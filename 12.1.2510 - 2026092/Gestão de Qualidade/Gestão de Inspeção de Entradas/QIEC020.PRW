#include "FWMBROWSE.CH"
#include "PROTHEUS.CH"
#include "QIEC020.CH"

/*/{Protheus.doc} QIEC020 - Consulta de Entradas em Skip-Lote
@type  Function
@author Marcelo Pimentel
@since  06/05/1998
@historico
19/04/1999, Vera, Inclusao da Loja do Fornecedor.
18/02/2000, Vera, Inclusao de filtro para considerar apenas registros com QEK_VERIFI = 2.
24/01/2001, Paulo Emidio, Correcao na abertura dos indices temporarios por meio da funcao IndRegua.
11/06/2001, Paulo Emidio, Inclusao da opcao para selecao do tipo de entrada considerado:
											 1) Normal; 2) Beneficiamento; 3) Devolucao.
*/
Static Function MenuDef()

	Local lPageAction := .T.
	Local aRotina :={{OemToAnsi(STR0001),"AxPesqui"	,	0 , 1},;  				//"Pesquisar"
					 {OemToAnsi(STR0002), "a020IMP", 0, 8,,,,,,   lPageAction}} //"Imprimir"
	

	Return aRotina

Function QIEC020()

	// Define Variaveis
	Local aSitEnt    := {}
	Local cFilDef    := " "
	Local cFilSQL    := ""
	Local cFiltro    := ""
	Local lLegSmartX := .F.
	Local oAuxLeg    := Nil

	Private Inclui := .T.

	// Recupera o desenho padrao de atualizacoes
	cCadastro := OemToAnsi(STR0003) //"Entradas em Skip-Lote"

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

	// Verifica as perguntas selecionadas
	Pergunte("QEC020",.F.)       
	If !(Pergunte("QEC020",.T.))
		Return
	EndIf

	// Realiza  o filtro das Entradas em Skip-Lote
	cFiltro += 'QEK_FILIAL == "'+xFilial("QEK")+'"'+'.And.'
	If mv_par03 == 1
		cFiltro += '(QEK_TIPONF == " " .Or. QEK_TIPONF == "N")' 
	ElseIf mv_par03 == 2
		cFiltro += 'QEK_TIPONF == "B"' 
	ElseIf mv_par03 == 3
		cFiltro += 'QEK_TIPONF == "D"' 
	EndIf
	cFiltro += '.And. Dtos(QEK_DTENTR) >= "'+Dtos(mv_par01)+'"'
	cFiltro += '.And. Dtos(QEK_DTENTR) <= "'+Dtos(mv_par02)+'"' 

	cFiltro += '.And. QEK_PRODUT >= "'+mv_par04+'"'                         
	cFiltro += '.And. QEK_PRODUT <= "'+mv_par05+'"'                         

	cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR >= "'+mv_par06+mv_par07+'"'                         
	cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR <= "'+mv_par08+mv_par09+'"'                         

	cFiltro += '.And. QEK_VERIFI == 2'      

	cFilDef := "QEK_FILIAL = " + ValToSql(xFilial("QEK"))
	If mv_par03 == 1
		cFilDef += " AND (QEK_TIPONF = ' ' OR QEK_TIPONF = 'N')"
	ElseIf mv_par03 == 2
		cFilDef += " AND QEK_TIPONF = 'B'"
	ElseIf mv_par03 == 3
		cFilDef += " AND QEK_TIPONF = 'D'"
	EndIf
	cFilDef += " AND QEK_DTENTR BETWEEN " + ValToSql(mv_par01) + " AND " + ValToSql(mv_par02)
	cFilDef += " AND QEK_PRODUT BETWEEN " + ValToSql(mv_par04) + " AND " + ValToSql(mv_par05)
	cFilDef += " AND ((QEK_FORNEC > " + ValToSql(mv_par06) + ") OR (QEK_FORNEC = " + ValToSql(mv_par06) + " AND QEK_LOJFOR >= " + ValToSql(mv_par07) + "))"
	cFilDef += " AND ((QEK_FORNEC < " + ValToSql(mv_par08) + ") OR (QEK_FORNEC = " + ValToSql(mv_par08) + " AND QEK_LOJFOR <= " + ValToSql(mv_par09) + "))"
	cFilDef += " AND QEK_VERIFI = 2"

	cFilDef += " AND D_E_L_E_T_ = ' '"
	If ExistBlock("QEC20FIL") 
		cFiltro := ExecBlock("QEC20FIL",.F.,.F.,{cFiltro}) 
		cFilSQL := QLTQueryManager():ConverteFiltroAdvplParaSql(cFiltro,"QEK")
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

	// Fecha o Arq. QEK p/ criar o QEK com Arq. de Trabalho
	dbSelectArea("QEK")
	QEK->(dbSetOrder(1))                              
	MsgRun(STR0014,STR0015,{||dbSetFilter({||&cFiltro},cFiltro)}) //"Selecionando as Entradas..."###"Aguarde..."

	QEK->(dbGoTop())
	If Eof()
		Help(" ",1,"RECNO")   
	Else
	
	// Endereca a funcao de BROWSE
	If hasSmartX()
		setSmartX(0, .F.)
		If !Empty(aSitEnt)
			mBrowse(6,1,22,75,"QEK",,"QEK_SITENT",,,, aSitEnt,,, ,, , ,, "@ " + cFilDef, , , ,  )
		Else
			mBrowse( 6, 1,22,75,"QEK",,,,,,,,,,,,,,cFilDef)
		EndIf
	Else
		mBrowse( 6, 1,22,75,"QEK" )
	EndIf
	EndIf

	dbSelectArea("QEK")
	Set Filter To

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a020IMP  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao da consulta obtida                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEC020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a020IMP()
LOCAL cTitulo  :=OemToAnsi(STR0005)		//"ENTRADAS EM SKIP-LOTE"
LOCAL cDesc1   :=OemToAnsi(STR0006)		//"Este programa ira imprimir a Consulta de Entradas em"
LOCAL cDesc2   :=OemToAnsi(STR0007)		//"Skip-Lote."
LOCAL cDesc3   :=""
LOCAL wnrel    :="QIEC020"
LOCAL cString  :="QEL"

PRIVATE cPerg   :="      "
PRIVATE aReturn := {OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey:=0
PRIVATE cTamanho:= "M"
wnrel:= SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| C020Imp(@lEnd,ctitulo,wnRel)},ctitulo)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C020Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que faz a impressao da consulta.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEC020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C020Imp(lEnd,ctitulo,wnRel)
Local aArea			:= GetArea()
Local aAreas        := {QE6->(GetArea()), QEK->(GetArea()), QEL->(GetArea()), SA2->(GetArea())}
Local CbCont		:= 0
Local cbTxt			:= SPACE(10)
Local cSeek    		:= ""
Private cCabec1		:= ''		//"Fornecedor           Produto                               Dt Entr.   Lote            Doc.Entrada     I/C Pedido     Tam.Lote Laudo"
Private cCabec2		:= ""
Private	cNomeprog	:= "QIEC020"
Private cTamanho	:= "M"
Private nTipo       := 15


cCabec1 := PADR(FwX3Titulo("QEK_FORNEC"),TAMSX3('A2_NREDUZ')[1]) + Space(1)   //Fornecedor
cCabec1 += PADR(FwX3Titulo("QEK_PRODUT"),TAMSX3('QE6_DESCPO')[1] - 9)         //Produto
cCabec1 += PADR(FwX3Titulo("QEK_DTENTR"),TAMSX3('QEK_DTENTR')[1]) + Space(4)  //Dt Entr.
cCabec1 += PADR(AllTrim(FwX3Titulo("QEK_LOTE"))+'/'+AllTrim(FwX3Titulo("QEK_DOCENT")),  TAMSX3('D1_LOTEFOR')[1]) + Space(2)  //Lote-Lote Fornec.
cCabec1 += FwX3Titulo("QEK_VERIFI")  + Space(4)                               // I/C
cCabec1 += PADR(FwX3Titulo("QEK_PEDIDO"),TAMSX3('QEK_PEDIDO')[1]) + Space(08) //No. Pedido
cCabec1 += FwX3Titulo("QEK_TAMLOT")                                           //Tam. Lote 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Li     := 80
m_pag  := 1
dbSelectArea("QEK")
QEK->(dbGoTop())
SetRegua(QEK->(RecCount())) //Total de Elementos da Regua


While !QEK->(Eof())
	IncRegua()
	If Li > 58 
		Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.)
	EndIf
	@Li,000 PSAY QEK->QEK_FORNEC + " - " + QEK->QEK_LOJFOR
	@Li,021 PSAY QEK->QEK_PRODUT	
	@Li,052 PSAY QEK->QEK_DTENTR	
	@Li,064 PSAY QEK->QEK_LOTE
	@Li,084 PSAY IIF(QEK_VERIFI == 1,STR0011,STR0012)		//"Ins"###"Cer"
	@Li,100 PSAY QEK->QEK_PEDIDO
	@Li,118 PSAY QEK->QEK_TAMLOT PICTURE PesqPict("QEK","QEK_TAMLOT")
	

	QEL->(DbSetOrder(3))
	cSeek := QEK->(QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE)+;
	Space(TamSX3("QEL_LABOR")[1])

	If	QEL->(dbSeek(xFilial("QEL")+cSeek))
		@Li,129 PSAY QEL->QEL_LAUDO
	Endif	
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
	QEK->(dbSkip())
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
MS_FLUSH()
aEval(aAreas, {|x| RestArea(x)})
RestArea(aArea)
Return .T.
