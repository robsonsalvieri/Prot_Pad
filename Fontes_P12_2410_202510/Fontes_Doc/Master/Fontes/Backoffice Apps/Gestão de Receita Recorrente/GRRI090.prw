#include "protheus.ch"
#Include 'FWMVCDef.ch'
#include "GRRXDefs.CH"

/*-----------------------------------------------------
        Informações do OrganizationIntegrationID
-----------------------------------------------------*/
#DEFINE ORG_COMPANY         1
#DEFINE ORG_BRANCH          2

//-------------------------- GRRI090 ------------------------------------------------
// Funções de envio dos boletos para a plataforma de volta.
//-----------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI090
Função que prepara as informações necessárias para o envio de boleto para a plataforma.

@param lForceExit, boolean, Controla a simulaão de erro do envio da mensagem quando executada pelo ADVPR.

@author  Rodrigo Soares
@since   03/07/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRI090( lForceExit )
    Local aSvAlias := GetArea()
    Local cSource := ''

    Default lForceExit := .F.

    //--------------------------------------------------------------
    // Retorna o nome do fonte PRW que fez a chamada da função
    //--------------------------------------------------------------
    cSource := ProcSource( 0 ) 
    cSource := StrTran( cSource, '.PRW', '' )  

    IF GRRSyncExec( 'bankSlip', cSource )        
        BEGIN TRANSACTION
            //-----------------------------------------------------------------------
            // Sincroniza os boletos do Protheus com a plataforma 
            //-----------------------------------------------------------------------
            SyncFlow( lForceExit )

            //--------------------------------------------------------------
            // Armazena a informação de execução ao controle de sincronismo
            //--------------------------------------------------------------
            GRRSyncTime( 'bankSlip', cSource )
        END TRANSACTION
    EndIf

    RestArea( aSvAlias )
    
    FWFreeArray( aSvAlias )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SyncFlow
Função que controla o envio dos boletos para a  plataforma

@param lForceExit, boolean, Controla a simulaão de erro do envio da mensagem quando executada pelo ADVPR.

@author  Rodrigo Soares 
@since   06/09/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SyncFlow( lForceExit )
    Local aSvAlias          := GetArea()
    Local aFiles            := {} // O array receberá os nomes dos arquivos e do diretório
    Local aPaymentOrders    := {}
    Local cEncode64         := ""
    Local cPath             := "\grr\bankslip\"
    Local cPathPDF          := ""
    Local cFile             := ""
    Local nX                := 1
    Local nY                := 1
    Local nTypeFile         := 0
    Local nFiles            := 0
    Local lNotify           := .f.
    Local lIsSndbox         := GRRIsSndbox()
    Local lSendSlip         := SuperGetMV("MV_GRREBOL", .F., .T.)
    Local lFilesSent        := .F.

    GRRMakeDir( cPath, .T. )
    aPaymentOrders := GetPaymentOrder()

    For nX := 1 to Len( aPaymentOrders )
        //-----------------------------------------------------------------------
        // Adicionando o id da cobrança no caminho da pasta.    
        //-----------------------------------------------------------------------
        cPathPDF := cPath + aPaymentOrders[ nX ][ 1 ]
        
        lFilesSent := .F.
    
        //-----------------------------------------------------------------------
        // Enviando para plataforma que foi criada uma PaymentOrder no Protheus
        // atualizando o vencimento do título.    
        //-----------------------------------------------------------------------
        If CreatedPaymentOrder( aPaymentOrders[ nX ], lSendSlip ) .And. lSendSlip
            If GRRMakeDir( cPathPDF, .F. )
                ADir( cPathPDF + "\*.pdf*", aFiles )
                nFiles := Len( aFiles )

                For nY := 1 to nFiles
                    cFile := aFiles[ nY ]

                    nTypeFile = IIF( "boleto" $ lower( cFile ), 1, IIF( "nota" $ lower( cFile ), 2, 0 ) )

                    cEncode64 := Encode64( , cPathPDF + "\" + cFile, .F., .F. )

                    lNotify   := IIF( nY == nFiles, .T. , .F. )

                    //-----------------------------------------------------------------------
                    // Enviando os arquivos que serão notificados ao cliente.
                    //-----------------------------------------------------------------------
                    If !lForceExit .And. PaymentOrderFileAttached( aPaymentOrders[ nX ][ 1 ], { nTypeFile, cFile, cEncode64, lNotify, lIsSndbox } )
                        FErase( cPathPDF + "\" + cFile )

                        if lNotify .and. DirRemove( cPathPDF )
                            lFilesSent := .T.
                        EndIf
                    else
                        break
                    EndIf
                Next
            EndIf
        EndIf

        If lFilesSent .Or. !lSendSlip
            HRI->( DBGoTo( aPaymentOrders[ nX ][ 3 ] ) )
            RecLock( 'HRI', .F. )
            HRI->HRI_STATUS := GRR_PROVIDER_GENERATED_BANKSLIP //2=Notificado para Plataforma
            MsUnlock()
        EndIf

    Next nX
    
    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aPaymentOrders )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CreatedPaymentOrder
Função que envia a mensagem para plataforma que o Payment Order foi gerado no Protheus.

@param aItem, array, vetor com informações da PaymentOrder para geração do JSON.
@param lSendSlip, logical, informa se enviará o arquivo do boleto

@return lSuccess, lógico, se a mensagem foi enviada com sucesso 
@author  Rodrigo Soares 
@since   24/11/2023
/*/
//-------------------------------------------------------------------------------------
Static Function CreatedPaymentOrder( aItem, lSendSlip )
    Local lSuccess := .F.
    Local jPaymentOrderUpdate

    jPaymentOrderUpdate := SetJsonCreated( aItem, lSendSlip )

    lSuccess := GRRSLSendMsg( EncodeUTF8( FwJsonSerialize( jPaymentOrderUpdate ) ), "PaymentOrderProtheusCreated" )
Return lSuccess

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PaymentOrderFileAttached
Função que envia uma mensagem para atualizar os registros na plataforma

@param cChargeId, string, Guid da cobrança na plataforma do GRR.
@param aFileType, array, vetor com informações da PaymentOrder para geração do JSON.

@return lSuccess, lógico, se a mensagem foi enviada com sucesso 
@author  Rodrigo Soares 
@since   06/09/2022
/*/
//-------------------------------------------------------------------------------------
Static Function PaymentOrderFileAttached( cChargeId, aFileType )
    Local lSuccess := .F.
    Local jPaymentOrderUpdate

    jPaymentOrderUpdate := SetJsonFileAttached( cChargeId, aFileType ) 

    lSuccess := GRRSLSendMsg( EncodeUTF8( FwJsonSerialize( jPaymentOrderUpdate ) ), "PaymentFileProtheusAttached" )
Return lSuccess

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJsonCreated
Função que prepara as informações necessárias para o envio do boleto para a plataforma
GRR.

@param aItem, array, vetor com informações da PaymentOrder para geração do JSON.
@param lSendSlip, logical, informa se enviará o arquivo do boleto

@return json, componente com as propriedades no formato JSON para envio à plataforma.
@author  Rodrigo G Soares
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetJsonCreated( aItem, lSendSlip )
    Local jData := NIL
    Local lNotify := .T.

    If lSendSlip
        lNotify := .F.
    EndIf

    jData := JsonObject():New()
 
    jData[ "ChargeId" ] := aItem[ 1 ]         
    jData[ "DueDate" ] := FWTimeStamp( 5, aItem[ 2 ], TIME() )
    JData[ "IsSandbox"] :=  aItem[ 5 ] 
    jData[ "Notify"] := lNotify
Return jData

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJsonFileAttached
Função que prepara as informações necessárias para o envio do arquivo para a plataforma
GRR.

@param cChargeId, string, Guid da cobrança na plataforma do GRR.
@param aFileType, array, vetor com informações da PaymentOrder para geração do JSON.

@return json, componente com as propriedades no formato JSON para envio à plataforma.
@author  Rodrigo G Soares
@since   23/11/2023
/*/
//-------------------------------------------------------------------------------------
Static Function SetJsonFileAttached( cChargeId, aFileType )
    Local jData := NIL

    jData := JsonObject():New()
 
    jData[ "ChargeId" ] := cChargeId        
    jData[ "FileType" ] := aFileType[ 1 ] 
    jData[ "FileName" ] := aFileType[ 2 ] 
    jData[ "File" ] := aFileType[ 3 ]  
    jData[ "Notify" ] := aFileType[ 4 ] 
    JData[ "IsSandbox"] :=  aFileType[ 5 ] 
Return jData

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPaymentOrder
Função busca quais titulos precisam atualizar na plataforma

@return aPaymentOrders, Array com os itens a ser enviados para plataforma.
    [1] Guid da cobrança na plataforma do GRR
    [2] Vencimento.
    [3] RECNO da tabela HRI.
    [4] bool que indica se é Ambiente Sandbox.

@author  Rodrigo G Soares
@since   23/11/2023
/*/
//-------------------------------------------------------------------------------------
Static Function GetPaymentOrder()
    Local aSvAlias       := GetArea()
    local aPaymentOrders := {}
    Local lIsSndbox      :=  GRRIsSndbox( ) 
    Local cQuery         := ""
    Local cTmp           := ""
    Local oQuery
    
    cQuery := "SELECT HRI_CHARID, E1_VENCTO, HRI.R_E_C_N_O_ RECNO " + ;
        " FROM " + RetSQLName( "HRI" ) + " HRI " + ;
        " INNER JOIN " + RetSQLName( "SE1" ) + " SE1 " + ;
            " ON E1_FILIAL = HRI_SRCFIL " + ;
            " AND ( E1_PREFIXO || E1_NUM || E1_PARCELA || E1_TIPO ) = HRI_REQCD " + ;
            " AND E1_SALDO > 0 " + ;
            " AND E1_BAIXA = '' " + ;
            " AND SE1.D_E_L_E_T_ = ' ' " + ;
        " WHERE HRI_STATUS = ? " + ;     
            " AND HRI.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery( cQuery )
    
    oQuery := FWPreparedStatement():New( cQuery )
    oQuery:SetString( 1, GRR_PROVIDER_CREATED )     // 1=Ordem de Pagamento Criada

    cTmp := MPSysOpenQuery( oQuery:GetFixQuery() )
    
    While ( cTmp )->( !Eof() )
        AADD( aPaymentOrders, { ( cTmp )->HRI_CHARID, STOD( ( cTmp )->E1_VENCTO ), ( cTmp )->RECNO, .T., lIsSndbox } )
        
        ( cTmp )->( dbSkip() )  
    EndDo
    ( cTmp )->( DbCloseArea() )

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FreeObj( oQuery )
return aPaymentOrders

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRGetUrlBankSlip
Busca o local a ser salvo os arquivos de um titulo posicionado para o envio para a plataforma.
Para executar corretamento a tabela SE1 precisa estar previamente posicionada.

@return cPath, string, Retorna a url onde deverá ser salvo os documentos para enviar para a plataforma.
@author Rodrigo Soares
@since 23/11/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRGetUrlBankSlip()
    Local aSvAlias  := GetArea()
    Local aHRIArea  := HRI->( GetArea() )
    local cPath      := '\grr\bankslip\'
    Local nTamFil   := TamSx3( "HRI_SRCFIL" )[ 1 ]
	Local nTamAlias := TamSx3( "HRI_ALIAS" )[ 1 ]
	Local nTamReq   := TamSx3( "HRI_REQCD" )[ 1 ]

    HRI->( dbSetOrder( 1 ) ) //HRI_FILIAL+HRI_SRCFIL+HRI_ALIAS+HRI_REQCD+HRI_SOURCE                                                                                                            
    if HRI->( MSSEEK( xFilial( 'HRI' ) + Padr( SE1->E1_FILIAL , nTamFil ) + Padr( "SE1" , nTamAlias ) ;
             + Padr( SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO , nTamReq ) ) )

        cPath += HRI->HRI_CHARID
    EndIf

    RestArea( aSvAlias )
    RestArea( aHRIArea ) 

    FWFreeArray( aSvAlias )
    FWFreeArray( aHRIArea )
Return cPath


