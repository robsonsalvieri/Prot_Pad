#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "PARMTYPE.ch" 
#INCLUDE "GRRA050.CH" 

//-------------------------- GRRA050 ------------------------------
// Funções para tratar os dados da tabela de requisições x plano ( HRH )
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRA050
Rotina que grava as informações sobre a assinatura.

@param aData, array, vetor com as informações para gerar a relação 
	com a assinatura do GRR. Onde: 
		[1] - Filial origem da solicitação
		[2] - Alias da solicitação
		[3] - Origem da assinatura
		[4] - Código da solicitação
		[5] - Filial plano
		[6] - Código do plano
		[7] - Forma de pagamento
		[8] - Id da subscrição

@author  Marcia Junko
@since   29/08/2022
/*/
//-------------------------------------------------------------------
Function GRRA050( aData )
	Local aSvAlias := GetArea()
	Local nTamFil := TamSx3( "HRH_SRCFIL" )[1]
	Local nTamAlias := TamSx3( "HRH_ALIAS" )[1]
	Local nTamReq := TamSx3( "HRH_REQCD" )[1]
	Local oModel 	:= Nil
	Local oMdlHRH 	:= Nil 
	
	If !Empty( aData )
		HRH->( DbSetOrder( 1 ))         // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE

		oModel  := FWLoadModel( "GRRA050" )
        IF !( HRH->( DbSeek( xFilial( "HRH" ) + Padr( aData[1], nTamFil) + Padr( aData[2], nTamAlias) + Padr( aData[4], nTamReq) ) ) )
            oModel:SetOperation( MODEL_OPERATION_INSERT )
        Else
            oModel:SetOperation( MODEL_OPERATION_UPDATE )
        EndIf
        //TODO - Readequar a rotina para tratar sem posição fixa.
        If oModel:Activate()
			oMdlHRH := oModel:GetModel( "HRHMASTER" )
			oMdlHRH:SetValue( "HRH_SRCFIL", aData[1] )
			oMdlHRH:SetValue( "HRH_ALIAS", aData[2] ) 
			oMdlHRH:SetValue( "HRH_SOURCE", aData[3] )
			oMdlHRH:SetValue( "HRH_REQCD", aData[4] )
			oMdlHRH:SetValue( "HRH_PLNFIL", aData[5] )
			oMdlHRH:SetValue( "HRH_PLANCD", aData[6] )
			If len( aData ) >= 7 .And. !Empty( Alltrim( aData[7] ) )
				oMdlHRH:SetValue( "HRH_PAYMET", Alltrim( aData[7] ) )
			EndIf
			If len( aData ) >= 8 .And. !Empty( Alltrim( aData[8] ) )
				oMdlHRH:SetValue( "HRH_SUBSID", Alltrim( aData[8] ) )
			EndIf
			
			If oModel:VldData()
				oModel:CommitData()    
			EndIf
		ENDIF

		oModel:DeActivate()
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FreeObj( oModel )
	FreeObj( oMdlHRH )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria o modelo de dados da assinatura.

@return object, Modelo com os dados da assinatura.
@author  Marcia Junko
@since   29/08/2022
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel	:= NIL
	Local oStruHRH  :=  FWFormStruct( 1, 'HRH' )

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "GRRA050" )
	oModel:AddFields( 'HRHMASTER', , oStruHRH )
	oModel:SetDescription( STR0001 )	// "Dados da assinatura"
	oModel:SetPrimaryKey( {'HRH_FILIAL', 'HRH_SRCFIL', 'HRH_ALIAS', 'HRH_REQCD', 'HRH_SOURCE' } ) 
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria a view com os dados da assinatura.

@return object, View com os dados da assinatura.
@author  Marcia Junko
@since   29/08/2022
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local   oModel      :=  FWLoadModel( 'GRRA050' )
	Local   oStruHRH    :=  FWFormStruct( 2, 'HRH' )
	Local   oView       :=  FWFormView():New()

	oView:SetModel( oModel )

	//-------------------------------------------
	//			Esrutura da View
	//-------------------------------------------
	// Cabeçalho
	oView:AddField( 'GRRA050_HRH', oStruHRH, 'HRHMASTER' )
	oView:EnableTitleView( 'HRHMASTER', STR0001 )	//'Dados da assinatura'

	//-----------------------------------------
	//		Estrutura do Folder
	//-------------------------------------------
	oView:CreateHorizontalBox( 'FIELDS', 100 )

	//-----------------------------------------
	// Amarração para exibição das informações
	//-------------------------------------------
	oView:SetOwnerView( 'HRHMASTER', 'FIELDS' )
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRSetSubscriptionId
Atribui o guid da subscription na tabela intermediária de acordo com os 
dados passados para pesquisa

@param aSeek, array, vetor com os dados para a pesquisa da chave da 
	requisição, onde: 
		[1] - Filial origem da solicitação
		[2] - Alias da solicitação
		[3] - Código da solicitação
		[3] - Origem da assinatura
@param cValue, caracter, conteúdo a ser gravado

@author  Marcia Junko
@since   02/09/2022
/*/
//-------------------------------------------------------------------
Function GRRSetSubscriptionId( aSeek, cValue )
Return SavePlatInfo( 1, aSeek, cValue )

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRSetBillId
Atribui o guid da fatura na tabela intermediária de acordo com os 
dados passados para pesquisa

@param aSeek, array, vetor com os dados para a pesquisa da chave da 
	requisição, onde: 
		[1] - Filial origem da solicitação
		[2] - Alias da solicitação
		[3] - Código da solicitação
		[3] - Origem da assinatura
@param cValue, caracter, conteúdo a ser gravado

@author  Marcia Junko
@since   02/09/2022
/*/
//-------------------------------------------------------------------
Function GRRSetBillId( aSeek, cValue )
Return SavePlatInfo( 2, aSeek, cValue )

//-------------------------------------------------------------------
/*/{Protheus.doc} SavePlatInfo
Atribui o guid da subscription na tabela intermediária de acordo com os 
dados passados para pesquisa

@param nType, number, indica qual o campo será atualizado, onde:
	1 = ID Subscrição
	2 = ID Fatura
@param aSeek, array, vetor com os dados para a pesquisa da chave da 
	requisição, onde: 
		[1] - Filial origem da solicitação
		[2] - Alias da solicitação
		[3] - Código da solicitação
		[3] - Origem da assinatura
@param cValue, caracter, conteúdo a ser gravado

@author  Marcia Junko
@since   02/09/2022
/*/
//-------------------------------------------------------------------
Static Function SavePlatInfo( nType, aSeek, cValue )
	Local aSvAlias := GetArea()
	Local nTamFil := TamSX3( "HRH_SRCFIL" )[1]
	Local nTamAlias := TamSX3( "HRH_ALIAS" )[1]
	Local nTamReq := TamSX3( "HRH_REQCD" )[1]
	Local nTamSource := TamSX3( "HRH_SOURCE" )[1]
	Local cSeek := ''
	Local cField := ''
	Local oModel
	Local oMdlHRH

	IF !Empty( cValue )
		HRH->( DbSetOrder( 1 )) // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE

		cSeek := Padr( aSeek[1], nTamFil )
		cSeek += Padr( aSeek[2], nTamAlias )
		cSeek += Padr( aSeek[3], nTamReq )
		If Len( aSeek ) >= 4
			cSeek += Padr( aSeek[4], nTamSource )
		EndIf

		If nType == 1
			cField := "HRH_SUBSID" 
		ElseIf nType == 2
			cField := "HRH_BILLID"
		ElseIf nType == 3
			cField := "HRH_PAYMET"
		EndIf


		If HRH->( DBSeek( xFilial( "HRH" ) + cSeek ))
			oModel  := FWLoadModel( "GRRA050" )
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			oModel:Activate()

			oMdlHRH := oModel:GetModel( "HRHMASTER" )
			oMdlHRH:SetValue( cField, cValue )

			If oModel:VldData()
				oModel:CommitData()    
			EndIf

			oModel:DeActivate()
		EndIF

		RestArea( aSvAlias )
	EndIf

	FWFreeArray( aSvAlias )
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GRRHRHFieldsInOrder
Função para assegurar que os dados sejam passados na sequência em que 
a função de gravação da tabela intermediária necessita.

@param aFields, array, vetor com campos a serem utilizados na função de 
	gravação do registro na tabela HRH, onde:
		[1] - nome do campo
		[2] - conteúdo

@return array, vetor com as informações ordenadas na estrutura da função GRRA050.
@author  Marcia Junko
@since   12/09/2022
/*/
//-------------------------------------------------------------------
Function GRRHRHFieldsInOrder( aFields )
	Local aOrderFields := {}
	Local aHRHFields := {}
	Local nI := 0
	Local nPos := 0

	aHRHFields := HRHSaveOrder()
	For nI := 1 to len( aHRHFields )
		nPos := Ascan( aFields, {|z| aHRHFields[ nI ] == z[ 1 ] } )
		If nPos > 0 
			aAdd( aOrderFields, aFields[ nPos ][ 2 ] )
		EndIf
	Next
	FWFreeArray( aHRHFields )
Return aOrderFields

//-------------------------------------------------------------------
/*/{Protheus.doc} HRHSaveOrder
Retorna a lista de campos, em ordem, das posições do array recebido como
parâmetro da função  GRRA050.

@return array, vetor com a ordem dos campos esperados pela função GRRA050.
@author  Marcia Junko
@since   12/09/2022
/*/
//-------------------------------------------------------------------
Static Function HRHSaveOrder()
Return { "HRH_SRCFIL", "HRH_ALIAS", "HRH_SOURCE", "HRH_REQCD", "HRH_PLNFIL", "HRH_PLANCD", "HRH_PAYMET" }


//-------------------------------------------------------------------
/*/{Protheus.doc} GRRSetHRHInfo()
Função que busca a relação da requisição com o plano e atribui às 
variáveis de memória.

@param cAlias, caracter, Alias da solicitação
@param cRequest, caracter, Código da solicitação
@param cSource, caracter, Origem da solicitação

@author  Marcia Junko
@since   15/09/2022
/*/
//-------------------------------------------------------------------
Function GRRSetHRHInfo( cAlias, cRequest, cSource )
	Local aSvAlias := GetArea()
	Local cSeek := ''
	Local nTamAlias := 0
	Local nTamRequest := 0

	Default cSource := ''

	HRH->( DbSetOrder( 1 ))	// HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE
	
	If !Empty( cAlias ) .And. !Empty( cRequest )
		nTamAlias := TamSX3( "HRH_ALIAS" )[1]
		nTamRequest := TamSX3( "HRH_REQCD" )[1]

		cSeek := xFilial( cAlias ) + Padr( cAlias, nTamAlias ) + Padr( cRequest, nTamRequest ) + cSource
		If HRH->( DBSeek( xFilial( "HRH" ) + cSeek ) )
			GRRA050( { xFilial( "SC5" ), cAlias, HRH->HRH_SOURCE, cRequest, xFilial( "HRD" ), HRH->HRH_PLANCD  } )
		EndIf
	EndIf

	IF !Empty( aSvAlias )
		RestArea( aSvAlias )
	EndIf 

	FWFreeArray( aSvAlias )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRSetPaymentMethod
Atualiza a forma de pagamento da fatura na tabela intermediária de acordo com os 
dados passados para pesquisa
@param aSeek, array, vetor com os dados para a pesquisa da chave da 
	requisição, onde: 
		[1] - Filial origem da solicitação
		[2] - Alias da solicitação
		[3] - Código da solicitação		
@param cValue, caracter, conteúdo a ser gravado
@author  philipe.pompeu
@since   13/06/2024
/*/
//-------------------------------------------------------------------
Function GRRSetPaymentMethod( aSeek, cValue )
Return SavePlatInfo( 3, aSeek, cValue )

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRValidPedido
Valida se o pedido que está sendo manipulado, pode realizar a movimentação.
A função foi criada na MATA410 passando o número do pedido, mas atualmente
valida o pedido posicionado na área de trabalho.
@return lRet, lógico, se pedido pode prosseguir com sua movimentação. 
@author  Rodrigo Soares
@since   13/06/2024
/*/
//-------------------------------------------------------------------
Function GRRValidPedido(cNumOrder as character) as logical
	Local aAlias := GetArea()
	Local aHrjAlias := HRH->(GetArea())
	Local lRet := .T.

	IF SC5->C5_LIBEROK == 'S' .and. !FWIsInCallStack( "CancelOrder" ) 

		HRH->( DbSetOrder( 1 ) ) // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE

		IF HRH->( MSSeek( xFilial( "HRH" ) + xFilial( "SC5" ) + 'SC5' + SC5->C5_NUM ) ) .and. !Empty(HRH->HRH_SUBSID)
			Help(" ",1,"GRRVALIDPED",,STR0002, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0003}) //'Pedido GRR Bloqueado' | 'Para movimentar o pedido,realize primeiro o cancelamento da fatura na plataforma GRR'
			lRet := .F.
		EndIf
	EndIf

	IF !Empty( aHrjAlias )
		RestArea( aHrjAlias )
	EndIf 
	IF !Empty( aAlias )
		RestArea( aAlias )
	EndIf 

	aSize(aHrjAlias, 0)
	aHrjAlias := Nil

	aSize(aAlias, 0)
	aAlias := Nil
	
Return lRet


/*User Function TstGRRA050()
	Local aPedido := {}

	RpcSetEnv("T1","D MG 01 ")

	aPedido := { xFilial( "SC5" ), "SC5", "MATA000", "jun002", xFilial( "HRD" ), "000001", "2" }
	GRRA050( aPedido )

	GRRSetSubscriptionId( { aPedido[1], aPedido[2], aPedido[4], aPedido[3] }, 'TESTE' )

Return
*/
