#___________________________________________________________________________________________________________________________________________
#___________________________________________ D�finition of Logical Model of pr�sentation ___________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit ChoiceN_LM_LP Logical_presentation
#___________________________________________________________________________________________________________________________________________
method ChoiceN_LM_LP constructor {name descr args} {
 set this(init_pas_ok) 1
 this inherited $name $descr
 this set_L_actives_PM {}
 set this(num_sub) 0

 if {[regexp "^(.*)_LM_LP" $objName rep comet_name]} {} else {set comet_name $objName}
 set this(comet_name) $comet_name

# Nesting parts
# set this(comet_label) [$comet_name get_comet_label]
#   this Add_daughter $this(comet_label)
#   this Add_handle_composing_comet $this(comet_label) 0 _LM_LP

# Adding some PM of presentations
# set TK_scale "${comet_name}_PM_P_TK_scale_[this get_a_unique_id]"
#   PM_P_scale_TK        $TK_scale "A scale" "A TK scale representing $objName"
#   this Add_PM        $TK_scale
#   this set_PM_active $TK_scale
 
  this Add_PM_factories [Generate_factories_for_PM_type [list {PM_P_scale_TK Ptf_TK}                    \
                                                              {PM_P_ChoiceN_menu_TK Ptf_TK}             \
                                                              {ChoiceN_PM_P_menu_HTML Ptf_HTML}         \
                                                              {ChoiceN_PM_P_Texte_HTML Ptf_HTML}        \
                                                              {CometChoiceN_PM_P_scale_BIGre Ptf_BIGre} \
															  {DChoiceN_PM_P_Menu_FLEX Ptf_FLEX}        \
                                                        ] $objName]
 set this(init_pas_ok) 0
 
 eval "$objName configure $args"
 return $objName
}
#______________________________________________________ Adding the choices functions _______________________________________________________
Methodes_set_LC ChoiceN_LM_LP $L_methodes_set_choicesN {} {$this(L_actives_PM)}
Methodes_get_LC ChoiceN_LM_LP $L_methodes_get_choicesN {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_PM_set_ChoiceN_COMET_RE {} {return [list {set_val {v}}]}
Generate_LM_setters ChoiceN_LM_LP [P_L_methodes_PM_set_ChoiceN_COMET_RE]

#______________________________________________________ Adding the choices functions _______________________________________________________
method ChoiceN_LM_LP set_PM_active {PM} {
 this inherited $PM
 if {$this(init_pas_ok)} {return}
 $PM set_val [this get_val]
}

#Trace ChoiceN_LM_LP set_val
