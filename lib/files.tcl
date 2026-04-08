######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
# Working with files module
######################################################


namespace eval FileOper {
    global packages
    variable types
    
    set ::types {
        {"All files" *}
    }
    #  Проверка поддерживаемых типов изображений
    # в зависимости устновлен пакет или нет
    proc SupportImageType {type} {
        if {[PackagePresent Img] eq "true"} { 
            switch $type {
                jpeg { return true }
                png { return true }
                gif { return true }
                bmp { return true }
                svg { return true }
                ppm { return true }
                pgm { return true }
                tiff { return true }
                xbm { return true }
                xpm { return true }
                default { return false}
            }
        } else {
            switch $type {
                png { return true }
                gif { return true }
                bmp { return true }
                svg { return true }
                ppm { return true }
                pgm { return true }
                default { return false}
            }
        }
    }

    proc GetFileMimeType {fileFullPath {opt ""}} {
        global cfgVariables
        # Проверям наличие программы в системе, если есть то добавляем опции
        # если нет то используем тиклевый пакет
        if [file exists $cfgVariables(fileTypeCommand)] {
            set cmd exec
            lappend cmd $cfgVariables(fileTypeCommand)
            foreach _ [split $cfgVariables(fileTypeCommandOptions) " "] {
                lappend cmd $_
            }
        } else {
            set cmd [list eval ::fileutil::magic::filetype]
        }

        # lappend cmd $activeProject
        lappend cmd $fileFullPath
        # puts $cmd
        catch $cmd pipe
        # puts $pipe
        if [regexp -nocase -- {(\w+)/([\w\-_\.]+); charset=([[:alnum:]-]+)} $pipe m fType fExt fCharset] {
            DebugPuts "$fType $fExt $fCharset"
        }
        switch $opt {
            "charset" {
                if [info exists fCharset] {
                    return $fCharset
                }
            }
        }
        # линуксовый file не всегда корректно определяет тип файла
        # используем пакет из tcl
        lassign [::fileutil::fileType $fileFullPath] fType fBinaryType fBinaryInterp
        DebugPuts "File type is $fType, $fBinaryType, $fBinaryInterp"
        set ext [string tolower [file extension $fileFullPath]]
        
        # Установка корректного типа для svg
        # Но для новых версий tcl
        switch $ext {
            ".svg" {
                set fType "binary"
                set fBinaryInterp "svg"
                set fBinaryType "graphic"
            }
            ".torrent" {
                set fType "binary"
                set fBinaryInterp "torrent"
                set fBinaryType "x-bittorrent"
            }
            ".pdf" {
                set fType "binary"
                set fBinaryInterp "pdf"
                set fBinaryType "binary"
            }
        }
        DebugPuts "File type is $fType, $fBinaryType, $fBinaryInterp, $ext"

        switch $fType {
            "binary" {
                if {$fBinaryType ne ""} {
                    switch $fBinaryType {
                        "graphic" {
                            if {[SupportImageType $fBinaryInterp] eq "true"} {
                                return image
                            } else {
                                set answer [tk_messageBox -message [::msgcat::mc "The file looks like a image. Support not implemented yet."] -icon question -type ok]
                                switch $answer {
                                    ok {
                                        return false
                                    }
                                }
                            }
                        }
                        default {
                            return binary
                        }
                    }
                } else {
                    return binary
                }
            }
            "text" {
                return text
            }
            "image" {
                if {[SupportImageType $fBinaryInterp] eq "true"} {
                    return image
                } else {
                    set answer [tk_messageBox -message [::msgcat::mc "The file looks like a image. Support not implemented yet."] -icon question -type ok]
                    switch $answer {
                        ok {
                            return false
                        }
                    }
                }
            }
            "empty" {
                return text
            }
            default {
                return false
            }
        }
    }
    ## GETTING FILE ATTRIBUTES ##
    proc GetFileAttr {file {opt ""}} {
        global tcl_platform
        set fileAttribute ""
        # get file modify time
        switch $opt {
            attr {
                if {$tcl_platform(platform) == "windows"} {
                    set unixTime [file mtime $file]
                    set modifyTime [clock format $unixTime -format "%d/%m/%Y, %H:%M"]
                } elseif {$tcl_platform(platform) == "mac"} {
            
                } elseif {$tcl_platform(platform) == "unix"} {
                    set unixTime [file mtime $file]
                    set modifyTime [clock format $unixTime -format "%d/%m/%Y, %H:%M"]
                }
                return $modifyTime
            }
            size {
                # get file size
                set size [file size $file]
                if {$size < 1024} {
                    set fileSize "$size b"
                }
                if {$size >= 1024} {
                    set s [expr ($size.0) / 1024]
                    set dot [string first "\." $s]
                    set int [string range $s 0 [expr $dot - 1]]
                    set dec [string range $s [expr $dot + 1] [expr $dot + 2]]
                    set fileSize "$int.$dec Kb"
                }
                if {$size >= 1048576} {
                    set s [expr ($size.0) / 1048576]
                    set dot [string first "\." $s]
                    set int [string range $s 0 [expr $dot - 1]]
                    set dec [string range $s [expr $dot + 1] [expr $dot + 2]]
                    set fileSize "$int.$dec Mb"
                }
                return $fileSize
            }
        }
    }
    
    proc OpenDialog {} {
        global env project activeProject
        if [info exists activeProject] {
            set dir $activeProject
        } else {
            set dir $env(HOME)
        }
        set fullPath [tk_getOpenFile -initialdir $dir -filetypes $::types -parent .]
        set file [string range $fullPath [expr [string last "/" $fullPath]+1] end]
        regsub -all "." $file "_" node
        set dir [file dirname $fullPath]
        set file [file tail $fullPath]
        set name [file rootname $file]
        set ext [string range [file extension $file] 1 end]
        if {$fullPath != ""} {
            # puts $fullPath
            return $fullPath
        } else {
            return
        }
    }
    
    proc OpenFolderDialog {} {
        global env activeProject
        #global tree node types dot env noteBook fontNormal fontBold fileList noteBook projDir activeProject imgDir editor rootDir
        #     set dir $projDir
        if [info exists activeProject] {
            set dir $activeProject
        } else {
            set dir $env(HOME)
        }
        set fullPath [tk_chooseDirectory  -initialdir $dir -parent .]
        # set file [string range $fullPath [expr [string last "/" $fullPath]+1] end]
        # regsub -all "." $file "_" node
        # set dir [file dirname $fullPath]
        # #     EditFile .frmBody.frmCat.noteBook.ffiles.frmTreeFiles.treeFiles $node $fullPath
        # # puts $fullPath
        # if ![info exists activeProject] {
            # set activeProject $fullPath
        # }
        # .frmStatus.lblGitLogo configure -image git_logo_20x20
        # .frmStatus.lblGit configure -text "[::msgcat::mc "Branch"]: [Git::Branches current]"
        AddRecentEditedFolder $fullPath
        return $fullPath
    }
    
    proc CloseFolder {} {
        global tree nbEditor activeProject

        set treeItem [$tree selection]
        set parent [$tree parent $treeItem]
        while {$parent ne ""} {
            set treeItem $parent
            set parent [$tree parent $treeItem]
        }
        set upper [Tree::GetUpperItem $tree $treeItem]
        if {$parent eq "" && [string match "directory::*" $treeItem] == 1} {
            # puts "tree root item: $treeItem"
            set proj [string trimleft $upper "directory::"]
            foreach nbItem [$nbEditor tabs] {
                set item [string trimleft [file extension $nbItem] "."]
                # puts "$upper $item"
                if [string match "$proj*" $item] {
                    if [$tree exists "file::$item"] {
                        $nbEditor select $nbItem
                        Close
                    }
                }
            }
            set nextProj [$tree next $treeItem]
            # puts $nextProj
            set prevProj [$tree prev $treeItem]
            # puts $prevProj
            if {$nextProj ne ""} {
                SetActiveProject [$tree item $nextProj -values]
                # puts $activeProject
            } elseif {$prevProj ne ""} {
                SetActiveProject [$tree item $prevProj -values]
                # puts $activeProject                
            } else {
                unset activeProject
                .frmStatus.lblGitLogo configure -image pixel
                .frmStatus.lblGit configure -text ""
            }
            $tree delete $treeItem
            unset nextProj
            unset prevProj
        }

    }

    proc CloseAll {} {
        global nbEditor modified
        foreach nb2Item [.frmWork.nbEditor2 tabs] {
            .frmWork.nbEditor2 forget $nb2Item
        }
        if {[lsearch -exact [.frmWork.panelNB panes] .frmWork.nbEditor2] != -1} {
            .frmWork.panelNB forget .frmWork.nbEditor2
        }
        foreach nbItem [$nbEditor tabs] {
            catch {$nbEditor select $nbItem}
            if {[Close] eq "cancel"} {
                return "cancel"
            }
        }
    }

    proc Close {{nbEditorWindow ""}} {
        global nbEditor modified tree editors
        if {$nbEditorWindow eq ""} {
            set nbEditorWindow $nbEditor
        }
        set nbItem [$nbEditorWindow select]
        # puts "Procedure FileOper::Close: item - $nbItem"
	    # puts "close tab $nbItem"
    	   
        if {$nbItem == ""} {return}
        if [info exists modified($nbItem)] {
            if {$modified($nbItem) eq "true"} {
                set answer [tk_messageBox -message [::msgcat::mc "File was modifyed"] \
                    -icon question -type yesnocancel \
                    -detail [::msgcat::mc "Do you want to save it?"]]
                switch $answer {
                    yes {Save close $nbEditorWindow}
                    no {}
                    cancel {return "cancel"}
                }
            }
        }
        if {[$nbEditorWindow select] eq $nbItem} {
            $nbEditorWindow forget $nbItem
            destroy $nbItem
        }
        set treeItem "file::[string range $nbItem [expr [string last "." $nbItem] +1] end ]"
        if [$tree exists $treeItem] {
            # delete all functions from tree item
            set children [$tree children $treeItem]
            if {$children ne ""} {
                foreach i $children {
                    $tree delete $i
                }
            }
            if {[$tree parent $treeItem] eq ""} {
                $tree delete $treeItem
            }
        }
        if [info exists modified($nbItem)] {
            unset modified($nbItem)
        }
        # puts $nbItem
        set editors [dict remove $editors $nbItem.frmText.t]
        .frmStatus.lblPosition configure -text ""
        .frmStatus.lblEncoding configure -text ""
        .frmStatus.lblSize configure -text ""
        
        NB::NextTab $nbEditorWindow 0
    }
    
    proc Save {{type ""} {nbEditorWindow ""}} {
        global nbEditor tree env activeProject dir

        if [info exists activeProject] {
            set dirProject $activeProject
        } else {
            set dirProject $env(HOME)
        }
        
        if {$nbEditorWindow eq ""} {
            set nbEditorWindow $nbEditor
            set str [split [focus] "."]
            set nbEditorWindow "[lindex $str 0].[lindex $str 1].[lindex $str 2]"
            # puts "FileOper::Save: current window $nbEditorWindow"
        }

        set nbEditorItem [$nbEditorWindow select]
        DebugPuts "Saved editor text: $nbEditorItem"
        if [string match "*untitled*" $nbEditorItem] {
            set filePath [tk_getSaveFile -initialdir $dirProject -filetypes $::types -parent .]
            if {$filePath eq ""} {
                return
            }
            # set fileName [string range $filePath [expr [string last "/" $filePath]+1] end]
            set fileName [file tail $filePath]
            $nbEditorWindow tab $nbEditorItem -text $fileName
            # set treeitem [Tree::InsertItem $tree {} $filePath "file" $fileName]
            set lblName "lbl[string range $nbEditorItem [expr [string last "." $nbEditorItem] +1] end]"
            $nbEditorItem.header.$lblName configure -text $filePath
        } else {
            set treeItem "file::[string range $nbEditorItem [expr [string last "." $nbEditorItem] +1] end ]"
            set filePath [Tree::GetItemID $tree $treeItem]
        }
        if {![winfo exists $nbEditorItem.frmText.t]} {
            DebugPuts "winfo exists $nbEditorWindow.frmText.t equal [winfo exists $nbEditorWindow.frmText.t]"
            return
        }
        set editedText [$nbEditorItem.frmText.t get 0.0 end]
        if {$type eq "saveas"} {set filePath [FileOper::SaveDialog]}
        if {$filePath eq "cancel"} {return}
        DebugPuts "FileOper::Save $filePath"
        set f [open $filePath "w+"]
        puts -nonewline $f $editedText
        # puts "$f was saved"
        close $f
        ResetModifiedFlag $nbEditorItem $nbEditorWindow

        # Проверяем если в редакторе открыт MD-файл и запущен его просмотрщик
        if {[string toupper [string trimleft [file extension $filePath] "."]] eq "MD" && [winfo exists .viewer]} {
           if {[wm title .viewer] eq $filePath} {
              ShowMD $filePath true
           }
        } 

        if {[file tail $filePath] eq "projman.ini"} {
            Config::read $dir(cfg)
        }
        if {[file tail $filePath] eq "tools.ini"} {
            Tools::Read $dir(cfg)
            Tools::CheckVariables
            Tools::GetMenu .popup.tools
            Tools::GetMenu .frmMenu.mnuTools.m
        }
        if {[string match "*untitled*" $nbEditorItem] || $type eq "saveas"} {
            FileOper::Close
            if {$type ne "close"} {
                FileOper::Edit $filePath
            }
        }
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
    
    proc ReadFolder {directory {parent ""}} {
        global tree dir lexers  project
        # puts "Read the folder $directory"
        set rList ""
        if {[catch {cd $directory}] != 0} {
            return ""
        }
        set parent [Tree::InsertItem $tree $parent $directory "directory" [file tail $directory]]
        $tree selection set $parent
        foreach i [$tree children $parent] {
            $tree delete $i
        }
        # if {[ $tree  item $parent -open] eq "false"} {
            # $tree  item $parent -open true
        # } else {
            # $tree  item $parent -open false
        # }
        # Проверяем наличие списка каталогов для спецобработки
        # и если есть читаем в список (ножно для ansible)
        if {[dict exists $lexers ALL varDirectory] == 1} {
            foreach i [split [dict get $lexers ALL varDirectory] " "] {
                # puts "-------- $i"
                lappend dirListForCheck [string trim $i]
            }
        }
        # Getting an files and directorues lists
        foreach file [glob -nocomplain *] {
            lappend rList [list [file join $directory $file]]
            if [file isdirectory $file] {
                lappend lstDir $file
            } else {
                lappend lstFiles $file
            }
        }
        foreach file [glob -nocomplain .?*] {
            if {$file ne ".."} {
                lappend rList [list [file join $directory $file]]
                if [file isdirectory $file] {
                    lappend lstDir $file
                } else {
                    lappend lstFiles $file
                }
            }
        }
        # Sort  lists and insert into tree
        if {[info exists lstDir] && [llength $lstDir] > 0} {
            foreach f [lsort $lstDir] {
                set i [Tree::InsertItem $tree $parent [file join $directory $f] "directory" $f]
                # puts "Tree insert item: $i $f]"
                ReadFolder [file join $directory $f] $i
                unset i
            }
        }
        if {[info exists lstFiles] && [llength $lstFiles] > 0} {
            foreach f [lsort $lstFiles] {
                Tree::InsertItem $tree $parent [file join $directory $f] "file" $f
                # puts "Tree insert item: "
            }
        }
        # Чтение структуры файлов в каталоге
        #  пока криво работает
        # Accept $dir(lib) $directory
    }
    
    proc ReadFile {fileFullPath itemName} {
        set txt $itemName.frmText.t
        if ![string match "*untitled*" $itemName] {
            set file [open "$fileFullPath" r]
            $txt insert end [chan read -nonewline $file]
            close $file
        }
        # Delete emty last line
        if {[$txt get {end-1 line} end] eq "\n" || [$txt get {end-1 line} end] eq "\r\n"} {
            $txt delete {end-1 line} end
            # puts ">[$txt get {end-1 line} end]<"
        }
        # ------------
        # Thanks https://github.com/wandrien/
        # https://github.com/wandrien/projman/commit/7d5539ac2031fbdcb0f4a97465ff19d0c348cf33
        $txt edit reset
        # -----------
        $txt see 1.0
    }
    
    proc Edit {fileFullPath {nbEditor .frmWork.nbEditor}} {
        global tree
        DebugPuts "$fileFullPath"
        if {[file exists $fileFullPath] == 0} {
            return false
        } else {
            # puts "$fileFullPath File type [::fileutil::magic::filetype $fileFullPath]"
            set fileType [FileOper::GetFileMimeType $fileFullPath]
        }

        # puts "$fileType <<<<<<<<<<<"

        switch $fileType {
            "text" {
                # return text
            }
            "image" {
            }
            "binary" {
                 set answer [tk_messageBox -message [::msgcat::mc "The file looks like a binary file. Open anyway?"] \
                    -icon question -type yesno]
                switch $answer {
                    yes {}
                    no {return}
                }
            }
            false {
                return
            }
        }
        # Проверяем размер файла и если он больше 1мб вывести предупреждение
        # puts " File size = [file size $fileFullPath]"
        if {[file size $fileFullPath] > 1000000} {
             set answer [tk_messageBox -message [::msgcat::mc "The file size to big. Open anyway?"] \
                -detail [GetFileAttr $fileFullPath "size"] \
                -icon question -type yesno]
            switch $answer {
                yes {}
                no {return}
            }
        }

        set filePath [file dirname $fileFullPath]
        set fileName [file tail $fileFullPath]
        
        regsub -all {\.|/|\\|\s|:} $fileFullPath "_" itemName
        set itemName [string tolower $itemName]
        set itemName "$nbEditor.$itemName"
        set treeItemName [Tree::InsertItem $tree {} $fileFullPath "file" $fileName]
        
        # переместим указатель на нужный файл в дереве
        Tree::SelectItem $treeItemName
        
        if {[winfo exists $itemName] == 0} {
            NB::InsertItem $nbEditor $fileFullPath "file"
            if {$fileType eq "image"} {
                ImageViewer $fileFullPath $itemName $itemName
                return $itemName
            }
            
            Editor::Editor $fileFullPath $nbEditor $itemName
            ReadFile $fileFullPath $itemName
            $itemName.frmText.t highlight 1.0 end
            ResetModifiedFlag $itemName $nbEditor
            $itemName.frmText.t see 1.1
        }
        $nbEditor select $itemName
        focus -force $itemName
        if {$fileType eq "image"} {
            # ImageViewer $fileFullPath $itemName $itemName
            return $itemName
        }
        Editor::ReadStructure $itemName.frmText.t $treeItemName
        GetVariablesFromFile $fileFullPath
        $itemName.frmText.t.t mark set insert 1.0
        $itemName.frmText.t.t see 1.0
        focus -force $itemName.frmText.t.t
        .frmStatus.lblSize configure -text [GetFileAttr $fileFullPath "size"]
        .frmStatus.lblEncoding configure -text [GetFileMimeType $fileFullPath "charset"]
        # puts ">> $itemName"

        return $itemName
    }
    
    proc FindInFiles {} {
        global nbEditor activeProject
        set res ""
        set txt ""
        set str ""
        set nbEditorItem [$nbEditor select]
        if {$nbEditorItem ne ""} {
            set txt $nbEditorItem.frmText.t
            # set txt [focus]
            set selIndex [$txt tag ranges sel]
            if {$selIndex ne ""} {
                set selBegin [lindex [$txt tag ranges sel] 0]
                set selEnd [lindex [$txt tag ranges sel] 1]
                set str [$txt get $selBegin $selEnd]
                # puts $str
                set res [SearchStringInFolder $str]
            }
        }
        if [FindInFilesDialog $txt $res] {
            .find.entryFind delete 0 end
            .find.entryFind insert end $str
        }
    }

    proc ReplaceInFiles {} {
        global nbEditor
        return
        # set selIndex [$txt tag ranges sel]
        # set selBegin [lindex [$txt tag ranges sel] 0]
        # set selEnd [lindex [$txt tag ranges sel] 1]
        # puts [$txt get [$txt tag ranges sel]]
    # }

    proc SaveDialog {} {
        global env project activeProject
        if [info exists activeProject] {
            set dir $activeProject
        } else {
            set dir $env(HOME)
        }
        set fileName [tk_getSaveFile -initialdir $dir -filetypes $::types -parent .]
        if {$fileName eq ""} {return "cancel"}
        set fullPath [file join $dir $fileName]
        set file [string range $fullPath [expr [string last "/" $fullPath]+1] end]
        DebugPuts "FileOper::SaveDialog $fileName $fullPath"
        regsub -all "." $file "_" node
        set dir [file dirname $fullPath]
        set file [file tail $fullPath]
        set name [file rootname $file]
        set ext [string range [file extension $file] 1 end]
        if {$fullPath != ""} {
            # puts $fullPath
            return $fullPath
        } else {
            return
        }
    }
}
