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


