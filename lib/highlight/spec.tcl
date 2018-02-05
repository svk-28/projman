###########################################################
#                Tcl/Tk Project Manager                   #
#                    version 0.0.1                        #
#                  SPEC highlight file                    #
# Copyright (c) "Sergey Kalinin", 2001, http://nuk-svk.ru  #
# Author: Sergey Kalinin banzaj28@yandex.ru       #
###########################################################

proc HighLightSPEC {text line lineNumber node} {
    global fontNormal editorFontBold fontBold tree imgDir noteBook
    global editor color
#    set pos [$text index insert]
#    set lineNumber [lindex [split $pos "."] 0]

    set startIndex 0
    # bind text tags for highlightning #
#    foreach tag {bold procName comments string number variable} {
#        $text tag remove $tag $lineNumber.0 $lineNumber.end
#    }

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
#    $text tag configure bold -font $fontBold
#    $text tag configure procName -font $editorFontBold -foreground blue
#    $text tag configure keyWord -foreground #0000a8
#    $text tag configure comments -foreground #9b9b9b
#    $text tag configure variable -foreground #e50000
#    $text tag configure string -foreground #168400
#    $text tag configure braceHighLight -font $editorFontBold -foreground green -background black
#    $text tag configure brace -foreground brown
#    $text tag configure percent -foreground #a500c6

    foreach n {define name version release description prep setup build install post postun clean files defattr changelog doc} {
        lappend keyWord $n
    }
    # add comment #
    if {[string range [string trim $line] 0 0] == "#"} {
        $text tag add comments $lineNumber.0 $lineNumber.end
        return 0
    }

    set a ""
    regexp "^( |\t|\%)*(\[a-z\]|\[A-Z\]|\[0-9\]|_|:|~|\\.|/)+" $line a
    if {$a != ""} {
        # gets name
        set b ""
        regexp "^( |\t|\%)*" $line b
        set nameStart [string length $b]
        set nameEnd [string length $a]
        set name [string range $a [string length $b] end]
        # is it keyword?
        if {[lsearch $keyWord $name] != -1} {
            incr nameStart $startIndex
            incr nameEnd $startIndex
            $text tag add keyWord $lineNumber.$nameStart $lineNumber.$nameEnd
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
    # string { } highlight
    set startPos 0
    set workLine $line
    while {$workLine != ""} {
        if {[regexp "\{.*?\}" $workLine a b]} {
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
    #find [
#    set i [string first "\[" $line]
#    if {$i != -1} {
#        incr i
#        set line [string range $line $i end]
#            incr i $startIndex
#        set l [HighLight $text $line $i $node]
#        eval lappend res $l
#    }
    
#    return $res
    
}



