#INCLUDE "protheus.ch"
#INCLUDE "gemr100.ch"

#Define _nLinSalt_  60  // Linha de salto de pagina
#Define _nLinInic_   9  // Linha de inicio para a impressao

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GEMR100   ³ Autor ³ WILKER VALLADARES     ³ Data ³ 26.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Dados do Empreendimento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 26.02.06 ³Wilker Valladar³ Criação                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GEMR100
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Relatório de Dados do Empreendimento"
Local cPict          := ""
Local titulo       	 := STR0003 //"Relatório de Dados do Empreendimento"
Local nLin         	 := 80
Local Cabec1       	 := STR0004 //"Codigo             Empreendimento                                Mascara        Qtde. Estruturas  Qtde. Unidades Endereco                                        Bairro                CEP        Cidade                UF"
Local Cabec2       	 := STR0009 //" 		     Unidade            Descrição                                       Metragem    UM    Status"
Local imprime      	 := .T.
Local aOrd           := {STR0008} // "Empreendimento + Unidade

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "G"
Private nomeprog     := "GEMR100" // nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { STR0005, 1, STR0006, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey		:= 0
Private cPerg       	:= "GER100"
Private cbcont     	 := 00
Private CONTFL     	 := 01
Private m_pag      	 := 01
Private wnrel      	 := nomeprog // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 	 := "LK3"

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

dbSelectArea("LK3")
dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI

AjustaSx1()
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Empreendimento De                        ³
//³ mv_par02        //  Empreendimento Ate                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

////////////////////////////////////////////
// Monta a interface padrao com o usuario...
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Cristiano Denardi  º Data ³  02.02.06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

//////////////////////
// Estrutura de aDados
//			.: Primeiro Array :.
//		Informacoes do Empreendimento
//		-----------------------------
// 01 - Codigo do Empreendimento
// 02 - Descricao
// 03 - Codigo da mascara usada
// 04 - Array com retorno da Funcao T_GEMmascCnf()
// 05 - Qtde de Estruturas no Empreendimento
// 06 - Qtde de Unidades no Empreendimento
// 07 - Logradouro
// 08 - Bairro
// 09 - CEP
// 10 - Cidade
// 11 - UF
//
//				  .: Segundo Array :.
//		Informacoes das Estruturas/Unidades
//		-----------------------------------
// 01 - "EST"(estrutura) ou "UNI"(unidade)
// 02 - Codigo Estrutura (usado para ordenacao posterior, util para nos)
// 03 - Codigo Estrutura ou Unidade
// 04 - Descricao da Estrutura ou Unidade
// 05 - Nivel onde se encontra na hierarquia da mascara
// 06 - Array com dados da Venda, caso ja' tenha sido vendido
//

Local aDados   := {}
Local aMasc    := {}
Local nEmp     := 0
Local nQtdeUni := 0
Local nQtdeEst := 0
Local nA       := 0
Local nB       := 0
Local cCodEmp  := ""

dbSelectArea("LK3")
dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
MsSeek( xFilial("LK3") + mv_par01, .T. )
    

While !EOF() .And. (xFilial("LK3") == LK3->LK3_FILIAL) .And.;
	( LK3->LK3_CODEMP >= mv_par01 .And. LK3->LK3_CODEMP <= mv_par02 )

	//////////////////////////////////////////
	// Verifica o cancelamento pelo usuario...
	If lAbortPrint
		@nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	///////////////////////////////////
	// Adiciona Empreendimento ao Array
	nEmp++
	
	nQtdeEst := 0
	nQtdeUni := 0
	
	// .: Primeiro Array :.
	aMasc := T_GEMmascCnf( LK3->LK3_MASCAR )
	Aadd( aDados, {{	LK3->LK3_CODEMP,LK3->LK3_DESCRI,LK3->LK3_MASCAR,aMasc,0,0,;
	LK3->LK3_END   ,LK3->LK3_BAIRRO,LK3->LK3_CEP   ,;
	LK3->LK3_CIDADE,LK3->LK3_UF    }, {} } )
	
	/////////////////////////////
	// Ajusta Array com estrutura
	// do Empreendimento LK5
	dbSelectArea("LK5")
	dbSetOrder(1) // LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
	MsSeek( xFilial("LK5") + LK3->LK3_CODEMP, .T. )
	While !EOF() .And. (xFilial("LK5") == LK5->LK5_FILIAL) .And.;
		( LK5->LK5_CODEMP == LK3->LK3_CODEMP )
		
		/////////////////////////////////
		// Nao adicona registro referente
		// ao empreendimento
		If Empty( LK5->LK5_STRPAI )
			LK5->( dbSkip() )
			Loop
		Endif
		
		nQtdeEst++
		// .: Segundo Array :.
		Aadd( aDados[nEmp][2], {"EST",LK5->LK5_STRUCT,LK5->LK5_STRUCT,LK5->LK5_DESCRI,LK5->LK5_NIVEL,{}} )
		LK5->( dbSkip() )
	EndDo
	// Ajusta Array com estrutura
	// do Empreendimento LK5
	/////////////////////////////
	
	/////////////////////////////
	// Ajusta Array com estrutura
	// das Unidades LIQ
	dbSelectArea("LIQ")
	dbSetOrder(4) // LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI
	MsSeek( xFilial("LIQ") + LK3->LK3_CODEMP, .T. )
	While !EOF() .And. (xFilial("LIQ") == LIQ->LIQ_FILIAL) .And.;
		( LIQ->LIQ_CODEMP == LK3->LK3_CODEMP )
		
		nQtdeUni++
		// .: Segundo Array :.
		Aadd( aDados[nEmp][2], {"UNI",LIQ->LIQ_STRPAI,LIQ->LIQ_COD,LIQ->LIQ_DESC,LIQ->LIQ_AREA,LIQ->LIQ_UM,LIQ->LIQ_STATUS,T_GEMNivelUn(LIQ->LIQ_CODEMP,LIQ->LIQ_STRPAI),{}} )
		
		LIQ->( dbSkip() )
	EndDo
	
	// Ajusta Array com estrutura
	// das Unidades LIQ
	/////////////////////////////
	
	aDados[nEmp][2]    := aSort( aDados[nEmp][2],,, {|x,y|x[2]+x[3] < y[2]+y[3]} )
	aDados[nEmp][1][5] := nQtdeEst
	aDados[nEmp][1][6] := nQtdeUni
	
	dbSelectArea("LK3")
	dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
	
	LK3->( dbSkip() )
EndDo

//////////////////////////////////////////////////////////////////////
// SETREGUA -> Indica quantos registros serao processados para a regua
nQtdeReg := Len(aDados)
SetRegua( nQtdeReg )

////////////////////////////////
// Realiza a Impressao dos dados
For nA := 1 To nQtdeReg

    cCodEmp := aDados[nA][1][1]
	
	//////////////////////////////////////////
	// Verifica o cancelamento pelo usuario...
	If lAbortPrint
		@nLin,00 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	///////////////////////////////////////////
	// Impressao do cabecalho do relatorio. . .
	nLin := Cbc( nLin, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
	If nA <> 1
		nLin++
		nLin++
		@nLin,00 PSAY __PrtThinLine()
		nLin++
	Endif
	 
	IncRegua(aDados[nA][1][2])
	
	
	/////////////////
	// Empreendimento
	@nLin,000 PSAY aDados[nA][1][1] + " - "							// Codigo
	@nLin,019 PSAY aDados[nA][1][2]										// Nome do Empreendimento
	@nLin,065 PSAY aDados[nA][1][4][1][1] 							// Mascara
	@nLin,095 PSAY aDados[nA][1][5]										// Qtde de Estruturas
	@nLin,110 PSAY aDados[nA][1][6] 									// Qtde de Unidades
	@nLin,113 PSAY Left( aDados[nA][1][7], 47 ) 					// Endereco
	@nLin,161 PSAY Left( aDados[nA][1][8], 20 ) 					// Bairro
	@nLin,183 PSAY Transform( aDados[nA][1][9], "@R 99999-999" )	// CEP
	@nLin,194 PSAY Left( aDados[nA][1][10], 20 ) 					// Cidade
	@nLin,216 PSAY Left( aDados[nA][1][11], 2 ) 					// UF
	nLin++
	@nLin,00 PSAY __PrtThinLine()
	/////////////////////////////
	// Detalhes do Empreendimento
	For nB := 1 To Len( aDados[nA][2] )
		
		////////////
		// Estrutura
		If Upper(aDados[nA][2][nB][1]) == "EST"
			nLin++
			nLin := Cbc( nLin, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			/////////////////
			// Lista a estrutura                 
			nLin++
			@nLin,001 PSAY "==>" 
			@nLin,008 PSAY Alltrim(aDados[nA][2][nB][3])					// Codigo da Estrutura
			@nLin,027 PSAY Alltrim(aDados[nA][2][nB][4])					// Descricao
		Endif


		////////////
		// Unidade
		If Upper(aDados[nA][2][nB][1]) == "UNI"
			nLin++
			nLin := Cbc( nLin, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			/////////////////
			// Lista as Unidades
			@nLin,008 PSAY Alltrim(aDados[nA][2][nB][3])					// Unidade
			@nLin,027 PSAY Alltrim(aDados[nA][2][nB][4])					// Descricao
			@nLin,075 PSAY Alltrim(Str(aDados[nA][2][nB][5]))				// Metragem
			@nLin,087 PSAY Alltrim(aDados[nA][2][nB][6])					// Unidade de Medida
			@nLin,093 PSAY Tabela("IT",Alltrim(aDados[nA][2][nB][7]))		// Status da Unidade
		Endif
		
	Next nB
	nLin++

    // Imprime totalizador na mudanca do empreendimento
	ImpTotEst( @nLin, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, {0, aDados[nA][1][5], aDados[nA][1][6]} ) // total, qtd. estrutura, qtd.Unidade       
	
Next nA

//passa o parametro total de empreendimentos listados e zera os demais totalizadores
nLin++
ImpTotEst( @nLin, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, { nEmp, 0, 0} ) // total, qtd. estrutura, qtd.Unidade       

SET DEVICE TO SCREEN

//////////////////////////////////////
// Se impressao em disco,
// chama o gerenciador de impressao...
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Cbc        ³ Autor ³ Cristiano Denardi    ³ Data ³ 02.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de cabecalho   	          				  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Cbc( nL, nLS, nLM, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )

Default nL  := 0
Default nLS := _nLinSalt_
Default nLM := _nLinInic_
If nL > nLS // Salto de Pagina.
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nL := nLM
Endif
Return( nL )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ImpTotEst  ³ Autor ³ Cristiano Denardi    ³ Data ³ 02.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime totalizadores da estrutura.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpTotEst( nL, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, aTotais  )

Local nCol		:= 13
Local nRepl		:= 100

Default nL  	:= 0
Default aTotais := {0,0,0}

nL++
nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
@nL,000 PSAY Replicate( "-", nRepl )
                         
if aTotais[1] > 0
	nL++
	nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
	@nL,nCol PSAY Replicate( "-", 57 )
	
	nL++
	nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
	@nL,nCol    PSAY Transform(aTotais[1] ,"@E 999,999") + STR0011 //"   Nº de Empreendimentos Listados"
else
	nL++
	nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
	@nL,nCol    PSAY Transform(aTotais[2] ,"@E 999,999") + STR0012 //"   Quantidade Estruturas"
	
	nL++
	nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
	@nL,nCol PSAY Transform(aTotais[3] ,"@E 999,999") + STR0013 // quantidade de unidades
endif

Return( nL )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³AjustaSx1  ³ Autor ³ Cristiano Denardi    ³ Data ³ 02.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ajusta SX1            			          				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSx1()

Local aArea 	:= GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpEsp	:= {}

////////////////////
// Empreendimento DE
aHelpPor	:= {}
aHelpEng	:= {}
aHelpEsp	:= {}
// Portugues
Aadd(aHelpPor,"Informe o codigo inicial do" )
Aadd(aHelpPor,"Empreendimento."             )
// Ingles
Aadd(aHelpEng,"" )
// Espanhol
Aadd(aHelpEsp,"")

PutSx1(	cPerg, "01", "Empreendimento De", "Empreendimento De", "Empreendimento De", ;
"mv_ch1", "C", 12, 0, 0, "G", "", "LK3", "015", "", ;
"mv_par01", "", "", "", "", "", "", "", "", ;
"", "", "", "", "", "", "", "", ;
aHelpPor, aHelpEng, aHelpEsp )
// Empreendimento DE
////////////////////

/////////////////////
// Empreendimento ATE
aHelpPor	:= {}
aHelpEng	:= {}
aHelpEsp	:= {}
// Portugues
Aadd(aHelpPor,"Informe o codigo final do" )
Aadd(aHelpPor,"Empreendimento."           )
// Ingles
Aadd(aHelpEng,"" )
// Espanhol
Aadd(aHelpEsp,"")

PutSx1(	cPerg, "02", "Empreendimento Ate", "Empreendimento Ate", "Empreendimento Ate", ;
"mv_ch2", "C", 12, 0, 0, "G", "", "LK3", "015", "", ;
"mv_par02", "", "", "", "", "", "", "", "", ;
"", "", "", "", "", "", "", "", ;
aHelpPor, aHelpEng, aHelpEsp )
// Empreendimento ATE
/////////////////////

RestArea(aArea)
Return
