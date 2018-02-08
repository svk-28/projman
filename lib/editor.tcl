###########################################################
#                Tcl/Tk Project Manager                   #
#                  all procedure file                     #
# Copyright (c) "Sergey Kalinin", 2002, http://nuk-svk.ru  #
# Author: Sergey Kalinin banzaj28@yandex.ru       #
###########################################################

## GETTING OPERATORS FOR COMPLITE PROCEDURE #
proc GetOp {} {
    global opList
    set opList(if) "\{\} \{\n\n\}"
    set opList(else) "\{\n\n\}"
    set opList(elseif) "\{\} \{\n\n\}"
    set opList(for) "\{\} \{\} \{\} \{\n\n\}"
    set opList(foreach) "\{\n\n\}"
    set opList(while) "\{\} \{\n\n\}"
    set opList(switch) "\{\n\n\}"
    set opList(proc) "\{\} \{\n\n\}"
    # for Object extention
    set opList(method) "\{\} \{\n\n\}"
    set opList(class) "\{\n\n\}"
}
## Alexander Dederer (aka Korwin) dederer-a@mail.ru ##
## SETTING DEFAULT STYLE FOR TEXT WIDGET    ##
proc SetDefStyle { text args } {
    global editor(font) editor(fontBold)
    set a_args(-wrap)     none
    set a_args(-background)  white
    set a_args(-font)      {$editor(font)}
    array set a_args $args
    
    foreach { key value } [ array get a_args ] {
        catch { $text configure $key $value }
    } ;# foreach
}

## CURSOR POSITION COUNTERED ##
proc Position {} {
    global tree noteBook fontNormal fontBold replace
    set nodeEdit [$noteBook raise]
    if {$nodeEdit == "" || $nodeEdit == "newproj" || $nodeEdit == "debug" || $nodeEdit == "about"} {
        return
    }
    set text "$noteBook.f$nodeEdit.text"
    set pos [$text index insert]
    set posY [lindex [split $pos "."] 0]
    set posX [lindex [split $pos "."] 1]
    set lbl .frmStatus.frmLine.lblLine
    $lbl configure -text $pos -font $fontBold
    return $pos
}
proc ReplaceChar {text} {
    global replace
    set pos [$text index insert]
    set posY [lindex [split $pos "."] 0]
    set posX [lindex [split $pos "."] 1]
    if {$replace == 1} {
        $text delete $posY.$posX $posY.[expr $posX + 1]
    }
}
## OVERWRITE SYMBOL PROCEDURE ##
proc OverWrite {} {
    global replace fontNormal
    if {$replace == 1} {
        set replace 0
        .frmStatus.frmOvwrt.lblOvwrt configure -text [::msgcat::mc "Insert"] -font $fontNormal\
        -foreground black
    } else {
        set replace 1
        .frmStatus.frmOvwrt.lblOvwrt configure -text [::msgcat::mc "Overwrite"] -font $fontNormal\
        -foreground red
    }
}
## GOTO LINE DIALOG FORM ##
proc GoToLine {} {
    global noteBook fileList fontNormal
    set node [$noteBook raise]
    if {$node == "newproj" || $node == "settings" || $node == "about" || $node == ""} {
        return
    }
    set file $fileList($node)
    set w $noteBook.f$node.goto
    set text "$noteBook.f$node.text"
    # destroy the find window if it already exists
    if {[winfo exists $w]} {
        destroy $w
    }
    # create the new "goto" window
    toplevel $w
    wm title $w [::msgcat::mc "Goto line"]
    wm resizable $w 0 0
    wm transient $w $noteBook.f$node
    
    label $w.text -text [::msgcat::mc "Line number"] -font $fontNormal
    entry $w.entGoTo -width 6 -validate key -validatecommand "ValidNumber %W %P"
    pack $w.text $w.entGoTo -side left -anchor nw  -padx 2 -pady 2
    
    bind $w.entGoTo <Return> "+GoToLineNumber $text $noteBook.f$node"
    bind $w.entGoTo <Escape> "destroy $w"
    focus -force $w.entGoTo
}
## Check input number ##
proc ValidNumber {w value} {
    if [string is integer $value] {
        return 1
    } else {
        bell
        return 0
    }
}
## GOTO LINE ##
proc GoToLineNumber {text w} {
    set lineNumber [$w.goto.entGoTo get]
    destroy $w.goto
    catch {
        $text mark set insert $lineNumber.0
        $text see insert
        Position $text .frmStatus.frmLine.lblLine
    }
}
## SEARCH DIALOG FORM ##
set findHistory ""
set findString ""
set replaceString ""
proc Find {} {
    global noteBook fileList  findHistory findString fontNormal
    
    set node [$noteBook raise]
    if {$node == "newproj" || $node == "settings" || $node == "about" || $node == ""} {
        return
    }
    set file $fileList($node)
    set w $noteBook.f$node.find
    set text "$noteBook.f$node.text"
    set findString ""
    # destroy the find window if it already exists
    if {[winfo exists $w]} {
        destroy $w
    }
    
    toplevel $w
    wm title $w [::msgcat::mc "Find"]
    wm resizable $w 0 0
    wm transient $w $noteBook.f$node
    frame $w.frmCombo -borderwidth 1
    frame $w.frmBtn -borderwidth 1
    pack $w.frmCombo $w.frmBtn -side top -fill x
    
    #    set combo [entry $w.frmCombo.entFind]
    set combo [ComboBox $w.frmCombo.txtLocale\
    -textvariable findString \
    -selectbackground "#55c4d1" -selectborderwidth 0\
    -values $findHistory]
    
    pack $combo -fill x -padx 2 -pady 2
    
    button $w.frmBtn.btnFind -text "[::msgcat::mc "Find"] - F3"\
    -font $fontNormal -width 12 -relief groove\
    -command "FindCommand $text $w"
    button $w.frmBtn.btnCancel -text "[::msgcat::mc "Close"] - Esc"\
    -relief groove -width 12 -font $fontNormal\
    -command "destroy $w"
    pack $w.frmBtn.btnFind $w.frmBtn.btnCancel -fill x -padx 2 -pady 2 -side left
    
    bind $w <Return> "FindCommand  $text $w"
    bind $w <F3> "FindCommand  $text $w"
    bind $w <Escape> "destroy $w"
    focus -force $combo
    
    #    set findIndex [lsearch -exact $findHistory "$findString"]
    $combo setvalue @0
}

proc FindCommand {text w} {
    global findString findHistory
    #    set findString [$entry get]
    destroy $w
    # if null string? do nothing
    if {$findString == ""} {
        return
    }
    # search "again" (starting from current position)
    FindNext $text 0
}

proc FindNext {text {incr 1}} {
    global findString findHistory
    set t $text
    puts $t
    # append find string into find history list #
    if {[lsearch -exact $findHistory $findString] == -1} {
        set findHistory [linsert $findHistory 0 $findString]
    }
    
    set pos [$t index insert]
    set line [lindex [split $pos "."] 0]
    set x [lindex [split $pos "."] 1]
    incr x $incr 
    
    set pos [$t search -nocase $findString $line.$x end]
    
    # if found then move the insert cursor to that position, otherwise beep
    if {$pos != ""} {
        $t mark set insert $pos
        $t see $pos
        
        # highlight the found word
        set line [lindex [split $pos "."] 0]
        set x [lindex [split $pos "."] 1]
        set x [expr {$x + [string length $findString]}]
        $t tag remove sel 1.0 end
        $t tag add sel $pos $line.$x
        focus -force $t
        return 1
    } else {
        bell
        return 0
    }
    Position
}
## FIND FUNCTION PROCEDURE ##
proc FindProc {text findString node} {
    global noteBook
    set pos "0.0"
    $text see $pos
    set line [lindex [split $pos "."] 0]
    set x [lindex [split $pos "."] 1]
    set pos [$text search -nocase $findString $line.$x end]
    $text mark set insert $pos
    $text see $pos
    # highlight the found word
    set line [lindex [split $pos "."] 0]
    set x [lindex [split $pos "."] 1]
    set x [expr {$x + [string length $findString]}]
    $text tag remove sel 1.0 end
    $text tag add sel $pos $line.$x
    focus -force $text
    Position
    return 1
}

#3 REPLACE DIALOG FORM ##
proc ReplaceDialog {} {
    global noteBook fontNormal fontBold fileList findString replaceString text
    set node [$noteBook raise]
    if {$node == "newproj" || $node == "settings" || $node == "about" || $node == ""} {
        return
    }
    #set file $fileList($node)
    set w .replace
    set text "$noteBook.f$node.text"
    #    set findString ""
    # destroy the find window if it already exists
    if {[winfo exists $w]} {
        destroy $w
    }
    
    # create the new "find" window
    toplevel $w
    wm transient $w $noteBook.f$node
    wm title $w [::msgcat::mc "Replace"]
    wm resizable $w 0 0

    set f1 [frame $w.frmFind]
    set f2 [frame $w.frmReplace]
    set f3 [frame $w.frmBtn -borderwidth 1]
    pack $f1 $f2 $f3 -side top -fill x -expand true

    label $f1.lblFind -text [::msgcat::mc "Find"] -font $fontNormal -width 15 -anchor w
    entry $f1.entFind -width 30
    pack $f1.lblFind $f1.entFind -side left -padx 2 -pady 2
    pack $f1.entFind -side left -fill x -expand true  -padx 2 -pady 2

    label $f2.lblReplace -text [::msgcat::mc "Replace with"] -font $fontNormal -width 15 -anchor w
    entry $f2.entReplace -width 30
    pack $f2.lblReplace $f2.entReplace -side left -padx 2 -pady 2
    pack $f2.entReplace -side left -fill x -expand true -padx 2 -pady 2

    button $f3.btnFind -text "[::msgcat::mc "Find"] - Enter" -width 12 -pady 0 -font $fontNormal -relief groove\
     -command "ReplaceCommand $text $w $f1.entFind $f2.entReplace find"
    button $f3.btnReplace -text "[::msgcat::mc "Replace"] - F4" -width 12 -pady 0\
            -font $fontNormal -relief groove\
            -command {
                ReplaceCommand $text $w  .replace.frmFind.entFind .replace.frmReplace.entReplace replace
                focus -force .replace
            }
    button $f3.btnReplaceAll -text [::msgcat::mc "Replace all"] -width 12 -pady 0\
            -font $fontNormal -relief groove\
            -command "ReplaceCommand $text $w $f1.entFind $f2.entReplace replace_all"
    button $f3.btnCancel -text "[::msgcat::mc "Cancel"] - Esc" -command "destroy $w"\
      -width 12 -pady 0 -font $fontNormal -relief groove
      pack $f3.btnFind $f3.btnReplace $f3.btnReplaceAll $f3.btnCancel\
            -side left -padx 2 -pady 2 -fill x

    bind $w <Return> "ReplaceCommand $text $w  $f1.entFind $f2.entReplace find"
    bind $w <F4> "ReplaceCommand $text $w  $f1.entFind $f2.entReplace replace"
    bind $w <Escape> "destroy $w"
    focus -force $f1.entFind

    if {$findString != ""} {
        InsertEnt $f1.entFind $findString
    }
    if {$replaceString != ""} {
        InsertEnt $f2.entReplace $replaceString
    }
}
## REPLACE COMMAND ##
proc ReplaceCommand {text w entFind entReplace command} {
    global noteBook fontNormal fontBold fileList findString replaceString
    set node [$noteBook raise]
    
    set findString [$entFind get]
    set replaceString [$entReplace get]
    
    switch -- $command {
        "find" {
            FindNext $text 1
            focus -force .replace
        }
        "replace" {
            if {[Replace $text 0]} {
                FindNext $text 1
                if {[lindex $fileList($node) 1] == 0} {
                    set fileList($node) [list [lindex $fileList($node) 0] 1]
                    LabelUpdate .frmStatus.frmProgress.lblProgress [::msgcat::mc "File modify"]
                }
                focus -force .replace
            }
        }
        "replace_all" {
            set stringsReplace 0
            if {[Replace $text 0]} {
                if {[lindex $fileList($node) 1] == 0} {
                    set fileList($node) [list [lindex $fileList($node) 0] 1]
                    LabelUpdate .frmStatus.frmProgress.lblProgress [::msgcat::mc "File modify"]
                }
                incr stringsReplace
                while {[Replace $text 1]} {
                    incr stringsReplace
                }
            }
            tk_messageBox -icon info -title [::msgcat::mc "Replace"]\
            -parent $text -message\
            "[::msgcat::mc "Was replacement"] $stringsReplace."
            destroy $w
        }
    }
}
## REPLACE ONE WORD PROCEDURE ##
proc Replace {text incr} {
    global noteBook fontNormal fontBold fileList findString replaceString
    
    if {[FindNext $text $incr]} {
        set selected [$text tag ranges sel]
        set start [lindex $selected 0]
        set end [lindex $selected 1]
        $text delete $start $end
        $text insert [$text index insert] $replaceString
        return 1
    } else {
        return 0
    }
    #    focus -force .replace
}
## FILE OPERATION ##
proc FileDialog {$tree operation} {
    global noteBook fontNormal fontBold fileList noteBook projDir activeProject imgDir editor
    set dot "_"
    set types {
        {"Tcl files" {.tcl}}
        {"Tk files" {.tk}}
        {"Rivet files" {.rvt}}
        {"TclHttpd Template" {.tml}}
        {"Sql files" {.sql}}
        {"Html files" {.html}}
        {"Text files" {.txt}}
        {"JAVA files" {.java}}
        {"PERL files" {.pl}}
        {"PHP files" {.php}}
        {"FORTRAN files" {.for}}
        {"CAML or ML files" {.ml}}
        {"CAML or ML interface files" {.mli}}
        {"Ruby files" {.rb}}
        {"Text files" {} TEXT}
        {"All files" *}
    }
    
    
    if {$operation == "open"} {
        set dir $projDir
        set fullPath [tk_getOpenFile -initialdir $dir -filetypes \
        $types -parent $noteBook]
        regsub -all "." $file "_" node
        set dir [file dirname $fullPath]
        set file [file tail $fullPath]
        set name [file rootname $file]
        set ext [string range [file extension $file] 1 end]
        set node "$name$dot$ext"
        EditFile $node $fullPath
        return 1
    } elseif {$operation == "delete"} {
        set node [$tree selection get]
        set fullPath [$tree itemcget $node -data]
        set dir [file dirname $fullPath]
        set file [file tail $fullPath]
        set answer [tk_messageBox -message "[::msgcat::mc "Delete file"] \"$file\"?"\
        -type yesno -icon question -default yes]
        case $answer {
            yes {
                FileDialog close
                file delete -force "$fullPath"
                $tree delete $node
                $tree configure -redraw 1
                return 0
            }
        }
    } elseif {$operation == "close"} {
        set node [$noteBook raise]
        if {$node == "newproj" || $node == "settings" || $node == "about" || $node == "debug"} {
            $noteBook delete $node
            set node [$noteBook raise]
            return
        } else {
            if {$node == ""} {return}
            if {[info exists fileList($node)] == 0} {return}
            set fullPath [lindex $fileList($node) 0]
            set dir [file dirname $fullPath]
            set file [file tail $fullPath]
            set text "$noteBook.f$node.text"
        }
    } elseif {$operation == "close" && [info exists files] == 0} {
        return
    }  else {
        set node [$noteBook raise]
        puts $node        
        if {$node == ""} {return}
        if {[info exists fileList($node)] == 0} {return}
        set fullPath [lindex $fileList($node) 0]
        set dir [file dirname $fullPath]
        set file [file tail $fullPath]
        set text "$noteBook.f$node.text"
    }
    set name [file rootname $file]
    set ext [string range [file extension $file] 1 end]
    set treeSubNode "$name$dot$ext"
    
    set img [GetImage $file]
    
    if {$operation == "open"} {
        set fullPath [tk_getOpenFile -initialdir $dir -filetypes \
        $types -parent $noteBook]
        set file [string range $fullPath [expr [string last "/" $fullPath]+1] end]
        regsub -all "." $file "_" node
        $noteBook insert end $node -text "$file"
        EditFile $node $fullPath
    } elseif {$operation == "save"} {
        if {$name == "untitled"} {
            set file [tk_getSaveFile -initialdir $dir -filetypes \
            $types -parent $text -initialfile $file \
            -defaultextension .$ext]
            set contents [$text get 0.0 end]
            set fhandle [open "$file" "w"]
            puts $fhandle $contents nonewline
            close $fhandle
            file delete [file join $dir $name.$ext]
            #$tree delete $treeSubNode
            unset fileList($node)
            # change data into tree and notebook
            set dir [file dirname $file]
            set file [file tail $file]
            set name [file rootname $file]
            set ext [string range [file extension $file] 1 end]
            $tree itemconfigure $treeSubNode -text $name
            set treeSubNode "$activeProject$dot$name$dot$ext"
            
            #$tree insert end $activeProject $treeSubNode -text "$file" \
            #-data "[file join $dir $file]" -open 1\
            #-image [Bitmap::get [file join $imgDir $img.gif]]\
            #-font $fontNormal
            set nbNode [$noteBook raise]
            $noteBook itemconfigure $nbNode -text $file
            set fileList($nbNode) [list $file 0]
        } else {
            set contents [$text get 0.0 end]
            set fhandle [open [file join $dir $file] "w"]
            puts $fhandle $contents nonewline
            close $fhandle
            EditFlag $node [file join $dir $file] 0
        }
    } elseif {$operation == "save_all"} {
        set i 0
        set nodeList [$noteBook pages 0 end]
        set length [llength $nodeList]
        while {$i < $length} {
            set nbNode [lindex $nodeList $i]
            if {[info exists fileList($nbNode)] == 1} {
                set text "$noteBook.f$nbNode.text"
                set savedFile [lindex $fileList($nbNode) 0]
                set contents [$text get 0.0 end]
                set fhandle [open [file join $dir $savedFile] "w"]
                puts $fhandle $contents nonewline
                close $fhandle
                EditFlag $nbNode [file join $dir $savedFile] 0
            }
            incr i
        }
    } elseif {$operation == "close"} {
        # delete file name from fileList array #
        if {$node == "newproj" || $node == "settings" || $node == "about" || $node == "debug"} {
            $noteBook delete $node
            set node [$noteBook raise]
            return
        }
        set editFlag [lindex $fileList($node) 1]
        set closedFile [file tail [lindex $fileList($node) 0]]
        if {$editFlag == 1} {
            set answer [tk_messageBox\
            -message "$closedFile [::msgcat::mc "File was modifyed. Save?"]"\
            -type yesnocancel -icon warning\
            -title [::msgcat::mc "Warning"]]
            case $answer {
                yes {
                    FileDialog save
                    #                    FileDialog close
                }
                no {
                    set index 0
                    set nl [$tree nodes $node 0 end]
                    if {$nl != ""} {
                        foreach n $nl {
                            $tree delete $n
                        }
                    }
                    $noteBook delete $node
                    unset fileList($node)
                    $noteBook raise [$noteBook page $index]
                    set node [$noteBook raise]
                }
                cancel {
                    return 0
                }
            }
        } else {
            set index 0
            set nl [$tree nodes $node 0 end]
            if {$nl != ""} {
                foreach n $nl {
                    $tree delete $n
                }
            }
            #puts $node
            $noteBook delete $node
            unset fileList($node)
            $noteBook raise [$noteBook page $index]
            set node [$noteBook raise]
        }
        if {$node != ""} {
            if {$node == "newproj" || $node == "settings" || $node == "about" || $node == "debug"} {
                $noteBook delete $node
            } else {
                focus -force $noteBook.f$node
            }
            $tree selection set $node
        } else {
            LabelUpdate .frmStatus.frmLine.lblLine ""
            LabelUpdate .frmStatus.frmFile.lblFile ""
            LabelUpdate .frmStatus.frmOvwrt.lblOvwrt ""
            LabelUpdate .frmStatus.frmProgress.lblProgress ""
        }
    } elseif {$operation == "close_all"} {
        set nodeList [$noteBook pages 0 end]
        $noteBook raise [$noteBook page 0]
        set nbNode [$noteBook raise]
        while {$nbNode != ""} {
            if {$nbNode == "newproj" || $nbNode == "settings" || $nbNode == "about" || $nbNode == "debug"} {
                $noteBook delete $nbNode
                $noteBook raise [$noteBook page 0]
                set nbNode [$noteBook raise]
            }
            if {[info exists fileList($nbNode)] == 1} {
                set editFlag [lindex $fileList($nbNode) 1]
                if {$editFlag == 1} {
                    set f [lindex $fileList($nbNode) 0]
                    set f [file tail $f]
                    set answer [tk_messageBox\
                    -message "$f [::msgcat::mc "File was modifyed. Save?"]"\
                    -type yesnocancel -icon warning\
                    -title [::msgcat::mc "Warning"]]
                    case $answer {
                        yes {
                            FileDialog save
                        }
                        no {}
                        cancel {return cancel}
                    }
                }
                set nl [$tree nodes $nbNode 0 end]
                if {$nl != ""} {
                    foreach n $nl {
                        $tree delete $n
                    }
                }
                $noteBook delete $nbNode
                $noteBook raise [$noteBook page 0]
                unset fileList($nbNode)
                set nbNode [$noteBook raise]
            }
        }
        LabelUpdate .frmStatus.frmLine.lblLine ""
        LabelUpdate .frmStatus.frmFile.lblFile ""
        LabelUpdate .frmStatus.frmOvwrt.lblOvwrt ""
        
    } elseif {$operation == "save_as"} {
        set file [tk_getSaveFile -initialdir $dir -filetypes \
        $types -parent $text -initialfile $file]
        if {$file != ""} {
            set contents [$text get 0.0 end]
            set fhandle [open $file "w"]
            puts $fhandle $contents nonewline
            close $fhandle
            set dir [file dirname $file]
            set file [file tail $file]
            set name [string range $file 0 [expr [string last "." $file]-1]]
            if {[string last "." $file] == -1} {
                set ext [string range [file extension $file] 1 end]
            } else {
                set ext ""
            }
            set treeSubNode "$activeProject$dot$name$dot$ext"
            $tree insert end $activeProject $treeSubNode -text "$file" \
            -data "[file join $dir $file]" -open 1\
            -image [Bitmap::get [file join $imgDir $img.gif]]\
            -font $fontNormal
            set nbNode [$noteBook raise]
            $noteBook itemconfigure $nbNode -text $file
            set fileList($nbNode) [list $file 0]
        }
        return 0
    }
}
## COMPLITE PRODEDURE AND OPERATOR ##
proc OpComplite {text fileExt node} {
    global opList autoFormat fileList
    if {$node == "newproj" || $node == "settings" || $node == "about"} {return}
    
    set pos [$text index insert]
    set line [lindex [split $pos "."] 0]
    set posNum [lindex [split $pos "."] 1]
    set string [$text get $line.0 $pos]
    set first [string wordstart $string [expr $posNum-1]]
    set op [string range $string $first $posNum]
    if {[info exists opList($op)] == 1} {
        if {[string match "*\{" [$text get $pos $line.end]] != 1} {
            $text insert $pos $opList($op)
            set x [expr $posNum + 2]
            $text mark set insert $line.$posNum
            $text see $line.$posNum
        } else {
            return
        }
    }
}
## OPEN AND CLOSE BRACE HIGHLIGHT ##
proc BraceHighLight {text} {
    set pos [$text index insert]
    set lineNum [lindex [split $pos "."] 0]
    set posNum [lindex [split $pos "."] 1]
    set curChar [$text get $lineNum.$posNum $lineNum.[expr $posNum+1]]
    #    _searchCloseBracket $text \{ \} insert end]
    
}


## NOTEBOOK PAGE SWITCHER ##
## NOTEBOOK PAGE SWITCHER ##
proc PageTab {key} {
    global noteBook tree fileList editor
    set nb $noteBook
    set len [llength [$nb pages]]
    if {$len > 0} {
        set newIndex [expr [$nb index [$nb raise]] + $key]
        if {$newIndex < 0} {
            set newIndex [expr $len - 1]
        } elseif {$newIndex >= $len} {
            set newIndex 0
        }
        $nb see [lindex [$nb pages] $newIndex]
        $nb raise [lindex [$nb pages] $newIndex]
        PageRaise $tree [lindex [$nb pages] $newIndex]
    }
}

proc _PageTab {} {
    global noteBook tree fileList editor
    set nodeList [$noteBook pages 0 end]
    set length [llength $nodeList]
    set node [$noteBook raise]
    set nodeIndex [$noteBook index $node]
    if {$nodeIndex == [expr $length-1]} {
        set nextNode [$noteBook page 0]
    } else {
        set nextNode [$noteBook page [expr $nodeIndex + 1]]
    }
    $noteBook raise $nextNode
    
    if {$nextNode == "newproj" || $nextNode == "settings" || $nextNode == "about" || $nextNode == "debug"} {
        return
    } else {
        $tree selection set $nextNode
        $tree see $nextNode
        set item [$tree itemcget $nextNode -data]
        focus -force $noteBook.f$nextNode.text
        LabelUpdate .frmStatus.frmHelp.lblHelp "[FileAttr $item]"
        LabelUpdate .frmStatus.frmFile.lblFile "[file size $item] b."
        if {[lindex $fileList($nextNode) 1] == 0} {
            LabelUpdate .frmStatus.frmProgress.lblProgress ""            
            $noteBook itemconfigure $node -foreground $editor(nbNormal)
        } else {
            LabelUpdate .frmStatus.frmProgress.lblProgress [::msgcat::mc "File modify"]
            $noteBook itemconfigure $node -foreground $editor(nbModify)
        }
    }
}
## RAISED NOTEBOOK TAB IF CLICK MOUSE BUTTON ##
proc PageRaise {tree node} {
    global noteBook fileList editor nodeEdit
    #puts $node
    $noteBook raise $node
    set nodeEdit [$noteBook raise]
    #set nodeEdit $node
    puts $node
    puts $nodeEdit
    if {$node == "newproj" || $node == "settings" || $node == "about" || $node == "debug"} {
        return
    } else {
        $tree selection set $node
        $tree see $node
        set item [$tree itemcget $node -data]
        puts $item ;# debug
        set ext [GetExtention $node]
        if {$ext == "gif" || $ext == "jpg" || $ext == "png" || $ext == "xpm"  || $ext == "xbm"} {
            focus -force $noteBook.f$node.f.c
        } else {
            focus -force $noteBook.f$node.text
            Position
        }
        LabelUpdate .frmStatus.frmHelp.lblHelp "[FileAttr $item]"
        LabelUpdate .frmStatus.frmFile.lblFile "[file size $item] b."
        if {[lindex $fileList($node) 1] == 0} {
            LabelUpdate .frmStatus.frmProgress.lblProgress ""
            $noteBook itemconfigure $node -foreground $editor(nbNormal)
        } else {
            LabelUpdate .frmStatus.frmProgress.lblProgress [::msgcat::mc "File modify"]
            $noteBook itemconfigure $node -foreground $editor(nbModify)
        }
    }
}

## TABULAR INSERT (auto indent)##
proc TabIns {text} {
    set tabSize 4
    set indentSize 4
    set pos [$text index insert]
    set lineNum [lindex [split $pos "."] 0]
    set posNum [lindex [split $pos "."] 1]
    if {$lineNum > 1} {
        # get current text
        set curText [$text get $lineNum.0 "$lineNum.0 lineend"]
        #get text of prev line
        set prevLineNum [expr {$lineNum - 1}]
        set prevText [$text get $prevLineNum.0 "$prevLineNum.0 lineend"]
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
            $text insert $lineNum.0 $incSpaces
        } elseif {$shouldBeSpaces < $spaceNum} {
            #delete spaces
            set deltaSpace [expr {$spaceNum - $shouldBeSpaces}]
            $text delete $lineNum.0 $lineNum.$deltaSpace
        }
    }
}

proc EditFlag {node file flag} {
    global fileList editor noteBook
    if {$flag == 0} {
        set fileList($node) [list $file 0]
        LabelUpdate .frmStatus.frmProgress.lblProgress [::msgcat::mc "File saved"]
        $noteBook itemconfigure $node -foreground $editor(nbNormal)
    } else {
        set fileList($node) [list $file end 1]
        LabelUpdate .frmStatus.frmProgress.lblProgress [::msgcat::mc "File modify"]
        $noteBook itemconfigure $node -foreground $editor(nbModify)
    }
}
proc TextEncode {encode} {
    global fileList editor noteBook
    set node [$noteBook raise]
    if {$node == "newproj" || $node == "settings" || $node == "about" || $node == ""} {
        return
    }
    #set file $fileList($node)
    set w .replace
    set text "$noteBook.f$node.text"
    set contents [$text get 0.0 end]
    #puts "[lindex $files($activeFile) 2] $encode"
    set contents [encoding convertfrom $encode $contents]
    #set contents [encoding convertfrom $encode $contents]
    $text delete 0.0 end
    $text insert end $contents
    unset text
    #SetEncode $encode
}

## EDITING  FILE ##
proc EditFile {tree node fileName} {
    global projDir workDir imgDir  noteBook fontNormal fontBold w fileList replace nodeEdit procList
    global backUpFileCreate fileExt progress editor braceHighLightBG braceHighLightFG activeProject
    set nodeEdit $node
    set replace 0
    set file [file tail $fileName]
    set name [file rootname $file]
    set fileExt [string range [file extension $fileName] 1 end]
    set parentNode  [$tree parent $node]
    set project [$tree itemcget $parentNode -data]
    set w [$noteBook insert end $node -text "$file" -image [Bitmap::get [file join $imgDir [GetImage $fileName].gif]]]
    # create array with file names #
    if {[info exists fileList($node)] != 1} {
        set fileList($node) [list $fileName 0]
        LabelUpdate .frmStatus.frmProgress.lblProgress ""
    }    
    if {$fileExt == "gif" || $fileExt == "jpg" || $fileExt == "png"  || $fileExt == "xpm" || $fileExt == "xbm"} {
        ImageViewer $fileName $w $node
        #$scrwin setwidget $w.Ó
        $noteBook raise $node
        return
    }
    set scrwin [ScrolledWindow $w.scrwin -bg $editor(bg)]
    pack $scrwin -fill both -expand true
    text $w.text\
    -relief sunken -wrap $editor(wrap) -highlightthickness 0 -undo 1 -font $editor(font)\
    -selectborderwidth 0 -selectbackground $editor(selectbg) -width 10 -background $editor(bg) -foreground $editor(fg)
    
    pack $w.text -side left -fill both -expand true
    $scrwin setwidget $w.text
    
    if {$backUpFileCreate == "Yes"} {file copy -force $fileName "$fileName~"}
    
    $noteBook raise $node
    set procName ""
    set file [open "$fileName" r]
    set lineNumber 1
    #    Progress start
    #    LabelUpdate .frmStatus.frmProgress.lblProgress "[::msgcat::mc "Opened file in progress"]"
    
    while {[gets $file line]>=0} {
        # Insert procedure names into tree #
        regsub -all {\t} $line "        " line
        $w.text insert end "$line\n"
        #        set progress $lineNumber
        set keyWord ""
        set procName ""                                                         
        
        if {$fileExt == "php" || $fileExt == "phtml"} {
            regexp -nocase -all -- {(function) (.*?)\(} $line match keyWord procName
            #puts "$keyWord --- $procName"
            
        } else {
            scan $line "%s%s" keyWord procName
        }
        # && $procName != ""
        if {$keyWord == "proc" || $keyWord == "let" || $keyWord == "class" || $keyWord == "sub" || $keyWord == "function" || $keyWord == "fun" } {
            set dot "_"
            set openBrace [string first "\{" $line]
            set closeBrace [expr [string first "\}" $line]-1]
            set var [string range $line $openBrace end]
            regsub -all ":" $procName "_" prcNode
            if {$keyWord == "proc" || $keyWord == "sub" || $keyWord == "function"  || $keyWord == "let"} {
                set img "proc.gif"
            } elseif {$keyWord == "class"} {
                set img "class.gif"
            }
            if {$keyWord =="proc"} {
                lappend procList($activeProject) [list $procName "param"]
                #$w.text tag add procName $lineNumber.[expr $startPos + $length] $lineNumber.[string wordend $line [expr $startPos + $length +2]]
            }
            if {[$tree exists $prcNode$dot$lineNumber] !=1} {
                $tree insert end $node $prcNode$dot$lineNumber -text $procName \
                -data "prc_$procName"\
                -image [Bitmap::get [file join $imgDir $img]] -font $fontNormal
            }
        }
        if {$keyWord =="set"} {
            lappend varList($activeProject) [list $procName "param"]]
        }
        incr lineNumber
    }
    close $file
    $w.text mark set insert 0.0
    $w.text see insert
    $w.text tag configure lightBracket -background #000000 -foreground #00ffff
    
    # key bindings #
    set text $w.text
    bind $text <Return> {
        regexp {^(\s*)} [%W get "insert linestart" end] -> spaceStart
        %W insert insert "\n$spaceStart"
        break
    }    
    bind $text <Control-idiaeresis> GoToLine
    bind $text <Control-g> GoToLine
    bind $text <Control-agrave> Find
    bind $text <Control-f> Find
    bind $text <F3> {FindNext $w.text 1}
    bind $text <Control-ecircumflex> ReplaceDialog
    bind $text <Control-r> ReplaceDialog
    bind $text <F4> {ReplaceCommand $w.text 1}
    bind $text <Control-ucircumflex> {FileDialog save}
    bind $text <Control-s> {FileDialog save}
    bind $text <Control-ocircumflex> {FileDialog save_as}
    bind $text <Shift-Control-s> {FileDialog save_as}
    bind $text <Control-odiaeresis> {FileDialog close}
    bind $text <Control-w> {FileDialog close}
    bind $text <Control-division> "tk_textCut $w.text;break"
    bind $text <Control-x> "tk_textCut $w.text;break"
    bind $text <Control-ntilde> "tk_textCopy $w.text;break"
    bind $text <Control-c> "tk_textCopy $w.text;break"
    bind $text <Control-igrave> "tk_textPaste $w.text;break"
    bind $text <Control-v> {TextOperation paste; break}
    
    bind $text <Control-adiaeresis> "auto_completition $text"
    bind $text <Control-l> "auto_completition $text"
    bind $text <Control-icircumflex> "auto_completition_proc $text"
    bind $text <Control-j> "auto_completition_proc $text"
    bind $text <Control-q> Find
    bind $text <Control-comma> {TextOperation comment}
    bind $text <Control-period> {TextOperation uncomment}
    bind $text <Control-eacute> Find
    #bind . <Control-m> PageTab
    #bind . <Control-udiaeresis> PageTab
    bind $text <Insert> {OverWrite}
    bind $text <ButtonRelease-1> {Position}
    bind $text <Button-3> {catch [PopupMenuEditor %X %Y]}
    bind $text <Button-4> "%W yview scroll -3 units"
    bind $text <Button-5> "%W yview scroll  3 units"
    #bind $text <Shift-Button-4> "%W xview scroll -2 units"
    #bind $text <Shift-Button-5> "%W xview scroll  2 units"
    
    bind $text <KeyRelease> {
        Position
        set nodeEdit [$noteBook raise]
        if {$nodeEdit == "" || $nodeEdit == "newproj" || $nodeEdit == "settings" || $nodeEdit == "about" || $nodeEdit == "debug"} {
        } else {
            set textEdit "$noteBook.f$nodeEdit.text"
            set pos [$textEdit index insert]
            set line [lindex [split $pos "."] 0]
            set editLine [$textEdit get $line.0 $pos]
            if {$autoFormat == "Yes"} {
                if {$fileExt != "for"} {
                    TabIns $textEdit
                }
            }
            HighLight $fileExt $textEdit $editLine $line $nodeEdit
        }
    }
    bind $text <KeyPress> {
        if {$nodeEdit == "" || $nodeEdit == "newproj" || $nodeEdit == "settings" || $nodeEdit == "about"  || $nodeEdit == "debug"} {
        } else {
            set nodeEdit [$noteBook raise]
            if {[Key %k] == "true"} {
                if {[lindex $fileList($nodeEdit) 1] == 0} {
                    set fileList($nodeEdit) [list [lindex $fileList($nodeEdit) 0] 1]
                    LabelUpdate .frmStatus.frmProgress.lblProgress [::msgcat::mc "File modify"]
                    $noteBook itemconfigure $nodeEdit -foreground $editor(nbModify)
                }
                ReplaceChar %W
            };# if
        };# if
    };# bind
    bind $text <Key-space> {
        if {$nodeEdit == ""} {return}
        set textEdit "$noteBook.f$nodeEdit.text"
        OpComplite $textEdit $fileExt $nodeEdit
        if {[lindex $fileList($nodeEdit) 1] == 0} {
            set fileList($nodeEdit) [list [lindex $fileList($nodeEdit) 0] 1]
            LabelUpdate .frmStatus.frmProgress.lblProgress [::msgcat::mc "File modify"]
            $noteBook itemconfigure $nodeEdit -foreground  $editor(nbModify)
        }
    }
    # Alexander Dederer (aka Korwin)
    # bind like VI editor
    bind $text <Control-u> {
        set i -1
        switch -- [%W get "insert - 1 chars"] {
            \{ {set i [_searchCloseBracket %W \{ \} insert end]}
            \[ {set i [_searchCloseBracket %W \[ \] insert end]}
            (  {set i [_searchCloseBracket %W  (  ) insert end]}
            \} {set i [_searchOpenBracket  %W \{ \} insert 1.0]}
            \] {set i [_searchOpenBracket  %W \[ \] insert 1.0]}
            )  {set i [_searchOpenBracket  %W  (  ) insert 1.0]}
        } ;# switch
        if { $i != -1 } {
            %W mark set insert $i
            %W see insert
        }
    } ;# bind
    bindtags $text [list [winfo toplevel $text] $text Text sysAfter all]
    bind sysAfter <Any-Key> {+ set i -1
            catch {
            switch -- [%W get "insert - 1 chars"] {
                \{ {set i [_searchCloseBracket %W \{ \} insert end]}
                \[ {set i [_searchCloseBracket %W \[ \] insert end]}
                ( {set i [_searchCloseBracket %W (   ) insert end]}
                \} {set i [_searchOpenBracket  %W \{ \} insert 1.0]}
                \] {set i [_searchOpenBracket  %W \[ \] insert 1.0]}
                ) {set i [_searchOpenBracket  %W  (  ) insert 1.0]}
            } ;# switch
            catch { %W tag remove lightBracket 1.0 end }
            if { $i != -1 } {
                %W tag add lightBracket "$i - 1 chars" $i
            };#if
        };#catch
    } ;# bind sysAfter
    
    bind sysAfter <Button-1> [bind sysAfter <Any-Key>]
    focus -force $w.text
    Position
    .frmStatus.frmOvwrt.lblOvwrt configure -text [::msgcat::mc "Insert"] -font $fontNormal
    bind $text <Insert> {OverWrite; break}
    ## READ TEXT FOR HIGHLIGHTNING ##
    set lineNum 1
    while {$lineNum <=[expr $lineNumber + 1]} {
        set line [$w.text get $lineNum.0 $lineNum.end]
        HighLight $fileExt $w.text $line $lineNum $nodeEdit
        incr lineNum
    }
}
## GET KEYS CODE ##
proc Key {key} {
    if {$key >= 10 && $key <= 22} {return "true"}
    if {$key >= 24 && $key <= 36} {return "true"}
    if {$key >= 38 && $key <= 50} {return "true"}
    if {$key >= 51 && $key <= 61 && $key != 58} {return "true"}
    if {$key >= 79 && $key <= 91} {return "true"}
    if {$key == 63 || $key == 107 || $key == 108 || $key == 112} {return "true"}
}
# "Alexander Dederer (aka Korwin)
## Search close bracket in editor widget
proc _searchCloseBracket { widget o_bracket c_bracket start_pos end_pos } {
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
    set o_count 0
    set c_count 1
    set found 0
    set pattern "\[\\$o_bracket\\$c_bracket\]"
    set pos [$widget search -backward -regexp -- $pattern "$start_pos - 1 chars" $end_pos]
    while { ! [string equal $pos {}] } {
        set char [$widget get $pos]
        #tk_messageBox -title $pattern -message "char: $char; $pos; o_count=$o_count; c_count=$c_count"
        if {[string equal $char $o_bracket]} {incr o_count ; set found 1}
        if {[string equal $char $c_bracket]} {incr c_count ; set found 1}
        if {($found == 1) && ($o_count == $c_count) } { return [$widget index "$pos + 1 chars"] }
        set found 0
        set start_pos "$pos - 0 chars"
        set pos [$widget search -backward -regexp -- $pattern $start_pos $end_pos]
    } ;# while search
    return -1
} ;# proc _searchOpenBracket

proc SelectAll {text} {
    global noteBook
    
    $text tag remove sel 1.0 end
    $text tag add sel 1.0 end
    
}

proc TextOperation {oper} {
    global noteBook fileList autoFormat
    set nb [$noteBook raise]
    if {$nb == "" || $nb == "newproj" || $nb == "about" || $nb == "debug"} {
        return
    }
    set nb "$noteBook.f$nb"
    switch $oper {
        "copy" {tk_textCopy $nb.text}
        "paste" {
            set startPos [Position]
            set nodeEdit [$noteBook raise]
            EditFlag $nodeEdit [lindex $fileList($nodeEdit) 0] 1
            set fileList($nodeEdit) [list [lindex $fileList($nodeEdit) 0] 1]
            set fileExt [string range [file extension [lindex $fileList($nodeEdit) 0]] 1 end]
            tk_textPaste $noteBook.f$nodeEdit.text
            set endPos [Position]
            set lineBegin [lindex [split $startPos "."] 0]
            set lineEnd [lindex [split $endPos "."] 0]
            for {set line $lineBegin} {$line <= $lineEnd} {incr line} {
                if {$nodeEdit == "" || $nodeEdit == "newproj" || $nodeEdit == "settings" || $nodeEdit == "about" || $nodeEdit == "debug"} {
                } else {
                    set textEdit "$noteBook.f$nodeEdit.text"
                    set editLine [$textEdit get $line.0 $line.end]
                    if {$autoFormat == "Yes"} {
                        if {$fileExt != "for"} {
                            TabIns $textEdit
                        }
                    }
                    HighLight $fileExt $textEdit $editLine $line $nodeEdit
                }
            }
        }
        "cut" {tk_textCut $nb.text}
        "redo" {$nb.text edit redo}
        "undo" {$nb.text edit undo}
        "comment" {
            set selIndex [$nb.text tag ranges sel]
            if {$selIndex != ""} {
                set lineBegin [lindex [split [lindex $selIndex 0] "."] 0]
                set lineEnd [lindex [split [lindex $selIndex 1] "."] 0]
                for {set i $lineBegin} {$i <=$lineEnd} {incr i} {
                    $nb.text insert $i.0 "# "
                }
                $nb.text tag add comments $lineBegin.0 $lineEnd.end
                $nb.text tag raise comments
            } else {
                return
            }
        }
        "uncomment" {
            set selIndex [$nb.text tag ranges sel]
            if {$selIndex != ""} {
                set lineBegin [lindex [split [lindex $selIndex 0] "."] 0]
                set lineEnd [lindex [split [lindex $selIndex 1] "."] 0]
                for {set i $lineBegin} {$i <=$lineEnd} {incr i} {
                    set str [$nb.text get $i.0 $i.end]
                    if {[regexp -nocase -all -line -- {(^| )(#+)(.+)} $str match v1 v2 v3]} {
                        $nb.text delete $i.0 $i.end
                        $nb.text insert $i.0 $v3
                    }
                }
                $nb.text tag remove comments $lineBegin.0 $lineEnd.end
            } else {
                return
            }
        }
    }
    unset nb
}
#################################### 
GetOp








