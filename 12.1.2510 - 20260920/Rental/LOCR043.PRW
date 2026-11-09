#Include "locr043.ch"
#Include "totvs.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT     0
#Define PAD_RIGHT    1
#Define PAD_CENTER   2
#Define PAD_JUSTIF   3

//Cores
#Define COR_CINZA    RGB(180, 180, 180)
#Define COR_PRETO    RGB(000, 000, 000)
#Define COR_BRANCO   RGB(255, 255, 255)
#Define COR_VERDE    RGB(000, 140, 000)
#Define COR_VERMELHO RGB(200, 000, 000)
#Define COR_CINZAESC RGB(100, 100, 100)
#Define COR_ROXO     RGB(156, 039, 176)
#Define COR_AZULESC  RGB(063, 081, 181)
#Define COR_AMARELO  RGB(255, 193, 007)
#Define COR_AZUL     RGB(033, 150, 243)
#Define COR_LARANJA  RGB(255, 152, 000)
#Define COR_AZULMAR  RGB(021, 101, 192)

//Colunas (layout de 2 colunas label/valor dentro de nColIni=015..nColFin=580)
#Define COL_01       015
#Define COL_02       110
#Define COL_03       305
#Define COL_04       395

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043
Reimpressao do check-list de entrega/devolucao de equipamento locado
(App Rental). Busca os dados gravados pelo LOCW002 nas tabelas FQC
(cabecalho do checklist) e FPX (itens do questionario), e as fotos no
banco de conhecimento nativo do Protheus (AC9/ACB).
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Function LOCR043()
Local aArea := GetArea()

	Processa({|| LOCR043M()}, STR0001) //"Processando..."

	RestArea(aArea)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043M
Monta o relatorio: seleciona os checklists (FQC) pelo filtro informado
no ParamBox e imprime cada um encontrado.
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043M()
Local cQuery     := "" as Character
Local cAliasFQC  := GetNextAlias() as Character
Local aBindParam := {} as Array
Local aPergs     := {} as Array
Local aRet       := {} as Array
Local aAreaFQC   := FQC->(GetArea())
Local aAreaFPX   := FPX->(GetArea())
Local aAreaST9   := ST9->(GetArea())
Local aAreaSA1   := SA1->(GetArea())
Local aAreaAC9   := AC9->(GetArea())
Local aAreaACB   := ACB->(GetArea())
Local lAchou     := .F.

Private nLinAtu    := 000
Private nTamLin    := 010
Private nLinFin    := 780
Private nColIni    := 015
Private nColFin    := 580
Private oPrintPvt
Private dDataGer   := Date()
Private cHoraGer   := Time()
Private nPagAtu    := 1
Private cNomeUsr   := UsrRetName(RetCodUsr())
Private cCodCheAt  := ""
Private cCentroAt  := "" //Centro de custo do bem (T9_CENTRAB), vazio se o bem nao for encontrado
Private cNomeBemAt := "" //Descricao do bem (T9_NOME), vazio se o bem nao for encontrado
Private cNomeCliAt := "" //Nome do cliente (A1_NOME), vazio se o cliente nao for encontrado
Private cEmailCliAt:= "" //E-mail do cliente (A1_EMAIL), vazio se o cliente nao for encontrado
Private cPathBcoAt := "" //Caminho fisico do banco de conhecimento (calculado uma unica vez)
Private aFotosChk  := {}
Private aStatIA    := {} //correlacao topico|item -> {FPX_STATIA, FPX_OBSIA}, montada por LOCR043Q e usada por LOCR043G
Private cNomeFont  := "Arial"
Private oFontGigN  := TFont():New(cNomeFont, 9, -18, .T., .T., 5, .T., 5, .T., .F.)
Private oFontTitN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
Private oFontTit   := TFont():New(cNomeFont, 9, -13, .T., .F., 5, .T., 5, .T., .F.)
Private oFontDetN  := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
Private oFontDet   := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
Private oFontRod   := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
Private oBrush1    := TBrush():New(, CLR_HGRAY)
//Cores identicas as usadas pelo app (lib/services/pdf_service.dart: _legendCircle) no PDF
//original do checklist, para o relatorio de reimpressao ficar visualmente igual
Private oBrushC    := TBrush():New(, COR_VERDE)    //legenda respostas: "C" Conforme
Private oBrushNC   := TBrush():New(, COR_VERMELHO) //legenda respostas: "NC" Nao conforme
Private oBrushNA   := TBrush():New(, COR_LARANJA)  //legenda respostas: "NA" Nao se aplica
Private oBrushA    := TBrush():New(, COR_VERMELHO) //legenda avaria: Amassado
Private oBrushF    := TBrush():New(, COR_AZUL)     //legenda avaria: Falta
Private oBrushP    := TBrush():New(, COR_ROXO)     //legenda avaria: Pique
Private oBrushQ    := TBrush():New(, COR_LARANJA)  //legenda avaria: Quebrado
Private oBrushR    := TBrush():New(, COR_AZULMAR)  //legenda avaria: Riscado
Private oBrushT    := TBrush():New(, COR_VERDE)    //legenda avaria: Trincado
Private oBrushIA1  := TBrush():New(, COR_VERMELHO) //Status I.A. 1: Danos Graves
Private oBrushIA2  := TBrush():New(, COR_AZULESC)  //Status I.A. 2: Desgaste Grande
Private oBrushIA3  := TBrush():New(, COR_CINZAESC) //Status I.A. 3: Desgaste Pequeno
Private oBrushIA4  := TBrush():New(, COR_AMARELO)  //Status I.A. 4: Pequenas Mudancas
Private oBrushIA5  := TBrush():New(, COR_VERDE)    //Status I.A. 5: Melhorou ou Manteve

	//FQC_CODCHE e um numero sequencial de controle (gerado por GetSxeNum), sem consulta
	//padrao de F3 associada - por isso o campo "tabela" (posicao 6) fica vazio.
	AAdd(aPergs, {1, STR0002, Space(TamSX3("FQC_CODCHE")[1]), "@!", "", "", "", 100, .F.}) //"Codigo Checklist De "
	AAdd(aPergs, {1, STR0003, Replicate("Z", TamSX3("FQC_CODCHE")[1]), "@!", "", "", "", 100, .F.}) //"Codigo Checklist Ate"

	If ParamBox(aPergs, "Reimpressao de Checklist", @aRet)

		LOCR043N() //cria o objeto FWMSPrinter (oPrintPvt)

		//calculado uma unica vez (fora do loop de checklists) para nao chamar SuperGetMv a cada
		//registro
		cPathBcoAt := Alltrim(SuperGetMv("MV_DIRDOC", .F., ""))
		If SubStr(cPathBcoAt, Len(cPathBcoAt), 1) <> '\'
			cPathBcoAt += "\"
		EndIf
		cPathBcoAt += "co" + cEmpAnt + "\shared\"

		cQuery := " SELECT FQC.FQC_CODCHE CODCHE "
		cQuery += " FROM " + RetSqlName("FQC") + " FQC "
		cQuery += " WHERE FQC.FQC_FILIAL = ? "
		AAdd(aBindParam, FWxFilial("FQC"))
		cQuery += "   AND FQC.FQC_CODCHE BETWEEN ? AND ? "
		AAdd(aBindParam, PadR(aRet[1], TamSX3("FQC_CODCHE")[1]))
		AAdd(aBindParam, PadR(aRet[2], TamSX3("FQC_CODCHE")[1]))
		cQuery += "   AND FQC.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY FQC.FQC_CODCHE "
		cQuery := ChangeQuery(cQuery)

		MPSysOpenQuery(cQuery, cAliasFQC, , , aBindParam)

		FQC->(DbSetOrder(1)) //FQC_FILIAL+FQC_CODCHE
		ST9->(DbSetOrder(1)) //T9_FILIAL+T9_CODBEM
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

		While !(cAliasFQC)->(Eof())

			If FQC->(DbSeek(FWxFilial("FQC") + (cAliasFQC)->CODCHE))
				lAchou := .T.
				LOCR043I() //imprime um checklist completo
			EndIf

			(cAliasFQC)->(DbSkip())
		EndDo

		(cAliasFQC)->(DbCloseArea())

		If !lAchou
			oPrintPvt:StartPage()
			oPrintPvt:SayAlign(30, nColIni, STR0004, oFontDet, 500, 20, COR_PRETO, PAD_LEFT, 0) //"Nao existem checklists para o filtro selecionado."
			oPrintPvt:EndPage()
		EndIf

		//Sleep(5000)
		oPrintPvt:SETVIEWPDF(.T.)
		oPrintPvt:Preview()

	EndIf

	RestArea(aAreaFQC)
	RestArea(aAreaFPX)
	RestArea(aAreaST9)
	RestArea(aAreaSA1)
	RestArea(aAreaAC9)
	RestArea(aAreaACB)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043N
Cria o objeto FWMSPrinter usado por todo o relatorio.
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043N()
Local cArquivo := "locr043_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')

	oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "\relato\", .T., , @oPrintPvt, "", , , , .T.)

	//DENNIS CALABREZ - mesma configuracao usada no LOCR003 (faturas): grava o
	//PDF na pasta "\relato\" (compartilhada/reconhecida pelo broker web) em vez
	//da pasta de temp local, que falha no servidor com "PDF nao pode ser exibido".
	//O cFilePrint NAO deve ser sobrescrito para GetTempPath() apos o New() - isso
	//anulava o parametro "\relato\" do construtor e fazia o PDF ser gravado na
	//pasta de temp local do appserver, inacessivel pelo broker web no servidor
	//(por isso funcionava local e falhava no servidor com "PDF nao pode ser exibido").
	oPrintPvt:lServer  := .T.
	oPrintPvt:lViewPDF := .T.
	oPrintPvt:nDevice  := 6

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043I
Imprime um checklist completo (FQC posicionado): cabecalho, dados
principais, legendas, questionario por familia, galeria de fotos e
termo de aceite com assinatura.
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043I()

	cCodCheAt := AllTrim(FQC->FQC_CODCHE)
	aFotosChk := {}
	aStatIA   := {}

	cCentroAt  := ""
	cNomeBemAt := ""
	If ST9->(DbSeek(FWxFilial("ST9") + FQC->FQC_CODBEM))
		cCentroAt  := AllTrim(ST9->T9_CENTRAB)
		cNomeBemAt := AllTrim(ST9->T9_NOME)
	EndIf

	cNomeCliAt  := ""
	cEmailCliAt := ""
	If SA1->(DbSeek(FWxFilial("SA1") + FQC->(FQC_CODCLI + FQC_LOJCLI)))
		cNomeCliAt  := AllTrim(SA1->A1_NOME)
		cEmailCliAt := AllTrim(SA1->A1_EMAIL)
	EndIf

	LOCR043H() //inicia pagina e imprime cabecalho + titulo

	LOCR043D() //dados principais

	LOCR043L() //legendas

	LOCR043Q() //questionario por topico (tambem monta aFotosChk)

	LOCR043G() //galeria de fotos "Fotos (n)"

	LOCR043T() //termos de aceite + assinaturas

	LOCR043R() //fecha a ultima pagina do checklist atual

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043H
Inicia uma nova pagina e imprime o cabecalho (logo, titulo do
formulario e identificacao do bem/contrato).
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043H()
Local nLinCab := 030

	oPrintPvt:StartPage()

	oPrintPvt:SayAlign(nLinCab, nColIni, AllTrim(FQC->FQC_DESFOR), oFontGigN, 400, 20, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLinCab, nColFin - 120, DtoC(dDataGer) + " " + cHoraGer, oFontDet, 120, nTamLin, COR_PRETO, PAD_RIGHT, 0)
	nLinCab += (nTamLin * 2)

	oPrintPvt:SayAlign(nLinCab, nColIni, "CodBem: " + AllTrim(FQC->FQC_CODBEM) + " / Contrato: " + AllTrim(FQC->FQC_PROJET), oFontTit, 400, 20, COR_CINZAESC, PAD_LEFT, 0)
	nLinCab += (nTamLin * 2)

	oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, COR_CINZA)
	nLinCab += nTamLin

	nLinAtu := nLinCab

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043P
Garante espaco disponivel na pagina atual; se nao houver, fecha a
pagina (rodape) e abre uma nova com o cabecalho compacto.
@type function
@author Dennis Calabrez
@since 01/09/2026
@param nAltura, numeric, Altura em pontos necessaria a seguir
/*/
//---------------------------------------------------------------------
Static Function LOCR043P(nAltura as Numeric) as Logical
Local lQuebrou := .F.

	If nLinAtu + nAltura > nLinFin
		LOCR043R()
		LOCR043H() //reabre a pagina ja com cabecalho (CodBem/Contrato/titulo)
		lQuebrou := .T.
	EndIf

Return lQuebrou

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043D
Imprime o bloco "Dados Principais" do checklist.
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043D()
Local cCelFmt := ""

	LOCR043P(120)

	oPrintPvt:SayAlign(nLinAtu, nColIni, STR0005, oFontTitN, 300, 20, COR_PRETO, PAD_LEFT, 0) //"Dados Principais"
	nLinAtu += (nTamLin * 1.5)
	oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)

	LOCR043D2(STR0007, AllTrim(FQC->FQC_DESFOR), STR0006, DtoC(FQC->FQC_DTINI) + " " + FQC->FQC_HRINI) //"Data/Hora" //"Tipo Vistoria"
	LOCR043D2(STR0009, cCentroAt, STR0008, AllTrim(FQC->FQC_PROJET)) //"Contrato" //"Centro de Custo"
	LOCR043D2(STR0011, cNomeCliAt, STR0010, cEmailCliAt) //"Email do Cliente" //"Cliente"
	LOCR043D2(STR0013, AllTrim(FQC->FQC_CIDADE) + " - " + AllTrim(FQC->FQC_ESTADO), STR0012, AllTrim(FQC->FQC_STBEMA)) //"Status do Bem" //"Cidade Atendimento"

	nLinAtu += (nTamLin * 0.5)
	oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)

	LOCR043D2(STR0015, AllTrim(FQC->FQC_CLIAUT), STR0014, AllTrim(FQC->FQC_CNHAUT)) //"Documento" //"Responsavel"

	cCelFmt := AllTrim(FQC->FQC_CELAUT)
	LOCR043D2(STR0017, AllTrim(FQC->FQC_EMAAUT), STR0016, cCelFmt) //"Celular" //"E-mail"

	nLinAtu += (nTamLin * 0.5)
	oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)

	LOCR043D2(STR0019, AllTrim(FQC->FQC_CODBEM) + " " + cNomeBemAt, STR0018, AllTrim(FQC->FQC_PLACA)) //"Placa" //"Veiculo"
	LOCR043D2(STR0020, AllTrim(Str(FQC->FQC_POSCON)), "", "") //"Contador"

	nLinAtu += nTamLin
	oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)
	nLinAtu += (nTamLin * 1.5)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043D2
Imprime uma linha com duas colunas de "rotulo: valor" do bloco Dados
Principais.
@type function
@author Dennis Calabrez
@since 01/09/2026
@param cRot1, caracter, Rotulo da 1a coluna
@param cVal1, caracter, Valor da 1a coluna
@param cRot2, caracter, Rotulo da 2a coluna (vazio se nao houver)
@param cVal2, caracter, Valor da 2a coluna
/*/
//---------------------------------------------------------------------
Static Function LOCR043D2(cRot1 as Character, cVal1 as Character, cRot2 as Character, cVal2 as Character)

	oPrintPvt:SayAlign(nLinAtu, nColIni, cRot1 + ":", oFontDetN, COL_02 - nColIni - 5, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLinAtu, COL_02, cVal1, oFontDet, COL_03 - COL_02 - 5, nTamLin, COR_PRETO, PAD_LEFT, 0)

	If !Empty(cRot2)
		oPrintPvt:SayAlign(nLinAtu, COL_03, cRot2 + ":", oFontDetN, COL_04 - COL_03 - 5, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLinAtu, COL_04, cVal2, oFontDet, nColFin - COL_04, nTamLin, COR_PRETO, PAD_LEFT, 0)
	EndIf

	nLinAtu += nTamLin

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043B
Desenha um badge (retangulo colorido com o codigo em branco) seguido,
opcionalmente, de um texto descritivo, e retorna a coluna livre
seguinte, para permitir encadear varios badges na mesma linha.
FWMSPrinter nao possui primitiva nativa de circulo/elipse preenchida
(somente Fillrect retangular) - o badge retangular e a aproximacao
visual usada para reproduzir os icones circulares coloridos do app.
@type function
@author Dennis Calabrez
@since 04/09/2026
@param nLin, numeric, Linha de impressao
@param nCol, numeric, Coluna inicial do badge
@param cCodigo, caracter, Codigo exibido dentro do badge (1 ou 2 letras)
@param cDescricao, caracter, Texto exibido apos o badge (vazio para omitir)
@param oBrush, objeto, TBrush com a cor do badge
@param nLargTxt, numeric, Largura reservada para o texto descritivo
@return nColProx, numeric, Coluna livre apos o badge (+texto), para o proximo item
/*/
//---------------------------------------------------------------------
Static Function LOCR043B(nLin as Numeric, nCol as Numeric, cCodigo as Character, cDescricao as Character, oBrush as Object, nLargTxt as Numeric) as Numeric
Local nLargBadge := 18 as Numeric
Local nAltBadge  := 12 as Numeric
Local nColProx   := 0 as Numeric

	oPrintPvt:Fillrect({nLin, nCol, nLin + nAltBadge, nCol + nLargBadge}, oBrush, "-2")
	oPrintPvt:SayAlign(nLin + 1, nCol, cCodigo, oFontRod, nLargBadge, nAltBadge, COR_BRANCO, PAD_CENTER, 0)

	nColProx := nCol + nLargBadge + 4

	If !Empty(cDescricao)
		oPrintPvt:SayAlign(nLin - 1, nColProx, cDescricao, oFontDet, nLargTxt, nTamLin, COR_PRETO, PAD_LEFT, 0)
		nColProx += nLargTxt + 10
	EndIf

Return nColProx

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043L
Imprime as legendas de respostas e de avarias, cada uma com um badge
colorido (mesma cor usada no questionario/galeria de fotos).
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043L()
Local nColAtu := nColIni as Numeric

	LOCR043P(60)

	oPrintPvt:SayAlign(nLinAtu, nColIni, STR0021, oFontDetN, 300, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Legenda respostas"
	nLinAtu += (nTamLin * 1.5)

	nColAtu := nColIni
	nColAtu := LOCR043B(nLinAtu, nColAtu, STR0023, STR0022, oBrushNA, 80) //"Nao se aplica" //"NA"
	nColAtu := LOCR043B(nLinAtu, nColAtu, STR0025 , STR0024     , oBrushC , 60) //"Conforme" //"C"
	nColAtu := LOCR043B(nLinAtu, nColAtu, STR0026, "Nao conforme" , oBrushNC, 80) //"NC"
	nLinAtu += (nTamLin * 2)

	oPrintPvt:SayAlign(nLinAtu, nColIni, STR0027, oFontDetN, 300, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Legenda avarias"
	nLinAtu += (nTamLin * 1.5)

	nColAtu := nColIni
	nColAtu := LOCR043B(nLinAtu, nColAtu, STR0029, STR0028, oBrushA, 60) //"Amassado" //"A"
	nColAtu := LOCR043B(nLinAtu, nColAtu, STR0031, STR0030   , oBrushF, 40) //"Falta" //"F"
	nColAtu := LOCR043B(nLinAtu, nColAtu, STR0033, STR0032   , oBrushP, 40) //"Pique" //"P"
	nColAtu := LOCR043B(nLinAtu, nColAtu, STR0035, STR0034, oBrushQ, 60) //"Quebrado" //"Q"
	nColAtu := LOCR043B(nLinAtu, nColAtu, STR0037, STR0036 , oBrushR, 55) //"Riscado" //"R"
	nColAtu := LOCR043B(nLinAtu, nColAtu, STR0039, STR0038, oBrushT, 60) //"Trincado" //"T"
	nLinAtu += (nTamLin * 2)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043Q
Consulta a FPX (itens do questionario do checklist atual, ultima
revisao de cada item) agrupada por topico/familia e imprime a tabela
de respostas. Tambem monta aFotosChk com a lista de fotos do banco de
conhecimento (AC9/ACB), usada por LOCR043G.
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043Q()
Local cQuery     := "" as Character
Local cAliasFPX  := GetNextAlias() as Character
Local aBindParam := {} as Array
Local cTopoAnt   := "*" as Character
Local cChaveIt   := "" as Character
Local aQtdFoto   := {} as Array
Local nPos       := 0 as Numeric
Local nQtdFotoIt := 0 as Numeric
Local nX         := 0 as Numeric
Local cStatIAAt  := "" as Character
Local cObsIAAt   := "" as Character
Local cCodFam    := "" as Character
Local cNomeSeq   := "" as Character
Local cCodFor    := "" as Character
	//monta a lista de fotos do checklist (banco de conhecimento) e a contagem por item
	LOCR043F()

	For nX := 1 To Len(aFotosChk)
		//"Cliente autorizado" (aFotosChk[nX][7]) nao e foto de item do questionario - fica
		//de fora da contagem por topico|item
		If !aFotosChk[nX][7]
			//Upper() para nao depender de a legenda da foto e o cadastro FPX baterem exatamente
			//na caixa (maiusculas/minusculas)
			cChaveIt := Upper(AllTrim(aFotosChk[nX][3])) + "|" + Upper(AllTrim(aFotosChk[nX][4])) //topico|item
			nPos := AScan(aQtdFoto, {|x| x[1] == cChaveIt})
			If nPos == 0
				AAdd(aQtdFoto, {cChaveIt, 0})
				nPos := Len(aQtdFoto)
			EndIf
			aQtdFoto[nPos][2]++
		EndIf
	Next nX

	//FPX_OBSIA e campo Memo - Memo nao vem confiavel via SELECT SQL puro (ChangeQuery/
	//MPSysOpenQuery); por isso FPX_STATIA/FPX_OBSIA sao lidos abaixo via Posicione() (mesmo
	//padrao ja usado em LOCA091.PRW para esta tabela), e nao entram no SELECT

	//itens do questionario: uma linha por topico+item (a mais recente, R_E_C_N_O_ desc)
	cQuery := " SELECT FPX.FPX_CODTOP CODTOP, FPX.FPX_NOMTOP NOMTOP, FPX.FPX_CODITE CODITE, "
	cQuery += "        FPX.FPX_NOMITE NOMITE, FPX.FPX_RESPOS RESPOS "
	cQuery += " FROM " + RetSqlName("FPX") + " FPX "
	cQuery += " WHERE FPX.FPX_FILIAL = ? "
	AAdd(aBindParam, FWxFilial("FPX"))
	cQuery += "   AND FPX.FPX_CODCHE = ? "
	AAdd(aBindParam, PadR(cCodCheAt, TamSX3("FPX_CODCHE")[1]))
	cQuery += "   AND FPX.D_E_L_E_T_ = ' ' "
	cQuery += "   AND FPX.R_E_C_N_O_ = (SELECT MAX(FPXM.R_E_C_N_O_) FROM " + RetSqlName("FPX") + " FPXM "
	cQuery += "                          WHERE FPXM.FPX_FILIAL = FPX.FPX_FILIAL AND FPXM.FPX_CODCHE = FPX.FPX_CODCHE "
	cQuery += "                            AND FPXM.FPX_CODTOP = FPX.FPX_CODTOP AND FPXM.FPX_CODITE = FPX.FPX_CODITE "
	cQuery += "                            AND FPXM.D_E_L_E_T_ = ' ') "
	cQuery += " ORDER BY FPX.FPX_CODTOP, FPX.FPX_CODITE "
	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, cAliasFPX, , , aBindParam)

	//Titulo unico da secao (igual ao app: "Questionario: <nomeSeq>"), com uma barra cinza por
	//topico abaixo (equivalente ao _topicSection de pdf_service.dart) - antes repetia
	//"Questionario: <NOMTOP>" a cada topico, o que nao reproduzia o layout original.
	//cNomeSeq = FPJ_NOMSEQ, mesmo campo usado como "Nome" do no "Seq" pelo endpoint
	//RetFormsApp (LOCW010.PRW:182), que e a fonte do "nomeSeq" do checklist no app; a
	//familia (FQC nao guarda FQC_CODFAM) e derivada do bem, igual ao RetFormsApp:98-102.
	cCodFam  := Posicione("ST9", 1, xFilial("ST9") + FQC->FQC_CODBEM, "T9_CODFAMI")
	//cNomeSeq := AllTrim(Posicione("FPJ", 1, xFilial("FPJ") + PadR(cCodFor, TamSX3("FPJ_CODFOR")[1]) + Alltrim(cCodFam) + FQC->FQC_SEQ, "FPJ_NOMSEQ"))

	LOCR043P(40)
	//If Empty(cNomeSeq)
		oPrintPvt:SayAlign(nLinAtu, nColIni, STR0040, oFontTitN, 400, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Questionario"
	//Else
	//	oPrintPvt:SayAlign(nLinAtu, nColIni, STR0041 + cNomeSeq, oFontTitN, 400, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Questionario: "
	//EndIf
	nLinAtu += (nTamLin * 1.8)

	(cAliasFPX)->(DbGoTop())
	While !(cAliasFPX)->(Eof())

		If AllTrim((cAliasFPX)->CODTOP) <> cTopoAnt
			cTopoAnt := AllTrim((cAliasFPX)->CODTOP)
			LOCR043P(40 + nTamLin)
			oPrintPvt:Fillrect({nLinAtu, nColIni, nLinAtu + nTamLin + 4, nColFin}, oBrush1, "-2")
			oPrintPvt:SayAlign(nLinAtu + 1, nColIni + 5, AllTrim((cAliasFPX)->NOMTOP), oFontDetN, 400, nTamLin, COR_PRETO, PAD_LEFT, 0)
			nLinAtu += (nTamLin * 1.5) + 4
		EndIf

		LOCR043P(nTamLin * 1.3)

		//a contagem em aQtdFoto foi montada a partir do nome do topico/item (unica informacao
		//disponivel na legenda da foto no banco de conhecimento); por isso a chave aqui usa
		//NOMTOP/NOMITE, e nao CODTOP/CODITE
		cChaveIt := Upper(AllTrim((cAliasFPX)->NOMTOP)) + "|" + Upper(AllTrim((cAliasFPX)->NOMITE))
		nPos := AScan(aQtdFoto, {|x| x[1] == cChaveIt})

		nQtdFotoIt := 0
		If nPos > 0
			nQtdFotoIt := aQtdFoto[nPos][2]
		EndIf

		//correlacao topico|item -> Status I.A./Observacao I.A. (FPX_STATIA/FPX_OBSIA), usada
		//por LOCR043G para exibir o mesmo status na legenda de cada foto do item. Posicione()
		//busca o campo pela chave sem alterar o registro/ordem atual da FPX - ver comentario
		//acima sobre o motivo de nao vir pela query
		cStatIAAt := AllTrim(Posicione("FPX", 1, FWxFilial("FPX") + cCodCheAt + (cAliasFPX)->CODTOP + (cAliasFPX)->CODITE, "FPX_STATIA"))
		cObsIAAt  := AllTrim(Posicione("FPX", 1, FWxFilial("FPX") + cCodCheAt + (cAliasFPX)->CODTOP + (cAliasFPX)->CODITE, "FPX_OBSIA"))
		AAdd(aStatIA, {cChaveIt, cStatIAAt, cObsIAAt})

		oPrintPvt:SayAlign(nLinAtu, COL_01 + 10, AllTrim((cAliasFPX)->NOMITE), oFontDet, 220, nTamLin, COR_PRETO, PAD_LEFT, 0)
		LOCR043B(nLinAtu, COL_03, LOCR043RD(AllTrim((cAliasFPX)->RESPOS)), "", LOCR043RB(LOCR043RD(AllTrim((cAliasFPX)->RESPOS))), 0)
		oPrintPvt:SayAlign(nLinAtu, COL_04, "Fotos: " + cValToChar(nQtdFotoIt), oFontDet, 100, nTamLin, COR_PRETO, PAD_LEFT, 0)

		nLinAtu += (nTamLin * 1.3)
		(cAliasFPX)->(DbSkip())
	EndDo

	(cAliasFPX)->(DbCloseArea())

	nLinAtu += (nTamLin * 0.5)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043RD
Traduz o codigo de resposta do item (C/NC/NA) para o texto exibido.
@type function
@author Dennis Calabrez
@since 01/09/2026
@param cResp, caracter, Codigo de resposta gravado na FPX
@return cDesc, caracter, Texto da resposta
/*/
//---------------------------------------------------------------------
Static Function LOCR043RD(cResp as Character) as Character
Local cDesc := "" as Character

	If cResp == "C"
		cDesc := "C"
	ElseIf cResp == "NC"
		cDesc := "NC"
	Else
		cDesc := "NA"
	EndIf

Return cDesc

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043RB
Retorna o TBrush (ja instanciado, um por cor possivel) associado ao
codigo de resposta, para nao recriar o objeto a cada foto da galeria.
@type function
@author Dennis Calabrez
@since 01/09/2026
@param cResp, caracter, Codigo de resposta: "C", "NC" ou "NA"
@return oBrush, objeto, Brush correspondente
/*/
//---------------------------------------------------------------------
Static Function LOCR043RB(cResp as Character) as Object
Local oBrush := oBrushNA as Object

	If cResp == "C"
		oBrush := oBrushC
	ElseIf cResp == "NC"
		oBrush := oBrushNC
	EndIf

Return oBrush

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043IB
Retorna o TBrush associado ao codigo de Status I.A. (FPX_STATIA), mesma
paleta de cores usada no grid MVC do checklist (LOCA091F/LOCA091G).
@type function
@author Dennis Calabrez
@since 04/09/2026
@param cStatIA, caracter, Codigo gravado em FPX_STATIA: "1" a "5"
@return oBrush, objeto, Brush correspondente
/*/
//---------------------------------------------------------------------
Static Function LOCR043IB(cStatIA as Character) as Object
Local oBrush := oBrushIA3 as Object

	Do Case
	Case cStatIA == "1"
		oBrush := oBrushIA1
	Case cStatIA == "2"
		oBrush := oBrushIA2
	Case cStatIA == "3"
		oBrush := oBrushIA3
	Case cStatIA == "4"
		oBrush := oBrushIA4
	Case cStatIA == "5"
		oBrush := oBrushIA5
	EndCase

Return oBrush

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043ID
Traduz o codigo de Status I.A. (FPX_STATIA) para a descricao exibida,
mesmo texto da legenda do grid MVC do checklist (LOCA091G).
@type function
@author Dennis Calabrez
@since 04/09/2026
@param cStatIA, caracter, Codigo gravado em FPX_STATIA: "1" a "5"
@return cDesc, caracter, Descricao do status
/*/
//---------------------------------------------------------------------
Static Function LOCR043ID(cStatIA as Character) as Character
Local cDesc := "" as Character

	Do Case
	Case cStatIA == "1"
		cDesc := STR0042 //"Danos Graves"
	Case cStatIA == "2"
		cDesc := STR0043 //"Desgaste Grande"
	Case cStatIA == "3"
		cDesc := STR0044 //"Desgaste Pequeno"
	Case cStatIA == "4"
		cDesc := STR0045 //"Pequenas Mudancas"
	Case cStatIA == "5"
		cDesc := STR0046 //"Melhorou ou Manteve"
	EndCase

Return cDesc

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043RP
Classifica o texto de resposta gravado na legenda da foto ("Conforme",
"Nao conforme" ou "Nao aplica", conforme LOCW002.PRW:306-312) no codigo
C/NC/NA. A comparacao e feita em minusculas, sem depender do acento em
"Nao", para nao exigir caractere acentuado literal no fonte.
@type function
@author Dennis Calabrez
@since 01/09/2026
@param cResp, caracter, Texto da resposta extraido da legenda da foto
@return cCod, caracter, Codigo da resposta: "C", "NC" ou "NA"
/*/
//---------------------------------------------------------------------
Static Function LOCR043RP(cResp as Character) as Character
Local cCod := "NA" as Character
Local cLow := Lower(AllTrim(cResp)) as Character

	If Left(cLow, 1) == "c"
		cCod := "C"
	ElseIf STR0047 $ cLow //"conforme"
		cCod := "NC"
	EndIf

Return cCod

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043OB
Extrai, do memo FPX_OBS (acumulado pelo LOCW026/CheckListIma), a
observacao gravada para uma foto especifica. O LOCW026 NAO grava JSON
valido no memo: a cada foto, concatena um bloco "{...}" (gerado por
LOCA091C) sem virgulas/colchetes entre eles, separados por CHR(13)+
CHR(10) duplicado. Por isso os blocos sao extraidos um a um (par de
chaves "{"/"}") e cada um e deserializado individualmente; o bloco cujo
"FPX_IMAGEM" bate com o nome fisico da foto e o que contem a observacao
dela (campo "FPX_OBS" dentro do bloco - nao confundir com o memo
FPX_OBS da tabela, nem com FPX_OBSIA, que e da IA).
@type function
@author Dennis Calabrez
@since 08/09/2026
@param cTextoObs, caracter, Conteudo do memo FPX_OBS do item
@param cArquivo, caracter, Nome fisico da foto (ACB_OBJETO)
@return cObsFoto, caracter, Observacao da foto, ou vazio se nao encontrada
/*/
//---------------------------------------------------------------------
Static Function LOCR043OB(cTextoObs as Character, cArquivo as Character) as Character
Local cObsFoto := "" as Character
Local nPos     := 1 as Numeric
Local nIni     := 0 as Numeric
Local nFim     := 0 as Numeric
Local cBloco   := "" as Character
Local oBloco   := Nil as Object

	While Empty(cObsFoto)
		nIni := At("{", SubStr(cTextoObs, nPos))
		If nIni == 0
			Exit
		EndIf
		nIni += nPos - 1

		nFim := At("}", SubStr(cTextoObs, nIni))
		If nFim == 0
			Exit
		EndIf
		nFim += nIni - 1

		cBloco := SubStr(cTextoObs, nIni, nFim - nIni + 1)
		If FWJsonDeserialize(cBloco, @oBloco)
			If ValType(oBloco:FPX_IMAGEM) == "C" .And. AllTrim(oBloco:FPX_IMAGEM) == AllTrim(cArquivo)
				cObsFoto := AllTrim(oBloco:FPX_OBS)
			EndIf
		EndIf

		nPos := nFim + 1
	EndDo

Return cObsFoto

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043F
Consulta o banco de conhecimento (AC9/ACB) do checklist atual, entidade
FPX, e monta aFotosChk com {arquivo, descricao, topico, item, resposta,
sequencia, lClienteAut, obsFoto}. Existem 2 fluxos de gravacao de foto
no app (confirmados no fonte, nao supostos):
- LOCW002/GeraCheckList (antigo): fotos enviadas juntas no payload do
  checklist. ACB_DESCRI = "FOTO <seq> - <Topico> - <Item> - <Resposta>"
  (texto legivel); topico/item/resposta vem dessa descricao.
- LOCW026/CheckListIma (atual, usado por
  current_checklist_provider.dart:buildImaUploads): fotos enviadas uma a
  uma, apos o checklist criado. ACB_DESCRI = FPX_FILIAL+FPX_CODCHE+
  FPX_CODTOP+FPX_CODITE+FPX_STATUS (chave crua, sem texto); topico/item
  vem do proprio AC9_CODENT (posicional), e a resposta/nomes vem da FPX
  (Posicione). A observacao dessa foto (campo "Observa" do app) fica
  num bloco JSON acrescentado ao memo FPX_OBS (ver LOCR043OB) - o app
  tambem envia um "datahora" por foto, mas o LOCW026 nunca le/grava esse
  campo, entao nao ha data por foto disponivel no Protheus.
Os dois fluxos sao distinguidos pelo prefixo "FOTO " em ACB_DESCRI, que
so o fluxo antigo grava.
Antes das fotos do questionario, inclui tambem a foto "Cliente
autorizado" (CHECKLIST_<codche>_CLIENTEAUTORIZADO.jpg, gravada pelo
LOCW002.PRW:140 na entidade FQC, nao FPX - por isso nao passa pelo AC9/
ACB abaixo), igual ao 1o item da galeria em pdf_service.dart
(buildChecklistPdf/gridPhotos).
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043F()
Local cChaveEnt := "" as Character
Local cCodEntPre:= "" as Character
Local aPartes   := {} as Array
Local cDescri   := "" as Character
Local cResp     := "" as Character
Local cRespCod  := "" as Character
Local cTopico   := "" as Character
Local cItem     := "" as Character
Local cRestante := "" as Character
Local nPosSep   := 0 as Numeric
Local nSeg      := 0 as Numeric
Local cArqCliAut:= "" as Character
Local cSufixo   := "" as Character
Local cCodTopAt := "" as Character
Local cCodIteAt := "" as Character
Local cChaveFPX := "" as Character
Local nTamTop   := 0 as Numeric
Local nTamIte   := 0 as Numeric
Local cObsFoto  := "" as Character

	cArqCliAut := "CHECKLIST_" + cCodCheAt + "_CLIENTEAUTORIZADO.jpg"
	If File(cPathBcoAt + cArqCliAut)
		AAdd(aFotosChk, {cArqCliAut, STR0048, "", "", "", Len(aFotosChk) + 1, .T., ""}) //"Cliente autorizado"
	EndIf

	AC9->(DbSetOrder(2)) //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
	ACB->(DbSetOrder(1)) //ACB_FILIAL+ACB_CODOBJ
	FPX->(DbSetOrder(1)) //FPX_FILIAL+FPX_CODCHE+FPX_CODTOP+FPX_CODITE+(FPX_STATUS ou FPX_STAT2)

	nTamTop := TamSX3("FPX_CODTOP")[1]
	nTamIte := TamSX3("FPX_CODITE")[1]

	//Espelha exatamente xGAppConhec (LOCW002.PRW:826-828): AC9_FILENT usa FWxFilial(cTab),
	//mas o prefixo dentro de AC9_CODENT usa xFilial("FPX") (sem o wrapper FW) - por isso as
	//duas chamadas abaixo nao sao a mesma funcao, isso e proposital.
	//AC9_CODENT nao tem necessariamente a mesma largura de FPX_CODCHE (e um campo generico
	//do banco de conhecimento, usado por varias entidades) - por isso a comparacao do loop
	//usa prefixo (Left) em vez de igualdade exata (==) do valor inteiro do campo, que falha
	//sempre que sobra espaco em branco (padding) alem do prefixo montado aqui.
	cChaveEnt  := "FPX" + FWxFilial("FPX")
	cCodEntPre := xFilial("FPX") + AllTrim(cCodCheAt)

	If AC9->(DbSeek(FWxFilial("AC9") + cChaveEnt + cCodEntPre))

		While !AC9->(Eof()) .And. AC9->(AC9_FILIAL + AC9_ENTIDA + AC9_FILENT) == (FWxFilial("AC9") + cChaveEnt) ;
				.And. Left(AllTrim(AC9->AC9_CODENT), Len(cCodEntPre)) == cCodEntPre

			If ACB->(DbSeek(FWxFilial("ACB") + AC9->AC9_CODOBJ))

				cDescri  := AllTrim(ACB->ACB_DESCRI)
				cObsFoto := ""

				If Left(cDescri, 5) == "FOTO "
					//fluxo antigo (LOCW002/GeraCheckList): separa manualmente pelo padrao " - "
					//(espaco-hifen-espaco), sem usar StrTokArr: quando o Topico ou o Item vem
					//gravado em branco (ex.: FPX_NOMTOP vazio), a string fica com separadores
					//consecutivos ("... -  - ...") e o StrTokArr descarta o campo vazio entre
					//eles, desalinhando todos os campos seguintes. SubStr/At preserva os campos
					//vazios, mantendo sempre os 4 segmentos nas posicoes corretas.
					aPartes := {}
					cRestante := cDescri
					For nSeg := 1 To 3
						nPosSep := At(" - ", cRestante)
						If nPosSep > 0
							AAdd(aPartes, SubStr(cRestante, 1, nPosSep - 1))
							cRestante := SubStr(cRestante, nPosSep + 3)
						Else
							AAdd(aPartes, cRestante)
							cRestante := ""
						EndIf
					Next nSeg
					AAdd(aPartes, cRestante)

					cResp := ""
					If Len(aPartes) >= 4
						cResp := AllTrim(aPartes[4])
					EndIf
					cRespCod := LOCR043RP(cResp)

					cTopico := ""
					If Len(aPartes) >= 2
						cTopico := AllTrim(aPartes[2])
					EndIf

					cItem := ""
					If Len(aPartes) >= 3
						cItem := AllTrim(aPartes[3])
					EndIf
				Else
					//fluxo atual (LOCW026/CheckListIma): ACB_DESCRI e a chave crua da FPX
					//(FPX_FILIAL+FPX_CODCHE+FPX_CODTOP+FPX_CODITE+FPX_STATUS); topico/item vem
					//do proprio AC9_CODENT (mesma chave, posicional), e nome/resposta vem da FPX
					cSufixo   := SubStr(AllTrim(AC9->AC9_CODENT), Len(cCodEntPre) + 1)
					cCodTopAt := SubStr(cSufixo, 1, nTamTop)
					cCodIteAt := SubStr(cSufixo, nTamTop + 1, nTamIte)
					//xFilial("FPX") acima (cCodEntPre) reconstroi a chave gravada dentro de
					//AC9_CODENT (ver comentario sobre xGAppConhec); FWxFilial("FPX") aqui e o
					//acesso direto a tabela FPX, mesmo padrao do restante do fonte (LOCR043Q)
					cChaveFPX := FWxFilial("FPX") + cCodCheAt + cCodTopAt + cCodIteAt

					cTopico  := AllTrim(Posicione("FPX", 1, cChaveFPX, "FPX_NOMTOP"))
					cItem    := AllTrim(Posicione("FPX", 1, cChaveFPX, "FPX_NOMITE"))
					cRespCod := LOCR043RD(AllTrim(Posicione("FPX", 1, cChaveFPX, "FPX_RESPOS")))

					//observacao especifica desta foto (campo "Observa" do app), gravada pelo
					//LOCW026 num bloco JSON acrescentado ao memo FPX_OBS do item - NAO e a
					//FPX_OBSIA (essa e da I.A. e ja e tratada em LOCR043Q/LOCR043G)
					cObsFoto := LOCR043OB(Posicione("FPX", 1, cChaveFPX, "FPX_OBS"), AllTrim(ACB->ACB_OBJETO))
				EndIf

				AAdd(aFotosChk, {;
					AllTrim(ACB->ACB_OBJETO),;
					cDescri,;
					cTopico,;
					cItem,;
					cRespCod,;
					Len(aFotosChk) + 1,;
					.F.,;
					cObsFoto;
				})

			EndIf

			AC9->(DbSkip())
		EndDo
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043G
Imprime a galeria de fotos do checklist (aFotosChk), no mesmo padrao de
leitura de arquivo fisico usado pelo LOCR037 (MV_DIRDOC+"co"+empresa+
"\shared\").
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043G()
Local nImgW    := 160 as Numeric
Local nImgH    := 120 as Numeric
Local nCapH    := 62 as Numeric //altura fixa reservada p/ badge resposta + badge Status I.A. + obs I.A. + obs da foto
Local nCol     := 0 as Numeric
Local nLinFoto := 0 as Numeric
Local nColFoto := 0 as Numeric
Local nX       := 0 as Numeric
Local nPosIA   := 0 as Numeric
Local cArqFoto := "" as Character
Local cLegFoto := "" as Character
Local cChaveIt := "" as Character
Local cStatIA  := "" as Character
Local cObsIA   := "" as Character
Local cObsFoto := "" as Character
Local oTamImg  := Nil as Object
Local lErroImg := .F. as Logical
Local lClienteAut := .F. as Logical

	If Len(aFotosChk) == 0
		Return
	EndIf

	LOCR043P(40)
	//pdf_service.dart escolhe entre "Fotos MOBILIZACAO"/"Fotos DESMOBILIZACAO" com
	//"ck.codForm == '02' && ck.statusBem == '20'" - mas current_checklist_provider.dart
	//so grava codForm como "1"/"2"/"3" (nunca "02", ha comentario explicito no fonte
	//proibindo isso), entao essa condicao nunca e verdadeira e o titulo no PDF do app e
	//sempre "Fotos MOBILIZACAO", em qualquer tipo de checklist - reproduzido aqui tal
	//qual (nao uma regra nova, e o comportamento real do gerador original)
	oPrintPvt:SayAlign(nLinAtu, nColIni, "Fotos MOBILIZACAO (" + cValToChar(Len(aFotosChk)) + ")", oFontTitN, 300, nTamLin, COR_PRETO, PAD_LEFT, 0)
	nLinAtu += (nTamLin * 1.8)

	For nX := 1 To Len(aFotosChk)
		nCol := (nX - 1) % 3
		nColFoto := nColIni + (nCol * (nImgW + 20))

		If nCol == 0
			LOCR043P(nImgH + nCapH + 10)
			nLinFoto := nLinAtu
		EndIf

		cArqFoto := aFotosChk[nX][1]
		lClienteAut := aFotosChk[nX][7]
		cLegFoto := AllTrim(aFotosChk[nX][4]) + " " + cValToChar(aFotosChk[nX][6])

		If File(cPathBcoAt + cArqFoto)
			//TBitmap():New() decodifica o arquivo fisico antes do SayBitmap - mesmo padrao do
			//LOCR037 (leitura do banco de conhecimento); sem isso o SayBitmap falha em
			//silencio para jpg/png e nada e desenhado.
			//Decodificacao roda dentro de Begin Sequence: no servidor (AppServer como
			//servico, sem sessao interativa) o decoder de imagem pode falhar/lancar erro
			//para determinados arquivos, o que interrompia a geracao do relatorio no meio
			//e resultava num PDF incompleto ("PDF nao pode ser exibido"). Com o Recover, uma
			//foto problematica so vira placeholder, sem derrubar o relatorio inteiro.
			lErroImg := .F.
			Begin Sequence
				oTamImg := TBitmap():New(01, 01,,,, cPathBcoAt + cArqFoto,,,,,,,,,,,,,)
				oTamImg:lAutoSize := .T.
				oPrintPvt:SayBitmap(nLinFoto, nColFoto, cPathBcoAt + cArqFoto, nImgW, nImgH)

			End Sequence

		Else
			oPrintPvt:Fillrect({nLinFoto, nColFoto, nLinFoto + nImgH, nColFoto + nImgW}, oBrush1, "-2")
			oPrintPvt:SayAlign(nLinFoto + (nImgH / 2), nColFoto, "[Imagem nao encontrada]", oFontDet, nImgW, nTamLin, COR_PRETO, PAD_CENTER, 0)
		EndIf

		If lClienteAut
			//"Cliente autorizado" (LOCW002.PRW:140) nao e um item do questionario - nao tem
			//resposta C/NC/NA nem Status I.A./Obs I.A. associados, igual ao 1o item de
			//gridPhotos em pdf_service.dart (sem badge, so a legenda com o titulo)
			oPrintPvt:SayAlign(nLinFoto + nImgH + 2, nColFoto, STR0048, oFontDetN, nImgW, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Cliente autorizado"
		Else
			//badge de resposta (C/NC/NA) no mesmo estilo de badge usado na legenda/questionario
			//(LOCR043B), em vez da barra colorida de fundo usada antes - visual consistente com
			//o questionario, conforme solicitado
			LOCR043B(nLinFoto + nImgH + 2, nColFoto, aFotosChk[nX][5], cLegFoto, LOCR043RB(aFotosChk[nX][5]), nImgW - 26)

			//correlaciona a foto (por topico|item) com o Status I.A./Observacao I.A. (FPX_STATIA/
			//FPX_OBSIA) montado por LOCR043Q; se o item nao tiver Status I.A. gravado, nada e
			//impresso aqui (o espaco fica reservado, mas em branco, para manter o grid alinhado)
			cChaveIt := Upper(AllTrim(aFotosChk[nX][3])) + "|" + Upper(AllTrim(aFotosChk[nX][4]))
			nPosIA := AScan(aStatIA, {|x| x[1] == cChaveIt})

			cStatIA := ""
			cObsIA  := ""
			If nPosIA > 0
				cStatIA := aStatIA[nPosIA][2]
				cObsIA  := aStatIA[nPosIA][3]
			EndIf

			If !Empty(cStatIA)
				LOCR043B(nLinFoto + nImgH + 14, nColFoto, cStatIA, LOCR043ID(cStatIA), LOCR043IB(cStatIA), nImgW - 26)
			EndIf

			If !Empty(cObsIA)
				oPrintPvt:SayAlign(nLinFoto + nImgH + 26, nColFoto, "Obs IA: " + cObsIA, oFontRod, nImgW, 18, COR_CINZAESC, PAD_LEFT, 0)
			EndIf

			//observacao da foto (campo "Observa" do app, gravada pelo LOCW026/CheckListIma no
			//memo FPX_OBS do item - ver LOCR043F/LOCR043OB); diferente da Obs IA acima
			cObsFoto := aFotosChk[nX][8]
			If !Empty(cObsFoto)
				oPrintPvt:SayAlign(nLinFoto + nImgH + 44, nColFoto, "Obs: " + cObsFoto, oFontRod, nImgW, 18, COR_PRETO, PAD_LEFT, 0)
			EndIf
		EndIf

		If nCol == 2 .Or. nX == Len(aFotosChk)
			nLinAtu := nLinFoto + nImgH + nCapH + 10
		EndIf
	Next nX

	nLinAtu += (nTamLin * 0.5)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043T
Imprime o texto de termos de aceite, observacao e o bloco de
assinatura (imagem da assinatura do cliente autorizado, lida do
arquivo fisico gravado pelo LOCW002).
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043T()
Local cArqAssin := "" as Character
Local nLinAssi  := 0 as Numeric
Local oTamImg   := Nil as Object
Local lErroAssi := .F. as Logical

	LOCR043P(120)
	oPrintPvt:SayAlign(nLinAtu, nColIni, STR0049, oFontTitN, 300, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Termos de Aceite"
	nLinAtu += (nTamLin * 1.5)

	//Alturas dos paragrafos justificados sao uma estimativa (dependem da fonte/DPI do
	//FWMSPrinter); conferir em impressao real e ajustar se o texto for cortado.
	oPrintPvt:SayAlign(nLinAtu, nColIni, STR0051 + AllTrim(FQC->FQC_PROJET) + STR0050, oFontDet, nColFin - nColIni, 90, COR_PRETO, PAD_JUSTIF, 0) //" firmado. (Quando o bem for um veiculo, inclusive assumo as infracoes de transito ocorridas no periodo de minha responsabilidade, conforme art. 257, paragrafos 7 e 8, do Codigo de Transito Brasileiro.)" //"Ao assinar este documento, declaro que recebi o bem em perfeitas condicoes de funcionamento e conservacao, com toda a documentacao em ordem, assumindo total responsabilidade por sua correta utilizacao. Respondo civilmente por eventuais danos morais e materiais causados a terceiros, por acao ou omissao, dolosa ou culposa (negligencia, imprudencia ou impericia), bem como pela autoria de quaisquer infracoes administrativas ou legais decorrentes do uso do bem durante o periodo em que estiver sob minha responsabilidade, nos termos do contrato "
	nLinAtu += 90

	oPrintPvt:SayAlign(nLinAtu, nColIni, STR0052, oFontDet, nColFin - nColIni, 30, COR_PRETO, PAD_JUSTIF, 0) //"Autorizo o envio de mensagens e e-mails inerentes ao contrato por meio do telefone/e-mail cadastrados neste termo."
	nLinAtu += (nTamLin * 4)

	If !Empty(FQC->FQC_OBS)
		oPrintPvt:SayAlign(nLinAtu, nColIni, STR0053, oFontDetN, 200, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Observacao"
		nLinAtu += nTamLin
		oPrintPvt:SayAlign(nLinAtu, nColIni, AllTrim(FQC->FQC_OBS), oFontDet, nColFin - nColIni, 40, COR_PRETO, PAD_JUSTIF, 0)
		nLinAtu += (nTamLin * 5)
	EndIf

	LOCR043P(140)
	nLinAssi := nLinAtu

	oPrintPvt:SayAlign(nLinAssi, COL_01, STR0054, oFontDetN, 200, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Assinatura Cliente"
	oPrintPvt:SayAlign(nLinAssi, COL_03, STR0055, oFontDetN, 200, nTamLin, COR_PRETO, PAD_LEFT, 0) //"Vistoriador"

	cArqAssin := "CHECKLIST_" + cCodCheAt + "_ASSINATURACLIENTEAUTORIZADO.jpg"
	If File(cPathBcoAt + cArqAssin)
		//TBitmap():New() decodifica o arquivo fisico antes do SayBitmap - mesmo padrao do
		//LOCR037 (leitura do banco de conhecimento); sem isso o SayBitmap falha em silencio
		//para jpg/png e nada e desenhado.
		//Ver comentario equivalente em LOCR043G: decodificacao protegida com Begin
		//Sequence para uma falha aqui nao interromper a geracao do PDF inteiro.
		lErroAssi := .F.
		Begin Sequence
			oTamImg := TBitmap():New(01, 01,,,, cPathBcoAt + cArqAssin,,,,,,,,,,,,,)
			oTamImg:lAutoSize := .T.
			oPrintPvt:SayBitmap(nLinAssi + nTamLin, COL_01, cPathBcoAt + cArqAssin, 160, 80)
		End Sequence

	Else
		oPrintPvt:SayAlign(nLinAssi + nTamLin, COL_01, "[Assinatura nao localizada]", oFontDet, 200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	EndIf

	//O vistoriador e o usuario logado no app que realizou a vistoria (FQC_NOMUSF/FQC_LOGPOF).
	//Os dados do cliente autorizado (FQC_CLIAUT/CNHAUT/EMAAUT/CELAUT) ja aparecem em
	//"Responsavel", no bloco Dados Principais - nao devem ser repetidos aqui.
	oPrintPvt:SayAlign(nLinAssi + nTamLin, COL_03, "Nome: " + AllTrim(FQC->FQC_NOMUSF), oFontDet, 220, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLinAssi + (nTamLin * 2), COL_03, "Login: " + AllTrim(FQC->FQC_LOGPOF), oFontDet, 220, nTamLin, COR_PRETO, PAD_LEFT, 0)

	nLinAtu := nLinAssi + (nTamLin * 7)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR043R
Imprime o rodape (data/usuario/pagina) e fecha a pagina atual.
@type function
@author Dennis Calabrez
@since 01/09/2026
/*/
//---------------------------------------------------------------------
Static Function LOCR043R()
Local nLinRod   := nLinFin + nTamLin
Local cTxtEsq   := "" as Character
Local cTxtDir   := "" as Character

	oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, COR_CINZA)
	nLinRod += 3

	cTxtEsq := DtoC(dDataGer) + "    " + cHoraGer + "    LOCR043    " + cNomeUsr
	cTxtDir := "Pagina " + cValToChar(nPagAtu)

	oPrintPvt:SayAlign(nLinRod, nColIni, cTxtEsq, oFontRod, 300, nTamLin, COR_CINZA, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLinRod, nColFin - 60, cTxtDir, oFontRod, 60, nTamLin, COR_CINZA, PAD_RIGHT, 0)

	oPrintPvt:EndPage()
	nPagAtu++

Return
