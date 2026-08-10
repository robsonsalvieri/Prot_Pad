#include "totvs.ch"
#include "restful.ch"
#include "parmtype.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TSIDivergentDocuments
https://api.totvs.com.br/apidetails/TSIIntegrationErrors_v1_000.json

API TAF Fiscal TSI - Retorna as divergências entre os registros das tabelas SFT X C20
@author Rafael de Paula Leme / Denis Souza
@since 07/07/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
WSRESTFUL TSIDivergentDocuments DESCRIPTION 'endpoint TSIIntegrationErrors API' FORMAT APPLICATION_JSON

WSDATA companyId  AS STRING         //Exemplo: T1|D MG 01
WSDATA branchCode AS STRING         //Exemplo: D MG 01
WSDATA dateOf     AS DATE OPTIONAL  //Exemplo: 2022-04-01
WSDATA dateUp     AS DATE OPTIONAL  //Exemplo: 2022-04-30
WSDATA page       AS INTEGER OPTIONAL
WSDATA pageSize   AS INTEGER OPTIONAL

//http://localhost:8083/rest/api/tsi/v1/TSIDivergentDocuments/?
//companyId=T1|D MG 01 &branchCode=D MG 01 &dateOf=2022-04-22&dateUp=2022-04-22&page=1&pageSize=10
WSMETHOD GET TSIDivergentDocuments;
DESCRIPTION "Retorna uma lista de divergencias entre as tabelas SFT x C20";
PATH "/api/tsi/v1/TSIDivergentDocuments/";
TTALK "v1";
WSSYNTAX "/api/tsi/v1/TSIDivergentDocuments/?{companyId}&{branchCode}&{dateOf}&{dateUp}&{page}&{pageSize}";
PRODUCES APPLICATION_JSON

WSMETHOD POST Reinstate;
DESCRIPTION "Reintegra uma ou mais nota fiscal divergente em relação a SFT";
PATH "/api/tsi/v1/TSIDivergentDocuments/reinstate";
TTALK "v1";
WSSYNTAX "/api/tsi/v1/TSIDivergentDocuments/reinstate/?{companyId}&{branchCode}&{dateOf}&{dateUp}";
PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para retornar a lista paginada para a Grid
@author			Rafael de Paula Leme / Denis Souza
@since			07/07/2022
@return			lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET TSIDivergentDocuments WSRECEIVE companyId, branchCode, dateOf, dateUp, page, pageSize WSREST TSIDivergentDocuments
Return getDifList( @self )

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método para reintegrar notas do documento divergente
@author			Denis Souza
@since			19/07/2022
@return			lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST Reinstate WSRECEIVE companyId, branchCode, dateOf, dateUp WSREST TSIDivergentDocuments

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
Local oTsiSftC20       := Nil
Local cWngSFT          := ''
Local cWngV5R          := ''
Local cRecnoV5R        := '0'

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
		cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())
		cBranchCode := self:BranchCode
        If PrepEnv( cEmpRequest, cFilRequest )
            if cBranchCode <> 'Todas' .And. !FWFilExist( cEmpRequest, cBranchCode )
                lRet := .F.
                cMsg := EncodeUTF8("Código da filial inválido 'branchCode'." )
                cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'branchCode' enviado na requisição.")
                SetRestFault(404,cMsg,.T.,,cDetaillMsg)
            endif
            if lRet
                oBody:FromJSON( cBody )
                oTsiSftC20 := TsiSftC20():New(cEmpAnt+cFilAnt,cBranchCode,self:dateOf,self:dateUp)
                if oBody['reprocessAll'] //Reintegra todas as Notas Fiscais ignora itemsSFT e itemsV5R
                    if oTsiSftC20:UpdFakeSF3() .And. oTsiSftC20:UpdFakeSFT()
                        oTsiSftC20:DelDivV5R()
                        oResult["status"] := .T.
                        if !Alltrim(cBranchCode) == "Todas"
                            oResult["message"] := EncodeUTF8('Todas as Notas Fiscais da filial '+cFilAnt+' foram remarcadas para reintegração. O tempo de processamento pode variar de acordo com a configuração efetuada pelo job.')
                        else
                            oResult["message"] := EncodeUTF8('Todas as Notas Fiscais foram remarcadas para reintegração. O tempo de processamento pode variar de acordo com a configuração efetuada pelo job.')
                        endIf
                    else
                        lRet := oResult["status"] := .F.
                        oResult["message"] := EncodeUTF8('Falha ao inserir os documentos divergentes na fila de reintegração.')
                    endif
                else //Processar apenas os selecionadas considera itemsSFT e itemsV5R
                    cWngSFT := ''
                    for nR := 1 to len(oBody['itemsSFT'])
                        if !oTsiSftC20:UpdFakeSF3( oBody['itemsSFT'][nR] ) .Or. !oTsiSftC20:UpdFakeSFT( oBody['itemsSFT'][nR] ) //itemsSFT possui toda a chave do registro selecionado
                            cWngSFT += oBody['itemsSFT'][nR]['series'] + ' ' + oBody['itemsSFT'][nR]['documentnumber'] + ','
                        endif
                    next nR
                    if !empty( cWngSFT )
                        cWngSFT := 'Houve falha na seguinte nota(s): ' + substr( cWngSFT , 1 , len(cWngSFT)-1 )
                    endif
                    //
                    cWngV5R := ''
                    for nR := 1 to len(oBody['itemsV5R'])
                        cRecnoV5R := cValToChar(oBody['itemsV5R'][nR])
                        if !oTsiSftC20:DelDivV5R(.F., cRecnoV5R)
                            cWngV5R += cRecnoV5R + ','
                        endif
                    next nR
                    if !empty( cWngV5R )
                        cWngV5R := 'Houve falha ao apagar o log na V5R para os identificadores: ' + substr( cWngV5R , 1 , len(cWngV5R)-1 )
                    endif
                    if !Empty( cWngSFT ) .Or. !Empty( cWngV5R )
                        lRet := oResult["status"]  := .F.
                        oResult["message"] := EncodeUTF8( cWngSFT + " " + cWngV5R )
                    else
                        oResult["status"]  := .T.
                        oResult["message"] := EncodeUTF8('As Notas Fiscais foram remarcadas para reintegração. O tempo de processamento pode variar de acordo com a configuração efetuada pelo job.')
                    endif
                endif
                ::SetResponse(oResult:toJSON())
            endif
		Else
			lRet := .F.
			cMessage := EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
			SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage)
		EndIf
	EndIf
EndIf
FreeObj( oResult )
oResult := Nil
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} getDifList
@type		 Static Function
@description Funcao para obter o response com json tratado
@author		 Rafael de Paula Leme / Denis Souza
@since		 07/07/2022
@return		 lRet - Indica se o funcao aceitou a execução do processo
/*/
//---------------------------------------------------------------------
Static Function getDifList ( oRest )

Local aTypingDt  As Array
Local lRet       As logical
Local nTmJson    As Numeric 
Local nlA        As Numeric
Local nTmSerie   As Numeric
Local nTmNumDoc  As Numeric
Local nTmCliFor  As Numeric
Local nTmLoja    As Numeric
Local cKey       As Character
Local cAlias     As Character
Local cFixQry    As Character
Local lV5rEp     As Logical
Local oTsiErrors As Object

if oRest:page == Nil .Or. Empty( oRest:page )
    oRest:page := 1
endif
if oRest:pageSize == Nil .Or. Empty( oRest:pageSize )
    oRest:pageSize := 10
endif

aTypingDt  := {}
lRet       := GetVldParams(@oRest)
oTsiErrors := Nil
nTmJson    := 0
nlA        := 1
cKey       := ""
cFixQry    := ""

if lRet
    oTsiErrors := TsiDifAdapter():new( oRest, 'GET' )
    oTsiErrors:setpage( oRest:page )
    oTsiErrors:setpageSize( oRest:pageSize )
    If oTsiErrors:Execute() //Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
        oTsiErrors:FillGetResponse() // Gera o arquivo Json com o retorno da Query
    EndIf
    If oTsiErrors:lOk
        nTmJson := len( oTsiErrors:oJsonObj:oJsonObj['items'] )
        DbSelectArea("V5R")
        V5R->(DbSetOrder(1)) //V5R_FILIAL, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY, R_E_C_N_O_, D_E_L_E_T_
        lV5rEp := V5R->(FieldPos("V5R_ERPKEY")) > 0

        //Verificado que se utilizar a V5R no LEFTJOIN, no caso de volumetria alta (>150.000), fica mais lento doque 10 consultas dos registros paginados.
        if nTmJson > 0 .And. lV5rEp //se nao existir ira manter a tag integrationerrorinv5r vazio
            nTmSerie  := GetSx3Cache( 'C20_SERIE' , 'X3_TAMANHO')
            nTmNumDoc := GetSx3Cache( 'C20_NUMDOC', 'X3_TAMANHO')
            nTmCliFor := GetSx3Cache( 'FT_CLIEFOR', 'X3_TAMANHO')
            nTmLoja   := GetSx3Cache( 'FT_LOJA'   , 'X3_TAMANHO')
            oStatV5R  := V5RERPKEY()
            cAlias := GetNextAlias()
            For nlA := 1 To nTmJson
                aTypingDt := Separa(oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['typingdate'],'-')
                cKey := iif(oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['operationtype']=="Entrada","0","1") + "|"
                cKey += aTypingDt[1]+PadL( aTypingDt[2],2,"0")+PadL( aTypingDt[3],2,"0") + "|"
                cKey += Padr(oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['series'],nTmSerie,' ') + "|"
                cKey += Padr(oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['documentnumber'],nTmNumDoc,' ') + "|"
                cKey += Padr(oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['participantcode'],nTmCliFor,' ') + "|"
                cKey += Padr(oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['store'],nTmLoja,' ')
                //Passa os parametros para o objeto da query
                oStatV5R:SetString( 1, xFilial( "V5R" ) ) //V5R_FILIAL
                oStatV5R:SetString( 2, oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['branchcode'] ) //V5R_CODFIL
                oStatV5R:SetString( 3, 'C20' ) //V5R_ALIAS
                oStatV5R:SetString( 4, alltrim(cKey) )  //V5R_ERPKEY
                cFixQry := oStatV5R:GetFixQuery( )
                DBUseArea(.T.,'TOPCONN',TCGenQry(,,cFixQry),cAlias,.F.,.T.)
                if (cAlias)->(!eof())
                    oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['integrationerrorinv5r'] := 'Sim'
                    oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['recnov5r'] := (cAlias)->RECNOV5R
                    oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['details' ] := 'Erro de integração: ' + Alltrim( (cAlias)->MSGV5R )
                else
                    oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['integrationerrorinv5r'] := 'Não'
                    if  oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['notefoundintaf' ] == 'Não'
                        oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['details' ] := 'Documento não encontrado no TAF.'
                    elseif oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['stampsft' ] <> oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['stampc20' ]
                        oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['details' ] := 'Data de integração do ERP diferente da data de integração do TAF.'
                    elseif oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['cancelederp' ] <> oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['canceledtaf' ]
                        if oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['cancelederp' ] == 'Sim' .And. oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['canceledtaf' ] == 'Não'
                            oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['details' ] := 'Documento cancelado no ERP e não cancelado no TAF.'
                        else
                            oTsiErrors:oJsonObj:oJsonObj['items'][nlA]['details' ] := 'Documento cancelado no TAF e não cancelado no ERP.'
                        endif
                    endif   
                endif
                (cAlias)->(DbCloseArea())
            Next nlA
        endif
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
@author		 Rafael de Paula Leme
@since		 07/07/2022
@return		 lRet - Indica se o funcao aceitou a execução do processo
/*/
//---------------------------------------------------------------------
Static Function GetVldParams(oRest)

Local lRet        As Logical
Local nCodeError  As Numeric
Local cMsg        As Character
Local cDetaillMsg As Character
Local cEmpRequest As Character
Local cFilRequest As Character
Local cBranchCode As Character
Local aCompany    As Array

lRet        := .T.
nCodeError  := 404
cMsg        := EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'." )
cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição.")
cEmpRequest := ''
cFilRequest := ''
cBranchCode := ''
aCompany    := {}

oRest:SetContentType( "application/json" )
If oRest:companyId == Nil .Or. Empty( oRest:companyId )
	lRet := .F.
	SetRestFault(404,cMsg,.T.,,cDetaillMsg)    
Elseif oRest:branchCode == Nil .Or. Empty( oRest:branchCode )
	lRet := .F.
    cMsg := EncodeUTF8("Código da filial não informado no parâmetro 'branchCode'." )
    cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'branchCode' enviado na requisição.")
	SetRestFault(404,cMsg,.T.,,cDetaillMsg)
Elseif !Empty(oRest:dateOf) .And. !Empty(oRest:dateUp) .And. DtoS(oRest:dateOf) > DtoS(oRest:dateUp)
	lRet := .F.
    cMsg := EncodeUTF8("Data Inválida 'dateOf' maior do que 'dateUp'." )
    cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'dateOf' e 'dateUp' enviado na requisição.")
	SetRestFault(404,cMsg,.T.,,cDetaillMsg)
Else
	aCompany := StrTokArr( oRest:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,cMsg,.T.,,cDetaillMsg)
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := PadR(Alltrim(aCompany[2]),FWSizeFilial())
        cBranchCode := oRest:BranchCode
        If PrepEnv( cEmpRequest, cFilRequest )
            if cBranchCode <> 'Todas' .And. !FWFilExist( cEmpRequest, cBranchCode )
                lRet := .F.
                cMsg := EncodeUTF8("Código da filial inválido 'branchCode'." )
                cDetaillMsg := EncodeUTF8("Verifique o parâmetro 'branchCode' enviado na requisição.")
                SetRestFault(404,cMsg,.T.,,cDetaillMsg)
            endif
        Else
		    lRet := .F.
		    cMsg := EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
		    SetRestFault(nCodeError,cMsg,.T.,,cDetaillMsg)
        EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TsiDifAdapter
Classe Adapter para o serviço
@author Rafael Leme
/*/
//-------------------------------------------------------------------
CLASS TsiDifAdapter FROM FWAdapterBaseV2
    DATA cQuery As Character
	DATA cOrder As Character
    DATA cWhere As Character
    METHOD New()
    METHOD LoadFields()
    METHOD LoadQuery()
ENDCLASS

 //---------------------------------------------------------------------
/*/{Protheus.doc} New
@type		 method
@description Método construtor
@author		 Rafael Leme
@since		 07/07/2022
@return		 Nil
/*/
//---------------------------------------------------------------------
Method New( oRest, cVerb ) CLASS TsiDifAdapter
    _Super:New( cVerb, .T. )
    ::LoadFields()
    ::LoadQuery( oRest )
Return Nil

 //---------------------------------------------------------------------
/*/{Protheus.doc} LoadFields
@type		 method
@description Método para atribuir a tags, campos no json
@author		 Rafael Leme
@since		 07/07/2022
@return		 Nil
/*/
//---------------------------------------------------------------------
Method LoadFields() CLASS TsiDifAdapter

Local nTmFtFil  := GetSx3Cache( 'F3_FILIAL' , 'X3_TAMANHO')
Local nTmDtEnt  := GetSx3Cache( 'F3_ENTRADA', 'X3_TAMANHO')
Local nTmNF     := GetSx3Cache( 'F3_NFISCAL', 'X3_TAMANHO')
Local nTmSerie  := GetSx3Cache( 'C20_SERIE' , 'X3_TAMANHO')
Local nTmPartic := GetSx3Cache( 'A1_COD', 'X3_TAMANHO') + GetSx3Cache( 'A1_LOJA', 'X3_TAMANHO') + GetSx3Cache( 'A1_NOME', 'X3_TAMANHO')
Local nTmCGC    := GetSx3Cache( 'A1_CGC'    , 'X3_TAMANHO')
Local nTmC20Stp := GetSx3Cache( 'C20_STAMP' , 'X3_TAMANHO')
Local nTmCodCli := GetSx3Cache( 'A1_COD'    , 'X3_TAMANHO')
Local nTmLojCli := GetSx3Cache( 'A1_LOJA'   , 'X3_TAMANHO')
Local nTmCodFor := GetSx3Cache( 'A2_COD'    , 'X3_TAMANHO')
Local nTmLojFor := GetSx3Cache( 'A2_LOJA'   , 'X3_TAMANHO')

::AddMapFields('branchcode'             ,'F3_FILIAL' ,.T.,.T.,{'F3_FILIAL'  ,'C',nTmFtFil   ,0})
::AddMapFields('notefoundinsft'         ,'ERP'       ,.T.,.F.,{'ERP'        ,'C',3          ,0})
::AddMapFields('notefoundintaf'         ,'TAF'       ,.T.,.F.,{'TAF'        ,'C',3          ,0})
::AddMapFields('integrationerrorinv5r'  ,'ERRORV5R'  ,.T.,.F.,{'ERRORV5R'   ,'C',3          ,0})
::AddMapFields('typingdate'             ,'F3_ENTRADA',.T.,.T.,{'F3_ENTRADA' ,'D',nTmDtEnt   ,0})
::AddMapFields('operationtype'          ,'TIPOMOV'   ,.T.,.F.,{'TIPOMOV'    ,'C',7          ,0})
::AddMapFields('documentnumber'         ,'F3_NFISCAL',.T.,.T.,{'F3_NFISCAL' ,'C',nTmNF      ,0})
::AddMapFields('series'                 ,'F3_SERIE'  ,.T.,.T.,{'F3_SERIE'   ,'C',nTmSerie   ,0})
::AddMapFields('participantcodeandname' ,'CODNOME'   ,.T.,.F.,{'CODNOME'    ,'C',nTmPartic  ,0})
::AddMapFields('participantscnpj'       ,'CGC'       ,.T.,.F.,{'CGC'        ,'C',nTmCGC     ,0})
::AddMapFields('stampc20'               ,'C20STAMP'  ,.T.,.F.,{'C20STAMP'   ,'C',nTmC20Stp  ,0})
::AddMapFields('stampsft'               ,'SFTSTAMP'  ,.T.,.F.,{'SFTSTAMP'   ,'C',nTmC20Stp  ,0})
::AddMapFields('cancelederp'            ,'CANCERP'   ,.T.,.F.,{'CANCERP'    ,'C',3          ,0})
::AddMapFields('canceledtaf'            ,'CANCTAF'   ,.T.,.F.,{'CANCTAF'    ,'C',3          ,0})

//Constatado que o leftjoin com a V5R onera o tempo da query para paginacao de poucos registros(ex FrontEnd10), 
//nesse caso eh melhor utilizar os auxiliares para o dbseek na V5R. Para o relatorio eh vantajoso utilizacao do leftjoin.
::AddMapFields('participantcode'        ,'CODPART'  ,.T.,.F.,{'CODPART'     ,'C',iif(nTmCodCli>nTmCodFor,nTmCodCli,nTmCodFor),0})
::AddMapFields('store'                  ,'LOJA'     ,.T.,.F.,{'LOJA'        ,'C',iif(nTmLojCli>nTmLojFor,nTmLojCli,nTmLojFor),0})
::AddMapFields('recnov5r'               ,'V5RREC'   ,.T.,.F.,{'V5RREC'      ,'N',12,0})

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
Method LoadQuery( oRest ) CLASS TsiDifAdapter

Local cSubStr    := ""
Local cConcat    := ""
Local cIndCFOP   := "'4'"
Local cIndSCFOP  := "'5'"
Local cIsNullSQL := ""
Local cConvSFT   := ""
Local cNoLock    := ""
Local cIniMes    := ""
Local cFimMes    := ""
Local cDbType    := Upper(Alltrim(TCGetDB()))

If cDbType $ "ORACLE"
    cSubStr    := "SUBSTR"
    cConcat    := "||"
    cIsNullSQL := "NVL"
    cConvSFT   := " (cast(to_char(MAX(SFT.S_T_A_M_P_),'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23))) "
ElseIf cDbType $ "POSTGRES"
	cSubStr    := "SUBSTR"
    cConcat    := "||"
    cIsNullSQL := "COALESCE"
    cConvSFT   := " (cast(to_char(MAX(SFT.S_T_A_M_P_),'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23))) "
Else //MSSQL,MYSQL,PROGRESS
	cSubStr    := "SUBSTRING"
    cConcat    := "+"	
    cIsNullSQL := "ISNULL"
    cConvSFT   := " CONVERT(VARCHAR(23),MAX(SFT.S_T_A_M_P_),21) "
    If "MSSQL" $ cDbType        
        cNoLock := "(NOLOCK)"
    endif
EndIf

::cQuery := "SELECT #QueryFields# FROM (SELECT TAB2.F3_FILIAL, TAB2.ERP, "

::cQuery += cIsNullSQL + "((SELECT CASE WHEN C20.D_E_L_E_T_='*' THEN 'Não' WHEN C20.C20_STAMP <> ' ' THEN 'Sim' ELSE 'Não' END FROM " + RetSqlName( 'C20' ) + " C20 WHERE C20.R_E_C_N_O_ = TAB2.C20REC),'Não') TAF, "

::cQuery += "TAB2.ERRORV5R, TAB2.F3_ENTRADA, TAB2.TIPOMOV, TAB2.F3_NFISCAL, TAB2.F3_SERIE, TAB2.CODNOME, TAB2.CGC, "

::cQuery += cIsNullSQL + "((SELECT " + cSubStr + "(C20.C20_STAMP,1,16) FROM " + RetSqlName( 'C20' ) + " C20 WHERE C20.R_E_C_N_O_ = TAB2.C20REC ),' ') C20STAMP, "

::cQuery += cSubStr + "(TAB2.SFTSTAMP,1,16) SFTSTAMP, TAB2.CANCERP, "

::cQuery += cIsNullSQL + "((SELECT CASE WHEN C20.C20_CODSIT IN ('000003','000004','000005','000006') THEN 'Sim' ELSE 'Não' END FROM " + RetSqlName( 'C20' ) + " C20 WHERE C20.R_E_C_N_O_ = TAB2.C20REC),'Não') CANCTAF, "

::cQuery += "TAB2.CODPART, TAB2.LOJA, TAB2.V5RREC "   

::cQuery += "FROM ( SELECT SF3.F3_FILIAL, CASE WHEN SF3.D_E_L_E_T_ = '*' THEN 'Não' ELSE 'Sim' END ERP, ' ' ERRORV5R, SF3.F3_ENTRADA "

::cQuery += ",CASE WHEN SF3.F3_CFO <= " + cIndCFOP + " THEN 'Entrada' ELSE 'Saída'END TIPOMOV "

::cQuery += ",SF3.F3_NFISCAL, SF3.F3_SERIE "

::cQuery += ",CASE WHEN ( SF3.F3_CFO <= " + cIndCFOP + " AND SF3.F3_TIPO NOT IN ('B','D') )"
::cQuery += "OR ( SF3.F3_CFO >= " + cIndSCFOP + " AND SF3.F3_TIPO IN ('B','D') ) "
::cQuery += "THEN SA2.A2_COD " + cConcat + " SA2.A2_LOJA " + cConcat + " ' ' " + cConcat + " SA2.A2_NOME "
::cQuery += "ELSE SA1.A1_COD " + cConcat + " SA1.A1_LOJA " + cConcat + " ' ' " + cConcat + " SA1.A1_NOME END CODNOME "

::cQuery += ",CASE WHEN ( SF3.F3_CFO <= " + cIndCFOP + " AND SF3.F3_TIPO NOT IN ('B','D') ) " 
::cQuery += " OR ( SF3.F3_CFO >= " + cIndSCFOP + " AND SF3.F3_TIPO IN ('B','D') ) "
::cQuery += "THEN SA2.A2_CGC ELSE SA1.A1_CGC END CGC, "

::cQuery += cIsNullSQL + "((SELECT MAX(C20.R_E_C_N_O_) FROM " + RetSqlName( 'C20' ) + " C20 WHERE C20.C20_FILIAL = SF3.F3_FILIAL AND C20.C20_INDOPE = CASE WHEN SF3.F3_CFO <= " + cIndCFOP + " THEN '0'ELSE '1' END "
::cQuery += "AND C20.C20_CODPAR = C1H.C1H_ID AND LTRIM(RTRIM(C20.C20_SERIE)) = LTRIM(RTRIM(SF3.F3_SERIE)) AND LTRIM(RTRIM(C20.C20_NUMDOC)) = LTRIM(RTRIM(SF3.F3_NFISCAL)) AND C20.C20_DTES = SF3.F3_ENTRADA ),0) C20REC "

::cQuery += "," + cIsNullSQL + "( ( SELECT " + cConvSFT + " FROM " + RetSqlName( 'SFT' ) + " SFT WHERE SFT.FT_FILIAL = SF3.F3_FILIAL AND SFT.FT_IDENTF3 = SF3.F3_IDENTFT AND SFT.FT_ENTRADA = SF3.F3_ENTRADA "
::cQuery += "AND SFT.FT_SERIE = SF3.F3_SERIE AND SFT.FT_NFISCAL = SF3.F3_NFISCAL AND SFT.FT_CLIEFOR = SF3.F3_CLIEFOR AND SFT.FT_LOJA = SF3.F3_LOJA ), ' ') SFTSTAMP "

::cQuery += ",CASE WHEN SF3.F3_DTCANC <> ' ' AND LTRIM(RTRIM(SF3.F3_OBSERV)) = 'NF CANCELADA' THEN 'Sim' ELSE 'Não' END CANCERP "

::cQuery += ",CASE WHEN ( SF3.F3_CFO <= " + cIndCFOP + " AND SF3.F3_TIPO NOT IN ('B','D') ) "
::cQuery +=" OR ( SF3.F3_CFO >= " + cIndSCFOP + " AND SF3.F3_TIPO IN ('B','D') ) "
::cQuery += "THEN SA2.A2_COD ELSE SA1.A1_COD END CODPART "

::cQuery += ",CASE WHEN ( SF3.F3_CFO <= " + cIndCFOP + " AND SF3.F3_TIPO NOT IN ('B','D') ) "
::cQuery += " OR ( SF3.F3_CFO >= " + cIndSCFOP + " AND SF3.F3_TIPO IN ('B','D') ) "
::cQuery += "THEN SA2.A2_LOJA ELSE SA1.A1_LOJA END LOJA "

::cQuery += ",0 V5RREC FROM " + RetSqlName( 'SF3' ) + " SF3 "

::cQuery += "INNER JOIN ( SELECT MAX(SF3.R_E_C_N_O_) SF3REC FROM " + RetSqlName( 'SF3' ) + " SF3 WHERE #QueryWhere# "
::cQuery += "GROUP BY SF3.F3_FILIAL,SF3.F3_IDENTFT,SF3.F3_ENTRADA,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_CLIEFOR,SF3.F3_LOJA ) TAB1 ON  SF3.R_E_C_N_O_ = TAB1.SF3REC "

::cQuery += TafSF3LJoin( cDbType, cSubStr, cConcat, cIndCFOP, cNoLock, cIndSCFOP)

::cQuery += ") TAB2 ) TMP WHERE (TMP.ERP = 'Sim' OR TMP.TAF = 'Sim' ) AND (TMP.ERP <> TMP.TAF OR TMP.C20STAMP < TMP.SFTSTAMP OR TMP.CANCERP <> TMP.CANCTAF )"

::cWhere := "" 
if oRest:branchCode <> "Todas"
    ::cWhere += " SF3.F3_FILIAL = '" + oRest:branchCode + "' AND "
endif
if !Empty(oRest:dateOf) .And. !Empty(oRest:dateUp)
    ::cWhere += " SF3.F3_ENTRADA BETWEEN '" + DtoS(oRest:dateOf) + "' AND '" + DtoS(oRest:dateUp) + "' "
else //Se Não passar parametro filtra mes todo
    cIniMes := Dtos( CtoD('01/' + StrZero(Month(dDataBase),2) + '/' + cValToChar(Year(dDataBase)) ) )
    cFimMes := Dtos(Lastday(Stod(cIniMes)))
    ::cWhere += " SF3.F3_ENTRADA BETWEEN '" + cIniMes + "' AND '" + cFimMes + "' "
endif

::cOrder := " ORDER BY TMP.F3_FILIAL, TMP.TIPOMOV, TMP.F3_SERIE, TMP.F3_NFISCAL, TMP.CODNOME "

::SetQuery( ::cQuery )
::SetWhere( ::cWhere )
::SetOrder( ::cOrder )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TafSF3LJoin
@type Function
@description Relacionamento tratado entre SF3 e as tabelas SA1/SA2/C1H/C20.
Chamada do WSTAF051 e TAFA603 Update SFT Documentos Divergentes.
@author Denis Souza
@since  20/07/2022
@return cQry
/*/
//---------------------------------------------------------------------
Function TafSF3LJoin( cDbType, cSubStr, cConcat, cIndCFOP, cNoLock, cIndSCFOP )

Local cCompSA1  := Upper(AllTrim(FWModeAccess("SA1",1)+FWModeAccess("SA1",2)+FWModeAccess("SA1",3)))
Local cCompSA2  := Upper(AllTrim(FWModeAccess("SA2",1)+FWModeAccess("SA2",2)+FWModeAccess("SA2",3)))
Local cCompC1H  := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
Local aInfoEUF  := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
Local cCasePart := ""
Local cQry      := ""
Local lOraPost  := cDbType $ "ORACLE|POSTGRES"

Default cDbType  := ""
Default cSubStr  := ""
Default cConcat  := ""
Default cIndCFOP := "'4'"
Default cNoLock  := ""
Default cIndSCFOP := "'5'"

cCasePart := " (CASE WHEN ( SF3.F3_CFO <= " + cIndCFOP + " AND SF3.F3_TIPO NOT IN ('B','D') ) "
cCasePart += " OR ( SF3.F3_CFO >= " + cIndSCFOP + " AND SF3.F3_TIPO IN ('B','D') ) "

cQry := " LEFT JOIN " + RetSqlName( 'SA1' ) + " SA1 " + cNoLock +  " ON "

if cCompSA1 == "EEE"
    cQry += " SA1.A1_FILIAL = SF3.F3_FILIAL AND "
else
    if cCompSA1 == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 //filial compartilhada EEC
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SA1.A1_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + iif(lOraPost,")","") + " = " 
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SF3.F3_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + iif(lOraPost,")","") + " AND " 
    elseIf cCompSA1 == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 //unidade + filial compartilhada ECC 
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SA1.A1_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + iif(lOraPost,")","") + " = "
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SF3.F3_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + iif(lOraPost,")","") + " AND " 
    else
        cQry += " SA1.A1_FILIAL = '" + FWxFilial( 'SA1' ) + "' AND "
    endIf
endIf
cQry += " SA1.A1_COD = SF3.F3_CLIEFOR AND "
cQry += " SA1.A1_LOJA = SF3.F3_LOJA AND "
cQry += " SA1.D_E_L_E_T_ = ' ' "

cQry += " LEFT JOIN " + RetSqlName( 'SA2' ) + " SA2 " + cNoLock +  " ON "
if cCompSA2 == "EEE"
    cQry += " SA2.A2_FILIAL = SF3.F3_FILIAL AND "
else
    if cCompSA2 == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 //filial compartilhada EEC
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SA2.A2_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + iif(lOraPost,")","") + " = "
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SF3.F3_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + iif(lOraPost,")","") + " AND "
    elseIf cCompSA2 == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 //unidade + filial compartilhada ECC 
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SA2.A2_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + iif(lOraPost,")","") + " = "
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SF3.F3_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + iif(lOraPost,")","") + " AND "
    else
        cQry += " SA2.A2_FILIAL = '" + FWxFilial( 'SA2' ) + "' AND "
    endIf
endIf
cQry += " SA2.A2_COD = SF3.F3_CLIEFOR AND "
cQry += " SA2.A2_LOJA = SF3.F3_LOJA AND "
cQry += " SA2.D_E_L_E_T_ = ' ' "

cQry += " LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H " + cNoLock +  " ON "
if cCompC1H == "EEE"
    cQry += " C1H.C1H_FILIAL = SF3.F3_FILIAL AND "
else
    if cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 //filial compartilhada EEC
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + iif(lOraPost,")","") + " = "
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SF3.F3_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + iif(lOraPost,")","") + " AND "
    elseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 //unidade + filial compartilhada ECC 
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + iif(lOraPost,")","") + " = "
        cQry += iif(lOraPost,"TRIM(","") + cSubStr + "(SF3.F3_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + iif(lOraPost,")","") + " AND "
    else
        cQry += " C1H.C1H_FILIAL = '" + FWxFilial( 'C1H' ) + "' AND "
    endIf
endIf

cQry += " RTRIM(C1H.C1H_CODPAR) = " + cCasePart
cQry += " THEN 'F'" + cConcat + "(SF3.F3_CLIEFOR)" + cConcat + "(SF3.F3_LOJA) "
cQry += " ELSE 'C'" + cConcat + "(SF3.F3_CLIEFOR)" + cConcat + "(SF3.F3_LOJA) END ) AND "
cQry += " C1H.D_E_L_E_T_ = ' ' "

Return cQry

//---------------------------------------------------------------------
/*/{Protheus.doc} GetVldParams
@type		 Static Function
@description Funcao responsavel por criar um objeto FWPreparedStatement() e setar a query de pesquisa
Verificado que se utilizar a V5R no LEFTJOIN, no caso de volumetria alta (>150.000), 
fica mais lento doque 10 consultas dos registros paginados.
@author		 Denis Souza
@since		 12/07/2022
@return		 lRet - Indica se o funcao aceitou a execução do processo
/*/
//---------------------------------------------------------------------
Static Function V5RERPKEY()

Local cQuery := ''
Local cSGBD  	:= Upper(Alltrim(TCGetDB())) //Banco de dados que esta sendo utilizado 
Local oStatPesq := Nil

cQuery := " SELECT "
cQuery += " V5R.R_E_C_N_O_ RECNOV5R, "

If cSGBD $ "MSSQL7|MSSQL"
	cQuery += "ISNULL(CONVERT(VARCHAR(3000), V5R.V5R_MSGERR),' ') MSGV5R "
ElseIf cSGBD $ "ORACLE"
	cQuery += "NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(V5R.V5R_MSGERR,3000,1)),'') MSGV5R "
ElseIf cSGBD $ "POSTGRES"
	cQuery += "ENCODE(V5R.V5R_MSGERR,'escape') MSGV5R "
EndIf

cQuery += " FROM " + RetSqlName('V5R') + " V5R "
cQuery += " WHERE V5R.D_E_L_E_T_ = ' ' "
cQuery += " AND V5R.V5R_FILIAL = ? " //1
cQuery += " AND V5R.V5R_CODFIL = ? " //2
cQuery += " AND V5R.V5R_ALIAS  = ? " //3
cQuery += " AND RTRIM(V5R.V5R_ERPKEY) = ? " //4

oStatPesq := FWPreparedStatement():New()
oStatPesq:SetQuery(cQuery)

return oStatPesq
