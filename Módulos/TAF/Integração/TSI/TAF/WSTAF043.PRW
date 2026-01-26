#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static __cTagID   := 'socialSecurityContribution'
Static __cUrl     := 'https://api.totvs.com.br/'
Static __oHashC5M := HashC5M()
Static __oHashT9T := HashT9T()
Static __oHashV48 := HashV48()

/*--------------------------------------------------------------------------/
{Protheus.doc} WSTAF043
WS para persistencia do CPRB
Extracao TAFA566 ( CPRB )
MVC TAFA097 ( C5M )
@author Denis Souza
@since 21/09/2021
@version 1.0
//----------------------------------------------------------------------*/
WSRESTFUL tsiSocialSecurityContribution DESCRIPTION "TAF Service Integration - CPRB"

    WSDATA sourceBranch     As string
    WSDATA page			    As integer optional
    WSDATA pageSize 	    As integer optional
    WSDATA order            As string  optional
    WSDATA dateOf           As string
    WSDATA dateUp           As string
    WSDATA activityCode     As string  optional
    WSDATA contributionRate As float   optional
    WSDATA accountCode      As string  optional
    WSDATA id               As string

	WSMETHOD GET tsiSocialSecurityContribution;
    DESCRIPTION "Retorna uma lista de CPRB";
    PATH 'api/tsi/v1/tsiSocialSecurityContribution/';
    TTALK "tsiSocialSecurityContribution";
    WSSYNTAX "/tsiSocialSecurityContribution";
    PRODUCES APPLICATION_JSON
 
    WSMETHOD GET idTsiSocialSecurityContribution;
    DESCRIPTION "Retorna uma CPRB pelo ID";
    PATH 'api/tsi/v1/tsiSocialSecurityContribution/idTsiSocialSecurityContribution/';
    TTALK "tsiSocialSecurityContribution";
    WSSYNTAX "/tsiSocialSecurityContribution";
    PRODUCES APPLICATION_JSON

    WSMETHOD POST tsiSocialSecurityContribution; 
    DESCRIPTION "Inclui/altera uma lista de CPRB";
    PATH 'api/tsi/v1/tsiSocialSecurityContribution/';
    TTALK "tsiSocialSecurityContribution";
    WSSYNTAX "/tsiSocialSecurityContribution";
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT tsiSocialSecurityContribution;
    DESCRIPTION "Altera uma lista de CPRB";
    PATH 'api/tsi/v1/tsiSocialSecurityContribution/';
    TTALK "tsiSocialSecurityContribution";
    WSSYNTAX "/tsiSocialSecurityContribution";
    PRODUCES APPLICATION_JSON
 
    WSMETHOD DELETE tsiSocialSecurityContribution;
    DESCRIPTION "Deleta uma CPRB  ";
    PATH 'api/tsi/v1/tsiSocialSecurityContribution/';
    TTALK "tsiSocialSecurityContribution";
    WSSYNTAX "/tsiSocialSecurityContribution";
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE idTsiSocialSecurityContribution;
    DESCRIPTION "Deleta uma CPRB pelo ID";
    PATH 'api/tsi/v1/tsiSocialSecurityContribution/idTsiSocialSecurityContribution/';
    TTALK "tsiSocialSecurityContribution";
    WSSYNTAX "/tsiSocialSecurityContribution";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

/*----------------------------------------------------------------------
{Protheus.doc} GET tsiSocialSecurityContribution
Metodo responsável por consultar a chave do CPRB no TAF

@param sourceBranch
@param page             opc
@param pageSize         opc
@param dateOf           obg
@param dateUp           obg
@param activityCode     opc
@param contributionRate opc
@param accountCode      opc
@param order

@param order
@type  WSMETHOD
@author Denis Souza
@since 21/09/2021
//----------------------------------------------------------------------*/
WSMETHOD GET tsiSocialSecurityContribution WSRECEIVE sourceBranch, page, pageSize, dateOf, dateUp, activityCode, contributionRate, accountCode, order WSREST tsiSocialSecurityContribution

Local oJsonResp  As Object
Local cDataDe    As Character
Local cDataAte   As Character
Local cActivCode As Character
Local cAccCode   As Character
Local nPage      As Numeric
Local nPageSize  As Numeric
Local xOrder     As Character
Local lOk        As Logical

cDataDe    := ''
cDataAte   := ''
cActivCode := ''
cAccCode   := ''
nPage      := 0
nPageSize  := 10
xOrder     := ''
lOk        := .F.
xContrRate := Nil

oJsonResp := JsonObject():New()

If VldExecute( self:sourceBranch, @oJsonResp )
  
    If valtype( self:page ) <> 'U' .and. self:page > 0
        nPage := self:page
        If valtype( self:pageSize ) <> 'U' .and. self:pageSize > 0
            nPageSize := self:pageSize
        EndIf
    EndIf

    //C5M_DTINI obg
    If valtype( self:dateOf ) <> 'U' .and. !Empty(self:dateOf)
        cDataDe := self:dateOf
        cDataDe := ValTsiData(cDataDe)
    EndIf
    //C5M_DTFIM obg
    If valtype( self:dateUp ) <> 'U' .and. !Empty(self:dateUp)
        cDataAte := self:dateUp
        cDataAte := ValTsiData(cDataAte)
    EndIf
    //C5M_CODATI opc
    If valtype( self:activityCode ) <> 'U' .and. !Empty(self:activityCode)
        cActivCode := self:activityCode
    EndIf

    //C5M_ALQCON opc
    //importante devera ser passado com ponto no decimal ao inves de virgula senao chegara apenas o inteiro e nao localizara o registro
    If  valtype( self:contributionRate ) == "N"
        xContrRate := self:contributionRate
    EndIf
    //C5M_CODCTA opc
    If valtype( self:accountCode ) <> 'U' .and. !Empty(self:accountCode)
        cAccCode := self:accountCode
    EndIf

    If valtype( self:order ) <> 'U' .and. !Empty(self:order)
        xOrder := self:order
    EndIf

    If valtype(self:dateOf) <> 'U' .AND. valtype(self:dateUp) <> 'U'
        getWS043(@oJsonResp,cDataDe,cDataAte,"",cActivCode,xContrRate,cAccCode,@lOK,nPage,nPageSize,xOrder)
        If !lOk
            SetErroJs( @oJsonResp, __cTagID, , __cUrl, '404' )
        EndIf
    Else
        SetErroJs( @oJsonResp, __cTagID, , __cUrl, '400',,,,.F. )    
    EndIf
EndIf

cJsonResp := FwJsonSerialize( oJsonResp ) //Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
cJsonResp := ''

Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} GET idTsiSocialSecurityContribution
Metodo responsável por consultar o Id no CPBR do TAF

@param sourceBranch
@param id
@type  WSMETHOD
@author Denis Souza
@since 21/09/2021
//----------------------------------------------------------------------*/
WSMETHOD GET idTsiSocialSecurityContribution WSRECEIVE sourceBranch, id WSREST tsiSocialSecurityContribution

Local cJsonResp  As Character
Local cId        As Character
Local oJsonResp  As Object
Local lOk        As Logical
Local cActivCode As Character
Local cAccCode   As Character

cId       := iif(valtype( self:id  ) <> 'U' .and. !empty(self:id ),self:id ," ")
cJsonResp := ''
lOk       := .F.

cActivCode := ''
xContrRate := Nil
cAccCode   := ''

oJsonResp := JsonObject():New()
If VldExecute( self:sourceBranch, @oJsonResp )
    If valtype(self:id ) <> 'U'
        getWS043( @oJsonResp,/*2*/,/*3*/,cId,cActivCode,xContrRate,cAccCode,@lOk)
        If !lOk
            SetErroJs( @oJsonResp, __cTagID, , __cUrl, '404' )
        EndIf
    else
        SetErroJs( @oJsonResp, __cTagID, , __cUrl, '400',,,,.F. )
    EndIf
endif

cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
cJsonResp := ''

Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} getWS043()
Executa a query de consulta para o retorno ao método get da apuração ICMS
e monta o jason de resposta
@author Denis Souza
@since 21/09/2021
//----------------------------------------------------------------------*/
Function getWS043(oJsonResp,cDataDe,cDataAte,cId,cActivCode,xContrRate,cAccCode,lOk,nPage,nPageSize,xOrder)

Local cJsonResp  as Character
Local cAlias     as Character
Local nPageAux   as Numeric
Local lHasNext   as Logical
Local aStructC5M as array
Local oModel     as Object
Local oMdlC5M    as Object
Local aStructT9T as array
Local oMdlT9T    as Object 
Local nTmGrid    as Numeric
Local oJsonT9T   as Object
Local nlA        as Numeric
Local nPos       as Numeric
Local aStructV48 as array
Local oMdlV48    as Object    
Local oJsonV48   as Object


Default cDataDe    := ''
Default cDataAte   := ''
Default cId        := ''
Default cActivCode := ''
Default xContrRate := Nil
Default cAccCode   := ''
Default nPage      := 0
Default nPageSize  := 10
Default xOrder     := ''

cJsonResp  := ''
cAlias     := ''
cTagJson   := ''
cOrder     := ''
nPageAux   := 0
lHasNext   := .F.
aStructC5M := {}
aStructT9T := {}
nTmGrid    := 0
nlA        := 0
nPos       := 0
aStructV48 := {}

oModel  := Nil
oMdlC5M := Nil
oMdlT9T := Nil
oJsonT9T := JsonObject():New()
oMdlV48  := Nil
oJsonV48 := JsonObject():New()

hmget( __oHashC5M, xOrder, @cOrder )
If !Empty(cOrder)
    cOrder := StrTran(StrTran(cOrder, "#DT#", ""),"#F3#", "")
EndIf

// executo a query do cabeçalho da nota fiscal
cAlias := GetCPRB(cDataDe,cDataAte,cId,cActivCode,xContrRate,cAccCode,nPage,nPageSize,xOrder)

//monto As estruturas para serem passadas a getJson
aStructC5M := C5M->(DBStruct())
aStructT9T := T9T->(DBStruct())
aStructV48 := V48->(DBStruct())

DbSelectArea("C5M")
C5M->(dbSetOrder(3)) //C5M_FILIAL, C5M_ID

//Carrega Modelo fora do laco
oModel := FwLoadModel( "TAFA097" )

while (cAlias)->(!eof())
    If C5M->(DbSeek( (cAlias)->C5M_FILIAL + (cAlias)->C5M_ID ))
        nPageAux++
        lOk := .T.
        oModel:SetOperation( 1 )
        oModel:Activate()

        oMdlC5M := oModel:GetModel("MODEL_C5M")

        If nPageAux <= nPageSize
            /*-----------------------------------
            |               CAPA                |
            ------------------------------------*/
            TsiGetJson( @oJsonResp, __oHashC5M, aStructC5M, @oMdlC5M, __cTagID, nPageAux, "socialSecurityContribution" )

            /*-----------------------------------
            |               FILHO                |
            ------------------------------------*/

            //Layout T082AC
            oMdlT9T := oModel:GetModel("MODEL_T9T")
            nTmGrid  := oMdlT9T:Length()
            for nlA := 1 to nTmGrid
                oMdlT9T:GoLine( nlA )
                TsiGetJson( @oJsonT9T, __oHashT9T, aStructT9T, @oMdlT9T, 'adjustment', nlA, "socialSecurityContribution|cnoSocialSecurityContribution|adjustment|" )
            next nlA

            oJsonResp['socialSecurityContribution'][Len( oJsonResp['socialSecurityContribution' ] )]['adjustment'] := oJsonT9T['adjustment'] 

            //Layout T082AD
            oMdlV48 := oModel:GetModel("MODEL_V48")
            nTmGrid  := oMdlV48:Length()
            for nlA := 1 to nTmGrid
                oMdlV48:GoLine( nlA )
                TsiGetJson( @oJsonV48, __oHashV48, aStructV48, @oMdlV48, 'cnoSocialSecurityContribution', nlA, "socialSecurityContribution|cnoSocialSecurityContribution|adjustment|" )
            next nlA

            oJsonResp['socialSecurityContribution'][Len( oJsonResp['socialSecurityContribution' ] )]['cnoSocialSecurityContribution'] := oJsonV48['cnoSocialSecurityContribution'] 

        Else
            lHasNext := .T.
        EndIf
        oModel:DeActivate()
    EndIf
    (cAlias)->(DbSkip())
EndDo

If cDataDe <> cDataAte; oJsonResp["hasnext"] := lHasNext ; EndIf

If Select(cAlias) > 0; (cAlias)->(dbCloseArea()); EndIf

Return oJsonResp


/*----------------------------------------------------------------------
{Protheus.doc} POST tsiSocialSecurityContribution
Persisti operações de inclusão no cadastro CPRB - Layout T082
@type  WSMETHOD
@author  Denis Naves / Renan Gomes
@since 22/09/2021
//----------------------------------------------------------------------*/
WSMETHOD POST tsiSocialSecurityContribution WSREST tsiSocialSecurityContribution
    WsTSIProc( self, .F., __oHashC5M )
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} PUT tsiSocialSecurityContribution
Persisti operações de inclusão no cadastro CPRB - Layout T082
@type  WSMETHOD
@author Denis Naves / Renan Gomes
@since 22/09/2021
//----------------------------------------------------------------------*/
WSMETHOD PUT tsiSocialSecurityContribution WSREST tsiSocialSecurityContribution
    WsTSIProc( self, .F., __oHashC5M )
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} DELETE tsiSocialSecurityContribution
Persistir operações de deleção do cadastro de CPRB pela chave
@type  WSMETHOD
@author Renan Gomes
@since 21/09/2021
//----------------------------------------------------------------------*/
WSMETHOD DELETE tsiSocialSecurityContribution WSRECEIVE sourceBranch, dateOf, dateUp  WSREST tsiSocialSecurityContribution

Local oModel    AS Object
Local oJsonResp As Object
Local cDataDe   As Character
Local cDataAte  As Character
Local cJsonResp As Character
Local aRetJs    As Array

oJsonResp   := JsonObject():New() // retorno
cJsonResp   := ""
cDataDe     := ""
cDataAte    := ""
aRetJs      := {}

If VldExecute( self:sourceBranch, @oJsonResp )
    If (valtype( self:dateOf ) <> 'U' .and. !Empty(self:dateOf)) .and.(valtype( self:dateUp ) <> 'U' .and. !Empty(self:dateUp))
        cDataDe := self:dateOf
        cDataDe := ValTsiData(cDataDe)
        cDataAte := self:dateUp
        cDataAte := ValTsiData(cDataAte)

        DbSelectArea( "C5M" )
        C5M->(DbSetOrder(1))   //C5M_FILIAL+DTOS(C5M_DTINI)+DTOS(C5M_DTFIM)+C5M_CODATI+STR(C5M_ALQCON)+C5M_CODCTA
        C5M->(dbGoTop())
        if C5M->(DbSeek(xFilial("C5M")+cDataDe+cDataAte,.T.)) //Não filtro o restante da chave pois quero excluir todo o movimento do
                                                              //periodo informado.
            BEGIN TRANSACTION
                while C5M->(!EOF()) .AND.  C5M->(C5M_FILIAL+DTOS(C5M_DTINI)+DTOS(C5M_DTFIM)) == xFilial("C5M")+cDataDe+cDataAte
                    oModel := FWLoadModel( 'TAFA097' )
                    oModel:SetOperation( 5 )
                    oModel:Activate()
                    FwFormCommit( oModel )
                    aadd( aRetJs, { .T., C5M->( DTOS(C5M_DTINI)+DTOS(C5M_DTFIM)+C5M_CODATI+STR(C5M_ALQCON)+C5M_CODCTA ) } ) 
                    C5M->(dbSkip())
                enddo 
            END TRANSACTION                                                                            
        Else
            SetErroJs( @oJsonResp,,,,'404' )
        EndIf
        dbCloseArea()
    Else
        SetErroJs( @oJsonResp, __cTagID, , __cUrl, '400',,,,.F. )    
    EndIf
endif

oJsonResp[__cTagID] := {}
SetErroJs(@oJsonResp, __cTagID, @aRetJs,,"403" )
cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )

Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} DELETE idTsiSocialSecurityContribution
Persistir operações de deleção do cadastro de CPRB pelo ID
@type  WSMETHOD
@author Renan Gomes
@since 21/09/2021
//----------------------------------------------------------------------*/
WSMETHOD DELETE idTsiSocialSecurityContribution WSRECEIVE sourceBranch, id  WSREST tsiSocialSecurityContribution

Local oJsonResp As Object
Local cJsonResp As Character
Local cArea     As Character
Local cSource   As Character
Local cId       As Character
Local aRetJs    As Array

oJsonResp   := JsonObject():New() // retorno
cJsonResp   := ""
aRetJs      := {}
cArea       := ""
cSource     := ""
cId         := iif(valtype( self:id  ) <> 'U' .and. !empty(self:id ),self:id ," ")

hmget( __oHashC5M, "s_o_u_r_c_e_", @cSource  )
hmget( __oHashC5M, "a_r_e_a_"    , @cArea    )

If VldExecute( self:sourceBranch, @oJsonResp )
    If !Empty(cID)
        DbSelectArea(cArea)
        C5M->( DbSetOrder(3) ) //C5M_FILIAL, C5M_ID, R_E_C_N_O_, D_E_L_E_T_
        If C5M->( DbSeek( xfilial('C5M') + cID ) )
            oModel := FWLoadModel( cSource )
            oModel:SetOperation( 5 )
            oModel:Activate()
            FwFormCommit( oModel )
            aadd( aRetJs, { .T., C5M->( DTOS(C5M_DTINI)+DTOS(C5M_DTFIM)+C5M_CODATI+STR(C5M_ALQCON)+C5M_CODCTA ) } )
        Else
            SetErroJs( @oJsonResp,,,,'404' )
        EndIf
    EndIf    
Else
    SetErroJs( @oJsonResp,,,__cUrl, '400',,,,.T. )
EndIf

oJsonResp[__cTagID] := {}
SetErroJs(@oJsonResp, __cTagID, @aRetJs,,"403" )
cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )

Return .T.

/*--------------------------------------------------------------------------------
{Protheus.doc} GetCPRB()
(Responsável por executar a consulta ao CPRB)
@author Denis Souza
@since 21/09/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
static Function GetCPRB(cDataDe,cDataAte,cIDApur,cActivCode,xContrRate,cAccCode,nPage,nPageSize,xOrder)

Local cAlias := getNextAlias()
Local cQry   := ''

Default cIDApur    := ''
Default cActivCode := ''
Default xContrRate := Nil
Default cAccCode   := ''

If nPage == 0 
    nPage := 1
EndIf

If nPageSize == 0
    nPageSize := 10
EndIf

If Empty(cDataAte)
    cDataAte := DtoS(LastDay(StoD(cDataDe)))
EndIf

cQry += " SELECT C5M.C5M_FILIAL, C5M.C5M_ID, C5M.C5M_DTINI, C5M.C5M_DTFIM, C5M.C5M_VTOT"
cQry += " ,C5M.C5M_CODATI, C5M.C5M_VATIV, C5M.C5M_VEXC"
cQry += " ,C5M.C5M_BASE, C5M.C5M_ALQCON, C5M.C5M_VCON"
cQry += " ,C5M.C5M_CODCTA, C5M.C5M_INFCOM"

If TAFColumnPos( "C5M_STAMP" )
    cQry += ", C5M.C5M_STAMP"
EndIf

If TAFColumnPos( "C5M_VCPEXS" )
    cQry += ", C5M.C5M_VCPEXS"
EndIf

if !Empty( cActivCode )
    cQry += " ,C5V.C5V_CODIGO"
endif

if !Empty( cAccCode )
    cQry += " ,C1O.C1O_CODIGO"
endif

cQry += " FROM "+RetSqlName("C5M") + " C5M "

if !Empty( cActivCode )
    cQry += " INNER JOIN " + RetSqlName("C5V") + " C5V ON "
    cQry += " C5V.C5V_FILIAL = '" + xFilial("C5V") + "' "
    cQry += " AND C5V.C5V_ID = C5M.C5M_CODATI "
    cQry += " AND C5V.C5V_CODIGO = '" + cActivCode + "' "
    cQry += " AND C5V.D_E_L_E_T_ = ' ' "
endif

if !Empty( cAccCode )
    cQry += " INNER JOIN " + RetSqlName("C1O") + " C1O ON "
    cQry += " C1O.C1O_FILIAL = '" + xFilial("C1O") + "' "
    cQry += " AND C1O.C1O_ID = C5M.C5M_CODCTA "
    cQry += " AND C1O.C1O_CODIGO = '" + cAccCode + "' "
    cQry += " AND C1O.D_E_L_E_T_ = ' ' "
endif

cQry += " WHERE C5M.C5M_FILIAL = '" + xFilial("C5M") + "'"

If !empty(cIDApur) //prioriza com ID
    cQry += " AND C5M.C5M_ID = '" + cIDApur + "'"
Else
    cQry += " AND C5M.C5M_DTINI >= '" + cDataDe + "'"
    cQry += " AND C5M.C5M_DTFIM <= '" + cDataAte + "'"

    //importante devera ser passado com ponto no decimal ao inves de virgula senao chegara apenas o inteiro e nao localizara o registro
    if type("xContrRate")=="N" //valor enviado por parametro
        cQry += " AND C5M.C5M_ALQCON = " + alltrim( str(xContrRate) )
    endif
EndIf
cQry += " AND C5M.D_E_L_E_T_ = ' ' "

If !empty(cOrder)
    cQry += " ORDER BY " + cOrder
Else
    cQry += " ORDER BY 1 "
EndIf
cQry += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nPageSize) + " ) ROWS "
cQry += " FETCH NEXT " + cValToChar(nPageSize+1) + " ROWS ONLY "

dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)

Return cAlias

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC5M()
Cria Hash de "De|Para" do identIficador do Json para o campo de gravação no TAF
da Contribuição Previdenciária sobre Receita Bruta - Layout T082
@author Renan Gomes
@since 21/09/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC5M()

Local oHash       := HMNew( )
Local cSeek       := ""
Local cKey        := ""
Local cTamAtiv    := lTrim(cValToChar(GetSx3Cache( 'C5M_CODATI' , 'X3_TAMANHO' )))
Local cTamCCtb    := lTrim(cValToChar(GetSx3Cache( 'C5M_CODCTA' , 'X3_TAMANHO' )))
Local cTamAlqCon  := lTrim(cValToChar(GetSx3Cache( 'C5M_ALQCON' , 'X3_TAMANHO' )))

cKey := "ValTsiData(aObjJson['startDate'])+"   //1 C5M_DTINI 
cKey += "ValTsiData(aObjJson['endDate'])+"     //2 C5M_DTFIM 
cKey += "padr(GetTafId( 'C5V', aObjJson['activityCode'], 1 ), "+cTamAtiv+")+" //3 C5M_CODATI 
cKey += "Padr(Alltrim(str(aObjJson['contributionRate'])), "+cTamAlqCon+")+" //4 C5M_ALQCON
cKey += "padr(GetTafId( 'C1O', aObjJson['accountCode'], 1 ), "+cTamCCtb+")" //5 C5M_CODCTA

cSeek := "C5M->(DbSeek(xfilial('C5M')+"
cSeek += "ValTsiData(aObjJson['startDate'])+"  //1 C5M_DTINI 
cSeek += "ValTsiData(aObjJson['endDate'])))"    //2 C5M_DTFIM 

//#F3# usado na gravação ou alteração
HMSet(oHash, '#DT#C5M_DTINI'   , "ValTsiData(aObjJson['startDate'])" ) 
HMSet(oHash, '#DT#C5M_DTFIM'   , "ValTsiData(aObjJson['endDate'])" ) 
HMSet(oHash, '#F3#C5M_CODATI'  , "GetTafId( 'C5V', aObjJson['activityCode'], 1 )" ) 
HMSet(oHash, '#F3#C5M_CODCTA'  , "GetTafId( 'C1O', aObjJson['accountCode'], 1 )" ) 

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'  , 'MODEL_C5M'    )
HMSet(oHash, 's_o_u_r_c_e_', 'TAFA097'      )
HMSet(oHash, 'a_r_e_a_'    , 'C5M'          )
HMSet(oHash, 'o_r_d_e_r_'  , 1              ) //C5M_FILIAL, C5M_DTINI, C5M_DTFIM, C5M_CODATI, C5M_ALQCON, C5M_CODCTA, R_E_C_N_O_, D_E_L_E_T_
HMSet(oHash, 'k_e_y_'      , cKey           )
HMSet(oHash, 's_e_e_k_'    , cSeek          )
HMSet(oHash, 't_a_g_i_d_'  , __cTagID       )

//                                  model filho,    tag filho,                       hash filho
HMSet(oHash, 's_u_b_m_o_d_e_l_', { {'MODEL_T9T'   ,'adjustment'                   , 'HashT9T()' },;
                                   {'MODEL_V48'   ,'cnoSocialSecurityContribution', 'HashV48()' } })

//Posicione ( utilizado no get )
HMSet(oHash, 'C5M_CODATI#POSIC#', "Posicione('C5V', 3, xFilial('C5V') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C5V_CODIGO'     )") 
HMSet(oHash, 'C5M_CODCTA#POSIC#', "Posicione('C1O', 3, xFilial('C1O') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1O_CODIGO'     )") 

// Propriedades e Campos
SetHashKey(oHash, 'id'                           , 'C5M_ID' )
SetHashKey(oHash, 'startDate'                    , 'C5M_DTINI#DT#' )
SetHashKey(oHash, 'endDate'                      , 'C5M_DTFIM#DT#' )
SetHashKey(oHash, 'totalValue'                   , 'C5M_VTOT' )
SetHashKey(oHash, 'activityCode'                 , 'C5M_CODATI#F3#' )
SetHashKey(oHash, 'grossIncome'                  , 'C5M_VATIV' )
SetHashKey(oHash, 'exclusionValue'               , 'C5M_VEXC' )
SetHashKey(oHash, 'baseValue'                    , 'C5M_BASE' )
SetHashKey(oHash, 'contributionRate'             , 'C5M_ALQCON' )
SetHashKey(oHash, 'contributionValue'            , 'C5M_VCON' )
SetHashKey(oHash, 'accountCode'                  , 'C5M_CODCTA#F3#' )
SetHashKey(oHash, 'complementInformation'        , 'C5M_INFCOM' )
SetHashKey(oHash, 'suspensionSocialContribution' , 'C5M_VCPEXS' )
SetHashKey(oHash, 'stamp'                        , 'C5M_STAMP')

Return oHash

/*--------------------------------------------------------------------------------
{Protheus.doc} HashT9T()
Cria Hash de "De|Para" do identificador do Json para o campo de gravação no TAF
do tipo de ajuste para CPRB ( T082AC )
@author Denis / Wesley Matos
@since 06/01/2022
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashT9T()
Local oHash := HMNew( )

SetHashKey(oHash, "adjustmentType"       , 'T9T_TPAJUS' ) //TPAJUSTE 
SetHashKey(oHash, "adjustmentCode"       , 'T9T_CODAJU' ) //CODAJUSTE
SetHashKey(oHash, "adjustmentValue"      , 'T9T_VLRAJU' ) //VLRAJUSTE
SetHashKey(oHash, "adjustmentDescription", 'T9T_DESCAJ' ) //DESCAJUSTE
SetHashKey(oHash, "adjustmentDate"       , 'T9T_DTAJUS' ) //DTAJUSTE

Return oHash

/*--------------------------------------------------------------------------------
{Protheus.doc} HashV48()
Cria Hash de "De|Para" do identIficador do Json para o campo de gravação no TAF
da Contribuição Previdenciária sobre Receita Bruta com CNO - Layout T082AD
@author Karen / Jose Felipe
@since 06/01/2022
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashV48()
Local oHash       := HMNew( )
Local cTamNRInsc := lTrim(cValToChar(GetSx3Cache('T9C_NRINSC','X3_TAMANHO')))

SetHashKey(oHash, 'grossValue'                , 'V48_VATIV' )  //VL_REC_ATIV_ESTAB 
SetHashKey(oHash, 'deletionValue'             , 'V48_VEXC' )   //VL_EXC
SetHashKey(oHash, 'baseValue'                 , 'V48_BASE' )    //VL_BC_CONT
SetHashKey(oHash, 'accountingRate'            , 'V48_ALQCON' )    //ALIQ_CONT
SetHashKey(oHash, 'cprbValue'                 , 'V48_VCON' )  //VL_CONT_APU
SetHashKey(oHash, 'accountCode'               , 'V48_CODCTA#F3#' ) //COD_CTA 
SetHashKey(oHash, "cnoNumber"                 , "V48_IDCNO#F3#" )  //CNO

HMSet(oHash, '#F3#V48_IDCNO' , "GetTafId( 'T9C', padr(aObjJson['cnoNumber']," + cTamNRInsc + "), 2 )" )                //T9C_FILIAL, T9C_NRINSC
HMSet(oHash, '#F3#V48_CODCTA' , "GetTafId( 'C1O',aObjJson['accountCode'], 1 )" ) 

//Posicione utilizado no get
HMSet(oHash, 'V48_CODCTA#POSIC#', "Posicione('C1O', 3, xFilial('C1O') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1O_CODIGO'     )")
HMSet(oHash, 'V48_IDCNO#POSIC#', "Posicione('T9C', 1, xFilial('T9C') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'T9C_NRINSC'     )") //T9C_FILIAL, T9C_ID

Return oHash

/*----------------------------------------------------------------------
{Protheus.doc} VldChvC5M
Valida as Tags que formam a chave da Contribuição Previdenciária sobre Receita Bruta - Layout T082
@author Renan Gomes
@since 21/09/2021
@return cWarning, caracter, caso falte alguma chave, retorna erro
//----------------------------------------------------------------------*/
Function VldChvC5M(aObjJson)

Local aFld := {}
Local nlA  := 0
Local nCnt := 0
Local cWarning := ''
If Valtype(aObjJson) <> "U"
    aAdd(aFld,'aObjJson["startDate"]')
    aAdd(aFld,'aObjJson["endDate"]')
    aAdd(aFld,'aObjJson["activityCode"]')
    aAdd(aFld,'aObjJson["contributionRate"]')

    for nlA := 1 to Len(aFld)
        If ValType( &(aFld[nlA]) ) == "U"
            If (++nCnt) > 1
                cWarning += ", "
            endIf
            cWarning += StrTran( StrTran( StrTran( aFld[nlA] , "aObjJson[" ) , "]" ) , '\"')
        endIf
    Next nlA
EndIf
Return cWarning
