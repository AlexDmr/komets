proc GDD_Q {dsl Q} {
 $dsl QUERY $Q
 return [$dsl get_Result]
}

proc Generate_CometChoices_representing_GDD_Q {name L} {
 CometChoice $name $name "Generated by proc Generate_CometChoices_representing_GDD_Q"
 foreach t $L {
   set n "$name[lindex $t 1]"
   CometChoice $n "GDD Task $t" {}
   $name Add_daughter $n
   foreach c [lindex [lindex $t 2] 1] {
     $n Add_daughter [Comet_RepresentationComet ${n}_$c "GDD CUI $c" {}]
	 ${n}_$c set_RepresentedComet $c
    }
  }
 return $name
}

set GDD_query_1 {?t, t : IS_root : NODE()<-REL(type ~= GDD_inheritance && type !~= GDD_concretization)<-$n()<-REL(type~=GDD_concretization)<-NODE()<-REL(type ~= GDD_inheritance)*<REL(type~=GDD_implementation)<-$f()}
set GDD_query_2 {?t, t : IS_root : NODE()<-REL(type ~= GDD_inheritance && type !~= GDD_concretization)<-$n()<-REL(type~=GDD_concretization)<-NODE()<-REL(type ~= GDD_inheritance)*<-$f(type==GDD_CUI)<-REL(type~=GDD_implementation)<-NODE()}

proc some_test_2 {} {
 set GDD_query_2 {?t, t : IS_root : NODE()<-REL(type ~= GDD_inheritance && type !~= GDD_concretization)<-$n()<-REL(type~=GDD_concretization)<-NODE()<-REL(type ~= GDD_inheritance)*<-$f(type==GDD_CUI)<-REL(type~=GDD_implementation)<-NODE()}
 set L_T_CUI [GDD_Q dsl_q $GDD_query_2]
 Generate_CometChoices_representing_GDD_Q c_tool $L_T_CUI
 ci set_daughters_R c_tool
 Connection c_tool
 cr Add_daughter_R [CometContainer c_cont_test cont_test "Test the drop..."]
}

proc some_test {} {
 #ScrollableMonospaceInterleaving_Deployable
set ci_PM_B207 [CSS++ ci "#ci->PMs\[soft_type == BIGre\]"]
#  $ci_PM_B207 Substitute_by_PM_type Interleaving_PM_P_B207_deployable 
set ci_PM_B207 [CSS++ ci "#ci->PMs\[soft_type == BIGre\]"]

Comet_RepresentationComet crc_1 n d -set_RepresentedComet toto
Comet_RepresentationComet crc_2 n d -set_RepresentedComet Clock_CUI_standard_analogic
Comet_RepresentationComet crc_3 n d -set_RepresentedComet fxghfdio
Comet_RepresentationComet crc_4 n d -set_RepresentedComet Specifyer_basic_CUI_textarea

CometChoice c_tool "Tool choice" ""
  CometChoice tool_1 "Tool 1" ""
    tool_1 Add_daughters_R [list crc_1 crc_2]
  CometChoice tool_2 "Tool 2" ""
    tool_2 Add_daughters_R [list crc_2 crc_3]
  CometChoice tool_3 "Tool 3" ""
    tool_3 Add_daughters_R [list crc_3 crc_4]
  c_tool Add_daughters_R [list tool_1 tool_2 tool_3]
  
ci set_daughters_R c_tool

 cr Add_daughter_R [CometContainer c_cont_test cont_test "Test the drop..."]
}