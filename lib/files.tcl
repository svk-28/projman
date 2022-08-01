######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
# Working with files module
######################################################


namespace eval FileOper {
    variable  types
    
    set ::types {
        {"All files" *}
    }
    
    proc OpenDialog {} {
        global env
        set dir $env(HOME)
        set fullPath [tk_getOpenFile -initialdir $dir -filetypes $::types -parent .]
        set file [string range $fullPath [expr [string last "/" $fullPath]+1] end]
        regsub -all "." $file "_" node
        set dir [file dirname $fullPath]
        set file [file tail $fullPath]
        set name [file rootname $file]
        set ext [string range [file extension $file] 1 end]
        if {$fullPath != ""} {
            puts $fullPath
            return $fullPath
        } else {
            return
        }
    }
    
    proc OpenFolderDialog {} {
        global env
        #global tree node types dot env noteBook fontNormal fontBold fileList noteBook projDir activeProject imgDir editor rootDir
        #     set dir $projDir
        set dir $env(HOME)
        set fullPath [tk_chooseDirectory  -initialdir $dir -parent .]
        set file [string range $fullPath [expr [string last "/" $fullPath]+1] end]
        regsub -all "." $file "_" node
        set dir [file dirname $fullPath]
        #     EditFile .frmBody.frmCat.noteBook.ffiles.frmTreeFiles.treeFiles $node $fullPath
        puts $fullPath
       
        return $fullPath
    }

    proc CloseAll {} {
        global nbEditor modified
        foreach nbItem [array names modified] {
            if {$modified($nbItem) eq "true"} {
                $nbEditor select $nbItem
                puts "close tab $nbItem"
                if {[Close] eq "cancel"} {return "cancel"}
            }
        }
    }

    proc Close {} {
        global nbEditor modified tree
        set nbItem [$nbEditor select]
	puts "close tab $nbItem"
        if {$nbItem == ""} {return}
        if {$modified($nbItem) eq "true"} {
            set answer [tk_messageBox -message [::msgcat::mc "File was modifyed"] \
                -icon question -type yesnocancel \
                -detail [::msgcat::mc "Do you want to save it?"]]
            switch $answer {
                yes Save
                no {}
                cancel {return "cancel"}
            }
        }
        $nbEditor forget $nbItem
        destroy $nbItem
        set treeItem "file::[string range $nbItem [expr [string last "." $nbItem] +1] end ]"
        if [$tree exists $treeItem] {
            if {[$tree parent $treeItem] eq ""} {
                $tree delete $treeItem
            }
        }
        unset modified($nbItem)
    }
    
    proc Save {} {
        global nbEditor tree env
        set nbEditorItem [$nbEditor select]
        puts "Saved editor text: $nbEditorItem"
        if [string match "*untitled*" $nbEditorItem] {
            set filePath [tk_getSaveFile -initialdir $env(HOME) -filetypes $::types -parent .]
            if {$filePath eq ""} {
                return
            }
            # set fileName [string range $filePath [expr [string last "/" $filePath]+1] end]
            set fileName [file tail $filePath]
            $nbEditor tab $nbEditorItem -text $fileName
            # set treeitem [Tree::InsertItem $tree {} $filePath "file" $fileName]
            set lblName "lbl[string range $nbEditorItem [expr [string last "." $nbEditorItem] +1] end]"
            $nbEditorItem.$lblName configure -text $filePath
        } else {
            set treeItem "file::[string range $nbEditorItem [expr [string last "." $nbEditorItem] +1] end ]"
            set filePath [Tree::GetItemID $tree $treeItem]
        }
        set editedText [$nbEditorItem.frmText.t get 0.0 end]
        set f [open $filePath "w+"]
        puts -nonewline $f $editedText
        puts "$f was saved"
        close $f
        ResetModifiedFlag $nbEditorItem
    }
    
    proc SaveAll {} {
        
    }
    
    proc Delete {} {
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
    
    proc ReadFolder {dir} {
        global tree
        puts "Read the folder $dir"
        set rList ""
        if {[catch {cd $dir}] != 0} {
            return ""
        }
        set parent [Tree::InsertItem $tree {} $dir "directory" $dir]
        # if {[ $tree  item $parent -open] eq "false"} {
            # $tree  item $parent -open true
        # } else {
            # $tree  item $parent -open false
        # }
        # Getting an files and directorues lists
        foreach file [glob -nocomplain *] {
            lappend rList [list [file join $dir $file]]
            if [file isdirectory $file] {
                lappend lstDir $file
            } else {
                lappend lstFiles $file
            }
        }
        # Sort  lists and insert into tree
        if {[info exists lstDir] && [llength $lstDir] > 0} {
            foreach f [lsort $lstDir] {
                puts " Tree insert item: [Tree::InsertItem $tree $parent [file join $dir $f] "directory" $f]"
            }
        }
        if {[info exists lstFiles] && [llength $lstFiles] > 0} {
            foreach f [lsort $lstFiles] {
                puts "Tree insert item: [Tree::InsertItem $tree $parent [file join $dir $f] "file" $f]"
            }
        }
    }
    
    proc ReadFile {fileFullPath itemName} {
        set txt $itemName.frmText.t
        if ![string match "*untitled*" $itemName] {
            set file [open "$fileFullPath" r]
            $txt insert end  [chan read -nonewline $file]  
            close $file
        }
        # Delete emty last line
        if {[$txt get {end-1 line} end] eq "\n" || [$txt get {end-1 line} end] eq "\r\n"} {
            $txt delete {end-1 line} end
            puts ">[$txt get {end-1 line} end]<"
        }
    }
    
    proc Edit {fileFullPath} {
        global nbEditor tree
        set filePath [file dirname $fileFullPath]
        set fileName [file tail $fileFullPath]
        regsub -all {\.|/|\\|\s} $fileFullPath "_" itemName
        set itemName "$nbEditor.$itemName"
        set treeItemName [Tree::InsertItem $tree {} $fileFullPath "file" $fileName]
        if {[winfo exists $itemName] == 0} {
            NB::InsertItem $nbEditor $fileFullPath "file"
            Editor::Editor $fileFullPath $nbEditor $itemName
            ReadFile $fileFullPath $itemName
            $itemName.frmText.t highlight 1.0 end
            ResetModifiedFlag $itemName
        }
        $nbEditor select $itemName
        Editor::ReadStructure $itemName.frmText.t $treeItemName
        focus -force $itemName.frmText.t
        
        return $itemName
    }
}
