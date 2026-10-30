#INCLUDE "gema060.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMA060   ºAutor  ³Telso Carneiro      º Data ³  24/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de Contratos                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMA060(cAlias,nReg,nCallOpcx)
Local aArea  := GetArea()

Private cCadastro:= OemToAnsi(STR0001)   // 'Cadastro de Contratos"
Private aRotina := MenuDef()
Private aCores := {{'LIT->LIT_STATUS == "1"','ENABLE'    },; // "Em aberto"
                   {'LIT->LIT_STATUS == "2"','DISABLE'   },; // "Encerrado"
                   {'LIT->LIT_STATUS == "3"','BR_CINZA'  },; // "Cancelado"
                   {'LIT->LIT_STATUS == "4"','BR_AMARELO'},; // "Cessao de direito"
                   {'LIT->LIT_STATUS == "5"','BR_PINK'   } } // "Distrato"

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

DbSelectArea("LIT")
LIT->(dbSetOrder(2)) //LIT_FILIAL+LIT_NCONTR
DbGoTop()
If nCallOpcx <> Nil
	GM060Telas(cAlias,nReg,nCallOpcx)
Else
	mBrowse(006,001,022,075,"LIT",,,,,, aCores)
EndIf


RestArea( aArea )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM060Telas³ Autor ³ Telso Carneiro        ³ Data ³ 22/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela Cadastro de Modelos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GM060TELAS(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do arquivo                                   ³±±
±±³          ³ ExpN1 - Numero do registro                                 ³±±
±±³          ³ ExpN2 - Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAGEM                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GM060Telas(cAlias,nReg,nOpc)

Local oDlgR
Local oGetCbCon
Local oGetItCon
Local nOpcX
Local nOpcGD 
Local nX
Local nUsado
Local cCpoGrv
Local aColsCON 	:={}
Local aHeadCON  :={}
Local aButtons  := {}
Local aArea     := GetArea()

If nOpc == 3 .Or. nOpc ==4
	nOpcGD := GD_UPDATE+GD_INSERT+GD_DELETE
Else     
	nOpcGD := 0
EndIf

dbSelectArea("LIU")
RegToMemory("LIU",.F.)
aHeadCON:= aClone(TableHeader("LIU"))
nUsado	:= Len(aHeadCON)

// Itens do Contrato
dbSelectArea("LIU")
dbSetOrder(3) //LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
dbSeek(xFilial("LIU")+LIT->LIT_NCONTR)
While LIU->(!eof()) .AND. (LIU->(LIU_FILIAL+LIU_NCONTR) == xFilial("LIT")+LIT->(LIT_NCONTR))
	AADD(aColsCON,Array(nUsado+1))
	For nX := 1 To Len(aHeadCON)
		cCpoGrv := FieldName(FieldPos(AllTrim(aHeadCON[nX,2])))
		aColsCON[Len(aColsCON),nX] := &cCpoGrv
	Next nX
	aColsCON[Len(aColsCON),nUsado+1] := .F.

	dbSelectArea("LIU")
	DbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 100, .t., .t. } )
AAdd( aObjects, { 100, 100, .t., .t. } )
AAdd( aObjects, { 100, 015, .t., .f. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,;
{{003,033,160,200,240,263}} )

DEFINE MSDIALOG oDlgR TITLE OemToAnsi(STR0001) From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL  //"Cadastro de Contratos" // //'Cadastro de Contratos"

dbSelectArea("LIT")
RegToMemory("LIT",.F.)

dbSelectArea("SA1")
If MsSeek( xFilial("SA1")+LIT->LIT_CLIENT+LIT_LOJA)

	If AllTrim(LIT->LIT_NOMCLI) # AllTrim(SA1->A1_NOME)
		If MsgYesNo(STR0047,STR0048)  //"Nome do cliente no contrato difere do cadastro de clientes, deseja atualizar?" # "Atenção"
			dbSelectArea("LIT")
			RecLock("LIT",.F.)
				LIT->LIT_NOMCLI := SA1->A1_NOME
				M->LIT_NOMCLI := SA1->A1_NOME
			MsUnLock()
			
		EndIf
	EndIf
	
EndIf
dbSelectArea("LIT")

oGetCbCon:=MsMGet():New("LIT",nReg,nOpc,,,,,{003,000,125,100},,,,,,oDlgR)
oGetCbCon:oBox:Align := CONTROL_ALIGN_TOP

oGetItCon := MsNewGetDados():New(002,02,097,338,nOpcGD,"AllwaysTrue","AllwaysTrue",,,,9999,,,,oDlgR,aHeadCON,aColsCON)
oGetItCon:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Aadd(aButtons,{"GROUP"    ,{|| A60ViewSol( M->LIT_NCONTR ) } ,STR0028,STR0029}) //"Cadastro de Solidarios"###"Solidarios"
aAdd(aButtons,{"PMSDOC"   ,{|| GMA060VNF() } ,OemtoAnsi(STR0005),OemtoAnsi(STR0005) } )   //"Visualiza N.Fiscal"###"Visualiza N.Fiscal"
aAdd(aButtons,{"RELATORIO",{|| IF(MsgYESNO(OemToAnsi(STR0006)),T_GEMXIPCON(aClone(aHeadCON),aClone(aColsCON)),"")  } ,OemtoAnsi(STR0007),OemtoAnsi(STR0007) } )   //"Deseja emitir o contrato ?"###"Re-emisaão"###"Re-emisaão"
aAdd(aButtons,{"TK_VERTIT",{|| A60Financ( oDlgR ,M->LIT_NCONTR ,M->LIT_REVISA ) } ,OemtoAnsi(STR0008)    ,OemtoAnsi(STR0008) } ) //"Financeiro"###"Financeiro"
aAdd(aButtons,{"NOTE"     ,{|| A60ViewHist( M->LIT_NCONTR ) } ,OemtoAnsi(STR0009),OemtoAnsi(STR0009) } ) //"Historico do Contrato"###"Historico do Contrato"

ACTIVATE MSDIALOG oDlgR ON INIT EnchoiceBar(oDlgR,{|| oDlgR:End()},{|| oDlgR:End()},,aButtons)

RestArea(aArea)

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GMA060VNF ºAutor  ³Telso Carneiro      º Data ³  24/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visulizaca da Nota Fiscal que gerou o Contrato             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMA060                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GMA060VNF()

SF2->(dbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
IF SF2->( MSSEEK(xFilial("SF2")+LIT->LIT_DOC+LIT->LIT_SERIE+LIT->LIT_CLIENT+LIT->LIT_LOJA))
 	SF2->(Mc090Visual("SF2",SF2->(Recno()),2)) 	
Endif

Return(NIL)	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontLine  ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 08.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a linha do browse                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontLine( aTitulo )                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aTitulo - Dados do titulo Corrente                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontLine( aTitulo )
Local nCount  := 0
Local aNewTit := {}
Local oReceber    := LoadBitMap(GetResources(), "BR_VERDE")
Local oParcial    := LoadBitMap(GetResources(), "BR_AZUL")
Local oBaixado    := LoadBitMap(GetResources(), "BR_VERMELHO")
Local oProtest    := LoadBitMap(GetResources(), "BR_AMARELO")
Local oProvisorio := LoadBitMap(GetResources(), "BR_CINZA")
Local oAtraso     := LoadBitMap(GetResources(), "BR_AMARELO")

Do Case
					
	Case aTitulo[1] == 1
		aAdd( aNewTit ,oReceber )
	Case aTitulo[1] == 2
		aAdd( aNewTit ,oParcial )
	Case aTitulo[1] == 3
		aAdd( aNewTit ,oBaixado )
	Case aTitulo[1] == 4
		aAdd( aNewTit ,oProtest )
	Case aTitulo[1] == 5
		aAdd( aNewTit ,oAtraso )
	Otherwise
		aAdd( aNewTit ,oProvisorio )
EndCase

For nCount := 2 to len(aTitulo)
	aAdd( aNewTit ,aTitulo[nCount])
Next nCount

Return( aNewTit )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A60ViewHis³ Autor ³ Reynaldo Miyashita    ³ Data ³ 31.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza o historico dos contratos.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A60ViewHist( cContrato )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cContrato - numero do contrato                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A60ViewHist( cContrato )

Local oBtnClose
Local oBtnView
Local oBrw
Local oDlgTit
Local oPanel1
Local oPanel2

Local aArea       := GetArea()
Local aHistor     := {}
Local aTable      := {}
Local cTitulo     := STR0015 + cContrato // //"Historico do contrato: "

	//
	// Contrato de venda - Cabecalho
	//
	dbSelectArea("LIT")
	LIT->(dbSetOrder(2)) // LIT_FILIAL+LIT_NCONTR
	If LIT->(dbSeek(xFilial("LIT")+cContrato))
		// RENEGOCIACAO
		dbSelectArea("LIZ")
		LIZ->(dbSetOrder(1)) // LIZ_FILIAL+LIZ_NCONTR+LIZ_REVISA
		If LIZ->(dbSeek(xFilial("LIZ")+cContrato))
		 	While LIZ->(!eof()) .AND. LIZ->LIZ_FILIAL+LIZ->LIZ_NCONTRAT == xFilial("LIZ")+cContrato
		 		aAdd( aHistor ,{ "" ,STR0016 ,LIZ->LIZ_REVISA ,LIZ->LIZ_DTNEG ,LIZ->LIZ_COND ,"" ,"" } ) //"Renegociação"
		 		aAdd( aTable, { LIZ->LIZ_REVISA ,"LIZ" ,LIZ->(Recno()) })
			 	LIZ->(dbSkip())
		 	EndDo
		EndIf
		// TRANSFERENCIA
		dbSelectArea("LJC")
		LJC->(dbSetOrder(1)) // LJC_FILIAL+LJC_NCONTR+LJC_REVISA
		If LJC->(dbSeek(xFilial("LJC")+cContrato))
		 	While LJC->(!eof()) .AND. LJC->LJC_FILIAL+LJC->LJC_NCONTRAT == xFilial("LJC")+cContrato
		 		aAdd( aHistor ,{ "" ,STR0017 ,LJC->LJC_REVISA ,LJC->LJC_DTTRAN ,"" ,LJC->LJC_CLIENT ,LJC->LJC_LOJA } ) //"Transferencia"
		 		aAdd( aTable, { LJC->LJC_REVISA ,"LJC" ,LJC->(Recno()) })
			 	LJC->(dbSkip())
		 	EndDo
		EndIf
		// DISTRATO
		dbSelectArea("LJD")
		LJD->(dbSetOrder(1)) // LJD_FILIAL+LJD_NCONTR+LJD_REVISA
		If LJD->(dbSeek(xFilial("LJD")+cContrato))
		 	While LJD->(!eof()) .AND. LJD->LJD_FILIAL+LJD->LJD_NCONTRAT == xFilial("LJD")+cContrato
		 		aAdd( aHistor ,{ "" ,STR0018 ,LJD->LJD_REVISA ,LJD->LJD_DTDIST ,"" ,"" ,"" } ) //"Distrato"
		 		aAdd( aTable ,{ LJD->LJD_REVISA ,"LJD" ,LJD->(Recno()) })
			 	LJD->(dbSkip())
		 	EndDo
		EndIf
		
		aSort(aHistor ,,,{|x,y| x[3]>y[3] })
		aSort(aTable  ,,,{|x,y| x[1]>y[1] })
		
		If len(aHistor) == 0
			aAdd(aHistor,{ "","","" ,"","","" })
		EndIf
		
		DEFINE MSDIALOG oDlgTit FROM 0,0  TO 350,690 TITLE cTitulo Of oMainWnd PIXEL //STYLE nOR(WS_VISIBLE,WS_POPUP)
		
		// painel principal para o browse de titulos
		oPanel1 := TPanel():New(2,2,'',oDlgTit, , .T., .T.,, ,30,30,.T.,.T. )
		oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
		// painel inferior para os botões
		oPanel2 := TPanel():New(2,2,'',oDlgTit, , .T., .T.,, ,20,20,.T.,.T. )
		oPanel2:Align := CONTROL_ALIGN_BOTTOM
	
		oBrw := TWBrowse():New( 15,15,200,70,,{"",STR0030,STR0031,STR0032,STR0033,STR0034,STR0035} ,{10,40,30,30,40,30,20},oPanel1,,,,,,,,,,,,.F.,,.T.,,.F.,,, )  //"Processo"###"Revisao"###"Data Proc."###"Cond. Pagto"###"Cliente"###"Loja"
		oBrw:SetArray(aHistor)
		oBrw:bLine := {|| aHistor[oBrw:nAT] }
		oBrw:Align := CONTROL_ALIGN_ALLCLIENT
		oBrw:bLDblClick := {|| iIf( ! Empty(aTable) ,ViewContr( aTable[oBrw:nAT] ) ,.T.) }
		
		@ 5 ,260 BUTTON oBtnView  PROMPT STR0019 SIZE 35 ,12 ACTION {|| iIf( ! Empty(aTable) ,ViewContr( aTable[oBrw:nAT] ) ,.T.) } OF oPanel2 PIXEL //"Visualizar"
		oBtnView:lActive := ! Empty(aTable)
		
		@ 5 ,300 BUTTON oBtnClose PROMPT STR0020     SIZE 35 ,12 ACTION {||oDlgTit:End() } OF oPanel2 PIXEL //"Fechar"
		
		ACTIVATE MSDIALOG oDlgTit CENTERED ON INIT (oBrw:Refresh())
		
	Else
		Alert(STR0014 + cContrato + STR0013) //"O contrato: "###" não foi encontrado. Verifique."
	EndIf	
	
	restArea( aArea )
	
Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewCont  ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 31.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza o historico dos contratos.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ViewContr( aTable )                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewContr( aTable )

Local cAlias  := aTable[2]
Local nReg    := aTable[3]
Local nOpc    := 2 // visualizar
Local aArea   := GetArea()

Private cCadastro := ""
           
	If ! Empty(cAlias)
		dbSelectArea(cAlias)
		&(cAlias)->(dbGoto(nReg))
		
		Do Case
			// renegociacao
			Case cAlias == "LIZ"
				cCadastro := OemToAnsi(STR0021)  //"Renegociação de Contrato - Visualizar"
				T_GMA100View(cAlias ,nReg ,nOpc)
				
			// transferencia
			Case cAlias == "LJC"
				cCadastro := OemToAnsi(STR0022) //"Transferencia de Contrato - Visualizar"
				T_GMA110Dlg(cAlias ,nReg ,nOpc)
				
			// distrato
			Case cAlias == "LJD"
				cCadastro := OemToAnsi(STR0023) //"Distrato de Contrato - Visualizar"
				T_GMA120Dlg(cAlias ,nReg ,nOpc)
		EndCase
	EndIf

RestArea(aArea)
	
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMA060Leg³ Autor ³ Reynaldo Miyashita   ³ Data ³06.06.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe a legenda                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GMA060Lege()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GMA060Lege()

Local aLegenda := {}
Local nCount := 0

	For nCount := 1 To len(aCores)
		Do Case
			Case aCores[nCount][1] == 'LIT->LIT_STATUS == "1"'
				aAdd( aLegenda ,{aCores[nCount][2] ,STR0024 }) //"Em Aberto"
			Case aCores[nCount][1] == 'LIT->LIT_STATUS == "2"'
				aAdd( aLegenda ,{aCores[nCount][2],STR0025 }) //"Encerrado"
			Case aCores[nCount][1] == 'LIT->LIT_STATUS == "3"'
				aAdd( aLegenda ,{aCores[nCount][2],STR0026 }) //"Cancelado"
			Case aCores[nCount][1] == 'LIT->LIT_STATUS == "4"'
				aAdd( aLegenda ,{aCores[nCount][2],STR0045 }) //"Cessão de Direito"
			Case aCores[nCount][1] == 'LIT->LIT_STATUS == "5"'
				aAdd( aLegenda ,{aCores[nCount][2],STR0046 }) //"Distrato"
			Otherwise
				aAdd( aLegenda ,{aCores[nCount][2],STR0027 }) //"Desconhecido"
		EndCase
		
	Next nCount

	BrwLegenda(cCadastro,OemToAnsi(STR0004), aLegenda) //"Legenda"

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A60ViewSo³ Autor ³ Reynaldo Miyashita   ³ Data ³06.06.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza os solidarios referente ao cliente no contrato.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A60ViewSol( cNumContr )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A60ViewSol( cNumContr )
Local aArea := GetArea()

	// cabecalho do contrato
	dbSelectArea("LIT")
	dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
	If LIT->(dbSeek(xFilial("LIT")+cNumContr))
		// permite visualizar os solidarios do contrato
		ExecTemplate("GMSOLCONT",.F.,.F.,{1 ,LIT->LIT_NCONTR ,LIT->LIT_CLIENT ,LIT->LIT_LOJA})
	Else
		Help(" ",1,"ERRCONTR",,STR0042 + cNumContr + STR0043,1) //"O contrato "###" não existe."
	EndIf

	RestArea( aArea )
	
Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A60Financ ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 06.04.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza as condicoes de venda e os titulo a receber        ³±±
±±³          ³ referente ao contrato.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A60Financ( cContrato ,cRevisa )                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cContrato - numero do contrato                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A60Financ( oDlgR ,cContrato ,cRevisa )

Local oBtnClose
Local oBtnCndVnd
Local oDlgTit

Local oPanel[3]

Local oGetDados[3]
Local oBrwTit[3]

Local oPanelButtons
Local cTitulo     := STR0010 + cContrato // "Titulos do contrato: "
Local nCount      := 0
Local aBrwCampo   := {}
Local aBrwDef     := {}
Local aHeader     := {}
Local aTamanho    := {}
Local aTitulos    := {}
Local aHeadCND    := {{},{},{}}
Local aColsCND    := {{},{},{}}
Local aItems      := {{},{},{}}
Local aTitles     := {STR0049,STR0016,STR0045}
Local aRetCM      := {}
Local lTitReneg   := .F.
Local aArea       := GetArea()

	//
	// Contrato de venda - Cabecalho
	//
	dbSelectArea("LIT")
	dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
	If dbSeek(xFilial("LIT")+cContrato)
		//
		// Nota Fiscal de Saida - Cabecalho
		//
		dbSelectArea("SF2")
		dbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
		If dbSeek(xFilial("SF2")+LIT->LIT_DOC+LIT->LIT_SERIE )
		
			aBrwCampo := {"E1_PREFIXO" ,"E1_NUM" ,"E1_PARCELA" ,"E1_TIPO" ,"E1_VENCTO" ,"E1_VALOR"}
			aTamanho := {0}
			aHeader  := {""}
			
			dbSelectArea("SX3")
			dbSetOrder(2) // X3_FILIAL+X3_CAMPO
			
			aEval(aBrwCampo ,{|x| iIf( SX3->(dbSeek(x)) ;
			                                ,( aAdd( aHeader  ,X3Titulo() )           ;
			                                  ,aAdd( aTamanho ,SX3->X3_TAMANHO*2.5) ) ;
			                                , .F. );
			                  } )
			
   			aAdd( aHeader  ,"Vlr.Amort." )
			aAdd( aHeader  ,"Vlr.Juros" )
            aAdd( aTamanho ,TamSX3("LIX_ORIAMO")[1]*2.5 )
            aAdd( aTamanho ,TamSX3("LIX_ORIJUR")[1]*2.5 )

			//	
			// Detalhes do titulos a receber
			//			                  
			dbSelectArea("LIX")
			dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
			dbSeek( xFilial("LIX")+LIT->LIT_NCONTR) 
			While LIX->(!eof()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR) == xFilial("LIT")+LIT->LIT_NCONTR
				//
				// titulos a receber
				//
				dbSelectArea("SE1")
				dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
				    
			    	lTitReneg := .F.
			    	
					//
					// Busca no SE5, as baixas do titulo a receber tanto baixa com/sem mov. bancario
					//
				    dbSelectArea("SE5")
				    dbSetOrder(7)
				    dbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
				    While SE5->(!Eof()) .AND. SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
				    	// É um titulo renegociado
						If SE5->E5_TIPODOC == "BA" .AND. SE5->E5_MOTBX == "LIQ" .and. !Empty(SE5->E5_DOCUMEN)
							lTitReneg := .T.
						EndIf
						
						dbSkip()
						
					EndDo
					
					If ! lTitReneg
					
						// titulo a receber
						If SE1->E1_VALOR == SE1->E1_SALDO
							If SE1->E1_VENCREA >= dDatabase
								nStatus := 1 // titulo a receber a vencer 
							Else
								nStatus := 5 // titulo a receber em atraso
							EndIf
						
						// titulo baixado
						ElseIf SE1->E1_SALDO == 0
							nStatus := 3
						
						// titulo a receber protestado
						ElseIf round(SE1->E1_VALOR,2) != round(SE1->E1_SALDO,2) .AND. SE1->E1_SITUACA == "F"
							nStatus := 4
						
						// titulo a recebido parcialmente
						ElseIf round(SE1->E1_VALOR,2) != round(SE1->E1_SALDO,2)
							nStatus := 2
						
						// titulo PROVISORIO
						Else 
							nStatus := 0
						
						EndIf
							
						aRetCM := GEMCMTit( LIX->(Recno()) ,iIf(Empty(SE1->E1_BAIXA) ,dDatabase ,SE1->E1_BAIXA ) )
						
						aAdd( aTitulos ,{ nStatus                                                                ;
										 ,TRANSFORM( SE1->E1_PREFIXO                   ,x3Picture("E1_PREFIXO")) ;
										 ,TRANSFORM( SE1->E1_NUM                       ,x3Picture("E1_NUM") )    ;
										 ,TRANSFORM( SE1->E1_PARCELA                   ,x3Picture("E1_PARCELA")) ;
										 ,TRANSFORM( SE1->E1_TIPO                      ,x3Picture("E1_TIPO"))    ;
										 ,TRANSFORM( SE1->E1_VENCTO                    ,x3Picture("E1_VENCTO"))  ;
										 ,TRANSFORM( SE1->E1_VALOR+aRetCM[2]+aRetCM[3] ,x3Picture("E1_VALOR"))   ;
										 ,TRANSFORM( LIX->LIX_ORIAMO+aRetCM[2]         ,x3Picture("LIX_ORIAMO")) ; 
										 ,TRANSFORM( LIX->LIX_ORIJUR+aRetCM[3]         ,x3Picture("LIX_ORIJUR")) ;
						                } )
						
					EndIf
					
				EndIf
				
				dbSelectArea("LIX")
				dbSkip()
				
			EndDo
			
			If len(aTitulos) == 0
				aAdd( aTitulos ,{ 0  ;
								 ,"" ;
								 ,"" ;
								 ,"" ;
								 ,"" ;
								 ,"  /  /  ";
								 ,"0.00" ;
								 ,"0.00" ;
								 ,"0.00" ;
				                } )
			EndIf
			
			DEFINE MSDIALOG oDlgTit FROM 0,0  TO 450,690 TITLE cTitulo Of oDlgR PIXEL //STYLE nOR(WS_VISIBLE,WS_POPUP)
			  
			oFolder := TFolder():New(0,0,aTitles,{},oDlgTit,,,, .T., .T.,0,75)
			oFolder:Align := CONTROL_ALIGN_ALLCLIENT
			For nCount := 1 to Len(oFolder:aDialogs)
				DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nCount]
			Next nCount
			
			oFolder:aDialogs[1]:oFont := oDlgTit:oFont
			oFolder:aDialogs[2]:oFont := oDlgTit:oFont
			oFolder:aDialogs[3]:oFont := oDlgTit:oFont
			
			//
			// painel inferior para os botões
			//
			oPanelButtons := TPanel():New( 100,0 ,'',oDlgTit,, .T., .T.,,, 0,25,.T.,.T. )
			oPanelButtons:Align := CONTROL_ALIGN_BOTTOM
			@ 5 ,300 BUTTON oBtnClose PROMPT STR0020       SIZE 35 ,12 ACTION {||oDlgTit:End() } OF oPanelButtons PIXEL //"Fechar"
			
			//
			// painel com condicao de venda do empreendiemnto
			//
			oPanel[1] := TPanel():New(0 ,0 ,'',oFolder:aDialogs[1],, .T., .T.,,, 0,75,.T.,.T. )
			oPanel[1]:Align := CONTROL_ALIGN_TOP

			//
			// painel com condicao de venda da renegociacao
			//
			oPanel[2] := TPanel():New(0 ,0 ,'',oFolder:aDialogs[2],, .T., .T.,,, 0,75,.T.,.T. )
			oPanel[2]:Align := CONTROL_ALIGN_TOP

			//
			// painel com condicao de pagamento do distrato
			//
			oPanel[3] := TPanel():New(0 ,0 ,'',oFolder:aDialogs[3],, .T., .T.,,, 0,75,.T.,.T. )
			oPanel[3]:Align := CONTROL_ALIGN_TOP

            //
            // carrega o aHeader e o aCols da condicao de venda
            //
			A060LJOLoad( cContrato ,SF2->F2_VALBRUT ,@aHeadCND[1] ,@aColsCND[1] )
			
			// visualiza a condicao de venda
			// item, parcelas, valor, porcentagem , tipo parcela, descricao tipo parcela, tipo sistema , taxa anual, coeficiente, indice, tipo price, residuo, parcela residuo
			nOpcGD := 0
			oGetDados[1] := MsNewGetDados():New( 5,10,25,100 ,nOpcGD ,"AllwaysTrue","AllwaysTrue",,,,9999,,,,oPanel[1],aHeadCND[1],aColsCND[1])
			oGetDados[1]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oGetDados[1]:refresh()
			
			//                                                       
			// browse de titulos a receber referentes a venda
			//
			oBrwTit[1] := TWBrowse():New( 15,0,100,70 ,,aHeader ,aTamanho ,oFolder:aDialogs[1] ,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 
			oBrwTit[1]:SetArray(aTitulos)
			oBrwTit[1]:Align := CONTROL_ALIGN_ALLCLIENT
			oBrwTit[1]:bLine := {|| MontLine(aTitulos[oBrwTit[1]:nAt]) }
			
            //
            // carrega o aHeader e o aCols da condicao de venda da renegociacao
            //
           	A060Reneg( cContrato ,cRevisa ,@aHeadCND[2] ,@aColsCND[2] ,@aItems[2] )
			
			// visualiza a condicao de venda da renegociacao
			// item, parcelas, valor, porcentagem , tipo parcela, descricao tipo parcela, tipo sistema , taxa anual, coeficiente, indice, tipo price, residuo, parcela residuo
			nOpcGD := 0
			oGetDados[2] := MsNewGetDados():New( 5,10,25,100 ,nOpcGD ,"AllwaysTrue","AllwaysTrue",,,,9999,,,,oPanel[2],aHeadCND[2],aColsCND[2])
			oGetDados[2]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oGetDados[2]:refresh()
			
			//                                                       
			// browse de titulos a receber referentes a renegociacao
			//
			oBrwTit[2] := TWBrowse():New( 15,0,100,70 ,,aHeader,aTamanho ,oFolder:aDialogs[2] ,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 
			oBrwTit[2]:SetArray(aItems[2])
			oBrwTit[2]:Align := CONTROL_ALIGN_ALLCLIENT
			oBrwTit[2]:bLine := {|| MontLine(aItems[2][oBrwTit[2]:nAt]) }
			
            //
            // carrega o aHeader e o aCols da condicao de pagamento do distrato
            //
			A060Distrato( cContrato ,cRevisa ,@aHeadCND[3] ,@aColsCND[3] ,@aItems[3] )
			
			// visualiza a condicao de pagamento do distrato
			// item, parcelas, valor, porcentagem , tipo parcela, descricao tipo parcela, tipo sistema , taxa anual, coeficiente, indice, tipo price, residuo, parcela residuo
			nOpcGD := 0
			oGetDados[3] := MsNewGetDados():New( 5,10,25,100 ,nOpcGD ,"AllwaysTrue","AllwaysTrue",,,,9999,,,,oPanel[3],aHeadCND[3],aColsCND[3])
			oGetDados[3]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oGetDados[3]:refresh()
			
			//                                                       
			// browse de titulos a pagar do distrato
			//
			                                            //"Prefixo","Numero","Parcela","Tipo","Vencimento","Valor"
			oBrwTit[3] := TWBrowse():New( 15,0,100,70 ,,{"",STR0050,STR0051,STR0052,STR0053,STR0054,STR0055} ,,oFolder:aDialogs[3] ,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 
			oBrwTit[3]:SetArray(aItems[3])
			oBrwTit[3]:Align := CONTROL_ALIGN_ALLCLIENT
			oBrwTit[3]:bLine := {|| MontLine(aItems[3][oBrwTit[3]:nAt]) }
			
			ACTIVATE MSDIALOG oDlgTit CENTERED ON INIT (aeval(oGetDados,{|oObj|oObj:Refresh()}),aeval(oBrwTit,{|oObj|oObj:Refresh()}))
			
		Else
			Alert(STR0011 + LIT->LIT_DOC +"-"+ LIT->LIT_SERIE + STR0012+ cContrato +STR0013	) //"O documento de saida: "###" do contrato: "###" não foi encontrado. Verifique."
		EndIf
		
	Else
		Alert(STR0014 + cContrato + STR0013) //"O contrato: "###" não foi encontrado. Verifique."
	EndIf	
	
	restArea( aArea )
	
Return( .T. )

//
// carrega o aHeader e o aCols
//
Static Function A060LJOLoad( cContrato ,nVlrContrato ,aHeadLJO ,aColsLJO )
Local nY          := 0
Local nPos_VALOR  := 0
Local nPos_PERCLT := 0
Local aArea       := GetArea()

	// monta o aHeadLJO
	aHeadLJO := aClone(TableHeader("LJO"))
	aEval( aHeadLJO ,{|aCampo|aCampo[2] := Alltrim(Upper(aCampo[2]))})
                   
	If Len(aColsLJO) == 0 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aColsLJO                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("LJO")
		LJO->(dbSetOrder(1)) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
		dbSeek(xFilial("LJO")+cContrato)
		While !Eof() .And. LJO->LJO_FILIAL+LJO->LJO_NCONTR==xFilial("LJO")+cContrato
			aAdd(aColsLJO ,Array(Len(aHeadLJO)+1))
			For nY := 1 to Len(aHeadLJO)
				If ( aHeadLJO[nY][10] != "V")
					aColsLJO[Len(aColsLJO)][nY] := FieldGet(FieldPos(aHeadLJO[nY][2]))
				Else
					aColsLJO[Len(aColsLJO)][nY] := CriaVar(aHeadLJO[nY][2])
				EndIf
			Next nY
			
			If (nPos_VALOR := aScan( aHeadLJO ,{|aCol| aCol[2] == "LJO_VALOR" } )) > 0
				If (nPos_PERCLT := aScan( aHeadLJO ,{|aCol| aCol[2] == "LJO_PERCLT" } )) > 0
					aColsLJO[Len(aColsLJO)][nPos_PERCLT] := Round( (aColsLJO[Len(aColsLJO)][nPos_VALOR]/nVlrContrato)*100 ,aHeadLJO[nPos_PERCLT][5])
				Endif
			EndIf
			aColsLJO[Len(aColsLJO)][Len(aHeadLJO)+1] := .F.
			
			dbSelectArea("LJO")
			dbSkip()
		EndDo
    EndIf
		    
	// Se naum tiver nenhum item
	If Empty(aColsLJO)
		aadd(aColsLJO,Array(Len(aHeadLJO)+1))
		
		For nY := 1 To Len(aHeadLJO)
			
			If Trim(aHeadLJO[nY][2]) == "LJO_ITEM"
				aColsLJO[1][nY] := StrZero(1, TamSX3("LJO_ITEM")[1])
			Else
				aColsLJO[1][nY] := CriaVar(aHeadLJO[nY][2])
			EndIf
			
		Next nY
		
		aColsLJO[1][Len(aHeadLJO)+1] := .F.
		
	Endif

RestArea(aArea)
			
Return( .T. )

//
// carrega o aHeader e o aCols referentes ao distrato do contrato
//
Static Function A060Distrato( cContrato ,cRevisa ,aHeadLJS ,aColsLJS ,aTitulos )

Local nUsado      := 0
Local nStatus     := 0
Local nY          := 0
Local nPos_FIXVNC := 0
Local nPos_VALOR  := 0
Local nPos_PERCLT := 0
Local nDecValor   := 0
Local aArea       := GetArea()

	// monta o aHeadLJS
	aHeadLJS := aClone(TableHeader("LJS"))
	nUsado := Len(aHeadLJS)
	
	// Cadastro de distrato
	dbSelectArea("LJD")
	dbSetOrder(1) // LJD_FILIAL+LJD_NCONTR+LJD_REVISA
	If dbSeek(xFilial("LJD")+cContrato)
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aColsLJS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("LJS")
		LJS->(dbSetOrder(1)) // LJS_FILIAL+LJS_NCONTR+LJS_REVISA+LJS_ITEM
		dbSeek(xFilial("LJS")+LJD->LJD_NCONTR+LJD->LJD_REVISA)
		While !Eof() .And. LJS->LJS_FILIAL+LJS->LJS_NCONTR+LJS->LJS_REVISA==xFilial("LJS")+LJD->LJD_NCONTR+LJD->LJD_REVISA
			aAdd(aColsLJS,Array(nUsado+1))
			For nY := 1 to nUsado
				If ( aHeadLJS[nY][10] != "V")
					aColsLJS[Len(aColsLJS)][nY] := FieldGet(FieldPos(aHeadLJS[nY][2]))
				Else
					aColsLJS[Len(aColsLJS)][nY] := CriaVar(aHeadLJS[nY][2])
				EndIf
			Next nY
				
			If (nPos_PERCLT := aScan( aHeadLJS ,{|x|AllTrim(x[2])=="LJS_PERCLT" })) >0
				If (nPos_VALOR := aScan( aHeadLJS ,{|x|AllTrim(x[2])=="LJS_VALOR" })) >0
					aColsLJS[Len(aColsLJS)][nPos_PERCLT] := Round( (aColsLJS[Len(aColsLJS)][nPos_VALOR]/LJD->LJD_VALDIS)*100 ,aHeadLJS[nPos_PERCLT][5])
				Endif
			EndIf
			
			aColsLJS[Len(aColsLJS)][nUsado+1] := .F.
			
			dbSelectArea("LJS")
			dbSkip()
		EndDo
		
		// Contrato
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+cContrato)
			//
			// titulos a receber
			//
			dbSelectArea("SE2")
			SE2->(dbSetOrder(1)) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			SE2->(dbSeek(xFilial("SE2")+LIT->LIT_PREFIX+LIT->LIT_DUPL))
			While SE2->(!eof()) .AND. xFilial("SE2") == SE2->E2_FILIAL ;
			      .AND. LIT->LIT_PREFIX == SE2->E2_PREFIXO ;
			      .AND. LIT->LIT_DUPL == SE2->E2_NUM

				// titulo a pagar
				If SE2->E2_VALOR == SE2->E2_SALDO
					nStatus := 1
				
				// titulo a pagar parcialmente
				ElseIf SE2->E2_VALOR != SE2->E2_SALDO
					nStatus := 2
				
				// titulo baixado
				ElseIf SE2->E2_SALDO == 0
					nStatus := 3
				
				// titulo PROVISORIO
				Else 
					nStatus := 5
				
				EndIf
			
				aAdd( aTitulos ,{ nStatus         ;
				                 ,SE2->E2_PREFIXO ;
				                 ,SE2->E2_NUM     ;
				                 ,SE2->E2_PARCELA ;
				                 ,SE2->E2_TIPO    ;
				                 ,Transform( SE2->E2_VENCTO ,x3Picture("E2_VENCTO"))  ;
				                 ,Transform( SE2->E2_VALOR ,x3Picture("E2_VALOR"))  ;
				                })
				
				dbSelectArea("SE2")
				SE2->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	// Se naum tiver nenhum item
	If Empty(aColsLJS)
		aadd(aColsLJS,Array(nUsado+1))
		For nY := 1 to Len(aHeadLJS)
			If Trim(aHeadLJS[nY][2]) == "LJS_ITEM"
				aColsLJS[1][nY] := StrZero(1, TamSX3("LJS_ITEM")[1])
			Else
				aColsLJS[1][nY] := CriaVar(aHeadLJS[nY][2])
			EndIf
			
		Next nY
		aColsLJS[1][nUsado+1] := .F.
	Endif
		
	If len(aTitulos) == 0
		aAdd( aTitulos ,{ 0         ;
		                 ,""        ;
		                 ,""        ;
		                 ,""        ;
		                 ,""        ;
		                 ," /  /  " ;
		                 ,"0.00"    ;
		                })
	EndIf
	RestArea(aArea)

Return( .T. )

//
// carrega o aHeader e o aCols referentes ao distrato do contrato
//
Static Function A060Reneg( cContrato ,cRevisa ,aHeadLJU ,aColsLJU ,aTitulos )
Local nUsado      := 0
Local nStatus     := 0
Local nY          := 0
Local nPos_FIXVNC := 0
Local nPos_VALOR  := 0
Local nPos_PERCLT := 0
Local aArea       := GetArea()

	// monta o aHeadLJU
	aHeadLJU := aClone(TableHeader("LJU"))
	nUsado := Len(aHeadLJU)
	
	// Cadastro de distrato
	dbSelectArea("LIZ")
	dbSetOrder(1) // LIY_FILIAL+LIY_PREFIX+LIY_NUM+DTOS(LIY_DTIND)+LIY_PARCEL
	If dbSeek(xFilial("LIZ")+cContrato)
		If LIZ->LIZ_TIPREG == "4"
	
			While LIZ->(!eof()) .AND. LIZ->LIZ_FILIAL+LIZ->LIZ_NCONTR == xFilial("LIZ")+cContrato
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a montagem do aColsLJU                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("LJU")
				LJU->(dbSetOrder(1)) // LJU_FILIAL+LJU_NCONTR+LJU_REVISA+LJU_ITEM
				dbSeek(xFilial("LJU")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA)
				While !Eof() .And. LJU->LJU_FILIAL+LJU->LJU_NCONTR+LJU->LJU_REVISA==xFilial("LJU")+LIZ->LIZ_NCONTR+LIZ->LIZ_REVISA
					aAdd(aColsLJU,Array(nUsado+1))
					For nY := 1 to nUsado
						If ( aHeadLJU[nY][10] != "V")
							aColsLJU[Len(aColsLJU)][nY] := FieldGet(FieldPos(aHeadLJU[nY][2]))
						Else
							aColsLJU[Len(aColsLJU)][nY] := CriaVar(aHeadLJU[nY][2])
						EndIf
					Next nY                         
					
					If (nPos_PERCLT := aScan( aHeadLJU ,{|x|AllTrim(x[2])=="LJU_PERCLT" })) >0
						If (nPos_VALOR := aScan( aHeadLJU ,{|x|AllTrim(x[2])=="LJU_VALOR" })) > 0
							aColsLJU[Len(aColsLJU)][nPos_PERCLT] := round((aColsLJU[Len(aColsLJU)][nPos_PERCLT]/LIZ->LIZ_NEGOC)*100,aHeadLJU[nPos_PERCLT][5])
						Endif
					EndIf
		   			
					aColsLJU[Len(aColsLJU)][nUsado+1] := .F.
					
					dbSelectArea("LJU")
					dbSkip()
				EndDo
				
				// Contrato
				dbSelectArea("LIT")
				dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
				If dbSeek(xFilial("LIT")+cContrato)
					//
					// titulos a receber renegociados
					//
					dbSelectArea("LJQ")
					LJQ->(dbSetOrder(1)) // LJQ_FILIAL+LJQ_NCONTR+LJQ_REVISA+LJQ_PARCEL
					LJQ->(dbSeek(xFilial("LJQ")+cContrato))
					While LJQ->(!eof()) .AND. xFilial("LJQ") == LJQ->LJQ_FILIAL .AND. ;
					      LJQ->LJQ_NCONTR == cContrato
					      
						dbSelectArea("SE1")
						dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						If dbSeek(xFilial("SE1")+LIT->LIT_PREFIX+LIT->LIT_DUPL+LJQ->LJQ_PARCEL+LJQ->LJQ_TIPO)
				
							// titulo a receber
							If SE1->E1_VALOR == SE1->E1_SALDO
								nStatus := 1
						
							// titulo baixado
							ElseIf SE1->E1_SALDO == 0
								nStatus := 3
							
							// titulo a receber protestado
							ElseIf round(SE1->E1_VALOR,2) != round(SE1->E1_SALDO,2) .AND. SE1->E1_SITUACA == "F"
								nStatus := 4
							
							// titulo a recebido parcialmente
							ElseIf round(SE1->E1_VALOR,2) != round(SE1->E1_SALDO,2)
								nStatus := 2
							
							// titulo PROVISORIO
							Else 
								nStatus := 5
							
							EndIf
					
							aAdd( aTitulos ,{ nStatus         ;
							                 ,SE1->E1_PREFIXO ;
							                 ,SE1->E1_NUM     ;
							                 ,SE1->E1_PARCELA ;
							                 ,SE1->E1_TIPO    ;
							                 ,Transform( SE1->E1_VENCTO ,x3Picture("E1_VENCTO"));
							                 ,Transform( SE1->E1_VALOR  ,x3Picture("E1_VALOR")) ;
							                })
					
						EndIf
						dbSelectArea("LJQ")
						LJQ->(dbSkip())
					EndDo
				
				EndIf
		
				LIZ->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	// Se naum tiver nenhum item
	If Empty(aColsLJU)
		aadd(aColsLJU,Array(nUsado+1))
		For nY := 1 to Len(aHeadLJU)
			If Trim(aHeadLJU[nY][2]) == "LJU_ITEM"
				aColsLJU[1][nY] := StrZero(1, TamSX3("LJU_ITEM")[1])
			Else
				aColsLJU[1][nY] := CriaVar(aHeadLJU[nY][2])
			EndIf
			
		Next nY
		aColsLJU[1][nUsado+1] := .F.
	Endif
		
	If len(aTitulos) == 0
		aAdd( aTitulos ,{ 0         ;
		                 ,""        ;
		                 ,""        ;
		                 ,""        ;
		                 ,""        ;
		                 ," /  /  " ;
		                 ,"0.00"    ;
		                })
	EndIf
	RestArea(aArea)
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
Local aRotina  := {{OemToAnsi(STR0002) ,"AxPesqui"   , 0 ,1,,.F.},;  // 'Pesquisar"
                   {OemToAnsi(STR0003) ,"GM060Telas" , 0 ,2},;  // 'Visualizar"
                   {OemToAnsi(STR0044) ,"MSDOCUMENT" , 0 ,4},;  // "Conhecimento"
                   {OemToAnsi(STR0004) ,"GMA060Lege" , 0 ,6,,.F.} }  // "Legenda"
Return(aRotina)
