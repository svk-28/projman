namespace eval Helper {
    variable ::originalBindings {}
    # Флаг, указывающий, что окно со списком активно
    variable ::listActive 0
    # Переменная для отслеживания предыдущего ввода (чтобы не обновлять список без необходимости)
    variable ::previousInput ""

    proc VarHelperKey { widget K A } {
        set win .varhelper
        DebugPuts "Helper::VarHelperKey: K=$K, A='$A'"
        
        # Проверяем, существует ли окно списка
        if {![winfo exists $win]} {
            DebugPuts "Window doesn't exist, restoring bindings"
            Helper::VarHelperBindingsRestore $widget
            set ::listActive 0
            return
        }
        
        switch -- $K {
            <Up> {
                DebugPuts "Processing Up arrow"
                # Перемещаем выбор вверх
                set current [$win.lBox curselection]
                DebugPuts "Current selection: $current"
                
                if {$current ne "" && $current > 0} {
                    $win.lBox selection clear 0 end
                    $win.lBox selection set [expr {$current - 1}]
                    $win.lBox activate [expr {$current - 1}]
                    $win.lBox see [expr {$current - 1}]
                } elseif {[$win.lBox size] > 0} {
                    # Если ничего не выбрано, выбираем последний элемент
                    set last [expr {[$win.lBox size] - 1}]
                    $win.lBox selection clear 0 end
                    $win.lBox selection set $last
                    $win.lBox activate $last
                    $win.lBox see $last
                }
                return -code break
            }
            <Down> {
                DebugPuts "Processing Down arrow"
                # Перемещаем выбор вниз
                set current [$win.lBox curselection]
                set size [$win.lBox size]
                DebugPuts "Current selection: $current, size: $size"
                
                if {$current ne "" && $current < $size - 1} {
                    $win.lBox selection clear 0 end
                    $win.lBox selection set [expr {$current + 1}]
                    $win.lBox activate [expr {$current + 1}]
                    $win.lBox see [expr {$current + 1}]
                } elseif {$size > 0} {
                    # Если ничего не выбрано, выбираем первый элемент
                    $win.lBox selection clear 0 end
                    $win.lBox selection set 0
                    $win.lBox activate 0
                    $win.lBox see 0
                }
                return -code break
            }
            <Return> {
                DebugPuts "Processing Return"
                Helper::SelectFromList $widget
                return -code break
            }
            <Escape> {
                DebugPuts "Processing Escape"
                # Закрываем окно списка
                wm withdraw $win
                set ::listActive 0
                Helper::VarHelperBindingsRestore $widget
                set ::previousInput ""
                focus $widget
                return -code break
            }
            default {
                DebugPuts "Default case for K=$K, A='$A'"
                # Для печатных символов
                if {$A ne ""} {
                    DebugPuts "Inserting character '$A' and restoring bindings"
                    # Восстанавливаем привязки перед вставкой
                    Helper::VarHelperBindingsRestore $widget
                    # Вставляем символ
                    $widget insert "insert" $A
                }
                return -code break
            }
        }
    }

    proc VarHelper {x y w word wordType} {
        global editors lexers variables
        variable txt 
        variable win
        
        DebugPuts "=== VarHelper called: word='$word', wordType='$wordType' ==="
        
        set txt $w
        # Проверяем если есть выделение то блокировать появление диалога
        if {[$txt tag ranges sel] != ""} {
            DebugPuts "You have selected text [$txt tag ranges sel]"
            return            
        }
        
        set fileType [dict get $editors $txt fileType]

        if {[dict exists $editors $txt variableList] != 0} {
            set varList [dict get $editors $txt variableList]
        } else {
            set varList {}
        }
        if {[dict exists $editors $txt procedureList] != 0} {
            set procList [dict get $editors $txt procedureList]
        } else {
            set procList {}
        }
        
        if {[dict exists $lexers $fileType commands] != 0} {
            foreach i [dict get $lexers $fileType commands] {
                lappend procList $i
            }
        }

        set findedVars ""
        switch -- $wordType {
            vars {
                foreach i [lsearch -nocase -all $varList $word*] {
                    set item [lindex [lindex $varList $i] 0]
                    if {[lsearch $findedVars $item] eq "-1"} {
                        lappend findedVars $item
                    }
                }
            }
            procedure {
                foreach i [lsearch -nocase -all $procList $word*] {
                    set item [lindex [lindex $procList $i] 0]
                    if {[lsearch $findedVars $item] eq "-1"} {
                        lappend findedVars $item
                    }
                }
            }
            default {
                foreach i [lsearch -nocase -all $varList $word*] {
                    set item [lindex [lindex $varList $i] 0]
                    if {[lsearch $findedVars $item] eq "-1"} {
                        lappend findedVars $item
                    }
                }
                foreach i [lsearch -nocase -all $procList $word*] {
                    set item [lindex [lindex $procList $i] 0]
                    if {[lsearch $findedVars $item] eq "-1"} {
                        lappend findedVars $item
                    }
                }
            }
        }
        
        DebugPuts "Found [llength $findedVars] items: $findedVars"
        
        if {$findedVars eq ""} {
            DebugPuts "No items found, returning"
            return
        }
        
        VarHelperDialog $x $y $w $word $findedVars
    }

    proc VarHelperDialog {x y w word findedVars} {
        variable txt 
        variable win

        set txt $w
        set win .varhelper
        
        DebugPuts "VarHelperDialog called with [llength $findedVars] items"
        
        # Если окно уже существует, уничтожаем его
        if {[winfo exists $win]} {
            DebugPuts "Window already exists, destroying it"
            destroy $win
            Helper::VarHelperBindingsRestore $txt
        }
        
        toplevel $win
        wm transient $win .
        wm overrideredirect $win 1
        
        listbox $win.lBox -width 30 -border 0
        pack $win.lBox -expand true -fill y -side left
        
        foreach item $findedVars {
            $win.lBox insert end $item
        }
        
        DebugPuts "Listbox created with [llength $findedVars] items"
        
        # Выбираем первый элемент
        if {[llength $findedVars] > 0} {
            $win.lBox selection set 0
            $win.lBox activate 0
        }
        
        if {[set height [llength $findedVars]] > 10} { 
            set height 10 
        }
        $win.lBox configure -height $height

        Helper::VarHelperBindingsSetup $w
        
        # Привязка для закрытия окна списка
        bind $win <Destroy> [list apply {{win txt} {
            set ::listActive 0
            Helper::VarHelperBindingsRestore $txt
            set ::previousInput ""
        }} $win $txt.t]

        # Определяем расстояние до края экрана (основного окна) и если
        # оно меньше размера окна со списком то сдвигаем его вверх
        set winGeomY [winfo reqheight $win]
        set winGeomX [winfo reqwidth $win]

        set topHeight [winfo height .]
        set topWidth [winfo width .]
        set topLeftUpperX [winfo x .]
        set topLeftUpperY [winfo y .]
        set topRightLowerX [expr $topLeftUpperX + $topWidth]
        set topRightLowerY [expr $topLeftUpperY + $topHeight]
        
        if {[expr $x + $winGeomX] > $topRightLowerX} {
            set x [expr $x - $winGeomX]
        }
        if {[expr $y + $winGeomY] > $topRightLowerY} {
            set y [expr $y - $winGeomY]
        }
        set ::listActive 1
        DebugPuts "Showing window at +$x+$y"
        wm geom $win +$x+$y 
    }

    proc VarHelperBindingsSetup {txt} {
        DebugPuts "Setting up bindings for $txt"
        
        # Сбрасываем сохраненные привязки
        set ::originalBindings {}
        
        # Список событий для перехвата
        set events {<Up> <Down> <Return>}
        
        # Сохраняем и заменяем привязки
        foreach event $events {
            # Получаем текущую привязку
            set original [bind $txt $event]
            DebugPuts "  Saving binding for $event: '$original'"
            
            # Сохраняем оригинал
            lappend ::originalBindings [list $event $original]
            
            # Устанавливаем новую привязку
            bind $txt $event [list Helper::VarHelperKey $txt $event %A]
        }
    }

    # Восстановление оригинальных привязок
    proc VarHelperBindingsRestore {txt} {
        DebugPuts "Restoring bindings for $txt"
        DebugPuts "Have [llength $::originalBindings] bindings to restore"
        
        if {![info exists ::originalBindings]} {
            DebugPuts "  No original bindings stored"
            # Очищаем наши привязки
            foreach event {<Up> <Down> <Return>} {
                bind $txt $event {}
            }
            return
        }
        
        # Восстанавливаем оригинальные привязки
        foreach binding $::originalBindings {
            set event [lindex $binding 0]
            set command [lindex $binding 1]
            DebugPuts "  Restoring $event: '$command'"
            
            if {$command eq ""} {
                bind $txt $event {}
            } else {
                bind $txt $event $command
            }
        }
        
        # Очищаем сохраненные привязки
        set ::originalBindings {}
    }

    proc SelectFromList {txt} {
        set win .varhelper
        
        DebugPuts "SelectFromList called"
        
        if {![winfo exists $win]} {
            DebugPuts "Window doesn't exist"
            return
        }
        
        # Получаем выбранный элемент
        set selected [$win.lBox curselection]
        DebugPuts "Selected index: $selected"
        
        if {$selected ne ""} {
            set text [$win.lBox get $selected]
            DebugPuts "Selected text: $text"
            
            # Вставляем выбранный текст в текстовое поле
            $txt delete "insert - 1 chars wordstart" "insert wordend - 1 chars"
            $txt insert "insert" $text
            
            # Закрываем окно списка
            destroy $win
            set ::listActive 0
            Helper::VarHelperBindingsRestore $txt
            set ::previousInput ""
            
            # Возвращаем фокус
            focus $txt.t
        }
    }

    proc DebugPuts {msg} {
        puts "DEBUG: $msg"
    }
}




