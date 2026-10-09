#Include "loca110.ch"
#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} LOCA110
Rotina de Aprovação/Reprovação de Solicitações de Trocas de Produtos
@type function
@version  25.10 
@author Alexandre Circenis
@since 23/04/2026
/*/
Function LOCA110()

LOCAL oBrowse:= FWmBrowse():New()

    oBrowse:SetDescription( STR0001) //"Solicitações de Troca de Produtos"
    oBrowse:SetMenuDef( 'LOCA110' )
    oBrowse:SetAlias( 'FH4' )
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
    oBrowse:OptionReport(.F.)

    oBrowse:AddLegend( "FH4->FH4_STATUS = '1'"      , "GREEN" , STR0002 )  //"Pendente"
	oBrowse:AddLegend( "FH4->FH4_STATUS = '2'"      , "RED"   , STR0003 )  //"Aprovada"
    oBrowse:AddLegend( "FH4->FH4_STATUS = '3'"      , "BLACK" , STR0004 )  //"Reprovada"
  
	oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MENUDEF
Menu Principal da aprovação/reprovação da Solicitação de Troca
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Array com as opçoes do menu
/*/
STATIC FUNCTION MENUDEF()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.LOCA109' OPERATION 2 ACCESS 1  //"Visualizar"
	ADD OPTION aRotina TITLE STR0006 ACTION 'LOCA110PRO' OPERATION 4 ACCESS 2 //"Aprovar"
	ADD OPTION aRotina TITLE STR0007 ACTION 'LOCA110PRO' OPERATION 4 ACCESS 3 //"Reprovar"

Return aRotina
/*/{Protheus.doc} LOCA110PRO
Rotina de preparação do model para aprovação/reprovação da solictação de troca de produtos
@type function
@version 25.10
@author Alexandre Circenis
@since 05/05/2026
@param cAlias, character, Alias da tabela do browse
@param nReg, numeric, Numero do registro posicionado
@param nOpc, numeric, numero do item do array arotina selecionada
@return variant, Retorna .t. por padrão para indicar o final da rotina
/*/
Function LOCA110PRO(cAlias, nReg, nOpc)
Local cOperacao := if( nOpc = 2, STR0006,STR0007) //"Aprovar" //"Reprovar"
Local oExecView
Local aButtons
Local oView as Object


    if FH4->FH4_STATUS <> '1'
       Help(Nil, Nil,"LOCA110_1", Nil,STR0008+cOperacao+STR0009,1,0,) //"A solicitação de troca não está pendente. A operação de " //" não será possivel!"
       Return .T. 
    endif

// Array a ser passado para ParamBox
    oView := FWLoadView("LOCA109")
    if nOpc = 2
	    oView:AddUserButton(STR0006,"OK",{|oView| Loca110APR() },STR0010,,,.T.) //"Aprova a Solicitação de Troca" //"Aprovar"
    else
        oView:AddUserButton(STR0007,"OK",{|oView| Loca110REP() },STR0011,,,.T.) //"Reprova a Solicitação de Troca" //"Reprovar"
    endif
    oView:EnableControlBar(.T.)   
	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
				  {.F.,Nil},{.T.,cOperacao},{.T.,Nil},{.F.,Nil},{.F.,Nil},;
				  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oExecView := FWViewExec():New()
	oExecView:setTitle(cOperacao)  //"Itens Enviados ao Cliente "
	oExecView:setView(oView)
   
	oExecView:setModal(.F.)
	oExecView:SetButtons(aButtons)
	oExecView:setOperation(MODEL_OPERATION_VIEW)
	oExecView:openView(.T.)

Return .T.

/*/{Protheus.doc} LOCA110REP
Seta o status da solicitação de Troca para 3 indicando que foi reprovada
@type function
@version  25.10
@author Alexandre Circenis
@since 05/05/2026
@return variant, retorna .F. para indicar que finalizou a View
/*/
Function LOCA110REP()
Local oView := FWViewActive()

	if MsgNoYes(STR0013,STR0012) //"Reprova Solitação de Troca" //"Confirma a reprovação da solicitção de troca ?"

		RecLock("FH4",.F.)
		FH4->FH4_STATUS := '3'
		msUnlock()

	endif

	oView:ButtonCancelAction()

Return .F.

/*/{Protheus.doc} LOCA110APR
Aprova a solicitação de troca 
Na AS original irá trocar o produto e quantidade 
Se houverem outros item serão geradas nova linha no contrato com quantidade indicada e valor zero
@type function
@version 25.10 
@author Alexandre Circenis
@since 05/05/2026
@return variant, Retorna .F. para indicar final da rotina
/*/
Function LOCA110APR()
Local oView := FWViewActive()
Local oModel := FWModelActive()
Local oFH5Grid := oModel:GetModel("FH5GRID")
Local nX 
Local aFldFPA := FPA->(dbStruct())
Local aFldFQ5 := FQ5->(dbStruct())
Local cFldFPA := "FPA_VLBRUT/FPA_ACRESC/FPA_PDESC/FPA_VRHOR/FPA_PRCUNI/FPA_VRISS" //Não replica os campos da tabela FPA
Local cFldFQ5 := ""
Local aNewFQ5 := {}
Local aNewFPA := {}
Local cQuery := ""
Local nQtdFPA
Local nQtdNew
Local nPosPrc // Posição do Preço Unitario
Local nTrocas := oFH5Grid:Length()
Local nCampos
Local aArea := GetArea()
Local aAreaFH4 := FH4->(GetArea())
Local cMaxFpa  := Criavar("FPA_SEQGRU", .F.)

	FPA->(dbSetorder(3))
	if FPA->(dbSeek(xFilial("FPA")+FH4->FH4_AS))

		aNewFPA := {}
		aBindParam := {}

		cQuery := " SELECT MAX(FPA_SEQGRU) MAXFPA FROM "+RetSqlName("FPA")+ " WHERE D_E_L_E_T_ = ' ' "
		//Obtem o utlimo item de sequencia de itens de inclusão 

		For nX := 1 To Len(aFldFPA)
		
			aadd(aNewFPA , {aFldFPA[nX][01], FPA->(FieldGet( FieldPos(aFldFPA[nX][01])))})
			If ( AllTrim(aFldFPA[nX][01]) == "FPA_QUANT" )
				nPosQtd := nX
				nQtdFPA := aNewFPA[Len(aNewFPA)][02]
			ElseIf ( AllTrim(aFldFPA[nX][01]) == "FPA_PRCUNI" )
				aFldFPA[nX][02] := 0 // Zerar para as proximas trocas
				nPosPrc := nX
				nPrcFPA := aNewFPA[Len(aNewFPA)][02]
			ElseIf ( AllTrim(aFldFPA[nX][01]) == "FPA_PDESC" )
				aFldFPA[nX][02] := 0 // Zerar para as proximas trocas
				nDesFPA := aNewFPA[Len(aNewFPA)][02]
			ElseIf ( AllTrim(aFldFPA[nX][01]) == "FPA_ACRESC" )
				aFldFPA[nX][02] := 0 // Zerar para as proximas trocas
				nAcrFPA := aNewFPA[Len(aNewFPA)][02]
			ElseIf ( AllTrim(aFldFPA[nX][01]) == "FPA_PACRES" )
				aFldFPA[nX][02] := 0 // Zerar para as proximas trocas
				nPAcFPA := aNewFPA[Len(aNewFPA)][02]
			ElseIf ( AllTrim(aFldFPA[nX][01]) == "FPA_VRHOR" )
				aFldFPA[nX][02] := 0 // Zerar para as proximas trocas
			
			EndIf

			Do Case
				Case AllTrim(aFldFPA[nX][01]) == "FPA_FILIAL"
					cFilFPA := FPA->(FieldGet( FieldPos(aFldFPA[nX][01])))
					cQuery += " AND FPA_FILIAL = ? "
					aadd(aBindParam, cFilFPA)
				Case AllTrim(aFldFPA[nX][01]) == "FPA_PROJET"
					cPrjFPA := FPA->(FieldGet( FieldPos(aFldFPA[nX][01])))
					cQuery += " AND FPA_PROJET = ? "
					aadd(aBindParam, cPrjFPA)
				Case AllTrim(aFldFPA[nX][01]) == "FPA_OBRA"
					cObrFPA := FPA->(FieldGet( FieldPos(aFldFPA[nX][01])))
					cQuery += " AND FPA_OBRA = ? "
					aadd(aBindParam, cObrFPA)
				Case AllTrim(aFldFPA[nX][01]) == "FPA_SEQGRU"
					cSeqFPA := FPA->(FieldGet( FieldPos(aFldFPA[nX][01])))
				Case AllTrim(aFldFPA[nX][01]) == "FPA_TIPOSE"
					cTipFPA := FPA->(FieldGet( FieldPos(aFldFPA[nX][01])))
			EndCase
			
		Next


		cQuery := ChangeQuery(cQuery)

		MPSysOpenQuery(cQuery,"FPAMAX",,,aBindParam)

		If FPAMAX->(!Eof())
			cMaxFPA := FPAMAX->MAXFPA
		EndIf

		FPAMAX->(dbCloseArea())

		Begin Transaction

		for nX := 1 to nTrocas

			oFH5Grid:GoLine(nX)
			nQtdNew := oFH5Grid:GetValue("FH5_QTDDES") 
			
			// Se é a primeira linha troca  o produto e quantidade na FPA e FQ5
			If nX = 1

				RecLock("FPA", .F.) //  Troca os produtos
				FPA->FPA_PRODUT := oFH5Grid:GetValue("FH5_DESTIN")

				If nQtdNew <> oFH5Grid:GetValue("FH5_QTDORI")  // Quantidades são diferentes calcular o novo valor unitario
					// Mantem o valor bruto e calcula novo valor unitario
					If FPA->FPA_TPBASE $ "D#H"
						nPrcFPA := ROUND(FPA->FPA_VLBRUT / (FPA->FPA_PREDIA * nQtdNew), GETSX3CACHE("FPA_PRCUNI","X3_DECIMAL")) 
					Else
						nPrcFPA := ROUND(FPA->FPA_VLBRUT / nQtdNew, GETSX3CACHE("FPA_PRCUNI","X3_DECIMAL")) 
					EndIf

					FPA->FPA_QUANT  := nQtdNew
					FPA->FPA_PRCUNI := nPrcFPA
					FPA->FPA_VLBRUT := ROUND(nPrcFPA * nQtdNew, GETSX3CACHE("FPA_VLBRUT","X3_DECIMAL")) 
					FPA->FPA_VRHOR  := ROUND(FPA->FPA_VLBRUT -(FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100)) + FPA->FPA_ACRESC, GETSX3CACHE("FPA_VRHOR","X3_DECIMAL")) 
				
				endif

				FPA->(msUnlock())

				FQ5->(dbSetOrder(9))
				if FQ5->(dbSeek(xFilial("FQ5")+FPA->FPA_AS))

					if nTrocas > 1 // Se tiver mais de uma troca preservar os dados da FQ5

						For nCampos := 1 To Len(aFldFQ5)
							If ( AllTrim(aFldFQ5[nCampos][01]) == "FQ5_FILIAL" ) .or.;
								( AllTrim(aFldFQ5[nCampos][01]) == "FQ5_FILORI" ) .or.;
								( AllTrim(aFldFQ5[nCampos][01]) == "FQ5_SOT" ) .or.;
								( AllTrim(aFldFQ5[nCampos][01]) == "FQ5_GUIND" ) .or.;
								( AllTrim(aFldFQ5[nCampos][01]) == "FQ5_XPROD" ) .or.;
								( AllTrim(aFldFQ5[nCampos][01]) == "FQ5_OBRA" )
								aadd(aNewFQ5 , {aFldFQ5[nCampos][01], FQ5->(FieldGet( FieldPos(aFldFQ5[nCampos][01])))})
							Else
								If !( aFldFQ5[nCampos][01] $ cFldFQ5 )
									aadd(aNewFQ5 , {aFldFQ5[nCampos][01], FQ5->(FieldGet( FieldPos(aFldFQ5[nCampos][01])))})
								EndIf
							EndIf
						Next
					
					endif

					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+oFH5Grid:GetValue("FH5_DESTIN")))

					SB5->(dbSetOrder(1))
					SB5->(dbSeek(xFilial("SB5")+oFH5Grid:GetValue("FH5_DESTIN")))

					RecLock("FQ5", .F.)
					FQ5->FQ5_XPROD := oFH5Grid:GetValue("FH5_DESTIN")
					FQ5->FQ5_XQTD  := nQtdNew
					// Gravar os Campos conforme as conversões cadastradas
					FQ5->FQ5_QTD2 := ConvUm( oFH5Grid:GetValue("FH5_DESTIN"), nQtdNew,0, 2 )
					FQ5->FQ5_PESLIQ := SB1->B1_PESO * nQtdNew
					FQ5->FQ5_PESBRU := SB1->B1_PESBRU * nQtdNew
					FQ5->FQ5_M3 := SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC * nQtdNew

					FQ5->(MsUnlock())

				EndIF
			Else

				//GERANUMAS("31", CPROJETO, FQ7->FQ7_OBRA, FQ7->FQ7_SEQGUI, FQ7->FQ7_FILIAL)
				cNasFPA := GERANUMAS( "30", cPrjFPA, cObrFPA, cSeqFPA, cFilFPA )
				nQtdNew := oFH5Grid:GetValue("FH5_QTDDES") 

				While .T.
					cViagem := GETSX8NUM("FQ5", "FQ5_VIAGEM" )
					CONFIRMSX8()
					FQ5->(dbSetOrder(1))
					If !FQ5->(dbSeek(xFilial("FQ5")+cViagem))
						Exit
					EndIf
				enddo

				//Gerar novo registro da FPA para os demais itens da troca
				RecLock("FPA", .T.)
				For nCampos := 1 To Len(aNewFPA)
					If ( AllTrim(aNewFPA[nCampos][01]) == "FPA_FILIAL" ) .or.;
							( AllTrim(aNewFPA[nCampos][01]) == "FPA_PROJET" ) .or.;
							( AllTrim(aNewFPA[nCampos][01]) == "FPA_OBRA" ) .or.;
							( AllTrim(aNewFPA[nCampos][01]) == "FPA_TIPOSE" )
						FPA->(FieldPut( FieldPos(aNewFPA[nCampos][01]), aNewFPA[nCampos][02]))
					ElseIf ( AllTrim(aNewFPA[nCampos][01]) == "FPA_SEQGRU" )
						FPA->FPA_SEQGRU := Soma1(cMaxFPA)
					ElseIf ( AllTrim(aNewFPA[nCampos][01]) == "FPA_AS" )
						FPA->(FieldPut( FieldPos(aNewFPA[nCampos][01]) , cNasFPA))
					ElseIf ( AllTrim(aNewFPA[nCampos][01]) == "FPA_PRODUT" )
						FPA->(FieldPut( FieldPos(aNewFPA[nCampos][01]) ,  oFH5Grid:GetValue("FH5_DESTIN") ))
					ElseIf ( AllTrim(aNewFPA[nCampos][01]) == "FPA_QUANT" )
						FPA->(FieldPut( FieldPos(aNewFPA[nCampos][01]) ,  nQtdNew ))
					ElseIf ( AllTrim(aNewFPA[nCampos][01]) == "FPA_VIAGEM" )
						FPA->(FieldPut( FieldPos(aNewFPA[nCampos][01]) ,  cViagem ))
					Else
						If !( Alltrim(aNewFPA[nCampos][01]) $ cFldFPA )
							FPA->(FieldPut( FieldPos(aNewFPA[nCampos][01]), aNewFPA[nCampos][02]))
						EndIf
					EndIf
				Next
				FPA->(MsUnlock())

			
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+oFH5Grid:GetValue("FH5_DESTIN")))

				SB5->(dbSetOrder(1))
				SB5->(dbSeek(xFilial("SB5")+oFH5Grid:GetValue("FH5_DESTIN")))

				//Gerar novo registro da FQ5 - nova viagem para o novo FPA
				RecLock("FQ5", .T.)

				For nCampos:= 1 To Len(aNewFQ5)
					FQ5->(FieldPut( FieldPos(aNewFQ5[nCampos][01]), aNewFQ5[nCampos][02]))
				Next

				// Gravar os Campos conforme as conversões cadastradas
				FQ5->FQ5_XPROD  := oFH5Grid:GetValue("FH5_DESTIN")
				FQ5->FQ5_XQTD   := nQtdNew
				FQ5->FQ5_AS     := cNasFPA
				FQ5->FQ5_VIAGEM := cViagem
				FQ5->FQ5_QTD2   := ConvUm( oFH5Grid:GetValue("FH5_DESTIN"), nQtdNew ,0, 2 )
				FQ5->FQ5_PESLIQ := SB1->B1_PESO * nQtdNew 
				FQ5->FQ5_PESBRU := SB1->B1_PESBRU * nQtdNew 
				FQ5->FQ5_M3     := SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC * nQtdNew 

				FQ5->(MsUnlock())

			endif

		next nX

		RestArea(aAreaFH4)
		RecLock("FH4", .F.)
		FH4->FH4_STATUS := '2'
		FH4->(MsUnlock())

		End Transaction
	endif

	oView:ButtonCancelAction()
	RestArea(aArea)

Return .F.
