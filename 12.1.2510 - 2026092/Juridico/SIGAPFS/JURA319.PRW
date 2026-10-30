#INCLUDE "JURA319.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA319
Cont. Orcamentario - Doc Entr x CP

@author Victor Hayashi
@since  18/04/2026
/*/
//-------------------------------------------------------------------
Function JURA319()
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) //"Cont. Orc - Doc Entr x CP"
	oBrowse:SetAlias("OID")
	oBrowse:SetLocate()
	JurSetLeg(oBrowse, "OID")
	JurSetBSize(oBrowse)
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Victor Hayashi
@since  18/04/2026
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA319", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA319", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA319", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA319", 0, 5, 0, NIL } ) // "Excluir"
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View do Controle Orcamentario - Doc Entr x CP

@author Victor Hayashi
@since  18/04/2026
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel  := FWLoadModel( "JURA319" )
	Local oStruct := FWFormStruct( 2, "OID" )

	JurSetAgrp( 'OID',, oStruct )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA319_VIEW", oStruct, "OIDMASTER")
	oView:CreateHorizontalBox( "FORMFIELD", 100)
	oView:SetOwnerView( "JURA319_VIEW", "FORMFIELD")
	oView:SetDescription(STR0001) //"Cont. Orc - Doc Entr x CP"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados Cont. Orcamentario - Doc Entr x CP

@author Victor Hayashi
@since  18/04/2026
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStructOID := FWFormStruct(1, "OID")

	//-----------------------------------------
	// Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA319", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields("OIDMASTER", /*cOwner*/, oStructOID, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription(STR0007) // "Modelo de Dados dos Titulos Controle Orcamentario"
	oModel:GetModel("OIDMASTER"):SetDescription(STR0008) // "Cabeçalho do Cont. Orc - Doc Entr x CP"

	oModel:SetPrimaryKey({"OID_FILIAL", "OID_DOC", "OID_SERIE", "OID_FORNEC", "OID_LOJA"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J319IncTit
Função para inclusão das informações dos titulos que são reescritos 
durante o processo de classificação do documento de entrada.

@obs chamada na função A103NFiscal

@author Victor Hayashi
@since  18/04/2026
/*/
//-------------------------------------------------------------------
Function J319IncTit(aColsSE2, nPosDtVenc, nPosValor, nMoeda, nTaxa)
	Local lRet       := .T.
	Local nX         := 0 
	Local oModel     := FWLoadModel("JURA319")
	Local oModelOID  := oModel:GetModel("OIDMASTER")

	OID->(DbSetOrder(1)) // OID_FILIAL+OID_DOC+OID_SERIE+OID_FORNEC+OID_LOJA+OID_PARCEL
	For nX := 1 To Len(aColsSE2)
		If OID->(DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + cValToChar(nX)))
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
		Else
			oModel:SetOperation(MODEL_OPERATION_INSERT)
		EndIf

		oModel:Activate()

		oModelOID:SetValue("OID_FILIAL", SF1->F1_FILIAL)
		oModelOID:SetValue("OID_DOC"   , SF1->F1_DOC)
		oModelOID:SetValue("OID_SERIE" , SF1->F1_SERIE)
		oModelOID:SetValue("OID_FORNEC", SF1->F1_FORNECE)
		oModelOID:SetValue("OID_LOJA"  , SF1->F1_LOJA)
		oModelOID:SetValue("OID_PARCEL", cValToChar(nX))
		oModelOID:SetValue("OID_CNATUR", MaFisRet(,"NF_NATUREZA"))
		oModelOID:SetValue("OID_VENCTO", aColsSE2[nX][nPosDtVenc])
		oModelOID:SetValue("OID_MOEDA" , nMoeda)
		oModelOID:SetValue("OID_COTAC" , nTaxa)
		oModelOID:SetValue("OID_VALOR" , aColsSE2[nX][nPosValor])

		If oModel:VldData()
			oModel:CommitData()
		Else
			lRet := JurMsgErro(oModel:GetErrorMessage()[6])
		EndIf

		oModel:DeActivate()

	Next nX

	oModel:Destroy()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J319DelTit
Função para exclusão das informações dos titulos do documento de 
entrada ao realizar um estorno ou exclusão do documento de entrada.

@obs chamada na função A103AtuSE2

@author Victor Hayashi
@since  18/04/2026
/*/
//-------------------------------------------------------------------
Function J319DelTit()
	Local lRet      := .T.
	Local oModel    := FWLoadModel("JURA319")
	Local lJConOrc  := SuperGetMV("MV_JCONORC",.F.,.F.) .And. SF1->(ColumnPos("F1_JSITLD")) > 0 .And. SF1->(ColumnPos("F1_JHSTLD")) > 0

	If lJConOrc
		OID->(DbSetOrder(1)) // OID_FILIAL, OID_DOC, OID_SERIE, OID_FORNEC, OID_LOJA
		If OID->(DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			If oModel:Activate()
				lRet := oModel:VldData()
				If lRet
					FWFormCommit(oModel)
				EndIf

				oModel:DeActivate()
			EndIf
		EndIf
	EndIf

Return lRet
