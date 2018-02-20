#!/usr/bin/wish
######################################################
#                Tcl/Tk Project Manager
#        Distributed under GNU Public License
# Author: Sergey Kalinin banzaj28@yandex.ru
# Copyright (c) "https://nuk-svk.ru", 2018
# Home: https://bitbucket.org/svk28/projman
######################################################
#
# Toolbar create procedures
#
######################################################

proc Separator {} {
    global sepIndex editor
    set f [frame .frmTool.separator$sepIndex -width 10 -border 1 \
    -background $editor(bg) -relief raised]
    incr sepIndex 1
    return $f
}

proc CreateToolBar {} {
    global toolBar fontBold noteBook tree imgDir editor
    if {$toolBar == "Yes"} {
        set bboxFile [ButtonBox .frmTool.bboxFile -spacing 0 -padx 1 -pady 1 -bg $editor(bg)]
        add_toolbar_button $bboxFile new.png {AddToProjDialog file} [::msgcat::mc "Create new file"]
        #add_toolbar_button $bboxFile open.png {FileDialog $tree open} [::msgcat::mc "Open file"]
        add_toolbar_button $bboxFile save.png {FileDialog $tree save} [::msgcat::mc "Save file"]
        add_toolbar_button $bboxFile save_as.png {FileDialog $tree save_as} [::msgcat::mc "Save file as"]
        add_toolbar_button $bboxFile save_all.png {FileDialog $tree save_all} [::msgcat::mc "Save all"]
        add_toolbar_button $bboxFile printer.png {PrintDialog} [::msgcat::mc "Print ..."]
        add_toolbar_button $bboxFile close.png {FileDialog $tree close} [::msgcat::mc "Close"]
        
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
## TOOLBAR ##
proc add_toolbar_button {path icon command helptext} {
    global editor imgDir
    image create photo $icon -format png -file [file join $imgDir $icon]
    $path add -image $icon \
    -highlightthickness 0 -takefocus 0 -relief link -bd 1  -activebackground $editor(bg)\
    -padx 1 -pady 1 -command $command -helptext $helptext
}
# Separator for toolbar

