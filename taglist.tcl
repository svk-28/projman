#########################################################
#                Tcl/Tk project Manager
#        Distributed under GNU Public License
# Author: Sergey Kalinin banzaj@lrn.ru
# Copyright (c) "CONERO lab", 2002, http://conero.lrn.ru
#########################################################

proc GetTagList {tagFile} {
    global tmpDir projDir workDir procList activeProject
    
    if {[file exists $tagFile] == 0} {
        return
    }
    
    set file [open $tagFile r]
    set procList($activeProject) ""
    while {[gets $file line]>=0} {
        scan $line "%s%s" proc procFile
        if {[regexp -nocase -all -- {\s\{.*?\}+\s} $line par]} {
            if [info exists procList($activeProject)] {
                lappend procList($activeProject) [list $proc $par $procFile]
            } else {
                set procList($activeProject) [list [list $proc $par $procFile]]
            }
        }
    }
}


proc GetTagList_ {tagFile} {
    global tmpDir projDir workDir procList activeProject
    if {[file exists $tagFile] == 0} {
        return
    }
    set projName [file rootname $tagFile]
    set file [open $tagFile r]
    set procList($projName) ""
    while {[gets $file line]>=0} {
        scan $line "%s%s" proc procFile
        if {[regexp -nocase -all -- {\s\{.*?\}+\s} $line par]} {
            if [info exists procList($projName)] {
                lappend procList($projName) [list $proc $par $procFile]
            } else {
                set procList($projName) [list [list $proc $par $procFile]]
            }
        }
    }
}







