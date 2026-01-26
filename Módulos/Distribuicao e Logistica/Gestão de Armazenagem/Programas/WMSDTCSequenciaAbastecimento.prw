#Include "Totvs.ch"
#Include "WMSDTCSequenciaAbastecimento.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0043
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0043()
Return Nil
//--------------------------------------
/*/{Protheus.doc} WMSDTCSequenciaAbastecimento
Classe sequencia de abastecimento
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//--------------------------------------
CLASS WMSDTCSequenciaAbastecimento FROM LongNameClass
	// Data
	DATA oNorma
	DATA cArmazem
	DATA cProduto
	DATA cServAbast
	DATA cOrdem
	DATA cEstFis
	DATA cDescSeq
	DATA cTipoRepos
	DATA nPercRepos
	DATA nPercApMax
	DATA cTipoSepar
	DATA nQtdMinSep
	DATA nQtdMinEnd
	DATA nNumUnitiz
	DATA cTipoSeq
	DATA cPriEnder
	DATA cTipoEnd
	DATA cUMMovto
	DATA cServico
	DATA lHasMinSep
	DATA lHasMinEnd
	DATA aSeqAbast AS Array
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cArmazAnt  // Performance
	DATA cProdutAnt // Performance
	DATA cOrdemAnt  // Performance
	DATA cEstFisAnt // Performance
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD SetArmazem(cArmazem)
	METHOD SetProduto(cProduto)
	METHOD SetSerAbas(cServAbast)
	METHOD SetOrdem(cOrdem)
	METHOD SetEstFis(cEstFis)
	METHOD SetCodNor(cCodNorma)
	METHOD SetDescSeq(cDescSeq)
	METHOD SetTipoRep(cTipoRepos)
	METHOD SetPercRep(nPercRepos)
	METHOD SetPerApMx(nPercApMax)
	METHOD SetTipoSep(cTipoSepar)
	METHOD SetQtMinSp(nQtdMinSep)
	METHOD SetQtMinEn(nQtdMinEnd)
	METHOD SetNumUnit(nNumUnitiz)
	METHOD SetTipoSeq(cTipoSeq)
	METHOD SetTipoEnd(cTipoEnd)
	METHOD SetServico(cServico)
	METHOD SetUMMovto(cUMMovto)
	METHOD GetArmazem()
	METHOD GetProduto()
	METHOD GetSerAbas()
	METHOD GetOrdem()
	METHOD GetEstFis()
	METHOD GetCodNor()
	METHOD GetDescSeq()
	METHOD GetTipoRep()
	METHOD GetPercRep()
	METHOD GetPerApMx()
	METHOD GetTipoSep()
	METHOD GetQtMinSp()
	METHOD GetQtMinEn()
	METHOD GetNumUnit()
	METHOD GetTipoSeq()
	METHOD GetTipoEnd()
	METHOD GetDisSep()
	METHOD GetUMMovto()
	METHOD GetArrSeqA()
	METHOD SeqAbast()
	METHOD FindSeqAbt()
	METHOD PrdTemPulm()
	METHOD PrdTemPkg()
	METHOD ApMaxPic()
	METHOD HasMinSep()
	METHOD HasMinEnd()
	METHOD HasPickMas(lPickMas)
	METHOD HasPickMasAbas()
	METHOD GetNorma()
	METHOD GetErro()
	METHOD Destroy()
	METHOD EstFisPul()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCSequenciaAbastecimento
	Self:oNorma     := WMSDTCNormaPaletizacao():New()
	Self:cArmazem   := PadR("", TamSx3("DC3_LOCAL")[1])
	Self:cProduto   := PadR("", TamSx3("DC3_CODPRO")[1])
	Self:cServAbast := PadR("", TamSx3("DC3_REABAS")[1])
	Self:cOrdem     := PadR("", TamSx3("DC3_ORDEM")[1])
	Self:cEstFis    := PadR("", TamSx3("DC3_TPESTR")[1])
	Self:cArmazAnt  := PadR("", Len(Self:cArmazem))
	Self:cProdutAnt := PadR("", Len(Self:cProduto))
	Self:cOrdemAnt  := PadR("", Len(Self:cOrdem))
	Self:cEstFisAnt := PadR("", Len(Self:cEstFis))
	Self:cDescSeq   := PadR("", TamSx3("DC3_DESPIC")[1])
	Self:cTipoSeq   := PadR("", TamSx3("DC3_EMBDES")[1])
	Self:cTipoSepar := PadR("", TamSx3("DC3_TIPSEP")[1])
	Self:nPercRepos := 0
	Self:nPercApMax := 0
	Self:nQtdMinSep := 0
	Self:nQtdMinEnd := 0
	Self:nNumUnitiz := 0
	Self:cTipoRepos := "1"
	Self:cPriEnder  := "1"
	Self:cTipoEnd   := "1"
	Self:cUMMovto   := "1"
	Self:lHasMinSep := .F.
	Self:lHasMinEnd := .F.
	Self:aSeqAbast  := {}
	Self:nRecno     := 0
	Self:cErro      := ""
Return

METHOD Destroy() CLASS WMSDTCSequenciaAbastecimento
	//Mantido para compatibilidade
Return Nil

METHOD LoadData(nIndex) CLASS WMSDTCSequenciaAbastecimento
Local lRet        := .T.
Local lCarrega    := .T.
Local aDC3_PERREP := TamSx3("DC3_PERREP")
Local aDC3_PERAPM := TamSx3("DC3_PERAPM")
Local aDC3_QTDUNI := TamSx3("DC3_QTDUNI")
Local aDC3_NUNITI := TamSx3("DC3_NUNITI")
Local aAreaAnt    := GetArea()
Local aAreaDC3    := GetArea()
Local cAliasDC3   := Nil
Local nApMinimo   := 1 / (10 ** TamSX3('DC3_QTDUNI')[2])
Local nEnMinimo   := 1 / (10 ** TamSX3('DC3_ENDMIN')[2])
Default nIndex := 1
	Do Case
		Case nIndex == 1 // DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_ORDEM
			If (Empty(Self:cProduto) .OR. Empty(Self:cArmazem))
				lRet := .F.
			Else
				If Self:cProduto == Self:cProdutAnt .And. Self:cArmazem == Self:cArmazAnt .And. Self:cOrdem == Self:cOrdemAnt
					lCarrega = .F.
				EndIf
			EndIf
		Case nIndex == 2 // DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_TPESTR
			If (Empty(Self:cProduto) .OR. Empty(Self:cArmazem) .OR. Empty(Self:cEstFis))
				lRet := .F.
			Else
				If Self:cProduto == Self:cProdutAnt .And. Self:cArmazem == Self:cArmazAnt .And. Self:cEstFis == Self:cEstFisAnt
					lCarrega = .F.
				EndIf
			EndIf
		OtherWise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		If lCarrega
			cAliasDC3  := GetNextAlias()
			Do Case
				Case nIndex == 1
					If !Empty(Self:cOrdem)
						BeginSql Alias cAliasDC3
							SELECT DC3.DC3_CODPRO,
									DC3.DC3_LOCAL,
									DC3.DC3_ORDEM,
									DC3.DC3_REABAS,
									DC3.DC3_CODNOR,
									DC3.DC3_TPESTR,
									DC3.DC3_DESPIC,
									DC3.DC3_TIPREP,
									DC3.DC3_PERAPM,
									DC3.DC3_PERREP,
									DC3.DC3_TIPSEP,
									DC3.DC3_QTDUNI,
									DC3.DC3_ENDMIN,
									DC3.DC3_NUNITI,
									DC3.DC3_EMBDES,
									DC3.DC3_PRIEND,
									DC3.DC3_TIPEND,
									DC3.DC3_UMMOV,
									DC3.R_E_C_N_O_ RECNODC3
							FROM %Table:DC3% DC3
							WHERE DC3.DC3_FILIAL = %xFilial:DC3%
							AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
							AND DC3.DC3_LOCAL =  %Exp:Self:cArmazem%
							AND DC3.DC3_ORDEM =  %Exp:Self:cOrdem%
							AND DC3.%NotDel%
							ORDER BY DC3.DC3_ORDEM
						EndSql
					Else
						BeginSql Alias cAliasDC3
							SELECT DC3.DC3_CODPRO,
									DC3.DC3_LOCAL,
									DC3.DC3_ORDEM,
									DC3.DC3_REABAS,
									DC3.DC3_CODNOR,
									DC3.DC3_TPESTR,
									DC3.DC3_DESPIC,
									DC3.DC3_TIPREP,
									DC3.DC3_PERAPM,
									DC3.DC3_PERREP,
									DC3.DC3_TIPSEP,
									DC3.DC3_QTDUNI,
									DC3.DC3_ENDMIN,
									DC3.DC3_NUNITI,
									DC3.DC3_EMBDES,
									DC3.DC3_PRIEND,
									DC3.DC3_TIPEND,
									DC3.DC3_UMMOV,
									DC3.R_E_C_N_O_ RECNODC3
							FROM %Table:DC3% DC3
							WHERE DC3.DC3_FILIAL = %xFilial:DC3%
							AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
							AND DC3.DC3_LOCAL =  %Exp:Self:cArmazem%
							AND DC3.%NotDel%
							ORDER BY DC3.DC3_ORDEM
						EndSql
					EndIf
				Case nIndex == 2
					BeginSql Alias cAliasDC3
						SELECT DC3.DC3_CODPRO,
								DC3.DC3_LOCAL,
								DC3.DC3_ORDEM,
								DC3.DC3_REABAS,
								DC3.DC3_CODNOR,
								DC3.DC3_TPESTR,
								DC3.DC3_DESPIC,
								DC3.DC3_TIPREP,
								DC3.DC3_PERAPM,
								DC3.DC3_PERREP,
								DC3.DC3_TIPSEP,
								DC3.DC3_QTDUNI,
								DC3.DC3_ENDMIN,
								DC3.DC3_NUNITI,
								DC3.DC3_EMBDES,
								DC3.DC3_PRIEND,
								DC3.DC3_TIPEND,
								DC3.DC3_UMMOV,
								DC3.R_E_C_N_O_ RECNODC3
						FROM %Table:DC3% DC3
						WHERE DC3.DC3_FILIAL = %xFilial:DC3%
						AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
						AND DC3.DC3_LOCAL =  %Exp:Self:cArmazem%
						AND DC3.DC3_TPESTR = %Exp:Self:cEstFis%
						AND DC3.%NotDel%
						ORDER BY DC3.DC3_ORDEM
					EndSql
			EndCase
			TCSetField(cAliasDC3,'DC3_PERREP','N',aDC3_PERREP[1],aDC3_PERREP[2])
			TCSetField(cAliasDC3,'DC3_PERAPM','N',aDC3_PERAPM[1],aDC3_PERAPM[2])
			TCSetField(cAliasDC3,'DC3_QTDUNI','N',aDC3_QTDUNI[1],aDC3_QTDUNI[2])
			TCSetField(cAliasDC3,'DC3_NUNITI','N',aDC3_NUNITI[1],aDC3_NUNITI[2])
			lRet := (cAliasDC3)->(!Eof())
			If lRet
				Self:cArmazem   := (cAliasDC3)->DC3_LOCAL
				Self:cProduto   := (cAliasDC3)->DC3_CODPRO
				Self:cServAbast := (cAliasDC3)->DC3_REABAS
				Self:cOrdem     := (cAliasDC3)->DC3_ORDEM
				Self:cEstFis    := (cAliasDC3)->DC3_TPESTR
				If (DCF->DCF_CODNOR # (cAliasDC3)->DC3_CODNOR .And. DCF->DCF_ORIGEM == "SD1",Self:SetCodNor(DCF->DCF_CODNOR),Self:SetCodNor((cAliasDC3)->DC3_CODNOR))
				Self:oNorma:LoadData()
				Self:cDescSeq   := (cAliasDC3)->DC3_DESPIC
				Self:cTipoRepos := (cAliasDC3)->DC3_TIPREP
				Self:nPercRepos := (cAliasDC3)->DC3_PERREP
				Self:nPercApMax := (cAliasDC3)->DC3_PERAPM
				Self:cTipoSepar := (cAliasDC3)->DC3_TIPSEP
				Self:nQtdMinSep := IIf((cAliasDC3)->DC3_QTDUNI > 0,(cAliasDC3)->DC3_QTDUNI,nApMinimo)
				Self:nQtdMinEnd := IIf((cAliasDC3)->DC3_ENDMIN > 0,(cAliasDC3)->DC3_ENDMIN,nEnMinimo)
				Self:lHasMinSep := (cAliasDC3)->DC3_QTDUNI > 0
				Self:lHasMinEnd := (cAliasDC3)->DC3_ENDMIN > 0
				Self:nNumUnitiz := (cAliasDC3)->DC3_NUNITI
				Self:cTipoSeq   := (cAliasDC3)->DC3_EMBDES
				Self:cPriEnder  := (cAliasDC3)->DC3_PRIEND
				Self:cTipoEnd   := IIf(Empty((cAliasDC3)->DC3_TIPEND),"1",(cAliasDC3)->DC3_TIPEND)
				Self:cUMMovto   := IIf(Empty((cAliasDC3)->DC3_UMMOV),"1",(cAliasDC3)->DC3_UMMOV)
				Self:nRecno     := (cAliasDC3)->RECNODC3
				// Controle dados anteriores
				Self:cProdutAnt := Self:cProduto
				Self:cArmazAnt  := Self:cArmazem
				Self:cOrdemAnt  := Self:cOrdem
				Self:cEstFisAnt := Self:cEstFis
				// Ponto de Entrada para permitir alterar as informações da sequencia de abastecimento
				// Recebe o objeto
				If ExistBlock('WMSLDDC3')
					ExecBlock('WMSLDDC3',.F.,.F.,Self)
				EndIf
			Else
				Self:cErro := WmsFmtMsg(STR0002,{{"[VAR01]",AllTrim(Self:cProduto)},{"[VAR02]",AllTrim(Self:cArmazem)},{"[VAR03]",AllTrim(Self:cEstFis)}}) // Produto [VAR01] para o armazem [VAR02] na estrutura física [VAR03] Não cadastrado!
				lRet := .F.
			EndIf
			(cAliasDC3)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaDC3)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetArmazem(cArmazem) CLASS WMSDTCSequenciaAbastecimento
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return
METHOD SetProduto(cProduto) CLASS WMSDTCSequenciaAbastecimento
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return
METHOD SetSerAbas(cServAbast) CLASS WMSDTCSequenciaAbastecimento
	Self:cServAbast := PadR(cServAbast, Len(Self:cServAbast))
Return
METHOD SetOrdem(cOrdem) CLASS WMSDTCSequenciaAbastecimento
	Self:cOrdem := PadR(cOrdem, Len(Self:cOrdem))
Return
METHOD SetEstFis(cEstFis) CLASS WMSDTCSequenciaAbastecimento
	Self:cEstfis := PadR(cEstfis, Len(Self:cEstfis))
Return
METHOD SetCodNor(cCodNorma) CLASS WMSDTCSequenciaAbastecimento
	Self:oNorma:cCodNorma := PadR(cCodNorma, Len(Self:oNorma:cCodNorma))
Return
METHOD SetDescSeq(cDescSeq) CLASS WMSDTCSequenciaAbastecimento
	Self:cDescSeq := PadR(cDescSeq, Len(Self:cDescSeq))
Return
METHOD SetTipoRep(cTipoRepos) CLASS WMSDTCSequenciaAbastecimento
	Self:cTipoRepos := PadR(cTipoRepos, Len(Self:cTipoRepos))
Return
METHOD SetPercRep(nPercRepos) CLASS WMSDTCSequenciaAbastecimento
	Self:nPercRepos := nPercRepos
Return
METHOD SetPerApMx(nPercApMax) CLASS WMSDTCSequenciaAbastecimento
	Self:nPercApMax := nPercApMax
Return
METHOD SetTipoSep(cTipoSepar) CLASS WMSDTCSequenciaAbastecimento
	Self:cTipoSepar := PadR(cTipoSepar, Len(Self:cTipoSepar))
Return
METHOD SetQtMinSp(nQtdMinSep) CLASS WMSDTCSequenciaAbastecimento
	Self:nQtdMinSep := nQtdMinSep
	Self:lHasMinSep := Self:nQtdMinSep >0
Return
METHOD SetQtMinEn(nQtdMinEnd) CLASS WMSDTCSequenciaAbastecimento
	Self:nQtdMinEnd := nQtdMinEnd
	Self:lHasMinEnd := Self:nQtdMinEnd >0
Return
METHOD SetNumUnit(nNumUnitiz) CLASS WMSDTCSequenciaAbastecimento
	Self:nNumUnitiz := nNumUnitiz
Return
METHOD SetTipoSeq(cTipoSeq) CLASS WMSDTCSequenciaAbastecimento
	Self:cTipoSeq := PadR(cTipoSeq, Len(Self:cTipoSeq))
Return
METHOD SetTipoEnd(cTipoEnd) CLASS WMSDTCSequenciaAbastecimento
	Self:cTipoEnd := cTipoEnd
Return
METHOD SetServico(cServico) CLASS WMSDTCSequenciaAbastecimento
	Self:cServico := cServico
Return
METHOD SetUMMovto(cUMMovto) CLASS WMSDTCSequenciaAbastecimento
	Self:cUMMovto := cUMMovto
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetArmazem() CLASS WMSDTCSequenciaAbastecimento
Return Self:cArmazem

METHOD GetProduto() CLASS WMSDTCSequenciaAbastecimento
Return Self:cProduto

METHOD GetSerAbas() CLASS WMSDTCSequenciaAbastecimento
Return Self:cServAbast

METHOD GetOrdem() CLASS WMSDTCSequenciaAbastecimento
Return Self:cOrdem

METHOD GetEstFis() CLASS WMSDTCSequenciaAbastecimento
Return Self:cEstFis

METHOD GetCodNor() CLASS WMSDTCSequenciaAbastecimento
Return Self:oNorma:GetCodNor()

METHOD GetDescSeq() CLASS WMSDTCSequenciaAbastecimento
Return Self:cDescSeq

METHOD GetTipoRep() CLASS WMSDTCSequenciaAbastecimento
Return Self:cTipoRepos

METHOD GetPercRep() CLASS WMSDTCSequenciaAbastecimento
Return Self:nPercRepos

METHOD GetPerApMx() CLASS WMSDTCSequenciaAbastecimento
Return Self:nPercApMax

METHOD GetTipoSep() CLASS WMSDTCSequenciaAbastecimento
Return Self:cTipoSepar

METHOD GetQtMinSp() CLASS WMSDTCSequenciaAbastecimento
Return Self:nQtdMinSep

METHOD GetQtMinEn() CLASS WMSDTCSequenciaAbastecimento
Return Self:nQtdMinEnd

METHOD GetNumUnit() CLASS WMSDTCSequenciaAbastecimento
Return Self:nNumUnitiz

METHOD GetTipoSeq() CLASS WMSDTCSequenciaAbastecimento
Return Self:cTipoSeq

METHOD GetTipoEnd() CLASS WMSDTCSequenciaAbastecimento
Return Self:cTipoEnd

METHOD GetUMMovto() CLASS WMSDTCSequenciaAbastecimento
Return Self:cUMMovto

METHOD GetErro() CLASS WMSDTCSequenciaAbastecimento
Return Self:cErro

METHOD GetArrSeqA() CLASS WMSDTCSequenciaAbastecimento
Return Self:aSeqAbast

METHOD GetNorma() CLASS WMSDTCSequenciaAbastecimento
Return DLQtdNorma(Self:cProduto,Self:cArmazem,Self:cEstfis,,.F.)

METHOD HasMinSep() CLASS WMSDTCSequenciaAbastecimento
Return Self:lHasMinSep

METHOD HasMinEnd()  CLASS WMSDTCSequenciaAbastecimento
Return Self:lHasMinEnd

METHOD SeqAbast(nProcesso) CLASS WMSDTCSequenciaAbastecimento
Local lRet        := .T.
Local lRetPE      := .F.
Local cTipoEstr   := "% '1','2','3','4','6' %"
Local lWMSSQAB1   := ExistBlock("WMSSQAB1")
Local lWMSSQAB2   := ExistBlock("WMSSQAB2")
Local lHasPkMas   := Self:HasPickMasAbas() // Verifica se estrutura tem master
Local aAreaDC3    := GetArea()
Local cAliasDC3   := Nil
Local lPrioPick   := SuperGetMV("MV_ENPK",.F.,.F.) .Or. SuperGetMV("MV_WMSENPK",.F.,.F.) //O parâmetro MV_ENPK será descontinuado
Local nSalPulmao  := 0
Local nI          := 0
Local aEstPulmao  := {}
	/*
	Tipo Estruturas
	1=Pulmao
	2=Picking
	3=Cross Docking
	4=Blocado
	5=Box/Doca
	6=Blocado Fracionado
	7=Produção
	8=Qualidade
	*/
	If Empty(nProcesso)
		lRet       := .F.
		Self:cErro := STR0001 // Dados para busca não foram informados!
	EndIf
	If lRet .And. Self:LoadData()
		Self:aSeqAbast := {}
		cAliasDC3 := GetNextAlias()

		Do Case
			Case nProcesso == 1 // Endereçamento

				If lPrioPick
					aEstPulmao := Self:EstFisPul()
					If Len(aEstPulmao) > 0
						For nI := 1 to Len(aEstPulmao)
							oEstEnder := WMSDTCEstoqueEndereco():New()
							oEstEnder:oEndereco:SetArmazem(Self:cArmazem)
							oEstEnder:oEndereco:SetEstFis(aEstPulmao[nI]) // Est Fis.
							oEstEnder:oProdLote:SetArmazem(Self:cArmazem) // Armazem
							oEstEnder:oProdLote:SetProduto(Self:cProduto) // Componente
							oEstEnder:LoadData()
							nSalPulmao += oEstEnder:ConsultSld(.F.,.F.,.F.,.F.)
						Next
						If nSalPulmao == 0 //Se prioriza Picking e não tem saldo no Pulmão
							Self:cPriEnder := "1"
						EndIf
					EndIf
				EndIf

				If Self:cPriEnder == "2" // Prioridade de endereçamento 1-Picking/2-Pulmão

					If lWMSSQAB2
						cTipoEstr:= ExecBlock('WMSSQAB2', .F., .F.,{cTipoEstr,Self:cArmazem,Self:cProduto})
					EndIf

					BeginSql Alias cAliasDC3
						SELECT CASE DC8.DC8_TPESTR
									WHEN '1' THEN 1
									WHEN '2' THEN 2
									WHEN '6' THEN 3
									WHEN '4' THEN 4
									WHEN '3' THEN 5 END REGRA,
								DC3.DC3_ORDEM,
								DC3.DC3_TPESTR,
								DC3.DC3_QTDUNI,
								DC8.DC8_TPESTR
						FROM %Table:DC3% DC3
						INNER JOIN %Table:DC8% DC8
						ON DC8.DC8_FILIAL = %xFilial:DC8%
						AND DC8.DC8_CODEST = DC3_TPESTR
						AND DC8.DC8_TPESTR IN (%Exp:cTipoEstr% ) // Considera somente as estruturas: (1=Pulmao;2=Picking;3=Cross Docking;4=Blocado;6=Blocado Fracionado)
						WHERE DC3.DC3_FILIAL = %xFilial:DC3%
						AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
						AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
						AND DC3.DC3_EMBDES = '1' // Considera somente Sequencias de Abastecimento (nao utiliza Sequencias de Embarque/Desembarque)
						AND DC3.%NotDel%
						ORDER BY REGRA,
									DC3.DC3_ORDEM
					EndSql
				Else
					BeginSql Alias cAliasDC3
						SELECT CASE DC8.DC8_TPESTR
									WHEN '2' THEN 1
									WHEN '1' THEN 2
									WHEN '6' THEN 3
									WHEN '4' THEN 4
									WHEN '3' THEN 5 END REGRA,
								DC3.DC3_ORDEM,
								DC3.DC3_TPESTR,
								DC3.DC3_QTDUNI,
								DC8.DC8_TPESTR
						FROM %Table:DC3% DC3
						INNER JOIN %Table:DC8% DC8
						ON DC8.DC8_FILIAL = %xFilial:DC8%
						AND DC8.DC8_CODEST = DC3_TPESTR
						AND DC8.DC8_TPESTR IN ('1','2','3','4','6') // Considera somente as estruturas: (1=Pulmao;2=Picking;3=Cross Docking;4=Blocado;6=Blocado Fracionado)
						WHERE DC3.DC3_FILIAL = %xFilial:DC3%
						AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
						AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
						AND DC3.DC3_EMBDES = '1' // Considera somente Sequencias de Abastecimento (nao utiliza Sequencias de Embarque/Desembarque)
						AND DC3.%NotDel%
						ORDER BY REGRA,
									DC3.DC3_ORDEM
					EndSql
				EndIf

			Case nProcesso == 2 // Separação com ou sem volume
				BeginSql Alias cAliasDC3
					SELECT CASE DC8.DC8_TPESTR
								WHEN '4' THEN 1
								WHEN '6' THEN 2
								WHEN '1' THEN 3
								WHEN '2' THEN 4
								WHEN '3' THEN 5 END REGRA,
							DC3.DC3_ORDEM,
							DC3.DC3_TPESTR,
							DC3.DC3_QTDUNI,
							DC8.DC8_TPESTR
					FROM %Table:DC3% DC3
					INNER JOIN %Table:DC8% DC8
					ON DC8.DC8_FILIAL = %xFilial:DC8%
					AND DC8.DC8_CODEST = DC3_TPESTR
					AND DC8.DC8_TPESTR IN ('1','2','3','4','6') // Considera somente as estruturas: (1=Pulmao;2=Picking;3=Cross Docking;4=Blocado;6=Blocado Fracionado)
					AND DC3.%NotDel%
					ORDER BY REGRA,
								DC3.DC3_QTDUNI DESC,
								DC3.DC3_ORDEM
				EndSql
			Case nProcesso == 3 // Separaçao cross docking com e sem volume
				BeginSql Alias cAliasDC3
					SELECT CASE DC8.DC8_TPESTR
								WHEN '3' THEN 1
								WHEN '6' THEN 2
								WHEN '4' THEN 3
								WHEN '1' THEN 4
								WHEN '2' THEN 5 END REGRA,
							DC3.DC3_ORDEM,
							DC3.DC3_TPESTR,
							DC3.DC3_QTDUNI,
							DC8.DC8_TPESTR
					FROM %Table:DC3% DC3
					INNER JOIN %Table:DC8% DC8
					ON DC8.DC8_FILIAL = %xFilial:DC8%
					AND DC8.DC8_CODEST = DC3_TPESTR
					AND DC8.DC8_TPESTR IN ('1','2','3','4','6') // Considera somente as estruturas: (1=Pulmao;2=Picking;3=Cross Docking;4=Blocado;6=Blocado Fracionado)
					AND DC8.%NotDel%
					WHERE DC3.DC3_FILIAL = %xFilial:DC3%
					AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
					AND DC3.DC3_LOCAL =  %Exp:Self:cArmazem%
					AND DC3.DC3_EMBDES = '1' // Considera somente Sequencias de Abastecimento (nao utiliza Sequencias de Embarque/Desembarque)
					AND DC3.%NotDel%
					ORDER BY REGRA,
								DC3.DC3_QTDUNI DESC,
								DC3.DC3_ORDEM
				EndSql
			Case nProcesso == 4 // Abastecimento
				If lHasPkMas
					BeginSql Alias cAliasDC3
						SELECT CASE DC8.DC8_TPESTR
									WHEN '1' THEN 1 END REGRA,
								DC3.DC3_ORDEM,
								DC3.DC3_TPESTR,
								DC3.DC3_QTDUNI,
								DC8.DC8_TPESTR
						FROM %Table:DC3% DC3
						INNER JOIN %Table:DC8% DC8
						ON DC8.DC8_FILIAL = %xFilial:DC8%
						AND DC8.DC8_CODEST = DC3_TPESTR
						AND DC8.DC8_TPESTR in ('2','1') // Somente estrutura picking
						AND DC8.%NotDel%
						WHERE DC3.DC3_FILIAL = %xFilial:DC3%
						AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
						AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
						AND DC3.DC3_EMBDES = '1' // Considera somente Sequencias de Abastecimento (nao utiliza Sequencias de Embarque/Desembarque)
						AND DC3.DC3_TPESTR <> %Exp:Self:cEstfis%
						AND (DC3.DC3_QTDUNI >= %Exp:Self:nQtdMinSep% OR DC8.DC8_TPESTR = '1')
 						AND DC3.%NotDel%
						ORDER BY REGRA,
									DC8.DC8_TPESTR DESC,
									DC3.DC3_QTDUNI DESC,
									DC3.DC3_ORDEM
					EndSql
				Else
					BeginSql Alias cAliasDC3
						SELECT CASE DC8.DC8_TPESTR
									WHEN '1' THEN 1 END REGRA,
								DC3.DC3_ORDEM,
								DC3.DC3_TPESTR,
								DC3.DC3_QTDUNI,
								DC8.DC8_TPESTR
						FROM %Table:DC3% DC3
						INNER JOIN %Table:DC8% DC8
						ON DC8.DC8_FILIAL = %xFilial:DC8%
						AND DC8.DC8_CODEST = DC3_TPESTR
						AND DC8.DC8_TPESTR = '1' // Somente estrutura pulmao
						AND DC8.%NotDel%
						WHERE DC3.DC3_FILIAL = %xFilial:DC3%
						AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
						AND DC3.DC3_LOCAL =  %Exp:Self:cArmazem%
						AND DC3.DC3_EMBDES = '1' // Considera somente Sequencias de Abastecimento (nao utiliza Sequencias de Embarque/Desembarque)
						AND DC3.%NotDel%
						ORDER BY REGRA,
									DC8.DC8_TPESTR DESC,
									DC3.DC3_QTDUNI DESC,
									DC3.DC3_ORDEM
					EndSql
				EndIf
			Case nProcesso == 5 // Endereçamento Crossdoking
				BeginSql Alias cAliasDC3
					SELECT CASE DC8.DC8_TPESTR
								WHEN '3' THEN 1
								WHEN '6' THEN 2
								WHEN '4' THEN 3
								WHEN '1' THEN 4
								WHEN '2' THEN 5
								WHEN '5' THEN 6 END REGRA, // CrossDoking permite armazenar em estrutura box/doca diferente do endereço origem
							DC3.DC3_ORDEM,
							DC3.DC3_TPESTR,
							DC3.DC3_QTDUNI,
							DC8.DC8_TPESTR
					FROM %Table:DC3% DC3
					INNER JOIN %Table:DC8% DC8
					ON DC8.DC8_FILIAL = %xFilial:DC8%
					AND DC8.DC8_CODEST = DC3_TPESTR
					AND DC8.DC8_TPESTR IN ('1','2','3','5','4','6') // Considera somente as estruturas: (1=Pulmao;2=Picking;3=Cross Docking;4=Blocado;5=Box/Doca;6=Blocado Fracionado)
					AND DC8.%NotDel%
					WHERE DC3.DC3_FILIAL = %xFilial:DC3%
					AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
					AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
					AND DC3.DC3_EMBDES = '1' // Considera somente Sequencias de Abastecimento (nao utiliza Sequencias de Embarque/Desembarque)
					AND DC3.%NotDel%
					ORDER BY REGRA,
								DC3.DC3_ORDEM
				EndSql
			Case nProcesso == 6
				BeginSql Alias cAliasDC3
					SELECT CASE DC8.DC8_TPESTR
								WHEN '2' THEN 1 END REGRA, // Separação (regra 4, geração de reabastecimento por demanda)
							DC3.DC3_ORDEM,
							DC3.DC3_TPESTR,
							DC3.DC3_QTDUNI,
							DC8.DC8_TPESTR
					FROM %Table:DC3% DC3
					INNER JOIN %Table:DC8% DC8
					ON DC8.DC8_FILIAL = %xFilial:DC8%
					AND DC8.DC8_CODEST = DC3_TPESTR
					AND DC8.DC8_TPESTR = '2' // Somente estrutura picking
					AND DC8.%NotDel%
					WHERE DC3.DC3_FILIAL = %xFilial:DC3%
					AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
					AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
					AND DC3.DC3_EMBDES = '1' // Considera somente Sequencias de Abastecimento (nao utiliza Sequencias de Embarque/Desembarque)
					AND DC3.%NotDel%
					ORDER BY REGRA,
								DC3.DC3_ORDEM
				EndSql
		EndCase
		Do While (cAliasDC3)->(!Eof())
			// Ponto de entrada para validar se considera estrutura física
			If lWMSSQAB1
				lRetPE:= ExecBlock('WMSSQAB1', .F., .F., {(cAliasDC3)->DC3_TPESTR,Self:cServico})
				If ValType(lRetPE)=="L" .And. !lRetPE
					(cAliasDC3)->(dbSkip())
					Loop
				EndIf
			EndIf
			AAdd(Self:aSeqAbast,{(cAliasDC3)->DC3_ORDEM,(cAliasDC3)->DC3_TPESTR,(cAliasDC3)->DC8_TPESTR})
			(cAliasDC3)->(dbSkip())
		EndDo
		(cAliasDC3)->(DbCloseArea())
	EndIf
	RestArea(aAreaDC3)
Return lRet

METHOD PrdTemPulm() CLASS WMSDTCSequenciaAbastecimento
Local lRet      := .F.
Local aAreaDC3  := GetArea()
Local cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DC3.DC3_TPESTR
		FROM %Table:DC3% DC3
		INNER JOIN %Table:DC8% DC8
		ON DC8.DC8_FILIAL = %xFilial:DC8%
		AND DC8.DC8_CODEST = DC3.DC3_TPESTR
		AND DC8.DC8_TPESTR = '1'
		AND DC8.%NotDel%
		WHERE DC3.DC3_FILIAL = %xFilial:DC3%
		AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
		AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
		AND DC3.%NotDel%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaDC3)
Return lRet

METHOD PrdTemPkg() CLASS WMSDTCSequenciaAbastecimento
Local lRet      := .F.
Local aAreaDC3  := GetArea()
Local cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DC3.DC3_TPESTR
		FROM %Table:DC3% DC3
		INNER JOIN %Table:DC8% DC8
		ON DC8.DC8_FILIAL = %xFilial:DC8%
		AND DC8.DC8_CODEST = DC3.DC3_TPESTR
		AND DC8.DC8_TPESTR = '2'
		AND DC8.%NotDel%
		WHERE DC3.DC3_FILIAL = %xFilial:DC3%
		AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
		AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
		AND DC3.%NotDel%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaDC3)
Return lRet
/*/-----------------------------------------------------------------------------
Retorna a quantidade máxima de apanhe para o picking com base no percentual
máximo de apanhe
-----------------------------------------------------------------------------/*/
METHOD ApMaxPic() CLASS WMSDTCSequenciaAbastecimento
Local nQtdApMax := 0
Local nQtdApUni := Self:nQtdMinSep
Local nQtdNorma := DLQtdNorma(Self:cProduto,Self:cArmazem,Self:cEstFis,/*cDesUni*/,.F.)
	// Assume valores padrão caso estejam zerados
	Self:nPercApMax := Iif(QtdComp(Self:nPercApMax) > 0,Self:nPercApMax,100)
	Self:nNumUnitiz := Iif(QtdComp(Self:nNumUnitiz) > 0,Self:nNumUnitiz,1)
	// Calcula a quantidade máxima para apanhe
	nQtdApMax := (nQtdNorma * Self:nNumUnitiz * Self:nPercApMax) / 100
	//Garante que a quantidade retornada seja múltipla do apanhe unitário mínimo
	nQtdApMax := NoRound(nQtdApMax/nQtdApUni,0) * nQtdApUni
Return nQtdApMax

METHOD FindSeqAbt() CLASS WMSDTCSequenciaAbastecimento
Local lRet      := .F.
Local aAreaDC3  := GetArea()
Local cAliasDC3 := Nil
	If Self:LoadData(2)
		Self:aSeqAbast := {}
		cAliasDC3 := GetNextAlias()
		BeginSql Alias cAliasDC3
			SELECT DC3.DC3_ORDEM
			FROM %Table:DC3% DC3
			WHERE DC3.DC3_FILIAL = %xFilial:DC3%
			AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
			AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
			AND DC3.DC3_TPESTR = %Exp:Self:cEstfis%
			AND DC3.%NotDel%
		EndSql
		If (cAliasDC3)->(!Eof())
			AAdd(Self:aSeqAbast,{(cAliasDC3)->DC3_ORDEM})
		EndIf
		(cAliasDC3)->(DbCloseArea())
		lRet := .T.
	EndIf
	RestArea(aAreaDC3)
Return lRet

METHOD HasPickMas(lPickMas) CLASS WMSDTCSequenciaAbastecimento
Local lRet      := .F.
Local lWMSPkMa  := SuperGetMV("MV_WMSPKMA",.F.,.F.)
Local aAreaDC3  := GetArea()
Local cAliasQry := Nil
Local lRetPE    := .F.

Default lPickMas  := .F.

	If lWMSPkMa
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:DC3% DC3
			INNER JOIN %Table:DC8% DC8
			ON DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = DC3.DC3_TPESTR
			AND DC8.DC8_TPESTR = '2'
			AND DC8.%NotDel%
			WHERE DC3.DC3_FILIAL = %xFilial:DC3%
			AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
			AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
			AND DC3.DC3_QTDUNI > 1
			AND DC3.%NotDel%
		EndSql
		lRet := (cAliasQry)->(!Eof())
		(cAliasQry)->(DbCloseArea())
	Else
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:DC3% DC3
			INNER JOIN %Table:DC8% DC8
			ON DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = DC3.DC3_TPESTR
			AND DC8.DC8_TPESTR = '2'
			AND DC8.%NotDel%
			WHERE DC3.DC3_FILIAL = %xFilial:DC3%
			AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
			AND DC3.DC3_TPESTR <> %Exp:Self:cEstfis%
			AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
			AND DC3.DC3_QTDUNI > %Exp:Self:nQtdMinSep%
			AND DC3.%NotDel%
		EndSql
		lRet := (cAliasQry)->(!Eof())
		(cAliasQry)->(DbCloseArea())
	EndIf

	//Ponto de entrada para manipular o retorno da função HasPickMas
	If ExistBlock("WMSPKMAS")
		lRetPE := ExecBlock('WMSPKMAS',.F.,.F.,{lWMSPkMa,lRet,Self})
		If ValType(lRetPE) == 'L'
			lRet := lRetPE
		EndIf
	EndIf

	RestArea(aAreaDC3)
Return lRet

METHOD HasPickMasAbas() CLASS WMSDTCSequenciaAbastecimento
Local lRet      := .F.
Local lWMSPkMa  := SuperGetMV("MV_WMSPKMA",.F.,.F.)
Local aAreaDC3  := GetArea()
Local cAliasQry := Nil
Local lRetPE    := .F.

	If lWMSPkMa
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:DC3% DC3
			INNER JOIN %Table:DC8% DC8
			ON DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = DC3.DC3_TPESTR
			AND DC8.DC8_TPESTR = '2'
			AND DC8.%NotDel%
			WHERE DC3.DC3_FILIAL = %xFilial:DC3%
			AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
			AND DC3.DC3_LOCAL = %Exp:Self:cArmazem%
			AND DC3.DC3_QTDUNI > 1
			AND DC3.%NotDel%
		EndSql
		lRet := (cAliasQry)->(!Eof())
		(cAliasQry)->(DbCloseArea())
	EndIf

	//Ponto de entrada para manipular o retorno da função HasPickMas
	If ExistBlock("WMSPKMAS")
		lRetPE := ExecBlock('WMSPKMAS',.F.,.F.,{lWMSPkMa,lRet,Self})
		If ValType(lRetPE) == 'L'
			lRet := lRetPE
		EndIf
	EndIf

	RestArea(aAreaDC3)
Return lRet

/*/-----------------------------------------------------------------------------
Retorna o(s) código(s) do tipo da estrutura correspondente ao Pulmão
-----------------------------------------------------------------------------/*/
METHOD EstFisPul() CLASS WMSDTCSequenciaAbastecimento
Local cAliasQry := GetNextAlias()
Local aRet := {}

	BeginSql Alias cAliasQry
		SELECT DISTINCT(DC3.DC3_TPESTR)
		  FROM %Table:DC3% DC3
		 INNER JOIN %Table:DC8% DC8
		    ON DC8.DC8_FILIAL = %xFilial:DC8%
		   AND DC8.DC8_CODEST = DC3.DC3_TPESTR
		   AND DC8.DC8_TPESTR IN ('1')
		   AND DC8.%NotDel%
		 WHERE DC3.DC3_FILIAL = %xFilial:DC3%
		   AND DC3.DC3_CODPRO = %Exp:Self:cProduto%
		   AND DC3.DC3_LOCAL  = %Exp:Self:cArmazem%
		   AND DC3.%NotDel%
	EndSql
	While (cAliasQry)->(!Eof())
		AADD(aRet, (cAliasQry)->DC3_TPESTR)
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(DbCloseArea())

Return aRet
