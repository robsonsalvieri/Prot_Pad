#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static __cTagIcST := 'apurationIcmsST'
Static __cUrl     := 'https://api.totvs.com.br/'
Static __oHashC3J := HashC3J()
Static __oHashC3K := HashC3K()

/*--------------------------------------------------------------------------/
{Protheus.doc} WSTAF040
WS para persistencia do cadastro de apurações ICMS ST no TAF

@author Wesley Matos / Renan Gomes
@since 12/08/2021
@version 1.0
//----------------------------------------------------------------------*/
WSRESTFUL tsiApurationIcmsSt DESCRIPTION "TAF Service Integration - Apuração ICMS ST"

    WSDATA sourceBranch             As string
    WSDATA page			            As integer optional
    WSDATA pageSize 	            As integer optional
    WSDATA order                    As string  optional
    WSDATA dateOf                   As string  optional
    WSDATA dateUp                   As string  optional
    WSDATA codUF                    As string  optional
    WSDATA indicatorApuration       As string  optional
    WSDATA id                       As string  optional

	WSMETHOD GET tsiApurationIcmsSt;
    DESCRIPTION "Retorna uma lista de Apurações ICMS ST";
    PATH 'api/tsi/v1/tsiApurationIcmsSt/';
    TTALK "tsiApurationIcmsSt";
    WSSYNTAX "/tsiApurationIcmsSt";
    PRODUCES APPLICATION_JSON
 
    WSMETHOD GET idTsiApurationIcmsSt;
    DESCRIPTION "Retorna um Apurações de ICMS ST pelo ID";
    PATH 'api/tsi/v1/tsiApurationIcmsSt/idTsiApurationIcmsSt/';
    TTALK "tsiApurationIcmsST";
    WSSYNTAX "/tsiApurationIcmsSt";
    PRODUCES APPLICATION_JSON

    WSMETHOD POST tsiApurationIcmsSt; 
    DESCRIPTION "Inclui/altera uma lista de Apuração ICMS ST";
    PATH 'api/tsi/v1/tsiApurationIcmsSt/';
    TTALK "tsiApurationIcmsSt";
    WSSYNTAX "/tsiApurationIcmsSt";
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT tsiApurationIcmsSt;
    DESCRIPTION "Altera uma lista de Apuração ICMS ST";
    PATH 'api/tsi/v1/tsiApurationIcmsSt/';
    TTALK "tsiApurationIcmsSt";
    WSSYNTAX "/tsiApurationIcmsSt";
    PRODUCES APPLICATION_JSON
 
    WSMETHOD DELETE tsiApurationIcmsSt;
    DESCRIPTION "Deleta uma Apuração ICMS ST";
    PATH 'api/tsi/v1/tsiApurationIcmsSt/';
    TTALK "tsiApurationIcmsSt";
    WSSYNTAX "/tsiApurationIcmsSt";
    PRODUCES APPLICATION_JSON 

    WSMETHOD DELETE idTsiApurationIcmsSt;
    DESCRIPTION "Deleta uma Apuração ICMS ST";
    PATH 'api/tsi/v1/tsiApurationIcmsSt/idTsiApurationIcmsSt/';
    TTALK "tsiApurationIcmsSt";
    WSSYNTAX "/tsiApurationIcmsSt";
    PRODUCES APPLICATION_JSON 

END WSRESTFUL

/*----------------------------------------------------------------------
{Protheus.doc} GET tsiApurationIcmsSt
Metodo responsável por consultar a chave TipoApur + DataDe + DataAte + IndApur 
no cadastro de Apuração ICMS ST ao TAF

@param sourceBranch
@param page
@param pageSize
@param dateOf
@param dateUp
@param codUF
@param indicatorApuration
@param order
@type  WSMETHOD
@author Wesley Matos / Renan Gomes
@since 12/08/2021
//----------------------------------------------------------------------*/
WSMETHOD GET tsiApurationIcmsSt WSRECEIVE sourceBranch, codUF, dateOf, dateUp, indicatorApuration WSREST tsiApurationIcmsSt
Local oJsonResp     As Object
Local cDataDe       As Character
Local cDataAte      As Character
Local cCodUF     As Character
Local cIndApur      As Character
Local nPage         As Numeric
Local nPageSize     As Numeric
Local xOrder        As Character
Local lOk           As Logical

cDataDe     := ''
cDataAte    := ''
cCodUF      := ' '
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
    If valtype( self:dateOf ) <> 'U' .and. !Empty(self:dateOf)
        cDataDe := self:dateOf
    EndIf
    If valtype( self:dateUp ) <> 'U' .and. !Empty(self:dateUp)
        cDataAte := self:dateUp
    EndIf
    If valtype( self:codUF ) <> 'U' .and. !Empty(self:codUF)
        cCodUF := GetTafId( 'C09', self:codUF, 1 )
    EndIf
    If valtype( self:indicatorApuration ) <> 'U' .and. !Empty(self:indicatorApuration)
        cIndApur := self:indicatorApuration
    EndIf

    If valtype(self:dateOf) <> 'U' .AND. valtype(self:dateUp) <> 'U' 
        getWS040(@oJsonResp, cDataDe, cDataAte, cCodUF, cIndApur,"", @lOK, nPage, nPageSize, xOrder)
        
        If !lOk
            SetErroJs( @oJsonResp, __cTagIcST, , __cUrl, '404' )
        EndIf

    Else
        SetErroJs( @oJsonResp, __cTagIcST, , __cUrl, '400',,,,.F. )
    EndIf

EndIf


cJsonResp := FwJsonSerialize( oJsonResp ) //Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
cJsonResp := ''

Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} GET idTsiApurationIcmsSt
Metodo responsável por consultar o Id no cadastro de Apuração ICMS ST ao TAF
@type  WSMETHOD
@author Wesley Matos / Renan Gomes
@since 12/08/2021
//----------------------------------------------------------------------*/
WSMETHOD GET idTsiApurationIcmsSt WSRECEIVE sourceBranch, id WSREST tsiApurationIcmsSt

Local cJsonResp As Character
Local cId       As Character
Local oJsonResp As Object
Local lOk       As Logical

cId       := iif(valtype( self:id  ) <> 'U' .and. !empty(self:id ),self:id ," ")
cJsonResp := ''
lOk       := .F.

oJsonResp := JsonObject():New()
If VldExecute( self:sourceBranch, @oJsonResp )
    getWS040( @oJsonResp, , , , ,cId, @lOk)
    If !lOk
        SetErroJs( @oJsonResp, __cTagIcST, , __cUrl, '404' )
    EndIf
EndIf

cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
cJsonResp := ''
    
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} POST tsiApurationIcmsSt
Persisti operações de inclusão no cadastro de Apuração ICMS ST ao TAF
@type  WSMETHOD
@author Wesley Matos / Renan Gomes
@since 12/08/2021
//----------------------------------------------------------------------*/
WSMETHOD POST tsiApurationIcmsSt WSREST tsiApurationIcmsSt
    WsTSIProc( self, .F., __oHashC3J )
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} PUT tsiApurationIcmsSt
Persisti operações de alteração de cadastro Apuração ICMS ST ao TAF
@type  WSMETHOD
@author Wesley Matos / Renan Gomes
@since 12/08/2021
//----------------------------------------------------------------------*/
WSMETHOD PUT tsiApurationIcms WSREST tsiApurationIcmsSt
    WsTSIProc( self, .F., __oHashC3J )
Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} DELETE tsiApurationIcms
Persisti operações de deleção de cadastro Apuração ICMS ST ao TAF
@type  WSMETHOD
@author Wesley Matos / Renan Gomes
@since 12/08/2021
//----------------------------------------------------------------------*/
WSMETHOD DELETE tsiApurationIcmsSt WSRECEIVE sourceBranch WSREST tsiApurationIcmsSt

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


hmget( __oHashC3J, "m_o_d_e_l_"  , @cModel   )
hmget( __oHashC3J, "s_o_u_r_c_e_", @cSource  )
hmget( __oHashC3J, "a_r_e_a_"    , @cArea    )
hmget( __oHashC3J, "o_r_d_e_r_"  , @nOrder   ) 

If VldExecute( self:sourceBranch, @oJsonResp )
    cBody := self:GetContent( ) 
    oBjJson:fromJSON( cBody ) 

    if len(oBjJson:GetNames())>0
        for nGetNames := 1 to len(oBjJson:GetNames())
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if oBjJson:GetNames()[nGetNames] == __cTagIcST
                
                hmget( __oHashC3J, "k_e_y_"    , @cKey    )
                hmget( __oHashC3J, "s_e_e_k_"  , @cSeek    )
                DbSelectArea(cArea)
                DbSetOrder(nOrder)
                for nI := 1 to Len( aNames )
                    cErro := ""

                    aObjJson := aNames[nI]
                   
                    If !Empty(aObjJson['dateInitialApuration']) .and. !Empty(aObjJson['dateFinalApuration'])

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
                            cErro := RetErroTaf( "dateInitialApuration", , "C3J_DTINI", 'INVALID', "")
                            AgrupaErro( "INVALID_KEY", cErro, @aRetJs )
                        EndIf    
                        If Empty(aObjJson['dateFinalApuration'])
                            cErro := RetErroTaf( "dateFinalApuration", , "C3J_DTFIN", 'INVALID', "")
                            AgrupaErro( "INVALID_KEY", cErro, @aRetJs )
                        EndIf
                        If Empty(aObjJson['indicatorApuration'])
                            cErro := RetErroTaf( "indicatorApuration", , "C3J_INDMOV", 'INVALID', "")
                            AgrupaErro( "INVALID_KEY", cErro, @aRetJs )
                        EndIf
                        If Empty(aObjJson['codUF'])
                            cErro := RetErroTaf( "codUF", , "C3J_UF", 'INVALID', "")
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
    SetErroJs( @oJsonResp,,,__cUrl, '400',,,,.T. )
EndIf

oJsonResp[__cTagIcST] := {}
SetErroJs(@oJsonResp, __cTagIcST, @aRetJs,,"403" )
cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )

Return .T.


/*----------------------------------------------------------------------
{Protheus.doc} DELETE idTsiApurationIcmsSt
Persisti operações de deleção de cadastro Apuração ICMS ST ao TAF
@type  WSMETHOD
@author Wesley Matos / Renan Gomes
@since 12/08/2021
//----------------------------------------------------------------------*/
WSMETHOD DELETE idTsiApurationIcmsSt WSRECEIVE sourceBranch, id  WSREST tsiApurationIcmsSt

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

hmget( __oHashC3J, "s_o_u_r_c_e_", @cSource  )
hmget( __oHashC3J, "a_r_e_a_"    , @cArea    )


If VldExecute( self:sourceBranch, @oJsonResp )
    If !Empty(cID)
        DbSelectArea(cArea)
        C3J->( DbSetOrder(2) ) //C3J_FILIAL, C3J_ID
        If C3J->( DbSeek( xfilial('C3J') + cID ) )
            oModel := FWLoadModel( cSource )
            oModel:SetOperation( 5 )
            oModel:Activate()
            FwFormCommit( oModel )
            aadd( aRetJs, { .T., C3J->(C3J_UF + Dtos(C3J_DTINI) + Dtos(C3J_DTFIN) + C3J_INDMOV) } )
        Else
            SetErroJs( @oJsonResp,,,,'404' )
        EndIf
    EndIf    
Else
    SetErroJs( @oJsonResp,,,__cUrl, '400',,,,.T. )
EndIf

oJsonResp[__cTagIcST] := {}
SetErroJs(@oJsonResp, __cTagIcST, @aRetJs,,"403" )
cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )

Return .T.

/*----------------------------------------------------------------------
{Protheus.doc} getWS040()
Executa a query de consulta para o retorno ao método get da apuração ICMS ST, e monta o jason de resposta
@author Wesley Matos / Renan Gomes
@since 12/08/2021
//----------------------------------------------------------------------*/
Function getWS040(oJsonResp, cDataDe, cDataAte, cCodUF, cIndApur, cId, lOk, nPage, nPageSize, xOrder)
         
Local cJsonResp  as Character
Local cAlias     as Character

Local nPageAux   as Numeric
Local nlA        as Numeric
Local nlB        as Numeric

Local lHasNext   as Logical

Local aStructC3J as array
Local aStructC3K as array

Local oModel     as Object
Local oMdlC3J    as Object
Local oMdlC3K    as Object

Local oJsonC3K   as Object
Local nTmC3K     as Numeric


Default cDataDe   := ''
Default cDataAte  := ''
Default cCodUF    := ''
Default cIndApur  := ''
Default cId       := ''
Default nPage     := 0
Default nPageSize := 10
Default xOrder    := ''

cJsonResp         := ''
cAlias            := ''
cTagJson          := ''
cOrder            := ''
nPageAux          := 0
nlA               := 0
nlB               := 0
lHasNext          := .F.

aStructC3J := {}
aStructC3K := {}

oJsonC3K  := JsonObject():New()

oModel  := Nil
oMdlC3J := Nil
oMdlC3K := Nil

hmget( __oHashC3J, xOrder, @cOrder )
If !Empty(cOrder)
    cOrder := StrTran(StrTran(cOrder, "#DT#", ""),"#F3#", "")
EndIf
If !Empty(cDataDe)
    cDataDe := ValTsiData(cDataDe)
EndIf    
If !Empty(cDataAte)
    cDataAte := ValTsiData(cDataAte)
EndIf    

// executo a query do cabeçalho da nota fiscal
cAlias := GetApuICSt(cDataDe, cDataAte, cCodUF, cIndApur, cId, nPage, nPageSize, xOrder)

//monto As estruturas para serem passadas a getJson
aStructC3J := C3J->(DBStruct())
aStructC3K := C3K->(DBStruct())

DbSelectArea("C3J")
C3J->(dbSetOrder(2)) //C3J_FILIAL, C3J_ID

//Carrega Modelo fora do laco
oModel := FwLoadModel( "TAFA188" )

while (cAlias)->(!eof())
    If C3J->(DbSeek( (cAlias)->C3J_FILIAL + (cAlias)->C3J_ID ))
        nPageAux++
        lOk := .T.
        oModel:SetOperation( 1 )
        oModel:Activate()

        oMdlC3J := oModel:GetModel("MODEL_C3J")

        If nPageAux <= nPageSize
            /*-----------------------------------
            |               CAPA                |
            ------------------------------------*/
            TsiGetJson( @oJsonResp, __oHashC3J, aStructC3J, @oMdlC3J,__cTagIcST, nPageAux,"apurationIcmsST|adjustmentApurationST|" )
            /*-----------------------------------
            |               FILHO                |
            ------------------------------------*/
            oMdlC3K := oModel:GetModel("MODEL_C3K")
            nTmC3K  := oMdlC3K:Length()
            for nlA := 1 to nTmC3K
                oMdlC3K:GoLine( nlA )
                TsiGetJson( @oJsonC3K, __oHashC3K, aStructC3K, @oMdlC3K, 'adjustmentApurationST', nlA, "apurationIcmsST|adjustmentApurationST|" )

            next nlA

        Else
            lHasNext := .T.
        EndIf

        oJsonResp[__cTagIcST][len(oJsonResp[__cTagIcST])]['adjustmentApurationST']:= oJsonC3K['adjustmentApurationST']
        
        oModel:DeActivate()
    EndIf

    (cAlias)->(DbSkip())
EndDo

If cDataDe <> cDataAte; oJsonResp["hasnext"] := lHasNext ; EndIf

If Select(cAlias) > 0; (cAlias)->(dbCloseArea()); EndIf

Return oJsonResp


/*--------------------------------------------------------------------------------
{Protheus.doc} GetApuICSt()
(Responsável por executar a consulta ao cadastro da Apuração ICMS ST)
@author Wesley Matos / Renan Gomes
@since 12/08/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
static Function GetApuICSt(cDataDe, cDataAte, cCodUF, cIndApur, cIDApur, nPage, nPageSize, xOrder)
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

cQry  += " SELECT C3J_FILIAL,"
cQry  += " C3J_ID, C3J_INDMOV, C3J_UF, C3J_DTINI, C3J_DTFIN, C3J_CREANT, C3J_VLRDEV, C3J_VLRRES, "
cQry  += " C3J_OUTCRD,C3J_AJUCRD,C3J_VLRRET,C3J_OUTDEB,C3J_AJUDEB,C3J_SDODEV,C3J_TOTDED, "
cQry  += " C3J_VLRREC,C3J_CRDTRA,C3J_DEBESP,C3J_STAMP "
cQry  += " FROM "+RetSqlName("C3J")+" "
cQry  += " where C3J_FILIAL = '"+xFilial("C3J") +"'" 
If !empty(cIDApur)
    cQry  += " AND C3J_ID = '"+cIDApur+"'" 
Else
    cQry  += " AND C3J_DTINI >= '"+cDataDe+"'"
    cQry  += " AND C3J_DTFIN <= '"+cDataAte+"'"
    
    If !empty(cIndApur)
        cQry  += " AND C3J_INDMOV = '"+cIndApur+"'"
    Endif
    
    If !empty(cCodUF)
        cQry  += " AND C3J_UF =     '"+cCodUF+"'"
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
{Protheus.doc} HashC3J()
Cria Hash de "De|Para" do identIficador do Json para o campo de gravação no TAF
da apuração de ICMS ST - Layout T021 
@author Renan Gomes
@since 13/07/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC3J()

Local oHash      := HMNew( )
Local cSeek      := ""
Local cKey       := ""
Local cTamIndMov := cValToChar( GetSx3Cache( "C3J_INDMOV", "X3_TAMANHO" ) )
Local cTamCodUF  := cValToChar( GetSx3Cache( "C3J_UF", "X3_TAMANHO" ) )

cKey := " padr(XFUNCh2ID( aObjJson['codUF'], 'C09' , 1 , ,.T.), "+cTamCodUF+")+" //1 C3J_UF 
cKey += " ValTsiData(aObjJson['dateInitialApuration'])+"  //2 C3J_DTINI 
cKey += " ValTsiData(aObjJson['dateFinalApuration'])+" //3 C3J_DTFIN 
cKey += " padr(aObjJson['indicatorApuration']," + cTamIndMov+ ")" //4 C3J_INDMOV  

cSeek := " C3J->(DbSeek(xfilial('C3J')+ "
cSeek += " padr(XFUNCh2ID( aObjJson['codUF'], 'C09' , 1 , ,.T.), "+cTamCodUF+")+" //1 C3J_UF 
cSeek += " ValTsiData(aObjJson['dateInitialApuration'])+"  //2 C3J_DTINI 
cSeek += " ValTsiData(aObjJson['dateFinalApuration'])+" //3 C3J_DTFIN 
cSeek += " padr(aObjJson['indicatorApuration']," + cTamIndMov+ ")))" //4 C3J_INDAPU 

//#F3# usado na gravação ou alteração
HMSet(oHash, '#F3#C3J_UF'      , "GetTafId( 'C09', aObjJson['codUF'], 1 )" ) 
HMSet(oHash, '#DT#C3J_DTINI'   , "ValTsiData(aObjJson['dateInitialApuration'])" ) 
HMSet(oHash, '#DT#C3J_DTFIN'   , "ValTsiData(aObjJson['dateFinalApuration'])" ) 

//Posicione ( utilizado no get )
HMSet(oHash, 'C3J_UF#POSIC#', "Posicione('C09', 3, xFilial('C09') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C09_UF'     )")

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'  , 'MODEL_C3J')
HMSet(oHash, 's_o_u_r_c_e_', 'TAFA188'  )
HMSet(oHash, 'a_r_e_a_'    , 'C3J'      )
HMSet(oHash, 'o_r_d_e_r_'  , 1          ) //C3J_FILIAL+C3J_UF+DTOS(C3J_DTINI)+DTOS(C3J_DTFIN)+C3J_INDMOV
HMSet(oHash, 'k_e_y_'      , cKey       )
HMSet(oHash, 's_e_e_k_'    , cSeek      )
HMSet(oHash, 't_a_g_i_d_'  , 'apurationIcmsST' )
HMSet(oHash, 's_u_b_m_o_d_e_l_'  , {{'MODEL_C3K'/*model filho*/,'adjustmentApurationST' /* tag filho*/, 'HashC3K()' /* hash filho*/ }} )

// Propriedades e Campos
SetHashKey(oHash, 'apurationId'                 ,'C3J_ID' )
SetHashKey(oHash, 'indicatorApuration'          ,'C3J_INDMOV')
SetHashKey(oHash, 'codUF'                       ,'C3J_UF#F3#')
SetHashKey(oHash, 'dateInitialApuration'        ,'C3J_DTINI#DT#')
SetHashKey(oHash, 'dateFinalApuration'          ,'C3J_DTFIN#DT#')
SetHashKey(oHash, 'balanceCreditPeridPrevios'   ,'C3J_CREANT')
SetHashKey(oHash, 'valueDevolution'             ,'C3J_VLRDEV')
SetHashKey(oHash, 'valueTotalReimbursement'     ,'C3J_VLRRES')
SetHashKey(oHash, 'valueOthersCredits'          ,'C3J_OUTCRD')
SetHashKey(oHash, 'valueAdjustmentCredits'      ,'C3J_AJUCRD')
SetHashKey(oHash, 'valueIcmsRet'                ,'C3J_VLRRET')
SetHashKey(oHash, 'valueOthersDebits'           ,'C3J_OUTDEB')
SetHashKey(oHash, 'valueAdjustmentDebits'       ,'C3J_AJUDEB')
SetHashKey(oHash, 'balanceDebitBeforeDeduction' ,'C3J_SDODEV')
SetHashKey(oHash, 'valueTotalDeductions'        ,'C3J_TOTDED')
SetHashKey(oHash, 'valueIcmsToRecall'           ,'C3J_VLRREC')
SetHashKey(oHash, 'creditCarried'               ,'C3J_CRDTRA')
SetHashKey(oHash, 'specialDebits'               ,'C3J_DEBESP')
SetHashKey(oHash, 'stamp'                       ,'C3J_STAMP')

Return oHash

/*--------------------------------------------------------------------------------
{Protheus.doc} HashC3K()
Cria Hash de "De|Para" do identIficador do Json para o campo de gravação no TAF
da apuração de ICMS ST - Layout T021AA 
@author Renan Gomes
@since 13/07/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashC3K()

Local oHash   := HMNew( )

// Propriedades e Campos
SetHashKey(oHash, 'adjustmentCode'          ,'C3K_CODAJU#F3#')  // 02-COD_AJ_APUR
SetHashKey(oHash, 'complementaryAdjustment' ,'C3K_AJUCOM')      // 03-DESCR_COMPL_AJ1
SetHashKey(oHash, 'valueAdjustment'         ,'C3K_VLRAJU')      // 04-VL_AJ_APUR
SetHashKey(oHash, 'subItemCode'             ,'C3K_IDSUBI#F3#')  // 05-COD_SUBITEM
SetHashKey(oHash, 'reasonCode'              ,'C3K_IDTMOT#F3#')  // 06-COD_MOT

//#F3# usado na gravação ou alteração dos tributos dos itens
HMSet(oHash, '#F3#C3K_CODAJU', "GetTafId( 'C1A', aObjJson['adjustmentCode'], 3 )" ) 
HMSet(oHash, '#F3#C3K_IDSUBI', "GetTafId( 'CHY', aObjJson['subItemCode'], 2 )" )                  
HMSet(oHash, '#F3#C3K_IDTMOT', "GetTafId( 'T0V', aObjJson['reasonCode']+XFUNCh2ID(  aObjJson['subItemCode'], 'CHY', 2 ), 2 )" )                  

//Posicione ( utilizado no get )
HMSet(oHash, 'C3K_CODAJU#POSIC#', "Posicione('C1A', 4, xFilial('C1A') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'C1A_CODIGO'     )") 
HMSet(oHash, 'C3K_IDSUBI#POSIC#', "Posicione('CHY', 1, xFilial('CHY') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'CHY_CODIGO'     )") 
HMSet(oHash, 'C3K_IDTMOT#POSIC#', "Posicione('T0V', 1, xFilial('T0V') + &('oMdl:GetValue(aStruct[nStruct][1])'), 'T0V_CODIGO'     )") 
Return oHash

/*----------------------------------------------------------------------
{Protheus.doc} VldC3JChv
Valida as Tags que formam a chave da Apuração ICMS
@author Renan Gomes
@since 15/07/2021
@return cWarning, caracter, caso falte alguma chave, retorna erro
//----------------------------------------------------------------------*/
Function VldChvC3J(aObjJson)

Local aFld := {}
Local nlA  := 0
Local nCnt := 0
Local cWarning := ''
If Valtype(aObjJson) <> "U"
    aAdd(aFld,'aObjJson["codUF"]')
    aAdd(aFld,'aObjJson["dateInitialApuration"]')
    aAdd(aFld,'aObjJson["dateFinalApuration"]')
    aAdd(aFld,'aObjJson["indicatorApuration"]')

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

