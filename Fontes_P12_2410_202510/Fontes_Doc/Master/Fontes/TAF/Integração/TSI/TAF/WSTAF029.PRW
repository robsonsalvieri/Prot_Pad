#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} WSTAF025
WS para operações GET/POST/PUT e DELETE do cadastro de centro de custo do TAF
@author Henrique Fabiano Pateno Pereira    
@since 15/07/2020
@version 1.0
*/

WSRESTFUL tsiCostCenter DESCRIPTION "TAF Service Integration - Cadastro de Centro de Custo"  
	
    WSDATA sourceBranch  as string
    WSDATA page			 as integer	optional 
	WSDATA pageSize 	 as integer	optional 
    WSDATA order         as string  optional
    WSDATA costCenterOf  as string  optional
    WSDATA costCenterUp  as string  optional
    WSDATA id            as string  optional 
  
	WSMETHOD GET tsiCostCenter;
    DESCRIPTION "Retorna uma lista de Centro de Custo";
    PATH 'api/tsi/v1/tsiCostCenter/';
    TTALK "v1";
    WSSYNTAX "/tsiCostCenter";
    PRODUCES APPLICATION_JSON 

    WSMETHOD GET idTsiCostCenter;
    DESCRIPTION "Retorna uma Centro de Custo";
    PATH 'api/tsi/v1/tsiCostCenter/{id}';
    TTALK "v1";
    WSSYNTAX "/tsiCostCenter";
    PRODUCES APPLICATION_JSON  

    WSMETHOD POST tsiCostCenter; 
    DESCRIPTION "Inclui/altera uma lista de Centro de Custo";
    PATH 'api/tsi/v1/tsiCostCenter/';
    TTALK "v1";
    WSSYNTAX "/tsiCostCenter";
    PRODUCES APPLICATION_JSON 
 
    WSMETHOD PUT tsiCostCenter; 
    DESCRIPTION "Altera um centro de custo";
    PATH 'api/tsi/v1/tsiCostCenter/{id}';
    TTALK "v1";
    WSSYNTAX "/tsiCostCenter";
    PRODUCES APPLICATION_JSON 

    WSMETHOD DELETE tsiCostCenter;
    DESCRIPTION "Delete uma lista de centro de custo";
    PATH 'api/tsi/v1/tsiCostCenter/';
    TTALK "v1";
    WSSYNTAX "/tsiCostCenter";
    PRODUCES APPLICATION_JSON 

END WSRESTFUL 

/*
Metodo responsável por consultar o cadastro de produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 
WSMETHOD GET tsiCostCenter WSREST TSIcostCenter

Local cJsonResp     as character
Local cCCDe         as character
Local cCCAte        as character
Local cAlias        as character
Local cOrder        as character
Local xOrder        as character
Local cUrl          as character
Local cField        as character
Local nPage         as numeric 
Local nPageSize     as numeric 
Local nStruct       as numeric 
Local nPos          as numeric
Local nPageAux      as numeric
Local lHasNext      as logical
Local aStruct       as array 
Local oHash         as object
Local oJsonResp     as object
Local xVal

cJsonResp :=  ''
cCCDe     :=  iif(valtype( self:costCenterOf ) <> 'U' .and. !empty(self:costCenterOf),self:costCenterOf," ")
cCCAte    :=  iif(valtype( self:costCenterUp ) <> 'U' .and. !empty(self:costCenterUp),self:costCenterUp,replicate('Z',60) )
cAlias    :=  ''
cTagJson  :=  ''
xOrder    :=  ''
cOrder    :=  '' 
cUrl      := 'https://api.totvs.com.br/'
cField    := ''
nPage     :=  0
nPageSize :=  10
nStruct   :=  0
nPos      :=  0
nPageAux  :=  0
lHasNext  :=  .f.
aStruct   :=  {}
oJsonResp := JsonObject():New( )
oHash     := HashCC( )

xOrder    := iif(valtype( self:order ) <> 'U' .and. !empty(self:order),self:order," ")

hmget( oHash, xOrder, @cOrder )

if "#F3#" $ cOrder .Or. "#DT#" $ cOrder
    cOrder := SubStr( cOrder, 1, Len( cOrder ) - 4 )
endif

if VldExecute( self:sourceBranch, @oJsonResp )

    DbSelectArea('C1P')

    If valtype( self:page ) <> 'U' .and. self:page > 0
        nPage := self:page
        if valtype( self:pageSize ) <> 'U' .and. self:pageSize > 0
            nPageSize := self:pageSize
        endif
    endif

    cAlias := GetCentCus( cCCDe, cCCAte, nPage, nPageSize, cOrder )

    aStruct := (cAlias)->(DBStruct()) // Retorna a estrutura dos campos utilizados na query

    while (cAlias)->(!eof())  
        nPageAux++        
        if nPageAux == 1
            oJsonResp["costCenter"] := {} 
        endif        
        if nPageAux < nPageSize+1 
            aAdd( oJsonResp["costCenter"],JsonObject():New())
            nPos++
            for nStruct := 1 to len(aStruct)
                cField := alltrim(aStruct[nStruct][1])
                if hmget( oHash, cField, @cTagJson ) .or. hmget( oHash, cField + "#F3#", @cTagJson )
                    xVal := &( '(cAlias)->' + cField )
                    if valtype( xVal ) == 'N'
                        oJsonResp["costCenter"][nPos][cTagJson] := xVal
                    else
                        oJsonResp["costCenter"][nPos][cTagJson] := alltrim( xVal )
                    endif
                elseif hmget( oHash, cField + "#DT#", @cTagJson )
                    xVal := &( '(cAlias)->' + cField )
                    if valtype(xVal) == 'C'
                        oJsonResp["costCenter"][nPos][cTagJson] := dtoc(stod(xVal))
                    else //tipo data
                        oJsonResp["costCenter"][nPos][cTagJson] := dtoc(xVal)
                    endif
                endif
            Next nStruct
        else
            lHasNext := .T.
            exit
        endif
        (cAlias)->(DbSkip())
    enddo
    ( cAlias )->( DBCloseArea( ) )
    if nPageAux == 0
        SetErroJs( @oJsonResp, "costCenter", , cUrl, '404' )
    endif
endif
oJsonResp["hasnext"] := lHasNext

cJsonResp := FwJsonSerialize( oJsonResp ) // Serializa objeto Json
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)

Return .T.

/*
Metodo responsável por consultar o cadastro de produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 
WSMETHOD GET idTsiCostCenter WSREST TSIcostCenter

Local cJsonResp     as character
Local cCCDe         as character
Local cAlias        as character
Local cUrl          as character
Local cField        as character
Local nStruct       as numeric
Local nPos          as numeric
Local nPageAux      as numeric
Local aStruct       as array
Local oHash         as object
Local oJsonResp     as object
Local lOk           as logical
Local xVal

lOk       := valtype( self:id ) <> 'U' .and. !empty(self:id)
cJsonResp := ''
cCCDe     := iif(lOk,self:id," ")
cAlias    := ''
cTagJson  := ''
cUrl      := 'https://api.totvs.com.br/'
cField    := ''
nStruct   := 0
nPos      := 0
nPageAux  := 0
aStruct   := {}
oJsonResp := JsonObject():New()
oHash     := HashCC( )

if VldExecute( self:sourceBranch, @oJsonResp )
    DbSelectArea('C1P')
    cAlias := GetCentCus(cCCDe, cCCDe)
    aStruct := ( cAlias )->( DBStruct( ) ) // Retorna a estrutura dos campos utilizados na query
    if (cAlias)->(eof())
        SetErroJs( @oJsonResp, "costCenter", , cUrl, '404' )
    else
        while (cAlias)->(!eof())
            oJsonResp["costCenter"] := {}
            aAdd( oJsonResp["costCenter"],JsonObject():New())
            nPos++
            for nStruct := 1 to len(aStruct)
                cField := alltrim( aStruct[nStruct][1] )
                if hmget( oHash, cField, @cTagJson ) .or. hmget( oHash, cField + "#F3#", @cTagJson )
                    xVal := &( '(cAlias)->' + cField )
                    if valtype( xVal ) == 'N'
                        oJsonResp["costCenter"][nPos][cTagJson] := xVal
                    else
                        oJsonResp["costCenter"][nPos][cTagJson] := alltrim( xVal )
                    endif
                elseif hmget( oHash, cField + "#DT#", @cTagJson )
                    xVal := &( '(cAlias)->' + cField )
                    if valtype(xVal) == 'C'
                        oJsonResp["costCenter"][nPos][cTagJson] := dtoc(stod(xVal))
                    else //tipo data
                        oJsonResp["costCenter"][nPos][cTagJson] := dtoc(xVal)
                    endif
                endif
            Next nStruct
            (cAlias)->(DbSkip())
        enddo
    endif
    ( cAlias )->( DBCloseArea( ) )
endif

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )
freeobj(oJsonResp)
fwFreeArray(aStruct)
lOk := .F.

Return .T.

/*
Metodo responsável por persistir os dados de produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/
WSMETHOD POST tsiCostCenter WSREST TSIcostCenter 

Local cJsonResp := ""
Local oBjJson   := JsonObject():New() // Requisição
Local oJsonResp	:= JsonObject():New() // retorno
Local nGetNames := 0
Local aNames    := {}
Local aRetJs    := {}

if VldExecute( self:sourceBranch, @oJsonResp )
    
    cBody := self:GetContent( )  
    oBjJson:fromJSON( cBody )

    if len( oBjJson:GetNames( ) ) > 0
        for nGetNames := 1 to len( oBjJson:GetNames() )
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if  oBjJson:GetNames()[nGetNames] == 'costCenter'
                TAFA565( HashCC( ), aNames, nil, @aRetJs ) 
                if nGetnames == 1
                    oJsonResp['costCenter'] := {}
                endif 
                // adiciona mensagem de erro ao objeto oJsonResp de retorno   
                SetErroJs(@oJsonResp, "costCenter", @aRetJs,,"403" )    
            endif
        next nGetNames
    else
        SetErroJs( @oJsonResp,,,,'400' )
    endif
endif

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )

return .T.

/*
Metodo responsável por persistir operações de alteração de cadastro produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 
WSMETHOD PUT tsiCostCenter WSREST TSIcostCenter

Local cJsonResp as character
Local cSeek     as character
Local cUrl      as character
Local oBjJson   as object
Local oJsonResp	as object
Local aRetJs    as array
Local nGetNames as numeric
Local aNames    as array
Local lOk       as logical
   
cJsonResp := ""
cUrl      := 'https://api.totvs.com.br/'
oBjJson   := JsonObject():New()
oJsonResp := JsonObject():New() 
aRetJs    := {}
nGetNames := 0
aNames    := {}
lOk       := valtype( self:id ) <> 'U' .and. !empty(self:id)

if lOk
    cSeekAux := self:id
    cSeek :=  "C1P->(DbSeek(xfilial('C1P') + " + "'"+cSeekAux+"'))"
    if VldExecute( self:sourceBranch, @oJsonResp )
        cBody := self:GetContent( )
        oBjJson:fromJSON( cBody )
        if len(oBjJson:GetNames()) > 0
            for nGetNames := 1 to len( oBjJson:GetNames() )
                aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                if  oBjJson:GetNames()[nGetNames] == 'costCenter'
                    TAFA565( HashCC( ), aNames, MODEL_OPERATION_UPDATE, @aRetJs, cSeek )
                endif
            next nGetNames
        else
            SetErroJs( @oJsonResp,,,,'400' )
        endif
        oJsonResp['costCenter'] := {}
        SetErroJs(@oJsonResp, "costCenter", @aRetJs,, "403", cSeekAux ) //cSeekAux garantia da chave ser i enviado na URL
    endif
else
    SetErroJs( @oJsonResp,,,cUrl,'401' )
endif

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )
cSeekAux :=  ''

Return .T.

/*
Metodo responsável por persistir operações de deleção de cadastro produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 
WSMETHOD DELETE tsiCostCenter WSREST TSIcostCenter

Local oBjJson   := JsonObject():New() 
Local oJsonResp	:= JsonObject():New() 
Local aRetJs    := {}
Local nGetNames := 0
Local aNames    := {}
Local cJsonResp := ""

if VldExecute( self:sourceBranch, @oJsonResp )
    cBody := self:GetContent( )
    oBjJson:fromJSON( cBody )
    if len(oBjJson:GetNames()) > 0
        for nGetNames := 1 to len(oBjJson:GetNames())
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if  oBjJson:GetNames()[nGetNames] == 'costCenter'
                TAFA565( HashCC( ), aNames, MODEL_OPERATION_DELETE, aRetJs )
            endif
        next nGetNames
    else
        SetErroJs( @oJsonResp,,,,'400' )
    endif
    oJsonResp['costCenter'] := {}
    // adiciona mensagem de erro ao objeto oJsonResp de retorno
    SetErroJs(@oJsonResp, "costCenter", @aRetJs,, "403" )
endif

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )

Return .t.

/*--------------------------------------------------------------------------------
{Protheus.doc} HashCC()
(Cria Hash de "De|Para" do identificador do Json para o campo de gravação no TAF)
@author Henrique Pereira
@since 15/07/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashCC()

Local oHash := HMNew( )
Local cTamKey := cValToChar( GetSx3Cache( "C1P_CODCUS", "X3_TAMANHO" ) )

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'  , 'MODEL_C1P' )
HMSet(oHash, 's_o_u_r_c_e_', 'TAFA061' )
HMSet(oHash, 'a_r_e_a_'    , 'C1P' )
HMSet(oHash, 'o_r_d_e_r_'  , 1 )
HMSet(oHash, 'k_e_y_'      , "aObjJson[nI]['costCenterId']" )
HMSet(oHash, 's_e_e_k_'    , "C1P->(DbSeek(xfilial('C1P') + padr(aObjJson[nI]['costCenterId']," + cTamKey + ")))" )
HMSet(oHash,'t_a_g_i_d_'   , 'costCenterId' )

// Propriedades e Campos
SetHashKey(oHash, 'costCenterId', 'C1P_CODCUS' )
SetHashKey(oHash, 'changeDate'  , 'C1P_DTALT#DT#' )
SetHashKey(oHash, 'description' , 'C1P_CCUS' )
SetHashKey(oHash, 'criationDate', 'C1P_DTCRIA#DT#' )
SetHashKey(oHash, 'stamp'       , 'C1P_STAMP' )

Return oHash

/*
Função responsável por executar a consulta ao cadastro de centro de custo
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 
static function GetCentCus( cCCDe, cCCAte, nPage, nPageSize, cOrder )

Local cQry        := ''
Local cAlias      := getNextAlias()

Default cCCDe     := ''
Default cCCAte    := ''
Default cOrder    := ''
Default nPage     := 0
Default nPageSize := 0

if nPage == 0
    nPage := 1
endif

if nPageSize == 0
    nPageSize := 10
endif

if Empty(cCCAte)
    cCCAte := replicate('Z',60)
endif

cQry := " SELECT "
cQry += " C1P.C1P_DTALT, "
cQry += " C1P.C1P_CODCUS, "
cQry += " C1P.C1P_CCUS, "
cQry += " C1P.C1P_DTCRIA, "
cQry += " C1P.C1P_STAMP "
cQry += " FROM " + RetSqlName("C1P") + " C1P "
cQry += " WHERE C1P.C1P_FILIAL = '" + xFilial("C1P") + "' "
cQry += " AND C1P.C1P_CODCUS BETWEEN '" + cCCDe + "' AND '" + cCCAte + "' "
cQry += " AND C1P.D_E_L_E_T_ = ' ' "

if !empty(cOrder)
    cQry += " ORDER BY C1P." + cOrder
else
    cQry += " ORDER BY 1 "
endif
cQry += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nPageSize) + " ) ROWS "
cQry += " FETCH NEXT " + cValToChar(nPageSize+1) + " ROWS ONLY "

dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)

Return cAlias
