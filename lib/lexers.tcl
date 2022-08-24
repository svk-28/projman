#---------------------------------------------------
# TCL/TK
dict set lexers TCL procFindString {proc }
dict set lexers TCL procRegexpCommand {regexp -nocase -all -- {^\s*?(proc) (::|_|)(\w+)(::|:|_|)(\w+)\s*?(\{|\()(.*)(\}|\)) \{} $line match v1 v2 v3 v4 v5 v6 params v8}

#--------------------------------------------------
# Go lang
dict set lexers GO procFindString {func.*?}
