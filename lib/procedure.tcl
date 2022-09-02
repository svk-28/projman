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
    if {$cfgVariables(filesPanelShow) eq "true"} {
        .frmBody.panel forget .frmBody.frmTree
        set cfgVariables(filesPanelShow) false
    } else {
        switch $cfgVariables(filesPanelPlace) {
        "left" {        
                .frmBody.panel insert 0 .frmBody.frmTree
            }
            "right" {
                .frmBody.panel add .frmBody.frmTree
            }
            default {
                .frmBody.panel insert 0 .frmBody.frmTree
            }
        }
        set cfgVariables(filesPanelShow) true
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

proc ImageBase64Encode {} {
    global env nbEditor
    set types {
        {"PNG" {.png}}
        {"GIF" {.gif}}
        {"JPEG" {.jpg}}
        {"BMP" {.bmp}}
        {"All files" *}
    }
    set txt "[$nbEditor select].frmText.t"
    set img [tk_getOpenFile -initialdir $env(HOME) -filetypes $types -parent .]
    if {$img ne ""} {
        set f [open $img]
        fconfigure $f -translation binary
        set data [base64::encode [read $f]]
        close $f
        # base name on root name of the image file
        set name [file root [file tail $img]]
        $txt insert insert "image create photo $name -data {\n$data\n}"
    }
}
proc FindImage {ext} {
    foreach img [image names] {
        if [regexp -nocase -all -- "^($ext)(_)" $img match v1 v2] {
            # puts "\nFindinig images: $img \n"
            return $img
        }
    }
}

namespace eval Help {
    proc About {} {
        global projman
        set msg "Tcl/Tk project Manager\n\n"
        append msg  "Version: " $projman(Version) "\n" \
            "Release: " $projman(Release) "\n" \
            "Build: " $projman(Build) "\n\n" \
            "Author: " $projman(Author) "\n" \
            "Home page: " $projman(Homepage)
        # foreach name [array names projman] {
            # append msg $name ": " $projman($name) "\n"
        # }
        set answer [
            tk_messageBox -message "[::msgcat::mc "About ..."] ProjMan" \
            -icon info -type ok -detail $msg
        ]
        switch $answer {
            ok {return}
        }
    }
}

proc SearchVariable {varName} {
    global fileStructure project variables
    # puts "$fileStructure"
    foreach key [dict keys $project] {
        foreach f [dict get $project $key] {
            foreach v [dict get $project $key $f] {
                puts "--$v"
            }
        }
    }
}
