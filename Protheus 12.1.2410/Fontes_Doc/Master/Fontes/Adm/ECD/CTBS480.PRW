#include 'PROTHEUS.CH'
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "CTBA940.CH"

Function CTBS480()

//verifico se existe o parametro criado na base
if FWSX6Util():ExistsParam( "MV_ULTVECD" ) 
	PutMv("MV_ULTVECD",DTOS(date()))
endIf
FWCallApp("ctbs480",,,,,,,,,.T.)


Return 
