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
    proc Comment {txt} {
        set selIndex [$txt tag ranges sel]
        set pos [$txt index insert]
        set lineNum [lindex [split $pos "."] 0]
        set PosNum [lindex [split $pos "."] 1]
        puts "Select : $selIndex"
        if {$selIndex != ""} {
            set lineBegin [lindex [split [lindex $selIndex 0] "."] 0]
            set lineEnd [lindex [split [lindex $selIndex 1] "."] 0]
            set posBegin [lindex [split [lindex $selIndex 1] "."] 0]
            set posEnd [lindex [split [lindex $selIndex 1] "."] 1]
            if {$lineEnd == $lineNum || $posEnd == 0} {
                set lineEnd [expr $lineEnd - 1]
            }
            for {set i $lineBegin} {$i <=$lineEnd} {incr i} {
                #$txt insert $i.0 "# "
                regexp -nocase -indices -- {^(\s*)(.*?)} [$txt get $i.0 $i.end] match v1 v2
                $txt insert  $i.[lindex [split $v2] 0] "# "
            }
            $txt tag add comments $lineBegin.0 $lineEnd.end
            $txt tag raise comments
        } else {
            regexp -nocase -indices -- {^(\s*)(.*?)} [$txt get $lineNum.0 $lineNum.end] match v1 v2
            $txt insert  $lineNum.[lindex [split $v2] 0] "# "
            $txt tag add comments $lineNum.0 $lineNum.end
            $txt tag raise comments
        }
    }
    proc Uncomment {txt} {
        set selIndex [$txt tag ranges sel]
        set pos [$txt index insert]
        set lineNum [lindex [split $pos "."] 0]
        set posNum [lindex [split $pos "."] 1]
        if {$selIndex != ""} {
            set lineBegin [lindex [split [lindex $selIndex 0] "."] 0]
            set lineEnd [lindex [split [lindex $selIndex 1] "."] 0]
            set posBegin [lindex [split [lindex $selIndex 1] "."] 0]
            set posEnd [lindex [split [lindex $selIndex 1] "."] 1]
            if {$lineEnd == $lineNum || $posEnd == 0} {
                set lineEnd [expr $lineEnd - 1]
            }            
            for {set i $lineBegin} {$i <=$lineEnd} {incr i} {
                set str [$txt get $i.0 $i.end]
                if {[regexp -nocase -indices -- {(^| )(#\s)(.+)} $str match v1 v2 v3]} {
                    $txt delete $i.[lindex [split $v2] 0] $i.[lindex [split $v3] 0]
                }
            }
           $txt tag remove comments $lineBegin.0 $lineEnd.end
           $txt tag add	sel $lineBegin.0 $lineEnd.end
           $txt highlight $lineBegin.0 $lineEnd.end
        } else {
            #set posNum [lindex [split $pos "."] 1]
            set str [$txt get $lineNum.0 $lineNum.end]
            if {[regexp -nocase -indices -- {(^| )(#\s)(.+)} $str match v1 v2 v3]} {
                puts ">>>>> $v1, $v2, $v3"
                    $txt delete $lineNum.[lindex [split $v2] 0] $lineNum.[lindex [split $v3] 0]
                    #$txt insert $i.0 $v3
            }
            $txt tag remove comments $lineNum.0 $lineNum.end
            $txt highlight $lineNum.0 $lineNum.end
        }
    }

    proc InsertTabular {txt} {
        global cfgVariables
        set selIndex [$txt tag ranges sel]
        set pos [$txt index insert]
        set lineNum [lindex [split $pos "."] 0]

        puts "Select : $selIndex"
        for {set i 0} {$i < $cfgVariables(tabSize)} { incr i} {
            append tabInsert " "
        }
        puts ">$tabInsert<"
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
            puts "Pos: $pos, Begin: $lineBegin, End: $lineEnd"
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
            puts "$v1<>$v2"
            $txt insert  $lineNum.[lindex [split $v2] 0] $tabInsert
        }
    }
    proc DeleteTabular {txt} {
        global cfgVariables
        set selIndex [$txt tag ranges sel]
        set pos [$txt index insert]
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
                    if {[expr $posEnd + 1] >= $cfgVariables(tabSize)} {
                        $txt delete $i.$posBegin $i.$cfgVariables(tabSize)
                    }
                }
            }
            $txt tag remove sel $lineBegin.$posBegin $lineEnd.$posEnd
            $txt tag add	sel $lineBegin.0 $lineEnd.end
            $txt highlight $lineBegin.0 $lineEnd.end
        } else {
            set str [$txt get $lineNum.0 $lineNum.end]
            if {[regexp -nocase -indices -- {(^\s*)(.*?)} $str match v1]} {
                    set posBegin [lindex [split $v1] 0]
                    set posEnd [lindex [split $v1] 1]
                    if {[expr $posEnd + 1] >= $cfgVariables(tabSize)} {
                        $txt delete $lineNum.$posBegin $lineNum.$cfgVariables(tabSize)
                    }
             }
        }
    }
    ## TABULAR INSERT (auto indent)##
    proc Indent {txt} {
        global cfgVariables
        # set tabSize 4
        set indentSize $cfgVariables(tabSize)
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
    proc ReleaseKey {k txt} {
        switch $k {
            Return {
                set pos [$txt index insert]
                set lineNum [lindex [split $pos "."] 0]
                set posNum [lindex [split $pos "."] 1]
                regexp {^(\s*)} [$txt get [expr $lineNum - 1].0 [expr $lineNum - 1].end] -> spaceStart
		# puts "$pos, $lineNum, $posNum, >$spaceStart<"
                $txt insert insert $spaceStart
                Editor::Indent $txt
            }
        }
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
    
    proc BindKeys {w} {
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
        #     bind $txt <Control-agrave> Find
        #     bind $txt <Control-f> Find
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
        #bind $txt <Control-l> "auto_completition $txt"
        bind $txt <Control-icircumflex> "auto_completition_proc $txt"
        bind $txt <Control-j> "auto_completition_proc $txt"
        bind $txt <Control-i> "ImageBase64Encode $txt"

        bind $txt <Control-bracketleft> "Editor::InsertTabular $txt"
        bind $txt <Control-bracketright> "Editor::DeleteTabular $txt"
        
        bind $txt <Control-comma> "Editor::Comment $txt"
        bind $txt <Control-period> "Editor::Uncomment $txt"
        bind $txt <Control-eacute> Find
        #bind . <Control-m> PageTab
        #bind . <Control-udiaeresis> PageTab
        bind $txt <Insert> {OverWrite}
        bind $txt <ButtonRelease-1> []
        bind $txt <Button-3> {catch [PopupMenuEditor %X %Y]}
        bind $txt <Button-4> "%W yview scroll -3 units"
        bind $txt <Button-5> "%W yview scroll  3 units"
        #bind $txt <Shift-Button-4> "%W xview scroll -2 units"
        #bind $txt <Shift-Button-5> "%W xview scroll  2 units"
        bind $txt <<Modified>> "SetModifiedFlag $w"
        bind $txt <<Selection>> "Editor::SelectionGet $txt"
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
            puts "Selected text: $selText, pos: $pos, lineBegin: $lineBegin, posBegin: $posBegin, pos end: $posEnd"
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
        set filePath untitled-$untitledNumber
        set fileName untitled-$untitledNumber
        set fileFullPath untitled-$untitledNumber
        #puts [Tree::InsertItem $tree {} $fileFullPath "file" $fileName]
        set nbEditorItem [NB::InsertItem $nbEditor  $fileFullPath "file"]
        puts "$nbEditorItem, $nbEditor"
        Editor $fileFullPath $nbEditor $nbEditorItem
    }
    proc Editor {fileFullPath nb itemName} {
        global cfgVariables
        set fr $itemName
        if ![string match "*untitled*" $itemName] {
            set lblName "lbl[string range $itemName [expr [string last "." $itemName] +1] end]"
            ttk::label $fr.$lblName -text $fileFullPath
            pack $fr.$lblName  -side top  -anchor w -fill x  
        }
        
        set frmText [ttk::frame $fr.frmText -border 1]
        set txt $frmText.t

        pack $frmText  -side top -expand true -fill both 
        pack [ttk::scrollbar $frmText.s -command "$frmText.t yview"] -side right -fill y
        ctext $txt -yscrollcommand "$frmText.s set" -font $cfgVariables(font) -linemapfg $cfgVariables(lineNumberFG) \
        -tabs "[expr {4 * [font measure $cfgVariables(font) 0]}] left" -tabstyle tabular -undo true
        pack $txt -fill both -expand 1
        puts ">>>>>>> [bindtags $txt]"
        if {$cfgVariables(lineNumberShow) eq "false"} {
            $txt configure -linemap 0
        }
        set fileType [string toupper [string trimleft [file extension $fileFullPath] "."]]
        
        if  {[info procs Highlight::$fileType] ne ""} {
            Highlight::$fileType $txt
        } else {
            Highlight::Default $txt
        }
        
        BindKeys $itemName
        # bind $txt <Return> {
            # regexp {^(\s*)} [%W get "insert linestart" end] -> spaceStart
            # %W insert insert "\n$spaceStart"
            # break
        # }

        return $fr
    }
}
