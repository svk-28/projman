#!/usr/bin/wish
######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
#
# Tree  widget working module
#
######################################################


namespace eval Tree {
    proc InsertItem {tree parent item type text} {
        # set img [GetImage $fileName]
        set dot "_"
        puts "$tree $parent $item $type $text"
        switch $type  {
            file {
                regsub -all {\.|/|\\|\s} $item "_" subNode
                puts $subNode
                set image imgFile
            }
            directory {
                regsub -all {\.|/|\\|\s} $item "_" subNode
                puts $subNode
                set image folder
            }
        }
        append id $type "::" $subNode
        puts $id
        if ![$tree exists $id] {
            $tree insert $parent end -id "$id" -text $text -values "$item" -image $image
        }
            return "$id"
    }
    proc DoublePressItem {tree} {
        set id [$tree selection]
        $tree tag remove selected
        $tree item $id -tags selected
        
        set values [$tree item $id -values]
        set key [lindex [split $id "::"] 0]
        if {$values eq "" || $key eq ""} {return}
        
        puts "$key $tree $values"
        switch $key {
            directory {
                FileOper::ReadFolder  $values             
            }
            file {
                FileOper::Edit $values
                # $tree item $id -open false
            }
        }
    }

    proc PressItem {tree} {
        set id [$tree selection]
        $tree tag remove selected
        $tree item $id -tags selected
        
        set values [$tree item $id -values]
        set key [lindex [split $id "::"] 0]
        if {$values eq "" || $key eq ""} {return}
        
        puts "$key $tree $values"
        switch $key {
            directory {
                FileOper::ReadFolder  $values
                # $tree item $id -open false
            }
            file {
                FileOper::Edit $values
            }
        }
        # 
}

    proc GetItemID {tree item} {
        if [$tree exists $item] {
            return [$tree item $item -values]
        }
    }
}
