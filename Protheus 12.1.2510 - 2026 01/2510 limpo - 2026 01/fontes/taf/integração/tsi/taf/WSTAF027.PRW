#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

static cUrl        := 'https://api.totvs.com.br/'
static __cTagJs    := 'participants'
static __lEstExt   := Nil
Static __Regime    := Nil
Static __cTamKey   := Nil
Static __lExistV3R := Nil

/*/{Protheus.doc} TSIPARTICIPANT
WS para persistencia do cadastro de Participantes do TAF

@author Henrique Fabiano Pateno Pereira / Denis Souza
@since 08/07/2020
@version 1.0 
*/

WSRESTFUL TSIPARTICIPANT DESCRIPTION "Api de persistência ao Participante"

    WSDATA sourceBranch  As String
    WSDATA page			 As Integer	Optional
	WSDATA pageSize 	 As Integer	Optional
    WSDATA order         As String  Optional
    WSDATA idFrom        As String  Optional
    WSDATA idTo          As String  Optional
    WSDATA id            As String  optional
    WSDATA lGetId        As Boolean optional

    WSMETHOD GET tsiParticipants;
    DESCRIPTION "Retorna uma lista de Participantes";
    PATH "api/tsi/v1/tsiParticipants/";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiParticipants/";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET idTsiParticipants;
    DESCRIPTION "Retorna o cadastro um Participante";
    PATH "api/tsi/v1/tsiParticipants/{id}";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiParticipants/{id}";
    PRODUCES APPLICATION_JSON

    WSMETHOD POST tsiParticipants; 
    DESCRIPTION "Inclui/altera uma lista de Participantes";
    PATH "api/tsi/v1/tsiParticipants/";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiParticipants/";
    PRODUCES APPLICATION_JSON

    WSMETHOD PUT tsiParticipants;
    DESCRIPTION "Altera participante";
    PATH "api/tsi/v1/tsiParticipants/";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiParticipants/";
    PRODUCES APPLICATION_JSON

    WSMETHOD DELETE tsiParticipants; 
    DESCRIPTION "Deleta uma lista de Participantes";
    PATH "api/tsi/v1/tsiParticipants/";
    TTALK "v1";
    WSSYNTAX "api/tsi/v1/tsiParticipants/";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

/*
Metodo responsável por consultar o cadastro de Participantes ao TAF
@author Henrique Fabiano Pateno Pereira / Denis Souza
@since 08/07/2020
@version 1.0 
*/
WSMETHOD GET tsiParticipants WSRECEIVE sourceBranch, idFrom, idTo, page, pageSize, order WSREST TSIPARTICIPANT

    self:lGetId := .F.

Return GetLstPart( self )

/*
Metodo responsável por consultar o cadastro de Participantes ao TAF
@author Henrique Fabiano Pateno Pereira / Denis Souza
@since 08/07/2020
@version 1.0 
*/
WSMETHOD GET idTsiParticipants WSRECEIVE sourceBranch PATHPARAM id WSREST TSIPARTICIPANT

    self:lGetId := .T.

Return GetLstPart( self )

/*
Metodo responsável por consultar o cadastro de Participantes ao TAF
@author Henrique Fabiano Pateno Pereira / Denis Souza
@since 08/07/2020
@version 1.0 
*/
Static Function GetLstPart( oRest )

    Local cJsonResp     as character
    Local cAlias        as character
    Local cTagChave     as character
    Local cTabSearch    as character
    Local cCmpSearch    as character
    Local cFilPart      as character
    Local cTagKeyDp     as character
    Local cF3           as character
    Local nIndSearch    as numeric
    Local nStruct       as numeric 
    Local nStruDep      as numeric
    Local nPos          as numeric
    Local nPageAux      as numeric
    Local nPosDep       as numeric
    Local lHasNext      as logical
    Local lOK           as logical
    Local lExistV3R     as logical
    Local aStruct       as array
    Local aStruDep      as array
    Local oHash         as object
    Local oJsonResp     as object
    Local nQtdReg       as Numeric
    Local cField        as character
    Local oHashDep      as object

    cJsonResp   := ''
    cAlias      := ''
    cTagChave   := 'participants'
    cTagJson    := ''
    cTabSearch  := ''
    cCmpSearch  := ''
    nIndSearch  := 0
    nStruct     := 0
    nPos        := 0
    nPageAux    := 0
    lHasNext    := .f.
    lOK         := .F.
    aStruct     := { }
    oJsonResp	:= JsonObject():New( )
    oHash       := HashPARTIC( )
    cField      := ""
    oHashDep    := HashV3R()
    lExistV3R   := TcCanOpen(RetSqlName('V3R'))
    cFilPart    := xFilial('C1H')
    nPosDep     := 0
    nStruDep    := 0
    aStruDep    := FwSX3Util():GetAllFields('V3R',.t.)
    cTagKeyDp   := 'dependent'
    cF3         := ''

    if VldExecute( oRest:sourceBranch, @oJsonResp )

        TsiQryPar( oRest, @nQtdReg )

        If valtype( oRest:order ) == 'U' .or. Empty( oRest:order )
            oRest:order := " "
        endif

        cAlias := GetParti( oRest )
        aStruct := ( cAlias )->( DBStruct( ) ) // Retorna a estrutura dos campos utilizados na query

        while ( cAlias )->( !eof( ) )
            nPageAux++

            if nPageAux == 1
                oJsonResp[cTagChave] := { }
            endif

            /* 
                nQtdReg -> Variável utilizada para controlar se a query retornou um registro a mais da quantidade solicitada ( nPageSize ),
                indicando assim a necessidade de uma outra página ( hasnext == true )
            */
            if nPageAux < ( nQtdReg )

                aAdd( oJsonResp[cTagChave], JsonObject( ):New( ) )
                nPos++

                for nStruct := 1 to len( aStruct )

                    cField := alltrim( aStruct[nStruct][1] )

                    //Busca Demais Campos
                    if hmget( oHash, cField, @cTagJson ) .or. hmget( oHash, cField + "#F3#", @cTagJson )

                        oJsonResp[cTagChave][nPos][cTagJson] := Alltrim( &( '(cAlias)->' + cField ) )

                    endif

                Next nStruct

                //T003AB - Carrega os dependentes caso tenham sido cadastrados.
                if lExistV3R
                    V3R->(DbSetOrder(1))
                    if V3R->(DbSeek( xFilial('V3R')+(cAlias)->C1H_ID))
                        oJsonResp[cTagChave][nPos]['dependent'] := {}
                        while V3R->(V3R_FILIAL) == cFilPart .and. V3R->V3R_ID == (cAlias)->C1H_ID
                            aadd( oJsonResp[cTagChave][nPos]['dependent'], JsonObject():New() )
                            nPosDep := len(oJsonResp[cTagChave][nPos]['dependent'])
                            for nStruDep := 1 to len(aStruDep)
                                cField := alltrim( aStruDep[nStruDep] )
                                cF3    := ''     
                                if hmget( oHashDep, cField, @cTagJson ) 
                                    hmget( oHashDep, '#POSIC#'+cField, @cF3 ) //Se o campo tem F3, busca o conteudo na autocontida.
                                    oJsonResp[cTagChave][nPos][cTagKeyDp][nPosDep][cTagJson] := iif(empty(cF3), Alltrim( &( 'V3R->' + cField ) ),  Alltrim( &( cF3 )) )
                                endif
                            next                                                                
                            V3R->(DbSkip())
                        enddo
                    endif
                endif    

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
Metodo responsável por persistir os dados de Participantes ao TAF
@author Henrique Fabiano Pateno Pereira / Denis Souza
@since 08/07/2020
@version 1.0
*/

WSMETHOD POST tsiParticipants WsReceive sourceBranch WSREST TSIPARTICIPANT

    //Usa a função generica de gravação para Pai/filho/neto TAFA585
    WsTSIProc( self, .f., HashPARTIC() )        

return .T.

/*
Metodo responsável por persistir operações de alteração do cadastro de Participantes ao TAF
@author Henrique Fabiano Pateno Pereira / Denis Souza
@since 08/07/2020
@version 1.0 
*/ 

WSMETHOD PUT tsiParticipants WSRECEIVE sourceBranch WSREST TSIPARTICIPANT

    //Usa a função generica de gravação para Pai/filho/neto TAFA585
    WsTSIProc( self, .f., HashPARTIC() )

Return .t.

/*
Metodo responsável por persistir operações de deleção do cadastro de Participantes ao TAF
@author Henrique Fabiano Pateno Pereira / Denis Souza
@since 08/07/2020
@version 1.0 
*/

WSMETHOD DELETE tsiParticipants WSRECEIVE sourceBranch WSREST TSIPARTICIPANT

Local cJsonResp := ""
Local oBjJson   := JsonObject():New()
Local oJsonResp := JsonObject():New()
Local nGetNames := 0
Local aNames    := {}
Local aRetJs    := {}
Local cFilProc  := ''

if VldExecute( self:sourceBranch, @oJsonResp, @cFilProc )
    
    // obtem o body contendo a tag de id dos cadastros que serão deletados
    cBody := self:GetContent( ) 
    oBjJson:fromJSON( cBody )

    if len(oBjJson:GetNames())>0
        for nGetNames := 1 to len(oBjJson:GetNames())             
            aNames := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
            if  oBjJson:GetNames()[nGetNames] == __cTagJs
                Ws027Del( aNames, cFilProc, @aRetJs, @oJsonResp ) 
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
freeobj(oJsonResp)

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} HashPARTIC()

Função responsável por montar o HashMap que será utilizado para:
1o Armazenar informações necessárias para a gravação do json em MVC
2o Realizar o De-Para entre propriedades json e campos do TAF
    Esse "De-Para" será utilizado para:
    - Persistir o json recebido no MVC ( permitindo assim validar a estrutura json em tempo de persitência no MVC ) e 
    - Caso ocorra erro de commit no MVC, permitirá gravar tabela de log V5R com mensagem amigavéis, pois saberemos qual campo do TAF corresponde a propriedade json com erro.
3o Macro execução de pesquisa F3 de campos que precisam realizar "De-Para" para o Id do TAF

@author Denis Souza
@since 08/07/2020
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function HashPARTIC( )

    Local oHash   := HMNew( )

    if __lExistV3R == Nil
        __lExistV3R := TcCanOpen(RetSqlName('V3R'))
    endif
    if __cTamKey == Nil
        __cTamKey := cValToChar( GetSx3Cache( "C1H_CODPAR", "X3_TAMANHO" ) )
    endif
    if __lEstExt == Nil
        __lEstExt := TafColumnPos("C1H_ESTEXT")
    endIf
    if __Regime == Nil
        __Regime := TafColumnPos("C1H_REGTRI") //1=Micro. Municipal;2=Estimativa;3=Sociedade Profissionais;4=Cooperativa;5=Micro. Individual (MEI);6=Micro. ou Emp. Pequeno Porte
    endif

    // Infos genéricas
    HMSet( oHash, "m_o_d_e_l_"   , "MODEL_C1H"    )
    HMSet( oHash, "s_o_u_r_c_e_" , "TAFA053"      )
    HMSet( oHash, "a_r_e_a_"     , "C1H"          )
    HMSet( oHash, "o_r_d_e_r_"   , 1              )
    HMSet( oHash, "k_e_y_"       , "padr(aObjJson['participantId'],60)" )
    //    HMSet( oHash, "k_e_y_"       , "aObjJson[nI]['participantId']" )
    HMSet( oHash, "s_e_e_k_"     , "C1H->( DbSeek( xfilial( 'C1H') + padr( cKey," + __cTamKey +" ) ) )" )
    HMSet( oHash, "t_a_g_i_d_"   , "participants" )

    If __lExistV3R
        HMSet( oHash, 's_u_b_m_o_d_e_l_'   , {{'MODEL_V3R'/*model filho*/,'dependent' /* tag filho*/, 'HashV3R()' /* hash filho*/ }} )
    Endif
    
    // Propriedades e Campos                                             // Campos da planilha Layout TAF - T003
    SetHashKey( oHash, "participantId"             , "C1H_CODPAR"      ) // 02 COD_PART
    SetHashKey( oHash, "name"                      , "C1H_NOME"        ) // 03 NOME
    SetHashKey( oHash, "countryCode"               , "C1H_CODPAI#F3#"  ) // 04 COD_PAIS
    SetHashKey( oHash, "registrationCNPJ"          , "C1H_CNPJ"        ) // 05 CNPJ
    SetHashKey( oHash, "registrationCPF"           , "C1H_CPF"         ) // 06 CPF
    SetHashKey( oHash, "stateRegistration"         , "C1H_IE"          ) // 07 IE
    SetHashKey( oHash, "codeCity"                  , "C1H_CODMUN#F3#"  ) // 08 COD_MUN
    SetHashKey( oHash, "suframa"                   , "C1H_SUFRAM"      ) // 09 SUFRAMA
    SetHashKey( oHash, "adress"                    , "C1H_END"         ) // 11 END
    SetHashKey( oHash, "numberAdress"              , "C1H_NUM"         ) // 12 NUM
    SetHashKey( oHash, "complement"                , "C1H_COMPL"       ) // 13 COMPL
    SetHashKey( oHash, "neighborhood"              , "C1H_BAIRRO"      ) // 15 BAIRRO
    SetHashKey( oHash, "unitFederative"            , "C1H_UF#F3#"      ) // 16 UF
    SetHashKey( oHash, "cep"                       , "C1H_CEP"         ) // 17 CEP
    SetHashKey( oHash, "ddd"                       , "C1H_DDD"         ) // 18 DDD FONE
    SetHashKey( oHash, "phoneNumber"               , "C1H_FONE"        ) // 19 FONE
    SetHashKey( oHash, "email"                     , "C1H_EMAIL"       ) // 22 EMAIL
    SetHashKey( oHash, "kindOfPerson"              , "C1H_PPES"        ) // 24 TP_PESSOA
    SetHashKey( oHash, "activity"                  , "C1H_RAMO"        ) // 25 RAMO_ATV
    SetHashKey( oHash, "cprb"                      , "C1H_CPRB"        ) // 41 INDCPRB
    SetHashKey( oHash, "paa"                       , "C1H_PAA"         ) // 43 EXECPAA
    SetHashKey( oHash, "sportsAssociationIndicator", "C1H_INDDES"      ) // 44 IND_ASSOC_DESPORT
    SetHashKey( oHash, "ctissCode"                 , "C1H_CONTRI"      ) // 45 CONTRIBUINTE
    SetHashKey( oHash, "indcp"                     , "C1H_INDCP"       ) // 46 INDCP
    SetHashKey( oHash, "simpleNational"            , "C1H_SIMPLS"      ) // Nao necessario proteger campo ja existente
    SetHashKey( oHash, "codCountryExt"             , "C1H_PAISEX#F3#"  ) // 28 COD_PAIS_EXT
    SetHashKey( oHash, "addressExt"                , "C1H_LOGEXT"      ) // 29 LOGRAD_EXT
    SetHashKey( oHash, "numberExt"                 , "C1H_NUMEXT"      ) // 30 NR_LOGRAD_EXT
    SetHashKey( oHash, "complementExt"             , "C1H_COMEXT"      ) // 31 COMPLEM_EXT
    SetHashKey( oHash, "district"                  , "C1H_BAIEXT"      ) // 32 BAIRRO_EXT
    SetHashKey( oHash, "city"                      , "C1H_NMCEXT"      ) // 33 NOME_CIDADE_EXT
    SetHashKey( oHash, "postalCode"                , "C1H_CDPOSE"      ) // 34 COD_POSTAL_EXT
    SetHashKey( oHash, "payingSourceReport"        , "C1H_RELFON#F3#"  ) // 36 REL_FONTE_PAG_RESID_EXTERIOR

    If __lEstExt
        SetHashKey( oHash, "exemptimmune"              , "C1H_ISEIMU"      ) // 46 ISENTO_IMUNE
        SetHashKey( oHash, "state"                     , "C1H_ESTEXT"      ) // 48 ESTADO_EXT    
        SetHashKey( oHash, "foneExt"                   , "C1H_TELEXT"      ) // 49 TELEFONE_EXT
        SetHashKey( oHash, "indicativeNif"             , "C1H_INDNIF"      ) // 50 INDICATIVO_NIF_EXT
        SetHashKey( oHash, "nif"                       , "C1H_NIF"         ) // 51 NIF
        SetHashKey( oHash, "formOftaxation"            , "C1H_IDTRIB#F3#"  ) // 52 FORMA_TRIBUTACAO
        SetHashKey( oHash, "kindOfPersonExt"           , "C1H_PEEXTE"      ) // 53 TIPO_PESSOA_EXTERIOR
    Endif
    
    SetHashKey( oHash, "stamp"                     , "C1H_STAMP"       )

    if __Regime
        SetHashKey( oHash, "taxationRegime"        , "C1H_REGTRI"      )    //Regime Especial Tributação
    endif

    // #F3#
    HMSet( oHash, "#F3#C1H_CODPAI", "GetTafId( 'C08', cChave, 1 )" )
    HMSet( oHash, "#F3#C1H_CODMUN", "GetTafId2( 'C09', aObjJson['unitFederative'], 1, 'C07', cChave, 1 ) " )
    HMSet( oHash, "#F3#C1H_UF"    , "GetTafId( 'C09', cChave, 1 )" )
    HMSet( oHash, "#F3#C1H_RELFON", "GetTafId( 'CUB', cChave , 2 )" )
    HMSet( oHash, "#F3#C1H_PAISEX", "GetTafId( 'C08', cChave , 4 )" )
    HMSet( oHash, "#F3#C1H_IDTRIB", "GetTafId( 'T9A', STRZERO(val(cChave),4), 2 )" )

Return oHash

/*--------------------------------------------------------------------------------
{Protheus.doc} HashV3R()
Cria Hash de "De|Para" do identIficador do Json para o campo de gravação no TAF

@author Carlos Eduardo
@since 29/09/2022
@return Nil, nulo, não tem retorno.
------------------------------------------------------------------------------*/
Function HashV3R()
Local oHash   := HMNew()

// Propriedades e Campos
SetHashKey(oHash, 'dependentCode'           , 'V3R_CODIGO')
SetHashKey(oHash, 'document'                , 'V3R_CPF')
SetHashKey(oHash, 'name'                    , 'V3R_NOME')
SetHashKey(oHash, 'dependencyRelationship'  , 'V3R_RELDEP#F3#')
SetHashKey(oHash, 'descriptionDependency'   , 'V3R_DESCDP') 

//#F3# usado na gravação ou alteração dos tributos dos itens 
HMSet(oHash, '#F3#V3R_RELDEP', "alltrim(GetAdvFVal('V3Q','V3Q_CODIGO',xFilial('V3Q')+aObjJson['dependencyRelationship'],2,'NOTFOUND',.t.))") 

//Posicione ( utilizado no get )
HMSet(oHash, '#POSIC#V3R_RELDEP', "alltrim(GetAdvFVal('V3Q','V3Q_CODIGO',xFilial('V3Q')+V3R->V3R_CREDEP,1))") 

Return oHash

/*
Função responsável por executar a consulta ao cadastro de produto
@author Henrique Fabiano Pateno Pereira / Denis Souza
@since 01/07/2020
@version 1.0 
*/
static Function getParti( oRest )

    Local cQry   := GetPartQry( oRest )
    Local cAlias := GetNextAlias( )
    dbUseArea(.T., "TOPCONN", TCGenQry(, , cQry), cAlias, .F., .T.)

Return cAlias

/*
Função responsável por montar a consulta ao cadastro de produto
@author Henrique Fabiano Pateno Pereira
@since 01/07/2020
@version 1.0 
*/
Static Function GetPartQry( oRest )

    Local cQry := ''

    cQry += " SELECT "
    cQry += "  C1H.C1H_ID "
    cQry += "  ,C1H.C1H_CODPAR "
    cQry += "  ,C1H.C1H_NOME "
    cQry += "  ,C08.C08_CODIGO C1H_CODPAI "
    cQry += "  ,C1H.C1H_CNPJ "
    cQry += "  ,C1H.C1H_CPF "
    cQry += "  ,C1H.C1H_IE "
    cQry += "  ,C07.C07_CODIGO C1H_CODMUN "
    cQry += "  ,C1H.C1H_SUFRAM "
    cQry += "  ,C1H.C1H_END "
    cQry += "  ,C1H.C1H_NUM "
    cQry += "  ,C1H.C1H_COMPL "
    cQry += "  ,C1H.C1H_BAIRRO "
    cQry += "  ,C09.C09_UF C1H_UF "
    cQry += "  ,C1H.C1H_CEP "
    cQry += "  ,C1H.C1H_DDD "
    cQry += "  ,C1H.C1H_FONE "
    cQry += "  ,C1H.C1H_EMAIL "
    cQry += "  ,C1H.C1H_PPES "
    cQry += "  ,C1H.C1H_RAMO "
    cQry += "  ,C1H.C1H_CPRB "
    cQry += "  ,C1H.C1H_PAA "
    cQry += "  ,C1H.C1H_INDDES "
    cQry += "  ,C1H.C1H_CONTRI "
    cQry += "  ,C1H.C1H_STAMP "
    cQry += " FROM " + RetSqlName("C1H") + " C1H "

    // Municipios 
    cQry += " LEFT JOIN "
    cQry += RetSqlName( "C07" ) + " C07 "
    cQry += " ON C07.C07_FILIAL = '" + xFilial( "C07" ) + "' "
    cQry += " AND C1H.C1H_CODMUN = C07.C07_ID "
    cQry += " AND C1H.D_E_L_E_T_ = C07.D_E_L_E_T_ "

    // Países
    cQry += " LEFT JOIN "
    cQry += RetSqlName( "C08" ) + " C08 "
    cQry += " ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
    cQry += " AND C1H.C1H_CODPAI = C08.C08_ID "
    cQry += " AND C1H.D_E_L_E_T_ = C08.D_E_L_E_T_ "

    // UF
    cQry += " LEFT JOIN "
    cQry += RetSqlName( "C09" ) + " C09 "
    cQry += " ON C09.C09_FILIAL = '" + xFilial( "C09" ) + "' "
    cQry += " AND C1H.C1H_UF = C09.C09_ID "
    cQry += " AND C1H.D_E_L_E_T_ = C09.D_E_L_E_T_ "

    cQry += " WHERE C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
    cQry += " AND C1H.D_E_L_E_T_ = ' ' "

    If valtype( oRest:lGetId ) == "L" .and. oRest:lGetId

        cQry += " AND C1H.C1H_CODPAR = '" + oRest:Id + "' "
    Else

        cQry  += " AND C1H.C1H_CODPAR BETWEEN '" + oRest:idFrom + "' AND '" + oRest:idTo + "' "

        If !Empty( oRest:order )
            cQry += " ORDER BY C1H.C1H_FILIAL, C1H." + oRest:order + " "
        else
            cQry  += " ORDER BY C1H.C1H_FILIAL, C1H.C1H_CODPAR "
        EndIf

        cQry  += " OFFSET ( " + cValToChar( oRest:page - 1 ) + " * " + cValToChar( oRest:pageSize ) + " ) ROWS
        cQry  += " FETCH NEXT " + cValToChar( oRest:pageSize + 1 ) + " ROWS ONLY

    EndIf

Return cQry

/*{Protheus.doc} Ws027Del()
Função responsável por deletar os registros quando for usado
o metodo delete()

@author Carlos Edurdo
@since 06/10/2022*/
Static Function Ws027Del(aObjJson, cFilProc, aRetJs, oJsonResp)
Local lRet      := .t.
Local lSucesso  := .t.
Local i         := 0
Local oModel    := FwLoadModel( 'TAFA053' )  
Local nTamCod   := FWSX3Util():GetFieldStruct( 'C1H_CODPAR' )[3]
Local cTagKey   := 'participantId'
Local cErro     := ''
Local cCodErro  := 'NOTEXIST'

DbSelectArea('C1H')
C1H->(DbSetOrder(1))

oJsonResp[__cTagJs] := {}
for i := 1 to len(aObjJson)    
    if C1H->(DbSeek(xFilial('C1H') + padr( aObjJson[i][cTagKey] ,nTamCod) ) )
        oModel:SetOperation( MODEL_OPERATION_DELETE )
        oModel:Activate( )
        lSucesso := FwFormCommit( oModel )
        oModel:DeActivate( ) 
        aadd( aRetJs,{ lSucesso ,aObjJson[i][cTagKey]})  
    else
        // o seek falhou, prepara e mensagem json de resposta insformando que o item não foi encontrado na base de dados
        lSucesso := .f. 
        cProperty := aObjJson[i][cTagKey]    
        cErro := RetErroTaf( cProperty, aObjJson[i], cTagKey , cCodErro, aObjJson[i][cTagKey] )
        aadd(aRetJs,{ lSucesso ,aObjJson[i][cTagKey], cCodErro, cErro} ) 
    endif

    if len( aRetJs ) > 0                       
        SetErroJs(@oJsonResp, __cTagJs, aRetJs,,"403") 
        aRetJs := {}
    endif     
next    

return lRet
