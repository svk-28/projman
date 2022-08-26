######################################################
#                ProjMan 2
#        Distributed under GNU Public License
# Author: Sergey Kalinin svk@nuk-svk.ru
# Copyright (c) "", 2022, https://nuk-svk.ru
######################################################
namespace eval Highlight {} {
    proc TCL {txt} {
        ctext::addHighlightClassForRegexp $txt flags orange {\s-[a-zA-Z]+}
        ctext::addHighlightClass $txt stackControl #19a2a6 [info commands]
        ctext::addHighlightClass $txt widgets #9d468d [list canvas ctext button entry label text labelframe frame toplevel scrollbar checkbutton canvas listbox menu menubar menubutton  radiobutton scale entry message tk_chooseDir tk_getSaveFile  tk_getOpenFile tk_chooseColor tk_optionMenu ttk::button ttk::checkbutton ttk::combobox ttk::entry ttk::frame ttk::intro ttk::label ttk::labelframe ttk::menubutton ttk::treeview ttk::notebook ttk::panedwindow ttk::progressbar ttk::radiobutton ttk::scale ttk::scrollbar ttk::separator ttk::sizegrip ttk::spinbox ]
        ctext::addHighlightClassWithOnlyCharStart $txt vars #4471ca "\$"
        ctext::addHighlightClass $txt variable_funcs gold {set global variable unset}
        ctext::addHighlightClassForSpecialChars $txt brackets green {[]{}()}
        ctext::addHighlightClassForRegexp $txt paths lightblue {\.[a-zA-Z0-9\_\-]+}
        ctext::addHighlightClassForRegexp $txt comments #666666 {(#|//)[^\n\r]*}    
        ctext::addHighlightClassForRegexp $txt namespaces #4f64ff {::}
        ctext::addHighlightClassForSpecialChars $txt qoute #b84a0c {"'`}
    }

    proc Default {txt} {
        ctext::addHighlightClassForRegexp $txt flags orange {\s-[a-zA-Z\-_]+}
        ctext::addHighlightClass $txt stackControl #19a2a6 [info commands]
        ctext::addHighlightClassWithOnlyCharStart $txt vars #4471ca "\$"
        ctext::addHighlightClass $txt variable_funcs gold {set global variable unset}
        ctext::addHighlightClassForSpecialChars $txt brackets green {[]{}()}
        ctext::addHighlightClassForRegexp $txt paths lightblue {\.[a-zA-Z0-9\_\-]+}
        ctext::addHighlightClassForRegexp $txt comments #666666 {(#|//)[^\n\r]*}    
        ctext::addHighlightClassForRegexp $txt namespaces #4f64ff {::}
        ctext::addHighlightClassForSpecialChars $txt qoute #b84a0c {"'`}
    }
    
    proc SH {txt} {
        ctext::addHighlightClassForRegexp $txt flags orange {-+[a-zA-Z\-_]+}
        ctext::addHighlightClass $txt stackControl #19a2a6 {if fi else elseif then while case esac do in exit source echo package mkdir ls rm sed awk grep date jq zip tar gzip mount umount test make curl git iconv less gcc scp rsync cut tr}
        ctext::addHighlightClassWithOnlyCharStart $txt vars #4471ca "\$"
        ctext::addHighlightClassForRegexp $txt vars_extended #4471ca {\$\{[a-zA-Z0-9\_\-:\./\$\{\}]+\}}
        ctext::addHighlightClass $txt variable_funcs gold {set export}
        ctext::addHighlightClassForSpecialChars $txt brackets green {[]{}()}
        ctext::addHighlightClassForRegexp $txt paths lightblue {\.[a-zA-Z0-9\_\-]+}
        ctext::addHighlightClassForRegexp $txt comments #666666 {(#|//)[^\n\r]*}    
        ctext::addHighlightClassForSpecialChars $txt qoute #b84a0c {"'`}
    }
    
    proc GO {txt} {
        ctext::addHighlightClassForRegexp $txt flags orange {-+[a-zA-Z\-_]+}
        ctext::addHighlightClass $txt stackControl #19a2a6 {if else for while case switch func import return interface map make break chan fallthrough defer continue go select package}  
        ctext::addHighlightClass $txt types #7187d5 {string int int16 int32 int64 float bool byte}
        ctext::addHighlightClassWithOnlyCharStart $txt vars #4471ca "\&"
        ctext::addHighlightClassWithOnlyCharStart $txt vars #4471ca "\*"
        # ctext::addHighlightClassForRegexp $txt vars_extended #4471ca {\$\{[a-zA-Z0-9\_\-:\./\$\{\}]+\}}
        ctext::addHighlightClass $txt variable_funcs gold {var type struct}
        ctext::addHighlightClassForSpecialChars $txt brackets green {[]{}()}
        ctext::addHighlightClassForRegexp $txt paths lightblue {\.[a-zA-Z0-9\_\-]+}
        ctext::addHighlightClassForRegexp $txt comments #666666 {(#|//)[^\n\r]*}    
        ctext::addHighlightClassForSpecialChars $txt qoute #b84a0c {"'`}
    }
    
    proc PY {txt} {
        ctext::addHighlightClassForRegexp $txt flags orange {-+[a-zA-Z\-_]+}
        ctext::addHighlightClass $txt stackControl #19a2a6 {if else for while case switch def import from return make break defer continue package len print with open}
        ctext::addHighlightClass $txt types #7187d5 {string int int16 int32 int64 float bool byte}
        ctext::addHighlightClassWithOnlyCharStart $txt vars #4471ca "\&"
        ctext::addHighlightClassWithOnlyCharStart $txt vars #4471ca "\*"
        # ctext::addHighlightClass $txt variable_funcs gold {var type struct}
        ctext::addHighlightClassForSpecialChars $txt brackets green {[]{}()}
        ctext::addHighlightClassForRegexp $txt paths lightblue {\.[a-zA-Z0-9\_\-]+}
        ctext::addHighlightClassForRegexp $txt comments #666666 {(#|//)[^\n\r]*}    
        ctext::addHighlightClassForSpecialChars $txt qoute #b84a0c {"'`}
    }
}
