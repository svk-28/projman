proc AlignSelectedText_ {text} {
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

proc AlignSelectedTextBySymbol {text {splitChar "|"}} {
    global cfgVariables
    set i 1
    set tabSize $cfgVariables(tabSize)
    set addLeading 0

    foreach line [split [string map {"\r\n" "\n"} $text] "\n"] {
        if {$i == 1} {
            regexp -nocase -- {^(\s*)} $line -> space
            set indentLength [string length $space]
            set steps [expr {int(ceil(double($indentLength) / $tabSize))}]
            set indentCount [expr {$steps * $tabSize}]
            set indent [string repeat " " $indentCount]

            # Определяем, есть ли разделитель в начале строки
            set trimmed [string trimleft $line]
            if {$splitChar ne " " && [string match "${splitChar}*" $trimmed]} {
                set addLeading 1
            }
        }

        # Разбор строки 
        if {$splitChar eq " "} {
            set words [regexp -all -inline {\S+} $line]
        } else {
            set words [lmap w [split $line $splitChar] {
                string trim $w
            }]
            set words [lsearch -all -inline -not -exact $words ""]
        }

        foreach word $words {
            lappend lst($i) $word
        }
        incr i
    }

    # Подсчёт ширин
    foreach index [array names lst] {
        set listLength [llength $lst($index)]
        for {set i 0} {$i < $listLength} {incr i} {
            set word [lindex $lst($index) $i]
            set wordLength [string length $word]
            if ![info exists maxLength($i)] {set maxLength($i) $wordLength}
            if {$wordLength > $maxLength($i)} {set maxLength($i) $wordLength}
        }
    }

    set textOut ""
    foreach index [lsort -integer [array names lst]] {
        set wordOut "$indent"
        set listLength [llength $lst($index)]
        for {set i 0} {$i < $listLength} {incr i} {
            set word [lindex $lst($index) $i]
            set wordLength [string length $word]
            set indentCount [expr $maxLength($i) - $wordLength]

            if {$addLeading} {
                append wordOut "$splitChar $word[string repeat " " [expr $indentCount + 1]]"
            } else {
                if {$i > 0} {
                    append wordOut "$splitChar "
                }
                append wordOut "$word[string repeat " " [expr $indentCount + 1]]"
            }
        }
        append textOut "[string trimright $wordOut]\n"
    }
    return $textOut
}

proc AlignSelectedTextBySpace {{w ""}} {
    ProcessSelection ExecuteAlignSelectedTextBySpace $w
}

proc ExecuteAlignSelectedTextBySpace {text} {
    return [AlignSelectedTextBySymbol $text " "]
}

proc AlignSelectedTextByBar {{w ""}} {
    ProcessSelection ExecuteAlignSelectedTextByBar $w
}

proc ExecuteAlignSelectedTextByBar {text} {
    return [AlignSelectedTextBySymbol $text "|"]
}

proc AlignSelectedTextBySemi {{w ""}} {
    ProcessSelection ExecuteAlignSelectedTextBySemi $w
}

proc ExecuteAlignSelectedTextBySemi {text} {
    return [AlignSelectedTextBySymbol $text ";"]
}

