#include "protheus.ch"
#Include 'FWMVCDef.ch'

/*-----------------------------------------------------
        Informações do OrganizationIntegrationID
-----------------------------------------------------*/
#DEFINE ORG_COMPANY         1
#DEFINE ORG_BRANCH          2

//-------------------------- GRRI030 ------------------------------------------------
// Funções de sincronização do cadastro de planos da plataforma GRR com o Protheus
//-----------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI030
Função que prepara as informações necessárias para a sincronização dos planos da 
plataforma GRR com o Protheus.

@author  Marcia Junko
@since   18/05/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRI030( )
    Local aSvAlias := GetArea()
    Local cPath := '/plans'     
    Local cSource := ''

    //--------------------------------------------------------------
    // Retorna o nome do fonte PRW que fez a chamada da função
    //--------------------------------------------------------------
    cSource := ProcSource( 0 ) 
    cSource := StrTran( cSource, '.PRW', '' )  

    IF GRRSyncExec( 'plans', cSource )        
        BEGIN TRANSACTION
            //-----------------------------------------------------------------------
            // Avalia se os planos gravados no Protheus ainda existem na plataforma.
            // Se não existirem, deleta estes registros no Protheus
            //-----------------------------------------------------------------------
            CheckPlans( cPath )

            //-----------------------------------------------------------------------
            // Sincroniza os planos da plataforma com o Protheus
            //-----------------------------------------------------------------------
            SyncFlow( cPath )

            //--------------------------------------------------------------
            // Armazena a informação de execução ao controle de sincronismo
            //--------------------------------------------------------------
            GRRSyncTime( 'plans', cSource )
        END TRANSACTION
    EndIf

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SyncFlow
Função que controla o sincronismo dos dados vindos da plataforma

@param cPath, caracter, Endpoint a executar

@author  Marcia Junko
@since   18/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SyncFlow( cPath )
    Local aSvAlias := GetArea()
    Local aResult := {}
    Local cEndpoint := GRRURL()
    Local cPage := ''
    Local cResult := ''
    Local lFirst := .T.
    Local lHasNext := .F.
    Local nI := 0
    Local nPage := 1
    Local oRest
    Local oResult
    Local oModel
    Local oJson
    
    oModel := FWLoadModel( "GRRA020" )
    While lFirst .Or. lHasNext
        oRest := NIL
        lHasNext := .F.

        IF lFirst
            lFirst := .F.
        else
            nPage++
            cPage := "?page=" + Alltrim( Str( nPage ) )
        EndIf

        cResult := GRRRestExec( 'GET', cEndpoint, cPath + cPage, @oRest )

        If !Empty( cResult )
            oResult := JSONObject():New() 
            oResult:FromJSON( cResult )

            lHasNext := oResult[ 'hasNext' ]
            aResult := oResult[ 'responseData' ]

            If !Empty( aResult )
                If FWJsonDeserialize( cResult, @oJson)
                    If AttIsMemberOf( oJson, "responseData" )
                        For nI := 1 to len( oJson:responseData )
                            SetData( @oModel, oJson:responseData[ nI ] )
                            oModel:DeActivate()
                        Next    
                    EndIf 
                EndIf
            EndIF
        EndIf
    End
    
    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
    FreeObj( oRest )
    FreeObj( oResult )
    FreeObj( oModel )
    FreeObj( oJson )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetData
Função que atribui as informações do plano vindas da plataforma GRR ao model.

@param @oModel, object, model do cadastro de planos ()
@param oData, json, dados do plano 

@author  Marcia Junko
@since   18/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetData( oModel, oData )
    Local aOrganizations := {}
    Local aBranch := {}
    Local cLastBranch := cFilAnt
    Local cBranch := ''
    Local nJ := 0
    Local lInsert := .F.
    Local oMdlHRD
    Local oMdlHRE
    
    If AttIsMemberOf(oData, 'items') .And. ValType(oData:items) == "A" .And. Len(oData:items) > 0       

        HRD->( DbSetOrder( 2 ))         // HRD_FILIAL+HRD_PLANID
        
        oModel:SetOperation( MODEL_OPERATION_VIEW )
        If oModel:Activate()
            oMdlHRD := oModel:GetModel( "HRDMASTER" )
            oMdlHRE := oModel:GetModel( "HREDETAIL" )
        EndIf

        aOrganizations := oData:organizations
        For nJ := 1 to len( aOrganizations )
            lInsert := .F.
            aBranch := {}

            //--------------------------------------------------------------------------
            // Desconsidera a organization em branco que é um default da plataforma
            //--------------------------------------------------------------------------
            If !Empty( aOrganizations[ nJ ]:organizationIntegrationId )
                aBranch := StrTokArr2( aOrganizations[ nJ ]:organizationIntegrationId, '|' )

                If aBranch[ ORG_COMPANY ] == cEmpAnt
                    If !Empty( aBranch[ ORG_BRANCH ] )
                        cFilAnt := aBranch[ ORG_BRANCH ]
                    EndIf
                    cBranch := aBranch[ ORG_BRANCH ]

                    //--------------------------------------------------------------------------
                    // Somente sincroniza se existir itens desta filial no plano
                    //--------------------------------------------------------------------------                    
                    If Ascan( oData:items, {|x| ValType(x) =="O" .And. AttIsMemberOf(x,'itemIntegrationId') .And. x:itemIntegrationId != NIL .And. cEmpant +'|'+ cBranch $ x:itemIntegrationId } ) > 0
                        oModel:DeActivate()
                        IF !( HRD->( DbSeek( xFilial( "HRD" ) + oData:id ) ) )
                            lInsert := .T.
                            oModel:SetOperation( MODEL_OPERATION_INSERT )
                        Else
                            oModel:SetOperation( MODEL_OPERATION_UPDATE )
                        EndIf

                        If oModel:Activate()
                            SetPlan( @oMdlHRD, @oMdlHRE, oData, lInsert )
                            If oModel:VldData()
                                If lInsert
                                    ConfirmSX8( )
                                EndIf
                                oModel:CommitData()
                            EndIf
                        EndIf
                    EndIf
                EndIF
            EndIf
        Next
    EndIf

    cFilAnt := cLastBranch

    FWFreeArray( aBranch )
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckPlans
Função que avalia se os planos cadastrados na base de dados ainda existem na plataforma

@param cPath, caracter, Endpoint a executar

@author  Marcia Junko
@since   20/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function CheckPlans( cPath )
    Local aSvAlias := GetArea()
    Local aHREAlias := HRE->( GetArea() )
    Local cQuery := ''
    Local cQryItems := ''
    Local cEndpoint := ''
    Local cResult := ''
    Local cTmpAlias := GetNextAlias()
    Local oModel
    Local oJson
    Local oQryItens

    HRE->( DbSetOrder( 3 ))         // HRE_FILIAL+HRE_ITPLID+HRE_ITEMID

    cQuery := "SELECT HRD_FILIAL, HRD_CODE, HRD_PLANID, R_E_C_N_O_ AS ID FROM " + RetSqlName( "HRD" ) + " HRD WHERE D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery( cQuery, cTmpAlias )

    If ( cTmpAlias )->( !Eof() )
        cEndPoint := GRRURL()
        oModel := FWLoadModel( "GRRA020" )
        
        cQryItems := "SELECT HRE_ITPLID, HRE_ITEMID, R_E_C_N_O_ AS ID FROM " + RetSqlName("HRE") + " WHERE HRE_FILIAL = ? AND HRE_PLAN = ? AND D_E_L_E_T_ = ' '"
        cQryItems := ChangeQuery( cQryItems )
        oQryItens := FWPreparedStatement():New( cQryItems )                    

        While ( cTmpAlias )->( !Eof() )
            oModel:DeActivate()
            
            cResult := SeekPlaninGRR( cEndpoint, cPath,  ( cTmpAlias )->HRD_PLANID )

            IF Empty( cResult )
                HRD->( DBGoto( ( cTmpAlias )->ID ) )
                oModel:SetOperation( MODEL_OPERATION_DELETE )
                oModel:Activate()

                If oModel:VldData()
                    oModel:CommitData()
                EndIf
            Else
                If FWJsonDeserialize( cResult, @oJson )
                    If AttIsMemberOf( oJson, "items" )
                        HRD->( DBGoto( ( cTmpAlias )->ID ) )
                        oModel:SetOperation( MODEL_OPERATION_UPDATE )
                        oModel:Activate()

                        VerifyItens( @oModel, oQryItens, { ( cTmpAlias )->HRD_FILIAL, ( cTmpAlias )->HRD_CODE }, oJson:items )
                    ENDIF
                EndIf
            EndIf

            ( cTmpAlias )->( DBSkip() )
        End
        oModel:DeActivate()

        FreeObj( oModel )
    ENDIF
    ( cTmpAlias )->( DbCloseArea() )

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf
    If !Empty( aHREAlias )
        RestArea( aHREAlias )
    EndIf

    FWFreeArray( aSvAlias )
    FWFreeArray( aHREAlias )
    FreeObj( oModel )
    FreeObj( oJson )
    FreeObj( oQryItens )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SeekPlaninGRR
Função que avalia se os planos cadastrados na base de dados ainda existem na plataforma

@param cEndPoint, caracter, URL do serviço
@param cPath, caracter, Endpoint a executar
@param cIDPlan, caracter, Guid do plano no GRR

@return caracter, conteúdo do plano específico na plataforma
@author  Marcia Junko
@since   20/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SeekPlaninGRR( cEndpoint, cPath, cIDPlan )
    Local cResult := ''

    cResult := GRRRestExec( 'GET', cEndpoint, cPath + '/' + cIDPlan )
Return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VerifyItens
Função que verifica se todos os itens presentes na base do Protheus ainda são válidas no GRR.

@param oModel, object, modelo da tela de planos x itens
@param oQryItens, object, estrutura da query para itens do plano
@param aPlanInfo, array, Vetor com as informações de base do plano
    [1] - filial do plano
    [2] - código do plano no Protheus
@param oItems, object, Json com os items do plano que estão cadastrados na plataforma.

@author  Marcia Junko
@since   23/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function VerifyItens( oModel, oQryItens, aPlanInfo, oItems )
    Local cTmpAlias := GetNextAlias()
    Local lUpdated := .F.
    Local oMdlHRE

    oMdlHRE := oModel:GetModel( "HREDETAIL" )

    oQryItens:SetString( 1, aPlanInfo[ 1 ] )
    oQryItens:SetString( 2, aPlanInfo[ 2 ] )

    MPSysOpenQuery( oQryItens:getFixQuery(), cTmpAlias )

    While ( cTmpAlias )->( !EOF() )
        If Ascan( oItems, {|x| x:id == ( cTmpAlias )->HRE_ITPLID .And. x:itemId == ( cTmpAlias )->HRE_ITEMID } )  == 0
            If oMdlHRE:SeekLine( { { "HRE_ITPLID", ( cTmpAlias )->HRE_ITPLID }, { "HRE_ITEMID", ( cTmpAlias )->HRE_ITEMID  } } )      
                oMdlHRE:DeleteLine()
                lUpdated := .T.
            Endif
        EndIf

        ( cTmpAlias )->( DBSkip() )
    End

    ( cTmpAlias )->( DbCloseArea() )

    If lUpdated
		If oModel:VldData()
            oModel:CommitData()
		EndIf
    EndIf
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPlan
Função que seta as informações do plano no modelo MVC e chama a inclusão dos itens do plano

@param oMdlHRD, object, model do cabeçalho do plano
@param oMdlHRE, object, model dos itens do plano
@param oData, object, JSON com as informações do plano cadastrados na plataforma
@param lNew, boolean, indica se está incluindo ou alterando o registro.

@author  Marcia Junko
@since   20/10/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetPlan( oMdlHRD, oMdlHRE, oData, lNew )
    Local cPayment := ''
    Local cPlan := ''

    aSort( oData:paymentMethods, , , {| x, y | x:paymentMethod < y:paymentMethod } )
    If valtype( oData:paymentMethods[1]:paymentMethod ) == "N"
        aEval( oData:paymentMethods, {|x| cPayment += cBIStr( x:paymentMethod ) + '|' } )                         
    EndIf
    cPayment := Subs( cPayment, 1, len( cPayment ) - 1 )

    If lNew
        cPlan := oMdlHRD:GetValue( "HRD_CODE" )
        oMdlHRD:SetValue( "HRD_FILIAL", xFilial( "HRD" ) ) 
        oMdlHRD:SetValue( "HRD_CODE", cPlan )             
        oMdlHRD:SetValue( "HRD_PLANID", oData:id )
    Else 
        cPlan := HRD->HRD_CODE
    EndIf
    
    oMdlHRD:SetValue( "HRD_REFERE", oData:reference )       
    oMdlHRD:SetValue( "HRD_VERSIO", oData:version )
    oMdlHRD:SetValue( "HRD_NAME", DecodeUTF8( oData:name ) )
    
    oMdlHRD:SetValue( "HRD_INTERM", stod( subs( strtran( oData:initialTerm, '-', '' ), 1, 8 ) ) )   
    If oData:finalTerm != NIL
        oMdlHRD:SetValue( "HRD_FITERM", stod( subs( strtran( oData:finalTerm, '-', '' ), 1, 8 ) ) )           
    EndIf

    oMdlHRD:SetValue( "HRD_DESCRI", DecodeUTF8( oData:description ) )
    oMdlHRD:SetValue( "HRD_PAYMET", cPayment )    
    oMdlHRD:SetValue( "HRD_ACTIVE", Iif( oData:isActive, '1', '2' ) )

    SetPlanItens( @oMdlHRE, oData, cPlan )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPlanItens
Função que seta as informações dos itens do plano no modelo MVC.

@param @oMdlHRE, object, model dos itens do plano
@param oData, object, JSON com as informações do plano cadastrados na plataforma
@param cPlanCode, caracter, código do plano

@author  Marcia Junko
@since   20/10/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetPlanItens( oMdlHRE, oData, cPlanCode )
    Local aSvAlias := GetArea()
    Local aProduct := {}
    Local nK := 0
    Local nLine := 0
    Local oItem

    SB1->( DbSetOrder( 1 ) )    // B1_FILIAL+B1_COD

    For nK := 1 to len( oData:items )
        aProduct := {}
        oItem := oData:items[ nK ]
        aProduct := StrTokArr2( oItem:itemIntegrationId , '|' ) 

        //---------------------------------------------------------------------
        // Só atribui o iten ao plano, se existir o mesmo produto no Protheus
        //---------------------------------------------------------------------
        If SB1->( DBSeek( xFilial( "SB1", aProduct[ 2 ] ) + aProduct[ 3 ] ) )
            nLine := oMdlHRE:GetLine()

            If !oMdlHRE:SeekLine( { { "HRE_ITPLID", oItem:id }, { "HRE_ITEMID", oItem:itemId } } ) 
                If nK < Len( oData:items )
                    oMdlHRE:AddLine()
                EndIf

                oMdlHRE:SetValue( "HRE_FILIAL", xFilial( "HRE" ))
                oMdlHRE:SetValue( "HRE_ITPLID", oItem:id ) 
                oMdlHRE:SetValue( "HRE_ITEMID", oItem:itemId )
                oMdlHRE:SetValue( "HRE_ITEM", StrZero( nK, TamSX3( "HRE_ITEM")[1] ) )   
                oMdlHRE:SetValue( "HRE_PLAN", cPlanCode )      
                oMdlHRE:SetValue( "HRE_FILPRD", aProduct[ 2 ] )       
                oMdlHRE:SetValue( "HRE_PRDCOD", aProduct[ 3 ] )   
            EndIf

            oMdlHRE:SetValue( "HRE_QUANT", oItem:quantity )
            oMdlHRE:SetValue( "HRE_BASEVL", oItem:baseValue )    
            oMdlHRE:SetValue( "HRE_VALUE", oItem:value )       
            oMdlHRE:SetValue( "HRE_TOTAL", oItem:totalAmount )  

            oMdlHRE:GoLine( nLine )
        EndIf
    Next

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FwFreeArray( aSvAlias )
    FwFreeArray( aProduct )
Return
