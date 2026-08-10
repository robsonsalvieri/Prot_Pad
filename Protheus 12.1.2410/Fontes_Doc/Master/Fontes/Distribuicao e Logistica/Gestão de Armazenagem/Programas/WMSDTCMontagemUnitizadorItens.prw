#INCLUDE "TOTVS.CH"
#INCLUDE "WMSDTCMONTAGEMUNITIZADORITENS.CH"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0056
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Squad WMS Embarcador
@since 04/04/2017
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0056()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCMontagemUnitizadorItens
Classe itens do unitizador
@author Squad WMS Embarcador
@since 04/04/2017
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCMontagemUnitizadorItens FROM LongNameClass
	// Data
	DATA lHasIdMvUn // Utilizado para suavizar o campo D0S_IDMVUN
	DATA oUnitiz
	DATA oProdLote
	DATA nQuant
	DATA cCodOpe
	DATA cIdD0Q
	DATA cIdUnitAnt
	DATA cEndrec
	DATA cIdMovUni
	DATA lUsaD0Q
	DATA nRecno
	DATA cErro
	DATA bGetDocto // Bloco de código para buscar informações do documento para movimentação de estoque
	// Method
	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD GoToD0S(nRecno)
	METHOD LoadData(nIndex)
	METHOD RecordD0S()
	METHOD ExcludeD0S()
	// Setters
	METHOD SetIdUnit(cIdUnit)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetQuant(nQuant)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetCodOpe(cCodOpe)
	METHOD SetIdD0Q(cIdD0Q)
	METHOD SetIdUnitA(cIdUnitAnt)
	METHOD SetUsaD0Q(lUsaD0Q)
	METHOD SetEndrec(cEndrec)
	METHOD SetBlkDoc()
	METHOD SetIdMovUn(cIdMovUni)
	// Getters
	METHOD GetIdUnit()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetQuant()
	METHOD GetPrdOri()
	METHOD GetCodOpe()
	METHOD GetEndrec()
	METHOD GetIdD0Q()
	METHOD GetIdUnitA()	
	METHOD GetIdMovUn()
	METHOD GetRecno()
	METHOD GetErro()
	// Metodo
	METHOD AssignD0S()
	METHOD VldIdUnit(nAcao,cTipUni,lEstorno)
	METHOD VldTipUni()
	METHOD VldPrdUni(lEstorno)
	METHOD VldPrdCmp(lEstorno)
	METHOD QtdPrdUni(lOnlyUnit,lRastro)
	METHOD VldQtdSld(nQtde,lEstorno)
	METHOD MntPrdUni()
	METHOD IsDad()
	METHOD GetArrProd()
	METHOD GetPesoItem(nQtde)
	METHOD GetSldDisp()
	METHOD EstPrdUni(aProdutos,lTotal)
	METHOD UpdateD0Q(lEstorno)
	METHOD UpdateD14(lEstorno,lTotal)
	METHOD UpdEndrec(lProduto)
	METHOD CalcPesUni(nQtde)
	METHOD Destroy()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 04/04/2017
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCMontagemUnitizadorItens
	Self:lHasIdMvUn := WmsX312118("D0S","D0S_IDMVUN")
	Self:oUnitiz    := WMSDTCMontagemUnitizador():New()
	Self:oProdLote  := WMSDTCProdutoLote():New()
	Self:cIdMovUni  := PadR("", IIf(Self:lHasIdMvUn,TamSx3("D0S_IDMVUN")[1],6))
	Self:cIdD0Q     := PadR("", TamSx3("D0S_IDD0Q")[1])
	Self:ClearData()
Return
//----------------------------------------
METHOD ClearData() CLASS WMSDTCMontagemUnitizadorItens
	Self:oUnitiz:ClearData()
	Self:oProdLote:ClearData()
	Self:nQuant     := 0
	Self:cCodOpe    := __cUserID
	Self:cIdD0Q     := PadR("", Len(Self:cIdD0Q))
	Self:cIdUnitAnt := PadR("", Len(Self:oUnitiz:GetIdUnit()))
	Self:cIdMovUni  := PadR("", IIf(Self:lHasIdMvUn,Len(Self:cIdMovUni),6))
	Self:nRecno     := 0
	Self:lUsaD0Q    := .T.
	Self:cErro      := ""
	Self:bGetDocto  := Nil
	Self:cEndrec    := "2"
Return Nil
//----------------------------------------
METHOD Destroy() CLASS WMSDTCMontagemUnitizadorItens
	//Mantido para compatibilidade
Return Nil
//----------------------------------------
/*/{Protheus.doc} GoToD0S
Posicionamento para atualização das propriedades
@author felipe.m
@since 04/04/2017
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToD0S(nRecno) CLASS WMSDTCMontagemUnitizadorItens
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0S
@author felipe.m
@since 27/02/2017
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCMontagemUnitizadorItens
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local aD0S_QUANT:= TamSx3("D0S_QUANT")
Local aAreaD0S  := D0S->(GetArea())
Local cCampos   := ""
Local cWhere    := ""
Local cAliasD0S := Nil
Default nIndex  := 1

	Do Case
		Case nIndex == 0 // D0S.R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0S_FILIAL+D0S_IDUNIT+D0S_PRDORI+D0S_CODPRO+D0S_LOTECT+D0S_NUMLOT+D0S_IDD0Q
			If Empty(Self:GetIdUnit()) .Or. Empty(Self:GetPrdOri()) .Or. Empty(Self:GetProduto())
				lRet := .F.
			EndIf
		Case nIndex == 2 // D0S_FILIAL+D0S_IDD0Q
			If Empty(Self:GetIdD0Q())
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 + " (" + GetClassName(Self) + ":LoadData(" + cValToChar(nIndex) + " )(D0S))"// Dados para busca não foram informados!
	Else
		// Parâmetro Campos
		cCampos := "%"
		cCampos += IIf(Self:lHasIdMvUn," D0S.D0S_IDMVUN,","")
		cCampos += "%"
		// Parâmetros Where
		cWhere := "%"
		If !Empty(Self:GetLoteCtl())
			cWhere += " AND D0S.D0S_LOTECT = '" + Self:GetLoteCtl()+ "'"
		EndIf
		If !Empty(Self:GetNumLote())
			cWhere += " AND D0S.D0S_NUMLOT = '" + Self:GetNumLote() + "'"
		EndIf
		If !Empty(Self:GetIdD0Q())
			cWhere += " AND D0S.D0S_IDD0Q = '" + Self:GetIdD0Q() + "'"
		EndIf
		cWhere += "%"
		cAliasD0S := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0S
					SELECT D0S.D0S_IDUNIT,
							D0S.D0S_CODPRO,
							D0S.D0S_LOTECT,
							D0S.D0S_NUMLOT,
							D0S.D0S_QUANT,
							D0S.D0S_PRDORI,
							D0S.D0S_CODOPE,
							D0S.D0S_IDD0Q,
							D0S.D0S_ENDREC,
							%Exp:cCampos%
							D0S.R_E_C_N_O_ RECNOD0S
					FROM %Table:D0S% D0S
					WHERE D0S.D0S_FILIAL = %xFilial:D0S%
					AND D0S.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D0S.%NotDel%
				EndSql
					
			Case nIndex == 1
				BeginSql Alias cAliasD0S
					SELECT D0S.D0S_IDUNIT,
							D0S.D0S_CODPRO,
							D0S.D0S_LOTECT,
							D0S.D0S_NUMLOT,
							D0S.D0S_QUANT,
							D0S.D0S_PRDORI,
							D0S.D0S_CODOPE,
							D0S.D0S_IDD0Q,
							D0S.D0S_ENDREC,
							%Exp:cCampos%
							D0S.R_E_C_N_O_ RECNOD0S
					FROM %Table:D0S% D0S
					WHERE D0S.D0S_FILIAL = %xFilial:D0S%
					AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
					AND D0S.D0S_PRDORI = %Exp:Self:GetPrdOri()%
					AND D0S.D0S_CODPRO = %Exp:Self:GetProduto()%
					AND %Exp:cWhere%
					AND D0S.%NotDel%
				EndSql
			Case nIndex == 2
				BeginSql Alias cAliasD0S
					SELECT D0S.D0S_IDUNIT,
							D0S.D0S_CODPRO,
							D0S.D0S_LOTECT,
							D0S.D0S_NUMLOT,
							D0S.D0S_QUANT,
							D0S.D0S_PRDORI,
							D0S.D0S_CODOPE,
							D0S.D0S_IDD0Q,
							D0S.D0S_ENDREC,
							%Exp:cCampos%
							D0S.R_E_C_N_O_ RECNOD0S
					FROM %Table:D0S% D0S
					WHERE D0S.D0S_FILIAL = %xFilial:D0S%
					AND D0S.D0S_IDD0Q = %Exp:Self:GetIdD0Q()%
					AND D0S.%NotDel%
				EndSql
			
		EndCase
		TCSetField(cAliasD0S,'D0S_QUANT','N',aD0S_QUANT[1],aD0S_QUANT[2])
		If (lRet := (cAliasD0S)->(!Eof()))
			// Dados do unitizador
			Self:SetIdUnit((cAliasD0S)->D0S_IDUNIT)
			Self:oUnitiz:LoadData(3)
			// Dados do produto
			Self:SetProduto((cAliasD0S)->D0S_CODPRO)
			Self:SetLoteCtl((cAliasD0S)->D0S_LOTECT)
			Self:SetNumLote((cAliasD0S)->D0S_NUMLOT)
			Self:SetPrdOri((cAliasD0S)->D0S_PRDORI)
			Self:oProdLote:LoadData()
			// Dados gerais
			Self:nQuant    := (cAliasD0S)->D0S_QUANT
			Self:cCodOpe   := (cAliasD0S)->D0S_CODOPE
			Self:cIdD0Q    := (cAliasD0S)->D0S_IDD0Q
			Self:cEndrec   := (cAliasD0S)->D0S_ENDREC
			If Self:lHasIdMvUn
				Self:cIdMovUni := (cAliasD0S)->D0S_IDMVUN
			EndIf
			Self:nRecno    := (cAliasD0S)->RECNOD0S
		EndIf
		(cAliasD0S)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0S)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetIdUnit(cIdUnit) CLASS WMSDTCMontagemUnitizadorItens
	Self:oUnitiz:SetIdUnit(cIdUnit)
Return
//-----------------------------------
METHOD SetProduto(cProduto) CLASS WMSDTCMontagemUnitizadorItens
	Self:oProdLote:SetProduto(cProduto)
Return
//-----------------------------------
METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCMontagemUnitizadorItens
	Self:oProdLote:SetLoteCtl(cLoteCtl)
Return
//-----------------------------------
METHOD SetNumLote(cNumLote) CLASS WMSDTCMontagemUnitizadorItens
	Self:oProdLote:SetNumLote(cNumLote)
Return
//-----------------------------------
METHOD SetQuant(nQuant) CLASS WMSDTCMontagemUnitizadorItens
	Self:nQuant := nQuant
Return
//-----------------------------------
METHOD SetPrdOri(cPrdOri) CLASS WMSDTCMontagemUnitizadorItens
	Self:oProdLote:SetPrdOri(cPrdOri)
Return
//-----------------------------------
METHOD SetCodOpe(cCodOpe) CLASS WMSDTCMontagemUnitizadorItens
	Self:cCodOpe := PadR(cCodOpe,Len(Self:cCodOpe))
Return
//-----------------------------------
METHOD SetIdD0Q(cIdD0Q) CLASS WMSDTCMontagemUnitizadorItens
	Self:cIdD0Q := PadR(cIdD0Q,Len(Self:cIdD0Q))
Return
//-----------------------------------
METHOD SetIdUnitA(cIdUnitAnt) CLASS WMSDTCMontagemUnitizadorItens
	Self:cIdUnitAnt := PadR(cIdUnitAnt,Len(Self:cIdUnitAnt))
Return
//-----------------------------------
METHOD SetUsaD0Q(lUsaD0Q) CLASS WMSDTCMontagemUnitizadorItens
	Self:lUsaD0Q := lUsaD0Q
Return
//-----------------------------------
METHOD SetBlkDoc(bGetDocto) CLASS WMSDTCMontagemUnitizadorItens
	Self:bGetDocto := bGetDocto
Return
//-----------------------------------
METHOD SetEndrec(cEndrec) CLASS WMSDTCMontagemUnitizadorItens
	Self:cEndrec := PadR(cEndrec,Len(Self:cEndrec))
Return
//-----------------------------------
METHOD SetIdMovUn(cIdMovUni) CLASS WMSDTCMontagemUnitizadorItens
	Self:cIdMovUni := PadR(cIdMovUni, IIf(Self:lHasIdMvUn,Len(Self:cIdMovUni),6))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetIdUnit() CLASS WMSDTCMontagemUnitizadorItens
Return Self:oUnitiz:GetIdUnit()
//-----------------------------------
METHOD GetProduto() CLASS WMSDTCMontagemUnitizadorItens
Return Self:oProdLote:GetProduto()
//-----------------------------------
METHOD GetLoteCtl() CLASS WMSDTCMontagemUnitizadorItens
Return Self:oProdLote:GetLoteCtl()
//-----------------------------------
METHOD GetNumLote() CLASS WMSDTCMontagemUnitizadorItens
Return Self:oProdLote:GetNumLote()
//-----------------------------------
METHOD GetQuant() CLASS WMSDTCMontagemUnitizadorItens
Return Self:nQuant
//-----------------------------------
METHOD GetPrdOri() CLASS WMSDTCMontagemUnitizadorItens
Return Self:oProdLote:GetPrdOri()
//-----------------------------------
METHOD GetCodOpe() CLASS WMSDTCMontagemUnitizadorItens
Return Self:cCodOpe
//-----------------------------------
METHOD GetIdD0Q() CLASS WMSDTCMontagemUnitizadorItens
Return Self:cIdD0Q
//-----------------------------------
METHOD GetIdUnitA() CLASS WMSDTCMontagemUnitizadorItens
Return Self:cIdUnitAnt
//-----------------------------------
METHOD GetEndrec() CLASS WMSDTCMontagemUnitizadorItens
Return Self:cEndrec
//-----------------------------------
METHOD GetIdMovUn() CLASS WMSDTCMontagemUnitizadorItens
Return Self:cIdMovUni
//-----------------------------------
METHOD GetRecno() CLASS WMSDTCMontagemUnitizadorItens
Return Self:nRecno
//-----------------------------------
METHOD GetErro() CLASS WMSDTCMontagemUnitizadorItens
Return Self:cErro
//-----------------------------------------------------------------------------
METHOD IsDad() CLASS WMSDTCMontagemUnitizadorItens
	Self:oProdLote:oProduto:oProdComp:SetProduto(Self:GetProduto())
Return Self:oProdLote:oProduto:oProdComp:IsDad()
//-----------------------------------------------------------------------------
METHOD GetArrProd() CLASS WMSDTCMontagemUnitizadorItens
Local aProduto := aClone(Self:oProdLote:oProduto:GetArrProd())
	If Len(aProduto) <= 1
		// Quanto foi informado um produto filho e o produto origem foi escolhido
		aProduto := {{Self:GetProduto(),1,Self:GetPrdOri()}}
	EndIf
Return aProduto
//-----------------------------------------------------------------------------
METHOD AssignD0S() CLASS WMSDTCMontagemUnitizadorItens
Local lRet := .T.

	// Criar um unitizador caso não exista
	If !Self:oUnitiz:RecordD0R()
		Self:cErro := Self:oUnitiz:GetErro()
		lRet := .F.
	EndIf
	// Seta as informações para a criação da D0S
	If lRet
		If !Self:RecordD0S()
			Self:cErro := STR0002 // Erro ao incluir D0S!
			lRet := .F.
		EndIf

		If Self:lUsaD0Q
			If lRet .And. !Self:UpdateD14()
				lRet := .F.
			EndIf
			If lRet
				// Atualização da demanda
				Self:UpdateD0Q()
			EndIf
		EndIf
	EndIf
Return lRet
//-----------------------------------------------------------------------------
METHOD RecordD0S() CLASS WMSDTCMontagemUnitizadorItens
Local lRet      := .T.
Local lAchou    := .F.
Local cIdMovUni := ""

	D0S->(DbSetOrder(1))
	// D0S_FILIAL+D0S_IDUNIT+D0S_PRDORI+D0S_CODPRO+D0S_LOTECT+D0S_NUMLOT+D0S_IDD0Q
	lAchou := D0S->(dbSeek(xFilial("D0S")+Self:GetIdUnit()+Self:GetPrdOri()+Self:GetProduto()+Self:GetLoteCtl()+Self:GetNumLote()+Self:GetIdD0Q()))
	Reclock('D0S',!lAchou)
	If !lAchou
		cIdMovUni   := GetSX8Num('D12', 'D12_IDMOV');ConfirmSx8()
		D0S->D0S_FILIAL := xFilial("D0S")
		D0S->D0S_IDUNIT := Self:GetIdUnit()
		D0S->D0S_CODPRO := Self:GetProduto()
		D0S->D0S_LOTECT := Self:GetLoteCtl()
		D0S->D0S_NUMLOT := Self:GetNumLote()
		D0S->D0S_QUANT  := Self:GetQuant()
		D0S->D0S_PRDORI := Self:GetPrdOri()
		D0S->D0S_CODOPE := Self:GetCodOpe()
		D0S->D0S_IDD0Q  := Self:GetIdD0Q()
		D0S->D0S_ENDREC := Self:GetEndrec()
		If Self:lHasIdMvUn
			D0S->D0S_IDMVUN := cIdMovUni
		EndIf
	Else
		D0S->D0S_QUANT  += Self:nQuant
	EndIf
	D0S->(MsUnLock())
	D0S->(DbCommit())
	// Carrega identificador do unitizador
	If Self:lHasIdMvUn
		Self:cIdMovUni := D0S->D0S_IDMVUN
	EndIf
	// Grava recno
	Self:nRecno := D0S->(Recno())
Return lRet
//-----------------------------------------------------------------------------
METHOD ExcludeD0S() CLASS WMSDTCMontagemUnitizadorItens
Local lRet := .T.
	D0S->(dbGoTo( Self:GetRecno() ))
	// Excluindo o registro do item no volume
	RecLock('D0S', .F.)
	D0S->(DbDelete())
	D0S->(MsUnlock())
Return lRet
//-----------------------------------------------------------------------------
METHOD UpdateD14(lEstorno,lTotal) CLASS WMSDTCMontagemUnitizadorItens
Local lRet        := .T.
Local aCopyD13    := {}
Local aAreaAnt    := GetArea()
Local aD13_QTDEST := TamSx3("D13_QTDEST")
Local oEstEnder   := WMSDTCEstoqueEndereco():New()
Local bGetDocto   := Nil
Local cAliasQr1   := Nil
Local cAliasQr2   := Nil
Local cAliasQr3   := Nil
Local cIdOpera    := ""
Local cIdUnitVz   := Space(TamSx3("D13_IDUNIT")[1])
Local nCnt        := 0

Default lEstorno := .F.
Default lTotal   := .T.

	cIdOpera := GetSx8Num('D12','D12_IDOPER')
	ConfirmSX8()
	// Dados Movto Estoque por Endereço WMS (D13)
	If  Self:lUsaD0Q .And. !Empty(Self:cIdD0Q)
		D0Q->(DbSetOrder(3)) // D0Q_FILIAL+D0Q_ID
		D0Q->(DbSeek(xFilial("D0Q")+Self:cIdD0Q))
		bGetDocto := {|oMovEstEnd|;
			oMovEstEnd:SetOrigem("D0S"),;
			oMovEstEnd:SetDocto(D0Q->D0Q_DOCTO),;
			oMovEstEnd:SetSerie(D0Q->D0Q_SERIE),;
			oMovEstEnd:SetCliFor(D0Q->D0Q_CLIFOR),;
			oMovEstEnd:SetLoja(D0Q->D0Q_LOJA),;
			oMovEstEnd:SetNumSeq(D0Q->D0Q_NUMSEQ),;
			oMovEstEnd:SetIdDCF(Self:cIdD0Q);
		}
	ElseIf ValType(Self:bGetDocto) == "B"
		bGetDocto := {|oMovEstEnd|;
			oMovEstEnd:SetOrigem("D0S"),;
			Eval(Self:bGetDocto,oMovEstEnd);
		}
	EndIf
	// Dados Estoque Endereço WMS (D14)
	oEstEnder:SetIdUnit(Iif(!lEstorno,"",Self:GetIdUnit()))
	// Endereço
	oEstEnder:oEndereco:SetArmazem(Self:oUnitiz:GetArmazem())
	oEstEnder:oEndereco:SetEnder(Self:oUnitiz:GetEnder())
	// Produto
	oEstEnder:oProdLote:SetArmazem(Self:oUnitiz:GetArmazem())
	oEstEnder:oProdLote:SetProduto(Self:GetProduto())
	oEstEnder:oProdLote:SetPrdOri(Self:GetPrdOri())
	oEstEnder:oProdLote:SetLoteCtl(Self:GetLoteCtl())
	oEstEnder:oProdLote:SetNumLote(Self:GetNumLote())
	oEstEnder:oProdLote:SetNumSer(Self:oProdLote:GetNumSer())
	oEstEnder:SetTipUni(Iif(!lEstorno,"",Self:oUnitiz:GetTipUni()))
	oEstEnder:SetQuant(Self:GetQuant())
	// Seta o bloco de código para informações do documento para o Kardex
	oEstEnder:SetBlkDoc(bGetDocto)
	// Seta o bloco de código para informações do movimento para o Kardex
	oEstEnder:SetBlkMov({|oMovEstEnd|;
		oMovEstEnd:SetIdMovto(Self:GetIdMovUn()),;
		oMovEstEnd:SetIdOpera(cIdOpera),;
		oMovEstEnd:SetlUsaCal(!lEstorno);
	})	
	// Retira o saldo do endereço informado, que está com unitizador em branco
	lRet := oEstEnder:UpdSaldo("999",.T./*lEstoque*/,.F./*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)

	If lRet
		// Atribui a quantidade ao mesmo endereço, porém com unitizador informado
		oEstEnder:SetTipUni(Iif(!lEstorno,Self:oUnitiz:GetTipUni(),""))
		oEstEnder:SetIdUnit(Iif(!lEstorno,Self:GetIdUnit(),""))
		lRet := oEstEnder:UpdSaldo("499",.T./*lEstoque*/,.F./*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
	EndIf
	If !lRet
		Self:cErro := oEstEnder:GetErro()
	EndIf
	// Verifica se movimento atualiza estoque
	If lRet .And. lEstorno .And. WmsX312118("D13","D13_USACAL")
		// Verifica se a quantidade estornada corresponde a quantidade total de um movimento
		cAliasQr1 := GetNextAlias()
		BeginSql Alias cAliasQr1
			SELECT D13.D13_IDOPER
			FROM %Table:D13% D13
			WHERE D13.D13_FILIAL = %xFilial:D13%
			AND D13.D13_IDDCF = %Exp:Self:cIdD0Q%
			AND D13.D13_IDMOV = %Exp:Self:GetIdMovUn()%
			AND D13.D13_IDUNIT = %Exp:cIdUnitVz%
			AND D13.D13_QTDEST = %Exp:Self:GetQuant()%
			AND D13.D13_USACAL <> '2'
			AND D13.%NotDel%
		EndSql
		If (cAliasQr1)->(!Eof())
			// Buscas os registros de kardex par
			cAliasQr2 := GetNextAlias()
			BeginSql Alias cAliasQr2
				SELECT D13.R_E_C_N_O_ RECNOD13
				FROM %Table:D13% D13
				WHERE D13.D13_FILIAL = %xFilial:D13%
				AND D13.D13_IDDCF = %Exp:Self:cIdD0Q%
				AND D13.D13_IDMOV = %Exp:Self:GetIdMovUn()%
				AND D13.D13_IDOPER = %Exp:(cAliasQr1)->D13_IDOPER%
				AND D13.D13_USACAL <> '2'
				AND D13.%NotDel%
			EndSql
			Do While (cAliasQr2)->(!Eof())
				D13->(dbGoTo((cAliasQr2)->RECNOD13))
				RecLock("D13",.F.)
				D13->D13_USACAL := '2'
				D13->(MsUnLock())
				(cAliasQr2)->(dbSkip())
			EndDo
			(cAliasQr2)->(dbCloseArea())
		Else
			nQtdSld := Self:GetQuant()
			cAliasQr2 := GetNextAlias()
			BeginSql Alias cAliasQr2
				SELECT D13.D13_IDOPER,
						D13.D13_QTDEST
				FROM %Table:D13% D13
				WHERE D13.D13_FILIAL = %xFilial:D13%
				AND D13.D13_IDDCF = %Exp:Self:cIdD0Q%
				AND D13.D13_IDMOV = %Exp:Self:GetIdMovUn()%
				AND D13.D13_IDUNIT = %Exp:cIdUnitVz%
				AND D13.D13_USACAL <> '2'
				AND D13.%NotDel%
			EndSql
			TCSetField(cAliasQr2,'D13_QTDEST','N',aD13_QTDEST[1],aD13_QTDEST[2])
			Do While (cAliasQr2)->(!Eof()) .And. nQtdSld > 0
				nQtdEst := (cAliasQr2)->D13_QTDEST
				cAliasQr3 := GetNextAlias()
				BeginSql Alias cAliasQr3
					SELECT D13.R_E_C_N_O_ RECNOD13
					FROM %Table:D13% D13
					WHERE D13.D13_FILIAL = %xFilial:D13%
					AND D13.D13_IDDCF = %Exp:Self:cIdD0Q%
					AND D13.D13_IDMOV = %Exp:Self:GetIdMovUn()%
					AND D13.D13_IDOPER = %Exp:(cAliasQr2)->D13_IDOPER%
					AND D13.D13_USACAL <> '2'
					AND D13.%NotDel%
				EndSql
				Do While (cAliasQr3)->(!Eof())
					D13->(dbGoTo((cAliasQr3)->RECNOD13))
					If QtdComp(nQtdSld) >= QtdComp(nQtdEst)
						RecLock("D13",.F.)
						D13->D13_USACAL := '2'
						D13->(MsUnLock())
					Else
						// Guarda o conteudo dos campos da D13 em uma variavel
						aCopyD13 := {}
						For nCnt := 1 To D13->(FCount())
							AAdd(aCopyD13, D13->(FieldGet(nCnt)))
						Next nCnt
						// Ajusta quantidade saldo
						RecLock("D13",.F.)
						D13->D13_QTDEST -= nQtdSld
						D13->(MsUnLock())
						// Cria novo movimento com base no original
						// com a quantidade estornada e indicando que
						// não utiliza no calculo de estoque
						cIdOpera := GetSx8Num('D12','D12_IDOPER')
						ConfirmSX8()
						
						RecLock("D13", .T.)
						For nCnt := 1 To Len(aCopyD13)
							FieldPut(nCnt, aCopyD13[nCnt])
						Next nCnt
						D13->D13_IDOPER := cIdOpera
						D13->D13_QTDEST := nQtdSld
						D13->D13_USACAL := '2'
						D13->(MsUnlock())
					EndIf
					(cAliasQr3)->(dbSkip())
				EndDo
				(cAliasQr3)->(dbCloseArea())
				(cAliasQr2)->(dbSkip())
				nQtdSld -= nQtdEst
			EndDo
			(cAliasQr2)->(dbCloseArea())
		EndIf
		(cAliasQr1)->(dbCloseArea())
	EndIf
	oEstEnder:Destroy()
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------------
METHOD UpdateD0Q(lEstorno) CLASS WMSDTCMontagemUnitizadorItens
Local lRet       := .T.
Local lAndamento := .F.
Local aAreaAnt   := GetArea()
Local aTamSX3    := TamSx3("D0Q_QUANT")
Local aProdD0Q   := {}
Local cAliasQry1 := Nil
Local cAliasQry2 := Nil
Default lEstorno := .F.

	D0Q->(dbSetOrder(3))
	// Busca os IDs de demandas utilizadas para montar o unitizador
	cAliasQry1 := GetNextAlias()
	BeginSql Alias cAliasQry1
		SELECT DISTINCT D0S.D0S_IDD0Q
		FROM %Table:D0S% D0S
		WHERE D0S.D0S_FILIAL = %xFilial:D0S%
		AND D0S.D0S_PRDORI = %Exp:Self:GetPrdOri()%
		AND D0S.D0S_LOTECT = %Exp:Self:GetLoteCtl()%
		AND D0S.D0S_NUMLOT = %Exp:Self:GetNumLote()%
		AND D0S.%NotDel%
	EndSql
	TcSetField(cAliasQry1,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry1)->(!Eof())
		aProdD0Q := {}
		// Busca os itens D0S que já estão no unitizador de uma determinada demanda
		cAliasQry2 := GetNextAlias()
		BeginSql Alias cAliasQry2
			SELECT SUM(CASE WHEN D0S.D0S_QUANT IS NULL THEN 0 ELSE D0S.D0S_QUANT END) D0S_QUANT
			FROM %Table:D0S% D0S
			WHERE D0S.D0S_FILIAL = %xFilial:D0S%
			AND D0S.D0S_PRDORI = %Exp:Self:GetPrdOri()%
			AND D0S.D0S_LOTECT = %Exp:Self:GetLoteCtl()%
			AND D0S.D0S_NUMLOT = %Exp:Self:GetNumLote()%
			AND D0S.D0S_IDD0Q = %Exp:(cAliasQry1)->D0S_IDD0Q%
			AND D0S.D0S_CODPRO = D0S.D0S_PRDORI
			AND D0S.%NotDel%
			GROUP BY D0S.D0S_CODPRO,D0S.D0S_PRDORI
			UNION ALL
			SELECT SUM(CASE WHEN D0S.D0S_QUANT IS NULL THEN 0 ELSE D0S.D0S_QUANT / D11.D11_QTMULT END) D0S_QUANT
			FROM %Table:D11% D11
			LEFT JOIN %Table:D0S% D0S
			ON D0S.D0S_FILIAL = %xFilial:D0S%
			AND D0S.D0S_PRDORI = D11.D11_PRDORI
			AND D0S.D0S_CODPRO = D11.D11_PRDCMP
			AND D0S.D0S_LOTECT = %Exp:Self:GetLoteCtl()%
			AND D0S.D0S_NUMLOT = %Exp:Self:GetNumLote()%
			AND D0S.D0S_IDD0Q =  %Exp:(cAliasQry1)->D0S_IDD0Q%
			AND D0S.%NotDel%
			WHERE D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRDORI = %Exp:Self:GetPrdOri()%
			AND D11.%NotDel%
			GROUP BY D11.D11_PRDCMP,D11.D11_PRDORI"
		EndSql
		TcSetField(cAliasQry2,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
		Do While (cAliasQry2)->(!Eof())
			aAdd(aProdD0Q,(cAliasQry2)->D0S_QUANT )
			(cAliasQry2)->(dbSkip())
		EndDo
		(cAliasQry2)->(dbCloseArea())
		If Len(aProdD0Q) > 0
			If Len(aProdD0Q) > 1
				// Ordena o array atribuindo a menor quantidade a primeira posição, para os produtos com componente
				aSort(aProdD0Q)
			EndIf
			If aProdD0Q[1] == 0
				lAndamento := (aScan(aProdD0Q,{|x| x > 0}) != 0)
			EndIf
			If D0Q->(dbSeek(xFilial("D0Q")+(cAliasQry1)->D0S_IDD0Q))
				RecLock("D0Q",.F.)
				D0Q->D0Q_QTDUNI := aProdD0Q[1]
				If QtdComp(D0Q->D0Q_QTDUNI) == QtdComp(0)
					If !lAndamento
						D0Q->D0Q_STATUS := "1" // Pendente
					Else
						// Foi iniciado a contagem de apenas uma parte do produto pai, sendo que D0Q só armazena o produto pai
						D0Q->D0Q_STATUS := "2" // Em Andamento
					EndIf
				ElseIf QtdComp(D0Q->D0Q_QTDUNI) > QtdComp(0) .And. QtdComp(D0Q->D0Q_QTDUNI) < QtdComp(D0Q->D0Q_QUANT)
					D0Q->D0Q_STATUS := "2" // Em Andamento
				Else
					D0Q->D0Q_STATUS := "3" // Finalizado
				EndIf
			EndIf
		EndIf
		(cAliasQry1)->(dbSkip())
	EndDo
	(cAliasQry1)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------------
METHOD MntPrdUni() CLASS WMSDTCMontagemUnitizadorItens
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aTamSX3    := TamSx3("D0Q_QUANT")
Local aProduto   := {}
Local cWhere     := ""
Local cAliasQry  := Nil
Local cProduto   := ""
Local cPrdOri    := ""
Local nQtAUni    := Self:GetQuant()
Local nQtdMult   := 0
Local nQtAUniAux := 0
Local nI         := 0
Local nQuant     := 0
	// Controle
	Self:SetIdUnitA(Self:GetIdUnit())
	// Valida unitizador
	If !Self:VldIdUnit()
		Return .F.
	EndIf
	Begin Transaction
		// Grava produtos do unitizador
		aProduto := Self:GetArrProd()
		For nI := 1 To Len(aProduto)
			cProduto := aProduto[nI][1]
			nQtdMult := aProduto[nI][2]
			cPrdOri  := aProduto[nI][3]
			nQuant   := 0
			nQtAUniAux := (nQtAUni * nQtdMult)
			cAliasQry := GetNextAlias()
			// Parâmetro Where
			cWhere := "%"
			If !Empty(Self:GetLoteCtl())
				cWhere += " AND D0Q.D0Q_LOTECT = '"+Self:GetLoteCtl()+"'"
			EndIf
			If !Empty(Self:GetNumLote())
				cWhere += " AND D0Q.D0Q_NUMLOT = '"+Self:GetNumLote()+"'"
			EndIf
			If !Empty(Self:oUnitiz:GetServico())
				cWhere += " AND D0Q.D0Q_SERVIC = '"+Self:oUnitiz:GetServico()+"'"
			EndIf
			cWhere += "%"
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D0Q.D0Q_ID,
						D0Q.D0Q_SERVIC,
						(D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) D0Q_SALDO
				FROM %Table:D0Q% D0Q
				WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
				AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
				AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
				AND D0Q.D0Q_CODPRO = %Exp:cProduto%
				AND D0Q.D0Q_PRDORI = %Exp:cPrdOri%
				AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
				AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
				%Exp:cWhere%
				AND D0Q.%NotDel%
				UNION ALL
				SELECT D0Q.D0Q_ID,
						D0Q.D0Q_SERVIC,
						((D0Q.D0Q_QUANT * D11.D11_QTMULT) - CASE WHEN SLD.D0S_QUANT IS NULL THEN 0 ELSE SLD.D0S_QUANT END) D0Q_SALDO
				FROM       %Table:D0Q% D0Q
				INNER JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = D0Q.D0Q_CODPRO
				AND D11.D11_PRDCMP = %Exp:cProduto%
				AND D11.%NotDel%
				LEFT JOIN (SELECT SUM(D0S.D0S_QUANT) D0S_QUANT, 
									D0S.D0S_CODPRO,
									D0S.D0S_PRDORI,
									D0S.D0S_LOTECT,
									D0S.D0S_NUMLOT,
									D0S.D0S_IDD0Q
							FROM %Table:D0S% D0S
							WHERE D0S.D0S_FILIAL = %xFilial:D0S%
							AND D0S.D0S_CODPRO = %Exp:cProduto%
							AND D0S.D0S_PRDORI = %Exp:cPrdOri%
							AND D0S.D0S_LOTECT = %Exp:Self:GetLoteCtl()%
							AND D0S.D0S_NUMLOT = %Exp:Self:GetNumLote()%
							AND D0S.%NotDel%
							GROUP BY D0S.D0S_CODPRO,
										D0S.D0S_PRDORI,
										D0S.D0S_LOTECT,
										D0S.D0S_NUMLOT,
										D0S.D0S_IDD0Q) SLD
				ON SLD.D0S_CODPRO = D11.D11_PRDCMP
				AND SLD.D0S_PRDORI = D11.D11_PRDORI
				AND SLD.D0S_LOTECT = D0Q.D0Q_LOTECT
				AND SLD.D0S_NUMLOT = D0Q.D0Q_NUMLOT
				AND SLD.D0S_IDD0Q = D0Q.D0Q_ID
				WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
				AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
				AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
				AND D0Q.D0Q_CODPRO = %Exp:cPrdOri%
				AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
				AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
				%Exp:cWhere%
				AND D0Q.%NotDel%
			EndSql
			TcSetField(cAliasQry,'D0Q_SALDO','N',aTamSX3[1],aTamSX3[2])
			Do While (cAliasQry)->(!Eof()) .And. nQtAUniAux > 0
				// Rateio da quantidade disponível na demanda
				If nQtAUniAux <= (cAliasQry)->D0Q_SALDO
					nQuant := nQtAUniAux
				Else
					nQuant := (cAliasQry)->D0Q_SALDO
				EndIf
				nQtAUniAux -= nQuant
	
				Self:SetQuant(nQuant)
	
				Self:SetProduto(cProduto)
				Self:SetPrdOri(cPrdOri)
				Self:SetIdD0Q((cAliasQry)->D0Q_ID)
				Self:oUnitiz:SetServico((cAliasQry)->D0Q_SERVIC)
				If !Self:AssignD0S()
					lRet := .F.
					Exit
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			If !lRet
				Exit
			EndIf
			(cAliasQry)->(dbCloseArea())
		Next nI
		If !lRet
			Disarmtransaction()
		EndIf
	End Transaction
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} VldIdUnit
Validações referentes ao ID do unitizador informado.
@author Squad WMS
@since 01/06/2017
@version 1.0
@param cTipUni, caracter, (Parâmetro por referência que retorna o tipo do unitizador)
@param lEstorno, lógico, (Indica se é uma validação de estorno)
@param nIndex, numérico, (Indice para LoadData da classe de montagem de unitizador)
@param lVldExist, lógico, (Indica se irá validar a existência do unitizador)
@param lVldMont, lógico, (Indica se irá validar a montagem de um novo unitizador)
/*/
//----------------------------------------
METHOD VldIdUnit(nAcao,cTipUni,lEstorno) CLASS WMSDTCMontagemUnitizadorItens
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local oEstEnder := Nil
Local cAliasD0R := Nil
Local cAliasD0Q := Nil

Default nAcao    := 1 // 1 - Montagem Demanda;2 - Montagem Conferência; 3 - Geração ordem de servico ; 4 - Movimento Interna
Default cTipUni  := Padr("", TamSx3("D0R_CODUNI")[1])
Default lEstorno := .F.
	If Empty(Self:GetIdUnit())
		lRet := .F.
	EndIf
	If lRet
		// Valida se o unitizador possui caractere especial
		lRet := WmsVlStr(Self:GetIdUnit())
	EndIf

	If lRet
		// Verifica se existe etiqueta do unitizador
		If !Self:oUnitiz:oEtiqUnit:LoadData()
			Self:cErro := Self:oUnitiz:oEtiqUnit:GetErro()
			lRet := .F.
		EndIf
	EndIf
	If lRet
		Do Case
			// Montagem demanda
			// Montagem Conferência
			Case nAcao == 1 .Or. nAcao == 2
				If !Self:oUnitiz:LoadData()
					If lEstorno
						Self:cErro := STR0004 // Unitizador informado inválido!
						lRet := .F.
					Else
						If Self:oUnitiz:oEtiqUnit:GetIsUsed()
							oEstEnder := WMSDTCEstoqueEndereco():New()
							oEstEnder:SetIdUnit(Self:GetIdUnit())
							nQtdSaldo := oEstEnder:ConsultSld(.T.,.F.,.F.,.F.)
							If QtdComp(nQtdSaldo) > QtdComp(0)
								Self:cErro := WmsFmtMsg(STR0025,{{"[VAR01]",Self:GetIdUnit()}}) // Etiqueta do Unitizador [VAR01] utilizada por outro processo!
							Else
								Self:cErro := WmsFmtMsg(STR0029,{{"[VAR01]",Self:GetIdUnit()}}) // Etiqueta do unitizador [VAR01] encerrada!
							EndIf
							lRet := .F.
						EndIf
					EndIf
				Else
					If Self:oUnitiz:GetStatus() ==  '3'
						Self:cErro := STR0017 // Unitizador já possui Ordem de Serviço gerada!
						lRet := .F.
					ElseIf Self:oUnitiz:GetStatus() == '4'
						oEstEnder := WMSDTCEstoqueEndereco():New()
						oEstEnder:SetIdUnit(Self:GetIdUnit())
						nQtdSaldo := oEstEnder:ConsultSld(.T.,.F.,.F.,.F.)
						If QtdComp(nQtdSaldo) > QtdComp(0)
							Self:cErro := STR0026 // Unitizador já endereçado!
						Else
							Self:cErro := WmsFmtMsg(STR0029,{{"[VAR01]",Self:GetIdUnit()}}) // Etiqueta do unitizador [VAR01] encerrada!
						EndIf
						lRet := .F.
					ElseIf Self:oUnitiz:GetStatus() == '5' .And. nAcao == 1
						Self:cErro := STR0027 // Unitizador em conferência!
						lRet := .F.
					ElseIf Self:oUnitiz:GetStatus() == '6'
						Self:cErro := STR0028 // Unitizador aguardando classificação NF!
						lRet := .F.
					EndIf
					If lRet .And. !lEstorno
						If Self:oUnitiz:GetStatus() == '2' .And. nAcao == 2
							Self:cErro := WmsFmtMsg(STR0025,{{"[VAR01]",Self:GetIdUnit()}}) // Etiqueta do Unitizador [VAR01] utilizada por outro processo!
							lRet := .F.
						Else
							If Self:oUnitiz:oEtiqUnit:GetIsUsed() .And. !(Self:GetIdUnit() == Self:GetIdUnitA())
								Self:cErro := ""
								lRet := WmsQuestion(WmsFmtMsg(STR0021,{{"[VAR01]",Self:GetIdUnit()}}),STR0010)
							EndIf
						EndIf
					EndIf
				EndIf
				If lRet 
					If !Empty(Self:oUnitiz:GetArmazem())
						cAliasD0R := GetNextAlias()
						BeginSql Alias cAliasD0R
							SELECT D0R.D0R_LOCAL,
									D0R.D0R_ENDER
							FROM %Table:D0R% D0R
							WHERE D0R.D0R_FILIAL = %xFilial:D0R%
							AND D0R.D0R_IDUNIT = %Exp:Self:GetIdUnit()%
							AND (D0R.D0R_LOCAL <> %Exp:Self:oUnitiz:GetArmazem()%
								OR (D0R.D0R_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
								AND D0R.D0R_ENDER <> %Exp:Self:oUnitiz:GetEnder()% ))
							AND D0R.%NotDel%
							UNION ALL
							SELECT D14.D14_LOCAL D0R_LOCAL,
									D14.D14_ENDER D0R_ENDER
							FROM %Table:D14% D14
							WHERE D14.D14_FILIAL = %xFilial:D14%
							AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
							AND (D14.D14_LOCAL <> %Exp:Self:oUnitiz:GetArmazem()%
								OR (D14.D14_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
								AND D14.D14_ENDER <> %Exp:Self:oUnitiz:GetEnder()% ))
							AND D14.%NotDel%
						EndSql
						If (cAliasD0R)->(!EoF())
							Self:cErro := WmsFmtMsg(STR0019,{{"[VAR01]",Self:GetIdUnit()},{"[VAR02]",(cAliasD0R)->D0R_LOCAL},{"[VAR03]",(cAliasD0R)->D0R_ENDER}}) //O unitizador [VAR01] em uso no armazém [VAR02] e/ou endereço [VAR03].
							lRet := .F.
						EndIf
						(cAliasD0R)->(DbCloseArea())
					EndIf
					If lRet .And. !lEstorno
						cAliasD0Q := GetNextAlias()
						BeginSql Alias cAliasD0Q
							SELECT D0Q.D0Q_ID
							FROM %Table:D0S% D0S
							INNER JOIN %Table:D0Q% D0Q
							ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
							AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
							AND D0Q.D0Q_ORIGEM <> %Exp:Self:oUnitiz:GetOrigem()%
							AND D0Q.%NotDel%
							WHERE D0S.D0S_FILIAL = %xFilial:D0S%
							AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
							AND D0S.%NotDel%
						EndSql
						If (cAliasD0Q)->(!EoF())
							Self:cErro := WmsFmtMsg(STR0024,{{"[VAR01]",Self:GetIdUnit()}}) //Unitizador [VAR01] em uso por outro tipo de documento.
							lRet := .F.
						EndIf
						(cAliasD0Q)->(DbCloseArea())
					EndIf
				EndIf
			// Geração da O.S
			Case nAcao == 3
				If !Self:oUnitiz:LoadData(3)
					If Self:oUnitiz:oEtiqUnit:GetIsUsed()
						oEstEnder := WMSDTCEstoqueEndereco():New()
						oEstEnder:SetIdUnit(Self:GetIdUnit())
						nQtdSaldo := oEstEnder:ConsultSld(.T.,.F.,.F.,.F.)
						If QtdComp(nQtdSaldo) > QtdComp(0)
							Self:cErro := WmsFmtMsg(STR0025,{{"[VAR01]",Self:GetIdUnit()}}) // Etiqueta do Unitizador [VAR01] utilizada por outro processo!
						Else
							Self:cErro := WmsFmtMsg(STR0018,{{"[VAR01]",Self:GetIdUnit()}}) // Etiqueta do unitizador [VAR01] encerrada!
						EndIf
					Else
						// Valida a existencia do código do unitizador
						Self:cErro := WmsFmtMsg(STR0018,{{"[VAR01]",Self:GetIdUnit()}}) // Unitizador [VAR01] ainda não foi montado!
					EndIf
					lRet := .F.
				Else
					If Self:oUnitiz:GetStatus() ==  '1'
						Self:cErro := WmsFmtMsg(STR0018,{{"[VAR01]",Self:GetIdUnit()}}) // Unitizador [VAR01] ainda não foi montado!
						lRet := .F.
					ElseIf Self:oUnitiz:GetStatus() ==  '3'
						Self:cErro := STR0017 // Unitizador já possui Ordem de Serviço gerada!
						lRet := .F.
					ElseIf Self:oUnitiz:GetStatus() == '4'
						oEstEnder := WMSDTCEstoqueEndereco():New()
						oEstEnder:SetIdUnit(Self:GetIdUnit())
						nQtdSaldo := oEstEnder:ConsultSld(.T.,.F.,.F.,.F.)
						If QtdComp(nQtdSaldo) > QtdComp(0)
							Self:cErro := STR0026 // Unitizador já endereçado!
						Else
							Self:cErro := WmsFmtMsg(STR0029,{{"[VAR01]",Self:GetIdUnit()}}) // Etiqueta do unitizador [VAR01] encerrada!
						EndIf
						lRet := .F.
					ElseIf Self:oUnitiz:GetStatus() == '5'
						Self:cErro := STR0027 // Unitizador em conferência!
						lRet := .F.
					ElseIf Self:oUnitiz:GetStatus() == '6'
						Self:cErro := STR0028 // Unitizador aguardando classificação NF!
						lRet := .F.
					EndIf
				EndIf
			// Movimento interna
			// Transferência
			// Transferência de Devolução
			Case nAcao == 4 .Or. nAcao == 5
				If Self:oUnitiz:LoadData(3)
					If !(Self:oUnitiz:GetStatus() == '4')
						Self:cErro := WmsFmtMsg(STR0025,{{"[VAR01]",Self:GetIdUnit()}}) // Etiqueta do Unitizador [VAR01] utilizada por outro processo!
						lRet := .F.
					EndIf
				EndIf
				If lRet
					If Self:oUnitiz:oEtiqUnit:GetIsUsed()
						oEstEnder := WMSDTCEstoqueEndereco():New()
						oEstEnder:SetIdUnit(Self:oUnitiz:GetIdUnit())
						nQtdSaldo := oEstEnder:ConsultSld(.T.,.F.,.F.,.F.)
						If QtdComp(nQtdSaldo) == QtdComp(0)
							Self:cErro := WmsFmtMsg(STR0029,{{"[VAR01]",Self:GetIdUnit()}}) // Etiqueta do unitizador [VAR01] encerrada!
							lRet := .F.
						EndIf
					EndIf
				EndIf
		EndCase
	EndIf
	If !lRet
		Self:SetIdUnit("")
		Self:oUnitiz:SetIdDCF("")
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------------
METHOD VldTipUni() CLASS WMSDTCMontagemUnitizadorItens
Local lRet := .T.
	If !(lRet := Self:oUnitiz:oTipUnit:LoadData())
		Self:cErro := STR0005 // Código do unitizador inválido!
		Self:oUnitiz:SetTipUni("")
	EndIf
Return lRet
//-----------------------------------------------------------------------------
METHOD VldPrdUni(lEstorno) CLASS WMSDTCMontagemUnitizadorItens
Local lRet       := .T.
Local lEstFis    := .T.
Local lContinua  := .F.
Local aZonPrd    := {}
Local aAreaAnt   := GetArea()
Local aEstPrd    := {}
Local aPrdMnt    := {}
Local aProduto   := {}
Local cProduto   := ""
Local cProdMnt   := ""
Local cEstFis    := ""
Local cQuery     := ""
Local cAliasQry  := Nil
Local cInZonArm  := ""
Local nI         := 0
Local nY         := 0

Default lEstorno := .F.

	// Carrega informações do produto e array de componentes
	Self:oProdLote:LoadData()
	// Carrega informações do tipo do unitizador
	Self:oUnitiz:oTipUnit:LoadData()
	If !lEstorno
		// Validação de bloqueio do produto. Não é possível informar um produto com o cadastro bloqueado.
		If Self:oProdLote:oProduto:oProdGen:IsMsBlQl()
			Self:cErro := STR0006 // Produto bloqueado ou não existe (B1_MSBLQL)!
			lRet := .F.
		EndIf
		//Verifica se o tipo do unitizador permite unitizadores mistos
		If lRet .And. !Self:oUnitiz:oTipUnit:CanUniMis() .And. (Self:IsDad() .Or. Self:oUnitiz:IsMultPrd(Self:GetProduto(),,.T.))
			Self:cErro := WmsFmtMsg(STR0031,{{"[VAR01]",Self:oUnitiz:oTipUnit:GetTipUni()}}) //Tipo de unitizador [VAR01] não permite montagem de unitizador misto.
			lRet := .F.
		EndIf
		If lRet .And. Self:oUnitiz:UniHasItem() .And. Self:oUnitiz:IsMultPrd(Self:GetProduto(),,.T.)
			// Carrega o unitizador quando ele já existe
			Self:oUnitiz:LoadData()
			// Carrega estruturas que compartilham produtos do primeiro produto
			aProduto := Self:GetArrProd()
			cProdMnt := aProduto[1][1]
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT DC3.DC3_TPESTR
				FROM %Table:DC3% DC3
				WHERE DC3.DC3_FILIAL = %xFilial:DC3%
				AND DC3.DC3_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
				AND DC3.DC3_CODPRO = %Exp:cProdMnt%
				AND DC3.DC3_TIPEND = '4'
				AND DC3.DC3_EMBDES = '1'
				AND DC3.%NotDel%
			EndSql
			Do While (cAliasQry)->(!Eof())
				Aadd(aEstPrd,(cAliasQry)->DC3_TPESTR)
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
			If !Empty(aEstPrd)
				// Carrega produtos já pertencentes ao unitizador
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT DISTINCT D0S.D0S_CODPRO
					FROM %Table:D0S% D0S
					WHERE D0S.D0S_FILIAL = %xFilial:D0S%
					AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
					AND D0S.%NotDel%
				EndSql
				Do While (cAliasQry)->(!Eof())
					Aadd(aPrdMnt,(cAliasQry)->D0S_CODPRO)
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
				// Carrega produtos que serão incluídos no unitizador
				For nI := 2 To Len(aProduto)
					cProduto := aProduto[nI][1]
					If AsCan(aPrdMnt,{|x| x == cProduto}) == 0
						Aadd(aPrdMnt,cProduto)
					EndIf
				Next nI
				// Verificar por estrutura se todos os produtos já incluídos e os demais à incluir
				// Possuem uma estrutura física em comum que compartilha produtos
				
				lContinua := .F.
				For nI := 1 To Len(aEstPrd)
					lEstFis   := .T.
					cEstFis := aEstPrd[nI]
					For nY := 1 To Len(aPrdMnt)
						cProduto := aPrdMnt[nY]
						// Valida se produto possui estrutura física em comum
						cAliasQry := GetNextAlias()
						BeginSql Alias cAliasQry
							SELECT 1
							FROM %Table:DC3% DC3
							WHERE DC3.DC3_FILIAL = %xFilial:DC3%
							AND DC3.DC3_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
							AND DC3.DC3_CODPRO = %Exp:cProduto%
							AND DC3.DC3_TPESTR = %Exp:cEstFis%
							AND DC3.DC3_TIPEND = '4'
							AND DC3.DC3_EMBDES = '1'
							AND DC3.%NotDel%
						EndSql
						If(cAliasQry)->(Eof())
							lEstFis := .F.
							Exit
						EndIf
						(cAliasQry)->(dbCloseArea())
					Next nY
					If lEstFis
						lContinua := .T.
						Exit
					EndIf
				Next nI
			EndIf
			// Não encontrou nenhuma estrutura em comum que compartilha produtos
			If !lContinua
				Self:cErro := WmsFmtMsg(STR0007,{{"[VAR01]",Self:oUnitiz:GetArmazem()},{"[VAR02]",cProdMnt},{"[VAR03]",Self:GetIdUnit()}}) // Local/Produto [VAR01]/[VAR02] não possui estrutura física correspondente a sequência de abastecimento dos produtos do unitizador [VAR03] ou não compartilha produtos.
				lRet := .F.
			EndIf
			// Deve validar se os produtos a serem incluídos no unitizador 
			// Possuem uma zona de armazenagem em comum entre eles
			If lRet
				cProdMnt := aProduto[1][1]
				// Carrega as zonas de armazenagem principal do primeiro produto
				SB5->(DbSetOrder(1)) //B5_FILIAL, B5_COD
				SB5->(DbSeek(xFilial("SB5")+cProdMnt))
				AAdd(aZonPrd,SB5->B5_CODZON)
				// Carrega as zonas de armazenagem alternativas do primeiro produto
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT DCH.DCH_CODZON
					FROM %Table:DCH% DCH
					WHERE DCH.DCH_FILIAL = %xFilial:DCH%
					AND DCH.DCH_CODPRO = %Exp:cProdMnt%
					AND DCH.DCH_CODZON <> %Exp:SB5->B5_CODZON%
					AND DCH.%NotDel%
				EndSql
				Do While (cAliasQry)->(!Eof())
					Aadd(aZonPrd,(cAliasQry)->DCH_CODZON)
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
				// Concatena as zonas de armazenagem
				AEval(aZonPrd,{|x| cInZonArm += "'"+x+"',"})
				// Retira a ultima virgula
				cInZonArm := "%"+SubStr(cInZonArm,1,Len(cInZonArm)-1)+"%"
				For nY := 1 To Len(aPrdMnt)
					cProduto := aPrdMnt[nY]
					// Avalia a zona principal do produto
					SB5->(DbSetOrder(1)) //B5_FILIAL, B5_COD
					SB5->(DbSeek(xFilial("SB5")+cProduto))
					// Se a zona de armazenagem principal não está contida no array do primeiro produto
					If AScan(aZonPrd,{|x| x == SB5->B5_CODZON}) == 0
						// Verifica se para o produto existe alguma zona de armazenagem alternativa
						cAliasQry := GetNextAlias()
						BeginSql Alias cAliasQry
							SELECT DCH.DCH_CODZON
							FROM %Table:DCH% DCH
							WHERE DCH.DCH_FILIAL = %xFilial:DCH%
							AND DCH.DCH_CODPRO = %Exp:cProduto%
							AND DCH.DCH_CODZON IN ( %Exp:cInZonArm% )
							AND DCH.%NotDel%
						EndSql
						If (cAliasQry)->(Eof())
							Self:cErro := WmsFmtMsg(STR0030,{{"[VAR01]",cProdMnt},{"[VAR02]",Self:GetIdUnit()}}) // Produto [VAR01] não possui zona de armazenagem comum aos demais produtos do unitizador [VAR02].
							lRet := .F.
							Exit
						EndIf
						(cAliasQry)->(dbCloseArea())
					EndIf
				Next nY
			EndIf
		Else
			// Carrega o objeto do endereço quando for um novo unitizador
			Self:oUnitiz:oEndereco:LoadData()
		EndIf
	Else
		// Verifica se o produto está contido no unitizador para realizar o estorno
		aProduto := Self:GetArrProd()
		For nI := 1 To Len(aProduto)
			cProduto := aProduto[nI][1]
			cPrdOri  := aProduto[nI][3]

			cQuery :=        "% 1"
			cQuery +=    " FROM "+RetSqlname("D0S")+" D0S"
			cQuery +=   " WHERE D0S.D0S_FILIAL = '"+xFilial("D0S")+"'"
			cQuery +=     " AND D0S.D0S_IDUNIT = '"+Self:GetIdUnit()+"'"
			cQuery +=     " AND D0S.D0S_PRDORI = '"+cPrdOri+"'"
			cQuery +=     " AND D0S.D0S_CODPRO = '"+cProduto+"'"
			If !Empty(Self:GetLoteCtl())
				cQuery += " AND D0S.D0S_LOTECT = '"+Self:GetLoteCtl()+"'"
			EndIf
			If !Empty(Self:GetNumLote())
				cQuery += " AND D0S.D0S_NUMLOT = '"+Self:GetNumLote()+"'"
			EndIf
			cQuery +=     " AND D0S.D_E_L_E_T_ = ' '"
			cQuery += "%"
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT %Exp:cQuery%
			EndSql
			If (cAliasQry)->(Eof())
				Self:cErro := WmsFmtMsg(STR0008,{{"[VAR01]",cProduto},{"[VAR02]",Self:GetIdUnit()}}) // Componente [VAR01] não está contido no unitizador [VAR02].
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		Next nI
	EndIf
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
METHOD VldPrdCmp(lEstorno) CLASS WMSDTCMontagemUnitizadorItens
Local aAreaAnt   := GetArea()
Local cAliasQry  := Nil
Local cPrdOriAnt := ""
Local cWhere     := ""
Local nPrdOri    := 0
Local nOpcao     := 0
Default lEstorno := .F.
	// Verifica se foi informado um produto pai, e sai do método sem validar a demanda
	If Self:IsDad()
		Self:SetPrdOri(Self:GetProduto())
		RestArea(aAreaAnt)
		Return Nil
	EndIf

	cAliasQry := GetNextAlias()
	If !lEstorno
		// Parâmetro Where
		cWhere := "%"
		If !Empty(Self:GetLoteCtl())
			cWhere += " AND D0Q.D0Q_LOTECT = '"+Self:GetLoteCtl()+"'"
		EndIf
		If !Empty(Self:GetNumLote())
			cWhere += " AND D0Q.D0Q_NUMLOT = '"+Self:GetNumLote()+"'"
		EndIf
		cWhere += "%"
		If !Empty(Self:oUnitiz:GetServico())
			// Seleciona o produto como componente ou normal com base em D0Qs disponíveis
			BeginSql Alias cAliasQry
				SELECT D0Q.D0Q_PRDORI PRDORI
				FROM %Table:D0Q% D0Q
				WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
				AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
				AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
				AND D0Q.D0Q_CODPRO = %Exp:Self:GetProduto()%
				AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
				AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
				AND D0Q.D0Q_SERVIC = %Exp:Self:oUnitiz:GetServico()%
				AND NOT EXISTS (SELECT 1
								FROM %Table:D11% D11
								WHERE D11.D11_FILIAL = %xFilial:D11%
								AND D11.D11_PRODUT = D0Q.D0Q_CODPRO
								AND D11.D11_PRDORI = D0Q.D0Q_CODPRO
								AND D11.%NotDel% )
				AND D0Q.%NotDel%
				%Exp:cWhere%
				UNION ALL
				SELECT D11.D11_PRDORI PRDORI
				FROM %Table:D0Q% D0Q
				INNER JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = D0Q.D0Q_CODPRO
				AND D11.D11_PRDCMP = %Exp:Self:GetProduto()%
				AND D11.%NotDel%
				WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
				AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
				AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
				AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
				AND D0Q.D0Q_SERVIC = %Exp:Self:oUnitiz:GetServico()%
				AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
				AND D0Q.%NotDel%
				%Exp:cWhere%
			EndSql
		Else
			// Seleciona o produto como componente ou normal com base em D0Qs disponíveis
			BeginSql Alias cAliasQry
				SELECT D0Q.D0Q_PRDORI PRDORI
				FROM %Table:D0Q% D0Q
				WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
				AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
				AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
				AND D0Q.D0Q_CODPRO = %Exp:Self:GetProduto()%
				AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
				AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
				AND NOT EXISTS (SELECT 1
								FROM %Table:D11% D11
								WHERE D11.D11_FILIAL = %xFilial:D11%
								AND D11.D11_PRODUT = D0Q.D0Q_CODPRO
								AND D11.D11_PRDORI = D0Q.D0Q_CODPRO
								AND D11.%NotDel% )
				AND D0Q.%NotDel%
				%Exp:cWhere%
				UNION ALL
				SELECT D11.D11_PRDORI PRDORI
				FROM %Table:D0Q% D0Q
				INNER JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = D0Q.D0Q_CODPRO
				AND D11.D11_PRDCMP = %Exp:Self:GetProduto()%
				AND D11.%NotDel%
				WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
				AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
				AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
				AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
				AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
				AND D0Q.%NotDel%
				%Exp:cWhere%
			EndSql
		EndIf
	Else
		cWhere := "%"
		If !Empty(Self:GetLoteCtl())
			cWhere += " AND D0S.D0S_LOTECT = '"+Self:GetLoteCtl()+"'"
		EndIf
		If !Empty(Self:GetNumLote())
			cWhere += " AND D0S.D0S_NUMLOT = '"+Self:GetNumLote()+"'"
		EndIf
		cWhere += "%"
		// Seleciona os produtos da D0S já montada
		BeginSql Alias cAliasQry
			SELECT DISTINCT D0S.D0S_PRDORI PRDORI
			FROM %Table:D0S% D0S
			WHERE D0S.D0S_FILIAL = %xFilial:D0S%
			AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
			AND D0S.D0S_CODPRO = %Exp:Self:GetProduto()%
			AND D0S.%NotDel%
			%Exp:cWhere%
		EndSql
	EndIf
	(cAliasQry)->(dbEval( {|| Iif(cPrdOriAnt!=PRDORI,nPrdOri++,), cPrdOriAnt := PRDORI }))
	// Pergunta o que deve considerar
	If nPrdOri > 1
		nOpcao := WmsMessage(STR0009+":",STR0010,4,.T.,{STR0011,STR0012}) // Considerar produto como: // Montagem Unitizador // Componente // Produto
	EndIf
	(cAliasQry)->(dbGoTop())
	Do While (cAliasQry)->(!Eof())
		If nPrdOri > 1
			// Quando "Componente", pula aquele que é produto
			If nOpcao == 1 .And. (cAliasQry)->PRDORI == Self:GetProduto()
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
			// Quando "Produto", pula aquele que é componente
			If nOpcao == 2 .And. (cAliasQry)->PRDORI != Self:GetProduto()
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		EndIf
		Self:SetPrdOri((cAliasQry)->PRDORI)
		Exit
	EndDo
	If Empty(Self:GetPrdOri())
		Self:SetPrdOri(Self:GetProduto())
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return Nil

//-----------------------------------------------------------------------------
METHOD QtdPrdUni(lOnlyUnit,lRastro) CLASS WMSDTCMontagemUnitizadorItens
Local lLoteCtl  := !Empty(Self:GetLoteCtl())
Local lSubLote  := !Empty(Self:GetNumLote())
Local aAreaAnt  := GetArea()
Local aTamSX3   := TamSx3('D0S_QUANT')
Local cWhere    := ""
Local cAliasQry := Nil

Default lOnlyUnit := .F.
Default lRastro   := .T.

	Self:SetQuant(0)
	If !lRastro
		lLoteCtl := .F.
		lSubLote := .F.
	EndIf
	If !lOnlyUnit
		Self:SetQuant(Self:GetSldDisp())
	Else
		// Busca o registro no unitizador para validar a quantidade de estorno
		// Parâmetro Where
		cWhere := "%"
		If lLoteCtl
			cWhere += " AND D0S.D0S_LOTECT = '"+Self:GetLoteCtl()+"'"
		EndIf
		If lSubLote
			cWhere += " AND D0S.D0S_NUMLOT = '"+Self:GetNumLote()+"'"
		EndIf
		cWhere += "%"
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SUM(D0S.D0S_QUANT) PRD_QUANT
			FROM %Table:D0S% D0S
			WHERE D0S.D0S_FILIAL = %xFilial:D0S%
			AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
			AND D0S.D0S_PRDORI = %Exp:Self:GetPrdOri()%
			AND D0S.D0S_CODPRO = %Exp:Self:GetProduto()%
			AND D0S.%NotDel%
			%Exp:cWhere%
		EndSql
		TcSetField(cAliasQry,'PRD_QUANT','N',aTamSX3[1],aTamSX3[2])
		If (cAliasQry)->(!Eof())
			Self:SetQuant((cAliasQry)->PRD_QUANT)
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return Nil

//-----------------------------------------------------------------------------
METHOD VldQtdSld(nQtde,lEstorno) CLASS WMSDTCMontagemUnitizadorItens
Local lRet      := .T.
// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local aAreaAnt  := GetArea()
Local aProduto  := {}
Local cProduto  := Self:GetProduto() // Salva o produto
Local cPrdOri   := Self:GetPrdOri()  // Salva o produto
Local cAliasQry := Nil
Local nToler1UM := SuperGetMV("MV_NTOL1UM",.F.,0)
Local nQtdNorma := 0
Local nSldDisp  := 0
Local nI        := 0

Default lEstorno := .F.
	If Empty(nQtde) .Or. QtdComp(nQtde) == 0
		lRet := .F.
	EndIf
	If lRet
		If !lEstorno
			// Apenas se não for multiplos produtos dentro do unitizador
			If Self:oUnitiz:GetCtrNor() .And. !Self:IsDad() .And. !Self:oUnitiz:IsMultPrd(Self:GetProduto(),,.T.)
				// Se a estrutura for do tipo produção ou qualidade, considera a norma da DOCA, visto que
				// não é obrigatório possuir estas estruturas na sequência de abastecimento do produto
				If Self:oUnitiz:oEndereco:GetTipoEst() == 7 .Or. Self:oUnitiz:oEndereco:GetTipoEst() == 8
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT DC3.DC3_TPESTR
						FROM %Table:DC3% DC3
						INNER JOIN %Table:DC8% DC8
						ON DC8.DC8_FILIAL = %xFilial:DC8%
						AND DC8.DC8_CODEST = DC3.DC3_TPESTR
						AND DC8.DC8_TPESTR = '5'
						AND DC8.%NotDel%
						WHERE DC3.DC3_FILIAL = %xFilial:DC3%
						AND DC3.DC3_CODPRO = %Exp:Self:GetProduto()%
						AND DC3.DC3_LOCAL  = %Exp:Self:oUnitiz:GetArmazem()%
						AND DC3.%NotDel%
					EndSql
					If !(cAliasQry)->(Eof())
						nQtdNorma := DLQtdNorma(Self:GetProduto(),Self:oUnitiz:GetArmazem(),(cAliasQry)->DC3_TPESTR,,.F.)
					EndIf
					(cAliasQry)->(DbCloseArea())
				Else
					// Busca a norma do produto
					nQtdNorma := DLQtdNorma(Self:GetProduto(),Self:oUnitiz:GetArmazem(),Self:oUnitiz:oEndereco:GetEstFis(),,.F.)
				EndIf
				// Força para calcular a quantidade do produto no unitizador
				Self:QtdPrdUni(.T.,.F.)
				If QtdComp(nQtdNorma) < QtdComp(Self:GetQuant()+nQtde) .And.;
					QtdComp(Abs((Self:GetQuant()+nQtde)-nQtdNorma)) > QtdComp(nToler1UM)
					Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",cValtoChar(nQtde)}}) // Quantidade informada ([VAR01]) ultrapassa a norma do produto.
					lRet := .F.
				EndIf
			EndIf
			If lRet .And. Self:lUsaD0Q
				aProduto := Self:GetArrProd()
				For nI := 1 To Len(aProduto)
					Self:SetProduto(aProduto[nI][1])
					Self:SetPrdOri(aProduto[nI][3])
					// Busca o saldo disponível com base na D0Q e carrega o saldo na propriedade Self:nQuant
					nSldDisp := Self:GetSldDisp()
	
					If QtdComp(nQtde * aProduto[nI][2]) > QtdComp(nSldDisp) .And.;
						QtdComp(Abs((nQtde * aProduto[nI][2]) - nSldDisp)) > QtdComp(nToler1UM)
						Self:cErro := WmsFmtMsg(STR0014,{{"[VAR01]",cValtoChar(nSldDisp)},{"[VAR02]",aProduto[nI][1]}}) // Quantidade de saldo disponível ([VAR01]) menor que a quantidade solicitada para o produto [VAR02].
						lRet := .F.
						Exit
					EndIf
				Next nI
			EndIf
			If lRet
				// Restaura as informações de produto
				Self:SetProduto(cProduto)
				Self:SetPrdOri(cPrdOri)
				// Calcula a ocupação do unitizador
				Self:oUnitiz:CalcOcupac(Nil,.T.)
				lRet := Self:CalcPesUni(nQtde)
			EndIf
		Else
			Self:QtdPrdUni(.T.,.F.)
			If QtdComp(nQtde) > QtdComp(Self:GetQuant()) .And.;
				QtdComp(Abs(Self:GetQuant()-nQtde)) > QtdComp(nToler1UM)
				Self:cErro := WmsFmtMsg(STR0016,{{"[VAR01]",cValtoChar(Self:GetQuant())}}) // Quantidade unitizada ([VAR01]) menor que a quantidade solicitada para estorno.
				lRet := .F.
			EndIf
		EndIf
	EndIf
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
METHOD GetSldDisp() CLASS WMSDTCMontagemUnitizadorItens
Local aAreaAnt  := GetArea()
Local aTamSX3   := TamSx3("D0Q_QUANT")
Local cWhere    := ""
Local cWhereAux := ""
Local cAliasQry := Nil
Local nSldDisp  := 0
	// Busca o saldo disponível em demanda de unitização
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:GetLoteCtl())
		cWhere += " AND D0Q.D0Q_LOTECT = '"+Self:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:GetNumLote())
		cWhere += " AND D0Q.D0Q_NUMLOT = '"+Self:GetNumLote()+"'"
	EndIf
	cWhere += "%"
	cWhereAux := "%"
	If !Empty(Self:GetLoteCtl())
		cWhereAux += " AND D0S.D0S_LOTECT = '"+Self:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:GetNumLote())
		cWhereAux += " AND D0S.D0S_NUMLOT = '"+Self:GetNumLote()+"'"
	EndIf
	cWhereAux += "%"
	cAliasQry := GetNextAlias()
	If !Empty(Self:oUnitiz:GetServico())
		BeginSql Alias cAliasQry
			SELECT SUM(D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) D0Q_SALDO
			FROM %Table:D0Q% D0Q
			WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
			AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
			AND D0Q.D0Q_CODPRO = %Exp:Self:GetProduto()%
			AND D0Q.D0Q_PRDORI = D0Q.D0Q_CODPRO
			AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
			AND D0Q.D0Q_SERVIC = %Exp:Self:oUnitiz:GetServico()%
			AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
			AND D0Q.%NotDel%
			%Exp:cWhere%
			GROUP BY D0Q.D0Q_FILIAL // Este GROUP BY é para só trazer resultado se encontrar registro
			UNION ALL
			SELECT (SUM(D0Q.D0Q_QUANT * D11.D11_QTMULT) - CASE WHEN  SLD.D0S_QUANT IS NULL THEN 0 ELSE SLD.D0S_QUANT END) D0Q_SALDO
			FROM %Table:D0Q% D0Q
			INNER JOIN %Table:D11% D11
			ON D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRDORI = D0Q.D0Q_CODPRO
			AND D11.D11_PRDCMP = %Exp:Self:GetProduto()%
			AND D11.%NotDel%
			LEFT JOIN ( SELECT SUM(D0S.D0S_QUANT) D0S_QUANT, 
								D0S.D0S_CODPRO,
								D0S.D0S_PRDORI,
								D0S.D0S_LOTECT,
								D0S.D0S_NUMLOT
						FROM %Table:D0S% D0S
						INNER JOIN %Table:D0Q% D0Q
						ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
						AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
						AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
						AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
						AND D0Q.D0Q_CODPRO = D0S.D0S_PRDORI
						AND D0Q.D0Q_LOTECT = D0S.D0S_LOTECT
						AND D0Q.D0Q_NUMLOT = D0S.D0S_NUMLOT
						AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
						AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
						AND D0Q.%NotDel%
						WHERE D0S.D0S_FILIAL = %xFilial:D0S%
						AND D0S.D0S_CODPRO = %Exp:Self:GetProduto()%
						AND D0S.D0S_PRDORI = %Exp:Self:GetPrdOri()%
						AND D0S.%NotDel%
						%Exp:cWhereAux%
						GROUP BY D0S.D0S_CODPRO,
									D0S.D0S_PRDORI,
									D0S.D0S_LOTECT,
									D0S.D0S_NUMLOT ) SLD
			ON SLD.D0S_CODPRO = D11.D11_PRDCMP
			AND SLD.D0S_PRDORI = D11.D11_PRDORI
			AND SLD.D0S_LOTECT = D0Q.D0Q_LOTECT
			AND SLD.D0S_NUMLOT = D0Q.D0Q_NUMLOT
			WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_LOCAL  = %Exp:Self:oUnitiz:GetArmazem()%
			AND D0Q.D0Q_ENDER  = %Exp:Self:oUnitiz:GetEnder()%
			AND D0Q.D0Q_CODPRO = %Exp:Self:GetPrdOri()%
			AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
			AND D0Q.D0Q_SERVIC = %Exp:Self:oUnitiz:GetServico()%
			AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0"
			AND D0Q.%NotDel%
			%Exp:cWhere%
			GROUP BY D0Q.D0Q_FILIAL, // Este GROUP BY é para só trazer resultado se encontrar registro
						SLD.D0S_QUANT
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT SUM(D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) D0Q_SALDO
			FROM %Table:D0Q% D0Q
			WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
			AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
			AND D0Q.D0Q_CODPRO = %Exp:Self:GetProduto()%
			AND D0Q.D0Q_PRDORI = D0Q.D0Q_CODPRO
			AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
			AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
			AND D0Q.%NotDel%
			%Exp:cWhere%
			GROUP BY D0Q.D0Q_FILIAL // Este GROUP BY é para só trazer resultado se encontrar registro
			UNION ALL
			SELECT (SUM(D0Q.D0Q_QUANT * D11.D11_QTMULT) - CASE WHEN  SLD.D0S_QUANT IS NULL THEN 0 ELSE SLD.D0S_QUANT END) D0Q_SALDO
			FROM %Table:D0Q% D0Q
			INNER JOIN %Table:D11% D11
			ON D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRDORI = D0Q.D0Q_CODPRO
			AND D11.D11_PRDCMP = %Exp:Self:GetProduto()%
			AND D11.%NotDel%
			LEFT JOIN ( SELECT SUM(D0S.D0S_QUANT) D0S_QUANT, 
								D0S.D0S_CODPRO,
								D0S.D0S_PRDORI,
								D0S.D0S_LOTECT,
								D0S.D0S_NUMLOT
						FROM %Table:D0S% D0S
						INNER JOIN %Table:D0Q% D0Q
						ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
						AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
						AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
						AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
						AND D0Q.D0Q_CODPRO = D0S.D0S_PRDORI
						AND D0Q.D0Q_LOTECT = D0S.D0S_LOTECT
						AND D0Q.D0Q_NUMLOT = D0S.D0S_NUMLOT
						AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
						AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
						AND D0Q.%NotDel%
						WHERE D0S.D0S_FILIAL = %xFilial:D0S%
						AND D0S.D0S_CODPRO = %Exp:Self:GetProduto()%
						AND D0S.D0S_PRDORI = %Exp:Self:GetPrdOri()%
						AND D0S.%NotDel%
						%Exp:cWhereAux%
						GROUP BY D0S.D0S_CODPRO,
									D0S.D0S_PRDORI,
									D0S.D0S_LOTECT,
									D0S.D0S_NUMLOT ) SLD
			ON SLD.D0S_CODPRO = D11.D11_PRDCMP
			AND SLD.D0S_PRDORI = D11.D11_PRDORI
			AND SLD.D0S_LOTECT = D0Q.D0Q_LOTECT
			AND SLD.D0S_NUMLOT = D0Q.D0Q_NUMLOT
			WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_LOCAL  = %Exp:Self:oUnitiz:GetArmazem()%
			AND D0Q.D0Q_ENDER  = %Exp:Self:oUnitiz:GetEnder()%
			AND D0Q.D0Q_CODPRO = %Exp:Self:GetPrdOri()%
			AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
			AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0"
			AND D0Q.%NotDel%
			%Exp:cWhere%
			GROUP BY D0Q.D0Q_FILIAL, // Este GROUP BY é para só trazer resultado se encontrar registro
						SLD.D0S_QUANT
		EndSql	
	EndIf
	TcSetField(cAliasQry,'D0Q_SALDO','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		nSldDisp := (cAliasQry)->D0Q_SALDO
	Else
		nSldDisp := 0
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return nSldDisp

//-----------------------------------------------------------------------------
METHOD GetPesoItem(nQtde) CLASS WMSDTCMontagemUnitizadorItens
Local aAreaAnt  := GetArea()
Local aTamSX3   := TamSx3("D0S_QUANT")
Local cAliasQry := GetNextAlias()
Local nPesoItem := 0

Default nQtde := 1
	// Calcula o produto de peso e quantidade do produto
	BeginSql Alias cAliasQry
		SELECT (SUM((SB1.B1_PESO + CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D') THEN (SB5.B5_ECPESOE / SB1.B1_CONV)
				ELSE  SB5.B5_ECPESOE END ) * ((CASE WHEN PRD_QTMULT IS NULL THEN 1 ELSE PRD_QTMULT END) * %Exp:nQtde% )))  D0S_PESUNI // Peso do produto vezes a quantidade
		FROM (  SELECT %Exp:Self:GetPrdOri()% PRD_PRDORI,
						%Exp:Self:GetProduto()% PRD_CODPRO,
						1 PRD_QTMULT
				FROM %Table:SB1% SB1
				WHERE SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = %Exp:Self:GetPrdOri()%
				AND NOT EXISTS (SELECT 1
								FROM %Table:D11% D11B
								WHERE D11B.D11_FILIAL = %xFilial:D11%
								AND D11B.D11_PRODUT = %Exp:Self:GetProduto()%
								AND D11B.%NotDel% )
				AND SB1.%NotDel%
				UNION ALL
				SELECT D11C.D11_PRDORI,
						D11C.D11_PRDCMP,
						D11C.D11_QTMULT
				FROM %Table:D11% D11C
				WHERE D11C.D11_FILIAL = %xFilial:D11%
				AND D11C.D11_PRODUT = %Exp:Self:GetProduto()%
				AND D11C.D11_PRDORI = %Exp:Self:GetPrdOri()%
				AND D11C.%NotDel% ) PRD
		INNER JOIN %Table:SB1% SB1
		ON SB1.B1_FILIAL = %xFilial:SB1%
		AND SB1.B1_COD = PRD.PRD_CODPRO
		AND SB1.%NotDel%
		INNER JOIN %Table:SB5% SB5
		ON SB5.B5_FILIAL = %xFilial:SB5%
		AND SB1.B1_FILIAL = %xFilial:SB1%
		AND SB5.B5_COD = SB1.B1_COD
		AND SB5.%NotDel%
	EndSql
	TcSetField(cAliasQry,'D0S_PESUNI','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		nPesoItem := ((cAliasQry)->D0S_PESUNI)
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return nPesoItem

//-----------------------------------------------------------------------------
METHOD EstPrdUni(aProdutos,lTotal) CLASS WMSDTCMontagemUnitizadorItens
Local lRet      := .T.
Local aExclD0S  := {}
Local aAreaD0S  := D0S->(GetArea())
Local nY        := 0
Local nRecnoAnt := Self:GetRecno()

Default lTotal := .F.

	Begin Transaction
		If lRet
			D0S->(DbSetOrder(1)) // D0S_FILIAL+D0S_IDUNIT+D0S_PRDORI+D0S_CODPRO+D0S_LOTECT+D0S_NUMLOT+D0S_IDD0Q
			// Gravando os itens do volume
			For nY := 1  To Len(aProdutos)
				Self:SetProduto(aProdutos[nY][1])
				Self:SetLoteCtl(aProdutos[nY][2])
				Self:SetNumLote(aProdutos[nY][3])
				Self:SetQuant(aProdutos[nY][4])
				Self:SetPrdOri(aProdutos[nY][5])
				Self:SetIdD0Q(aProdutos[nY][6])
				Self:SetIdMovUn(aProdutos[nY][7])
				If D0S->(dbSeek(xFilial("D0S")+Self:GetIdUnit()+Self:GetPrdOri()+Self:GetProduto()+Self:GetLoteCtl()+Self:GetNumLote()+Self:GetIdD0Q()))
					RecLock("D0S", .F.)
					If !lTotal
						// Se sobrar quantidade deve apenas diminuir a quantidade
						D0S->D0S_QUANT -= Self:GetQuant()
					Else
						D0S->D0S_QUANT := 0
					EndIf
					If QtdComp(D0S->D0S_QUANT) == QtdComp(0)
						aAdd(aExclD0S, D0S->(Recno()))
					EndIf
					D0S->(MsUnLock())
	
					// Retorna as quantidade do unitizador para o endereço
					If lRet .And. !Self:UpdateD14(.T.,lTotal)
						lRet := .F.
					EndIf
					// Atualiza a quantidade e status das demandas utilizadas
					If lRet
						Self:UpdateD0Q(.T.)
					EndIf
				EndIf
			Next nY
			// Exclui a D0S após atualizar D14 e D0Q
			For nY := 1 To Len(aExclD0S)
				Self:nRecno := aExclD0S[nY]
				Self:ExcludeD0S()
			Next nY
			// Retorna o recno original da classe
			Self:nRecno := nRecnoAnt
			If !lTotal
				lTotal := D0S->(!dbSeek(xFilial("D0S")+Self:GetIdUnit()))
			EndIf
			If lTotal
				If Self:oUnitiz:LoadData(1)
					lRet := Self:oUnitiz:ExcludeD0R()
				EndIf
			EndIf
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	RestArea(aAreaD0S)
Return lRet

//-----------------------------------------------------------------------------
METHOD UpdEndrec(lProduto) CLASS WMSDTCMontagemUnitizadorItens
Local aAreaD0S := D0S->(GetArea())
Local cSeek    := xFilial("D0S")+Self:GetIdUnit()

Default lProduto := .T.
	// Indica atualização do produto do unitizador
	If lProduto
		cSeek += Self:GetPrdOri()+Self:GetProduto()+Self:GetLoteCtl()+Self:GetNumLote()
	EndIf
	D0S->(dbSetOrder(1))
	D0S->(dbSeek(cSeek))
	Do While D0S->(!Eof()) .And. D0S->(D0S_FILIAL+D0S_IDUNIT + Iif(lProduto,D0S_PRDORI+D0S_CODPRO+D0S_LOTECT+D0S_NUMLOT,"")) == cSeek
		RecLock("D0S",.F.)
		D0S->D0S_ENDREC := Self:cEndrec // 1=Sim;2=Não
		D0S->(MsUnlock())
		D0S->(dbSkip())
	EndDo
	D0S->(dbCloseArea())
	RestArea(aAreaD0S)
Return

//-----------------------------------------------------------------------------
METHOD CalcPesUni(nQtde) CLASS WMSDTCMontagemUnitizadorItens
Local lRet := .T.
	// Capacidade Máxima do unitizador - o Peso dos produtos contidos no unitizador, deve ser menor que o peso do item que está sendo adicionado
	If lRet .And. ((Self:oUnitiz:GetCapMax() - Self:oUnitiz:GetPeso()) < Self:GetPesoItem(nQtde))
		Self:cErro := WmsFmtMsg(STR0015,{{"[VAR01]",cValtoChar(Self:oUnitiz:GetCapMax())}}) // Peso do produto ultrapassa a capacidade máxima ([VAR01]) do tipo do unitizador!
		lRet := .F.
	EndIf
Return lRet