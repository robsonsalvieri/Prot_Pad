#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTagUM := 'unitOfMeasureCode'

/*-------------------------------------------------------------
WS para persisitencia do cadastro de unidade de medida ao TAF
@author Carlos Eduardo N. da Silva
@since 17/07/2020
@version 1.0
--------------------------------------------------------------*/
WSRESTFUL tsiUnitOfMeasureCode DESCRIPTION 'TAF Service Integration - Unidade de Medida'

WSDATA sourceBranch        as string
WSDATA page			       as integer optional
WSDATA pageSize 	       as integer optional 
WSDATA order               as string  optional
WSDATA unitOfMeasureCodeOf as string  optional
WSDATA unitOfMeasureCodeUp as string  optional
WSDATA id                  as string  optional


WSMETHOD GET tsiUnitOfMeasureCode;
    DESCRIPTION 'Retorna uma lista de Unidade de Medida';
    PATH 'api/tsi/v1/tsiUnitOfMeasureCode/';
    TTALK "v1";
    WSSYNTAX '/tsiUnitOfMeasureCode';
    PRODUCES APPLICATION_JSON

WSMETHOD GET idTsiUnitOfMeasureCode;
    DESCRIPTION 'Retorna uma Unidade de Medida';
    PATH 'api/tsi/v1/tsiUnitOfMeasureCode/{id}';
    TTALK "v1";
    WSSYNTAX '/tsiUnitOfMeasureCode';
    PRODUCES APPLICATION_JSON

WSMETHOD POST tsiUnitOfMeasureCode; 
    DESCRIPTION "Inclui/altera uma lista de Unidade de Medida";
    PATH 'api/tsi/v1/tsiUnitOfMeasureCode/';
    TTALK "v1";
    WSSYNTAX '/tsiUnitOfMeasureCode';
    PRODUCES APPLICATION_JSON

WSMETHOD PUT tsiUnitOfMeasureCode;
    DESCRIPTION 'Altera uma Unidade de Medida';
    PATH 'api/tsi/v1/tsiUnitOfMeasureCode/{id}';
    TTALK "v1";
    WSSYNTAX '/tsiUnitOfMeasureCode';
    PRODUCES APPLICATION_JSON

WSMETHOD DELETE tsiUnitOfMeasureCode;
    DESCRIPTION "Delete uma lista de Unidade de Medida";
    PATH 'api/tsi/v1/tsiUnitOfMeasureCode/';
    TTALK "v1";
    WSSYNTAX '/tsiNatureOfTheOperation';
    PRODUCES APPLICATION_JSON 

END WSRESTFUL 

/*-------------------------------------------------------------------
Metodo responsável por persistir os dados de Unidade de Medida ao TAF
@author Carlos Eduardo N. da Silva
@since 17/07/2020
@version 1.0 
---------------------------------------------------------------------*/ 
WSMETHOD POST tsiUnitOfMeasureCode WSREST tsiUnitOfMeasureCode
Local lRet := .t.
Local cJsonResp     := ""
Local oBjJson       := JsonObject():New() // Requisição
Local oJsonResp	    := JsonObject():New() // retorno
Local nGetNames     := 0
Local aNames        := {}
Local aRetJs        := {}

// valida parâmetro counsceBranche
if VldExecute( self:sourceBranch, @oJsonResp )
    cBody := self:GetContent( ) 
    oBjJson:fromJSON( cBody )
    if len(oBjJson:GetNames())>0
        for nGetNames := 1 to len(oBjJson:GetNames())
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if  oBjJson:GetNames()[nGetNames] == cTagUm
                TAFA565( HashUM(), aNames, nil, @aRetJs )

                oJsonResp[cTagUm] := { }

                //Retorna possíveis erros que possam ter ocorrido na integração.
                SetErroJs( @oJsonResp, cTagUm, @aRetJs,,'403' ) 
            endif
        next
    else
        SetErroJs( @oJsonResp,,,,'400' )
    endif
endif

// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )   

return lRet

/*---------------------------------------------------------------------------------------------
Metodo responsável por persistir operações de alteração de cadastro de Unidade de Medida ao TAF
@author Carlos Eduardo N. da Silva
@since 17/07/2020
@version 1.0 
----------------------------------------------------------------------------------------------*/ 
WSMETHOD PUT tsiUnitOfMeasureCode WSREST tsiUnitOfMeasureCode
Local lRet := .t.
Local cJsonResp     := ""
Local oBjJson       := JsonObject():New()
Local oJsonResp	    := JsonObject():New() 
Local nGetNames     := 0
Local aNames        := {}
Local aRetJs        := {}
Local lOk           := valtype( self:id ) <> 'U' .and. !empty(self:id)
Local cSeekAux      := ''
Local cSeek         := ''
Local nTamCodUM     := GetSx3Cache('C1J_CODIGO','X3_TAMANHO')
Local cUrl          := 'https://api.totvs.com.br/'

if lOk      
    cSeekAux := padr(self:id,nTamCodUM)
    cSeek :=  "C1J->(DbSeek(xfilial('C1J') + " + "'"+cSeekAux+"'))"         
    if VldExecute( self:sourceBranch, @oJsonResp )
        cBody := self:GetContent( ) 
        oBjJson:fromJSON( cBody )

        if len(oBjJson:GetNames())>0
            for nGetNames := 1 to len(oBjJson:GetNames())
                aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                if  oBjJson:GetNames()[nGetNames] == cTagUm
                    TAFA565( HashUM(), aNames, MODEL_OPERATION_UPDATE, @aRetJs, cSeek )
                endif
            next
        else
            SetErroJs( @oJsonResp,,,,'400' )
        endif    
        oJsonResp[cTagUm] := {}
        //Retorna possíveis erros que possam ter ocorrido na integração.
        SetErroJs( @oJsonResp, cTagUm, @aRetJs,, '403' )
    endif
else
    SetErroJs( @oJsonResp,,,cUrl,'401' )
endif    

// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )   

Return lRet

/*-------------------------------------------------------------------------------------------
Metodo responsável por persistir operações de deleção de cadastro da unidade de medida ao TAF
@author Carlos Eduardo N. da Silva
@since 21/07/2020
@version 1.0 
---------------------------------------------------------------------------------------------*/ 
WSMETHOD DELETE tsiUnitOfMeasureCode WSREST tsiUnitOfMeasureCode
Local lRet := .t.
Local cJsonResp  := ''
Local oBjJson    := JsonObject():New() 
Local oJsonResp	 := JsonObject():New() 
Local aRetJs     :=  {}
Local nGetNames  := 0
Local aNames     := {} 

if VldExecute( self:sourceBranch, @oJsonResp )
    cBody := self:GetContent( ) 
    oBjJson:fromJSON( cBody )
    if len(oBjJson:GetNames())>0
        for nGetNames := 1 to len(oBjJson:GetNames())
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if  oBjJson:GetNames()[nGetNames] == cTagUm
                TAFA565( HashUM(), aNames, MODEL_OPERATION_DELETE, aRetJs )
            endif
        next
    else
        SetErroJs( @oJsonResp,,,,'400' )
    endif
    oJsonResp[cTagUm] := {} 
    //Retorna possíveis erros que possam ter ocorrido na integração.
    SetErroJs( @oJsonResp, cTagUm, @aRetJs,, '403' ) 
endif

// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )   

Return lRet

/*---------------------------------------------------------------------
Metodo responsável por consultar o cadastro de Unidade de Medida ao TAF
@author Carlos Eduardo N. da Silva
@since 22/07/2020
@version 1.0 
---------------------------------------------------------------------*/ 
WSMETHOD GET tsiUnitOfMeasureCode WSREST tsiUnitOfMeasureCode
Local cJsonResp     as character
Local cItemDe       as character
Local cItemAte      as character
Local cAlias        as character
Local nPage         as numeric 
Local nPageSize     as numeric 
Local nStruct       as numeric 
Local nPos          as numeric
Local nPageAux      as numeric
Local lHasNext      as logical
Local aStruct       as array
Local oHash         as object
Local oJsonResp     as object
Local cOrder        as character
Local xOrder        as character
Local cUrl          as character

cJsonResp   :=  ''
cItemDe     :=  ' '
cItemAte    :=  replicate('Z',6)
cAlias      :=  ''
cTagJson    :=  ''
nPage       :=  0
nPageSize   :=  10
nStruct     :=  0
nPos        :=  0
nPageAux    :=  0
lHasNext    :=  .f.
aStruct     :=  {}
oJsonResp	:= JsonObject():New()
oHash := HashUM() 
cOrder    := ''
xOrder    := '' 
cUrl      := 'https://api.totvs.com.br/'

//Trata o parametro order caso o mesmo tenha sido passado.
if valtype( self:order ) != 'U'; xOrder := self:order; endif
hmget(oHash, xOrder, @cOrder)
if "#F3#" $ cOrder; cOrder := strtran(cOrder,'#F3#',''); endif

if VldExecute( self:sourceBranch, @oJsonResp )

    if valtype( self:unitOfMeasureCodeOf ) != 'U'; cItemDe  := self:unitOfMeasureCodeOf; endif
    if valtype( self:unitOfMeasureCodeUp ) != 'U'; cItemAte := self:unitOfMeasureCodeUp; endif

    if valtype( self:page ) != 'U' .and. self:page > 0
        nPage := self:page
        if valtype( self:pageSize ) != 'U' .and. self:pageSize > 0
            nPageSize := self:pageSize
        endif
    endif

    cAlias := GetUM(cItemDe, cItemAte, nPage, nPageSize, cOrder)
    
    aStruct := C1J->(DBStruct())
    aadd( aStruct ,GetAdvFVal('SX3',{'X3_CAMPO','X3_TIPO','X3_TAMANHO','X3_DECIMAL'},'CHJ_CODIGO',2))//Incluo campo da CHJ para tratar campo com F3
    
    while (cAlias)->(!eof())  
        nPageAux++
        if nPageAux == 1
            oJsonResp[cTagUm] := {}
        endif
        if nPageAux <= nPageSize
            aAdd( oJsonResp[cTagUm],JsonObject():New())
            nPos++
            for nStruct := 1 to len(aStruct)
                if hmget( oHash, alltrim(aStruct[nStruct][1]), @cTagJson )
                    oJsonResp[cTagUm][nPos][cTagJson] := alltrim(&('(cAlias)->'+aStruct[nStruct][1]))
                endif
            next
        else 
            lHasNext := .t. 
            exit
        endif
        (cAlias)->(DbSkip())
    enddo

    ( cAlias )->( DBCloseArea( ) )

    if nPageAux == 0
        SetErroJs( @oJsonResp, cTagUm, , cUrl, '404' )
    endif
endif

oJsonResp["hasnext"] := lHasNext

// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp ) 
Self:SetResponse( cJsonResp )   
freeobj(oJsonResp)
 
Return .t.

/*-----------------------------------------------------------
Metodo responsável por consultar o cadastro de produto ao TAF
@author Carlos Eduardo N. da Silva
@since 22/07/2020
@version 1.0 
-------------------------------------------------------------*/ 
WSMETHOD GET idTsiUnitOfMeasureCode WSREST tsiUnitOfMeasureCode
Local cJsonResp     as character
Local cAlias        as character
Local nStruct       as numeric 
Local nPos          as numeric
Local aStruct       as array
Local oHash         as object
Local oJsonResp     as object
Local lOk           as logical
Local cUrl          as character

lOk :=  valtype( self:id ) <> 'U' .and. !empty(self:id)
cJsonResp   :=  ''
cItemUm     :=  iif(lOk,self:id,' ')
cAlias      :=  ''
cTagJson    :=  ''
nStruct     :=  0
nPos        :=  0
aStruct     :=  {}
oJsonResp	:= JsonObject():New()
oHash := HashUM() 
cUrl := 'https://api.totvs.com.br/'

if VldExecute( self:sourceBranch, @oJsonResp )

    DbSelectArea('C1J')
    aStruct := C1J->(DBStruct())
    aadd( aStruct ,GetAdvFVal('SX3',{'X3_CAMPO','X3_TIPO','X3_TAMANHO','X3_DECIMAL'},'CHJ_CODIGO',2))//Incluo campo da CHJ para tratar campo com F3

    cAlias := GetUM(cItemUm)
    
    if (cAlias)->(eof())
        SetErroJs( @oJsonResp, cTagUm, , cUrl, '404' )
    else        
        while (cAlias)->(!eof())  
            oJsonResp[cTagUm] := {}
            aAdd( oJsonResp[cTagUm],JsonObject():New())
            nPos++
            for nStruct := 1 to len(aStruct)
                if hmget( oHash, alltrim(aStruct[nStruct][1]), @cTagJson )
                    oJsonResp[cTagUm][nPos][cTagJson] := alltrim(&('(cAlias)->'+aStruct[nStruct][1]))
                endif
            next
            (cAlias)->(DbSkip())
        enddo
    endif

    ( cAlias )->( DBCloseArea( ) )

endif

// Serializa objeto Json 
cJsonResp := FwJsonSerialize( oJsonResp ) 
Self:SetResponse( cJsonResp )   
freeobj(oJsonResp)
 
Return .t.

/*--------------------------------------------------------------------------------
{Protheus.doc} HashUM()
(Cria Hash de "De|Para" do identificador do Json para o campo de gravação no TAF)
@author Carlos Eduardo 
@since 16/07/2020
@return Nil, nulo, não tem retorno.
//------------------------------------------------------------------------------*/
Function HashUM() 
Local oHash     := HMNew( ) 
Local cTamCodUM := lTrim(cValToChar(GetSx3Cache('C1J_CODIGO','X3_TAMANHO')))
Local lGetUm    := IsInCallStack('GET_TSIUNITOFMEASURECODE') .or. IsInCallStack('GET_IDTSIUNITOFMEASURECODE')
Local cUmECF    := iif(lGetUm,'CHJ_CODIGO','C1J_IDUMEC')

// Infos genéricas
HMSet(oHash, 'm_o_d_e_l_'  , 'MODEL_C1J')
HMSet(oHash, 's_o_u_r_c_e_', 'TAFA055'  )
HMSet(oHash, 'a_r_e_a_'    , 'C1J'      )
HMSet(oHash, 'o_r_d_e_r_'  , 1          )
HMSet(oHash, 'k_e_y_'      , "aObjJson[nI]['unitOfMeasureCode']")
HMSet(oHash, 's_e_e_k_'    , "C1J->(DbSeek(xfilial('C1J') + padr(aObjJson[nI]['unitOfMeasureCode']," + cTamCodUM + ")))")
HMSet(oHash, 't_a_g_i_d_'  , cTagUm)

// Propriedades e Campos
SetHashKey(oHash,cTagUm, 'C1J_CODIGO'   )
SetHashKey(oHash,'description'      , 'C1J_DESCRI'  )
SetHashKey(oHash,'unitOfMeasureECF' , cUmECF+'#F3#' )
if !lGetUm; SetHashKey(oHash,'stamp'            , 'C1J_STAMP'   ); endif    

// #F3#
HMSet(oHash, '#F3#'+cUmECF, "GetTafId( 'CHJ', cChave, 2 )") 

Return oHash    

/*--------------------------------------------------------------------
{Protheus.doc} GetUM()
(Responsável por executar a consulta ao cadastro de Unidade de Medida)
@author Carlos Eduardo
@since 07/07/2020
@return Nil, nulo, não tem retorno.
//-------------------------------------------------------------------*/
Static function GetUM(cUmDe, cUmAte, nPage, nPageSize, cOrder)
Local cQuery := '' 
Local cAlias := getNextAlias()
Local lGetId := IsInCallStack('GET_IDTSIUNITOFMEASURECODE')

cQuery := " SELECT "
cQuery += " 	C1J.C1J_CODIGO, "
cQuery += " 	C1J.C1J_DESCRI, "
cQuery += " 	CHJ.CHJ_CODIGO  "
cQuery += " FROM " + RetSqlName('C1J') + " C1J "
cQuery += " 	LEFT JOIN " + RetSqlName('CHJ') + " CHJ ON CHJ.CHJ_FILIAL = '" + xFilial('CHJ') + "' AND CHJ.CHJ_ID = C1J.C1J_IDUMEC AND CHJ.D_E_L_E_T_ = ' ' "
cQuery += " WHERE C1J.D_E_L_E_T_ = ' '
cQuery += " 	AND C1J.C1J_FILIAL = '" + xFilial('C1J') + "' "

if lGetId
    cQuery += "     AND C1J.C1J_CODIGO = '" + cUmDe + "' "
else
    if nPage == 0    ; nPage := 1                 ; endif
    if nPageSize == 0; nPageSize := 10            ; endif
    if Empty(cUmAte) ; cUmAte := replicate('Z',6) ; endif

    if Empty(cOrder) 
        cOrder := "C1J.R_E_C_N_O_" 
    else
        cOrder := left(cOrder,3)+'.'+cOrder //Alias da tabela + campo
    endif    
    cQuery += "     AND C1J.C1J_CODIGO BETWEEN '" + cUmDe + "' AND '" + cUmAte + "' "
    cQuery += " ORDER BY " + cOrder
    cQuery += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nPageSize) + " ) ROWS "
    cQuery += " FETCH NEXT " + cValToChar(nPageSize+1) + " ROWS ONLY "
endif        
dbUseArea(.T., "TOPCONN", TCGenQry(, , cQuery), cAlias, .F., .T.)  

Return cAlias