#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "GRRXDefs.CH" 
#include "GRRA060.CH" 

PUBLISH MODEL REST NAME GRRA060 SOURCE GRRA060


//-------------------------- GRRA060 ------------------------------
// Funções para tratar os dados da tabela de Ordem de Pagamento
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRA060
Rotina que grava as informações sobre a ordem de pagamento.

@param aData, array, vetor com as informações para gerar a relação 
	com a ordem de pagamento do GRR. Onde: 
		[1] - Filial origem da solicitação
		[2] - Alias da solicitação
		[3] - Origem da assinatura
		[4] - Código da solicitação
		[5] - Id da cobrança no GRR
		[6] - Id da Fatura no GRR
		[7] - Referência do cliente na Integração.
		[8] - Boleto
		[9] - Status
		[10] - Valor 
		[11] - Vencimento
		[12] - Método de Pagamento

@return boolean, Indica se salvou com sucesso os dados de ordem de pagamento.
@author  Rodrigo G. Soares
@since   31/05/2023
/*/
//-------------------------------------------------------------------
Function GRRA060( aData )
	Local aSvAlias := GetArea()
	Local nTamFil := TamSx3( "HRI_SRCFIL" )[ 1 ]
	Local nTamAlias := TamSx3( "HRI_ALIAS" )[ 1 ]
	Local nTamReq := TamSx3( "HRI_REQCD" )[ 1 ]
	Local lRet := .F.
	Local oModel := Nil
	Local oMdlHRI := Nil 
	
	If !Empty( aData ) .and. len( aData ) == 12 
		HRI->( DbSetOrder( 1 ) )         // HRI_FILIAL+HRI_SRCFIL+HRI_ALIAS+HRI_REQCD+HRI_SOURCE

		oModel  := FWLoadModel( "GRRA060" )
        IF !( HRI->( DbSeek( xFilial( "HRI" ) + Padr( aData[ 1 ], nTamFil ) + Padr( aData[ 2 ], nTamAlias ) + Padr( aData[ 4 ], nTamReq ) ) ) )
            oModel:SetOperation( MODEL_OPERATION_INSERT )
        Else
            oModel:SetOperation( MODEL_OPERATION_UPDATE )
        EndIf
        
		If oModel:Activate()
			oMdlHRI := oModel:GetModel( "HRIMASTER" )
			oMdlHRI:SetValue( "HRI_SRCFIL", aData[ GRR_PAYMENT_ORDER_SRCFIL ] )
			oMdlHRI:SetValue( "HRI_ALIAS", aData[ GRR_PAYMENT_ORDER_ALIAS ] ) 
			oMdlHRI:SetValue( "HRI_SOURCE", aData[ GRR_PAYMENT_ORDER_SOURCE ] )
			oMdlHRI:SetValue( "HRI_REQCD", aData[ GRR_PAYMENT_ORDER_REQCD ] )
			oMdlHRI:SetValue( "HRI_CHARID", aData[ GRR_PAYMENT_ORDER_CHARID ] )
			oMdlHRI:SetValue( "HRI_BILLID", aData[ GRR_PAYMENT_ORDER_BILLID ] )
			oMdlHRI:SetValue( "HRI_CUSIID", aData[ GRR_PAYMENT_ORDER_CUSIID ] )
			oMdlHRI:SetValue( "HRI_BOLETO", aData[ GRR_PAYMENT_ORDER_BANKSLIP ] )
			oMdlHRI:SetValue( "HRI_STATUS", aData[ GRR_PAYMENT_ORDER_STATUS ] )
			oMdlHRI:SetValue( "HRI_VALOR", aData[ GRR_PAYMENT_ORDER_VALUE ] )
			oMdlHRI:SetValue( "HRI_VENCTO", aData[ GRR_PAYMENT_ORDER_DUEDATE ] )
			oMdlHRI:SetValue( "HRI_PAYMET", cValtoCHAR( aData[ GRR_PAYMENT_ORDER_PAYMET ] ) )
			
			If oModel:VldData()
				oModel:CommitData()    
				lRet := .T.
			EndIf
		ENDIF

		oModel:DeActivate()
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FreeObj( oModel )
	FreeObj( oMdlHRI )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria o modelo de dados da ordem de pagamento GRR.

@return object, Modelo com os dados da ordem de pagamento.
@author  Rodrigo G. Soares
@since   31/05/2023
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel := NIL
	Local oStruHRI := FWFormStruct( 1, 'HRI' )

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "GRRA060" )
	oModel:AddFields( 'HRIMASTER', /*cOwner*/, oStruHRI )
	oModel:SetDescription( STR0001 )	//"Ordem de pagamento - GRR"
	oModel:SetPrimaryKey( { 'HR1_FILIAL', 'HRI_SRCFIL', 'HRI_ALIAS', 'HRI_REQCD', 'HRI_SOURCE' } ) 
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria a view com os dados da ordem de pagamento.

@return object, View com os dados da ordem de pagamento.
@author  Rodrigo G. Soares
@since   31/05/2023
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel( 'GRRA060' )
	Local oStruHRI := FWFormStruct( 2, 'HRI' )
	Local oView := FWFormView():New()

	oView:SetModel( oModel )

	/*-------------------------------------------
				Esrutura da View
	---------------------------------------------*/
	// Cabeçalho
	oView:AddField( 'GRRA060_HRI', oStruHRI, 'HRIMASTER' )
	oView:EnableTitleView( 'HRIMASTER',  STR0002 )	//'Ordem de Pagamento'

	/*-----------------------------------------
			Estrutura do Folder
	-------------------------------------------*/
	oView:CreateHorizontalBox( 'FIELDS', 100 )

	/*-----------------------------------------
	Amarração para exibição das informações
	-------------------------------------------*/
	oView:SetOwnerView( 'HRIMASTER', 'FIELDS' )
Return oView
