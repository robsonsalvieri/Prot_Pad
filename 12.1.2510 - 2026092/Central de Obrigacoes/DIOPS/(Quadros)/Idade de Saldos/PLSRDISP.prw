#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999.99"

STATIC oFnt09L := TFont():New("MS LineDraw Regular",08,08,,.F., , , , .T., .F.)
STATIC oFnt09T := TFont():New("MS LineDraw Regular",08,08,,.T., , , , .T., .F.)
STATIC oFnt11N := TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt09C := TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt10C := TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt10J := TFont():New("Arial",10,10,,.T., , , , .t., .f.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSDAGI<³ Autor ³Roger C 			    ³ Data ³18/01/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressão de Dados DIOPS Idade de Saldos Ativos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TOTVS - SIGAPLS			                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSRDISP(lTodosQuadros,lAuto)
//Local nOpca			:= 0
Local aSays			:= {}
Local aButtons		:= {}
Local cCadastro		:= "DIOPS - Idade de Saldos Ativo"
Local aResult		:= {}

DEFAULT lTodosQuadros	:= .F.

If !lTodosQuadros
	Private cPerg		:= "DIOPSINT"
	PRIVATE cTitulo 		:= cCadastro
	PRIVATE oReport     	:= nil
	PRIVATE cFileName		:= "DIOPS_Idade_de_Saldos_Ativos_"+CriaTrab(NIL,.F.)
	PRIVATE nPagina		:= 0		// Já declarada PRIVATE na chamada de todos os quadros
	If !lAuto
		Pergunte(cPerg,.F.)
	Endif	

	oReport := FWMSPrinter():New(cFileName,IMP_PDF,.F.,nil,.T.,nil,@oReport,nil,lAuto,.F.,.F.,!lAuto)
	oReport:setDevice(IMP_PDF)
	oReport:setResolution(72)
	oReport:SetLandscape()
	oReport:SetPaperSize(9)
	oReport:setMargin(10,10,10,10)

	If lAuto
		oReport:CFILENAME  := cFileName
		oReport:CFILEPRINT := oReport:CPATHPRINT + oReport:CFILENAME
	Else
		oReport:Setup()  //Tela de configurações
		If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return ()
		EndIf

	EndIf
		
Else
	nPagina	:= 0	// Já declarada PRIVATE na chamada de todos os quadros, necessário resetar a cada quadro
		
EndIf


Processa( {|| aResult := PLSDIDSA() }, "DIOPS - Idade de Saldos Ativo")

// Se não há dados a apresentar
If !aResult[1]
	If !lAuto
		MsgAlert('Não há dados a apresentar referente a Idade de Saldos Ativo')
	EndIf
	Return
EndIf 

cTitulo 	:= "Distribuição dos Saldos do Contas a Receber"
PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

lRet := PRI18IDSA(aResult[2]) //Recebe Resultado da Query e Monta Relatório para DIOPS 2018	

If !lTodosQuadros .and. lRet
	oReport:EndPage()
	oReport:Print()
EndIf
	

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRI18IDSA

@description Imprime Idade de Saldos Ativo para DIOPS 2018
@author Roger C
@since 22/03/18
@version P12
@return Logico - Imprimiu ou não.

/*/
//------------------------------------------------------------------

Static Function PRI18IDSA(aValores)

LOCAL lRet		:= .T.
Local nCtItemPg	:= 0 // Contador de Itens por Página
Local nItem		:= 0
Local nLin		:= 0
Local aSomaCols	:= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }	// Somatorio das Colunas de Valores em todos os Vencimentos
Local nI		:= 0
Local nJ		:= 0
Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro
Local nTotlin	:= 0
Local nSubTotlin:= 0
Local nTotPDD	:= 0

Local nCol01	:= 003
Local nCol02	:= 075
Local nCol03	:= 151      
Local nCol04	:= 227
Local nCol05	:= 310
Local nCol06	:= 379
Local nCol07	:= 455  
Local nCol08	:= 531    
Local nCol09	:= 607
Local nCol10	:= 683
Local nCol11	:= 760
Local nCol12	:= 759
Local nCol13	:= 834


oReport:box(100, 03, 365, nCol13 )  //Box principal
oReport:box(100, 03, 200, 75) //Box Vencimento Financeiro
oReport:Say(160, 20, "Vencimento", oFnt10c)  //"Vencimento"
oReport:Say(175, 20, "Financeiro", oFnt10c)	 //"Financeiro"

oReport:Line(120, 725, 120, 075)	
oReport:Say(115, nCol04+75, "Créditos de Operações com Planos de Saúde - (Subgrupo 123)", oFnt10c) //"Créditos de Operações com Planos de Saúde - (Subgrupo 123)"

oReport:Line(135, 400, 135, 075)	
oReport:Say(130, nCol02+65, "Contraprestação Pecuniária/Prêmios a Receber"	, oFnt10c)  //"Contraprestação Pecuniária/Prêmios a Receber"	
oReport:Say(145, nCol02+70, "Mensalidades/Faturas/Seguros a Receber"	, oFnt10c)  //"Mensalidades/Faturas/Seguros a Receber"	

oReport:box(150, nCol02, 175 , nCol04)   //144
oReport:Say(160, nCol02+23, "Planos Individuais/Familiares", oFnt10c)	//"Planos Individuais/Familiares"
oReport:Say(170, nCol02+23, "Mensalidades (Pessoa Física)", oFnt10c)	//"Mensalidades (Pess. Física)"

oReport:box(150, nCol04, 175, nCol06) 
oReport:Say(160, nCol04+23, "    Planos Coletivos     ", oFnt10c) //"Planos Coletivos"	
oReport:Say(170, nCol04+23, "Faturas (Pessoa Jurídica)"	, oFnt10c)  //"Faturas (Pessoa Jurídica)"		
 //--------------------------------                     
oReport:box(175, nCol02, 200, nCol03) 
oReport:Say(185, nCol02+10, "      Preço     ", oFnt10c)  //"Preço"
oReport:Say(195, nCol02+10, "Pré-Estabelecido", oFnt10c)  //"Pré-Estabelecido"	

oReport:box(175, nCol03, 200, nCol04)
oReport:Say(185, nCol03+10, "      Preço     " , oFnt10c)	//"Preço" 
oReport:Say(195, nCol03+5, "Pós-Estabelecido", oFnt10c)	//"Pós-Estabelecido"

oReport:box(175, nCol04, 200, nCol05-7) 
oReport:Say(185, nCol04+10, "      Preço     ", oFnt10c)  //"Preço"
oReport:Say(195, nCol04+10, "Pré-Estabelecido"	, oFnt10c)  //"Pré-Estabelecido"	

oReport:box(175, nCol05-7, 200, nCol06 + 2) 
oReport:Say(185, nCol05+5, "     Preço      ", oFnt10c)  //"Preço"
oReport:Say(195, nCol05, "Pós-Estabelecido", oFnt10c)  //"Pós-Estabelecido"

//Box Linha dos vencimentos
oReport:box(200, nCol01, 215, nCol13)
oReport:Fillrect( {201, nCol01+1, 216, nCol13-1 }, oBrush1)		

nSom := 0

For nI := 1 To 6 //Seis linhas de vencimentos e subtotal
	oReport:box(215 + nSom, nCol01, 240 + nSom, nCol13)
	nSom += 25
Next

oReport:Say(230, nCol01+3, " A vencer  ", oFnt10J) //"A vencer"
oReport:Say(253, nCol01+3, "Vencidos de", oFnt10J) //"Vencidos de 1 a 30 dias"	
oReport:Say(263, nCol01+3, "1 a 30 dias", oFnt10J) //"Vencidos de 1 a 30 dias"	
oReport:Say(278, nCol01+3, "Vencidos de ", oFnt10J) //"Vencidos de 31 a 60 dias"
oReport:Say(288, nCol01+3, "31 a 60 dias", oFnt10J) //"Vencidos de 31 a 60 dias"
oReport:Say(303, nCol01+3, "Vencidos de ", oFnt10J)  //"Vencidos de 61 a 90 dias"
oReport:Say(313, nCol01+3, "61 a 90 dias", oFnt10J)  //"Vencidos de 61 a 90 dias"
oReport:Say(328, nCol01+3, "Vencidos a mais", oFnt10J)	 //"Vencidos a mais de 90 dias"
oReport:Say(338, nCol01+3, "  de 90 dias   ", oFnt10J)	 //"Vencidos a mais de 90 dias"
oReport:Say(355, 23, "SubTotal", oFnt10J)  //SubTotal

//Box Créditos a Receber de Administradoras de Benefícios
oReport:box(120, nCol06, 200, nCOl07)   
oReport:Say(155, nCol06+5, "Crédito Receber", oFnt10c)	//"Créditos Receber"
oReport:Say(165, nCol06+5, "Administradoras", oFnt10c)	//"Administradoras"
oReport:Say(175, nCol06+5, " de Benefícios", oFnt10c)     //"de Benefícios" 	

//Box Participação dos Beneficiários em Eventos/ Sinistros
oReport:box(120, nCol07, 200, nCol08)   
oReport:Say(155, nCol07+3, "  Participação    ", oFnt10c)	  //"Participação"
oReport:Say(165, nCol07+3, "dos Beneficiários ", oFnt10c)	//"dos Beneficiários"	
oReport:Say(175, nCol07+3, "Eventos/ Sinistros", oFnt10c)	//"Eventos/ Sinistros"

//Box Créditos de Operadoras
oReport:box(120, nCol08, 200, nCol10)   
oReport:Say(155, nCol08+35, "Créditos de Operadoras", oFnt10c)		//"Créditos de Operadoras"
//oReport:Say(145, 546, "Operadoras", oFnt10c)		//"Operadoras"	
                      
oReport:box(175, nCol08, 200, nCol09) 
oReport:Say(185, nCol08+8, "     Preço      ", oFnt10c)  //"Preço"
oReport:Say(195, nCol08+5, "Pré-Estabelecido", oFnt09c)  //"Pré-Estabelecido"	

oReport:box(175, nCol09, 200, nCol10)
oReport:Say(185, nCol09+8, "     Preço      " , oFnt10c)	//"Preço" 
oReport:Say(195, nCol09+5, "Pós-Estabelecido", oFnt09c)	//"Pós-Estabelecido"

//Box Outros Créditos de Operações com Planos
oReport:box(120, nCol10, 200, nCol11)   
oReport:Say(155, nCol10+5, "Outros Créditos", oFnt10c)	//"Outros Créditos"
oReport:Say(165, nCol10+5, " de Operações  ", oFnt10c)	//"de Operações"
oReport:Say(175, nCol10+5, "  com Planos   ", oFnt10c)	//"com Planos"

//Box Outros Créditos Não Relacionados com Planos  (Subgrupo 124)
oReport:box(120, nCol12, 200, nCol13)   
oReport:Say(155, nCol12+5, "Outros Créditos", oFnt10c)	//"Outros Créditos"		
oReport:Say(165, nCol12+5, "Não Relacionado", oFnt10c)	//"Não Relacionados"
oReport:Say(175, nCol12+5, "   com Planos  ", oFnt10c)	//"com Planos"
//
//Box PPSC
oReport:box(380, nCol01, 405, nCol13 )  //Box principal
oReport:Say(393, 30, "PPSC", oFnt11N)	//PPSC
	
oReport:box(405, nCol01, 415, nCol13)	
oReport:Fillrect( {406, nCOl01+1, 414, nCol13-1 }, oBrush1)	

oReport:box(415, nCol01, 440, nCOl13)		
oReport:Say(433, 30, "SALDO", oFnt11N)  //"SALDO"

//Line das colunas relatório
nCol := 75  
For nI := 2 to 11
	
	If nI > 2
		nCol+= 76
	EndIf
	oReport:Line(200, nCol, 365, nCol)
	oReport:Line(380, nCol, 440, nCol) //BOX PPSC
Next

//****************************
//Impressão dos Valores
//****************************
//***********COLUNAS de 1 a 9 e 11	

nCol	:= 64
For nI := 1 To 10 

	// A primeira coluna do array aValores identifica o vencimento, então o contador está sempre valendo um a menos da coluna que precisamos imprimir
	// Quando o contador nI chegar em 10 pulará para a coluna 12, porque a coluna 11 é a totalizadora de linha
	nLin	:= 230
	If nI == 2
		nCol:=139
	ElseIf nI == 3
		nCol:=214
	ElseIf nI == 4
		nCol:=290
	ElseIf nI == 5
		nCol:=365
	ElseIf nI == 6
		nCol:=444
	ElseIf nI == 7
		nCol:=519
	ElseIf nI == 8
		nCol:=594
	ElseIf nI == 9
		nCol:=671
	ElseIf nI == 10
		nCol:=745
	EndIf	

	For nJ := 1 To 6  //6 linhas para preenchimento, sendo que a 6 linha é a soma das 5 anteriores
		
		If nJ == 6		// Linha de totalização			
			oReport:Say(nLin, nCol, PADL(Transform(aSomaCols[nI], Moeda),20), oFnt09T)  		

		Else
			oReport:Say(nLin, nCol, PADL(Transform(aValores[nJ, nI+1], Moeda),20), oFnt09L)
			aSomaCols[nI] += aValores[nJ, nI+1]  
		EndIf
		nLin += 25
		
	Next
	
Next		 

nCol	:= 64

//Preenchimento do PPSC - é a sexta linha do array aValores
For nI := 1 To 10
	// A primeira coluna do array aValores identifica o vencimento, então o contador está sempre valendo um a menos da coluna que precisamos imprimir
	// Quando o contador nI chegar em 10 pulará para a coluna 12, porque a coluna 11 é a totalizadora de linha
	
	If nI == 2
		nCol:=139
	ElseIf nI == 3
		nCol:=214
	ElseIf nI == 4
		nCol:=290
	ElseIf nI == 5
		nCol:=365
	ElseIf nI == 6
		nCol:=444
	ElseIf nI == 7
		nCol:=519
	ElseIf nI == 8
		nCol:=594
	ElseIf nI == 9
		nCol:=671
	ElseIf nI == 10
		nCol:=745
	EndIf	

	oReport:Say(393, nCol, PADL(Transform(aValores[6, nI+1], Moeda),20), oFnt09L)  
	
	// Imprimir Linha do Saldo
	// Soma a coluna de PPSC porque o valor da conta PPSC é negativo
	nSaldo := aSomaCols[nI] + aValores[6, nI+1]
	oReport:Say(433, nCol, PADL(Transform(nSaldo, Moeda),20), oFnt09T)  

//	nCol	:= &('nCol'+StrZero(nI+1, 2))
//	Iif ((nI == 10), oReport:Say(433, nCol, PADL(Transform((nSubTotlin), Moeda),20), oFnt09T), '')
Next

Return lRet

Static Function PLSDIDSA()
Local nCount	:= 0
Local aRetIDSA	:= 	{}						
Local cSql 		:= ""
Local lRet 		:= .T.

aRetIDSA	:= 	{	{'000', 0,0,0,0,0,0,0,0,0,0,0 },;		
					{'030', 0,0,0,0,0,0,0,0,0,0,0 },;
					{'060', 0,0,0,0,0,0,0,0,0,0,0 },;
					{'090', 0,0,0,0,0,0,0,0,0,0,0 },;
					{'099', 0,0,0,0,0,0,0,0,0,0,0 },;
					{'400', 0,0,0,0,0,0,0,0,0,0,0 } }	
cSql := " SELECT B8G_VENCTO, B8G_INDPRE, B8G_INDPOS, B8G_COLPRE, B8G_COLPOS, B8G_CREADM, B8G_PARBEN, B8G_OUCROP, B8G_CROPPO, B8G_OUCRPL, B8G_OUTCRE "


cSql += " FROM " + RetSqlName("B8G")
cSql += " WHERE B8G_FILIAL = '" + xFilial("B8G") + "' " 
cSql += " AND B8G_CODOPE = '" + B3D->B3D_CODOPE + "' "
cSql += " AND B8G_CODOBR = '" + B3D->B3D_CDOBRI + "' "
cSql += " AND B8G_ANOCMP = '" + B3D->B3D_ANO + "' "
cSql += " AND B8G_CDCOMP = '" + B3D->B3D_CODIGO + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
cSql += " ORDER BY B8G_VENCTO " 	
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBISP",.F.,.T.)
TcSetField("TRBISP", "B8G_INDPRE",  "N", 16, 2 )
TcSetField("TRBISP", "B8G_INDPOS",  "N", 16, 2 )
TcSetField("TRBISP", "B8G_COLPRE",  "N", 16, 2 )
TcSetField("TRBISP", "B8G_COLPOS",  "N", 16, 2 )
TcSetField("TRBISP", "B8G_CREADM",  "N", 16, 2 )
TcSetField("TRBISP", "B8G_PARBEN",  "N", 16, 2 )
TcSetField("TRBISP", "B8G_OUCROP",  "N", 16, 2 )
TcSetField("TRBISP", "B8G_OUCRPL",  "N", 16, 2 )
TcSetField("TRBISP", "B8G_OUTCRE",  "N", 16, 2 )
TcSetField("TRBISP", "B8G_CROPPO",  "N", 16, 2 )


If !TRBISP->(Eof())
	Do While !TRBISP->(Eof())
		nCount++
		nLinha	:= 0		// Linha do array em que se encaixa o registro
		Do Case
			Case TRBISP->B8G_VENCTO = '000'
				nLinha := 1
			Case TRBISP->B8G_VENCTO = '030'
				nLinha := 2
			Case TRBISP->B8G_VENCTO = '060'
				nLinha := 3
			Case TRBISP->B8G_VENCTO = '090'
				nLinha := 4
			Case TRBISP->B8G_VENCTO = '099'
				nLinha := 5
			OtherWise	// Case TRBISP->B8G_VENCTO = '400'
				nLinha := 6
		EndCase
		If nLinha > 0
			aRetIDSA[nLinha,2] := TRBISP->B8G_INDPRE
			aRetIDSA[nLinha,3] := TRBISP->B8G_INDPOS
			aRetIDSA[nLinha,4] := TRBISP->B8G_COLPRE
			aRetIDSA[nLinha,5] := TRBISP->B8G_COLPOS
			aRetIDSA[nLinha,6] := TRBISP->B8G_CREADM
			aRetIDSA[nLinha,7] := TRBISP->B8G_PARBEN
			aRetIDSA[nLinha,8] := TRBISP->B8G_OUCROP
			aRetIDSA[nLinha,9] := TRBISP->B8G_CROPPO
			aRetIDSA[nLinha,10]:= TRBISP->B8G_OUCRPL
			aRetIDSA[nLinha,11]:= TRBISP->B8G_OUTCRE  			

			TRBISP->(DbSkip())		
		Else
			TRBISP->(DbSkip())	
		Endif
	EndDo
EndIf
TRBISP->(DbCloseArea())
	
Return( { nCount>0 , aRetIDSA } )


