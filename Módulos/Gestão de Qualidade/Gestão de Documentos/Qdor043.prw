#INCLUDE "QDOR043.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "REPORT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOR043   ºAutor  ³Leandro Sabino      º Data ³  03/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Relatorio de Lista de Documentos                 º±±
±±º          ³ (Versao Relatorio Personalizavel)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QDOR043()

	Local oReport := ReportDef()

	Pergunte("QDR042",.F.)
	oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 03/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR043                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local cDesc1    := OemToAnsi(STR0002) // "Este programa ir  imprimir uma rela‡„o dos documentos, com "
Local cDesc2    := OemToAnsi(STR0003) // "a quantidade de copias distribuidas com os respectitivos"
Local cDesc3    := OemToAnsi(STR0004) // "departamentos recebedores."
Local cTitulo   := OemToAnsi(STR0001) // "LISTA DE DOCUMENTO X DEPARTAMENTOS"
Local oSection1 := Nil

DEFINE REPORT oReport NAME "QDOR043" TITLE cTitulo PARAMETER "QDR042" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2+cDesc3)

DEFINE SECTION oSection1 OF oReport TABLES "QDH" TITLE OemToAnsi(STR0012)
DEFINE CELL NAME "QDH_DOCTO"  OF oSection1 ALIAS "QDH" SIZE 18
DEFINE CELL NAME "QDH_RV"     OF oSection1 ALIAS "QDH" 
DEFINE CELL NAME "QDH_TITULO" OF oSection1 ALIAS "QDH" SIZE 88 PICTURE "" LINE BREAK
DEFINE CELL NAME "cNCopia"    OF oSection1 ALIAS "  " TITLE OemToAnsi(STR0010) SIZE 04 //"Copias"
DEFINE CELL NAME "cDepto"     OF oSection1 ALIAS "  " TITLE OemToAnsi(STR0011) SIZE 44 //"Departamento"
oSection1:Cell("cDepto"):SeTLineBREAK(.T.)
DEFINE CELL NAME "nCopDepto"  OF oSection1 ALIAS "  " TITLE OemToAnsi(STR0013) SIZE 16 LINE BREAK //"Copias/Depto"

Return oReport
                             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 03/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR043                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport) 

Local aDeptos   := {}
Local cFilQDH   := xFilial("QDH")
Local cFiltro   := ""
Local lList     := .T.
Local nCopDepto := Nil
Local nCopia    := 0
Local nI        := 0
Local nP        := 0
Local nUlt      := 1
Local oSection1 := oReport:Section(1)

DbSelectArea("QDH")
DbSetOrder(1)

DbSelectArea("QDG")
DbSetOrder(1)

DbSelectArea("QAD")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Imprime Documento Interno/Externo/Ambos  						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01	== 2
	cFiltro:= 'QDH_DTOIE == "I" .AND.'
Elseif mv_par01 == 3
	cFiltro:= 'QDH_DTOIE == "E" .AND.'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Impressao de Doc. sera Vigente/Obsoleto/Cancelado/Todos-Cancelado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par02	== 1   // Vigente
	cFiltro+='QDH_CANCEL<>"S".And. QDH_OBSOL<>"S".And.QDH_STATUS = "L  "'
Elseif mv_par02 == 2   // Obsoleto
	cFiltro+='QDH_CANCEL <> "S" .And. QDH_OBSOL == "S"'
Elseif mv_par02 == 3   // Cancelado
	cFiltro+='QDH_CANCEL == "S"'
ElseIf mv_par02 == 4   // Todas Revisoes
	cFiltro+='QDH_CANCEL <> "S"'
EndIf

oSection1:SetFilter(cFiltro)

QDH->(dbGoTop())

oSection1:Init()

QDH->(DbSeek(cFilQDH))
While !oReport:Cancel() .And. QDH->(!Eof()) .And. QDH->QDH_FILIAL == cFilQDH

	lList  :=.T.
	cDepto := " "
	nCopia := 0

	If QDG->(DbSeek(xFilial("QDG")+QDH->QDH_DOCTO+QDH->QDH_RV))
		aDeptos := {}          
		nCopDepto := 0
 	    nUlt      := 1
		
		While QDG->(!Eof()) .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == xFilial("QDG")+QDH->QDH_DOCTO+QDH->QDH_RV
			If QDG->QDG_SIT <> "I" .And. QDG->QDG_TPRCBT <> "4"
				nCopia := nCopia + QDG->QDG_NCOP
				nCopDepto := QDG->QDG_NCOP
			Endif
			If( nP := Ascan( aDeptos, {|x| x[1] == QDG->QDG_DEPTO} ) ) == 0
				If Empty(AllTrim(xFilial("QAD")))
					QAD->(DbSeek(xFilial("QAD")+QDG->QDG_DEPTO))
				Else
					QAD->(DbSeek(QDG->QDG_FILMAT+QDG->QDG_DEPTO))
				EndIf
				Aadd( aDeptos, { QDG->QDG_DEPTO,QAD->QAD_DESC,StrZero(nCopDepto,4)})				
				nUlt := len(aDeptos)
			Else
				nUlt := Ascan( aDeptos, {|x| x[1] == QDG->QDG_DEPTO} )
				
				aDeptos[nUlt,3]:= If(Val(aDeptos[nUlt,3]) > 0, StrZero(Val(aDeptos[nUlt,3])+nCopDepto,4), StrZero(nCopDepto,4))				
			Endif
			cDoc := QDG->QDG_DOCTO
			QDG->(DbSkip())
			If aDeptos[nUlt,1] <> QDG->QDG_DEPTO .or. cDoc <> QDG->QDG_DOCTO
				nCopDepto := 0	
			Endif
		EndDo
	Endif
   
    oSection1:Cell("cNCopia"):SetValue(StrZero(nCopia,4))

	If Len( aDeptos ) > 0
		For nI:= 1 to Len( aDeptos ) 
			If nI=1 
				oSection1:Cell("cNCopia"):Show()
				oSection1:Cell("QDH_DOCTO"):Show()
				oSection1:Cell("QDH_RV"):Show()
				oSection1:Cell("QDH_TITULO"):Show()
			Else
				oSection1:Cell("cNCopia"):Hide()
				oSection1:Cell("QDH_DOCTO"):Hide()
				oSection1:Cell("QDH_RV"):Hide()
				oSection1:Cell("QDH_TITULO"):Hide()
			Endif
			oSection1:Cell("cDepto"):Show()
			oSection1:Cell("cDepto"):SetValue(Alltrim(aDeptos[nI,1])+" - "+Alltrim(aDeptos[nI,2]))							
			oSection1:Cell("nCopDepto"):SetValue(Space(2) + aDeptos[nI,3])
			oSection1:PrintLine()
		Next nI
	Else
		oSection1:Cell("cDepto"):Hide()
		oSection1:PrintLine()
	EndIf
	oReport:SkipLine(1) 
	oReport:ThinLine()
	
   	QDH->(DbSkip())

EndDo

oSection1:Finish()

Return NIL
