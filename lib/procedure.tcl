######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
#
# All procedures module
#
######################################################

proc Quit {} {
    global dir
    Config::write $dir(cfg)
    if {[FileOper::CloseAll] eq "cancel"} {
        return "cancel"
    } else {
        exit
    }
}

proc ViewFilesTree {} {
    global cfgVariables
    if {$cfgVariables(toolBarShow) eq "true"} {
        .frmBody.panel forget .frmBody.frmTree
        set cfgVariables(toolBarShow) false
    } else {
        .frmBody.panel insert 0 .frmBody.frmTree
        set cfgVariables(toolBarShow) true
    }
}

# Enable/Disabled line numbers in editor
proc ViewLineNumbers {} {
    global cfgVariables nbEditor
    # Changed global settigs
    if {$cfgVariables(lineNumberShow) eq "true"} {
        set cfgVariables(lineNumberShow) false
    } else {
        set cfgVariables(lineNumberShow) true
    }
    # apply changes for opened tabs
    foreach node [$nbEditor tabs] {
        $node.frmText.t configure -linemap $cfgVariables(lineNumberShow)
    }
}

proc Del {} {
    return
}

proc YScrollCommand {txt canv} {
    $txt yview
    $canv yview"
}

proc ResetModifiedFlag {w} {
    global modified nbEditor
    $w.frmText.t edit modified false
    set modified($w) "false"
    set lbl [string trimleft [$nbEditor tab $w -text] "* "]
    puts "ResetModifiedFlag: $lbl"
    $nbEditor tab $w -text $lbl
}
proc SetModifiedFlag {w} {
    global modified nbEditor
    #$w.frmText.t edit modified false
    set modified($w) "true"
    set lbl [$nbEditor tab $w -text]
    puts "SetModifiedFlag: $w; $modified($w); >$lbl<"
    if {[regexp -nocase -all -- {^\*} $lbl match] == 0} {
        set lbl "* $lbl"
    }
    $nbEditor tab $w -text $lbl
}

