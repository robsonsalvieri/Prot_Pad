#include "FWMBROWSE.CH"
#include "QIEC030.CH"
#include "TOTVS.CH"

/* {Protheus.doc} Qiec030  Consultas - Entradas Inspecionadas
@author   Marcelo Pimentel  @since    06/05/1998
@type  Function
@note  Modulo SIGAQIE - Inspeccao de Entradas
@note  Historico de alteracoes:
@note  19/04/1999 (Vera) - Inclusao da Loja do Fornecedor
@note  18/02/2000 (Vera) - Filtra Entradas pelo campo QEK_VERIFI = 1
@note  24/01/2001 (Paulo Emidio) - Correcao na abertura dos indices temporarios atraves da funcao IndRegua
@note  11/06/2001 (Paulo Emidio) - Incluida a opcao para selecionar o tipo de Entrada a ser considerada (Normal, Beneficiamento, Devolucao)
*/
Static Function MenuDef()

	Local lPageAction := .T.
	Local aRotina     := {{OemToAnsi(STR0001),"AxPesqui"	,	0 , 1},; 			 //"Pesquisar"
					      {OemToAnsi(STR0002),"a030IMP" , 0, 8,,,,,,   lPageAction}} //"Imprimir"

Return aRotina

Function QIEC030()

	// Define Variaveis
	Local aSitEnt    := {}
	Local lLegSmartX := .F.
	Local oAuxLeg    := Nil

	Private cFilDef := " "
	Private cFilSQL := ""
	Private cFiltro := " "
	Private Inclui  := .T.

	// Recupera o desenho padrao de atualizacoes
	cCadastro := OemToAnsi(STR0003) // STR0003 - "Entradas inspecionadas"

	/*
	 Define Array contendo as Rotinas a executar do programa 
	 ----------- Elementos contidos por dimensao ------------
	 1. Nome a aparecer no cabecalho                         
	 2. Nome da Rotina associada                             
	 3. Usado pela rotina                                    
	 4. Tipo de Transa‡„o a ser efetuada                     
	    1 - Pesquisa e Posiciona em um Banco de Dados        
	    2 - Simplesmente Mostra os Campos                    
	    3 - Inclui registros no Bancos de Dados              
	    4 - Altera o registro corrente                       
	    5 - Remove o registro corrente do Banco de Dados     
	*/
	Private aRotina := MenuDef()

	/*
	 -------------Verifica as perguntas selecionadas-------------          
	 -------------Variaveis utilizadas para parametros-----------

	 1. mv_par01  - Data inicial                          
	 2. mv_par02  - Data final                            
	 3. mv_par03  - Considera Nota Fiscal
	    3.1) Normal
	    3.2) Beneficiamento
	    3.3) Devolucao     
	 4. mv_par04  -  Considera Lotes a Vencer			
	 5. mv_par05  -  Dias p/ os lotes a Vencer			
	 6. mv_par06  -  Produto De  		                 
	 7. mv_par07  -  Produto Ate				              
	 8. mv_par08  -  Fornecedor De                   	
	 9. mv_par09  -  Loja De                         	
	 10. mv_par10 -  Fornecedor Ate                  	
	 11. mv_par11 -  Loja Ate                        	
	*/
	Pergunte("QEC030",.F.)
	If !(Pergunte("QEC030",.T.))
		Return
	EndIf

	// Realiza o filtro das Entradas Inspecionadas
	cFiltro := 'QEK_FILIAL == "'+xFilial("QEK")+'"'+'.And.'
	If mv_par03 == 1
		cFiltro += '(QEK_TIPONF == " " .Or. QEK_TIPONF == "N")'
	ElseIf mv_par03 == 2                                   
		cFiltro += 'QEK_TIPONF == "B"'
	ElseIf mv_par03 == 3
		cFiltro += 'QEK_TIPONF == "D"'
	EndIf

	cFiltro += '.And. Dtos(QEK_DTENTR) >= "'+Dtos(mv_par01)+'"'
	cFiltro += '.And.Dtos(QEK_DTENTR) <= "'+Dtos(mv_par02)+'"'                         

	cFiltro += '.And. QEK_PRODUT >= "'+mv_par06+'"'                         
	cFiltro += '.And. QEK_PRODUT <= "'+mv_par07+'"'                         

	cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR >= "'+mv_par08+mv_par09+'"'                         
	cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR <= "'+mv_par10+mv_par11+'"'                         

	cFiltro += '.And. QEK_VERIFI == 1 .And. QEK_SITENT # "1" .And. QEK_SITENT # "4" .And. QEK_SITENT # " " .And. QEK_SITENT # "7"'
	cFiltro += '.And. C030PosLau()'
	If mv_par04 == 1
		cFiltro += '.And. Dtos(QEL->QEL_DTVAL) <= "'+Dtos(dDataBase+mv_par05)+'"'
	EndIf

	cFilDef := "QEK_FILIAL = " + ValToSql(xFilial("QEK"))
	If mv_par03 == 1
		cFilDef += " AND (QEK_TIPONF = ' ' OR QEK_TIPONF = 'N')"
	ElseIf mv_par03 == 2
		cFilDef += " AND QEK_TIPONF = 'B'"
	ElseIf mv_par03 == 3
		cFilDef += " AND QEK_TIPONF = 'D'"
	EndIf
	cFilDef += " AND QEK_DTENTR BETWEEN " + ValToSql(mv_par01) + " AND " + ValToSql(mv_par02)
	cFilDef += " AND QEK_PRODUT BETWEEN " + ValToSql(mv_par06) + " AND " + ValToSql(mv_par07)
	cFilDef += " AND ((QEK_FORNEC > " + ValToSql(mv_par08) + ") OR (QEK_FORNEC = " + ValToSql(mv_par08) + " AND QEK_LOJFOR >= " + ValToSql(mv_par09) + "))"
	cFilDef += " AND ((QEK_FORNEC < " + ValToSql(mv_par10) + ") OR (QEK_FORNEC = " + ValToSql(mv_par10) + " AND QEK_LOJFOR <= " + ValToSql(mv_par11) + "))"
	cFilDef += " AND QEK_VERIFI = 1 AND QEK_SITENT NOT IN ('1', '4', ' ', '7')"
	If mv_par04 == 1
		cFilDef += " AND EXISTS (SELECT 1 FROM " + RetSqlName("QEL") + " QEL9" + ;
			" WHERE QEL9.QEL_FILIAL = '" + xFilial("QEL") + "'" + ;
			"   AND QEL9.QEL_FORNEC = QEK_FORNEC AND QEL9.QEL_LOJFOR = QEK_LOJFOR" + ;
			"   AND QEL9.QEL_PRODUT = QEK_PRODUT AND QEL9.QEL_NTFISC = QEK_NTFISC" + ;
			"   AND QEL9.QEL_SERINF = QEK_SERINF AND QEL9.QEL_ITEMNF = QEK_ITEMNF" + ;
			"   AND QEL9.QEL_TIPONF = QEK_TIPONF AND QEL9.QEL_DTENTR = QEK_DTENTR" + ;
			"   AND QEL9.QEL_LOTE   = QEK_LOTE" + ;
			"   AND QEL9.QEL_DTVAL <= " + ValToSql(dDataBase + mv_par05) + ;
			"   AND QEL9.D_E_L_E_T_ = ' ')"
	EndIf
	cFilDef += " AND D_E_L_E_T_ = ' '"

	If ExistBlock("QEC30FIL") 
		cFiltro := ExecBlock("QEC30FIL",.F.,.F.,{cFiltro}) 
		cFilSQL := QLTQueryManager():ConverteFiltroAdvplParaSql(cFiltro,"QEK",,,{;
			{'.And. C030PosLau()', ''}})
		If !Empty(cFilSQL)
			cFilDef := cFilSQL + " AND D_E_L_E_T_ = ' '"
		EndIf
	EndIF

	lLegSmartX := hasSmartX()
	If lLegSmartX .And. FindClass("QIEA215AuxClass")
		oAuxLeg := QIEA215AuxClass():New()
		If oAuxLeg <> Nil
			aSitEnt := oAuxLeg:criaLegendaSituacaoEntrada(lLegSmartX)
		EndIf
	EndIf

	dbSelectArea("QEK")
	QEK->(dbSetOrder(2))                                                    

	QEK->(dbGoTop())
	If Eof()
		Help(" ",1,"RECNO")   
	Else
	
		// Endereca a funcao de BROWSE
		If lLegSmartX
			setSmartX(0, .F.)
			mBrowse(6,1,22,75,"QEK",,"QEK_SITENT",,,,aSitEnt,,, ,, , ,, "@ " + cFilDef, , , ,  )
		Else
			mBrowse(6,1,22,75,"QEK",,,,,,,,,,,,,,,,,,cFiltro)
		EndIf
	EndIf	        

	dbSelectArea("QEK") 
	Set Filter To

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a030IMP  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao da consulta obtida                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qiec030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a030IMP()
LOCAL cTitulo := OemToAnsi(STR0005)		//"ENTRADAS INSPECIONADAS"
LOCAL cDesc1  := OemToAnsi(STR0006)		//"Este programa ira imprimir a Consulta das Entradas"
LOCAL cDesc2  := OemToAnsi(STR0007)		//"Inspecionadas."
LOCAL cDesc3  := ""
LOCAL wnrel   := "QIEC030"
LOCAL cString := "QEK"

PRIVATE cPerg   := " "
PRIVATE aReturn := { OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0
PRIVATE cTamanho:= "M"

wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,.F.) 

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| c030Imp(@lEnd,ctitulo,wnRel)},ctitulo)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ c030Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que faz a impressao da consulta.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qiec030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function c030Imp(lEnd,ctitulo,wnRel)
Local aAreas   := {QE6->(GetArea()), QEK->(GetArea()), QEL->(GetArea()), SA2->(GetArea())}

Local cCabec1  := ""
Local cNomeProg:= "QIEC030"
Local cbTxt    := SPACE(10)
Local cbcont   := 0
Local nTipo    := 15


cCabec1 := PADR(FwX3Titulo("QEK_FORNEC"),TAMSX3('A2_NREDUZ')[1]) + Space(1)   //Fornecedor
cCabec1 += PADR(FwX3Titulo("QEK_PRODUT"),TAMSX3('QE6_DESCPO')[1] - 9)         //Produto
cCabec1 += PADR(FwX3Titulo("QEK_DTENTR"),TAMSX3('QEK_DTENTR')[1]) + Space(4)  //Dt Entr.
cCabec1 += PADR(AllTrim(FwX3Titulo("QEK_LOTE"))+'/'+AllTrim(FwX3Titulo("QEK_DOCENT")),  TAMSX3('D1_LOTEFOR')[1]) + Space(2)  //Lote-Lote Fornec.
cCabec1 += FwX3Titulo("QEK_VERIFI")  + Space(4)                               // I/C
cCabec1 += PADR(FwX3Titulo("QEK_PEDIDO"),TAMSX3('QEK_PEDIDO')[1]) + Space(08) //No. Pedido
cCabec1 += FwX3Titulo("QEK_TAMLOT") + Space(4)

  

Li    := 80
m_pag := 1

dbSelectArea("QEK")
dbGoTop()
SetRegua(RecCount()) //Total de Elementos da Regua

While !Eof()
				
	IncRegua()
	If Li > 58 
		Cabec(cTitulo,cCabec1,"",cNomeProg,cTamanho,nTipo,,.F.)
	EndIf
	@Li,000 PSAY QEK->QEK_FORNEC	+ " - " + QEK_LOJFOR
	@Li,021 PSAY QEK->QEK_PRODUT	
	@Li,052 PSAY QEK->QEK_DTENTR
	@Li,064 PSAY QEK->QEK_LOTE
	@Li,086 PSAY IIF(QEK->QEK_VERIFI == 1,STR0011,STR0012)		//"Ins"###"Cer"
	@Li,103 PSAY QEK->QEK_PEDIDO
	@Li,120 PSAY QEK->QEK_TAMLOT
	@Li,129 PSAY QEL->QEL_LAUDO

	Li++
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR))
		@Li,000 PSAY SA2->A2_NREDUZ
	EndIf	
	QE6->(dbSetOrder(1))
	If QE6->(dbSeek(xFilial("QE6")+QEK->QEK_PRODUT))
		@Li,021 PSAY QE6->QE6_DESCPO
	EndIf
	@Li,064 PSAY QEK->QEK_DOCENT
	Li+=2
	dbSkip()
EndDo

If Li != 80 
	Roda(cbcont,cbtxt)
EndIf

Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	ourSpool(wnrel)
EndIf

dbSelectArea("QEK")
dbGoTop() 
MS_FLUSH()             
aEval(aAreas, {|x| RestArea(x)})

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C030Laudo³ Autor ³ Marcelo Pimentel      ³ Data ³ 06.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta o Laudo do QEL.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C030Laudo()
Local cRet	 :=""
Local cSeek  := ""

QEL->(DbSetOrder(3))
cSeek := QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE+;
Space(TamSX3("QEL_LABOR")[1])

If	QEL->(dbSeek(xFilial("QEL")+cSeek))		
	QED->(dbSetOrder(1))
	QED->(dbSeek(xFilial("QED")+QEL->QEL_LAUDO))
		cRet := QED->QED_DESCPO
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C030PosLau³ Autor ³ Paulo Emidio de Barros³ Data ³28/11/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona No Laudo Final da Entrada Inspecionada           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C030PosLau() 

QEL->(dbSetOrder(3))
QEL->(MsSeek(xFilial("QEL")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE+Space(TamSx3("QEL_LABOR")[1])))

Return(.T.)
