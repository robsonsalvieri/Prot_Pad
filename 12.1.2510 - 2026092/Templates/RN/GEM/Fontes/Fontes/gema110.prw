#INCLUDE "GEMA110.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMA110   ºAutor  ³Reynaldo Miyashita  º Data ³  13.05.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento de Transferencia de contratos                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMA110()
Local aArea := GetArea()

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004) //"Transferencia de Contrato"

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereca para a funcao MBrowse                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("LJC")
LJC->(dbSetOrder(1)) // LJC_FILIAL+LJC_NCONTR+LJC_REVISA
MsSeek(xFilial("LJC"))
mBrowse(06,01,22,75,"LJC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade da Rotina                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("LJC")
LJC->(dbSetOrder(1)) // LJC_FILIAL+LJC_NCONTR+LJC_REVISA
dbClearFilter()

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMA110Dlg ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 13.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Transferencia de titulos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³T_GMA110Dlg()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GMA110Dlg(cAlias,nReg,nOpc)

Local lA110Inclui := .F.
Local lA110Visual := .F.
Local lA110Altera := .F.
Local lA110Exclui := .F.
Local lContinua   := .T.
Local lOk         := .F.

Local cCpoGrv     := ""
Local nRecLJC     := 0
Local nOpcGD      := 0
Local nX          := 0
Local aSize       := {}
Local aObjects    := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aButtons    := {}
Local aUsrButtons := {}

Local aBrwCampo   := {}
Local aTamanho    := {}
Local aHeader     := {}
Local aTitulos    := {}
Local aCampos     := {}

Local aArea       := GetArea()

Local oDlg 
Local oPanel1

Private aGets[0]
Private aTela[0][0]
Private oEnch 
Private oBrw
Private aBrwDef  := {}
Private aHeadLK6 := {}
Private aColsLK6 := {}

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (aRotina[nOpc][4] == 2)
		lA110Visual := .T.
	Case (aRotina[nOpc][4] == 3)
		Inclui      := .T.
		lA110Inclui := .T.
	Case (aRotina[nOpc][4] == 4)
		Altera      := .T.
		lA110Altera := .T.
	Case (aRotina[nOpc][4] == 5)
		lA110Exclui := .T.
		lA110Visual := .T.
EndCase

// caso exista a rotina, sera incluido os botoes especificos.
If ExistBlock("GMA110BTN")
	If ValType( aUsrButtons := ExecBlock( "GMA110BTN",.F., .F. ) ) == "A"
		aEval( aUsrButtons, { |x| aAdd( aButtons, x ) } )
	EndIf
EndIf
	
aCampos := {}
dbSelectArea("SX3")
SX3->(dbSetOrder(1)) // X3_FILIAL+X3_CAMPO
dbSeek("LJC")
While !Eof() .and. SX3->X3_ARQUIVO == "LJC"
	IF X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
		aAdd(aCampos,AllTrim(SX3->X3_CAMPO))
	EndIf
	dbSkip()
End

If Empty(aCampos)
	lContinua := .F.
EndIf               

If !lA110Inclui
	If lA110Altera.Or.lA110Exclui
		If !SoftLock("LJC")
			lContinua := .F.
		Else
			nRecLJC := LJC->(RecNo())
		Endif
		
		// verifica o status do contrato
		lContinua := T_GMContrStatus( LJC->LJC_NCONTRAT )
		
	EndIf
EndIf

If lContinua 
	RegToMemory( "LJC" ,lA110Inclui )
	If lA110Inclui
		M->LJC_FILIAL := xFilial("LJC")
		M->LJC_DTTRAN := dDataBase
	EndIf
	
	//
	// define a tabela, campos e a ordens dos campos no browse
	//
	If lA110Visual
		aBrwCampo := {"LJE_PREFIX" ,"LJE_NUM" ,"LJE_PARCEL" ,"LJE_TIPO" ,"LJE_VENCTO" ,"LJE_MOEDA" ,"LJE_VALOR","LJE_AMORT","LJE_PVLJUR"}
	Else
		aBrwCampo := {"E1_PREFIXO" ,"E1_NUM" ,"E1_PARCELA" ,"E1_TIPO" ,"E1_VENCTO" ,"E1_MOEDA" ,"E1_VALOR"}
	EndIf
	aTamanho := {0}
	aHeader  := {""}
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) //X3_FILIAL+X3_CAMPO
	aEval(aBrwCampo ,{|cCampo| iIf( SX3->(dbSeek(cCampo)) ;
	                               ,( aAdd( aBrwDef ,{ SX3->X3_CAMPO ,X3Titulo() ,SX3->X3_PICTURE ,SX3->X3_TAMANHO}) ;
	                                 ,aAdd( aHeader ,X3Titulo()) ,aAdd( aTamanho ,SX3->X3_TAMANHO*2.5) ) ;
	                               ,.F. ) ;
	                  } )
	aTitulos := {Array(len(aBrwDef)+1)}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aAdd( aObjects, { 200, 200, .T., .T. } )
	aSize   := MsAdvSize()
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
                                                                              
	oEnch := MsMGet():New("LJC",LJC->(RecNo()),nOpc,,,,,aPosObj[1],aCampos,3,,,,oDlg)
	oPanel1 := TPanel():New(aPosObj[2,1],aPosObj[2,2],'',oDlg, ,.T.,.T.,, ,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],.T.,.T. )
	oBrw := TWBrowse():New( 5,10,300,100,,aHeader ,aTamanho ,oPanel1,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 
	oBrw:SetArray(aTitulos)
	oBrw:bLine := {|| aTitulos[oBrw:nAT] }
	oBrw:Align := CONTROL_ALIGN_ALLCLIENT

	If lA110Visual 
		T_GMA110BrwTit( M->LJC_NCONTR ,M->LJC_REVISA ,lA110Visual)
		aAdd(aButtons,{"PMSDOC",{|| T_GMViewContr(M->LJC_NCONTR,M->LJC_REVISA ) } ,OemtoAnsi(STR0005),OemtoAnsi(STR0006) } ) //"Visualiza o Contrato"###"Contrato"
	Else
		Aadd(aButtons,{"GROUP"    ,{|| A110Solid( M->LJC_NCONTR ,M->LJC_REVISA ,M->LJC_CLIENT ,M->LJC_LOJA ) } ,STR0011,STR0012}) //"Cadastro de Solidarios"###"Solidarios"
	EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela) .AND. iIf( lA110Visual ,.T. ,T_GMA110CLIATUAL(M->LJC_NCONTR ,M->LJC_CLIENT, M->LJC_LOJA) ) ;
	                                                      ,(lOk:=.T.,nOpc:=1,oDlg:End()),Nil ) ;
	                                                },{||oDlg:End()},,aButtons)
  
	If lOk .AND. (lA110Inclui .Or. lA110Altera .Or. lA110Exclui)
		Begin Transaction
			Processa({||A110Grava(lA110Altera,lA110Exclui,nRecLJC,aTitulos) },STR0007,STR0008,.F.)  //"Transferindo os titulos"###"Aguarde..."
		End Transaction
	EndIf
	
EndIf

RestArea( aArea )
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GMA110GravºAutor  ³Reynaldo Miyashita  º Data ³  13.05.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento para gravacao da tabela LJC                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A110Grava(lA110Altera,lA110Exclui,nRecLJC ,aTitulos)
Local bCampo      := {|n| FieldName(n) }
Local nCount      := 0
Local nY          := 0
Local nQtdParc    := 0
Local nPosCp      := 0
Local cParcela    := ""
Local cCodCliente := ""
Local cLjCliente  := ""
Local cNewRevisa  := ""
Local lProvisorio := .F.
Local aRecord     := {}
Local aArea       := GetArea()

If ! lA110Exclui

	If ! lA110Altera
		// LIT - cadastro de contratos
		dbSelectArea("LIT")
		LIT->(dbSetOrder(2)) //LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+M->LJC_NCONTR)
			
			cCodCliente := LIT->LIT_CLIENT
			cLjCliente  := LIT->LIT_LOJA
			cNewRevisa  := Soma1(LIT->LIT_REVISA)
			
			//
			// Grava o historico do contrato
			//
			t_GMHistContr( M->LJC_NCONTR ,M->LJC_REVISA ,cNewRevisa ,,M->LJC_CLIENT ,M->LJC_LOJA )
			
			//
			// Grava a Transferencia do contrato
			//
			RecLock("LJC",.T.)
				For nCount := 1 TO FCount()
					LJC->(FieldPut(nCount,M->&(EVAL(bCampo,nCount))))
				Next nCount
				LJC->LJC_PARCEL := cParcela 
			LJC->(MsUnlock())
				
			// cadastro de cliente
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
			If dbSeek(xFilial("SA1")+M->LJC_CLIENT+M->LJC_LOJA)
				// Grava os solidarios do titular do contrato
				A100GravSolid( M->LJC_NCONTR )
				
				//
				// Altera o codigo e nome do cliente no titulo a receber somente dos titulos que 
				// tem o mes/ano de vencimento maior que a da database
				// 
				dbSelectArea("SE1")
				SE1->(dbSetOrder(1)) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				dbSeek(xFilial("SE1")+LIT->LIT_PREFIX+LIT->LIT_DUPL+cParcela)
				While SE1->(!EOF()) .AND. ;
				      SE1->E1_Filial+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SE1")+LIT->LIT_PREFIX+LIT->LIT_DUPL
				      
					// Se a mes/ano do vencimento for maior que mes/ano da database
					If left(dtos(SE1->E1_VENCREA),6) > left(dtos(dDataBase),6)
						RecLock("SE1",.F.)
							SE1->E1_CLIENTE := M->LJC_CLIENT
							SE1->E1_LOJA    := M->LJC_LOJA
							SE1->E1_NOMCLI  := iIf( Empty(SA1->A1_NREDUZ) ,SA1->A1_NOME ,SA1->A1_NREDUZ )
						SE1->(MsUnLock())
					EndIf
					SE1->(dbSkip())
				EndDo
					
			Else
				// nao encontrou o cliente
			EndIF
			
		EndIf
	EndIf
Endif

RestArea( aArea ) 	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GMA110CliAºAutor  ³Reynaldo Miyashita  º Data ³  17.05.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se é o cliente atual do contrato                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GMA110CliAtual( cContrato ,cCliente ,cLoja )
Local aArea  := GetArea()
Local lOk    := .T.

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	dbSelectArea("LIT")
	LIT->(dbSetOrder(2)) //LIT_FILIAL+LIT_NCONTR
	If dbSeek(xFilial("LIT")+cContrato)
		If cCliente == LIT->LIT_CLIENT .AND. cLoja == LIT->LIT_LOJA
			Help(" ",1,"GMA100CLIATUAL","",STR0009+CRLF+STR0010,1) //"O código do cliente informado "###"é o atual do contrato."
			lOk := .F.
		EndIf
				
	EndIf
	
	RestArea(aArea)
Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GMA110BrwTºAutor  ³Reynaldo Miyashita  º Data ³  13.05.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Array com os titulos                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
TEMPLATE Function GMA110BrwTit( cContrato ,cRevisa ,lVisual )
Local lContinua := .F.
Local aTit      := {}
Local aTitulos  := {}
Local aArea     := GetArea()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	If lVisual
		// busca o Historico do contrato
		dbSelectArea("LJA")	
		LJA->(dbSetOrder(2)) // LJA_FILIAL+LJA_NCONTR+LJA_REVISA
		If dbSeek( xFilial("LJA")+cContrato+cRevisa )
			//
			// Busca o historico dos titulos a receber
			//
			dbSelectArea("LJE")	
			LJE->(dbSetOrder(1)) // LJE_FILIAL+LJE_NCONTR+LJE_REVISA
			dbSeek( xFilial("LJE")+cContrato+cRevisa )
			While LJE->(!eof()) .AND. ;
			      xFilial("LJE")+cContrato+cRevisa == ; 
			      LJE->LJE_FILIAL+LJE->LJE_NCONTR+LJE->LJE_REVISA
				aTit := {""}
				aEval( aBrwDef ,{|aCampo| aAdd( aTit, TRANSFORM( LJE->&(aCampo[1]) ,aCampo[3]) )} )
				aAdd( aTitulos ,aTit )
				LJE->(dbSkip())
			EndDo
		EndIf
	Else
		// busca o contrato atual
		dbSelectArea("LIT")	
		LIT->(dbSetOrder(2)) ////LIT_FILIAL+LIT_NCONTR
		If dbSeek( xFilial("LIT")+cContrato )
			//
			// busca pelos titulos atuais
			//
			dbSelectArea("SE1")	
			SE1->(dbSetOrder(1)) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			dbSeek( xFilial("SE1") + LIT->LIT_PREFIX + LIT->LIT_DUPL)
			While SE1->(!eof()) .AND. ;
			      xFilial("SE1")+LIT->LIT_PREFIX+LIT->LIT_DUPL == ; 
			      SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM
				If SE1->E1_SALDO <> 0
					aAdd( aTitulos ,{""} )
					aEval( aBrwDef ,{|aCampo| aAdd( aTitulos[len(aTitulos)] ,TRANSFORM( SE1->&(aCampo[1]) ,aCampo[3]) )} )
				EndIf
				SE1->(dbSkip())
			EndDo
		EndIf
	EndIf
    
    //
	If Empty(aTitulos)
		aTitulos := {Array(len(aBrwDef)+1)}
	EndIf
		
	oBrw:SetArray(aTitulos)
	oBrw:bLine := {|| aTitulos[oBrw:nAT] }
	oBrw:Align := CONTROL_ALIGN_ALLCLIENT
	oBrw:Refresh()

RestArea( aArea )
 
Return( .t. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A110Solid ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 23.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualiza os solidarios do cliente no Historico do contrato.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A110Solid( cContrato ,cRevisa ,cCliente ,cLjCli )             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do contrato                                     ³±±
±±³          ³ExpC2: Numero da revisao do contrato                          ³±±
±±³          ³ExpC3: Código do cliente                                      ³±±
±±³          ³ExpC4: Filial do Codigo do CLiente                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A110Solid( cContrato ,cRevisa ,cCliente ,cLjCli )

Local lContinua := .T. 
Local aArea     := GetArea()

DEFAULT cContrato := ""
DEFAULT cRevisa   := ""
DEFAULT cCliente  := ""
DEFAULT cLjCli    := ""
    
	cContrato := padr( cContrato ,TamSx3("LJC_NCONTRAT")[1])
	cRevisa   := padr( cRevisa   ,TamSx3("LJC_REVISA")[1])
	cCliente  := padr( cCliente  ,TamSx3("LJC_CLIENT")[1])
	cLjCli    := padr( cLjCli    ,TamSx3("LJC_LOJA")[1])

	If Empty(cContrato)
		Help(" ",1,"VAZIOCONTR",,STR0013,1) //"Contrato não foi informado."
		lContinua := .F.
	Else
		If Empty(cCliente)
			Help(" ",1,"ERRCLIENT",,STR0014,1) //"O código do cliente não informado."
			lContinua := .F.
		EndIf
	EndIf
	
	If lContinua
		// verifica se o cliente atual já esta no contrato.
		If t_GMA110CliAtual( cContrato ,cCliente ,cLjCli )
			// cabecalho do contrato
			dbSelectArea("LIT")
			dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
			If dbSeek(xFilial("LIT")+cContrato)
				// permite visualizar os solidarios do contrato
				ExecTemplate("GMSOLCONT",.F.,.F.,{3 ,cContrato ,cCliente ,cLjCli})
			Else
				Help(" ",1,"ERRCONTR",,STR0021 + cContrato + STR0022,1) //"O contrato "###" não existe."
			EndIf
		EndIf
	EndIf

RestArea(aArea)
		
Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A100GravSo³ Autor ³ Reynaldo Miyashita    ³ Data ³ 29.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os solidarios informados na transferencia.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A100GravSolid( cContrato )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do contrato                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A100GravSolid( cContrato )
Local nCount     := 0
Local nY         := 0
Local nPosCp     := 0
Local nPos       := 0
Local nPosCodSol := GdFieldPos( "LK6_CODSOL" ,aHeadLK6)
Local nPosJlSol	 := GdFieldPos( "LK6_LJSOLI" ,aHeadLK6)
Local nUsado     := len(aHeadLK6)
Local cNumPed    := ""
Local lOk        := .F.

Local aArea  := GetArea()

	If len(aColsLK6) > 0
		// cabecalho do contrato
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If LIT->(dbSeek(xFilial("LIT")+cContrato))
			// Itens de nota fiscal de saida
			dbSelectArea("SD2")
			dbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If SD2->(dbSeek(xFilial("SD2")+LIT->LIT_DOC+LIT->LIT_SERIE ))
				// cabecalho do pedido de venda
				dbSelectArea("SC5") 
				dbSetOrder(1) // C5_FILIAL+C5_NUM
				If SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
					cNumPed := SC5->C5_NUM
					lOk := .T.
				EndIf
			EndIf
		EndIf
		
		If lOk	
			dbSelectArea("LK6")
			dbSetOrder(1) // LK6_FILIAL+LK6_NCONTR+LK6_CODSOL+LK6_LJSOLI
			For nCount := 1 To Len(aColsLK6)
				// se o item nao foi deletado
				If !(aColsLK6[nCount,nUsado+1])
					If LK6->(MsSeek(xFilial("LK6")+cContrato+aColsLK6[nCount,nPosCodSol]+aColsLK6[nCount,nPosJlSol]))
						RecLock("LK6",.F.)
					Else
						RecLock("LK6",.T.)
					Endif
					For nY := 1 to fCount()
						nPosCp := GdFieldPos(Fieldname(nY),aHeadLK6)
						IF nPosCp<>0
							FieldPut(nY,aColsLK6[nCount,nPosCp])
						Endif
					Next nY
					LK6->LK6_FILIAL := xFilial("LK6")
					LK6->LK6_NCONTR := cContrato 
					LK6->(MsUnLock())
				Else
					If LK6->(MSSeek(xFilial("LK6")+cContrato +aColsLK6[nCount,nPosCodSol]+aColsLK6[nCount,nPosJlSol]))
						While !Eof() .And. xFilial("LK6")+cContrato +aColsLK6[nCount,nPosCodSol]+aColsLK6[nCount,nPosJlSol] == ;
							LK6->LK6_FILIAL+LK6->LK6_NCONTR+LK6->LK6_CODSOL+LK6->LK6_LJSOLI
							RecLock("LK6",.F.)
							LK6->(dbDelete())
							LK6->(MsUnLock())
							LK6->(DbSkip())
						Enddo
					Endif
				EndIf
			Next nCount
			// exclui os registros que naum sao mais utilizados 
			LK6->(dbGoTop())
			If LK6->(MSSeek(xFilial("LK6")+cContrato ))
				While LK6->(!Eof()) .AND. xFilial("LK6")+cContrato == LK6->LK6_FILIAL+LK6->LK6_NCONTR
					nPos := aScan( aColsLK6 ,{|x| !(x[nUsado+1]) .AND. x[nPosCodSol] == LK6->LK6_CODSOL .AND. x[nPosJlSol] == LK6->LK6_LJSOLI })
					If nPos <=0
						RecLock("LK6",.F.)
						LK6->(dbDelete())
						LK6->(MsUnLock())
					EndIf
					LK6->(DbSkip())
				EndDo
			EndIf 
			
			aHeadLK6:={}
			aColsLK6:={}
		EndIf
	Else
		dbSelectArea("LK6")
		dbSetOrder(1) // LK6_FILIAL+LK6_NCONTR+LK6_CODSOL+LK6_LJSOLI
		IF LK6->(dbSeek(xFilial("LK6")+cContrato))
			While !Eof() .And. xFilial("LK6")+cContrato == LK6->LK6_FILIAL+LK6->LK6_NCONTR
				RecLock("LK6",.F.)
				LK6->(dbDelete())
				LK6->(MsUnLock())
				LK6->(DbSkip())
			Enddo
		Endif
	EndIf
	
	RestArea( aArea )

Return( lOk )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMA110Troc³ Autor ³ Reynaldo Miyashita    ³ Data ³ 05.07.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Troca o titular pelo solidario no browse de solidarios.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A110TrocaSolid( cCliente ,cLoja )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do Contrato                                     ³±±
±±³          ³ExpC2: Codigo do Cliente                                      ³±±
±±³          ³ExpC2: Loja do Cliente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GMA110TrocSolid( cContrato ,cCliente ,cLoja )
Local nCount      := 0
Local nPos        := 0
Local nPos_CODSOL := 0
Local nPos_LJSOLI := 0
Local nPos_NOMSOL := 0
Local nPos_GRAU   := 0
Local nPos_CIVIL  := 0
Local nUsado      := 0
Local cCpoGrv     := ""
Local aArea       := GetArea()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	// Estrutura das colunas
	If Len(aHeadLK6)==0
		aHeadLK6 := aClone(TableHeader("LK6"))
	Endif           
	nUsado := len(aHeadLK6)
			
	// se for um solidario efetua a troca
	dbSelectArea("LK6")
	dbSetOrder(1) // LK6_FILIAL+LK6_NCONTR+LK6_CODSOL+LK6_LJSOLI
	If LK6->(dbSeek(xFilial("LK6")+cContrato+cCliente+cLoja ))
		
		// posicoes dos campos no array
		nPos_CODSOL := aScan( aHeadLK6 ,{|x|Upper(AllTrim(x[2])) == "LK6_CODSOL" } )
		nPos_LJSOLI := aScan( aHeadLK6 ,{|x|Upper(AllTrim(x[2])) == "LK6_LJSOLI" } )
		nPos_NOMSOL := aScan( aHeadLK6 ,{|x|Upper(AllTrim(x[2])) == "LK6_NOMSOL" } )
		nPos_GRAU   := aScan( aHeadLK6 ,{|x|Upper(AllTrim(x[2])) == "LK6_GRAU" } )
		nPos_CIVIL  := aScan( aHeadLK6 ,{|x|Upper(AllTrim(x[2])) == "LK6_CIVIL" } )
		
		// dados das colunas
		aColsLK6 := {}
		dbSelectArea("LK6")
		dbSetOrder(1) // LK6_FILIAL+LK6_NCONTR+LK6_CODSOL+LK6_LJSOLI
		If LK6->(dbSeek(xFilial("LK6")+cContrato))
			While LK6->(!Eof()) .And. xFilial("LK6") == LK6->LK6_FILIAL .And. cContrato == LK6->LK6_NCONTR
				Aadd(aCoLsLK6,Array(nUsado+1))
				For nCount := 1 To nUsado
					cCpoGrv := FieldName(FieldPos(AllTrim(aHeadLK6[nCount ,2])))
					aColsLK6[Len(aColsLK6),nCount ] := &cCpoGrv
				Next nCount
				aColsLK6[Len(aColsLK6),nUsado+1] := .F.
				LK6->(dbSkip())
			Enddo
		Endif
	    If Len(aColsLK6) == 0
			aColsLK6 := Array(1,nUsado+1)
			dbSelectArea("SX3")
			SX3->(dbSetOrder(1)) // X3_FILIAL+X3_CAMPO
			SX3->(dbSeek("LK6"))
			nUsado := 0
			
			While !Eof() .And. (SX3->x3_arquivo == "LK6")
			
				If X3USO(SX3->x3_usado) .And. cNivel >= SX3->x3_nivel
					nUsado++
					aColsLK6[1,nUsado] := CriaVar( SX3->X3_Campo)
				EndIf
				SX3->(dbSkip())
			EndDo
			aColsLK6[1,nUsado+1] := .F.
		EndIf
		
		//
		// preenche o campo LK6_NOMSOL
		//
		If nPos_CODSOL > 0 .AND. nPos_LJSOLI > 0 .AND. nPos_NOMSOL > 0
	  		For nCount := 1 To len(aColsLK6)
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
				If SA1->(dbSeek( xFilial("SA1")+aColsLK6[nCount ,nPos_CODSOL]+aColsLK6[nCount ,nPos_LJSOLI]))
					aColsLK6[nCount ,nPos_NOMSOL] := SA1->A1_NOME
				EndIf
			Next nCount
		EndIf
		
		//
		// busca pelo cliente informado do cadastro de solidario, caso encontre subtitui.
		//	 
		nPos := aScan( aColsLK6,{|aCol| aCol[nPos_CODSOL]==cCliente .and. aCol[nPos_LJSOLI]== cLoja })
		If nPos >0 
			dbSelectArea("LIT")
			LIT->(dbSetOrder(2)) // LIT_FILIAL+LIT_NCONTR
			If dbSeek(xFilial("LIT")+cContrato )
				aColsLK6[nPos ,nPos_CODSOL] := LIT->LIT_CLIENT
				aColsLK6[nPos ,nPos_LJSOLI] := LIT->LIT_LOJA
				aColsLK6[nPos ,nPos_GRAU]   := ""
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
				If SA1->(dbSeek( xFilial("SA1")+LIT->LIT_CLIENT+LIT->LIT_LOJA))
					aColsLK6[nPos ,nPos_NOMSOL] := SA1->A1_NOME
					aColsLK6[nPos ,nPos_CIVIL]  := SA1->A1_GMCIVIL
				Else                            
					aColsLK6[nPos ,nPos_NOMSOL] := ""
					aColsLK6[nPos ,nPos_CIVIL]  := ""
				EndIf
			Else
				aEval(aHeadLK6,{|aCampo|aColsLK6[nPos] := CriaVar(aCampo[2])})
			EndIf
			
		Endif
	Else
		aColsLK6 := Array(1,nUsado+1)
		dbSelectArea("SX3")
		SX3->(dbSetOrder(1)) // X3_FILIAL+X3_CAMPO
		SX3->(dbSeek("LK6"))
		nUsado := 0
		
		While !Eof() .And. (SX3->x3_arquivo == "LK6")
		
			If X3USO(SX3->x3_usado) .And. cNivel >= SX3->x3_nivel
				nUsado++
				aColsLK6[1,nUsado] := CriaVar( SX3->X3_Campo)
			EndIf
			SX3->(dbSkip())
		EndDo
		aColsLK6[1,nUsado+1] := .F.
		
	EndIf
	
	restArea(aArea)
	
Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³05/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local aRotina := {{ OemToAnsi(STR0001) ,"AxPesqui"    ,0,1,,.F.},;  //'Pesquisar'
                  { OemToAnsi(STR0002) ,"T_GMA110Dlg" ,0,2},; //"Visualizar"
                  { OemToAnsi(STR0003) ,"T_GMA110Dlg" ,0,3} } //"Incluir"
Return(aRotina)
