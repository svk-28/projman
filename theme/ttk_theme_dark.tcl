# black.tcl -
#
#   Experimental!
#
#  Copyright (c) 2007-2008 Mats Bengtsson
#
# $Id: black.tcl,v 1.2 2009/10/25 19:21:30 oberdorfer Exp $

package require Tk

namespace eval ttk::theme::dark {
    variable version 0.0.1
    variable dir [file dirname [info script]]
    global cfgVariables
    package provide ttk::theme::dark $version
    
    # NB: These colors must be in sync with the ones in black.rdb
    
    variable colors
    array set colors {
        -disabledfg "#a9a9a9"
        -frame      "#1e1e1e"
        -lightframe "#3d3d3d"
        -dark       "#222222"
        -darker     "#121212"
        -darkest    "#000000"
        -lighter    "#626262"
        -lightest   "#ffffff"
        -selectbg   "#4a6984"
        -selectfg   "#ffffff"
        -foreground "#cecbc9"
    }
    
    ttk::style theme create dark -parent clam -settings {
        
        # -----------------------------------------------------------------
        # Theme defaults
        #
        ttk::style configure . \
        -background $colors(-frame) \
        -foreground #ffffff \
        -bordercolor $colors(-darkest) \
        -darkcolor $colors(-dark) \
        -lightcolor $colors(-lighter) \
        -troughcolor $colors(-darker) \
        -selectbackground $colors(-selectbg) \
        -selectforeground $colors(-selectfg) \
        -selectborderwidth 0 \
        -font "{Droid Sans Mono} 9" 
        
        ttk::style map "." \
        -background [list disabled $colors(-frame) \
        active $colors(-lighter)] \
        -foreground [list disabled $colors(-disabledfg)] \
        -selectbackground [list  !focus $colors(-darkest)] \
        -selectforeground [list  !focus #ffffff]
        
        # ttk widgets.
        ttk::style configure TButton \
        -width -8 -padding {5 1} -relief link
        ttk::style configure TMenubutton \
        -width -11 -padding {5 1} -relief raised
        ttk::style configure TCheckbutton \
        -indicatorbackground "#ffffff" -indicatormargin {1 1 4 1}
        ttk::style configure TRadiobutton \
        -indicatorbackground "#ffffff" -indicatormargin {1 1 4 1}
        
        # ttk::style configure TEntry -fieldbackground #ffffff -foreground #000000 -padding {2 0}
        ttk::style configure TEntry -fieldbackground $colors(-lightframe) -foreground #ffffff -padding {2 0}
        
        ttk::style configure TCombobox \
        -fieldbackground $colors(-lightframe) \
        -foreground #ffffff \
        -padding {2 0}
        ttk::style configure TSpinbox \
        -fieldbackground $colors(-lightframe) \
        -foreground #ffffff
        
        ttk::style configure TNotebook.Tab \
        -padding {6 2 6 2}
        
        #ttk::style configure TPanedwindow -fieldbackground #ffffff -foreground #000000
        #ttk::style configure TPanedwindow -background red -foreground blue
        
        # tk widgets.
        ttk::style map Menu \
        -background [list active $colors(-lighter)] \
        -foreground [list disabled $colors(-disabledfg)]
        
        ttk::style configure Treeview \
        -background $colors(-lightframe) -itembackground {gray60 gray50} \
        -itemfill #ffffff -itemaccentfill yellow \
        -fieldbackground $colors(-lightframe)
        
        ttk::style configure Text \
        -linemapbg [list active $colors(-frame)]\
        -linemapbg [list active $colors(-disabledfg)]\
        -background [list active $colors(-lighter)] \
        -foreground [list disabled $colors(-disabledfg)]
        
        ttk::style configure TLabel -foreground  $colors(-disabledfg)  -padding {2 0}
       
        #         ttk::style configure TreeCtrl \
        #         -background gray30 -itembackground {gray60 gray50} \
        #         -itemfill #ffffff -itemaccentfill yellow
        option add *Toplevel.Background $colors(-dark) interactive
        option add *Text.Foreground $colors(-foreground) interactive
        option add *Text.Background $colors(-frame) interactive
        
        # option add *Text.Insertbackground yellow interactive
        # option add *Text.BorderWidth -2 interactive
        # option add *Text.selectBorderWidth -2 interactive
        # option add *Text.Relief flat interactive
        option add *Text.Font "{Noto Sans Mono} 10" interactive
        #option add *BorderWidth -2 interactive
    }
    #option add *Treeview.Background red interactive
    #     option add *Frame.Background $colors(-frame) interactive
    #     option add *Label.Background $colors(-frame) interactive
    #     option add *Label.Foreground $colors(-foreground) interactive
    #     option add *Entry.Background $colors(-frame) interactive
    #     option add *Entry.Foreground $colors(-foreground) interactive
}
