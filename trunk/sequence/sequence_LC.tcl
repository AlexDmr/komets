#___________________________________________________________________________________________________________________________________________
inherit CometSequence Logical_consistency

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometSequence constructor {name descr args} {
 this inherited $name $descr
   this set_GDD_id CT_Sequence
 set this(FC) "${objName}_CFC"; CommonFC_sequence $this(FC)

 set this(LM_LP) "${objName}_LM_LP";
   Sequence_LM_LP $this(LM_LP) $this(LM_LP) "A logical presentation of $objName"
   this Add_LM $this(LM_LP);

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometSequence [L_methodes_set_sequence] {$this(FC)} {$this(L_LM)}
Methodes_get_LC CometSequence [L_methodes_get_sequence] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
method CometSequence Previous {} {
 if {[this get_step] > 0} {
   [this get_Common_FC] Previous
   foreach LM [this get_L_LM] {$LM Previous}
  } 
}

#___________________________________________________________________________________________________________________________________________
method CometSequence Next {} {
 if {[this get_step] < ([llength [this get_out_daughters]]-1)} {
   [this get_Common_FC] Next
   foreach LM [this get_L_LM] {$LM Next}
  } 
}
