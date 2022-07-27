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
                regsub -all {\.|/|\\|\s} $item "_" itemName
                if [winfo exists $nb.$itemName] {
                    set fm $nb.$itemName
                } else {
                    set fm [ttk::frame $nb.$itemName]
                    pack $fm -side top -expand true -fill both
                    $nb add $fm -text [file tail $item];# -image close_12x12 -compound right
                    $nb select $fm
                }
            }
        }
        puts "NB item - $fm"
        return $fm
    }

    proc CloseTab {w x y} {
        if {[$w identify $x $y] == "close_button"} {
            FileOper::Close
        }
    }
}
