##################################################################
# tools.tcl - this file implements the logic of working
#             with external tools.
##################################################################
# svk, 01/2026
##################################################################

namespace eval Tools {} {
    variable toolsINISections
    variable toolsVariables
}

set ::toolsDefault "\[VisualRegexp\]
commandString=tkregexp %
description'A graphical front-end to write/debug regular expression
icon=
shortCut=
\[TkDIFF\]
commandString=tkdiff %f %f
description=TkDiff is a Tcl/Tk front-end to diff
icon=
shortCut=
"
# Создание файла настроек внешних инструментов
proc Tools::Create {dir} {
    set toolsFile [open [file join $dir tools.ini]  "w+"]
    puts $toolsFile $::toolsDefault
    close $toolsFile
}

proc Tools::Read {dir} {
    set toolsFile [ini::open [file join $dir tools.ini] "r"]
    foreach section [ini::sections $toolsFile] {
        foreach key [ini::keys $toolsFile $section] {
            lappend ::toolsINIsections($section) $key
            dict set ::toolsVariables $section $key [ini::value $toolsFile $section $key]
            DebugPuts "Tools::Read: $toolsFile $section $key = [ini::value $toolsFile $section $key]"
        }
    }
    ini::close $toolsFile
}

proc Tools::Write {dir} {
    set toolsFile [ini::open [file join $dir tools.ini] "w"]
    foreach section  [array names ::toolsINIsections] {
        dict for {key value} [dict get $::toolsVariables $section] {
            DebugPuts "Tools::write: $section $key = $value"
            # ini::set $toolsFile $section $key [dict get $::toolsVariables $section $key]
            ini::set $toolsFile $section $key $value
        }
    }
    ini::commit $toolsFile
    ini::close $toolsFile
}

# Добавление перменной в список 
# если отсутствует нужная секция то она будет добавлена.
proc Tools::AddVariable {key value section} {
    # Проверяем, существует ли уже такая переменная
    if {[info exists ::toolsVariables($key)]} {
        DebugPuts "The variable '$key' already exists: "
        return 0
    }
    # Добавляем в массив переменных
    # set ::toolsVariables($key) $value
    dict set ::toolsVariables $section $key $value
    # Добавляем в список ключей секции
    if {[dict exists $::toolsVariables $key]} {
        # Проверяем, нет ли уже такого ключа в секции
        if {[lsearch -exact $::toolsINIsections($section) $key] == -1} {
            lappend ::toolsINIsections($section) $key
        }
    } else {
        set ::toolsINIsections($section) [list $key]
    }
    DebugPuts "Tools::AddVariable: The variable '$key' has been added to the '$section' array 'toolsVariables' with value '$value'"
    
    return 1
}

# Проверяем наличие переменных в tools.ini на основе "эталонного" списка 
# и выставляем значение по умолчанию если в конфиге переменной нет
proc Tools::CheckVariables {} {
    set valList [split $::toolsDefault "\n"]
    foreach item $valList {
        if {[regexp -nocase -all -- {\[(\w+)\]} $item -> v1]} {
            set section $v1
        }
        if {[regexp {^([^=]+)=(.*)$} $item -> key value]} {
            # puts "$section $key $value >> [dict get $::toolsVariables $section $key]"
            # if {[dict get $::toolsVariables $section $key] eq ""} 
            if ![dict exists $::toolsVariables $section $key] {
                DebugPuts "Error in Tools::CheckVariables: variable $section $key not found"
                Tools::AddVariable "$key" "$value" "$section"
                # DebugPuts "Tools::CheckVariables: The variable toolsVariables $key setting to default value \"$value\""
            }
        }
    }
    foreach id [dict keys $::toolsVariables] {
        DebugPuts "Tools::CheckVariables: config parameters for $id [dict get $::toolsVariables $id]!"
    }
    # DebugPuts "toolsVariables dict keys: [dict keys $::toolsVariables]"
}

proc Tools::GetMenu {m} {
    global cfgVariables toolsVariables
    foreach toolName [dict keys $toolsVariables] {
        dict for {key value} [dict get $toolsVariables $toolName] {
            DebugPuts "GetToolsMenu $key $value"
            if {$key eq "commandString"} {
                set cmd "$value"
            }
            if {$key eq "shortCut"} {
                set shortCut "$value"
            }
        }
        if {[info exists cmd] == 1 && $cmd ne ""} {
            if {[info exists shortCut] == 1 && $shortCut ne ""} {
                $m add command -label $toolName -accelerator $shortCut -command [list Tools::Execute "$toolName"]
            } else {
                $m add command -label $toolName -command [list Tools::Execute "$toolName"]
            }
        }
    }
}

proc Tools::Execute {toolName} {
    global cfgVariables toolsVariables
    if ![dict exists $::toolsVariables $toolName commandString] {
        DebugPuts "Tools::Execute: command for $toolName not found"
        return
    } else {
        set command [dict get $::toolsVariables $toolName commandString]
        DebugPuts "Tools::Execute: command for $toolName as $command"
    }
    # 1. Определять текущий файл
    # 2. Определять выделен ли текст в открытом редакторе
    # 3. Опеределять сколько файлов выделено в дереве
    # 4. Заменяем знак %f на имя текущего файла (файлов)
    # regsub -all "%f" $command "$filePath" fullCommand
    # 5. Заменяем %s на выделенный в редакторе текст 
    # 6. Заменяем %d на текущий каталог(и), если он выделен в дереве,
    #    и если не выделено то корневой открытый в дереве
    # 7. Проверять команды на доступность в системе и подставлять полный путь к команде
    #    если в конфиге не указан полный путь.
    set pipe [open "|$command" "r"]
    fileevent $pipe readable
    fconfigure $pipe -buffering none -blocking no
}

