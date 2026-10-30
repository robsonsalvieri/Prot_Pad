#Include 'Protheus.ch'
//#Include 'PLSDAGCNT.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define _LF Chr(13)+Chr(10) // Quebra de linha.
#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25
#Define __NTAM5  38
#Define __NTAM6  15
#Define __NTAM7  5
#Define __NTAM8  9
#Define __NTAM9  7
#Define __NTAM10 30
#Define __NTAM11 8
#Define TABBD7 1
#Define TABBM1 2
#Define _DEBITO '1'
#Define _CREDITO '2'
#Define _PARTDOBRADA '3'
#Define _POOLRISCO '1'
#Define Moeda "@E 999,999,999.99"
#DEFINE ARQ_LOG_CARGA	"diops_carga_agrupamento_contratos.log"

STATIC oFnt10C 		:= TFont():New("Arial",12,12,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt11N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",14,14,,.T., , , , .t., .f.)
STATIC oFnt09C 		:= TFont():New("Arial",9,9,,.f., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)

//------------------------------------------------------------------
/*/{Protheus.doc} PLSDAGCNT

@description Geração de Dados - DIOPS Agrupamento de Contratos
@author Roger C
@since 01/10/2017
@version P12

/*/
//------------------------------------------------------------------
Function PLSDAGCNT()
	Local aResult		:= {}

	Private cPerg		:= "PLSDAGCNT"
	PRIVATE cTitulo 		:= "DIOPS - Agrupamento de Contratos"
	PRIVATE oReport     	:= nil
	PRIVATE cFileName		:= "DIOPS_Agrupamento_de_Contratos_"+CriaTrab(NIL,.F.)

	DEFAULT lWeb			:= .f.
	DEFAULT aParWeb		:= {}
	DEFAULT cDirPath		:= lower(getMV("MV_RELT"))
	DEFAULT cBenefLog	  	:= ""

	If  Pergunte(cPerg,.T.)//nOpca == 1
		If Empty(MV_PAR01)
			MsgInfo("Parâmetro não informado, por favor informar.","DIOPS - Agrupamento de Contratos" ) //"Parâmetro não informado, por favor informar."#"DIOPS - Distribuição dos Saldos de Contas a Pagar"
		else
			Processa( {|| aResult := PLSDAGRP(LastDay(MV_PAR01),.T.)}, "DIOPS - Agrupamento de Contratos") //

			// Se não há dados a apresentar
			If aResult[1]
				MsgAlert('Não há dados a apresentar')
				Return
			EndIf

			oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)

			oReport:lInJob  	:= lWeb
			oReport:lServer 	:= lWeb
			oReport:cPathPDF	:= cDirPath

			oReport:setDevice(IMP_PDF)
			oReport:setResolution(72)
			oReport:SetLandscape()
			oReport:SetPaperSize(9)
			oReport:setMargin(10,10,10,10)

			IF !lWeb
				oReport:Setup()  //Tela de configurações
			ENDIF

			lRet := PLSRDAGRP(aResult[2]) //Recebe Resultado da Query e Monta Relatório

			if lRet
				aRet := {cFileName+".pdf",""}
			else
				aRet := {"",""}
			endif

			IF (lRet)
				oReport:EndPage()
				oReport:Print()
			ENDIF

			if lWeb
				PLSCHKRP(cDirPath, cFileName+".pdf")
			endIf
		endif
	endif

Return

//------------------------------------------------------------------
/*/{Protheus.doc} DAGCNTPROC

@description Processa o DIOPS Grava arquivo .CSV com as informações
@author Roger C
@since 13/10/2017
@version P12

/*/
//------------------------------------------------------------------
Function PLSRDAGRP(aValores)

	LOCAL lRet			:= .T.
	Local nI			:= 0
	Local nVez			:= 0
	Local nSom			:= 0
	Local cValor 		:= ""
	Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro

	oReport:StartPage()

	//Logotipo ANS
	cBMP	:= "lgrl01.bmp"
	If File("lgdiopsidr" + FWGrpCompany() + FWCodFil() + ".bmp")
		cBMP :=  "lgdiopsidr" + FWGrpCompany() + FWCodFil() + ".bmp"
	ElseIf File("lgdiopsidr" + FWGrpCompany() + ".bmp")
		cBMP :=  "lgdiopsidr" + FWGrpCompany() + ".bmp"
	EndIf

	oReport:box(30, 20, 290, 805 )  //Box principal
	oReport:box(30, 20, 100, 805)	//Box Titulo
	cStr := "Receita e Despesas dos Contratos Agregados ao Agrupamento (RN Nº 309 de 2012)"
	oReport:Say(075, 155, cStr, oFnt14N)

	// Deve ser posterior ao desenho do quadro em que está, senão apaga o bitmap na impressão
	oReport:SayBitmap(40, 25, cBMP, , 50,150)

	//oReport:box(100, 135, 175 , 580)
	oReport:Say(140, 023, "Cobertura Assistencial com", oFnt12N)
	oReport:Say(155, 023, "Preço Pré depois da Lei", oFnt12N)

	oReport:box(100, 220, 200 , 580)
	oReport:Say(120, 225, "Planos Coletivos Adesão", oFnt12N)

	oReport:box(130, 220, 200, 350)
	oReport:Say(155, 225, "Contraprestação", oFnt10c)
	oReport:Say(165, 225, "Emitida", oFnt10c)

	oReport:box(130, 350, 200, 480)
	oReport:Say(155, 355, "Eventos/Sinistros", oFnt10c)
	oReport:Say(165, 355, "Conhecidos", oFnt10c)

	oReport:box(100, 480, 200 , 805)
	oReport:Say(120, 485, "Planos Coletivos por Empresariais", oFnt12N)

	oReport:box(130, 480, 200, 610)
	oReport:Say(155, 485, "Contraprestação", oFnt10c)
	oReport:Say(165, 485, "Emitida", oFnt10c)

	oReport:box(130, 610, 200, 805)
	oReport:Say(155, 615, "Eventos/Sinistros", oFnt10c)
	oReport:Say(165, 615, "Conhecidos", oFnt10c)

	oReport:box(200, 20, 215, 805)
	oReport:Fillrect( {201, 21, 214, 804 }, oBrush1)

	oReport:box(215, 20, 240, 805)
	oReport:Say(228, 23, "Contratos Agredados ao Pool de Risco", oFnt10N)

	oReport:box(240, 20, 265, 805)
	oReport:Say(253, 23, "Demais Contratos", oFnt10N)

	oReport:box(265, 20, 290, 805)
	oReport:Fillrect( {266, 21, 289, 804 }, oBrush1)
	oReport:Say(278, 23, "TOTAL", oFnt10N)

	//Line das colunas
	nSom := 0
	For nI := 1 to 4
		oReport:Line(200, 220 + nSom, 290, 220 + nSom)
		nSom += 130
	Next

	//****************************
	//Impressão dos Valores
	//****************************
	nSom := 0
	For nVez := 1 to 3
		For nI := 1 to 4
			cValor := aValores[nVez][nI]
			oReport:Say(203+(25*nVez), 225 + nSom, cValtoChar(cValor)/*"1234567890123"*/, oFnt11N)
			nSom += 130
		Next
		nSom := 0
	Next

return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} PLSDAGRP

@description Retorna os dados dos agrupamentos de contratos
@author Roger C
@since 13/10/2017
@version P12
@return

/*/
//------------------------------------------------------------------
Function PLSDAGRP(dDatAte,lExibeTela)
	Local nCount	:= 0
	Local nProc		:= 0
	Local cSql	:= ''
	Local nRecTr1	:= 0
	Local nPos		:= 0
	Local nVar		:= 0
	Local nTabela	:= 0
	Local nLen		:= 0
	Local cConta	:= ''
	Local cMsg		:= ""
	Local cProd		:= ""
	Local lEnvAns	:= .F.

	Local aRetAgrp	:= 	{;
		{ 0,0,0,0,0,0 },;			// Contratos Agregados ao Pool de Risco
		{ 0,0,0,0,0,0 },;			// Demais Contratos
		{ 0,0,0,0,0,0 }; 			// Total
		}

	Local aContas	:= {}

	Local oProd		:= tHashMap():New()
	Local oMatric	:= tHashMap():New()
	Local oMatEmp	:= tHashMap():New()
	Local oContaNaoParam	:= tHashMap():New()
	Local oProdNaoEnvia		:= tHashMap():New()
	Local oTipoLancInvld	:= tHashMap():New()

	// Array default das contas do DIOPS
	Local aDefDiops	:= {'31111104',;
		'41111104','41121104','41131104','41141104','41151104','41171104','41181104','41191104',;
		'31111106',;
		'41111106','41121106','41131106','41141106','41151106','41171106','41181106','41191106',;
		'31171104',;
		'31171106'}


	Default dDatAte		:= LastDay(dDataBase)
	Default lExibeTela	:= .T.

	// Loop de colunas para preenchimento do array principal de valores do DIOPS - MV_PLAGC01, MV_PLAGC02, MV_PLAGC03 e MV_PLAGC04
	For nVar := 1 to 20
		cStr	:= GetNewPar('MV_PLAGC'+AllTrim(StrZero(nVar,2)), aDefDiops[nVar] )
		For nPos := 1 to Len(cStr)
			If Subs(cStr,nPos,1) == ','
				aAdd(aContas, { cConta, nVar } )
				cConta := ''
			Else
				cConta := cConta + Subs(cStr,nPos,1)
			EndIf
		Next nPos
		If !Empty(cConta)
			aAdd(aContas, { cConta, nVar } )
			cConta := ''
		EndIf
	Next nVar

	If lExibeTela
		ProcRegua(nRecTr1)
	EndIf

	// Indice para busca:
	BA1->(dbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	BA3->(dbSetOrder(1)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
	BI3->(dbSetOrder(1)) //BI3_FILIAL+BI3_CODINT+BI3_CODIGO

	For nTabela := TABBD7 to TABBM1
		cCabTab := IIf(nTabela==TABBD7,"[BD7]","[BM1]")
		If CarregaDados(cCabTab,@nCount,dDatAte)
			PlsLogFil(CENDTHRL("I") + cCabTab +"Inicio do processamento da tabela. ",ARQ_LOG_CARGA)
			PlsLogFil(CENDTHRL("I") + cCabTab +"Encontrou dados para processar. ",ARQ_LOG_CARGA)
			nProc := 0
			While TRBAGR->(!Eof())
				nProc += 1
				If nProc % 50000 == 0 .Or. nProc == 1
					cMsg := "Foram encontrados " + alltrim(str(nCount)) + " registros. Processando registro " + alltrim(str(nProc) )
					PlsLogFil(CENDTHRL("I") + cCabTab +cMsg,ARQ_LOG_CARGA)
					If lExibeTela
						IncProc(cMsg)
					EndIf
				EndIf

				nValor := TRBAGR->CV3_VLR01
				// Se não houver valor, vai para o próximo registro.
				If nValor <= 0
					PlsLogFil(CENDTHRL("W") + cCabTab +"Lançamento contábil zerado. Recno: " + AllTrim(Str(TRBAGR->RecEve)),ARQ_LOG_CARGA)
					TRBAGR->(dbSkip())
					Loop
				EndIf

				// Posiciona no registro para obtenção de dados
				If TRBAGR->TIPO == 'P'
					cProd := TRBAGR->(BD7_OPEUSR+BD7_CODPLA)
				Else
					If !HMGet(oMatric, TRBAGR->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_DIGITO ),@cProd)
						BA1->(msSeek(xFilial('BA1')+TRBAGR->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_DIGITO) ) )
						If !Empty(BA1->BA1_CODPLA)
							cProd := BA1->BA1_CODINT + BA1->BA1_CODPLA
							HMSet(oMatric,TRBAGR->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_DIGITO) ,cProd)
						Else
							If !HMGet(oMatEmp, TRBAGR->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB) ,@cProd)
								BA3->(msSeek(xFilial('BA3')+TRBAGR->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB)) )
								cProd := BA3->(BA3_CODINT+BA3_CODPLA)
								HMSet(oMatEmp,TRBAGR->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB) ,cProd)
							EndIf
						EndIf
					EndIf
				EndIf

				lEnvAns := .F.
				If !HMGet( oProd, cProd, @lEnvAns)
					// Posiciona BI3-Produto Saude
					If BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO) <> xFilial("BI3") + cProd
						BI3->( msSeek( xFilial("BI3") + cProd ) )
					EndIf
					lEnvAns := BI3->BI3_INFANS == '1' .and. AllTrim(BI3->BI3_MODPAG) == '1' .and.  BI3->BI3_APOSRG == '1'
					//aAdd(aProd, { cProd, lEnvAns } )
					HMSet( oProd , cProd, lEnvAns )
				EndIf

				// Se retornar falso, é porque deve desconsiderar o registro
				If !lEnvAns
					HMSet( oProdNaoEnvia,cProd,AllTrim(Str(TRBAGR->RecEve)) )
					TRBAGR->(dbSkip())
					Loop
				EndIf

				If TRBAGR->CV3_DC == _DEBITO
					cConta	:= TRBAGR->CV3_DEBITO
					nVez	:= 1
				ElseIf TRBAGR->CV3_DC == _CREDITO
					cConta	:= TRBAGR->CV3_CREDIT
					nVez	:= 1
				ElseIf TRBAGR->CV3_DC == _PARTDOBRADA
					cConta	:= TRBAGR->CV3_DEBITO
					cConta2	:= TRBAGR->CV3_CREDIT
					nVez	:= 2
				Else
					TRBAGR->(dbSkip())
					HMSet( oTipoLancInvld,TRBAGR->CV3_DC,AllTrim(Str(TRBAGR->RecEve)) )
					Loop
				EndIf

				For nVar := 1 to nVez

					cConta	:= SubStr(AllTrim(IIf(nVar==1,cConta,cConta2)),1,8)
					nPos := aScan(aContas, {|x| x[1] == cConta} )

					If nPos == 0
						HMSet( oContaNaoParam,cConta,AllTrim(Str(TRBAGR->RecEve)) )
						Loop
					EndIf

					If nPos > 0
						If nPos == 1
							nPos:=1
						ElseIf nPos >=2 .And. nPos <= 9
							nPos:=2
						ElseIf nPos == 10
							nPos:=3
						ElseIf nPos >=11 .And. nPos <= 18
							nPos:=4
						ElseIf nPos == 19
							nPos:=5
						else
							nPos:=6
						EndIf
					EndIf

					If TRBAGR->BT5_AGR309 == _POOLRISCO
						aRetAgrp[ 1, aContas[nPos,2] ] += nValor
					Else //Demais modalidades de agrupamento
						aRetAgrp[ 2, aContas[nPos,2] ] += nValor
					EndIf
					// Adiciona na totalização
					aRetAgrp[ 3,aContas[nPos,2] ] += nValor

				Next nVar

				TRBAGR->(DbSkip())
			EndDo

			TRBAGR->(DbCloseArea())
			PlsLogFil(CENDTHRL("I") + cCabTab +"Fim do processamento da tabela. ",ARQ_LOG_CARGA)

			LogaIgnorados(oContaNaoParam,cCabTab,"Não encontrou a conta ",". Verifique os parametos MV_PLAGC01, MV_PLAGC02, MV_PLAGC03 e MV_PLAGC04")
			LogaIgnorados(oProdNaoEnvia,cCabTab,"Produto não envia dados para a ANS. Produto ",". Verifique os campos BI3->BI3_INFANS == '1' .and. AllTrim(BI3->BI3_MODPAG) == '1' .and.  BI3->BI3_APOSRG == '1' ")
			LogaIgnorados(oTipoLancInvld,cCabTab,"Tipo de lançamento inválido. Tipo lcto:","")

		Else
			PlsLogFil(CENDTHRL("I") + cCabTab +"Não encontrou dados para processar. ",ARQ_LOG_CARGA)
		EndIf
	Next nTabela

	PlsLogFil(CENDTHRL("I") + cCabTab +"Fim do processamento dos agrupamentos selecionados. ",ARQ_LOG_CARGA)

Return( { Len(aRetAgrp)>0 , aRetAgrp } )

/*/{Protheus.doc} CarregaDados
	Decide qual função de carregamento de dados deve ser chamada e devolve se encontrou dados
	@type  Static Function
	@author everton.mateus
	@since 01/02/2019
	@version P12
	@param cSql, String, Query que será executada
	@return lFound, Boolean, .T. Encontrou dados e a área foi aberta, .F. não encontrou dados e a área foi fechada
/*/
Static Function CarregaDados(cCabTab,nCount,dDatAte)
	Local lFound 		:= .F.
	Local lCount 		:= .T.

	Default cCabTab		:= "[BD7]"
	Default nCount		:= 0
	Default dDatAte		:= LastDay(dDataBase)

	If cCabTab == "[BD7]"
		lFound := CarDadBD7(cCabTab,dDatAte,lCount,@nCount)
		If lFound
			lFound := CarDadBD7(cCabTab,dDatAte)
		EndIf
	ElseIf cCabTab == "[BM1]"
		lFound := CarDadBM1(cCabTab,dDatAte,lCount,@nCount)
		If lFound
			lFound := CarDadBM1(cCabTab,dDatAte)
		EndIf
	EndIf

Return lFound

//------------------------------------------------------------------
/*/{Protheus.doc} CarDadBD7

@description Retorna os dados da BD7 que devem ser processados
@author everton.mateus
@since 01/02/2019
@version P12
@param dDatAte, Date, Data até
@param lCount, Boolean, Indica se deve fazer um count na query
@param nCount, Number, Deve ser passado como referência quando lCount == .T. para retornar o Count da Query

/*/
//------------------------------------------------------------------
Static Function CarDadBD7(cCabTab,dDatAte,lCount,nCount)
	Local lFound := .F.
	Local cSql := ""
	Local lMsSql	:= "MSSQL" $ Upper(TcGetDb())
	Local cNotIn	:= RetLocIgn()
	Local dDatDe	:= CTOD("")

	Default dDatAte		:= LastDay(dDataBase)
	Default lCount		:= .F.
	Default nCount		:= 0

	dDatDe	:= FirstDay(dDatAte-87)
	// Query principal na Composição dos Itens da Guia
	If lCount
		cSql	+= "SELECT Count(1) TOTAL "
	Else
		cSql += "SELECT BD7.R_E_C_N_O_ AS RecEve, SE2.R_E_C_N_O_ AS RecTit, BD7_VLRPAG AS VALOR, BII_TIPPLA, BT5_AGR309, 'P' AS TIPO "
		cSql += " ,CV3_VLR01,CV3_DC,CV3_DEBITO,CV3_CREDIT "
		cSql += " ,BD7_CODPLA "
		cSql += " ,BD7_OPEUSR "
	EndIf

	cSql += " FROM " + PLSSQLNAME("SE2") + " SE2 " + Iif( lMsSql, ' (NOLOCK) ', '' )

	// Composição dos Itens da Guia
	cSql += " INNER JOIN " + PLSSQLNAME("BD7") + " BD7 " + Iif( lMsSql, ' (NOLOCK) ', '' )
	cSql += "    ON BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSql += "   AND BD7_CHKSE2 = E2_FILIAL || '|' || E2_PREFIXO || '|' || E2_NUM || '|' || E2_PARCELA || '|' || E2_TIPO || '|' || E2_FORNECE || '|' || E2_LOJA "
	cSql += "   AND BD7_SITUAC <> '2' " // 1 - Ativo / 2 - Cancelado / 3 - Bloqueado
	cSql += "   AND BD7_DTDIGI  <= '" + DtoS(dDatAte) + "' "
	If !Empty(cNotIn)
		cSql += "   AND BD7_CODLDP NOT IN" + cNotIn + " "
	EndIf
	cSql += "   AND BD7.D_E_L_E_T_ = ' ' "

	//CV3
	cSql += " INNER JOIN " + PLSSQLNAME("CV3") + " CV3 " + Iif( lMsSql, ' (NOLOCK) ', '' )
	cSql += " 	 ON CV3_FILIAL = '" + xFilial("CV3") + "' "
	cSql += " 	AND CV3.CV3_TABORI = 'BD7' "
	cSql += "   	AND CV3.CV3_RECORI = BD7.R_E_C_N_O_ "
	cSql += "   	AND CV3.D_E_L_E_T_ = ' ' "

	//CT2
	cSql += " INNER JOIN " + PLSSQLNAME("CT2") + " CT2 " + Iif( lMsSql, ' (NOLOCK) ', '' )
	cSql += " 	 ON CT2.R_E_C_N_O_ = CV3.CV3_RECDES "
	cSql += " 	AND CT2.D_E_L_E_T_ = ' ' "

	// Contrato
	cSql += "INNER JOIN "+RetSqlName("BT5")+" BT5 "+ Iif( lMsSql, ' (NOLOCK) ', '' )
	cSql += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
	cSql += "  AND BT5_CODINT=BD7.BD7_OPEUSR "
	cSql += "  AND BT5_CODIGO=BD7.BD7_CODEMP "
	cSql += "  AND BT5_NUMCON=BD7.BD7_CONEMP "
	cSql += "  AND BT5_VERSAO=BD7.BD7_VERCON "
	cSql += "  AND BT5_INFANS = '1' "
	cSql += "  AND BT5.D_E_L_E_T_ = '' "

	// Tipo de Contrato
	cSql += "INNER JOIN "+RetSqlName("BII")+" BII "+ Iif( lMsSql, '  (NOLOCK) ', '' )
	cSql += "ON BII_FILIAL='"+xFilial('BII')+"' "
	cSql += "  AND BII_CODIGO=BT5.BT5_TIPCON "
	cSql += "  AND BII_TIPPLA IN ('2','3') "			// Deve considerar contratos tipo 2 (Col.Empresarial) e 3 (Col.Adesão)
	cSql += "  AND BII.D_E_L_E_T_ = '' "

	cSql += " WHERE E2_FILIAL  = '" + xFilial("SE2") + "' "

	cSql += "   AND E2_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT,"|") //AB-|FB-|FC-|FU-|IR-|IN-|IS-|PI-|CF-|CS-|FE-|IV-//IR-//IN-
	cSql += "   AND SE2.E2_EMISSAO BETWEEN '" + dtoS(dDatDe) + "' AND '" + dtoS(dDatAte) + "'"
	cSql += "   AND SE2.D_E_L_E_T_ = ' ' "

	cSql += "   AND BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSql += "   AND BD7_SITUAC <> '2' " // 1 - Ativo / 2 - Cancelado / 3 - Bloqueado
	cSql += "   AND BD7_BLOPAG <> '1' "	// Pagamento liberado
	cSql += "   AND BD7_DTDIGI  > ' ' "
	cSql += "   AND BD7_DTDIGI  <= '" + DtoS(dDatAte) + "' "
	If !Empty(cNotIn)
		cSql += "   AND BD7_CODLDP NOT IN" + cNotIn + " "
	EndIf
	cSql += "   AND BD7.D_E_L_E_T_ = ' ' "
	If !lCount
		cSql	+= " ORDER BY TIPO, BII_TIPPLA, BT5_AGR309, RecTit, RecEve "
	EndIf

	cSql	:= ChangeQuery(cSql)

	lFound := OpenQuery(cSql,cCabTab)
	If lCount .AND. lFound
		nCount := TRBAGR->TOTAL
		lFound := nCount > 0
	EndIf

Return lFound

//------------------------------------------------------------------
/*/{Protheus.doc} CarDadBM1

@description Retorna os dados da BM1 que devem ser processados
@author everton.mateus
@since 01/02/2019
@version P12
@param dDatAte, Date, Data até
@param lCount, Boolean, Indica se deve fazer um count na query
@param nCount, Number, Deve ser passado como referência quando lCount == .T. para retornar o Count da Query

/*/
//------------------------------------------------------------------
Static Function CarDadBM1(cCabTab,dDatAte,lCount,nCount)
	Local lFound := .F.
	Local cSql := ""
	Local lMsSql	:= "MSSQL" $ Upper(TcGetDb())
	Local cNotIn	:= RetLocIgn()
	Local dDatDe	:= CTOD("")
	Default dDatAte		:= LastDay(dDataBase)
	Default lCount		:= .F.
	Default nCount		:= 0

	dDatDe	:= FirstDay(dDatAte-87)
	// Query principal na Composição dos Itens de Cobrança
	If lCount
		cSql	+= "SELECT Count(1) TOTAL "
	Else
		cSql	+= "SELECT BM1.R_E_C_N_O_ AS RecEve, SE1.R_E_C_N_O_ AS RecTit, BM1_VALOR AS VALOR, BII_TIPPLA, BT5_AGR309, 'R' AS TIPO "
		cSql	+= " ,CV3_VLR01,CV3_DC,CV3_DEBITO,CV3_CREDIT "
		cSql	+= " ,BM1_MATRIC "
		cSql	+= " ,BM1_TIPREG "
		cSql	+= " ,BM1_DIGITO "
		cSql	+= " ,BM1_CODINT "
		cSql	+= " ,BM1_CODEMP "
		cSql	+= " ,BM1_CONEMP "
		cSql	+= " ,BM1_VERCON "
		cSql	+= " ,BM1_SUBCON "
		cSql	+= " ,BM1_VERSUB "
	EndIf

	cSql += " FROM " + PLSSQLNAME("SE1") + " SE1 " + Iif( lMsSql, ' (NOLOCK) ', '' )

	// Composição da Cobrança
	cSql += " INNER JOIN " + PLSSQLNAME("BM1") + " BM1 "
	cSql += "    ON BM1_FILIAL =  '" + xFilial("BM1") + "' "
	cSql += "   AND BM1_PLNUCO = E1_PLNUCOB "
	cSql += "   AND BM1_PREFIX = E1_PREFIXO "
	cSql += "   AND BM1_NUMTIT = E1_NUM "
	cSql += "   AND BM1_PARCEL = E1_PARCELA "
	cSql += "   AND BM1_TIPTIT = E1_TIPO "
	cSql += "   AND BM1.D_E_L_E_T_ = ' ' "

	//CV3
	cSql += " INNER JOIN " + PLSSQLNAME("CV3") + " CV3 " + Iif( lMsSql, ' (NOLOCK) ', '' )
	cSql += " 	 ON CV3_FILIAL = '" + xFilial("CV3") + "' "
	cSql += " 	AND CV3.CV3_TABORI = 'BM1' "
	cSql += "   	AND CV3.CV3_RECORI = BM1.R_E_C_N_O_ "
	cSql += "   	AND CV3.D_E_L_E_T_ = ' ' "

	//BT2
	cSql += " INNER JOIN " + PLSSQLNAME("CT2") + " CT2 " + Iif( lMsSql, ' (NOLOCK) ', '' )
	cSql += " 	 ON CT2.R_E_C_N_O_ = CV3.CV3_RECDES "
	cSql += " 	AND CT2.D_E_L_E_T_ = ' ' "

	// Contrato
	cSql += "INNER JOIN "+RetSqlName("BT5")+" BT5 "+ Iif( lMsSql, ' (NOLOCK) ', '' )
	cSql += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
	cSql += "  AND BT5_CODINT=BM1.BM1_CODINT "
	cSql += "  AND BT5_CODIGO=BM1.BM1_CODEMP "
	cSql += "  AND BT5_NUMCON=BM1.BM1_CONEMP "
	cSql += "  AND BT5_VERSAO=BM1.BM1_VERCON "
	cSql += "  AND BT5_INFANS = '1' "
	cSql += "  AND BT5.D_E_L_E_T_='' "

	// Tipo de Contrato
	cSql += "INNER JOIN "+RetSqlName("BII")+" BII "+ Iif( lMsSql, ' (NOLOCK) ', '' )
	cSql += "ON BII_FILIAL='"+xFilial('BII')+"' "
	cSql += "  AND BII_CODIGO=BT5.BT5_TIPCON "
	cSql += "  AND BII_TIPPLA IN ('2','3') "			// Deve considerar contratos tipo 2 (Col.Empresarial) e 3 (Col.Adesão)
	cSql += "  AND BII.D_E_L_E_T_ = '' "

	cSql += " WHERE E1_FILIAL  = '" + xFilial("SE1") + "' "
	//AB-|FB-|FC-|FU-|IR-|IN-|IS-|PI-|CF-|CS-|FE-|IV- //IR- //IN- //NCC //NDF //RA //PA
	cSql += "   AND E1_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MV_CRNEG+"|"+MV_CPNEG+"|"+MVPAGANT+"|"+MVRECANT ,"|")
	cSql += "   AND E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "
	cSql += "   AND SUBSTRING(E1_ORIGEM,1,3) = 'PLS' "
	cSql += "   AND SE1.E1_EMISSAO BETWEEN '" + dtoS(dDatDe) + "' AND '" + dtoS(dDatAte) + "'"
	cSql += "   AND SE1.D_E_L_E_T_ = ' ' "

	If !lCount
		cSql	+= " ORDER BY TIPO, BII_TIPPLA, BT5_AGR309, RecTit, RecEve "
	EndIf

	cSql	:= ChangeQuery(cSql)

	lFound := OpenQuery(cSql,cCabTab)
	If lCount .AND. lFound
		nCount := TRBAGR->TOTAL
		lFound := nCount > 0
	EndIf

Return lFound

/*/{Protheus.doc} OpenQuery
	Controla a abertura da query
	@type  Static Function
	@author everton.mateus
	@since 01/02/2019
	@version P12
	@param cSql, String, Query que será executada
	@return lFound, Boolean, .T. Encontrou dados e a área foi aberta, .F. não encontrou dados e a área foi fechada
/*/
Static Function OpenQuery(cSql,cCabTab)
	Local lFound := .F.

	If Select("TRBAGR") > 0
		TRBAGR->(DbCloseArea())
	EndIf
	PlsLogFil(CENDTHRL("I") + cCabTab +" Criando tabela temporária.",ARQ_LOG_CARGA)
	PlsLogFil(CENDTHRL("I") + cCabTab +" Query: " + cSql,ARQ_LOG_CARGA)
	dbUseArea(.T., 'TOPCONN', TCGenQry(, , cSql), "TRBAGR", .F., .T.)
	PlsLogFil(CENDTHRL("I") + cCabTab +"Fim da query. ",ARQ_LOG_CARGA)
	If TRBAGR->(Eof())
		TRBAGR->(DbCloseArea())
	Else
		lFound := .T.
	EndIf
Return lFound

Static Function LogaIgnorados(oHmRegistros,cCabTab,cMsg,cObs)
	Local nRegistro := 0
	Local nLen := 0
	Local aRegistros := {}

	Default cCabTab	:= ""
	Default cMsg	:= ""
	Default cObs	:= ""

	HMList(oHmRegistros,aRegistros)
	nLen := Len(aRegistros)
	For nRegistro := 1 to nLen
		PlsLogFil(CENDTHRL("W") + cCabTab + cMsg + aRegistros[nRegistro][1] + " Recno: " + aRegistros[nRegistro][2] + cObs ,ARQ_LOG_CARGA)
	Next nRegistro

Return