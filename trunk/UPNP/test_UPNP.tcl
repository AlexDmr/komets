cd c:/These/Projet\ Interface/COMETS/devCOMETS/Comets/
source gml_Object.tcl
cd UPNP
source UPNP_utils.tcl

UPNP_server S

S Send_msg_discovery


proc Encore_un_test_UPNP {} {
 S dispose
 source UPNP_utils.tcl
 UPNP_server S
 S Send_msg_discovery
}