######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "SVK", 2022, https://nuk-svk.ru
######################################################
# Editor module
######################################################

namespace eval Editor {
    variable selectionTex
    # Set the editor option
    proc SetOption {optionName value} {
        global cfgVariables nbEditor
        # apply changes for opened tabs
        foreach node [$nbEditor tabs] {
            $node.frmText.t configure -$optionName $value
        }
    }
    
    # Comment one string or selected string
    proc Comment {txt fileType} {
        global lexers
        set selIndex [$txt tag ranges sel]
        set pos [$txt index insert]
        set lineNum [lindex [split $pos "."] 0]
        set PosNum [lindex [split $pos "."] 1]

        if [dict exists $lexers $fileType commentSymbol] {
            set symbol [dict get $lexers $fileType commentSymbol]
        } else {
            set symbol "#"
        }
        puts "Select : $selIndex"
        if {$selIndex != ""} {
            set lineBegin [lindex [split [lindex $selIndex 0] "."] 0]
            set lineEnd [lindex [split [lindex $selIndex 1] "."] 0]
            set posBegin [lindex [split [lindex $selIndex 1] "."] 0]
            set posEnd [lindex [split [lindex $selIndex 1] "."] 1]
            if {$lineEnd == $lineNum && $posEnd == 0} {
                set lineEnd [expr $lineEnd - 1]
            }
            for {set i $lineBegin} {$i <=$lineEnd} {incr i} {
                #$txt insert $i.0 "# "
                regexp -nocase -indices -- {^(\s*)(.*?)} [$txt get $i.0 $i.end] match v1 v2
                $txt insert  $i.[lindex [split $v2] 0] "$symbol "
            }
            $txt tag add comments $lineBegin.0 $lineEnd.end
            $txt tag raise comments
        } else {
            regexp -nocase -indices -- {^(\s*)(.*?)} [$txt get $lineNum.0 $lineNum.end] match v1 v2
            $txt insert  $lineNum.[lindex [split $v2] 0] "$symbol "
            $txt tag add comments $lineNum.0 $lineNum.end
            $txt tag raise comments
        }
    }

    # Uncomment one string selected strings
    proc Uncomment {txt fileType} {
        set selIndex [$txt tag ranges sel]
        set pos [$txt index insert]
        set lineNum [lindex [split $pos "."] 0]
        set posNum [lindex [split $pos "."] 1]
        
        if  {[info procs GetComment:$fileType] ne ""} {
            set commentProcedure "GetComment:$fileType"
        } else {
            set commentProcedure {GetComment:Unknown}
        }
        # set commentProcedure "GetComment"
        
        # puts "$fileType, $commentProcedure"
        if {$selIndex != ""} {
            set lineBegin [lindex [split [lindex $selIndex 0] "."] 0]
            set lineEnd [lindex [split [lindex $selIndex 1] "."] 0]
            set posBegin [lindex [split [lindex $selIndex 1] "."] 0]
            set posEnd [lindex [split [lindex $selIndex 1] "."] 1]
            if {$lineEnd == $lineNum && $posEnd == 0} {
                set lineEnd [expr $lineEnd - 1]
            }            
            for {set i $lineBegin} {$i <=$lineEnd} {incr i} {
                set str [$txt get $i.0 $i.end]
                set commentSymbolIndex [$commentProcedure $str]
                if {$commentSymbolIndex != 0} {
                    $txt delete $i.[lindex $commentSymbolIndex 0] $i.[lindex $commentSymbolIndex 1]
                }
            }
            $txt tag remove comments $lineBegin.0 $lineEnd.end
            $txt tag add	sel $lineBegin.0 $lineEnd.end
            $txt highlight $lineBegin.0 $lineEnd.end
        } else {
            set posNum [lindex [split $pos "."] 1]
            set str [$txt get $lineNum.0 $lineNum.end]
            set commentSymbolIndex [$commentProcedure $str]
            if {$commentSymbolIndex != 0} {
                $txt delete $lineNum.[lindex $commentSymbolIndex 0] $lineNum.[lindex $commentSymbolIndex 1]
            }
            $txt tag remove comments $lineNum.0 $lineNum.end
            $txt highlight $lineNum.0 $lineNum.end
        }
    }
    proc GetComment {fileType str} {
        global lexers
        puts [dict get $lexers $fileType commentSymbol]
        if {[dict exists $lexers $fileType commentSymbol] == 0} {
            return
        }
        
        if {[regexp -nocase -indices -- {(^| )([dict get $lexers $fileType commentSymbol]\s)(.+)} $str match v1 v2 v3]} {
            puts "$match, $v1, $v2, $v3"
            return [list [lindex [split $v2] 0] [lindex [split $v3] 0]]
        } else {
            puts "FUCK"
            return 0
        }
    }

    proc GetComment:TCL {str} {
        if {[regexp -nocase -indices -- {(^| )(#\s)(.+)} $str match v1 v2 v3]} {
            return [list [lindex [split $v2] 0] [lindex [split $v3] 0]]
        } else {
            return 0
        }
    }
    proc GetComment:GO {str} {
        # puts ">>>>>>>$str"
        if {[regexp -nocase -indices -- {(^| |\t)(//\s)(.+)} $str match v1 v2 v3]} {
            # puts ">>>> $match $v1 $v2 $v3"
            return [list [lindex [split $v2] 0] [lindex [split $v3] 0]]
        } else {
            return 0
        }
    }
    proc GetComment:Unknown	{str} {
        if {[regexp -nocase -indices -- {(^| )(#\s)(.+)} $str match v1 v2 v3]} {
            return [list [lindex [split $v2] 0] [lindex [split $v3] 0]]
        } else {
            return 0
        }
    }

    proc InsertTabular {txt} {
        global cfgVariables lexers editors
        set selIndex [$txt tag ranges sel]
        set pos [$txt index insert]
        set lineNum [lindex [split $pos "."] 0]
        set fileType [dict get $editors $txt fileType]
        if {[dict exists $lexers $fileType tabSize] != 0 } {
            set tabSize [dict get $lexers $fileType tabSize]
        } else {
            set tabSize $cfgVariables(tabSize)
        }
        # puts "Select : $selIndex"
        for {set i 0} {$i < $tabSize} { incr i} {
            append tabInsert " "
        }
        # puts ">$tabInsert<"
        if {$selIndex != ""} {
            set lineBegin [lindex [split [lindex $selIndex 0] "."] 0]
            set lineEnd [lindex [split [lindex $selIndex 1] "."] 0]
            set posBegin [lindex [split [lindex $selIndex 1] "."] 0]
            set posEnd [lindex [split [lindex $selIndex 1] "."] 1]
            # if {$lineBegin == $lineNum} {
                # set lineBegin [expr $lineBegin +	 1]
            # }
            if {$lineEnd == $lineNum || $posEnd == 0} {
                set lineEnd [expr $lineEnd - 1]
            }
            # puts "Pos: $pos, Begin: $lineBegin, End: $lineEnd"
            for {set i $lineBegin} {$i <=$lineEnd} {incr i} {
                #$txt insert $i.0 "# "
                regexp -nocase -indices -- {^(\s*)(.*?)} [$txt get $i.0 $i.end] match v1 v2
                $txt insert  $i.[lindex [split $v2] 0]  $tabInsert
            }
            $txt tag remove sel $lineBegin.$posBegin $lineEnd.$posEnd
            $txt tag add	sel $lineBegin.0 $lineEnd.end
            $txt highlight $lineBegin.0 $lineEnd.end            
        } else {
            # set pos [$txt index insert]
            # set lineNum [lindex [split $pos "."] 0]
            regexp -nocase -indices -- {^(\s*)(.*?)} [$txt get $lineNum.0 $lineNum.end] match v1 v2
            # puts "$v1<>$v2"
            $txt insert  $lineNum.[lindex [split $v2] 0] $tabInsert
        }
    }
    proc DeleteTabular {txt} {
        global cfgVariables lexers editors
        set selIndex [$txt tag ranges sel]
        set pos [$txt index insert]
        set fileType [dict get $editors $txt fileType]
        if {[dict exists $lexers $fileType tabSize] != 0 } {
            set tabSize [dict get $lexers $fileType tabSize]
        } else {
            set tabSize $cfgVariables(tabSize)
        }
        set lineNum [lindex [split $pos "."] 0]
        if {$selIndex != ""} {
            set lineBegin [lindex [split [lindex $selIndex 0] "."] 0]
            set lineEnd [lindex [split [lindex $selIndex 1] "."] 0]
            set posBegin [lindex [split [lindex $selIndex 1] "."] 0]
            set posEnd [lindex [split [lindex $selIndex 1] "."] 1]
            if {$lineEnd == $lineNum && $posEnd == 0} {
                set lineEnd [expr $lineEnd - 1]
            }
            for {set i $lineBegin} {$i <=$lineEnd} {incr i} {
                set str [$txt get $i.0 $i.end]
                if {[regexp -nocase -indices -- {(^\s*)(.*?)} $str match v1 v2]} {
                    set posBegin [lindex [split $v1] 0]
                    set posEnd [lindex [split $v1] 1]
                    if {[expr $posEnd + 1] >= $tabSize} {
                        $txt delete $i.$posBegin $i.$tabSize
                    }
                }
            }
            $txt tag remove sel $lineBegin.$posBegin $lineEnd.$posEnd
            $txt tag add	sel $lineBegin.0 $lineEnd.end
            $txt highlight $lineBegin.0 $lineEnd.end
        } else {
            set str [$txt get $lineNum.0 $lineNum.end]
            puts ">>>>> $str"
            if {[regexp -nocase -indices -- {(^\s*)(.*?)} $str match v1]} {
                    set posBegin [lindex [split $v1] 0]
                    set posEnd [lindex [split $v1] 1]
                    if {[expr $posEnd + 1] >= $tabSize} {
                        $txt delete $lineNum.$posBegin $lineNum.$tabSize
                    }
             }
        }
    }
    ## TABULAR INSERT (auto indent)##
    proc Indent {txt} {
        global cfgVariables lexers editors
        # set tabSize 4
        set fileType [dict get $editors $txt fileType]
        if {[dict exists $lexers $fileType tabSize] != 0 } {
            set tabSize [dict get $lexers $fileType tabSize]
        } else {
            set tabSize $cfgVariables(tabSize)
        }
        set indentSize $tabSize
        set pos [$txt index insert]
        set lineNum [lindex [split $pos "."] 0]
        set posNum [lindex [split $pos "."] 1]
        puts "$pos"
        if {$lineNum > 1} {
            # get current text
            set curText [$txt get $lineNum.0 "$lineNum.0 lineend"]
            #get text of prev line
            set prevLineNum [expr {$lineNum - 1}]
            set prevText [$txt get $prevLineNum.0 "$prevLineNum.0 lineend"]
            #count first spaces in current line
            set spaces ""
            regexp "^| *" $curText spaces
            #count first spaces in prev line
            set prevSpaces ""
            regexp "^( |\t)*" $prevText prevSpaces
            set len [string length $prevSpaces]
            set shouldBeSpaces 0
            for {set i 0} {$i < $len} {incr i} {
                if {[string index $prevSpaces $i] == "\t"} {
                    incr shouldBeSpaces $tabSize 
                } else  {
                    incr shouldBeSpaces
                }            
            }
            #see last symbol in the prev String.
            set lastSymbol [string index $prevText [expr {[string length $prevText] - 1}]]
            # is it open brace?
            if {$lastSymbol == ":" || $lastSymbol == "\\"} {
                incr shouldBeSpaces $indentSize
            }
            if {$lastSymbol == "\{"} {
                incr shouldBeSpaces $indentSize
            }
            set a ""
            regexp "^| *\}" $curText a
            if {$a != ""} {
                # make unindent
                if {$shouldBeSpaces >= $indentSize} {
                    set shouldBeSpaces [expr {$shouldBeSpaces - $indentSize}]
                }
            }
            if {$lastSymbol == "\["} {
                incr shouldBeSpaces $indentSize
            }
            set a ""
            regexp "^| *\]" $curText a
            if {$a != ""} {
                # make unindent
                if {$shouldBeSpaces >= $indentSize} {
                    set shouldBeSpaces [expr {$shouldBeSpaces - $indentSize}]
                }
            }
            if {$lastSymbol == "\("} {
                incr shouldBeSpaces $indentSize
            }
            set a ""
            regexp {^| *\)} $curText a
            if {$a != ""} {
                # make unindent
                if {$shouldBeSpaces >= $indentSize} {
                    set shouldBeSpaces [expr {$shouldBeSpaces - $indentSize}]
                }
            }
            set spaceNum [string length $spaces]
            if {$shouldBeSpaces > $spaceNum} {
                #insert spaces
                set deltaSpace [expr {$shouldBeSpaces - $spaceNum}]
                set incSpaces ""
                for {set i 0} {$i < $deltaSpace} {incr i} {
                    append incSpaces " "
                }
                $txt insert $lineNum.0 $incSpaces
            } elseif {$shouldBeSpaces < $spaceNum} {
                #delete spaces
                set deltaSpace [expr {$spaceNum - $shouldBeSpaces}]
                $txt delete $lineNum.0 $lineNum.$deltaSpace
            }
        }
    }
    proc SelectionPaste {txt} {
        set selBegin [lindex [$txt tag ranges sel] 0]
        set selEnd [lindex [$txt tag ranges sel] 1]
        if {$selBegin ne ""} {
            $txt delete $selBegin $selEnd
            $txt highlight $selBegin $selEnd
            #tk_textPaste $txt
        }
    }

    proc SelectionGet {txt} {
        variable selectionText
        set selBegin [lindex [$txt tag ranges sel] 0]
        set selEnd [lindex [$txt tag ranges sel] 1]
        if {$selBegin ne "" && $selEnd ne ""} {
            set selectionText [$txt get $selBegin $selEnd]
        }
    }
    
    proc SelectionHighlight {txt} {
        variable selectionText

        $txt tag remove lightSelected 1.0 end 

        set selBegin [lindex [$txt tag ranges sel] 0]
        set selEnd [lindex [$txt tag ranges sel] 1]
        if {$selBegin ne "" && $selEnd ne ""} {
            set selectionText [$txt get $selBegin $selEnd]
            # set selBeginRow [lindex [split $selBegin "."] 1]
            # set selEndRow [lindex [split $selEnd "."] 1]
            # puts "$selBegin, $selBeginRow; $selEnd, $selEndRow"
            # set symNumbers [expr $selEndRow - $selBeginRow]
            set symNumbers [expr [lindex [split $selEnd "."] 1] - [lindex [split $selBegin "."] 1]]
            # puts "Selection $selectionText"
            if [string match "-*" $selectionText] {
                set selectionText "\$selectionText"
            }
            set lstFindIndex [$txt search -all "$selectionText" 0.0]
            foreach ind $lstFindIndex {
                set selFindLine [lindex [split $ind "."] 0]
                set selFindRow [lindex [split $ind "."] 1]
                set endInd "$selFindLine.[expr $selFindRow + $symNumbers]"
                # puts "$ind;  $symNumbers; $selFindLine, $selFindRow; $endInd "
                $txt tag add lightSelected $ind $endInd 
            }
        }

    }
    
    proc ReleaseKey {k txt} {
        set pos [$txt index insert]
        SearchBrackets $txt
        switch $k {
            Return {
                set lineNum [lindex [split $pos "."] 0]
                set posNum [lindex [split $pos "."] 1]
                regexp {^(\s*)} [$txt get [expr $lineNum - 1].0 [expr $lineNum - 1].end] -> spaceStart
		# puts "$pos, $lineNum, $posNum, >$spaceStart<"
                $txt insert insert $spaceStart
                Editor::Indent $txt
            }
        }
        set lpos [split $pos "."]
        set lblText "[::msgcat::mc "Row"]: [lindex $lpos 0], [::msgcat::mc "Column"]: [lindex $lpos 1]"
        .frmStatus.lblPosition configure -text $lblText
        unset lpos
        $txt tag remove lightSelected 1.0 end 
    }

    proc PressKey {k txt} {
        # puts [Editor::Key $k]
        switch $k {
            apostrophe {
               QuotSelection $txt {'}
            }
            quotedbl {
                QuotSelection $txt {"}
            }
            grave {
                QuotSelection $txt {`}
            }
            parenleft {
                # QuotSelection $txt {)}
            }
            bracketleft {
                # QuotSelection $txt {]}
            }
            braceleft {
                # {QuotSelection} $txt {\}}
            }
            parentright {
                if [string is space [$txt get {insert linestart} {insert - 1c}]] {
                    Editor::DeleteTabular $txt
                }
            }
            bracketright {
                if [string is space [$txt get {insert linestart} {insert - 1c}]] {
                    Editor::DeleteTabular $txt
                }
            }
            braceright {
                if [string is space [$txt get {insert linestart} {insert - 1c}]] {
                    Editor::DeleteTabular $txt
                }
            }
        }
    }
    ## GET KEYS CODE ##
    proc Key {key str} {
        puts "Pressed key code: $key, $str"
        if {$key >= 10 && $key <= 22} {return "true"}
        if {$key >= 24 && $key <= 36} {return "true"}
        if {$key >= 38 && $key <= 50} {return "true"}
        if {$key >= 51 && $key <= 61 && $key != 58} {return "true"}
        if {$key >= 79 && $key <= 91} {return "true"}
        if {$key == 63 || $key == 107 || $key == 108 || $key == 112} {return "true"}
    }
    
    proc BindKeys {w fileType} {
        global cfgVariables
        #  variable txt
        set txt $w.frmText.t
        bind $txt <KeyRelease> "Editor::ReleaseKey %K $txt"
        bind $txt <KeyPress> "Editor::PressKey %K $txt"
        # bind $txt <KeyRelease> "Editor::Key %k %K" 
        #$txt tag bind Sel  <Control-/> {puts ">>>>>>>>>>>>>>>>>>>"}
        #bind $txt <Control-slash> {puts "/////////////////"}
        #     #bind $txt <Control-g> GoToLine
        #     bind $txt <Control-g> {focus .frmTool.frmGoto.entGoTo; .frmTool.frmGoto.entGoTo delete 0 end}
        bind $txt <Control-agrave> "Editor::FindDialog $w"
        bind $txt <Control-f> "Editor::FindDialog $w"
        bind $txt <Control-F> "Editor::FindDialog $w"
        #     bind $txt <F3> {FindNext $w.text 1}
        #     bind $txt <Control-ecircumflex> ReplaceDialog
        #     bind $txt <Control-r> ReplaceDialog
        #     bind $txt <F4> {ReplaceCommand $w.text 1}
        #     bind $txt <Control-ucircumflex> {FileDialog [$noteBookFiles raise] save}
        #     bind $txt <Control-s> {FileDialog [$noteBookFiles raise] save}
        #     bind $txt <Control-ocircumflex> {FileDialog [$noteBookFiles raise] save_as}
        #     bind $txt <Shift-Control-s> {FileDialog [$noteBookFiles raise] save_as}
        bind $txt <Control-odiaeresis> FileOper::Close
        bind $txt <Control-w> FileOper::Close
        #     bind $txt <Control-division> "tk_textCut $w.text;break"
        #     bind $txt <Control-x> "tk_textCut $w.text;break"
        #     bind $txt <Control-ntilde> "tk_textCopy $txt"
        #     bind $txt <Control-c> "tk_textCopy $txt"
        bind $txt <Control-igrave> "Editor::SelectionPaste $txt"
        bind $txt <Control-v> "Editor::SelectionPaste $txt"
        
        #bind $txt <Control-adiaeresis> "auto_completition $txt"
        bind $txt <Control-l> "SearchVariable $txt"
        # bind $txt <Control-icircumflex> ""
        # bind $txt <Control-j> ""
        bind $txt <Control-i> "ImageBase64Encode $txt"

        bind $txt <Control-bracketleft> "Editor::InsertTabular $txt"
        bind $txt <Control-bracketright> "Editor::DeleteTabular $txt"

        bind $txt <Control-comma> "Editor::Comment $txt $fileType"
        bind $txt <Control-period> "Editor::Uncomment $txt $fileType"
        bind $txt <Control-eacute> Find
        #bind . <Control-m> PageTab
        #bind . <Control-udiaeresis> PageTab
        bind $txt <Insert> {OverWrite}
        bind $txt <ButtonRelease-1> "Editor::SearchBrackets $txt"
        # bind <Button-1> [bind sysAfter <Any-Key>]
        # bind $txt <Button-3> {catch [PopupMenuEditor %X %Y]}
        # bind $txt <Button-4> "%W yview scroll -3 units"
        # bind $txt <Button-5> "%W yview scroll  3 units"
        #bind $txt <Shift-Button-4> "%W xview scroll -2 units"
        #bind $txt <Shift-Button-5> "%W xview scroll  2 units"
        bind $txt <Button-1><ButtonRelease-1> "Editor::SelectionHighlight $txt"
        # bind $txt <<Selection>> "Editor::SelectionHighlight $txt"
        bind $txt <<Modified>> "SetModifiedFlag $w"
        # bind $txt <<Selection>> "Editor::SelectionGet $txt"
        bind $txt <Control-i> ImageBase64Encode
        bind $txt <Control-u> "Editor::SearchBrackets %W"
        bind $txt <Control-J> "catch {Editor::GoToFunction $w}"
        bind $txt <Control-j> "catch {Editor::GoToFunction $w}"
        bind $txt <Alt-w> "$txt delete {insert wordstart} {insert wordend}"
        bind $txt <Alt-r> "$txt delete {insert linestart} {insert lineend}"
        bind $txt <Alt-b> "$txt delete {insert linestart} insert"
        bind $txt <Alt-e> "$txt delete insert {insert lineend}"
    }
    
    proc SearchBrackets {txt} {
        set i -1
        catch {
            switch -- [$txt get "insert - 1 chars"] {
                \{ {set i [Editor::_searchCloseBracket $txt \{ \} insert end]}
                \[ {set i [Editor::_searchCloseBracket $txt \[ \] insert end]}
                ( {set i [Editor::_searchCloseBracket $txt (   ) insert end]}
                \} {set i [Editor::_searchOpenBracket $txt \{ \} insert 1.0]}
                \] {set i [Editor::_searchOpenBracket $txt \[ \] insert 1.0]}
                ) {set i [Editor::_searchOpenBracket $txt (  ) insert 1.0]}
            } ;# switch
            catch { $txt tag remove lightBracket 1.0 end }
            if { $i != -1 } {
                # puts $i
                $txt tag add lightBracket "$i - 1 chars" $i
            };#if
        };#catch
    }
    
    proc QuotSelection {txt symbol} {
        variable selectionText
        set selIndex [$txt tag ranges sel]
        set pos [$txt index insert]
        set lineNum [lindex [split $pos "."] 0]
        set posNum [lindex [split $pos "."] 1]
        set symbol [string trim [string trimleft $symbol "\\"]]
        # puts "Selindex : $selIndex, cursor position: $pos"
        if {$selIndex != ""} {
            set lineBegin [lindex [split [lindex $selIndex 0] "."] 0]
            set posBegin [lindex [split [lindex $selIndex 0] "."] 1]
            set lineEnd [lindex [split [lindex $selIndex 1] "."] 0]
            set posEnd [lindex [split [lindex $selIndex 1] "."] 1]
            # set selText [$txt get $lineBegin.$posBegin $lineEnd.$posEnd]
            set selText $selectionText
            # puts "Selected text: $selText, pos: $pos, lineBegin: $lineBegin, posBegin: $posBegin, pos end: $posEnd"
            if {$posNum == $posEnd} {
                $txt insert $lineBegin.$posBegin "$symbol"
            }
            if {$posNum == $posBegin} {
                $txt insert $lineBegin.$posEnd "$symbol"
            }
            $txt highlight $lineBegin.$posBegin $lineEnd.end
            # $txt insert $lineBegin.[expr $posBegin + 1] "$symbol"
        } else {
            # $txt insert $lineNum.[expr $posNum + 1] "$symbol"
            # $txt mark set insert $lineNum.[expr $posNum - 1]
            # # $txt see $lineNum.[expr $posNum - 1]
            # $txt see insert
            # $txt highlight $lineNum.$posNum $lineNum.end
        }
    }
 
    # Create editor for new file (Ctrl+N)
    proc New {} {
        global nbEditor tree untitledNumber
        if [info exists untitledNumber] {
            incr untitledNumber 1
        } else {
            set untitledNumber 0
        }
        # set filePath untitled-$untitledNumber
        # set fileName untitled-$untitledNumber
        set fileFullPath untitled-$untitledNumber
        #puts [Tree::InsertItem $tree {} $fileFullPath "file" $fileName]
        set nbEditorItem [NB::InsertItem $nbEditor  $fileFullPath "file"]
        # puts "$nbEditorItem, $nbEditor"
        Editor $fileFullPath $nbEditor $nbEditorItem
        SetModifiedFlag $nbEditorItem
    }
    
    proc ReadStructure {txt treeItemName} {
        global tree nbEditor editors lexers
        set fileType [dict get $editors $txt fileType]
        set procList ""
        set varList ""
        set params ""
        if {[dict exists $lexers $fileType] == 0} {return}
        for {set lineNumber 0} {$lineNumber <= [$txt count -lines 0.0 end]} {incr lineNumber} {
            set line [$txt get $lineNumber.0 $lineNumber.end]
            # ???????????????? ?????????????????? (??????????????, ???????????? ?? ??.??.)
            if {[dict exists $lexers $fileType procRegexpCommand] != 0 } {
                if {[eval [dict get $lexers $fileType procRegexpCommand]]} {
                    set procName_ [string trim $procName]
                    puts [Tree::InsertItem $tree $treeItemName $procName_  "procedure" "$procName_ ($params)"]
                    lappend procList [list $procName_ $params]
                    unset procName_
                }
            }
            # ???????????????? ????????????????????
            if {[dict exists $lexers $fileType varRegexpCommand] != 0 } {
                if {[eval [dict get $lexers $fileType varRegexpCommand]]} {
                    set varName [string trim $varName]
                    set varValue [string trim $varValue]
                    puts "variable: $varName, value: $varValue"
                    lappend varList [list $varName $varValue]
                }
            }
        }
        dict set editors $txt procedureList $procList
        dict set editors $txt variableList $varList
    }

proc FindFunction {findString} {
        global nbEditor
        puts $findString
        set pos "0.0"
        set txt [$nbEditor select].frmText.t
        $txt see $pos
        set line [lindex [split $pos "."] 0]
        set x [lindex [split $pos "."] 1]
        # set pos [$txt search -nocase $findString $line.$x end]
        set pos [$txt search -nocase -regexp $findString $line.$x end]
        $txt mark set insert $pos
        $txt see $pos
        puts $pos
        # highlight the found word
        set line [lindex [split $pos "."] 0]
        # set x [lindex [split $pos "."] 1]
        # set x [expr {$x + [string length $findString]}]
        $txt tag remove sel 1.0 end
        $txt tag add sel $pos $line.end
        # #$text tag configure sel -background $editor(selectbg) -foreground $editor(fg)
        $txt tag raise sel
        focus -force $txt.t
        # Position
        return 1
    }
        # "Alexander Dederer (aka Korwin)
    ## Search close bracket in editor widget
    proc _searchCloseBracket { widget o_bracket c_bracket start_pos end_pos } {
        # puts "_searchCloseBracket: $widget $o_bracket $c_bracket $start_pos $end_pos"
        set o_count 1
        set c_count 0
        set found 0
        set pattern "\[\\$o_bracket\\$c_bracket\]"
        set pos [$widget search -regexp -- $pattern $start_pos $end_pos]
        while { ! [string equal $pos {}] } {
            set char [$widget get $pos]
            #tk_messageBox -title $pattern -message "char: $char; $pos; o_count=$o_count; c_count=$c_count"
            if {[string equal $char $o_bracket]} {incr o_count ; set found 1}
            if {[string equal $char $c_bracket]} {incr c_count ; set found 1}
            if {($found == 1) && ($o_count == $c_count) } { return [$widget index "$pos + 1 chars"] }
            set found 0
            set start_pos "$pos + 1 chars"
            set pos [$widget search -regexp -- $pattern $start_pos $end_pos]
        } ;# while search
        
        return -1
    } ;# proc _searchCloseBracket
    
    # "Alexander Dederer (aka Korwin)
    ## Search open bracket in editor widget
    proc _searchOpenBracket { widget o_bracket c_bracket start_pos end_pos } {
        # puts "_searchOpenBracket: $widget $o_bracket $c_bracket $start_pos $end_pos"
        set o_count 0
        set c_count 1
        set found 0
        set pattern "\[\\$o_bracket\\$c_bracket\]"
        set pos [$widget search -backward -regexp -- $pattern "$start_pos - 1 chars" $end_pos]
        # puts "$pos"
        while { ! [string equal $pos {}] } {
            set char [$widget get $pos]
            # tk_messageBox -title $pattern -message "char: $char; $pos; o_count=$o_count; c_count=$c_count"
            if {[string equal $char $o_bracket]} {incr o_count ; set found 1}
            if {[string equal $char $c_bracket]} {incr c_count ; set found 1}
            if {($found == 1) && ($o_count == $c_count) } { return [$widget index "$pos + 1 chars"]}
            set found 0
            set start_pos "$pos - 0 chars"
            set pos [$widget search -backward -regexp -- $pattern $start_pos $end_pos]
        } ;# while search
        return -1
    }

    # ----------------------------------------------------------------------
    # ?????????? ?????????????? ???? ?????????????? ???????????????? ?????? ?????????????? ???????????????????????????? ?? ????????????
    
        proc GoToFunction { w } {
        global tree editors
        set txt $w.frmText.t
        # set start_word [$txt get "insert - 1 chars wordstart" insert]
        set box        [$txt bbox insert]
        set box_x      [expr [lindex $box 0] + [winfo rootx $txt] ]
        set box_y      [expr [lindex $box 1] + [winfo rooty $txt] + [lindex $box 3] ]
        set l ""
        # bindtags $txt [list GoToFunctionBind [winfo toplevel $txt] $txt Text sysAfter all]
        # bind GoToFunctionBind <Escape> "bindtags $txt {[list [winfo toplevel $txt] $txt Text sysAfter all]}; catch { destroy .gotofunction; break}"
        # bind GoToFunctionBind <Key> { Editor::GoToFunctionKey %W %K %A ; break}
        # puts [array names editors]

        foreach item [dict get $editors $txt procedureList] {
            # puts $item
            lappend l [lindex $item 0]
        }
        if {$l ne ""} {
            eval GotoFunctionDialog $w $box_x $box_y [lsort $l]
            focus .gotofunction.lBox
        }
    }

    # proc GoToFunctionKey { txt K A } {
        # set win .gotofunction
        # set ind [$win.lBox curselection]
        # puts "$txt $K $A"
        # switch -- $K {
            # Prior   {
                # set up   [expr [$win.lBox index active] - [$win.lBox cget -height]]
                # if { $up < 0 } { set up 0 }
                # $win.lBox activate $up
                # $win.lBox selection clear 0 end
                # $win.lBox selection set $up $up
            # }
            # Next    {
                # set down [expr [$win.lBox index active] + [$win.lBox cget -height]]
                # if { $down >= [$win.lBox index end] }  { set down end }
                # $win.lBox activate $down
                # $win.lBox selection clear 0 end
                # $win.lBox selection set $down $down
            # }
            # Up      {
                # set up   [expr [$win.lBox index active] - 1]
                # if { $up < 0 } { set up 0 }
                # $win.lBox activate $up
                # $win.lBox selection clear 0 end
                # $win.lBox selection set $up $up
            # }
            # Down    {
                # set down [expr [$win.lBox index active] + 1]
                # if { $down >= [$win.lBox index end] }  { set down end }
                # $win.lBox activate $down 
                # $win.lBox selection clear 0 end 
                # $win.lBox selection set $down $down 
            # }
            # Return  {
                # Editor::FindFunction "proc $values"
                # eval [bind GoToFunctionBind <Escape>]
            # }
            # default {
                # $txt insert "insert" $A
                # eval [bind GoToFunctionBind <Escape>] 
            # }
        # }
    # }

    #---------------------------------------------------------
    # ?????????? ???? ???????????? ???? ???????????? ??????????
    # Richard Suchenwirth 2001-03-1
    # https://wiki.tcl-lang.org/page/Listbox+navigation+by+keyboard
    proc ListBoxSearch {w key} {
        if [regexp {[-A-Za-z0-9_]} $key] {
            set n 0   
            foreach i [$w get 0 end] {
                if [string match -nocase $key* $i] {
                    $w see $n
                    $w selection clear 0 end
                    $w selection set $n
                    $w activate $n
                    break
                } else {
                    incr n
                }
            }               
        }
    }
    # ------------------------------------------------------------------------
    # ???????????????????? ???????? ???? ?????????????? ???????????????? ?????? ?????????????? ?? ?????????????????????????? ????????????
    proc GotoFunctionDialog {w x y args} {
        global editors lexers
        variable txt 
        variable win
        set txt $w.frmText.t
        set win .gotofunction

        if { [winfo exists $win] }  { destroy $win }
        toplevel $win
        wm transient $win .
        wm overrideredirect $win 1
        
        listbox $win.lBox -width 30 -border 2 -yscrollcommand "$win.yscroll set" -border 1
        ttk::scrollbar $win.yscroll -orient vertical -command  "$win.lBox yview"
        pack $win.lBox -expand true -fill y -side left
        pack $win.yscroll -side left -expand false -fill y
        
        foreach { word } $args {
            $win.lBox insert end $word
        }
        
        catch { $win.lBox activate 0 ; $win.lBox selection set 0 0 }
        
        if { [set height [llength $args]] > 10 } { set height 10 }
        $win.lBox configure -height $height

        bind $win      <Escape> { 
            destroy $Editor::win
            focus -force $Editor::txt.t
            break
        }
        bind $win.lBox <Escape> {
            destroy $Editor::win
            focus -force $Editor::txt.t
            break
        }
        bind $win.lBox <Return> {
            set findString [dict get $lexers [dict get $editors $Editor::txt fileType] procFindString]
            set values [.gotofunction.lBox get [.gotofunction.lBox curselection]]
            regsub -all {PROCNAME} $findString $values str
            Editor::FindFunction "$str"
            destroy .gotofunction
            $Editor::txt tag remove sel 1.0 end
            # focus $Editor::txt.t
            break
        }
        bind $win.lBox <Any-Key> {Editor::ListBoxSearch %W %A}
        # ?????????????????? ???????????????????? ???? ???????? ???????????? (?????????????????? ????????) ?? ????????
        # ?????? ???????????? ?????????????? ???????? ???? ?????????????? ???? ???????????????? ?????? ??????????
        set winGeom [winfo reqheight $win]
        set topHeight [winfo height .]
        # puts "$x, $y, $winGeom, $topHeight"
        if [expr [expr $topHeight - $y] < $winGeom] {
            set y [expr $topHeight - $winGeom]
        }
        wm geom $win +$x+$y
    }
    proc FindReplaceText {findString replaceString regexp} {
        global nbEditor
        set txt [$nbEditor select].frmText.t
        $txt tag remove sel 1.0 end
        # $txt see $pos
        # set pos [$txt search -nocase $findString $line.$x end]
        set options ""
        # $txt see 1.0
        set pos [$txt index insert]
        set allLines [$txt count -lines 1.0 end]
        # puts "$pos $allLines"
        set line [lindex [split $pos "."] 0]

        if [expr $line == $allLines] {
            set pos "0.0"
            set line [lindex [split $pos "."] 0]
        }
        set x [lindex [split $pos "."] 1]
        # incr x $incr 

        # puts "$findString -> $replaceString, $regexp, $pos, $line.$x"
        set matchIndexPair ""
        if {$regexp eq "-regexp"} {
            # puts "$txt search -all -nocase -regexp {$findString} $line.$x end"
            set lstFindIndex [$txt search -all -nocase -regexp -count matchIndexPair "$findString" $line.$x end]
        } else {
            # puts "$txt search -all -nocase {$findString} $line.$x end"
            set lstFindIndex [$txt search -all -nocase -count matchIndexPair $findString $line.$x end]
            # set symNumbers [string length "$findString"]
        }
        puts $lstFindIndex
        puts $matchIndexPair
        # set lstFindIndex [$txt search -all "$selectionText" 0.0]
        set i 0
        foreach ind $lstFindIndex {
            set selFindLine [lindex [split $ind "."] 0]
            set selFindRow [lindex [split $ind "."] 1]
            # set endInd "$selFindLine.[expr $selFindRow + $symNumbers]"
            set endInd "$selFindLine.[expr [lindex $matchIndexPair $i] + $selFindRow]"
            puts "$ind; $selFindLine, $selFindRow; $endInd "
            if {$replaceString ne ""} {
                $txt replace $ind $endInd $replaceString
            }
            $txt tag add sel $ind $endInd
            incr i
        }
        # set pos [$txt search $options $findString $pos end]

        
        # $txt mark set insert $pos
        $txt see $pos
        # puts $pos
        # # highlight the found word
        # set line [lindex [split $pos "."] 0]
        # set x [lindex [split $pos "."] 1]
        # set x [expr {$x + [string length $findString]}]
        # $txt tag remove sel 1.0 end
        # $txt tag add sel $pos $line.end
        # #$text tag configure sel -background $editor(selectbg) -foreground $editor(fg)
        $txt tag raise sel
        # # focus -force $txt.t
        # # Position
        # return 1
    }

    # Find and replace text dialog
    proc FindDialog {w} {
        global editors lexers nbEditor regexpSet
        variable txt 
        variable win
        variable show

        
        set findString ""
        set replaceString ""
        
        set txt $w.frmText.t
        set win .finddialog
        set regexpSet ""
        # set nocaseSet "-nocase"
        
        if { [winfo exists $win] }  { destroy $win }
        toplevel $win
        wm transient $win .
        wm overrideredirect $win 1
        
        ttk::entry $win.entryFind -width 30 -textvariable findString
        ttk::entry $win.entryReplace -width 30 -textvariable replaceString
        
        set show($win.entryReplace) false
        
        
        ttk::button $win.bForward -image forward_20x20 -command  {
            Editor::FindReplaceText "$findString" "" $regexpSet
        }
        ttk::button $win.bBackward -state disable -image backward_20x20 -command "puts $replaceString"
        ttk::button $win.bDone -image done_20x20 -state disable -command {
            puts "$findString -> $replaceString, $regexpSet"
        }
        ttk::button $win.bDoneAll -image doneall_20x20 -command {
            Editor::FindReplaceText "$findString" "$replaceString" $regexpSet
        }
        ttk::button $win.bReplace -image replace_20x20 \
            -command {
                puts $Editor::show($Editor::win.entryReplace)
                if {$Editor::show($Editor::win.entryReplace) eq "false"} {
                    grid $Editor::win.entryReplace -row 1 -column 0 -columnspan 2 -sticky nsew
                    grid $Editor::win.bDone -row 1 -column 3 -sticky e
                    grid $Editor::win.bDoneAll -row 1 -column 4 -sticky e
                    set Editor::show($Editor::win.entryReplace) "true"
                } else {
                    grid remove $Editor::win.entryReplace $Editor::win.bDone $Editor::win.bDoneAll
                    set Editor::show($Editor::win.entryReplace) "false"
                }
            }
        ttk::checkbutton $win.chkRegexp -text "Regexp" \
            -variable regexpSet -onvalue "-regexp" -offvalue ""
        # ttk::checkbutton $win.chkCase -text "Case Sensitive" \
            # -variable nocaseSet -onvalue "" -offvalue "-nocase"

        grid $win.entryFind -row 0 -column 0  -columnspan 2 -sticky nsew
        grid $win.bForward -row 0 -column 3 -sticky e
        grid $win.bBackward -row 0 -column 4 -sticky e
        grid $win.bReplace -row 0 -column 5 -sticky e
        grid $win.chkRegexp -row 2 -column 0 -sticky w
        # grid $win.chkCase -row 2 -column 1  -sticky w

        # set reqWidth [winfo reqwidth $win]
        set boxX      [expr [winfo rootx $w] + [expr [winfo width $nbEditor] - 350]]
        set boxY      [expr [winfo rooty $w] + 10]

        bind $win <Escape> { 
            destroy $Editor::win
            focus -force $Editor::txt.t
            break
        }
        bind $win.entryFind <Escape> {
            destroy $Editor::win
            focus -force $Editor::txt.t
            break
        }
        bind $win.entryFind <Return> {
            Editor::FindReplaceText "$findString" "" $regexpSet
            break
        }
        bind $win.entryReplace <Return> {
            Editor::FindReplaceText "$findString" "$replaceString" $regexpSet
            break
        }

        wm geom $win +$boxX+$boxY
        focus -force $win.entryFind
    }

    proc Editor {fileFullPath nb itemName} {
        global cfgVariables editors
        set fr $itemName
        if ![string match "*untitled*" $itemName] {
             set lblText $fileFullPath
        } else {
             set lblText ""

        }
        
        set lblName "lbl[string range $itemName [expr [string last "." $itemName] +1] end]"
        ttk::label $fr.$lblName -text $lblText
        pack $fr.$lblName  -side top  -anchor w -fill x
        
        set frmText [ttk::frame $fr.frmText -border 1]
        set txt $frmText.t

        pack $frmText  -side top -expand true -fill both 
        pack [ttk::scrollbar $frmText.v -command "$frmText.t yview"] -side right -fill y
        ttk::scrollbar $frmText.h -orient horizontal -command "$frmText.t xview"
        ctext $txt -xscrollcommand "$frmText.h set" -yscrollcommand "$frmText.v set" \
            -font $cfgVariables(font) -relief flat -wrap $cfgVariables(editorWrap) \
            -linemapfg $cfgVariables(lineNumberFG) -linemapbg $cfgVariables(lineNumberBG) \
            -tabs "[expr {4 * [font measure $cfgVariables(font) 0]}] left" -tabstyle tabular -undo true
            
        pack $txt -fill both -expand 1
        pack $frmText.h -side bottom -fill x
        # puts ">>>>>>> [bindtags $txt]"
        if {$cfgVariables(lineNumberShow) eq "false"} {
            $txt configure -linemap 0
        }
        $txt tag configure lightBracket -background $cfgVariables(selectLightBg) -foreground #00ffff
        $txt tag configure lightSelected -background $cfgVariables(selectLightBg) -foreground #00ffff
        
        set fileType [string toupper [string trimleft [file extension $fileFullPath] "."]]
        if {$fileType eq ""} {set fileType "Unknown"}

        # puts ">$fileType<"
        # puts [info procs Highlight::GO]
        dict set editors $txt fileType $fileType
        dict set editors $txt procedureList [list]
        
        # puts ">>[dict get $editors $txt fileType]"
        # puts ">>[dict get $editors $txt procedureList]"
		# puts ">>>>> $editors"
        
        if  {[info procs ::Highlight::$fileType] ne ""} {
            Highlight::$fileType $txt
        } else {
            Highlight::Default $txt
        }
        
        BindKeys $itemName $fileType
        # bind $txt <Return> {
            # regexp {^(\s*)} [%W get "insert linestart" end] -> spaceStart
            # %W insert insert "\n$spaceStart"
            # break
        # }

        return $fr
    }
}

# ctextBindings.tcl
#
# Copyright (C) 2012 Sedat Serper
# A similar script and functionality is implemented in tG?? as of v1.06.01.41 
#
# proc ctext_binding4Tag {w tags} {
  # # foreach tag $tags {
    # $w tag bind $tag <Enter> {%W config -cursor hand2}
    # $w tag bind $tag <Leave> {%W config -cursor xterm}
    # $w tag bind $tag <ButtonRelease-1> {
      # set cur [::tk::TextClosestGap %W %x %y]
      # if {[catch {%W index anchor}]} {%W mark set anchor $cur}
      # set anchor [%W index anchor]
      # set last  [::tk::TextNextPos %W "$cur - 1c" tcl_wordBreakAfter]
      # set first [::tk::TextPrevPos %W anchor tcl_wordBreakBefore]
      # if {![catch {set tmp [%W get $first $last]}]} {
        # ctext_execTagCmd $tmp
      # }
    # }
  # }
# }
# 
# 
# THE DEMO
# 
# # ----------------------- demo -------------------------------------------
# # Open a new wish console and copy/paste the following complete script.
# # Clicking on parts that are highlighted and observe the console output...
# # Adjust procedure 'ctext_execTagCmd' to customize the handling 4 your application.
# package require ctext
# pack [ctext .t] -fill both -expand 1
# ctext::addHighlightClass .t bindings purple [list <Enter> <Leave> <ButtonRelease-1>]
# ctext::addHighlightClass .t commands orange [list foreach proc if set catch]
# .t fastinsert end [info body ctext_binding4Tag]
# .t highlight 1.0 end
# ctext_binding4Tag .t {bindings commands}
