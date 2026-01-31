#Include "Totvs.ch"   
#Include "WMSDTCRelacionamentoMovimentosServicoArmazem.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0040
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0040()
Return Nil
//--------------------------------------
/*/{Protheus.doc} WMSDTCRelacionamentoMovimentosServicoArmazem
Classe relacionamento ordem de servico e movimentos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//--------------------------------------
CLASS WMSDTCRelacionamentoMovimentosServicoArmazem FROM LongNameClass
	// Data
	DATA cIdOrigem
	DATA cIdDCF
	DATA cSequen
	DATA cIdMovto
	DATA cIdOpera
	DATA nQuant
	DATA nQuant2
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cIdOriAnt 
	DATA cIdDCFAnt 
	DATA cIdMovAnt 
	DATA cIdOperAnt
	DATA cSequenAnt	
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToDCR(nRecno)
	METHOD LoadData(nIndex)
	METHOD SetIdOrig(cIdOrigem)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetSequen(cSequen)
	METHOD SetIdMovto(cIdMovto)
	METHOD SetIdOpera(cIdOpera)
	METHOD SetQuant(nQuant)
	METHOD SetQuant2(nQuant2)
	METHOD GetIdOrig()
	METHOD GetIdDCF()
	METHOD GetSequen()
	METHOD GetIdMovto()
	METHOD GetIdOpera()
	METHOD GetQuant()
	METHOD GetQuant2()
	METHOD RecordDCR()
	METHOD UpdateDCR()
	METHOD DeleteDCR()
	METHOD UpdQtdDCR()
	METHOD UpdQtdMov(nQtdQuebra)
	METHOD FindIdDCF(cIdDCFRel,cSequenRel)
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS

METHOD New() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	Self:cIdOrigem  := PadR("", TamSx3("DCR_IDORI")[1])
	Self:cIdDCF     := PadR("", TamSx3("DCR_IDDCF")[1])
	Self:cIdMovto   := PadR("", TamSx3("DCR_IDMOV")[1])
	Self:cIdOpera   := PadR("", TamSx3("DCR_IDOPER")[1])
	Self:cSequen    := PadR("", TamSx3("DCR_SEQUEN")[1])
	Self:cIdOriAnt  := PadR("", Len(Self:cIdOrigem))
	Self:cIdDCFAnt  := PadR("", Len(Self:cIdDCF))
	Self:cIdMovAnt  := PadR("", Len(Self:cIdMovto))
	Self:cIdOperAnt := PadR("", Len(Self:cIdOpera))
	Self:cSequenAnt := PadR("", Len(Self:cSequen))
	Self:nQuant     := 0
	Self:nQuant2    := 0
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	//Mantido para compatibilidade
Return

METHOD GoToDCR(nRecno) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	Self:nRecno := nRecno
Return Self:LoadData(0)

METHOD LoadData(nIndex) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Local lRet        := .T.
Local lCarrega    := .T.
Local aAreaAnt    := GetArea()
Local aAreaDCR    := DCR->(GetArea())
Local aDCR_QUANT  := TamSX3("DCR_QUANT")
Local aDCR_QTSEUM := TamSX3("DCR_QTSEUM")
Local cAliasDCR   := Nil
Default nIndex := 1
	Do Case
		Case nIndex == 0 // R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // DCR_FILIAL+DCR_IDORI+DCR_IDDCF+DCR_IDMOV+DCR_IDOPER
			If (Empty(Self:cIdOrigem) .OR. Empty(Self:cIdDCF) .OR. Empty(Self:cSequen) .OR. Empty(Self:cIdMovto).OR. Empty(Self:cIdOpera))
				lRet := .F.
			Else
				If Self:cIdOrigem == Self:cIdOriAnt .And. Self:cIdDCF == Self:cIdDCFAnt .And. Self:cSequen == Self:cSequenAnt .And. Self:cIdMovto == Self:cIdMovAnt .And. Self:cIdOpera == Self:cIdOperAnt
					lCarrega := .F.
				EndIf
			EndIf
		Otherwise
			lRet := .F.
	EndCase	
	If !lRet
		Self:cErro := STR0002 // Dados para busca não foram informados!
	Else
		If lCarrega
			cAliasDCR   := GetNextAlias()
			Do Case
				Case nIndex == 0
					BeginSql Alias cAliasDCR
						SELECT DCR.DCR_IDORI,
								DCR.DCR_IDDCF,
								DCR.DCR_IDMOV,
								DCR.DCR_IDOPER,
								DCR.DCR_SEQUEN,
								DCR.DCR_QUANT,
								DCR.DCR_QTSEUM,
								DCR.R_E_C_N_O_ RECNODCR
						FROM %Table:DCR% DCR
						WHERE DCR.DCR_FILIAL = %xFilial:DCR%
						AND DCR.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
						AND DCR.%NotDel%
					EndSql
				Case nIndex == 1
					BeginSql Alias cAliasDCR
						SELECT DCR.DCR_IDORI,
								DCR.DCR_IDDCF,
								DCR.DCR_IDMOV,
								DCR.DCR_IDOPER,
								DCR.DCR_SEQUEN,
								DCR.DCR_QUANT,
								DCR.DCR_QTSEUM,
								DCR.R_E_C_N_O_ RECNODCR
						FROM %Table:DCR% DCR
						WHERE DCR.DCR_FILIAL = %xFilial:DCR%
						AND DCR.DCR_IDORI = %Exp:Self:cIdOrigem%
						AND DCR.DCR_IDDCF = %Exp:Self:cIdDCF%
						AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
						AND DCR.DCR_IDOPER =%Exp:Self:cIdOpera%
						AND DCR.DCR_SEQUEN = %Exp:Self:cSequen%
						AND DCR.%NotDel%
					EndSql
			EndCase
			TCSetField(cAliasDCR,'DCR_QUANT','N',aDCR_QUANT[1],aDCR_QUANT[2])
			TCSetField(cAliasDCR,'DCR_QTSEUM','N',aDCR_QTSEUM[1],aDCR_QTSEUM[2])
			lRet := (cAliasDCR)->(!Eof())
			If lRet
				Self:cIdOrigem  := (cAliasDCR)->DCR_IDORI
				Self:cIdDCF     := (cAliasDCR)->DCR_IDDCF
				Self:cIdMovto   := (cAliasDCR)->DCR_IDMOV
				Self:cIdOpera   := (cAliasDCR)->DCR_IDOPER
				Self:cSequen    := (cAliasDCR)->DCR_SEQUEN
				Self:nQuant     := (cAliasDCR)->DCR_QUANT
				Self:nQuant2    := (cAliasDCR)->DCR_QTSEUM
				Self:nRecno     := (cAliasDCR)->RECNODCR
				// Controle dados anteriores
				Self:cIdOriAnt  := Self:cIdOrigem
				Self:cIdDCFAnt  := Self:cIdDCF
				Self:cIdMovAnt  := Self:cIdMovto
				Self:cIdOperAnt := Self:cIdOpera
				Self:cSequenAnt := Self:cSequen
			Else
				Self:cErro := STR0003 // Relacionamento DCR/D12/DCF não cadastrado!"
				lRet := .F.
			EndIf
			(cAliasDCR)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaDCR)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetIdOrig(cIdOrigem) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	Self:cIdOrigem := PadR(cIdOrigem, Len(Self:cIdOrigem))
Return

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	Self:cIdDCF := PadR(cIdDCF, Len(Self:cIdDCF))
Return

METHOD SetSequen(cSequen) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	Self:cSequen := PadR(cSequen, Len(Self:cSequen))
Return

METHOD SetIdMovto(cIdMovto) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	Self:cIdMovto := PadR(cIdMovto, Len(Self:cIdMovto))
Return

METHOD SetIdOpera(cIdOpera) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	Self:cIdOpera := PadR(cIdOpera, Len(Self:cIdOpera))
Return

METHOD SetQuant(nQuant) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	Self:nQuant := nQuant
Return

METHOD SetQuant2(nQuant2) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
	Self:nQuant2 := nQuant2
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetIdOrig() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Return Self:cIdOrigem

METHOD GetIdDCF() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Return Self:cIdDCF

METHOD GetSequen() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Return Self:cSequen

METHOD GetIdMovto() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Return Self:cIdMovto

METHOD GetIdOpera() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Return Self:cIdOpera

METHOD GetQuant() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Return Self:nQuant

METHOD GetQuant2() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Return Self:nQuant2

METHOD RecordDCR() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Local lRet     := .T.
Local aAreaDCR := DCR->(GetArea())
	Reclock('DCR', .T.)
	DCR_FILIAL := xFilial('DCR')
	DCR_IDORI  := Self:cIdOrigem
	DCR_IDDCF  := Self:cIdDCF
	DCR_SEQUEN := Self:cSequen
	DCR_IDMOV  := Self:cIdMovto
	DCR_IDOPER := Self:cIdOpera
	DCR_QUANT  := Self:nQuant
	DCR_QTSEUM := Self:nQuant2
	DCR->( MsUnlock() )
	RestArea(aAreaDCR)
Return lRet

METHOD UpdateDCR() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Local lRet     := .T.
Local aAreaDCR := DCR->(GetArea())
	DCR->(dbGoTo(Self:nRecno))
	If Reclock('DCR', .F.)
		WmsConout('UpdateDCR - reclock ok recno / qtd / idori' + cValToChar(Self:nRecno) + ' / ' + cValToChar(Self:nQuant) + ' / ' + Self:cIdOrigem )
	Else
		WmsConout('UpdateDCR - reclock não ok recno / qtd / idori ' + cValToChar(Self:nRecno) + ' / ' + cValToChar(Self:nQuant) + ' /' + Self:cIdOrigem)
	EndIf		
	DCR_IDORI  := Self:cIdOrigem
	DCR_QUANT  := Self:nQuant
	DCR_QTSEUM := Self:nQuant2
	DCR->( MsUnlock())
	RestArea(aAreaDCR)
Return lRet

METHOD DeleteDCR() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Local lRet     := .T.
Local aAreaDCR := DCR->(GetArea())
	DCR->(dbGoTo(Self:nRecno))
	If RecLock("DCR",.F.)
		WmsConout('DeleteDCR - reclock ok ' + cValToChar(Self:nRecno))
	Else
		WmsConout('DeleteDCR - reclock não ok ' + cValToChar(Self:nRecno))
	EndIf		

	DCR->(dbDelete())
	DCR->(MsUnlock())

	//Temporário para verificar se registro foi excluído
	If Deleted()
		WmsConout('DeleteDCR - Registro excluído')
	Else
		WmsConout('DeleteDCR - Registro não excluído')
	EndIf

	/*DCR->(dbGoTo(Self:nRecno))
	WmsConout('DeleteDCR - Recno após exclusão ' + cValToChar(DCR->(Recno())))*/

	RestArea(aAreaDCR)
Return lRet

METHOD GetErro() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Return Self:cErro


METHOD FindIdDCF(cIdDCFRel,cSequenRel) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Local lRet      := .T.
Local aAreaDCR  := GetArea()
Local cAliasDCR := GetNextAlias()

Default cIdDCFRel  := ""
Default cSequenRel := ""
	BeginSql Alias cAliasDCR
		SELECT DCR.DCR_IDDCF,
				DCR.DCR_SEQUEN
		FROM %Table:DCR% DCR
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_IDDCF = DCR.DCR_IDORI
		AND D12.D12_IDMOV = DCR.DCR_IDMOV
		AND D12.D12_IDOPER = DCR.DCR_IDOPER
		AND D12.D12_STATUS <> '0'
		AND D12.%NotDel%
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
		AND DCR.DCR_IDOPER = %Exp:Self:cIdOpera%
		AND DCR.%NotDel%
	EndSQl
	If (cAliasDCR)->(!Eof())
		cIdDCFRel  := (cAliasDCR)->DCR_IDDCF
		cSequenRel := (cAliasDCR)->DCR_SEQUEN
	Else
		lRet := .F.
	EndIf
	(cAliasDCR)->(dbCloseArea())
	RestArea(aAreaDCR)
Return lRet

METHOD UpdQtdDCR() CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local oRelMovAux := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local cAliasDCR  := GetNextAlias()
	BeginSql Alias cAliasDCR
		SELECT DCR.R_E_C_N_O_ RECNODCR
		FROM %TAble:DCR% DCR
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDORI = %Exp:Self:cIdOrigem%
		AND DCR.DCR_IDDCF = %Exp:Self:cIdDCF%
		AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
		AND DCR.DCR_IDOPER = %Exp:Self:cIdOpera%
		AND DCR.DCR_SEQUEN = %Exp:Self:cSequen%
		AND DCR.%NotDel%
	EndSql
	If (cAliasDCR)->(!Eof())
		oRelMovAux:GoToDCR((cAliasDCR)->RECNODCR)
		If QtdComp(Self:GetQuant()) <= 0
			oRelMovAux:DeleteDCR()
		Else
			oRelMovAux:SetQuant(Self:GetQuant())
			oRelMovAux:SetQuant2(Self:GetQuant2())
			oRelMovAux:UpdateDCR()
		EndIf
	EndIf
	(cAliasDCR)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*---------------------------------------------------------
---UpdQtdMov
---Ajusta quantidade movimento
---Alexsander.correa 04/10/2016
---cOpcao, Caracter, 1=Todas as tarefas do movimento;2=Tarefa Atual;3=Ordem Tarefa posterior 
---lQtdMaior, Logico, (Consideração de quantidade maior que a original)
---nQtdDif, Numerico, (Quantidade de diferença quando a original)
---------------------------------------------------------*/
METHOD UpdQtdMov(nQtdQuebra,lBxEmp) CLASS WMSDTCRelacionamentoMovimentosServicoArmazem
Local lRet       := .T.
Local lEmpPrev   := .F.
Local aAreaD13   := D13->(GetArea())
Local oMovimento := WMSDTCMovimentosServicoArmazem():New()
Local oMovNew    := WMSDTCMovimentosServicoArmazem():New()
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oMovNewEst := WMSDTCMovimentosEstoqueEndereco():New()
Local cProduto   := ""
Local cIdDCFRel  := ""
Local cSequenRel := ""
Local cAliasD13  := Nil
	oMovimento:SetIdDCF(Self:GetIdOrig())
	oMovimento:SetIdMovto(Self:GetIdMovto())
	oMovimento:SetIdOpera(Self:GetIdOpera())
	If oMovimento:LoadData(4)
		If oMovimento:GetStatus() == '1'
			// Indica que baixa empenho
			lBxEmp := .T.
			If QtdComp(oMovimento:GetQtdMov()) <= QtdComp(nQtdQuebra)
				// Deve atribuir o status cancelado
				oMovimento:SetStatus('0')
				oMovimento:UpdateD12()
			Else
				// Deve alterar o movimento atual e gerar outro com a diferença
				nQtdDif  := oMovimento:GetQtdMov() - nQtdQuebra
				cPriori  := oMovimento:GetPriori()
				cSeqPri  := oMovimento:GetSeqPrio()
				// Atualiza quantidade da DCR
				If QtdComp(Self:GetQuant() - nQtdQuebra) > QtdComp(0) 
					Self:SetQuant(Self:GetQuant() - nQtdQuebra)
					Self:SetQuant2(ConvUm(oMovimento:oMovPrdLot:GetProduto(),Self:GetQuant(),0,2))
					Self:UpdateDCR()
				Else
					Self:DeleteDCR()
				EndIf
				// Cria novo D12 com o restante da quantidade
				oMovNew:oOrdServ:SetIdDCF(Self:GetIdDCF())
				oMovNew:oOrdServ:LoadData()
				oMovNew:SetRadioF(oMovimento:GetRadioF())
				oMovNew:SetPrAuto(oMovimento:GetPrAuto())
				oMovNew:SetBxEsto(oMovimento:GetBxEsto())
				// Atribui dados servico
				oMovNew:oMovServic:SetServico(oMovimento:oMovServic:GetServico())
				oMovNew:oMovServic:SetOrdem(oMovimento:oMovServic:GetOrdem())
				oMovNew:oMovServic:LoadData()
				// Atribui dados Atividade
				oMovNew:oMovTarefa:SetTarefa(oMovimento:oMovTarefa:GetTarefa())
				oMovNew:oMovTarefa:SetOrdem(oMovimento:oMovTarefa:GetOrdem())
				oMovNew:oMovTarefa:LoadData()
				// Atribui dados Produto/Lote
				oMovNew:oMovPrdLot:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())
				oMovNew:oMovPrdLot:SetProduto(oMovimento:oMovPrdLot:GetProduto())
				oMovNew:oMovPrdLot:SetLoteCtl(oMovimento:oMovPrdLot:GetLoteCtl())
				oMovNew:oMovPrdLot:SetNumLote(oMovimento:oMovPrdLot:GetNumLote())
				oMovNew:oMovPrdLot:SetNumSer(oMovimento:oMovPrdLot:GetNumSer())
				oMovNew:oMovPrdLot:LoadData()
				// Atribui dados endereço origem
				oMovNew:oMovEndOri:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
				oMovNew:oMovEndOri:SetEnder(oMovimento:oMovEndOri:GetEnder())
				oMovNew:oMovEndOri:LoadData()
				// Atribui dados endereço destino
				oMovNew:oMovEndDes:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
				oMovNew:oMovEndDes:SetEnder(oMovimento:oMovEndDes:GetEnder())
				oMovNew:oMovEndDes:LoadData()
				// Atribui dados gerais movimento serviço
				cIdMovto := GetSX8Num('D12', 'D12_IDMOV')
				ConfirmSx8()
				oMovNew:SetIdMovto(cIdMovto)
				oMovNew:SetQtdMov(nQtdQuebra)
				oMovNew:SetQtdLid(nQtdQuebra)
				oMovNew:SetPriori(cPriori)
				oMovNew:SetSeqPrio(cSeqPri)
				oMovNew:SetStatus('0')
				oMovNew:SetAgluti('2')
				oMovNew:SetIdUnit(oMovimento:GetIdUnit())
				oMovNew:SetUniDes(oMovimento:GetUniDes())
				oMovNew:SetRhFunc(oMovimento:GetRhFunc())
				oMovNew:SetRecHum(oMovimento:GetRecHum())
				oMovNew:SetRecFis(oMovimento:GetRecFis())
				oMovNew:SetAtuEst(oMovimento:GetAtuEst())
				oMovNew:SetLibPed(oMovimento:GetLibPed())
				oMovNew:SetMntVol(oMovimento:GetMntVol())
				oMovNew:SetDisSep(oMovimento:GetDisSep())
				oMovNew:SetDataIni(oMovimento:GetDataIni())
				oMovNew:SetHoraIni(oMovimento:GetHoraIni())
				oMovNew:SetDataFim(oMovimento:GetDataFim())
				oMovNew:SetHoraFim(oMovimento:GetHoraFim())
				oMovNew:cOrdMov := oMovimento:cOrdMov
				// Atribui dados das atividades e cria as movimentações
				oMovNew:RecordD12()
				// Cria novo D13 com a informação do movimento criado.
				oMovNew:LoadData(0)
				// Ajusta D13
				If oMovimento:IsUpdEst()
					cAliasD13 := GetNextAlias()
					BeginSql Alias cAliasD13
						SELECT D13.R_E_C_N_O_ RECNOD13
						FROM %Table:D13% D13
						WHERE D13.D13_FILIAL = %xFilial:D13%
						AND D13.D13_IDDCF = %Exp:oMovimento:GetIdDCF()%
						AND D13.D13_IDMOV = %Exp:oMovimento:GetIdMovto()%
						AND D13.D13_IDOPER = %Exp:oMovimento:GetIdOpera()%
						AND D13.%NotDel%
					EndSql
					// Subtrai quantidade cortada do DCR
					Do While (cAliasD13)->(!Eof())
						If oMovEstEnd:GoToD13((cAliasD13)->RECNOD13)
							oMovEstEnd:SetQtdEst(oMovEstEnd:GetQtdEst() - nQtdQuebra)
							oMovEstEnd:UpdateD13()
							// Cria novo D12 com o restante da quantidade para posterior convocacao pelo radio frequencia.
							oMovNewEst:AssignD12(oMovNew)
							oMovNewEst:SetQtdEst(nQtdQuebra)
							// Atribui endereço
							oMovNewEst:SetArmazem(oMovEstEnd:GetArmazem())
							oMovNewEst:SetEnder(oMovEstEnd:GetEnder())
							oMovNewEst:LoadData()
							oMovNewEst:SetDtEsto(oMovEstEnd:GetDtEsto())
							oMovNewEst:SetHrEsto(oMovEstEnd:GetHrEsto())
							oMovNewEst:SetTipMov(oMovEstEnd:GetTipMov())
							oMovNewEst:RecordD13()
						EndIf
						(caliasD13)->(dbSkip())
					EndDo
					(caliasD13)->(dbCloseArea())
				EndIf
				// Atualiza o D12 posicionado com a quantidade informada pelo operador.
				oMovimento:SetQtdMov(nQtdDif)
				oMovimento:SetQtdLid(nQtdDif)
				// Atualiza se movimento é aglutinado
				If oMovimento:GetAgluti() == '1' .And. !oMovimento:HasAgluAti()
					oMovimento:SetAgluti("2")
					If Self:FindIdDCF(@cIdDCFRel,@cSequenRel)
						oMovimento:SetIdDCF(cIdDCFRel)
						oMovimento:oOrdServ:LoadData()
						// Posiciona na identificador da ordem de serviço restante
						Self:SetIdDCF(cIdDCFRel)
						Self:SetSequen(cSequenRel)
						Self:LoadData()
						// Ajusta o identificador origem da ordem de serviço igual ao identificador restante do relacionamento
						Self:SetIdOrig(cIdDCFRel)
						Self:UpdateDCR()
					EndIf
				EndIf
				oMovimento:UpdateD12()
			EndIf
		ElseIf oMovimento:GetStatus() $ "2|3|4"
			// Indica que não baixa empenho
			lBxEmp := .F.
			If oMovimento:oMovServic:ChkMovEst() .And. oMovimento:IsUpdEst()
				lEmpPrev := oMovimento:oMovServic:ChkSepara()
				// Realiza os estorno da quantidade entrada prevista
				oMovimento:oEstEnder:ClearData()
				oMovimento:oEstEnder:oEndereco:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
				oMovimento:oEstEnder:oEndereco:SetEnder(oMovimento:oMovEndDes:GetEnder())
				oMovimento:oEstEnder:oProdLote:SetArmazem(oMovimento:oMovPrdLot:GetArmazem())
				oMovimento:oEstEnder:oProdLote:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())
				oMovimento:oEstEnder:oProdLote:SetProduto(oMovimento:oMovPrdLot:GetProduto())
				oMovimento:oEstEnder:oProdLote:SetLoteCtl(oMovimento:oMovPrdLot:GetLoteCtl())
				oMovimento:oEstEnder:oProdLote:SetNumLote(oMovimento:oMovPrdLot:GetNumLote())
				oMovimento:oEstEnder:oProdLote:SetNumSer(oMovimento:oMovPrdLot:GetNumSer())
				If oMovimento:oEstEnder:LoadData()
					oMovimento:oEstEnder:SetQuant(Self:GetQuant())
					// Diminui entrada prevista
					If (oMovimento:oMovServic:ChkSepara() .And. Empty(oMovimento:oOrdServ:oOrdEndOri:GetEnder())) .Or. (!oMovimento:oMovServic:ChkSepara() .And. Empty(oMovimento:oOrdServ:oOrdEndDes:GetEnder())) .Or.  oMovimento:oMovServic:ChkReabast() 
						If oMovimento:oMovServic:GetTipo() $ "1|2|3"
							oMovimento:oEstEnder:oEndereco:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
							oMovimento:oEstEnder:oEndereco:SetEnder(oMovimento:oMovEndDes:GetEnder())
							If !oMovimento:oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
								Self:cErro := oMovimento:oEstEnder:GetErro()
								lRet := .F.
							EndIf
						EndIf
						// Diminui saida prevista
						If lRet .And. (oMovimento:oMovServic:GetTipo() == "2" .Or. (oMovimento:oMovServic:GetTipo() == "3" .And. (!Empty(oMovimento:oOrdServ:oOrdEndDes:GetEnder()) .Or. !oMovimento:ChkEndD0F())) ) 											
							oMovimento:oEstEnder:oEndereco:SetArmazem(oMovimento:oMovEndOri:GetArmazem())
							oMovimento:oEstEnder:oEndereco:SetEnder(oMovimento:oMovEndOri:GetEnder())
							oMovimento:oEstEnder:SetIdUnit(oMovimento:GetIdUnit())
							If !oMovimento:oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
								Self:cErro := oMovimento:oEstEnder:GetErro()
								lRet := .F.
							EndIf
						EndIf
					EndIf
					If lRet
						// Empenho do lote
						If Empty(cProduto)
							cProduto := oMovimento:oMovPrdLot:GetProduto()
						EndIf
						If cProduto == oMovimento:oMovPrdLot:GetProduto()
							// Quando origem pedido de venda sempre estorna o empenho de lote quando não informado no pedido de venda
							// Quando origem movimento interno de requisição estorna o empenho gerado na execução da ordem de serviço 
							If lEmpPrev .And. oMovimento:oOrdServ:oProdLote:HasRastro() .And. Empty(oMovimento:oOrdServ:oProdLote:GetLoteCtl())
								oMovimento:oOrdServ:UpdEmpSB8("-",oMovimento:oOrdServ:oProdLote:GetPrdOri(),oMovimento:oMovPrdLot:GetArmazem(),oMovimento:oMovPrdLot:GetLoteCtl(),oMovimento:oMovPrdLot:GetNumLote(),(Self:GetQuant() / oMovimento:oOrdServ:oProdLote:GetArrProd()[1,2]))
							EndIf
						EndIf
					EndIf
				Else
					Self:cErro := oMovimento:oEstEnder:GetErro()
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If QtdComp(oMovimento:GetQtdMov() - Self:GetQuant()) == QtdComp(0)
					oMovimento:DeleteD12()
				Else
					oMovimento:SetQtdMov(oMovimento:GetQtdMov() - Self:GetQuant())
					If oMovimento:GetQtdLid() > 0
						oMovimento:SetQtdLid(oMovimento:GetQtdLid() - Self:GetQuant())
					EndIf
					oMovimento:UpdateD12()
				EndIf
				Self:DeleteDCR()
			EndIf
		EndIf
	EndIf
	RestArea(aAreaD13)
Return lRet
