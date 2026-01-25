#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFSPNFE.CH"                                     
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"  
#INCLUDE "RPTDEF.CH"  
#INCLUDE "PARMTYPE.CH"    
#INCLUDE "FILEIO.CH"    
#INCLUDE "APWEBSRV.CH"                                 

#DEFINE TAMMAXXML 400000 //- Tamanho maximo do XML em  bytes       

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRIdEnt
Obtem o codigo da entidade apos enviar o post para o Totvs Service

@author Evandro dos Santos Oliveira
@since 21/11/2013
@version 1.0

@param lMatriz - Determina se deve posicionar na Filial Matriz
@param lExibeMsg - Determina se a rotina deve exibir uma caixa de alerta
				 caso ocorro erro na rotina
@param cMsgErro - Mesagem de Erro (caso houver)
@param lValidErpOk - Indica se não houve erro de validação do lado do ERP (.t. - nao ha erro) (referencia)
@param lTSSOk - Indica se houve erro do lado do TSS. (referencia) (.t. - não ha erros)

@return  cIdEnt - Código da Entidade
/*/
//-------------------------------------------------------------------
Function TAFRIdEnt(lMatriz,lExibeMsg,cMsgErro,lValidErpOk,lTSSOk,lEsocial, lApi, cUser, lErroToken)
Return(GetIdEnt(lMatriz,.T.,lExibeMsg,@cMsgErro,@lValidErpOk,@lTSSOk,lEsocial,lApi, cUser, @lErroToken))


//-------------------------------------------------------------------
/*/{Protheus.doc} GetIdEnt
Obtem o codigo da entidade apos enviar o post para o Totvs Service
@author Evandro dos Santos Oliveira
@since 21/11/2013
@version 1.0

@param lMatriz - Determina se deve posicionar na Filial Matriz
@param lExibeMsg - Determina se a rotina deve exibir uma caixa de alerta
				 caso ocorro erro na rotina
@param cMsgErro - Mesagem de Erro (caso houver)
@param lValidErpOk - Indica se não houve erro de validação do lado do ERP (.t. - nao ha erro) (referencia)
@param lTSSOk - Indica se houve erro do lado do TSS. (referencia) (.t. - não ha erros)
@param lEsocial - 
@param lApi - Indica se é chamada da API
@param cUser - Indica o usuário
@param lErroToken - Indica erro no Token

@return  cIdEnt - Código da Entidade
/*/
//-------------------------------------------------------------------
Static Function GetIdEnt(lMatriz,lNewId,lExibeMsg,cMsgErro,lValidErpOk,lTSSOk,lEsocial,lApi, cUser, lErroToken)

	Local aArea  		:= SM0->(GetArea())
	Local cFilBack		:= cFilAnt
	Local cIdEnt 		:= ""
	Local cURL   		:= ""
	Local oWs			:= Nil
	Local lUsaGesEmp 	:= IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
	Local lJob 			:= IsBlind() 
	Local cProdRural 	:= ""
	Local aProdRural 	:= {}
	Local cGetIdEnt     := "GetIdEntTafspnfe"

	Default lMatriz 	:= .F.
	Default lNewId 		:= .F.
	Default lExibeMsg 	:= .T.
	Default cMsgErro 	:= ""
	Default lValidErpOk := .F.
	Default lTSSOk 		:= .F. 
	Default lEsocial    := .F.
	Default lApi  		:= .F.
	Default cUser 		:= __cUserId
	Default lErroToken	:= .F.

	If FindFunction( "VProdRural" ) 

		aProdRural := VProdRural( ,,cGetIdEnt)

		If Len( aProdRural ) > 0
			cProdRural := aProdRural[2]
		EndIf

	EndIf

	If FindFunction("TafGetUrlTSS")
		cURL := PadR(TafGetUrlTSS(),250)
	Else
		cURL := PadR(GetNewPar("MV_TAFSURL","http://"),250)
	EndIf
	cURL := AllTrim(cURL) 

	If lMatriz
		lValidErpOk := TAFChgFil(@cMsgErro)
	Else
		lValidErpOk := .T. 
	EndIf

	If lValidErpOk
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o codigo da entidade                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lNewId
			// Criação das propriedades com classe embarcada nesse fonte
			oWS := WSTAFSPEDADM():New()
		Else
			oWS := WSSPEDADM():New()	
		EndIf	
		oWS:cUSERTOKEN := "TOTVS"
			
		/*
		Realiza tratamento para criação de Entidade no TSS com CPF e manter 
		Entidade com CNPJ para envio de NFE na mesma filial.
		*/
		If !Empty(cProdRural) .And. lEsocial	
			oWS:OWSEMPRESA:cCPF    := cProdRural
		Else
		oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
			oWS:OWSEMPRESA:cCPF    := IIF(SM0->M0_TPINSC==3,AllTrim(SM0->M0_CGC),"")
		oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
		EndIf
		oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
		oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
		oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
		oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
		oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
		oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
		oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
		oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
		oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
		oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
		oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
		oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
		oWS:oWSEMPRESA:cCEP_CP     := Nil
		oWS:oWSEMPRESA:cCP         := Nil
		oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
		oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
		oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
		oWS:oWSEMPRESA:cEMAIL  		 := RetEmailAPI(cUser)  
		oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
		oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
		oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cINDSITESP  := ""
		oWS:oWSEMPRESA:cID_MATRIZ  := ""

		If lUsaGesEmp 
			oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
		EndIf

		If lNewId
			oWS:oWSOUTRASINSCRICOES:oWSInscricao := TAFADM_ARRAYOFSPED_GENERICSTRUCT():New()
		Else
			oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
		EndIf
		oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

		// Tratamento para inclusao do campo de emissor/responsavel
		If TAFColumnPos( "C1E_CNPJTR" )
			// Verifica a função do client do SPEDADM(sped_wscadm.prw) 
			// e protege para a nova propriedade não gerar error log.
			If lNewId .Or. (FindFunction("U_TAFSPEDADM") .And. U_TAFSPEDADM() >= "20180227")
				oWS:oWSEMPRESA:cUPDINSCRTR	:= "S"
			Else
				// Se for chamado do wizardo, apresenta mensagem
				If IsInCallStack("TAFAWizd")
					If lJob
						TafConOut("A versão dos programas de uso do TSS estão desatualizadas.")
					Else
						Aviso("Configuração TSS","A versão dos programas de uso do TSS estão desatualizadas.",{STR0009},2)
					EndIf			
				EndIf	
			EndIf

			oWS:oWSEMPRESA:cINSCRTRA   	:= GetInscTra()
		EndIf

		If oWs:ADMEMPRESAS()
			cIdEnt  := oWs:cADMEMPRESASRESULT
			lTSSOk := .T. 
		Else
			// Retirada a recursividade desnecessária.
			// cIdEnt := GetIdEnt( lMatriz, .F. )	
			//Tratamento para mensagens mais amigáveis
			cMsgErro := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			If "WSCERR044" $ cMsgErro
				cMsgErro := "Falha ao tentar se conectar ao TSS."+CRLF+CRLF
				cMsgErro += "Configurações usadas:"+CRLF
				cMsgErro += "Url Totvs Service SOA: "+ AllTrim(cURL) +CRLF+CRLF
				cMsgErro += "Verifique as configurações do servidor e se o mesmo está ativo."
			EndIf

			TAFVldTokenTSS(@cMsgErro, @lErroToken, GetWscError(2)) 	

			If lExibeMsg .And. !lJob
				MsgInfo(cMsgErro, "Conexão TSS - Totvs Service SOA")
			Else
				TafConOut(cMsgErro)
			EndIf
		EndIf
		
		FreeObj(oWS)
		oWS := Nil 
		
	EndIf 

	RestArea(aArea)
	cFilAnt := cFilBack

Return cIdEnt 

//---------------------------------------------------------------------------
/*/{Protheus.doc} GetInscTra
Funcao que coleta informação do cadastro de complemento de empresas para informar o CNPJ do transmissor quando for diferente do empregador

@author Roberto Souza
@since 20/12/2017
@version 1.0	

@return cResult - CNPJ do Transmissor, se houver 
/*/
//---------------------------------------------------------------------------- 
Static Function GetInscTra()
	Local cInfo := ""
	Local aArea := GetArea()
	
	DbSelectArea("C1E")
	DbSetOrder(3)

	If C1E->( DbSeek( xFilial( "C1E" ) + PadR( SM0->M0_CODFIL , TamSX3( 'C1E_FILTAF' )[1] ) + '1' ) )
		cInfo := C1E->C1E_CNPJTR //"CNPJ" do transmissor
	EndIf
	
	RestArea( aArea )
Return( cInfo )

//---------------------------------------------------------------------------
/*/{Protheus.doc}  TAFIdNfe
Retorna a Chave Eletronica da NFe

@author Evandro dos Santos Oliveira
@since 23/05/2014
@version 1.0	

@param cXml   - Xml na NFe
@param cAttId - Id do atributo a ser recuperado

@return cUri  - Chave Eletronica
/*/
//---------------------------------------------------------------------------- 
Function TAFIdNfe(cXML,cAttId)  

	Local nAt  := 0
	Local cURI := ""
	Local nSoma:= Len(cAttId)+2
	
	nAt := At(cAttId+'=',cXml)
	cURI:= SubStr(cXml,nAt+nSoma)
	nAt := At('"',cURI)
	If nAt == 0
		nAt := At("'",cURI)
	EndIf
	cURI:= SubStr(cURI,1,nAt-1) 
	
Return(cUri)  

//*********************************************************************************** 
//*********************************************************************************** 
//*******                 ********       ***********            ********************* 
//*******                 *******         **********            ********************* 
//*************     ************     *     *********     **************************** 
//*************     ***********     ***     ********     **************************** 
//*************     **********               *******         ************************ 
//*************     *********     *******     ******     **************************** 
//*************     ********     *********     *****     **************************** 
//*************     *******     ***********     ****     **************************** 
//*********************************************************************************** 
//*********************************************************************************** 
/* ===============================================================================
WSDL Location    http://localhost:8080/SPEDADM.apw?WSDL
Gerado em        02/27/18 11:30:26
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSTAFSPEDADM
------------------------------------------------------------------------------- */

WSCLIENT WSTAFSPEDADM

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ADDENTFILE
	WSMETHOD ADMEMISS
	WSMETHOD ADMEMPRESAS
	WSMETHOD CONSULTEMISS
	WSMETHOD ENTIDADEATIVA
	WSMETHOD ENTIDADECLEAR
	WSMETHOD GETADMEMPRESAS
	WSMETHOD GETADMEMPRESASID
	WSMETHOD GETINFOPEDNFE
	WSMETHOD GETPASSENT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSERTOKEN                AS string
	WSDATA   cKEYPASS                  AS string
	WSDATA   cCNPJ                     AS string
	WSDATA   cNOME                     AS string
	WSDATA   cADDENTFILERESULT         AS string
	WSDATA   cID_ENT                   AS string
	WSDATA   cCPF                      AS string
	WSDATA   cIE                       AS string
	WSDATA   cUF                       AS string
	WSDATA   nOPC                      AS integer
	WSDATA   oWSARQUIVO                AS TAFADM_ARQUIVOAUT
	WSDATA   cPARTNER                  AS string
	WSDATA   oWSADMEMISSRESULT         AS TAFADM_AUTEMP_EMISSAO
	WSDATA   oWSEMPRESA                AS TAFADM_SPED_ENTIDADE
	WSDATA   oWSOUTRASINSCRICOES       AS TAFADM_SPED_ENTIDADEREFERENCIAL
	WSDATA   cADMEMPRESASRESULT        AS string
	WSDATA   cPEDIDO                   AS string
	WSDATA   cIDINICIAL                AS string
	WSDATA   cIDFINAL                  AS string
	WSDATA   oWSCONSULTEMISSRESULT     AS TAFADM_ARRAYOFCONTROLENFEEMISS
	WSDATA   cENTIDADEATIVARESULT      AS string
	WSDATA   cENTIDADECLEARRESULT      AS string
	WSDATA   cIDEMPRESA                AS string
	WSDATA   oWSGETADMEMPRESASRESULT   AS TAFADM_ARRAYOFSPED_ENTIDADE
	WSDATA   cGETADMEMPRESASIDRESULT   AS string
	WSDATA   oWSGETINFOPEDNFERESULT    AS TAFADM_PEDIDOSNFE
	WSDATA   cNEWPASS                  AS string
	WSDATA   cGETPASSENTRESULT         AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSARQUIVOAUT             AS TAFADM_ARQUIVOAUT
	WSDATA   oWSSPED_ENTIDADE          AS TAFADM_SPED_ENTIDADE
	WSDATA   oWSSPED_ENTIDADEREFERENCIAL AS TAFADM_SPED_ENTIDADEREFERENCIAL

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTAFSPEDADM
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20171213 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTAFSPEDADM
	::oWSARQUIVO         := TAFADM_ARQUIVOAUT():New()
	::oWSADMEMISSRESULT  := TAFADM_AUTEMP_EMISSAO():New()
	::oWSEMPRESA         := TAFADM_SPED_ENTIDADE():New()
	::oWSOUTRASINSCRICOES := TAFADM_SPED_ENTIDADEREFERENCIAL():New()
	::oWSCONSULTEMISSRESULT := TAFADM_ARRAYOFCONTROLENFEEMISS():New()
	::oWSGETADMEMPRESASRESULT := TAFADM_ARRAYOFSPED_ENTIDADE():New()
	::oWSGETINFOPEDNFERESULT := TAFADM_PEDIDOSNFE():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSARQUIVOAUT      := ::oWSARQUIVO
	::oWSSPED_ENTIDADE   := ::oWSEMPRESA
	::oWSSPED_ENTIDADEREFERENCIAL := ::oWSOUTRASINSCRICOES
Return

WSMETHOD RESET WSCLIENT WSTAFSPEDADM
	::cUSERTOKEN         := NIL 
	::cKEYPASS           := NIL 
	::cCNPJ              := NIL 
	::cNOME              := NIL 
	::cADDENTFILERESULT  := NIL 
	::cID_ENT            := NIL 
	::cCPF               := NIL 
	::cIE                := NIL 
	::cUF                := NIL 
	::nOPC               := NIL 
	::oWSARQUIVO         := NIL 
	::cPARTNER           := NIL 
	::oWSADMEMISSRESULT  := NIL 
	::oWSEMPRESA         := NIL 
	::oWSOUTRASINSCRICOES := NIL 
	::cADMEMPRESASRESULT := NIL 
	::cPEDIDO            := NIL 
	::cIDINICIAL         := NIL 
	::cIDFINAL           := NIL 
	::oWSCONSULTEMISSRESULT := NIL 
	::cENTIDADEATIVARESULT := NIL 
	::cENTIDADECLEARRESULT := NIL 
	::cIDEMPRESA         := NIL 
	::oWSGETADMEMPRESASRESULT := NIL 
	::cGETADMEMPRESASIDRESULT := NIL 
	::oWSGETINFOPEDNFERESULT := NIL 
	::cNEWPASS           := NIL 
	::cGETPASSENTRESULT  := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSARQUIVOAUT      := NIL
	::oWSSPED_ENTIDADE   := NIL
	::oWSSPED_ENTIDADEREFERENCIAL := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTAFSPEDADM

	Local oClone := WSTAFSPEDADM():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERTOKEN    := ::cUSERTOKEN
	oClone:cKEYPASS      := ::cKEYPASS
	oClone:cCNPJ         := ::cCNPJ
	oClone:cNOME         := ::cNOME
	oClone:cADDENTFILERESULT := ::cADDENTFILERESULT
	oClone:cID_ENT       := ::cID_ENT
	oClone:cCPF          := ::cCPF
	oClone:cIE           := ::cIE
	oClone:cUF           := ::cUF
	oClone:nOPC          := ::nOPC
	oClone:oWSARQUIVO    :=  IIF(::oWSARQUIVO = NIL , NIL ,::oWSARQUIVO:Clone() )
	oClone:cPARTNER      := ::cPARTNER
	oClone:oWSADMEMISSRESULT :=  IIF(::oWSADMEMISSRESULT = NIL , NIL ,::oWSADMEMISSRESULT:Clone() )
	oClone:oWSEMPRESA    :=  IIF(::oWSEMPRESA = NIL , NIL ,::oWSEMPRESA:Clone() )
	oClone:oWSOUTRASINSCRICOES :=  IIF(::oWSOUTRASINSCRICOES = NIL , NIL ,::oWSOUTRASINSCRICOES:Clone() )
	oClone:cADMEMPRESASRESULT := ::cADMEMPRESASRESULT
	oClone:cPEDIDO       := ::cPEDIDO
	oClone:cIDINICIAL    := ::cIDINICIAL
	oClone:cIDFINAL      := ::cIDFINAL
	oClone:oWSCONSULTEMISSRESULT :=  IIF(::oWSCONSULTEMISSRESULT = NIL , NIL ,::oWSCONSULTEMISSRESULT:Clone() )
	oClone:cENTIDADEATIVARESULT := ::cENTIDADEATIVARESULT
	oClone:cENTIDADECLEARRESULT := ::cENTIDADECLEARRESULT
	oClone:cIDEMPRESA    := ::cIDEMPRESA
	oClone:oWSGETADMEMPRESASRESULT :=  IIF(::oWSGETADMEMPRESASRESULT = NIL , NIL ,::oWSGETADMEMPRESASRESULT:Clone() )
	oClone:cGETADMEMPRESASIDRESULT := ::cGETADMEMPRESASIDRESULT
	oClone:oWSGETINFOPEDNFERESULT :=  IIF(::oWSGETINFOPEDNFERESULT = NIL , NIL ,::oWSGETINFOPEDNFERESULT:Clone() )
	oClone:cNEWPASS      := ::cNEWPASS
	oClone:cGETPASSENTRESULT := ::cGETPASSENTRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSARQUIVOAUT := oClone:oWSARQUIVO
	oClone:oWSSPED_ENTIDADE := oClone:oWSEMPRESA
	oClone:oWSSPED_ENTIDADEREFERENCIAL := oClone:oWSOUTRASINSCRICOES
Return oClone

// WSDL Method ADDENTFILE of Service WSTAFSPEDADM

WSMETHOD ADDENTFILE WSSEND cUSERTOKEN,cKEYPASS,cCNPJ,cNOME WSRECEIVE cADDENTFILERESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ADDENTFILE xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("KEYPASS", ::cKEYPASS, cKEYPASS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NOME", ::cNOME, cNOME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ADDENTFILE>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/ADDENTFILE",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::cADDENTFILERESULT  :=  WSAdvValue( oXmlRet,"_ADDENTFILERESPONSE:_ADDENTFILERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ADMEMISS of Service WSTAFSPEDADM

WSMETHOD ADMEMISS WSSEND cUSERTOKEN,cID_ENT,cCNPJ,cCPF,cIE,cUF,nOPC,oWSARQUIVO,cPARTNER WSRECEIVE oWSADMEMISSRESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ADMEMISS xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPF", ::cCPF, cCPF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IE", ::cIE, cIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("UF", ::cUF, cUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OPC", ::nOPC, nOPC , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ARQUIVO", ::oWSARQUIVO, oWSARQUIVO , "ARQUIVOAUT", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PARTNER", ::cPARTNER, cPARTNER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ADMEMISS>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/ADMEMISS",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::oWSADMEMISSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_ADMEMISSRESPONSE:_ADMEMISSRESULT","AUTEMP_EMISSAO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ADMEMPRESAS of Service WSTAFSPEDADM

WSMETHOD ADMEMPRESAS WSSEND cUSERTOKEN,oWSEMPRESA,oWSOUTRASINSCRICOES WSRECEIVE cADMEMPRESASRESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ADMEMPRESAS xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPRESA", ::oWSEMPRESA, oWSEMPRESA , "SPED_ENTIDADE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OUTRASINSCRICOES", ::oWSOUTRASINSCRICOES, oWSOUTRASINSCRICOES , "SPED_ENTIDADEREFERENCIAL", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ADMEMPRESAS>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/ADMEMPRESAS",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::cADMEMPRESASRESULT :=  WSAdvValue( oXmlRet,"_ADMEMPRESASRESPONSE:_ADMEMPRESASRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONSULTEMISS of Service WSTAFSPEDADM

WSMETHOD CONSULTEMISS WSSEND cUSERTOKEN,cID_ENT,cPEDIDO,cIDINICIAL,cIDFINAL WSRECEIVE oWSCONSULTEMISSRESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSULTEMISS xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PEDIDO", ::cPEDIDO, cPEDIDO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDINICIAL", ::cIDINICIAL, cIDINICIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDFINAL", ::cIDFINAL, cIDFINAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONSULTEMISS>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/CONSULTEMISS",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::oWSCONSULTEMISSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTEMISSRESPONSE:_CONSULTEMISSRESULT","ARRAYOFCONTROLENFEEMISS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ENTIDADEATIVA of Service WSTAFSPEDADM

WSMETHOD ENTIDADEATIVA WSSEND cUSERTOKEN,cID_ENT,nOPC WSRECEIVE cENTIDADEATIVARESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ENTIDADEATIVA xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OPC", ::nOPC, nOPC , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ENTIDADEATIVA>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/ENTIDADEATIVA",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::cENTIDADEATIVARESULT :=  WSAdvValue( oXmlRet,"_ENTIDADEATIVARESPONSE:_ENTIDADEATIVARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ENTIDADECLEAR of Service WSTAFSPEDADM

WSMETHOD ENTIDADECLEAR WSSEND cUSERTOKEN,cID_ENT WSRECEIVE cENTIDADECLEARRESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ENTIDADECLEAR xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ENTIDADECLEAR>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/ENTIDADECLEAR",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::cENTIDADECLEARRESULT :=  WSAdvValue( oXmlRet,"_ENTIDADECLEARRESPONSE:_ENTIDADECLEARRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETADMEMPRESAS of Service WSTAFSPEDADM

WSMETHOD GETADMEMPRESAS WSSEND cUSERTOKEN,cCNPJ,cCPF,cIE,cUF,cIDEMPRESA WSRECEIVE oWSGETADMEMPRESASRESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETADMEMPRESAS xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPF", ::cCPF, cCPF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IE", ::cIE, cIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("UF", ::cUF, cUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDEMPRESA", ::cIDEMPRESA, cIDEMPRESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETADMEMPRESAS>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/GETADMEMPRESAS",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::oWSGETADMEMPRESASRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETADMEMPRESASRESPONSE:_GETADMEMPRESASRESULT","ARRAYOFSPED_ENTIDADE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETADMEMPRESASID of Service WSTAFSPEDADM

WSMETHOD GETADMEMPRESASID WSSEND cUSERTOKEN,cCNPJ,cCPF,cIE,cUF,cIDEMPRESA WSRECEIVE cGETADMEMPRESASIDRESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETADMEMPRESASID xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPF", ::cCPF, cCPF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IE", ::cIE, cIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("UF", ::cUF, cUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDEMPRESA", ::cIDEMPRESA, cIDEMPRESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETADMEMPRESASID>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/GETADMEMPRESASID",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::cGETADMEMPRESASIDRESULT :=  WSAdvValue( oXmlRet,"_GETADMEMPRESASIDRESPONSE:_GETADMEMPRESASIDRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETINFOPEDNFE of Service WSTAFSPEDADM

WSMETHOD GETINFOPEDNFE WSSEND cUSERTOKEN,cID_ENT,cKEYPASS WSRECEIVE oWSGETINFOPEDNFERESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETINFOPEDNFE xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("KEYPASS", ::cKEYPASS, cKEYPASS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETINFOPEDNFE>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/GETINFOPEDNFE",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::oWSGETINFOPEDNFERESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETINFOPEDNFERESPONSE:_GETINFOPEDNFERESULT","PEDIDOSNFE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPASSENT of Service WSTAFSPEDADM

WSMETHOD GETPASSENT WSSEND cUSERTOKEN,cID_ENT,cNEWPASS,nOPC WSRECEIVE cGETPASSENTRESULT WSCLIENT WSTAFSPEDADM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPASSENT xmlns="http://webservices.totvs.com.br/spedadm.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NEWPASS", ::cNEWPASS, cNEWPASS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OPC", ::nOPC, nOPC , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETPASSENT>"

oXmlRet := SvcSoapCall(	Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/spedadm.apw/GETPASSENT",; 
	"DOCUMENT","http://webservices.totvs.com.br/spedadm.apw",,"1.031217",; 
	"http://localhost:8080/SPEDADM.apw")

::Init()
::cGETPASSENTRESULT  :=  WSAdvValue( oXmlRet,"_GETPASSENTRESPONSE:_GETPASSENTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARQUIVOAUT

WSSTRUCT TAFADM_ARQUIVOAUT
	WSDATA   cCNPJ                     AS string OPTIONAL
	WSDATA   cCPF                      AS string OPTIONAL
	WSDATA   dDATAPED                  AS date
	WSDATA   cIE                       AS string OPTIONAL
	WSDATA   cPEDIDO                   AS string
	WSDATA   nQTDPED                   AS integer
	WSDATA   cUF                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_ARQUIVOAUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_ARQUIVOAUT
Return

WSMETHOD CLONE WSCLIENT TAFADM_ARQUIVOAUT
	Local oClone := TAFADM_ARQUIVOAUT():NEW()
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCPF                 := ::cCPF
	oClone:dDATAPED             := ::dDATAPED
	oClone:cIE                  := ::cIE
	oClone:cPEDIDO              := ::cPEDIDO
	oClone:nQTDPED              := ::nQTDPED
	oClone:cUF                  := ::cUF
Return oClone

WSMETHOD SOAPSEND WSCLIENT TAFADM_ARQUIVOAUT
	Local cSoap := ""
	cSoap += WSSoapValue("CNPJ", ::cCNPJ, ::cCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CPF", ::cCPF, ::cCPF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATAPED", ::dDATAPED, ::dDATAPED , "date", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IE", ::cIE, ::cIE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PEDIDO", ::cPEDIDO, ::cPEDIDO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QTDPED", ::nQTDPED, ::nQTDPED , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UF", ::cUF, ::cUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure AUTEMP_EMISSAO

WSSTRUCT TAFADM_AUTEMP_EMISSAO
	WSDATA   cCNPJ                     AS string OPTIONAL
	WSDATA   cCPF                      AS string OPTIONAL
	WSDATA   cID_ENT                   AS string OPTIONAL
	WSDATA   cIE                       AS string OPTIONAL
	WSDATA   nQTDE                     AS integer OPTIONAL
	WSDATA   nSALDO                    AS integer OPTIONAL
	WSDATA   cUF                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_AUTEMP_EMISSAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_AUTEMP_EMISSAO
Return

WSMETHOD CLONE WSCLIENT TAFADM_AUTEMP_EMISSAO
	Local oClone := TAFADM_AUTEMP_EMISSAO():NEW()
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCPF                 := ::cCPF
	oClone:cID_ENT              := ::cID_ENT
	oClone:cIE                  := ::cIE
	oClone:nQTDE                := ::nQTDE
	oClone:nSALDO               := ::nSALDO
	oClone:cUF                  := ::cUF
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TAFADM_AUTEMP_EMISSAO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCPF               :=  WSAdvValue( oResponse,"_CPF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cID_ENT            :=  WSAdvValue( oResponse,"_ID_ENT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIE                :=  WSAdvValue( oResponse,"_IE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nQTDE              :=  WSAdvValue( oResponse,"_QTDE","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::nSALDO             :=  WSAdvValue( oResponse,"_SALDO","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cUF                :=  WSAdvValue( oResponse,"_UF","string",NIL,"Property cUF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SPED_ENTIDADEREFERENCIAL

WSSTRUCT TAFADM_SPED_ENTIDADEREFERENCIAL
	WSDATA   oWSINSCRICAO              AS TAFADM_ARRAYOFSPED_GENERICSTRUCT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_SPED_ENTIDADEREFERENCIAL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_SPED_ENTIDADEREFERENCIAL
Return

WSMETHOD CLONE WSCLIENT TAFADM_SPED_ENTIDADEREFERENCIAL
	Local oClone := TAFADM_SPED_ENTIDADEREFERENCIAL():NEW()
	oClone:oWSINSCRICAO         := IIF(::oWSINSCRICAO = NIL , NIL , ::oWSINSCRICAO:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT TAFADM_SPED_ENTIDADEREFERENCIAL
	Local cSoap := ""
	cSoap += WSSoapValue("INSCRICAO", ::oWSINSCRICAO, ::oWSINSCRICAO , "ARRAYOFSPED_GENERICSTRUCT", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFCONTROLENFEEMISS

WSSTRUCT TAFADM_ARRAYOFCONTROLENFEEMISS
	WSDATA   oWSCONTROLENFEEMISS       AS TAFADM_CONTROLENFEEMISS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_ARRAYOFCONTROLENFEEMISS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_ARRAYOFCONTROLENFEEMISS
	::oWSCONTROLENFEEMISS  := {} // Array Of  TAFADM_CONTROLENFEEMISS():New()
Return

WSMETHOD CLONE WSCLIENT TAFADM_ARRAYOFCONTROLENFEEMISS
	Local oClone := TAFADM_ARRAYOFCONTROLENFEEMISS():NEW()
	oClone:oWSCONTROLENFEEMISS := NIL
	If ::oWSCONTROLENFEEMISS <> NIL 
		oClone:oWSCONTROLENFEEMISS := {}
		aEval( ::oWSCONTROLENFEEMISS , { |x| aadd( oClone:oWSCONTROLENFEEMISS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TAFADM_ARRAYOFCONTROLENFEEMISS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CONTROLENFEEMISS","CONTROLENFEEMISS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCONTROLENFEEMISS , TAFADM_CONTROLENFEEMISS():New() )
			::oWSCONTROLENFEEMISS[len(::oWSCONTROLENFEEMISS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSPED_ENTIDADE

WSSTRUCT TAFADM_ARRAYOFSPED_ENTIDADE
	WSDATA   oWSSPED_ENTIDADE          AS TAFADM_SPED_ENTIDADE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_ARRAYOFSPED_ENTIDADE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_ARRAYOFSPED_ENTIDADE
	::oWSSPED_ENTIDADE     := {} // Array Of  TAFADM_SPED_ENTIDADE():New()
Return

WSMETHOD CLONE WSCLIENT TAFADM_ARRAYOFSPED_ENTIDADE
	Local oClone := TAFADM_ARRAYOFSPED_ENTIDADE():NEW()
	oClone:oWSSPED_ENTIDADE := NIL
	If ::oWSSPED_ENTIDADE <> NIL 
		oClone:oWSSPED_ENTIDADE := {}
		aEval( ::oWSSPED_ENTIDADE , { |x| aadd( oClone:oWSSPED_ENTIDADE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TAFADM_ARRAYOFSPED_ENTIDADE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SPED_ENTIDADE","SPED_ENTIDADE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSPED_ENTIDADE , TAFADM_SPED_ENTIDADE():New() )
			::oWSSPED_ENTIDADE[len(::oWSSPED_ENTIDADE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure PEDIDOSNFE

WSSTRUCT TAFADM_PEDIDOSNFE
	WSDATA   oWSPEDIDOS                AS TAFADM_ARRAYOFENTPEDNFE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_PEDIDOSNFE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_PEDIDOSNFE
Return

WSMETHOD CLONE WSCLIENT TAFADM_PEDIDOSNFE
	Local oClone := TAFADM_PEDIDOSNFE():NEW()
	oClone:oWSPEDIDOS           := IIF(::oWSPEDIDOS = NIL , NIL , ::oWSPEDIDOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TAFADM_PEDIDOSNFE
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PEDIDOS","ARRAYOFENTPEDNFE",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSPEDIDOS := TAFADM_ARRAYOFENTPEDNFE():New()
		::oWSPEDIDOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFSPED_GENERICSTRUCT

WSSTRUCT TAFADM_ARRAYOFSPED_GENERICSTRUCT
	WSDATA   oWSSPED_GENERICSTRUCT     AS TAFADM_SPED_GENERICSTRUCT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_ARRAYOFSPED_GENERICSTRUCT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_ARRAYOFSPED_GENERICSTRUCT
	::oWSSPED_GENERICSTRUCT := {} // Array Of  TAFADM_SPED_GENERICSTRUCT():New()
Return

WSMETHOD CLONE WSCLIENT TAFADM_ARRAYOFSPED_GENERICSTRUCT
	Local oClone := TAFADM_ARRAYOFSPED_GENERICSTRUCT():NEW()
	oClone:oWSSPED_GENERICSTRUCT := NIL
	If ::oWSSPED_GENERICSTRUCT <> NIL 
		oClone:oWSSPED_GENERICSTRUCT := {}
		aEval( ::oWSSPED_GENERICSTRUCT , { |x| aadd( oClone:oWSSPED_GENERICSTRUCT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT TAFADM_ARRAYOFSPED_GENERICSTRUCT
	Local cSoap := ""
	aEval( ::oWSSPED_GENERICSTRUCT , {|x| cSoap := cSoap  +  WSSoapValue("SPED_GENERICSTRUCT", x , x , "SPED_GENERICSTRUCT", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure CONTROLENFEEMISS

WSSTRUCT TAFADM_CONTROLENFEEMISS
	WSDATA   cCNPJDEST                 AS string
	WSDATA   dDATE_NFE                 AS date
	WSDATA   nERROS                    AS integer
	WSDATA   cNFE_ID                   AS string
	WSDATA   cPED_DPEC                 AS string
	WSDATA   cPED_NFE                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_CONTROLENFEEMISS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_CONTROLENFEEMISS
Return

WSMETHOD CLONE WSCLIENT TAFADM_CONTROLENFEEMISS
	Local oClone := TAFADM_CONTROLENFEEMISS():NEW()
	oClone:cCNPJDEST            := ::cCNPJDEST
	oClone:dDATE_NFE            := ::dDATE_NFE
	oClone:nERROS               := ::nERROS
	oClone:cNFE_ID              := ::cNFE_ID
	oClone:cPED_DPEC            := ::cPED_DPEC
	oClone:cPED_NFE             := ::cPED_NFE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TAFADM_CONTROLENFEEMISS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCNPJDEST          :=  WSAdvValue( oResponse,"_CNPJDEST","string",NIL,"Property cCNPJDEST as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dDATE_NFE          :=  WSAdvValue( oResponse,"_DATE_NFE","date",NIL,"Property dDATE_NFE as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::nERROS             :=  WSAdvValue( oResponse,"_ERROS","integer",NIL,"Property nERROS as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNFE_ID            :=  WSAdvValue( oResponse,"_NFE_ID","string",NIL,"Property cNFE_ID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPED_DPEC          :=  WSAdvValue( oResponse,"_PED_DPEC","string",NIL,"Property cPED_DPEC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPED_NFE           :=  WSAdvValue( oResponse,"_PED_NFE","string",NIL,"Property cPED_NFE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SPED_ENTIDADE

WSSTRUCT TAFADM_SPED_ENTIDADE
	WSDATA   cBAIRRO                   AS string OPTIONAL
	WSDATA   cCEP                      AS string
	WSDATA   cCEP_CP                   AS string OPTIONAL
	WSDATA   cCNPJ                     AS string OPTIONAL
	WSDATA   cCOD_MUN                  AS string
	WSDATA   cCOD_PAIS                 AS string
	WSDATA   cCOMPL                    AS string OPTIONAL
	WSDATA   cCP                       AS string OPTIONAL
	WSDATA   cCPF                      AS string OPTIONAL
	WSDATA   cDDD                      AS string OPTIONAL
	WSDATA   dDTRE                     AS date OPTIONAL
	WSDATA   cEMAIL                    AS string OPTIONAL
	WSDATA   cENDERECO                 AS string
	WSDATA   cFANTASIA                 AS string OPTIONAL
	WSDATA   cFAX                      AS string OPTIONAL
	WSDATA   cFONE                     AS string OPTIONAL
	WSDATA   cID_MATRIZ                AS string OPTIONAL
	WSDATA   cIDEMPRESA                AS string OPTIONAL
	WSDATA   cIE                       AS string OPTIONAL
	WSDATA   cIM                       AS string OPTIONAL
	WSDATA   cINDSITESP                AS string OPTIONAL
	WSDATA   cINSCRTRA                 AS string OPTIONAL
	WSDATA   cMUN                      AS string OPTIONAL
	WSDATA   cNIRE                     AS string
	WSDATA   cNIT                      AS string OPTIONAL
	WSDATA   cNOME                     AS string
	WSDATA   cNUM                      AS string OPTIONAL
	WSDATA   cSUFRAMA                  AS string OPTIONAL
	WSDATA   cUF                       AS string
	WSDATA   cUPDINSCRTR               AS string OPTIONAL
	WSDATA   cINDTAF	               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_SPED_ENTIDADE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_SPED_ENTIDADE
Return

WSMETHOD CLONE WSCLIENT TAFADM_SPED_ENTIDADE
	Local oClone := TAFADM_SPED_ENTIDADE():NEW()
	oClone:cBAIRRO              := ::cBAIRRO
	oClone:cCEP                 := ::cCEP
	oClone:cCEP_CP              := ::cCEP_CP
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCOD_MUN             := ::cCOD_MUN
	oClone:cCOD_PAIS            := ::cCOD_PAIS
	oClone:cCOMPL               := ::cCOMPL
	oClone:cCP                  := ::cCP
	oClone:cCPF                 := ::cCPF
	oClone:cDDD                 := ::cDDD
	oClone:dDTRE                := ::dDTRE
	oClone:cEMAIL               := ::cEMAIL
	oClone:cENDERECO            := ::cENDERECO
	oClone:cFANTASIA            := ::cFANTASIA
	oClone:cFAX                 := ::cFAX
	oClone:cFONE                := ::cFONE
	oClone:cID_MATRIZ           := ::cID_MATRIZ
	oClone:cIDEMPRESA           := ::cIDEMPRESA
	oClone:cIE                  := ::cIE
	oClone:cIM                  := ::cIM
	oClone:cINDSITESP           := ::cINDSITESP
	oClone:cINSCRTRA            := ::cINSCRTRA
	oClone:cMUN                 := ::cMUN
	oClone:cNIRE                := ::cNIRE
	oClone:cNIT                 := ::cNIT
	oClone:cNOME                := ::cNOME
	oClone:cNUM                 := ::cNUM
	oClone:cSUFRAMA             := ::cSUFRAMA
	oClone:cUF                  := ::cUF
	oClone:cUPDINSCRTR          := ::cUPDINSCRTR
Return oClone

WSMETHOD SOAPSEND WSCLIENT TAFADM_SPED_ENTIDADE
	Local cSoap := ""
	cSoap += WSSoapValue("BAIRRO", ::cBAIRRO, ::cBAIRRO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CEP", ::cCEP, ::cCEP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CEP_CP", ::cCEP_CP, ::cCEP_CP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNPJ", ::cCNPJ, ::cCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COD_MUN", ::cCOD_MUN, ::cCOD_MUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COD_PAIS", ::cCOD_PAIS, ::cCOD_PAIS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COMPL", ::cCOMPL, ::cCOMPL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CP", ::cCP, ::cCP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CPF", ::cCPF, ::cCPF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DDD", ::cDDD, ::cDDD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DTRE", ::dDTRE, ::dDTRE , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMAIL", ::cEMAIL, ::cEMAIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDERECO", ::cENDERECO, ::cENDERECO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FANTASIA", ::cFANTASIA, ::cFANTASIA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FAX", ::cFAX, ::cFAX , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FONE", ::cFONE, ::cFONE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ID_MATRIZ", ::cID_MATRIZ, ::cID_MATRIZ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IDEMPRESA", ::cIDEMPRESA, ::cIDEMPRESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IE", ::cIE, ::cIE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IM", ::cIM, ::cIM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("INDSITESP", ::cINDSITESP, ::cINDSITESP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("INSCRTRA", ::cINSCRTRA, ::cINSCRTRA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MUN", ::cMUN, ::cMUN , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NIRE", ::cNIRE, ::cNIRE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NIT", ::cNIT, ::cNIT , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NOME", ::cNOME, ::cNOME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NUM", ::cNUM, ::cNUM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SUFRAMA", ::cSUFRAMA, ::cSUFRAMA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UF", ::cUF, ::cUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UPDINSCRTR", ::cUPDINSCRTR, ::cUPDINSCRTR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TAFADM_SPED_ENTIDADE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBAIRRO            :=  WSAdvValue( oResponse,"_BAIRRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCEP               :=  WSAdvValue( oResponse,"_CEP","string",NIL,"Property cCEP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCEP_CP            :=  WSAdvValue( oResponse,"_CEP_CP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCOD_MUN           :=  WSAdvValue( oResponse,"_COD_MUN","string",NIL,"Property cCOD_MUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCOD_PAIS          :=  WSAdvValue( oResponse,"_COD_PAIS","string",NIL,"Property cCOD_PAIS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCOMPL             :=  WSAdvValue( oResponse,"_COMPL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCP                :=  WSAdvValue( oResponse,"_CP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCPF               :=  WSAdvValue( oResponse,"_CPF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDDD               :=  WSAdvValue( oResponse,"_DDD","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::dDTRE              :=  WSAdvValue( oResponse,"_DTRE","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::cEMAIL             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cENDERECO          :=  WSAdvValue( oResponse,"_ENDERECO","string",NIL,"Property cENDERECO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFANTASIA          :=  WSAdvValue( oResponse,"_FANTASIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFAX               :=  WSAdvValue( oResponse,"_FAX","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFONE              :=  WSAdvValue( oResponse,"_FONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cID_MATRIZ         :=  WSAdvValue( oResponse,"_ID_MATRIZ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIDEMPRESA         :=  WSAdvValue( oResponse,"_IDEMPRESA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIE                :=  WSAdvValue( oResponse,"_IE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIM                :=  WSAdvValue( oResponse,"_IM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cINDSITESP         :=  WSAdvValue( oResponse,"_INDSITESP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cINSCRTRA          :=  WSAdvValue( oResponse,"_INSCRTRA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMUN               :=  WSAdvValue( oResponse,"_MUN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNIRE              :=  WSAdvValue( oResponse,"_NIRE","string",NIL,"Property cNIRE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNIT               :=  WSAdvValue( oResponse,"_NIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNUM               :=  WSAdvValue( oResponse,"_NUM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSUFRAMA           :=  WSAdvValue( oResponse,"_SUFRAMA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUF                :=  WSAdvValue( oResponse,"_UF","string",NIL,"Property cUF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cUPDINSCRTR        :=  WSAdvValue( oResponse,"_UPDINSCRTR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFENTPEDNFE

WSSTRUCT TAFADM_ARRAYOFENTPEDNFE
	WSDATA   oWSENTPEDNFE              AS TAFADM_ENTPEDNFE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_ARRAYOFENTPEDNFE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_ARRAYOFENTPEDNFE
	::oWSENTPEDNFE         := {} // Array Of  TAFADM_ENTPEDNFE():New()
Return

WSMETHOD CLONE WSCLIENT TAFADM_ARRAYOFENTPEDNFE
	Local oClone := TAFADM_ARRAYOFENTPEDNFE():NEW()
	oClone:oWSENTPEDNFE := NIL
	If ::oWSENTPEDNFE <> NIL 
		oClone:oWSENTPEDNFE := {}
		aEval( ::oWSENTPEDNFE , { |x| aadd( oClone:oWSENTPEDNFE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TAFADM_ARRAYOFENTPEDNFE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ENTPEDNFE","ENTPEDNFE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSENTPEDNFE , TAFADM_ENTPEDNFE():New() )
			::oWSENTPEDNFE[len(::oWSENTPEDNFE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure SPED_GENERICSTRUCT

WSSTRUCT TAFADM_SPED_GENERICSTRUCT
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_SPED_GENERICSTRUCT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_SPED_GENERICSTRUCT
Return

WSMETHOD CLONE WSCLIENT TAFADM_SPED_GENERICSTRUCT
	Local oClone := TAFADM_SPED_GENERICSTRUCT():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
Return oClone

WSMETHOD SOAPSEND WSCLIENT TAFADM_SPED_GENERICSTRUCT
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ENTPEDNFE

WSSTRUCT TAFADM_ENTPEDNFE
	WSDATA   dDATAPED                  AS date
	WSDATA   cNFE_ID                   AS string
	WSDATA   cPEDIDO                   AS string
	WSDATA   nQTDPED                   AS integer
	WSDATA   nSALDO                    AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TAFADM_ENTPEDNFE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TAFADM_ENTPEDNFE
Return

WSMETHOD CLONE WSCLIENT TAFADM_ENTPEDNFE
	Local oClone := TAFADM_ENTPEDNFE():NEW()
	oClone:dDATAPED             := ::dDATAPED
	oClone:cNFE_ID              := ::cNFE_ID
	oClone:cPEDIDO              := ::cPEDIDO
	oClone:nQTDPED              := ::nQTDPED
	oClone:nSALDO               := ::nSALDO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TAFADM_ENTPEDNFE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::dDATAPED           :=  WSAdvValue( oResponse,"_DATAPED","date",NIL,"Property dDATAPED as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cNFE_ID            :=  WSAdvValue( oResponse,"_NFE_ID","string",NIL,"Property cNFE_ID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPEDIDO            :=  WSAdvValue( oResponse,"_PEDIDO","string",NIL,"Property cPEDIDO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nQTDPED            :=  WSAdvValue( oResponse,"_QTDPED","integer",NIL,"Property nQTDPED as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSALDO             :=  WSAdvValue( oResponse,"_SALDO","integer",NIL,"Property nSALDO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return



