#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "JURR099.CH"

#DEFINE IMP_PDF   6
#DEFINE IMP_SPOOL 2
#DEFINE nColIni   50   // Coluna inicial
#DEFINE nColFim   2350 // Coluna final
#DEFINE nSalto    40   // Salto de uma linha a outra
#DEFINE nFimL     3000 // Linha Final da página de um relatório
#DEFINE nTamCarac 20.5 // Tamanho de um caractere no relatório

//-------------------------------------------------------------------
/*/{Protheus.doc} JURR099()
Regras do relatório de Despesas

@param cCodJur Código do Processo que terá os andamentos impressos
                 no relatório
       cFilpro Filial
	   lAutomato Indica se vem de automação ou app totvs Juridico
	   cNomeRel  Quando vem de automação é enviado também o nome
	   cCaminho  Quando vem de automação é enviado também o caminho

@Return Nil

@author Jorge Luis Branco Martins Junior
@since 11/01/16
@version 1.0

/*/
//-------------------------------------------------------------------
Function JURR099(cCodJur, cFilpro, lAutomato, cNomeRel, cCaminho)
Local oFont      := TFont():New("Arial",,-20,,.T.,,,,.T.,.F.) // Fonte usada no nome do relatório
Local oFontDesc  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.)   // Fonte usada nos textos
Local oFontTit   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos títulos do relatório (Título de campos e títulos no cabeçalho)
Local oFontSub   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos títulos das sessões
Local cQuery     := ""
Local cData      := ""
Local cSimbolo   := ""
Local cValor     := ""
Local cDesc      := ""
Local cDespesa   := ""
Local aRelat     := {}
Local aCabec     := {}
Local aSessao    := {}

Default lAutomato := .F.
Default cCaminho  := ""

cTpAssJur := JurGetDados("NSZ",1,xFilial("NSZ")+cCodJur, "NSZ_TIPOAS")

cData := JurGetDados('NUZ', 1, xFilial('NUZ') + cTpAssJur + "NT3_DATA  " + Replicate(" ",10-len("NT3_DATA")), 'NUZ_DESCPO')
If Empty(AllTrim(cData))
	cData := JURX3INFO("NT3_DATA","X3_TITULO")
EndIf

cSimbolo := JurGetDados('NUZ', 1, xFilial('NUZ') + cTpAssJur + "NT3_DMOEDA" + Replicate(" ",10-len("NT3_DMOEDA")), 'NUZ_DESCPO')
If Empty(AllTrim(cSimbolo))
	cSimbolo := JURX3INFO("NT3_DMOEDA","X3_TITULO")
EndIf

cValor := JurGetDados('NUZ', 1, xFilial('NUZ') + cTpAssJur + "NT3_VALOR " + Replicate(" ",10-len("NT3_VALOR ")), 'NUZ_DESCPO')
If Empty(AllTrim(cValor))
	cValor := JURX3INFO("NT3_VALOR ","X3_TITULO")
EndIf

cDesc := JurGetDados('NUZ', 1, xFilial('NUZ') + cTpAssJur + "NT3_DESC" + Replicate(" ",10-len("NT3_DESC")), 'NUZ_DESCPO')
If Empty(AllTrim(cDesc))
	cDesc := JURX3INFO("NT3_DESC","X3_TITULO")
EndIf

cDespesa := JURX3INFO("NT3_DTPDES","X3_TITULO")

//Título do Relatório
  // 1 - Título,
  // 2 - Posição da descrição,
  // 3 - Fonte do título
  // 4 - Orientação("R" = Retrato, "P"=Paisagem)
aRelat := {STR0001,800,oFont,"R"} //"Relatório de Despesas"

//Cabeçalho do Relatório
// 1 - Título, 
  // 2 - Conteúdo, 
  // 3 - Posição de início da descrição(considere 20,5 para cada caractere do título, ou seja se o título tiver 6 caracteres indique 6x20,5 = 123. 
  //     Indique esse número para todos os itens do cabeçalho, para que todos tenham o mesmo alinhamento. 
  //     Para isso considere sempre a posição da maior descrição),
  // 4 - Fonte do título, 
  // 5 - Fonte da descrição

aCabec := {{STR0002/*"Impressão"*/   ,DToC(Date())                                                ,(nTamCarac*12),oFontTit,oFontDesc},;
           {STR0003/*"Núm Processo"*/,JurGetDados("NUQ",2,xFilial("NUQ")+cCodJur+"1","NUQ_NUMPRO"),(nTamCarac*12),oFontTit,oFontDesc},;
           {STR0004/*"Envolvidos"*/  ,JA099Envolv(cCodJur)                                        ,(nTamCarac*12),oFontTit,oFontDesc}}

cQuery := JA099QryRel(cCodJur,1, cFilpro)

//Campos do Relatório
  //Exemplo da primeira parte -> aAdd(aSessao, {"Andamentos",65,oFontSub,.F.,;// 
  // 1 - Título da sessão do relatório,
  // 2 - Posição de início da descrição, 
  // 3 - Fonte no quadro com título da sessão,
  // 4 - Impressão na horizontal? -> Título e descrição na mesma linha (Ex: Data: 01/01/2016)
  // 5 - Query do subreport - Se for parte do relatório principal não precisa ser indicado
    // Arrays a partir da 6ª posição
      // 1 - Título do campo,
      // 2 - Tabela do campo,
      // 3 - Nome do campo no dicionário,
      // 4 - Nome do Campo na Query,
      // 5 - Tipo do Campo,
      // 6 - Indica a coordenada horizontal em pixels ou caracteres, 
      // 7 - Tamanho que o conteúdo pode ocupar,
      // 8 - Fonte do título, 
      // 9 - Fonte da descrição
      // 10 - Posição de início da descrição
      // 11 - Quebra Linha após impressão do conteúdo?
aAdd(aSessao, {"",65,oFontSub,.F.,,;
	              	{cData /*Data*/      		,"NT3","NT3_DATA"	,"NT3_DATA"	,"D",65  , 1000 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
	              	{cDespesa /*Despesa*/		,"NSR","NSR_DESC"  	,"NSR_DESC" ,"C",500 , 1500 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
	                {""/*Simbolo Moeda*/ 	,"NT3","NT3_CMOEDA" ,"CTO_SIMB" ,"C",2000 , 1500	,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
	                {cValor /*Valor*/			,"NT3","NT3_VALOR"  ,"NT3_VALOR","N",2100, 1500 ,oFontTit,oFontDesc,(nTamCarac*5),.T.},;
	                {cDesc /*Descrição*/      	,"NT3","NT3_DESC"  	,"RECNONT3" ,"M",65  , 3200 ,oFontTit,oFontDesc,(nTamCarac*12),.T.}})
nSessao := Len(aSessao)
	                
aAdd(aSessao, {"Totaldesp",65,oFontSub,.T.,JA099QryRel(cCodJur,2, cFilpro),.T.})
				nSessao := Len(aSessao)
				aAdd(aSessao[nSessao],{STR0005/*"Total"*/,"NT3","NT3_VALOR","TOTAL","N",2000,1500,oFontTit,oFontTit,(nTamCarac*5),.T.})

JRelatorio(aRelat, aCabec, aSessao, cQuery, lAutomato, cNomeRel, cCaminho) //Chamada da função de impressão do relatório em TMSPrinter

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA099Envolv()
Imprime cabeçalho do relatório de Andamentos
 
Uso Geral.

@param cAssJur Código do Processo que terá os andamentos impressos
                 no relatório

@Return cEnv   Nome dos envolvidos separados por hifen

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA099Envolv(cAssJur)
Local cEnv := ""
Local cAtivo := JurGetDados("NT9",3,xFilial("NT9")+cAssJur+"11","NT9_NOME")   // Polo Ativo Principal
Local cPassivo := JurGetDados("NT9",3,xFilial("NT9")+cAssJur+"21","NT9_NOME") // Polo Passívo Principal

cEnv := Alltrim(cAtivo)

If !Empty(AllTrim(JurGetDados("NT9",3,xFilial("NT9")+cAssJur+"21","NT9_NOME")))
	cEnv += " / " + Alltrim(cPassivo)
EndIf

Return cEnv

//-------------------------------------------------------------------
/*/{Protheus.doc} JA099QryRel()
Retorna dados que serão impressos no relatório
 
Uso Geral.

@param cAssJur Código do Processo que terá os andamentos impressos
                 no relatório
        aFiltro Filtro usado na pesquisa de andamentos 

@Return aDados Array contendo as informações dos andamentos

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA099QryRel(cAssJur, nTipo, cFilpro)
	Local aArea      := GetArea()
	Local cQrySelect := ""
	Local cQryWhere  := ""
	Local cQueryFrom := ""

If nTipo == 1	
	cQrySelect += " SELECT NSR.NSR_DESC NSR_DESC, "
	cQrySelect += 		 " NT3.NT3_DATA,"
	cQrySelect +=        " NT3.R_E_C_N_O_ RECNONT3,"
	cQrySelect +=        " CTO.CTO_SIMB,"	
	cQrySelect +=        " NT3.NT3_VALOR,"
	cQrySelect +=        " NT3.NT3_DESC "
	cQueryFrom += " FROM " + RetSqlName("NT3") + " NT3 "
	cQueryFrom +=  " LEFT OUTER JOIN " + RetSqlName("NSR") + " NSR ON ( " 
	cQueryFrom +=            " NT3.D_E_L_E_T_ = NSR.D_E_L_E_T_ AND " 
	cQueryFrom +=            " NT3.NT3_CTPDES = NSR.NSR_COD AND " 
	cQueryFrom +=            " NSR.NSR_FILIAL = '"+xFilial("NSR")+"') "
	cQueryFrom +=        " INNER JOIN "  + RetSqlName("NSZ") + " NSZ "
	cQueryFrom +=                " ON ( NT3.NT3_CAJURI = NSZ.NSZ_COD "
	cQueryFrom +=                     " AND NT3.D_E_L_E_T_ = NSZ.D_E_L_E_T_) "
	cQueryFrom +=                     " AND NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	cQueryFrom +=        " INNER JOIN "  + RetSqlName("CTO") + " CTO"
	cQueryFrom +=                " ON ( NT3.NT3_CMOEDA = CTO.CTO_MOEDA"
	cQueryFrom +=                     " AND CTO.CTO_FILIAL = '"+xFilial("CTO")+"') " 	
	cQryWhere  += " WHERE NT3_FILIAL = '"+cFilpro+"' "
	cQryWhere  +=       " AND NT3.D_E_L_E_T_ = ' ' "
	cQryWhere  +=       " AND NT3_CAJURI = '"+cAssJur+"' "
	cQryWhere  += " ORDER BY NT3.NT3_DATA DESC, NT3.NT3_COD DESC"
Else // Total
	cQrySelect += " SELECT SUM(NT3.NT3_VALOR) TOTAL"
	cQueryFrom += " FROM " + RetSqlName("NT3") + " NT3 "
	cQueryFrom +=  " LEFT OUTER JOIN " + RetSqlName("NSR") + " NSR ON ( " 
	cQueryFrom +=            " NT3.D_E_L_E_T_ = NSR.D_E_L_E_T_ AND " 
	cQueryFrom +=            " NT3.NT3_CTPDES = NSR.NSR_COD AND " 
	cQueryFrom +=            " NSR.NSR_FILIAL = '"+xFilial("NSR")+"') "
	cQueryFrom +=        " INNER JOIN "  + RetSqlName("NSZ") + " NSZ "
	cQueryFrom +=                " ON ( NT3.NT3_CAJURI = NSZ.NSZ_COD "
	cQueryFrom +=                     " AND NT3.D_E_L_E_T_ = NSZ.D_E_L_E_T_) "
	cQueryFrom +=                     " AND NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	cQueryFrom +=        " INNER JOIN "  + RetSqlName("CTO") + " CTO"
	cQueryFrom +=                " ON ( NT3.NT3_CMOEDA = CTO.CTO_MOEDA"
	cQueryFrom +=                     " AND CTO.CTO_FILIAL = '"+xFilial("CTO")+"') " 	
	cQryWhere  += " WHERE NT3_FILIAL = '"+cFilpro+"' "
	cQryWhere  +=       " AND NT3.D_E_L_E_T_ = ' ' "
	cQryWhere  +=       " AND NT3_CAJURI = '"+cAssJur+"' "
EndIf
	RestArea( aArea )

Return cQrySelect + cQueryFrom + cQryWhere

//-------------------------------------------------------------------
/*/{Protheus.doc} JRelatorio()
Impressão de Relatórios SIGAJURI
Ferramenta TMSPrinter 
Uso Geral.

@param aRelat  Dados do título do relatório
       aCabec  Dados do cabeçalho do relatório
       aSessao Dados do conteúdo do relatório
	   cQuery  Query que será executada
	   lAutomato Indica se vem de automação ou app totvs Juridico
	   cNomeRel  Quando vem de automação é enviado também o nome
	   cCaminho  Quando vem de automação é enviado também o caminho

@Return

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRelatorio(aRelat, aCabec, aSessao, cQuery, lAutomato, cNomeRel, cCaminho)

Local lHori     := .F.
Local lQuebPag  := .F.
Local lTitulo   := .T. 
Local lLinTit   := .F.
Local nI        := 0    // Contador
Local nJ        := 0    // Contador
Local nLin      := 0    // Linha Corrente
Local nLinCalc  := 0    // Contator de linhas - usada para os cálculos de novas linhas
Local nLinCalc2 := 0
Local nLinFinal := 0
Local oPrint    := Nil
Local aDados    := {}
Local TMP       := GetNextAlias()

Default cNomerel  := AllTrim(aRelat[1]) //Nome do Relatório


If !lAutomato
	oPrint := FWMsPrinter():New( cNomeRel, IMP_PDF,,, .T.,,, "PDF" ) // Inicia o relatório
Else
	oPrint := FWMsPrinter():New( cNomeRel, IMP_SPOOL,,, .T.,,,) // Inicia o relatório
	//Altera o nome do arquivo de impressão para o padrão de impressão automatica
	oPrint:CFILENAME  := cNomeRel
	oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),TMP,.T.,.T.)

If (TMP)->(!EOF())

	ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Imprime cabeçalho
	nLinCalc := nLin // Inicia o controle das linhas impressas

	While (TMP)->(!EOF())

		If nLin >= nFimL // Verifica se a linha corrente é maior que linha final permitida por página
			oPrint:EndPage() // Se for maior, encerra a página atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabeçalho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lTitulo := .T. // Indica que o título pode ser impresso 
			lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
		EndIf

		For nI := 1 To Len(aSessao) // Inicia a impressão de cada sessão do relatório
			
			lHori := aSessao[nI][4]
			
			If Empty(aSessao[nI][5]) // Nessa posição é indicada a query de um subreport
			
				nLinCalc2 := nLinCalc // Backup da próxima linha a ser usada, pois na função JDadosCpo abaixo a variavel tem seu conteúdo alterado para
		                      // que seja realizada uma simulação das linhas usadas para impressão do conteúdo. 

				nLinFinal := 0 // Limpa a variável

				For nJ := 6 to Len(aSessao[nI]) // Lê as informações de cada campo a ser impresso. O contador começa em 6 pois é a partir dessa posição que estão as informações sobre o campo
					cTabela  := aSessao[nI][nJ][2] //Tabela
					cCpoTab  := aSessao[nI][nJ][3] //Nome do campo na tabela
					cCpoQry  := aSessao[nI][nJ][4] //Nome do campo na query
					cTipo    := aSessao[nI][nJ][5] //Tipo do campo
					cValor := JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,,.F.) // Retorna o conteúdo/valor a ser impresso. Chama essa função para tratar o valor caso seja um memo ou data
					
					aAdd(aDados,JDadosCpo(aSessao[nI][nJ],cValor,@nLinCalc,@lQuebPag)) // Título e conteúdo de cada campo são inseridos do array com os dados para serem impressos abaixo
				Next 
	
				nLinCalc := nLinCalc2 // Retorno do valor original da variável
	
				If lQuebPag // Verifica se é necessário ocorrer a quebra de pagina
					oPrint:EndPage() // Se é necessário, encerra a página atual
					ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabeçalho
					nLinCalc := nLin // Inicia o controle das linhas impressas
					lQuebPag := .F. // Limpa a variável de quebra de página
					lTitulo  := .T. // Indica que o título pode ser impresso 
					lLinTit  := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
				EndIf
				
				If nI > 1 // Inclui uma linha em branco no final de cada sessão do relatório principal, desde que não seja a primeira sessão 
					nLin += nSalto
				EndIf		
				
				If !lHori // Caso a impressão dos títulos seja na vertical - Todos os títulos na mesma linha e os conteúdos vem em colunas abaixo dos títulos (Ex: Relatório de andamentos)
					// Os títulos devem ser impressos
					lTitulo := .T. // Indica que o título pode ser impresso 
					lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
				EndIf
				
				//Imprime os campos do relatório
				JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec)
				
				//Limpa array de dados
				aSize(aDados,0)
				aDados := {}
	
				nLinCalc := nLinFinal //Indica a maior refência de uso de linhas para que sirva como referência para começar a impressão do próximo registro
				
				nLinFinal := 0 // Limpa a variável
				
				nLin := nLinCalc+nSalto //Recalcula a linha de referência para impressão
			
				nLinCalc := nLin //Indica a linha de referência para impressão
			EndIf
		Next

		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório
		
		nLin += nSalto //Adiciona uma linha em branco após a linha impressa
		nLinCalc := nLin
		
		(TMP)->(DbSkip())
	End

	For nI := 1 To Len(aSessao) // Inicia a impressão de cada sessão do relatório
		
		lHori := aSessao[nI][4]
		
		If !Empty(aSessao[nI][5]) // Nessa posição é indicada a query de um subreport
			JImpSub(aSessao[nI][5], TMP, aSessao[nI],@nLinCalc,@lQuebPag, aRelat, aCabec, @oPrint, @nLin, @lTitulo, @lLinTit) // Imprime os dados do subreport
		Endif
	Next
	
	oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório
	
	(TMP)->(dbCloseArea())
	
	aSize(aDados,0)  //Limpa array de dados
	aSize(aRelat,0)  //Limpa array de dados do relatório
	aSize(aCabec,0)  //Limpa array de dados do cabeçalho do relatório
	aSize(aSessao,0) //Limpa array de dados das sessões do relatório
	
	oPrint:EndPage() // Finaliza a página
	
	If !lAutomato
		If Empty(cCaminho)
			oPrint:CFILENAME  := Replace(AllTrim(cNomeRel),'.','') + '-' + SubStr(AllTrim(Str(ThreadId())),1,4) + RetCodUsr() + StrTran(Time(),':','') + '.rel'
			oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
		Else
			oPrint:CFILENAME  := cNomeRel
			oPrint:CFILEPRINT := cCaminho + cNomeRel
		EndIf
	Endif
	
	oPrint:Print()
	
	If !lAutomato .And. Empty(cCaminho)
		FErase(oPrint:CFILEPRINT)
	Endif

EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCabec()
Imprime cabeçalho do relatório
 
Uso Geral.

@param oPrint  Objeto do Relatório
        nColIni Coluna inicial
        nColFim Coluna final
        nSalto  Salto de uma linha a outra
        nLin    Linha Corrente
        aRelat  Dados do título do relatório
        aCabec  Dados do cabeçalho do relatório
        aSessao Dados do conteúdo do relatório

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImpCabec(oPrint, nLin, aRelat, aCabec)
Local cTit       := aRelat[1] // Título
Local nColTit    := aRelat[2] // Posição da Título
Local oFontTit   := aRelat[3] // Fonte do Título
Local cTitulo    := ""
Local cValor     := ""
Local nPosValor  := 0
Local nSaltoCabe := 40
Local nI         := 0
Local oFontValor
Local oFontRoda  := TFont():New("Arial",,-8,,.F.,,,,.T.,.F.) // Fonte usada no Rodapé

If aRelat[4] == "R"
	oPrint:SetPortrait()  // Define a orientação do relatório como retrato (Portrait).
Else
	oPrint:SetLandscape() // Define a orientação do relatório como paisagem (Landscape).
EndIf

oPrint:SetPaperSize(9) //A4 - 210 x 297 mm

// Inicia a impressao da pagina
oPrint:StartPage()
oPrint:Say( nFimL, nColFim - 100, alltochar(oPrint:NPAGECOUNT), oFontRoda )
oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relatório
oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relatório
nLin := 90

// Imprime o cabecalho
oPrint:Say( nLin, nColTit, cTit, oFontTit )

nLin += 2*nSaltoCabe // Espaço para que o cabeçalho fique um pouco abaixo do Título do Relatório 

If Len(aCabec) > 0
	For nI := 1 to Len(aCabec)
		cTitulo    := aCabec[nI][1] // Título
		cValor     := aCabec[nI][2] // Conteúdo
		nPosValor  := aCabec[nI][3] // Posição do conteúdo (considere 20,5 para cada caractere do título, ou seja se o título tiver 6 caracteres indique 6x20,5 = 123. Indique esse número para todos os itens do cabeçalho, para que todos tenham o mesmo alinhamento. Para isso considere sempre a posição da maior descrição)
		oFontTit   := aCabec[nI][4] // Fonte do título
		oFontValor := aCabec[nI][5] // Fonte do conteúdo
		oPrint:Say( nLin += nSaltoCabe, 070                        , cTitulo + ":" , oFontTit   ) //Imprime o Título
		oPrint:Say( nLin              , nPosValor + (nTamCarac * 4), cValor        , oFontValor ) //Imprime o Conteúdo - Esse (nTamCarac * 4) é para dar um espaço de 4 caracteres a mais do que o tamanho da descrição
	Next
EndIf

//nLin+=2*nSaltoCabe // Inclui duas linhas em branco após a impressão do cabeçalho
nLin+=20
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relatório

nLin+=40 //Recalcula a linha de referência para impressão

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrataVal()
Trata os tipos de campos e imprime os valores
 
Uso Geral.

@param cTabela  Nome da tabela
        cCpoTab  Nome do campo na tabela
        cCpoQry  Nome do campo na query
        cTipo    Tipo do campo
        TMP      Alias aberto

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 15/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Local cValor  	:= ""
Local lPicture	:=.F.
Local cPicture	:= ""

If lSub
	If cTipo == "D" // Tipo do campo
		TCSetField(SUB, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((SUB)->&(cCpoQry))) //Conteúdo a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((SUB)->&(cCpoQry))) // Esse seek é para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
		ElseIf cTipo == "N" // Tipo do campo
		TcSetField( SUB, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
		cPicture := JURX3INFO(cCpoTab,"X3_PICTURE")
		lPicture := Iif(Empty(cPicture),.F.,.T.)
		If lPicture
			cValor   := TRANSFORM((SUB)->&(cCpoQry), cPicture)
			cValor   := AllTrim(CVALTOCHAR(cValor)) //Conteúdo a ser gravado
		Else
			cValor := AllTrim(CVALTOCHAR((SUB)->&(cCpoQry)))
		EndIf
	Else
		cValor := AllTrim(AllToChar((SUB)->&(cCpoQry)))
	EndIf
Else 
	If cTipo == "D" // Tipo do campo
		TCSetField(TMP, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((TMP)->&(cCpoQry))) //Conteúdo a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((TMP)->&(cCpoQry))) // Esse seek é para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
	ElseIf cTipo == "N" // Tipo do campo
		TcSetField( TMP, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
		cPicture := JURX3INFO(cCpoTab,"X3_PICTURE")
		lPicture := Iif(Empty(cPicture),.F.,.T.)
		If lPicture
			cValor   := TRANSFORM((TMP)->&(cCpoQry), cPicture)
			cValor   := AllTrim(CVALTOCHAR(cValor)) //Conteúdo a ser gravado
		Else
			cValor := AllTrim(CVALTOCHAR((TMP)->&(cCpoQry)))
		EndIf
	Else
		cValor := AllTrim(AllToChar((TMP)->&(cCpoQry)))
	EndIf
EndIf

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpSub()
Imprime o título da sessão no relatório
 
Uso Geral.

@param cTabela  Nome da tabela
        cCpoTab  Nome do campo na tabela
        cCpoQry  Nome do campo na query
        cTipo    Tipo do campo
        TMP      Alias aberto

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpSub(cQuerySub, TMP, aSessao, nLinCalc,lQuebPag, aRelat, aCabec, oPrint, nLin, lTitulo, lLinTit)
Local nJ     := 0
Local cValor := ""
Local aDados := {}
Local lHori  := aSessao[4]
Local cTxt   := cQuerySub
Local SUB    := GetNextAlias()
Local cVar   := "" // CAMPO
Local xValor       // Valor do campo

While RAT("#@", cTxt) > 0 // Substitui os nomes dos campos passados na query por seus respectivos valores
	cVar     := SUBSTR(cTxt,AT("@#", cTxt) + 2,AT("#@", cTxt) - (AT("@#", cTxt) + 2))
	xValor   := (TMP)->(FieldGet(FieldPos(cVar)))
	cTxt     := SUBSTR(cTxt, 1,AT("@#", cTxt)-1) + ALLTRIM(xValor) + SUBSTR(cTxt, AT("#@", cTxt)+2)
End

cQuerySub := cTxt

cQuerySub := ChangeQuery(cQuerySub)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySub),SUB,.T.,.T.)

While (SUB)->(!EOF())

	If nLin >= nFimL // Verifica se a linha corrente é maior que linha final permitida por página
		oPrint:EndPage() // Se for maior, encerra a página atual
		ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabeçalho
		nLinCalc := nLin // Inicia o controle das linhas impressas
		lTitulo := .T. // Indica que o título pode ser impresso 
		lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
	EndIf
		
		nLinCalc2 := nLinCalc // Backup da próxima linha a ser usada, pois na função JDadosCpo abaixo a variavel tem seu conteúdo alterado para
		                      // que seja realizada uma simulação das linhas usadas para impressão do conteúdo. 
		
		For nJ := 7 to Len(aSessao) // Lê as informações de cada campo a ser impresso. O contador começa em 6 pois é a partir dessa posição que estão as informações sobre o campo
			
			nLinFinal := 0 // Limpa a variável
						
			cTabela  := aSessao[nJ][2] //Tabela
			cCpoTab  := aSessao[nJ][3] //Nome do campo na tabela
			cCpoQry  := aSessao[nJ][4] //Nome do campo na query
			cTipo    := aSessao[nJ][5] //Tipo do campo
			cValor   := JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,,SUB,.T.) // Retorna o conteúdo/valor a ser impresso. Chama essa função para tratar o valor caso seja um memo ou data

			aAdd(aDados,JDadosCpo(aSessao[nJ],cValor,@nLinCalc,@lQuebPag)) // Título e conteúdo de cada campo são inseridos do array com os dados para serem impressos abaixo
		Next
		
		nLinCalc := nLinCalc2 // Retorno do valor original da variável
		
		If lQuebPag // Verifica se é necessário ocorrer a quebra de pagina
			oPrint:EndPage() // Se é necessário, encerra a página atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabeçalho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lQuebPag := .F. // Limpa a variável de quebra de página
			lTitulo  := .T. // Indica que o título pode ser impresso 
			lLinTit  := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
		EndIf

		If !lHori // Caso a impressão dos títulos seja na vertical - Todos os títulos na mesma linha e os conteúdos vem em colunas abaixo dos títulos (Ex: Relatório de andamentos)
			// Os títulos devem ser impressos
			lTitulo := .T. // Indica que o título pode ser impresso 
			lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
		EndIf

		//Imprime os campos do relatório
		JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec)
		
		//Limpa array de dados
		aSize(aDados,0)
		aDados := {}

		nLinCalc := nLinFinal //Indica a maior refência de uso de linhas para que sirva como referência para começar a impressão do próximo registro
		
		nLinFinal := 0 // Limpa a variável
		
		nLin := nLinCalc
	
	(SUB)->(DbSkip())
End

aSize(aDados,0)

(SUB)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JDadosCpo()
Função para montar array de titulos das colunas
 
Uso Geral.

@param cTabela  Nome da tabela
        cCpoTab  Nome do campo na tabela
        cCpoQry  Nome do campo na query
        cTipo    Tipo do campo
        cAliasqry      Alias aberto

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JDadosCpo(aSessao,cValor,nLinCalc,lQuebPag)
Local aDados    := {}
Local lQuebLin  := .F.
Local cTitulo   := ""
Local nPos      := 0
Local nQtdCar   := 0
Local nPosValor := 0
Local nPosTit   := 0
Local oFontVal
Local oFontTit

	cTitulo  := aSessao[1] //Título da Coluna
	nPosTit  := aSessao[6] //Indica a coordenada horizontal em pixels ou caracteres
	oFontTit := aSessao[8] //Fonte do título
	nPos     := aSessao[6] //Indica a coordenada horizontal para imprimir o valor do campo
	nQtdCar  := aSessao[7] //Quantidade de caracteres para que seja feita a quebra de linha
	oFontVal := aSessao[9] //Fonte usada para impressão do conteúdo
	nPosValor:= aSessao[10] //Fonte usada para impressão do conteúdo
	lQuebLin := aSessao[11] //Indica se deve existir a quebra de linha

	If !lQuebPag // Verifica se será necessária quebra de página para essa sessão
		lQuebPag := ((Int((Len(cValor)/nQtdCar) + 1) * nSalto) + nLinCalc) > nFimL
		nLinCalc += (Int((Len(cValor)/nQtdCar) + 1) * nSalto) // Indica a linha que será usada para cada valor quando forem impressos - Usado apenas para uma simulação.
	EndIf

	aDados := {cTitulo, nPosTit, oFontTit, cValor, nQtdCar, oFontVal, nPos, nPosValor, lQuebLin}

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpRel(aDados)
Função para montar array de titulos das colunas
 
Uso Geral.

@param 

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpRel(aDados,nLin,nLinCalc,oPrint,nLinFinal,lHori, lTitulo, lLinTit, aRelat,aCabec, lSalta)
Local nJ        := 0
Local lQuebLin  := .F.
Local lImpTit   := .T.
Local cTitulo   := ""
Local cValor    := ""
Local nPosTit   := 0
Local nPos      := 0
Local nQtdCar   := 0
Local nPosValor := 0
Local nLinTit   := 0
Local nLinAtu   := 0
Local aSobra    := aClone(aDados)
Local oFontTit
Local oFontVal

aEval(aSobra,{|x| x[4] := ""}) // Limpa a posição de conteúdo/valor dos campos no array de sobra, pois ele é preenchido com os dados do array aDados. Limpa para que seja preenchido com o conteúdo da sobra. 

Default lSalta  := .F.
Default lHori   := .T.

If lSalta // Se for continuação de impressão do conteúdo que não coube na página anterior 
	lImpTit := .F. // Indica que os títulos não precisam ser impressos
	lSalta  := .F. // Limpa variável
EndIf

For nJ := 1 to Len(aDados)

	cTitulo  := aDados[nJ][1] //Título da Coluna
	nPosTit  := aDados[nJ][2] //Indica a coordenada horizontal em pixels ou caracteres
	oFontTit := aDados[nJ][3] //Fonte do título
	cValor   := aDados[nJ][4] //Valor a ser impresso
	nQtdCar  := aDados[nJ][5] //Quantidade de caracteres para que seja feita a quebra de linha
	oFontVal := aDados[nJ][6] //Fonte usada para impressão do conteúdo
	nPos     := aDados[nJ][7] //Indica a coordenada horizontal para imprimir o valor do campo
	nPosValor:= aDados[nJ][8] + nPos //Indica a coordenada horizontal para imprimir o valor do campo
	lQuebLin := aDados[nJ][9] // Indica se deve existir quebra de linha após a impressão do campo

	If lHori // Impressão na horizontal -> título e descrição na mesma linha (Ex: Data: 01/01/2016)
		nLinTit  := nLin
		nLinCalc := nLin
		oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os títulos das colunas
	Else // Impressão na vertical -> Todos os títulos na mesma linha e os conteúdos vem em colunas abaixo dos títulos (Ex: Data
	     //                                                                                                                01/01/2016 )
		
		If lImpTit // Essa variável indica se deve imprimir o título dos campos - Será .F. somente quando ocorrer quebra de um conteúdo em mais de uma página (lSalta == .T.).
			If !lLinTit // Como a linha onde será impresso o título dos campos ainda não foi definida entrará nessa condição
				
				If (nLin + 2*nSalto) >= nFimL // Verifica se a linha corrente é maior que linha final permitida por página
					oPrint:EndPage() // Se for maior, encerra a página atual
					ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabeçalho
					nLinCalc := nLin // Inicia o controle das linhas impressas
					lTitulo := .T. // Indica que o título pode ser impresso 
					lLinTit := .F. // Essa variável indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
					nLinFinal := 0 
				EndIf
				
				nLinTit  := nLin
				nLin     += nSalto
				nLinCalc := nLin
				lLinTit := .T. // Indica que a linha onde será impresso o título dos campos já foi definida e não será mais alterada
			EndIf
			
			If lTitulo // Indica que o título pode ser impresso
				oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os títulos das colunas
				
				lTitulo := Len(aDados) <> nJ // Enquanto estiver preenchendo os títulos indica .T., para que os outros títulos sejam impressos. 
				                             // Após o preenchimento do último título indica .F., não premitindo mais a impressão dos títulos nessa página.
				                             
				// Deve imprimir apenas uma vez por página para que a letra não fique mais grossa.
				// Se não tiver esse tratamento a impressão será feita várias vezes sobre a mesma palavra devido as condições do laço, 
				// fazendo com que a grossura das letras nas palavras aumente e isso atrapalha.
				
			EndIf
		EndIf
		nPosValor := nPosTit // Indica que a posição (coluna) do conteúdo/valor a ser impresso é a mesma que foi impresso o titulo, ou seja, o conteúdo/valor ficará logo abaixo do título
	EndIf

	nLinAtu := nLinCalc // Controle de linhas usadas para imprimir o conteúdo atual

	JImpLin(@oPrint,@nLinAtu,nPosValor,cValor,oFontVal,nQtdCar,@aSobra[nJ], @lSalta, lImpTit) //Imprime as linhas com os conteúdos/valores

	// Verifica qual campo precisou de mais linhas para ser impresso
	// para usar esse valor como referência para começar a impressão do próximo registro
	If nLinAtu > nLinFinal
		nLinFinal := nLinAtu
	EndIf

	If lSalta .And. lQuebLin // Se precisa continuar a impressão do conteúdo atual na próxima página 
		oPrint:EndPage() // Finaliza a página atual
		ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabeçalho na próxima página
		nLinCalc  := nLin // Inicia o controle das linhas a serem impressas
		nLinAtu   := nLinCalc // Atualiza variável linha atual
		lQuebPag  := .F. // Indica que não é necessário ocorrer a quebra de pagina, pois já está sendo quebrada nesse momento.
		lTitulo   := .T. // Indica que o título pode ser impresso 
		lLinTit   := .F. // Indica que a linha de impressão do título precisa ser definida, pois iniciará uma nova linha.
		nLinFinal := 0 // Limpa variável de controle da última linha impressa.
		
		// Imprime o restante do conteúdo que não coube na página anterior.
		JImpRel(aSobra,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec, @lSalta)
		aEval(aSobra,{|x| x[4] := ""})
	EndIf
	
	If lQuebLin // Indica que é necessária quebra de linha, ou seja, o próximo campo será impresso na próxima linha
		If nLinFinal >= nLin // Se a próxima linha a ser impressa (nLin) for menor que a última linha que tem conteúdo impresso (nLinFinal)
			nLin     := nLinFinal // Deve-se indicar a maior referência
		Else
			nLin     += nSalto // Caso contrário, pule uma linha.
		EndIf
		
		If nLin >= nFimL
			oPrint:EndPage() // Se for maior, encerra a página atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabeçalho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lTitulo := .T. // Indica que o título pode ser impresso 
			lLinTit := .F. // Indica que a linha de impressão do título precisa ser definida, pois iniciará uma nova linha.
			nLinFinal := 0 // Limpa variável de controle da última linha impressa.
		Else
			nLinTit  := nLin // Recebe a próxima linha disponível para impressão do título
			nLinCalc := nLin // Atualiza variável de cálculo de linhas
			lLinTit  := .F.  // Indica que a linha de impressão do título precisa ser definida, pois iniciará uma nova linha.
		EndIf
	EndIf
	
Next nJ

If lSalta // Se precisa continuar a impressão do conteúdo atual na próxima página 
	oPrint:EndPage() // Finaliza a página atual
	ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabeçalho na próxima página
	nLinCalc  := nLin // Inicia o controle das linhas a serem impressas
	nLinAtu   := nLinCalc // Atualiza variável linha atual
	lQuebPag  := .F. // Indica que não é necessário ocorrer a quebra de pagina, pois já está sendo quebrada nesse momento.
	lTitulo   := .T. // Indica que o título pode ser impresso 
	lLinTit   := .F. // Indica que a linha de impressão do título precisa ser definida, pois iniciará uma nova linha.
	nLinFinal := 0 // Limpa variável de controle da última linha impressa.
	
	// Imprime o restante do conteúdo que não coube na página anterior.
	JImpRel(aSobra,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec, @lSalta)
EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpLin(aDados)
Função para montar array de titulos das colunas
 
Uso Geral.

@param 

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpLin(oPrint,nLinAtu,nPosValor,cTexto,oFontVal,nQtdCar,aSobra, lSalta, lImpTit)
Local nRazao    := oPrint:GetTextWidth( "oPrint:nPageWidth", oFontVal )
Local nTam      := (nRazao * nQtdCar) / 350
Local aCampForm := {} // Array com cada palavra a ser escrita.
Local cValor    := ""
Local cValImp   := "" // Valor impresso
Local nX        := 0

cTexto := StrTran(cTexto, Chr(13)+Chr(10), '')
cTexto := StrTran(cTexto, Chr(10), '')
aCampForm := STRTOKARR(cTexto, " ")

If Len(aCampForm) == 0 // Caso não exista conteúdo/valor
	If lImpTit // E o título do campo foi impresso 
		oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Será inserida a linha com conteúdo em branco
		nLinAtu += nSalto // Pula uma linha
	EndIf
Else // Caso exista conteúdo/valor
	For nX := 1 To Len(aCampForm) // Laço para cada palavra a ser escrita
		If oPrint:GetTextWidth( cValor + aCampForm[nX], oFontVal ) <= nTam // Se a palavra atual for impressa e NÃO passar do limite de tamanho da linha
			cValor += aCampForm[nX] + " " // Preenche a linha com a palavra atual
		
			If Len(aCampForm) == nX // Caso esteja na última palavra
				oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conteúdo que estava em cValor
				nLinAtu += nSalto // Pula para a próxima linha
			EndIf
	
		Else // Se a palavra atual for impressa e passar do limite de tamanho da linha
			oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conteúdo que estava em cValor sem a palavra que ocasionou a quebra.
			nLinAtu += nSalto // Pula para a próxima linha
					
			If nLinAtu + 2*nSalto > nFimL // Se a próxima linha a ser impressa NÃO couber na página atual
				lSalta := .T. // Indica que precisa continuar a impressão do conteúdo atual na próxima página 
				If Empty(SubStr(cTexto,Len(cValImp+cValor)+2,1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor)+3,Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				ElseIf Empty(SubStr(cTexto,Len(cValImp+cValor)+1,1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor)+2,Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				ElseIf Empty(SubStr(cTexto,Len(cValImp+cValor),1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor),Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				EndIf
				Exit
			Else // Se a próxima linha a ser impressa couber na página atual
				cValImp += cValor // Guarda todo o texto que já foi impresso para que caso necessite de quebra o sistema saiba até qual parte o texto já foi impresso.
				cValor := aCampForm[nX] + " " // Preenche a linha com a palavra atual
			EndIf
		EndIf
		
	Next
EndIf

//Limpa array
aSize(aCampForm,0)

Return Nil
