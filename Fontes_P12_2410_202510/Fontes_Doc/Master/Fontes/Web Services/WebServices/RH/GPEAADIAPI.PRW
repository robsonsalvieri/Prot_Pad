#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEAADIAPI.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB 			 CHR ( 13 ) + CHR ( 10 )

/*
{Protheus.doc} additional
API de Controle de Adicionais dos Funcionarios                              
@author  Silvia Taguti
@since   17/03/2020
@version 12.1.27
*/

WSRESTFUL additional DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para controle das informações de Adicionais"
	WSDATA companyId	 	As Character
	WSDATA branchId	     	As Character
	WSDATA employeeId     	As Character
	WSDATA unhealthyDegree  As Character
	WSDATA additionalId 	As Character
	WSDATA dangerousness    As Character

	/*STR0002 "Metodo para alterar adicionais dos funcionarios"
	  STR0003 "/api/rh/v1/additional"
	  STR0004 "v1"
	*/
	//WSMETHOD PUT  DESCRIPTION OemToAnsi(STR0002) WSSYNTAX STR0003 PATH STR0003 PRODUCES 'application/json;charset=utf-8' TTALK STR0004

WSMETHOD PUT additionalId ;
  DESCRIPTION EncodeUTF8(STR0002) ; 
  WSSYNTAX "/api/rh/v1/additional/{additionalId}" ;
  PATH "/api/rh/v1/additional/{additionalId}" ;
  PRODUCES "application/json;charset=utf-8" ;
  TTALK "v1"

END WSRESTFUL

// Altera um adicional do funcionario
/*/{Protheus.doc} PUT
Método responsável pela alteração de adicionais dos funcionarios no Header do REST/JSON
@author  Silvia Taguti 
@since   17/03/2020
@version 12.1.27
@return return, return_description
/*/

WSMETHOD PUT additionalId WSREST additional

Local aUrlParam	:= ::aUrlParms
Local cJsonObj	:= "JsonObject():New()"
Local oItem		:= &cJsonObj
Local oItemDetail	:= &cJsonObj
Local cToken := Self:GetHeader('Authorization')

Local json as OBJECT
Local cBody As Character
Local cRecebe As Character
Local cId := ""

//Variaveis do corpo
Local cParEmp := ""
Local cParFil := ""
Local cParFun := ""
Local aParFun := {}

Local chave 		:= ""
Local lRetorno 		:= .F.
Local aRetorno 		:= {}
Local cFilPar 		:= ""
Local cEmpFun 		:= ""
Local cFilFun 		:= ""
Local cCodFun 		:= ""
Local cInsalub 		:= ""
Local cPericul 		:= ""
Local aCampos 		:= {}
Local cEmpAntBck 	:= cEmpAnt
Local cFilAntBck 	:= cFilAnt

Local nItem := 0

Private lMsHelpAuto := .T. // se .t. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F. //necessário a criação, pois sera atualizado quando houver alguma inconsistência nos parâmetros

BEGIN SEQUENCE

if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
		fSendMess(400,STR0006,.T.,400,STR0005,,) //"Informação addionalId ausente ou inválida."#"Erro na validação do recebimento da mensagem"
		lRetorno := .F.
		return (lRetorno)
else 
	chave := aUrlParam[1]
EndIf
	
	aRetorno := fValidaChave(chave)
	
	If (Len(aRetorno) == 0)
		fSendMess(400,STR0006,.T.,400,STR0005,,) //"Informação addionalId ausente ou inválida."#"Erro na validação do recebimento da mensagem"

		lRetorno := .F.
		return (lRetorno)
	EndIf
	
	json		:= JsonObject():New()
	cBody		:= Self:GetContent()
	lRetorno	:= .F.
	lCompact	:= .F. 
	cRecebe   := json:FromJSON(EncodeUTF8(NoAcento(cBody)))
		
	If cRecebe != Nil  .Or. Len(json:GetNames()) == 0  
		fSendMess(400,STR0007,.T.,400,STR0005,,) // "Não foi possível reconhecer o pacote recebido. Verifique a informação e envie novamente."
		return (lRetorno)
	EndIf

	aCampos := json:GetNames()

	If ! ValidaBody(aCampos,json)
		fSendMess(400,STR0007,.T.,400,STR0005,,) // "Não foi possível reconhecer o pacote recebido. Verifique a informação e envie novamente."
		return (lRetorno)
	EndIf

	For nItem:= 1 to Len(aCampos)
		
		If UPPER(aCampos[nItem]) $ "COMPANYID"
			cParEmp := json[aCampos[nItem]]		
		EndIf
		
		If UPPER(aCampos[nItem]) =="BRANCHID" 
			cParFil := json[aCampos[nItem]]
		EndIf

		If UPPER(aCampos[nItem]) =="EMPLOYEEID" 
			cParFun := json[aCampos[nItem]]
			aParFun := StrTokArr2(cParFun,"|",.T.) 
		EndIf	
		If UPPER(aCampos[nItem]) =="UNHEALTHYDEGREE" 
			cInsalub := json[aCampos[nItem]]
		EndIf	
		If UPPER(aCampos[nItem]) =="DANGEROUSNESS" 
			cPericul := json[aCampos[nItem]]
		EndIf	
		
	Next nItem

	cEmpFun := aRetorno[1]
	cFilFun := aRetorno[2]
	cCodFun := aRetorno[3]

	If cEmpAntBck <> cEmpFun .Or. cFilAntBck <> cFilFun
		fTrGrpGPE( cEmpFun, cFilFun, "SRA", "GPE" )
	EndIf

		lRet := fPutData( cFilFun, cCodFun, cInsalub, cPericul )

		If lRet
			cId := cEmpFun + ";" + cFilFun + ";" + cEmpFun+"|"+cFilFun+"|"+cCodFun
			cRetorno :=  fSendJson(json,cId)
			::SetResponse(cRetorno)
		ENDIF

	RECOVER

	   lRet := .F.
		ErrorBlock(bErrorBlock)
		fSendMess(500,oError:Description,.T.,500,STR0008,,) // "Ocorreu uma falha no retorno da informação."

END SEQUENCE

If cEmpAntBck <> cEmpFun .Or. cFilAntBck <> cFilFun
    fTrGrpGPE(cEmpAntBck, cFilAntBck)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  Silvia Taguti
@since   09/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

DEFAULT nCode := 500
DEFAULT cMessage := STR0009    //"Erro desconhecido no processo!"
DEFAULT lJson := .T.
DEFAULT nStatus := 500
Default cDetailMsg := STR0009  //"Erro desconhecido no processo!"
Default cHelpUrl := "https://tdn.totvs.com/x/BJuMHw"
DEFAULT aDetails := {}

	SetRestFault(nCode,EncodeUTF8(NoAcento(OemToAnsi(cMessage))),lJson,nStatus,EncodeUTF8(NoAcento(OemToAnsi(cDetailMsg))),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendJson
Gera as mensagens para o retorno REST/JSON
@author  Silvia Taguti
@since  12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendJson(ojson,cId)
Local cJson			:= ""
Local lcompact := .F.

	If Type("Self:GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(Self:GetHeader('Accept-Encoding') )        
		lCompact := .T.
	EndIf

	ojson["id"] := cId

	If(lCompact)    	
		cJson := fCompress(ojson)				
	Else
		cJson :=  FWJsonSerialize(ojson, .F., .F., .T.)   	
	Endif

Return (cJson)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compacta os dados do retorno solicitado
@author  Silvia Taguti
@since   12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := FWJsonSerialize(oObj,.T.,.T.)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif

Return cComp

/*/{Protheus.doc} fValidaChave
//Tratamento e validação de dados do Json
@author  Silvia Taguti
@since   17/03/2020
@version 12.1.27
@param json,object, variável de objeto que contém os dados de json
@return lRet, logical, variável que verifica se ocorreu erro ou não
/*/
Static Function fValidaChave(cChave)
Local aTemp := {}
Local aReto := {}
Local aErro := {}
Local aFunc     as ARRAY

aTemp := StrTokArr2(cChave,";",.T.)

If ( Len(aTemp) < 3)
	return (aErro)
EndIf

aReto := StrTokArr2(aTemp[3],"|",.T.)

If ( Len(aReto) < 3)
	return (aErro)
EndIf

//Verifica Empresa/Filial
If !FWFilExist(aReto[1],aReto[2])
	return (aErro)
EndIf

//Verifica Funcionario
aFunc := {}
aAdd(aFunc,aReto[1])
aAdd(aFunc,aReto[2])
aAdd(aFunc,aReto[3])

RESET ENVIRONMENT
RPCSetType(3)
PREPARE ENVIRONMENT EMPRESA aReto[1] FILIAL aReto[2] TABLES "SRA" MODULO "GPE"
DBSelectArea("SRA")
DBSetOrder(1)
If ! DBseek (aFunc[2]+aFunc[3])
	return (aErro)
Endif

Return (aReto)

/*/{Protheus.doc} fPutData
// Inclui/Altera dados na tabela.
@author Silvia Taguti
@since 13/03/2020
@return return, return_description
@param oEmpData, object, descricao
@param cBranchId, characters, descricao
@param cEmplId, characters, descricao
@param cBody, characters, descricao
/*/
Static Function fPutData(cBranchId, cEmplId, cInsalub, cPericuL )
	
	Local lRet 			:= .F.
	Local nHrMes		:= 0
	Local cPerEmp  		:= ""
    Local cInsEmp  		:= "" 
	Local cAdcPeri		:= ""
	Local cAdcInsa		:= ""
	
	Default cEmplId		:= ""
	Default cEmplId	:= ""
	Default cInsalub:= ""
	Default cPericul:= ""
		
		// Se não houver erros executa a alteração no banco
		Begin Transaction
			SRA->(DBSelectArea("SRA"))
			SRA->(DBSetOrder(1)) // Filial + Matrícula  
			
			// Recebe novos valores dos campos
			If SRA->(DbSeek( xFilial("SRA", cBranchId) + cEmplId ))
				
				nHrMes := SRA->RA_HRSMES
				
				RecLock("SRA", .F.)		
				
				If !Empty(cPericul)
					If cPericul == "1"
						cPerEmp	:= "2"
					Else	
						cPerEmp	:= "1"
					Endif
					cAdcPeri 		 := SRA->RA_ADCPERI
					
					SRA->RA_ADCPERI  := cPerEmp
					If  SRA->RA_HRSMES > 0 .And. cPerEmp == "2" 
						SRA->RA_PERICUL := SRA->RA_HRSMES
					ElseIf cPerEmp == "1" 
						SRA->RA_PERICUL := 0
					Endif
					
					fGravaSr9( "RA_ADCPERI" , cPerEmp ,cAdcPeri )
					
					lRet := .T.
					
				Endif		
				
				If !Empty(cInsalub)
					If cInsalub== "1"
						cInsEmp  := "2"
					ElseIf cInsalub== "2"
						cInsEmp  := "3"
					ElseIf cInsalub== "3"
						cInsEmp:= "4"
					else
						cInsEmp:= "1"	
					Endif
					
					cAdcInsa 		 := SRA->RA_ADCINS
					SRA->RA_ADCINS	 := cInsEmp
					fGravaSr9( "RA_ADCINS" , cInsEmp,cAdcInsa  )
					
					If  SRA->RA_HRSMES > 0 .And. Val(cInsEmp) >= 2 
						SRA->RA_INSMAX := SRA->RA_HRSMES
					ElseIf  Val(cInsEmp) <= 1
						SRA->RA_INSMAX := 0 
					Endif
					fGravaSr9( "RA_ADCINS" , cInsEmp,cAdcInsa  )
					
					lRet := .T.
					
				Endif
				
				SRA->( MsUnLock() )
				
			EndIF
			
		End Transaction
		
	If !lRet
		
		fSendMess(400,STR0010,.T.,400,STR0010,,) //"Erro na execucao da operacao"
		
	EndIf
	
Return lRet

/*/{Protheus.doc} ValidaBody
// Valida as informações recebidas no body da mensagem.
@author Wesley Alves Pereira
@since 03/06/2020
@return lReto,
@param aCampos, array, Array do corpo da mensagem
/*/

Static Function ValidaBody(aCampos,json)

Local lReto := .F.
Local nItem := 0
Local cEmpTemp := ""
Local cFilTemp := ""
Local cParFunc := ""
Local aParFunc := {}
Local cInsalub := ""
Local cPericul := ""

For nItem:= 1 to Len(aCampos)
		
	If UPPER(aCampos[nItem]) $ "COMPANYID"
		cEmpTemp := json[aCampos[nItem]]		
	EndIf
		
	If UPPER(aCampos[nItem]) =="BRANCHID" 
		cFilTemp := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="EMPLOYEEID" 
		cParFunc := json[aCampos[nItem]]
		aParFunc := StrTokArr2(cParFunc,"|",.T.) 
	EndIf	
	
	If UPPER(aCampos[nItem]) =="UNHEALTHYDEGREE" 
		cInsalub := json[aCampos[nItem]]
	EndIf	
	
	If UPPER(aCampos[nItem]) =="DANGEROUSNESS" 
		cPericul := json[aCampos[nItem]]
	EndIf	
		
Next nItem

If ( !Empty(cEmpTemp) .AND. !Empty(cFilTemp))
	If !FWFilExist(cEmpTemp,cFilTemp)
		Return (lReto)
	EndIf
EndIf

if ( !Empty(aParFunc))

	If ( Len ( aParFunc ) <> 3 )
		Return (lReto)
	Else
	
		If !FWFilExist(aParFunc[1],aParFunc[2])
			Return (lReto)
		EndIf
	
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA aParFunc[1] FILIAL aParFunc[2] TABLES "SRA" MODULO "GPE"
		DBSelectArea("SRA")
		DBSetOrder(1)
		If ! DBseek (aParFunc[2]+aParFunc[3])
			Return (lReto)
		Endif
	EndIf
EndIf

If ! Empty(cPericul) 
	If ( "2" <> Alltrim(cPericul) .AND. "1" <> Alltrim(cPericul) ) 
		Return (lReto)
	EndIf
EndIf

If ! Empty(cInsalub) 
	If ( "3" <> Alltrim(cInsalub) .AND. "2" <> Alltrim(cInsalub) .AND. "1" <> Alltrim(cInsalub) .AND. "0" <> Alltrim(cInsalub) )
		Return (lReto)
	EndIf
EndIf



lReto := .T.

Return (lReto)
