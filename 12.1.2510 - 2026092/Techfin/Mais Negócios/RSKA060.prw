#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RSKA060.CH"
#INCLUDE "RSKDEFS.CH"

Static aOrgSettings := {}
Static __nLenCodeAn := Nil
Static oBrowse      := Nil

PUBLISH MODEL REST NAME RSKA060

//-------------------------------------------------------------------
/*/{Protheus.doc} RSKA060
Concessão de Credito Risk.
@type   Function
@param  nOpcAuto, number, Indica a ação que será executada pela execauto
@param  uAR5Auto, array, Array com os dados da execauto
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@author Squad NT / TechFin
@since  22/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RSKA060( nOpcAuto, uAR5Auto, lAutomato )
    Local aAuto     := {}
    Local oModel    := Nil 
 
    Private aRotina := MenuDef() 

    Default nOpcAuto    := 0
    Default uAR5Auto    := Nil
    Default lAutomato   := .F.

    Static lADVPR := lAutomato

    If uAR5Auto == Nil
        oBrowse := FWMBrowse():New() 
        oBrowse:SetAlias( "AR5" ) 
        oBrowse:SetDescription( STR0001 )   //'Concessões Mais Negócios'
        oBrowse:SetMenuDef( "RSKA060" )
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_AWAIT    + "'", "BR_BRANCO"   , STR0036 )  // 0=Aguardando Envio
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_ANALYSIS + "'", "BR_AMARELO"  , STR0002 )  // 1=Em análise
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_APPROVED + "'", "BR_VERDE"    , STR0003 )  // 2=Aprovado
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_REJECTED + "'", "BR_VIOLETA"  , STR0004 )  // 3=Rejeitado
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_DENIED   + "'", "BR_VERMELHO" , STR0005 )  // 4=Negado
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_CANCELED + "'", "BR_PRETO"    , STR0006 )  // 5=Cancelado
        oBrowse:AddLegend( "AR5->AR5_STATUS=='" + AR5_STT_PENDING  + "'", "BR_LARANJA"  , STR0007 )  // 6=Pendente
        oBrowse:Activate()

        FreeObj( oBrowse )
    Else
        oModel  := FWLoadModel( "RSKA060" )
        aAuto   := { { "AR5MASTER", uAR5Auto } }
        FWMVCRotAuto( oModel, "AR5", nOpcAuto, aAuto, /*lSeek*/, .T. )
        FreeObj( oModel )
    EndIf

    FWFreeArray( aAuto ) 
    FWFreeArray( uAR5Auto )  
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Concessão de Crédito Mais Negócio.
@type   Static Function
@return objeto, modelo da concessão de crédito
@author Squad NT TechFin
@since  02/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function ModelDef() 
    Local oStructAR5    := FWFormStruct( 1, "AR5" )
    Local oModel        := Nil
    Local bPosValid     := {|oModel| RskPosValid( oModel ) }
    Local bCommit       := {|oModel| RskCmtModel( oModel ) }

    oModel := MPFormModel():New( "RSKA060", /*bPreValid*/, bPosValid, bCommit ) 
    oModel:AddFields( "AR5MASTER", /*cOwner*/, oStructAR5 )
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Interface da Concessão de Crédito Mais Negócio.
@type   Static Function
@return objeto, interface da tela de concessão
@author Squad NT TechFin
@since  02/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel        := FWLoadModel( "RSKA060" )
    Local oStructAR5    := FWFormStruct( 2, "AR5" )
    Local oView         := Nil

    oStructAR5:RemoveField( "AR5_ENTIDA" )    
    oStructAR5:RemoveField( "AR5_FILENT" )
    oStructAR5:RemoveField( "AR5_DTAVAL" )     
    oStructAR5:RemoveField( "AR5_IDRSK" )
    oStructAR5:RemoveField( "AR5_DTSOLI" )
    oStructAR5:RemoveField( "AR5_RCOUNT" )
    oStructAR5:RemoveField( "AR5_STARSK" )

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( "VIEW_AR5", oStructAR5, "AR5MASTER" )
    oView:CreateHorizontalBox( "SCREEN" , 100 )
    oView:SetOwnerView( "VIEW_AR5", "SCREEN" )
    oView:ShowInsertMsg( .F. ) 
    oView:SetUpdateMessage( STR0008, STR0009 ) //"Concessão"##"Concessão de crédito solicitada com sucesso."
Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do Browse
@type   Static Function
@return array, vetor com as opções da rotina
@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0010 ACTION 'Rsk020RBrw'         OPERATION 4 ACCESS 0    //'Atualizar'
    ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.RSKA060'    OPERATION 2 ACCESS 0    //'Visualizar'
Return aRotina 


//------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk060RBrw
Botão de atualização do browse para o usuário.
@type   Function
@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Function Rsk060RBrw()
    If oBrowse := Nil 
        oBrowse:Refresh()
    EndIf 
Return Nil 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPosValid
Bloco de pos validação.
@type  Static Function
@param  oModel, object, modelo da tela de concessão
@return boolean, indica se a validação ocorreu sem falhas ou não.
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskPosValid(oModel As Object) As Logical
    Local lRet      	As Logical
    Local lColPOri  	As Logical 
    Local oMdlAR5   	As Object
    
    Default oModel := FwModelActive()

     If Type('lAutomato') == 'U' // Tratamento para execução via ADVPR.
        lAutomato := .F.
    EndIf

    lRet     := .T.
    lColPOri := AR5->( ColumnPos( "AR5_ORIGIN" ) ) > 0 
    oMdlAR5  := oModel:GetModel( "AR5MASTER" )

    If ( !lColPOri .Or. oMdlAR5:GetValue("AR5_ORIGIN") == PROTHEUS_CONCESSION )     // 2=Protheus
        lRet := RskVldCli( oModel, lAutomato )  

        If lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !Empty(AR5->AR5_FILENT )
            lRet := RskVldPOrg( oModel, lADVPR ) 
        EndIf
    EndIf 
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskVldPOrg
Valida geracao da concessão de credito com base nos parametros do
organization.
@type  Static Function
@param  oModel, object, modelo da tela de concessão
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@return lógico, indica se não houve problemas na validação
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskVldPOrg( oModel As Object, lAutomato As Logical) As Logical
    Local oMdlAR5       As Object
    Local aArea         As Array
    Local aAreaAR5      As Array
    Local aDtSol        As Array 
    Local lRet          As Logical
    Local cCodConR      As Character

    Default lAutomato := .F.

    oMdlAR5   := oModel:GetModel( "AR5MASTER" )
    aArea     := GetArea()
    aAreaAR5  := AR5->( GetArea() )
    aDtSol := {} 
    lRet      := .T.
    cCodConR  := ""

    //------------------------------------------------------------------------------
    // Atualiza os parametros se o CNPJ da SMO for alterado.
    //------------------------------------------------------------------------------
    If Empty( aOrgSettings ) .Or. aOrgSettings[1] != SM0->M0_CGC 
        aOrgSettings := RskGetSSettings( SM0->M0_CGC, lAutomato, CLIENTPOSITION, 'RSKA060', 'AR5', /*aParam*/ )
    EndIf 

    If !Empty( aOrgSettings )
        cCodConR := RskConcRecent( "SA1", oMdlAR5:GetValue( "AR5_FILENT" ), oMdlAR5:GetValue( "AR5_CODENT" ), oMdlAR5:GetValue( "AR5_LOJENT" ) )

        AR5->( DBSetOrder(1) )    //AR5_FILIAL+AR5_CODCON
        If !Empty( cCodConR ) .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
            If AR5->( DBSeek( xFilial("AR5") + cCodConR ) )
                aDtSol := StrToArray( RskFmtTStamp( AR5->AR5_DTSOLI ), " " )  
                If AR5->AR5_STATUS $ "'" + AR5_STT_ANALYSIS + "|" + AR5_STT_PENDING + "'"       // 1=Em análise ### 6=Pendente
                	lRet := .F.
                   	Help( "", 1, "RSKA060",, STR0012, 1, 0,,,,,, { STR0013 } )     //"Já existe uma concessão em andamento."###"Por favor, aguarde o parceiro atualizar o status da concessão."
                EndIf
            EndIf
        EndIf
    Else
        lRet := .F.
        Help( "", 1, "RSKA060",, STR0017, 1, 0,,,,,, { STR0018 } )      //"Não foi possível consultar as configurações para concessão de crédito na plataforma."###"Por favor verifique se há um emitente vinculado a essa Empresa/Filial  ou realize uma nova tentativa mais tarde!"
    EndIf

    RestArea( aArea )
    RestArea( aAreaAR5 )

    FWFreeArray( aArea )
    FWFreeArray( aAreaAR5 )
    FWFreeArray( aDtSol )
Return lRet 


//------------------------------------------------------------------------------
/*/{Protheus.doc} RskConcRecent
Retorna a concessao de credito mais recente.
@type   Static Function
@param  cEntity, caracter, entidade da concessão
@param  cFilEnt, caracter, filial
@param  cCodEnt, caracter, código do cliente
@param  cLojEnt, caracter, loja do cliente
@param  cStatus, caracter, status da concessão

@return caracter, código da concessão relacionado aos dados de pesquisa
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskConcRecent( cEntity, cFilEnt, cCodEnt, cLojEnt, cStatus )
    Local aArea     := GetArea()
    Local cCodCon   := ""   
    Local cQuery    := ""
    Local cTempAR5  := GetNextAlias() 
    Local cTypeDB	:= TCGetDB()

    Default cEntity := ""
    Default cFilEnt := "" 
    Default cCodEnt := ""
    Default cLojEnt := ""
    Default cStatus := ""
    
    cQuery  := " SELECT "
    
    If cTypeDB = "MSSQL"
        cQuery += " TOP 1 "
    EndIf

    cQuery  += " AR5_CODCON "  
    cQuery  += " FROM " + RetSqlName( "AR5" )
    cQuery  += " WHERE AR5_FILIAL = '" + xFilial( "AR5" ) + "' " 
    cQuery  += " AND AR5_ENTIDA = '" + cEntity + "' "  
    cQuery  += " AND AR5_FILENT = '" + cFilEnt + "' "  
    cQuery  += " AND AR5_CODENT = '" + cCodEnt + "' "  
    cQuery  += " AND AR5_LOJENT = '" + cLojEnt + "' "  
    If !Empty( cStatus )
        cQuery  += " AND AR5_STATUS = '" + cStatus + "' "
    EndIf
    cQuery  += " AND D_E_L_E_T_ = ' ' "   
    
    If cTypeDB = "ORACLE"
        cQuery += " AND ROWNUM = 1 "
    EndIf

    cQuery  += " ORDER BY AR5_CODCON DESC "  
    
    If cTypeDB $ "MYSQL|POSTGRES"
        cQuery += " LIMIT 1 " 
    EndIf 

    cQuery  := ChangeQuery( cQuery ) 
    DbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), cTempAR5, .F., .T. )

    If ( cTempAR5 )->( !Eof() ) 
        cCodCon := ( cTempAR5 )->AR5_CODCON
    EndIf
    ( cTempAR5 )->( DBCloseArea() )

    RestArea( aArea )

    FWFreeArray( aArea )
Return cCodCon


//------------------------------------------------------------------------------
/*/{Protheus.doc} RskCmtModel
Função que faz gravação do modelo de dados 
@type  Static Function
@param  oModel, objeto, modelo de dados
@return lRet, logico, Gravação realizada com sucesso.
@author Squad NT TechFin
@since  03/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskCmtModel( oModel )
    Local lRet      := .T.
    Local oMdlAR5   := oModel:GetModel( "AR5MASTER" )
    Local lColPOri  := AR5->( ColumnPos( "AR5_ORIGIN" ) ) > 0 

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        oMdlAR5:LoadValue( "AR5_ENTIDA", Upper( oMdlAR5:GetValue("AR5_ENTIDA") ) )
        oMdlAR5:LoadValue( "AR5_DTSOLI", FWTimeStamp( 1, Date(), Time() ) )
        If ( !lColPOri .Or. oMdlAR5:GetValue("AR5_ORIGIN") == PROTHEUS_CONCESSION )     // 2=Protheus
            oMdlAR5:LoadValue( "AR5_STATUS", AR5_STT_AWAIT )    // 0=Aguardando Envio
            oMdlAR5:LoadValue( "AR5_STARSK", STARSK_SUBMIT )    // 1=Enviar
        EndIf
    EndIf 
    lRet := FWFormCommit( oModel )
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskVldCli
Função que valida o cadastro de cliente para fazer uma concessão de crédito
Mais Negócios.
@type   Static Function
@param  oModel, objeto, modelo de dados
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@return lRet, logico, Retorna se o cliente está apto para realizar uma
concessão de credito Mais Negócio.
@author Squad NT TechFin
@since  03/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskVldCli( oModel As Object, lAutomato As Logical ) As Logical
    Local aArea    As Array
    Local aAreaSA1 As Array
    Local aAreaAR3 As Array
    Local oMdlAR5  As Object
    Local lRet     As Logical

    Default lAutomato := .F.

    aArea    := GetArea()
    aAreaSA1 := SA1->( GetArea() )
    aAreaAR3 := AR3->( GetArea() )
    oMdlAR5  := oModel:GetModel( "AR5MASTER" )
    lRet     := .T.

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        SA1->( DBSetOrder(1) )    //A1_FILIAL+A1_COD+A1_LOJA
        AR3->( DBSetOrder(1) )    //AR3_FILIAL+AR3_CODCLI+AR3_LOJCLI
        
        If Upper( oMdlAR5:GetValue( "AR5_ENTIDA" ) ) == "SA1"
            If SA1->( MSSeek( oMdlAR5:GetValue( "AR5_FILENT" ) + oMdlAR5:GetValue( "AR5_CODENT" ) + oMdlAR5:GetValue( "AR5_LOJENT" ) ) )           
                If lRet 
                    //------------------------------------------------------------------------------
                    // Validacao no cadastro do cliente
                    //------------------------------------------------------------------------------
                    If Empty( SA1->A1_CEP ) .Or. Empty( SA1->A1_BAIRRO )
                        lRet := .F.
                        Help( "", 1, "RSKA060",, STR0021, 1, 0,,,,,, { STR0022 } )      //"O campo CEP ou bairro do cliente não foi preenchido."###"Preencha o campo para realizar uma concessão de crédito."
                    ElseIf Empty( SA1->A1_CGC )
                        lRet := .F.
                        Help( "", 1, "RSKA060",, STR0023, 1, 0,,,,,, { STR0022 } )      //"O campo CNPJ/CPF do cliente não foi preenchido."###"Preencha o campo para realizar uma concessão de crédito."
                    ElseIf SA1->A1_MSBLQL == '1'
                        lRet := .F.
                        Help( "", 1, "RSKA060",, STR0037, 1, 0,,,,,, { STR0038 } )      //"O cliente está inativo."###"."Não é possivel pedir uma concessão para um cliente bloqueado."
                    EndIf   
                EndIf

                If lRet .and. !FwIsInCallStack( "RskCliPosition" )
                    //------------------------------------------------------------------------------
                    // Atualiza\verifica a posição do cliente.
                    //------------------------------------------------------------------------------
                    RskGetCliPosition( SA1->A1_CGC, NIL, NIL, lAutomato, CONCESSION, 'RSKA060', 'AR5', /*aParam*/ )

                    If AR3->( MSSeek( xFilial( "AR3" ) + SA1->A1_COD + SA1->A1_LOJA ) ) .And. AR3->AR3_CREDIT == CREDIT_YES     // 1=Sim
                        If oMdlAR5:GetValue( "AR5_LIMDEJ" ) < 0 .Or. oMdlAR5:GetValue( "AR5_LIMDEJ" ) == AR3->AR3_LIMITE
                            lRet := .F.
                            Help( "", 1, "RskVldCli",, STR0019, 1, 0,,,,,, { STR0020 } )    //"Limite desejado inválido."###"Verifique se o limite desejado está negativo ou igual ao limite atual"
                        EndIf
                    EndIf
                EndIf
            Else
                lRet := .F.
                Help( "", 1, "RSKA060",, STR0028, 1, 0,,,,,, { STR0029 } )     //"Dados do cliente não localizado."###"Verifique o cadastro de clientes."
            EndIf
        Else
            lRet := .F.
            Help( "", 1, "RSKA060",, STR0030, 1, 0,,,,,, { STR0031 } )    //"Entidade inválida para concessão."###"Informe SA1 no campo Entidade."
        EndIf  
    EndIf    

    RestArea( aAreaSA1 )
    RestArea( aAreaAR3 )
    RestArea( aArea )

    FWFreeArray( aAreaSA1 )
    FWFreeArray( aAreaAR3 )
    FWFreeArray( aArea )
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPostConcession
Funcao que envia as concessões de credito diretamente para plataforma risk.
@type Function
@param cEndPoint, caracter, endpoint utilizado na integração.
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário
@author Squad NT TechFin
@since  02/09/2020
/*/
//-----------------------------------------------------------------------------
Function RskPostConcession( cEndPoint As Character, lAutomato As Logical, aParam As Array )
    Local aArea         As Array
    Local aJItems       As Array
    Local aErpIds       As Array
    Local aErrorMd      As Array
    Local cHost         As Character
    Local cErpId        As Character
    Local cBody         As Character
    Local cDescription  As Character
    Local cTmpCons      As Character
    Local nCount        As Numeric
    Local nRecProc      As Numeric
    Local nLimit        As Numeric
    Local nRetryCount   As Numeric
    Local nX            As Numeric
    Local nPosErpId     As Numeric
    Local oJResult      As Object
    Local oJItem        As Object
    Local oRest         As Object
    Local oModel        As Object
    Local oMdlAR5       As Object
    Local lLockByFil	As Logical
    Local lNotReanalise As Logical
    Local cCpoLongTerm  As Character
    Local oQueryAR5     As Object
    Local cFinalQuery   As Character

    Default lAutomato := .F.
    Default aParam    := {}

    aArea         := GetArea() 
    aJItems       := {}
    aErpIds       := {}  
    aErrorMd      := {}
    cHost         := GetRSKPlatform( .F. )
    cErpId        := "" 
    cBody         := "" 
    cDescription  := ""
    cTmpCons      := ""
    nCount        := 0
    nRecProc      := 0
    nLimit        := 10
    nRetryCount   := 99 
    nX            := 0
    nPosErpId     := 0 
    oJResult      := Nil    
    oJItem        := Nil
    oRest         := Nil
    oModel        := Nil
    oMdlAR5       := Nil
    lLockByFil	  := !Empty(xFilial("AR5"))
    lNotReanalise := .F.  
    cCpoLongTerm  := ""
    If AR5->( ColumnPos( "AR5_LONGTE" ) ) > 0
        cCpoLongTerm  := ", AR5.AR5_LONGTE"
    EndIf
    oQueryAR5     := Nil
    cFinalQuery   := ""

    If LockByName("RskPostConcession", .T., lLockByFil )

        If lAutomato .Or. ( !Empty( cHost ) .Or. !Empty( cEndPoint ) )
            cQuery := " SELECT AR5.AR5_FILIAL, AR5.AR5_CODCON, AR5.AR5_FILENT, AR5.AR5_CODENT, AR5.AR5_LOJENT, " + ;
                        " AR5.AR5_LIMDEJ , AR5.AR5_LIMAPR, AR5.AR5_DTSOLI, AR5.AR5_DTAVAL, AR5.AR5_STATUS, " + ;
                        " AR5.AR5_RCOUNT, SA1.A1_LC, AR5.R_E_C_N_O_ RECNO ? " + ;
                    " FROM ? AR5 " + ;
                    " INNER JOIN ? SA1 " + ;
                        " ON SA1.A1_FILIAL = AR5.AR5_FILENT " + ;
                        " AND SA1.A1_COD = AR5.AR5_CODENT " + ;
                        " AND SA1.A1_LOJA = AR5.AR5_LOJENT " + ;
                        " AND SA1.D_E_L_E_T_ = ' ' " + ;
                    " WHERE AR5.AR5_FILIAL = ? " + ;
                        " AND AR5.AR5_STARSK = ? " + ;
                        " AND AR5.AR5_ENTIDA = ? " + ;    
                        " AND AR5.D_E_L_E_T_ = ' ' " + ;
                    " ORDER BY ? "
            
            oQueryAR5 := FWPreparedStatement():New()
            oQueryAR5:SetQuery(cQuery)
            oQueryAR5:SetUnsafe(1, cCpoLongTerm)
            oQueryAR5:SetUnsafe(2, RetSqlName( "AR5" ))
            oQueryAR5:SetUnsafe(3, RetSqlName( "SA1" ))
            oQueryAR5:SetString(4, xFilial( "AR5" ))
            oQueryAR5:SetString(5, STARSK_SUBMIT) // 1=Enviar
            oQueryAR5:SetString(6, 'SA1')
            oQueryAR5:SetUnsafe(7, SqlOrder( AR5->( IndexKey( 1 ) ) )) //AR5_FILIAL+AR5_CODCON
            cFinalQuery := oQueryAR5:GetFixQuery()
            cTmpCons    := mpsysopenquery( cFinalQuery )
            DbSelectArea( cTmpCons )
            If ( cTmpCons )->( !Eof() )
                //-----------------------------------------------------------------------------------
                // Identifica a quantidade de registro no alias temporário para processamento.
                //-----------------------------------------------------------------------------------
                COUNT TO nRecProc

                //-------------------------------------------------------------------
                // Posiciona no primeiro registro.
                //-------------------------------------------------------------------
                ( cTmpCons )->( DBGoTop() )    

                //------------------------------------------------------------------
                // Ajusta o pagesize, caso o numero de registros de envio for menor.
                //------------------------------------------------------------------
                If nLimit > nRecProc
                    nLimit := nRecProc
                EndIf 

                oModel  := FWLoadModel( "RSKA060" )

                While ( cTmpCons )->( !Eof() ) 
                    cErpId  := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTmpCons )->AR5_FILIAL ) + "|" + AllTrim( ( cTmpCons )->AR5_CODCON )
                    nCount  += 1
                        
                    aAdd( aErpIds, { cErpId, ( cTmpCons )->RECNO } )
                    
                    oJItem                      := JsonObject():New()
                    oJItem["erpId"]             := cErpId
                    oJItem["customerErpId"]     := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTmpCons )->AR5_FILENT ) + "|" + AllTrim( ( cTmpCons )->AR5_CODENT ) + "|" + AllTrim( ( cTmpCons )->AR5_LOJENT )    
                    oJItem["currentLimit"]      := ( cTmpCons )->A1_LC
                    oJItem["desiredLimit"]      := ( cTmpCons )->AR5_LIMDEJ 
                    oJItem["requestDate"]       := RskDTimeUTC( ( cTmpCons )->AR5_DTSOLI )
                    oJItem["status"]            := AR5_STT_ANALYSIS  // 1=Em Análise
                    oJItem["retryCount"]        := ( cTmpCons )->AR5_RCOUNT
                    oJItem["deleted"]           := 'false'
                    If !Empty( cCpoLongTerm )
                        oJItem["LongTermAnalysis"]  := IIF( ( cTmpCons )->AR5_LONGTER == "1", "true", "false" )
                    EndIf
                    aAdd( aJItems, oJItem )    

                    If nCount == nLimit
                        cBody := RSKRestExec( RSKPOST, cEndPoint, @oRest, aJItems, RISK, SERVICE, .F., .F., CONCESSION, 'AR5', 'RSKA060', aParam )   // POST ### 1=Risk ### 2=URL de autenticação de serviços

                        If !Empty( cBody ) 
                            oJResult    := JSONObject():New()
                            oJResult:FromJSON( cBody )
                            
                            For nX := 1 To Len( oJResult )
                                oJItem      	:= oJResult[nX]
                                nPosErpId   	:= aScan( aErpIds, {|x| x[1] == oJItem["erpId"] } )
                                lNotReanalise   := .F.

                                If nPosErpId > 0
                                    AR5->( DBGoTo( aErpIds[nX][2] ) )
                                    BEGIN TRANSACTION
                                        oModel:SetOperation( MODEL_OPERATION_UPDATE )
                                        oModel:Activate()   

                                        If oModel:IsActive()  
                                            oMdlAR5 := oModel:GetModel( "AR5MASTER" )  
                                            
                                            oMdlAR5:SetValue( "AR5_RCOUNT", oJItem["retryCount"] )
                                            
                                            If oJItem["statusProcess"] == 1
                                                oMdlAR5:SetValue( "AR5_STATUS", AR5_STT_ANALYSIS )  // 1=Em Análise
                                                oMdlAR5:SetValue( "AR5_STARSK", STARSK_SENT )       // 2=Enviado
                                                cDescription := " " 
                                            Else
                                                cDescription  := DecodeUTF8( oJItem["description"] ) + Chr(10)
                                                
                                                //------------------------------------------------------------------------------
                                                // Não traduzir o texto do AT, pois ele vem da plataforma
                                                //------------------------------------------------------------------------------
                                                lNotReanalise := AT( "A permissão para reanálise estará", cDescription ) > 0
                                                If oJItem["retryCount"] >= nRetryCount .Or. lNotReanalise
                                                    oMdlAR5:SetValue( "AR5_STARSK", STARSK_CANCELED )   // 5=Cancelado
                                                    oMdlAR5:SetValue( "AR5_STATUS", AR5_STT_REJECTED )  // 3=Rejeitado
                                                    oMdlAR5:SetValue( "AR5_DTAVAL", FWTimeStamp( 1, Date(), Time() ) ) // Data da avaliação da concessão de credito pela plataforma 

                                                    If !lNotReanalise 
                                                        cDescription += STR0032 + Chr(10) + STR0033     //"Concessão de crédito não enviada para Supplier."###"Verifique os cadastros e tente uma nova concessão de crédito."
                                                    EndIf
                                                Else
                                                    cDescription += STR0032 + Chr(10) + STR0034    //"Concessão de crédito não enviada para Supplier."###"Será realizado uma nova tentativa dentro de instantes."
                                                EndIf
                                            EndIf

                                            oMdlAR5:SetValue( "AR5_OBSRSK", cDescription )      

                                            If oModel:VldData()
                                                oModel:CommitData()   
                                            Else
                                                aErrorMd := oModel:GetErrorMessage()
                                                LogMsg( "RskPostCredit", 23, 6, 1, "", "", "RskPostCredit -> " + aErrorMd[6] )      
                                            EndIf
                                        EndIf

                                        oModel:DeActivate()
                                    END TRANSACTION
                                EndIf
                            Next nX 
                        Else 
                            If !lAutomato
                                LogMsg( "RskPostConcession", 23, 6, 1, "", "", "RskPostConcession -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )    
                            EndIf
                        EndIf 

                        aJItems     := {}
                        aErpIds     := {}  
                        nCount      := 0 
                        nRecProc    -= nLimit

                        //------------------------------------------------------------------
                        // Ajusta o pagesize para enviar os registros restantes.
                        //------------------------------------------------------------------
                        If nLimit > nRecProc
                            nLimit := nRecProc
                        EndIf 
                    EndIf
                    ( cTmpCons )->( DBSkip() )
                End
            EndIf

            ( cTmpCons )->( DBCloseArea() )
        Else
            LogMsg( "RskPostConcession", 23, 6, 1, "", "", "RskPostConcession -> " + STR0035 )  //"Host da plataforma RISK não informado."
        EndIf

        If oModel != Nil
            oModel:Destroy()
        EndIf
         
        UnLockByName( "RskPostConcession", .T., lLockByFil ) 
    Else
        LogMsg( "RskPostConcession", 23, 6, 1, "", "", "RskPostConcession -> " + STR0039 )  //"Existe um processamento de envio Concessão Mais Negócios em outra instancia..." 
    EndIf

    RestArea( aArea ) 

    FWFreeArray( aArea ) 
    FWFreeArray( aJItems ) 
    FreeObj( oJResult )     
    FreeObj( oJItem )
    FreeObj( oRest )        
    FreeObj( oModel )        
    FreeObj( oMdlAR5 )
    FreeObj( oQueryAR5 )
Return Nil 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskUpdConcession
Atualização a concessão de credito realizada na plataforma para o Protheus.
@type       Function
@param 		aRecords: 	Array de concessões com a seguinte estrutura
						[1] = Filial da Concessão
                        [2] = Id da Concessão
                        [3] = Id da Concessão Risk
                        [4] = Filial do cliente
                        [5] = Codigo do cliente
                        [6] = Loja do cliente
                        [7] = Limite Desejado  
                        [8] = Limite Aprovado
                        [9] = Data da Requisição
                        [10] = Data da Avaliação
                        [11] = Status
                        [12] = Observações
                        [13] = Origem (1=Plataforma ou 2=Protheus)
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Function RskUpdConcession( aRecords as Array, lAutomato as Logical, cHost as Character, nType as Numeric)  
    Local aSvAlias     As Array
    Local aAreaSA1     As Array
    Local aAreaAR5     As Array
    Local aErrorMd     As Array
    Local oModel       As Object
    Local oMdlAR5      As Object
    Local cStatus      As Character   
    Local cObs         As Character      
    Local nTamLimApr   As Numeric 
    Local nTamLimDes   As Numeric
    Local nValLimApr   As Numeric 
    Local nValLimDes   As Numeric
    Local nX           As Numeric
    Local nRecords     As Numeric
    Local nLenCustID   As Numeric
    Local nLenCustUnit As Numeric

    Default aRecords  := {}
    Default lAutomato := .F.

    aSvAlias     := GetArea()
    aAreaSA1     := SA1->( GetArea() )
    aAreaAR5     := AR5->( GetArea() )
    aErrorMd     := {}
    oModel       := FWLoadModel( "RSKA060" )  
    oMdlAR5      := Nil
    nX           := 0      
    nRecords     := 0   
    nLenCustID   := TamSX3("A1_COD")[1]   
    nLenCustUnit := TamSX3("A1_LOJA")[1]
    nValLimApr   := 0
    nValLimDes   := 0

    AR5->( DBSetOrder(1) )      //AR5_FILIAL+AR5_CODCON
    SA1->( DBSetOrder(1) )      //A1_FILIAL+A1_COD+A1_LOJA
    
    If __nLenCodeAn == Nil
        __nLenCodeAn := IF( AR5->( ColumnPos( "AR5_CODEAN" ) ) > 0 , TamSX3("AR5_CODEAN")[1] , 0 )
    EndIf

    nRecords := Len( aRecords )    

    For nX := 1 To nRecords             
        cBranchSA1  := Padr( aRecords[ nX ][ CONCESSION_CUSTBRANCH ], FwSizeFilial() )      // [4]-Filial do cliente
        cCustID     := Padr( aRecords[ nX ][ CONCESSION_CUSTID ]    , nLenCustID )          // [5]-Codigo do cliente
        cCustUnit   := Padr( aRecords[ nX ][ CONCESSION_CUSTUNIT ]  , nLenCustUnit )        // [6]-Loja do cliente

        If SA1->( DBSeek( cBranchSA1 + cCustID + cCustUnit ) ) 
            If AR5->( DBSeek( aRecords[ nX ][ CONCESSION_BRANCH ] + aRecords[ nX ][ CONCESSION_ID ] ) )     // [1]-Filial da concessão ### [2]-ID da concessão
                oModel:SetOperation( MODEL_OPERATION_UPDATE )
            Else
                oModel:SetOperation( MODEL_OPERATION_INSERT )
            EndIf
                
            oModel:Activate()  

            If oModel:IsActive() 
                oMdlAR5 := oModel:GetModel( "AR5MASTER" )  
                
                nValLimDes := Val( aRecords[ nX ][ CONCESSION_DESIREDLIMIT ] )      // [7]-Limite Desejado
                nValLimApr := Val( aRecords[ nX ][ CONCESSION_APPROVEDCREDLIMIT ] ) // [8]-Limite Aprovado
                nTamLimDes := Len( AllTrim( Str( nValLimDes,, TamSx3("AR5_LIMDEJ")[2] ) ) )      // [7]-Limite Desejado
                nTamLimApr := Len( AllTrim( Str( nValLimApr,, TamSx3("AR5_LIMAPR")[2] ) ) ) // [8]-Limite Aprovado
                cStatus    := aRecords[ nX ][ CONCESSION_STATUS ]   // [11]-Status
                cObs       := ""

                If nTamLimDes > TamSx3("AR5_LIMDEJ")[1]
                    nValLimDes := 0.01
                    cStatus    := AR5_STT_CANCELED  // 5 - Cancelado
                    cObs       += CRLF + STR0043 + aRecords[ nX ][ CONCESSION_DESIREDLIMIT ] + ' (' + AllTrim( GetSX3Cache( 'AR5_LIMDEJ', 'X3_TITULO' ) ) + ' )'  // Valor solicitado:
                EndIf
                If nTamLimApr > TamSx3("AR5_LIMAPR")[1] 
                    nValLimApr := 0
                    cStatus    := AR5_STT_CANCELED  // 5 - Cancelado
                    cObs       += CRLF + STR0043 + aRecords[ nX ][ CONCESSION_APPROVEDCREDLIMIT ] + ' (' + AllTrim( GetSX3Cache( 'AR5_LIMAPR', 'X3_TITULO' ) ) + ' )'  // Valor solicitado:
                EndIf

                If oModel:GetOperation() == MODEL_OPERATION_INSERT
                    oMdlAR5:SetValue( "AR5_ENTIDA", "SA1" )
                    oMdlAR5:SetValue( "AR5_FILENT", SA1->A1_FILIAL )
                    oMdlAR5:SetValue( "AR5_CODENT", SA1->A1_COD )
                    oMdlAR5:SetValue( "AR5_LOJENT", SA1->A1_LOJA )
                    oMdlAR5:SetValue( "AR5_LIMDEJ", nValLimDes )                  
                    oMdlAR5:SetValue( "AR5_ORIGIN", aRecords[ nX ][ CONCESSION_ORIGIN ] )                              // [13]-Origem (1=Plataforma ou 2=Protheus)
                    oMdlAR5:SetValue( "AR5_DTSOLI", RskDTToLocal( aRecords[ nX ][ CONCESSION_REQUESTDATE ], .F. ) )    // [9]-Data da Requisição
                EndIf

                If aRecords[ nX ][ CONCESSION_STATUS ] == AR5_STT_APPROVED // [11]-Status ### 2=Aprovado
                    oMdlAR5:SetValue( "AR5_LIMAPR", nValLimApr )     // Limite Aprovado
                EndIf
                
                oMdlAR5:SetValue( "AR5_DTAVAL", RskDTToLocal( aRecords[ nX ][ CONCESSION_EVALUATIONDATE ], .F. ) )   // [10]-Data da Avaliação
                oMdlAR5:SetValue( "AR5_STATUS",  cStatus )  // Status

                If !Empty( aRecords[ nX ][ CONCESSION_OBSREASON ] )     // [12]-Observações  
                    oMdlAR5:SetValue( "AR5_OBSRSK", aRecords[ nX ][ CONCESSION_OBSREASON ] + cObs )
                EndIf

                If __nLenCodeAn > 0
                    oMdlAR5:SetValue( "AR5_CODEAN", Left( aRecords[ nX ][ CONCESSION_CODEANALYZE ] , __nLenCodeAn ) )    // [14]-Código de análise da concessão
                EndIf
                oMdlAR5:SetValue( "AR5_STARSK", STARSK_RECEIVED )       // 3=Recebido 
                oMdlAR5:SetValue( "AR5_IDRSK", aRecords[ nX ][ CONCESSION_RSKID ] )     // [3]-Id da Concessão Risk
                
                If oModel:VldData() 
                    oModel:CommitData()   
                    If oModel:GetOperation() == MODEL_OPERATION_INSERT
                        aRecords[ nX ][ CONCESSION_BRANCH ] := xFilial( "AR5" )                     // [1]-Filial da concessão  
                        aRecords[ nX ][ CONCESSION_ID ]     := oMdlAR5:GetValue( "AR5_CODCON" )     // [2]-ID da concessão
                    EndIf
                    RSKConfPlat(cHost, nType, {aRecords[ nX ]}, lAutomato)
                Else  
                    aErrorMd := oModel:GetErrorMessage()  
                    LogMsg( "RskUpdConcession", 23, 6, 1, "", "", "RskUpdConcession -> " + aErrorMd[6] )      
                EndIf     
            EndIf
 
            oModel:DeActivate() 
        EndIf
    Next nX 

    If oModel != Nil 
        oModel:Destroy() 
    EndIf 

    RestArea( aSvAlias )
    RestArea( aAreaSA1 )
    RestArea( aAreaAR5 )

    FWFreeArray( aSvAlias )
    FWFreeArray( aAreaSA1 )
    FWFreeArray( aAreaAR5 )
    FWFreeArray( aErrorMd )
    FreeObj( oModel )  
    FreeObj( oMdlAR5 )  
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk060NEnt
Retorna o nome da entidade para a montagem da tela
@type   Function
@param  nType, number, Identifica onde a função está sendo chamada, onde:
    1=X3_RELACAO
    2=X3_INIBRW

@return caracter, Nome do cliente
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Function Rsk060NEnt( nType )
    Local cName     := ""
    Local oModel    := FwModelActive()
    Local oMdlAR5   := Nil

    Default nType := 1

    If nType == 1
        If oModel:GetOperation() != MODEL_OPERATION_INSERT
            oMdlAR5 := oModel:GetModel( "AR5MASTER" )
            cName := AllTrim( Posicione( oMdlAR5:GetValue( "AR5_ENTIDA" ), 1, oMdlAR5:GetValue( "AR5_FILENT" ) + ;
                    oMdlAR5:GetValue( "AR5_CODENT" ) + oMdlAR5:GetValue( "AR5_LOJENT" ), "A1_NOME" ) )
        EndIf
    Else
        cName := AllTrim( Posicione( AR5->AR5_ENTIDA, 1, AR5->AR5_FILENT + AR5->AR5_CODENT + AR5->AR5_LOJENT, "A1_NOME" ) )
    EndIf
Return cName

 
//------------------------------------------------------------------------------
/*/{Protheus.doc} MyRSKA020
Exemplo de rotina automatica para concessão de crédito.
@type   Function
@param  Nenhum
@return Nenhum
@author Squad NT TechFin
@since  06/10/2020
/*/
//-----------------------------------------------------------------------------
/*
User Function MyRSKA060()

    Local aArea     := {} 
    Local aAreaSA1  := {}
    Local aAR5Auto  := {}
    Local lRet      := .T. 
    Local cCodCli   := ""  
    Local cLojCli   := ""
    Local nLimDej   := 0                                                                                                
 
    Private lMsErroAuto := .F.

    //RpcSetEnv("MyCompany","MyBranch")  

    RpcSetEnv("T1","M SP 01 ") 

    cCodCli     := "028928"
    cLojCli     := "01"
    nLimDej     := 70000
    aArea       := GetArea()
    aAreaSA1    := SA1->(GetArea())
    
    DBSelectArea("SA1")
    DBSetOrder(1)
 
    If DBSeek(xFilial("SA1") + cCodCli + cLojCli )     

        aAdd(aAR5Auto,{"AR5_ENTIDA" ,"SA1"          ,Nil})  //Entidade
        aAdd(aAR5Auto,{"AR5_FILENT"	,SA1->A1_FILIAL ,Nil})  //Filial da Entidade
        aAdd(aAR5Auto,{"AR5_CODENT"	,SA1->A1_COD    ,Nil})  //Codigo da Entidade
        aAdd(aAR5Auto,{"AR5_LOJENT"	,SA1->A1_LOJA   ,Nil})  //Loja da Entidade
        aAdd(aAR5Auto,{"AR5_LIMDEJ"	,600          ,Nil})  //Limite desejado.
    
        //Inclusão da concessão de credito.
        MSExecAuto({|x,y| RSKA060(x,y)},3,aAR5Auto) 
        
        If lMsErroAuto 
            MostraErro() 
            lRet := .F. 
        EndIf
       
    EndIf

    RpcClearEnv()

    RestArea(aAreaSA1)    
    RestArea(aArea)
    FWFreeArray(aAreaSA1)
    FWFreeArray(aArea)

Return Nil*/ 

