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
    global toolBar fontNormal fontBold noteBook tree imgDir editor
    if {$toolBar == "Yes"} {
        set bboxFile [ButtonBox .frmTool.bboxFile -spacing 0 -padx 1 -pady 1 -bg $editor(bg)]
        add_toolbar_button $bboxFile new.png {AddToProjDialog file [$noteBookFiles raise]} [::msgcat::mc "Create new file"]
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
        # GoTo field
        set frm [frame .frmTool.frmGoto -bg $editor(bg)]
        GoToLineButton $frm
        pack $bboxFile [Separator] $bboxEdit [Separator] $bboxProj [Separator] $bboxHelp [Separator] $frm -side left -anchor w
        
        # Create menubutton and menu 
        image create photo menu.png -format png -file [file join $imgDir menu.png]
        menubutton .frmTool.menu -menu .frmTool.menu.m -font $fontNormal -bg $editor(bg) -fg $editor(fg) \
        -image menu.png
        set m [menu .frmTool.menu.m -bg $editor(bg) -fg $editor(fg)]
        GetFileMenu $m
        $m add separator
        $m add cascade -label [::msgcat::mc "Project"] -menu $m.project -font $fontNormal
        GetProjMenu [menu $m.project  -bg $editor(bg) -fg $editor(fg)]
        
        $m add cascade -label [::msgcat::mc "Edit"] -menu $m.edit -font $fontNormal
        GetMenu [menu $m.edit  -bg $editor(bg) -fg $editor(fg)]
        
        #$m add cascade -label [::msgcat::mc "View"] -menu $m.view -font $fontNormal
        #GetViewMenu [menu $m.view  -bg $editor(bg) -fg $editor(fg)]
        
        $m add cascade -label [::msgcat::mc "Modules"] -menu $m.modules -font $fontNormal
        GetModulesMenu [menu $m.modules  -bg $editor(bg) -fg $editor(fg)]
        
        $m add cascade -label [::msgcat::mc "Help"] -menu $m.help -font $fontNormal
        GetHelpMenu [menu $m.help  -bg $editor(bg) -fg $editor(fg)]
            
        pack .frmTool.menu -side right
        
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
proc GoToLineButton {w} {
    global noteBook fontNormal editor
    label $w.text -text [::msgcat::mc "Line number"] -font $fontNormal \
    -bg $editor(bg) -fg $editor(fg)
    entry $w.entGoTo -width 6 -validate key -validatecommand "ValidNumber %W %P" \
    -bg $editor(bg) -fg $editor(fg)
    pack $w.text $w.entGoTo -side left  -padx 2 -pady 2
    bind $w.entGoTo <Return> "+ToolBarGoToLineNumber $w"
    balloon $w.entGoTo set [::msgcat::mc "Goto line"]
}



