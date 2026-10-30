#INCLUDE 'LOCR039.CH'
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} LOCR039
Relatório de Previsão de Faturamento
@type function
@author Circenis
@since 7/8/2024
@version 1
/*/
FUNCTION LOCR039()
//Local nX
Private oReport
Private CTITULO := STR0001 //"Previsão de Faturamento"
Private OBREAK
Private OBREAK2
Private OBREAK3
Private OBREAK4
Private LOBRNFREM := SUPERGETMV("MV_LOCX067",.F.,.T.) // --> OBRIGA OU NAO UMA NOTA FISCAL DE REMESSA PARA GERACAO DA NOTA DE FATURAMENTO AUTOMATICO. PADRÃO: .T.

	IF TREPINUSE()
		IF PERGPARAM("LOCR039")
			oReport := REPORTDEF()
			oReport:DisableOrientation( ) 
			//oReport:SETDEVICE(4)    // MODO DEFAULT DE IMPRESS???O  4 = PLANILHA
			oReport:PRINTDIALOG()
		ENDIF
	ENDIF

RETURN

/*/{Protheus.doc} REPORTDEF
Definição do layout do relatório
@type function
@author Miguel Gontijo
@since 09/02/2017
@version 1
@return oReport, objeto, Objeto TReport configurado
/*/
STATIC FUNCTION REPORTDEF()

Local oSection1
Local oSection2
Local oSection3
Local oSection4

Private CFILBRK := CFILANT

	//??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
	//???CRIACAO DO COMPONENTE DE IMPRESSAO                                      ???
	//???                                                                        ???
	//???TREPORT():NEW                                                           ???
	//???EXPC1 : NOME DO RELATORIO                                               ???
	//???EXPC2 : TITULO                                                           ???
	//???EXPC3 : PERGUNTE                                                        ???
	//???EXPB4 : BLOCO DE CODIGO QUE SERA EXECUTADO NA CONFIRMACAO DA IMPRESSAO  ???
	//???EXPC5 : DESCRICAO                                                       ???
	//??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
	oReport := TREPORT():NEW("LOCR039",STR0002,"LOCR039",{|oReport| PRINTREPORT(oReport)},STR0003) //"PREVISAO DE FATURAMENTO" //"PREVISÃO DE FATURAMENTO"
	//oReport:NFONTBODY    := 10
	//oReport:CFONTBODY    := "CALIBRIrP
	//oReport:LUNDERLINE := .F.
	oReport:SetLandscape( )
	oReport:TOTALINLINE(.F.)
	//SETBORDER(UBORDER,NWEIGHT,NCOLOR,LHEADER)
	oReport:LPARAMPAGE := .F.
	oReport:LPRTPARAMPAGE := .F.
	oReport:UPARAM := {|| PERGPARAM("LOCR039") }
	oReport:DisableOrientation()

	// Cabeçalho
	oSection1 := TRSECTION():NEW(oReport,STR0004,{"TRB1"}, , , , , .F.) //"PROJETO \ OBRA"
	TRCELL():NEW(oSection1,"FP0_PROJET","TRB1",STR0005, , ) //"CONTRATO"
	TRCELL():NEW(oSection1,"FP0_CLI","TRB1",, , )
	TRCELL():NEW(oSection1,"FP0_LOJA","TRB1",, , )
	TRCELL():NEW(oSection1,"FP0_CLINOM","TRB1",, , )
	TRCELL():NEW(oSection1,"FP1_OBRA","TRB1",STR0006, , ) //"OBRA"
	TRCELL():NEW(oSection1,"FP1_CLIORI","TRB1",, , )
	TRCELL():NEW(oSection1,"FP1_NOMORI","TRB1",, , 30 )
	TRCELL():NEW(oSection1,"FP1_TPMES","TRB1",, , )
	TRCELL():NEW(oSection1,"SALDO",,STR0007, "@E 999,999,999,999.99" , , ) //"Valor Total"
	oSection1:SetHeaderPage(.T.) //Unico cabecalho por pagina
	oSection1:SetPageBreak(.T.)


	//OBREAK := TRBREAK():NEW(oSection1, {|| TRB1->FP0_PROJET+TRB1->FP1_OBRA},"Total Obra",.T.,,.F.) //"SUB TOTAIS"

	// Itens da FPA
	oSection2 := TRSECTION():NEW(oSection1,STR0008,{"FPA"},,,,,.F.,,.T.,,,,,1) //"Recorrente"
	//oSection2:lLineBreak := .T.
	TRCELL():NEW(oSection2,"FPA_OBRA","TRB2",STR0006, , , /*LPIXEL*/, {|| TRB1->FP1_OBRA} ) //"OBRA"
	TRCELL():NEW(oSection2,"FPA_PRODUT","TRB2",STR0009, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Produto"
	TRCELL():NEW(oSection2,"B1_DESC","TRB2",STR0010, , , /*LPIXEL*/, ) //"Descricao"
	if MV_PAR08 <> 1 // Por Produto DSERLOCA-10481 - Alexandre Circenis - Inclusão de Novas colunas
		TRCELL():NEW(oSection2,"FPA_SEQGRU","TRB2",STR0048, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Seq."
		TRCELL():NEW(oSection2,"FPA_GRUA","TRB2",STR0037, , , /*LPIXEL*/, /*{|| BLOCK } */ )  //"Codigo Bem"
		oSection2:Cell("FPA_SEQGRU"):SetType("C")
	endif
	TRCELl():NEW(oSection2,"TPBASE","TRB2",STR0038+CRLF+STR0039, ,05 , /*LPIXEL*/, {||AllTrim( X3Combo("FPA_TPBASE", TRB2->FPA_TPBASE)) } ) //"Base" //"Calculo"
	TRCELL():NEW(oSection2,"FPA_QUANT","TRB2",STR0011,"@E 999,999.9999" , , /*LPIXEL*/, /*{|| BLOCK } */ ) // PROBLEMA 1: Alterado de "Quantidade" para "Qtde."
	TRCELL():NEW(oSection2,"FPA_VRHOR","TRB2",STR0035, "@E 999,999,999,999.99", , /*LPIXEL*/, /*{|| BLOCK } */ ) //'Vlr.Base'
	TRCELL():NEW(oSection2,"VLRPED","TRB2",STR0012, "@E 999,999,999,999.99" , , /*LPIXEL*/, {|| ValFat(TRB2->ALIAS = 'FQZ') } ) //'Vlr.Pedido'
	TRCELL():NEW(oSection2,"FPA_INICIO","TRB2",STR0013, , 12, /*LPIXEL*/, {|| TRB2->FPA_INICIO + TRB2->SOMA_DATA} ) // PROBLEMA 4: Alterado de "Inicio/Ult Fat" para "Inicio" e tamanho definido
	TRCELL():NEW(oSection2,"FPA_GERAEM","TRB2",STR0014, , 12, /*LPIXEL*/, ) // PROBLEMA 6: Tamanho definido para evitar truncamento
	TRCELL():NEW(oSection2,"FPA_DTFIM","TRB2",STR0015, , 12, /*LPIXEL*/, ) // PROBLEMA 6: Tamanho definido para evitar truncamento
	TRCELL():NEW(oSection2,"FPA_DTSCRT","TRB2",STR0036, , 12, /*LPIXEL*/, ) // PROBLEMA 5: Alterado de "Dt. Sol. Retirada" para "Dt.Sol.Retir" e tamanho definido
	//Inicio DSERLOCA-10481 - Alexandre Circenis - 09/02/2026 - Inclusão de novas Colunas
//	TRCELL():NEW(oSection2,"DIASCOR","TRB2",STR0040+CRLF+STR0041,"@Z 9999" ,10, /*LPIXEL*/, {|| DiasCor(TRB2->ALIAS = 'FQZ') } ) // PROBLEMA 3: Assumindo que STR0021 é "Valor Pro Rata", alterado para "Vlr.Perdido" //"Dias" //"Corridos"
//	TRCELL():NEW(oSection2,"VLRDIA","TRB2",STR0042,"@EZ 999,999,999,999.99" , , /*LPIXEL*/, {|| ValDia(TRB2->FPA_TPBASE, TRB2->FPA_VRHOR, TRB2->FPA_LOCDIA, TRB2->ALIAS = 'FQZ') } ) // PROBLEMA 3: Assumindo que STR0021 é "Valor Pro Rata", alterado para "Vlr.Perdido" //"Valor Diária"
//	TRCELL():NEW(oSection2,"TOTAL","TRB2",STR0007,"@EZ 999,999,999,999.99" , , /*LPIXEL*/, {|| ValDia(TRB1->FP1_TPMES, TRB2->FPA_VRHOR , TRB2->FPA_LOCDIA, TRB2->ALIAS = 'FQZ') * DiasCor() } ) // PROBLEMA 3: Assumindo que STR0021 é "Valor Pro Rata", alterado para "Vlr.Perdido" //"Valor Total"
	//FiM DSERLOCA-10481 - Alexandre Circenis - 09/02/2026 - Inclusão de novas Colunas

	oSection2:SetLineCondition({|| ValFat() >= 0})

	// Pro-Rata de Retorno
	oSection3 := TRSECTION():NEW(oSection1,STR0016,{"FQZ"},,,,,.F.) //"PRO RATA"
	TRCELL():NEW(oSection3,"FQZ_OBRA","TRB3",STR0006, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"OBRA"
	TRCELL():NEW(oSection3,"FQZ_COD","TRB3",STR0009, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Produto"
	TRCELL():NEW(oSection3,"B1_DESC","TRB3",STR0010, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Descricao"
	TRCELL():NEW(oSection3,"FQZ_QTD","TRB3",STR0011, , , /*LPIXEL*/, /*{|| BLOCK } */ ) // PROBLEMA 1: Alterado para "Qtde."
	TRCELL():NEW(oSection3,"FQZ_VLRTOT","TRB3",STR0035, , , /*LPIXEL*/, /*{|| BLOCK } */ ) // PROBLEMA 2: Alterado de "Valor Base" para STR0035
	TRCELL():NEW(oSection3,"FQZ_INICIO","TRB3",STR0018, , , /*LPIXEL*/, {|| TRB3->FQZ_RETIRA - TRB3->FQZ_PERPRO +1} ) //"Data Inicio"
	TRCELL():NEW(oSection3,"FQZ_RETIRA","TRB3",STR0019, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Devolução"
	TRCELL():NEW(oSection3,"FQZ_PERPRO","TRB3",STR0020, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Pro rata"
	TRCELL():NEW(oSection3,"FQZ_VLRPRO","TRB3",STR0043, , , /*LPIXEL*/, /*{|| BLOCK } */ ) // PROBLEMA 3: Assumindo que STR0021 é "Valor Pro Rata", alterado para "Vlr.Perdido"
	TRCELL():NEW(oSection3,"FQZ_VLRPRO","TRB3",STR0053, , , /*LPIXEL*/, /*{|| BLOCK } */ ) // PROBLEMA 3: Assumindo que STR0021 é "Valor Pro Rata", alterado para "Vlr.Perdido" //"Dias Corridos"
	TRCELL():NEW(oSection3,"FQZ_VLRPRO","TRB3",STR0042, , , /*LPIXEL*/, /*{|| BLOCK } */ ) // PROBLEMA 3: Assumindo que STR0021 é "Valor Pro Rata", alterado para "Vlr.Perdido" //"Valor Diária"
	TRCELL():NEW(oSection3,"FQZ_VLRPRO","TRB3",STR0007, , , /*LPIXEL*/, /*{|| BLOCK } */ ) // PROBLEMA 3: Assumindo que STR0021 é "Valor Pro Rata", alterado para "Vlr.Perdido" //"Valor Total"


	// Custo Extra
	if MV_PAR05 = 1
		oSection4 := TRSECTION():NEW(oSection1,STR0022,{"FPG"},,,,,.F.) //"CUSTO EXTRA"
		TRCELL():NEW(oSection4,"FPG_OBRA","TRB4",STR0006, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"OBRA"
		TRCELL():NEW(oSection4,"FPG_PRODUT","TRB4",STR0009, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Produto"
		TRCELL():NEW(oSection4,"B1_DESC","TRB4",STR0010, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Descricao"
		TRCELL():NEW(oSection4,"FPG_QUANT","TRB4",STR0011, , , /*LPIXEL*/, /*{|| BLOCK } */ ) // PROBLEMA 1: Alterado para "Qtde."
		TRCELL():NEW(oSection4,"FPG_TAXAV","TRB4",STR0023, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Taxa"
		TRCELL():NEW(oSection4,"FPG_VALTOT","TRB4",STR0024, , , /*LPIXEL*/, /*{|| BLOCK } */ ) //"Total"
	endif
	//oSection1:Cell("SALDO"):SetSize(0)
	//oSection1:Cell("SALDO"):Disable()
RETURN oReport

/*/{Protheus.doc} PRINTREPORT
Imprime o relatório de previsão de faturamento
@type function
@author Miguel Gontijo
@since 09/02/2017
@version 1
@param oReport, objeto, Objeto TReport a ser impresso
/*/
STATIC FUNCTION PRINTREPORT(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oSection1:Section(1)
Local oSection3 := oSection1:SECTION(2)
Local oSection4 := oSection1:SECTION(3)
Local cAlias2 := "TRB2"
Local cAlias3 := "TRB3"
Local cAlias4 := "TRB4"
Local cQuery := ""
Local aBindParam := {}
Local cWhere := ""
Local oTotReco
Local oTotPro
Local oTotCEXT
Local oTotObra
Local cFilUserFPA := oSection1:GetSQLExp("FPA")
Local cTemp := ""
Local cProduto :=  ""
Local dIni := Ctod("")
Local dFim := Ctod("")
Local dGera := Ctod("")
LOcal dRet  := Ctod("")
LOcal cDesc := ""

	cWhere := "%FPA_GERAEM >= '" + DTOS(MV_PAR06) + "' AND FPA_GERAEM <= '" + DTOS(MV_PAR07) + "'"+;
	          " AND FPA_DTFIM >= '" + DTOS(MV_PAR13) + "' AND FPA_DTFIM <= '" + DTOS(MV_PAR14) + "'%"

	// Totalizadores de secao - NIL = acumula toda a secao, impresso ao fim de cada obra.
	// oTotReco e referenciado por oTotObra:GetValue() -> manter vinculado ao nivel de secao.
	oTotReco := TRFunction():New(oSection2:Cell("VLRPED")   , "TOTRECO", "SUM"  , NIL , , , , .T. , .F. , .F.)
	TRFunction():New(oSection2:Cell("B1_DESC")   , , "COUNT", NIL , "Itens" , "@E 999,999.99"          , , , .F.)
	TRFunction():New(oSection2:Cell("FPA_QUANT") , , "SUM"  , NIL , "Itens" , "@E 999,999,999.9999"    , , , .F.)
	TRFunction():New(oSection2:Cell("FPA_VRHOR") , , "SUM"  , NIL , "Itens" , "@E 999,999,999,999.99"  , , , .F.)
	// Fim DSERLOCA-XXXXX

/*	oTotReco := TRFUNCTION():NEW(oSection2:CELL("VLRPED"),STR0025,"SUM",oBreak2,,,, .T., .F.,.F. ) //"TOTAL  "*/
//	TRFunction():New(oSection2:Cell("B1_DESC"),/*"oTotal"*/ ,"COUNT",oBreak2,"Itens","@E 999,999.99",/*[ uFormula ]*/,,.F.)
//	TRFunction():New(oSection2:Cell("FPA_QUANT"),/*"oTotal"*/ ,"SUM",oBreak2,"Itens","@E 999,999,999.9999",/*[ uFormula ]*/,,.F.)
//	TRFunction():New(oSection2:Cell("FPA_VRHOR"),/*"oTotal"*/ ,"SUM",oBreak2,"Itens","@E 999,999,999.99",/*[ uFormula ]*/,,.F.)
	

	//TRFunction():New(oSection2:Cell("TOTAL"),/*"oTotal"*/ ,"SUM",oBreak2,"Itens","@E 999,999,999.99",/*[ uFormula ]*/,,.F.)
	oTotPro := TRFUNCTION():NEW(oSection3:CELL("FQZ_VLRPRO"),"TOTPRO","SUM",oBreak3,,,, .T., .F.,.F. ) //"TOTAL "
	TRFunction():New(oSection3:Cell("B1_DESC"),/*"oTotal"*/ ,"COUNT",oBreak3,"Itens","@E 999,999.99",/*[ uFormula ]*/,,.F.)
	TRFunction():New(oSection3:Cell("FQZ_QTD"),/*"oTotal"*/ ,"SUM",oBreak3,"Itens","@E 999,999,999.9999",/*[ uFormula ]*/,,.F.)
	TRFunction():New(oSection3:Cell("FQZ_VLRTOT"),/*"oTotal"*/ ,"SUM",oBreak3,"Itens","@E 999,999,999.99",/*[ uFormula ]*/,,.F.)

	if MV_PAR05 = 1
		oTotCEXT := TRFUNCTION():NEW(oSection4:CELL("FPG_VALTOT"),"TOTCEXT","SUM",oBreak4,,,, .T., .F.,.F. ) //"TOTAL "
		oTotObra := TRFunction():New(oSection1:Cell("SALDO"),"SALDO","ONPRINT",OBREAK,/*Titulo*/,/*cPicture*/,;
			{ || oTotReco:GetValue()+oTotPro:GetValue()+oTotCEXT:GetValue() },.T.,.F.,.F.,oSection1)
	else
		oTotObra := TRFunction():New(oSection1:Cell("SALDO"),"SALDO","ONPRINT",OBREAK,/*Titulo*/,/*cPicture*/,;
			{ || oTotReco:GetValue()+oTotPro:GetValue() },.T.,.F.,.F.,oSection1)
	endif

	cQuery += " SELECT FP0_PROJET, FP0_CLI, FP0_LOJA, FP0_CLINOM, FP1_OBRA, FP1_TPMES, FP1_NOMORI, FP0_CLI, FP0_LOJA, FP1_CLIORI, FP1_LOJORI, FP1_TPMES"
	cQuery += " FROM "+RetSqlName("FP0")+ " FP0"
	cQuery += " inner JOIN "+RetSqlName("FP1")+ " FP1"
	cQuery += " ON FP1_FILIAL = '"+xFilial("FP1")+"'"
	cQuery += " AND FP1_PROJET = FP0_PROJET"
	cQuery += " AND FP1_OBRA >= ?"
	Aadd(aBindParam, MV_PAR03 )
	cQuery += " AND FP1_OBRA <= ?"
	Aadd(aBindParam, MV_PAR04 )
	cQuery += " AND FP1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE FP0_FILIAL = '"+xFilial("FP0")+"'"
	cQuery += " AND FP0_PROJET >= ?"
	Aadd(aBindParam, MV_PAR01)
	cQuery += " AND FP0_PROJET <= ?"
	Aadd(aBindParam, MV_PAR02)
	cQuery += " AND FP0_CLI >= ?"
	Aadd(aBindParam, MV_PAR09)
	cQuery += " AND FP0_LOJA >= ?"
	Aadd(aBindParam, MV_PAR10)
	cQuery += " AND FP0_CLI <= ?"
	Aadd(aBindParam, MV_PAR11)
	cQuery += " AND FP0_LOJA <= ?"
	Aadd(aBindParam, MV_PAR12)
	cQuery += " AND (FP0_STATUS = '1' OR FP0_STATUS = '5')"
	cQuery += " AND FP0.D_E_L_E_T_ = ' '"
	cQuery += " AND EXISTS ( Select FPA_AS"
	cQuery += " FROM "+RetSqlName("FPA")+" FPA"
	cQuery += " WHERE FPA_FILIAL = '"+xFilial("FPA")+"'"
	cQuery += " AND FPA_PROJET = FP0_PROJET"

	IF LOBRNFREM
		cQuery += " AND FPA_NFREM <> ' '"
	EndIf

	cQuery += " AND ((FPA_ULTFAT < FPA_DTSCRT OR FPA_DTSCRT = ' ') OR FPA_ULTFAT = ' ') "
	cQuery += " AND FPA_TIPOSE <> 'S' "
	cQuery += " AND FPA_PRCUNI > 0 "
	cQuery += " AND FPA_OBRA = FP1_OBRA "

	If !Empty(cFilUserFPA)
		cTemp := '" AND ' + cFilUserFPA + '"'
		cTemp := " cQuery += " + cTemp
		&(cTemp)
	EndIf

	cQuery += " AND FPA.D_E_L_E_T_ = ' ' )"
	cQuery += " ORDER BY FP0_PROJET, FP1_OBRA"

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"TRB1",,,aBindParam)

	oSection1:BeginQuery()

	While !oReport:Cancel() .And. !TRB1->(Eof())

		oSection1:Init()
		oSection1:PrintLine()

		LOCR039S2(cAlias2)

		if !(TRB2->(Eof()))
			oSection2:Init()
			if MV_PAR08 = 1
				cProduto := TRB2->FPA_PRODUT
				cDesc    := TRB2->B1_DESC
				dIni    := TRB2->FPA_INICIO + TRB2->SOMA_DATA
				dFim    := TRB2->FPA_DTFIM
				dGera   := TRB2->FPA_GERAEM
				dRet    := TRB2->FPA_DTSCRT
				oSection2:Cell("FPA_QUANT"):SetValue(0)
				oSection2:Cell("FPA_VRHOR"):SetValue(0)
				oSection2:Cell("VLRPED"):SetValue(0)
			endif
		endif			

		While !(TRB2->(Eof()))


			if MV_PAR08 = 1 // Por Produto
				
				oSection2:Cell("FPA_PRODUT"):SetValue( cProduto )
				oSection2:Cell("B1_DESC"):SetValue( cDesc)
				oSection2:Cell("FPA_INICIO"):SetValue(dIni)
				oSection2:Cell("FPA_DTFIM"):SetValue(dFim)
				oSection2:Cell("FPA_GERAEM"):SetValue(dGera)
				oSection2:Cell("FPA_DTSCRT"):SetValue(dRet)

				while !(TRB2->(Eof())) .and. cProduto = TRB2->FPA_PRODUT .and. ;
					dIni = TRB2->FPA_INICIO + TRB2->SOMA_DATA .and.;
					dFim = TRB2->FPA_DTFIM .and. dGera = TRB2->FPA_GERAEM .and.;
					dRet = TRB2->FPA_DTSCRT
					oSection2:Cell("FPA_QUANT"):SetValue(oSection2:Cell("FPA_QUANT"):GetValue() + TRB2->FPA_QUANT)
					oSection2:Cell("FPA_VRHOR"):SetValue(oSection2:Cell("FPA_VRHOR"):GetValue() + TRB2->FPA_VRHOR)
					oSection2:Cell("VLRPED"):SetValue(oSection2:Cell("VLRPED"):GetValue() + ValFat(TRB2->ALIAS = 'FQZ'))
					TRB2->(dbSkip())
				enddo
				oSection2:PrintLine()
				cProduto := TRB2->FPA_PRODUT
				cDesc    := TRB2->B1_DESC
				dIni    := TRB2->FPA_INICIO + TRB2->SOMA_DATA
				dFim    := TRB2->FPA_DTFIM
				dGera   := TRB2->FPA_GERAEM
				dRet    := TRB2->FPA_DTSCRT
				oSection2:Cell("FPA_QUANT"):SetValue(0)
				oSection2:Cell("FPA_VRHOR"):SetValue(0)
				oSection2:Cell("VLRPED"):SetValue(0) 
			else
				oSection2:PrintLine()
				TRB2->(dbSkip())
			endif

		End

		oSection2:Finish()

		BEGIN REPORT QUERY oSection3
			BeginSql alias cAlias3
				SELECT FQZ_PROJET, FQZ_OBRA, FQZ_COD, B1_DESC, Sum(FQZ_QTD) FQZ_QTD
				, SUM(FQZ_VLRPRO) FQZ_VLRPRO, FQZ_RETIRA, FQZ_PERPRO, Sum(FQZ_VLRTOT) FQZ_VLRTOT
				FROM %table:FQZ% FQZ
				inner JOIN %table:SB1% SB1
				ON B1_FILIAL = %xfilial:SB1%
				AND B1_COD = FQZ_COD
				AND SB1.%notDel%
				INNER JOIN %table:FPA% FPA
				ON FPA_FILIAL = %xfilial:FPA%
				AND FPA_AS = FQZ_AS
				AND %Exp:cWhere%
				AND FPA.%notDel%
				WHERE FQZ_FILIAL = %xfilial:FQZ%
				AND FQZ_PROJET = %report_param: TRB1-> FP0_PROJET %
				AND FQZ_PV = ' '
				AND FQZ_PERPRO > 0
				AND FQZ_MSBLQL <> '1'
				AND FQZ_RETIRA <= FPA_DTFIM
				AND FQZ_OBRA = %report_param: TRB1-> FP1_OBRA %
				AND FQZ.%notDel%
				GROUP BY FQZ_PROJET, FQZ_OBRA, FQZ_COD, B1_DESC,FQZ_RETIRA, FQZ_PERPRO
				ORDER BY FQZ_PROJET, FQZ_OBRA, FQZ_COD, B1_DESC,FQZ_RETIRA, FQZ_PERPRO
			EndSql
		END REPORT QUERY oSection3

		oSection3:Print()
		oSection3:Finish()

		if MV_PAR05 = 1
			BEGIN REPORT QUERY oSection4
				BeginSql alias cAlias4
					SELECT FPG_PROJET, FPG_OBRA, FPG_PRODUT, B1_DESC, FPG_NRAS, FPG_VLUNIT,FPG_QUANT, FPG_TAXAV
					, FPG_VALTOT
					FROM %table:FPG% FPG
					inner JOIN %table:SB1% SB1
					ON B1_FILIAL = %xfilial:SB1%
					AND B1_COD = FPG_PRODUT
					AND SB1.%notDel%
					WHERE FPG_FILIAL = %xfilial:FPG%
					AND FPG_PROJET = %report_param: TRB1-> FP0_PROJET %
					AND FPG_COBRA = 'S'
					AND FPG_STATUS = '1'
					AND FPG_OBRA = %report_param: TRB1-> FP1_OBRA %
					AND FPG.%notDel%
					ORDER BY FPG_PROJET, FPG_OBRA, FPG_PRODUT
				EndSql
			END REPORT QUERY oSection4
			oSection4:Print()
			oSection4:Finish()

		endif
	
		oSection1:Finish()
	
		oSection2:GetFunction("TOTRECO"):ResetReport()
		oSection2:GetFunction("TOTRECO"):ResetSection()
		oSection2:GetFunction("TOTRECO"):Reset()

		oSection3:GetFunction("TOTPRO"):ResetReport()
		oSection3:GetFunction("TOTPRO"):ResetSection()
		oSection3:GetFunction("TOTPRO"):Reset()

	if MV_PAR05 = 1

		oSection4:GetFunction("TOTCEXT"):ResetReport()
		oSection4:GetFunction("TOTCEXT"):ResetSection()
		oSection4:GetFunction("TOTCEXT"):Reset()

	endif

		oSection1:GetFunction("SALDO"):ResetReport()
		oSection1:GetFunction("SALDO"):ResetSection()
		oSection1:GetFunction("SALDO"):Reset()
		dbSelectArea("TRB1")
		dbSkip()
		oReport:IncMeter()

	
	End

Return

/*/{Protheus.doc} PERGPARAM
Pergunta do relatório
@type function
@author Miguel Gontijo
@since 09/02/2017
@version 1
@param cPerg, string, Nome do grupo de perguntas
@return lRet, boolean, Retorna .T. se os parâmetros foram confirmados
/*/
STATIC FUNCTION PERGPARAM(cPerg)

Local aPergs := {}
Local ARET := {}
Local lRet := .F.
Local NX
Local cContrDe   := If(FUNNAME()="LOCA001", FP0->FP0_PROJET, Criavar("FPA_PROJET",.T.))
Local cContrAte  := If(FUNNAME()="LOCA001", FP0->FP0_PROJET, Criavar("FPA_PROJET",.T.))
Local cObraDe    := Criavar("FPA_OBRA",.T.)
Local cObraAte   := If(FUNNAME()="LOCA001", "zzz",Criavar("FPA_OBRA",.T.))
Local dDataDe    := Criavar("FPA_GERAEM",.T.)
Local dDataAt    := Criavar("FPA_GERAEM",.T.)
Local cCliDe     := Criavar("FP0_CLI",.T.)
Local cCliAte    := Criavar("FP0_CLI",.T.)
Local cLojaDe    := Criavar("FP0_LOJA",.T.)
Local cLojaAte   := Criavar("FP0_LOJA",.T.)
Local dProxFatDe := Criavar("FPA_DTFIM",.T.)
Local dProxFatAt := Criavar("FPA_DTFIM",.T.)

	AADD( aPergs ,{1,STR0027,cContrDe , ,'.T.',"FP0",'.T.', 50 ,.F.}) //"Contrato de "
	AADD( aPergs ,{1,STR0028,cContrAte, ,'.T.',"FP0",'.T.', 50 ,.F.}) //"Contrato ate"
	AADD( aPergs ,{1,STR0029,cObraDe , ,'.T.',"",'.T.', 50 ,.F.}) //"Obra de "
	AADD( aPergs ,{1,STR0030,cObraAte, ,'.T.',"",'.T.', 50 ,.F.}) //"Obra ate"
	aAdd( aPergs ,{3,STR0033,1,{ STR0032 , STR0031 },50,"",.F.}) // Imprimir Custo Extra
	aAdd( aPergs ,{1, STR0044, dDataDe, "", ".T.", "", ".T.", 80, .F.}) //"Gera em De"
	aAdd( aPergs ,{1, STR0045, dDataAt, "", ".T.", "", ".T.", 80, .F.}) //"Gera em Até"
	//DSERLOCA-10481 - Alexandre Circenis - 09/02/2026 - Novo parametro
	aAdd( aPergs ,{3, STR0047,1,{STR0009,STR0046},50,"",.F.}) //"Produto" # A.S.
	// ISSUE: DSERLOCA-XXXX - Dev - 25/03/2026 - Filtros de Cliente e Loja
	AADD(aPergs ,{1,STR0049,cCliDe  ,,'.T.',"SA1",'.T.',6,.F.})   //"Cliente de"
	AADD(aPergs ,{1,STR0051,cLojaDe ,,'.T.',"",'.T.',2,.F.})  //"Loja de"
	AADD(aPergs ,{1,STR0050,cCliAte ,,'.T.',"SA1",'.T.',6,.F.})   //"Cliente ate"
	AADD(aPergs ,{1,STR0052,cLojaAte,,'.T.',"",'.T.',2,.F.}) //"Loja ate"
	aAdd(aPergs ,{1, STR0054, dProxFatDe, "", ".T.", "", ".T.", 80, .F.})   //"Prox Faturamento de"
	aAdd(aPergs ,{1, STR0055, dProxFatAt, "", ".T.", "", ".T.", 80, .F.})   //"Prox Faturamento até"

	IF PARAMBOX(aPergs,STR0034,ARET, /*< BOK >*/, /*< ABUTTONS >*/, .T. , /*7 < NPOSX >*/, /*8 < NPOSY >*/, /*9 < ODLGWIZARD >*/, /*10 < CLOAD > */,!( FUNNAME()="LOCA001") , .T. ) //"Parametros"
		FOR NX := 1 TO LEN(ARET)
			&("MV_PAR"+STRZERO(NX,2)) := ARET[NX]
		NEXT
		lRet := .T.
	endif

RETURN (lRet)

/*/{Protheus.doc} ValFat
Calcula o valor do faturamento baseado no tipo de mês e período
@type function
@author Sistema
@since 09/02/2017
@version 1
@return nValLoc, numérico, Valor calculado do faturamento
/*/
Static function ValFat(lFQZ)

Local nValLoc := 0
Local dDtIni := TRB2->FPA_INICIO + TRB2->SOMA_DATA
Local dDtFim := TRB2->FPA_DTFIM
Local nDiasTrb
Local nDiasX
Local nDias := 30
Local dUltFat
Local _LOCA021C := ExistBlock("LOCA021C")


	DEFAULT lFQZ := .F.

	if lFQZ
		nValLoc := TRB2->FPA_VRHOR

	else

		DO CASE
		CASE TRB2->FPA_TPBASE == "M"
			nDiasTrb := 30
		CASE TRB2->FPA_TPBASE == "Q"
			nDiasTrb := 15
		CASE TRB2->FPA_TPBASE == "S"
			nDiasTrb :=  7
		OTHERWISE
			DO CASE
			CASE FPA->( FIELDPOS("FPA_LOCDIA") ) > 0
				nDiasTrb :=TRB2->FPA_LOCDIA
			ENDCASE
		ENDCASE

		
		nValLoc := TRB2->FPA_VRHOR


		dUltFat	 := TRB2->FPA_DTFIM

		dDtIni := TRB2->FPA_INICIO + If (Empty(TRB2->FPA_ULTFAT), 0 , 1)

		//	FP1_TPMES --- "0" = FECHADO  E  "1" = ABERTO e '2' = Fixo
		IF TRB1->FP1_TPMES == "0"				// MES FECHADO
			nDiasTrb := 30 // quantidade de dias do mês fechado que foi usado
			nDiasX  := 30 // quantidade de dias do fator do periodo

			// ATENCAO: se alterar a forma de encontrar o dDtFim e dUltFat e dProcFat
			// precisa ser replicado para o mes fixo TPMES = 2

			dDtFim  := TRB2->FPA_DTFIM

			IF _LOCA021C //EXISTBLOCK("LOCA021C") // ponto de entrada para alteracao dos dias fixos = 30
				nDiasTrb   := EXECBLOCK("LOCA021C" , .T. , .T. )
				nDiasX     := nDiasTrb // Frank em 12/01/2026 - estava chamando 2 x o PE LOCA021C.
			ENDIF

			dUltFat  := dDtFim

			// Frank em 20/07/22 - somente quando for segundo faturamento em diante
			// considerar os dias corretos para o calculo

			IF !EMPTY(TRB2->FPA_ULTFAT)
				nDiasTrb := dDtFim - dDtIni + 1
				nValLoc := (nValLoc * nDiasTrb) / nDiasX
			EndIf
			IF EMPTY(TRB2->FPA_ULTFAT) //.AND. ((dDtFim - dDtIni) + 1) < nDiasX   //DAY(dDtIni) - 1 <> DAY(dDtFim)
				nDiasTrb := dDtFim - dDtIni + 1
				nValLoc := (nValLoc * nDiasTrb) / nDiasX
			ENDIF


			IF !EMPTY(TRB2->FPA_DTSCRT)
				IF TRB2->FPA_DTSCRT< dDtFim .or. file("\SYSTEM\LOCR039A.TXT")
					nValLoc := TRB2->FPA_VRHOR 
					nDiasTrb := TRB2->FPA_DTSCRT - dDtIni + 1
					dDtFim  := TRB2->FPA_DTSCRT
					IF nDiasTrb < nDiasX
						nValLoc := (nValLoc * nDiasTrb) / nDiasX
					ENDIF

					// Frank 21/09/23 - tratamento quanto for 1.fat

					IF EMPTY(TRB2->FPA_ULTFAT)
						nValLoc := TRB2->FPA_VRHOR
						nDiasTrb := TRB2->FPA_DTSCRT- dDtIni + 1
						nValLoc := (nValLoc * nDiasTrb) / nDiasX
					ENDIF

				ENDIF
			ENDIF
		ELSEIF TRB1->FP1_TPMES == "1"				//Dias Corridos
			IF EMPTY(TRB2->FPA_DTSCRT)
				// DSERLOCA-2875 - Frank em 09/04/2024
				//dDtFim := dDtIni + nDiasTrb - 1
				dDtFim := dDtIni +TRB2->FPA_LOCDIA - 1
			ELSE
				// DSERLOCA-2875 - Frank em 09/04/2024
				//IF dDtIni + nDiasTrb - 1 < TRB2->FPA_DTSCRT
				IF dDtIni +TRB2->FPA_LOCDIA - 1 < TRB2->FPA_DTSCRT
					//dDtFim := dDtIni + nDiasTrb - 1
					dDtFim := dDtIni +TRB2->FPA_LOCDIA - 1
				ELSE
					dDtFim := TRB2->FPA_DTSCRT
				ENDIF
			ENDIF
			dUltFat  := dDtFim
			
			// DSERLOCA-2875 - Frank em 09/04/2024
			//nValLoc  := nValLoc * (dDtFim - dDtIni + 1) / nDiasTrb
			nValLoc  := nValLoc * (dDtFim - dDtIni + 1) /TRB2->FPA_LOCDIA
		ELSE // mes fixo


			dDtFim := TRB2->FPA_DTFIM


			dUltFat  := dDtFim

			IF !EMPTY(TRB2->FPA_DTSCRT)
				IF TRB2->FPA_DTSCRT< dDtFim .or. file("\SYSTEM\LOCR039A.TXT")
					dDtFim  := TRB2->FPA_DTSCRT
				ENDIF
			ENDIF

			nDias :=  dDtFim - dDtIni + 1

			If month(dDtIni) == 2 .and. month(dDtFim) > 2
				If nDias == 28 .or. nDias == 29
					nDias := 30
				EndIf
			Else
				If month(dDtIni) == 2 .and. month(dDtFim) == 2
					If nDias == 28 .or. nDias == 29
						nDias := 30
					EndIf
				EndIf
			EndIf


			If EMPTY(TRB2->FPA_DTSCRT) .and. !empty(TRB2->FPA_ULTFAT)
				nDias := 30
			EndIF

			if (!EMPTY(TRB2->FPA_DTSCRT) .or. Empty(TRB2->FPA_ULTFAT)) .and. nDias > 30
				nDias := 30
			endif
	
			nValLoc := (TRB2->FPA_VRHOR) / 30 // Calculo do valor por dia
			nValLoc := ROUND(nValLoc * nDias,GETSX3CACHE("C6_VALOR","X3_DECIMAL"))   // (30 - 31 = -1 dia 30 - 29 = 1 dia)
	
		endif

	ENDIF

	IF  nValLoc <> ROUND(nValLoc/(TRB2->FPA_QUANT ),SC6->(GETSX3CACHE("C6_PRCVEN","X3_DECIMAL"))) * (TRB2->FPA_QUANT )
		nValLoc := ROUND(nValLoc/(TRB2->FPA_QUANT ),SC6->(GETSX3CACHE("C6_PRCVEN","X3_DECIMAL"))) * (TRB2->FPA_QUANT )
	ENDIF

Return ROUND(nValLoc,GETSX3CACHE("C6_VALOR","X3_DECIMAL"))

/*/{Protheus.doc} DiasCor
DSERLOCA-10481 Calcula os dias de Pro-Rata
@type function
@author Alexandre Circenis
@since 09/02/2017
@version 1
@return nDiasCor, numeric, Numero de Dias para Pro-Rata

Static function DiasCor(lFQZ)

Local cTipMes := TRB1->FP1_TPMES

Local dDtIni := Stod(TRB2->FPA_INICIO)+TRB2->SOMA_DATA
Local dDtFim := TRB2->FPA_DTSCRT
Local nDiasCor := dDtFim - dDtIni + 1
Local nDiasMes 

	if lFQZ
		
		nDiasCor := 0
	else
		if !Empty(dDtFim)

			If cTipMes = '0' // Mes Fechado
				if nDiasCor > 30
					nDiasCor := 30
				endif
			ElseIf cTipMes = '1' // Dias Corridos

				// por enquanto nada a ser feito
			Elseif cTipMes = '2' // Mes Fixo
				nDiasMes := Day(LastDay(dDtFim))
				nDiasCor := Min(nDiasMes, nDiasCor)
			endif
		else
			nDiasCor := 0
		endif
	endif
Return nDiasCor
/*/

/*/{Protheus.doc} ValDia
DSERLOCA-10481 Calcula o valor da Diaria conforme o tipo do mes
@type function
@version 25.10
@author Alexandre Circenis
@since 10/02/2026
@param cTpBase, character, tipo do periodo usado na FPA
@param nValorBase, numeric, valor base 
@return variant, Valor cobrado por dia

Static Function ValDia(cTpFat, nValorBase, nLocDias, lFQZ )
Local nValor := 0

DEFAULT lFQZ := .F.

if !lFQZ	

	if cTpFat = '1' // Dias Corridos
		nValor := nValorBase/nLocDias
	else
		nValor := nValorBase/30
	endif
endif

Return nValor
/*/

// =============================================================================
// MUDANCA 1: substituir a Static Function LOCR039S2 inteiramente
// (versao anterior tinha 4 variants; nova versao tem apenas 2)
// =============================================================================

/*/{Protheus.doc} LOCR039S2
Gera o dataset da Secao 2 (Itens Recorrentes FPA + retornos abertos FQZ) do relatorio LOCR039.
Sempre retorna um registro por A.S. da FPA, sem agrupamento por produto.
A agregacao sintetica e controlada pelo TReport via TRBreak (ver PRINTREPORT),
garantindo que ValFat() calcule o valor de faturamento sobre cada registro
individual antes de qualquer somatorio.
Executa dois variants conforme LOBRNFREM:
- Com NF de remessa obrigatoria (LOBRNFREM = .T.): filtra AND FPA_NFREM <> ' '
- Sem NF de remessa (LOBRNFREM = .F.): sem filtro de NF
São serão retornadas as A.S. que estaiverm aceitas FQ5_STATUS = '6'
@type function
@author Alexandre Circenis
@since 09/03/2026
@version 2
@param cAlias, character, Alias de destino onde o resultado da query sera aberto
@param cWhere, character, Condicao de filtro de data geraem no formato BeginSql (%Exp%)
@return Nil
/*/
Static Function LOCR039S2(cAlias)
Local cQuery :=  ""
Local aParam := {}
	cQuery += "SELECT FPA_PROJET, FPA_OBRA, FPA_PRODUT, B1_DESC, FPA_QUANT"
	cQuery += " , FPA_VRHOR, FPA_INICIO, FPA_TPBASE, FPA_LOCDIA, FPA_GRUA, FPA_SEQGRU"
	cQuery += " , FPA_GERAEM, FPA_DTFIM, FPA_DTSCRT, FPA_ULTFAT, SOMA_DATA, 'FPA' ALIAS, 0 FQZ_VLRPRO"
	cQuery += " From ("
	cQuery += "	SELECT FPA_PROJET, FPA_OBRA, FPA_PRODUT, B1_DESC, FPA_QUANT"
	cQuery += "	, FPA_DTSCRT, FPA_ULTFAT, FPA_GRUA, FPA_SEQGRU"
	cQuery += "	, FPA_VRHOR"
	cQuery += "	, CASE WHEN FPA_ULTFAT = ' ' THEN FPA_DTINI ELSE FPA_ULTFAT END FPA_INICIO"
	cQuery += "	, FPA_GERAEM"
	cQuery += "	, CASE WHEN FPA_DTSCRT <> ' ' AND FPA_DTSCRT < FPA_DTFIM THEN FPA_DTSCRT ELSE FPA_DTFIM END FPA_DTFIM"
	cQuery += "	, FPA_TPBASE, FPA_LOCDIA"
	cQuery += "	, CASE WHEN FPA_ULTFAT = ' ' THEN 0 ELSE 1 END SOMA_DATA"
	cQuery += "	FROM "+ RetSqlName("FPA")+" FPA"
	cQuery += " INNER JOIN "+RETSQLNAME("FQ5")+" FQ5 "
	cQuery += "   ON FQ5_FILIAL='"+XFILIAL("FQ5")+"'"
	cQuery += "   AND FQ5.D_E_L_E_T_ = ' '"
	cQuery += "   AND FQ5_FILORI = FPA_FILIAL"
	cQuery += "   AND FQ5_VIAGEM = FPA_VIAGEM"
	cQuery += "   AND FQ5_AS = FPA_AS" 
	cQuery += "   AND FQ5_STATUS = '6' "
	cQuery += "	INNER JOIN "+ RetSqlName("SB1")+" SB1"
	cQuery += "	ON B1_COD = FPA_PRODUT"
	cQuery += "	AND B1_FILIAL = '"+ xFilial("SB1")+"'"
	cQuery += "	AND SB1.D_E_L_E_T_ = ' '"
	cQuery += "	WHERE FPA_FILIAL = '"+ xFilial("FPA")+"'"
	cQuery += "	AND FPA_PROJET = ? "
	Aadd(aParam , TRB1->FP0_PROJET) 
	cQuery += "	AND ((FPA_ULTFAT < FPA_DTSCRT OR FPA_DTSCRT = ' ') OR FPA_ULTFAT = ' ')"
	cQuery += "	AND FPA_PRCUNI > 0"
	if LOBRNFREM // Só com nota de Remessa
		cQuery += "	AND FPA_NFREM <> ' '"
	endif
	cQuery += "	AND FPA_TIPOSE <> 'S'"
	// ISSUE: DSERLOCA-11475 - Alexandre Circenis - 26/03/2026 - Excluir itens de Cobranca Unica ja faturados da projecao
	cQuery += " AND NOT (FPA_TIPOSE = 'Z' AND FPA_ULTFAT <> ' ')"
	cQuery += "	AND FPA_OBRA = ?"
	Aadd(aParam, TRB1->FP1_OBRA ) 
	cQuery += " AND FPA_GERAEM >= ? " 
	Aadd(aParam, Dtos(MV_PAR06))
	cQuery += " AND FPA_GERAEM <= ? " 
	Aadd(aParam, Dtos(MV_PAR07))
	cQuery += " AND FPA_DTFIM >= ? " 
	Aadd(aParam, Dtos(MV_PAR13))
	cQuery += " AND FPA_DTFIM <= ? " 
	Aadd(aParam, Dtos(MV_PAR14))
	cQuery += "	AND FPA.D_E_L_E_T_ = ' '"
	cQuery += ") X "

	cQuery += " UNION ALL "

	cQuery += "SELECT FQZ_PROJET, FQZ_OBRA, FQZ_COD, B1_DESC, FQZ_QTD"
	cQuery += " , FQZ_QTD * FQZ_VLRUNI"
	cQuery += " , CASE WHEN FPA_ULTFAT = ' ' THEN FPA_DTINI ELSE FPA_ULTFAT END FPA_INICIO"
	cQuery += " , FPA_TPBASE, FPA_LOCDIA"
	cQuery += " , FPA_GRUA,  FPA_SEQGRU"
	cQuery += " , FPA_GERAEM, FPA_DTFIM, FPA_DTSCRT, FPA_ULTFAT"
	cQuery += " , CASE WHEN FPA_ULTFAT = ' ' THEN 0 ELSE 1 END SOMA_DATA, 'FQZ' ALIAS, FQZ_VLRPRO"
	cQuery += " FROM "+ RetSqlName("FQZ")+" FQZ"
	cQuery += " INNER JOIN "+ RetSqlName("SB1")+ " SB1"
	cQuery += " ON B1_COD = FQZ_COD"
	cQuery += " AND B1_FILIAL = '"+ xFilial("SB1")+"'"
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+ RetSqlName("FPA")+" FPA"
	cQuery += " ON FPA_FILIAL = '"+ xFilial("FPA")+"'"
	cQuery += " AND FPA_AS = FQZ_AS"
	cQuery += " AND FPA_GERAEM >= ? " 
	Aadd(aParam, Dtos(MV_PAR06))
	cQuery += " AND FPA_GERAEM <= ? " 
	Aadd(aParam, Dtos(MV_PAR07))
	cQuery += " AND FPA_DTFIM >= ? " 
	Aadd(aParam, Dtos(MV_PAR13))
	cQuery += " AND FPA_DTFIM <= ? " 
	Aadd(aParam, Dtos(MV_PAR14))
	cQuery += " AND FPA.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RETSQLNAME("FQ5")+" FQ5 "
	cQuery += "   ON FQ5_FILIAL='"+XFILIAL("FQ5")+"'"
	cQuery += "   AND FQ5.D_E_L_E_T_ = ' '"
	cQuery += "   AND FQ5_FILORI = FPA_FILIAL"
	cQuery += "   AND FQ5_VIAGEM = FPA_VIAGEM"
	cQuery += "   AND FQ5_AS = FPA_AS" 
	cQuery += "   AND FQ5_STATUS = '6' "
	cQuery += " WHERE FQZ_FILIAL = '"+ xFilial("FQZ")+"'"
	cQuery += " AND FQZ_PROJET = ? "
	Aadd(aParam , TRB1->FP0_PROJET) 
	cQuery += " AND FQZ_PV = ' '"
	cQuery += " AND FQZ_RETIRA > FPA_DTFIM"
	cQuery += " AND FQZ_OBRA = ?"
	Aadd(aParam, TRB1->FP1_OBRA ) 
	cQuery += " AND FQZ.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY FPA_PROJET, FPA_OBRA, FPA_PRODUT, FPA_SEQGRU"

	MPSysOpenQuery(cQuery,cAlias,,,aParam)
	TcSetField(cAlias, "FPA_GERAEM", "D")
	TcSetField(cAlias, "FPA_DTFIM", "D")
	TcSetField(cAlias, "FPA_INICIO", "D")
	TcSetField(cAlias, "FPA_DTSCRT", "D")
Return
