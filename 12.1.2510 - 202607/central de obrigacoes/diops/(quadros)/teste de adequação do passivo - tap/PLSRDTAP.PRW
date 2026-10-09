#Include 'Protheus.ch'
#Include 'PLSRDIP.ch'
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
#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt10C := TFont():New("Arial",10,10,,.F., , , , .t., .f.)
STATIC oFnt10N := TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt10L := TFont():New("MS LineDraw Regular",10,10,,.F., , , , .t., .f.)
STATIC oFnt10T := TFont():New("MS LineDraw Regular",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N := TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt12C := TFont():New("Arial",12,12,,.F., , , , .t., .f.)
STATIC oFnt12N := TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt09C := TFont():New("Arial",09,09,,.F., , , , .t., .f.)
STATIC oFnt14N := TFont():New("Arial",14,14,,.T., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDTAP

Relatório do Quadro Adequação do Passivo - TAP

@author lima.everton
@since 22/01/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDTAP(lTodosQuadros, lAuto)

	Local aSays		:= {}
	Local aButtons	:= {}
	Local cCadastro := "DIOPS - Teste Adequação do Passivo - TAP"
	Local aResult	:= {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto         := .F.

	If !lTodosQuadros
		Private cPerg	  := "DIOPSINT"
		PRIVATE cTitulo   := cCadastro
		PRIVATE oReport   := nil
		PRIVATE cFileName := "DIOPS_Modelo_Padrao_Capital_"+CriaTrab(NIL,.F.)
		PRIVATE nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

		If lAuto
			Pergunte(cPerg,.F.)
		Endif

		oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,lAuto,.f.,.f.,!lAuto)
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

	Processa( {|| aResult := PLSDTAP() }, "DIOPS - Teste Adequação do Passivo - TAP")

	// Se não há dados a apresentar
	If !aResult[1]
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Teste Adequação do Passivo - TAP')
		Endif
		Return
	EndIf

	cTitulo 	:= "Teste Adequação do Passivo - TAP"
	PlsRDCab(cTitulo)  // Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTTAP(aResult[2]) //Recebe Resultado da Query e Monta Relatório

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return

Static Function PRINTTAP(aValores)

	Local lRet		:= .T.
	Local nLinha	:= 105
	Local aTotal	:= { { 0, 0, 0 }, { 0,0,0 }, { 0,0,0 } }
	Local cMsgCabec	:= "Teste Adequação do Passivo - TAP"
	Local lTemItem  := Len(aValores) > 0
	Local nI        := 0

	If nLinha >= 580
		oReport:EndPage()
		PlsRDCab(cMsgCabec)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
		nLinha	:= 110
		//Cabec1(@nLinha) Função não existe, mas como fixa 105 para o nLinha, não deverá entrar aqui.
	EndIf

	//Primeira linha
	oReport:box(nLinha, 020, nLinha+35, 805)
	oReport:box(nLinha, 220, nLinha+35, 805)
	oReport:Say(nLinha+30, 023 , "Agregação de contratos utilizada no teste", oFnt10T)

	oReport:box(nLinha, 220, nLinha+35, 805)
	oReport:box(nLinha, 353, nLinha+35, 805)
	oReport:Say(nLinha+20, 223 , "Ajuste na tábua biométrica", oFnt10T)
	oReport:Say(nLinha+30, 223 , "(sim ou não)", oFnt10T)

	oReport:box(nLinha, 353, nLinha+35, 805)
	oReport:box(nLinha, 475, nLinha+35, 805)
	oReport:Say(nLinha+10, 356, "Taxa de cancelamento de", oFnt10T)
	oReport:Say(nLinha+20, 356, "contratos* (valor em", oFnt10T)
	oReport:Say(nLinha+30, 356, "percentual)", oFnt10T)

	oReport:box(nLinha, 470, nLinha+35, 805)
	oReport:box(nLinha, 620, nLinha+35, 805)
	oReport:Say(nLinha+10, 473, "Inflação Médica estimada para", oFnt10T)
	oReport:Say(nLinha+20, 473, "o primeiro ano de apuração do", oFnt10T)
	oReport:Say(nLinha+30, 473, "TAP (valor em percentual)", oFnt10T)

	oReport:box(nLinha, 620, nLinha+35, 805)
	oReport:box(nLinha, 805, nLinha+35, 805)
	oReport:Say(nLinha+10, 623, "Reajuste máximo estimado para os", oFnt10T)
	oReport:Say(nLinha+20, 623, "planos individuais no primeiro ano de", oFnt10T)
	oReport:Say(nLinha+30, 623, "apuração do TAP (valor em percentual)", oFnt10T)

	//Segunda linha
	nLinha+=35

	oReport:box(nLinha, 020, nLinha+15, 805)
	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:Say(nLinha+10, 023 , "Carteira individual", oFnt10L)

	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:box(nLinha, 353, nLinha+15, 805)

	For nI:=1 to 1
		If Len(aValores)>=1 .And. LEN(aValores[nI])>1
			oReport:Say(nLinha+10, 223, IIf(lTemItem, IIf(aValores[nI,2] == "0", "Não","Sim"),""), oFnt10L)
			oReport:box(nLinha, 353, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:Say(nLinha+10, 390, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,3])),16),""), oFnt10L)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:Say(nLinha+10, 540, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,4])),16),""), oFnt10L)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)
			oReport:Say(nLinha+10, 725, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,5])),16),""), oFnt10L)
		Else
			oReport:box(nLinha, 353, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)

		EndIf
	Next

	//Terceira linha
	nLinha+=15

	oReport:box(nLinha, 020, nLinha+15, 805)
	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:Say(nLinha+10, 023 , "Coletivo por adesão", oFnt10L)

	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:box(nLinha, 353, nLinha+15, 805)

	For nI:=2 To 2
		If Len(aValores)>=2 .And. LEN(aValores[nI])>1
			oReport:Say(nLinha+10, 223, IIf(lTemItem, IIf(aValores[nI,2] == "0", "Não","Sim"),""), oFnt10L)
			oReport:box(nLinha, 353, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:Say(nLinha+10, 390, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,3])),16),""), oFnt10L)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:Say(nLinha+10, 540, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,4])),16),""), oFnt10L)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)
			oReport:Say(nLinha+10, 725, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,5])),16),""), oFnt10L)
		Else
			oReport:box(nLinha, 353, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)
		EndIf
	Next

	//Quarta linha
	nLinha+=15

	oReport:box(nLinha, 020, nLinha+15, 805)
	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:Say(nLinha+10, 023 , "Coletivo empresarial", oFnt10L)

	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:box(nLinha, 353, nLinha+15, 805)

	For nI:=3 to 3
		If Len(aValores)>=3 .And. LEN(aValores[nI])>1
			oReport:Say(nLinha+10, 223, IIf(lTemItem, IIf(aValores[nI,2] == "0", "Não","Sim"),""), oFnt10L)
			oReport:box(nLinha, 353, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:Say(nLinha+10, 390, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,3])),16),""), oFnt10L)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:Say(nLinha+10, 540, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,4])),16),""), oFnt10L)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)
			oReport:Say(nLinha+10, 725, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,5])),16),""), oFnt10L)
		Else
			oReport:box(nLinha, 353, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)

		EndIf
	Next
	//Quinta linha
	nLinha+=15

	oReport:box(nLinha, 020, nLinha+25, 805)
	oReport:box(nLinha, 220, nLinha+25, 805)
	oReport:Say(nLinha+10, 023 , "Corresponsabilidade assumida em", oFnt10L)
	oReport:Say(nLinha+20, 023 , "pré-pagamento", oFnt10L)

	oReport:box(nLinha, 220, nLinha+25, 805)
	oReport:box(nLinha, 353, nLinha+25, 805)

	For nI:=4 To 4
		If Len(aValores)>=4 .And. LEN(aValores[nI])>1
			oReport:Say(nLinha+20, 223, IIf(lTemItem, IIf(aValores[nI,2] == "0", "Não","Sim"),""), oFnt10L)
			oReport:box(nLinha, 353, nLinha+25, 805)
			oReport:box(nLinha, 470, nLinha+25, 805)
			oReport:Say(nLinha+20, 390, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,3])),16),""), oFnt10L)
			oReport:box(nLinha, 470, nLinha+25, 805)
			oReport:box(nLinha, 620, nLinha+25, 805)
			oReport:Say(nLinha+20, 540, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,4])),16),""), oFnt10L)
			oReport:box(nLinha, 620, nLinha+25, 805)
			oReport:box(nLinha, 805, nLinha+25, 805)
			oReport:Say(nLinha+20, 725, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,5])),16),""), oFnt10L)
		Else
			oReport:box(nLinha, 353, nLinha+25, 805)
			oReport:box(nLinha, 470, nLinha+25, 805)
			oReport:box(nLinha, 470, nLinha+25, 805)
			oReport:box(nLinha, 620, nLinha+25, 805)
			oReport:box(nLinha, 620, nLinha+25, 805)
			oReport:box(nLinha, 805, nLinha+25, 805)

		EndIf
	Next

	nLinha+=40

	/*
        Quadro inferior
	*/

	//Primeira linha
	oReport:box(nLinha, 020, nLinha+55, 805)
	oReport:box(nLinha, 220, nLinha+55, 805)
	oReport:Say(nLinha+50, 023 , "Agregação de contratos utilizada no teste", oFnt10T)

	oReport:box(nLinha, 220, nLinha+55, 805)
	oReport:box(nLinha, 358, nLinha+55, 805)
	oReport:Say(nLinha+10, 223 , "Reajuste médio por variação", oFnt10T)
	oReport:Say(nLinha+20, 223 , "de custos estimado para os", oFnt10T)
	oReport:Say(nLinha+30, 223 , "planos coletivos no primeiro", oFnt10T)
	oReport:Say(nLinha+40, 223 , "ano de apuração do TAP", oFnt10T)
	oReport:Say(nLinha+50, 223 , "(valor em percentual)", oFnt10T)

	oReport:box(nLinha, 358, nLinha+55, 805)
	oReport:box(nLinha, 470, nLinha+55, 805)
	oReport:Say(nLinha+10, 362, "Utilização das faixas", oFnt10T)
	oReport:Say(nLinha+20, 362, "etárias da RN 63/2003", oFnt10T)
	oReport:Say(nLinha+30, 362, "para estimação das", oFnt10T)
	oReport:Say(nLinha+40, 362, "despesas assistenciais", oFnt10T)
	oReport:Say(nLinha+50, 362, "(sim ou não)", oFnt10T)

	oReport:box(nLinha, 470, nLinha+55, 805)
	oReport:box(nLinha, 620, nLinha+55, 805)
	oReport:Say(nLinha+40, 473, "Método de interpolação da", oFnt10T)
	oReport:Say(nLinha+50, 473, "ETTJ utilizado", oFnt10T)

	oReport:box(nLinha, 620, nLinha+55, 805)
	oReport:box(nLinha, 805, nLinha+55, 805)
	oReport:Say(nLinha+40, 623, "Estimativa corrente de fluxo de caixa", oFnt10T)
	oReport:Say(nLinha+50, 623, "na data-base (valor em R$)", oFnt10T)

	//Segunda linha
	nLinha+=55

	oReport:box(nLinha, 020, nLinha+15, 805)
	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:Say(nLinha+10, 023 , "Carteira individual", oFnt10L)

	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:box(nLinha, 358, nLinha+15, 805)

	For nI:=1 To 1
		If Len(aValores)>=1 .And. LEN(aValores[nI])>1
			oReport:Say(nLinha+10, 280, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,6])),16),""), oFnt10L)
			oReport:box(nLinha, 358, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:Say(nLinha+10, 362, IIf(lTemItem, IIf(aValores[nI,7] == "0", "Não","Sim"), ""), oFnt10L)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:Say(nLinha+10, 473, IIf(lTemItem, aValores[nI,8],""), oFnt10L)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)
			oReport:Say(nLinha+10, 700, IIf(lTemItem, PadL(Transform(aValores[nI,9], Moeda),20), ""), oFnt10L)

		Else

			oReport:box(nLinha, 358, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)
		EndIf
	Next
	//Terceira linha
	nLinha+=15

	oReport:box(nLinha, 020, nLinha+15, 805)
	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:Say(nLinha+10, 023 , "Coletivo por adesão", oFnt10L)

	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:box(nLinha, 358, nLinha+15, 805)

	For nI:=2 to 2
		If Len(aValores)>=2 .And. LEN(aValores[nI])>1
			oReport:Say(nLinha+10, 280, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,6])),16),""), oFnt10L)
			oReport:box(nLinha, 358, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:Say(nLinha+10, 362, IIf(lTemItem, IIf(aValores[nI,7] == "0", "Não","Sim"), ""), oFnt10L)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:Say(nLinha+10, 473, IIf(lTemItem, aValores[nI,8],""), oFnt10L)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)
			oReport:Say(nLinha+10, 700, IIf(lTemItem, PadL(Transform(aValores[nI,9], Moeda),20), ""), oFnt10L)
		Else
			oReport:box(nLinha, 358, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)

		EndIF
	Next
	//Quarta linha
	nLinha+=15

	oReport:box(nLinha, 020, nLinha+15, 805)
	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:Say(nLinha+10, 023 , "Coletivo empresarial", oFnt10L)

	oReport:box(nLinha, 220, nLinha+15, 805)
	oReport:box(nLinha, 358, nLinha+15, 805)

	For nI:=3 to 3
		If Len(aValores)>=3 .And. LEN(aValores[nI])>1
			oReport:Say(nLinha+10, 280, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,6])),16),""), oFnt10L)
			oReport:box(nLinha, 358, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:Say(nLinha+10, 362, IIf(lTemItem, IIf(aValores[nI,7] == "0", "Não","Sim"), ""), oFnt10L)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:Say(nLinha+10, 473, IIf(lTemItem, aValores[nI,8],""), oFnt10L)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)
			oReport:Say(nLinha+10, 700, IIf(lTemItem, PadL(Transform(aValores[nI,9], Moeda),20), ""), oFnt10L)
		Else
			oReport:box(nLinha, 358, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 470, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 620, nLinha+15, 805)
			oReport:box(nLinha, 805, nLinha+15, 805)

		EndIf
	Next
	//Quinta linha
	nLinha+=15

	oReport:box(nLinha, 020, nLinha+25, 805)
	oReport:box(nLinha, 220, nLinha+25, 805)
	oReport:Say(nLinha+10, 023 , "Corresponsabilidade assumida em", oFnt10L)
	oReport:Say(nLinha+20, 023 , "pré-pagamento", oFnt10L)

	oReport:box(nLinha, 220, nLinha+25, 805)
	oReport:box(nLinha, 358, nLinha+25, 805)
	For nI:=4 to 4
		If Len(aValores)>=4 .And. LEN(aValores[nI])>1
			oReport:Say(nLinha+20, 280, IIf(lTemItem, PadL(AllTrim(Str(aValores[nI,6])),16),""), oFnt10L)

			oReport:box(nLinha, 358, nLinha+25, 805)
			oReport:box(nLinha, 470, nLinha+25, 805)
			oReport:Say(nLinha+20, 362, IIf(lTemItem, IIf(aValores[nI,7] == "0", "Não","Sim"), ""), oFnt10L)

			oReport:box(nLinha, 470, nLinha+25, 805)
			oReport:box(nLinha, 620, nLinha+25, 805)
			oReport:Say(nLinha+20, 473, IIf(lTemItem, aValores[nI,8],""), oFnt10L)

			oReport:box(nLinha, 620, nLinha+25, 805)
			oReport:box(nLinha, 805, nLinha+25, 805)
			oReport:Say(nLinha+20, 700, IIf(lTemItem, PadL(Transform(aValores[nI,9], Moeda),20), ""), oFnt10L)
		Else
			oReport:box(nLinha, 358, nLinha+25, 805)
			oReport:box(nLinha, 470, nLinha+25, 805)
			oReport:box(nLinha, 470, nLinha+25, 805)
			oReport:box(nLinha, 620, nLinha+25, 805)
			oReport:box(nLinha, 620, nLinha+25, 805)
			oReport:box(nLinha, 805, nLinha+25, 805)

		EndIF
	Next
Return lRet

Static Function PLSDTAP()

	Local nCount	:= 0
	Local aRetTAP	:= 	{}
	Local cSql 		:= ""
	Local lRet 		:= .T.
	Local aAux      := {}
	Local nPos        := 0

	cSql := " SELECT B89_TIPPLA, B89_AJUTAB, B89_TXCANC, B89_INFMED, B89_REAMAX, B89_REACUS, B89_FAIETA, B89_METINT, B89_ESTFLX "
	cSql += " FROM " + RetSqlName("B89")
	cSql += " WHERE B89_FILIAL = '" + xFilial("B89") + "' "
	cSql += " AND B89_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B89_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B89_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B89_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND B89_TIPPLA IN ('CID','CAD','CEM','CAP') "
	cSql += " AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBTAP",.F.,.T.)
	TcSetField("TRBTAP", "B89_ESTFLX",  "N", 16, 2 )

	If !TRBTAP->(Eof())
		TRBTAP->(dbGoTop())
		Do While !TRBTAP->(Eof())
			nCount++
			aAdd( aRetTAP, { TRBTAP->B89_TIPPLA, TRBTAP->B89_AJUTAB, TRBTAP->B89_TXCANC, TRBTAP->B89_INFMED, TRBTAP->B89_REAMAX, TRBTAP->B89_REACUS, TRBTAP->B89_FAIETA, TRBTAP->B89_METINT, TRBTAP->B89_ESTFLX } )
			TRBTAP->(DbSkip())
		EndDo
	EndIf
	TRBTAP->(DbCloseArea())

	If Len(aRetTAP)>0

		nPos:=Ascan(aRetTAP,{ |x| x[1] == "CID"})
		If nPos > 0
			AADD(aAux,aRetTAP[nPos])
		Else
			AADD(aAux,{"CID"})
		EndIF

		nPos:=Ascan(aRetTAP,{ |x| x[1] == "CAD"})
		If nPos > 0
			AADD(aAux,aRetTAP[nPos])
		Else
			AADD(aAux,{"CAD"})
		EndIf

		nPos:=Ascan(aRetTAP,{ |x| x[1] == "CEM"})
		If nPos > 0
			AADD(aAux,aRetTAP[nPos])
		Else
			AADD(aAux,{"CEM"})
		EndIf

		nPos:=Ascan(aRetTAP,{ |x| x[1] == "CAP"})
		If nPos > 0
			AADD(aAux,aRetTAP[nPos])
		Else
			AADD(aAux,{"CAP"})
		EndIf

	EndIF

	If Len(aAux)>0
		aRetTAP:=aClone(aAux)
	EndIf

Return( { nCount > 0 , aRetTAP } )
