#!/usr/bin/wish
######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
# Generate menu module
######################################################

proc GetFileMenu {m} {
    $m add command -label [::msgcat::mc "New file"] -command Editor::New\
    -accelerator "Ctrl+N"
    $m add command -label [::msgcat::mc "Open file"] -accelerator "Ctrl+O" -command {
        set filePath [FileOper::OpenDialog]
        if {$filePath != ""} {
            FileOper::Edit $filePath
        }
    }
    $m add command -label [::msgcat::mc "Save file"] -command {FileOper::Save}\
        -accelerator "Ctrl+S"
    $m add command -label [::msgcat::mc "Close file"] -command {FileOper::Close}\
        -accelerator "Ctrl+w"
    $m add command -label [::msgcat::mc "Open folder"] -accelerator "Ctrl+K" -command {
        set folderPath [FileOper::OpenFolderDialog]
        if {$folderPath != ""} {
            FileOper::ReadFolder $folderPath
        }
    }    
    $m add command -label [::msgcat::mc "Close folder"] -command {FileOper::CloseFolder}
    
    #$m add command -label [::msgcat::mc "Open"] -command {FileDialog $tree open}\
    #-font $fontNormal -accelerator "Ctrl+O"        -state disable
    $m add separator
    $m add command -label [::msgcat::mc "Exit"] -command Quit -accelerator "Ctrl+Q"
}


proc GetEditMenu {m} {
    $m add command -label [::msgcat::mc "Undo"] -command Undo\
    -accelerator "Ctrl+Z"
    $m add command -label [::msgcat::mc "Redo"] -command Redo\
    -accelerator "Ctrl+Y"
    $m add separator
    $m add command -label [::msgcat::mc "Copy"] -command Copy\
    -accelerator "Ctrl+C"
    $m add command -label [::msgcat::mc "Paste"] -command Paste\
    -accelerator "Ctrl+V"
    $m add command -label [::msgcat::mc "Cut"] -command Cut\
    -accelerator "Ctrl+Z"
    $m add separator
    $m add command -label [::msgcat::mc "Find"] -command Find\
    -accelerator "Ctrl+F"
    $m add command -label [::msgcat::mc "Replace"] -command Replace\
    -accelerator "Ctrl+R"
    $m add separator
    $m add command -label [::msgcat::mc "Find in files"] -command File::Find\
    -accelerator "Ctrl+Shift+F"
    $m add command -label [::msgcat::mc "Replace in files"] -command File::Replace\
    -accelerator "Ctrl+Shift+RV"
    $m add separator
    $m add command -label [::msgcat::mc "Insert image"] -accelerator "Ctrl+I"\
        -command ImageBase64Encode
    
}

proc GetViewMenu {m} {
    global cfgVariables
    $m add command -label [::msgcat::mc "View panel"] -command ViewFilesTree
    menu $m.panelSide 
    $m add cascade -label [::msgcat::mc "Panel side"] -menu $m.panelSide 
    
    $m.panelSide  add radiobutton -label [::msgcat::mc "Left"] -variable cfgVariables(filesPanelPlace) -value left
    $m.panelSide  add radiobutton -label [::msgcat::mc "Right"]  -variable cfgVariables(filesPanelPlace) -value right

    $m add separator
    $m add command -label [::msgcat::mc "View line numbers"] -command ViewLineNumbers
    
    menu $m.editorWrap
    $m add cascade -label [::msgcat::mc "Editors word wrapping"] -menu $m.editorWrap
    $m.editorWrap  add radiobutton -label [::msgcat::mc "None"] -variable cfgVariables(editorWrap) -value none \
        -command "Editor::SetOption wrap $cfgVariables(editorWrap)"
    $m.editorWrap  add radiobutton -label [::msgcat::mc "Char"] -variable cfgVariables(editorWrap) -value char \
        -command "Editor::SetOption wrap $cfgVariables(editorWrap)"
    $m.editorWrap  add radiobutton -label [::msgcat::mc "Word"] -variable cfgVariables(editorWrap) -value word \
        -command "Editor::SetOption wrap $cfgVariables(editorWrap)"
}

proc GetHelpMenu {m} {
    $m add command -label [::msgcat::mc "About ..."] -command Help::About
}
