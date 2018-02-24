#!
######################################################
#                projman
#        Distributed under GNU Public License
# Author: Sergey Kalinin s.v.kalinin28@gmail.com
# Copyright (c) "https://nuk-svk.ru", 2018, https://bitbucket.org/svk28/projman
######################################################

## FILE OPERATION ##
proc FileDialog {nbNode operation} {
    global noteBook noteBookFiles fontNormal fontBold
    global fileList projDir activeProject imgDir editor
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
    variable tree
    if {$nbNode eq "files"} {
        set tree .frmBody.frmCat.noteBook.ffiles.frmTreeFiles.treeFiles
    } elseif {$nbNode eq "projects"} {
        set tree .frmBody.frmCat.noteBook.fprojects.frmTree.tree 
    }
    
    if {$operation == "open"} {
        set dir $projDir
        set fullPath [tk_getOpenFile -initialdir $dir -filetypes $types -parent $noteBook]
        set file [string range $fullPath [expr [string last "/" $fullPath]+1] end]
        regsub -all "." $file "_" node
        set dir [file dirname $fullPath]
        set file [file tail $fullPath]
        set name [file rootname $file]
        set ext [string range [file extension $file] 1 end]
        set node "$name$dot$ext"
        EditFile $tree $node $fullPath
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
                FileDialog $tree close
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
        set fullPath [tk_getOpenFile -initialdir $dir -filetypes $types -parent $noteBook]
        puts $fullPath
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
            set fhandle [open [file join $dir $file] "w"]
            set lineNumber 1
            #    Progress start
            #    LabelUpdate .frmStatus.frmProgress.lblProgress "[::msgcat::mc "Opened file in progress"]"
            set linesCount [$text count -lines $lineNumber.0 end]
            foreach item [$tree nodes $node] {
                puts $item
                $tree delete $item
            }
            for {set lineNumber 1} {$lineNumber <= $linesCount} {incr lineNumber} {
                set line [$text get $lineNumber.0 $lineNumber.end]
                #puts $line
                puts $fhandle $line
                ReadFileStructure "updateFile" $line $lineNumber $tree $node
                #exit
            }
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
        set tree [GetTreeForNode $node]
        set editFlag [lindex $fileList($node) 1]
        set closedFile [file tail [lindex $fileList($node) 0]]
        if {$editFlag == 1} {
            set answer [tk_messageBox\
            -message "$closedFile [::msgcat::mc "File was modifyed. Save?"]"\
            -type yesnocancel -icon warning\
            -title [::msgcat::mc "Warning"]]
            case $answer {
                yes {
                    FileDialog $tree save
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
            set tree [GetTreeForNode $node]
            focus $tree
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
        set tree [GetTreeForNode $nbNode]
        if {$tree eq ".frmBody.frmCat.noteBook.ffiles.frmTreeFiles.treeFiles"} {
            $noteBookFiles raise files
        } elseif {$tree eq ".frmBody.frmCat.noteBook.fprojects.frmTree.tree"} {
            $noteBookFiles raise projects
        }
        
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
                            FileDialog $tree save
                        }
                        no {}
                        cancel {return cancel}
                    }
                }
                set tree [GetTreeForNode $nbNode]
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


namespace eval FileOperation {
    global noteBook fontNormal fontBold fileList noteBook projDir activeProject imgDir editor
}
proc FileOperation::Open {} {
    set dir $projDir
    set fullPath [tk_getOpenFile -initialdir $dir -filetypes $types -parent $noteBook]
    set file [string range $fullPath [expr [string last "/" $fullPath]+1] end]
    regsub -all "." $file "_" node
    set dir [file dirname $fullPath]
    set file [file tail $fullPath]
    set name [file rootname $file]
    set ext [string range [file extension $file] 1 end]
    set node "$name$dot$ext"
    EditFile $node $fullPath
    return 1
}
proc FileOperation::Close {} {
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
}
proc FileOperation::Save {} {
    
}
proc FileOperation::SaveAll {} {
    
}
proc FileOperation::Delete {} {
    set node [$tree selection get]
    set fullPath [$tree itemcget $node -data]
    set dir [file dirname $fullPath]
    set file [file tail $fullPath]
    set answer [tk_messageBox -message "[::msgcat::mc "Delete file"] \"$file\"?"\
    -type yesno -icon question -default yes]
    case $answer {
        yes {
            FileDialog $tree close
            file delete -force "$fullPath"
            $tree delete $node
            $tree configure -redraw 1
            return 0
        }
    }
}
## FILE OPERATION ##
proc FileOperation::FileDialog {tree operation} {
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
        FileOperation::Open
    } elseif {$operation == "delete"} {
        FileOperation::Delete
    } elseif {$operation == "close"} {
        FileOperation::Close
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
        set fullPath [tk_getOpenFile -initialdir $dir -filetypes $types -parent $noteBook]
        puts $fullPath
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
                    FileDialog $tree save
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
                            FileDialog $tree save
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








