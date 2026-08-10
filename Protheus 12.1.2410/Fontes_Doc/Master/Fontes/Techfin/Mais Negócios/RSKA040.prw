#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RSKDEFS.CH"
#INCLUDE "RSKA040.CH" 

#DEFINE SYNCED          '1' // 1=Sincronizado
#DEFINE UNSYNCED        '2' // 2=Não Sincronizado

PUBLISH MODEL REST NAME RSKA040

//------------------------------------------------------------------------------
/*/{Protheus.doc} RSKA040
Posição cliente Mais Negócios.

@author Squad NT TechFin   
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Function RSKA040()
Return Nil  

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados cliente Mais Negócios.
@type   Static Function
@return objeto, modelo da posição do cliente mais negócios 
@author Squad NT TechFin
@since  15/10/2020 
/*/
//-----------------------------------------------------------------------------
Static Function ModelDef() 
    Local oStructAR3    := FWFormStruct( 1, "AR3" )
    Local oStructAR5    := FWFormStruct( 1, "AR5" )
    Local oModel        := Nil
    Local bPosValid     := {|oModel| RskPosValid( oModel ) }
    
    oStructAR5:RemoveField( "AR5_CODCON" )
    oStructAR5:RemoveField( "AR5_NOMENT" )
    oStructAR5:SetProperty( "AR5_DTSVIR", MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "RskFmtTStamp(AR5->AR5_DTSOLI)" ) )
    oStructAR5:SetProperty( "AR5_DTAVIR", MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "RskFmtTStamp(AR5->AR5_DTAVAL)" ) )

    oStructAR5:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )

    oModel := MPFormModel():New( "RSKA040", /*bPreValid*/, bPosValid )
    oModel:AddFields( "AR3MASTER", /*cOwner*/, oStructAR3 )
    oModel:AddGrid( "AR5DETAIL", "AR3MASTER", oStructAR5 )

    oModel:GetModel( "AR5DETAIL" ):SetNoInsertLine( .T. )
    oModel:GetModel( "AR5DETAIL" ):SetNoUpdateLine( .T. )
    oModel:GetModel( "AR5DETAIL" ):SetNoDeleteLine( .T. )

    oModel:GetModel( "AR5DETAIL" ):SetOptional( .T. )
    oModel:GetModel( "AR5DETAIL" ):SetOnlyQuery( .T. )

    oModel:SetRelation( "AR5DETAIL", { {"AR5_FILIAL", "xFilial('AR5')" },;
                                    { "AR5_ENTIDA", "'SA1'" }, { "AR5_FILENT", "xFilial('SA1')" },;
                                    { "AR5_CODENT", "AR3_CODCLI" }, { "AR5_LOJENT", "AR3_LOJCLI" } }, AR5->( IndexKey(1) ) )   //AR5_FILIAL+AR5_CODCON
	
Return oModel
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface cliente Mais Negócios.
@type   Static Function
@return objeto, view da posição do cliente mais negócios
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel        := FWLoadModel( "RSKA040" )
    Local oStructAR3    := FWFormStruct( 2, "AR3" )
    Local oStructAR5    := FWFormStruct( 2, "AR5" )
    Local oView         := Nil

    oStructAR3:RemoveField( "AR3_DTATUA" ) 

    oStructAR5:RemoveField( "AR5_CODCON" )
    oStructAR5:RemoveField( "AR5_NOMENT" )
    oStructAR5:RemoveField( "AR5_ENTIDA" ) 
    oStructAR5:RemoveField( "AR5_FILENT" )
    oStructAR5:RemoveField( "AR5_CODENT" ) 
    oStructAR5:RemoveField( "AR5_LOJENT" )
    oStructAR5:RemoveField( "AR5_DTAVAL" )
    oStructAR5:RemoveField( "AR5_DTSOLI" )
    oStructAR5:RemoveField( "AR5_IDRSK" )
    oStructAR5:RemoveField( "AR5_RCOUNT" )
    oStructAR5:RemoveField( "AR5_STARSK" )

    oStructAR5:SetProperty( "*", MVC_VIEW_CANCHANGE, .F. )
    oStructAR5:SetProperty( "AR5_OBSRSK", MVC_VIEW_CANCHANGE, .T. )

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( "VIEW_AR3", oStructAR3, "AR3MASTER" )
    oView:AddGrid( "VIEW_AR5", oStructAR5, "AR5DETAIL" )
    oView:AddIncrementField( "VIEW_AR5", "AR5_CODCON" ) 

    oView:CreateHorizontalBox( "POSITION", 60 )
    oView:EnableTitleView( "VIEW_AR3", STR0001 )    //"Posição do Cliente" 

    oView:CreateHorizontalBox( "CONCESSIONS", 40 )
    oView:EnableTitleView( "VIEW_AR5", STR0002 )     //"Concessões de Crédito"  

    oView:SetOwnerView( "VIEW_AR3", "POSITION" )
    oView:SetOwnerView( "VIEW_AR5", "CONCESSIONS" )

    oView:ShowInsertMsg( .F. ) 
    oView:ShowUpdateMsg( .F. ) 
Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPosValid
Bloco de pos validação.
@type   Static Function
@param  oModel, object, Modelo a ser validado
@return lógico, Retorna se a validação está correta
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskPosValid( oModel As Object )
    Local lRet       As Logical
    Local oMdlRsk060 As Object
    Local oMdlAR3    As Object
    Local oMdlAR5    As Object
    Local aError     As Array

    lRet       := .T.
    oMdlRsk060 := Nil
    oMdlAR3    := Nil
    oMdlAR5    := Nil
    aError     := {}

    Default oModel := FwModelActive()

    oMdlAR3 := oModel:GetModel( "AR3MASTER" )

    If oMdlAR3:GetValue( "AR3_LIMDEJ" ) > 0 .And. !FwIsInCallStack( "RSKA060" )
        If AR3->( ColumnPos( "AR3_LONGTE" ) ) > 0
            oMdlAR3:SetValue( "AR3_LONGTE", oMdlAR3:GetValue( "AR3_LONGTE" ) )
            oMdlAR3:SetValue( "AR3_DESCLG", "" )
        EndIf
         oMdlRsk060 := FwLoadModel( "RSKA060" )
         oMdlRsk060:SetOperation( MODEL_OPERATION_INSERT ) 
         oMdlRsk060:Activate()
         If oMdlRsk060:IsActive()
            oMdlAR5 := oMdlRsk060:GetModel( "AR5MASTER" )
            oMdlAR5:SetValue( "AR5_ENTIDA", "SA1" )
            oMdlAR5:SetValue( "AR5_FILENT", xFilial( "SA1" ) )
            oMdlAR5:SetValue( "AR5_CODENT", oMdlAR3:GetValue( "AR3_CODCLI" ) )
            oMdlAR5:SetValue( "AR5_LOJENT", oMdlAR3:GetValue( "AR3_LOJCLI" ) )
            oMdlAR5:SetValue( "AR5_LIMDEJ", oMdlAR3:GetValue( "AR3_LIMDEJ" ) )
            If AR5->( ColumnPos( "AR5_LONGTE" ) ) > 0
                oMdlAR5:SetValue( "AR5_LONGTE", oMdlAR3:GetValue( "AR3_LONGTE" ) )
            EndIf            
            If oMdlRsk060:VldData()
                oMdlRsk060:CommitData()
            Else 
                lRet := .F.   
                aError := oMdlRsk060:GetErrorMessage() 
                Help( "", 1, "RSKA040", , aError[6], 1, 0,,,,,, { IIF( ValType( aError[7] ) =="C", aError[7], "" ) } )     
            EndIf
         EndIf
    EndIf

    FwFreeArray( aError )

    FwFreeObj( oMdlRsk060 )

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPosVlOK
Bloco de pos do Botão OK quando está em tela na posição do cliente.
@type   Static Function
@param  oModel, object, Modelo a ser validado
@return lógico, Retorna se a validação está correta
@author Alecsandre Ap. Fabiano Santana Ferreira | Squad Integrações TechFin
@since  09/04/2024
/*/
//-----------------------------------------------------------------------------
Static Function RskPosVlOK(oModel As Object) As Logical
    Local oMdlAR3Ok    As Object
    Local lRet         As Logical

    oMdlAR3Ok    := Nil
    lRet       := .T.

    Default oMdlAR3Ok := FwModelActive()

    oMdlAR3Ok := oModel:GetModel( "AR3MASTER" )

    If xFilial("AR3") == oMdlAR3Ok:GetValue("AR3_FILIAL") .AND.;
        AR3->AR3_CODCLI == oMdlAR3Ok:GetValue("AR3_CODCLI") .AND.;
        AR3_LOJCLI == oMdlAR3Ok:GetValue("AR3_LOJCLI")
        If oMdlAR3Ok:GetValue("AR3_LIMDEJ") == 0 
            lRet := .F.
            Help("", 1, "RSKA040LIMNAOINF",, STR0017, 1, 0,,,,,, {STR0018}) //'Necessário digitar o valor do limite desejado.' // "Informe o valor no campo Limite Desejado."
        Endif
    Endif
Return lRet
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} RskCliPosition
Interface da Posição do Cliente Mais Negócio.
@type   Function
@param  cCodCli, caracter, Código do cliente
@param  cLojCli, caracter, Código da loja
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@return lógico, indica se a posição do cliente pode ser apresentada
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Function RskCliPosition( cCodCli As Character, cLojCli As Character, lAutomato As Logical ) As Logical
    Local nOperation As Numeric
    Local aSvAlias   As Array
    Local aAreaSA1   As Array
    Local aPosition  As Array
    Local aError     As Array
    Local aButtons   As Array
    Local lRet       As Logical
    Local bPosVldOk  As CodeBlock
    Local oView      As Object
    Local oExecView  As Object
    Local oModel     As Object
    Local oMdlAR3    As Object

    Default cCodCli     := ""
    Default cLojCli     := ""
    Default lAutomato   := .F.

    bPosVldOk := {|oModel| RskPosVlOK( oModel ) }

    nOperation := MODEL_OPERATION_INSERT
    aSvAlias   := GetArea()
    aAreaSA1   := SA1->( GetArea() )
    aPosition  := {} 
    aError     := {}
    aButtons   := {}
    lRet       := .T. 
    oView      := Nil
    oExecView  := Nil
    oModel     := Nil 
    oMdlAR3    := Nil

    cCodCli := PadR( cCodCli, TamSX3( "AR3_CODCLI" )[1] )
    cLojCli := PadR( cLojCli, TamSX3( "AR3_LOJCLI" )[1] )

    SA1->( DBSetOrder(1) )    //A1_FILIAL+A1_COD+A1_LOJA
    AR3->( DBSetOrder(1) )    //AR3_FILIAL+AR3_CODCLI+AR3_LOJCLI

    If SA1->( DBSeek( xFilial( "SA1" ) + cCodCli + cLojCli ) )
        If !Empty( SA1->A1_CGC )
            //------------------------------------------------------------------------------
            // Retorna a posicao já salva para o cliente.
            //------------------------------------------------------------------------------
            FwMsgRun( Nil, {||aPosition := RskGetCliPosition( SA1->A1_CGC, cCodCli, cLojCli, lAutomato, CLIENTPOSITION, 'RSKA040', 'AR3', /*aParam*/ ) }, Nil, STR0003 ) //"Consultando a posição do cliente na plataforma Risk..."
            
            lRet := AR3->( DBSeek( xFilial( "AR3" ) + cCodCli + cLojCli ) ) 
        Else
            lRet := .F.
            Help( "", 1, "RSKA040",, STR0004, 1, 0,,,,,, { STR0005 } )   //"Cliente sem CNPJ/CPF."###"Atualize o campo no cadastro de cliente para acessar a posição."
        EndIf
    Else
        lRet := .F.
        Help( "", 1, "RSKA040",, STR0006, 1, 0,,,,,, { STR0007 } )    //"Cliente não localizado."###"Verifique se o cliente informado está correto."
    EndIf

    If lRet  
        oModel := FwLoadModel( "RSKA040" )
        oModel:SetOperation( MODEL_OPERATION_UPDATE )  
        oModel:Activate()
        
        If oModel:IsActive() 
            oMdlAR3 := oModel:GetModel( "AR3MASTER" )
        
            If !Empty( aPosition ) 
                oMdlAR3:SetValue( "AR3_STASRV", SYNCED )   // 1=Sincronizado
            EndIf

            aButtons := { { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }	  ,;
                        { .F., Nil }, { .T., STR0008 }, { .T., STR0009 }, { .F., Nil } ,;
                        { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil } }     //"Conceder Crédito"###"Fechar"
            
            oModel:lModify := .F.

            oView := FWLoadView( "RSKA040" )
            oView:SetModel( oModel )
            oView:SetOperation( nOperation )  

            oExecView := FWViewExec():New()
            oExecView:SetTitle( STR0010 )   //"Posição Mais Negócios" 
            oExecView:SetSource( "RSKA040" ) 
            oExecView:SetModal( .F. )
            oExecView:SetModel( oModel )
            oExecView:SetView( oView )
            oExecView:SetOperation( nOperation )
            oExecView:SetButtons( aButtons )  
            oExecView:SetOk(bPosVldOk)
            oExecView:SetSize( 600, 600 )    

            IF !lAutomato
                oExecView:OpenView( .F. )
                oExecView:DeActivate()
            EndIf
        Else
            aError	:= oModel:GetErrorMessage()
            Help( "", 1, "RSKA040", , aError[6], 1 )  
        EndIf
    EndIf

    RestArea( aSvAlias )
    RestArea( aAreaSA1 )

    FWFreeArray( aSvAlias )
    FWFreeArray( aAreaSA1 )
    FWFreeArray( aError )
    FWFreeArray( aPosition )
    FWFreeArray( aButtons )
    FreeObj( oView )
    FreeObj( oExecView )
    FreeObj( oMdlAR3 )
    FreeObj( oModel )
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPVdLimD
Valida o limite desejado.
@type   Function
@return lógico, Indica se o limite solicitado é válido.
@author Squad NT TechFin
@since  15/10/2020
/*/
//-----------------------------------------------------------------------------
Function RskPVdLimD()
    Local lRet := .T.

    If FwFldGet( "AR3_LIMDEJ" ) < 0 .Or. FwFldGet( "AR3_LIMDEJ" ) == FwFldGet( "AR3_LIMITE" )  
        lRet := .F.
        Help( "", 1, "RSKA040",, STR0011, 1, 0,,,,,, { STR0012 } )     //"Limite desejado inválido."###"Verifique se o limite desejado está negativo ou igual que o limite atual."
    EndIf  
Return lRet  


//------------------------------------------------------------------------------
/*/{Protheus.doc} RskUpdClientPos
Update da posição dos Clientes.
@type function 
@param aRecords - Array com todos os dados da posição do cliente.
        [1] = Id do cliente (guide)
        [2] = Numero do CNPJ
        [3] = Status do Cliente
        [4] = Descrição do status da posição do cliente.
        [5] = Limite total do cliente
        [6] = Limite disponivel do cliente
        [7] = Limite total do cliente
        [8] = Limite disponivel do cliente 
        [9] = Limite liberado do clientee
        [10] = Limite pré-autorizado do cliente 
        [11] = Limite usado do cliente
        [12] = Permite Faturamento a Prazo no parceiro.
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@return nil.
@author Rodrigo Soares
@since  08/07/2021
/*/
//-----------------------------------------------------------------------------
Function RskUpdClientPos( aRecords As Array, lAutomato As Logical, aParam As Array )
    Local nOperation   As Numeric
    Local cQrySA1      As Character 
    Local cTempSA1     As Character 
    Local aOrgSettings As Array
    Local aItens       As Array
    Local aError       As Array
    Local nX           As Numeric
    Local nTamNomCli   As Numeric
    Local aArea        As Array
    Local aAreaAR3     As Array
    Local oModel       As Object
    Local oMdlAR3      As Object  
    Local oQrySA1      As Object  
    Local lRet         As Logical
    Local lLongTerm    As Logical
    Local cDescLongT   As Character

    Default aParam    := {}
    Default lAutomato := .F. 

    nOperation   := MODEL_OPERATION_INSERT
    cQrySA1      := ''
    cTempSA1     := ''
    aOrgSettings := {}
    aItens       := {}
    aError       := {}
    nX           := 0
    nTamNomCli   := TamSX3( "AR3_NOMCLI" )[1]
    aArea        := GetArea()
    aAreaAR3     := AR3->( GetArea() )
    oModel       := NIL
    oMdlAR3      := NIL  
    oQrySA1      := NIL  
    lRet         := .T.
    lLongTerm    := AR3->( ColumnPos( "AR3_LONGTE" ) ) > 0
    cDescLongT   := ''

    If !Empty( aRecords) 
        aOrgSettings := RskGetSSettings( SM0->M0_CGC, lAutomato, CLIENTPOSITION, 'RSKA040', 'AR3', aParam )
        If !Empty( aOrgSettings )

            dbSelectArea('AR3')   
            AR3->( DBSetOrder(1) )    //AR3_FILIAL+AR3_CODCLI+AR3_LOJCLI

            cTempSa1 := GetNextAlias()

            cQrySA1  := " SELECT A1_COD, A1_LOJA, A1_NOME, R_E_C_N_O_ RECNO "
            cQrySA1  += " FROM " + RetSqlName( "SA1" ) 
            cQrySA1  += " WHERE A1_FILIAL = '" + xFilial( "SA1" ) + "' "
            cQrySA1  += " AND A1_CGC = ? "   
            cQrySA1  += " AND D_E_L_E_T_ = ' ' " 
            cQrySA1  += " ORDER BY " + SqlOrder( SA1->( IndexKey() ) )

            oQrySA1 := FWPreparedStatement():New( cQrySA1 )

            For nX := 1 to len (aRecords)
                aItens     := aRecords[nX]
                cDescLongT := ''
                oQrySA1:SetString( 1, aItens[2] )
            
                cQrySA1     := oQrySA1:GetFixQuery()
                cTempSA1    := MPSysOpenQuery( cQrySA1 )

                ( cTempSA1 )->( DBGoTop() )
                
                While ( cTempSA1 )->( !Eof() )
                    If AR3->( MSSeek( xFilial( "AR3" ) + ( cTempSA1 )->A1_COD + ( cTempSA1 )->A1_LOJA ) )
                        nOperation := MODEL_OPERATION_UPDATE
                    EndIf 

                    oModel := FwLoadModel( "RSKA040" )
                    oModel:SetOperation( nOperation )
                    oModel:Activate()

                    If oModel:IsActive()                         
                        oMdlAR3 := oModel:GetModel( "AR3MASTER" )   

                        If nOperation == MODEL_OPERATION_INSERT 
                            oMdlAR3:SetValue( "AR3_CODCLI", ( cTempSA1 )->A1_COD ) 
                            oMdlAR3:SetValue( "AR3_LOJCLI", ( cTempSA1 )->A1_LOJA )
                            oMdlAR3:SetValue( "AR3_NOMCLI", PadR( ( cTempSA1 )->A1_NOME, nTamNomCli ) )   
                        EndIf

                        If !Empty( aItens )
                            oMdlAR3:SetValue( "AR3_CREDIT", "1" )                               //Crédito Parceiro? Sim
                            oMdlAR3:SetValue( "AR3_LIMITE", aItens[7] )                         //Limite Atual
                            oMdlAR3:SetValue( "AR3_LIMDIS", aItens[8] )                         //Limite Disponivel
                            oMdlAR3:SetValue( "AR3_LIMLIB", aItens[9] )                         //Limite Liberado
                            oMdlAR3:SetValue( "AR3_LIMPRE", aItens[10] )                        //Limite Pre-Autorizado
                            oMdlAR3:SetValue( "AR3_TOTFAT", aItens[11] )                        //Total Faturado
                            oMdlAR3:SetValue( "AR3_DIASAT", aItens[6] )                         //Dias de atraso
                            oMdlAR3:SetValue( "AR3_SITPAR", Capital( aItens[4] ) )              //Status do Cliente
                            oMdlAR3:SetValue( "AR3_TIPCLI", aItens[5] )                         //Tipo de Cliente
                            oMdlAR3:SetValue( "AR3_DTATUA", FWTimeStamp( 1, Date(), Time() ) )  //Data/Hora da atulização
                            oMdlAR3:SetValue( "AR3_FATPRA", If( aItens[12] == "0", .T., .F. ) ) //Permite Faturamento a Prazo no parceiro.
                            If lLongTerm .And. Len( aItens ) > 12
                                oMdlAR3:SetValue( "AR3_LONGTE", aItens[13] )                    //Permite Faturamento Mais Negócios - Mais Longo.
                                If aItens[13] == "1"
                                    cDescLongT := STR0015 + aItens[14] + STR0016                //"Liberado para " # " dias."
                                EndIf
                                oMdlAR3:SetValue( "AR3_DESCLG", cDescLongT )                    //Descrição do Faturamento Mais Negócios - Mais Longo.
                            EndIf
                        EndIf

                        If oModel:VldData()
                            oModel:CommitData()
                            RSKConfirm(aItens[2], CLIENTPOSITION, lAutomato )   //10=Posição do Cliente
                        Else
                            aError	:= oModel:GetErrorMessage() 
                            Conout( "RskUpdClientPos -> " + aError[6] )            
                        EndIf
                    Else
                        aError	:= oModel:GetErrorMessage()
                        Conout( "RskUpdClientPos -> " + aError[6] ) 
                    EndIf
                    
                    ( cTempSA1 )->( dbSkip() )  
                End

                ( cTempSA1 )->( DBCloseArea() )
            Next nX 
       Else
            lRet := .F.
            Help( "", 1, "RSKA040",, STR0013, 1, 0,,,,,, { STR0014 } )      //"Não foi possível consultar as configurações para concessão de crédito na plataforma."###"Por favor verifique se há um emitente vinculado a essa Empresa/Filial  ou realize uma nova tentativa mais tarde!"
        EndIf
    EndIf

    RestArea(aArea)
    RestArea(aAreaAR3)
    
    FWFreeArray( aArea )
    FWFreeArray( aAreaAR3 )
    FWFreeArray( aItens )
    FWFreeArray( aOrgSettings )
    FWFreeArray( aError )
    FreeObj( oModel )
    FreeObj( oMdlAR3 )
    FreeObj( oQrySA1 )
Return nil
