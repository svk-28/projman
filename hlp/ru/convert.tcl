######################################################
#                Tk LaTeX Editor
#        Distributed under GNU Public License
# Author: Sergey Kalinin banzaj28@yandex.ru
# Copyright (c) "Sergey Kalinin", 2002, http://nuk-svk.ru
######################################################


proc Latex2Html {} {
    global tree module cmdString
    set selFiles [$tree selection get]
    if {[llength $selFiles] == 0} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Don't selected file"]"\
        -type ok -icon warning\
        -title [::msgcat::mc "Warning"]]
        case $answer {
            ok {return 0}
        }
    }
    if {[llength $selFiles] == 1} {
        if {$selFiles != ""} {
            set file [$tree itemcget $selFiles -data]
        }
        CommandStringDialog $file
    }
    #puts $command
}
proc CommandStringDialog {action file} {
    global nb files font color cmdString module convert_cmd preview_cmd
    set w .cmd
    # destroy the find window if it already exists
    if {[winfo exists $w]} {
        destroy $w
    }
    
    toplevel $w
    wm title $w [::msgcat::mc "Command options"]
    wm resizable $w 0 0
    wm transient $w .
    frame $w.frmCombo -borderwidth 1 -background $color(bg)
    frame $w.frmBtn -borderwidth 1 -background $color(bg)
    pack $w.frmCombo $w.frmBtn -side top -fill x
    
    #    set combo [entry $w.frmCombo.entFind]
    label $w.frmCombo.lblModule -text $module() -background $color(bg)
    set combo [entry $w.frmCombo.txtString]
    
    pack $w.frmCombo.lblModule $combo -fill x -padx 2 -pady 2 -side top
    
    button $w.frmBtn.btnFind -text [::msgcat::mc "Run"]\
    -font $font(normal) -width 12 -relief groove -background $color(bg)\
    -command {
        RunConverter [.cmd.frmCombo.txtString get]
    }
    button $w.frmBtn.btnCancel -text [::msgcat::mc "Close"]\
    -relief groove -width 12 -font $font(normal) -background $color(bg)\
    -command "destroy $w"
    pack $w.frmBtn.btnFind $w.frmBtn.btnCancel -fill x -padx 2 -pady 2 -side left
    
    bind $w <Return> {RunConverter [.cmd.frmCombo.txtString get]}
    bind $w <Escape> "destroy $w"
    if [info exists convert_cmd($m)] {
        $combo insert end "$convert_cmd($action)"
    }
    if [info exists preview_cmd($m)] {
        $combo insert end "$preview_cmd($action)"
    } else {
        $combo insert end "$module($action)"
    }
    
    focus -force $combo
}

proc RunConverter {string} {
    global module
    destroy .cmd
    set pipe [open "|$module(latex2html) $string" "r"]
    fileevent $pipe readable [list EndProc latex2html $pipe]
    fconfigure $pipe -buffering none -blocking no
}

