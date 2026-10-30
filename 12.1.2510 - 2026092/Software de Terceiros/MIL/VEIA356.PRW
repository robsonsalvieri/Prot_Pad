#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA356.CH"

/*/{Protheus.doc} VEIA356
	MVC - Registros de Cotitulares na Entrada de Usados - ARGENTINA - VWM

	@author Andre Luis Almeida
	@since 23/07/2026
/*/
Function VEIA356()
Return

Static Function MenuDef()
Local aRotina := {}
Return aRotina

Static Function ModelDef()
Local oStrVWM := FWFormStruct(1,"VWM")
oModel := MPFormModel():New("VEIA356", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VWMMASTER",/*cOwner*/ , oStrVWM)
oModel:GetModel("VWMMASTER"):SetDescription(STR0001) // Registros de Cotitulares na Entrada de Usados
oModel:SetDescription(STR0001) // Registros de Cotitulares na Entrada de Usados
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 23/07/2026
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVWM:= FWFormStruct(2,"VWM")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField('VIEW_VWM', oStrVWM, 'VWMMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView( 'VIEW_VWM' , 'CABEC' ) // Registros de Cotitulares na Entrada de Usados

Return oView

/*/{Protheus.doc} VA3560011_Tela_selecionar_Faturas
Tela para Selecionar Faturas de Entrada dos Cotitulares que estão relacionadas ao Veiculo da Entrada por Compra

@author Andre Luis Almeida
@since 23/07/2026
/*/
Function VA3560011_Tela_selecionar_Faturas( cVVF_TRACPA , aVeiUsu )
Local lRet     := .f.
Local nCntFor  := 0
Local nCntAux  := 0
Local aVWM     := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aNewBot  := {{"Analitic" ,{|| VA3560051_Legenda_Tela() },STR0002}} // Legenda
Private oPrinc := LoadBitmap( GetResources(), "AVGOIC1" ) // 1 - Principal ( mesmo Fornecedor do Remito de Entrada )
Private oCotit := LoadBitmap( GetResources(), "LBTIK" )   // 2 - Cotitulares 
Private oNo    := LoadBitmap( GetResources(), "LBNO" )    // 0 - Nao selecionado
Private aTitChassi := {}
Private aFatChassi := {}
Private cCadastro := STR0003 // Selecionar Faturas de Entrada dos Cotitulares

For nCntFor := 1 to len(aVeiUsu)
	aAdd(aTitChassi,Alltrim(aVeiUsu[nCntFor,1]))
	aAdd(aFatChassi,aClone(aVeiUsu[nCntFor,2]))
Next

For nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.9)
Next

DEFINE MSDIALOG oVEIA356Fat From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE STR0004 of oMainWnd PIXEL // Entrada de Veiculos/Máquinas Usados
	oFolder := TFolder():New(01,01,aTitChassi,{}, oVEIA356Fat,,,,.t.,.f.,100,100) 
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	For nCntFor := 1 to len(oFolder:aDialogs)
		&("oLbFat" + AllTrim(Str(nCntFor))) := TWBrowse():New(1,1,1,1,,,,oFolder:aDialogs[nCntFor],,,,,{ || VA3560021_Tik() },,,,,,,.F.,,.T.,,.F.,,,)
		&("oLbFat" + AllTrim(Str(nCntFor))):nAT := 1
		&("oLbFat" + AllTrim(Str(nCntFor))):SetArray(&("aFatChassi["+AllTrim(Str(nCntFor))+"]"))
		&("oLbFat" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( "" , &("{ || IIf(aFatChassi["+AllTrim(Str(nCntFor))+",oLbFat"+AllTrim(Str(nCntFor))+":nAt,7]=='1',oPrinc,IIf(aFatChassi["+AllTrim(Str(nCntFor))+",oLbFat"+AllTrim(Str(nCntFor))+":nAt,7]=='2',oCotit,oNo)) }"),,,,"LEFT" ,08,.T.,.F.,,,,.F.,) )
		&("oLbFat" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( STR0005 , &("{ || Transform(aFatChassi["+AllTrim(Str(nCntFor))+",oLbFat"+AllTrim(Str(nCntFor))+":nAt,1],'@D') }"),,,,"LEFT" , 45,.F.,.F.,,,,.F.,) )	// Data
		&("oLbFat" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( STR0006 , &("{ || aFatChassi["+AllTrim(Str(nCntFor))+",oLbFat"+AllTrim(Str(nCntFor))+":nAt,2] }")                ,,,,"LEFT" , 70,.F.,.F.,,,,.F.,) )	// Documento
		&("oLbFat" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( STR0007 , &("{ || aFatChassi["+AllTrim(Str(nCntFor))+",oLbFat"+AllTrim(Str(nCntFor))+":nAt,3] }")                ,,,,"LEFT" , 35,.F.,.F.,,,,.F.,) )	// Serie
		&("oLbFat" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( STR0008 , &("{ || aFatChassi["+AllTrim(Str(nCntFor))+",oLbFat"+AllTrim(Str(nCntFor))+":nAt,4] }")                ,,,,"LEFT" , 50,.F.,.F.,,,,.F.,) )	// Fornecedor
		&("oLbFat" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( STR0009 , &("{ || aFatChassi["+AllTrim(Str(nCntFor))+",oLbFat"+AllTrim(Str(nCntFor))+":nAt,5] }")                ,,,,"LEFT" , 30,.F.,.F.,,,,.F.,) )	// Loja
		&("oLbFat" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( STR0010 , &("{ || aFatChassi["+AllTrim(Str(nCntFor))+",oLbFat"+AllTrim(Str(nCntFor))+":nAt,6] }")                ,,,,"LEFT" ,160,.F.,.F.,,,,.F.,) )	// Nome
		&("oLbFat" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( STR0011 , &("{ || IIf(aFatChassi["+AllTrim(Str(nCntFor))+",oLbFat"+AllTrim(Str(nCntFor))+":nAt,8]=='1','"+STR0012+"','') }"),,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )	// Observação / Mesmo Fornecedor do Remito de Entrada
		&("oLbFat" + AllTrim(Str(nCntFor))):Align := CONTROL_ALIGN_ALLCLIENT
		&("oLbFat" + AllTrim(Str(nCntFor))):Refresh()
	Next
ACTIVATE MSDIALOG oVEIA356Fat CENTER ON INIT EnchoiceBar(oVEIA356Fat,{|| IIf( VA3560061_TudoOk_Tela() , ( lRet:=.t. , oVEIA356Fat:End() ) , .t. ) },{|| oVEIA356Fat:End() } ,, aNewBot )

If lRet // Ok Tela
	VVF->(DbSetOrder(1))
	VVF->(DbSeek(xFilial("VVF")+cVVF_TRACPA))
	For nCntFor := 1 to len(aVeiUsu)
		aVeiUsu[nCntFor,2] := aClone(aFatChassi[nCntFor])
		For nCntAux := 1 to len(aVeiUsu[nCntFor,2])
			If !Empty(aVeiUsu[nCntFor,2,nCntAux,7]) .and. aVeiUsu[nCntFor,2,nCntAux,7] $ "1/2"
				aVWM := {}
				aAdd(aVWM,{ "VWM_TRACPA" , cVVF_TRACPA })
				aAdd(aVWM,{ "VWM_PRINCI" , aVeiUsu[nCntFor,2,nCntAux,7] })
				aAdd(aVWM,{ "VWM_NUMNFI" , aVeiUsu[nCntFor,2,nCntAux,2] })
				aAdd(aVWM,{ "VWM_SERNFI" , aVeiUsu[nCntFor,2,nCntAux,3] })
				aAdd(aVWM,{ "VWM_CODFOR" , aVeiUsu[nCntFor,2,nCntAux,4] })
				aAdd(aVWM,{ "VWM_LOJFOR" , aVeiUsu[nCntFor,2,nCntAux,5] })
				VA3560031_MVC_INC_VWM( aVWM ) // Inclusão do VWM
			EndIf
			If aVeiUsu[nCntFor,2,nCntAux,7] == "1" .and. Empty(VVF->VVF_NUMNFI) // Principal
				DbSelectArea("VVF")
				RecLock("VVF",.f.)
					VVF->VVF_NUMNFI := aVeiUsu[nCntFor,2,nCntAux,2] // DOC
					VVF->VVF_SERNFI := aVeiUsu[nCntFor,2,nCntAux,3] // SERIE
					VVF->VVF_ESPECI := aVeiUsu[nCntFor,2,nCntAux,9] // ESPECIE
					VVF->VVF_TPFATR := "3" // Fatura com Remito
				MsUnLock()
			EndIf
		Next
	Next
EndIf

Return lRet

/*/{Protheus.doc} VA3560021_Tik
Tik ListBox

@author Andre Luis Almeida
@since 23/07/2026
/*/
Static Function VA3560021_Tik()
Local nAba := oFolder:nOption
Local cAtu := &("aFatChassi["+Alltrim(str(nAba))+",oLbFat"+AllTrim(Str(nAba))+":nAt,7]")
Local cOld := &("aFatChassi["+Alltrim(str(nAba))+",oLbFat"+AllTrim(Str(nAba))+":nAt,8]")
Local cNew := IIf(cAtu=="0",cOld,"0")
&("aFatChassi["+Alltrim(str(nAba))+",oLbFat"+AllTrim(Str(nAba))+":nAt,7]") := cNew
&("oLbFat"+AllTrim(Str(nAba))+":Refresh()")
Return

/*/{Protheus.doc} VA3560031_MVC_INC_VWM
Inclusão do VWM - Cotitulares Entrada de Usados

@author Andre Luis Almeida
@since 23/07/2026
/*/
Function VA3560031_MVC_INC_VWM( aVWM )
Local lRet      := .t.
Local oModelVWM := FWLoadModel( 'VEIA356' ) // VWM
Local nRecVWM   := 0
Local nCntFor   := 0
oModelVWM:SetOperation( MODEL_OPERATION_INSERT ) // Inclusão
If oModelVWM:Activate()
	For nCntFor := 1 to len(aVWM)
		oModelVWM:SetValue( "VWMMASTER" , aVWM[nCntFor,1] , aVWM[nCntFor,2]              ) // Campos variaveis
	Next
	If ( lRet := oModelVWM:VldData() )
		if ( lRet := oModelVWM:CommitData() )
		EndIf
	EndIf
	oModelVWM:DeActivate()
	If lRet
		nRecVWM := VWM->(RecNo())
	EndIf
EndIf
Return nRecVWM

/*/{Protheus.doc} VA3560041_MVC_DEL_VWM
Deleção do VWM - Cotitulares Entrada de Usados

@author Andre Luis Almeida
@since 23/07/2026
/*/
Function VA3560041_MVC_DEL_VWM( nRecVWM )
Local lRet      := .f.
Local oModelVWM := FWLoadModel( 'VEIA356' ) // VWM
VWM->(DbGoto(nRecVWM))
oModelVWM:SetOperation( MODEL_OPERATION_DELETE )
If oModelVWM:Activate()
	lRet := oModelVWM:CommitData()
	oModelVWM:DeActivate()
EndIf
Return lRet

/*/{Protheus.doc} VA3560051_Legenda_Tela
Legenda da Tela de Selecionar Faturas de Entrada dos Cotitulares

@author Andre Luis Almeida
@since 24/07/2026
/*/
Function VA3560051_Legenda_Tela()
Local aLegenda := {	{'LBNO'   ,STR0014},; // Faturas não selecionadas
					{'AVGOIC1',STR0015},; // Faturas selecionadas do mesmo Fornecedor do Remito
					{'LBTIK'  ,STR0016} } // Faturas selecionadas dos demais Cotitulares
BrwLegenda(STR0013,"",aLegenda) // Faturas de Entrada - Legenda
Return

/*/{Protheus.doc} VA3560061_TudoOk_Tela
TudoOk da Tela de Selecionar Faturas de Entrada dos Cotitulares

@author Andre Luis Almeida
@since 26/07/2026
/*/
Function VA3560061_TudoOk_Tela()
Local lRet    := .t.
Local nCntFor := 0
Local nCntAux := 0
Local nSelPrinc := 0
Local nSelCotit := 0
For nCntFor := 1 to len(aFatChassi) // CHASSI's (Folders)
	nSelPrinc := 0
	nSelCotit := 0
	For nCntAux := 1 to len(aFatChassi[nCntFor]) // Linhas ( Faturas )
		nSelPrinc += IIf(aFatChassi[nCntFor,nCntAux,7]=="1",1,0)
		nSelCotit += IIf(aFatChassi[nCntFor,nCntAux,7]=="2",1,0)
	Next
	If ( nSelPrinc < 1 ) // Necessário selecionar no minimo uma Fatura do Titular ( mesmo Fornecedor do Remito de Entrada )
		FMX_HELP("VEIA356_ERR001",aTitChassi[nCntFor],STR0017)  // Necessário selecionar no minimo uma Fatura do Titular ( mesmo Fornecedor do Remito de Entrada )
		lRet := .f.
		Exit
	EndIf
	If ( nSelCotit < 1 ) // Necessário selecionar no minimo uma Fatura dos demais Cotitulares
		FMX_HELP("VEIA356_ERR002",aTitChassi[nCntFor],STR0018)  // Necessário selecionar no minimo uma Fatura dos demais Cotitulares
		lRet := .f.
		Exit
	EndIf
Next
Return lRet

/*/{Protheus.doc} VA3560071_Limpa_relacionamento_VWM
Limpa o Relacionamento com o VWM - Cotitulares na Entrada por Compra de Usados

@author Andre Luis Almeida
@since 04/08/2026
/*/
Function VA3560071_Limpa_relacionamento_VWM( cVVF_TRACPA , lMsg )
Local nCntFor   := 0
Local cQuery    := ""
Local aExcVWM   := {}
Default lMsg    := .f.
DbSelectArea("VWM")
DbSetOrder(2)
If DbSeek( xFilial("VWM") + cVVF_TRACPA )
	If lMsg .and. !MsgYesNo(STR0020,STR0019) // Deseja cancelar o Vinculo dos Cotitulares de Usados? / Atenção
		Return
	EndIf
	While !VWM->(Eof()) .and. xFilial("VWM") == VWM->VWM_FILIAL .and. VWM->VWM_TRACPA == cVVF_TRACPA
		aAdd( aExcVWM , VWM->(RecNo()) )
		VWM->(DbSkip())
	EndDo
	For nCntFor := 1 to len(aExcVWM)
		VA3560041_MVC_DEL_VWM( aExcVWM[nCntFor] )
	Next
	DbSelectArea("VWM")
	DbSetOrder(2)
	If !DbSeek( xFilial("VWM") + cVVF_TRACPA ) // Caso não exista mais o Relacionamento
		DbSelectArea("VVF")
		DbSetOrder(1)
		If DbSeek( xFilial("VVF") + cVVF_TRACPA )
			cQuery := "SELECT F1_ESPECIE "
			cQuery += "  FROM " + RetSQLName("SF1")
			cQuery += " WHERE F1_FILIAL  = '" + xFilial("SF1")  + "'"
			cQuery += "   AND F1_DOC     = '" + VVF->VVF_REMITO + "'"
			cQuery += "   AND F1_SERIE   = '" + VVF->VVF_SERREM + "'"
			cQuery += "   AND F1_FORNECE = '" + VVF->VVF_CODFOR + "'"
			cQuery += "   AND F1_LOJA    = '" + VVF->VVF_LOJA   + "'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			DbSelectArea("VVF") // Volta o VVF como estava anterior ao relacionamento
			RecLock("VVF",.f.)
				VVF->VVF_NUMNFI := "" // DOC
				VVF->VVF_SERNFI := "" // SERIE
				VVF->VVF_ESPECI := FM_SQL(cQuery)
				VVF->VVF_TPFATR := "2" // Remito
			VVF->(MsUnLock())
			If lMsg
				oBrowse:Refresh()
				oBrwVWM:Refresh()
				MsgInfo(STR0021,STR0019) // Vinculo cancelado com sucesso! / Atenção
			EndIf
		EndIf
	EndIf
EndIf
Return