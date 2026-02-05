######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
#
# Operation with  NoteBook widget module
#
######################################################

namespace eval NB {
    proc InsertItem {nb item type} {
        switch $type {
            file {
                set titleFileName [file tail $item]
                set item [string tolower $item]
                regsub -all {\.|/|\\|\s|:} $item "_" itemName
                # puts "$item -> $itemName"
                if [winfo exists $nb.$itemName] {
                    set fm $nb.$itemName
                } else {
                    set fm [ttk::frame $nb.$itemName]
                    pack $fm -side top -expand true -fill both
                    $nb add $fm -text $titleFileName;# -image close_12x12 -compound right
                    $nb select $fm
                }
            }
            git {
                if [winfo exists $nb.$item] {
                    return $nb.$item
                }
                set fm [ttk::frame $nb.$item]
                pack $fm -side top -expand true -fill both
                $nb add $fm -text Git;# -image close_12x12 -compound right
                $nb select $fm                
            }
        }
        # puts "NB item - $fm"
        return $fm
    }

    proc PressTab {w x y} {
        global tree
        if {[$w identify tab $x $y] ne ""} {
            $w select [$w identify tab $x $y]
            set nbItem [string trimleft [$w select] "$w."]
            # puts  $nbItem
            append treeItemName "file" "::" $nbItem
            Tree::SelectItem $treeItemName
        } else {
            return
        }
        if {[$w identify $x $y] == "close_button"} {
            # puts "NB::PressTab: w - $w"
            FileOper::Close $w
        } else {
            set txt [$w select].frmText.t
            if {[winfo exists [$w select].frmText2] == 1} {
                focus -force [$w select].frmText2.frame.text.t
            } else {
                if [winfo exists $txt] {
                    focus -force $txt.t
                }
            }
        }
    }

    proc NextTab {w step} {
        global tree
        set i [expr [$w index end] - 1]
        # puts "NB::NextTab $w"
        if {[$w select] eq ""} {
            # puts "NB::NextTab no items availabels"
            if {$w eq ".frmWork.nbEditor2"} {
                .frmWork.panelNB forget .frmWork.nbEditor2
            }
            return
        }
        set nbItemIndex [$w index [$w select]]
        if {$nbItemIndex eq 0 && $step eq "-1"} {
            $w select $i
        } elseif {$nbItemIndex eq $i && $step eq "1"} {
            $w select 0
        } else {
            $w select [expr $nbItemIndex + $step]
        }
        set nbItem [string trimleft [$w select] "$w."]
        append treeItemName "file" "::" $nbItem
        Tree::SelectItem $treeItemName
        
        set txt [$w select].frmText.t
        DebugPuts "NextTab: [$w select]"
        if {[winfo exists [$w select].frmText2] == 1} {
            focus -force [$w select].frmText2.frame.text.t
        } else {
            if [winfo exists $txt] {
                focus -force $txt.t
            }
        }
    }
}
