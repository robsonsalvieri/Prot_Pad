#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "WMSA508.CH"

#DEFINE WMSA50801 "WMSA50801"
#DEFINE WMSA50802 "WMSA50802"
#DEFINE WMSA50803 "WMSA50803"
#DEFINE WMSA50804 "WMSA50804"
#DEFINE WMSA50805 "WMSA50805"
#DEFINE WMSA50806 "WMSA50806"
#DEFINE WMSA50807 "WMSA50807"
#DEFINE WMSA50808 "WMSA50808"
#DEFINE WMSA50809 "WMSA50809"
#DEFINE WMSA50810 "WMSA50810"
#DEFINE WMSA50811 "WMSA50811"
#DEFINE WMSA50812 "WMSA50812"
#DEFINE WMSA50813 "WMSA50813"
#DEFINE WMSA50814 "WMSA50814"
#DEFINE WMSA50815 "WMSA50815"
#DEFINE WMSA50816 "WMSA50816"
#DEFINE WMSA50817 "WMSA50817"
#DEFINE WMSA50818 "WMSA50818"
#DEFINE WMSA50819 "WMSA50819"
#DEFINE WMSA50820 "WMSA50820"
//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} WMSA508
Geração Automática de Requisições OP para o WMS

@author  Alexsander Corrêa
@version P12
@Since	02/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Function WMSA508()
Private oBrwSC2
	// Pergunte
	If Pergunte('WMSA508',.T.)
		oBrwSC2 := FWMBrowse():New()
		oBrwSC2:SetAlias("SC2")
		oBrwSC2:SetMenuDef("WMSA508")
		oBrwSC2:SetFilterDefault("@"+Filtro())
		oBrwSC2:SetParam({|| SelFiltro() })
		oBrwSC2:AddLegend("A650DefLeg(1)","YELLOW" , STR0001) // Prevista
		oBrwSC2:AddLegend("A650DefLeg(2)","GREEN"  , STR0002) // Em Aberto
		oBrwSC2:AddLegend("A650DefLeg(3)","ORANGE" , STR0003) // Iniciada
		oBrwSC2:AddLegend("A650DefLeg(4)","GRAY"   , STR0004) // Ociosa
		oBrwSC2:AddLegend("A650DefLeg(5)","BLUE"   , STR0005) // Encerrada Parcialmente
		oBrwSC2:AddLegend("A650DefLeg(6)","RED"    , STR0006) // Encerrada Totalmente
		oBrwSC2:SetDescription("Ordem de Produção") // Ordem de Produção
		oBrwSC2:Activate()
	EndIf
Return(Nil)
//-------------------------------------------------------------------//
//-------------------------Função MenuDef----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0007 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.WMSA508' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0009 ACTION 'WMSA508GRQ()'    OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0010 ACTION 'WMSA508ERQ()'    OPERATION 4 ACCESS 0 // Calcula Multiplos
Return aRotina
//--------------------------------------------------------------------//
//-------------------------Função ModelDef----------------------------//
//--------------------------------------------------------------------//
Static Function ModelDef()
Local oModel     := MPFormModel():New('WMSA508')
Local oStructSC2 := FWFormStruct(1,'SC2')

	oModel:AddFields('MdFieldSC2',,oStructSC2)
	oModel:SetDescription(STR0011) // Ordem de Produção 
Return oModel
//-------------------------------------------------------------------//
//-------------------------Função ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oView      := FWFormView():New()
Local oModel     := FWLoadModel('WMSA508')
Local oStructSC2 := FWFormStruct(2,'SC2')
	oView:SetModel(oModel)
	oView:AddField('VwFieldSC2',oStructSC2,'MdFieldSC2')
Return oView
//-------------------------------------------------------------------//
//--------------------Seleção do filtro tecla F12--------------------//
//-------------------------------------------------------------------//
Static Function SelFiltro()
Local lRet := .T.
	If (lRet := Pergunte('WMSA508',.T.))
		oBrwSC2:SetFilterDefault("@"+Filtro())
		oBrwSC2:Refresh(.T.)
	EndIf
Return lRet
//-------------------------------------------------------------------//
//-------------------------------Filtro------------------------------//
//-------------------------------------------------------------------//
Static Function Filtro()
Local cFiltro   := ""
Local cDBMS     := Upper(TCGETDB())
	cFiltro += " C2_FILIAL = '"+xFilial('SC2')+"'"
	cFiltro += " AND C2_PRODUTO >= '"+MV_PAR01+"'"
	cFiltro += " AND C2_PRODUTO <= '"+MV_PAR02+"'"
	If "MSSQL" $ cDBMS
		cFiltro += " AND C2_NUM+C2_ITEM+C2_SEQUEN >= '"+MV_PAR03+"'"
		cFiltro += " AND C2_NUM+C2_ITEM+C2_SEQUEN <= '"+MV_PAR04+"'"
	Else
		cFiltro += " AND C2_NUM||C2_ITEM||C2_SEQUEN >= '"+MV_PAR03+"'"
		cFiltro += " AND C2_NUM||C2_ITEM||C2_SEQUEN <= '"+MV_PAR04+"'"
	EndIf
	cFiltro += " AND C2_DATPRF >= '"+DToS(MV_PAR05)+"'"
	cFiltro += " AND C2_DATPRF <= '"+DToS(MV_PAR06)+"'"
	cFiltro += " AND C2_DATPRI >= '"+DToS(MV_PAR07)+"'"
	cFiltro += " AND C2_DATPRI <= '"+DToS(MV_PAR08)+"'"
	cFiltro += " AND D_E_L_E_T_ = ' '"
Return cFiltro
//-----------------------------------------------------------
/*/{Protheus.doc} WMSA508GR
Gerar requisições OP vs WMS

@author Squad WMS Protheus
@version P12
@Since	29/04/19
@version 1.0
/*/
//-----------------------------------------------------------
Function WMSA508GRQ()
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
Local cOp       := Alltrim(SC2->C2_NUM)+Alltrim(SC2->C2_ITEM)+Alltrim(SC2->C2_SEQUEN)
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:SD4% SD4
		INNER JOIN %Table:SB1% SB1
		ON SB1.B1_FILIAL = %xFilial:SB1%
		AND SB1.B1_COD = SD4.D4_COD
		AND SB1.B1_TIPO <> 'MO'
		AND SB1.%NotDel%
		WHERE SD4.D4_FILIAL = %xFilial:SD4%
		AND SD4.D4_OP = %Exp:cOp%
		AND SD4.D4_QTDEORI = SD4.D4_QUANT
		AND SD4.D4_QTDEORI > 0
		AND SD4.D4_IDDCF = ' '
		AND NOT EXISTS( SELECT 1
						FROM %Table:SDC% SDC
						WHERE SDC.DC_FILIAL = %xFilial:SDC%
						AND SD4.D4_FILIAL = %xFilial:SD4%
						AND SDC.DC_PRODUTO = SD4.D4_COD
						AND SDC.DC_LOCAL = SD4.D4_LOCAL
						AND SDC.DC_OP = SD4.D4_OP
						AND SDC.DC_TRT = SD4.D4_TRT
						AND SDC.DC_LOTECTL = SD4.D4_LOTECTL
						AND SDC.%NotDel% )
		AND SD4.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		If IsBlind()
			WMSA508GRA(,cOp)
		Else
			Processa( {|| ProcRegua(100), IncProc(STR0012),WMSA508GRA(,cOp),IncProc(STR0012) } , STR0013, "..." + '...', .F.) // Aguarde... // Aguarde... // Processando...
		EndIf
	Else
		WmsMessage(WmsFmtMsg(STR0014,{{"[VAR01]",cOp}}),WMSA50819,5) // OP [VAR01] já requisitada ou não há itens à requisitar!
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return Nil
//-----------------------------------------------------------
/*/{Protheus.doc} WMSA508GR
Estorna requisições OP vs WMS

@author Squad WMS Protheus
@version P12
@Since	01/05/19
@version 1.0
/*/
//-----------------------------------------------------------
Function WMSA508ERQ()
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
Local cOp       := Alltrim(SC2->C2_NUM)+Alltrim(SC2->C2_ITEM)+Alltrim(SC2->C2_SEQUEN)

	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:SD4% SD4
		WHERE SD4.D4_FILIAL = %xFilial:SD4%
		AND SD4.D4_OP = %Exp:cOp%
		AND SD4.D4_QTDEORI = SD4.D4_QUANT
		AND SD4.D4_QTDEORI > 0
		AND SD4.D4_IDDCF <> ' '
		AND SD4.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		Processa( {|| ProcRegua(100), IncProc(STR0012),WMSA508EQA(,cOp),IncProc(STR0012) } , STR0013, "..." + '...', .F.) // Aguarde... // Aguarde... // Processando...
	Else
		WmsMessage(WmsFmtMsg(STR0015,{{"[VAR01]",cOp}}),WMSA50820,5) // OP [VAR01] não possui ordem de serviço de requisição gerada!
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return Nil
//-----------------------------------------------------------
/*/{Protheus.doc} WMSA508GRA
Gera requisições OP vs WMS

@author Squad WMS Protheus
@version P12
@Since	01/05/19
@version 1.0
/*/
//-----------------------------------------------------------
Function WMSA508GRA(lExibe,cOp,lSldPrd,cRegra,aResErro,aResOk,cEndOri)
Local lRet       := .T.
Local lContinua  := .T.
Local lRastro    := .F.
Local lDadosLot  := .F.
Local lWMSA508LO := ExistBlock("WMSA508LO")
Local lWMSA508EO := ExistBlock("WMSA508EO")
Local aTamSx3    := TamSx3("D14_QTDEST")
Local oEstEnder  := Nil
Local oOrdServ   := Nil
Local cAliasQry  := Nil
Local cLocOri    := ""
Local cLocDes    := ""
Local cEndDes    := ""
Local cProduto   := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cQuery     := ""
Local nQtdReq    := 0
Local nSldLot    := 0
Local nSldPrd    := 0
Local nSldWMS    := 0
Local nI         := 0
Local nNewRecno  := 0
Local lWMS508CW := isblind() .AND. ExistBlock("WMS508CW")
Local cWhere    := ""
Local cRetPE    := ""

Default cEndOri   := ""
Default lExibe    := .T.
Default lSldPrd   := .T.
Default cRegra    := "3"
DEfault cOp       := ' '
	// Inicializa array de mensagens de erro
	aResErro   := {}
	aResOk     := {}
	aExecErro  := {}
	// Validação
	If Empty(cOp) .AND. !lWMS508CW
		WMSA508RM(WMSA50801,aResErro,cOp,,,,,,STR0016) // Ordem de produção não informada!
		lRet := .F.
	EndIf
	// Busca requisições
	//Ponto de entrada para alteração do filtro de Ordens de produção podendo retornar mais de um OP . 
	cWhere := " AND SD4.D4_OP = '" + cOp + "' "
	If lWMS508CW
		cRetPE:=ExecBlock("WMS508CW",.F.,.F.,{cWhere})
		If Valtype(cRetPe) == "C"
			cWhere := cRetPE
		EndIf
	EndIf
	cWhere :=  "%" + cWhere
	cWhere +=  "%"
	
	If lRet
		
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SB1.B1_LOCPAD,
					SB5.B5_SERVREQ,
					SB5.B5_ENDREQ,
					SD4.D4_LOCAL,
					SD4.D4_COD,
					SD4.D4_LOTECTL,
					SD4.D4_NUMLOTE,
					SUM(SD4.D4_QUANT) D4_QUANT
			FROM %Table:SD4% SD4
			INNER JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SD4.D4_COD
			AND SB1.B1_TIPO <> 'MO'
			AND SB1.%NotDel%
			INNER JOIN %Table:SB5% SB5
			ON SB5.B5_FILIAL = %xFilial:SB5%
			AND SB5.B5_COD = SD4.D4_COD
			AND SB5.%NotDel%
			WHERE SD4.D4_FILIAL = %xFilial:SD4%
			AND SD4.D4_QTDEORI = SD4.D4_QUANT
			AND SD4.D4_QTDEORI > 0
			AND SD4.D4_IDDCF = ' '
			%Exp:cWhere%
			AND NOT EXISTS( SELECT 1
							FROM %Table:SDC% SDC
							WHERE SDC.DC_FILIAL = %xFilial:SDC%
							AND SD4.D4_FILIAL = %xFilial:SD4%
							AND SDC.DC_PRODUTO = SD4.D4_COD
							AND SDC.DC_LOCAL = SD4.D4_LOCAL
							AND SDC.DC_OP = SD4.D4_OP
							AND SDC.DC_LOTECTL = SD4.D4_LOTECTL
							AND SDC.DC_TRT = SD4.D4_TRT
							AND SDC.%NotDel% )
			AND SD4.%NotDel%
			
			GROUP BY SB1.B1_LOCPAD,
						SB5.B5_SERVREQ,
						SB5.B5_ENDREQ,
						SD4.D4_LOCAL,
						SD4.D4_COD,
						SD4.D4_LOTECTL,
						SD4.D4_NUMLOTE
			ORDER BY SD4.D4_COD,
						SD4.D4_LOTECTL DESC
		EndSql
		If (cAliasQry)->(!Eof())
			oEstEnder  := WMSDTCEstoqueEndereco():New()
			oOrdServ   := WMSDTCOrdemServicoCreate():New()
			// Passa a referência da OS para a função
			WmsOrdSer(oOrdServ)
			Do While (cAliasQry)->(!Eof())
				lContinua := .T.
				// Inicializa variáveis
				cLocOri   := (cAliasQry)->D4_LOCAL
				cProduto  := (cAliasQry)->D4_COD
				cLoteCtl  := (cAliasQry)->D4_LOTECTL
				cNumLote  := (cAliasQry)->D4_NUMLOTE
				cLocDes   := (cAliasQry)->D4_LOCAL
				cEndDes   := (cAliasQry)->B5_ENDREQ
				cServReq  := (cAliasQry)->B5_SERVREQ
				nQtdReq   := (cAliasQry)->D4_QUANT
				lDadosLot := !Empty(cLoteCtl)
				// Valida Rastro
				dbSelectArea("SB1")
				lRastro   := Rastro(cProduto)
				If IntWms(cProduto)
					// PE para indicar o endereço origem
					If lWMSA508LO
						cLocOriPE := ExecBlock('WMSA508LO',.F.,.F.,{cLocOri,cProduto})
						cLocOri := IIf(ValType(cLocOriPE) == 'C',cLocOriPE,cLocOri)
					EndIf
					
					If lWMSA508EO
						cEndOriPE := ExecBlock('WMSA508EO',.F.,.F.,{cLocOri,cProduto})
						cEndOri := IIf(ValType(cEndOriPE) == 'C',cEndOriPE,cEndOri)
					EndIf
					// Validações
					If Empty(cLocOri)
						WMSA508RM(WMSA50802,aResErro,cOp,,cProduto,cLoteCtl,cNumLote,nQtdReq,STR0017) // Armazém padrão não informado no cadastro do produto (SB1)!
						lContinua := .F.
					EndIf
					If Empty(cEndDes)
						WMSA508RM(WMSA50803,aResErro,cOp,,cProduto,cLoteCtl,cNumLote,nQtdReq,STR0018) // Endereço destino não informado no cadastro de complementos do produto (SB5)!
						lContinua := .F.
					EndIf
					If Empty(cServReq)
						WMSA508RM(WMSA50804,aResErro,cOp,,cProduto,cLoteCtl,cNumLote,nQtdReq,STR0019) // Serviço WMS não informado no cadatro de complementos do produto (SB5)!
						lContinua := .F.
					EndIf
					If lContinua
						// Se indicado que ultiliza saldo de produção
						// busca o saldo do endereço de produção
						If lSldPrd
							cQuery :=         "% D14.D14_PRODUT,"
							If lRastro
								If lDadosLot
									cQuery +=  " D14.D14_LOTECT,"
									cQuery +=  " D14.D14_NUMLOT,"
								EndIf
								cQuery +=      " CASE WHEN LOT.B8_SLDLOT IS NULL THEN 0 ELSE LOT.B8_SLDLOT END B8_SLDLOT,"
							EndIf
							cQuery +=          " SUM(D14.D14_QTDEST- (D14.D14_QTDSPR+D14.D14_QTDBLQ+D14.D14_QTDEMP)) D14_SLDPRD"
							cQuery +=     " FROM "+RetSqlName("D14")+" D14"
							If lRastro
								cQuery +=    " INNER JOIN "+RetSqlName("DC8")+" DC8"
								cQuery +=       " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
								cQuery +=      " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
								cQuery +=      " AND DC8.DC8_TPESTR = '7'"
								cQuery +=      " AND DC8.D_E_L_E_T_ = ' '"
								cQuery +=     " LEFT JOIN (SELECT SB8.B8_PRODUTO,"
								cQuery +=                       " SB8.B8_LOCAL,"
								If lDadosLot
									cQuery +=                   " SB8.B8_LOTECTL,"
									cQuery +=                   " SB8.B8_NUMLOTE,"
								EndIf
								cQuery +=                       " SUM(SB8.B8_SALDO - SB8.B8_EMPENHO) B8_SLDLOT"
								cQuery +=                  " FROM "+RetSqlName("SB8")+" SB8"
								cQuery +=                 " WHERE SB8.B8_FILIAL = '"+xFilial("SB8")+"'"
								cQuery +=                   " AND SB8.D_E_L_E_T_ = ' '"
								cQuery +=                 " GROUP BY SB8.B8_PRODUTO,"
								cQuery +=                          " SB8.B8_LOCAL "+IIf(lDadosLot,",","")
								If lDadosLot
									cQuery +=                      " SB8.B8_LOTECTL,"
									cQuery +=                      " SB8.B8_NUMLOTE"
								EndIf
								cQuery +=               " ) LOT"
								cQuery +=       " ON LOT.B8_PRODUTO = D14.D14_PRODUT"
								cQuery +=      " AND LOT.B8_LOCAL = D14.D14_LOCAL"
								If lDadosLot
									cQuery +=  " AND LOT.B8_LOTECTL = D14.D14_LOTECT"
									cQuery +=  " AND LOT.B8_NUMLOTE = D14.D14_NUMLOT"
								EndIf
							EndIf
							cQuery +=    " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
							cQuery +=      " AND D14.D14_LOCAL = '"+cLocDes+"'"
							cQuery +=      " AND D14.D14_ENDER = '"+cEndDes+"'"
							cQuery +=  " AND D14.D14_PRODUT = '"+cProduto+"'"
							If lRastro .And. lDadosLot
								cQuery +=  " AND D14.D14_LOTECT = '"+cLoteCtl+"'"
								cQuery +=  " AND D14.D14_NUMLOT = '"+cNumLote+"'"
							EndIf
							cQuery +=      " AND D14.D_E_L_E_T_ = ' '"
							cQuery +=    " GROUP BY D14.D14_PRODUT"
							If lRastro
								cQuery +=    ","
								If lDadosLot
									cQuery +=         " D14.D14_LOTECT,"
									cQuery +=         " D14.D14_NUMLOT,"
								EndIf
								cQuery +=             " LOT.B8_SLDLOT"
							EndIf
							cQuery += "%"
							cAliasD14 := GetNextAlias()
							BeginSql Alias cAliasD14
								SELECT %Exp:cQuery% 
							EndSql
							TcSetField(cAliasD14,'D14_SLDPRD','N',aTamSx3[1],aTamSx3[2])
							If lRastro
								TcSetField(cAliasD14,'B8_SLDLOT','N',aTamSx3[1],aTamSx3[2])
							EndIf
							If (cAliasD14)->(!Eof())
								If lRastro
									nSldLot := IIf(lDadosLot,(cAliasD14)->B8_SLDLOT + nQtdReq,(cAliasD14)->B8_SLDLOT)
									nSldPrd := IIf(QtdComp(nSldLot) < QtdComp((cAliasD14)->D14_SLDPRD), (cAliasD14)->B8_SLDLOT, (cAliasD14)->D14_SLDPRD)
								Else
									nSldPrd := (cAliasD14)->D14_SLDPRD
								EndIf
							EndIf
							(cAliasD14)->(dbCloseArea())
						EndIf
						// busca saldo no endereço WMS
						cAliasD14 := GetNextAlias()
						cQuery :=        "% D14.D14_PRODUT,"
						If lRastro
							If lDadosLot
								cQuery += " D14.D14_LOTECT,"
								cQuery += " D14.D14_NUMLOT,"
							EndIf
							cQuery +=     " CASE WHEN LOT.B8_SLDLOT IS NULL THEN 0 ELSE LOT.B8_SLDLOT END B8_SLDLOT,"
						EndIf
						cQuery +=         " SUM(D14.D14_QTDEST- (D14.D14_QTDSPR+D14.D14_QTDBLQ+D14.D14_QTDEMP)) D14_SLDWMS"
						cQuery +=    " FROM "+RetSqlName("D14")+" D14"
						If lRastro
							cQuery +=   " INNER JOIN "+RetSqlName("DC8")+" DC8"
							cQuery +=      " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
							cQuery +=     " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
							cQuery +=     " AND DC8.DC8_TPESTR <> '7'"
							cQuery +=     " AND DC8.D_E_L_E_T_ = ' '"
							cQuery +=    " LEFT JOIN (SELECT SB8.B8_PRODUTO,"
							cQuery +=                      " SB8.B8_LOCAL,"
							If lDadosLot
								cQuery +=                  " SB8.B8_LOTECTL,"
								cQuery +=                  " SB8.B8_NUMLOTE,"
							EndIf
							cQuery +=                      " SUM(SB8.B8_SALDO - SB8.B8_EMPENHO) B8_SLDLOT"
							cQuery +=                 " FROM "+RetSqlName("SB8")+" SB8"
							cQuery +=                " WHERE SB8.B8_FILIAL = '"+xFilial("SB8")+"'"
							cQuery +=                  " AND SB8.D_E_L_E_T_ = ' '"
							cQuery +=                " GROUP BY SB8.B8_PRODUTO,"
							cQuery +=                         " SB8.B8_LOCAL "+IIf(lDadosLot,",","")
							If lDadosLot
								cQuery +=                     " SB8.B8_LOTECTL,"
								cQuery +=                     " SB8.B8_NUMLOTE"
							EndIf
							cQuery +=             " ) LOT"
							cQuery +=      " ON LOT.B8_PRODUTO = D14.D14_PRODUT
							cQuery +=     " AND LOT.B8_LOCAL = D14.D14_LOCAL
							If lDadosLot
								cQuery += " AND LOT.B8_LOTECTL = D14.D14_LOTECT
								cQuery += " AND LOT.B8_NUMLOTE = D14.D14_NUMLOT
							EndIf
						EndIf
						cQuery +=   " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
						cQuery +=     " AND D14.D14_LOCAL = '"+cLocOri+"'"
						If !Empty(cEndOri)
							cQuery += " AND D14.D14_ENDER = '"+cEndOri+"'"
						EndIf
						cQuery +=     " AND D14.D14_PRODUT = '"+cProduto+"'"
						If lRastro .And. lDadosLot
							cQuery += " AND D14.D14_LOTECT = '"+cLoteCtl+"'"
							cQuery += " AND D14.D14_NUMLOT = '"+cNumLote+"'"
						EndIf
						cQuery +=     " AND D14.D_E_L_E_T_ = ' '"
						cQuery +=   " GROUP BY D14.D14_PRODUT"
						If lRastro 
							cQuery +=    ","
							If lDadosLot
								cQuery +=        " D14.D14_LOTECT,"
								cQuery +=        " D14.D14_NUMLOT,"
							EndIf
							cQuery +=            " LOT.B8_SLDLOT
						EndIf
						cQuery += "%"
						BeginSql Alias cAliasD14
							SELECT %Exp:cQuery%
						EndSql
						TcSetField(cAliasD14,'D14_SLDWMS','N',aTamSx3[1],aTamSx3[2])
						If lRastro
							TcSetField(cAliasD14,'B8_SLDLOT','N',aTamSx3[1],aTamSx3[2])
						EndIf
						If (cAliasD14)->(!Eof())
							// Quando produto controla lote e o lote estiver informado considera o saldo no WMS
							If lRastro .And. !lDadosLot
								nSldWms := IIf(QtdComp((cAliasD14)->B8_SLDLOT) < QtdComp((cAliasD14)->D14_SLDWMS), (cAliasD14)->B8_SLDLOT, (cAliasD14)->D14_SLDWMS)
							Else
								nSldWms := (cAliasD14)->D14_SLDWMS
							EndIf
						EndIf	
						(cAliasD14)->(dbCloseArea())
						If QtdComp(nQtdReq) > (QtdComp(nSldPrd + nSldWms))
							WMSA508RM(WMSA50805,aResErro,cOp,,cProduto,cLoteCtl,cNumLote,nQtdReq,STR0020) // Não há saldo disponível para atender a requisição!
							lContinua := .F.
						EndIf
						If lContinua
							nQtdSol := IIf(QtdComp(nQtdReq - nSldPrd) > 0,nQtdReq - nSldPrd,0)
							If QtdComp(nSldPrd) > 0
								// Verifica requisições
								cAliasQr2 := GetNextAlias()
								BeginSql Alias cAliasQr2
									SELECT SD4.R_E_C_N_O_ RECNOSD4
									FROM %Table:SD4% SD4
									WHERE SD4.D4_FILIAL = %xFilial:SD4%
									AND SD4.D4_LOCAL = %Exp:cLocDes%
									AND SD4.D4_COD = %Exp:cProduto%
									AND SD4.D4_LOTECTL = %Exp:cLoteCtl%
									AND SD4.D4_NUMLOTE = %Exp:cNumLote%
									AND SD4.D4_QTDEORI = SD4.D4_QUANT
									AND SD4.D4_QTDEORI > 0
									AND SD4.%NotDel%
									%Exp:cWhere%
									AND SD4.D4_IDDCF = ' '
									AND NOT EXISTS( SELECT 1
													FROM %Table:SDC% SDC
													WHERE SDC.DC_FILIAL = %xFilial:SDC%
													AND SD4.D4_FILIAL = %xFilial:SD4%
													AND SDC.DC_PRODUTO = SD4.D4_COD
													AND SDC.DC_LOCAL = SD4.D4_LOCAL
													AND SDC.DC_OP = SD4.D4_OP
													AND SDC.DC_LOTECTL = SD4.D4_LOTECTL
													AND SDC.DC_TRT = SD4.D4_TRT
													AND SDC.%NotDel% )
								EndSql
								Do While (cAliasQr2)->(!Eof()) .And. lContinua .And. nSldPrd > 0
									SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
									nQtdRat := IIf(QtdComp(nSldPrd) >= QtdComp(SD4->D4_QUANT),SD4->D4_QUANT,nSldPrd)
									Do While nQtdRat > 0 .And. lContinua
										lContinua := .T.
										// Busca saldo do produto no endereço de produção
										// Quando controla lote e o lote não foi informado no
										// Empenho de requisição, irá buscar o lote mais antigo, priorizando
										// o lote que atende na completude
										oEstEnder:ClearData()
										oEstEnder:oProdLote:SetArmazem(cLocDes)
										oEstEnder:oProdLote:SetProduto(cProduto)
										oEstEnder:oProdLote:SetPrdOri(cProduto)
										oEstEnder:oProdLote:SetLoteCtl(cLoteCtl)
										oEstEnder:oProdLote:SetNumLote(cNumLote)
										oEstEnder:oProdLote:SetNumSer("")
										oEstEnder:oProdLote:LoadData()
										// Atribui dados do endereço de produção
										oEstEnder:oEndereco:SetArmazem(cLocDes)
										oEstEnder:oEndereco:SetEnder(cEndDes)
										
										If oEstEnder:FindSldPrd(nQtdRat)
											// Gera empenho da quantidade saldo produção
											SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
											WmsDivSD4(SD4->D4_COD,;
														oEstEnder:oEndereco:GetArmazem(),;
														SD4->D4_OP,;
														SD4->D4_TRT,;
														oEstEnder:oProdLote:GetLoteCtl(),;
														oEstEnder:oProdLote:GetNumLote(),;
														Nil,;
														oEstEnder:GetQuant(),;
														Nil,;
														oEstEnder:oEndereco:GetEnder(),;
														Nil,;
														.T.,;
														Nil,;
														Nil,;
														@nNewRecno)
											// Gera empenho no estoque por endereço
											SD4->(dbGoTo(nNewRecno))
											oEstEnder:UpdSaldo("499",.F. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.T. /*lEmpenho*/,.F. /*lBloqueio*/)
											// Empenha SB2 e SB8
											If lRastro .And. !lDadosLot
												GravaEmp(SD4->D4_COD,;        // Produto
															SD4->D4_LOCAL,;   // Armazem
															SD4->D4_QUANT,;   // Quantidade
															Nil,;             // Quantidade 2 UM
															SD4->D4_LOTECTL,; // Lote
															SD4->D4_NUMLOTE,; // Sub-Lote
															Nil,;             // Endereço
															Nil,;             // Número de série
															SD4->D4_OP,;      // Ordem de produção
															SD4->D4_TRT,;     // Trt Op
															Nil,; // Pedido
															Nil,; // Seq. Pedido
															'SD4',; // Origem
															Nil,; // Op Origem
															Nil,; // Data Entrega
															Nil,; // aTravas
															Nil,; // Estorno
															Nil,; // Projeto
															.F.,; // Empenha SB2
															.F.,; // Grava SD4
															Nil,; // Consulta Vencidos
															.T.,; // Empenha SB8/SBF
															Nil,; // Cria SDC
															Nil,; // Encerra Op
															Nil,; // IdDCF
															Nil,; // aSalvCols
															Nil,; // nSG1
															Nil,; // OpEncer
															Nil,; // TpOp 
															Nil,; // CAT83
															Nil,; // Data Emissão
															Nil,; // Grava Lote
															Nil) // aSDC
											EndIf
											WMSA508RM(WMSA50806,aResOk,cOp,SD4->D4_TRT,cProduto,cLoteCtl,cNumLote,nQtdReq,STR0021) // Quantidade empenhada
											nQtdRat -= SD4->D4_QUANT
											nSldPrd -= SD4->D4_QUANT
										Else
											WMSA508RM(WMSA50807,aResErro,cOp,SD4->D4_TRT,cProduto,cLoteCtl,cNumLote,nQtdReq,oEstEnder:GetErro())
											lContinua := .F.
										EndIf
									EndDo
									(cAliasQr2)->(dbSkip())
								EndDo
								(cAliasQr2)->(dbCloseArea())
							EndIf
							// Se ainda houver quantidade do produto requisitado, é criado a DCF
							If QtdComp(nQtdSol) > 0
								Begin Transaction
									// Dados serviço
									oOrdServ:oServico:SetServico(cServReq)
									// Dados produto
									oOrdServ:oProdLote:SetArmazem(cLocOri)
									oOrdServ:oProdLote:SetProduto(cProduto)
									oOrdServ:oProdLote:SetPrdOri(cProduto)
									oOrdServ:oProdLote:SetLoteCtl(cLoteCtl)
									oOrdServ:oProdLote:SetNumLote(cNumLote)
									// Dados endereço origem
									oOrdServ:oOrdEndOri:SetArmazem(cLocOri)
									oOrdServ:oOrdEndOri:SetEnder(cEndOri)
									// Dados endereço destino
									oOrdServ:oOrdEndDes:SetArmazem(cLocDes)
									oOrdServ:oOrdEndDes:SetEnder(cEndDes)
									// Dados gerais
									oOrdServ:SetOrigem("SD4")
									oOrdServ:SetRegra(cRegra)
									oOrdServ:SetQuant(nQtdSol)
									If oOrdServ:CreateDCF()
										// Verifica requisições
										cAliasQr2 := GetNextAlias()
										BeginSql Alias cAliasQr2
											SELECT SD4.R_E_C_N_O_ RECNOSD4
											FROM %Table:SD4% SD4
											WHERE SD4.D4_FILIAL = %xFilial:SD4%
											AND SD4.D4_LOCAL = %Exp:cLocDes%
											AND SD4.D4_COD = %Exp:cProduto%
											AND SD4.D4_LOTECTL = %Exp:cLoteCtl%
											AND SD4.D4_NUMLOTE = %Exp:cNumLote%
											AND SD4.D4_QTDEORI = SD4.D4_QUANT
											AND SD4.D4_QTDEORI > 0
											AND SD4.%NotDel%
											%Exp:cWhere%
											AND SD4.D4_IDDCF = ' '
											AND NOT EXISTS( SELECT 1
													FROM %Table:SDC% SDC
													WHERE SDC.DC_FILIAL = %xFilial:SDC%
													AND SD4.D4_FILIAL = %xFilial:SD4%
													AND SDC.DC_PRODUTO = SD4.D4_COD
													AND SDC.DC_LOCAL = SD4.D4_LOCAL
													AND SDC.DC_OP = SD4.D4_OP
													AND SDC.DC_TRT = SD4.D4_TRT
													AND SDC.DC_LOTECTL = SD4.D4_LOTECTL
													AND SDC.%NotDel% )
										EndSql
										If (cAliasQr2)->(!Eof())
											nSldPrd   := nQtdSol
											Do While lRet .And. (cAliasQr2)->(!Eof()) .And. QtdComp(nSldPrd) > 0
												SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
												RecLock('SD4',.F.)
												SD4->D4_IDDCF := oOrdServ:GetIdDCF()
												SD4->(MsUnLock())
												// Se for uma origem 
												If lRet .And. !(cLocOri == cLocDes)
													// Dados lote e sublote
													oOrdServ:oProdLote:SetLoteCtl(SD4->D4_LOTECTL)
													oOrdServ:oProdLote:SetNumLote(SD4->D4_NUMLOTE)
													// Dados Requisição
													oOrdServ:SetOp(SD4->D4_OP)
													oOrdServ:SetTrt(SD4->D4_TRT)
													oOrdServ:SetQuant(SD4->D4_QUANT)
													lRet := WmsGeraDH1("WMSXFUNJ",.F.,.F.)
												EndIf
												If lRet
													nSldPrd -= SD4->D4_QUANT
													WMSA508RM(WMSA50808,aResOk,SD4->D4_OP,SD4->D4_TRT,SD4->D4_COD,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_QUANT,WmsFmtMsg(STR0022,{{"[VAR01]",AllTrim(SD4->D4_IDDCF)}})) // Ordem de serviço [VAR01] gerada
												EndIf
												(cAliasQr2)->(dbSkip())
											EndDo
										EndIf
										(cAliasQr2)->(dbCloseArea())
									Else
										WMSA508RM(WMSA50809,aResErro,cOp,,cProduto,cLoteCtl,cNumLote,nQtdReq,oOrdServ:GetErro())
										DisarmTransaction()
									EndIf
								End Transaction
							EndIf
						EndIf
					EndIf
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			// Verifica as Ordens de servico geradas para execução automatica
			WmsExeServ()
			// Carrega listagem de erro de execução
			For nI := 1 To Len(oOrdServ:aWmsAviso)
				WMSA508RM(WMSA50810,aResErro,,,,,,,oOrdServ:aWmsAviso[nI])
			Next nI
			// Resumo problemas processo
			If lExibe
				WMSA508AR(oOrdServ,aResErro,aResOk)
			EndIf
			oOrdServ:Destroy()
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} WMSA508EQA
Estorno das requisições da OP selecionada

@author Squad WMS Protheus
@since 01/05/19
@version 1.0
/*/
//--------------------------------------------------------------------
Function WMSA508EQA(lExibe,cOp,aResErro,aResOk)
Local lRet      := .T.
Local lEstorno  := .F.
Local lOutraOp  := .F.
Local oOrdSerDel:= WMSDTCOrdemServicoDelete():New()
Local aAreaDCF  := DCF->(GetArea())
Local aTamSX3   := TamSx3("D4_QUANT")
Local cQuery    := ""
Local cAliasQry := ""
Local cAliasQr1 := ""
Local cAliasQr2 := ""
Local cAliasDH1 := ""
Local cIdDCF    := ""
Local cCod      := ""
Local cTrt      := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local nQtdReq   := 0
Local nQuant    := 0
Local nQtdOri   := 0

Default lExibe := .T.
	// Inicializa array de mensagens de erro
	aResErro   := {}
	aResOk     := {}
	aExecErro  := {}
	// Validação
	If Empty(cOp)
		WMSA508RM(WMSA50801,aResErro,cOp,,,,,,STR0016) // Ordem de produção não informada!
		lRet := .F.
	EndIf
	// Verifica se há alguma requisição selecionada
	If lRet
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD4.D4_COD,
					SD4.D4_TRT,
					SD4.D4_LOTECTL,
					SD4.D4_NUMLOTE,
					SD4.D4_IDDCF,
					SD4.D4_QUANT,
					SD4.D4_QTDEORI 
			FROM %Table:SD4% SD4
			WHERE SD4.D4_FILIAL = %xFilial:SD4%
			AND SD4.D4_OP = %Exp:cOp%
			AND SD4.D4_IDDCF <> ' '
			AND SD4.D4_QTDEORI > 0
			AND SD4.%NotDel%
		EndSql
		Do While (cAliasQry)->(!Eof())
			lEstorno  := .F.
			lOutraOp  := .F.
			cCod      := (cAliasQry)->D4_COD
			cTrt      := (cAliasQry)->D4_TRT
			cLoteCtl  := (cAliasQry)->D4_LOTECTL
			cNumLote  := (cAliasQry)->D4_NUMLOTE
			cIdDCF    := (cAliasQry)->D4_IDDCF
			nQuant    := (cAliasQry)->D4_QUANT
			nQtdOri   := (cAliasQry)->D4_QTDEORI
			// Carrega ordem de serviço
			oOrdSerDel:SetIdDCF(cIdDCF)
			If oOrdSerDel:LoadData()
				// Verifica se há mais de uma requisições para ordem de serviço
				cAliasQr1 := GetNextAlias()
				BeginSql Alias cAliasQr1
					SELECT 1
					FROM %Table:SD4% SD4
					WHERE SD4.D4_FILIAL = %xFilial:SD4%
					AND SD4.D4_IDDCF = %Exp:cIdDCF%
					AND (SD4.D4_OP <> %Exp:cOp%
					OR (SD4.D4_OP = %Exp:cOp% AND SD4.D4_TRT <> %Exp:cTrt% ))
					AND SD4.D4_QTDEORI > 0
					AND SD4.%NotDel%
				EndSql			
				If (cAliasQr1)->(!Eof())
					lOutraOp := .T.
				EndIf
				(cAliasQr1)->(dbCloseArea())
				
				Begin Transaction
					lEstorno := .F.
					If !lOutraOp
						If QtdComp(nQuant) == QtdComp(nQtdOri)
							If oOrdSerDel:CanDelete()
								If oOrdSerDel:DeleteDCF()
									If !(oOrdSerDel:oOrdEndOri:GetArmazem() == oOrdSerDel:oOrdEndDes:GetArmazem())
										cAliasDH1 := GetNextAlias()
										BeginSql Alias cAliasDH1
											SELECT R_E_C_N_O_ RECNODH1
											FROM %Table:DH1% DH1
											WHERE DH1.DH1_FILIAL = %xFilial:DH1%
											AND DH1.DH1_IDDCF = %Exp:oOrdSerDel:GetIdDCF()%
											AND DH1.%NotDel%
										EndSql
										Do While (cAliasDH1)->(!Eof())
											DH1->(dbGoTo((cAliasDH1)->RECNODH1))
											RecLock("DH1",.F.)
											DH1->(dbDelete())
											DH1->(MsUnlock())
											(cAliasDH1)->(dbSkip())
										EndDo
										(cAliasDH1)->(dbCloseArea())
										// Retira a reserva da SB2 da quantidade cancelada
										oOrdSerDel:UpdEmpSB2("-",oOrdSerDel:oProdLote:GetPrdOri(),oOrdSerDel:oOrdEndOri:GetArmazem(),oOrdSerDel:GetQuant())
									EndIf
									lEstorno := .T.
									// Dados do resumo
									WMSA508RM(WMSA50811,aResOk,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0023,{{"[VAR01]",AllTrim(cIdDCF)}})) // Ordem de serviço [VAR01] excluída!
								EndIf
							EndIf
							If !lEstorno
								WMSA508RM(WMSA50812,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,oOrdSerDel:GetErro())
							EndIf
						Else
							WMSA508RM(WMSA50813,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0024,{{"[VAR01]",AllTrim(cIdDCF)}})) // A ordem de serviço [VAR01] não pode ser estornada, requisiçao já possui baixa!
						EndIf
					ElseIf oOrdSerDel:GetStServ() == "3" 
						WMSA508RM(WMSA50814,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0025,{{"[VAR01]",AllTrim(cIdDCF)}})) // A ordem de serviço [VAR01] deverá ser estornada manualmente no WMS.
					Else
						// Verifica requisições
						cAliasQr1 := GetNextAlias()
						BeginSql Alias cAliasQr1
							SELECT SUM(SD4.D4_QUANT) D4_QUANT,
									SUM(SD4.D4_QTDEORI) D4_QTDEORI
							FROM %Table:SD4% SD4
							WHERE SD4.D4_FILIAL = %xFilial:SD4%
							AND SD4.D4_IDDCF = %Exp:cIdDCF%
							AND SD4.%NotDel%
						EndSql
						TcSetField(cAliasQr1,'D4_QUANT','N',aTamSX3[1],aTamSX3[2])
						TcSetField(cAliasQr1,'D4_QTDEORI','N',aTamSX3[1],aTamSX3[2])
						If (cAliasQr1)->D4_QUANT <> (cAliasQr1)->D4_QTDEORI
							WMSA508RM(WMSA50815,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0026,{{"[VAR01]",AllTrim(cIdDCF)}})) // A ordem de serviço [VAR01] não pode ser estornada, existem requisiçoes baixadas!
						Else
							lEstorno := .T.
							oOrdSerDel:SetQuant(oOrdSerDel:GetQuant() - nQuant)
							oOrdSerDel:SetQtdOri(oOrdSerDel:GetQtdOri() - nQuant)
							oOrdSerDel:UpdateDCF()
							If oOrdSerDel:ChkMovEst(.F.)
								lRet := oOrdSerDel:ReverseMO(nQuant)
								If lRet
									lRet := oOrdSerDel:ReverseMI(nQuant)
								EndIf
							EndIf
							// Verifica se existe movimentos para a ordem de serviço se não existir excluir a ordem de serviço
							If oOrdSerDel:GetQuant() == 0
								lEstorno := oOrdSerDel:CancelDCF()
							EndIf
							If lEstorno
								If !(oOrdSerDel:oOrdEndOri:GetArmazem() == oOrdSerDel:oOrdEndDes:GetArmazem())
									// Atualiza DH1
									cAliasDH1 := GetNextAlias()
									cQuery :=        "% DH1.R_E_C_N_O_ RECNODH1
									cQuery +=    " FROM "+RetSqlName("DH1")+" DH1"
									cQuery +=   " WHERE DH1.DH1_FILIAL = '"+xFilial("DH1")+"'"
									cQuery +=     " AND DH1.DH1_IDDCF = '"+oOrdSerDel:GetIdDCF()+"'"
									If !Empty(oOrdSerDel:oProdLote:GetLoteCtl())
										cQuery += " AND DH1.DH1_LOTECT = '"+oOrdSerDel:oProdLote:GetLoteCtl()+"'"
									EndIf
									If !Empty(oOrdSerDel:oProdLote:GetNumLote())
										cQuery += " AND DH1.DH1_NUMLOT = '"+oOrdSerDel:oProdLote:GetNumLote()+"'"
									EndIf
									cQuery +=     " AND DH1.D_E_L_E_T_ = ' '"
									cQuery += "%"
									BeginSql Alias cAliasDH1
										SELECT %Exp:cQuery%
									EndSql
									If (cAliasDH1)->(!Eof())
										nQtdReq := nQuant
										Do While (cAliasDH1)->(!Eof()) .And. nQtdReq > 0
											DH1->(dbGoTo((cAliasDH1)->RECNODH1))
											RecLock("DH1",.F.)
											If QtdComp(DH1->DH1_QUANT) <= QtdComp(nQtdReq)
												nQtdReq -= DH1->DH1_QUANT
												DH1->DH1_QUANT := 0
											Else
												DH1->DH1_QUANT -= nQtdReq
												nQtdReq := 0
											EndIf
											If DH1->DH1_QUANT <= 0
												DH1->(dbDelete())
											EndIf
											DH1->(MsUnlock())
											(cAliasDH1)->(dbSkip())
										EndDo
									EndIf
									(cAliasDH1)->(dbCloseArea())
									// Retira a reserva da SB2 da quantidade cancelada
									oOrdSerDel:UpdEmpSB2("-",oOrdSerDel:oProdLote:GetPrdOri(),oOrdSerDel:oOrdEndOri:GetArmazem(),nQuant)
								EndIf
							EndIf
							If !lEstorno
								WMSA508RM(WMSA50816,aResErro,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,oOrdSerDel:GetErro())
							Else
								// Dados do resumo
								WMSA508RM(WMSA50817,aResOk,cOp,cTrt,cCod,cLoteCtl,cNumLote,nQuant,WmsFmtMsg(STR0027,{{"[VAR01]",AllTrim(cIdDCF)}})) // Ordem Serviço [VAR01] alterada!
							EndIf
						EndIf
						(cAliasQr1)->(dbCloseArea())
					EndIf
					If lEstorno
						// Apaga a IDDCF da SD4
						cAliasQr1 := GetNextAlias()
						BeginSql Alias cAliasQr1
							SELECT SD4.R_E_C_N_O_ RECNOSD4
							FROM %Table:SD4% SD4
							WHERE SD4.D4_FILIAL = %xFilial:SD4%
							AND SD4.D4_COD = %Exp:cCod%
							AND SD4.D4_OP = %Exp:cOp%
							AND SD4.D4_TRT = %Exp:cTrt%
							AND SD4.D4_LOTECTL = %Exp:oOrdSerDel:oProdLote:GetLoteCtl()%
							AND SD4.D4_NUMLOTE = %Exp:oOrdSerDel:oProdLote:GetNumLote()%
							AND SD4.D4_IDDCF = %Exp:cIdDCF%
							AND SD4.D4_QTDEORI > 0
							AND SD4.%NotDel%
						EndSql					
						Do While (cAliasQr1)->(!Eof())
							SD4->(dbGoTo((cAliasQr1)->RECNOSD4))
							
							RecLock('SD4',.F.)
							SD4->D4_IDDCF   := ' '
							SD4->(MsUnLock())
							// Verifica requisições
							cAliasQr2 := GetNextAlias()
							BeginSql Alias cAliasQr2
								SELECT SD4.R_E_C_N_O_ RECNOSD4
								FROM %Table:SD4% SD4
								WHERE SD4.D4_FILIAL = %xFilial:SD4%
								AND SD4.D4_IDDCF = %Exp:cIdDCF%
								AND SD4.D4_QTDEORI = 0
								AND NOT EXISTS (SELECT 1"
												FROM %Table:SD4% SD4A
												WHERE SD4A.D4_FILIAL = %xFilial:SD4%
												AND SD4A.D4_IDDCF = SD4.D4_IDDCF
												AND SD4A.D4_QTDEORI > 0
												AND SD4A.%NotDel%)"
								AND SD4.%NotDel%
							EndSql
							Do While (cAliasQr2)->(!Eof())
								// Ajusta primeira SD4
								SD4->(dbGoTo((cAliasQr2)->RECNOSD4))
								// Atualiza quantidade empenho de acordo com a quantidade requisitada
								GravaEmp(SD4->D4_COD,;            // Produto
										SD4->D4_LOCAL,;           // Armazem
										SD4->D4_QUANT,;           // Quantidade
										Nil,;                     // Quantidade 2 UM
										SD4->D4_LOTECTL,;         // Lote
										SD4->D4_NUMLOTE,;         // Sub-Lote
										Nil,;                     // Endereço
										Nil,;                     // Número de série
										SD4->D4_OP,;              // Ordem de produção
										SD4->D4_TRT,;             // Trt Op
										Nil,;                     // Pedido
										Nil,;                     // Seq. Pedido
										'SD4',;                   // Origem
										Nil,;                     // Op Origem
										Nil,;                     // Data Entrega
										Nil,;                     // aTravas
										.T.,;                     // Estorno
										Nil,;                     // Projeto
										.T.,;                     // Empenha SB2
										.T.,;                     // Grava SD4
										Nil,;                     // Consulta Vencidos
										.T.,;                     // Empenha SB8/SBF
										Nil,;                     // Cria SDC
										Nil,;                     // Encerra Op
										Nil,;                     // IdDCF
										Nil,;                     // aSalvCols
										Nil,;                     // nSG1
										Nil,;                     // OpEncer
										Nil,;                     // TpOp 
										Nil,;                     // CAT83
										Nil,;                     // Data Emissão
										Nil,;                     // Grava Lote
										Nil)                      // aSDC
								// Dados do resumo
								WMSA508RM(WMSA50818,aResOk,SD4->D4_OP,SD4->D4_TRT,SD4->D4_COD,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_QUANT,WmsFmtMsg(STR0023,{{"[VAR01]",AllTrim(SD4->D4_IDDCF)}})) // Ordem de serviço [VAR01] excluída!
								// Elimina SD4
								RecLock('SD4',.F.)
								SD4->(dbDelete())
								SD4->(MsUnLock())
								
								(cAliasQr2)->(dbSkip())
							EndDo
							(cAliasQr2)->(dbCloseArea())
							(cAliasQr1)->(dbSkip())
						EndDo
						(cAliasQr1)->(dbCloseArea())
					EndIf
					(cAliasQry)->(dbSkip())
					If !lEstorno
						DisarmTransaction()
					EndIf
				End Transaction
			EndIf
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	// Resumo problemas processo
	If lExibe
		WMSA508AR(oOrdSerDel,aResErro,aResOk)
	EndIf
	// Restaura area
	RestArea(aAreaDCF)
Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} ResumoMsg
Resumo

@author SQUAD WMS Logistica
@since 21/07/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WMSA508RM(cTitulo,aResumo,cOp,cTrt,cProduto,cLoteCtl,cNumLote,nQuant,cResumo)
Local lRet      := .T.
Local cMensagem := ""

Default cTitulo  := ""
Default cOp      := ""
Default cProduto := ""
Default cLoteCtl := ""
Default cNumLote := ""
Default nQuant   := 0
Default cResumo  := ""
	If !Empty(cTitulo)
		cMensagem += cTitulo +" - "
	EndIf
	If !Empty(cOp)
		cMensagem += WmsFmtMsg(STR0028,{{"[VAR01]",cOp}})+" | " // Ordem de produção [VAR01]
	EndIf
	If !Empty(cTrt)
		cMensagem += WmsFmtMsg(STR0029,{{"[VAR01]",cTrt}})+" | " // Sequência [VAR01]
	EndIf
	If !Empty(cProduto)
		cMensagem += WmsFmtMsg(STR0030,{{"[VAR01]",cProduto}})+" | " // Produto [VAR01]
	EndIf
	If !Empty(cLoteCtl)
		cMensagem += WmsFmtMsg(STR0031,{{"[VAR01]",cLoteCtl}})+" | " // Lote [VAR01]
	EndIf
	If !Empty(cNumLote)
		cMensagem += WmsFmtMsg(STR0032,{{"[VAR01]",cNumLote}})+" | " // Sub-lote [VAR01]
	EndIf
	If QtdComp(nQuant) > 0
		cMensagem += WmsFmtMsg(STR0033,{{"[VAR01]",NtoC(nQuant,10)}})+" | " // Quantidade [VAR01]
	EndIf
	cMensagem += AllTrim(cResumo)
	aAdd(aResumo,cMensagem)
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} AvisoRes
Monta aviso resumo

@author SQUAD WMS Logistica
@since 21/07/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function WMSA508AR(oOrdServ,aResErro,aResOk)
Local lRet := .T.
Local nI   := 0

Default aResErro := {}
Default aResOk   := {}
	
	oOrdServ:aWmsAviso := {}

	If !Empty(aResErro)
		aAdd(oOrdServ:aWmsAviso,Replicate("- ",70))
		aAdd(oOrdServ:aWmsAviso,STR0034) // RESUMO DA(S) DIVERGÊNCIA(S)
		aAdd(oOrdServ:aWmsAviso,Replicate("- ",70))
		For nI := 1 To Len(aResErro)
			aAdd(oOrdServ:aWmsAviso,aResErro[nI])
		Next nI
		aAdd(oOrdServ:aWmsAviso,"")
	EndIf
	// Resumo confirmações processo
	If !Empty(aResOk)
		aAdd(oOrdServ:aWmsAviso,Replicate("- ",70))
		aAdd(oOrdServ:aWmsAviso,STR0035) // RESUMO OP(S) INTEGRADA(S) WMS
		aAdd(oOrdServ:aWmsAviso,Replicate("- ",70))
		For nI := 1 To Len(aResOk)
			aAdd(oOrdServ:aWmsAviso,aResOk[nI])
		Next nI
		aAdd(oOrdServ:aWmsAviso,"")
	EndIf
	// Aviso
	If !IsBlind()
		oOrdServ:ShowWarnig()
	EndIf
Return lRet
