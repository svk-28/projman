package require Img


proc ImageViewer {f w node} {
    global tab_label noteBook factor im1 im2 editor
    set factor($node) 1.0
    frame $w.f -bg $editor(bg)
    pack $w.f -side left -fill both -expand true
    canvas $w.f.c -xscrollcommand "$w.f.x set" -yscrollcommand "$w.y set"  -bg $editor(bg)
    scrollbar $w.f.x -ori hori -command "$w.f.c xview"  -bg $editor(bg)
    scrollbar $w.y -ori vert -command "$w.f.c yview" -bg $editor(bg)
    
    pack $w.f.c -side top -fill both -expand true
    pack $w.f.x -side top -fill x 
    pack $w.y -side left -fill y
    bind $w.f.c <Button-4> "%W yview scroll -3 units"
    bind $w.f.c <Button-5> "%W yview scroll  3 units"
    bind $w.f.c <Shift-Button-4> "%W xview scroll -2 units"
    bind $w.f.c <Shift-Button-5> "%W xview scroll  2 units"
    bind $w.f.c <Control-Button-4> "scale $w.f.c 0.5 $node"
    bind $w.f.c <Control-Button-5> "scale $w.f.c 2 $node"
    #$w.scrwin setwidget $w.scrwin.f
    openImg $f $w.f.c $node
    set tab_label [$noteBook itemcget $node -text]
    balloon $w.f.c set "Mouse wheel up/down - vertiÓal scrolling the image\n\
    Shift + mouse wheel up/down - horizontal image scrolling\n\
    Control + mouse wheel up/down is a scale image -/+"
}
        
proc openImg {fn w node} {
    global im1
    set im1 [image create photo -file $fn]
    #scale $w
    list [file size $fn] bytes, [image width $im1]x[image height $im1]
    $w create image 1 1 -image $im1 -anchor nw -tag img
}

proc scale {w {n 1} node} {
    global im1 im2 factor noteBook tab_label
    set factor($node) [expr {$factor($node) * $n}]
    $w delete img
    catch {image delete $im2}
    set im2 [image create photo]
    if {$factor($node)>=1} {
        set f [expr int($factor($node))]
        $im2 copy $im1 -zoom $f $f
    } else {
        set f [expr round(1./$factor($node))]
        $im2 copy $im1 -subsample $f $f
    }
    $w create image 1 1 -image $im2 -anchor nw -tag img
    $noteBook itemconfigure $node -text "$tab_label (size x$factor($node))"
    $w config -scrollregion [$w bbox all]
}






