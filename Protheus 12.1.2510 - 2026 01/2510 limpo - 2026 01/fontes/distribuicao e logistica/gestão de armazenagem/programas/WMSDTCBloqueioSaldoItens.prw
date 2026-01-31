#INCLUDE 'TOTVS.CH'
#INCLUDE "WMSDTCBloqueioSaldoItens.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0062
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Squad WMS Embarcador
@since 26/07/2017
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0062()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCBloqueioSaldoItens
Classe de Itens do Bloqueio de Saldo (D0V)
@author Squad WMS Embarcador
@since 26/07/2017
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCBloqueioSaldoItens FROM LongNameClass
	// Data	
	DATA oOrdServ
	DATA oMovServ
	DATA oBlqSaldo
	DATA cPrdOri
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA cArmazem
	DATA cEnder
	DATA cIdUnit
	DATA cIdDCF
	DATA cTM
	DATA dDtValid
	DATA cErro
	DATA nRecno
	DATA nIndex
	DATA nQtdOri
	DATA nQtdBlq
	DATA nQtdBlq2
	DATA nQtdBlqT
	DATA nQtdLib
	DATA nQtdLib2
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToD0V(nRecno)
	METHOD LoadData(nIndex)
	METHOD RecordD0V()
	METHOD AssignSDD()
	METHOD AssignD0V()
	METHOD GerarSDD()
	METHOD GerarD0U()
	METHOD GerarEmpenho()
	METHOD GerarBloqueioEstoque()
	METHOD RemoverBloqueioEstoque()
	METHOD RemoverBloqueio()
	METHOD RemoverEmpenho()
	METHOD RemoverSDD()
	METHOD RealizarBloqueio()
	METHOD AtualizarD0V()
	METHOD UpdateD0V()
	METHOD ExisteD0V()
	METHOD RevBlqSld()
	METHOD ApagarD0U()
	METHOD DeleteD0V()
	METHOD ClearData()
	// Setters
	METHOD SetOrdServ(oOrdServ)
	METHOD SetMovServ(oMovServ)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetArmazem(cArmazem)
	METHOD SetEnder(cEnder)
	METHOD SetIdUnit(cIdUnit)
	METHOD SetDocto(cDocto)
	METHOD SetTM(cTM)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetQtdBlq(nQtdBlq)
	METHOD SetDtValid(dDtValid)
	METHOD SetIdBlq(cIdBlq)
	METHOD SetQtdLib(nQtdLib)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetMotivo(cMotivo)
	METHOD SetObserv(cObserv)
	METHOD SetOrigem(cOrigem)
	METHOD SetTipBlq(cTipBlq)

	// Getters
	METHOD GetIdBlq()
	METHOD GetPrdOri()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetArmazem()
	METHOD GetEnder()
	METHOD GetIdUnit()
	METHOD GetQtdOri()
	METHOD GetQtdBlq()
	METHOD GetQtdBlq2()
	METHOD GetQtdLib2()
	METHOD GetDtValid()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author Squad WMS Embarcador
@since 26/07/2017
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCBloqueioSaldoItens
	Self:oOrdServ := Nil
	Self:oMovServ := Nil
	Self:oBlqSaldo:= WMSDTCBloqueioSaldo():New()
	Self:cPrdOri  := PadR("", TamSx3("D0V_PRDORI")[1])
	Self:cProduto := PadR("", TamSx3("D0V_PRODUT")[1])
	Self:cLoteCtl := PadR("", TamSx3("D0V_LOTECT")[1])
	Self:cNumLote := PadR("", TamSx3("D0V_NUMLOT")[1])
	Self:cArmazem := PadR("", TamSx3("D0V_LOCAL")[1])
	Self:cEnder   := PadR("", TamSx3("D0V_ENDER")[1])
	Self:cIdUnit  := PadR("", TamSx3("D0V_IDUNIT")[1])
	Self:ClearData()
Return
//----------------------------------------
METHOD ClearData() CLASS WMSDTCBloqueioSaldoItens
	Self:oBlqSaldo:ClearData()
	Self:cPrdOri  := PadR("", Len(Self:cPrdOri))
	Self:cProduto := PadR("", Len(Self:cProduto))
	Self:cLoteCtl := PadR("", Len(Self:cLoteCtl))
	Self:cNumLote := PadR("", Len(Self:cNumLote))
	Self:cArmazem := PadR("", Len(Self:cArmazem))
	Self:cEnder   := PadR("", Len(Self:cEnder))
	Self:cIdUnit  := PadR("", Len(Self:cIdUnit))
	Self:cTM      := "999"
	Self:dDtValid := CtoD("")
	Self:nQtdOri  := 0
	Self:nQtdBlq  := 0
	Self:nQtdBlqT := 0
	Self:nRecno   := 0
	Self:cErro    := ""
Return
//----------------------------------------
METHOD Destroy() CLASS WMSDTCBloqueioSaldoItens
	//Método mantido para compatibilidade
Return Nil
//----------------------------------------
METHOD GoToD0V(nRecno) CLASS WMSDTCBloqueioSaldoItens
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCBloqueioSaldoItens
Local lRet        := .T.
Local aAreaD0V    := D0V->(GetArea())
Local aD0V_QTDORI := TamSx3("D0V_QTDORI")
Local cWhere      := ""
Local cAliasD0V   := Nil

Default nIndex := 1

	Do Case
		Case nIndex == 0 // R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0V_FILIAL+D0V_IDBLOQ+D0V_PRDORI+D0V_PRODUT+D0V_LOTECT+D0V_NUMLOT+D0V_LOCAL+D0V_ENDER+D0V_IDUNIT
			If Empty(Self:GetIdBlq()) .Or. Empty(Self:cPrdOri) .Or. Empty(Self:cProduto) .Or. Empty(Self:cArmazem)
				lRet := .F.
			EndIf

		Otherwise
			lRet := .F.
	EndCase

	If !lRet
		Self:cErro := STR0001 + " (" + GetClassName(Self) + ":LoadData(" + cValToChar(nIndex) + " )(D0V))" // Dados para busca não foram informados! 
	Else
		cAliasD0V:= GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0V
					SELECT D0V.D0V_IDBLOQ,
							D0V.D0V_PRDORI,
							D0V.D0V_PRODUT,
							D0V.D0V_LOTECT,
							D0V.D0V_NUMLOT,
							D0V.D0V_LOCAL,
							D0V.D0V_ENDER,
							D0V.D0V_IDUNIT,
							D0V.D0V_QTDORI,
							D0V.D0V_QTDBLQ,
							D0V.D0V_DTVALD,
							D0V.R_E_C_N_O_ RECNOD0V
					FROM %Table:D0V% D0V
					WHERE D0V.D0V_FILIAL = %xFilial:D0V%
					AND D0V.R_E_C_N_O_ = %Exp:cValtoChar(Self:nRecno)%
					AND D0V.%NotDel%
				EndSql
			Case nIndex == 1
				// Parâmetro Where
				cWhere := "%"
				If !Empty(Self:cEnder)
					cWhere += " AND D0V.D0V_ENDER  = '"+Self:cEnder+"'"
				EndIf
				If !Empty(Self:cIdUnit)
					cWhere += " AND D0V.D0V_IDUNIT = '"+Self:cIdUnit+"'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD0V
					SELECT D0V.D0V_IDBLOQ,
							D0V.D0V_PRDORI,
							D0V.D0V_PRODUT,
							D0V.D0V_LOTECT,
							D0V.D0V_NUMLOT,
							D0V.D0V_LOCAL,
							D0V.D0V_ENDER,
							D0V.D0V_IDUNIT,
							D0V.D0V_QTDORI,
							D0V.D0V_QTDBLQ,
							D0V.D0V_DTVALD,
							D0V.R_E_C_N_O_ RECNOD0V
					FROM %Table:D0V% D0V
					WHERE D0V.D0V_FILIAL = %xFilial:D0V%
					AND D0V.D0V_IDBLOQ = %Exp:Self:GetIdBlq()%
					AND D0V.D0V_PRDORI = %Exp:Self:cPrdOri%
					AND D0V.D0V_PRODUT = %Exp:Self:cProduto%
					AND D0V.D0V_LOTECT = %Exp:Self:cLoteCtl%
					AND D0V.D0V_NUMLOT = %Exp:Self:cNumLote%
					AND D0V.D0V_LOCAL =  %Exp:Self:cArmazem%
					AND D0V.%NotDel%
					%Exp:cWhere%
				EndSql
		EndCase
		TCSetField(cAliasD0V,'D0V_QTDORI','N',aD0V_QTDORI[1],aD0V_QTDORI[2])
		TCSetField(cAliasD0V,'D0V_QTDBLQ','N',aD0V_QTDORI[1],aD0V_QTDORI[2])
		TcSetField(cAliasD0V,'D0V_DTVALD','D')
		If (lRet := (cAliasD0V)->(!Eof()))
			Self:oBlqSaldo:SetIdBlq((cAliasD0V)->D0V_IDBLOQ)
			Self:oBlqSaldo:LoadData(3)
			Self:cPrdOri  := (cAliasD0V)->D0V_PRDORI
			Self:cProduto := (cAliasD0V)->D0V_PRODUT
			Self:cLoteCtl := (cAliasD0V)->D0V_LOTECT
			Self:cNumLote := (cAliasD0V)->D0V_NUMLOT
			Self:cArmazem := (cAliasD0V)->D0V_LOCAL
			Self:cEnder   := (cAliasD0V)->D0V_ENDER
			Self:cIdUnit  := (cAliasD0V)->D0V_IDUNIT
			Self:nQtdOri  := (cAliasD0V)->D0V_QTDORI
			Self:nQtdBlq  := (cAliasD0V)->D0V_QTDBLQ
			Self:dDtValid := (cAliasD0V)->D0V_DTVALD
			Self:nRecno   := (cAliasD0V)->RECNOD0V
		EndIf
		(cAliasD0V)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0V)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetOrdServ(oOrdServ) CLASS WMSDTCBloqueioSaldoItens
	Self:oOrdServ := oOrdServ
Return
//----------------------------------------
METHOD SetMovServ(oMovServ) CLASS WMSDTCBloqueioSaldoItens
	Self:oMovServ := oMovServ
Return
//----------------------------------------
METHOD SetPrdOri(cPrdOri) CLASS WMSDTCBloqueioSaldoItens
	Self:cPrdOri := PadR(cPrdOri, Len(Self:cPrdOri))
Return
//----------------------------------------
METHOD SetProduto(cProduto) CLASS WMSDTCBloqueioSaldoItens
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return
//----------------------------------------
METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCBloqueioSaldoItens
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return
//----------------------------------------
METHOD SetNumLote(cNumLote) CLASS WMSDTCBloqueioSaldoItens
	Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))
Return
//----------------------------------------
METHOD SetArmazem(cArmazem) CLASS WMSDTCBloqueioSaldoItens
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return
//----------------------------------------
METHOD SetEnder(cEnder) CLASS WMSDTCBloqueioSaldoItens
	Self:cEnder := PadR(cEnder, Len(Self:cEnder))
Return
//----------------------------------------
METHOD SetIdUnit(cIdUnit) CLASS WMSDTCBloqueioSaldoItens
	Self:cIdUnit := PadR(cIdUnit, Len(Self:cIdUnit))
Return
//----------------------------------------
METHOD SetTM(cTM) CLASS WMSDTCBloqueioSaldoItens
	Self:cTM := PadR(cTM, Len(Self:cTM))
Return
//----------------------------------------
METHOD SetQtdOri(nQtdOri) CLASS WMSDTCBloqueioSaldoItens
	Self:nQtdOri := nQtdOri
Return
//----------------------------------------
METHOD SetQtdBlq(nQtdBlq) CLASS WMSDTCBloqueioSaldoItens
	Self:nQtdBlq := nQtdBlq
Return	
//----------------------------------------
METHOD SetDtValid(dDtValid) CLASS WMSDTCBloqueioSaldoItens
	Self:dDtValid := dDtValid
Return
//----------------------------------------
METHOD SetIdBlq(cIdBlq) CLASS WMSDTCBloqueioSaldoItens
Return Self:oBlqSaldo:SetIdBlq(cIdBlq)
//----------------------------------------
METHOD SetIdDCF(cIdDCF) CLASS WMSDTCBloqueioSaldoItens
Return Self:oBlqSaldo:SetIdDCF(cIdDCF)
//----------------------------------------
METHOD SetDocto(cDocto) CLASS WMSDTCBloqueioSaldoItens
Return Self:oBlqSaldo:SetDocto(cDocto)
//----------------------------------------
METHOD SetMotivo(cMotivo) CLASS WMSDTCBloqueioSaldoItens
Return Self:oBlqSaldo:SetMotivo(cMotivo)
//----------------------------------------
METHOD SetObserv(cObserv) CLASS WMSDTCBloqueioSaldoItens
Return Self:oBlqSaldo:SetObserv(cObserv)
//----------------------------------------
METHOD SetOrigem(cOrigem) CLASS WMSDTCBloqueioSaldoItens
Return Self:oBlqSaldo:SetOrigem(cOrigem)
//----------------------------------------
METHOD SetTipBlq(cTipBlq) CLASS WMSDTCBloqueioSaldoItens
Return Self:oBlqSaldo:SetTipBlq(cTipBlq)
//----------------------------------------
METHOD SetQtdLib(nQtdLib) CLASS WMSDTCBloqueioSaldoItens
	Self:nQtdLib := nQtdLib
Return 
//----------------------------------------
// Getters
//-----------------------------------
METHOD GetIdBlq() CLASS WMSDTCBloqueioSaldoItens
Return Self:oBlqSaldo:GetIdBlq()
//----------------------------------------
METHOD GetPrdOri() CLASS WMSDTCBloqueioSaldoItens
Return Self:cPrdOri
//----------------------------------------
METHOD GetProduto() CLASS WMSDTCBloqueioSaldoItens
Return Self:cProduto
//----------------------------------------
METHOD GetLoteCtl() CLASS WMSDTCBloqueioSaldoItens
Return Self:cLoteCtl
//----------------------------------------
METHOD GetNumLote() CLASS WMSDTCBloqueioSaldoItens
Return Self:cNumLote
//----------------------------------------
METHOD GetArmazem() CLASS WMSDTCBloqueioSaldoItens
Return Self:cArmazem
//----------------------------------------
METHOD GetEnder() CLASS WMSDTCBloqueioSaldoItens
Return Self:cEnder
//----------------------------------------
METHOD GetIdUnit() CLASS WMSDTCBloqueioSaldoItens
Return Self:cIdUnit
//----------------------------------------
METHOD GetQtdOri() CLASS WMSDTCBloqueioSaldoItens
Return Self:nQtdOri
//----------------------------------------
METHOD GetQtdBlq() CLASS WMSDTCBloqueioSaldoItens
Return Self:nQtdBlq
//----------------------------------------
METHOD GetQtdBlq2() CLASS WMSDTCBloqueioSaldoItens
Return ConvUm(Self:cPrdOri,Self:nQtdBlq,0,2)
//----------------------------------------
METHOD GetQtdLib2() CLASS WMSDTCBloqueioSaldoItens
Return ConvUm(Self:cPrdOri,Self:nQtdLib,0,2)
//----------------------------------------
METHOD GetDtValid() CLASS WMSDTCBloqueioSaldoItens
Return IiF(Empty(Self:dDtValid),CToD(""),Self:dDtValid)
//----------------------------------------
METHOD GetRecno() CLASS WMSDTCBloqueioSaldoItens
Return Self:nRecno
//----------------------------------------
METHOD GetErro() CLASS WMSDTCBloqueioSaldoItens
Return Self:cErro
//-----------------------------------------
/*/{Protheus.doc} RecordD0V
Grava D0V
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD RecordD0V() CLASS WMSDTCBloqueioSaldoItens
Local aAreaAnt := GetArea()
Local lRet := .T.
	dbSelectArea("D0V")
	D0V->(dbSetOrder(1)) //D0V_FILIAL+D0V_IDBLOQ+D0V_PRDORI+D0V_PRODUT+D0V_LOTECT+D0V_NUMLOT+D0V_LOCAL+D0V_ENDER+D0V_IDUNIT
	If !D0V->(DbSeek(xFilial('D0V')+Self:GetIdBlq()+Self:cPrdOri+Self:cProduto+Self:cLoteCtl+Self:cNumLote+Self:cArmazem+Self:cEnder+Self:cIdUnit))
		RecLock("D0V", .T.)
		D0V->D0V_FILIAL := xFilial("D0V")
		D0V->D0V_IDBLOQ := Self:GetIdBlq()
		D0V->D0V_PRDORI := Self:cPrdOri
		D0V->D0V_PRODUT := Self:cProduto
		D0V->D0V_LOTECT := Self:cLoteCtl
		D0V->D0V_NUMLOT := Self:cNumLote
		D0V->D0V_QTDORI := Self:nQtdBlq
		D0V->D0V_QTDBLQ := Self:nQtdBlq
		D0V->D0V_DTVALD := Self:GetDtValid()
		D0V->D0V_LOCAL  := Self:cArmazem
		D0V->D0V_ENDER  := Self:cEnder
		D0V->D0V_IDUNIT := Self:cIdUnit
		D0V->(MsUnLock())
		// Grava recno
		Self:nRecno := D0V->(Recno())
	Else
		RecLock("D0V", .F.)
		D0V->D0V_QTDORI += Self:nQtdOri
		D0V->D0V_QTDBLQ += Self:nQtdBlq
		D0V->(MsUnLock())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------
/*/{Protheus.doc} AssignD0V
Processa gravação da D0V e tabelas associadas
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD AssignD0V() CLASS WMSDTCBloqueioSaldoItens
Local lRet      := .T.
Local cAliasD0S := Nil
Local cAliasDCR := Nil
	// Informações do endereço
	Self:cArmazem := Self:oMovServ:oMovEndDes:GetArmazem()
	Self:cEnder   := Self:oMovServ:oMovEndDes:GetEnder()
	Self:cIdUnit  := Self:oMovServ:GetUniDes()
	Self:dDtValid := Self:oMovServ:oMovPrdLot:GetDtValid()
	//Grava D0V (Itens do Bloqueio) e quantidade bloqueada D14
	//Caso seja um movimento unitizado grava D0V para todos os produtos do unitizador
	If Self:oMovServ:IsMovUnit()
		 If lRet
			cAliasD0S := GetNextAlias()
			BeginSql Alias cAliasD0S
				SELECT D0S.D0S_IDD0Q,
						D0S.D0S_QUANT,
						D0S.D0S_PRDORI,
						D0S.D0S_CODPRO,
						D0S.D0S_LOTECT,
						D0S.D0S_NUMLOT,
						D0S.D0S_QUANT,
						SB8.B8_DTVALID
				FROM %Table:D0S% D0S
				INNER JOIN %Table:D0Q% D0Q
				ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
				AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
				AND D0Q.%NotDel%
				LEFT JOIN %Table:SB8% SB8
				ON SB8.B8_FILIAL  = %xFilial:SB8%
				AND SB8.B8_NUMLOTE = D0S.D0S_NUMLOT
				AND SB8.B8_LOTECTL = D0S.D0S_LOTECT
				AND SB8.B8_PRODUTO = D0S.D0S_CODPRO
				AND SB8.B8_LOCAL = D0Q.D0Q_LOCAL
				AND SB8.%NotDel%
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:Self:oMovServ:GetIdUnit()%
				AND D0S.%NotDel%
			EndSql
			TcSetField(cAliasD0S,'B8_DTVALID','D')
			Do While (cAliasD0S)->(!Eof()) .And. lRet
				//Busca o documento de bloqueio (D0U) referente ao ID da demanda (D0Q)
				Self:oBlqSaldo:ClearData()
				Self:oBlqSaldo:SetIdDCF((cAliasD0S)->D0S_IDD0Q)
				If Self:oBlqSaldo:LoadData(2)
					Self:SetIdUnit(Self:oMovServ:GetIdUnit())
					Self:SetPrdOri((cAliasD0S)->D0S_PRDORI)
					Self:SetProduto((cAliasD0S)->D0S_CODPRO)
					Self:SetLoteCtl((cAliasD0S)->D0S_LOTECT)
					Self:SetNumLote((cAliasD0S)->D0S_NUMLOT)
					Self:SetQtdOri((cAliasD0S)->D0S_QUANT)
					Self:SetQtdBlq((cAliasD0S)->D0S_QUANT)
					Self:SetDtValid((cAliasD0S)->B8_DTVALID)
					//Atuliza D0V
					lRet := Self:RecordD0V()
					//Atualiza D14
					If lRet
						lRet := Self:GerarBloqueioEstoque()
					EndIf
				Else
					lRet := .F.
					Self:cErro := Self:oBlqSaldo:GetErro()
				EndIf
				(cAliasD0S)->(DbSkip())
			EndDo
		EndIf
	Else
		cAliasDCR := GetNextAlias()
		BeginSql Alias cAliasDCR
			SELECT DCR.DCR_IDDCF,
					DCR.DCR_QUANT
			FROM %Table:DCR% DCR
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDMOV = %Exp:Self:oMovServ:GetIdMovto()%
			AND DCR.DCR_IDOPER = %Exp:Self:oMovServ:GetIdOpera()%
			AND DCR.DCR_IDORI = %Exp:Self:oMovServ:oOrdServ:GetIdDCF()%
			AND DCR.%NotDel%
		EndSql
		Do While (cAliasDCR)->(!Eof()) .And. lRet
			//Informações do produto
			Self:SetPrdOri(Self:oMovServ:oMovPrdLot:GetPrdOri())
			Self:SetProduto(Self:oMovServ:oMovPrdLot:GetProduto())
			Self:SetLoteCtl(Self:oMovServ:oMovPrdLot:GetLoteCtl())
			Self:SetNumLote(Self:oMovServ:oMovPrdLot:GetNumLote())
			//Carrega capa do bloqueio de saldo (D0U)
			Self:oBlqSaldo:ClearData()
			Self:oBlqSaldo:SetIdDCF((cAliasDCR)->DCR_IDDCF)
			If Self:oBlqSaldo:LoadData(2)
				Self:SetQtdOri((cAliasDCR)->DCR_QUANT)
				Self:SetQtdBlq((cAliasDCR)->DCR_QUANT)
				//Atuliza D0V
				lRet := Self:RecordD0V()
			Else
				lRet := .F.
				Self:cErro := Self:oBlqSaldo:GetErro()
			EndIf
			(cAliasDCR)->(DbSkip())
		EndDo
		(cAliasDCR)->(DbCloseArea())
		//Atualiza D14
		If lRet
			Self:SetQtdOri(Self:oMovServ:GetQtdMov())
			Self:SetQtdBlq(Self:oMovServ:GetQtdMov())
			lRet := Self:GerarBloqueioEstoque()
		EndIf
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} AssignSDD
Gera bloqueio de saldo ao executar ordem de serviço
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD AssignSDD() CLASS WMSDTCBloqueioSaldoItens
Local lRet       := .T.
Local oSaldoADis := WMSDTCSaldoADistribuir():New()
Local cAliasQry  := Nil
Local nCont      := 1
	If Len(Self:oOrdServ:aRecDCF) == 0	
		AAdd(Self:oOrdServ:aRecDCF ,{Self:oOrdServ:GetRecno(),.T.})
	EndIf
	For nCont := 1 to Len(Self:oOrdServ:aRecDCF)
		Self:oOrdServ:GoToDCF(Self:oOrdServ:aRecDCF[nCont][1])
		Self:cArmazem := Self:oOrdServ:oOrdEndDes:GetArmazem()
		//Grava uma D0U para cada IDDCF ou IDD0Q
		If !Empty(Self:oOrdServ:GetIdUnit())
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D0Q.D0Q_ID,
						D0Q.D0Q_DOCTO,
						D0Q.D0Q_QUANT,
						D0Q.D0Q_CODPRO,
						D0Q.D0Q_LOTECT,
						D0Q.D0Q_NUMLOT,
						SB8.B8_DTVALID
				FROM %Table:D0S% D0S
				INNER JOIN %Table:D0Q% D0Q
				ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
				AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
				AND D0Q.%NotDel%
				LEFT JOIN %Table:SB8% SB8
				ON SB8.B8_FILIAL = %xFilial:SB8%
				AND SB8.B8_NUMLOTE = D0S.D0S_NUMLOT
				AND SB8.B8_LOTECTL = D0S.D0S_LOTECT
				AND SB8.B8_PRODUTO = D0S.D0S_CODPRO
				AND SB8.B8_LOCAL = D0Q.D0Q_LOCAL
				AND SB8.%NotDel%
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:Self:oOrdServ:GetIdUnit()%
				AND D0S.%NotDel%
				AND NOT EXISTS( SELECT 1
								FROM %Table:D0U% D0U
								WHERE D0U.D0U_FILIAL = %xFilial:D0U%
								AND D0U.D0U_IDDCF = D0Q.D0Q_ID
								AND D0U.D0U_DOCTO = D0Q.D0Q_DOCTO
								AND D0U.D0U_ORIGEM = 'D0Q'
								AND D0U.%NotDel% )
				GROUP BY D0Q.D0Q_ID,
							D0Q.D0Q_DOCTO,
							D0Q.D0Q_QUANT,
							D0Q.D0Q_CODPRO,
							D0Q.D0Q_LOTECT,
							D0Q.D0Q_NUMLOT,
							SB8.B8_DTVALID
			EndSql
			TcSetField(cAliasQry,'B8_DTVALID','D')
			//Grava D0U
			Do While (cAliasQry)->(!EoF()) .And. lRet
				//Informções do bloqueio D0U
				Self:oBlqSaldo:ClearData()
				Self:oBlqSaldo:SetTipBlq("2")
				Self:oBlqSaldo:SetMotivo("US")
				Self:oBlqSaldo:SetObserv("Geração automática WMS")
				Self:oBlqSaldo:SetOrigem("D0Q")
				Self:oBlqSaldo:SetIdDCF((cAliasQry)->D0Q_ID)
				Self:oBlqSaldo:SetDocto((cAliasQry)->D0Q_DOCTO)
				If !Self:oBlqSaldo:LoadData(2)
					If !(lRet := Self:oBlqSaldo:RecordD0U())
						Self:cErro := Self:oBlqSaldo:GetErro()
					EndIf
				EndIf
				//Se existir D0G deve apagar para gravar o bloqueio
				oSaldoADis:SetIdDCF((cAliasQry)->D0Q_ID)
				If oSaldoADis:LoadData(3)
					oSaldoADis:DeleteD0G()
				EndIf
				//Grava SDD com base nos itens do unitizador
				Self:nQtdBlq  := (cAliasQry)->D0Q_QUANT
				Self:cPrdOri  := (cAliasQry)->D0Q_CODPRO
				Self:cLoteCtl := (cAliasQry)->D0Q_LOTECT
				Self:cNumLote := (cAliasQry)->D0Q_NUMLOT
				Self:dDtValid := (cAliasQry)->B8_DTVALID
				If (lRet := Self:GerarSDD())
					lRet := Self:GerarEmpenho()
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		Else
			//Grava D0U
			Self:oBlqSaldo:SetTipBlq("2")
			Self:oBlqSaldo:SetMotivo("US")
			Self:oBlqSaldo:SetObserv("Geração automática WMS")
			Self:oBlqSaldo:SetOrigem("DCF")
			Self:oBlqSaldo:SetIdDCF(Self:oOrdServ:GetIdDCF())
			Self:oBlqSaldo:SetDocto(Self:oOrdServ:GetDocto())
			If !(lRet := Self:oBlqSaldo:RecordD0U())
				Self:cErro := Self:oBlqSaldo:GetErro()
			EndIf
			//Se existir D0G deve apagar para gravar o bloqueio	
			oSaldoADis:SetIdDCF(Self:oBlqSaldo:GetIdDCF())
			If oSaldoADis:LoadData(3)
				oSaldoADis:DeleteD0G()
			EndIf
			//Grava SDD com base na DCF
			Self:cPrdOri  := Self:oOrdServ:oProdLote:GetPrdOri()
			Self:cLoteCtl := Self:oOrdServ:oProdLote:GetLoteCtl()
			Self:cNumLote := Self:oOrdServ:oProdLote:GetNumLote()
			Self:dDtValid := Self:oOrdServ:oProdLote:GetDtValid()
			Self:nQtdBlq  := Self:oOrdServ:GetQuant()
			If (lRet := Self:GerarSDD())
				lRet := Self:GerarEmpenho()
			EndIf
		EndIf
	Next nCont
Return lRet
//-----------------------------------------
/*/{Protheus.doc} GerarSDD
Gera SDD
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD GerarSDD() CLASS WMSDTCBloqueioSaldoItens
Local lRet := .T.
Local cDocto := PadR(Self:oBlqSaldo:GetDocto(),TamSx3("DD_DOC")[1])
Local cPrdOri := PadR(Self:cPrdOri,TamSx3("DD_PRODUTO")[1])
Local cArmazem := PadR(Self:cArmazem,TamSx3("DD_LOCAL")[1])
Local cLote := PadR(Self:cLoteCtl,TamSx3("DD_LOTECTL")[1])
Local cNumLote := PadR(Self:cNumLote,TamSx3("DD_NUMLOTE")[1])
	// Converte segunda unidade de medida
	Self:nQtdBlq2 := Self:GetQtdBlq2()

	SDD->(DbSetOrder(2)) //--DD_FILIAL + DD_PRODUTO + DD_LOCAL + DD_LOTECTL + DD_NUMLOTE	
	If SDD->(DbSeek(xFilial('SDD')+cPrdOri+cArmazem+cLote+cNumLote))
		
		While SDD->(!EoF()) .And.;
			SDD->(DD_FILIAL+DD_PRODUTO+DD_LOCAL+DD_LOTECTL+DD_NUMLOTE) == (xFilial('SDD')+cPrdOri+cArmazem+cLote+cNumLote)

			If SDD->DD_SALDO == 0
				RecLock('SDD',.F.)
				SDD->(dbDelete())
				SDD->(MsUnLock())
			EndIf

			SDD->( DbSkip() )
		EndDo

	EndIf

	SDD->(DbSetOrder(1))//DD_FILIAL+DD_DOC+DD_PRODUTO+DD_LOCAL+DD_LOTECTL+DD_NUMLOTE
	If !SDD->(DbSeek(xFilial('SDD')+cDocto+cPrdOri+cArmazem+cLote+cNumLote))
		RecLock("SDD", .T.)
		SDD->DD_FILIAL  := xFilial('SDD')
		SDD->DD_DOC     := cDocto
		SDD->DD_MOTIVO  := Self:oBlqSaldo:GetMotivo()
		SDD->DD_OBSERVA := Self:oBlqSaldo:GetObserv()
		SDD->DD_LOCAL   := Self:cArmazem
		SDD->DD_PRODUTO := cPrdOri
		SDD->DD_LOTECTL := cLote
		SDD->DD_NUMLOTE := cNumLote
		SDD->DD_DTVALID := Self:GetDtValid()
		SDD->DD_QUANT   := Self:nQtdBlq
		SDD->DD_SALDO   := Self:nQtdBlq
		SDD->DD_QTDORIG := Self:nQtdBlq
		SDD->DD_QTSEGUM := Self:nQtdBlq2
		SDD->DD_SALDO2  := Self:nQtdBlq2
		SDD->DD_LOCALIZ := ""
		SDD->(MsUnLock())
	Else
		RecLock("SDD", .F.)
		SDD->DD_QUANT   += Self:nQtdBlq
		SDD->DD_SALDO   += Self:nQtdBlq
		SDD->DD_QTSEGUM += Self:nQtdBlq2
		SDD->DD_SALDO2  += Self:nQtdBlq2
		SDD->(MsUnLock())
	End
Return lRet
//-----------------------------------------
/*/{Protheus.doc} RemoverEmpenho
Remove empenho (SB2, SB8 e SDC)
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD RemoverEmpenho() CLASS WMSDTCBloqueioSaldoItens
Local lRet := .T.
	Self:nQtdLib2 := Self:GetQtdLib2()
	//Grava empenhos SB8 e SB2
	GravaEmp(Self:cPrdOri,; //cProduto
				Self:cArmazem,; //cLocal
				Self:nQtdLib,;  //nQtd
				Self:nQtdLib2,; //nQtd2UM
				Self:cLoteCtl,; //cLoteCtl
				Self:cNumLote,; //cNumLote
				Nil,; //cLocaliza
				Nil,; //cNumSerie
				Nil,; //cOp
				Nil,; //cTrt
				Nil,; //cPedido
				Nil,; //cItem
				"SDD",; //cOrigem
				Nil,; //cOpOrig
				Nil,; //dEntrega
				Nil,; //aTravas
				.T.,; //lEstorno
				.F.,; //lProj
				.T.,; //lEmpSB2
				.F.,; //lGravaSD4
				.T.,; //lConsVenc
				.T.,; //lEmpSB8SBF
				.F.,; //lCriaSDC
				.F.,; //lEncerrOp
				Self:oBlqSaldo:GetIdDCF(),; //cIdDCF
				Nil,; //aSalvCols
				Nil,; //nSG1
				.F.,; //lOpEncer
				Nil,; //cTpOp
				Nil,; //cCAT83
				Nil,; //dDtEmissao
				.F.,; //lGravLote
				Nil)  //aSDC
	//Grava composição do empenho SDC
	lRet := WmsAtuSDC("SDD",; //cOrigem
						Nil,; //cOp
						Nil,; //cTrt
						Nil,; //cPedido
						Nil,; //cItem
						Nil,; //cSeqSC9
						Self:cPrdOri,;  //cProduto
						Self:cLoteCtl,; //cLoteCtl
						Self:cNumLote,; //cNumLote
						"",; //cNumSerie
						Self:nQtdLib,; //nQuant
						Self:nQtdLib2,; //nQuant2UM
						Self:cArmazem,; //cLocal
						"",; //cEndereco
						Self:oBlqSaldo:GetIdDCF(),; //cIdDCF
						1,; //nIndex
						.T.) //lEstorno
	If !lRet
		Self:cErro := STR0002 //"Erro na gravação da composição do empenho (SDC)."
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} GerarEmpenho
Gera empenho (SB2, SB8 e SDC)
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD GerarEmpenho() CLASS WMSDTCBloqueioSaldoItens
Local lRet := .T.
	// Converte seugnda unidade de medida
	Self:nQtdBlq2 := Self:GetQtdBlq2()
	//Grava empenhos SB8 e SB2
	GravaEmp(Self:cPrdOri,; //cProduto
				Self:cArmazem,; //cLocal
				Self:nQtdBlq,;  //nQtd
				Self:nQtdBlq2,; //nQtd2UM
				Self:cLoteCtl,; //cLoteCtl
				Self:cNumLote,; //cNumLote
				Nil,; //cLocaliza
				Nil,; //cNumSerie
				Nil,; //cOp
				Nil,; //cTrt
				Nil,; //cPedido
				Nil,; //cItem
				"SDD",; //cOrigem
				Nil,; //cOpOrig
				Nil,; //dEntrega
				Nil,; //aTravas
				.F.,; //lEstorno
				.F.,; //lProj
				.T.,; //lEmpSB2
				.F.,; //lGravaSD4
				.T.,; //lConsVenc
				.T.,; //lEmpSB8SBF
				.F.,; //lCriaSDC
				.F.,; //lEncerrOp
				Self:oBlqSaldo:GetIdDCF(),; //cIdDCF
				Nil,; //aSalvCols
				Nil,; //nSG1
				.F.,; //lOpEncer
				Nil,; //cTpOp
				Nil,; //cCAT83
				Nil,; //dDtEmissao
				.F.,; //lGravLote
				Nil)  //aSDC
	//Grava composição do empenho SDC
	lRet := WmsAtuSDC("SDD",; //cOrigem
						Nil,; //cOp
						Nil,; //cTrt
						Nil,; //cPedido
						Nil,; //cItem
						Nil,; //cSeqSC9
						Self:cPrdOri,;  //cProduto
						Self:cLoteCtl,; //cLoteCtl
						Self:cNumLote,; //cNumLote
						"",; //cNumSerie
						Self:nQtdBlq,; //nQuant
						Self:nQtdBlq2,; //nQuant2UM
						Self:cArmazem,; //cLocal
						"",; //cEndereco
						Self:oBlqSaldo:GetIdDCF(),; //cIdDCF
						1,; //nIndex
						.F.) //lEstorno
	If !lRet
		Self:cErro := STR0002 //"Erro na gravação da composição do empenho (SDC)."
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} GerarBloqueioEstoque
Gera bloqueio de estoque D14
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD GerarBloqueioEstoque() CLASS WMSDTCBloqueioSaldoItens
Local lRet      := .T.
Local oEstEnder := WMSDTCEstoqueEndereco():New()
	//Informações do endereço
	oEstEnder:oEndereco:SetArmazem(Self:cArmazem)
	oEstEnder:oEndereco:SetEnder(Self:cEnder)
	oEstEnder:oEndereco:LoadData()
	If !(oEstEnder:oEndereco:GetTipoEst() == 2) .And. !(oEstEnder:oEndereco:GetTipoEst() == 7)
		oEstEnder:SetIdUnit(Self:cIdUnit)
	EndIf
	oEstEnder:oProdLote:SetDtValid(Self:dDtValid)
	// Informações do produto
	oEstEnder:oProdLote:SetPrdOri(Self:cPrdOri)
	oEstEnder:oProdLote:SetProduto(Self:cProduto)
	oEstEnder:oProdLote:SetLoteCtl(Self:cLoteCtl)
	oEstEnder:oProdLote:SetNumLote(Self:cNumLote)
	oEstEnder:oProdLote:SetNumSer("")
	oEstEnder:oProdLote:LoadData()
	oEstEnder:SetQuant(Self:nQtdBlq)
	If !(lRet := oEstEnder:UpdSaldo("499",.F./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.T./*lBloqueio*/,.F./*lEmpPrev*/,.F./*lMovEstEnd*/))
		Self:cErro := oEstEnder:GetErro()
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} RemoverBloqueioEstoque
Remove bloqueio de estoque D14
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD RemoverBloqueioEstoque() CLASS WMSDTCBloqueioSaldoItens
Local lRet      := .T.
Local oEstEnder := WMSDTCEstoqueEndereco():New()
	//Informações do endereço
	oEstEnder:oEndereco:SetArmazem(Self:cArmazem)
	oEstEnder:oEndereco:SetEnder(Self:cEnder)
	oEstEnder:oEndereco:LoadData()
	If !(oEstEnder:oEndereco:GetTipoEst() == 2) .And. !(oEstEnder:oEndereco:GetTipoEst() == 7)
		oEstEnder:SetIdUnit(Self:cIdUnit)
	EndIf
	oEstEnder:oProdLote:SetDtValid(Self:dDtValid)
	// Informações do produto
	oEstEnder:oProdLote:SetPrdOri(Self:cPrdOri)
	oEstEnder:oProdLote:SetProduto(Self:cProduto)
	oEstEnder:oProdLote:SetLoteCtl(Self:cLoteCtl)
	oEstEnder:oProdLote:SetNumLote(Self:cNumLote)
	oEstEnder:oProdLote:SetNumSer("")
	oEstEnder:oProdLote:LoadData()
	oEstEnder:SetQuant(Self:nQtdLib)
	If !(lRet := oEstEnder:UpdSaldo("999",.F./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.T./*lBloqueio*/,.F./*lEmpPrev*/,.F./*lMovEstEnd*/))
		Self:cErro := oEstEnder:GetErro()
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} DeleteD0V
Apaga D0V
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD DeleteD0V() CLASS WMSDTCBloqueioSaldoItens
Local lRet       := .T.
	If !Empty(Self:GetRecno())
		D0V->(dbGoTo(Self:GetRecno()))
		RecLock('D0V',.F.)
		D0V->(dbDelete())
		D0V->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados (D0V)!
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} RevBlqSld
Remove bloqueio de saldo, quando estorna a ordem de serviço
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD RevBlqSld()  CLASS WMSDTCBloqueioSaldoItens
Local lRet      := .T.
Local cAliasD0S := Nil
Local cAliasD0Q := Nil
Local cAliasD0V := Nil
	//Informações gerais DCF
	Self:cArmazem := Self:oOrdServ:oOrdEndDes:GetArmazem()
	If !Empty(Self:oOrdServ:GetIdUnit())
		//Faz ajustes necessários para o estorno
		cAliasD0S := GetNextAlias()
		BeginSql Alias cAliasD0S
			SELECT D0S.D0S_IDD0Q,
					D0S.D0S_QUANT,
					D0S.D0S_PRDORI,
					D0S.D0S_CODPRO,
					D0S.D0S_LOTECT,
					D0S.D0S_NUMLOT,
					D0S.D0S_ENDREC
			FROM %Table:D0S% D0S
			WHERE D0S.D0S_FILIAL = %xFilial:D0S%
			AND D0S.D0S_IDUNIT = %Exp:Self:oOrdServ:GetIdUnit()%
			AND D0S.%NotDel%
		EndSql
		Do While (cAliasD0S)->(!EoF())  .And. lRet
			//Carrega documento (D0U) referente à demanda (D0Q)
			Self:oBlqSaldo:ClearData()
			Self:oBlqSaldo:SetIdDCF((cAliasD0S)->D0S_IDD0Q)
			If Self:oBlqSaldo:LoadData(2)
				Self:cIdUnit  := Self:oOrdServ:GetIdUnit()
				Self:cPrdOri  := (cAliasD0S)->D0S_PRDORI
				Self:cProduto := (cAliasD0S)->D0S_CODPRO
				Self:cLoteCtl := (cAliasD0S)->D0S_LOTECT
				Self:cNumLote := (cAliasD0S)->D0S_NUMLOT
				Self:nQtdLib  := (cAliasD0S)->D0S_QUANT
				//Apaga D0V  e D14 para O.S. já movimentadas
				If Self:LoadData(1)
					//Remove quantidade bloqueada D14
					If (lRet := Self:RemoverBloqueioEstoque())
						lRet := Self:DeleteD0V()
					EndIf
				EndIf
			EndIf
			//Verifica se não existe mais bloqueios de estoque relacionados à demanda e desfaz empenhos. Busca por D0Q para pegar toda a quantidade bloqueada.
			If lRet
				cAliasD0Q := GetNextAlias()
				BeginSql Alias cAliasD0Q
					SELECT D0Q.D0Q_ID,
							D0Q.D0Q_QUANT,
							D0Q.D0Q_CODPRO,
							D0Q.D0Q_LOTECT,
							D0Q.D0Q_NUMLOT
					FROM %Table:D0Q% D0Q
					INNER JOIN %Table:D0U% D0U
					ON D0U.D0U_FILIAL = %xFilial:D0U%
					AND D0U.D0U_IDDCF = D0Q.D0Q_ID
					AND D0U.D0U_ORIGEM = 'D0Q'
					AND D0U.%NotDel%
					WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
					AND D0Q.D0Q_ID = %Exp:(cAliasD0S)->D0S_IDD0Q%
					//Quando tratar-se de um produto componente, verifica se a demanda não está relacionada à outras ordens de serviços já executadas para só então estornar o produto pai
					AND NOT EXISTS (SELECT D0S_IDUNIT
									FROM %Table:D0S% D0S
									INNER JOIN %Table:DCF% DCF
									ON DCF.DCF_FILIAL = %xFilial:DCF%
									AND DCF.DCF_UNITIZ = D0S.D0S_IDUNIT
									AND DCF.DCF_ORIGEM = 'D0R'
									AND DCF.DCF_STSERV = '3'
									AND DCF.DCF_ID <> %Exp:Self:oOrdServ:GetIdDCF()%
									AND DCF.%NotDel%
									WHERE D0S.D0S_FILIAL = %xFilial:D0S%
									AND D0S.D0S_IDD0Q = D0Q.D0Q_ID
									AND D0S.D0S_IDUNIT <> %Exp:Self:oOrdServ:GetIdUnit()%
									AND D0S.%NotDel% )
					AND D0Q.%NotDel%
				EndSql
				Do While (cAliasD0Q)->(!EoF())
					Self:cPrdOri  := (cAliasD0Q)->D0Q_CODPRO
					Self:cProduto := (cAliasD0Q)->D0Q_CODPRO
					Self:cLoteCtl := (cAliasD0Q)->D0Q_LOTECT
					Self:cNumLote := (cAliasD0Q)->D0Q_NUMLOT
					Self:cIdUnit  := Self:oOrdServ:GetIdUnit()
					Self:nQtdBlq  := (cAliasD0Q)->D0Q_QUANT //Estorno de produto com estruturas será ajustado.
					Self:nQtdLib  := Self:nQtdBlq
					//Remove empenhos SB2, SB8 e SDC
					If lRet
						Self:RemoverEmpenho()
					EndIf
					//Apaga ou remove quantidade bloqueada SDD
					If lRet
						lRet := Self:RemoverSDD()
					EndIf
					//Apaga D0U
					If lRet
						Self:oBlqSaldo:DeleteD0U()
					EndIf
					(cAliasD0Q)->(dbSkip())
				EndDo
				(cAliasD0Q)->(dbCloseArea())
			EndIf
			(cAliasD0S)->(DbSkip())
		EndDo
		(cAliasD0S)->(DbCloseArea())
	Else
		//Verifica se existe bloqueio de saldo para a DCF
		Self:oBlqSaldo:SetIDDCF(Self:oOrdServ:GetIdDCF())
		If Self:oBlqSaldo:LoadData(2)
			cAliasD0V := GetNextAlias()
			BeginSql Alias cAliasD0V
				SELECT D0V.R_E_C_N_O_ RECNOD0V
				FROM %Table:D0V% D0V
				WHERE D0V.D0V_FILIAL = %xFilial:D0V%
				AND D0V.D0V_IDBLOQ = %Exp:Self:GetIdBlq()%
				AND D0V.%NotDel%
			EndSql
			Do While (cAliasD0V)->(!EoF())
				//Apaga D0V  e D14 para O.S. já movimentadas
				If Self:GoToD0V((cAliasD0V)->RECNOD0V)
					Self:nQtdLib := Self:nQtdBlq
					Self:nQtdBlqT += Self:nQtdBlq
					//Remove quantidade bloqueada D14
					If (lRet := Self:RemoverBloqueioEstoque())
						//Apaga D0V
						lRet := Self:DeleteD0V()
					EndIf
				EndIf
				(cAliasD0V)->(DbSkip())
			EndDo
			(cAliasD0V)->(DbCloseArea())
			
			//Informações do produto
			Self:cPrdOri  := Self:oOrdServ:oProdLote:GetPrdOri()
			Self:cLoteCtl := Self:oOrdServ:oProdLote:GetLoteCtl()
			Self:cNumLote := Self:oOrdServ:oProdLote:GetNumLote()
			Self:nQtdBlq  := Self:nQtdBlqT
			Self:nQtdLib  := Self:nQtdBlq
			//Remove empenhos SB2, SB8 e SDC
			If lRet
				Self:RemoverEmpenho()
			EndIf
			//Apaga ou remove quantidade bloqueada SDD
			If lRet
				lRet := Self:RemoverSDD()
			EndIf
			//Apaga D0U
			If lRet
				Self:oBlqSaldo:DeleteD0U()
			EndIf
		EndIf
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} RemoverSDD
Remove SDD
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD RemoverSDD() CLASS WMSDTCBloqueioSaldoItens
Local lRet    := .T.
Local nSaldo  := 0
Local nSaldo2 := 0
Local cDocto  := PadR(Self:oBlqSaldo:GetDocto(),TamSx3("DD_DOC")[1])
Local cPrdOri := PadR(Self:cPrdOri,TamSx3("DD_PRODUTO")[1])
Local cArmazem:= PadR(Self:cArmazem,TamSx3("DD_LOCAL")[1])
Local cLote    := PadR(Self:cLoteCtl,TamSx3("DD_LOTECTL")[1])
Local cNumLote := PadR(Self:cNumLote,TamSx3("DD_NUMLOTE")[1])
	SDD->(DbSetOrder(1)) //DD_FILIAL+DD_DOC+DD_PRODUTO+DD_LOCAL+DD_LOTECTL+DD_NUMLOTE
	If SDD->(DbSeek(xFilial('SDD')+cDocto+cPrdOri+cArmazem+cLote+cNumLote))
		nSaldo  := SDD->DD_SALDO - Self:nQtdLib
		nSaldo2 := ConvUm(Self:cPrdOri,nSaldo,0,2)

		If nSaldo == 0
			RecLock('SDD',.F.)
			SDD->(dbDelete())
			SDD->(MsUnLock())
		Else
			RecLock('SDD',.F.)
			SDD->DD_SALDO  := nSaldo
			SDD->DD_QUANT  := nSaldo
			SDD->DD_SALDO2 := nSaldo2
			SDD->DD_QTSEGUM:= nSaldo2
			SDD->(MsUnLock())
		EndIf
	Else
		Self:cErro := STR0004 //Registro de bloqueio de saldo (SDD) não encontrado.
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} UpdateD0V
Atualiza D0V
@author Squad WMS
@version 1.0
/*/
//-----------------------------------------
METHOD UpdateD0V(lMsUnLock) CLASS WMSDTCBloqueioSaldoItens
Local lRet := .T.

Default lMsUnLock := .T.

	If !Empty(Self:GetRecno())
		D0V->(dbGoTo( Self:GetRecno() ))
		RecLock('D0V', .F.)
		D0V->D0V_QTDBLQ := Self:nQtdBlq
		D0V->(dbCommit())
		If lMsUnLock
			D0V->(MsUnLock())
		EndIf
	Else
		lRet := .F.
		Self:cErro := "Recno inválido!" + " (" + GetClassName(Self) + ":UpdateD0V()(D0V))" // Recno inválido!
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} AtualizarD0V
Apaga D0V quando a quantidade bloqueada zerar ou então ajusta a quantidade bloquada.
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-----------------------------------------
METHOD AtualizarD0V() CLASS WMSDTCBloqueioSaldoItens
Return Iif(Self:nQtdBlq == 0,Self:DeleteD0V(),Self:UpdateD0V())
//-----------------------------------------
/*/{Protheus.doc} ExisteD0V
Verifica se existem D0V para o id de bloqueio.
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-----------------------------------------
METHOD ExisteD0V() CLASS WMSDTCBloqueioSaldoItens
Local lRet := .F.
Local cAliasD0V := GetNextAlias()
	BeginSql Alias cAliasD0V
		SELECT 1
		  FROM %Table:D0V% D0V
		 WHERE D0V.D0V_FILIAL = %xFilial:D0V%
		   AND D0V.D0V_IDBLOQ = %Exp:Self:GetIdBlq()%
		   AND D0V.%NotDel%
	EndSql
	If (cAliasD0V)->(!EoF())
		lRet := .T.
	EndIf
	(cAliasD0V)->(DbCloseArea())
Return lRet
//-----------------------------------------
/*/{Protheus.doc} GerarD0U
Apaga registro na D0U caso não existam mais D0V associadas.
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-----------------------------------------
METHOD ApagarD0U() CLASS WMSDTCBloqueioSaldoItens
Return Iif(Self:ExisteD0V(),.T.,Self:oBlqSaldo:DeleteD0U())
//-----------------------------------------
/*/{Protheus.doc} GerarD0U
Gera registro na D0U.
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-----------------------------------------
METHOD GerarD0U() CLASS WMSDTCBloqueioSaldoItens
Local lRet := .T.
	If !Self:oBlqSaldo:LoadData(3)
		Self:oBlqSaldo:RecordD0U()
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} RealizarBloqueio
Remove o bloqueio de estoque por endereço.
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-----------------------------------------
METHOD RemoverBloqueio() CLASS WMSDTCBloqueioSaldoItens
Local lRet := .T.

	//Remove bloqueio de saldo do endereço
	If lRet
		lRet := Self:RemoverBloqueioEstoque()
	EndIf

	//Remove empenhos (SB2,SB8,SDC)
	If lRet
		Ret := Self:RemoverEmpenho()
	EndIf

	//Remove quantidade bloqueada na SDD
	If lRet
		lRet := Self:RemoverSDD()
	EndIf
	
	//Define quantidade bloqueada que será utilizada para atualizar D0V e D0U
	Self:nQtdBlq -= Self:nQtdLib

	//Reduz ou remove D0V
	If lRet
		lRet := Self:AtualizarD0V()
	EndIf

	//Remove D0U quando quantidade bloqueada zerar e não existirem D0V associadas
	If lRet
		lRet := Self:ApagarD0U()
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} RealizarBloqueio
Realiza o bloqueio de estoque por endereço.
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-----------------------------------------
METHOD RealizarBloqueio() CLASS WMSDTCBloqueioSaldoItens
Local lRet := .T.

	//Gera bloqueio de saldo do endereço
	If lRet
		lRet := Self:GerarBloqueioEstoque()
	EndIf

	//Gera empenhos (SB2,SB8,SDC)
	If lRet
		Ret := Self:GerarEmpenho()
	EndIf

	//Gera quantidade bloqueada na SDD
	If lRet
		lRet := Self:GerarSDD()
	EndIf
	
	//Gera D0V
	If lRet
		lRet := Self:RecordD0V()
	EndIf

	//Gera D0U
	If lRet
		lRet := Self:GerarD0U()
	EndIf
Return lRet
