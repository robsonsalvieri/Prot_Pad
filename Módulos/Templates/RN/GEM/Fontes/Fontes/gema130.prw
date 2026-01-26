#INCLUDE "GEMA130.ch"
#INCLUDE "PROTHEUS.CH" 

/////////////////////////////
// Sequencia para o Cabecalho
#define  _SeqCabec_  StrZero(0,TamSX3("LK2_SEQUEN")[1])
#define  _TamCodEm_  TamSX3("LIQ_COD")[1]

////////
// Cores
#define CLR_FUNDO		RGB(240,240,240)
#define CLR_FONTB		RGB(000,000,255)
#define CLR_FONTT		RGB(000,000,000)

////////////////
// .: Indices :.
// LK2	1	LK2_FILIAL+LK2_CODIGO+LK2_SEQUEN
// LK2	2	LK2_FILIAL+LK2_DESCRI
// LK2	3	LK2_FILIAL+LK2_CODIGO+LK2_DESCRI
// LK2	4	LK2_FILIAL+LK2_SEQUEN

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GEMA130  ³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro da mascara para codigo de empreendimento em niveis³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template  GEM                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
   */
TEMPLATE Function GEMA130()
Local cFiltro := "LK2_SEQUEN == '"+_SeqCabec_+"'"

Private aCpsObg := { "LK2_SEQUEN", "LK2_QUANT", "LK2_DESCIT"  } // Campos Obrigatorios para MsGetDados
Private aRotina := MenuDef()

// Define o cabecalho da tela de atualizacoes
Private cCadastro := OemToAnsi(STR0006) //"Mascaras para Empreendimentos"

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

DbSelectArea("LK2")
DbSetOrder(4) // LK2_FILIAL+LK2_SEQUEN
dbClearFilter()

If !Empty(cFiltro)
	dbSetFilter({||&cFiltro},cFiltro)
EndIf

mBrowse(6,1,22,75,"LK2",,,,,,,,,,,,,)

LK2->(dbClearFilter())

Return( .T. )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GEMA130Frm³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gerencia a Inclusao, Alteracao, Visualizacao e Exclusao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMA130Frm( cAlias, nReg, nOpc )

Local lOk 			:= .F.
Local cTitCod		:= RetTitle("LK2_CODIGO")
Local cTitDesc		:= RetTitle("LK2_DESCRI")
Local oSize
Local a1stRow 		:=  {}

Private oDlg		:= Nil
Private oGet_1		:= Nil
Private oGet_2		:= Nil
Private oFont		:= Nil
Private oTxtMas		:= Nil
Private cTxtMas 	:= Space(_TamCodEm_)
Private oFontE 		:= Nil
Private aHeader		:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= Nil

INCLUI := nOpc == 3

RegToMemory("LK2", INCLUI )

///////////////////////////////////////
// Monta aHeader: utilizado na getdados
G130Ahead("LK2") 
DbSelectArea("LK2")
DbSetOrder(4) // LK2_FILIAL+LK2_SEQUEN

nUsado := Len(aHeader)     

					
//Defino o tamanho dos componentes através do método FwDefSize(), amarrando ao objeto oDlg
oSize := FwDefSize():New(.T.)

oSize:lLateral := .F.
oSize:lProp := .T.

oSize:AddObject("MASTER",100,100,.T.,.T.)

oSize:Process()

a1stRow := {oSize:GetDimension("MASTER","LININI"),;
			oSize:GetDimension("MASTER","COLINI"),;
			oSize:GetDimension("MASTER","LINEND"),;
			oSize:GetDimension("MASTER","COLEND")}


DEFINE MSDIALOG	oDlg TITLE OemToAnsi(STR0007); //"Mascara do Empreendimento"
		FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4]  OF oMainWnd PIXEL	
	
			

	@ a1stRow[1] + 003,a1stRow[2] + 003 SAY cTitCod 	SIZE 56,07 OF oDlg PIXEL
	@ a1stRow[1] + 003,a1stRow[2] + 040 MSGET oGet_1	VAR M->LK2_CODIGO ;
									PICTURE PesqPict("LK2","LK2_CODIGO") ;
									Valid T_GEM130Masc() ;
									WHEN INCLUI ;
									SIZE 35,10 ;
									OF oDlg PIXEL
	
	
	@  a1stRow[1] + 003,a1stRow[2] + 110 SAY cTitDesc	SIZE 56,07 OF oDlg PIXEL
	@  a1stRow[1] + 003,a1stRow[2] + 138 MSGET oGet_2	VAR M->LK2_DESCRI ;
									PICTURE PesqPict("LK2","LK2_DESCRI") ;      
	                        WHEN INCLUI ;
	                        SIZE 130,10 ;
	                        OF oDlg PIXEL
	
	                        
	////////////////////////////////////////////
	// Caixa de texto para a mascara configurada
	DEFINE FONT oFontT NAME "Arial" SIZE 5,15
	@ a1stRow[1] + 13 , a1stRow[2] + 2 TO  66,  270   LABEL STR0008 OF oDlg PIXEL COLOR CLR_FONTT //" Mascara "
		
	//////////////////////
	// Texto com a Mascara
	DEFINE FONT oFont NAME "Arial" SIZE 7,20 BOLD	
	@  a1stRow[1] + 20,a1stRow[2] + 10 SAY oTxtMas PROMPT cTxtMas FONT oFont COLOR CLR_FONTB,CLR_FUNDO OF oDlg PIXEL
	
	/////////////////////////////////////
	// Monta aCols: utilizado na getdados
	G130Acols(nOpc)
	If !INCLUI
		T_RetMascEmp( _TamCodEm_ )
	Endif

      ////////////////////////////
      // Visualiza          Exclui
If     ( nOpc == 2 ) .or. ( nOpc == 5 ) 

	oGet := MSGetDados():New(a1stRow[1] + 35 ,a1stRow[2] + 2  ,a1stRow[3] ,a1stRow[4]  , nOpc,"AllwaysTrue","AllwaysTrue","+LK2_SEQUEN",.T.)   
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(nOpc==2,Nil,G130Dele()),oDlg:End()},{||oDlg:End()} ) CENTER
	

      ////////////////////////////
      // Inclui             Altera	
ElseIf ( nOpc == 3 ) .or. ( nOpc == 4 ) 

	oGet := MSGetDados():New(a1stRow[1] + 35 ,a1stRow[2] + 2  ,a1stRow[3] ,a1stRow[4]   , nOpc,"T_GE130LinOk" ,"T_GE130TudOk("+STR(nOpc)+")","+LK2_SEQUEN",.T.,,1,,9999)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := oGet:TudoOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()} ) CENTER
	
EndIf

If lOk
	T_GEM130Grav(nOpc)
Endif

DbSelectArea("LK2")
DbSetOrder(4) // LK2_FILIAL+LK2_SEQUEN

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ G130Acols³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G130Acols( nOpc )

Local nCnt, n, nI, nPos

////////////////////
// Montagem do aCols
If nOpc == 3 // Inclusao

	aCols := Array(1,nUsado+1)

	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := dDataBase
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

	nPos := aScan(aHeader,{ |x| AllTrim(x[2])== "LK2_SEQUEN" })
	aCols[1,nPos] := StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.

Else
	              
	DbSelectArea( "LK2" )
	DbSetOrder( 1 )
	DbSeek( xFilial("LK2") + M->LK2_CODIGO + StrZero(1,TamSX3("LK2_SEQUEN")[1]) )

		Do While LK2->(!Eof()) .and. xFilial("LK2") == LK2->LK2_FILIAL .and.;
		   LK2->LK2_CODIGO == M->LK2_CODIGO
			 	
			aAdd(aCols,Array(nUsado+1))
		
			For nI := 1 to nUsado
	   	
				If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Else														// Campo Virtual
					cCpo := AllTrim(Upper(aHeader[nI,2]))
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Endif

			Next nI
	  			
			aCols[Len(aCols),nUsado+1] := .F.
			DbSkip()
		Enddo
Endif

DbSelectArea("LK2")
DbSetOrder(4) // LK2_FILIAL+LK2_SEQUEN

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ G130Ahead³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G130Ahead(cAlias)

aHeader := {}
nUsado  := 0

DbSelectArea("SX3")
DbSetOrder(1) // X3_FILIAL+X3_ALIAS
DbSeek(cAlias)

Do While !Eof() .and. (X3_ARQUIVO == cAlias)

	///////////////////////////////////////////////////
	// Ignora campos que nao devem aparecer na getdados
    If  Upper( AllTrim(X3_CAMPO) ) == "LK2_CODIGO" .Or. ;
        Upper( AllTrim(X3_CAMPO) ) == "LK2_DESCRI"
				
		DbSkip()
		Loop
	Endif
	// Ignora campos que nao devem aparecer na getdados
	///////////////////////////////////////////////////

	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
		nUsado++
 		aAdd(aHeader,{ Trim(X3Titulo()), X3_CAMPO  , X3_PICTURE	,;
						X3_TAMANHO     , X3_DECIMAL, X3_VALID   		,;
						X3_USADO       , X3_TIPO   , X3_ARQUIVO 		,; 
						X3_CONTEXT                               		;
					 }                                           	;
			)
	Endif

	DbSkip()
Enddo 

Return


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ G130Dele ³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para exclusao das Mascaras				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G130Dele()

Local aArea 		:= GetArea()
Local aAreaLK3 	:= LK3->(GetArea())
Local aAreaLK2 	:= LK2->(GetArea())
Local lContinua	:= .T.

DbSelectArea("LK3")
LK3->(dbGoTop())
While LK3->( !Eof() )
	
	If Alltrim(LK3->LK3_MASCAR) == Alltrim(M->LK2_CODIGO) .and. (LK3->LK3_FILIAL == M->LK2_FILIAL)
		lContinua := .F.
		Exit
	Else
		LK3->( dbSkip() )
	EndIf
		 
EndDo
	
If lContinua
	
	DbSelectArea("LK2")
	DbSetOrder(1) // LK2_FILIAL+LK2_CODIGO+LK2_SEQUEN
	DbSeek( xFilial("LK2") + M->LK2_CODIGO )
	
	If MsgYesNo( OemToAnsi( STR0009 ) ) //"Confirma a exclusao desta mascara?"
	
		Begin Transaction
			Do While LK2->(!Eof())  .And. xFilial("LK2") == LK2->LK2_FILIAL ;
			   .And. LK2->LK2_CODIGO == M->LK2_CODIGO
					 
				RecLock("LK2",.F.)
					LK2->( DbDelete() )
				MsUnLock()
					
				LK2->( DbSkip() )
					
			Enddo
		End Transaction
	
	EndIf
	
	DbSelectArea("LK2")
	DbSetOrder(4) // LK2_FILIAL+LK2_SEQUEN
                  
Else
	// #  "Essa máscara esta em uso por algum Empreendimento e não poderá ser deletada!" #
	Alert(STR0015)
EndIf                                                                          
   
RestArea(aArea)
RestArea(aAreaLK3)
RestArea(aAreaLK2)

Return


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GEM130Grav³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao - Incl./Alter				      		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEM130Grav( nOpc )

Local nIt		:= 0
Local cSeq		:= _SeqCabec_
Local nPosDel	:= Len(aHeader) + 1
Local nPosSeq	:= aScan(aHeader,{ |x| AllTrim(x[2])== "LK2_SEQUEN" })
Local nPosQtd	:= aScan(aHeader,{ |x| AllTrim(x[2])== "LK2_QUANT"  })
Local nPosDes	:= aScan(aHeader,{ |x| AllTrim(x[2])== "LK2_DESCIT" })
Local nPosSep	:= aScan(aHeader,{ |x| AllTrim(x[2])== "LK2_SEPARA" })
Local lGraOk	:= .T.

DbSelectArea("LK2")
DbSetOrder(1) // LK2_FILIAL + LK2_CODIGO + LK2_SEQUEN
	
Begin Transaction

	///////////////////////////
	// Grava dados do Cabecalho
	If INCLUI 
		RecLock("LK2",.T.)
			LK2->LK2_FILIAL	:= xFilial("LK2")
			LK2->LK2_CODIGO	:= M->LK2_CODIGO
			LK2->LK2_DESCRI	:= M->LK2_DESCRI
			LK2->LK2_SEQUEN	:= _SeqCabec_
			LK2->LK2_QUANT	:= 0
			LK2->LK2_DESCIT	:= ""
			LK2->LK2_SEPARA	:= ""
		MsUnLock()
	Endif

	For nIt := 1 To Len(aCols)
		
		If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado
			
			cSeq := Soma1(cSeq)
	
			/////////////////////////////////////////////
			// Caso ja exista registro com a chave abaixo
			// 		trava registro
			// Caso contrario cria registro novo travado
			If ALTERA
				If DbSeek( xFilial("LK2")+ M->LK2_CODIGO + aCols[nIt,nPosSeq] )
					RecLock("LK2",.F.)
				Else
					RecLock("LK2",.T.)
				Endif
			Else
				RecLock("LK2",.T.)
			Endif
				
			////////////////////////////	
			// Grava dados da MsGetDados
			LK2->LK2_FILIAL	:= xFilial("LK2")
			LK2->LK2_CODIGO	:= M->LK2_CODIGO
			LK2->LK2_DESCRI	:= M->LK2_DESCRI
			LK2->LK2_SEQUEN	:= cSeq
			LK2->LK2_QUANT		:= aCols[nIt,nPosQtd]
			LK2->LK2_DESCIT	:= aCols[nIt,nPosDes]
			LK2->LK2_SEPARA	:= aCols[nIt,nPosSep]
			MsUnLock()

		Else
			If DbSeek( xFilial("LK2")+ M->LK2_CODIGO + aCols[nIt, nPosSeq] )
				RecLock("LK2",.F.)
					LK2->(DbDelete())
				MsUnLock()
			Endif
		Endif
		
	Next nIt
End Transaction

DbSelectArea("LK2")
DbSetOrder(4) // LK2_FILIAL + LK2_SEQUEN
LK2->( dbGoTop() )

Return( lGraOk )


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GE130LinOk ³ Autor ³ Cristiano Denardi    ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GE130LinOk( )

Local nQtdeCps 	:= Len( aCpsObg )
Local nPosDel  	:= Len( aHeader ) + 1
Local nPosCpo  	:= 0 // Posicao do campo obrigatorio
Local nIt	   	:= 0
Local lRetorno 	:= .T.      

///////////////////////////////////////////
// Campos Obrigatorios:
// verifica campo a campo se foi preenchido
For nIt := 1 to nQtdeCps

	nPosCpo  := aScan( aHeader, {|x| AllTrim(x[2]) == aCpsObg[nIt]} )
	
	If Empty ( aCols[n,nPosCpo] ) .and. ( !aCols[n, nPosDel] )
		MsgAlert( STR0010+Upper(Alltrim(aHeader[nPosCpo,1]))+" !", STR0011 )		 //"Favor preencher o campo "###"Campo obrigatorio!"
		lRetorno := .F.
		exit
	EndIf   

Next nIt

If lRetorno
	T_RetMascEmp( _TamCodEm_ ) // Atualiza Mascara abaixo para vizualizacao
Endif
Return( lRetorno )


/*                                                                           
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GE130TudOk ³ Autor ³ Cristiano Denardi    ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GE130TudOk(nOpc)

Local nQtdeCps	:= Len( aCpsObg )
Local nPosCpo	:= 0 // Posicao do campo obrigatorio
Local cTitle 	:= OemToAnsi( STR0012 ) //"Atencao!"
Local cMsg		:= OemToAnsi( STR0013 )  //"Campos obrigatorios nao preenchidos."
Local lRetorno	:= .T.
Local nIt 		:= 0
Local nPosDel  := Len(aHeader) + 1

Local aArea 		:= GetArea()
Local aAreaLK3 	:= LK3->(GetArea())
Local aAreaLK2 	:= LK2->(GetArea())
Local lContinua	:= .T.


IF ( nOpc == 4 )
	DbSelectArea("LK3")
	LK3->(dbGoTop())
	While LK3->( !Eof() )

		If Alltrim(LK3->LK3_MASCAR) == Alltrim(M->LK2_CODIGO)  .and. (LK3->LK3_FILIAL == M->LK2_FILIAL)
			lContinua := .F.
			lRetorno := .F.
			Exit
		Else
			LK3->( dbSkip() )
		EndIf
			 
	EndDo
EndIf
		
If lContinua

	///////////////////////////////
	// Verifica campos obrigatorios
	// do cabecalho
	If Empty(M->LK2_CODIGO) .Or. Empty(M->LK2_DESCRI)
		lRetorno := .F.             
		MsgAlert( cMsg, cTitle )
	EndIf
	
	
	///////////////////////////////////////////
	// Campos Obrigatorios: MsGetDados
	// verifica campo a campo se foi preenchido
	For nIt := 1 to nQtdeCps
	
		nPosCpo  := aScan( aHeader, {|x| AllTrim(x[2]) == aCpsObg[nIt]} )
		
		If Empty ( aCols[n,nPosCpo] ) .and. ( !aCols[n, nPosDel] )
			lRetorno := .F.                                        
			MsgAlert( cMsg, cTitle)
			exit
		EndIf   
	
	Next nIt
	
	If lRetorno
		T_RetMascEmp( _TamCodEm_ ) // Atualiza Mascara abaixo para vizualizacao
	Endif

Else
	// ## "Essa máscara esta em uso por algum Empreendimento e não poderá ser alterada!" ##
	Alert(STR0016)
EndIf                                                                          
   
RestArea(aArea)
RestArea(aAreaLK3)
RestArea(aAreaLK2)

Return( lRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GEM130Masc³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se ja nao existe codigo da mascara cadastrado.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA130Inc()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEM130Masc( )

Local aArea		:= GetArea()
Local cMsg		:= ""
Local cTitle	:= ""
Local lRetorno	:= .T.
Local cCod		:= M->LK2_CODIGO

dbSelectArea( "LK2" )
dbSetOrder( 1 )

/////////////////////////////////
// verifica existencia de mascara
If dbSeek( xFilial("LK2") + cCod + _SeqCabec_ )

	lRetorno := .F.
	
	///////////
	// Mensagem
	cTitle 	:= OemToAnsi( STR0012 ) //"Atencao!"
	cMsg		:= OemToAnsi( STR0014 )  //"Ja existe uma Mascara com esse codigo, localize-a para edita-la ou escolha outro codigo."
	MsgAlert( cMsg, cTitle )

Endif

dbSelectArea( "LK2" )
dbSetOrder( 4 )

RestArea( aArea )
Return( lRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetMascEmp³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna mascara conforme valores configurados no aCols.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function RetMascEmp( nTamVar, lValid )

Local xRet		:= Nil
Local xVar		:= Nil
Local cMasc 	:= ""
Local cCarMas	:= "x"
Local nL		:= 0
Local nTam		:= Len(aCols)
Local nPosDel	:= Len(aHeader) + 1
Local nPosQtd	:= aScan(aHeader,{ |x| AllTrim(x[2])== "LK2_QUANT"  })
Local nPosSep	:= aScan(aHeader,{ |x| AllTrim(x[2])== "LK2_SEPARA" })

Default nTamVar := _TamCodEm_
Default lValid  := .F.

If nTam > 0
	For nL := 1 To nTam
		If !aCols[nL, nPosDel]
			cMasc += Replicate( cCarMas, aCols[nL][nPosQtd] )
			If len(AllTrim(aCols[nL][nPosSep])) > 0 
				cMasc += aCols[nL][nPosSep]
			EndIf
		Endif
	Next
Else
	cMasc := Space( nTamVar )
Endif

/////////////////////////////////
// necessario para valid dos cpos
If lValid
	cMasc := Alltrim( cMasc )
	xVar  := &(ReadVar())
	If ValType( xVar ) == "N"
		cMasc += Replicate( cCarMas, xVar )
	ElseIf ValType( xVar ) == "C"
		If Right( cMasc, 1 ) == cCarMas
			cMasc += xVar
		Else
			cMasc := SubStr( cMasc, 1, Len(cMasc)-1 )
			cMasc += xVar
		Endif
	Endif
Endif

oTxtMas:cCaption := cMasc
oTxtMas:Show()
oTxtMas:Refresh()

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ChvCabec  ³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra registros para exibicao da mBrowse.	  				  ³±±
±±³          ³ (Exibe somente cabecalhos, LK2_SEQUEN = '00')				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function ChvCabec()
Return( xFilial("LK2") + _SeqCabec_ )

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
Local aRotina := {	{OemToAnsi(STR0001), "AxPesqui"     , 0, 1,,.F.},;  //'Pesquisar'
					{OemToAnsi(STR0002), "T_GEMA130Frm" , 0, 2},; //"Visualiza"
					{OemToAnsi(STR0003), "T_GEMA130Frm" , 0, 3},; //"Inclui"
					{OemToAnsi(STR0004), "T_GEMA130Frm" , 0, 4},; //"Altera"
					{OemToAnsi(STR0005), "T_GEMA130Frm" , 0, 5}}  //"Exclui"
Return(aRotina)
