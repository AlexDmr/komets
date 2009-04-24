#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_______________________________________________ Définition of the presentations __________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit Marker_PM_P_Radio_HTML Marker_PM_P_HTML

#___________________________________________________________________________________________________________________________________________
method Marker_PM_P_Radio_HTML constructor {name descr args} {
 this inherited $name $descr
   this set_GDD_id Marker_simple_CUI_RadioBt_HTML

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
method Marker_PM_P_Radio_HTML dispose {} {
 this inherited
}

#___________________________________________________________________________________________________________________________________________
method Marker_PM_P_Radio_HTML maj_choices {} {}

#___________________________________________________________________________________________________________________________________________
method Marker_PM_P_Radio_HTML set_mark {v} {
  set root [this get_L_roots] 
  set methode "checked"

 if {![info exists this(old_mark)]} {set this(old_mark) [this get_mark]}
 
 if {$v != $this(old_mark)} {
   if {$v} {
     set cmd "\$('#${objName}_input').attr('checked', 'checked');"
    } else {set cmd "\$('#${objName}_input').removeAttr('checked');"}
  
   if {[lsearch [gmlObject info classes $root] PhysicalHTML_root] != -1} {
     $root Concat_update $objName $methode $cmd
    }
	
   set this(old_mark) $v
  } 
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Marker_PM_P_Radio_HTML Render_prim {strm_name {dec {}}} {
 upvar $strm_name rep
 append rep $dec "<input id=\"${objName}_input\"" { type="radio" onClick="javascript:addOutput(this)" name="} [this get_HTML_var] {" value="} [this get_HTML_val] {"}
   if {[this get_mark]} {append rep { checked="checked"}}
 append rep { />}
   #this Render_daughters rep ""
}


