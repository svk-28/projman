proc AlignSelectedText {text} {
    global cfgVariables
    set i 1
    set tabSize $cfgVariables(tabSize)
    # set lst($i) ""
    foreach line [split [string map {"\r\n" "\n"} $text] "\n"] {
        if {$i == 1} {
            regexp -nocase -- {^(\s*)} $line -> space
            set indentLength [string length $space]
            set steps [expr {int(ceil(double($indentLength) / $tabSize))}]
            set indentCount [expr {$steps * $tabSize}]
            set indent [string repeat " " $indentCount]
        }
        set words [regexp -all -inline {\S+} $line]
        foreach word $words {
            lappend lst($i) $word
        }
        incr i
    }
    foreach index [array names lst]  {
        set listLength [llength $lst($index)]
        for {set i 0} {$i < $listLength} {incr i} {
            set word [lindex $lst($index) $i]
            set wordLength [string length $word]

            if ![info exists maxLength($i)] {set maxLength($i) $wordLength}
            if {$wordLength > $maxLength($i)} {set maxLength($i) $wordLength}
        }
    }
    set textOut ""
    foreach index [lsort -integer [array names lst]]  {
        set wordOut "$indent"
        set listLength [llength $lst($index)]
        for {set i 0} {$i < $listLength} {incr i} {
            set word [lindex $lst($index) $i]
            set wordLength [string length $word]
            set indentCount [expr $maxLength($i) - $wordLength]
            append wordOut "$word[string repeat " " [expr $indentCount + 1]]"
        }
        append textOut "[string trimright $wordOut]\n"
    }
    return $textOut
}

proc AlignSelectedTextByColumns {{w ""}} {
    ProcessSelection AlignSelectedText $w
}
