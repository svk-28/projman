###########################################################
#                Tcl/Tk Project Manager                   #
#                    version 0.0.1                        #
#                  TCL highlight file                     #
# Copyright (c) "Sergey Kalinin", 2001, http://nuk-svk.ru  #
# Author: Sergey Kalinin banzaj28@yandex.ru       #
###########################################################
set beginQuote "0.0"
set endQuote "2.0"
set endQuotePrev "0.0"
proc HighLightRUBY {text line lineNumber node} {
    global fontNormal fontBold editorFontBold tree imgDir noteBook
    global editor color
    global beginQuote endQuote endQuotePrev
    set startIndex 0
    
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
    $text tag configure sql -font $editor(fontBold) -foreground $color(sql)
    
    set keyWord [info commands]
    # for OOP extention
    foreach n {class method attribute constructor destructor invariant attribute binding new delete extends final finally implements import interface native new private protected public static super this throw synchronized throws transient try volatile void else def end slots require} {lappend keyWord $n}
    set dataType {list abstract boolean byte char double float int long short}
    set sqlOperators {select from where and or count sum in order cast as by}
    set a ""
    set startPos 0
    set endPos 0
    set length 0
    set workLine $line
    set className ""
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
            if {[string trim $word]=="class"} {
                $text tag add procName $lineNumber.[expr $startPos + $length] $lineNumber.[string wordend $line [expr $startPos + $length +2]]
                puts "$text tag add procName $lineNumber.[expr $startPos + $length] $lineNumber.[string wordend $line [expr $startPos + $length +2]]"
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
        if {[regexp "<.*?>" $workLine a b]} {
            set start [string first $a $workLine]
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
    # variable highlight #
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "\\@\[a-zA-Z\\_:\]+" $workLine a]} {
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
    # persent % highlight
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        #        if {[regexp "\%.*? " $workLine a b]}
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
    ## COMENTS ##
    # add comment #
    set workLine [$text get $lineNumber.0 $lineNumber.end]
    if {[regexp -indices "(^|\t|;| )#" $workLine word]} {
        set p [lindex $word 1]
        $text tag add comments $lineNumber.$p $lineNumber.end
    } else {
        $text tag remove comments $lineNumber.0 $lineNumber.end
    }
    
    # DEDERER
    # hightlight [, {, }, ], ( , )
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
}









