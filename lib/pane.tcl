package provide pane 1.0

namespace eval pane {
    
    namespace export create
    
    proc create { f1 f2 args } {
        global editor
        set t(-orient)       vertical
    set t(-percent)      0.25
    set t(-gripcolor)    $editor(bg)
    set t(-gripposition) 0.95
    set t(-gripcursor)   crosshair
    set t(-in)           [winfo parent $f1]
    array set t $args

    set master $t(-in)
    upvar #0 [namespace current]::Pane$master pane
    array set pane [array get t]

    if {! [string match v* $pane(-orient)] } {
      set pane(-gripcursor) sb_v_double_arrow
      set height 5 ; set width 3000
    } else {
      set pane(-gripcursor) sb_h_double_arrow
      set height 3000 ; set width 5
    }

    set pane(1) $f1
    set pane(2) $f2
    set pane(grip) [frame $master.grip -background $pane(-gripcolor) \
                          -width $width -height $height \
                          -bd 0 -relief raised -cursor $pane(-gripcursor)]

    if {! [string match v* $pane(-orient)] } {
      set pane(D) Y
      place $pane(1) -in $master -x 0 -rely 0.0 -anchor nw -relwidth 1.0 -height -1
      place $pane(2) -in $master -x 0 -rely 1.0 -anchor sw -relwidth 1.0 -height -1
      place $pane(grip) -in $master -anchor c -relx $pane(-gripposition)
    } else {
      set pane(D) X
      place $pane(1) -in $master -relx 0.0 -y 0 -anchor nw -relheight 1.0 -width -1
      place $pane(2) -in $master -relx 1.0 -y 0 -anchor ne -relheight 1.0 -width -1
      place $pane(grip) -in $master -anchor c -rely 0 ;#$pane(-gripposition)
    }
    $master configure -background gray50

    bind $master <Configure> [list [namespace current]::PaneGeometry $master]
    bind $pane(grip) <ButtonPress-1> \
         [list [namespace current]::PaneDrag $master %$pane(D)]
    bind $pane(grip) <B1-Motion> \
         [list [namespace current]::PaneDrag $master %$pane(D)]
    bind $pane(grip) <ButtonRelease-1> \
         [list [namespace current]::PaneStop $master]

    [namespace current]::PaneGeometry $master
  }

  proc PaneDrag { master D } {
    upvar #0 [namespace current]::Pane$master pane
    if {[info exists pane(lastD)]} {
      set delta [expr double($pane(lastD) - $D) \
                             / $pane(size)]
      set pane(-percent) [expr $pane(-percent) - $delta]
      if {$pane(-percent) < 0.0} {
        set pane(-percent) 0.0
      } elseif {$pane(-percent) > 1.0} {
        set pane(-percent) 1.0
      }
      [namespace current]::PaneGeometry $master
    }
    set pane(lastD) $D
  }

  proc PaneStop { master } {
    upvar #0 [namespace current]::Pane$master pane
    catch {unset pane(lastD)}
  }

  proc PaneGeometry { master } {
    upvar #0 [namespace current]::Pane$master pane
    if {$pane(D) == "X"} {
      place $pane(1) -relwidth $pane(-percent)
      place $pane(2) -relwidth [expr 1.0 - $pane(-percent)]
      place $pane(grip) -relx $pane(-percent)
      set pane(size) [winfo width $master]
    } else {
      place $pane(1) -relheight $pane(-percent)
      place $pane(2) -relheight [expr 1.0 - $pane(-percent)]
      place $pane(grip) -rely $pane(-percent)
      set pane(size) [winfo height $master]
    }
  }

}









