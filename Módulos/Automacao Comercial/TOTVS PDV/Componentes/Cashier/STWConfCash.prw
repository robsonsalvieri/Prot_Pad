#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWCONFCASH.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWConfCash
Realiza a conferencia de caixa
@param 	cTpOpCl - 1 para abertura de caixa, 2 para fechamento de caixa
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	lRet - Retorna se realizou a conferencia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWConfCash(cTpOpCl)

Local lConfCaixa 	:= SuperGetMV( "MV_LJCONFF",,.F. )	//Parametro da conferencia de caixa
Local lRet			:= .T.							//Retorno da funcao

Default cTpOpCl 	:= ""

ParamType 1 Var cTpOpCl As Character Default ""

If lConfCaixa
	If cTpOpCl == "1"
		If 	Empty(STBValOpCash())
			lRet := .T.
		Else
			STFMessage("STWConfCash","STOP",STR0001)
			STFShowMessage("STWConfCash")
			lRet := .F.
		EndIf
	EndIf	
Else
	If cTpOpCl == "2"
		lRet := .F.
	EndIf
EndIf

Return lRet