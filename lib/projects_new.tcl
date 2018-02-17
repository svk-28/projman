#######################################
#                Tcl/Tk Project Manager
#        Distributed under GNU Public License
# Author: Serge Kalinin banzaj28@yandex.ru
# Copyright (c) "https://nuk-svk.ru", 2018, 
# Home: https://bitbucket.org/svk28/projman
#######################################


proc NewProj {type proj l} {
    global  fontNormal fontBold tree projDir workDir activeProject fileList noteBook imgDir prjDir
    global openProjDir tclDir frm lang operType
    set operType $type
    if {$operType == "edit" && $proj == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning -title [::msgcat::mc "Warning"]]
        case $answer {
            ok {return 0}
        }
    }
    set typeProjects "Tcl Tcl/Tk Java Perl Fortran O'Caml PHP Ruby Erlang"
    
    set node [$noteBook page [$noteBook index newproj]]
    if {$node != ""} {
        $noteBook raise newproj
        return 0
    } else {
        set w [$noteBook insert end newproj -text [::msgcat::mc "New project"]]
    }
    set frm [frame $w.frmProjSettings]
    pack $frm -fill both -expand true
    
    image create photo imgFold -format gif -file [file join $imgDir folder.gif]
    variable frm_1
    set frm_1 [frame $frm.frmProjName]
    label $frm_1.lblProjName -text [::msgcat::mc "Project name"] -width 20 -anchor w
    entry $frm_1.txtProjName -textvariable txtProjName -bd 0 -relief flat
    pack $frm_1.lblProjName -side left 
    pack $frm_1.txtProjName -side left -fill x -expand true
    
    ###
    set frm_lang [frame $frm.frmLanguage]
    set lang "Tcl"
    label $frm_lang.lblLanguage -text [::msgcat::mc "Project type"] -width 20 -anchor w
    set combo [
        ComboBox $frm_lang.txtLocale \
        -textvariable lang -editable false \
        -autocomplete true -autopost true \
        -selectbackground "#55c4d1" -selectborderwidth 0 \
        -values $typeProjects
    ]
    #$combo setvalues $lang
    pack  $frm_lang.lblLanguage -side left
    pack $combo -fill x -expand true 
    bind $combo <ButtonRelease-1> { append txtFileName ".[GetExtentionProj $lang]"}
    ### 
    
    set frm_2 [frame $frm.frmFileName]
    label $frm_2.lblFileName -text [::msgcat::mc "Project file"] -width 20 -anchor w
    entry $frm_2.txtFileName -textvariable txtFileName -bd 0 -relief flat
    pack  $frm_2.lblFileName -side left 
    pack $frm_2.txtFileName -side left -fill x -expand true
    bind $frm_2.txtFileName <FocusIn> {
        append txtFileName ".[GetExtentionProj $lang]"
    }
    #$frm_2.txtFileName insert end $txtProjName
    
    set frm_8 [frame $frm.frmDirName]
    label $frm_8.lblDirName -text [::msgcat::mc "Project dir"] -width 20 -anchor w
    entry $frm_8.txtDirName -textvariable txtDirName 
    button $frm_8.btnDirName -image imgFold -relief flat \
    -command {
        $frm.frmDirName.txtDirName configure -state normal
        InsertEnt $frm.frmDirName.txtDirName [tk_chooseDirectory -initialdir $projDir -title "[::msgcat::mc "Select directory"]" -parent .]
        $frm.frmDirName.txtDirName configure -state disable    
    }
    pack  $frm_8.lblDirName -side left 
    pack $frm_8.txtDirName -side left -fill x -expand true 
    pack  $frm_8.btnDirName -side left 
    bind $frm_8.txtDirName <FocusIn> {
        
    }
    
    set frm_13 [frame $frm.frmCompiler]
    label $frm_13.lblCompiler -text [::msgcat::mc "Compiler"]\
    -width 20 -anchor w
    entry $frm_13.txtCompiler -textvariable txtCompiler
    button $frm_13.btnCompiler  -image imgFold -relief flat\
    -command {
        InsertEnt $frm.frmCompiler.txtCompiler [tk_getOpenFile -initialdir $tclDir -parent .]
    }
    pack $frm_13.lblCompiler -side left
    pack $frm_13.txtCompiler -side left -fill x -expand true 
    pack  $frm_13.btnCompiler -side left
    
    set txtProjInterp [GetInterp $lang]
    set frm_12 [frame $frm.frmProjInterp]
    label $frm_12.lblProjInterp -text [::msgcat::mc "Interpetator"]\
    -width 20 -anchor w
    entry $frm_12.txtProjInterp -textvariable txtProjInterp
    button $frm_12.btnInterp  -image imgFold -relief flat\
    -command {
        InsertEnt $frm.frmProjInterp.txtProjInterp [tk_getOpenFile -initialdir $tclDir -parent .]
    }
    pack $frm_12.lblProjInterp -side left
    pack $frm_12.txtProjInterp -side left -fill x -expand true
    pack  $frm_12.btnInterp -side left 
    bind $frm_12.txtProjInterp <FocusIn> {
        set txtProjInterp [GetInterp $lang]
    }
    
    set frm_4 [frame $frm.frmVersion]
    label $frm_4.lblProjVersion -text [::msgcat::mc "Version"] -width 20 -anchor w
    entry $frm_4.txtProjVersion -textvariable txtProjVersion -bd 0 -relief flat
    pack $frm_4.lblProjVersion -side left
    pack $frm_4.txtProjVersion -side left -fill x -expand true 
    InsertEnt $frm_4.txtProjVersion "0.0.1"
    
    set frm_11 [frame $frm.frmRelease]
    label $frm_11.lblProjRelease -text [::msgcat::mc "Release"] -width 20 -anchor w
    entry $frm_11.txtProjRelease -textvariable txtProjRelease -bd 0 -relief flat
    pack $frm_11.lblProjRelease -side left 
    pack $frm_11.txtProjRelease -side left -fill x -expand true 
    InsertEnt $frm_11.txtProjRelease "1"
    
    set frm_3 [frame $frm.frmProjAuthor]
    label $frm_3.lblProjAuthor -text [::msgcat::mc "Author"] -width 20 -anchor w
    entry $frm_3.txtProjAuthor -textvariable txtProjAuthor -bd 0 -relief flat
    pack  $frm_3.lblProjAuthor -side left
    pack $frm_3.txtProjAuthor -side left -fill x -expand true
    
    set frm_9 [frame $frm.frmProjEmail]
    label $frm_9.lblProjEmail -text [::msgcat::mc "E-mail"] -width 20 -anchor w
    entry $frm_9.txtProjEmail -textvariable txtProjEmail -bd 0 -relief flat
    pack  $frm_9.lblProjEmail -side left
    pack $frm_9.txtProjEmail -side left -fill x -expand true
    
    set frm_5 [frame $frm.frmProjCompany]
    label $frm_5.lblProjCompany -text [::msgcat::mc "Company"] -width 20 -anchor w
    entry $frm_5.txtProjCompany -textvariable txtProjCompany -bd 0 -relief flat
    pack $frm_5.lblProjCompany -side left
    pack $frm_5.txtProjCompany -side left -fill x -expand true
    
    set frm_10 [frame $frm.frmProjHome]
    label $frm_10.lblProjHome -text [::msgcat::mc "Home page"] -width 20 -anchor w
    entry $frm_10.txtProjHome -textvariable txtProjHome
    pack $frm_10.lblProjHome -side left 
    pack $frm_10.txtProjHome -side left -fill x -expand true 
    
    set frm_7 [frame $frm.frmWinTitle ]
    label $frm_7.lblWinTitle -text [::msgcat::mc "Create new project"] -height 2 -font $fontBold
    
    
    pack $frm_7.lblWinTitle -fill x -expand true
    
    set frm_6 [frame $frm.frmBtn ]
    if {$operType == "edit" && $proj != ""} {
        $noteBook itemconfigure newproj -text [::msgcat::mc "Project settings"]
        button $frm_6.btnProjCreate -text [::msgcat::mc "Save"] -relief flat \
        -font $fontNormal -command {
            regsub -all {\\} $txtProjInterp {\\\\} $txtProjInterp
            SaveProj "$txtFileName" "$lang" "$txtProjName" "$txtFileName" "$txtDirName"\
            "$txtCompiler" "$txtProjInterp" "$txtProjVersion" "$txtProjRelease"\
            "$txtProjAuthor" "$txtProjEmail" "$txtProjCompany" "$txtProjHome"
            $noteBook delete newproj
            $noteBook raise [$noteBook page end]
        }
    } else {
        button $frm_6.btnProjCreate -text [::msgcat::mc "Create"] -relief flat \
        -font $fontNormal -command {
            CreateProj "$operType" "$lang" "$txtFileName" "$txtProjName" "$txtFileName" "$txtDirName"\
            "$txtCompiler" "$txtProjInterp" "$txtProjVersion" "$txtProjRelease"\
            "$txtProjAuthor" "$txtProjEmail" "$txtProjCompany" "$txtProjHome"
            $noteBook delete newproj
            $noteBook raise [$noteBook page end]
        }
        
    }
    button $frm_6.btnClose -text [::msgcat::mc "Cancel"] -relief flat  -font $fontNormal -command {
        $noteBook delete newproj
        $noteBook raise [$noteBook page end]
    }
    pack $frm_6.btnProjCreate $frm_6.btnClose -padx 10 -pady 20 -side right
    pack  $frm_7 $frm_1 $frm_lang $frm_2 $frm_8 $frm_13 $frm_12 $frm_4 $frm_11 $frm_3 $frm_9 $frm_5 $frm_10 $frm_6\
    -side top -fill x -padx 10 -pady 5
    pack $frm_6 -side top -fill x -expand true -anchor n
    bind $w <Escape>  "$noteBook delete newproj"
    $noteBook raise newproj
    
    ## EDIT PROJECT SETTINGS ##
    if {$operType == "edit" && $proj != ""} {
        $frm.frmDirName.txtDirName configure -state normal
        $frm_7.lblWinTitle configure -text [::msgcat::mc "Project settings"]
        $frm_6.btnProjCreate configure -text "[::msgcat::mc "Save"]"
        set file [open [file join $workDir $proj.proj] r]
        while {[gets $file line]>=0} {
            scan $line "%s" keyWord
            set string [string range $line [string first "\"" $line] [string last "\"" $line]]
            set string [string trim $string "\""]
            #                regsub -all " " $string "_" project
            puts $string
            switch $keyWord {
                ProjectName {InsertEnt $frm_1.txtProjName "$string"}
                ProjectFileName {InsertEnt $frm_2.txtFileName "$string"}
                ProjectLanguage {set lang "$string"}
                ProjectDirName {InsertEnt $frm_8.txtDirName "$string"}  
                ProjectCompiler {InsertEnt $frm_13.txtCompiler "$string"}  
                ProjectInterp {InsertEnt $frm_12.txtProjInterp "$string"}  
                ProjectVersion {InsertEnt $frm_4.txtProjVersion "$string"}  
                ProjectRelease {InsertEnt $frm_11.txtProjRelease "$string"}  
                ProjectAuthor {InsertEnt $frm_3.txtProjAuthor "$string"}  
                ProjectEmail {InsertEnt $frm_9.txtProjEmail "$string"}  
                ProjectCompany {InsertEnt $frm_5.txtProjCompany "$string"}  
                ProjectHome {InsertEnt $frm_10.txtProjHome "$string"}  
            }
        }
        close $file
    } elseif {$operType == "open"} {
        $frm_7.lblWinTitle configure -text [::msgcat::mc "Open project"]
        InsertEnt $frm_1.txtProjName "$proj"
        InsertEnt $frm_2.txtFileName "$proj"
        #$combo setvalue $lang
        InsertEnt $frm_8.txtDirName "$proj"
        $frm_8.txtDirName configure -state normal
        puts $prjDir
        InsertEnt $frm_8.txtDirName "$prjDir"
        InsertEnt $frm_13.txtCompiler ""
        InsertEnt $frm_12.txtProjInterp ""
        InsertEnt $frm_4.txtProjVersion "0.0.1"
        InsertEnt $frm_11.txtProjRelease "1"
        InsertEnt $frm_3.txtProjAuthor ""
        InsertEnt $frm_9.txtProjEmail ""
        InsertEnt $frm_5.txtProjCompany ""
        InsertEnt $frm_10.txtProjHome ""
    } else {
        InsertEnt $frm_1.txtProjName ""
        InsertEnt $frm_2.txtFileName ""
        InsertEnt $frm_8.txtDirName ""
        InsertEnt $frm_13.txtCompiler ""
        InsertEnt $frm_12.txtProjInterp ""
        InsertEnt $frm_4.txtProjVersion "0.0.1"
        InsertEnt $frm_11.txtProjRelease "1"
        InsertEnt $frm_3.txtProjAuthor ""
        InsertEnt $frm_9.txtProjEmail ""
        InsertEnt $frm_5.txtProjCompany ""
        InsertEnt $frm_10.txtProjHome ""
    }
    # bind autocomlite dir only if new project
    if {[$frm_8.txtDirName get ] eq ""} {
        bind  $frm_1.txtProjName <KeyRelease> {
            regsub -all -- {\s} [string tolower [Translit [$frm_1.txtProjName get]]] "_" txtFileName
            set txtDirName [file join $projDir $txtFileName]
        }
    }
    
}

proc GetExtentionProj {lang} {
    if {$lang=="Tcl"  || $lang=="Tcl/Tk"} {
        set ext "tcl"
    } elseif {$lang == "Perl"} {
        set ext pl
    } elseif {$lang=="Java"} {
        set ext "java"
    } elseif {$lang=="Fortran"} {
        set ext "for"
    } elseif {$lang=="O'Caml"} {
        set ext ml            
    } elseif {$lang=="Ruby"} {
        set ext rb
    } elseif {$lang=="PHP"} {
        set ext php
    } elseif {$lang=="Erlang"} {
        set ext erl          
    }
    return $ext    
}
proc GetInterp {lang} {
    global tcl_platform
    if {$tcl_platform(platform) == "unix"} {
        set interp [GetInterp_unix $lang]
    } elseif {$tcl_platform(platform) == "windows"} {
        set interp [GetInterp_windows $lang]
    }  else {
        set interp ""
    }
    return $interp
}

proc GetInterp_unix {lang} {
    set searchCommand "which"
    switch $lang {
        Tcl {set interp "tclsh"}
        Tcl/Tk {set interp "wish"}
        Perl {set interp "perl"}
        Java {set interp "java"}
        Fortran {set interp ""}
        O'Caml {set interp ""}
        Ruby {set interp "ruby"}
        PHP {set interp "php"}
        Perl {set interp "perl"}
        Erlang {set interp ""}
    }
    try {
        set result [exec $searchCommand $interp]
    } trap {} {} {
        puts "Error: don't find interp for $lang"
        set result ""
    }
    return $result
}
proc GetInterp_windows {lang} {
    set searchCommand "where"
    switch $lang {
        Tcl {set interp "tclsh"}
        Tcl/Tk {set interp "wish"}
        Perl {set interp "perl"}
        Java {set interp "java"}
        Fortran {set interp ""}
        O'Caml {set interp ""}
        Ruby {set interp "ruby"}
        PHP {set interp "php"}
        Perl {set interp "perl"}
        Erlang {set interp ""}
    } 
    try {
        set result [exec $searchCommand $interp]
    } trap {} {} {
        puts "Error: don't find interp for $lang"
        set result ""
    }
    return $result
}

proc SaveProj {txtFileName lang txtProjName txtFileName txtDirName \
txtCompiler txtProjInterp txtProjVersion txtProjRelease txtProjAuthor \
txtProjEmail txtProjCompany txtProjHome} {
    global projDir workDir dataDir
    
    set file [file tail $txtDirName]
    set projFile [open [file join $workDir $file.proj] w]
    puts $projFile "ProjectName \"$txtProjName\""
    puts $projFile "ProjectLanguage \"$lang\""
    puts $projFile "ProjectFileName \"$txtFileName\""
    puts $projFile "ProjectDirName \"$txtDirName\""
    puts $projFile "ProjectCompiler  \"$txtCompiler\""
    puts $projFile "ProjectInterp  \"$txtProjInterp\""
    puts $projFile "ProjectVersion  \"$txtProjVersion\""
    puts $projFile "ProjectRelease  \"$txtProjRelease\""
    puts $projFile "ProjectAuthor \"$txtProjAuthor\""
    puts $projFile "ProjectEmail \"$txtProjEmail\""
    puts $projFile "ProjectCompany \"$txtProjCompany\""
    puts $projFile "ProjectHome \"$txtProjHome\""
    close $projFile
}    


## CREATING PROJECT PROCEDURE ##
proc CreateProj {type lang txtFileName txtProjName txtFileName txtDirName \
txtCompiler txtProjInterp txtProjVersion  txtProjRelease txtProjAuthor txtProjEmail \
txtProjCompany txtProjHome} {
    global projDir workDir tree fontNormal dataDir tcl_platform
    puts "$type $lang";# "$txtFileName" "$txtProjName" "$txtFileName" "$txtDirName"\
    #    "$txtCompiler" "$txtProjInterp" "$txtProjVersion" "$txtProjRelease"\
    #    "$txtProjAuthor" "$txtProjEmail" "$txtProjCompany" "$txtProjHome"
    ## SAVING PROJECT SETTINGS ##
    set projShortName [file tail $txtDirName]
    
    set projFile [open [file join $workDir $projShortName.proj] w]
    
    puts $projFile "ProjectName \"$txtProjName\""
    puts $projFile "ProjectLanguage \"$lang\""
    puts $projFile "ProjectFileName \"$txtFileName\""
    puts $projFile "ProjectDirName \"$txtDirName\""
    puts $projFile "ProjectCompiler  \"$txtCompiler\""
    puts $projFile "ProjectInterp  \"$txtProjInterp\""
    puts $projFile "ProjectVersion  \"$txtProjVersion\""
    puts $projFile "ProjectRelease  \"$txtProjRelease\""
    puts $projFile "ProjectAuthor \"$txtProjAuthor\""
    puts $projFile "ProjectEmail \"$txtProjEmail\""
    puts $projFile "ProjectCompany \"$txtProjCompany\""
    puts $projFile "ProjectHome \"$txtProjHome\""
    close $projFile
    if {$type != "open"} {
        set dir [file join $projDir $txtDirName]
        if {[file exists "$dir"] != 1} {
            file mkdir "$dir"
        }
        # file header
        if {$lang=="Tcl"  || $lang == "Tcl/Tk"} {
            set text "######################################################\n#\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Home page: $txtProjHome\n######################################################\n"        
        } elseif {$lang == "Perl"} {
            set lang pl
            set text "######################################################\n#\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Home page: $txtProjHome\n######################################################\n"        
        } elseif {$lang=="Java"} {
            set text "/*\n*****************************************************\n*\t$txtProjName\n*\tDistributed under GNU Public License\n* Author: $txtProjAuthor $txtProjEmail\n* Home page: $txtProjHome\n*****************************************************\n*/\n"
        } elseif {$lang=="Fortran"} {
            set text "\nc*****************************************************\nc*\t$txtProjName\n*c\tDistributed under GNU Public License\nc* Author: $txtProjAuthor $txtProjEmail\nc* Home page: $txtProjHome\nc*****************************************************\n*/\n"
        } elseif {$lang=="O'Caml"} {
            set text "\(*****************************************************\n*\t$txtProjName\n*\tDistributed under GNU Public License\n* Author: $txtProjAuthor $txtProjEmail\n* Home page: $txtProjHome\n******************************************************\)\n"
            set lang ml            
        } elseif {$lang=="Ruby"} {
            set lang rb
            set text "######################################################\n#\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Home page: $txtProjHome\n######################################################\n"        
        } elseif {$lang=="PHP"} {
            set text "<?\n/////////////////////////////////////////////////////\n//\t$txtProjName\n//\tDistributed under GNU Public License\n// Author: $txtProjAuthor $txtProjEmail\n// Home page: $txtProjHome\n/////////////////////////////////////////////////////\n?>"
            set lang php
        } elseif {$lang=="Erlang"} {
            set text "\%**************************************************\n%\t$txtProjName\n%\tDistributed under GNU Public License\n% Author: $txtProjAuthor $txtProjEmail\n* Home page: $txtProjHome\n%*****************************************************\)\n"
            set lang erl          
        }
        if {[file exists [file join $dir $txtFileName]] == 0} {
            set file [open [file join $dir $txtFileName] w]
            puts $file $text
            close $file
        }
        #    file attributes "$dir/$txtFileName.tcl" -permissions "777"
        #    catch {chmod 744 "$dir/$txtFileName.tcl"} mes
        foreach f {README TODO CHANGELOG COPYING INSTALL} {
            if {[file exists [file join $dir $f]] != 1} {
                set file [open [file join $dir $f] w]
                puts $file "$text"
                if {$f == "CHANGELOG"} {
                    if {$tcl_platform(platform) == "windows"} {
                        set d [clock format [clock scan "now" -base [clock seconds]] -format %d/%m/%Y]
                    } elseif {$tcl_platform(platform) == "mac"} {
                        set d "Needed date command for this platform"
                    } elseif {$tcl_platform(platform) == "unix"} {
                        set d [clock format [clock scan "now" -base [clock seconds]] -format %d/%m/%Y]
                    }
                    
                    puts $file "$d\n\t- Beginning the project"
                }
                close $file
            }
        }
    } else {
        ## Insert new project into tree ##
        #         $tree insert end root $projShortName -text "$txtProjName" -font $fontNormal \
        #         -data "prj_$projShortName" -open 0 -image [Bitmap::get folder]
        #         GetFiles $txtDirName $projShortName $tree
    }
    AddNewProjectIntoTree $projShortName.proj
}

## OPEN EXISTING PROJECT AND ADDED INYO PROJMAN TREE ##
proc OpenProj {nbNode} {
    global projDir workDir openProjDir prjDir prjName
    #set prjDir [SelectDir $projDir]
    # puts $nbNode
    # what is a tree we clicked?
    if {$nbNode eq "files"} {
        set tree .frmBody.frmCat.noteBook.ffiles.frmTreeFiles.treeFiles
    } elseif {$nbNode eq "projects"} {
        set tree .frmBody.frmCat.noteBook.fprojects.frmTree.tree 
    }
    set item [$tree itemcget [$tree selection get] -data]
    puts $item
    if {[file isdirectory $item]} {
        set prjDir $item
    } elseif {[file isfile $item]} {
        tk_messageBox -type ok -icon error -message "File will not added like project!"
        return
    }
    
    if {$prjDir != ""} {
        set prjName "[file tail $prjDir]"
        NewProj open "" ""
        #file copy $prjDir $projDir
    }
    return
}


proc AddNewProjectIntoTree {proj} {
    global workDir tree imgDir fontNormal
    lappend rList [list [file join $workDir $proj]]
    set projFile [open [file join $workDir $proj] r]
    set prjName [file rootname $proj]
    while {[gets $projFile line]>=0} {
        scan $line "%s" keyWord
        set string [string range $line [string first "\"" $line] [string last "\"" $line]]
        set string [string trim $string "\""]
        if {$keyWord == "ProjectName"} {
            regsub -all " " $string "_" project
            set projName "$string"
        }
        if {$keyWord == "ProjectDirName"} {
            set projList($prjName) [file dirname $string]
            puts "$projList($prjName) - $string"
            $tree insert end root $prjName -text "$projName" -font $fontNormal \
            -data "prj_$prjName" -open 0\
            -image [Bitmap::get [file join $imgDir folder.gif]]
            GetFiles [file join $string] $prjName $tree
            set dir $string
        }
    }
}



