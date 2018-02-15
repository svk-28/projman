######################################################
#                projman
#        Distributed under GNU Public License
# Author: Sergey Kalinin s.v.kalinin28@gmail.com
# Copyright (c) "https://nuk-svk.ru", 2018,
# https://bitbucket.org/svk28/projman
######################################################

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
    #image create photo imgLogo -format png -file [file join $imgDir projman.png]
    image create photo imgLogo -data {
        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
        AABJRU5ErkJggg==
    }
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

