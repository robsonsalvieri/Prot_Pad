#INCLUDE "gemr090.ch"
#INCLUDE "protheus.ch"

#Define _nLinSalt_  60  // Linha de salto de pagina
#Define _nLinInic_   9  // Linha de inicio para a impressao

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMR090   º Autor ³ Daniel Tadashi Batori º Data ³  26.02.07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao do Distrato                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template GEM                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GEMR090

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Distrato"
Local cPict          := ""
Local cTitulo       	:= STR0003 //"Distrato"
Local nLin         	:= 80
Local Cabec1       	:= STR0004 //"Num.    Data      Data      Cód.    Nome Cliente                    Cód.          Desc.                           Val.               Observação do Distrato                              Val.Rec.           Val.Juros"
Local Cabec2       	:= STR0005 //"Contr.  Contr.    Distrato  Cliente                                 Unidade       Unidade                         Venda                                                                  Principal          Fcto.Recebido"
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "G"
Private nomeprog     := "GEMR090" // nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { STR0006, 1, STR0007, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey		:= 0
Private cPerg       	:= "GER090"
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= nomeprog // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 		:= "LJD"

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

dbSelectArea("LJD")
dbSetOrder(1) // LJD_FILIAL+LJD_NCONTR+LJD_REVISA

AjustaSx1()
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Contrato De                              ³
//³ mv_par02        //  Contrato Ate                             ³
//³ mv_par03        //  Cliente De                               ³
//³ mv_par04        //  Cliente Ate                              ³
//³ mv_par05        //  Unidade De                               ³
//³ mv_par06        //  Unidade Ate                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


////////////////////////////////////////////
// Monta a interface padrao com o usuario...
wnrel := SetPrint(cString,NomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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

RptStatus({|| RunReport(Cabec1,Cabec2,cTitulo,nLin) },cTitulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Daniel Tadashi Batori  º Data ³  26.02.07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS     º±±
±±º          ³ monta a janela com a regua de processamento.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,cTitulo,nLin)

Local cFilLJD := xFilial("LJD")
Local cFilLIT := xFilial("LIT")
Local cFilSA1 := xFilial("SA1")
Local cFilLIQ := xFilial("LIQ")
Local cFilSE1 := xFilial("SE1")
Local cFilSE5 := xFilial("SE5")
Local cFilLIX := xFilial("LIX")
Local cPict   := x3Picture("LIT_VALBRU")
Local n       := 0
Local nTotAmo := 0
Local nTotJur := 0
Local nAmort  := 0
Local nValor  := 0
Local aArea   := {}
Local lFim    := .F.
Local cUnid := ""

LJD->(DbSetOrder(1)) //filial+contrato+revisa
LIT->(DbSetOrder(2)) //filial+contrato
SA1->(DbSetOrder(1)) //filial+A1_COD+A1_LOJA
LIQ->(DbSetOrder(1)) //filial+LIQ_COD
SE1->(DbSetOrder(1)) //FILIAL+PREFIXO+NUM+PARCELA+TIPO
SE5->(DbSetOrder(7)) //FILIAL+PREFIXO+TITULO
LIX->(DbSetOrder(1)) //FILIAL+PREFIXO+NUM+PARCELA+TIPO

// Busca por Distratos
LJD->(DbSeek( cFilLJD+mv_par01,.T. )) //Distrato De/Ate

SetRegua( LJD->(RecCount()) )

While LJD->(!EOF()) .And. (cFilLJD+mv_par02 >= LJD->(LJD_FILIAL+LJD_NCONTR))
	lFim := .F.
	IncRegua()

	// Verifica o cancelamento pelo usuario...
	If lAbortPrint
		@nLin,00 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
   
	// Impressao do cabecalho do relatorio. . .
	nLin := Cbc( nLin, _nLinSalt_, _nLinInic_, cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
	
	If !LIT->(DbSeek(cFilLIT+LJD->LJD_NCONTR)) .Or. ;
		LIT->LIT_CLIENT < mv_par03 .Or. ; //Cliente De/Ate
		LIT->LIT_CLIENT > mv_par04
		LJD->(DbSkip())
		Loop
	EndIf

	If LJD->(FieldPos("LJD_E_CODE"))>0
	   If LJD->LJD_E_CODE < mv_par05 .Or. LJD->LJD_E_CODE > mv_par06 //Unidade De/Ate
			LJD->(DbSkip())
			Loop
	   EndIf
	   cUnid := LJD->LJD_E_CODE
    Else
	 	aArea   := GetArea()
		dbSelectArea("LIU")
		dbSetOrder(3) //LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
		If LIU->(DbSeek(xFilial()+LJD->LJD_NCONTR))
			While LIU->(!Eof()) .AND. !lFim .AND. LIU->(LIU_FILIAL+LIU_NCONTR)==xFilial()+LJD->LJD_NCONTR
				If !Empty(LIU->LIU_CODEMP)
					If LIU->LIU_CODEMP>= mv_par05 .AND. LIU->LIU_CODEMP<=mv_par06
						cUnid := LIU->LIU_CODEMP
						lFim := .T.
					EndIf
				EndIf
				
				dbSelectArea("LIU")
				dbSkip()
			EndDo
	    EndIF
	 	RestArea(aArea)
	 	If !lFim
	 		Loop
	 	EndIf   
 	EndIF
 	
	LIQ->(DbSeek(cFilLIQ+cUnid))
	SA1->(DbSeek(cFilSA1+LIT->(LIT_CLIENT+LIT_LOJA)))

	nTotAmo := 0
	nTotJur := 0

	If SE1->(DbSeek(cFilSE1+LIT->(LIT_PREFIX+LIT_DOC)))
			
		While !SE1->(EOF()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM)==cFilSE1+LIT->(LIT_PREFIX+LIT_DOC)
				
			//Se o titulo nao teve nenhum pagamento entao skip
			If SE1->E1_SALDO == SE1->E1_VALOR
				SE1->(DbSkip())
				Loop
			EndIf

			//Totaliza as baixas do titulo
			nValor := 0
			If SE5->(DbSeek(cFilSE5+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)))
				While !SE5->(EOF()) .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA)==cFilSE5+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)

					//Verifica se o registro eh de receber
					If SE5->E5_RECPAG != "R"
						If SE5->E5_TIPODOC == "ES"
							nValor -= SE5->E5_VALOR
						EndIf
						SE5->(DbSkip())
						Loop
					EndIf
	
					If !(SE5->E5_TIPODOC $ "VL/BA/V2/CP")
						SE5->(DbSkip())
						Loop
					EndIf

					// Consiste se o motivo gera ou nao movimento bancario.
					If !MovBcoBx( SE5->E5_MOTBX, .F. )
						SE5->(DbSkip())
						Loop
					Endif
	
					nValor += SE5->E5_VALOR

					SE5->(DbSkip())
				EndDo
			EndIf

			If LIX->(DbSeek(cFilLIX+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))

				nAmort  := nValor * LIX->LIX_ORIAMO / LIX->(LIX_ORIAMO+LIX_ORIJUR)
				nTotAmo += nAmort
				nTotJur += nValor - nAmort
			
			EndIf
			
			SE1->(DbSkip())
		EndDo
	EndIf
			

	@nLin,000 PSAY PadL(Val(LIT->LIT_NCONTR),6,"0")   //Numero do Contrato
	@nLin,008 PSAY LIT->LIT_EMISSA                    //Data do Contrato
	@nLin,018 PSAY LJD->LJD_DTDIST	                 //Data do Distrato
  	@nLin,028 PSAY SA1->A1_COD                        //Codigo do Cliente 6
  	@nLin,036 PSAY PadL(SA1->A1_NOME,30)              //Nome do Cliente
  	@nLin,068 PSAY LIQ->LIQ_COD                       //Código da Unidade 12
  	@nLin,082 PSAY LIQ->LIQ_DESC                      //Desc. da Unidade 30
  	@nLin,114 PSAY Transform(LIT->LIT_VALBRU,cPict)   //Valor da Venda 17
	@nLin,133 PSAY MemoLine(LJD->LJD_HIST,50,1,,)     //Obs. do Distrato  	
  	@nLin,185 PSAY Transform(nTotAmo,cPict)           //Valor Principal do Recebido
  	@nLin,204 PSAY Transform(nTotJur,cPict)           //Valor Juros Fcto Recebido

  	For n := 2 to MLCount(LJD->LJD_HIST,50)
  		cLinha := MemoLine(LJD->LJD_HIST,50,n,,)
  		If !Empty(cLinha)
	  		nLin++
	  		nLin := Cbc( nLin, _nLinSalt_, _nLinInic_, cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
  			@nLin,133 PSAY cLinha    //Obs. do Distrato
  		EndIf
  	Next n
  	
   nLin++
   LJD->(DbSkip())
EndDo
		
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Cbc        ³ Autor ³ Daniel Tadashi Batori  ³ Data ³ 26.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de cabecalho                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLin : linha atual da impressao                              ³±±
±±³          ³ nLS : Linha de salto de pagina                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Cbc( nLin, nLS, nLM, cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )

Default nLin := 0
Default nLS  := _nLinSalt_
Default nLM  := _nLinInic_

If nLin > nLS // Salto de Pagina.
	Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := nLM
Endif
Return( nLin )
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³AjustaSx1  ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 26.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ajusta SX1                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSx1()

Local aArea 	:= GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpEsp	:= {} 
Local cPerg		:= PadR ( "GER090", Len( SX1->X1_GRUPO ) )  

aHelpPor	:= {}
aHelpEng	:= {}
aHelpEsp	:= {}
// Portugues
Aadd(aHelpPor,"Informe o codigo inicial do" )
Aadd(aHelpPor,"Contrato."                   )
// Ingles
Aadd(aHelpEng,"" )
// Espanhol
Aadd(aHelpEsp,"")

PutSx1(	cPerg, "01", "Contrato De", "Contrato De", "Contrato De", ;
			"mv_ch1", "C", 15, 0, 0, "G", "", "LJD", "", "", ;
			"mv_par01", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


aHelpPor	:= {}
aHelpEng	:= {}
aHelpEsp	:= {}
// Portugues
Aadd(aHelpPor,"Informe o codigo final do" )
Aadd(aHelpPor,"Contrato."                 )
// Ingles
Aadd(aHelpEng,"" )
// Espanhol
Aadd(aHelpEsp,"")

PutSx1(	cPerg, "02", "Contrato Ate", "Contrato Ate", "Contrato Ate", ;
			"mv_ch2", "C", 15, 0, 0, "G", "naovazio()", "LJD", "", "", ;
			"mv_par02", "", "", "", "ZZZZZZZZZZZZZZZ", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


aHelpPor	:= {}
aHelpEng	:= {}
aHelpEsp	:= {}
// Portugues
Aadd(aHelpPor,"Informe o codigo inicial do" )
Aadd(aHelpPor,"Cliente."                    )
// Ingles
Aadd(aHelpEng,"" )
// Espanhol
Aadd(aHelpEsp,"")

PutSx1(	cPerg, "03", "Cliente De", "Cliente De", "Cliente De", ;
			"mv_ch3", "C", 6, 0, 0, "G", "", "SA1", "", "", ;
			"mv_par03", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


aHelpPor	:= {}
aHelpEng	:= {}
aHelpEsp	:= {}
// Portugues
Aadd(aHelpPor,"Informe o codigo final do" )
Aadd(aHelpPor,"Cliente."                  )
// Ingles
Aadd(aHelpEng,"" )
// Espanhol
Aadd(aHelpEsp,"")

PutSx1(	cPerg, "04", "Cliente Ate", "Cliente Ate", "Cliente Ate", ;
			"mv_ch4", "C", 6, 0, 0, "G", "naovazio()", "SA1", "", "", ;
			"mv_par04", "", "", "", "ZZZZZZ", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


aHelpPor	:= {}
aHelpEng	:= {}
aHelpEsp	:= {}
// Portugues
Aadd(aHelpPor,"Informe o codigo inicial da" )
Aadd(aHelpPor,"Unidade."                    )
// Ingles
Aadd(aHelpEng,"" )
// Espanhol
Aadd(aHelpEsp,"")

PutSx1(	cPerg, "05", "Unidade De", "Unidade De", "Unidade De", ;
			"mv_ch5", "C", 12, 0, 0, "G", "", "LIQ", "", "", ;
			"mv_par05", "", "", "", "", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


aHelpPor	:= {}
aHelpEng	:= {}
aHelpEsp	:= {}
// Portugues
Aadd(aHelpPor,"Informe o codigo final da" )
Aadd(aHelpPor,"Unidade."                  )
// Ingles
Aadd(aHelpEng,"" )
// Espanhol
Aadd(aHelpEsp,"")

PutSx1(	cPerg, "06", "Unidade Ate", "Unidade Ate", "Unidade Ate", ;
			"mv_ch6", "C", 12, 0, 0, "G", "naovazio()", "LIQ", "", "", ;
			"mv_par06", "", "", "", "ZZZZZZZZZZZZ", "", "", "", "", ;
			"", "", "", "", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )

RestArea(aArea)
Return
