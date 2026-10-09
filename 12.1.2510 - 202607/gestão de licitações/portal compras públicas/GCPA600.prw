#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#include "GCPA600.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA600
Monitor de integração com Portal de Compras Públicas

@author Marcio Lopes
@since 12/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPA600()

    Local oBrowse

    Private aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("DKF")
    oBrowse:SetDescription(STR0001 + " - " + STR0002) //"Monitor de Integração"#"Portal de Compras Públicas"

    //Adicionando as Legendas
	oBrowse:AddLegend( "DKF->DKF_STATUS == '0'", "PINK",  STR0003 )	//"Integrado"
    oBrowse:AddLegend( "DKF->DKF_STATUS == '1'", "GREEN", STR0004 ) //"Aguardando Início da Sessão Pública"
	oBrowse:AddLegend( "DKF->DKF_STATUS == '2'", "BLUE" , STR0005 ) //"Sessão Pública Iniciada"
	oBrowse:AddLegend( "DKF->DKF_STATUS == '3'", "BROWN", STR0006 ) //"Suspenso"
	oBrowse:AddLegend( "DKF->DKF_STATUS == '4'", "GRAY" , STR0007 ) //"Processo Fracassado"
	oBrowse:AddLegend( "DKF->DKF_STATUS == '5'", "BLACK", STR0008 ) //"Cancelado"
	oBrowse:AddLegend( "DKF->DKF_STATUS == '6'", "WHITE", STR0009 ) //"Sessão Pública Finalizada"
	oBrowse:AddLegend( "DKF->DKF_STATUS == '7'", "RED"  , STR0010 ) //"Documento Gerado"

    //Ativa a Browse
    oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação do Menu.

@author Marcio Lopes
@since 12/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.GCPA600'	OPERATION MODEL_OPERATION_VIEW ACCESS 3 //"Visualizar"
	ADD OPTION aRotina TITLE STR0012 ACTION 'A600GerDoc()'		OPERATION MODEL_OPERATION_VIEW ACCESS 4 //"Gerar Documento"

Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Marcio Lopes
@since 12/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStruPai 	:= FWFormStruct(1, "DKF")
    Local oStruFilho:= FWFormStruct(1, "DKG")
    Local aRelation := {}
    Local oModel
    Local bPre 		:= Nil
    Local bPos 		:= Nil
    Local bCancel 	:= Nil

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("GCPA600", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("DKFMASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("DKGDETAIL","DKFMASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription(STR0024)
	oModel:GetModel("DKFMASTER"):SetDescription( STR0013 ) //"Processo Licitatório"
	oModel:GetModel("DKGDETAIL"):SetDescription( STR0014 ) //"Atualizações Processo"
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"DKG_FILIAL", "FWxFilial('DKG')"} )
	aAdd(aRelation, {"DKG_IDLICT", "DKF_IDLICT"})
	oModel:SetRelation("DKGDETAIL", aRelation, DKG->(IndexKey(2)))

	//Definindo campos unicos da linha
	oModel:GetModel("DKGDETAIL"):SetUniqueLine({'DKG_ITEM'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@author Marcio Lopes
@since 12/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel 		:= FWLoadModel("GCPA600")
	Local oStruPai 		:= FWFormStruct(2, "DKF",{|cCampo| !( AllTrim(cCampo) $ "DKF_URLPRO|DKF_MSGATU|DKF_MSGRET|DKF_MSGENV|DKF_DSCSTS")} )
	Local oStruFilho	:= FWFormStruct(2, "DKG",{|cCampo| !( AllTrim(cCampo) $ "DKG_MSGRET|DKG_REVISA|DKG_VERSAO")})
	Local oView

	//Cria a visualizacao do cadastro
	oView:= FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_DKF", oStruPai, "DKFMASTER")
	oView:AddGrid("VIEW_DKG",  oStruFilho,  "DKGDETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 60)
	oView:CreateHorizontalBox("GRID", 40)
	oView:SetOwnerView("VIEW_DKF", "CABEC")
	oView:SetOwnerView("VIEW_DKG", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_DKF", STR0013) //"Processo Licitatório"
	oView:EnableTitleView("VIEW_DKG", STR0014) //"Atualizações Processo"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A600GerDoc
Rotina para geração do documento do processo

@author Leonardo Kichitaro
@since 12/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function A600GerDoc()

	Local oGCPApiPCP := nil

	If DKF->DKF_STATUS == '6'
		If DKF->DKF_TPINTG == '1'
			oGCPApiPCP := GCPApiPCP():New()
			oGCPApiPCP:GerarDocProcesso()

			FreeObj(oGCPApiPCP)
		Else
			A600Proc()
		EndIf
	Elseif DKF->DKF_STATUS == '7'
		 Aviso("Aviso","Documento já gerado",{"Ok"})
	else
		MsgAlert(STR0016 + CRLF + STR0017,STR0015)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A600Proc
Realiza a geração do documento para processo importado:
   1=Pedido de Compra
   2=Contrato

@author Leonardo Kichitaro
@since 12/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A600Proc()

	Local oDadosProc	:= Nil

	Local cMsgErro		:= ""
	Local cNDocGer		:= ""

	Local cDocGer		:= 0

	Local lRet			:= .F.

	Local aFornVenc		:= {}

	oDadosProc := JsonObject():New()
	oDadosProc:FromJson(DKF->DKF_MSGATU)
	If (ValType(oDadosProc['Encerramento']) == 'A' .And. Len(oDadosProc['Encerramento']) > 0) .Or.;
	   (Valtype(oDadosProc['TIPO_LICITACAO']) == "C" .and. oDadosProc['TIPO_LICITACAO'] == "Inexigibilidade" )
		//Realiza a verificação dos participantes se existe cadastro na SA2, caso não realiza inclusão
		MsgRun(STR0025, STR0026,{|| GcpPCPFor(oDadosProc)}) //Processando informações Geração de Documento

		//Realiza leitura do Json para buscar os vencedores e itens
		MsgRun(STR0025, STR0026,{|| A600FVenc(oDadosProc, @aFornVenc, @cMsgErro)}) //Processando informações Geração de Documento

		If Len(aFornVenc) > 0
			cDocGer := A600TipDoc(@aFornVenc)

			If cDocGer == "1"
				MsgRun(STR0027, STR0026,{|| lRet := A600GerPC(oDadosProc, aFornVenc, @cNDocGer)}) //"Gerando Pedido(s) de Compra"
			ElseIf cDocGer == "2"
				MsgRun(STR0028, STR0026,{|| lRet := A600GerCtr(oDadosProc, aFornVenc, @cNDocGer)}) //"Gerando Contrato(s)"
			EndIf

			If lRet
				RecLock("DKF", .F.)
				DKF->DKF_TPDOC 	:= cDocGer
				DKF->DKF_NUMDOC	:= cNDocGer:= Left(cNDocGer,len(cNDocGer)-1)
				DKF->DKF_STATUS := "7"
				DKF->(MsUnlock())
			EndIf
		Else
			
			MsgAlert(STR0017 + CRLF + CRLF + cMsgErro, STR0015)
		EndIf
	Else
		
		MsgAlert(STR0017 + CRLF + CRLF + STR0029, STR0015) //O retorno do processo importado não possui informações de encerramento.
	EndIf

	FreeObj(oDadosProc)

	FwFreeArray(aFornVenc)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A600FVenc
Busca vencedores e itens do processo

@author Leonardo Kichitaro
@since 17/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A600FVenc(oDadosProc, aFornVenc, cMsgErro)

	Local xFilSA2   := xFilial("SA2")

	
	Local cMvcondp	:= SuperGetMV("MV_CONDPAD", .F., "   ") //Condição de pagamento padrão, para fornecedor que não tenha informado no cadastro

	Local nLote		:= 0 //Contador do lote
	Local nItem		:= 0 //Contador do item
	Local nVenc		:= 0 //Contador do vencedor
	Local nPos		:= 0

	Local aItens	:= {}
	Local aVence	:= {}
	Local aItemLote := {}
	local nProp     := 0 
	local nValUnit  := 0 
	local nTot      := 0 
	local nA        := 0
	local cIdItem   := ""
	local nRank     := 0
	local cCnpjVenc := ""

	SA2->(dbSetOrder(3))

	//Adiciona os itens no array e os vencedores caso estejam no nivel de produto
	if ValType(oDadosProc['lotes']) == "A"
		
		//Verificação em cada lote
		For nLote := 1 To Len(oDadosProc['lotes']) 

			//Itens do lote
			If Valtype(oDadosProc['lotes'][nLote]['itens']) == "A"
				For nItem := 1 To Len(oDadosProc['lotes'][nLote]['itens'])
					//Adiciona todos os itens do processo
					aAdd(aItens,{oDadosProc['lotes'][nLote]['itens'][nItem]['IdItem'],;
								Iif(Valtype(oDadosProc['lotes'][nLote]['itens'][nItem]['CODIGO_EXTERNO']) <> "U", oDadosProc['lotes'][nLote]['itens'][nItem]['CODIGO_EXTERNO'], ""),;
								oDadosProc['lotes'][nLote]['itens'][nItem]['DS_ITEM'],;
								oDadosProc['lotes'][nLote]['itens'][nItem]['SG_UNIDADE_MEDIDA'],;
								oDadosProc['lotes'][nLote]['itens'][nItem]['QT_ITENS'],;
								oDadosProc['lotes'][nLote]['itens'][nItem]['VL_UNITARIO_ESTIMADO'],;
								oDadosProc['lotes'][nLote]['itens'][nItem]['NR_LOTE'],;
								oDadosProc['lotes'][nLote]['itens'][nItem]['NR_ITEM'],;
								0,;
								0,;
								0,;
								""})

							//Vencedores na estrutura do item
							if Valtype(oDadosProc['operacaoLote']) == "U"
								If Valtype(oDadosProc['lotes'][nLote]['itens'][nItem]['Vencedores']) == "A"
									For nVenc := 1 To Len(oDadosProc['lotes'][nLote]['itens'][nItem]['Vencedores'])
										
										If !oDadosProc['lotes'][nLote]['itens'][nItem]['Vencedores'][nVenc]['Cancelado']
											If aScan(aVence, {|x| x[1] == oDadosProc['lotes'][nLote]['itens'][nItem]['NR_LOTE'] .And.;
																x[2] == oDadosProc['lotes'][nLote]['itens'][nItem]['Vencedores'][nVenc]['IdItem'] .And.;
																x[3] == AllTrim(oDadosProc['lotes'][nLote]['itens'][nItem]['Vencedores'][nVenc]['IdFornecedor'])}) == 0

												aAdd(aVence,{oDadosProc['lotes'][nLote]['itens'][nItem]['NR_LOTE'],;
															oDadosProc['lotes'][nLote]['itens'][nItem]['Vencedores'][nVenc]['IdItem'],;
															AllTrim(oDadosProc['lotes'][nLote]['itens'][nItem]['Vencedores'][nVenc]['IdFornecedor']),;
															oDadosProc['lotes'][nLote]['itens'][nItem]['Vencedores'][nVenc]['ValorUnitario'],;
															oDadosProc['lotes'][nLote]['itens'][nItem]['Vencedores'][nVenc]['ValorTotal']})
											EndIf
										EndIf
									Next nVenc
								endif	
							EndIf
				Next nItem
			EndIf

		Next nLote

		// Aqui serão tratados os editais que o vencedor estão no nível de lote (lá no PCP)
		if Len(aVence) == 0	
			
			For nLote := 1 To Len(oDadosProc['lotes']) 

				aItemLote := {}

				//Edital por item mas com vencedor no nível de lote.
				if Valtype(oDadosProc['operacaoLote']) == "U" 

					//Adiciona os dados do vencedor 
					if Valtype(oDadosProc['lotes'][nLote]['Vencedores'] ) == "A"
						For nVenc := 1 To Len(oDadosProc['lotes'][nLote]['Vencedores'])
							if !oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['Cancelado']  .And.;
							    Valtype(oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['IdItem']) == "N"

								aAdd(aVence,{oDadosProc['lotes'][nLote]['NR_LOTE'],;
									oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['IdItem'],;
									AllTrim(oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['IdFornecedor']),;
									oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['ValorUnitario'],;
									oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['ValorTotal']})
							endif
						Next nVenc
					endif

				else // Edital por lote

					//Pega o CNPJ do vencedor
					for nRank := 1 To  Len(oDadosProc['lotes'][nLote]['Ranking'])
						if oDadosProc['lotes'][nLote]['Ranking'][nRank]['Posicao'] == 1
							cCnpjVenc := oDadosProc['lotes'][nLote]['Ranking'][nRank]['IdFornecedor']
							exit
						endif
					Next 


					For nItem := 1 To Len(oDadosProc['lotes'][nLote]['itens'])
								   
						//Verifica as propostas para pegar o valor unitario e total do item 
						if Valtype(oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"]) =="A"
							for nProp := 1 to len(oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"])
								if oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"][nProp]["Valido"] .And.; 
								   oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"][nProp]["IdFornecedor"] == cCnpjVenc

									cIdItem := oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"][nProp]["IdItem"]

									if oDadosProc['lotes'][nLote]['itens'][nItem]["tipoJulgamento"] == "Maior Desconto"
										nValUnit  := oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"][nProp]["ValorTotal"] - oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"][nProp]["ValorDesconto"]
										nTot      := oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"][nProp]["ValorTotal"]
									else 
										nValUnit  := oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"][nProp]["ValorUnitario"] 
										nTot      := oDadosProc['lotes'][nLote]['itens'][nItem]["Propostas"][nProp]["ValorTotal"]
									endif
								endif
							next nProp
						endif

						// Se teve proprosta readequada
						if Valtype(oDadosProc['lotes'][nLote]['itens'][nItem]["PropostasReadequadas"]) =="A"
							for nProp := 1 to len(oDadosProc['lotes'][nLote]['itens'][nItem]["PropostasReadequadas"])
								if oDadosProc['lotes'][nLote]['itens'][nItem]["PropostasReadequadas"][nProp]["Valido"] .And.;
								   oDadosProc['lotes'][nLote]['itens'][nItem]["PropostasReadequadas"][nProp]["IdFornecedor"] == cCnpjVenc
									
									cIdItem   := oDadosProc['lotes'][nLote]['itens'][nItem]["PropostasReadequadas"][nProp]["IdItem"]
									nValUnit  := oDadosProc['lotes'][nLote]['itens'][nItem]["PropostasReadequadas"][nProp]["ValorUnitario"] 
									nTot      := oDadosProc['lotes'][nLote]['itens'][nItem]["PropostasReadequadas"][nProp]["ValorTotal"]
								endif
							next nProp
						endif

						//Atualiza o valor unitário e total dos itens do lote
						for nA := 1 to len(aItens)
							if aItens[nA,7] == oDadosProc['lotes'][nLote]['NR_LOTE'] .And.; 
							   aItens[nA,1]  == cIdItem

								aItens[nA,9]  := nValUnit
								aItens[nA,10] := nTot

								aAdd(aItemLote,aItens[nA])
							endif
						Next 
					
					Next nItem

				    //Adiciona o vencedor
					If Valtype(oDadosProc['lotes'][nLote]['Vencedores']) == "A" .and. len(oDadosProc['lotes'][nLote]['Vencedores']) > 0 
						For nVenc := 1 To Len(oDadosProc['lotes'][nLote]['Vencedores'])
							If !oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['Cancelado'] 
								aAdd(aVence,{oDadosProc['lotes'][nLote]['NR_LOTE'],;
									"",;
									oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['IdFornecedor'],;
									oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['ValorUnitario'],;
									oDadosProc['lotes'][nLote]['Vencedores'][nVenc]['ValorTotal'],;
									aItemLote })
							EndIf
						Next nVenc
					EndIf
				endif	
				
			Next nLote
		endif 


		If Len(aVence) == 0	
			cMsgErro := STR0030 //O retorno do processo importado não possui informações do(s) vencedor(es) ou estão cancelados.
		EndIf



		If Empty(cMsgErro)
			For nVenc := 1 To Len(aVence)
				If SA2->(dbSeek(xFilSA2 + aVence[nVenc][3]))
					
					if len(aVence[nVenc]) <= 5 //Vencedor esta no item

						If (nItem := aScan(aItens, {|x| x[1] == aVence[nVenc][2]})) > 0
							aItens[nItem][9]	:= aVence[nVenc][4]
							aItens[nItem][10]	:= aVence[nVenc][5]

							If (nPos := aScan(aFornVenc, {|x| x[1] == SA2->A2_COD .And. x[2] == SA2->A2_LOJA})) > 0
								aAdd(aFornVenc[nPos][4], aClone(aItens[nItem]))
							Else
								aAdd(aFornVenc,{SA2->A2_COD,;
												SA2->A2_LOJA,;
												SA2->A2_NOME,;
												{aClone(aItens[nItem])},;
												Iif(!Empty(SA2->A2_COND), SA2->A2_COND, cMvcondp),;
												SA2->A2_CONTATO})
							EndIf
						endif
					else 
						//Vencedor esta no lote
						aAdd(aFornVenc,{SA2->A2_COD, SA2->A2_LOJA,SA2->A2_NOME,	aClone(aVence[nVenc,6]),;
										Iif(!Empty(SA2->A2_COND), SA2->A2_COND, cMvcondp),;
										SA2->A2_CONTATO})
						
					endif	
				EndIf
			Next nVenc
		EndIf
	Endif

	FwFreeArray(aItens)
	FwFreeArray(aVence)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A600TipDoc
Define que tipo de documento será gerado Pedido de Compra/Contrato.
Somente para registros importados do portal.

@author Leonardo Kichitaro
@since 12/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A600TipDoc(aFornVenc)

nOpca :=Gcpa600Doc(@aFornVenc)

Return nOpca


/*/{Protheus.doc} A600GerPC
Geração do pedido de compra para o processo licitatório importado

@author Leonardo Kichitaro
@since 15/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A600GerPC(oDadosProc, aFornVenc, cNDocGer)

	Local lRet			:= .T.

	Local cFilEnt		:= FWxFilial("SC7")
	Local cFilSB1		:= FWxFilial("SB1")
	Local cTes			:= ""
	Local cPath     	:= ""
	Local cFileLog		:= ""
	Local nTamIT		:= TamSX3("C7_ITEM")[1]
	Local cObs      	:= STR0038+Alltrim(DKF->DKF_CODEDT) //-- Ref. Processo Licitatório

	Local nX			:= 0
	Local nY			:= 0

	Local aItens		:= {}

	SB1->(dbSetOrder(1))
	
	Begin Transaction
		For nX := 1 To Len(aFornVenc)
			//-- Preenche cabecalho
			aCab    := {}
			AAdd(aCab,{"C7_EMISSAO", dDataBase			,NIL})
			AAdd(aCab,{"C7_FORNECE", aFornVenc[nX][1]	,NIL})
			AAdd(aCab,{"C7_LOJA"   , aFornVenc[nX][2]	,NIL})
			AAdd(aCab,{"C7_CONTATO", aFornVenc[nX][6]	,NIL})
			AAdd(aCab,{"C7_COND"   , aFornVenc[nX][5]	,NIL})
			AAdd(aCab,{"C7_FILENT" , cFilEnt     		,NIL})

			aItens := {}
			
			//Montagen da array dos itens
			For nY := 1 To Len(aFornVenc[nX][4])
				cC7Item := StrZero(nY, nTamIT)

				SB1->(dbSeek(cFilSB1 + aFornVenc[nX][4][nY][12]))

				//-- Preenche itens
				aAdd(aItens,{})
				aAdd(aTail(aItens), {"C7_ITEM"			,cC7Item  				,Nil} ) 
				aAdd(aTail(aItens), {"C7_PRODUTO"		,aFornVenc[nX][4][nY][12]				,Nil} )
				aAdd(aTail(aItens), {"C7_FISCORI"		,cFilAnt					,Nil} )
				aAdd(aTail(aItens), {"C7_QUANT"			,aFornVenc[nX][4][nY][5]					,Nil} ) 
				aAdd(aTail(aItens), {"C7_PRECO"			,aFornVenc[nX][4][nY][9]			,Nil} ) 
				aAdd(aTail(aItens), {"C7_DATPRF"		,dDataBase			,Nil} ) 
				aAdd(aTail(aItens), {"C7_TES"			,cTes					,Nil} ) 
				aAdd(aTail(aItens), {"C7_FLUXO"			,"S"					,Nil} ) 
				aAdd(aTail(aItens), {"C7_OBS"			,cObs					,Nil} ) 
				aAdd(aTail(aItens), {"C7_LOCAL"			,SB1->B1_LOCPAD			,Nil} ) 
				aAdd(aTail(aItens), {"C7_CODED"			,DKF->DKF_CODEDT				,Nil} )	
				aAdd(aTail(aItens), {"C7_NUMPR" 		,DKF->DKF_NUMPRO				,Nil} ) 
				aAdd(aTail(aItens), {"C7_CC"			,SB1->B1_CC			,Nil} )
				aAdd(aTail(aItens), {"C7_CONTA"			,SB1->B1_CONTA			,Nil} )
				aAdd(aTail(aItens), {"C7_ITEMCTA"		,SB1->B1_ITEMCC			,Nil} )
				aAdd(aTail(aItens), {"C7_CLVL"			,SB1->B1_CLVL			,Nil} )
				aAdd(aTail(aItens), {"C7_GCPLT"			,aFornVenc[nX][4][nY][7]					,Nil} )
				aAdd(aTail(aItens), {"C7_FILEDT"		,cFilEnt				,Nil} )

			Next nY

			If Len(aItens) > 0
				lMsErroAuto := .F.
				lMsHelpAuto := .T.

				MSExecAuto({|v,x,y,z,w,a| MATA120(v,x,y,z,w,a)},1,aCab,aItens,3,.F.) //"Gerando Pedido de Compra"

				If lMsErroAuto
					DisarmTransaction()
					lMsErroAuto := .F.
					lRet := .F.
					Exit
				Else
					cNDocGer += SC7->C7_NUM + '|'
				Endif
			EndIf
		Next nX
	End Transaction

	cFileLog := NomeAutoLog()

	If !Empty(cFileLog) .And. !lRet
		MostraErro(cPath,cFileLog)
		MsgAlert(STR0039, STR0015) //"Não foi possível gerar o pedido para o Processo Licitatório."
	else 
		MsgAlert(STR0040) //"Pedido(s) gerado(s) com sucesso!"
	endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A600GerCtr
Geração do contrato para o processo licitatório importado

@author Leonardo Kichitaro
@since 15/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A600GerCtr(oDadosProc, aFornVenc, cNDocGer)

	Local oModel300		:= Nil

	Local cMsg			:= ""

	Local nX			:= 0
	Local nGravou		:= 0
	Local nCtrs			:= Len(aFornVenc)

	Local lRet			:= .T.

	Begin Transaction
		oModel300 := FWLoadModel("CNTA300")
		For nX := 1 To Len(aFornVenc)
			If nGravou == 0
				MsgRun(STR0041 + AllTrim(Str(nX)) + STR0042 + AllTrim(Str(nCtrs)), STR0043, {|| oModel300 := A600Vncd(oModel300, aFornVenc[nX])}) // "Gerando Contrato " + " de " + "Gerando Contrato(s)"
				cNDocGer += oModel300:Getmodel("CN9MASTER"):GetValue('CN9_NUMERO') + '|'

				nGravou := FWExecView("Incluir", "CNTA300",  MODEL_OPERATION_INSERT,,{||.T.},,,,,,,oModel300) //"Incluir"
				lRet := (nGravou == 0)
			EndIf

			If nGravou == 1 .Or. !lRet
				cMsg := IIF((nGravou==1), STR0044, cMsg) //"Operação cancelada pelo Usuario!"			
				lRet := .F.
				Exit
			Else
				lRet := .T.
			EndIf
		Next
		oModel300:DeActivate()
	End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A600Vncd
Geração do contrato para o processo licitatório importado

@author Leonardo Kichitaro
@since 15/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A600Vncd(oModel300, aFornVncd)

	Local oCN9Master	:= Nil
	Local oCNCDetail	:= Nil

	Local aProp			:= {}

	oModel300:SetOperation(MODEL_OPERATION_INSERT)
	If oModel300:Activate()
		oCNCDetail:= oModel300:GetModel("CNCDETAIL")

		aProp := GetPropMdl(oCNCDetail)
		CNTA300BlMd(oCNCDetail, .F.)

		oCNCDetail:SetValue('CNC_CODIGO', aFornVncd[1])
		oCNCDetail:SetValue('CNC_LOJA'  , aFornVncd[2])

		RstPropMdl(oCNCDetail,aProp)
		FwFreeArray(aProp)

		oCN9Master := oModel300:GetModel('CN9MASTER')
		oCN9Master:SetValue('CN9_ESPCTR','1')
		oCN9Master:SetValue('CN9_DTINIC',dDataBase)
		oCN9Master:SetValue('CN9_UNVIGE','4')
		oCN9Master:SetValue('CN9_CODED',DKF->DKF_CODEDT)
		oCN9Master:SetValue('CN9_NUMPR',DKF->DKF_NUMPRO)
		oCN9Master:SetValue('CN9_NUMATA','')
		oCN9Master:SetValue('CN9_FILEDT',cFilAnt)
		oCN9Master:SetValue('CN9_CONDPG','')

		CNTA300BlMd(oModel300:GetModel('CNBDETAIL'),.F.)
		CNTA300BlMd(oModel300:GetModel('CNZDETAIL'),.F.)
		CNTA300BlMd(oModel300:GetModel('CNCDETAIL'),.F.)
		oModel300:GetModel('CNADETAIL'):SetNoUpdateLine(.F.)

		//Monta detalhes do contrato
		A600DetCtr(oModel300, aFornVncd[4])

		CNTA300BlMd(oModel300:GetModel('CNBDETAIL'),.T.,.T.)
		CNTA300BlMd(oModel300:GetModel('CNZDETAIL'),.T.)
		CNTA300BlMd(oModel300:GetModel('CNCDETAIL'),.T.)
		CNTA300BlMd(oModel300:GetModel('CNADETAIL'),.T.,.T.)
	EndIf

Return oModel300

//-------------------------------------------------------------------
/*/{Protheus.doc} A600DetCtr
Geração dos detalhes do contrato

@author Leonardo Kichitaro
@since 15/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A600DetCtr(oModel, aFornCtr)

	Local oCNADetail	:= oModel:GetModel("CNADETAIL")
	Local oCNBDetail	:= oModel:GetModel("CNBDETAIL")
	Local oCNCDetail	:= oModel:GetModel("CNCDETAIL")

	Local nI			:= 0
	Local nLinhaPla		:= 0
	Local nTamItCNB		:= TamSx3('CNB_ITEM')[1]
	Local cTipPro		:= ""
	Local cTpPla		:= SuperGetMV("MV_TPPLA", .T., "")
	Local cItPla		:= Replicate("0", (TamSx3('CNA_NUMERO')[1]))
	Local cItemCNB		:= Replicate("0", nTamItCNB)
	Local cItPlaZero	:= cItemCNB
	Local xFilSB5		:= FWxFilial("SB5")

	For nI := 1 To Len(aFornCtr)
		GCP017BMod(oModel,{'CNBDETAIL'},.F.)
		GCP017BMod(oModel,{'CNADETAIL'},.F.)
		
		If nLinhaPla == 0 .or. (cTipPro <>  SB5->B5_TIPO .and. !Empty(SB5->B5_TIPO))

			nLinhaPla++
			cItPla := Soma1(cItPla)

			oCNADetail:SetValue('CNA_FORNEC',oCNCDetail:GetValue('CNC_CODIGO'))
			oCNADetail:SetValue('CNA_LJFORN',oCNCDetail:GetValue('CNC_LOJA'))

			oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
			oCNADetail:SetValue('CNA_NUMERO',cItPla)
			oCNADetail:SetValue('CNA_DTINI'	,dDataBase)
			oCNADetail:LoadValue('CNA_FLREAJ',oModel:GetValue("CN9MASTER", "CN9_FLGREJ"))
		Else
			oCNADetail:GoLine(nLinhaPla)//-- Posiciona na ultima planilha inclusa.
		EndIf

		CNTA300BlMd(oModel:GetModel( 'CNBDETAIL' ), .F.)

		If (cItemCNB <> cItPlaZero)
			oCNBDetail:AddLine()
		EndIf
		cItemCNB := Soma1(cItemCNB)
		oCNBDetail:SetValue('CNB_ITEM',cItemCNB)

		oCNBDetail:SetValue('CNB_PRODUT',PadR(aFornCtr[nI][12],Len(CNB->CNB_PRODUT)))
		oCNBDetail:SetValue('CNB_GCPIT',StrZero(nI, nTamItCNB))
		oCNBDetail:SetValue('CNB_GCPLT',"")

		oCNBDetail:SetValue('CNB_QUANT',aFornCtr[nI][5])
		oCNBDetail:SetValue('CNB_VLUNIT',aFornCtr[nI][9])
		oCNBDetail:SetValue('CNB_VLTOTR',aFornCtr[nI][10])

		cTipPro := GetAdvFVal("SB5", "B5_TIPO", xFilSB5 + aFornCtr[nI][12], 1)
	Next nI

	oCNADetail:GoLine(1)
	oCNBDetail:GoLine(1)
	GCP017BMod(oModel,{'CNBDETAIL'},.T.)

Return
