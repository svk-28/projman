#####################################################
#                Tcl/Tk Project Manager
#        Distributed under GNU Public License
# Author: Sergey Kalinin s.v.kalinin28@gmail.com
# Copyright (c) "https://nuk-svk.ru", 2018
# Git repo: https://bitbucket.org/svk28/projman
####################################################
#
# Procedure for operation wwith Tree widget
#
####################################################

proc GetAllDirs {treeFiles} {
    global projDir workDir fontNormal imgDir module env
    set rList ""
    set rootDir $env(HOME)
    if {[catch {cd $rootDir}] != 0} {
        return ""
    }
    set rootNode [$treeFiles insert end root $rootDir -text "$rootDir" -font $fontNormal \
    -data "dir_root" -open 1\
    -image [Bitmap::get [file join $imgDir folder.gif]]]
    
    GetFiles $treeFiles $rootNode [file join $rootDir]    
    $treeFiles configure -redraw 1
}
proc GetFilesSubdir {tree node dir} {
    global  fontNormal projDir workDir activeProject imgDir
    global backUpFileShow dotFileShow
    set rList ""
    puts "$tree $node $dir"
    if {[catch {cd $dir}] != 0} {
        return ""
    }
    if {$dotFileShow eq "Yes"} {
        foreach file [lsort [glob -nocomplain .*]] {
            if {$file != "." || $file != ".."} {
                lappend rList [list [file join $dir $file]]
                set fileName [file join $dir $file]
                GetFile $tree $fileName $parent
            }
        }
    }
    foreach file [lsort [glob -nocomplain *]] {
        lappend rList [list [file join $dir $file]]
        set fileName [file join $dir $file]
        GetFile $tree $fileName $parent
    }
    $tree itemconfigure $node -open 1
}
## GETTING FILES FROM PROJECT DIR AND INSERT INTO TREE WIDGET ##
proc GetFile {tree fileName parent} {
    global  fontNormal backUpFileShow dotFileShow imgDir
    set img [GetImage $fileName]
    set dot "_"
    regsub -all {\.|/|\\} $fileName "_" subNode
    puts $subNode
    if {[$tree exists $subNode] != 1} {
        $tree insert end $parent $subNode -text [file tail $fileName] \
        -data $fileName -open 1\
        -image [Bitmap::get [file join $imgDir $img.gif]]\
        -font $fontNormal
    }   
}
proc GetFiles {tree parent dir} {
    global  fontNormal backUpFileShow dotFileShow imgDir
    set rList ""
    puts "$dir $parent $tree"
    if {[catch {cd $dir}] != 0} {
        return ""
    }
    if {$dotFileShow eq "Yes"} {
        foreach file [lsort [glob -nocomplain .*]] {
            if {$file != "." || $file != ".."} {
                lappend rList [list [file join $dir $file]]
                set fileName [file join $dir $file]
                
                GetFile $tree $fileName $parent
            }
        }
    }
    
    foreach file [lsort [glob -nocomplain *]] {
        lappend rList [list [file join $dir $file]]
        set fileName [file join $dir $file]
        GetFile $tree $fileName $parent
    }
    $tree configure -redraw 1
}

## GETTING PROJECT NAMES FROM DIR AND PUTS INTO 
proc GetProj {tree} {
    global projDir workDir fontNormal imgDir module
    set rList ""
    #set tree .frmBody.frmCat.noteBook.fprojects.frmTree.tree 
        
    if {[catch {cd $workDir}] != 0} {
        return ""
    }
    foreach proj [lsort [glob -nocomplain *.proj]] {
        lappend rList [list [file join $workDir $proj]]
        set projFile [open [file join $workDir $proj] r]
        set prjName [file rootname $proj]
        while {[gets $projFile line]>=0} {
            scan $line "%s" keyWord
            set string [string range $line [string first "\"" $line] [string last "\"" $line]]
            set string [string trim $string "\""]
            if {$keyWord == "ProjectName"} {
                regsub -all " " $string "_" project
                set projName "$string"
            }
            if {$keyWord == "ProjectDirName"} {
                set projList($prjName) [file dirname $string]
                #puts "$tree $projList($prjName) - $prjName - $string"
                $tree insert end root $prjName -text "$projName" -font $fontNormal \
                -data "prj_$prjName" -open 0\
                -image [Bitmap::get [file join $imgDir folder.gif]]
                #puts "GetFiles $tree $prjName $string"
                GetFiles $tree $prjName $string
                #$tree itemconfigure $prjName -open 1
                
            }
        }
    }
    $tree configure -redraw 1
}

## SHOW PUP-UP MENUS ## 
proc PopupMenuFileTree {treeFiles x y} {
    if {[$treeFiles selection get] != ""} {
        set node [$treeFiles selection get]
        $treeFiles selection set $node
    } else {
        return
    }
    if {[info exists fileList($node)] != 1} {
        tk_popup .popupFile $x $y
    }
}

proc PopupMenuTree {x y} {
    global tree fontNormal fontBold imgDir activeProject
    if {[$tree selection get] != ""} {
        set node [$tree selection get]
        $tree selection set $node
    } else {
        return
    }
    
    #$tree selection set $node
    set item [$tree itemcget $node -data]
    if {[string range $item 0 2] == "prj"} {
        set activeProject [string range $item 4 end]
        .frmStatus.frmActive.lblActive configure -text [$tree itemcget $node -text] -font $fontBold
        tk_popup .popupProj $x $y
        return
    }
    if {[info exists fileList($node)] != 1} {
        #        set fileList($node) $item
        tk_popup .popupFile $x $y
    }
}


## OPEN TREE PROCEDURE
proc TreeOpen {node} {
    global fontNormal tree projDir workDir activeProject fileList noteBook findString imgDir fontBold
    set tree [GetTreeForNode $node]
    $tree selection set $node
    set item [$tree itemcget $node -data]
    if {[string range $item 0 2] == "prj"} {
        set activeProject [string range $item 4 end]
        #puts $activeProject
        .frmStatus.frmActive.lblActive configure -text [$tree itemcget $node -text] -font $fontBold
        $tree itemconfigure $node -image [Bitmap::get [file join $imgDir openfold.gif]] 
        if {[file exists [file join $workDir $activeProject.tags]] == 1} {
            GetTagList [file join $workDir $activeProject.tags] ;# geting tag list
        } else {
            DoModule ctags
        }
    }
    if {[info exists fileList($node)] != 1} {
        set fileList($node) $item
        if {[file isdirectory $item] == 1} {
            $tree itemconfigure $node -image [Bitmap::get [file join $imgDir openfold.gif]] 
        }
    }
}
## CLOSE TREE PROCEDURE ##
proc TreeClose {node} {
    global fontNormal tree projDir workDir activeProject fileList noteBook findString imgDir fontBold
    set tree [GetTreeForNode $node]
    $tree selection set $node
    set item [$tree itemcget $node -data]
    if {[string range $item 0 2] == "prj"} {
        $tree itemconfigure $node -image [Bitmap::get [file join $imgDir folder.gif]] 
    }
    if {[info exists fileList($node)] != 1} {
        if {[file isdirectory $item] == 1} {
            $tree itemconfigure $node -image [Bitmap::get [file join $imgDir folder.gif]]
        }
    }
}
## TREE ONE CLICK PROCEDURE ##
proc TreeOneClick {tree node} {
    global noteBook fontNormal projDir workDir activeProject fileList noteBook findString imgDir fontBold
    $tree selection get
    $tree selection set $node
    set item [$tree itemcget $node -data]
    if {[string range $item 0 2] == "prj"} {
        set activeProject [string range $item 4 end]
        .frmStatus.frmActive.lblActive configure -text [$tree itemcget $node -text] -font $fontBold
        if {[file exists [file join $workDir $activeProject.tags]] == 1} {
            GetTagList [file join $workDir $activeProject.tags] ;# geting tag list
        }
        return
    } elseif {[file isdirectory $item] == 1} {
        if {[$noteBook index $node] == -1} {
            return
        }
    } elseif {[file isfile $item] == 1 } {
        if {[$noteBook index $node] != -1} {
            if {[file exists $item] == 1} {
                LabelUpdate .frmStatus.frmHelp.lblHelp [FileAttr $item]
                PageRaise $tree $node
            }
        }
    } elseif {[string range $item 0 2] == "prc"} {
        set parent [$tree parent $node]
        set file [$tree itemcget $parent -data]
        set fileExt [string range [file extension $file] 1 end]
        if {[info exists fileList($parent)] == 0} {
            EditFile $parent $file
        }
        PageRaise $tree $parent
        $tree selection set $node
        set text "$noteBook.f$parent.text"
        set index1 [expr [string first "_" $item]+1]
        set index2 [expr [string last "_" $item]11]
        if {$fileExt == "java" || $fileExt == "ja"} {
            set findString "class [string range $item $index1 $index2] "
        } elseif {$fileExt == "perl" || $fileExt == "pl"} {
            set findString "sub [string range $item $index1 $index2]"
        } elseif {$fileExt == "ml" || $fileExt == "mli"} {
            set findString "let [string range $item $index1 $index2]"
        } elseif {$fileExt == "php" || $fileExt == "phtml"} {
            set findString "function [string range $item $index1 $index2]"
            #puts $findString
            #return
        } elseif {$fileExt == "rb"} {
            set findString "class [string range $item $index1 $index2]"
        } else {
            set findString "proc [string range $item $index1 $index2] "
        }
        FindProc $text $findString $node
        focus -force $text
    }
}

## TREE DOUBLE  CLICK PROCEDURE ##
proc TreeDoubleClick {tree node} {
    global  fontNormal projDir workDir activeProject fileList noteBook findString imgDir fontBold noteBook
    $tree selection set $node
    set item [$tree itemcget $node -data]
    
    if {[$tree itemcget $node -open        ] == 1} {
        puts " $item $tree itemcget $node -open"
        $tree closetree $node
    } elseif {[$tree itemcget $node -open        ] == 0}  {
        puts " $item $tree itemcget $node -open"
        $tree opentree $node
    }
    $tree opentree $node
    if {[string range $item 0 2] == "prj"} {
        # node is project
        set activeProject [string range $item 4 end]
        .frmStatus.frmActive.lblActive configure -text [$tree itemcget $node -text] -font $fontBold
        #GetFilesSubdir $tree $node $item
    } elseif {[file isdirectory $item] ==1} {
        # node is directory
        GetFiles $tree $node $item
        puts "GetFiles $tree $node $item"
    } elseif {[string range $item 0 2] == "prc"} {
        # node is procedure (class, function, etc)
        $tree selection set $node
        set parent [$tree parent $node]
        if {[info exists fileList($parent)] != 1} {
            set file [$tree itemcget $parent -data]
            EditFile $parent $file
            $noteBook raise $parent
        } else {
            $noteBook raise $parent
        }
        set text "$noteBook.f$parent.text"
        set index1 [expr [string first "_" $item]+1]
        set index2 [expr [string last "_" $item]11]
        set findString "proc [string range $item $index1 $index2] "
        FindProc $text $findString $node
        focus -force $text
    } elseif {[file isfile $item] == 1} {
        #puts [$noteBook index $node]
        if {[$noteBook index $node] != -1} {
            puts "File тута $node"
            puts "fileList($node) $fileList($node)"
        } else {
            EditFile $tree $node $item
        }
    } else {
        return        
    }
    
}

## UPDATE TREE ##
proc UpdateTree {} {
    global tree
    $tree delete [$tree nodes root]
    GetProj $tree
}

proc GetTreeForNode {node} {
    if {[.frmBody.frmCat.noteBook.ffiles.frmTreeFiles.treeFiles exists $node] ==1} {
        return .frmBody.frmCat.noteBook.ffiles.frmTreeFiles.treeFiles
    } elseif {[.frmBody.frmCat.noteBook.fprojects.frmTree.tree exists $node] ==1} {
        return .frmBody.frmCat.noteBook.fprojects.frmTree.tree 
    }
    
}
proc FileNotePageRaise {nb s} {
    global workingTree
    if {$nb eq "files"} {
        set workingTree .frmBody.frmCat.noteBook.ffiles.frmTreeFiles.treeFiles
    } elseif {$nb eq "projects"} {
        set workingTree .frmBody.frmCat.noteBook.fprojects.frmTree.tree 
    } else {
        puts "Error node"
        return
    }
}




