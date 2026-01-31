#INCLUDE "gemr030.ch"
#INCLUDE "protheus.ch"

#Define		_nLinSalt_	60	// Linha de salto de pagina
#Define 		_nLinInic_	9	// Linha de inicio para a impressao

#Define		_PosQdTit_	8	// Posicao array aProcRel - Qtde de Titulos que possuem valor a receber
#Define		_PosQdUni_	9	// Posicao array aProcRel - Qtde de Unidade que possuem titulos a receber
#Define		_PosVlTot_	10	// Posicao array aProcRel - Valor Total a Receber
#Define		_PosCMTot_	11	// Posicao array aProcRel - Valor Total de CM
#Define		_PosAmTot_	12	// Posicao array aProcRel - Valor Total de Amortizacao
#Define		_PosJrTot_	13	// Posicao array aProcRel - Valor Total de Juros

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMR030   º Autor ³ Cristiano Denardi  º Data ³  02.02.06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de Status do Empreendimento							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template GEM                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GEMR030

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario"
Local cDesc3         := STR0003 //"de titulos a receber pelo valor presente liquido"
Local cPict          := ""
Local titulo       	:= STR0004 //"Relatorio de titulos a receber pelo valor presente liquido"
Local nLin         	:= 80
Local Cabec1       	:= STR0005 //"Codigo             Empreendimento                                Endereco                                 Bairro                         CEP       Cidade                        UF"
Local Cabec2 			:= STR0006 //"                                       Qtde|Titulos Unidades|         Amortizacao               Juros               Valor"
Local imprime      	:= .T.
Local aOrd 				:= {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "G"
Private nomeprog     := "GEMR030" // nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { STR0007, 1, STR0008, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey		:= 0
Private cPerg       	:= "GER030"
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= nomeprog // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 		:= "LK3"

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

dbSelectArea("LK3")
dbSetOrder(1)

AjustaSx1()
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros     ³
//³ mv_par01        //  Empreendimento De    ³
//³ mv_par02        //  Empreendimento Ate   ³
//³ mv_par03        //  Contrato De          ³
//³ mv_par04        //  Contrato Ate         ³
//³ mv_par05        //  Data De              ³
//³ mv_par06        //  Data Ate             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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

//================================
//  .: Estrutura do aEmpTit :.   |
//  --------------------------   |
// 01 - Codigo do empreendimento |
// 02 - Numero da Fatura         |
// 03 - Serie da Fatura          |
// 04 - Proprietario da Unidade  |
// 05 - Filial do proprietario   |
//================================
//
//=========================================================
//  .: Estrutura do aProcRel :.                           |
//  ---------------------------                           |
// 01 - ( aProcRel[1] ) Array com dados do Empreendimento |
// 02 - ( aProcRel[2] ) Array com dados dos Titulos       |
// ......................................                 |
//                                                        |
//  .: Estrutura do aProcRel[1] :.                        |
//  ------------------------------                        |
// 01 - Codigo                                            |
// 02 - Nome                                              |
// 03 - Endereco                                          |
// 04 - Bairro                                            |
// 05 - CEP                                               |
// 06 - Cidade                                            |
// 07 - UF                                                |
// - ate aqui sao alimentados por RetInfEmp() -           |
// 08 - Qtde de titulos a receber                         |
// 09 - Qtde de Unidade que possuem titulos a receber     |
// 10 - Valor Total a Receber                             |
// 11 - Valor Total de CM                                 |
// 12 - Valor Total de Amortizacao                        |
// 13 - Valor Total de Juros                              |
//                                                        |
//  .: Estrutura do aProcRel[2] :.                        |
//  ------------------------------                        |
//  (podera ser usado futuramente para rel analitico)     |
// 01 - Distribuir campos aki                             |
//=========================================================
Local aEmpTit	:= {}
Local aProcRel	:= {} // Esse sera processado para a impressao do relatorio
Local nA			:= 0
Local nX			:= 0
Local nQtdeUni	:= 0
Local cCodEmp	:= ""
Local nQtdeReg	:= 0


//////////////////////
// Busca por Contratos
dbSelectArea("LIT")
dbSetOrder(2) // LIT_FILIAL + LIT_NCONTR
MsSeek( xFilial("LIT") + mv_par03, .T. )

While !EOF() .And. (xFilial("LIT") == LIT->LIT_FILIAL) .And.;
		( LIT->LIT_NCONTR >= mv_par03 .And. LIT->LIT_NCONTR <= mv_par04 )

   //////////////////////////////////////////
   // Verifica o cancelamento pelo usuario...
   If lAbortPrint
      @nLin,00 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   dbSelectArea("LIU")
   dbSetOrder(1) // LIU_FILIAL + LIU_DOC + LIU_SERIE + LIU_CLIENT + LIU_LOJA + LIU_COD + LIU_ITEM
   MsSeek( xFilial("LIU") + LIT->LIT_DOC + LIT->LIT_SERIE + LIT->LIT_CLIENT + LIT->LIT_LOJA, .F. )
	While !EOF() .And. (xFilial("LIT") == LIT->LIT_FILIAL)	.And.;
			LIU->LIU_DOC 		== LIT->LIT_DOC 						.And.;
			LIU->LIU_SERIE 	== LIT->LIT_SERIE 					.And.;
			LIU->LIU_CLIENT 	== LIT->LIT_CLIENT 					.And.;
			LIU->LIU_LOJA 		== LIT->LIT_LOJA
			
		dbSelectArea("LIQ")
		dbSetOrder(1) // LIQ_FILIAL + LIQ_COD
		If MsSeek( xFilial("LIQ") + LIU->LIU_CODEMP )
			If ( LIQ->LIQ_CODEMP >= mv_par01 .And. LIQ->LIQ_CODEMP <= mv_par02 )
				Aadd( aEmpTit,{	LIQ->LIQ_CODEMP	,; // Codigo do empreendimento
										LIT->LIT_DOC		,; // Numero da Fatura
										LIT->LIT_SERIE		,; // Serie da Fatura
										LIT->LIT_CLIENT	,; // Proprietario da Unidade
										LIT->LIT_LOJA		}) // Filial do proprietario
				Exit
			Endif
		EndIf
   
   	dbSelectArea("LIU")
	   dbSetOrder(1)
   	LIU->( dbSkip() )
   EndDo

   dbSelectArea("LIT")
	dbSetOrder(2)
   LIT->( dbSkip() )
EndDo
aEmpTit := aSort( aEmpTit,,, {|x,y|x[1] < y[1]} )

cCodEmp := ""
For nA := 1 To Len(aEmpTit)
	///////////////////////////////////
	// Ocorre a troca do empreendimento
	// Zera contadores
	If cCodEmp <> aEmpTit[nA][1]
		nX++                     
		nQtdeUni := 0
		Aadd( aProcRel, { RetInfEmp(aEmpTit[nA][1],6), {/*array com dados dos titulos*/} } )
			aProcRel[nX][1][_PosQdTit_] := 0 // Qtde de Titulos
			aProcRel[nX][1][_PosQdUni_] := 0 // Qtde de unidades
			aProcRel[nX][1][_PosVlTot_] := 0 // Saldo do Titulo
			aProcRel[nX][1][_PosCMTot_] := 0 // CM
			aProcRel[nX][1][_PosAmTot_] := 0 // Amortizacao
			aProcRel[nX][1][_PosJrTot_] := 0 // Juros
	Endif
	nQtdeUni++
	cCodEmp := aEmpTit[nA][1]
	
	dbSelectArea("SE1")
	dbSetOrder(1) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	// Nao mudar para MsSeek() - Denardi
	dbSeek( xFilial("SE1")+ aEmpTit[nA][3] + aEmpTit[nA][2], .T. )
	While !EOF() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
			SE1->E1_NUM == aEmpTit[nA][2] .And. SE1->E1_PREFIXO == aEmpTit[nA][3] .And.;
			( SE1->E1_VENCREA >= mv_par05 .And. SE1->E1_VENCREA <= mv_par06 )

		dbSelectArea("LIX")                          
		dbSetOrder(1) // LIX_FILIAL + LIX_PREFIX + LIX_NUM + LIX_PARCEL + LIX_TIPO
		If MsSeek( xFilial("LIX") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO )
		
			////////////////////////////////////
			// Pega valores calculados do Titulo
			aValTit := T_GEMValTitR( .T. ) 

			aProcRel[nX][1][_PosQdTit_] += 1 				// Qtde de titulos a receber
			aProcRel[nX][1][_PosQdUni_] := nQtdeUni 		// Qtde de unidades negociadas
			aProcRel[nX][1][_PosVlTot_] += aValTit[02]	// Saldo do Titulo
			aProcRel[nX][1][_PosCMTot_] += aValTit[09]	// CM
			aProcRel[nX][1][_PosAmTot_] += aValTit[07]	// Amortizacao
			aProcRel[nX][1][_PosJrTot_] += aValTit[11]	// Juros
			
			/*
			----------------------------------------------
			Aqui se colocarao os dados para cada titulo em 
			futura implementacao de relatorio analitico
			----------------------------------------------

			Aadd( aProcRel[nX][2], {	SE1->E1_PREFIXO	,;
												SE1->E1_NUM  		,;
												SE1->E1_PARCELA 	,;
												SE1->E1_TIPO 		})
			*/
		
		Endif
		
		dbSelectArea("SE1")
		dbSetOrder(1)
		SE1->( dbSkip() )
	EndDo
Next nA

//////////////////////////////////////////////////////////////////////
// SETREGUA -> Indica quantos registros serao processados para a regua
nQtdeReg := Len(aProcRel)
SetRegua( nQtdeReg )

////////////////////////////////
// Realiza a Impressao dos dados
For nA := 1 To nQtdeReg

   //////////////////////////////////////////
   // Verifica o cancelamento pelo usuario...
   If lAbortPrint
      @nLin,00 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
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
  
   //////////////////////////
   //     .: 1a. Linha :.
   // Dados do Empreendimento
   @nLin,000 PSAY aProcRel[nA][1][1] + " - "								// Codigo
   @nLin,019 PSAY aProcRel[nA][1][2]											// Nome do Empreendimento
   @nLin,065 PSAY aProcRel[nA][1][3]     									// Endereco
   @nLin,106 PSAY aProcRel[nA][1][4] 											// Bairro
   @nLin,137 PSAY Transform( aProcRel[nA][1][5], "@R 99999-999" )	// CEP 
   @nLin,147 PSAY aProcRel[nA][1][6] 											// Cidade
   @nLin,174 PSAY " - " + aProcRel[nA][1][7] 								// UF
   
   nLin++
   nLin := Cbc( nLin, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
   
   //////////////////
   // .: 2a. Linha :.
   // Valores Totais
   @nLin,030 PSAY STR0010 //"TOTAIS ->"
   @nLin,040 PSAY Transform( aProcRel[nA][1][_PosQdTit_], "@E 999,999,999" )				// Qtde de titulos a receber
   @nLin,053 PSAY Transform( aProcRel[nA][1][_PosQdUni_], "@E 999,999" ) 					// Qtde de unidades negociadas
   @nLin,063 PSAY Transform( aProcRel[nA][1][_PosAmTot_], "@E 999,999,999,999.99" )	// Amortizacao
   @nLin,083 PSAY Transform( aProcRel[nA][1][_PosJrTot_], "@E 999,999,999,999.99" )	// Juros
   @nLin,103 PSAY Transform( aProcRel[nA][1][_PosVlTot_], "@E 999,999,999,999.99" )	// Saldo a Receber

Next nA

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
±±³Descri‡…o ³Controle de cabecalho   			          				  		  ³±±
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
±±³Fun‡…o	 ³RetInfEmp  ³ Autor ³ Cristiano Denardi    ³ Data ³ 02.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna informacoes do cadastro do empreendimento	  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetInfEmp( cCod, nTamAr )

Local aArea := GetArea()
Local aRet	:= {}
Local nA		:= 0

Default cCod	:= ""
Default nTamAr	:= 00

dbSelectArea("LK3")
dbSetOrder(1) // LK3_FILIAL + LK3_CODEMP + LK3_DESCRI
If MsSeek( xFilial("LK3") + cCod )
	aRet := {	LK3->LK3_CODEMP ,;
					LK3->LK3_DESCRI ,;
					LK3->LK3_END    ,;
					LK3->LK3_BAIRRO ,;
					LK3->LK3_CEP    ,;
					LK3->LK3_CIDADE ,;
					LK3->LK3_UF     }
Endif

If nTamAr > 0
	For nA := 1 To nTamAr
		Aadd( aRet, Nil )
	Next nA
Endif

RestArea( aArea )
Return( aRet )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³AjustaSx1  ³ Autor ³ Cristiano Denardi    ³ Data ³ 02.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ajusta SX1            			          				  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSx1()

Local aArea 	:= GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpEsp	:= {} 
Local cPerg 	:= PadR ( "GER030", Len( SX1->X1_GRUPO ) )  

////////////////////
// Empreendimento DE
	aHelpPor	:= {}
	aHelpEng	:= {}
	aHelpEsp	:= {}
	// Portugues
	Aadd(aHelpPor,"Informe o codigo inicial do" )
	Aadd(aHelpPor,"Empreendimento."             )

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

	PutSx1(	cPerg, "02", "Empreendimento Ate", "Empreendimento Ate", "Empreendimento Ate", ;
			"mv_ch2", "C", 12, 0, 0, "G", "", "LK3", "015", "", ;
			"mv_par02", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
// Empreendimento ATE
/////////////////////

//////////////
// Contrato DE
	aHelpPor	:= {}
	aHelpEng	:= {}
	aHelpEsp	:= {}
	// Portugues
	Aadd(aHelpPor,"Informe o codigo inicial do" )
	Aadd(aHelpPor,"Contrato."                   )

	PutSx1(	cPerg, "03", "Contrato De", "Contrato De", "Contrato De", ;
			"mv_ch3", "C", 15, 0, 0, "G", "", "LIT", "", "", ;
			"mv_par03", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
// Contrato DE
//////////////

///////////////
// Contrato ATE
	aHelpPor	:= {}
	aHelpEng	:= {}
	aHelpEsp	:= {}
	// Portugues
	Aadd(aHelpPor,"Informe o codigo final do" )
	Aadd(aHelpPor,"Contrato."                 )

	PutSx1(	cPerg, "04", "Contrato Ate", "Contrato Ate", "Contrato Ate", ;
			"mv_ch4", "C", 15, 0, 0, "G", "", "LIT", "", "", ;
			"mv_par04", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
// Contrato ATE
///////////////

//////////
// Data DE
	aHelpPor	:= {}
	aHelpEng	:= {}
	aHelpEsp	:= {}
	// Portugues
	Aadd(aHelpPor,"Informe a Data inicial do" )
	Aadd(aHelpPor,"vencimento do titulo."     )

	PutSx1(	cPerg, "05", "Data De", "Data De", "Data De", ;
			"mv_ch5", "D", 8, 0, 0, "G", "", "", "", "", ;
			"mv_par05", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
// Data DE
//////////

///////////
// Data ATE
	aHelpPor	:= {}
	aHelpEng	:= {}
	aHelpEsp	:= {}
	// Portugues
	Aadd(aHelpPor,"Informe a Data final do"   )
	Aadd(aHelpPor,"vencimento do titulo."     )

	PutSx1(	cPerg, "06", "Data Ate", "Data Ate", "Data Ate", ;
			"mv_ch6", "D", 8, 0, 0, "G", "", "", "", "", ;
			"mv_par06", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
// Data ATE
///////////

RestArea(aArea)
Return