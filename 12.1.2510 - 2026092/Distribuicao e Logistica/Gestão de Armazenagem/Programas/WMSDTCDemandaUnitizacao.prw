#Include "Totvs.ch"
#Include "WMSDTCDemandaUnitizacao.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0053
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Squad WMS
@since 20/03/2017
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0053()
Return Nil
//----------------------------------------
/*/{Protheus.doc} WMSDTCDemandaUnitizacao
Classe demanda de unitização
@author Squad WMS
@since 20/03/2017
@version 1.0
/*/
//----------------------------------------
CLASS WMSDTCDemandaUnitizacao FROM LongNameClass
	// Data
	DATA lHasHora   // Utilizado para suavizar o campo D0Q_HORA
	DATA oProdLote
	DATA oDmdEndOri
	DATA oDmdEndDes
	DATA oServico
	DATA dData
	DATA cHora
	DATA cOrigem
	DATA cDocumento
	DATA cSerie
	DATA cCliFor
	DATA cLoja
	DATA cStatus
	DATA cNumSeq
	DATA cIdD0Q
	DATA cErro
	DATA nQuant
	DATA nQtdUni
	DATA nRecno
	DATA nIndex
	DATA aWmsAviso AS array
	// Setters e Getters
	METHOD New() CONSTRUCTOR
	METHOD SetServico(cServico)
	METHOD SetData(dData)
	METHOD SetHora(cHora)
	METHOD SetOrigem(cOrigem)
	METHOD SetDocto(cDocumento)
	METHOD SetSerie(cSerie)
	METHOD SetCliFor(cCliFor)
	METHOD SetLoja(cLoja)
	METHOD SetStatus(cStatus)
	METHOD SetNumSeq(cNumSeq)
	METHOD SetIdD0Q(cIdD0Q)
	METHOD SetQuant(nQuant)
	METHOD SetQtdUni(nQtdUni)
	METHOD GetServico()
	METHOD GetData()
	METHOD GetHora()
	METHOD GetOrigem()
	METHOD GetDocto()
	METHOD GetSerie()
	METHOD GetCliFor()
	METHOD GetLoja()
	METHOD GetStatus()
	METHOD GetNumSeq()
	METHOD GetIdD0Q()
	METHOD GetQuant()
	METHOD GetQtdUni()
	METHOD GetGeraSld()
	METHOD GetRecno()
	METHOD GetErro()
	//Demais Métodos
	METHOD LoadData(nIndex)
	METHOD RecordD0Q()
	METHOD ReverseMO(nQtdEst)
	METHOD GoToD0Q(nRecno)
	METHOD MakeArmaz()
	METHOD MakeOutput()
	METHOD MakeInput()
	METHOD ShowWarnig()
	METHOD UpdateD0Q()
	METHOD UpdIntegra()
	METHOD UndoIntegr()
	METHOD ReverseMA()
	METHOD ExcludeD0Q()
	METHOD SaiMovEst()
	METHOD Destroy()
ENDCLASS
//----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author Squad WMS
@since 20/03/2017
@version 1.0
/*/
//----------------------------------------
METHOD New() CLASS WMSDTCDemandaUnitizacao
	Self:lHasHora   := WmsX312123("D0Q","D0Q_HORA")
	Self:oProdLote  := WMSDTCProdutoLote():New()
	Self:oDmdEndOri := WMSDTCEndereco():New()
	Self:oDmdEndDes := WMSDTCEndereco():New()
	Self:oServico   := WMSDTCServicoTarefa():New()
	//Atribui demais campos
	Self:dData      := dDataBase
	Self:cHora      := Space(IIf(Self:lHasHora,TamSx3("D0Q_HORA")[1],8))
	Self:cOrigem    := Padr("", TamSX3("D0Q_ORIGEM")[1])
	Self:cDocumento := Padr("", TamSX3("D0Q_DOCTO")[1])
	Self:cSerie     := Padr("", TamSX3("D0Q_SERIE")[1])
	Self:cCliFor    := Padr("", TamSX3("D0Q_CLIFOR")[1])
	Self:cLoja      := Padr("", TamSX3("D0Q_LOJA")[1])
	Self:cStatus    := Padr("", TamSX3("D0Q_STATUS")[1])
	Self:cNumSeq    := Padr("", TamSX3("D0Q_NUMSEQ")[1])
	Self:cIdD0Q     := Padr("", TamSX3("D0Q_ID")[1])
	Self:cErro      := ""
	Self:nQuant     := 0
	Self:nQtdUni    := 0
	Self:nRecno     := 0
	Self:aWmsAviso  := {}
Return

METHOD Destroy() CLASS WMSDTCDemandaUnitizacao
	//Mantido para compatibilidade
Return Nil
//----------------------------------------
/*/{Protheus.doc} GoToD0Q
Posicionamento para atualização das propriedades
@author Squad WMS
@since 20/03/2017
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToD0Q(nRecno) CLASS WMSDTCDemandaUnitizacao
	Self:nRecno := nRecno
Return Self:LoadData(0)
//----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0Q
@author Squad WMS
@since 21/03/2017
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCDemandaUnitizacao
Local lRet        := .T.
Local aAreaD0Q    := D0Q->(GetArea())
Local aD0Q_QUANT  := TamSx3("D0Q_QUANT")
Local aD0Q_QTDUNI := TamSx3("D0Q_QTDUNI")
Local cCampos     := ""
Local cWhere      := ""
Local cAliasD0Q   := Nil

	Default nIndex := 3
	Do Case
		Case nIndex == 0 // R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0Q_FILIAL+D0Q_SERVIC+D0Q_DOCTO+D0Q_SERIE+D0Q_CLIFOR+D0Q_LOJA+D0Q_CODPRO
			If (Empty(Self:oServico:GetServico()) .Or. Empty(Self:cDocumento))
				lRet := .F.
			EndIf
		Case nIndex == 2 // D0Q_FILIAL+D0Q_SERVIC+D0Q_CODPRO+D0Q_DOCTO+D0Q_SERIE+D0Q_CLIFOR+D0Q_LOJA
			If (Empty(Self:oServico:GetServico()) .Or. Empty(Self:oProdLote:GetProduto()) .Or. Empty(Self:cDocumento))
				lRet := .F.
			EndIf
		Case nIndex == 3 // D0Q_FILIAL+D0Q_ID
			If Empty(Self:cIdD0Q)
				lRet := .F.
			EndIf
		Otherwise
		lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		// Parâmetro Campos
		cCampos := "%"
		If Self:lHasHora
			cCampos += " D0Q.D0Q_HORA,"
		EndIf
		cCampos += "%"
		cAliasD0Q := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0Q
					SELECT D0Q.D0Q_SERVIC,
							D0Q.D0Q_DATA,
							%Exp:cCampos%
							D0Q.D0Q_ORIGEM,
							D0Q.D0Q_DOCTO,
							D0Q.D0Q_SERIE,
							D0Q.D0Q_CLIFOR,
							D0Q.D0Q_LOJA,
							D0Q.D0Q_CODPRO,
							D0Q.D0Q_LOTECT,
							D0Q.D0Q_NUMLOT,
							D0Q.D0Q_STATUS,
							D0Q.D0Q_QUANT,
							D0Q.D0Q_QTDUNI,
							D0Q.D0Q_PRDORI,
							D0Q.D0Q_NUMSEQ,
							D0Q.D0Q_LOCAL,
							D0Q.D0Q_ENDER,
							D0Q.D0Q_ID,
							D0Q.R_E_C_N_O_ RECNOD0Q
					FROM %Table:D0Q% D0Q
					WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
					AND D0Q.R_E_C_N_O_ = %Exp:Self:nRecno%
					AND D0Q.%NotDel%
				EndSql
			Case nIndex == 1
				cWhere := "%"
				If !Empty(Self:cSerie)
					cWhere += " AND D0Q.D0Q_SERIE  = '"+Self:cSerie+"'"
				EndIf
				If !Empty(Self:cCliFor)
					cWhere += " AND D0Q.D0Q_CLIFOR = '"+Self:cCliFor+"'"
				EndIf
				If !Empty(Self:cLoja)
					cWhere += " AND D0Q.D0Q_LOJA   = '"+Self:cLoja+"'"
				EndIf
				If !Empty(Self:oProdLote:GetProduto())
					cWhere += " AND D0Q.D0Q_CODPRO = '"+Self:oProdLote:GetProduto()+"'"
				EndIf
				If !Empty(Self:cNumSeq)
					cWhere += " AND D0Q.D0Q_NUMSEQ = '"+Self:cNumSeq+"'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD0Q
					SELECT D0Q.D0Q_SERVIC,
							D0Q.D0Q_DATA,
							%Exp:cCampos%
							D0Q.D0Q_ORIGEM,
							D0Q.D0Q_DOCTO,
							D0Q.D0Q_SERIE,
							D0Q.D0Q_CLIFOR,
							D0Q.D0Q_LOJA,
							D0Q.D0Q_CODPRO,
							D0Q.D0Q_LOTECT,
							D0Q.D0Q_NUMLOT,
							D0Q.D0Q_STATUS,
							D0Q.D0Q_QUANT,
							D0Q.D0Q_QTDUNI,
							D0Q.D0Q_PRDORI,
							D0Q.D0Q_NUMSEQ,
							D0Q.D0Q_LOCAL,
							D0Q.D0Q_ENDER,
							D0Q.D0Q_ID,
							D0Q.R_E_C_N_O_ RECNOD0Q
					FROM %Table:D0Q% D0Q
					WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
					AND D0Q.D0Q_SERVIC = %Self:oServico:GetServico()%
					AND D0Q.D0Q_DOCTO  = %Self:cDocumento%
					AND D0Q.%NotDel%
					%Exp:cWhere%
				EndSql
			Case nIndex == 2
				cWhere := "%"
				If !Empty(Self:cSerie)
					cWhere += " AND D0Q.D0Q_SERIE  = '"+Self:cSerie+"'"
				EndIf
				If !Empty(Self:cCliFor)
					cWhere += " AND D0Q.D0Q_CLIFOR = '"+Self:cCliFor+"'"
				EndIf
				If !Empty(Self:cLoja)
					cWhere += " AND D0Q.D0Q_LOJA   = '"+Self:cLoja+"'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD0Q
					SELECT D0Q.D0Q_SERVIC,
							D0Q.D0Q_DATA,
							%Exp:cCampos%
							D0Q.D0Q_ORIGEM,
							D0Q.D0Q_DOCTO,
							D0Q.D0Q_SERIE,
							D0Q.D0Q_CLIFOR,
							D0Q.D0Q_LOJA,
							D0Q.D0Q_CODPRO,
							D0Q.D0Q_LOTECT,
							D0Q.D0Q_NUMLOT,
							D0Q.D0Q_STATUS,
							D0Q.D0Q_QUANT,
							D0Q.D0Q_QTDUNI,
							D0Q.D0Q_PRDORI,
							D0Q.D0Q_NUMSEQ,
							D0Q.D0Q_LOCAL,
							D0Q.D0Q_ENDER,
							D0Q.D0Q_ID,
							D0Q.R_E_C_N_O_ RECNOD0Q
					FROM %Table:D0Q% D0Q
					WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
					AND D0Q.D0Q_SERVIC = %Exp:Self:oServico:GetServico()%
					AND D0Q.D0Q_CODPRO = %Exp:Self:oProdLote:GetProduto()%
					AND D0Q.D0Q_DOCTO  = %Exp:Self:cDocumento%
					AND D0Q.%NotDel%
					%Exp:cWhere%
				EndSql
			Case nIndex == 3
				BeginSql Alias cAliasD0Q
					SELECT D0Q.D0Q_SERVIC,
							D0Q.D0Q_DATA,
							%Exp:cCampos%
							D0Q.D0Q_ORIGEM,
							D0Q.D0Q_DOCTO,
							D0Q.D0Q_SERIE,
							D0Q.D0Q_CLIFOR,
							D0Q.D0Q_LOJA,
							D0Q.D0Q_CODPRO,
							D0Q.D0Q_LOTECT,
							D0Q.D0Q_NUMLOT,
							D0Q.D0Q_STATUS,
							D0Q.D0Q_QUANT,
							D0Q.D0Q_QTDUNI,
							D0Q.D0Q_PRDORI,
							D0Q.D0Q_NUMSEQ,
							D0Q.D0Q_LOCAL,
							D0Q.D0Q_ENDER,
							D0Q.D0Q_ID,
							D0Q.R_E_C_N_O_ RECNOD0Q
					FROM %Table:D0Q% D0Q
					WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
					AND D0Q.D0Q_ID = %Exp:Self:cIdD0Q%
					AND D0Q.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD0Q,'D0Q_QUANT','N',aD0Q_QUANT[1],aD0Q_QUANT[2])
		TCSetField(cAliasD0Q,'D0Q_QTDUNI','N',aD0Q_QTDUNI[1],aD0Q_QTDUNI[2])
		TcSetField(cAliasD0Q,'D0Q_DATA','D')
		If (lRet := (cAliasD0Q)->(!Eof()))
			// Busca dados endereco origem
			Self:oDmdEndOri:SetArmazem((cAliasD0Q)->D0Q_LOCAL)
			Self:oDmdEndOri:SetEnder((cAliasD0Q)->D0Q_ENDER)
			Self:oDmdEndOri:LoadData()
			// Busca dados endereco destino
			Self:oDmdEndDes:SetArmazem((cAliasD0Q)->D0Q_LOCAL)
			Self:oDmdEndDes:SetEnder((cAliasD0Q)->D0Q_ENDER)
			Self:oDmdEndDes:LoadData()
			// Busca dados lote/produto
			Self:oProdLote:SetArmazem((cAliasD0Q)->D0Q_LOCAL)
			Self:oProdLote:SetPrdOri((cAliasD0Q)->D0Q_PRDORI)
			Self:oProdLote:SetProduto((cAliasD0Q)->D0Q_CODPRO)
			Self:oProdLote:SetLoteCtl((cAliasD0Q)->D0Q_LOTECT)
			Self:oProdLote:SetNumLote((cAliasD0Q)->D0Q_NUMLOT)
			Self:oProdLote:SetNumSer("")
			Self:oProdLote:LoadData()
			// Atribui dados servico
			Self:oServico:SetServico((cAliasD0Q)->D0Q_SERVIC)
			Self:oServico:LoadData()
			// Atribui dados aos demais campos
			Self:dData     := (cAliasD0Q)->D0Q_DATA
			If Self:lHasHora
				Self:cHora     := (cAliasD0Q)->D0Q_HORA
			EndIf
			Self:cOrigem   := (cAliasD0Q)->D0Q_ORIGEM
			Self:cDocumento:= (cAliasD0Q)->D0Q_DOCTO
			Self:cSerie    := (cAliasD0Q)->D0Q_SERIE
			Self:cCliFor   := (cAliasD0Q)->D0Q_CLIFOR
			Self:cLoja     := (cAliasD0Q)->D0Q_LOJA
			Self:cStatus   := (cAliasD0Q)->D0Q_STATUS
			Self:nQuant    := (cAliasD0Q)->D0Q_QUANT
			Self:nQtdUni   := (cAliasD0Q)->D0Q_QTDUNI
			Self:cNumSeq   := (cAliasD0Q)->D0Q_NUMSEQ
			Self:cIdD0Q    := (cAliasD0Q)->D0Q_ID
			Self:nRecno    := (cAliasD0Q)->RECNOD0Q
		Else
			Self:cErro := WmsFmtMsg(STR0002,{{"[VAR01]",AllTrim(Self:cIdD0Q)}})// Demanda de Unitização para o identificador [VAR01] não cadastrado!
		EndIf
		(cAliasD0Q)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0Q)
Return lRet
//----------------------------------------
// Setters
//----------------------------------------,
METHOD SetServico(cServico) CLASS WMSDTCDemandaUnitizacao
	Self:oServico:SetServico(cServico)
Return

METHOD SetData(dData) CLASS WMSDTCDemandaUnitizacao
	Self:dData := PadR(dData, Len(Self:dData))
Return

METHOD SetHora(cHora) CLASS WMSDTCDemandaUnitizacao
	Self:cHora := cHora
Return

METHOD SetOrigem(cOrigem) CLASS WMSDTCDemandaUnitizacao
	Self:cOrigem := PadR(cOrigem, Len(Self:cOrigem))
Return

METHOD SetDocto(cDocumento) CLASS WMSDTCDemandaUnitizacao
	Self:cDocumento := PadR(cDocumento, Len(Self:cDocumento))
Return

METHOD SetSerie(cSerie) CLASS WMSDTCDemandaUnitizacao
	Self:cSerie := PadR(cSerie, Len(Self:cSerie))
Return

METHOD SetCliFor(cCliFor) CLASS WMSDTCDemandaUnitizacao
	Self:cCliFor := PadR(cCliFor, Len(Self:cCliFor))
Return

METHOD SetLoja(cLoja) CLASS WMSDTCDemandaUnitizacao
	Self:cLoja := PadR(cLoja, Len(Self:cLoja))
Return

METHOD SetStatus(cStatus) CLASS WMSDTCDemandaUnitizacao
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetNumSeq(cNumSeq) CLASS WMSDTCDemandaUnitizacao
	Self:cNumSeq := PadR(cNumSeq, Len(Self:cNumSeq))
Return

METHOD SetIdD0Q(cIdD0Q) CLASS WMSDTCDemandaUnitizacao
	Self:cIdD0Q := PadR(cIdD0Q, Len(Self:cIdD0Q))
Return

METHOD SetQuant(nQuant) CLASS WMSDTCDemandaUnitizacao
	Self:nQuant := nQuant
Return

METHOD SetQtdUni(nQtdUni) CLASS WMSDTCDemandaUnitizacao
	Self:nQtdUni := nQtdUni
Return
//----------------------------------------
// Getters
//----------------------------------------
METHOD GetServico() CLASS WMSDTCDemandaUnitizacao
Return Self:oServico:GetServico()

METHOD GetData() CLASS WMSDTCDemandaUnitizacao
Return Self:dData

METHOD GetHora() CLASS WMSDTCDemandaUnitizacao
Return Self:cHora

METHOD GetOrigem() CLASS WMSDTCDemandaUnitizacao
Return Self:cOrigem

METHOD GetDocto() CLASS WMSDTCDemandaUnitizacao
Return Self:cDocumento

METHOD GetSerie() CLASS WMSDTCDemandaUnitizacao
Return Self:cSerie

METHOD GetCliFor() CLASS WMSDTCDemandaUnitizacao
Return Self:cCliFor

METHOD GetLoja() CLASS WMSDTCDemandaUnitizacao
Return Self:cLoja

METHOD GetStatus() CLASS WMSDTCDemandaUnitizacao
Return Self:cStatus

METHOD GetNumSeq() CLASS WMSDTCDemandaUnitizacao
Return Self:cNumSeq

METHOD GetIdD0Q() CLASS WMSDTCDemandaUnitizacao
Return Self:cIdD0Q

METHOD GetQuant() CLASS WMSDTCDemandaUnitizacao
Return Self:nQuant

METHOD GetQtdUni() CLASS WMSDTCDemandaUnitizacao
Return Self:nQtdUni

METHOD GetErro() CLASS WMSDTCDemandaUnitizacao
Return Self:cErro

METHOD GetRecno() CLASS WMSDTCDemandaUnitizacao
Return Self:nRecno
//----------------------------------------
/*/{Protheus.doc} RecordD0Q
Grava D0Q
@author Squad WMS
@since 20/03/2017
@version 1.0
/*/
//----------------------------------------
METHOD RecordD0Q() CLASS WMSDTCDemandaUnitizacao
Local lRet     := .T.
Local aAreaD0Q := D0Q->(GetArea())
	Self:cIdD0Q := WMSProxSeq('MV_DOCSEQ','DCF_ID')
	// Verifica se o Armazem está vazio e atribui para os enderecos
	If Empty(Self:oDmdEndOri:GetArmazem())
		Self:oDmdEndOri:SetArmazem(Self:oDmdEndDes:GetArmazem())
	EndIf
	If Empty(Self:oDmdEndDes:GetArmazem())
		Self:oDmdEndDes:SetArmazem(Self:oDmdEndOri:GetArmazem())
	EndIf
	If Empty(Self:dData)
		Self:dData := dDataBase
	EndIf
	If Empty(Self:cHora)
		Self:cHora := Time()
	EndIf
	If Empty(Self:cStatus)
		Self:cStatus := "1"
	EndIf
	// Grava D0Q
	D0Q->(dbSetOrder(3)) //D0Q_FILIAL+D0Q_ID
	If !D0Q->(dbSeek(xFilial('D00')+Self:cIdD0Q))
		Reclock('D0Q',.T.)
		D0Q->D0Q_FILIAL := xFilial('D0Q')
		D0Q->D0Q_SERVIC := Self:oServico:GetServico()
		D0Q->D0Q_DATA   := Self:dData
		If Self:lHasHora
			D0Q->D0Q_HORA   := Self:cHora
		EndIf
		D0Q->D0Q_ORIGEM := Self:cOrigem
		D0Q->D0Q_DOCTO  := Self:cDocumento
		D0Q->D0Q_SERIE  := Self:cSerie
		D0Q->D0Q_CLIFOR := Self:cCliFor
		D0Q->D0Q_LOJA   := Self:cLoja
		D0Q->D0Q_CODPRO := Self:oProdLote:GetProduto()
		D0Q->D0Q_PRDORI := Self:oProdLote:GetPrdOri()
		D0Q->D0Q_LOTECT := Self:oProdLote:GetLoteCtl()
		D0Q->D0Q_NUMLOT := Self:oProdLote:GetNumLote()
		D0Q->D0Q_STATUS := Self:cStatus
		D0Q->D0Q_NUMSEQ := Self:cNumSeq
		D0Q->D0Q_LOCAL  := Self:oDmdEndOri:GetArmazem()
		D0Q->D0Q_ENDER  := Self:oDmdEndOri:GetEnder()
		D0Q->D0Q_ID     := Self:cIdD0Q
		D0Q->D0Q_QUANT  := Self:nQuant
		D0Q->D0Q_QTDUNI := Self:nQtdUni
		D0Q->(MsUnlock())
		//Grava Recno
		Self:nRecno := D0Q->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Chave duplicada!
	EndIf
	RestArea(aAreaD0Q)
Return lRet
//----------------------------------------
/*/{Protheus.doc} UpdateD0Q
Atualização dos dados D0Q
@author Squad WMS
@since 20/03/2017
@version 1.0
/*/
//----------------------------------------
METHOD UpdateD0Q() CLASS WMSDTCDemandaUnitizacao
Local lRet     := .T.
Local aAreaD0Q := D0Q->(GetArea())
	If !Empty(Self:GetRecno())
		D0Q->(dbGoto(Self:GetRecno()))
		Reclock('D0Q',.F.)
		D0Q->D0Q_SERVIC := Self:oServico:GetServico()
		D0Q->D0Q_DATA   := Self:dData
		If Self:lHasHora
			D0Q->D0Q_HORA   := Self:cHora
		EndIf
		D0Q->D0Q_ORIGEM := Self:cOrigem
		D0Q->D0Q_DOCTO  := Self:cDocumento
		D0Q->D0Q_SERIE  := Self:cSerie
		D0Q->D0Q_CLIFOR := Self:cCliFor
		D0Q->D0Q_LOJA   := Self:cLoja
		D0Q->D0Q_CODPRO := Self:oProdLote:GetProduto()
		D0Q->D0Q_PRDORI := Self:oProdLote:GetPrdOri()
		D0Q->D0Q_LOTECT := Self:oProdLote:GetLoteCtl()
		D0Q->D0Q_NUMLOT := Self:oProdLote:GetNumLote()
		D0Q->D0Q_STATUS := Self:cStatus
		D0Q->D0Q_NUMSEQ := Self:cNumSeq
		D0Q->D0Q_LOCAL  := Self:oDmdEndOri:GetArmazem()
		D0Q->D0Q_ENDER  := Self:oDmdEndOri:GetEnder()
		D0Q->D0Q_ID     := Self:cIdD0Q
		D0Q->D0Q_QUANT  := Self:nQuant
		D0Q->D0Q_QTDUNI := Self:nQtdUni
		D0Q->(MsUnlock())
	Else
		lRet := .F.
		Self:cErro := STR0004 // Recno inválido!
	EndIf
	RestArea(aAreaD0Q)
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeArmaz
Realiza a armazenagem
@author Squad WMS
@since 21/03/2017
@version 1.0
/*/
//----------------------------------------
METHOD MakeArmaz() CLASS WMSDTCDemandaUnitizacao
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oDmdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oDmdEndOri:GetEnder())
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
				oMovEstEnd:SetIdDCF(Self:cIdD0Q);
			})
			// Seta o bloco de código para informações do movimento
			oEstEnder:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdMovto(""),;
				oMovEstEnd:SetIdOpera(""),;
				oMovEstEnd:SetIdUnit("");
			})
			// Realiza Entrada Armazem Estoque por Endereço
			If !(lRet := oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/))
				Self:cErro := oEstEnder:GetErro()
				Exit
			EndIf
		Next
	EndIf

Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeOutput
Realiza uma saída
@author Squad WMS
@since 21/03/2017
@version 1.0
/*/
//----------------------------------------
METHOD MakeOutput() CLASS WMSDTCDemandaUnitizacao
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()

	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	// Verifica se há produtos
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oDmdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oDmdEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
			// Realiza Entrada Armazem Estoque por Endereço
			If !(lRet := oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/))
				Self:cErro := oEstEnder:GetErro()
				Exit
			EndIf
		Next
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} MakeInput
Realiza uma entrada
@author Squad WMS
@since 21/03/2017
@version 1.0
/*/
//----------------------------------------
METHOD MakeInput() CLASS WMSDTCDemandaUnitizacao
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	// Verifica se há produtos
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oDmdEndDes:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oDmdEndDes:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
			// Realiza Entrada Armazem Estoque por Endereço
			If !(lRet := oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/))
				Self:cErro := oEstEnder:GetErro()
				Exit
			EndIf
		Next
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} ShowWarnig
Mostra a mensagem de erro
@author Squad WMS
@since 21/03/2017
@version 1.0
/*/
//----------------------------------------
METHOD ShowWarnig() CLASS WMSDTCDemandaUnitizacao
Local nCntFor := 0
Local cMemo   := ""
Local cMask   := STR0005 // Arquivos Texto (*.TXT) |*.txt|
Local cFile   := Space(100)
Local cTitle  := OemToAnsi(OemToAnsi(STR0006)) // Salvar Aquivo
	If !Empty(Self:aWmsAviso)
		For nCntFor := 1 To Len(Self:aWmsAviso)
			If nCntFor == 1
				cMemo := Self:aWmsAviso[nCntFor]
			Else
				cMemo += CRLF+Self:aWmsAviso[nCntFor]
			EndIf
		Next
		DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15

		DEFINE MSDIALOG oDlg TITLE "SIGAWMS" From 3,0 to 340,717 PIXEL

		@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 351,145 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont

		DEFINE SBUTTON  FROM 153,330 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL // Apaga
		DEFINE SBUTTON  FROM 153,300 TYPE 13 ACTION (cFile:=cGetFile(cMask,cTitle),If(cFile="",.T.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL // Salva e Apaga //"Salvar Como..."

		ACTIVATE MSDIALOG oDlg CENTER
		// Limpa as mensagens anteriores
		Self:aWmsAviso := {}
	EndIf
Return

//----------------------------------------
/*/{Protheus.doc} ExcludeD0Q
Realiza a exclusão da demanda de unitização
@author Squad WMS
@since 12/04/2017
@version 1.0
/*/
//----------------------------------------
METHOD ExcludeD0Q() CLASS WMSDTCDemandaUnitizacao
Local lRet := .T.
Local aAreaD0Q := D0Q->(GetArea())
	//Se exclui a demanda de unitização, deve apagar os campos de "IDDCF" na D0G  e SD1
	Self:UpdIntegra()
	If !Empty(Self:GetRecno())
		//Apaga D0Q
		D0Q->(dbGoTo( Self:GetRecno() ))
		RecLock('D0Q', .F.)
		D0Q->(dbDelete())
		D0Q->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0007 // Dados não encontrados!
	EndIf
	RestArea(aAreaD0Q)
Return lRet
//----------------------------------------
/*/{Protheus.doc} UpdIntegra
Atualiza a integração da demanda de unitização
@author Squad WMS
@since 08/05/2017
@version 1.0
/*/
//----------------------------------------
METHOD UpdIntegra() CLASS WMSDTCDemandaUnitizacao
Local lRet := .T.
Local aAreaSD1 := SD1->(GetArea())
Local aAreaD0G := D0G->(GetArea())
	//Ajusta SD1
	SD1->(DbSetOrder(1))
	If SD1->(dbSeek(xFilial('SD1')+Self:cDocumento+Self:cSerie+Self:cCliFor+Self:cLoja+Self:oProdLote:GetProduto()))
		RecLock('SD1', .F.)
		SD1->D1_IDDCF := ""
		SD1->(MsUnLock())
	EndIf
	//Ajusta D0G
	D0G->(DbSetOrder(3))
	If D0G->(dbSeek(xFilial('D0G')+Self:cIdD0Q))
		RecLock('D0G', .F.)
		D0G->D0G_IDDCF := ""
		D0G->(MsUnLock())
	EndIf
	RestArea(aAreaSD1)
	RestArea(aAreaD0G)
Return lRet
//----------------------------------------
/*/{Protheus.doc} ReverseMO
Estorno MO
@author Squad WMS
@since 12/04/2017
@version 1.0
/*/
//----------------------------------------
METHOD ReverseMO(nQtdEst) CLASS WMSDTCDemandaUnitizacao
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()

Default nQtdEst := Self:nQuant
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oDmdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oDmdEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:LoadData()
			oEstEnder:SetQuant(QtdComp(nQtdEst * aProduto[nProduto][2]) )
			// Realiza Entrada Armazem Estoque por Endereço
			If !(lRet := oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,.F.))
				Self:cErro := oEstEnder:GetErro()
				Exit
			EndIf
		Next
	EndIf
Return lRet
//----------------------------------------
/*/{Protheus.doc} UndoIntegr
Desfaz a integração da ordem de serviço
@author Squad WMS
@since 08/05/2017
@version 1.0
/*/
//----------------------------------------
METHOD UndoIntegr() CLASS WMSDTCDemandaUnitizacao
Local lRet     := .T.
	// Atualiza estoque por endereco
	If Self:oServico:HasOperac({'1','2'}) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
		If lRet
			lRet := Self:ReverseMA()
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
			oSaldoADis:SetIdDCF(Self:cIdD0Q)
			If oSaldoADis:LoadData(1)
				oSaldoADis:DeleteD0G()
			EndIf
		EndIf
	EndIf
	If lRet .And. WmsX312118("D13","D13_USACAL")
		lRet := Self:SaiMovEst()
	EndIf
Return lRet

//----------------------------------------
/*/{Protheus.doc} ReverseMA
Estorno MA
@author Squad WMS
@since 10/05/2017
@version 1.0
/*/
//----------------------------------------
METHOD ReverseMA() CLASS WMSDTCDemandaUnitizacao
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	aProduto := Self:oProdLote:GetArrProd()
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem(Self:oDmdEndOri:GetArmazem())
			oEstEnder:oEndereco:SetEnder(Self:oDmdEndOri:GetEnder())
			oEstEnder:oProdLote:SetArmazem(Self:oProdLote:GetArmazem()) // Armazem
			oEstEnder:oProdLote:SetPrdOri(Self:oProdLote:GetPrdOri())   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl(Self:oProdLote:GetLotectl()) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote(Self:oProdLote:GetNumLote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())   // Numero de serie
			oEstEnder:LoadData()
			oEstEnder:SetQuant(QtdComp(Self:nQuant * aProduto[nProduto][2]) )
			// Seta o bloco de código para informações do documento
			oEstEnder:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem(Self:cOrigem),;
				oMovEstEnd:SetDocto(Self:cDocumento),;
				oMovEstEnd:SetSerie(Self:cSerie),;
				oMovEstEnd:SetCliFor(Self:cCliFor),;
				oMovEstEnd:SetLoja(Self:cLoja),;
				oMovEstEnd:SetNumSeq(Self:cNumSeq),;
				oMovEstEnd:SetIdDCF(Self:cIdD0Q);
			})
			// Seta o bloco de código para informações do movimento
			oEstEnder:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdMovto(""),;
				oMovEstEnd:SetIdOpera(""),;
				oMovEstEnd:SetIdUnit(""),;
				oMovEstEnd:SetlUsaCal(.F.);
			})
			
			// Realiza Entrada Armazem Estoque por Endereço
			lRet := oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
			If !lRet
				Exit
			EndIf
		Next
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
METHOD SaiMovEst() CLASS WMSDTCDemandaUnitizacao
Local lRet := .T.
Local cAliasD13  := GetNextAlias()
	// Atualiza Saldo
	// Busca dados do kardex
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
		AND D13.D13_IDDCF =  %Exp:Self:cIdD0Q%
		AND D13.D13_USACAL <> '2'
		AND D13.%NotDel%
	EndSql
	Do While (cAliasD13)->(!Eof())
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
