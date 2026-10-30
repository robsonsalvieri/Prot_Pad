#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static __cTagIcms := 'apurationIcms'
Static __cUrl     := 'https://api.totvs.com.br/'
Static __oHashC2S := HashC2S()
Static __oHashC2T := HashC2T()
Static __oHashT02 := HashT02()

/*--------------------------------------------------------------------------/
{Protheus.doc} WSTAF039
WS para persistencia do cadastro de apurações ICMS no TAF

@author Karen Honda   
@since 22/07/2021
@version 1.0
//----------------------------------------------------------------------*/
WSRESTFUL tsiApurationIcms DESCRIPTION "TAF Service Integration - Apuração ICMS"

    WSDATA sourceBranch             As string
    WSDATA page			            As integer optional
    WSDATA pageSize 	            As integer optional
    WSDATA order                    As string  optional
    WSDATA dateOf                   As string  optional
    WSDATA dateUp                   As string  optional
    WSDATA typeApuration            As string  optional
    WSDATA indApuration             As string  optional
    WSDATA id                       As string  optional

	WSMETHOD GET tsiApurationIcms;
    DESCRIPTION "Retorna uma lista de Apurações ICMS";
    PATH 'api/tsi/v1/tsiApurationIcms/';
    TTALK "tsiApurationIcms";
    WSSYNTAX "/tsiApurationIcms";
    PRODUCES APPLICATION_JSON
 
    WSMETHOD GET idTsiApurationIcms;
    DESCRIPTION "Retorna uma Apurações ICMS pelo ID";
    PATH 'api/tsi/v1/tsiApurationIcms/idTsiApurationIcms/';
    TTALK "tsiApurationIcms";
    WSSYNTAX "/tsiApurationIcms";
    PRODUCES APPLICATION_JSON

    WSMETHOD POST tsiApurationIcms; 
    DESCRIPTION "Inclui/altera uma lista de Apuração ICMS";
    PATH 'api/tsi/v1/tsiApurationIcms/';
    TTALK "tsiApurationIcms";
    WSSYNTAX "/tsiApurationIcms";
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT tsiApurationIcms;
    DESCRIPTION "Altera uma lista de Apuração ICMS";
    PATH 'api/tsi/v1/tsiApurationIcms/';
    TTALK "tsiApurationIcms";
    WSSYNTAX "/tsiApurationIcms";
    PRODUCES APPLICATION_JSON
 
    WSMETHOD DELETE tsiApurationIcms;
    DESCRIPTION "Deleta uma Apuração ICMS";
    PATH 'api/tsi/v1/tsiApurationIcms/';
    TTALK "tsiApurationIcms";
    WSSYNTAX "/tsiApurationIcms";
    PRODUCES APPLICATION_JSON 

    WSMETHOD DELETE idTsiApurationIcms;
    DESCRIPTION "Deleta uma Apuração ICMS";
    PATH 'api/tsi/v1/tsiApurationIcms/idTsiApurationIcms/';
    TTALK "tsiApurationIcms";
    WSSYNTAX "/tsiApurationIcms";
    PRODUCES APPLICATION_JSON 

END WSRESTFUL

/*----------------------------------------------------------------------
{Protheus.doc} GET tsiApurationIcms
Metodo responsável por consultar a chave TipoApur + DataDe + DataAte + IndApur 
no cadastro de Apuração ICMS ao TAF

@param sourceBranch
@param page
@param pageSize
@param dateOf
@param dateUp
@param typeApuration
@param indApuration
@param order
@type  WSMETHOD
@author Karen Honda
@since 22/07/2021
//----------------------------------------------------------------------*/
WSMETHOD GET tsiApurationIcms WSRECEIVE sourceBranch, typeApuration, dateOf, dateUp, indApuration WSREST tsiApurationIcms
Local oJsonResp     As Object
Local cDataDe       As Character
Local cDataAte      As Character
Local cTipoApur     As Character
Local cIndApur      As Character
Local nPage         As Numeric
Local nPageSize     As Numeric
Local xOrder        As Character
Local lOk           As Logical

cDataDe     := ''
cDataAte    := ''
cTipoApur   := ' '
cIndApur    := ' '
nPage       := 0
nPageSize   := 10
xOrder      := ''
lOk         := .F.

oJsonResp := JsonObject():New()

If VldExecute( self:sourceBranch, @oJsonResp )
    If valtype( self:order ) <> 'U' .and. !Empty(self:order)
        xOrder  := self:order
    EndIf    
    If valtype( self:page ) <> 'U' .and. self:page > 0
        nPage := self:page
        If valtype( self:pageSize ) <> 'U' .and. self:pageSize > 0
            nPageSize := self:pageSize
        EndIf
    EndIf
    If valtype( self:typeApuration ) <> 'U' .and. !Empty(self:typeApuration)
        cTipoApur := self:typeApuration
    EndIf
    If valtype( self:dateOf ) <> 'U' .and. !Empty(self:dateOf)
        cDataDe := self:dateOf    
        cDataDe := ValTsiData(cDataDe)
    EndIf
    If valtype( self:dateUp ) <> 'U' .and. !Empty(self:dateUp)
        cDataAte := self:dateUp
        cDataAte := ValTsiData(cDataAte)
    EndIf
    If valtype( self:indApuration ) <> 'U' .and. !Empty(self:indApuration)
        cIndApur := self:indApuration
    EndIf

    If valtype(self:dateOf) <> 'U' .AND. valtype(self:dateUp) <> 'U' 
        getWS039(@oJsonResp, cDataDe, cDataAte, cTipoApur, cIndApur,"", @lOK, nPage, nPageSize, xOrder)
        If !lOk
            SetErroJs( @oJsonResp, __cTagIcms, , __cUrl, '404' )
        EndIf
    Else
        SetErroJs( @oJsonResp, __cTagIcms, , __cUrl, '400',,,,.F. )    
    EndIf
EndIf

cJsonResp := FwJsonSerialize( oJsonResp ) //Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
cJsonResp := ''

Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} GET idTsiApurationIcms
Metodo responsável por consultar o Id no cadastro de Apuração ICMS ao TAF
@type  WSMETHOD
@author Karen Honda
@since 08/11/2020
//----------------------------------------------------------------------*/
WSMETHOD GET idTsiApurationIcms WSRECEIVE sourceBranch, id WSREST tsiApurationIcms

Local cJsonResp As Character
Local cId       As Character
Local oJsonResp As Object
Local lOk       As Logical

cId       := iif(valtype( self:id  ) <> 'U' .and. !empty(self:id ),self:id ," ")
cJsonResp := ''
lOk       := .F.

oJsonResp := JsonObject():New()
If VldExecute( self:sourceBranch, @oJsonResp )
    getWS039( @oJsonResp, , , , ,cId, @lOk)
    If !lOk
        SetErroJs( @oJsonResp, __cTagIcms, , __cUrl, '404' )
    EndIf
Else
    SetErroJs( @oJsonResp,,,__cUrl,'400' )        
EndIf

cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
cJsonResp := ''
    
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} POST tsiApurationIcms
Persisti operações de inclusão no cadastro de Apuração ICMS ao TAF
@type  WSMETHOD
@author Karen Honda
@since 10/11/2021
//----------------------------------------------------------------------*/
WSMETHOD POST tsiApurationIcms WSREST tsiApurationIcms
    WsTSIProc( self, .F., __oHashC2S )
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} PUT tsiApurationIcms
Persisti operações de alteração de cadastro Apuração ICMS ao TAF
@type  WSMETHOD
@author Karen Honda
@since 10/11/2021
//----------------------------------------------------------------------*/
WSMETHOD PUT tsiApurationIcms WSREST tsiApurationIcms
    WsTSIProc( self, .F., __oHashC2S )
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} DELETE tsiApurationIcms
Persisti operações de deleção de cadastro Apuração ICMS ao TAF
@type  WSMETHOD
@author Karen Honda
@since 10/08/2021
//----------------------------------------------------------------------*/
WSMETHOD DELETE tsiApurationIcms WSRECEIVE sourceBranch WSREST tsiApurationIcms

Local cJsonResp As Character
Local oJsonResp As Object
Local oBjJson   As Object
Local cBody     As Character
Local nGetNames As Numeric
Local nI        As Numeric
Local aObjJson  As Array
Local aRetJs    As Array
Local cSeek     As Character
Local cArea     As Character
Local cSource   As Character
Local cModel    As Character
Local nOrder    As Numeric
Local cKey      As Character
Local cErro     As Character

oJsonResp   := JsonObject():New() // retorno
oBjJson     := JsonObject():New()
cJsonResp   := ""
nGetNames   := 0
aObjJson    := {}
aRetJs      := {}
cSeek       := ""
cArea       := ""
cSource     := ""
cModel      := ""
nOrder      := 1
cKey        := ""


hmget( __oHashC2S, "m_o_d_e_l_"  , @cModel   )
hmget( __oHashC2S, "s_o_u_r_c_e_", @cSource  )
hmget( __oHashC2S, "a_r_e_a_"    , @cArea    )
hmget( __oHashC2S, "o_r_d_e_r_"  , @nOrder   ) 

If VldExecute( self:sourceBranch, @oJsonResp )
    cBody := self:GetContent( ) 
    oBjJson:fromJSON( cBody ) 

    if len(oBjJson:GetNames())>0
        for nGetNames := 1 to len(oBjJson:GetNames())
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if oBjJson:GetNames()[nGetNames] == __cTagIcms
                
                hmget( __oHashC2S, "k_e_y_"    , @cKey    )
                hmget( __oHashC2S, "s_e_e_k_"  , @cSeek    )
                DbSelectArea(cArea)
                DbSetOrder(nOrder)
                for nI := 1 to Len( aNames )
                    cErro := ""

                    aObjJson := aNames[nI]

                    If !Empty(aObjJson['dateInitialApuration']) .and. !Empty(aObjJson['dateFinalApuration']) .and. !Empty(aObjJson['typeApuration'])

                        aObjJson['dateInitialApuration'] := StoD(ValTsiData(aObjJson['dateInitialApuration']))
                        aObjJson['dateFinalApuration'] := StoD(ValTsiData(aObjJson['dateFinalApuration']))

                        if !&cSeek
                            cErro := RetErroTaf( "", aObjJson, "", 'NOTEXIST', &cKey )
                            // grava tabela de log e alimenta o aRetJs para retorno ao rest
                            AgrupaErro( &cKey, cErro, @aRetJs )
                        else
                            oModel := FWLoadModel( cSource )
                            oModel:SetOperation( 5 )
                            oModel:Activate()
                            FwFormCommit( oModel )     
                            aadd( aRetJs, { .T., &cKey } )
                            
                        EndIf
                    Else
                        If Empty(aObjJson['dateInitialApuration'])
                            cErro := RetErroTaf( "dateInitialApuration", , "C2S_DTINI", 'INVALID', "")
                            AgrupaErro( "INVALID_KEY", cErro, @aRetJs )
                        EndIf    
                        If Empty(aObjJson['dateFinalApuration'])
                            cErro := RetErroTaf( "dateFinalApuration", , "C2S_DTFIN", 'INVALID', "")
                            AgrupaErro( "INVALID_KEY", cErro, @aRetJs )
                        EndIf
                        If Empty(aObjJson['typeApuration'])
                            cErro := RetErroTaf( "typeApuration", , "C2S_TIPAPU", 'INVALID', "")
                            AgrupaErro( "INVALID_KEY", cErro, @aRetJs )
                        EndIf
                    EndIf    
                Next nI    
            endif
        next nGetNames
    else
        SetErroJs( @oJsonResp,,,, '400',,,,.T. )
    endif    
Else
    SetErroJs( @oJsonResp,,,, '400',,,,.T. )
EndIf

oJsonResp[__cTagIcms] := {}
SetErroJs(@oJsonResp, __cTagIcms, @aRetJs,,"403" )
cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )

Return .T.


/*----------------------------------------------------------------------
{Protheus.doc} DELETE idTsiApurationIcms
Persisti operações de deleção de cadastro Apuração ICMS ao TAF
@type  WSMETHOD
@author Karen Honda
@since 10/08/2021
//----------------------------------------------------------------------*/
WSMETHOD DELETE idTsiApurationIcms WSRECEIVE sourceBranch, id  WSREST tsiApurationIcms

Local cJsonResp As Character
Local oJsonResp As Object
Local oBjJson   As Object
Local cId       As Character
Local nGetNames As Numeric
Local aRetJs    As Array
Local cSeek     As Character
Local cArea     As Character
Local cSource   As Character

oJsonResp   := JsonObject():New() // retorno
oBjJson     := JsonObject():New()
cJsonResp   := ""
nGetNames   := 0
aRetJs      := {}
cSeek       := ""
cArea       := ""
cSource     := ""
cId         := iif(valtype( self:id  ) <> 'U' .and. !empty(self:id ),self:id ," ")

hmget( __oHashC2S, "s_o_u_r_c_e_", @cSource  )
hmget( __oHashC2S, "a_r_e_a_"    , @cArea    )


If VldExecute( self:sourceBranch, @oJsonResp )
    If !Empty(cID)
        DbSelectArea(cArea)
        C2S->( DbSetOrder(2) ) //C2S_FILIAL, C2S_ID
        If C2S->( DbSeek( xfilial('C2S') + cID ) )
            oModel := FWLoadModel( cSource )
            oModel:SetOperation( 5 )
            oModel:Activate()
            FwFormCommit( oModel )
            aadd( aRetJs, { .T., C2S->(C2S_TIPAPU + Dtos(C2S_DTINI) + Dtos(C2S_DTFIN) + C2S_INDAPU) } )
        Else
            SetErroJs( @oJsonResp,,,,'404' )
        EndIf
    EndIf    
Else
    SetErroJs( @oJsonResp,,,, '400',,,,.T.)
EndIf

oJsonResp[__cTagIcms] := {}
SetErroJs(@oJsonResp, __cTagIcms, @aRetJs,,"403" )
cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )

Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} getWS039()
Executa a query de consulta para o retorno ao método get da apuração ICMS, e monta o jason de resposta
@author Karen Honda
@since 05/08/2021
//----------------------------------------------------------------------*/
Function getWS039(oJsonResp, cDataDe, cDataAte, cTipoApur, cIndApur, cId, lOk, nPage, nPageSize, xOrder)
         
Local cJsonResp  as Character
Local cAlias     as Character

Local nPageAux   as Numeric
Local nlA        as Numeric
Local nlB        as Numeric

Local lHasNext   as Logical

Local aStructC2S as array
Local aStructC2T as array
Local aStructT02 as array

Local oModel     as Object
Local oMdlC2S    as Object
Local oMdlC2T    as Object
Local oMdlT02    as Object

Local oJsonC2T   as Object
Local oJsonT02   as Object
Local nTmC2T     as Numeric
Local nTmT02     as Numeric

Default cDataDe   := ''
Default cDataAte  := ''
Default cTipoApur := ''
Default cIndApur  := ''
Default cId       := ''
Default nPage     := 0
Default nPageSize := 10
Default xOrder    := ''

cJsonResp  := ''
cAlias     := ''
cTagJson   := ''
cOrder     := ''
nPageAux   := 0
nlA        := 0
nlB        := 0
lHasNext   := .F.

aStructC2S := {}
aStructC2T := {}
aStructT02 := {}

oJsonC2T  := JsonObject():New()
oJsonT02  := JsonObject():New()

oModel  := Nil
oMdlC2S := Nil
oMdlC2T := Nil
oMdlT02 := Nil

hmget( __oHashC2S, xOrder, @cOrder )
If !Empty(cOrder)
    cOrder := StrTran(StrTran(cOrder, "#DT#", ""),"#F3#", "")
EndIf

// executo a query do cabeçalho da nota fiscal
cAlias := GetApurICMS(cDataDe, cDataAte, cTipoApur, cIndApur, cId, nPage, nPageSize, xOrder)

//monto As estruturas para serem passadas a getJson
aStructC2S := C2S->(DBStruct())
aStructC2T := C2T->(DBStruct())
aStructT02 := T02->(DBStruct())

DbSelectArea("C2S")
C2S->(dbSetOrder(2)) //C2S_FILIAL, C2S_ID

//Carrega Modelo fora do laco
oModel := FwLoadModel( "TAFA063" )

while (cAlias)->(!eof())
    If C2S->(DbSeek( (cAlias)->C2S_FILIAL + (cAlias)->C2S_ID ))
        nPageAux++
        lOk := .T.
        oModel:SetOperation( 1 )
        oModel:Activate()

        oMdlC2S := oModel:GetModel("MODEL_C2S")

        If nPageAux <= nPageSize
            /*-----------------------------------
            |               CAPA                |
            ------------------------------------*/
            TsiGetJson( @oJsonResp, __oHashC2S, aStructC2S, @oMdlC2S, __cTagIcms, nPageAux,"apurationIcms|adjustmentApuration|accumulatedAdjust|" )
            /*-----------------------------------
            |               FILHO                |
            ------------------------------------*/
            oMdlC2T := oModel:GetModel("MODEL_C2T")
            nTmC2T  := oMdlC2T:Length()
            
            for nlA := 1 to nTmC2T
                oMdlC2T:GoLine( nlA )
                TsiGetJson( @oJsonC2T, __oHashC2T, aStructC2T, @oMdlC2T, 'adjustmentApuration', nlA, "apurationIcms|adjustmentApuration|accumulatedAdjust|" )

                /*-----------------------------------
                |           NETO    |
                ------------------------------------*/
                oMdlT02 := oModel:GetModel("MODEL_T02")
                nTmT02  := oMdlT02:Length()
                If nTmT02 > 0
                    oJsonC2T["adjustmentApuration"][nlA]['accumulatedAdjust'] := { }
                    for nlB := 1 to nTmT02
                        oMdlT02:GoLine( nlB )
                        TsiGetJson( @oJsonT02, __oHashT02, aStructT02, @oMdlT02, 'accumulatedAdjust',,"apurationIcms|adjustmentApuration|accumulatedAdjust|" )
                    next nlB
                    oJsonC2T["adjustmentApuration"][nlA]['accumulatedAdjust'] := oJsonT02['accumulatedAdjust']
                    oJsonT02['accumulatedAdjust'] := {}
                EndIf
            next nlA

        Else
            lHasNext := .T.
        EndIf
        oJsonResp[__cTagIcms][len(oJsonResp[__cTagIcms])]['adjustmentApuration']:=  oJsonC2T['adjustmentApuration']

        oModel:DeActivate()
    EndIf

    (cAlias)->(DbSkip())
EndDo

If cDataDe <> cDataAte; oJsonResp["hasnext"] := lHasNext ; EndIf

If Select(cAlias) > 0; (cAlias)->(dbCloseArea()); EndIf

Return oJsonResp


/*--------------------------------------------------------------------------------
{Protheus.doc} GetApurICMS()
(Responsável por executar a consulta ao cadastro da Apuração ICMS)
@author Karen Honda
@since 07/11/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
static Function GetApurICMS(cDataDe, cDataAte, cTipoApur, cIndApur, cIDApur, nPage, nPageSize, xOrder)
Local cAlias      := getNextAlias()
Local cQry          := ''
Default cIDApur := ''

If nPage == 0 
    nPage := 1
EndIf

If nPageSize == 0
    nPageSize := 10
EndIf

If Empty(cDataAte)
    cDataAte := DtoS(LastDay(StoD(cDataDe)))
EndIf

cQry  += " SELECT C2S_FILIAL,"
cQry  += " C2S_ID, C2S_TIPAPU, C2S_DTINI, C2S_DTFIN, C2S_INDAPU, C2S_DSCCOM, "
cQry  += " C2S_TOTDEB,C2S_AJUDEB,C2S_TAJUDB,C2S_ESTCRE,C2S_TOTCRE,C2S_AJUCRE,C2S_TAJUCR, "
cQry  += " C2S_ESTDEB,C2S_CREANT,C2S_SDOAPU,C2S_TOTDED,C2S_TOTREC,C2S_CRESEG,C2S_DEBESP, "
cQry  += " C2S_STAMP "
cQry  += " FROM "+RetSqlName("C2S")+" "
cQry  += " where C2S_FILIAL = '"+xFilial("C2S") +"'" 
If !empty(cIDApur)
    cQry  += " AND C2S_ID = '"+cIDApur+"'" 
Else
    cQry  += " AND C2S_DTINI >= '"+cDataDe+"'"
    cQry  += " AND C2S_DTFIN <= '"+cDataAte+"'"
    
    If !empty(cTipoApur)
        cQry  += " AND C2S_TIPAPU = '"+cTipoApur+"'"
    Endif
    
    If !empty(cIndApur)
        cQry  += " AND C2S_INDAPU = '"+cIndApur+"'"
    Endif
EndIf

cQry  += " AND D_E_L_E_T_ = ' ' "
If !empty(cOrder)
    cQry  += " ORDER BY "+cOrder 
Else
    cQry  += " ORDER BY 1 "
EndIf
cQry  += " OFFSET ( "+cValToChar(nPage-1)+" * "+cValToChar(nPageSize)+" ) ROWS "
cQry  += " FETCH NEXT "+cValToChar(nPageSize+1)+" ROWS ONLY "  

dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)

Return cAlias 

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC2S()
Cria Hash de "De|Para" do identIficador do Json para o campo de gravação no TAF
da apuração de ICMS - Layout T020 
@author Karen Honda
@since 13/07/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC2S()

Local oHash   := HMNew( )
Local cSeek   := ""
Local cKey    := ""
Local cTamTpApu  := cValToChar( GetSx3Cache( "C2S_TIPAPU", "X3_TAMANHO" ) )
Local cTamIndApu := cValToChar( GetSx3Cache( "C2S_INDAPU", "X3_TAMANHO" ) )

cKey := " padr(aObjJson['typeApuration']," + cTamTpApu+ ")+" //1 C2S_TIPAPU 
cKey += " ValTsiData(aObjJson['dateInitialApuration'])+"  //2 C2S_DTINI 
cKey += " ValTsiData(aObjJson['dateFinalApuration'])+" //3 C2S_DTFIN 
cKey += " padr(aObjJson['indicatorApuration']," + cTamIndApu+ ")" //4 C2S_INDAPU 

cSeek := " C2S->(DbSeek(xfilial('C2S')+ "
cSeek += " padr(aObjJson['typeApuration']," + cTamTpApu+ ")+" //1 C2S_TIPAPU 
cSeek += " ValTsiData(aObjJson['dateInitialApuration'])+"  //2 C2S_DTINI 
cSeek += " ValTsiData(aObjJson['dateFinalApuration'])+" //3 C2S_DTFIN 
cSeek += " padr(aObjJson['indicatorApuration']," + cTamIndApu+ ")))" //4 C2S_INDAPU 

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'  , 'MODEL_C2S')
HMSet(oHash, 's_o_u_r_c_e_', 'TAFA063'  )
HMSet(oHash, 'a_r_e_a_'    , 'C2S'      )
HMSet(oHash, 'o_r_d_e_r_'  , 1          ) //C2S_FILIAL, C2S_TIPAPU, C2S_DTINI, C2S_DTFIN, C2S_INDAPU, R_E_C_N_O_, D_E_L_E_T_
HMSet(oHash, 'k_e_y_'      , cKey       )
HMSet(oHash, 's_e_e_k_'    , cSeek      )
HMSet(oHash, 't_a_g_i_d_'  , 'apurationIcms' )
HMSet(oHash, 's_u_b_m_o_d_e_l_'  , {{'MODEL_C2T'/*model filho*/,'adjustmentApuration' /* tag filho*/, 'HashC2T()' /* hash filho*/ }} )
HMSet(oHash, 's_u_b_m_o_d_e_l_2' , {{'adjustmentApuration'/* tag filho*/,'MODEL_T02'/*model neto*/,'accumulatedAdjust'/*tag neto*/, 'HashT02()' /*hash neto*/}} )

// Propriedades e Campos
SetHashKey(oHash, 'apurationId'             ,'C2S_ID' )
SetHashKey(oHash, 'typeApuration'           ,'C2S_TIPAPU')
SetHashKey(oHash, 'dateInitialApuration'    ,'C2S_DTINI#DT#')
SetHashKey(oHash, 'dateFinalApuration'      ,'C2S_DTFIN#DT#')
SetHashKey(oHash, 'indicatorApuration'      ,'C2S_INDAPU')
SetHashKey(oHash, 'descriptionComplementary','C2S_DSCCOM')
SetHashKey(oHash, 'valueTotalDebts'         ,'C2S_TOTDEB')
SetHashKey(oHash, 'valueAdjustmentDebts'    ,'C2S_AJUDEB')
SetHashKey(oHash, 'valueTotalAdjustmentDebts','C2S_TAJUDB')
SetHashKey(oHash, 'valueReversalCredit'     ,'C2S_ESTCRE')
SetHashKey(oHash, 'valueTotalCredits'       ,'C2S_TOTCRE')
SetHashKey(oHash, 'valueAdjustmentCredits'  ,'C2S_AJUCRE')
SetHashKey(oHash, 'valueTotalAdjustmentCredits','C2S_TAJUCR')
SetHashKey(oHash, 'valueReversalDebts'      ,'C2S_ESTDEB')
SetHashKey(oHash, 'balanceCreditPeridPrevios','C2S_CREANT')
SetHashKey(oHash, 'balanceDebtVerified'     ,'C2S_SDOAPU')
SetHashKey(oHash, 'totalDeductions'         ,'C2S_TOTDED')
SetHashKey(oHash, 'totalToRecall'           ,'C2S_TOTREC')
SetHashKey(oHash, 'balanceCreditNextPeriod' ,'C2S_CRESEG')
SetHashKey(oHash, 'debtsSpecial'            ,'C2S_DEBESP')
SetHashKey(oHash, 'stamp'                   ,'C2S_STAMP')
Return oHash

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC2T()
Cria Hash de "De|Para" do identIficador do Json para o campo de gravação no TAF
da apuração de ICMS - Layout T020AA 
@author Karen Honda
@since 13/07/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC2T()

Local oHash   := HMNew( )

// Propriedades e Campos
SetHashKey(oHash, 'seqReg'                  ,'C2T_SEQREG')
SetHashKey(oHash, 'adjustmentCode'          ,'C2T_CODAJU#F3#') // 02-COD_AJ_APUR
SetHashKey(oHash, 'valueAdjustment'         ,'C2T_VLRAJU') //4-VL_AJ_APUR
SetHashKey(oHash, 'complementaryAdjustment' ,'C2T_AJUCOM') //8-DESCR_COMPL_AJ1
SetHashKey(oHash, 'subItemCode'             ,'C2T_IDSUBI#F3#') // 5-COD_SUBITEM
SetHashKey(oHash, 'reasonCode'              ,'C2T_IDTMOT#F3#') //6-COD_MOT
SetHashKey(oHash, 'complemNote1'            ,'C2T_OBS1')
SetHashKey(oHash, 'complemNote2'            ,'C2T_OBS2')
SetHashKey(oHash, 'complemNote3'            ,'C2T_OBS3')
SetHashKey(oHash, 'codeAdjInvoice'          ,'C2T_CODAJ1#F3#') //7-COD_AJ_APUR_NF

//#F3# usado na gravação ou alteração dos tributos dos itens
HMSet(oHash, '#F3#C2T_CODAJU', "GetTafId( 'C1A', aObjJson['adjustmentCode'], 3 )" ) 
HMSet(oHash, '#F3#C2T_IDSUBI', "GetTafId( 'CHY', aObjJson['subItemCode'], 2 )" )                  
HMSet(oHash, '#F3#C2T_IDTMOT', "GetTafId( 'T0V', aObjJson['reasonCode']+XFUNCh2ID(  aObjJson['subItemCode'], 'CHY', 2 ), 2 )" )                  
HMSet(oHash, '#F3#C2T_CODAJ1', "GetTafId( 'C0J', aObjJson['codeAdjInvoice'], 4 )" )                  

//Posicione ( utilizado no get )
HMSet(oHash, 'C2T_CODAJU#POSIC#', "Posicione('C1A', 4, xFilial('C1A') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1A_CODIGO'     )") 
HMSet(oHash, 'C2T_IDSUBI#POSIC#', "Posicione('CHY', 1, xFilial('CHY') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'CHY_CODIGO'     )") 
HMSet(oHash, 'C2T_IDTMOT#POSIC#', "Posicione('T0V', 1, xFilial('T0V') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'T0V_CODIGO'     )") 
HMSet(oHash, 'C2T_CODAJ1#POSIC#', "Posicione('C0J', 3, xFilial('C1A') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C0J_CODIGO'     )") 


Return oHash

/*--------------------------------------------------------------------------------
{Protheus.doc} HashT02()
Cria Hash de "De|Para" do identIficador do Json para o campo de gravação no TAF
da apuração de ICMS - Layout T020AG 
@author Karen Honda
@since 13/07/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashT02()

Local oHash   := HMNew( )

// Propriedades e Campos
SetHashKey(oHash, 'seqReg'              ,'T02_SEQREG')
SetHashKey(oHash, 'valueCredIcms'       ,'T02_VALOR') // 2-COD_AUTORIZ
SetHashKey(oHash, 'authorizationCode'   ,'T02_CODIGO') //3-VALOR

Return oHash


/*----------------------------------------------------------------------
{Protheus.doc} VldC2SChv
Valida as Tags que formam a chave da Apuração ICMS
@author Karen Honda
@since 15/07/2021
@return cWarning, caracter, caso falte alguma chave, retorna erro
//----------------------------------------------------------------------*/
Function VldChvC2S(aObjJson)

Local aFld := {}
Local nlA  := 0
Local nCnt := 0
Local cWarning := ''
If Valtype(aObjJson) <> "U"
    aAdd(aFld,'aObjJson["typeApuration"]')
    aAdd(aFld,'aObjJson["dateInitialApuration"]')
    aAdd(aFld,'aObjJson["dateFinalApuration"]')
    aAdd(aFld,'aObjJson["indicatorApuration"]')

    for nlA := 1 to Len(aFld)
        If ValType( &(aFld[nlA]) ) == "U"
            If (++nCnt) > 1
                cWarning += ", "
            EndIf
            cWarning += StrTran( StrTran( StrTran( aFld[nlA] , "aObjJson[" ) , "]" ) , '\"')
        EndIf
    Next nlA
EndIf
Return cWarning
