#include "totvs.ch"
#include "restful.ch"
#include "parmtype.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TSIIntegrationErrors
https://api.totvs.com.br/apidetails/TSIIntegrationErrors_v1_000.json

API TAF Fiscal TSI - Retorna erros da V5R
@author Denis Souza
@since 22/04/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
WSRESTFUL TSIIntegrationErrors DESCRIPTION 'endpoint TSIIntegrationErrors API' FORMAT APPLICATION_JSON

WSDATA companyId  AS STRING //Exemplo: T1|D MG 01
WSDATA branchCode AS STRING //Exemplo: D MG 01
WSDATA typeFilter AS STRING //Exemplo: Movimento
WSDATA dateOf     AS DATE OPTIONAL //Exemplo: 2022-04-01
WSDATA dateUp     AS DATE OPTIONAL //Exemplo: 2022-04-30
WSDATA order      AS STRING  OPTIONAL
WSDATA page       AS INTEGER OPTIONAL
WSDATA pageSize   AS INTEGER OPTIONAL

//http://localhost:8083/rest/api/tsi/v1/TSIIntegrationErrors/?
//companyId=T1|D MG 01 &branchCode=X TAF01 &typeFilter=Movimentos&dateOf=2022-04-22&dateUp=2022-04-22&order=V5R.V5R_HORA DESC&page=1&pageSize=10
WSMETHOD GET TSIIntegrationErrors;
DESCRIPTION "Retorna uma lista de erros de integração";
PATH "/api/tsi/v1/TSIIntegrationErrors/";
TTALK "v1";
WSSYNTAX "/api/tsi/v1/TSIIntegrationErrors/?{companyId}&{branchCode}&{typeFilter}&{dateOf}&{dateUp}&{order}&{page}&{pageSize}";
PRODUCES APPLICATION_JSON

WSMETHOD POST ReprocessInvoice;
DESCRIPTION "Reprocessa um ou mais nota fiscal com erro de integração";
PATH "/api/tsi/v1/TSIIntegrationErrors/reprocessInvoice";
TTALK "v1";
WSSYNTAX "/api/tsi/v1/TSIIntegrationErrors/reprocessInvoice/?{companyId}&{branchCode}";
PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para retornar a lista paginada para a Grid
@author			Denis Souza
@since			25/04/2022
@return			lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST ReprocessInvoice WSRECEIVE companyId, branchCode WSREST TSIIntegrationErrors
Local lRet             := .T.
Local nCodeError       := 404
Local cMessage         := EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId' ." )
Local cDetailedMessage := EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição.")
Local aCompany		   := {}
Local oResult 		   := JsonObject():New()
Local cEmpRequest	   := ""
Local cFilRequest	   := ""
Local oBody            := JsonObject():New()
Local cBody            := self:GetContent()
Local nR               := 0

::SetContentType( "application/json" )

If Empty(cBody)
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Corpo da requisição não enviado." ) )

ElseIf self:companyId == Nil
	lRet := .F.
	SetRestFault(404,cMessage,.T.,,cDetailedMessage)
Else
	aCompany := StrTokArr( self:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage)
	Else
		cEmpRequest := aCompany[1]
		
    	If Alltrim(self:branchCode) == 'Todas'
			cFilRequest := aCompany[2]
		Else
            cFilRequest := PADR(alltrim(self:branchCode),FWSizeFilial())
        EndIf

		If PrepEnv( cEmpRequest, cFilRequest )
            oBody:FromJSON( cBody )

            //Processa todas as Notas Fiscais
            if oBody['reprocessAll']
                TSIV5RC20():New( cEmpAnt+cFilAnt, .T.,,self:branchCode)
                oResult["status"]   := .T.
                if !Alltrim(self:branchCode) == "Todas"
                    oResult["message"] := EncodeUTF8('Todas as Notas Fiscais da filial '+cFilAnt+' foram remarcadas para reintegração. O tempo de processamento pode variar de acordo com a configuração efetuada pelo job.')
                else
                    oResult["message"] := EncodeUTF8('Todas as Notas Fiscais foram remarcadas para reintegração. O tempo de processamento pode variar de acordo com a configuração efetuada pelo job.')
                endIf
            else //Processar apenas as selecionadas
                for nR := 1 to len(oBody['items'])
                    TSIV5RC20():NEW(cFilAnt+cEmpAnt,.T.,oBody['items'][nR], self:branchCode )
                    oResult["status"]   := .T.
                    oResult["message"]  := EncodeUTF8('As Notas Fiscais foram remarcadas para reintegração. O tempo de processamento pode variar de acordo com a configuração efetuada pelo job.')
                next
            endif
            
            ::SetResponse(oResult:toJSON())
			
		Else
			lRet     := .F.
			cMessage := EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
			SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage)
		EndIf
	EndIf
EndIf

FreeObj( oResult )
oResult := Nil
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para retornar a lista paginada para a Grid
@author			Denis Souza
@since			25/04/2022
@return			lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET TSIIntegrationErrors WSRECEIVE companyId, branchCode, dateOf, dateUp, typeFilter, order, page, pageSize WSREST TSIIntegrationErrors
Return getErrorsList( @self )

//---------------------------------------------------------------------
/*/{Protheus.doc} getErrorsList
@type		 Static Function
@description Funcao para obter o response com json tratado
@author		 Denis Souza
@since		 25/04/2022
@return		 lRet - Indica se o funcao aceitou a execução do processo
/*/
//---------------------------------------------------------------------
Static Function getErrorsList( oRest )
Local lRet       As Logical
Local oTsiErrors As Object
Local aChvNt     As Array
Local aTitCmp    As Array
Local nTmJson    As Numeric
Local nlA        As Numeric
Local cErrorMsg  As Character
Local cFaild     As Character

if oRest:page == Nil .Or. Empty( oRest:page )
    oRest:page := 1
endif
if oRest:pageSize == Nil .Or. Empty( oRest:pageSize )
    oRest:pageSize := 10
endif

lRet       := GetVldParams(@oRest)
oTsiErrors := Nil
aChvNt     := {}
aTitCmp    := {'Operação = ','Data da Nota = ','Série = ','Nota Fiscal = ','Cód. Participante = '}

nTmJson    := 0
nlA        := 1
cErrorMsg  := ''
cFaild     := "Falha ao obter o resultado da consulta de erros de integração. "

if lRet
    oTsiErrors := TsiErrorAdapter():new( 'GET' )
    oTsiErrors:setpage( oRest:page )
    oTsiErrors:setpageSize( oRest:pageSize )

    oTsiErrors:GetListErrors( oRest )
    If oTsiErrors:lOk
        nTmJson := len( oTsiErrors:oJsonObj:oJsonObj['items'] )
        For nlA := 1 To nTmJson
            oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['errormessage'] := StrTran(oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['errormessage'],"|",CRLF)
            if "C20" $ oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['layouterror']
                oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['regkey'] := ''
                aChvNt := Separa( oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['erpkey'], '|' )
                oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['erpkey'] := FormChvNt(aTitCmp,aChvNt,@oTsiErrors:oJsonObj:oJsonObj[ 'items' ][nlA])
            endif
        Next nlA
        oRest:SetResponse( EncodeUTF8( oTsiErrors:getJSONResponse() ) )
    EndIf
    oTsiErrors:DeActivate() //faz a desalocação de objetos e arrays utilizados
    oTsiErrors := nil
endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GetVldParams
@type		 Static Function
@description Verifica se os parâmetros são válidos.
@author		 Denis Souza
@since		 25/04/2022
@return		 lRet - Indica se o funcao aceitou a execução do processo
/*/
//---------------------------------------------------------------------
Static Function GetVldParams(oRest)
Local lRet        As Logical
Local nCodeError  As Numeric
Local cMsg        As Character
Local cDetaillMsg As Character
Local cHelpUrl    As Character
Local cEmpRequest As Character
Local cFilRequest As Character
Local aCompany    As Array

lRet        := .T.
nCodeError  := 404
cMsg        := EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'." )
cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição.")
cHelpUrl    := EncodeUTF8("https://api.totvs.com.br/apidetails/TSIIntegrationErrors_v1_000.json")
cEmpRequest := ''
cFilRequest := ''
cBranchCode := ''
aCompany    := {}

oRest:SetContentType( "application/json" )
If oRest:companyId == Nil .Or. Empty( oRest:companyId )
	lRet := .F.
	SetRestFault(404,cMsg,.T.,,cDetaillMsg,cHelpUrl)    
Elseif oRest:branchCode == Nil .Or. Empty( oRest:branchCode )
	lRet := .F.
    cMsg := EncodeUTF8("Código da filial não informado no parâmetro 'branchCode'." )
    cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'branchCode' enviado na requisição.")
	SetRestFault(404,cMsg,.T.,,cDetaillMsg,cHelpUrl)
Elseif !Empty(oRest:dateOf) .And. !Empty(oRest:dateUp) .And. DtoS(oRest:dateOf) > DtoS(oRest:dateUp)
	lRet := .F.
    cMsg := EncodeUTF8("Data Inválida 'dateOf' maior do que 'dateUp'." )
    cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'dateOf' e 'dateUp' enviado na requisição.")
	SetRestFault(404,cMsg,.T.,,cDetaillMsg,cHelpUrl)
Elseif oRest:typeFilter == Nil .Or. Empty( oRest:typeFilter )
	lRet := .F.
    cMsg := EncodeUTF8("Tipo de Filtro não informado no parâmetro 'typeFilter'." )
    cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'typeFilter' enviado na requisição.")
	SetRestFault(404,cMsg,.T.,,cDetaillMsg,cHelpUrl)
Else
	aCompany := StrTokArr( oRest:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,cMsg,.T.,,cDetaillMsg,cHelpUrl)
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := PadR(Alltrim(aCompany[2]),FWSizeFilial())
        cBranchCode := oRest:BranchCode
        If PrepEnv( cEmpRequest, cFilRequest )
            if cBranchCode <> 'Todas' .And. !FWFilExist( cEmpRequest, cBranchCode )
                lRet := .F.
                cMsg := EncodeUTF8("Código da filial inválido 'branchCode'." )
                cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'branchCode' enviado na requisição.")
                SetRestFault(404,cMsg,.T.,,cDetaillMsg,cHelpUrl)
            endif
        Else
		    lRet := .F.
		    cMsg := EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
		    SetRestFault(nCodeError,cMsg,.T.,,cDetaillMsg,cHelpUrl)
        EndIf
	EndIf
EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} FormChvNt
@type		 Static Function
@description Trata a chave da nota com base na quebra do erpkey
@author		 Denis Souza
@since		 25/04/2022
@return		 cText - Texto Formatado
/*/
//---------------------------------------------------------------------
Static Function FormChvNt(aTitCmp,aChvNt,oJsItem)
Local cText    As Character

Default aTitCmp  := {}
Default aChvNt   := {}

cText    := ''

if Len( aTitCmp ) == 5  
    cText += aTitCmp[1] //Operacao
    oJsItem[ 'typeInvoice' ] := iif( aChvNt[1] == "0", "NF Entrada" , "NF Saída" )
    cText += iif( aChvNt[1] == "0", "NF Entrada" , "NF Saída" )
    cText += CRLF
    
    cText += aTitCmp[4] //Nota
    oJsItem[ 'invoice' ] := Alltrim( aChvNt[4] )
    cText += Alltrim( aChvNt[4] )
    cText += CRLF
    
    cText += aTitCmp[3] //Serie
    oJsItem[ 'serie' ]   := Alltrim( aChvNt[3] )
    cText += Alltrim( aChvNt[3] )
    cText += CRLF
    
    cText += aTitCmp[2] //Data
    oJsItem[ 'dateInvoice' ]  := SUBSTRING(aChvNt[2],7,2)+"/"+SUBSTRING(aChvNt[2],5,2)+"/"+SUBSTRING(aChvNt[2],1,4)
    cText += SUBSTRING(aChvNt[2],7,2)+"/"+SUBSTRING(aChvNt[2],5,2)+"/"+SUBSTRING(aChvNt[2],1,4)
    cText += CRLF
    
    cText += aTitCmp[5] //Cód.Part
    cText += Alltrim( aChvNt[5] ) + '-' + Alltrim( aChvNt[6])
    oJsItem[ 'codeParticipant' ]  := Alltrim( aChvNt[5] ) + '-' + Alltrim( aChvNt[6] )

endif

Return cText

//-------------------------------------------------------------------
/*/{Protheus.doc} TsiErrorAdapter
Classe Adapter para o serviço
@author Denis Souza
/*/
//-------------------------------------------------------------------
CLASS TsiErrorAdapter FROM FWAdapterBaseV2
    DATA cQuery As Character
    METHOD New()
    METHOD LoadFields()
    METHOD LoadQuery()
    METHOD GetListErrors()
ENDCLASS

 //---------------------------------------------------------------------
/*/{Protheus.doc} New
@type		 method
@description Método construtor
@author		 Denis Souza
@since		 25/04/2022
@return		 Nil
/*/
//---------------------------------------------------------------------
Method New( cVerb ) CLASS TsiErrorAdapter
    _Super:New( cVerb, .T. )
    ::LoadFields()
    ::LoadQuery()
Return Nil

 //---------------------------------------------------------------------
/*/{Protheus.doc} LoadFields
@type		 method
@description Método para atribuir a tags, campos no json
@author		 Denis Souza
@since		 25/04/2022
@return		 Nil
/*/
//---------------------------------------------------------------------
Method LoadFields() CLASS TsiErrorAdapter
    ::AddMapFields('layouterror'    ,'V5R_ALIAS' ,.T.,.T.,{'V5R_ALIAS' ,'C',TamSX3('V5R_ALIAS' )[1],0})
    ::AddMapFields('branchcode'     ,'V5R_CODFIL',.T.,.T.,{'V5R_CODFIL','C',TamSX3('V5R_CODFIL')[1],0})
    ::AddMapFields('integrationdate','V5R_DATA'  ,.T.,.T.,{'V5R_DATA'  ,'D',TamSX3('V5R_DATA'  )[1],0})
    ::AddMapFields('integrationtime','V5R_HORA'  ,.T.,.T.,{'V5R_HORA'  ,'C',TamSX3('V5R_HORA'  )[1],0})
    ::AddMapFields('regkey'         ,'V5R_REGKEY',.T.,.T.,{'V5R_REGKEY','C',TamSX3('V5R_REGKEY')[1],0})
    ::AddMapFields('erpKey'         ,'V5R_ERPKEY',.T.,.T.,{'V5R_ERPKEY','C',TamSX3('V5R_ERPKEY')[1],0})
    ::AddMapFields('errormessage'   ,'V5R_MSGERR',.T.,.T.,{'V5R_MSGERR','M',TamSX3('V5R_MSGERR')[1],0})
    ::AddMapFields('key'            ,'R_E_C_N_O_',.T.,.F.,{'R_E_C_N_O_','N',9,0})
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadQuery
@type		 method
@description Método para atribuir a query
@author		 Denis Souza
@since		 25/04/2022
@return		 Nil
/*/
//---------------------------------------------------------------------
Method LoadQuery() CLASS TsiErrorAdapter
Local alist := {}
Local nlA   := 0
Local nAte  := 0
Local cCase := ''

GetListTsi('Todos', @alist )
nAte := len(alist)

if nAte > 1
    cCase := " CASE V5R.V5R_ALIAS "
    for nlA := 1 to nAte
        cCase += " WHEN '" + alist[nlA][1] + "' THEN '" + alist[nlA][1] + " - " + alist[nlA][3] + "' " // Buscar posicao 3 do array para não usar abreviacao
    next nlA
    cCase += "ELSE V5R.V5R_ALIAS "
    cCase += "END "
endif

::cQuery := "SELECT " + cCase + " #QueryFields# FROM " + RetSqlName( "V5R" ) + " V5R WHERE #QueryWhere#"

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} GetListErrors
@type		 method
@description Método para Setar a query com filtro, ordem, execucao e retorno do json
@author		 Denis Souza
@since		 25/04/2022
@return		 Nil
/*/
//---------------------------------------------------------------------
Method GetListErrors( oRest ) CLASS TsiErrorAdapter
Local aArea     As Array
Local cTBMov    As Character
Local cTBApur   As Character
Local cTBNotCad As Character
Local cWhere    As Character
Local cOrder    As Character

aArea := FwGetArea()

cTBMov    := GetListTsi( 'Movimentos' )    //C20 Nota Fiscal
cTBApur   := GetListTsi( 'Apurações' )     //C2S Apuração ICMS / C3J Apuração ICMS ST / C5M CPRB
cTBNotCad := GetListTsi( 'Sem Cadastros' ) //C20 Nota Fiscal / C2S Apuração ICMS / C3J Apuração ICMS ST / C5M CPRB

::SetQuery( ::cQuery )

cWhere := " V5R.V5R_FILIAL = '" + FWxFilial('V5R') + "'"

if oRest:typeFilter == 'Movimentos'
    cWhere += " AND V5R.V5R_ALIAS = '" + cTBMov + "'"
elseif oRest:typeFilter == 'Cadastros'
    cWhere += " AND V5R.V5R_ALIAS NOT IN ( " + cTBNotCad + ") "
elseif oRest:typeFilter == 'Apurações' .Or. oRest:typeFilter == 'Apuracoes' //devido automacao
    cWhere += " AND V5R.V5R_ALIAS IN ( " + cTBApur + ") "
endif

if oRest:branchCode <> "Todas"
    cWhere += " AND V5R.V5R_CODFIL = '" + oRest:branchCode + "'"
endif

if !Empty(oRest:dateOf) .And. !Empty(oRest:dateUp)
    cWhere += " AND V5R.V5R_DATA BETWEEN '" + DtoS(oRest:dateOf) + "' AND '" + DtoS(oRest:dateUp) + "'"
endif

cWhere += " AND V5R.D_E_L_E_T_ = ' ' "

if oRest:order == Nil .Or. Empty( oRest:order )
    cOrder := "V5R.V5R_CODFIL, V5R.V5R_DATA DESC, V5R.V5R_HORA DESC"
else
    cOrder := oRest:order
endif

::SetWhere( cWhere )
::SetOrder( cOrder )

If ::Execute() //Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
    ::FillGetResponse() // Gera o arquivo Json com o retorno da Query
EndIf

FwRestArea(aArea)

Return Nil
