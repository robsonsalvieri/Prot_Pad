#Include "Totvs.ch"
#Include "WMSDTCOrdemServico.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0029
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0029()
Return Nil
//----------------------------------------
/*/{Protheus.doc} WMSDTCOrdemServico
Classe ordem de serviço
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//----------------------------------------
CLASS WMSDTCOrdemServico FROM LongNameClass
	// Data
	DATA lHasUniDes // Utilizado para suavizar o campo DCF_UNIDES
	DATA lHasCodUni // Utilizado para suavizar o campo D14_CODUNI
	DATA lHasIdMvOr // Utilizado para suavizar o campo DCF_IDMVOR
	DATA lHasHora   // Utilizado para suavizar o campo DCF_HORA
	DATA oProdLote
	DATA oOrdEndOri
	DATA oOrdEndDes
	DATA oServico
	DATA cDocumento
	DATA cSerieDoc
	DATA cSerie
	DATA cCliFor
	DATA cLoja
	DATA cOrigem
	DATA cNumSeq
	DATA nQuant
	DATA nQuant2
	DATA nQtdOri
	DATA nQtdDel
	DATA dData
	DATA cHora
	DATA cStServ
	DATA cRegra
	DATA cPriori
	DATA cCodFun
	DATA cCarga
	DATA cIdUnitiz
	DATA cUniDes
	DATA cTipUni
	DATA cCodNorma
	DATA cStRadi
	DATA cIdDCF
	DATA cSequen
	DATA cTipReab
	DATA cCodRec
	DATA cIdOrigem
	DATA cDocPen
	DATA cOk
	DATA aWmsAviso AS array
	DATA aLibD12   AS array
	DATA aLibDCF   AS array // Ordens de serviço criadas e liberadas para execução automatica
	DATA aOrdReab  AS Array // Ordens de serviço de reabastecimento de complemento para estorno
	DATA lLogSld
	DATA lLogEnd
	DATA lLogEndUni
	DATA lForceDtHr
	DATA lGeraNovoId
	DATA nRecno
	DATA cErro
	DATA cSeqPriExe
	DATA cCodPln
	DATA cOp
	DATA cTrt
	DATA nProduto
	DATA nTarefa
	DATA cCodMntVol
	DATA cCodDisSep
	DATA cConfExped
	DATA cIdMovOrig
	// Controle dados anteriores
	DATA cServicAnt
	DATA cDoctoAnt
	DATA cIdDCFAnt
	DATA lHasPrdPul
	DATA lHasPRdPkg
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToDCF(nRecno)
	METHOD LockDCF()
	METHOD UnLockDCF()
	METHOD LoadData(nIndex)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetSequen(cSequen)
	METHOD SetIdOrig(cIdOrigem)
	METHOD SetNumSeq(cNumSeq)
	METHOD SetDocto(cDocumento)
	METHOD SetSerie(cSerie)
	METHOD SetCliFor(cCliFor)
	METHOD SetLoja(cLoja)
	METHOD SetServico(cServico)
	METHOD SetStServ(cStServ)
	METHOD SetOrigem(cOrigem)
	METHOD SetCarga(cCarga)
	METHOD SetCodRec(cCodRec)
	METHOD SetQuant(nQuant)
	METHOD SetOk(cOk)
	METHOD SetRegra(cRegra)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetArrLib(aLibD12)
	METHOD SetData(dData)
	METHOD SetHora(cHora)
	METHOD SetCodPln(cCodPln)
	METHOD SetIdUnit(cIdUnit)
	METHOD SetUniDes(cUniDes)
	METHOD SetTipUni(cTipUni)
	METHOD SetIdMovOr(cIdMovOrig)
	METHOD SetTipReab(cTipReab)
	METHOD SetOp(cOp)
	METHOD SetTrt(cTrt)
	METHOD GetIdDCF()
	METHOD GetSequen()
	METHOD GetIdOrig()
	METHOD GetNumSeq()
	METHOD GetDocto()
	METHOD GetSerie()
	METHOD GetCliFor()
	METHOD GetLoja()
	METHOD GetServico()
	METHOD GetStServ()
	METHOD GetOrigem()
	METHOD GetCodNor()
	METHOD GetCarga()
	METHOD GetCodRec()
	METHOD GetQuant()
	METHOD GetQuant2()
	METHOD GetOk()
	METHOD GetRegra()
	METHOD GetRecNo()
	METHOD GetQtdOri()
	METHOD GetArrLib()
	METHOD GetData()
	METHOD GetHora()
	METHOD GetDocPen()
	METHOD GetErro()
	METHOD GetCodPln()
	METHOD GetIdUnit()
	METHOD GetUniDes()
	METHOD GetTipUni()
	METHOD GetIdMovOr()
	METHOD GetTipReab()
	METHOD GetOp()
	METHOD GetTrt()
	METHOD ExcludeDCF()
	METHOD CancelDCF()
	METHOD RecordDCF()
	METHOD UpdateDCF(lMsUnLock)
	METHOD UpdAgluDCF(aFields,lMsUnLock)
	METHOD UpdStatus()
	METHOD UpdAgluSta(cStatus)
	METHOD UndoIntegr()
	METHOD UpdIntegra()
	METHOD UpdServic()
	METHOD CancelSC9(lEstPed,nRecnoSC9,nQtdQuebra,lPedFat)
	METHOD HaveMovD12(cAcao)
	METHOD MakeArmaz()
	METHOD UndoArmaz()
	METHOD ReverseMA()
	METHOD ReverseMI(nQtdEst)
	METHOD ReverseMO(nQtdEst)
	METHOD MakeOutput()
	METHOD MakeInput()
	METHOD SaiMovEst()
	METHOD EstOpTotal()
	METHOD ChkOrdDep()
	METHOD ChkDepPend(cIdDCF)
	METHOD FindDocto()
	METHOD ExisteDCF()
	METHOD UpdEndDCF(cEndereco,lEndVazio)
	METHOD ChkDistr()
	METHOD ShowWarnig()
	METHOD HasLogEnd()
	METHOD HasLogSld()
	METHOD HasLogUni()
	METHOD ForceDtHr()
	METHOD AtuMovSD3()
	METHOD MovSD3Estr(lMontagem)
	METHOD MovSD3Prod()
	METHOD MovSD3Lote()
	METHOD UndoMovSD3()
	METHOD UpdEmpSD4(lEstorno)
	METHOD UpdEmpSB2(cOper,cPrdOri,cArmazem,nQuant,lReserva,cTipOp)
	METHOD UpdEmpSB8(cOper,cPrdOri,cArmazem,cLoteCtl,cNumLote,nQuant)
	METHOD Destroy()
	METHOD GetSeqPri()
	METHOD FindSeqPri()
	METHOD FindDCFOri()
	METHOD NextSeqPri(cParametro, cField)
	METHOD EstParcial(nRecnoSC9,nQtdQuebra,lPedLib)
	METHOD ChkOrdReab()
	METHOD ChkQtdRes()
	METHOD ChkMovEst(lEndOri)
	METHOD CanEstReab()
	METHOD IsMovUnit()
	METHOD HasPrdPul()
	METHOD HasPrdPkg()
	METHOD GeraNovoId(lGeraNovoId)
	METHOD VldGrvOS(cMessError, aOSAglu, nQtdeAnt, nRecnoAtu)	
ENDCLASS
//----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD New() CLASS WMSDTCOrdemServico
	Self:lHasUniDes := WmsX312118("DCF","DCF_UNIDES")
	Self:lHasCodUni := WmsX312118("D14","D14_CODUNI")
	Self:lHasIdMvOr := WmsX312118("DCF","DCF_IDMVOR")
	Self:lHasHora   := WmsX312123("DCF","DCF_HORA")
	Self:oProdLote  := WMSDTCProdutoLote():New()
	Self:oOrdEndOri := WMSDTCEndereco():New()
	Self:oOrdEndDes := WMSDTCEndereco():New()
	Self:oServico   := WMSDTCServicoTarefa():New()
	// Atribui demais campos
	Self:cIdDCF     := PadR("", TamSx3("DCF_ID")[1])
	Self:cDocumento := PadR("", TamSx3("DCF_DOCTO")[1])
	Self:cSerieDoc  := PadR("", TamSx3("DCF_SERIE")[1]) // DCF->DCF_SDOC
	Self:cSerie     := PadR("", TamSx3("DCF_SERIE")[1])
	Self:cCliFor    := PadR("", TamSx3("DCF_CLIFOR")[1])
	Self:cLoja      := PadR("", TamSx3("DCF_LOJA")[1])
	Self:cOrigem    := PadR("", TamSx3("DCF_ORIGEM")[1])
	Self:cIdOrigem  := PadR("", TamSx3("DCF_IDORI")[1])
	Self:cNumSeq    := PadR("", TamSx3("DCF_NUMSEQ")[1])
	Self:cCodRec    := PadR("", TamSx3("DCF_CODREC")[1])
	Self:cDocPen    := PadR("", TamSx3("DCF_DOCPEN")[1])
	Self:nQtdOri    := 0
	Self:nQuant     := 0
	Self:nQuant2    := 0
	Self:nQtdDel    := 0
	Self:dData      := dDataBase
	Self:cHora      := PadR("", IIf(Self:lHasHora,TamSx3("DCF_HORA")[1],8))
	Self:cStServ    := PadR("", TamSx3("DCF_STSERV")[1])
	Self:cRegra     := PadR("", TamSx3("DCF_REGRA")[1])
	Self:cPriori    := PadR("", TamSx3("DCF_PRIORI")[1])
	Self:cCodFun    := PadR("", TamSx3("DCF_CODFUN")[1])
	Self:cCarga     := PadR("", TamSx3("DCF_CARGA")[1])
	Self:cIdUnitiz  := PadR("", TamSx3("DCF_UNITIZ")[1])
	Self:cUniDes    := PadR("", IIf(Self:lHasUniDes,TamSx3("DCF_UNIDES")[1],6))
	Self:cTipUni    := PadR("", IIf(Self:lHasCodUni,TamSx3("D14_CODUNI")[1],6))
	Self:cCodNorma  := PadR("", TamSx3("DCF_CODNOR")[1])
	Self:cStRadi    := PadR("", TamSx3("DCF_STRADI")[1])
	Self:cIdMovOrig := PadR("", IIf(Self:lHasIdMvOr,TamSx3("DCF_IDMVOR")[1],6))
	Self:cOp        := PadR("", TamSx3("D4_OP")[1])
	Self:cTrt       := PadR("", TamSx3("D4_TRT")[1])
	Self:cSequen    := "01"
	Self:cTipReab   := "D" //Demanda
	Self:aWmsAviso  := {}
	Self:aLibDCF    := {}
	Self:aOrdReab   := {}
	Self:lLogEnd    := .F.
	Self:lLogSld    := .F.
	Self:lLogEndUni := .F.
	Self:lForceDtHr := .T.
	Self:lHasPrdPul := .F.
	Self:lHasPRdPkg	:= .F.
	Self:lGeraNovoId:= .T.
	Self:cErro      := ""
	Self:nRecno     := 0
	// Controle dados anteriores
	Self:cServicAnt:= PadR("", Len(Self:oServico:GetServico()))
	Self:cDoctoAnt := PadR("", Len(Self:cDocumento))
	Self:cIdDCFAnt := PadR("", Len(Self:cIdDCF))
	Self:cSeqPriExe:= ""
	Self:nProduto  := 0
	Self:nTarefa   := 0
Return

METHOD Destroy() CLASS WMSDTCOrdemServico
	//Mantido para compatibilização
Return Nil
//----------------------------------------
/*/{Protheus.doc} HasLogEnd
Seta log de endereço
@author felipe.m
@since 23/12/2014
@version 1.0
@param lLogEnd, ${logico}, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD HasLogEnd(lLogEnd) CLASS WMSDTCOrdemServico
	If ValType(lLogEnd) == 'L'
		Self:lLogEnd := lLogEnd
	EndIf
Return Self:lLogEnd
//----------------------------------------
/*/{Protheus.doc} HasLogSld
Seta log de saldo
@author felipe.m
@since 23/12/2014
@version 1.0
@param lLogSld, ${logico}, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD HasLogSld(lLogSld) CLASS WMSDTCOrdemServico
	If ValType(lLogSld) == 'L'
		Self:lLogSld := lLogSld
	EndIf
Return Self:lLogSld
//----------------------------------------
/*/{Protheus.doc} HasLogUni
Seta log de enderecamento unitizado
@author  Guilherme A. Metzger
@since   27/04/2017
@version 1.0
/*/
//----------------------------------------
METHOD HasLogUni(lLogEndUni) CLASS WMSDTCOrdemServico
	If ValType(lLogEndUni) == 'L'
		Self:lLogEndUni := lLogEndUni
	EndIf
Return Self:lLogEndUni
//----------------------------------------
/*/{Protheus.doc} ForceDtHr
Seta log se força data e hora do sistema
@author  Squad WMS/Protheus
@since   27/08/2018
@version 1.0
/*/
//----------------------------------------
METHOD ForceDtHr(lForceDtHr) CLASS WMSDTCOrdemServico
	If ValType(lForceDtHr) == 'L'
		Self:lForceDtHr := lForceDtHr
	EndIf
Return Self:lForceDtHr
//----------------------------------------
/*/{Protheus.doc} GeraNovoId
Indica se força a geração de um novo ID.
@author  amanda.vieira
@since   02/12/2019
@version 1.0
/*/
//----------------------------------------
METHOD GeraNovoId(lGeraNovoId) CLASS WMSDTCOrdemServico
	Self:lGeraNovoId := lGeraNovoId
Return Self:lGeraNovoId
//----------------------------------------
/*/{Protheus.doc} GoToDCF
Posicionamento para atualização das propriedades
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToDCF(nRecno) CLASS WMSDTCOrdemServico
	Self:nRecno := nRecno
Return Self:LoadData(0)
//----------------------------------------
/*/{Protheus.doc} LockDCF
Prende a tabela para alteração DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD LockDCF() CLASS WMSDTCOrdemServico
Local lRet := .T.
	DCF->(dbGoTo(Self:nRecno))
	If !DCF->(SimpleLock())
		lRet := .F.
		Self:cErro := STR0002 // Lock não foi efetuado!
	Else
		Self:cStServ := DCF->DCF_STSERV
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} UnLockDCF
Libera a tabela para alteração DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UnLockDCF() CLASS WMSDTCOrdemServico
	DCF->(dbGoTo(Self:nRecno))
Return DCF->(MsUnlock())
//----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados DCF
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCOrdemServico
Local lRet        := .T.
Local lCarrega    := .T.
Local aAreaAnt    := GetArea()
Local aAreaDCF    := DCF->(GetArea())
Local aDCF_QTDORI := TamSx3("DCF_QTDORI")
Local aDCF_QUANT  := TamSx3("DCF_QUANT")
Local aDCF_QTSEUM := TamSx3("DCF_QTSEUM")
Local cCampos     := "" 
Local cAliasDCF   := Nil
	Default nIndex := 9
	Do Case
		Case nIndex == 0 // R_E_C_N_O_
		If Empty(Self:nRecno)
			lRet := .F.
		EndIf
		Case nIndex == 3 // DCF_FILIAL+DCF_SERVIC+DCF_CODPRO+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA
		If (Empty(Self:GetServico()) .Or. Empty(Self:oProdLote:GetProduto()) .Or. Empty(Self:GetDocto()))
			lRet := .F.
		Else
			If Self:GetServico() == Self:cServicAnt .And. Self:oProdLote:GetProduto() == Self:cProdutAnt .And. Self:GetDocto() == Self:cDoctoAnt
				lCarrega := .F.
			EndIf
		EndIf
		Case nIndex == 9 // DCF_FILIAL+DCF_ID
		If Empty(Self:cIdDCF)
			lRet := .F.
		Else
			If Self:cIdDCF == Self:cIdDCFAnt
				lCarrega := .F.
			EndIf
		EndIf
		Otherwise
		lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0004 // Dados para busca não foram informados!
	Else
		If lCarrega
			cAliasDCF  := GetNextAlias()
			cCampos := "%"
			cCampos += IIf(Self:lHasHora," DCF.DCF_HORA,","")
			cCampos += IIf(Self:lHasUniDes," DCF.DCF_UNIDES,","")
			cCampos += IIf(Self:lHasIdMvOr," DCF.DCF_IDMVOR,","")
			cCampos += "%"
			Do Case
				Case nIndex == 0
					BeginSql Alias cAliasDCF
						SELECT DCF.DCF_LOCAL,
								%Exp:cCampos%
								DCF.DCF_ENDER,
								DCF.DCF_LOCDES,
								DCF.DCF_ENDDES,
								DCF.DCF_PRDORI,
								DCF.DCF_CODPRO,
								DCF.DCF_LOTECT,
								DCF.DCF_NUMLOT,
								DCF.DCF_SERVIC,
								DCF.DCF_DOCTO,
								DCF.DCF_SERIE,
								DCF.DCF_CLIFOR,
								DCF.DCF_LOJA,
								DCF.DCF_ORIGEM,
								DCF.DCF_NUMSEQ,
								DCF.DCF_QTDORI,
								DCF.DCF_QUANT,
								DCF.DCF_QTSEUM,
								DCF.DCF_DATA,
								DCF.DCF_STSERV,
								DCF.DCF_REGRA,
								DCF.DCF_PRIORI,
								DCF.DCF_CODFUN,
								DCF.DCF_CARGA,
								DCF.DCF_UNITIZ,
								DCF.DCF_CODNOR,
								DCF.DCF_STRADI,
								DCF.DCF_ID,
								DCF.DCF_SEQUEN,
								DCF.DCF_IDORI,
								DCF.DCF_OK,
								DCF.DCF_CODREC,
								DCF.DCF_DOCPEN,
								DCF.DCF_CODPLN,
								DCF.R_E_C_N_O_ RECNODCF,
								CASE WHEN ( SELECT DISTINCT 1
											FROM %Table:DC3% DC3
											INNER JOIN %Table:DC8% DC8
											ON DC8.DC8_FILIAL = %xFilial:DC8%
											AND DC8.DC8_CODEST = DC3.DC3_TPESTR
											AND DC8.DC8_TPESTR = '1'
											AND DC8.%NotDel%
											WHERE DC3.DC3_FILIAL = %xFilial:DC3%
											AND DC3.DC3_CODPRO = DCF.DCF_CODPRO
											AND DC3.DC3_LOCAL = DCF.DCF_LOCAL
											AND DC3.%NotDel%) IS NULL THEN 2 ELSE 1 END HASPRDPUL,
								CASE WHEN ( SELECT DISTINCT 1
											FROM %Table:DC3% DC3
											INNER JOIN %Table:DC8% DC8
											ON DC8.DC8_FILIAL = %xFilial:DC8%
											AND DC8.DC8_CODEST = DC3.DC3_TPESTR
											AND DC8.DC8_TPESTR = '2'
											AND DC8.%NotDel%
											WHERE DC3.DC3_FILIAL = %xFilial:DC3%
											AND DC3.DC3_CODPRO = DCF.DCF_CODPRO
											AND DC3.DC3_LOCAL = DCF.DCF_LOCAL
											AND DC3.%NotDel%) IS NULL THEN 2 ELSE 1 END HASPRDPKG
						FROM %Table:DCF% DCF
						WHERE DCF.DCF_FILIAL = %xFilial:DCF%
						AND DCF.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
						AND DCF.%NotDel%
					EndSql
				Case nIndex == 9
					BeginSql Alias cAliasDCF
						SELECT DCF.DCF_LOCAL,
								%Exp:cCampos%
								DCF.DCF_ENDER,
								DCF.DCF_LOCDES,
								DCF.DCF_ENDDES,
								DCF.DCF_PRDORI,
								DCF.DCF_CODPRO,
								DCF.DCF_LOTECT,
								DCF.DCF_NUMLOT,
								DCF.DCF_SERVIC,
								DCF.DCF_DOCTO,
								DCF.DCF_SERIE,
								DCF.DCF_CLIFOR,
								DCF.DCF_LOJA,
								DCF.DCF_ORIGEM,
								DCF.DCF_NUMSEQ,
								DCF.DCF_QTDORI,
								DCF.DCF_QUANT,
								DCF.DCF_QTSEUM,
								DCF.DCF_DATA,
								DCF.DCF_STSERV,
								DCF.DCF_REGRA,
								DCF.DCF_PRIORI,
								DCF.DCF_CODFUN,
								DCF.DCF_CARGA,
								DCF.DCF_UNITIZ,
								DCF.DCF_CODNOR,
								DCF.DCF_STRADI,
								DCF.DCF_ID,
								DCF.DCF_SEQUEN,
								DCF.DCF_IDORI,
								DCF.DCF_OK,
								DCF.DCF_CODREC,
								DCF.DCF_DOCPEN,
								DCF.DCF_CODPLN,
								DCF.R_E_C_N_O_ RECNODCF,
								CASE WHEN ( SELECT DISTINCT 1
											FROM %Table:DC3% DC3
											INNER JOIN %Table:DC8% DC8
											ON DC8.DC8_FILIAL = %xFilial:DC8%
											AND DC8.DC8_CODEST = DC3.DC3_TPESTR
											AND DC8.DC8_TPESTR = '1'
											AND DC8.%NotDel%
											WHERE DC3.DC3_FILIAL = %xFilial:DC3%
											AND DC3.DC3_CODPRO = DCF.DCF_CODPRO
											AND DC3.DC3_LOCAL = DCF.DCF_LOCAL
											AND DC3.%NotDel%) IS NULL THEN 2 ELSE 1 END HASPRDPUL,
								CASE WHEN ( SELECT DISTINCT 1
											FROM %Table:DC3% DC3
											INNER JOIN %Table:DC8% DC8
											ON DC8.DC8_FILIAL = %xFilial:DC8%
											AND DC8.DC8_CODEST = DC3.DC3_TPESTR
											AND DC8.DC8_TPESTR = '2'
											AND DC8.%NotDel%
											WHERE DC3.DC3_FILIAL = %xFilial:DC3%
											AND DC3.DC3_CODPRO = DCF.DCF_CODPRO
											AND DC3.DC3_LOCAL = DCF.DCF_LOCAL
											AND DC3.%NotDel%) IS NULL THEN 2 ELSE 1 END HASPRDPKG
						FROM %Table:DCF% DCF
						WHERE DCF.DCF_FILIAL = %xFilial:DCF%
						AND DCF.DCF_ID = %Exp:Self:cIdDCF%
						AND DCF.DCF_STSERV <> '0'
						AND DCF.%NotDel%
					EndSql
			EndCase
			TCSetField(cAliasDCF,'DCF_QTDORI','N',aDCF_QTDORI[1],aDCF_QTDORI[2])
			TCSetField(cAliasDCF,'DCF_QUANT' ,'N',aDCF_QUANT[1] ,aDCF_QUANT[2])
			TCSetField(cAliasDCF,'DCF_QTSEUM','N',aDCF_QTSEUM[1],aDCF_QTSEUM[2])
			TcSetField(cAliasDCF,'DCF_DATA','D')
			If (lRet := (cAliasDCF)->(!Eof()))
				// Busca dados endereco origem
				Self:oOrdEndOri:SetArmazem((cAliasDCF)->DCF_LOCAL)
				Self:oOrdEndOri:SetEnder((cAliasDCF)->DCF_ENDER)
				Self:oOrdEndOri:LoadData()
				// Busca dados endereco destino
				Self:oOrdEndDes:SetArmazem((cAliasDCF)->DCF_LOCDES)
				Self:oOrdEndDes:SetEnder((cAliasDCF)->DCF_ENDDES)
				Self:oOrdEndDes:LoadData()
				// Busca dados lote/produto
				Self:oProdLote:SetArmazem((cAliasDCF)->DCF_LOCAL)
				Self:oProdLote:SetPrdOri((cAliasDCF)->DCF_PRDORI)
				Self:oProdLote:SetProduto((cAliasDCF)->DCF_CODPRO)
				Self:oProdLote:SetLoteCtl((cAliasDCF)->DCF_LOTECT)
				Self:oProdLote:SetNumLote((cAliasDCF)->DCF_NUMLOT)
				Self:oProdLote:SetNumSer("")
				Self:oProdLote:LoadData()
				// Atribui dados servico
				Self:oServico:SetServico((cAliasDCF)->DCF_SERVIC)
				Self:oServico:LoadData()
				// Atribui dados aos demais campos
				Self:cDocumento:= (cAliasDCF)->DCF_DOCTO
				Self:cSerieDoc := (cAliasDCF)->DCF_SERIE // DCF->DCF_SDOC
				Self:cSerie    := (cAliasDCF)->DCF_SERIE
				Self:cCliFor   := (cAliasDCF)->DCF_CLIFOR
				Self:cLoja     := (cAliasDCF)->DCF_LOJA
				Self:cOrigem   := (cAliasDCF)->DCF_ORIGEM
				Self:cNumSeq   := (cAliasDCF)->DCF_NUMSEQ
				Self:nQtdOri   := (cAliasDCF)->DCF_QTDORI
				Self:nQuant    := (cAliasDCF)->DCF_QUANT
				Self:nQuant2   := (cAliasDCF)->DCF_QTSEUM
				Self:dData     := (cAliasDCF)->DCF_DATA
				If Self:lHasHora
					Self:cHora     := (cAliasDCF)->DCF_HORA
				EndIf
				Self:cStServ   := (cAliasDCF)->DCF_STSERV
				Self:cRegra    := (cAliasDCF)->DCF_REGRA
				Self:cPriori   := (cAliasDCF)->DCF_PRIORI
				Self:cCodFun   := (cAliasDCF)->DCF_CODFUN
				Self:cCarga    := (cAliasDCF)->DCF_CARGA
				Self:cIdUnitiz := (cAliasDCF)->DCF_UNITIZ
				If Self:lHasUniDes
					Self:cUniDes   := (cAliasDCF)->DCF_UNIDES
				EndIf
				If Self:lHasIdMvOr
					Self:cIdMovOrig:= (cAliasDCF)->DCF_IDMVOR
				EndIf
				Self:cCodNorma  := (cAliasDCF)->DCF_CODNOR
				Self:cStRadi    := (cAliasDCF)->DCF_STRADI
				Self:cIdDCF     := (cAliasDCF)->DCF_ID
				Self:cSequen    := (cAliasDCF)->DCF_SEQUEN
				Self:cIdOrigem  := (cAliasDCF)->DCF_IDORI
				Self:cOk        := (cAliasDCF)->DCF_OK
				Self:cCodRec    := (cAliasDCF)->DCF_CODREC
				Self:cDocPen    := (cAliasDCF)->DCF_DOCPEN
				Self:cCodPln    := (cAliasDCF)->DCF_CODPLN
				Self:lHasPrdPul := IIf((cAliasDCF)->HASPRDPUL == 1,.T.,.F.)
				Self:lHasPrdPkg := IIf((cAliasDCF)->HASPRDPKG == 1,.T.,.F.)
				Self:nRecno     := (cAliasDCF)->RECNODCF
				// Controle dados anteriores
				Self:cServicAnt := Self:GetServico()
				Self:cDoctoAnt  := Self:GetDocto()
				Self:cIdDCFAnt  := Self:cIdDCF
				Self:cSeqPriExe := "" // Limpa para forçar uma nova busca
			Else
				Self:cErro := WmsFmtMsg(STR0010,{{"[VAR01]",AllTrim(Self:cIdDCF)}})// Ordem de serviço para o identificador [VAR01] não cadastrado!
			EndIf
			(cAliasDCF)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaDCF)
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
// Setters
//----------------------------------------
METHOD SetIdDCF(cIdDCF) CLASS WMSDTCOrdemServico
	Self:cIdDCF := PadR(cIdDCF, Len(Self:cIdDCF))
Return

METHOD SetSequen(cSequen) CLASS WMSDTCOrdemServico
	Self:cSequen := PadR(cSequen, Len(Self:cSequen))
Return

METHOD SetIdOrig(cIdOrigem) CLASS WMSDTCOrdemServico
Local aAreaDCF := DCF->(GetArea())
	If !Empty(cIdOrigem)
		DCF->(dbSetOrder(9)) // DCF_FILIAL+DCF_ID
		DCF->(dbSeek(xFilial("DCF")+ PadR(cIdOrigem, Len(Self:cIdOrigem))))
		Self:cDocPen := DCF->DCF_DOCTO
	Else
		Self:cDocPen := PadR("", Len(Self:cIdOrigem))
	EndIf
	Self:cIdOrigem  := PadR(cIdOrigem, Len(Self:cIdOrigem))
	RestArea(aAreaDCF)
Return

METHOD SetNumSeq(cNumSeq) CLASS WMSDTCOrdemServico
	Self:cNumSeq := PadR(cNumSeq, Len(Self:cNumSeq))
Return

METHOD SetDocto(cDocumento) CLASS WMSDTCOrdemServico
	Self:cDocumento := PadR(cDocumento, Len(Self:cDocumento))
Return

METHOD SetSerie(cSerie) CLASS WMSDTCOrdemServico
	Self:cSerie := PadR(cSerie, Len(Self:cSerie))
Return

METHOD SetCliFor(cCliFor) CLASS WMSDTCOrdemServico
	Self:cCliFor := PadR(cCliFor, Len(Self:cCliFor))
Return

METHOD SetLoja(cLoja) CLASS WMSDTCOrdemServico
	Self:cLoja := PadR(cLoja, Len(Self:cLoja))
Return

METHOD SetServico(cServico) CLASS WMSDTCOrdemServico
	Self:oServico:SetServico(cServico)
Return

METHOD SetStServ(cStatus) CLASS WMSDTCOrdemServico
	Self:cStServ := PadR(cStatus, Len(Self:cStServ))
Return

METHOD SetCarga(cCarga) CLASS WMSDTCOrdemServico
	Self:cCarga := PadR(cCarga, Len(Self:cCarga))
Return

METHOD SetCodRec(cCodRec) CLASS WMSDTCOrdemServico
	Self:cCodRec := PadR(cCodRec, Len(Self:cCodRec))
Return

METHOD SetOrigem(cOrigem) CLASS WMSDTCOrdemServico
	Self:cOrigem := PadR(cOrigem, Len(Self:cOrigem))
Return

METHOD SetQuant(nQuant) CLASS WMSDTCOrdemServico
	Self:nQuant := nQuant
Return

METHOD SetOk(cOk) CLASS WMSDTCOrdemServico
	Self:cOk := PadR(cOk, Len(Self:cOk))
Return

METHOD SetRegra(cRegra) CLASS WMSDTCOrdemServico
	Self:cRegra := PadR(cRegra, Len(Self:cRegra))
Return

METHOD SetQtdOri(nQtdOri) CLASS WMSDTCOrdemServico
	Self:nQtdOri := nQtdOri
Return

METHOD SetArrLib(aLibD12) CLASS WMSDTCOrdemServico
	Self:aLibD12 := aLibD12
Return

METHOD SetData(dData) CLASS WMSDTCOrdemServico
	Self:dData := dData
Return

METHOD SetHora(cHora) CLASS WMSDTCOrdemServico
	Self:cHora := cHora
Return

METHOD SetCodPln(cCodPln) CLASS WMSDTCOrdemServico
	Self:cCodPln := cCodPln
Return

METHOD SetIdUnit(cIdUnit) CLASS WMSDTCOrdemServico
	Self:cIdUnitiz := PadR(cIdUnit, Len(Self:cIdUnitiz))
Return

METHOD SetUniDes(cUniDes) CLASS WMSDTCOrdemServico
	Self:cUniDes := PadR(cUniDes, IIf(Self:lHasUniDes, Len(Self:cUniDes),6))
Return

METHOD SetTipUni(cTipUni) CLASS WMSDTCOrdemServico
	Self:cTipUni := PadR(cTipUni, IIf(Self:lHasCodUni, Len(Self:cTipUni),6))
Return

METHOD SetIdMovOr(cIdMovOrig) CLASS WMSDTCOrdemServico
	Self:cIdMovOrig := PadR(cIdMovOrig, IIf(Self:lHasIdMvOr, Len(Self:cIdMovOrig),6))
Return

METHOD SetTipReab(cTipReab) CLASS WMSDTCOrdemServico
	Self:cTipReab := cTipReab
Return

METHOD SetOp(cOp) CLASS WMSDTCOrdemServico
	Self:cOp := PadR(cOp, Len(Self:cOp))
Return

METHOD SetTrt(cTrt) CLASS WMSDTCOrdemServico
	Self:cTrt := PadR(cTrt, Len(Self:cTrt))
Return
//----------------------------------------
// Getters
//----------------------------------------
METHOD GetIdDCF() CLASS WMSDTCOrdemServico
Return Self:cIdDCF

METHOD GetSequen() CLASS WMSDTCOrdemServico
Return Self:cSequen

METHOD GetIdOrig() CLASS WMSDTCOrdemServico
Return Self:cIdOrigem

METHOD GetNumSeq() CLASS WMSDTCOrdemServico
Return Self:cNumSeq

METHOD GetDocto() CLASS WMSDTCOrdemServico
Return Self:cDocumento

METHOD GetSerie() CLASS WMSDTCOrdemServico
Return Self:cSerie

METHOD GetCliFor() CLASS WMSDTCOrdemServico
Return Self:cCliFor

METHOD GetLoja() CLASS WMSDTCOrdemServico
Return Self:cLoja

METHOD GetServico() CLASS WMSDTCOrdemServico
Return Self:oServico:GetServico()

METHOD GetStServ() CLASS WMSDTCOrdemServico
Return Self:cStServ

METHOD GetOrigem() CLASS WMSDTCOrdemServico
Return Self:cOrigem

METHOD GetCodNor() CLASS WMSDTCOrdemServico
Return Self:cCodNorma

METHOD GetCarga() CLASS WMSDTCOrdemServico
Return Self:cCarga

METHOD GetCodRec() CLASS WMSDTCOrdemServico
Return Self:cCodRec

METHOD GetQuant() CLASS WMSDTCOrdemServico
Return Self:nQuant

METHOD GetQuant2() CLASS WMSDTCOrdemServico
Return Self:nQuant2

METHOD GetRegra() CLASS WMSDTCOrdemServico
Return Self:cRegra

METHOD GetOk() CLASS WMSDTCOrdemServico
Return Self:cOk

METHOD GetRecno() CLASS WMSDTCOrdemServico
Return Self:nRecno

METHOD GetQtdOri() CLASS WMSDTCOrdemServico
Return Self:nQtdOri

METHOD GetArrLib() CLASS WMSDTCOrdemServico
Return Self:aLibD12

METHOD GetData() CLASS WMSDTCOrdemServico
Return Self:dData

METHOD GetHora() CLASS WMSDTCOrdemServico
Return Self:cHora

METHOD GetDocPen() CLASS WMSDTCOrdemServico
Return Self:cDocPen

METHOD GetErro() CLASS WMSDTCOrdemServico
Return Self:cErro

METHOD GetCodPln() CLASS WMSDTCOrdemServico
Return Self:cCodPln

METHOD GetIdUnit() CLASS WMSDTCOrdemServico
Return Self:cIdUnitiz

METHOD GetUniDes() CLASS WMSDTCOrdemServico
Return Self:cUniDes

METHOD GetTipUni() CLASS WMSDTCOrdemServico
Return Self:cTipUni

METHOD GetIdMovOr() CLASS WMSDTCOrdemServico
Return Self:cIdMovOrig

METHOD GetTipReab() CLASS WMSDTCOrdemServico
Return Self:cTipReab

METHOD GetOp() CLASS WMSDTCOrdemServico
Return Self:cOp

METHOD GetTrt() CLASS WMSDTCOrdemServico
Return Self:cTrt

METHOD HasPrdPul() CLASS WMSDTCOrdemServico
Return Self:lHasPrdPul

METHOD HasPrdPkg() CLASS WMSDTCOrdemServico
Return Self:lHasPrdPkg
//----------------------------------------
/*/{Protheus.doc} RecordDCF
Gravação dos dados DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD RecordDCF() CLASS WMSDTCOrdemServico
Local lRet      := .T.
Local aAreaDCF  := DCF->(GetArea())
Local cAliasDCF := Nil
	If Empty(Self:cIdDCF) .Or. Self:lGeraNovoId
		Self:cIdDCF  := WMSProxSeq('MV_DOCSEQ','DCF_ID')
	EndIf
	// Verifica se o Armazem está vazio e atribui para os enderecos
	If Empty(Self:oOrdEndOri:GetArmazem())
		Self:oOrdEndOri:SetArmazem(Self:oOrdEndDes:GetArmazem())
	EndIf
	If Empty(Self:oOrdEndDes:GetArmazem())
		Self:oOrdEndDes:SetArmazem(Self:oOrdEndOri:GetArmazem())
	EndIf
	If Self:lforceDtHr
		Self:dData := dDataBase
		Self:cHora := Time()
	Else
		If Empty(Self:dData)
			Self:dData := dDataBase
		EndIf
		If Empty(Self:cHora)
			Self:cHora := Time()
		EndIf
	EndIf
	Self:nQuant2 := ConvUm(Self:oProdLote:GetProduto(),Self:nQuant,0,2)
	Self:nQtdOri := Self:nQuant
	If Empty(Self:cStServ) .Or. Self:cStServ != "4"
		Self:cStServ := "1"
	EndIf
	// Grava DCF
	cAliasDCF := GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT 1
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ID = %Exp:Self:cIdDCF%
		AND DCF.%NotDel%
	EndSql
	If (cAliasDCF)->(Eof())
		RecLock('DCF', .T.)
		DCF->DCF_FILIAL := xFilial('DCF')
		DCF->DCF_ID     := Self:cIdDCF
		DCF->DCF_SERVIC := Self:oServico:GetServico()
		DCF->DCF_DOCTO  := Self:cDocumento
		DCF->DCF_SERIE  := Self:cSerie
		// DCF->DCF_SDOC  := Self:cSerieDoc
		DCF->DCF_CLIFOR := Self:cCliFor
		DCF->DCF_LOJA   := Self:cLoja
		DCF->DCF_CODPRO := Self:oProdLote:GetProduto()
		DCF->DCF_DATA   := Self:dData
		If Self:lHasHora
			DCF->DCF_HORA   := Self:cHora
		EndIf
		DCF->DCF_STSERV := Self:cStServ
		DCF->DCF_QUANT  := Self:nQuant
		DCF->DCF_QTSEUM := Self:nQuant2
		DCF->DCF_QTDORI := Self:nQtdOri
		DCF->DCF_ORIGEM := Self:cOrigem
		DCF->DCF_NUMSEQ := Self:cNumseq
		DCF->DCF_LOCAL  := Self:oOrdEndOri:GetArmazem() //Self:oProdLote:GetArmazem()
		DCF->DCF_ESTFIS := Self:oOrdEndOri:GetEstFis()
		DCF->DCF_LOCDES := Self:oOrdEndDes:GetArmazem()
		DCF->DCF_ENDDES := Self:oOrdEndDes:GetEnder()
		DCF->DCF_REGRA  := Self:cRegra
		DCF->DCF_ENDER  := Self:oOrdEndOri:GetEnder()
		DCF->DCF_LOTECT := Self:oProdLote:GetLoteCtl()
		DCF->DCF_NUMLOT := Self:oProdLote:GetNumLote()
		DCF->DCF_PRDORI := Self:oProdLote:GetPrdOri()
		DCF->DCF_PRIORI := Self:cPriori
		DCF->DCF_CODFUN := Self:cCodFun
		DCF->DCF_CARGA  := Self:cCarga
		DCF->DCF_UNITIZ := Self:cIdUnitiz
		If Self:lHasUniDes
			DCF->DCF_UNIDES := Self:cUniDes
		EndIf
		If Self:lHasIdMvOr
			DCF->DCF_IDMVOR := Self:cIdMovOrig
		EndIf
		DCF->DCF_CODNOR := Self:cCodNorma
		DCF->DCF_STRADI := Self:cStradi
		DCF->DCF_SEQUEN := Self:cSequen
		DCF->DCF_IDORI  := Self:cIdOrigem
		DCF->DCF_OK     := Self:cOk
		DCF->DCF_CODREC := Self:cCodRec
		DCF->DCF_DOCPEN := Self:cDocPen
		DCF->DCF_CODPLN := Self:cCodPln
		DCF->(MsUnLock())
		// Grava recno
		Self:nRecno := DCF->(Recno())
		// Ponto de Entrada WMSPOSDCF apos as gravacoes
		// Recebe o recno da DCF criada
		If ExistBlock('WMSPOSDC')
			ExecBlock('WMSPOSDC',.F.,.F.,{Self:nRecno})
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0005 // Chave duplicada!
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaDCF)
Return lRet
//----------------------------------------
/*/{Protheus.doc} ExcludeDCF
Exclusão da DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ExcludeDCF() CLASS WMSDTCOrdemServico
Local lRet     := .T.
Local aAreaDCF := DCF->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local cAliasQry:= ""
// Posiciona registro
	DCF->(dbGoTo( Self:GetRecno() ))
	// Diminui a quantidade ou exclui a ordem de serviço
	If Self:cOrigem == "SC9" .And. QtdComp(Self:nQtdDel) > QtdComp(0) .And. QtdComp(DCF->DCF_QUANT) > QtdComp(Self:nQtdDel)
		RecLock('DCF', .F.)
		DCF->DCF_QUANT  -= Self:nQtdDel
		DCF->DCF_QTSEUM := ConvUm(DCF->DCF_CODPRO,DCF->DCF_QUANT,0,2)
		DCF->(MsUnlock())
	Else
		//Se exclui a ordem de serviço, deve excluir o IDDCF da origem
		Self:UpdIntegra()
		// Excluindo a ordem de serviço
		RecLock('DCF', .F.)
		DCF->(DbDelete())
		DCF->(MsUnlock())

		//--Após a exclusão, verifica se ainda existe ordem de serviço atrelada ao documento, como conferencia por exemplo
		//--Se houver, atribui ao campo D1_IDDCF para recriar o relacionamento na origem
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCF.DCF_ID, DCF.DCF_STSERV
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_DOCTO = %Exp:Self:cDocumento%
			AND DCF.DCF_SERIE = %Exp:Self:cSerie%
			AND DCF.DCF_CLIFOR = %Exp:Self:cCliFor%
			AND DCF.DCF_LOJA = %Exp:Self:cLoja%
			AND DCF.DCF_CODPRO = %Exp:Self:oProdLote:GetPrdOri()%
			AND DCF.DCF_ORIGEM = 'SD1'
			AND DCF.DCF_STSERV <> '0'
			AND DCF.%NotDel%
		EndSql
		If (cAliasQry)->(!EOF())
			SD1->(DbSetOrder(4)) //--D1_FILIAL + D1_NUMSEQ
			If SD1->(DbSeek(xFilial("SD1")+Self:cNumSeq))		
				RecLock('SD1', .F.)
				SD1->D1_IDDCF  := (cAliasQry)->DCF_ID
				SD1->D1_STSERV := (cAliasQry)->DCF_STSERV
				SD1->(MsUnlock())
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())

	EndIf
	RestArea(aAreaDCF)
	RestArea(aAreaSD1)
Return lRet
//----------------------------------------
/*/{Protheus.doc} CancelDCF
Cancelamento da DCF
@author alexsander.correa
@since 09/11/2016
@version 1.0
/*/
//----------------------------------------
METHOD CancelDCF() CLASS WMSDTCOrdemServico
Local lRet := .T.
Local aAreaDCF := DCF->(GetArea())
	// Posiciona registro
	DCF->(dbGoTo( Self:GetRecno() ))
	// Diminui a quantidade ou exclui a ordem de serviço
	//Se cancela a ordem de serviço, deve cancelar o IDDCF da origem
	Self:UpdIntegra()
	// Excluindo a ordem de serviço
	RecLock('DCF', .F.)
	DCF->DCF_STSERV := '0'
	DCF->(MsUnlock())
	RestArea(aAreaDCF)
Return lRet
//----------------------------------------
/*/{Protheus.doc} UpdateDCF
Atualização dos dados DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdateDCF(lMsUnLock) CLASS WMSDTCOrdemServico
Local lRet := .T.

Default lMsUnLock := .T.

	If !Empty(Self:GetRecno())
		DCF->(dbGoTo( Self:GetRecno() ))
		WmsConout('Efetuando UpdateDCF Recno / nQuant / Carga / Docto / Produto ' + cValToChar( Self:GetRecno()) + ' / ' + cValToChar(Self:nQuant) + ' / ' + Self:cCarga + ' / ' + Self:cDocumento + ' / ' + Self:oProdLote:GetProduto())
		Self:nQuant2 := ConvUm(Self:oProdLote:GetProduto(),Self:nQuant,0,2)
		// Grava DCF
		RecLock('DCF', .F.)
		DCF->DCF_SERVIC := Self:oServico:GetServico()
		DCF->DCF_DOCTO  := Self:cDocumento
		DCF->DCF_SERIE  := Self:cSerie
		// DCF->DCF_SDOC  := Self:cSerieDoc
		DCF->DCF_CLIFOR := Self:cCliFor
		DCF->DCF_LOJA   := Self:cLoja
		DCF->DCF_CODPRO := Self:oProdLote:GetProduto()
		DCF->DCF_DATA   := Self:dData
		If Self:lHasHora
			DCF->DCF_HORA   := Self:cHora
		EndIf
		DCF->DCF_STSERV := Self:cStServ
		DCF->DCF_QTDORI := Self:nQtdOri
		DCF->DCF_QUANT  := Self:nQuant
		DCF->DCF_QTSEUM := Self:nQuant2
		DCF->DCF_ORIGEM := Self:cOrigem
		DCF->DCF_NUMSEQ := Self:cNumseq
		DCF->DCF_LOCAL  := Self:oProdLote:GetArmazem()
		DCF->DCF_ENDER  := Self:oOrdEndOri:GetEnder()
		DCF->DCF_ESTFIS := Self:oOrdEndOri:GetEstFis()
		DCF->DCF_LOCDES := Self:oOrdEndDes:GetArmazem()
		DCF->DCF_ENDDES := Self:oOrdEndDes:GetEnder()
		DCF->DCF_LOTECT := Self:oProdLote:GetLoteCtl()
		DCF->DCF_NUMLOT := Self:oProdLote:GetNumLote()
		DCF->DCF_PRDORI := Self:oProdLote:GetPrdOri()
		DCF->DCF_REGRA  := Self:cRegra
		DCF->DCF_PRIORI := Self:cPriori
		DCF->DCF_CODFUN := Self:cCodFun
		DCF->DCF_CARGA  := Self:cCarga
		DCF->DCF_UNITIZ := Self:cIdUnitiz
		If Self:lHasUniDes
			DCF->DCF_UNIDES := Self:cUniDes
		EndIf
		If Self:lHasIdMvOr
			DCF->DCF_IDMVOR := Self:cIdMovOrig
		EndIf
		DCF->DCF_CODNOR := Self:cCodNorma
		DCF->DCF_STRADI := Self:cStradi
		DCF->DCF_SEQUEN := Self:cSequen
		DCF->DCF_IDORI  := Self:cIdOrigem
		DCF->DCF_OK     := Self:cOk
		DCF->DCF_CODREC := Self:cCodRec
		DCF->DCF_DOCPEN := Self:cDocPen
		DCF->DCF_CODPLN := Self:cCodPln
		DCF->(dbCommit()) // Para forçar atualização do banco
		If lMsUnLock
			DCF->(MsUnLock())
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0001 // Recno inválido!
	EndIf
Return lRet

//----------------------------------------
/*/{Protheus.doc} UpdAgluDCF
Atualização dos dados DCF aglutinados com a OS executada.
Objetivo é melhorar performance, pois em vez de fazer o método Load (lê 3, 4 tabelas por OS), 
para atualizar apenas 2 ou 3 campos, indica-se que campos e valores serão atualizados para uma lista de
DCF->Recno.
@author wander.horongoso
@since 01/08/2021
@version 1.0
/*/
//----------------------------------------
METHOD UpdAgluDCF(aFields, lMsUnlock) CLASS WMSDTCOrdemServico
Local lRet := .T.
Local nCont := 0
Local cRecDCF := ''
Local cFields := ''
Local cQuery := ''

Default lMsUnLock := .T.

	For nCont := 1 to Len(Self:aRecDCF)
		If Self:aRecDCF[nCont][2]
			cRecDCF += cValToChar(Self:aRecDCF[nCont][1]) + ","
		EndIf
	Next nCont

	If !Empty(cRecDCF)
		cRecDCF := SubStr(cRecDCF,1,Len(cRecDCF)-1) 

		For nCont := 1 to Len(aFields)
			cFields += aFields[nCont,1] + " = '" + aFields[nCont,2] + "',"
		Next nCont

		cFields := Substr(cFields, 1, Len(cFields)-1)

		cQuery := "UPDATE " + RetSqlName('DCF')
		cQuery += " SET " + cFields
		cQuery += "	WHERE DCF_FILIAL = '" + xFilial('DCF') + "'"
		cQuery += "	AND R_E_C_N_O_ IN (" + AllTrim(cRecDCF) + ")"
		cQuery += "	AND D_E_L_E_T_ = ' '"
		If TcSQLExec(cQuery) < 0
			Self:cErro := TcSQLError()
		EndIf

		WmsConout('UpdAgluDCF ' + cQuery)
	Else
		lRet := .F.
		Self:cErro := STR0001 // Recno inválido!
	EndIf
Return lRet

//----------------------------------------
/*/{Protheus.doc} UpdStatus
Atualização do status
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdStatus() CLASS WMSDTCOrdemServico
Local lRet      := .F.
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSD2  := SD2->(GetArea())
Local aAreaSD3  := SD3->(GetArea())
Local aAreaSD4  := SD4->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local cAliasQry := Nil
	// Atualiza documento origem
	If Self:cOrigem == 'SD1'
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD1.R_E_C_N_O_ RECNOSD1
			FROM %Table:SD1% SD1
			WHERE SD1.D1_FILIAL = %xFilial:SD1%
			AND SD1.D1_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD1.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SD1->(dbGoTo((cAliasQry)->RECNOSD1))
			RecLock('SD1', .F.)
			SD1->D1_STSERV := Self:cStServ
			SD1->(MsUnLock())
		EndIf
		(cAliasQry)->(dbCloseArea())
	ElseIf Self:cOrigem == 'SD2'
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD2.R_E_C_N_O_ RECNOSD2
			FROM %Table:SD2% SD2
			WHERE SD2.D2_FILIAL = %xFilial:SD2%
			AND SD2.D2_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD2.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SD2->(dbGoTo((cAliasQry)->RECNOSD2))
			RecLock('SD2', .F.)
			SD2->D2_STSERV := Self:cStServ
			SD2->(MsUnLock())
		EndIf
		(cAliasQry)->(dbCloseArea())
	ElseIf Self:cOrigem == 'SD3'
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD3.R_E_C_N_O_ RECNOSD3
			FROM %Table:SD3% SD3
			WHERE SD3.D3_FILIAL = %xFilial:SD3%
			AND SD3.D3_COD = %Exp:Self:oProdLote:GetPrdOri()%
			AND SD3.D3_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
			AND SD3.D3_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD3.%NotDel%
		EndSql
		Do While (cAliasQry)->(!Eof())
			SD3->(dbGoTo((cAliasQry)->RECNOSD3))
			RecLock('SD3', .F.)
			SD3->D3_STSERV := Self:cStServ
			SD3->(MsUnLock())
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	ElseIf Self:cOrigem == 'SC9'
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_IDDCF = %Exp:Self:cIdDCF% 
			AND SC9.%NotDel%
		EndSql
		Do While (cAliasQry)->(!Eof())
			SC9->(dbGoTo((cAliasQry)->RECNOSC9))
			WmsConout('UpdStatus RecnoSC9 ' + cValToChar((cAliasQry)->RECNOSC9))
			RecLock('SC9', .F.)
			SC9->C9_STSERV := Self:cStServ
			SC9->(MsUnLock())
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	// Restaura area
	RestArea(aAreaSD1)
	RestArea(aAreaSD2)
	RestArea(aAreaSD3)
	RestArea(aAreaSD4)
	RestArea(aAreaSC9)
Return lRet

//----------------------------------------
/*/{Protheus.doc} UpdAgluSta
Atualização dos dados da SC9 (e futuramente outras tabelas) a partir de DCF aglutinados com a OS executada.
Objetivo é melhorar performance, pois em vez de usar o método UpdStatus, que faz dbGoto e RecLock,
os valores serão atualizados para uma lista de DCF->Recno.
@author wander.horongoso
@since 01/08/2021
@version 1.0
/*/
//----------------------------------------
METHOD UpdAgluSta(cStatus) CLASS WMSDTCOrdemServico
Local lRet := .T.
Local nCont := 0
Local cRecDCF := ''
Local cQuery := ''

	//Se o registro origem for SC9, os aglutinados também serão
	If Self:cOrigem == 'SC9'

		For nCont := 1 to Len(Self:aRecDCF)
			If Self:aRecDCF[nCont][2]
				cRecDCF += cValToChar(Self:aRecDCF[nCont][1]) + ","
			EndIf
		Next nCont

		If !Empty(cRecDCF)
			cRecDCF := SubStr(cRecDCF,1,Len(cRecDCF)-1)
		
			cQuery := "UPDATE " + RetSqlName('SC9')
			cQuery += "	SET C9_STSERV = '" + AllTrim(cStatus) + "'"
			cQuery += "	WHERE C9_FILIAL = '" + xFilial('SC9') + "'"
			cQuery += "	AND C9_IDDCF IN ("
			cQuery +=   "SELECT DCF_ID FROM " + RetSqlName('DCF')
			cQuery +=   " WHERE DCF_FILIAL = '" + xFilial("DCF") + "'"
			cQuery +=   " AND R_E_C_N_O_ IN (" + AllTrim(cRecDCF) + ")"
			cQuery +=   " AND D_E_L_E_T_ = ' ')"
			cQuery += "	AND D_E_L_E_T_ = ' '"
			
			If TcSQLExec(cQuery) < 0
				lRet := .F.
				Self:cErro := TcSQLError()
			EndIf	

			WmsConout('UpdAgluSta ' + cQuery)
		EndIf
	EndIf

Return lRet


//----------------------------------------
/*/{Protheus.doc} UndoIntegr
Desfaz a integração da ordem de serviço
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//----------------------------------------
METHOD UndoIntegr() CLASS WMSDTCOrdemServico
Local lRet     := .T.
	// Atualiza estoque por endereco
	If Self:oServico:HasOperac({'1','2'}) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
		If lRet
			lRet := Self:ReverseMA()
		EndIf
		If lRet .And. Self:ChkMovEst(.F.)
			lRet := Self:ReverseMI()
		EndIf
		// Realiza a exclusão da D0G depois do SD3, pois do contrário gera erro de saldo negativo
		If lRet
			oSaldoADis := WMSDTCSaldoADistribuir():New()
			oSaldoADis:oProdLote:SetProduto(Self:oProdLote:GetPrdOri())
			oSaldoADis:oProdLote:SetArmazem(Self:oProdLote:GetArmazem())
			oSaldoADis:SetDocto(Self:cDocumento)
			oSaldoADis:SetSerie(Self:cSerie)
			oSaldoADis:SetCliFor(Self:cCliFor)
			oSaldoADis:SetLoja(Self:cLoja)
			oSaldoADis:SetNumSeq(Self:cNumSeq)
			oSaldoADis:SetIdDCF(Self:GetIdDCF())
			If oSaldoADis:LoadData(1)
				oSaldoADis:DeleteD0G()
			EndIf
		EndIf
		If lRet .And. WmsX312118("D13","D13_USACAL")
			// Ajuste movimento kardex de integração
			lRet := Self:SaiMovEst()
			//Analisar registros SD3 como Estorno = S e D13_USACAL = 1. Se encontrar, alterar para 2 
			If lRet
				lRet := Self:EstOpTotal()
			EndIf
		EndIf
	ElseIf Self:oServico:HasOperac({'8'}) // Caso serviço tenha operação de transferencia
		lRet := Self:ReverseMO()
		If lRet .And. Self:ChkMovEst(.F.)
			lRet := Self:ReverseMI()
		EndIf

		// Retirar a Reserva quando está desfazendo a integração
		If lRet .And. Self:cOrigem == "DH1"
			Self:UpdEmpSB2("-",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:GetQuant())
			// Baixa da reserva do SB8
			If Self:oProdLote:HasRastro() .And. !Empty(Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote())
				Self:UpdEmpSB8("-",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:oProdLote:GetLoteCtl(), Self:oProdLote:GetNumLote(), Self:GetQuant())
			EndIf
		EndIf
	ElseIf Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
		// incluso validação para o programa mara462tn para nao fazern atualização de entrada e saida prevista quando tem endereço origem preenchido 
		If lRet .And. !Empty(Self:oOrdEndOri:GetEnder()) .AND. (cPaisLoc = 'BRA' .OR. !FwIsInCallStack('MATA462TN'))
			// Efetua ajuste estoque por endereço
			If Self:cOrigem $ "SC9" .And. QtdComp(Self:nQtdDel) > QtdComp(0)
				Self:nQuant := Self:nQtdDel
			EndIf
			If Self:ChkMovEst(.F.) .Or. (Self:cStServ == '1' .And. Self:ChkMovEst(.T.) )
				lRet := Self:ReverseMO()
				If lRet
					lRet := Self:ReverseMI()
				EndIf
			EndIf
		EndIf
		If lRet .And. Self:cOrigem == "DH1"
			Self:UpdEmpSB2("-",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:GetQuant())
			// Baixa da reserva do SB8
			If Self:oProdLote:HasRastro() .And. !Empty(Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote())
				Self:UpdEmpSB8("-",Self:oProdLote:GetProduto(),Self:oOrdEndOri:GetArmazem(),Self:oProdLote:GetLoteCtl(), Self:oProdLote:GetNumLote(), Self:GetQuant())
			EndIf
			If lRet .And. WmsX312118("D13","D13_USACAL")
				// Ajuste movimento kardex de integração
				lRet := Self:SaiMovEst()
			EndIf
		EndIf
	EndIf
Return lRet

//----------------------------------------
/*/{Protheus.doc} UpdIntegra
Atualiza a integração da ordem de serviço
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdIntegra() CLASS WMSDTCOrdemServico
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSD2  := SD2->(GetArea())
Local aAreaSD3  := SD3->(GetArea())
Local aAreaSD4  := SD4->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local cAliasQry := Nil
	// Atualiza documento origem
	If Self:cOrigem == 'SD1'
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD1.R_E_C_N_O_ RECNOSD1
			FROM %Table:SD1% SD1
			WHERE SD1.D1_FILIAL = %xFilial:SD1%
			AND SD1.D1_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD1.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SD1->(dbGoTo((cAliasQry)->RECNOSD1))
			RecLock('SD1', .F.)
			SD1->D1_IDDCF  := ""
			SD1->D1_STSERV := ""
			SD1->(MsUnLock())
		EndIf
		(cAliasQry)->(dbCloseArea())
		// Cancela movimentos
	ElseIf Self:cOrigem == 'SD2'
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD2.R_E_C_N_O_ RECNOSD2
			FROM %Table:SD2% SD2
			WHERE SD2.D2_FILIAL = %xFilial:SD2%
			AND SD2.D2_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD2.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SD2->(dbGoTo((cAliasQry)->RECNOSD2))
			RecLock('SD2', .F.)
			SD2->D2_IDDCF  := ""
			SD2->D2_STSERV := ""
			SD2->(MsUnLock())
		EndIf
		(cAliasQry)->(dbCloseArea())
	ElseIf Self:cOrigem == 'SD3'
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD3.R_E_C_N_O_ RECNOSD3
			FROM %Table:SD3% SD3
			WHERE SD3.D3_FILIAL = %xFilial:SD3%
			AND SD3.D3_COD = %Exp:Self:oProdLote:GetPrdOri()%
			AND SD3.D3_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
			AND SD3.D3_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD3.%NotDel%
		EndSql
		Do While (cAliasQry)->(!Eof())
			SD3->(dbGoTo((cAliasQry)->RECNOSD3))
			RecLock('SD3', .F.)
			SD3->D3_IDDCF  := ""
			SD3->D3_STSERV := ""
			SD3->(MsUnLock())
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	ElseIf Self:cOrigem == 'SC9'
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_IDDCF = %Exp:Self:cIdDCF% 
			AND SC9.%NotDel%
		EndSql
		Do While (cAliasQry)->(!Eof())
			SC9->(dbGoTo((cAliasQry)->RECNOSC9))
			RecLock('SC9', .F.)
			SC9->C9_IDDCF  := ""
			SC9->C9_STSERV := ""
			SC9->(MsUnLock())
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	ElseIf Self:cOrigem == "DH1"
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DH1.R_E_C_N_O_ RECNODH1
			FROM %Table:DH1% DH1
			WHERE DH1.DH1_FILIAL = %xFilial:DH1%
			AND DH1.DH1_DOC = %Exp:Self:GetDocto()%
			AND DH1.DH1_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
			AND DH1.DH1_NUMSEQ = %Exp:Self:cNumSeq%
			AND DH1.DH1_IDDCF = %Exp:Self:GetIdDCF()%
			AND DH1.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			DH1->(dbGoTo((cAliasQry)->RECNODH1))
			RecLock('DH1', .F.)
			DH1->DH1_IDDCF  := ""
			DH1->(MsUnLock())
		EndIf
		(cAliasQry)->(dbCloseArea())
	ElseIf Self:cOrigem == "D0R"
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D0R.R_E_C_N_O_ RECNOD0R
			FROM %Table:D0R% D0R
			WHERE D0R.D0R_FILIAL = %xFilial:D0R%
			AND D0R.D0R_IDDCF = %Exp:Self:cIdDCF%
			AND D0R.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			D0R->(dbGoTo((cAliasQry)->RECNOD0R))
			RecLock('D0R', .F.)
			D0R->D0R_STATUS := "2"
			D0R->D0R_IDDCF  := ""
			D0R->(MsUnLock())
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaSD1)
	RestArea(aAreaSD2)
	RestArea(aAreaSD3)
	RestArea(aAreaSD4)
	RestArea(aAreaSC9)
Return Nil
//----------------------------------------
/*/{Protheus.doc} UpdServic
Atualização do serviço
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdServic() CLASS WMSDTCOrdemServico
Local lRet      := .F.
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSD3  := SD3->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local cAliasQry := Nil
	// Atualiza dados das tabelas de Origem do documento
	If self:cOrigem == 'SD1' // Documentos de Entrada
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD1.R_E_C_N_O_ RECNOSD1
			FROM %Table:SD1% SD1
			WHERE SD1.D1_FILIAL = %xFilial:SD1%
			AND SD1.D1_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD1.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SD1->(dbGoTo((cAliasQry)->RECNOSD1))
			RecLock('SD1', .F.)
			SD1->D1_SERVIC := Self:GetServico()
			SD1->(MsUnLock())
		EndIf
		(cAliasQry)->(dbCloseArea())
	ElseIf DCF->DCF_ORIGEM == 'SD3' // Movimentos Internos
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD3.R_E_C_N_O_ RECNOSD3
			FROM %Table:SD3% SD3
			WHERE SD3.D3_FILIAL = %xFilial:SD3%
			AND SD3.D3_DOC = %Exp:Self:cDocumento%
			AND SD3.D3_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD3.%NotDel%
		EndSql
		Do While (cAliasQry)->(!Eof())
			SD3->(dbGoTo((cAliasQry)->RECNOSD3))
			RecLock('SD3', .F.)
				SD3->D3_SERVIC := Self:GetServico()
			SD3->(MsUnLock())
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	ElseIf DCF->DCF_ORIGEM == 'SC9' // Pedidos de Venda
		// Atualiza dados do documento de saida
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SC6.R_E_C_N_O_ RECNOSC6,
					SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:SC9% SC9
			INNER JOIN %Table:SC6% SC6
			ON SC6.C6_FILIAL = %xFilial:SC6%
			AND SC6.C6_NUM = SC9.C9_PEDIDO
			AND SC6.C6_ITEM = SC9.C9_ITEM
			AND SC6.C6_PRODUTO = SC9.C9_PRODUTO
			AND SC6.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_IDDCF = %Exp:Self:cIdDCF% 
			AND SC9.%NotDel%
		EndSql
		Do While (cAliasQry)->(!Eof())
			SC9->(dbGoTo((cAliasQry)->RECNOSC9))
			RecLock('SC9', .F.)
			SC9->C9_SERVIC := Self:GetServico()
			SC9->( MsUnlock())
			If SC6->C6_SERVIC <> SC9->C9_SERVIC
				SC6->(dbGoTo((cAliasQry)->RECNOSC6))
				RecLock('SC6', .F.)
				SC6->C6_SERVIC := Self:GetServico()
				SC6->( MsUnlock())
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaSD1)
	RestArea(aAreaSD3)
	RestArea(aAreaSC9)
	RestArea(aAreaSC6)
Return lRet
//----------------------------------------
/*/{Protheus.doc} HaveMovD12
Verifica se a ordem de serviço tem movimentação D12
@author felipe.m
@since 23/12/2014
@version 1.0
@param cAcao, character, (Ação a ser executada)
/*/
//----------------------------------------
METHOD HaveMovD12(cAcao) CLASS WMSDTCOrdemServico
Local lRet      := .F.
Local aAreaAnt  := GetArea()
Local cAliasD12 := GetNextAlias()
Local cQuery    := ""
Default cAcao := "1"
	// Utilzado pela funcao MaDeletDCF
	cQuery :=           "% D12.R_E_C_N_O_ RECNOD12"
	cQuery +=        " FROM "+RetSqlName('DCF')+" DCF"
	cQuery +=       " INNER JOIN "+RetSqlName('DCR')+" DCR
	cQuery +=          " ON DCR.DCR_FILIAL = '"+xFilial('DCR')+"'"
	cQuery +=         " AND DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=         " AND DCR.DCR_IDDCF  = DCF.DCF_ID"
	cQuery +=         " AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN"
	cQuery +=         " AND DCR.D_E_L_E_T_ = ' '"
	cQuery +=       " INNER JOIN "+RetSqlName('D12')+" D12
	cQuery +=          " ON D12.D12_FILIAL = '"+xFilial('D12')+"'"
	If cAcao == '1'
		cQuery +=     " AND D12.D12_STATUS IN ('1','3') "
	ElseIf cAcao == '2'
		cQuery +=     " AND D12.D12_STATUS = '2'"
	ElseIf (cAcao == '3' .OR. cAcao == '6')
		cQuery +=     " AND D12.D12_STATUS IN ('-','2','3','4')"
	ElseIf cAcao == '4'
		cQuery +=     " AND D12.D12_STATUS NOT IN ('-','2','4')"
	ElseIf cAcao == '5'
		cQuery +=     " AND D12.D12_STATUS = '3'"
	ElseIf cAcao == '7'
		cQuery +=     " AND D12.D12_STATUS = '1'"
	EndIf
	cQuery +=         " AND D12.D12_IDDCF = DCR.DCR_IDORI"
	cQuery +=         " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
	cQuery +=         " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
	cQuery +=         " AND D12.D_E_L_E_T_ = ' '"
	cQuery +=       " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	If cAcao $ "1|2|3|4"
		If WmsCarga(Self:cCarga)
			cQuery += " AND DCF.DCF_CARGA = '"+Self:cCarga+"'"
		Else
			cQuery += " AND DCF.DCF_DOCTO = '"+Self:cDocumento+"'"
			cQuery += " AND DCF.DCF_SERIE = '"+Self:cSerie+"'"
			cQuery += " AND DCF.DCF_CLIFOR = '"+Self:cCliFor+"'"
			cQuery += " AND DCF.DCF_LOJA = '"+Self:cLoja+"'"
		EndIf
		cQuery +=     " AND DCF.DCF_SERVIC = '"+Self:oServico:GetServico()+"'"
		cQuery +=     " AND DCF.DCF_LOCAL = '"+Self:oProdLote:GetArmazem()+"'"
		cQuery +=     " AND DCF.DCF_CODPRO = '"+Self:oProdLote:GetPrdOri()+"'"
	Else
		cQuery +=     " AND DCF.DCF_ID = '"+Self:cIdDCF+"'"
	EndIf
	cQuery +=         " AND DCF.DCF_SEQUEN = '"+Self:cSequen+"'"
	If cAcao <> '0'
		cQuery +=     " AND DCF.DCF_STSERV <> '0'"
	EndIf
	cQuery +=         " AND DCF.D_E_L_E_T_ = ' '"
	cQuery += "%"
	BeginSql Alias cAliasD12
		SELECT %Exp:cQuery%
	EndSql
	If (cAliasD12)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasD12)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeArmaz
Realiza a armazenagem
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD MakeArmaz() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
			// Seta o bloco de código para informações do documento
			oEstEnder:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem(Self:cOrigem),;
				oMovEstEnd:SetDocto(Self:cDocumento),;
				oMovEstEnd:SetSerie(Self:cSerie),;
				oMovEstEnd:SetCliFor(Self:cCliFor),;
				oMovEstEnd:SetLoja(Self:cLoja),;
				oMovEstEnd:SetNumSeq(Self:cNumSeq),;
				oMovEstEnd:SetIdDCF(Self:cIdDCF);
			})
			// Seta o bloco de código para informações do movimento
			oEstEnder:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdMovto(""),;
				oMovEstEnd:SetIdOpera("");
			})
			// Realiza Entrada Armazem Estoque por Endereço
			If !oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				Self:cErro := oEstEnder:GetErro()
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} UndoArmaz
Desfaz a armazenagem
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UndoArmaz() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
			// Seta o bloco de código para informações do documento
			oEstEnder:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem(Self:cOrigem),;
				oMovEstEnd:SetDocto(Self:cDocumento),;
				oMovEstEnd:SetSerie(Self:cSerie),;
				oMovEstEnd:SetCliFor(Self:cCliFor),;
				oMovEstEnd:SetLoja(Self:cLoja),;
				oMovEstEnd:SetNumSeq(Self:cNumSeq),;
				oMovEstEnd:SetIdDCF(Self:cIdDCF);
			})
			// Seta o bloco de código para informações do movimento
			oEstEnder:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdMovto(""),;
				oMovEstEnd:SetIdOpera(""),;
				oMovEstEnd:SetlUsaCal(.F.);
			})
			// Realiza Entrada Armazem Estoque por Endereço
			If !oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				Self:cErro := oEstEnder:GetErro()
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} ReverseMA
Estorno MA
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ReverseMA() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
			// Seta o bloco de código para informações do documento
			oEstEnder:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem(Self:cOrigem),;
				oMovEstEnd:SetDocto(Self:cDocumento),;
				oMovEstEnd:SetSerie(Self:cSerie),;
				oMovEstEnd:SetCliFor(Self:cCliFor),;
				oMovEstEnd:SetLoja(Self:cLoja),;
				oMovEstEnd:SetNumSeq(Self:cNumSeq),;
				oMovEstEnd:SetIdDCF(Self:cIdDCF);
			})
			// Seta o bloco de código para informações do movimento
			oEstEnder:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdMovto(""),;
				oMovEstEnd:SetIdOpera(""),;
				oMovEstEnd:SetlUsaCal(.F.);
			})
			// Realiza Entrada Armazem Estoque por Endereço
			If !oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				Self:cErro := oEstEnder:GetErro()
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} ReverseMI
Estorno MI
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ReverseMI(nQtdEst) CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local cAliasQry  := Nil
Local nProduto   := 0

Default nQtdEst := Self:nQuant
	// Atualiza Saldo
	If Self:IsMovUnit() .And. Self:oServico:HasOperac({'8'})
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D14.D14_CODUNI,
					D14.D14_PRDORI,
					D14.D14_PRODUT,
					D14.D14_LOTECT,
					D14.D14_NUMLOT,
					D14.D14_QTDEST
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D14.D14_LOCAL = %Exp:Self:oOrdEndOri:GetArmazem()%
			AND D14.D14_ENDER = %Exp:Self:oOrdEndOri:GetEnder()%
			AND D14.%NotDel%
		EndSql
		aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
		If (cAliasQry)->(!Eof())
			Do While lRet .And. (cAliasQry)->(!Eof())
				// Carrega dados para LoadData EstEnder
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oOrdEndDes:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)       // Produto Origem - Componente
				oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)      // Produto Principal
				oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:SetIdUnit(Self:cUniDes)
				oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D14_CODUNI,Self:cTipUni))
				oEstEnder:SetQuant((cAliasQry)->D14_QTDEST)
				// Realiza Saída Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
				(cAliasQry)->(DbSkip())
			EndDo
		Else
			Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	Else
		// arrega estrutura do produto x componente
		aProduto := Self:oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
				oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de Serie
				oEstEnder:SetIdUnit(Self:cUniDes)                           // Id Unitizador
				oEstEnder:LoadData()
				oEstEnder:SetQuant(QtdComp(nQtdEst * aProduto[nProduto][2]) )
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
			Next
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} ReverseMO
Estorno MO
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ReverseMO(nQtdEst) CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local lEmpPrev   := Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
Local aProduto   := {}
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local cAliasQry  := Nil
Local nProduto   := 0

Default nQtdEst := Self:nQuant
	// Atualiza Saldo
	If Self:IsMovUnit() .And. Self:oServico:HasOperac({'8'})
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D14.D14_CODUNI,
					D14.D14_PRDORI,
					D14.D14_PRODUT,
					D14.D14_LOTECT,
					D14.D14_NUMLOT,
					D14.D14_QTDEST
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D14.D14_LOCAL = %Exp:Self:oOrdEndOri:GetArmazem()%
			AND D14.D14_ENDER = %Exp:Self:oOrdEndOri:GetEnder()%
			AND D14.%NotDel%
		EndSql
		aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
		If (cAliasQry)->(!Eof())
			Do While lRet .And. (cAliasQry)->(!Eof())
				// Carrega dados para LoadData EstEnder
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oOrdEndOri:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)       // Produto Origem - Componente
				oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)      // Produto Principal
				oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:SetIdUnit(Self:cIdUnitiz)
				oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D14_CODUNI,Self:cTipUni))
				oEstEnder:SetQuant((cAliasQry)->D14_QTDEST)
				// Realiza Saída Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
				(cAliasQry)->(DbSkip())
			EndDo
		Else
			Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	Else
		// Carrega estrutura do produto x componente
		aProduto := Self:oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
				oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
				oEstEnder:SetIdUnit(Self:cIdUnitiz)
				oEstEnder:LoadData()
				oEstEnder:SetQuant(QtdComp(nQtdEst * aProduto[nProduto][2]) )
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
			Next
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeOutput
Realiza uma saída
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD MakeOutput() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local lEmpPrev   := Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
Local cAliasQry  := Nil
Local aProduto   := {}
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local nProduto   := 0
	// Atualiza Saldo
	// Se for OS de transferência unitizada
	If Self:IsMovUnit() .And. Self:oServico:HasOperac({'8'})
		// Se for uma transferência de estorno de endereçamento e a origem for um picking ou produção
		// Não possui saldo por unitizador, neste caso deve carregar o saldo inicial do unitizador
		If !Empty(Self:cIdOrigem) .And. !Empty(Self:cUniDes) .And. (Self:oOrdEndOri:GetTipoEst() == 2 .Or. Self:oOrdEndOri:GetTipoEst() == 7)
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D0R.D0R_CODUNI,
						D0S.D0S_PRDORI,
						D0S.D0S_CODPRO,
						D0S.D0S_LOTECT,
						D0S.D0S_NUMLOT,
						D0S.D0S_QUANT
				FROM %Table:D0S% D0S
				INNER JOIN %Table:D0R% D0R
				AND D0R.D0R_FILIAL = %xFilial:D0R%
				AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT
				AND D0R.%NotDel%
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:Self:cUniDes%
				AND D0S.%Notdel%
			EndSql
			aTamSX3 := TamSx3("D0S_QUANT"); TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
					oEstEnder:oProdLote:SetArmazem(Self:oOrdEndOri:GetArmazem()) // Armazem
					oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0S_PRDORI)       // Produto Origem - Componente
					oEstEnder:oProdLote:SetProduto((cAliasQry)->D0S_CODPRO)      // Produto Principal
					oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0S_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote((cAliasQry)->D0S_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:SetIdUnit("") // Picking não controla unitizador
					oEstEnder:SetTipUni("") // Picking não controla unitizador
					oEstEnder:SetQuant((cAliasQry)->D0S_QUANT)
					// Realiza Saída Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0011,{{"[VAR01]",Self:cUniDes}}) // Não foi encontrado o saldo dos produtos recebidos no unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		Else
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D14.D14_CODUNI,
						D14.D14_PRDORI,
						D14.D14_PRODUT,
						D14.D14_LOTECT,
						D14.D14_NUMLOT,
						D14.D14_QTDEST
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
				AND D14.D14_LOCAL = %Exp:Self:oOrdEndOri:GetArmazem()%
				AND D14.D14_ENDER = %Exp:Self:oOrdEndOri:GetEnder()%
				AND D14.%NotDel%
			EndSql
			aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
					oEstEnder:oProdLote:SetArmazem(Self:oOrdEndOri:GetArmazem()) // Armazem
					oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)       // Produto Origem - Componente
					oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)      // Produto Principal
					oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:SetIdUnit(Self:cIdUnitiz)
					oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D14_CODUNI,Self:cTipUni))
					oEstEnder:SetQuant((cAliasQry)->D14_QTDEST)
					// Realiza Saída Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:cIdUnitiz}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	Else
		// Carrega estrutura do produto x componente
		aProduto := Self:oProdLote:GetArrProd()
		// Verifica se há produtos
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndOri:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndOri:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
				oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
				oEstEnder:SetIdUnit(Self:cIdUnitiz)                         // Id Unitizador
				oEstEnder:LoadData()
				oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
				// Realiza Saída Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
			Next
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeInput
Realiza uma entrada
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD MakeInput() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aProduto   := {}
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local cAliasQry  := Nil
Local nProduto   := 0
	// Atualiza Saldo
	// Se for OS unitizada
	If Self:IsMovUnit()
		// Se for uma transferência de estorno de endereçamento e a origem for um picking ou produção
		// Não possui saldo por unitizador, neste caso deve carregar o saldo inicial do unitizador
		If Self:oServico:HasOperac({'8'}) .And. !Empty(Self:cIdOrigem) .And. !Empty(Self:cUniDes) .And. (Self:oOrdEndOri:GetTipoEst() == 2 .Or. Self:oOrdEndOri:GetTipoEst() == 7)
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D0R.D0R_CODUNI,
						D0S.D0S_PRDORI,
						D0S.D0S_CODPRO,
						D0S.D0S_LOTECT,
						D0S.D0S_NUMLOT,
						D0S.D0S_QUANT
				FROM %Table:D0S% D0S
				INNER JOIN %Table:D0R% D0R
				AND D0R.D0R_FILIAL = %xFilial:D0R%
				AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT
				AND D0R.%NotDel%
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:Self:cUniDes%
				AND D0S.%NotDel%
			EndSql
			aTamSX3 := TamSx3("D0S_QUANT"); TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
					oEstEnder:oProdLote:SetArmazem(Self:oOrdEndDes:GetArmazem()) // Armazem
					oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0S_PRDORI)       // Produto Origem - Componente
					oEstEnder:oProdLote:SetProduto((cAliasQry)->D0S_CODPRO)      // Produto Principal
					oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0S_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote((cAliasQry)->D0S_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:SetIdUnit(Self:cUniDes)
					oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D0R_CODUNI,Self:cTipUni))
					oEstEnder:SetQuant((cAliasQry)->D0S_QUANT)
					// Realiza Entrada Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0011,{{"[VAR01]",Self:cUniDes}}) // Não foi encontrado o saldo dos produtos recebidos no unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		Else
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D14.D14_CODUNI,
						D14.D14_PRDORI,
						D14.D14_PRODUT,
						D14.D14_LOTECT,
						D14.D14_NUMLOT,
						D14.D14_QTDEST
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
				AND D14.D14_LOCAL = %Exp:Self:oOrdEndOri:GetArmazem()%
				AND D14.D14_ENDER = %Exp:Self:oOrdEndOri:GetEnder()%
				AND D14.%NotDel%
			EndSql
			aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
					oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
					oEstEnder:oProdLote:SetArmazem(Self:oOrdEndDes:GetArmazem()) // Armazem
					oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)       // Produto Origem - Componente
					oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)      // Produto Principal
					oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)      // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)      // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:SetIdUnit(Self:cUniDes)
					oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasQry)->D14_CODUNI,Self:cTipUni))
					oEstEnder:SetQuant((cAliasQry)->D14_QTDEST)
					// Realiza Entrada Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:cUniDes}}) // Não foi encontrado o saldo por endereço do unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	Else
		// Carrega estrutura do produto x componente
		aProduto := Self:oProdLote:GetArrProd()
		// Verifica se há produtos
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(Self:oOrdEndDes:GetArmazem())
				oEstEnder:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
				oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
				oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
				oEstEnder:SetIdUnit(Self:cUniDes)                           // Id Unitizador
				oEstEnder:SetTipUni(Self:cTipUni)
				oEstEnder:LoadData()
				oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
			Next
		EndIf
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} SaiMovEst
Realiza uma movimentação do estoque de saida
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD SaiMovEst() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local cAliasD13  := Nil
	// Atualiza Saldo
	// Busca dados do kardex
	cAliasD13 := GetNextAlias()
	BeginSql Alias cAliasD13
		SELECT D13.R_E_C_N_O_ RECNOD13
		FROM %Table:D13% D13
		WHERE D13.D13_FILIAL = %xFilial:D13%
		AND D13.D13_ORIGEM = %Exp:Self:cOrigem%
		AND D13.D13_DOC = %Exp:Self:cDocumento%
		AND D13.D13_SERIE = %Exp:Self:cSerie%
		AND D13.D13_CLIFOR = %Exp:Self:cCliFor%
		AND D13.D13_LOJA = %Exp:Self:cLoja%
		AND D13.D13_NUMSEQ = %Exp:Self:cNumSeq%
		AND D13.D13_IDDCF = %Exp:Self:cIdDCF%
		AND D13.D13_USACAL <> '2'
		AND D13.%NotDel%
	EndSql
	Do While lRet .And. (cAliasD13)->(!Eof())
		// Posiciona D13
		D13->(dbGoTo((cAliasD13)->RECNOD13))
		// Atualiza dados
		Reclock("D13",.F.)
		D13->D13_DTESTO := dDataBase
		D13->D13_HRESTO := Time()
		D13->D13_USACAL := "2"
		D13->(MsUnlock())
		
		(cAliasD13)->(dbSkip())
	EndDo
	(cAliasD13)->(dbCloseArea())
Return lRet
//----------------------------------------
/*/{Protheus.doc} ChkOrdDep
Verifica de a ordem de serviço possui dependente
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ChkOrdDep() CLASS WMSDTCOrdemServico
Local lRet       := .F.
Local aAreaAnt   := GetArea()
Local cAliasDCF  := GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT DCF.DCF_ID
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_IDORI = %Exp:Self:cIdDCF%
		AND DCF.DCF_STSERV <> '0'
		AND DCF.%NotDel%
	EndSql
	If (cAliasDCF)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} CancelSC9
Cancela a ordem de serviço
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD CancelSC9(lEstPed,nRecnoSC9,nQtdQuebra,lPedFat) CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local lPedEmp    := .F.
Local lMovFin    := .F.
Local aAreaSC9   := SC9->(GetArea())
Local oOrdSerDel := Nil
Local cAliasSDC  := Nil

Default lEstPed    := .F.
Default lPedFat    := .F.
Default nQtdQuebra := 0
	If nRecnoSC9 > 0
		SC9->(dbGoTo(nRecnoSC9))
		Self:SetIdDCF(SC9->C9_IDDCF)
		If Self:LoadData()
			// Estorno parcial da sequencia SC9
			If QtdComp(nQtdQuebra) <= 0
				nQtdQuebra := SC9->C9_QTDLIB
			EndIf

			If !lPedFat
				// Verifica se pedido já está empenhado
				cAliasSDC := GetNextAlias()
				BeginSql Alias cAliasSDC
					SELECT 1
					FROM %Table:SDC% SDC
					WHERE SDC.DC_FILIAL = %xFilial:SDC%
					AND SDC.DC_PRODUTO = %Exp:SC9->C9_PRODUTO%
					AND SDC.DC_LOCAL = %Exp:SC9->C9_LOCAL%
					AND SDC.DC_ORIGEM = 'SC6'
					AND SDC.DC_PEDIDO = %Exp:SC9->C9_PEDIDO%
					AND SDC.DC_ITEM = %Exp:SC9->C9_ITEM%
					AND SDC.DC_SEQ = %Exp:SC9->C9_SEQUEN%
					AND SDC.DC_LOTECTL = %Exp:SC9->C9_LOTECTL%
					AND SDC.DC_NUMLOTE = %Exp:SC9->C9_NUMLOTE%
					AND SDC.DC_LOCALIZ = %Exp:SC9->C9_ENDPAD%
					AND SDC.DC_NUMSERI = %Exp:SC9->C9_NUMSERI%
					AND SDC.%NotDel%
				EndSql
				If (cAliasSDC)->(!Eof())
					lPedEmp := .T.
				EndIf
				(cAliasSDC)->(dbCloseArea())
			EndIf
			// Verifica se existe movimento finalizado, onde a primeira sequencia foi faturada e a segunda ainda
			// não foi separa no WMS, porém possuem o mesmo IDDCF/Ordem de Serviço.
			lMovFin := Self:HaveMovD12("7")
			// Verifica se ordem de servico executada com pedido empenhado
			If Self:GetStServ() == "3"
				lRet := Self:EstParcial(nRecnoSC9,nQtdQuebra,lPedEmp)
			Else
				oOrdSerDel := WMSDTCOrdemServicoDelete():New()
				oOrdSerDel:SetIdDCF(Self:GetIdDCF())
				If oOrdSerDel:LoadData()
					oOrdSerDel:SetQtdDel(nQtdQuebra)
					If !oOrdSerDel:DeleteDCF()
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		RestArea(aAreaSC9)
	Else
		lRet := .F.
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} ChkDepPend
Verifica dependentes pendentes
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ChkDepPend(cIdDCF) CLASS WMSDTCOrdemServico
Local lRet      := .F.
Local aAreaAnt  := GetArea()
Local cAliasDCF := GetNextAlias()

Default cIdDCF := Self:cIdDCF

	// Procura por DCF com o Id Origem preenchido
	BeginSql Alias cAliasDCF
		SELECT DCF.DCF_DOCTO,
				DCF.DCF_PRDORI
		FROM %Table:DCF% DCF
		INNER JOIN %Table:DC5% DC5
		ON DC5.DC5_FILIAL = %xFilial:DC5%
		AND DC5.DC5_SERVIC = DCF.DCF_SERVIC
		AND DC5.DC5_OPERAC <> '5'
		AND DC5.%NotDel%
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_IDORI = %Exp:cIdDCF%
		AND DCF.DCF_STSERV <> '0'
		AND DCF.%NotDel%
		// Verifica se foi executada, porém não finalizada
		AND (EXISTS (SELECT 1
						FROM %Table:D12% D121
						WHERE D121.D12_FILIAL = %xFilial:D12%
						AND DCF.DCF_FILIAL = %xFilial:DCF%
						AND D121.D12_IDDCF = DCF.DCF_ID
						AND D121.D12_SEQUEN = DCF.DCF_SEQUEN
						AND D121.D12_STATUS IN ('2','3','4')
						AND D121.%NotDel% )
		// Verifica se nao existe D12, ou seja, não foi executada
		OR NOT EXISTS (SELECT 1
						FROM %Table:D12% D122
						WHERE D122.D12_FILIAL = %xFilial:D12%
						AND DCF.DCF_FILIAL = %xFilial:DCF%
						AND D122.D12_IDDCF = DCF.DCF_ID
						AND D122.D12_SEQUEN = DCF.DCF_SEQUEN
						AND D122.%NotDel% )
						AND NOT EXISTS
							(SELECT 1 FROM %Table:DCR% DCR
								INNER JOIN %Table:D12% D123 
									ON (DCR.DCR_FILIAL  = %xFilial:D12%
									AND DCR.DCR_IDORI  = D123.D12_IDDCF 
									AND DCR.DCR_IDMOV  = D123.D12_IDMOV 
									AND DCR.DCR_IDOPER = D123.D12_IDOPER
									AND DCR.DCR_SEQUEN = D123.D12_SEQUEN
									AND DCR.%NotDel%)
								WHERE D123.D12_FILIAL = %xFilial:D12%
									AND DCF.DCF_FILIAL = %xFilial:DCF%
									AND DCR.DCR_IDDCF  = DCF.DCF_ID
									AND D123.D12_SEQUEN = DCF.DCF_SEQUEN
									AND D123.D12_IDDCF = DCR.DCR_IDORI
									AND D123.D12_STATUS NOT IN ('2','3','4')
									AND D123.%NotDel%))
	EndSql
	If (cAliasDCF)->(!Eof())
		Self:cErro := WmsFmtMsg(STR0018,{{"[VAR01]",(cAliasDCF)->DCF_DOCTO},{"[VAR02]",(cAliasDCF)->DCF_PRDORI}}) // Documento : [VAR01]/ Produto: [VAR02] pendente de execução ou finalização!
		lRet := .T.
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} ExisteDCF
Verifica se existe DCF
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ExisteDCF() CLASS WMSDTCOrdemServico
Local lRet      := .F.
Local aAreaAnt  := GetArea()
Local cAliasDCF := GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT DCF.DCF_ID
		FROM %table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ID = %Exp:Self:cIdDCF%
		AND DCF.DCF_STSERV <> '0'
		AND DCF.%NotDel%
	EndSql
	If (cAliasDCF)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} FindDocto
Procura o documento
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD FindDocto() CLASS WMSDTCOrdemServico
Local aAreaAnt   := GetArea()
Local cDocumento := ""
Local cAliasDCF  := GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT DCF.DCF_DOCTO
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_IDORI = %Exp:Self:cIdDCF%
		AND DCF.DCF_STSERV = '1'
		AND DCF.%NotDel%
	EndSql
	If (cAliasDCF)->(!Eof())
		cDocumento := (cAliasDCF)->DCF_DOCTO
	EndIf
	// Busca dados servico
	If Empty(cDocumento)
		cDocumento :=  GetSX8Num('DCF', 'DCF_DOCTO'); ConfirmSx8()
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cDocumento
//----------------------------------------
/*/{Protheus.doc} UpdEndDCF
Atualiza endereço DCF
@author felipe.m
@since 23/12/2014
@version 1.0
@param cEndereco, character, (Descrição do parâmetro)
@param lEndVazio, ${param_type}, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD UpdEndDCF(cEndereco,lEndVazio) CLASS WMSDTCOrdemServico
Local aArea      := GetArea()
Local oOrdSerAux := WMSDTCOrdemServico():New()
Local cAliasQry  := GetNextAlias()

Default lEndVazio := .T. // Atualiza somente OS sem informação de endereço ou atualiza tudo
	If lEndVazio
		BeginSql Alias cAliasQry
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_DOCTO = %Exp:Self:cDocumento%
			AND DCF.DCF_SERIE = %Exp:Self:cSerie%
			AND DCF.DCF_CLIFOR = %Exp:Self:cCliFor%
			AND DCF.DCF_LOJA = %Exp:Self:cLoja%
			AND DCF.DCF_CODPRO = %Exp:Self:oProdLote:GetPrdOri()%
			AND DCF.DCF_ORIGEM = 'SC9'
			AND DCF.DCF_STSERV IN ('1','2')
			AND DCF.DCF_ENDER = ' '
			AND DCF.DCF_ESTFIS = ' '
			AND DCF.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_DOCTO = %Exp:Self:cDocumento%
			AND DCF.DCF_SERIE = %Exp:Self:cSerie%
			AND DCF.DCF_CLIFOR = %Exp:Self:cCliFor%
			AND DCF.DCF_LOJA = %Exp:Self:cLoja%
			AND DCF.DCF_CODPRO = %Exp:Self:oProdLote:GetPrdOri()%
			AND DCF.DCF_ORIGEM = 'SC9'
			AND DCF.DCF_STSERV IN ('1','2')
			AND DCF.%NotDel%
		EndSql
	EndIf
	Do While (cAliasQry)->(!Eof())
		oOrdSerAux:GoToDCF((cAliasQry)->RECNODCF)
		oOrdSerAux:oOrdEndDes:SetEnder(cEndereco)
		oOrdSerAux:oOrdEndDes:LoadData()
		oOrdSerAux:UpdateDCF()
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return lRet
//----------------------------------------
/*/{Protheus.doc} ChkDistr
Verifica distribuição
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ChkDistr() CLASS WMSDTCOrdemServico
Local lRet      := .T.
Local cAliasNew := GetNextAlias()

	BeginSql Alias cAliasNew
		SELECT 1
		FROM %Table:SD1% SD1
		INNER JOIN %Table:D06% D06 
		ON D06.D06_FILIAL = %xFilial:D06%
		AND D06.D06_CODDIS = SD1.D1_CODDIS
		AND D06.D06_SITDIS IN ('1','2')
		AND D06.%NotDel%
		INNER JOIN %Table:D07% D07 
		ON D07.D07_FILIAL = %xFilial:D07%
		AND D07.D07_CODDIS = SD1.D1_CODDIS
		AND D07.D07_DOC = SD1.D1_DOC
		AND D07.D07_SERIE = SD1.D1_SERIE
		AND D07.D07_FORNEC = SD1.D1_FORNECE
		AND D07.D07_LOJA = SD1.D1_LOJA
		AND D07.D07_PRODUT = SD1.D1_COD
		AND D07.D07_ITEM = SD1.D1_ITEM
		AND D07.%NotDel%
		INNER JOIN %Table:D0F% D0F
		ON D0F.D0F_FILIAL = %xFilial:D0F%
		AND D0F.D0F_CODDIS = SD1.D1_CODDIS
		AND D0F.D0F_DOC = SD1.D1_DOC
		AND D0F.D0F_SERIE = SD1.D1_SERIE
		AND D0F.D0F_FORNEC = SD1.D1_FORNECE
		AND D0F.D0F_LOJA = SD1.D1_LOJA
		AND D0F.D0F_PRODUT = SD1.D1_COD
		AND D0F.D0F_ITEM = SD1.D1_ITEM
		AND D0F.%NotDel%
		WHERE SD1.D1_FILIAL = %xFilial:SD1%
		AND SD1.D1_DOC = %Exp:Self:cDocumento%
		AND SD1.D1_SERIE = %Exp:Self:cSerie%
		AND SD1.D1_FORNECE = %Exp:Self:cCliFor%
		AND SD1.D1_LOJA = %Exp:Self:cLoja%
		AND SD1.D1_COD = %Exp:Self:oProdLote:GetProduto()%
		AND SD1.D1_IDDCF = %Exp:Self:cIdDCF%
		AND SD1.D1_CODDIS <> '  '
		AND SD1.%NotDel%
	EndSql
	lRet := (cAliasNew)->(!Eof())
	(cAliasNew)->(dbCloseArea())
Return lRet
//----------------------------------------
/*/{Protheus.doc} ShowWarnig
Mostra a mensagem de erro
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD ShowWarnig() CLASS WMSDTCOrdemServico
Local nCntFor := 0
Local cMemo   := ""
Local cMask   := STR0017 // Arquivos Texto (*.TXT) |*.txt|
Local cFile   := Space(100)
Local cTitle  := OemToAnsi(OemToAnsi(STR0019)) // Salvar Aquivo
	If !Empty(Self:aWmsAviso)
		For nCntFor := 1 To Len(Self:aWmsAviso)
			If nCntFor == 1
				cMemo := Self:aWmsAviso[nCntFor]
			Else
				cMemo += CRLF+Self:aWmsAviso[nCntFor]
			EndIf
		Next
		If Self:HasLogEnd()
			cMemo += CRLF+Replicate('*',90)
			cMemo += CRLF+STR0008 // Para ordens de serviço de endereçamento com problemas, execute manual as ordens de serviço interrompidas e analise o relatório de busca de endereço.
		EndIf
		If Self:HasLogSld()
			cMemo += CRLF+Replicate('*',90)
			cMemo += CRLF+STR0009 // Para ordens de serviço de expedição com problemas, execute manual as ordens de serviço interrompidas e analise o relatório de busca de saldo.
		EndIf
		If WmsMsgExibe()
			DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15
			
			DEFINE MSDIALOG oDlg TITLE "SIGAWMS" From 3,0 to 340,717 PIXEL
			
			@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 351,145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont
			
			DEFINE SBUTTON  FROM 153,330 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL // Apaga
			DEFINE SBUTTON  FROM 153,300 TYPE 13 ACTION (cFile:=cGetFile(cMask,cTitle),If(cFile="",.T.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL // Salva e Apaga //"Salvar Como..."

			ACTIVATE MSDIALOG oDlg CENTER
		Else
			WmsMessage(cMemo,"ShowWarnig")
		EndIf
		// Limpa as mensagens anteriores
		Self:aWmsAviso := {}
	EndIf
Return

METHOD AtuMovSD3() CLASS WMSDTCOrdemServico
Local lRet      := .T.
Local lMontagem := .T.
Local aAreaD0A  := D0A->(GetArea())
Local cProcesso := ""
Local cAliasD0A := Nil
	cAliasD0A := GetNextAlias()
	BeginSql Alias cAliasD0A
		SELECT D0A.D0A_PROCES,
				D0A.D0A_OPERAC
		FROM %Table:D0A% D0A
		WHERE D0A.D0A_FILIAL = %xFilial:D0A%
		AND D0A.D0A_DOC = %Exp:Self:GetDocto()%
		AND D0A.%NotDel%
	EndSql
	If (cAliasD0A)->(!Eof())
		lMontagem := ((cAliasD0A)->D0A_OPERAC == "1")
		cProcesso := (cAliasD0A)->D0A_PROCES
		If cProcesso == "1"     // Process de montagem/desmontagem de estruturas
			lRet := Self:MovSD3Estr(lMontagem)
		ElseiF cProcesso == "2" //Processo de montagem/desmontagem de produtos
			lRet := Self:MovSD3Prod()
		ElseIf cProcesso == "3" // Processo de troca de lotes
			lRet := Self:MovSD3Lote()
		EndIf
	EndIf
	(cAliasD0A)->(dbCloseArea())
	RestArea(aAreaD0A)
Return lRet

METHOD UndoMovSD3() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aAreaD0A   := D0A->(GetArea())
Local aAreaSD3   := SD3->(GetArea())
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local aLockProds := {}
Local aApont     := {}
Local cAliasD0A  := nIL
Local cAliasD0B  := Nil
Local cAliasSD3  := Nil

Private lMsErroAuto := .F.
Private lExecWms    := Nil
Private lDocWms     := Nil

	cAliasD0A := GetNextAlias()
	BeginSql Alias cAliasD0A
		SELECT D0A.D0A_OPERAC
		FROM %Table:D0A% D0A
		WHERE D0A.D0A_FILIAL = %xFilial:D0A%
		AND D0A.D0A_DOC = %Exp:Self:GetDocto()%
		AND D0A.%NotDel%
	EndSql
	If (cAliasD0A)->(!Eof())
		If (cAliasD0A)->D0A_OPERAC == "2"
			// Estorno de uma Desmontagem
			cAliasD0B := GetNextAlias()
			BeginSql Alias cAliasD0B
				SELECT D0B.D0B_LOCAL,
						D0B.D0B_PRDORI
				FROM %Table:D0B% D0B
				WHERE D0B.D0B_FILIAL = %xFilial:D0B%
				AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
				AND D0B.%NotDel%
				GROUP BY D0B.D0B_LOCAL,
							D0B.D0B_PRDORI
			EndSql
			Do While (cAliasD0B)->(!Eof())
				aAdd(aLockProds, {(cAliasD0B)->D0B_PRDORI,;  // Produto
				(cAliasD0B)->D0B_LOCAL})   // Armazém
				(cAliasD0B)->(dbSkip())
			EndDo
			(cAliasD0B)->(dbCloseArea())
			cAliasSD3 := GetNextAlias()
			BeginSql Alias cAliasSD3
				SELECT DISTINCT SD3.D3_NUMSEQ
				FROM %Table:SD3% SD3
				WHERE SD3.D3_FILIAL = %xFilial:SD3%
				AND SD3.D3_DOC = %Exp:Self:GetDocto()%
				AND SD3.D3_ESTORNO <> 'S'
				AND SD3.%NotDel%
			EndSql
			Do While (cAliasSD3)->(!Eof())
				oEstEnder:EstDesSD3(aLockProds, (cAliasSD3)->D3_NUMSEQ, (cAliasD0A)->D0A_OPERAC)
				(cAliasSD3)->(dbSkip())
			EndDo
			(cAliasSD3)->(dbCloseArea())

		ElseIf (cAliasD0A)->D0A_OPERAC == "1"
			// Estorno de uma Montagem
			cAliasD0B := GetNextAlias()
			BeginSql Alias cAliasD0B
				SELECT D0B.D0B_LOCAL,
						D0B.D0B_PRDORI,
						SD3.D3_NUMSEQ,
						CASE WHEN (D0B.D0B_PRDORI = D0A.D0A_PRODUT)  THEN '0' ELSE '1' END D0A_ORDEM
				FROM %Table:D0B% D0B
				INNER JOIN %Table:D0A% D0A
				ON D0A.D0A_FILIAL = %xFilial:D0A%
				AND D0A.D0A_DOC = D0B.D0B_DOC
				AND D0A.%NotDel%
				INNER JOIN %Table:SD3% SD3
				ON SD3.D3_FILIAL = %xFilial:SD3%
				AND SD3.D3_DOC = D0B.D0B_DOC
				AND SD3.D3_LOCAL = D0B.D0B_LOCAL
				AND SD3.D3_COD = D0B.D0B_PRDORI
				AND SD3.D3_LOTECTL = D0B.D0B_LOTECT
				AND SD3.D3_NUMLOTE = D0B.D0B_NUMLOT
				AND SD3.%NotDel%
				WHERE D0B.D0B_FILIAL = %xFilial:D0B%
				AND D0B_DOC = %Exp:Self:GetDocto()%
				AND D0B.%NotDel%
				GROUP BY D0B.D0B_LOCAL,
							D0B.D0B_PRDORI,
							SD3.D3_NUMSEQ,
							D0A.D0A_PRODUT
				ORDER BY D0A_ORDEM
			EndSql
			Do While (cAliasD0B)->(!Eof())
				cAliasSD3 := GetNextAlias()
				BeginSql Alias cAliasSD3
					SELECT SD3.D3_DOC,
							SD3.D3_OP,
							SD3.D3_COD,
							SD3.D3_UM,
							SD3.D3_QUANT,
							SD3.D3_LOCAL,
							SD3.D3_CC,
							SD3.D3_EMISSAO,
							SD3.D3_LOTECTL,
							SD3.D3_DTVALID,
							SD3.D3_NUMSEQ,
							SD3.D3_CHAVE,
							SD3.D3_ESTORNO,
							SD3.R_E_C_N_O_ RECNOSD3
					FROM %Table:SD3% SD3
					WHERE SD3.D3_FILIAL = %xFilial:SD3%
					AND SD3.D3_COD = %Exp:(cAliasD0B)->D0B_PRDORI%
					AND SD3.D3_LOCAL = %Exp:(cAliasD0B)->D0B_LOCAL%
					AND SD3.D3_NUMSEQ = %Exp:(cAliasD0B)->D3_NUMSEQ%
					AND SD3.%NotDel%
				EndSql
				If (cAliasSD3)->(!Eof())
					aApont := {}
					If (cAliasD0B)->D0A_ORDEM == "0"
						Aadd(aApont,{"D3_DOC"    ,(cAliasSD3)->D3_DOC         ,Nil})
						Aadd(aApont,{"D3_OP"     ,(cAliasSD3)->D3_OP          ,Nil})
						Aadd(aApont,{"D3_COD"    ,(cAliasSD3)->D3_COD         ,Nil})
						Aadd(aApont,{"D3_UM"     ,(cAliasSD3)->D3_UM          ,Nil})
						Aadd(aApont,{"D3_QUANT"  ,(cAliasSD3)->D3_QUANT       ,Nil})
						Aadd(aApont,{"D3_LOCAL"  ,(cAliasSD3)->D3_LOCAL       ,Nil})
						Aadd(aApont,{"D3_CC"     ,(cAliasSD3)->D3_CC          ,Nil})
						Aadd(aApont,{"D3_EMISSAO",(cAliasSD3)->D3_EMISSAO     ,Nil})
						If Rastro((cAliasSD3)->D3_COD)
							Aadd(aApont,{"D3_LOTECTL",(cAliasSD3)->D3_LOTECTL ,Nil})
							Aadd(aApont,{"D3_DTVALID",(cAliasSD3)->D3_DTVALID ,Nil})
						EndIf
						Aadd(aApont,{"D3_NUMSEQ" ,(cAliasSD3)->D3_NUMSEQ      ,Nil})
						Aadd(aApont,{"D3_CHAVE"  ,(cAliasSD3)->D3_CHAVE       ,Nil})
						Aadd(aApont,{"D3_CF"     ,"PR0"                       ,Nil})
						aAdd(aApont,{"INDEX"     , 4                          ,Nil})
	
						lMsErroAuto := .F.
						lExecWms := .T.
						// Estorno automático do apontamento da ordem de produção
						MsExecAuto({|x,y| MATA250(x,y)},aApont,5)
						If lMsErroAuto
							// Erro na criação da SD3 pelo MsExecAuto
							MostraErro()
							If Intransaction()
								DisarmTransaction()
							EndIf
							lRet := .F.
							Exit
						EndIf
					Else
						Do While (cAliasSD3)->(!Eof())
							If (cAliasSD3)->D3_ESTORNO != "S"
								SD3->(dbGoTo((cAliasSD3)->RECNOSD3))
								// Indica que será DH1 e DCF
								lExecWms := .T.
								lDocWms  := .T.
								lMsErroAuto := .F.
								// Estorno do movimento de requisição
								MsExecAuto({|x,y,z| MATA241(x,y,z)},{},Nil,6)
								If lMsErroAuto
									// Erro na criação da SD3 pelo MsExecAuto
									MostraErro()
									If Intransaction()
										DisarmTransaction()
									EndIf
									lRet := .F.
									Exit
								EndIf
							EndIf
							(cAliasSD3)->(dbSkip())
						EndDo
					EndIf
					(cAliasSD3)->(dbCloseArea())
					If !lRet
						Exit
					EndIf
				EndIf
				(cAliasD0B)->(dbSkip())
			EndDo
			(cAliasD0B)->(dbCloseArea())
		EndIf
	EndIf
	oEstEnder:Destroy()
	RestArea(aAreaD0A)
	RestArea(aAreaSD3)
Return lRet

METHOD UpdEmpSB2(cOper,cPrdOri,cArmazem,nQuant,lReserva,cTipOp)  CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aAreaSB2   := SB2->(GetArea())
Local nValNovo := 0
Default lReserva := .T.
Default cTipOp   := ""

	// Reversa produto
	SB2->(dbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
	If SB2->(dbSeek(xFilial("SB2")+cPrdOri+cArmazem))
		nValNovo := SB2->B2_RESERVA + (nQuant * (Iif(cOper == "-",-1,1)))
		GravaB2Emp(cOper,nQuant,cTipOp,lReserva)
		lRet := B2_RESERVA = nValNovo
		If !lRet
			Self:cErro := STR0060 //Erro ao atualizar Reserva do Estoque (B2_RESERVA)
		EndIf		
	EndIf
	RestArea(aAreaSB2)

Return lRet

METHOD UpdEmpSB8(cOper,cPrdOri,cArmazem,cLoteCtl, cNumLote, nQuant)  CLASS WMSDTCOrdemServico
Local lRet     := .T.
Local aAreaSB8 := SB8->(GetArea())
Local nValNovo := 0

	// Empenha Lote
	SB8->(dbSetOrder(3))	// B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	If SB8->(dbSeek(xFilial("SB8")+cPrdOri+cArmazem+cLoteCtl+Padr(cNumLote,TamSx3("B8_NUMLOTE")[1])))
		WmsConout('Gravação de empenho SB8 (GravaSB8Emp) ' + cOper + ' / ' + cValToChar(nQuant))
		nValNovo := SB8->B8_EMPENHO + (nQuant * (Iif(cOper == "-",-1,1)))
		GravaB8Emp(cOper,nQuant,Nil,.T.)
		lRet := B8_EMPENHO = nValNovo
		If !lRet
			Self:cErro := STR0061 //Erro ao atualizar Empenho do Estoque por Lote (B8_EMPENHO)
		EndIf		
	EndIf
	RestArea(aAreaSB8)

Return lRet

METHOD UpdEmpSD4(lExcluir) CLASS WMSDTCOrdemServico
Local lRet := .T.
Local cOp  := PadR("",TamSx3("D4_OP")[1])
Local cTrt := PadR("",TamSx3("D4_TRT")[1])

Default lExcluir := .F.

	dbSelectArea("SD4")
	SD4->(dbSetOrder(1)) // D4_FILIAL+D4_COD+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE
	// D4_FILIAL, D4_COD, D4_OP, D4_TRT, D4_LOTECTL, D4_NUMLOTE, D4_LOCAL, D4_ORDEM, D4_OPORIG, D4_SEQ, R_E_C_D_E_L_
	If !SD4->(dbSeek(xFilial("SD4")+Self:oProdLote:GetPrdOri()+cOp+cTrt+Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote()))
		RecLock("SD4", .T.)
		SD4->D4_FILIAL  := xFilial("SD4")
		SD4->D4_COD     := Self:oProdLote:GetPrdOri()
		SD4->D4_LOCAL   := Self:oProdLote:GetArmazem()
		SD4->D4_OP      := cOp
		SD4->D4_TRT     := cTrt
		SD4->D4_LOTECTL := Self:oProdLote:GetLoteCtl()
		SD4->D4_NUMLOTE := Self:oProdLote:GetNumLote()
		SD4->D4_DATA    := dDataBase
		SD4->D4_QUANT   := Self:nQuant
		SD4->D4_QTSEGUM := ConvUM(Self:oProdLote:GetPrdOri(), SD4->D4_QUANT, 0, 2)
		SD4->D4_QTDEORI := SD4->D4_QUANT
		SD4->D4_IDDCF   := Self:cIdDCF
		SD4->(MsUnlock())
		// Grava empenho SB2
		GravaEmp(Self:oProdLote:GetProduto(),; //1
		Self:oProdLote:GetArmazem(),;   //2
		Self:nQuant,;     //3
		Nil,;             //4
		Self:oProdLote:GetLoteCtl(),; //5
		Self:oProdLote:GetNumLote(),; //6
		Nil,;             //7
		Nil,;             //8
		Nil,;             //9
		,;                //10
		,;                //11
		,;                //12
		"SD3",;           //13
		Nil,;             //14
		Nil,;             //15
		Nil,;             //16
		.F.,;             //17
		.F.,;             //18
		.T.,;             //19
		.F.,;             //20
		!Empty(Self:oProdLote:GetLoteCtl()+Self:oProdLote:GetNumLote()),; //21
		.T.,;             //22
		.F.,;             //23
		.F.,;             //24
		Self:cIdDCF) //25
	Else
		lRet := .F.
	EndIf
Return lRet

METHOD GetSeqPri() CLASS WMSDTCOrdemServico
	If Empty(Self:cSeqPriExe)
		Self:cSeqPriExe := Self:FindSeqPri()
	EndIf
Return Self:cSeqPriExe

METHOD FindSeqPri() CLASS WMSDTCOrdemServico
Local aAreaAnt  := GetArea()
Local cAliasD12 := Nil
Local cVazioSeq := Space(TamSx3("D12_SEQPRI")[1])
Local cSeqPri   := ""
	cAliasD12 := GetNextAlias()
	If WmsCarga(Self:cCarga)
		BeginSql Alias cAliasD12
			SELECT D12.D12_SEQPRI
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_CARGA = %Exp:Self:cCarga%
			AND D12.D12_SEQPRI <> %Exp:cVazioSeq%
			AND D12.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasD12
			SELECT D12.D12_SEQPRI
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_DOC = %Exp:Self:cDocumento%
			AND D12.D12_CLIFOR = %Exp:Self:cCliFor%
			AND D12.D12_LOJA = %Exp:Self:cLoja%
			AND D12.D12_SEQPRI <> %Exp:cVazioSeq%
			AND D12.%NotDel%
		EndSql
	EndIf
	If (cAliasD12)->( !Eof())
		cSeqPri := (cAliasD12)->D12_SEQPRI
	EndIf
	(cAliasD12)->(dbCloseArea())
	If Empty(cSeqPri)
		cSeqPri := Self:NextSeqPri('MV_WMSSQPR','D12_SEQPRI') // Proxima sequencia da execucao dos servicos
	EndIf
	RestArea(aAreaAnt)
Return cSeqPri
//--------------------------------------------------
/*/{Protheus.doc} NextSeqPri
Proxima sequencia de prioridade
@author felipe.m
@since 23/12/2014
@version 1.0
@param cParametro, character, (Parametro)
@param cField, character, (Campos)
/*/
//--------------------------------------------------
METHOD NextSeqPri(cParametro, cField) CLASS WMSDTCOrdemServico
Local cCodAnt := ""
Local nC      := 0
	Do While !LockByName("WMSPROXSEQ", .T., .F.)
		Sleep(50)
		nC++
		If nC == 60
			nC := 0
		EndIf
	EndDo
	cCodAnt := PadR(GetMv(cParametro), TamSx3(cField)[1])
	If Empty(cCodAnt)
		cCodAnt := Replicate('0',TamSX3(cField)[1])
	EndIf
	cCodAnt := Soma1(cCodAnt,TamSX3(cField)[1])
	PutMv(cParametro,cCodAnt)
	UnLockByName("WMSPROXSEQ", .T., .F.)
Return cCodAnt

METHOD EstParcial(nRecnoSC9,nQtdQuebra,lPedEmp) CLASS WMSDTCOrdemServico
Local lRet         := .T.
Local lBxEmp       := .F.
Local lBxEmp2      := .F.
Local aAreaSC9     := SC9->(GetArea())
Local aAreaSDC     := SDC->(GetArea())
Local oMntVolItem  := Nil
Local oConfExpItem := Nil
Local oDisSepItem  := Nil
Local oRelacMov    := Nil
Local cAliasD12    := Nil
Local cProduto     := PadR("",TamSx3("D12_PRODUT")[1])
Local cOrdTar      := PadR("",TamSx3("D12_ORDTAR")[1])
Local cTarefa      := PadR("",TamSx3("D12_TAREFA")[1])
Local cOrdAti      := PadR("",TamSx3("D12_ORDATI")[1])
Local cAtividade   := PadR("",TamSx3("D12_ATIVID")[1])
Local nQtdOrig     := 0
Local nQtdMvto     := 0
Local nQtdAux      := nQtdQuebra
Local oEstEnder  := WMSDTCEstoqueEndereco():New()

	// Procura as movimentações criadas do produto para atualização da nova quantidade
	cAliasD12 := GetNextAlias()
	// Se empenhado deverá ordenar a partir dos movimentos finalizados
	// Se não empenhado deverá ordenar a partir dos movimentos não finalizados
	If !lPedEmp
		BeginSql Alias cAliasD12
			SELECT D12.D12_PRODUT,
					D12.D12_SERVIC,
					D12.D12_ORDTAR,
					D12.D12_TAREFA,
					D12.D12_ORDATI,
					D12.D12_ATIVID,
					(CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D11_QTMULT,
					DCR.R_E_C_N_O_ RECNODCR
			FROM %Table:D12% D12
			INNER JOIN %Table:DCR% DCR
			ON DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = %Exp:Self:GetIDDCF()%
			AND DCR.DCR_SEQUEN = %Exp:Self:GetSequen()%
			AND DCR.%NotDel%
			LEFT JOIN %Table:D11% D11
			ON D11.D11_FILIAL = %xFilial:D11%
			AND D12.D12_FILIAL = %xFilial:D12%
			AND D11.D11_PRDORI = D12.D12_PRDORI
			AND D11.D11_PRDCMP = D12.D12_PRODUT
			AND D11.%NotDel%
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_STATUS <> '0'
			AND D12.%NotDel%
			ORDER BY D12.D12_SERVIC,
						D12.D12_ORDTAR,
						D12.D12_TAREFA,
						D12.D12_ORDATI,
						D12.D12_ATIVID,
						D12.D12_STATUS DESC
		EndSql
	Else
		BeginSql Alias cAliasD12
			SELECT D12.D12_PRODUT,
					D12.D12_SERVIC,
					D12.D12_ORDTAR,
					D12.D12_TAREFA,
					D12.D12_ORDATI,
					D12.D12_ATIVID,
					(CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D11_QTMULT,
					DCR.R_E_C_N_O_ RECNODCR
			FROM %Table:D12% D12
			INNER JOIN %Table:DCR% DCR
			ON DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = %Exp:Self:GetIDDCF()%
			AND DCR.DCR_SEQUEN = %Exp:Self:GetSequen()%
			AND DCR.%NotDel%
			LEFT JOIN %Table:D11% D11
			ON D11.D11_FILIAL = %xFilial:D11%
			AND D12.D12_FILIAL = %xFilial:D12%
			AND D11.D11_PRDORI = D12.D12_PRDORI
			AND D11.D11_PRDCMP = D12.D12_PRODUT
			AND D11.%NotDel%
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_STATUS <> '0'
			AND D12.%NotDel%
			ORDER BY D12.D12_SERVIC,
						D12.D12_ORDTAR,
						D12.D12_TAREFA,
						D12.D12_ORDATI,
						D12.D12_ATIVID,
						D12.D12_STATUS
		EndSql
	EndIf
	If (cAliasD12)->(!Eof())
		oRelacMov := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
		Do While (cAliasD12)->(!Eof()) .And. lRet
			If cProduto+cOrdTar+cTarefa+cOrdAti+cAtividade <> (cAliasD12)->(D12_PRODUT+D12_ORDTAR+D12_TAREFA+D12_ORDATI+D12_ATIVID)
				cProduto   := (cAliasD12)->D12_PRODUT
				cOrdTar    := (cAliasD12)->D12_ORDTAR
				cTarefa    := (cAliasD12)->D12_TAREFA
				cOrdAti    := (cAliasD12)->D12_ORDATI
				cAtividade := (cAliasD12)->D12_ATIVID
				nQtdQuebra := nQtdAux
			EndIf
			If nQtdQuebra > 0
				If oRelacMov:GotoDCR((cAliasD12)->RECNODCR)
					// Ajusta saida e entrada prevista
					// Ajusta movimentações
					nQtdOrig := oRelacMov:GetQuant()
					nQtdMvto := Iif((nQtdQuebra*(cAliasD12)->D11_QTMULT) >= oRelacMov:GetQuant(),oRelacMov:GetQuant(),nQtdQuebra*(cAliasD12)->D11_QTMULT)
					lRet := oRelacMov:UpdQtdMov(nQtdQuebra*(cAliasD12)->D11_QTMULT,@lBxEmp2)
					lBxEmp := lBxEmp .Or. lBxEmp2 //caso tenha 1 separação executada e uma conferência bloqueada, entende-se que é necessário estornar.
					nQtdQuebra -= (nQtdMvto/(cAliasD12)->D11_QTMULT)
				EndIf
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
	EndIf
	(cAliasD12)->(dbCloseArea())
	If lRet
		// Retira o empenho da DOCA com base no SC9 e quantidade estornada
		// Retira a quantidade original e separa dos processos de expedição
	 	If lBxEmp .And. lPedEmp
			oEstEnder:ReversePed(nRecnoSC9,nQtdAux)
		EndIf
		// Atualização DCT e DCS quando existir montagem de volume
		oMntVolItem := WMSDTCMontagemVolumeItens():New()
		oMntVolItem:SetCarga(Self:GetCarga())
		oMntVolItem:SetPedido(Self:GetDocto())
		oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
		oMntVolItem:SetPrdOri(Self:oProdLote:GetPrdOri())
		oMntVolItem:SetProduto(Self:oProdLote:GetProduto())
		oMntVolItem:SetIdDCF(Self:GetIdDCF())
		If oMntVolItem:LoadData()
			// Atualização das quantidades e liberação dos pedidos caso processo libere
			oMntVolItem:UpdQtdParc(nQtdAux,lBxEmp)
		EndIf
		// Atualiza D02 e D01 quando existir conferência de expedição
		oConfExpItem := WMSDTCConferenciaExpedicaoItens():New()
		oConfExpItem:SetCarga(Self:GetCarga())
		oConfExpItem:SetPedido(Self:GetDocto())
		oConfExpItem:SetCodExp(oConfExpItem:oConfExp:FindCodExp())
		oConfExpItem:SetPrdOri(Self:oProdLote:GetPrdOri())
		oConfExpItem:SetProduto(Self:oProdLote:GetProduto())
		oConfExpItem:SetIdDCF(Self:GetIdDCF())
		If oConfExpItem:LoadData()
			// Atualização das quantidades e liberação dos pedidos caso processo libere
			oConfExpItem:UpdQtdParc(nQtdAux,lBxEmp)
		EndIf
		// Atualiza D0E e D0D quando existir distribuição de separação
		oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
		oDisSepItem:SetCarga(Self:GetCarga())
		oDisSepItem:SetPedido(Self:GetDocto())
		oDisSepItem:oDisSep:oDisEndDes:SetArmazem(Self:oOrdEndDes:GetArmazem())
		oDisSepItem:SetCodDis(oDisSepItem:oDisSep:FindCodDis())
		oDisSepItem:oDisEndOri:SetArmazem(Self:oOrdEndOri:GetArmazem())
		oDisSepItem:oDisPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
		oDisSepItem:oDisPrdLot:SetProduto(Self:oProdLote:GetProduto())
		If oDisSepItem:LoadData()
			// Atualização das quantidades da distribuição da separação
			oDisSepItem:UpdQtdParc(nQtdAux,lBxEmp)
		EndIf
		// Atualiza quantidade ordem de serviço
		Self:SetQuant(Self:GetQuant() - nQtdAux)
		If Self:GetQtdOri() == 0
			Self:SetQtdOri(Self:GetQuant())
		EndIf
		Self:UpdateDCF()
		// Verifica se existe movimentos para a ordem de serviço se não existir excluir a ordem de serviço
		If Self:GetQuant() == 0
			If !Self:HaveMovD12("0")
				//Como a quantidade de Self foi zerada, é necessário passar a qtde excluída para que 
				//UndoIntegr atualize as quantidades de entrada e saída previstas.				 
				Self:nQtdDel := nQtdAux 
				If lRet
					If !(lRet := Self:UndoIntegr())
						Self:cErro := STR0007 // Não foi possível desfazer a integração da ordem de serviço!
					EndIf
				EndIf
				If lRet
					Self:ExcludeDCF()
				EndIf
			Else
				Self:CancelDCF()
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSC9)
	RestArea(aAreaSDC)
Return lRet

METHOD FindDCFOri() CLASS WMSDTCOrdemServico
Local aAreaDCF := DCF->(GetArea())
Local cOrigem  := ""
	dbSelectArea("DCF")
	DCF->(dbSetOrder(9)) //DCF_FILIAL+DCF_ID

	//Procura a origem do documento originador da DCF
	If DCF->(DbSeek(xFilial("DCF")+Self:cIdOrigem))
		cOrigem := 	DCF->DCF_ORIGEM
	EndIf
	RestArea(aAreaDCF)
Return cOrigem

METHOD ChkOrdReab() CLASS WMSDTCOrdemServico
Local lRet     := .T.
Local nI       := 0
Local nPos     := 0
Local cProduto := ""
Local aReabD12 := {}
	For nI := 1 To Len(Self:aLibD12)
		cProduto := AllTrim(Self:aLibD12[nI][6])
		//Deve adicionar no log apenas uma vez
		If (nPos := AScan(Self:aWmsReab, { |x| cProduto $ x[1] })) > 0
			If AScan(aReabD12, { |x| cProduto $ x[1] }) == 0
				AAdd(aReabD12,{Self:aWmsReab[nPos][1]}) // Reabastecimentos pendentes que precisam ser executados para o produto
			EndIf
		EndIf
	Next nI
	Self:aWmsReab := aReabD12
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} NextSeqPri
Proxima sequencia de prioridade
@author logistica
@since 23/12/2014
@version 1.0
@param cParametro, character, (Parametro)
@param cField, character, (Campos)
/*/
//--------------------------------------------------
METHOD CanEstReab() CLASS WMSDTCOrdemServico
Local lRet        := .T.
Local aD12_QTDMOV := TamSx3("D12_QTDMOV")
Local oEstEnder   := WMSDTCEstoqueEndereco():New()
Local cAliasD12   := Nil
	If Self:cStServ == '3'
		cAliasD12 := GetNextAlias()
		If Self:lHasUniDes
			BeginSql Alias cAliasD12
				SELECT DISTINCT D12.D12_LOCDES,
						D12.D12_ENDDES,
						D12.D12_PRODUT,
						D12.D12_PRDORI,
						D12.D12_LOTECT,
						D12.D12_NUMLOT,
						D12.D12_NUMSER,
						D12.D12_UNIDES,
						D12.D12_QTDMOV
				FROM %Table:D12% D12
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_IDDCF = %Exp:Self:cIdDCF%
				AND D12.D12_STATUS IN ('2','3','4')
				AND D12.D12_ATUEST = '1'
				AND D12.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasD12
				SELECT DISTINCT D12.D12_LOCDES,
						D12.D12_ENDDES,
						D12.D12_PRODUT,
						D12.D12_PRDORI,
						D12.D12_LOTECT,
						D12.D12_NUMLOT,
						D12.D12_NUMSER,
						D12.D12_QTDMOV
				FROM %Table:D12% D12
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_IDDCF = %Exp:Self:cIdDCF%
				AND D12.D12_STATUS IN ('2','3','4')
				AND D12.D12_ATUEST = '1'
				AND D12.%NotDel%
			EndSql
		EndIf
		TCSetField(cAliasD12,'D12_QTDMOV','N',aD12_QTDMOV[1],aD12_QTDMOV[2])
		Do While (cAliasD12)->(!EoF())
			oEstEnder:ClearData()
			oEstEnder:oEndereco:SetArmazem((cAliasD12)->D12_LOCDES)
			oEstEnder:oEndereco:SetEnder((cAliasD12)->D12_ENDDES)
			oEstEnder:oProdLote:SetArmazem((cAliasD12)->D12_LOCDES)
			oEstEnder:oProdLote:SetPrdOri((cAliasD12)->D12_PRDORI)
			oEstEnder:oProdLote:SetProduto((cAliasD12)->D12_PRODUT)
			oEstEnder:oProdLote:SetNumSer((cAliasD12)->D12_NUMSER)
			oEstEnder:oProdLote:SetLoteCtl((cAliasD12)->D12_LOTECT)
			oEstEnder:oProdLote:SetNumLote((cAliasD12)->D12_NUMLOT)
			If Self:lHasUniDes
				oEstEnder:SetIdUnit((cAliasD12)->D12_UNIDES)
			EndIf
			If oEstEnder:LoadData()
				If QtdComp(oEstEnder:GetQtdEst() + oEstEnder:GetQtdEpr() - (cAliasD12)->D12_QTDMOV) < QtdComp(oEstEnder:GetQtdSpr())
					Self:cErro := STR0023 // Reabastecimento não pode ser estornado, saldo comprometido!
					lRet       := .F.
				EndIf
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} ChkQtdRes
Verifica quantidade reservada SB2
@author logistica
@since 15/02/2016
@version 1.0
@param cParametro, character, (Parametro)
@param cField, character, (Campos)
/*/
//--------------------------------------------------
METHOD ChkQtdRes() CLASS WMSDTCOrdemServico
Local lRet     := .T.
Local aB2_QATU := TamSx3("B2_QATU")
Local cAliasSB2:= GetNextAlias()
	BeginSql Alias cAliasSB2
		SELECT SB2.B2_QATU - ((SB2.B2_QACLASS - CASE WHEN D0G.D0G_QTDORI IS NULL THEN 0 ELSE D0G.D0G_QTDORI END) + SB2.B2_RESERVA + SB2.B2_QEMP + SB2.B2_QEMPSA + SB2.B2_QEMPN + SB2.B2_QNPT) B2_QTDEST,
				SB2.B2_QATU,
				SB2.B2_QACLASS,
				SB2.B2_RESERVA,
				SB2.B2_QEMP,
				SB2.B2_QEMPSA,
				SB2.B2_QEMPN,
				SB2.B2_QNPT
		FROM %Table:SB2% SB2
		LEFT JOIN %Table:D0G% D0G
		ON D0G.D0G_FILIAL = %xFilial:D0G%
		AND D0G.D0G_PRODUT = SB2.B2_COD
		AND D0G.D0G_LOCAL = SB2.B2_LOCAL
		AND D0G.D0G_IDDCF = %Exp:Self:GetIdDCF()%
		AND D0G.%NotDel%
		WHERE SB2.B2_FILIAL = %xFilial:SB2%
		AND SB2.B2_COD = %Exp:Self:oProdLote:GetPrdOri()%
		AND SB2.B2_LOCAL = %Exp:Self:oOrdEndOri:GetArmazem()%
		AND SB2.%NotDel%
	EndSql
	TCSetField(cAliasSB2,'B2_QTDEST','N',aB2_QATU[1],aB2_QATU[2])
	If (cAliasSB2)->(!EoF())
		If QtdComp((cAliasSB2)->B2_QTDEST) < QtdComp(Self:nQuant)
			Self:cErro := WmsFmtMsg(STR0024; // Não é possível estornar o documento [VAR01]. O armazém/produto [VAR02]/[VAR03] possui:
									+CRLF+STR0025; // Quantidade atual de [VAR04]
									+CRLF+STR0026; // Quantidade reservada de [VAR05]
									+CRLF+STR0027; // Quantidade a classificar de [VAR06]
									+CRLF+STR0028; // Quantidade empenhada de [VAR07]
									+CRLF+STR0029; // Quantidade prevista SA de [VAR08]
									+CRLF+STR0031; // Quantidade empenhada para NFs de [VAR10]
									+CRLF+STR0032,{{"[VAR01]",Self:cDocumento},; // Quantidade nosso em poder terc. de [VAR11]
													{"[VAR02]",Self:oProdLote:GetPrdOri()},;
													{"[VAR03]",Self:oOrdEndOri:GetArmazem()},;
													{"[VAR04]",Str((cAliasSB2)->B2_QATU)},;
													{"[VAR05]",Str((cAliasSB2)->B2_RESERVA)},;
													{"[VAR06]",Str((cAliasSB2)->B2_QACLASS)},;
													{"[VAR07]",Str((cAliasSB2)->B2_QEMP)},;
													{"[VAR08]",Str((cAliasSB2)->B2_QEMPSA)},;
													{"[VAR10]",Str((cAliasSB2)->B2_QEMPN)},;
													{"[VAR11]",Str((cAliasSB2)->B2_QNPT)}})
			lRet := .F.
		EndIf
	EndIf
	(cAliasSB2)->(dbCloseArea())
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} IsMovUnit
Verifica se é um movimento unitizado
@author  Guilherme A. Metzger
@since   28/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD IsMovUnit() CLASS WMSDTCOrdemServico
Return (Empty(Self:oProdLote:GetProduto()) .And. (!Empty(Self:cIdUnitiz) .Or. !Empty(Self:cUniDes)))

//-----------------------------------------------
/*/{Protheus.doc} ChkMovEst
Verifica se é um movimento unitizado
@author  Guilherme A. Metzger
@since   28/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD ChkMovEst(lEndOri) CLASS WMSDTCOrdemServico
Local lRet      := .F.
Local cEndereco := ""

Default lEndOri := .T.
	// Valida se o endereço e o lote estão informados para realizar a movimentação
	If lEndOri
		cEndereco := Self:oOrdEndOri:GetEnder()
	Else
		cEndereco := Self:oOrdEndDes:GetEnder()
	EndIf
	If !Empty(cEndereco) .And. (!Self:oProdLote:HasRastro() .Or. (Self:oProdLote:HasRastro() .And. !Empty(Self:oProdLote:GetLoteCtl())))
		lRet := .T.
	EndIf
Return lRet
//-----------------------------------------------
/*/{Protheus.doc} MovSD3Estr
Realiza movimentações SB3 para montagem ou desmontagem de produtos
@author  Squad WMS
@since   27/10/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD MovSD3Estr(lMontagem) CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aArrSD3    := {}
Local aAreaSD3   := SD3->(GetArea())
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local cAliasLot  := Nil
Local cAliasD0B  := Nil
Local cAliasD11  := Nil
Local cNumOp     := ""
Local cPrdPai    := ""
Local cLocal     := ""
Local cTipMov    := ""
Local cNumSeq    := ProxNum()
Local nRateio    := 0
Local nQuant     := 0
Local nRecno     := 0
Local nCusPar    := 0
Local nCusto1    := 0

Default lMontagem := .T.

Private nHdlPrv
Private lExecWms := .T.
	//Realiza loop por lote
	//para criar uma ordem de produção e uma entrada SD3 (numseq) para cada lote
	cTipMov := Iif(lMontagem,"2","1")
	cAliasLot := GetNextAlias()	
	BeginSql Alias cAliasLot
		SELECT D0B.D0B_LOTECT,
				D0B.D0B_NUMLOT
		FROM %table:D0B% D0B
		WHERE D0B.D0B_FILIAL = %xFilial:D0B%
		AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
		AND D0B.D0B_TIPMOV = %Exp:cTipMov%
		AND D0B.%NotDel%
		GROUP BY D0B.D0B_LOTECT,
					D0B.D0B_NUMLOT
	EndSql
	Do While (cAliasLot)->(!Eof()) .And. lRet
		// Inicializa array
		aArrSD3 := {}		
		// Produtos Origem
		cAliasD0B := GetNextAlias()
		BeginSql Alias cAliasD0B
			SELECT D0B.D0B_LOCAL,
					D0B.D0B_PRDORI,
					D0B.D0B_LOTECT,
					D0B.D0B_NUMLOT,
					SUM(D0B.D0B_QUANT / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END ) D0B_QUANT
			FROM %Table:D0B% D0B
			LEFT JOIN %table:D11% D11
			ON D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRDORI = D0B.D0B_PRDORI
			AND D11.D11_PRDCMP = D0B.D0B_PRODUT
			AND D11.%NotDel%
			WHERE D0B.D0B_FILIAL = %xFilial:D0B%
			AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
			AND D0B.D0B_TIPMOV = %Exp:cTipMov%
			AND D0B.D0B_PRODUT = %Exp:Self:oProdLote:GetProduto()%
			AND D0B.D0B_LOTECT = %Exp:(cAliasLot)->D0B_LOTECT%
			AND D0B.D0B_NUMLOT = %Exp:(cAliasLot)->D0B_NUMLOT%
			AND D0B.%NotDel%
			GROUP BY D0B.D0B_LOCAL,
						D0B.D0B_PRDORI,
						D0B.D0B_LOTECT,
						D0B.D0B_NUMLOT
			ORDER BY D0B.D0B_LOTECT,
						D0B.D0B_NUMLOT
		EndSql
		Do While (cAliasD0B)->(!Eof()) .And. lRet
			If !lMontagem
				// Adiocina os produtos destino
				aAdd(aArrSD3, {"999",;                   // Tipo movimentação
								Self:GetDocto(),;         // Documento
								(cAliasD0B)->D0B_PRDORI,; // Produto
								(cAliasD0B)->D0B_LOTECT,; // Lote
								(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
								(cAliasD0B)->D0B_QUANT,;  // Quantidade
								100,;                     // % Rateio
								(cAliasD0B)->D0B_LOCAL,;  // Armazém
								"",;                      // Endereço
								"",;                      // Id DCF
								"RE7",;                   // Cf
								"E0",;                    // Chave
								Self:GetServico(),;       // Serviço
								Self:GetStServ(),;        // Status Servico
								Self:GetRegra()})         // Regra
			Else
				cLocal  := (cAliasD0B)->D0B_LOCAL
				cPrdPai := (cAliasD0B)->D0B_PRDORI
				nQuant  := (cAliasD0B)->D0B_QUANT
				cNumOp  := oEstEnder:WmsGeraOP(cLocal, cPrdPai, nQuant)
				If Empty(cNumOp)
					lRet := .F.
				EndIf
			EndIf
			(cAliasD0B)->(dbSkip())
		EndDo
		(cAliasD0B)->(dbCloseArea())

		// Produtos destino
		If lRet
			cTipMov := Iif(lMontagem,"1","2")
			cAliasD0B := GetNextAlias()
			BeginSql Alias cAliasD0B
				SELECT D0B.D0B_LOCAL,
						D0B.D0B_PRDORI,
						D0B.D0B_PRODUT,
						D0B.D0B_LOTECT,
						D0B.D0B_NUMLOT,
						SUM(D0B.D0B_QUANT / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END ) D0B_QUANT
				FROM %Table:D0B% D0B
				LEFT JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = D0B.D0B_PRDORI
				AND D11.D11_PRDCMP = D0B.D0B_PRODUT
				AND D11.%NotDel%
				WHERE D0B.D0B_FILIAL = %xFilial:D0B%
				AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
				AND D0B.D0B_LOTECT = %Exp:(cAliasLot)->D0B_LOTECT%
				AND D0B.D0B_NUMLOT = %Exp:(cAliasLot)->D0B_NUMLOT%
				AND D0B.D0B_TIPMOV = %Exp:cTipMov%
				AND D0B.%NotDel%
				GROUP BY D0B.D0B_LOCAL,
							D0B.D0B_PRDORI,
							D0B.D0B_PRODUT,
							D0B.D0B_LOTECT,
							D0B.D0B_NUMLOT
				ORDER BY D0B.D0B_LOTECT,
							D0B.D0B_NUMLOT
			EndSql
			Do While (cAliasD0B)->(!Eof())
				nRateio := 0
				// Na montagem/desmontagem de estruturas o percentual de rateio é cadastrado nos componentes (D11)
				cAliasD11 := GetNextAlias()
				BeginSql Alias cAliasD11
					SELECT CASE WHEN D11.D11_RATEIO IS NULL THEN 100 ELSE D11.D11_RATEIO END D11_RATEIO
					FROM %Table:D11% D11
					WHERE D11.D11_FILIAL = %xFilial:D11%
					AND D11.D11_PRDORI = %Exp:D0A->D0A_PRODUT%
					AND D11.D11_PRDCMP = %Exp:(cAliasD0B)->D0B_PRODUT%
					AND D11.%NotDel%
				EndSql
				If (cAliasD11)->(!Eof())
					nRateio := (cAliasD11)->D11_RATEIO
				EndIf
				(cAliasD11)->(dbCloseArea())
				If !lMontagem
					// Adiocina os produtos destino
					aAdd(aArrSD3, {"499",;                                               // Tipo movimentação
									Self:GetDocto(),;                                     // Documento
									(cAliasD0B)->D0B_PRODUT,;                             // Produto
									(cAliasD0B)->D0B_LOTECT,;                             // Lote
									(cAliasD0B)->D0B_NUMLOT,;                             // Sub-Lote
									(cAliasD0B)->D0B_QUANT,;                              // Quantidade
									nRateio,;                                             // % Rateio
									(cAliasD0B)->D0B_LOCAL,;                              // Armazém
									"",;                                                  // Endereço
									"",;                                                  // Id DCF
									"DE7",;                                               // Cf
									"E9",;                                                // Chave
									Self:GetServico(),;                                   // Serviço
									Self:GetStServ(),;                                    // Status Servico
									Self:GetRegra()})                                     // Regra
				Else
					A340SD3Prt((cAliasD0B)->D0B_PRODUT,;           // Produto
								"",;                               // Endereço
								"999",;                            // Tipo de movimentação
								(cAliasD0B)->D0B_QUANT,;           // Quantidade
								Self:GetDocto(),;                  // Documento
								.F./*lInventario*/,;               // Indica se é um processo de inventário
								{;                                 // aParam - Informações do SD3
								(cAliasD0B)->D0B_LOCAL,;           // [01] cLocal
								dDataBase,;                        // [02] dData
								(cAliasD0B)->D0B_NUMLOT,;          // [03] cNumLote
								(cAliasD0B)->D0B_LOTECT,;          // [04] cLoteCtl
								/*Self:oMovPrdLot:GetDtValid()*/,; // [05] dDtValid
								0,;                                // [06] nQtSegUm
								/*Self:oMovPrdLot:GetNumSer()*/,;  // [07] cNumSerie
								/*Self:oMovEndDes:GetEstFis()*/,;  // [08] cEstFis
								"",;                               // [09] cContagem
								Self:GetDocto(),;                  // [10] cNumDoc
								/*Self:oOrdServ:GetSerie()*/,;     // [11] cSerie
								/*Self:oOrdServ:GetCliFor()*/,;    // [12] cFornece
								/*Self:oOrdServ:GetLoja()*/,;      // [13] cLoja
								dDataBase,;                        // [14] mv_par01 -> D3_EMISSAO
								Posicione("SB1",1,xFilial("SB1")+(cAliasD0B)->D0B_PRODUT,"B1_CC"),; // [15] mv_par02 -> D3_CC  /*Self:oOrdServ:oProdLote:oProduto:oProdGen:GetCC()*/
								2;                                 // [16] mv_par14 -> 1=Pega os custos medios finais;2=Pega os custos medios atuais
								},;
								{dDataBase},;
								cNumSeq,;
								.F./*lDesmontagem*/,;
								cNumOP,;
								@nCusPar)
					// Soma o custo das partes para formar o custo do pai
					nCusto1 += nCusPar
				EndIf
				(cAliasD0B)->(dbSkip())
			EndDo
			(cAliasD0B)->(dbCloseArea())
		EndIf

		If lRet
			If lMontagem
				// Realiza o apontamento para gerar saldo do pai
				If !oEstEnder:WmsApontOp(cNumOP,cPrdPai,nQuant,Self:GetDocto(),@nRecno,cLocal,(cAliasLot)->D0B_LOTECT,(cAliasLot)->D0B_NUMLOT,Self:GetServico())
					lRet :=  .F.
				Else
					// Altera a movimentação SD3 para gravar o custo da produção do pai com relação aos filhos
					SD3->(dbGoto(nRecno))
					RecLock("SD3",.F.)
					SD3->D3_CUSTO1 := nCusto1
					SD3->(MsUnlock())
				EndIf
			Else
				// Gera movimento interno
				oEstEnder:AtuDesSD3(aArrSD3,D0A->D0A_OPERAC)
			EndIf
		EndIf
		(cAliasLot)->(dbSkip())
	EndDo
	(cAliasLot)->(dbCloseArea())
	oEstEnder:Destroy()
	RestArea(aAreaSD3)
Return lRet
//-----------------------------------------------
/*/{Protheus.doc} MovSD3Prod
Realiza movimentações SB3 para desmontagem de produtos
@author  Squad WMS
@since   27/10/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD MovSD3Prod() CLASS WMSDTCOrdemServico
Local lRet      := .T.
Local aArrSD3   := {}
Local aAreaSD3  := SD3->(GetArea())
Local oEstEnder := WMSDTCEstoqueEndereco():New()
Local cAliasD0B := Nil
Local cAliasD0C := Nil
Local nRateio   := 0
Local cTmEnt	:= "RE7"
Local cTmSaida	:= "DE7"

Private nHdlPrv
Private lExecWms := .T.

	If Type('nTpWMSA520') != 'U' 
		If nTpWMSA520 == 2 //--Transferência
			cTmEnt	 := "RE4"
			cTmSaida := "DE4"
		EndIf
	EndIf

	// Inicializa array
	aArrSD3 := {}
	// Produtos Origem
	cAliasD0B := GetNextAlias()
	BeginSql Alias cAliasD0B
		SELECT D0B.D0B_LOCAL,
				D0B.D0B_PRDORI,
				D0B.D0B_LOTECT,
				D0B.D0B_NUMLOT,
				SUM(D0B.D0B_QUANT) D0B_QUANT
		FROM %Table:D0B% D0B
		WHERE D0B.D0B_FILIAL = %xFilial:D0B%
		AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
		AND D0B.D0B_TIPMOV = '1'
		AND D0B.%NotDel%
		GROUP BY D0B.D0B_LOCAL,
					D0B.D0B_PRDORI,
					D0B.D0B_LOTECT,
					D0B.D0B_NUMLOT
		ORDER BY D0B.D0B_LOTECT,
					D0B.D0B_NUMLOT
	EndSql
	Do While (cAliasD0B)->(!Eof()) .And. lRet
		// Adiocina os produtos destino
		aAdd(aArrSD3, {"999",;    // Tipo movimentação
						Self:GetDocto(),;         // Documento
						(cAliasD0B)->D0B_PRDORI,; // Produto
						(cAliasD0B)->D0B_LOTECT,; // Lote
						(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
						(cAliasD0B)->D0B_QUANT,;  // Quantidade
						100,;                     // % Rateio
						(cAliasD0B)->D0B_LOCAL,;  // Armazém
						"",;                      // Endereço
						"",;                      // Id DCF
						cTmEnt,;	 			  // Cf
						"E0",;                    // Chave
						Self:GetServico(),;       // Serviço
						Self:GetStServ(),;        // Status Servico
						Self:GetRegra()})         // Regra
		(cAliasD0B)->(dbSkip())
	EndDo
	(cAliasD0B)->(dbCloseArea())
	If lRet
		// Produtos destino
		cAliasD0B := GetNextAlias()
		BeginSql Alias cAliasD0B
			SELECT D0B.D0B_LOCAL,
					D0B.D0B_PRDORI,
					D0B.D0B_PRODUT,
					D0B.D0B_LOTECT,
					D0B.D0B_NUMLOT,
					SUM(D0B.D0B_QUANT) D0B_QUANT
			FROM %table:D0B% D0B
			WHERE D0B.D0B_FILIAL = %xFilial:D0B%
			AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
			AND D0B.D0B_TIPMOV = '2'
			AND D0B.%NotDel%
			GROUP BY D0B.D0B_LOCAL,
						D0B.D0B_PRDORI,
						D0B.D0B_PRODUT,
						D0B.D0B_LOTECT,
						D0B.D0B_NUMLOT
			ORDER BY D0B.D0B_LOTECT,
						D0B.D0B_NUMLOT
		EndSql
		Do While (cAliasD0B)->(!Eof())
			// Busca rateio do produto
			nRateio := 0
			// Na montagem/desmontagem de produto o percentual de rateio é informado (D0C)
			cAliasD0C := GetNextAlias()
			BeginSql Alias cAliasD0C
				SELECT D0C.D0C_RATEIO
				FROM %Table:D0C% D0C
				WHERE D0C.D0C_FILIAL = %xFilial:D0C%
				AND D0C.D0C_DOC = %Exp:Self:GetDocto()%
				AND D0C.D0C_PRODUT = %Exp:(cAliasD0B)->D0B_PRDORI%
				// Na desmontagem de produto deverá considerar o percentual de rateio por produto/lote e sublote
				// Na montagem será considerado o percentual de rateio de 100%
				AND D0C.D0C_LOTECT= %Exp:(cAliasD0B)->D0B_LOTECT%
				AND D0C.D0C_NUMLOT= %Exp:(cAliasD0B)->D0B_NUMLOT%
				AND D0C.%NotDel%
			EndSql
			If (cAliasD0C)->(!Eof())
				nRateio := (cAliasD0C)->D0C_RATEIO
			EndIf
			(cAliasD0C)->(dbCloseArea())
			// Adiocina os produtos destino
			aAdd(aArrSD3, {"499",;                   // Tipo movimentação
							Self:GetDocto(),;         // Documento
							(cAliasD0B)->D0B_PRODUT,; // Produto
							(cAliasD0B)->D0B_LOTECT,; // Lote
							(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
							(cAliasD0B)->D0B_QUANT,;  // Quantidade
							nRateio,;                 // % Rateio
							(cAliasD0B)->D0B_LOCAL,;  // Armazém
							"",;                      // Endereço
							"",;                      // Id DCF
							cTmSaida,;	 			  // Cf
							"E9",;                    // Chave
							Self:GetServico(),;       // Serviço
							Self:GetStServ(),;        // Status Servico
							Self:GetRegra()})         // Regra
			(cAliasD0B)->(dbSkip())
		EndDo
		(cAliasD0B)->(dbCloseArea())
	EndIf
	If lRet
		// Gera movimento interno
		oEstEnder:AtuDesSD3(aArrSD3,D0A->D0A_OPERAC)
	EndIf
	oEstEnder:Destroy()
	RestArea(aAreaSD3)
Return lRet
//-----------------------------------------------
/*/{Protheus.doc} MovSD3Lote
Realiza movimentações SB3 para troca de lotes.
@author  Squad WMS
@since   27/10/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD MovSD3Lote() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local aArrSD3    := {}
Local aAreaSD3   := SD3->(GetArea())
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local cAliasD0B  := Nil
Local cAliasCtrl := Nil

Private nHdlPrv
Private lExecWms := .T.
	//Realiza loop por controle do processo
	//para amarrar entradas e saídas SD3 conforme o lote que está sendo trocado
	cAliasCtrl := GetNextAlias()
	BeginSql Alias cAliasCtrl
		SELECT D0B.D0B_CTRL
		FROM %Table:D0B% D0B
		WHERE D0B.D0B_FILIAL = %xFilial:D0B%
		AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
		AND D0B.%NotDel%
		GROUP BY D0B.D0B_CTRL
	EndSql
	Do While (cAliasCtrl)->(!Eof())
		// Inicializa array
		aArrSD3 := {}
		// Produtos Origem
		cAliasD0B := GetNextAlias()
		BeginSql Alias cAliasD0B
			SELECT D0B.D0B_LOCAL,
					D0B.D0B_PRDORI,
					D0B.D0B_LOTECT,
					D0B.D0B_NUMLOT,
					SUM(D0B.D0B_QUANT) D0B_QUANT
			FROM %Table:D0B% D0B
			WHERE D0B.D0B_FILIAL = %xFilial:D0B%
			AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
			AND D0B.D0B_CTRL = %Exp:(cAliasCtrl)->D0B_CTRL%
			AND D0B.D0B_TIPMOV = '1'
			AND D0B.%NotDel%
			GROUP BY D0B.D0B_LOCAL,
						D0B.D0B_PRDORI,
						D0B.D0B_LOTECT,
						D0B.D0B_NUMLOT
			ORDER BY D0B.D0B_LOTECT,
						D0B.D0B_NUMLOT
		EndSql
		Do While (cAliasD0B)->(!Eof())
			// Adiocina os produtos destino
			aAdd(aArrSD3, {"999",;                   // Tipo movimentação
							Self:GetDocto(),;         // Documento
							(cAliasD0B)->D0B_PRDORI,; // Produto
							(cAliasD0B)->D0B_LOTECT,; // Lote
							(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
							(cAliasD0B)->D0B_QUANT,;  // Quantidade
							100,;                     // % Rateio
							(cAliasD0B)->D0B_LOCAL,;  // Armazém
							"",;                      // Endereço
							"",;                      // Id DCF
							"RE4",;                   // Cf
 							"E0",;                    // Chave
							Self:GetServico(),;       // Serviço
							Self:GetStServ(),;        // Status Servico
							Self:GetRegra()})         // Regra
			(cAliasD0B)->(dbSkip())
		EndDo
		(cAliasD0B)->(dbCloseArea())
		// Produtos destino
		cAliasD0B := GetNextAlias()
		BeginSql Alias cAliasD0B
			SELECT D0B.D0B_LOCAL,
					D0B.D0B_PRDORI,
					D0B.D0B_PRODUT,
					D0B.D0B_LOTECT,
					D0B.D0B_NUMLOT,
					D0B.D0B_ENDDES,
					SUM(D0B.D0B_QUANT) D0B_QUANT
			FROM %Table:D0B% D0B
			WHERE D0B.D0B_FILIAL = %xFilial:D0B%
			AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
			AND D0B.D0B_CTRL = %Exp:(cAliasCtrl)->D0B_CTRL%
			AND D0B.D0B_TIPMOV = '2'
			AND D0B.%NotDel%
			GROUP BY D0B.D0B_LOCAL,
						D0B.D0B_PRDORI,
						D0B.D0B_PRODUT,
						D0B.D0B_LOTECT,
						D0B.D0B_NUMLOT,
						D0B.D0B_ENDDES
			ORDER BY D0B.D0B_LOTECT,
						D0B.D0B_NUMLOT
		EndSql
		Do While (cAliasD0B)->(!Eof())
			// Adiocina os produtos destino
			aAdd(aArrSD3, {"499",;    // Tipo movimentação
							Self:GetDocto(),;         // Documento
							(cAliasD0B)->D0B_PRODUT,; // Produto
							(cAliasD0B)->D0B_LOTECT,; // Lote
							(cAliasD0B)->D0B_NUMLOT,; // Sub-Lote
							(cAliasD0B)->D0B_QUANT,;  // Quantidade
							100,;                     // % Rateio
							(cAliasD0B)->D0B_LOCAL,;  // Armazém
							(cAliasD0B)->D0B_ENDDES,; // Endereço
							"",;                      // Id DCF
							"DE4",;                   // Cf
							"E9",;                    // Chave
							Self:GetServico(),;       // Serviço
							Self:GetStServ(),;        // Status Servico
							Self:GetRegra()})         // Regra
			(cAliasD0B)->(dbSkip())
		EndDo
		(cAliasD0B)->(dbCloseArea())
		// Gera movimento interno
		oEstEnder:AtuDesSD3(aArrSD3,D0A->D0A_OPERAC)
		(cAliasCtrl)->(DbSkip())
	EndDo
	(cAliasCtrl)->(DbCloseArea())
	oEstEnder:Destroy()
	RestArea(aAreaSD3)
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} VldGrvOS
Confronta as quantidades das tabelas SC9, D12, DCR e DCF para garantir que não houve erro no processo 
de aglutinação.
@author  Wander Horongoso
@since   06/04/2021
@version 1.0
@params
	cMessError - caracter - ponteiro para armazenar as mensagens de erro
	aOSAglu - array  - passado no processo de execução de serviço, quando poderá haver mais de uma OS e 
	todas precisam ser validadas.
	nQtdeAnt: quantidade da D12 excluída
		nRecnoAtu: recno da D12 recém criada
/*/ 
//-----------------------------------------------
METHOD VldGrvOS(cMessError, aOSAglu, nQtdeAnt,cAglutiAnt, nRecnoAtu) CLASS WMSDTCOrdemServico
Local lRet := .T.
Local cQry := ''
Local cQryDCR := ''
Local cIdMovAnt := ''
Local nTotal := 0
Local nX := 0
Local cIdDCF := ''
Default nQtdeAnt := 0
Default nRecnoAtu := 0

	//Parâmetro não criado no AtuSX. Será usado apenas para casos de necessidade
	//If SuperGetMV('MV_WMSVGOS',.F.,.F.) 

	cMessError := ''
	
	cQry := GetNextAlias()

	//Esse if será executado somente via WMSA332 - Opção Alterar Movimento
	If nQtdeAnt > 0 .And. nRecnoAtu > 0
		//Valida se quantidade anterior à alteração é igual à quantidade atual
		BeginSql Alias cQry
			SELECT D12_QTDMOV, D12_AGLUTI
			FROM %Table:D12%
			WHERE R_E_C_N_O_ = %Exp:nRecnoAtu%
			AND %NotDel%	
		EndSql

		If !((cQry)->D12_QTDMOV = nQtdeAnt)
			lRet := .F.
			cMessError += STR0053 + cValToChar(nQtdeAnt) + STR0054 + cValToChar((cQry)->D12_QTDMOV) + ').' //'Quantidade do movimento origem (99) diverge da quantidade do movimento a ser criado (98). 
		EndIf

		//Valida se o indicador de aglutinação anterior à alteração é igual ao indicador atual
		If !(AllTrim((cQry)->D12_AGLUTI) == AllTrim(cAglutiAnt))
			lRet := .F.
			cMessError += STR0055 + AllTrim(cAglutiAnt) + STR0056 + (cQry)->D12_AGLUTI + ').' //'Indicador de aglutinação do movimento origem (2) diverge do indicador do movimento a ser criado (1). 
		EndIf

		(cQry)->(dbCloseArea())
	
		//Verifica se as quantidades dos produto/lote na tabela de pedidos (SC9) são as mesmas dos movtos aglutinados (DCR)
		BeginSql Alias cQry
			SELECT * FROM (
				SELECT SC9.C9_LOTECTL, SC9.C9_PRODUTO, SC9.C9_IDDCF, 
					SC9.C9_PEDIDO, SC9.C9_LOCAL, SC9.C9_ITEM,
					SUM(SC9.C9_QTDLIB) C9_QTDLIB,
					(SELECT COALESCE(SUM(DCR_QUANT),0)
					FROM %Table:DCR% DCR
					INNER JOIN %Table:D12% D12
						ON D12.D12_FILIAL = %xFilial:D12%
						AND D12.D12_IDDCF = DCR.DCR_IDORI
						AND D12.D12_IDMOV = DCR.DCR_IDMOV
						AND D12.D12_IDOPER = DCR.DCR_IDOPER
						AND D12.D12_ATUEST = '1'
						AND D12.D12_STATUS <> '0'
						AND D12.D12_TAREFA IN (
							SELECT DC5_TAREFA 
							FROM %Table:DC5% DC5 
							WHERE DC5.DC5_FILIAL= %xFilial:DC5%
							AND	DC5.DC5_OPERAC IN ('3','4') 
							AND	DC5.%NotDel%)
						AND D12.%NotDel%
					WHERE DCR.DCR_IDDCF = SC9.C9_IDDCF
					AND DCR.%NotDel%
					AND SC9.C9_LOTECTL = D12.D12_LOTECT) DCR_QUANT			
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND C9_CARGA <> ' '
					AND C9_IDDCF <> ' '
					AND EXISTS (SELECT DISTINCT 1
						FROM %Table:D12% D12C
							WHERE D12C.D12_FILIAL = %xFilial:D12%
								AND D12C.R_E_C_N_O_ = %Exp:nRecnoAtu%
								AND D12C.D12_CARGA = SC9.C9_CARGA
								AND D12C.D12_PRODUT = SC9.C9_PRODUTO
								AND D12C.D12_LOTECT = SC9.C9_LOTECTL
								AND D12C.%NotDel%)
					AND SC9.%NotDel%
				GROUP BY SC9.C9_LOTECTL, SC9.C9_PRODUTO, SC9.C9_IDDCF, 
						SC9.C9_PEDIDO, SC9.C9_LOCAL, SC9.C9_ITEM
				) QRY_RESULT
			WHERE DCR_QUANT <> C9_QTDLIB
		EndSql

		If (cQry)->(!Eof())
			lRet := .F.
			cMessError += STR0057 + AllTrim((cQry)->C9_PEDIDO) + ' (' + cValToChar((cQry)->C9_QTDLIB) + STR0058 + cValToChar((cQry)->DCR_QUANT) + ').' //Quantidade do pedido XX (99) diverge da quantidade do movimento aglutinado (98). 
			WmsConout('VLDGRVOS -' + cMessError)
		Else
			WmsConout ('VLDGRVOS - Alteração sem erro. D12_RECNO ' + cValToChar(nRecnoAtu))
			WmsConout(GetLastQuery()[2])
		EndIf
	
		(cQry)->(dbCloseArea())
	EndIf

	//Esse IF será executado  na execução de serviço (WMSA150) ou no WMSA332 - alterar movimento, caso haja movimento aglutinado
	If lRet .And. Len(aOSAglu) > 0 
	
		For nX := 1 To Len(aOSAglu)
			cIdDCF += IIf(IsEmpty(cIdDCF), "'" + aOSAglu[nX][1] + "'", ", '" + aOSAglu[nX][1] + "'")
		Next nX

		WmsConout ('VLDGRVOS - OS a validar ' + cIdDCF)
		cIdDCF := "%" + cIdDCF + "%"
		
		If !Empty(cIdDCF)

			//Valida se alguma D12 da carga não possui vínculo com algum pedido da mesma carga.
			BeginSql Alias cQry
				SELECT D12.D12_PRODUT, D12.D12_LOTECT, D12.D12_IDDCF, D12.D12_IDMOV, 
					D12.D12_IDOPER
				FROM %Table:D12% D12
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.%NotDel%
				AND D12.D12_IDDCF IN (%Exp:cIdDCF%)
				AND D12.D12_STATUS <> '0'
				AND D12.D12_TAREFA IN (
					SELECT DC5_TAREFA 
					FROM %Table:DC5% DC5 
					WHERE DC5.DC5_FILIAL = %xFilial:DC5%
					AND	DC5.DC5_OPERAC IN ('3','4') 
					AND	DC5.%NotDel%)
				AND NOT EXISTS (
					SELECT C9_FILIAL FROM %Table:SC9% SC9
					INNER JOIN %Table:DCR% DCR					  
					ON DCR.DCR_FILIAL = %xFilial:DCR%
					AND DCR.DCR_IDDCF = SC9.C9_IDDCF
					AND DCR.DCR_IDORI = D12.D12_IDDCF
					AND DCR.DCR_IDMOV = D12.D12_IDMOV
					AND DCR.DCR_IDOPER = D12.D12_IDOPER
					AND DCR.%NotDel%
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_LOTECTL = D12.D12_LOTECT
					AND SC9.%NotDel%)
			EndSql

			While (cQry)->(!Eof())
				lRet := .F.
				cMessError += STR0059 + (cQry)->D12_IDDCF + ') (D12_IDMOV ' + (cQry)->D12_IDMOV + ') (D12_IDOPER ' + (cQry)->D12_IDOPER + ') (D12_PRODUT ' + AllTrim((cQry)->D12_PRODUT) + ') (D12_LOTECT ' + AllTrim((cQry)->D12_LOTECT) + ').' //Movimento de separação não possui pedido vinculado (DCF xxx) (D12_IDMOV yyy) (D12_DOPER zzz) (D12_PRODUT www) (D12_LOTECT vvv). 
				WmsConout ('VLDGRVOS - Movimento de separação não possui pedido vinculado (DCF ' + (cQry)->D12_IDDCF + ') (D12_IDMOV ' + (cQry)->D12_IDMOV + ') (D12_IDOPER ' + (cQry)->D12_IDOPER + ') (D12_PRODUT ' + AllTrim((cQry)->D12_PRODUT) + ') (LOTE ' + AllTrim((cQry)->D12_LOTECT) + ').')
				(cQry)->(dbSkip())
			EndDo

			(cQry)->(dbCloseArea())

			WmsConout ('VLDGRVOS - Movimentos D12 sem pedido: ' + GetLastQuery()[2])

			//Valida se o indicador de aglutinado D12_AGLUTI = 1 quando houver aglutinação (Mais de 1 DCR).
			BeginSql Alias cQry
				SELECT D12.D12_AGLUTI,
					D12.R_E_C_N_O_,
					(SELECT Count(1) 
					FROM %Table:DCR% DCR
					WHERE DCR.DCR_FILIAL = %xFilial:DCR%
					AND DCR.DCR_IDORI = D12.D12_IDDCF
					AND DCR.DCR_IDMOV = D12.D12_IDMOV
					AND DCR.DCR_IDOPER = D12.D12_IDOPER
					AND DCR.%NotDel%) TOTAL
				FROM %Table:D12% D12
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_IDDCF IN (%Exp:cIdDCF%)
				AND D12.D12_ATUEST = '1'
				AND D12.D12_STATUS <> '0'				
				AND D12.%NotDel%
				AND D12.D12_TAREFA NOT IN (
					SELECT DC5_TAREFA 
					FROM %Table:DC5%
					WHERE DC5_FILIAL = %xFilial:DC5%						
					AND DC5_OPERAC = '7'
					AND %NotDel%)
			EndSql

			While (cQry)->(!Eof())
				If (cQry)->TOTAL > 1 .And. (cQry)->D12_AGLUTI == '2'
					cQryUpd := "UPDATE " + RetSqlName('D12')
					cQryUpd += " SET D12_AGLUTI = '1'"
					cQryUpd += " WHERE R_E_C_N_O_ = " + cValToChar((cQry)->R_E_C_N_O_)
					If TcSqlExec(cQryUpd) < 0
						cMessError += 'Erro Atualização D12_AGLUTI ' + TcSqlError()
					EndIf
	
					WmsConout ('VLDGRVOS - Atualização D12_AGLUTI: ' + GetLastQuery()[2])
				EndIf
		
				(cQry)->(dbSkip())
			EndDo

			(cQry)->(dbCloseArea())
		
			//Valida se Quantidade da OS confere com o somatório dos pedidos
			BeginSQL Alias cQry
				SELECT DCF.DCF_ID, DCF.DCF_QUANT,
					(SELECT SUM(C9_QTDLIB)
					FROM %Table:SC9% SC9 
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_IDDCF = DCF.DCF_ID
					AND SC9.%NotDel%) C9_QUANT
				FROM %Table:DCF% DCF
				WHERE DCF.DCF_FILIAL = %xFilial:DCF%
				AND DCF.DCF_ID IN (%Exp:cIdDCF%)
				AND DCF.%NotDel%
			EndSQL

			WmsConout ('VLDGRVOS - Quantidade OS x somatório pedidos: ' + GetLastQuery()[2])

			While (cQry)->(!Eof())
				If (cQry)->DCF_QUANT <> (cQry)->C9_QUANT
					lRet := .F.
					cMessError += STR0036 + AllTrim((cQry)->DCF_ID) + STR0037 + cValToChar((cQry)->DCF_QUANT) + STR0038 + cValToChar((cQry)->C9_QUANT) + ').' //OS aglutinada ID XXXX com quantidade (YY) diferente do somatório dos pedidos (ZZ'). 
					WmsConout ('VLDGRVOS - Erro valor 1: ' + cValToChar((cQry)->DCF_QUANT) + ' Valor 2: ' + cvalToChar((cQry)->C9_QUANT))
				EndIf
			
				(cQry)->(dbSkip())
			EndDo

			(cQry)->(dbCloseArea())
			
			//Valida se Quantidade dos movimentos bate com o somatório da distribuição
			BeginSQL Alias cQry
				SELECT D12.D12_IDDCF, D12.D12_QTDORI,
					(SELECT SUM (DCR.DCR_QUANT)
					FROM %Table:DCR% DCR
					WHERE DCR.DCR_FILIAL = %xFilial:DCR%
					AND DCR.DCR_IDORI = D12.D12_IDDCF
					AND DCR.DCR_IDMOV = D12.D12_IDMOV
					AND DCR.DCR_IDOPER = D12.D12_IDOPER
					AND DCR.DCR_SEQUEN = D12.D12_SEQUEN
					AND DCR.%NotDel%) DCR_QUANT
				FROM %Table:D12% D12 
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_IDDCF IN (%Exp:cIdDCF%)
				AND D12.D12_STATUS <> '0'
				AND D12.%NotDel%
			EndSQL

			WmsConout ('VLDGRVOS - Quantidade D12 x DCR: ' + GetLastQuery()[2])

			While (cQry)->(!Eof())				
				If (cQry)->D12_QTDORI <> (cQry)->DCR_QUANT
					lRet := .F.
					cMessError += STR0036 + AllTrim((cQry)->D12_IDDCF) + STR0040 + cValToChar((cQry)->D12_QTDORI) + STR0041 + cValToChar((cQry)->DCR_QUANT) + ').' //OS aglutinada ID XXXX com quantidade de movimento (YY) diferente do somatório necessário aos pedidos (ZZ). 
					WmsConout ('VLDGRVOS - Erro valor 1: ' + cValToChar((cQry)->D12_QTDORI) + ' Valor 2: ' + cvalToChar( (cQry)->DCR_QUANT))
				EndIf
			
				(cQry)->(dbSkip())
			EndDo

			(cQry)->(dbCloseArea())

			//Valida se quantidade do pedido/produto/lote é a mesma dos movimentos de distribuição.

			BeginSQL Alias cQry
				SELECT C9_IDDCF, SUM(C9_QTDLIB) QTDTOTAL 
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%						
				AND C9_IDDCF IN (%Exp:cIdDCF%) 
				AND SC9.%NotDel%
				GROUP BY SC9.C9_IDDCF
				ORDER BY SC9.C9_IDDCF	
			EndSQL
			
			WmsConout ('VLDGRVOS - Quantidade C9 por DCF: ' + GetLastQuery()[2])

			cQryDCR := GetNextAlias()

			While !(cQry)->(Eof())
				
				BeginSQL Alias cQryDCR
					SELECT SUM(DCR.DCR_QUANT) DCR_QUANT, DCR.DCR_IDMOV, DCR.DCR_IDOPER
					FROM %Table:DCR% DCR 
					WHERE DCR.DCR_FILIAL = %xFilial:DCR%						
					AND DCR.DCR_IDDCF = %Exp:(cQry)->C9_IDDCF%
					AND DCR.DCR_IDMOV NOT IN (
						SELECT D12.D12_IDMOV 
						FROM %Table:D12% D12
						WHERE D12.D12_FILIAL = %xFilial:D12%						 
						AND D12.D12_IDDCF = DCR.DCR_IDDCF
						AND D12.D12_STATUS <> '0'
						AND D12.D12_TAREFA IN (
							SELECT DC5_TAREFA 
							FROM %Table:DC5%
							WHERE DC5_FILIAL = %xFilial:DC5%						
							AND DC5_OPERAC = '7'
							AND %NotDel%)
						AND D12.%NotDel%)
					AND DCR.%NotDel%	
					GROUP BY DCR.DCR_IDMOV, DCR.DCR_IDOPER
					ORDER BY DCR.DCR_IDMOV, DCR.DCR_IDOPER
				EndSQL
				
				cIdMovAnt := ''
				nTotal := 0
				
				While !(cQryDCR)->(Eof())
					If (cQryDCR)->DCR_IDMOV <> cIdMovAnt	
						cIdMovAnt := (cQryDCR)->DCR_IDMOV 
						nTotal += (cQryDCR)->DCR_QUANT 
					EndIf

					(cQryDCR)->(dbSkip())
				EndDo

				WmsConout ('VLDGRVOS - Total C9: ' + cValToChar( (cQry)->QTDTOTAL) + ' Total Separação: ' + cValToChar(nTotal))
				If (cQry)->QTDTOTAL <> nTotal
					lRet := .F.
					cMessError += STR0046 + AllTrim((cQry)->c9_IDDCF) +  STR0047 + cValToChar((cQry)->QTDTOTAL)  + STR0048 + cValToChar(nTotal) + '.'  //'Divergência atividade de separação: IDDCF ' + (cQry)->c9_IDDCF +  ' / Qtde Pedido ' + cValToChar((cQry)->QTDTOTAL)  + ' / Somatório dos Movimentos (DCR) ' + cValToChar(nTotal) + '.' 
				EndIf

				(cQryDCR)->(dbCloseArea())

				BeginSQL Alias cQryDCR
					SELECT SUM(DCR.DCR_QUANT) DCR_QUANT, DCR.DCR_IDMOV, DCR.DCR_IDOPER
					FROM %Table:DCR% DCR 
					WHERE DCR.DCR_FILIAL = %xFilial:DCR%						
					AND DCR.DCR_IDDCF = %Exp:(cQry)->C9_IDDCF%
					AND DCR.DCR_IDMOV IN (
						SELECT D12.D12_IDMOV 
						FROM %Table:D12% D12
						WHERE D12.D12_FILIAL = %xFilial:D12%						 
						AND D12.D12_IDDCF = DCR.DCR_IDDCF
						AND D12.D12_STATUS <> '0'
						AND D12.D12_TAREFA IN (
							SELECT DC5_TAREFA 
							FROM %Table:DC5%
							WHERE DC5_FILIAL = %xFilial:DC5%						
							AND DC5_OPERAC = '7'
							AND %NotDel%)
						AND D12.%NotDel%)
					AND DCR.%NotDel%	
					GROUP BY DCR.DCR_IDMOV, DCR.DCR_IDOPER
					ORDER BY DCR.DCR_IDMOV, DCR.DCR_IDOPER
				EndSQL

				cIdMovAnt := ''
				nTotal := 0
				
				While !(cQryDCR)->(Eof())
					If (cQryDCR)->DCR_IDMOV <> cIdMovAnt	
						cIdMovAnt := (cQryDCR)->DCR_IDMOV 
						nTotal += (cQryDCR)->DCR_QUANT 
					EndIf

					(cQryDCR)->(dbSkip())
				EndDo

				WmsConout ('VLDGRVOS - Total C9: ' + cValToChar( (cQry)->QTDTOTAL) + ' Total Conferência: ' + cvalToChar(nTotal))
				If (cQry)->QTDTOTAL <> nTotal .And. nTotal > 0 //Se nTotal = 0 a OS não possui conferência
					lRet := .F.
					cMessError += STR0050 + AllTrim((cQry)->c9_IDDCF) +  STR0047 + cValToChar((cQry)->QTDTOTAL)  + STR0048 + cValToChar(nTotal) + '.' //'Divergência atividade de conferência: IDDCF ' + (cQry)->c9_IDDCF +  ' / Qtde Pedido ' + cValToChar((cQry)->QTDTOTAL)  + ' / Somatório dos Movimentos (DCR) ' + cValToChar(nTotal) + '.'
				EndIf
				
				(cQryDCR)->(dbCloseArea())

				(cQry)->(dbSkip())
			EndDo
			
			(cQry)->(dbCloseArea())
		EndIf
	EndIf

	//EndIf

	If !Vazio(cMessError)	
		cMessError += STR0039 //Tente novamente.
	EndIf

Return lRet

//----------------------------------------
/*/{Protheus.doc} EstOpTotal
Realiza a comparação da SD3 com a D13 referente ao que foi estornado e 
replica para a tabela D13.
@author equipe WMS
@since 15/09/2022
@version 1.0
/*/
//----------------------------------------
METHOD EstOpTotal() CLASS WMSDTCOrdemServico
Local lRet       := .T.
Local cAliasD13  := Nil
	// Atualiza Saldo
	// Busca dados do kardex
	cAliasD13 := GetNextAlias()
	BeginSql Alias cAliasD13
		SELECT D13.R_E_C_N_O_ RECNOD13
		FROM %Table:D13% D13
		INNER JOIN %Table:SD3% SD3
		ON SD3.D3_FILIAL = %xFilial:SD3%
		AND SD3.D3_DOC = D13.D13_DOC
		AND SD3.D3_COD = D13.D13_PRODUT
		AND SD3.D3_LOCAL = D13.D13_LOCAL
		AND SD3.D3_TM = D13.D13_TM
		AND SD3.D3_NUMSEQ = D13.D13_NUMSEQ
		AND SD3.%NotDel%
		WHERE D13.D13_FILIAL = %xFilial:D13%
		AND D13.D13_ORIGEM = %Exp:Self:cOrigem%
		AND D13.D13_DOC = %Exp:Self:cDocumento%
		AND D13.D13_SERIE = %Exp:Self:cSerie%
		AND D13.D13_CLIFOR = %Exp:Self:cCliFor%
		AND D13.D13_LOJA = %Exp:Self:cLoja%
		AND D13.D13_NUMSEQ = %Exp:Self:cNumSeq%
		AND D13.D13_USACAL <> '2'
		AND D13.D13_ORIGEM = 'SC2'
		AND SD3.D3_ESTORNO = 'S'
		AND D13.%NotDel%
	EndSql
	Do While lRet .And. (cAliasD13)->(!Eof())

		D13->(dbGoTo((cAliasD13)->RECNOD13))
		// Atualiza dados
		Reclock("D13",.F.)
		D13->D13_DTESTO := dDataBase
		D13->D13_HRESTO := Time()
		D13->D13_USACAL := "2"
		D13->(MsUnlock())
		
		(cAliasD13)->(dbSkip())
	EndDo
	(cAliasD13)->(dbCloseArea())
Return lRet
