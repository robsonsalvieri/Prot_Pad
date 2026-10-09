#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTagCNO := 'workNationalFile'
Static lT9CCodART := Nil

/* {Protheus.doc} WSTAF042
WS para persistencia do cadastro de Tabelas de Obras

@author Rafael Leme
@since 21/09/2021
@version 1.0
*/

WSRESTFUL tsiWorkNationalFile DESCRIPTION "TAF Service Integration - Tabelas de Obras"

    WSDATA sourceBranch         As  string
    WSDATA order                As  string  optional
    WSDATA registrationType     As  string  optional
    WSDATA registrationNumberOF As  string  optional
    WSDATA registrationNumberUP As  string  optional
    WSDATA id                   As  string  optional
    WSDATA page			        As  integer optional
    WSDATA pageSize 	        As  integer optional

	WSMETHOD GET tsiWorkNationalFile;
    DESCRIPTION "Retorna uma lista de cadastros de obras";
    PATH 'api/tsi/v1/tsiWorkNationalFile/';
    TTALK "tsiWorkNationalFile";
    WSSYNTAX "/tsiWorkNationalFile";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET idTsiWorkNationalFile;
    DESCRIPTION "Retorna um cadastro de obras pelo ID";
    PATH 'api/tsi/v1/tsiWorkNationalFile/idTsiWorkNationalFile/';
    TTALK "tsiWorkNationalFile";
    WSSYNTAX "/tsiWorkNationalFile";
    PRODUCES APPLICATION_JSON

    WSMETHOD POST tsiWorkNationalFile; 
    DESCRIPTION "Inclui/altera uma lista de cadastros de obras";
    PATH 'api/tsi/v1/tsiWorkNationalFile/';
    TTALK "tsiWorkNationalFile";
    WSSYNTAX "/tsiWorkNationalFile";
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT tsiWorkNationalFile;
    DESCRIPTION "Altera um cadastro de obras";
    PATH 'api/tsi/v1/tsiWorkNationalFile/';
    TTALK "tsiWorkNationalFile";
    WSSYNTAX "/tsiWorkNationalFile";
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE tsiWorkNationalFile;
    DESCRIPTION "Deleta uma lista de cadastro de obras";
    PATH 'api/tsi/v1/tsiWorkNationalFile/';
    TTALK "tsiWorkNationalFile";
    WSSYNTAX "/tsiWorkNationalFile";
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE idTsiWorkNationalFile;
    DESCRIPTION "Deleta um cadastro de obras através do ID";
    PATH 'api/tsi/v1/tsiWorkNationalFile/idTsiWorkNationalFile/';
    TTALK "tsiWorkNationalFile";
    WSSYNTAX "/tsiWorkNationalFile";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

/*
Metodo responsável por retornar uma lista do cadastro de obras
@author Rafael Leme
@since 21/09/2021
@version 1.0 
*/ 

WSMETHOD GET tsiWorkNationalFile WSRECEIVE sourceBranch, registrationType, registrationNumberOf, registrationNumberUp WSREST tsiWorkNationalFile

Local oHash     As object
Local oJsonResp As object
Local cJsonResp As character
Local cCNODe    As character
Local cCNOAte   As character
Local cTPInsc   As Character
Local cAlias    As character
Local cOrder    As character
Local xOrder    As character
Local cUrl      As character
Local cField    As character
Local cTagJson  As character    
Local nPage     As numeric 
Local nPageSize As numeric 
Local nStruct   As numeric 
Local nPos      As numeric
Local nPageAux  As numeric
Local lHasNext  As logical
Local aStruct   As array

oHash     := HashCNO()
oJsonResp := JsonObject():New()
cJsonResp := ''
cNcmDe    := ''
cNcmAte   := ''
cTPInsc   := ''
cAlias    := ''
cOrder    := ''
xOrder    := iif(valtype( self:order ) <> 'U' .and. !empty(self:order),self:order," ")
cUrl      := 'https://api.totvs.com.br/'
cField    := ''
cTagJson  := ''
nPage     := 0
nPageSize := 10
nStruct   := 0
nPos      := 0
nPageAux  := 0
lHasNext  := .f.
aStruct   := {}

hmget( oHash, xOrder,@cOrder)

if VldExecute( self:sourceBranch, @oJsonResp )
    if valtype( self:page ) <> 'U' .and. self:page > 0
        nPage := self:page
        if valtype( self:pageSize ) <> 'U' .and. self:pageSize > 0
            nPageSize := self:pageSize
        endif
    endif
    if valtype( self:registrationType ) <> 'U' .and. !Empty(self:registrationType)
        cTPInsc := "'" + self:registrationType + "'"
    else
        cTPInsc := "'1','4'"
    endif
    if valtype( self:registrationNumberOf ) <> 'U' .and. !Empty(self:registrationNumberOf)
        cCNODe := self:registrationNumberOf
    else
        cCNODe := ' '
    endif
    if valtype( self:registrationNumberUp ) <> 'U' .and. !Empty(self:registrationNumberUp)
        cCNOAte := self:registrationNumberUp
    else
        cCNOAte := replicate('z',15)
    endif
    cAlias  := GetQryCNO( cTPInsc, cCNODe, cCNOAte, nPage, nPageSize, cOrder )
    aStruct := ( cAlias )->( DBStruct() ) // Retorna a estrutura dos campos utilizados na query
    while (cAlias)->(!eof())
        nPageAux++
        if nPageAux == 1
            oJsonResp[cTagCNO] := {}
        endif
        if nPageAux <= nPageSize
            aAdd( oJsonResp[cTagCNO],JsonObject():New())
            nPos++
            for nStruct := 1 to len(aStruct)
                cField := alltrim( aStruct[nStruct][1] )

                //Busca Demais Campos
                if hmget( oHash, cField, @cTagJson )
                    oJsonResp[cTagCNO][nPos][cTagJson] := Alltrim( &( '(cAlias)->' + cField ) )
                endif
            Next nStruct
        else
            lHasNext := .t.
            exit
        endif
        (cAlias)->(DbSkip())
    enddo
    ( cAlias )->( DBCloseArea() )
    if nPageAux == 0
        SetErroJs( @oJsonResp, cTagCNO, , cUrl, '404' )
    endif
endif
oJsonResp["hasnext"] := lHasNext

// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp ) 
Self:SetResponse( cJsonResp )   
freeobj(oJsonResp)
fwFreeArray(aStruct)
 
Return .t.

/*
Metodo responsável por retornar um cadastro de obras através do ID
@author Rafael Leme   
@since 21/09/2021
@version 1.0
*/

WSMETHOD GET idTsiWorkNationalFile WSRECEIVE sourceBranch, registrationType, id WSREST tsiWorkNationalFile

Local oHash     As object
Local oJsonResp As object
Local cJsonResp As character
Local cTPInsc   As Character
Local cCNODe    As character
Local cAlias    As character
Local cUrl      As character
Local cField    As character
Local cTagJson  As character
Local nStruct   As numeric
Local nPos      As numeric
Local nPageAux  As numeric
Local lok       As logical
Local aStruct   As array

oHash     := HashCNO()
oJsonResp := JsonObject():New()
cJsonResp := ''
cTPInsc   := iif(valtype( self:registrationType ) <> 'U' .and. !empty(self:registrationType),self:registrationType," ")
cCNODe    := iif(valtype( self:id ) <> 'U' .and. !empty(self:id),self:id," ")
cAlias    := ''
cUrl      := 'https://api.totvs.com.br/'
cField    := ''
cTagJson  := ''
nStruct   := 1
nPos      := 0
nPageAux  := 0
lOk       := .f.
aStruct   := {} 

if !Empty(cTPInsc) .and. !Empty(cCNODe)
    if VldExecute( self:sourceBranch, @oJsonResp )
        DbSelectArea('T9C')
        cAlias  := GetQryCNO(cTPInsc, cCNODe, cCNODe,,,) //filtra o unico Id
        aStruct := ( cAlias  )->( DBStruct() ) // Retorna a estrutura dos campos utilizados na query
        while (cAlias)->(!eof())
            lOk := .t.
            oJsonResp[cTagCNO] := {}
            aAdd( oJsonResp[cTagCNO], JsonObject():New() )
            nPos++
            for nStruct := 1 to len(aStruct)  
                cField := alltrim( aStruct[nStruct][1] )

                //Busca Demais Campos
                if hmget( oHash, cField, @cTagJson )
                    oJsonResp[cTagCNO][nPos][cTagJson] := Alltrim( &( '(cAlias)->' + cField ) )
                endif
            Next nStruct
            (cAlias)->(DbSkip()) 
        enddo
        ( cAlias  )->( DBCloseArea() )
        if !lOk
            SetErroJs( @oJsonResp, cTagCNO, , cUrl, '404' )
        endif
    endif
else
    SetErroJs( @oJsonResp,,,, '400',,,,.F.)
endif
 
// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp ) 
Self:SetResponse( cJsonResp )   
freeobj(oJsonResp)
fwFreeArray(aStruct)

Return .t.

/*
Metodo responsável por incluir/alterar os cadastros de obras conforme o body
@author Rafael Leme    
@since 21/09/2021
@version 1.0 
*/

WSMETHOD POST tsiWorkNationalFile WSRECEIVE sourceBranch WSREST tsiWorkNationalFile

Local oBjJson   As object
Local oJsonResp As object
Local cJsonResp As character
Local nGetNames As numeric
Local aNames    As array
Local aRetJs    As array

oBjJson   := JsonObject():New() // Requisição
oJsonResp := JsonObject():New() // retorno
cJsonResp := ''
nGetNames := 0
aNames    := {}
aRetJs    := {}

if VldExecute( self:sourceBranch, @oJsonResp )
    cBody := self:GetContent()
    oBjJson:fromJSON( cBody )
    if len( oBjJson:GetNames() ) > 0
        for nGetNames := 1 to len( oBjJson:GetNames() )
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if  oBjJson:GetNames()[nGetNames] == cTagCNO
                TAFA565( HashCNO(), aNames, nil, @aRetJs )
                oJsonResp[cTagCNO] := {}
                //Retorna possíveis erros que possam ter ocorrido na integração.
                SetErroJs(@oJsonResp, cTagCNO, @aRetJs,,'403')
            endif
        next
    else
        SetErroJs( @oJsonResp,,,,'400' )
    endif
endif
        
// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )

return .t.

/*
Metodo responsável por alterar um cadastro de obra conforme ID e body
@author Rafael Leme  
@since 22/09/2021
@version 1.0
*/

WSMETHOD PUT tsiWorkNationalFile WSRECEIVE sourceBranch, registrationType, id WSREST tsiWorkNationalFile

Local oBjJson   As object
Local oJsonResp	As object
Local cJsonResp As character
Local cSeek     As character
Local cSeekTP   As character
Local cSeekID   As character
Local cUrl      As character
Local nError    As numeric
Local nGetNames As numeric
Local nJson     As numeric
Local aRetJs    As array
Local aNames    As array

oBjJson   := JsonObject():New()
oJsonResp := JsonObject():New()
cJsonResp := ""
cSeek     := ''
cSeekTP   := iif(valtype( self:registrationType ) <> 'U' .and. !empty(self:registrationType),self:registrationType," ")
cSeekID   := iif(valtype( self:id ) <> 'U' .and. !empty(self:id),self:id," ")
cUrl      := 'https://api.totvs.com.br/'
nError    := 0
nGetNames := 0
nJson     := 1
aRetJs    := {}
aNames    := {}

if  !Empty(cSeekTP) .and. !Empty(cSeekID)
    if VldExecute( self:sourceBranch, @oJsonResp )
        cSeek := "T9C->(DbSeek(xfilial('T9C') + '" + cSeekTP + "' + '" + cSeekID + "'))"
        cBody := self:GetContent() 
        oBjJson:fromJSON( cBody ) 
        if len(oBjJson:GetNames())>0
            for nGetNames := 1 to len( oBjJson:GetNames() )
                aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                if oBjJson:GetNames()[nGetNames] == cTagCNO
                    TAFA565( HashCNO(), aNames, MODEL_OPERATION_UPDATE, @aRetJs, cSeek )
                endif
            next nGetNames
        else
            SetErroJs( @oJsonResp,,,,'400' )
        endif
        oJsonResp[cTagCNO] := {} 
        
        //Retorna possíveis erros que possam ter ocorrido na integração.
        SetErroJs(@oJsonResp, cTagCNO, @aRetJs, , '403', cSeekTP + cSeekID )      
    endif
else
    SetErroJs( @oJsonResp,,,, '400',,,,.T.)
endif

// Serializa objeto Json
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )
cSeekAux := ''

Return .t.

/*
Metodo responsável por deletar cadastros de obras conforme body
@author Rafael Leme   
@since 22/09/2021
@version 1.0 
*/

WSMETHOD DELETE tsiWorkNationalFile WSRECEIVE sourceBranch WSREST tsiWorkNationalFile

Local oBjJson   As object
Local oJsonResp	As object
Local cJsonResp As character
Local nGetNames As numeric
Local aNames    As array
Local aRetJs    As array

oBjJson   := JsonObject():New() 
oJsonResp := JsonObject():New()
cJsonResp := ''
nGetNames := 0
aNames    := {}
aRetJs    := {}

if VldExecute( self:sourceBranch, @oJsonResp )
    cBody := self:GetContent() 
    oBjJson:fromJSON( cBody )
    if len(oBjJson:GetNames()) > 0
        for nGetNames := 1 to len(oBjJson:GetNames())
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if oBjJson:GetNames()[nGetNames] == cTagCNO
                TAFA565( HashCNO(), aNames, MODEL_OPERATION_DELETE, aRetJs )
            endif
        next nGetNames
    else
        SetErroJs( @oJsonResp,,,,'400' )
    endif
    oJsonResp[cTagCNO] := {}

    // adiciona mensagem de erro ao objeto oJsonResp de retorno   
    SetErroJs(@oJsonResp, cTagCNO, aRetJs,,'403' )       
endif

// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )

Return .t.

/*
Metodo responsável por deletar cadastros de obras conforme ID
@author Rafael Leme   
@since 22/09/2021
@version 1.0 
*/

WSMETHOD DELETE idTsiWorkNationalFile WSRECEIVE sourceBranch, registrationType, id WSREST tsiWorkNationalFile

Local oJsonResp As Object
Local oBjJson   As Object
Local cJsonResp As Character
Local cId       As Character
Local cTPInsc   As Character
Local cSeek     As Character
Local cArea     As Character
Local cSource   As Character
Local nGetNames As Numeric
Local aRetJs    As Array

oJsonResp := JsonObject():New() // retorno
oBjJson   := JsonObject():New()
cJsonResp := ''
cId       := iif(valtype( self:id  ) <> 'U' .and. !empty(self:id ),self:id ," ")
cTPInsc   := iif(valtype( self:registrationType  ) <> 'U' .and. !empty(self:registrationType ),self:registrationType ," ")
cSeek     := ''
cArea     := ''
cSource   := ''
nGetNames := 0
aRetJs    := {}

hmget( HashCNO(), "s_o_u_r_c_e_", @cSource  )
hmget( HashCNO(), "a_r_e_a_"    , @cArea    )

if  !Empty(cTPInsc) .and. !Empty(cID)
    if VldExecute( self:sourceBranch, @oJsonResp )
        DbSelectArea(cArea)
        T9C->( DbSetOrder(3) ) //T9C_FILIAL, T9C_TPINSC, T9C_NRINSC, R_E_C_N_O_, D_E_L_E_T_
        if T9C->( DbSeek( xfilial('T9C') + cTPInsc + cID ) )
            oModel := FWLoadModel( cSource )
            oModel:SetOperation( 5 )
            oModel:Activate()
            FwFormCommit( oModel )
            aadd( aRetJs, { .T., cTPInsc + cID } )
        else
            SetErroJs( @oJsonResp,,,,'404' )
        endif
        oJsonResp[cTagCNO] := {}

        // adiciona mensagem de erro ao objeto oJsonResp de retorno   
        SetErroJs(@oJsonResp, cTagCNO, aRetJs,,'403' )    
    endif
else
    SetErroJs( @oJsonResp,,,, '400',,,,.F.)
endif

// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )

Return .T.

/*--------------------------------------------------------------------------------
{Protheus.doc} HashCNO()
(Cria Hash de "De|Para" do identificador do Json para o campo de gravação no TAF)
CNO vinculo com o TAFA489
@author Rafael Leme   
@since 21/09/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashCNO()

Local oHash      As object
Local cTamTPInsc As character
Local cTamNRInsc As character

oHash      := HMNew()
cTamTPInsc := lTrim(cValToChar(GetSx3Cache('T9C_TPINSC','X3_TAMANHO')))
cTamNRInsc := lTrim(cValToChar(GetSx3Cache('T9C_NRINSC','X3_TAMANHO')))

if lT9CCodART == Nil
    lT9CCodART := T9C->(FieldPos("T9C_CODART")) > 0
endif

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'  , 'MODEL_T9C')
HMSet(oHash, 's_o_u_r_c_e_', 'TAFA489'  )
HMSet(oHash, 'a_r_e_a_'    , 'T9C'      )
HMSet(oHash, 'o_r_d_e_r_'  , 3          ) //T9C_FILIAL, T9C_TPINSC, T9C_NRINSC, R_E_C_N_O_, D_E_L_E_T_
HMSet(oHash, 'k_e_y_'      , "aObjJson[nI]['registrationType'] + aObjJson[nI]['cnoNumber']")
HMSet(oHash, 's_e_e_k_'    , "T9C->(DbSeek(xfilial('T9C') + padr(aObjJson[nI]['registrationType']," + cTamTPInsc + ") + padr(aObjJson[nI]['cnoNumber']," + cTamNRInsc + ")))")
HMSet(oHash, 't_a_g_i_d_'  , 'workNationalFile' )

// Propriedades e Campos
SetHashKey(oHash, 'registrationType'  , 'T9C_TPINSC' )
SetHashKey(oHash, 'cnoNumber'         , 'T9C_NRINSC' )
SetHashKey(oHash, 'workIdentification', 'T9C_INDOBR' )
SetHashKey(oHash, 'thirdPartyCallsign', 'T9C_INDTER' )
SetHashKey(oHash, 'description'       , 'T9C_DSCOBR' )
SetHashKey(oHash, 'cprbPayer'         , 'T9C_CPRB'   )
SetHashKey(oHash, 'stamp'             , 'T9C_STAMP'  )

if lT9CCodART
    SetHashKey(oHash, 'artCode'       , 'T9C_CODART' )
endif

Return oHash

/*--------------------------------------------------------------------------------
{Protheus.doc} GetQryCNO()
(Responsável por executar a consulta ao cadastro de Tabelas de Obras)
@author Rafael Leme  
@since 21/09/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/

Function GetQryCNO( cTPInsc, cCNODe, cCNOAte, nPage, nPageSize, cOrder)

Local cQry As character
Local cAlias As character

Default cTPInsc   := ''
Default cCNODe    := ''
Default cCNOAte   := ''
Default cOrder    := ''
Default nPage     := 0
Default nPageSize := 0

cQry   := ''
cAlias := getNextAlias()

if nPage     == 0; nPage := 1                 ; endif
if nPageSize == 0; nPageSize := 10            ; endif
if Empty(cCNOAte); cCNOAte := replicate('z',8); endif
if Empty(cTPInsc); cTPInsc := "'1','4'"       ; endif

cQry := " SELECT "
cQry += " 	T9C.T9C_TPINSC, "
cQry += " 	T9C.T9C_NRINSC, "
cQry += " 	T9C.T9C_INDOBR, "
cQry += " 	T9C.T9C_DSCOBR, "
cQry += " 	T9C.T9C_INDTER, "
cQry += " 	T9C.T9C_CPRB, "
cQry += " 	T9C.T9C_STAMP "
cQry += " FROM " + RetSqlName('T9C') + " T9C "
cQry += " WHERE T9C.D_E_L_E_T_ = ' ' "
cQry += " 	AND T9C.T9C_FILIAL = '" + xFilial('T9C') + "' "
cQry += " 	AND T9C.T9C_TPINSC IN ( " + cTPInsc + " ) "
cQry += " 	AND T9C.T9C_NRINSC BETWEEN '" + cCNODe + "' AND '" + cCNOAte + "' "

if !empty(cOrder)
    cQry += " ORDER BY T9C."+cOrder
else
    cQry += " ORDER BY 1 "
endif

cQry += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nPageSize) + " ) ROWS "
cQry += " FETCH NEXT " + cValToChar(nPageSize+1) + " ROWS ONLY "

dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)

Return cAlias
