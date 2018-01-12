###########################################################
#                Tcl/Tk Project Manager                   #
#                Distrubuted under GPL                    #
# Copyright (c) "CONERO lab", 2002, http://conero.lrn.ru  #
# Author: Sergey Kalinin (aka BanZaj) banzaj@lrn.ru       #
###########################################################
#                AutoCompletition Procedure               #
#                    Author Alex DEDERER                  #
###########################################################

proc auto_completition { widget } {
    set start_word [$widget get "insert - 1 chars wordstart" insert]
    set box        [$widget bbox insert]
    set box_x      [expr [lindex $box 0] + [winfo rootx $widget] ]
    set box_y      [expr [lindex $box 1] + [winfo rooty $widget] + [lindex $box 3] ] 
    
    set cnt 0
    set pos "1.0"
    set last_pos ""
    set pattern "$start_word\\w*"
    #set pattern ""
    
    set list_word($start_word) 1
    while { ([set start [$widget search -count cnt -regexp -- $pattern $pos end]] != "") } {
        set word [$widget get $start "$start + $cnt chars"]
        if { ![string equal $start_word $word] }  { set list_word($word) 1 }
        set pos [$widget index "$pos + [expr $cnt + 1] chars"]
        if { [string equal $last_pos $pos] } { break }
        set last_pos $pos
    } ;# while
    
    bindtags $widget [list CompletitionBind [winfo toplevel $widget] $widget Text sysAfter all]
    bind CompletitionBind <Escape>  "bindtags $widget {[list [winfo toplevel $widget] $widget Text sysAfter all]}; catch { destroy .aCompletition }"
    bind CompletitionBind <Key>     { auto_completition_key %W %K %A ; break}
    eval auto_completition_win $box_x $box_y [array names list_word]
} ;# proc auto_completition

## PROCEDURE LIST        ##
## by BanZaj             ##

proc auto_completition_proc { widget } {
    global procList activeProject noteBook varList
    set nodeEdit [$noteBook raise]
    if {$nodeEdit == "" || $nodeEdit == "newproj" || $nodeEdit == "about" || $nodeEdit == "debug"} {
        return
    }
    set start_word [$widget get "insert - 1 chars wordstart" insert]
    set box        [$widget bbox insert]
    set box_x      [expr [lindex $box 0] + [winfo rootx $widget] ]
    set box_y      [expr [lindex $box 1] + [winfo rooty $widget] + [lindex $box 3] ] 
    
    set cnt 0
    set pos "1.0"
    set last_pos ""
    puts "$start_word"
    puts [regsub -all -- "\$" $start_word "\\\$" word]
    puts $word
    #set list_word($start_word) 1
    if {[string index $start_word 0] == "\$"} {
        set workList $varList($activeProject)
    } else {
        set workList $procList($activeProject)
    }
    if [info exists workList] {
        set len [llength $workList]
    } else {
        return
    }
    set i 0
    while {$len >=$i} {
        set line [lindex $ $i]
        scan $line "%s" word
        if {[string match "$start_word*" $word]} {
            set list_word($word) $i
        }
        incr i
    }
    bindtags $widget [list CompletitionBind [winfo toplevel $widget] $widget Text sysAfter all]
    bind CompletitionBind <Escape>  "bindtags $widget {[list [winfo toplevel $widget] $widget Text sysAfter all]}; catch { destroy .aCompletition }"
    bind CompletitionBind <Key>     {auto_completition_key %W %K %A ; break}
    eval auto_completition_win $box_x $box_y [array names list_word]
} ;# proc auto_completition_proc


proc auto_completition_win { x y args} {
    set win .aCompletition
    if { [winfo exists $win] }  { destroy $win }
    toplevel $win
    wm transient $win .
    wm overrideredirect $win 1
    
    listbox $win.lBox -width 30 -border 2 -yscrollcommand "$win.yscroll set" -border 1
    scrollbar $win.yscroll -orient vertical -command  "$win.lBox yview" -width 13 -border 1
    pack $win.lBox -expand true -fill y -side left
    pack $win.yscroll -side left -expand false -fill y
    
    foreach { word } $args {
        $win.lBox insert end $word
    } ;# foreach | insert all word 
    
    catch { $win.lBox activate 0 ; $win.lBox selection set 0 0 }
    
    if { [set height [llength $args]] > 10 } { set height 10 }
    $win.lBox configure -height $height
    
    bind $win      <Escape> " destroy $win "
    bind $win.lBox <Escape> " destroy $win "
    
    wm geom $win +$x+$y
} ;# auto_completition_win



proc auto_completition_key { widget K A } {
    set win .aCompletition
    set ind [$win.lBox curselection]
    
    switch -- $K {
        Prior   {
            set up   [expr [$win.lBox index active] - [$win.lBox cget -height]]
            if { $up < 0 } { set up 0 }
            $win.lBox activate $up
            $win.lBox selection clear 0 end
            $win.lBox selection set $up $up
        }
        Next    {
            set down [expr [$win.lBox index active] + [$win.lBox cget -height]]
            if { $down >= [$win.lBox index end] }  { set down end }
            $win.lBox activate $down
            $win.lBox selection clear 0 end
            $win.lBox selection set $down $down
        }
        Up      {
            set up   [expr [$win.lBox index active] - 1]
            if { $up < 0 } { set up 0 }
            $win.lBox activate $up
            $win.lBox selection clear 0 end
            $win.lBox selection set $up $up
        }
        Down    {
            set down [expr [$win.lBox index active] + 1]
            if { $down >= [$win.lBox index end] }  { set down end }
            $win.lBox activate $down 
            $win.lBox selection clear 0 end 
            $win.lBox selection set $down $down 
        }
        Return  {
            $widget delete "insert - 1 chars wordstart" "insert wordend - 1 chars"
            $widget insert "insert" [$win.lBox get [$win.lBox curselection]]
            eval [bind CompletitionBind <Escape>]
        }
        default {
            $widget insert "insert" $A
            eval [bind CompletitionBind <Escape>] 
        }
    }
} ;# proc auto_completition_key




















