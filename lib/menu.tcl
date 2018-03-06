        ######################################################
#                Tcl/Tk Project Manager
#        Distributed under GNU Public License
# Author: Sergey Kalinin banzaj28@yandex.ru
# Copyright (c) "https://nuk-svk.ru", 2018, https://bitbucket.org/svk28/projman
######################################################
#
# Menu file
#
######################################################

proc PopupMenuTab {menu x y} {
    tk_popup $menu $x $y
}

# File tree pop-up menu
proc GetMenuFileTree {m} {
    global fontNormal
    
}

# Project menu
proc GetProjMenu {m} {
    global fontNormal
    $m add command -label [::msgcat::mc "Project settings"] -command {NewProj edit $activeProject ""}\
    -font $fontNormal
    $m add separator
    $m add command -label [::msgcat::mc "Open project"] -command {OpenProj} -font $fontNormal
    $m add command -label [::msgcat::mc "New project"] -command {NewProj new "" ""} -font $fontNormal
    $m add command -label [::msgcat::mc "Delete project"] -command DelProj -font $fontNormal
    $m add separator
    $m add command -label [::msgcat::mc "Add to project"] \
    -command {AddToProjDialog ""} -font $fontNormal -state disable
    $m add command -label [::msgcat::mc "Delete from project"]\
    -command {FileDialog delete} -font $fontNormal  -state disable
    $m add separator
    $m add command -label [::msgcat::mc "Make archive"] -command MakeTGZ -font $fontNormal -accelerator "F7"
    $m add command -label [::msgcat::mc "Make RPM"] -command MakeRPM -font $fontNormal -accelerator "F6"
    $m add separator
    $m add command -label [::msgcat::mc "Compile"] -command {MakeProj compile proj} -font $fontNormal -accelerator "F8"
    $m add command -label [::msgcat::mc "Run"] -command {MakeProj run proj} -font $fontNormal -accelerator "F9"
}

# Edit menu
proc GetMenu {m} {
    global fontNormal fontBold imgDir editor
    $m add command -label [::msgcat::mc "Undo"] -font $fontNormal -accelerator "Ctrl+Z"\
    -state normal -command {TextOperation undo}
    $m add command -label [::msgcat::mc "Redo"] -font $fontNormal -accelerator "Ctrl+G"\
    -state normal -command {TextOperation redo}
    $m add separator
    $m add command -label [::msgcat::mc "Procedure name complit"] -font $fontNormal -accelerator "Ctrl+J" -state normal\
    -command {
        set nb "$noteBook.f[$noteBook raise]"
        auto_completition_proc $nb.text
        unset nb
    }
    $m add separator
    $m add command -label [::msgcat::mc "Copy"] -font $fontNormal -accelerator "Ctrl+C"\
    -command {TextOperation copy}
    $m add command -label [::msgcat::mc "Paste"] -font $fontNormal -accelerator "Ctrl+V"\
    -command {TextOperation paste}
    $m add command -label [::msgcat::mc "Cut"] -font $fontNormal -accelerator "Ctrl+X"\
    -command {TextOperation cut}
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
    $m add command -label [::msgcat::mc "Comment selected"] -font $fontNormal -accelerator "Ctrl+,"\
    -command {TextOperation comment}
            $m add command -label [::msgcat::mc "Uncomment selected"] -font $fontNormal  -accelerator "Ctrl+." \
    -command {TextOperation uncomment}
    
    $m add separator
    $m add command -label [::msgcat::mc "Goto line"] -command GoToLine -font $fontNormal -accelerator "Ctrl+g"
    $m add separator
    
    $m add command -label [::msgcat::mc "Find"] -command Find -font $fontNormal -accelerator "Ctrl+F"
    $m add command -label [::msgcat::mc "Replace"] -command ReplaceDialog -font $fontNormal\
    -accelerator "Ctrl+R"
    $m add cascade -label [::msgcat::mc "Encode"] -menu $m.encode -font $fontNormal
    set me [menu $m.encode  -bg $editor(bg) -fg $editor(fg)]
    $me add command -label [::msgcat::mc "KOI8-R"] -command {TextEncode koi8-r} -font $fontNormal
    $me add command -label [::msgcat::mc "CP1251"] -command {TextEncode cp1251} -font $fontNormal
    $me add command -label [::msgcat::mc "CP866"] -command {TextEncode cp866} -font $fontNormal
}

proc GetViewMenu {m} {
    global fontNormal fontBold imgDir editor
    $m add checkbutton -label [::msgcat::mc "Show the Menu"] -font $fontNormal -state normal\
    -offvalue "No" -onvalue "Yes" -variable showMenu -command {ToolBar}
    $m add checkbutton -label [::msgcat::mc "Toolbar"] -font $fontNormal -state normal\
    -offvalue "No" -onvalue "Yes" -variable toolBar -command {ToolBar}
    $m add command -label [::msgcat::mc "Split edit window"] -font $fontNormal -accelerator "F4" -state disable\
    -command SplitWindow
    $m add separator
    $m add command -label [::msgcat::mc "Refresh"] -font $fontNormal -accelerator "F5" -state normal\
    -command UpdateTree    
}

proc GetModulesMenu {m} {
    global fontNormal fontBold imgDir editor module activeProject
    if {[info exists module(tkcvs)]} {
        $m add command -label "TkCVS" -command {DoModule tkcvs} -font $fontNormal
    }
    if {[info exists module(tkdiff)]} {
        $m add command -label "TkDIFF+" -command {DoModule tkdiff} -font $fontNormal
    }
    if {[info exists module(tkregexp)]} {
        $m add command -label "TkREGEXP" -command {DoModule tkregexp} -font $fontNormal
    }
    if {[info exists module(gitk)]} {
        $m add command -label "Gitk" -font $fontNormal -command {
            DoModule gitk
            GetTagList [file join $workDir $activeProject.tags] ;# geting tag list
        }
    }
}

proc GetHelpMenu {m} {
    global fontNormal fontBold imgDir editor
    $m  add  command  -label [::msgcat::mc "Help"]  -command  ShowHelp \
    -accelerator F1 -font $fontNormal
    $m add command -label [::msgcat::mc "About ..."] -command AboutDialog \
    -font $fontNormal
}
proc GetFileMenu {m} {
    global fontNormal fontBold imgDir editor noteBookFiles noteBook
    $m add cascade -label [::msgcat::mc "New"] -menu $m.new -font $fontNormal
    set mn [menu $m.new  -bg $editor(bg) -fg $editor(fg)]
    $mn add command -label [::msgcat::mc "New file"] -command {AddToProjDialog file [$noteBookFiles raise]}\
    -font $fontNormal -accelerator "Ctrl+N"
    $mn add command -label [::msgcat::mc "New directory"] -command {AddToProjDialog directory [$noteBookFiles raise]}\
    -font $fontNormal -accelerator "Ctrl+N"
    $mn add command -label [::msgcat::mc "New project"] -command {NewProjDialog "new"}\
    -font $fontNormal
    #$m add command -label [::msgcat::mc "Open"] -command {FileDialog $tree open}\
    #-font $fontNormal -accelerator "Ctrl+O"        -state disable
    $m add command -label [::msgcat::mc "Save"] -command {FileDialog [$noteBookFiles raise] save}\
    -font $fontNormal -accelerator "Ctrl+S"
    $m add command -label [::msgcat::mc "Save as"] -command {FileDialog [$noteBookFiles raise] save_as}\
    -font $fontNormal
    $m add command -label [::msgcat::mc "Save all"] -command {FileDialog [$noteBookFiles raise] save_all}\
    -font $fontNormal
    $m add command -label [::msgcat::mc "Close"] -command {FileDialog [$noteBookFiles raise] close}\
    -font $fontNormal -accelerator "Ctrl+W"
    $m add command -label [::msgcat::mc "Close all"] -command {FileDialog [$noteBookFiles raise] close_all}\
    -font $fontNormal
    $m add command -label [::msgcat::mc "Delete"] -command {FileDialog [$noteBookFiles raise] delete}\
    -font $fontNormal -accelerator "Ctrl+D"
    $m add separator
    $m add command -label [::msgcat::mc "Compile file"] -command {MakeProj compile file} -font $fontNormal -accelerator "Ctrl+F8"
    $m add command -label [::msgcat::mc "Run file"] -command {MakeProj run file} -font $fontNormal -accelerator "Ctrl+F9"
    $m add separator
    $m add command -label [::msgcat::mc "Print"] -command PrintDialog\
    -font $fontNormal -accelerator "Ctrl+P"
    $m add separator
    $m add command -label [::msgcat::mc "Settings"] -command {Settings $noteBook} -font $fontNormal
    $m add separator
    $m add command -label [::msgcat::mc "Exit"] -command Quit -font $fontNormal -accelerator "Ctrl+Q"
}


