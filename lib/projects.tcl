##################################################
#          Tcl/Tk Project Manager
#   Distributed under GNU Public License
# Author: Serge Kalinin banzaj28@yandex.ru
# Copyright (c) "https://nuk-svk.ru", 2018, 
# Home: https://bitbucket.org/svk28/projman
##################################################

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
    global workDir imgDir fontNormal
    set tree .frmBody.frmCat.noteBook.fprojects.frmTree.tree 
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
            GetFiles $tree $prjName [file join $string]
            set dir $string
            
        }
    }
}

## ADD FILE INTO PROJECTS ##
proc AddToProj {fileName mode workingTree} {
    global projDir workDir activeProject noteBook fontNormal imgDir count
    set type [string trim [file extension $fileName] {.}]
    destroy .addtoproj
    
    set node [$workingTree selection get]
    #puts "$fileName $mode $workingTree $node"
    set fullPath [$workingTree itemcget $node -data]
    if {[file isdirectory $fullPath] == 1} {
        set dir $fullPath
        set parentNode $node
    } else {
        set dir [file dirname $fullPath]
        set parentNode [$workingTree parent $node]
    }
    #puts "$node $parentNode $workingTree $fullPath"
    
    if {$type == "tcl"} {
        set img "tcl"
    } elseif {$type == "tk"} {
        set img "tk"
    } elseif {$type == "txt"} {
        set img "file"
    } elseif {$type == "html"} {
        set img "html"
    } elseif {$type == "java"} {
        set img "java"
    } elseif {$type == "pl" || $type == "perl"} {
        set img "perl"
    } elseif {$type == "for"} {
        set img "fortran"
    } elseif {$type == "ml" || $type == "mli"} {
        set img "caml"
    } elseif {$type == "php" || $type == "phtml"} {
        set img "php"
    } elseif {$type == "rb"} {
        set img "ruby"
    } elseif {$type == "rb"} {
        set img "erl"
    } else {
        set img "file"
    }
    if {$mode == "directory"} {
        set img "folder"
    }
    #set dir [file join $projDir $activeProject]
    set dot "_"
    set name [file rootname $fileName]
    set ext [string range [file extension $fileName] 1 end]
    set subNode "$name$dot$ext"
    if {[$workingTree exists $subNode] == 1} {
        puts $count
        append subNode "_$count"
        incr count
    }
    $workingTree insert end $parentNode $subNode -text $fileName \
    -data [file join $dir $fileName] -open 1\
    -image [Bitmap::get [file join $imgDir $img.gif]]\
    -font $fontNormal
    if {[$workingTree itemcget $parentNode -open] == 0} {
        $workingTree itemconfigure $parentNode -open 1
    }
    set file [file join $dir $fileName]
    
    if {$mode == "directory"} {
        file mkdir $file
        return
    }
    InsertTitle $file $type
    EditFile [GetTreeForNode $subNode] $subNode [file join $dir $fileName]
}
## ADD FILE INTO PROJECT DIALOG##

proc AddToProjDialog {mode node} {
    global projDir workDir activeProject imgDir mod workingTree
    set mod $mode
    if {$node eq "files"} {
        set workingTree .frmBody.frmCat.noteBook.ffiles.frmTreeFiles.treeFiles
    } elseif {$node eq "projects"} {
        set workingTree .frmBody.frmCat.noteBook.fprojects.frmTree.tree 
    } else {
        puts "Error node"
        return
    }
    #     if {$activeProject == ""} {
#         set answer [tk_messageBox\
#         -message "[::msgcat::mc "Not found active project"]"\
#         -type ok -icon warning]
#         case $answer {
#             ok {return 0}
#         }
#     }
    
    set w .addtoproj
    if {[winfo exists $w]} {
        destroy $w
    }
    # create the new "goto" window
    toplevel $w
    wm title $w [::msgcat::mc "Create new $mod"]
    wm resizable $w 0 0
    wm transient $w .
    
    frame $w.frmCanv -border 1 -relief sunken
    frame $w.frmBtn -border 1 -relief sunken
    pack $w.frmCanv -side top -fill both -padx 1 -pady 1
    pack $w.frmBtn -side top -fill x
    
    label $w.frmCanv.lblImgTcl -text [::msgcat::mc "Input $mod name"]
    entry $w.frmCanv.entImgTcl
    pack $w.frmCanv.lblImgTcl $w.frmCanv.entImgTcl -expand true -padx 5 -pady 5 -side top
    
    button $w.frmBtn.btnOk -text [::msgcat::mc "Create"] -relief groove \
    -command {AddToProj [.addtoproj.frmCanv.entImgTcl get] $mod $workingTree}
    
    button $w.frmBtn.btnCancel -text [::msgcat::mc "Close"] -command "destroy $w" -relief groove
    pack $w.frmBtn.btnOk $w.frmBtn.btnCancel -padx 2 -pady 2 -fill x -side left
    
    bind $w <Escape> "destroy .addtoproj"
    bind $w.frmCanv.entImgTcl <Return> {
        AddToProj [.addtoproj.frmCanv.entImgTcl get] $mod $workingTree
    }
    focus -force $w.frmCanv.entImgTcl
    puts "$node $workingTree $mode"
    
    #unset type
}
proc AddToProjDialog_ {} {
    global projDir workDir activeProject imgDir tree
    if {$activeProject == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning]
        case $answer {
            ok {return 0}
        }
    }
    
    set w .addtoproj
    if {[winfo exists $w]} {
        destroy $w
    }
    # create the new "goto" window
    toplevel $w
    wm title $w [::msgcat::mc "Create new file"]
    wm resizable $w 0 0
    wm transient $w .
    
    frame $w.frmCanv -border 1 -relief sunken
    frame $w.frmBtn -border 1 -relief sunken
    pack $w.frmCanv -side top -fill both -padx 1 -pady 1
    pack $w.frmBtn -side top -fill x
    
    label $w.frmCanv.lblImgTcl -text [::msgcat::mc "Input file name"]
    entry $w.frmCanv.entImgTcl
    pack $w.frmCanv.lblImgTcl $w.frmCanv.entImgTcl -expand true -padx 5 -pady 5 -side top
    
    button $w.frmBtn.btnOk -text [::msgcat::mc "Create"] -relief groove -command {
        AddToProj [.addtoproj.frmCanv.entImgTcl get]
    }
    button $w.frmBtn.btnCancel -text [::msgcat::mc "Close"] -command "destroy $w" -relief groove
    pack $w.frmBtn.btnOk $w.frmBtn.btnCancel -padx 2 -pady 2 -fill x -side left
    
    bind $w <Escape> "destroy .addtoproj"
    bind $w.frmCanv.entImgTcl <Return> {
        AddToProj [.addtoproj.frmCanv.entImgTcl get]
    }
    focus -force $w.frmCanv.entImgTcl
    
}
## DELETE FILE FROM PROJECT ##
proc DelFromProj {project} {
    global projDir workDir
    
}
## DELETEING PROJECT PROCEDURE ##
proc DelProj {} {
    global workDir activeProject tree
    if {$activeProject == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning]
        case $answer {
            ok {return 0}
        }
    }
    set file [open [file join $workDir $activeProject.proj] r]
    while {[gets $file line]>=0} {
        scan $line "%s" keyWord
        set string [string range $line [string first "\"" $line] [string last "\"" $line]]
        set string [string trim $string "\""]
        if {$keyWord == "ProjectDirName"} {
            set projDir "$string"
            puts $projDir
        }  
    }
    close $file
    
    set answer [tk_messageBox \
    -message "[::msgcat::mc "Delete project"] \"$activeProject\" \
    [::msgcat::mc "with all files"]?\n\
    [::msgcat::mc "If press \"Yes\" will deleted all files!"]\n\
    [::msgcat::mc  "If press \"No\" will deleted only proj-file"]" \
    -type yesnocancel -icon question -default yes]
    switch $answer {
        yes {
            FileDialog $tree close_all
            file delete -force $projDir
            file delete -force [file join $workDir $activeProject.proj]
            file delete -force [file join $workDir $activeProject.tags]
            $tree delete [$tree selection get]
            $tree configure -redraw 1
            set activeProject ""
            LabelUpdate .frmStatus.frmActive.lblActive ""
        }
        no {
            file delete -force [file join $workDir $activeProject.proj]
            file delete -force [file join $workDir $activeProject.tags]
            $tree delete [$tree selection get]
            $tree configure -redraw 1
            set activeProject ""
            LabelUpdate .frmStatus.frmActive.lblActive ""
           }
    }
}

proc CompileOption {string} {
    global fontNormal cmdCompile editor
    set w .cmd
    # destroy the find window if it already exists
    if {[winfo exists $w]} {
        destroy $w
    }
    
    toplevel $w
    wm title $w [::msgcat::mc "Command options"]
    wm resizable $w 0 0
    wm transient $w .
    frame $w.frmCombo -borderwidth 1 -bg $editor(bg)
    frame $w.frmBtn -borderwidth 1 -bg $editor(bg)
    pack $w.frmCombo $w.frmBtn -side top -fill x
    
    #    set combo [entry $w.frmCombo.entFind]
    label $w.frmCombo.lblModule -text "[::msgcat::mc "Convert to"]" -bg $editor(bg) -fg $editor(fg)
    label $w.frmCombo.lblFile -text "[::msgcat::mc "File"]" -bg $editor(bg) -fg $editor(fg)
    set combo [entry $w.frmCombo.txtString -text "$string"]
    
    pack $w.frmCombo.lblModule $w.frmCombo.lblFile $combo -fill x -padx 2 -pady 2 -side top
    
    button $w.frmBtn.btnFind -text [::msgcat::mc "Run"]\
    -font $fontNormal -width 12 -relief groove -bg $editor(bg) -fg $editor(fg)\
    -command {
        return [.cmd.frmCombo.txtString get]
        destroy .cmd
    }
    button $w.frmBtn.btnCancel -text [::msgcat::mc "Close"] -bg $editor(bg) -fg $editor(fg)\
    -relief groove -width 12 -font $fontNormal\
    -command "destroy $w"
    pack $w.frmBtn.btnFind $w.frmBtn.btnCancel -fill x -padx 2 -pady 2 -side left
    
    bind $w <Return> {
        set cmdCompile [.cmd.frmCombo.txtString get]
        destroy .cmd
    }
    bind $w <Escape> "destroy $w"
    $combo insert end "$string"
    focus -force $combo
}

## MAKE PROJ PROCEDURE (RUNNING PROJECT) ##
proc MakeProj {action t} {
    global activeProject projDir noteBook fontNormal fontBold workDir tree cmdCompile editor
    if {$activeProject == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning\
        -title [::msgcat::mc "Warning"]]
        case $answer {
            ok {return 0}
        }
    }
    FileDialog $tree save_all
    set file [open [file join $workDir $activeProject.proj] r]
    while {[gets $file line]>=0} {
        scan $line "%s" keyWord
        set string [string range $line [string first "\"" $line] [string last "\"" $line]]
        set string [string trim $string "\""]
        if {$keyWord == "ProjectName"} {
            set projName "$string"
        }
        if {$keyWord == "ProjectFileName"} {
            set projFileName "$string"
        }
        if {$keyWord == "ProjectDirName"} {
            set projDirName "$string"
        }  
        if {$keyWord == "ProjectCompiler"} {
            set projCompiler "$string"
        }  
        if {$keyWord == "ProjectInterp"} {
            set projInterp "$string"
        }  
    }
    close $file
    if {$action == "compile"} {
        if {$t == "proj"} {
            set prog [file join $projDirName $projFileName.java]
        } elseif {$t == "file"} {
            set node [$tree selection get]
            set fullPath [$tree itemcget $node -data]
            set dir [file dirname $fullPath]
            set file [file tail $fullPath]
            set prog $fullPath
        }
    } elseif {$action == "run"} {
        if {$t == "proj"} {
            set prog [file join $projDirName $projFileName]
        } elseif {$t == "file"} {
            set node [$tree selection get]
            set fullPath [$tree itemcget $node -data]
            set dir [file dirname $fullPath]
            set file [file tail $fullPath]
            set prog $fullPath
        }
    }
    
    set node "debug"
    if {[$noteBook index $node] != -1} {
        $noteBook delete debug
    }
    set w [$noteBook insert end $node -text [::msgcat::mc "Running project"]]
    # create array with file names #
    frame $w.frame -borderwidth 2 -relief ridge -background $editor(bg)
    pack $w.frame -side top -fill both -expand true
    
    
    text $w.frame.text -yscrollcommand "$w.frame.yscroll set" \
    -bg $editor(bg) -fg $editor(fg) \
    -relief sunken -wrap word -highlightthickness 0 -font $fontNormal\
    -selectborderwidth 0 -selectbackground #55c4d1 -width 10 -height 10
    scrollbar $w.frame.yscroll -relief sunken -borderwidth {1} -width {10} -takefocus 0 \
    -command "$w.frame.text yview" -background $editor(bg)
    
    pack $w.frame.text -side left -fill both -expand true
    pack $w.frame.yscroll -side left -fill y 
    
    frame $w.frmBtn -borderwidth 2 -relief ridge -bg $editor(bg)
    pack $w.frmBtn -side top -fill x
    button $w.frmBtn.btnOk -text [::msgcat::mc "Close"] -borderwidth {1} \
    -bg $editor(bg) -fg $editor(fg) -command {
        $noteBook delete debug
        $noteBook  raise [$noteBook page end]
        return 0
    }
    pack $w.frmBtn.btnOk -pady 2
    # key bindings #
    bind $w.frmBtn.btnOk <Escape> {
        $noteBook delete debug
        $noteBook  raise [$noteBook page end]
        #        return 0
    }
    bind $w.frmBtn.btnOk <Return> {
        $noteBook delete debug
        $noteBook  raise [$noteBook page end]
        #        return 0
    }
    focus -force $w.frmBtn.btnOk
    $noteBook raise $node
    # insert debug data into text widget #
    $w.frame.text tag configure bold -font $fontBold
    $w.frame.text tag configure error -font $fontNormal -foreground red
    $w.frame.text tag add bold 0.0 0.end
    if {$action == "compile"} {
        $w.frame.text insert end "[::msgcat::mc "Compile project"] - $activeProject\n"
        $w.frame.text insert end "[::msgcat::mc "Compile"] - $prog\n\n"
    } elseif {$action == "run"} {
        $w.frame.text insert end "[::msgcat::mc "Running project"] - $activeProject\n"
        $w.frame.text insert end "[::msgcat::mc "Run"] - $prog\n\n"
    }
    set pos [$w.frame.text index insert]
    set lineNum [lindex [split $pos "."] 0]
    $w.frame.text insert end "----------------- [::msgcat::mc "Programm output"] -----------------\n"
    $w.frame.text tag add bold $lineNum.0 $lineNum.end
    
    # open and manipulate executed program chanel #
    if {$action == "compile"} {
        set cmdCompile ""
        CompileOption "$projCompiler $prog"
        vwait cmdCompile
        puts "string - $projCompiler $prog" ;# debug info
        set pipe [open "|$cmdCompile 2> [file join $projDirName errors]" "r"]
        set f [open [file join $projDirName errors] "r"]
    } elseif {$action == "run"} {
        set pipe [open "|$projInterp $prog 2> [file join $projDirName errors]" "r"]
        set f [open [file join $projDirName errors] "r"]
    }
    
    fileevent $pipe readable [list DebugInfo $w.frame.text $pipe $f]
    fconfigure $pipe -buffering none -blocking no
}
## INSERT DEBUG INFORMATION INTO TEXT WIDGET ##
proc DebugInfo {widget file f} {
    $widget configure -state normal
    if {[eof $file]} {
        catch [close $file] msg
        if {$msg != ""} {
            puts $msg
            $widget insert end "[::msgcat::mc "Program failed"]: $msg\n";
        } else {
            puts $msg
            $widget insert end "\n-------------------------------------------------\n"
            $widget insert end "[::msgcat::mc "Program finished successfully"]\n"
        }
    } else {
        $widget insert end [read $file]
    }
    while {[gets $f line]>=0} {
        $widget insert end "$line\n"
        puts $line
    }
    $widget see end
    $widget tag add error 0.0 0.end
    $widget configure -state disabled
}
## INSERT TITLE INTO NEW FILE ##
proc InsertTitle {newFile type} {
    global activeProject projDir workDir ver
    puts "$newFile $type"
    set year [clock format [clock scan "now" -base [clock seconds]] -format %Y]
    if {$activeProject == ""} {
        set answer [tk_messageBox\
        -message "[::msgcat::mc "Not found active project"]"\
        -type ok -icon warning\
        -title [::msgcat::mc "Warning"]]
        case $answer {
            ok {return 0}
        }
    }
    set file [open [file join $workDir $activeProject.proj] r]
    while {[gets $file line]>=0} {
        scan $line "%s" keyWord
        set string [string range $line [string first "\"" $line] [string last "\"" $line]]
        set string [string trim $string "\""]
        if {$keyWord == "ProjectName"} {
            set txtProjName "$string"
        }
        if {$keyWord == "ProjectFileName"} {
            set txtProjFileName "$string"
        }
        if {$keyWord == "ProjectDirName"} {
            set txtProjDirName "$string"
        }  
        if {$keyWord == "ProjectInterp"} {
            set txtProjInterp "$string"
        }  
        if {$keyWord == "ProjectVersion"} {
            set txtProjVersion "$string"
        }  
        if {$keyWord == "ProjectRelease"} {
            set txtProjRelease "$string"
        }  
        if {$keyWord == "ProjectAuthor"} {
            set txtProjAuthor "$string"
        }  
        if {$keyWord == "ProjectEmail"} {
            set txtProjEmail "$string"
        }  
        if {$keyWord == "ProjectCompany"} {
            set txtProjCompany "$string"
        }  
        if {$keyWord == "ProjectHome"} {
            set txtProjHome "$string"
        }  
    }
    if {$type == "html"} {
        set fileTitle "<HTML>\n<HEAD>\n<META http-equiv=Content-Type content=\"text/html; charset=koi8-r\">\n<META NAME=\"Author\" CONTENT=\"$txtProjAuthor\">\n<META NAME=\"GENERATOR\" CONTENT=\"Created by Tcl/Tk Project Manager - $ver\">\n<TITLE></TITLE>\n</HEAD>\n<BODY>\n\n</BODY>\n</HTML>"
    } elseif {$type == "tcl"} {
        set fileTitle "#!$txtProjInterp\n######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } elseif {$type == "perl" || $type == "pl"} {
        set fileTitle "######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } elseif {$type == "txt"} {
        set fileTitle "#######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } elseif {$type == "rb"} {
        set fileTitle "#!$txtProjInterp\n######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } elseif {$type == "java"} {
        set fileTitle "/*\n*****************************************************\n*\t$txtProjName\n*\tDistributed under GNU Public License\n* Author: $txtProjAuthor $txtProjEmail\n* Home page: $txtProjHome\n*****************************************************\n*/\n"
    } elseif {$type == "for"} {
        set fileTitle "*****************************************************\n*\t$txtProjName\n*\tDistributed under GNU Public License\n* Author: $txtProjAuthor $txtProjEmail\n* Home page: $txtProjHome\n*****************************************************\n"
    } elseif {$type == "ml" || $type == "mli"} {
        set fileTitle "\(*****************************************************\n*\t$txtProjName\n*\tDistributed under GNU Public License\n* Author: $txtProjAuthor $txtProjEmail\n* Home page: $txtProjHome\n*****************************************************\)\n"
    } elseif {$type == "php" || $type == "phtml"} {
        set fileTitle "<?\n////////////////////////////////////////////////////////////\n//\t$txtProjName\n//\tDistributed under GNU Public License\n// Author: $txtProjAuthor $txtProjEmail\n// Home page: $txtProjHome\n////////////////////////////////////////////////////////////\n\n\n\n\n?>"
    } elseif {$type == "tml"} {
        set fileTitle "<!--\n######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n-->\n"
    } elseif {$type == "erl"} {
        set fileTitle "%*****************************************************\n%\t$txtProjName\n%\tDistributed under GNU Public License\n% Author: $txtProjAuthor $txtProjEmail\n% Home page: $txtProjHome\n%****************************************************\n"
    } else {
        set fileTitle "######################################################\n#\t\t$txtProjName\n#\tDistributed under GNU Public License\n# Author: $txtProjAuthor $txtProjEmail\n# Copyright (c) \"$txtProjCompany\", $year, $txtProjHome\n######################################################\n"
    } 
    set pipe [open $newFile w]
    #   puts "$newFile\n $fileTitle" ;# debuf info
    puts $pipe $fileTitle
    close $pipe
}




