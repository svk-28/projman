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

