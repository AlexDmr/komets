inherit CometCamNote_ExaminatorQuestions_LM_FC Logical_model

#______________________________________________________
method CometCamNote_ExaminatorQuestions_LM_FC constructor {name descr args} {
 this inherited $name $descr

 set this(init_ok) 0
  
# Adding some physical presentations
 if {[regexp "^(.*)_LM_FC" $objName rep comet_name]} {} else {set comet_name $objName}
   set name ${comet_name}_PM_FC_[this get_a_unique_id]
#   CometCamNote_ExaminatorQuestions_PM_FC_local $name "Computer CamNote" {CamNote of the computer, time is the one of computer}
#   this Add_PM $name

 set this(init_ok) 1

 eval "$objName configure $args"
 return $objName
}

#______________________________________________________
method CometCamNote_ExaminatorQuestions_LM_FC dispose {} {this inherited}


#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometCamNote_ExaminatorQuestions_LM_FC [L_methodes_set_CamNote_ExaminatorQuestions] {$this(FC)} {$this(L_actives_PM)}
Methodes_get_LC CometCamNote_ExaminatorQuestions_LM_FC [L_methodes_get_CamNote_ExaminatorQuestions] {$this(FC)}

