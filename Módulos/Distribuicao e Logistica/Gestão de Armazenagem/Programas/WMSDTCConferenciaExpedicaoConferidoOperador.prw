#Include 'TOTVS.CH'  
#Include 'WMSDTCConferenciaExpedicaoConferidoOperador.CH'
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0010
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0010()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCConferenciaExpedicaoConferidoOperador
Classe do produto conferido por operador
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCConferenciaExpedicaoConferidoOperador FROM LongNameClass
	// Data
	DATA oConfExpItem
	DATA cCodOpe
	DATA cItem
	DATA cSequen
	DATA nQtConf
	DATA dDtIni
	DATA cHrIni
	DATA dDtFim
	DATA cHrFim
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	// Setters
	METHOD SetCarga(cCarga)
	METHOD SetPedido(cPedido)
	METHOD SetCodExp(cCodExp)
	METHOD SetCodOpe(cCodOpe)
	METHOD SetProduto(cProduto)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetItem(cItem)
	METHOD SetSequen(cSequen)
	METHOD SetQtConf(nQtConf)
	METHOD SetDtIni(dDtIni)
	METHOD SetHrIni(cHrIni)
	METHOD SetDtFim(dDtFim)
	METHOD SetHrFim(cHrFim)
	// Getters
	METHOD GetCarga()
	METHOD GetPedido()
	METHOD GetCodExp()
	METHOD GetCodOpe()
	METHOD GetProduto()
	METHOD GetPrdOri()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetIdDCF()
	METHOD GetItem()
	METHOD GetSequen()
	METHOD GetQtConf()
	METHOD GetDtIni()
	METHOD GetHrIni()
	METHOD GetDtFim()
	METHOD GetHrFim()
	// Metodos
	METHOD ClearData()
	METHOD Destroy()
	METHOD GetQtSeqLib()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 11/08/2016
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:oConfExpItem := WMSDTCConferenciaExpedicaoItens():New()
	Self:cCodOpe := PadR("", TamSx3("D04_CODOPE")[1])
	Self:cItem   := PadR("", TamSx3("D04_ITEM")[1])
	Self:cSequen := PadR("", TamSx3("D04_SEQUEN")[1])
	Self:ClearData()
Return

METHOD ClearData() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:cCodOpe := PadR("", Len(Self:cCodOpe))
	Self:cItem   := PadR("", Len(Self:cItem))
	Self:cSequen := PadR("", Len(Self:cSequen))
	Self:nQtConf := 0
	Self:dDtIni  := dDataBase
	Self:cHrIni  := Time()
	Self:dDtFim  := dDataBase
	Self:cHrFim  := Time()
	Self:nRecno  := 0
	Self:cErro   := ""
Return 

METHOD Destroy() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	//Mantido para compatibilidade
Return
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D04
@author felipe.m
@since 11/08/2016
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD04    := D04->(GetArea())
Local aD04_QTCONF := TamSx3("D04_QTCONF")
Local cAliasD04   := Nil

Default nIndex   := 1

	Do Case
		Case nIndex == 3 // D04_FILIAL+D04_PEDIDO+D04_ITEM+D04_SEQUEN+D04_PRDORI
			If Empty(Self:GetPedido()) .Or. Empty(Self:GetItem()) .Or. Empty(Self:GetSequen()) .Or. Empty(Self:GetPrdOri())
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // "Dados para busca não foram informados!"
	Else
		cAliasD04 := GetNextAlias()
		Do Case
			Case nIndex == 3
				BeginSql Alias cAliasD04
					SELECT D04.D04_FILIAL,
							D04.D04_CARGA,
							D04.D04_PEDIDO,
							D04.D04_CODEXP,
							D04.D04_CODPRO,
							D04.D04_PRDORI,
							D04.D04_LOTE,
							D04.D04_SUBLOT,
							D04.D04_CODOPE,
							D04.D04_ITEM,
							D04.D04_SEQUEN,
							D04.D04_QTCONF,
							D04.D04_DTINI,
							D04.D04_HRINI,
							D04.D04_DTFIM,
							D04.D04_HRFIM,
							D04.R_E_C_N_O_ RECNOD04
					FROM %Table:D04% D04
					WHERE D04.D04_FILIAL = %xFilial:D04%
					AND D04.D04_PEDIDO = %Exp:Self:GetPedido()%
					AND D04.D04_ITEM = %Exp:Self:GetItem()%
					AND D04.D04_SEQUEN = %Exp:Self:GetSequen()%
					AND D04.D04_PRDORI = %Exp:Self:GetPrdOri()%
					AND D04.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD04,'D04_QTCONF','N',aD04_QTCONF[1],aD04_QTCONF[2])
		If (lRet := (cAliasD04)->(!Eof()))
			Self:SetCarga((cAliasD04)->D04_CARGA)
			Self:SetPedido((cAliasD04)->D04_PEDIDO)
			Self:SetCodExp((cAliasD04)->D04_CODEXP)
			Self:SetProduto((cAliasD04)->D04_CODPRO)
			Self:SetPrdOri((cAliasD04)->D04_PRDORI)
			Self:SetLoteCtl((cAliasD04)->D04_LOTE)
			Self:SetNumLote((cAliasD04)->D04_SUBLOT)
			Self:oConfExpItem:LoadData()
			
			Self:cCodOpe := (cAliasD04)->D04_CODOPE
			Self:cItem   := (cAliasD04)->D04_ITEM
			Self:cSequen := (cAliasD04)->D04_SEQUEN
			Self:nQtConf := (cAliasD04)->D04_QTCONF
			Self:dDtIni  := (cAliasD04)->D04_DTINI
			Self:cHrIni  := (cAliasD04)->D04_HRINI
			Self:dDtFim  := (cAliasD04)->D04_DTFIM
			Self:cHrFim  := (cAliasD04)->D04_HRFIM
			Self:nRecno  := (cAliasD04)->RECNOD04
		EndIf
		(cAliasD04)->(dbCloseArea())
	EndIf
	RestArea(aAreaD04)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCarga(cCarga) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:oConfExpItem:SetCarga(cCarga)
Return

METHOD SetPedido(cPedido) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:oConfExpItem:SetPedido(cPedido)
Return

METHOD SetCodExp(cCodExp) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:oConfExpItem:SetCodExp(cCodExp)
Return

METHOD SetProduto(cProduto) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:oConfExpItem:SetProduto(cProduto)
Return

METHOD SetPrdOri(cPrdOri) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:oConfExpItem:SetPrdOri(cPrdOri)
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:oConfExpItem:SetLoteCtl(cLoteCtl)
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:oConfExpItem:SetNumLote(cNumLote)
Return

METHOD SetCodOpe(cCodOpe) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:cCodOpe := cCodOpe
Return

METHOD SetItem(cItem) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:cItem := PadR(cItem, Len(Self:cItem))
Return

METHOD SetSequen(cSequen) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:cSequen := PadR(cSequen, Len(Self:cSequen))
Return

METHOD SetQtConf(nQtConf) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:nQtConf := nQtConf
Return

METHOD SetDtIni(dDtIni) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:dDtIni := dDtIni
Return

METHOD SetHrIni(cHrIni) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:cHrIni := cHrIni
Return

METHOD SetDtFim(dDtFim) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:dDtFim := dDtFim
Return

METHOD SetHrFim(cHrFim) CLASS WMSDTCConferenciaExpedicaoConferidoOperador
	Self:cHrFim := cHrFim
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCarga() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:oConfExpItem:GetCarga()

METHOD GetPedido() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:oConfExpItem:GetPedido()

METHOD GetCodExp() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:oConfExpItem:GetCodExp()

METHOD GetProduto() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:oConfExpItem:GetProduto()

METHOD GetPrdOri() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:oConfExpItem:GetPrdOri()

METHOD GetLoteCtl() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:oConfExpItem:GetLoteCtl()

METHOD GetNumLote() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:oConfExpItem:GetNumLote()

METHOD GetCodOpe() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:cCodOpe

METHOD GetItem() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:cItem

METHOD GetSequen() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:cSequen

METHOD GetQtConf() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:nQtConf

METHOD GetDtIni() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:dDtIni

METHOD GetHrIni() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:cHrIni

METHOD GetDtFim() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:dDtFim

METHOD GetHrFim() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Return Self:cHrFim

METHOD GetQtSeqLib() CLASS WMSDTCConferenciaExpedicaoConferidoOperador
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
Local nQtSeqLib := 0
	BeginSql Alias cAliasQry
		SELECT MIN(D04.D04_QTCONF / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D04_QTCONF
		FROM %Table:D04% D04
		LEFT JOIN %Table:D11% D11
		ON D11.D11_FILIAL = %xFilial:D11%
		AND D04.D04_FILIAL = %xFilial:D04%
		AND D11.D11_PRODUT = D04.D04_PRDORI
		AND D11.D11_PRDORI = D04.D04_PRDORI
		AND D11.D11_PRDCMP = D04.D04_CODPRO
		AND D11.%NotDel%
		WHERE D04.D04_FILIAL = %xFilial:D04%
		AND D04.D04_PEDIDO = %Exp:Self:GetPedido()%
		AND D04.D04_ITEM = %Exp:Self:GetItem()%
		AND D04.D04_SEQUEN = %Exp:Self:GetSequen()%
		AND D04.D04_PRDORI = %Exp:Self:GetPrdOri()%
		AND D04.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		nQtSeqLib := (cAliasQry)->D04_QTCONF
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return nQtSeqLib
