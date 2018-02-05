#!/usr/bin/wish

###########################################################
#                Tcl/Tk Project Manager                   #
#                  install script                         #
# Copyright (c) "Sergey Kalinin", 2001, http://nuk-svk.ru  #
# Author: Sergey Kalinin banzaj28@yandex.ru       #
###########################################################

## SETTING VARIABLES AND DIRECTORYES ##
set ver "0.4.5"
set imgDir img
set msgDir msgs
set docDir hlp
set hlDir highlight
set fontNormal "helvetica 12 normal roman"
package require msgcat
package require BWidget



::msgcat::mclocale en
::msgcat::mcload msgs

if {$tcl_platform(platform) == "unix"} {
    set initDir "$env(HOME)"
    set rootDir "/usr/local"
    set tmpDir "$env(HOME)/tmp"
    set tclDir "/usr/bin"
} elseif {$tcl_platform(platform) == "windows"} {
    set initDir "c:\\"
    set rootDir "c:\\Tcl"
    set tmpDir "c:\\temp"
    set tclDir "C:\\Tcl\\bin"
}

proc InsertEnt {entry text} {
    $entry delete 0 end
    $entry insert end $text
}
proc SelectDir {dir} {
    set dirName [tk_chooseDirectory -initialdir $dir\
    -title "[::msgcat::mc "Select directory"]"\
        -parent .]
    return $dirName
}
## GET HELP DIRECTORYES ##
proc GetHelp {} {
    global docDir localeList
    set localeList ""
    if {[catch {cd $docDir}] != 0} {
        return ""
    }
    foreach file [lsort [glob -nocomplain *]] {
        if {[file isdirectory $file] == 1 && $file != "CVS"} {
            lappend localeList [list [file rootname $file]]
        }
    }
    catch {cd ..}
    return $localeList
}

proc GetLocale {} {
    global msgDir locList
    set locList ""
    if {[catch {cd $msgDir}] != 0} {
        return ""
    }
    foreach file [lsort [glob -nocomplain *.msg]] {
        puts $file
        if {[file isdirectory $file] == 0} {
            puts [file rootname $file]
            lappend locList [list [file rootname $file]]
        }
    }
    catch {cd ..}
    return $locList
}

set w .
wm title $w "Install Tcl/Tk Project Manager"
#wm resizable $w 0 0
#wm geometry $w 400x350
set top [frame .frmTop -relief groove -borderwidth 1 -background white]
pack $top -fill x

image create photo imgAbout -format gif -file [file join img projman.gif]
label $top.lblImg -image imgAbout -background white
pack $top.lblImg -side top -pady 5 -padx 5

set frm [frame .frmMain -relief groove -borderwidth 1]
pack $frm -expand 1 -fill both
 
set btn [frame .frmButton -relief groove -borderwidth 1]
pack $btn -fill x

image create photo imgFold -format gif -file [file join img folder.gif]

set frm1 [frame $frm.frmRootDir]
pack $frm1 -fill x -pady 2
label $frm1.lblRootDir -text "Install dir" -width 23 -anchor w
entry $frm1.txtRootDir
button $frm1.btnRootDir -borderwidth {1} -image imgFold\
-command {
    $frm1.txtRootDir delete 0 end
    $frm1.txtRootDir insert end [SelectDir $initDir]
}
pack $frm1.lblRootDir -side left
pack $frm1.txtRootDir -side left -fill x -expand true

pack $frm1.btnRootDir -side left
set frm4 [frame $frm.frmTclDir]
pack $frm4 -fill x -pady 2
label $frm4.lblTclDir -text "Tcl bin dir" -width 23 -anchor w
entry $frm4.txtTclDir
button $frm4.btnTclDir -borderwidth {1} -image imgFold\
        -command {
    $frm4.txtTclDir delete 0 end
    $frm4.txtTclDir insert end [SelectDir $initDir]
}
pack $frm4.lblTclDir -side left
pack $frm4.txtTclDir -side left -fill x -expand true
pack $frm4.btnTclDir -side left

set frm6 [frame $frm.frmDocLang]
pack $frm6 -fill x -pady 2
label $frm6.lblLang -text [::msgcat::mc "Documentation language"]\
-width 23 -anchor w
set combo [ComboBox $frm6.txtLang\
-textvariable langDoc -command "puts 123"\
-selectbackground "#55c4d1" -selectborderwidth 0\
-values [GetHelp]]
pack $frm6.lblLang -side left
pack $frm6.txtLang -side left -fill x -expand true

set frm7 [frame $frm.frmLocale]
pack $frm7 -fill x -pady 2
label $frm7.lblLocale -text [::msgcat::mc "Interface language"]\
-width 23 -anchor w
set comboLocale [ComboBox $frm7.txtLocale\
-textvariable localeSet -command "puts 123"\
-selectbackground "#55c4d1" -selectborderwidth 0\
-values [GetLocale]]
pack $frm7.lblLocale -side left
pack $frm7.txtLocale -side left -fill x -expand true


button $btn.btnOk -text "Next" -width 10 -borderwidth {1}\
-command {
    CopyFiles [$frm1.txtRootDir get] [$frm4.txtTclDir get] $langDoc $localeSet
}
button $btn.btnCancel -text "Exit" -width 10 -borderwidth {1}\
-command {exit}

pack $btn.btnOk $btn.btnCancel -side left -padx 2 -pady 2 -expand 1

bind $w <Escape> "exit"

InsertEnt $frm1.txtRootDir $rootDir
InsertEnt $frm4.txtTclDir $tclDir
$combo setvalue @0
$comboLocale setvalue @0

proc CopyFiles {rootDir tclDir langDoc locale} {
    global ver tcl_platform binDir hlDir
    set exeName projman
    set modules {
        editor.tcl        help.tcl        html_lib.tcl        procedure.tcl
        main.tcl        settings.tcl        projects.tcl        imgviewer.tcl
        baloon.tcl        completition.tcl taglist.tcl        supertext.tcl
        pane.tcl highlight/html.tcl highlight/spec.tcl highlight/tcl.tcl highlight/tex.tcl
        highlight/caml.tcl        highlight/fortran.tcl        highlight/java.tcl
        highlight/perl.tcl        highlight/php.tcl        highlight/rivet.tcl highlight/ruby.tcl
    }
    set docFiles {TODO README INSTALL CHANGELOG COPYING THANKS}
    set confFiles {projman.spec projman.conf}
    
    if {[string length [string trim $rootDir]]} {
        regsub -all {\\} $rootDir {\\\\} rootDir_
        set rootDir $rootDir_
    }
    if {[string length [string trim $tclDir]]} {
        regsub -all {\\} $tclDir {\\\\} tclDir_
        set tclDir $tclDir_
    }
    destroy .frmMain.frmRootDir
    destroy .frmMain.frmTclDir
    destroy .frmMain.frmLocale
    destroy .frmMain.frmDocLang
    set frm ".frmMain"
    pack $frm -expand 1 -fill both
    set text [text $frm.text -yscrollcommand "$frm.yscroll set" \
    -relief sunken -wrap word -highlightthickness 0\
    -selectborderwidth 0 -selectbackground #55c4d1 -height 15 -width 30]
    scrollbar $frm.yscroll -relief sunken -borderwidth {1} -width {10} -takefocus 0 \
    -command "$frm.text yview"
    pack $frm.text -side left -fill both -expand true
    pack $frm.yscroll -side left -fill y
    
    $text insert end "Root dir - $rootDir\nTcl dir - $tclDir"
    $text insert end "\n-- Copying files --\n"
    
    set binDir  [file join $rootDir bin             ]
    set dataDir [file join $rootDir share projman   ]
    set docDir  [file join $rootDir share doc projman-$ver]
    set imgDir  [file join $dataDir img             ]
    set msgDir  [file join $dataDir msgs            ]
    set hlDir  [file join $dataDir highlight        ]
    
    ## CREATE DIRECTORYES ##
    if {[file exists $rootDir] != 1} {file mkdir $rootDir}
    if {[file exists $binDir ] != 1} {file mkdir $binDir }
    if {[file exists $dataDir] != 1} {file mkdir $dataDir}
    if {[file exists $docDir ] != 1} {file mkdir $docDir }
    if {[file exists $imgDir ] != 1} {file mkdir $imgDir }
    if {[file exists $msgDir ] != 1} {file mkdir $msgDir }
    if {[file exists $hlDir ] != 1} {file mkdir $hlDir }
    
    ## CREATE EXECUTION FILE ##
    puts [pwd]
    set source [open "projman.tcl" "r"]
    set exe [open [file join $binDir $exeName] "w"]
    while {[gets $source line]>=0} {
        if {[string match "set rootDir \"/usr\"" [string trim $line]] == 1} {
            puts $exe "set rootDir \"$rootDir_\""
        } elseif {[string match "set tclDir \"/usr/bin\"" [string trim $line]] == 1} {
            puts $exe "set tclDir \"$tclDir_\""
        } else {
            puts $exe $line
        }
    }
    close $source
    close $exe
    
    ## SET PERMISSIONS ON FILE FOR UNIX OR CREATE start.bat FILE FOR WINDOWS ##
    if {$tcl_platform(platform) == "unix"} {
        file attributes [file join $binDir $exeName] -permissions 00755
    } elseif {$tcl_platform(platform) == "windows"} {
        set bat [open [file join $binDir projman.bat] "w"]
        set progPath "[file join $binDir $exeName.tcl]"
        file rename -force [file join $binDir $exeName] $progPath
        regsub -all {/} $progPath "\\" progPath
        set tclPath "[file join $tclDir wish.exe]"
        regsub -all {/} $tclPath "\\" tclPath
        puts $bat "\"$tclPath\" \"$progPath\""
        close $bat
    }
    ## COPYING MODULES FILES (*.tcl) ##
    foreach file $modules {
        lappend rList [list [file join . $file]]
        set fileName [file join $file]
        $text insert end "$fileName\n"
        $text mark set insert end
        $text see insert
        file copy -force -- $fileName [file join $dataDir $fileName]
    }
    
    ## COPYING CONFIG FILE ##
    foreach fileName $confFiles {
        $text insert end "$fileName\n"
        $text mark set insert end
        $text see insert
        file copy -force -- $fileName [file join $dataDir $fileName]
    }
    ## COPYING DOCUMENTATION (HELP) FILES ##
    foreach fileName $docFiles {
        $text insert end "$fileName\n"
        $text mark set insert end
        $text see insert
        file copy -force -- $fileName [file join $docDir $fileName]
    }
    if {$locale == ""} {
        set locale "en"
    }
    if {$langDoc == ""} {
        set langDoc "en"
    }
    puts "Locale - $locale LangDoc - $langDoc"
    if {[catch {cd [file join hlp $langDoc]}] != 0} {
        return ""
    }
    foreach dir [lsort [glob -nocomplain *]] {
        if {[file isdirectory $dir] == 1 && $dir != "CVS"} {
            if {[file exists [file join $docDir $dir]] != 1} {
                file mkdir [file join $docDir $dir]
                #puts [file join $docDir $dir]
            }
            foreach file [lsort [glob -nocomplain [file join $dir *.*]]] {
                #puts $file
                lappend rList [list [file join . $file]]
                set fileName [file join $file]
                $text insert end "$fileName\n"
                $text mark set insert end
                $text see insert
                file copy -force -- $fileName [file join $docDir $fileName]
            }
        }
    }
    ## COPYING IMAGE FILES ##
    if {[catch {cd [file join .. .. img]}] != 0} {
        return ""
    }
    foreach file [lsort [glob -nocomplain *.gif]] {
        lappend rList [list [file join . $file]]
        set fileName [file join $file]
        $text insert end "$fileName\n"
        $text mark set insert end
        $text see insert
        file copy -force -- $fileName [file join $imgDir $fileName]
    }
    foreach file [lsort [glob -nocomplain *.png]] {
        lappend rList [list [file join . $file]]
        set fileName [file join $file]
        $text insert end "$fileName\n"
        $text mark set insert end
        $text see insert
        file copy -force -- $fileName [file join $imgDir $fileName]
    }
    ## COPYING MESSAGES FILES ##
    if {[catch {cd [file join .. msgs]}] != 0} {
        return ""
    }
    foreach file [lsort [glob -nocomplain *.msg]] {
        lappend rList [list [file join . $file]]
        set fileName [file join $file]
        $text insert end "$fileName\n"
        $text mark set insert end
        $text see insert
        file copy -force -- $fileName [file join $msgDir $fileName]
    }
    ## COPYING HIGHLIGHT FILES ##
    if {[catch {cd [file join .. highlight]}] != 0} {
        return ""
    }
    foreach file [lsort [glob -nocomplain *.tcl]] {
        lappend rList [list [file join . $file]]
        set fileName [file join $file]
        $text insert end "$fileName\n"
        $text mark set insert end
        $text see insert
        file copy -force -- $fileName [file join $hlDir $fileName]
    }
    $text insert end "-- Copying file complite --"
    $text mark set insert end
    $text see insert
    destroy .frmButton.btnOk 
    .frmButton.btnCancel configure -text "Finish" -command {exit}
    
    SetVarLang $locale
}


#Michel SALVAGNIAC 7 avril 2002
#positionne la variable d'environnement LANG
#n?cessaire pour msgcat
#version de tcl/tk :8.3
#test? avec Windows 95,Windows NT4,Windows 2000, Windows XP pro

proc SetVarLang {lang} {
    global tcl_platform rootDir
    set language $lang
    if {$tcl_platform(platform) == "windows"} {
        #Windows NT,2000,XP PRO
        if {$tcl_platform(os) == "Windows NT"} {
            package require registry
            tk_messageBox -type ok -icon warning \
            -message "Modifying the Registry..."
            set clebase "HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\Environment"
            registry set $clebase LANG $language sz
            #Windows 95
        } elseif {$tcl_platform(os) == "Windows 95"} {
            tk_messageBox -type ok -icon warning \
            -message "Modifying the C:\\Autoexec.bat"
            file copy -force c:/Autoexec.bat c:/autoexec.sav
            set ficsys [open "c:/autoexec.bat" a+]
            puts  $ficsys "SET LANG=$language "
            puts  $ficsys "SET HOMEDRIVE=C:\\"
            set workDir [file join $rootDir work]
            regsub -all {/} $workDir {\\} home
            puts  $ficsys "SET HOMEPATH=$home"
            close $ficsys
        }
    }
}
















