#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

static cTagMain := "addInformation"
static cUrl     := 'https://api.totvs.com.br/'

/*/{Protheus.doc} TSIADDINFORMATION
WS para persisitencia do cadastro de Informações Complementares do TAF

@author Wesley Pinheiro
@since 09/11/2020
@version 1.0 
*/

WSRESTFUL TSIADDINFORMATION DESCRIPTION "Api de persistência do Cadastro de Informações Complementares"

    WSDATA sourceBranch  As String
    WSDATA page			 As Integer	Optional
	WSDATA pageSize 	 As Integer	Optional
    WSDATA order         As String  Optional
    WSDATA idFrom        As String  Optional
    WSDATA idTo          As String  Optional
    WSDATA id            As String  optional
    WSDATA lGetId        As Boolean optional

    WSMETHOD GET tsiAddInformation;
    DESCRIPTION "Retorna uma lista de Informações Complementares";
    PATH "api/tsi/v1/tsiAddInformation/";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiAddInformation/";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET idTsiAddInformation;
    DESCRIPTION "Retorna o cadastro uma Informação Complementar";
    PATH "api/tsi/v1/tsiAddInformation/{id}";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiAddInformation/{id}";
    PRODUCES APPLICATION_JSON

    WSMETHOD POST tsiAddInformation; 
    DESCRIPTION "Inclui/altera uma lista de Informações Complementares";
    PATH "api/tsi/v1/tsiAddInformation/";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiAddInformation/";
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT tsiAddInformation;
    DESCRIPTION "Altera Informação Complementar";
    PATH "api/tsi/v1/tsiAddInformation/";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiAddInformation/";
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE tsiAddInformation; 
    DESCRIPTION "Deleta uma lista de Informações Complementares";
    PATH "api/tsi/v1/tsiAddInformation/";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiAddInformation/";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

/*
Metodo responsável por consultar o cadastro de Informações Complementares ao TAF
@author Wesley Pinheiro
@since 09/11/2020
@version 1.0 
*/
WSMETHOD GET tsiAddInformation WSRECEIVE sourceBranch, idFrom, idTo, page, pageSize, order WSREST TSIADDINFORMATION

    self:lGetId := .F.

Return GetLstAddInf( self )

/*
Metodo responsável por consultar o cadastro de Informações Complementares ao TAF
@author Wesley Pinheiro
@since 09/11/2020
@version 1.0 
*/
WSMETHOD GET idTsiAddInformation WSRECEIVE sourceBranch PATHPARAM id WSREST TSIADDINFORMATION

    self:lGetId := .T.

Return GetLstAddInf( self )

/*
Metodo responsável por consultar o cadastro de Informações Complementares ao TAF
@author Wesley Pinheiro
@since 09/11/2020
@version 1.0 
*/
Static Function GetLstAddInf( oRest )

    Local cJsonResp     as character
    Local cAlias        as character
    Local nStruct       as numeric 
    Local nPos          as numeric
    Local nPageAux      as numeric
    Local lHasNext      as logical
    Local lOK           as logical
    Local aStruct       as array
    Local oHash         as object
    Local oJsonResp     as object
    Local nQtdReg       as Numeric
    Local cField        as character

    cJsonResp   := ''
    cAlias      := ''
    cTagJson    := ''
    nStruct     := 0
    nPos        := 0
    nPageAux    := 0
    lHasNext    := .f.
    lOK         := .F.
    aStruct     := { }
    oJsonResp	:= JsonObject():New( )
    oHash       := HashAddInf( )
    cField      := ""

    if VldExecute( oRest:sourceBranch, @oJsonResp )

        TsiQryPar( oRest, @nQtdReg )

        If valtype( oRest:order ) == 'U' .or. Empty( oRest:order )
            oRest:order := " "
        endif

        cAlias := getAddInfo( oRest )
        aStruct := ( cAlias )->( DBStruct( ) )

        while ( cAlias )->( !eof( ) )
            nPageAux++

            if nPageAux == 1
                oJsonResp[cTagMain] := { }
            endif

            /* 
                nQtdReg -> Variável utilizada para controlar se a query retornou um registro a mais da quantidade solicitada ( nPageSize ),
                indicando assim a necessidade de uma outra página ( hasnext == true )
            */
            if nPageAux < ( nQtdReg )

                aAdd( oJsonResp[cTagMain], JsonObject( ):New( ) )

                for nStruct := 1 to len( aStruct )

                    cField := alltrim( aStruct[nStruct][1] )

                    if  hmget( oHash, cField, @cTagJson )

                        nPos := Len( oJsonResp[cTagMain] )
                        oJsonResp[cTagMain][nPos][cTagJson] := Alltrim( &( '(cAlias)->' + cField ) )
                        
                    endif

                Next nStruct

            else
                lHasNext := .t.
                exit    
            endif
            ( cAlias )->( DbSkip( ) )
        enddo

        ( cAlias )->( DBCloseArea( ) )

    endif

    lOK := TsiLstResp( oRest, oJsonResp, lHasNext )

Return lOK
/*
Metodo responsável por persistir os dados de Informações Complementares ao TAF
@author Wesley Pinheiro
@since 09/11/2020
@version 1.0
*/

WSMETHOD POST tsiAddInformation WsReceive sourceBranch WSREST TSIADDINFORMATION

    Local cJsonResp := ""
    Local oBjJson   := JsonObject( ):New( ) // Requisição
    Local oJsonResp := JsonObject( ):New( ) // retorno
    Local nGetNames := 0
    Local aRetJs    := { }
    Local aNames    := { }

    if VldExecute( self:sourceBranch, @oJsonResp )
        cBody := self:GetContent( )
        oBjJson:fromJSON( cBody )

        if len( oBjJson:GetNames( ) ) > 0
            for nGetNames := 1 to len( oBjJson:GetNames( ) )
                aNames := oBjJson:GetJsonObject( oBjJson:GetNames( )[nGetNames] )
                if oBjJson:GetNames( )[nGetNames] == cTagMain
                    TAFA565( HashAddInf( ), aNames, nil, @aRetJs )
                endif
            next nGetNames
        else
            SetErroJs( @oJsonResp,,,,'400' )
        endif

        oJsonResp[cTagMain] := {}
        // adiciona mensagem de erro ao objeto oJsonResp de retorno   
        SetErroJs(@oJsonResp, cTagMain, @aRetJs,,"403" )
    else
        SetErroJs( @oJsonResp,,,cUrl,'401' )
    endif

    //-------------------------------------------------------------------
    // Serializa objeto Json
    //-------------------------------------------------------------------
    cJsonResp := FwJsonSerialize( oJsonResp )
    Self:SetResponse( cJsonResp )

return .T.

/*
Metodo responsável por persistir operações de alteração do cadastro de Informações Complementares ao TAF
@author Wesley Pinheiro
@since 09/11/2020
@version 1.0 
*/ 

WSMETHOD PUT tsiAddInformation WSRECEIVE sourceBranch WSREST TSIADDINFORMATION

    Local cJsonResp := ""
    Local oBjJson   := JsonObject():New()
    Local oJsonResp	:= JsonObject():New()
    Local aRetJs    := {}
    Local nGetNames := 0
    Local aNames    := {}

    if VldExecute( self:sourceBranch, @oJsonResp )
        cBody := self:GetContent( )
        oBjJson:fromJSON( cBody )

        if len(oBjJson:GetNames())>0
            for nGetNames := 1 to len(oBjJson:GetNames())
                oJsonResp['success'] := .t.
                aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                if oBjJson:GetNames()[nGetNames] == cTagMain
                    TAFA565( HashAddInf( ), aNames, MODEL_OPERATION_UPDATE, @aRetJs )
                endif
            next nGetNames
        else
            SetErroJs( @oJsonResp,,,,'400' )
        endif

        oJsonResp[cTagMain] := {}
        // adiciona mensagem de erro ao objeto oJsonResp de retorno   
        SetErroJs(@oJsonResp, cTagMain, @aRetJs,,"403" )
    else
        SetErroJs( @oJsonResp,,,cUrl,'401' )
    endif

    //-------------------------------------------------------------------
    // Serializa objeto Json
    //-------------------------------------------------------------------
    cJsonResp := FwJsonSerialize( oJsonResp )
    Self:SetResponse( cJsonResp )

Return .t.

/*
Metodo responsável por persistir operações de deleção do cadastro de Informações Complementares ao TAF
@author Wesley Pinheiro
@since 09/11/2020
@version 1.0 
*/

WSMETHOD DELETE tsiAddInformation WSRECEIVE sourceBranch WSREST TSIADDINFORMATION

    Local cJsonResp := ""
    Local oBjJson   := JsonObject():New()
    Local oJsonResp := JsonObject():New()
    Local aRetJs    := {}
    Local nGetNames := 0
    Local aNames    := {}

    if VldExecute( self:sourceBranch, @oJsonResp )
        cBody := self:GetContent( )
        oBjJson:fromJSON( cBody )

        if len(oBjJson:GetNames())>0
            for nGetNames := 1 to len(oBjJson:GetNames())
                oJsonResp['success'] := .t.
                aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                if  oBjJson:GetNames()[nGetNames] == cTagMain
                    TAFA565( HashAddInf( ), aNames, MODEL_OPERATION_DELETE, aRetJs )                
                endif
            next nGetNames
        else
            SetErroJs( @oJsonResp,,,,'400' )
        endif

        oJsonResp[cTagMain] := {}
        // adiciona mensagem de erro ao objeto oJsonResp de retorno   
        SetErroJs(@oJsonResp, cTagMain, @aRetJs,,"403" )
    else
        SetErroJs( @oJsonResp,,,cUrl,'401' )
    endif

    //-------------------------------------------------------------------
    // Serializa objeto Json
    //-------------------------------------------------------------------
    cJsonResp := FwJsonSerialize( oJsonResp )
    Self:SetResponse( cJsonResp )

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} HashAddInf()

Função responsável por montar o HashMap que será utilizado para:
1o Armazenar informações necessárias para a gravação do json em MVC
2o Realizar o De-Para entre propriedades json e campos do TAF
    Esse "De-Para" será utilizado para:
    - Persistir o json recebido no MVC ( permitindo assim validar a estrutura json em tempo de persitência no MVC ) e 
    - Caso ocorra erro de commit no MVC, permitirá gravar tabela de log V5R com mensagem amigavéis, pois saberemos qual campo do TAF corresponde a propriedade json com erro.
3o Macro execução de pesquisa F3 de campos que precisam realizar "De-Para" para o Id do TAF

@author Wesley Pinheiro
@since 09/11/2020
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function HashAddInf( )

    Local oHash   := HMNew( )

    Local cTamKey := cValToChar( GetSx3Cache( "C3Q_CODINF", "X3_TAMANHO" ) )

    // Infos genéricas
    HMSet( oHash, "m_o_d_e_l_"   , "MODEL_C3Q"    )
    HMSet( oHash, "s_o_u_r_c_e_" , "TAFA079"      )
    HMSet( oHash, "a_r_e_a_"     , "C3Q"          )
    HMSet( oHash, "o_r_d_e_r_"   , 1              )
    HMSet( oHash, "k_e_y_"       , "aObjJson[nI]['addInformationId']" )
    HMSet( oHash, "s_e_e_k_"     , "C3Q->( DbSeek( xfilial( 'C3Q' ) + padr( cKey," + cTamKey +" ) ) )" )
    HMSet( oHash, "t_a_g_i_d_"   , "addInformationId" )

    // Propriedades e Campos
    SetHashKey( oHash, "addInformationId", "C3Q_CODINF" ) // 02 COD_INF
    SetHashKey( oHash, "description"     , "C3Q_TXTCOM" ) // 03 TXT_COMPL
    SetHashKey( oHash, "stamp"           , "C3Q_STAMP"  )

Return oHash

/*
Função responsável por executar a consulta ao cadastro de produto
@author Wesley Pinheiro
@since 01/07/2020
@version 1.0 
*/
static Function getAddInfo( oRest )

    Local cQry   := addInfoQry( oRest )
    Local cAlias := GetNextAlias( )
    dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)

Return cAlias

/*
Função responsável por montar a consulta ao cadastro de produto
@author Henrique Fabiano Pateno Pereira
@since 01/07/2020
@version 1.0 
*/
Static Function addInfoQry( oRest )

    Local cQry := ''

    cQry += " SELECT "
    cQry += "  C3Q.C3Q_CODINF "
    cQry += "  ,C3Q.C3Q_TXTCOM "
    cQry += "  ,C3Q.C3Q_STAMP "

    cQry  += " FROM " + RetSqlName( "C3Q" ) + " C3Q "
    cQry  += " WHERE C3Q.C3Q_FILIAL = '" + xFilial( "C3Q" ) + "' "
    cQry  += " AND C3Q.D_E_L_E_T_ = ' ' "


    If valtype( oRest:lGetId ) == "L" .and. oRest:lGetId

        cQry += " AND C3Q.C3Q_CODINF = '" + oRest:Id + "' "
    Else

        cQry  += " AND C3Q.C3Q_CODINF BETWEEN '" + oRest:idFrom + "' AND '" + oRest:idTo + "' "

        If !Empty( oRest:order )
            cQry += " ORDER BY C3Q.C3Q_FILIAL, C3Q." + oRest:order + " "
        else
            cQry  += " ORDER BY C3Q.C3Q_FILIAL, C3Q.C3Q_CODINF "
        EndIf

        cQry  += " OFFSET ( " + cValToChar( oRest:page - 1 ) + " * " + cValToChar( oRest:pageSize ) + " ) ROWS
        cQry  += " FETCH NEXT " + cValToChar( oRest:pageSize + 1) + " ROWS ONLY

    EndIf

Return cQry