#Include "Totvs.ch"
#Include "WMSBCCEnderecamento.ch"
#Define CLRF  Chr(13)+Chr(10)
#Define RELDETEST 7
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0005
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0005()
Return Nil
//---------------------------------------------
/*/{Protheus.doc} WMSBCCEnderecamento
Classe para analise e geração de movimentos
de endereçamento e endereçamento crossdocking
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
CLASS WMSBCCEnderecamento FROM WMSDTCMovimentosServicoArmazem

	// Declaracao das propriedades da Classe
	DATA oEstFis
	DATA lZonaPrd
	DATA lZonaAlt
	DATA lPriorSA
	DATA lMultPkg
	DATA nLimtPkg
	DATA aNivEndOri // Array que irá conter os níveis do primeiro endereço encontrado
	DATA nQuant     // Quantidade da ordem de serviço já atendida
	DATA nQuantPkg
	DATA aLogEnd
	DATA lTrfCol

	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD SetOrdServ(oOrdServ)
	METHOD SetLogEnd(aLogEnd)
	METHOD SetTrfCol(lTrfCol)
	METHOD ExecFuncao()
	METHOD VldGeracao()
	METHOD ProcSeqEnd()
	METHOD FindEndSld()
	METHOD FindNivSBE(cLocal,cLocaliz)
	METHOD VldProcPkg()
	METHOD ProcEstFis(lCapEstr)
	METHOD AddMsgLog()
	METHOD QryEndEst(nCapEstru)
	METHOD QryEndSel(cEndereco)
	METHOD Destroy()
ENDCLASS

METHOD New() CLASS WMSBCCEnderecamento
	_Super:New()
	Self:oEstFis    := WMSDTCEstruturaFisica():New()
	Self:lZonaPrd   := .T.
	Self:lZonaAlt   := .F.
	// MV_WMSZNSA
	// .T. = Utiliza zona de armazenagem alternativa somente se for a ultima sequencia de abastecimento
	// .F. = Utiliza zona de armazenagem alternativa para cada estrutura da sequencia de abastecimento
	Self:lPriorSA   := SuperGetMV('MV_WMSZNSA',.F.,.F.)
	Self:lMultPkg   := (SuperGetMV('MV_WMSMULP',.F.,'N')=='S') // Utiliza multiplos pickings
	Self:nLimtPkg   := SuperGetMV('MV_WMSNRPO',.F.,10) // Limite de enderecos picking ocupados
	Self:aNivEndOri := {}
	Self:nQuantPkg  := 0
	Self:aLogEnd    := Nil
	Self:lTrfCol    := .F.
Return

METHOD Destroy() CLASS WMSBCCEnderecamento
	//Mantido para compatibilidade
Return Nil

METHOD SetOrdServ(oOrdServ) CLASS WMSBCCEnderecamento
	Self:oOrdServ := oOrdServ
	Self:oMovServic := Self:oOrdServ:oServico
	//--Carrega dados endereço origem
	Self:oMovEndOri:SetArmazem(Self:oOrdServ:oOrdEndOri:GetArmazem())
	Self:oMovEndOri:SetEnder(Self:oOrdServ:oOrdEndOri:GetEnder())
	Self:oMovEndOri:LoadData()
	Self:oMovEndOri:ExceptEnd()
	//--Carrega dados endereço destino
	Self:oMovEndDes:SetArmazem(Self:oOrdServ:oOrdEndDes:GetArmazem())
	Self:oMovEndDes:SetEnder(Self:oOrdServ:oOrdEndDes:GetEnder())
	Self:oMovEndDes:LoadData()
	Self:oMovEndDes:ExceptEnd()
Return

METHOD ExecFuncao() CLASS WMSBCCEnderecamento
Local lRet  := .T.
	If Self:VldGeracao()
		lRet := Self:ProcSeqEnd()
	Else
		lRet := .F.
	EndIf
Return lRet

METHOD SetLogEnd(aLogEnd) CLASS WMSBCCEnderecamento
	Self:aLogEnd := aLogEnd
Return

METHOD SetTrfCol(lTrfCol) CLASS WMSBCCEnderecamento
	Self:lTrfCol := lTrfCol
Return

METHOD VldGeracao() CLASS WMSBCCEnderecamento
Local lRet      := .T.
	If !Self:ChkEndOri(.T.)
		lRet := .F.
	EndIf
Return lRet

METHOD ProcSeqEnd() CLASS WMSBCCEnderecamento
Local lRet       := .T.
Local aSeqAbast  := {}
Local aSeqAbPkg  := {}
Local nSeqAbast  := 0
	Self:lZonaPrd := .T.
	Self:lZonaAlt := .F.
	// Carrega Estoque por endereco
	Self:oEstEnder:ClearData()
	// Carrega dados endereco
	Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
	Self:oEstEnder:oEndereco:SetEnder("")
	// Carrega dados produto
	Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
	Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
	Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
	Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
	Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
	Self:oEstEnder:oProdLote:SetNumSer(Self:oMovPrdLot:GetProduto())
	Self:oEstEnder:oProdLote:LoadData()
	// Carrega sequencias de abastecimento
	Self:oMovSeqAbt:SetArmazem(Self:oMovEndDes:GetArmazem())
	Self:oMovSeqAbt:SetProduto(Self:oMovPrdLot:GetProduto())
	Self:oMovSeqAbt:SetServico(Self:oMovServic:GetServico())
	If !Empty(Self:oMovEndDes:GetEnder())
		// Inclui somente a sequencia de abastecimento do endereço
		Self:oMovSeqAbt:SetEstFis(Self:oMovEndDes:GetEstFis())
		Self:oMovSeqAbt:FindSeqAbt()
	Else
		If Self:oMovServic:ChkArmaz() .Or. Self:oMovServic:ChkTransf()
			Self:oMovSeqAbt:SeqAbast(1)
		Else
			Self:oMovSeqAbt:SeqAbast(5)
		EndIf
	EndIf
	aSeqAbast := Self:oMovSeqAbt:GetArrSeqA()
	If Len(aSeqAbast) <= 0
		Self:cErro += WmsFmtMsg(STR0004,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndDes:GetArmazem()}}) // Produto/Armazém [VAR01]/[VAR02] não possui sequência de abastecimento cadastrada (DC3).
		lRet := .F.
	EndIf
	nSeqAbast := 1
	If lRet
		AAdd(Self:aLogEnd,{Self:oOrdServ:GetDocto(),Self:oOrdServ:GetSerie(),Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetDesc(),Self:oMovPrdLot:GetLoteCtl(),Self:nQuant,{}})
	EndIf
	// Realiza o endereçamento dos produtos até que a quantidade seja zero
	Do While lRet .And. nSeqAbast <= Len(aSeqAbast) .And. QtdComp(Self:nQuant) > QtdComp(0)
		// Busca dados Sequencia abastecimento

		Self:oMovSeqAbt:SetOrdem(aSeqAbast[nSeqAbast][1])
		If !Self:oMovSeqAbt:LoadData()
			lRet := .F.
			Self:cErro := Self:oMovSeqAbt:GetErro()
			Exit
		EndIf
		If Empty(Self:oMovSeqAbt:GetTipoEnd())
			lRet := .F.
			Self:cErro := STR0016 // Tipo endereçamento não definido para o produto na sequencia de abastecimento!
			Exit
		EndIf

		// Busca dados Estrutura Fisica
		Self:oEstFis:SetEstFis(Self:oMovSeqAbt:GetEstFis())
		Self:oEstFis:LoadData()
		// Atribui informacoes estoque por endereco
		Self:oEstEnder:oEndereco:SetEstFis(Self:oMovSeqAbt:GetEstFis())
		Self:oEstEnder:SetCodNor(Self:oMovSeqAbt:GetCodNor())
		// Atribui informacoes endereco destino
		Self:oMovEndDes:SetEstFis(Self:oMovSeqAbt:GetEstFis())
		// Endereçamento normal não é considerada estrutura de Box/Doca
    		If (Self:oMovServic:ChkCross()) .Or. ((Self:oMovServic:ChkArmaz() .Or. Self:oMovServic:ChkTransf()) .And. Self:oEstFis:GetTipoEst() != "5")
			AAdd(Self:aLogEnd[Len(Self:aLogEnd),RELDETEST],{WmsFmtMsg(STR0005,{{"[VAR01]",Self:oMovEndDes:GetArmazem()},{"[VAR02]",Self:oEstFis:GetEstFis()},{"[VAR03]",Self:oEstFis:GetDesEst()}}),Self:oMovSeqAbt:GetTipoEnd(),{}}) // Armazém [VAR01] - Busca de endereço na estrutura [VAR02] - [VAR03]
			// Procura endereço alvo com saldo no produto para armazenagem proxima a esse endereço
			Self:FindEndSld()
			// Procura endereço estrutura picking
			If Self:oEstFis:GetTipoEst() == "2"
				If AScan(aSeqAbPkg,aSeqAbast[nSeqAbast]) <= 0
					AAdd(aSeqAbPkg,aSeqAbast[nSeqAbast])
				EndIf

				If Self:VldProcPkg()
					lRet := Self:ProcEstFis()
				EndIf
			Else
				lRet := Self:ProcEstFis()
			EndIf
		EndIf
		nSeqAbast++
		// Se prioriza a sequencia de abastecimento e chegou no fim, volta para pesquisar as alternativas
		If Self:lPriorSA .And. nSeqAbast > Len(aSeqAbast) .And. !Self:lZonaAlt
			nSeqAbast := 1
			Self:lZonaPrd := .F.
			Self:lZonaAlt := .T.
		EndIf
		If QtdComp(Self:nQuant) > QtdComp(0)
			// Limpa o endereço para não ficar com sugeira do estrutura física anterior
			Self:oMovEndDes:SetEnder("")
		EndIf
	EndDo
	// Se restou saldo menor que uma caixa e ao menos uma das estruturas possuia endereçamento mínimo
	If lRet .And. QtdComp(Self:nQuant) > QtdComp(0)
		If QtdComp(Self:nQuant) < QtdComp(IIf(Self:oMovPrdLot:GetTipConv() == "D" .And. Self:oMovPrdLot:GetConv()>0,Self:oMovPrdLot:GetConv(),0))
			nSeqAbast := 1
			Self:lZonaPrd := .T.
			Self:lZonaAlt := .F.
			If lRet
				AAdd(Self:aLogEnd,{Self:oOrdServ:GetDocto(),Self:oOrdServ:GetSerie(),Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetDesc(),Self:oMovPrdLot:GetLoteCtl(),Self:nQuant,{}})
			EndIf
			// Realiza o endereçamento dos produtos até que a quantidade seja zero
			Do While lRet .And. nSeqAbast <= Len(aSeqAbPkg) .And. QtdComp(Self:nQuant) > QtdComp(0)
				// Busca dados Sequencia abastecimento
				Self:oMovSeqAbt:SetOrdem(aSeqAbPkg[nSeqAbast][1])
				If !Self:oMovSeqAbt:LoadData()
					lRet := .F.
					Self:cErro := Self:oMovSeqAbt:GetErro()
					Exit
				EndIf
				If Empty(Self:oMovSeqAbt:GetTipoEnd())
					lRet := .F.
					Self:cErro := STR0016 // Tipo endereçamento não definido para o produto na sequencia de abastecimento!
					Exit
				EndIf

				// Busca dados Estrutura Fisica
				Self:oEstFis:SetEstFis(Self:oMovSeqAbt:GetEstFis())
				Self:oEstFis:LoadData()
				// Atribui informacoes estoque por endereco
				Self:oEstEnder:oEndereco:SetEstFis(Self:oMovSeqAbt:GetEstFis())
				Self:oEstEnder:SetCodNor(Self:oMovSeqAbt:GetCodNor())
				// Atribui informacoes endereco destino
				Self:oMovEndDes:SetEstFis(Self:oMovSeqAbt:GetEstFis())
				// Endereçamento normal não é considerada estrutura de Box/Doca
				If (Self:oMovServic:ChkCross()) .Or. ((Self:oMovServic:ChkArmaz() .Or. Self:oMovServic:ChkTransf()) .And. Self:oEstFis:GetTipoEst() != "5")
					AAdd(Self:aLogEnd[Len(Self:aLogEnd),RELDETEST],{WmsFmtMsg(STR0005,{{"[VAR01]",Self:oMovEndDes:GetArmazem()},{"[VAR02]",Self:oEstFis:GetEstFis()},{"[VAR03]",Self:oEstFis:GetDesEst()}}),Self:oMovSeqAbt:GetTipoEnd(),{}}) // Armazém [VAR01] - Busca de endereço na estrutura [VAR02] - [VAR03]
					lRet := Self:ProcEstFis(.F.)
				EndIf
				nSeqAbast++
				// Se prioriza a sequencia de abastecimento e chegou no fim, volta para pesquisar as alternativas
				If Self:lPriorSA .And. nSeqAbast > Len(aSeqAbast) .And. !Self:lZonaAlt
					nSeqAbast := 1
					Self:lZonaPrd := .F.
					Self:lZonaAlt := .T.
				EndIf
				If QtdComp(Self:nQuant) > QtdComp(0)
					// Limpa o endereço para não ficar com sugeira do estrutura física anterior
					Self:oMovEndDes:SetEnder("")
				EndIf
			EndDo
		EndIf
	EndIf
	// Se restou saldo a endereçar retorna falso
	If lRet .And. QtdComp(Self:nQuant) > QtdComp(0)
		Self:cErro += WmsFmtMsg(STR0007,{{"[VAR01]",Str(Self:nQuant)}}) // Não foi possível endereçar toda a quantidade. Saldo restante ([VAR01]).
		Self:oOrdServ:HasLogEnd(.T.)
		lRet := .F.
	EndIf
Return lRet


METHOD ProcEstFis(lCapEstru) CLASS WMSBCCEnderecamento
Local aAreaAnt   := GetArea()
Local aRetPE     := NIL
Local lRet       := .T.
Local lFoundPkg  := .F.
Local lChkUnit   := .T.
Local nTipoPerc  := 0
Local nCapEstru  := 0
Local nNormaEst  := 0
Local nCapEnder  := 0
Local nQtdNorma  := 0
Local nSaldoLot  := 0
Local nSaldoEnd  := 0
Local nSaldoRF   := 0
Local nSldEndPrd := 0
Local nSldEndOut := 0
Local nSldRFPrd  := 0
Local nSldRFOut  := 0
Local cEndDest   := ""
Local cOrdSeq    := "00"
Local cOrdPrd    := "00"
Local cOrdSld    := "00"
Local cOrdMov    := "00"
Local nQtdEnd    := 0
Local cUltEndPer := ""
Local lWMSNrPo   := ExistBlock('WMSNRPO')
Local lWmsVlEnd  := ExistBlock('WMSVLEND')
Local lWMSCAPMX  := ExistBlock('WMSCAPMX')
Local nCapNewEnd := ""

Default lCapEstru := .T. // Indica se a capacidade da estrutura deverá ser considerada

	// Calcula a norma somente uma vez para a estrtura fisica, pois todos os endereços
	// devem posuir a mesma norma, exceto quando possui percentual de ocupação
	nCapEstru := Iif(lCapEstru,DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oEstFis:GetEstFis(),,,,If(DCF->DCF_ORIGEM == "SD1",Self:OORDSERV:CCODNORMA,"")),999999999)
	nNormaEst := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oEstFis:GetEstFis(), /*cDesUni*/, .F.,,If(DCF->DCF_ORIGEM == "SD1",Self:OORDSERV:CCODNORMA,"")) // Considerar somente a norma
	If QtdComp(nCapEstru) <= 0
		Self:AddMsgLog(Self:oEstFis:GetEstFis(),"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,Self:nQuant,0,STR0017) // Estrutura com capacidade zerada.
		Self:cErro := Self:oEstFis:GetEstFis()+" - "+STR0017
		RestArea(aAreaAnt)
		Return .F.
	EndIf

	cAliasSBE = Self:QryEndEst(nCapEstru)
	If (cAliasSBE)->(Eof())
		//Valida se a não localização do endereço esta ligado ao numero limite de picking configurado no processo
		//de multiplos picking  
		If lWMSNrPo 
			Self:nLimtPkg := ExecBlock('WMSNRPO',.F.,.F.,{Self:nLimtPkg,Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetLoteCtl()})
		EndIf
		If Self:lMultPkg .And.  Self:oEstFis:GetTipoEst() == "2" .And. Self:nLimtPkg <= Self:nQuantPkg
			Self:AddMsgLog(Self:oEstFis:GetEstFis(),"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,Self:nQuant,0,WmsFmtMsg(Iif(lWMSNRPO, STR0021,"")+STR0022,{{"[VAR01]",Str(Self:nLimtPkg)}})) //{PE WMSNRPO:} "Endereço indisponivel.Limite picking ocupado ([VAR01])."
			
		Else
			Self:AddMsgLog(Self:oEstFis:GetEstFis(),"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,Self:nQuant,0,STR0008) // Não encontrou nenhum endereço disponível.
			(cAliasSBE)->(dbCloseArea())
			RestArea(aAreaAnt)
		EndIf
		Return .T.
	EndIf

	// Deve validar o endereço e gerar os processos de movimentação para o endereçamento
	Do While lRet .And. (cAliasSBE)->(!Eof()) .And. Self:nQuant > 0
		// Se encontrou um endereço e não utiliza multiplos picking,
		//nem usa somente picking, sai fora e vai para próxima estrtura
		If Self:oEstFis:GetTipoEst() == "2" .And. QtdComp((cAliasSBE)->SLD_PRODUT) <= 0 .And. QtdComp((cAliasSBE)->MOV_PRODUT) <= 0
			If !Self:lMultPkg .And. lFoundPkg
				Self:AddMsgLog(Self:oEstFis:GetEstFis(),"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,Self:nQuant,0,STR0009) // Encontrou endereço de picking. Múltiplos = Não
				Exit
			EndIf
			// MV_WMSNRPO = Limite de enderecos picking ocupados
			If lWMSNrPo
				Self:nLimtPkg := ExecBlock('WMSNRPO',.F.,.F.,{Self:nLimtPkg,Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetLoteCtl()})
			EndIf
 			If Self:nLimtPkg > 0 .And. Self:nLimtPkg <= Self:nQuantPkg
				Self:AddMsgLog(Self:oEstFis:GetEstFis(),"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,Self:nQuant,0,WmsFmtMsg(Iif(lWMSNrPo, STR0021,"")+STR0010,{{"[VAR01]",Str(Self:nLimtPkg)}})) //{PE WMSNRPO:} Limite de endereços picking ocupados ([VAR01]).
				Exit
			EndIf
		EndIf

		lFoundPkg  := .F.

		cOrdSeq    := PadR((cAliasSBE)->ZON_ORDEM,TamSX3("DCH_ORDEM")[1],'0') // Ordem Zona
		cOrdPrd    := StrZero((cAliasSBE)->PRD_ORDEM,2,0) // Ordem Produto
		cOrdSld    := StrZero((cAliasSBE)->SLD_ORDEM,2,0) // Ordem Saldo -- Endereço Ocupado
		cOrdMov    := StrZero((cAliasSBE)->MOV_ORDEM,2,0) // Ordem Movimentação -- Endereço Ocupado
		cEndDest   := (cAliasSBE)->BE_LOCALIZ   // Código do Endereço
		nTipoPerc  := (cAliasSBE)->DCP_PEROCP   // Indicador de percentual de ocupação -> 0-Não compartilha;1-Produto;2-Geral;3-Outros Produtos/Normas;

		// Descarta se o endereço possui um percentual de ocupação para outros produtos ou normas
		If nTipoPerc >= 3
			// Só loga uma vez, pois podem ter vários registros
			If !(cUltEndPer == cEndDest)
				Self:AddMsgLog(Self:oEstFis:GetEstFis(),"00","00","00","00",cEndDest,0,0,0,Self:nQuant,0,STR0019) //"Percentual de ocupação para outro Produto/Norma."
				cUltEndPer := cEndDest
			EndIf
			(cAliasSBE)->(DbSkip())
			Loop
		EndIf

		// Descarta se o endereço possui um percentual de ocupação somente para a norma,
		// caso já tenha utilizado este endereço com o cadastro por norma+produto - ordenação
		If nTipoPerc == 2 .And. cUltEndPer == cEndDest
			(cAliasSBE)->(DbSkip()) // Não loga neste caso
			Loop
		EndIf

		If nTipoPerc != 0
			cUltEndPer := cEndDest
		EndIf
		// lock do endereço
		SBE->(dbGoTo((cAliasSBE)->RECNOSBE))
		SBE->(SoftLock("SBE"))
		// Inicializa quantidades
		nSldEndPrd := 0
		nSldEndOut := 0
		nSldRFPrd  := 0
		nSldRFOut  := 0
		// Busca saldos do endereço 
		cAliasD14 = Self:QryEndSel(cEndDest)
		If (cAliasD14)->(!Eof())
			nSldEndPrd := (cAliasD14)->SLD_PRODUT  // Saldo no Endereço para o Produto
			nSldEndOut := (cAliasD14)->SLD_OUTROS  // Saldo no Endereço para outros Produto
			nSldRFPrd  := (cAliasD14)->MOV_PRODUT  // Saldo RF do Endereço para o Produto
			nSldRFOut  := (cAliasD14)->MOV_OUTROS  // Saldo RF do Endereço para outros Produto
		EndIf
		(cAliasD14)->(dbCloseArea())
		// Se possui percentual de ocupação deve consultar o saldo somente do produto
		// Caso contrário deve consultar o saldo do endereço por completo
		nSaldoEnd  := Iif(nTipoPerc==1,nSldEndPrd,(nSldEndPrd + nSldEndOut))
		nSaldoRF   := Iif(nTipoPerc==1,nSldRFPrd ,(nSldRFPrd  + nSldRFOut ))
		// Se não utiliza percentual de ocupação utiliza a capacidade da estrutura, senão calcula a do endereço
		lChkUnit := ((cAliasSBE)->BE_NRUNIT = 0 .Or. (Self:oEstFis:GetNrUnit() == (cAliasSBE)->BE_NRUNIT))
		nCapEnder  := Iif(nTipoPerc==0 .And. lChkUnit,nCapEstru,DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oEstFis:GetEstFis(),/*cDesUni*/,.T.,cEndDest)) // Considerar a qtd pelo nr de unitizadores

		//Ponto de entrada para manipular a capacidade do endereço destino
		If lWMSCAPMX
			nCapNewEnd := ExecBlock('WMSCAPMX',.F.,.F.,{Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oEstFis:GetEstFis(),cEndDest,nCapEnder,nSaldoEnd,nSaldoRF})
			If ValType(nCapNewEnd) == "N"
				nCapEnder := nCapNewEnd
			EndIf
		Endif

		If QtdComp(nCapEnder) <= 0
			Self:AddMsgLog(Self:oEstFis:GetEstFis(),"00","00","00","00",cEndDest,0,0,0,Self:nQuant,0,STR0017) // Endereço com capacidade zerada.
			(cAliasSBE)->(dbSkip())
			Loop
		EndIf
		// Se procura só endereços vazios, não precisa consultar o saldo, pois já foi descartado no SELECT
		If !Self:oEstFis:GetTipoEst() $ '3|5' .And. Self:oMovSeqAbt:GetTipoEnd() != "1"
			// Somente considera endereço ocupado se o picking possui saldo, para picking sempre consulta o saldo completo
			If Self:oEstFis:GetTipoEst() == "2" .And. QtdComp(nSldEndPrd + nSldRFPrd) > QtdComp(0)
				lFoundPkg := .T.
				Self:nQuantPkg++
			EndIf
			// Verifica se o endereço possui capacidade, para comportar o produto
			If lCapEstru .And. QtdComp(nSaldoEnd + nSaldoRF) >= QtdComp(nCapEnder)
				Self:AddMsgLog(Self:oEstFis:GetEstFis(),cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoEnd,nSaldoRF,Self:nQuant,0,STR0011) // Saldo do endereço utiliza toda capacidade.
				(cAliasSBE)->(dbSkip())
				Loop
			EndIf
			// Verifica se o endereço possui saldo de outro produto ou outro lote quando não permite misturar lotes ou produtos
			// A consulta de lote não é feita na consulta de saldo original, somente neste ponto é que deve ser validada
			If Self:oMovSeqAbt:GetTipoEnd() == "3" .And. QtdComp(nSldEndPrd) > 0
				// Inicializa informações de Lote/Sub-lote para realizar a consulta de saldo por produto
				Self:oEstEnder:oProdLote:SetLoteCtl("")
				Self:oEstEnder:oProdLote:SetNumLote("")
				Self:oEstEnder:oProdLote:SetNumSer("")
				Self:oEstEnder:oEndereco:SetEnder(cEndDest)
				// Busca Saldo
				nSaldoLot := Self:oEstEnder:ConsultSld(.T.,.F.,.F.,.F.,.F.)
			Else // Senão considera o saldo geral do produto
				nSaldoLot := (nSldEndPrd + nSldRFPrd)
			EndIf
			// Se a quantidade de saldo do endereço, for diferente da quantidade retornada do
			// produto indica que o endereço possui saldo relativo a algum outro produto ou lote
			If (QtdComp(nSaldoEnd + nSaldoRF) > QtdComp(0)) .And. (QtdComp(nSaldoLot) != QtdComp(nSaldoEnd + nSaldoRF))
				// Produto não compartilha endereço
				If Self:oMovSeqAbt:GetTipoEnd() != "4"
					Self:AddMsgLog(Self:oEstFis:GetEstFis(),cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoEnd,nSaldoRF,Self:nQuant,0,STR0012) // Possui saldo de outros produtos/lotes.
					(cAliasSBE)->(dbSkip())
					Loop
				Else
					// Valida se o produto a ser armazenado permite compartilhar endereco
					Self:oEstEnder:oEndereco:SetEnder(cEndDest)
					Self:oEstEnder:oEndereco:LoadData()
					Self:oEstEnder:SetCodNor(Self:oMovSeqAbt:GetCodNor()) // Atribui a norma do produto
					If !Self:oEstEnder:EndUsaComp()
						Self:AddMsgLog(Self:oEstFis:GetEstFis(),cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoEnd,nSaldoRF,Self:nQuant,0,STR0013) // Possui produto que não compartilha endereço.
						(cAliasSBE)->(dbSkip())
						Loop
					EndIf
				EndIf
			EndIf
		EndIf
		nQtdEnd   := IIf(lCapEstru, Min(Self:nQuant,(nCapEnder - (nSaldoEnd + nSaldoRF))),Self:nQuant)
		// Ajusta a quantidade, pois deve ser múltipla do endereçamento mínimo
		nQtdEnd := NoRound(nQtdEnd/Self:oMovSeqAbt:GetQtMinEn(),0) * Self:oMovSeqAbt:GetQtMinEn()
		If QtdComp(nQtdEnd) <= 0
			Self:AddMsgLog(Self:oEstFis:GetEstFis(),cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoEnd,nSaldoRF,Self:nQuant,0,WmsFmtMsg(STR0018,{{"[VAR01]",Str(Self:oMovSeqAbt:GetQtMinEn())}})) //"Múltiplo menor que endereçamento mínimo ([VAR01])."
			Exit
		EndIf
		// Somente endereço que comporte a quantidade total da movimentação para tranferencia via coletor.
		If Self:lTrfCol .And. QtdComp(nQtdEnd) < QtdComp(Self:nQuant)
			(cAliasSBE)->(dbSkip())
			Loop
		EndIf
		//Ponto de entrada para validação adicional se o endereço será ignorado.
		If lWmsVlEnd
			aRetPE := ExecBlock('WMSVLEND',.F.,.F.,{Self:oMovEndDes:GetArmazem(),cEndDest,Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetLoteCtl()})
			If ValType(aRetPE) == "A" .And. !aRetPE[1]
				Self:AddMsgLog(Self:oEstFis:GetEstFis(),cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoEnd,nSaldoRF,Self:nQuant,0,STR0020+aRetPE[2]) //"PE WMSVLEND: "
				(cAliasSBE)->(dbSkip())
				Loop		
			EndIf
		EndIf
		// Se não utiliza percentual de ocupação utiliza a norma da estrutura, senão calcula a do endereço
		nQtdNorma := Iif(nTipoPerc==0,nNormaEst,DLQtdNorma(Self:oMovPrdLot:GetProduto(), Self:oMovEndDes:GetArmazem(), Self:oEstFis:GetEstFis(), /*cDesUni*/, .F., cEndDest)) // Considerar somente a norma
		Self:AddMsgLog(Self:oEstFis:GetEstFis(),cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoEnd,nSaldoRF,Self:nQuant,nQtdEnd,STR0015) // Endereço utilizado.
		Self:oMovEndDes:SetEnder(cEndDest)
		Self:oMovEndDes:LoadData()
		// Movimentação de transferencia via coletor
		If Self:lTrfCol
			Self:nQuant := 0
			Exit
		EndIf
		// Verifica se a Atividade utiliza Radio Frequencia
		// Carregas as exceções das atividades no destino
		Self:oMovEndDes:ExceptEnd()
		// Enquanto for maior que zero, vai endereçando a quantidade de uma norma ou o restante
		Do While lRet .And. QtdComp(nQtdEnd) > QtdComp(0)
			// Status movimento
			Self:cStatus := IIf(Self:oMovServic:GetBlqSrv() == '1','2','4')
			Self:nQtdMovto := Min(nQtdEnd,nQtdNorma)
			nQtdEnd  -= Self:nQtdMovto
			Self:nQuant -= Self:nQtdMovto
			// Gera a movimentação de estoque por endereco
			If lRet .And. !Self:MakeInput()
				lRet := .F.
			EndIf
			// Gera movimentos WMS
			If !Self:AssignD12()
				lRet := .F.
			EndIf
		EndDo
		// Libera endereço
		SBE->(MsUnLock())
		
		If lRet
			// Indicando que encontrou um endereço de picking
			lFoundPkg := (Self:oEstFis:GetTipoEst() == "2")
			// Deve verificar se o número de pickings ocupados não ultrapasou
			// Só deve considerar o que não tinha saldo, pois os que continham saldo já foram considerados
			If Self:oEstFis:GetTipoEst() == "2" .And. QtdComp(nSldEndPrd + nSldRFPrd) == QtdComp(0)
				Self:nQuantPkg++
			EndIf
		EndIf
		(cAliasSBE)->(dbSkip())
	EndDo
	(cAliasSBE)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

METHOD FindEndSld() CLASS WMSBCCEnderecamento
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local lWMSQFESL := ExistBlock("WMSQFESL")
Local cQueryPE  := ""
Local cAliasSBE := GetNextAlias()
Local nX        := 0
Local cEstFis   := ""
Local lWMSPRPF  := SuperGetMV("MV_WMSPRPF",.F.,.F.)

	Self:aNivEndOri := {}
	If Empty(Self:oMovEndDes:GetEnder())

		//Caso o parâmetro MV_WMSPRPF esteja ativo, receberá as estruturas de picking, uma a uma
		If lWMSPRPF
			For nX := 1 To Len(Self:oMovSeqAbt:GetArrSeqA())
				If Self:oMovSeqAbt:GetArrSeqA()[nX,3] == "2" //picking
					cEstFis += "'" + Self:oMovSeqAbt:GetArrSeqA()[nX,2] + "',"
				EndIf
			Next nX

			If !Empty(cEstFis)
				cEstFis := Substr(cEstFis, 1, Len(cEstFis)-1)
			EndIf
		EndIf

		//Se estiver vazio, ou o parâmetro MV_WMSPRPF está inativo ou não há picking
		If Empty(cEstFis)
			cEstFis := "'" + Self:oEstFis:GetEstFis() + "'"
		EndIf

		cEstFis := "%" + AllTrim(cEstFis + "%")

		// Se endereça somente endereços vazios, deve pesquisar se possui algum endereço de picking
		// Pois mesmo endereçando somente em endereços vazios, deve respeitar os parâmetros do picking
		If Self:lPriorSA .And. Self:lZonaPrd
			BeginSql Alias cAliasSBE
				SELECT MIN(BE_LOCALIZ) BE_LOCALIZ
				FROM %Table:SBE% SBE
				INNER JOIN %Table:DCH% DCH
				ON DCH_FILIAL = %xFilial:DCH%
				AND DCH_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
				AND DCH.DCH_CODZON = SBE.BE_CODZON
				AND DCH_CODZON <> %Exp:Self:oMovPrdLot:GetCodZona()%
				AND DCH.%NotDel%
				WHERE BE_FILIAL = %xFilial:SBE%
				AND BE_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
				AND BE_ESTFIS IN (%Exp:cEstFis%)
				AND SBE.%NotDel%
				AND ( EXISTS ( SELECT 1 
								FROM %Table:D14% D14
								WHERE D14_FILIAL = %xFilial:D14%
								AND D14_LOCAL = BE_LOCAL
								AND D14_ESTFIS = BE_ESTFIS
								AND D14_ENDER = BE_LOCALIZ
								AND D14_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
								AND (D14_QTDEST+D14_QTDEPR) > 0
								AND D14.%NotDel% )
						OR ( SBE.BE_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()% )
						OR ( EXISTS ( SELECT 1
										FROM %Table:DCP% DCP
										WHERE DCP.DCP_FILIAL = %xFilial:DCP%
										AND DCP.DCP_LOCAL = SBE.BE_LOCAL
										AND DCP.DCP_ENDERE = SBE.BE_LOCALIZ
										AND DCP.DCP_ESTFIS = SBE.BE_ESTFIS
										AND DCP.DCP_NORMA = %Exp:Self:oMovSeqAbt:GetCodNor()%
										AND DCP.DCP_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
										AND DCP.%NotDel% )))
			EndSql
		Else
			BeginSql Alias cAliasSBE
				SELECT MIN(BE_LOCALIZ) BE_LOCALIZ
				FROM %Table:SBE% SBE
				WHERE BE_FILIAL = %xFilial:SBE%
				AND BE_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
				AND BE_ESTFIS IN (%Exp:cEstFis%)
				AND SBE.BE_CODZON = %Exp:Self:oMovPrdLot:GetCodZona()%
				AND SBE.%NotDel%
				AND ( EXISTS ( SELECT 1 
								FROM %Table:D14% D14
								WHERE D14_FILIAL = %xFilial:D14%
								AND D14_LOCAL = BE_LOCAL
								AND D14_ESTFIS = BE_ESTFIS
								AND D14_ENDER = BE_LOCALIZ
								AND D14_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
								AND (D14_QTDEST+D14_QTDEPR) > 0
								AND D14.%NotDel% )
						OR ( SBE.BE_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()% )
						OR ( EXISTS ( SELECT 1
										FROM %Table:DCP% DCP
										WHERE DCP.DCP_FILIAL = %xFilial:DCP%
										AND DCP.DCP_LOCAL = SBE.BE_LOCAL
										AND DCP.DCP_ENDERE = SBE.BE_LOCALIZ
										AND DCP.DCP_ESTFIS = SBE.BE_ESTFIS
										AND DCP.DCP_NORMA = %Exp:Self:oMovSeqAbt:GetCodNor()%
										AND DCP.DCP_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
										AND DCP.%NotDel% ))										
						OR ( %Exp:cValtoChar(lWMSPRPF)% = '.F.' AND EXISTS ( SELECT 1
										FROM %Table:DC7% DC7
										WHERE DC7.DC7_FILIAL = %xFilial:DC7%
										AND DC7.DC7_CODCFG = BE_CODCFG
										AND ( DC7.DC7_PESO1 > 0 OR DC7.DC7_PESO2 > 0 )
										AND DC7.%NotDel% )))
			EndSql
		EndIf
		If lWMSQFESL
			cQueryPE := ExecBlock('WMSQFESL',.F.,.F.,{GetLastQuery()[2]})
			If !Empty(cQueryPE)
				(cAliasSBE)->(dbCloseArea())
				cQueryPE := "%"+AllTrim(cQueryPE)+"%"
				cQueryPE := StrTran(cQueryPE,"%SELECT","%")
				cAliasSBE := GetNextAlias()
				BeginSql Alias cAliasSBE
					SELECT %Exp:cQueryPE%
				EndSql
			EndIf
		EndIf
		If (cAliasSBE)->(!Eof()) .And. !Empty((cAliasSBE)->BE_LOCALIZ)
			Self:FindNivSBE(Self:oMovEndDes:GetArmazem(),(cAliasSBE)->BE_LOCALIZ)
		EndIf
		(cAliasSBE)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet


METHOD VldProcPkg() CLASS WMSBCCEnderecamento
Local lRet      := .T.
Local lFoundPkg := .F.
Local aAreaAnt  := GetArea()
Local cEndPkg   := ""
Local cAliasSBE := GetNextAlias()
	BeginSql Alias cAliasSBE
		SELECT MIN(BE_LOCALIZ) BE_LOCALIZ,
				COUNT(*) BE_QTDPKG
		FROM %Table:SBE% SBE
		WHERE BE_FILIAL = %xFilial:SBE%
		AND BE_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
		AND BE_ESTFIS = %Exp:Self:oEstFis:GetEstFis()%
		AND SBE.%NotDel%
		AND EXISTS (SELECT 1
					FROM %Table:D14% D14
					WHERE D14_FILIAL = %xFilial:D14%
					AND D14_LOCAL = BE_LOCAL
					AND D14_ESTFIS = BE_ESTFIS
					AND D14_ENDER = BE_LOCALIZ
					AND D14_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
					AND (D14_QTDEST+D14_QTDEPR) > 0
					AND D14.%NotDel% )
	EndSql
	If (cAliasSBE)->(!Eof())
		lFoundPkg := ((cAliasSBE)->BE_QTDPKG > 0)
		Self:nQuantPkg := (cAliasSBE)->BE_QTDPKG
		cEndPkg   := (cAliasSBE)->BE_LOCALIZ
	Else
		lFoundPkg := .F.
	EndIf
	(cAliasSBE)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} QryEndEst
Monta a query responsável por buscar os endereços possíveis a serem utilizados
@author Jackson Patrick Werka
@since 10/09/2014
@return Caracter Alias para a consulta já aberta
/*/
METHOD QryEndEst(nCapEstru) CLASS WMSBCCEnderecamento
Local lWMSQENES := ExistBlock("WMSQENES")
Local aTamSX3   := {}
Local cNivel11  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>0,Self:aNivEndOri[1,1],0)))
Local cNivel21  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>1,Self:aNivEndOri[2,1],0)))
Local cNivel31  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>2,Self:aNivEndOri[3,1],0)))
Local cNivel41  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>3,Self:aNivEndOri[4,1],0)))
Local cNivel51  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>4,Self:aNivEndOri[5,1],0)))
Local cNivel61  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>5,Self:aNivEndOri[6,1],0)))
Local cNivel12  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>0,Self:aNivEndOri[1,2],0)))
Local cNivel22  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>1,Self:aNivEndOri[2,2],0)))
Local cNivel32  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>2,Self:aNivEndOri[3,2],0)))
Local cNivel42  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>3,Self:aNivEndOri[4,2],0)))
Local cNivel52  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>4,Self:aNivEndOri[5,2],0)))
Local cNivel62  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>5,Self:aNivEndOri[6,2],0)))
Local cNivel13  := AllTrim(Str(Iif(Len(Self:aNivEndOri)>1,Self:aNivEndOri[1,3],0)))
Local cAliasSBE := GetNextAlias()
Local cAliasQry := GetNextAlias()
Local cProdVz   := Space(TamSx3("BE_CODPRO")[1])
Local cQuery    := ""
Local cQueryPE  := ""
Local cListZon  := ""
Local cDBMS     := Upper(TCGETDB())
Local lPrPkFixo := SuperGetMV("MV_BPKFIX",.F.,.F.) .Or. SuperGetMV("MV_WMSPKFX",.F.,.F.) //O parâmetro MV_BPKFIX será descontinuado

	// Busca estrutura fisica do endereco destino
	Self:oEstFis:SetEstFis(Self:oEstFis:GetEstFis())
	Self:oEstFis:LoadData()
	// Deve filtar os outros produtos somente da mesma zona de armazenagem do produto atual
	If Self:lPriorSA .And. Self:lZonaPrd
		cListZon := "'"+Self:oMovPrdLot:GetCodZona()+"'"
	Else
		If !Self:lPriorSA
			BeginSql Alias cAliasQry
				// Se prioriza a sequencia, vai filtar direto, senão junta na query
				SELECT DCH.DCH_CODZON ZON_CODZON
				FROM %Table:DCH% DCH
				WHERE DCH.DCH_FILIAL = %xFilial:DCH%
				AND DCH.DCH_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
				AND DCH.DCH_CODZON <> %Exp:Self:oMovPrdLot:GetCodZona()%
				AND DCH.%NotDel%
				// Não utiliza do cadastro por que existe um PE que pode alterar, usa a variável
				UNION ALL
				SELECT %Exp:Self:oMovPrdLot:GetCodZona()% ZON_CODZON
				FROM %Table:SB5% SB5
				WHERE SB5.B5_FILIAL = %xFilial:SB5%
				AND SB5.B5_COD = %Exp:Self:oMovPrdLot:GetProduto()%
				AND SB5.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasQry
				// Se prioriza a sequencia, vai filtar direto, senão junta na query
				SELECT DCH.DCH_CODZON ZON_CODZON
				FROM %Table:DCH% DCH
				WHERE DCH.DCH_FILIAL = %xFilial:DCH%
				AND DCH.DCH_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
				AND DCH.DCH_CODZON <> %Exp:Self:oMovPrdLot:GetCodZona()%
				AND DCH.%NotDel%
			EndSql
		EndIf
		Do While (cAliasQry)->(!Eof())
			cListZon += "'"+(cAliasQry)->ZON_CODZON+"',"
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		cListZon := SubsTr(cListZon,1,Len(cListZon)-1)
	EndIf
	cQuery := "SELECT"
	// Se considera primeiro a zona de armazenagem do produto
	If Self:lPriorSA
		If Self:lZonaPrd
			cQuery +=   " '00' ZON_ORDEM,"
		Else
			cQuery +=    " ZON.ZON_ORDEM,"
		EndIf
	Else
		cQuery +=          " ZON.ZON_ORDEM,"
	EndIf
	// Se foi informado o produto no endereço ele tem prioridade
	cQuery +=              " CASE WHEN SBE.BE_CODPRO = '"+cProdVz+"' THEN 2 ELSE 1 END PRD_ORDEM,"
	// Este campos são para compatibilidade com outros tipos de endereçamento
	If Self:oMovSeqAbt:GetTipoEnd() == "1" .Or. Self:oEstFis:GetTipoEst() $ '3|5'
		cQuery +=          " 99 SLD_ORDEM,"
		cQuery +=          " 99 MOV_ORDEM,"
	Else
		cQuery +=          " CASE WHEN SLD.SLD_ORDEM IS NOT NULL THEN SLD.SLD_ORDEM ELSE 99 END SLD_ORDEM,"
		cQuery +=          " CASE WHEN SLD.MOV_ORDEM IS NOT NULL THEN SLD.MOV_ORDEM ELSE 99 END MOV_ORDEM,"
	EndIf
	// Pegando as informações do endereço
	cQuery +=              " SBE.BE_LOCALIZ,"
	cQuery +=              " SBE.BE_CODCFG,"
	cQuery +=              IIf(WmsX312120("SBE","BE_NRUNIT")," SBE.BE_NRUNIT,"," 0 BE_NRUNIT,") 
	cQuery +=              " SBE.R_E_C_N_O_ RECNOSBE,"
	// Carregando as informações de endereço compartilhado via percentual de ocupação
	cQuery +=              " CASE WHEN DCP.DCP_CODPRO IS NULL THEN 0"
	cQuery +=                   " WHEN (DCP.DCP_NORMA = '"+Self:oMovSeqAbt:GetCodNor()+"' AND DCP.DCP_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"') THEN 1"
	cQuery +=                   " WHEN (DCP.DCP_NORMA = '"+Self:oMovSeqAbt:GetCodNor()+"' AND DCP.DCP_CODPRO = '"+cProdVz+"') THEN 2"
	cQuery +=                   " ELSE 3"
	cQuery +=              " END DCP_PEROCP,"
	// Este campos são para compatibilidade com outros tipos de endereçamento
	If Self:oMovSeqAbt:GetTipoEnd() == "1" .Or. Self:oEstFis:GetTipoEst() $ '3|5'
		cQuery +=          " 0 SLD_PRODUT,"
		cQuery +=          " 0 MOV_PRODUT,"
		cQuery +=          " 0 SLD_OUTROS,"
		cQuery +=          " 0 MOV_OUTROS,"
	Else
		cQuery +=          " CASE WHEN SLD.SLD_PRODUT IS NULL THEN 0 ELSE SLD.SLD_PRODUT END SLD_PRODUT,"
		cQuery +=          " CASE WHEN SLD.MOV_PRODUT IS NULL THEN 0 ELSE SLD.MOV_PRODUT END MOV_PRODUT,"
		cQuery +=          " CASE WHEN SLD.SLD_OUTROS IS NULL THEN 0 ELSE SLD.SLD_OUTROS END SLD_OUTROS,"
		cQuery +=          " CASE WHEN SLD.MOV_OUTROS IS NULL THEN 0 ELSE SLD.MOV_OUTROS END MOV_OUTROS,"
	EndIf
	// Calcula um Endereco Alvo com base nos Pesos atribuidos aos Niveis
	cQuery +=              " ((ABS(SBE.BE_VALNV1 - "+cNivel11+") * "+cNivel12+") +"
	cQuery +=              " (ABS(SBE.BE_VALNV2 - "+cNivel21+") * "+cNivel22+") +"
	cQuery +=              " (ABS(SBE.BE_VALNV3 - "+cNivel31+") * "+cNivel32+") +"
	cQuery +=              " (ABS(SBE.BE_VALNV4 - "+cNivel41+") * "+cNivel42+") +"
	cQuery +=              " (ABS(SBE.BE_VALNV5 - "+cNivel51+") * "+cNivel52+") +"
	cQuery +=              " (ABS(SBE.BE_VALNV6 - "+cNivel61+") * "+cNivel62+")"
	// Inclui o Peso  "LADO"  para  Enderecos  localizados  no  Mesmo  Nivel
	// Primario e Secundario (Ex.:Na mesma Rua e mesmo Predio)
	If Len(Self:aNivEndOri) > 1
		If "MSSQL" $ cDBMS .Or. "POSTGRES" $ cDBMS
			cQuery +=      " + ( CASE WHEN (ABS(SBE.BE_VALNV1-"+cNivel11+") = 0 AND ( ( SBE.BE_VALNV2-(2*( CAST(SBE.BE_VALNV2 / 2 AS INTEGER))) ) != ( "+cNivel21+"-(2 * ( CAST("+cNivel21+" / 2 AS INTEGER))) ) )) THEN (1 * "+cNivel13+") ELSE 0 END)"
		Else
			cQuery +=      " + ( CASE WHEN (ABS(SBE.BE_VALNV1-"+cNivel11+") = 0 AND (MOD(SBE.BE_VALNV2,2) != MOD("+cNivel21+",2))) THEN (1 * "+cNivel13+") ELSE 0 END)"
		EndIf
	EndIf
	cQuery +=              " ) BE_DISTANC"
	cQuery +=        " FROM "+RetSqlName("SBE")+" SBE"
	// Verifica se já considera as zonas de armazenagem na query
	If !Self:lPriorSA .Or. (Self:lPriorSA .And. !Self:lZonaPrd)
		cQuery +=   " INNER JOIN ("
		// Se prioriza a sequencia, vai filtar direto, senão junta na query
		If !Self:lPriorSA
			// Não utiliza do cadastro por que existe um PE que pode alterar, usa a variável
			cQuery +=           " SELECT '00' ZON_ORDEM, '"+Self:oMovPrdLot:GetCodZona()+"' ZON_CODZON"
			cQuery +=             " FROM "+RetSqlName("SB5")+" SB5"
			cQuery +=            " WHERE SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
			cQuery +=              " AND SB5.B5_COD = '"+Self:oMovPrdLot:GetProduto()+"'"
			cQuery +=              " AND SB5.D_E_L_E_T_ = ' '"
			cQuery +=            " UNION ALL"
		EndIf
		cQuery +=               " SELECT DCH.DCH_ORDEM ZON_ORDEM,"
		cQuery +=                      " DCH.DCH_CODZON ZON_CODZON"
		cQuery +=                 " FROM "+RetSqlName("DCH")+" DCH"
		cQuery +=                " WHERE DCH.DCH_FILIAL = '"+xFilial("DCH")+"'"
		cQuery +=                  " AND DCH.DCH_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"'"
		cQuery +=                  " AND DCH.DCH_CODZON <> '"+Self:oMovPrdLot:GetCodZona()+"'"
		cQuery +=                  " AND DCH.D_E_L_E_T_ = ' ') ZON"
		cQuery +=      " ON ZON.ZON_CODZON = SBE.BE_CODZON"
	EndIf
	// Carrega as informações se o endereço possui percentual de ocupação
	cQuery +=        " LEFT JOIN "+RetSqlName("DCP")+" DCP"
	cQuery +=          " ON DCP.DCP_FILIAL = '"+xFilial("DCP")+"'"
	cQuery +=         " AND DCP.DCP_LOCAL = SBE.BE_LOCAL"
	cQuery +=         " AND DCP.DCP_ENDERE = SBE.BE_LOCALIZ"
	cQuery +=         " AND DCP.DCP_ESTFIS = SBE.BE_ESTFIS"
	cQuery +=         " AND DCP.D_E_L_E_T_ = ' ' "
	// Carrega os saldos e movimentações pendentes para este produto para o endereço
	If Self:oMovSeqAbt:GetTipoEnd() $ "2|3|4" .And. !Self:oEstFis:GetTipoEst() $ '3|5'
		// Carregando saldo do endereço para o produto e/ou lote e outros produtos
		cQuery +=    " LEFT JOIN ( SELECT SLD_LOCAL,"
		cQuery +=                       " SLD_ENDER,"
		cQuery +=                       " CASE SUM(SLD_ORDEM) WHEN 1 THEN 1 WHEN 4 THEN 2 ELSE 3 END SLD_ORDEM,"
		cQuery +=                       " CASE SUM(MOV_ORDEM) WHEN 1 THEN 1 WHEN 4 THEN 2 ELSE 3 END MOV_ORDEM,"
		cQuery +=                       " SUM(SLD_PRODUT) SLD_PRODUT, SUM(SLD_OUTROS) SLD_OUTROS,"
		cQuery +=                       " SUM(MOV_PRODUT) MOV_PRODUT, SUM(MOV_OUTROS) MOV_OUTROS"
		cQuery +=                  " FROM ("
		// Consultando saldo do produto
		cQuery +=                         " SELECT D14.D14_LOCAL SLD_LOCAL,"
		cQuery +=                               " D14.D14_ENDER SLD_ENDER,"
		cQuery +=                               " CASE WHEN SUM(D14.D14_QTDEST) <= 0 THEN 0 ELSE 1 END SLD_ORDEM,"
		cQuery +=                               " CASE WHEN SUM(D14.D14_QTDEPR) <= 0 THEN 0 ELSE 1 END MOV_ORDEM,"
		cQuery +=                               " SUM(D14.D14_QTDEST) SLD_PRODUT, 0 SLD_OUTROS,"
		cQuery +=                               " SUM(D14.D14_QTDEPR) MOV_PRODUT, 0 MOV_OUTROS"
		cQuery +=                          " FROM "+RetSqlName("D14")+" D14"
		cQuery +=                         " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=                           " AND D14.D14_LOCAL  = '"+Self:oMovEndDes:GetArmazem()+"'"
		cQuery +=                           " AND D14.D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
		If Self:oMovSeqAbt:GetTipoEnd() == '3' .And. Self:oMovPrdLot:HasRastro() .And. !Empty(Self:oMovPrdLot:GetLoteCtl())
			cQuery +=                       " AND D14.D14_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
		EndIf
		cQuery +=                           " AND D14.D14_ESTFIS = '"+Self:oEstFis:GetEstFis()+"'"
		cQuery +=                           " AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0"
		cQuery +=                           " AND D14.D_E_L_E_T_ = ' '"
		cQuery +=                         " GROUP BY D14.D14_LOCAL,"
		cQuery +=                                " D14.D14_ENDER"
		// Consultando o saldo de outros produtos
		cQuery +=                         " UNION ALL "
		cQuery +=                         "SELECT D14.D14_LOCAL SLD_LOCAL,"
		cQuery +=                               " D14.D14_ENDER SLD_ENDER,"
		cQuery +=                               " CASE WHEN SUM(D14.D14_QTDEST) <= 0 THEN 0 ELSE 3 END SLD_ORDEM,"
		cQuery +=                               " CASE WHEN SUM(D14.D14_QTDEPR) <= 0 THEN 0 ELSE 3 END MOV_ORDEM,"
		cQuery +=                               " 0 SLD_PRODUT, SUM(D14.D14_QTDEST) SLD_OUTROS,"
		cQuery +=                               " 0 MOV_PRODUT, SUM(D14.D14_QTDEPR) MOV_OUTROS"
		cQuery +=                          " FROM "+RetSqlName("D14")+" D14"
		cQuery +=                         " INNER JOIN "+RetSqlName("SBE")+" SBE"
		cQuery +=                            " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
		cQuery +=                           " AND SBE.BE_LOCAL = '"+Self:oMovEndDes:GetArmazem()+"'"
		cQuery +=                           " AND SBE.BE_ESTFIS = '"+Self:oEstFis:GetEstFis()+"'"
		cQuery +=                           " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
		//Se não existir zonas, não pode simplesmente adicionar ' ' porque existem endereços 
		//com zona em branco. Nesse caso, nenhum endereço deverá ser selecionado.
		If Vazio(AllTrim(cListZon))
			cQuery +=                       " AND 0 = 1"		
		Else
			cQuery +=                       " AND SBE.BE_CODZON IN ("+cListZon+")"
		EndIf
		cQuery +=                           " AND SBE.D_E_L_E_T_ = ' '"
		cQuery +=                         " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=                           " AND D14.D14_LOCAL  = '"+Self:oMovEndDes:GetArmazem()+"'"
		cQuery +=                           " AND D14.D14_ESTFIS = '"+Self:oEstFis:GetEstFis()+"'"
		If Self:oMovSeqAbt:GetTipoEnd() == '3' .And. Self:oMovPrdLot:HasRastro() .And. !Empty(Self:oMovPrdLot:GetLoteCtl())
			cQuery +=                       " AND ((D14.D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
			cQuery +=                           " AND D14.D14_LOTECT <> '"+Self:oMovPrdLot:GetLoteCtl()+"')"
			cQuery +=                            " OR (D14.D14_PRODUT <> '"+Self:oMovPrdLot:GetProduto()+"'))"
		Else
			cQuery +=                       " AND D14.D14_PRODUT <>'"+Self:oMovPrdLot:GetProduto()+"'"
		EndIf
		cQuery +=                           " AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0"
		cQuery +=                           " AND D14.D_E_L_E_T_ = ' '"
		cQuery +=                         " GROUP BY D14.D14_LOCAL,"
		cQuery +=                                  " D14.D14_ENDER) COM "
		cQuery +=                 " GROUP BY SLD_LOCAL,"
		cQuery +=                          " SLD_ENDER ) SLD"
		cQuery +=      " ON SLD.SLD_LOCAL = SBE.BE_LOCAL"
		cQuery +=     " AND SLD.SLD_ENDER = SBE.BE_LOCALIZ"
	EndIf
	// Filtros em cima da SBE - Endereços
	cQuery +=       " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=         " AND SBE.BE_LOCAL  = '"+Self:oMovEndDes:GetArmazem()+"'"
	If lPrPkFixo .AND. Self:oEstFis:GetTipoEst() == "2"
		cQuery +=   " AND (SBE.BE_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"')"
	Else
		cQuery +=   " AND (SBE.BE_CODPRO = ' ' OR SBE.BE_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"')"
	EndIf
	If !Empty(Self:oMovEndDes:GetEnder())
		cQuery +=     " AND SBE.BE_LOCALIZ = '"+Self:oMovEndDes:GetEnder()+"'"
	EndIf
	cQuery +=         " AND SBE.BE_ESTFIS = '"+Self:oEstFis:GetEstFis()+"'"
	cQuery +=         " AND SBE.BE_LOCALIZ  <> '"+Self:oMovEndOri:GetEnder()+"'"
	// Desconsidera endereços com '3=Bloqueio Endereço', '4=Bloqueio Entrada' e '6=Bloqueio Inventário'
	cQuery +=         " AND SBE.BE_STATUS NOT IN ('3','4','6')"
	cQuery +=         " AND SBE.D_E_L_E_T_ = ' '"
	// Se prioriza a sequencia e está usando a zona do produto, filtra direto
	If Self:lPriorSA .And. Self:lZonaPrd
		cQuery +=     " AND SBE.BE_CODZON = '"+Self:oMovPrdLot:GetCodZona()+"'"
	EndIf
	// Se somente endereça em endereços vazios, não considera endereços saldo ou movimentação
	If Self:oMovSeqAbt:GetTipoEnd() == "1" .And. !Self:oEstFis:GetTipoEst() $ '3|5'
		// Desconsiderando endereços que possuem saldo ou movimentação de entrada pendente
		cQuery +=     " AND NOT EXISTS ("
		cQuery +=                     " SELECT 1 FROM "+RetSqlName('D14')+" D14"
		cQuery +=                      " WHERE D14.D14_FILIAL = '"+xFilial('D14')+"'"
		cQuery +=                        " AND D14.D14_LOCAL  = SBE.BE_LOCAL"
		cQuery +=                        " AND D14.D14_ESTFIS = SBE.BE_ESTFIS"
		cQuery +=                        " AND D14.D14_ENDER  = SBE.BE_LOCALIZ"
		cQuery +=                        " AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0"
		cQuery +=                        " AND D14.D_E_L_E_T_  = ' ')"
	EndIf
	If Empty(Self:oMovEndDes:GetEnder()) .And. Self:oEstFis:GetTipoEst() $ '3|5'
		cQuery +=     " AND NOT EXISTS (SELECT 1"
		cQuery +=                       " FROM "+RetSqlName("D10")+" D10"
		cQuery +=                      " WHERE D10.D10_FILIAL = '"+xFilial("D10")+"'"
		cQuery +=                        " AND D10.D10_LOCAL = SBE.BE_LOCAL"
		cQuery +=                        " AND D10.D10_ENDER = SBE.BE_LOCALIZ"
		cQuery +=                        " AND D10.D_E_L_E_T_ = ' ')"
	EndIf
	If Self:oMovSeqAbt:GetTipoEnd() $ "2|3|4" .And. !Self:oEstFis:GetTipoEst() $ '3|5'
		cQuery +=     " AND (CASE WHEN DCP.DCP_CODPRO IS NULL THEN "+cValtoChar(nCapEstru)+" ELSE 999999999 END) >"
		cQuery +=         " ((CASE WHEN SLD_PRODUT IS NULL THEN 0 ELSE SLD_PRODUT END) + "
		cQuery +=         " (CASE WHEN MOV_PRODUT IS NULL THEN 0 ELSE MOV_PRODUT END) + "
		cQuery +=         " (CASE WHEN SLD_OUTROS IS NULL THEN 0 ELSE SLD_OUTROS END) + "
		cQuery +=         " (CASE WHEN MOV_OUTROS IS NULL THEN 0 ELSE MOV_OUTROS END)) "
		If Self:oMovSeqAbt:GetTipoEnd() $ "2|3"
			cQuery += " AND ((CASE WHEN SLD_OUTROS IS NULL THEN 0 ELSE SLD_OUTROS END) + "
			cQuery +=      " (CASE WHEN MOV_OUTROS IS NULL THEN 0 ELSE MOV_OUTROS END)) <= 0 "
		EndIf
	EndIf
	// Deve ordenar de forma diferente para o caso de não utilizar múltiplos pickings
	If Self:oMovSeqAbt:GetTipoEnd() != "1" .And. Self:oEstFis:GetTipoEst() == "2"
		// Ordena por - Endereço Ocupado + Movimentação Prevista + Ordem Zona + Ordem Produto + Distancia Total + Código Endereço + Percentual Ocupação
		cQuery +=   " ORDER BY SLD_ORDEM,"
		cQuery +=            " MOV_ORDEM,"
		cQuery +=            " ZON_ORDEM,"
		cQuery +=            " PRD_ORDEM,"
		cQuery +=            " BE_DISTANC,"
		cQuery +=            " SBE.BE_LOCALIZ,"
		cQuery +=            " DCP_PEROCP"
	Else
		// Ordena por - Ordem Zona + Ordem Produto + Endereço Ocupado + Movimentação Prevista + Distancia Total + Código Endereço + Percentual Ocupação
		cQuery +=   " ORDER BY ZON_ORDEM,"
		cQuery +=            " PRD_ORDEM,"
		cQuery +=            " SLD_ORDEM,"
		cQuery +=            " MOV_ORDEM,"
		cQuery +=            " BE_DISTANC,"
		cQuery +=            " BE_LOCALIZ,"
		cQuery +=            " DCP_PEROCP"
	EndIf
	If lWMSQENES
		cQueryPE := ExecBlock('WMSQENES',.F.,.F.,{cQuery})
		If !Empty(cQueryPE)
			cQuery := cQueryPE
		EndIf
	EndIf
	cQuery := "%"+AllTrim(cQuery)+"%"
	cQuery := StrTran(cQuery,"%SELECT","%")
	cAliasSBE := GetNextAlias()
	BeginSql Alias cAliasSBE
		SELECT %Exp:cQuery%
	EndSql
	// Ajustando o tamanho dos campos da query
	TcSetField(cAliasSBE,'PRD_ORDEM' ,'N',5,0)
	TcSetField(cAliasSBE,'SLD_ORDEM' ,'N',5,0)
	TcSetField(cAliasSBE,'MOV_ORDEM' ,'N',5,0)
	TcSetField(cAliasSBE,'DCP_PEROCP','N',5,0)
	TcSetField(cAliasSBE,'BE_DISTANC','N',10,0)
	aTamSX3 := IIf(WmsX312120("SBE","BE_NRUNIT"),TamSx3('BE_NRUNIT'),{1,0}) 
	TcSetField(cAliasSBE,'BE_NRUNIT','N',aTamSX3[1],aTamSX3[2])
	aTamSX3 := TamSx3('D14_QTDEST')
	TcSetField(cAliasSBE,'SLD_PRODUT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBE,'MOV_PRODUT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBE,'SLD_OUTROS','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBE,'MOV_OUTROS','N',aTamSX3[1],aTamSX3[2])
Return cAliasSBE
/*/{Protheus.doc} QryEndSel
Monta a query responsável por buscar os saldos do endereço selecionado
@author Squad WMS Protheus
@since 20/06/2018
@return Caracter Alias para a consulta já aberta
@param cEndereco, caracter, Endereço selecionado
/*/
METHOD QryEndSel(cEndereco) CLASS WMSBCCEnderecamento
Local lWMSQENSE := ExistBlock("WMSQENSE")
Local aTamSX3   := {}
Local cQuery    := ""
Local cQueryPE  := ""
Local cAliasD14 := Nil
	cQuery :="SELECT SUM(SLD_PRODUT) SLD_PRODUT, SUM(SLD_OUTROS) SLD_OUTROS,"
	cQuery +=      " SUM(MOV_PRODUT) MOV_PRODUT, SUM(MOV_OUTROS) MOV_OUTROS"
	cQuery += " FROM ("
	// Consultando saldo do produto
	cQuery +=         "SELECT SUM(D14_QTDEST) SLD_PRODUT,"
	cQuery +=               " 0 SLD_OUTROS,"
	cQuery +=               " SUM(D14_QTDEPR) MOV_PRODUT,"
	cQuery +=               " 0 MOV_OUTROS"
	cQuery +=          " FROM "+RetSqlName("D14")
	cQuery +=         " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=           " AND D14_LOCAL  = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=           " AND D14_ENDER = '"+cEndereco+"'"
	cQuery +=           " AND D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
	If Self:oMovSeqAbt:GetTipoEnd() == '3' .And. Self:oMovPrdLot:HasRastro() .And. !Empty(Self:oMovPrdLot:GetLoteCtl())
		cQuery +=       " AND D14_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
	EndIf
	cQuery +=           " AND (D14_QTDEST+D14_QTDEPR) > 0"
	cQuery +=           " AND D_E_L_E_T_ = ' '"
	// Consultando o saldo de outros produtos
	cQuery +=         " UNION ALL "
	cQuery +=        " SELECT 0 SLD_PRODUT,"
	cQuery +=               " SUM(D14_QTDEST) SLD_OUTROS,"
	cQuery +=               " 0 MOV_PRODUT,"
	cQuery +=               " SUM(D14_QTDEPR) MOV_OUTROS"
	cQuery +=          " FROM "+RetSqlName("D14")+" D14"
	cQuery +=         " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=           " AND D14_LOCAL  = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=           " AND D14_ENDER = '"+cEndereco+"'"
	If Self:oMovSeqAbt:GetTipoEnd() == '3' .And. Self:oMovPrdLot:HasRastro() .And. !Empty(Self:oMovPrdLot:GetLoteCtl())
		cQuery +=       " AND ((D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
		cQuery +=       " AND D14_LOTECT <> '"+Self:oMovPrdLot:GetLoteCtl()+"')"
		cQuery +=        " OR (D14_PRODUT <> '"+Self:oMovPrdLot:GetProduto()+"'))"
	Else
		cQuery +=       " AND D14_PRODUT <>'"+Self:oMovPrdLot:GetProduto()+"'"
	EndIf
	cQuery +=           " AND (D14_QTDEST+D14_QTDEPR) > 0"
	cQuery +=           " AND D14.D_E_L_E_T_ = ' ') SLD"
	If lWMSQENSE
		cQueryPE := ExecBlock('WMSQENSE',.F.,.F.,{cQuery})
		If !Empty(cQueryPE)
			cQuery := cQueryPE
		EndIf
	EndIf
	cQuery := "%"+AllTrim(cQuery)+"%"
	cQuery := StrTran(cQuery,"%SELECT","%")
	cAliasD14 := GetNextAlias()
	BeginSql Alias cAliasD14
		SELECT %Exp:cQuery%
	EndSql
	// Ajustando o tamanho dos campos da query
	aTamSX3 := TamSx3('D14_QTDEST')
	TcSetField(cAliasD14,'SLD_PRODUT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'MOV_PRODUT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'SLD_OUTROS','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'MOV_OUTROS','N',aTamSX3[1],aTamSX3[2])
Return cAliasD14

METHOD FindNivSBE(cLocal,cLocaliz) CLASS WMSBCCEnderecamento
Local lRet      := .T.
Local cAliasSBE := GetNextAlias()
Local nValNv    := 0
	Self:aNivEndOri := {}
	BeginSql Alias cAliasSBE
		SELECT DC7_SEQUEN,
				DC7_POSIC,
				DC7_PESO1,
				DC7_PESO2,
				BE_LOCALIZ,
				BE_LOCALIZ,
				BE_VALNV1,
				BE_VALNV2,
				BE_VALNV3,
				BE_VALNV4,
				BE_VALNV5,
				BE_VALNV6
		FROM %Table:DC7% DC7
		INNER JOIN %Table:SBE% SBE
		ON SBE.BE_FILIAL = %xFilial:SBE%
		AND SBE.BE_LOCAL = %Exp:cLocal%
		AND SBE.BE_LOCALIZ = %Exp:cLocaliz%
		AND SBE.%NotDel%
		WHERE DC7.DC7_FILIAL = %xFilial:DC7%
		AND DC7.DC7_CODCFG = SBE.BE_CODCFG
		AND DC7.%NotDel%
		ORDER BY DC7.DC7_SEQUEN,
					DC7.DC7_POSIC,
					DC7.DC7_PESO1,
					DC7.DC7_PESO2
	EndSql
	TcSetField(cAliasSBE,'DC7_PESO1','N',15,0)
	TcSetField(cAliasSBE,'DC7_PESO2','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV1','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV2','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV3','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV4','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV5','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV6','N',15,0)
	Do While (cAliasSBE)->(!Eof()) .And. !Empty((cAliasSBE)->BE_LOCALIZ)
		// Niveis
		nValNv := 0
		If (cAliasSBE)->DC7_SEQUEN == "01"
			nValNv := (cAliasSBE)->BE_VALNV1
		ElseIf (cAliasSBE)->DC7_SEQUEN == "02"
			nValNv := (cAliasSBE)->BE_VALNV2
		ElseIf (cAliasSBE)->DC7_SEQUEN == "03"
			nValNv := (cAliasSBE)->BE_VALNV3
		ElseIf (cAliasSBE)->DC7_SEQUEN == "04"
			nValNv := (cAliasSBE)->BE_VALNV4
		ElseIf (cAliasSBE)->DC7_SEQUEN == "05"
			nValNv := (cAliasSBE)->BE_VALNV5
		ElseIf (cAliasSBE)->DC7_SEQUEN == "06"
			nValNv := (cAliasSBE)->BE_VALNV6
		EndIf
		aAdd(Self:aNivEndOri,{nValNv,(cAliasSBE)->DC7_PESO2,(cAliasSBE)->DC7_PESO1})
		(cAliasSBE)->(dbSkip())
	EndDo
	(cAliasSBE)->(DbCloseArea())
Return lRet
/*/-----------------------------------------------------------------------------
Adiciona mensagens ao registro de LOG de busca de endereços.
Formato aLogEnd
	aLogEnd[nX,1] = Documento
	aLogEnd[nX,2] = Serie
	aLogEnd[nX,3] = Produto
	aLogEnd[nX,4] = Descrição Produto
	aLogEnd[nX,5] = Lote
	aLogEnd[nX,6] = Quantidade Endereçar
	aLogEnd[nX,7] = Array(2)
		aLogEnd[nX,7,nY,1] = "Busca de endereços ..."
		aLogEnd[nX,7,nY,2] = Tipo Endereçamento
		aLogEnd[nX,7,nY,3] = Array(6)
			aLogEnd[nX,7,nY,3,nZ,01] = Estrutura Fisica
			aLogEnd[nX,7,nY,3,nZ,02] = Ordem Zona Armazenagem
			aLogEnd[nX,7,nY,3,nZ,03] = Ordem Produto
			aLogEnd[nX,7,nY,3,nZ,04] = Ordem Saldo
			aLogEnd[nX,7,nY,3,nZ,05] = Ordem Movimento
			aLogEnd[nX,7,nY,3,nZ,06] = Endereço
			aLogEnd[nX,7,nY,3,nZ,07] = Capacidade
			aLogEnd[nX,7,nY,3,nZ,08] = Saldo Endereço
			aLogEnd[nX,7,nY,3,nZ,09] = Saldo RF
			aLogEnd[nX,7,nY,3,nZ,10] = Quantidade Total a Endereçar
			aLogEnd[nX,7,nY,3,nZ,11] = Quantidade Endereçada
			aLogEnd[nX,7,nY,3,nZ,12] = Mensagem


-----------------------------------------------------------------------------/*/
METHOD AddMsgLog(cEstrtura,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndereco,nCapEnder,nSaldoD14,nSaldoRF,nTotEnd,nQtdEnd,cMensagem) CLASS WMSBCCEnderecamento
Local aLogMsg := Nil
	aLogMsg := Self:aLogEnd[Len(Self:aLogEnd),RELDETEST]
	AAdd(aLogMsg[Len(aLogMsg),3],{cEstrtura,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndereco,nCapEnder,nSaldoD14,nSaldoRF,nTotEnd,nQtdEnd,cMensagem})
Return (Nil)
