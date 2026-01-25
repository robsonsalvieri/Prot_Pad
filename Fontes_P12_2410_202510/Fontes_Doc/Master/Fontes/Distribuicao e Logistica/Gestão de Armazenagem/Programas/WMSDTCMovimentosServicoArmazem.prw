#Include "Totvs.ch"
#Include "WMSDTCMovimentosServicoArmazem.ch"
#Define POSTAREFA 5
#Define POSQTDSOL 1
#Define POSQTDATD 2
#Define POSIDDCF  3
#Define POSSEQDCF 4
#Define POSQTDMOV 4
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0027
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0027()
Return Nil
//--------------------------------------------------
/*/{Protheus.doc} WMSDTCMovimentosServicoArmazem
Classe movimentos serviço armazem
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//--------------------------------------------------
CLASS WMSDTCMovimentosServicoArmazem FROM LongNameClass
	DATA lHasUniDes // Utilizado para suavizar o campo D12_UNIDES
	DATA oOrdServ
	DATA oMovServic
	DATA oMovTarefa
	DATA oMovPrdLot
	DATA oMovEndOri
	DATA oMovEndDes
	DATA oMovSeqAbt
	DATA oEstEnder
	DATA cCodVolume
	DATA cIdVolume
	DATA cIdUnitiz
	DATA cTipUni
	DATA cUniDes
	DATA cStatus
	DATA dDtGeracao
	DATA cHrGeracao
	DATA cSeqPrior
	DATA cSeqCarga
	DATA cPriori
	DATA cRadioF
	DATA nQtdOrig
	DATA nQtdOrig2
	DATA nQtdMovto
	DATA nQtdMovto2
	DATA nQtdLida
	DATA nQtdLida2
	DATA nQuant     // Quantidade da ordem de serviço já atendida
	DATA nMetricRec  //Quantidade de produtos recebidos para metrica WMS
	DATA nMetricExp //Quantidade de produtos expedidos para metrica WMS
	DATA dDtInicio
	DATA cHrInicio
	DATA dDtFinal
	DATA cHrFinal
	DATA cTempoMov
	DATA cRhFuncao
	DATA cRecHumano
	DATA cRecFisico
	DATA cLibPed
	DATA cAnomalia
	DATA cIdMovto
	DATA cMapaSep
	DATA cMapaCon
	DATA cMapaTipo
	DATA cRecConf
	DATA cRecEmbal
	DATA cEndConf
	DATA cOcorre
	DATA nQtdErro
	DATA cIdOpera
	DATA cMntVol
	DATA cDisSep
	DATA nSitSel
	DATA cOrdMov
	DATA cAtuEst
	DATA lEstAglu
	DATA aRecD12 AS ARRAY
	DATA aWmsReab AS ARRAY
	DATA aOrdAglu AS ARRAY
	DATA aPrdMont AS ARRAY
	DATA aMovAglu AS ARRAY
	DATA aReabD12 AS ARRAY
	DATA cArmInv
	DATA cEndInv
	DATA cAgluti
	DATA cNumOcor
	DATA cSolImpEti
	DATA cGrvPriAux
	DATA cPrioriAux
	DATA cRegraPrio
	DATA cPrAuto
	DATA cBxEsto
	DATA cLog
	DATA lUsuArm
	DATA lUpdMovto
	DATA nRecno
	DATA cErro
	// Mais campos necessário
	METHOD New() CONSTRUCTOR
	METHOD GoToD12(nRecno)
	METHOD LoadData(nIndex)
	METHOD LockD12()
	METHOD UnLockD12()
	// Method Set
	METHOD SetIdDCF(cIdDCF)
	METHOD SetSequen(cSequen)
	METHOD SetIdMovto(cIdMovto)
	METHOD SetIdOpera(cIdOpera)
	METHOD SetOrdAtiv(cOrdAtiv)
	METHOD SetQtdOri(nQtdOrig)
	METHOD SetQtdOri2(nQtdOrig2)
	METHOD SetQtdMov(nQtdMovto)
	METHOD SetQtdMov2(nQtdMovto2)
	METHOD SetQtdLid(nQtdLida)
	METHOD SetQtdLid2(nQtdLida2)
	METHOD SetQuant(nQuant)
	METHOD SetCodVol(cCodVolume)
	METHOD SetStatus(cStatus)
	METHOD SetMapTip(cMapaTipo)
	METHOD SetRhFunc(cRhFuncao)
	METHOD SetLibPed(cLibPed)
	METHOD SetPriori(cPriori)
	METHOD SetGrvPriA(cGrvPri)
	METHOD SetPrioriA(cPriori)
	METHOD SetSeqPrio(cSeqPrior)
	METHOD SetDataGer(dDtGeracao)
	METHOD SetHoraGer(cHrGeracao)
	METHOD SetDataIni(dDtInicio)
	METHOD SetHoraIni(cHrInicio)
	METHOD SetDataFim(dDtFinal)
	METHOD SetHoraFim(cHrFinal)
	METHOD SetRecHum(cRecHumano)
	METHOD SetRecFis(cRecFisico)
	METHOD SetAnomal(cAnomalia)
	METHOD SetRecCon(cRecConf)
	METHOD SetRecEmb(cRecEmbal)
	METHOD SetQtdErro(nQtdErro)
	METHOD SetMntVol(cMntVol)
	METHOD SetDisSep(cDisSep)
	METHOD SetAtuEst(cAtuEst)
	METHOD SetOcorre(cOcorre)
	METHOD SetIdUnit(cIdUnitiz)
	METHOD SetTipUni(cTipUni)
	METHOD SetUniDes(cUniDes)
	METHOD SetRecD12(aRecD12)
	METHOD SetReaBD12(aReabD12)
	METHOD SetWmsReab(aWmsReab)
	METHOD SetRadioF(cRadioF)
	METHOD SetArmInv(cArmInv)
	METHOD SetEndInv(cEndInv)
	METHOD SetAgluti(cAgluti)
	METHOD SetNumOcor(cNumOcor)
	METHOD SetSolImpE(cSolImpEti)
	METHOD SetOrdAglu(aOrdAglu)
	METHOD SetErro(cErro)
	METHOD SetPrAuto(cPrAuto)
	METHOD SetBxEsto(cBxEsto)
	METHOD SetLog(cLog)
	METHOD SetUsuArm(lUsuArm)
	METHOD SetUpdMovto(lUpdMovto)
	METHOD SetMetricRec(nMetricRec)
	METHOD SetMetricExp(nMetricExp)
	// Method Get
	METHOD GetIdDCF()
	METHOD GetSequen()
	METHOD GetIdMovto()
	METHOD GetIdOpera()
	METHOD GetOrdAtiv()
	METHOD GetQtdMov()
	METHOD GetQtdMov2()
	METHOD GetQtdLid()
	METHOD GetQtdLid2()
	METHOD GetQuant()
	METHOD GetStatus()
	METHOD GetIdUnit()
	METHOD GetUniDes()
	METHOD GetTipUni()
	METHOD GetCodVol()
	METHOD GetPriori()
	METHOD GetRadioF()
	METHOD GetSeqPrio()
	METHOD GetDataGer()
	METHOD GetHoraGer()
	METHOD GetDataIni()
	METHOD GetHoraIni()
	METHOD GetDataFim()
	METHOD GetHoraFim()
	METHOD GetRecHum()
	METHOD GetRecFis()
	METHOD GetMapSep()
	METHOD GetMapaTip()
	METHOD GetLibPed()
	METHOD GetRhFunc()
	METHOD GetOcorre()
	METHOD GetRecCon()
	METHOD GetQtdErro()
	METHOD GetEndCon()
	METHOD GetMntVol()
	METHOD GetDisSep()
	METHOD GetAtuEst()
	METHOD GetArmInv()
	METHOD GetEndInv()
	METHOD GetAgluti()
	METHOD GetNumOcor()
	METHOD GetSolImpE()
	METHOD GetOrdAglu()
	METHOD GetPrAuto()
	METHOD GetBxEsto()
	// Method processos
	METHOD AssignD12()
	METHOD RecordD12()
	METHOD DeleteD12()
	METHOD UpdateD12(lMsUnLock)
	METHOD UpdExpedic(cIdDCF,cDocto,cCliFor,cLoja)
	METHOD UpdQtdConf(cNovoLote,cNovoSubLote)
	METHOD UpdLote(cNovoLote,cNovoSbLot)
	METHOD UpdMovto(cNovoLote,cNovoSbLot,cNovoUnit,cNovoEnder)
	METHOD UpdPedido(cNovoLote,cNovoSbLot)
	METHOD UpdMovExp(aMovExp)
	METHOD MakeInput()
	METHOD MakeOutput()
	METHOD IsUltAtiv()
	METHOD IsPriAtiv()
	METHOD IsUpdEst()
	METHOD ChkMntVol(cTipoMnt)
	METHOD ChkDisSep()
	METHOD ChkConfExp()
	METHOD ChkSolImpE()
	METHOD ChkEndOri(lConsMov,lMovEst,lConsSld)
	METHOD ChkEndDes(lConsMov,lConsCap,cTipReab)
	METHOD ReverseAgl(oRelacMov)
	METHOD GetNextOri(cIdDCF,cIdMovto,cIdOpera)
	METHOD AtuNextOri(cIdDCF,cIdMovto,cIdOpera,cNextId)
	METHOD GetNextMov()
	METHOD AtuNextMov(cNextIdMov)
	METHOD VldEndInv()
	METHOD HasAgluAti()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD Destroy()
	METHOD ChkEndD0F()
	METHOD IsMovUnit()
	METHOD DesNotUnit()
	METHOD OriNotUnit()
	METHOD HasSldUni()
	METHOD ChkEstPrd(lMovEst,lConsMov,cLocal,cProduto,cLoteCtl,cNumLote,nQuant)
	METHOD SldPrdLot(cLotectl,cNumlote)
	METHOD LibPedConf()
	METHOD EstMovto()
	METHOD GeraMovto()
	METHOD ReproRegra()
	METHOD SldBlq(cProduto,cLoteCtl,cNumLote,cLocal)
	METHOD EstMovComp()
	METHOD RegMovAglu()
	METHOD GetReabD12()
	METHOD GetMetrRec()
	METHOD GetMetrExp()
	METHOD WmsMetrMov()
	METHOD WmsAgLotC9(nRecno, cLote, cSub)
ENDCLASS
//--------------------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD New() CLASS WMSDTCMovimentosServicoArmazem
	Self:lHasUniDes := WmsX312118("D12","D12_UNIDES")
	Self:oOrdServ   := WMSDTCOrdemServico():New()
	Self:oMovServic := Self:oOrdServ:oServico
	Self:oMovTarefa := WMSDTCTarefaAtividade():New()
	Self:oMovPrdLot := WMSDTCProdutoLote():New()
	Self:oMovEndOri := WMSDTCEndereco():New()
	Self:oMovEndDes := WMSDTCEndereco():New()
	Self:oMovSeqAbt := WMSDTCSequenciaAbastecimento():New()
	Self:oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Inicializa campos
	Self:cIdMovto   := PadR("", TamSx3("D12_IDMOV")[1])
	Self:cIdOpera   := PadR("", TamSx3("D12_IDOPER")[1])
	Self:cStatus    := "-"
	Self:dDtGeracao := dDataBase
	Self:cHrGeracao := Time()
	Self:cSeqPrior  := PadR("",TamSx3("D12_SEQPRI")[1])
	Self:cPriori    := PadR("",TamSx3("D12_PRIORI")[1])
	Self:cRadioF    := "2"
	Self:cCodVolume := PadR("",TamSx3("D12_CODVOL")[1])
	Self:cIdVolume  := PadR("",TamSx3("D12_IDVOLU")[1])
	Self:cIdUnitiz  := PadR("",TamSx3("D12_IDUNIT")[1])
	Self:cTipUni    := PadR("",Iif(Self:lHasUniDes,TamSx3("D14_CODUNI")[1],6))
	Self:cUniDes    := PadR("",Iif(Self:lHasUniDes,TamSx3("D12_UNIDES")[1],6))
	Self:nQtdOrig   := 0
	Self:nQtdOrig2  := 0
	Self:nQtdMovto  := 0
	Self:nQtdMovto2 := 0
	Self:nQtdLida   := 0
	Self:nQtdLida2  := 0
	Self:nQuant     := 0
	Self:cSeqCarga  := PadR("", TamSx3("D12_SEQCAR")[1])
	Self:dDtInicio  := CtoD('  /  /  ')
	Self:cHrInicio  := PadR("", Len(Self:cHrGeracao))
	Self:dDtFinal   := CtoD('  /  /  ')
	Self:cHrFinal   := PadR("", Len(Self:cHrGeracao))
	Self:cRhFuncao  := PadR("", TamSx3("D12_RHFUNC")[1])
	Self:cRecHumano := PadR("", TamSx3("D12_RECHUM")[1])
	Self:cRecFisico := PadR("", TamSx3("D12_RECFIS")[1])
	Self:cLibPed    := PadR("", TamSx3("D12_LIBPED")[1])
	Self:cAnomalia  := PadR("", TamSx3("D12_ANOMAL")[1])
	Self:cMapaSep   := PadR("", TamSx3("D12_MAPSEP")[1])
	Self:cMapaCon   := PadR("", TamSx3("D12_MAPCON")[1])
	Self:cMapaTipo  := "2" // Default - Caixa
	Self:cRecConf   := PadR("", TamSx3("D12_RECCON")[1])
	Self:cRecEmbal  := PadR("", TamSx3("D12_RECEMB")[1])
	Self:cEndConf   := PadR("", TamSx3("D12_ENDCON")[1])
	Self:cOcorre    := PadR("", TamSx3("D12_OCORRE")[1])
	Self:cArmInv    := PadR("", Len(Self:oMovEndOri:GetArmazem()))
	Self:cEndInv    := PadR("", Len(Self:oMovEndOri:GetEnder()))
	Self:nQtdErro   := 0
	Self:cMntVol    := "2"
	Self:cDisSep    := "2"
	Self:cSolImpEti := "2"
	Self:lUsuArm    := .F.
	Self:cOrdMov    := "1"
	Self:cAtuEst    := "2"
	Self:lEstAglu   := .F.
	Self:lUpdMovto  := .F.
	Self:aRecD12    := {}
	Self:aReabD12   := {}
	Self:aOrdAglu   := {}
	Self:aMovAglu   := {}
	Self:aPrdMont   := {}
	Self:cAgluti    := "2"
	Self:cNumOcor   := PadR("", TamSx3("D12_NUMERO")[1])
	Self:cRegraPrio := SuperGetMV('MV_WMSPRIO', .F., '' ) // Prioridade de convocacao no WMS.
	Self:cErro      := ""
	Self:nRecno     := 0
	Self:cPrAuto    := "2"
	Self:cBxEsto    := "2"
	Self:cLog       := "2"
	Self:nMetricRec := 0 
	Self:nMetricExp := 0 
Return

METHOD Destroy() CLASS WMSDTCMovimentosServicoArmazem
	//Mantido para compatibilidade
Return Nil
//--------------------------------------------------
/*/{Protheus.doc} GoToD12
Método utilizado para posicionamentos dos dados
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//--------------------------------------------------
METHOD GoToD12(nRecno) CLASS WMSDTCMovimentosServicoArmazem
	Self:nRecno := nRecno
Return Self:LoadData(0)
//--------------------------------------------------
/*/{Protheus.doc} LockD12
Prende a tabela para alteração D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD LockD12() CLASS WMSDTCMovimentosServicoArmazem
Local lRet := .T.
	D12->(dbGoTo(Self:nRecno))
	If !D12->(SimpleLock())
		lRet := .F.
		Self:cErro := STR0002 // Lock não foi efetuado!
	Else
		Self:cStatus := D12->D12_STATUS
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UnLockD12
Libera a tabela para alteração D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD UnLockD12() CLASS WMSDTCMovimentosServicoArmazem
	D12->(dbGoTo(Self:nRecno))
Return D12->(MsUnlock())
//--------------------------------------------------
/*/{Protheus.doc} LoadData
Carregamentos dos dados D12
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//--------------------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCMovimentosServicoArmazem
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD12    := D12->(GetArea())
Local aD12_QTDORI := TamSx3("D12_QTDORI")
Local aD12_QTDOR2 := TamSx3("D12_QTDOR2")
Local aD12_QTDMOV := TamSx3("D12_QTDMOV")
Local aD12_QTDMO2 := TamSx3("D12_QTDMO2")
Local aD12_QTDLID := TamSx3("D12_QTDLID")
Local aD12_QTDLI2 := TamSx3("D12_QTDLI2")
Local cAliasD12   := Nil
Default nIndex := 4
	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 4
			If (Empty(Self:GetIdDCF()) .OR. Empty(Self:cIdMovto).OR. Empty(Self:cIdOpera))
				lRet := .F.
			EndIf
		otherwise
			lRet := .F.
	EndCase

	If !lRet
		Self:cErro := STR0004 + " (" + GetClassName(Self) + ":LoadData(" + cValToChar(nIndex) + "))"// Dados para busca não foram informados!
	EndIf

	If lRet
		cAliasD12   := GetNextAlias()
		cCmpUniDes := IIf(Self:lHasUniDes,"% D12.D12_UNIDES,%","% %")
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD12
					SELECT D12.D12_IDDCF,
							%Exp:cCmpUniDes%
							D12.D12_SERVIC,
							D12.D12_ORDTAR,
							D12.D12_TAREFA,
							D12.D12_ORDATI,
							D12.D12_PRDORI,
							D12.D12_PRODUT,
							D12.D12_LOTECT,
							D12.D12_NUMLOT,
							D12.D12_NUMSER,
							D12.D12_LOCORI,
							D12.D12_ENDORI,
							D12.D12_LOCDES,
							D12.D12_ENDDES,
							D12.D12_STATUS,
							D12.D12_DTGERA,
							D12.D12_HRGERA,
							D12.D12_SEQPRI,
							D12.D12_PRIORI,
							D12.D12_RADIOF,
							D12.D12_QTDORI,
							D12.D12_QTDOR2,
							D12.D12_QTDMOV,
							D12.D12_QTDMO2,
							D12.D12_QTDLID,
							D12.D12_QTDLI2,
							D12.D12_DATINI,
							D12.D12_HORINI,
							D12.D12_DATFIM,
							D12.D12_HORFIM,
							D12.D12_RHFUNC,
							D12.D12_RECHUM,
							D12.D12_RECFIS,
							D12.D12_LIBPED,
							D12.D12_SEQCAR,
							D12.D12_CODVOL,
							D12.D12_IDVOLU,
							D12.D12_IDUNIT,
							D12.D12_ANOMAL,
							D12.D12_IDMOV,
							D12.D12_MAPSEP,
							D12.D12_MAPCON,
							D12.D12_MAPTIP,
							D12.D12_RECCON,
							D12.D12_RECEMB,
							D12.D12_ENDCON,
							D12.D12_OCORRE,
							D12.D12_QTDERR,
							D12.D12_MNTVOL,
							D12.D12_DISSEP,
							D12.D12_IDOPER,
							D12.D12_ORDMOV,
							D12.D12_ATUEST,
							D12.D12_AGLUTI,
							D12.D12_NUMERO,
							D12.D12_IMPETI,
							D12.D12_PRAUTO,
							D12.D12_BXESTO,
							D12.D12_LOG,
							D12.R_E_C_N_O_ RECNOD12
					FROM %Table:D12% D12
					WHERE D12.D12_FILIAL = %xFilial:D12%
					AND D12.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D12.%NotDel%
				EndSql
			Case nIndex == 4
				BeginSql Alias cAliasD12
					SELECT D12.D12_IDDCF,
							%Exp:cCmpUniDes%
							D12.D12_SERVIC,
							D12.D12_ORDTAR,
							D12.D12_TAREFA,
							D12.D12_ORDATI,
							D12.D12_PRDORI,
							D12.D12_PRODUT,
							D12.D12_LOTECT,
							D12.D12_NUMLOT,
							D12.D12_NUMSER,
							D12.D12_LOCORI,
							D12.D12_ENDORI,
							D12.D12_LOCDES,
							D12.D12_ENDDES,
							D12.D12_STATUS,
							D12.D12_DTGERA,
							D12.D12_HRGERA,
							D12.D12_SEQPRI,
							D12.D12_PRIORI,
							D12.D12_RADIOF,
							D12.D12_QTDORI,
							D12.D12_QTDOR2,
							D12.D12_QTDMOV,
							D12.D12_QTDMO2,
							D12.D12_QTDLID,
							D12.D12_QTDLI2,
							D12.D12_DATINI,
							D12.D12_HORINI,
							D12.D12_DATFIM,
							D12.D12_HORFIM,
							D12.D12_RHFUNC,
							D12.D12_RECHUM,
							D12.D12_RECFIS,
							D12.D12_LIBPED,
							D12.D12_SEQCAR,
							D12.D12_CODVOL,
							D12.D12_IDVOLU,
							D12.D12_IDUNIT,
							D12.D12_ANOMAL,
							D12.D12_IDMOV,
							D12.D12_MAPSEP,
							D12.D12_MAPCON,
							D12.D12_MAPTIP,
							D12.D12_RECCON,
							D12.D12_RECEMB,
							D12.D12_ENDCON,
							D12.D12_OCORRE,
							D12.D12_QTDERR,
							D12.D12_MNTVOL,
							D12.D12_DISSEP,
							D12.D12_IDOPER,
							D12.D12_ORDMOV,
							D12.D12_ATUEST,
							D12.D12_AGLUTI,
							D12.D12_NUMERO,
							D12.D12_IMPETI,
							D12.D12_PRAUTO,
							D12.D12_BXESTO,
							D12.D12_LOG,
							D12.R_E_C_N_O_ RECNOD12
					FROM %Table:D12% D12
					WHERE D12.D12_FILIAL = %xFilial:D12%
					AND D12.D12_IDDCF = %Exp:Self:GetIdDCF()%
					AND D12.D12_IDMOV = %Exp:Self:cIdMovto%
					AND D12.D12_IDOPER = %Exp:Self:cIdOpera%
					AND D12.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD12,'D12_QTDORI','N',aD12_QTDORI[1],aD12_QTDORI[2])
		TCSetField(cAliasD12,'D12_QTDOR2','N',aD12_QTDOR2[1],aD12_QTDOR2[2])
		TCSetField(cAliasD12,'D12_QTDMOV','N',aD12_QTDMOV[1],aD12_QTDMOV[2])
		TCSetField(cAliasD12,'D12_QTDMO2','N',aD12_QTDMO2[1],aD12_QTDMO2[2])
		TCSetField(cAliasD12,'D12_QTDLID','N',aD12_QTDLID[1],aD12_QTDLID[2])
		TCSetField(cAliasD12,'D12_QTDLI2','N',aD12_QTDLI2[1],aD12_QTDLI2[2])
		TcSetField(cAliasD12,'D12_DTGERA','D')
		TcSetField(cAliasD12,'D12_DATINI','D')
		TcSetField(cAliasD12,'D12_DATFIM','D')
		If (lRet := (cAliasD12)->(!Eof()))
			// Busca dados Ordem Servico
			Self:oOrdServ:SetIdDCF((cAliasD12)->D12_IDDCF)
			Self:oOrdServ:LoadData()
			// Busca dados Servico
			Self:oMovServic:SetServico((cAliasD12)->D12_SERVIC)
			Self:oMovServic:SetOrdem((cAliasD12)->D12_ORDTAR)
			Self:oMovServic:LoadData()
			// Busca dados Tarefa
			Self:oMovTarefa:SetTarefa((cAliasD12)->D12_TAREFA)
			Self:oMovTarefa:SetOrdem((cAliasD12)->D12_ORDATI)
			Self:oMovTarefa:LoadData()
			// Busca dados Produto/Lote
			Self:oMovPrdLot:SetArmazem((cAliasD12)->D12_LOCORI)
			Self:oMovPrdLot:SetPrdOri((cAliasD12)->D12_PRDORI)
			Self:oMovPrdLot:SetProduto((cAliasD12)->D12_PRODUT)
			Self:oMovPrdLot:SetLoteCtl((cAliasD12)->D12_LOTECT)
			Self:oMovPrdLot:SetNumLote((cAliasD12)->D12_NUMLOT)
			Self:oMovPrdLot:SetNumSer((cAliasD12)->D12_NUMSER)
			Self:oMovPrdLot:LoadData()
			// Busca dados Endereco Origem
			Self:oMovEndOri:SetArmazem((cAliasD12)->D12_LOCORI)
			Self:oMovEndOri:SetEnder((cAliasD12)->D12_ENDORI)
			Self:oMovEndOri:LoadData()
			// Busca dados Endereco Destino
			Self:oMovEndDes:SetArmazem((cAliasD12)->D12_LOCDES)
			Self:oMovEndDes:SetEnder((cAliasD12)->D12_ENDDES)
			Self:oMovEndDes:LoadData()
			// Atribui restante das informações
			Self:cStatus    := (cAliasD12)->D12_STATUS
			Self:dDtGeracao := (cAliasD12)->D12_DTGERA
			Self:cHrGeracao := (cAliasD12)->D12_HRGERA
			Self:cSeqPrior  := (cAliasD12)->D12_SEQPRI
			Self:cPriori    := (cAliasD12)->D12_PRIORI
			Self:cRadioF    := (cAliasD12)->D12_RADIOF
			Self:nQtdOrig   := (cAliasD12)->D12_QTDORI
			Self:nQtdOrig2  := (cAliasD12)->D12_QTDOR2
			Self:nQtdMovto  := (cAliasD12)->D12_QTDMOV
			Self:nQtdMovto2 := (cAliasD12)->D12_QTDMO2
			Self:nQtdLida   := (cAliasD12)->D12_QTDLID
			Self:nQtdLida2  := (cAliasD12)->D12_QTDLI2
			Self:dDtInicio  := (cAliasD12)->D12_DATINI
			Self:cHrInicio  := (cAliasD12)->D12_HORINI
			Self:dDtFinal   := (cAliasD12)->D12_DATFIM
			Self:cHrFinal   := (cAliasD12)->D12_HORFIM
			Self:cRhFuncao  := (cAliasD12)->D12_RHFUNC
			Self:cRecHumano := (cAliasD12)->D12_RECHUM
			Self:cRecFisico := (cAliasD12)->D12_RECFIS
			Self:cLibPed    := (cAliasD12)->D12_LIBPED
			Self:cSeqCarga  := (cAliasD12)->D12_SEQCAR
			Self:cCodVolume := (cAliasD12)->D12_CODVOL
			Self:cIdVolume  := (cAliasD12)->D12_IDVOLU
			Self:cIdUnitiz  := (cAliasD12)->D12_IDUNIT
			If Self:lHasUniDes
				Self:cUniDes    := (cAliasD12)->D12_UNIDES
			EndIf
			Self:cAnomalia  := (cAliasD12)->D12_ANOMAL
			Self:cIdMovto   := (cAliasD12)->D12_IDMOV
			Self:cMapaSep   := (cAliasD12)->D12_MAPSEP
			Self:cMapaCon   := (cAliasD12)->D12_MAPCON
			Self:cMapaTipo  := (cAliasD12)->D12_MAPTIP
			Self:cRecConf   := (cAliasD12)->D12_RECCON
			Self:cRecEmbal  := (cAliasD12)->D12_RECEMB
			Self:cEndConf   := (cAliasD12)->D12_ENDCON
			Self:cOcorre    := (cAliasD12)->D12_OCORRE
			Self:nQtdErro   := (cAliasD12)->D12_QTDERR
			Self:cMntVol    := (cAliasD12)->D12_MNTVOL
			Self:cDisSep    := (cAliasD12)->D12_DISSEP
			Self:cIdOpera   := (cAliasD12)->D12_IDOPER
			Self:cOrdMov    := (cAliasD12)->D12_ORDMOV
			Self:cAtuEst    := (cAliasD12)->D12_ATUEST
			Self:cAgluti    := (cAliasD12)->D12_AGLUTI
			Self:cNumOcor   := (cAliasD12)->D12_NUMERO
			Self:cSolImpEti := (cAliasD12)->D12_IMPETI
			Self:cPrAuto    := (cAliasD12)->D12_PRAUTO
			Self:cBxEsto    := (cAliasD12)->D12_BXESTO
			Self:cLog       := (cAliasD12)->D12_LOG
			Self:nRecno     := (cAliasD12)->RECNOD12
		EndIf
		(cAliasD12)->(dbCloseArea())
	EndIf
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetIdDCF(cIdDCF) CLASS WMSDTCMovimentosServicoArmazem
	Self:oOrdServ:SetIdDCF(cIdDCF)
Return

METHOD SetSequen(cSequen) CLASS WMSDTCMovimentosServicoArmazem
	Self:oOrdServ:SetSequen(cSequen)
Return

METHOD SetIdMovto(cIdMovto) CLASS WMSDTCMovimentosServicoArmazem
	Self:cIdMovto := PadR(cIdMovto, Len(Self:cIdMovto))
Return

METHOD SetIdOpera(cIdOpera) CLASS WMSDTCMovimentosServicoArmazem
	Self:cIdOpera := PadR(cIdOpera, Len(Self:cIdOpera))
Return

METHOD SetStatus(cStatus) CLASS WMSDTCMovimentosServicoArmazem
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetOrdAtiv(cOrdAtiv) CLASS WMSDTCMovimentosServicoArmazem
	Self:cOrdemAtiv := PadR(cOrdAtiv, Len(Self:cOrdemAtiv))
Return

METHOD SetQtdOri(nQtdOrig) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdOrig := nQtdOrig
Return

METHOD SetQtdOri2(nQtdOrig2) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdOrig2 := nQtdOrig2
Return

METHOD SetQtdMov(nQtdMovto) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdMovto := nQtdMovto
Return

METHOD SetQtdMov2(nQtdMovto2) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdMovto2 := nQtdMovto2
Return

METHOD SetQtdLid(nQtdLida) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdLida := nQtdLida
Return

METHOD SetQtdLid2(nQtdLida2) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdLida2 := nQtdLida2
Return

METHOD SetQuant(nQuant) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQuant := nQuant
Return

METHOD SetCodVol(cCodVolume) CLASS WMSDTCMovimentosServicoArmazem
	Self:cCodVolume := PadR(cCodVolume, Len(Self:cCodVolume))
Return

METHOD SetMapTip(cMapaTipo) CLASS WMSDTCMovimentosServicoArmazem
	Self:cMapaTipo := PadR(cMapaTipo, Len(Self:cMapaTipo))
Return

METHOD SetRhFunc(cRhFuncao) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRhFuncao := PadR(cRhFuncao, Len(Self:cRhFuncao))
Return

METHOD SetLibPed(cLibPed) CLASS WMSDTCMovimentosServicoArmazem
	Self:cLibPed := PadR(cLibPed, Len(Self:cLibPed))
Return

METHOD SetPriori(cPriori) CLASS WMSDTCMovimentosServicoArmazem
	Self:cPriori := PadR(cPriori, Len(Self:cPriori))
Return

METHOD SetSeqPrio(cSeqPrior) CLASS WMSDTCMovimentosServicoArmazem
	Self:cSeqPrior := PadR(cSeqPrior, Len(Self:cSeqPrior))
Return

METHOD SetDataGer(dDtGeracao) CLASS WMSDTCMovimentosServicoArmazem
	Self:dDtGeracao := dDtGeracao
Return

METHOD SetHoraGer(cHrGeracao) CLASS WMSDTCMovimentosServicoArmazem
	Self:cHrGeracao := PadR(cHrGeracao, Len(Self:cHrGeracao))
Return

METHOD SetDataIni(dDtInicio) CLASS WMSDTCMovimentosServicoArmazem
	Self:dDtInicio := dDtInicio
Return

METHOD SetHoraIni(cHrInicio) CLASS WMSDTCMovimentosServicoArmazem
	Self:cHrInicio := PadR(cHrInicio, Len(Self:cHrInicio))
Return

METHOD SetDataFim(dDtFinal) CLASS WMSDTCMovimentosServicoArmazem
	Self:dDtFinal := dDtFinal
Return

METHOD SetHoraFim(cHrFinal) CLASS WMSDTCMovimentosServicoArmazem
	Self:cHrFinal := PadR(cHrFinal, Len(Self:cHrFinal))
Return

METHOD SetRecHum(cRecHumano) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRecHumano := PadR(cRecHumano, Len(Self:cRecHumano))
Return

METHOD SetRecFis(cRecFisico) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRecFisico := PadR(cRecFisico, Len(Self:cRecFisico))
Return

METHOD SetAnomal(cAnomalia) CLASS WMSDTCMovimentosServicoArmazem
	Self:cAnomalia := PadR(cAnomalia, Len(Self:cAnomalia))
Return

METHOD SetRecCon(cRecConf) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRecConf := PadR(cRecConf, Len(Self:cRecConf))
Return

METHOD SetRecEmb(cRecEmbal) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRecEmbal := PadR(cRecEmbal, Len(Self:cRecEmbal))
Return

METHOD SetQtdErro(nQtdErro) CLASS WMSDTCMovimentosServicoArmazem
	Self:nQtdErro := nQtdErro
Return

METHOD SetMntVol(cMntVol) CLASS WMSDTCMovimentosServicoArmazem
	Self:cMntVol := PadR(cMntVol, Len(Self:cMntVol))
Return

METHOD SetDisSep(cDisSep) CLASS WMSDTCMovimentosServicoArmazem
	Self:cDisSep := PadR(cDisSep, Len(Self:cDisSep))
Return

METHOD SetAtuEst(cAtuEst) CLASS WMSDTCMovimentosServicoArmazem
	Self:cAtuEst := PadR(cAtuEst, Len(Self:cAtuEst))
Return

METHOD SetOcorre(cOcorre) CLASS WMSDTCMovimentosServicoArmazem
	Self:cOcorre := PadR(cOcorre, Len(Self:cOcorre))
Return

METHOD SetIdUnit(cIdUnitiz) CLASS WMSDTCMovimentosServicoArmazem
	Self:cIdUnitiz := PadR(cIdUnitiz, Len(Self:cIdUnitiz))
Return

METHOD SetTipUni(cTipUni) CLASS WMSDTCMovimentosServicoArmazem
	Self:cTipUni := PadR(cTipUni, Iif(Self:lHasUniDes, Len(Self:cTipUni),6))
Return

METHOD SetUniDes(cUniDes) CLASS WMSDTCMovimentosServicoArmazem
	Self:cUniDes := PadR(cUniDes, Iif(Self:lHasUniDes, Len(Self:cUniDes),6))
Return

METHOD SetRecD12(aRecD12) CLASS WMSDTCMovimentosServicoArmazem
	Self:aRecD12 := aRecD12
Return

METHOD SetReaBD12(aReabD12) CLASS WMSDTCMovimentosServicoArmazem
	Self:aReabD12 := aReabD12
Return

METHOD SetWmsReab(aWmsReab) CLASS WMSDTCMovimentosServicoArmazem
	Self:aWmsReab := aWmsReab
Return

METHOD SetRadioF(cRadioF) CLASS WMSDTCMovimentosServicoArmazem
	Self:cRadioF := PadR(cRadioF, Len(Self:cRadioF))
Return

METHOD SetArmInv(cArmInv) CLASS WMSDTCMovimentosServicoArmazem
	Self:cArmInv := PadR(cArmInv, Len(Self:cArmInv))
Return

METHOD SetEndInv(cEndInv) CLASS WMSDTCMovimentosServicoArmazem
	Self:cEndInv := PadR(cEndInv, Len(Self:cEndInv))
Return

METHOD SetAgluti(cAgluti) CLASS WMSDTCMovimentosServicoArmazem
	Self:cAgluti := PadR(cAgluti, Len(Self:cAgluti))
Return

METHOD SetNumOcor(cNumOcor) CLASS WMSDTCMovimentosServicoArmazem
	Self:cNumOcor := PadR(cNumOcor, Len(Self:cNumOcor))
Return

METHOD SetSolImpE(cSolImpEti) CLASS WMSDTCMovimentosServicoArmazem
	Self:cSolImpEti := PadR(cSolImpEti, Len(Self:cSolImpEti))
Return

METHOD SetOrdAglu(aOrdAglu) CLASS WMSDTCMovimentosServicoArmazem
	Self:aOrdAglu := aOrdAglu
Return

METHOD SetErro(cErro) CLASS WMSDTCMovimentosServicoArmazem
	Self:cErro := cErro
Return

METHOD SetPrAuto(cPrAuto) CLASS WMSDTCMovimentosServicoArmazem
	Self:cPrAuto := cPrAuto
Return

METHOD SetBxEsto(cBxEsto) CLASS WMSDTCMovimentosServicoArmazem
	Self:cBxEsto := cBxEsto
Return

METHOD SetLog(cLog) CLASS WMSDTCMovimentosServicoArmazem
	Self:cLog := cLog
Return

METHOD SetUsuArm(lUsuArm) CLASS WMSDTCMovimentosServicoArmazem
	Self:lUsuArm := lUsuArm
Return

METHOD SetUpdMovto(lUpdMovto) CLASS WMSDTCMovimentosServicoArmazem
	Self:lUpdMovto := lUpdMovto
Return

METHOD SetMetricRec(nMetricRec) CLASS WMSDTCMovimentosServicoArmazem
	Self:nMetricRec := nMetricRec
Return

METHOD SetMetricExp(nMetricExp) CLASS WMSDTCMovimentosServicoArmazem
	Self:nMetricExp := nMetricExp
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetIdDCF() CLASS WMSDTCMovimentosServicoArmazem
Return Self:oOrdServ:GetIdDCF()

METHOD GetSequen() CLASS WMSDTCMovimentosServicoArmazem
Return Self:oOrdServ:GetSequen()

METHOD GetIdMovto() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cIdMovto

METHOD GetIdOpera() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cIdOpera

METHOD GetOrdAtiv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cOrdemAtiv

METHOD GetStatus() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cStatus

METHOD GetIdUnit() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cIdUnitiz

METHOD GetCodVol() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cCodVolume

METHOD GetUniDes() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cUniDes

METHOD GetTipUni() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cTipUni

METHOD GetPriori() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cPriori

METHOD GetRadioF() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRadioF

METHOD GetSeqPrio() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cSeqPrior

METHOD GetQtdMov() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdMovto

METHOD GetQtdMov2() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdMovto2

METHOD GetQtdLid() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdLida

METHOD GetQtdLid2() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdLida2

METHOD GetQuant() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQuant

METHOD GetDataGer() CLASS WMSDTCMovimentosServicoArmazem
Return Self:dDtGeracao

METHOD GetHoraGer() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cHrGeracao

METHOD GetDataIni() CLASS WMSDTCMovimentosServicoArmazem
Return Self:dDtInicio

METHOD GetHoraIni() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cHrInicio

METHOD GetDataFim() CLASS WMSDTCMovimentosServicoArmazem
Return Self:dDtFinal

METHOD GetHoraFim() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cHrFinal

METHOD GetRecHum() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRecHumano

METHOD GetRecFis() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRecFisico

METHOD GetLibPed() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cLibPed

METHOD GetMapSep() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cMapaSep

METHOD GetMapaTip() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cMapaTipo

METHOD GetRhFunc() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRhFuncao

METHOD GetOcorre() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cOcorre

METHOD GetRecCon() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cRecConf

METHOD GetQtdErro() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nQtdErro

METHOD GetMntVol() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cMntVol

METHOD GetDisSep() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cDisSep

METHOD GetAtuEst() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cAtuEst

METHOD GetEndCon() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cEndConf

METHOD GetRecno() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cErro

METHOD GetArmInv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cArmInv

METHOD GetEndInv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cEndInv

METHOD GetAgluti() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cAgluti

METHOD GetNumOcor() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cNumOcor

METHOD GetSolImpE() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cSolImpEti

METHOD GetOrdAglu() CLASS WMSDTCMovimentosServicoArmazem
Return Self:aOrdAglu

METHOD GetPrAuto() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cPrAuto

METHOD GetBxEsto() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cBxEsto

METHOD GetReabD12() CLASS WMSDTCMovimentosServicoArmazem
Return Self:aReabD12 

METHOD GetMetrRec() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nMetricRec 

METHOD GetMetrExp() CLASS WMSDTCMovimentosServicoArmazem
Return Self:nMetricExp 

//--------------------------------------------------
/*/{Protheus.doc} AssignD12
Atribui os dados às propriedades
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD AssignD12() CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local aAtividade := {}
Local aExOrigem  := {}
Local aExDestino := {}
Local lNoExcec   := .T.
Local nAtividade := 0
Local cIdMovto   := ""
Local nRecnoD12  := 0
Local nContMov   := 0
Local nI         := 0
Local nPos       := 0
Local nQtSol     := 0
Local nOrdTar    := 0
Local nOrdPrd    := 0
Local aAgluMov   := {}
Local aAgluLot   := {}
Local aProduto   := {}
Local nRecnoDCF  := Self:oOrdServ:GetRecno()
Local nRegraWMS  := Self:oOrdServ:GetRegra()
Local cNoExOri   := ""
Local cNoExDes   := ""
Local cIDDCFOrig := ""
Local nAux := 0
Local lWmsExOR  := SuperGetMV("MV_WMSEXOR",.F.,.F.)

	// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
	If Self:DesNotUnit()
		Self:cUniDes := ""
		Self:cTipUni := ""
	Else
		// Caso não foi informado o unitizador destino, assume o mesmo que a origem, apenas se o armazém destino tbm for unitizado
		If Empty(Self:cUniDes) .And. WmsArmUnit(Self:oMovEndDes:GetArmazem())
			Self:cUniDes := Self:cIdUnitiz
		EndIf
	EndIf

	// Gera IDMOVTO
	cIdMovto   := GetSX8Num('D12', 'D12_IDMOV')
	ConfirmSx8()
	// Atribui identificador de movimento
	Self:SetIdMovto(cIdMovto)
	// Excecao endereco origem
	aExOrigem  := Self:oMovEndOri:GetArrExce()
	// Excecao endereco destino
	aExDestino := Self:oMovEndDes:GetArrExce()
	// Carrega as atividades da tarefa
	Self:oMovTarefa:SetTarefa(Self:oMovServic:GetTarefa())
	Self:oMovTarefa:TarefaAtiv()
	Self:cOrdMov := "1" // Primeira Atividade
	Self:cAtuEst := "2" // Atividade não atualiza estoque
	aAtividade := Self:oMovTarefa:GetArrAti()

	// Quando documentos aglutinados
	If !Empty(Self:aOrdAglu)
		WmsConout('AssignD12 - Processamento com documentos aglutinados (aOrdAglu > 0)')
		//Realiza o rateio para a tarefa da quantidade total solicitada dentre os ID DCF que estão no array,
		//determinando neste momento quanto de cada ID DCF que será atendido pela quantidade total deste movimento
		nQtSol := Self:nQtdMovto
		WmsConout('AssignD12 - Qtde solicitada ' + cValToChar(nQtSol))

		nOrdPrd := Self:oOrdServ:nProduto
		nOrdTar := Self:oOrdServ:nTarefa
		WmsConout('AssignD12 - nOrdPrd / nOrdTar ' + cValToChar(nOrdPrd) + ' / ' + cValToChar(nOrdTar))

		For nI := 1 To Len(Self:aOrdAglu)
			Wmsconout('*** Verificando item ' + cValToChar(nI) + ' da aglutinacao')
			aAgluMov := Self:aOrdAglu[nI][POSTAREFA][nOrdPrd][nOrdTar]
			// Reserva um novo array para os lotes que podem ser atendidos para o primeiro item
			// Exemplo de rateio para dois documentos DOC 01 e DOC 02 ambos com 5 unidades:
			//  MOV01 -> FILHO-01 -> LOTE A -> 2
			//                       DOC 01 -> 2 -> Sobram 3
			//  MOV02 -> FILHO-01 -> LOTE B -> 2
			//                       DOC 01 -> 2 -> Sobram 1
			//  MOV03 -> FILHO-01 -> LOTE A -> 6
			//                       DOC 01 -> 1 -> Sobram 0
			//                       DOC 02 -> 5 -> Sobram 0
			// Somando está gerando LOTE A -> 8 e LOTE B -> 2
			// Ao executar o segundo movimento vai tentar atender com os lotes na ordem,
			// forçando o rateio dos demais produtos serem para os lotes errados nos documentos
			// pois o rateio seria forçado a ser DOC 01 -> 5 e DOC 02 -> 3 + 2
			If nOrdPrd == 1
				WmsConout('AssignD12 - nOrdPrd=1')
				If Len(aAgluMov) <= POSQTDMOV
					WmsConout('AssignD12 - adicionando item no array de lotes')
					AAdd(aAgluMov,{})
				EndIf
			Else
				WmsConout('AssignD12 - nOrdPrd <> 1 (Uso de produtos filho)')
				If Len(aAgluMov) <= POSQTDMOV
					// Copia o rateio de lotes para os outros produtos filhos
					aAgluLot := Self:aOrdAglu[nI][POSTAREFA][1][nOrdTar][POSQTDMOV+1]
					aAgluLot := AClone(aAgluLot)
					aProduto := Self:oOrdServ:oProdLote:GetArrProd()
					// Reserva uma linha para a quantidade já atendida para os demais produtos para o lote
					aEval(aAgluLot, {|x| x[3] := ((x[3]/aProduto[1][2])*(aProduto[nOrdPrd][2])), AAdd(x,0)})
					AAdd(aAgluMov,aAgluLot)
				EndIf
			EndIf
			Wmsconout('AssignD12 - Dados do item: QtdSol / QtdAtendida ' + cValToChar(aAgluMov[POSQTDSOL]) + ' / ' + cValToChar(aAgluMov[POSQTDATD]))
			If (aAgluMov[POSQTDSOL] - aAgluMov[POSQTDATD]) > 0
				//Considera a primeira DCF com saldo disponível para ser utilizado na movimentação, como a DCF de origem.
				If Empty(cIDDCFOrig)
					cIDDCFOrig := Self:aOrdAglu[nI][1]
					WmsConout('AssignD12 - CIDDCFOrig ' + Self:aOrdAglu[nI][1])
				EndIf 
				WmsConout('AssignD12 - CIDDCFOrig 2 / aglutinado em ' + Self:aOrdAglu[nI][1] + ' / ' + cIDDCFOrig)
				aAgluMov[POSIDDCF] := cIDDCFOrig
				If nOrdPrd == 1
					If nQtSol > (aAgluMov[POSQTDSOL] - aAgluMov[POSQTDATD])
						nQtSol -= (aAgluMov[POSQTDSOL] - aAgluMov[POSQTDATD])
						aAgluMov[POSQTDMOV] := (aAgluMov[POSQTDSOL] - aAgluMov[POSQTDATD]) //Utiliza todo o saldo
						Wmsconout('AssignD12 1 - Qtde ainda a solicitar (nQtSol) / Qtde movimento (aAgluMov[POSQTDMOV]) ' + cValToChar(nQtSol) + ' / ' + cValToChar(aAgluMov[POSQTDMOV]))
					Else
						aAgluMov[POSQTDMOV] := nQtSol
						nQtSol := 0
						Wmsconout('AssignD12 2 - Qtde ainda a solicitar (nQtSol) / Qtde movimento (aAgluMov[POSQTDMOV]) ' + cValToChar(nQtSol) + ' / ' + cValToChar(aAgluMov[POSQTDMOV]))
					EndIf
					// Grava o total atendido
					aAgluMov[POSQTDATD] += aAgluMov[POSQTDMOV]
					Wmsconout('AssignD12 - Total já atendido da DCF ([POSQTDATD]) ' + cValToChar(aAgluMov[POSQTDATD]))

					// Grava o rateio por lote para o primeiro produto
					If (nPos := AScan(aAgluMov[POSQTDMOV+1],{|x| x[1]+x[2] == Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote()})) > 0
						aAgluMov[POSQTDMOV+1][nPos][3] += aAgluMov[POSQTDMOV]
						WmsConout('AssignD12 - Posicao array lotes(nPos) / Nova Qtde usada / qtde recém somada ' + cValToChar(nPos) + ' / ' + cValToChar(aAgluMov[POSQTDMOV+1][nPos][3]) + ' / ' + cValToChar(aAgluMov[POSQTDMOV]))
					Else
						 AAdd(aAgluMov[POSQTDMOV+1],{Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote(),aAgluMov[POSQTDMOV]})
						 nAux := Len(aAgluMov[POSQTDMOV+1])
						WmsConout('AssignD12 - Aadd(aAglumov) Lote / Qtde ' + aAgluMov[POSQTDMOV+1][nAux][1] + ' / ' + cValToChar(aAgluMov[POSQTDMOV+1][nAux][3]))
					EndIf

					If nQtSol == 0
						WmsConout('AssignD12 nQtSol = 0')
						Exit
					EndIf
				Else
					WmsConout('AssignD12 nOrdProd > 1')

					// Deve fazer o rateio levando em consideração os lotes rateados para o primeiro produto
					nPos := AScan(aAgluMov[POSQTDMOV+1],{|x| x[1]+x[2] == Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote()})
					If nPos > 0
						aAgluLot := aAgluMov[POSQTDMOV+1][nPos]
						If nQtSol > (aAgluLot[3] - aAgluLot[4])
							nQtSol -= (aAgluLot[3] - aAgluLot[4])
							aAgluMov[POSQTDMOV] := (aAgluLot[3] - aAgluLot[4]) //Utiliza todo o saldo
						Else
							aAgluMov[POSQTDMOV] := nQtSol
							nQtSol := 0
						EndIf
						// Grava o total atendido
						aAgluLot[4] += aAgluMov[POSQTDMOV]
						aAgluMov[POSQTDATD] += aAgluMov[POSQTDMOV]

						If nQtSol == 0
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI
	EndIf
	// Atividades
	For nAtividade := 1 To Len(aAtividade)
		WmsConout('AssignD12 - nAtividade ' + cValToChar(nAtividade))
		Self:oMovTarefa:SetOrdem(aAtividade[nAtividade][1])
		Self:oMovTarefa:LoadData()
		// Valida Excecoes
		lNoExcec := .T.
		If Self:oMovServic:GetTipo() == "1" // Nas Entradas, verifica as Excecoes nos Enderecos Destino (Ex.: DOCA->Picking)
			lNoExcec := AScan(aExDestino, Self:oMovTarefa:GetAtivid()) == 0
		ElseIf Self:oMovServic:GetTipo() == "2" // Nas Saidas, verifica as Excecoes nos Enderecos Origem (Ex.: Picking->DOCA)
			lNoExcec := AScan(aExOrigem, Self:oMovTarefa:GetAtivid()) == 0
		ElseIf Self:oMovServic:GetTipo() == "3" // Nos Movtos.Internos, verifica as Excecoes nos Enderecos Destino ou Origem
			// Valida exceções
			If lWmsExOR .AND. Self:oMovServic:GetOperac() == '5'  // Quando e reabastecimento e Quando o parametro de exceção na origem estiver ativo independente de ter uma ou mais atividade validar origem para exceção. 
				lNoExcec := AScan(aExOrigem, Self:oMovTarefa:GetAtivid()) == 0 
			Else
				If Len(aAtividade) > 1 .And. nAtividade == 1 // Se possuir mais de uma atividade, e for a primeira, deve verificar apenas na origem
					lNoExcec := AScan(aExOrigem, Self:oMovTarefa:GetAtivid()) == 0
				ElseIf Len(aAtividade) > 1                   // Se possuir mais de uma atividade, e não for a primeira, deve verificar apenas no destino
					lNoExcec := AScan(aExDestino, Self:oMovTarefa:GetAtivid()) == 0
				ElseIf Len(aAtividade) == 1                  // Se possuir uma unica atividade, deve verificar se há excessão na origem e/ou no destino
					lNoExcec := (AScan(aExOrigem, Self:oMovTarefa:GetAtivid()) == 0 .Or. AScan(aExDestino, Self:oMovTarefa:GetAtivid()) == 0)
				EndIf
			EndIf
		EndIf
		If lNoExcec // Se nao houverem excecoes
			WmsConout('AssignD12 - Sem excecao')
			Self:cRadioF := IIf(Empty(Self:oMovTarefa:GetRadioF()),"2",Self:oMovTarefa:GetRadioF())
			Self:RecordD12()
			Self:cOrdMov := "2" // Atividade Intermediaria
			nRecnoD12    := Self:nRecno
			WmsConout('AssignD12 nRecnoD12 ' + cValToChar(nRecnoD12))
			nContMov++
			WmsConout('AssignD12 Incrementando Qtde Atividades (nContMov) ' + cValToChar(nContMov))
		Else
			WmsConout('AssignD12 - Com excecao')
			If Self:oMovServic:GetTipo() == "1"
				cNoExDes += IIf(Empty(cNoExDes),Alltrim(Self:oMovEndDes:GetEnder())," ,"+Alltrim(Self:oMovEndDes:GetEnder()))
			ElseIf Self:oMovServic:GetTipo() == "2"
				cNoExOri += IIf(Empty(cNoExOri),Alltrim(Self:oMovEndOri:GetEnder())," ,"+Alltrim(Self:oMovEndOri:GetEnder()))
			ElseIf Self:oMovServic:GetTipo() == "3"
				cNoExDes += IIf(Empty(cNoExDes),Alltrim(Self:oMovEndDes:GetEnder())," ,"+Alltrim(Self:oMovEndDes:GetEnder()))
				cNoExOri += IIf(Empty(cNoExOri),Alltrim(Self:oMovEndOri:GetEnder())," ,"+Alltrim(Self:oMovEndOri:GetEnder()))
			EndIf
		EndIf
	Next
	// Quando documentos aglutinados
	If !Empty(Self:aOrdAglu)
		// Zera as quantidades distribuídas nesta movimentação
		For nI := 1 To Len(Self:aOrdAglu)
			Self:aOrdAglu[nI][POSTAREFA][nOrdPrd][nOrdTar][POSQTDMOV] := 0
			WmsConout('AssignD12 - Zerando qtde distribuida aOrdAglu ' + cValToChar(nI))
		Next nI
	EndIf
	// Verifica se foram criadas atividades
	If !Empty(nRecnoD12)
	
		Self:GoToD12(nRecnoD12)
		If lRet
			WmsConout('AssignD12 - Validando qtde atividades (nContMov) ' + cValToChar(nContMov))
			If nContMov > 1
				Self:cOrdMov := "3" // Ultima Atividade
			Else
				Self:cOrdMov := "4" // Ultima e Primeira Atividade
			EndIf
			If Self:oMovServic:ChkMovEst()
				Self:cAtuEst := "1" // Ultima tarefa atualiza estoque
			EndIf
			
			Self:UpdateD12() 
			Self:oOrdServ:GoToDCF(nRecnoDCF) // Recarrega a DCF original quando aglutina tarefas
			Self:oOrdServ:SetRegra(nRegraWMS) // Recarrega também a regra WMS, que pode estar em branco no registro da DCF, porém foi definida no processo de separação
			WmsConout('AssignD12 - GotoDCF após updateD12 nRecnoDCF / nRegraWMS ' + cValToChar(nRecnoDCF) + ' / ' + nRegraWMS)
	
		EndIf
	Else
		Self:cErro := WmsFmtMsg(STR0019,{{"[VAR01]",Self:oMovServic:GetTarefa()}}) // Não foi gerado atividade para a tarefa [VAR01]
		If !Empty(cNoExOri)
			Self:cErro += CRLF + WmsFmtMsg(STR0029,{{"[VAR01]",cNoExOri}}) // Verifique as excessoes dos endereços origem ([VAR01])
		EndIf
		If !Empty(cNoExDes)
			Self:cErro += CRLF + WmsFmtMsg(STR0030,{{"[VAR01]",cNoExDes}}) // Verifique as excessoes dos endereços destido ([VAR01])
		EndIf
		lRet := .F.
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD UpdExpedic(cIdDCF,cDocto,cCliFor,cLoja) CLASS WMSDTCMovimentosServicoArmazem
//------------------------------------------------------------------------------
Local lRet        := .T.
Local aIdDCF      := {}
Local oMntVolItem := Nil
Local oDisSepItem := Nil
Local oConExpItem := Nil
Local cAliasQry   := Nil
Local nI          := 0
	
	If !Empty(Self:aOrdAglu)
		For nI := 1 To Len(Self:aOrdAglu)
			aAdd(aIdDCF,Self:aOrdAglu[nI][1])
		Next nI
	Else
		aAdd(aIdDCF,cIdDCF)
	EndIf
	
	For nI := 1 To Len(aIdDCF)
		
		// Valida se possui montagem de volume
		If Self:oMovServic:ChkMntVol()
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
			SELECT DCF.DCF_CARGA,
				DCF.DCF_DOCTO,
				D12.D12_LOTECT,
				D12.D12_NUMLOT,
				D12.D12_PRODUT,
				D12.D12_PRDORI,
				CASE WHEN MNTVOL.QTD_MNTVOL IS NULL THEN SUM(DCR.DCR_QUANT) 
				ELSE SUM(DCR.DCR_QUANT) + MNTVOL.QTD_MNTVOL END QTD_MNTVOL
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12
				ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_STATUS IN ('1','2','3','4','-')
			AND D12.D12_ATUEST = '1'
			AND D12.%NotDel% 
			INNER JOIN %Table:DCF% DCF 
				ON DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_ID = DCR.DCR_IDDCF
			AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
			AND DCF.%NotDel% 
			LEFT JOIN ( SELECT SUM(DCR.DCR_QUANT) AS QTD_MNTVOL,
								SC9.C9_PRODUTO,
								SC9.C9_LOTECTL,
								SC9.C9_CLIENTE,
								SC9.C9_LOJA,
								SC9.C9_PEDIDO,
								SC9.C9_CARGA
						FROM %Table:D12% D12
						INNER JOIN %Table:DCR% DCR 
							ON DCR.DCR_FILIAL = %xFilial:DCR%
							AND DCR.DCR_IDMOV = D12.D12_IDMOV 
							AND DCR.DCR_IDOPER = D12.D12_IDOPER
							AND DCR.DCR_IDORI = D12.D12_IDDCF
							AND DCR.%NotDel%
						INNER JOIN %Table:DCF% DCF 
							ON DCF.DCF_FILIAL = %xFilial:DCF%
							AND DCF.DCF_ID = DCR.DCR_IDDCF
							AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
							AND DCF.%NotDel%
						INNER JOIN %Table:SC9% SC9 
							ON SC9.C9_FILIAL = %xFilial:SC9%
							AND SC9.C9_CLIENTE = DCF.DCF_CLIFOR
							AND SC9.C9_LOJA = DCF.DCF_LOJA
							AND SC9.C9_PEDIDO = DCF.DCF_DOCTO
							AND SC9.C9_PRODUTO = D12.D12_PRDORI
							AND SC9.C9_LOTECTL = D12.D12_LOTECT
							AND SC9.C9_IDDCF = DCR.DCR_IDDCF
							AND SC9.C9_NFISCAL = ' '
							AND SC9.C9_IDDCF <> %Exp:aIdDCF[nI]%
							AND SC9.%NotDel%
						LEFT JOIN %Table:D11% D11 
							ON D11.D11_FILIAL = %xFilial:D11%
							AND D11.D11_PRODUT = D12.D12_PRDORI
							AND D11.D11_PRDORI = D12.D12_PRDORI
							AND D11.D11_PRDCMP = D12.D12_PRODUT
							AND D11.%NotDel%
						WHERE D12.D12_FILIAL = %xFilial:D12%
							AND D12.D12_DOC = %Exp:cDocto%
							AND D12.D12_CLIFOR = %Exp:cCliFor%
							AND D12.D12_LOJA  = %Exp:cLoja%
							AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
							AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
							AND D12.D12_ATUEST = '1'
							AND D12.D12_MNTVOL IN ('1','2')
							AND D12.D12_STATUS IN ('1','2','3','4','-')
							AND D12.%NotDel%
						GROUP BY SC9.C9_PRODUTO,
								SC9.C9_LOTECTL,
								SC9.C9_CLIENTE,
								SC9.C9_LOJA,
								SC9.C9_PEDIDO,
								SC9.C9_CARGA,
								D11.D11_QTMULT
						UNION 
						SELECT SUM(DCR.DCR_QUANT) AS QTD_MNTVOL,
							SC9.C9_PRODUTO,
							SC9.C9_LOTECTL,
							SC9.C9_CLIENTE,
							SC9.C9_LOJA,
							SC9.C9_PEDIDO,
							SC9.C9_CARGA
						FROM %Table:DCR% DCR
						INNER JOIN %Table:DCF% DCF ON (DCF.DCF_FILIAL = %xFilial:DCF%
							AND DCF.DCF_ID = DCR.DCR_IDDCF
							AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
							AND DCF.%NotDel%)
						INNER JOIN %Table:DC5% DC5 ON (DC5.DC5_FILIAL = %xFilial:DC5%
							AND DC5.DC5_SERVIC = DCF.DCF_SERVIC
							AND DC5.DC5_OPERAC IN ('3','4')
							AND DC5.%NotDel%)
						INNER JOIN %Table:SC9% SC9 ON (SC9.C9_FILIAL = %xFilial:SC9%
							AND SC9.C9_CLIENTE = DCF.DCF_CLIFOR
							AND SC9.C9_LOJA = DCF.DCF_LOJA
							AND SC9.C9_PEDIDO = DCF.DCF_DOCTO
							AND SC9.C9_PRODUTO = DCF.DCF_CODPRO
							AND SC9.C9_IDDCF = DCR.DCR_IDDCF
							AND SC9.C9_NFISCAL = ' '
							AND SC9.C9_IDDCF = DCF.DCF_ID
							AND SC9.%NotDel%)
						LEFT JOIN %Table:D11% D11 ON (D11.D11_FILIAL = %xFilial:D11%
							AND D11.D11_PRODUT = DCF.DCF_PRDORI
							AND D11.D11_PRDORI = DCF.DCF_PRDORI
							AND D11.D11_PRDCMP = DCF.DCF_CODPRO
							AND D11.%NotDel%)
						WHERE DCR.DCR_FILIAL = %xFilial:DCR%
							AND DCR.DCR_IDDCF <> %Exp:aIdDCF[nI]%
							AND DC5.DC5_MNTVOL = '1'
							AND DCF.DCF_DOCTO = %Exp:cDocto%
							AND DCF.DCF_CLIFOR = %Exp:cCliFor%
							AND DCF.DCF_LOJA = %Exp:cLoja%
							AND DCF.DCF_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
							AND DCF.DCF_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
							AND DCF.DCF_STSERV = '3'
							AND DCR.DCR_IDORI NOT IN (SELECT DCR_IDORI FROM %Table:DCR% DCR2 WHERE DCR2.DCR_FILIAL = %xFilial:DCR% AND DCR2.DCR_IDORI = DCR.DCR_IDDCF AND DCR2.%NotDel%)
							AND DCR.%NotDel%
						GROUP BY SC9.C9_PRODUTO,
								SC9.C9_LOTECTL,
								SC9.C9_CLIENTE,
								SC9.C9_LOJA,
								SC9.C9_PEDIDO,
								SC9.C9_CARGA,
								D11.D11_QTMULT) MNTVOL
			ON MNTVOL.C9_CLIENTE = DCF.DCF_CLIFOR
			AND MNTVOL.C9_LOJA = DCF.DCF_LOJA
			AND MNTVOL.C9_PEDIDO = DCF.DCF_DOCTO
			AND MNTVOL.C9_PRODUTO = D12.D12_PRDORI
			AND MNTVOL.C9_LOTECTL = D12.D12_LOTECT
			AND MNTVOL.C9_CARGA = DCF.DCF_CARGA
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = %Exp:aIdDCF[nI]%
			AND DCR.%NotDel% 
			GROUP BY DCF.DCF_CARGA,
					DCF.DCF_DOCTO,
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_PRODUT,
					D12.D12_PRDORI,
					MNTVOL.QTD_MNTVOL
			EndSql

			Do While (cAliasQry)->(!Eof())
				// Valida se possui montagem de volume
				If (cAliasQry)->QTD_MNTVOL > 0
					oMntVolItem := WMSDTCMontagemVolumeItens():New()
					oMntVolItem:SetCarga((cAliasQry)->DCF_CARGA)
					oMntVolItem:SetPedido((cAliasQry)->DCF_DOCTO)
					oMntVolItem:SetPrdOri((cAliasQry)->D12_PRDORI)
					oMntVolItem:SetProduto((cAliasQry)->D12_PRODUT)
					oMntVolItem:SetLoteCtl((cAliasQry)->D12_LOTECT)
					oMntVolItem:SetNumLote((cAliasQry)->D12_NUMLOT)
					oMntVolItem:SetLibPed(Self:oMovServic:GetLibPed())
					oMntVolItem:SetMntExc(Self:oMovServic:GetMntExc())
					// Busca o código da montagem de volume
					oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
					oMntVolItem:SetIdDCF(aIdDCF[nI])
					oMntVolItem:SetQtdOri((cAliasQry)->QTD_MNTVOL)
					lRet := oMntVolItem:AssignDCT()
					If !lRet
						Self:cErro := oMntVolItem:GetErro()
					EndIf
					oMntVolItem:Destroy()
				EndIf
				(cAliasQry)->(DbSkip())
			End Do
			(cAliasQry)->(DbCloseArea())

		EndIf

		// Valida se possui distribuição da separação
		If Self:oMovServic:ChkDisSep()
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
			SELECT DCF.DCF_CARGA,
				DCF.DCF_DOCTO,
				D12.D12_LOTECT,
				D12.D12_NUMLOT,
				D12.D12_PRODUT,
				D12.D12_PRDORI,
				CASE WHEN DISSEP.QTD_DISSEP IS NULL THEN SUM(DCR.DCR_QUANT) 
				ELSE SUM(DCR.DCR_QUANT) + DISSEP.QTD_DISSEP END QTD_DISSEP
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12
				ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_STATUS IN ('1','2','3','4','-')
			AND D12.D12_ATUEST = '1'
			AND D12.%NotDel% 
			INNER JOIN %Table:DCF% DCF 
				ON DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_ID = DCR.DCR_IDDCF
			AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
			AND DCF.%NotDel% 
			LEFT JOIN ( SELECT SUM(DCR.DCR_QUANT) AS QTD_DISSEP,
								SC9.C9_PRODUTO,
								SC9.C9_LOTECTL,
								SC9.C9_CLIENTE,
								SC9.C9_LOJA,
								SC9.C9_PEDIDO,
								SC9.C9_CARGA
						FROM %Table:D12% D12
						INNER JOIN %Table:DCR% DCR 
							ON DCR.DCR_FILIAL = %xFilial:DCR%
							AND DCR.DCR_IDMOV = D12.D12_IDMOV 
							AND DCR.DCR_IDOPER = D12.D12_IDOPER
							AND DCR.DCR_IDORI = D12.D12_IDDCF
							AND DCR.%NotDel%
						INNER JOIN %Table:DCF% DCF 
							ON DCF.DCF_FILIAL = %xFilial:DCF%
							AND DCF.DCF_ID = DCR.DCR_IDDCF
							AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
							AND DCF.%NotDel%
						INNER JOIN %Table:SC9% SC9 
							ON SC9.C9_FILIAL = %xFilial:SC9%
							AND SC9.C9_CLIENTE = DCF.DCF_CLIFOR
							AND SC9.C9_LOJA = DCF.DCF_LOJA
							AND SC9.C9_PEDIDO = DCF.DCF_DOCTO
							AND SC9.C9_PRODUTO = D12.D12_PRDORI
							AND SC9.C9_LOTECTL = D12.D12_LOTECT
							AND SC9.C9_IDDCF = DCR.DCR_IDDCF
							AND SC9.C9_NFISCAL = ' '
							AND SC9.C9_IDDCF <> %Exp:aIdDCF[nI]%
							AND SC9.%NotDel%
						LEFT JOIN %Table:D11% D11 
							ON D11.D11_FILIAL = %xFilial:D11%
							AND D11.D11_PRODUT = D12.D12_PRDORI
							AND D11.D11_PRDORI = D12.D12_PRDORI
							AND D11.D11_PRDCMP = D12.D12_PRODUT
							AND D11.%NotDel%
						WHERE D12.D12_FILIAL = %xFilial:D12%
							AND D12.D12_DOC = %Exp:cDocto%
							AND D12.D12_CLIFOR = %Exp:cCliFor%
							AND D12.D12_LOJA  = %Exp:cLoja%
							AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
							AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
							AND D12.D12_LOCORI = %Exp:Self:oMovEndDes:GetArmazem()%
							AND D12.D12_ATUEST = '1'
							AND D12.D12_DISSEP = '1'
							AND D12.D12_STATUS IN ('1','2','3','4','-')
							AND D12.%NotDel%
						GROUP BY SC9.C9_PRODUTO,
								SC9.C9_LOTECTL,
								SC9.C9_CLIENTE,
								SC9.C9_LOJA,
								SC9.C9_PEDIDO,
								SC9.C9_CARGA,
								D11.D11_QTMULT) DISSEP
			ON DISSEP.C9_CLIENTE = DCF.DCF_CLIFOR
			AND DISSEP.C9_LOJA = DCF.DCF_LOJA
			AND DISSEP.C9_PEDIDO = DCF.DCF_DOCTO
			AND DISSEP.C9_PRODUTO = D12.D12_PRDORI
			AND DISSEP.C9_LOTECTL = D12.D12_LOTECT
			AND DISSEP.C9_CARGA = DCF.DCF_CARGA
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = %Exp:aIdDCF[nI]%
			AND DCR.%NotDel% 
			GROUP BY DCF.DCF_CARGA,
					DCF.DCF_DOCTO,
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_PRODUT,
					D12.D12_PRDORI,
					DISSEP.QTD_DISSEP
			EndSql

			Do While (cAliasQry)->(!Eof())
				// Enquanto for maior que zero, vai separando a quantidade de uma norma ou o restante
				// Deve verificar se a estrutura da sequência de abastecimento utiliza distribuição da separação
				If (cAliasQry)->QTD_DISSEP > 0
					oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
					oDisSepItem:oDisSep:SetCarga((cAliasQry)->DCF_CARGA)
					oDisSepItem:oDisSep:SetPedido((cAliasQry)->DCF_DOCTO)
					oDisSepItem:oDisSep:oDisEndDes:SetArmazem(Self:oMovEndDes:GetArmazem())
					oDisSepItem:SetPrdOri((cAliasQry)->D12_PRDORI)
					oDisSepItem:oDisPrdLot:SetProduto((cAliasQry)->D12_PRODUT)
					oDisSepItem:oDisPrdLot:SetLoteCtl((cAliasQry)->D12_LOTECT)
					oDisSepItem:oDisPrdLot:SetNumLote((cAliasQry)->D12_NUMLOT)
					oDisSepItem:oDisPrdLot:SetNumSer(Self:oMovPrdLot:GetNumSer())
					oDisSepItem:oDisEndOri:SetArmazem(Self:oMovEndDes:GetArmazem())
					oDisSepItem:oDisEndOri:SetEnder(Self:oMovEndDes:GetEnder())
					// Busca codigo da distribuição da separação
					oDisSepItem:SetCodDis(oDisSepItem:oDisSep:FindCodDis())
					oDisSepItem:SetIdDCF(aIdDCF[nI])
					oDisSepItem:SetQtdOri((cAliasQry)->QTD_DISSEP)
					lRet := oDisSepItem:AssignD0E()
					If !lRet
						Self:cErro := oDisSepItem:GetErro()
					EndIf
					oDisSepItem:Destroy()
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf

		// Valida se possui conferencia de expedição
		If Self:oMovServic:ChkConfExp()
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
			SELECT DCF.DCF_CARGA,
				DCF.DCF_DOCTO,
				D12.D12_LOTECT,
				D12.D12_NUMLOT,
				D12.D12_PRODUT,
				D12.D12_PRDORI,
				CASE WHEN CONFEXP.QTD_CONFEXP IS NULL THEN SUM(DCR.DCR_QUANT) 
				ELSE SUM(DCR.DCR_QUANT) + CONFEXP.QTD_CONFEXP END QTD_CONFEXP
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12
				ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_STATUS IN ('1','2','3','4','-')
			AND D12.D12_ATUEST = '1'
			AND D12.%NotDel% 
			INNER JOIN %Table:DCF% DCF 
				ON DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_ID = DCR.DCR_IDDCF
			AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
			AND DCF.%NotDel% 
			LEFT JOIN ( SELECT SUM(DCR.DCR_QUANT) AS QTD_CONFEXP,
								SC9.C9_PRODUTO,
								SC9.C9_LOTECTL,
								SC9.C9_CLIENTE,
								SC9.C9_LOJA,
								SC9.C9_PEDIDO,
								SC9.C9_CARGA
						FROM %Table:D12% D12
						INNER JOIN %Table:DCR% DCR 
							ON DCR.DCR_FILIAL = %xFilial:DCR%
							AND DCR.DCR_IDMOV = D12.D12_IDMOV 
							AND DCR.DCR_IDOPER = D12.D12_IDOPER
							AND DCR.DCR_IDORI = D12.D12_IDDCF
							AND DCR.%NotDel%
						INNER JOIN %Table:DCF% DCF 
							ON DCF.DCF_FILIAL = %xFilial:DCF%
							AND DCF.DCF_ID = DCR.DCR_IDDCF
							AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
							AND DCF.%NotDel%
						INNER JOIN %Table:D0H% D0H
							ON D0H.D0H_FILIAL = %xFilial:D0H%
							AND D0H.D0H_IDDCF = DCF.DCF_ID
							AND D0H.%NotDel%                                                                                                                            
						INNER JOIN %Table:SC9% SC9 
							ON SC9.C9_FILIAL = %xFilial:SC9%
							AND SC9.C9_CLIENTE = DCF.DCF_CLIFOR
							AND SC9.C9_LOJA = DCF.DCF_LOJA
							AND SC9.C9_PEDIDO = DCF.DCF_DOCTO
							AND SC9.C9_PRODUTO = D12.D12_PRDORI
							AND SC9.C9_LOTECTL = D12.D12_LOTECT
							AND SC9.C9_IDDCF = DCR.DCR_IDDCF
							AND SC9.C9_NFISCAL = ' '
							AND SC9.C9_IDDCF <> %Exp:aIdDCF[nI]%
							AND SC9.%NotDel%
						LEFT JOIN %Table:D11% D11 
							ON D11.D11_FILIAL = %xFilial:D11%
							AND D11.D11_PRODUT = D12.D12_PRDORI
							AND D11.D11_PRDORI = D12.D12_PRDORI
							AND D11.D11_PRDCMP = D12.D12_PRODUT
							AND D11.%NotDel%
						WHERE D12.D12_FILIAL = %xFilial:D12%
							AND D12.D12_DOC = %Exp:cDocto%
							AND D12.D12_CLIFOR = %Exp:cCliFor%
							AND D12.D12_LOJA  = %Exp:cLoja%
							AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
							AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
							AND D12.D12_ATUEST = '1'
							AND D12.D12_STATUS IN ('1','2','3','4','-')
							AND D12.%NotDel%
						GROUP BY SC9.C9_PRODUTO,
								SC9.C9_LOTECTL,
								SC9.C9_CLIENTE,
								SC9.C9_LOJA,
								SC9.C9_PEDIDO,
								SC9.C9_CARGA,
								D11.D11_QTMULT) CONFEXP
			ON CONFEXP.C9_CLIENTE = DCF.DCF_CLIFOR
			AND CONFEXP.C9_LOJA = DCF.DCF_LOJA
			AND CONFEXP.C9_PEDIDO = DCF.DCF_DOCTO
			AND CONFEXP.C9_PRODUTO = D12.D12_PRDORI
			AND CONFEXP.C9_LOTECTL = D12.D12_LOTECT
			AND CONFEXP.C9_CARGA = DCF.DCF_CARGA
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = %Exp:aIdDCF[nI]%
			AND DCR.%NotDel% 
			GROUP BY DCF.DCF_CARGA,
					DCF.DCF_DOCTO,
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_PRODUT,
					D12.D12_PRDORI,
					CONFEXP.QTD_CONFEXP
			EndSql
		
			Do While (cAliasQry)->(!Eof())
				// Valida se possui conferencia de expedição
				If (cAliasQry)->QTD_CONFEXP > 0
					oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
					oConExpItem:SetCarga((cAliasQry)->DCF_CARGA)
					oConExpItem:SetPedido((cAliasQry)->DCF_DOCTO)
					oConExpItem:SetPrdOri((cAliasQry)->D12_PRDORI)
					oConExpItem:SetProduto((cAliasQry)->D12_PRODUT)
					oConExpItem:SetLoteCtl((cAliasQry)->D12_LOTECT)
					oConExpItem:SetNumLote((cAliasQry)->D12_NUMLOT)
					oConExpItem:SetLibPed(Self:oMovServic:GetLibPed())
					// Busca codigo da conferencia de expedição
					oConExpItem:SetCodExp(oConExpItem:oConfExp:FindCodExp())
					oConExpItem:SetIdDCF(aIdDCF[nI])
					oConExpItem:SetQtdOri((cAliasQry)->QTD_CONFEXP)
					lRet := oConExpItem:AssignD02()
					If !lRet
						Self:cErro := oConExpItem:GetErro()
					EndIf
					oConExpItem:Destroy()
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf

	Next nI
	
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} RecordD12
Gravação dos dados D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD RecordD12() CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local lAglutina := .F.
Local lHasLibD12:= AttIsMemberOf(Self:oOrdServ,"aLibD12",.T.) .And. ValType(Self:oOrdServ:aLibD12)=="A"
Local aAreaD12  := D12->(GetArea())
Local oRelacMov := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local cAliasD12 := Nil
Local cAliasDAK := Nil
Local cWhere    := ""
Local cIdDCF    := ""
Local cSequen   := ""
Local cIdMovto  := ""
Local cIdOpera  := ""
Local nQtdNorma := 0
Local nQtdMovto := 0
Local nQtdMovto2:= 0
Local nQtdLida  := 0
Local nQtdLida2 := 0
Local nQtdOrig  := 0
Local nQtdOrig2 := 0
Local nOrdTar   := 0
Local nI        := 0
Local nQtdTotal := 0
Local nQtdDCR   := 0
	// Armazena informações origem
	cIdDCF          := Self:GetIdDCF()
	cSequen         := Self:GetSequen()
	cIdMovto        := Self:cIdMovto
	cIdOpera        := GetSx8Num('D12','D12_IDOPER'); ConfirmSX8()
	Self:cIdOpera   := cIdOpera
	// Atribui quantidades
	nQtdMovto  := Self:nQtdMovto
	nQtdMovto2 := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdMovto,0,2)
	nQtdLida   := Self:nQtdLida
	nQtdLida2  := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdLida,0,2)


	WmsConout('RecordD12 - cIdDCF / cIdMovto / cIdOper / nQtdMovto / nQtdLida ' + cIdDCF + ' / ' + cIdMovto + ' / ' + cIdOpera + ' / ' + cValtoChar(nQtdMovto) + ' / ' + cValToChar(nQtdLida))

	// Preenche a Sequencia da Carga
	If !Empty(Self:oOrdServ:GetCarga()) .And. Empty(Self:cSeqCarga)
		cAliasDAK := GetNextAlias()
		BeginSql Alias cAliasDAK
			SELECT DAK.DAK_SEQCAR
			FROM %Table:DAK% DAK
			WHERE DAK.DAK_FILIAL = %xFilial:DAK%
			AND DAK.DAK_COD = %Exp:Self:oOrdServ:GetCarga()%
			AND DAK.%NotDel%
		EndSql
		If (cAliasDAK)->(!Eof())
			Self:cSeqCarga := (cAliasDAK)->DAK_SEQCAR
		EndIf
		(cAliasDAK)->(dbCloseArea())
	EndIf
	// Verifica tipo de aglutinação defido e se não é
	// um movimento de estorno de movimento aglutinado
	WmsConout('RecordD12 - Regra de aglutinação ')
	If Self:cStatus <> '0' .And. Self:oMovTarefa:GetTpAglu() > "1" .And. !Self:IsMovUnit() .And. !Self:lEstAglu .And. !Self:oMovServic:ChkConfer() .And. !Self:lUpdMovto
		// Posiciona no Registro para Aglutinacao
		nQtdNorma := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis(),,.F.)
		WmsConout('RecordD12 - Determinando qtde do movto - nQtdMovto / nQtdNorma ' + cValToChar(Self:nQtdMovto) + ' / ' + cValToChar(nQtdNorma))
		If QtdComp(Self:nQtdMovto) < QtdComp(nQtdNorma) .And. ;
			(!Self:oMovTarefa:GetTpAglu() $ "4|5"  .Or. (Self:oMovTarefa:GetTpAglu() $ "4|5" .And. WmsCarga(Self:oOrdServ:GetCarga())))
			cWhere := "%"
			If Self:oMovTarefa:GetTpAglu() == "2" .And. Self:oMovServic:ChkRecebi()
				cWhere += " AND D12.D12_SERIE = '"+Self:oOrdServ:GetSerie()+"'"
			EndIf
			If Self:lHasUniDes
				cWhere += " AND D12.D12_UNIDES = '"+Self:cUniDes+"'"
			EndIf
			cWhere += "%"
			
			cAliasD12 := GetNextAlias()
			Do Case
				Case Self:oMovTarefa:GetTpAglu() == "2" // Aglutina por Documento+Serie
					BeginSql Alias cAliasD12
						SELECT D12.R_E_C_N_O_ RECNOD12
						FROM %Table:D12% D12
						WHERE D12.D12_FILIAL = %xFilial:D12%
						AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
						AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
						AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
						AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
						AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
						AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
						AND D12.D12_ENDORI = %Exp:Self:oMovEndOri:GetEnder()%
						AND D12.D12_LOCDES = %Exp:Self:oMovEndDes:GetArmazem()%
						AND D12.D12_ENDDES = %Exp:Self:oMovEndDes:GetEnder()%
						AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
						AND D12.D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
						AND D12.D12_ATIVID = %Exp:Self:oMovTarefa:GetAtivid()%
						AND D12.D12_MAPTIP = %Exp:Self:cMapaTipo%
						AND D12.D12_IDUNIT = %Exp:Self:cIdUnitiz%
						AND D12.D12_STATUS IN ( %Exp:Self:cStatus% ,'-')
						AND D12.D12_MNTVOL = %Exp:Self:cMntVol%
						AND D12.D12_DISSEP = %Exp:Self:cDisSep%
						AND D12.D12_RADIOF = %Exp:Self:cRadioF%
						AND D12.D12_QTDMOV + %Exp:AllTrim(Str(Self:nQtdMovto))% <= %Exp:AllTrim(Str(nQtdNorma))%
						AND D12.D12_DOC = %Exp:Self:oOrdServ:GetDocto()%
						AND D12.%NotDel%
						%Exp:cWhere%
					EndSql
				Case Self:oMovTarefa:GetTpAglu() == "3" // Aglutina por Cliente/Fornecedor+Loja
					BeginSql Alias cAliasD12
						SELECT D12.R_E_C_N_O_ RECNOD12
						FROM %Table:D12% D12
						WHERE D12.D12_FILIAL = %xFilial:D12%
						AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
						AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
						AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
						AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
						AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
						AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
						AND D12.D12_ENDORI = %Exp:Self:oMovEndOri:GetEnder()%
						AND D12.D12_LOCDES = %Exp:Self:oMovEndDes:GetArmazem()%
						AND D12.D12_ENDDES = %Exp:Self:oMovEndDes:GetEnder()%
						AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
						AND D12.D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
						AND D12.D12_ATIVID = %Exp:Self:oMovTarefa:GetAtivid()%
						AND D12.D12_MAPTIP = %Exp:Self:cMapaTipo%
						AND D12.D12_IDUNIT = %Exp:Self:cIdUnitiz%
						AND D12.D12_STATUS IN ( %Exp:Self:cStatus% ,'-')
						AND D12.D12_MNTVOL = %Exp:Self:cMntVol%
						AND D12.D12_DISSEP = %Exp:Self:cDisSep%
						AND D12.D12_RADIOF = %Exp:Self:cRadioF%
						AND D12.D12_QTDMOV + %Exp:AllTrim(Str(Self:nQtdMovto))% <= %Exp:AllTrim(Str(nQtdNorma))%
						AND D12.D12_CLIFOR = %Exp:Self:oOrdServ:GetCliFor()%
						AND D12.D12_LOJA = %Exp:Self:oOrdServ:GetLoja()%
						AND D12.%NotDel%
						%Exp:cWhere%
					EndSql
				Case Self:oMovTarefa:GetTpAglu() == "4" // Aglutina por Carga+Sequencia da Carga
					BeginSql Alias cAliasD12
						SELECT D12.R_E_C_N_O_ RECNOD12
						FROM %Table:D12% D12
						WHERE D12.D12_FILIAL = %xFilial:D12%
						AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
						AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
						AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
						AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
						AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
						AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
						AND D12.D12_ENDORI = %Exp:Self:oMovEndOri:GetEnder()%
						AND D12.D12_LOCDES = %Exp:Self:oMovEndDes:GetArmazem()%
						AND D12.D12_ENDDES = %Exp:Self:oMovEndDes:GetEnder()%
						AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
						AND D12.D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
						AND D12.D12_ATIVID = %Exp:Self:oMovTarefa:GetAtivid()%
						AND D12.D12_MAPTIP = %Exp:Self:cMapaTipo%
						AND D12.D12_IDUNIT = %Exp:Self:cIdUnitiz%
						AND D12.D12_STATUS IN ( %Exp:Self:cStatus% ,'-')
						AND D12.D12_MNTVOL = %Exp:Self:cMntVol%
						AND D12.D12_DISSEP = %Exp:Self:cDisSep%
						AND D12.D12_RADIOF = %Exp:Self:cRadioF%
						AND D12.D12_QTDMOV + %Exp:AllTrim(Str(Self:nQtdMovto))% <= %Exp:AllTrim(Str(nQtdNorma))%
						AND D12.D12_CARGA = %Exp:Self:oOrdServ:GetCarga()%
						AND D12.D12_SEQCAR = %Exp:Self:cSeqCarga%
						AND D12.%NotDel%
						%Exp:cWhere%
					EndSql
				Case Self:oMovTarefa:GetTpAglu() == "5" // Aglutina por Carga+Sequencia da Carga+Cliente+loja
					BeginSql Alias cAliasD12
						SELECT D12.R_E_C_N_O_ RECNOD12
						FROM %Table:D12% D12
						WHERE D12.D12_FILIAL = %xFilial:D12%
						AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
						AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
						AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
						AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
						AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
						AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
						AND D12.D12_ENDORI = %Exp:Self:oMovEndOri:GetEnder()%
						AND D12.D12_LOCDES = %Exp:Self:oMovEndDes:GetArmazem()%
						AND D12.D12_ENDDES = %Exp:Self:oMovEndDes:GetEnder()%
						AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
						AND D12.D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
						AND D12.D12_ATIVID = %Exp:Self:oMovTarefa:GetAtivid()%
						AND D12.D12_MAPTIP = %Exp:Self:cMapaTipo%
						AND D12.D12_IDUNIT = %Exp:Self:cIdUnitiz%
						AND D12.D12_STATUS IN ( %Exp:Self:cStatus% ,'-')
						AND D12.D12_MNTVOL = %Exp:Self:cMntVol%
						AND D12.D12_DISSEP = %Exp:Self:cDisSep%
						AND D12.D12_RADIOF = %Exp:Self:cRadioF%
						AND D12.D12_QTDMOV + %Exp:AllTrim(Str(Self:nQtdMovto))% <= %Exp:AllTrim(Str(nQtdNorma))%
						AND D12.D12_CARGA = %Exp:Self:oOrdServ:GetCarga()%
						AND D12.D12_SEQCAR = %Exp:Self:cSeqCarga%
						AND D12.D12_CLIFOR = %Exp:Self:oOrdServ:GetCliFor()%
						AND D12.D12_LOJA =  %Exp:Self:oOrdServ:GetLoja()%
						AND D12.%NotDel%
						%Exp:cWhere%
					EndSql
				Case Self:oMovTarefa:GetTpAglu() == "6" // Aglutina por produto
					BeginSql Alias cAliasD12
						SELECT D12.R_E_C_N_O_ RECNOD12
						FROM %Table:D12% D12
						WHERE D12.D12_FILIAL = %xFilial:D12%
						AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
						AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
						AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
						AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
						AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
						AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
						AND D12.D12_ENDORI = %Exp:Self:oMovEndOri:GetEnder()%
						AND D12.D12_LOCDES = %Exp:Self:oMovEndDes:GetArmazem()%
						AND D12.D12_ENDDES = %Exp:Self:oMovEndDes:GetEnder()%
						AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
						AND D12.D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
						AND D12.D12_ATIVID = %Exp:Self:oMovTarefa:GetAtivid()%
						AND D12.D12_MAPTIP = %Exp:Self:cMapaTipo%
						AND D12.D12_IDUNIT = %Exp:Self:cIdUnitiz%
						AND D12.D12_STATUS IN ( %Exp:Self:cStatus% ,'-')
						AND D12.D12_MNTVOL = %Exp:Self:cMntVol%
						AND D12.D12_DISSEP = %Exp:Self:cDisSep%
						AND D12.D12_RADIOF = %Exp:Self:cRadioF%
						AND D12.D12_QTDMOV + %Exp:AllTrim(Str(Self:nQtdMovto))% <= %Exp:AllTrim(Str(nQtdNorma))%
						AND D12.%NotDel%
						%Exp:cWhere%
					EndSql
			EndCase
			WmsConout('*** Verificando se há registro para aglutinar com base na query abaixo')
			WmsConout('RecordD12 - ' + GetLastQuery()[2])
			If (cAliasD12)->(!Eof())
				lAglutina := .T.
				// Verifica se aglutina e posiciona no registro aglutinador
				D12->(dbGoTo((cAliasD12)->RECNOD12))
				WmsConout('RecordD12 - lAglutina .T. D12Goto ' + cValToChar((cAliasD12)->RECNOD12))
			else
				WmsConout('Registro não encontrado')
			EndIf
			(cAliasD12)->(dbCloseArea())
		EndIf
	EndIf
	dbSelectArea('D12')
	WmsConout('RecordD12 - dbSelectArea na D12 com Recno ' + cValToChar(D12->(Recno())))
	Self:cAgluti := Iif(lAglutina,"1","2")
	WmsConout('RecordD12 - cAgluti (se 2 a query anterior retornou vazio) ' + Self:cAgluti)
	// Utiliza o array quando documentos aglutinados
	WmsConout('RecordD12 - Tamanho da lista de aglutinacao (Len(aOrdAglu)) ' + cValToChar(Len(Self:aOrdAglu)))
	If !Empty(Self:aOrdAglu) 
		// Grava relacionamento movimento servico armazem
		nOrdPrd := Self:oOrdServ:nProduto
		nOrdTar := Self:oOrdServ:nTarefa
		For nI := 1 To Len(Self:aOrdAglu)
			aAgluMov := Self:aOrdAglu[nI][POSTAREFA][nOrdPrd][nOrdTar]
			WmsConout('RecordD12 - Item da lista (nI) / Qtd Movimento ' + cValToChar(nI) + ' / ' + cValToChar(aAgluMov[POSQTDMOV]))
			
			If aAgluMov[POSQTDMOV] > 0
				cIdDCF     := aAgluMov[POSIDDCF]
				nQtdMovto  := aAgluMov[POSQTDMOV]
				nQtdMovto2 := ConvUm(Self:oMovPrdLot:GetProduto(),nQtdMovto,0,2)

				oRelacMov:SetIdOrig(Iif(lAglutina,D12->D12_IDDCF,cIdDCF))
				oRelacMov:SetIdDCF(Self:aOrdAglu[nI][1])
				oRelacMov:SetIdMovto(Iif(lAglutina,D12->D12_IDMOV,cIdMovto))
				oRelacMov:SetIdOpera(Iif(lAglutina,D12->D12_IDOPER,cIdOpera))
				oRelacMov:SetSequen(Self:aOrdAglu[nI][4])
				WmsConout('RecordD12 - oRelacMov (DCR) ' + oRelacMov:GetIdOrig() + ' ' + oRelacMov:GetIdDCF() + ' ' + oRelacMov:GetIdMovto() + ' ' + oRelacMov:GetIdOpera() + ' ' + oRelacMov:GetSequen())

				If oRelacMov:LoadData()
					WmsConout('RecordD12 - oRelacMov update Qtde' + cValToChar(nQtdMovto))
					oRelacMov:SetQuant(oRelacMov:GetQuant()+nQtdMovto)
					oRelacMov:SetQuant2(oRelacMov:GetQuant2()+nQtdMovto2)
					oRelacMov:UpdateDCR()
				Else
					WmsConout('RecordD12 - oRelacMov insert Qtde ' + cValToChar(nQtdMovto))
					oRelacMov:SetQuant(nQtdMovto)
					oRelacMov:SetQuant2(nQtdMovto2)
					oRelacMov:RecordDCR()
				EndIf
				nQtdTotal += nQtdMovto
				nQtdDCR++
				WmsConout('RecordD12 - nQtdDCR ' + cValToChar(nQtdDCR))
			EndIf
		Next nI
		nQtdMovto := nQtdTotal
		WmsConout('RecordD12 - Qtde com base nas DCR (nQtdMovto) ' + cValToChar(nQtdMovto))
		nQtdMovto2 := ConvUm(Self:oMovPrdLot:GetProduto(),nQtdMovto,0,2)
		Self:cAgluti := Iif(nQtdDCR > 1,"1","2") 
		WmsConout('RecordD12 - Qtde DCR (nQtdDCR) / cAgluti ' + cValToChar(nQtdDCR) + ' / ' + Self:cAgluti) 
		// Verifica se a DCF é diferente da executada, posiciona a mesma
		WmsConout('RecordD12 - Para troca de DCF Ori - Ultima DCF e DCF usada ' + cIdDCF + ' ' + Self:oOrdServ:GetIdDCF())
		If cIdDCF <> Self:oOrdServ:GetIdDCF()
			// Atribui ordem de serviço para carregar os documentos corretos
			Self:oOrdServ:SetIdDCF(cIdDCF)
			Self:oOrdServ:LoadData()
		EndIf
	ElseIf !Empty(Self:aMovAglu)
		Self:cAgluti := "1"
		WmsConout('RecordD12 - cAgluti ' + Self:cAgluti) 

		For nI := 1 To Len(Self:aMovAglu)
			oRelacMov:SetIdOrig(cIdDCF)
			oRelacMov:SetIdDCF(Self:aMovAglu[nI][1])
			oRelacMov:SetIdMovto(cIdMovto)
			oRelacMov:SetIdOpera(cIdOpera)
			oRelacMov:SetSequen(Self:aMovAglu[nI][2])
			WmsConout('RecordD12 - oRelacMov 2 (DCR) ' + oRelacMov:GetIdOrig() + ' ' + oRelacMov:GetIdDCF() + ' ' + oRelacMov:GetIdMovto() + ' ' + oRelacMov:GetIdOpera() + ' ' + oRelacMov:GetSequen())
			If oRelacMov:LoadData()
				WmsConout('RecordD12 - oRelacMov 2 update qtde ' + cValToChar(Self:aMovAglu[nI][3]))
				oRelacMov:SetQuant(oRelacMov:GetQuant()+Self:aMovAglu[nI][3])
				oRelacMov:SetQuant2(oRelacMov:GetQuant2()+Self:aMovAglu[nI][4])
				oRelacMov:UpdateDCR()
			Else
				WmsConout('RecordD12 - oRelacMov 2 insert qtde ' + cValToChar(Self:aMovAglu[nI][3]))
				oRelacMov:SetQuant(Self:aMovAglu[nI][3])
				oRelacMov:SetQuant2(Self:aMovAglu[nI][4])
				oRelacMov:RecordDCR()
			EndIf
		Next nI
	Else
		// Grava relacionamento movimento servico armazem
		oRelacMov:SetIdOrig(IIf(lAglutina,D12->D12_IDDCF,cIdDCF))
		oRelacMov:SetIdDCF(cIdDCF)
		oRelacMov:SetSequen(cSequen)
		oRelacMov:SetIdMovto(IIf(lAglutina,D12->D12_IDMOV,cIdMovto))
		oRelacMov:SetIdOpera(IIf(lAglutina,D12->D12_IDOPER,cIdOpera))
		WmsConout('RecordD12 - oRelacMov 3 (DCR) ' + oRelacMov:GetIdOrig() + ' ' + oRelacMov:GetIdDCF() + ' ' + oRelacMov:GetIdMovto() + ' ' + oRelacMov:GetIdOpera() + ' ' + oRelacMov:GetSequen())
		If oRelacMov:LoadData()
			WmsConout('RecordD12 - oRelacMov update qtde ' + cValToChar(nQtdMovto))
			oRelacMov:SetQuant(oRelacMov:GetQuant()+nQtdMovto)
			oRelacMov:SetQuant2(oRelacMov:GetQuant2()+nQtdMovto2)
			oRelacMov:UpdateDCR()
		Else
			WmsConout('RecordD12 - oRelacMov insert qtde ' + cValToChar(nQtdMovto))
			oRelacMov:SetQuant(nQtdMovto)
			oRelacMov:SetQuant2(nQtdMovto2)
			oRelacMov:RecordDCR()
		EndIf
	EndIf

	If lAglutina
		// Somatorias
		nQtdMovto  += D12->D12_QTDMOV
		nQtdMovto2 += D12->D12_QTDMO2
		WmsConout('RecordD12 - nQtdMovto D12 ' + cValToChar(nQtdMovto))
	EndIf
	// Ajusta quantidades
	nQtdOrig  := nQtdMovto
	nQtdOrig2 := nQtdMovto2
	// Busca sequencia de execução da OS
	If !lAglutina
		Self:cSeqPrior := Self:oOrdServ:GetSeqPri()
		WmsConout('RecordD12 - Self:cSeqPrior ' + Self:cSeqPrior)
 	EndIf
	// Grava dados
	Reclock('D12', !lAglutina)
	If !lAglutina
		WmsConout('RecordD12 - Insert D12')

		D12->D12_FILIAL := xFilial("D12")
		D12->D12_IDDCF  := cIdDCF //Self:GetIdDCF()
		D12->D12_IDMOV  := Self:cIdMovto
		D12->D12_IDOPER := Self:cIdOpera
		D12->D12_NUMSEQ := Self:oOrdServ:GetNumSeq()
		D12->D12_SEQUEN := Self:oOrdServ:GetSequen()
		D12->D12_PRDORI := Self:oMovPrdLot:GetPrdOri()
		D12->D12_PRODUT := Self:oMovPrdLot:GetProduto()
		D12->D12_LOTECT := Self:oMovPrdLot:GetLoteCtl()
		D12->D12_NUMLOT := Self:oMovPrdLot:GetNumLote()
		D12->D12_NUMSER := Self:oMovPrdLot:GetNumSer()
		D12->D12_CODVOL := Self:cCodVolume
		D12->D12_IDVOLU := Self:cIdVolume
		D12->D12_IDUNIT := Self:cIdUnitiz
		If Self:lHasUniDes
			D12->D12_UNIDES := Self:cUniDes
		EndIf
		D12->D12_ORIGEM := Self:oOrdServ:GetOrigem()
		D12->D12_DOC    := Self:oOrdServ:GetDocto()
		D12->D12_SDOC   := Self:oOrdServ:GetSerie() // Self:oOrdServ:GetSDoc()
		D12->D12_CLIFOR := Self:oOrdServ:GetCliFor()
		D12->D12_LOJA   := Self:oOrdServ:GetLoja()
		D12->D12_SERIE  := Self:oOrdServ:GetSerie()
		D12->D12_CARGA  := Self:oOrdServ:GetCarga()
		D12->D12_CODREC := Self:oOrdServ:GetCodRec()
		D12->D12_SEQCAR := Self:cSeqCarga
		// Muda o status do movimento para posterior analise da regra de convoca
		If lHasLibD12 .And. !Self:lEstAglu
			D12->D12_STATUS := "-"
		Else
			D12->D12_STATUS := Self:cStatus
		EndIf
		D12->D12_DTGERA := Self:dDtGeracao
		D12->D12_HRGERA := Self:cHrGeracao
		D12->D12_SEQPRI := Self:cSeqPrior
		D12->D12_PRIORI := Self:cPriori
		D12->D12_SERVIC := Self:oMovServic:GetServico()
		D12->D12_TAREFA := Self:oMovServic:GetTarefa()
		D12->D12_ORDTAR := Self:oMovServic:GetOrdem()
		D12->D12_LIBPED := Self:cLibPed
		D12->D12_ATIVID := Self:oMovTarefa:GetAtivid()
		D12->D12_ORDATI := Self:oMovTarefa:GetOrdem()
		D12->D12_RHFUNC := Self:oMovTarefa:GetFuncao()
		D12->D12_RECFIS := Self:oMovTarefa:GetTpRec()
		D12->D12_RADIOF := Self:cRadioF
		D12->D12_PRAUTO := Self:cPrAuto
		D12->D12_QTDLID := Self:nQtdLida
		D12->D12_QTDLI2 := Self:nQtdLida2
		D12->D12_TM     := "0"
		D12->D12_LOCORI := Self:oMovEndOri:GetArmazem()
		D12->D12_ENDORI := Self:oMovEndOri:GetEnder()
		D12->D12_LOCDES := Self:oMovEndDes:GetArmazem()
		D12->D12_ENDDES := Self:oMovEndDes:GetEnder()
		D12->D12_DATINI := Self:dDtInicio
		D12->D12_HORINI := Self:cHrInicio
		D12->D12_DATFIM := Self:dDtFinal
		D12->D12_HORFIM := Self:cHrFinal
		D12->D12_RECHUM := Self:cRecHumano
		D12->D12_ORIGEM := Self:oOrdServ:GetOrigem()
		D12->D12_ANOMAL := Self:cAnomalia
		D12->D12_MAPSEP := Self:cMapaSep
		D12->D12_MAPCON := Self:cMapaCon
		D12->D12_MAPTIP := Self:cMapaTipo
		D12->D12_RECCON := Self:cRecConf
		D12->D12_RECEMB := Self:cRecEmbal
		D12->D12_ENDCON := Self:cEndConf
		D12->D12_OCORRE := Self:cOcorre
		D12->D12_QTDERR := Self:nQtdErro
		D12->D12_MNTVOL := Self:cMntVol
		D12->D12_DISSEP := Self:cDisSep
		D12->D12_ORDMOV := Self:cOrdMov
		D12->D12_ATUEST := Self:cAtuEst
		D12->D12_BXESTO := Self:cBxEsto
		D12->D12_IMPETI := Self:oMovServic:GetSolImpE()
	EndIf
	// Quantidade
	D12->D12_QTDORI := nQtdOrig
	D12->D12_QTDOR2 := nQtdOrig2
	D12->D12_QTDMOV := nQtdMovto
	D12->D12_QTDMO2 := nQtdMovto2
	D12->D12_QTDLID := nQtdLida
	D12->D12_QTDLI2 := nQtdLida2
	D12->D12_NUMERO := Self:cNumOcor
	D12->D12_LOG    := Self:cLog
	D12->D12_AGLUTI := Self:cAgluti  
	WmsConout('RecordD12 - Valores QtdMov / QtdLid / QtdOri / Agluti ' + cValToChar(nQtdMovto) + ' / ' + cValToChar(nQtdLida) + ' / ' + cValToChar(nQtdOrig) + ' / ' + Self:cAgluti)
	D12->(MsUnLock())
	// Inclui movimento para analise de regra de convocação quando não for um
	// estorno de movimento aglutinado
	If lHasLibD12 .And. !Self:lEstAglu
		AAdd(Self:aRecD12, {Self:cStatus, D12->(Recno()),D12->D12_LOCORI, D12->D12_SERVIC," ",D12->D12_PRODUT})
	EndIf
	// Grava Recno da D12
	Self:nRecno := D12->(Recno())
	WmsConout('RecordD12 - cRecno apos inclusao/ateracao ' + cValToChar(Self:nRecno))
	// Ponto de Entrada WMSPOSDCF apos as gravacoes
	// Recebe o recno da D12 criada
	// Recebe o recno da DCF da D12 criada
	If ExistBlock('WMSPOSD12')
		WmsConout('RecordD12 WMSPOSD12')
		ExecBlock('WMSPOSD12',.F.,.F.,{Self:nRecno,Self:oOrdServ:GetRecno()})
	EndIf
	RestArea(aAreaD12)
	WmsConout('RecordD12 RestArea / Recno ' + aAreaD12[1] + ' / ' + cValToChar(aAreaD12[3]))

	IIF(oRelacMov != Nil, FreeObj(oRelacMov), Nil)

Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UpdateD12
Atualiza a movimentação D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD UpdateD12(lMsUnLock) CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local aAreaD12   := D12->(GetArea())

Default lMsUnLock := .T.
	WmsConout('UpdatedD12 - Inicio')
	Self:nQtdMovto2 := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdMovto,0,2)
	Self:nQtdLida2  := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdLida,0,2)
	Self:nQtdOrig2  := ConvUm(Self:oMovPrdLot:GetProduto(),Self:nQtdOrig,0,2)
	// Garante que a D12 está posicionada
	WmsConout('UpdateD12 - QtdMov / QtdLid / Recno ' + cValToChar(Self:nQtdMovto) + ' / ' + cValToChar(Self:nQtdLida) + ' / ' + cValToChar(Self:GetRecno()))
	D12->(dbGoTo(Self:GetRecno()))
	// Grava dados
	Reclock('D12', .F.)
	WmsConout('UpdateD12 - DCF / IdMovto / IdOper / Lote / cAgluti ' + Self:GetIdDCF() + ' / ' + Self:cIdMovto + ' / ' + Self:cIdOpera + ' / ' + Self:oMovPrdLot:GetLoteCtl() + ' / ' + Self:cAgluti)
	D12->D12_IDDCF  := Self:GetIdDCF()
	D12->D12_IDMOV  := Self:cIdMovto
	D12->D12_LOTECT := Self:oMovPrdLot:GetLoteCtl()
	D12->D12_NUMLOT := Self:oMovPrdLot:GetNumLote()
	D12->D12_NUMSER := Self:oMovPrdLot:GetNumSer()
	D12->D12_CODVOL := Self:cCodVolume
	D12->D12_IDVOLU := Self:cIdVolume
	D12->D12_IDUNIT := Self:cIdUnitiz
	If Self:lHasUniDes
		D12->D12_UNIDES := Self:cUniDes
	EndIf
	D12->D12_STATUS := Self:cStatus
	D12->D12_SEQPRI := Self:cSeqPrior
	D12->D12_PRIORI := Self:cPriori
	D12->D12_RHFUNC := Self:oMovTarefa:GetFuncao()
	D12->D12_RECFIS := Self:oMovTarefa:GetTpRec()
	D12->D12_RADIOF := Self:cRadioF
	D12->D12_QTDORI := Self:nQtdOrig
	D12->D12_QTDOR2 := Self:nQtdOrig2
	D12->D12_QTDMOV := Self:nQtdMovto
	D12->D12_QTDMO2 := Self:nQtdMovto2
	D12->D12_QTDLID := Self:nQtdLida
	D12->D12_QTDLI2 := Self:nQtdLida2
	D12->D12_LOCORI := Self:oMovEndOri:GetArmazem()
	D12->D12_ENDORI := Self:oMovEndOri:GetEnder()
	D12->D12_LOCDES := Self:oMovEndDes:GetArmazem()
	D12->D12_ENDDES := Self:oMovEndDes:GetEnder()
	D12->D12_DATINI := Self:dDtInicio
	D12->D12_HORINI := Self:cHrInicio
	D12->D12_DATFIM := Self:dDtFinal
	D12->D12_HORFIM := Self:cHrFinal
	D12->D12_RECHUM := Self:cRecHumano
	D12->D12_ANOMAL := Self:cAnomalia
	D12->D12_MAPSEP := Self:cMapaSep
	D12->D12_MAPCON := Self:cMapaCon
	D12->D12_MAPTIP := Self:cMapaTipo
	D12->D12_RECCON := Self:cRecConf
	D12->D12_RECEMB := Self:cRecEmbal
	D12->D12_ENDCON := Self:cEndConf
	D12->D12_OCORRE := Self:cOcorre
	D12->D12_QTDERR := Self:nQtdErro
	D12->D12_MNTVOL := Self:cMntVol
	D12->D12_DISSEP := Self:cDisSep
	D12->D12_ORDMOV := Self:cOrdMov
	D12->D12_ATUEST := Self:cAtuEst
	D12->D12_PRAUTO := Self:cPrAuto
	D12->D12_NUMERO := Self:cNumOcor
	D12->D12_IMPETI := Self:cSolImpEti
	D12->D12_AGLUTI := Self:cAgluti
	D12->D12_LOG    := Self:cLog
	D12->D12_DOC    := Self:oOrdServ:GetDocto()
	D12->D12_SDOC   := Self:oOrdServ:GetSerie() // Self:oOrdServ:GetSDoc()
	D12->D12_CLIFOR := Self:oOrdServ:GetCliFor()
	D12->D12_LOJA   := Self:oOrdServ:GetLoja()
	D12->D12_SERIE  := Self:oOrdServ:GetSerie()
	D12->D12_CARGA  := Self:oOrdServ:GetCarga()
	D12->D12_CODREC := Self:oOrdServ:GetCodRec()
	D12->D12_NUMSEQ := Self:oOrdServ:GetNumSeq()
	D12->D12_SEQCAR := Self:cSeqCarga
	D12->(dbCommit())
	If lMsUnLock
		D12->(MsUnLock())
	EndIf
	RestArea(aAreaD12)
	WmsConout('RecordD12 RestArea / Recno ' + aAreaD12[1] + ' / ' + cValToChar(aAreaD12[3]))
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} DeleteD12
Exclusão do registro D12
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD DeleteD12() CLASS WMSDTCMovimentosServicoArmazem
Local lRet     := .T.
Local aAreaD12 := D12->(GetArea())
	// Grava dados
	D12->(dbGoTo(Self:GetRecno()))
	If Reclock('D12', .F.)
		WmsConout('DeleteD12 - reclock ok ' + cValToChar(Self:GetRecno()))
	Else
		WmsConout('DeleteD12 - reclock não ok ' + cValToChar(Self:GetRecno()))
	EndIf		
	
	D12->(DbDelete())
	D12->(MsUnlock())

	//Temporário para verificar se registro foi excluído
	If Deleted()
		WmsConout('DeleteD12 - Registro excluído')
	Else
		WmsConout('DeleteD12 - Registro não excluído')
	EndIf

	RestArea(aAreaD12)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} IsUltAtiv
Verifica se é a ultima atividade
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD IsUltAtiv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cOrdMov $ "3|4"
//--------------------------------------------------
/*/{Protheus.doc} IsPriAtiv
Verifica se é a primeira atividade
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD IsPriAtiv() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cOrdMov $ "1|4"
//--------------------------------------------------
/*/{Protheus.doc} IsUpdEst
Verifica se atividades atualiza estoque
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD IsUpdEst() CLASS WMSDTCMovimentosServicoArmazem
Return Self:cAtuEst == "1"
//--------------------------------------------------

//--------------------------------------------------
/*/{Protheus.doc} MakeInput
Efetua uma entrada prevista
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD MakeInput() CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local aTamSX3   := {}
Local cAliasD14 := Nil
	// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
	If Self:DesNotUnit()
		Self:cUniDes := ""
		Self:cTipUni := ""
	Else
		// Caso não foi informado o unitizador destino, assume o mesmo que a origem, apenas se o armazém destino tbm for unitizado
		If Empty(Self:cUniDes) .And. WmsArmUnit(Self:oMovEndDes:GetArmazem())
			Self:cUniDes := Self:cIdUnitiz
		EndIf
	EndIf
	Self:oEstEnder:ClearData()
	If Self:IsMovUnit()
		cAliasD14 := GetNextAlias()
		BeginSql Alias cAliasD14
			SELECT D14.D14_CODUNI,
					D14.D14_PRDORI,
					D14.D14_PRODUT,
					D14.D14_LOTECT,
					D14.D14_NUMLOT,
					D14.D14_QTDEST
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D14.D14_LOCAL = %Exp:Self:oMovEndOri:GetArmazem()%
			AND D14.D14_ENDER = %Exp:Self:oMovEndOri:GetEnder()%
			AND D14.%NotDel%
		EndSql
		aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
		If (cAliasD14)->(!Eof())
			Do While lRet .And. (cAliasD14)->(!Eof())
				// Carrega dados para LoadData EstEnder
				Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
				Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
				Self:oEstEnder:oProdLote:SetArmazem(Self:oMovEndDes:GetArmazem()) // Armazem
				Self:oEstEnder:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)   // Produto Origem - Componente
				Self:oEstEnder:oProdLote:SetProduto((cAliasD14)->D14_PRODUT) // Produto Principal
				Self:oEstEnder:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oEstEnder:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oEstEnder:SetIdUnit(Self:cUniDes)
				Self:oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasD14)->D14_CODUNI,Self:cTipUni))
				// Atribui a quantidade do produto no unitizador
				Self:oEstEnder:SetQuant((cAliasD14)->D14_QTDEST)
				lRet := Self:oEstEnder:UpdSaldo('499',.F.,.T.,.F.,.F.,.F.)
				(cAliasD14)->(DbSkip())
			EndDo
		Else
			Self:cErro := WmsFmtMsg(STR0031,{{"[VAR01]",Self:cUniDes}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
			lRet := .F.
		EndIf
		(cAliasD14)->(DbCloseArea())
	Else
		// Carrega dados para LoadData EstEnder
		Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
		Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
		Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
		Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem - Componente
		Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto()) // Produto Principal
		Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
		Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		Self:oEstEnder:SetIdUnit(Self:cUniDes)
		Self:oEstEnder:SetTipUni(Self:cTipUni)
		Self:oEstEnder:SetQuant(Self:nQtdMovto)
		lRet := Self:oEstEnder:UpdSaldo('499',.F.,.T.,.F.,.F.,.F.)
		WmsConout('MakeInput ' + cValToChar(Self:nQtdMovto))
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} MakeOutput
Efetua uma saída prevista
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD MakeOutput() CLASS WMSDTCMovimentosServicoArmazem
Local lEmpPrev  := Self:oMovServic:ChkSepara()
Local lRet      := .T.
Local aTamSX3   := {}
Local cAliasD14 := Nil

	Self:oEstEnder:ClearData()
	If Self:IsMovUnit()
		cAliasD14 := GetNextAlias()
		BeginSql Alias cAliasD14
			SELECT D14.D14_CODUNI,
					D14.D14_PRDORI,
					D14.D14_PRODUT,
					D14.D14_LOTECT,
					D14.D14_NUMLOT,
					D14.D14_QTDEST
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D14.D14_LOCAL = %Exp:Self:oMovEndOri:GetArmazem()%
			AND D14.D14_ENDER = %Exp:Self:oMovEndOri:GetEnder()%
			AND D14.%NotDel%
		EndSql
		aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
		If (cAliasD14)->(!Eof())
			Do While lRet .And. (cAliasD14)->(!Eof())
				// Carrega dados para LoadData EstEnder
				Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
				Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
				Self:oEstEnder:oProdLote:SetArmazem(Self:oMovEndOri:GetArmazem()) // Armazem
				Self:oEstEnder:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)   // Produto Origem - Componente
				Self:oEstEnder:oProdLote:SetProduto((cAliasD14)->D14_PRODUT) // Produto Principal
				Self:oEstEnder:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT) // Lote do produto principal que deverá ser o mesmo no componentes
				Self:oEstEnder:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
				//Self:oEstEnder:SetTipUni((cAliasD14)->D14_CODUNI) // Registro já está na D14, não informar para não sobrepor
				Self:oEstEnder:SetQuant((cAliasD14)->D14_QTDEST)
				lRet := Self:oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev /*lEmpPrev*/)
				(cAliasD14)->(dbSkip())
			EndDo
		Else
			Self:cErro := WmsFmtMsg(STR0031,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
			lRet := .F.
		EndIf
		(cAliasD14)->(DbCloseArea())
	Else
		// Caso servico de separação gera quantidade empenho
		// Caso não seja separação gera quantidade saida prevista
		// Carrega dados para LoadData EstEndEr
		Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
		Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
		Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
		Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem - Componente
		Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto()) // Produto Principal
		Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
		Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
		//Self:oEstEnder:SetTipUni(Self:cTipUni) // Registro já está na D14, não informar para não sobrepor
		Self:oEstEnder:SetQuant(Self:nQtdMovto)
		lRet := Self:oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev /*lEmpPrev*/)
		WmsConout('MakeOutput ' + cValToChar(Self:nQtdMovto))
	EndIf
Return lRet

METHOD ChkMntVol(cTipoMnt) CLASS WMSDTCMovimentosServicoArmazem
Return (Self:cMntVol != "0" .And. Self:cMntVol == cTipoMnt)

METHOD ChkDisSep() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:cDisSep == "1")

METHOD ChkConfExp() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:oMovServic:ChkConfExp())

METHOD ChkSolImpE() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:cSolImpEti == "1" .Or. Empty(Self:cSolImpEti))
//--------------------------------------------------
/*/{Protheus.doc} ChkEndOri
//Valida se endereço origem não possui restrição para movimentação
@author Squad WMS Protheus
@since 27/06/2018
@version 1.0
@return lógico
@param lMovEst, Logical, Indica se desconta quantidade da movimentação da quantidade saida prevista, pois quantidade do movimento está inclusa.
@param lConMov, Logical, Inidca se Considera apenas o saldo atual do endereço, pois está efetuando efetivamente a movimentação de estoque
@param lConsSld, Logical, Inidca se Não efetua a consulta de capacidade do endereço, pois é feita em outro momento
@param lDesQtBlq, Logical, Inidca se desconsidera a quantidade bloqueada ao calcular saldo do produto
@type function
@version 1.0
/*/
//--------------------------------------------------
METHOD ChkEndOri(lConsMov,lMovEst,lConsSld,lDesQtBlq) CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local cAliasD14 := Nil
Local nSaldoPrd := 0
Local nSaldoPRE := 0
Local nSaldoPRS := 0
Default lConsMov := .F. // Desconta quantidade da movimentação da quantidade saida prevista, pois quantidade do movimento está inclusa.
Default lMovEst  := .F. // Considera apenas o saldo atual do endereço, pois está efetuando efetivamente a movimentação de estoque
Default lConsSld := .T. // Não efetua a consulta de capacidade do endereço, pois é feita em outro momento
Default lDesQtBlq := .F. //Inidca se desconsidera a quantidade bloqueada ao calcular saldo do produto
	If Self:oMovEndOri:LoadData(Nil,.T.)
		If Self:oMovEndOri:GetStatus() == "3" // Endereço bloqueado
			Self:cErro := WmsFmtMsg(STR0020,{{"[VAR01]",Self:oMovEndOri:GetEnder()}}) // O endereço origem [VAR01] está bloqueado.
			lRet := .F.
		ElseIf Self:oMovEndOri:GetStatus() == "5" // Endereço com bloqueio de saída
			Self:cErro := WmsFmtMsg(STR0021,{{"[VAR01]",Self:oMovEndOri:GetEnder()}}) // O endereço origem [VAR01] está com bloqueio de saída.
			lRet := .F.
		ElseIf Self:oMovEndOri:GetStatus() == "6" // Endereço com bloqueio de inventário
			Self:cErro := WmsFmtMsg(STR0022,{{"[VAR01]",Self:oMovEndOri:GetEnder()}}) // O endereço origem [VAR01] está com bloqueio de inventário.
			lRet := .F.
		ElseIf BlqInvent(Self:oMovPrdLot:GetProduto(),Self:oMovEndOri:GetArmazem())
			Self:cErro := WmsFmtMsg(STR0051,{{"[VAR01]",AllTrim(Self:oMovPrdLot:GetProduto())}})//"O produto [VAR01] está bloqueado para inventário nesta data, portando não pode ser movimentado."
			lRet := .F.
		EndIf
	EndIf
	// Somente executa as validações de saldo para os serviços que movimentam estoque:
	// Recebimento e Separação (normal e crossdocking), Transferência e Reabastecimento
	If lRet .And. lConsSld .And. Self:oMovServic:ChkMovEst()
		Self:oEstEnder:ClearData()
		If Self:IsMovUnit()
			cAliasD14 := GetNextAlias()
			BeginSql Alias cAliasD14
				SELECT D14.D14_LOCAL,
						D14.D14_CODUNI,
						D14.D14_PRDORI,
						D14.D14_PRODUT,
						D14.D14_LOTECT,
						D14.D14_NUMLOT,
						D14.D14_NUMSER,
						D14.D14_QTDEST,
						D14.D14_QTDEPR,
						D14.D14_QTDSPR,
						D14.D14_QTDEMP,
						D14.D14_QTDBLQ
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_LOCAL = %Exp:Self:oMovEndOri:GetArmazem()%
				AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
				AND D14.D14_ENDER = %Exp:Self:oMovEndOri:GetEnder()%
				AND D14.%NotDel%
			EndSql
			aTamSX3 := TamSx3("D14_QTDEST")
			TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
			TcSetField(cAliasD14,'D14_QTDEPR','N',aTamSX3[1],aTamSX3[2])
			TcSetField(cAliasD14,'D14_QTDSPR','N',aTamSX3[1],aTamSX3[2])
			TcSetField(cAliasD14,'D14_QTDEMP','N',aTamSX3[1],aTamSX3[2])
			TcSetField(cAliasD14,'D14_QTDBLQ','N',aTamSX3[1],aTamSX3[2])
			If (cAliasD14)->(!Eof())
				Do While lRet .And. (cAliasD14)->(!Eof())
					If lDesQtBlq
						nSaldoPrd := (cAliasD14)->D14_QTDEST - ( (cAliasD14)->D14_QTDEMP )
					Else
						nSaldoPrd := (cAliasD14)->D14_QTDEST - ( (cAliasD14)->D14_QTDEMP + (cAliasD14)->D14_QTDBLQ )
					EndIf
					nSaldoPRE := (cAliasD14)->D14_QTDEPR
					nSaldoPRS := (cAliasD14)->D14_QTDSPR
					// Utiliza o saldo descontando a saida prevista
					If (Iif(lMovEst,QtdComp(nSaldoPrd),QtdComp(nSaldoPrd - Iif(lConsMov,0,nSaldoPRS))) < QtdComp((cAliasD14)->D14_QTDEST))
						If QtdComp(nSaldoPRE) > 0 .Or. QtdComp(nSaldoPRS) > 0
							Self:cErro := WmsFmtMsg(STR0016,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetEnder()}})  // Existem atividades a executar que comprometem o saldo do produto [VAR01] no endereço [VAR02].
							Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('D12_QTDMOV',14))}})                   // Endereço possui saldo de [VAR01].
							Self:cErro += CRLF+WmsFmtMsg(STR0012,{{"[VAR01]",Transf(nSaldoPRE,PesqPictQt('D12_QTDMOV',14))}})                   // Entrada prevista de [VAR01].
							Self:cErro += CRLF+WmsFmtMsg(STR0015,{{"[VAR01]",Transf(nSaldoPRS,PesqPictQt('D12_QTDMOV',14))}})                   // Saída prevista de [VAR01].
						Else
							Self:cErro += WmsFmtMsg(STR0017,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetEnder()}})  // Saldo do produto [VAR01] no endereço [VAR02] insuficiente para movimentação.
							Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('D12_QTDMOV',14))}})                   // Endereço possui saldo de [VAR01].
						EndIf
						lRet := .F.
					EndIf
					// Analisa empenho do lote
					If lRet .And. Self:oMovServic:ChkTransf() .And. !(Self:oMovEndOri:GetArmazem() == Self:oMovEndDes:GetArmazem())
						If !Self:ChkEstPrd(lMovEst,lConsMov,(cAliasD14)->D14_LOCAL,(cAliasD14)->D14_PRODUT,(cAliasD14)->D14_LOTECTL,(cAliasD14)->D14_NUMLOT,(cAliasD14)->D14_QTDEST,lDesQtBlq)
							Self:cErro := WmsFmtMsg(STR0045,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetArmazem()},{"[VAR03]",Self:oMovEndOri:GetEnder()}})  // Existem reservas e/ou empenhos que comprometem o saldo do produto [VAR01] no armazém [VAR02] e endereço [VAR03].
							lRet := .F.
						EndIf
					EndIf
					(cAliasD14)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0031,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasD14)->(dbCloseArea())
		Else
			If lRet
				Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
				Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
				Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
				Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem
				Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
				Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
				Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
				Self:oEstEnder:oProdLote:SetNumSer(Self:oMovPrdLot:GetNumSer())
				Self:oEstEnder:SetIdUnit(Self:GetIdUnit())
				Self:oEstEnder:SetTipUni(Self:GetTipUni())
				If Self:oEstEnder:LoadData()
					If lDesQtBlq
						nSaldoPrd := Self:oEstEnder:GetQtdEst() - ( Self:oEstEnder:GetQtdEmp() )
					Else
						nSaldoPrd := Self:oEstEnder:GetQtdEst() - ( Self:oEstEnder:GetQtdEmp() + Self:oEstEnder:GetQtdBlq() )
					EndIf
					nSaldoPRE := Self:oEstEnder:GetQtdEPr()
					nSaldoPRS := Self:oEstEnder:GetQtdSPr()
					// Utiliza o saldo descontando a saida prevista
					If (Iif(lMovEst,QtdComp(nSaldoPrd),QtdComp(nSaldoPrd - Iif(lConsMov,(nSaldoPRS-Self:nQuant),nSaldoPRS))) < QtdComp(Self:nQuant))
						If QtdComp(nSaldoPRE) > 0 .Or. QtdComp(nSaldoPRS) > 0
							Self:cErro := WmsFmtMsg(STR0016,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetEnder()}})  // Existem atividades a executar que comprometem o saldo do produto [VAR01] no endereço [VAR02].
							Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('D12_QTDMOV',14))}})                   // Endereço possui saldo de [VAR01].
							Self:cErro += CRLF+WmsFmtMsg(STR0012,{{"[VAR01]",Transf(nSaldoPRE,PesqPictQt('D12_QTDMOV',14))}})                   // Entrada prevista de [VAR01].
							Self:cErro += CRLF+WmsFmtMsg(STR0015,{{"[VAR01]",Transf(nSaldoPRS,PesqPictQt('D12_QTDMOV',14))}})                   // Saída prevista de [VAR01].
						Else
							Self:cErro := WmsFmtMsg(STR0017,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetEnder()}})  // Saldo do produto [VAR01] no endereço [VAR02] insuficiente para movimentação.
							Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoPrd,PesqPictQt('D12_QTDMOV',14))}})                   // Endereço possui saldo de [VAR01].
						EndIf
						lRet := .F.
					EndIf
				Else
					Self:cErro := STR0038  //Não foi encontrado o saldo em estoque com as informações: 
					Self:cErro += CRLF+WmsFmtMsg(STR0039,{{"[VAR01]",Self:oMovEndOri:GetEnder()}})   //Endereço: [VAR01]
					Self:cErro += CRLF+WmsFmtMsg(STR0040,{{"[VAR01]",Self:oMovPrdLot:GetProduto()}}) //Produto: [VAR01]
					Self:cErro += CRLF+WmsFmtMsg(STR0041,{{"[VAR01]",Self:oMovPrdLot:GetLoteCtl()}}) //Lote: [VAR01]
					Self:cErro += CRLF+WmsFmtMsg(STR0042,{{"[VAR01]",Self:oMovPrdLot:GetNumLote()}}) //Sub-lote: [VAR01]
					Self:cErro += CRLF+WmsFmtMsg(STR0043,{{"[VAR01]",Self:GetIdUnit()}})             //Unitizador: [VAR01]
					lRet := .F.
				EndIf
			EndIf
			// Analisa empenho do lote
			If lRet .And. Self:oMovServic:ChkTransf() .And. !(Self:oMovEndOri:GetArmazem() == Self:oMovEndDes:GetArmazem()) .AND. !(!Empty(Self:oordserv:GetIdOrig()) .AND. Self:oMovEndOri:GetTipoEst() = 7)
				If !Self:ChkEstPrd(lMovEst,lConsMov,Self:oMovEndOri:GetArmazem(),Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote(),Self:nQuant,lDesQtBlq)
					Self:cErro := WmsFmtMsg(STR0045,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndOri:GetArmazem()},{"[VAR03]",Self:oMovEndOri:GetEnder()}})  // Existem reservas e/ou empenhos que comprometem o saldo do produto [VAR01] no armazém [VAR02] e endereço [VAR03].
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

METHOD ChkEndDes(lConsMov,lConsCap,cTipReab) CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local lPercOcup  := .F.
Local aRet       := {}
Local oEstFis    := WMSDTCEstruturaFisica():New()
Local oProdZona  := Nil
Local oTrfUnitiz := Nil
Local oEndUnitiz := Nil
Local cTipEstVld := "3|5|7|8"
Local cAliasD14  := Nil
Local cMsgErrEst := ''
Local nQtdErrEst := 0
Local nSaldoPrd  := 0
Local nSaldoPRF  := 0
Local nSaldoD14  := 0
Local nSaldoRF   := 0
Local nCapEnder  := 0
Local nPesoEnd   := 0
Local nVolEnd    := 0
Local nPesoItem  := 0
Local nVolItem   := 0
Local lWMSCAPEN  := ExistBlock('WMSCAPEN')
Local lConsPick	 := SuperGetMV("MV_WMSZNPK", .F., .F.) //--Permiti considerar a estrutura de picking nas validacoes do endereco
Default lConsMov := .F.
Default lConsCap := .T.
Default cTipReab := "D"

	If Self:oMovEndDes:LoadData(Nil,.T.)
		If Self:oMovEndDes:GetStatus() == "3" // Endereço bloqueado
			Self:cErro := WmsFmtMsg(STR0005,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço destino [VAR01] está bloqueado.
			lRet := .F.
		EndIf
		If Self:oMovEndDes:GetStatus() == "4" // Endereço com bloqueio de entrada
			Self:cErro := WmsFmtMsg(STR0023,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço destino [VAR01] está com bloqueio de entrada.
			lRet := .F.
		EndIf
		If Self:oMovEndDes:GetStatus() == "6" // Endereço com bloqueio de inventário
			Self:cErro := WmsFmtMsg(STR0024,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço destino [VAR01] está com bloqueio de inventário.
			lRet := .F.
		EndIf
	Else
		Self:cErro := Self:oMovEndDes:GetErro() // Erro do LoadData
		lRet := .F.
	EndIf
	If lRet
		oEstFis:SetEstFis(Self:oMovEndDes:GetEstFis())
		If !oEstFis:LoadData()
			Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:oMovEndDes:GetEstFis()}}) // Estrutura física [VAR01] não cadastrada. (DC8)
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. !Empty(Self:oMovEndDes:GetProduto())
		If !Self:IsMovUnit()
			If !(Self:oMovEndDes:GetProduto() == Self:oMovPrdLot:GetProduto())
				Self:cErro := WmsFmtMsg(STR0046,{{"[VAR01]",Self:oMovEndDes:GetEnder()},{"[VAR02]",Self:oMovEndDes:GetProduto()}}) // Endereço [VAR01] exclusivo para o produto [VAR02]!
				lRet := .F.
			EndIf
		Else
			cAliasD14 := GetNextAlias()
			BeginSql Alias cAliasD14
				SELECT 1
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
				AND D14.D14_LOCAL  = %Exp:Self:oMovEndOri:GetArmazem()%
				AND D14.D14_ENDER  = %Exp:Self:oMovEndOri:GetEnder()%
				AND D14.D14_PRODUT <> %Exp:Self:oMovEndDes:GetProduto()%
				AND D14.%NotDel%
			EndSql
			If (cAliasD14)->(!Eof())
				Self:cErro := WmsFmtMsg(STR0046,{{"[VAR01]",Self:oMovEndDes:GetEnder()},{"[VAR02]",Self:oMovEndDes:GetProduto()}}) // Endereço [VAR01] exclusivo para o produto [VAR02]!.
				lRet := .F.
			EndIf
			(cAliasD14)->(dbCloseArea())
		EndIf
	EndIf
	
	If lRet 
		IF !Self:IsMovUnit() //Se não for unitizado, verifica se a estrutura do endereço destino está na seq. abastecimento do item
			cAliasD14 := GetNextAlias()
			BeginSQL Alias cAliasD14			
				SELECT 1 FROM %Table:DC3% DC3
				WHERE DC3.DC3_FILIAL = %xFilial:DC3%
				AND DC3.DC3_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
				AND DC3.DC3_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
				AND DC3.DC3_TPESTR = %Exp:Self:oMovEndDes:GetEstFis()%
				AND DC3.%NotDel%
			EndSQL

			If (cAliasD14)->(Eof())
				Self:cErro := WmsFmtMsg(STR0050,{{"[VAR01]",Self:oMovEndOri:GetProduto()},{"[VAR02]", Self:oMovEndDes:GetEstFis()}}) // Produto [VAR01] não possui sequência de abastecimento para a estrutura do endereço informado ([VAR02]).
				lRet := .F.
			EndIf

			(cAliasD14)->(dbCloseArea())

		Else //Se for unitizado, verifica se a estrutura do endereço destino está na seq. abastecimento dos itens do unitizador
			cAliasD14 := GetNextAlias()			
			BeginSQL Alias cAliasD14			
				SELECT D0S_CODPRO FROM %Table:D0S% D0S
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:Self:cIdUnitiz%
				AND D0S.%NotDel%
				AND NOT EXISTS (SELECT 1 FROM %Table:DC3% DC3
				WHERE DC3.DC3_FILIAL = %xFilial:DC3%
				AND DC3.DC3_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
				AND DC3.DC3_CODPRO = D0S_CODPRO
				AND DC3.DC3_TPESTR = %Exp:Self:oMovEndDes:GetEstFis()%
				AND DC3.%NotDel%)			
			EndSQL

 			Do While !(cAliasD14)->(Eof())
				nQtdErrEst += 1
				If nQtdErrEst <= 3			
					cMsgErrEst += AllTrim((cAliasD14)->D0S_CODPRO) + ', '
				Else
					Exit
				EndIf			
				
				(cAliasD14)->(dbSkip())
			EndDo
		
			If nQtdErrEst > 0
				cMsgErrEst := Substr(cMsgErrEst, 1, Len(cMsgErrEst)-2)
			EndIf
			If nQtdErrEst > 3
				cMsgErrEst += STR0048 // e outros
			EndIf
			
			If nQtdErrEst > 0
				Self:cErro := WmsFmtMsg(STR0047 + cMsgErrEst + STR0049,{{"[VAR01]",Self:oMovEndDes:GetEstFis()}}) // Produto(s) A, B, C e outros não possui(em) sequência de abastecimento para a estrutura do endereço informado ([VAR01]).
				lRet := .F.
			EndIf

			(cAliasD14)->(dbCloseArea())
		EndIf
	EndIF

	// Se não deve consultar a capacidade, retorna neste momento
	If lConsCap 
		// Valida se tipo de estrutura é picking e reabastecimento ou enderecamento de saldo menor que uma embalagem
		If lRet .And. oEstFis:GetTipoEst() == '2' .And. !lConsPick .And. ((Self:oMovServic:ChkReabast() .And. cTipReab == 'D') .Or. Self:oMovServic:ChkArmaz())
			cTipEstVld := "2|3|5|7|8"
		EndIf
		If lRet .And. (!(oEstFis:GetTipoEst() $ cTipEstVld) .Or. IsInCallStack('WMSA332AEN'))
			If !Self:IsMovUnit()
				// Verifica Sequência de Abastecimento
				Self:oMovSeqAbt:SetProduto(Self:oMovPrdLot:GetProduto())
				Self:oMovSeqAbt:SetArmazem(Self:oMovEndDes:GetArmazem())
				Self:oMovSeqAbt:SetEstFis(Self:oMovEndDes:GetEstFis())
				If !Self:oMovSeqAbt:LoadData(2)
					Self:cErro := WmsFmtMsg(STR0007,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndDes:GetArmazem()},{"[VAR03]",Self:oMovEndDes:GetEstFis()}}) // Produto [VAR01] não possui sequência de abastecimento para Armazém/Estrutura [VAR02]/[VAR03]. (DC3)
					lRet := .F.
				EndIf
				If lRet
					// Verifica Zona Armazenagem Alternativa
					If Self:oMovPrdLot:GetCodZona() <> Self:oMovEndDes:GetCodZona()
						oProdZona := WMSDTCProdutoZona():New()
						oProdZona:SetProduto(Self:oMovPrdLot:GetProduto())
						oProdZona:SetCodZona(Self:oMovEndDes:GetCodZona())
						If !oProdZona:LoadData()
							Self:cErro := WmsFmtMsg(STR0008,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndDes:GetCodZona()}}) // Produto [VAR01] não está cadastrado para a zona armazenagem [VAR02]. (SB5,DCH)
							lRet := .F.
						EndIf
					EndIf
				EndIf
				If lRet
					If !Empty(Self:cUniDes)
						oTrfUnitiz := WMSBCCTransferencia():New()
						// Faz uma referência dos objetos para a nova classe (Temporário)
						oTrfUnitiz:oMovPrdLot := Self:oMovPrdLot
						oTrfUnitiz:oMovEndOri := Self:oMovEndOri
						oTrfUnitiz:oMovEndDes := Self:oMovEndDes
						oTrfUnitiz:oMovSeqAbt := Self:oMovSeqAbt
						oTrfUnitiz:SetUniDes(Self:cUniDes)
						oTrfUnitiz:SetTipUni(Self:cTipUni)
						oTrfUnitiz:SetQuant(Self:nQuant)
						If !(lRet := oTrfUnitiz:CanUnitPar(lConsMov))
							Self:cErro := STR0033 //"O endereço não pode receber o saldo do movimento. Motivo:"
							Self:cErro += CRLF + oTrfUnitiz:GetErro()
						EndIf
						// Retira as referências dos objetos
						oTrfUnitiz:oMovPrdLot := Nil
						oTrfUnitiz:oMovEndOri := Nil
						oTrfUnitiz:oMovEndDes := Nil
						oTrfUnitiz:oMovSeqAbt := Nil
						oTrfUnitiz:Destroy()
					Else
						// Se o destino for armazém unitizado, realiza as validações de capacidade (peso e volume)
						If Self:oMovEndDes:IsArmzUnit()
							// Calcula o peso e volume dos itens contidos no endereço
							aRet     := WmsCalcEnd(Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEnder())
							nPesoEnd := aRet[1]
							nVolEnd  := aRet[2]
							// Calcula o peso e volume dos itens que estão sendo movimentados
							If !lConsMov
								aRet      := WmsCalcIt(Self:oMovPrdLot:GetProduto(),Self:nQuant)
								nPesoItem := aRet[1]
								nVolItem  := aRet[2]
							EndIf
							// Valida peso máximo do endereço
							If QtdComp(nPesoEnd + nPesoItem) > QtdComp(Self:oMovEndDes:GetCapacid())
								Self:cErro := STR0036 // "Estouro do peso máximo suportado do endereço."
								lRet := .F.
							EndIf
							// Valida volume máximo do endereço
							If lRet .And. QtdComp(nVolEnd + nVolItem) > QtdComp(Self:oMovEndDes:GetCubagem())
								Self:cErro := STR0037 // "Estouro do volume máximo suportado do endereço."
								lRet := .F.
							EndIf
						EndIf
						// Verifica se o endereço utiliza percentual de ocupação
						If lRet
							lPercOcup := WmsChkDCP(Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEnder(),Self:oMovEndDes:GetEstFis(),Self:oMovSeqAbt:GetCodNor(),Self:oMovPrdLot:GetProduto())
							Self:oEstEnder:ClearData()
							Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
							Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
							Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
							Self:oEstEnder:oProdLote:SetPrdOri("")
							Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
							Self:oEstEnder:oProdLote:SetNumSer(Self:oMovPrdLot:GetNumSer())
							// Saldo do produto
							nSaldoPrd := Self:oEstEnder:ConsultSld(.F.,.F.,.F.,.F.)
							// Saldo Previsto Entrada
							nSaldoPRF := Self:oEstEnder:ConsultSld(.T.,.F.,.F.,.F.) - nSaldoPrd
							// Saldo produto/lote/sublote
							Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdlot:GetLoteCtl())
							Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
							nSaldoLT  := Self:oEstEnder:ConsultSld(.T.,.F.,.F.,.F.)
							If lPercOcup
								nSaldoD14 := nSaldoPrd
								nSaldoRF  := nSaldoPRF
							Else
								Self:oEstEnder:oProdLote:SetPrdOri("")
								Self:oEstEnder:oProdLote:SetProduto("")
								Self:oEstEnder:oProdLote:SetLoteCtl("")
								Self:oEstEnder:oProdLote:SetNumLote("")
								// Saldo do endereco
								nSaldoD14 := Self:oEstEnder:ConsultSld(.F.,.F.,.F.,.F.)
								// Saldo Previsto entrada no Endereco
								nSaldoRF  := Self:oEstEnder:ConsultSld(.T.,.F.,.F.,.F.) - nSaldoD14
							EndIf
							//Reabastecimentos devem desconsiderar a capacidade do endereço, pois são gerados conforme tipo de reposição (completar ou norma) pela classe de abastecimento
							If !Self:oMovServic:ChkReabast()
								nCapEnder := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis(),/*cDesUni*/,.T.,Self:oMovEndDes:GetEnder()) // Considerar a qtd pelo nr de unitizadores

								//Ponto de entrada para manipular a capacidade do endereço destino
								If lWMSCAPEN
									nCapNewEnd := ExecBlock('WMSCAPEN',.F.,.F.,{Self:oMovPrdLot,Self:oMovEndOri,Self:oMovEndDes,nCapEnder})
									If ValType(nCapNewEnd) == "N"
										nCapEnder := nCapNewEnd
									EndIf
								Endif

								// Deve verificar se a quantidade a transferir não ultrapassa a capacidade do endereço
								If QtdComp(nSaldoD14 + IIf(lConsMov,(nSaldoRF - Self:nQuant),nSaldoRF) + Self:nQuant) > QtdComp(nCapEnder)
									Self:cErro := WmsFmtMsg(STR0009,{{"[VAR01]",Transf(Self:nQuant,PesqPictQt('D12_QTDMOV',14))},{"[VAR02]",Self:oMovEndDes:GetEnder()}}) // Movimentação de [VAR01] para o endereço [VAR02] excedendo a capacidade de armazenagem.
									Self:cErro += CRLF+WmsFmtMsg(STR0010,{{"[VAR01]",Transf(nCapEnder,PesqPictQt('D12_QTDMOV',14))}})                                     // Capacidade total do endereço de [VAR01].
									If nSaldoD14 > 0
										Self:cErro += CRLF+WmsFmtMsg(STR0011,{{"[VAR01]",Transf(nSaldoD14,PesqPictQt('D12_QTDMOV',14))}}) // Endereço possui saldo de [VAR01].
									EndIf
									If nSaldoRF > 0
										Self:cErro += CRLF+WmsFmtMsg(STR0012,{{"[VAR01]",Transf(nSaldoRF,PesqPictQt('D12_QTDMOV',14))}})  // Entrada prevista de [VAR01].
									EndIf
									lRet := .F.
								EndIf
							EndIf
						EndIf
	
						// Se não compartilha endereço, deve verificar se o endereço está em uso por outro produto
						If lRet .And. Self:oMovSeqAbt:GetTipoEnd() != "4"
							If QtdComp(nSaldoPrd + nSaldoPRF) != QtdComp(nSaldoD14 + nSaldoRF)
								Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço [VAR01] em uso por outro produto e tipo de endereçamento não permitir misturar produtos (DC3).
								lRet := .F.
							EndIf
						EndIf
						// Se não compartilha endereço e não endereça produtos de mesmo lote,
						// deve verificar se o endereço está em uso por outro lote
						If lRet .And. Self:oMovSeqAbt:GetTipoEnd() == '3'
							If nSaldoLT != (nSaldoD14 + nSaldoRF) // A consulta de saldo por lote não está sendo feita separadamente, por isso não precisa somar RF
								Self:cErro := WmsFmtMsg(STR0014,{{"[VAR01]",Self:oMovEndDes:GetEnder()}}) // Endereço [VAR01] em uso por outro lote e tipo de endereçamento não permite misturar lotes (DC3).
								lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				// Se for validação de movimentação unitizada
				// Cria instância da classe de endereçamento unitizado
				oEndUnitiz := WMSBCCEnderecamentoUnitizado():New()
				// Atribui os dados mínimos para execução da validação
				// Faz uma referência dos objetos para a nova classe (Temporário)
				oEndUnitiz:oMovEndOri := Self:oMovEndOri
				oEndUnitiz:oMovEndDes := Self:oMovEndDes
				oEndUnitiz:oMovSeqAbt := Self:oMovSeqAbt
				oEndUnitiz:SetIdUnit(Iif(Empty(Self:cUniDes),Self:cIdUnitiz,Self:cUniDes))
				oEndUnitiz:SetTipUni(Self:cTipUni)
				// Verifica se o unitizador pode ser armazenado no endereço
				If !(lRet := oEndUnitiz:UnitCanEnd(lConsMov))
					Self:cErro := STR0033 //"O endereço não pode receber o saldo do movimento. Motivo:"
					Self:cErro += CRLF + oEndUnitiz:GetErro()
				EndIf
				// Retira as referências dos objetos
				oEndUnitiz:oMovEndOri := Nil
				oEndUnitiz:oMovEndDes := Nil
				oEndUnitiz:oMovSeqAbt := Nil
				FreeObj(oEndUnitiz)
			EndIf
		EndIf
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} ReverseAgl
Estorno de movimentação aglutinada
@author alexsander.correa
@since 13/07/2015
@version 1.0
@return lógico
@param oRelacMov, object, relacionamento do movimento de distribuição
@param lTrocaLote, logical, identifica se é um processo de troca de lote
@type function
/*/
//--------------------------------------------------
METHOD ReverseAgl(oRelacMov,lTrocaLote) CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local oMovEstEnd := Nil
Local oOrdSerOri := Nil
Local oOrdSerAux := Nil
Local cAliasQry  := Nil
Local cIdDCFEst  := Self:GetIdDCF()
Local cIdMovEst  := Self:GetIdMovto()
Local cIdOpeEst  := Self:GetIdOpera()
Local cNextIdMov := ""

Default lTrocaLote := .F.
	// Ajusta o movimento origem descontando a quantidade a ser estornada
	Self:nQtdOrig  -= oRelacMov:GetQuant()
	Self:nQtdMovto -= oRelacMov:GetQuant()
	If Self:nQtdLida > 0
		Self:nQtdLida  -= oRelacMov:GetQuant()
	EndIf
	// Se está estornando a própria OS aglutinadora, deve atualizar o movimento
	// com a próxima OS aglutinada para esta passar a ser a a OS aglutinadora
	If oRelacMov:GetIdDCF() == cIdDCFEst
		oOrdSerOri := Self:oOrdServ
		oOrdSerAux := WMSDTCOrdemServico():New()
		Self:oOrdServ := oOrdSerAux
		Self:oOrdServ:SetIdDCF(Self:GetNextOri(cIdDCFEst,cIdMovEst,cIdOpeEst))
		Self:oOrdServ:LoadData()
		lRet := Self:AtuNextOri(cIdDCFEst,cIdMovEst,cIdOpeEst,Self:oOrdServ:GetIdDCF())
	EndIf
	//Remove DCR, pois será criada uma nova DCR para a quantidade estornada
	If lRet
		lRet := oRelacMov:DeleteDCR()
	EndIf
	// Atualiza movimento origem
	If lRet
		Self:cAgluti := Iif(Self:HasAgluAti(),"1","2")
		// Se virou um movimento não aglutinado, verifica se existem outros movimentos
		// que não estavam originalmente aglutinados para normalizar o mesmo IDMOVTO
		If Self:cAgluti == "2" .And. Self:cStatus != "1"
			cNextIdMov := Self:GetNextMov()
			If !Empty(cNextIdMov)
				lRet := Self:AtuNextMov(cNextIdMov)
				// Deve obrigatoriamente ficar depois da atualização da DCR - Usa no SELECT
				Self:cIdMovto := cNextIdMov
			EndIf
		EndIf
		If lRet
			Self:UpdateD12()
		EndIf
	EndIf
	// Restaura a referencia original
	If oOrdSerOri != Nil
		Self:oOrdServ := oOrdSerOri
	EndIf
	// Somente recria um novo movimento, caso se tratar de um processo de troca de lote ou se a movimentação original estava executada
	If lRet .And. (lTrocaLote .Or. Self:cStatus == "1")
		// Cria novo movimento considerando com base no origem
		// Contendo as informações do movimentos aglutinado que será
		// Estornado
		// Atribui ordem de serviço
		If oRelacMov:GetIdDCF() <> Self:oOrdServ:GetIdDCF()
			Self:oOrdServ:SetIdDCF(oRelacMov:GetIdDCF())
			Self:oOrdServ:LoadData()
		EndIf
		// Atualiza a aquantidade para o novo movimento gerado
		Self:nQtdOrig   := oRelacMov:GetQuant()
		Self:nQtdMovto  := oRelacMov:GetQuant()
		Self:nQtdLida   := oRelacMov:GetQuant()
		Self:cAgluti    := "1"
		Self:lEstAglu   := .T.
		// Grava novo movimento
		If !Self:RecordD12()
			lRet := .F.
		EndIf
	EndIf

	// Quando o estorno é de um movimento aglutinado deverá ser criado uma nova
	// movimentação de estoque com a quantidade a ser estornada, e a movimentação
	// original deverá ter a quantidade estornada subtraída.
	If lRet .And. Self:cStatus == "1" .And. Self:IsUpdEst()
		oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D13.R_E_C_N_O_ RECNOD13
			FROM %Table:D13% D13
			WHERE D13.D13_FILIAL = %xFilial:D13%
			AND D13.D13_IDDCF = %Exp:cIdDCFEst%
			AND D13.D13_IDMOV = %Exp:cIdMovEst%
			AND D13.D13_IDOPER = %Exp:cIdOpeEst%
			AND D13.%NotDel%
		EndSql
		// Subtrai quantidade cortada do DCR
		Do While (cAliasQry)->(!Eof())
			If oMovEstEnd:GoToD13((cAliasQry)->RECNOD13)
				oMovEstEnd:SetQtdEst(oMovEstEnd:nQtdEst - oRelacMov:GetQuant())
				// Se encontrou uma OS para ser a nova OS aglutinadora
				If oOrdSerAux != Nil
					oMovEstEnd:SetDocto(oOrdSerAux:GetDocto())
					oMovEstEnd:SetSerie(oOrdSerAux:GetSerie())
					oMovEstEnd:SetCliFor(oOrdSerAux:GetCliFor())
					oMovEstEnd:SetLoja(oOrdSerAux:GetLoja())
					oMovEstEnd:SetNumSeq(oOrdSerAux:GetNumSeq())
					oMovEstEnd:SetIdDCF(oOrdSerAux:GetIdDCF())
				EndIf
				oMovEstEnd:UpdateD13()
				// Cria novo D13 com o restante da quantidade para posterior convocacao pelo radio frequencia.
				oMovEstEnd:AssignD12(Self)
				oMovEstEnd:SetQtdEst(oRelacMov:GetQuant())
				oMovEstEnd:RecordD13()
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

METHOD VldEndInv() CLASS WMSDTCMovimentosServicoArmazem
Local lRet := .T.
Local oEndAux := WMSDTCEndereco():New()
	If Self:oMovServic:GetTipo() == "1" // Movimento de entrada
		// Seta o armazem destino do inventario
		Self:SetArmInv(Self:oMovEndDes:GetArmazem())
		oEndAux:SetArmazem(Self:oMovEndDes:GetArmazem())

	ElseIf Self:oMovServic:GetTipo() $ "2|3" // Movimento de saida/interno
		// Seta o armazem origem do inventario
		Self:SetArmInv(Self:oMovEndOri:GetArmazem())
		oEndAux:SetArmazem(Self:oMovEndOri:GetArmazem())
	EndIf
	oEndAux:SetEnder(Self:GetEndInv())
	If oEndAux:LoadData()
		If oEndAux:GetStatus() == "6"
			Self:cErro := WmsFmtMsg(STR0025,{{"[VAR01]",cEndereco}})// Endereço [VAR01] está bloqueado para inventário.
			lRet := .F.
		EndIf
	Else
		Self:cErro := oEndAux:GetErro()
		lRet := .F.
	EndIf
	If !lRet .And. Self:oMovServic:GetTipo() == "3" .And. Self:oMovEndOri:GetArmazem() != Self:oMovEndDes:GetArmazem()
		// Seta o armazem destino do inventario
		Self:SetArmInv(Self:oMovEndDes:GetArmazem())
		oEndAux:SetArmazem(Self:oMovEndDes:GetArmazem())
		oEndAux:SetEnder(Self:GetEndInv())
		If oEndAux:LoadData()
			If oEndAux:GetStatus() == "6"
				Self:cErro := WmsFmtMsg(STR0025,{{"[VAR01]",cEndereco}}) // Endereço [VAR01] está bloqueado para inventário.
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		Else
			Self:cErro := oEndAux:GetErro()
			lRet := .F.
		EndIf
	EndIf
Return lRet

METHOD HasAgluAti() CLASS WMSDTCMovimentosServicoArmazem
Local aAreaDCR  := GetArea()
Local lRet      := .F.
Local cAliasDCR := GetNextAlias()
	BeginSql Alias cAliasDCR
		SELECT COUNT(DCR.DCR_IDDCF) NRO_COUNT
		FROM %Table:DCR% DCR
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDORI = %Exp:Self:GetIdDCF()%
		AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
		AND DCR.DCR_IDOPER = %Exp:Self:cIdOpera%
		AND DCR.%NotDel%
	EndSql
	TcSetField(cAliasDCR,'NRO_COUNT','N',5,0)
	If (cAliasDCR)->(!Eof())
		lRet := ((cAliasDCR)->NRO_COUNT > 1)
	EndIf
	(cAliasDCR)->(dbCloseArea())
	RestArea(aAreaDCR)
Return lRet
/*----------------------------------------------------------------------
---ChkEndD0F
---Método utilizado para verificar se o endereço destino está definido
---felipe.m 22/04/2016
----------------------------------------------------------------------*/
METHOD ChkEndD0F() CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local aAreaD0F   := D0F->(GetArea())
Local cAliasD0F  := GetNextAlias()
	// Busca as informações do documento de montagem/desmontagem
	BeginSql Alias cAliasD0F
		SELECT D0F.D0F_ENDER
		FROM %Table:SD1% SD1
		INNER JOIN %Table:D06% D06
		ON D06.D06_FILIAL = %xFilial:D06%
		AND D06.D06_CODDIS = SD1.D1_CODDIS
		AND D06.%NotDel%
		INNER JOIN %Table:D0F% D0F
		ON D0F.D0F_FILIAL = %xFilial:D0F%
		AND D0F.D0F_CODDIS = D06.D06_CODDIS
		AND D0F.D0F_DOC = SD1.D1_DOC
		AND D0F.D0F_SERIE = SD1.D1_SERIE
		AND D0F.D0F_FORNEC = SD1.D1_FORNECE
		AND D0F.D0F_LOJA = SD1.D1_LOJA
		AND D0F.D0F_PRODUT = SD1.D1_COD
		AND D0F.D0F_ITEM = SD1.D1_ITEM
		AND D0F.D0F_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
		AND D0F.D0F_ENDER = %Exp:Self:oMovEndDes:GetEnder()%
		AND D0F.%NotDel%
		WHERE SD1.D1_FILIAL = %xFilial:SD1%
		AND SD1.D1_NUMSEQ = %Exp:Self:oOrdServ:GetNumSeq()%
		AND SD1.%NotDel%
		ORDER BY D0F.D0F_ENDER
	EndSql
	lRet := !(cAliasD0F)->(!Eof())
	(cAliasD0F)->(dbCloseArea())
	RestArea(aAreaD0F)
Return lRet
//----------------------------------------------------------------------
METHOD GetNextOri(cIdDCF,cIdMovto,cIdOpera) CLASS WMSDTCMovimentosServicoArmazem
Local cNextOri   := ""
Local cAliasDCR  := GetNextAlias()
	BeginSql Alias cAliasDCR
		SELECT MIN(DCR.DCR_IDDCF) DCR_IDDCF
		FROM %Table:DCR% DCR
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDORI = %Exp:cIdDCF%
		AND DCR.DCR_IDMOV = %Exp:cIdMovto%
		AND DCR.DCR_IDOPER = %Exp:cIdOpera%
		AND DCR.DCR_IDDCF <> %Exp:cIdDCF%
		AND DCR.%NotDel%
	EndSql
	If (cAliasDCR)->(!Eof())
		cNextOri := (cAliasDCR)->DCR_IDDCF
	EndIf
	(cAliasDCR)->(dbCloseArea())
	If Empty(cNextOri)
		cNextOri := cIdDCF
	EndIf
Return cNextOri
//----------------------------------------------------------------------
METHOD AtuNextOri(cIdDCF,cIdMovto,cIdOpera,cNextOri) CLASS WMSDTCMovimentosServicoArmazem
Local lRet   := .T.
Local cQuery := ""
	cQuery := "UPDATE "+RetSqlName("DCR")
	cQuery +=   " SET DCR_IDORI  = '"+cNextOri+"'"
	cQuery += " WHERE DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=   " AND DCR_IDORI  = '"+cIdDCF+"'"
	cQuery +=   " AND DCR_IDMOV  = '"+cIdMovto+"'"
	cQuery +=   " AND DCR_IDOPER = '"+cIdOpera+"'"
	cQuery +=   " AND DCR_IDDCF <> '"+cIdDCF+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0035 // "Problema ao atualizar o ID origem para os relacionamentos do movimento."
	EndIf
Return lRet

//----------------------------------------------------------------------
// Busca o IDMOVTO do movimento dos outros movimentos não aglutinados
// e altera no movimento e ajusta a DCR correspondente.
METHOD GetNextMov() CLASS WMSDTCMovimentosServicoArmazem
Local aAreaAnt  := GetArea()
Local cAliasD12 := GetNextAlias()
Local cNextIdMov:= ""
	BeginSql Alias cAliasD12
		SELECT D12.D12_IDMOV
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_DOC = %Exp:Self:oOrdServ:GetDocto()%
		AND D12.D12_SERIE = %Exp:Self:oOrdServ:GetSerie()%
		AND D12.D12_CLIFOR = %Exp:Self:oOrdServ:GetCliFor()%
		AND D12.D12_LOJA = %Exp:Self:oOrdServ:GetLoja()%
		AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
		AND D12.D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
		AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
		AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
		AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
		AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
		AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
		AND D12.D12_ENDORI = %Exp:Self:oMovEndOri:GetEnder()%
		AND D12.D12_LOCDES = %Exp:Self:oMovEndDes:GetArmazem()%
		AND D12.D12_ENDDES = %Exp:Self:oMovEndDes:GetEnder()%
		AND D12.D12_ORDATI <> %Exp:Self:oMovTarefa:GetOrdem()%
		AND D12.D12_IDMOV <> %Exp:Self:cIdMovto%
		AND D12.D12_IDUNIT = %Exp:Self:cIdUnitiz%
		AND D12.D12_UNIDES = %Exp:Self:cUniDes%
		AND D12.D12_IDDCF  = %Exp:Self:GetIdDCF()%
		AND D12.D12_QTDMOV = %Exp:Self:nQtdMovto%
		AND D12.%NotDel%
		ORDER BY D12.D12_IDMOV
	EndSQl
	If (cAliasD12)->(!Eof())
		cNextIdMov := (cAliasD12)->D12_IDMOV
	EndIf
	(cAliasD12)->(DbCloseArea())
	RestArea(aAreaAnt)
Return cNextIdMov
//-----------------------------------------------------------------------------
METHOD AtuNextMov(cNextIdMov) CLASS WMSDTCMovimentosServicoArmazem
	cQuery := "UPDATE "+RetSqlName("DCR")
	cQuery +=   " SET DCR_IDMOV  = '"+cNextIdMov+"'"
	cQuery += " WHERE DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=   " AND DCR_IDORI  = '"+Self:GetIdDCF()+"'"
	cQuery +=   " AND DCR_IDMOV  = '"+Self:cIdMovto+"'"
	cQuery +=   " AND DCR_IDOPER = '"+Self:cIdOpera+"'"
	cQuery +=   " AND DCR_IDDCF  = '"+Self:GetIdDCF()+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0044 //Problema ao atualizar o ID movimento para os relacionamentos do movimento.
	EndIf
Return lRet

//-----------------------------------------------------------------------------
METHOD IsMovUnit() CLASS WMSDTCMovimentosServicoArmazem
Return (Empty(Self:oMovPrdLot:GetProduto()) .And. (!Empty(Self:cIdUnitiz) .Or. !Empty(Self:cUniDes)))

//-----------------------------------------------------------------------------
METHOD DesNotUnit() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:oMovEndDes:GetTipoEst() == 2 .Or. Self:oMovEndDes:GetTipoEst() == 7 .Or. (Self:oMovEndDes:GetTipoEst() == 5 .And. (Self:oMovServic:ChkSepara() .Or. Self:oOrdServ:GetOrigem() == "D0A")))

//-----------------------------------------------------------------------------
METHOD OriNotUnit() CLASS WMSDTCMovimentosServicoArmazem
Return (Self:oMovEndOri:GetTipoEst() == 2 .Or. Self:oMovEndOri:GetTipoEst() == 7 .Or. (Self:oMovEndOri:GetTipoEst() == 5 .And. (Self:oMovServic:ChkSepara() .Or. Self:oOrdServ:GetOrigem() == "D0A")))

/*/{Protheus.doc} UpdLote
Atualiza lote da movimentação (função de suavização)
@author Squad WMS
@since 26/01/2018
@version 1.0
@return lógico
@param cNovoLote, characters, novo lote para a movimentação
@param cNovoSbLot, characters, novo sub-lote para a movimentação
@type method
/*/
METHOD UpdLote(cNovoLote,cNovoSbLot) CLASS WMSDTCMovimentosServicoArmazem
Local lRet := .T.
	lRet := Self:UpdMovto(cNovoLote,cNovoSbLot,,,,.T.)
Return lRet

/*/{Protheus.doc} UpdMovto
Atualiza lote da movimentação
@author Squad WMS
@since 26/01/2018
@version 1.0
@return lógico
@param cNovoLote, characters, novo lote para a movimentação
@param cNovoSbLot, characters, novo sub-lote para a movimentação
@param cNovoUnit, characters, novo unitizador para a movimentação
@param cNovoEnder, characters, novo endereço para a movimentação
@param cTipoUnit, characters, tipo do novo unitizador
@param lUpdLote, lógico, indica se é apenas uma troca de lote (opção utilizada pelo coletor). Neste caso, a premissa é que o lote terá o mesmo unitizador.
@type method
/*/
METHOD UpdMovto(cNovoLote,cNovoSbLot,cNovoUnit,cNovoEnder,cTipoUnit,lUpdLote) CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local lAltLote  := Iif((AllTrim(cNovoLote) == AllTrim(Self:oMovPrdLot:GetLoteCtl()) .And. AllTrim(cNovoSbLot) == AllTrim(Self:oMovPrdLot:GetNumLote())), .F., .T.)
Local lAltEnder := .T.
Local oMovAux   := WMSDTCMovimentosServicoArmazem():New()
Local oEtiqUnit := Nil
Local cAliasD12 := Nil
Local cAliasQry := Nil
Local nNewRecno := 0
Local nI        := 0
Local aMovExp   := {}
Local nQtdeAnt  := Self:GetQtdMov()
Local cAglutiAnt := Self:GetAgluti()
Default cNovoEnder := ""
Default cNovoUnit  := ""
Default cTipoUnit  := ""
	Wmsconout('UpdMovto - Inicio')
	//Verifica se é uma troca de endereço
	If Self:oMovServic:ChkRecebi().Or. Self:oMovServic:ChkTransf()
		lAltEnder := !Empty(cNovoEnder) .And. !(AllTrim(cNovoEnder) == AllTrim(Self:oMovEndDes:GetEnder()))
	Else
		lAltEnder := !Empty(cNovoEnder) .And. !(AllTrim(cNovoEnder) == AllTrim(Self:oMovEndOri:GetEnder()))
	EndIf
	If lAltLote .And. Self:oOrdServ:GetOrigem() == "SC9" 
		lRet := Self:UpdPedido(cNovoLote,cNovoSbLot)
		
		/* Atualização das movimentações.
		 * Remove a quantidade do lote antigo de:
		 * Montagem de Volume
		 * Distribuição Separação
		 * Conferencia Expedição*/
		If lRet
			lRet := Self:UpdMovExp(@aMovExp)
		EndIf

		//Ajusta conferência de saída
		If lRet 
			lRet := Self:UpdQtdConf(cNovoLote,cNovoSbLot)
		EndIf

		// Ajusta empenho SB8
		If lRet
			lRet := Self:oOrdServ:UpdEmpSB8("-",Self:oMovPrdLot:GetPrdOri(),Self:oMovPrdLot:GetArmazem(),Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote(),Self:GetQtdMov())
			If lRet
				lRet := Self:oOrdServ:UpdEmpSB8("+",Self:oMovPrdLot:GetPrdOri(),Self:oMovPrdLot:GetArmazem(),cNovoLote,cNovoSbLot,Self:GetQtdMov())
			EndIf
		EndIf

	ElseIf Self:oOrdServ:GetOrigem() == 'SD4'
		nQtdSld := (Self:GetQtdMov() / Self:oMovPrdLot:oProduto:oProdComp:GetQtMult())
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD4.R_E_C_N_O_ RECNOSD4
			FROM %Table:SD4% SD4
			WHERE SD4.D4_FILIAL = %xFilial:SD4%
			AND SD4.D4_LOTECTL = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND SD4.D4_NUMLOTE = %Exp:Self:oMovPrdLot:GetNumLote()%
			AND SD4.D4_IDDCF = %Exp:Self:GetIdDCF()%
			AND SD4.%NotDel%
		EndSql
		Do While (cAliasQry)->(!Eof()) .And. nQtdSld > 0
			SD4->(dbGoTo((cAliasQry)->RECNOSD4))
			WmsDivSD4(SD4->D4_COD,;
					Self:oMovEndDes:GetArmazem(),;
					SD4->D4_OP,;
					SD4->D4_TRT,;
					cNovoLote,;
					cNovoSbLot,;
					Nil,;
					nQtdSld,;
					Nil,;
					cNovoEnder,;
					Self:GetIdDCF(),;
					.F.,;
					SD4->(Recno()),;
					Nil,;
					@nNewRecno,;
					.F.,;
					Self:oMovEndOri:GetArmazem())
			SD4->(dbGoTo(nNewRecno))
			// Ajusta empenho SB8
			If lAltLote
				lRet := Self:oOrdServ:UpdEmpSB8("-",Self:oMovPrdLot:GetPrdOri(),Self:oMovPrdLot:GetArmazem(),Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote(),nQtdSld)
				If lRet
					lRet := Self:oOrdServ:UpdEmpSB8("+",Self:oMovPrdLot:GetPrdOri(),Self:oMovPrdLot:GetArmazem(),cNovoLote,cNovoSbLot,nQtdSld)
				EndIf
			EndIf
			nQtdSld -= SD4->D4_Quant
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	ElseIf Self:oMovServic:ChkRecebi().Or. Self:oMovServic:ChkTransf()
		If !Empty(cNovoUnit)
			oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
			oEtiqUnit:SetIdUnit(cNovoUnit)
			If oEtiqUnit:LoadData() .And. Empty(oEtiqUnit:GetTipUni())
				oEtiqUnit:SetTipUni(cTipoUnit)
				oEtiqUnit:SetUsado('1')
				oEtiqUnit:UpdateD0Y(.F.)
			EndIf
		EndIf
	EndIf
	IF lRet
		cAliasD12 := GetNextAlias()
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECNOD12,
				   D12.D12_ATUEST,
				   D12.D12_STATUS,
				   D12.D12_LOCORI,
				   D12.D12_SERVIC
			FROM %Table:D12% D12
		   WHERE D12.D12_FILIAL = %xFilial:D12%
			 AND D12.D12_DOC = %Exp:Self:oOrdServ:GetDocto()%
			 AND D12.D12_SERIE = %Exp:Self:oOrdServ:GetSerie()%
			 AND D12.D12_CLIFOR = %Exp:Self:oOrdServ:GetCliFor()%
			 AND D12.D12_LOJA = %Exp:Self:oOrdServ:GetLoja()%
			 AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
			 AND D12.D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
			 AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			 AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
			 AND D12.D12_ENDORI = %Exp:Self:oMovEndOri:GetEnder()%
			 AND D12.D12_LOCDES = %Exp:Self:oMovEndDes:GetArmazem()%
			 AND D12.D12_ENDDES = %Exp:Self:oMovEndDes:GetEnder()%
			 AND D12.D12_IDMOV = %Exp:Self:GetIdMovto()%
			 AND D12.D12_STATUS <> '0'
			 AND D12.%NotDel%
		EndSql
		WmsConout('UpdMovto - ' + GetLastQuery()[2])
		IF (cAliasD12)->(Eof()) //Inserida esta validacao, 
			//pois o cliente pode ter alterado via UPDATE algum cadastro que foi utilizado para geração do movimento
			lRet := .F.
			Self:cErro := STR0052 //"Os dados do movimento não conferem com o cadastro utilizado para a geração."
		EndIf
		Do While lRet .And. (cAliasD12)->(!Eof())			
			//Posiciona D12
			oMovAux:GoToD12((cAliasD12)->RECNOD12)
			WmsConout('UpdMovto - RecnoD12 / Atuest ' + cValToChar((cAliasD12)->RECNOD12) + ' / ' + (cAliasD12)->D12_ATUEST)
			//Informa que é uma alteração de movimento
			oMovAux:SetUpdMovto(.T.)
			//Registra movimentos aglutinação para a recriação da D12
			If Self:GetAgluti() == "1"
				oMovAux:RegMovAglu()
			EndIf
			//Estorna D12
			If !oMovAux:EstMovComp()
				lRet := .F.
				Self:cErro := oMovAux:GetErro()
				Exit
			EndIf
			//Chama método para geração da nova D12			
			If (cAliasD12)->D12_ATUEST == "1"
				//Seta informações para a nova D12
				If !Empty(cNovoLote)
					oMovAux:oMovPrdLot:SetLoteCtl(cNovoLote)
				EndIf
				If !Empty(cNovoSbLot)
					oMovAux:oMovPrdLot:SetNumLote(cNovoSbLot)
				EndIf
				If !lUpdLote
					If Self:oMovServic:ChkRecebi().Or. Self:oMovServic:ChkTransf()
						oMovAux:SetUniDes(cNovoUnit)
						oMovAux:SetTipUni(cTipoUnit)
					Else
						oMovAux:SetIdUnit(cNovoUnit)
						oMovAux:SetTipUni(cTipoUnit)
					EndIf
				EndIf
				If lAltEnder
					If Self:oMovServic:ChkRecebi().Or. Self:oMovServic:ChkTransf()
						oMovAux:oMovEndDes:SetEnder(cNovoEnder)
						oMovAux:oMovEndDes:LoadData()
					Else
						oMovAux:oMovEndOri:SetEnder(cNovoEnder)
						oMovAux:oMovEndOri:LoadData()
					EndIf
					//Limpa informação do recurso humano
					oMovAux:SetRecHum("")
				EndIf
				oMovAux:GeraMovto()
			EndIf
			(cAliasD12)->(DbSkip())
		EndDo
		(cAliasD12)->(DbCloseArea())
	EndIf
	IF lRet
		//Posiciona na nova D12 gerada
		Self:GoToD12(oMovAux:GetRecno())
	EndIf
	If lRet .And. lAltEnder
		//Reprocessa regra de convocação para o documento
		Self:ReproRegra()
	EndIf
	If lRet .And. lAltLote .And. Self:oOrdServ:GetOrigem() == "SC9"
		// Atualização das movimentações:
		// Ajusta a quantidade do lote selecionado
		// Montagem de Volume
		// Distribuição Separação
		// Conferencia Expedição
		For nI := 1 To Len(aMovExp)
			lRet := Self:UpdExpedic(aMovExp[nI][1],aMovExp[nI][2],aMovExp[nI][3],aMovExp[nI][4])
		Next nI
	EndIf

	If lRet /*.And. lAltLote*/ .And. Self:oOrdServ:GetOrigem() == "SC9" 
		lRet := Self:oOrdServ:VldGrvOS(@Self:cErro, oMovAux:aMovAglu, nQtdeAnt, cAglutiAnt, oMovAux:GetRecno())
	EndIf

	Wmsconout('UpdMovto - Fim')

Return lRet
/*/{Protheus.doc} UpdPedido
Troca de lote do pedido de venda (SC9)
@author Squad WMS
@since 28/01/2018
@version 1.0
@return lógico
@param cNovoLote, characters, novo lote para a movimentação
@param cNovoSbLot, characters, novo sub-lote para a movimentação
@type method
/*/
METHOD UpdPedido(cNovoLote,cNovoSbLot) CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lWmsAglu  := SuperGetMV('MV_WMSAGLU',.F.,.F.) .Or. lWmsNew //-- Aglutina itens da nota fiscal de saida com mesmo Lote e Sub-Lote
Local lDlEstC9  := .T.
Local aAreaAnt  := GetArea()
Local aAreaSB2  := SB2->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local aDlEstC9  := {}
Local cAliasQry := Nil
Local nQtdMov   := Self:nQtdMovto
Local nQtdOrig  := Self:nQtdMovto
Local nNewRecno := 0
	
	// P.E. para manipular o estorno da liberação do pedido
	// O retorno deve ser .T. para que o processo não tome o padrão
	If ExistBlock("DLVESTC9")
		aDlEstC9 := ExecBlock("DLVESTC9",.F.,.F.,{lDlEstC9,Self:GetRecno(),nQtdOrig,nQtdMov,.F.})
		If ValType(aDlEstC9) == "A" .And. Len(aDlEstC9) >= 2
			lDlEstC9 := aDlEstC9[1]
			lRet     := aDlEstC9[2]
		EndIf
	EndIf

	If lDlEstC9
		// Busca todos os documentos aglutinados ao movimento
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCR.DCR_QUANT,
					DCR.DCR_IDDCF,
					SC9.C9_CARGA,
					SC9.C9_PEDIDO,
					SC9.C9_ITEM,
					SC9.C9_QTDLIB,
					SC9.C9_SEQUEN,
					SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:DCR% DCR
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_IDDCF = DCR.DCR_IDDCF
			AND SC9.C9_LOTECTL = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND SC9.C9_NUMLOTE = %Exp:Self:oMovPrdLot:GetNumLote()%
			AND SC9.C9_BLWMS   = '01'
			AND SC9.C9_BLEST   = '  '
			AND SC9.C9_BLCRED  = '  '
			AND SC9.%NotDel%
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
			AND DCR.DCR_IDOPER = %Exp:Self:cIdOpera%
			AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR.%NotDel%
		EndSql

		WmsConout('UpdPedido - ' + GetLastQuery()[2])
		Do While (cAliasQry)->(!EoF()) .And. lRet .And. nQtdMov > 0
			nNewRecno := 0
			
			If QtdComp(nQtdMov) >= QtdComp((cAliasQry)->C9_QTDLIB)
				//Posiciona na SC9 que terá o lote alterado
				SC9->(DbGoTo((cAliasQry)->RECNOSC9))
				WmsConout('UpdPedido - RecnoSC9 ' + cValToChar((cAliasQry)->RECNOSC9) + '. Substraindo ' + cValToChar((cAliasQry)->C9_QTDLIB) + ' do movimento de ' + cValToChar(nQtdMov))
				nQtdMov -= (cAliasQry)->C9_QTDLIB
			Else // Realiza quebra da SC9 para gravar novo lote informado
				lRet := WmsDivSC9((cAliasQry)->C9_CARGA,;                 //cCarga
									(cAliasQry)->C9_PEDIDO,;              //cPedido
									(cAliasQry)->C9_ITEM,;                //cItem
									Self:oMovPrdLot:GetProduto(),;        //cProduto
									Self:oOrdServ:oServico:GetServico(),; //cServico
									Self:oMovPrdLot:GetLoteCtl(),;        //cLoteCtl
									Self:oMovPrdLot:GetNumLote(),;        //cNumLote
									Self:oMovPrdLot:GetNumSer(),;         //cNumSerie
									(cAliasQry)->DCR_QUANT,;              //nQuant
									/*nQuant2UM*/,;                       //nQuant2UM
									Self:oMovEndOri:GetArmazem(),;        //cLocal
									Self:oMovEndOri:GetEnder(),;          //cEndereco
									(cAliasQry)->DCR_IDDCF,;              //cIdDCF
									.F.,;                                 //lWmsLibSC9
									.F.,;                                 //lGeraEmp
									"01",;                                //cBlqWMS
									(cAliasQry)->RECNOSC9,;               //nRecSC9
									Nil,;                                 //cRomaneio
									(cAliasQry)->C9_SEQUEN,;              // cSeqSC9
									.F.,;                                 //lLotVazio
									@nNewRecno)                           //Novo Recno da SC9 criada
				//Posiciona na SC9 que terá o lote alterado
				SC9->(DbGoTo(nNewRecno))
				//Atualiza quantidade movimentada restante
				WmsConout('UpdPedido - 2 RecnoSC9 ' + cValToChar(nNewRecno) + '. Substraindo ' + cValToChar((cAliasQry)->DCR_QUANT) + ' do movimento de ' + cValToChar(nQtdMov))
				nQtdMov -= (cAliasQry)->DCR_QUANT
			EndIf
			
			//Altera lote SC9
 			If lRet
				If RecLock("SC9",.F.)
					WmsConout('UpdPedido - RecLock SC9 Ok')
				Else
					WmsConout('UpdPedido - RecLock SC9 Não Ok')			
				EndIf

				SC9->C9_BLEST   := " "
				SC9->C9_BLCRED  := " "
				SC9->C9_LOTECTL := cNovoLote
				SC9->C9_DTVALID := Posicione('SB8',3,xFilial('SB8')+Self:oMovPrdLot:GetProduto()+Self:oMovEndOri:GetArmazem()+cNovoLote+cNovoSbLot,'B8_DTVALID')
				SC9->C9_NUMLOTE := cNovoSbLot
				SC9->(MsUnlock())
				SC9->(DbCommit()) //-- Força enviar para o banco a atualização da SC9
			
				//Verifica se pode aglutinar a SC9 criada
				If lWmsAglu .And. (nNewRecno > 0 .Or. (nNewRecno = 0 .And. Self:WmsAgLotC9((cAliasQry)->RECNOSC9,cNovoLote,cNovoSbLot))) //Ou mesma quantidade, alterou SC9 e ela ficou duplicada.
					If WmsAgluSC9(SC9->C9_CARGA,;                  //cCarga
									SC9->C9_PEDIDO,;               //cPedido
									SC9->C9_ITEM,;                 //cItem
									Self:oMovPrdLot:GetProduto(),; //cProduto
									cNovoLote,;                    //cLoteCtl
									cNovoSbLot,;                   //cNumLote
									Self:oMovPrdLot:GetNumSer(),;  //cNumSerie
									(cAliasQry)->DCR_QUANT,;       //nQuant
									Nil,;                          //nQuant2UM
									Self:oMovEndOri:GetArmazem(),; //cLocal
									Self:oMovEndOri:GetEnder(),;   //cEndereco
									(cAliasQry)->DCR_IDDCF,;       //cIdDCF
									.F.,;                          //lWmsLibSC9
									.F.,;                          //lGeraEmp
									SC9->C9_SEQUEN,;               //cSeqSC9
									.T.)                           //lDescSC9
						//-- Deve diminuir a quantidade da SC9 atual apenas
						SC9->C9_QTDLIB  -= (cAliasQry)->DCR_QUANT
						SC9->C9_QTDLIB2 -= ConvUM(Self:oMovPrdLot:GetProduto(),(cAliasQry)->DCR_QUANT,0,2)
						If QtdComp(SC9->C9_QTDLIB) <= 0
							WmsConout('UpdPedido - Delete SC9 Aglutinada Recno SC9 ' + cValtoChar(SC9->(Recno())))
							SC9->(DbDelete())
						EndIf
						SC9->(MsUnlock())
					EndIf
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aAreaSB2)
	RestArea(aAreaSC9)
	RestArea(aAreaAnt)

Return lRet

/*/{Protheus.doc} UpdMovExp
Atualização das movimentações de expedição:
	Montagem de Volume
	Distribuição Separação
	Conferencia Expedição
@author Squad WMS
@since 28/01/2018
@version 1.0
@return lógico
@type method
/*/
METHOD UpdMovExp(aMovExp) CLASS WMSDTCMovimentosServicoArmazem
Local lRet        := .T.
Local oMntVolItem := WMSDTCMontagemVolumeItens():New()
Local oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
Local oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
Local cAliasQry   := Nil
Default aMovExp := {}
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCF.DCF_CARGA,
			   DCF.DCF_DOCTO,
			   DCF.DCF_CLIFOR,
			   DCF.DCF_LOJA,
			   DCF.DCF_ID,
			   DCR.DCR_QUANT
		FROM %Table:DCR% DCR
		INNER JOIN %Table:DCF% DCF
		ON DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ID = DCR.DCR_IDDCF
		AND DCF.%NotDel%
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
		AND DCR.DCR_IDOPER = %Exp:Self:cIdOpera%
		AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
		AND DCR.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof()) .And. lRet
		//Armazena as ordens de serviço que terão suas movimentações apagadas, para recriar posteriormente
		If aScan(aMovExp,{|x| x[1]+x[2]+x[3]+x[4]==(cAliasQry)->DCF_ID+(cAliasQry)->DCF_DOCTO+(cAliasQry)->DCF_CLIFOR+(cAliasQry)->DCF_LOJA}) == 0
			AADD(aMovExp,{(cAliasQry)->DCF_ID,(cAliasQry)->DCF_DOCTO,(cAliasQry)->DCF_CLIFOR,(cAliasQry)->DCF_LOJA})
		EndIf
		// Atualiza Montagem Volume
		oMntVolItem:SetCarga((cAliasQry)->DCF_CARGA)
		oMntVolItem:SetPedido((cAliasQry)->DCF_DOCTO)
		oMntVolItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
		oMntVolItem:SetProduto(Self:oMovPrdLot:GetProduto())
		oMntVolItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
		oMntVolItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
		// Busca o codigo da montagem do volume
		oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
		If oMntVolItem:LoadData()
			lRet := oMntVolItem:RevMntVol((cAliasQry)->DCR_QUANT,0)
			// Atualiza o status para da DCV para liberado
			If lRet .And. oMntVolItem:oMntVol:GetLibPed() == "6" .And. oMntVolItem:oMntVol:GetStatus() == "3"
				oMntVolItem:oMntVol:LiberSC9()
			EndIf
			If !lRet
				Self:cErro := oMntVolItem:GetErro()
			EndIf
		EndIf
		If lRet
			// Atualiza Distribuição Separação
			oDisSepItem:oDisSep:SetCarga((cAliasQry)->DCF_CARGA)
			oDisSepItem:oDisSep:SetPedido((cAliasQry)->DCF_DOCTO)
			oDisSepItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
			oDisSepItem:oDisPrdLot:SetProduto(Self:oMovPrdLot:GetProduto())
			oDisSepItem:oDisPrdLot:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
			oDisSepItem:oDisPrdLot:SetNumLote(Self:oMovPrdLot:GetNumLote())
			oDisSepItem:oDisPrdLot:SetNumSer(Self:oMovPrdLot:GetNumSer())
			oDisSepItem:oDisEndOri:SetArmazem(Self:oMovEndDes:GetArmazem())
			oDisSepItem:oDisSep:oDisEndDes:SetArmazem(Self:oMovEndDes:GetArmazem())
			oDisSepItem:oDisEndOri:SetArmazem(Self:oMovEndDes:GetArmazem())
			// Busca o codigo da distribuição da separação
			oDisSepItem:SetCodDis(oDisSepItem:oDisSep:FindCodDis())
			If oDisSepItem:LoadData()
				lRet := oDisSepItem:RevDisSep((cAliasQry)->DCR_QUANT,0) // Senão estorna a quantidade a menor
				If !lRet
					Self:cErro := oDisSepItem:GetErro()
				EndIf
			EndIf
		EndIf
		If lRet
			// Atualiza Conferencia Expedição
			oConExpItem:SetCarga((cAliasQry)->DCF_CARGA)
			oConExpItem:SetPedido((cAliasQry)->DCF_DOCTO)
			oConExpItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
			oConExpItem:SetProduto(Self:oMovPrdLot:GetProduto())
			oConExpItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
			oConExpItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
			// Busca o codigo da conferencia de expedicao
			oConExpItem:SetCodExp(oConExpItem:oConfExp:FindCodExp())
			If oConExpItem:LoadData()
				lRet := oConExpItem:RevConfExp((cAliasQry)->DCR_QUANT,0) // Senão estorna a quantidade a menor
				//Se o status da conferência encontra-se como "3-Conferido" e o serviço WMS está parametrizado para liberar na conferência de expedição, então libera SC9
				If lRet .And. oConExpItem:oConfExp:GetLibPed() == "3"  .And. oConExpItem:oConfExp:GetStatus() == "3"
					WMSV102LIB(1,oConExpItem:GetCodExp(),oConExpItem:GetCarga(),oConExpItem:GetPedido())
				EndIf
				If !lRet
					Self:cErro := oConExpItem:GetErro()
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet
/*/{Protheus.doc} UpdQtdConf
//Ajusta quantidade do movimento de conferência de saída,
//que possuí como característica agrupar em uma única D12
//as quantidades referentes a um lote e produto 
@author amanda.vieira
@since 23/06/2018
@version 1.0
@return lógico
@param cNovoLote, characters, Novo lote para a quebra 
@param cNovoSubLote, characters, Novo sub-lote para a quebra
@type function
/*/
METHOD UpdQtdConf(cNovoLote,cNovoSubLote) CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local aIdDCF     := {}
Local oMovimento := WMSDTCMovimentosServicoArmazem():New()
Local oMovNew    := WMSDTCMovimentosServicoArmazem():New()
Local oRelacMov  := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local oRelacNew  := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local cIdDCF     := ""
Local cAliasQry  := Nil
Local cAliasD12  := Nil
Local nI         := 1
Local nQtdQuebra := 0
	
	//Monta array com os Id DCF e suas respectivas quantidades
	If Self:GetAgluti() == "1"
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCR.DCR_IDDCF,
					DCR.DCR_QUANT
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12 
			ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_STATUS <> '0'
			AND D12.%NotDel%
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDMOV = %Exp:Self:GetIdMovto()%
			AND DCR.DCR_IDOPER = %Exp:Self:GetIdOpera()%
			AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR.%NotDel%
		EndSql
		WmsConout('UpdQtdConf - ' + GetLastQuery()[2])
		Do While (cAliasQry)->(!EoF())
			AADD(aIdDCF,{(cAliasQry)->DCR_IDDCF,(cAliasQry)->DCR_QUANT})
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	Else
		AADD(aIdDCF,{Self:oOrdServ:GetIdDCF(),Self:nQuant})
	EndIf
	
	For nI :=1 To Len(aIdDCF)
		cIdDCF     := aIdDCF[nI][1]
		nQtdQuebra := aIdDCF[nI][2]
		//Busca conferência de saída para o Id DCF
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12,
					DCR.R_E_C_N_O_ RECNODCR
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12
			ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI 
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
			AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
			AND D12.D12_STATUS <> '0'
			AND D12.%NotDel%
			INNER JOIN %Table:DC5% DC5
			ON DC5.DC5_FILIAL = %xFilial:DC5%
			AND DC5.DC5_SERVIC = D12.D12_SERVIC
			AND DC5.DC5_TAREFA = D12.D12_TAREFA
			AND DC5.DC5_OPERAC = '7'
			AND DC5.%NotDel%
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF  = %Exp:cIdDCF%
			AND DCR.%NotDel%
		EndSql
		WmsConout('UpdQtdConf - D12 e DCR ' + GetLastQuery()[2])
		If (cAliasQry)->(!EoF())
			//Posiciona D12 e DCR
			oMovimento:GoToD12((cAliasQry)->RECNOD12)
			oRelacMov:GoToDCR((cAliasQry)->RECNODCR)
			WmsConout('UpdQtdConf RecnoD12 / RecnoDCR / QtdMov / QtdQuebra ' + CValToChar((cAliasQry)->RECNOD12) + ' / ' +CValToChar((cAliasQry)->RECNODCR) + ' / ' + CValToChar(oMovimento:GetQtdMov()) + ' / ' + CValToChar(nQtdQuebra))			
			If QtdComp(oMovimento:GetQtdMov()) <= QtdComp(nQtdQuebra)
				// Exclui D12 e DCR quando a quantidade ficar zerada
				oMovimento:DeleteD12()
				oRelacMov:DeleteDCR()
			Else
				// Ajusta conferência atual
				oMovimento:SetQtdMov(oMovimento:GetQtdMov() - nQtdQuebra)
				oMovimento:SetQtdOri(oMovimento:GetQtdMov())
				If oMovimento:GetQtdMov() == oMovimento:GetQtdLid()
					oMovimento:SetStatus("1")
				EndIf
				oMovimento:UpdateD12()
				// Atualiza quantidade da DCR
				oRelacMov:SetQuant(oRelacMov:GetQuant() - nQtdQuebra)
				oRelacMov:SetQuant2(ConvUm(oMovimento:oMovPrdLot:GetProduto(),oRelacMov:GetQuant(),0,2))
				oRelacMov:UpdateDCR()
			EndIf
			//Verifica se já existe movimentação de conferência para o novo lote/sublote
			cAliasD12  := GetNextAlias()
			BeginSql Alias cAliasD12
				SELECT D12.R_E_C_N_O_ RECNOD12,
						DCR.R_E_C_N_O_ RECNODCR
				FROM %Table:DCR% DCR
				INNER JOIN %Table:D12% D12
				ON D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_IDDCF  = DCR.DCR_IDORI 
				AND D12.D12_IDMOV  = DCR.DCR_IDMOV
				AND D12.D12_IDOPER = DCR.DCR_IDOPER
				AND D12.D12_PRODUT = %Exp:oMovimento:oMovPrdLot:GetProduto()%
				AND D12.D12_LOTECT = %Exp:cNovoLote%
				AND D12.D12_NUMLOT = %Exp:cNovoSubLote%
				AND D12.D12_STATUS <> '0'
				AND D12.%NotDel%
				INNER JOIN %Table:DC5% DC5
				ON DC5.DC5_FILIAL = %xFilial:DC5%
				AND DC5.DC5_SERVIC = D12.D12_SERVIC
				AND DC5.DC5_TAREFA = D12.D12_TAREFA
				AND DC5.DC5_OPERAC = '7'
				AND DC5.%NotDel%
				WHERE DCR.DCR_FILIAL = %xFilial:DCR%
				AND DCR.DCR_IDDCF  = %Exp:cIdDCF%
				AND DCR.%NotDel%
			EndSql
			WmsConout('UpdateQtdConf ' + GetLastQuery()[2])
			If (cAliasD12)->(!EoF())
				//Atualiza D12 já existente com a quantidade alterada
				oMovNew:GoToD12((cAliasD12)->RECNOD12)
				oMovNew:SetQtdMov(oMovNew:GetQtdMov()+nQtdQuebra)
				oMovNew:SetQtdOri(oMovNew:GetQtdMov())
				If oMovNew:GetQtdLid() > 0 .And. oMovNew:GetStatus() == "1"
					oMovNew:SetStatus("4")
				EndIf
				oMovNew:UpdateD12()
				//Atualiza DCR já existente com a quantidade alterada
				oRelacNew:GoToDCR((cAliasD12)->RECNODCR)
				oRelacNew:SetQuant(oRelacNew:GetQuant() + nQtdQuebra)
				oRelacNew:SetQuant2(ConvUm(oMovNew:oMovPrdLot:GetProduto(),oRelacNew:GetQuant(),0,2))
				oRelacNew:UpdateDCR()
			Else
				//Cria nova movimentação com a quantidade restante
				oMovNew:oOrdServ:SetIdDCF(cIdDCF)
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
				oMovNew:oMovPrdLot:SetLoteCtl(cNovoLote)
				oMovNew:oMovPrdLot:SetNumLote(cNovoSubLote)
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
				oMovNew:SetQtdLid(0)
				oMovNew:SetPriori(oMovimento:GetPriori())
				oMovNew:SetSeqPrio(oMovimento:GetSeqPrio())
				oMovNew:SetStatus('4')
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
				oMovNew:cOrdMov := oMovimento:cOrdMov
				// Atribui dados das atividades e cria as movimentações
				oMovNew:RecordD12()
			EndIf
			(cAliasD12)->(DbCloseArea())
		EndIf
		(cAliasQry)->(DbCloseArea())
	Next nI
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} ChkEstPrd
//Valida se quantidade solicitada possui saldo do produto
//e quando possui controle de lote se a quantidade possui
//saldo por lote
@author Squad WMS Protheus
@since 27/06/2018
@version 1.0
@return lógico
@param lMovEst, Logical, Indica se desconta quantidade da movimentação da quantidade saida prevista, pois quantidade do movimento está inclusa.
@param lConMov, Logical, Inidca se Considera apenas o saldo atual do endereço, pois está efetuando efetivamente a movimentação de estoque
@param cLocal, characters, código do armazém 
@param cProduto, characters, código do produto
@param cLoteCtl, characters, código do lote 
@param cNumLote, characters, código do sub-lote do lote
@param nQuant, characters, Quantidade solicitada 

@type function
@version 1.0
/*/
//--------------------------------------------------
METHOD ChkEstPrd(lMovEst,lConsMov,cLocal,cProduto,cLoteCtl,cNumLote,nQuant,lDescBlq) CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local aSldD14   := {}
Local aTamSX3   := TamSx3("D4_QUANT")
Local cAliasQry := Nil
Local cAliasSD4 := Nil
Local nSaldoSB2 := 0
Local nSldD14   := 0
Local nEmpD14   := 0
Local nEmpSB8   := 0
Local nQtdBlq   := 0
Default cLoteCtl := PadR(cLoteCtl,TamSx3("D12_LOTECT")[1])
Default cNumLote := PadR(cNumLote,TamSx3("D12_NUMLOT")[1])
Default nQuant   := 0
Default lDescBlq := .F.

	cLocal   := PadR(cLocal,TamSx3("D12_LOCORI")[1])
	cProduto := PadR(cProduto,TamSx3("D12_PRODUT")[1])
	// Valida saldo produto
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SB2.R_E_C_N_O_ RECNOSB2
		FROM %Table:SB2% SB2
		WHERE SB2.B2_FILIAL = %xFilial:SB2%
		AND SB2.B2_COD = %Exp:cProduto%
		AND SB2.B2_LOCAL = %Exp:cLocal%
		AND SB2.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		SB2->(dbGoTo((cAliasQry)->RECNOSB2))
		// Busca saldo do produto descontando empenhos
		nSaldoSB2:=SaldoSB2()
		//Soma quantidade bloqueada, para considerar como disponível para a transferência
		if lDescBlq
			nSaldoSB2 += Self:SldBlq(cLocal,cProduto)
		EndIf
		// Busca saldo de requisição de empenho pendente para somar no saldo do produto
		// Pois não é um saldo restritivo
		cAliasSD4 := GetNextAlias()
		BeginSql Alias cAliasSD4
			SELECT SUM(SD4.D4_QUANT) D4_QUANT
			FROM %Table:SD4% SD4
			WHERE SD4.D4_FILIAL = %xFilial:SD4%
			AND SD4.D4_COD = %Exp:cProduto%
			AND SD4.D4_LOCAL = %Exp:cLocal%
			AND SD4.D4_LOTECTL = ' '
			AND SD4.D4_NUMLOTE = ' '
			AND SD4.D4_IDDCF = ' '
			AND SD4.%NotDel%
		EndSql
		TcSetField(cAliasSD4,'D4_QUANT' ,'N',aTamSX3[1],aTamSX3[2])
		If (cAliasSD4)->(!Eof())
			nSaldoSB2 += (cAliasSD4)->D4_QUANT
		EndIf
		(cAliasSD4)->(dbCloseArea())
		// Calcula saldo disponível
		nSaldoSB2:= Iif(lMovEst,QtdComp(nSaldoSB2),QtdComp(nSaldoSB2 - Iif(lConsMov,0,nQuant)))
	EndIf
	(cAliasQry)->(dbCloseArea())
	If QtdComp(nSaldoSB2) < 0
		lRet := .F.
	EndIf 
	// Valida se controla rastro e lote informado
	If lRet .And. Self:oMovPrdLot:HasRastro() .And. !Empty(cLoteCtl)
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SB8.B8_EMPENHO
			FROM %Table:SB8% SB8
			WHERE SB8.B8_FILIAL = %xFilial:SB8%
			AND SB8.B8_PRODUTO = %Exp:cProduto%
			AND SB8.B8_LOCAL = %Exp:cLocal%
			AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
			AND SB8.B8_NUMLOTE = %Exp:cNumLote%
			AND SB8.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			nQtdBlq := 0
			if lDescBlq
				//Caso o sistema encontrar-se parametrizado para permitir transferência de quantidade bloqueada
				//deve desconsiderar o saldo bloqueado ao calcular o empenho do lote
				nQtdBlq := Self:SldBlq(cLocal,cProduto,cLoteCtl,cNumLote)
			EndIf
			aSldD14 := Self:SldPrdLot(cLoteCtl,cNumLote)
			nSldD14 := aSldD14[1]      //Quantidade em estoque do lote (D14)
			nEmpD14 := aSldD14[2] - nQtdBlq //Quantidade de empenho e empenho previsto do lote (D14)
			nEmpSB8 := (cAliasQry)->B8_EMPENHO - nQtdBlq//Quantidade de empenho do lote (SB8)
			//Quando é uma transferência entre armazéns e o destino e DOCA, pode gerar mais de um movimento neste caso desconta do empenho SB8 a quantidade da movimentação.
			If Self:oMovServic:ChkTransf() .And. !(Self:oMovEndOri:GetArmazem() == Self:oMovEndDes:GetArmazem()) .AND. lMovEst
				nEmpSB8 -= Self:oordserv:nQuant
			EndIf 

			//Verifica se a quantidade empenhada do lote (SB8) é maior que a quantidade empenhada dos endereços (D14)
			//Caso for maior, indica que existem ordens de serviços que estão pendentes de execução para o lote (lote informado no pedido)
			nSldD14 := Iif(lMovEst,QtdComp(nSldD14),QtdComp(nSldD14 - Iif(lConsMov,0,nQuant)))
			If QtdComp(nEmpSB8) > QtdComp(nEmpD14)
				//Calcula a quantidade disponível para o lote 
				nSldD14 -= nEmpSB8
			Else
				nSldD14 -= nEmpD14
			EndIf
			//Se sobrou saldo disponível, utiliza para realizar a transferencia
			If QtdComp(nSldD14) < 0
 				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} SldPrdLot
//Busca os saldo do produto em estoque e o saldo do produto
//descontando a quantidade bloqueada, empenho previsto e empenho
@author Squad WMS Protheus
@since 27/06/2018
@version 1.0
@return array
@param cLoteCtl, characters, código do lote 
@param cNumLote, characters, código do sub-lote do lote
@type function
@version 1.0
/*/
//--------------------------------------------------
METHOD SldPrdLot(cLotectl, cNumlote) CLASS WMSDTCMovimentosServicoArmazem
Local aSaldo    := {}
Local aTamSX3   := GetWmsSx3("D14_QTDEST")
Local cAliasD14 := Nil
	cAliasD14 := GetNextAlias()
	If !Empty(cNumLote)
		BeginSql Alias cAliasD14
			SELECT SUM(D14_QTDEST) D14_SALDO,
					SUM(D14_QTDBLQ+D14_QTDPEM+D14_QTDEMP) D14_EMP
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL =  %Exp:Self:oMovEndOri:GetArmazem()%
			AND D14.D14_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND D14.D14_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
			AND D14.D14_LOTECT = %Exp:cLoteCtl%
			AND D14.D14_NUMLOT = %Exp:cNumLote%
			AND D14.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasD14
			SELECT SUM(D14_QTDEST) D14_SALDO,
					SUM(D14_QTDBLQ+D14_QTDPEM+D14_QTDEMP) D14_EMP
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL =  %Exp:Self:oMovEndOri:GetArmazem()%
			AND D14.D14_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND D14.D14_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
			AND D14.D14_LOTECT = %Exp:cLoteCtl%
			AND D14.%NotDel%
		EndSql
	EndIf
	TcSetField(cAliasD14,'D14_SALDO' ,'N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_EMP'   ,'N',aTamSX3[1],aTamSX3[2])
	If (cAliasD14)->(!Eof())
		aSaldo := {(cAliasD14)->D14_SALDO,(cAliasD14)->D14_EMP}
	EndIf
	(cAliasD14)->(DbCloseArea())
Return aSaldo
//--------------------------------------------------
/*/{Protheus.doc} LibPedConf
// Efetua a liberação do bloqueio WMS quando configura para liberar 
// na conferência convocada
@author Squad WMS Protheus
@since 15/02/2019
@version 1.0
@type function
@version 1.0
/*/
//--------------------------------------------------
METHOD LibPedConf() CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local lCarga    := WmsCarga(Self:oOrdServ:GetCarga())
Local lWmsDaEn  := SuperGetMV("MV_WMSDAEN",.F.,.F.) // Conferência apenas considerando o endereço sem o armazém
Local aAreaAnt  := GetArea()
Local cWhere    := ""
Local cAliasQry := Nil
	// Parâmetro Where
	cWhere := "%"
	If Self:lUsuArm .Or. !lWmsDaEn 
		cWhere +=  " AND D12.D12_LOCDES  = '"+Self:oMovEndDes:GetArmazem()+"'"
	EndIf
	cWhere += "%"
	cAliasQry := GetNextAlias()
	If lCarga
		BeginSql Alias cAliasQry
			SELECT DISTINCT SC9.C9_CARGA,
					SC9.C9_PEDIDO,
					SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:D12% D12
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_CARGA = %Exp:Self:oOrdServ:GetCarga()%
			AND SC9.C9_PRODUTO = D12.D12_PRDORI
			AND SC9.C9_SERVIC = D12.D12_SERVIC
			AND SC9.C9_LOTECTL = D12.D12_LOTECT
			AND SC9.C9_NUMLOTE = D12.D12_NUMLOT
			AND SC9.C9_IDDCF = D12.D12_IDDCF
			AND SC9.C9_BLWMS = '01'
			AND SC9.%NotDel%
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
			AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()%
			AND D12.D12_TAREFA = %Exp:Self:oMovTarefa:GetTarefa()%
			AND D12.D12_ATIVID = %Exp:Self:oMovTarefa:GetAtivid()%
			AND D12.D12_CARGA = %Exp:Self:oOrdServ:GetCarga()%
			AND D12.D12_STATUS = '1'
			AND D12.D12_ENDDES  = %Exp:Self:oMovEndDes:GetEnder()%
			AND D12.%NotDel%
			%Exp:cWhere%
			AND NOT EXISTS (SELECT 1
							FROM %Table:D12% D12E
							WHERE D12E.D12_FILIAL = %xFilial:D12%
							AND D12E.D12_IDDCF = D12.D12_IDDCF
							AND D12E.D12_SERVIC = D12.D12_SERVIC
							AND D12E.D12_TAREFA = D12.D12_TAREFA
							AND D12E.D12_ORDATI = D12.D12_ORDATI
							AND D12E.D12_CARGA = D12.D12_CARGA
							AND D12E.D12_STATUS IN ('4','3','2')
							AND D12E.%NotDel% )
			ORDER BY SC9.C9_CARGA,
						SC9.C9_PEDIDO
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT DISTINCT SC9.C9_CARGA,
					SC9.C9_PEDIDO,
					SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:D12% D12
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:Self:oOrdServ:GetDocto()%
			AND SC9.C9_ITEM = D12.D12_SERIE
			AND SC9.C9_PRODUTO = D12.D12_PRDORI
			AND SC9.C9_SERVIC  = D12.D12_SERVIC
			AND SC9.C9_LOTECTL = D12.D12_LOTECT
			AND SC9.C9_NUMLOTE = D12.D12_NUMLOT
			AND SC9.C9_IDDCF = D12.D12_IDDCF
			AND SC9.C9_BLWMS = '01'
			AND SC9.%NotDel%
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
			AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()%
			AND D12.D12_TAREFA = %Exp:Self:oMovTarefa:GetTarefa()%
			AND D12.D12_ATIVID = %Exp:Self:oMovTarefa:GetAtivid()%
			AND D12.D12_DOC   =  %Exp:Self:oOrdServ:GetDocto()%
			AND D12.D12_STATUS  = '1'
			AND D12.D12_ENDDES  = %Exp:Self:oMovEndDes:GetEnder()%
			AND D12.%NotDel%
			%Exp:cWhere%
			AND NOT EXISTS (SELECT 1
							FROM %Table:D12% D12E
							WHERE D12E.D12_FILIAL = %xFilial:D12%
							AND D12E.D12_IDDCF = D12.D12_IDDCF
							AND D12E.D12_SERVIC = D12.D12_SERVIC
							AND D12E.D12_TAREFA = D12.D12_TAREFA
							AND D12E.D12_ORDATI = D12.D12_ORDATI
							AND D12E.D12_DOC = D12.D12_DOC
							AND D12E.D12_SERIE = D12.D12_SERIE
							AND D12E.D12_STATUS IN ('4','3','2')
							AND D12E.%NotDel% )
			ORDER BY SC9.C9_CARGA,
						SC9.C9_PEDIDO
		EndSql
	EndIf
	Do While lRet .And. (cAliasQry)->(!Eof())
		SC9->(DbGoTo((cAliasQry)->RECNOSC9)) // Posiciona no registro do SC9 correspondente
		RecLock("SC9",.F.)
		SC9->C9_BLWMS := "05"
		SC9->(MsUnlock())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------------------
METHOD EstMovto() CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local lEmpPrev   := .F.
Local aTamSX3    := {}
Local oEstEnder  := Self:oEstEnder // Para facilitar o apontamento do objeto
Local oRelacMov  := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local cAliasQry  := Nil
Local cAliasDCR  := Nil
	cAliasDCR := GetNextAlias()
	If WmsX312118("D12","D12_IDUNIT")
		BeginSql Alias cAliasDCR
			SELECT DCR.R_E_C_N_O_ RECNODCR
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12
			ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI 
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
			AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
			AND D12.D12_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D12.D12_STATUS <> '0'
			AND D12.D_E_L_E_T_ = ' '
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR.DCR_IDDCF = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
			AND DCR.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasDCR
			SELECT DCR.R_E_C_N_O_ RECNODCR
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12
			ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI 
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
			AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
			AND D12.D12_STATUS <> '0'
			AND D12.D_E_L_E_T_ = ' '
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR.DCR_IDDCF = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
			AND DCR.%NotDel%
		EndSql
	EndIf
	If (cAliasDCR)->(!EoF())
		oRelacMov:GoToDCR((cAliasDCR)->RECNODCR)
	EndIf
	(cAliasDCR)->(DbCloseArea())
	If lRet .And. Self:IsUpdEst()
		lEmpPrev := Self:oMovServic:ChkSepara()
		If Self:IsMovUnit()
			// Se for uma transferência de estorno de endereçamento e a origem for um picking
			// Não possui saldo por unitizador, neste caso deve carregar o saldo inicial do unitizador
			If Self:oMovServic:ChkRecebi() .And. Self:oMovEndDes:GetTipoEst() == 2
				If !Empty(Self:oMovEndDes:GetEnder())
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT D0R.D0R_CODUNI,
								D0S.D0S_PRDORI,
								D0S.D0S_CODPRO,
								D0S.D0S_LOTECT,
								SD1.D1_NUMLOTE,
								D0S.D0S_QUANT
						FROM %Table:D0S% D0S
						INNER JOIN %Table:D0R% D0R 
						ON D0R.D0R_FILIAL = %xFilial:D0R%
						AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT
						AND D0R.%NotDel%
						INNER JOIN %Table:D0Q% D0Q
						ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
						AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
						AND D0Q.%NotDel%
						INNER JOIN %Table:SD1% SD1
						ON SD1.D1_FILIAL = %xFilial:SD1%
						AND SD1.D1_NUMSEQ = D0Q.D0Q_NUMSEQ
						AND SD1.%NotDel%
						WHERE D0S.D0S_FILIAL = %xFilial:D0S%
						AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
						AND D0S.%NotDel%
					EndSql
					aTamSX3 := TamSx3("D0S_QUANT"); TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
					If (cAliasQry)->(!Eof())
						Do While lRet .And. (cAliasQry)->(!Eof())
							// Realiza os estorno da quantidade entrada prevista
							oEstEnder:ClearData()
							oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
							oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
							oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
							oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0S_PRDORI)
							oEstEnder:oProdLote:SetProduto((cAliasQry)->D0S_CODPRO)
							oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0S_LOTECT)
							oEstEnder:oProdLote:SetNumLote((cAliasQry)->D1_NUMLOTE)
							oEstEnder:SetIdUnit("") // Picking não controla unitizador
							oEstEnder:SetTipUni("") // Picking não controla unitizador
							oEstEnder:SetQuant((cAliasQry)->D0S_QUANT)
							// Diminui entrada prevista
							If Self:oMovServic:GetTipo() $ "1|2|3"
								oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
								oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
								If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
									Self:cErro := oEstEnder:GetErro()
									lRet := .F.
								EndIf
							EndIf
							// Diminui saida prevista
							If lRet .And. (Self:oMovServic:GetTipo() == "2" .Or. (Self:oMovServic:GetTipo() == "3" .And. (Self:oOrdServ:ChkMovEst(.F.) .Or. !Self:ChkEndD0F())) )
								oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
								oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
								oEstEnder:SetIdUnit(Self:GetIdUnit())
								oEstEnder:SetTipUni((cAliasQry)->D0R_CODUNI)
								If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
									Self:cErro := oEstEnder:GetErro()
									lRet := .F.
								EndIf
							EndIf
							(cAliasQry)->(DbSkip())
						EndDo
					Else
						Self:cErro := WmsFmtMsg(STR0020,{{"[VAR01]",Self:GetIdUnit()}}) // Não foi encontrado o saldo dos produtos recebidos no unitizador [VAR01].
						lRet := .F.
					EndIf
					(cAliasQry)->(DbCloseArea())
				EndIf
			Else
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT D14.D14_CODUNI,
							D14.D14_PRDORI,
							D14.D14_PRODUT,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_NUMSER,
							D14.D14_QTDEPR
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:Self:GetUniDes()%
					AND D14.D14_LOCAL  = %Exp:Self:oMovEndDes:GetArmazem()%
					AND D14.D14_ENDER  = %Exp:Self:oMovEndDes:GetEnder()%
					AND D14.D14_QTDEPR > 0
					AND D14.%NotDel%
				EndSql
				aTamSX3 := TamSx3("D14_QTDEPR"); TcSetField(cAliasQry,'D14_QTDEPR','N',aTamSX3[1],aTamSX3[2])
				If (cAliasQry)->(!Eof())
					Do While lRet .And. (cAliasQry)->(!Eof())
						// Realiza os estorno da quantidade entrada prevista
						oEstEnder:ClearData()
						oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
						oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
						oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
						oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)
						oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)
						oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)
						oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)
						oEstEnder:oProdLote:SetNumSer((cAliasQry)->D14_NUMSER)
						// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
						If Self:DesNotUnit()
							oEstEnder:SetIdUnit("")
						Else
							If Self:oMovServic:ChkTransf()
								oEstEnder:SetIdUnit(Self:GetUniDes())
							Else
								oEstEnder:SetIdUnit(Self:GetIdUnit())
							EndIf
						EndIf
						oEstEnder:SetQuant((cAliasQry)->D14_QTDEPR)
						// Diminui entrada prevista
						If (Self:oMovServic:ChkSepara() .And. !Self:oOrdServ:ChkMovEst()) .Or. (!Self:oMovServic:ChkSepara() .And. !Self:oOrdServ:ChkMovEst(.F.)) .Or.  Self:oMovServic:ChkReabast() .Or. Self:oMovServic:ChkTransf()
							If Self:oMovServic:GetTipo() $ "1|2|3"
								oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
								oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
								If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
									Self:cErro := oEstEnder:GetErro()
									lRet := .F.
								EndIf
							EndIf
							// Diminui saida prevista
							If lRet .And. !Self:oMovServic:ChkTransf() .And. (Self:oMovServic:GetTipo() == "2" .Or. Self:oMovServic:ChkReabast() .Or. (Self:oMovServic:GetTipo() == "3" .And. (Self:oOrdServ:ChkMovEst(.F.) .Or. !Self:ChkEndD0F())))
								oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
								oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
								If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
									Self:cErro := oEstEnder:GetErro()
									lRet := .F.
								EndIf
							EndIf
						EndIf
						(cAliasQry)->(DbSkip())
					EndDo
				Else
					Self:cErro := WmsFmtMsg(STR0019,{{"[VAR01]",Self:GetIdUnit()}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
					lRet := .F.
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf
		Else
			// Realiza os estorno da quantidade entrada prevista
			oEstEnder:ClearData()
			oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
			oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
			oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
			oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
			oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
			oEstEnder:oProdLote:SetNumSer(Self:oMovPrdLot:GetNumSer())
			// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
			If Self:DesNotUnit()
				oEstEnder:SetIdUnit("")
			Else
				oEstEnder:SetIdUnit(Self:GetUniDes())
			EndIf
			oEstEnder:SetQuant(oRelacMov:GetQuant())
			// Diminui entrada prevista
			If (Self:oMovServic:ChkSepara() .And. !Self:oOrdServ:ChkMovEst()) .Or. (!Self:oMovServic:ChkSepara() .And. !Self:oOrdServ:ChkMovEst(.F.)) .Or.  Self:oMovServic:ChkReabast() .Or. Self:oMovServic:ChkTransf()
				If Self:oMovServic:GetTipo() $ "1|2|3"
					oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
					If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
						Self:cErro := oEstEnder:GetErro()
						lRet := .F.
					EndIf
				EndIf
				// Diminui saida prevista
				If lRet .And. !Self:oMovServic:ChkTransf() .And. (Self:oMovServic:GetTipo() == "2" .Or. Self:oMovServic:ChkReabast() .Or. (Self:oMovServic:GetTipo() == "3" .And. (Self:oOrdServ:ChkMovEst(.F.) .Or. !Self:ChkEndD0F())) )
					oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
					// Caso endereço origem seja um picking ou produção, limpa o unitizador destino do movimento
					If Self:oMovEndOri:GetTipoEst() == 2 .Or. Self:oMovEndOri:GetTipoEst() == 7 
						oEstEnder:SetIdUnit("")
					Else
						oEstEnder:SetIdUnit(Self:GetIdUnit())
					EndIf
					If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
						Self:cErro := oEstEnder:GetErro()
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	If lRet
		oRelacMov:DeleteDCR()
		If QtdComp(Self:GetQtdMov() - oRelacMov:GetQuant()) == QtdComp(0)
			Self:DeleteD12()
		Else
			If !Self:ReverseAgl(oRelacMov)
				Self:cErro := Self:GetErro()
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet

METHOD GeraMovto() CLASS WMSDTCMovimentosServicoArmazem
Local lRet := .T.
	WmsConout('GeraMovto - Inicio')
	//Realiza entradas e saídas previstas
	If (Self:oMovServic:ChkRecebi().Or. Self:oMovServic:ChkTransf())
		lRet := Self:MakeInput()
	Else
		If (lRet := Self:MakeOutput())
			lRet := Self:MakeInput()
		EndIf
	EndIF
	// Carregas as exceções das atividades
	Self:oMovEndOri:ExceptEnd()
	Self:oMovEndDes:ExceptEnd()
	// Gera movimentos WMS
	If lRet .And. !Self:AssignD12()
		lRet := .F.
	EndIf
	WmsConout('GeraMovto - Fim')
Return lRet

METHOD ReproRegra() CLASS WMSDTCMovimentosServicoArmazem
Local lRet      := .T.
Local aAreaD12  := D12->(GetArea())
Local oRegraConv:= WMSBCCRegraConvocacao():New()
Local cAliasD12 := GetNextAlias()
	oRegraConv:IniArrLib()
	BeginSql Alias cAliasD12
		SELECT D12.D12_LOCORI,
				D12.D12_SERVIC,
				D12.D12_ORDTAR,
				D12.D12_STATUS,
				D12.R_E_C_N_O_ RECNOD12
		FROM %Table:D12% D12
		WHERE D12_FILIAL = %xFilial:D12%
		AND D12_DOC = %Exp:Self:oOrdServ:GetDocto()%
		AND D12_SERIE = %Exp:Self:oOrdServ:GetSerie()%
		AND D12_CLIFOR = %Exp:Self:oOrdServ:GetCliFor()%
		AND D12_LOJA = %Exp:Self:oOrdServ:GetLoja()%
		AND D12_STATUS IN ('-','4','2') //3=Em Execução;4=A Executar
		AND D12.%NotDel%
	EndSql
	Do While (cAliasD12)->(!Eof())
		AAdd(oRegraConv:GetArrLib(),{IIf((cAliasD12)->D12_STATUS == '-','3',(cAliasD12)->D12_STATUS),(cAliasD12)->RECNOD12,(cAliasD12)->D12_LOCORI,(cAliasD12)->D12_SERVIC,""})
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(dbCloseArea())
	If !Empty(oRegraConv:GetArrLib())
		oRegraConv:LawExecute()
	EndIF
	RestArea(aAreaD12)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} SldBlq
Calcula quantidade bloqueda para o produto ou lote
@author amanda.vieira
@since 28/11/2019
@version 1.0
@version 1.0
/*/
//--------------------------------------------------
METHOD SldBlq(cLocal,cProduto,cLoteCtl,cNumLote) CLASS WMSDTCMovimentosServicoArmazem
Local cAliasSDD := GetNextAlias()
Local cWhere    := ""
Local nQtdBlq   := 0
	cWhere := "%"
	If !Empty(cLoteCtl)
		cWhere += " AND SDD.DD_LOTECTL = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND SDD.DD_NUMLOTE = '"+cNumLote+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasSDD
		SELECT SUM(SDD.DD_QUANT) DD_QUANT
		  FROM %Table:SDD% SDD
		 WHERE SDD.DD_FILIAL = %xFilial:SDD%
		   AND SDD.DD_PRODUTO = %Exp:cProduto%
		   AND SDD.DD_LOCAL = %Exp:cLocal%
		   AND SDD.%NotDel%
		   %Exp:cWhere%
	EndSql
	If (cAliasSDD)->(!EoF())
		nQtdBlq := (cAliasSDD)->DD_QUANT
	EndIf
	(cAliasSDD)->(DbCloseArea())
Return nQtdBlq
//--------------------------------------------------
/*/{Protheus.doc} RegMovAglu
Registra array com movimentos aglutinados à D12 carregada no objeto
@author amanda.vieira
@since 05/06/2020
/*/
//--------------------------------------------------
METHOD RegMovAglu() CLASS WMSDTCMovimentosServicoArmazem
Local cAliasDCR := GetNextAlias()
Local cWhere    := ""

	Self:aMovAglu := {}

	cWhere := "%"
	If WmsX312118("D12","D12_IDUNIT")
		cWhere += " AND D12.D12_IDUNIT = '"+Self:cIdUnitiz+"'"
	EndIf
	cWhere += "%"

	BeginSql Alias cAliasDCR
		SELECT DCR.DCR_IDDCF,
			   DCR.DCR_SEQUEN,
			   DCR.DCR_QUANT, 
			   DCR.DCR_QTSEUM
		  FROM %Table:DCR% DCR
		 INNER JOIN %Table:D12% D12
		    ON D12.D12_FILIAL = %xFilial:D12%
		   AND D12.D12_IDDCF = DCR.DCR_IDORI 
		   AND D12.D12_IDMOV = DCR.DCR_IDMOV
		   AND D12.D12_IDOPER = DCR.DCR_IDOPER
		   AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
		   AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
		   AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
		   AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
		   AND D12.D12_STATUS <> '0'
		   AND D12.%NotDel%
		   %Exp:cWhere%
		 WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		   AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
		   AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
		   AND DCR.%NotDel%
	EndSql
	WmsConout('RegMovAglu - ' + GetLastQuery()[2])
	While (cAliasDCR)->(!EoF())
			WmsConout('RegMovAglu - ' + (cAliasDCR)->DCR_IDDCF + ' / ' + (cAliasDCR)->DCR_SEQUEN + ' / ' + cValToChar((cAliasDCR)->DCR_QUANT))
			Aadd(Self:aMovAglu,{(cAliasDCR)->DCR_IDDCF,(cAliasDCR)->DCR_SEQUEN,(cAliasDCR)->DCR_QUANT,(cAliasDCR)->DCR_QTSEUM})
		(cAliasDCR)->(DbSkip())
	EndDo
	(cAliasDCR)->(DbCloseArea())
Return
//--------------------------------------------------
/*/{Protheus.doc} EstMovComp
Estorna movimentação (D12) completa.
Trata-se de uma cópia do método EstMovto, a diferença é que não estorna apenas o Id DCF aglutinador e 
também não realiza o processo de desfazer a aglutinação do movimento.
@author amanda.vieira
@since 05/06/2020
/*/
//--------------------------------------------------
METHOD EstMovComp() CLASS WMSDTCMovimentosServicoArmazem
Local lRet       := .T.
Local lEmpPrev   := .F.
Local aTamSX3    := {}
Local oEstEnder  := Self:oEstEnder // Para facilitar o apontamento do objeto
Local oRelacMov  := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local cAliasQry  := Nil
Local cAliasDCR  := Nil
Local cWhere     := ""

	cWhere := "%"
	If WmsX312118("D12","D12_IDUNIT")
		cWhere += " AND D12.D12_IDUNIT = '"+Self:cIdUnitiz+"'"
	EndIf
	cWhere += "%"

	cAliasDCR := GetNextAlias()
	BeginSql Alias cAliasDCR
		SELECT DCR.R_E_C_N_O_ RECNODCR,
			   D12.D12_ATUEST
		  FROM %Table:DCR% DCR
		 INNER JOIN %Table:D12% D12
		    ON D12.D12_FILIAL = %xFilial:D12%
		   AND D12.D12_IDDCF = DCR.DCR_IDORI 
		   AND D12.D12_IDMOV = DCR.DCR_IDMOV
		   AND D12.D12_IDOPER = DCR.DCR_IDOPER
		   AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
		   AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
		   AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
		   AND D12.D12_NUMSER = %Exp:Self:oMovPrdLot:GetNumSer()%
		   AND D12.D12_STATUS <> '0'
		   AND D12.%NotDel%
		   %Exp:cWhere%
		 WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		   AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
		   AND DCR.DCR_IDMOV = %Exp:Self:cIdMovto%
		   AND DCR.DCR_IDOPER = %Exp:Self:cIdOpera%
		   AND DCR.%NotDel%
	EndSql
	WmsConout('EstMovComp - ' + GetlastQuery()[2])
	While (cAliasDCR)->(!EoF())
		oRelacMov:GoToDCR((cAliasDCR)->RECNODCR)
		WmsConout('EstMovComp - RecnoDCR ' + cValToChar((cAliasDCR)->RECNODCR))
		If lRet .And. (cAliasDCR)->D12_ATUEST == "1"
			lEmpPrev := Self:oMovServic:ChkSepara()
			If Self:IsMovUnit()
				// Se for uma transferência de estorno de endereçamento e a origem for um picking
				// Não possui saldo por unitizador, neste caso deve carregar o saldo inicial do unitizador
				If Self:oMovServic:ChkRecebi() .And. Self:oMovEndDes:GetTipoEst() == 2
					If !Empty(Self:oMovEndDes:GetEnder())
						cAliasQry := GetNextAlias()
						BeginSql Alias cAliasQry
							SELECT D0R.D0R_CODUNI,
								   D0S.D0S_PRDORI,
								   D0S.D0S_CODPRO,
								   D0S.D0S_LOTECT,
								   SD1.D1_NUMLOTE,
								   D0S.D0S_QUANT
							 FROM %Table:D0S% D0S
							INNER JOIN %Table:D0R% D0R 
							   ON D0R.D0R_FILIAL = %xFilial:D0R%
							  AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT
							  AND D0R.%NotDel%
							INNER JOIN %Table:D0Q% D0Q
							   ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
							  AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
							  AND D0Q.%NotDel%
							INNER JOIN %Table:SD1% SD1
							   ON SD1.D1_FILIAL = %xFilial:SD1%
							  AND SD1.D1_NUMSEQ = D0Q.D0Q_NUMSEQ
							  AND SD1.%NotDel%
							WHERE D0S.D0S_FILIAL = %xFilial:D0S%
							  AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
							  AND D0S.%NotDel%
						EndSql
						aTamSX3 := TamSx3("D0S_QUANT"); TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
						If (cAliasQry)->(!Eof())
							Do While lRet .And. (cAliasQry)->(!Eof())
								// Realiza os estorno da quantidade entrada prevista
								oEstEnder:ClearData()
								oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
								oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
								oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
								oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0S_PRDORI)
								oEstEnder:oProdLote:SetProduto((cAliasQry)->D0S_CODPRO)
								oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0S_LOTECT)
								oEstEnder:oProdLote:SetNumLote((cAliasQry)->D1_NUMLOTE)
								oEstEnder:SetIdUnit("") // Picking não controla unitizador
								oEstEnder:SetTipUni("") // Picking não controla unitizador
								oEstEnder:SetQuant((cAliasQry)->D0S_QUANT)
								// Diminui entrada prevista
								If Self:oMovServic:GetTipo() $ "1|2|3"
									oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
									oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
									If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
										Self:cErro := oEstEnder:GetErro()
										lRet := .F.
									EndIf
								EndIf
								// Diminui saida prevista
								If lRet .And. (Self:oMovServic:GetTipo() == "2" .Or. (Self:oMovServic:GetTipo() == "3" .And. (Self:oOrdServ:ChkMovEst(.F.) .Or. !Self:ChkEndD0F())) )
									oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
									oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
									oEstEnder:SetIdUnit(Self:GetIdUnit())
									oEstEnder:SetTipUni((cAliasQry)->D0R_CODUNI)
									If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
										Self:cErro := oEstEnder:GetErro()
										lRet := .F.
									EndIf
								EndIf
								(cAliasQry)->(DbSkip())
							EndDo
						Else
							Self:cErro := WmsFmtMsg(STR0020,{{"[VAR01]",Self:GetIdUnit()}}) // Não foi encontrado o saldo dos produtos recebidos no unitizador [VAR01].
							lRet := .F.
						EndIf
						(cAliasQry)->(DbCloseArea())
					EndIf
				Else
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT D14.D14_CODUNI,
								D14.D14_PRDORI,
								D14.D14_PRODUT,
								D14.D14_LOTECT,
								D14.D14_NUMLOT,
								D14.D14_NUMSER,
								D14.D14_QTDEPR
						FROM %Table:D14% D14
						WHERE D14.D14_FILIAL = %xFilial:D14%
						AND D14.D14_IDUNIT = %Exp:Self:GetUniDes()%
						AND D14.D14_LOCAL  = %Exp:Self:oMovEndDes:GetArmazem()%
						AND D14.D14_ENDER  = %Exp:Self:oMovEndDes:GetEnder()%
						AND D14.D14_QTDEPR > 0
						AND D14.%NotDel%
					EndSql
					aTamSX3 := TamSx3("D14_QTDEPR"); TcSetField(cAliasQry,'D14_QTDEPR','N',aTamSX3[1],aTamSX3[2])
					If (cAliasQry)->(!Eof())
						Do While lRet .And. (cAliasQry)->(!Eof())
							// Realiza os estorno da quantidade entrada prevista
							oEstEnder:ClearData()
							oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
							oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
							oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
							oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)
							oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)
							oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)
							oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)
							oEstEnder:oProdLote:SetNumSer((cAliasQry)->D14_NUMSER)
							// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
							If Self:DesNotUnit()
								oEstEnder:SetIdUnit("")
							Else
								If Self:oMovServic:ChkTransf()
									oEstEnder:SetIdUnit(Self:GetUniDes())
								Else
									oEstEnder:SetIdUnit(Self:GetIdUnit())
								EndIf
							EndIf
							oEstEnder:SetQuant((cAliasQry)->D14_QTDEPR)
							// Diminui entrada prevista
							If (Self:oMovServic:ChkSepara() .And. !Self:oOrdServ:ChkMovEst()) .Or. (!Self:oMovServic:ChkSepara() .And. !Self:oOrdServ:ChkMovEst(.F.)) .Or.  Self:oMovServic:ChkReabast() .Or. Self:oMovServic:ChkTransf()
								If Self:oMovServic:GetTipo() $ "1|2|3"
									oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
									oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
									If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
										Self:cErro := oEstEnder:GetErro()
										lRet := .F.
									EndIf
								EndIf
								// Diminui saida prevista
								If lRet .And. !Self:oMovServic:ChkTransf() .And. (Self:oMovServic:GetTipo() == "2" .Or. Self:oMovServic:ChkReabast() .Or. (Self:oMovServic:GetTipo() == "3" .And. (Self:oOrdServ:ChkMovEst(.F.) .Or. !Self:ChkEndD0F())))
									oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
									oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
									If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
										Self:cErro := oEstEnder:GetErro()
										lRet := .F.
									EndIf
								EndIf
							EndIf
							(cAliasQry)->(DbSkip())
						EndDo
					Else
						Self:cErro := WmsFmtMsg(STR0019,{{"[VAR01]",Self:GetIdUnit()}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
						lRet := .F.
					EndIf
					(cAliasQry)->(DbCloseArea())
				EndIf
			Else
				// Realiza os estorno da quantidade entrada prevista
				oEstEnder:ClearData()
				oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
				oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
				oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
				oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
				oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
				oEstEnder:oProdLote:SetNumSer(Self:oMovPrdLot:GetNumSer())
				// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unitizador destino do movimento
				If Self:DesNotUnit()
					oEstEnder:SetIdUnit("")
				Else
					oEstEnder:SetIdUnit(Self:GetUniDes())
				EndIf
				oEstEnder:SetQuant(oRelacMov:GetQuant())
				// Diminui entrada prevista
				If (Self:oMovServic:ChkSepara() .And. !Self:oOrdServ:ChkMovEst()) .Or. (!Self:oMovServic:ChkSepara() .And. !Self:oOrdServ:ChkMovEst(.F.)) .Or.  Self:oMovServic:ChkReabast() .Or. Self:oMovServic:ChkTransf()
					If Self:oMovServic:GetTipo() $ "1|2|3"
						oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
						oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
						If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
							Self:cErro := oEstEnder:GetErro()
							lRet := .F.
						EndIf
					EndIf
					// Diminui saida prevista
					If lRet .And. !Self:oMovServic:ChkTransf() .And. (Self:oMovServic:GetTipo() == "2" .Or. Self:oMovServic:ChkReabast() .Or. (Self:oMovServic:GetTipo() == "3" .And. (Self:oOrdServ:ChkMovEst(.F.) .Or. !Self:ChkEndD0F())) )
						oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
						oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
						// Caso endereço origem seja um picking ou produção, limpa o unitizador destino do movimento
						If Self:oMovEndOri:GetTipoEst() == 2 .Or. Self:oMovEndOri:GetTipoEst() == 7 
							oEstEnder:SetIdUnit("")
						Else
							oEstEnder:SetIdUnit(Self:GetIdUnit())
						EndIf
						If !oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
							Self:cErro := oEstEnder:GetErro()
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet
			oRelacMov:DeleteDCR()
		EndIf
		(cAliasDCR)->(DbSkip())
	EndDo
	(cAliasDCR)->(DbCloseArea())
	If lRet
		Self:DeleteD12()
	EndIf
	WmsConout('WmsEstComp ' + Self:cErro)
	If lRet
		WmsConout('WmsEstComp Verdadeiro')
	else
		WmsConout('WmsEstComp Falso')
	EndIf
		
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} WmsMetrMov
Este methodo tem pos funcionalidade buscar quantidade de produtos recebidos 
e expedidos através da tela de movimentação do coletor e monitor de servicos.
@author roselaine.adriano
@since 20/03/2023
/*/
//--------------------------------------------------
METHOD WmsMetrMov() CLASS WMSDTCMovimentosServicoArmazem
Local lSomaMetr := .T.
Local cAliasQry := Nil 

	If !Self:oMovServic:ChkSepara() .AND. !Self:oMovServic:ChkRecebi()
		Return 
	EndIf

	//validar se existe estorno para o movimento 
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DISTINCT 1
		FROM %Table:D12% D12
        WHERE D12.D12_FILIAL = %xFilial:D12%
        AND D12.D12_IDDCF = %Exp:Self:oOrdServ:GetIdDCF()%
        AND D12_STATUS = '0'
		AND %NotDel%
	ENDSQL
	If (cAliasQry)->(!Eof())
		lSomaMetr := .F.  
	EndIf 
	(cAliasQry)->(DbCloseArea())
	
	If lSomaMetr .AND. (Self:oMovEndDes:GetArmazem() == SuperGetMv("MV_CQ",.F.,"98"))
		lSomaMetr := .F. 
	EndIf 

	If lSomaMetr 
		If Self:oMovServic:ChkSepara()   
			//If Self:cBxEsto <> "1" //.AND. Self:oMovEndDes:GetTipoEst() <> 7 .AND.  Self:oMovEndDes:GetTipoEst() <> 5 //Produção ou DOCA e mao baixa estoque 
			If Self:cBxEsto <> "1" .AND.  Self:oMovEndDes:GetTipoEst() <> 5 //DOCA e baixa estoque 
				lSomaMetr := .F. 
			EndIf 
		EndIf
	EndIf

	If lSomaMetr .AND. Self:oMovServic:ChkSepara()
	    If Self:nQtdMovto2 > 0 
			Self:nMetricExp += Self:nQtdMovto2
		ELSE
			Self:nMetricExp += Self:nQtdMovto
		ENDIF
	ELSE
		If lSomaMetr .AND. Self:oMovServic:ChkRecebi()
			If Self:nQtdMovto2 > 0 
				Self:nMetricRec += Self:nQtdMovto2	
			else
				Self:nMetricRec += Self:nQtdMovto
			ENDIF
		endIf
	EndIf			
Return


/*/{Protheus.doc} WmsAgLotC9
	Executada pela UpdPedido. Quando chamada, o usuário está alterando o lote do movimento.
	O metodo WmsAgLotC9, tem o objeto de informar se existe outra SC9 que pode ser aglutinada.
	A outra SC9 precisa ter o mesmo Pedido, Lote, Sublote, Endereco e somente a sequencia pode ser diferente.
	A regra funciona apenas para separacao com lotes diferentes, no mesmo endereço e um lote foi alterado para o mesmo de outra movimentação.
	Deve ser uma separação com montagem de volumes.
	@type METHOD
	@author Equipe WMS
	@since 30/04/2024
	@param nRecno, numerico, recno da SC9 atual que está sendo alterado lote
	@param cLote, caracter, novo lote da SC9 atual
	@param cSub, caracter, nvo sublote da SC9 atual
	@return lRet, logical, existe outra SC9 que pode ser aglutinada
	@see (DLOGWMSMSP-16237)
	/*/
METHOD WmsAgLotC9(nRecno, cLote, cSub) CLASS WMSDTCMovimentosServicoArmazem
	Local cAliasSC9 := Nil
	Local lRet		:= .F.
	Local aArea		:= GetArea()

	If Self:oMovServic:ChkSepara() .And. Self:oMovServic:ChkMntVol() .And.;
		(Self:oMovPrdLot:GetLoteCtl() <> cLote .Or. Self:oMovPrdLot:GetNumLote() <> cSub)

		cAliasSC9 := GetNextAlias()
		BeginSql Alias cAliasSC9
			SELECT DISTINCT SC9.R_E_C_N_O_ RECNOSC9
				FROM %Table:DCR% DCR
				INNER JOIN %Table:D12% D12
					ON D12.%NotDel%
					AND D12.D12_FILIAL = %xFilial:D12%
					AND D12.D12_IDDCF = DCR.DCR_IDORI
					AND D12.D12_IDMOV = DCR.DCR_IDMOV
					AND D12.D12_IDOPER = DCR.DCR_IDOPER
					AND D12.D12_ATUEST = '1'
					AND D12.D12_STATUS <> '0'
					AND D12.D12_ORIGEM = 'SC9'
				INNER JOIN %Table:SC9% SC9
					ON SC9.%NotDel%
					AND SC9.C9_IDDCF = DCR.DCR_IDDCF
					AND SC9.C9_FILIAL = %Exp:SC9->C9_FILIAL%
					AND SC9.C9_PEDIDO = %Exp:SC9->C9_PEDIDO%
					AND SC9.C9_ITEM   = %Exp:SC9->C9_ITEM%
			WHERE DCR.%NotDel%
				AND DCR.DCR_FILIAL = %xFilial:DCR%
				AND SC9.C9_LOTECTL = %Exp:SC9->C9_LOTECTL%
				AND SC9.C9_NUMLOTE = %Exp:SC9->C9_NUMLOTE%
				AND SC9.C9_BLEST   = %Exp:SC9->C9_BLEST%
				AND SC9.C9_BLCRED  = %Exp:SC9->C9_BLCRED%
				AND SC9.C9_IDDCF   = %Exp:SC9->C9_IDDCF%
				AND SC9.C9_LOCAL   = %Exp:SC9->C9_LOCAL%
				AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
				AND D12.D12_ENDORI = %Exp:Self:oMovEndOri:GetEnder()%
		EndSql
		Do While (cAliasSC9)->(!EoF())
			If (cAliasSC9)->RECNOSC9 != nRecno
				lRet := .T.
				Exit
			EndIf
			(cAliasSC9)->(DbSkip())
		EndDo
		(cAliasSC9)->(DbCloseArea())
	EndIf
	RestArea(aArea)
Return lRet

