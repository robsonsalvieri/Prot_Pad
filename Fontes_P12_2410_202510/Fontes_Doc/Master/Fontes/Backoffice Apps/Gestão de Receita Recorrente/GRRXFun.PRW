#include "protheus.ch"
#include "GRRXDefs.ch"
#INCLUDE "FwSchedule.ch"
#include "GRRXFun.ch"

//-------------------------- GRRXFun ------------------------------
// Biblioteca de funções utilizadas pelo produto GRR
//-------------------------------------------------------------------

// posições do array de serviço
#DEFINE ENDPOINT        1   
#DEFINE PATH            2

Static __aCurrencyByCompany := {}
Static __aGRROrganizations := {}        // Identifica as filiais ativas na integração com o GRR
Static __lGRRSndbox := NIL              // Identifica se a integração com o GRR usa o modo Sandbox.
Static __lAutomato := GRRADVPRExec()    // Indica que a função foi chamada por um script ADVPR
Static _oGRRHshQry := HMNew()           // Objeto que armazena as queries base do GRR
Static __oConfig := NIL                 // Objeto da FWTFConfig()
Static _oExVldHri := Nil                // Armazena a Query da função GRRVldHri

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRSM0byCarol
Avalia se os registros devem ser selecionados, por já haver amarração
de uso delas pela Carol

@param @aArray, array, lista de empresas para validar o uso.

@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------
/*Function GRRSM0byCarol( aArray ) 
    Local oParam
    Local cContent := ''
    Local nI := 0

    oParam := FwAppParam():New()
    For nI := 1 to len( aArray )
        cContent := oParam:Get( "FWCarolCompany" + aArray[ nI ][2] )

        If cContent == 'true'
            aArray[ nI ][1] := .T.
        EndIf
    Next

    FreeObj( oParam )
RETURN
*/
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRWVlPlatform
Função que valida os dados de conexão com o RAC ( plataforma )

@param @aPlatInfo, array, vetor com as informações da conexão com a plataforma RISK
@param @aRetValues, array, vetor com as informações que serão gravadas pelo Wizard.

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRWVlPlatform( aPlatInfo, aRetValues )
    Local lValid := .T.
    Local cMsg  := ''
    Local nI := 0

    If Empty( aPlatInfo[ CLIENT_ID ] )
        lValid := .F.
        cMsg := STR0052     //"Informe o ID do cliente de conexão."
    ElseIf Empty( aPlatInfo[ CLIENT_SECRET ] ) 
        lValid := .F.
        cMsg := STR0053     //"Informe a senha do cliente para conexão."
    Endif
    
    If !lValid
        ApMsgAlert( cMsg )
    Else 
        For nI := 1 to len( aPlatInfo )
            aPlatInfo[ nI ] := Alltrim( aPlatInfo[ nI ] )
        Next

        lValid := GRRChkPlatform( aPlatInfo ) 
   
        If lValid 
            Aadd( aRetValues, { 'Auth', { aPlatInfo[ CLIENT_ID ], aPlatInfo[ CLIENT_SECRET ] } } )
        EndIf 
    EndIf
Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSaveAppParam
Função que grava as configurações do GRR na SYS_APP_PARAM

@param aData, array, vetor com as informações da conexão 

@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRSaveAppParam( aData )
    Local oParam := JsonObject():New()
    Local nI := 0

    For nI := 1 to len( aData )
        oParam[ aData[ nI ][1] ] := aData[ nI ][2]
    Next

    FwTFSetConfig( oParam )

    FreeObj( oParam )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSaveParam
Função que grava os parâmetros na SX6

@param aParam, array, lista com os parâmetros a serem gravados, onde
    [1] - nome do parâmetro
    [2] - conteúdo que deve ser atribuído
@param lSX6, boolean, indica onde os parâmetros devem ser salvos. Quando for .T. salva 
        no SX6 e se for .F. salva na SYS_APP_PARAM

@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRSaveParam( aParam, lSX6 )
    Local aSvAlias := GetArea()
    Local nI := 0

    Default lSX6 := .T.

    IF lSX6    
        //-----------------------------------------------------------------------
        // Grava as informações na SX6.
        //-----------------------------------------------------------------------
        For nI := 1 to len( aParam )
            PutMV( aParam[ nI ][ 1 ], aParam[ nI ][ 2 ])
        Next
    else
        //-----------------------------------------------------------------------
        // Manda as informações para a SYS_APP_PARAM
        //-----------------------------------------------------------------------
        GRRSaveAppParam( aParam )    
    EndIf
    
    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRROpenEnv
Função de abertura do ambiente.

@param cUser, caracter, nome do usuário
@param cPsw, caracter, senha
@param cCompany, caracter, empresa onde o ambiente será aberto

@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRROpenEnv( cUser, cPsw, cCompany )
    OpenSM0( cCompany )            

    GRRConnCompany( cCompany, SM0->M0_CODFIL, cUser, cPsw )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AdjCarolComp
Função que atribui se a empresa deve ser sincronizada na Carol, dependendo se ela está
ou não selecionada no Wizard. 
Somente empresas selecionadas devem ser sincronizadas.

@param cCompany, caracter, nome do usuário
@param lSelected, boolean, indica se o registro está selecionado ou não.

@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
/*Static Function AdjCarolComp( cCompany, lSelected )
    Local oParam
    Local cSelected := ''

    Default lSelected := .T.
    
    If lSelected
        cSelected := "true"
    else
        cSelected := "false"
    EndIf

    oParam := FwAppParam():New()
    oParam:Put( "FWCarolCompany" + cCompany, cSelected )  

    FreeObj( oParam )
Return
*/
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRConnCompany
Função auxliar para abertura do ambiente.

@param cCompany, caracter, empresa onde o ambiente será aberto
@param cBranch, caracter, filial onde o ambiente será aberto
@param cUser, caracter, nome do usuário
@param cPsw, caracter, senha

@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRConnCompany( cCompany, cBranch, cUser, cPsw )
    Local lRet      := .T.  

    Default cUser   := ''
    Default cPsw    := ''

    RPCSetType( 3 )
    IF !Empty( cUser )
        lRet := RpcSetEnv( cCompany, cBranch, cUser, cPsw )
    else
        lRet := RpcSetEnv( cCompany, cBranch )
    EndIf
    oApp:cInternet := Nil
    __cInternet := NIL
    lMsHelpAuto := .F.
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRRestExec
Função que executa o verbo GET dos endpoints da plataforma com autenticação 

@param cAction, caracter, Identifica qual a ação do Rest será chamada (GET, POST ou PUT)
@param cEndPoint, caracter, URL do serviço
@param cPath, caracter, Endpoint a executar
@param @oRest, object, Objeto Rest de retorno para a função chamadora
@param xValues, any, Conteúdo a ser trasmitido pelo serviço nas chamadas de POST e PUT
@param nTypeAuth, number, identifica qual a URL do RAC utiliza
    1 - admin ( autenticação de serviços )
    2 - autenticação
@param lCompanyID, boolean, indica se adiciona a propriedade companyId no aHeader da requisição

@return caracter, Result da requisição.
@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRRestExec( cAction, cEndpoint, cPath, oRest, xValues, nTypeAuth, lCompanyID )
    Local aToken    := {}
    Local aHeader   := {}
    Local aInfo     := {}
    Local cResult   := ''
    Local cHeader   := ''
    Local cBody     := ''
    Local cDesc     := ''
    Local cMsg      := ''
    Local lRet      := .F.
    Local jValues
    Local oResult 
    
    Default cAction       := 'GET'       
    Default oRest         := NIL
    Default xValues       := ''
    Default nTypeAuth     := SERVICE      // 1=URL de autenticação de serviços
    Default lCompanyID    := .T.
 
    IF ( cAction == 'GET' .Or. cAction == 'DELETE' ) .Or. ( ( cAction == 'POST' .Or. cAction == 'PUT' .Or. cAction == 'PATCH' ) .And. ;
        ( ( Valtype( xValues ) == "J" .And. len( xValues:Getnames() ) > 0 ) .Or. ( Valtype( xValues ) == "A" .And. !Empty( xValues ) ) ;
        .Or. ( cAction == 'PATCH' .And.  Valtype( xValues ) == "J" .And. len( xValues:toJson() ) > 0 ) ) )
        
        aHeader := GRRRestHeader( cEndpoint, nTypeAuth, lCompanyID )

        If !Empty( aHeader )
            oRest := FWRest():New( cEndpoint ) 
            oRest:SetPath( cPath )

            If GRRInDebug( )
                aAdd( aInfo, { 'Action', cAction } )
                aAdd( aInfo, { 'Endpoint', cEndpoint } )
                aAdd( aInfo, { 'Path', cPath } )
                aAdd( aInfo, { 'Sandbox', iif( GRRIsSndbox( ), "ON", "OFF" ) } ) 
                // aAdd( aInfo, {'JSON', FwJsonSerialize( xValues ) } ) 
                aAdd( aInfo, { 'xValues', IIF( ValType( xValues ) == 'J', xValues:toJson(), FwJsonSerialize( xValues ) ) } ) 

                GRRDebugInfo( aInfo )
            EndIf

            // TODO - Precisa trocar a função FwJsonSerialize pela classe JSONObject
            Do Case 
                Case cAction == 'GET'      
                    lRet := oRest:Get( aHeader )
                Case cAction == 'POST'     
                    cJSON := EncodeUTF8( FwJsonSerialize( xValues ) )
                    oRest:SetPostParams( cJSON )
                    lRet := oRest:Post( aHeader )
                Case cAction == 'PUT'      
                    lRet := oRest:Put( aHeader, FwJsonSerialize( xValues ) )
//                Case cAction == 'DELETE'      
//                    lRet := oRest:Delete( aHeader, FwJsonSerialize( xValues ) )
                Case cAction == 'PATCH'      
                    // If Valtype( xValues ) == "A"
                    //     jValues := GRRArrtoJson( xValues )
                    //     cBody   := EncodeUTF8( jValues:ToJson() )
                    // Else
                        cBody   := EncodeUTF8( xValues:ToJson() )
                    // EndIf

                    cResult := HTTPQuote( cEndpoint + cPath , "PATCH",, cBody, 120, aclone( aHeader ), @cHeader )
                    If HTTPGetStatus( @cDesc ) <> 200
                        cMsg := I18N( "GRRRestExec -> " + STR0003 + " : ", { cEndpoint + cPath } )   // ERRO - Ocorreram erros durante a atualização do registro pelo serviço #1"
                        If FwJsonDeserialize( cResult, @oResult )
                            cResult := ''
                            cMsg += DecodeUTF8( oResult[1][ 'message' ] )
                        Else
                            cMsg += cBIStr( HTTPGetStatus( @cDesc ) ) + ' - ' + cDesc
                        EndIf   
                        LogMsg( "GRRRestExec - PATCH", 23, 3, 1, "", "", cMsg ) 
                    EndIf
            EndCase

            If lRet
                cResult := oRest:GetResult()
            EndIf

            If !Empty( cResult )
                GRRDebugInfo( { { 'cResult', cResult } } )
            EndIf
        EndIf
    EndIf

    FWFreeArray( aToken )
    FWFreeArray( aHeader )
    FWFreeArray( aInfo )
    FreeObj( jValues )
    FreeObj( oResult )
Return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSaveSchedule
Função que grava os JOBs no Schedule

@param aSelCompany, array, vetor com a lista de filiais por empresas selecionadas, onde: 
    [1] - grupo de empresas selecionada
    [2] - vetor com as filiais selecionadas dentro do grupo de empresas 
@param aJobs, array, vetor com a lista de jobs para cadastrar, onde
    [1] - nome do job
    [2] - expressão de recorrência
    [3] - hora de execução
@param lOnlyFirst, boolean, Indica que o schedule deve ser configurado apenas para a 
    primeira filial. Este comportamento é útil quando as funções que serão executadas 
    estão preparadas para execução por empresa ( quando podem ser executadas apenas uma vez).

@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRSaveSchedule( aSelCompany, aJobs, lOnlyFirst )
    Local aSvAlias := GetArea()
    Local aSchdComp := {}
    Local nItem := 1
    Local cRecurrence := ''
    Local cTime := ''
    Local cExecComp := ''
    Local cTaskID := ''

    Default lOnlyFirst := .T.

    //-----------------------------------------------------------------------
    // Monta lista de empresas\filiais para execução do agendamento.
    //-----------------------------------------------------------------------
    For nItem := 1 to len( aSelCompany )
        If lOnlyFirst 
            cExecComp += aSelCompany[ nItem ][1] + "/" + aSelCompany[ nItem ][2][1] + ";"
        
        // Bloco comentado, pois por enquanto o agendamento é único.
        // Else
        //     For nAux := 1 to len( aSelCompany[ nItem ][2] )
        //         cExecComp += aSelCompany[ nItem ][1] + "/" + aSelCompany[ nItem ][2][ nAux ] + ";"
        //     Next
        EndIf
    Next

    For nItem := 1 to len( aJobs )
        cRecurrence := 'A'
        cTime := '00:00'

        // Bloco comentado, pois os agendamentos são sempre ativos
        // If Valtype( aJobs[ nItem ] ) == "A"
        //     If len( aJobs[ nItem ] ) >= 2 .And. !Empty( aJobs[ nItem ][ 2 ] )
        //         cRecurrence := aJobs[ nItem ][ 2 ]
        //     EndIf

        //     If len( aJobs[ nItem ] ) >= 3 .And. !Empty( aJobs[ nItem ][ 3 ] )
        //         cTime := aJobs[ nItem ][ 3 ]
        //     EndIf
        // ENDIF

        //-----------------------------------------------------------------------
        // Procura no Schedule se o Job já está cadastrado
        //-----------------------------------------------------------------------
        cTaskID := FwSchdByFunction( aJobs[ nItem ] )
        If Empty( cTaskID )
            //-----------------------------------------------------------------------
            // Inclui o job no Schedule
            //-----------------------------------------------------------------------
            FwInsSchedule( aJobs[ nItem ], __cUserID, , cRecurrence, cTime, Upper( GetEnvServer() ), cExecComp , SCHD_ACTIVE, Date(), 5, NIL )
        // Bloco comentado pois o agendamento é único.
        // Else
        //     If !( ExistFunc( "FwOpenXX2" ) )
        //         DbSelectArea( "XX2" )
        //     Else
        //         FwOpenXX2()
        //     EndIf

        //     //-----------------------------------------------------------------------
        //     // Exclui as empresas\filiais de cada agendamento
        //     //-----------------------------------------------------------------------
        //     cQuery := "SELECT R_E_C_N_O_ ID FROM XX2 WHERE XX2_AGEND = '" + cTaskID + "' "
        //     cTmpAlias := MPSysOpenQuery( cQuery )

        //     While ( cTmpAlias )->( !Eof() )
        //         XX2->( DBGoto( ( cTmpAlias )->ID ) )    
        //         RecLock( "XX2", .F. )
        //             XX2->( DBDelete() )
        //         XX2->( MsUnlock() )

        //         ( cTmpAlias )->( DBSkip() )
        //     End
        //     ( cTmpAlias )->( DbCloseArea() )

        //     //-----------------------------------------------------------------------
        //     // Recria a ligação entre o agendamento e filiais
        //     //-----------------------------------------------------------------------
        //     aSchdComp := StrtokArr( cExecComp, ";" )
        //     For nAux := 1 to len( aSchdComp )
        //         RecLock( 'XX2', .T. )
        //             XX2->XX2_AGEND := cTaskID
        //             XX2->XX2_EMPFIL := aSchdComp[ nAux ]
        //         MsUnLock()        
        //     Next
        EndIf
    Next

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aJobs )
    FWFreeArray( aSchdComp )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRCarolHeader
Função que cria um modelo de aHeader para a sincronização de dados com a Carol.

@param aKeys, array, Vetor com informações para conexão com a Carol.
    [1] - Carol API Token
    [2] - Connector ID

OBS: A Carol não é usada pelo GRR.

@return array, cabeçalho para autenticação de serviços com a Carol.
@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
/*Function GRRCarolHeader( aKeys )
    Local aHeader := {}
    Local cCarolConnID := ''
    Local cCarolAPIToken := ''

    cCarolAPIToken := aKeys[ 1 ]
    cCarolConnID := aKeys[ 2 ]

    // TODO - rever este bloco
    AAdd( aHeader, "Content-Type: application/json" )
    AAdd( aHeader, "Accept: application/json" )
    AAdd( aHeader, "X-Auth-Key: "          + cCarolAPIToken )  
    AAdd( aHeader, "X-Auth-ConnectorId: "  + cCarolConnID )    
    AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )    
Return aHeader
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSyncSX6
Esta função é responsável por sincronizar alguns parâmetros do Protheus com a Carol.

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.
@param aParameters, array, lista com os parâmetros a sincronizar.
@param cEndPoint, caracter, URL do serviço
@param cPath, caracter, Path da plataforma para validar os dados de conexão.
@param aHeader, array, vetor com as informações do aHeader para execução do REST

OBS: A Carol não é usada pelo GRR.

@author  Marcia Junko
@since   30/02/2022
/*/
//-------------------------------------------------------------------------------------
/*Function GRRSyncSX6( oStatus, aParameters, cEndPoint, cPath, aHeader )
    Local aSvAlias      := GetArea()
    Local aJsonItem     := {}
    Local aSM0Data      := {}
    Local oRestClient   := Nil
    Local oJSon         := Nil
    Local nSM0          := 0
    Local nParam        := 0
    Local nLenItem      := 0
    Local cParameters   := ''
    Local cBranch       := ''
    Local cContent      := ''

    Default oStatus := NIL

    IF !Empty( aParameters ) .And. ( !Empty( cEndpoint ) .And. !Empty( cPath ) )
        aSM0Data    := FWLoadSM0()      
        oJson       := JsonObject():New()

        DBSelectArea( "SX6" )
        DBSetOrder(1)
        For nSM0 := 1 To Len( aSM0Data )  
            If aSM0Data[ nSM0 ][1] == cEmpAnt
                For nParam := 1 To Len( aParameters )
                    cParameters := aParameters[ nParam ]

                    AAdd( aJsonItem, JsonObject():New())
                    nLenItem := Len( aJsonItem )
                
                    If DBSeek( aSM0Data[ nSM0 ][2] + cParameters )  
                        cBranch := aSM0Data[ nSM0 ][2]
                        cContent := SuperGetMv( cParameters, .F., , cBranch )
                    Else
                        cBranch := Space( FWSizeFilial() )
                        cContent := SuperGetMv( cParameters , .F. )
                    EndIf

                    aJsonItem[ nLenItem ][ "protheus_pk" ] := cEmpAnt + "|" + cParameters
                    aJsonItem[ nLenItem ][ "branch" ]      := cBranch      
                    aJsonItem[ nLenItem ][ "content" ]     := cContent
                    aJsonItem[ nLenItem ][ "parameter" ]   := cParameters
                Next
            EndIf
        Next 

        oJson:Set( aJsonItem ) 
        cJson := EncodeUTF8( oJson:ToJson() ) 
            
        oRestClient := FWRest():New( cEndPoint )
        oRestClient:SetPath( cPath )
        oRestClient:SetPostParams( cJson )  

        If oRestClient:Post( aHeader )
            GRRWizStatus( @oStatus, STR0004 )  // "Parâmetros enviados com sucesso para a plataforma." 
        Else
            GRRWizStatus( @oStatus, STR0005 )    //'A T E N Ç Ã O - Ocorreu erro no envio dos parâmetros para a plataforma.'
        EndIf
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aJsonItem )
    FWFreeArray( aSM0Data )
    FreeObj( oRestClient )
    FreeObj( oJson )
Return Nil
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSyncData
Esta função é responsável por sincronizar os dados do Protheus com a plataforma.

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.
@param xItems, array ou JSON, dado a ser enviado
@param cEndPoint, caracter, URL do serviço
@param cPath, caracter, Path da plataforma para validar os dados de conexão.
@param nType, number, Tipo de operação a ser realizada, sendo:
    1 = POST    ( Inclusão )
    2 = PUT     ( Alteração )
    3 = DELETE  ( Exclusão )
@param lShowMsg, boolean, Indica se a mensagem deve ser apresentada no objeto oStatus.
@param cMsg, caracter, Mensagem que deve ser apresentada

@return, caracter, informações de resposta da requisição.
@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRSyncData( oStatus, xItems, cEndPoint, cPath, nType, lShowMsg, cMsg )
    Local aSvAlias      := GetArea()
    Local oRest         := Nil
    Local oProtRest     := Nil
    Local oResult       := Nil
    Local cResult       := ''
    Local cProtocol     := ''
    Local cProtResult   := ''
    Local cReference    := ''
    Local cError        := ''
    Local cAction       := 'POST'
    Local lRunning      := .T.
    Local nCount        := 0 

    Default oStatus := NIL
    Default nType := 1
    Default lShowMsg := .T.
    Default cMsg := STR0001     //"Dados enviados com sucesso para a plataforma."

    IF ( !Empty( cEndpoint ) .And. !Empty( cPath ) ) .And. ;
        ( ( Valtype( xItems ) == "J" .And. ( len( xItems:Getnames() ) > 0 .Or. !Empty(xItems:toJson()) ) ) .Or. ;
          ( Valtype( xItems ) == "A" .And. !Empty( xItems ) ) )

            Iif( nType == 2, cAction := 'PUT', Iif( nType == 3, cAction := 'DELETE', Iif( nType == 4, cAction := 'PATCH', NIL  ) ) )

            cResult := GRRRestExec( cAction, cEndpoint, cPath, @oRest, xItems )

            If !Empty( cResult )
                //-----------------------------------------------------------------------
                // Indica que fez uma ação de sincronismo em lote
                //-----------------------------------------------------------------------
                If Valtype( xItems ) == "A"
                    oResult := JSONObject():New() 
                    oResult:FromJSON( cResult )

                    cProtocol  := oResult[ 'url' ]
                    cProtocol := Strtran( cProtocol, '/api/v1/rac', '' )

                    While lRunning
                        cProtResult := GRRRestExec( 'GET', cEndpoint, cProtocol, @oProtRest )

                        If !Empty( cProtResult )
                            oResult:FromJson( cProtResult )

                            If oResult[ 'status' ][ 'running' ] <> 0
                                Sleep( 3000 )
                                nCount++
                            else
                                If oResult[ 'status' ][ 'total' ] > 1
                                    cMsg := I18N( "GRRSyncData -> INFO - " + STR0006, { oResult[ 'status' ][ 'total' ], oResult[ 'status' ][ 'completed' ] + oResult[ 'status' ][ 'errors' ] } )    //"Foram enviados #1 registros para sincronismo e #2 foram processados."
                                Else
                                    cMsg := I18N( "GRRSyncData -> INFO - " + STR0007, { oResult[ 'status' ][ 'total' ], oResult[ 'status' ][ 'completed' ] + oResult[ 'status' ][ 'errors' ] } )    //"Foi enviado #1 registro para sincronismo e #2 foi processado."
                                EndIf
                                lRunning := .F.
                            EndIf
                        else
                            Sleep( 1000 )
                            nCount++
                        endif

                        If nCount >= 5
                            cMsg := STR0008 //"A T E N Ç Ã O - Número máximo de tentativas de sincronismo foi excedido."

                            lRunning := .F.
                        EndIf
                    End                
                    LogMsg( "GRRSyncData", 23, 6, 1, "", "", cMsg ) 
                EndIf

                If lShowMsg
                    GRRWizStatus( @oStatus, cMsg  ) 
                EndIf
            Else
                GRRWizStatus( @oStatus, STR0009 )    //'A T E N Ç Ã O - Ocorreu erro no envio dos parâmetros para a plataforma.'
                
                IF oRest <> NIL .And. ( oRest:GetHTTPCode() == '400' .Or. oRest:GetHTTPCode() == '500' )
                    If xItems:HasProperty( "reference" )
                        cReference := xItems[ 'reference' ]
                    EndIf

                    cError := IIF( oRest:GetResult() != Nil, DecodeUTF8( oRest:GetResult() ), "" )
                    cMsg := I18N( "GRRSyncData -> " + STR0010, { cReference, EncodeUTF8( oRest:GetLastError() ) + " " + cError } )   // "ERRO - Ocorreram erros durante a sincronização do registro #1: #2" 
            
                    LogMsg( "GRRSyncData", 23, 3, 1, "", "", cMsg ) 
                    GRRWizStatus( @oStatus, cMsg )    
                EndIf
            EndIf
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FreeObj( oRest )
Return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRRacAccess
Autentica e recupera o Token para comunicação com a plataforma 

@param cPlatform, URL da plataforma para definição do RAC
@param nType, number, identifica qual a URL do RAC retornar
    1 - autenticação
    2 - admin ( autenticação de serviços )
@param cClientId, caracter, força um clientId específico para geração do token
@param cSecret, caracter, força um Secret específico para geração do token
@param lAutomato, boolean, Indica que vai tratar pelo ADVPR.

@return array, dados de comunicação com a plataforma
    [1] - Código de resposta da requisição
    [2] - Código de autenticação
    [3] - Tempo para expirar
    [4] - data da solicitação
    [5] - segundo da solicitação

@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRRacAccess( cPlatform, nType, cClientId, cSecret, lAutomato )
    Local aToken := {}
    Local aHeader := {}
    Local oConfig
    Local oRest
    Local oJson
    Local cFormParam := ''
    Local cEndPoint := ''
    Local cBody := ''

    Default cPlatform := '' 
    Default nType := SERVICE
    Default cClientID := '' 
    Default cSecret := ''
    Default lAutomato := .F.

    oConfig := FWTFConfig()
    
    cEndPoint := GRRSetRacURL( oConfig, cPlatform, nType, lAutomato ) 
    If Empty( cClientId )
        cClientID := oConfig[ "platform-clientId" ] 
    EndIf

    If Empty( cSecret )
        cSecret := oConfig[ "platform-secret" ] 
    EndIf

    AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded")
    AAdd( aHeader, "charset: UTF-8")

    cFormParam := "client_id=" + cClientID + "&"   
    cFormParam += "client_secret=" + cSecret + "&"  
    cFormParam += "grant_type=client_credentials&"
    cFormParam += "scope=authorization_api"

    oRest := FwRest():New( cEndPoint )
    oRest:setPath( "/totvs.rac/connect/token" ) 
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
        LogMsg( "GRRRacAccess", 23, 6, 1, "", "", "GRRRacAccess -> " + STR0002 )    //"Não foi possível autenticar no RAC."
    EndIf

    FWFreeArray( aHeader )
    FreeObj( oRest )
    FreeObj( oConfig )
    FreeObj( oJSON )
Return aToken


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSetRacURL
Identifica qual o endereço do RAC para utilizar durante as autenticações

@param oConfig, objeto, dados de conexão com a plataforma
@param cURL, caracter, URL da plataforma
@param nType, number, identifica qual a URL do RAC retornar
    1 - admin ( autenticação de serviços )
    2 - autenticação
@param lAutomato, boolean, Indica que vai tratar pelo ADVPR.

@return caracter, URL do RAC para autenticação
@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------
Function GRRSetRacURL( oConfig, cPlatform, nType, lAutomato )
    Local aSVAlias := GetArea()
    Local cRacURL := ''
    Local cURL := ''
    Local cRACinIni := ''
    
    Default oConfig := GRRTFCfg()
    Default nType   := SERVICE
    Default lAutomato := .F.

    cRacURL   := oConfig[ "rac-endpoint" ]

    If nType == SERVICE
        If !lAutomato
            cRACinIni := GetSrvProfString( "fw-tf-rac-endpoint", "" )
        EndIf

        If '.dev.' $ lower( cPlatform )
            cURL :=  "https://admin.rac.dev.totvs.app" 
        ElseIf 'staging' $ lower( cPlatform )
            cURL := 'https://admin.rac.staging.totvs.app'
        Else
            cURL := "https://admin.rac.totvs.app"
        EndIf

         cRacURL := Iif( !Empty( cRACinIni ), cRACinIni, cURL )
    // Else
    //     If Empty( cRacURL ) 
    //         If '.dev.' $ lower( cPlatform )
    //             cRacURL := "https://totvs.rac.dev.totvs.app"
    //         ElseIf 'staging' $ lower( cPlatform )
    //             cRacURL := 'https://totvs.rac.staging.totvs.app'
    //         Else
    //             cRacURL := "https://totvs.rac.totvs.app"
    //         EndIf
    //     EndIf
    EndIF

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
Return cRacURL


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRChkPlatform
Função de validação das informações de conexão com o GRR

@param aInfo, array, vetor com as informarções de conexão da plataforma, onde:
    [1] - Client ID
    [2] - Client Secret
    [3] - Identificador do serviço
    [4] - Path da plataforma para validar os dados de conexão.

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   30/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRChkPlatform( aInfo )
    Local aHeader      := {}
    Local aToken       := {}
    Local oRest 
    Local cClientID    := ''
    Local cSecret      := ''
    Local cPlatform   := ''
    Local cMessage     := ''
    Local cPath        := ''
    Local lValid       := .F.

    cClientID := aInfo[ CLIENT_ID ] 
    cSecret := aInfo[ CLIENT_SECRET ]
    cPlatform := aInfo[ PLATFORM_URL ] 
    cPath := aInfo[ PLATFORM_PATH ] 

    aToken := GRRRacAccess( cPlatform, NIL, cClientId, cSecret )
    
    If !Empty( aToken )
        AAdd( aHeader, "Content-Type: application/json" )
        AAdd( aHeader, "Authorization: Bearer " + aToken[ 2 ] )
        AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

        oRest := FWRest():New( cPlatform ) 
        oRest:setPath( cPath )
        
        If oRest:Get( aHeader )  
            lValid := .T.
        EndIf 
    EndIf

    If !lValid
        If oRest != NIL
            // IF !Empty( oRest:GetHTTPCode() ) .And. oRest:GetHTTPCode() != "200"
            //     cMessage := CRLF + CRLF + I18N( STR0011, { oRest:GetLastError() + ' - ' + oRest:GetResult() } )  //'Status da requisição: #1'
            // EndIf
        EndIf
        MsgStop( I18N( STR0012, { cMessage } ) )      //"Informações de conexão inválidas na plataforma. #1"
    EndIf

    FwFreeArray( aHeader )
    FwFreeArray( aToken )
    FreeObj( oRest )
Return lValid


//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRRPgControl
Função responsável por atribuir o tratamento de paginação, caso a tag PAGE_CONTROL
seja utilizada ma query.

@param cQuery, caracter, Query original para tratamento
@param cOrderBy, caracter, Instrução de ordenação por operação

@return caracter, Query com o tratamento para paginação
@author Marcia Junko
@since 24/03/2022
/*/
//----------------------------------------------------------------------------------
Function GRRPgControl( cQuery, cOrderBy )
    Local nPosStart   := 0
    Local nPosEnd     := 0
    Local nPosFrom    := 0
    Local cAuxQuery    := ""
    Local cFields      := ""
    Local cPageControl := ""
    Local cTag         := "<<PAGE_CONTROL>>"

    Default cQuery   := ""
    Default cOrderBy := ""
	
    IF At( cTag, cQuery ) > 0 
        nPosStart  := At( cTag, cQuery )
        cAuxQuery  := SubStr( cQuery, nPosStart )
	
        nPosEnd := Len( cTag )
        nPosFrom := At( " FROM ", cAuxQuery )
        cFields := Alltrim( Subs( cAuxQuery, nPosEnd + 2, nPosFrom - nPosEnd - 2 ) )
        cFields := AdjustFields( cFields )

        If Empty( cOrderBy )
            cOrderBy := GRRQryOrder( cQuery )
        EndIf

        cPageControl := cFields + ' FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ' + cOrderBy + ' ) AS LINE '
    
        cQuery := StrTran( cQuery, cTag, cPageControl )
        cQuery += ' ) TABLE_AUX WHERE LINE BETWEEN ? AND ? '
    EndIf
Return cQuery

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRRQryOrder
Função responsável por identificar a ordenação da query

@param cQuery, caracter, Query original para tratamento

@return caracter, Instrução de order by da query
@author Marcia Junko
@since 24/03/2022
/*/
//----------------------------------------------------------------------------------
Function GRRQryOrder( cQuery )
    Local cTag         := "ORDER BY"
    Local cOrderBy     := ""
    Local cTable       := ""

    Default cQuery   := ""
    Default cOrderBy := ""

    IF At( cTag, cQuery ) > 0 
        cOrderBy  := GRRTags( cQuery, cTag ) 
    else
        cTable := GRRQryFrom( cQuery )
        cOrderBy := SqlOrder( ( cTable )->( IndexKey(1) ) )
    EndIf
Return cOrderBy


//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRRQryFrom
Função responsável por identificar a cláusula FROM da query

@param cQuery, caracter, Query original para tratamento

@return caracter, Chave da tabela atribuída no FROM.
@author Marcia Junko
@since 24/03/2022
/*/
//----------------------------------------------------------------------------------
Function GRRQryFrom( cQuery )
    Local nPosEnd    := 0
    Local cTag       := 'FROM'
    Local cAuxQuery  := ''
    Local cRemainder := ''
    Local cFrom      := ''

    cAuxQuery  := GRRTags( cQuery, cTag ) 

    nPosEnd := At( " ", cAuxQuery )
    If nPosEnd > 0
        cRemainder := SubStr( cAuxQuery, 1, nPosEnd )
        If FwSX2Util():SeekX2File( cRemainder )
            cFrom := FWX2Chave()
        Else
            cFrom := cRemainder
        EndIf
    endif
Return cFrom


//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRRTags
Função responsável por retornar o restante de um texto, desconsiderando o conteúdo 
da tag informada.

@param cText, caracter, Texto original para pesquisa da tag
@param cTag, caracter, Tag a ser pesquisada

@return caracter, Conteúdo restante do texto
@author Marcia Junko
@since 24/03/2022
/*/
//----------------------------------------------------------------------------------
Function GRRTags( cText, cTag )
    Local nPosStart  := 0
    Local cAttribute := ''
    Local cRemainder := ''

    cAttribute := ' ' + cTag + ' '
    nPosStart  := At( cAttribute, cText ) 

    If nPosStart > 0
        cRemainder  := SubStr( cText, nPosStart + Len( cAttribute ) )
    EndIf
Return cRemainder


//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRRQryTRecords
Função responsável por retornar a quantidade total de registros ( COUNT ) que satisfazem
a consulta.

@param cQuery, caracter, Consulta a ser executada

@return number, quantidade de registros da query
@author Marcia Junko
@since 24/03/2022
/*/
//----------------------------------------------------------------------------------
Function GRRQryTRecords( cQuery )
    Local aSvAlias := GetArea()
    Local nTotal  := 0
    Local cTmpAlias := GetNextAlias()
    Local cQryCount  := ''

    cQryCount  := DealQryCount( cQuery )
    cQryCount := ChangeQuery( cQryCount )
    MPSysOpenQuery( cQryCount, cTmpAlias )

    If ( cTmpAlias)->( !EOF() )
        nTotal := ( cTmpAlias )->TOTAL
    EndIf
    ( cTmpAlias )->( DBCloseArea() )

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
Return nTotal


//----------------------------------------------------------------------------------
/*/{Protheus.doc} DealQryCount
Transforma a query passada para que seja executada o COUNT com as condições apresentadas.
Esta função deve ser utilizada apenas para consultas simples, sem agrupamento.

@param cQuery, caracter, Consulta a ser executada

@return caracter, query modificada para obtenção do COUNT
@author Marcia Junko
@since 24/03/2022
/*/
//----------------------------------------------------------------------------------
Static Function DealQryCount( cQuery )
    Local nPosFrom := 0
    Local cTag := 'SELECT '
    Local cAuxQuery := ''
    Local cQryCount  := ''
    Local cFields    := ''

    //-----------------------------------------------------------------------
    // Identifica os campos da query
    //-----------------------------------------------------------------------
    cAuxQuery  := SubStr( cQuery, Len( cTag ) )
    nPosFrom := At( " FROM ", cAuxQuery )
    cFields := Alltrim( Subs( cAuxQuery, 1, nPosFrom ) )

    //-----------------------------------------------------------------------
    // Substitui os campos pela instrução de COUNT
    //-----------------------------------------------------------------------
    cQryCount := StrTran( cQuery, cFields, 'COUNT(*) AS TOTAL' )
Return cQryCount


//----------------------------------------------------------------------------------
/*{Protheus.doc} AdjustFields
Função responsável por ajustar os campos na query de paginação quando utilizado 
alguma função de agregação ou renomear o nome do campo.
Esta função só é acionada quando o controle de paginação está sendo usado.

@param cFields, caracter, Campos da query

@return caracter, Campos tratados da query
@author Marcia Junko
@since 11/02/2022
*/
//----------------------------------------------------------------------------------
Static Function AdjustFields( cFields )
    Local aFields := {}
    Local nItem := 0
    Local nPosAs := 0
    Local cAdjustFields := ''    
    Local cField := ''

    If At( ' AS ', cFields ) > 0
        aFields := StrToArray( cFields, ',' )
        For nItem := 1 to len( aFields )
            If nItem > 1
                cAdjustFields += ', '
            EndIf

            cField := aFields[ nItem ]
            If ' AS ' $ Upper( cField )
                nPosAs := At( " AS ", Upper( cField ) )

                cAdjustFields += SubStr( cField, nPosAs + 4 )
            Else
                cAdjustFields += cField
            EndIf
        Next
    Else
        cAdjustFields := cFields
    EndIf
Return cAdjustFields


//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRRMakeStamp
Cria as colunas de  S_T_A_M_P_ nas tabelas informadas.

@param aTables, array, Lista de tabelas onde a coluna S_T_A_M_P_ deve ser criada.

@author Marcia Junko
@since 24/03/2022
/*/
//----------------------------------------------------------------------------------
Function GRRMakeStamp( aTables )
    Local cConfig
    Local nI
    Local lChangeStamp := .F.
    Local cSVAlias  := ''

    //===================================================================================
    // Esperando as funções do frame, mas poderia ser mais ou menos assim... - Funcionando
    //====================================================================================
    If TCConfig( 'GETAUTOSTAMP' ) == 'OFF' .Or. TCConfig( 'GETUSEROWSTAMP' ) == 'OFF'
        lChangeStamp := .T.

        cConfig := TCConfig( 'SETAUTOSTAMP=ON' )
        cConfig := TCConfig( 'SETUSEROWSTAMP=ON' )
    EndIf

    cSvAlias := Alias()

    For nI := 1 to Len( aTables )
        DbSelectArea( aTables[ nI ] )

        ( aTables[ nI ] )->( DbCloseArea() )
    Next

    If !Empty( cSvAlias )
        DbSelectArea( cSvAlias )
    EndIf
    
    If lChangeStamp
        cConfig := TCConfig( 'SETAUTOSTAMP=OFF' )    
        cConfig := TCConfig( 'SETUSEROWSTAMP=OFF' )
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRRetbyAttribute
Função para pesquisar dentro de vetor a posição de um atributo e 
retornar a posição.

@param aArray	Vetor contendo as informações.
@param cAttribute	Valor a ser pesquisado.

@return number, posição do atributo dentro do array
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------
Function GRRRetbyAttribute( aArray, cAttribute )
    Local nPos := 0
    
    nPos := Ascan( aArray, {|x| x[1] == Alltrim( cAttribute ) } )
Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRURL
Função que busca a URL do serviço no registry da TOTVS.

@return caracter, Retorna a URL de determinado serviço no registry da TOTVS
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------
Function GRRURL( )
    Local cURL := ''

    cURL := FwTotvsAppsRegistry():GetServiceURL( GRRService() )  
    If !Empty( cURL )
        cURL += '/rac'
    EndIf
Return cURL


//-------------------------------------------------------------------
/*/{Protheus.doc} GRRURLService
Função que busca a URL dos serviços de comunicação do GRR de acordo 
com o tipo

@param nType, number, indica qual o tipo de serviço

@return caracter, Retorna a URL de determinado serviço no registry da TOTVS
@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------
Function GRRURLService( nType )
    Local cURL := GRRURL()

    Default nType := GRR_CONCILIATION

    If nType == GRR_CONCILIATION
        cURL := StrTran( cURL, '/api/', '/reconciliation-api/' )
        cURL := StrTran( cURL, '/rac', '' )
    EndIF
Return cURL

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRISOCurrency
Função que retorna o código ISO de uma moeda de acordo com o país da 
instalação. O padrão utilizado é da ISO-4217.

@return caracter, Retorna o código da moeda no padrão ISO.
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------
Function GRRISOCurrency( )
    Local nPos := 0
    Local cResult := ''

    iF ( nPos := Ascan( __aCurrencyByCompany, { |x| x[ 1 ] == cEmpAnt } ) ) > 0 
        cResult := __aCurrencyByCompany[ nPos ][ 2 ]
    Else
        cResult := SeekISOCurrency()
        If !Empty( cResult )
            aAdd( __aCurrencyByCompany, { cEmpAnt, cResult } )
        EndIf
    EndIf
Return cResult


//-------------------------------------------------------------------
/*/{Protheus.doc} ISOCurrencyList
Retorna a lista de moedas x país de acordo com a ISO-4217.

@return array, Lista com as moedas x país
    [1] - Código da moeda na ISO
    [2] - Número
    [3] - Casas decimais
    [4] - Moeda
    [5] - Sigla do país
    [6] - Nome do país
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------
Static Function ISOCurrencyList( )
Return aISOList := { ;
        { 'AOA', 973, 2, STR0013, 'ANG', STR0014 }, ;   //'Kwanza'###'Angola'
        { 'ARS', 032, 2, STR0015, 'ARG', STR0016 }, ;   //'Peso argentino'###'Argentina'
        { 'BOB', 068, 2, STR0017, 'BOL', STR0018 }, ;   //'Boliviano'###'Bolívia'
        { 'BRL', 986, 2, STR0019, 'BRA', STR0020 }, ;   //'Real'###'Brasil'
        { 'CLP', 152, 0, STR0021, 'CHI', STR0022 }, ;   //'Peso chileno'###'Chile'
        { 'COP', 170, 0, STR0023, 'COL', STR0024 }, ;   //'Peso colombiano'###'Colômbia'
        { 'CRC', 188, 2, STR0025, 'COS', STR0026 }, ;   //'Colon da Costa Rica'###'Costa Rica'
        { 'DOP', 214, 2, STR0027, 'DOM', STR0028 }, ;   //'Peso dominicano'###'República Dominicana'
        { 'USD', 840, 2, STR0029, 'EQU', STR0030 }, ;   //'Dólar americano'###'Equador'
        { 'USD', 840, 2, STR0029, 'EUA', STR0031 }, ;   //'Dólar americano'###'Estados Unidos'
        { 'MXN', 484, 2, STR0032, 'MEX', STR0033 }, ;   //'Peso mexicano'###'México'
        { 'PYG', 600, 0, STR0034, 'PAR', STR0035 }, ;   //'Guarani'###'Paraguai'
        { 'PEN', 604, 2, STR0036, 'PER', STR0037 }, ;   //'Sol'###'Peru'
        { 'EUR', 978, 2, STR0038, 'PTG', STR0039 }, ;   //'Euro'###'Portugal'
        { 'UYU', 858, 2, STR0040, 'URU', STR0041 }, ;   //'Peso uruguaio'###'Uruguai'
        { 'VES', 928, 2, STR0042, 'VEN', STR0043 };     //'Bolivar'###'Venezuela'
    }


//-------------------------------------------------------------------
/*/{Protheus.doc} SeekISOCurrency
Pesquisa na lista de moedas ISO a ocorrência do país da instalação.

@return caracter, código da moeda na ISO-4217.
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------
Static Function SeekISOCurrency( )
    Local aCurrency := {}
    Local nPos := 0
    Local cResult := ''
    
    aCurrency := ISOCurrencyList()

    nPos := Ascan( aCurrency, { |x| x[ 5 ] == SuperGetMV( "MV_PAISLOC" ) } )

    IF nPos > 0
        cResult := aCurrency[ nPos ][ 1 ]
    else
        LogMsg( "GRRXFun", 23, 1, 1, "", "", STR0043 ) //"Não foi possível atribuir a moeda."
    EndIf

    FWFreeArray( aCurrency )
Return cResult


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRPlatParam
Função que retorna como array as informações de conexão com a plataforma.

@param aPlatInfo, array, vetor com as informações da conexão 

@return array, vetor com o nome da propriedade e o conteúdo.
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRPlatParam( aPlatInfo )
    Local aParams := {}

    Aadd( aParams, { "platform-clientId", AllTrim( aPlatInfo[ CLIENT_ID ] )  })
    Aadd( aParams, { "platform-secret", AllTrim( aPlatInfo[ CLIENT_SECRET ] )  })

Return aParams

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRFilterArray
Filtra um array por determinada condição.

@param aData, array, vetor com as informações originais
@param bCondition, codeblock, condição para execução do filtro

@return array, vetor somente com os itens que satisfazem a condição.
@author  Marcia Junko
@since   01/04/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRFilterArray( aData, bCondition )
    Local aResult:= {}

    aEval( aData, {|uValue, nIndex| ;
        If( Eval( bCondition, uValue, nIndex, aData ), ;
            aAdd( aResult, uValue ), ;
        Nil) ;
    })
Return ( aResult )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRLoadAppParams
Função que busca as configurações do GRR na tabela SYS_APP_PARAM

@param cIdentifier, caracter, item a ser pesquisado. A informação é case sensitive.

@return array, vetor com as informações do GRR
@author  Marcia Junko
@since   01/04/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRLoadAppParams( cIdentifier )
    Local aParams := {}
    Local aParamNames := {}
    Local oConfig

    default cIdentifier := lower( 'GRR' ) + '_'

    oConfig := GRRTFCfg()

    aParamNames := oConfig:GetNames()

    aParams := GRRFilterArray( aParamNames, {|x| cIdentifier $ x } )

    FWFreeArray( aParamNames )
    FreeObj( oConfig )
Return aParams 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRTreatStamp
Formata a expressão SQL para uso do campo S_T_A_M_P_ nas condições de query de acordo com
o banco de dados utilizado.

@paramcTable, caracter, Nome da tabela onde a condiçãp será avaliada
@param lAutomato, boolean, Indica que vai tratar pelo ADVPR.
@param nType, number, Indica o tipo de banco de dados, sendo 1=SQL, 2=Oracle e 3=Postgres

@return	Caracter, Expressão SQL formatada de acordo com o banco de dados utilizado.
@author  Marcia Junko
@since   18/04/2022
/*/
//-------------------------------------------------------------------------------------
function GRRTreatStamp( cTable, lAutomato, nType )
    Local cDbMs  := ''
    Local cQuery := ''

    Default lAutomato := .F.
    Default nType := 1
  
    cDbMs := Iif( !lAutomato, TcGetDb(), Iif( nType == 1, 'MSSQL', Iif( nType == 2, "ORACLE", "POSTGRES" ) ) )
    
    If "MSSQL" $ cDbMs
        cQuery := " CONVERT( VARCHAR( 23 ), " + cTable + ".S_T_A_M_P_ , 21 ) "
    ElseIf "ORACLE" $ cDbMs
        cQuery := " CAST( TO_CHAR(" + cTable + ".S_T_A_M_P_ , 'YYYY-MM-DD HH24:MI:SS.FF' ) AS VARCHAR( 23 ) ) "
    ElseIf "POSTGRES" $ cDbMs
        cQuery := " CAST( TO_CHAR(" + cTable + ".S_T_A_M_P_ , 'YYYY-MM-DD HH24:MI:SS.FF' ) AS VARCHAR( 23 ) ) "
    EndIf
Return cQuery

// //-------------------------------------------------------------------------------------
// /*/{Protheus.doc} GRRStampValue
// Efetua a formatação da data e hora no formato Time Stamp.

// @return	Caracter, Expressão do Time Stamp para controle de execuções por data.
// @author  Marcia Junko
// @since   18/04/2022
// /*/
// //-------------------------------------------------------------------------------------
// Function GRRStampValue()
//     Local cValue := ''

//     cValue    := FWTimeStamp( 6, DATE(), TIME() )
//     cValue    := StrTran( cValue, 'T', ' ' )
//     cValue    := StrTran( cValue, 'Z', '' )
// Return cValue

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRDTimeUTC
Função que converte data e hora em UTC

@param cTimeStamp, caracter, timestamp no formato aaaammddhhmmss

@return caracter, formato aaaammddhhmmss
@author  Marcia Junko
@since   18/04/2022
/*/
//-------------------------------------------------------------------
/*Function GRRDTimeUTC( cTimeStamp ) 
    Local aDateTime := {}

    Default cTimeStamp  := ""

    cTimeStamp := GRRFmtTStamp( cTimeStamp )

    If !Empty( cTimeStamp )
        aDateTime  := StrTokArr( cTimeStamp, " " )
        If Len( aDateTime ) == 2
            cTimeStamp := FWTimeStamp( 5, cTod( aDateTime[1] ), aDateTime[2] )
        EndIf
    EndIf

    FWFreeArray( aDateTime )
Return cTimeStamp
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRFmtTStamp
Função que converte um timestamp no formato aaaammddhhmmss
no formato dd/mm/aaaa hh:mm:ss.

@param cTimeStamp, caracter, timestamp no formato aaaammddhhmmss

@return caracter, formato data e hora 
@author  Marcia Junko
@since   18/04/2022
/*/
//-------------------------------------------------------------------
/*Function GRRFmtTStamp( cTimeStamp )
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
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRSyncTime
Função que salva as informações de sincronismo ao SYS_APP_PARAM

@param cName, caracter, Identificador
@param cSource, caracter, nome do fonte de origem da chamada
@param cStampValue, caracter, Data e hora do sincronismo
@param lRemove, boolean, indica se precisa remover caracteres da informação.
@param cIdentifier, caracter, Identificador da chave a ser buscada

@obs Ideal que se use a função FWTimeStamp com o tipo 6, pois ela é a mais
compatível com o conteúdo gravado no campo S_T_A_M_P_ das tabelas, não 
sendo necessário passos adicionais para a comparação via query.

@author  Marcia Junko
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Function GRRSyncTime( cName, cSource, cStampValue, lRemove, cIdentifier )
    Local aParams := {}
    Local lIsSandbox := .F.

    Default cStampValue := FWTimeStamp( 6 )
    Default lRemove := .T.
    Default cIdentifier := "grr_sync_"

    lIsSandbox := Iif( GRRSysValue( 'grr_sndbox' ) == "true", .T., .F. )

    if lIsSandbox
        cIdentifier += 'sndbox_'
    EndIf
    
    If lRemove
        cStampValue    := StrTran( cStampValue, 'T', ' ' )
        cStampValue    := StrTran( cStampValue, 'Z', '' )
    EndIf

    aAdd( aParams, { cIdentifier + cEmpAnt, cStampValue } )
    aAdd( aParams, { cIdentifier + cName + "_" + cEmpAnt, cStampValue } )
    GRRSaveAppParam( aParams )

    UnLockByName( cSource, .T., .F. )

    FWFreeArray( aParams )
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} GRRSysValue
Função que retorna o conteúdo gravado na SYS_APP_PARAM de acordo com a 
identificação passada.

@param cName, caracter, Identificador

@return caracter, Conteúdo da configuração.
@author  Marcia Junko
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Function GRRSysValue( cName )
    Local oConfig 
    Local cContent := ''
 
	If ( __oConfig == NIL .Or. ( cContent := __oConfig[ cName ] ) == NIL )
		cContent := ''
		oConfig := GRRTFCfg()
		If oConfig[ cName ] <> NIL
			cContent := oConfig[ cName ]
		EndIf
		__oConfig[ cName ] := cContent
		FreeObj( oConfig )
    EndIf
Return cContent


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRBranchFilter
Função que monta a instrução de filtro por filial de acordo com as filiais selecionadas.

@param aBranches, array, vetor com as informações das filiais selecionadas.
@param cTable, caracter, tabela em que o filtro será montado.

@return caracter, Instrução de filtro da filial
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRBranchFilter( aBranches, cTable )
    Local aBranch := {}
    Local cTableFilter := ''
    Local cBranch := ''
    Local cFilter := ''
    Local nI := 0

    If !Empty( cTable )
        For nI := 1 to len( aBranches )
            aBranch := StrtokArr( aBranches[ nI ], '-' )

            If Alltrim( aBranch[ 1 ] ) == cEmpAnt
                cBranch := xFilial( cTable, LTrim( aBranch[ 2 ] ) )
                IF !( cBranch $ cTableFilter )
                    If !Empty( cTableFilter ) 
                        cTableFilter += ", "
                    EndIf

                    cTableFilter += "'" + cBranch + "'"
                EndIf
            EndIf
        Next

        If !Empty( cTableFilter )
            cFilter := " " + PrefixoCpo( cTable ) + "_FILIAL IN ( " + cTableFilter + " ) "
        EndIf
    EndIf
Return cFilter 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSyncExec
Função que controla se o sincronismo de uma determinada entidade deve ser executado.

@param cName, caracter, Identificador
@param cSource, caracter, nome do fonte de origem da chamada
@param nType, number, identifica qual a medida utilizada pelo sincronismo, onde: 
    1 = sincroniza em dias
    2 = sincroniza em horas
    3 = sincroniza em minutos
@param nCycleValue, number, indica de quanto em quanto tempo a sincronização será feita.

@return boolean, Indica se o sincronismo deve ser realizado ou não
@author  Marcia Junko
@since   18/04/2022
/*/
//------------------------------------------------------------------------------------------
Function GRRSyncExec( cName, cSource, nType, nCycleValue )
    Local cLastExec := ''
    Local cLastSyncDate := ''
    Local cTimeExec := ''
    Local cNow := FWTimeStamp( 6 )
    Local cDate := ''
    Local cTime :=  ''
    Local dDate := NIL
    Local dLastSync := NIL
    Local lExecute := .F.
    Local lIsSandbox := .F.

    Default cName := 'items'
    Default nType := 1
    Default nCycleValue := 0

    If LockByName( cSource, .T., .F. )
        lIsSandbox := Iif( GRRSysValue( 'grr_sndbox' ) == "true", .T., .F. )

        if lIsSandbox
            cName := 'sndbox_' + cName
        EndIf

        //--------------------------------------------------------------
        // Se for chamado via job, sempre avalia se está dentro das 
        // condições de sincronismo
        //--------------------------------------------------------------
        If FWIsInCallStack( "GRRJobCommand" ) 
            If nType == 1 .And. nCycleValue == 0
                nCycleValue := SuperGetMV( "MV_GRRSYNC", .F., 7 )     
            EndIf

            cLastExec := GRRSysValue( "grr_sync_" + cName + "_" + cEmpAnt )
            cLastSyncDate := subs( cLastExec, 1, 10 )
            cLastSyncDate := Strtran( cLastSyncDate, '-', '' )
            dLastSync := STOD( cLastSyncDate )
            cTimeExec := subs( cLastexec, 12 )
            cDate := subs( cNow, 1, 10 )
            cDate := Strtran( cDate, '-', '' )
            dDate := STOD( cDate )
            cTime := Subs( cNow, 12, 8 )

            Do Case
                //--------------------------------------------------------------
                // Trata o sincronismo em dias
                //--------------------------------------------------------------
                Case nType == GRR_SYNC_DAYS         // 1=dias
                    If dDate > dLastSync + nCycleValue 
                        lExecute := .T.
                    EndIf
                
                //--------------------------------------------------------------
                // Trata o sincronismo em horas
                //--------------------------------------------------------------
                Case nType == GRR_SYNC_HOURS        // 2=horas
                    If ( dDate > dLastSync ) .Or. ( ( dDate == dLastSync ) .And. ( cTime >= IncTime( cTimeExec, nCycleValue ) ) )
                        lExecute := .T.
                    EndIf
                            
                //--------------------------------------------------------------
                // Trata o sincronismo em minutos
                //--------------------------------------------------------------
                Case nType == GRR_SYNC_MINUTES      // 3=minutos
                    If ( dDate > dLastSync ) .Or. ( ( dDate == dLastSync ) .And. ( cTime >= IncTime( cTimeExec, 0, nCycleValue ) ) )
                        lExecute := .T.
                    EndIf
            End

            If lExecute
                MsgAlert( I18N( STR0045, { cSource } ) )  //"Executando o sincronismo pelo job da rotina #1"
            EndIf
        Else
            //--------------------------------------------------------------
            // Se for via chamada direta sempre realiza o sincronismo
            //--------------------------------------------------------------
            lExecute := .T.
            LogMsg( "GRRSyncExec", 23, 6, 1, "", "", I18N( STR0046, { cSource } ) )	//"Executando o sincronismo direto da rotina #1"
        EndIf
    else
        MsgAlert( I18N( STR0047, { cSource } ) )  //"Outra intância está executando o sincronismo da #1"
    EndIf
Return lExecute


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSyncFlow
Função padrão para execução do controle de sincronismo sem a utilização de condições específicas.

@param cIdentifier, caracter, Identificador do sincronismo
@param aSteps, array, vetor com as etapas ( funções ) a serem chamadas durante o sincronismo.
@param nType, number, identifica qual a medida utilizada pelo sincronismo, onde: 
    1 = sincroniza em dias
    2 = sincroniza em horas
    3 = sincroniza em minutos
@param nCycleValue, number, indica de quanto em quanto tempo a sincronização será feita.

@obs Esta função deve ser usada somente nos casos onde seja possível fazer as chamadas dos 
passos diretamente pela atribuição do array aSteps. Caso seja necessário adicionar condições
para a execução de determinado passo, a utilização desta função não é recomendada, devendo o
analista criar o fluxo manualmente, conforme a sua necessidade.

@author  Marcia Junko
@since   03/08/2022
/*/
//------------------------------------------------------------------------------------------
Function GRRSyncFlow( cIdentifier, aSteps, nType, nCycleValue )
    Local nI := 0
    Local nAt := 0
    Local cSource := ''
    Local cFunction := ''
    Local cParams := ''

    Default aSteps := {}
    Default nType := 1
    Default nCycleValue := 0

    If !Empty( cIdentifier ) .And. !Empty( aSteps )
        //--------------------------------------------------------------
        // Retorna o nome do fonte PRW que fez a chamada da função
        //--------------------------------------------------------------
        cSource := ProcSource( 1 ) 
        cSource := StrTran( cSource, '.PRW', '' )  

        //--------------------------------------------------------------
        // Avalia se o sincronismo deve ser realizado
        //--------------------------------------------------------------
        IF GRRSyncExec( cIdentifier, cSource, nType, nCycleValue )
            //--------------------------------------------------------------
            // Executa os passos atribuídos ao sincronismo
            //--------------------------------------------------------------
            For nI := 1 to len( aSteps )
                If FindFunction( aSteps[ nI ] )
                    &( aSteps[ nI ] )   
                Else
                    nAt := At( '(', aSteps[ nI ] )
                    cParams := Subs( aSteps[ nI ], nAt + 1 )
                    cFunction := Subs( aSteps[ nI ], 1, nAt - 1 )

                    nAt := At( ')', cParams )
                    cParams := Subs( cParams, 1, nAt - 1 )

                    &( "STATICCALL( " + cSource + ", " + cFunction + ", '" + Alltrim( cParams ) + "' )" )
                EndIf
            Next        
            
            //--------------------------------------------------------------
            // Armazena a informação de execução ao controle de sincronismo
            //--------------------------------------------------------------
            GRRSyncTime( cIdentifier, cSource )
        EndIf
    EndIf
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSLMakeSetup
Atualiza na plataforma as subscrições do produto.

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.
@param aMessages, array, lista de mensagens da plataforma

@return, array, vetor com a lista de subsccrições ( mensagens ) atribuídas ao GRR.
@author  Marcia Junko
@since   20/04/2022
/*/
//-------------------------------------------------------------------------------------
/*Function GRRSLMakeSetup( oStatus, aMessages )
    Local cTenant := ''
    Local cEndpoint := ''
    Local cResult := ''
    Local cMsg := STR0048  //"Subscrições criadas com sucesso na plataforma."
    Local oBody := NIL
    Local oRest := NIL

    Default oStatus := NIL

    If !Empty( aMessages )
        cEndpoint := GRRSLUrl()
        cTenant := GRRGetTenant()

        oBody := JSONObject():New() 
        oBody[ "subscriptions" ] := aMessages 
        oBody[ "tenants" ] := { cTenant }

        cResult := GRRRestExec( 'POST', cEndpoint, '/link/setup', @oRest, oBody )

        If Empty( cResult )
            cMsg := STR0049     // "A T E N Ç Ã O - Falha na criação das subscrições na plataforma."
            LogMsg( "GRRSLMakeSetup", 23, 3, 1, "", "", cMsg )                     
        EndIf
        GRRWizStatus( @oStatus, cMsg  )
    EndIF

    FreeObj( oBody )
    FreeObj( oRest )
Return  
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRTokenInfo
Função que retorna dados específicos relacionados ao token

@param cToken, caracter, token
@param cInfo, caracter, propriedade a pesquisar

@return caracter, conteúdo pesquisado
@author  Marcia Junko
@since   20/04/2022
/*/
//-------------------------------------------------------------------------------------
/*Function GRRTokenInfo( cToken, cInfo )
    Local aToken := {}
    Local cJson := ''
    Local cResult := ''
    Local oPayLoad

    oPayLoad := JsonObject():New()

    aToken := StrTokArr( cToken, "." )
    cJson := Decode64( aToken[ 2 ] )

    oPayLoad:fromJson( cJson )
    cResult := oPayLoad[ cInfo ]

    FWFreeArray( aToken )
    FreeObj( oPayLoad )
Return cResult
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRGetTenant
Função que retorna o tenant do ambiente 

@return caracter, código do tenant
@author  Marcia Junko
@since   20/04/2022
/*/
//-------------------------------------------------------------------------------------
/*Function GRRGetTenant()
    Local aToken := {}
    Local cTenant := ''    
    
    aToken := GRRRacAccess( GRRURL() )
        
    If !Empty( aToken )
        cTenant := GRRTokenInfo( aToken[ 2 ], "http://www.tnf.com/identity/claims/tenantId"  )
    EndIF
    FWFreeArray( aToken )
Return cTenant
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSLMakeHeader
Função que cria o header para mensagem trafegadas pelo SmartLink.

@param cMessageType, caracter, Identificação da mensagem

@return object, Objeto JSON com a estrutura do aHeader para comnicação via SmartLink.
@author  Marcia Junko
@since   27/04/2022
/*/
//-------------------------------------------------------------------------------------
/*Function GRRSLMakeHeader( cMessageType )
    Local cTenant := ''    
    Local oHeader 

    cTenant := GRRGetTenant()
    
    If !Empty( cTenant )
        oHeader := JsonObject():New()
        oHeader[ "tenantId" ]       := cTenant
        oHeader[ "type" ]           := cMessageType
        oHeader[ "transactionId" ] := FWUUID( 'GRRSMARTLINK' )
    EndIf
Return oHeader
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSLUrl
Função que busca a URL do SmartLink utilizado no GRR.

@return caracter, Retorna a URL do SmartLink utilizado no GRR.
@author  Marcia Junko
@since   27/04/2022
/*/
//-------------------------------------------------------------------------------------
/*Function GRRSLUrl()
    Local cURL := ''

    // TODO - Descubrir uma forma de pegar o caminho do Smartlink sem chumbar
    // cURL :='https://link.dev.totvs.app/api/v1'
    cURL :='https://link.staging.totvs.app/api/v1'
    // cURL := FwTotvsAppsRegistry():GetServiceURL( GRRService()+'-smartlink' )
Return cURL
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSyncbySL
Esta função é responsável por sincronizar os dados do Protheus com a plataforma 
utilizando o SmartLink.

@param xItems, array ou JSON, dado a ser enviado
@param cMessageType, caracter, Identificador da mensagem

@author  Marcia Junko
@since   27/04/2022
/*/
//-------------------------------------------------------------------------------------
/*Function GRRSyncbySL( xItems, cMessageType )
    Local oData         := NIL
    Local oRest         := Nil
    Local oProtRest     := Nil
    Local oResult       := Nil
    Local cResult       := ''
    Local cHTTPCode     := ''
    Local cReference    := ''
    Local cProtResult   := ''
    Local cEndpoint     := ''
    Local cPath         := ''
    Local cMsg          := ''
    Local lRunning      := .T.

    cEndpoint := GRRSLUrl()

    IF ( !Empty( cEndpoint ) .And. !Empty( cMessageType ) ) .And. ;
        ( ( Valtype( xItems ) == "J" .And. len( xItems:Getnames() ) > 0 ) .Or. ( Valtype( xItems ) == "A" .And. !Empty( xItems ) ) )
            cPath := '/link/send/' + cMessageType + '/recorrencia'

            oData := JsonObject():New()
            oData[ "header" ]       := GRRSLMakeHeader( cMessageType )
            oData[ "content" ]      := xItems

            cResult := GRRRestExec( 'POST', cEndpoint, cPath, @oRest, oData )

            If !Empty( cResult )
                If cResult == 'false'
                    oResult := JSONObject():New() 

                    cProtResult := GRRRestExec( 'GET', cEndpoint, '/link/get', @oProtRest )
                    If !Empty( cProtResult )
                        oResult:FromJson( cProtResult )

                        If oResult[ 'data' ][ 'content' ][ 'typeError' ] <> 0
                            Sleep( 1000 )
                        else
                            // cMsg := I18N( "GRRSyncData -> INFO - Foram enviados #1 registros para sincronismo, sendo que #2 foram concluídos com sucesso e #3 falharam.", { oResult[ 'status' ][ 'total' ], oResult[ 'status' ][ 'completed' ], oResult[ 'status' ][ 'errors' ] } )
                            cMsg := I18N( "GRRSyncData -> INFO - " + STR0050, ;
                                { oResult[ 'status' ][ 'total' ], oResult[ 'status' ][ 'completed' ], oResult[ 'status' ][ 'errors' ] } )     //"Foram enviados #1 registros para sincronismo, sendo que #2 foram concluídos com sucesso e #3 falharam."
                    
                            LogMsg( "GRRSyncData", 23, 6, 1, "", "", cMsg ) 

                            lRunning := .F.
                        EndIf
                    EndIf
                EndIf
                // // Indica que fez uma ação em lote
                // If Valtype( xItems ) == "A"
                //     oResult := JSONObject():New() 
                //     oResult:FromJSON( cResult )

                //     cProtocol  := oResult[ 'url' ]
                //     cProtocol := Strtran( cProtocol, '/api/v1/rac', '')

                //         cProtResult := GRRRestExec( 'GET', cEndpoint, cProtocol, @oProtRest )

                //         // varinfo('cProtResult', cProtResult)

                //         If !Empty( cProtResult )
                //             oResult:FromJson( cProtResult )

                //             If oResult[ 'status' ][ 'running' ] <> 0
                //                 Sleep( 1000 )
                //             else
                ////                 cMsg := I18N( "GRRSyncData -> INFO - Foram enviados #1 registros para sincronismo, sendo que #2 foram concluídos com sucesso e #3 falharam.", { oResult[ 'status' ][ 'total' ], oResult[ 'status' ][ 'completed' ], oResult[ 'status' ][ 'errors' ] } )
                //                 cMsg := I18N( "GRRSyncData -> INFO - " + STR0050, { oResult[ 'status' ][ 'total' ], oResult[ 'status' ][ 'completed' ], oResult[ 'status' ][ 'errors' ] } )  //"Foram enviados #1 registros para sincronismo, sendo que #2 foram concluídos com sucesso e #3 falharam."
                        
                //                 LogMsg( "GRRSyncData", 23, 6, 1, "", "", cMsg ) 

                //                 lRunning := .F.
                //             EndIf
                //         else
                //             Sleep( 1000 )
                //         endif
                //     End                
                // EndIf
            Else                
                cHTTPCode := oRest:GetHTTPCode()
                IF cHTTPCode == '400' .Or. cHTTPCode == '500'
                    // TODO - Este tratamento deve estar presente até que a estrutura de todas as tabelas da plataforma
                    // sejam ajustadas para o campo reference.
                    If xItems:HasProperty( "reference" )
                        cReference := xItems[ 'reference' ]
                    Else
                        cReference := xItems[ 'externalId' ]
                    EndIf

                    // cMsg := "GRRSyncbySL -> ERRO - Ocorreram erros durante a sincronização do registro " + cReference + ": " + ;
                    //             EncodeUTF8( oRest:GetLastError() ) + " " + IIF( oRest:GetResult() != Nil, EncodeUTF8( oRest:GetResult() ), "" )
                    cMsg := I18N( "GRRSyncbySL -> " + STR0010, ;
                            { cReference , EncodeUTF8( oRest:GetLastError() ) + " " + IIF( oRest:GetResult() != Nil, EncodeUTF8( oRest:GetResult() ), "" ) } )  //"ERRO - Ocorreram erros durante a sincronização do registro #1: #2"
            
                    LogMsg( "GRRSyncbySL", 23, 3, 1, "", "", cMsg ) 
                EndIf
            EndIf
    EndIf

    FreeObj( oData )
    FreeObj( oRest )
Return Nil
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRNumAddress
Função que localiza o número de um endereço de acordo com um padrão ( após a vírgula ou 
último espaço )

@param cAddress, caracter, endereço do cliente

@return caracter, número da casa
@author  Marcia Junko
@since   06/05/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRNumAddress( cAddress )
    Local cNumber := ''
    Local nAt := 0

    //---------------------------------------------------
    // Localiza o numero do endereço    
    //---------------------------------------------------    
    nAt := At( ',',  cAddress )
    If nAt > 0
        cNumber := alltrim( Subs( cAddress, nAt + 1 ) )
    Else
        nAt := RAt( ' ', cAddress)
        cNumber := alltrim( Subs( cAddress, nAt + 1 ) )
    EndIf
Return cNumber


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRLoadSX5
Função que carrega as informações de uma tabela da SX5.

@param cTable, caracter, tabela do SX5

@return array, lista com os registros de determinada tabela do SX5.
@author  Marcia Junko
@since   06/05/2022
/*/
//-------------------------------------------------------------------------------------
/*Function GRRLoadSX5( cTable )
    Local aSvAlias := GetArea()
    Local aData := {}

    SX5->( DbSetOrder( 1 ) )    // X5_FILIAL + X5_TABELA

    If SX5->( dbSeek( xFilial( "SX5" ) + cTable ) ) 
        While SX5->( !Eof() ) .And. SX5->X5_FILIAL == xFilial( "SX5" ) .And. SX5->X5_TABELA == cTable 
            aAdd( aData, { SX5->X5_CHAVE, X5Descri() } )

            SX5->( DBSkip() )
        End        
    EndIf

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
Return aData
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRX5Content
Função que retorna a descrição de um registro específico da SX5.

@param cTable, caracter, tabela do SX5
@param cKey, caracter, chave da tabela para pesquisa

@return caracter, Descrição do registro no idioma corrente
@author  Marcia Junko
@since   06/05/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRX5Content( cTable, cKey )
    Local aSvAlias := GetArea()
    Local cContent := ''

    SX5->( DbSetOrder( 1 ) )    // X5_FILIAL + X5_TABELA + X5_CHAVE

    If SX5->( dbSeek( xFilial( "SX5" ) + cTable + cKey ) ) 
       cContent := X5Descri()
    EndIf

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
Return Alltrim( cContent )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRPesqPict
Função que retorna a picture de um campo cadastrado no dicionário

@param cField, caracter, Nome do campo

@return caracter, Descrição do registro no idioma corrente
@author  Marcia Junko
@since   25/05/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRPesqPict( cField )
    Local cTable := ''
    Local cPicture := ''

    If !Empty( cField )
        cTable := GRRAliasXField( cField )
        cPicture := PesqPict( cTable, cField )
    EndIf
Return cPicture


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRAliasXField
Função que retorna a tabela à partir de um campo

@param cField, caracter, Nome do campo

@return caracter, Alias do campo
@author  Marcia Junko
@since   25/05/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRAliasXField( cField )
    Local cTable := ''
    Local nPos := 0

    If !Empty( cField )
        nPos := At( '_', cField )
        cTable := Substr( cField, 1, nPos - 1)

        If len( cTable ) == 2
            cTable := "S" + cTable 
        EndIf
    EndIf
Return cTable


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRProcJob
Função auxiliar para iniciar o ambiente para execução das funções

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando executada por
User Function

@return boolean, indica se está sendo executado via Schedule ou User Function
@author  Marcia Junko
@since   27/05/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRProcJob( aParam, cFil )
    Local cCompany := NIL
    Local cBranch := NIL
    Local lJob := .F.

    Default aParam := nil
    Default cFil := NIL

    //-------------------------------------------------------------------
    // Tratamento para validar se a execução é via JOB ou User Function
    //-------------------------------------------------------------------
    If Valtype( aParam ) != "A" 
        If ValType( aParam ) <> "C" .AND. !Empty( cEmpAnt )
            cCompany := cEmpAnt
            cBranch := cFilant
        Else
            cCompany := aParam
            cBranch := cFil
            lJob  := .T.
        EndIf
    Else
        lJob :=  .T.
        cCompany := aParam[1]
        cBranch := aParam[2]
    EndIf
    
    IF lJob
        RPCSetType( 3 )
        RPCSetEnv( cCompany, cBranch )
    EndIF 
Return lJob


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRDataAction
Função executada ao clicar no botão Informar dados.
Esta função é responsável por montar a AXINCLUI para informar os dados adicionais ao 
incluir o registro na base de dados.

@param aDataInfo, array, Vetor com as informações específicas da tela, onde:
    [1] - título da tela
    [2] - campos essencias
    [3] - conteúdo fixo
    [4] - tratamento de descrição
@param aArray, array, armazena os dados da entidade
@param lExist, boolean, variável de controle do botão. Se ocorrer a inclusão pela
função, o botão no wizard deve ser desabilitado. (passado por referência)

@author  Marcia Junko
@since   01/06/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRDataAction( aDataInfo, aArray, lExist )
    Local aSvAlias := GetArea()
    Local aParam := Array(4)
    Local aFields := {}
    Local cAlias := ''
    Local nPos := 0

    Private cCadastro

    cCadastro := aDataInfo[ 1 ]
    aFields := aDataInfo[ 2 ]

    if type("Inclui") == "U"
        private Inclui := .T.
    endIf
    
    If !Empty( aFields )
        cAlias := GRRAliasXField( aFields[1] ) 
    
        aParam[1] := {|| SetFldEnch( cAlias, aDataInfo, aArray )}
        aParam[2] := {|| .T. }
        aParam[3] := {|| .T. }
        aParam[4] := {|| .T. }
        
        If AxInclui( cAlias, 1, , , , , , , , , aParam ) == 1
            lExist := .T.
            For nPos := 1 to len( aFields )
                aArray[ nPos ] := ( cAlias )->&( aFields[ nPos ])
            Next
        EndIf
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aParam )
    FWFreeArray( aFields )
    FWFreeArray( aSvAlias ) 
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetFldEnch
Função responsável em atribuir um conteúdo padrão aos campos da enchoice.

@param cType, caracter, Alias da tabela principal
@param aDataInfo, array, Vetor com as informações específicas da tela, onde:
    [1] - título da tela
    [2] - campos essencias
    [3] - conteúdo fixo
    [4] - tratamento de descrição
@param aValue, array, Contém os dados do registro

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SetFldEnch( cType, aDataInfo, aValue )
    Local aFields := {}
    Local aFixContent := {}
    Local aOtherInfo := {}
    Local nPos := 0
    Local nFind := 0
    Local cAuxDesc := ''
    Local cField := ''
    Local cPrefix := ''
    Local lOther := .F.

    aFields := aDataInfo[ 2 ]
    aFixContent := aDataInfo[ 3 ]
    aOtherInfo := aDataInfo[ 4 ]

    For nPos := 1 To Len( aFields )
        cField := aFields[ nPos ]
        lOther := .F.

        If ( nFind := Ascan( aOtherInfo, {|x| x[1] == cField } ) ) > 0
            cAuxDesc := aOtherInfo[ nFind ][2]
            lOther := .T.
        EndIf

        If !lOther
            M->&( cField ) := aValue[ nPos ]
        Else
            M->&( cField ) := cAuxDesc
        EndIF
    Next

    If !Empty( aFixContent )
        cPrefix := PrefixoCpo( cType )
        If cType == 'SA1'
            Aadd( aFixContent, { 'A1_PESSOA', 'J' } )
            Aadd( aFixContent, { 'A1_TIPO', 'F' } )
        ElseIf cType == 'SA2'
            Aadd( aFixContent, { 'A2_TIPO', 'J' } )
        EndIf

        For nPos := 1 to len( aFixContent )
            cField := aFixContent[ nPos ][1]

            IF !( cPrefix + '_' $ cField )
                cField := cPrefix + '_' + cField
            EndIf
            M->&( cField ) := aFixContent[ nPos ][2]
        Next
    ENDIF
Return Nil


//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRRIsActive
Funcao que retorna se a integração com o GRR está ativa.

@return lógico, Retorna se a integração com o GRR está ativa na empresa\filial corrente.
@author Marcia Junko
@since  14/06/2022
/*/
//-------------------------------------------------------------------------------
Function GRRIsActive()
    Local lIsActive := .F. 
    
    If IsGRRUpdated()
        IF Empty( __aGRROrganizations )
            __aGRROrganizations := GRRActBranches( .F. )
        EndIf

        IF Ascan( __aGRROrganizations, {|x| Alltrim( cEmpAnt )  + ' - ' + Alltrim( cFilAnt ) + ' - ' $ x } ) > 0
            lIsActive := .T.
        EndIf

        lIsActive := Iif( __lAutomato .And. !lIsActive, SuperGetMV( "MV_GRRACTI", .F., .F. ), lIsActive )
    EndIf 
Return lIsActive 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRRIsSndbox
Função que indica se a integração está usando o modo Produção ou Sandbox.

@param cSeek, caracter, nome da tag relacionada ao uso do Sandbox

@return lógico, Se .T. indica que a integração do GRR usa o modo Sandbox, 
            se .F., utiliza o modo Produção.
@author Marcia Junko
@since  14/06/2022
/*/
//-------------------------------------------------------------------------------
Function GRRIsSndbox( cSeek )
    Default cSeek := 'grr_sndbox'

    If __lGRRSndbox == Nil 
        __lGRRSndbox := Iif( GRRSysValue( cSeek ) == "true", .T., .F. )
    EndIf 
Return __lGRRSndbox 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRChkX6Filled
Avalia se um determinado parâmetro está preenchido.

@param cParam, caracter, nome do parâmetro para pesquisar

@return boolean, Se .T. indica que o parâmetro está preenchido
@author  Marcia Junko
@since   19/07/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRChkX6Filled( cParam )
Return !Empty( SuperGetMV( cParam, .F., '' ) )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSysIdentifier
Monta o identificador do atributo de acordo com a origem e uso do Sandbox.

@param cName, caracter, nome do atributo
@param cSourceName, caracter, origem do atributo. Por padrão, refere-se aos dados do grr_sync
@param lSync, boolean, indica se é um atributo de sincronismo. Caso o identificador não seja
    associado a um sync, recomenda-se passar o nome completo no parâmetro cSourceName.

@return caracter, identificador real do atributo.
@author  Marcia Junko
@since   29/08/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRSysIdentifier( cName, cSourceName, lSync )
    Local lIsSandbox := .F.
    Local cIdentifier := ''

    Default cSourceName := 'grr_'
    Default lSync := .T.

    cIdentifier := cSourceName

    cIdentifier += Iif( lSync, 'sync_', '' ) 

    lIsSandbox := Iif( GRRSysValue( 'grr_sndbox' ) == "true", .T., .F. )

    if lIsSandbox
        cIdentifier += 'sndbox_'
    EndIf

    cIdentifier += cName
RETURN cIdentifier 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRArrtoJson
Função que prepara as informações de um array no formato Json.

@param aData, array, vetor com informações, onde: 
    [1] - nome da propriedade
    [2] - conteúdo

@return json, componente com as propriedades no formato JSON
@author  Marcia Junko
@since   12/09/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRArrtoJson( aData )
    Local jData := NIL
    Local nI := 0

    jData := JsonObject():New()
    For nI := 1 to len( aData )
        jData[ aData[ nI ][ 1 ] ] := aData[ nI ][ 2 ]
    Next
Return jData


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSetJsonValue
Função que atribui uma informação a uma propriedade específica de um array de json.

@param @aArray, vetor, array com a estrutura json
@param cField, caracter, nome do campo para busca
@param xValue, any, conteúdo que será atribuído.
@param cName, caracter, nome da propriedade para pesquisa
@param cValueName, caracter, nome da propriedade que recebe o conteúdo xValue

@author  Marcia Junko
@since   12/09/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRSetJsonValue( aArray, cField, xValue, cName, cValueName )
    Local nI := 0

    Default cName := 'key'
    Default cValueName := 'value'

    If ( nI := Ascan( aArray, {|x| x[ cName ] == Alltrim( cField ) } ) ) > 0
        aArray[ nI ][ cValueName ] := xValue
    EndIf
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRADVPRExec
Função que avalia se está sendo executado um script ADVPR

@return boolean, Indica se está sendo executado por um script ADVPR.
@author  Marcia Junko
@since   04/11/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRADVPRExec()
Return ( FWIsInCallStack( "FWMYTESTRUNNER" )  .Or. FWIsInCallStack( "CASIGAADV" ) .Or. FWIsInCallStack( "CACOVERTEST" ) .Or. FWIsInCallStack( "CAUNITTEST" ) .Or. FWIsInCallStack( "AUTJOBRUNCT" ) )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRRestHeader
Função que monta o header das requisições REST do GRR.

@param cEndPoint, caracter, URL do serviço
@param nTypeAuth, number, identifica qual a URL do RAC utiliza
    1 - admin ( autenticação de serviços )
    2 - autenticação
@param lCompanyID, boolean, indica se adiciona a propriedade companyId no aHeader da requisição

@return array, Vetor com as informações do header para execução do serviço via REST.
@author  Marcia Junko
@since   04/11/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRRestHeader( cEndpoint, nTypeAuth, lCompanyID )
    Local aToken := {}
    Local aHeader := {}

    Default nTypeAuth     := SERVICE      // 1=URL de autenticação de serviços
    Default lCompanyID    := .T.

    aToken := GRRRacAccess( cEndpoint, nTypeAuth ) 

    If !Empty( aToken )
        AAdd( aHeader, "Content-Type: application/json" )  
        AAdd( aHeader, "Charset: UTF-8")
        AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )  
        AAdd( aHeader, "Authorization: Bearer " + aToken[ 2 ] )
        If lCompanyID
            AAdd( aHeader, "companyID: " + cEmpAnt )
        EndIf
        Aadd( aHeader, "X-Sandbox-Mode: " + iif( GRRIsSndbox( ), "ON", "OFF" ) )
    EndIf
 
Return aHeader


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRInDebug
Função que indica se as informações devem ser apresentadas no console.

@param cParam, caracter, nome do parâmetro no appserver.ini

@return boolean, indica se deve apresentar informações no console.
@author  Marcia Junko
@since   28/12/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRInDebug( cParam )
    Local lDebug := .F.

    Default cParam := "GRRDebug"

    lDebug := ( __lAutomato .Or. Upper( GetSrvProfString( cParam, "OFF" ) ) == "ON" )

Return lDebug


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRDebugInfo
Função que apresenta as informações solicitadas no console

@param aInfo, array, vetor com as informações a apresentar no console, onde: 
    [1] - texto a apresentar
    [2] - conteúdo

@author  Marcia Junko
@since   28/12/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRDebugInfo( aInfo )
    Local nI := 0

    Default aInfo := {}

    If Len( ainfo ) > 0
        If GRRInDebug(  )
            For nI := 1 to len( aInfo )
                varinfo( cBiStr( aInfo[nI][1] ), aInfo[nI][2] )
            Next
        EndIf
    EndIf
Return 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRAllResponse
Função que retorna todos os registros apresentados pelo serviço.

@param cEndPoint, caracter, URL do serviço
@param cPath, caracter, Path da plataforma para validar os dados de conexão.
@param aSteps, array, vetor com as etapas ( funções ) a serem chamadas durante o sincronismo.
@param cInfoData, caracter, nome da propriedade para iterar

@obs: Para utilizar esta função é necessário que a função passada no array aSteps retorne 
um array

@return array, vetor com todos os registros retornados pelo serviço

@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRAllResponse( cEndpoint, cPath, aSteps, cInfoData )
    Local aResult := {}
    Local aData := {}
    Local cPage := ''
    Local cResult := ''
    Local lFirst := .T.
    Local lHasNext := .F.
    Local nI := 0
    Local nPage := 1
    Local oRest
    Local oResult
    Local oJson

    Default cInfoData := 'responseData'

    If !Empty( cEndpoint ) .And. !Empty( cPath ) //.And. !Empty( aSteps )
        While lFirst .Or. lHasNext
            oRest := NIL
            lHasNext := .F.

            IF lFirst
                lFirst := .F.
            else
                nPage++
                cPage := Iif( '?' $ cPath, "&page=", "?page=" ) + Alltrim( Str( nPage ) )
            EndIf

            cResult := GRRRestExec( 'GET', cEndpoint, cPath + cPage, @oRest )

            If !Empty( cResult )
                oResult := JSONObject():New() 
                oResult:FromJSON( cResult )

                lHasNext := oResult[ 'hasNext' ]
                aResult := oResult[ cInfoData ]

                If !Empty( aResult )
                    If FWJsonDeserialize( cResult, @oJson)
                        If AttIsMemberOf( oJson, cInfoData )
                            For nI := 1 to len( oJson:responseData )
                                oData := oJson:responseData[ nI ]

                                If !Empty( aSteps )
                                    GRRExecStep( aSteps, @aData )
                                Else
                                    aAdd( aData, oJson:responseData[ nI ] )
                                EndIf
                            Next    
                        EndIf 
                    EndIf
                EndIF
            EndIf
        End
    EndIf

    FWFreeArray( aResult )
    FreeObj( oRest )
    FreeObj( oResult )
    FreeObj( oJson )
Return aClone( aData )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRPatchExec
Função que atualiza algumas propriedades do serviço. ( PATCH )

@param aService, array, informações do serviço, onde: 
    [1] - endpoint
    [2] - path
@param aValues, array, vetor com as propriedades a serem atualizadas na fatura, onde:  
    [1] - nome da propriedade
    [2] - conteúdo
@param cPropName, caracter, nome da propriedade para verificar no response.
@param cMsg, caracter, mensagem a ser apresentada.

@return boolean, indica se o registro foi atualizado
@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRPatchExec( aService, aValues, cPropName, cMsg )
    Local cEndpoint := ''
    Local cPath := ''
    Local cResult := ''
    Local lRet := .F.
    Local jJson
    Local oResult

    If !Empty( aService ) .And. !Empty( aValues ) .And. !Empty( cPropName )
        cEndpoint := aService[ ENDPOINT ]
        cPath := aService[ PATH ]

        If !Empty( cEndpoint ) .And. !Empty( cPath )
            IF !Empty( aValues )
                jJson := GRRArrtoJson( aValues )
            
                cResult := GRRSyncData( NIL, jJson, cEndPoint, cPath, GRR_PATCH, NIL, @cMsg )

                If !Empty( cResult )
                    oResult := JSONObject():New() 
                    oResult:FromJSON( cResult )

                    If !Empty( oResult[ cPropName ] ) 
                        lRet := .T.
                    Endif
                EndIf
            EndIf
        EndIf
    EndIf
    FreeObj( oResult )
    FreeObj( jJson )
Return lRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRExecStep
Função que processa as etapas indicadas e retorna o seu conteúdo para processamento 
adicionais.

@param aSteps, array, vetor com as etapas ( funções ) a serem chamadas durante o sincronismo.
@param @aData, array, vetor com o conteúdo processado pelas etapas do aSteps

@return array, conteúdo processado pelas etapas do aSteps
@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRExecStep( aSteps, aData )
    Local aParams := {}
    Local nI := 0
    Local nAt := 0
    Local cParams := ''
    Local cFunction := ''
    Local cSource := ''

    //--------------------------------------------------------------
    // Retorna o nome do fonte PRW que fez a chamada da função
    //--------------------------------------------------------------
    cSource := ProcSource( 2 ) 
    cSource := StrTran( cSource, '.PRW', '' )  

    //--------------------------------------------------------------
    // Executa os passos atribuídos ao sincronismo
    //--------------------------------------------------------------
    For nI := 1 to len( aSteps )
        If FindFunction( aSteps[ nI ] )
            &( aSteps[ nI ] )   
        Else
            nAt := At( '(', aSteps[ nI ] )
            cParams := Subs( aSteps[ nI ], nAt + 1 )
            cFunction := Subs( aSteps[ nI ], 1, nAt - 1 )

            nAt := At( ')', cParams )
            cParams := Subs( cParams, 1, nAt - 1 )

            &( "STATICCALL( " + cSource + ", " + cFunction + ", " + Alltrim( cParams ) + " )" )
        EndIf
    Next        

    FWFreeArray( aParams )
Return aData

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRRGetQuery
Função responsável por verificar no cache se a query já foi executada anteriormente.
Caso ainda não tenha sido executada, cria a query base de acordo com a operação que
está sendo executada.

@param cOper, caracter, Identifica qual a query será retornada

@return object, Objeto contendo a query a ser executada.
@author Marcia Junko
@since 23/01/2023
/*/
//----------------------------------------------------------------------------------
Function GRRGetQuery( cOper )
    Local oPrepare := Nil
    Local cQuery := ''
    Local cTreatQuery := ''
    Local cSource := ''
    Local cName := ''

    If !Empty( cOper )
        cName := Alltrim( cOper ) + '_' + cEmpAnt
        If !HMGet( _oGRRHshQry, cName, @cTreatQuery )
            //--------------------------------------------------------------
            // Retorna o nome do fonte PRW que fez a chamada da função
            //--------------------------------------------------------------
            cSource := ProcSource( 2 ) 
            cSource := StrTran( cSource, '.PRW', '' )  

            cQuery := &( "STATICCALL( " + cSource + ", MakeQueryModel, cOper ) " )

            If !Empty( cQuery )
                cTreatQuery := GRRTreatQuery( cQuery )

                HMSet( _oGRRHshQry, cName, cTreatQuery )
            EndIf
        EndIf

        If !Empty( cTreatQuery )
            oPrepare := FWPreparedStatement():New( cTreatQuery )
        EndIf
    EndIf
Return oPrepare


//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRRTreatQuery
Função responsável por tratar as queries, adicionando o tratamento de paginação, caso
especificado pela tag <<PAGE_CONTROL>> e realizar a chamada da ChangeQuery.

@param cQuery, caracter, string com a consulta SQL ( query )

@return caracter, consulta SQL tratada.
@author Marcia Junko
@since 23/01/2023
/*/
//----------------------------------------------------------------------------------
Function GRRTreatQuery( cQuery )
    Local cResult := ''

    cResult := GRRPgControl( cQuery )
    cResult := ChangeQuery( cResult )
Return cResult


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRTreatData
Função que ajusta a data do registro para uso no serviço

@param cValue, caracter, Data do lote a ser processado

@return caracter, data no formato aaaa-mm-dd
@author  Marcia Junko
@since   27/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRTreatData( cValue )
    Local cData := ''
    Local nPos := 0

    nPos := At( 'T', cValue )
    cData := SubStr( cValue, 1, nPos-1 )
Return cData 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRVldMessage
Valida se <oMessage> contêm as propriedades listadas em <aPropObg>

@param oMessage, instância de JsonObject, json da mensagem
@param aPropObg, vetor, estrutura esperada em <oMessage>

@return lMsgValid, lógico, se a mensagem está no formato esperado
@author philipe.pompeu
@since 30/06/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRVldMessage( oMessage, aPropObg )
    Local nX  := 0
    Local lMsgValid := ( ValType( oMessage ) == "J" )

    If lMsgValid        
        for nX := 1 to Len( aPropObg ) //Valida estrutura do objeto
            lMsgValid := oMessage:HasProperty( aPropObg[ nX ] )            
            If !lMsgValid
                LogMsg( "GRRVldMsg", 23, 6, 1, "", "", I18N( STR0051, { aPropObg[ nX ] } ) )  //'Propriedade #1 inexistente'
                Exit
            EndIf
        next        
    EndIf
Return lMsgValid


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSLSendMsg
Envia <cJson> para o Smartlink

@param cJson, caractere, conteúdo da mensagem
@param cTypeName, caractere, nome do tipo a ser enviado

@return lSuccess, lógico, se a mensagem foi enviada com sucesso 
@author philipe.pompeu
@since 30/06/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRSLSendMsg( cJson, cTypeName )
    Local oClient       := Nil
    Local lSuccess      := .F.
    Local cTenantId     := ""
    Local cAudience     := "gestao-de-recorrencia"
    
    Default cTypeName   := "PaymentOrderProtheusCreated"

    oClient := FwTotvsLinkClient():New()

    If MethIsMemberOf( oClient,'GetTenantClient' )  
        cTenantId := oClient:GetTenantClient()
    EndIf
    
    lSuccess := (__lAutomato .Or. oClient:SendAudience( cTypeName, cAudience, cJson ))

    FreeObj(oClient)
Return lSuccess

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRChgConn
Função para abertura do ambiente nos fluxos internos.

@param cCompany, caracter, empresa onde o ambiente será aberto
@param cBranch, caracter, filial onde o ambiente será aberto

@author Marcia Junko
@since 23/05/2024
/*/
//-------------------------------------------------------------------------------------
Function GRRChgConn( cCompany, cBranch )
    If cEmpAnt == cCompany
        If cFilAnt != cBranch
            cFilAnt := cBranch
        EndIf
    Else
        RpcClearEnv()
        GRRConnCompany( cCompany, cBranch )
    EndIf
Return 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRMakeDir
Função para criar as pastas do GRR no Protheus Data

@param cPath, caracter, Path para criação do diretório
@param lVerify, boolean, Indica se deve avaliar todas as pastas
@return lRet, boolean, Indica se conseguiu criar o diretório

@author Marcia Junko
@since 27/06/2024
/*/
//-------------------------------------------------------------------------------------
Function GRRMakeDir( cPath, lVerify )
    Local aPath As Array
    Local nI As Numeric
    Local nResult As Numeric
    Local cAux As Character
    Local lRet As Logical

    Default lVerify := .T.

    aPath := {}
    nI := 0
    nResult := 0
    cAux := ''
    lRet := .T.

    If ( !ExistDir( cPath ) )
        If lVerify
            aPath := StrTokArr( cPath, '\' )

            For nI := 1 to len( aPath )
                cAux += '\' + aPath[ nI ]

                nResult := MakeDir( cAux )
                If nResult <> 0
                    Exit
                EndIf
            Next
        Else
            nResult := MakeDir( cPath )
        EndIf
    EndIf

    If nResult <> 0
        lRet := .F.
        LogMsg( "GRRMakeDir", 23, 6, 1, "", "", "GRRMakeDir -> " + I18N( STR0055, { cPath } ) )
    EndIf

    FWFreeArray( aPath )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRAutoError
Função para tratar os erros da ExecAuto

@param @cError, caracter, Texto de retorno da validação da ExecAuto
@param cFuncName, caracter, Nome da função para apresentar na mensagem de erro.
@param lShowMsg, boolean, Indica se será apresentada a mensagem de erro.

@return boolean, Indica se conseguiu realizar a ação da ExecAuto.
@author Marcia Junko
@since 27/06/2024
/*/
//-------------------------------------------------------------------------------------
Function GRRAutoError( cError, cFuncName, lShowMsg )
    Local aErroAuto := {}
    Local nI := 0
    Local lRet := .T.
    
    Default lShowMsg := .T.
    
    If Valtype( lMsErroAuto ) == "L" .And. lMsErroAuto
        cError := ""
        lRet := .F.
        
        aErroAuto := GetAutoGRLog()
        For nI := 1 To Len( aErroAuto ) 
            cError += aErroAuto[ nI ]
        Next

        If !Empty( cError ) .And. lShowMsg
            LogMsg( cFuncName, 23, 6, 1, "", "", cFuncName + " -> " + cError )
        EndIf
    EndIf

    FWFreeArray( aErroAuto )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GRRTFCfg
Função responsável por retornar em cache o conteúdo da FWTFConfig()

@return Object, Objeto da FWTFConfig()
@author  Nilton Rodrigues
@since   13/06/2024
/*/
//-------------------------------------------------------------------
Function GRRTFCfg()
    Default __oConfig := FWTFConfig()
Return __oConfig 


//-------------------------------------------------------------------
/*/{Protheus.doc} GRRVldHRI
Função responsável por consultar HRI para saber se o titulo segue fluxo 
de boleto Protheus e não tenta realizar a baixa do titulo.

@return boolean, Indica se segue o fluxo de boleto Protheus
@author ivan.magno
@since 28/04/2025
/*/
//-------------------------------------------------------------------
Function GRRVldHRI()
    Local cQuery    as Char
	Local cAliasTmp as Char
    Local lRet      as Logical
    Local oQuery    as Object

    lRet      := .F.   
    cAliasTmp := "" 

    If _oExVldHri == Nil
        cQuery := " SELECT COALESCE(COUNT(*),0) TOTAL "
        cQuery += " FROM "+ RetSqlName("SF2") +" SF2 "
        cQuery += " INNER JOIN "+ RetSqlName("SE1") +" SE1 ON "
        cQuery +=   FWJoinFilial("SE1", "SF2")
        cQuery += " AND SE1.E1_PREFIXO = SF2.F2_SERIE "
        cQuery += " AND SE1.E1_NUM = SF2.F2_DOC "
        cQuery += " AND SE1.E1_TIPO = ? " 
        cQuery += " AND SE1.D_E_L_E_T_ = ? "
        cQuery += " INNER JOIN "+ RetSqlName("HRI") +" HRI ON "
        cQuery += " HRI.HRI_FILIAL = ? " 
        cQuery += " AND HRI.HRI_SRCFIL = SE1.E1_FILIAL "
        cQuery += " AND HRI_ALIAS = ? " 
        cQuery += " AND HRI_REQCD = SE1.E1_PREFIXO || SE1.E1_NUM || SE1.E1_PARCELA || SE1.E1_TIPO "
        cQuery += " AND HRI.D_E_L_E_T_ = ? " 
        cQuery += " WHERE SF2.F2_FILIAL = ?" 
        cQuery += " AND  SF2.F2_DOC = ? " 
        cQuery += " AND SF2.F2_SERIE = ? " 
        cQuery += " AND SF2.F2_CLIENTE = ? " 
        cQuery += " AND SF2.F2_LOJA = ? " 
        cQuery += " AND SF2.D_E_L_E_T_= ? "
        cQuery := ChangeQuery(cQuery)
        _oExVldHri := FWExecStatement():New(cQuery)	
    Endif    
    oQuery := _oExVldHri

    oQuery:SetString(1, MVNOTAFIS )
    oQuery:SetString(2, Space(1) )
    oQuery:SetString(3, xFilial("HRI")  )
    oQuery:SetString(4, 'SE1')
    oQuery:SetString(5, Space(1) )   
    oQuery:SetString(6, xFilial("SF2")  )
    oQuery:SetString(7, SC5->C5_NOTA   )
    oQuery:SetString(8, SC5->C5_SERIE  )
    oQuery:SetString(9, SC5->C5_CLIENTE)
    oQuery:SetString(10, SC5->C5_LOJACLI)
    oQuery:SetString(11, Space(1) )
    
    nTotal := oQuery:ExecScalar("TOTAL")
    lRet   := nTotal > 0    

Return lRet
