#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSTAF025.CH" 
#INCLUDE "FWMVCDEF.CH"

Static cTagNatOp := 'natureOfTheOperation'

/*/{Protheus.doc} WSTAF025
WS para persistencia do cadastro de natureza de operação ao TAF

@author Henrique Fabiano Pateno Pereira
@author Carlos Eduardo N. da Silva / Denis Souza
@since 08/07/2020
@version 1.0
*/

WSRESTFUL tsiNatureOfTheOperation DESCRIPTION "TAF Service Integration - Natureza de Operação"

    WSDATA sourceBranch           As string
    WSDATA page			          As integer optional
    WSDATA pageSize 	          As integer optional
    WSDATA order                  As string  optional
    WSDATA natureOfTheOperationOf As string  optional
    WSDATA natureOfTheOperationUp As string  optional
    WSDATA id                     As string  optional

	WSMETHOD GET tsiNatureOfTheOperation;
    DESCRIPTION "Retorna uma lista de Natureza de Operação";
    PATH 'api/tsi/v1/tsiNatureOfTheOperation/';
    TTALK "v1";
    WSSYNTAX "/tsiNatureOfTheOperation";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET idTsiNatureOfTheOperation;
    DESCRIPTION "Retorna uma Natureza de Operação";
    PATH 'api/tsi/v1/tsiNatureOfTheOperation/{id}';
    TTALK "v1";
    WSSYNTAX "/tsiNatureOfTheOperation";
    PRODUCES APPLICATION_JSON

    WSMETHOD POST tsiNatureOfTheOperation; 
    DESCRIPTION "Inclui/altera uma lista de Natureza de Operação";
    PATH 'api/tsi/v1/tsiNatureOfTheOperation/';
    TTALK "v1";
    WSSYNTAX "/tsiNatureOfTheOperation";
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT tsiNatureOfTheOperation;
    DESCRIPTION "Altera uma natureza de Operação";
    PATH 'api/tsi/v1/tsiNatureOfTheOperation/{id}';
    TTALK "v1";
    WSSYNTAX "/tsiNatureOfTheOperation";
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE tsiNatureOfTheOperation;
    DESCRIPTION "Delete uma lista de natureza de Operação";
    PATH 'api/tsi/v1/tsiNatureOfTheOperation/';
    TTALK "v1";
    WSSYNTAX "/tsiNatureOfTheOperation";
    PRODUCES APPLICATION_JSON 

END WSRESTFUL

/*
Metodo responsável por consultar o cadastro de natureza de operacao ao TAF
@author Henrique Fabiano Pateno Pereira
@author Carlos Eduardo N. da Silva / Denis Souza
@since 08/07/2020
@version 1.0 
*/ 

WSMETHOD GET tsiNatureOfTheOperation WSREST TSInatureOfTheOperation

Local cJsonResp     as character
Local cNatDe        as character
Local cNatAte       as character
Local cAlias        as character
Local cOrder        as character
Local xOrder        as character
Local nPage         as numeric 
Local nPageSize     as numeric 
Local nStruct       as numeric 
Local nPos          as numeric
Local nPageAux      as numeric
Local lHasNext      as logical
Local aStruct       as array
Local oHash         as object
Local oJsonResp     as object
Local cUrl          as character
Local cField        as character

cJsonResp :=  ''
cNatDe    :=  ''
cNatAte   :=  ''
cAlias    :=  ''
cTagJson  :=  ''
xOrder    :=  ''
cOrder    :=  ''
nPage     :=  0
nPageSize :=  10
nStruct   :=  0
nPos      :=  0
nPageAux  :=  0
lHasNext  :=  .f.
aStruct   :=  {}
oJsonResp := JsonObject():New()
oHash     := HashNature( )
cUrl      := 'https://api.totvs.com.br/'
cField    := ""

xOrder  :=  iif(valtype( self:order ) <> 'U' .and. !empty(self:order),self:order," ")

hmget( oHash, xOrder,@cOrder)

if VldExecute( self:sourceBranch, @oJsonResp )
    
    If valtype( self:page ) <> 'U' .and. self:page > 0
        nPage := self:page
        if valtype( self:pageSize ) <> 'U' .and. self:pageSize > 0
            nPageSize := self:pageSize
        endif
    endif

    If valtype( self:natureOfTheOperationOf ) <> 'U' .and. !Empty(self:natureOfTheOperationOf)
        cNatDe := self:natureOfTheOperationOf
    else
        cNatDe := ' '
    endif

    If valtype( self:natureOfTheOperationUp ) <> 'U' .and. !Empty(self:natureOfTheOperationUp)
        cNatAte := self:natureOfTheOperationUp
    else
        cNatAte := replicate('Z',8)
    endif

    cAlias := GetNature( cNatDe, cNatAte, nPage, nPageSize, cOrder )

    aStruct := ( cAlias )->( DBStruct( ) ) // Retorna a estrutura dos campos utilizados na query

    while (cAlias)->(!eof())
        nPageAux++

        if nPageAux == 1
            oJsonResp[cTagNatOp] := {}
        endif

        if nPageAux <= nPageSize
            aAdd( oJsonResp[cTagNatOp],JsonObject():New())
            nPos++

            for nStruct := 1 to len(aStruct)
                
                cField := alltrim( aStruct[nStruct][1] )

                //Busca Demais Campos
                if hmget( oHash, cField, @cTagJson ) .or. hmget( oHash, cField + "#F3#", @cTagJson )

                    oJsonResp[cTagNatOp][nPos][cTagJson] := Alltrim( &( '(cAlias)->' + cField ) )

                endif

            Next nStruct
        else
            lHasNext := .t.
            exit
        endif

        (cAlias)->(DbSkip())
    enddo

    ( cAlias )->( DBCloseArea( ) )

    if nPageAux == 0
        SetErroJs( @oJsonResp, cTagNatOp, , cUrl, '404' )
    endif
endif

oJsonResp["hasnext"] := lHasNext

//------------------------------------------------------------------- 
// Serializa objeto Json 
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp ) 
Self:SetResponse( cJsonResp )   
freeobj(oJsonResp)
 
Return .t.

/*
Metodo responsável por consultar o cadastro de natureza de operação ao TAF
@author Henrique Fabiano Pateno Pereira / Denis Souza
@since 15/07/2020
@version 1.0
*/

WSMETHOD GET idTsiNatureOfTheOperation WSREST TSInatureOfTheOperation

Local cJsonResp As character
Local cNatDe    As character
Local cAlias    As character
Local nStruct   As numeric
Local nPos      As numeric
Local nPageAux  As numeric
Local aStruct   As array
Local oHash     As object
Local oJsonResp As object
Local lOk       As logical
Local cUrl      as character
Local cField    as character

lOk         := valtype( self:id ) <> 'U' .and. !empty(self:id)
cJsonResp   := ''
cNatDe      := iif(lOk,self:id," ")
cAlias      := ''
cTagJson    := ''
nStruct     := 1
nPos        := 0
nPageAux    := 0
aStruct     := {} 
oJsonResp	:= JsonObject():New()
oHash       := HashNature( )
cUrl        := 'https://api.totvs.com.br/'
cField      := ""

if VldExecute( self:sourceBranch, @oJsonResp )
    DbSelectArea('C1N')
    cAlias := GetNature(cNatDe, cNatDe) //filtra o unico Id

    aStruct := ( cAlias )->( DBStruct( ) ) // Retorna a estrutura dos campos utilizados na query

    // coloco lOk como false para validar a exisitencia do registro na base
    lOk := .f.

    while (cAlias)->(!eof())
        lOk := .t.
        oJsonResp[cTagNatOp] := {}

        aAdd( oJsonResp[cTagNatOp], JsonObject():New() )
        nPos++

        for nStruct := 1 to len(aStruct)
             cField := alltrim( aStruct[nStruct][1] )

            //Busca Demais Campos
            if hmget( oHash, cField, @cTagJson ) .or. hmget( oHash, cField + "#F3#", @cTagJson )

                oJsonResp[cTagNatOp][nPos][cTagJson] := Alltrim( &( '(cAlias)->' + cField ) )

            endif
        Next nStruct  

        (cAlias)->(DbSkip()) 
    enddo

    ( cAlias )->( DBCloseArea( ) )

    if !lOk
        SetErroJs( @oJsonResp, cTagNatOp, , cUrl, '404' )
    endif
endif

//------------------------------------------------------------------- 
// Serializa objeto Json 
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp ) 
Self:SetResponse( cJsonResp )   
freeobj(oJsonResp)
fwFreeArray(aStruct)
lOk := .f.

Return .t.

/*
Metodo responsável por persistir os dados de natureza de Operação ao TAF
@author Henrique Fabiano Pateno Pereira
@author Carlos Eduardo N. da Silva / Denis Souza
@since 08/07/2020
@version 1.0 
*/

WSMETHOD POST tsiNatureOfTheOperation WSREST TSInatureOfTheOperation

Local cJsonResp     := ""
Local oBjJson       := JsonObject():New() // Requisição
Local oJsonResp	    := JsonObject():New() // retorno
Local nGetNames     := 0
Local aNames        := {}
Local aRetJs        := {}

if VldExecute( self:sourceBranch, @oJsonResp )

    cBody := self:GetContent( )
    oBjJson:fromJSON( cBody )

    if len( oBjJson:GetNames( ) ) > 0

        for nGetNames := 1 to len( oBjJson:GetNames() )
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if  oBjJson:GetNames()[nGetNames] == cTagNatOp
                TAFA565( HashNature( ), aNames, nil, @aRetJs )

                oJsonResp[cTagNatOp] := {}
                //Retorna possíveis erros que possam ter ocorrido na integração.
                SetErroJs(@oJsonResp, cTagNatOp, @aRetJs,,'403')

            endif
        next
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
Metodo responsável por persistir operações de alteração de cadastro natureza de operação ao TAF
@author Henrique Fabiano Pateno Pereira
@author Carlos Eduardo N. da Silva / Denis de Souza Naves
@since 08/07/2020
@version 1.0
*/

WSMETHOD PUT tsiNatureOfTheOperation WSREST TSInatureOfTheOperation

Local cJsonResp     as character
Local cSeek         as character
Local oBjJson       as object
Local oJsonResp	    as object
Local aRetJs        as array
Local nError        as numeric
Local nGetNames     as numeric
Local nJson         as numeric
Local aNames        as array
Local lOk           as logical
Local cUrl          := 'https://api.totvs.com.br/'

cJsonResp   := ""
oBjJson     := JsonObject():New()
oJsonResp	:= JsonObject():New()
aRetJs      := {}
nError      := 0
nGetNames   := 0
nJson       := 1
aNames      := {}
lOk         := valtype( self:id ) <> 'U' .and. !empty(self:id)

if lOk
    cSeekAux := self:id
    cSeek := "C1N->(DbSeek(xfilial('C1N') + " + "'"+cSeekAux+"'))"
    // valida parâmetro counsceBranche
    if VldExecute( self:sourceBranch, @oJsonResp )
        cBody := self:GetContent( ) 
        oBjJson:fromJSON( cBody ) 

        if len(oBjJson:GetNames())>0
            for nGetNames := 1 to len( oBjJson:GetNames() )
                aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                if oBjJson:GetNames()[nGetNames] == cTagNatOp
                    TAFA565( HashNature( ), aNames, MODEL_OPERATION_UPDATE, @aRetJs, cSeek )
                endif
            next nGetNames
        else
            SetErroJs( @oJsonResp,,,,'400' )
        endif

        oJsonResp[cTagNatOp] := {} //todo Id?
        //Retorna possíveis erros que possam ter ocorrido na integração.
        SetErroJs(@oJsonResp, cTagNatOp, @aRetJs, , '403', cSeekAux )    // garantia de retorno do id de acordo com a url       

    endif
else
    SetErroJs( @oJsonResp,,,cUrl,'401' )
endif

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )
cSeekAux := ''
Return .t.

/*
Metodo responsável por persistir operações de deleção de cadastro natureza de operação ao TAF
@author Henrique Fabiano Pateno Pereira
@author Carlos Eduardo N. da Silva / Denis Souza
@since 08/07/2020
@version 1.0 
*/ 

WSMETHOD DELETE tsiNatureOfTheOperation WSREST TSInatureOfTheOperation

Local cJsonResp  as character
Local oBjJson    := JsonObject():New() 
Local oJsonResp	 := JsonObject():New()
Local nGetNames  := 0
Local aNames     := {}
Local aRetJs     := {}

cJsonResp        := ""

if VldExecute( self:sourceBranch, @oJsonResp )
    cBody := self:GetContent( ) 
    oBjJson:fromJSON( cBody )

    if len(oBjJson:GetNames())>0
        for nGetNames := 1 to len(oBjJson:GetNames())
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if oBjJson:GetNames()[nGetNames] == cTagNatOp
                TAFA565( HashNature(), aNames, MODEL_OPERATION_DELETE, aRetJs )
            endif
        next nGetNames
    else
        SetErroJs( @oJsonResp,,,,'400' )
    endif

    oJsonResp[cTagNatOp] := {}
    // adiciona mensagem de erro ao objeto oJsonResp de retorno   
    SetErroJs(@oJsonResp, cTagNatOp, aRetJs,,'403' )       

endif

//------------------------------------------------------------------- 
// Serializa objeto Json 
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )

Return .T.

/*--------------------------------------------------------------------------------
{Protheus.doc} HashNature()
(Cria Hash de "De|Para" do identificador do Json para o campo de gravação no TAF)
@author Carlos Eduardo / Denis Souza
@since 15/07/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashNature()

Local oHash := HMNew( )

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'   , 'MODEL_C1N'   )
HMSet(oHash, 's_o_u_r_c_e_' , 'TAFA059'     )
HMSet(oHash, 'a_r_e_a_'     , 'C1N'         )
HMSet(oHash, 'o_r_d_e_r_'   , 1             )
HMSet(oHash, 'k_e_y_'       , "aObjJson[nI]['natureOfTheOperationId']")
HMSet(oHash, 's_e_e_k_'     , "C1N->(DbSeek(xfilial('C1N') + aObjJson[nI]['natureOfTheOperationId']))" )
HMSet( oHash,'t_a_g_i_d_'   , 'natureOfTheOperationId'      )

// Propriedades e Campos
SetHashKey(oHash, 'natureOfTheOperationId', 'C1N_CODNAT') 
SetHashKey(oHash, 'description'           , 'C1N_DESNAT')
SetHashKey(oHash, 'natureCodeECF'         , 'C1N_IDNATE#F3#')
SetHashKey(oHash, 'purposeOfTheNature'    , 'C1N_OBJOPE')
SetHashKey(oHash, 'operationCodeANP'      , 'C1N_IDOPAN#F3#')
SetHashKey(oHash, 'stamp'                 , 'C1N_STAMP' )
SetHashKey(oHash, 'enforceabilityISS'     , 'C1N_IDEXIG#F3#' ) //Campos ja existente nao sera necessario protecao C1N_CODEXI (V)

// #F3#
HMSet(oHash, '#F3#C1N_IDNATE', "GetTafId( 'CHK', cChave, 2 )")
HMSet(oHash, '#F3#C1N_IDOPAN', "GetTafId( 'T5A', cChave, 2 )")
HMSet(oHash, '#F3#C1N_IDEXIG', "GetTafId( 'T85', cChave, 2 )") //Campo ja existentes nao sera necessario protecao

Return oHash

/*--------------------------------------------------------------------------------
{Protheus.doc} GetNature()
(Responsável por executar a consulta ao cadastro da Natureza de Operação)
@author Carlos Eduardo / Denis Souza
@since 07/07/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function GetNature( cNatDe, cNatAte, nPage, nPageSize, cOrder )

Local cQry   := ''
Local cAlias := getNextAlias()

Default cNatDe     := ''
Default cNatAte    := ''
Default cOrder     := ''
Default nPage      := 0
Default nPageSize  := 0

if nPage == 0    ; nPage := 1                 ; endif
if nPageSize == 0; nPageSize := 10            ; endif
if Empty(cNatAte); cNatAte := replicate('Z',8); endif

cQry := " SELECT "
cQry += " 	C1N.C1N_CODNAT, "
cQry += " 	C1N.C1N_DESNAT, "
cQry += " 	CHK.CHK_CODIGO C1N_IDNATE, "
cQry += " 	C1N.C1N_OBJOPE, "
cQry += " 	T5A.T5A_CODOPE C1N_IDOPAN, "
cQry += " 	C1N.C1N_STAMP "
cQry += " FROM " + RetSqlName('C1N') + " C1N "
cQry += " 	LEFT JOIN " + RetSqlName('CHK') + " CHK ON CHK.CHK_FILIAL = '" + xFilial('CHK') + "' AND CHK.CHK_ID = C1N.C1N_IDNATE AND CHK.D_E_L_E_T_ = ' ' "
cQry += " 	LEFT JOIN " + RetSqlName('T5A') + " T5A ON T5A.T5A_FILIAL = '" + xFilial('T5A') + "' AND T5A.T5A_ID = C1N.C1N_IDOPAN AND T5A.D_E_L_E_T_ = ' ' "
cQry += " WHERE C1N.D_E_L_E_T_ = ' ' "
cQry += " 	AND C1N_FILIAL = '" + xFilial('C1N') + "' "
cQry += " 	AND C1N_CODNAT BETWEEN '" + cNatDe + "' AND '" + cNatAte + "' "

if !empty(cOrder)
    cQry += " ORDER BY C1N."+cOrder
else
    cQry += " ORDER BY 1 "
endif

cQry += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nPageSize) + " ) ROWS "
cQry += " FETCH NEXT " + cValToChar(nPageSize+1) + " ROWS ONLY "

dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)

Return cAlias
