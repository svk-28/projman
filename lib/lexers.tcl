########################################################
#
#-------------------------------------------------------
# "PROCNAME" in procFindString will be changed on
# "procName" from procRegexpCommand
#-------------------------------------------------------
# TCL/TK
dict set lexers TCL commentSymbol {#}
dict set lexers TCL procFindString {proc PROCNAME}
dict set lexers TCL procRegexpCommand {regexp -nocase -all -- {^\s*?(proc) (.*?) \{(.*?)\} \{} $line match keyWord procName params}
dict set lexers TCL varRegexpCommand {regexp -nocase -all -- {^\s*?set\s+([a-zA-Z0-9\:\-_$]+)\s+(.+?)($|;)} $line match varName varValue lineEnd}

#--------------------------------------------------
# Go lang
dict set lexers GO commentSymbol {//}
dict set lexers GO procFindString {func.*?PROCNAME}
dict set lexers GO procRegexpCommand {regexp -nocase -all -- {\s*?func\s*?(\(\w+\s*?\**?\w+\)|)\s*?(\w+)\((.*?)\)\s+?([a-zA-Z0-9\{\}\[\]\(\)-_.]*?|)\s*?\{} $line match linkName procName params returns}

#--------------------------------------------------
# SHELL (Bash)
dict set lexers SH commentSymbol {#}
dict set lexers SH procFindString {(function |)\s*?PROCNAME\(\)}
dict set lexers SH procRegexpCommand {regexp -nocase -all -- {^\s*?(function |)\s*?(.*?)\(()\)} $line match keyWord procName params}

#--------------------------------------------------
# Python 
dict set lexers PY commentSymbol {#}
dict set lexers PY procFindString {(def )\s*?PROCNAME}
dict set lexers PY procRegexpCommand {regexp -nocase -all -- {^\s*?(def)\s*?(.*?)\((.*?)\):} $line match keyWord procName params}

#--------------------------------------------------
# Ruby 
dict set lexers RB commentSymbol {#}
dict set lexers RB tabSize 2
dict set lexers RB procFindString {(def )\s*?PROCNAME}
dict set lexers RB procRegexpCommand {regexp -nocase -all -- {^\s*?(def)\s([a-zA-Z0-9\-_:]+?)($|\(.+?\))} $line match keyWord procName params}

#--------------------------------------------------
# YAML (ansible)
dict set lexers YML commentSymbol {#}
dict set lexers YML tabSize 2
dict set lexers YML procFindString {(- name:)\s*?PROCNAME}
dict set lexers YML procRegexpCommand {regexp -nocase -all -- {^\s*?- (name):\s(.+?)$} $line match keyWord procName}
dict set lexers YML varRegexpCommand {regexp -nocase -all -- {^\s*?([a-zA-Z0-9\-_$]+):\s+(.+?)(\s*$)} $line match varName varValue lineEnd}

dict set lexers ALL varDirectory {vars group_vars host_vars}


