#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA560B.CH"

#DEFINE WMSA560B01 "WMSA560B01"
#DEFINE WMSA560B02 "WMSA560B02"
#DEFINE WMSA560B03 "WMSA560B03"
#DEFINE WMSA560B04 "WMSA560B04"
#DEFINE WMSA560B05 "WMSA560B05"
#DEFINE WMSA560B06 "WMSA560B06"
#DEFINE WMSA560B07 "WMSA560B07"
#DEFINE WMSA560B08 "WMSA560B08"

//-------------------------------------
/*/{Protheus.doc} WMSA560B
Bloqueio de Saldo WMS (Liberar)
@author felipe.m
@since 25/07/2017
@version 1.0
/*/
//-------------------------------------
Function WMSA560BDUMMY()
Return Nil
//-------------------------------------
Static Function ModelDef()
//-------------------------------------
Local oModel  := Nil
Local oStrD0U := FWFormStruct(1,"D0U")
Local oStrD0V := FWFormStruct(1,"D0V")
Local oStrSDD := FWFormStruct(1,"SDD")
Local aColsSX3:= {}; BuscarSX3("D0V_QTDORI",,aColsSX3)
	
	oModel := MPFormModel():New("WMSA560A",,{|oModel| ValidModel(oModel) },{|oModel| CommitMdl(oModel) })
	// Modelo D0U
	oModel:AddFields("D0U_MODEL",,oStrD0U)
	oModel:SetDescription(STR0001) // "Bloqueio de Saldo WMS"
	oModel:GetModel("D0U_MODEL"):SetDescription(STR0001) // "Bloqueio de Saldo WMS"
	
	oStrD0U:SetProperty('D0U_OBSERV', MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,'WMS580WFld(A,B)'))
	
	// Modelo D0V      cTitulo     ,cTooltip         ,cIdField      ,cTipo ,nTamanho   ,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid
	oStrD0V:AddField(STR0002,STR0003,"D0V_LIBERA","N",aColsSX3[3],aColsSX3[4],Nil,{|| .T.},Nil,.F.,{|| D0V->D0V_QTDBLQ },.F.,.F.,.F.) // "Qtd Liberada"##"Quantidade à Liberar"

	oStrD0V:SetProperty("D0V_QTDBLQ",MODEL_FIELD_TITULO,STR0004) // "Saldo Lib."
	oStrD0V:SetProperty("D0V_QTDBLQ",MODEL_FIELD_TOOLTIP,STR0005) // "Saldo para liberar"

	oModel:AddGrid("D0V_MODEL","D0U_MODEL",oStrD0V)
	oModel:GetModel("D0V_MODEL"):SetDescription(STR0006) // "Itens Bloqueio de Saldo WMS"
	oModel:SetRelation("D0V_MODEL", {{"D0V_FILIAL","xFilial('D0V')"},{"D0V_IDBLOQ","D0U_IDBLOQ"}},)
	oModel:GetModel("D0V_MODEL"):SetNoInsertLine(.T.)
	oModel:GetModel("D0V_MODEL"):SetNoDeleteLine(.T.)

	// Modelo SDD
	oStrSDD:AddField("","","DD_LIBERAR","N",aColsSX3[3],aColsSX3[4],Nil,{|| .F.},Nil,.F.,,.F.,.F.,.F.) // Saldo
	oStrSDD:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	oModel:AddGrid("SDD_MODEL","D0U_MODEL",oStrSDD)
	oModel:GetModel("SDD_MODEL"):SetDescription(STR0007) // "Bloqueio de Lote"
	oModel:SetRelation("SDD_MODEL", {{"DD_FILIAL","xFilial('SDD')"},{"DD_DOC","D0U_DOCTO"}},)
	oModel:SetActivate({|oModel| ActiveModel(oModel) } )
Return oModel
//-------------------------------------
Static Function ActiveModel(oModel)
//-------------------------------------
Local oModelSDD  := oModel:GetModel("SDD_MODEL")
Local lRet := .T.
	oModelSDD:LoadValue("DD_LIBERAR",0)
Return lRet
//-------------------------------------
Static Function ViewDef()
//-------------------------------------
Local oModel  := ModelDef()
Local oView   := Nil
Local oStrD0U := FWFormStruct(2,"D0U")
Local oStrD0V := FWFormStruct(2,"D0V")
Local nI      := 1
Local aColsSX3:= {}; BuscarSX3("D0V_QTDORI",,aColsSX3)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox("D0U_DADOS",16)
	oView:CreateHorizontalBox("D0V_DADOS",84)

	oStrD0V:AddField("D0V_LIBERA","99",STR0002,STR0003,Nil,"GET",aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.) // "Qtd Liberada"##"Quantidade à Liberar"

	For nI := 1 To Len(oStrD0U:aFields)
		If nI > Len(oStrD0U:aFields)
			Exit
		EndIf
		// Campos que podem aparecer em tela
		If oStrD0U:aFields[nI][1] $ "D0U_DOCTO/D0U_MOTIVO/D0U_OBSERV/D0U_DATINC/D0U_HORINC/D0U_TIPBLQ/D0U_ORIGEM/D0U_IDDCF"
			Loop
		EndIf

		oStrD0U:RemoveField(oStrD0U:aFields[nI][1])
		nI--
	Next nI

	For nI := 1 To Len(oStrD0V:aFields)
		If nI > Len(oStrD0V:aFields)
			Exit
		EndIf
		// Campos que podem aparecer em tela
		If oStrD0V:aFields[nI][1] $ "D0V_PRDORI/D0V_PRODUT/D0V_LOTECT/D0V_NUMLOT/D0V_LOCAL/D0V_ENDER/D0V_IDUNIT/D0V_QTDBLQ/D0V_QTDORI/D0V_LIBERA/D0V_DTVALD"
			Loop
		EndIf

		oStrD0V:RemoveField(oStrD0V:aFields[nI][1])
		nI--
	Next nI

	oStrD0U:SetProperty("*"          ,MVC_VIEW_ORDEM,"99")
	oStrD0U:SetProperty("D0U_DOCTO"  ,MVC_VIEW_ORDEM,"01")
	oStrD0U:SetProperty("D0U_IDDCF"  ,MVC_VIEW_ORDEM,"02")
	oStrD0U:SetProperty("D0U_MOTIVO" ,MVC_VIEW_ORDEM,"03")
	oStrD0U:SetProperty("D0U_OBSERV" ,MVC_VIEW_ORDEM,"04")
	oStrD0U:SetProperty("D0U_DATINC" ,MVC_VIEW_ORDEM,"05")
	oStrD0U:SetProperty("D0U_HORINC" ,MVC_VIEW_ORDEM,"06")
	oStrD0U:SetProperty("D0U_TIPBLQ" ,MVC_VIEW_ORDEM,"07")
	oStrD0U:SetProperty("D0U_ORIGEM" ,MVC_VIEW_ORDEM,"08")
	oStrD0U:SetProperty("*"          ,MVC_VIEW_CANCHANGE,.F.)
	oStrD0U:SetProperty("D0U_OBSERV" ,MVC_VIEW_CANCHANGE,.T.)

	oStrD0V:SetProperty("*"          ,MVC_VIEW_ORDEM,"99")
	oStrD0V:SetProperty("D0V_LOCAL"  ,MVC_VIEW_ORDEM,"01")
	oStrD0V:SetProperty("D0V_ENDER"  ,MVC_VIEW_ORDEM,"02")
	oStrD0V:SetProperty("D0V_PRODUT" ,MVC_VIEW_ORDEM,"03")
	oStrD0V:SetProperty("D0V_QTDORI" ,MVC_VIEW_ORDEM,"04")
	oStrD0V:SetProperty("D0V_QTDBLQ" ,MVC_VIEW_ORDEM,"05")
	oStrD0V:SetProperty("D0V_LIBERA" ,MVC_VIEW_ORDEM,"06")
	oStrD0V:SetProperty("D0V_IDUNIT" ,MVC_VIEW_ORDEM,"07")
	oStrD0V:SetProperty("D0V_LOTECT" ,MVC_VIEW_ORDEM,"08")
	oStrD0V:SetProperty("D0V_NUMLOT" ,MVC_VIEW_ORDEM,"09")
	oStrD0V:SetProperty("D0V_DTVALD" ,MVC_VIEW_ORDEM,"10")
	oStrD0V:SetProperty("D0V_PRDORI" ,MVC_VIEW_ORDEM,"11")
	oStrD0V:SetProperty("*"          ,MVC_VIEW_CANCHANGE,.F.)
	oStrD0V:SetProperty("D0V_LIBERA" ,MVC_VIEW_CANCHANGE,.T.)
	oStrD0V:SetProperty("D0V_QTDBLQ" ,MVC_VIEW_TITULO,STR0004) // "Saldo Lib."
	oStrD0V:SetProperty("D0V_QTDBLQ" ,MVC_VIEW_DESCR,STR0005) // "Saldo para liberar"

	oView:AddField("D0U_VIEW",oStrD0U,"D0U_MODEL")
	oView:SetOwnerView("D0U_VIEW","D0U_DADOS")

	oView:AddGrid("D0V_VIEW",oStrD0V,"D0V_MODEL")
	oView:EnableTitleView("D0V_VIEW", STR0006) // "Itens Bloqueio de Saldo WMS"
	oView:SetOwnerView("D0V_VIEW","D0V_DADOS")
Return oView
//-------------------------------------------------------
Static Function ValidModel(oModel)
//-------------------------------------------------------
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local oModelD0V := oModel:GetModel("D0V_MODEL")
Local oOrdServ  := WMSDTCOrdemServico():New()
Local nI        := 0
Local nJ        := 0
Local nX        := 0
Local nPos      := 0
Local nQtMult   := 0
Local nQtdBlq   := 0
Local cPrdCmp   := ""
Local cPrdPai   := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local cPrdFalt  := ""
Local aPais     := {}
Local aLotesPrd := {}
Local aLotes    := {}
Local aArrProd  := {}
Local oProdComp := WMSDTCProdutoComponente():New()

	WmsMsgExibe(.F.) // Exibe a mensagem do WmsMessage

	For nI := 1 To oModelD0V:Length()
		oModelD0V:GoLine(nI)
		If oModelD0V:IsDeleted(nI)
			Loop
		EndIf

		If QtdComp(oModelD0V:GetValue("D0V_LIBERA")) < 0 .Or. QtdComp(oModelD0V:GetValue("D0V_LIBERA")) > QtdComp(oModelD0V:GetValue("D0V_QTDBLQ"))
			aAdd(oOrdServ:aWmsAviso, WmsFmtMsg(STR0008,{{"[VAR01]","D0V_LIBERA"}}) + CRLF + WMSA560B01 + " - " + STR0009) // "Modelo inválido ([VAR01])"##"Quantidade inválida para a liberação de saldo."
			lRet := .F.
		EndIf

		// Carrega os arrays para validação proporcional dos componentes
		If lRet .And. !(oModelD0V:GetValue("D0V_PRODUT") == oModelD0V:GetValue("D0V_PRDORI"))
			If aScan(aPais,{ |x| x[1] == oModelD0V:GetValue("D0V_PRDORI") }) == 0
				// Busca a estrutura do produto pai
				oProdComp:SetProduto(oModelD0V:GetValue("D0V_PRDORI"))
				oProdComp:SetPrdOri(oModelD0V:GetValue("D0V_PRDORI"))
				oProdComp:EstProduto()
				aAdd(aPais,{ oModelD0V:GetValue("D0V_PRDORI"),oProdComp:GetArrProd() })
			EndIf

			// Adiciona ao array produtos componentes
			If (nPos := aScan(aLotesPrd,{ |x| x[1]+x[2]+x[3]+x[4] == oModelD0V:GetValue("D0V_LOTECT") + oModelD0V:GetValue("D0V_NUMLOT") + oModelD0V:GetValue("D0V_PRODUT") + oModelD0V:GetValue("D0V_PRDORI") })) == 0
				aAdd(aLotesPrd,{ oModelD0V:GetValue("D0V_LOTECT"),oModelD0V:GetValue("D0V_NUMLOT"),oModelD0V:GetValue("D0V_PRODUT"),oModelD0V:GetValue("D0V_PRDORI"),oModelD0V:GetValue("D0V_LIBERA") })
			Else
				aLotesPrd[nPos][5] += oModelD0V:GetValue("D0V_LIBERA")
			EndIf
		EndIf
	Next nI

	If lRet .And. Len(aPais) > 0
		For nI := 1 To Len(aPais)
			cPrdPai  := aPais[nI][1]
			aArrProd := aPais[nI][2]
			cPrdFalt := ""

			For nJ := 1 To Len(aArrProd)
				cPrdCmp := aArrProd[nJ][1]
				// Valida se todas as partes do produto estão selecionadas
				If aScan(aLotesPrd,{|x| x[3]+x[4] == cPrdCmp + cPrdPai }) == 0
					cPrdFalt += CRLF + cPrdCmp
					lRet := .F.
				EndIf
			Next nJ

			If !lRet
				aAdd(oOrdServ:aWmsAviso, WmsFmtMsg(STR0008,{{"[VAR01]",STR0010}}) + CRLF + WMSA560B02 + " - " + WmsFmtMsg(STR0011,{{"[VAR01]",cPrdPai}}) + CRLF + STR0012 + cPrdFalt) // "Modelo inválido ([VAR01])"#"Componentização"#"Não foram selecionados todos os componentes para bloquear o produto [VAR01]."##"Produtos faltantes:"
			EndIf
		Next nI
	EndIf

	If lRet .And. Len(aPais) > 0
		// Carregas todos os lotes selecionados
		For nJ := 1 To Len(aLotesPrd)
			cLoteCtl := aLotesPrd[nJ][1]
			cNumLote := aLotesPrd[nJ][2]
			cPrdPai  := aLotesPrd[nJ][4]
			nQtdBlq  := aLotesPrd[nJ][5]

			If (aScan(aLotes,{ |x| x[1]+x[2]+x[3] == cLoteCtl + cNumLote + cPrdPai}) == 0) .And. QtdComp(nQtdBlq) > 0
			 	aAdd(aLotes,{cLoteCtl, cNumLote, cPrdPai})
			EndIf
		Next nJ

		For nX := 1 To Len(aPais)
			cPrdPai  := aPais[nX][1]
			aArrProd := aPais[nX][2]
			lRet     := .T.

			// Para cada lote, verifica a quantidade multipla dos componentes
			For nJ := 1 To Len(aLotes)
				cLoteCtl := aLotes[nJ][1]
				cNumLote := aLotes[nJ][2]

				For nI := 1 To Len(aArrProd)
					cPrdCmp := aArrProd[nI][1]
					nQtMult := aArrProd[nI][2]

					If (nPos := aScan(aLotesPrd,{|x| AllTrim(x[1]+x[2]+x[3]+x[4]) == AllTrim(cLoteCtl+cNumLote+cPrdCmp+cPrdPai)})) > 0
						nQtdBlq := aLotesPrd[nPos][5]

						If nI == 1
							nQuant := nQtdBlq / nQtMult
						Else
							If QtdComp(nQuant) != QtdComp(nQtdBlq / nQtMult)
								aAdd(oOrdServ:aWmsAviso, WmsFmtMsg(STR0008,{{"[VAR01]",STR0010}}) + CRLF + WMSA560B03 + " - " + WmsFmtMsg(STR0013,{{"[VAR01]",cPrdCmp},{"[VAR02]",cLoteCtl+"/"+cNumLote}})) // "Modelo inválido ([VAR01])"#"Componentização"#"Quantidade multipla dos componentes em lotes inválida! Rever quantidades do produto [VAR01] do Lote/Sub-Lote: '[VAR02]'."
								lRet := .F.
								Exit
							EndIf
						EndIf
					EndIf
				Next nI

				If !lRet
					Exit
				EndIf
			Next nJ
		Next nX
	EndIf
	
	WmsMsgExibe(.T.) // Exibe a mensagem do WmsMessage
	
	If Len(oOrdServ:aWmsAviso) > 0
		oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,WMSA560B06,STR0014,"") // "Existem informações inválidos no formulário!"
		oOrdServ:ShowWarnig()
		lRet := .F.
	EndIf

RestArea(aAreaAnt)
Return lRet
//-------------------------------------------------------
Static Function CommitMdl(oModel)
//-------------------------------------------------------
Return FwFormCommit(oModel,,,,{|oModel| InTTS(oModel)},{|oModel| ABeforeTTS(oModel)}) // Estorno D14, SB2, SB8, SDD e SDC
//-------------------------------------------------------
Static Function ABeforeTTS(oModel)
//-------------------------------------------------------
Local oModelD0V := oModel:GetModel("D0V_MODEL")
Local nJ := 0

	For nJ := 1 To oModelD0V:Length()
		oModelD0V:GoLine(nJ)

		// Atualiza quantidade bloqueada no modelo D0V
		oModelD0V:LoadValue("D0V_QTDBLQ", (oModelD0V:GetValue("D0V_QTDBLQ") - oModelD0V:GetValue("D0V_LIBERA")) )
	Next nJ

Return .T.
//-------------------------------------------------------
Static Function InTTS(oModel)
//-------------------------------------------------------
Local oModelSDD := oModel:GetModel("SDD_MODEL")
Local oModelD0V := oModel:GetModel("D0V_MODEL")
Local oModelD0U := oModel:GetModel("D0U_MODEL")
Local oBlqSaldo := WMSDTCBloqueioSaldoItens():New()
Local cPrdOri   := ""
Local cProdut   := ""
Local cLocal    := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local lRet      := .T.
Local lCanEstEmp:= .F.
Local nSaldo    := 0
Local nSaldo2   := 0
Local nI        := 0
Local nJ        := 0
Local nPos      := 0
Local nQtdLib   := 0
Local aPrdOri   := {}
	//Verifica se não há mais itens relacionados ao documento (D0U)
	lCanEstEmp := CanEstEmp(oModelD0U:GetValue("D0U_IDBLOQ"),oModelD0U:GetValue("D0U_IDDCF"),oModelD0U:GetValue("D0U_ORIGEM"))
	//Ajusta quantidade liberada D0V e armazena a quantidade liberada para o produto origem
	If lRet
		For nJ := 1 To oModelD0V:Length()
			oModelD0V:GoLine(nJ)
			//Armazena quantidade de apenas UM dos produtos da esturuta, para usar de base para o desconto da SDD, SDC, SB2, SB8  e D0U posteriormente
			If (aScan(aPrdOri,{ |x| x[1]+x[2]+x[4]+x[5] == oModelD0V:GetValue("D0V_LOCAL")+oModelD0V:GetValue("D0V_PRDORI")+oModelD0V:GetValue("D0V_LOTECT") + oModelD0V:GetValue("D0V_NUMLOT")})) > 0
				If (nPos := aScan(aPrdOri,{ |x| x[1]+x[2]+x[3]+x[4]+x[5] == oModelD0V:GetValue("D0V_LOCAL")+oModelD0V:GetValue("D0V_PRDORI")+oModelD0V:GetValue("D0V_PRODUT")+oModelD0V:GetValue("D0V_LOTECT") + oModelD0V:GetValue("D0V_NUMLOT")})) > 0
					aPrdOri[nPos][6] += oModelD0V:GetValue("D0V_LIBERA")
				EndIf
			Else
				aAdd(aPrdOri,{ oModelD0V:GetValue("D0V_LOCAL"),oModelD0V:GetValue("D0V_PRDORI"),oModelD0V:GetValue("D0V_PRODUT"),oModelD0V:GetValue("D0V_LOTECT"),oModelD0V:GetValue("D0V_NUMLOT"),oModelD0V:GetValue("D0V_LIBERA")})
			EndIf			
			// Limpa os dados do objeto
			oBlqSaldo:ClearData()
			// Informações do produto pai
			oBlqSaldo:SetPrdOri(oModelD0V:GetValue("D0V_PRDORI"))
			oBlqSaldo:SetProduto(oModelD0V:GetValue("D0V_PRODUT"))
			oBlqSaldo:SetLoteCtl(oModelD0V:GetValue("D0V_LOTECT"))
			oBlqSaldo:SetNumLote(oModelD0V:GetValue("D0V_NUMLOT"))
			oBlqSaldo:SetDtValid(oModelD0V:GetValue("D0V_DTVALD"))
			// Informaçoes do endereço
			oBlqSaldo:SetArmazem(oModelD0V:GetValue("D0V_LOCAL"))
			oBlqSaldo:SetEnder(oModelD0V:GetValue("D0V_ENDER"))
			oBlqSaldo:SetIdUnit(oModelD0V:GetValue("D0V_IDUNIT"))
			// Informações do estoque endereço
			oBlqSaldo:SetQtdLib(oModelD0V:GetValue("D0V_LIBERA"))
			// Atualização do estoque endereço
			If !(lRet := oBlqSaldo:RemoverBloqueioEstoque())
				oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,WMSA560B04,STR0015+oBlqSaldo:GetErro(),"") // "Problema na liberação: "
			EndIf			
			//Apaga D0V
			If lRet .And. QtdComp(oModelD0V:GetValue("D0V_QTDBLQ")) == 0
				oBlqSaldo:oBlqSaldo:SetIdBlq(oModelD0U:GetValue("D0U_IDBLOQ"))
				If oBlqSaldo:LoadData(1)
					oBlqSaldo:DeleteD0V()
				Else
					oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,WMSA560B07,STR0015+oBlqSaldo:GetErro(),"") // "Problema na liberação: "
				EndIf
			EndIf
			If !lRet
				Exit
			EndIf
		Next nJ
	EndIf
	
	//Ajusta quantidade liberada SDD, SDC, SB2, SB8 e D0U
	For nI := 1 To Len(aPrdOri)
		If aPrdOri[nI][6] > 0
			cLocal  := aPrdOri[nI][1]
			cPrdOri := aPrdOri[nI][2]
			cProdut := aPrdOri[nI][3]
			cLoteCtl:= aPrdOri[nI][4]
			cNumLote:= aPrdOri[nI][5]
			//Calcula quantidade do produto pai com base na quantidade de um dos componentes
			D11->(DbSetOrder(1)) //D11_FILIAL+D11_PRODUT+D11_PRDORI+D11_PRDCMP
			If D11->(DbSeek(xFilial('D11')+cPrdOri+cPrdOri+cProdut))
				cQtdLib := aPrdOri[nI][6]/D11->D11_QTMULT
			Else
				cQtdLib := aPrdOri[nI][6]
			EndIf
			
			//Ajusta SDD
			If oModelSDD:SeekLine({{"DD_LOCAL",cLocal},{"DD_PRODUTO",cPrdOri},{"DD_LOTECTL",cLoteCtl},{"DD_NUMLOTE",cNumLote}})
				nSaldo  := oModelSDD:GetValue("DD_SALDO") - cQtdLib
				nSaldo2 := ConvUm(oModelSDD:GetValue("DD_PRODUTO"), nSaldo, 0, 2)
				oModelSDD:LoadValue("DD_LIBERAR", cQtdLib)
				oModelSDD:LoadValue("DD_QUANT"  ,nSaldo)
				oModelSDD:LoadValue("DD_QTSEGUM",nSaldo2)
				oModelSDD:LoadValue("DD_SALDO"  ,nSaldo)
				oModelSDD:LoadValue("DD_SALDO2" ,nSaldo2)
				
				// Limpa os dados do objeto
				oBlqSaldo:ClearData()
				// Informações do produto pai
				oBlqSaldo:SetPrdOri(oModelSDD:GetValue("DD_PRODUTO"))
				oBlqSaldo:SetLoteCtl(oModelSDD:GetValue("DD_LOTECTL"))
				oBlqSaldo:SetNumLote(oModelSDD:GetValue("DD_NUMLOTE"))
				oBlqSaldo:SetDtValid(oModelSDD:GetValue("DD_DTVALID"))
				//Informações do documento
				oBlqSaldo:oBlqSaldo:SetDocto(oModelD0U:GetValue("D0U_DOCTO"))
				oBlqSaldo:SetQtdLib(oModelSDD:GetValue("DD_LIBERAR"))
				oBlqSaldo:SetArmazem(oModelSDD:GetValue("DD_LOCAL"))
				
				// Ajustes dos empenhos SB2, SB8 e SDC
				If !(lRet := oBlqSaldo:RemoverEmpenho())
					oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,WMSA560B05,STR0015+oBlqSaldo:GetErro(),"") // "Problema na liberação: "
				EndIf
				If lRet .And. lCanEstEmp
					If QtdComp(oModelSDD:GetValue("DD_SALDO")) == 0
						oBlqSaldo:RemoverSDD()
					EndIf 
					oBlqSaldo:oBlqSaldo:GoToD0U(D0U->(Recno()))
					If !(lRet := oBlqSaldo:oBlqSaldo:DeleteD0U())
						oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,WMSA560B08,STR0015+oBlqSaldo:GetErro(),"") // "Problema na liberação: "
					EndIf
				EndIf
				
			EndIf
		EndIf
	Next nI
	//Força gravação SDD
	If lRet
		FwFormCommit(oModel)
	EndIf
Return lRet
//-------------------------------------------------------
Static Function CanEstEmp(cIdBloq,cId,cOrigem)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasD0V := ""
Local cAliasD0Q := ""
Local cAliasD0S := ""
Local cAliasDCR := ""
	//Verifica se existe mais algum item com quantidade pendente de desbloqueio
	cQuery := " SELECT D0V.D0V_IDBLOQ"
	cQuery +=   " FROM "+RetSqlName('D0V')+" D0V"
	cQuery +=  " WHERE D0V.D0V_FILIAL = '"+xFilial('D0V')+"'"
	cQuery +=    " AND D0V.D0V_IDBLOQ = '"+cIdBloq+"'"
	cQuery +=    " AND D0V.D0V_QTDBLQ > 0"
	cQuery +=    " AND D0V.D_E_L_E_T_ = ' '"
	cAliasD0V := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0V,.F.,.T.)
	lRet := (cAliasD0V)->(EoF())
	(cAliasD0V)->(DbCloseArea())
	If lRet .And. cOrigem == "D0Q"
		//Verifica se toda a D0Q encontra-se atendida
		cQuery := " SELECT D0Q.D0Q_ID" 
		cQuery +=   " FROM "+RetSqlName('D0Q')+" D0Q"
		cQuery +=  " WHERE D0Q.D0Q_FILIAL = '"+xFilial('D0Q')+"'"
		cQuery +=    " AND D0Q.D0Q_ID = '"+cId+"'"
		cQuery +=    " AND D0Q.D0Q_QUANT > D0Q.D0Q_QTDUNI"
		cQuery +=    " AND D0Q.D_E_L_E_T_ = ' '"
		cAliasD0Q := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0Q,.F.,.T.)
		lRet := (cAliasD0Q)->(EoF())
		(cAliasD0Q)->(DbCloseArea())
		If lRet
			//Verifica se existe algum unitizador da demanda que não está endereçado
			cQuery := " SELECT D0S.D0S_IDUNIT"
			cQuery += " FROM "+RetSqlName('D0S')+" D0S"
			cQuery += " INNER JOIN "+RetSqlName('D0R')+" D0R"
			cQuery += " ON D0R.D0R_FILIAL = '"+xFilial('D0R')+"'"
			cQuery += " AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT"
			cQuery += " AND D0R.D0R_STATUS <> '4'"
			cQuery += " AND D0R.D_E_L_E_T_ = ' '"
			cQuery += " WHERE D0S.D0S_FILIAL = '"+xFilial('D0S')+"'"
			cQuery += " AND D0S.D0S_IDD0Q = '"+cId+"'"
			cQuery += " AND D0S.D_E_L_E_T_ = ' '"
			cAliasD0S := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0S,.F.,.T.)
			lRet := (cAliasD0S)->(EoF())
			(cAliasD0S)->(DbCloseArea())
		EndIf
	EndIf
	If lRet .And. cOrigem == "DCF"
		//Verifica se existe alguma movimentação da DCF que ainda não foi executada
		cQuery := " SELECT DCF.DCF_ID"
		cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
		cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
		cQuery +=    " AND DCF.DCF_ID     = '"+cId+"'"
		cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
		cQuery +=    " AND EXISTS (SELECT DCR.DCR_IDDCF"
		cQuery +=                  " FROM "+RetSqlName("DCR")+" DCR"
		cQuery +=                 " INNER JOIN "+RetSqlName('D12')+" D12"
		cQuery +=                    " ON D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=                   " AND D12.D12_SEQUEN = DCR.DCR_SEQUEN"
		cQuery +=                   " AND D12.D12_IDDCF  = DCR.DCR_IDORI"
		cQuery +=                   " AND D12.D12_IDMOV  = DCR.DCR_IDMOV"
		cQuery +=                   " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
		cQuery +=                   " AND D12.D12_ATUEST = '1'" //Atualiza Estoque
		cQuery +=                   " AND D12.D12_STATUS = '4'" //A executar
		cQuery +=                   " AND D12.D_E_L_E_T_ = ' '"
		cQuery +=                 " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=                   " AND DCR.DCR_IDDCF  = DCF.DCF_ID"
		cQuery +=                   " AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN"
		cQuery +=                   " AND DCR.D_E_L_E_T_ = ' ')"
		cAliasDCR := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCR,.F.,.T.)
		lRet := (cAliasDCR)->(EoF())
		(cAliasDCR)->(DbCloseArea())
	EndIf
Return lRet
//-------------------------------------------------------
Function WMS580WFld(oModel,cField)
Local lRet := .F.
	If cField == "D0U_OBSERV" .And. oModel:GetValue("D0U_TIPBLQ") == "1"
		lRet := .T.	
	EndIf
Return lRet
