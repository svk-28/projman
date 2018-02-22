######################################################
#                Tcl/Tk project Manager
#        Distributed under GNU Public License
# Author: Sergey Kalinin banzaj28@yandex.ru
# Home page: http://nuk-svk.ru
######################################################


proc ColorSelect {ent w} {
    set color [SelectColor::menu $w.color [list below $w] -color [$w cget -background]]
    if {[string length $color]} {
        $ent configure -foreground $color
        InsertEnt $ent $color
    }
}

## SHOW SELECTED COLOR IN DIALOG ##
proc ConfigureEnt {col} {
    global editor color
    global main editFrm network
    $editFrm.frmColorEditFG.txtColorEditFG configure -background $col
    $editFrm.frmColorProc.txtColorProc configure -background $col -fg $color(procName)
    $editFrm.frmColorKeyWord.txtColorKeyWord configure -background $col -fg $color(keyWord)
    $editFrm.frmColorParam.txtColorParam  configure -background $col -fg $color(param)
    $editFrm.frmColorSubParam.txtColorSubParam  configure -background $col -fg $color(subParam)
    $editFrm.frmColorComments.txtColorComments configure -background $col -fg $color(comments)
    $editFrm.frmColorVar.txtColorVar configure -background $col -fg $color(var)
    $editFrm.frmColorString.txtColorString configure -background $col -fg $color(string)
    $editFrm.frmColorBrace.txtColorBrace configure -background $col -fg $color(brace)
    $editFrm.frmColorBraceQuad.txtColorBraceQuad configure -background $col -fg $color(bracequad)
    $editFrm.frmColorBraceBG.txtColorBraceBG configure -background $col -fg $color(braceBG)
    $editFrm.frmColorBraceFG.txtColorBraceFG configure -background $col -fg $color(braceFG)
    $editFrm.frmColorPercent.txtColorPercent configure -background $col -fg $color(percent)
    $editFrm.frmColorBindKey.txtColorBindKey configure -background $col -fg $color(bindKey)
    $editFrm.frmColorLabel.txtColorLabel configure -background $col -fg $color(label)
    $editFrm.frmColorSixFG.txtColorSixFG configure -background $col -fg $color(sixFG)
    $editFrm.frmColorSixBG.txtColorSixBG configure -background $col -fg $color(sixBG)
    $editFrm.frmColorSQL.txtColorSQL configure -background $col -fg $color(sql)
}

## READ CONFIG FILE ##
proc LoadSettings {} {
    global fontNormal imgDir workDir msgDir
    global editor color nb
    global main editFrm network
    global toolBar autoFormat backUpDel backUpCreate backUpShow showDotFiles localeSet localeList wrapSet wrapList
    
    ## load .conf file ##
    set file [open [file join $workDir projman.conf] r]
    while {[gets $file line]>=0} {
        scan $line "%s%s%s" trash keyWord var
        if {$trash == "set"} {
            set var [string trim $var "\""]
            switch $keyWord {
                fontNormal {
                    set v [string trim [string range $line [string first $var $line] end] "\""]
                    InsertEnt $main.frmFontNormal.txtFontNormal "$v"
                }
                fontBold {
                    set v [string trim [string range $line [string first $var $line] end] "\""]
                    InsertEnt $main.frmFontBold.txtFontBold "$v"
                }
                locale {
                    set localeIndex [lsearch -exact $localeList "$var"]
                    if {$localeIndex != -1} {
                        $main.frmLocale.txtLocale setvalue @$localeIndex
                    } else {
                        puts "$var.msg file not found into $msgDir"
                    }
                }
                toolBar {if {$var == "Yes"} {set toolBar "true" } else {set toolBar "false"} }
                backUpFileShow {
                    if {$var == "Yes"} {
                        set backUpShow "true"
                    } else {
                        set backUpShow "false"
                    }
                }
                backUpFileCreate {
                    if {$var == "Yes"} {
                        set backUpCreate "true"
                    } else {
                        set backUpCreate "false"
                    }
                }
                backUpFileDel {
                    if {$var == "Yes"} {
                        set backUpDel "true"
                    } else {
                        set backUpDel "false"
                    }
                }
                dotFileShow {
                    if {$var == "Yes"} {
                        set showDotFiles "true"
                    } else {
                        set showDotFiles "false"
                    }
                }
                projDir {InsertEnt $main.frmProjDir.txtProjDir "$var"}
                rpmDir {InsertEnt $main.frmRpmDir.txtRpmDir "$var"}
                tgzDir {InsertEnt $main.frmTgzDir.txtTgzDir "$var"}
                rpmNamed {InsertEnt $main.frmRpmNamed.txtRpmNamed "$var"}
                tgzNamed {InsertEnt $main.frmTgzNamed.txtTgzNamed "$var"}
                autoFormat {if {$var == "Yes"} {set autoFormat "true"} else {set autoFormat "false"}}
                "editor(wrap)" {
                    set wrapIndex [lsearch -exact $wrapList "$var"]
                    if {$wrapIndex != -1} {
                        $editFrm.frmWrap.txtWrap setvalue @$wrapIndex
                    }
                    unset wrapIndex
                }
                "editor(bg)" {
                    InsertEnt $editFrm.frmColorEditBG.txtColorEditBG "$var"
                    ConfigureEnt $var
                }
                "editor(fg)" {InsertEnt $editFrm.frmColorEditFG.txtColorEditFG "$var"}
                "editor(selectbg)" {InsertEnt $editFrm.frmColorSelectBG.txtColorSelectBG "$var"}
                "editor(nbNormal)" {InsertEnt $editFrm.frmColorNbNormal.txtColorNbNormal "$var"}
                "editor(nbModify)" {InsertEnt $editFrm.frmColorNbModify.txtColorNbModify "$var"}
                "color(procName)" {InsertEnt $editFrm.frmColorProc.txtColorProc "$var"}
                "color(keyWord)" {InsertEnt $editFrm.frmColorKeyWord.txtColorKeyWord "$var"}
                "color(param)" {InsertEnt $editFrm.frmColorParam.txtColorParam "$var"}
                "color(subParam)" {InsertEnt $editFrm.frmColorSubParam.txtColorSubParam "$var"}
                "color(comments)" {InsertEnt $editFrm.frmColorComments.txtColorComments "$var"}
                "color(var)" {InsertEnt $editFrm.frmColorVar.txtColorVar "$var"}
                "color(string)" {InsertEnt $editFrm.frmColorString.txtColorString "$var"}
                "color(brace)" {InsertEnt $editFrm.frmColorBrace.txtColorBrace "$var"}
                "color(bracequad)" {InsertEnt $editFrm.frmColorBraceQuad.txtColorBraceQuad "$var"}
                "color(braceBG)" {InsertEnt $editFrm.frmColorBraceBG.txtColorBraceBG "$var"}
                "color(braceFG)" {InsertEnt $editFrm.frmColorBraceFG.txtColorBraceFG "$var"}
                "color(percent)" {InsertEnt $editFrm.frmColorPercent.txtColorPercent "$var"}
                "color(bindKey)" {InsertEnt $editFrm.frmColorBindKey.txtColorBindKey "$var"}
                "color(label)" {InsertEnt $editFrm.frmColorLabel.txtColorLabel "$var"}
                "color(sixFG)" {InsertEnt $editFrm.frmColorSixFG.txtColorSixFG "$var"}
                "color(sixBG)" {InsertEnt $editFrm.frmColorSixBG.txtColorSixBG "$var"}
                "color(sql)" {InsertEnt $editFrm.frmColorSQL.txtColorSQL "$var"}
            }
            if {$keyWord == "editor(fontBold)"} {
                set v [string trim [string range $line [string first $var $line] end] "\""]
                InsertEnt $editFrm.frmEditorFontBold.txtEditorFontBold "$v"
            }
            if {$keyWord == "editor(font)"} {
                set v [string trim [string range $line [string first $var $line] end] "\""]
                InsertEnt $editFrm.frmEditorFont.txtEditorFont "$v"
            }
        }
    }
    close $file
}

## SAVE SETTINGS PROCEDURE ##
proc SaveSettings {} {
    global editor color workDir topLevelGeometry
    global main editFrm network wrapSet
    file copy -force [file join $workDir projman.conf] [file join $workDir projman.conf.old]
    set file [open [file join $workDir projman.conf] w]
    puts $file "###########################################################"
    puts $file "#                TCL/Tk Project Manager                   #"
    puts $file "#                    version $ver                        #"
    puts $file "#                                                         #"
    puts $file "# Copyright \(c\) \"Sergey Kalinin\", 2001, http://nuk-svk.ru #"
    puts $file "# Authors: Sergey Kalinin \(aka BanZaj\) banzaj28@yandex.ru #"
    puts $file "###########################################################\n"
    puts $file "# Modification date: [exec date]"
    puts $file "###########################################################\n"
    puts $file "set topLevelGeometry \"$topLevelGeometry\""
    puts $file "# Normal Font"
    puts $file "set fontNormal \"[$main.frmFontNormal.txtFontNormal get]\""
    puts $file "# Bold Font #"
    puts $file "set fontBold \"[$main.frmFontBold.txtFontBold get]\""
    puts $file "# ToolBar on/off \(Yes/No\)"
    if {$toolBar == "false"} {
        puts $file "set toolBar \"No\"\n"
    } else {
        puts $file "set toolBar \"Yes\"\n"
    }
    if {$backUpShow == "false"} {
        puts $file "set backUpFileShow \"No\""
    } else {
        puts $file "set backUpFileShow \"Yes\""
    }
    if {$backUpCreate == "false"} {
        puts $file "set backUpFileCreate \"No\""
    } else {
        puts $file "set backUpFileCreate \"Yes\""
    }
    if {$backUpDel == "false"} {
        puts $file "set backUpFileDelete \"No\""
    } else {
        puts $file "set backUpFileDelete \"Yes\""
    }
    if {$showDotFiles == "false"} {
        puts $file "set dotFileShow \"No\""
    } else {
        puts $file "set dotFileShow \"Yes\""
    }
    puts $file "\n# Don't edit this line"
    puts $file "# Directorys Settings #"
    puts $file "set projDir \"[$main.frmProjDir.txtProjDir get]\""
    puts $file "set rpmDir \"[$main.frmRpmDir.txtRpmDir get]\""
    puts $file "set tgzDir \"[$main.frmTgzDir.txtTgzDir get]\""
    puts $file "# File mask #"
    puts $file "set rpmNamed \"[$main.frmRpmNamed.txtRpmNamed get]\""
    puts $file "set tgzNamed \"[$main.frmTgzNamed.txtTgzNamed get]\""
    puts $file "\n# Locale setting\nset locale \"$localeSet\""
    
    if {$autoFormat == "false"} {
        puts $file "set autoFormat \"No\"\n"
    } else {
        puts $file "set autoFormat \"Yes\"\n"
    }
    puts $file "# Editor Font #"
    puts $file "set editor(font) \"[$frm_17.txtEditorFont get]\""
    puts $file "# Editor Bold Font #"
    puts $file "set editor(fontBold) \"[$frm_18.txtEditorFontBold get]\""
    puts $file "# background color #"
    puts $file "set editor(bg) \"[$editFrm.frmColorEditBG.txtColorEditBG get]\""
    puts $file "# foreground color #"
    puts $file "set editor(fg) \"[$editFrm.frmColorEditFG.txtColorEditFG get]\""
    puts $file "# selection background color #"
    puts $file "set editor(selectbg) \"[$editFrm.frmColorSelectBG.txtColorSelectBG get]\""
    puts $file "# NoteBook title normal font color #"
    puts $file "set editor(nbNormal) \"[$editFrm.frmColorNbNormal.txtColorNbNormal get]\""
    puts $file "# NoteBook title modify font color #"
    puts $file "set editor(nbModify) \"[$editFrm.frmColorNbModify.txtColorNbModify get]\""
    puts $file "# selection border width #"
    puts $file "set editor(selectBorder) \"0\""
    puts $file "# Editor wraping  #"
    puts $file "# must be: none, word or char"
    puts $file "set editor(wrap) \"$wrapSet\""
    
    puts $file "## SOURCE CODE HIGHLIGTNING ##"
    puts $file "set color(procName) \"[$editFrm.frmColorProc.txtColorProc get]\""
    puts $file "set color(keyWord) \"[$editFrm.frmColorKeyWord.txtColorKeyWord get]\""
    puts $file "set color(param) \"[$editFrm.frmColorCParam.txtColorParam get]\""
    puts $file "set color(subParam) \"[$editFrm.frmColorSubParam.txtColorSubParam get]\""
    puts $file "set color(comments) \"[$editFrm.frmColorComments.txtColorComments get]\""
    puts $file "set color(var) \"[$editFrm.frmColorVar.txtColorVar get]\""
    puts $file "set color(string) \"[$editFrm.frmColorString.txtColorString get]\""
    puts $file "set color(brace) \"[$editFrm.frmColorBrace.txtColorBrace get]\""
    puts $file "set color(bracequad) \"[$editFrm.frmColorBraceQuad.txtColorBraceQuad get]\""
    puts $file "set color(braceBG) \"[$editFrm.frmColorBraceBG.txtColorBraceBG get]\""
    puts $file "set color(braceFG) \"[$editFrm.frmColorBraceFG.txtColorBraceFG get]\""
    puts $file "set color(percent) \"[$editFrm.frmColorPercent.txtColorPercent get]\""
    puts $file "set color(bindKey) \"[$editFrm.frmColorBindKey.txtColorBindKey get]\""
    puts $file "set color(label) \"[$editFrm.frmColorLabel.txtColorLabel get]\""
    puts $file "set color(sixFG) \"[$editFrm.frmColorSixFG.txtColorSixFG get]\""
    puts $file "set color(sixBG) \"[$editFrm.frmColorSixBG.txtColorSixBG get]\""
    puts $file "set color(sql) \"[$editFrm.frmColorSQL.txtColorSQL get]\""
    puts $file "\nset workingProject \"\""
    close $file
    $noteBook delete settings
    $noteBook  raise [$noteBook page end]
}


proc Settings {nBook} {
    global fontNormal fontBold imgDir workDir
    global editor color nb topLevelGeometry
    global main editFrm network
    global toolBar autoFormat backUpDel backUpCreate backUpShow showDotFiles localeSet localeList wrapSet wrapList
    set topLevelGeometry [winfo geometry .]
    if {[$nBook index settings] != -1} {
        $nBook delete settings
    }
    set w [$nBook insert end settings -text [::msgcat::mc "Settings"]]
    $nBook raise settings
    
    # destroy the find window if it already exists
    frame $w.frmMain -borderwidth 1 
    pack $w.frmMain -side top -fill both -expand true
    frame $w.frmBtn -borderwidth 1 
    pack $w.frmBtn -side top -fill x
    
    set nb [NoteBook $w.frmMain.noteBook -font $fontBold \
    -side bottom -bg $editor(bg) -fg $editor(fg)]
    pack $nb -fill both -expand true -padx 2 -pady 2
    
    button $w.frmBtn.btnFind -text [::msgcat::mc "Save"] \
    -font $fontNormal -width 12 -relief flat \
    -bg $editor(bg) -fg $editor(fg) -command {
        file copy -force [file join $workDir projman.conf] [file join $workDir projman.conf.old]
        set file [open [file join $workDir projman.conf] w]
        puts $file "###########################################################"
        puts $file "#                TCL/Tk Project Manager                   #"
        puts $file "#                    version $ver                        #"
        puts $file "#                                                         #"
        puts $file "# Copyright \(c\) \"Sergey Kalinin\", 2001, http://nuk-svk.ru #"
        puts $file "# Authors: Sergey Kalinin \(aka BanZaj\) banzaj28@yandex.ru #"
        puts $file "###########################################################"        
        puts $file "# Modification date: [exec date]"
        puts $file "###########################################################\n"
        puts $file "set topLevelGeometry \"$topLevelGeometry\""
        puts $file "# Normal Font"
        puts $file "set fontNormal \"[$main.frmFontNormal.txtFontNormal get]\""
        puts $file "# Bold Font #"
        puts $file "set fontBold \"[$main.frmFontBold.txtFontBold get]\""
        puts $file "# ToolBar on/off \(Yes/No\)"
        if {$toolBar == "false"} {
            puts $file "set toolBar \"No\"\n"
        } else {
            puts $file "set toolBar \"Yes\"\n"
        }
        if {$backUpShow == "false"} {
            puts $file "set backUpFileShow \"No\""
        } else {
            puts $file "set backUpFileShow \"Yes\""
        }
        if {$backUpCreate == "false"} {
            puts $file "set backUpFileCreate \"No\""
        } else {
            puts $file "set backUpFileCreate \"Yes\""
        }
        if {$backUpDel == "false"} {
            puts $file "set backUpFileDelete \"No\""
        } else {
            puts $file "set backUpFileDelete \"Yes\""
        }
        if {$showDotFiles == "false"} {
            puts $file "set dotFileShow \"No\""
        } else {
            puts $file "set dotFileShow \"Yes\""
        }
        puts $file "\n# Don't edit this line"
        puts $file "# Directorys Settings #"
        puts $file "set projDir \"[$main.frmProjDir.txtProjDir get]\""
        puts $file "set rpmDir \"[$main.frmRpmDir.txtRpmDir get]\""
        puts $file "set tgzDir \"[$main.frmTgzDir.txtTgzDir get]\""
        puts $file "# File mask #"
        puts $file "set rpmNamed \"[$main.frmRpmNamed.txtRpmNamed get]\""
        puts $file "set tgzNamed \"[$main.frmTgzNamed.txtTgzNamed get]\""
        puts $file "\n# Locale setting\nset locale \"$localeSet\""
        
        if {$autoFormat == "false"} {
            puts $file "set autoFormat \"No\"\n"
        } else {
            puts $file "set autoFormat \"Yes\"\n"
        }
        puts $file "# Editor Font #"
        puts $file "set editor(font) \"[$editFrm.frmEditorFont.txtEditorFont get]\""
        puts $file "# Editor Bold Font #"
        puts $file "set editor(fontBold) \"[$editFrm.frmEditorFontBold.txtEditorFontBold get]\""
        puts $file "# background color #"
        puts $file "set editor(bg) \"[$editFrm.frmColorEditBG.txtColorEditBG get]\""
        puts $file "# foreground color #"
        puts $file "set editor(fg) \"[$editFrm.frmColorEditFG.txtColorEditFG get]\""
        puts $file "# selection background color #"
        puts $file "set editor(selectbg) \"[$editFrm.frmColorSelectBG.txtColorSelectBG get]\""
        puts $file "# NoteBook title normal font color #"
        puts $file "set editor(nbNormal) \"[$editFrm.frmColorNbNormal.txtColorNbNormal get]\""
        puts $file "# NoteBook title modify font color #"
        puts $file "set editor(nbModify) \"[$editFrm.frmColorNbModify.txtColorNbModify get]\""
        puts $file "# selection border width #"
        puts $file "set editor(selectBorder) \"0\""
        puts $file "# Editor wraping  #"
        puts $file "# must be: none, word or char"
        puts $file "set editor(wrap) \"$wrapSet\""
        
        puts $file "## SOURCE CODE HIGHLIGTNING ##"
        puts $file "set color(procName) \"[$editFrm.frmColorProc.txtColorProc get]\""
        puts $file "set color(keyWord) \"[$editFrm.frmColorKeyWord.txtColorKeyWord get]\""
        puts $file "set color(param) \"[$editFrm.frmColorParam.txtColorParam get]\""
        puts $file "set color(subParam) \"[$editFrm.frmColorSubParam.txtColorSubParam get]\""
        puts $file "set color(comments) \"[$editFrm.frmColorComments.txtColorComments get]\""
        puts $file "set color(var) \"[$editFrm.frmColorVar.txtColorVar get]\""
        puts $file "set color(string) \"[$editFrm.frmColorString.txtColorString get]\""
        puts $file "set color(brace) \"[$editFrm.frmColorBrace.txtColorBrace get]\""
        puts $file "set color(bracequad) \"[$editFrm.frmColorBraceQuad.txtColorBraceQuad get]\""
        puts $file "set color(braceBG) \"[$editFrm.frmColorBraceBG.txtColorBraceBG get]\""
        puts $file "set color(braceFG) \"[$editFrm.frmColorBraceFG.txtColorBraceFG get]\""
        puts $file "set color(percent) \"[$editFrm.frmColorPercent.txtColorPercent get]\""
        puts $file "set color(bindKey) \"[$editFrm.frmColorBindKey.txtColorBindKey get]\""
        puts $file "set color(label) \"[$editFrm.frmColorLabel.txtColorLabel get]\""
        puts $file "set color(sixFG) \"[$editFrm.frmColorSixFG.txtColorSixFG get]\""
        puts $file "set color(sixBG) \"[$editFrm.frmColorSixBG.txtColorSixBG get]\""
        puts $file "set color(sql) \"[$editFrm.frmColorSQL.txtColorSQL get]\""
        puts $file "\nset workingProject \"\""
        
        close $file
        #destroy $w
        .frmBody.frmWork.noteBook delete settings

    }
    button $w.frmBtn.btnCancel -text [::msgcat::mc "Close"] -relief flat -width 12\
    -font $fontNormal -command "destroy $w; $nBook delete settings " -bg $editor(bg) -fg $editor(fg)
    pack $w.frmBtn.btnFind $w.frmBtn.btnCancel -fill x -padx 5 -pady 5 -side right
    
    ##################  MAIN PREF ##########################
    set main [$nb insert end main -text "[::msgcat::mc "Main"]"]
    
    set scrwin [ScrolledWindow $main.scrwin -relief flat -bd 2 -bg $editor(bg)]
    #pack $scrwin -fill both -expand true
    set scrfrm [ScrollableFrame $main.frm  -bg $editor(bg) -constrainedwidth true]
    pack $scrwin -fill both -expand true
    pack $scrfrm -fill both -expand true
    
    $scrwin setwidget $scrfrm
    set main [$scrfrm getframe]
    label $main.lblWinTitle -text [::msgcat::mc "Main settings"] -height 2 -font $fontBold
    pack $main.lblWinTitle -side top -fill x -expand true
    
    #### BEGIN Fonts settings ####
    set fontWidgets {
        FontNormal {Font normal}
        FontBold  {Font bold}
    }
    foreach {widgetName widgetText} $fontWidgets {
        set frm [frame $main.frm$widgetName -bg $editor(bg)]
        label $frm.lbl$widgetName -text [::msgcat::mc $widgetText] -width 30 -anchor w \
        -font $fontNormal -fg $editor(fg) -bg $editor(bg)
        entry $frm.txt$widgetName
        button $frm.btn$widgetName -borderwidth {1} -font $fontNormal \
        -command "SelectFontDlg \"$fontBold\" $main.frm$widgetName.txt$widgetName" \
        -image [Bitmap::get [file join $imgDir font_selector.gif]]
        pack $frm.lbl$widgetName -side left
        pack $frm.txt$widgetName -side left -fill x -expand true
        pack $frm.btn$widgetName -side left
        pack $frm -side top -fill both -expand true -padx 5 -pady 2
        unset frm
    }
    #### END #####
    
    set frm_5 [frame $main.frmLocale -bg $editor(bg)]
    label $frm_5.lblLocale -text [::msgcat::mc "Interface language"]\
    -width 30 -anchor w -font $fontNormal -fg $editor(fg) -bg $editor(bg)
    set combo [ComboBox $frm_5.txtLocale \
    -textvariable localeSet -command "puts 123"\
    -selectbackground "#55c4d1" -selectborderwidth 0\
    -values [GetLocale]]
    pack $frm_5.lblLocale -side left
    pack $frm_5.txtLocale -side left ;#-fill x -expand true
    pack $frm_5 -side top -fill both -expand true -padx 5 -pady 2
 
    #### BEGIN directory widgets builder ###
    set dirWidgets {
        ProjDir Projects
        RpmDir {RPM directory}
        TgzDir {Archive directory}
    }
    foreach {widgetName widgetText} $dirWidgets {
        set frm [frame $main.frm$widgetName -bg $editor(bg)]
        label $frm.lbl$widgetName -text [::msgcat::mc "$widgetText"] \
        -width 30 -anchor w -font $fontNormal -fg $editor(fg)
        entry $frm.txt$widgetName
        button $frm.btn$widgetName -borderwidth {1} -font $fontNormal \
        -image [Bitmap::get [file join $imgDir folder.gif]]\
        -command "DirInsertIntoEnt $main.frm$widgetName.txt$widgetName $workDir"
        pack $frm.lbl$widgetName -side left
        pack $frm.txt$widgetName -side left -fill x -expand true
        pack $frm.btn$widgetName -side left
        pack $frm -side top -fill both -expand true -padx 5 -pady 2
        unset frm
    }
    # little workaround hack
    proc DirInsertIntoEnt {widget dir} {
        InsertEnt $widget [SelectDir $dir]
    }
    ######### END #########

    #### BEGIN file mask widgets builder ###
    set fileMaskWidgets {
        RpmNamed {RPM file mask}
        TgzNamed {Archive file mask}
    }
    foreach {widgetName widgetText} $fileMaskWidgets {
        set frm [frame $main.frm$widgetName -bg $editor(bg)]
        label $frm.lbl$widgetName -text [::msgcat::mc "$widgetText"] -width 30 -anchor w\
        -font $fontNormal -fg $editor(fg)
        entry $frm.txt$widgetName
        pack $frm.lbl$widgetName -side left
        pack $frm.txt$widgetName -side left -fill x -expand true
        pack $frm -side top -fill both -expand true -padx 5 -pady 2
        unset frm
    }
    ######### END ##########
    
    ### BEGIN CheckBox widgets build ####    
    set cbWidgets {
        ToolBar toolBar {Toolbar}
        BackUpShow  backUpShow {Show backup files}
        BackUpCreate backUpCreate {Create backup files}
        BackUpDel backUpDel {Delete backup files}
        DotFilesShow dotFileShow {Show dot files}
    }
    foreach {widgetName confVar widgetText} $cbWidgets {
        set frm [frame $main.frm$widgetName -bg $editor(bg)]
        label $frm.lbl$widgetName -text [::msgcat::mc "$widgetText"]\
        -width 30 -anchor w -font $fontNormal -fg $editor(fg)
        checkbutton $frm.chk$widgetName -text "" -variable $confVar \
        -font $fontNormal -onvalue true -offvalue false
        pack $frm.lbl$widgetName -side left
        pack $frm.chk$widgetName -side left
        pack $frm -side top -fill both -expand true -padx 5 -pady 2
        unset frm
    }
    ######### END ##########
    
    #################### EDITOR PREF #########################
    set editFrm [$nb insert end editor -text "[::msgcat::mc "Editor"]"]
    
    set scrwin [ScrolledWindow $editFrm.scrwin  -relief flat -bd 2 -bg $editor(bg)]
    set scrfrm [ScrollableFrame $editFrm.frm -bg $editor(bg) -constrainedwidth true]
    pack $scrwin -fill both -expand true -fill both
    pack $scrfrm -fill both -expand true -fill both
    $scrwin setwidget $scrfrm
    
    set editFrm [$scrfrm getframe]
    label $editFrm.lblTitle -text [::msgcat::mc "Editor settings"] -height 2 -font $fontBold
    pack $editFrm.lblTitle -side top -fill x -expand true
    
    ### BEGIN editor fonts settings field builder ####
    set fontWidgets {
        EditorFont {Editor font}
        EditorFontBold  {Editor font bold}
    }
    foreach {widgetName widgetText} $fontWidgets {
        set frm [frame $editFrm.frm$widgetName -bg $editor(bg)]
        label $frm.lbl$widgetName -text [::msgcat::mc "$widgetText"] -width 30\
        -anchor w -font $fontNormal
        entry $frm.txt$widgetName
        button $frm.btn$widgetName -borderwidth {1} -font $fontNormal \
        -command "SelectFontDlg \"$editor(font)\" $editFrm.frm$widgetName.txt$widgetName" \
        -image [Bitmap::get [file join $imgDir font_selector.gif]]
        pack $frm.lbl$widgetName -side left
        pack $frm.txt$widgetName -side left -fill x -expand true
        pack $frm.btn$widgetName -side left
        pack $frm -side top -fill x -expand true -padx 5 -pady 2
        unset frm
    }
    #### END ####    
    set frm_21 [frame $editFrm.frmColorEditBG -bg $editor(bg)]
    label $frm_21.lblColorEditBG -text [::msgcat::mc "Editor background"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_21.txtColorEditBG
    button $frm_21.btnColorEditBG -borderwidth {1} -font $fontNormal \
    -text "Select color" -image [Bitmap::get [file join $imgDir color_selector.gif]]\
    -command {
        ColorSelect $editFrm.frmColorEditBG.txtColorEditBG $editFrm.frmColorEditBG.btnColorEditBG
        ConfigureEnt [Text $editFrm.frmColorEditBG.txtColorEditBG]
    } 
    pack $frm_21.lblColorEditBG -side left
    pack $frm_21.txtColorEditBG -side left -fill x -expand true
    pack $frm_21.btnColorEditBG -side left
    
    set frm_15 [frame $editFrm.frmAutoFormat -bg $editor(bg)]
    label $frm_15.lblAutoFormat -text [::msgcat::mc "Text autoformat"]\
    -width 30 -anchor w -font $fontNormal
    checkbutton $frm_15.chkAutoFormat -text "" -variable autoFormat \
    -font $fontNormal -onvalue true -offvalue false
            pack $frm_15.lblAutoFormat -side left
    pack $frm_15.chkAutoFormat -side left
    
    set wrapList [list none word char]
    
    set frm_28 [frame $editFrm.frmWrap -bg $editor(bg)]
    label $frm_28.lblWrap -text [::msgcat::mc "Word wrapping"]\
    -width 30 -anchor w -font $fontNormal
    set combo2 [ComboBox $frm_28.txtWrap\
    -textvariable wrapSet -command "puts 123"\
    -selectbackground "#55c4d1" -selectborderwidth 0\
    -values "$wrapList"]
    pack $frm_28.lblWrap -side left
    pack $combo2 -side left
    
    pack $frm_15 $frm_28 $frm_21 -side top -fill x -expand true -padx 5 -pady 2
    
    #### BEGIN of Color setting label and entry build ####
    set colorWidgets {
        EditFG {Editor foreground}
        Proc {Procedure name}
        KeyWord {Operators}
        Param {Parameters}
        SubParam {Subparameters}
        Comments {Comments}
        Var {Variables}
        String {Quote string}
        Brace {Braces}
        BraceBG {Braces background}
        BraceFG {Braces foreground}
        Percent Percent
        BindKey {Key bindings}
        SelectBG {Selection color}
        NbNormal {Title normal}
        NbModify {Title modify}
        Label {Label}
        SixFG {Indent foreground}
        SixBG {Indent background}
        SQL {SQL commands}
        BraceQuad {Quad braces}
    }
    foreach {widgetName widgetText} $colorWidgets {
        set frm [frame $editFrm.frmColor$widgetName -bg $editor(bg)]
        puts "$frm >$widgetName> $widgetText"
        label $frm.lblColor$widgetName -text "[::msgcat::mc $widgetText]"\
        -width 30 -anchor w -font $fontNormal
        entry $frm.txtColor$widgetName -background $editor(bg)
        button $frm.btnColor$widgetName -borderwidth {1} -font $fontNormal \
        -command "ColorSelect $frm.txtColor$widgetName $frm.txtColor$widgetName" \
        -text "[::msgcat::mc $widgetText]"\
        -image [Bitmap::get [file join $imgDir color_selector.gif]]
        pack $frm.lblColor$widgetName -side left
        pack $frm.txtColor$widgetName -side left -fill x -expand true
        pack $frm.btnColor$widgetName -side left
        pack $frm  -side top -fill x -expand true -padx 5 -pady 2
    }
    #### END ####
    
    ################### NETWORK PREF #########################
    set network [$nb insert end network -text "[::msgcat::mc "Network"]" -state disabled]
    set scrwin [ScrolledWindow $network.scrwin -relief groove -bd 2]
    set scrfrm [ScrollableFrame $network.frm]
    pack $scrwin -fill both -expand true
    pack $scrfrm -fill both -expand true
    $scrwin setwidget $scrfrm
    
    set network [$scrfrm getframe]
    
    set frm_29 [frame $network.frmFtpServer]
    label $frm_29.lblFtpServer -text [::msgcat::mc "FTP server"] -width 30\
    -anchor w -font $fontNormal
    entry $frm_29.txtFtpServer
    pack $frm_29.lblFtpServer -side left
    pack $frm_29.txtFtpServer -side left -fill x -expand true
    
    set frm_30 [frame $network.frmFtpUser]
    label $frm_30.lblFtpUser -text [::msgcat::mc "FTP user"] -width 30\
    -anchor w -font $fontNormal
    entry $frm_30.txtFtpUser
    pack $frm_30.lblFtpUser -side left
    pack $frm_30.txtFtpUser -side left -fill x -expand true
    
    set frm_31 [frame $network.frmFtpUserPass]
    label $frm_31.lblFtpUserPass -text [::msgcat::mc "FTP password"] -width 30\
    -anchor w -font $fontNormal
    entry $frm_31.txtFtpUserPass
    pack $frm_31.lblFtpUserPass -side left
    pack $frm_31.txtFtpUserPass -side left -fill x -expand true
    
    pack $frm_29 $frm_30 $frm_31 -side top -fill x
    
    $nb raise main
    # Read a config file #
    LoadSettings
}


