#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA560A.CH"

#DEFINE WMSA560A01 "WMSA560A01"
#DEFINE WMSA560A02 "WMSA560A02"
#DEFINE WMSA560A03 "WMSA560A03"
#DEFINE WMSA560A04 "WMSA560A04"
#DEFINE WMSA560A05 "WMSA560A05"
#DEFINE WMSA560A06 "WMSA560A06"
#DEFINE WMSA560A07 "WMSA560A07"
#DEFINE WMSA560A08 "WMSA560A08"
#DEFINE WMSA560A09 "WMSA560A09"

//-------------------------------------
/*/{Protheus.doc} WMSA560A
Bloqueio de Saldo WMS (Bloquear)
@author felipe.m
@since 25/07/2017
@version 1.0
/*/
//-------------------------------------
Function WMSA560ADUMMY()
Return Nil
//-------------------------------------
Static Function ModelDef()
//-------------------------------------
Local oModel  := Nil
Local oStrD0U := FWFormStruct(1,"D0U")
Local oStrD0V := FWFormStruct(1,"D0V")
Local cDocto  := ""
Local cIdBloq := ""
Local aColsSX3:= {}; BuscarSX3("D0V_QTDORI",,aColsSX3)

	oModel := MPFormModel():New("WMSA560A",,{|oModel| ValidModel(oModel) },{|oModel| CommitMdl(oModel) })
	// Modelo D0U
	oStrD0U:SetProperty("D0U_DOCTO" ,MODEL_FIELD_INIT,{|| cDocto := GetSX8Num("D0U","D0U_DOCTO"),Iif(__lSX8,ConfirmSX8(),Nil),cDocto })
	oStrD0U:SetProperty("D0U_DATINC",MODEL_FIELD_INIT,{|| dDataBase })
	oStrD0U:SetProperty("D0U_HORINC",MODEL_FIELD_INIT,{|| Time() })
	oStrD0U:SetProperty("D0U_TIPBLQ",MODEL_FIELD_INIT,{|| "1" })
	oStrD0U:SetProperty("D0U_IDBLOQ",MODEL_FIELD_INIT,{|| cIdBloq := ProxNum(),cIdBloq })
	oStrD0U:SetProperty("D0U_ORIGEM",MODEL_FIELD_INIT,{|| "D0U" })

	oModel:AddFields("D0U_MODEL",,oStrD0U)
	oModel:SetDescription(STR0001) // "Bloqueio de Saldo WMS"
	oModel:GetModel("D0U_MODEL"):SetDescription(STR0001) // "Bloqueio de Saldo WMS"

	// Modelo D0V
	oStrD0V:AddField(STR0002,STR0002,"D0V_SALDO","N",aColsSX3[3],aColsSX3[4],Nil,{|| .F.},Nil,.F.,,.F.,.F.,.F.) // Saldo
	oStrD0V:SetProperty("D0V_IDBLOQ",MODEL_FIELD_INIT,{|| cIdBloq })
	oStrD0V:AddTrigger("D0V_QTDBLQ","D0V_QTDORI",,{|oModel,cField,nVal| nVal } )

	oModel:AddGrid("D0V_MODEL","D0U_MODEL",oStrD0V)
	oModel:GetModel("D0V_MODEL"):SetDescription(STR0003) // "Itens Bloqueio de Saldo WMS"
	oModel:SetRelation("D0V_MODEL", {{"D0V_FILIAL","xFilial('D0V')"},{"D0V_IDBLOQ","D0U_IDBLOQ"}},)
	oModel:GetModel("D0V_MODEL"):SetNoInsertLine(.T.)
	oModel:GetModel("D0V_MODEL"):SetNoDeleteLine(.T.)
Return oModel
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
	oView:CreateHorizontalBox("MARK_DADOS",42)
	oView:CreateHorizontalBox("D0V_DADOS",42)

	oStrD0V:AddField("D0V_SALDO","99",STR0002,STR0002,Nil,"GET",aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.) // Saldo

	For nI := 1 To Len(oStrD0U:aFields)
		If nI > Len(oStrD0U:aFields)
			Exit
		EndIf
		// Campos que podem aparecer em tela
		If oStrD0U:aFields[nI][1] $ "D0U_DOCTO/D0U_MOTIVO/D0U_OBSERV/D0U_DATINC/D0U_HORINC/D0U_TIPBLQ/D0U_ORIGEM"
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
		If oStrD0V:aFields[nI][1] $ "D0V_PRDORI/D0V_PRODUT/D0V_LOTECT/D0V_NUMLOT/D0V_LOCAL/D0V_ENDER/D0V_IDUNIT/D0V_SALDO/D0V_QTDBLQ/D0V_DTVALD"
			Loop
		EndIf

		oStrD0V:RemoveField(oStrD0V:aFields[nI][1])
		nI--
	Next nI

	oStrD0U:SetProperty("*"          ,MVC_VIEW_ORDEM,"99")
	oStrD0U:SetProperty("D0U_DOCTO"  ,MVC_VIEW_ORDEM,"01")
	oStrD0U:SetProperty("D0U_MOTIVO" ,MVC_VIEW_ORDEM,"02")
	oStrD0U:SetProperty("D0U_OBSERV" ,MVC_VIEW_ORDEM,"03")
	oStrD0U:SetProperty("D0U_DATINC" ,MVC_VIEW_ORDEM,"04")
	oStrD0U:SetProperty("D0U_HORINC" ,MVC_VIEW_ORDEM,"05")
	oStrD0U:SetProperty("D0U_TIPBLQ" ,MVC_VIEW_ORDEM,"06")
	oStrD0U:SetProperty("D0U_ORIGEM" ,MVC_VIEW_ORDEM,"07")

	oStrD0U:SetProperty("*"          ,MVC_VIEW_CANCHANGE,.F.)
	oStrD0U:SetProperty("D0U_MOTIVO" ,MVC_VIEW_CANCHANGE,.T.)
	oStrD0U:SetProperty("D0U_OBSERV" ,MVC_VIEW_CANCHANGE,.T.)

	oStrD0V:SetProperty("*"          ,MVC_VIEW_ORDEM,"99")
	oStrD0V:SetProperty("D0V_LOCAL"  ,MVC_VIEW_ORDEM,"01")
	oStrD0V:SetProperty("D0V_ENDER"  ,MVC_VIEW_ORDEM,"02")
	oStrD0V:SetProperty("D0V_PRODUT" ,MVC_VIEW_ORDEM,"03")
	oStrD0V:SetProperty("D0V_SALDO"  ,MVC_VIEW_ORDEM,"04")
	oStrD0V:SetProperty("D0V_QTDBLQ" ,MVC_VIEW_ORDEM,"05")
	oStrD0V:SetProperty("D0V_IDUNIT" ,MVC_VIEW_ORDEM,"06")
	oStrD0V:SetProperty("D0V_LOTECT" ,MVC_VIEW_ORDEM,"07")
	oStrD0V:SetProperty("D0V_NUMLOT" ,MVC_VIEW_ORDEM,"08")
	oStrD0V:SetProperty("D0V_DTVALD" ,MVC_VIEW_ORDEM,"09")
	oStrD0V:SetProperty("D0V_PRDORI" ,MVC_VIEW_ORDEM,"10")

	oStrD0V:SetProperty("*"          ,MVC_VIEW_CANCHANGE,.F.)
	oStrD0V:SetProperty("D0V_QTDBLQ" ,MVC_VIEW_CANCHANGE,.T.)

	oView:AddField("D0U_VIEW",oStrD0U,"D0U_MODEL")
	oView:SetOwnerView("D0U_VIEW","D0U_DADOS")

	oView:AddOtherObject("D14_MARK",{|oPainel| MarkProds(oPainel,oModel,oView) })
	oView:SetOwnerView("D14_MARK","MARK_DADOS")

	oView:AddGrid("D0V_VIEW",oStrD0V,"D0V_MODEL")
	oView:EnableTitleView("D0V_VIEW", STR0003) // "Itens Bloqueio de Saldo WMS"
	oView:SetOwnerView("D0V_VIEW","D0V_DADOS")
Return oView
//-------------------------------------------------------
Static Function ValidModel(oModel)
//-------------------------------------------------------
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local oModelD0U  := oModel:GetModel("D0U_MODEL")
Local oModelD0V  := oModel:GetModel("D0V_MODEL")
Local oOrdServ   := WMSDTCOrdemServico():New()
Local nI         := 0
Local nJ         := 0
Local nX         := 0
Local nPos       := 0
Local nQtMult    := 0
Local nQuant     := 0
Local nQtdBlq    := 0
Local nPosLocPrd := 0
Local nSaldo     := 0
Local nDiv       := 1
Local cPrdCmp    := ""
Local cPrdPai    := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cPrdFalt   := ""
Local aPais      := {}
Local aLotesPrd  := {}
Local aLotes     := {}
Local aArrProd   := {}
Local aLocalProd := {}
Local oProdComp  := WMSDTCProdutoComponente():New()
Local cMensag := ""
Local nCntFor := 0 

	WmsMsgExibe(.F.) // Exibe a mensagem do WmsMessage

	If Empty(oModelD0U:GetValue("D0U_DOCTO"))
		aAdd(oOrdServ:aWmsAviso, WmsFmtMsg(STR0005,{{"[VAR01]","D0U_DOCTO"}}) + CRLF + WMSA560A01 + " - " + STR0006) // "Modelo inválido ([VAR01])"##"Documento para o bloqueio de saldo não foi informado."
		lRet := .F.
	EndIf

	If lRet .And. Empty(oModelD0U:GetValue("D0U_MOTIVO"))
		aAdd(oOrdServ:aWmsAviso, WmsFmtMsg(STR0005,{{"[VAR01]","D0U_MOTIVO"}}) + CRLF + WMSA560A02 + " - " + STR0007) // "Modelo inválido ([VAR01])"##"Motivo para o bloqueio de saldo não foi informado."
		lRet := .F.
	EndIf

	For nI := 1 To oModelD0V:Length()
		oModelD0V:GoLine(nI)
		If oModelD0V:IsDeleted(nI)
			Loop
		EndIf
				
		nPosLocPrd := AScan(aLocalProd,{|x| x[1] == oModelD0V:GetValue("D0V_LOCAL") .And. x[2] == oModelD0V:GetValue("D0V_PRODUT")})
		If nPosLocPrd > 0
			aLocalProd[nPosLocPrd][4] += oModelD0V:GetValue("D0V_QTDBLQ")  
		Else
			aAdd(aLocalProd, {oModelD0V:GetValue("D0V_LOCAL"), oModelD0V:GetValue("D0V_PRDORI"), oModelD0V:GetValue("D0V_PRODUT"), oModelD0V:GetValue("D0V_QTDBLQ")})
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
				aAdd(aLotesPrd,{ oModelD0V:GetValue("D0V_LOTECT"),oModelD0V:GetValue("D0V_NUMLOT"),oModelD0V:GetValue("D0V_PRODUT"),oModelD0V:GetValue("D0V_PRDORI"),oModelD0V:GetValue("D0V_QTDBLQ") })
			Else
				aLotesPrd[nPos][5] += oModelD0V:GetValue("D0V_QTDBLQ")
			EndIf
		EndIf
	Next nI
	
	dbSelectArea('SB2')
	SB2->(dbSetOrder(2))
	D11->(DbSetOrder(1)) //D11_FILIAL+D11_PRODUT+D11_PRDORI+D11_PRDCMP
	
	//Verifica se há saldo do produto para ser bloqueado
	For nI := 1 to Len(aLocalProd)
		nDiv := 1
		//SB2 precisa estar posicionada para calcular o saldo
		SB2->(dbSeek(xFilial("SB2")+aLocalProd[nI][1]+aLocalProd[nI][2]))
		nSaldo := SaldoSB2()
		If !(aLocalProd[nI][2] == aLocalProd[nI][3])
			If D11->(DbSeek(xFilial('D11')+aLocalProd[nI][2]+aLocalProd[nI][2]+aLocalProd[nI][3]))
				nDiv := D11->D11_QTMULT
			EndIf
		EndIf
		If nSaldo < (aLocalProd[nI][4]/nDiv)
			aAdd(oOrdServ:aWmsAviso, WmsFmtMsg(WMSA560A03 + " - " + STR0008, {{"[VAR01]",AllTrim(aLocalProd[nI][2])},{"[VAR02]",AllTrim(aLocalProd[nI][1])},;
                 {"[VAR03]",cValToChar(aLocalProd[nI][3])},{"[VAR04]",cValToChar(nSaldo)}})) // "##"Produto [VAR01]/ armazém [VAR02]: bloqueio solicitado ([VAR03]) é maior que o saldo ([VAR04])."'"  
			lRet := .F.
		EndIf
	Next nI
	
	SB2->(dbCloseArea())

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
				aAdd(oOrdServ:aWmsAviso, WmsFmtMsg(STR0005,{{"[VAR01]",STR0009}}) + CRLF + WMSA560A04 + " - " + WmsFmtMsg(STR0010,{{"[VAR01]",cPrdPai}}) + CRLF + STR0011 + cPrdFalt) // "Modelo inválido ([VAR01])"#"Componentização"#"Não foram selecionados todos os componentes para bloquear o produto [VAR01]."##"Produtos faltantes:"
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
								If lRet
									aAdd(oOrdServ:aWmsAviso, WmsFmtMsg(STR0005,{{"[VAR01]",STR0009}})) //"Modelo inválido ([VAR01])"#"Componentização"#"
									lRet := .F.
								EndIf
								aAdd(oOrdServ:aWmsAviso, WMSA560A05 + " - " + WmsFmtMsg(STR0012,{{"[VAR01]",cPrdCmp},{"[VAR02]",Alltrim(cLoteCtl)+"/"+Alltrim(cNumLote)}})) // Quantidade multipla dos componentes em lotes inválida! Rever quantidades do produto [VAR01] do Lote/Sub-Lote: '[VAR02]'."
							EndIf
						EndIf
					EndIf
				Next nI
			Next nJ
		Next nX
	EndIf
	
	If !IsBlind()
		WmsMsgExibe(.T.) // Exibe a mensagem do WmsMessage
		If Len(oOrdServ:aWmsAviso) > 0
			oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,WMSA560A08,STR0016,"") // "Existem informações inválidos no formulário!"
			oOrdServ:ShowWarnig()
			lRet := .F.
		EndIf 
	Else
		If Len(oOrdServ:aWmsAviso) > 0
	 		For nCntFor := 1 To Len(oOrdServ:aWmsAviso)
				If nCntFor == 1
					cMensag := oOrdServ:aWmsAviso[nCntFor]
				Else
					cMensag += CRLF+oOrdServ:aWmsAviso[nCntFor]
				EndIf
			Next
			oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,,STR0016+ " "+cMensag,"") // "Existem informações inválidos no formulário!"
			lRet := .F.
		EndIF
	EndIf 
	
RestArea(aAreaAnt)
Return lRet
//-------------------------------------------------------
Static Function CommitMdl(oModel)
//-------------------------------------------------------
Return FwFormCommit(oModel,,,,{|oModel| InTSAtuMVC(oModel)}) // Efetivação dos dados do modelo (D0U, D0V e SDD) + Geração dos empenhos D14, SB2, SB8 e SDC
//-------------------------------------------------------
Static Function InTSAtuMVC(oModel)
//-------------------------------------------------------
Local oModelD0V := oModel:GetModel("D0V_MODEL")
Local oModelD0U := oModel:GetModel("D0U_MODEL")
Local oBlqSaldo := WMSDTCBloqueioSaldoItens():New()
Local cQuery    := ""
Local cAliasD0V := ""
Local lRet      := .T.
Local nI        := 0

	For nI := 1 To oModelD0V:Length()
		oModelD0V:GoLine(nI)
		// Limpa os dados do objeto
		oBlqSaldo:ClearData()
		// Informações do produto
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
		oBlqSaldo:SetQtdBlq(oModelD0V:GetValue("D0V_QTDBLQ"))
		// Atualização do estoque endereço
		If !(lRet := oBlqSaldo:GerarBloqueioEstoque())
			oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,WMSA560A06,STR0014+oBlqSaldo:GetErro(),"") // "Problema na efetivação dos dados: "
		EndIf
	Next nI
	//Calcula quantidades à serem gravadas para o bloqueio (SDD,SB2,SB8 e SDC) com base na quantidade dos itens (D0V)
	cQuery := " SELECT MIN(D0V.D0V_SALDO) SALDO, "
	cQuery +=        " D0V.D0V_PRDORI,"
	cQuery +=        " D0V.D0V_LOTECT,"
	cQuery +=        " D0V.D0V_NUMLOT,"
	cQuery +=        " D0V.D0V_LOCAL,"
	cQuery +=        " D0V.D0V_DTVALD"
	cQuery +=   " FROM (SELECT SUM(D0V.D0V_QTDBLQ) D0V_SALDO,"
	cQuery +=                " D0V.D0V_PRDORI,"
	cQuery +=                " D0V.D0V_PRODUT,"
	cQuery +=                " D0V.D0V_LOTECT,"
	cQuery +=                " D0V.D0V_NUMLOT,"
	cQuery +=                " D0V.D0V_LOCAL,"
	cQuery +=                " D0V.D0V_DTVALD"
	cQuery +=           " FROM "+RetSqlName('D0V')+" D0V"
	cQuery +=          " WHERE D0V.D0V_FILIAL = '"+xFilial('D0V')+"'"
	cQuery +=            " AND D0V.D0V_IDBLOQ = '"+oModelD0U:GetValue("D0U_IDBLOQ")+"'"
	cQuery +=            " AND D0V.D_E_L_E_T_ = ' '"
	cQuery +=          " GROUP BY D0V.D0V_PRDORI,"
	cQuery +=                   " D0V.D0V_PRODUT,"
	cQuery +=                   " D0V.D0V_LOTECT,"
	cQuery +=                   " D0V.D0V_NUMLOT,"
	cQuery +=                   " D0V.D0V_LOCAL,
	cQuery +=                   " D0V.D0V_DTVALD) D0V"
	cQuery +=  " GROUP BY D0V.D0V_PRDORI,"
	cQuery +=           " D0V.D0V_LOTECT,"
	cQuery +=           " D0V.D0V_NUMLOT,"
	cQuery +=           " D0V.D0V_LOCAL,"
	cQuery +=           " D0V.D0V_DTVALD"	
	cQuery := ChangeQuery(cQuery)
	cAliasD0V := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0V,.F.,.T.)
	TcSetField(cAliasD0V,'D0V_DTVALD','D')
	While (cAliasD0V)->(!EoF())
		oBlqSaldo:SetArmazem((cAliasD0V)->D0V_LOCAL)
		oBlqSaldo:SetPrdOri((cAliasD0V)->D0V_PRDORI)
		oBlqSaldo:SetLoteCtl((cAliasD0V)->D0V_LOTECT)
		oBlqSaldo:SetNumLote((cAliasD0V)->D0V_NUMLOT)
		oBlqSaldo:SetDtValid((cAliasD0V)->D0V_DTVALD)
		oBlqSaldo:SetQtdBlq((cAliasD0V)->SALDO)
		oBlqSaldo:oBlqSaldo:SetDocto(oModelD0U:GetValue("D0U_DOCTO"))
		oBlqSaldo:oBlqSaldo:SetMotivo(oModelD0U:GetValue("D0U_MOTIVO"))
		oBlqSaldo:oBlqSaldo:SetObserv(oModelD0U:GetValue("D0U_OBSERV"))
		If !(lRet := oBlqSaldo:GerarSDD())
			oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,WMSA560A09,STR0014+oBlqSaldo:GetErro(),"") // "Problema na efetivação dos dados: "
		EndIf
		If lRet
			// Geração dos empenhos SB2, SB8 e SDC
			If !(lRet := oBlqSaldo:GerarEmpenho())
				oModel:SetErrorMessage(oModelD0V:GetId(),oModelD0V:GetId(),,,WMSA560A09,STR0014+oBlqSaldo:GetErro(),"") // "Problema na efetivação dos dados: "
			EndIf
		EndIf
		(cAliasD0V)->(DbSkip())
	EndDo
	(cAliasD0V)->(DbCloseArea())
Return lRet
//-------------------------------------------------------
Static Function RetFiltro()
//-------------------------------------------------------
Local cFiltro := ""
	cFiltro := "D14_LOCAL  >= '"+MV_PAR01+"' AND D14_LOCAL  <= '"+MV_PAR02+"' AND "
	cFiltro += "D14_ENDER  >= '"+MV_PAR03+"' AND D14_ENDER  <= '"+MV_PAR04+"' AND "
	cFiltro += "D14_PRODUT >= '"+MV_PAR05+"' AND D14_PRODUT <= '"+MV_PAR06+"' AND "
	cFiltro += "D14_LOTECT >= '"+MV_PAR07+"' AND D14_LOTECT <= '"+MV_PAR08+"' AND "
	cFiltro += "D14_NUMLOT >= '"+MV_PAR09+"' AND D14_NUMLOT <= '"+MV_PAR10+"' AND "
	cFiltro += "D14_IDUNIT >= '"+MV_PAR11+"' AND D14_IDUNIT <= '"+MV_PAR12+"' AND "
	cFiltro += "(D14_QTDEST - (D14_QTDSPR+D14_QTDEMP+D14_QTDBLQ)) > 0"
Return cFiltro
//-------------------------------------------------------
Static Function MarkProds(oPainel,oModel,oView)
//-------------------------------------------------------
Local aAreaAnt := GetArea()
Local oMarkBrw := Nil
Local lMarcar  := .F.

	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetDescription(STR0015) // "Saldo por endereço WMS"
	oMarkBrw:SetOwner(oPainel)
	oMarkBrw:SetAlias("D14")
	oMarkBrw:oBrowse:SetDBFFilter(.T.)
	oMarkBrw:oBrowse:SetUseFilter(.T.)
	oMarkBrw:oBrowse:SetFixedBrowse(.T.)
	oMarkBrw:oBrowse:SetFilterDefault("@ "+RetFiltro())
	oMarkBrw:SetFieldMark("D14_OK")
	oMarkBrw:bAllMark := { || SetMarkAll(oMarkBrw:Mark(),lMarcar := !lMarcar,oMarkBrw,oModel ), oMarkBrw:Refresh(.T.),oView:Refresh()  }
	oMarkBrw:SetAfterMark({|| SetAfter(oMarkBrw,oModel), oView:Refresh() })
	oMarkBrw:SetMenuDef("")
	oMarkBrw:Activate()

	RestArea(aAreaAnt)
Return
//-------------------------------------------------------
Static Function SetMarkAll(cMarca,lMarcar,oMarkBrw,oModel)
//-------------------------------------------------------
Local aAreaTable := D14->(GetArea())
	D14->(dbSetOrder(1))
	D14->(dbGoTop() )
	While !D14->(Eof())
		RecLock( "D14", .F. )
		D14->D14_OK := IIf( lMarcar, cMarca, "  " )
		SetAfter(oMarkBrw,oModel)
		MsUnLock()
		D14->(dbSkip())
	EndDo
	RestArea( aAreaTable )
Return .T.
//-------------------------------------------------------
Static Function SetAfter(oMarkBrw,oModel)
//-------------------------------------------------------
Local aAreaAnt := GetArea()
Local nI := 0
Local aSelecao := {}

	oModel:GetModel("D0V_MODEL"):SetNoInsertLine(.F.)
	oModel:GetModel("D0V_MODEL"):SetNoDeleteLine(.F.)
	If oMarkBrw:IsMark()
		If !oModel:GetModel("D0V_MODEL"):SeekLine( { {"D0V_LOCAL",D14->D14_LOCAL},{"D0V_ENDER",D14->D14_ENDER},{"D0V_PRDORI",D14->D14_PRDORI},{"D0V_PRODUT",D14->D14_PRODUT},{"D0V_LOTECT",D14->D14_LOTECT},{"D0V_NUMLOT",D14->D14_NUMLOT},{"D0V_IDUNIT",D14->D14_IDUNIT} } )
			If !Empty(oModel:GetModel("D0V_MODEL"):GetValue("D0V_PRODUT"))
				oModel:GetModel("D0V_MODEL"):AddLine()
			EndIf
			
			// Carrega a grid D0V
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_PRDORI",D14->D14_PRDORI)
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_PRODUT",D14->D14_PRODUT)
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_LOTECT",D14->D14_LOTECT)
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_NUMLOT",D14->D14_NUMLOT)
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_DTVALD",D14->D14_DTVALD)
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_LOCAL" ,D14->D14_LOCAL)
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_ENDER" ,D14->D14_ENDER)
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_IDUNIT",D14->D14_IDUNIT)
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_SALDO",Iif(D14->D14_QTDEST > 0,D14->D14_QTDEST - ( D14->D14_QTDSPR + D14->D14_QTDEMP + D14->D14_QTDBLQ),0))
			oModel:GetModel("D0V_MODEL"):SetValue("D0V_QTDBLQ",Iif(D14->D14_QTDEST > 0,D14->D14_QTDEST - ( D14->D14_QTDSPR + D14->D14_QTDEMP + D14->D14_QTDBLQ),0))
		EndIf
	Else
		// Deleta o item desmarcado D0V
		If oModel:GetModel("D0V_MODEL"):SeekLine( { {"D0V_LOCAL",D14->D14_LOCAL},{"D0V_ENDER",D14->D14_ENDER},{"D0V_PRDORI",D14->D14_PRDORI},{"D0V_PRODUT",D14->D14_PRODUT},{"D0V_LOTECT",D14->D14_LOTECT},{"D0V_NUMLOT",D14->D14_NUMLOT},{"D0V_IDUNIT",D14->D14_IDUNIT} } )
			oModel:GetModel("D0V_MODEL"):DeleteLine()
		EndIf
		// Salva a grid D0V
		For nI := 1 To oModel:GetModel("D0V_MODEL"):Length()
			oModel:GetModel("D0V_MODEL"):GoLine(nI)
			If !oModel:GetModel("D0V_MODEL"):IsDeleted()
				aAdd(aSelecao,{oModel:GetModel("D0V_MODEL"):GetValue("D0V_IDBLOQ",nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_PRDORI" ,nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_PRODUT" ,nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_LOTECT" ,nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_NUMLOT" ,nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_DTVALD" ,nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_LOCAL"  ,nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_ENDER"  ,nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_IDUNIT" ,nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_SALDO"  ,nI),;
								oModel:GetModel("D0V_MODEL"):GetValue("D0V_QTDBLQ" ,nI)})
			EndIf
		Next nI
		// Limpa a grid D0V
		oModel:GetModel("D0V_MODEL"):ClearData()
		oModel:GetModel("D0V_MODEL"):InitLine()
		oModel:GetModel("D0V_MODEL"):GoLine(1)
		// Recarrega a grid D0V
		For nI := 1 To Len(aSelecao)
			If !Empty(oModel:GetModel("D0V_MODEL"):GetValue("D0V_PRODUT"))
				oModel:GetModel("D0V_MODEL"):AddLine()
				oModel:GetModel("D0V_MODEL"):GoLine(nI)
			EndIf

			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_IDBLOQ" ,aSelecao[nI][01])
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_PRDORI" ,aSelecao[nI][02])
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_PRODUT" ,aSelecao[nI][03])
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_LOTECT" ,aSelecao[nI][04])
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_NUMLOT" ,aSelecao[nI][05])
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_DTVALD" ,aSelecao[nI][06])
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_LOCAL"  ,aSelecao[nI][07])
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_ENDER"  ,aSelecao[nI][08])
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_IDUNIT" ,aSelecao[nI][09])
			oModel:GetModel("D0V_MODEL"):LoadValue("D0V_SALDO"  ,aSelecao[nI][10])
			oModel:GetModel("D0V_MODEL"):SetValue("D0V_QTDBLQ"  ,aSelecao[nI][11])
		Next nI
	EndIf

	oModel:GetModel("D0V_MODEL"):SetNoInsertLine(.T.)
	oModel:GetModel("D0V_MODEL"):SetNoDeleteLine(.T.)
	oModel:GetModel("D0V_MODEL"):GoLine(1)

RestArea(aAreaAnt)
Return
