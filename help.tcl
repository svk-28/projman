##!/usr/bin/wish                                                                 

###########################################################
#                Tcl/Tk Project Manager                   #
#                    version 0.0.1                        #
#                    help module                          #
# Copyright (c) "CONERO lab", 2002, http://conero.lrn.ru  #
# Author: Sergey Kalinin (aka BanZaj) banzaj@lrn.ru       #
###########################################################

#package require BWidget                                                         
#package require msgcat

## GETTING TABLES OF CONTENT ##
#set homeDir "$env(HOME)/projects/tcl/projman"
#set docDir "$env(HOME)/projects/tcl/projman/hlp"
#set imgDir "$env(HOME)/projects/tcl/projman/img"
#set msgDir "$env(HOME)/projects/tcl/projman/msgs"

#set workDir "$env(HOME)/.projman"

#source $workDir/projman.conf
source [file join $dataDir html_lib.tcl]
#source [file join $dataDir htmllib.tcl]

set sourceEncode "koi8-r"

## LOAD MESSAGES FILE? LANGUAGE AND NEDDED FILES ##
#source $homeDir/html.tcl

#::msgcat::mclocale $locale
#::msgcat::mcload $msgDir
proc HlpTreeOneClick {node} {
    global fontNormal hlpTree wordList hlpNoteBook findString imgDir fontBold fontNormal
    global lstSearch nodeParent
    $hlpTree selection set $node
    set nodeParent [$hlpTree parent $node]
    set item [$hlpTree itemcget $node -data]
    set file [string range $item 4 end]
    #puts "$file" ;#debuf info
    if {[string range $item 0 2] == "toc"} {
        #        $hlpTree configure
    }
    if {[$hlpTree itemcget $node -open] == 1} {
        $hlpTree itemconfigure $node -open 0
    } elseif {[$hlpTree itemcget $node -open] == 0} {
        $hlpTree itemconfigure $node -open 1
    }
    if {[string range $item 0 2] == "doc"} {
        GetContent $file
    }
}
## GETTING TABLE OF CONTENT ##
proc GetTOC {} {
    global docDir hlpTree imgDir fontNormal lstSearch arr sourceEncode
    if {[catch {cd $docDir}] != 0} {
        return ""
    }
    foreach dir [lsort [glob -nocomplain *]] {
        if {[file isdirectory $dir] == 1} {
            foreach file [lsort [glob -nocomplain [file join $dir *toc.html]]] {
                #puts $file
                set fileName [file join $file]
                set tocFile [open $fileName r]
                fconfigure $tocFile -encoding binary
                set dot "_"
                #set nodeParent [string range $fileName 0 [expr [string first "." $fileName]-1]]
                #puts $fileName
                set nodeParent [file dirname $fileName]
                while {[gets $tocFile line]>=0} {
                    set a ""
                    set b ""
                    set line [encoding convertfrom $sourceEncode $line]
                    if {[regexp -nocase "<title>.+\</title>" $line a]} {
                        if {[regexp ">.+\<" $line a]} {
                            set length [string length $a]
                            set title [string range $a 1 [expr $length-2]]
                            #puts $nodeParent ;# debug info
                            $hlpTree insert end root $nodeParent -text "$title" -font $fontNormal \
                                    -data "toc_$nodeParent" -open 0\
                                    -image [Bitmap::get [file join $imgDir books.gif]]
                        }
                    } elseif {[regexp "\".+\"" $line a]} {
                        set data [string range $a 1 [expr [string last "\"" $a]-1]]
                        if {[regexp ">.+\<" $line b]} {
                            set line [string range $b 1 [expr [string first "<" $b]-1]]
                            regsub -all {[ :]} $line "_" subNode
                            #regsub -all ":" $ubNode "_" node
                            set subNode "$nodeParent$dot$subNode"
                            if {[info exists arr($subNode)] == 0} {
                                set arr($subNode) [file join $dir $data]
                            }
                            set data [file join $dir $data]
                            #puts "$subNode" ;# debug info
                            $hlpTree insert end "$nodeParent" $subNode -text "$line"\
                            -font $fontNormal -data "doc_$data" -open 0\
                            -image [Bitmap::get [file join $imgDir file.gif]]
                            $lstSearch insert end $line
                        }        
                    } else {
                        break
                    }
                }
                
            } ;# foreach
        }
    }
    $hlpTree configure -redraw 1
}
proc SearchWord {word} {
    global arr nBookTree
    set word [string tolower [string trim $word]]
    puts $word
    $nBookTree raise hlpSearch
    InsertEnt .help.frmBody.frmCat.nBookTree.fhlpSearch.frmScrhEnt.entSearch $word
    foreach wrd [array names arr] {
        set name "[file rootname [file tail $arr($wrd)]]"
        set file "$arr($wrd)"
        if {[string match "$word*" [string tolower $name]] == 1} {
            GetContent $file
        }
    }
}
## GETTING CONTENT FROM FILES ##
proc GetContent {file} {
    global docDir hlpNoteBook fontNormal sourceEncode editor
    $hlpNoteBook raise [$hlpNoteBook page 0]
    set node [$hlpNoteBook raise]
    if {$node != ""} {
        $hlpNoteBook delete hlpHTML
    }
    set nbTitle ""
    set html ""
    set file [open $file r]
    fconfigure $file -encoding binary
    while {[gets $file line]>=0} {
        set line [encoding convertfrom $sourceEncode $line]
        if {[regexp -nocase "<title>.+\</title>" $line a]} {
            if {[regexp ">.+\<" $a a]} {
                set length [string length $a]
                set nbTitle [string range $a 1 [expr $length-2]]
                #puts $nbTitle
                #puts $a
            }
        }
        append html $line\n
    }
    set frmHTML [$hlpNoteBook insert end hlpHTML -text $nbTitle]
    set txt [text $frmHTML.txtHTML  -yscrollcommand "$frmHTML.yscroll set" \
            -relief sunken -wrap word -highlightthickness 0 -font $fontNormal\
            -selectborderwidth 0 -selectbackground #55c4d1 -width 10]
    scrollbar $frmHTML.yscroll -relief sunken -borderwidth {1} -width {10} -takefocus 0\
            -command "$frmHTML.txtHTML yview"
    
    pack $txt -side left -fill both -expand true
    pack $frmHTML.yscroll -side left -fill y
    $hlpNoteBook raise hlpHTML
    focus -force $txt
#    $txt configure -state disabled
    HM::init_win $txt
    HM::set_link_callback LinkCallback
    HM::set_state $txt -size 0
    HM::set_indent $txt 1.2
    HM::parse_html $html "HM::render $txt"
#    HM::tag_title .help "Help - $nbTitle"
    $txt configure -state disabled

}
## GOTO URL PROCEDURE ##
proc LinkCallback {w url} {
    global docDir nodeParent
    set url "[file join $docDir $nodeParent $url]"
    if {[catch {open $url r} oHTML]} {
        tk_messageBox -title "[::msgcat::mc "Error open URL"]"\
                -message "[::msgcat::mc "Can't found file:"] $url"\
                -icon error -type ok
    } else {
        GetContent $url
    }
}


##   autor DEDERER    ##
proc LinkCallback_ {w url} {
    global docDir
    set url "[file join $docDir $url]"
    if {[catch {open $url r} oHTML]} {
        tk_messageBox -title "[::msgcat::mc "Error open URL"]"\
                -message "[::msgcat::mc "Can't founf file: $url"]"\
                -icon error -type ok
    } else {
        set html [read $oHTML]
        $w configure -state normal
        HM::reset_win $w
        HM::parse_html $html "HM::render $w"
        $w configure -state disable
    }
#    HM::render [winfo toplevel $w] $url
}

## MAIN HELP WINDOW ##
proc TopLevelHelp {} {
    global fontNormal fontBold hlpTree hlpNoteBook nBookTree homeDir docDir lstSearch w frmSrchList
    global imgDir color editor
    set w .help
    set w_exist [winfo exists $w]
    if !$w_exist  {
        toplevel $w
        #    wm resizable .help 0 0
        wm geometry $w 900x800+0+0
        wm title $w [::msgcat::mc "Help"]
        #    wm protocol $w WM_DELETE_WINDOW {destroy .msg .help}
        #wm geometry . 600x400+0+0
        wm title $w [::msgcat::mc "Help"]
        
        frame $w.frmMenu -border 1 -relief raised
        frame $w.frmTool -border 1 -relief raised
        frame $w.frmBody -border 1 -relief raised
        frame $w.frmStatus -border 1 -relief sunken
        pack $w.frmMenu -side top -padx 1 -fill x
        pack $w.frmTool -side top -padx 1 -fill x
        pack $w.frmBody -side top -padx 1 -fill both -expand true
        pack $w.frmStatus -side top -padx 1 -fill x
        
        
        button $w.frmTool.btnBack -relief groove -font $fontBold -command Back -state disable
        button $w.frmTool.btnForward -relief groove -font $fontBold -command Forward -state disable
        button $w.frmTool.btnRefresh -relief groove -font $fontBold -command Refresh -state disable
        button $w.frmTool.btnPrint -relief groove -font $fontBold -command Print -state disable
        image create photo imgBack -format gif -file [file join $imgDir back.gif]
        image create photo imgForward -format gif -file [file join $imgDir forward.gif]
        image create photo imgRefresh -format gif -file [file join $imgDir refresh.gif]
        image create photo imgPrint -format png -file [file join $imgDir printer.png]
        $w.frmTool.btnBack configure -image imgBack
        $w.frmTool.btnForward configure -image imgForward
        $w.frmTool.btnRefresh configure -image imgRefresh
        $w.frmTool.btnPrint configure -image imgPrint
        pack $w.frmTool.btnBack $w.frmTool.btnForward $w.frmTool.btnRefresh $w.frmTool.btnPrint\
        -side left -fill x
        
        
        set frmCat [frame $w.frmBody.frmCat -border 1 -relief sunken]
        pack $frmCat -side left -fill y
        set frmWork [frame $w.frmBody.frmWork -border 1 -relief sunken]
        pack $frmWork -side left -fill both -expand true
        
        set nBookTree [NoteBook $frmCat.nBookTree -font $fontNormal -bg $editor(bg) -fg $editor(fg)]
        pack $nBookTree -fill both -expand true -padx 2 -pady 2
        set frmTreeNb [$nBookTree insert end hlpTree -text "[::msgcat::mc "Contents"]"]
        set frmSearch [$nBookTree insert end hlpSearch -text "[::msgcat::mc "Search"]"]
        $nBookTree raise hlpTree
        
        set frmScrlX [frame $frmTreeNb.frmScrlX -border 0 -relief sunken]
        set frmTree [frame $frmTreeNb.frmTree -border 1 -relief sunken]
        set hlpTree [Tree $frmTree.tree \
        -relief sunken -borderwidth 1 -width 20 -highlightthickness 0\
        -redraw 0 -dropenabled 1 -dragenabled 1 -dragevent 3 \
        -yscrollcommand {.help.frmBody.frmCat.nBookTree.fhlpTree.frmTree.scrlY set} \
        -xscrollcommand {.help.frmBody.frmCat.nBookTree.fhlpTree.frmScrlX.scrlX set} \
        -selectbackground "#55c4d1" \
        -droptypes {
            TREE_NODE    {copy {} move {} link {}}
            LISTBOX_ITEM {copy {} move {} link {}}
        } -opencmd   "" -closecmd  ""]
        
        pack $frmTree -side top -fill y -expand true
        pack $frmScrlX -side top -fill x
        
        scrollbar $frmTree.scrlY -command {$hlpTree yview} \
        -borderwidth {1} -width {10} -takefocus 0
        pack $hlpTree $frmTree.scrlY -side left -fill y
        
        scrollbar $frmScrlX.scrlX -command {$hlpTree xview} \
        -orient horizontal -borderwidth {1} -width {10} -takefocus 0
        pack $frmScrlX.scrlX -fill x -expand true
        
        set frmSrchList [frame $frmSearch.frmScrhList -border 0 -relief sunken]
        set frmSrchEnt [frame $frmSearch.frmScrhEnt -border 0 -relief sunken]
        set frmSrchScrollX [frame $frmSearch.frmScrhScrollX -border 0 -relief sunken]
        pack $frmSrchEnt -side top -fill x
        pack $frmSrchList -side top -fill both -expand true
        pack $frmSrchScrollX -side top -fill x
        
        entry $frmSrchEnt.entSearch
        set lstSearch [listbox $frmSrchList.lstSearch -font $fontNormal\
        -yscrollcommand\
        {.help.frmBody.frmCat.nBookTree.fhlpSearch.frmScrhList.scrListY set}\
        -xscrollcommand\
        {.help.frmBody.frmCat.nBookTree.fhlpSearch.frmScrhScrollX.scrListX set}\
        -selectmode single -selectbackground #55c4d1\
        -selectborderwidth 0]
        scrollbar $frmSrchList.scrListY -command\
        {$frmSrchList.lstSearch yview} -borderwidth {1} -width {10} -takefocus 0
        
        pack $frmSrchEnt.entSearch -side top -fill x -expand true
        
        pack $frmSrchList.lstSearch -side left -fill both -expand true
        pack $frmSrchList.scrListY -side left -fill y
        
        scrollbar $frmSrchScrollX.scrListX -orient horizontal -command\
        {$frmSrchList.lstSearch xview} -borderwidth {1} -width {10} -takefocus 0
        pack $frmSrchScrollX.scrListX -fill x
        #            $hlpTree bindText <ButtonRelease-4> [puts %k]
        #            $hlpTree bindText <ButtonRelease-3> [puts %k]
        #            bind $frmTree <ButtonPress-4> {$frmSrchList.lstSearch xview}
        #        $hlpTree bindText  <Double-ButtonPress-1> "HlpTreeDoubleClick [$hlpTree selection get]"
        #        $hlpTree bindImage  <Double-ButtonPress-1> "HlpTreeDoubleClick [$hlpTree selection get]"
        $hlpTree bindText  <ButtonPress-1> "HlpTreeOneClick [$hlpTree selection get]"
        $hlpTree bindImage  <ButtonPress-1> "HlpTreeOneClick [$hlpTree selection get]"
        bind .help <Escape> "destroy .help"
        
        #        bind $frmSrchEnt.entSearch <KeyRelease>\
        #                {SearchWord [Text .help.frmBody.frmCat.nBookTree.fhlpSearch.frmScrhEnt.entSearch]}
        
        #bind $w <Escape> exit
        #bind $frmTree <Down> {TreeClick [$hlpTree selection get]}
        #bind $frmTree <Up> {TreeClick [$hlpTree selection get]}
        #bind $frmTree <Return> {TreeClick [$hlpTree selection get]}
        bind $frmTree.tree.c <Button-4> "$hlpTree yview scroll -3 units"
        bind $frmTree.tree.c <Button-5> "$hlpTree yview scroll  3 units"
        bind $frmTree.tree.c <Shift-Button-4> "$hlpTree xview scroll -2 units"
        bind $frmTree.tree.c <Shift-Button-5> "$hlpTree xview scroll  2 units"
        
        set hlpNoteBook [NoteBook $frmWork.hlpNoteBook -font $fontNormal  -bg $editor(bg) -fg $editor(fg)]
        pack $hlpNoteBook -fill both -expand true -padx 2 -pady 2
        GetTOC
    }
    
}

##################################################
#TopLevelHelp
#GetTOC

#GetContent $docDir/tcl.toc.html






























