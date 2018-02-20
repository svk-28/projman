######################################################
#                Tcl/Tk project Manager
#        Distributed under GNU Public License
# Author: Sergey Kalinin banzaj28@yandex.ru
# Home page: http://nuk-svk.ru
######################################################

## SETTING DIALOG ##
proc Settings {nBook} {
    global fontNormal fontBold imgDir workDir
    global editor color nb topLevelGeometry
    global main editFrm network
    global toolBar autoFormat backUpDel backUpCreate backUpShow localeSet localeList wrapSet wrapList
    set topLevelGeometry [winfo geometry .]
    if {[$nBook index settings] != -1} {
        $nBook delete settings
    }
    set w [$nBook insert end settings -text [::msgcat::mc "Settings"]]
    $nBook raise settings
    
    # destroy the find window if it already exists
    frame $w.frmMain -borderwidth 1 
    pack $w.frmMain -side top -fill both -expand 1
    frame $w.frmBtn -borderwidth 1 
    pack $w.frmBtn -side top -fill x
    
    set nb [NoteBook $w.frmMain.noteBook -font $fontBold -side bottom -bg $editor(bg) -fg $editor(fg)]
    pack $nb -fill both -expand true -padx 2 -pady 2
    
    button $w.frmBtn.btnFind -text [::msgcat::mc "Save"] -font $fontNormal -width 12 -relief groove \
    -bg $editor(bg) -fg $editor(fg) \
    -command {
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
        if {$dotFileShow == "false"} {
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
    button $w.frmBtn.btnCancel -text [::msgcat::mc "Close"] -relief groove -width 12\
    -font $fontNormal -command "destroy $w; $nBook delete settings " -bg $editor(bg) -fg $editor(fg)
    pack $w.frmBtn.btnFind $w.frmBtn.btnCancel -fill x -padx 5 -pady 5 -side right
    
    ##################  MAIN PREF ##########################
    set main [$nb insert end main -text "[::msgcat::mc "Main"]"]
    
    set scrwin [ScrolledWindow $main.scrwin -relief groove -bd 2 -bg $editor(bg)]
    #pack $scrwin -fill both -expand true
    set scrfrm [ScrollableFrame $main.frm  -bg $editor(bg)]
    pack $scrwin -fill both -expand true
    pack $scrfrm -fill both -expand true
    
    $scrwin setwidget $scrfrm
    set main [$scrfrm getframe]
    
    set frm_1 [frame $main.frmFontNormal  -bg $editor(bg)]
    label $frm_1.lblFontNormal -text [::msgcat::mc "Font normal"] -width 30\
    -anchor w -font $fontNormal -fg $editor(fg) -bg $editor(bg)
    entry $frm_1.txtFontNormal
    button $frm_1.btnFontNormal -borderwidth {1} -font $fontNormal \
    -command {SelectFontDlg $fontNormal $main.frmFontNormal.txtFontNormal} \
    -image [Bitmap::get [file join $imgDir font_selector.gif]]
    pack $frm_1.lblFontNormal -side left
    pack $frm_1.txtFontNormal -side left -fill x -expand true
    pack $frm_1.btnFontNormal -side left
    
    set frm_2 [frame $main.frmFontBold -bg $editor(bg)]
    label $frm_2.lblFontBold -text [::msgcat::mc "Font bold"] -width 30 -anchor w \
    -font $fontNormal -fg $editor(fg) -bg $editor(bg)
    entry $frm_2.txtFontBold
    button $frm_2.btnFontBold -borderwidth {1} -font $fontNormal \
    -command {SelectFontDlg $fontBold $main.frmFontBold.txtFontBold} \
    -image [Bitmap::get [file join $imgDir font_selector.gif]]
    pack $frm_2.lblFontBold -side left
    pack $frm_2.txtFontBold -side left -fill x -expand true
    pack $frm_2.btnFontBold -side left
    
    set frm_3 [frame $main.frmToolBar -bg $editor(bg)]
    label $frm_3.lblToolBar -text [::msgcat::mc "Toolbar"] -width 30 -anchor w \
    -font $fontNormal -fg $editor(fg) -bg $editor(bg)
    checkbutton $frm_3.chkToolBar -text "" -variable toolBar \
    -font $fontNormal -onvalue true -offvalue false -bg $editor(bg)
    pack $frm_3.lblToolBar -side left
    pack $frm_3.chkToolBar -side left
    
    set frm_4 [frame $main.frmProjDir -bg $editor(bg)]
    label $frm_4.lblProjDir -text [::msgcat::mc "Projects"] -width 30 -anchor w \
    -font $fontNormal -fg $editor(fg) -bg $editor(bg)
    entry $frm_4.txtProjDir -bg $editor(bg)
    button $frm_4.btnProjDir -borderwidth {1} -font $fontNormal -bg $editor(bg)\
    -image [Bitmap::get [file join $imgDir folder.gif]]\
    -command {
        InsertEnt $main.frmProjDir.txtProjDir [SelectDir $projDir]
    }
    pack $frm_4.lblProjDir -side left
    pack $frm_4.txtProjDir -side left -fill x -expand true
    pack $frm_4.btnProjDir -side left
    
    set frm_5 [frame $main.frmLocale -bg $editor(bg)]
    label $frm_5.lblLocale -text [::msgcat::mc "Interface language"]\
    -width 30 -anchor w -font $fontNormal -fg $editor(fg) -bg $editor(bg)
    set combo [ComboBox $frm_5.txtLocale \
    -textvariable localeSet -command "puts 123"\
    -selectbackground "#55c4d1" -selectborderwidth 0\
    -values [GetLocale]]
    pack $frm_5.lblLocale -side left
    pack $frm_5.txtLocale -side left -fill x -expand true
    
    set frm_6 [frame $main.frmRpmDir -bg $editor(bg)]
    label $frm_6.lblRpmDir -text [::msgcat::mc "RPM dir"] -width 30 -anchor w \
    -font $fontNormal -fg $editor(fg) -bg $editor(bg)
    entry $frm_6.txtRpmDir -fg $editor(fg) -bg $editor(bg)
    button $frm_6.btnRpmDir -borderwidth {1} -font $fontNormal -bg $editor(bg) \
    -image [Bitmap::get [file join $imgDir folder.gif]]\
    -command {
        InsertEnt $main.frmRpmDir.txtRpmDir [SelectDir $workDir]
    }
    pack $frm_6.lblRpmDir -side left
    pack $frm_6.txtRpmDir -side left -fill x -expand true
    pack $frm_6.btnRpmDir -side left
    
    set frm_7 [frame $main.frmTgzDir -bg $editor(bg)]
    label $frm_7.lblTgzDir -text [::msgcat::mc "TGZ dir"] -width 30 -anchor w -font $fontNormal -fg $editor(fg)
    entry $frm_7.txtTgzDir
    button $frm_7.btnTgzDir -borderwidth {1} -font $fontNormal \
    -image [Bitmap::get [file join $imgDir folder.gif]]\
    -command {
        InsertEnt $main.frmTgzDir.txtTgzDir [SelectDir $workDir]
    }
    pack $frm_7.lblTgzDir -side left
    pack $frm_7.txtTgzDir -side left -fill x -expand true
    pack $frm_7.btnTgzDir -side left
    
    set frm_8 [frame $main.frmRpmNamed -bg $editor(bg)]
    label $frm_8.lblRpmNamed -text [::msgcat::mc "RPM file mask"] -width 30 -anchor w\
    -font $fontNormal -fg $editor(fg)
    entry $frm_8.txtRpmNamed
    pack $frm_8.lblRpmNamed -side left
    pack $frm_8.txtRpmNamed -side left -fill x -expand true

    set frm_9 [frame $main.frmTgzNamed -bg $editor(bg)]
    label $frm_9.lblTgzNamed -text [::msgcat::mc "TGZ file mask"] -width 30 -anchor w\
    -font $fontNormal -fg $editor(fg)
    entry $frm_9.txtTgzNamed
    pack $frm_9.lblTgzNamed -side left
    pack $frm_9.txtTgzNamed -side left -fill x -expand true

    set frm_10 [frame $main.frmBackUpCreate -bg $editor(bg)]
    label $frm_10.lblBackUpCreate -text [::msgcat::mc "Create backup files"]\
            -width 30 -anchor w -font $fontNormal -fg $editor(fg)
    checkbutton $frm_10.chkBackUpCreate -text "" -variable backUpCreate \
            -font $fontNormal -onvalue true -offvalue false
    pack $frm_10.lblBackUpCreate -side left
    pack $frm_10.chkBackUpCreate -side left

    set frm_11 [frame $main.frmBackUpShow -bg $editor(bg)]
    label $frm_11.lblBackUpShow -text [::msgcat::mc "Show backup files"]\
            -width 30 -anchor w -font $fontNormal -fg $editor(fg)
    checkbutton $frm_11.chkBackUpShow -text "" -variable backUpShow \
            -font $fontNormal -onvalue true -offvalue false
    pack $frm_11.lblBackUpShow -side left
    pack $frm_11.chkBackUpShow -side left

    set frm_12 [frame $main.frmBackUpDel -bg $editor(bg)]
    label $frm_12.lblBackUpDel -text [::msgcat::mc "Delete backup files"]\
            -width 30 -anchor w -font $fontNormal -fg $editor(fg)
    checkbutton $frm_12.chkBackUpDel -text "" -variable backUpDel \
            -font $fontNormal -onvalue true -offvalue false
    pack $frm_12.lblBackUpDel -side left
    pack $frm_12.chkBackUpDel -side left
    set frm_13 [frame $main.frmDotFilesShow -bg $editor(bg)]
    label $frm_13.lblDotFilesShow -text [::msgcat::mc "Show dot files"]\
            -width 30 -anchor w -font $fontNormal -fg $editor(fg)
    checkbutton $frm_13.chkDotFilesShow -text "" -variable showDotFiles \
            -font $fontNormal -onvalue true -offvalue false
    pack $frm_13.lblDotFilesShow -side left
    pack $frm_13.chkDotFilesShow -side left

    pack $frm_1 $frm_2 $frm_5 $frm_3 $frm_4 $frm_6 $frm_7 \
    $frm_8 $frm_9 $frm_10 $frm_11 $frm_12  $frm_13 -side top -fill both -expand true
    
    #################### EDITOR PREF #########################
    set editFrm [$nb insert end editor -text "[::msgcat::mc "Editor"]"]
    
    set scrwin [ScrolledWindow $editFrm.scrwin  -relief groove -bd 2 -bg $editor(bg)]
    set scrfrm [ScrollableFrame $editFrm.frm -bg $editor(bg)]
    pack $scrwin -fill both -expand true
    pack $scrfrm -fill both -expand true
    $scrwin setwidget $scrfrm
    
    set editFrm [$scrfrm getframe]
    
    set frm_13 [frame $editFrm.frmEditorFont -bg $editor(bg)]
    label $frm_13.lblEditorFont -text [::msgcat::mc "Editor font"] -width 30\
    -anchor w -font $fontNormal
    entry $frm_13.txtEditorFont
    button $frm_13.btnEditorFont -borderwidth {1} -font $fontNormal \
    -command {SelectFontDlg $editor(font) $editFrm.frmEditorFont.txtEditorFont} \
    -image [Bitmap::get [file join $imgDir font_selector.gif]]
    pack $frm_13.lblEditorFont -side left
    pack $frm_13.txtEditorFont -side left -fill x -expand true
    pack $frm_13.btnEditorFont -side left
    
    set frm_14 [frame $editFrm.frmEditorFontBold -bg $editor(bg)]
    label $frm_14.lblEditorFontBold -text [::msgcat::mc "Editor font bold"]\          -width 30 -anchor w -font $fontNormal
    entry $frm_14.txtEditorFontBold
    button $frm_14.btnEditorFontBold -borderwidth {1} -font $fontNormal \
    -command {SelectFontDlg $editor(fontBold) $editFrm.frmEditorFontBold.txtEditorFontBold} \
    -image [Bitmap::get [file join $imgDir font_selector.gif]]
    pack $frm_14.lblEditorFontBold -side left
    pack $frm_14.txtEditorFontBold -side left -fill x -expand true
    pack $frm_14.btnEditorFontBold -side left
    
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
    
    set frm_22 [frame $editFrm.frmColorEditFG -bg $editor(bg)]
    label $frm_22.lblColorEditFG -text [::msgcat::mc "Editor foreground"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_22.txtColorEditFG
    button $frm_22.btnColorEditFG -borderwidth {1} -font $fontNormal \
    -command {
        ColorSelect $editFrm.frmColorEditFG.txtColorEditFG $editFrm.frmColorEditFG.btnColorEditFG
    } \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_22.lblColorEditFG -side left
    pack $frm_22.txtColorEditFG -side left -fill x -expand true
    pack $frm_22.btnColorEditFG -side left

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

    set frm_16 [frame $editFrm.frmColorProc -bg $editor(bg)]
    label $frm_16.lblColorProc -text [::msgcat::mc "Procedure name"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_16.txtColorProc -background $editor(bg)
    button $frm_16.btnColorProc -borderwidth {1} -font $fontNormal \
            -command {ColorSelect $editFrm.frmColorProc.txtColorProc $editFrm.frmColorProc.btnColorProc} \
            -text "Select color"\
            -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_16.lblColorProc -side left
    pack $frm_16.txtColorProc -side left -fill x -expand true
    pack $frm_16.btnColorProc -side left
    
    set frm_17 [frame $editFrm.frmColorKeyWord -bg $editor(bg)]
    label $frm_17.lblColorKeyWord -text [::msgcat::mc "Operators"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_17.txtColorKeyWord -background $editor(bg)
    button $frm_17.btnColorKeyWord -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorKeyWord.txtColorKeyWord $editFrm.frmColorKeyWord.btnColorKeyWord} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_17.lblColorKeyWord -side left
    pack $frm_17.txtColorKeyWord -side left -fill x -expand true
    pack $frm_17.btnColorKeyWord -side left
    
    set frm_35 [frame $editFrm.frmColorParam -bg $editor(bg)]
    label $frm_35.lblColorParam -text [::msgcat::mc "Parameters"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_35.txtColorParam -background $editor(bg)
    button $frm_35.btnColorParam -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorParam.txtColorParam $editFrm.frmColorParam.btnColorParam} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_35.lblColorParam -side left
    pack $frm_35.txtColorParam -side left -fill x -expand true
    pack $frm_35.btnColorParam -side left
    
    set frm_36 [frame $editFrm.frmColorSubParam -bg $editor(bg)]
    label $frm_36.lblColorSubParam -text [::msgcat::mc "Subparameters"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_36.txtColorSubParam -background $editor(bg)
    button $frm_36.btnColorSubParam -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorSubParam.txtColorSubParam $editFrm.frmColorSubParam.btnColorSubParam} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_36.lblColorSubParam -side left
    pack $frm_36.txtColorSubParam -side left -fill x -expand true
    pack $frm_36.btnColorSubParam -side left
    
    set frm_18 [frame $editFrm.frmColorComments -bg $editor(bg)]
    label $frm_18.lblColorComments -text [::msgcat::mc "Comments"]\
            -width 30 -anchor w -font $fontNormal
    entry $frm_18.txtColorComments -background $editor(bg)
    button $frm_18.btnColorComments -borderwidth {1} -font $fontNormal \
            -command {ColorSelect $editFrm.frmColorComments.txtColorComments $editFrm.frmColorComments.btnColorComments} \
            -text "Select color"\
            -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_18.lblColorComments -side left
    pack $frm_18.txtColorComments -side left -fill x -expand true
    pack $frm_18.btnColorComments -side left

    set frm_19 [frame $editFrm.frmColorVar -bg $editor(bg)]
    label $frm_19.lblColorVar -text [::msgcat::mc "Variables"]\
            -width 30 -anchor w -font $fontNormal
    entry $frm_19.txtColorVar -background $editor(bg)
    button $frm_19.btnColorVar -borderwidth {1} -font $fontNormal \
            -command {ColorSelect $editFrm.frmColorVar.txtColorVar $editFrm.frmColorVar.btnColorVar} \
            -text "Select color"\
            -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_19.lblColorVar -side left
    pack $frm_19.txtColorVar -side left -fill x -expand true
    pack $frm_19.btnColorVar -side left
    
    set frm_20 [frame $editFrm.frmColorString -bg $editor(bg)]
    label $frm_20.lblColorString -text [::msgcat::mc "Quote string"]\
            -width 30 -anchor w -font $fontNormal
            entry $frm_20.txtColorString -background $editor(bg)
    button $frm_20.btnColorString -borderwidth {1} -font $fontNormal \
            -command {ColorSelect $editFrm.frmColorString.txtColorString $editFrm.frmColorString.btnColorString} \
            -text "Select color"\
            -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_20.lblColorString -side left
    pack $frm_20.txtColorString -side left -fill x -expand true
    pack $frm_20.btnColorString -side left
    
    set frm_23 [frame $editFrm.frmColorBrace -bg $editor(bg)]
    label $frm_23.lblColorBrace -text [::msgcat::mc "Braces"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_23.txtColorBrace -background $editor(bg)
    button $frm_23.btnColorBrace -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorBrace.txtColorBrace $editFrm.frmColorBrace.btnColorBrace} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_23.lblColorBrace -side left
    pack $frm_23.txtColorBrace -side left -fill x -expand true
    pack $frm_23.btnColorBrace -side left

    set frm_24 [frame $editFrm.frmColorBraceBG -bg $editor(bg)]
    label $frm_24.lblColorBraceBG -text [::msgcat::mc "Braces background"]\
            -width 30 -anchor w -font $fontNormal
    entry $frm_24.txtColorBraceBG -background $editor(bg)
    button $frm_24.btnColorBraceBG -borderwidth {1} -font $fontNormal \
    -command {
        ColorSelect $editFrm.frmColorBraceBG.txtColorBraceBG $editFrm.frmColorBraceBG.btnColorBraceBG
        $editFrm.frmColorBraceFG.txtColorBraceFG configure -background [Text $editFrm.frmColorBraceBG.txtColorBraceBG]
    } \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_24.lblColorBraceBG -side left
    pack $frm_24.txtColorBraceBG -side left -fill x -expand true
    pack $frm_24.btnColorBraceBG -side left
    
    set frm_25 [frame $editFrm.frmColorBraceFG -bg $editor(bg)]
    label $frm_25.lblColorBraceFG -text [::msgcat::mc "Braces foreground"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_25.txtColorBraceFG -background $color(braceBG)
    button $frm_25.btnColorBraceFG -borderwidth {1} -font $fontNormal \
            -command {ColorSelect $editFrm.frmColorBraceFG.txtColorBraceFG $editFrm.frmColorBraceFG.btnColorBraceFG} \
            -text "Select color"\
            -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_25.lblColorBraceFG -side left
    pack $frm_25.txtColorBraceFG -side left -fill x -expand true
    pack $frm_25.btnColorBraceFG -side left

    set frm_26 [frame $editFrm.frmColorPercent -bg $editor(bg)]
    label $frm_26.lblColorPercent -text [::msgcat::mc "Percent \%"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_26.txtColorPercent -background $editor(bg)
    button $frm_26.btnColorPercent -borderwidth {1} -font $fontNormal \
            -command {ColorSelect $editFrm.frmColorPercent.txtColorPercent $editFrm.frmColorPercent.btnColorPercent} \
            -text "Select color"\
            -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_26.lblColorPercent -side left
    pack $frm_26.txtColorPercent -side left -fill x -expand true
    pack $frm_26.btnColorPercent -side left

    set frm_27 [frame $editFrm.frmColorBindKey -bg $editor(bg)]
    label $frm_27.lblColorBindKey -text [::msgcat::mc "Key bindings <Key>"]\
            -width 30 -anchor w -font $fontNormal
    entry $frm_27.txtColorBindKey -background $editor(bg)
    button $frm_27.btnColorBindKey -borderwidth {1} -font $fontNormal \
            -command {ColorSelect $editFrm.frmColorBindKey.txtColorBindKey $editFrm.frmColorBindKey.btnColorBindKey} \
            -text "Select color"\
            -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_27.lblColorBindKey -side left
    pack $frm_27.txtColorBindKey -side left -fill x -expand true
    pack $frm_27.btnColorBindKey -side left
    
    set frm_32 [frame $editFrm.frmColorSelectBG -bg $editor(bg)]
    label $frm_32.lblColorSelectBG -text [::msgcat::mc "Selection color"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_32.txtColorSelectBG -background $editor(bg)
    button $frm_32.btnColorSelectBG -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorSelectBG.txtColorSelectBG $editFrm.frmColorSelectBG.btnColorSelectBG} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_32.lblColorSelectBG -side left
    pack $frm_32.txtColorSelectBG -side left -fill x -expand true
    pack $frm_32.btnColorSelectBG -side left
    
    set frm_33 [frame $editFrm.frmColorNbNormal -bg $editor(bg)]
    label $frm_33.lblColorNbNormal -text [::msgcat::mc "Title normal"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_33.txtColorNbNormal -background $editor(bg)
    button $frm_33.btnColorNbNormal -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorNbNormal.txtColorNbNormal $editFrm.frmColorNbNormal.btnColorNbNormal} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_33.lblColorNbNormal -side left
    pack $frm_33.txtColorNbNormal -side left -fill x -expand true
    pack $frm_33.btnColorNbNormal -side left
    
    set frm_34 [frame $editFrm.frmColorNbModify -bg $editor(bg)]
    label $frm_34.lblColorNbModify -text [::msgcat::mc "Title modify"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_34.txtColorNbModify -background $editor(bg)
    button $frm_34.btnColorNbModify -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorNbModify.txtColorNbModify $editFrm.frmColorNbModify.btnColorNbModify} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_34.lblColorNbModify -side left
    pack $frm_34.txtColorNbModify -side left -fill x -expand true
    pack $frm_34.btnColorNbModify -side left
    
    set frm_37 [frame $editFrm.frmColorLabel -bg $editor(bg)]
    label $frm_37.lblColorLabel -text [::msgcat::mc "Label"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_37.txtColorLabel -background $editor(bg)
    button $frm_37.btnColorLabel -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorLabel.txtColorLabel $editFrm.frmColorLabel.btnColorLabel} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_37.lblColorLabel -side left
    pack $frm_37.txtColorLabel -side left -fill x -expand true
    pack $frm_37.btnColorLabel -side left

    set frm_38 [frame $editFrm.frmColorSixFG -bg $editor(bg)]
    label $frm_38.lblColorSixFG -text [::msgcat::mc "Six pos. foreground"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_38.txtColorSixFG -background $editor(bg)
    button $frm_38.btnColorSixFG -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorSixFG.txtColorSixFG $editFrm.frmColorSixFG.btnColorSixFG} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_38.lblColorSixFG -side left
    pack $frm_38.txtColorSixFG -side left -fill x -expand true
    pack $frm_38.btnColorSixFG -side left
    
    set frm_39 [frame $editFrm.frmColorSixBG -bg $editor(bg)]
    label $frm_39.lblColorSixBG -text [::msgcat::mc "Six pos. background"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_39.txtColorSixBG -background $editor(bg)
    button $frm_39.btnColorSixBG -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorSixBG.txtColorSixBG $editFrm.frmColorSixBG.btnColorSixBG} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_39.lblColorSixBG -side left
    pack $frm_39.txtColorSixBG -side left -fill x -expand true
    pack $frm_39.btnColorSixBG -side left
    
    set frm_40 [frame $editFrm.frmColorSQL -bg $editor(bg)]
    label $frm_40.lblColorSQL -text [::msgcat::mc "SQL commands"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_40.txtColorSQL -background $editor(bg)
    button $frm_40.btnColorSQL -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorSQL.txtColorSQL $editFrm.frmColorSQL.btnColorSQL} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_40.lblColorSQL -side left
    pack $frm_40.txtColorSQL -side left -fill x -expand true
    pack $frm_40.btnColorSQL -side left
    
    set frm_41 [frame $editFrm.frmColorBraceQuad -bg $editor(bg)]
    label $frm_41.lblColorBraceQuad -text [::msgcat::mc "Quad braces"]\
    -width 30 -anchor w -font $fontNormal
    entry $frm_41.txtColorBraceQuad -background $editor(bg)
    button $frm_41.btnColorBraceQuad -borderwidth {1} -font $fontNormal \
    -command {ColorSelect $editFrm.frmColorBraceQuad.txtColorBraceQuad $editFrm.frmColorBraceQuad.txtColorBraceQuad} \
    -text "Select color"\
    -image [Bitmap::get [file join $imgDir color_selector.gif]]
    pack $frm_41.lblColorBraceQuad -side left
    pack $frm_41.txtColorBraceQuad -side left -fill x -expand true
    pack $frm_41.btnColorBraceQuad -side left
    
    pack $frm_13 $frm_14 $frm_15 $frm_28 $frm_21 $frm_22 $frm_32 $frm_33 $frm_34 $frm_16 $frm_17 $frm_35 $frm_36 $frm_18 $frm_19 $frm_20\
    $frm_23 $frm_41 $frm_24 $frm_25 $frm_26 $frm_27 $frm_37 $frm_38 $frm_39 $frm_40  -side top -fill x -expand true
    
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
    global toolBar autoFormat backUpDel backUpCreate backUpShow localeSet localeList wrapSet wrapList
    
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
    puts $file "set color(param) \"[$editFrm.frmColorComments.txtColorComments get]\""
    puts $file "set color(subParam) \"[ get]\""
    puts $file "set color(comments) \"[ get]\""
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

