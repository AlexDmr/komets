#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_______________________________________________ Définition of the presentations __________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometSWL_Planet_PM_P_SVG_basic PM_SVG

#___________________________________________________________________________________________________________________________________________
method CometSWL_Planet_PM_P_SVG_basic constructor {name descr args} {
 this inherited $name $descr
   this set_GDD_id FUI_CometSWL_Planet_PM_P_SVG_basic
 
 this Add_MetaData PRIM_STYLE_CLASS [list $objName "PLANET PARAM RESULT IN OUT"]
 
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometSWL_Planet_PM_P_SVG_basic [P_L_methodes_set_CometSWL_Planet] {} {}
Methodes_get_LC CometSWL_Planet_PM_P_SVG_basic [P_L_methodes_get_CometSWL_Planet] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
Generate_PM_setters CometSWL_Planet_PM_P_SVG_basic [P_L_methodes_set_CometSWL_Planet_COMET_RE]

#___________________________________________________________________________________________________________________________________________
method CometSWL_Planet_PM_P_SVG_basic Update_datas {} {}

#___________________________________________________________________________________________________________________________________________
method CometSWL_Planet_PM_P_SVG_basic set_mode    {m}  {
 if {$m == "game"} {set v 0} else {set v 1}

}

#___________________________________________________________________________________________________________________________________________
method CometSWL_Planet_PM_P_SVG_basic set_X       {v}  {
 
}

#___________________________________________________________________________________________________________________________________________
method CometSWL_Planet_PM_P_SVG_basic set_Y       {v}  {
 
}

#___________________________________________________________________________________________________________________________________________
method CometSWL_Planet_PM_P_SVG_basic set_R       {v}  {
 
}

#___________________________________________________________________________________________________________________________________________
method CometSWL_Planet_PM_P_SVG_basic set_density {v}  {}

#___________________________________________________________________________________________________________________________________________
method CometSWL_Planet_PM_P_SVG_basic Render {strm_name {dec {}}} {
 upvar $strm_name strm
 
  append strm "<circle id=\"${objName}_resize\" cx=\"[this get_X]\" cy=\"[this get_Y]\" r=\"45\" fill=\"green\" />\n"
  append strm "<circle id=\"${objName}_drag\" cx=\"[this get_X]\" cy=\"[this get_Y]\" r=\"40\" fill=\"red\" />\n"

 this Render_daughters strm "$dec  "
}

#___________________________________________________________________________________________________________________________________________
method CometSWL_Planet_PM_P_SVG_basic Render_post_JS {strm_name} {
 upvar $strm_name strm
 this inherited strm
 # draggable?
 # append cmd "\$(this).get(0).setAttribute('cx',e.pageX);"
 # append cmd "\$(this).get(0).setAttribute('cy',e.pageY);"
}
