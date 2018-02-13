###########################################################
#                Tcl/Tk Project Manager                   #
#                 Distributed under GPL                   #
#                  all procedure file                     #
# Copyright (c) "Sergey Kalinin", 2001, http://nuk-svk.ru  #
# Author: Sergey Kalinin banzaj28@yandex.ru       #
###########################################################

## INSERT TEXT INTO ENTRY BOmX ##
proc InsertEnt {entry text} {
    $entry delete 0 end
    $entry insert end $text
}

## GET TEXT FROM ENTRY WIDGET ##
proc Text {entry} {
    set text [$entry get]
}
## FONT SELECTOR DIALOG ##
proc SelectFontDlg {font text} {
    set font [SelectFont .fontdlg -parent . -font $font]
    if { $font != "" } {
        InsertEnt $text $font
    }
}
## STATUS BAR OR ANYTHING LABEL TEXT UPDATE ##
proc LabelUpdate {widget value} {
    global fontNormal
    $widget configure -text $value -font $fontNormal
}
proc PopupMenuEditor {x y} {
    tk_popup .popMnuEdit $x $y
}
## GETTING FILE ATTRIBUTES ##
proc FileAttr {file} {
    global tcl_platform
    set fileAttribute ""
    # get file modify time
    if {$tcl_platform(platform) == "windows"} {
        set unixTime [file mtime $file]
        set modifyTime [clock format $unixTime -format "%d/%m/%Y, %H:%M"]
        append fileAttribute $modifyTime
    } elseif {$tcl_platform(platform) == "mac"} {
        
    } elseif {$tcl_platform(platform) == "unix"} {
        set unixTime [file mtime $file]
        set modifyTime [clock format $unixTime -format "%d/%m/%Y, %H:%M"]
        append fileAttribute $modifyTime
    }
    # get file size
    set size [file size $file]
    if {$size < 1024} {
        set fileSize "$size b"
    }
    if {$size >= 1024} {
        set s [expr ($size.0) / 1024]
        set dot [string first "\." $s]
        set int [string range $s 0 [expr $dot - 1]]
        set dec [string range $s [expr $dot + 1] [expr $dot + 2]]
        set fileSize "$int.$dec Kb"
    }
    if {$size >= 1048576} {
        set s [expr ($size.0) / 1048576]
        set dot [string first "\." $s]
        set int [string range $s 0 [expr $dot - 1]]
        set dec [string range $s [expr $dot + 1] [expr $dot + 2]]
        set fileSize "$int.$dec Mb"
    }
    append fileAttribute ", $fileSize"
}

## ABOUT PROGRAMM DIALOG ##
proc AboutDialog {} {
    global docDir imgDir tree noteBook ver fontNormal dataDir env editor
    set w {}
    # prevent double creation "About" page
    if { [catch {set w [$noteBook insert end about -text [::msgcat::mc "About ..."]]} ] } {
        $noteBook raise about
        return
    }
    frame $w.frmImg -borderwidth 2 -relief ridge -background white
    image create photo imgLogo -format png -file [file join $imgDir projman.png]
    #    image create photo imgAbout -format png -file [file join $imgDir icons large projman.png]
    label $w.frmImg.lblImgLogo -image imgLogo -border 0
    #label $w.frmImg.lblImg -image imgAbout
    pack $w.frmImg.lblImgLogo -side top -pady 5 -padx 5
    
    frame $w.frmlbl -borderwidth 2 -relief ridge
    label $w.frmlbl.lblVersion -text "[::msgcat::mc Version] $ver"
    label $w.frmlbl.lblCompany -text "License: GPL"
    label $w.frmlbl.lblAuthorName -text "[::msgcat::mc Author]: Sergey Kalinin"
    label $w.frmlbl.lblEmail -text "[::msgcat::mc E-mail]: banzaj28@yandex.ru"
    label $w.frmlbl.lblWWWhome -text "[::msgcat::mc "Home page"]: https://nuk-svk.ru"
    label $w.frmlbl.lblWWWgit -text "Git repository: https://bitbucket.org/svk28/projman"
    
    pack $w.frmlbl.lblVersion $w.frmlbl.lblCompany $w.frmlbl.lblAuthorName \
    $w.frmlbl.lblEmail $w.frmlbl.lblWWWhome $w.frmlbl.lblWWWgit -side top -padx 5
    frame $w.frmThanks -borderwidth 2 -relief ridge
    label $w.frmThanks.lblThanks -text "[::msgcat::mc Thanks]" -font $fontNormal
    text $w.frmThanks.txtThanks -width 10 -height 10 -font $fontNormal\
    -selectborderwidth 0 -selectbackground #55c4d1 -width 10
    pack $w.frmThanks.lblThanks -pady 5
    pack $w.frmThanks.txtThanks -fill both -expand true
    
    frame $w.frmBtn -borderwidth 2 -relief ridge
    button $w.frmBtn.btnOk -text [::msgcat::mc "Close"] -borderwidth {1} \
    -command {
        $noteBook delete about
        $noteBook  raise [$noteBook page end]
    }
    pack $w.frmBtn.btnOk -pady 2
    pack $w.frmImg -side top -fill x
    pack $w.frmlbl  -side top -expand true -fill both
    pack $w.frmThanks  -side top -expand true -fill both
    pack $w.frmBtn -side top -fill x
    
    bind $w <KeyRelease-Return> "$noteBook  delete about"
    bind $w <Escape>  "$noteBook  delete about"
    bind $w <Return> {$noteBook  delete about}
    #
    bind $w.frmlbl.lblWWWhome <Enter> {
        .frmBody.frmWork.noteBook.fabout.frmlbl.lblWWWhome configure -fg blue -cursor hand1
        LabelUpdate .frmStatus.frmHelp.lblHelp "Goto https://nuk-svk.ru"
    }
    bind $w.frmlbl.lblWWWhome <Leave> {
        .frmBody.frmWork.noteBook.fabout.frmlbl.lblWWWhome configure -fg $editor(fg)
        LabelUpdate .frmStatus.frmHelp.lblHelp ""
    }
    bind $w.frmlbl.lblWWWhome <ButtonRelease-1> {GoToURL "https://nuk-svk.ru"}
    bind $w.frmlbl.lblWWWgit <Enter> {
        .frmBody.frmWork.noteBook.fabout.frmlbl.lblWWWgit configure -fg blue -cursor hand1
        LabelUpdate .frmStatus.frmHelp.lblHelp "Goto https://bitbucket.org/svk28/projman"
    }
    bind $w.frmlbl.lblWWWgit <Leave> {
        .frmBody.frmWork.noteBook.fabout.frmlbl.lblWWWgit configure -fg $editor(fg)
        LabelUpdate .frmStatus.frmHelp.lblHelp ""
    }
    bind $w.frmlbl.lblWWWgit <ButtonRelease-1> {GoToURL "https://bitbucket.org/svk28/projman"}
    #
    bind $w.frmlbl.lblEmail <Enter> {
        .frmBody.frmWork.noteBook.fabout.frmlbl.lblEmail configure -fg blue -cursor hand1
        LabelUpdate .frmStatus.frmHelp.lblHelp "Send email \"banzaj28@yandex.ru\""
    }
    bind $w.frmlbl.lblEmail <Leave> {
        .frmBody.frmWork.noteBook.fabout.frmlbl.lblEmail configure -fg $editor(fg)
        LabelUpdate .frmStatus.frmHelp.lblHelp ""
    }
    bind $w.frmlbl.lblEmail <ButtonRelease-1> {SendEmail "banzaj28@yandex.ru"}
    
    
    $noteBook  raise about
    focus $w.frmBtn.btnOk
    if {[file exists $env(HOME)/projects/tcl/projman]==1} {
        set file [open [file join $env(HOME)/projects/tcl/projman THANKS] r]
    } else {
        set file [open [file join $docDir THANKS] r]
    }
    while {[gets $file line]>=0} {
        $w.frmThanks.txtThanks insert end "$line\n"
    }
    close $file
    $w.frmThanks.txtThanks configure -state disable
}
## CLOSE FILE ##
proc CloseFile {} {
    global docDir imgDir tree noteBook ver fontNormal node
    set w [$noteBook itemcget page option insert end settings -text [::msgcat::mc "Settings"]]
    
    $noteBook  raise settings
}
## GET LOCALE NAMES FROM MESSAGES FILE ##
proc GetLocale {} {
    global msgDir localeList
    set localeList ""
    if {[catch {cd $msgDir}] != 0} {
        return ""
    }
    foreach file [lsort [glob -nocomplain *.msg]] {
        lappend localeList [list [file rootname $file]]
    }
    return $localeList
}
## MAKING TAR ARCHIVE ##
proc MakeTGZ {} {
    global activeProject tgzDir tgzNamed workDir projDir env tcl_platform
    if {$activeProject == ""} {
        set answer [tk_messageBox\
                -message [::msgcat::mc "Not found active project"]\
                -type ok -icon warning\
                -title [::msgcat::mc "Warning"]]
        case $answer {
            ok {return 0}
        }
    }
    FileDialog tree save_all
    set file [open [file join $workDir $activeProject.proj] r]
    while {[gets $file line]>=0} {
        scan $line "%s" keyWord
        set string [string range $line [string first "\"" $line] [string last "\"" $line]]
        set string [string trim $string "\""]
        if {$keyWord == "ProjectDirName"} {
            set dir "$string"
        }  
        if {$keyWord == "ProjectVersion"} {
            set version "$string"
        }  
        if {$keyWord == "ProjectRelease"} {
            set release "$string"
        }  
    }
    close $file
    set res [split $tgzNamed "-"]
    set name [lindex $res 0]
    set ver [lindex $res 1]
    set rel [lindex $res 2]
    if {$name == "projectName"} {
        set name $activeProject
    }
    if {$ver == "version"} {
        append name "-$version"
    }
    if {$rel == "release"} {
        append name "-$release"
    }
    # multiplatform featuring #
    if {$tcl_platform(platform) == "windows"} {
        append name ".zip"
    } elseif {$tcl_platform(platform) == "mac"} {
        append name ".zip"
    } elseif {$tcl_platform(platform) == "unix"} {
        append name ".tar.gz"
    }
    catch {cd $projDir} res
    if {[file exists [file join $tgzDir $name]] == 1} {
        set answer [tk_messageBox\
                -message "[::msgcat::mc "File already exists. Overwrite?"] \"$name\" ?"\
                -type yesno -icon question -default yes\
                -title [::msgcat::mc "Question"]]
        case $answer {
            yes {file delete [file join $tgzDir $name]}
            no {return 0}
        }
    }
    # multiplatform featuring #
    if {$tcl_platform(platform) == "windows"} {
        catch [exec pkzip -r -p [file join $tgzDir $name] [file join $activeProject *]] err
    } elseif {$tcl_platform(platform) == "mac"} {
        catch [exec zip -c [file join $tgzDir $name] $activeProject] err
    } elseif {$tcl_platform(platform) == "unix"} {
        catch [exec tar -czvf [file join $tgzDir $name] $activeProject] err
    }
    # message dialog #
    set msg "[::msgcat::mc "Archive created in"] [file join $tgzDir $name]"
    set icon info
    set answer [tk_messageBox\
            -message "$msg"\
            -type ok -icon $icon]
            case $answer {
        ok {return 0}
    }
}

## MAKING RPM ##
proc MakeRPM {} {
    global activeProject tgzDir tgzNamed workDir projDir env tcl_platform

    set answer [tk_messageBox\
            -message "[::msgcat::mc "Not implemented yet"]"\
            -type ok -icon info]
    case $answer {
        ok {return 0}
    }


    if {$activeProject == ""} {
        set answer [tk_messageBox\
                -message "[::msgcat::mc "Not found active project"]"\
                -type ok -icon warning -title [::msgcat::mc "Warning"]]
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
            set dir "$string"
        }  
        if {$keyWord == "ProjectVersion"} {
            set version "$string"
        }  
        if {$keyWord == "ProjectRelease"} {
            set release "$string"
        }  
    }
    close $file
    set res [split $tgzNamed "-"]
    set name [lindex $res 0]
    set ver [lindex $res 1]
    set rel [lindex $res 2]
    if {$name == "projectName"} {
        set name $activeProject
    }
    if {$ver == "version"} {
        append name "-$version"
    }
    if {$rel == "release"} {
        append name "-$release"
    }
    append name ".tar.gz"
    catch {cd $projDir} res
    if {[file exists $tgzDir/$name] == 1} {
        set answer [tk_messageBox\
                -message "[::msgcat::mc "File already exists. Overwrite?"] \"$name\" ?"\
                -type yesno -icon question -default yes]
        case $answer {
            yes {file delete $tgzDir/$name}
            no {return 0}
        }
    }
    catch [exec tar -czvf $tgzDir/$name $activeProject] pipe
}

## PROGRESS DIALOG ##
proc Progress {oper} {
    global progval
    if {$oper == "start"} {
        set prg [ProgressBar .frmStatus.frmProgress.lblProgress.progress\
                -variable progval -type infinite -borderwidth 0]
        pack $prg -side left -fill both -expand true
    } elseif {$oper == "stop"} {
        destroy .frmStatus.frmProgress.lblProgress.progress
    }
    #    ProgUpdate
}
proc ProgUpdate { } {
    global progval
    set progval 5
}

## SHOW HELP WINDOW ##
proc ShowHelp {} {
    global dataDir
    if {[winfo exists .help] == 1} {
        focus -force .help
        raise .help
    } else {
        TopLevelHelp
    }
    if {[catch {set word [selection get]} error] != 0} {
        set word " "
    } else {
        puts $word
        TopLevelHelp
        SearchWord $word
    }
}

## EXEC EXTERNAL BROWSER AND GOTO URL ##
proc GoToURL {url} {
    global env tcl_platform
    if {$tcl_platform(platform) == "windows"} {
        set pipe [open "|iexplore $url" "r"]
    } elseif {$tcl_platform(platform) == "mac"} {
        set pipe [open "|iexplore $url" "r"]
    } elseif {$tcl_platform(platform) == "unix"} {
        #$env(BROWSER)
        #set pipe [open "|$env(BROWSER) $url" "r"]
        launchBrowser $url
        return
    }
    fileevent $pipe readable
    fconfigure $pipe -buffering none -blocking no
}

proc launchBrowser {url} {
    global tcl_platform
    if {$tcl_platform(platform) eq "windows"} {
        set command [list {*}[auto_execok start] {}]
        if {[file isdirectory $url]} {
            set url [file nativename [file join $url .]]
        }
    } elseif {$tcl_platform(os) eq "Darwin"} {
        set command [list open]
    } else {
        set command [list xdg-open]
    }
    exec {*}$command $url &
}

## SEND EMAIL PROCEDURE ##
proc SendEmail {mail} {
    global env tcl_platform
    if {$tcl_platform(platform) == "windows"} {
    } elseif {$tcl_platform(platform) == "mac"} {
    } elseif {$tcl_platform(platform) == "unix"} {
        set pipe [open "|xdg-open $mail" "r"]
        fileevent $pipe readable
        fconfigure $pipe -buffering none -blocking no
    }
}
## QUIT PROJECT MANAGER PROCEDURE ##
proc Quit {} {
    set v [FileDialog tree close_all]
    if {$v == "cancel"} {
        return
    } else {
        exit
    }
}
## PRINT DIALOG ##
proc PrintDialog {} {
    global fontNormal fontBold selectPrint
    set wp .print
    # destroy the print window if it already exists
    if {[winfo exists $wp]} {
        destroy $wp
    }
    # create the new "find" window
    toplevel $wp
    wm transient $wp .
    wm title $wp [::msgcat::mc "Print ..."]
    wm resizable $wp 0 0
    frame $wp.frmLbl
    frame $wp.frmEnt
    frame $wp.frmField
    frame $wp.frmBtn
    pack $wp.frmLbl $wp.frmEnt $wp.frmField $wp.frmBtn -side top -fill x
    label $wp.frmLbl.lblPrint -text [::msgcat::mc "Print command"] -font $fontNormal
    pack $wp.frmLbl.lblPrint -fill x -expand true -padx 2
    entry $wp.frmEnt.entPrint -font $fontNormal
    pack $wp.frmEnt.entPrint -fill x -expand true -padx 2
    
    checkbutton $wp.frmField.chkSelect -text [::msgcat::mc "Print selected text"] -variable selectPrint\
    -font $fontNormal -onvalue true -offvalue false ;#-command Check
    pack $wp.frmField.chkSelect -fill x -expand true -padx 2
    
    button $wp.frmBtn.btnPrint -text [::msgcat::mc "Print"] -font $fontNormal -width 12 -relief groove\
    -command {
        Print [.print.frmEnt.entPrint get]
        destroy .print
    }
    button $wp.frmBtn.btnCancel -text [::msgcat::mc "Cancel"] -font $fontNormal -width 12 -relief groove\
    -command "destroy .print"
    pack $wp.frmBtn.btnPrint $wp.frmBtn.btnCancel -side left -padx 2 -pady 2 -fill x -expand true
    InsertEnt $wp.frmEnt.entPrint "lpr"
    bind $wp <Escape> "destroy .print"
}
## PRINT COMMAND ##
proc Print {command} {
    global noteBook fontNormal fontBold fileList selectPrint tmpDir
    set node [$noteBook raise]
    set text "$noteBook.f$node.frame.text"
    set command lpr

    if {$node == "newproj" || $node == "settings" || $node == "about" || $node == ""} {
        set answer [tk_messageBox\
                -message "[::msgcat::mc "Don't selected file"]"\
                -type ok -icon warning\
                -title [::msgcat::mc "Warning"]]
                case $answer {
            ok {return 0}
        }
    }
    if {$selectPrint == "true"} {
        set selIndex [$text tag ranges sel]
        set start [lindex $selIndex 0]
        set end [lindex $selIndex 1]
        set prnText [$text get $start $end]
        set file [file join $tmpDir projprn.tmp]
        set f [open $file "w"]
        puts $f $prnText
        close $f
    } else {
        set file [lindex $fileList($node) 0]
    }
    set pipe [open "|$command $file" "r"]
    fileevent $pipe readable
    fconfigure $pipe -buffering none -blocking no
}

## GETTING EXTERNAL MODULES ##
proc Modules {} {
    global tcl_platform
    global module tclDir dataDir binDir
    # TkDIFF loading
    foreach m {tkcvs tkdiff gitk tkregexp} {
        if {$tcl_platform(platform) == "unix"} {
            if {$m == "tkregexp"} {
                set module($m) "[file join $binDir tkregexp.tcl]"
                break
            }
            set string [exec whereis $m]
            scan $string "%s%s" v module($m)
            if {[info exists module($m)] &&  [file isdirectory $module($m)] == 0} {
                puts "Find $module($m)"
            } else {
                set module($m) ""
            }
        }
    }
}
## RUNNING MODULE ##
proc DoModule {mod} {
    global tcl_platform
    global module activeProject projDir tree tclDir dataDir workDir
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
            set projName "$string"
        }
        if {$keyWord == "ProjectFileName"} {
            set projFileName "$string"
        }
        if {$keyWord == "ProjectDirName"} {
            set dir "$string"
        }  
        if {$keyWord == "ProjectCompiler"} {
            set projCompiler "$string"
        }  
        if {$keyWord == "ProjectInterp"} {
            set projInterp "$string"
        }  
    }
    close $file
    
    #puts "project dir - $dir"
    
    set curDir [pwd]
    case $mod {
        tkcvs {
            set pipe [open "|$module(tkcvs) -dir $dir" "r"]
            fileevent $pipe readable
            fconfigure $pipe -buffering none -blocking no
        }
        tkdiff {
            set files [$tree selection get]
            if {[llength $files] == 0} {
                set answer [tk_messageBox\
                -message "[::msgcat::mc "Don't selected file"]"\
                -type ok -icon warning\
                -title [::msgcat::mc "Warning"]]
                case $answer {
                    ok {return 0}
                }
            }
            if {[llength $files] == 1} {
                if {$files != ""} {
                    set file1 [$tree itemcget $files -data]
                }
                set command "-r $file1"
            }
            if {[llength $files] == 2} {
                if {[lindex $files 0] != ""} {
                    set file1 [$tree itemcget [lindex $files 0] -data]
                }
                if {[lindex $files 1] != ""} {
                    set file2 [$tree itemcget [lindex $files 1] -data]
                }
                set command "$file1 $file2"
            } 
            if {[llength $files] > 2} {
                set answer [tk_messageBox\
                -message "[::msgcat::mc "Must be one or two file select!"]"\
                -type ok -icon info\
                -title [::msgcat::mc "Warning"]]
                case $answer {
                    ok {return 0}
                }
            }
            set pipe [open "|$module(tkdiff) $command" "r"]
            fileevent $pipe readable
            fconfigure $pipe -buffering none -blocking no
        }
        tkregexp {
            set files [$tree selection get]
            if {[llength $files] == 0} {
                set command ""
            } elseif {[llength $files] == 1} {
                if {$files != ""} {
                    set file [$tree itemcget $files -data]
                }
                set command "$file"
            } else {
                set answer [tk_messageBox\
                -message "[::msgcat::mc "Must be one file select!"]"\
                -type ok -icon info\
                -title [::msgcat::mc "Warning"]]
                case $answer {
                    ok {return 0}
                }
            }
            puts "$module(tkregexp) $command"
            set pipe [open "|$module(tkregexp) $command" "r"]
            fileevent $pipe readable
            fconfigure $pipe -buffering none -blocking no
        }
        gitk {
            cd $dir
            #puts "========== $projDir $dir $curDir"
            set pipe [open "|$module(gitk)" "r"]
            fileevent $pipe readable
            fconfigure $pipe -buffering none -blocking no
        }
    }
}

proc SelectDir {dir} {
    global projDir workDir openProjDir
    set dirName [tk_chooseDirectory -initialdir $dir\
    -title "[::msgcat::mc "Select directory"]"\
        -parent .]
    return $dirName
}
## TOOLBAR ON/OFF PROCEDURE ##
proc ToolBar {} {
    global toolBar
    if {$toolBar == "Yes"} {
        CreateToolBar
    } elseif {$toolBar == "No"} {
        destroy .frmTool.btnNew .frmTool.btnSave .frmTool.btnSaveAs .frmTool.btnSaveAll\
                .frmTool.btnCopy .frmTool.btnPaste .frmTool.btnCut .frmTool.btnDo .frmTool.btnPrint\
                .frmTool.btnDoFile .frmTool.btnTGZ .frmTool.btnHelp .frmTool.btnClose
        .frmTool configure -height 1
    }
}


## LOADING HIGHLIGHT FILES ##
proc HighLight {ext text line lineNumber node} {
    global font tree color noteBook hlDir
    
    if {[file exists [file join $hlDir $ext.tcl]] == 1} {
        HighLight[string toupper $ext] $text $line $lineNumber $node
    } elseif {($ext == "htm") || ($ext == "xml") || ($ext == "fm") || ($ext == "html")} {
        HighLightHTML $text $line $lineNumber $node
    } elseif {($ext == "pl")} {
        HighLightPERL $text $line $lineNumber $node
    } elseif {($ext == "for")} {
        HighLightFORTRAN $text $line $lineNumber $node
    } elseif {($ext == "ml") || ($ext == "mli")} {
        HighLightML $text $line $lineNumber $node
    } elseif {($ext == "rvt") || ($ext == "tml")} {
        HighLightRIVET $text $line $lineNumber $node
    } elseif {($ext == "php") || ($ext == "phtml")} {
        HighLightPHP $text $line $lineNumber $node
    } elseif {($ext == "rb")} {
        HighLightRUBY $text $line $lineNumber $node
    } else {
        HighLightTCL $text $line $lineNumber $node
    }
}

## GET IMAGE FOR tree AND notebook WIDGETS ##
proc GetImage {fileName} {
    global imgDir
    if {[file isdirectory $fileName] == 1} {
        set img "folder"
        set data "dir"
    } elseif {[string match "*.tcl" $fileName] == 1} {
        set img "tcl"
        set data "src"
    } elseif {[string match "*.tk" $fileName] == 1} {
        set img "tk"
        set data "src"
    } elseif {[string match "*.rvt" $fileName] == 1} {
        set img "rvt"
        set data "src"
    } elseif {[string match "*.tex" $fileName] == 1} {
        set img "tex"
        set data "src"
    } elseif {[string match "*.html" $fileName] == 1 || [string match "*.htm" $fileName] == 1} {
        set img "html"
        set data "src"
    } elseif {[string match "*.gif" $fileName] == 1 || [string match "*.xpm" $fileName] == 1 || \
    [string match "*.png" $fileName] == 1 || [string match "*.jpg" $fileName] == 1 || \
    [string match "*.xbm" $fileName] == 1 || [string match "*.jpeg" $fileName] == 1 || \
    [string match "*.bmp" $fileName] == 1} {
        set img "img"
        set data "img"
    } elseif {[string match "*.xml" $fileName] == 1} {
        set img "xml"
        set data "xml"
    } elseif {[string match "*.java" $fileName] == 1 || [string match "*.ja" $fileName] == 1} {
        set img "java"
        set data "src"
    } elseif {[string match "*.c" $fileName] == 1} {
        set img "c"
        set data "src"
    } elseif {[string match "*.cpp" $fileName] == 1} {
        set img "cpp"
        set data "src"
    } elseif {[string match "*.spec" $fileName] == 1} {
        set img "rpm"
        set data "src"
    } elseif {[string match "*.pl" $fileName] == 1} {
        set img "perl"
        set data "src"
    } elseif {[string match "*.for" $fileName] == 1 || [string match "*.f" $fileName] == 1} {
        set img "fortran"
        set data "src"
    } elseif {[string match "*.ml" $fileName] == 1 || [string match "*.mli" $fileName] == 1} {
        set img "caml"
        set data "src"
    } elseif {[string match "*.tml" $fileName] == 1 || [string match "*.rvt" $fileName] == 1} {
        set img "tclhtml"
        set data "src"
    } elseif {[string match "*.php" $fileName] == 1 || [string match "*.phtml" $fileName] == 1} {
        set img "php"
        set data "src"
    } elseif {[string match "*.rb" $fileName] == 1} {
        set img "ruby"
        set data "src"
    } else {
        set img "file"
        set data "txt"
    }    
    return $img
}

proc GetExtention {node} {
    global fileList
    set ext [string range [file extension [file tail [lindex $fileList($node) 0]]] 1 end]
    return $ext
}











