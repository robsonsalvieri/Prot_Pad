#Include 'TOTVS.ch'
#Include 'FWMVCDef.ch'
#Include 'MATA600EST.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA600EST
Classe utilizada para validações de Estoque no MATA600
@author Squad Entradas
@since 25/02/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Class MATA600EST FROM FWModelEvent

	Public Data lEstNeg
	Public Data lRastro
	Public Data lLocaliz
	Public Data lLotVenc
	Public Data lUsaSB8
	Public Data lUsaSBF
	Public Data lFechto
	Public Data cLocaliz
	Public Data cNumSeri
	Public Data cLoteCtl
	Public Data cNumLote
	Public Data nPotenci
	Public Data dDtValid
	Public Data cTipoNF
	Public Data lPotenci

	Method New() CONSTRUCTOR
	Method ModelPosVld()
	Method GridLinePreVld()
	Method GridLinePosVld()
	Method FieldPreVld()
	Method validaQtdEstoque()
	Method atualizaCamposdoGrid()
	Method tesAtualizaEstoque()
	Method validaSaldoEndereco()
	Method vldSaldoLote()
	Method limpaCampos()
	Method vldSaldoEstoque()
	Method resetPropriedades()
	Method setFieldsEditable()

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Instancia a classe
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class MATA600EST

	//Propriedades de controle
	::lEstNeg  	 := .F.
	::lRastro  	 := .F.
	::lLocaliz 	 := .F.
	::lLotVenc 	 := .F.
	::lUsaSB8  	 := .F.
	::lUsaSBF  	 := .F.
	::lFechto  	 := .F.
	::lPotenci	 := X3Usado("D2_POTENCI")

	//Propriedades para gatilho de lote/endereço via F4
	::cLocaliz := ""
	::cNumSeri := ""
	::cLoteCtl := ""
	::cNumLote := ""
	::dDtValid := sTod("")
	::nPotenci := 0
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class MATA600EST
	Local lRet 	      := .T.
	Local lAtuEst	  := .F.
	Local nX   		  := 0
	Local dDataFec
	Local dDataMov
	Local oSubModel
	Local oMdlSD2	  := oModel:GetModel("CABMASTER")
	Local cF2_TPCOMPL := oMdlSD2:GetValue("F2_TPCOMPL")
	
	If oModel:GetOperation() == 5
		If cF2_TPCOMPL == "7"
			dDataFec  := MVUlmes()
			oSubModel := oModel:GetModel("ITENSDETAIL")
			dDataMov  := oMdlSD2:GetValue("F2_EMISSAO")

			// Verifica calendário contábil
			For nX := 1 to oSubModel:Length()
				oSubModel:GoLine(nX)
				If ::tesAtualizaEstoque(oSubModel:GetValue("D2_TES"))
					lRet 	:= (CtbValiDt(Nil,dDataMov,.T.,Nil,Nil,{"EST001"}))
					lAtuEst := .T.
					Exit
				EndIf
			Next nX

			// Valida se a nota pode ser excluída. Não permite exclusão caso 
			// a tes atualize estoque e esteja dentro de um período fechado.
			If lRet .And. lAtuEst .And. dDataFec >= dDataMov
				Help(" ", 1,"FECHTO")
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method GridLinePreVld(oModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class MATA600EST
	Local cTes	  	  := ""
	Local cSeek	  	  := ""
	Local lRet 	  	  := .T.
	Local lAtuEst 	  := .F.
	Local cF2_TPCOMPL := oModelNCND:GetModel("CABMASTER"):GetValue("F2_TPCOMPL")

	If cF2_TPCOMPL == "7"
		// Valições acionadas ao clicar em um campo do grid
		If cModelID == "ITENSDETAIL"
			If cAction == "SETVALUE"
				If cID == "D2_COD"
					//Altera o when dos campos de lote/endereço ao alterar o produto
					::setFieldsEditable()
					
					// Limpa os campos de rastro e endereço ao trocar o produto
					If !Empty(xValue) .And. xValue <> xCurrentValue
						::limpaCampos(oModel)
					EndIf
				ElseIf cId == "D2_QUANT" .Or. cId == "D2_QTSEGUM"
					//Valida a quantidade digitada quando não permitir saldo negativo
					lRet := ::validaQtdEstoque(oModel,nLine,cId,xValue)
				ElseIf cId == "D2_TES"
					If ReadVar() == "M->D2_COD"
						Return .T.
					EndIf
					If !Empty(xValue) .And. xValue <> xCurrentValue
						cTes    := xValue
						lAtuEst := ::tesAtualizaEstoque(cTes)

						//Altera o when dos campos de lote/endereço ao alterar a tes
						::setFieldsEditable()
						
						//Limpa os campos de lote/endereço ao trocar de uma tes
						//que atualiza estoque para uma que nao atualiza
						If !Empty(xCurrentValue)
							If lAtuEst <> ::tesAtualizaEstoque(xCurrentValue)
								::limpaCampos(oModel)
							EndIf
						EndIf
						
						If lAtuEst
							//Nao permite a inclusao de notas que atualizam estoque em períodos fechados
							If ::lFechto
								lRet := .F.
								Help(" ",1,"FECHTO")
							EndIf

							//Atualiza o when dos campos de lote e endereço
							If lRet
								If ::lLocaliz .And. Localiza(oModel:GetValue("D2_COD"))
									::lUsaSBF := .T.
								EndIf
								If ::lRastro .And. Rastro(oModel:GetValue("D2_COD"))
									::lUsaSB8 := .T.
								EndIf
							EndIf
						EndIf
					EndIf
				ElseIf cId == "D2_LOCALIZ" .Or. cId == "D2_NUMSERI"
					//Gatilha os campos de localização/rastro ao selecionar o endereço/num.serie pelo F4
					::atualizaCamposdoGrid(oModel,.T.,.F.,xValue,cId)
				ElseIf cId == "D2_LOTECTL" .Or. cId == "D2_NUMLOTE"
					If !Empty(xValue)
						SB8->(DbSetOrder(3))
						If cId == "D2_LOTECTL"
							If !Empty(::cNumLote)
								cSeek := FWxFilial("SB8")+oModel:GetValue("D2_COD")+oModel:GetValue("D2_LOCAL")+xValue+::cNumLote
							Else
								cSeek := FWxFilial("SB8")+oModel:GetValue("D2_COD")+oModel:GetValue("D2_LOCAL")+xValue
							EndIf
						Else
							If !Empty(::cLoteCtl)
								cSeek := FWxFilial("SB8")+oModel:GetValue("D2_COD")+oModel:GetValue("D2_LOCAL")+::cLoteCtl+xValue
							Else
								cSeek := FWxFilial("SB8")+oModel:GetValue("D2_COD")+oModel:GetValue("D2_LOCAL")+oModel:GetValue("D2_LOTECTL")+xValue
							EndIf
						EndIf
						
						If !SB8->(DbSeek(cSeek))
							Help(" ",1,"A240LOTENE")
							lRet := .F.
						EndIf

						If lRet
							//Gatilha os campos de localização/rastro ao selecionar o endereço/num.serie pelo F4
							lRet := ::atualizaCamposdoGrid(oModel,.F.,.T.,xValue,cId)
						EndIf
					EndIf
				EndIf
			ElseIf cAction == "CANSETVALUE"
				If cId == "D2_LOCALIZ" .Or. cId == "D2_NUMSERI" .Or. cId == "D2_LOTECTL" .Or. cId == "D2_NUMLOTE"
					//Limpa as propriedades utilizadas nos gatilhos F4
					::resetPropriedades()
					
					//Valida se os campos poderão ser alterados
					If ::tesAtualizaEstoque(oModel:GetValue("D2_TES"))
						If cId == "D2_LOCALIZ" .Or. cId == "D2_NUMSERI"
							If !::lUsaSBF .And. (!Empty(oModel:GetValue("D2_LOCALIZ")) .Or. !Empty(oModel:GetValue("D2_NUMSERI")))
								::lUsaSBF := .T.
							EndIf
						Else
							If !::lUsaSB8 .And. (!Empty(oModel:GetValue("D2_LOTECTL")) .Or. !Empty(oModel:GetValue("D2_NUMLOTE")))
								::lUsaSB8 := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method GridLinePosVld(oModel, cModelID, nLine) Class MATA600EST
	Local lRet 	   	  := .T.
	Local nX	   	  := 0
	Local nQtdLine 	  := 0
	Local nHdl 	   	  := 0
	Local cCod	   	  := ""
	Local cLocal   	  := ""
	Local cChave   	  := ""
	Local cLocaliz 	  := ""
	Local cNumSeri 	  := ""
	Local cLoteCtl 	  := ""
	Local cNumLote 	  := ""
	Local cF2_TPCOMPL := oModelNCND:GetModel("CABMASTER"):GetValue("F2_TPCOMPL")
	Local oProduto
	Local oSubModel

	If cF2_TPCOMPL == "7"
		// Validações de linha do grid
		If cModelID == "ITENSDETAIL"
			If ::tesAtualizaEstoque(oModel:GetValue("D2_TES"))
				//Inicializa as variáveis caso o 
				cCod     := oModel:GetValue("D2_COD")
				cLocal 	 := oModel:GetValue("D2_LOCAL")
				nQtdLine := oModel:GetValue("D2_QUANT") 
				If ::lLocaliz
					cLocaliz := oModel:GetValue("D2_LOCALIZ")
					cNumSeri := oModel:GetValue("D2_NUMSERI")
				EndIf

				// Retorna se o produto está bloqueado para inventário
				If BlqInvent(cCod,cLocal,,cLocaliz)
					Help(" ",1,"BLQINVENT",,Alltrim(cCod)+OemToAnsi(STR0002)+AllTrim(cLocal),1,11)
					lRet := .F.
				EndIf

				If lRet
					//Validacao de permissao do armazem
					lRet := MaAvalPerm(3,{cLocal,cCod})
				EndIf

				If lRet
					// Verifica se o saldo do armazem esta liberado
					lRet := SldBlqSB2(cCod,cLocal)
				EndIf

				If lRet
					// Verifica calendário contábil 
					lRet := (CtbValiDt(Nil,dDataBase,.T.,Nil,Nil,{"EST001"}))
				EndIf

				//Valida se o produto possui saldo em estoque para atender a requisição
				If lRet
					lRet := ::vldSaldoEstoque(oModel,cCod,cLocal,nQtdLine,nLine)
				EndIf

				// Valida se o lote possui saldo em estoque para atender a requisição
				If lRet
					If ::lRastro .And. Rastro(cCod)
						lRet := ::vldSaldoLote(oModel,cCod,cLocal,nQtdLine,nLine)
					EndIf
				EndIf

				// Valida se o endereço possui saldo em estoque para atender a requisição
				If lRet 
					If ::lLocaliz .And. Localiza(cCod)
						lRet := ::validaSaldoEndereco(oModel,cCod,cLocal,nQtdLine,nLine,cLocaliz,cNumSeri)
					EndIf
				EndIf

				If lRet
					::lUsaSB8 := ::lUsaSBF := .F.
				EndIf
			EndIf
		// Validações ao confirmar a inclusão da nota
		ElseIf cModelID == "TOTAIS"
			oSubModel := oModelNCND:GetModel("ITENSDETAIL")
			oProduto  := JsonObject():New()
			nHdl 	  := GetFocus()
			For nX := 1 to oSubModel:Length()
				oSubModel:GoLine(nX)
				If ::tesAtualizaEstoque(oSubModel:GetValue("D2_TES"))
					cCod   	 := oSubModel:GetValue("D2_COD")
					cLocal 	 := oSubModel:GetValue("D2_LOCAL")
					nQtdLine := oSubModel:GetValue("D2_QUANT")
					cChave := cCod+cLocal
					If ::lLocaliz .And. Localiza(cCod)
						cLocaliz := oSubModel:GetValue("D2_LOCALIZ")
						cNumSeri := oSubModel:GetValue("D2_NUMSERI")
						cChave   += cLocaliz+cNumSeri
					EndIf
					If ::lRastro .And. Rastro(cCod)
						cLoteCtl := oSubModel:GetValue("D2_LOTECTL")
						cNumLote := oSubModel:GetValue("D2_NUMLOTE")
						cChave   += cLoteCtl+cNumLote
					EndIf
					lRet := oProduto[cChave]
					If lRet == Nil
						If !::vldSaldoEstoque(oSubModel,cCod,cLocal,nQtdLine,oSubModel:nLine)
							Return .F.
						EndIf

						If ::lRastro .And. Rastro(cCod)
							If !::vldSaldoLote(oSubModel,cCod,cLocal,nQtdLine,oSubModel:nLine,cLoteCtl,cNumLote)
								Return .F.
							EndIf
						EndIf

						If ::lLocaliz .And. Localiza(cCod)
							If !::validaSaldoEndereco(oSubModel,cCod,cLocal,nQtdLine,oSubModel:nLine,cLocaliz,cNumSeri)
								Return .F.
							EndIf
						EndIf
						oProduto[cChave] := .T.
						cLocaliz := cNumSeri := cLoteCtl := cNumLote := ""
					EndIf
				EndIf
			Next nX
			oSubModel:GoLine(nLine)
			SetFocus(nHdl)
		EndIf
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class MATA600EST
	Local dDataFec

	// Atualiza a propriedade lFechto para indicar se podem ser inclusos
	// movimentos que atualizam estoque
	If cModelID == "CABMASTER"
		If cAction == "SETVALUE"
			If cID == "F2_TPCOMPL"
				If xValue == "7"
					dDataFec  := MVUlmes()
					// Atualiza as propriedades quando selecionado um tipo de 
					// nota que pode atualizar estoque
					::lEstNeg  := SuperGetMV("MV_ESTNEG" ,.F.,"N") == "S"
					::lRastro  := SuperGetMV("MV_RASTRO" ,.F.,"N") == "S"
					::lLotVenc := SuperGetMV("MV_LOTVENC",.F.,"N") == "S"
					::lLocaliz := SuperGetMV("MV_LOCALIZ",.F.,"N") == "S"
					If dDataFec >= dDataBase
						::lFechto := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} validaQtdEstoque
Valida o saldo físico em estoque ao informar a quantidade
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method validaQtdEstoque(oModel,nLine,cCampo,nQtd) Class MATA600EST
	Local lRet   := .T.
	Local cCod   := oModel:GetValue('D2_COD')
	Local cLocal := oModel:GetValue('D2_LOCAL')

	If ::tesAtualizaEstoque(oModel:GetValue('D2_TES'))
		If cCampo == "D2_QUANT"
			If !MtAvlNSer(oModel:GetValue("D2_COD"),oModel:GetValue("D2_NUMSERI"),nQtd,oModel:GetValue("D2_QTSEGUM"))
				lRet := .F.
			EndIf
		Else
			If !MtAvlNSer(oModel:GetValue("D2_COD"),oModel:GetValue("D2_NUMSERI"),oModel:GetValue("D2_QUANT"),nQtd)
				lRet := .F.
			EndIf
		EndIf

		If lRet
			lRet := ::vldSaldoEstoque(oModel,cCod,cLocal,nQtd,nLine)
		EndIf
	EndIf
	
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} atualizaCamposdoGrid
Atualiza os campos de endereço e rastro no grid quando selecionado
através da consulta F4
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method atualizaCamposdoGrid(oModel,lLocaliz,lRastro,cValue,cCampo) Class MATA600EST
	Local lRet 	   := .T. as logical
	Local lSubLote as logical

	// Gatilha campos de endereço
	If lLocaliz
		If cCampo == "D2_LOCALIZ" 
			oModel:LoadValue("D2_LOCALIZ",cValue)

			If !Empty(::cNumSeri)
				oModel:LoadValue("D2_NUMSERI",::cNumSeri)
			EndIf
		ElseIf cCampo == "D2_NUMSERI"
			oModel:LoadValue("D2_NUMSERI",cValue)

			If !Empty(::cLocaliz)
				oModel:LoadValue("D2_LOCALIZ",::cLocaliz)
			EndIf
		EndIf

		If !Empty(::cLoteCtl)
			lRastro := .T.
		EndIf
	EndIf

	// Gatilha os campos de lote
	If lRastro
		If cCampo == "D2_LOTECTL"
			oModel:LoadValue("D2_LOTECTL",cValue)

			If !Empty(::cNumLote)
				oModel:LoadValue("D2_NUMLOTE",::cNumLote)
			EndIf
		ElseIf cCampo == "D2_NUMLOTE"
			oModel:LoadValue("D2_NUMLOTE",cValue)
			
			If !Empty(::cLoteCtl)
				oModel:LoadValue("D2_LOTECTL",::cLoteCtl)
			EndIf
		ElseIf cCampo == "D2_LOCALIZ" .Or. cCampo == "D2_NUMSERI"
			If !Empty(::cLoteCtl)
				oModel:LoadValue("D2_LOTECTL",::cLoteCtl)
			EndIf

			If !Empty(::cNumLote)
				oModel:LoadValue("D2_NUMLOTE",::cNumLote)
			EndIf
		EndIf

		If !Empty(::dDtValid)
			oModel:LoadValue("D2_DTVALID",::dDtValid)
			If !Empty(::nPotenci)
				oModel:LoadValue("D2_POTENCI",::nPotenci)
			EndIf
		Else
			lSubLote := Rastro(oModel:GetValue("D2_COD"),"S")
			If cCampo == "D2_LOTECTL" .And. !lSubLote
				oModel:LoadValue("D2_DTVALID",SB8->B8_DTVALID)
				oModel:LoadValue("D2_POTENCI",SB8->B8_POTENCI)
			ElseIf cCampo == "D2_NUMLOTE" .And. lSubLote
				If SB8->(DbSeek(FWxFilial("SB8")+oModel:GetValue("D2_COD")+oModel:GetValue("D2_LOCAL")+oModel:GetValue("D2_LOTECTL")+cValue))
					oModel:LoadValue("D2_DTVALID",SB8->B8_DTVALID)
					oModel:LoadValue("D2_POTENCI",SB8->B8_POTENCI)
				EndIf
			EndIf

			If !::lLotVenc
				If oModel:GetValue("D2_DTVALID") < dDataBase
					If cCampo == "D2_LOTECTL" .And. !lSubLote
						oModel:LoadValue("D2_LOTECTL","")
						lRet := .F.
					ElseIf cCampo == "D2_NUMLOTE" .And. lSubLote
						oModel:LoadValue("D2_NUMLOTE","")
						lRet := .F.
					EndIf
					
					If !lRet
						Help(" ",1,"A240LOTENE")
					EndIf
				Endif
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} tesAtualizaEstoque
Indica se a tes informada no item atualiza estoque
@author Squad Entradas
@since 25/02/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method tesAtualizaEstoque(cTes) Class MATA600EST
	Local lRet := .F.
	Local aAreaSF4 := {}

	// Retorna se a tes do item atualiza estoque
	If !Empty(cTes)
		aAreaSF4 := SF4->(GetArea())
		SF4->(DBSetOrder(1))
		If SF4->(MsSeek(FWxFilial("SF4")+cTES,.F.))
			If SF4->F4_ESTOQUE == "S"
				lRet := .T.
			EndIf
		EndIf
		SF4->(RestArea(aAreaSF4))
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} validaSaldoEndereco
Valida se o endereço/num.serie possui saldo suficiente em estoque
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method validaSaldoEndereco(oModel,cCod,cLocal,nQtdLine,nLine,cLocaliz,cNumSeri) Class MATA600EST
	Local lRet	   := .T.
	Local nX	   := 0
	Local nQtd	   := 0
	Local cLoteCtl := ""
	Local cNumLote := ""
	Local cHelp	   := ""

	If !Empty(cLocaliz) .Or. !Empty(cNumSeri)
		If ::lRastro .And. Rastro(cCod)
			cLoteCtl := oModel:GetValue("D2_LOTECTL")
			cNumLote := oModel:GetValue("D2_NUMLOTE")
		EndIf

		If lRet
			nQtd := nQtdLine
			For nX := 1 to oModel:Length()
				oModel:GoLine(nX)
				If nLine <> oModel:nLine .And. !oModel:IsDeleted()
					If oModel:GetValue('D2_COD') == cCod .And. oModel:GetValue('D2_LOCAL') == cLocal .And. AllTrim(If(!Empty(cLocaliz),oModel:GetValue("D2_LOCALIZ"),"")) == AllTrim(cLocaliz) .And. AllTrim(If(!Empty(cNumSeri),oModel:GetValue("D2_NUMSERI"),"")) == AllTrim(cNumSeri) .And.;
						AllTrim(If(!Empty(cLoteCtl),oModel:GetValue("D2_LOTECTL"),"")) == AllTrim(cLoteCtl) .And. AllTrim(If(!Empty(cNumLote),oModel:GetValue("D2_NUMLOTE"),"")) == AllTrim(cNumLote)
						nQtd += oModel:GetValue("D2_QUANT")
					EndIf
				EndIf
			Next nX
			oModel:GoLine(nLine)
			
			If QtdComp(SaldoSBF(cLocal,cLocaliz,cCod,cNumSeri,cLoteCtl,cNumLote,.F.)) < QtdComp(nQtd)
				lRet := .F.
				cHelp:=OemToAnsi(STR0001)+AllTrim(cCod)+OemToAnsi(STR0002)+AllTrim(cLocal)+OemToAnsi(STR0003)+cLocaliz
				Help(" ",1,"SALDOLOCLZ",,cHelp,5,1)
			EndIf
		EndIf
	Else
		lRet := .F.
		Help(" ",1,"LOCALIZOBR")
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vldSaldoLote
Valida se o lote/sublote possui saldo suficiente em estoque
@author Squad Entradas
@since 25/05/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method vldSaldoLote(oModel,cCod,cLocal,nQtdLine,nLine,cLoteCtl,cNumLote) Class MATA600EST
	Local lRet 	   := .T.
	Local nX 	   := 0
	Local nQtd	   := 0
	Local nSaldo   := 0
	Local cLoteCtl := ""
	Local cNumLote := ""
	Local cHelp	   := ""
	
	If Empty(cLoteCtl)
		cLoteCtl := oModel:GetValue("D2_LOTECTL")
	EndIf

	If Empty(cNumLote)
		cNumLote := oModel:GetValue("D2_NUMLOTE")
	EndIf

	If !Empty(cLoteCtl+cNumLote)
		nQtd   := nQtdLine
		For nX := 1 to oModel:Length()
			oModel:GoLine(nX)
			If nLine <> oModel:nLine .And. !oModel:IsDeleted()
				If oModel:GetValue('D2_COD') == cCod .And. oModel:GetValue('D2_LOCAL') == cLocal .And. oModel:GetValue("D2_LOTECTL") == cLoteCtl .And. AllTrim(If(!Empty(cNumLote),oModel:GetValue("D2_NUMLOTE"),"")) == AllTrim(cNumLote)
					nQtd += oModel:GetValue("D2_QUANT")
				EndIf
			EndIf
		Next nX
		oModel:GoLine(nLine)

		nSaldo:= SaldoLote(cCod,cLocal,cLoteCtl,cNumLote,.F.,.T.,NIL,dDataBase)			
		If QtdComp(nSaldo) < QtdComp(nQtd)
			lRet := .F.
			cHelp:=OemToAnsi(STR0001)+AllTrim(cCod)+OemToAnsi(STR0002)+cLocal+OemToAnsi(STR0005)+AllTrim(cValToChar(nSaldo))+OemToAnsi(STR0004)+cLoteCtl // Produto#Local#Saldo Disp.#Lote
			Help(" ",1,"A240LOTENE",,cHelp,4,1)
		EndIf
	Else
		lRet := .F.
		Help(" ",1,"A240NUMLOT")
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} limpaCampos
Limpa os campos de lote e endereço
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method limpaCampos(oModel) Class MATA600EST

	oModel:LoadValue("D2_LOTECTL","")
	oModel:LoadValue("D2_NUMLOTE","")
	oModel:LoadValue("D2_DTVALID",stod(""))
	oModel:LoadValue("D2_LOCALIZ","")
	oModel:LoadValue("D2_NUMSERI","")
	oModel:LoadValue("D2_POTENCI",0)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} A600F4EST
Função acionada ao pressionar a tecla F4 no grid de itens da nota
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function A600F4EST(cReadVar, oModelItem as object)
	Local cCampo    as Character
	Local lEditCell as Logical
	
	Private c600LocEnd := ""
	Private c600NumSer := ""
	Private c600LotCtl := ""
	Private c600SubLot := ""
	Private d600DtVld
	Private n600Potenc := 0

	If cReadVar $ "M->D2_QUANT|M->D2_LOCALIZ|M->D2_NUMSERI|M->D2_LOTECTL|M->D2_NUMLOTE"
		lEditCell := IsInCallStack("EditCell")

		If lEditCell
			cCampo    := AllTrim(Upper(ReadVar()))
			cCod      := oModelItem:GetValue('D2_COD')
			cLocal    := oModelItem:GetValue('D2_LOCAL')
			nQtd      := oModelItem:GetValue('D2_QUANT')
			cLocaliz  := oModelItem:GetValue('D2_LOCALIZ')

			If cCampo $ 'M->D2_QUANT'
				MaViewSB2(cCod)
			ElseIf cCampo $ 'M->D2_LOTECTL|M->D2_NUMLOTE'
				If Localiza(cCod)
					F4Lote(,,,'A600',cCod,cLocal,NIL,cLocaliz)
				Else
					F4Lote(,,,'A600',cCod,cLocal,NIL,NIL)
				EndIf

				If cCampo == "M->D2_LOTECTL"
					If !Empty(c600LotCtl)
						M->D2_LOTECTL := c600LotCtl
					EndIf
					If !Empty(c600SubLot)
						oModelEst:cNumLote := c600SubLot
					EndIf
				Else
					If !Empty(c600SubLot)
						M->D2_NUMLOTE 	   := c600SubLot
						oModelEst:cLoteCtl := c600LotCtl
					EndIf
				EndIf

				If !Empty(d600DtVld)
					oModelEst:dDtValid := d600DtVld
				EndIf

				If !Empty(n600Potenc)
					oModelEst:nPotenci := n600Potenc
				EndIf
			ElseIf cCampo == "M->D2_LOCALIZ" .Or. cCampo == "M->D2_NUMSERI"
				// Verifica campos necessarios p/ Localizacao
				F4Localiz(,,,'A600',cCod,cLocal,nQtd,ReadVar())

				If cCampo == "M->D2_LOCALIZ"
					M->D2_LOCALIZ := c600LocEnd
					If !Empty(c600NumSer)
						oModelEst:cNumSeri := c600NumSer
					EndIf
				Else
					M->D2_NUMSERI := c600NumSer
					If !Empty(c600LocEnd)
						oModelEst:cLocaliz := c600LocEnd
					EndIf
				EndIf

				If !Empty(c600LotCtl)
					oModelEst:cLoteCtl := c600LotCtl
				EndIf
				If !Empty(c600SubLot)
					oModelEst:cNumLote := c600SubLot
				EndIf
				If !Empty(d600DtVld)
					oModelEst:dDtValid := d600DtVld
				EndIf
				If !Empty(n600Potenc)
					oModelEst:nPotenci := n600Potenc
				EndIf
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EstSD2Fields
Adição de campos no model ITENSDETAIL da MATA600
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function EstSD2Fields(oModelEst)
	Local cCampos := "|D2_LOTECTL|D2_NUMLOTE|D2_DTVALID|D2_LOCALIZ|D2_NUMSERI"
	
	If oModelEst:lPotenci
		cCampos += "|D2_POTENCI"
	EndIf

Return cCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} A600MdlDef
redefinição dos valid e when dos campos que foram adicionados no model ITENSDETAIL
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function A600MdlDef(oModelItens as object, oModelEst as object)

	oModelItens:SetProperty('D2_LOTECTL', MODEL_FIELD_VALID,{||.T.})
	oModelItens:SetProperty('D2_NUMLOTE', MODEL_FIELD_VALID,{||.T.})
	oModelItens:SetProperty('D2_DTVALID', MODEL_FIELD_VALID,{||.T.})
	oModelItens:SetProperty("D2_LOTECTL", MODEL_FIELD_WHEN, {||oModelEst:lUsaSB8 })
	oModelItens:SetProperty("D2_NUMLOTE", MODEL_FIELD_WHEN, {||oModelEst:lUsaSB8 })
	oModelItens:SetProperty("D2_LOCALIZ", MODEL_FIELD_WHEN, {||oModelEst:lUsaSBF })
	oModelItens:SetProperty("D2_NUMSERI", MODEL_FIELD_WHEN, {||oModelEst:lUsaSBF})
	oModelItens:SetProperty("D2_POTENCI", MODEL_FIELD_WHEN, {.F.})

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A600VwdDef
redefinição dos valid e when dos campos que foram adicionados no model ITENSDETAIL
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function A600VwdDef(oModelItens as object, nUltOrdem as numeric, oModelEst as object )
	Local nCnt    as numeric
	Local nOrdem  as numeric
	Local aFields as array
	Local cField  as character

	aFields := {'D2_LOTECTL','D2_NUMLOTE','D2_DTVALID'}
	If oModelEst:lPotenci
		AAdd(aFields,'D2_POTENCI')
	EndIf
	AAdd(aFields,'D2_LOCALIZ')
	AAdd(aFields,'D2_NUMSERI')


	for nCnt := 1 to len(aFields)
		nOrdem := nUltOrdem+nCnt
		cField := aFields[nCnt]
		oModelItens:SetProperty(cField, MVC_VIEW_ORDEM, cValTochar(nOrdem))
	next nCnt

	aSize(aFields,0)
	aFields := NIL
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} A600VwdDef
redefinição dos valid e when dos campos que foram adicionados no model ITENSDETAIL
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function A600PosSD2(aStruSD2)
	Local aPosCmpEst := {}

	AAdd(aPosCmpEst,Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOTECTL"}))
	AAdd(aPosCmpEst,Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_NUMLOTE"}))
	AAdd(aPosCmpEst,Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOCALIZ"}))
	AAdd(aPosCmpEst,Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_NUMSERI"}))
	AAdd(aPosCmpEst,Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DTVALID"}))
	AAdd(aPosCmpEst,Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_POTENCI"}))

Return aPosCmpEst
//-------------------------------------------------------------------
/*/{Protheus.doc} A600EstGrv
redefinição dos valid e when dos campos que foram adicionados no model ITENSDETAIL
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function A600EstGrv(aItensAux,nPos,oMdlSD2,aPosCmpEst)

	If aPosCmpEst[1] > 0
		aItensAux[nPos][aPosCmpEst[1]]   := oMdlSD2:GetValue("D2_LOTECTL")
	EndIf

	If aPosCmpEst[2] > 0
		aItensAux[nPos][aPosCmpEst[2]]  := oMdlSD2:GetValue("D2_NUMLOTE")
	EndIf

	If aPosCmpEst[3] > 0
		aItensAux[nPos][aPosCmpEst[3]] := oMdlSD2:GetValue("D2_LOCALIZ")
	EndIf

	If aPosCmpEst[4] > 0
		aItensAux[nPos][aPosCmpEst[4]]  := oMdlSD2:GetValue("D2_NUMSERI")
	EndIf

	If aPosCmpEst[5] > 0
		aItensAux[nPos][aPosCmpEst[5]]  := oMdlSD2:GetValue("D2_DTVALID")
	EndIf

	If aPosCmpEst[6] > 0
		aItensAux[nPos][aPosCmpEst[6]]  := oMdlSD2:GetValue("D2_POTENCI")
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} vldSaldoEstoque
Valida o saldo físico do produto
@author Squad Entradas
@since 13/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method vldSaldoEstoque(oModel,cCod,cLocal,nQtd,nLine) Class MATA600EST
	Local nX     as numeric
	Local cHelp  as character
	Local nSaldo as numeric
	Local lRet := .T. as logical

	If !::lEstNeg
		For nX := 1 to oModel:Length()
			oModel:GoLine(nX)
			If nLine <> oModel:nLine
				If !oModel:IsDeleted() .And. ::tesAtualizaEstoque(oModel:GetValue("D2_TES"))
					If oModel:GetValue('D2_COD') == cCod .And. oModel:GetValue('D2_LOCAL') == cLocal
						nQtd += oModel:GetValue('D2_QUANT')
					EndIf
				EndIf
			EndIf
		Next nX
		oModel:GoLine(nLine)

		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))
		If DbSeek(FWxFilial("SB2")+cCod+cLocal)
			nSaldo := SaldoMov(Nil,.T.,Nil,.F.,,Nil,Nil,dDataBase)
		EndIf

		If QtdComp(nSaldo-nQtd) < QtdComp(0)
			cHelp:= OemToAnsi(STR0001)+cCod+OemToAnsi(STR0002)+cLocal //"Produto: "--" Local: "
			Help(" ",1,"MA240NEGAT",,cHelp,4,1)
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} resetPropriedades
Reseta as propriedades para não gatilhar dados incorretos
@author Squad Entradas
@since 13/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method resetPropriedades() Class MATA600EST

	::cLocaliz := ::cNumSeri := ::cLoteCtl := ::cNumLote := ""
	::nPotenci := 0
	::dDtValid := stod("")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} setFieldsEditable
Inicializa o when dos campos de lote/endereço ao alterar o produto ou tes
@author Squad Entradas
@since 16/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method setFieldsEditable() Class MATA600EST

	//Inicializa o when dos campos de lote e endereço
	::lUsaSBF := ::lUsaSB8 := .F.

Return

/*
chamadas feitas no fonte MATA600 e MATA103 - validando se todas as funcoes existem para correta execução.
*/
Function chkA600EST()
Local lOk as logical

	lOk := .T.

Return lOk 
