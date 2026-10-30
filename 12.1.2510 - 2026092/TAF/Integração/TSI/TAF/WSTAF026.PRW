#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSTAF025.CH"
#INCLUDE "FWMVCDEF.CH"
/*/{Protheus.doc} WSTAF025
WS para persisitencia do cadastro de produto ao TAF

@author Henrique Fabiano Pateno Pereira    
@since 03/07/2020
@version 1.0
*/

WSRESTFUL tsiitem DESCRIPTION "Api de persistência ao produto" 
	
    WSDATA sourceBranch  as string
    WSDATA page			 as integer	optional
	WSDATA pageSize 	 as integer	optional 
    WSDATA order         as string  optional
    WSDATA itemDe        as string  optional 
    WSDATA itemAte       as string  optional
    WSDATA id            as string  optional 
  
	WSMETHOD GET tsiitem;
    DESCRIPTION "Método de consulta aos cadastros ";
    PATH 'api/tsi/v1/tsiitem/';
    TTALK "tsiitem";
    WSSYNTAX "/tsiitem";
    PRODUCES APPLICATION_JSON 

    WSMETHOD GET idtsiitem;
    DESCRIPTION "Método de consulta aos cadastros ";
    PATH 'api/tsi/v1/tsiitem/{id}';
    TTALK "idTsiitem";
    WSSYNTAX "/tsiitem";
    PRODUCES APPLICATION_JSON  

    WSMETHOD POST   tsiItem;
    DESCRIPTION "Método de inclusão ";
    PATH 'api/tsi/v1/tsiitem/';
    TTALK "tsiitem";
    WSSYNTAX "/tsiitem";
    PRODUCES APPLICATION_JSON 

    WSMETHOD PUT    tsiItem;
    DESCRIPTION "Método de alteração " ;
    PATH 'api/tsi/v1/tsiitem/{id}';
    TTALK "tsiitem";
    WSSYNTAX "/tsiitem";
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE tsiItem; 
    DESCRIPTION "Método de deleção";
    PATH 'api/tsi/v1/tsiitem/';
    TTALK "tsiitem";
    WSSYNTAX "/tsiitem"; 
    PRODUCES APPLICATION_JSON 

END WSRESTFUL 

/*
Metodo responsável por consultar o cadastro de produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 03/07/2020
@version 1.0 
*/ 

WSMETHOD GET tsiitem WSREST tsiitem 
    Local cJsonResp     as character
    Local cItemDe       as character
    Local cItemAte      as character 
    Local cAlias        as character
    Local cOrder        as character
    Local xOrder        as character
    Local cTabSearch    as character
    Local cCmpSearch    as character
    Local cUrl          as character
    Local nPage         as numeric 
    Local nPageSize     as numeric 
    Local nStruct       as numeric 
    Local nPos          as numeric
    Local nPageAux      as numeric
    Local nIndSearch    as numeric
    Local lHasNext      as logical
    Local aStruct       as array
    Local oHash         as object
    Local oJsonResp     as object
    Local cField        as character
    Local xVal 

    cJsonResp   :=  ''
    cItemDe     :=  iif(valtype( self:itemDe ) <> 'U' .and. !empty(self:itemDe),self:itemDe," ")
    cItemAte    :=  iif(valtype( self:itemAte ) <> 'U' .and. !empty(self:itemAte),self:itemAte,"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")
    cAlias      :=  ''
    cTagJson    :=  ''
    xOrder      :=  ''
    cOrder      :=  ''
    cTabSearch  :=  ''
    cCmpSearch  :=  ''
    cUrl        := 'https://api.totvs.com.br/'
    cField      := ''
    nPage       :=  0
    nPageSize   :=  10
    nStruct     :=  0
    nPos        :=  0
    nPageAux    :=  0
    nIndSearch  :=  0
    lHasNext    :=  .f.
    aStruct     :=  {}
    oJsonResp	:= JsonObject():New()
    oHash := HashITEM( )
    xOrder  :=  iif(valtype( self:order ) <> 'U' .and. !empty(self:order),self:order," ")  

    hmget( oHash, xOrder,@cOrder)
        
    if '#F3#'$cOrder
        cOrder  :=   SubStr( cOrder, 1, Len( cOrder ) - 4 )
    endif

    if VldExecute( self:sourceBranch, @oJsonResp )
        
        If valtype( self:page ) <> 'U' .and. self:page > 0
            nPage := self:page
            if valtype( self:pageSize ) <> 'U' .and. self:pageSize > 0
                nPageSize := self:pageSize
            endif
        endif

        cAlias := getItem( cItemDe, cItemAte, nPage, nPageSize, cOrder )
        
        aStruct := ( cAlias )->( DBStruct( ) ) // Retorna a estrutura dos campos utilizados na query
        while (cAlias)->(!eof())  
            nPageAux++
                
            if nPageAux == 1
                oJsonResp["item"] := {}
            endif
            
            if nPageAux < nPageSize+1 

                aAdd( oJsonResp["item"], JsonObject( ):New( ) )
                nPos++

                for nStruct := 1 to len( aStruct )

                    cField := alltrim( aStruct[nStruct][1] )

                    if hmget( oHash, cField, @cTagJson ) .or. hmget( oHash, cField + "#F3#", @cTagJson )

                        xVal := &( '(cAlias)->' + cField )

                        if valtype( xVal ) == 'N'
                            oJsonResp["item"][nPos][cTagJson] := xVal
                        else
                            oJsonResp["item"][nPos][cTagJson] := alltrim( xVal ) 
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
            SetErroJs( @oJsonResp, "item", , cUrl, '404' )
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
Metodo responsável por consultar o cadastro de produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 15/07/2020
@version 1.0 
*/ 

WSMETHOD GET idtsiitem WSREST tsiitem

    Local cJsonResp     as character
    Local cItemDe       as character
    Local cAlias        as character 
    Local cUrl          as character
    Local nStruct       as numeric 
    Local nPos          as numeric
    Local nPageAux      as numeric 
    Local nIndSearch    as numeric
    Local cTabSearch    as character
    Local cCmpSearch    as character
    Local aStruct       as array 
    Local oHash         as object
    Local oJsonResp     as object
    Local lOk           as logical
    Local cField        as character
    Local xVal

    lOk :=  valtype( self:id ) <> 'U' .and. !empty(self:id)
    cJsonResp   :=  ''
    cItemDe     :=  iif(lOk,self:id," ")
    cAlias      :=  ''
    cTagJson    :=  ''
    cTabSearch  :=  ''
    cCmpSearch  :=  ''
    cUrl        :=  'https://api.totvs.com.br/'
    nIndSearch  :=  0                                
    nStruct     :=  0
    nPos        :=  0
    nPageAux    :=  0
    aStruct     :=  {} 
    oJsonResp	:= JsonObject():New()
    oHash := HashITEM( )
        
    if VldExecute( self:sourceBranch, @oJsonResp )
        DbSelectArea('C1L')
        cAlias := getItem(cItemDe, cItemDe)
        
        aStruct := ( cAlias )->( DBStruct( ) ) // Retorna a estrutura dos campos utilizados na query
        
        if (cAlias)->(eof())
            SetErroJs( @oJsonResp, "item", , cUrl, '404' )
        else
        
            while (cAlias)->(!eof()) 
                nPageAux++
                    
                if nPageAux == 1
                    oJsonResp["item"] := {}
                endif
        
                aAdd( oJsonResp["item"], JsonObject( ):New( ) )
                nPos++
                
                for nStruct := 1 to len(aStruct)
                
                    cField := alltrim( aStruct[nStruct][1] )

                    if hmget( oHash, cField, @cTagJson ) .or. hmget( oHash, cField + "#F3#", @cTagJson )

                        xVal := &( '(cAlias)->' + cField )

                        if valtype( xVal ) == 'N'
                            oJsonResp["item"][nPos][cTagJson] := xVal
                        else
                            oJsonResp["item"][nPos][cTagJson] := alltrim( xVal ) 
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
    lOk         :=  .f.

Return .t.
/*
Metodo responsável por persistir os dados de produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 03/07/2020
@version 1.0 
*/ 
 
WSMETHOD POST tsiItem WSREST TSIITEM 
 
Local cJsonResp     := ""
Local oBjJson       := JsonObject():New() // Requisição
Local oJsonResp	    := JsonObject():New() // retorno
Local nGetNames     := 0
Local aRetJs        := {} 
Local aNames        := {} 

        if VldExecute( self:sourceBranch, @oJsonResp )
            cBody := self:GetContent( ) 
            oBjJson:fromJSON( cBody )
            
            if len(oBjJson:GetNames())>0
                for nGetNames := 1 to len(oBjJson:GetNames())
                    aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                    if  oBjJson:GetNames()[nGetNames] == 'item'
                        TAFA565( HashITEM( ), aNames, nil, @aRetJs )
                    endif
                     if nGetnames == 1
                        oJsonResp['item'] := { } 
                    endif 
                   //Retorna possíveis erros que possam ter ocorrido na integração.
                    SetErroJs( @oJsonResp, "item", @aRetJs,,'403' ) 
   
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
Metodo responsável por persistir operações de alteração de cadastro produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 03/07/2020
@version 1.0 
*/ 

WSMETHOD PUT tsiItem WSREST TSIITEM 
Local cJsonResp     as character
Local cSeek         as character
Local cUrl          as character
Local oBjJson       as object
Local oJsonResp	    as object
Local aRetJs        as array
Local nGetNames     as numeric
Local nJson         as numeric
Local aNames        as array
Local lOk           as logical
   
cJsonResp   := ""
cUrl        := 'https://api.totvs.com.br/'
oBjJson     := JsonObject():New()
oJsonResp	:= JsonObject():New() 
aRetJs      := {}
nGetNames   := 0
nJson       := 0
aNames      := {}
lOk         := valtype( self:id ) <> 'U' .and. !empty(self:id)

if lOk
    cSeekAux := self:id
    cSeek :=  "C1L->(DbSeek(xfilial('C1L') + " + "'"+cSeekAux+"'))" 
    if VldExecute( self:sourceBranch, @oJsonResp )
        cBody := self:GetContent( ) 
        oBjJson:fromJSON( cBody )

        if len(oBjJson:GetNames())>0 
            for nGetNames := 1 to len(oBjJson:GetNames())
                aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                if  oBjJson:GetNames()[nGetNames] == 'item'
                    TAFA565( HashITEM( ), aNames, MODEL_OPERATION_UPDATE, @aRetJs, cSeek )
                endif
            next
        else
            SetErroJs( @oJsonResp,,,,'400' )
        endif
        oJsonResp['item'] := {}
        // adiciona mensagem de erro ao objeto oJsonResp de retorno   
        SetErroJs( @oJsonResp, "item", @aRetJs,, '403', cSeekAux )         
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
Return .t.

/*
Metodo responsável por persistir operações de deleção de cadastro produto ao TAF
@author Henrique Fabiano Pateno Pereira
@since 03/07/2020
@version 1.0 
*/ 

WSMETHOD DELETE tsiItem WSREST TSIITEM 
Local cJsonResp     as character
Local oBjJson       := JsonObject():New() 
Local oJsonResp	    := JsonObject():New() 
Local nGetNames     := 0
Local aNames        := {} 
Local aRetJs        := {}

cJsonResp     := ""

if VldExecute( self:sourceBranch, @oJsonResp )
    cBody := self:GetContent( ) 
    oBjJson:fromJSON( cBody )
    if len(oBjJson:GetNames())>0
        for nGetNames := 1 to len(oBjJson:GetNames())
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if  oBjJson:GetNames()[nGetNames] == 'item'
                TAFA565( HashITEM( ), aNames, MODEL_OPERATION_DELETE, @aRetJs )         
            endif
        next
    else
        SetErroJs( @oJsonResp,,,,'400' )   
    endif 
    oJsonResp["item"] := {} 
    //Retorna possíveis erros que possam ter ocorrido na integração.
    SetErroJs( @oJsonResp, "item", @aRetJs,, '403' )
endif

//------------------------------------------------------------------- 
// Serializa objeto Json 
//-------------------------------------------------------------------
cJsonResp := FwJsonSerialize( oJsonResp )
Self:SetResponse( cJsonResp )   

Return .t.

/*/{Protheus.doc} HashITEM
Função responsável por montar o HashMap que será utilizado para:
1o Armazenar informações necessárias para a gravação do json em MVC
2o Realizar o De-Para entre propriedades json e campos do TAF
    Esse "De-Para" será utilizado para:
    - Persistir o json recebido no MVC ( permitindo assim validar a estrutura json em tempo de persitência no MVC ) e 
    - Caso ocorra erro de commit no MVC, permitirá gravar tabela de log V5R com mensagem amigavéis, pois saberemos qual campo do TAF corresponde a propriedade json com erro.
3o Macro execução de pesquisa F3 de campos que precisam realizar "De-Para" para o Id do TAF

@author Henrique Fabiano Pateno Pereira
@author Wesley Pinheiro
@since 01/07/2020
@version 1.0 
*/ 
Function HashITEM( ) 

    Local oHash := HMNew( )

    Local cTamKey := cValToChar( GetSx3Cache( "C1L_CODIGO", "X3_TAMANHO" ) )
    
    // Infos genéricas
    HMSet( oHash, "m_o_d_e_l_"   , "MODEL_C1L"   )
    HMSet( oHash, "s_o_u_r_c_e_" , "TAFA057"     )
    HMSet( oHash, "a_r_e_a_"     , "C1L"         )
    HMSet( oHash, "o_r_d_e_r_"   , 1             )
    HMSet( oHash, "k_e_y_"       , "aObjJson[nI]['itemId']" )
    HMSet( oHash, "s_e_e_k_"     , "C1L->( DbSeek( xfilial( 'C1L') + padr( cKey, " + cTamKey + " ) ) )" )
    HMSet( oHash, "t_a_g_i_d_"   , "itemId"      )
 
    // Propriedades e Campos                               // Campos da Planilha Layout TAF - T007
    SetHashKey( oHash, "itemId"       , "C1L_CODIGO"     ) // 02 COD_ITEM 
    SetHashKey( oHash, "description"  , "C1L_DESCRI"     ) // 03 DESCR_ITEM
    SetHashKey( oHash, "unit"         , "C1L_UM#F3#"     ) // 05 UNID_INV
    SetHashKey( oHash, "itemType"     , "C1L_TIPITE#F3#" ) // 06 TIPO_ITEM
    SetHashKey( oHash, "idNcm"        , "C1L_CODNCM#F3#" ) // 07 COD_NCM
    SetHashKey( oHash, "serviceId"    , "C1L_CODSER#F3#" ) // 10 COD_LST
    SetHashKey( oHash, "originId"     , "C1L_ORIMER#F3#" ) // 14 ORIGEM
    SetHashKey( oHash, "icmsRate"     , "C1L_ALQICM"     ) // 16 ALIQ_ICMS
    SetHashKey( oHash, "ipiRate"      , "C1L_ALQIPI"     ) // 18 ALIQ_IPI
    SetHashKey( oHash, "serviceTypeId", "C1L_IDTSER#F3#" ) // 29 TIP_SERV
    SetHashKey( oHash, "stamp"        , "C1L_STAMP"      )
 
    // #F3#
    HMSet( oHash, "#F3#C1L_UM"       , "GetTafId( 'C1J', cChave, 1 )" ) 
    HMSet( oHash, "#F3#C1L_TIPITE"   , "GetTafId( 'C2M', cChave, 1 )" ) 
    HMSet( oHash, "#F3#C1L_CODNCM"   , "GetTafId( 'C0A', cChave, 1 )" ) 
    HMSet( oHash, "#F3#C1L_CODSER"   , "GetTafId( 'C0B', cChave, 1 )" ) 
    HMSet( oHash, "#F3#C1L_ORIMER"   , "GetTafId( 'C03', cChave, 1 )" )
    HMSet( oHash, "#F3#C1L_IDTSER"   , "GetTafId( 'C8C', cChave, 4 )" )

Return oHash

/*
Função responsável por executar a consulta ao cadastro de produto
@author Henrique Fabiano Pateno Pereira
@since 01/07/2020
@version 1.0 
*/ 
function getItem( cItemDe, cItemAte, nPage, nPageSize, cOrder )
Local cQry          := ''
Local cAlias        := getNextAlias()  
Default cItemDe     :=  ''
Default cItemAte    :=  ''
Default cOrder      :=  ''
Default nPage       := 0 
Default nPageSize   := 0 

cQry :=  GetItemQry(cItemDe, cItemAte, nPage, nPageSize, cOrder)    

dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)

Return cAlias

/*
Função responsável por montar a consulta ao cadastro de produto
@author Henrique Fabiano Pateno Pereira
@since 01/07/2020
@version 1.0 
*/ 

static function GetItemQry(cItemDe, cItemAte, nPage, nPageSize, cOrder)

    Local cQry := ''

    if nPage == 0
        nPage := 1
    endif

    if nPageSize == 0
        nPageSize := 10
    endif
    if Empty(cItemAte)
        cItemAte := 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'
    endif

    cQry  += " SELECT "
    cQry  += " C1L.C1L_CODIGO "
    cQry  += " ,C1L.C1L_DESCRI "
    cQry  += " ,C1L.C1L_ALQICM "
    cQry  += " ,C1L.C1L_ALQIPI "
    cQry  += " ,C1J.C1J_CODIGO C1L_UM "
    cQry  += " ,C2M.C2M_CODIGO C1L_TIPITE "
    cQry  += " ,C0A.C0A_CODIGO C1L_CODNCM "
    cQry  += " ,C0B.C0B_CODIGO C1L_CODSER "
    cQry  += " ,C03.C03_CODIGO C1L_ORIMER "
    cQry  += " ,C8C.C8C_CREINF C1L_IDTSER "
    cQry  += " ,C1L.C1L_STAMP  
    cQry  += " FROM "
    cQry  += RetSqlName( "C1L" ) + " C1L "

    // Unidade de medida
    cQry  += " LEFT JOIN "
    cQry  += RetSqlName( "C1J" ) + " C1J "
    cQry  += " ON C1J.C1J_FILIAL = '" + xFilial( "C1J" ) + "' "
    cQry  += " AND C1L.C1L_UM = C1J.C1J_ID "
    cQry  += " AND C1L.D_E_L_E_T_ = C1J.D_E_L_E_T_ "

    // Tipo de Item
    cQry  += " LEFT JOIN "
    cQry  += RetSqlName( "C2M" ) + " C2M "
    cQry  += " ON C2M.C2M_FILIAL = '" + xFilial( "C2M" ) + "' "
    cQry  += " AND C1L.C1L_TIPITE = C2M.C2M_ID "
    cQry  += " AND C1L.D_E_L_E_T_ = C2M.D_E_L_E_T_ "

    // NCM
    cQry  += " LEFT JOIN "
    cQry  += RetSqlName( "C0A" ) + " C0A "
    cQry  += " ON C0A.C0A_FILIAL = '" + xFilial( "C0A" ) + "' "
    cQry  += " AND C1L.C1L_CODNCM = C0A.C0A_ID "
    cQry  += " AND C1L.D_E_L_E_T_ = C0A.D_E_L_E_T_ "

    // Código de Serviço Federal
    cQry  += " LEFT JOIN "
    cQry  += RetSqlName( "C0B" ) + " C0B "
    cQry  += " ON C0B.C0B_FILIAL = '" + xFilial( "C0B" ) + "' "
    cQry  += " AND C1L.C1L_CODSER = C0B.C0B_ID "
    cQry  += " AND C1L.D_E_L_E_T_ = C0B.D_E_L_E_T_ "

    // Origem da mercadoria
    cQry  += " LEFT JOIN "
    cQry  += RetSqlName( "C03" ) + " C03 "
    cQry  += " ON C03.C03_FILIAL = '" + xFilial( "C03" ) + "' "
    cQry  += " AND C1L.C1L_ORIMER = C03.C03_ID "
    cQry  += " AND C1L.D_E_L_E_T_ = C03.D_E_L_E_T_ "

    // Tipo de serviço da fatura/recibo
    cQry  += " LEFT JOIN "
    cQry  += RetSqlName( "C8C" ) + " C8C "
    cQry  += " ON C8C.C8C_FILIAL = '" + xFilial( "C8C" ) + "' "
    cQry  += " AND C1L.C1L_IDTSER = C8C.C8C_ID "
    cQry  += " AND C1L.D_E_L_E_T_ = C8C.D_E_L_E_T_ "

    cQry  += " WHERE C1L.C1L_FILIAL = '" + xFilial( "C1L" ) + "' "
    cQry  += " AND C1L.C1L_CODIGO BETWEEN '" + cItemDe + "' AND '" + cItemAte + "' "
    cQry  += " AND C1L.D_E_L_E_T_ = ' ' "

    if !empty( cOrder )
        cQry  += " ORDER BY C1L." + cOrder 
    else
        cQry  += " ORDER BY 1 "
    endif
    cQry  += " OFFSET ( " + cValToChar( nPage - 1 ) + " * " + cValToChar( nPageSize ) + " ) ROWS "
    cQry  += " FETCH NEXT " + cValToChar( nPageSize + 1 ) + " ROWS ONLY "
    
Return cQry