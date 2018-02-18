###########################################################
#                Tcl/Tk Project Manager                   #
#                Distrubuted under GPL                    #
# Copyright (c) "Sergey Kalinin", 2002, http://nuk-svk.ru #
# Author: Sergey Kalinin banzaj28@yandex.ru               #
###########################################################

Modules
## MAIN INTERFACE ##
#
if {[info exists topLevelGeometry]} {
    wm geometry . $topLevelGeometry
} else {
    wm geometry . 1200x1024+0+0
}

wm title . "Tcl/Tk Project Manager $ver"
wm iconname . "Tcl/Tk Project Manager $ver"
#image create photo icon -format png -file [file join $imgDir icons large projman.png]
image create photo icon -data {
    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
}
wm iconphoto . icon
wm protocol . WM_DELETE_WINDOW Quit
wm overrideredirect . 0
wm positionfrom . user
#wm resizable . 0 0

frame .frmMenu -border 1 -relief raised -background $editor(bg)
frame .frmTool -border 1 -relief raised -background $editor(bg)
frame .frmBody -border 1 -relief raised -background $editor(bg)
frame .frmStatus -border 1 -relief sunken -bg $editor(bg)
pack .frmMenu -side top -padx 1 -fill x
pack .frmTool -side top -padx 1 -fill x
pack .frmBody -side top -padx 1 -fill both -expand true
pack .frmStatus -side top -padx 1 -fill x

########## CREATE MENU LINE ##########
menubutton .frmMenu.mnuFile -text [::msgcat::mc "File"] -menu .frmMenu.mnuFile.m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuFile.m -bg $editor(bg) -fg $editor(fg)]
$m add cascade -label [::msgcat::mc "New"] -menu $m.new -font $fontNormal
set mn [menu $m.new  -bg $editor(bg) -fg $editor(fg)]
$mn add command -label [::msgcat::mc "New file"] -command {AddToProjDialog file}\
-font $fontNormal -accelerator "Ctrl+N"
$mn add command -label [::msgcat::mc "New directory"] -command {AddToProjDialog directory}\
-font $fontNormal -accelerator "Ctrl+N"
$mn add command -label [::msgcat::mc "New project"] -command {NewProjDialog "new"}\
-font $fontNormal
#$m add command -label [::msgcat::mc "Open"] -command {FileDialog $tree open}\
#-font $fontNormal -accelerator "Ctrl+O"        -state disable
$m add command -label [::msgcat::mc "Save"] -command {FileDialog [$noteBookFiles raise] save}\
-font $fontNormal -accelerator "Ctrl+S"
$m add command -label [::msgcat::mc "Save as"] -command {FileDialog [$noteBookFiles raise] save_as}\
-font $fontNormal
$m add command -label [::msgcat::mc "Save all"] -command {FileDialog [$noteBookFiles raise] save_all}\
-font $fontNormal
$m add command -label [::msgcat::mc "Close"] -command {FileDialog [$noteBookFiles raise] close}\
-font $fontNormal -accelerator "Ctrl+W"
$m add command -label [::msgcat::mc "Close all"] -command {FileDialog [$noteBookFiles raise] close_all}\
-font $fontNormal
$m add command -label [::msgcat::mc "Delete"] -command {FileDialog [$noteBookFiles raise] delete}\
-font $fontNormal -accelerator "Ctrl+D"
$m add separator
$m add command -label [::msgcat::mc "Compile file"] -command {MakeProj compile file} -font $fontNormal -accelerator "Ctrl+F8"
$m add command -label [::msgcat::mc "Run file"] -command {MakeProj run file} -font $fontNormal -accelerator "Ctrl+F9"
$m add separator
$m add command -label [::msgcat::mc "Print"] -command PrintDialog\
-font $fontNormal -accelerator "Ctrl+P"
$m add separator
$m add command -label [::msgcat::mc "Settings"] -command Settings -font $fontNormal
$m add separator
$m add command -label [::msgcat::mc "Exit"] -command Quit -font $fontNormal -accelerator "Ctrl+Q"

##.frmMenu 'Project' ##


menubutton .frmMenu.mnuProj -text [::msgcat::mc "Project"] -menu .frmMenu.mnuProj.m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuProj.m -bg $editor(bg) -fg $editor(fg)]
GetProjMenu $m

##.frmMenu 'Edit' ##
menubutton .frmMenu.mnuEdit -text [::msgcat::mc "Edit"] -menu .frmMenu.mnuEdit.m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
## BUILDING EDIT-MENU FOR MAIN AND POP-UP MENU ##
GetMenu [menu .frmMenu.mnuEdit.m -bg $editor(bg) -fg $editor(fg)];# main edit menu
GetMenu [menu .popMnuEdit -bg $editor(bg) -fg $editor(fg)] ;# pop-up edit menu

## VIEW MENU ##
menubutton .frmMenu.mnuView -text [::msgcat::mc "View"] -menu .frmMenu.mnuView.m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuView.m -bg $editor(bg) -fg $editor(fg)]
$m add checkbutton -label [::msgcat::mc "Toolbar"] -font $fontNormal -state normal\
-offvalue "No" -onvalue "Yes" -variable toolBar -command {ToolBar}
$m add command -label [::msgcat::mc "Split edit window"] -font $fontNormal -accelerator "F4" -state disable\
-command SplitWindow
$m add separator
$m add command -label [::msgcat::mc "Refresh"] -font $fontNormal -accelerator "F5" -state normal\
-command UpdateTree

##.frmMenu Settings ##
menubutton  .frmMenu.mnuCVS -text [::msgcat::mc "Modules"] -menu .frmMenu.mnuCVS.m \
-font $fontNormal -state normal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuCVS.m -bg $editor(bg) -fg $editor(fg)]
if {[info exists module(tkcvs)]} {
    $m add command -label "TkCVS" -command {DoModule tkcvs} -font $fontNormal
}
if {[info exists module(tkdiff)]} {
    $m add command -label "TkDIFF+" -command {DoModule tkdiff} -font $fontNormal
}
if {[info exists module(tkregexp)]} {
    $m add command -label "TkREGEXP" -command {DoModule tkregexp} -font $fontNormal
}
if {[info exists module(gitk)]} {
    $m add command -label "Gitk" -font $fontNormal -command {
        DoModule gitk
        GetTagList [file join $workDir $activeProject.tags] ;# geting tag list
    }
}
menubutton  .frmMenu.mnuHelp  -text [::msgcat::mc "Help"] -menu .frmMenu.mnuHelp.m \
-underline 0 -font $fontNormal -bg $editor(bg) -fg $editor(fg)
set m [menu .frmMenu.mnuHelp.m -bg $editor(bg) -fg $editor(fg)]
$m  add  command  -label [::msgcat::mc "Help"]  -command  ShowHelp \
-accelerator F1 -font $fontNormal
$m add command -label [::msgcat::mc "About ..."] -command AboutDialog \
-font $fontNormal

pack .frmMenu.mnuFile .frmMenu.mnuProj .frmMenu.mnuEdit .frmMenu.mnuView .frmMenu.mnuCVS -side left
pack .frmMenu.mnuHelp -side right
## Bind command ##
bind . <F1> ShowHelp
bind . <F5> UpdateTree
bind . <F6> MakeRPM
bind . <F7> MakeTGZ
bind . <F8> {MakeProj compile proj}
bind . <Control-F8> {MakeProj compile file}
bind . <F9> {MakeProj run proj}
bind . <Control-F9> {MakeProj run file}
bind . <Control-ograve> AddToProjDialog
bind . <Control-n> AddToProjDialog
bind . <Control-ocircumflex> AddToProjDialog
bind . <Control-a> AddToProjDialog
bind . <Control-eacute> Quit
bind . <Control-q> Quit
bind . <Control-ccedilla> PrintDialog
bind . <Control-p> PrintDialog
set sepIndex 0

########## STATUS BAR ##########
set frm1 [frame .frmStatus.frmHelp -bg $editor(bg)]
set frm2 [frame .frmStatus.frmActive -bg $editor(bg)]
set frm3 [frame .frmStatus.frmProgress -relief sunken -bg $editor(bg)]
set frm4 [frame .frmStatus.frmLine -bg $editor(bg)]
set frm5 [frame .frmStatus.frmFile -bg $editor(bg)]
set frm6 [frame .frmStatus.frmOvwrt -bg $editor(bg)]
pack $frm1 $frm4 $frm6 $frm2 $frm5 -side left -fill x
pack $frm3 -side left -fill x -expand true
label $frm1.lblHelp -width 25 -relief sunken -font $fontNormal \
-anchor w -bg $editor(bg) -fg $editor(fg)
pack $frm1.lblHelp -fill x
label $frm4.lblLine -width 10 -relief sunken -font $fontNormal \
-anchor w -bg $editor(bg) -fg $editor(fg)
pack $frm4.lblLine -fill x
label $frm2.lblActive -width 25 -relief sunken -font $fontNormal \
-anchor center -bg $editor(bg) -fg $editor(fg)
pack $frm2.lblActive -fill x
label $frm3.lblProgress -relief sunken -font $fontNormal \
-anchor w -bg $editor(bg) -fg $editor(fg)
pack $frm3.lblProgress -fill x
label $frm5.lblFile -width 10 -relief sunken -font $fontNormal \
-anchor w -bg $editor(bg) -fg $editor(fg)
pack $frm5.lblFile -fill x
label $frm6.lblOvwrt -width 10 -relief sunken -font $fontNormal \
-anchor center -bg $editor(bg) -fg $editor(fg)
pack $frm6.lblOvwrt -fill x

########## PROJECT-FILE-FUNCTION TREE ##################

#set frmCat [frame .frmBody.frmCat -border 1 -relief sunken -bg $editor(bg)]
set frmCat [frame .frmBody.frmCat -border 1 -relief sunken]
pack $frmCat -side left -fill y -fill both
#set frmWork [frame .frmBody.frmWork -border 1 -relief sunken -bg $editor(bg)]
set frmWork [frame .frmBody.frmWork -border 1 -relief sunken]
pack $frmWork -side left -fill both -expand true

## CREATE PANE ##
pane::create .frmBody.frmCat .frmBody.frmWork

# NoteBook - Projects and Files
#################### WORKING AREA ####################
set noteBookFiles [NoteBook $frmCat.noteBook -font $fontNormal -side top -bg $editor(bg) -fg $editor(fg) \
-activebackground $editor(bg) -activeforeground $editor(fg) ]
pack $noteBookFiles -fill both -expand true -padx 2 -pady 2
set nbProjects [$noteBookFiles insert end projects -text [::msgcat::mc "Projects"] \
-activebackground $editor(bg) -activeforeground $editor(fg)]
set nbFiles [$noteBookFiles insert end files -text [::msgcat::mc "Files"]   \
-activebackground $editor(bg) -activeforeground $editor(fg)]


# Create FileTree
FileTree::create $nbFiles

# Create Project tree
set frmTree [ScrolledWindow $nbProjects.frmTree -bg $editor(bg)]
global tree noteBook
set tree [Tree $frmTree.tree \
-relief sunken -borderwidth 1 -width 5 -height 5 -highlightthickness 1\
-redraw 0 -dropenabled 1 -dragenabled 1 -dragevent 3 \
-background $editor(bg) -selectbackground $editor(selectbg) -selectforeground white\
-droptypes {
    TREE_NODE    {copy {} move {} link {}}
    LISTBOX_ITEM {copy {} move {} link {}}
} -opencmd {TreeOpen} -closecmd  {TreeClose}]
$frmTree setwidget $tree
pack $frmTree -side top -fill both -expand true

$noteBookFiles raise projects

$tree bindText  <Double-ButtonPress-1> "TreeDoubleClick $tree [$tree selection get]"
$tree bindText  <ButtonPress-1> "TreeOneClick $tree [$tree selection get]"
$tree bindImage  <Double-ButtonPress-1> "TreeDoubleClick $tree [$tree selection get]"
$tree bindImage  <ButtonPress-1> "TreeOneClick $tree [$tree selection get]"
$tree bindText <Shift-Button-1> {$tree selection add [$tree selection get]}
bind $frmTree.tree.c <Control-acircumflex> {FileDialog [$noteBookFiles raise] delete}
bind $frmTree.tree.c <Control-d> {FileDialog [$noteBookFiles raise] delete}
bind $frmTree.tree.c <Return> {
    set node [$tree selection get]
    TreeOneClick $tree $node
    TreeDoubleClick $tree $node
}

## POPUP FILE-MENU ##
set m .popupFile
menu $m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
$m add command -label [::msgcat::mc "New file"] -command {AddToProjDialog file}\
-font $fontNormal -accelerator "Ctrl+N"
$m add command -label [::msgcat::mc "New directory"] -command {AddToProjDialog directory}\
-font $fontNormal -accelerator "Alt + Ctrl+N"
$m add command -label [::msgcat::mc "Open"] -command {FileDialog [$noteBookFiles raise] open}\
-font $fontNormal -accelerator "Ctrl+O"        -state disable
$m add command -label [::msgcat::mc "Save"] -command {FileDialog [$noteBookFiles raise] save}\
-font $fontNormal -accelerator "Ctrl+S"
$m add command -label [::msgcat::mc "Save as"] -command {FileDialog [$noteBookFiles raise] save_as}\
-font $fontNormal -accelerator "Ctrl+A"
$m add command -label [::msgcat::mc "Save all"] -command {FileDialog [$noteBookFiles raise] save_all}\
-font $fontNormal
$m add command -label [::msgcat::mc "Close"] -command {FileDialog [$noteBookFiles raise] close}\
-font $fontNormal -accelerator "Ctrl+W"
$m add command -label [::msgcat::mc "Close all"] -command {FileDialog [$noteBookFiles raise] close_all}\
-font $fontNormal
$m add command -label [::msgcat::mc "Delete"] -command {FileDialog [$noteBookFiles raise] delete}\
-font $fontNormal -accelerator "Ctrl+D"
$m add separator
$m add command -label [::msgcat::mc "Compile file"] -command {MakeProj compile file} \
-font $fontNormal -accelerator "Ctrl+F8"
$m add command -label [::msgcat::mc "Run file"] -command {MakeProj run file} -font $fontNormal \
-accelerator "Ctrl+F9"
$m add separator
$m add command -label [::msgcat::mc "Add to existing project"] -command {AddToProjDialog ""} \
-font $fontNormal -state disable
$m add command -label [::msgcat::mc "Add as new project"] -command {OpenProj [$noteBookFiles raise]} -font $fontNormal
    

## POPUP PROJECT-MENU ##
set m [menu .popupProj -font $fontNormal -bg $editor(bg) -fg $editor(fg)]
GetProjMenu $m

## TABS popups ##
set m .popupTabs
menu $m -font $fontNormal -bg $editor(bg) -fg $editor(fg)
$m add command -label [::msgcat::mc "Close"] -command {FileDialog [$noteBookFiles raise] close}\
-font $fontNormal -accelerator "Ctrl+W"
$m add command -label [::msgcat::mc "Close all"] -command {FileDialog [$noteBookFiles raise] close_all}\
-font $fontNormal


bind $frmTree.tree.c <Button-3> {catch [PopupMenuTree %X %Y]}

######### DEDERER: bind Wheel Scroll ##################
bind $frmTree.tree.c <Button-4> "$tree yview scroll -3 units"
bind $frmTree.tree.c <Button-5> "$tree yview scroll  3 units"
bind $frmTree.tree.c <Shift-Button-4> "$tree xview scroll -2 units"
bind $frmTree.tree.c <Shift-Button-5> "$tree xview scroll  2 units"

#################### WORKING AREA ####################
set noteBook [NoteBook $frmWork.noteBook -font $fontNormal -side top -bg $editor(bg) -fg $editor(fg)]
pack $noteBook -fill both -expand true -padx 2 -pady 2
$noteBook bindtabs  <ButtonRelease-1> "PageRaise $tree [$noteBook raise]"
$noteBook bindtabs <Button-3> {catch [PopupMenuTab .popupTabs %X %Y]}

#bind . <Control-udiaeresis> PageTab
#bind . <Control-M> PageTab

bind . <Control-Next> {PageTab 1}
bind . <Control-Prior> {PageTab -1}

##################################################
CreateToolBar
GetProj $tree
$tree configure -redraw 1
set activeProject ""
focus -force $tree

# Opened last active project
if {[info exists workingProject]} {
    if {$workingProject ne ""} {
        TreeDoubleClick .frmBody.frmCat.noteBook.fprojects.frmTree.tree $workingProject
    }
}




