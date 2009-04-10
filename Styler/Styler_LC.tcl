#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
# Creation of a set of cometStyler
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometStyler Logical_consistency

#___________________________________________________________________________________________________________________________________________
method CometStyler constructor {name descr args} {
 this inherited $name $descr

 set CFC "${objName}_CFC"; CommonFC_Styler $CFC
   this set_Common_FC $CFC

 set this(LM_LP) "${objName}_LM_LP";
   Styler_LM_LP  $this(LM_LP) $this(LM_LP) "The logical presentation of $name"
   this Add_LM $this(LM_LP);

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometStyler [L_methodes_set_Styler] {$this(FC)} {$this(L_LM)}
Methodes_get_LC CometStyler [L_methodes_get_Styler] {$this(FC)}

#___________________________________________________________________________________________________________________________________________


