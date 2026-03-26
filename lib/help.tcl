######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022-2026, https://nuk-svk.ru
######################################################
# 
# Projman Help dialog
# 
######################################################


proc ShowHelpDialog {} {
    ShowMD [HelpFileLocation README.md]
}

proc HelpFileLocation {fileName} {
    global dir
    if [file exists [file join $dir(lib) $fileName]] {
        return [file join $dir(lib) fileName]
    } elseif [file exists [file join /usr/share/doc/projman $fileName]] {
        return [file join /usr/share/doc/projman $fileName]
    } else {
        return [file join [pwd] $fileName]
    }
    
}
