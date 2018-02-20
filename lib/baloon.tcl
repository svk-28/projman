#######################################################################
#                        Baloon help
#                Author: Alexander Dederer
# Usage:
#   Set balloon tips to widget:
#     balloon $widget set "Hello World"
#     balloon [button .exit -text "exit" -command exit] set "Hello world"
#
#   Clear ballon tips from widget:
#     balloon $widget clear
#
#   Show balloon tips on widget:
#     balloon $widget show "Hello World"
#######################################################################

proc balloon { widget action args } {
    global BALLOON
    
    switch -- $action {
        set {
            if { $args != {{}} } {
                balloon $widget clear
                #bind $widget <Any-Enter> "after 1000 [list balloon %W show $args mousepointer %X %Y]"
                #bind $widget <Any-Leave> "catch { destroy %W.balloon }"
                bind $widget <Enter> " balloon $widget show $args "
                bind $widget <Leave> " wm withdraw .bubble "
            }
        }
        show {
            if ![winfo exists .bubble] {
                toplevel .bubble -relief flat -background black -bd 1
                wm withdraw .bubble
                update
                array set attrFont [font actual fixed]
                set attrFont(-size) [expr $attrFont(-size) - 2]
                eval pack [message .bubble.txt -aspect 5000 -bg lightyellow \
                -font [array get attrFont] -text [lindex $args 0]]
                pack .bubble.txt
                wm transient .bubble .
                wm overrideredirect .bubble 1
                bind .bubble <Enter> "wm withdraw .bubble"
            } ;# if
            
            if {$args == ""} {  wm withdraw .bubble  }
            set text [lindex $args 0]
            
            set BALLOON $text
            switch $text {
                ""        {   wm withdraw .bubble ; update  }
                "default" {
                    after 1000 "raise_balloon $widget {$text}"
                    after 7000 "if { \$BALLOON == {$text} } { wm withdraw .bubble ; update }"
                }
            } ;# switch
        }
        clear {
            catch { destroy .balloon }
            bind $widget <Enter> {}
            bind $widget <Leave> {}
        }
    } ;# switch action
} ;# proc balloon

proc raise_balloon {widget text} {
    global BALLOON
    
    if { $BALLOON != $text } {   wm withdraw .bubble ; update ; return  }
    set cur_widget [winfo containing [winfo pointerx .] [winfo pointery .]]
    if { $cur_widget != $widget } {  return  }
    
    raise .bubble
    .bubble.txt configure -text $text
    set b_x [expr [winfo pointerx .] - [winfo reqwidth .bubble]/2]
    set b_y [expr [winfo pointery .] + 15]
    wm geometry .bubble +$b_x+$b_y
    wm deiconify .bubble
    update
} ;# proc raise_balloon

