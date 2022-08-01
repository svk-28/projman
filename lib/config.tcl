######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
# The config file procedures
# create
# copy
# save
######################################################

namespace eval Config {} {
    variable cfgINISections
    variable cfgVariables
}

if [info exists env(LANG)] {
    set locale $env(LANG)
} else {
    set locale "en"
}

set ::configDefault "\[General\]
locale=$locale
cfgModifyDate=''
\[GUI\]
theme=dark
toolBarShow=true
menuShow=true
filesPanelShow=true
geometry=1024x768
guiFont={Droid Sans Mono} 9
guiFontBold={Droid Sans Mono} 9 bold
guiFG=#cccccc
\[Editor\]
autoFormat=true
font=courier 10 normal roman
fontBold=courier 10 bold roman
backGround=#333333
foreground=#cccccc
selectbg=#10a410a410a4
nbNormal=#000000
nbModify=#ffff5d705d70
lineNumberFG=#a9a9a9
selectBorder=0
# must be: none, word or char
editorWrap=word
lineNumberShow=true
tabSize=4
"
proc Config::create {dir} {
    set cfgFile [open [file join $dir projman.ini]  "w+"]
    puts $cfgFile $::configDefault        
    close $cfgFile
}

proc Config::read {dir} {
    set cfgFile [ini::open [file join $dir projman.ini] "r"]
    foreach section [ini::sections $cfgFile] {
        foreach key [ini::keys $cfgFile $section] {
            lappend ::cfgINIsections($section)  $key
            set ::cfgVariables($key)  [ini::value $cfgFile $section $key]
        }
    }
    ini::close $cfgFile
}

proc Config::write {dir} {
    set cfgFile [ini::open [file join $dir projman.ini] "w"]
    foreach section  [array names ::cfgINIsections] {
        foreach key $::cfgINIsections($section) {
            ini::set $cfgFile $section $key $::cfgVariables($key)
        }
    }
    set systemTime [clock seconds]
    # Set a config modify time (i don't know why =))'
    ini::set $cfgFile "General" cfgModifyDate [clock format $systemTime -format "%D %H:%M:%S"]
  
    # Save an top level window geometry into config
    ini::set $cfgFile "GUI" geometry [wm geometry .]
    
    ini::commit $cfgFile
    ini::close $cfgFile
}
