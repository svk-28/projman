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
namespace eval FileTree {
    variable count
    variable dblclick
}
set count 1

proc FileTree::create {nb} {
    global editor
    global treeFiles
    set frmTreeFiles [ScrolledWindow $nb.frmTreeFiles -bg $editor(bg) -background $editor(bg) ]
    
    set treeFiles [
        Tree $frmTreeFiles.treeFiles \
        -relief sunken -borderwidth 1 -width 5 -highlightthickness 0\
        -redraw 0 -dropenabled 1 -dragenabled 1 -dragevent 3 \
        -background $editor(bg) -selectbackground $editor(selectbg) -selectforeground white\
        -droptypes {
            TREE_NODE    {copy {} move {} link {}}
            LISTBOX_ITEM {copy {} move {} link {}}
        } -opencmd {FileTree::select tree 1 $treeFiles} \
        -closecmd  {FileTree::select tree 1 $treeFiles}
    ]
    $frmTreeFiles setwidget $treeFiles
    pack $frmTreeFiles -side top -fill both -expand true
    $treeFiles bindText <ButtonPress-1> "TreeOneClick $treeFiles [$treeFiles selection get]"
    $treeFiles bindImage <ButtonPress-1> "TreeOneClick $treeFiles [$treeFiles selection get]"
    $treeFiles bindImage <Double-ButtonPress-1> "TreeDoubleClick $treeFiles [$treeFiles selection get]"
    $treeFiles bindText <Double-ButtonPress-1> "TreeDoubleClick $treeFiles [$treeFiles selection get]"
    $treeFiles bindText <Shift-Button-1> {$treeFiles selection add $treeFiles [$treeFiles selection get]}
    # Added menu
    GetMenuFileTree [menu .popMenuFileTree -bg $editor(bg) -fg $editor(fg)] ;# pop-up edit menu
    
    bind $frmTreeFiles.treeFiles.c <Button-3> {catch [PopupMenuFileTree $treeFiles %X %Y]}
    
    FileTree::GetAllDirs $treeFiles
}

proc FileTree::init { treeFile } {
    global   tcl_platform count
    
    set count 0
    if { $tcl_platform(platform) == "unix" } {
        set rootdir [glob "~"]
    } else {
        set rootdir "c:\\"
    }
    $treeFile insert end root home -text $rootdir -data $rootdir -open 1 \
    -image [Bitmap::get openfold]
    getdir $treeFile home $rootdir
    FileTree::select tree 1 $treeFile home
    $treeFile configure -redraw 1
    
    # ScrollView
    set w .top
    toplevel $w
    wm withdraw $w
    wm protocol $w WM_DELETE_WINDOW {
        # don't kill me
    }
    wm resizable $w 0 0 
    wm title $w "Drag rectangle to scroll directory tree"
    wm transient $w .
    ScrollView $w.sv -window $treeFile -fill white -relief sunken -bd 1 \
    -width 300 -height 300
    pack $w.sv -fill both -expand yes
}

proc FileTree::getdir { treeFile node path } {
    global count
    
    set lentries [glob -nocomplain [file join $path "*"]]
    set lfiles   {}
    foreach f $lentries {
        set tail [file tail $f]
        if { [file isdirectory $f] } {
            $treeFile insert end $node n:$count \
            -text      $tail \
            -image     [Bitmap::get folder] \
            -drawcross allways \
            -data      $f
            incr count
        } else {
            lappend lfiles $tail
        }
    }
    $treeFile itemconfigure $node -drawcross auto -data $lfiles
}

proc FileTree::moddir { idx treeFile node } {
    if { $idx && [$treeFile itemcget $node -drawcross] == "allways" } {
        getdir $treeFile $node [$treeFile itemcget $node -data]
        if { [llength [$treeFile nodes $node]] } {
            $treeFile itemconfigure $node -image [Bitmap::get openfold]
        } else {
            $treeFile itemconfigure $node -image [Bitmap::get folder]
        }
    } else {
        $treeFile itemconfigure $node -image [Bitmap::get [lindex {folder openfold} $idx]]
    }
}


proc FileTree::select { where num treeFile node } {
    variable dblclick
    
    set dblclick 1
    if { $num == 1 } {
        if { $where == "tree" && [lsearch [$treeFile selection get] $node] != -1 } {
            unset dblclick
            #after 500 "DemoTree::edit tree $treeFile $list $node"
            return
        }
        if { $where == "tree" } {
            select_node $treeFile $node
        } else {
            #$list selection set $node
        }
    } elseif { $where == "list" && [$treeFile exists $node] } {
        set parent [$treeFile parent $node]
        while { $parent != "root" } {
            $treeFile itemconfigure $parent -open 1
            set parent [$treeFile parent $parent]
        }
        select_node $treeFile $node
    }
}


proc FileTree::select_node { treeFile node } {
    $treeFile selection set $node
    update
    #eval $list delete [$list item 0 end]
    
    set dir [$treeFile itemcget $node -data]
    if { [$treeFile itemcget $node -drawcross] == "allways" } {
        getdir $treeFile $node $dir
        set dir [$treeFile itemcget $node -data]
    }
    
    set num 0
    foreach f $dir {
        if {[$treeFile exists $node:file:$num] !=1} {
            $treeFile insert end $node $node:file:$num -text [file tail $f] -data $f \
            -image [Bitmap::get file]
            incr num
        }
    }
    
}


proc FileTree::edit { where treeFile node } {
    variable dblclick
    
    if { [info exists dblclick] } {
        return
    }
    
    if { $where == "tree" && [lsearch [$treeFile selection get] $node] != -1 } {
        set res [$treeFile edit $node [$treeFile itemcget $node -text]]
        if { $res != "" } {
            $treeFile itemconfigure $node -text $res
            $treeFile selection set $node
        }
        return
    }
    
}

proc FileTree::expand { treeFile but } {
    if { [set cur [$treeFile selection get]] != "" } {
        if { $but == 0 } {
            $treeFile opentree $cur
        } else {
            $treeFile closetree $cur
        }
    }
}

proc FileTree::GetAllDirs {treeFiles} {
    global projDir workDir fontNormal imgDir module env nodeCounter
    set rList ""
    set rootDir $env(HOME)
    if {[catch {cd $rootDir}] != 0} {
        return ""
    }
    set rootNode [$treeFiles insert end root $rootDir -text "$rootDir" -font $fontNormal \
    -data "dir_root" -open 1\
    -image [Bitmap::get [file join $imgDir folder.gif]]]
    incr nodeCounter
    
#     $treeFiles insert end root $rootDir -text "$rootDir" -font $fontNormal \
#     -data "dir_root" -open 0\
#     -image [Bitmap::get [file join $imgDir folder.gif]]
    GetFiles [file join $rootDir] $rootNode $treeFiles
    #set dir $string
    
    $treeFiles configure -redraw 1
}


## GETTING FILES FROM SUBDIR ##
proc GetFilesSubdir {tree node dir} {
    global  fontNormal projDir workDir activeProject imgDir count
    global backUpFileShow dotFileShow
    set rList ""
    if {[catch {cd $dir}] != 0} {
        return ""
    }
    if {$dotFileShow eq "Yes"} {
        foreach file [lsort [glob -nocomplain .*]] {
            if {$file == "." || $file == ".."} {
                #puts $file
            } else {
                lappend rList [list [file join $dir $file]]
                set fileName [file join $file]
                set img [GetImage $fileName]
                set dot "_"
                regsub -all {\.} $fileName "_" subNode
                set subNode "$activeProject$dot$node$dot$subNode$dot$count"
                if {[$tree exists $subNode] == 1} {return}
                if {$backUpFileShow == "Yes"} {
                    $tree insert end $node $subNode -text $fileName \
                    -data [file join $dir $fileName] -open 1\
                    -image [Bitmap::get [file join $imgDir $img.gif]]\
                    -font $fontNormal
                }
                if {$backUpFileShow == "No"} {
                    if {[file isdirectory $fileName] == 1} {
                        $tree insert end $node $subNode -text $fileName \
                        -data [file join $dir $fileName] -open 1\
                        -image [Bitmap::get [file join $imgDir $img.gif]]\
                        -font $fontNormal
                    } else {
                        if {[string index $fileName end] != "~"} {
                            $tree insert end $node $subNode -text $fileName \
                            -data [file join $dir $fileName] -open 1\
                            -image [Bitmap::get [file join $imgDir $img.gif]]\
                            -font $fontNormal
                        }
                    }
                }
            }
            incr count   
        }
    }
    foreach file [lsort [glob -nocomplain *]] {
        lappend rList [list [file join $dir $file]]
        set fileName [file join $file]
        set img [GetImage $fileName]
        set dot "_"
        regsub -all {\.} $fileName "_" subNode
        set subNode "$activeProject$dot$node$dot$subNode$dot$count"
        if {[$tree exists $subNode] == 1} {return}
        if {$backUpFileShow == "Yes"} {
            $tree insert end $node $subNode -text $fileName \
            -data [file join $dir $fileName] -open 1\
            -image [Bitmap::get [file join $imgDir $img.gif]]\
            -font $fontNormal
        }
        if {$backUpFileShow == "No"} {
            if {[file isdirectory $fileName] == 1} {
                $tree insert end $node $subNode -text $fileName \
                -data [file join $dir $fileName] -open 1\
                -image [Bitmap::get [file join $imgDir $img.gif]]\
                -font $fontNormal
            } else {
                if {[string index $fileName end] != "~"} {
                    $tree insert end $node $subNode -text $fileName \
                    -data [file join $dir $fileName] -open 1\
                    -image [Bitmap::get [file join $imgDir $img.gif]]\
                    -font $fontNormal
                }
            }
        }
        incr count
        incr nodeCouner
    }
    $tree itemconfigure $node -open 1
}
## GETTING FILES FROM PROJECT DIR AND INSERT INTO TREE WIDGET ##
proc GetFiles {dir project tree} {
    global  fontNormal backUpFileShow dotFileShow imgDir count
    set rList ""
    if {[catch {cd $dir}] != 0} {
        return ""
    }
    if {$dotFileShow eq "Yes"} {
        foreach file [lsort [glob -nocomplain .*]] {
            if {$file == "." || $file == ".."} {
                #puts $file
            } else {
                lappend rList [list [file join $dir $file]]
                set fileName [file join $file]
                set img [GetImage $fileName]
                set dot "_"
                regsub -all {\.} $fileName "_" subNode
                set subNode "$project$dot$subNode$dot$count"
                if {$backUpFileShow == "Yes"} {
                    $tree insert end $project $subNode -text $fileName \
                    -data [file join $dir $fileName] -open 1\
                    -image [Bitmap::get [file join $imgDir $img.gif]]\
                    -font $fontNormal
                }
                if {$backUpFileShow == "No"} {
                    if {[string index $fileName end] != "~"} {
                        $tree insert end $project $subNode -text $fileName \
                        -data [file join $dir $fileName] -open 1\
                        -image [Bitmap::get [file join $imgDir $img.gif]]\
                        -font $fontNormal
                    }
                }
            }
            incr count
        }
    }
    
    foreach file [lsort [glob -nocomplain *]] {
        lappend rList [list [file join $dir $file]]
        set fileName [file join $file]
        set img [GetImage $fileName]
        set dot "_"
        regsub -all {\.} $fileName "_" subNode
        set subNode "$project$dot$subNode$dot$count"
        if {$backUpFileShow == "Yes"} {
            $tree insert end $project $subNode -text $fileName \
            -data [file join $dir $fileName] -open 1\
            -image [Bitmap::get [file join $imgDir $img.gif]]\
            -font $fontNormal
        }
        if {$backUpFileShow == "No"} {
            if {[string index $fileName end] != "~"} {
                $tree insert end $project $subNode -text $fileName \
                -data [file join $dir $fileName] -open 1\
                -image [Bitmap::get [file join $imgDir $img.gif]]\
                -font $fontNormal
            }
        }
        incr count
    }
    $tree configure -redraw 1
}
## GETTING PROJECT NAMES FROM DIR AND PUTS INTO 
proc GetProj {tree} {
    global projDir workDir fontNormal imgDir module
    set rList ""                     
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
                #puts "$projList($prjName) - $string"
                $tree insert end root $prjName -text "$projName" -font $fontNormal \
                -data "prj_$prjName" -open 0\
                -image [Bitmap::get [file join $imgDir folder.gif]]
                GetFiles [file join $string] $prjName $tree
                set dir $string
            }
        }
    }
    $tree configure -redraw 1
}

## SHOW PUP-UP MENUS ## 
proc PopupMenuFileTree {treeFiles x y} {
    #global fontNormal fontBold imgDir activeProject
    #set node [$treeFiles selection get]
    if {[$treeFiles selection get] != ""} {
        set node [$treeFiles selection get]
        $treeFiles selection set $node
    } else {
        return
    }
    #set item [$treeFiles itemcget $node -data]
    if {[info exists fileList($node)] != 1} {
        #        set fileList($node) $item
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
    global fontNormal projDir workDir activeProject fileList noteBook findString imgDir fontBold
    $tree selection get
    $tree selection set $node
    #puts "$tree >>> $node"
    set item [$tree itemcget $node -data]
    if {[string range $item 0 2] == "prj"} {
        set activeProject [string range $item 4 end]
        #puts $activeProject
        .frmStatus.frmActive.lblActive configure -text [$tree itemcget $node -text] -font $fontBold
        if {[file exists [file join $workDir $activeProject.tags]] == 1} {
            GetTagList [file join $workDir $activeProject.tags] ;# geting tag list
        }
        return
    }
    if {[info exists fileList($node)] != 1} {
        if {[file isdirectory $item] == 1} {
            return
        } else {
            if {[file exists $item] == 1} {
                LabelUpdate .frmStatus.frmHelp.lblHelp [FileAttr $item]
            }
        }
    } else {
        PageRaise $tree $node
    }
    if {[string range $item 0 2] == "prc"} {
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
    global  fontNormal projDir workDir activeProject fileList noteBook findString imgDir fontBold
    #puts "$tree $node"
    $tree selection set $node
    set item [$tree itemcget $node -data]
    #puts $item
    if {[$tree itemcget $node -open] == 1} {
        $tree itemconfigure $node -open 0
    } elseif {[$tree itemcget $node -open] == 0} {
        $tree itemconfigure $node -open 1
    }
    if {[string range $item 0 2] == "prj"} {
        set activeProject [string range $item 4 end]
        .frmStatus.frmActive.lblActive configure -text [$tree itemcget $node -text] -font $fontBold
        GetTagList [file join $workDir $activeProject.tags] ;# geting tag list
    }
    
    if {[info exists fileList($node)] != 1} {
        if {[file isdirectory $item] == 1} {
            GetFilesSubdir $tree $node $item
        } else {
            if {[file exists $item] == 1} {
                EditFile $tree $node $item
                LabelUpdate .frmStatus.frmFile.lblFile "[file size $item] b."
            }
        }
    }
    if {[string range $item 0 2] == "prc"} {
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


