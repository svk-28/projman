######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
#
# All procedures module
#
######################################################

proc Quit {} {
    global dir
    Config::write $dir(cfg)
    if {[FileOper::CloseAll] eq "cancel"} {
        return "cancel"
    } else {
        exit
    }
}

proc ViewFilesTree {} {
    global cfgVariables
    if {$cfgVariables(filesPanelShow) eq "true"} {
        .frmBody.panel forget .frmBody.frmTree
        set cfgVariables(filesPanelShow) false
    } else {
        switch $cfgVariables(filesPanelPlace) {
        "left" {        
                .frmBody.panel insert 0 .frmBody.frmTree
            }
            "right" {
                .frmBody.panel add .frmBody.frmTree
            }
            default {
                .frmBody.panel insert 0 .frmBody.frmTree
            }
        }
        set cfgVariables(filesPanelShow) true
    }
}

# Enable/Disabled line numbers in editor
proc ViewLineNumbers {} {
    global cfgVariables nbEditor
    # Changed global settigs
    if {$cfgVariables(lineNumberShow) eq "true"} {
        set cfgVariables(lineNumberShow) false
    } else {
        set cfgVariables(lineNumberShow) true
    }
    # apply changes for opened tabs
    foreach node [$nbEditor tabs] {
        $node.frmText.t configure -linemap $cfgVariables(lineNumberShow)
    }
}

proc Del {} {
    return
}

proc YScrollCommand {txt canv} {
    $txt yview
    $canv yview"
}

proc ResetModifiedFlag {w} {
    global modified nbEditor
    $w.frmText.t edit modified false
    set modified($w) "false"
    set lbl [string trimleft [$nbEditor tab $w -text] "* "]
    puts "ResetModifiedFlag: $lbl"
    $nbEditor tab $w -text $lbl
}
proc SetModifiedFlag {w} {
    global modified nbEditor
    #$w.frmText.t edit modified false
    set modified($w) "true"
    set lbl [$nbEditor tab $w -text]
    puts "SetModifiedFlag: $w; $modified($w); >$lbl<"
    if {[regexp -nocase -all -- {^\*} $lbl match] == 0} {
        set lbl "* $lbl"
    }
    $nbEditor tab $w -text $lbl
}

proc ImageBase64Encode {} {
    global env nbEditor
    set types {
        {"PNG" {.png}}
        {"GIF" {.gif}}
        {"JPEG" {.jpg}}
        {"BMP" {.bmp}}
        {"All files" *}
    }
    set txt "[$nbEditor select].frmText.t"
    set img [tk_getOpenFile -initialdir $env(HOME) -filetypes $types -parent .]
    if {$img ne ""} {
        set f [open $img]
        fconfigure $f -translation binary
        set data [base64::encode [read $f]]
        close $f
        # base name on root name of the image file
        set name [file root [file tail $img]]
        $txt insert insert "image create photo $name -data {\n$data\n}"
    }
}
proc FindImage {ext} {
    foreach img [image names] {
        if [regexp -nocase -all -- "^($ext)(_)" $img match v1 v2] {
            # puts "\nFindinig images: $img \n"
            return $img
        }
    }
}

namespace eval Help {
    proc About {} {
        global projman
        set msg "Tcl/Tk project Manager\n\n"
        append msg  "Version: " $projman(Version) "\n" \
            "Release: " $projman(Release) "\n" \
            "Build: " $projman(Build) "\n\n" \
            "Author: " $projman(Author) "\n" \
            "Home page: " $projman(Homepage)
        # foreach name [array names projman] {
            # append msg $name ": " $projman($name) "\n"
        # }
        set answer [
            tk_messageBox -message "[::msgcat::mc "About ..."] ProjMan" \
            -icon info -type ok -detail $msg
        ]
        switch $answer {
            ok {return}
        }
    }
}

proc SearchVariable {txt} {
    global fileStructure project variables
    set varName [$txt get {insert wordstart} {insert wordend}]
    puts ">>>$varName<<<"
    if {[info exists project] == 0} {return}
    foreach f [array names project] {
        puts "--$f"
        puts "----"
        foreach a $project($f) {
            puts "-----$variables($a)"
            foreach b $variables($a) {
                puts "------$b -- [lindex $b 0]"
                if {$varName eq [lindex $b 0]} {
                    puts "УРААААААА $varName = $b в файле $a \n\t [lindex $b 0]"
                    FindVariablesDialog $txt "$varName: $a"
                }
            }
        }
    }
}
proc FindVariablesDialog {txt args} {
    global editors lexers
    # variable txt 
    variable win
    # set txt $w.frmText.t
    set box        [$txt bbox insert]
    set x      [expr [lindex $box 0] + [winfo rootx $txt] ]
    set y      [expr [lindex $box 1] + [winfo rooty $txt] + [lindex $box 3] ]

    set win .findVariables

    if { [winfo exists $win] }  { destroy $win }
    toplevel $win
    wm transient $win .
    wm overrideredirect $win 1
    
    listbox $win.lBox -width 50 -border 2 -yscrollcommand "$win.yscroll set" -border 1
    ttk::scrollbar $win.yscroll -orient vertical -command  "$win.lBox yview"
    pack $win.lBox -expand true -fill y -side left
    pack $win.yscroll -side left -expand false -fill y
    
    foreach { word } $args {
        $win.lBox insert end $word
    }
    
    catch { $win.lBox activate 0 ; $win.lBox selection set 0 0 }
    
    if { [set height [llength $args]] > 10 } { set height 10 }
    $win.lBox configure -height $height

    bind $win      <Escape> { 
        destroy $win
        # focus -force $txt.t
        break
    }
    bind $win.lBox <Escape> {
        destroy $win
        # focus -force $txt.t
        break
    }
    bind $win.lBox <Return> {
        # set findString [dict get $lexers [dict get $editors $Editor::txt fileType] procFindString]
        set values [.findVariables.lBox get [.findVariables.lBox curselection]]
        # regsub -all {PROCNAME} $findString $values str
        # Editor::FindFunction "$str"
        destroy .findVariables
        # $txt tag remove sel 1.0 end
        # focus $Editor::txt.t
        break
    }
    bind $win.lBox <Any-Key> {Editor::ListBoxSearch %W %A}
    # Определям расстояние до края экрана (основного окна) и если
    # оно меньше размера окна со списком то сдвигаем его вверх
    set winGeom [winfo reqheight $win]
    set topHeight [winfo height .]
    # puts "$x, $y, $winGeom, $topHeight"
    if [expr [expr $topHeight - $y] < $winGeom] {
        set y [expr $topHeight - $winGeom]
    }
    wm geom $win +$x+$y
}

   
