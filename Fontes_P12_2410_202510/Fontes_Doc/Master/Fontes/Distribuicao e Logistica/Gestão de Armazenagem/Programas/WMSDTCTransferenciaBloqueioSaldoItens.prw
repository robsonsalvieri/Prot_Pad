#Include "Totvs.ch"
#Include "WMSDTCTransferenciaBloqueioSaldoItens.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0067
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0068()
Return Nil
//--------------------------------------
/*/{Protheus.doc} WMSDTCTransferenciaBloqueioSaldoItens
Classe Transferência (Itens) x Bloqueio de Saldo (D19)
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//--------------------------------------
CLASS WMSDTCTransferenciaBloqueioSaldoItens FROM LongNameClass
	DATA cIdDCF
	DATA cIdBlq
	DATA cDocto
	DATA cPrdOri
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA cLocal
	DATA cEnder
	DATA cIdUnit
	DATA cErro
	DATA nQtdBlq
	DATA nQtdLib
	DATA dDtValid
	DATA nRecno
	DATA oTransfBlq

	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetIdBlq(cIdBlq)
	METHOD SetDocto(cDocto)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetLocal(cLocal)
	METHOD SetEnder(cEnder)
	METHOD SetIdUnit(cIdUnit)
	METHOD SetQtdLib(nQtdLib)
	METHOD SetDtValid(dDtValid)
	METHOD ExisteD19()
	METHOD RecordD19()
	METHOD DeleteD19()
	METHOD RemoverBloqueioParaTransferir()
	METHOD RefazerBloqueio()
	METHOD GerarBloqueioNoEnderecoDestino(cIdDCF,cArmDes,cEndDes)
	METHOD GetErro()
	METHOD GetDtValid()
	METHOD Destroy()
ENDCLASS

METHOD New() CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cErro := ""
	Self:oTransfBlq := WMSDTCTransferenciaBloqueioSaldo():New()
Return

METHOD Destroy() CLASS WMSDTCTransferenciaBloqueioSaldoItens
	//Mantido para compatibilidade
Return 

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cIdDCF := cIdDCF
Return 

METHOD SetIdBlq(cIdBlq) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cIdBlq := cIdBlq
Return 

METHOD SetDocto(cDocto) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cDocto := cDocto
Return

METHOD SetPrdOri(cPrdOri) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cPrdOri := cPrdOri
Return 

METHOD SetProduto(cProduto) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cProduto := cProduto
Return 

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cLoteCtl := cLoteCtl
Return 

METHOD SetNumLote(cNumLote) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cNumLote := cNumLote
Return

METHOD SetLocal(cLocal) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cLocal := cLocal
Return

METHOD SetEnder(cEnder) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cEnder := cEnder
Return

METHOD SetIdUnit(cIdUnit) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:cIdUnit := cIdUnit
Return

METHOD SetQtdLib(nQtdLib) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:nQtdLib := nQtdLib
Return

METHOD SetDtValid(dDtValid) CLASS WMSDTCTransferenciaBloqueioSaldoItens
	Self:dDtValid := dDtValid
Return

METHOD GetErro() CLASS WMSDTCTransferenciaBloqueioSaldoItens
Return Self:cErro

METHOD GetDtValid() CLASS WMSDTCTransferenciaBloqueioSaldoItens
Return IiF(Empty(Self:dDtValid),CToD(""),Self:dDtValid)

METHOD LoadData(nIndex) CLASS WMSDTCTransferenciaBloqueioSaldoItens
Local lRet      := .T.
Local cAliasD19 := ""
Local cWhere    := ""
Default nIndex  := 1
	Do Case 
		Case nIndex == 1 //D19_FILIAL+D19_IDDCF+D19_IDBLOQ+D19_PRDORI+D19_PRODUT+D19_LOTECT+D19_NUMLOT+D19_LOCAL+D19_ENDER+D19_IDUNIT
			If Empty(Self:cIdDCF) .Or.;
			   Empty(Self:cIdBlq)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD19 := GetNextAlias()
		Do Case
			Case nIndex == 1
				cWhere := "%"
				If !Empty(Self:cPrdOri)
					cWhere += " AND D19.D19_PRDORI  = '"+Self:cPrdOri+"'"
				EndIf
			   	If !Empty(Self:cProduto)
					cWhere += " AND D19.D19_PRODUT  = '"+Self:cProduto+"'"
				EndIf
				If !Empty(Self:cLoteCtl)
					cWhere += " AND D19.D19_LOTECT = '"+Self:cLoteCtl+"'"
				EndIf
				If !Empty(Self:cNumLote)
					cWhere += " AND D19.D19_NUMLOT = '"+Self:cNumLote+"'"
				EndIf
			   	If !Empty(Self:cLocal)
					cWhere += " AND D19.D19_LOCAL  = '"+Self:cLocal+"'"
				EndIf
			   	If !Empty(Self:cEnder)
					cWhere += " AND D19.D19_ENDER  = '"+Self:cEnder+"'"
				EndIf
				If !Empty(Self:cIdUnit)
					cWhere += " AND D19.D19_IDUNIT = '"+Self:cIdUnit+"'"
				EndIf
				cWhere += "%"

				BeginSql Alias cAliasD19
					SELECT D19.D19_IDDCF,
						   D19.D19_IDBLOQ,
						   D19.D19_PRDORI,
						   D19.D19_PRODUT,
						   D19.D19_LOTECT,
						   D19.D19_NUMLOT,
						   D19.D19_DTVALD,
						   D19.D19_LOCAL,
						   D19.D19_ENDER,
						   D19.D19_IDUNIT,
						   D19.D19_QTDBLQ
					FROM %Table:D19% D19
				   WHERE D19.D19_FILIAL = %xFilial:D19%
					 AND D19.D19_IDDCF  = %Exp:Self:cIdDCF%
					 AND D19.D19_IDBLOQ = %Exp:Self:cIdBlq%
					 AND D19.%NotDel%
					 %Exp:cWhere%
				EndSql
		EndCase
		TcSetField(cAliasD19,'D19_DTVALD','D')
		If (lRet := (cAliasD19)->(!Eof()))
			Self:cIdDCF  := (cAliasD19)->D19_IDDCF
			Self:cIdBlq  := (cAliasD19)->D19_IDBLOQ
			Self:cPrdOri := (cAliasD19)->D19_PRDORI
			Self:cProduto:= (cAliasD19)->D19_PRODUT
			Self:cLoteCtl:= (cAliasD19)->D19_LOTECT
			Self:cNumLote:= (cAliasD19)->D19_NUMLOT
			Self:cLocal  := (cAliasD19)->D19_LOCAL
			Self:cEnder  := (cAliasD19)->D19_ENDER
			Self:cIdUnit := (cAliasD19)->D19_IDUNIT
			Self:nQtdBlq := (cAliasD19)->D19_QTDBLQ
			Self:dDtValid:= (cAliasD19)->D19_DTVALD
		EndIf
		(cAliasD19)->(dbCloseArea())
	EndIf
Return lRet

METHOD ExisteD19() CLASS WMSDTCTransferenciaBloqueioSaldoItens
Return Self:LoadData(1)

METHOD DeleteD19() CLASS WMSDTCTransferenciaBloqueioSaldoItens
Local lRet       := .T.
	If !Empty(Self:nRecno)
		D19->(dbGoTo(Self:nRecno))
		RecLock('D19',.F.)
		D19->(dbDelete())
		D19->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Dados não encontrados (D19)!
	EndIf
Return lRet

METHOD RecordD19() CLASS WMSDTCTransferenciaBloqueioSaldoItens
Local lRet := .T.
	If !Self:ExisteD19()
		RecLock("D19",.T.)
		D19->D19_FILIAL := xFilial("D19")
		D19->D19_IDDCF  := Self:cIdDCF
		D19->D19_IDBLOQ := Self:cIdBlq
		D19->D19_PRDORI := Self:cPrdOri
		D19->D19_PRODUT := Self:cProduto
		D19->D19_LOTECT := Self:cLoteCtl
		D19->D19_NUMLOT := Self:cNumLote
		D19->D19_DTVALD := Self:GetDtValid()
		D19->D19_LOCAL  := Self:cLocal
		D19->D19_ENDER  := Self:cEnder
		D19->D19_IDUNIT := Self:cIdUnit
		D19->D19_QTDBLQ := Self:nQtdLib
		D19->(MsUnLock())
		Self:nRecno := D19->(Recno())
	Else
		RecLock("D19",.F.)
		D19->D19_QTDBLQ += Self:nQtdLib
		D19->(MsUnLock())
	EndIf
Return lRet
//--------------------------------------
/*/{Protheus.doc} RemoverBloqueioParaTransferir
Remove o bloqueio de saldo para permitir a transferência entre endereços.
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//--------------------------------------
METHOD RemoverBloqueioParaTransferir() CLASS WMSDTCTransferenciaBloqueioSaldoItens
Local lRet := .T.
Local oBlqSaldoItens := WMSDTCBloqueioSaldoItens():New()
Local oBlqSaldo := WMSDTCBloqueioSaldo():New()

	oBlqSaldo:SetIdBlq(Self:cIdBlq)
	oBlqSaldo:LoadData(3)
	Self:oTransfBlq:SetIdDCF(Self:cIdDCF)
	Self:oTransfBlq:SetDocto(Self:cDocto)
	Self:oTransfBlq:SetIdBlq(Self:cIdBlq)
	Self:oTransfBlq:SetIdDCFBlq(oBlqSaldo:GetIdDCF())
	Self:oTransfBlq:SetDoctoBlq(oBlqSaldo:GetDocto())
	Self:oTransfBlq:SetOrigem(oBlqSaldo:GetOrigem())
	Self:oTransfBlq:SetTipBlq(oBlqSaldo:GetTipBlq())
	Self:oTransfBlq:SetMotivo(oBlqSaldo:GetMotivo())
	Self:oTransfBlq:SetObserv(oBlqSaldo:GetObserv())
	//Grava capa do bloqueio
	If !(lRet := Self:oTransfBlq:RecordD18())
		Self:cErro := Self:oTransfBlq:GetErro()
	EndIf
	If lRet
	//Grava itens do bloqueio
		lRet := Self:RecordD19()
	EndIf
	//Remove bloqueio de saldo
	oBlqSaldoItens:SetIdBlq(Self:cIdBlq)
	oBlqSaldoItens:SetPrdOri(Self:cPrdOri)
	oBlqSaldoItens:SetProduto(Self:cProduto)
	oBlqSaldoItens:SetLoteCtl(Self:cLoteCtl)
	oBlqSaldoItens:SetNumLote(Self:cNumLote)
	oBlqSaldoItens:SetArmazem(Self:cLocal)
	oBlqSaldoItens:SetEnder(Self:cEnder)
	oBlqSaldoItens:SetIdUnit(Self:cIdUnit)
	oBlqSaldoItens:SetQtdLib(Self:nQtdLib)
	If oBlqSaldoItens:LoadData(1)
		If !(lRet := oBlqSaldoItens:RemoverBloqueio())
			Self:cErro := Self:oBlqSaldoItens:GetErro()
		EndIf
	EndIf
	FreeObj(oBlqSaldoItens)
Return lRet
//--------------------------------------
/*/{Protheus.doc} RefazerBloqueio
Refaz bloqueio de saldo no endereço origem, quando a transferência é excluída.
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//--------------------------------------
METHOD RefazerBloqueio() CLASS WMSDTCTransferenciaBloqueioSaldoItens
Local lRet := .T.
Local cAliasQry := GetNextAlias()
Local oBlqSaldoItens := WMSDTCBloqueioSaldoItens():New()

	BeginSql Alias cAliasQry
		SELECT D18.D18_IDBLOQ,
			   D18.D18_DOCBLQ,
			   D18.D18_DCFBLQ,
			   D18.D18_TIPBLQ,
			   D18.D18_ORIGEM,
			   D18.D18_OBSERV,
			   D18.D18_MOTIVO,
			   D19.D19_PRDORI,
			   D19.D19_PRODUT,
			   D19.D19_LOTECT,
			   D19.D19_NUMLOT,
			   D19.D19_LOCAL,
			   D19.D19_ENDER,
			   D19.D19_IDUNIT,
			   D19.D19_QTDBLQ,
			   D19.D19_DTVALD,
			   D18.R_E_C_N_O_ RECNOD18,
			   D19.R_E_C_N_O_ RECNOD19
		 FROM %Table:D18% D18
		INNER JOIN %Table:D19% D19
		   ON D19.D19_FILIAL = %xFilial:D19%
		  AND D19.D19_IDDCF = D18.D18_IDDCF
		  AND D19.D19_IDBLOQ = D18.D18_IDBLOQ
		  AND D19.%NotDel%
		WHERE D18.D18_FILIAL = %xFilial:D18%
		  AND D18.D18_IDDCF = %Exp:Self:cIdDCF%
		  AND D18.%NotDel%
	EndSql
	TcSetField(cAliasQry,'D19_DTVALD','D')
	While (cAliasQry)->(!EoF()) .And. lRet
		oBlqSaldoItens:ClearData()
		oBlqSaldoItens:SetIdBlq((cAliasQry)->D18_IDBLOQ)
		oBlqSaldoItens:SetIdDCF((cAliasQry)->D18_DCFBLQ)
		oBlqSaldoItens:SetDocto((cAliasQry)->D18_DOCBLQ)
		oBlqSaldoItens:SetMotivo((cAliasQry)->D18_MOTIVO)
		oBlqSaldoItens:SetObserv((cAliasQry)->D18_OBSERV)
		oBlqSaldoItens:SetOrigem((cAliasQry)->D18_ORIGEM)
		oBlqSaldoItens:SetTipBlq((cAliasQry)->D18_TIPBLQ)
		oBlqSaldoItens:SetPrdOri((cAliasQry)->D19_PRDORI)
		oBlqSaldoItens:SetProduto((cAliasQry)->D19_PRODUT)
		oBlqSaldoItens:SetLoteCtl((cAliasQry)->D19_LOTECT)
		oBlqSaldoItens:SetNumLote((cAliasQry)->D19_NUMLOT)
		oBlqSaldoItens:SetArmazem((cAliasQry)->D19_LOCAL)
		oBlqSaldoItens:SetEnder((cAliasQry)->D19_ENDER)
		oBlqSaldoItens:SetIdUnit((cAliasQry)->D19_IDUNIT)
		oBlqSaldoItens:SetQtdBlq((cAliasQry)->D19_QTDBLQ)
		oBlqSaldoItens:SetDtValid((cAliasQry)->D19_DTVALD)
		If !(lRet := oBlqSaldoItens:RealizarBloqueio())
			Self:cErro := oBlqSaldoItens:GetErro()
		EndIf
		If lRet
			Self:nRecno := (cAliasQry)->RECNOD19
			lRet := Self:DeleteD19()
		EndIf
		If lRet
			Self:oTransfBlq:SetRecno((cAliasQry)->RECNOD18)
			If !Self:ExisteD19()
				lRet := Self:oTransfBlq:DeleteD18()
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	FreeObj(oBlqSaldoItens)
Return lRet

METHOD GerarBloqueioNoEnderecoDestino(cIdDCF,cArmDes,cEndDes,cUniDes) CLASS WMSDTCTransferenciaBloqueioSaldoItens
Local lRet := .T.
Local cAliasQry := GetNextAlias()
Local oBlqSaldoItens := WMSDTCBloqueioSaldoItens():New()
	BeginSql Alias cAliasQry
		SELECT D18.D18_IDBLOQ,
			   D18.D18_DOCBLQ,
			   D18.D18_DCFBLQ,
			   D18.D18_TIPBLQ,
			   D18.D18_ORIGEM,
			   D18.D18_OBSERV,
			   D18.D18_MOTIVO,
			   D19.D19_PRDORI,
			   D19.D19_PRODUT,
			   D19.D19_LOTECT,
			   D19.D19_NUMLOT,
			   D19.D19_LOCAL,
			   D19.D19_ENDER,
			   D19.D19_IDUNIT,
			   D19.D19_QTDBLQ,
			   D19.D19_DTVALD,
			   D18.R_E_C_N_O_ RECNOD18,
			   D19.R_E_C_N_O_ RECNOD19
		 FROM %Table:D18% D18
		INNER JOIN %Table:D19% D19
		   ON D19.D19_FILIAL = %xFilial:D19%
		  AND D19.D19_IDDCF = D18.D18_IDDCF
		  AND D19.D19_IDBLOQ = D18.D18_IDBLOQ
		  AND D19.%NotDel%
		WHERE D18.D18_FILIAL = %xFilial:D18%
		  AND D18.D18_IDDCF = %Exp:cIdDCF%
		  AND D18.%NotDel%
	EndSql
	TcSetField(cAliasQry,'D19_DTVALD','D')
	While (cAliasQry)->(!EoF()) .And. lRet
		oBlqSaldoItens:ClearData()
		oBlqSaldoItens:SetIdBlq((cAliasQry)->D18_IDBLOQ)
		oBlqSaldoItens:SetIdDCF((cAliasQry)->D18_DCFBLQ)
		oBlqSaldoItens:SetDocto((cAliasQry)->D18_DOCBLQ)
		oBlqSaldoItens:SetMotivo((cAliasQry)->D18_MOTIVO)
		oBlqSaldoItens:SetObserv((cAliasQry)->D18_OBSERV)
		oBlqSaldoItens:SetOrigem((cAliasQry)->D18_ORIGEM)
		oBlqSaldoItens:SetTipBlq((cAliasQry)->D18_TIPBLQ)
		oBlqSaldoItens:SetPrdOri((cAliasQry)->D19_PRDORI)
		oBlqSaldoItens:SetProduto((cAliasQry)->D19_PRODUT)
		oBlqSaldoItens:SetLoteCtl((cAliasQry)->D19_LOTECT)
		oBlqSaldoItens:SetNumLote((cAliasQry)->D19_NUMLOT)
		oBlqSaldoItens:SetArmazem(cArmDes)
		oBlqSaldoItens:SetEnder(cEndDes)
		oBlqSaldoItens:SetIdUnit(cUniDes)
		oBlqSaldoItens:SetQtdBlq((cAliasQry)->D19_QTDBLQ)
		oBlqSaldoItens:SetQtdOri((cAliasQry)->D19_QTDBLQ)
		oBlqSaldoItens:SetDtValid((cAliasQry)->D19_DTVALD)
		If !(lRet := oBlqSaldoItens:RealizarBloqueio())
			Self:cErro := oBlqSaldoItens:GetErro()
		EndIf
		If lRet
			Self:nRecno := (cAliasQry)->RECNOD19
			lRet := Self:DeleteD19()
		EndIf
		If lRet
			Self:oTransfBlq:SetRecno((cAliasQry)->RECNOD18)
			If !Self:ExisteD19()
				lRet := Self:oTransfBlq:DeleteD18()
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
Return lRet
