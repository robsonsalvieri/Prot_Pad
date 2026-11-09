#Include "Totvs.ch"
#Include "WMSBCCConferenciaSaida.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0003
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0003()
Return Nil
//---------------------------------------------
/*/{Protheus.doc} WMSBCCConferenciaSaida
Classe de conferência de saída
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
CLASS WMSBCCConferenciaSaida FROM WMSDTCMovimentosServicoArmazem

	METHOD New() CONSTRUCTOR
	METHOD ExecFuncao()
	METHOD SetOrdServ(oOrdServ)
	METHOD VldGeracao()
	METHOD ProcConfSai()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSBCCConferenciaSaida
	_Super:New()
Return

METHOD SetOrdServ(oOrdServ) CLASS WMSBCCConferenciaSaida
	Self:oOrdServ := oOrdServ
	Self:oMovServic := Self:oOrdServ:oServico
	// Carrega dados endereço origem
	Self:oMovEndOri:SetArmazem(Self:oOrdServ:oOrdEndDes:GetArmazem())
	Self:oMovEndOri:SetEnder(Self:oOrdServ:oOrdEndDes:GetEnder())
	Self:oMovEndOri:LoadData()
	Self:oMovEndOri:ExceptEnd()
	// Carrega dados endereço destino
	Self:oMovEndDes:SetArmazem(Self:oOrdServ:oOrdEndDes:GetArmazem())
	Self:oMovEndDes:SetEnder(Self:oOrdServ:oOrdEndDes:GetEnder())
	Self:oMovEndDes:LoadData()
	Self:oMovEndDes:ExceptEnd()
Return

METHOD Destroy() CLASS WMSBCCConferenciaSaida
	//FreeObj(Self)
Return

METHOD VldGeracao() CLASS WMSBCCConferenciaSaida
Local lRet := .T.
Return lRet

METHOD ExecFuncao() CLASS WMSBCCConferenciaSaida
Local lRet      := .T.
Local nRecnoDCF := Self:oOrdServ:GetRecno()
Local nRegraWMS := Self:oOrdServ:GetRegra()
	If Self:VldGeracao()
		lRet := Self:ProcConfSai()
	Else
		lRet := .F.
	EndIf
	If Self:oOrdServ:GetRecno() != nRecnoDCF
		Self:oOrdServ:GoToDCF(nRecnoDCF) // Recarrega a DCF original quando aglutina tarefas
	EndIf
	Self:oOrdServ:SetRegra(nRegraWMS) // Recarrega também a regra WMS, que pode estar em branco no registro da DCF, porém foi definida no processo de separação
Return lRet

METHOD ProcConfSai() CLASS WMSBCCConferenciaSaida
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local aAreaDC5  := DC5->(GetArea())
Local aTamSX3   := TamSx3('DCR_QUANT')
Local cAliasQry := Nil
Local cDCFID    := ""
Local cOrdSep   := "01"
Local nI        := 0
	
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DC5.DC5_ORDEM
		FROM %Table:DC5% DC5
		WHERE DC5.DC5_FILIAL = %xFilial:DC5%
		AND DC5.DC5_SERVIC = %Exp:Self:oMovServic:GetServico()%
		AND DC5.DC5_ORDEM < %Exp:Self:oMovServic:GetOrdem()%
		AND DC5.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		cOrdSep := (cAliasQry)->DC5_ORDEM
	EndIf
	(cAliasQry)->(DbCloseArea())
	//Variável utilizada para gravar todas as IdDCF contidas no array de aglutinação para utilização na query
	If Len(Self:GetOrdAglu()) > 0
		For nI := 1 To Len(Self:GetOrdAglu())
			cDCFID += IIF (nI  == Len(Self:GetOrdAglu()),"'"+Self:GetOrdAglu()[nI][1]+"'","'"+Self:GetOrdAglu()[nI][1]+"',")
		Next nI
	Else
		cDCFID := "'"+Self:GetIdDCF()+"'"
	EndIf
	cDCFID := "%"+cDCFID+"%"
	cAliasQry := GetNextAlias()
	//Ordernar por IDDCF pois
	BeginSql Alias cAliasQry
		SELECT DCR.DCR_IDDCF,
				D12.D12_PRODUT,
				D12.D12_LOTECT,
				D12.D12_NUMLOT,
				D12.D12_NUMSER,
				SUM(DCR.DCR_QUANT) DCR_QUANT
		FROM %Table:DCR% DCR
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
		AND D12.D12_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
		AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
		AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
		AND D12.D12_IDDCF = DCR.DCR_IDORI
		AND D12.D12_IDMOV = DCR.DCR_IDMOV
		AND D12.D12_IDOPER = DCR.DCR_IDOPER
		AND D12.D12_STATUS IN ('4','-')
		AND D12.D12_ORDTAR = %Exp:cOrdSep% // Assume a tarefa exatamante anterior
		AND D12.D12_ORDMOV IN ('3','4')
		AND D12.%NotDel%
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDDCF  IN ( %Exp:cDCFID% )
		AND DCR.%NotDel%
		GROUP BY DCR.DCR_IDDCF,
					D12.D12_PRODUT,
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_NUMSER					
		ORDER BY DCR.DCR_IDDCF, 
			   		D12.D12_PRODUT,
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_NUMSER					
	EndSql
	TcSetField(cAliasQry,'DCR_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While lRet .And. (cAliasQry)->(!Eof())
		// Carregando as informações do movimento
		Self:oMovPrdLot:SetLoteCtl((cAliasQry)->D12_LOTECT) // Lote
		Self:oMovPrdLot:SetNumLote((cAliasQry)->D12_NUMLOT) // Sub-Lote
		Self:oMovPrdLot:SetNumSer((cAliasQry)->D12_NUMSER)  // Numero de série
		If Self:oOrdServ:GetIdDCF() != (cAliasQry)->DCR_IDDCF
			Self:oOrdServ:SetIdDCF((cAliasQry)->DCR_IDDCF)
			Self:oOrdServ:LoadData()
		EndIf
		// Status movimento
		Self:cStatus := IIf(Self:oMovServic:GetBlqSrv() == "1","2","4")
		Self:SetLibPed(Self:oMovServic:GetLibPed())
		Self:nQtdMovto := (cAliasQry)->DCR_QUANT
		// Executa todas as Atividades (DC6) da Tarefa (DC5) Atual
		If !Self:AssignD12()
			lRet := .F.
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaDC5)
	RestArea(aAreaAnt)
Return lRet
