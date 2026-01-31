#INCLUDE "PROTHEUS.CH"

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFER081
Relatorio de Despesa de Frete por Transportador
Generico.

@sample
GFER093()

@author Israel A. Possoli
@since 15/02/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFER081()
	Local oReport
	Local aArea := GetArea()

	Private cDados
	Private cFilialIni
	Private cFilialFim
	Private dDataIni
	Private dDataFim
	Private cTranspIni
	Private cTranspFim
	Private cGrupoTransp
	Private cImpRecup
	Private cImpAuton
	Private lDetalhado	// Relatório detalhado
	Private cAliasRel

	Pergunte("GFER081",.F.)

	If TRepInUse() // teste padrão
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

	GFEDelTab(cAliasRel)
	RestArea( aArea )
Return

Static Function CriaTabela()

	// Criacao da tabela temporaria p/ imprimir o relat
	aTT := {{"CDTRAN" , "C", TamSX3("GU3_CDEMIT" )[1], 0},;	// Código Transportador,
			{"NMTRAN" , "C", TamSX3("GU3_NMEMIT" )[1], 0},;	// Nome Transportador,
			{"CATTRP" , "C", TamSX3("GU3_CATTRP" )[1], 0},;	// Categoria Transp,
			{"CDGREM" , "C", TamSX3("GU3_CDGREM" )[1], 0},;	// Grupo Transp,
			{"AUTON"  , "C", TamSX3("GU3_AUTON" )[1],  0},; 	// Autonomo 1=Sim;2=Nao
			{"PREV_TOT"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Previsto Total,
			{"PREV_NOR"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Previsto Normal,
			{"PREV_RED"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Previsto Redesp,
			{"PREV_REE"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Previsto Reentr,
			{"PREV_DEV"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Previsto Devol,
			{"PREV_SER"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Previsto Serviço,
			{"PREV_COM"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Previsto Compl,
			{"REAL_TOT"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Real Total,
			{"REAL_NOR"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Real Normal,
			{"REAL_RED"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Real Redesp,
			{"REAL_REE"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Real Reentr,
			{"REAL_DEV"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Real Devol,
			{"REAL_SER"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Real Serviço,
			{"REAL_COM"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;   //Frete Real Compl,
			{"REAL_AUT"  , "N", TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]}}    //Frete Real Autonomo,

	cAliasRel := GFECriaTab({aTT, {"CDTRAN+CATTRP+CDGREM"}})

Return

Static Function ReportDef()
	Local oReport := Nil
	Local aOrdem  := {}

	CriaTabela()

	oReport	:= TReport():New("GFER081","Despesa de Frete por Transportador","GFER081", {|oReport| ReportPrint(oReport)},"Despesa de Frete por Transportador")
	oReport:SetLandscape()   // define se o relatorio saira deitado
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	oReport:nFontBody	:= 10 // Define o tamanho da fonte.
	oReport:nLineHeight	:= 50 // Define a altura da linha.

	Pergunte("GFER081",.F.)
	lDetalhado := If(MV_PAR10 == 2, .T., .F.)

	Aadd( aOrdem, "Despesa de Frete por Transportador" ) // "Sequência" //"Codigo"

	oSection1 := TRSection():New(oReport,"Despesa de Frete por Transportador",{"(cAliasRel)"},aOrdem)
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"(cAliasRel)->CDTRAN", (cAliasRel), "Cod. Transp", "@!", TamSX3("GU3_CDEMIT" )[1], /*lPixel*/, )
	TRCell():New(oSection1,"(cAliasRel)->NMTRAN", (cAliasRel), "Nome Transp", "@!", TamSX3("GU3_NMEMIT" )[1], /*lPixel*/, )
	TRCell():New(oSection1,"(cAliasRel)->CATTRP", (cAliasRel), "Cat. Transp", "@!", 02						, /*lPixel*/, )
	TRCell():New(oSection1,"(cAliasRel)->CDGREM", (cAliasRel), "Grp. Transp", "@!", TamSX3("GU3_CDGREM" )[1], /*lPixel*/, )

	TRCell():New(oSection1,"(cAliasRel)->PREV_TOT", (cAliasRel), "Prev Total", "@E 99,999,999.99", TamSX3("GWI_VLFRET" )[1], /*lPixel*/, )//Frete Previsto Total,
	TRCell():New(oSection1,"(cAliasRel)->PREV_NOR", (cAliasRel), "Prev Normal" , "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, )//Frete Previsto Normal,
	TRCell():New(oSection1,"(cAliasRel)->PREV_RED", (cAliasRel), "Prev Redesp" , "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, )//Frete Previsto Redesp,
	TRCell():New(oSection1,"(cAliasRel)->PREV_REE", (cAliasRel), "Prev Reentr" , "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, ) //Frete Previsto Reentr,
	TRCell():New(oSection1,"(cAliasRel)->PREV_DEV", (cAliasRel), "Prev Devol"  , "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, )//Frete Previsto Devol,
	TRCell():New(oSection1,"(cAliasRel)->PREV_SER", (cAliasRel), "Prev Serviço", "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, )//Frete Previsto Serviço,
	TRCell():New(oSection1,"(cAliasRel)->PREV_COM", (cAliasRel), "Prev Complen", "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, ) //Frete Previsto Compl,

	TRCell():New(oSection1,"(cAliasRel)->REAL_TOT", (cAliasRel), "Real Total"  , "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, ) //Frete Real Total,
	TRCell():New(oSection1,"(cAliasRel)->REAL_NOR", (cAliasRel), "Real Normal" , "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, ) //Frete Real Normal,
	TRCell():New(oSection1,"(cAliasRel)->REAL_RED", (cAliasRel), "Real Redesp" , "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, )//Frete Real Redesp,
	TRCell():New(oSection1,"(cAliasRel)->REAL_REE", (cAliasRel), "Real Reentr" , "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, ) //Frete Real Reentr,
	TRCell():New(oSection1,"(cAliasRel)->REAL_DEV", (cAliasRel), "Real Devol"  , "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, )//Frete Real Devol,
	TRCell():New(oSection1,"(cAliasRel)->REAL_SER", (cAliasRel), "Real Serviço", "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, ) //Frete Real Serviço,
	TRCell():New(oSection1,"(cAliasRel)->REAL_COM", (cAliasRel), "Real Complen", "@E 99,999,999.99", TamSX3("GWI_VLFRET")[1], /*lPixel*/, ) //Frete Real Compl,

Return(oReport)


Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)

  /*aParam[1] - Filial de
	aParam[2] - Filial até
	aParam[3] - Data Emis de
	aParam[4] - Data Emis até
	aParam[5] - Transp de
	aParam[6] - Transp até
	aParam[7] - Grupo Transp
	aParam[8] - Impost Recup
	aParam[9] - Impost Auton
	aParam[10] - Tipo Relatório	*/

	cFilialIni := MV_PAR01
	cFilialFim := MV_PAR02
	dDataIni   := MV_PAR03
	dDataFim   := MV_PAR04
	cTranspIni := MV_PAR05
	cTranspFim := MV_PAR06
	cGrupoTrp  := MV_PAR07
	cImpRecup  := MV_PAR08
	cImpAuton  := MV_PAR09
	lDetalhado := If(MV_PAR10 == 2, .T., .F.)

	If !lDetalhado
		oSection1:aCell[6]:Disable()
		oSection1:aCell[7]:Disable()
		oSection1:aCell[8]:Disable()
		oSection1:aCell[9]:Disable()
		oSection1:aCell[10]:Disable()
		oSection1:aCell[11]:Disable()
		oSection1:aCell[12]:Disable()
		oSection1:aCell[14]:Disable()
		oSection1:aCell[15]:Disable()
		oSection1:aCell[16]:Disable()
		oSection1:aCell[17]:Disable()
		oSection1:aCell[18]:Disable()
	EndIf

	oReport:SetMeter(0)
	CarregaDados(oReport)

	dbSelectArea((cAliasRel))
	oReport:SetMeter((cAliasRel)->( LastRec() ))
	(cAliasRel)->( dbGoTop() )

	oSection1:Init()

	While !((cAliasRel)->( Eof() )	)
		oSection1:PrintLine()

		(cAliasRel)->( dbSkip() )
	EndDo

	oSection1:Finish()
Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} CarregaDados
Realiza a busca dos dados da seleção e cria a tabela temporária de impressão
Generico.

@sample
CarregaDados()

@author Israel A. Possoli
@since 15/02/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function CarregaDados(oReport)
	Local   cAliasGW1
	Local	cTransp
	Local	lAutonomo

	Private aValPrev[7], aValReal[8]

	// Faz a busca dos dados dos movimentos, movimentos contábeis e cálculo de frete
	cAliasGW1 := GetNextAlias()
	cQuery := "SELECT * "
	cQuery += " FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += " WHERE GW1.GW1_FILIAL >= '" + cFilialIni     + "' AND GW1.GW1_FILIAL <= '" + cFilialFim     + "'"
	cQuery += " AND GW1.GW1_DTEMIS >= '" + DTOS(dDataIni) + "' AND GW1.GW1_DTEMIS <= '" + DTOS(dDataFim) + "'"
	cQuery += " AND GW1.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)

	dbSelectArea((cAliasGW1))
	(cAliasGW1)->( dbGoTop() )

	While !oReport:Cancel() .AND. !(cAliasGW1)->( Eof() )
		oReport:IncMeter()
		dbSelectArea("GWM")
		dbSetOrder(2)
		dbSeek((cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_CDTPDC + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC)
		While !GWM->( Eof() ) .AND.	GWM->GWM_FILIAL == (cAliasGW1)->GW1_FILIAL ;
							  .AND.	GWM->GWM_CDTPDC == (cAliasGW1)->GW1_CDTPDC ;
							  .AND.	GWM->GWM_EMISDC == (cAliasGW1)->GW1_EMISDC ;
							  .AND.	GWM->GWM_SERDC  == (cAliasGW1)->GW1_SERDC ;
							  .AND.	GWM->GWM_NRDC   == (cAliasGW1)->GW1_NRDC

			aValPrev[1]  := 0	// Normal
			aValPrev[2]  := 0	// Compl Valor
			aValPrev[3]  := 0	// Compl Imposto
			aValPrev[4]  := 0	// Reentrega
			aValPrev[5]  := 0	// Devolução
			aValPrev[6]  := 0	// Redespacho
			aValPrev[7]  := 0	// Serviço

			aValReal[1]  := 0	// Normal
			aValReal[2]  := 0	// Compl Valor
			aValReal[3]  := 0	// Compl Imposto
			aValReal[4]  := 0	// Reentrega
			aValReal[5]  := 0	// Devolução
			aValReal[6]  := 0	// Redespacho
			aValReal[7]  := 0	// Serviço
			aValReal[8]	 := 0	// Realizado Autônomo

			/***********************************************
				Define o transportador do Rateio Contábil
			 ***********************************************/
			// Se estimativa não entra no relatório
			If GWM->GWM_TPDOC == '4'
				GWM->(dbSkip())
				Loop
			EndIf
			
			// Cálculo
			If GWM->GWM_TPDOC == '1'
				dbSelectArea("GWF")
				dbSetOrder(1)
				dbSeek(GWM->GWM_FILIAL + GWM->GWM_NRDOC)
				cTransp := GWF->GWF_TRANSP
			EndIf

			// Documento de Frete
			If GWM->GWM_TPDOC == '2'
				cTransp := GWM->GWM_CDTRP
			EndIf

			// Contrato com Autônomo
			If GWM->GWM_TPDOC == '3'
				dbSelectArea("GW2")
				dbSetOrder(1)
				dbSeek(GWM->GWM_FILIAL + GWM->GWM_NRDOC)
				cTransp := GW2->GW2_CDPROP
			EndIf

			/***********************************************
				Verifica se o transportador está dentro da faixa informada
			 ***********************************************/
			If cTransp < cTranspIni .OR. cTransp > cTranspFim
				GWM->(dbSkip())
				Loop
			EndIf

			/***********************************************
				Criação/Modificação da tabela temporária
			 ***********************************************/
			dbSelectArea((cAliasRel))
			dbSetOrder(1)
			If dbSeek(cTransp)
			    // Altera o registro corrente
			    RecLock((cAliasRel), .F.)
			Else
				dbSelectArea("GU3")
				dbSetOrder(1)
				dbSeek(xFilial("GU3")+cTransp)
				// Cria um novo registro com o novo transportador
				RecLock((cAliasRel), .T.)
					(cAliasRel)->CDTRAN := cTransp
					(cAliasRel)->NMTRAN := GU3->GU3_NMEMIT
					(cAliasRel)->CATTRP := GU3->GU3_CATTRP
					(cAliasRel)->CDGREM := GU3->GU3_CDGREM
					(cAliasRel)->AUTON	:= GU3->GU3_AUTON

					(cAliasRel)->PREV_TOT := 0
					(cAliasRel)->PREV_NOR := 0
					(cAliasRel)->PREV_RED := 0
					(cAliasRel)->PREV_REE := 0
					(cAliasRel)->PREV_DEV := 0
					(cAliasRel)->PREV_SER := 0
					(cAliasRel)->PREV_COM := 0
					(cAliasRel)->REAL_TOT := 0
					(cAliasRel)->REAL_NOR := 0
					(cAliasRel)->REAL_RED := 0
					(cAliasRel)->REAL_REE := 0
					(cAliasRel)->REAL_DEV := 0
					(cAliasRel)->REAL_SER := 0
					(cAliasRel)->REAL_COM := 0
					(cAliasRel)->REAL_AUT := 0
			EndIf

			lAutonomo := If((cAliasRel)->AUTON == '1' .OR. GWM->GWM_TPDOC == '3', .T., .F.)

			/***********************************************
				Busca os valores de Previsão/Realização
			 ***********************************************/
			// Cálculo de Frete - Despesas de Previsão
			If GWM->GWM_TPDOC == '1'
				FretePrevisto(lAutonomo)

				// Valores de Frete Previsto
				(cAliasRel)->PREV_NOR += aValPrev[1]	// Normal
				(cAliasRel)->PREV_RED += aValPrev[6]	// Redespacho
				(cAliasRel)->PREV_REE += aValPrev[4]	// Reentrega
				(cAliasRel)->PREV_DEV += aValPrev[5]	// Devolução
				(cAliasRel)->PREV_SER += aValPrev[7]	// Serviço
				(cAliasRel)->PREV_COM += aValPrev[2] + aValPrev[3]	// Complementar: Compl de Valor + Compl. Imposto
				(cAliasRel)->PREV_TOT += aValPrev[1] + ;
										 aValPrev[2] + ;
										 aValPrev[3] + ;
										 aValPrev[4] + ;
										 aValPrev[5] + ;
										 aValPrev[6] + ;
										 aValPrev[7]	// Total
			EndIf

			// Documento de Frete/Contrato - Realizado
			If GWM->GWM_TPDOC == '2' .OR. GWM->GWM_TPDOC == '3'
				FreteRealizado(lAutonomo)

				(cAliasRel)->REAL_NOR += aValReal[1]	// Normal
				(cAliasRel)->REAL_RED += aValReal[6]	// Redespacho
				(cAliasRel)->REAL_REE += aValReal[4]	// Reentrega
				(cAliasRel)->REAL_DEV += aValReal[5]	// Devolução
				(cAliasRel)->REAL_SER += aValReal[7]	// Serviço
				(cAliasRel)->REAL_COM += aValReal[2] + aValReal[3]	// Complementar: Compl de Valor + Compl. Imposto
				(cAliasRel)->REAL_TOT += aValReal[1] + ;
										 aValReal[2] + ;
										 aValReal[3] + ;
										 aValReal[4] + ;
										 aValReal[5] + ;
										 aValReal[6] + ;
										 aValReal[7]	// Total
				// (cAliasRel)->REAL_AUT += aValReal[8]	// Realizado Autônomo
			EndIf

			MsUnlock()

			GWM->( dbSkip() )
		EndDo

		(cAliasGW1)->(dbSkip())
	EndDo
   (cAliasGW1)->(dbCloseArea())
Return


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} FretePrevisto
Altera as informações no array aValPrev com os valores relativo ao Frete Previsto
O id do array aValPrev é o campo TPCALC
Generico.

@sample
GFER093()

@author Israel A. Possoli
@since 15/02/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function FretePrevisto(lAutonomo)
	// Busca o cálculo de frete relacionado ao Movimento Contábil
	dbSelectArea("GWF")
	dbSetOrder(1)
	If dbSeek(GWM->GWM_FILIAL + GWM->GWM_NRDOC)
		If GWF->GWF_TPCALC != "8" // Frete de estimativa não entra no frete previsto
			aValPrev[Val(GWF->GWF_TPCALC)] := GWM->GWM_VLFRET
	
			If lAutonomo
				// Adicionar impostos
				If cImpAuton == 2
					aValPrev[Val(GWF->GWF_TPCALC)] += GWM->GWM_VLINEM + ;
											 		  GWM->GWM_VLIRRF + ;
													  GWM->GWM_VLSEST + ;
													  GWM->GWM_VLISS  + ;
													  Iif(GFXCP2510("GWM_VLIBM"), GWM->GWM_VLIBM, 0)  + ;
													  GWM->GWM_VLINAU
				EndIf
			Else
				// Descontar impostos recuperáveis
				If cImpRecup == 1
					 //Retira o ICMS
					If GWF->GWF_CRDICM == "1"
						aValPrev[Val(GWF->GWF_TPCALC)] -= (GWM->GWM_VLICMS + Iif(GFXCP2510("GWM_VLIBS"), GWM->GWM_VLIBS, 0))
					EndIf
	
					//Retira o PIS e COFINS
					If GWF->GWF_CRDPC == "1"
						aValPrev[Val(GWF->GWF_TPCALC)] -= (GWM->GWM_VLCOFI + GWM->GWM_VLPIS + Iif(GFXCP2510("GWM_VLCBS"), GWM->GWM_VLCBS, 0))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} FreteRealizado
Altera as informações no array aValReal com os valores relativo ao Frete Realizado
O id do array aValReal é o campo TPCALC
Generico.

@sample
GFER093()

@author Israel A. Possoli
@since 18/02/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function FreteRealizado(lAutonomo)
	// Busca o cálculo de frete relacionado ao Movimento Contábil
	dbSelectArea("GW3")
	dbSetOrder(1)
	If dbSeek(GWM->GWM_FILIAL + GWM->GWM_CDESP + GWM->GWM_CDTRP + GWM->GWM_SERDOC + GWM->GWM_NRDOC + DTOS(GWM->GWM_DTEMIS))
		aValReal[Val(GW3->GW3_TPDF)] := GWM->GWM_VLFRET

		If lAutonomo
			// Adicionar impostos
			If cImpAuton == 2
				aValReal[Val(GW3->GW3_TPDF)] += GWM->GWM_VLINEM + ;
										 		GWM->GWM_VLIRRF + ;
												GWM->GWM_VLSEST + ;
												GWM->GWM_VLISS  + ;
												Iif(GFXCP2510("GWM_VLIBM"), GWM->GWM_VLIBM, 0)  + ;
												GWM->GWM_VLINAU
			EndIf

		Else
			// Descontar impostos recuperáveis
			If cImpRecup == 1
				 //Retira o ICMS
				If GW3->GW3_CRDICM == "1"
					aValReal[Val(GW3->GW3_TPDF)] -= (GWM->GWM_VLICMS + Iif(GFXCP2510("GWM_VLIBS"), GWM->GWM_VLIBS, 0))
				EndIf

				//Retira o PIS e COFINS
				If GW3->GW3_CRDPC == "1"
					aValReal[Val(GW3->GW3_TPDF)] -= (GWM->GWM_VLCOFI + GWM->GWM_VLPIS + Iif(GFXCP2510("GWM_VLCBS"), GWM->GWM_VLCBS, 0))
				EndIf
			EndIf
		EndIf
	EndIf
Return
