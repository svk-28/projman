###########################################################
#                Tcl/Tk Project Manager                   #
#                Distrubuted under GPL                    #
# Copyright (c) "CONERO lab", 2002, http://conero.lrn.ru  #
# Author: Sergey Kalinin (aka BanZaj) banzaj@lrn.ru       #
###########################################################

Modules
## MAIN INTERFACE ##
wm geometry . 1024x768+0+0
wm title . "Tcl/Tk Project Manager $ver"
wm iconname . "Tcl/Tk Project Manager $ver"
wm protocol . WM_DELETE_WINDOW Quit
wm overrideredirect . 0
wm positionfrom . user
#wm resizable . 0 0

frame .frmMenu -border 1 -relief raised -background $editor(bg)
frame .frmTool -border 1 -relief raised -background $editor(bg)
frame .frmBody -border 1 -relief raised -background $editor(bg)
frame .frmStatus -border 1 -relief sunken -bg $editor(bg)
pack .frmMenu -side top -padx 1 -fill x
pack .frmTool -side top -padx 1 -fill x
pack .frmBody -side top -padx 1 -fill both -expand true
pack .frmStatus -side top -padx 1 -fill x

########## CREATE MENU LINE ##########
menubutton .frmMenu.mnuFile -text [::msgcat::mc "File"] -menu .frmMenu.mnuFile.m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuFile.m -bg $editor(bg) -fg $editor(fg)]
$m add cascade -label [::msgcat::mc "New"] -menu $m.new -font $fontNormal
set mn [menu $m.new  -bg $editor(bg) -fg $editor(fg)]
$mn add command -label [::msgcat::mc "New file"] -command {AddToProjDialog file}\
-font $fontNormal -accelerator "Ctrl+N"
$mn add command -label [::msgcat::mc "New directory"] -command {AddToProjDialog directory}\
-font $fontNormal -accelerator "Ctrl+N"
$mn add command -label [::msgcat::mc "New project"] -command {NewProjDialog "new"}\
-font $fontNormal
$m add command -label [::msgcat::mc "Open"] -command {FileDialog open}\
-font $fontNormal -accelerator "Ctrl+O"        -state disable
$m add command -label [::msgcat::mc "Save"] -command {FileDialog save}\
-font $fontNormal -accelerator "Ctrl+S"
$m add command -label [::msgcat::mc "Save as"] -command {FileDialog save_as}\
-font $fontNormal -accelerator "Ctrl+A"
$m add command -label [::msgcat::mc "Save all"] -command {FileDialog save_all}\
-font $fontNormal
$m add command -label [::msgcat::mc "Close"] -command {FileDialog close}\
-font $fontNormal -accelerator "Ctrl+W"
$m add command -label [::msgcat::mc "Close all"] -command {FileDialog close_all}\
-font $fontNormal
$m add command -label [::msgcat::mc "Delete"] -command {FileDialog delete}\
-font $fontNormal -accelerator "Ctrl+D"
$m add separator
$m add command -label [::msgcat::mc "Compile file"] -command {MakeProj compile file} -font $fontNormal -accelerator "Ctrl+F8"
$m add command -label [::msgcat::mc "Run file"] -command {MakeProj run file} -font $fontNormal -accelerator "Ctrl+F9"
$m add separator
$m add command -label [::msgcat::mc "Print"] -command PrintDialog\
-font $fontNormal -accelerator "Ctrl+P"
$m add separator
$m add command -label [::msgcat::mc "Settings"] -command Settings -font $fontNormal
$m add separator
$m add command -label [::msgcat::mc "Exit"] -command Quit -font $fontNormal -accelerator "Ctrl+Q"

##.frmMenu 'Project' ##

proc GetProjMenu {m} {
    global fontNormal
    $m add command -label [::msgcat::mc "Project settings"] -command {NewProj edit $activeProject ""}\
    -font $fontNormal
    $m add separator
    $m add command -label [::msgcat::mc "Open project"] -command {OpenProj} -font $fontNormal
    $m add command -label [::msgcat::mc "New project"] -command {NewProjDialog new} -font $fontNormal
    $m add command -label [::msgcat::mc "Delete project"] -command DelProj -font $fontNormal
    $m add separator
    $m add command -label [::msgcat::mc "Add to project"] -command AddToProjDialog -font $fontNormal
    $m add command -label [::msgcat::mc "Delete from project"]\
    -command {FileDialog delete} -font $fontNormal
    $m add separator
    $m add command -label [::msgcat::mc "Make archive"] -command MakeTGZ -font $fontNormal -accelerator "F7"
    $m add command -label [::msgcat::mc "Make RPM"] -command MakeRPM -font $fontNormal -accelerator "F6"
    $m add separator
    $m add command -label [::msgcat::mc "Compile"] -command {MakeProj compile proj} -font $fontNormal -accelerator "F8"
    $m add command -label [::msgcat::mc "Run"] -command {MakeProj run proj} -font $fontNormal -accelerator "F9"
}

menubutton .frmMenu.mnuProj -text [::msgcat::mc "Project"] -menu .frmMenu.mnuProj.m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuProj.m -bg $editor(bg) -fg $editor(fg)]
GetProjMenu $m

##.frmMenu 'Edit' ##
menubutton .frmMenu.mnuEdit -text [::msgcat::mc "Edit"] -menu .frmMenu.mnuEdit.m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
## BUILDING EDIT-MENU FOR MAIN AND POP-UP MENU ##
proc GetMenu {m} {
    global fontNormal fontBold imgDir editor
    $m add command -label [::msgcat::mc "Undo"] -font $fontNormal -accelerator "Ctrl+Z"\
    -state normal -command Undo
    $m add command -label [::msgcat::mc "Redo"] -font $fontNormal -accelerator "Ctrl+Z"\
    -state normal -command Redo
    $m add separator
    $m add command -label [::msgcat::mc "Procedure name complit"] -font $fontNormal -accelerator "Ctrl+J" -state normal\
    -command {
        set nb "$noteBook.f[$noteBook raise]"
        auto_completition_proc $nb.text
        unset nb
    }
    $m add separator
    $m add command -label [::msgcat::mc "Copy"] -font $fontNormal -accelerator "Ctrl+C"\
    -command {
        set nb "$noteBook.f[$noteBook raise]"
        tk_textCopy $nb.text
        unset nb
    }
    $m add command -label [::msgcat::mc "Paste"] -font $fontNormal -accelerator "Ctrl+V"\
    -command {
        set nb "$noteBook.f[$noteBook raise]"
        tk_textPaste $nb.text
        unset nb
    }
    $m add command -label [::msgcat::mc "Cut"] -font $fontNormal -accelerator "Ctrl+X"\
    -command {
        set nb "$noteBook.f[$noteBook raise]"
        tk_textCut $nb.text
        unset nb
    }
    $m add separator
    $m add command -label [::msgcat::mc "Select all"] -font $fontNormal -accelerator "Ctrl+/"\
    -command {
        set nb [$noteBook raise]
        if {$nb == "" || $nb == "newproj" || $nb == "about" || $nb == "debug"} {
            return
        }
        set nb "$noteBook.f$nb"
        SelectAll $nb.text
        unset nb
    }
    $m add separator
    $m add command -label [::msgcat::mc "Goto line"] -command GoToLine -font $fontNormal\
    -accelerator "Ctrl+G"
    $m add command -label [::msgcat::mc "Find"] -command Find -font $fontNormal -accelerator "Ctrl+F"
    $m add command -label [::msgcat::mc "Replace"] -command ReplaceDialog -font $fontNormal\
    -accelerator "Ctrl+R"
    $m add cascade -label [::msgcat::mc "Encode"] -menu $m.encode -font $fontNormal
	set me [menu $m.encode  -bg $editor(bg) -fg $editor(fg)]
	$me add command -label [::msgcat::mc "KOI8-R"] -command {TextEncode koi8-r} -font $fontNormal
	$me add command -label [::msgcat::mc "CP1251"] -command {TextEncode cp1251} -font $fontNormal
	$me add command -label [::msgcat::mc "CP866"] -command {TextEncode cp866} -font $fontNormal
}
GetMenu [menu .frmMenu.mnuEdit.m -bg $editor(bg) -fg $editor(fg)];# main edit menu
GetMenu [menu .popMnuEdit -bg $editor(bg) -fg $editor(fg)] ;# pop-up edit menu

## VIEW MENU ##
menubutton .frmMenu.mnuView -text [::msgcat::mc "View"] -menu .frmMenu.mnuView.m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuView.m -bg $editor(bg) -fg $editor(fg)]
$m add checkbutton -label [::msgcat::mc "Toolbar"] -font $fontNormal -state normal\
-offvalue "No" -onvalue "Yes" -variable toolBar -command {ToolBar}
$m add command -label [::msgcat::mc "Split edit window"] -font $fontNormal -accelerator "F4" -state disable\
-command SplitWindow
$m add separator
$m add command -label [::msgcat::mc "Refresh"] -font $fontNormal -accelerator "F5" -state normal\
-command UpdateTree

##.frmMenu Settings ##
menubutton  .frmMenu.mnuCVS -text [::msgcat::mc "Modules"] -menu .frmMenu.mnuCVS.m \
-font $fontNormal -state normal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuCVS.m -bg $editor(bg) -fg $editor(fg)]
if {$module(tkcvs) != ""} {
    $m add command -label "TkCVS" -command {DoModule tkcvs} -font $fontNormal
}
if {$module(tkdiff) != ""} {
    $m add command -label "TkDIFF+" -command {DoModule tkdiff} -font $fontNormal
}
if {$module(tkregexp) != ""} {
    $m add command -label "TkREGEXP" -command {DoModule tkregexp} -font $fontNormal
}
if {$module(ctags) != ""} {
    $m add command -label "CTags" -font $fontNormal -command {
        DoModule ctags
        GetTagList [file join $workDir $activeProject.tags] ;# geting tag list
    }
}

menubutton  .frmMenu.mnuHelp  -text [::msgcat::mc "Help"] -menu .frmMenu.mnuHelp.m \
-underline 0 -font $fontNormal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuHelp.m -bg $editor(bg) -fg $editor(fg)]
$m  add  command  -label [::msgcat::mc "Help"]  -command  ShowHelp \
-accelerator F1 -font $fontNormal
$m add command -label [::msgcat::mc "About ..."] -command AboutDialog \
-font $fontNormal

pack .frmMenu.mnuFile .frmMenu.mnuProj .frmMenu.mnuEdit .frmMenu.mnuView .frmMenu.mnuCVS -side left
pack .frmMenu.mnuHelp -side right
## Bind command ##
bind . <F1> ShowHelp
bind . <F5> UpdateTree
bind . <F6> MakeRPM
bind . <F7> MakeTGZ
bind . <F8> {MakeProj compile proj}
bind . <Control-F8> {MakeProj compile file}
bind . <F9> {MakeProj run proj}
bind . <Control-F9> {MakeProj run file}
bind . <Control-ograve> AddToProjDialog
bind . <Control-n> AddToProjDialog
bind . <Control-ocircumflex> AddToProjDialog
bind . <Control-a> AddToProjDialog
bind . <Control-eacute> Quit
bind . <Control-q> Quit
bind . <Control-ccedilla> PrintDialog
bind . <Control-p> PrintDialog
## TOOLBAR ##
proc add_toolbar_button {path icon command helptext} {
    global editor imgDir
    image create photo $icon -format png -file [file join $imgDir $icon]
    $path add -image $icon \
    -highlightthickness 0 -takefocus 0 -relief link -bd 1  -activebackground $editor(bg)\
    -padx 1 -pady 1 -command $command -helptext $helptext
}
# Separator for toolbar
set sepIndex 0
proc Separator {} {
    global sepIndex editor
    set f [frame .frmTool.separator$sepIndex -width 10 -border 1 -background $editor(bg) -relief raised]
    incr sepIndex 1
    return $f
}
proc CreateToolBar {} {
    global toolBar fontBold noteBook tree imgDir editor
    if {$toolBar == "Yes"} {
        set bboxFile [ButtonBox .frmTool.bboxFile -spacing 0 -padx 1 -pady 1 -bg $editor(bg)]
        add_toolbar_button $bboxFile new.png {AddToProjDialog file} [::msgcat::mc "Create new file"]
        add_toolbar_button $bboxFile save.png {FileDialog save} [::msgcat::mc "Save file"]
        add_toolbar_button $bboxFile save_as.png {FileDialog save_as} [::msgcat::mc "Save file as"]
        add_toolbar_button $bboxFile save_all.png {FileDialog save_all} [::msgcat::mc "Save all"]
        add_toolbar_button $bboxFile printer.png {PrintDialog} [::msgcat::mc "Print ..."]
        add_toolbar_button $bboxFile close.png {FileDialog close} [::msgcat::mc "Close"]
        
        set bboxEdit [ButtonBox .frmTool.bboxEdit -spacing 0 -padx 1 -pady 1 -bg $editor(bg)]
        add_toolbar_button $bboxEdit copy.png {TextOperation copy} [::msgcat::mc "Copy into clipboard"]
        add_toolbar_button $bboxEdit cut.png {TextOperation cut} [::msgcat::mc "Cut into clipboard"]
        add_toolbar_button $bboxEdit paste.png {TextOperation paste} [::msgcat::mc "Paste from clipboard"]
        add_toolbar_button $bboxEdit undo.png {TextOperation undo} [::msgcat::mc "Undo"]
        add_toolbar_button $bboxEdit redo.png {TextOperation redo} [::msgcat::mc "Redo"]
        
        
        set bboxProj [ButtonBox .frmTool.bboxProj -spacing 0 -padx 1 -pady 1 -bg $editor(bg)]
        
        add_toolbar_button $bboxProj doit.png {MakeProj run proj} [::msgcat::mc "Running project"]
        add_toolbar_button $bboxProj doit_file.png {MakeProj run file} [::msgcat::mc "Running file"]
        add_toolbar_button $bboxProj archive.png {MakeTGZ} [::msgcat::mc "Make TGZ"]
        
        set bboxHelp [ButtonBox .frmTool.bboxHelp -spacing 0 -padx 1 -pady 1 -bg $editor(bg)]
        add_toolbar_button $bboxHelp help.png {ShowHelp} [::msgcat::mc "Help"]
        
        pack $bboxFile [Separator] $bboxEdit [Separator] $bboxProj [Separator] $bboxHelp -side left -anchor w
        
    }
}
########## STATUS BAR ##########
set frm1 [frame .frmStatus.frmHelp -bg $editor(bg)]
set frm2 [frame .frmStatus.frmActive -bg $editor(bg)]
set frm3 [frame .frmStatus.frmProgress -relief sunken -bg $editor(bg)]
set frm4 [frame .frmStatus.frmLine -bg $editor(bg)]
set frm5 [frame .frmStatus.frmFile -bg $editor(bg)]
set frm6 [frame .frmStatus.frmOvwrt -bg $editor(bg)]
pack $frm1 $frm4 $frm6 $frm2 $frm5 -side left -fill x
pack $frm3 -side left -fill x -expand true
label $frm1.lblHelp -width 25 -relief sunken -font $fontNormal -anchor w -bg $editor(bg) -fg $editor(fg)
pack $frm1.lblHelp -fill x
label $frm4.lblLine -width 10 -relief sunken -font $fontNormal -anchor w -bg $editor(bg) -fg $editor(fg)
pack $frm4.lblLine -fill x
label $frm2.lblActive -width 25 -relief sunken -font $fontNormal -anchor center -bg $editor(bg) -fg $editor(fg)
pack $frm2.lblActive -fill x
label $frm3.lblProgress -relief sunken -font $fontNormal -anchor w -bg $editor(bg) -fg $editor(fg)
pack $frm3.lblProgress -fill x
label $frm5.lblFile -width 10 -relief sunken -font $fontNormal -anchor w -bg $editor(bg) -fg $editor(fg)
pack $frm5.lblFile -fill x
label $frm6.lblOvwrt -width 10 -relief sunken -font $fontNormal -anchor center -bg $editor(bg) -fg $editor(fg)
pack $frm6.lblOvwrt -fill x

########## PROJECT-FILE-FUNCTION TREE ##################

set frmCat [frame .frmBody.frmCat -border 1 -relief sunken -bg $editor(bg)]
pack $frmCat -side left -fill y -fill both
set frmWork [frame .frmBody.frmWork -border 1 -relief sunken -bg $editor(bg)]
pack $frmWork -side left -fill both -expand true

## CREATE PANE ##
pane::create .frmBody.frmCat .frmBody.frmWork

set frmTree [ScrolledWindow $frmCat.frmTree -bg $editor(bg)]
global tree noteBook
set tree [Tree $frmTree.tree \
-relief sunken -borderwidth 1 -width 5 -height 5 -highlightthickness 1\
-redraw 0 -dropenabled 1 -dragenabled 1 -dragevent 3 \
-background $editor(bg) -selectbackground "#55c4d1" \
-droptypes {
    TREE_NODE    {copy {} move {} link {}}
    LISTBOX_ITEM {copy {} move {} link {}}
} -opencmd {TreeOpen} -closecmd  {TreeClose}]
$frmTree setwidget $tree
pack $frmTree -side top -fill both -expand true

$tree bindText  <Double-ButtonPress-1> "TreeDoubleClick [$tree selection get]"
$tree bindText  <ButtonPress-1> "TreeOneClick [$tree selection get]"
$tree bindImage  <Double-ButtonPress-1> "TreeDoubleClick [$tree selection get]"
$tree bindImage  <ButtonPress-1> "TreeOneClick [$tree selection get]"
$tree bindText <Shift-Button-1> {$tree selection add [$tree selection get]}
bind $frmTree.tree.c <Control-acircumflex> {FileDialog delete}
bind $frmTree.tree.c <Control-d> {FileDialog delete}
bind $frmTree.tree.c <Return> {
    set node [$tree selection get]
    TreeOneClick $node
    TreeDoubleClick $node
}

## POPUP FILE-MENU ##
set m .popupFile
menu $m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
$m add command -label [::msgcat::mc "New file"] -command {AddToProjDialog file}\
-font $fontNormal -accelerator "Ctrl+N"
$m add command -label [::msgcat::mc "New directory"] -command {AddToProjDialog directory}\
-font $fontNormal -accelerator "Alt + Ctrl+N"
$m add command -label [::msgcat::mc "Open"] -command {FileDialog open}\
-font $fontNormal -accelerator "Ctrl+O"        -state disable
$m add command -label [::msgcat::mc "Save"] -command {FileDialog save}\
-font $fontNormal -accelerator "Ctrl+S"
$m add command -label [::msgcat::mc "Save as"] -command {FileDialog save_as}\
-font $fontNormal -accelerator "Ctrl+A"
$m add command -label [::msgcat::mc "Save all"] -command {FileDialog save_all}\
-font $fontNormal
$m add command -label [::msgcat::mc "Close"] -command {FileDialog close}\
-font $fontNormal -accelerator "Ctrl+W"
$m add command -label [::msgcat::mc "Close all"] -command {FileDialog close_all}\
-font $fontNormal
$m add command -label [::msgcat::mc "Delete"] -command {FileDialog delete}\
-font $fontNormal -accelerator "Ctrl+D"
$m add separator
$m add command -label [::msgcat::mc "Compile file"] -command {MakeProj compile file} -font $fontNormal -accelerator "Ctrl+F8"
$m add command -label [::msgcat::mc "Run file"] -command {MakeProj run file} -font $fontNormal -accelerator "Ctrl+F9"

## POPUP PROJECT-MENU ##
set m [menu .popupProj -font $fontNormal -bg $editor(bg) -fg $editor(fg)]
GetProjMenu $m


## TABS popups ##

set m .popupTabs
menu $m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
$m add command -label [::msgcat::mc "Close"] -command {FileDialog close}\
-font $fontNormal -accelerator "Ctrl+W"
$m add command -label [::msgcat::mc "Close all"] -command {FileDialog close_all}\
-font $fontNormal


proc PopupMenuTab {menu x y} {
    tk_popup $menu $x $y
}



bind $frmTree.tree.c <Button-3> {catch [PopupMenuTree %X %Y]}

######### DEDERER: bind Wheel Scroll ##################
#$tree bindText  <Button-4> "$tree yview scroll -3 units ; break ;# "
#$tree bindText  <Button-5> "$tree yview scroll  3 units ; break ;# "
bind $frmTree.tree.c <Button-4> "$tree yview scroll -3 units"
bind $frmTree.tree.c <Button-5> "$tree yview scroll  3 units"
bind $frmTree.tree.c <Shift-Button-4> "$tree xview scroll -2 units"
bind $frmTree.tree.c <Shift-Button-5> "$tree xview scroll  2 units"

#################### WORKING AREA ####################
set noteBook [NoteBook $frmWork.noteBook -font $fontNormal -side top -bg $editor(bg) -fg $editor(fg)]
pack $noteBook -fill both -expand true -padx 2 -pady 2
#$noteBook bindtabs  <ButtonRelease-1> "PageRaise [$tree selection get]"
$noteBook bindtabs <Button-3> {catch [PopupMenuTab .popupTabs %X %Y]}


#bind . <Control-udiaeresis> PageTab
#bind . <Control-M> PageTab

bind . <Control-Next> {PageTab 1}
bind . <Control-Prior> {PageTab -1}

##################################################
CreateToolBar
GetProj $tree
$tree configure -redraw 1
set activeProject ""
focus -force $tree























