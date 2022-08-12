######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
#  GUI module
#######################################################

if {[info exists cfgVariables(geometry)]} {
    wm geometry . $cfgVariables(geometry)
} else {
    wm geometry . 1024x768
}
# Заголовок окна
wm title . "ProjMan \($projman(Version)-$projman(Release)\)"
wm iconname . "ProjMan"
# иконка окна (берется из файла lib/imges.tcl)
wm iconphoto . projman
wm protocol . WM_DELETE_WINDOW Quit
wm overrideredirect . 0
#wm positionfrom . user

bind . <Control-q> Quit
bind . <Control-Q> Quit
bind . <Control-eacute> Quit
bind . <Insert> Add
bind . <Delete> Del
bind . <Control-Return> Edit
bind . <F1> ShowHelpDialog
bind . <Control-n> Editor::New
bind . <Control-N> Editor::New
bind . <Control-o> {
    set filePath [FileOper::OpenDialog]
    if {$filePath != ""} {
        FileOper::Edit $filePath
    }
}
bind . <Control-O> {
    set filePath [FileOper::OpenDialog]
    if {$filePath != ""} {
        FileOper::Edit $filePath
    }
}
bind . <Control-k> {
    set folderPath [FileOper::OpenFolderDialog]
    if {$folderPath != ""} {
        FileOper::ReadFolder $folderPath
    }
}
bind . <Control-K> {
    set folderPath [FileOper::OpenFolderDialog]
    if {$folderPath != ""} {
        FileOper::ReadFolder $folderPath
    }
}
bind . <Control-s> {FileOper::Save}
bind . <Control-S> {FileOper::Save}
#ttk::style configure TPanedwindow -background blue
#ttk::style configure Sash -sashthickness 5
#ttk::style configure TButton  -padding 60  -relief flat -bg black
#ttk::style configure Custom.Treeview -foreground red
#ttk::style configure Custom.Treeview -rowheight 20

if [info exists cfgVariables(theme)] {
    ttk::style theme use $cfgVariables(theme)
}

frame .frmMenu -border 1 -relief raised  -highlightthickness 0
frame .frmBody -border 1 -relief raised -highlightthickness 0
ttk::frame .frmStatus -border 0 -relief sunken 
pack .frmMenu -side top -padx 1 -fill x
pack .frmBody -side top -padx 1 -fill both -expand true
pack .frmStatus -side top -padx 1 -fill x

# pack .panel -expand true -fill both
# pack propagate .panel false
#pack [label .frmMenu.lbl -text "ddd"]
pack [ttk::label .frmStatus.lblPosition -justify right] -side right

menubutton .frmMenu.mnuFile -text [::msgcat::mc "File"] -menu .frmMenu.mnuFile.m
GetFileMenu [menu .frmMenu.mnuFile.m]

menubutton .frmMenu.mnuEdit -text [::msgcat::mc "Edit"] -menu .frmMenu.mnuEdit.m
GetEditMenu [menu .frmMenu.mnuEdit.m]

menubutton .frmMenu.mnuView -text [::msgcat::mc "View"] -menu .frmMenu.mnuView.m
GetViewMenu [menu .frmMenu.mnuView.m]

pack .frmMenu.mnuFile .frmMenu.mnuEdit .frmMenu.mnuView -side left

menubutton .frmMenu.mnuHelp -text [::msgcat::mc "Help"] -menu .frmMenu.mnuHelp.m
GetHelpMenu [menu .frmMenu.mnuHelp.m]
pack .frmMenu.mnuHelp -side right


set frmTool [ttk::frame .frmBody.frmTool]
ttk::panedwindow .frmBody.panel -orient horizontal -style TPanedwindow
pack propagate .frmBody.panel false

pack .frmBody.frmTool -side left -fill y
pack .frmBody.panel -side left -fill both -expand true

ttk::button $frmTool.btn_tree  -command  ViewFilesTree  -image tree_24x24

pack $frmTool.btn_tree -side top -padx 1 -pady 1
# #label $frmTool.lbl_logo -image tcl
# pack $frmTool.btn_quit -side bottom -padx 5 -pady 5
# #pack $frmTool.lbl_logo -side bottom -padx 5 -pady 5
# 
# # Дерево с полосами прокрутки
set frmTree [ttk::frame .frmBody.frmTree]

set tree [ttk::treeview $frmTree.tree -show tree \
    -xscrollcommand [list .frmBody.frmTree.h set] -yscrollcommand [list .frmBody.frmTree.v set]]
    
ttk::scrollbar $frmTree.h -orient horizontal -command [list $frmTree.tree xview]
ttk::scrollbar $frmTree.v -orient vertical -command [list $frmTree.tree yview]



bind $tree <Double-ButtonPress-1> {Tree::DoublePressItem $tree}
bind $tree  <ButtonRelease-1> {Tree::PressItem $tree}

grid $tree -row 0 -column 0 -sticky nsew
grid $frmTree.v -row 0 -column 1 -sticky nsew
# grid $frmTree.h -row 1 -column 0 -sticky nsew
grid columnconfigure $frmTree 0 -weight 1
grid rowconfigure $frmTree 0 -weight 1

set frm_work [ttk::frame .frm_work]

set nbEditor [ttk::notebook $frm_work.nbEditor]

#grid $nbEditor -row 0 -column 0 -sticky nsew
pack $nbEditor -fill both -expand true

# Create an image CLOSE for tab
ttk::style element create close_button image close_10x10 -height 12 -width 12 -sticky e -padding {10 0}

ttk::style layout TNotebook.Tab {
    Notebook.tab -sticky nswe -children {
        Notebook.padding -expand 1 -sticky nswe -children {
            Notebook.label
            -expand 1 -sticky nesw -side left close_button -side right
        }
    }
}

bind TNotebook <Button-1> "NB::CloseTab %W %x %y\;[bind TNotebook <Button-1>]"

# ttk::scrollbar $nbEditor.hsb1 -orient horizontal -command [list $frm_tree.work xview]
# ttk::scrollbar $fbEditor.vsb1 -orient vertical -command [list $frm_tree.work yview]
# set tree [ttk::treeview $frm_tree.tree -show tree \
# -xscrollcommand [list $frm_tree.hsb1 set] -yscrollcommand [list $frm_tree.vsb1 set]]
# 

# # назначение обработчика нажатия кнопкой мыши
# #bind $frm_tree.tree <ButtonRelease> "TreePress %x %y %X %Y $frm_tree.tree"
# bind $frm_tree.tree <ButtonRelease> "TreePress $frm_tree.tree"

#.panel add $frmTool -weight 1
if {$cfgVariables(toolBarShow) eq "true"} {        
    .frmBody.panel add $frmTree -weight 0
} 
.frmBody.panel add $frm_work -weight 1 

ttk::style configure . \
    -foreground $::cfgVariables(guiFG) \
    -font $::cfgVariables(guiFont)
