#!/usr/bin/wish                                                                 

###########################################################
#                Tcl/Tk Project Manager                   #
#                Distrubuted under GPL                    #
# Copyright (c) "CONERO lab", 2002, http://conero.lrn.ru  #
# Author: Sergey Kalinin (aka BanZaj) banzaj@lrn.ru       #
###########################################################

########## VERSION INFORMATION ##########
set ver "0.4.5"

package require BWidget
package require msgcat

## DO NOT EDIT THIS LINE! USE install.tcl SCRIPT ##
set rootDir "/usr"
set tclDir "/usr/bin"

##
if {[file exists $env(HOME)/projects/tcl/projman]==1} {
    set dataDir "[file join $env(HOME) projects tcl projman]"
    set docDir "[file join $env(HOME) projects tcl projman hlp ru]"
    set imgDir "[file join $env(HOME) projects tcl projman img]"
    set msgDir "[file join $env(HOME) projects tcl projman msgs]"
    set hlDir "[file join $env(HOME) projects tcl projman highlight]"
    set binDir "[file join $env(HOME) projects tcl projman]"
} else {
    set binDir  [file join $rootDir bin]
    set dataDir [file join $rootDir share projman]
    set docDir  [file join $rootDir share doc projman-$ver]
    set imgDir  [file join $dataDir img]
    set msgDir  [file join $dataDir msgs]
    set hlDir  [file join $dataDir highlight]
}
if {$tcl_platform(platform) == "unix"} {
    set tmpDir "$env(HOME)/tmp"
    set workDir "[file join $env(HOME) .projman]"
} elseif {$tcl_platform(platform) == "windows"} {
    if [info exists env(TEMP)] {
        set tmpDir "$env(TEMP)"
    } else {
        set tmpDir "c:\\temp"
    }
    if {[info exist env(HOMEDRIVE)] && [info exists env(HOMEPATH)]} {
        set workDir "[file join $env(HOMEDRIVE)/$env(HOMEPATH) .projman]"
    } else {
        set workDir "[file join $rootDir .projman]"
    }
}
if {[file exists $workDir] == 0} {file mkdir $workDir}
if {[file exists $tmpDir] == 0} {file mkdir $tmpDir}

if {[file exists [file join $workDir projman.conf]] == 0} {
    file copy -force -- [file join $dataDir projman.conf] [file join $workDir projman.conf]
}

source [file join $workDir projman.conf]

## CREATE WORK DIR ##
if {[file exists $rpmDir] != 1} {file mkdir $rpmDir}
if {[file exists $tgzDir] != 1} {file mkdir $tgzDir}
if {[file exists $projDir] != 1} {file mkdir $projDir}

## SETTINGS ENVIRONMENT LANGUAGE ##
if [info exists env(LANG)] {
    set locale $env(LANG)
} else {
    set locale $locale
}

::msgcat::mclocale $locale
::msgcat::mcload $msgDir
#set mc_source [open [file join $msgDir $locale.msg] "r"]
#set mc_source [encoding convertto koi8-r $mc_source]
#set mc_source [encoding convertfrom [encoding system] $mc_source]

## LOAD FILE ##


source [file join $dataDir procedure.tcl]
source [file join $dataDir supertext.tcl]
source [file join $dataDir editor.tcl]
source [file join $dataDir help.tcl]
source [file join $dataDir settings.tcl]
source [file join $dataDir baloon.tcl]
source [file join $dataDir completition.tcl]
source [file join $dataDir pane.tcl]
source [file join $dataDir taglist.tcl]
source [file join $dataDir projects.tcl]
source [file join $dataDir imgviewer.tcl]
source [file join $dataDir main.tcl]


foreach file [lsort [glob -nocomplain [file join $hlDir *.tcl]]] {
    source $file
    puts "Loaded highlight module $file"
}

set editor(selectBorder) "0"

#option add *tree.foreground red widgetDefault


