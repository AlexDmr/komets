inherit Hierarchy_CFC CommonFC

#________________________________________________________________________________________________________________________________________
proc L_methodes_get_hierarchy {} {return [list {get_L_h {}}  ]}
proc L_methodes_set_hierarchy {} {return [list {set_L_h {L}} ]}

#________________________________________________________________________________________________________________________________________
method Hierarchy_CFC constructor {} {
 set this(L_h) [list]
}

#________________________________________________________________________________________________________________________________________
Generate_accessors Hierarchy_CFC [list L_h]