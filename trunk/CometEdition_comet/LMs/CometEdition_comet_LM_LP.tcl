inherit CometEdition_comet_LM_LP Logical_presentation

#___________________________________________________________________________________________________________________________________________
method CometEdition_comet_LM_LP constructor {name descr args} {
 this inherited $name $descr
# Adding some physical presentations 
 this Add_PM_factories [Generate_factories_for_PM_type [list {CometEdition_comet_PM_P_U_basic Ptf_ALL} \
                                                       ] $objName]

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometEdition_comet_LM_LP [P_L_methodes_set_CometEdition_comet] {} {$this(L_actives_PM)}
Methodes_get_LC CometEdition_comet_LM_LP [P_L_methodes_get_CometEdition_comet] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_CometEdition_comet_COMET_RE {} {return [list]}
Generate_LM_setters CometEdition_comet_LM_LP [P_L_methodes_set_CometEdition_comet_COMET_RE]

#___________________________________________________________________________________________________________________________________________


