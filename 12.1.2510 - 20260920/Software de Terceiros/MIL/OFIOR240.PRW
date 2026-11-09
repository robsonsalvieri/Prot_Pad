// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 14     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "OFIOR240.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR240 ³ Autor ³ Eveli Morasco         ³ Data ³ 25/02/93 ³±±
±±³Refatorado OFIOR240 ³  Autor ³ Peterson O. De Paula  ³ Data ³ 28/04/26 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Saldos em Estoques                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Rodrigo Sart.³07/08/98³16964A³Acerto na filtragem dos almoxarifados   ³±±
±±³ Fernando Joly³23/10/98³15013A³Acerto na filtragem de Filiais          ³±±
±±³ Fernando Joly³03/12/98³XXXXXX³S¢ imprimir "Total do Produto" quando   ³±±
±±³              ³        ³      ³houver mais de 1 produto.               ³±±
±±³ Fernando Joly³21/12/98³18920A³Possibilitar filtragem pelo usuario.    ³±±
±±³ Cesar Valadao³30/03/99³XXXXXX³Manutencao na SetPrint()                ³±±
±±³ Aline        ³27/04/99³21147 ³Considerar o NewHead do Titulo          ³±±
±±³ Cesar Valadao³28/04/99³17188A³Inclusao da Pergunta - Descricao Produto³±±
±±³              ³        ³      ³Descricao Cientifica ou Generica.       ³±±
±±³ Cesar Valadao³08/12/99³25510A³Erro na Totalizacao de Produto Por      ³±±
±±³              ³        ³      ³Almoxarifado com Saldo Zerado.          ³±±
±±³ Patricia Sal.³11/07/00³005086³Acerto Salto de linha (P/ Almoxarifado) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OFIOR240

Local oReport
               
Private nSizFil := 0
Private cStr    := ""
Private aReturn := {(STR0008), 1,(STR0009), 2, 2, 1, '',1 } // 'Zebrado'###'Administracao'

Pergunte('OFR240',.F.)
oReport := ReportDef()
oReport:PrintDialog()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport
Local oSection1
//Local oCell

oReport := TReport():New("OFIOR240",(STR0015),"OFR240",{|oReport| OR240Imp(oReport)}) //Saldos em Estoques

oSection1 := TRSection():New(oReport,STR0019,{"SB1","SB2"})
TRCell():New(oSection1,"",,"","@!",220,, {|| cStr } )

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OR240Imp ³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OR240Imp(oReport)

Local oSection1 := oReport:Section(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Local cRodaTxt   := 'REG(S)'
// Local nCntImpr   := 0
Local nTipo      := 0
Local aOrd       := {(STR0004),(STR0005),(STR0006),(STR0007)} // ' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nSoma      := 0
Local nTotSoma   := 0
Local nQtdProd   := 0
Local aSalProd   := {}
Local cMens      := ''
Local cFilOld    := 'úú'
Local cCodAnt    := 'úú'
Local cDesc
Local lIsCient
Local cPict      := "@E 9,999,999.99"
Local lmv_par02  := ''
Local lmv_par03  := ''
Local nSaldo        := 0
//
Local cGruVei    := PadR(AllTrim(GetNewPar("MV_GRUVEI","VEIC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cGruSrv    := PadR(AllTrim(GetNewPar("MV_GRUSRV","SRVC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Servico
//
Local cAlias := GetNextAlias()
Local cQuery := ""
Local cSB1Fil := ""
Local cSB2Fil := ""
//
Local cQuebraAnt2 := ""
Local cGrpAnt     := ""
Local cCodIteAnt  := ""
Local cTipoAnt    := ""
Local cDescAnt    := ""
Local cUmAnt      := ""
Local cChvTotAtu := ""
//
oReport:SetMeter(RecCount())
oSection1:Init(.f.)
oReport:SetMeter(SE1->(RecCount()))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private exclusivas deste programa                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cQuebra2   := ''
Private cCond2     := ''
Private cFiltroB1  := ''
Private cIndB1     := ''
Private aFilAtu        := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Private aFiliais       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Private nCont          := 0
Private cBkpFilAnt := cFilAnt // salvar cFilAnt
Private cFiltroB2  := ''
Private cIndB2     := ''
Private lContinua  := .T.
Private cNomArqB1  := ''
Private cNomArqB2  := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Li         := 80
Private m_pag      := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := iif(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a ordem escolhida ao Titulo do relatorio          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type('NewHead') # 'U'
	NewHead := AllTrim(NewHead)
	NewHead += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
Else
	Titulo := STR0015 //AllTrim("Saldos em Estoques")
	Titulo += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1 := (STR0010) // 'CODIGO          TP GRUP DESCRICAO                      UM FL ALM      QUANTIDADE'
cCabec2 := ''
//-- 123456789012345 12 1234 123456789012345678901234567890 12 12 12 999,999,999.99
//-- 0         1         2         3         4         5         6         7
//-- 012345678901234567890123456789012345678901234567890123456789012345678901234567890


Pergunte('OFR240',.F.)
If mv_par01 == 3
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
ElseIf mv_par01 == 2
	cIndB2 := 'B2_FILIAL + B2_COD + B2_LOCAL'
Else
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
EndIf

//Filial SB1
cSB1Fil := " B1.B1_FILIAL = '"+ xFilial("SB1")+"'"
If !Empty(xFilial('SB1'))
	// Para Argentina, o sistema não deixa colocar paremetro filial em branco, 
	// por isso é necessário ajustar por causa do tipo de compartilhamento difirente entre SB1 e SB2 
	 lmv_par02 := mv_par02 
	 lmv_par03 := mv_par03 
	If len(AllTrim(xFilial('SB2'))) > len(AllTrim(xFilial('SB1')))
		lmv_par02 := substr(mv_par02,-1*len(Alltrim(xFilial('SB1'))))
		lmv_par03 := substr(mv_par03,-1*len(Alltrim(xFilial('SB1'))))
	Endif
    cSB1Fil := " B1.B1_FILIAL BETWEEN '" + lmv_par02 + "' AND '" + lmv_par03 + "' "
EndIf

//Filial SB2
cSB2Fil := " B2.B2_FILIAL = '"+ xFilial("SB2")+"'"
If !Empty(xFilial("SB2"))
	cSB2Fil := " B2.B2_FILIAL BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
EndIf

cMens        := ""

//////////////// sql SB1 ////////////////
cQuery += " SELECT          "
cQuery += "   B1.B1_COD,    "
cQuery += "   B1.B1_CODITE, " 
cQuery += "   B1.B1_DESC,   "
cQuery += "   B1.B1_TIPO,   "
cQuery += "   B1.B1_GRUPO,  "
cQuery += "   B1.B1_UM,     "
cQuery += "   B2.B2_FILIAL, "
cQuery += "   B2.B2_LOCAL,  "
cQuery += "   B2.B2_QATU,   "
cQuery += "   B2.B2_QFIM,    "
cQuery += "   B2.B2_COD    "
cQuery += " FROM " + RetSqlName("SB1") + " B1 "
cQuery += " INNER JOIN " + RetSqlName("SB2") + " B2 "
cQuery += "    ON "+cSB2Fil
cQuery += " AND B2.B2_COD = B1.B1_COD    "
cQuery += " AND B2.B2_LOCAL BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "' "
cQuery += " AND B2.D_E_L_E_T_ = ' '     "

// WHERE Filtros SB1
cQuery += " WHERE "+cSB1Fil
cQuery += " AND B1.B1_COD BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "' "
cQuery += " AND B1.B1_TIPO BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "' "
cQuery += " AND B1.B1_GRUPO BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "' "
cQuery += " AND B1.D_E_L_E_T_ = ' '     "

// Excluir grupos de Veiculo e Servico diretamente no SQL
cQuery += " AND B1.B1_GRUPO NOT IN ('" + cGruVei + "','" + cGruSrv + "') "

cQuery += " ORDER BY B1.B1_COD, B2.B2_FILIAL, B2.B2_LOCAL "

// Executa query
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

dbSelectArea(cAlias)
dbGoTop()

oReport:SetMeter((cAlias)->(LastRec()))
oSection1:Init(.F.)

//-- Imprime cabecalho
cStr := (STR0010)
oSection1:PrintLine()
cStr := ""
oSection1:PrintLine()

// Loop agora é só no resultado da query (bem menor)
Do While !(cAlias)->(Eof()) .and. lContinua

	oReport:IncMeter()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
	//³ verifica se existe registro no SB5 e se nao esta vazio    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDesc := (cAlias)->B1_DESC
	lIsCient := .F.
	If mv_par17 == 1
		dbSelectArea("SB5")
		MsSeek(xFilial()+(cAlias)->B1_COD)
		If Found() .and. !Empty(B5_CEME)
			cDesc := B5_CEME
			lIsCient := .T.
		EndIf
		dbSelectArea(cAlias)
	Endif
	
	//-- Consiste Descri‡Æo De/At‚
	If cDesc < mv_par12 .Or. cDesc > mv_par13
		(cAlias)->(dbSkip())
		Loop
	EndIf
	
	
	
	
	
	
	
    // Calcula saldo conforme parametro mv_par15
	If mv_par15 == 1
		nSaldo := (cAlias)->B2_QATU
	ElseIf mv_par15 == 2
		nSaldo := (cAlias)->B2_QFIM
    ElseIf mv_par15 > 2
        // CalcEst: verifica posicionamento correto da filial
        If !Empty((cAlias)->B2_FILIAL)
            aSalProd := CalcEst((cAlias)->B2_COD, (cAlias)->B2_LOCAL, dDataBase + 1)
        Else
            aSalProd := {0,0,0,0,0,0,0}
        EndIf
        nSaldo := aSalProd[1]
    Else
        nSaldo := 0
    EndIf

	If (nSaldo == 0 .And. mv_par14 == 2) .Or. ;
	   (nSaldo > 0  .And. mv_par16 == 1)
		(cAlias)->(dbSkip())
		Loop
	EndIf

 	If mv_par01 == 1
		cChvTotAtu := (cAlias)->B1_COD
	ElseIf mv_par01 == 2
		cChvTotAtu := (cAlias)->B2_FILIAL + (cAlias)->B1_COD
	Else
		cChvTotAtu := (cAlias)->B1_COD
	EndIf

	If !Empty(cQuebraAnt2) .And. cQuebraAnt2 # cChvTotAtu

		If mv_par01 == 1

			If nQtdProd > 1
				cStr := STR0014 + Space(1) + AllTrim(Left(cCodAnt,15)) + Space(1) + ;
				        Replicate(".",21-Len(AllTrim(Left(cCodAnt,15)))) + " " + ;
				        Transform(nSoma, cPict)
				oSection1:PrintLine()
				cStr := ""
				oSection1:PrintLine()
			EndIf

		Else

			If nSoma # 0
				nSizFil := 12 - FWSizeFilial()

				cStr := Left(cGrpAnt + Space(4),4) + " " + ;
				        Left(cCodIteAnt + Space(27),27) + " " + ;
				        Left(cCodAnt + Space(15),15) + " " + ;
				        Left(cTipoAnt + Space(2),2) + " " + ;
				        Left(cDescAnt,17) + " " + ;
				        cUmAnt + " " + ;
				        IIf(mv_par01 == 2, cFilOld + Space(nSizFil), Repl("*",FWSizeFilial()) + Space(nSizFil)) + ;
				        " **" + Transform(nSoma, cPict)

				oSection1:PrintLine()
			EndIf

		EndIf

		nSoma    := 0
		nQtdProd := 0

	EndIf

	nSizFil := 12 - FWSizeFilial()

	If mv_par01 == 1
		cStr := Left((cAlias)->B1_GRUPO  + Space(4),4) + " " + ;
		        Left((cAlias)->B1_CODITE + Space(27),27) + " " + ;
		        Left((cAlias)->B1_COD    + Space(15),15) + " " + ;
		        Left((cAlias)->B1_TIPO   + Space(2),2) + " " + ;
		        Left(IIf(lIsCient, cDesc, (cAlias)->B1_DESC),17) + " " + ;
		        (cAlias)->B1_UM + " " + ;
		        (cAlias)->B2_FILIAL + Space(nSizFil) + " " + ;
		        (cAlias)->B2_LOCAL + "   " + ;
		        Transform(nSaldo, cPict)

		nQtdProd++
		oSection1:PrintLine()
	EndIf

	nSoma    += nSaldo
	nTotSoma += nSaldo

	cGrpAnt     := (cAlias)->B1_GRUPO
	cCodIteAnt  := (cAlias)->B1_CODITE
	cTipoAnt    := (cAlias)->B1_TIPO
	cDescAnt    := IIf(lIsCient, cDesc, (cAlias)->B1_DESC)
	cUmAnt      := (cAlias)->B1_UM
	cFilOld     := (cAlias)->B2_FILIAL
	cCodAnt     := (cAlias)->B1_COD
	cQuebraAnt2 := cChvTotAtu

		
	(cAlias)->(dbSkip())
		
EndDo

If !Empty(cQuebraAnt2) .And. !Empty(cCodAnt) .And. nSoma # 0

	If mv_par01 == 1
		If nQtdProd > 1
			cStr := STR0014 + Space(1) + AllTrim(Left(cCodAnt,15)) + Space(1) + ;
			        Replicate(".",21-Len(AllTrim(Left(cCodAnt,15)))) + " " + ;
			        Transform(nSoma, cPict)
			oSection1:PrintLine()
			cStr := ""
			oSection1:PrintLine()
		EndIf
	Else
		nSizFil := 12 - FWSizeFilial()

		cStr := Left(cGrpAnt + Space(4),4) + " " + ;
		        Left(cCodIteAnt + Space(27),27) + " " + ;
		        Left(cCodAnt + Space(15),15) + " " + ;
		        Left(cTipoAnt + Space(2),2) + " " + ;
		        Left(cDescAnt,17) + " " + ;
		        cUmAnt + " " + ;
		        IIf(mv_par01 == 2, cFilOld + Space(nSizFil), Repl("*",FWSizeFilial()) + Space(nSizFil)) + ;
		        " **" + Transform(nSoma, cPict)
		oSection1:PrintLine()
	EndIf

EndIf

(cAlias)->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original dos arquivos principal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cBkpFilAnt
dbSelectArea('SB1')
Set Filter To
dbSetOrder(1)

dbSelectArea('SB2')
Set Filter To
dbSetOrder(1)

oSection1:Finish()

Return Nil
