###########################################################
#                Tcl/Tk Project Manager                   #
#                    version 0.0.1                        #
#                  TCL highlight file                     #
# Copyright (c) "CONERO lab", 2001, http://conero.lrn.ru  #
# Author: Sergey Kalinin (aka BanZaj) banzaj@lrn.ru       #
###########################################################

proc HighLightTEX {text line lineNumber node} {
    global tree color noteBook
    global editor
    $text tag configure bold -font $editor(fontBold)
    $text tag configure procName -font $editor(fontBold) -foreground $color(procName)
    $text tag configure param -foreground $color(param)
    $text tag configure subParam -foreground $color(subParam)
    
    $text tag configure keyWord -foreground $color(keyWord)
    $text tag configure comments -foreground $color(comments)
    $text tag configure variable -foreground $color(var)
    $text tag configure string -foreground $color(string)
    $text tag configure brace -foreground $color(brace)
    $text tag configure percent -foreground $color(percent)
    $text tag configure bindKey -foreground $color(bindKey)
    $text tag configure lightBracket -background $color(braceBG) -foreground $color(braceFG)
    
    set startIndex 0
    set keyWord [info commands]
    # for OOP extention
    foreach n {class method attribute constructor destructor invariant attribute binding new delete} {
        lappend keyWord $n
    }
    set startPos 0
    set workLine $line
    regexp -nocase -all -- {(\\)([a-zA-Z])*} string match v1 v2
    while {$workLine != ""} {
        if {[regexp -nocase -all {(\\)([a-zA-Z])*} $workLine a b c]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start $startPos
            incr end $startPos
            $text tag add keyWord $lineNumber.$start $lineNumber.$end
            set startPos $end
        } else {
            break
        }        
    }
    # string " " highlight
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "\".*?\"" $workLine a b]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start $startPos
            incr end $startPos
            $text tag add string $lineNumber.$start $lineNumber.$end
            set startPos $end
        } else {
            break
        }        
    }
   set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp {\{.*?\}} $workLine a b]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start [expr $startPos +1]
            incr end [expr $startPos - 1]
            $text tag add param $lineNumber.$start $lineNumber.$end
            set startPos $end
        } else {
            break
        }        
    }
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp {\[.*?\]} $workLine a b]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start [expr $startPos + 1]
            incr end [expr $startPos - 1]
            $text tag add subParam $lineNumber.$start $lineNumber.$end
            set startPos $end
        } else {
            break
        }        
    }
    # add comment #
    if [regexp -nocase -all -indices -- {%} $line pos] {
        set cur [lindex $pos 1]
        $text tag add comments $lineNumber.$cur $lineNumber.end
        return 0
    }
}










