#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTagNcm := 'commonExternalTariff'

/*/{Protheus.doc} WSTAF036
WS para persisitencia do cadastro de Ncm do TAF

@author Ricardo Lovrenovic    
@since 12/07/2021
@version 1.0
*/

WSRESTFUL tsiCommonExternalTariff DESCRIPTION "TAF Service Integration - Ncm"

    WSDATA sourceBranch             As  string
    WSDATA page			            As  integer optional
    WSDATA pageSize 	            As  integer optional
    WSDATA order                    As  string  optional
    WSDATA commonExternalTariffOf   As  string  optional
    WSDATA commonExternalTariffUp   As  string  optional
    WSDATA id                       As  string  optional
    WSDATA exNcm                    As  string  optional

	WSMETHOD GET tsiCommonExternalTariff;
    DESCRIPTION "Retorna uma lista de Ncm";
    PATH 'api/tsi/v1/tsiCommonExternalTariff/';
    TTALK "v1";
    WSSYNTAX "/tsiCommonExternalTariff";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET idTsiCommonExternalTariff;
    DESCRIPTION "Retorna um Ncm";
    PATH 'api/tsi/v1/tsiCommonExternalTariff/{id}';
    TTALK "v1";
    WSSYNTAX "/tsiCommonExternalTariff/?{sourceBranch}&{exNcm}";
    PRODUCES APPLICATION_JSON

    WSMETHOD POST tsiCommonExternalTariff; 
    DESCRIPTION "Inclui/altera uma lista de Ncm";
    PATH 'api/tsi/v1/tsiCommonExternalTariff/';
    TTALK "v1";
    WSSYNTAX "/tsiCommonExternalTariff";
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT tsiCommonExternalTariff;
    DESCRIPTION "Altera um Ncm";
    PATH 'api/tsi/v1/tsiCommonExternalTariff/{id}';
    TTALK "v1";
    WSSYNTAX "/tsiCommonExternalTariff";
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE tsiCommonExternalTariff;
    DESCRIPTION "Delete uma lista de Ncm";
    PATH 'api/tsi/v1/tsiCommonExternalTariff/';
    TTALK "v1";
    WSSYNTAX "/tsiCommonExternalTariff";
    PRODUCES APPLICATION_JSON 

END WSRESTFUL

/*
Metodo responsável por consultar o cadastro de Ncm ao TAF
@author Ricardo Lovrenovic    
@since 12/07/2021
@version 1.0 
*/ 

WSMETHOD GET tsiCommonExternalTariff WSREST TSIcommonExternalTariff

Local cJsonResp     As  character
Local cNcmDe        As  character
Local cNcmAte       As  character
Local cAlias        As  character
Local cOrder        As  character
Local xOrder        As  character
Local nPage         As  numeric 
Local nPageSize     As  numeric 
Local nStruct       As  numeric 
Local nPos          As  numeric
Local nPageAux      As  numeric
Local lHasNext      As  logical
Local aStruct       As  array
Local oHash         As  object
Local oJsonResp     As  object
Local cUrl          As  character
Local cField        As  character

cJsonResp :=  ''
cNcmDe    :=  ''
cNcmAte   :=  ''
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
oHash     := HashNcm( )
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

    If valtype( self:commonExternalTariffOf ) <> 'U' .and. !Empty(self:commonExternalTariffOf)
        cNcmDe := self:commonExternalTariffOf
    else
        cNcmDe := ' '
    endif

    If valtype( self:commonExternalTariffUp ) <> 'U' .and. !Empty(self:commonExternalTariffUp)
        cNcmAte := self:commonExternalTariffUp
    else
        cNcmAte := replicate('Z',8)
    endif

    cAlias  := GetQryNcm( cNcmDe, cNcmAte, nPage, nPageSize, cOrder )

    aStruct := ( cAlias )->( DBStruct( ) ) // Retorna a estrutura dos campos utilizados na query

    while (cAlias)->(!eof())
        
        nPageAux++

        if nPageAux == 1
            oJsonResp[cTagNcm] := {}
        endif

        if nPageAux <= nPageSize
            aAdd( oJsonResp[cTagNcm],JsonObject():New())
            nPos++

            for nStruct := 1 to len(aStruct)
                
                cField := alltrim( aStruct[nStruct][1] )

                //Busca Demais Campos
                if hmget( oHash, cField, @cTagJson ) .or. hmget( oHash, cField + "#F3#", @cTagJson )

                    if valtype( &('(cAlias)->'+aStruct[nStruct][1])) == 'C' 
                    
                        oJsonResp[cTagNcm][nPos][cTagJson] := Alltrim( &( '(cAlias)->' + cField ) )
                    
                    ElseIf valtype( &('(cAlias)->'+aStruct[nStruct][1])) == 'N' 
                    
                        oJsonResp[cTagNcm][nPos][cTagJson] := &( '(cAlias)->' + cField )
                    
                    EndIf
                    //tratamento para campos do tipo data
                
                elseif hmget( oHash, alltrim(aStruct[nStruct][1]) + "#DT#", @cTagJson ) 
                                
                    nPos := Len(oJsonResp[cTagNcm])
                   //é um campo data mas por algum motivo retornou caracter
                   if valtype( &('(cAlias)->'+aStruct[nStruct][1])) == 'C'                                   
                    oJsonResp[cTagNcm][nPos][cTagJson] := dtoc(stod( &('(cAlias)->'+aStruct[nStruct][1])))
                   else // tipo data
                     oJsonResp[cTagNcm][nPos][cTagJson] :=  dtoc(&('(cAlias)->'+aStruct[nStruct][1]))
                   endif
              
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
        SetErroJs( @oJsonResp, cTagNcm, , cUrl, '404' )
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
Metodo responsável por consultar o cadastro de Ncm ao TAF
@author Ricardo Lovrenovic    
@since 12/07/2021
@version 1.0
*/

WSMETHOD GET idTsiCommonExternalTariff QUERYPARAM sourceBranch, exNcm WSREST TSIcommonExternalTariff

Local cJsonResp As character
Local cNcmDe    As character
Local cAlias    As character
Local nStruct   As numeric
Local nPos      As numeric
Local nPageAux  As numeric
Local aStruct   As array
Local oHash     As object
Local oJsonResp As object
Local lOk       As logical
Local cUrl      As character
Local cField    As character

lOk         := valtype( self:id ) <> 'U' .and. !empty(self:id)
cJsonResp   := ''
cNcmDe      := iif(lOk,self:id," ")
lOk         := valtype( self:exNcm ) <> 'U' .and. !empty(self:exNcm)
cExNcm      := iif(lOk,self:exNcm," ")
cAlias      := ''
cTagJson    := ''
nStruct     := 1
nPos        := 0
nPageAux    := 0
aStruct     := {} 
oJsonResp	:= JsonObject():New()
oHash       := HashNcm( )
cUrl        := 'https://api.totvs.com.br/'
cField      := ""

if VldExecute( self:sourceBranch, @oJsonResp )
    DbSelectArea('C0A')
    cAlias  := GetQryNcm(cNcmDe, cNcmDe,,,,cExNcm) //filtra o unico Id

    aStruct := ( cAlias  )->( DBStruct( ) ) // Retorna a estrutura dos campos utilizados na query

    // coloco lOk como false para validar a exisitencia do registro na base
    lOk := .f.

    while (cAlias)->(!eof())
        lOk := .t.
        oJsonResp[cTagNcm] := {}

        aAdd( oJsonResp[cTagNcm], JsonObject():New() )
        nPos++

           for nStruct := 1 to len(aStruct)
                
                cField := alltrim( aStruct[nStruct][1] )

                //Busca Demais Campos
                if hmget( oHash, cField, @cTagJson ) .or. hmget( oHash, cField + "#F3#", @cTagJson )

                    if valtype( &('(cAlias)->'+aStruct[nStruct][1])) == 'C' 
                    
                        oJsonResp[cTagNcm][nPos][cTagJson] := Alltrim( &( '(cAlias)->' + cField ) )
                    
                    ElseIf valtype( &('(cAlias)->'+aStruct[nStruct][1])) == 'N' 
                    
                        oJsonResp[cTagNcm][nPos][cTagJson] := &( '(cAlias)->' + cField )
                    
                    EndIf
                    //tratamento para campos do tipo data
                
                elseif hmget( oHash, alltrim(aStruct[nStruct][1]) + "#DT#", @cTagJson ) 
                                
                    nPos := Len(oJsonResp[cTagNcm])
                   //é um campo data mas por algum motivo retornou caracter
                   if valtype( &('(cAlias)->'+aStruct[nStruct][1])) == 'C'                                   
                    oJsonResp[cTagNcm][nPos][cTagJson] := dtoc(stod( &('(cAlias)->'+aStruct[nStruct][1])))
                   else // tipo data
                     oJsonResp[cTagNcm][nPos][cTagJson] :=  dtoc(&('(cAlias)->'+aStruct[nStruct][1]))
                   endif
              
                endif

            Next nStruct

        (cAlias)->(DbSkip()) 
    enddo

    ( cAlias  )->( DBCloseArea( ) )

    if !lOk
        SetErroJs( @oJsonResp, cTagNcm, , cUrl, '404' )
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
Metodo responsável por persistir os dados de Ncm ao TAF
@author Ricardo Lovrenovic    
@since 12/07/2021
@version 1.0 
*/

WSMETHOD POST tsiCommonExternalTariff WSREST TSIcommonExternalTariff

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
            if  oBjJson:GetNames()[nGetNames] == cTagNcm
                TAFA565( HashNcm( ), aNames, nil, @aRetJs )

                oJsonResp[cTagNcm] := {}
                //Retorna possíveis erros que possam ter ocorrido na integração.
                SetErroJs(@oJsonResp, cTagNcm, @aRetJs,,'403')

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
Metodo responsável por persistir operações de alteração de cadastro Ncm ao TAF
@author Ricardo Lovrenovic    
@since 12/07/2021
@version 1.0
*/

WSMETHOD PUT tsiCommonExternalTariff WSREST TSIcommonExternalTariff

Local cJsonResp     As character
Local cSeek         As character
Local oBjJson       As object
Local oJsonResp	    As object
Local aRetJs        As array
Local nError        As numeric
Local nGetNames     As numeric
Local nJson         As numeric
Local aNames        As array
Local lOk           As logical
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
    cSeek := "C0A->(DbSeek(xfilial('C0A') + " + "'"+cSeekAux+"'))"
    // valida parâmetro counsceBranche
    if VldExecute( self:sourceBranch, @oJsonResp )
        cBody := self:GetContent( ) 
        oBjJson:fromJSON( cBody ) 

        if len(oBjJson:GetNames())>0
            for nGetNames := 1 to len( oBjJson:GetNames() )
                aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                if oBjJson:GetNames()[nGetNames] == cTagNcm
                    TAFA565( HashNcm( ), aNames, MODEL_OPERATION_UPDATE, @aRetJs, cSeek )
                endif
            next nGetNames
        else
            SetErroJs( @oJsonResp,,,,'400' )
        endif

        oJsonResp[cTagNcm] := {} 
        //Retorna possíveis erros que possam ter ocorrido na integração.
        SetErroJs(@oJsonResp, cTagNcm, @aRetJs, , '403', cSeekAux )    // garantia de retorno do id de acordo com a url       

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
Metodo responsável por persistir operações de deleção de cadastro Ncm ao TAF
@author Ricardo Lovrenovic    
@since 12/07/2021
@version 1.0 
*/ 

WSMETHOD DELETE tsiCommonExternalTariff WSREST TSIcommonExternalTariff

Local cJsonResp  As character
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
            if oBjJson:GetNames()[nGetNames] == cTagNcm
                TAFA565( HashNcm(), aNames, MODEL_OPERATION_DELETE, aRetJs )
            endif
        next nGetNames
    else
        SetErroJs( @oJsonResp,,,,'400' )
    endif

    oJsonResp[cTagNcm] := {}
    // adiciona mensagem de erro ao objeto oJsonResp de retorno   
    SetErroJs(@oJsonResp, cTagNcm, aRetJs,,'403' )       

endif

//------------------------------------------------------------------- 
// Serializa objeto Json 
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )

Return .T.


/*--------------------------------------------------------------------------------
{Protheus.doc} HashNcm()
(Cria Hash de "De|Para" do identificador do Json para o campo de gravação no TAF)
Ncm vinculo com o TAFA561
@author Ricardo Lovrenovic    
@since 12/07/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashNcm()

Local oHash   := HMNew( )
Local cTamNcm := lTrim(cValToChar(GetSx3Cache('C0A_CODIGO','X3_TAMANHO')))
Local cTamExNcm := lTrim(cValToChar(GetSx3Cache('C0A_EXNCM','X3_TAMANHO')))

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'  , 'MODEL_C0A')
HMSet(oHash, 's_o_u_r_c_e_', 'TAFA010'  )
HMSet(oHash, 'a_r_e_a_'    , 'C0A'      )
HMSet(oHash, 'o_r_d_e_r_'  , 1          ) //C0A_FILIAL, C0A_CODIGO, C0A_EXNCM, C0A_VALIDA, R_E_C_N_O_, D_E_L_E_T_
HMSet(oHash, 'k_e_y_'      , "aObjJson[nI]['commonExternalTariff'] + aObjJson[nI]['exceptionNcm']")
HMSet(oHash, 's_e_e_k_'    , "C0A->(DbSeek(xfilial('C0A') + padr(aObjJson[nI]['commonExternalTariff']," + cTamNcm + ") + padr(aObjJson[nI]['exceptionNcm']," + cTamExNcm + ")))")
HMSet(oHash, 't_a_g_i_d_'  , 'commonExternalTariff' )

// Propriedades e Campos
SetHashKey(oHash, 'id'                  , 'C0A_ID' )
SetHashKey(oHash, 'commonExternalTariff', 'C0A_CODIGO' )
SetHashKey(oHash, 'exceptionNcm'        , 'C0A_EXNCM'  )
SetHashKey(oHash, 'description'         , 'C0A_DESCRI' )
SetHashKey(oHash, 'percentual'          , 'C0A_PERNCM' )
SetHashKey(oHash, 'effectiveDate'       , 'C0A_VALIDA#DT#')
SetHashKey(oHash, 'stamp'               , 'C0A_STAMP'  )

Return oHash


/*--------------------------------------------------------------------------------
{Protheus.doc} GetQryNcm()
(Responsável por executar a consulta ao cadastro de Ncm)
@author Ricardo Lovrenovic    
@since 12/07/2021
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function GetQryNcm( cNcmDe, cNcmAte, nPage, nPageSize, cOrder, cExNcm )

Local cQry    := ''
Local cAlias  := getNextAlias()

Default cNcmDe     := ''
Default cNcmAte    := ''
Default cOrder     := ''
Default nPage      := 0
Default nPageSize  := 0
Default cExNcm     := ' '

if nPage == 0    ; nPage := 1                 ; endif
if nPageSize == 0; nPageSize := 10            ; endif
if Empty(cNcmAte); cNcmAte := replicate('Z',8); endif

cQry := " SELECT "
cQry += " 	C0A.C0A_CODIGO, "
cQry += " 	C0A.C0A_EXNCM, "
cQry += " 	C0A.C0A_DESCRI, "
cQry += " 	C0A.C0A_PERNCM, "
cQry += " 	C0A.C0A_VALIDA, "
cQry += " 	C0A.C0A_STAMP "
cQry += " FROM " + RetSqlName('C0A') + " C0A "
cQry += " WHERE C0A.D_E_L_E_T_ = ' ' "
cQry += " 	AND C0A.C0A_FILIAL = '" + xFilial('C0A') + "' "
cQry += " 	AND C0A.C0A_CODIGO BETWEEN '" + cNcmDe + "' AND '" + cNcmAte + "' "
cQry += " 	AND C0A.C0A_EXNCM = '" + cExNcm + "' "

if !empty(cOrder)
    cQry += " ORDER BY C0A."+cOrder
else
    cQry += " ORDER BY 1 "
endif

cQry += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nPageSize) + " ) ROWS "
cQry += " FETCH NEXT " + cValToChar(nPageSize+1) + " ROWS ONLY "

dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)

Return cAlias
