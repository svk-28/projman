###########################################################
#                Tcl/Tk Project Manager                   #
#                    version 0.0.1                        #
#                  TCL highlight file                     #
# Copyright (c) "Sergey Kalinin", 2001, http://nuk-svk.ru  #
# Author: Sergey Kalinin banzaj28@yandex.ru       #
###########################################################

proc HighLightHTML {text line lineNumber node} {
    global fontNormal editorFontBold tree imgDir fontBold
    global editor color
    set startIndex 0
    # bind text tags for highlightning #
    $text tag configure bold -font $editor(fontBold)
    $text tag configure procName -font $editor(fontBold) -foreground $color(procName)
    $text tag configure keyWord -foreground $color(keyWord)
    $text tag configure comments -foreground $color(comments)
    $text tag configure variable -foreground $color(var)
    $text tag configure string -foreground $color(string)
    $text tag configure braceHighLight -font $editor(fontBold)\
    -foreground  $color(braceBG) -background $color(braceFG)
    $text tag configure brace -foreground $color(brace)
    $text tag configure percent -foreground $color(percent)
    $text tag configure bindKey -foreground $color(bindKey)
#    incr lineNumber
    set keyWord [info commands]
    # for OOP extention
    foreach n {class method attribute constructor destructor invariant attribute binding new delete} {
        lappend keyWord $n
    }
    # add comment #
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "<\!--.+-->" $workLine a]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start $startPos
            incr end $startPos
            $text tag add coments $lineNumber.$start $lineNumber.$end
            set startPos $end
        } else {
            break
        }        
    }
    # get keywords
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "(</?\[a-zA-Z0-9\]+\[> \t\])|>" $workLine a]} {
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
    # get variables
    set workLine $line
    set startPos 0
    while {$workLine != ""} {
        if {[regexp "\[a-zA-Z0-9\]+=" $workLine a]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start $startPos
            incr end $startPos
            $text tag add variable $lineNumber.$start $lineNumber.$end
            set startPos $end
        } else {
            break
        }        
    }
    # get strings
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "\".+\"" $workLine a]} {
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

}






