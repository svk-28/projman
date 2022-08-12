######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
# 
# Module for read files structure into directory
# 
######################################################
package require fileutil
package require Thread

# TCL procedure
proc ReadFileStructureTCL {fileFullName} {
    global procList
    set f [open "$fileFullName" r]
    while {[gets $f line] >=0} {
        if {[regexp -nocase -all -- {^\s*?(proc) (::|)(\w+)(::|:|)(\w+)\s*?(\{|\()(.*)(\}|\)) \{} $line match v1 v2 v3 v4 v5 v6 params v8]} {
            set procName "$v2$v3$v4$v5"
            lappend procList($fileFullName) [list $procName $params]
        }
    }
    close $f
}

 # GO function
proc ReadFileStructureGO {fileName} {
    if {[regexp -nocase -all -- {^\s*?func\s*?\((\w+\s*?\*\w+)\)\s*?(\w+)\((.*?)\)\s*?(\(\w+\)|\w+|)\s*?\{} $line match v1 funcName params returns]} {
        # set procName "$v2$v3$v4$v5"
        # lappend procList($activeProject) [list $procName [string trim $params]]
        if {$v1 ne ""} {
            set linkName [lindex [split $v1 " "] 1]
            set functionName "\($linkName\).$funcName"
        }

        # tree parent item type text
       lappend procList($fuleFullName) [list $functionName $params]
    }
    if {[regexp -nocase -all -- {^\s*?func\s*?(\w+)\((.*?)\) (\(\w+\)|\w+|)\s*?\{} $line match funcName params returns]} {
        lappend procList($fuleFullName) [list $functonName $params]
    }
}

proc ReadFilesFromDirectory {directory} {
    global procList
    puts $directory
    foreach fileName [fileutil::findByPattern $directory *.tcl] {
        puts "Find file: $fileName"
        ReadFileStructureTCL $fileName
    }
        set f [open "/tmp/test" w]
    foreach name [array names procList] {
        puts $f "$name: $procList($name)"
    }
}


# set threadID [thread::create {
    # proc runCommand {ID command} {
        # set result [eval $command]
        # eval [subst {thread::send -async $ID \
            # {::printResult [list $result]}}]
    # }
    # thread::wait
# }] 
# 
proc Accept { dirLib directory } {
    global dir
    puts $dir(lib)
   puts $dirLib
  # переменная с указанием ваших действия перед порождением потока
    set threadinit {
        # если необходимо, загружаем исходный tcl код, расположенный в других файлах
        foreach { s } { readstructure } {
          # uplevel #0 source [file join /home/svkalinin/Проекты/projman/lib $s.tcl]
          uplevel #0 source [file join $dirLib $s.tcl]
        }
        # не завершаем поток, ибо будет запущен событийный сокетный обработчик
        thread::wait
    }

      # порождаем поток, выполнив предварительные действия, описанные в переменной threadinit
      set tid [thread::create $threadinit]

      # thread::transfer $tid
      # запускаем поток в асинхронном режиме
      thread::send -async $tid [list ReadFilesFromDirectory $directory]
}


# процедура завершения потока
proc Exit:Thread {  } {
  # уничтожаем, останавливаем поток
  thread::release
}
