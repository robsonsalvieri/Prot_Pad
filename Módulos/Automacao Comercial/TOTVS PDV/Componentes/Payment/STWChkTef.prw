#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"


//--------------------------------------------------------------------
/*/{Protheus.doc} STWChkTef
Verifica em qual qual o tipo de transação deve ser executada

@param   	cType - Tipo de transacao
@author  Varejo
@version P11.8
@since   	20/02/2013
@return  	lRet - Retorna se o Tipo esta configurado
@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STWChkTef( cType )

Local lRet		:= .F.				//Variavel de retorno
Local oTEF20 	:= STBGetTEF()		//Objeto do TEF já instanciado

Default cType := ""

LjGrvLog("STWChkTef"," Inicio - Verifica em qual qual o tipo de transação deve ser executada ", cType)

ParamType 0 Var 	cType 	As Character	Default 	""

If oTEF20 <> Nil

	Do Case
	
		Case cType $ "CC|CD"
			If 	oTEF20:oConfig:ISCCCD()
				lRet := .T.
			Else
				lRet := .F.
			EndIf	
		Case cType == "CH"
			If oTEF20:oConfig:ISCheque()
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		Case cType == "RC"
			If oTEF20:oConfig:ISRecCel()
				lRet := .T.
			Else
				lRet := .F.
			EndIf			
		Case cType == "CB"
			If oTEF20:oConfig:ISCB()
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		Case IsPDOrPix(cType) // PD e PIX
			If oTEF20:oConfig:ISPgtoDig()
				lRet := .T.
			Else
				lRet := .F.
			EndIf
			
	EndCase 

Else
	LjGrvLog("STWChkTef", "Variavel oTEF20 Nula!")
	
EndIf

LjGrvLog("STWChkTef"," Verifica em qual qual o tipo de transação deve ser executada - Fim", lRet)

Return lRet

