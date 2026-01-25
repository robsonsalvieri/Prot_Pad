#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RSKXFun.CH'   
#INCLUDE "RSKDefs.ch"
#INCLUDE "fwlibversion.ch"

Static _lRskIsAct    := Nil    //Identifica se a integração RISK está habilitada.
Static _aSupInfo     := {}      //Armazena as informações da Supplier de acordo com a filial (CNPJ)
Static _nRskType     := Nil     //Identifica qual o tipo de integração do RISK
Static _lIsRskUpd    := Nil    //Identifica se o ambiente está atualizado com as tabelas do RISK
Static __lTechFinlog := FindFunction( "FINA138A" )    //Verifique se a função de log existe
Static __oTechFinlog := Nil    //Method para gravação de log
Static __lRegistry   := FindFunction( "FINA138B" )
Static __oTFRegistry := TFRegistry()

//-------------------------------------------------------------------
/*/{Protheus.doc} RSKXFUN
Biblioteca de funções utilizadas no Risk Off Balance

@author Squad NT / TechFin
@since 15/05/2020 
@version P12
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskIsActive
Funcao que retorna se a integração Risk está ativada.

@return lógico, Retorna se a integração RISK está habilitada.
@author Squad NT TechFin
@since  12/06/2020
/*/
//-------------------------------------------------------------------------------
Function RskIsActive()
    If _lRskIsAct == Nil 
        _lRskIsAct := RskType() > 0
    EndIf 
Return _lRskIsAct 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskType
Funcao que retorna se a integração Risk está ativada e qual o tipo desta integração.

@return lógico, Retorna qual o tipo de integração do RISK
@author Squad NT TechFin
@since  20/07/2020
/*/
//-------------------------------------------------------------------------------
Function RskType()
    If _nRskType == Nil 
        If IsRskUpdated()
            _nRskType := SuperGetMV( "MV_RISKTIP", .F., 0 ) // 0=desligado;1=full;2=offbalance
        Else
            _nRskType := 0
        EndIf
    EndIf 
Return _nRskType 


//-------------------------------------------------------------------------------
/*/{Protheus.doc} IsRskUpdated
Funcao que valida se a estrutura do RISK está disponível

@return lógico, Retorna se o ambiente está atualizado com as tabelas do RISK
@author Squad NT TechFin
@since  28/10/2020
/*/
//-------------------------------------------------------------------------------
Function IsRskUpdated()
    If _lIsRskUpd == Nil
        If AliasInDic( "AR0" ) .And. GetRPORelease() >= '12.1.025'
            _lIsRskUpd := .T.
        Else
            _lIsRskUpd := .F.
        EndIf
    EndIf 
Return _lIsRskUpd 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskTrtCmp
Funcao que retorna boolean para mostrar/inibir campos do cadastro de clientes conforme parametros Risk.

@return lógico, Retorna se a integração é do tipo FULL
@author Squad NT TechFin
@since  20/07/2020
/*/
//-------------------------------------------------------------------------------
Function RskBlqCmp()
Local lRetF := RskType() == 1   // 0 - desligado; 1 - full; 2 - offbalance
Return lRetF 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskCPTPay
Função que trata o when da condicao de pagamento para permitir ativar o TPay.

@return lógico, Retorna se a integração RISK está habilitada
@author Squad NT TechFin
@since  12/06/2020
/*/
//------------------------------------------------------------------------------
Function RskCPTPay()
Local lRetCPay := RskType() >= 1
Return lRetCPay


//------------------------------------------------------------------------------
/*/{Protheus.doc} RskBankSlip
Define se o título financeiro poderá gerar boleto.

@return cRet, caracter, Vazio ou 1 permite / 2 Não permite 
@author Squad NT TechFin
@since  09/07/2020
/*/
//-----------------------------------------------------------------------------
Function RskBankSlip()
    Local cRet := " "
    
    If ( RskIsActive() .And. SE4->( ColumnPos( "E4_TPAY" ) ) > 0 .And. SE4->E4_TPAY )
        //-----------------------------------------------------------------------------
        // Não permite gerar boleto para título financeiro OFF Balance.
        //-----------------------------------------------------------------------------
        cRet := "2" 
    EndIf
Return cRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskQWBorde
Condição utilizada para geração de bordero no Finaceiro.

@return cWhere, caracter, Condição em SQLANSI
@author Squad NT TechFin
@since  09/07/2020
/*/
//-----------------------------------------------------------------------------
Function RskQWBorde()    
    Local cWhere := ""
    
    If ( RskIsActive() .And. SE4->( ColumnPos( "E4_TPAY" ) ) > 0 )
        //-----------------------------------------------------------------------------
        // Não pode entrar em bordero, títulos associados a uma NFS OFF Balance ou movimentos de concialiação OFF Balance.
        //-----------------------------------------------------------------------------
        cWhere := " AND E1_BOLETO <> '2'"  
    EndIf  
Return cWhere

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskNCtoCli
Função que associa um cliente ao contato quando o campo A1_CONTATO for
preenchido.

@return lRet, logico, Retorna verdadeiro se o contato foi incluido.
@author Squad NT TechFin
@since  12/06/2020
/*/
//-----------------------------------------------------------------------------
Function RskNCtoCli()
    Local aArea       := GetArea()
    Local aAreaAC8    := AC8->( GetArea() )
    Local aContact    := {}
    Local aPhone      := {}
    Local aAddress    := {}
    Local aAux        := {}
    Local nLength     := 0
    Local oModelAC8   := Nil 
    Local oMdlAC8     := Nil
    Local lRskcont    := SuperGetMv("MV_RSKCONT",.F.,.F.) 

    Private lMsErroAuto := .F.

    If RskIsActive() .and. lRskcont
        SaveInter()
        DBSelectArea( "AC8" )
        AC8->( DBSetOrder(2) )    //AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON

        If AC8->( !DBSeek( xFilial( "AC8" ) + "SA1" + xFilial( "SA1" ) + M->A1_COD + M->A1_LOJA ) ) .And. !Empty( M->A1_CONTATO )
            aAdd( aContact, { "U5_CONTAT"  , M->A1_CONTATO  , Nil } ) 
            aAdd( aContact, { "U5_EMAIL"   , M->A1_EMAIL    , Nil } ) 

            aAdd( aAux, { "AGA_TIPO"        , "1"		    , Nil } )
            aAdd( aAux, { "AGA_END"         , M->A1_END    	, Nil } )
            aAdd( aAux, { "AGA_CEP"         , M->A1_CEP     , Nil } )
            aAdd( aAux, { "AGA_BAIRRO"	    , M->A1_BAIRRO  , Nil } )
            aAdd( aAux, { "AGA_MUNDES"	    , M->A1_MUN     , Nil } )
            aAdd( aAux, { "AGA_EST"	        , M->A1_EST     , Nil } )
            aAdd( aAux, { "AGA_MUN"	        , M->A1_COD_MUN , Nil } )
            aAdd( aAux, { "AGA_COMP"	    , M->A1_COMPLEM , Nil } )
            aAdd( aAux, { "AGA_PADRAO"	    , "1"	        , Nil } )

            aAdd( aAddress, aAux )

            aAux := {}

            aAdd( aAux, {"AGB_TIPO"         , "1"		    , Nil } )
            aAdd( aAux, {"AGB_DDI"          , M->A1_DDI	    , Nil } )
            aAdd( aAux, {"AGB_DDD"          , M->A1_DDD     , Nil } )
            aAdd( aAux, {"AGB_TELEFO"	    , M->A1_TEL     , Nil } )
            aAdd( aAux, {"AGB_PADRAO"	    , "1"	        , Nil } )

            aAdd( aPhone, aAux )

            INCLUI := .T.
            MSExecAuto( { |x, y, z, b| TMKA070( x, y, z, b ) }, aContact, 3, aAddress, aPhone )
                
            If !lMsErroAuto
                oModelAC8 := FwLoadModel( "CRMA060" )
                oModelAC8:SetOperation( MODEL_OPERATION_UPDATE )
                oModelAC8:GetModel( "AC8MASTER" ):bLoad := {|| { xFilial( "AC8" ), xFilial( "SA1" ), "SA1", M->A1_COD + M->A1_LOJA, "" } }
                oModelAC8:Activate()
                
                If oModelAC8:IsActive()
                    oMdlAC8	:= oModelAC8:GetModel( "AC8CONTDET" )
                    
                    If !oMdlAC8:SeekLine( { { "AC8_CODCON", SU5->U5_CODCONT } } )
                        nLength := oMdlAC8:Length()
                        If oMdlAC8:AddLine() > nLength
                            oMdlAC8:SetValue( "AC8_CODCON", SU5->U5_CODCONT )
                        EndIf
                    EndIf
                    
                    If oModelAC8:VldData()
                        oModelAC8:CommitData()
                    EndIf
                EndIf
            EndIf

            If ( IsBlind() .And. lMsErroAuto )
                MostraErro()
            EndIf
        EndIf  
        
        RestInter()
    EndIf

    RestArea( aArea )
    RestArea( aAreaAC8 )

    FWFreeArray( aArea )
    FWFreeArray( aAreaAC8 )
    FWFreeArray( aContact )
    FWFreeArray( aPhone )
    FWFreeArray( aAddress )
    FWFreeArray( aAux )
    FreeObj( oModelAC8 )
    FreeObj( oMdlAC8 )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RSKOBSInvoice()
Função chamada como gatilho do campo C5_CONDPAG para preencher
a mensagem no campo C5_MENNOTA.

@param cPayCond, Código da condição de pagamento
@param cMessage, Messagem padrão caso a condição não for Mais Negócios.
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return caracter, mensagem que será gravada no campo C5_MENNOTA
@author  TECHFIN
@since   29/05/2020
/*/
//-------------------------------------------------------------------
Function RskOBSInvoice( cPayCond, cMessage, lAutomato )
    Local aSvAlias  := GetArea()
    Local aContent  := Array(4) // Armazena os dadas que serão apresentados na mensagem.
    Local aSupInfo  := {}
    Local cMsgBkp   := ""
    Local nTamMsg   := 0

    Default cPayCond  := ""
    Default cMessage  := ""
    Default lAutomato := .F.

    If ( Empty(cPayCond) .And. Type("M->C5_CONDPAG") == "C" )
        cPayCond := M->C5_CONDPAG
    EndIf

    If ( Empty(cMessage) .And. Type("M->C5_MENNOTA") == "C" )  
        cMessage := M->C5_MENNOTA
    EndIf       
    
    If RskIsActive()
        If !Empty( cPayCond )
            If RskIsTPayCond( cPayCond )
                aSupInfo := GetSupplInfo( lAutomato )
                If !Empty(aSupInfo)
                    aContent[1] := aSupInfo[4][1] // Nome do cartão parceiro - '[Cartão Parceiro]'
                    aContent[2] := Len( Condicao( 100, cPayCond ) )
                    aContent[3] := aSupInfo[4][2] // Central de atendimento
                    aContent[4] := aSupInfo[4][3] // Central de cobrança

                    cMsgBkp  := AllTrim( cMessage )
                    nTamMsg  := TamSX3( "C5_MENNOTA" )[1]
                    cMessage := I18N( STR0001, aContent )   //'Compra efetuada através do #1 em #2 parcelas. Central de atendimento do #1: #3. Central de cobrança do #1: #4'
                    If .Not. Empty( cMsgBkp )
                        If AT(aSupInfo[4][1], cMsgBkp) == 0
                            If Len( cMsgBkp + cMessage ) > nTamMsg
                                Help( "", 1, "C5_MENNOTA", , STR0018 + Str( nTamMsg ), 1, 0,,,,,, { STR0019 } ) //'Não é possível gravar a mensagem no campo "Mens. / Nota" (C5_MENNOTA), ultrapassou o limite do campo - Tamanho: ' ## 'Revisar o conteúdo, será atualizado com a mensagem padrão Mais Negócios.'
                            Else
                                cMessage := cMsgBkp + " " + cMessage
                            EndIf
                        ElseIf cMsgBkp <> cMessage
                            Help( "", 1, "C5_MENNOTA", , STR0020, 1, 0,,,,,, { STR0019 } ) // 'Condição de Pagamento Mais Negócios irá atualizar o campo "Mens. / Nota" (C5_MENNOTA)' ## 'Revisar o conteúdo, será atualizado com a mensagem padrão Mais Negócios.'
                        EndIf
                    EndIf
                EndIf
            ElseIf .Not. Empty( cMessage )
                aSupInfo := GetSupplInfo( lAutomato )
                If AT(aSupInfo[4][1], cMessage) > 0
                    Help( "", 1, "C5_MENNOTA", , STR0021, 1, 0,,,,,, { STR0022 } ) // 'Campo "Mens. / Nota" (C5_MENNOTA) contêm informações da Condição de Pagamento Mais Negócios' ## 'Revisar o conteúdo, será preenchido com conteúdo em branco.'
                    cMessage := ""
                EndIf
            EndIf
        EndIF
    EndIf

    RestArea( aSvAlias) 

    FWFreeArray( aContent )  
    FWFreeArray( aSupInfo )
    FWFreeArray( aSvAlias )
Return cMessage 


//-------------------------------------------------------------------
/*/{Protheus.doc} RSKXFmtTStamp()
Função que converte um timestamp no formato aaaammddhhmmss
no formato dd/mm/aaaa hh:mm:ss.

@param cTimeStamp, caracter, timestamp no formato aaaammddhhmmss

@return caracter, formato data e hora 
@author  TECHFIN
@since   30/05/2020
/*/
//-------------------------------------------------------------------
Function RskFmtTStamp( cTimeStamp )
    Local cDateTime := ""
    Local cDate     := ""
    Local cTime     := "" 

    Default cTimeStamp  := ""
     
    If !Empty( cTimeStamp ) 
        cDate := SubStr( cTimeStamp, 1, 8 )
        cTime := SubStr( cTimeStamp, 9, 6 )
        If !Empty( cTime )
            cTime := SubStr( cTime, 1, 2 ) + ":" + SubStr( cTime, 3, 2 ) + ":" + SubStr( cTime, 5, 2 )
        Else
            cTime := "00:00:00"
        EndIf
        cDateTime := dToc( sTod( cDate ) ) + " " + cTime 
    EndIf 
Return cDateTime 

//-------------------------------------------------------------------
/*/{Protheus.doc} RskDTToLocal()
Função que converte formato data aaaa-mm-ddThh:mm:ss
no formato aaaammddhhmmss

// junko - documentar os parâmetros
@return caracter, formato aaaammddhhmmss
@author  TECHFIN
@since   30/05/2020
/*/
//-------------------------------------------------------------------
Function RskDTToLocal( cDateTime, lUTC )
    Local aRet          := {}
    Local cTimeStamp    := ""
    Local cDate         := ""
    Local cTime         := ""

    Default cDateTime   := ""
    Default lUTC        := .T.
   
    If !Empty( cDateTime ) 
        cDateTime   := StrTran( cDateTime, "-", "" )
        cDateTime   := StrTran( cDateTime, "T", "" )
        cDate       := SubStr( cDateTime, 1, 8 )
        cTime       := SubStr( cDateTime, 9, 8 )
        If lUTC
            aRet    := UTCToLocal( cDate, cTime )
            cDate   := aRet[1]
            cTime   := aRet[2]
        EndIf 
        cTimeStamp  := cDate + StrTran( cTime, ":", "" )
    EndIf 

    FWFreeArray( aRet )
Return cTimeStamp

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSupplInfo
Função responsável por trazer os dados do cartão da Supplier de acordo com o CNPJ da
filial corrente. Os dados serão buscados na plataforma RISK e armazenados na variável
estática _aSupInfo, mimimizando a busca dos dados em cada interação.

@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, informações da plataforma de acordo com o CNPJ da filial corrente. Se o 
endpoint da plataforma não retornar valores, o retorno será um array VAZIO.
    [1] - empresa
    [2] - filial
    [3] - CNPJ
    [4] - dados do cartão
        [1] - nome do cartão
        [2] - telefone da central de atendimento
        [3] - telefone da central de cobrança

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetSupplInfo( lAutomato )
    Local aSvAlias := GetArea() 
    lOCAL aBranchDetails := {}
    Local cCNPJ := ''
    Local cCardInfo := ''
    Local nPos := 0

    If ( nPos := Ascan(_aSupInfo, {|x| x[1] == cEmpAnt .And. x[2] == cFilAnt }) ) == 0
        aBranchDetails := FWArrFilAtu()
        cCNPJ := aBranchDetails[ SM0_CGC ]
        
        cCardInfo := GetSupplCard( lAutomato )
        If !Empty( cCardInfo )
            Aadd( _aSupInfo, { cEmpAnt, cFilAnt, cCNPJ, StrtokArr( cCardInfo , '|' ) } )
            nPos := Len( _aSupInfo )
        EndIf
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aBranchDetails )
Return Iif( nPos > 0, Aclone( _aSupInfo[ nPos ] ), {} )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSupplCard
Função de busca dos dados do cartão parceiro na plataforma RISK

@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return caracter, informações do cartão do parceiro retornadas pela plataforma RISK
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetSupplCard( lAutomato As Logical ) As Character
    Local aSVAlias    As Array
    Local aProperties As Array
    Local cResult     As Character
    Local cEndPoint   As Character
    Local cContent    As Character
    Local nProp       As Numeric
    Local xValue

    aSVAlias    := GetArea()
    aProperties := {'cardName', 'attendancePhone', 'chargePhone'}
    cResult     := ''
    cEndPoint   := '/api/partners/invoicefooter/protheus'
    cContent    := ''
    nProp       := 0

    If __lRegistry
        cEndPoint := __oTFRegistry:oUrlTF["risk-riskapi-invoicefooter-V1"]
    EndIf
    cResult := RunPlatEndpoint( cEndPoint )

    If !Empty( cResult )
        oJSON := JSONObject():New()
        oJSON:FromJSON( cResult )

        For nProp := 1 to len( aProperties )
            xValue := oJSON[ aProperties[ nProp ] ]
        
            If Valtype( xValue ) != "U"
                cContent += DecodeUTF8( xValue )
            else
                cContent += ' '
            EndIf
            cContent += '|'
        Next

        If !Empty( cContent ) 
            cContent := Subs( cContent, 1, Len( cContent ) -1)
        ENDIF
    EndIf

    RestArea( aSVAlias )
    
    FWFreeArray( aProperties )
    FWFreeArray( aSVAlias )
Return cContent

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskGetSSettings
Função de busca dos dados de configuração na plataforma.

@param cCNPJ, caracter, CNPJ da filial corrente
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@param nEntity, number, numero que define o tipo de operação 5=CONCESSION, 10=CLIENTPOSITION
@param cOrigem, caracter, possui a informação da rotina de origem da informação
@param cTabela, caracter, possui a informação da tabela de origem da informação
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@return caracter, dados de configuração da plataforma RISK, sendo:
    organizationCnpj | ID da linha de crédito | Código do grupo na plataforma | Mínimo de dias para reanálise de crédito | Mínimo de dias para atualizar solicitação
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Function RskGetSSettings( cCNPJ As Character, lAutomato As Logical, nEntity As Numeric, cOrigem As Character, cTabela As Character, aParam As Array ) As Array
    Local aSVAlias      As Array
    Local aProperties   As Array
    Local aSettings     As Array
    Local cResult       As Character
    Local cEndPoint     As Character
    Local nProp         As Numeric
    Local xValue

    Default nEntity   := 0
    Default cTabela   := ''
    Default cOrigem   := ''
    Default aParam    := {}
    Default lAutomato := .F. 

    aSVAlias    := GetArea()
    aProperties := {'organizationCnpj','creditLineId','groupCode','minimumDaysForReanalysisSolicitation','minimumDaysForUpdateSolicitation'}
    aSettings   := {}
    cResult     := ''
    cEndPoint   := '/api/organizations/XXX/settings/protheus'
    nProp       := 0 

    If !Empty( cCNPJ ) 
        cEndPoint := StrTran( cEndPoint, 'XXX', cCNPJ )
        If __lRegistry
            cEndPoint := __oTFRegistry:oUrlTF["risk-riskapi-organizations-V1"]
            cEndPoint := StrTran( cEndPoint, '{id}', cCNPJ )
        EndIf
        cResult := RunPlatEndpoint( cEndPoint , /*cAddParam*/, /*nType*/, /*lAutomato*/, nEntity, cOrigem, cTabela, aParam )
            
        If !Empty( cResult )
            oJSON := JSONObject():New() 
            oJSON:FromJSON( cResult )

            For nProp := 1 to len( aProperties )
                xValue := oJSON[ aProperties[ nProp ] ]
            
                If Valtype( xValue ) != "U"
                    If Valtype( xValue ) == "C"
                        xValue := DecodeUTF8( xValue )
                    EndIf
                    aAdd( aSettings, xValue )
                EndIf   
            Next nProp
        EndIf    
    EndIf

    RestArea( aSVAlias )
    
    FWFreeArray( aProperties )
    FWFreeArray( aSVAlias )
Return aSettings

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRSKPlatform
Esta função retorna a URL da plataforma Risk para consumo da API

@param lProtheus, boolean, se .T. indica que irá consumir o protheus-api, caso contrário
    consome as APIs da plataforma 

@return caracter, URL para consumo da API
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Function GetRSKPlatform( lProtheus ) 
    Local cInfo := '' 
    Local cProtheusAPI := '/protheus-api'

    Default lProtheus := .T.

    cInfo := SuperGetMV( "MV_RSKPLAT", .F., '' ) 

    If !Empty( cInfo ) 
        If lProtheus
            // cInfo := IIF( RIGHT( cInfo, 1 ) == '/', Subs( cInfo, 1, len( cInfo ) - 1 ), cInfo )
            If !( cProtheusAPI $ cInfo ) 
                cInfo += cProtheusAPI     
            EndIf
        Else
            If ( cProtheusAPI $ cInfo ) 
                cInfo := StrTran( cInfo, cProtheusAPI, '' )
            EndIf
        EndIf
        cInfo := IIF( RIGHT( cInfo, 1 ) == '/', Subs( cInfo, 1, len( cInfo ) - 1 ), cInfo )
    EndIf
Return cInfo

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKVlAlfaNum
Esta função é responsável por avaliar se a informação passada possui apenas caracteres
afanuméricos.

@param cString, caracter, conteúdo a ser avaliado

@return lógico, indica se o dado passado é alfanumérico
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKVlAlfaNum( cString ) 
    Local cAlfaNum  As Character
    Local lValid   As Logical
    Local nAlfa    As Numeric

    Default cString := ""

    cString     := Upper( cString )
    cAlfaNum    := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ "
    lValid      := .T.

    For nAlfa := 1 To Len( cString )
        If !( SubStr( cString, nAlfa, 1 ) $ cAlfaNum )
            lValid := .F.
            Help( Nil, Nil, "NOCARACESPEC", "", STR0002, 1,,,,,,, { STR0003 } )  //"Não é permitido o uso de caracteres especiais."###"Informe somente letras ou números."
            Exit
        EndIf
    Next
Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskRacAccess
Autentica e recupera o Token para comunicação com a plataforma 

@param cPlatform, URL da plataforma para definição do RAC
@param nType, number, identifica qual a URL do RAC retornar
    1 - autenticação
    2 - admin ( autenticação de serviços )
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, dados de comunicação com a plataforma
    [1] - Código de resposta da requisição
    [2] - Código de autenticação
    [3] - Tempo para expirar
    [4] - data da solicitação
    [5] - segundo da solicitação

@author  Marcia Junko
@since   27/06/2020
/*/
//-------------------------------------------------------------------------------------
Function RskRacAccess( cPlatform As Character, nType As Numeric, lAutomato As Logical ) As Array
    Local aToken     As Array
    Local aHeader    As Array
    Local cFormParam As Character
    Local cEndPoint  As Character
    Local cBody      As Character
    Local cPathRac   As Character
    Local oRest      As Object
    Local oJson      As Object
    Local cClientID  As Character
    Local cSecret    As Character
    Local oConfig    As Object

    Default cPlatform := ''
    Default nType     := 1
    Default lAutomato := .F.

    aToken     := {}
    aHeader    := {}
    cFormParam := ''
    cEndPoint  := ''
    cBody      := ''
    cPathRac   := '/totvs.rac/connect/token'
    cClientID  := '' 
    cSecret    := ''

    If !lAutomato
        oConfig   := FWTFConfig()
        If __lRegistry
            cEndPoint   := __oTFRegistry:oUrlTF["rac-token-V1"]
            cPathRac    := ""
        Else
            cEndPoint   := RSKSetRacURL( oConfig, cPlatform, nType )
        EndIf
        cClientID   := oConfig[ "platform-clientId" ] 
        cSecret     := oConfig[ "platform-secret" ] 

        AAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")
        AAdd(aHeader, "charset: UTF-8")

        cFormParam := "client_id=" + cClientID + "&"   
        cFormParam += "client_secret=" + cSecret + "&"  
        cFormParam += "grant_type=client_credentials&"
        cFormParam += "scope=authorization_api"

        oRest := FwRest():New( cEndPoint )
        oRest:setPath( cPathRac ) 
        oRest:SetPostParams( cFormParam ) 

        If oRest:Post( aHeader )
            cBody := oRest:GetResult()
            oJson := JsonObject():New()
            oJson:fromJson( cBody )

            If !( Empty( oJSON[ "access_token" ] ) )
                AAdd( aToken, oRest:GetHTTPCode() )
                AAdd( aToken, oJSON[ "access_token" ] )
                AAdd( aToken, oJSON[ "expires_in" ] )
                AAdd( aToken, Date())
                AAdd( aToken, Seconds() ) 
            EndIf
        Else
            LogMsg( "RskRacAccess", 23, 6, 1, "", "", "RskRacAccess -> " + STR0004 )    //"Não foi possível autenticar no RAC."
        EndIf
    Else
        aToken := Array(5)
    EndIf

    FWFreeArray( aHeader )
    FreeObj( oRest )
    FreeObj( oConfig )
    FreeObj( oJSON )
Return aToken

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKSetRacURL
Identifica qual o endereço do RAC para utilizar durante as autenticações

@param oConfig, objeto, dados de conexão com a plataforma
@param cURL, caracter, URL da plataforma
@param nType, number, identifica qual a URL do RAC retornar
    1 - autenticação
    2 - admin ( autenticação de serviços )

@return caracter, URL do RAC para autenticação
@author  Marcia Junko
@since   30/07/2020
/*/
//-------------------------------------------------------------------
Function RSKSetRacURL( oConfig, cURL, nType )
    Local aSVAlias := GetArea()
    Local cRacURL := ''
    Local cPlatform := ''
    
    Default oConfig := FWTFConfig()
    Default cURL    := ''
    Default nType   := 1

    cRacURL   := oConfig[ "rac-endpoint" ]

    If Empty( cURL )
        cPlatform := GetRSKPlatform()
    Else
        cPlatform := cURL
    EndIf

    If nType == 1
        If Empty( cRacURL ) .Or. !Empty( cURL )
            If '.dev.' $ lower( cPlatform )
                cRacURL := "https://totvs.rac.dev.totvs.app"
            ElseIf 'staging' $ lower( cPlatform )
                cRacURL := 'https://totvs.rac.staging.totvs.app'
            Else
                cRacURL := "https://totvs.rac.totvs.app"
            EndIf
        EndIf
    Else
        If '.dev.' $ lower( cPlatform )
            cRacURL :=  "https://admin.rac.dev.totvs.app" 
        ElseIf 'staging' $ lower( cPlatform )
            cRacURL := 'https://admin.rac.staging.totvs.app'
        Else
            cRacURL := "https://admin.rac.totvs.app"
        EndIf
    EndIF

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )

Return cRacURL


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKGetCliPosition
Função de busca da posição do cliente na plataforma

@param cCNPJ, caracter, CNPJ do cliente para pesquisa
@param cCodCli, caracter, código do cliente para pesquisa
@param cLojCli, caracter, loja do cliente para pesquisa
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@param nEntity, number, numero que define o tipo de operação 5=CONCESSION, 10=CLIENTPOSITION
@param cOrigem, caracter, possui a informação da rotina de origem da informação
@param cTabela, caracter, possui a informação da tabela de origem da informação
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@return array, vetor com os dados de posição do cliente
    [1] - Limite de compra disponível
    [2] - Limite de compra liberado
    [3] - Limite de compra pré-autorizado
    [4] - Limite de compra total
    [5] - Limite de compra utilizado
    [6] - Número de dias atraso
    [7] - Status do cliente
    [8] - Código do retorno
    [9] - Mensagem de retorno

@author  Marcia Junko
@since   06/08/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKGetCliPosition( cCNPJ As Character, cCodCli As Character, cLojCli As Character, lAutomato As Logical, nEntity As Numeric, cOrigem As Character, cTabela As Character, aParam As Array ) As Array
    Local aSVAlias   As Array
    Local oResult    As Object
    Local oLimit     As Object
    Local oModel     As Object
    Local oMdlAR3    As Object
    Local aInfo      As Array
    Local aFatPra    As Array
    Local aError     As Array
    Local cResult    As Character
    Local cAddParam  As Character
    Local cEndPoint  As Character
    Local nOperation As Numeric

    DEFAULT cCodCli     := ''
    DEFAULT cLojCli     := ''
    Default lAutomato   := .F.
    Default nEntity     := 0
    Default cTabela     := ''
    Default cOrigem     := ''
    Default aParam      := {}    

    aSVAlias   := GetArea()
    oResult    := Nil
    oLimit     := Nil
    oModel     := Nil
    oMdlAR3    := Nil
    aInfo      := {}
    aFatPra    := {}
    aError     := {}
    cResult    := ''
    cAddParam  := ''
    cEndPoint  := '/api-customer/api/v2/customers/position'
    nOperation := MODEL_OPERATION_INSERT

    If AliasInDic( "AR3" ) .And. AliasInDic( "AR5" ) 
        DBSelectArea( "SA1" )
        
        IF( Empty(cCodCli) .or. Empty(cLojCli) ) 
            DBSetOrder(3)   //A1_FILIAL+A1_CGC
            If DBSeek( xFilial( "SA1" ) + cCNPJ )
                lRet := .t.
            EndIF
        Else
            DBSetOrder(1)
            If DBSeek( xFilial( "SA1" ) + cCodCli + cLojCli )
                lRet := .t.
            EndIf
        ENDIF

        IF lRet
    
            If !Empty(SA1->A1_CGC)
                AR3->( DBSetOrder(1) )    //AR3_FILIAL+AR3_CODCLI+AR3_LOJCLI
                If AR3->( DBSeek( xFilial( "AR3" ) + SA1->A1_COD + SA1->A1_LOJA ) )
                    nOperation := MODEL_OPERATION_UPDATE
                EndIf 

                If __lRegistry
                    cEndPoint := __oTFRegistry:oUrlTF["risk-totvsrisk-position-V2"]
                EndIf
                cAddParam := '?CnpjCpf=' + cCNPJ
                cResult := RunPlatEndpoint( cEndPoint, cAddParam, 2, lAutomato, nEntity, cOrigem, cTabela, aParam )

                If !Empty(cResult)
                    aFatPra := RSKTermBilling( cCNPJ, lAutomato )   
                    If FWJsonDeserialize( cResult, @oResult )
                        If AttIsMemberOf( oResult, "CnpjCpf" ) 
                            IF !oResult:CNPJCPF == Nil
                                If AttIsMemberOf( oResult, "limiteCompra" )
                                    oLimit  := oResult:limiteCompra
                                    Aadd( aInfo,  oLimit:limiteCompraDisponivel )
                                    Aadd( aInfo,  oLimit:limiteCompraLiberado )
                                    Aadd( aInfo,  oLimit:limiteCompraPreAutorizado )
                                    Aadd( aInfo,  oLimit:limiteCompraTotal )
                                    Aadd( aInfo,  oLimit:limiteCompraUtilizado )
                                    Aadd( aInfo,  oResult:numeroDiasAtraso )
                                    Aadd( aInfo,  IIF(oResult:statusClienteDesc == Nil, 'Vazio', DecodeUTF8(oResult:statusClienteDesc )) )
                                    Aadd( aInfo,  oResult:tipoCliente )
                                    Aadd( aInfo,  IIF(oResult:mensagemRetorno == Nil, 'Vazio', DecodeUTF8( oResult:mensagemRetorno )) )
                                    Aadd( aInfo,  IIF( len(aFatPra) > 0 ,  aFatPra[1], .T. ))
                                    If AttIsMemberOf( oResult, "enableLongTermConditions" )
                                        Aadd( aInfo, IIf(oResult:enableLongTermConditions, '1', '2' ) )
                                        Aadd( aInfo, IIf(oResult:enableLongTermConditions, STR0026 + cValToChar( oResult:maximumDaysLongTerm ) + STR0027, '' ) ) // "Liberado para " ### " dias."
                                    EndIf
                                    
                                    FreeObj( oLimit )
                                EndIf
                            ENDIF
                        EndIf
                    EndIf
                EndIf

                oModel := FwLoadModel( "RSKA040" )
                oModel:SetOperation( nOperation )
                oModel:Activate()

                If oModel:IsActive() 
                    
                    oMdlAR3 := oModel:GetModel( "AR3MASTER" )   

                    If nOperation == MODEL_OPERATION_INSERT 
                        oMdlAR3:SetValue( "AR3_CODCLI", SA1->A1_COD ) 
                        oMdlAR3:SetValue( "AR3_LOJCLI", SA1->A1_LOJA )
                        oMdlAR3:SetValue( "AR3_NOMCLI", PadR( SA1->A1_NOME, TamSX3( "AR3_NOMCLI" )[1] ) )   
                    EndIf

                    If !Empty( aInfo )
                        oMdlAR3:SetValue( "AR3_CREDIT", "1" )                               //Crédito Parceiro? Sim
                        oMdlAR3:SetValue( "AR3_LIMITE", aInfo[4] )                          //Limite Atual
                        oMdlAR3:SetValue( "AR3_LIMDIS", aInfo[1] )                          //Limite Disponivel
                        oMdlAR3:SetValue( "AR3_LIMLIB", aInfo[2] )                          //Limite Liberado
                        oMdlAR3:SetValue( "AR3_LIMPRE", aInfo[3] )                          //Limite Pre-Autorizado
                        oMdlAR3:SetValue( "AR3_TOTFAT", aInfo[5] )                          //Total Faturado
                        oMdlAR3:SetValue( "AR3_DIASAT", aInfo[6] )                          //Dias de atraso
                        oMdlAR3:SetValue( "AR3_SITPAR", Capital( aInfo[7] ) )               //Status do Cliente
                        oMdlAR3:SetValue( "AR3_TIPCLI", aInfo[8] )                          //Tipo de Cliente
                        oMdlAR3:SetValue( "AR3_DTATUA", FWTimeStamp( 1, Date(), Time() ) )  //Data/Hora da atulização
                        oMdlAR3:SetValue( "AR3_FATPRA", aInfo[10] )                         //Permite Faturamento a Prazo no parceiro.
                        If AR3->( ColumnPos( "AR3_LONGTE" ) ) > 0 .And. Len( aInfo ) > 10
                            oMdlAR3:SetValue( "AR3_LONGTE", aInfo[11] )                     //Permite Faturamento Mais Negócios Mais Longo.
                            oMdlAR3:SetValue( "AR3_DESCLG", aInfo[12] )                     //Descrição em dias do Faturamento Mais Negócios Mais Longo.
                        EndIf
                    Else
                        oMdlAR3:SetValue( "AR3_DTATUA", FWTimeStamp( 1, Date(), Time() ) )            //Data/Hora da atulização
                        oMdlAR3:SetValue( "AR3_FATPRA", IIF( Len( aFatPra ) > 0 , aFatPra[1], .T. ) ) //Permite Faturamento a Prazo no parceiro.
                        Aadd( aInfo, 0 ) //oLimit:limiteCompraDisponivel
                        Aadd( aInfo, 0 ) //oLimit:limiteCompraLiberado
                        Aadd( aInfo, 0 ) //oLimit:limiteCompraPreAutorizado
                        Aadd( aInfo, 0 ) //oLimit:limiteCompraTotal
                        Aadd( aInfo, 0 ) //oLimit:limiteCompraUtilizado
                        Aadd( aInfo, 0 ) //oResult:numeroDiasAtraso
                        Aadd( aInfo, '' ) //oResult:statusClienteDesc
                        Aadd( aInfo, '' ) //oResult:tipoCliente
                        Aadd( aInfo, '' ) //oResult:mensagemRetorno
                        Aadd( aInfo, IIF( Len(aFatPra) > 0 ,  aFatPra[1], .T. ) )
                        If AR3->( ColumnPos( "AR3_LONGTE" ) ) > 0
                            Aadd( aInfo, '2' ) //Permite Faturamento Mais Negócios Mais Longo.
                            Aadd( aInfo, '' )  //Descrição em dias do Faturamento Mais Negócios Mais Longo.
                        EndIf
                    EndIf
    
                    If oModel:VldData()
                        oModel:CommitData()
                    Else
                        aError	:= oModel:GetErrorMessage() 
                        Help( "", 1, "RSKGetCliPosition", , aError[6], 1 )            
                    EndIf
                Else
                     aError	:= oModel:GetErrorMessage()
                     Help( "", 1, "RSKGetCliPosition", , aError[6], 1 ) 
                EndIf
            EndIf
        EndIf
    EndIf   

    RestArea( aSVAlias )
    
    FWFreeArray( aSVAlias )
    FWFreeArray( aError )
    FWFreeArray( aFatPra )
    FreeObj( oResult )
    FreeObj( oModel )
    FreeObj( oMdlAR3 )
    FreeObj( oLimit )
Return aInfo

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKTermBilling
Função que identifica se o cliente tem permissão de faturamento a prazo no parceiro 
com base na API disponibilizada pela plataforma de crédito

@param cCNPJ, caracter, CNPJ do cliente para pesquisa
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, vetor com os dados de posição do cliente
    [1] - Identifica se o cliente tem permissão de faturamento a prazo ( "true' ou "false" )
    [2] - Motivo
    [3] - Código do retorno
    [4] - Mensagem de retorno

@author  Marcia Junko
@since   06/08/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKTermBilling( cCNPJ As Character, lAutomato As Logical ) As Array
    Local aSVAlias  As Array
    Local oContent  As Object
    Local oBilling  As Object
    Local aInfo     As Array
    Local cResult   As Character
    Local cAddParam As Character
    Local cEndPoint As Character

    Default lAutomato := .F.

    aSVAlias  := GetArea()
    oContent  := NIL
    oBilling  := NIL
    aInfo     := {}
    cResult   := ''
    cAddParam := ''
    cEndPoint := '/api-customer/api/billing/installment_sale'

    If !Empty( cCNPJ )
        cAddParam := '/' + alltrim(cCNPJ)

        If __lRegistry
            cEndPoint := __oTFRegistry:oUrlTF["risk-totvsrisk-installment-sale-V1"]
        EndIf
        cResult := RunPlatEndpoint( cEndPoint, cAddParam, 2, lAutomato )

        If !Empty( cResult )
            If FWJsonDeserialize( cResult, @oContent )
                If AttIsMemberOf( oContent:result, "faturamentoAPrazoParceiro" ) 
                    oBilling := oContent:result:faturamentoAPrazoParceiro

                    IF !oBilling == Nil
                        Aadd( aInfo,  IIf( oBilling:permiteFaturarAPrazoNoParceiro == "S", .T., .F. ) )
                        Aadd( aInfo,  IIF( oBilling:motivo == Nil, 'Vazio', DecodeUTF8( oBilling:motivo ) ) )
                        Aadd( aInfo,  oContent:result:codigoRetorno )
                        Aadd( aInfo,  IIF( oContent:result:mensagemRetorno == Nil, 'Vazio', DecodeUTF8( oContent:result:mensagemRetorno ) ) )
                    Endif
                EndIf
            EndIF
        EndIf 
    EndIf

    RestArea( aSVAlias )
    
    FWFreeArray( aSVAlias )
    FreeObj( oContent )
    FreeObj( oBilling )
Return aInfo

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKBankSlip
Função que retorna o Boleto atualizado com base na API disponibilizada pela plataforma
de crédito.

@param cCNPJ, caracter, CNPJ do cliente para pesquisa
@param cTitulo, caracter, número do título
@param cParc,  caracter, Numero da parcela
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, vetor com os dados de posição do cliente
    [1] - Mensagem de retorno
    [2] - Boleto
    [3] - Data do retorno

@author  Rodrigo G. Soares
@since   26/10/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKBankV1( cCNPJ As Character, cTitulo As Character, cParc As Character, lAutomato As Logical ) As Array
    Local aSVAlias  As Array
    Local oResult   As Object
    Local oBilling  As Object
    Local aInfo     As Array
    Local cResult   As Character
    Local cAddParam As Character
    Local cEndPoint As Character
    
    Default cParc     := ''
    Default lAutomato := .F.

    aSVAlias  := GetArea()
    oResult   := NIL
    oBilling  := NIL
    aInfo     := {}
    cResult   := ''
    cAddParam := ''
    cEndPoint := '/api-customer/api/v1/bankslip'

    If !Empty( cCNPJ )
        If __lRegistry
            cEndPoint := __oTFRegistry:oUrlTF["risk-totvsrisk-bankslip-V1"]
        EndIf
        cEndPoint += '/' + cCNPJ + '/' + cTitulo

        If !Empty( alltrim( cParc ) )
            cEndPoint += '/' + cParc
        EndIf

        cResult := RunPlatEndpoint( cEndPoint, cAddParam, 2 )

        If !Empty( cResult )
            If FWJsonDeserialize( cResult, @oResult )
                Aadd( aInfo,  IIF( oResult:mensagemRetorno == Nil, 'Vazio', DecodeUTF8( oResult:mensagemRetorno ) ) )
                Aadd( aInfo,  IIF( oResult:boleto == Nil, '', DecodeUTF8( oResult:boleto ) ) )
                Aadd( aInfo,  IIF( oResult:DATAHORARETORNO == Nil, '', DecodeUTF8( oResult:DATAHORARETORNO ) ) )
            EndIF
        EndIf 
    EndIf

    RestArea( aSVAlias )
    
    FWFreeArray( aSVAlias )
    FreeObj( oResult )
    FreeObj( oBilling )
Return aInfo

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKSeekBankSlip
Função que retorna os dados do boleto

@param cCNPJ, caracter, CNPJ do cliente para pesquisa

@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, vetor com os dados do boleto
    [1] - Boleto
    [2] - Código do retorno
    [3] - Mensagem de retorno

@author  Marcia Junko
@since   06/08/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKSeekBankSlip( cCNPJ, cTransac, cParcela, lAutomato )
    Local aSVAlias := GetArea()
    Local oResult := NIL
    Local aInfo := {}
    Local cResult := ''
    Local cAddParam := ''
    Local cEndPoint := '/api-customer/api/bankslip'
    
    Default cTransac := ''
    Default cParcela := ''
    Default lAutomato := .F.
    
    If !Empty( cCNPJ )
        cAddParam += '/' + cCNPJ
        If !Empty( cTransac )
            cAddParam += '/' + cTransac 
        EndIf 
        If !Empty(cParcela)
            cAddParam += '/' + cParcela  
        EndIf

        cResult := RunPlatEndpoint( cEndPoint, cAddParam, 2 )
        If !Empty(cResult)
            If FWJsonDeserialize( cResult, @oResult )
                Aadd( aInfo,  oResult:boleto )
                Aadd( aInfo,  oResult:codigoRetorno )
                Aadd( aInfo,  IIF( type('oResult:mensagemRetorno' ) == 'U', 'Vazio', DecodeUTF8( oResult:mensagemRetorno ) ) )
            EndIF
        EndIf
    EndIf 

    RestArea( aSVAlias )
    
    FWFreeArray( aSVAlias )
    FreeObj( oResult )
Return aInfo

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RunPlatEndpoint
Função que executa os endpoints da plataforma com autenticação.

@param cEndpoint, caracter, Endpoint a executar
@param cAddHeader, caracter, informações adicionais para o header
@param nType, number, tipo de URL a ser executada ( PROVISÓRIO )
    1 = Altera a URL para o conteúdo do parâmetro 
    2 = Altera a URL para um endereço específico
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@param nEntity, number, numero que define o tipo de operação 5=CONCESSION, 10=CLIENTPOSITION
@param cOrigem, caracter, possui a informação da rotina de origem da informação
@param cTabela, caracter, possui a informação da tabela de origem da informação
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@return caracter, dados retornados pelo endpoint
@author  Marcia Junko
@since   06/08/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RunPlatEndpoint( cEndPoint As Character, cAddParam As Character, nType As Numeric, lAutomato As Logical, nEntity As Numeric, cOrigem As Character, cTabela As Character, aParam As Array ) As Character
    Local oRest      As Object
    Local cHost      As Character
    Local cPlatform  As Character
    Local cResult    As Character
    Local cResultLog As Character
    Local aToken     As Array
    Local aHeader    As Array
    Local lRet       As Logical

    Default cAddParam := ''
    Default nType     := 1
    Default lAutomato := .F.
    Default nEntity   := 0
    Default cTabela   := ''
    Default cOrigem   := ''
    Default aParam    := {}

    oRest      := Nil
    cHost      := ''  
    cPlatform  := ''  
    cResult    := ''  
    cResultLog := ''  
    aToken     := {}
    aHeader    := {}
    lRet       := .F.

    If !lAutomato
        If __lRegistry
            cHost     := cEndPoint
            cEndPoint := ""
        Else
            cHost := GetRSKPlatform( .F. )
        EndIf
        If !Empty( cHost )
            aToken := RskRacAccess( cPlatform, 2 )
            If !Empty( aToken )
                AAdd( aHeader, "Content-Type: application/json" ) 
                AAdd( aHeader, "Accept: application/json" )
                AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )  
                AAdd( aHeader, "Authorization: Bearer " + aToken[2] )

                oRest := FWRest():New( cHost )
                oRest:setPath( cEndPoint + cAddParam)
                lRet  := oRest:Get( aHeader )
                If lRet
                    cResult    := oRest:GetResult()
                    cResultLog := cResult
                Else
                    LogMsg( "RunPlatEndpoint", 23, 6, 1, "", "", "RunPlatEndpoint -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )  
                    cResultLog := cHost + " " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) + ' HttpCode: '+cValtoChar(oRest:GetHTTPCode()) 
                EndIf
            EndIf
        EndIf  
    EndIf

    If __lTechFinlog .And. nEntity > 0 .And. Len( cResultLog ) > 28
        If __oTechFinlog == Nil
            __oTechFinlog := TechFinLog():New()
        EndIf
        If __oTechFinlog:lIntegLog
            RskInsertLog(/*cJSON*/ '', RSKGET, cHost + cEndPoint + cAddParam, cResultLog, lRet, cTabela, cOrigem, aParam)
        EndIf
    Endif

    FWFreeArray( aHeader )
    FWFreeArray( aToken )
    FreeObj( oRest )
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} RskCdPgPay()
Função chamada para retornar se condição de pagamento é Totvs Pay.

@param cNumPed, caracter, Número do Pedido de Venda.

@return boolean, indica se integra ou não com Totvs Pay
@author  TECHFIN
@since   07/08/2020
/*/
//-------------------------------------------------------------------
Function RskCdPgPay( cNumPed )
    Local aAreaRsk := GetArea()
    Local aAreaSC5	:= SC5->( GetArea() )
    Local lRskTPay := .F. 

    Default cNumPed := ""

    dbSelectArea( "SC5" )
    SC5->( DbSetOrder(1) )    // C5_FILIAL+C5_NUM

    If SC5->( MsSeek( xFilial( "SC5" ) + cNumPed ) )
        lRskTPay := RskIsTPayCond( SC5->C5_CONDPAG )
    EndIf 

    RestArea( aAreaSC5 )
    RestArea( aAreaRsk ) 

    FWFreeArray( aAreaSC5 )
    FWFreeArray( aAreaRsk )
Return lRskTPay

//-------------------------------------------------------------------
/*/{Protheus.doc} RskDTimeUTC()
Função que converte data e hora em UTC

@param cTimeStamp, caracter, timestamp no formato aaaammddhhmmss

@return caracter, formato aaaammddhhmmss
@author  TECHFIN
@since   25/08/2020
/*/
//-------------------------------------------------------------------
Function RskDTimeUTC( cTimeStamp ) 
    Local aDateTime := {}

    Default cTimeStamp  := ""

    cTimeStamp := RskFmtTStamp( cTimeStamp )

    If !Empty( cTimeStamp )
        aDateTime  := StrTokArr( cTimeStamp, " " )
        If Len( aDateTime ) == 2
            cTimeStamp := FWTimeStamp( 5, cTod( aDateTime[1] ), aDateTime[2] )
        EndIf
    EndIf

    FWFreeArray( aDateTime )
Return cTimeStamp

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskVdPayCond
Funcao que valida se exitem tickets com a condicao de pagamento Mais Negocios.
@type function
@param oModel, object, Modelo de dados da condição de pagamento
@return logical, Indica se poderá incluir/alterar a condição de pagamento
@author Squad NT TechFin
@since  26/08/2020
/*/
//------------------------------------------------------------------------------
Function RskVdPayCond( oModel As Object ) As Logical
    Local aSvAlias   As Array
    Local lRet       As Logical
    Local cQuery     As Character
    Local oMdlSE4    As Object
    Local cTempAR0   As Character
    Local cTypeDB	 As Character
    Local cBody      As Character
    Local cEndPoint  As Character
    Local oRest      As Object
    Local oJPCond    As Object
    Local oJParcel   As Object
    Local oJResult   As Object
    Local aPayCond   As Array
    Local aJPCond    As Array
    Local aDadosSE4  As Array
    Local nLenPCond  As Numeric
    Local nX         As Numeric
    Local nOperation As Numeric

    Default oModel    := Nil
    
    If Type('lAutomato') == 'U' // Tratamento para execução via ADVPR.
        lAutomato := .F.
    EndIf

    aSvAlias   := GetArea()
    lRet       := .T.
    cQuery     := ""
    oMdlSE4    := Nil
    cTempAR0   := ""
    cTypeDB	   := Upper( TCGetDB() )
    cBody      := ""
    cEndPoint  := "/api/v1/simulate_condition"
    oRest      := Nil
    oJPCond    := Nil
    oJParcel   := Nil
    oJResult   := Nil
    aPayCond   := {}
    aJPCond    := {}
    aDadosSE4  := {}
    nLenPCond  := 0
    nX         := 1
    nOperation := 0

    If oModel != Nil 
        oMdlSE4 := oModel:GetModel( "SE4MASTER" )
        nOperation := oMdlSE4:GetOperation()
        If SE4->( ColumnPos( "E4_TPAY" ) ) > 0 .And. oMdlSE4:GetValue( "E4_TPAY" )
            If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE 
                If .Not. oMdlSE4:GetValue( "E4_TIPO" ) == "9"
                    aDadosSE4 := { oMdlSE4:GetValue( "E4_CODIGO" ), oMdlSE4:GetValue( "E4_COND" ), oMdlSE4:GetValue( "E4_TIPO" ), oMdlSE4:GetValue( "E4_DDD" ),;
                                   oMdlSE4:GetValue( "E4_IPI" ), oMdlSE4:GetValue( "E4_SOLID" ), IIf( SE4->(FieldPos("E4_ACRES")) <> 0, oMdlSE4:GetValue( "E4_ACRES" ), "N" ) }
                    aPayCond  := AvalCond( 1000, aDadosSE4[01],,,,,aDadosSE4,,aDadosSE4)

                    // Verifica se a condição de pagamento é Mais Negócios com Adiantamento e Despreza a 1ª parcela,
                    // pois não há condição de pagamento à vista na Supplier
                    If oMdlSe4:GetValue("E4_CTRADT") == "1" .And. Len(aPayCond) > 1
                        aDel(aPayCond, 1)
                        aSize(aPayCond, Len(aPayCond) - 1)
                    EndIf
                    nLenPCond := Len( aPayCond )

                    If nLenPCond > 0
                        oJPCond := JsonObject():New()
                        oJPCond["partnerDocNumber"]     := SM0->M0_CGC
                        oJPCond["requestDate"]          := DToC( dDataBase )
                        oJPCond["creditEvaluationDate"] := DToC( dDataBase )
                        oJPCond["installments"]         := nLenPCond

                        For nX := 1 To nLenPCond
                            oJParcel := JsonObject():New()
                            oJParcel["DueDate"] := DToC( aPayCond[nX][1] )
                            aAdd( aJPCond, oJParcel )
                        Next nX 
                        oJPCond["paymentConditions"]    := aJPCond

                        If __lRegistry
                            cEndPoint := __oTFRegistry:oUrlTF["risk-riskapi-simulate_condition-V1"]
                        EndIf
                        cBody := RSKRestExec( RSKPOST, cEndPoint, @oRest, oJPCond, RISK, SERVICE, .F., .F. )   // POST ### 1=Risk ### 2=URL de autenticação de serviços

                        If .Not. Empty( cBody )
                            oJResult := JSONObject():New()
                            oJResult:FromJSON( cBody )
                            lRet := oJResult['conditionCommercialIsValid']
                        Else
                            MsgInfo( STR0014, STR0013 )    //'Falha de comunicação com a API'###"Não foi possível avaliar essa condição comercial, durante a inclusão pedido de venda atente-se para as regras estabelecidas em contrato ou seu ticket poderá ser recusado."
                        EndIf
                    EndIf
                Else
                    MsgInfo( STR0017, STR0015 )    //"Condição de Pagamento Mais Negócios"###"Não é possível avaliar esse tipo de condição comercial, durante a inclusão do pedido atente-se para as regras estabelecidas em contrato ou seu ticket poderá ser recusado."
                EndIf
            EndIf

            If lRet
                cTempAR0    := GetNextAlias()
                cQuery      := " SELECT "

                If cTypeDB = "MSSQL"
                    cQuery += " TOP 1 "
                EndIf

                cQuery += " AR0_FILIAL, AR0_TICKET "  
                cQuery += " FROM " + RetSqlName( "AR0" ) + " AR0 "
                cQuery += " INNER JOIN " + RetSqlName( "SC5" ) + " SC5 "
                cQuery += " ON SC5.C5_FILIAL = AR0.AR0_FILPED "
                cQuery += " AND SC5.C5_NUM = AR0.AR0_NUMPED " 
                cQuery += " AND SC5.C5_CONDPAG = '" + oMdlSE4:GetValue( "E4_CODIGO" ) + "' " 
                cQuery += " AND SC5.D_E_L_E_T_ = ' ' "
                cQuery += " INNER JOIN " + RetSqlName( "SC9" ) + " SC9 "
                cQuery += " ON SC9.C9_FILIAL = AR0.AR0_FILPED "
                cQuery += " AND SC9.C9_PEDIDO = AR0.AR0_NUMPED " 
                cQuery += " AND SC9.C9_TICKETC = AR0.AR0_TICKET "
                cQuery += " AND SC9.C9_NFISCAL = ' ' "
                cQuery += " AND SC9.C9_SERIENF = ' ' "
                cQuery += " AND SC9.D_E_L_E_T_ = ' ' "
                cQuery += " WHERE AR0.AR0_FILIAL = '" + xFilial( "AR0" ) + "' "
                cQuery += " AND AR0.AR0_STATUS IN ( '0','1','2' ) "
                cQuery += " AND AR0.D_E_L_E_T_ = ' ' " 
                
                If cTypeDB = "ORACLE"
                    cQuery += " AND ROWNUM = 1 "
                EndIf

                If cTypeDB $ "MYSQL|POSTGRES"
                    cQuery += " LIMIT 1 " 
                EndIf 

                cQuery  := ChangeQuery( cQuery ) 
                DbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), cTempAR0, .F., .T. )

                If ( cTempAR0 )->( !Eof() ) 
                    Help( "", 1, "RSKVDPAYCOND", , STR0005, 1, 0,,,,,, { STR0006 } )    //'Não será possível alterar condição de pagamento Mais Negócios com tickets de crédito com status: Em Análise ou Aprovado (Com pedidos liberados para Faturamento).'###"Inclua uma nova condição de pagamento ou exclua os pedidos liberados que utilizam esta condição de pagamento."
                    lRet := .F.
                EndIf

                ( cTempAR0 )->( DBCloseArea() ) 
            Else
                Help( "", 1, "RSKVDPAYCOND",, STR0015, 1, 0,,,,,,{ STR0016 } )    //'Condição de Pagamento Mais Negócios'###"Não foi possível localizar a condição comercial desejada! Avalie o cadastrado de condições comerciais na plataforma TOTVS Mais Negócios."
            EndIf    
        EndIf
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aPayCond )
    FWFreeArray( aJPCond )
    FWFreeArray( aDadosSE4 )
    FreeObj( oRest )
    FreeObj( oJPCond )
    FreeObj( oJParcel )
    FreeObj( oJResult )

Return lRet        

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskEvlCredit
Função que define se haverá analise pela plataforma risk.

@param  nType , number, Tipo de pesquisa: 1= por pedido; 2= condição de pagamento
@param  cSeek , caracter, Chave de pesquisa

@return lógico, Indica se a análise será pela plataforma RISK
@author Squad NT TechFin
@since  26/10/2020
/*/
//------------------------------------------------------------------------------
Function RskEvlCredit( nType, cSeek )
    Local lRet          := .F.
    Local lOffBalance   := .F.

    Default nType := 1
    Default cSeek := ""

    If nType == 1       // avalia pelo pedido
        lOffBalance := RskCdPgPay( cSeek )
    ElseIf nType == 2   // avalia pela condição de pagamento
        lOffBalance := RskIsTPayCond( cSeek )
    EndIf

    lRet := ( RskType() == 1 .Or. ( RskType() == 2 .And. lOffBalance ) )
Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskFillSC9
Função que preenche a liberação do pedido conforme as regras do risk.

@author Squad NT TechFin
@since  26/10/2020
/*/
//------------------------------------------------------------------------------
Function RskFillSC9()  
    Local cTicketId := RskGetMTkt() 
    
    //Reuso do ticket na proxima liberação
    If !Empty( cTicketId )
        SC9->C9_TICKETC := cTicketId    
    EndIf   
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskTermB
Função que valida se o cliente pode ser faturado de acordo com a Supplier e a 
condição de pagamento.

@param  cChaveSA1 , caracter    , A1_COD+A1_LOJA
@param  cCondPag , caracter    , Código da Condição de pagamento

@return lógico, define se o cliente pode ser faturado
@author Squad NT TechFin
@since  06/11/2020
/*/
//------------------------------------------------------------------------------
Function RskTermB( cChaveSA1, cCondPag )  
    Local lRskTermB := .T.
    Local aInfo     := {}
    Local aParcelas := {}
    Local cDt       := ""
    Local nParcelas := 0
    Local lAutomato := .F.
    Local lAtualiza := .T.
    Local nDias := 0
	Local cElapTime := ""
	Local nMinutos := 0
    Local cTimeAtu := ""
    Local dDateAtu := CTOD("//")
	Local nRskMinu := SUPERGETMV("MV_RSKMACL", .F., 300)

    aParcelas := CONDICAO( 100, cCondPag )
    nParcelas := Len( aParcelas )

    //------------------------------------------------------------------------------
    // Valida a posição do cliente se for uma venda a prazo 
    // ( mais de uma parcela ou vencimento a vista em até 6 dias.)
    //------------------------------------------------------------------------------
    If ( nParcelas > 1 .Or. ( nParcelas == 1 .And. aParcelas[1][1] > Date() + 6 ) )
        AR3->(dbSetOrder(1)) // AR3_FILIAL + AR3_CODCLI + AR3_LOJCLI
        If AR3->(MsSeek( xFilial( "AR3" ) + cChaveSA1 ))
            cDt := AR3->AR3_DTATUA
            dDateAtu := CTOD(SubStr(cDt, 7, 2) + "/" + SubStr(cDt, 5, 2) + "/" + SubStr(cDt, 1, 4)) 
            nDias := DateDiffDay(dDateAtu, Date()) 
            If (!Empty(cDt)) .and. dDateAtu <= Date() .and. nDias <= 1
                cTimeAtu := SubStr(cDt, 9, 2) + ":" + SubStr(cDt,11, 2) + ":" + SubStr(cDt,13, 2)
                If ! ((nDias == 0 .and. cTimeAtu > Time()) .or. (nDias == 1 .and. cTimeAtu <= Time()))
                    If nRskMinu > 1440  
                        nRskMinu := 1440
                    ElseIf nRskMinu < 1 
                        nRskMinu := 300
                    EndIf
                    cElapTime := ElapTime(cTimeAtu, Time())
                    nMinutos := (Val(SubStr(cElapTime, 1, 2)) * 60) + (Val(SubStr(cElapTime, 4, 2))) + (Val(SubStr(cElapTime, 7, 2)) / 60)
                    If nMinutos < nRskMinu 
                        lAtualiza := .F.    
                    EndIf
                EndIf
            Endif 

            //------------------------------------------------------------------------------
            // Não traduzir os textos do AT, pois ele vem da plataforma
            //------------------------------------------------------------------------------
            If ! lAtualiza
                IF ( AT( 'Bloqueado Por Atraso', AR3->AR3_SITPAR ) > 0 ) .or. AR3->AR3_FATPRA == .F.
                    lRskTermB := .F.
                EndIF
            else
                aInfo := RskGetCliPosition( SA1->A1_CGC, NIL, NIL, lAutomato )

                if len( aInfo ) > 0
                    IF ( AT( 'Bloqueado Por Atraso', Capital( aInfo[7] ) ) > 0 ) .or. aInfo[10] == .F.
                        lRskTermB := .F.
                    EndIF
                EndIf
            EndIf
        else
            aInfo := RSKGetCliPosition( SA1->A1_CGC, NIL, NIL, lAutomato )

            if len( aInfo ) > 0
                //------------------------------------------------------------------------------
                // Não traduzir os textos do AT, pois ele vem da plataforma
                //------------------------------------------------------------------------------
                IF ( AT('Bloqueado Por Atraso', Capital( aInfo[7] ) ) > 0 ) .or. aInfo[10] == .F.
                    lRskTermB := .f.
                EndIF
            EndIf		
        EndIf
    EndIf

    FWFreeArray( aParcelas )
    FWFreeArray( aInfo )
Return lRskTermB

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskIsTPayCond
Função que avalia se a condição de pagamento é TOTVS Mais Negócio.

@param  cPayCond, caracter, Condição de pagamento

@return logico, Retorna se a condição de pagamento é relacionada ao TOTVS Mais Negócio
@author Marcia Junko
@since  11/11/2020
/*/
//------------------------------------------------------------------------------
Function RskIsTPayCond( cPayCond )
    Local aArea         := GetArea()
    Local aAreaSE4      := SE4->( GetArea() )
    Local lTPay         := .F.

    Default cPayCond    := ""

    If !Empty( cPayCond )
        SE4->( DbSetOrder(1) )  // E4_FILIAL+E4_CODIGO
        If SE4->( MsSeek( xFilial( "SE4" ) + cPayCond ) )
            If SE4->( ColumnPos( "E4_TPAY" ) ) > 0
                lTPay := SE4->E4_TPAY
            EndIf
        EndIf
    EndIf

    RestArea( aAreaSE4 )
    RestArea( aArea )
    
    FWFreeArray( aArea )
    FWFreeArray( aAreaSE4 )
Return lTPay

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskSeekNature
Esta função retorna a natureza de acordo com o tipo informado

@param nType, number, Indica o tipo de natureza a pesquisar, sendo: 1=Receita e 2=Despesa
@param @cMessage, caracter, Armazena a mensagem de erro ao criar a natureza.

@return caracter, Código da natureza de acordo com o tipo informado.
@author  Marcia Junko
@since   04/12/2020
/*/
//-------------------------------------------------------------------------------------
Function RskSeekNature( nType, cMessage )
    Local aSvAlias  := GetArea()
    Local aAreaSED  := SED->( GetArea() )
    Local cParam    := ''
    Local cCodeNature := ''
    Local cContent  := ''
    Local cSeek     := ''
    Local lAssignParam := .F.

    Default cMessage := ''
    
    DBSelectArea( "SED" )
    SED->( DBSetOrder(1) )  //ED_FILIAL + ED_CODIGO

    IF nType == INCOME_NATURE
        cParam := 'MV_RSKNATR'
        cCodeNature := 'MN RECEITA'
    Else
        cParam := 'MV_RSKNATD'
        cCodeNature := 'MN DESPESA'
    EndIf

    cContent := SuperGetMV( cParam, .F., ' ' )

    If !Empty( cContent )
        cSeek := cContent
    Else
        cSeek := cCodeNature
    EndIF

    If SED->( !( MSSeek( xFilial( "SED" ) + cSeek ) ) )
        cMessage := RSKMakeNature( nType, cSeek )

        IF Empty( cMessage )
            lAssignParam := .T.
        EndIf
    EndIf

    If lAssignParam .Or. Empty( cContent ) 
        Putmv( cParam, cSeek )
    EndIf

    RestArea( aSvAlias )
    RestArea( aAreaSED )

    FWFreeArray( aSvAlias )
    FWFreeArray( aAreaSED )
Return cSeek

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKMakeNature
Esta função é reponsável por criar a natureza do TOTVS Mais Negócios na tabela SED.

@param nType, number, Indica o tipo de natureza a pesquisar, sendo: 1=Receita e 2=Despesa
@param cSeek, caracter, Recebe a natureza que deve ser criada.

@return caracter, Mensagem de erro ao criar a natureza.
@author  Marcia Junko
@since   04/12/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKMakeNature( nType, cSeek )
    Local aSvAlias := GetArea()
    Local aAreaSED := SED->( GetArea() )
    Local cCode := ''
    Local cDescription := ''
    Local cCond := ''
    Local cRet  := ''

    Default cSeek := ''

    DBSelectArea( "SED" )
    SED->( DBSetOrder(1) )  //ED_FILIAL + ED_CODIGO

    IF nType == INCOME_NATURE
        cCode := 'MN RECEITA'
        cDescription := STR0007     //'Receita Totvs Mais Negócios'
        cCond := 'R'
    Else
        cCode := 'MN DESPESA'
        cDescription := STR0008     //'Despesa Totvs Mais Negócios'
        cCond := 'D'
    EndIf

    If !Empty( cSeek )
        cCode := cSeek
    EndIF

    RecLock( "SED" , .T. )
        SED->ED_FILIAL      := xFilial( "SED" )
        SED->ED_CODIGO      := cCode
        SED->ED_DESCRIC     := cDescription
        SED->ED_CALCIRF     := "N"  
        SED->ED_CALCISS     := "N"  
        SED->ED_CALCINS     := "N"  
        SED->ED_CALCCSL     := "N"  
        SED->ED_CALCCOF     := "N"  
        SED->ED_CALCPIS     := "N"  
        SED->ED_DEDPIS      := "2"  
        SED->ED_DEDCOF      := "2"  
        SED->ED_TIPO        := "2"  
        SED->ED_COND        := cCond
    MsUnLock()

    IF !( SED->( MSSeek( xFilial( "SED" ) + cCode ) ) )
        cRet := I18N( STR0009, { cCode } )    //"Falha ao criar a natureza #1"
    EndIf

    RestArea( aSvAlias )
    RestArea( aAreaSED )

    FWFreeArray( aSvAlias )
    FWFreeArray( aAreaSED )
Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKConfirm
Esta função é reponsável por confirmar um registro na Plataforma, quando há apenas
a chave para a confirmação do resgistro.

@param cKey  - Guide responsavel para confirmar o registro.
@param nType - Tipo de operação que está realizando a confirmação do registro.
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return lRet - Retorno lógico da execução do processo.
@author  Rodrigo Soares
@since   22/01/2021
/*/
//-------------------------------------------------------------------------------------
Function RSKConfirm( cKey As Character, nType As Numeric, lAutomato As Logical ) As Logical
    Local oRest   As Object
    Local cBody   As Character
    Local cAction As Character
    Local cResult As Character
    Local lRet    As Logical
    Local cTabela As Character
    Local cOrigem As Character

    Default lAutomato := .F.

    oRest   := FWRest():New( )
    cBody   := ""
    cAction := ''
    cResult := ""
    lRet    := .F.
    cTabela := ""
    cOrigem := ""

    If __lRegistry
        Do Case
            Case nType == UPDARINVOICE
                cAction := __oTFRegistry:oUrlTF["risk-protheusapi-invoice-partner-V3"] +'/'+ cKey +'/confirmation'
                cTabela := 'AR1'
                cOrigem := 'RSKA020'
            Case nType == NFSCANCEL
                cAction := __oTFRegistry:oUrlTF["risk-protheusapi-invoice-cancellation-V3"] +'/'+ cKey +'/confirmation'
                cTabela := 'AR1'
                cOrigem := 'RSKA020'
            Case nType == CLIENTPOSITION
                cAction := __oTFRegistry:oUrlTF["risk-protheusapi-position-V1"] +'/'+ cKey +'/confirmation'
                cTabela := 'AR3'
                cOrigem := 'RSKA040'
        EndCase
    Else
        Do Case
            Case nType == UPDARINVOICE
                cAction := '/protheus-api/v3/invoice_partner/' + cKey +'/confirmation'
                cTabela := 'AR1'
                cOrigem := 'RSKA020'
            Case nType == NFSCANCEL
                cAction := '/protheus-api/v3/invoice_cancellation/' + cKey +'/confirmation'
                cTabela := 'AR1'
                cOrigem := 'RSKA020'
            Case nType == CLIENTPOSITION
                cAction := '/protheus-api/v1/position/' + cKey +'/confirmation'
                cTabela := 'AR3'
                cOrigem := 'RSKA040'                
        EndCase
    EndIf

    If !lAutomato
        cResult := RSKRestExec( RSKPUT, cAction, @oRest, cBody, RISK, SERVICE, .F., .F., nType, cTabela, cOrigem )   // POST ### 1=Risk ### 2=URL de autenticação de serviços
    EndIf

    if lAutomato .Or. len(cResult) > 0 
        lRet := .T.
    Else
        IF !lAutomato
            LogMsg( "RSKConfirm", 23, 6, 1, "", "", "RSKConfirm --> " + oRest:GetLastError() )
        EndIf
    ENDIF

    FreeObj( oRest )

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKRestExec
Função que executa o verbo GET dos endpoints da plataforma com autenticação 

@param cAction, caracter, Identifica qual a ação do Rest será chamada (GET, POST ou PUT)
@param cPath, caracter, Endpoint a executar
@param @cErrorMsg, caracter, Mensagem de erro do método POST
@param @oRest, object, Objeto Rest de retorno para a função chamadora
@param xValues, any, Conteúdo a ser trasmitido pelo serviço nas chamadas de POST e PUT
@param nTypePlat, number, Indica em qual plataforma será feita a consulta
    1 - Risk
    2 - Antecipa
@param nTypeAuth, number, identifica qual a URL do RAC utiliza
    1 - autenticação
    2 - admin ( autenticação de serviços )
@param lCompanyID, boolean, indica se adiciona a propriedade companyId no aHeader da requisição
@param lProtheusAPI, boolean, indica se irá utilizar um endpoint do protheus-api
@param nEntity, number, numero que define o tipo de operação 1=NEWTICKET/2=UPDTICKET/3=UPDARINVOICE/4=AFTERSALES/5=CONCESSION/6=SEM USO/7=NFSCANCEL=Cancelamento de NFS Mais Negócios/9=CONCILIATION
@param cOrigem, caracter, possui a informação da rotina de origem da informação
@param cTabela, caracter, possui a informação da tabela de origem da informação
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@return caracter, Result da requisição.
@author  Marcia Junko
@since   23/08/2021
/*/
//-------------------------------------------------------------------------------------
Function RSKRestExec( cAction As Character, cPath As Character, oRest As Object, xValues, nTypePlat As Numeric, nTypeAuth As Numeric, lCompanyID As Logical, lProtheusAPI As Logical, nEntity As Numeric, cTabela As Character, cOrigem As Character, aParam As Array)
    Local aToken     As Array
    Local aHeader    As Array
    Local cHost      As Character
    Local cPlatform  As Character
    Local cResult    As Character
    Local cResultLog As Character
    Local cJSON      As Character
    Local lRet       As Logical
    
    Default cAction       := RSKGET       // Ação GET do REST
    Default oRest         := NIL
    Default xValues       := ''
    Default nTypePlat     := RISK         // 1=Plataforma RISK
    Default nTypeAuth     := SERVICE      // 2=URL de autenticação de serviços
    Default lCompanyID    := .T.
    Default lProtheusAPI  := .T.
    Default nEntity       := 0
    Default cTabela       := ''
    Default cOrigem       := ''
    Default aParam        := {}
        
    aToken    := {}
    aHeader   := {}
    cHost     := ''
    cPlatform := ""
    cResult   := ''
    cResultLog := ''
    lRet      := .F.
    cJSON     := ''

    IF ( cAction == RSKGET .Or. cAction == RSKPUT .Or. ( ( Valtype( xValues ) == "J" .And. len( xValues:Getnames() ) > 0 ) .Or. ( Valtype( xValues ) == "A" .And. !Empty( xValues ) ) ) )

        If __lRegistry
            cHost := cPath
            cPath := ""
        Else
            If nTypePlat == RISK    // 1=Plataforma RISK
                cHost := GetRSKPlatform( lProtheusAPI )
            else
                cHost := RSKURLAntecipa()
                cPlatform := cHost
            EndIf
        EndIf

        aToken := RskRacAccess( cPlatform, nTypeAuth ) 

        If !Empty( aToken )
            AAdd( aHeader, "Content-Type: application/json" )  
            AAdd( aHeader, "Charset: UTF-8")
            AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )  
            AAdd( aHeader, "Authorization: Bearer " + aToken[2] )
            If lCompanyID
                AAdd( aHeader, "companyID: " + cEmpAnt )
            EndIf

            oRest := FWRest():New( cHost ) 
            oRest:SetPath( cPath )

            Do Case 
                Case cAction == RSKGET      // GET
                    lRet := oRest:Get( aHeader )
                Case cAction == RSKPOST     // POST
                    cJSON := EncodeUTF8( FwJsonSerialize( xValues ) )
                    oRest:SetPostParams( cJSON )

                    lRet := oRest:Post( aHeader )
                Case cAction == RSKPUT      // PUT
                    lRet := oRest:Put( aHeader, xValues )
            EndCase

            If lRet
                cResult := oRest:GetResult()
                cResultLog := cResult
            Else
                cResultLog := cHost + " " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) + ' HttpCode: '+cValtoChar(oRest:GetHTTPCode()) 
            EndIf

        EndIf

        If __lTechFinlog .And. nEntity > 0 .And. .Not. ( cAction == RSKGET .And. Len( cResultLog ) <= 38 )
            If __oTechFinlog == Nil
                __oTechFinlog := TechFinLog():New() //instancia a classe log
            EndIf
            If __oTechFinlog:lIntegLog
                RskInsertLog(cJSON, cAction, cHost+cPath, cResultLog, lRet, cTabela, cOrigem, aParam)
            EndIf
        Endif
    EndIf

    FWFreeArray( aToken )
    FWFreeArray( aHeader )
Return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKURLAntecipax'
Função que obtém a URL da plataforma Antecipa

@return caracter, URL da plataforma Antecipa ( Pós-Venda )
@author  Marcia Junko
@since   26/08/2021
/*/
//-------------------------------------------------------------------------------------
Function RSKURLAntecipa( ) 
    Local oConfig  
    Local cURL := ''

    oConfig := FWTFConfig()
    cURL := oConfig[ "platform-endpoint" ]   
Return cURL

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RSKTRBFields
Função responsável por montar a estrutura do vetor aHeader e aStruct para montar o
componente GetDB.

@param aFields, array, lista de campos para pesquisa

@return array, vetor com os dados relativo aos campos passados no parâmetro, onde:
    [1] - aHeader
    [2] - aStruct
@author Marcia Junko
@since 24/02/2021
/*/
//----------------------------------------------------------------------------------
Function RSKTRBFields( aFields )
    Local aSvAlias := GetArea()
    Local aInfo := {}
    Local aHeader := {}
    Local aStruct := {}
    Local nI := 0

    For nI := 1 to len( aFields )
        SX3->( DBSetOrder(2) )
        If SX3->( MsSeek( aFields[ nI ] ) )
            aInfo := FWSX3Util():GetFieldStruct( aFields[ nI ] )

            Aadd( aHeader, { TRIM( X3Titulo() ),;   //Título
                aInfo[1],;                          //Nome do campo
                X3Picture( aFields[ nI ] ) ,;       //Picture
                aInfo[3],;                          //Tamanho do campo
                aInfo[4],;                          //Decimais do campo
                "",;                                //Valid
                "",;                                //"Não utilizado"
                aInfo[2]} )                         //Tipo do campo

            aadd( aStruct, { aInfo[1], aInfo[2], aInfo[3], aInfo[4] } )
        EndIf
    Next 

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aInfo )
Return { aClone( aHeader ), aClone( aStruct ) }

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RSKValCan
Função responsável por validar a exclusão de um titulo MN.

@param cAlias - Alias da tabela da exclusão do titulo. ("SF2")
@param cMarca - Caracter para demonstrar quais itens estão marcados na tabela.
@param lInverte - indica se os indicadores estão invertidos ou não.
@param nReg - Número do registro posicionado para a validação.
@return lRet, Indica o resultado da validação.

@author Rodrigo G. Soares
@since 19/03/2021
/*/
//----------------------------------------------------------------------------------
Function RSKValCan( cAlias as Character, cMarca as Character, lInverte as Logical, nReg as Numeric) as Logical
    Local aAlias           as Array
    Local aAliasSF2        as Array
    Local aAliasAR1        as Array
    Local cQuery           as Character
    Local cTempSF2         as Character 
    Local oStatement       as Object
    Local lRet             as Logical
    Local lVerLib		   as Logical

    DEFAULT cMarca      := '' 
    DEFAULT lInverte    := .F.
    DEFAULT nReg        := 0

    aAlias      := GetArea()
    aAliasSF2   := SF2->( GetArea() )
    aAliasAR1   := AR1->( GetArea() )
    lRet        := .T.
    cQuery      := ''
    cTempSF2    := ''
    lVerLib		:= FWLibVersion() >= "20211116"
    oStatement  := NIL

    Pergunte("MT521A",.F.)
    
    IF cAlias == "SF2"
        IF nReg == 0
            cQuery  :=  " SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, F2.R_E_C_N_O_" 
            cQuery  +=  " FROM " + RetSqlName( "SF2" ) + " F2" 
            cQuery  +=  " INNER JOIN " + RetSqlName( "AR1" ) + " AR1 ON AR1.AR1_DOC  = F2.F2_DOC" 
            cQuery  +=  " AND AR1.AR1_SERIE = F2.F2_SERIE AND AR1.AR1_FILNF = F2.F2_FILIAL" 
            cQuery  +=  " AND AR1.AR1_CLIENT = F2.F2_CLIENTE AND AR1.AR1_LOJA = F2.F2_LOJA" 
            cQuery  +=  " AND AR1.AR1_STATUS IN (?,?,?,?,?,?,?,?,?) "
            cQuery  +=  " AND (F2.F2_CHVNFE <> '' OR F2.F2_NFELETR <> '')" 
            cQuery  +=  " AND AR1.D_E_L_E_T_ = ' '"
            cQuery  +=  " WHERE F2.F2_FILIAL= ?  AND" 
            IF ( lInverte )
                cQuery += " F2.F2_OK <> ? "
            ELSE
                cQuery += " F2.F2_OK = ? "
            ENDIF
            cQuery  +=  " AND F2_EMISSAO BETWEEN ? AND ? "
            cQuery  +=  " AND F2_SERIE BETWEEN ? AND ? "
            cQuery  +=  " AND F2_DOC BETWEEN ? AND ? "
            cQuery  +=  " AND F2.D_E_L_E_T_ = ' '" 

            cQuery  := ChangeQuery( cQuery ) 

            oStatement :=  IIf(lVerLib, FwExecStatement():New(cQuery), FWPreparedStatement():New(cQuery))

            oStatement:SetString(1,AR1_STT_AWAIT)
            oStatement:SetString(2,AR1_STT_ANALYSIS)
            oStatement:SetString(3,AR1_STT_APPROVED)
            oStatement:SetString(4,AR1_STT_REJECTED)
            oStatement:SetString(5,AR1_STT_CANCELED)
            oStatement:SetString(6,AR1_STT_FLIMSY)
            oStatement:SetString(7,AR1_STT_CANCELING)
            oStatement:SetString(8,AR1_STT_CANCELINGSEF)
            oStatement:SetString(9,AR1_STT_ERRORCANCERP)
            oStatement:SetString(10,xFilial("SF2"))
            oStatement:SetString(11,cMarca)
            oStatement:SetString(12,DTOS(MV_PAR03))
            oStatement:SetString(13,DTOS(MV_PAR04))
            oStatement:SetString(14,MV_PAR05)
            oStatement:SetString(15,MV_PAR06)
            oStatement:SetString(16,MV_PAR07) 
            oStatement:SetString(17,MV_PAR08)
            
            cQuery := oStatement:GetFixQuery()
                
            cTempSF2 := mpsysopenquery(cQuery)

            WHILE ( cTempSF2 )->( !Eof() )                
                SF2->( DBGoto(( cTempSF2 )->R_E_C_N_O_))
                    lret := .F.
                    RecLock("SF2")
                        SF2->F2_OK := ""
                    MsUnlock()
                ( cTempSF2 )->( DBSkip() )
            ENDDO
                ( cTempSF2 )->( DBCloseArea() )
        ELSE
            SF2->( DBGoto( nReg ) )

            DbSelectArea('AR1')
            DbSetorder(2)
            If( MsSeek(xFilial('AR1') + SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ))                
                //0=Aguardando Envio / 1=Em Análise / 2=Aprovada / 3=Rejeitada / 4=Cancelada / 5=Inconsistente / 7=Em cancelamento Sefaz / 9=Erro no Cancelamento ERP
                If ( !Empty(SF2->F2_CHVNFE) .Or. !Empty(SF2->F2_NFELETR) ) .And. AR1->AR1_STATUS $ '"' + AR1_STT_AWAIT + '|' + AR1_STT_ANALYSIS + '|' + AR1_STT_APPROVED + '|' + AR1_STT_REJECTED + '|' + AR1_STT_CANCELED + '|' + AR1_STT_FLIMSY + '|' + AR1_STT_CANCELING + '|' + AR1_STT_CANCELINGSEF + '|' + AR1_STT_ERRORCANCERP + '"'
                    lRet := .F.
                EndIf
                
            EndIf
         ENDIF
    ENDIF

     Pergunte("MTA521",.F.)

    IF(!lRet)
        Help( "", 1, "RSKVALCAN", , STR0010 , 1, 0,,,,,, { STR0011 } ) //"Não é permitido a exclusão de uma NF Mais Negócio por esta rotina."#"Para cancelar uma NF Mais Negócio, acesse a rotina Documento de Saída Mais Negócio."
    ENDIF

    RestArea( aAlias )
    RestArea( aAliasSF2 )
    RestArea( aAliasAR1 )
    
    FWFreeArray( aAlias )
    FWFreeArray( aAliasSF2 )
    FWFreeArray( aAliasAR1 )

    FreeObj(oStatement)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskInstallments
Funcao que gera as parcelas no formato do Protheus para localizar
no financeiro.

@param nNumber, numerico, Numero de parcelas.

@return aInstallments , array, Array de parcelas no formato do Protheus.

@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Function RskInstallments( nNumber )
    Local cSequence     := SuperGetMv("MV_1DUP",.F.,"1")
    Local aInstallments := {}
    Local nInstallment  := 0
    
    Default nNumber := 1

    aAdd(aInstallments,{"1",cSequence})

    If nNumber > 1
        For nInstallment := 2 To nNumber  
            cSequence := MAParcela( cSequence )
            aAdd(aInstallments,{cValToChar(nInstallment),cSequence}) 
        Next   
    EndIf  
Return aInstallments

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RskGetSupplier
Função que retorna o Fornecedor com base nos dados do Cliente.

@param cCustID, caracter, Código do cliente
@param cCustBranch, caracter, Loja do cliente.

@return aSupplier, Array, Retorna Código/Loja do Fornecedor.
@author Squad NT TechFin
@since 29/01/2021
/*/
//----------------------------------------------------------------------------------
Function RskGetSupplier(cCustID, cCustBranch)
    Local aSvAlias  := GetArea()
    Local cTempSE2  := GetNextAlias() 
    Local aSupplier := {}

    BeginSQL Alias cTempSE2

        SELECT	A2_COD, A2_LOJA
        FROM 	%Table:SA2% SA2
        WHERE	SA2.%NotDel% AND
                SA2.A2_FILIAL  = %Exp:xFilial("SA2")% AND
                SA2.A2_CLIENTE = %Exp:cCustID% AND
                SA2.A2_LOJCLI  = %Exp:cCustBranch%

    EndSQL 

    If (cTempSE2)->(!Eof())
        aSupplier := { (cTempSE2)->A2_COD, (cTempSE2)->A2_LOJA }
    EndIf

    (cTempSE2)->(DBCloseArea())

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )   
Return aSupplier  

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RskInsertLog
Função que grava o log na AR7

@param cJson, caracter, json completo
@param cAcao, caracter, Verbo Get/post, etc
@param cUrl, caracter, endpoint
@param cResult, caracter, retorno da operação
@param lRet, Logical, retorno lógico da operação get/post 
@param cOrigem, caracter, possui a informação da rotina de origem da informação
@param cTabela, caracter, possui a informação da tabela de origem da informação
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@author Jailton Urbano
@since 07/03/2023
/*/
//----------------------------------------------------------------------------------
Static Function RskInsertLog(cJson As Character, cAcao As Character, cUrl As Character, cResult As Character, lRet As Logical, cTabela As Character, cOrigem As Character, aParam As Array)
    Local aLog       As Array
    Local oJItem     As Object
    Local cChave     As Character
    Local cRetorno   As Character
    Local cProduto   As Character
    Local cDecResult As Character

    Default cJson   := ''
    Default cTabela := ''
    Default cOrigem := ''
    Default cResult := ''
    Default aParam  := {}

    aLog       := {}
    oJItem     := JsonObject():New()
    cChave     := ''
    cRetorno   := '2'
    cDecResult := DecodeUtf8(cResult)

    If !Empty(cJson)
        oJItem:FromJson(cJson)
        If len(oJItem) == 1
            cChave := oJItem[1]["erpId"]
        ElseIf oJItem["erpId"] <> NIL
            cChave := oJItem["erpId"]
        EndIf
    else
        cJson := cUrl //caso não haja body, vai gravar o url params
    EndIf

    If cAcao == RSKGET
        cAcao := '1'
    ElseIf cAcao == RSKPOST
        cAcao := '2'
    ElseIf cAcao == RSKPUT
        cAcao := '3'
    ElseIf cAcao == RSKDELETE
        cAcao := '4'
    else
        cAcao := '5' //patch
    EndIf

    If lRet
        cRetorno := '1' //Processamento ok
    EndIf

    If ValType( cDecResult ) == "U"
        cDecResult := cResult
    EndIf
    //Fixado para o produto Mais Negócios
    cProduto := 'Mais Negócios'

    If Empty(__oTechFinlog:cNomeUser) .And. len(aParam) >= 3 //A Posição 3 que possui o codigo do usuário
        __oTechFinlog:cNomeUser := UsrRetName( aParam[3] )
    EndIf

    /*
    [1] Id do Log
    [2] Produto Origem
    [3] Origem do Log
    [4] Acao
    [5] Endpoint
    [6] JSON
    [7] Observação
    [8] Resultado
    [9] Tabela Origem
    [10] Chave do Registro (X2_UNICO)
    */
    aAdd(aLog,{'',;
        cProduto,;
        cOrigem,;
        cAcao,;
        cUrl,;
        DecodeUtf8(cJson),;
        cDecResult,;
        cRetorno,;
        cTabela,;
        cChave})
        
    __oTechFinlog:InsertLog(aLog)

    FreeObj(oJItem)
    FwFreeArray( aLog )
Return 

/*/
    {Protheus.doc} TFRegistry
    Verifica se existe a classe para poder instanciar
    @author Daniel Moda
    @since 10/03/2023
    @version 1.0
    @return oObjRet, Object, objeto com as URLs Mais Negócios
/*/
Static Function TFRegistry() As Object

Local oObjRet As Object

oObjRet := Nil

If __lRegistry
    oObjRet := FINA138BTFRegistry():New()
EndIf

Return oObjRet
