######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022-2026, https://nuk-svk.ru
######################################################
#
# The markdown file viewer
#
######################################################

proc ShowMD {fileFullPath {reload "false"}} {
    global cfgVariables

    set win .viewer
    if {$reload eq "false"} {
        set parentGeometry [wm geometry .]
        set parentWidth [winfo width .]
        set parentHeight [winfo height .]
        set parentX [winfo x .]
        set parentY [winfo y .]
        
        # Устанавливаем размеры нового окна (меньше на 200)
        set newWidth [expr {$parentWidth - 200}]
        set newHeight [expr {$parentHeight - 200}]
        
        # Вычисляем позицию для центрирования относительно родительского окна
        set x [expr {$parentX + ($parentWidth - $newWidth) / 2}]
        set y [expr {$parentY + ($parentHeight - $newHeight) / 2}]
        
        # Применяем геометрию
    
        if { [winfo exists $win] }  { destroy $win; return false }
        toplevel $win
        # wm title $win "[::msgcat::mc "Help"]"
        wm title $win $fileFullPath
        wm geometry $win ${newWidth}x${newHeight}+${x}+${y}
        wm overrideredirect $win 0
        
        set frm [ttk::frame $win.frmHelp]
        pack $frm -expand 1 -fill both
        
        set txt [text $frm.txt -wrap $cfgVariables(editorWrap) -background $cfgVariables(textBG) \
            -xscrollcommand "$win.h set" -yscrollcommand "$frm.v set" -font $cfgVariables(viewerFont)]
        pack $txt -side left -expand 1 -fill both
        pack [ttk::scrollbar $frm.v -command "$frm.txt yview"] -side right -fill y
        ttk::scrollbar $win.h -orient horizontal -command "$frm.txt xview"
        if {$cfgVariables(editorWrap) eq "none"} {
            pack $win.h -side bottom -fill x
    
        }
        bind .viewer <Escape> {destroy .viewer}
        
        $txt tag configure h1 -font $cfgVariables(h1Font)
        $txt tag configure h2 -font $cfgVariables(h2Font)
        $txt tag configure h3 -font $cfgVariables(h3Font)
        $txt tag configure h4 -font $cfgVariables(h4Font)
        $txt tag configure h5 -font $cfgVariables(h5Font)
        $txt tag configure h6 -font $cfgVariables(h6Font)
        $txt tag configure mdList -font $cfgVariables(mdListFont)
        $txt tag configure codeBlock -foreground $cfgVariables(codeBlockFG) \
            -background $cfgVariables(codeBlockBG) -font $cfgVariables(codeBlockFont)
        $txt tag configure italic -font $cfgVariables(italicFont)
        $txt tag configure bold -font $cfgVariables(boldFont)
        $txt tag configure italicBold -font $cfgVariables(italicBoldFont)
        $txt tag configure link -foreground $cfgVariables(linkFG) -font $cfgVariables(linkFont)
        $txt tag configure quote -background $cfgVariables(codeBlockBG)
    } else {
        set txt .viewer.frmHelp.txt
        $txt delete 0.0 end
    }
    set codeBlockBegin false

    set f [open "$fileFullPath" r]
    set lineNumber 0
    while {[gets $f line] >= 0} {
        # puts $line
        if {$line eq ""} {
            if {$codeBlockBegin eq "true"} {
                $txt insert end "\n" codeBlock
            } else {
                $txt insert end "\n"
            }
            incr lineNumber
            continue
        }
        set result [MarkDownParser $line]
        # puts $result
        set textTag [lindex $result 0]
        if {$textTag eq "codeBlock" && $codeBlockBegin eq "false"} {
            set codeBlockBegin true
        } elseif {$textTag eq "codeBlock" && $codeBlockBegin eq "true"} {
            set codeBlockBegin false
        }
        if {$codeBlockBegin eq "true"} {
            set textTag "codeBlock"
        }
        if {$textTag eq "" && $codeBlockBegin eq "false"} {
            $txt insert end "[lindex $result 1]\n"
        } elseif {$textTag eq "codeBlockOneString"} {
            ProcessLineWithCode $line $txt
        } elseif {$textTag eq "mdList"} {
            $txt insert end "  $cfgVariables(listSymbol) [lindex $result 1]\n"
        } elseif {$textTag eq "breakTheLine"} {
            $txt insert end "[lindex $result 1]\n\n"
        } elseif {$textTag eq "link"} {
            ProcessLineWithURL $line $txt $result
        } elseif {$textTag eq "markable"} {
            ProcessLineWithMark $line $txt $result
        } elseif {$textTag eq "quote"} {
            set symList [split [lindex $result 2] ">"]
            for {set i 1} { $i < [llength $symList]} {incr i} {
                $txt insert end " " quote
                $txt insert end "  "
            }
            $txt insert end [lindex $result 1]\n
        } else {
            $txt insert end "[lindex $result 1]\n" $textTag
        }
        incr lineNumber
    }
    close $f
}

proc ProcessLineWithCode {line txt} {
    set codeBlocks [ExtractCodeBlocks $line {`{1,3}([^`]+)`{1,3}}]
    
    if {[llength $codeBlocks] == 0} {
        $txt insert end "$line\n"
        return
    }
    
    set lastPos 0
    
    foreach block $codeBlocks {
        # Извлекаем данные из блока
        set fullMatch   [lindex $block 0]
        set codeText    [lindex $block 1]
        set matchPos    [lindex $block 2]
        set codePos     [lindex $block 3]
        
        set start       [lindex $matchPos 0]
        set end         [lindex $matchPos 1]
        
        # Вставляем текст перед кодом
        if {$start > $lastPos} {
            set textBefore [string range $line $lastPos [expr {$start - 1}]]
            $txt insert end $textBefore
        }
        
        # Вставляем код с соответствующим тегом
        if {[string match "```*" $fullMatch]} {
            $txt insert end $codeText codeBlock
        } else {
            $txt insert end $codeText code_inline
        }
        
        set lastPos [expr {$end + 1}]
    }
    
    # Вставляем остаток строки
    if {$lastPos < [string length $line]} {
        $txt insert end [string range $line $lastPos end]
    }
    
    $txt insert end "\n"
}

# Функция вставки ссылки
proc InsertLink {txt link url} {
    global cfgVariables
    set tag [format "link_%d" [incr ::link_counter]]
    $txt insert end $link $tag
    $txt tag configure $tag -foreground $cfgVariables(linkFG) -font $cfgVariables(linkFont)
    $txt tag bind $tag <Button-1> [list OpenURL $url]
    # $txt tag bind $tag <Enter> [list $txt configure -cursor hand2]
    $txt tag bind $tag <Enter> [list InsertLinkEnter $txt $tag $url]
    $txt tag bind $tag <Leave> [list InsertLinkLeave $txt]
    # $txt tag bind $tag <Leave> [list InsertLinkLeave $txt $tag]
    # $txt tag bind $tag <Enter> [list %W tag configure $tag -foreground red]
    # $txt tag bind $tag <Leave> [list %W tag configure $tag -foreground blue]
}

proc InsertLinkEnter {txt tag url} {
    $txt configure -cursor hand2
    # Показываем подсказку с URL
    ShowTooltip $txt $url
}

proc InsertLinkLeave {txt} {
    if [winfo exists .baloonTip] {destroy .baloonTip}
    $txt configure -cursor ""
}

proc ProcessLineWithURL {line txt urlList} {
    if {[llength $urlList] == 0} {
        $txt insert end "$line\n"
        return
    }
    set resultLine ""
    set lastPos 0
    foreach url [lindex $urlList 1] {
        set start [lindex [lindex $url 1] 0]
        set end [lindex [lindex $url 1] 1]
        set linkName [lindex [lindex $url 2] 0]
        # set linkStart [lindex [lindex $url 2] 1]
        # set linkEnd [lindex [lindex $url 2] 2]
        set urlName [lindex [lindex $url 3] 0]
        # set urlStart [lindex [lindex $url 3] 1]
        # set urlEnd [lindex [lindex $url 3] 2]
        # Вставляем текст перед ссылкой
        if {$start > $lastPos} {
            set textBefore [string range $line $lastPos [expr {$start - 1}]]
            $txt insert end $textBefore
        }
        # $txt insert end $linkName link
        InsertLink $txt $linkName $urlName
        set lastPos [expr {$end + 1}]
    }

    # Вставляем остаток строки
    if {$lastPos < [string length $line]} {
        $txt insert end [string range $line $lastPos end]
    }
    
    $txt insert end "\n"
}

proc ProcessLineWithMark {line txt textList} {
    if {[llength $textList] == 0} {
        $txt insert end "$line\n"
        return
    }
    set resultLine ""
    set lastPos 0
    foreach record [lindex $textList 1] {
        set start [lindex [lindex $record 2] 0]
        set end [lindex [lindex $record 2] 1]
        set markableText [lindex $record 1]

        # Вставляем текст перед ссылкой
        if {$start > $lastPos} {
            set textBefore [string range $line $lastPos [expr {$start - 1}]]
            $txt insert end $textBefore
        }
        switch [lindex $record 4] {
            "*"  {set tag italic}
            "**" {set tag bold}
            "***" {set tag italicBold}
            "_"  {set tag italic}
            "__" {set tag bold}
            "___" {set tag italicBold}
        }
        $txt insert end " $markableText" $tag
        set lastPos [expr {$end + 1}]
    }

    # Вставляем остаток строки
    if {$lastPos < [string length $line]} {
        $txt insert end [string range $line $lastPos end]
    }
    
    $txt insert end "\n"
}

proc MarkDownParser {line} {
    # Title
    # [regexp -nocase -line -- {^(#{1,6})\s\w+} $line match sharp]
    if [regexp -nocase -all -line -- {^(#{1,6})\s(.+)} $line match sharp title] {
        set titlePrefixLength [string length $sharp]
        switch $titlePrefixLength {
            1 {return [list h1 "$title"]}
            2 {return [list h2 "$title"]}
            3 {return [list h3 "$title"]}
            4 {return [list h4 "$title"]}
            5 {return [list h5 "$title"]}
            6 {return [list h6 "$title"]}
        }
    }
    # Lists
    if [regexp -nocase -all -line -- {^\s*(\*|-|\+)\s(.+)} $line match symbol textLine] {
        # puts $textLine
        return [list mdList "$textLine"]
    }

    # Multi-line code block
    if [regexp -nocase -all -line -- {^```(\w*)} $line match lang] {
        return [list codeBlock {}]
    }

    # One string code blockregexp -nocase -all -line -- {(`{1,3}([^`]+)`{1,3})} string match v1 v2
    
    if [regexp -nocase -all -line -- {`{1,3}([^`]+)`{1,3}} $line match v1 code v2] {
        # puts $line
        set result [ExtractCodeBlocks $line {`{1,3}([^`]+)`{1,3}}]
        # puts "$v1, $code, $v2"
        # puts "$result"
        return [list codeBlockOneString $result]
    }
    # Line break (\, <br>, "  ")
    if [regexp -nocase -all -line -linestop -- {(.*)(\B|<br>| {2,})$} $line match v1 v2] {
        return [list breakTheLine $v1]
    }
    # Italic text
    if [regexp -nocase -all -line -linestop -- {(^|\s+)(_{1,3}|\*{1,3})([^_\*]+)(_{1,3}|\*{1,3})} $line match v1 v2 v3 v4] {
        set result [ExtractBlocks $line {(^|\s+)(_{1,3}|\*{1,3})([^_\*]+)(_{1,3}|\*{1,3})}]
        return [list markable $result]
    }
    # URL (link) parser
    if [regexp -nocase -all -line -linestop -- {\[([^\]]+)\]\(([^)]+)\)} $line match v1 v2] {
        set result [ExtractURL $line {\[([^\]]+)\]\(([^)]+)\)}]
        return [list link $result]
    }
    # Quoted text
    if [regexp -nocase -line -- {(^>(?:>|\s)*)(.*)$} $line match v1 v2] {
        puts "Quoted text $match"
        return [list quote $v2 $v1]
    }

    return [list {} $line]

}

proc ExtractCodeBlocks {line pattern} {
    # set pattern {`{1,3}([^`]+)`{1,3}}
    set result {}
    
    # Ищем все вхождения
    set pos 0
    while {[regexp -indices -start $pos -- $pattern $line match code]} {
        set start [lindex $match 0]
        set end [lindex $match 1]
        set codeStart [lindex $code 0]
        set codeEnd [lindex $code 1]
        
        # Получаем текст кода без кавычек
        set codeText [string range $line $codeStart $codeEnd]
        
        # Получаем полный текст с кавычками
        set fullMatch [string range $line $start $end]
        
        lappend result [list $fullMatch $codeText [list $start $end] [list $codeStart $codeEnd]]
        
        set pos [expr {$end + 1}]
    }
    return $result
}

proc ExtractURL {line pattern} {
    set result {}
    
    # Ищем все вхождения
    set pos 0
    while {[regexp -indices -start $pos -- $pattern $line match link url]} {
        set start [lindex $match 0]
        set end [lindex $match 1]
        set linkStart [lindex $link 0]
        set linkEnd [lindex $link 1]
        set urlStart [lindex $url 0]
        set urlEnd [lindex $url 1]
        
        # Получаем текст ссылки без кавычек
        set linkText [string range $line $linkStart $linkEnd]
        # Получаем текст url без кавычек
        set urlText [string range $line $urlStart $urlEnd]
        
        # Получаем полный текст с кавычками
        set fullMatch [string range $line $start $end]
        
        lappend result [list $fullMatch [list $start $end] [list $linkText $linkStart $linkEnd] [list $urlText $urlStart $urlEnd]]
        
        set pos [expr {$end + 1}]
    }
    
    return $result
}

proc ExtractBlocks {line pattern} {
    set result {}
    
    # Ищем все вхождения
    set pos 0
    while {[regexp -indices -start $pos -- $pattern $line match v1 blockSymbolBegin code blocSymbolEnd]} {
        set start [lindex $match 0]
        set end [lindex $match 1]
        set codeStart [lindex $code 0]
        set codeEnd [lindex $code 1]
        
        # Получаем текст кода без кавычек
        set codeText [string range $line $codeStart $codeEnd]
        
        # Получаем полный текст с кавычками
        set fullMatch [string range $line $start $end]
        
        lappend result [list $fullMatch $codeText [list $start $end] [list $codeStart $codeEnd] [string range $line [lindex $blockSymbolBegin 0] [lindex $blockSymbolBegin 1]]]
        
        set pos [expr {$end + 1}]
    }
    return $result
}
