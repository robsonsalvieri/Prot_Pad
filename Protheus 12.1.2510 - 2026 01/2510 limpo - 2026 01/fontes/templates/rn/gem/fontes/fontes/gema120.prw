#include "GEMA120.ch"
#include "protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMA120   บAutor  ณReynaldo Miyashita  บ Data ณ  13.05.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento do Distrato de contrato                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GEMA120()
Local aArea   := GetArea()
Private nSaldo   := 0
Private aRotina := MenuDef()

Private cCadastro := OemToAnsi(STR0004) //"Distrato de Contrato"

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

// inclui um motivo de baixa
GEMMOT()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEndereca para a funcao MBrowse                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("LJD")
dbSetOrder(1) // LJD_FILIAL+LJD_NCONTR+LJD_REVISA
MsSeek(xFilial("LJD"))
mBrowse(06,01,22,75,"LJD")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a Integridade da Rotina                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("LJD")
dbSetOrder(1) // LJD_FILIAL+LJD_NCONTR+LJD_REVISA
dbClearFilter()

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณGMA120Dlg ณ Autor ณ Reynaldo Miyashita    ณ Data ณ 13.05.2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRotina de Distrato do contrato                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณT_GMA120Dlg()                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1: Alias do Arquivo                                       ณฑฑ
ฑฑณ          ณExpN2: Numero do Registro                                     ณฑฑ
ฑฑณ          ณExpN3: Opcao do aRotina                                       ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Template Function GMA120Dlg(cAlias,nReg,nOpc)

Local lA120Inclui := .F.
Local lA120Visual := .F.
Local lA120Altera := .F.
Local lA120Exclui := .F.
Local lContinua   := .T.
Local lOk         := .F.

Local cCpoGrv     := ""
Local nRecLJD     := 0
Local nOpcGD      := 0
Local nX          := 0
Local aConjLJS    := {}
Local aSize       := {}
Local aObjects    := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aButtons    := {}
Local aUsrButtons := {}
Local aArea       := GetArea()

Local oDlg 
Local oPanel1
Local aTitulos    := {}

Private oBrw

Private aGets[0]
Private aTela[0][0]
Private oEnch 


// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case (aRotina[nOpc][4] == 2)
		lA120Visual := .T.
	Case (aRotina[nOpc][4] == 3)
		Inclui      := .T.
		lA120Inclui := .T.
	Case (aRotina[nOpc][4] == 4)
		Altera      := .T.
		lA120Altera := .T.
	Case (aRotina[nOpc][4] == 5)
		lA120Exclui := .T.
		lA120Visual := .T.
EndCase

aCampos := {}
dbSelectArea("SX3")
dbSetOrder(1) // X3_FILIAL+X3_CAMPO
dbSeek("LJD")
While !Eof() .and. SX3->X3_ARQUIVO == "LJD"
	If X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
		aAdd(aCampos,AllTrim(SX3->X3_CAMPO))
	EndIf
	dbSkip()
End

If !lA120Inclui
	If lA120Altera.Or.lA120Exclui
		If !SoftLock("LJD")
			lContinua := .F.
		Else
			nRecLJD := LJD->(RecNo())
		Endif
		
		// verifica o status do contrato
		lContinua := T_GMContrStatus( LJD->LJD_NCONTRAT )
		
	EndIf

EndIf       

If lContinua

	RegToMemory( "LJD" ,lA120Inclui )
	If lA120Inclui
		M->LJD_FILIAL := xFilial("LJD")
	EndIf
	
	If lA120Visual
		M->LJD_PERDIS := ROUND((M->LJD_VALDIS/M->LJD_SALDO)*100 ,TamSx3("LJD_PERDIS")[2])
	EndIf
		
	aAdd(aButtons,{"PMSDOC",{|| ViewBordero() } ,OemtoAnsi(STR0015),OemtoAnsi(STR0015) } ) //"Bordero"
	aadd(aButtons,{"RELATORIO",{||a120DLGCVN( aRotina[nOpc][4] ,M->LJD_NCONTR ,M->LJD_REVISA ,M->LJD_COND ,dDataBase ,M->LJD_VALDIS ,@aConjLJS ) },"Condicao de Venda", "Condicao de Venda" })
	If lA120Visual
		aAdd(aButtons,{"PMSDOC",{|| T_GMViewContr(M->LJD_NCONTR,M->LJD_REVISA ) } ,OemtoAnsi(STR0005),OemtoAnsi(STR0006) } ) //"Visualiza o Contrato"###"Contrato"
	EndIf
	
	// caso exista a rotina, sera incluido os botoes especificos.
	If ExistBlock("GMA120BTN")
		If ValType( aUsrButtons := ExecBlock( "GMA120BTN",.F., .F. ) ) == "A"
			aEval( aUsrButtons, { |x| aAdd( aButtons, x ) } )
		EndIf
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz o calculo automatico de dimensoes de objetos     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aAdd( aObjects, { 200, 200, .T., .T. } )
	aSize   := MsAdvSize()
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
                                                                              
	oEnch := MsMGet():New("LJD",LJD->(RecNo()),nOpc,,,,,aPosObj[1],aCampos,3,,,,oDlg)
	oPanel1 := TPanel():New(aPosObj[2,1],aPosObj[2,2],'',oDlg, ,.T.,.T.,, ,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],.T.,.T. )
	@005,010 LISTBOX oBrw FIELDS TITLE   STR0016    ,STR0017         ,STR0018     ,STR0019      ;
										,STR0020 , STR0021 ,STR0022 ,STR0023  ;
										,STR0024      ,STR0025     ,STR0026  ,STR0027 ;
										,STR0028 ;
	                          SIZE 370,100 OF oPanel1 PIXEL

	MsAguarde({|| aTitulos := A120LoadTitulo(M->LJD_NCONTR ,M->LJD_REVISA ,lA120Visual )},STR0029)  //Carregando titulos...
	// carrega e formata as parcelas a receber do contrato
	GMA120BrwRefresh( aTitulos )
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf( Obrigatorio(aGets,aTela) .AND. A120ValDlg( aConjLJS );
	                                                       ,(lOk := .T.,oDlg:End()) ;
	                                                       ,lOk := .F. ) ;
	                                                },{||(lOk := .F.,oDlg:End())},,aButtons)
  
	If lOk .AND. (lA120Inclui .Or. lA120Altera .Or. lA120Exclui)
		Begin Transaction
			Processa({|| A120Grava(lA120Altera,lA120Exclui,nRecLJD,aConjLJS) },STR0007,STR0008,.F.)  //"Processando os titulos do contrato"###"Aguarde..."
		End Transaction
	EndIf
	
EndIf

RestArea( aArea )
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA120ValDlgบAutor  ณReynaldo Miyashita  บ Data ณ  17.05.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento para validacao da tela.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A120ValDlg( aConjLJS )
Local aArea     := GetArea()
Local lOk       := .T.
Local nPosValor := 0
Local nVlrTotal := 0
Local nQtdCnd   := 0
Local nCount 	:= 0
DEFAULT aConjLJS := {}

	// Valida os titulos a receber do contrato
	MsAguarde({||lOk := VldTitRec()} ,STR0030)  //Validando titulos...
	
	If lOk
	 	// se houver valor de distrato, deve validar a condicao de venda
		If M->LJD_VALDIS > 0
			// se naum foi informado a condicao de pagamento
			If Empty(M->LJD_COND) 
				Help(" ",1,"GEMA120COND",,STR0010,1) //"Nใo foi informado a condi็ใo de pagamento"
				lOk := .F.
			Else
				If M->LJD_COND <> GetMV("MV_GMCPAG")
					// se existe a condicao de pagamento
					dbSelectArea("SE4")
					dbSetOrder(1) // E4_FILIAL+E4_CODIGO
					lOk := dbSeek(xFilial("SE4")+M->LJD_COND)
				Else    
					If (Len(aConjLJS)>2) 
						// se encontrar a coluna LJS_VALOR
						If (nPosValor := aScan(aConjLJS[2] ,{|e|Trim(e[2])=="LJS_VALOR"})) > 0
							aEval( aConjLJS[3] ,{|aColuna| iIf( !aColuna[Len(aColuna)] ;
						                                       ,nVlrTotal += aColuna[nPosValor] ;
						                                       ,.F. )})
				
							If (nVlrTotal <> M->LJD_VALDIS )
								MsgAlert(STR0031)      //"Existe diferen็a entre o valor do Distrato e a soma dos valores dos titulos a pagar."
								lOk := .F.
							EndIf
							
							nQtdCnd := aScan(aConjLJS[2], {|x| alltrim(x[2])==alltrim("LJS_NUMPAR")})		
			
							For nCount := 1 to Len(aConjLJS[3]) 
								If (aConjLJS[3][nCount][nQtdCnd] == 0) .AND. !(aConjLJS[3][nCount][Len(aConjLJS[3][nCount])])
									Alert(STR0064)  //"Existe quantidade zerada em algum item desta condi็ใo. Favor verificar." 
									lOk := .F.										
									Exit								
								Endif
							Next nCount

						EndIf
					Else
						MsgAlert(STR0032) //"Nใo foi definido os titulos a pagar do distrato."
						lOk := .F.
					EndIf
		        EndIf
			EndIf
				
		//
		// se nao tem valor de distrato
		//
		Else
			// Se foi informado a condicao de pagamento
			If Empty(M->LJD_COND)
				MsgAlert(STR0033)  //"Nใo foi informado o valor do distrato para a condi็ใo de pagamento escolhida."
				lOk := .F.    
			ElseIf nSaldo == 0 .and. ( M->LJD_PERDIS == 100 )
				lOk := .T.    											
			elseIf nSaldo <> 0 .and. ( M->LJD_PERDIS == 0)
				If MsgYesNo(STR0034) //"Tem certeza que nada serแ pago ao cliente referente a este distrato?"
					lOk := .T.    											
				ELSE
					lOk := .F.    															
				EndIf
			EndIf
		EndIf  
		
		// Se for um distrato sem movimentacao financeira
		If lOk .AND. (M->LJD_VALDIS == 0) .AND. Empty(M->LJD_COND) 
			// pede confirmacao para continuar.
			lOk := Aviso( STR0035 ,STR0036;          //"Nใo foi informado valor de distrato, nใo serแ gerado o cadastro de fornecedor e os tํtulos a pagar."
			                          +STR0037 ;     //" Deseja continuar?"
			                   ,{STR0038 ,STR0039} ,3 ) == 1     // Sim ## Nao
		EndIf
		
		If lOk 
			// Faz ou naum a inclusao do fornecedor com dados do 
			// cliente conforme escolha do usuario
			lOk := a120VldForn( M->LJD_NCONTR ,@M->LJD_FORNECE ,@M->LJD_LOJA ,(M->LJD_VALDIS >= 0) )
		EndIf
		
   	EndIf
   			
	RestArea( aArea )
	
Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMA120GravบAutor  ณReynaldo Miyashita  บ Data ณ  13.05.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento para gravacao da tabela LJD                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A120Grava(lA120Altera ,lA120Exclui ,nRecLJD ,aConjLJS)
Local bCampo      := {|n| FieldName(n) }
Local nY          := 0
Local nCount      := 0
Local nCnt2       := 0
Local nQtdParc    := 0
Local nMoeda      := 1
Local nPos        := 0
Local lErro       := .F.
Local cParcela    := ""
Local cNewRevisa  := ""
Local cMsgHist    := ""
Local aRecord     := {}
Local aVetor      := {}
Local aRetCpos
Local aArea       := GetArea()
Local cFilLIW     := xFilial("LIW")
Local cForNat		:= ""

If ! lA120Exclui

	If ! lA120Altera                                                   
		Begin Transaction
		// LIT - cadastro de contratos
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+M->LJD_NCONTR)
		    // nova revisao
			cNewRevisa := Soma1(LIT->LIT_REVISA)
			
			//
			// procura a moeda na nota fiscal (SF2)
			//           
			dbSelectArea("SF2")
			dbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
			If MsSeek(xFilial("SF2")+LIT->LIT_DOC+LIT->LIT_SERIE)
				nMoeda := SF2->F2_MOEDA
			Else
				nMoeda := 1
			EndIf
			
			//
			// Grava Historico do Contrato
			//
			t_GMHistContr( M->LJD_NCONTR ,M->LJD_REVISA ,cNewRevisa ,,,,"5") //lit_status=5(distrato)
			
			// itens da condicao de venda customizado do contrato
			dbSelectArea("LJO")
			dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
			If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR)
				// Obtem a quantidade de titulos a receber
				nQtdParc := 0
				While LJO->(!eof()) .AND. LJO->LJO_FILIAL+LJO->LJO_NCONTR==xFilial("LJO")+LIT->LIT_NCONTR
					nQtdParc += LJO->LJO_NUMPAR
					dbSkip()
				EndDo
			Endif
			
			ProcRegua( nQtdParc )
			
			//
			// LIX - Detalhes do titulos a receber
			// Converter de titulo provisorio para definitivo caso, existir
			//
			dbSelectArea("LIX")
			dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
			dbSeek( xFilial("LIX")+LIT->LIT_NCONTR )
			While LIX->(!Eof()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR) == xFilial("LIX")+LIT->LIT_NCONTR .AND. !lErro
				//
				// SE1 - Titulos a receber
				// Converter de titulo provisorio para definitivo caso, existir
				//
				dbSelectArea("SE1")
				dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
				  
					IncProc()
					
					// Titulo A RECEBER em aberto 
					If SE1->E1_SALDO >0 
				    
						// se o titulo for provisorio deve alterar para tipo Nota Fiscal
						If SE1->E1_TIPO == MVPROVIS
							aRecord := {}
					
							dbSelectArea("SE1")
							RecLock("SE1",.F.,.T.)
							For nCount := 1 to FCount()
								aAdd( aRecord ,FieldGet( nCount ) )
							Next nCount                                                                    
						
							SE1->(dbDelete())
							SE1->(MsUnlock())
								
							RecLock("SE1",.T.)
							For nCount := 1 to Len(aRecord)
								SE1->(FieldPut( nCount ,aRecord[nCount] ))
							Next nCount
							SE1->E1_TIPO := MVNOTAFIS
							SE1->(MsUnlock())
							
							//
							// LIX - Detalhes do titulos a receber
							// Converter de titulo provisorio para definitivo caso, existir
							//
							dbSelectArea("LIX")
							dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
							If MsSeek( xFilial("LIX")+SE1->E1_PREFIXO +SE1->E1_NUM+SE1->E1_PARCELA+MVPROVIS )
							
								aRecord := {}
								
								dbSelectArea("LIX")
								RecLock("LIX",.F.,.T.)
								For nCount := 1 to FCount()
									aAdd( aRecord ,FieldGet( nCount ) )
								Next nCount
								LIX->(dbDelete())
								LIX->(MsUnlock())
							
								RecLock("LIX",.T.)
								For nCount := 1 to Len(aRecord)
							   		FieldPut( nCount ,aRecord[nCount] )
								Next nCount
								LIX->LIX_TIPO := MVNOTAFIS
								LIX->(MsUnlock())
							EndIf
								
							//
							// Valor de correcao monetaria dos titulos a receber
							// Converter de titulo provisorio para definitivo caso, existir
							//
							dbSelectArea("LIW")
							dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
							If DbSeek( cFilLIW+SE1->E1_PREFIXO +SE1->E1_NUM+SE1->E1_PARCELA+MVPROVIS+LIT->LIT_FECHAM )

								aRecord := {}

								dbSelectArea("LIW")
								RecLock("LIW",.F.,.T.)
								For nCount := 1 to FCount()
									aAdd( aRecord ,FieldGet( nCount ) )
								Next nCount
								LIW->(dbDelete())
								LIW->(MsUnlock())
								
								RecLock("LIW",.T.)
								For nCount := 1 to Len(aRecord)
									FieldPut( nCount ,aRecord[nCount] )
								Next nCount
								LIW->LIW_TIPO := MVNOTAFIS
								LIW->(MsUnlock())
							
							EndIf
						EndIf

						// Define o texto pro historico da baixa do titulo
						If SE1->E1_SALDO < SE1->E1_VALOR
							cMsgHist := "Baixa Parcial Renegociacao-Distrato"
						Else //If SE1->E1_SALDO == 0
							cMsgHist := "Baixa Total Renegociacao-Distrato"
						EndIf
				
						//
						// alimenta o array para baixa do titulo pela rotina fina070()
						//
						aVetor := {	{"E1_PREFIXO",SE1->E1_PREFIXO,Nil } ;
	  							   ,{"E1_NUM"         ,SE1->E1_NUM    ,Nil } ;
								   ,{"E1_PARCELA"     ,SE1->E1_PARCELA,Nil } ;
								   ,{"E1_TIPO"        ,SE1->E1_TIPO   ,Nil } ;
								   ,{"AUTMOTBX"       ,"DIS"          ,Nil } ;
								   ,{"AUTDTBAIXA"     ,dDataBase      ,Nil } ;
								   ,{"AUTHIST"        ,cMsgHist       ,Nil } ;
								   ,{"AUTBANCO"       ,""             ,Nil } ;
								   ,{"AUTAGENCIA"     ,""             ,Nil } ;
								   ,{"AUTCONTA"       ,""             ,Nil } ;
								   ,{"AUTJUROS"       ,0              ,Nil ,.T. } ;
								   ,{"AUTMULTA"       ,0              ,Nil ,.T. } ;
								   ,{"AUTCM1"         ,0              ,Nil ,.T. } ;
								   ,{"AUTPRORATA"     ,0              ,Nil ,.T. } ;
				 				   ,{"AUTVALREC"      ,SE1->E1_SALDO  ,Nil } }
						lMsErroAuto := .F.
				 	  	MSExecAuto({|x,y| fina070(x,y)},aVetor,3)
						If lMsErroAuto
							Alert("Erro ao Baixar parcela no Contas a Receber! (Pref/Num/Parc: " + SE1->E1_PREFIXO + "/" + SE1->E1_NUM + "/" + SE1->E1_PARCELA + ")")
							lErro := .T.
							MostraErro()
						EndIf
					
					EndIf

					// deleta as correcoes posteriores a data de fechamento de existir
					LIW->( DbSeek( cFilLIW+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA ) )
					While cFilLIW+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA==LIW->(LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL)
						If LIT->LIT_FECHAM < LIW->LIW_DTREF // deleta correcoes posteriores a data de fechamento se existir
							RecLock("LIW",.F.,.T.)
							LIW->(dbDelete())
							LIW->(MsUnlock())
						EndIf
						LIW->(DbSkip())
					EndDo

				EndIf
				
				dbSelectArea("LIX")
				dbSkip()
			EndDo

			// atualiza a data de correcao no contrato(LIT)
			If LIT->LIT_DTCM > LIT->LIT_FECHAM
				RecLock("LIT",.F.,.T.)
				LIT->LIT_DTCM := LIT->LIT_FECHAM
				LIT->(MsUnlock())
			EndIf

			// SE existe saldo a pagar, deve gerar os titulos a pagar 
			// e cadastrar o fornecedor com os dados do clientes
			If M->LJD_VALDIS > 0
				// Cadastro de Fornecedores
				dbSelectArea("SA2")
				dbSetOrder(1) // A2_FILIAL+A2_COD+A2_LOJA
				If dbSeek( xFilial("SA2")+M->LJD_FORNEC+M->LJD_LOJA )
					//
					// se for uma condicao de venda personalizada.
					//
					cForNat := SA2->A2_NATUREZ
					If M->LJD_COND == GetMV("MV_GMCPAG")
					
						// Copia a condicao de venda personalizada do pedido de venda para o contrato
						dbSelectArea("LJS")
						For nCount := 1 to Len(aConjLJS[3])
						
							RecLock("LJS",.T.)
							
							LJS->LJS_FILIAL := xFilial("LJS")
							LJS->LJS_NCONTR := LIT->LIT_NCONTR
							LJS->LJS_REVISA := M->LJD_REVISA
							
							For nCnt2 := 1 to FCount()   
								nPos := aScan( aConjLJS[2] ,{|aHeader|alltrim(aHeader[2])==alltrim(FieldName(nCnt2)) })
								If nPos >0 
									LJS->(FieldPut( nCnt2 ,aConjLJS[3][nCount][nPos] ))
								EndIf
							Next nCnt2
							LJS->(MsUnLock())
							
						Next nCount
						
						// gera os tiulos a pagar
						aTitulos := a120GeraDupl( aConjLJS[2] ,aConjLJS[3] ,4 )
						
					//
					// condicao de venda padrao
					//
					Else
						// Condicao de pagamento
						dbSelectArea("SE4")
						dbSetOrder(1) // E4_FILIAL+E4_CODIGO
						If dbSeek(xFilial("SE4")+M->LJD_COND)
							// Condicao de venda
							dbSelectArea("LIR")
							dbSetOrder(1) // LIR_FILIAL+LIR_CODCND
							If dbSeek(xFilial("LIR")+SE4->E4_CODCND)
							    
								aConjLJS := {"",{},{}}
							
								// Itens da Condicao de venda
								dbSelectArea("LIS")
								dbSeek(xFilial("LIS")+LIR->LIR_CODCND)
							
								// Copia a condicao de venda referenciado na condicao de pagamento do 
								// pedido de venda para o contrato
								While LIS->(!eof()) .AND. LIS->LIS_FILIAL+LIS->LIS_CODCND==xFilial("LIR")+LIR->LIR_CODCND
								
									RecLock("LJS",.T.)
									
									LJS->LJS_FILIAL := xFilial("LIS")
									LJS->LJS_NCONTR := M->LJD_NCONTR
									LJS->LJS_REVISA := M->LJD_REVISA
									
									LJS->LJS_ITEM   := LIS->LIS_ITEM
									LJS->LJS_NUMPAR := LIS->LIS_NUMPAR
									LJS->LJS_VALOR  := M->LJD_VALDIS*(LIS->LIS_PERCLT/100)

									LJS->LJS_TIPPAR := LIS->LIS_TIPPAR
									LJS->LJS_TPDESC := LIS->LIS_TPDESC
									LJS->LJS_FIXVNC := "2" // nao tem data fixa
									LJS->LJS_1VENC  := dDataBase
									LJS->LJS_IND    := LIS->LIS_IND
									LJS->LJS_DIACOR := LIS->LIS_DIACOR
									
									LJS->(MSUnLock())
									
									LIS->(dbSkip())
									
								EndDo
								aConjLJS := {}
								A120LJSLoad( .T. ,M->LJD_NCONTR ,M->LJD_REVISA ,M->LJD_COND ,,M->LJD_VALDIS ,@aConjLJS )
								// gera os tiulos a pagar
								aTitulos := a120GeraDupl( aConjLJS[2] ,aConjLJS[3] ,4 )
							
							Else
								//
								// Monta os titulos a pagar conforme a condicao de pagamento
								//
								aTitulos := Condicao(M->LJD_VALDIS ,M->LJD_COND,0,dDataBase,0)
							EndIf
							
						EndIf // busca pela condicao de venda
					EndIf // condicao de venda customizado
					
					//
					// Gera os titulos a pagar
					//
					cParcela := GetMV("MV_1DUP")
					ProcRegua( Len(aTitulos) )
					For nCount := 1 to Len(aTitulos)
						
						IncProc()

						aCampos :={}
						aAdd( aCampos ,{"E2_FILIAL"  ,xFilial("SE2")                    ,Nil})
						aAdd( aCampos ,{"E2_PREFIXO" ,LIT->LIT_PREFIX                   ,Nil})
						aAdd( aCampos ,{"E2_NUM"     ,LIT->LIT_DUPL                     ,Nil})
						aAdd( aCampos ,{"E2_PARCELA" ,cParcela                          ,Nil})
						aAdd( aCampos ,{"E2_TIPO"    ,"NF"                              ,Nil}) // NF- "Nota Fiscal"
						aAdd( aCampos ,{"E2_NATUREZ" ,cForNat                           ,Nil})
						aAdd( aCampos ,{"E2_FORNECE" ,SA2->A2_COD                       ,Nil})
						aAdd( aCampos ,{"E2_LOJA"    ,SA2->A2_LOJA                      ,Nil})
						aAdd( aCampos ,{"E2_NOMFOR"  ,iIf( empty(SA2->A2_NREDUZ) ; 
									                      ,SA2->A2_NOME ,SA2->A2_NREDUZ),Nil})
						aAdd( aCampos ,{"E2_EMISSAO" ,dDatabase                         ,Nil})
						
						aAdd( aCampos ,{"E2_VENCTO"  ,aTitulos[nCount][1]               ,Nil})
						aAdd( aCampos ,{"E2_VENCREA" ,DataValida(aTitulos[nCount][1])   ,Nil})
						aAdd( aCampos ,{"E2_VALOR"   ,xMoeda( aTitulos[nCount][2],1 ;
						                                     ,nMoeda,dDataBase)         ,Nil})
						aAdd( aCampos ,{"E2_HIST"    ,"DISTRATO: " + M->LJD_NCONTR      ,Nil})
						aAdd( aCampos ,{"E2_EMIS1"   ,SE2->E2_EMISSAO                   ,Nil})
						aAdd( aCampos ,{"E2_SALDO"   ,aTitulos[nCount][2]               ,Nil})
						aAdd( aCampos ,{"E2_VENCORI" ,aTitulos[nCount][1]               ,Nil})
						aAdd( aCampos ,{"E2_MOEDA"   ,nMoeda                            ,Nil})
						aAdd( aCampos ,{"E2_VLCRUZ"  ,aTitulos[nCount][2]               ,Nil})
			   	
							If ExistBlock("GM120Distr")
								aRetCpos := Execblock("GM120Distr", .F.,.F.,{aCampos})
								If ValType(aRetCpos) == "A"
									aCampos := {}
									aCampos := aClone(aRetCpos)
								Else                                                                        
									// tratamento necessario porque se o retorno nao for um array, irแ dar erro na rotina automatica
									// 
									Alert(STR0013+chr(13)+chr(10)+STR0014) // O P.E. nao esta retornando um Array.
									Final(STR0013)   //O sistema finalizarแ para manter integridade dos dados.
								EndIf
							EndIf
						lMsErroAuto := .F.
						MsExecAuto({|x,y|FINA050(x,y)},aCampos,3)
						  
						If lMsErroAuto
								Alert(STR0044)     // Nao foi possivel gerar titulos no Contas a Pagar
							MostraErro()
								
								Final(STR0014)//O sistema finalizara para manter integridade dos dados.
						EndIf
						
						If Len(aConjLJS)>2 .AND. (Len(aConjLJS[2]) > 0 .AND. Len(aConjLJS[3]) > 0)
							//
							// Detalhes do titulo a pagar
							//
							dbSelectArea("LJV")
							dbSetOrder(1) // LJV_FILIAL+LJV_PREFIX+LJV_NUM+LJV_PARCEL+LJV_TIPO
							RecLock("LJV",.T.) 
								LJV->LJV_FILIAL	:= xFilial("LJV")
								LJV->LJV_PREFIX	:= LIT->LIT_PREFIX
								LJV->LJV_NUM   	:= LIT->LIT_DUPL
								LJV->LJV_PARCEL	:= cParcela
								LJV->LJV_TIPO  	:= "NF"
								LJV->LJV_CODCND	:= M->LJD_COND
								LJV->LJV_ITCND  := aTitulos[nCount][3]
								LJV->LJV_DTVENC	:= aTitulos[nCount][1]
								LJV->LJV_AMORT  := aTitulos[nCount][2]-aTitulos[nCount][5]
//								LJV->LJV_VALJUR := 0 
//								LJV->LJV_CMAMO  := 0 
//								LJV->LJV_CMJUR  := 0 

							MsUnLock()
						EndIf
						
						cParcela := MaParcela( cParcela )
						SE2->(MsUnlock())
						
					Next nCount
				EndIf
			EndIf

			//
			// Altera o Status do Unidade vendida para livre
			//         
			dbSelectArea("LIU")
			dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
			dbSeek(xFilial("LIU")+LIT->(LIT_NCONTR))
			While LIU->(!Eof()) .AND. ;
			      LIU->(LIU_FILIAL+LIU_NCONTR)==xFilial("LIU")+LIT->LIT_NCONTR
				
				dbSelectArea("LIQ")
				dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
				If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
					RecLock("LIQ",.F.,.T.)
						LIQ->LIQ_STATUS := "LV"
					LIQ->(MsUnlock())
				EndIf
				
				dbSelectArea("LIU")
				LIU->(dbSkip())
			EndDo

			//
			// Grava o Distrato do contrato
			//
			RecLock("LJD",.T.)
				For nCount := 1 TO FCount()
					LJD->(FieldPut(nCount,M->&(EVAL(bCampo,nCount))))
				Next nCount
			LJD->(MsUnlock())
				
				// P.E. para manipulacao dos dados na LJD
				If ExistBlock("GM120LJD")
					Execblock("GM120LJD", .F.,.F.)
				EndIf
	
			Else
				// nao encontrou o contrato                                            
			EndIf
	
		End Transaction 	
	EndIf
Endif
	
RestArea( aArea )
	
Return( .T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMA120BrwTบAutor  ณReynaldo Miyashita  บ Data ณ  13.05.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Array com os titulos                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
TEMPLATE Function GMA120BrwTit( cContrato ,cRevisa ,lVisual )
Local aTitulos := {}
                                   
Default lVisual := .F.

	CursorWait()
	
	MsAguarde({|| aTitulos := A120LoadTitulo( cContrato ,cRevisa ,lVisual )},STR0029)
	nSaldo := 0
	aEval( aTitulos ,{|aTit| nSaldo += aTit[6] })
	
	GMA120BrwRefresh( aTitulos )
    
	CursorArrow()

Return( nSaldo )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMA120BrwRบAutor  ณReynaldo Miyashita  บ Data ณ  15.02.2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o browse de titulos a receber pagos do contrato   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GMA120BrwRefresh( aTitulos )
Local nX        := 0
Local lContinua := .T.

	If Type("oBrw")=="U"
		lContinua := .F.
	EndIf
	
	If lContinua
		
		oBrw:SetArray( aTitulos )
		oBrw:bLine := {|| { aTitulos[oBrw:nAt, 2]                                    ,aTitulos[oBrw:nAt, 3] ;
		                   ,aTitulos[oBrw:nAt, 4]                                    ,Transform( aTitulos[oBrw:nAt, 5] ,x3Picture("E1_VALOR")) ;
	 			           ,Transform( aTitulos[oBrw:nAt, 6] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oBrw:nAt, 7] ,x3Picture("E1_VALOR")) ;
	 			           ,Transform( aTitulos[oBrw:nAt, 8] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oBrw:nAt, 9] ,x3Picture("E1_VALOR")) ;
	 			           ,Transform( aTitulos[oBrw:nAt,10] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oBrw:nAt,11] ,x3Picture("E1_VALOR")) ;
	 			           ,Transform( aTitulos[oBrw:nAt,12] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oBrw:nAt,13] ,x3Picture("E1_VALOR")) }}
		oBrw:Align := CONTROL_ALIGN_ALLCLIENT
		oBrw:Refresh(.f.)
	EndIf
	
Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMA120DisPบAutor  ณReynaldo Miyashita  บ Data ณ  16.05.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a soma das porcentagens de distratos dos           บฑฑ
ฑฑบ          ณ empreendimentos envolvidos no contrato.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMA120DisPerc( cContrato )
Local nPercent := 0
Local aArea    := GetArea()
Local aAreaLIT := LIT->(GetArea())

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	// busca o contrato
	dbSelectArea("LIT")	
	dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
	If dbSeek( xFilial("LIT")+cContrato )
		// busca item do contrato
		dbSelectArea("LIU")	
		dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
		If dbSeek( xFilial("LIU")+LIT->LIT_NCONTR )
			While LIU->(!eof()) .AND. xFilial("LIU")+LIU->LIU_DOC+LIU->LIU_SERIE+LIU->LIU_CLIENT+LIT->LIT_LOJA == ;
			      LIT->LIT_FILIAL+LIT->LIT_DOC+LIT->LIT_SERIE+LIT->LIT_CLIENT+LIT->LIT_LOJA
				// busca O EMPREENDIMENTO
				dbSelectArea("LIQ")	
				dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
				If dbSeek( xFilial("LIQ")+LIU->LIU_CODEMP )
					nPercent += LIQ->LIQ_PERDIS
				EndIf
				LIU->(dbSkip())
			End
		EndIf
	EndIf
	
	RestArea(aAreaLIT)
	RestArea(aArea)

Return( nPercent )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMA120ValoบAutor  ณReynaldo Miyashita  บ Data ณ  16.05.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Valor de distrato conforme a porcentagem         บฑฑ
ฑฑบ          ณ informada.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMA120Valor( cContrato ,nPercent )
Local nValor := 0
Local aArea  := GetArea()
        
// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")
                         	
	If nPercent > 0	             
		// Retorna o Saldo recebido
		nValor := M->LJD_SALDO //T_GEMSldCalc( cContrato ,3 ,.F. )[1]
		
		If nValor > 0 
			nValor := ROUND( nValor *(nPercent/100) , TamSx3("LJD_VALDIS")[2])
		EndIf
		
	EndIf
			
	RestArea(aArea)
	
Return( nValor )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMA120FornบAutor  ณReynaldo Miyashita  บ Data ณ  16.05.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o fornecedor(cliente) tem cadastro nas tabelas บฑฑ
ฑฑบ          ณ SA1 e SA2 atrav้s do CGC/CPF.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMA120Fornec( cCodFornec ,cLoja )
Local aArea   := GetArea()
Local lExiste := .F.

DEFAULT cCodFornec := ""
DEFAULT cLoja      := ""

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	cCodFornec := padr( cCodFornec ,tamSX3("A2_COD")[1] )
	cLoja      := iIf( Empty(cLoja),"" ,padr( cLoja ,tamSX3("A2_LOJA")[1]))
	
	//
	// Busca o fornecedor(cliente)
	//
	dbSelectArea("SA2")
	dbSetOrder(1) // A2_FILIAL+A2_COD+A2_LOJA
	If dbSeek( xFilial("SA2")+cCodFornec+cLoja )
		//
		// Busca o cliente
		//
		dbSelectArea("SA1")
		dbSetOrder(3) // A2_FILIAL+A2_CGC
		If dbSeek( xFilial("SA2")+SA2->A2_CGC )
			lExiste := .T.
		Else
			Help(" ",1,"GEMA120FORNEC",,STR0011,1) //"Fornecedor nใo tem o mesmo CPF/CGC do cliente."
		EndIf                         

		If !lExiste .AND. ExistBlock("GM120SA2")
			lExiste := ExecBlock("GM120SA2", .F., .F. )
		EndIf

	Else
		Help(" ",1,"GEMA120FORNEC",,STR0045,1)  //"Codigo/Loja do Fornecedor nใo existe."
	EndIf

	RestArea(aArea)
	
Return( lExiste )

/*                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa120VldForบAutor  ณReynaldo Miyashita  บ Data ณ  19.10.2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o fornecedor(cliente) tem cadastro nas tabelas บฑฑ
ฑฑบ          ณ SA1 e SA2 atrav้s do CGC/CPF.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a120VldForn( cContrato ,cCodForn ,cLjForn ,lObrig )
Local cCodCli   := ""
Local cLoja     := ""
Local lExiste   := .F.
Local lContinua := .F.
Local nIdxForn  := 0
Local cSeek     := ""
Local aArea     := GetArea()
    
DEFAULT cCodForn  := ""
DEFAULT cLjForn   := ""
DEFAULT cContrato := ""
DEFAULT lObrig    := .T.

	cCodForn := padr( cCodForn ,TamSX3("A2_COD")[1] )
	cLjForn  := padr( cLjForn  ,TamSX3("A2_LOJA")[1])
	
	If ! Empty(cContrato)
		// cabecalho do contrato 
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+cContrato)
			cCodCli := LIT->LIT_CLIENT
			cLoja   := LIT->LIT_LOJA

			If Empty(cCodForn) 
				//
				// Busca o cliente
				//
				dbSelectArea("SA1")
				dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
				If dbSeek( xFilial("SA1")+cCodCli+cLoja )
					nIdxForn  := 3
					cSeek     := SA1->A1_CGC
					lContinua := .T.
				EndIf
			Else
				nIdxForn  := 1
				cSeek     := cCodForn + cLjForn
				lContinua := .T.
			EndIf
		    
			If lContinua
		
				lExiste := .F.
		
				//
				// Busca o fornecedor( cliente)
				//
				dbSelectArea("SA2")
				dbSetOrder(nIdxForn)
				If dbSeek( xFilial("SA2")+cSeek)
					If SA1->A1_CGC == SA2->A2_CGC
						M->LJD_FORNECE := SA2->A2_COD
						M->LJD_LOJA    := SA2->A2_LOJA
						lExiste := .T.
					EndIf

					If !lExiste .AND. ExistBlock("GM120SA2")
						lExiste := ExecBlock("GM120SA2", .F., .F. )
					EndIf
		
				EndIf

				// se naum existir e for obrigatorio, inclui automaticamente.
				If (!lExiste) .and. lObrig 
					lExiste := A120AddFornec( cContrato ,cCodCli ,cLoja )	
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return( lExiste )

/*                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA120AddForบAutor  ณReynaldo Miyashita  บ Data ณ  16.05.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o fornecedor(cliente) tem cadastro nas tabelas บฑฑ
ฑฑบ          ณ SA1 e SA2 atrav้s do CGC/CPF.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A120AddFornec( cContrato ,cCodCli ,cLoja )
Local cAutoCad    := GetMV("MV_GMAUTCL") 
Local cCodFornec  := ""
Local cLjFornec   := ""
Local nX          := 0
Local lOk         := .F.
Local aCampos     := {}
Local aArea       := GetArea()

DEFAULT cContrato := ""
DEFAULT cCodCli   := ""
DEFAULT cLoja     := ""

	cCodCli := padr( cCodCli ,tamSX3("A2_COD")[1] )
	cLoja   := padr( cLoja   ,tamSX3("A2_LOJA")[1])
	
	If !Empty(cContrato)
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+cContrato)
			cCodCli := LIT->LIT_CLIENT
			cLoja   := LIT->LIT_LOJA
		EndIf
	EndIf
	
	If ! (Empty(cCodCli) .AND. Empty(cLoja)) 
		//
		// Busca o cliente
		//
		dbSelectArea("SA1")
		dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
		If dbSeek( xFilial("SA1")+cCodCli+cLoja )
			//
			// Busca o fornecedor( cliente)
			//
			dbSelectArea("SA2")
			dbSetOrder(3) // A2_FILIAL+A2_CGC
			If dbSeek( xFilial("SA2")+SA1->A1_CGC)
				M->LJD_FORNECE := SA2->A2_COD
				M->LJD_LOJA    := SA2->A2_LOJA
				lOk := .T.
			Else
				// Deve criar o automaticamente o cliente no cadastro de fornecedores
				If cAutoCad == "1"
				
					If MsgYesNo(STR0012) //"Cliente nใo tem cadastro de fornecedor para gerar tํtulos a receber. Deseja incluir?"
						cCodFornec := GetSXENum("SA2","A2_COD")
						cLjFornec  := padl( "1" ,TamSX3("A2_LOJA")[1] ,"0")
						
						aCampos := {}
						aAdd( aCampos ,{"A2_FILIAL"    ,xFilial("SA2")  ,Nil})
						aAdd( aCampos ,{"A2_COD"       ,cCodFornecec    ,Nil})	
						aAdd( aCampos ,{"A2_LOJA"      ,cLjFornec       ,Nil})
						
						If( SA1->(FieldPos("A1_ATIVIDA")) >0 .and. SA2->(FieldPos("A2_ATIVIDA")) >0 )
							aAdd( aCampos ,{"A2_ATIVIDA"   ,SA1->A1_ATIVIDA ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_NOME")) >0 .and. SA2->(FieldPos("A2_NOME")) >0 )
							aAdd( aCampos ,{"A2_NOME"      ,SA1->A1_NOME	,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_NREDUZ")) >0 .and. SA2->(FieldPos("A2_NREDUZ")) >0 )
							aAdd( aCampos ,{"A2_NREDUZ"    ,SA1->A1_NREDUZ	,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_END")) >0 .and. SA2->(FieldPos("A2_END")) >0 )
							aAdd( aCampos ,{"A2_END"       ,SA1->A1_END		,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_BAIRRO")) >0 .and. SA2->(FieldPos("A2_BAIRRO")) >0 )
							aAdd( aCampos ,{"A2_BAIRRO"    ,SA1->A1_BAIRRO	,Nil})		
						EndIf
						
						If( SA1->(FieldPos("A1_MUN")) >0 .and. SA2->(FieldPos("A2_MUN")) >0 )
							aAdd( aCampos ,{"A2_MUN"       ,SA1->A1_MUN		,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_EST")) >0 .and. SA2->(FieldPos("A2_EST")) >0 )
							aAdd( aCampos ,{"A2_EST"       ,SA1->A1_EST		,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_TIPO")) >0 .and. SA2->(FieldPos("A2_TIPO")) >0 )
							aAdd( aCampos ,{"A2_TIPO"      ,SA1->A1_TIPO	,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_CEP")) >0 .and. SA2->(FieldPos("A2_CEP")) >0 )
							aAdd( aCampos ,{"A2_CEP"       ,SA1->A1_CEP		,Nil})
						EndIf

						If( SA1->(FieldPos("A1_COD_MUN")) >0 .and. SA2->(FieldPos("A2_COD_MUN")) >0 )
							aAdd( aCampos ,{"A2_COD_MUN"   ,SA1->A1_COD_MUN ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_COND")) >0 .and. SA2->(FieldPos("A2_COND")) >0 )
							aAdd( aCampos ,{"A2_COND"      ,SA1->A1_COND    ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_CONTA")) >0 .and. SA2->(FieldPos("A2_CONTA")) >0 )
							aAdd( aCampos ,{"A2_CONTA"     ,SA1->A1_CONTA   ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_CONTAB")) >0 .and. SA2->(FieldPos("A2_CONTAB")) >0 )
							aAdd( aCampos ,{"A2_CONTAB"    ,SA1->A1_CONTAB  ,Nil}) 
						EndIf
						
						If( SA1->(FieldPos("A2_CONTATO")) >0 .and. SA2->(FieldPos("A2_CONTAT0")) >0 )
							aAdd( aCampos ,{"A2_CONTATO"   ,SA1->A1_CONTATO ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_CX_POST")) >0 .and. SA2->(FieldPos("A2_CX_POST")) >0 )
							aAdd( aCampos ,{"A2_CX_POST"   ,SA1->A1_CXPOSTA ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_DDD")) >0 .and. SA2->(FieldPos("A2_DDD")) >0 )
							aAdd( aCampos ,{"A2_DDD"       ,SA1->A1_DDD     ,Nil}) 
						EndIf
						
						If( SA1->(FieldPos("A1_DDI")) >0 .and. SA2->(FieldPos("A2_DDI")) >0 )
							aAdd( aCampos ,{"A2_DDI"       ,SA1->A1_DDI     ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_CGC")) >0 .and. SA2->(FieldPos("A2_CGC")) >0 )
							aAdd( aCampos ,{"A2_CGC"       ,SA1->A1_CGC		,Nil})
						EndIf

						If( SA1->(FieldPos("A1_PFISICA")) >0 .and. SA2->(FieldPos("A2_PFISICA")) >0 )
							aAdd( aCampos ,{"A2_PFISICA"   ,SA1->A1_PFISICA	,Nil})
						EndIf

						If( SA1->(FieldPos("A1_TEL")) >0 .and. SA2->(FieldPos("A2_TEL")) >0 )
							aAdd( aCampos ,{"A2_TEL"       ,SA1->A1_TEL		,Nil})
						EndIf

						If( SA1->(FieldPos("A1_INSCR")) >0 .and. SA2->(FieldPos("A2_INSCR")) >0 )
							aAdd( aCampos ,{"A2_INSCR"     ,SA1->A1_INSCR	,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_EMAIL")) >0 .and. SA2->(FieldPos("A2_EMAIL")) >0 )
							aAdd( aCampos ,{"A2_EMAIL"     ,SA1->A1_EMAIL   ,Nil})
						EndIf

						If( SA1->(FieldPos("A2_END")) >0 .and. SA2->(FieldPos("A2_END")) >0 )
							aAdd( aCampos ,{"A2_END"       ,SA1->A1_END     ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_EST")) >0 .and. SA2->(FieldPos("A2_EST")) >0 )
							aAdd( aCampos ,{"A2_EST"       ,SA1->A1_EST     ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_ESTADO")) >0 .and. SA2->(FieldPos("A2_ESTADO")) >0 )
							aAdd( aCampos ,{"A2_ESTADO"    ,SA1->A1_ESTADO  ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_FAX")) >0 .and. SA2->(FieldPos("A2_FAX")) >0 )
							aAdd( aCampos ,{"A2_FAX"       ,SA1->A1_FAX     ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_HPAGE")) >0 .and. SA2->(FieldPos("A2_HPAGE")) >0 )
							aAdd( aCampos ,{"A2_HPAGE"     ,SA1->A1_HPAGE   ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A2_INSCRM")) >0 .and. SA2->(FieldPos("A2_INSCRM")) >0 )
							aAdd( aCampos ,{"A2_INSCRM"    ,SA1->A1_INSCRM  ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_LC")) >0 .and. SA2->(FieldPos("A2_LC")) >0 )
							aAdd( aCampos ,{"A2_LC"        ,STR(SA1->A1_LC) ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_MATR")) >0 .and. SA2->(FieldPos("A2_MATR")) >0 )
							aAdd( aCampos ,{"A2_MATR"      ,SA1->A1_MATR    ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_MCOMPRA")) >0 .and. SA2->(FieldPos("A2_MCOMPRA")) >0 )
							aAdd( aCampos ,{"A2_MCOMPRA"   ,SA1->A1_MCOMPRA ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_METR")) >0 .and. SA2->(FieldPos("A2_METR")) >0 )
							aAdd( aCampos ,{"A2_METR"      ,SA1->A1_METR    ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_MSBLQL")) >0 .and. SA2->(FieldPos("A2_MSBLQL")) >0 )
							aAdd( aCampos ,{"A2_MSBLQL"    ,SA1->A1_MSBLQL  ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_NATUREZ")) >0 .and. SA2->(FieldPos("A2_NATUREZ")) >0 )
							aAdd( aCampos ,{"A2_NATUREZ"   ,SA1->A1_NATUREZ ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_NROCOM")) >0 .and. SA2->(FieldPos("A2_NROCOM")) >0 )
							aAdd( aCampos ,{"A2_NROCOM"    ,SA1->A1_NROCOM  ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_PAIS")) >0 .and. SA2->(FieldPos("A2_PAIS")) >0 )
							aAdd( aCampos ,{"A2_PAIS"      ,SA1->A1_PAIS    ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_PRICOM")) >0 .and. SA2->(FieldPos("A2_PRICOM")) >0 )
							aAdd( aCampos ,{"A2_PRICOM"    ,SA1->A1_PRICOM  ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_PRIOR")) >0 .and. SA2->(FieldPos("A2_PRIOR")) >0 )
							aAdd( aCampos ,{"A2_PRIOR"     ,SA1->A1_PRIOR   ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_RECISS")) >0 .and. SA2->(FieldPos("A2_RECISS")) >0 )
							aAdd( aCampos ,{"A2_RECISS"    ,If(SA1->A1_RECISS=="1","S","N")   ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_RECCOFI")) >0 .and. SA2->(FieldPos("A2_RECCOFI")) >0 )
							aAdd( aCampos ,{"A2_RECCOFI"   ,IIf( SA1->A1_RECCOFI=="N" ,"2","1") ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_RECCSLL")) >0 .and. SA2->(FieldPos("A2_RECCSLL")) >0 )
							aAdd( aCampos ,{"A2_RECCSLL"   ,IIf( SA1->A1_RECCSLL=="N" ,"2","1") ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_RECPIS")) >0 .and. SA2->(FieldPos("A2_RECPIS")) >0 )
							aAdd( aCampos ,{"A2_RECPIS"   ,IIf( SA1->A1_RECPIS=="N" ,"2","1") ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_RECINSS")) >0 .and. SA2->(FieldPos("A2_RECINSS")) >0 )
							aAdd( aCampos ,{"A2_RECINSS"   ,iIf( Empty(SA1->A1_RECINSS) ,"S" ;
							                                    ,SA1->A1_RECINSS) ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_RISCO")) >0 .and. SA2->(FieldPos("A2_RISCO")) >0 )
							aAdd( aCampos ,{"A2_RISCO"     ,SA1->A1_RISCO   ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_SATIV1")) >0 .and. SA2->(FieldPos("A2_SATIV1")) >0 )
							aAdd( aCampos ,{"A2_SATIV1"    ,SA1->A1_SATIV1  ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_TELEX")) >0 .and. SA2->(FieldPos("A2_TELEX")) >0 )
							aAdd( aCampos ,{"A2_TELEX"     ,SA1->A1_TELEX   ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_TIPO")) >0 .and. SA2->(FieldPos("A2_TIPO")) >0 )
							aAdd( aCampos ,{"A2_TIPO"      ,SA1->A1_TIPO    ,Nil})
						EndIf

						If( SA1->(FieldPos("A1_TRANSP")) >0 .and. SA2->(FieldPos("A2_TRANSP")) >0 )
							aAdd( aCampos ,{"A2_TRANSP"    ,SA1->A1_TRANSP  ,Nil})
						EndIf
						
						If( SA1->(FieldPos("A1_TRANSP")) >0 .and. SA2->(FieldPos("A2_TRANSP")) >0 )
							aAdd( aCampos ,{"A2_TRANSP"    ,SA1->A1_TRANSP  ,Nil})
						EndIf
						
						dbSelectArea("SA2")
						
						RecLock( "SA2" ,.T.)
						For nX := 1 To Len(aCampos)
							SA2->(FieldPut( FieldPos(aCampos[nX ,1]),aCampos[nX ,2] ) )
						Next nX
						MsUnlock()
						M->LJD_FORNECE := cCodFornec
						M->LJD_LOJA    := cLjFornec
						lOk := .T.
						ConfirmSx8()
/*						
						lMsErroAuto := .F.
						MsExecAuto({|x,y|MATA020(x,y)},aCampos,3)
							
						If lMsErroAuto
							Alert('Nao foi possivel Gerar automaticamente o Fornecedor.')
							MostraErro()
							cCodFornec := ""
							cLjFornec  := ""
							lOk := .F.
							RollBackSx8()
						Else
							M->LJD_FORNECE := cCodFornec
							M->LJD_LOJA    := cLjFornec
							lOk := .T.
							ConfirmSx8()
						EndIf
*/						
					EndIf
				// se o cadastro nใo for automatico, adverte q nao tem cliente cadastrado como fornecedor
				Else
					Help(" ",1,"GMA120001")
				EndIf
			EndIf
			
		EndIf
		
	EndIf
		
	RestArea(aArea)
	
Return( lOk )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA120DLGCVNบAutor  ณReynaldo Miyashita  บ Data ณ  02.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dialog para customizar a condicao de venda e simular os    บฑฑ
ฑฑบ          ณ titulos a pagar.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEMA120.PRX                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a120DLGCVN( nOpcX ,cContrato ,cRevisa ,cCondPag ,d1Venc ,nVlrTotal ,aConjLJS )

Local cCadastro   := "Condi็ใo "
Local nUsado      := 0
Local nY          := 0
Local nOpcGD      := 0
Local lContinua   := .T. 
Local aHeadTit    := { STR0016 ,STR0018 ,STR0046 ,STR0021 }
Local aObjects    := {}
Local aSize       := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aColsOri    := {}
Local aHeadLJS    := {}
Local aColsLJS    := {}
Local aArea       := GetArea()

Local oDlg
Local oPnlCab 
Local oCod 
Local oDescr
Local oValor
Local oPnlTit 
Local oArialBold 

Private aGets[0]
Private aTela[0][0]
Private oGetCVnd
Private oBrwTit 
Private nSaldoDup := nVlrTotal

	//
	If nVlrTotal > 0 
		
		// carrega o aheader e acols do browse dos itens de pagamento da tabela LJS
		A120LJSLoad( nOpcX==2 ,cContrato ,cRevisa ,cCondPag ,d1Venc ,nVlrTotal ,@aConjLJS )
	    
		aHeadLJS := aConjLJS[2]
		aColsLJS := aConjLJS[3]
		
		If lContinua
		    // Os registros com valor original
			aColsOri := aClone(aColsLJS)
	
			dbSelectArea("LJS")
			RegToMemory( "LJS" ,(nOpcX==3) )
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Faz o calculo automatico de dimensoes de objetos     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM 09,00 TO 40,90 of oMainWnd 
			DEFINE FONT oArialBold NAME "Arial" SIZE 0, -16 BOLD
			
			If nOpcX == 3 .Or. nOpcX == 4
				nOpcGD := GD_UPDATE+GD_INSERT+GD_DELETE
			Else
				nOpcGD := 0
			EndIf
		
		    // Valor total do distrato
			@ 5 ,240 SAY OemToAnsi(STR0047)+Transform(nVlrTotal ,x3Picture("LJD_VALDIS") ) FONT oArialBold SIZE 200,16 PIXEL OF oDlg
	
			// visualiza a condicao de venda
			// item, parcelas, valor, porcentagem , tipo parcela, descricao tipo parcela, tipo sistema , taxa anual, coeficiente, indice, tipo price, residuo, parcela residuo
			oGetCVnd := MsNewGetDados():New( 20,10,100,350 ,nOpcGD ,"AllwaysTrue","AllwaysTrue","+LJS_ITEM",,,9999,,,,oDlg,aHeadLJS,aColsLJS)
			
			// visualiza as parcelas conforme a condicao de venda informado
			oPnlTit := TPanel():New(110,10,'',oDlg, ,.T.,.T.,, ,340,100,.T.,.T. )
			
			oBrwTit := TWBrowse():New( 5,10,100,340,,aHeadTit ,/*tamanho*/ ,oPnlTit,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 
			oBrwTit:Align := CONTROL_ALIGN_ALLCLIENT
			a120BrwRefresh( oGetCVnd:aHeader ,aColsLJS ,@oBrwTit )
		
			@ 220,170 BUTTON OemToAnsi(STR0048)/*Recalculo*/	SIZE 040,11 ACTION a120BrwRefresh( oGetCVnd:aHeader ,oGetCVnd:aCols ,@oBrwTit ) OF oDlg WHEN nOpcGD <> 0 PIXEL
			@ 220,220 BUTTON OemToAnsi(STR0049)/*Confirma*/		SIZE 040,11 ACTION (Iif( a120Conf( @oDlg ,aConjLJS[1] ,aColsOri ,@aConjLJS, aHeadLJS),oDlg:End(),.F.)) OF oDlg WHEN nOpcGD <> 0 PIXEL
			@ 220,270 BUTTON OemToAnsi(STR0050)/*Sair*/			SIZE 040,11 ACTION oDlg:End() OF oDlg PIXEL
			
			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf
	Else
		MsgAlert(STR0051)  //"Nใo existe valor de distrato para negociar."
	EndIf
	RestArea(aArea)
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMA120LJSบAutor  ณReynalo Miyashita   บ Data ณ  02.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega os dados da condicao de venda conforme a condicao  บฑฑ
ฑฑบ          ณ de pagamento informado no Contrato.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A120LJSLoad( lVisual ,cContrato ,cRevisa ,cCondPag ,d1Venc ,nVlrTotal ,aConjLJS )
Local nPos_1VENC  := 0
Local nPos_FIXVNC := 0
Local nPos_VALOR  := 0
Local nPos_PERCLT := 0
Local nY          := 0
Local aHeadLJS    := {}
Local aColsLJS    := {}
Local aArea       := GetArea()

DEFAULT cCondPag  := ""
DEFAULT d1Venc    := stod("")
DEFAULT nVlrTotal := 0
	
	If !Empty(aConjLJS)
		If cCondPag == aConjLJS[1]
			aHeadLJS := aConjLJS[2]
			aColsLJS := aConjLJS[3]
		EndIf
	EndIf
	
	If len(aHeadLJS)==0
		// monta o aHeadLJS
		aHeadLJS := aClone(TableHeader("LJS"))
		aEval( aHeadLJS ,{|aCampo|aCampo[2] := Alltrim(Upper(aCampo[2]))})
		nY := aScan( aHeadLJS ,{|aCampo| alltrim(aCampo[2])=="LJS_PERCLT"})
		If nY > 0
			If Empty(aHeadLJS[nY][6])
				aHeadLJS[nY][6] := "t_GMa120Perc()"
			Else
				aHeadLJS[nY][6] := aHeadLJS[nY][6] + " .AND. t_GMa120Perc()"
			EndIf
		EndIf
		
		nY := aScan( aHeadLJS ,{|aCampo| alltrim(aCampo[2])=="LJS_VALOR"})
		If nY > 0
			If Empty(aHeadLJS[nY][6])
				aHeadLJS[nY][6] := "t_GMa120Perc()"
			Else
				aHeadLJS[nY][6] := aHeadLJS[nY][6] + " .AND. t_GMa120Perc()"
			EndIf
		EndIf
	EndIf
	                   
	nUsado := Len(aHeadLJS)
	
	If Len(aColsLJS) == 0
		//
		// se for consulta da condicao de venda do distrato do contrato
		//
		If lVisual
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Faz a montagem do aColsLJS                                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("LJS")
			dbSetOrder(1) // LJS_FILIAL+LJS_NCONTR+LJS_REVISA+LJS_ITEM
			dbSeek(xFilial("LJS")+cContrato+cRevisa)
			While !Eof() .And. LJS->LJS_FILIAL+LJS->LJS_NCONTR+LJS->LJS_REVISA==xFilial("LJS")+cContrato+cRevisa
				aAdd(aColsLJS,Array(Len(aHeadLJS)+1))
				For nY := 1 to Len(aHeadLJS)
					If ( aHeadLJS[ny][10] != "V")
						aColsLJS[Len(aColsLJS)][nY] := FieldGet(FieldPos(aHeadLJS[nY][2]))
					Else
						aColsLJS[Len(aColsLJS)][nY] := CriaVar(aHeadLJS[nY][2])
					EndIf
				Next nY  
				If (nPos_PERCLT := aScan( aHeadLJS ,{|aCol| aCol[2] == "LJS_PERCLT" }) ) >0
					If (nPos_VALOR := aScan( aHeadLJS ,{|aCol| aCol[2] == "LJS_VALOR" }) ) >0
						aColsLJS[Len(aColsLJS)][nPos_PERCLT] := round((aColsLJS[Len(aColsLJS)][nPos_VALOR]/nVlrTotal)*100 ,aHeadLJS[nPos_PERCLT][5])
					Endif
				EndIf
				aColsLJS[Len(aColsLJS)][Len(aHeadLJS)+1] := .F.
				
				dbSelectArea("LJS")
				dbSkip()
			EndDo
		//
		// se for consulta da condicao de venda do distrato do contrato
		//
		Else
			// condicao de pagamento
			dbSelectArea("SE4")
			dbSetOrder(1) // E4_FILIAL+E4_CODIGO
			If dbSeek(xFilial("SE4")+cCondPag)
				// condicao de venda - cabecalho
				dbSelectArea("LIR")
				dbSetOrder(1) // LIR_FILIAL+LIR_CODCND
				If dbSeek(xFilial("LIR")+SE4->E4_CODCND)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Faz a montagem do aColsLJS                                   ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					dbSelectArea("LIS")
					dbSetOrder(1) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
					If dbSeek(xFilial("LIS")+LIR->LIR_CODCND)
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Faz a montagem do aColsLJS                                   ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						While !Eof() .And. LIS->LIS_FILIAL+LIS->LIS_CODCND==xFilial("LIR")+LIR->LIR_CODCND
							aAdd(aColsLJS,Array(Len(aHeadLJS)+1))
							For nY := 1 to Len(aHeadLJS)
								If FieldPos("LIS"+substr(aHeadLJS[ny][2],4)) >0 
									If ( aHeadLJS[ny][10] != "V")
										aColsLJS[Len(aColsLJS)][nY] := FieldGet(FieldPos("LIS"+substr(aHeadLJS[nY][2],4)))
									Else   
										aColsLJS[Len(aColsLJS)][nY] := CriaVar(aHeadLJS[ny][2])
									EndIf
								Else
									aColsLJS[Len(aColsLJS)][nY] := CriaVar(aHeadLJS[ny][2])
								EndIf
							Next nY
							
							If (nPos_1VENC := aScan( aHeadLJS ,{|x|x[2]=="LJS_1VENC" })) >0
								nPos_FIXVNC := aScan( aHeadLJS ,{|x|x[2]=="LJS_FIXVNC" })
								If nPos_FIXVNC > 0 .and. aHeadLJS[nPos_FIXVNC][2] == "2"
									aColsLJS[Len(aColsLJS)][nY] := d1Venc
								Endif
							EndIf

							If (nPos_PERCLT := aScan( aHeadLJS ,{|aCol| aCol[2] == "LJS_PERCLT" }) ) >0
								If (nPos_VALOR := aScan( aHeadLJS ,{|aCol| aCol[2] == "LJS_VALOR" }) ) > 0
									aColsLJS[Len(aColsLJS)][nPos_PERCLT] := round((aColsLJS[Len(aColsLJS)][nPos_VALOR]/nVlrTotal)*100 ,aHeadLJS[nPos_PERCLT][5])
								Endif
							EndIf
							aColsLJS[Len(aColsLJS)][Len(aHeadLJS)+1] := .F.
							
							dbSelectArea("LIS")
							dbSkip()
						EndDo
					EndIf
				EndIf
			EndIf
		EndIf		
	//
	// atualiza os valores a serem financiados 
	//
	Else        
		nPos_VALOR := aScan( aHeadLJS ,{|aCol| aCol[2] == "LJS_VALOR" } ) 
		nPos_PERCLT := aScan( aHeadLJS ,{|aCol| aCol[2] == "LJS_PERCLT" } ) 
		If nPos_Valor > 0 .AND. nPos_PERCLT > 0
			For nY := 1 to Len(aColsLJS)
				// se o item nao foi deletado 
				If !aColsLJS[nY][Len(aHeadLJS)+1]
					// se o item nao foi deletado 
					aColsLJS[nY][nPos_PERCLT] := round((aColsLJS[nY][nPos_VALOR]/nVlrTotal)*100,aHeadLJS[nPos_PERCLT][5])
				Endif
			Next nY
        EndIf
    EndIf
    
	// Se naum tiver nenhum item
	If Empty(aColsLJS)
		aadd(aColsLJS,Array(Len(aHeadLJS)+1))
		For nY := 1 to Len(aHeadLJS)
			If Trim(aHeadLJS[nY][2]) == "LJS_ITEM"
				aColsLJS[1][nY] := StrZero(1, TamSX3("LJS_ITEM")[1])
			Else
				aColsLJS[1][nY] := CriaVar(aHeadLJS[nY][2])
			EndIf
		Next nY
		aColsLJS[1][Len(aHeadLJS)+1] := .F.
		
	Endif
	
	RestArea(aArea)
	
	aConjLJS := aClone({cCondPag ,aHeadLJS ,aColsLJS})
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGMa120PercบAutor  ณReynaldo Miyashita  บ Data ณ  07/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a coluna de porcentagem do browse de condicao de    บฑฑ
ฑฑบ          ณ venda.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEMa120.PRW                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function GMA120Perc()
Local lOk       := .T.
Local nPosPerc  := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJS_PERCLT"})
Local nPosValor := aScan(oGetCVnd:aHeader ,{|e|Trim(e[2])=="LJS_VALOR"})
Local nPorc     := 0
Local nMaxPorc  := 0
Local nVlrParc  := 0
Local nMaxTotal := 0
Local cVar      := ReadVar()

// Valida se tem licen็as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

nMaxTotal := nSaldoDup - nVlrParc
Do Case
	// Valor 
	Case cVar == "M->LJS_VALOR"
		If M->LJS_VALOR <= nMaxTotal
			If nPosPerc > 0
				aEval( oGetCVnd:aCols ,{|aColuna,nIndex| iIf( !aColuna[Len(aColuna)] .AND. n <> nIndex ;
				                                    ,nVlrParc += aColuna[nPosValor] ;
				                                    ,.F.)})
			
				M->LJS_PERCLT := Round(((100 * M->LJS_VALOR) / nSaldoDup ),oGetCVnd:aHeader[nPosPerc,5])
				oGetCVnd:aCols[n][nPosPerc] := M->LJS_PERCLT
			EndIf
		Else
			Alert(STR0052 + transform( nMaxTotal ,x3Picture("LJS_VALOR")) )   //"Valor nใo pode ser superior a"
			lOk := .F.
		EndIf
		
	// Porcentagem
	Case cVar == "M->LJS_PERCLT"
		aEval( oGetCVnd:aCols ,{|aColuna,nIndex| iIf( !aColuna[Len(aColuna)] .AND. n <> nIndex ;
		                                             ,nPorc += aColuna[nPosPerc] ;
				                                     ,.F.)})
		nMaxTotal := 100 - nPorc 
		If M->LJS_PERCLT <= nMaxTotal
			M->LJS_VALOR := Round(( nSaldoDup * M->LJS_PERCLT / 100),oGetCVnd:aHeader[nPosValor,5])
			oGetCVnd:aCols[n][nPosValor] := M->LJS_VALOR
		EndIf
EndCase

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa120BrwRefบAutor  ณReynaldo Miyashita  บ Data ณ  02.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o browse com os valores dos titulos conforme       บฑฑ
ฑฑบ          ณ condicao de venda montado                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a120BrwRefresh( aHeader ,aCols ,oBrw )
Local aTitulos := {}
Local aTits    := {}
                  
	aTitulos := {{}}
	aEval(aHeader ,{|aIt|aAdd(aTitulos[1],CriaVar(aIt[2])) })
   	oBrw:SetArray(aTitulos)
	oBrw:bLine := {|| aTitulos[oBrw:nAT] }
	oBrw:refresh()
	
	// gera os titulos a pagar para visualizar conforme a customizacao da condicao de venda
	aTitulos := a120GeraDupl( aHeader ,aCols )
	If Empty(aTitulos)
		aTitulos := {{"" ,stod(""),"",0}}
	EndIf
	aEval(aTitulos ,{|aTitulo| aAdd(aTits ,{ aTitulo[1] ,transform(aTitulo[2],x3Picture("E1_VENCTO")) ,aTitulo[3] ,transform(aTitulo[4],x3Picture("E1_VALOR")) } ) })
   	oBrw:SetArray(aTits)
	oBrw:bLine := {|| aTits[oBrw:nAT] }
	
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa120GeraDuบAutor  ณReynaldo Miyashita  บ Data ณ  02.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera as duplicadas conforme a condicao de venda customizadoบฑฑ
ฑฑบ          ณ no browse.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a120GeraDupl( aHeader ,aCols ,nTipo )
Local cParcela     := ""
Local nCount       := 0
Local nPos_ITEM    := 0
Local nPos_TIPPAR  := 0
Local nPos_TPDESC  := 0
Local nPos_DT1VCTO := 0
Local nPos_VALOR   := 0
Local nPos_TPSIST  := 0
Local nPos_TAXANO  := 0
Local nPos_INTERV  := 0
Local nPos_NUMPARC := 0
Local nPos_TPPRIC  := 0
Local aTitTmp      := {}
Local aTitulos     := {}
Local aArea        := GetArea()
Local aConjunto    := {}
Local nCnt2        := 0

DEFAULT nTipo := 2

	nPos_ITEM    := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJS_ITEM" } )
	nPos_TIPPAR  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJS_TIPPAR" } )
	nPos_TPDESC  := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJS_TPDESC" } )
	nPos_DT1VCTO := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJS_1VENC" } )
	nPos_VALOR   := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJS_VALOR" } )
	
	nPos_NUMPARC := aScan( aHeader ,{|aCol| alltrim(aCol[2]) == "LJS_NUMPAR" } )

	For nCount := 1 to Len(aCols)
		// se o item nao foi deletado 
		If !aCols[nCount][Len(aHeader)+1] ;
		   .and. !Empty(aCols[nCount][nPos_DT1VCTO]) ;
		   .and. (aCols[nCount][nPos_NUMPAR]>0) .and. (aCols[nCount][nPos_VALOR] >0 )

			// existencia do tipo de titulo para obtencao do intervalo entre titulos.
			dbSelectArea("LFD")
			dbSetOrder(1) // LFD_FILIAL+LFD_COD
			If MsSeek( xFilial("LFD")+aCols[nCount][nPos_TIPPAR] )
				// calcula o valor a ser financiado neste item de condicao de venda
				nPerCorr := 0
				
				// gera os titulos a pagar calculando como tipo de sistema "4- nenhum"
				aTitTmp := T_GMGeraTit( "4" ,aCols[nCount][nPos_DT1VCTO] ,0 ,LFD->LFD_INTERV ;
				                       ,aCols[nCount][nPos_NUMPAR] ,aCols[nCount][nPos_VALOR] ,/*% do indice de correcao*/ ,nPerCorr ,/* Tipo de Price */ )
				//
				aAdd( aConjunto ,{ aCols[nCount][nPos_ITEM] ;
				                  ,aCols[nCount][nPos_TIPPAR] ;
				                  ,aCols[nCount][nPos_TPDESC] ;
				                  ,iIf(LFD->(FieldPos("LFD_EXCLUS"))>0,iIf(Empty(LFD->LFD_EXCLUS),"2",LFD->LFD_EXCLUS),"2") ;
				                  ,LFD->LFD_INTERV ;
				                  ,aTitTmp } )

			EndIf
		EndIf
	Next nCount       
	
	// reordena as datas das parcelas
	GMPRCPARC( @aConjunto ) 
	
	//
	// aTitulos[1] Item da condicao de venda
	// aTitulos[2] Numero da Parcela do Titulo
	// aTitulos[3] Data de Vencimento
	// aTitulos[4] Descricao do Tipo de parcela
	// aTitulos[5] Valor da Parcela
	// aTitulos[6] Valor Juros Financiado
	// aTitulos[7] Saldo Devedor
	//
	aTitulos := {}
	For nCount := 1 To Len( aConjunto )
		For nCnt2 := 1 To Len( aConjunto[nCount][6] )
			aAdd( aTitulos ,{ aConjunto[nCount][1]           ;  // [1] Item da condicao de venda
			                 ,aConjunto[nCount][6][nCnt2][1] ;  // [2] Numero da Parcela do Titulo
			                 ,aConjunto[nCount][6][nCnt2][2] ;  // [3] Data de Vencimento
			                 ,aConjunto[nCount][3]           ;  // [4] Descricao do Tipo de parcela
			                 ,aConjunto[nCount][6][nCnt2][3] ;  // [5] Valor da Parcela
			                 ,aConjunto[nCount][6][nCnt2][4] ;  // [6] Valor Juros Financiado
			                 ,aConjunto[nCount][6][nCnt2][5] }) // [7] Saldo Devedor
		Next nCnt2
	Next nCount

	// ordena pela data de vencimento e item da condicao de venda
	aSort( aTitulos ,,,{|x,y|dtos(x[3])+x[1] < dtos(y[3])+y[1]})
	
	// se aTitulos nao for vazio
	If ! Empty(aTitulos) 
		aTitTmp := aClone(aTitulos)
		aTitulos := {}
		Do Case
			// Padrao Siga (data vencto,valor)
			Case nTipo == 1
				For nCount := 1 To len(aTitTmp)
					aAdd(aTitulos ,{ aTitTmp[nCount][3] ,aTitTmp[nCount][5] } )
				Next nCount
			// GEM Detalhe 1 ( Numero parcela , data vencto ,Tipo de Parcela ,valor )
			Case nTipo == 2
				cParcela := SuperGetMv("MV_1DUP")
				// re-ordena os numeros da parcela
				For nCount := 1 To len(aTitTmp) 
					aAdd(aTitulos ,{ cParcela ,aTitTmp[nCount][3],aTitTmp[nCount][4] ,aTitTmp[nCount][5] } )
					cParcela := MaParcela(cParcela)
				Next nCount 
			// GEM - Detalhe do valor da parcela
			//  { data de vencimento, valor do titulo, Item da condicao venda, parcela , juros, saldo devedor}
			OtherWise
				For nCount := 1 To len(aTitTmp) 
					aAdd(aTitulos ,{ aTitTmp[nCount][3] ,aTitTmp[nCount][5] ,aTitTmp[nCount][1] ,aTitTmp[nCount][2] ,aTitTmp[nCount][6] ,aTitTmp[nCount][7] } )
					cParcela := MaParcela(cParcela)
				Next nCount 
		EndCase
	EndIf
    
	restArea(aArea)
	
Return( aTitulos )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa120Conf  บAutor  ณReynaldo Miyashita  บ Data ณ  02.08.2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Confirmacao da customizacao da condicao de venda.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a120Conf( oDlg ,cCondPag ,aColsOri ,aConjLJS,aHeadLJS ) 
Local nPos        := 0
Local nTotal      := 0
Local nCount      := 0
Local nPosValor   := aScan(oGetCVnd:aHeader ,{|e|alltrim(e[2])=="LJS_VALOR"})
Local lModificado := .F.
Local lContinua   := .T.
Local aColsLJS    := {}
Local nQtdCnd	  := 0
Local nx		  := 0
Local nVenc		  := 0	
	aEval( oGetCVnd:aCols ,{|aColuna| iIf( !aColuna[Len(aColuna)]  ;
	                                ,(nTotal += aColuna[nPosValor] ) ;
	                                ,.F.)})
    nVenc := aScan(oGetCVnd:aHeader,{|x| alltrim(x[2])==alltrim("LJS_1VENC")})
	If nVenc > 0
   	   For nx:=1 To Len(oGetCVnd:aCols)
          If oGetCVnd:aCols[nx][nVenc] < dDatabase
	         MsgAlert(STR0065) //"Erro: Data de vencimento menor que a data base do sistema."
		     lContinua = .F.
		     Exit
	      Endif
       Next nx
    Endif
	If nTotal <> M->LJD_VALDIS
		MsgAlert(STR0053)  //"Diferen็a entre o valor do Distrato e a soma dos valores a serem pagos."
		lContinua := .F.
	EndIf

	nQtdCnd := aScan(aHeadLJS,{|x| alltrim(x[2])==alltrim("LJS_NUMPAR")})			         

	If lContinua
		If cCondPag <> GetMV("MV_GMCPAG")
	    	//
	    	// avalia O oGetCVnd:aCols com o aColsOri para verificar se houve alteracao nos itens da condicao de venda, Dia da correcao monetaria,tipo de price
	    	//
			For nCount := 1 to Len(aColsOri)
		    	// numero de parcelas, valor , tipo de parcela, Fixa data de vencimento, Data de vencimento, Tipo de Sistema, TAXA anual , indice
		    	// for diferente do original
		    	nPos := aScan( oGetCVnd:aCols ,{|aColuna| !aColuna[len(oGetCVnd:aHeader)+1] .AND. ;
		    	                                          aColuna[02] == aColsOri[nCount][02] .AND. aColuna[03] == aColsOri[nCount][03] .AND. ;
		    	                                          aColuna[04] == aColsOri[nCount][04] .AND. aColuna[07] == aColsOri[nCount][07] .AND. ;
		     	                                          aColuna[08] == aColsOri[nCount][08] .AND. aColuna[09] == aColsOri[nCount][09] ;
		     	                                           })
		    	If nPos == 0
		    		lModificado := .T.
					Exit
				EndIf
					
			Next nCount

		EndIf
		    
   		If lModificado
			M->LJD_COND := GetMV("MV_GMCPAG")
		EndIf
		aColsLJS := {}
		aEval(oGetCVnd:aCols ,{|aColuna| iIf( !aColuna[len(oGetCVnd:aHeader)+1] ,aAdd( aColsLJS ,aColuna ) ,.F.)}) 
		
		aConjLJS := aClone({M->LJD_COND ,oGetCVnd:aHeader ,aColsLJS })
		
	EndIf
	
Return( lContinua )

//
// Carrega os titulos a receber pagos referentes ao contrato
//
Static Function A120LoadTitulo( cContrato ,cRevisa ,lVisual )
Local nX            := 0
Local nVlrParcela   := 0
Local nVlrCMAmort   := 0
Local nVlrCMJur     := 0
Local nVlrJurosMora := 0
Local aTitulos      := {}
Local lTitReneg     := .F.
Local aArea         := GetArea()
Local aAreaLIT      := LIT->(GetArea())
Local nValorPgo	  := 0
Local nRecno		  := 0
//
// se visual, ้ visualizacao dos titulos a pagar negociados no distrato
// 
If lVisual
	// parcelas selecionadas
	dbSelectArea("LJE")
	dbSetOrder(1) // LJE_FILIAL+LJE_NCONTR+LJE_REVISA
	dbSeek(xFilial("LJE")+cContrato+cRevisa)
	While LJE->(!eof()) .AND. LJE->LJE_FILIAL+LJE->LJE_NCONTR+LJE->LJE_REVISA== xFilial("LJA")+cContrato+cRevisa
		MsProcTxt('Lendo Titulo '+LJE->(LJE_PREFIX +"/"+LJE_NUM+"/"+ LJE_PARCEL))	
		//  "Parcela"    ,"Tipo"         ,"Vencto"     ,"Baixa"      ;
		// ,"Valor Pago" ,"Valor Titulo" ,"Amortizado" ,"CM Amort."  ;
		// ,"Juros"      ,"CM Juros"     ,"Cm Atraso"  ,"Juros Mora" ;
		// ,"Multa" ;
		aAdd( aTitulos ,{ .T. ;
		                 ,LJE->LJE_PARCEL ,LJE->LJE_TIPO  ,LJE->LJE_VENCTO ,LJE->LJE_BAIXA  ;
		                 ,LJE->LJE_VALLIQ ,LJE->LJE_VALOR ,LJE->LJE_AMORT  ,LJE->LJE_CMAMOR ; 
		                 ,LJE->LJE_PVLJUR ,LJE->LJE_CMJUR ,LJE->LJE_PRORAT ,LJE->LJE_VALJUR ; 
		                 ,LJE->LJE_MULTA  } )
		LJE->(dbSkip())
	EndDo
//
// se naum ้ uma inclusao de DISTRATO, deve mostrar os titulos a receber pagos
//	
Else

	// cadastro de contratos
	dbSelectArea("LIT")
	dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
	If dbSeek(xFilial("LIT")+cContrato)
		
		dbSelectArea("LIX")
		dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
		dbSeek(xFilial("LIX")+cContrato)
		While LIX->(!Eof()) .AND. (LIX->LIX_NCONTR == cContrato)
						
			// titulos a receber
			dbSelectArea("SE1")
			dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If dbSeek(xFilial("SE1")+LIX->LIX_PREFIX+LIX->LIX_NUM+LIX->LIX_PARCEL)
	//While SE1->(!Eof()) .AND. SE1->E1_PREFIXO==LIT->LIT_PREFIX .AND. SE1->E1_NUM==LIT->LIT_DUPL
				lTitReneg := .F.
				cParcela := SE1->E1_PARCELA
				MsProcTxt('Lendo Titulo '+SE1->(E1_PREFIXO +"/"+E1_NUM+"/"+ E1_PARCELA))	
				If SE1->E1_SALDO # SE1->E1_VALOR 
					//
					// Busca no SE5, as baixas do titulo a receber tanto baixa com/sem mov. bancario
					//
 					nValorPgo := 0
				   dbSelectArea("SE5")
				   dbSetOrder(7)
				   IF dbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
				    	While SE5->(!Eof()) .AND. SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
				    	// ษ um titulo renegociado
					
						
							If SE5->E5_TIPODOC == "BA" .AND. SE5->E5_MOTBX == "LIQ" .and. !Empty(SE5->E5_DOCUMEN)
								lTitReneg := .T.
							EndIF
		
							If !lTitReneg .and. (SE5->E5_TIPODOC $ "VL/JR/ES/DC") .and. !Empty(SE5->E5_BANCO)
															
								If (SE5->E5_SITUACA <> "C") .AND. (SE5->E5_RECPAG == "R") .AND. (SE5->E5_TIPODOC $ "VL/JR") //SE5->E5_TIPODOC $ "VL/JR" .AND. E5_RECPAG != "P" .AND. E5_SITUACA <> "C"
									nValorPgo += SE5->E5_VALOR
								ElseIf (SE5->E5_SITUACA =="C") .OR. (SE5->E5_RECPAG == "P") .OR. (SE5->E5_TIPODOC $ "ES/DC/BA") 
									nValorPgo -= SE5->E5_VALOR
								EndIF    
							EndIF
							
		               SE5->( dbSkip() )
						EndDo
			
					EndIf	

					nRecno := LIX->(Recno())
					If ! lTitReneg
						// titulos a receber detalhado
						dbSelectArea("LIX")
						dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
						If dbSeek(xFilial("LIX")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
							nVlrParcela := LIX->LIX_ORIAMO + LIX->LIX_ORIJUR
							nVlrCMAmort := SE1->E1_CM1*(LIX->LIX_ORIAMO/nVlrParcela)
							nVlrCMJur   := SE1->E1_CM1*(LIX->LIX_ORIJUR/nVlrParcela)
							
						    nVlrJurosMora := SE1->E1_JUROS -(SE1->E1_CM1+SE1->E1_PRORATA)
						
							//  "Parcela"    ,"Tipo"         ,"Vencto"     ,"Baixa"      ;
							// ,"Valor Pago" ,"Valor Titulo" ,"Amortizado" ,"CM Amort."  ;
							// ,"Juros"      ,"CM Juros"     ,"Cm Atraso"  ,"Juros Mora" ;
							// ,"Multa" ;
							aAdd( aTitulos ,{ .F. ;
							                 ,SE1->E1_PARCELA ,SE1->E1_TIPO  ,SE1->E1_VENCREA ,SE1->E1_BAIXA ;
							                 ,nValorPgo  ,SE1->E1_VALOR ,LIX->LIX_ORIAMO ,nVlrCMAmort   ;
							                 ,LIX->LIX_VALJUR ,nVlrCMJur     ,SE1->E1_PRORATA ,nVlrJurosMora ;
							                 ,SE1->E1_MULTA   } )
		     			EndIf 
		     			
		     			dbSelectArea("LIX")
						dbSetOrder(3)
		     			LIX->(dbGoTo(nRecno))
		     		EndIf
				EndIf
			EndIf
			LIX->(dbSkip())
		EndDo
	EndIf
	
EndIf

If len(aTitulos) == 0
	aAdd( aTitulos ,array(13))
	aTitulos[1][1] := .F.
	aTitulos[1][2] := ""
	aTitulos[1][3] := ""
	aTitulos[1][4] := ""
	For nX := 5 to 13
		aTitulos[1][nX] := 0 
	Next nX
EndIf

RestArea(aAreaLIT)
restArea(aArea)
		
Return( aTitulos )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMMOT    บAutor  ณReynaldo Miyashita  บ Data ณ  24.02.2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclui na Tabela de Motivos da baixa a baixa por Distrato  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GEMMOT()
Local nHandle := 0
Local nTamArq := 0
Local nBytes  := 0
Local nTamLin := 19
Local xBuffer := ""
Local lExiste := .F.

	If (nHandle := fOpen( "SigaAdv.MOT" ,2+32 ) ) == -1
		HELP(" ",1,"MOT_ERROR")
		Final("Erro F_"+str(fError(),2)+" em SIGAADV.MOT")
	EndIf

	nTamArq := fSeek(nHandle,0,2)	// Verifica tamanho do arquivo
	fSeek( nHandle,0,0)	     	// Volta para inicio do arquivo
	
	While nBytes<nTamArq
		
		xBuffer := Space(nTamLin)
		fRead(nHandle,@xBuffer,nTamLin)
		If ! Empty(xBuffer)
			If "DIS" == left(xBuffer,3)
				lExiste := .T.
			EndIf
		EndIf
		
		nBytes+=nTamLin
	End

	If !lExiste	
//		fSeek( nHandle ,0 ,2)
		fWrite(nHandle,"DISDISTRATO  ANNN"+chr(13)+chr(10))
	EndIf	

	fClose(nHandle)

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldTitRec บAutor  ณBruno Sobieski      บ Data ณ  05.06.2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se existe titulos a receber baixados com data       บฑฑ
ฑฑบ          ณ posterior a database.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldTitRec()
Local lRet	   := .T.
Local aArea	   := GetArea()
Local aAreaLIT := LIT->(GetArea())
Local aAreaSE1 := SE1->(GetArea())

// cadastro de contratos
dbSelectArea("LIT")
dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
If dbSeek(xFilial("LIT")+M->LJD_NCONTR)
	// titulos a receber
	dbSelectArea("SE1")
	dbSeek(xFilial("SE1")+LIT->LIT_PREFIX+LIT->LIT_DUPL)
	While lRet .And. SE1->(!Eof()) .AND. SE1->E1_PREFIXO==LIT->LIT_PREFIX .AND. SE1->E1_NUM==LIT->LIT_DUPL
	
		MsProcTxt(STR0054+LJE->(LJE_PREFIX +"/"+LJE_NUM+"/"+ LJE_PARCEL)) //'Lendo Titulo '		
	
		//
		// Nao pode existir parcelas emitidas posterior a database
		//
		If lRet .AND. SE1->E1_SALDO >0 .AND. dDatabase < SE1->E1_EMISSAO
		// ### "A parcela "  +++ ## foi gerada em data posterior เ data base    ++ ## O distrato nao poderแ ser confirmado.
			MsgAlert(STR0055 + SE1->E1_PARCELA + STR0056 + DTOC(SE1->E1_EMISSAO) + ")." + CRLF + STR0057)
			lRet	:=	.F.
		EndIf
		  
		//
		// Nao pode existir parcelas baixadas ap๓s a database
		//
		If lRet .and. SE1->E1_SALDO # SE1->E1_VALOR .And. Empty(SE1->E1_TIPOLIQ) .AND. SE1->E1_BAIXA > dDataBase
		// ### "A parcela "  +++ ## foi baixada em data posterior เ data base    ++ ## O distrato nao poderแ ser confirmado.
			MsgAlert(STR0055 + SE1->E1_PARCELA + STR0058 + DTOC(SE1->E1_BAIXA) + ")." + CRLF+ STR0057)
			lRet	:=	.F.
		EndIf
		
		//
		// Verificar se a parcela estแ em aberto e em bordero.
		//
		If lRet .AND. SE1->E1_SALDO >0 .AND. !Empty( SE1->E1_NUMBOR )
			// ### "A parcela "  +++ ## estแ em aberto no bordero    ++ ## O distrato nao poderแ ser confirmado.
			MsgAlert(STR0055 + SE1->E1_PARCELA + STR0059 + SE1->E1_NUMBOR + "." + CRLF + STR0057)
			lRet	:=	.F.
		EndIf
		
		dbSelectArea("SE1")
		dbSkip()
	EndDo
EndIf

RestArea(aAreaSE1)
RestArea(aAreaLIT)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewBorderบAutor  ณReynaldo Miyashita  บ Data ณ  29.01.2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza e permite selecionar os titulos a receber que    บฑฑ
ฑฑบ          ณ estao em bordero para serem tirados do mesmo.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewBordero()
Local aArea	   := GetArea()
Local aAreaLIT := LIT->(GetArea())
Local aAreaSE1 := SE1->(GetArea())

Local cCadastro := OemToAnsi(STR0060)   //"Tํtulos a receber em aberto no Bordero"

Local nCount := 0

Local lOk    := .F.

Local aObjects   := {}
Local aSize      := {}
Local aInfo      := {}
Local aPosObj    := {}
Local aTitulos   := {}
Local aCampos    := {}
Local aHeader    := {}
Local aDefHeader := {}
Local aParcelas  := {}
Local aButtons   := {}

Local oDlg
Local oLstBox


//
// [1] Nome do campo
// [2] .T. = Visualiza na coluna, .F. = NยO Visualiza
//
aCampos := { {"E1_NUMBOR"  ,.T.} ;
            ,{"E1_DATABOR" ,.T.} ;
            ,{"E1_ITPARC"  ,.T.} ;
            ,{"E1_EMISSAO" ,.T.} ;
            ,{"E1_VENCTO"  ,.T.} ;
            ,{"E1_VALOR"   ,.T.} ;
            ,{"E1_PARCELA" ,.F.} ;
            ,{"E1_TIPO"    ,.F.} }

// define a coluna de sele็ใo
aDefHeader  := { { "" ,"__SEL" ,"" ,"" ,"" ,.T. } }

// busca os definicoes na tabela SX3 conforme nome do campo
dbSelectArea("SX3")
dbSetOrder(2) // X3_FILIAL+X3_CAMPO
aEval(aCampos ,{|x| iIf( SX3->(dbSeek(x[1])) ;
                        ,aAdd( aDefHeader ,{ SX3->X3_ARQUIVO ,SX3->X3_CAMPO ,X3Titulo() ,SX3->X3_TIPO ,SX3->X3_PICTURE ,x[2] }) ;
                        ,.F. ;
		               ) } )

aEval(aDefHeader ,{|x| iIf( x[6] ,aAdd(aHeader ,x[3]) ,.F.) })
		
// cadastro de contratos
dbSelectArea("LIT")
dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
If dbSeek(xFilial("LIT")+M->LJD_NCONTR)
	// titulos a receber
	dbSelectArea("SE1")
	dbSeek(xFilial("SE1")+LIT->LIT_PREFIX+LIT->LIT_DUPL)
	While SE1->(!Eof()) .AND. SE1->E1_PREFIXO==LIT->LIT_PREFIX .AND. SE1->E1_NUM==LIT->LIT_DUPL
		//
		// Verificar se a parcela estแ em aberto e em bordero.
		//
		If SE1->E1_SALDO >0 .AND. !Empty( SE1->E1_NUMBOR )
			aAdd( aParcelas ,{} )
			aEval(aDefHeader ,{|x| iIf( !Empty(x[1]) ;
			                            ,aAdd( aParcelas[len(aParcelas)] ,&(x[1]+"->"+x[2])) ;
			                            ,aAdd( aParcelas[len(aParcelas)] ,ProcCol(x)) ;
			                          ) })
		EndIf
		
		dbSelectArea("SE1")
		dbSkip()
	EndDo
	
	If !Empty( aParcelas )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Faz o calculo automatico de dimensoes de  objetos    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAdd( aObjects, {  100 ,075 ,.T. ,.F. } )
		aAdd( aObjects, {  200 ,100 ,.T. ,.F. } )
		aAdd( aObjects, {  300 ,100 ,.T. ,.F. ,.T. } )
		aSize   := MsAdvSize()
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
		aPosObj := MsObjSize( aInfo ,aObjects ,.T. )
	
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

		oLstBox := TWBrowse():New( 005, 005, 140, 370,/*aFields*/,aHeader,/*aColSizes*/,oDlg,/*cField*/,/*uValue1*/,/*uValue2*/,/*bChange*/ ;
		                           ,/*bDblClick*/,/*bRightClick*/,/*oFont*/,/*oCursor*/,/*nClrFore*/,/*nClrBack*/,/*cMsg*/,/*lUpdate*/,/*cAlias*/,/*lPixel*/,/*uWhen*/,/*ldesign*/,/*bValid*/,/*bLeftClick*/,/*bAction*/)
		
		oLstBox:SetArray( aParcelas )
		oLstBox:Align := CONTROL_ALIGN_ALLCLIENT
		oLstBox:bLine := {|| Line( aDefHeader ,aParcelas[oLstBox:nAt]) }
		oLstBox:bLDblClick := {|| DblClick( aDefHeader ,aParcelas[oLstBox:nAt] )}

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{||lOk := .T.,oDlg:End()} ;
		                                                ,{||lOk := .F.,oDlg:End()}  ;
		                                                ,,aButtons )
		If lOk
			a120BorGrv( LIT->LIT_PREFIX ,LIT->LIT_DUPL ,aParcelas )
		EndIf
		
	Else
		// #Tํtulos em Bordero# Nใo existe tํtulos a receber em aberto no Bordero. # OK # 
		Aviso(STR0061, STR0062 ,{STR0063} )
    EndIf

EndIf

RestArea(aAreaSE1)
RestArea(aAreaLIT)
RestArea(aArea)

Return( .T. )

Static Function ProcCol( aDefField )
Local uValor

	If aDefField[02] == "__SEL"
		uValor := .F.
	EndIf

Return( uValor )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLine      บAutor  ณReynaldo Miyashita  บ Data ณ  29.01.2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a linha do browse de titulos em bordero           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Line( aDefHeader ,aTitulo )
Local aNewTitulo := {}
Local nCount     := 0
Local oBmpOk := LoadBitmap( GetResources(), "LBOK" )
Local oBmpNo := LoadBitmap( GetResources(), "LBNO" )

	For nCount := 1 To Len(aTitulo)
		If !Empty(aDefHeader[nCount][01])
			aAdd( aNewTitulo ,Transform( aTitulo[nCount] ,aDefHeader[nCount][5] ))
		Else
			If aDefHeader[nCount][02] == "__SEL"
				aAdd( aNewTitulo ,iIf(aTitulo[nCount] ,oBmpOk ,oBmpNo) )
			EndIf
		EndIf
	 			                
	Next nCount
		                        
Return( aNewTitulo )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDblClick  บAutor  ณReynaldo Miyashita  บ Data ณ  29.01.2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca/desmarca os titulos em aberto no bordero             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DblClick( aDefHeader ,aTitulo )
Local nCount := 0

	For nCount := 1 To Len(aTitulo)
		If aDefHeader[nCount][02] == "__SEL"
			aTitulo[nCount] := !aTitulo[nCount]
		EndIf
	Next nCount

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa120BorGrvบAutor  ณReynaldo Miyashita  บ Data ณ  29.01.2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza as tabelas SEA e SE1 retirando assim os titulos   บฑฑ
ฑฑบ          ณ selecionados do bordero.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGEM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a120BorGrv( cPrefixo ,cNumero ,aParcelas )
Local nCount   := 0
Local cParcela := ""
Local cTipo    := ""

	//
	// retira dos bordero os titulos a receber selecionados
	//
	For nCount := 1 to len(aParcelas)
	
		If aParcelas[nCount][01]
		
			cParcela := aParcelas[nCount][08]
			cTipo    := aParcelas[nCount][09]
			
			// titulos a receber
			dbSelectArea("SE1")
			dbSetOrder(1) //SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
			MsSeek(xFilial("SE1") + cPrefixo + cNumero + cParcela + cTipo)
			If SE1->E1_SALDO > 0
				RecLock( "SE1" )
				Replace SE1->E1_NUMBOR With CriaVar("E1_NUMBOR")
		    	Replace SE1->E1_DATABOR With stod("") 
			    If Alltrim(Upper(FunName())) <> "FINA089"
					Replace SE1->E1_PORTADO With ""
					Replace SE1->E1_AGEDEP  With ""
					Replace SE1->E1_CONTA   With ""
					Replace SE1->E1_SITUACA With "0"
					Replace SE1->E1_NUMBCO  With "" 					
				EndIf
				MsUnlock()
				
				// titulos enviados ao banco
				dbSelectArea("SEA")
				dbSetOrder(1) //SEA->EA_NUMBOR+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+SEA->EA_LOJA
				MsSeek(xFilial("SEA") + aParcelas[nCount][02] + cPrefixo + cNumero + cParcela + cTipo)
				RecLock("SEA",.F.,.T.)
				dbDelete()
				MsUnlock()
			Endif  
		EndIf
		
    Next nCount
		
Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva    ณ Data ณ05/12/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := {{ OemToAnsi(STR0001) ,"AxPesqui"    ,0,1},; //"Pesquisar"
                    { OemToAnsi(STR0002) ,"T_GMA120Dlg" ,0,2},; //"Visualizar"
                    { OemToAnsi(STR0003) ,"T_GMA120Dlg" ,0,3} } //"Incluir"
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEMA120   บAutor  ณClovis Magenta      บ Data ณ  17/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que valida o campo LJD_NCONTR quando cliente tiver  บฑฑ
ฑฑบ          ณ p.e. GM120APROV para aceitar contratos quitados		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEMA120           	                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

TEMPLATE FUNCTION GMDistrAprov(cContrato)
Local lRetorno := .F.
DEFAULT cContrato := ""
        
If ExistBlock("GM120APROV")
	lRetorno := ExecBlock("GM120APROV", .F.,.F.,{cContrato})
EndIf       

Return lRetorno
