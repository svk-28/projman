#!/bin/sh
# Tcl ignores the next line -*- tcl -*- \
exec wish "$0" -- "$@"

###########################################################
#                Tcl/Tk Project Manager                   #
#                Distrubuted under GPL                    #
# Copyright (c) "Sergey Kalinin", 2001, http://nuk-svk.ru #
# Author: Sergey Kalinin banzaj28@yandex.ru               #
###########################################################

########## VERSION INFORMATION ##########
set ver "0.4.5"

package require BWidget
package require msgcat

set wishOpList [info commands]
## DO NOT EDIT THIS LINE! USE install.tcl SCRIPT ##

# if {$tcl_platform(platform) == "unix"} {
#     set initDir "$env(HOME)"
#     set rootDir "/usr/local"
#     set tmpDir "$env(HOME)/tmp"
#     set tclDir "/usr/bin"
# } elseif {$tcl_platform(platform) == "windows"} {
#     set initDir "c:\\"
#     set rootDir "c:\\Tcl"
#     set tmpDir "c:\\temp"
#     set tclDir "C:\\Tcl\\bin"
# }
set tclDir [file dirname [info nameofexecutable]]
puts $tclDir
set rootDir [pwd]
#set rootDir "/usr"
#set tclDir "/usr/bin"

if {[file exists $env(HOME)/projects/tcl/projman]==1} {
    set dataDir "[file join $env(HOME) projects tcl projman lib]"
    set docDir "[file join $env(HOME) projects tcl projman hlp ru]"
    set imgDir "[file join $env(HOME) projects tcl projman img]"
    set msgDir "[file join $env(HOME) projects tcl projman msgs]"
    set binDir "[file join $env(HOME) projects tcl projman]"
} else {
    set dataDir "[file join $rootDir lib]"
    set docDir "[file join $rootDir hlp ru]"
    set imgDir "[file join $rootDir img]"
    set msgDir "[file join $rootDir msgs]"
    set binDir $rootDir
#    set binDir  [file join $rootDir bin]
#    set dataDir [file join $rootDir share projman]
#    set docDir  [file join $rootDir share doc projman-$ver]
#    set imgDir  [file join $dataDir img]
#    set msgDir  [file join $dataDir msgs]
}
set hlDir  [file join $dataDir highlight]

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
        set workDir "[file join $env(HOMEDRIVE) $env(HOMEPATH) .projman]"
    } else {
        set workDir "[file join $rootDir .projman]"
    }
}
if {[file exists $workDir] == 0} {file mkdir $workDir}
if {[file exists $tmpDir] == 0} {file mkdir $tmpDir}

if {[file exists [file join $workDir projman.conf]] == 0} {
    file copy -force -- projman.conf [file join $workDir projman.conf]
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

## LOAD FILE ##
# Load modules but maain.tcl must last loaded
foreach modFile [lsort [glob -nocomplain [file join $dataDir *.tcl]]] {
    if {[file tail $modFile] ne "main.tcl"} {
        source $modFile
        puts "Loaded module $modFile"
    }
}
# load code highlight modules
foreach modFile [lsort [glob -nocomplain [file join $hlDir *.tcl]]] {
    source $modFile
    puts "Loaded highlight module $modFile"
}

source [file join $dataDir main.tcl]

#option add *tree.foreground red widgetDefault
# Set colors for widgets
option add *Frame.background $editor(bg) startupFile
option add *Scrollableframe.background $editor(bg) startupFile
option add *Scrolledwindow.background $editor(bg) startupFile
option add *Button.foreground $editor(fg) startupFile
option add *Button.background $editor(bg) startupFile
option add *Entry.foreground $editor(fg) startupFile
option add *Entry.background $editor(bg) startupFile
option add *Label.foreground $editor(fg) startupFile
option add *Label.background $editor(bg) interactive
option add *Checkbox.foreground $editor(fg) startupFile
option add *Checkbox.background $editor(bg) startupFile
option add *Checkbutton.foreground $editor(fg) startupFile
option add *Checkbutton.background $editor(bg) startupFile
option add *Combobox.foreground $editor(fg) startupFile
option add *Combobox.background $editor(bg) startupFile
option add *Text.foreground $editor(fg) startupFile
option add *Text.background $editor(bg) startupFile
option add *Tree.background $editor(bg) startupFile
option add *Tree.foreground $editor(fg) startupFile
option add *scrollbar.background $editor(bg) startupFile
option add *Canvas.background $editor(bg) startupFile
option add *Canvas.foreground $editor(fg) startupFile
option add *Node.foreground $editor(fg) startupFile
option add *NoteBook.bg $editor(bg) startupFile
option add *NoteBook.fg $editor(fg) startupFile
option add *Listbox.foreground $editor(fg) startupFile
option add *Listbox.background $editor(bg) startupFile
option add *Scrollbar.background $editor(bg) startupFile





