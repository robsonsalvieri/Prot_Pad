#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA350.CH"

/*/{Protheus.doc} VEIA350()
Relacionar Cotitulares no Atendimento - SOMENTE ARGENTINA que possui COTITULARES

@author Andre Luis Almeida
@since 02/10/2024
@version 1.0
@return NIL
/*/
Function VEIA350(nOpc,cNumAte)
Local oView
Local nCliTotais := 0
Local aCliTotais := {}
Local cAux       := ""
Local cNamSA1    := ""
Local cFilSA1    := ""
Local cNome      := ""
Local lTela      := .t.
local lRetorno	:= .f.
Private oModel
Private cNCampoVW1 := ""
Private cFiltroSE1 := "" // Filtro do Browse dos SE1
Private aFiltroSE1 := {} // Filtro do Browse dos SE1
VV9->(DbSetOrder(1))
If VV9->(DbSeek( xFilial("VV9") + cNumAte )) .and. cPaisLoc == "ARG"
	If nOpc == 3 .or. nOpc == 4 // Inclusão ou Alteração
		cNCampoVW1 := "VW1_NUMPED/VW1_NUMNFI/VW1_SERNFI/"
	Else
		// TOTAIS por Cliente/Loja //
		aCliTotais := VXI010031_Totais_por_Cliente( VV9->VV9_NUMATE , .f. , .f. , )
		lTela := ( len(aCliTotais) > 1 ) // Mostra tela somente se tiver Cotitulares
		cNamSA1 := RetSQLName("SA1")
		cFilSA1 := xFilial("SA1")
		For nCliTotais := 1 to len(aCliTotais)
			If !Empty(aCliTotais[nCliTotais,6])
				cNome := FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '"+aCliTotais[nCliTotais,1]+"' AND A1_LOJA = '"+aCliTotais[nCliTotais,2]+"' AND D_E_L_E_T_ = ' '")
				aAdd(aFiltroSE1,{aCliTotais[nCliTotais,1]+"-"+aCliTotais[nCliTotais,2]+" "+cNome,;
								"E1_CLIENTE = '"+aCliTotais[nCliTotais,1]+"' AND E1_LOJA = '"+aCliTotais[nCliTotais,2]+"' AND E1_NUM = '"+aCliTotais[nCliTotais,6]+"'"})
				If !Empty(cAux)
					cAux += " OR "
				EndIf
				cAux += "( "+aFiltroSE1[len(aFiltroSE1),2]+" )"
			EndIf
		Next
		If !Empty(cAux) // Filtrar os Titulos do Atendimento
			cFiltroSE1 := "@ ( "+cAux+ " )"
		EndIf
	EndIf
	If lTela
		oView := FWViewExec():New()
		oView:setSource("VEIA350")
		oView:setModal(.F.)
		oView:setTitle(STR0001) // Cotitulares
		If nOpc == 3 .or. nOpc == 4 // Inclusão ou Alteração
			oView:setOperation( MODEL_OPERATION_UPDATE ) // Sempre altera para gravar o Filho VW1
		Else
			oView:setOperation( MODEL_OPERATION_VIEW ) // View
		EndIf
		oView:setReduction(20) // Redução de 20% da tela
		oView:openView(.F.)

		lRetorno := (oView:getButtonPress() == 0)

		oView:DeActivate()

	Else
		MsgAlert(STR0013) // Atendimento não possui Cotitulares
	EndIf
EndIf
Return lRetorno

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 02/10/2024
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.VEIA350' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.VEIA350' OPERATION 4 ACCESS 0 // Alterar
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 02/10/2024
@version 1.0
@Return oModel
/*/
Static Function ModelDef()

Local oStrVV9 := FWFormStruct( 1, "VV9", { |cCampo|  ALLTRIM(cCampo) == "VV9_NUMATE" } )
Local oStrVW1 := FWFormStruct( 1, "VW1")
Local aAuxTrigger := {}

aAuxTrigger := FwStruTrigger("VW1_CODCLI","VW1_NOMCLI","Left(SA1->A1_NOME," + cValToChar(GetSX3Cache("VW1_NOMCLI","X3_TAMANHO")) + ")",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VW1_CODCLI') + FwFldGet('VW1_LOJCLI')","!Empty(FWFldGet('VW1_CODCLI'))")
oStrVW1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
aAuxTrigger := FwStruTrigger("VW1_LOJCLI","VW1_NOMCLI","Left(SA1->A1_NOME," + cValToChar(GetSX3Cache("VW1_NOMCLI","X3_TAMANHO")) + ")",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VW1_CODCLI') + FwFldGet('VW1_LOJCLI')","!Empty(FWFldGet('VW1_LOJCLI'))")
oStrVW1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

oStrVW1:SetProperty("VW1_NUMTRA", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, M->VV9_NUMATE )) // Inicializador Padrão

oModel := MPFormModel():New("VEIA350", /* bPre */ , /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields( 'VV9MASTER', /*cOwner*/, oStrVV9, /* <bPre> */ , /* <bPost> */ , /* <bLoad>  { |oModel| loadCab(oModel) }*/ )
oModel:AddGrid( 'VW1DETAIL', 'VV9MASTER', oStrVW1)
oModel:GetModel('VV9MASTER'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR

oModel:SetDescription(STR0001) // Cotitulares
oModel:GetModel("VW1DETAIL"):SetUniqueLine({"VW1_CODCLI","VW1_LOJCLI"})
oModel:AddRules( 'VW1DETAIL', 'VW1_LOJCLI', 'VW1DETAIL', 'VW1_CODCLI', 3)
oModel:GetModel('VW1DETAIL'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetRelation('VW1DETAIL', { { 'VW1_FILIAL' , 'xFilial("VV9")' } , { 'VW1_NUMTRA' , 'VV9_NUMATE' } }, VW1->( IndexKey(2) ) )
oModel:SetPrimaryKey( { "VW1_FILIAL", "VW1_NUMTRA" , "VW1_CODIGO" } )

oModel:InstallEvent("VEIA350EVDEF", /*cOwner*/, VEIA350EVDEF():New() ) // Eventos do VEIA350

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 02/10/2024
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVW1 := FWFormStruct(2, "VW1", { |cCampo| !ALLTRIM(cCampo) $ "VW1_FILIAL/VW1_CODIGO/VW1_NUMTRA/VW1_PERCEN/VW1_VALTOT/"+cNCampoVW1 } )
//
oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
If !Empty(cFiltroSE1)
	oView:CreateHorizontalBox( 'TELAVW1' , 40 )
	oView:CreateHorizontalBox( 'TELASE1' , 60 )
Else
	oView:CreateHorizontalBox( 'TELAVW1' , 100 )
EndIf
oView:AddUserButton(STR0004,'CLIPS',{ |oView| VA3500011_Posicao_do_Cliente() }) // Posição do Cliente
oView:AddUserButton(STR0005,'CLIPS',{ |oView| VA3500021_Veiculos_do_Cliente() }) // Veiculos/Máquinas do Cliente
oView:AddGrid( 'VIEW_VW1', oStrVW1, 'VW1DETAIL' )
oView:SetOwnerView( "VIEW_VW1" , "TELAVW1" )
If !Empty(cFiltroSE1)
	oView:AddOtherObject("VIEW_SE1", {|oPanel| VA3500031_Visualiza_Titulos(oPanel)})
	oView:SetOwnerView( "VIEW_SE1" , "TELASE1" )
EndIf
//
Return oView

/*/{Protheus.doc} VA3500011_Posicao_do_Cliente
Posição do Cliente 

@author Andre Luis Almeida
@since 04/10/2024
/*/
Function VA3500011_Posicao_do_Cliente()
Local aAreaA1 := sGetArea(,"SA1")
Local oModel  := FWModelActive()
Local oModVW1 := oModel:GetModel("VW1DETAIL")
Local cCodCli := oModVW1:GetValue("VW1_CODCLI")
Local cLojCli := oModVW1:GetValue("VW1_LOJCLI")
//
MaFisSave() // Salva o Fiscal
SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+cCodCli+cLojCli))
FC010CON() // Tela de Consulta -> Posicao do Cliente
MaFisRestore() // Restaura o Fiscal
sRestArea(aAreaA1)
//
Return

/*/{Protheus.doc} VA3500021_Veiculos_do_Cliente
Veiculos do Cliente 

@author Andre Luis Almeida
@since 04/10/2024
/*/
Function VA3500021_Veiculos_do_Cliente()
Local oModel  := FWModelActive()
Local oModVW1 := oModel:GetModel("VW1DETAIL")
Local cCodCli := oModVW1:GetValue("VW1_CODCLI")
Local cLojCli := oModVW1:GetValue("VW1_LOJCLI")
//
VEIVC090(cCodCli,cLojCli,.t.)
//
Return

/*/{Protheus.doc} VA3500031_Visualiza_Titulos
Visualizar Todos os Titulos do Atendimento

@author Andre Luis Almeida
@since 04/10/2024
/*/
Function VA3500031_Visualiza_Titulos(oPanel)
Local nCntFor  := 0
Local aCposSE1 := {'E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_NATUREZ','E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_VENCTO','E1_VENCREA','E1_VALOR','E1_BAIXA','E1_SALDO','E1_NUMNOTA','E1_SERIE'}
//
oBrwSE1 := FwMBrowse():New()
oBrwSE1:SetOwner(oPanel)
oBrwSE1:SetDescription(STR0006) // Titulos do Atendimento referentes aos Cotitulares
oBrwSE1:SetAlias('SE1')
oBrwSE1:SetChgAll(.T.) //nao apresentar a tela para informar a filial
oBrwSE1:SetMenuDef( ' ' )
oBrwSE1:SetFilterDefault(cFiltroSE1)
oBrwSE1:lOptionReport := .f.
oBrwSE1:AddLegend( " SE1->E1_SALDO == SE1->E1_VALOR"                          , 'BR_BRANCO'  , STR0007 ) // Titulos sem Baixa
oBrwSE1:AddLegend( " SE1->E1_SALDO > 0 .and. SE1->E1_SALDO <> SE1->E1_VALOR " , 'BR_AMARELO' , STR0008 ) // Titulos com Baixa Parcial
oBrwSE1:AddLegend( " SE1->E1_SALDO == 0 "                                     , 'BR_VERDE'   , STR0009 ) // Titulos com Baixa Total
For nCntFor := 1 to len(aFiltroSE1)
	oBrwSE1:AddFilter(STR0010+": "+aFiltroSE1[nCntFor,1],"@ "+aFiltroSE1[nCntFor,2],.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar // Cliente
Next
oBrwSE1:SetOnlyFields( aCposSE1 )
oBrwSE1:DisableLocate()
oBrwSE1:DisableDetails()
oBrwSE1:ForceQuitButton(.T.)
oBrwSE1:Activate()
//
Return()

/*/{Protheus.doc} VA3500041_Levanta_Cotitulares
Levanta Cotitulares - VW1

@author Andre Luis Almeida
@since 07/10/2024
/*/
Function VA3500041_Levanta_Cotitulares( cNumAte , lCriarDoAtendimento)
Local aCliTotais := {}

Default lCriarDoAtendimento := .f. // Cria uma linha com dados do Atendimento quando nao for CoTItular

//Conout("VA3500041_Levanta_Cotitulares - " + ProcName(1) + " - " + cValToChar(ProcLine(1) ))
If cPaisLoc == "ARG"
	VW1->(DbSetOrder(2)) // Numero Atendimento
	VW1->(DbSeek( xFilial("VW1") + cNumAte ))
	While !VW1->(Eof()) .and. VW1->VW1_FILIAL == xFilial("VW1") .and. VW1->VW1_NUMTRA == cNumAte

		//Conout("   " + VW1->VW1_CODCLI + "-" + VW1->VW1_LOJCLI + " - " + cvaltochar(VW1->VW1_VALTOT) + " - " + cvaltochar(VW1->VW1_PERCEN))

		aAdd(aCliTotais,{	VW1->VW1_CODCLI,;	// 01-Codigo Cliente
							VW1->VW1_LOJCLI,;	// 02-Loja Cliente
							VW1->VW1_VALTOT,;	// 03-Total para o Cliente
							VW1->VW1_PERCEN,;	// 04-% que corresponde do Valor TOTAL
							VW1->VW1_NUMPED,;	// 05-Pedido
							VW1->VW1_NUMNFI,;	// 06-Nro.Fatura
							VW1->VW1_SERNFI,;	// 07-Serie Fatura
							VW1->VW1_PERVEI,;	// 08-% que corresponde dos veiculos
							{/* VEICULOS */},;	// 09-Veiculos VVA com o devido % para cada cliente
							{/* PARCELAS */},;	// 10-Parcelas VS9 com o devido % para cada cliente
							VW1->(RecNo()),;	 // 11-RecNo do VW1 - Tabela de Percentuais por Cliente/Veiculo
							""})					 // 12-Prefixo do Titulo
		VW1->(dbSkip())
	EndDo
EndIf
if lCriarDoAtendimento .and. len(aCliTotais) == 0
	aAdd(aCliTotais,{	VV9->VV9_CODCLI,; 	// 01-Codigo Cliente
					VV9->VV9_LOJA,;		// 02-Loja Cliente
					VV0->VV0_VALTOT,;	// 03-Total para o Cliente
					100,;				// 04-% que corresponde do Valor TOTAL: 100% (default)
					VV0->VV0_NUMPED,;	// 05-Pedido
					VV0->VV0_NUMNFI,;	// 06-Nro.Fatura
					VV0->VV0_SERNFI,;	// 07-Serie Fatura
					100,;				// 08-% que corresponde dos veiculos: 100% (default)
					{/* VEICULOS */},;	// 09-Veiculos VVA com o devido % para cada cliente
					{/* PARCELAS */},;	// 10-Parcelas VS9 com o devido % para cada cliente
					0,;					// 11-RecNo do VW1 - Tabela de Percentuais por Cliente/Veiculo ( quando não utiliza Cotilares, deve ser 0 )
					""})					// 12-Prefixo do Titulo
endif

//Conout(" ")
Return aClone(aCliTotais)

/*/{Protheus.doc} VA3500051_Gravacao_Totais_por_Clientes
	Gravação da tabela de Percentuais por Cliente VW1
	
	@author Andre Luis Almeida
	@since 07/10/2024
/*/
Function VA3500051_Gravacao_Totais_por_Clientes( aCliTotais , nCliTotais )
If aCliTotais[nCliTotais,11] > 0 .and. cPaisLoc == "ARG"
	DbSelectArea("VW1")
	DbGoTo(aCliTotais[nCliTotais,11])
	RecLock("VW1",.f.)
		VW1->VW1_VALTOT := aCliTotais[nCliTotais,3] // 03-Total para o Cliente
		VW1->VW1_PERCEN := aCliTotais[nCliTotais,4] // 04-% que corresponde do Valor TOTAL
		VW1->VW1_NUMPED := aCliTotais[nCliTotais,5] // Pedido (SC5)
		VW1->VW1_NUMNFI := aCliTotais[nCliTotais,6] // NF (SF2)
		VW1->VW1_SERNFI := aCliTotais[nCliTotais,7] // Serie (SF2)
	MsUnLock()

	//Conout("VA3500051_Gravacao_Totais_por_Clientes - " + ProcName(1) + " - " + cValToChar(ProcLine(1) ) + "   " + VW1->VW1_CODCLI + "-" + VW1->VW1_LOJCLI + " - " + cvaltochar(VW1->VW1_VALTOT) + " - " + cvaltochar(VW1->VW1_PERCEN))
	
	//Conout(" ")
EndIf
Return