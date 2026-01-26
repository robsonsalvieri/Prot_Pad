#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class BO_Odonto from BO_Guia
		
	method New() Constructor
	method getFace(cDente)
	method getDente(cFace)
	method getDadLib(cNumLib)
		
endClass

method new() class BO_Odonto
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} BO_Odonto
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function BO_Odonto
Return

method getDente(cDente) class BO_Odonto
local cDescDente := ""
	// Dente e face quando e procedimento de consulta no odontologico.
	if !Empty(cDente)
		B04->( DbSetOrder(1) )//B04_FILIAL+B04_CODIGO+B04_TIPO
	    if B04->(MsSeek(XFILIAL("B04")+cDente))
			//BD6->BD6_DENREG := cDente 	
		    cDescDente := B04->B04_DESCRI 	//BD6->BD6_DESREG
		else
			cDescDente := ""					
		endIf
	endIf
return cDescDente

method getFace(cFace) class BO_Odonto	
local cDesFace := ""
	if !Empty(cFace)
		B09->( DbSetOrder(1) )//B09_FILIAL+B09_FADENT
		if B09->( msSeek(xFilial("B09")+cFace) )
			//BD6->BD6_FADENT := cFace
			cDesFace := B09->B09_FACDES 	//BD6->BD6_FACDES
		else
			cDesFace := ""
		endIf
	endIf
return cDesFace


//Obter dados de data da data de autorização e validade da senha da liberação, noa hora de editar a guia odonto.
method getDadLib(cNumLib) class BO_Odonto
local aDados	:= {}
local aPosBEA	:= BEA->(GetArea())
local aPosBE2 := BE2->(GetArea())
local cCodPad := ""
local cProcsL	:= ""

BEA->(DbSetOrder(1)) //BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
if BEA->( MsSeek( xFilial("BEA") + cNumLib ) )
	aAdd(aDados, {BEA->BEA_DATPRO, BEA->BEA_VALSEN})
endif

BE2->( DbSetOrder(1) )//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
If BE2->( MsSeek(xFilial("BE2") + cNumLib) )	
	While ! BE2->( Eof() ) .And. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == xFilial("BE2") + cNumLib
		cCodPad := PLSGETVINC("BTU_CDTERM", "BR4", .F., "87", Alltrim(BE2->BE2_CODPAD),.T.)
		cProcsL += cCodPad + AllTrim(BE2->BE2_CODPRO) + AllTrim(BE2->BE2_DENREG) + AllTrim(BE2->BE2_FADENT) + "$"
		BE2->( DbSkip())	
	enddo
	aAdd(aDados, {cProcsL})
endif

RestArea(aPosBEA)
RestArea(aPosBE2)
return aDados                                                                               
