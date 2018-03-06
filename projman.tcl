#!/bin/sh
# Tcl ignores the next line -*- tcl -*- \
exec wish "$0" -- "$@"

###############################################
#        Tcl/Tk Project Manager               #
#         Distrubuted under GPL               #
# Copyright (c) "Sergey Kalinin", 2001,       #
# Home: http://nuk-svk.ru                     #
# Author: Sergey Kalinin banzaj28@yandex.ru   #
###############################################

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
set dataDir "[file join $rootDir lib]"
set docDir "[file join $rootDir hlp ru]"
set imgDir "[file join $rootDir img]"
set msgDir "[file join $rootDir msgs]"
set binDir $rootDir
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

#source [file join $workDir projman.conf]
# Read the projman.conf file and setting the variable
set config [open [file join $workDir projman.conf] RDONLY]
while {[gets $config line]>=0} {
    if [regexp -nocase -all -line -- {(set)\s(.+)\s"(.+|)"} $line match op var data] {
        regsub -all -- {\$env\(HOME\)} $data "$env(HOME)" data
        regsub -all -- {\$workDir} $data "$workDir" data
        set $var $data
    }
}



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
option add *Frame.Background $editor(bg) interactive
option add *ScrollableFrame.Background $editor(bg) interactive
option add *ScrolledWindow.Background $editor(bg) interactive
option add *Button.Foreground $editor(fg) interactive
option add *Button.Background $editor(bg) interactive
option add *Button.activeBackground $editor(bg) userDefault
option add *Button.activeForeground $editor(fg) userDefault

option add *Entry.Foreground $editor(fg) interactive
option add *Entry.Background $editor(bg) interactive
option add *Label.Foreground $editor(fg) interactive
option add *Label.Background $editor(bg) interactive
option add *Checkbox.Foreground $editor(fg) interactive
option add *Checkbox.Background $editor(bg) interactive
option add *Checkbutton.Foreground $editor(fg) interactive
option add *Checkbutton.Background $editor(bg) interactive
option add *Combobox.Foreground $editor(fg) interactive
option add *Combobox.Background $editor(bg) interactive
option add *Text.Foreground $editor(fg) interactive
option add *Text.Background $editor(bg) interactive
option add *Tree.Background $editor(bg) interactive
option add *Tree.Foreground $editor(fg) interactive
option add *Scrollbar.Background $editor(bg) interactive
option add *Canvas.Background $editor(bg) interactive
option add *Canvas.Foreground $editor(fg) interactive
option add *Node.Foreground $editor(fg) interactive
option add *NoteBook.bg $editor(bg) interactive
option add *NoteBook.fg $editor(fg) interactive
option add *Listbox.Foreground $editor(fg) interactive
option add *Listbox.Background $editor(bg) interactive

#option add *Button.font $guifont userDefault
#option add *Label.font $guifont userDefault
#option add *Menu.font $guifont userDefault
#option add *Menubutton.font $guifont userDefault
option add *Dialog.msg.background $editor(bg)

  #   option add *Text.Background $textbg userDefault
#   option add *Entry.Background $textbg userDefault
#   option add *Text.Foreground $textfg userDefault
#   option add *Entry.Foreground $textfg userDefault
#   option add *Button.activeBackground $bg userDefault
#   option add *Button.activeForeground $fg userDefault
#   option add *Scrollbar.activeBackground $bg userDefault
#   option add *Scrollbar.troughColor $shadow userDefault
#   option add *Canvas.Background $shadow userDefault
# 
#   # These menu configs work if you use native menus.
#   option add *Menu.borderWidth 1 userDefault
#   option add *Menu.activeForeground $fg userDefault
#   option add *Menubutton.activeForeground $fg userDefault
# 
#   # This draws a thin border around buttons
#   #option add *highlightBackground $bg userDefault
#   # Suppress the border
#   option add *HighlightThickness 0 userDefault
#   # Add it back for text and entry widgets
#   option add *Text.highlightBackground $bg userDefault
#   option add *Entry.highlightBackground $bg userDefault
#   option add *Text.HighlightThickness 2 userDefault
#   option add *Entry.HighlightThickness 1 userDefault
