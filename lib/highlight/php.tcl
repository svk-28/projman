###########################################################
#                Tcl/Tk Project Manager                   #
#                    version 0.0.1                        #
#                   TCL highlight file                     #
# Copyright (c) "Sergey Kalinin", 2001, http://nuk-svk.ru  #
# Author: Sergey Kalinin banzaj28@yandex.ru       #
###########################################################

proc HighLightPHP {text line lineNumber node} {
    global fontNormal fontBold editorFontBold tree imgDir noteBook
    global editor color
    global beginQuote endQuote endQuotePrev
    #    set pos [$text index insert]
    #    set lineNumber [lindex [split $pos "."] 0]
    
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
    $text tag configure rivet -foreground $color(bindKey) -font $editor(fontBold) -foreground "#ff8800" ;#-background "#c6c6c6"
    $text tag configure sql -font $editor(fontBold) -foreground $color(sql)
    #    incr lineNumber
    set keyWord [info commands]
    # for OOP extention
    foreach n {class method attribute constructor destructor invariant attribute binding new delete \
    mcset mc mclocale mcpreferences mcload mcunknown configure match else elseif} {
        lappend keyWord $n
    }
    foreach n {var include_once include function case echo select from where in order by and or} {
        lappend keyWord $n
    }
    set dataType {true false}
    set sqlOperators {select from where and or count sum in order cast as by}
    set a ""
    set startPos 0
    set endPos 0
    set length 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "(^|\t| )\[a-zA-Z\\_:\]+" $workLine word]} {
            set length [string length $word]
            set startPos [string first [string trim $word] $line]
            set endPos [expr $startPos + $length]
            set workLine [string range $workLine $length end]
            if {[lsearch $keyWord [string trim $word]] != -1} {
                $text tag add keyWord $lineNumber.$startPos $lineNumber.$endPos
            }
            if {[lsearch $dataType [string trim $word]] != -1} {
                $text tag add bold $lineNumber.$startPos $lineNumber.$endPos
            }            
            if {[lsearch $sqlOperators [string trim $word]] != -1} {
                $text tag add sql $lineNumber.$startPos $lineNumber.$endPos
            }
            if {[string trim $word]=="proc"} {
                $text tag add procName $lineNumber.[expr $startPos + $length] $lineNumber.[string wordend $line [expr $startPos + $length +2]]
            }
            set startPos [expr $endPos + 1]
        } else {
            break
        }
    }
    set workLine $line
    while {$workLine != ""} {
        if {[regexp {(\{|\[)[a-zA-Z\\_:]+} $workLine word v]} {
            set word [string trim $word $v]
            set length [string length $word]
            set startPos [string first [string trim $word] $line]
            set endPos [expr $startPos + $length]
            set workLine [string range $workLine $length end]
            if {[lsearch $keyWord [string trim $word]] != -1} {
                $text tag add keyWord $lineNumber.$startPos $lineNumber.$endPos
            }
            if {[string trim $word]=="proc"} {
                $text tag add procName $lineNumber.[expr $startPos + $length] $lineNumber.[string wordend $line [expr $startPos + $length +2]]
            }
            set startPos [expr $endPos + 1]
        } else {
            break
        }
    }
    
    # key binding highlight
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
    # variable highlight #
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "\\$\[a-zA-Z\\_:\]+" $workLine a]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start $startPos
            incr end $startPos
            if {$a != ""} {
                $text tag add variable $lineNumber.$start $lineNumber.$end
            }
            set startPos $end
        } else {
            break
        }        
    }
    # persent % highlight
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "\%" $workLine a b]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start $startPos
            incr end $startPos
            $text tag add percent $lineNumber.$start $lineNumber.$end
            set startPos $end
        } else {
            break
        }        
    }
    # DEDERER
    # hightlight [, {, }, ]
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp {\(|\[|{|}|\]|\)} $workLine a b]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start $startPos
            incr end $startPos
            $text tag add bold $lineNumber.$start $lineNumber.$end
            set startPos $end
        } else {
            break
        }
    }
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp {\<\?|\?>} $workLine a b]} {
            set start [string first $a $workLine]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start $startPos
            incr end $startPos
            $text tag add rivet $lineNumber.$start $lineNumber.end
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
    # parameter for command hightlight
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp -- {\s-\w+(?=\s)} $workLine a b]} {
            set start [expr [string first $a $workLine] + 1]
            set end $start
            incr end [string length $a]
            set workLine [string range $workLine $end end]
            incr start $startPos
            incr end $startPos
            $text tag add bindKey $lineNumber.$start $lineNumber.$end
            set startPos $end
        } else {
            break
        }
    }
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "<!.+>" $workLine a]} {
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
    # add comment #
    
    set workLine [$text get $lineNumber.0 $lineNumber.end]
    if {[regexp -indices "(^|\t|;| )//" $workLine begin]} {
        set p [lindex $begin 0]
        $text tag add comments $lineNumber.[expr $p - 0] $lineNumber.end
    } elseif {[regexp -indices {(^|\t|;| )/\*} $workLine beginIndex]} {
        set beginQuote "$lineNumber.[lindex $beginIndex 0]"
        set endQuote [$text search -forward -regexp -- {\*/} $beginQuote end]
        if {$endQuote != ""} {
            $text tag add comments $beginQuote "$endQuote + 2 chars"
        } else {
            $text tag add comments $beginQuote end
        }
        set endQuotePrev [$text search -backward -regexp -- {\*/} [expr $lineNumber - 1].end 0.0]
        if {$endQuotePrev != ""} {
            $text tag remove comments "$endQuotePrev + 2 chars" $beginQuote
        }
    } elseif {[regexp -indices {\*/} $workLine endIndex]} {
        set endQuote "$lineNumber.[lindex $endIndex 1]"
        set beginQuote [$text search -backward -regexp -- {/\*} $endQuote 0.0]
        if {$beginQuote != ""} {
            $text tag add comments $beginQuote "$endQuote + 1 chars"
        } else {
            $text tag add comments 0.0 "$endQuote + 1 chars"
        }
        set beginQuoteNext [$text search -forward -regexp -- {/\*} $endQuote end]
        if {$beginQuoteNext != ""} {
            $text tag remove comments "$endQuote + 2 chars" $beginQuoteNext
        }
    } else {
        if {[lindex [split $beginQuote "."] 0] <= $lineNumber && [lindex [split $endQuote "."] 0] >= $lineNumber} {
            #$text tag add comments $lineNumber.0 $lineNumber.end
        } else {
            $text tag remove comments $lineNumber.0 $lineNumber.end
        }
    }
}




