#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
# ECA : E, C, A
#   E :
method DSL_ECA constructor {} {
 set this(lexic,letters)     {[a-zA-Z0-9_\$"]}
 set this(lexic,spaces)      {[ \n\t]}
 set this(lexic,op_cmp)      {[!~=<>]}
}

#_________________________________________________________________________________________________________
method DSL_ECA Interprets {str {L_comets {}}} {
# D�coupage E, C, A
 set E [this E str]
 set C {}
 set A {}

 set pos [string first , $str]
 set str [string range $str [expr $pos+1] end]
   set C [this C str]
 set pos [string first , $str]
 set str [string range $str [expr $pos+1] end]
   set A [this A str]

 #puts "E : $E\nC : $C\nA : $A"
 foreach c $L_comets {
   set obj $c
   set comet_evt [lindex $E 0]
     if {[string equal \$ [string index $comet_evt 0]]} {eval "set comet_evt $comet_evt"}
   set mtd_evt   [lindex $E 1]
   set A_txt [subst $A]
   set A_txt [string map [list ALX_CROCHET_OUVRANT "\\\[" \
	                           ALX_CROCHET_FERMANT "\\\]" ] $A_txt]
   #puts "$comet_evt Subscribe_to_$mtd_evt \"$c$C\" \"if \{$C\} \{set obj $c; [subst $A_txt]\}\" UNIQUE"
   $comet_evt Subscribe_to_$mtd_evt "$c$C" "if \{$C\} \{set obj $c; $A_txt\}" UNIQUE
  }
}

#_________________________________________________________________________________________________________
method DSL_ECA E {str_name} {
 upvar $str_name str

 set pos [string first , $str]
 set rep [string range $str 0 [expr $pos-1]]
 if {[regexp "^$this(lexic,spaces)*($this(lexic,letters)*)$this(lexic,spaces)*($this(lexic,letters)*)$this(lexic,spaces)*$" $str reco obj mtd]} {set rep [list $obj $mtd]}
 set str [string range $str $pos end]

 return $rep
}

#_________________________________________________________________________________________________________
method DSL_ECA C {str_name} {
 upvar $str_name str

 set pos [string first , $str]
 set rep [string range $str 0 [expr $pos-1]]
 set str [string range $str $pos end]

 return $rep
}

#_________________________________________________________________________________________________________
method DSL_ECA A {str_name} {
 upvar $str_name str
 set res {}
 set rep {}
 set delta_prcdt 0
 set level 0
 set delta_level [this Next_parenthesis str rep level]
 
 set at_least_one 1
 while {$at_least_one || $delta_level != 0 || $delta_prcdt==-1} {
   set at_least_one 0
   #puts "str : $str\nrep : $rep\nlevel : $level\ndelta : $delta_level\n__________________________"
   set nb [expr $level-$delta_level-1]
   if {$delta_prcdt == -1} {incr nb}
   set dec {}; for {set i 0} {$i<int(pow(2, $nb))-1} {incr i} {append dec {\\}}

   # Replace \\
     set nb2 $nb; incr nb2 2
     set dec2 {}; for {set i 0} {$i<int(pow(2, $nb2))-1} {incr i} {append dec2 {\\}}
     
	 set rep [string map [list "\\\[" ALX_CROCHET_OUVRANT \
	                           "\\\]" ALX_CROCHET_FERMANT] $rep]
	 
	 set rep [string map [list "\\" "$dec2\\\\"] $rep]
   # Replace ---
     set rep [string map [list {---} " $dec\\\; "] $rep]
   # Replace $
     set rep [string map [list {$} "\\\$" ] $rep]
   # Replace ", [ and ]
     set rep [string map [list "\[" "$dec\\\[" "\]" "$dec\\\]" "\"" "$dec\\\""] $rep]
   # Replace \n
     set rep [string map [list "\n" ""] $rep]
   # Replace ,
     set nb [expr $level-$delta_level-1]
     set dec {}; for {set i 0} {$i<int(pow(2, $nb))-1} {incr i} {append dec {\\}}
     set rep [string map [list , "$dec\\\" $dec\\\""] $rep]


   # Append the corrected string
   set dec {};
   if {$level-$delta_level > 0 || $delta_prcdt == -1} {
     set nb [expr $level-$delta_level-1]
     if {$delta_prcdt == -1} {incr nb}
     for {set i 0} {$i<int(pow(2, $nb))-1} {incr i} {append dec {\\}}
     append dec "\\\""
    }

   append res " $dec " $rep

   # Continue analysis
   set delta_prcdt $delta_level
   set delta_level [this Next_parenthesis str rep level]
  }

 return $res
}

#_________________________________________________________________________________________________________
method DSL_ECA Next_parenthesis {str_name rep_name level_name} {
 upvar $str_name   str
 upvar $rep_name   rep
 upvar $level_name level

 set pos_txt [string first '' $str]
 set o [string first ( $str]
 set c [string first ) $str]

 if {$o == $c} {set rep $str; set str {}; return 0}
 if {$o == -1} {set o $c; incr o} else {if {$c == -1} {set c $o; incr c}}

# On passe les pure text
 if {$pos_txt >= 0 && $pos_txt < $o && $pos_txt < $c} {
   #puts "On a vu un text ''"
   incr pos_txt 2
   set end_txt [string first '' $str $pos_txt]; incr end_txt 2
   set o [string first ( $str $end_txt]
   set c [string first ) $str $end_txt]
   if {$o == $c} {set rep $str; set str {}; return 0}
   if {$o == -1} {set o $c; incr o} else {if {$c == -1} {set c $o; incr c}}
  }

 if {$o < $c} {set res 1; set pos $o; incr level} else {set res -1; set pos $c; incr level -1}
 incr pos -1
   set rep [string range $str 0 $pos]
   set rep [string map [list '' {}] $rep]
 incr pos 2
   set str [string range $str $pos end]

 return $res
}

#_________________________________________________________________________________________________________
# set str {ccn toto, $m == 1, Transfo(F(a, $b)---$obj Sub kiki, Morph(A(b,c), d), Anim(E(g,h,j), K($d))}