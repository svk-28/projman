
######################################################
#                Tcl/Tk Project Manager
#        Distributed under GNU Public License
# Author: Serge Kalinin banzaj28@yandex.ru
# Copyright (c) "https://nuk-svk.ru"
# 2018, https://bitbucket.org/svk28/projman
######################################################
#
# Transliterate cyrilic symbols into latins
#
######################################################
proc Translit {line} {
    return [
        string map {
            "А" "A"
            "Б" "B"
            "В" "V"
            "Г" "G"
            "Д" "D"
            "Е" "E"
            "Ё" "E"
            "Ж" "ZH"
            "З" "Z"
            "И" "I"
            "Й" "J"
            "К" "K"
            "Л" "L"
            "М" "M"
            "Н" "N"
            "О" "O"
            "П" "P"
            "Р" "R"
            "С" "S"
            "Т" "T"
            "У" "U"
            "Ф" "F"
            "Х" "H"
            "Ч" "CH"
            "Ш" "SH"
            "Щ" "SCH"
            "Ь" ""
            "Ы" "Y"
            "Ъ" ""
            "Э" "E"
            "Ю" "U"
            "Я" "IA"
            "а" "a"
            "б" "b"
            "в" "v"
            "г" "g"
            "д" "d"
            "е" "e"
            "ё" "e"
            "ж" "zh"
            "з" "z"
            "и" "i"
            "й" "j"
            "к" "k"
            "л" "l"
            "м" "m"
            "н" "n"
            "о" "o"
            "п" "p"
            "р" "r"
            "с" "s"
            "т" "t"
            "у" "u"
            "ф" "f"
            "х" "h"
            "ц" "c"
            "ч" "ch"
            "ш" "sh"
            "щ" "sch"
            "ь" ""
            "ы" "y"
            "ъ" ""
            "э" "e"
            "ю" "u"
            "я" "ia"
        } $line
    ]
}



