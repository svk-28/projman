###########################################################
#                Tcl/Tk project Manager                   #
#        Distributed under GNU Public License             # 
# Author: Sergey Kalinin banzaj28@yandex.ru               #
# Copyright (c) "Sergey Kalinin", 2002, http://nuk-svk.ru #
###########################################################
## ADD FILE INTO PROJECTS ##
proc AddToProj {fileName mode} {
    global projDir workDir activeProject tree noteBook fontNormal imgDir tree
    set type [string trim [file extension $fileName] {.}]
    destroy .addtoproj
    
    set node [$tree selection get]
    set fullPath [$tree itemcget $node -data]
    
    if {[file isdirectory $fullPath] == 1} {
        set dir $fullPath
        set parentNode $node
    } else {
        set dir [file dirname $fullPath]
        set parentNode [$tree parent $node]
    }
    
    if {$type == "tcl"} {
        set img "tcl"
    } elseif {$type == "tk"} {
        set img "tk"
    } elseif {$type == "txt"} {
        set img "file"
    } elseif {$type == "html"} {
        set img "html"
    } elseif {$type == "java"} {
        set img "java"
    } elseif {$type == "pl" || $type == "perl"} {
        set img "perl"
    } elseif {$type == "for"} {
        set img "fortran"
    } elseif {$type == "ml" || $type == "mli"} {
        set img "caml"
    } elseif {$type == "php" || $type == "phtml"} {
        set img "php"
    } elseif {$type == "rb"} {
        set img "ruby"
    } elseif {$type == "rb"} {
        set img "erl"
    } else {
        set img "file"
    }
    if {$mode == "directory"} {
        set img "folder"
    }
    #set dir [file join $projDir $activeProject]
    set dot "_"
    set name [file rootname $fileName]
    set ext [string range [file extension $fileName] 1 end]
    set subNode "$name$dot$ext"
    $tree insert end $parentNode $subNode -text $fileName \
    -data [file join $dir $fileName] -open 1\
    -image [Bitmap::get [file join $imgDir $img.gif]]\
    -font $fontNormal
    if {[$tree itemcget $activeProject -open] == 0} {
        $tree itemconfigure $activeProject -open 1
    }
    set file [file join $dir $fileName]
    
    if {$mode == "directory"} {
        file mkdir $file
        return
    }
    InsertTitle $file $type
    EditFile [GetTreeForNode $subNode] $subNode [file join $dir $fileName]
}
## ADD FILE INTO PROJECT DIALOG##
proc AddToProjDialog {mode} {
    global projDir workDir activeProject imgDir tree mod
    set mod $mode
    if {$activeProject == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning]
        case $answer {
            ok {return 0}
        }
    }
    
    set w .addtoproj
    if {[winfo exists $w]} {
        destroy $w
    }
    # create the new "goto" window
    toplevel $w
    wm title $w [::msgcat::mc "Create new $mod"]
    wm resizable $w 0 0
    wm transient $w .
    
    frame $w.frmCanv -border 1 -relief sunken
    frame $w.frmBtn -border 1 -relief sunken
    pack $w.frmCanv -side top -fill both -padx 1 -pady 1
    pack $w.frmBtn -side top -fill x
    
    label $w.frmCanv.lblImgTcl -text [::msgcat::mc "Input $mod name"]
    entry $w.frmCanv.entImgTcl
    pack $w.frmCanv.lblImgTcl $w.frmCanv.entImgTcl -expand true -padx 5 -pady 5 -side top
    
    button $w.frmBtn.btnOk -text [::msgcat::mc "Create"] -relief groove -command {
        AddToProj [.addtoproj.frmCanv.entImgTcl get] $mod
    }
    button $w.frmBtn.btnCancel -text [::msgcat::mc "Close"] -command "destroy $w" -relief groove
    pack $w.frmBtn.btnOk $w.frmBtn.btnCancel -padx 2 -pady 2 -fill x -side left
    
    bind $w <Escape> "destroy .addtoproj"
    bind $w.frmCanv.entImgTcl <Return> {
        AddToProj [.addtoproj.frmCanv.entImgTcl get] $mod
    }
    focus -force $w.frmCanv.entImgTcl
    #unset type
}
proc AddToProjDialog_ {} {
    global projDir workDir activeProject imgDir tree
    if {$activeProject == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning]
        case $answer {
            ok {return 0}
        }
    }
    
    set w .addtoproj
    if {[winfo exists $w]} {
        destroy $w
    }
    # create the new "goto" window
    toplevel $w
    wm title $w [::msgcat::mc "Create new file"]
    wm resizable $w 0 0
    wm transient $w .
    
    frame $w.frmCanv -border 1 -relief sunken
    frame $w.frmBtn -border 1 -relief sunken
    pack $w.frmCanv -side top -fill both -padx 1 -pady 1
    pack $w.frmBtn -side top -fill x
    
    label $w.frmCanv.lblImgTcl -text [::msgcat::mc "Input file name"]
    entry $w.frmCanv.entImgTcl
    pack $w.frmCanv.lblImgTcl $w.frmCanv.entImgTcl -expand true -padx 5 -pady 5 -side top
    
    button $w.frmBtn.btnOk -text [::msgcat::mc "Create"] -relief groove -command {
        AddToProj [.addtoproj.frmCanv.entImgTcl get]
    }
    button $w.frmBtn.btnCancel -text [::msgcat::mc "Close"] -command "destroy $w" -relief groove
    pack $w.frmBtn.btnOk $w.frmBtn.btnCancel -padx 2 -pady 2 -fill x -side left
    
    bind $w <Escape> "destroy .addtoproj"
    bind $w.frmCanv.entImgTcl <Return> {
        AddToProj [.addtoproj.frmCanv.entImgTcl get]
    }
    focus -force $w.frmCanv.entImgTcl
    
}
## DELETE FILE FROM PROJECT ##
proc DelFromProj {project} {
    global projDir workDir
    
}
## DELETEING PROJECT PROCEDURE ##
proc DelProj {} {
    global workDir activeProject tree
    if {$activeProject == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning]
        case $answer {
            ok {return 0}
        }
    }
    set file [open [file join $workDir $activeProject.proj] r]
    while {[gets $file line]>=0} {
        scan $line "%s" keyWord
        set string [string range $line [string first "\"" $line] [string last "\"" $line]]
        set string [string trim $string "\""]
        if {$keyWord == "ProjectDirName"} {
            set projDir "$string"
            puts $projDir
        }  
    }
    close $file
    
    set answer [tk_messageBox -message "[::msgcat::mc "Delete project"] \"$activeProject\" ?"\
    -type yesno -icon question -default yes]
    case $answer {
        yes {
            FileDialog $tree close_all
            file delete -force $projDir
            file delete -force [file join $workDir $activeProject.proj]
            file delete -force [file join $workDir $activeProject.tags]
            $tree delete [$tree selection get]
            $tree configure -redraw 1
            set activeProject ""
            LabelUpdate .frmStatus.frmActive.lblActive ""
        }
    }
}

proc CompileOption {string} {
    global fontNormal cmdCompile editor
    set w .cmd
    # destroy the find window if it already exists
    if {[winfo exists $w]} {
        destroy $w
    }
    
    toplevel $w
    wm title $w [::msgcat::mc "Command options"]
    wm resizable $w 0 0
    wm transient $w .
    frame $w.frmCombo -borderwidth 1 -bg $editor(bg)
    frame $w.frmBtn -borderwidth 1 -bg $editor(bg)
    pack $w.frmCombo $w.frmBtn -side top -fill x
    
    #    set combo [entry $w.frmCombo.entFind]
    label $w.frmCombo.lblModule -text "[::msgcat::mc "Convert to"]" -bg $editor(bg) -fg $editor(fg)
    label $w.frmCombo.lblFile -text "[::msgcat::mc "File"]" -bg $editor(bg) -fg $editor(fg)
    set combo [entry $w.frmCombo.txtString -text "$string"]
    
    pack $w.frmCombo.lblModule $w.frmCombo.lblFile $combo -fill x -padx 2 -pady 2 -side top
    
    button $w.frmBtn.btnFind -text [::msgcat::mc "Run"]\
    -font $fontNormal -width 12 -relief groove -bg $editor(bg) -fg $editor(fg)\
    -command {
        return [.cmd.frmCombo.txtString get]
        destroy .cmd
    }
    button $w.frmBtn.btnCancel -text [::msgcat::mc "Close"] -bg $editor(bg) -fg $editor(fg)\
    -relief groove -width 12 -font $fontNormal\
    -command "destroy $w"
    pack $w.frmBtn.btnFind $w.frmBtn.btnCancel -fill x -padx 2 -pady 2 -side left
    
    bind $w <Return> {
        set cmdCompile [.cmd.frmCombo.txtString get]
        destroy .cmd
    }
    bind $w <Escape> "destroy $w"
    $combo insert end "$string"
    focus -force $combo
}

## MAKE PROJ PROCEDURE (RUNNING PROJECT) ##
proc MakeProj {action t} {
    global activeProject projDir noteBook fontNormal fontBold workDir tree cmdCompile editor
    if {$activeProject == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning\
        -title [::msgcat::mc "Warning"]]
        case $answer {
            ok {return 0}
        }
    }
    FileDialog $tree save_all
    set file [open [file join $workDir $activeProject.proj] r]
    while {[gets $file line]>=0} {
        scan $line "%s" keyWord
        set string [string range $line [string first "\"" $line] [string last "\"" $line]]
        set string [string trim $string "\""]
        if {$keyWord == "ProjectName"} {
            set projName "$string"
        }
        if {$keyWord == "ProjectFileName"} {
            set projFileName "$string"
        }
        if {$keyWord == "ProjectDirName"} {
            set projDirName "$string"
        }  
        if {$keyWord == "ProjectCompiler"} {
            set projCompiler "$string"
        }  
        if {$keyWord == "ProjectInterp"} {
            set projInterp "$string"
        }  
    }
    close $file
    if {$action == "compile"} {
        if {$t == "proj"} {
            set prog [file join $projDirName $projFileName.java]
        } elseif {$t == "file"} {
            set node [$tree selection get]
            set fullPath [$tree itemcget $node -data]
            set dir [file dirname $fullPath]
            set file [file tail $fullPath]
            set prog $fullPath
        }
    } elseif {$action == "run"} {
        if {$t == "proj"} {
            set prog [file join $projDirName $projFileName]
        } elseif {$t == "file"} {
            set node [$tree selection get]
            set fullPath [$tree itemcget $node -data]
            set dir [file dirname $fullPath]
            set file [file tail $fullPath]
            set prog $fullPath
        }
    }
    
    set node "debug"
    if {[$noteBook index $node] != -1} {
        $noteBook delete debug
    }
    set w [$noteBook insert end $node -text [::msgcat::mc "Running project"]]
    # create array with file names #
    frame $w.frame -borderwidth 2 -relief ridge -background $editor(bg)
    pack $w.frame -side top -fill both -expand true
    
    
    text $w.frame.text -yscrollcommand "$w.frame.yscroll set" \
    -bg $editor(bg) -fg $editor(fg) \
    -relief sunken -wrap word -highlightthickness 0 -font $fontNormal\
    -selectborderwidth 0 -selectbackground #55c4d1 -width 10 -height 10
    scrollbar $w.frame.yscroll -relief sunken -borderwidth {1} -width {10} -takefocus 0 \
    -command "$w.frame.text yview" -background $editor(bg)
    
    pack $w.frame.text -side left -fill both -expand true
    pack $w.frame.yscroll -side left -fill y 
    
    frame $w.frmBtn -borderwidth 2 -relief ridge -bg $editor(bg)
    pack $w.frmBtn -side top -fill x
    button $w.frmBtn.btnOk -text [::msgcat::mc "Close"] -borderwidth {1} \
    -bg $editor(bg) -fg $editor(fg) -command {
        $noteBook delete debug
        $noteBook  raise [$noteBook page end]
        return 0
    }
    pack $w.frmBtn.btnOk -pady 2
    # key bindings #
    bind $w.frmBtn.btnOk <Escape> {
        $noteBook delete debug
        $noteBook  raise [$noteBook page end]
        #        return 0
    }
    bind $w.frmBtn.btnOk <Return> {
        $noteBook delete debug
        $noteBook  raise [$noteBook page end]
        #        return 0
    }
    focus -force $w.frmBtn.btnOk
    $noteBook raise $node
    # insert debug data into text widget #
    $w.frame.text tag configure bold -font $fontBold
    $w.frame.text tag configure error -font $fontNormal -foreground red
    $w.frame.text tag add bold 0.0 0.end
    if {$action == "compile"} {
        $w.frame.text insert end "[::msgcat::mc "Compile project"] - $activeProject\n"
        $w.frame.text insert end "[::msgcat::mc "Compile"] - $prog\n\n"
    } elseif {$action == "run"} {
        $w.frame.text insert end "[::msgcat::mc "Running project"] - $activeProject\n"
        $w.frame.text insert end "[::msgcat::mc "Run"] - $prog\n\n"
    }
    set pos [$w.frame.text index insert]
    set lineNum [lindex [split $pos "."] 0]
    $w.frame.text insert end "----------------- [::msgcat::mc "Programm output"] -----------------\n"
    $w.frame.text tag add bold $lineNum.0 $lineNum.end
    
    # open and manipulate executed program chanel #
    if {$action == "compile"} {
        set cmdCompile ""
        CompileOption "$projCompiler $prog"
        vwait cmdCompile
        puts "string - $projCompiler $prog" ;# debug info
        set pipe [open "|$cmdCompile 2> [file join $projDirName errors]" "r"]
        set f [open [file join $projDirName errors] "r"]
    } elseif {$action == "run"} {
        set pipe [open "|$projInterp $prog 2> [file join $projDirName errors]" "r"]
        set f [open [file join $projDirName errors] "r"]
    }
    
    fileevent $pipe readable [list DebugInfo $w.frame.text $pipe $f]
    fconfigure $pipe -buffering none -blocking no
}
## INSERT DEBUG INFORMATION INTO TEXT WIDGET ##
proc DebugInfo {widget file f} {
    $widget configure -state normal
    if {[eof $file]} {
        catch [close $file] msg
        if {$msg != ""} {
            puts $msg
            $widget insert end "[::msgcat::mc "Program failed"]: $msg\n";
        } else {
            puts $msg
            $widget insert end "\n-------------------------------------------------\n"
            $widget insert end "[::msgcat::mc "Program finished successfully"]\n"
        }
    } else {
        $widget insert end [read $file]
    }
    while {[gets $f line]>=0} {
        $widget insert end "$line\n"
        puts $line
    }
    $widget see end
    $widget tag add error 0.0 0.end
    $widget configure -state disabled
}
## INSERT TITLE INTO NEW FILE ##
proc InsertTitle {newFile type} {
    global activeProject projDir workDir ver
    puts "$newFile $type"
    set year [clock format [clock scan "now" -base [clock seconds]] -format %Y]
    if {$activeProject == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning\
        -title [::msgcat::mc "Warning"]]
        case $answer {
            ok {return 0}
        }
    }
    set file [open [file join $workDir $activeProject.proj] r]
    while {[gets $file line]>=0} {
        scan $line "%s" keyWord
        set string [string range $line [string first "\"" $line] [string last "\"" $line]]
        set string [string trim $string "\""]
        if {$keyWord == "ProjectName"} {
            set txtProjName "$string"
        }
        if {$keyWord == "ProjectFileName"} {
            set txtProjFileName "$string"
        }
        if {$keyWord == "ProjectDirName"} {
            set txtProjDirName "$string"
        }  
        if {$keyWord == "ProjectInterp"} {
            set txtProjInterp "$string"
        }  
        if {$keyWord == "ProjectVersion"} {
            set txtProjVersion "$string"
        }  
        if {$keyWord == "ProjectRelease"} {
            set txtProjRelease "$string"
        }  
        if {$keyWord == "ProjectAuthor"} {
            set txtProjAuthor "$string"
        }  
        if {$keyWord == "ProjectEmail"} {
            set txtProjEmail "$string"
        }  
        if {$keyWord == "ProjectCompany"} {
            set txtProjCompany "$string"
        }  
        if {$keyWord == "ProjectHome"} {
            set txtProjHome "$string"
        }  
    }
    if {$type == "html"} {
        set fileTitle "<HTML>\n<HEAD>\n<META http-equiv=Content-Type content=\"text/html; charset=koi8-r\">\n<META NAME=\"Author\" CONTENT=\"$txtProjAuthor\">\n<META NAME=\"GENERATOR\" CONTENT=\"Created by Tcl/Tk Project Manager - $ver\">\n<TITLE></TITLE>\n</HEAD>\n<BODY>\n\n</BODY>\n</HTML>"
    } elseif {$type == "tcl"} {
        set fileTitle "#!$txtProjInterp\n######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } elseif {$type == "perl" || $type == "pl"} {
        set fileTitle "######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } elseif {$type == "txt"} {
        set fileTitle "#######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } elseif {$type == "rb"} {
        set fileTitle "#!$txtProjInterp\n######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } elseif {$type == "java"} {
        set fileTitle "/*\n*****************************************************\n*\t$txtProjName\n*\tDistributed under GNU Public License\n* Author: $txtProjAuthor $txtProjEmail\n* Home page: $txtProjHome\n*****************************************************\n*/\n"
    } elseif {$type == "for"} {
        set fileTitle "*****************************************************\n*\t$txtProjName\n*\tDistributed under GNU Public License\n* Author: $txtProjAuthor $txtProjEmail\n* Home page: $txtProjHome\n*****************************************************\n"
    } elseif {$type == "ml" || $type == "mli"} {
        set fileTitle "\(*****************************************************\n*\t$txtProjName\n*\tDistributed under GNU Public License\n* Author: $txtProjAuthor $txtProjEmail\n* Home page: $txtProjHome\n*****************************************************\)\n"
    } elseif {$type == "php" || $type == "phtml"} {
        set fileTitle "<?\n////////////////////////////////////////////////////////////\n//\t$txtProjName\n//\tDistributed under GNU Public License\n// Author: $txtProjAuthor $txtProjEmail\n// Home page: $txtProjHome\n////////////////////////////////////////////////////////////\n\n\n\n\n?>"
    } elseif {$type == "tml"} {
        set fileTitle "<!--\n######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n-->\n"
    } elseif {$type == "erl"} {
        set fileTitle "%*****************************************************\n%\t$txtProjName\n%\tDistributed under GNU Public License\n% Author: $txtProjAuthor $txtProjEmail\n% Home page: $txtProjHome\n%****************************************************\n"
    } else {
        set fileTitle "######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } 
    set pipe [open $newFile w]
    #   puts "$newFile\n $fileTitle" ;# debuf info
    puts $pipe $fileTitle
    close $pipe
}




















