#INCLUDE "gemr010.ch"
#INCLUDE "protheus.ch"

#Define _nLinSalt_  60  // Linha de salto de pagina
#Define _nLinInic_   9  // Linha de inicio para a impressao

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMR010   º Autor ³ Cristiano Denardi  º Data ³  02.02.06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de Status do Empreendimento					  	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template GEM                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±				 | Alteracao do conceito do relatorio por: Clovis Magenta  	  	±±
±±           | O relatorio trazia somente unidade com pedido de venda e		±±
±±				 |	agora o relatorio traz todas as unidades conforme filtro.	±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GEMR010

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Status do Empreendimento"
Local cPict          := ""
Local titulo       	:= STR0003 //"Status do Empreendimento"
Local nLin         	:= 80
Local Cabec1       	:= STR0019 //"Codigo             Empreendimento                                Mascara        Qtde. Estruturas  Qtde. Unidades Endereco                                        Bairro                CEP        Cidade                UF"
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd           := {STR0011,STR0012,STR0013,STR0014,STR0015} //"Código do Unidade","Código do Cliente","Nome do Cliente","Valor de Venda(Crescente)","Valor de Venda(Decrescente)"

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "G"
Private nomeprog     := "GEMR010" // nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { STR0005, 1, STR0006, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey		:= 0
Private cPerg       	:= "GER010"
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= nomeprog // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 		:= "LK3"
Private lAnalitico 	:= .F.
       
// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

dbSelectArea("LK3")
dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI

AjustaSx1()
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Analitico / Sintetico                    ³
//³ mv_par02        //  Empreendimento De                        ³
//³ mv_par03        //  Empreendimento Ate                       ³
//³ mv_par04        //  Status da Unidade                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


////////////////////////////////////////////
// Monta a interface padrao com o usuario...
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

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

Local aDados   	:= {}
Local aAnali   	:= {}
Local cCodEst  	:= "" 
Local cIndex   	:= ""
Local cStatus  	:= Upper(mv_par04)
Local nEmp     	:= 0
Local nA       	:= 0
Local nB       	:= 0
Local nC 			:= 0
Local nX 			:= 0 
Local nIndex		:= 0   
Local nQtdeReg 	:= 0 
Local nUniFin  	:= 0
Local nUniQuit 	:= 0 
Local nUni			:= 0
Local nUniRes  	:= 0
Local nUniTot  	:= 0
Local nUniVen  	:= 0

lAnalitico := (mv_par01 == 1)
If lAnalitico
	Cabec2 := STR0020 //"                  Cod. Unidade   Descricao                             Valor Cod. Cli  Nome Cliente                            N.Ped. Dt. Ped.   Nota   Sr  Dt. Fat."
Else
	Cabec2 := ""
Endif             
 
cCond  := "C6_FILIAL='"+xFilial("SC6")+"'"
If SC6->( FieldPos("C6_CODEMPR") ) > 0
	cCond  += " .AND. !Empty(C6_CODEMPR)"
Endif

cIndex := CriaTrab(,.F.)
cChave := IndexKey()
IndRegua("SC6",cIndex,"C6_FILIAL+C6_CODEMPR",,cCond)
nIndex := RetIndex("SC6")
dbSelectArea("SC6")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
nIndex++
   //////////////////////////////////////////
   // Verifica o cancelamento pelo usuario...
   If lAbortPrint
      @nLin,00 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
   Endif
   
cStr		:= 0
cUni		:= "UNI"
cEst		:= "EST"
nEmp		:=	0
nStr 		:= 0
nUni		:= 0	                       
nRes		:= 0
nUniVen	:= 0 

aUniTotal := {}
aUniRes	 := {}
aUniVen	 := {}
aUniFin	 := {}
aUniQuit	 := {}

dbSelectArea("LK3")                  
dbSetOrder(1) // Filial + CodEmp + Descricao
MsSeek( xFilial("LK3") + mv_par02, .T.)

While LK3->(! EOF()) .And. ( xFilial("LK3") == LK3->LK3_FILIAL) .And. (LK3->LK3_CODEMP >= mv_par02 .And. LK3->LK3_CODEMP <= mv_par03)
	
	Aadd (aDados, {	LK3->LK3_CODEMP,LK3->LK3_DESCRI,LK3->LK3_MASCAR,;
	LK3->LK3_END   ,LK3->LK3_BAIRRO,LK3->LK3_CEP   ,;
	LK3->LK3_CIDADE,LK3->LK3_UF, {}    } )
	
	nEmp++
	nStr := 0
	
	dbSelectArea("LK5")
	dbSetOrder(1) // FILIAL + CODEMP + ESTRUTURA
	MsSeek( xFilial("LK5") + LK3->LK3_CODEMP, .T.)
	
	While  LK5->(! EOF()) .And. (cFilAnt == LK5->LK5_FILIAL) .And. (LK5->LK5_CODEMP == LK3->LK3_CODEMP)
		
		nUni	:= 0
		If Empty( LK5->LK5_STRPAI )
			Aadd (aDados[nEmp][9], {cEst, 	"------" , "----------------------------", "---------" ,"------------", {} } )
			nStr++
		Else
			cEst	:= "EST"
			Aadd (aDados[nEmp][9], {cEst, 	LK5->LK5_STRUCT,LK5->LK5_DESCRI,LK5->LK5_STRPAI,LK5->LK5_NIVEL, {} } )
			nStr++
		Endif
		
		dbSelectArea("LIQ")
		dbSetOrder(4)  // FILIAL + CODEMP + ESTRUTURA
		MsSeek( xFilial("LIQ") + LK3->LK3_CODEMP + LK5->LK5_STRUCT,.T.)
		
		While LIQ->(! EOF()) .And. (xFilial("LIQ") == LIQ->LIQ_FILIAL) .And. (LK3->LK3_CODEMP == LIQ->LIQ_CODEMP) .And. (LIQ->LIQ_STRPAI == LK5->LK5_STRUCT)
			
			If ! Empty(cStatus) .And. (LIQ->LIQ_STATUS $ cStatus)
				Aadd (aDados[nEmp][9][nStr][6], {cUni ,  LIQ->LIQ_COD , LIQ->LIQ_DESC , LIQ->LIQ_HABITE ,  T_GEMNivelUn(LIQ->LIQ_CODEMP,LIQ->LIQ_STRPAI), LIQ->LIQ_STATUS,  LIQ->LIQ_STRPAI , {} } )
				nUni++
			ELSEIF Empty(cStatus)
				Aadd (aDados[nEmp][9][nStr][6], {cUni , LIQ->LIQ_COD , LIQ->LIQ_DESC , LIQ->LIQ_HABITE , T_GEMNivelUn(LIQ->LIQ_CODEMP,LIQ->LIQ_STRPAI), LIQ->LIQ_STATUS,  LIQ->LIQ_STRPAI, {} } )
				nUni++
			EndIf
						
			dbSelectArea("SC6")
			dbSetOrder(nIndex)
			MsSeek( xFilial("SC6") + LIQ->LIQ_COD )
			While SC6->(!Eof()) .AND. SC6->(C6_FILIAL+C6_CODEMPR) == xFilial("SC6") + LIQ->LIQ_COD
				
				lAchou := .F.
				If Empty(cStatus)
					lAchou := .T.
				ElseIf LIQ->LIQ_STATUS$cStatus
					If LIQ->LIQ_STATUS=="CA"
						// cabecalho do contrato
						dbSelectArea("LIT")
						dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
						If MsSeek( xFilial("LIT") + SC6->(C6_NOTA+C6_SERIE+C6_CLI+C6_LOJA) )
							If AllTrim(LIT->LIT_STATUS) == "1" .OR. AllTrim(LIT->LIT_STATUS) == "2"
								lAchou := .T.
							EndIf
						EndIf
					ElseIf LIQ->LIQ_STATUS == "RE"
						If Empty(SC6->C6_NOTA) .and. Empty(SC6->C6_SERIE).and. Empty(SC6->C6_DATFAT)
							lAchou := .T.
						EndIf
					Else
						lAchou := .T.
					EndIf
				EndIf
				
				If lAchou
					//////////////////
					// Pedido de Venda
					dbSelectArea("SC5")
					dbSetOrder(1) // C5_FILIAL+C5_NUM
					If MsSeek( xFilial("SC5") + SC6->C6_NUM )
					dbSelectArea("LIT")
						dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
						If MsSeek( xFilial("LIT") + SC6->(C6_NOTA+C6_SERIE+C6_CLI+C6_LOJA) )
							If AllTrim(LIT->LIT_STATUS) == "1" .OR. AllTrim(LIT->LIT_STATUS) == "2"
							// .: Sub-Array :. 
								Aadd( aDados[nEmp][9][nStr][6][nUni][8], {LIT->LIT_STATUS } )
							Endif
						EndIf
					EndIf
				EndIf
				SC6->( dbSkip() )
			EndDo
			
			LIQ->( dbSkip() )
			
		EndDo //FIM DO LIQ
		
		LK5->( dbSkip() )
	EndDo // FIM DO LK5
	
	LK3-> ( dbSkip() )
EndDo	// FIM DO LK3                 

	
If !Empty(cIndex)
	fErase (cIndex+OrdBagExt())
Endif

//////////////////////////////////////////////////////////////////////
// SETREGUA -> Indica quantos registros serao processados para a regua 
nQtdeReg := Len(aDados)
SetRegua( nQtdeReg )

////////////////////////////////
// Realiza a Impressao dos dados
For nA := 1 To nQtdeReg
            
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
		nUniTot	:= 0
		nUniRes	:= 0
		nUniVen	:= 0
		nUniFin  := 0
		nUniQuit  := 0
		nX			:= 0    
 	For nB := 1 to Len( aDados[nA][9] )
   	For nC := 1 To Len( aDados[nA][9][nB][6] )
	  		If Upper(aDados[nA][9][nB][6][nC][1]) == "UNI"
	  			nUniTot++
	  			Do case
	  				case aDados[nA][9][nB][6][nC][6] == "RE"
	  					nUniRes++ 
	  				case aDados[nA][9][nB][6][nC][6] == "CA"
						nUniVen++                  
				EndCase
				   
				 	If Len(aDados[nA][9][nB][6][nC][8]) > 0 
						If aDados[nA][9][nB][6][nC][8][1][1] == "1"
							nUniFin++
						elseif aDados[nA][9][nB][6][nC][8][1][1] == "2"
							nUniQuit++
						EndIf
					EndIf			
				           
			Endif
		Next nC

	Next nB
  	Aadd(aUniTotal, {nUniTot})
   Aadd(aUniRes, {nUniRes})
   Aadd(aUniVen, {nUniVen})
   Aadd(aUniQuit, {nUniQuit})
   Aadd(aUniFin, {nUniFin})
  	
   cCodEst := ""
   nLin++           
   
Next nA      


ImpTotEst( @nLin, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, {aUniTotal, aUniRes, aUniVen, aUniQuit, aUniFin},aAnali, aDados, lAnalitico)	

SET DEVICE TO SCREEN

//////////////////////////////////////
// Se impressao em disco, 
// chama o gerenciador de impressao...
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

//Cbc(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

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
Static Function ImpTotEst( nL, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, aTotais ,aPed, aDados, lAnalitico)
                      
Local nCol		:= 13
Local nEmp		:= 0
Local nRepl		:= 100
Local nT			:= 0
Local nY			:= 0
Local nZ			:= 0  
Local nDados		:= 1

Default nL 	 	:= 0
Default aTotais	:= {0,0,0,0,0}
Default aDados  :=	{0,0,0,0,0,0}       

If lAnalitico
     	
	For nEmp := 1 to Len(aDados) 
   	nPrt := 10 
   	          
		@nL,002 PSAY aDados[nEmp][1] + " - "							// Codigo
		@nL,015 PSAY aDados[nEmp][2]									// Nome do Empreendimento
		@nL,065 PSAY aDados[nEmp][3] 									// Mascara
	  	@nL,075 PSAY aDados[nEmp][4]									// Endereco	
	  	@nL,115 PSAY aDados[nEmp][5] 									// Bairro
	  	@nL,140 PSAY Left( aDados[nEmp][6], 47 ) 					// CEP
	  	@nL,161 PSAY Left( aDados[nEmp][7], 20 ) 					// Bairro
  		                                                     
		For nY := 1 To Len(aDados[nEmp][9])
			nL++
			nL++ 
			nPrt 	 := 10
		   nPrt2  := 5
			nDados := 1
			
			While nDados <> 6
				@nL,nPrt2 PSAY aDados[nEmp][9][nY][nDados] 
				nPrt2 := nPrt2 + 30
				nDados++            
				nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			EndDo       
     
	   	For nZ:= 1 to Len(aDados[nEmp][9][nY][6])     
	     		nL++ 
				nPrt := 10 
			  	For nT:= 1 to 7
					If (aDados[nEmp][9][nY][2] == aDados[nEmp][9][nY][6][nZ][7]) .OR. (aDados[nEmp][9][nY][2] == "------")
    					@nL,nPrt PSAY aDados[nEmp][9][nY][6][nZ][nT]
     	  				nPrt := nPrt + 30
  	   				nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
     	   		EndIf
	   	   Next nT
   		Next nZ
    		nL++ 
   	//		Endif
	   Next nY
   	nL++
	   @nL,000 PSAY Replicate( "-", nRepl )
   	nL++
		nL++	
	nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
	@nL,000 PSAY Replicate( "-", nRepl )

	nL++           

nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
@nL,nCol PSAY Transform(aTotais[4][nEmp][1] ,"@E 999,999") + STR0016 //" unidades quitadas"

nL++
nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
@nL,nCol PSAY Transform(aTotais[5][nEmp][1] ,"@E 999,999") + STR0017 //" unidades financiadas"


nL++
nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
@nL,nCol PSAY Replicate( "-", 57 )

nL++
nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
@nL,nCol    PSAY Transform(aTotais[3][nEmp][1] ,"@E 999,999") + STR0010 //" unidades vendidas"
@nL,nCol+30 PSAY Transform(aTotais[2][nEmp][1] ,"@E 999,999") + STR0018 //" unidades reservadas"

nL++
nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
@nL,nCol    PSAY Transform(aTotais[1][nEmp][1] ,"@E 999,999") + STR0009 //" unidades ao total"
            
nL++
nL++
	Next nEmp

Return( nL )
else	
	For nEmp := 1 to Len(aDados) 
   	@nL,002 PSAY aDados[nEmp][1] + " - "							// Codigo
		@nL,015 PSAY aDados[nEmp][2]									// Nome do Empreendimento
		@nL,065 PSAY aDados[nEmp][3] 									// Mascara
	  	@nL,075 PSAY aDados[nEmp][4]									// Endereco	
	  	@nL,115 PSAY aDados[nEmp][5] 									// Bairro
	  	@nL,140 PSAY Left( aDados[nEmp][6], 47 ) 					// CEP
	  	@nL,161 PSAY Left( aDados[nEmp][7], 20 ) 					// Bairro
  		nL++
		nL++	
	
		nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )

		nL++           


		nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
		@nL,nCol PSAY Transform(aTotais[4][nEmp][1] ,"@E 999,999") + STR0016 //" unidades quitadas"

		nL++
		nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
		@nL,nCol PSAY Transform(aTotais[5][nEmp][1] ,"@E 999,999") + STR0017 //" unidades financiadas"
	

		nL++
		nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
		@nL,nCol PSAY Replicate( "-", 57 )

  		nL++
  		nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
		@nL,nCol    PSAY Transform(aTotais[3][nEmp][1] ,"@E 999,999") + STR0010 //" unidades vendidas"
		@nL,nCol+30 PSAY Transform(aTotais[2][nEmp][1] ,"@E 999,999") + STR0018 //" unidades reservadas"

		nL++
		nL := Cbc( nL, _nLinSalt_, _nLinInic_, Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
		@nL,nCol    PSAY Transform(aTotais[1][nEmp][1] ,"@E 999,999") + STR0009 //" unidades ao total"
            
		nL++
		nL++
		nL++
	Next Emp
EndIf

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

//////////////////////
// Analitico/Sintetico 
	aHelpPor	:= {}
	aHelpEng	:= {}
	aHelpEsp	:= {}
	// Portugues
	Aadd(aHelpPor,"Indica qual o modelo do relatorio a ser" )
	Aadd(aHelpPor,"considerado."                            )
	// Ingles
	Aadd(aHelpEng,"It indicates the report model that will" )
	Aadd(aHelpEng,"be considered."                          )
	// Espanhol
	Aadd(aHelpEsp,"Indica cual es el modelo del informe que")
	Aadd(aHelpEsp,"se debe considerar."                     )

	PutSx1(	cPerg, "01", "Analitico/Sintetico", "Analitico/Sintetico", "Detailed/Summarized", ;
			"mv_ch1", "N", 1, 0, 1, "C", "", "", "", "", ;
			"mv_par01", "Analitico", "Analitico", "Detailed", "", "Sintetico", "Sintetico", "Summarized", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
// Analitico/Sintetico
//////////////////////  

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

	PutSx1(	cPerg, "02", "Empreendimento De", "Empreendimento De", "Empreendimento De", ;
			"mv_ch2", "C", 12, 0, 0, "G", "", "LK3", "015", "", ;
			"mv_par02", "", "", "", "", "", "", "", "", ;
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

	PutSx1(	cPerg, "03", "Empreendimento Ate", "Empreendimento Ate", "Empreendimento Ate", ;
			"mv_ch3", "C", 12, 0, 0, "G", "", "LK3", "015", "", ;
			"mv_par03", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
// Empreendimento ATE
/////////////////////

//////////////////////
// Status
	aHelpPor	:= {}
	aHelpEng	:= {}
	aHelpEsp	:= {}
	// Portugues
	Aadd(aHelpPor,"Informe o status das unidades a serem  " )
	Aadd(aHelpPor,"listadas ou deixe em branco para todos." )
	Aadd(aHelpPor,'Ex.: "RE;LV"' )
	// Ingles
	Aadd(aHelpEng,"Informe o status das unidades a serem  " )
	Aadd(aHelpEng,"listadas ou deixe em branco para todos." )
	Aadd(aHelpEng,'Ex.: "RE;LV"' )
	// Espanhol
	Aadd(aHelpEsp,"Informe o status das unidades a serem  " )
	Aadd(aHelpEsp,"listadas ou deixe em branco para todos." )
	Aadd(aHelpEsp,'Ex.: "RE;LV"' )

	PutSx1(	cPerg, "04", "Status", "Spanish", "English", ;
			"mv_ch4", "C", 20, 0, 0, "G", "", "", "", "", ;
			"mv_par04", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
// Status
//////////////////////  

RestArea(aArea)
Return