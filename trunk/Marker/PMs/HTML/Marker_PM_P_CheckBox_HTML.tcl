#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_______________________________________________ Définition of the presentations __________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit Marker_PM_P_CheckBox_HTML Marker_PM_P_HTML

#___________________________________________________________________________________________________________________________________________
method Marker_PM_P_CheckBox_HTML constructor {name descr args} {
 this inherited $name $descr
   this set_GDD_id Marker_simple_CUI_CheckBox_HTML
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
method Marker_PM_P_CheckBox_HTML dispose {} {this inherited}

#___________________________________________________________________________________________________________________________________________
method Marker_PM_P_CheckBox_HTML maj_choices {} {}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Marker_PM_P_CheckBox_HTML Render_prim {strm_name {dec {}}} {
 upvar $strm_name rep
 append rep $dec <input [this Style_class] { type="checkbox" onchange="javascript:addOutput(this)" name="} [this get_HTML_var] {" value="} [this get_HTML_val] {"}
   if {[this get_mark]} {append rep { checked="checked"}}
 append rep { />}
   this Render_daughters rep ""
}


