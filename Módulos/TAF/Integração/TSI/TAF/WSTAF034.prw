#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTagNf     := 'invoice'
Static _cTmT9CTpI := lTrim(cValToChar(GetSx3Cache('T9C_TPINSC','X3_TAMANHO')))
Static _cTmT9CNrI := lTrim(cValToChar(GetSx3Cache('T9C_NRINSC','X3_TAMANHO')))
Static oHashC20   := HashC20()
Static oHashC30   := HashC30()
Static oHashC35   := HashC35()
Static oHashC39   := HashC39()
Static oHashT9Q   := HashT9Q()
Static oHashC2F   := HashC2F()
Static oHashC2D   := HashC2D()
Static oHashC21   := HashC21()
Static _cCposFake := "C20_TPOBR|T9Q_VERSAO|"
Static lV5rErp    := V5R->( FieldPos("V5R_ERPKEY") ) > 0
static _nTmINDOPE := GetSx3Cache( 'C20_INDOPE','X3_TAMANHO')
static _nTmCODMOD := GetSx3Cache( 'C20_CODMOD','X3_TAMANHO')
static _nTmSERIE  := GetSx3Cache( 'C20_SERIE' ,'X3_TAMANHO')
static _nTmSUBSER := GetSx3Cache( 'C20_SUBSER','X3_TAMANHO')
static _nTmNUMDOC := GetSx3Cache( 'C20_NUMDOC','X3_TAMANHO')
static _nTmDTDOC  := GetSx3Cache( 'C20_DTDOC' ,'X3_TAMANHO')
static _nTmCODPAR := GetSx3Cache( 'C20_CODPAR','X3_TAMANHO')
static _nTmCODFIL := GetSx3Cache( 'V5R_CODFIL','X3_TAMANHO')

/*----------------------------------------------------------------------
{Protheus.doc} WSTAF034
WS para persisitencia do cadastro de Nota Fiscal ao TAF
@type  WSRESTFUL
@author Henrique Pereira / Denis Souza
@since 08/11/2020
//----------------------------------------------------------------------*/
WSRESTFUL tsiinvoice DESCRIPTION "TAF Service Integration - Nota Fiscal"

    WSDATA sourceBranch             As string
    WSDATA page			            As integer optional
    WSDATA pageSize 	            As integer optional
    WSDATA order                    As string  optional
    WSDATA invoiceOf                As string  optional
    WSDATA invoiceUp                As string  optional
    WSDATA id                       As string  optional
    WSDATA modelIdentificationCode  As string  optional
    WSDATA operationType            As string  optional
    WSDATA documentType             As string  optional
    WSDATA taxDocumentIssuer        As string  optional
    WSDATA participatingCode        As string  optional 
    WSDATA identificationSituation  As string  optional 
    WSDATA taxDocumentSeries        As string  optional 
    WSDATA taxDocumentNumber        As string  optional 
    WSDATA fiscalDocumentDate       As string  optional

	WSMETHOD GET tsiinvoice;
    DESCRIPTION "Retorna uma lista de Nota Fiscal";
    PATH 'api/tsi/v1/tsiinvoice/';
    TTALK "tsiinvoice";
    WSSYNTAX "/tsiinvoice";
    PRODUCES APPLICATION_JSON
 
    WSMETHOD GET idTsiinvoice;
    DESCRIPTION "Retorna uma Nota Fiscal";
    PATH 'api/tsi/v1/tsiinvoice/idTsiinvoice/';
    TTALK "idTsiinvoice";
    WSSYNTAX "/tsiinvoice";
    PRODUCES APPLICATION_JSON

    WSMETHOD POST tsiinvoice; 
    DESCRIPTION "Inclui/altera uma lista de Nota Fiscal";
    PATH 'api/tsi/v1/tsiinvoice/';
    TTALK "tsiinvoice";
    WSSYNTAX "/tsiinvoice";
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT tsiinvoice;
    DESCRIPTION "Altera uma lista de Nota Fiscal";
    PATH 'api/tsi/v1/tsiinvoice/';
    TTALK "tsiinvoice";
    WSSYNTAX "/tsiinvoice";
    PRODUCES APPLICATION_JSON
 
    WSMETHOD DELETE tsiinvoice;
    DESCRIPTION "Delete uma Nota Fiscal";
    PATH 'api/tsi/v1/tsiinvoice/';
    TTALK "tsiinvoice";
    WSSYNTAX "/tsiinvoice";
    PRODUCES APPLICATION_JSON 

END WSRESTFUL

/*----------------------------------------------------------------------
{Protheus.doc} GET tsiinvoice
Metodo responsável por consultar a lista no cadastro de Nota Fiscal ao TAF
@param sourceBranch
@param page
@param pageSize
@param invoiceOf
@param invoiceUp
@param order
@type  WSMETHOD
@author Henrique Pereira / Denis Souza
@since 08/11/2020
//----------------------------------------------------------------------*/
WSMETHOD GET tsiinvoice WSREST TSIinvoice

    Local cNfDe     := ''
    Local cNfAte    := ''
    Local nPage     := 0
    Local nPageSize := 10
    Local xOrder    := ''

    oJsonResp := JsonObject():New()

    if VldExecute( self:sourceBranch, @oJsonResp )
        xOrder  :=  iif(valtype( self:order ) <> 'U' .and. !empty(self:order),self:order," ")
        If valtype( self:page ) <> 'U' .and. self:page > 0
            nPage := self:page
            if valtype( self:pageSize ) <> 'U' .and. self:pageSize > 0
                nPageSize := self:pageSize
            endif
        endif
        If valtype( self:invoiceOf ) <> 'U' .and. !Empty(self:invoiceOf)
            cNfDe := self:invoiceOf
        else
            cNfDe := ' '
        endif
        If valtype( self:invoiceUp ) <> 'U' .and. !Empty(self:invoiceUp)
            cNfAte := self:invoiceUp
        else
            cNfAte := replicate('Z',8)
        endif
        getWS034(@oJsonResp, cNfDe, cNfAte, nPage, nPageSize, xOrder)
    endif

    cJsonResp := FwJsonSerialize( oJsonResp ) //Serializa objeto Json
    Self:SetResponse( cJsonResp )
    freeobj(oJsonResp)
    cJsonResp := ''

Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} GET idTsiinvoice
Metodo responsável por consultar o Id no cadastro de Nota Fiscal ao TAF
@type  WSMETHOD
@author Henrique Pereira / Denis Souza
@since 08/11/2020
//----------------------------------------------------------------------*/
WSMETHOD GET idTsiinvoice WSRECEIVE sourceBranch, operationType, modelIdentificationCode, taxDocumentSeries, taxDocumentNumber, fiscalDocumentDate, participatingCode WSREST TSIinvoice

    Local cJsonResp As character
    Local cOperType As character
    Local cCodMod   As character
    Local cSerie    As character
    Local cNumDoc   As character
    Local cDateDoc  As character
    Local cAlias    As character
    Local cPartCod  As character

    Local nStruct   As numeric
    Local nPos      As numeric
    Local nPageAux  As numeric
    Local aStruct   As array
    Local oJsonResp As object
    Local lOk       As logical
    Local cUrl      As character

    lOk       := valtype( self:modelIdentificationCode ) <> 'U' .and. !empty(self:modelIdentificationCode)
    cOperType := iif(valtype( self:operationType ) <> 'U' .and. !empty(self:operationType),self:operationType," ") //0=Entrada;1=Saída;
    cCodMod   := iif(valtype( self:modelIdentificationCode ) <> 'U' .and. !empty(self:modelIdentificationCode),self:modelIdentificationCode," ") //55	NOTA FISCAL ELETRONICA NF-E
    cSerie    := iif(valtype( self:taxDocumentSeries ) <> 'U' .and. !empty(self:taxDocumentSeries),self:taxDocumentSeries," ")
    cNumDoc   := iif(valtype( self:taxDocumentNumber ) <> 'U' .and. !empty(self:taxDocumentNumber),self:taxDocumentNumber," ")
    cDateDoc  := iif(valtype( self:fiscalDocumentDate ) <> 'U' .and. !empty(self:fiscalDocumentDate),self:fiscalDocumentDate," ") //20201015
    cPartCod  := iif(valtype( self:participatingCode ) <> 'U' .and. !empty(self:participatingCode),self:participatingCode," ")

    cAlias  := cTagJson := cJsonResp := ''
    nPos    := nPageAux := 0
    nStruct := 1

    aStruct   := {}
    oJsonResp := JsonObject():New()
    cUrl      := 'https://api.totvs.com.br/'

    if VldExecute( self:sourceBranch, @oJsonResp )
        getWS034( @oJsonResp, cNumDoc, cNumDoc, nil, nil, "C20_NUMDOC", cCodMod, cOperType, cPartCod, cSerie, cDateDoc )
        if !lOk
            SetErroJs( @oJsonResp, cTagNf, , cUrl, '404' )
        endif
    endif

    cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
    Self:SetResponse( cJsonResp )
    freeobj(oJsonResp)
    cJsonResp := ''
    fwFreeArray(aStruct)
    lOk := .F.

Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} POST tsiinvoice
Persisti operações de inclusão no cadastro de Nota Fiscal ao TAF
@type  WSMETHOD
@author Henrique Pereira / Denis Souza
@since 08/11/2020
//----------------------------------------------------------------------*/
WSMETHOD POST tsiinvoice WSREST TSIinvoice
    Ws034Prep(self)
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} PUT tsiinvoice
Persisti operações de alteração de cadastro Nota Fiscal ao TAF
@type  WSMETHOD
@author Henrique Pereira / Denis Souza
@since 08/11/2020
//----------------------------------------------------------------------*/
WSMETHOD PUT tsiinvoice WSREST TSIinvoice
    Ws034Prep(self)
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} DELETE tsiinvoice
Persisti operações de deleção de cadastro Nota Fiscal ao TAF
@type  WSMETHOD
@author Henrique Pereira / Denis Souza
@since 08/11/2020
//----------------------------------------------------------------------*/
WSMETHOD DELETE tsiinvoice WSRECEIVE sourceBranch, operationType, modelIdentificationCode, taxDocumentSeries, taxDocumentNumber, fiscalDocumentDate, participatingCode WSREST TSIinvoice

Local cJsonResp As character
Local cCodMod   As character
Local cOperType As character
Local cPartCod  As character
Local cSerie    As character
Local cNumDoc   As character
Local cDateDoc  As character
Local cSubSer   As character
Local cUrl      As character
Local oJsonResp As object

oJsonResp   := JsonObject():New() // retorno
cJsonResp   := ''
cSubSer     := ''

cCodMod     := iif(valtype( self:modelIdentificationCode ) <> 'U' .and. !empty(self:modelIdentificationCode),self:modelIdentificationCode," ")
cOperType   := iif(valtype( self:operationType ) <> 'U' .and. !empty(self:operationType),self:operationType," ")
cPartCod    := iif(valtype( self:participatingCode ) <> 'U' .and. !empty(self:participatingCode),self:participatingCode," ")
cSerie      := iif(valtype( self:taxDocumentSeries ) <> 'U' .and. !empty(self:taxDocumentSeries),self:taxDocumentSeries," ")
cNumDoc     := iif(valtype( self:taxDocumentNumber ) <> 'U' .and. !empty(self:taxDocumentNumber),self:taxDocumentNumber," ")
cDateDoc    := iif(valtype( self:fiscalDocumentDate ) <> 'U' .and. !empty(self:fiscalDocumentDate),self:fiscalDocumentDate," ")

cUrl := 'https://api.totvs.com.br/'

if VldExecute( self:sourceBranch, @oJsonResp )

    C01->( DbSetOrder(1) )
    cCodMod := ValCodMod(padr(XFUNCh2ID( cCodMod, 'C01' , 1 , ,.T.), tamsx3('C20_CODMOD')[1]))

    cOperType := padr( cOperType, tamsx3('C20_INDOPE')[1] )

    C1H->( DbSetOrder(1) )
    cPartCod := padr(XFUNCh2ID(cPartCod, 'C1H' , 1 , ,.T.), tamsx3('C20_CODPAR')[1])

    cSerie   := padr( cSerie ,  tamsx3('C20_SERIE')[1]  )
    cSubSer  := padr( cSubSer,  tamsx3('C20_SUBSER')[1] )
    cNumDoc  := padr( cNumDoc,  tamsx3('C20_NUMDOC')[1] )
    cDateDoc := padr( cDateDoc, tamsx3('C20_DTDOC')[1]  )

    C20->( DbSetOrder(5) ) //C20_FILIAL, C20_INDOPE, C20_CODMOD, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_DTDOC, C20_CODPAR, R_E_C_N_O_, D_E_L_E_T_    
    If C20->( DbSeek( xfilial('C20') + cOperType + cCodMod + cSerie + cSubSer + cNumDoc + cDateDoc + cPartCod ) )
        oModel := FWLoadModel( 'TAFA062' )
        oModel:DeActivate()
        oModel:SetOperation( 5 )
        oModel:Activate()
        FwFormCommit( oModel )

        oJsonResp[cTagNf] := {}
        SetErroJs( @oJsonResp, cTagNf,{},,"403" )
    else
        SetErroJs( @oJsonResp,,,,'404' )
    Endif
else
    SetErroJs( @oJsonResp,,,cUrl,'400' )
endif

cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )

Return .T.

/*--------------------------------------------------------------------------------
{Protheus.doc} Ws034Prep()
Faz a carga do modelo fora de laco de repeticao.
@author Denis Souza / karen
@since 13/12/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Static Function Ws034Prep(oBjWS034)

Local oModel   := Nil
Local oMldC20  := Nil
Local oMldC30  := Nil
Local oMldC35  := Nil
Local oMldC39  := Nil
Local oMldT9Q  := Nil
Local oMldC2F  := Nil
Local oMldC2D  := Nil
Local oMldC21  := Nil
Local lERP     := .F.
Local aJsonDoc := {}
Local oTsiNFis := TSINFISCAL():Create()

oModel  := FwLoadModel( "TAFA062" ) //Carrego modelo fora do laco
oMldC20 := oModel:GetModel( 'MODEL_C20' )
oMldC30 := oModel:GetModel( 'MODEL_C30' )
oMldC35 := oModel:GetModel( 'MODEL_C35' )
oMldC39 := oModel:GetModel( 'MODEL_C39' )
oMldT9Q := oModel:GetModel( 'MODEL_T9Q' )
oMldC2F := oModel:GetModel( 'MODEL_C2F' )
oMldC2D := oModel:GetModel( 'MODEL_C2D' )
oMldC21 := oModel:GetModel( 'MODEL_C21' )

DbSelectArea("V5R")
V5R->(DbSetOrder(1)) //V5R_FILIAL, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY

DbSelectArea("C20")
C20->( DbSetOrder(5) ) //C20_FILIAL, C20_INDOPE, C20_CODMOD, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_DTDOC, C20_CODPAR, C20_CODSIT, C20_PROCID, R_E_C_N_O_, D_E_L_E_T_

Ws034Proc( oBjWS034, lERP, aJsonDoc, oTsiNFis, oModel, oMldC20, oMldC30, oMldC35, oMldC39, oMldT9Q, oMldC2F, oMldC2D, oMldC21 )

Return Nil

/*--------------------------------------------------------------------------------
{Protheus.doc} GetNf()
(Responsável por executar a consulta ao cadastro da Nota Fiscal)
@author Henrique Pereira
@since 07/11/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function GetNf( cNfDe, cNfAte, nPage, nPageSize, cOrder, cCodMod, cOperType, cPartCod, cSerie, cDateDoc, cIndEmi )

Local cAlias      := getNextAlias()
Local oStatement  := FWPreparedStatement():New()
Local lFilMod     := .F.
Local lFilPart    := .F.

Default cNfDe     := ''
Default cNfAte    := ''
Default cOrder    := ''
Default nPage     := 0
Default nPageSize := 0
Default cCodMod   := ''
Default cOperType := ''
Default cPartCod  := ''
Default cSerie    := ''
Default cIndEmi   := ''

if nPage == 0    ; nPage := 1     ; endif
if nPageSize == 0; nPageSize := 10; endif

//Tratamento LookUps
cCodMod := GetTafId( 'C01', cCodMod, 1 )
lFilMod := !empty(cCodMod) .And. Upper(Alltrim(cCodMod)) <> "NOTFOUND"

cPartCod := GetTafId( 'C1H', cPartCod, 5 )
lFilPart := !empty(cPartCod) .And. Upper(Alltrim(cPartCod)) <> "NOTFOUND"

cConvDt := ''
if valtype(cDateDoc) == 'C' .And. Len(StrTokArr(cDateDoc,"/"))==3 //15/10/2020 ou 15/10/20
    cConvDt := 'Dtos(CtoD(cDateDoc))'
elseif valtype(cDateDoc) == 'C' .And. Len(StrTokArr(cDateDoc,"/"))==0 //20201015
    cConvDt := 'DtoS(StoD(cDateDoc))'
elseif valtype(cDateDoc) == 'D' //integracao direta protheus
    cConvDt := 'DtoS(cDateDoc)'
endif

cQry := " SELECT C20.C20_STAMP, C20.C20_FILIAL, C20.C20_CHVNF, C20.R_E_C_N_O_ "
cQry += " FROM " + RetSqlName('C20') + " C20 "
cQry += " WHERE C20.D_E_L_E_T_ = ' ' "
cQry += " AND C20.C20_FILIAL = ? " //1

if lFilMod //2
    cQry += " AND C20.C20_CODMOD = ? "
endif

if !empty(cOperType) //3
    cQry += " AND C20.C20_INDOPE = ? "
endif

if lFilPart //4
    cQry += " AND C20.C20_CODPAR = ? "
endif

if !empty(cSerie) //5
    cQry += " AND C20.C20_SERIE = ? "
endif

cQry += " AND C20.C20_NUMDOC BETWEEN ? AND ? " //6 7

if !Empty(cConvDt) //8
    cQry += " AND C20.C20_DTDOC = ? "
endif

if !Empty(cIndEmi) //9
    cQry += " AND C20.C20_INDEMI = ? "
endif

if !empty(cOrder)
    cQry += " ORDER BY C20." + cOrder
else
    cQry += " ORDER BY 1 "
endif

cQry += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nPageSize) + " ) ROWS "
cQry += " FETCH NEXT " + cValToChar(nPageSize+1) + " ROWS ONLY "

oStatement:SetQuery(cQry)

nQtField := 1 //1
oStatement:SetString(nQtField,xFilial('C20'))

if lFilMod
   nQtField++ //2
   oStatement:SetString(nQtField,cCodMod)
endif

if !empty(cOperType)
    nQtField++ //3
    oStatement:SetString(nQtField,cOperType)
endif

if lFilPart
    nQtField++ //4
    oStatement:SetString(nQtField,cPartCod)
endif

if !empty(cSerie)
    nQtField++ //5
    oStatement:SetString(nQtField,cSerie)
endif

nQtField++ //6
oStatement:SetString(nQtField,cNfDe)

nQtField++ //7
oStatement:SetString(nQtField,cNfAte)

if !empty( cConvDt )
    nQtField++ //8
    cDateDoc := &(cConvDt)
    oStatement:SetString(nQtField,cDateDoc)
endif

if !empty(cIndEmi)
    nQtField++ //9
    oStatement:SetString(nQtField,cIndEmi)
endif

TafConout('query item' + oStatement:GetFixQuery())
dbUseArea(.T., "TOPCONN", TCGenQry(, , oStatement:GetFixQuery()), cAlias, .F., .T.)

Return cAlias

/*----------------------------------------------------------------------
{Protheus.doc} getWS034()
Executa a query de consulta para o retorno ao método get, e monta o json de resposta
@author Henrique Pereira / Denis Souza
@since 09/11/2020
//----------------------------------------------------------------------*/
function getWS034(oJsonResp, cNfDe, cNfAte, nPage, nPageSize, xOrder, cCodMod, cOperType, cPartCod, cSerie, cDateDoc )

Local cJsonResp     as character
Local cAlias        as character
Local cAliasIte     as character
Local cAlsItTrib    as character
Local cAlsTotTri    as character
Local cUrl          as character
Local lC2FCredSt    as character
Local lC2FVlSCre    as character

Local nStruct       as numeric
Local nPos          as numeric
Local nPageAux      as numeric
Local nPageIte      as numeric
Local nQtItem       as numeric
Local nlA           as numeric
Local nlB           as numeric
Local nTmC30        as numeric
Local nTmC35        as numeric
Local nTmC39        as numeric
Local nTmT9Q        as numeric
Local nTmC2F        as numeric
Local nQtNt         as numeric
Local nTmC2D        as numeric
Local nTmC21        as numeric

Local lHasNext      as logical

Local aStructC20    as array
Local aStructC30    as array
Local aStructC35    as array
Local aStructC39    as array
Local aStructT9Q    as array
Local aStructC2F    as array
Local aStructC2D    as array
Local aStructC21    as array

Local oModel        as object
Local oMdlC20       as object
Local oMdlC30       as object
Local oMdlC35       as object
Local oMdlC39       as object
Local oMdlT9Q       as object
Local oMdlC2F       as object
Local oMdlC2D       as object
Local oMdlC21       as object

Local oJsonItem     as object
Local oJsIteTrib    as object
Local oJsTotTrib    as object
Local oJsCTransp    as object
Local oJsIndSus     as object
Local oJsAjuInf     as object
Local oJsInfComp    as object
Local oJsInfTick    as object

Default nPageSize := 10

lC2FCredSt := TAFColumnPos( "C2F_CREDST" )
lC2FVlSCre := TAFColumnPos( "C2F_VLSCRE" )
cJsonResp  := ''
cAlias     := ''
cAliasIte  := ''
cAlsItTrib := ''
cAlsTotTri := ''
cTagJson   := ''
cOrder     := ''
cUrl       := 'https://api.totvs.com.br/'
nStruct    := 0
nPageIte   := 0
nPageAux   := 0
nPos       := 0
nQtItem    := 0
nlA        := 0
nlB        := 0
nTmC30     := 0
nTmC35     := 0
nTmC39     := 0
nTmC2F     := 0
nTmC2D     := 0
nTmC21     := 0
nQtNt      := 0

lHasNext   := .F.

aStructC20 := {}
aStructC30 := {}
aStructC35 := {}
aStructC2F := {}
aStructC21 := {}

oJsonItem  := JsonObject():New()
oJsIteTrib := JsonObject():New()
oJsTotTrib := JsonObject():New()
oJsCTransp := JsonObject():New()
oJsIndSus  := JsonObject():New()
oJsAjuInf  := JsonObject():New()
oJsInfComp := JsonObject():New()
oJsInfTick := JsonObject():New()

oModel  := Nil
oMdlC20 := Nil
oMdlC30 := Nil
oMdlC35 := Nil
oMdlC39 := Nil
oMdlT9Q := Nil
oMdlC2F := Nil
oMdlC2D := Nil
oMdlC21 := Nil

hmget( oHashC20, "taxDocumentNumber", @cOrder )

// executo a query do cabeçalho da nota fiscal
cAlias := GetNf( cNfDe, cNfAte, nPage, nPageSize, cOrder, cCodMod, cOperType, cPartCod, cSerie, cDateDoc )

//monto as estruturas para serem passadas a getJson
aStructC20 := TsiStruct( C20->(DBStruct()), oHashC20 )
aStructC30 := TsiStruct( C30->(DBStruct()), oHashC30 )
aStructC35 := TsiStruct( C35->(DBStruct()), oHashC35 )
aStructC39 := TsiStruct( C39->(DBStruct()), oHashC39 )
aStructT9Q := TsiStruct( T9Q->(DBStruct()), oHashT9Q )
aStructC2F := TsiStruct( C2F->(DBStruct()), oHashC2F )
aStructC2D := TsiStruct( C2D->(DBStruct()), oHashC2D )
aStructC21 := TsiStruct( C21->(DBStruct()), oHashC21 )

//adiciona campo fake
aadd(aStructC20, {"C20_TPOBR", "C", 1, 0})
aadd(aStructT9Q, {"T9Q_VERSAO", "C", 14, 0})

DbSelectArea("C20")
C20->(dbSetOrder(4)) //C20_FILIAL, C20_CHVNF

//Carrega Modelo fora do laco
oModel := FwLoadModel( "TAFA062" )

while (cAlias)->(!eof())
    if C20->(DbSeek( (cAlias)->C20_FILIAL + (cAlias)->C20_CHVNF ))
        nPageAux++
        oModel:SetOperation( 1 )
        oModel:Activate()

        oMdlC20 := oModel:GetModel("MODEL_C20")

        if nPageAux <= nPageSize
            /*-----------------------------------
            |               CAPA                |
            ------------------------------------*/
            getJson( @oJsonResp, oHashC20, aStructC20, @oMdlC20, cTagNf, nPageAux )
            /*-----------------------------------
            |               ITEM                |
            ------------------------------------*/
            oMdlC30 := oModel:GetModel("MODEL_C30")
            nTmC30  := oMdlC30:Length()
            for nlA := 1 to nTmC30
                oMdlC30:GoLine( nlA )
                getJson( @oJsonItem, oHashC30, aStructC30, @oMdlC30, 'fiscalDocumentItems', nlA )

                /*-----------------------------------
                |           TRIBUTOS POR ITEM       |
                ------------------------------------*/
                oMdlC35 := oModel:GetModel("MODEL_C35")
                nTmC35  := oMdlC35:Length()
                if nTmC35 > 0
                    oJsonItem["fiscalDocumentItems"][nlA]['valuesByTaxPerItem'] := { }
                    for nlB := 1 to nTmC35
                        oMdlC35:GoLine( nlB )
                        getJson( @oJsIteTrib, oHashC35, aStructC35, @oMdlC35, 'valuesByTaxPerItem' )
                    next nlB
                    oJsonItem["fiscalDocumentItems"][nlA]['valuesByTaxPerItem'] := oJsIteTrib['valuesByTaxPerItem']
                    oJsIteTrib['valuesByTaxPerItem'] := {}
                endif
                /*-----------------------------------------------
                |    AJUSTE DE INFORMAÇÕES - DOCUMENTO FISCAL   |
                ------------------------------------------------*/

                oMdlC2D := oModel:GetModel("MODEL_C2D") 
                nTmC2D  := oMdlC2D:Length()
                if nTmC2D > 0
                    oJsonItem["fiscalDocumentItems"][nlA]['otherTaxObligationsAdjustmentsAndInformation'] := { }
                    for nlB := 1 to nTmC2D
                        oMdlC2D:GoLine( nlB )
                        getJson( @oJsAjuInf, oHashC2D, aStructC2D, @oMdlC2D, 'otherTaxObligationsAdjustmentsAndInformation' )
                    next nlB
                    oJsonItem["fiscalDocumentItems"][nlA]['otherTaxObligationsAdjustmentsAndInformation'] := oJsAjuInf['otherTaxObligationsAdjustmentsAndInformation']
                    oJsAjuInf['otherTaxObligationsAdjustmentsAndInformation'] := {}
                endif

                /*-----------------------------------
                |    COMPLEMENTO DE TRANSPORTE      |
                ------------------------------------*/
                oMdlC39 := oModel:GetModel("MODEL_C39")
                nTmC39  := oMdlC39:Length()
                if nTmC39 > 0
                    oJsonItem["fiscalDocumentItems"][nlA]['transportComplement'] := { }
                    for nlB := 1 to nTmC39
                        oMdlC39:GoLine( nlB )
                        getJson( @oJsCTransp, oHashC39, aStructC39, @oMdlC39, 'transportComplement' )
                    next nlB
                    oJsonItem["fiscalDocumentItems"][nlA]['transportComplement'] := oJsCTransp['transportComplement']
                    oJsCTransp['transportComplement'] := {}
                endif

                /*--------------------------------------------------------------------
                |    INDICATIVO DE SUSPENSÃO POR PROCESSO JUDICIAL/ADMINISTRATIVO    |
                ---------------------------------------------------------------------*/
                oMdlT9Q := oModel:GetModel("MODEL_T9Q")
                nTmT9Q  := oMdlT9Q:Length()
                if nTmT9Q > 0
                    oJsonItem["fiscalDocumentItems"][nlA]['indicativeOfSuspensionByJudicialProcess'] := { }
                    for nlB := 1 to nTmT9Q
                        oMdlT9Q:GoLine( nlB )
                        getJson( @oJsIndSus, oHashT9Q, aStructT9Q, @oMdlT9Q, 'indicativeOfSuspensionByJudicialProcess' )
                    next nlB
                    oJsonItem["fiscalDocumentItems"][nlA]['indicativeOfSuspensionByJudicialProcess'] := oJsIndSus['indicativeOfSuspensionByJudicialProcess']
                    oJsIndSus['indicativeOfSuspensionByJudicialProcess'] := {}
                endif
            next nlA

            /*-----------------------------------
            |           TRIBUTOS CAPA           |
            ------------------------------------*/
            oMdlC2F := oModel:GetModel("MODEL_C2F")
            nTmC2F  := oMdlC2F:Length()
            if nTmC2F > 0
                nQtNt := len(oJsonResp[cTagNf])
                oJsonResp[cTagNf][nQtNt]['valuesByTax'] := {}
                for nlA := 1 to nTmC2F
                    oMdlC2F:GoLine( nlA )
                    getJson(@oJsTotTrib, oHashC2F, aStructC2F, @oMdlC2F, 'valuesByTax' )
                next nlA
                oJsonResp[cTagNf][nQtNt]['valuesByTax'] := oJsTotTrib['valuesByTax']
                oJsTotTrib['valuesByTax'] := {}
            endif

            /*-----------------------------------
            |     INFORMAÇÕES COMPLEMENTARES     |
            ------------------------------------*/
            oMdlC21 := oModel:GetModel("MODEL_C21")
            nTmC21  := oMdlC21:Length()
            if nTmC21 > 0
                nQtNt := len(oJsonResp[cTagNf])
                oJsonResp[cTagNf][nQtNt]['complementaryInformationByTaxDocument'] := {}
                for nlA := 1 to nTmC21
                    oMdlC21:GoLine( nlA )
                    getJson(@oJsInfComp, oHashC21, aStructC21, @oMdlC21, 'complementaryInformationByTaxDocument' )
                next nlA
                oJsonResp[cTagNf][nQtNt]['complementaryInformationByTaxDocument'] := oJsInfComp['complementaryInformationByTaxDocument']
                oJsInfComp['complementaryInformationByTaxDocument'] := {}
            endif

            /*----------------------------------------------
            |     FATURAS DO DOCUMENTO FISCAL T013AI (C29)  |
            -----------------------------------------------*/
			/* Retirado 19/03/2025 pois o TAF não considera a tabela C29 em nenhuma das obrigacoes.
			Com esse trecho retirado (SE1\SE2), a query que estava sendo executado em 6 horas na JadLog, abaixou para 7 minutos.
			Caso necessite do NUMFAT, verificar historico no TFS para recuparar a query e suas amarracoes. */
        else
            lHasNext := .T.
        EndIf

        //Agrega o json isolado do item ao json de resposta, encaixa um nó no outro
        //TAFConOut("Json Item >>>>>>>>>>>>> " + cvaltochar(oJsonItem:tojson() ))
        oJsonResp[cTagNf][len(oJsonResp[cTagNf])]['fiscalDocumentItems'] := oJsonItem['fiscalDocumentItems']

        oModel:DeActivate()
    EndIf

    (cAlias)->(DbSkip())
EndDo

If cNfDe <> cNfAte; oJsonResp["hasnext"] := lHasNext ; endif

If Select(cAlias) > 0; (cAlias)->(dbCloseArea()); EndIf

Return oJsonResp

/*----------------------------------------------------------------------
{Protheus.doc} getJson()
Motor que realiza de para de campo com hash para parsear registros em json.
Monta o objeto json de forma automatizada.
@type  Static Function
@author Henrique Pereira / Denis Souza
@since 11/11/2020
//----------------------------------------------------------------------*/
Static Function getJson(oJsonResp, oHash, aStruct, oMdl, cTag, nPageAux)
Local nAte       := 0
Local nStruct    := 0
Local nPos       := 0
Local cPosition  := ''
Local cTagJson   := ''
Local xCnt       := Nil
Default nPageAux := 0

if nPageAux == 1
    oJsonResp[cTag] := {}
endif
if cTag $ "valuesByTaxPerItem|valuesByTax|transportComplement|otherTaxObligationsAdjustmentsAndInformation|indicativeOfSuspensionByJudicialProcess|complementaryInformationByTaxDocument|ticketsByInvoice" //argument #0 error, expected A->U    
    if valtype( oJsonResp[cTag] ) == 'U'
        oJsonResp[cTag] := {}
    endif
endif
aAdd( oJsonResp[cTag],JsonObject():New())
nAte := Len(aStruct)
for nStruct := 1 to nAte
    if hmget( oHash, alltrim(aStruct[nStruct][1]) + "#DT#", @cTagJson )
        nPos := Len(oJsonResp[cTag])
        xCnt := &('oMdl:GetValue(aStruct[nStruct][1])')
        if valtype( xCnt ) == 'C'
            oJsonResp[cTag][nPos][cTagJson] := dtoc(stod( xCnt ))
        else //Tipo Data
            oJsonResp[cTag][nPos][cTagJson] := dtoc( xCnt )
        endif
    elseif hmget( oHash, alltrim(aStruct[nStruct][1]), @cTagJson ) //Busca Demais Campos
        nPos := Len(oJsonResp[cTag])
        if Ws034VldGet(@oJsonResp, aStruct[nStruct][1], @oMdl, cTag, nPos, cTagJson )                
            if hmget( oHash, alltrim(aStruct[nStruct][1]) + "#POSIC#", @cPosition ) //Executa o posicione para não retornar o ID e sim o código
                xCnt := &cPosition
                if valtype( xCnt ) == 'N'
                    oJsonResp[cTag][nPos][cTagJson] := xCnt
                else
                    oJsonResp[cTag][nPos][cTagJson] := Alltrim( xCnt )
                endif
            else
                xCnt := &('oMdl:GetValue(aStruct[nStruct][1])')
                if valtype( xCnt ) == 'N'
                    oJsonResp[cTag][nPos][cTagJson] := xCnt
                else
                    oJsonResp[cTag][nPos][cTagJson] := AllTrim( xCnt )
                endif
            endif
            //TAFConOut("Dentro de getJson: " + cvaltochar( oJsonResp[cTag][nPos][cTagJson] ) )
        endif
    endif
Next nStruct

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} Ws034VldGet()
No caso de conteúdo vazio para retorno ao get, retorna com 0 se for campo 
numerico e '' se for outro tipo de dado.
@author Henrique Pereira / Denis Souza
@since 12/11/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Static Function Ws034VldGet( oJsonResp, cField, oMdl, cTag, nPos, cTagJson )

    Local lRet      As Logical
    Local cTypeUtil As Character

    If ! (cField $ _cCposFake)
        cTypeUtil := FWSX3Util():GetFieldType( cField )
        lRet      := .F.
        xCont     := &('alltrim(cValToChar(oMdl:GetValue("'+cField+'")))')

        If Empty(xCont) .Or. (cTypeUtil == "N" .And. xCont == "0")
            lRet := .F.
            Do Case
            Case cTypeUtil == 'N'
                oJsonResp[cTag][nPos][cTagJson] := 0
            Otherwise
                oJsonResp[cTag][nPos][cTagJson] := ''
            EndCase
        Else
            lRet := .t.
        EndIf
    Else
        lRet := .T.
    EndIf    
Return lRet

/*----------------------------------------------------------------------
{Protheus.doc} Ws034Proc()
Funcao responsável iniciar o processamento do Post ou Put
@author Denis Souza
@since 22/12/2020
@return Nil, nulo, não tem retorno. 
//----------------------------------------------------------------------*/
Function Ws034Proc( oBjWS034, lERP, aJsonDoc, oTsiNFis, oModel, oMldC20, oMldC30, oMldC35, oMldC39, oMldT9Q, oMldC2F, oMldC2D, oMldC21 ) 

Local cJsonResp  := ""
Local cFilProc   := ""
Local xRet       := Nil
Local oBjJson    := JsonObject():New() // Requisição
Local oJsonResp	 := JsonObject():New() // retorno
Local nQtd       := 0
Local nAte       := 0
Local aRetJs     := {}
Local i          := 0
Local nLenJSon   := 1
Local oError     := ErrorBlock({|e| Conout("ERRO na função WSTAF034: " +e:Description +"- Thread " + cValtoChar(ThreadId()) + " " + Time()+ "ERRORSTACK:"	+ Chr(10)+Chr(13) + e:ErrorStack , sleep(3000))})
Local nProcReg   := 0

Default lERP        := .F.
Default aJsonDoc    := {}
Default oTsiNFis    := Nil
Begin Sequence	
if lErp; nLenJSon := len(aJsonDoc); endif // Se foi chamado pelo ERP, pego o tamanho do array passado no parâmetro.

for i := 1 to nLenJSon
    if lERP
        oBjJson := aJsonDoc[i]
    elseif VldExecute( oBjWS034:sourceBranch, @oJsonResp, @cFilProc )
        cBody := oBjWS034:GetContent( )
        xRet := oBjJson:fromJSON( cBody ) // quando xRet nulo eh sucesso no parser
    endif
    if ValType(xRet) == "U" .And. ValType( oBjJson["invoice"] ) == 'A'  //JsonObject populado com sucesso
        nProcReg++
        nAte := len( oBjJson["invoice"] )
        for nQtd := 1 to nAte
            if nQtd == 1
                oJsonResp[cTagNf] := {}
            endif
            //Tafconout('antes Ws034PutPost - '+oBjJson["invoice"][nQtd]['taxDocumentNumber']+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
            if !Ws034PutPost( oBjJson["invoice"][nQtd], @aRetJs, @oJsonResp, @oModel, @oMldC30, @oMldC35, @oMldC2F, @oMldC39, @oMldC2D, @oMldT9Q, @oMldC21, @oMldC20, @oTsiNFis )
                //Tafconout('apos Ws034PutPost - Erro lSucessItem'+oBjJson["invoice"][nQtd]['taxDocumentNumber']+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
            Endif
            FreeObj(oBjJson['invoice'][nQtd])
        next nQtd        
        SetErroJs(@oJsonResp, cTagNf, @aRetJs,,'403') //Retorna possíveis erros que possam ter ocorrido na integração.
        //Para o TSI, depois que processou o for interno e foi limpando a posicao do FreeObj(oBjJson['invoice'][nQtd]), nao tem tem a necessidade de rodar o primeiro for novamente.
        if isInCallStack("TSI")
            exit
        endif
    else //Erro de Estrutura
        Tafconout('Erro de estrutura- Thread ' + cValtoChar(ThreadId()),1,.t.,"TSI")
        SetErroJs( @oJsonResp,,,,'400' )
    endif
next i

//Tafconout(cValToChar(nProcReg)+' = nProcReg - Total proc'+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")

if !lERP
    cJsonResp := FwJsonSerialize( oJsonResp ) //Serializa objeto Json Apenas API
    oBjWS034:SetResponse( cJsonResp )
endif
End Sequence	

ErrorBlock(oError)

Return Nil
/*----------------------------------------------------------------------
{Protheus.doc} Ws034PutPost()
Funcao que efetua inclusao e alteracao a Nota e seus respectivos itens.
@author Henrique Pereira / Denis Souza
@since 07/07/2020
@return Nil, nulo, não tem retorno. 
//----------------------------------------------------------------------*/
Function Ws034PutPost(aObjJson, aRetJs, oJsonResp, oModel, oMldC30, oMldC35, oMldC2F, oMldC39, oMldC2D, oMldT9Q, oMldC21, oMldC20, oTsiNFis )

Local nI          := 0
Local nOpcao      := 0
Local cSource     := ''
Local cKey        := ''
Local cKeySeek    := ''
Local cSeek       := ''
Local cKeyErp     := ''
Local cC20Chv     := ''
Local cWarning    := ''
Local lSucessItem := .T.
Local lGrv        := .T.
Local cNewStamp   := ''
Local lSameStamp  := .f.
Local cChv        := ''
Local lErrorModel := .F.

Private cIndOpe   :=  ''

Default aObjJson  := {}
Default aRetJs    := {}
Default oJsonResp := Nil
Default oModel    := Nil
Default oMldC30   := Nil
Default oMldC35   := Nil
Default oMldC2F   := Nil
Default oMldC39   := Nil
Default oMldC2D   := Nil
Default oMldT9Q   := Nil
Default oMldC21   := Nil
Default oMldC20   := Nil
Default oTsiNFis  := Nil

hmget( oHashC20, "s_o_u_r_c_e_", @cSource  )
hmget( oHashC20, "k_e_y_"      , @cKeySeek )
hmget( oHashC20, "s_e_e_k_"    , @cSeek    )
hmget( oHashC20, "k_e_y_e_r_p_", @cKeyErp  )

//Protecao para nao ocorrer erro na macroexecucao caso algum campo da chave nao seja enviado, o mesmo sera nulo e ocorrera falha nas conversoes, ex: DTOS(CTOD(null))
VldC20Chv(aObjJson, @cWarning)

if Empty(cWarning) //caso nao encontre inconsistencias

    cKey := &cKeySeek //chave completa sem a filial para utilizar na gravacao do log
    //Antes havia uma verificacao atraves de query se a nota existia no cSeek ( NfExist ) 
    //devido nao possuirmos todas as chaves e a situacao que estava entrando poderia ser de cancelamento
    //macro execucao com consulta por query, pois a situacao pode ser alterada (quando excluida ou cancelada uma nota no Protheus)
    //e faz parte da chave por esse motivo nao deve ser utilizado o dbseek que contenha a situacao.

    //Depois foi entendido que o esforco de fazer a macroexecucao da query NfExist a cada nota era inviavel,
    //entao foi colocado C1H/C20 na query do TAFA574 para trazer o recno na query e fazer DbGoTo
    //ficou melhor doque a opcao mencionada acima

    //Agora na JadLog a query de extracao estava levando mais de 1h30m para executar devido os joins com a C1H e C20
    //foi retirado o join com C1H e C20 e o campo de RECNO da tag aObjJson["existC20"]
    //dessa forma, agora esta utilizando o indice 5 e fazendo posicionamento com seek e usando Hash nos códigos do modelo e participante.
    //Nesse modelo a query de extração passou a executar rapidamente em menos de 10 minutos.

    C20->( DbSetOrder(5) ) //C20_FILIAL, C20_INDOPE, C20_CODMOD, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_DTDOC, C20_CODPAR, R_E_C_N_O_, D_E_L_E_T_

	//Controle para inativar o RPS caso a nova inclusão seja uma nota eletrônica.
    //se forem iguais significa que o tipo eh saida e tem um codiss preenchido entao assumiu o FT_NFELETR,
    //alem disso no taf nao tem um tipo RPS, por isso foi adicionado mais um controle direto da especie da SFT.
    if aObjJson["especie"] == 'RPS' .And. aObjJson["electronicInvoice"] == aObjJson['taxDocumentNumber']
        cChv := ModelChvNf(oTsiNFis, aObjJson, aObjJson["invoice"]) //envia o numero do rps ja gravado
        If C20->( DbSeek( xfilial('C20') + cChv ) )  
            ModelDelInc(@oModel,@nOpcao)
        endif
    endif

    //Controle da nova chave que ira ser integrada
    cChv := ModelChvNf(oTsiNFis, aObjJson, aObjJson['taxDocumentNumber'])

    If C20->( DbSeek( xfilial('C20') + cChv ) )  
        nOpcao      := MODEL_OPERATION_UPDATE
        cC20Chv     := C20->C20_CHVNF
        lSameStamp  := alltrim(C20->C20_STAMP) == alltrim(aObjJson["stamp"])
    else
        nOpcao := MODEL_OPERATION_INSERT
    endif

    //Bloco para integracao direta do ERP, deve-se excluir no TAF, quando doc entrada com Formulário Próprio Nao for cancelado ou excluído do Protheus
    if nOpcao == MODEL_OPERATION_UPDATE .and. aObjJson["opCancelation"] == "5" .and. aObjJson["identificationSituation"] == "02"
        if !Empty( aObjJson["stamp"] ) //se encontrou, atualiza o stamp do item que sera deletado com o mesmo stamp do erp
            oModel:DeActivate()
            oModel:SetOperation( nOpcao )
            oModel:Activate()
            oModel:LoadValue( "MODEL_C20", "C20_STAMP", alltrim(aObjJson["stamp"]) )
            FwFormCommit( oModel )
            oModel:DeActivate()
        endif
        nOpcao := MODEL_OPERATION_DELETE
    //A situacao abaixo protege o processo para nao integrar notas que ja haviam sido inseridas no fiscal, nao foram integradas ao TAF
    //e posteriormente foram excluidas do ERP, como nao estao no TAF e foram apagadas do ERP, nao devem ser integradas.
    elseIf nOpcao == MODEL_OPERATION_INSERT .and. aObjJson["opCancelation"] == "5" .and. aObjJson["identificationSituation"] == "02"
        lSucessItem := lGrv := .F. //nao deve inserir
    endif
    //Demais casos, nota entrada com form prop sim e doc saída quando cancelados ou excluídos, atualizam a situação para 02 (MODEL_OPERATION_UPDATE).

    //Caso seja alteracao, apagamos os registros via MVC e inserimos o novo lote, pois no primeiro envio pode possuir x registros,
    //e no segundo envio x-y, podendo ficar ativos registros que o usuario nao deseja, alem da alteracao ficar mais custosa ao percorrer
    //todo o length em todas as grids com seekline. O risco do seek line falhar eh alto, pois pode nao ser enviado todas as tags que compoe a chave.
    if lGrv
        BEGIN TRANSACTION
            if nOpcao == MODEL_OPERATION_UPDATE .and. !lSameStamp
                ModelDelInc(@oModel,@nOpcao)
            endif

            oModel:SetOperation( nOpcao )
            oModel:Activate( )

            if nOpcao <> MODEL_OPERATION_DELETE
                if !Empty( cC20Chv )
                    oModel:LoadValue( "MODEL_C20", "C20_CHVNF", cC20Chv ) //mantem mesma chave, para rastreamento
                endif
                //Proteger gravação para não gravar mesmo stamp
                If !lSameStamp
                    GrvFisDoc( @oModel, @oMldC30, @oMldC35, @oMldC2F, @oMldC39, @oMldT9Q, @oMldC2D, @oMldC21, @aObjJson, @aRetJs, nI, nOpcao, cKey, @lSucessItem , @oMldC20, @oTsiNFis )
                Endif
            EndIf

            If !lSameStamp
                // TafConout('entrou gravacao - '+aOBjJson['taxDocumentNumber']+"- Thread " + cValtoChar(ThreadId()),1,.f.,"TSI")
                If !lSucessItem .or. !TsiNFCommit(oModel,aRetJs,lSucessItem,cKey,aOBjJson)
					// TafConout('desarmando transacao stamp - '+aOBjJson['taxDocumentNumber']+"- Thread " + cValtoChar(ThreadId()),1,.f.,"TSI")
                    lErrorModel:= .T. 
                    RollBackDelTran()//Necessario caso ocorra alguma falha na alteracao, nao efetiva delecao do registro anterior.
                endif
            else
                // TafConout('else mesmo stamp - '+aOBjJson['taxDocumentNumber']+"- Thread " + cValtoChar(ThreadId()),1,.F.,"TSI")
            Endif
            
            oModel:DeActivate( )

        END TRANSACTION
        //- Indica que houve um erro na gravação em transação
        //- procede a gravação pós transação 
        If lErrorModel 
            oModel:DeActivate( ) //- DESATIVAÇÃO DO MODELO
            if lV5rErp //Se o campo V5R_ERPKEY existe eh importante o atualizar o fonte TAFA565.
                putTsiV5r('C20', cKey, @aRetJs, aObjJson["stamp"], (&cKeyErp) ) //Efetiva gravacao do erro, fora da transacao
            else
                putTsiV5r('C20', cKey, @aRetJs, aObjJson["stamp"]) //Efetiva gravacao do erro, fora da transacao
            endif
        EndIf 
    else
        //Tafconout('else lGrv - '+aOBjJson['taxDocumentNumber']+"- Thread " + cValtoChar(ThreadId()),1,.f.,"TSI")
    endif

    cNewStamp := aObjJson["stamp"] //stamp vindo da SFT

    if valtype( oTsiNFis ) == "O" //protecao para funcionar na extracao ja que a API nao utiliza o controle na V80 ( data de corte ).
        if empty( oTsiNFis:cUpStamp ) .Or. iif(FindFunction('TsiCompStamp'),TsiCompStamp(cNewStamp, oTsiNFis:cUpStamp ),cNewStamp > oTsiNFis:cUpStamp)
            oTsiNFis:cUpStamp := cNewStamp
        endif
    endif
    
else
    //Tafconout('erro gravacao - '+aOBjJson['taxDocumentNumber']+"- Thread " + cValtoChar(ThreadId()),1,.f.,"TSI")
    lSucessItem := .F.
    cErro := "OBRIGAT"
    cCodError := "A(s) tag(s) não foram encontrada(s) e formam a chave da nota, portanto devem ser enviadas "
    cCodError += cWarning
    aadd(aRetJs, {lSucessItem,cKey,cErro,cCodError})
    AgrupaErro( cKey, cErro, @aRetJs )
    
endif

Return lSucessItem


/*----------------------------------------------------------------------
{Protheus.doc} TsiNFCommit()
Função para chamar o FWFormCommit
@author Renan Gomes
@since 02/08/2022
@return Nil, nulo, não tem retorno.
*/

static function TsiNFCommit(oModel,aRetJs,lSucessItem,cKey,aOBjJson)
Local lRet := .F.

If ValType( oModel) == 'O' .and. FwFormCommit( oModel )
    aadd(aRetJs, {lSucessItem, cKey})
    ClearV5R( "C20", cKey )
    lRet := .T.
Endif

Return lRet 

/*----------------------------------------------------------------------
{Protheus.doc} GrvFisDoc()
Gravacao Documento Fiscal
@author Denis Souza
@since 14/12/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
static function GrvFisDoc( oModel, oMldC30, oMldC35, oMldC2F, oMldC39, oMldT9Q, oMldC2D, oMldC21, aObjJson, aRetJs, nI, nOperation, cKey, lSucessItem, oMldC20, oTsiNFis )

Local cFilAux   := ''
Local nlA       := 1
Local nlB       := 1
Local nAteA     := 0
Local nAteB     := 0

Local cModel    := ''
Local cModelC20 := ''
Local cSource   := ''
Local cArea     := ''
Local nOrder    := ''
Local cKeySeek  := ''
Local cTagId    := ''
Local cProp     := ''
Local oHashGen  := Nil
Local lErro     := .T.
Local aErroVld  := NIL

Default oModel   := Nil
Default oMldC30  := Nil
Default oMldC35  := Nil
Default oMldC2F  := Nil
Default oMldC39  := Nil
Default oMldT9Q  := Nil
Default oMldC2D  := Nil
Default oMldC20  := Nil
Default oMldC21  := Nil

Default aObjJson := {}
Default oTsiNFis := Nil

cFilAux := PadR( cFilAnt, _nTmCODFIL )

hmget( oHashC20, "m_o_d_e_l_"      , @cModel    )
hmget( oHashC20, "m_o_d_e_l_C_2_0_", @cModelC20 )
hmget( oHashC20, "s_o_u_r_c_e_"    , @cSource   )
hmget( oHashC20, "a_r_e_a_"        , @cArea     )
hmget( oHashC20, "o_r_d_e_r_"      , @nOrder    )
hmget( oHashC20, "k_e_y_"          , @cKeySeek  )
hmget( oHashC20, "t_a_g_i_d_"      , @cTagId    )

aInfo := { cModel, cModelC20, cSource, cArea, nOrder, cKeySeek, cTagId, cFilAux, nOperation, cKey }

DBSelectArea( cArea )
DBSetOrder( nOrder )
DBSelectArea( "V5R" )
DBSetOrder( 1 ) // V5R_FILIAL, V5R_GRPERP, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY

/*-----------------------------
|         CAPA ( T013 )       |
------------------------------*/
TafIncReg( @oModel, aObjJson, oHashC20, @aRetJs, @lSucessItem, 'MODEL_C20', aInfo, oTsiNFis )
if !lSucessItem; lErro := lSucessItem ; endif
    nAteA := 0
    if valtype( aObjJson["otherTaxObligationsAdjustmentsAndInformation"] ) == 'A'
        nAteA := len( aObjJson["otherTaxObligationsAdjustmentsAndInformation"] )
    endif
    for nlA := 1 to nAteA
        if (nlA > 1);oMldC2D:AddLine();endif
        TafIncReg( @oModel, aObjJson["otherTaxObligationsAdjustmentsAndInformation"][nlA], oHashC2D, @aRetJs, @lSucessItem, 'MODEL_C2D', aInfo ,oTsiNFis)
        if !lSucessItem; lErro := lSucessItem ; endif
    next nlA
/*-----------------------------
|        ITENS ( T015 )       |
------------------------------*/
nAteA := 0
if valtype( aObjJson["fiscalDocumentItems"] ) == 'A'
    nAteA := len( aObjJson["fiscalDocumentItems"] )
endif
for nlA := 1 to nAteA
    if (nlA > 1);oMldC30:AddLine();endif
    TafIncReg( @oModel, aObjJson["fiscalDocumentItems"][nlA], oHashC30, @aRetJs, @lSucessItem, 'MODEL_C30', aInfo ,oTsiNFis)
    if !lSucessItem; lErro := lSucessItem ; endif

    /*-----------------------------
    | TRIBUTOS X ITENS ( T015AE ) |
    ------------------------------*/
    nAteB := 0
    if valtype( aObjJson["fiscalDocumentItems"][nlA]["valuesByTaxPerItem"] ) == 'A'
        nAteB := len( aObjJson["fiscalDocumentItems"][nlA]["valuesByTaxPerItem"] )
    endif

    aC35Uniq := {} //Controle dos tributos por item
    for nlB := 1 to nAteB
        if (nlB > 1);oMldC35:AddLine();endif
        TafIncReg( @oModel, aObjJson["fiscalDocumentItems"][nlA]["valuesByTaxPerItem"][nlB], oHashC35, @aRetJs, @lSucessItem, 'MODEL_C35', aInfo , oTsiNFis)
        if !lSucessItem; lErro := lSucessItem ; endif
        TafVldUniq( 'MODEL_C35', oMldC35, @aC35Uniq, cKey, @lErro, @aRetJs ) //*excecao o VldData nao validou UniqLine nesse modelo
    next nlB

    /*--------------------------
    |   TRANSPORTE ( T015AI )  |
    ---------------------------*/
    nAteB := 0
    if valtype( aObjJson["fiscalDocumentItems"][nlA]["transportComplement"] ) == 'A'
        nAteB := len( aObjJson["fiscalDocumentItems"][nlA]["transportComplement"] )
    endif
    for nlB := 1 to nAteB
        if (nlB > 1);oMldC39:AddLine();endif
        TafIncReg( @oModel, aObjJson["fiscalDocumentItems"][nlA]["transportComplement"][nlB], oHashC39, @aRetJs, @lSucessItem, 'MODEL_C39', aInfo , oTsiNFis)
        if !lSucessItem; lErro := lSucessItem ; endif
    next nlB

    /*-------------------------------------------------------------
    |   INDICATIVO DE SUSPENSÃO POR PROCESSO JUDICIAL ( T015AK )  |
    -------------------------------------------------------------*/
    nAteB := 0
    if valtype( aObjJson["fiscalDocumentItems"][nlA]["indicativeOfSuspensionByJudicialProcess"] ) == 'A'
        nAteB := len( aObjJson["fiscalDocumentItems"][nlA]["indicativeOfSuspensionByJudicialProcess"] )
    endif
    for nlB := 1 to nAteB
        if (nlB > 1);oMldT9Q:AddLine();endif
        TafIncReg( @oModel, aObjJson["fiscalDocumentItems"][nlA]["indicativeOfSuspensionByJudicialProcess"][nlB], oHashT9Q, @aRetJs, @lSucessItem, 'MODEL_T9Q', aInfo , oTsiNFis)
        if !lSucessItem; lErro := lSucessItem ; endif
    next nlB

next nlA

/*-----------------------------
|   TOTAL TRIBUTOS ( T013AP ) |
------------------------------*/
nAteA := 0
if valtype( aObjJson["valuesByTax"] ) == 'A'
    nAteA := len( aObjJson["valuesByTax"] )
endif
for nlA := 1 to nAteA
    if (nlA > 1);oMldC2F:AddLine();endif
    TafIncReg( @oModel, aObjJson["valuesByTax"][nlA], oHashC2F, @aRetJs, @lSucessItem, 'MODEL_C2F', aInfo , oTsiNFis)
    if !lSucessItem; lErro := lSucessItem ; endif
next nlA

/*----------------------------------------------------------------
|   INFORMAÇÕES COMPLEMENTARES POR DOCUMENTOS FISCAIS ( T013AA ) |
----------------------------------------------------------------*/
nAteA := 0
if valtype( aObjJson["complementaryInformationByTaxDocument"] ) == 'A'
    nAteA := len( aObjJson["complementaryInformationByTaxDocument"] )
endif
for nlA := 1 to nAteA
    aObjJson["complementaryInformationByTaxDocument"][nlA]['auxiliaryCode'] := aObjJson["complementaryInformationByTaxDocument"][nlA]['complementaryInfoCode']
    aObjJson["complementaryInformationByTaxDocument"][nlA]['complementaryInfoDesc'] := AllTrim(Posicione('C3Q', 1, xFilial('C3Q') + aObjJson["complementaryInformationByTaxDocument"][nlA]['complementaryInfoCode'], 'C3Q_TXTCOM' ))
    if (nlA > 1);oMldC21:AddLine();endif
    TafIncReg( @oModel, aObjJson["complementaryInformationByTaxDocument"][nlA], oHashC21, @aRetJs, @lSucessItem, 'MODEL_C21', aInfo , oTsiNFis)
    if !lSucessItem; lErro := lSucessItem ; endif
next nlA

/*----------------------------------------------------------------
|                CADASTRO DE FATURAS ( T013AI C29 )               |
-----------------------------------------------------------------*/
/* Retirado 19/03/2025 pois o TAF não considera a tabela C29 em nenhuma das obrigacoes.
Com esse trecho retirado (SE1\SE2), a query que estava sendo executado em 6 horas na JadLog, abaixou para 7 minutos.
Caso necessite do NUMFAT, verificar historico no TFS para recuparar a query e suas amarracoes. */

/*-----------------------------
|    VALIDACAO DO MODELO       |
------------------------------*/

lSucessItem := oModel:VldData()
if !lSucessItem
    aErroVld  := oModel:GetErrorMessage()
    cField    := aErroVld[4]
    cCodError := aErroVld[5]    
    if !Empty(cField)
        cPrefixo := substr(alltrim(cField),1,3)
        oHashGen := &("oHash" + cPrefixo)
        HMGet(oHashGen, cField, @cProp )
    endif
    cErro := RetErroTaf( cProp, aObjJson, cField, cCodError,,aErroVld )

    /*
    Tratamento quando o erro fica nulo na V5R, mas existe regra de persistencia dentro do ValidModel.
    Ex: TAFHLPNF002 Informações complementares referentes ao modelo de documento fiscal selecionado deve ser preenchido antes de gravar o formulário.
    Pasta 57(50->57) Para documentos fiscais modelos 06, 28 e/ou 29 é necessário informar registros complementares com informações específicas desses modelos.
    ou
    TAFHLPNF003 Informações complementares referentes ao modelo de documento fiscal selecionado, deve ser preenchido antes de gravar o formulário. Pasta 17(01->03->17) 
    Para documentos fiscais de Saída modelo 21 e/ou 22, deve-se informar os campos complementares.
    */
    if empty(cErro) .And. len(aErroVld) >= 7
        while space(2) $ aErroVld[6]
            aErroVld[6] := StrTran( aErroVld[6], space(2), space(1) )
        enddo
        cErro := Alltrim(aErroVld[5]) + space(1) + Alltrim(aErroVld[6]) + space(1) + Alltrim(aErroVld[7])
    endif

    if !empty(cKey) //Grava tabela V5R log e alimenta aRetJs para o rest
        AgrupaErro( cKey, cErro, @aRetJs )
    endif
endif

//Caso o ValidData retorne verdadeiro, porem foi encontrado alguma inconsistencia no controle de validacao atribuo retorno do lErro
if lSucessItem
    lSucessItem := lErro
    /*
    if !lSucessItem
        Tafconout('erro lSucessItem GrvFisDoc - '+aObjJson['taxDocumentNumber']+"- Thread " + cValtoChar(ThreadId()),1,.f.,"TSI")
        Tafconout('JSON NF' + aObjJson:toJson()+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
    Endif
    */
    
endif

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} TafIncReg()
Prepara o modelo com oas informações do json para posterior commit
@author Henrique Pereira / Denis Souza
@since 09/11/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Static Function TafIncReg( oModel, aObjJson, oHash, aRetJs, lSucessItem, cModelID, aInfo , oTsiNFis)

Local cField    := ''
Local cChave    := ''
Local nY        := 0
Local nOrder    := 1
Local cArea     := ''
Local cModel    := ''
Local cModelC20 := ''
Local cSource   := ''   
Local cFunc     := '' 
Local cTagId    := ''
Local cTagIdAux := ''
Local cProperty := ''
Local cKeySeek  := ''
Local cCodErro  := '' 
Local cErro     := ''
Local cStamp    := ''
Local cCod      := ''
Local aProperty := {}
Local nAte      := 0
Local lErro     := .T. //variavel para acumular ao menos 1 falha.
Local cKey      := ''
Local nOperation := 0
Private cIndOpe := ''

Default oModel      := Nil
Default aObjJson    := {}
Default oHash       := Nil
Default aRetJs      := {}
Default lSucessItem := .F.  //variavel para controlar o sucesso de cada transacao
Default cModelID    := 'MODEL_C20'
Default aInfo       := {}
//oTsiNFis -> Esse parâmetro não deve ser retirado da função pois o objeto é usado por macro execução.

aProperty := aObjJson:GetNames( )
nAte      := Len( aProperty )

if len(aInfo) == 10
    cModel     := aInfo[1] //TAFA062
    cModelC20  := aInfo[2] //MODEL_C20
    cSource    := aInfo[3] //TAFA062
    cArea      := aInfo[4] //C20
    nOrder     := aInfo[5] //1
    cKeySeek   := aInfo[6] //xfilial('C20')+padr(XFUNCh2ID( aObjJson...
    cTagId     := aInfo[7] //invoiceId
    nOperation := aInfo[9]
    cKey       := aInfo[10]
endif

//Com a propriedade do json em mãos ( EX: aProperty := "itemId" )
//Buscamos no objeto oHash o campo a ser utilizado para gravação e retornamos na variável @cField.
//Ex: Se o Hash passado como parametro for de produto: hmget( oHash, "itemId", @cField ) | cField terá o conteúdo "C1L_CODIGO"
// Begin Sequence

for nY := 1 to nAte
    lSucessItem := .T.
    cTagIdAux := ''
    If hmget( oHash, aProperty[nY], @cField )
        cCod := cChave := aObjJson[aProperty[nY]] // Retornamos o contéudo da propriedade que será gravado
        cStamp := aObjJson["stamp"] //Pega o STAMP
        If "#F3#" $ cField //Tratamento de-para para campos F3
            cField := SubStr( cField, 1, Len( cField ) - 4 )
            If !empty( cChave )
                hmget( oHash, "#F3#"+cField, @cFunc )
                cChave := &cFunc
                If "NOTFOUND" == cChave
                    lErro := lSucessItem := .F.
                    cChave := aObjJson[aProperty[nY]]
                    cCodErro := "NOTFOUND"
                    HMGet( oHash, cField, @cProperty )
                    cErro := RetErroTaf( cProperty, aObjJson, cField, cCodErro )
                    if !empty(cKey)
                        AgrupaErro( cKey, cErro, @aRetJs )
                    endif
                EndIf
            ElseIf empty( cChave ) .and. "C20_CODMOD" $ cField
                cChave := '000001'
            EndIf
        elseif "#DT#" $ cField // Tratamento para campos tipo data
            cField := SubStr( cField, 1, Len( cField ) - 4 )
            if valtype(cChave) == 'C'
                cChave := ctod(cChave)
                if cField <> "C20_DTCPIS" .And. ( alltrim(cvaltochar(cChave)) == "/  /" .or. empty(alltrim(cvaltochar(cChave))) ) //C20_DTCPIS nao eh obrigatorio logo nao passara na validacao de data vazia.
                    cChave := cTod('')
                    lErro := lSucessItem := .F.
                    cCodErro := "DATE"
                    HMGet( oHash, cField, @cProperty )
                    cErro := RetErroTaf( cProperty, aObjJson, cField, cCodErro )
                    if !empty(cKey)
                        AgrupaErro( cKey, cErro, @aRetJs )
                    endif
                endif
            endif
        ElseIf cField $ _cCposFake //campo fake
            Loop
        EndIf

        if nOperation == MODEL_OPERATION_UPDATE
            hmget( oHash, cField, @cTagIdAux )
        endif

        if cTagIdAux <> cTagId .And. lSucessItem
            /*
            Tratamento de predecessao: 
            - Antes de gravar o ID do C30_CODITE, deve ser gravado o "codigo de produto" em um campo virtual "C30_ITEM".
            Ja que campos virtuais nao possuem TAG no HASH. No tratamento abaixo,o campo virtual C30_ITEM eh gravado antes do C30_CODITE.
            Importante: Os campos C30_CODITE e C30_ITEM gatilham no campo C30_ORIGEM a origem do campo 'C1L_ORIMER', porem existe uma tag para esse fim, a "originIdentCode",
            para o vldData nao apontar erro na origem, ja que o campo C1L_ORIMER pode estar vazio e ainda nao foi gravado o conteúdo da TAG "originIdentCode"
            se fez necessario gravar esses 2 campos com LoadValue, ao inves do SetValue, para nao disparar esse gatilho.
            */
            if Upper(AllTrim(cField)) == "C30_CODITE"
                oModel:LoadValue( cModelID, "C30_ITEM", cCod ) //carrega campo virtual C30_ITEM com loadvalue antes do C30_CODITE, devido validação de preenchimento no vldData.
            endif
            /*
            Inviabilidade do uso do SetValue: 
            - Valida todas regras da tela, como ordem de preenchimentos dos campos, porem por integracao tsi, nao existe ordem e não necessário enviar todos os campos.
            - O mecanismo do SetValue dispara propriedades do campos (como "Gatilhos", "Valids", "When" ), obrigando fazer inumeros desvios no fonte TAFA062.
            - O mecanismo do SetValue considera os "SetProperty" e "Rules" do model, como preenchimento de um campo antes do outro, inviavel para o TSI.
            - No caso de alguns campos virtuais como código e descrição, eh necessario fazer preenchimento com algum conteudo "fake" ou "vazio" para passar.
            - Ha excecoes e nesse caso deve ficar fazendo condicional por campo, podera onerar a integracao, ja que passa nesse ponto para cada tag/campo.
            - Existe um trigger do C2F_CST no C2F_DCST, porem o VldData reclama do tipo de dado no campo virtual C2F_DCST, 
              para nao executar "trigger" e nao ocorrer o bloqueio no modelo, eh utilizado loadvalue.
            - Existem muitas triggers com fórmulas e nesse caso atualizará campos "totalizados" ocorrendo o risco de desconsiderar o(s) dado(s) que o cliente informou.
            - No caso de uma alteração, mantemos o mesmo ID no C20_CHVNF, porem com o uso do SetValue, eh apresentado TAFJAGRAVADO devido acionar a funcao XFUNVldUni,
              que considerou o registro apagado no seu bloqueio.
            */
            if valtype( cChave ) == "U" .Or. !oModel:LoadValue( cModelID, cField, cChave )
                //TafConout("---->cModelID: " + cModelID + " cField: " + cField + " cChave:" + cvaltochar(cChave) )
                lErro := lSucessItem := .F. //O campo não pode sofrer atualização, invalidará a folha inteira de dados e o erro será retornado em aRetJs
                cCodError := "LOADVALUE"
                HMGet( oHash, cField, @cProperty )
                cErro := RetErroTaf( cProperty, aObjJson, cField, cCodError )
                if !empty(cKey) // Grava tabela V5R log e alimenta aRetJs para o rest
                    AgrupaErro( cKey, cErro, @aRetJs )
                endif
            endif
        endif
    endIf
Next nY

//O lSucessItem pode estar "ok", ja que recebe incremento a cada Tags, porem se existir no minimo uma falha devera impedir a gravacao.
lSucessItem := lErro

// End Sequence

Return Nil

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC20()
@author Henrique Pereira / Denis Souza
@since 15/07/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC20()

Local oHashC20 := HMNew()
Local cSeek    := ''
Local cKey     := ''

TafInfGen( @cKey, @cSeek, @oHashC20 )

SetHashKey(oHashC20, "operationType"              , "C20_INDOPE" )     // 02 - IND_OPER
SetHashKey(oHashC20, "documentType"               , "C20_TPDOC#F3#" )  // 03 - TIPO_DOC -> De/Para na query -> FDeParaTAF( )   // C0U
SetHashKey(oHashC20, "taxDocumentIssuer"          , "C20_INDEMI" )     // 04 - IND_EMIT -> De/Para na query
SetHashKey(oHashC20, "participatingCode"          , "C20_CODPAR#F3#" ) // 05 - COD_PART
SetHashKey(oHashC20, "identificationSituation"    , "C20_CODSIT#F3#" ) // 06 - COD_SIT  SPEDSITDOC( ) // C02
SetHashKey(oHashC20, "taxDocumentSeries"          , "C20_SERIE" )	   // 07 - SER
SetHashKey(oHashC20, "taxDocumentNumber"          , "C20_NUMDOC" )	   // 09 - NUM_DOC
SetHashKey(oHashC20, "fiscalDocumentDate"         , "C20_DTDOC#DT#" )  // 10 - DT_DOC
SetHashKey(oHashC20, "electronicKeyDocument"      , "C20_CHVELE" )     // 11 - CHV_DOC_E
SetHashKey(oHashC20, "documentValue"              , "C20_VLDOC" )      // 12 - VL_DOC
SetHashKey(oHashC20, "typeOfPayment"              , "C20_INDPAG" )     // 13 - IND_PGTO
SetHashKey(oHashC20, "discountAmount"             , "C20_VLDESC" )	   // 14 - VL_DESC
SetHashKey(oHashC20, "modelIdentificationCode"    , "C20_CODMOD#F3#" ) // 15 - COD_MOD -> AModNot( )
SetHashKey(oHashC20, "finalDocumentNumber"        , "C20_NDOCF" )	   // 16 - NUM_DOC_FIN
SetHashKey(oHashC20, "valueOfGoods"               , "C20_VLMERC" )	   // 18 - VL_MERC
SetHashKey(oHashC20, "taxDocumentEntryAndExitDate", "C20_DTES#DT#" )   // 19 - DT_E_S
SetHashKey(oHashC20, "amountOfAccessoryExpenses"  , "C20_VLRDA" )	   // 20 - VL_DA
SetHashKey(oHashC20, "shippingIndicator"          , "C20_INDFRT#F3#" ) // 25 - IND_FRT
SetHashKey(oHashC20, "insuranceAmount"            , "C20_VLRSEG" )	   // 26 - VL_SEG
SetHashKey(oHashC20, "otherExpenses"              , "C20_VLOUDE" )	   // 27 - VL_OUT_DESP
SetHashKey(oHashC20, "freight"                    , "C20_VLRFRT" )	   // 28 - VL_FRT
SetHashKey(oHashC20, "untaxedAllowanceAmount"     , "C20_VLABNT" )	   // 30 - VL_ABAT_NT
SetHashKey(oHashC20, "AIDFNumber"                 , "C20_AIDF" )       // 31 - NUM_AUT
SetHashKey(oHashC20, "valueOfServices"            , "C20_VLSERV" )	   // 38 - VL_SERV
//SetHashKey(oHashC20, "invoiceCancellationDate"  , "C20_DTCANC#DT#" ) // 56 - DT_CANC
SetHashKey(oHashC20, "placeOfDelivery"            , "C20_CODLOC#F3#" ) // 62 - LOC_PRESTACAO
SetHashKey(oHashC20, "valueReducedISSMaterials"   , "C20_VLABMT" )	   // 63 - VL_DED_ISS_MAT
SetHashKey(oHashC20, "cnoNumber"                  , "C20_IDOBR#F3#" )  // 65 - NR_INSC_ESTAB
SetHashKey(oHashC20, "registrationType"           , "C20_TPOBR" )      // 70 - TP_INSCRICAO CAMPO FAKE
SetHashKey(oHashC20, "federativeUnitOrigin"       , "C20_UF#F3#" )	   // 69 - UF_ORIGEM

if TAFColumnPos( "C20_DTCONT" )
    SetHashKey(oHashC20, "accountingDate"         , "C20_DTCONT#DT#" ) // 74 - Dt. Contabilização
Endif

if TAFColumnPos( "C20_DTCPIS" )
    SetHashKey(oHashC20, "competenceIss"          , "C20_DTCPIS#DT#" ) //Data Competencia ISS
Endif

SetHashKey(oHashC20, "stamp" 					  , "C20_STAMP" )      // 09 - STAMP

//#F3# usado na gravação ou alteração
HMSet(oHashC20, '#F3#C20_CODLOC', "GetIDCached( 'C07', XFUNGETUF( iif(Len(aObjJson['placeOfDelivery'])==7, substr(aObjJson['placeOfDelivery'],1,2),'')) + iif(Len(aObjJson['placeOfDelivery'])==7, substr(aObjJson['placeOfDelivery'],3,5),''), 1 ,oTsiNFis:GetHashCahed('C07') ) " ) //C07_FILIAL, C07_UF, C07_CODIGO
HMSet(oHashC20, '#F3#C20_UF'    , "GetIDCached( 'C09', aObjJson['federativeUnitOrigin']   , 1 ,oTsiNFis:GetHashCahed('C09'))" )                //C09_FILIAL, C09_UF
HMSet(oHashC20, '#F3#C20_CODMOD', "ValCodMod( GetIDCached( 'C01', aObjJson['modelIdentificationCode'] , 1 ,oTsiNFis:GetHashCahed('C01') ) )" )  //C01_FILIAL, C01_CODIGO
HMSet(oHashC20, '#F3#C20_CODSIT', "GetIDCached( 'C02', aObjJson['identificationSituation'], 1 ,oTsiNFis:GetHashCahed('C02'))" )                //C02_FILIAL, C02_CODIGO
HMSet(oHashC20, '#F3#C20_TPDOC' , "GetIDCached( 'C0U', aObjJson['documentType']           , 1 ,oTsiNFis:GetHashCahed('C0U'))" )                //C0U_FILIAL, C0U_CODIGO
HMSet(oHashC20, '#F3#C20_CODPAR', "GetIDCached( 'C1H', aObjJson['participatingCode']      , 1 ,oTsiNFis:GetHashCahed('C1H'))" )                //C1H_FILIAL, C1H_CODPAR
HMSet(oHashC20, '#F3#C20_INDFRT', "GetIDCached( 'C0X', aObjJson['shippingIndicator']      , 1 ,oTsiNFis:GetHashCahed('C0X'))" )                //C0X_FILIAL, C0X_CODIGO
HMSet(oHashC20, '#F3#C20_IDOBR' , "GetIDCached( 'T9C', padr(aObjJson['registrationType']," + _cTmT9CTpI + ") + padr(aObjJson['cnoNumber']," + _cTmT9CNrI + "), 3 ,oTsiNFis:GetHashCahed('T9C'))" ) //T9C_FILIAL, T9C_ID

//Posicione referente ao cabeçalho ( utilizado no get )
HMSet(oHashC20, 'C20_CODLOC#POSIC#', "Posicione('C07', 3, xFilial('C07') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C07_UF'     )") //C07_FILIAL, C07_ID
HMSet(oHashC20, 'C20_UF#POSIC#'    , "Posicione('C09', 3, xFilial('C09') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C09_UF'     )") //C09_FILIAL, C09_ID
HMSet(oHashC20, 'C20_CODMOD#POSIC#', "Posicione('C01', 3, xFilial('C01') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C01_CODIGO' )") //C01_FILIAL, C01_ID
HMSet(oHashC20, 'C20_CODSIT#POSIC#', "Posicione('C02', 3, xFilial('C02') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C02_CODIGO' )") //C02_FILIAL, C02_ID
HMSet(oHashC20, 'C20_TPDOC#POSIC#' , "Posicione('C0U', 3, xFilial('C0U') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C0U_CODIGO' )") //C0U_FILIAL, C0U_ID
HMSet(oHashC20, 'C20_CODPAR#POSIC#', "Posicione('C1H', 5, xFilial('C1H') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1H_CODPAR' )") //C1H_FILIAL, C1H_ID
HMSet(oHashC20, 'C20_INDFRT#POSIC#', "Posicione('C0X', 3, xFilial('C0X') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C0X_CODIGO' )") //C0X_FILIAL, C0X_ID
HMSet(oHashC20, 'C20_IDOBR#POSIC#',  "Posicione('T9C', 1, xFilial('T9C') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'T9C_NRINSC' )") //T9C_FILIAL, T9C_ID
HMSet(oHashC20, 'C20_TPOBR#POSIC#',  "Posicione('T9C', 1, xFilial('T9C') + oMdl:GetValue('C20_IDOBR'), 'T9C_TPINSC' )") //T9C_FILIAL, T9C_ID

Return oHashC20

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC30()
@author Henrique Pereira / Denis Souza
@since 15/07/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC30()

Local oHashC30 := HMNew()

SetHashKey(oHashC30, "itemNumber"             , "C30_NUMITE" )
SetHashKey(oHashC30, "itemCode"               , "C30_CODITE#F3#" )
SetHashKey(oHashC30, "cfopIndicator"          , "C30_CFOP#F3#" )
SetHashKey(oHashC30, "itemAdditions"          , "C30_VLACRE" )
SetHashKey(oHashC30, "operationNature"        , "C30_NATOPE#F3#" )
SetHashKey(oHashC30, "originIdentCode"        , "C30_ORIGEM#F3#" )
SetHashKey(oHashC30, "physicalMovement"       , "C30_INDMOV" )
SetHashKey(oHashC30, "accountingValue"        , "C30_VLOPER" )
SetHashKey(oHashC30, "socialSecurityExemption", "C30_INDISE" )
SetHashKey(oHashC30, "itemAmount"             , "C30_QUANT" )
SetHashKey(oHashC30, "itemTotalValue"         , "C30_TOTAL" )
SetHashKey(oHashC30, "discountValue"          , "C30_VLDESC" )
SetHashKey(oHashC30, "itemValue"              , "C30_VLRITE" )
SetHashKey(oHashC30, "acessoryExpense"        , "C30_VLRDA" )
SetHashKey(oHashC30, "unitOfMeasurement"      , "C30_UM#F3#" )
SetHashKey(oHashC30, "serviceCode"            , "C30_CODSER#F3#" )
SetHashKey(oHashC30, "cityServiceCode"        , "C30_SRVMUN" )
SetHashKey(oHashC30, "serviceType"            , "C30_IDTSER#F3#" )
SetHashKey(oHashC30, "dipamCode"              , "C30_CODIPA#F3#" )
SetHashKey(oHashC30, "natureOfIncome"         , "C30_CNATRE#F3#" )
SetHashKey(oHashC30, "indicator13Salary"      , "C30_DECTER" )
SetHashKey(oHashC30, "typeOfTransfer"         , "C30_TPREPA" )

//#F3# usado na gravação ou alteração dos itens
HMSet(oHashC30, '#F3#C30_CODITE', "GetIDCached( 'C1L', aObjJson['itemCode']         , 1 ,oTsiNFis:GetHashCahed('C1L'))" ) //C1L_FILIAL, C1L_CODIGO
HMSet(oHashC30, '#F3#C30_CFOP'  , "GetIDCached( 'C0Y', aObjJson['cfopIndicator']    , 1 ,oTsiNFis:GetHashCahed('C0Y'))" ) //C0Y_FILIAL, C0Y_CODIGO
HMSet(oHashC30, '#F3#C30_NATOPE', "GetIDCached( 'C1N', aObjJson['operationNature']  , 1 ,oTsiNFis:GetHashCahed('C1N'))" ) //C1N_FILIAL, C1N_CODNAT
HMSet(oHashC30, '#F3#C30_ORIGEM', "GetIDCached( 'C03', aObjJson['originIdentCode']  , 1 ,oTsiNFis:GetHashCahed('C03'))" ) //C03_FILIAL, C03_CODIGO
HMSet(oHashC30, '#F3#C30_UM'    , "GetIDCached( 'C1J', aObjJson['unitOfMeasurement'], 1 ,oTsiNFis:GetHashCahed('C1J'))" ) //C1J_FILIAL, C1J_CODIGO
HMSet(oHashC30, '#F3#C30_CODSER', "GetIDCached( 'C0B', cValToChar(Val(StrTran(aObjJson['serviceCode'],'.'))) , 1 ,oTsiNFis:GetHashCahed('C0B'))" ) //C0B_FILIAL, C0B_CODIGO
HMSet(oHashC30, '#F3#C30_IDTSER', "GetIDCached( 'C8C', aObjJson['serviceType']      , 4 ,oTsiNFis:GetHashCahed('C8C'))" ) //C8C_FILIAL, C8C_CREINF
HMSet(oHashC30, '#F3#C30_CODIPA', "GetIDCached( 'LF0', aObjJson['dipamCode']        , 2 ,oTsiNFis:GetHashCahed('LF0'))" ) //LF0_FILIAL, LF0_CODIGO
HMSet(oHashC30, '#F3#C30_CNATRE', "GetIDCached( 'V3O', aObjJson['natureOfIncome']   , 1 ,oTsiNFis:GetHashCahed('V3O'))" ) //V3O_FILIAL, V3O_CODIGO

//Posicione referente aos itens ( utilizado no get )
HMSet(oHashC30, 'C30_CODITE#POSIC#' , "Posicione('C1L', 3, xFilial('C1L') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1L_CODIGO' )") //C1L_FILIAL, C1L_ID
HMSet(oHashC30, 'C30_CFOP#POSIC#'   , "Posicione('C0Y', 3, xFilial('C0Y') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C0Y_CODIGO' )") //C0Y_FILIAL, C0Y_ID
HMSet(oHashC30, 'C30_NATOPE#POSIC#' , "Posicione('C1N', 3, xFilial('C1N') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1N_CODNAT' )") //C1N_FILIAL, C1N_ID
HMSet(oHashC30, 'C30_ORIGEM#POSIC#' , "Posicione('C03', 3, xFilial('C03') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C03_CODIGO' )") //C03_FILIAL, C03_ID
HMSet(oHashC30, 'C30_UM#POSIC#'     , "Posicione('C1J', 3, xFilial('C1J') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1J_CODIGO' )") //C1J_FILIAL, C1J_ID
HMSet(oHashC30, 'C30_CODSER#POSIC#' , "Posicione('C0B', 3, xFilial('C0B') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C0B_CODIGO' )") //C0B_FILIAL, C0B_ID
HMSet(oHashC30, 'C30_IDTSER#POSIC#' , "Posicione('C8C', 1, xFilial('C8C') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C8C_CREINF' )") //C8C_FILIAL, C8C_ID
HMSet(oHashC30, 'C30_CODIPA#POSIC#' , "Posicione('LF0', 1, xFilial('LF0') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'LF0_CODIGO' )") //LF0_FILIAL, LF0_ID
HMSet(oHashC30, 'C30_CNATRE#POSIC#' , "Posicione('V3O', 2, xFilial('C3O') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'V3O_CODIGO' )") //V3O_FILIAL, V3O_ID

Return oHashC30

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC35()
@author Denis Souza
@since 17/10/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC35()

Local oHashC35 := HMNew( )

SetHashKey(oHashC35, "taxCode"                        , "C35_CODTRI#F3#" ) // 02 - COD_TRIB    -> C35_CODTRI
SetHashKey(oHashC35, "cst"                            , "C35_CST#F3#" )    // 03 - CST         -> C35_CST
SetHashKey(oHashC35, "mva"                            , "C35_MVA" )        // 05 - MVA         -> C35_MVA
SetHashKey(oHashC35, "percentageReduction"            , "C35_REDBC" )      // 06 - PERC_RED_BC -> C35_REDBC
SetHashKey(oHashC35, "calculationBase"                , "C35_BASE" )       // 07 - BASE        -> C35_BASE
SetHashKey(oHashC35, "calculationBaseNotTaxed"        , "C35_BASENT" )     // 09 - BASE_NT     -> C35_BASENT
SetHashKey(oHashC35, "taxRate"                        , "C35_ALIQ" )       // 10 - ALIQUOTA    -> C35_ALIQ
SetHashKey(oHashC35, "taxValue"                       , "C35_VALOR" )      // 12 - VALOR       -> C35_VALOR
SetHashKey(oHashC35, "exemptValue"                    , "C35_VLISEN" )     // 15 - VLR_ISENTO  -> C35_VLISEN
SetHashKey(oHashC35, "otherValue"                     , "C35_VLOUTR" )     // 16 - VLR_OUTROS  -> C35_VLOUTR
SetHashKey(oHashC35, "nonTaxedValue"                  , "C35_VLNT" )       // 17 - VALOR_NT    -> C35_VLNT
SetHashKey(oHashC35, "valueWithoutCredit"             , "C35_VLSCRE" )     // 22 - VL_SCRED    -> C35_VLSCRE
SetHashKey(oHashC35, "subContractServiceValue"        , "C35_VLSCON" )     // 24 - VLSCONTR    -> C35_VLSCON
SetHashKey(oHashC35, "addRetentionAmount"             , "C35_VLRADI" )     // 25 - VLRADIC     -> C35_VLRADI
SetHashKey(oHashC35, "UnpaidRetentionAmount"          , "C35_VLRNPG" )     // 26 - VLRNPAG     -> C35_VLRNPG
SetHashKey(oHashC35, "serviceValueSpecialCondition15A", "C35_VLCE15" )     // 27 - VLRCE15     -> C35_VLCE15
SetHashKey(oHashC35, "serviceValueSpecialCondition20A", "C35_VLCE20" )     // 28 - VLRCE20     -> C35_VLCE20
SetHashKey(oHashC35, "serviceValueSpecialCondition25A", "C35_VLCE25" )     // 29 - VLRCE25     -> C35_VLCE25
SetHashKey(oHashC35, "addUnpaidRetentionAmount"       , "C35_VLRANP" )     // 30 - VLRADICNPAG -> C35_VLRANP

//#F3# usado na gravação ou alteração dos tributos dos itens
HMSet(oHashC35, '#F3#C35_CODTRI', "GetIDCached( 'C3S', aObjJson['taxCode']  , 1 ,oTsiNFis:GetHashCahed('C3S'))" ) //C3S_FILIAL, C3S_CODIGO
HMSet(oHashC35, '#F3#C35_CST'   , "ValCodCst(aObjJson['cst'], GetIDCached( 'C3S', aObjJson['taxCode']  , 1 ,oTsiNFis:GetHashCahed('C3S'))  )" )//C14_FILIAL, C14_CODIGO

//Posicione referente aos tributos dos itens ( utilizado no get )
HMSet(oHashC35, 'C35_CODTRI#POSIC#', "Posicione('C3S', 3, xFilial('C3S') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C3S_CODIGO' )") //C3S_FILIAL, C3S_ID
HMSet(oHashC35, 'C35_CST#POSIC#'   , "Posicione('C14', 3, xFilial('C14') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C14_CODIGO' )") //C14_FILIAL, C14_ID

Return oHashC35

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC39()
@author Denis Souza
@since 11/01/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC39()

Local oHashC39 := HMNew( )

SetHashKey(oHashC39, "originFUCode"   , "C39_UFORIG#F3#" ) // 02 - UF_MUN_ORIG
SetHashKey(oHashC39, "originCityCode" , "C39_CMUNOR#F3#" ) // 03 - COD_MUN_ORIG
SetHashKey(oHashC39, "destinyFUCode"  , "C39_UFDEST#F3#" ) // 04 - UF_MUN_DEST
SetHashKey(oHashC39, "destinyCityCode", "C39_CMUNDE#F3#" ) // 05 - COD_MUN_DEST

//#F3# usado na gravação(post) ou alteração(put) do complemento de transporte
HMSet(oHashC39,'#F3#C39_UFORIG',"GetIDCached('C09',aObjJson['originFUCode'],1,oTsiNFis:GetHashCahed('C09'))")  //C09_FILIAL, C09_UF
HMSet(oHashC39,'#F3#C39_CMUNOR',"GetIDCached('C07',GetIDCached('C09',aObjJson['originFUCode'],1,oTsiNFis:GetHashCahed('C09'))+aObjJson['originCityCode'],1,oTsiNFis:GetHashCahed('C07'))")   //C07_FILIAL, C07_UF, C07_CODIGO
HMSet(oHashC39,'#F3#C39_UFDEST',"GetIDCached('C09',aObjJson['destinyFUCode'],1,oTsiNFis:GetHashCahed('C09'))") //C09_FILIAL, C09_UF
HMSet(oHashC39,'#F3#C39_CMUNDE',"GetIDCached('C07',GetIDCached('C09',aObjJson['destinyFUCode'],1,oTsiNFis:GetHashCahed('C09'))+aObjJson['destinyCityCode'],1,oTsiNFis:GetHashCahed('C07'))") //C07_FILIAL, C07_UF, C07_CODIGO

//Posicione referente ao complemento de transporte ( utilizado no get )
HMSet(oHashC39, 'C39_UFORIG#POSIC#', "Posicione('C09', 3, xFilial('C09') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C09_UF' )")      //C09_FILIAL, C09_ID
HMSet(oHashC39, 'C39_CMUNOR#POSIC#', "Posicione('C07', 3, xFilial('C07') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C07_CODIGO' )")  //C07_FILIAL, C07_ID
HMSet(oHashC39, 'C39_UFDEST#POSIC#', "Posicione('C09', 3, xFilial('C09') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C09_UF' )")      //C09_FILIAL, C09_ID
HMSet(oHashC39, 'C39_CMUNDE#POSIC#', "Posicione('C07', 3, xFilial('C07') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C07_CODIGO' )")  //C07_FILIAL, C07_ID

Return oHashC39

/*--------------------------------------------------------------------------------
{Protheus.doc} HashT9Q()
@author Wesley Matos
@since 15/10/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashT9Q()

Local oHashT9Q := HMNew( )
Local cTamCodSus := lTrim(cValToChar(GetSx3Cache('T5L_CODSUS','X3_TAMANHO'))) //14
Local cTamVers   := lTrim(cValToChar(GetSx3Cache('C1G_VERSAO','X3_TAMANHO'))) //14
Local cTamPro    := lTrim(cValToChar(GetSx3Cache('C1G_NUMPRO','X3_TAMANHO'))) //06

SetHashKey(oHashT9Q, "processNumber"          , "T9Q_NUMPRO#F3#" ) // 02 - PROC_REFERENCIADOS
SetHashKey(oHashT9Q, "typeOfProcess"          , "T9Q_TPPROC"     ) // 04 - TIPO_PROCESSOS
SetHashKey(oHashT9Q, "suspensionCode"         , "T9Q_IDSUSP#F3#" ) // 05 - COD_SUSPENSÃO //TM 34 (ID6 + VERS14 + SUSP14)
SetHashKey(oHashT9Q, "tributeCode"            , "T9Q_CODTRI#F3#" ) // 06 - COD_TRIBUTO
SetHashKey(oHashT9Q, "retentionValue"         , "T9Q_VALSUS"     ) // 08 - VLR_RETENÇÃO
If TAFColumnPos("T9Q_BSSUSP")
    SetHashKey(oHashT9Q, "baseValueOfSuspendedTax", "T9Q_BSSUSP"     ) // 08 - VLR_BASE_SUSP
EndIf
SetHashKey(oHashT9Q, "versionSuspensionCode"  , "T9Q_VERSAO"  )    // CAMPO FAKE

//#F3# usado na gravação ou alteração dos tributos dos itens
HMSet(oHashT9Q, '#F3#T9Q_NUMPRO', "GetIDCached( 'C1G', padr(aObjJson['processNumber']," + cTamPro + "), 1 ,oTsiNFis:GetHashCahed('C1G'))" ) //T9Q_FILIAL, T9Q_NUMPRO
HMSet(oHashT9Q, '#F3#T9Q_CODTRI', "GetIDCached( 'C3S', aObjJson['tributeCode']     , 1 ,oTsiNFis:GetHashCahed('C3S'))" ) //T9Q_FILIAL, T9Q_CODTRI
//GetIDCached( ID_PROC ) + VERSAO + CODSUSP
HMSet(oHashT9Q, '#F3#T9Q_IDSUSP', "GetIDCached( 'C1G', padr(aObjJson['processNumber']," + cTamPro + "), 1 ,oTsiNFis:GetHashCahed('C1G')) + padr(alltrim(aObjJson['versionSuspensionCode'])," + cTamVers + ") + padr(alltrim(aObjJson['suspensionCode'])," + cTamCodSus + ") " )

//Posicione referente ao complemento de transporte ( utilizado no get )
HMSet(oHashT9Q, 'T9Q_NUMPRO#POSIC#', "Posicione('C1G', 3, xFilial('C1G') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1G_NUMPRO' )") //C1G_FILIAL+C1G_ID+C1G_VERSAO+C1G_ATIVO                                                                                                                                                                                                                                                   
HMSet(oHashT9Q, 'T9Q_CODTRI#POSIC#', "Posicione('C3S', 3, xFilial('C3S') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C3S_CODIGO' )") //C3S_FILIAL+C3S_ID                                                                                                                                               
HMSet(oHashT9Q, 'T9Q_IDSUSP#POSIC#', "Posicione('T5L', 1, xFilial('T5L') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'T5L_CODSUS' )") //T5L_FILIAL+T5L_ID+T5L_VERSAO+T5L_CODSUS
HMSet(oHashT9Q, 'T9Q_VERSAO#POSIC#', "Posicione('T5L', 1, xFilial('T5L') + oMdl:GetValue('T9Q_IDSUSP') , 'T5L_VERSAO' )") //T5L_FILIAL+T5L_ID+T5L_VERSAO+T5L_CODSUS

Return oHashT9Q

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC2D()
@author Wesley Matos|Ze Felipe
@since  09/03/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/

Function HashC2D()

Local oHashC2D := HMNew( )

SetHashKey(oHashC2D, "adjustmentCode"       , "C2D_CODAJ#F3#" )   // 02 - COD_AJ
SetHashKey(oHashC2D, "settingDescription"   , "C2D_DESCRI")       // 03 - DESCR_COMPL_AJ
SetHashKey(oHashC2D, "product"              , "C2D_CODITE#F3#" )  // 04 - COD_ITEM
SetHashKey(oHashC2D, "basisOfCalculation"   , "C2D_BSICM" )       // 05 - VL_BC_ICMS
SetHashKey(oHashC2D, "aliquot"              , "C2D_ALQICM" )      // 06 - ALIQ_ICMS  
SetHashKey(oHashC2D, "value"                , "C2D_VLICM" )       // 07 - VL_ICMS  
SetHashKey(oHashC2D, "subitemCode"          , "C2D_IDSUBI#F3#")   // 09 - COD_SUBITEM

//#F3# usado na gravação(post) ou alteração(put) dos ajustes de informações - documentos fiscais
HMSet(oHashC2D, '#F3#C2D_CODAJ', "GetIDCached('C0J',aObjJson['adjustmentCode'],4,oTsiNFis:GetHashCahed('C0J'))") //C0J_FILIAL, C0J_CODIGO
HMSet(oHashC2D, '#F3#C2D_CODITE', "GetIDCached('C1L',aObjJson['product'],1,oTsiNFis:GetHashCahed('C1L'))")       //C1L_FILIAL, C1L_CODIGO
HMSet(oHashC2D, '#F3#C2D_IDSUBI', "GetIDCached('CHY',aObjJson['subitemCode'],2,oTsiNFis:GetHashCahed('CHY'))")   //CHY_FILIAL, CHY_CODIGO, CHY_OPERAC, CHY_IDUF

//Posicione referente ao ajustes de informações - documentos fiscais ( utilizado no get das API's)
HMSet(oHashC2D, 'C2D_CODAJ#POSIC#', "Posicione('C0J',  3,  xFilial('C0J') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C0J_CODIGO' )") //C0J_FILIAL, C0J_ID
HMSet(oHashC2D, 'C2D_CODITE#POSIC#', "Posicione('C1L', 3, xFilial('C1L') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1L_CODIGO' )")  //C1L_FILIAL, C1L_ID
HMSet(oHashC2D, 'C2D_IDSUBI#POSIC#', "Posicione('CHY', 1, xFilial('CHY') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'CHY_CODIGO' )")  //CHY_FILIAL, CHY_ID

Return oHashC2D
/*--------------------------------------------------------------------------------
{Protheus.doc} HashC2F()
@author Denis Souza
@since 17/10/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC2F()

Local oHashC2F := HMNew( )

//campos dos tributos capa documento fiscal "valuesByTax"
SetHashKey(oHashC2F, "taxCode"                 , "C2F_CODTRI#F3#" )    // 02 - COD_TRIB       -> C2F_CODTRI
SetHashKey(oHashC2F, "calculationBase"	       , "C2F_BASE" )          // 03 - BASE           -> C2F_BASE
SetHashKey(oHashC2F, "calculationBaseAmount"   , "C2F_BASEQT" )        // 04 - BASE_QUANT     -> C2F_BASEQT
SetHashKey(oHashC2F, "calculationBaseNotTaxed" , "C2F_BASENT" )        // 05 - BASE_NT        -> C2F_BASENT
SetHashKey(oHashC2F, "taxValue"                , "C2F_VALOR" )         // 06 - VALOR          -> C2F_VALOR
SetHashKey(oHashC2F, "taxBaseValue"            , "C2F_VLRPAU" )        // 07 - VLR_TRIBUTAVEL -> C2F_VLRPAU
SetHashKey(oHashC2F, "exemptValue"             , "C2F_VLISEN" )        // 08 - VLR_ISENTO     -> C2F_VLISEN
SetHashKey(oHashC2F, "otherValue"              , "C2F_VLOUTR" )        // 09 - VLR_OUTROS     -> C2F_VLOUTR
SetHashKey(oHashC2F, "nonTaxedValue"           , "C2F_VLNT" )          // 10 - VALOR_NT       -> C2F_VLNT
SetHashKey(oHashC2F, "cst"                     , "C2F_CST#F3#" )       // 11 - CST            -> C2F_CST
SetHashKey(oHashC2F, "cfop"                    , "C2F_CFOP#F3#" )      // 12 - CFOP           -> C2F_CFOP
SetHashKey(oHashC2F, "taxRate"                 , "C2F_ALIQ" )          // 13 - ALIQUOTA       -> C2F_ALIQ
SetHashKey(oHashC2F, "serviceCode"             , "C2F_CODSER#F3#" )    // 14 - COD_LST        -> C2F_CODSER
SetHashKey(oHashC2F, "operationValue"          , "C2F_VLOPE" )         // 15 - VL_OPER        -> C2F_VLOPE

If TAFColumnPos( "C2F_VLSCRE" ) //protecao conforme TafLayout
    SetHashKey(oHashC2F, "valueWithoutCredit"  , "C2F_VLSCRE" )        // 16 - VL_SCRED       -> C2F_VLSCRE
endif

If TAFColumnPos( "C2F_CREDST" ) //protecao conforme TafLayout
    SetHashKey(oHashC2F, "previousICMSSTvalue" , "C2F_CREDST" )        // 17 - ICMNDES        -> C2F_ICMNDES
endif

//#F3# usado na gravação ou alteração dos tributos da capa
HMSet(oHashC2F, '#F3#C2F_CODTRI', "GetIDCached( 'C3S', aObjJson['taxCode'], 1 ,oTsiNFis:GetHashCahed('C3S'))")  //C3S_FILIAL, C3S_CODIGO
HMSet(oHashC2F, '#F3#C2F_CST'   , "ValCodCst( aObjJson['cst'], GetIDCached( 'C3S', aObjJson['taxCode'], 1 ,oTsiNFis:GetHashCahed('C3S')) )")               //C14_FILIAL, C14_CODIGO
HMSet(oHashC2F, '#F3#C2F_CFOP'  , "GetIDCached( 'C0Y', aObjJson['cfop'], 1 ,oTsiNFis:GetHashCahed('C0Y'))")     //C0Y_FILIAL, C0Y_CODIGO
HMSet(oHashC2F, '#F3#C2F_CODSER', "GetIDCached( 'C0B', cValToChar(Val(StrTran(aObjJson['serviceCode'],'.'))) , 1 ,oTsiNFis:GetHashCahed('C0B'))" ) //C0B_FILIAL, C0B_CODIGO

//Posicione referente aos tributos da capa ( utilizado no get )
HMSet(oHashC2F, 'C2F_CODTRI#POSIC#', "Posicione('C3S', 3, xFilial('C3S') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C3S_CODIGO' )") //C3S_FILIAL, C3S_ID
HMSet(oHashC2F, 'C2F_CST#POSIC#'   , "Posicione('C14', 3, xFilial('C14') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C14_CODIGO' )") //C14_FILIAL, C14_ID
HMSet(oHashC2F, 'C2F_CFOP#POSIC#'  , "Posicione('C0Y', 3, xFilial('C0Y') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C0Y_CODIGO' )") //C0Y_FILIAL, C0Y_ID
HMSet(oHashC2F, 'C2F_CODSER#POSIC#', "Posicione('C0B', 3, xFilial('C0B') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C0B_CODIGO' )") //C0B_FILIAL, C0B_ID

Return oHashC2F

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC21()
@author Rafael de Paula Leme
@since 19/10/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC21()

Local oHashC21 := HMNew( )

//Campos das informações complementares de documentos fiscais.
SetHashKey(oHashC21, 'complementaryInfoCode', 'C21_CODINF#F3#')
SetHashKey(oHashC21, 'auxiliaryCode',         'C21_CDINFO'    )
SetHashKey(oHashC21, 'complementaryInfoDesc', 'C21_DCODIN'    )
SetHashKey(oHashC21, 'complementaryInfoText', 'C21_DESCRI'    )

//#F3# usado na gravação ou alteração das informações complementares.
HMSet(oHashC21, '#F3#C21_CODINF', "GetIDCached( 'C3Q', aObjJson['complementaryInfoCode'], 1 ,oTsiNFis:GetHashCahed('C3Q'))") //C3Q_FILIAL, C3Q_CODINF

//Posicione referente as informações complementares do documento fiscal ( utilizado no get )
HMSet(oHashC21, 'C21_CODINF#POSIC#', "Posicione('C3Q', 3, xFilial('C3Q') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C3Q_CODINF' )") //C3Q_FILIAL, C3Q_ID

Return oHashC21

/*----------------------------------------------------------------------
{Protheus.doc} TafInfGen()
Otimizacao do uso de informacoes genericas
Prepara a macro execução para se obter o valor da chave ( tamanho 178 )
@author Henrique Pereira / Denis Souza
@since 16/11/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
function TafInfGen( cKey, cSeek, oHash )

//Prepara a macro execução para efetuar query de consulta da nota.
//Verifica a existencia da nota na base, se fez necessario por query,
//pois quando a nota eh cancelada ou excluída e existe a necessidade de alteracao,
//a situacao que faz parte da chave muda para "02" e o seek não encontra o registro.
cSeek := "NfExist("
cSeek += "XFUNCh2ID( aObjJson['modelIdentificationCode'], 'C01' , 1 , ,.T.)" //1 C20_CODMOD ok
cSeek += ",aObjJson['operationType']" //2 C20_INDOPE ok
cSeek += ",aObjJson['documentType']"  //3 C20_TPDOC ok
cSeek += ",aObjJson['taxDocumentIssuer']" //4 C20_INDEMI ok
cSeek += ",aObjJson['participatingCode']" //5 C20_CODPAR ok
//Nao utilizar a situacao devido o processo de integracao de nota excluida e cancelada do Protheus.
//cSeek += ",XFUNCh2ID( aObjJson['identificationSituation'] , 'C02' , 1 , ,.T.)" //6 x C20_CODSIT
cSeek += ",aObjJson['taxDocumentSeries']"  //7 C20_SERIE ok
cSeek += ",aObjJson['taxDocumentNumber']"  //9 C20_NUMDOC ok
cSeek += ",aObjJson['fiscalDocumentDate']" //10 C20_DTDOC ok
cSeek += ")"

//1.C20_CODMOD(6), 2.C20_INDOPE(1), 3.C20_TPDOC(6), 4.C20_INDEMI(1), 5.C20_CODPAR(36),
//6. C20_CODSIT(12), 7.C20_SERIE(20), 8.C20_SUBSER(20), 9.C20_NUMDOC(60), 10.C20_DTDOC(8), 11.C20_DTES(8)
cKey := "padr(XFUNCh2ID( aObjJson['modelIdentificationCode'], 'C01' , 1 , ,.T.),tamsx3('C20_CODMOD')[1])" //1 ok
cKey += "+padr(aObjJson['operationType'],tamsx3('C20_INDOPE')[1])" //2 ok
cKey += "+padr(XFUNCh2ID( aObjJson['documentType'], 'C0U' , 1 , ,.T.),tamsx3('C20_TPDOC')[1])" //3 ok
cKey += "+padr(aObjJson['taxDocumentIssuer'],tamsx3('C20_INDEMI')[1])" //4 ok
cKey += "+padr(XFUNCh2ID( aObjJson['participatingCode'], 'C1H' , 1 , ,.T.),tamsx3('C20_CODPAR')[1])" //5 ok
cKey += "+padr(XFUNCh2ID( aObjJson['identificationSituation'] , 'C02' , 1 , ,.T.),tamsx3('C20_CODSIT')[1])" //6 x
cKey += "+padr(aObjJson['taxDocumentSeries'],tamsx3('C20_SERIE')[1])" //7 ok
cKey += "+padr('',tamsx3('C20_SUBSER')[1])" //8 x ( campo vazio completado com espaco )
cKey += "+padr(aObjJson['taxDocumentNumber'],tamsx3('C20_NUMDOC')[1])" //9 ok
cKey += "+padr(DTOS(CTOD(aObjJson['fiscalDocumentDate'])),tamsx3('C20_DTDOC')[1])" //10 ok
cKey += "+padr(DTOS(CTOD(aObjJson['taxDocumentEntryAndExitDate'])),tamsx3('C20_DTES')[1])" //11 ok

//SFT Indice(2) FT_FILIAL, FT_TIPOMOV, FT_ENTRADA, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA
cKeyERP := "+padr(aObjJson['operationType'],tamsx3('C20_INDOPE')[1])"                             //FT_TIPOMOV
cKeyERP += "+'|'+padr(DTOS(CTOD(aObjJson['taxDocumentEntryAndExitDate'])),tamsx3('C20_DTES')[1])" //FT_ENTRADA
cKeyERP += "+'|'+padr(aObjJson['taxDocumentSeries'],tamsx3('C20_SERIE')[1])"                      //FT_SERIE
cKeyERP += "+'|'+padr(aObjJson['taxDocumentNumber'],tamsx3('C20_NUMDOC')[1])"                     //FT_NFISCAL
cKeyERP += "+'|'+padr( Alltrim( aObjJson['clieFor'] ), tamsx3('FT_CLIEFOR')[1] ) " //FT_CLIEFOR
cKeyERP += "+'|'+padr( Alltrim( aObjJson['loja'] ), tamsx3('FT_LOJA')[1] ) "       //FT_LOJA

// Infos genéricas
HMSet( oHash, 'm_o_d_e_l_'      , 'TAFA062'   )
HMSet( oHash, 'm_o_d_e_l_C_2_0_', 'MODEL_C20' )
HMSet( oHash, 's_o_u_r_c_e_'    , 'TAFA062'   )
HMSet( oHash, 'a_r_e_a_'        , 'C20'       )
HMSet( oHash, 'o_r_d_e_r_'      , 1           )
HMSet( oHash, 'k_e_y_'          , cKey        )
HMSet( oHash, 'k_e_y_e_r_p_'    , cKeyERP     )
HMSet( oHash, 's_e_e_k_'        , cSeek       )
HMSet( oHash, 't_a_g_i_d_'      , 'invoiceId' )

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} ValCodCst()
Ajusta o codigo do cst
@author Denis Souza
@since 12/11/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
static function ValCodCst(cCodCst,cIDTrib)
Local cAliasCst  := ''

Default cCodCst := ''
Default cIDTrib := ''

if !empty(cIDTrib)
    cAliasCst	:= XFUNChgF3(,,,cIdTrib) //Consulta tabela específica conforme o tributo.
endif    

if cCodCst == "0  " //mantem o mesmo mecanismo do extrator fiscal
    cCodCst := '00 '  
endif
cCodCst := alltrim(Posicione( cAliasCst , 1 , xFilial( cAliasCst ) + cCodCst , cAliasCst+'_ID' ))
if Empty( cCodCst )
    cCodCst := 'NOTFOUND'
endif

return cCodCst

/*----------------------------------------------------------------------
{Protheus.doc} ValCodMod()
Ajusta o codigo do modelo caso venha vazio
@author Henrique Pereira
@since 12/11/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
static function ValCodMod(cCodMod)
    Default cCodMod := ''
    if empty(cCodMod)
        cCodMod := '000001'
    endif
return cCodMod

/*----------------------------------------------------------------------
{Protheus.doc} Ws034Dipa()
Retorna o descrição da DIMPAM. Chamado do metadados.
@author Henrique Pereira / Denis Souza
@since 16/11/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
function Ws034Dipa()
return Iif(!INCLUI .and. !Empty(C30->C30_CODIPA),Posicione("LF0",1,xFilial("LF0")+C30->C30_CODIPA,"trim(LF0_CODIGO)+' - '+LF0_DESCRI"),"")

/*----------------------------------------------------------------------
{Protheus.doc} TafVldUniq
Verifica a exisitencia de duplicidade de chave unica, o VldData nao protegeu
a chave unica da C35. Nesse caso nao sera onerado, pois o array sera pequeno,
ja que armazena temporariamente apenas o(s) tributo(s) de apenas 1x item processado.
@type Static Function
@author Denis Souza
@since 22/12/2020
@return logico
//----------------------------------------------------------------------*/
Static Function TafVldUniq(cModel,oMldGen,aUniq,cKey,lErro,aRetJs)

    Local cChav1    := ""
    Local cChav2    := ""
    Local cChav3    := ""
    Local cErro     := ""
    Local nPos      := 0    
    Default cModel  := ''
    Default oMldGen := Nil
    Default aUniq   := {}
    Default cKey    := ''

    if cModel == "MODEL_C35" //UniqueLine( { 'C35_CODTRI' , 'C35_CST' , 'C35_ALIQ' }
        cChav1 := oMldGen:GetValue("C35_CODTRI")
        cChav2 := oMldGen:GetValue("C35_CST")
        cChav3 := cvaltochar( oMldGen:GetValue("C35_ALIQ") )
        nPos := aScan(aUniq,{|x| x[1] == cChav1 .and. x[2] == cChav2 .and. x[3] == cChav3 })
        if nPos > 0
            lErro := .F.
            cErro := "Tributo, CST e Alíquota em duplicidade: " + cChav1 + ", " + cChav2 + ", " + cChav3
            AgrupaErro( cKey, cErro, @aRetJs )
        else
            aadd(aUniq, {cChav1, cChav2, cChav3 } )
        endif
    endif

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} TsiStruct
Reduz os campos do DbStruct de acordo com a estrutura no hash.
Melhora a performance para cada nota processada no get, pois o array ja esta reduzido. 
Ex:
C20 --> De 68 abaixou para 28 registros ( 40 verificaoes a menos por capa )
C30 --> De 47 abaixou para 18 registros ( 29 verificaoes a menos por item )
C35 --> De 34 abaixou para 19 registros ( 15 verificaoes a menos por tributo no item )
C2F --> De 18 abaixou para 15 registros ( 03 verificaoes a menos por tributo na capa )
@type Static Function
@author Denis Souza
@since 22/12/2020
@return Nil
//----------------------------------------------------------------------*/
Static Function TsiStruct( aDbStru , oHash )

Local nlA  As Numeric
Local nAte As Numeric
Local nCnt As Numeric
Local cTag As Character

Default aDbStru := { "", "", 0, 0 } //[1]Titulo, [2]Tipo, [3]Tamanho, [4]Decimal
Default oHash   := Nil

nCnt := 0
cTag := ''
nAte := len( aDbStru )

if nAte > 0
    For nlA := 1 to nAte
        if ValType( aDbStru[nlA] ) == 'A'
            cCmp := alltrim(aDbStru[nlA][1])
            if aDbStru[nlA][2] == "D"
                cCmp += "#DT#"
            endif
            if !hmget( oHash, cCmp, @cTag ) .And. !hmget( oHash, (cCmp + "#F3#"), @cTag )
                //TAFConOut("--->apagou: " + alltrim(aDbStru[nlA][1] ) )
                ADel( aDbStru, nlA ) //Apaga posicao nao localizada
                ++nCnt //contator de itens apagados
                --nlA  //reduz o incremento para nao pular nenhum item
            endif
        endif
    Next nlA
    if nCnt > 0
        ASize( aDbStru, (nAte-nCnt) ) //Redimensiona o array apos N exclusoes
    endif
endif

Return aDbStru

/*----------------------------------------------------------------------
{Protheus.doc} VldC20Chv
Valida as Tags que formam a chave da Nota
@author Denis Souza
@since 07/01/2021
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Static Function VldC20Chv(aObjJson, cWarning)

Local aFld := {}
Local nlA  := 0
Local nCnt := 0
Default cWarning := ''

aAdd(aFld,'aObjJson["modelIdentificationCode"]')
aAdd(aFld,'aObjJson["operationType"]')
aAdd(aFld,'aObjJson["documentType"]')
aAdd(aFld,'aObjJson["taxDocumentIssuer"]')
aAdd(aFld,'aObjJson["participatingCode"]')
aAdd(aFld,'aObjJson["identificationSituation"]')
aAdd(aFld,'aObjJson["taxDocumentSeries"]')
aAdd(aFld,'aObjJson["taxDocumentNumber"]')
aAdd(aFld,'aObjJson["fiscalDocumentDate"]')
aAdd(aFld,'aObjJson["taxDocumentEntryAndExitDate"]')

for nlA := 1 to Len(aFld)
    if ValType( &(aFld[nlA]) ) == "U"
        if (++nCnt) > 1
            cWarning += ", "
        endif
        cWarning += StrTran( StrTran( StrTran( aFld[nlA] , "aObjJson[" ) , "]" ) , '\"')
    endif
Next nlA

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} NfExist()
Verifica a existencia da nota na base, se fez necessario por query,
pois quando a nota eh cancelada ou excluída e existe a necessidade de alteracao,
a situacao que faz parte da chave muda para "02" e o seek não encontra o registro.
@author Henrique Pereira / Denis Souza
@since 08/01/2021
@return logico.
//----------------------------------------------------------------------*/
static function NfExist(cCodMod, cOperType, cDocuType, cIndEmi, cPartCod, cSerie, cNumDoc, cDtDoc )

    Local lRet   as logical
    Local cAlias as character

    lRet     := .F.
    cPartCod := XFUNCh2ID( cPartCod , 'C1H' , 1 , ,.T.)
    cAlias   := GetNf( cNumDoc, cNumDoc,/*nPage*/,/*nPageSize*/,/*cOrder*/, cCodMod, cOperType, cPartCod, cSerie, cDtDoc, cIndEmi )

    if (cAlias)->(!EOF())
        C20->(DbGoTo((cAlias)->R_E_C_N_O_)) //posiciona na nota correspondente para atualizar corretamente
        lRet := .T.
    endif

    ( cAlias )->( DBCloseArea( ) )

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetIDCached()
Busca o _ID de cada consulta F3 no cache da tabela e caso não encontre, 
pesquisa diretamente na tabela e alimenta o cache para uma próxima busca.
@author Renan Quadros
@since 29/07/2022
/*/ 
//-----------------------------------------------------------------------
Function GetIDCached( cAlias, cChave, nIndex, oHash )
Local   cRet := '' 
Default cAlias := ''
Default cChave := ''
Default nIndex := 0

if ValType(oHash) == "O"
    HMGet( oHash, cChave, @cRet )
    if Empty(cRet)
        cRet := GetTafId( cAlias, cChave, nIndex, oHash )
        SetHashKey(oHash, cChave, cRet) 
    Endif
else   
    cRet := GetTafId( cAlias, cChave, nIndex, oHash )
endif

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDelInc()
Exclui o registro posicionado e posteriormente seta operação para inclusão

@author Denis de Souza Naves
@since 04/07/2024
/*/ 
//-----------------------------------------------------------------------
Static Function ModelDelInc(oModel,nOpcao)

Default oModel := Nil
Default nOpcao := 0

oModel:DeActivate()
oModel:SetOperation( MODEL_OPERATION_DELETE )
oModel:Activate()

FwFormCommit( oModel )

oModel:DeActivate()

nOpcao := MODEL_OPERATION_INSERT

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelChvNf()
Controle para a nova chave que ira ser integrada

@author Denis de Souza Naves
@since 04/07/2024
/*/ 
//-----------------------------------------------------------------------
Static Function ModelChvNf(oTsiNFis,aObjJson,cDocNumber)

Local cChv := ''

Default oTsiNFis   := Nil
Default aObjJson   := {}
Default cDocNumber := ''

cChv := padr(aObjJson['operationType'],_nTmINDOPE)
cChv += ValCodMod(padr(GetIDCached('C01',aObjJson['modelIdentificationCode'],1,oTsiNFis:GetHashCahed('C01')),_nTmCODMOD))
cChv += padr(aObjJson['taxDocumentSeries'],_nTmSERIE)
cChv += padr('',_nTmSUBSER)
cChv += padr(cDocNumber,_nTmNUMDOC)
cChv += padr(DTOS(CTOD(aObjJson['fiscalDocumentDate'])),_nTmDTDOC)
cChv += padr(GetIDCached('C1H',aObjJson['participatingCode'],1,oTsiNFis:GetHashCahed('C1H')),_nTmCODPAR)

Return cChv
