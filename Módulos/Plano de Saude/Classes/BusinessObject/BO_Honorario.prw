#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class BO_Honorario from BO_Guia
		
	method New() Constructor
	method getCabec(cNumGuiInt)
	method getRdaInt(cNumGuiInt)
		
endClass

method new() class BO_Honorario
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} BO_Honorario
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function BO_Honorario
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getCabec
Recupera informações da guia de internação vinculada para inclusão na guia de honorários.
@author Rodrigo Morgon
@since 09/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Method getCabec(cNumGuiInt) Class BO_Honorario
	
	Local aHonCab := {}
	Local lFound 	:= .F.
	Local cGrpEmpInt := GetNewPar("MV_PLSGEIN","0050")
	
	If !Empty(cNumGuiInt)	
		BE4->(DbSetORder(2))	
		If BE4->(MsSeek(xFilial("BE4")+padr(cNumGuiInt,18)))
			lFound := .T.
		EndIf
	EndIf
	
	If lFound
		aadd(aHonCab, BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO) //BD5->BD5_GUIINT
		aadd(aHonCab, BE4->BE4_CODOPE+BE4->BE4_ANOINT+BE4->BE4_MESINT+BE4->BE4_NUMINT) //BD5->BD5_GUIPRI ~ ESTE CAMPO AQUI EH O NRO DO GUIA PRINCIPAL, SERVE PARA FAZER A LIGACAO ENTRE GUIAS, NA PRATICA DEVE TER O NRO DA LIBERACAO
		aadd(aHonCab, BE4->BE4_SENHA) //BD5->BD5_SENHA
		aAdd(aHonCab, BE4->BE4_CDPFSO)		
		If BA1->BA1_CODEMP == cGrpEmpInt
			aadd(aHonCab, BE4->BE4_NRAOPE) //BD5->BD5_NRAOPE
		Endif
	EndIf
	
Return aHonCab

//-------------------------------------------------------------------
/*/{Protheus.doc} getRdaInt
Recupera informações da RDA da guia de internação
@author Rodrigo Morgon
@since 09/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Method getRdaInt(cNumGuiInt) Class BO_Honorario
	
	Local aArea := GetArea()
	Local aHonRdaInt := {}
	Local lFound 	:= .F.
	Local cGrpEmpInt := GetNewPar("MV_PLSGEIN","0050")
	Local cCpfCgc := ""
	Local cCnes   := ""
		
	If !Empty(cNumGuiInt)	
		BE4->(DbSetORder(2))	//be4_filial, be4_codope, be4_codldp, be4_codpeg, be4_numero
		If BE4->(MsSeek(xFilial("BE4")+cNumGuiInt))
			lFound := .T.
		EndIf
	EndIf
	
	if !empty(BE4->BE4_CGCRDA)
	
		BAU->( DbSetOrder(4) )//BAU_FILIAL + BAU_CPFCGC
		BAU->( MsSeek(xFilial("BAU")+BE4->BE4_CGCRDA))
		
		cCnes  := BAU->BAU_CNES  
	else
		BAU->( DbSetOrder(1) )//BAU_FILIAL + BAU_CODIGO
		BAU->( MsSeek(xFilial("BAU")+BE4->BE4_CODRDA) )
		
		BB8->( DbSetOrder(1) )
		BB8->( MsSeek( xFilial("BB8")+BE4->(BE4_CODRDA+BE4_CODOPE+BE4_CODLOC) ) )
		
		cCnes  := BB8->BB8_CNES
	endif
	
	If lFound
 		/*BAU->(DbSetOrder(1)) Ja dei seek acima, não precisa seekar novamente.
		If BAU->(MsSeek(xFilial("BAU")+BE4->BE4_CODRDA))*/
		aadd(aHonRdaInt, BAU->BAU_CPFCGC) //CNPJ da RDA da guia de internação
		aadd(aHonRdaInt, BAU->BAU_NOME) //Nome da RDA da guia de internação
		aadd(aHonRdaInt, /*BAU->BAU_CNES*/cCnes) //CNES da RDA
		//EndIf		
	EndIf
	
Return aHonRdaInt