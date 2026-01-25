#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBRFDShowObs
Verifica configurações se exibe campo observação na interface

@param		
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lShow				Retorna se exibe campo obs na interface
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRFDShowObs()

Local lShow		:= .T.		// Retorno funcao

/*/
	Facilitador que diz se:
	"N" - Não Aparece
	"B" - Aparece e é obrigatório
	"P" - Aparece e é opcional
/*/
If  STFGetCfg("cRFDShowObs") == "N"	
	lShow := .T.
Else
	lShow := .F.	
EndIf

Return lShow


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRFDObrigat
Verifica configurações se exibe campo observação na interface

@param		
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lShow				Retorna se exibe campo obs na interface
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRFDObrigat()

Local lObrigat		:= .T.		// Retorno funcao

/*/
	Facilitador que diz se:
	"N" - Não Aparece
	"B" - Aparece e é obrigatório
	"P" - Aparece e é opcional
/*/
If  STFGetCfg("cRFDObrigat") $ "B|P" 	
	lObrigat := .T.
Else
	lObrigat := .F.	
EndIf


Return lObrigat

//-------------------------------------------------------------------
/*/{Protheus.doc} STBRFDAtiv
Verifica se o motivo de desconto esta ativo para itens

@param		
@author  Varejo
@version P11.8
@since   11/09/2014
@return  lRet Existem dados na tabela MDT e esta ativo o tratamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRFDAtiv(nItemLine,cCodItem,cTesPad,nTotItem)

Local lRet		:= .T.
Local lMotDesIt	:= SuperGetMV("MV_LJMTDIT",,.T.)

If lMotDesIt .And. STDRsnDesc()
	STIExchangePanel( { || STIReasonD(nItemLine,cCodItem,cTesPad,nTotItem) } )
EndIf

Return lRet