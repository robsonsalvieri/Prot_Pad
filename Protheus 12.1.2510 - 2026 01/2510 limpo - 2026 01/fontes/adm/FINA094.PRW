#INCLUDE "FINA094.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINA094    ³ Autor ³ Carlos Eduardo Chigres      ³ Data ³ 15/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa do Cadastro de Entidades Bancarias         	              ³±±
±±³          ³                                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA094                       						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³          Manutencoes efetuadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FINA094()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCores := { {'FJO_BLOCK == "2" .OR. EMPTY(FJO_BLOCK)' , 'ENABLE' },;  //"Conta Corrente liberada para movimentações"
				  {'FJO_BLOCK == "1"' , 'DISABLE' } }	                     //"Conta Corrente bloqueada para movimentações"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi( STR0001 )  // "Atualizaçäo de Entidades Bancarias"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "FJO" )
//--- Filial + Banco 
dbSetOrder( 1 )


mBrowse( 6, 1, 22, 75, "FJO",,,,,,aCores )
	
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A094Manut  ³ Autor ³ Carlos Eduardo Chigres      ³ Data ³ 26/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao do Cadastro de Entidades Bancarias         	          ³±±
±±³          ³                                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA094                       						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³          Manutencoes efetuadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A094Manut( cAlias, nReg, nOpcx )

//--- Genericas
Local nX    := 0
Local nOpc  := 0
Local lWhen := ( nOpcx == 3 .Or. nOpcx == 4 )

//--- Tratamento de Exclusao
Local lApaga := .F.
Local aApaga := {}

//--- Dimensionamento de Objetos
Local aSize    := {}
Local aInfo    := {}
Local aObjects := {}
Local aPosObj  := {}

//--- Dialog
Local oDlg

//---EnchoiceBar
Local aButtons := {}

Private oEnc   
Private oGet
Private aTela[0][0], aGets[0] 
Private aHeader := {}, aCols := {}

//--- Array auxiliar para tratamento na gravacao das informacoes da GetDados()
Private aColsReg := {}

//--- Array auxiliar para tratamento da gravacao do Log de Manutencoes
Private aColsAnt := {}	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificacao de Permissao para Exclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 5
	
   Aadd( aApaga, { "SEL" , "EL_BCOCHQ" } )
   Aadd( aApaga, { "SE5" , "E5_BCOCHQ" } )

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica possiveis Vinculos Ativos com as Tabelas SEL e SE5, antes da confirmacao de Delecao ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

   //--- Funcao que avalia vinculo
   lApaga := AXDelete( aApaga, FJO->FJO_COD )   
   //--- Sintaxe: ACSDelete("<Tabela onde sera procurado o campo>",<campo a ser procurado>)         
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso existir vinculo com outra tabela nao permite exclusao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !lApaga

       Aviso( OemToAnsi(STR0010), OemToAnsi(STR0011), {"Ok"} )  //Aviso("Atenção", "Essa Entidade Bancaria não pode ser excluida, pois se encontra em uso no Sistema."

       Return Nil

    EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa variaveis de memoria referentes a Enchoice() ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( "FJO", nOpcx == 3 ) 
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a montagem do aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsReg := A094Fill( nOpcx, "FJN", 1, xFilial("FJN") + M->FJO_COD, {|| FJN->FJN_FILIAL + FJN->FJN_COD },, )

aColsAnt := aClone(aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controla coordenadas das janelas referentes a Enchoice() e GetDados() ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aObjects, {100,100,.T.,.T.,.F.} ) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)
Aadd( aObjects, {100,400,.T.,.T.,.F.} ) // Indica dimensoes x e y e indica que redimensiona x e y

aSize   := MsAdvSize()
aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
aPosObj := MsObjSize(aInfo,aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

     oEnc := MsMGet():New( cAlias, nReg, nOpcx,,,,, aPosObj[1],,3,,,,,,.T. )

     oGet := MSNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],Iif(Altera .Or. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0), "A094LinOk" ,"Allwaystrue()" , , , , 999, "A094ChgP" ,  , "A094DelK" , oDlg, aHeader, aCols )

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(aGets, aTela) .And. oGet:TudoOk(),(nOpc := 1, oDlg:End()), nOpc := 0)},{||nOpc := 0, oDlg:End()},.F.,aButtons ) CENTERED

If ( nOpc == 1 ) .And. ( nOpcx <> 2 )

	Begin Transaction

		If nOpcx == 5 
		 
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Exclusao dos dados referentes a GetDados(FJN) ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   dbSelectArea("FJN")
		   dbSeek( xFilial("FJN")+M->FJO_COD )
		   dbEval( {|| RecLock("FJN", .F., .T.), dbDelete(), MsUnlock()}, , {|| FJN->FJN_FILIAL+FJN->FJN_COD == xFilial("FJN")+M->FJO_COD } )

		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Exclusao dos dados referentes a Enchoice(FJO) ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   dbSelectArea("FJO")
		   RecLock( "FJO" , .F. , .T. )
		   dbDelete()
		   MsUnlock()

		Else
		
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Grava header do contrato ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           Mem2Reg( "FJO", nOpcx==3 )

	       If __lSX8
	          ConfirmSX8()
           EndIf

		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Grava itens do contrato ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   GCol( oGet:aCols, oGet:aHeader, aColsReg, "FJN", {|| FJN->FJN_COD := M->FJO_COD}, "")

		EndIf

	End Transaction
  
Else

   If __lSX8 
      RollBackSX8()
   EndIf

EndIf

dbSelectArea("FJO")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A094LinOk ³ Autor ³ Andre Schwartz        ³ Data ³ 22/11/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a linha digitada esta OK                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ A094Manut, FINA094                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A094LinOk()

Local lRet     := .T.
Local cAlias   := Alias()
Local nCnt     := 0
Local cAgencia := " "
Local nPAgenci := GDFieldPos( "FJN_AGENCI", oGet:aHeader )

Local nP := n

Local bGrupo := {|| ( oGet:aCols[nCnt][nPAgenci] == cAgencia ) }       

cAgencia := GDFieldGet( "FJN_AGENCI" , nP, , oGet:aHeader, oGet:aCols )

Begin Sequence


//--- Ignore linhas deletadas
If !GDDeleted( nP, oGet:aHeader, oGet:aCols ) 

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se nao existem AGENCIAS duplicadas ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //
   For nCnt := 1 TO Len( oGet:aCols )
      
      //--- Ignore a linha corrente e demais deletadas
      If ( nCnt <> nP ) .And. !GDDeleted( nCnt, oGet:aHeader, oGet:aCols ) 

         //--- Verifica Agencia repetida
         If Eval( bGrupo )
            lRet := .F.
            Exit
         EndIf
            
      EndIf
         
   Next nCnt

   If !lRet

      //--- Aviso de Chave Duplicada em FJN
      Aviso( OemToAnsi(STR0021), OemToAnsi(STR0022), { STR0027 } )  
      //--- "Inconsistencia" #### "A informação de Agencia não pode ser duplicada."  #### Fechar
      Break

   EndIf

EndIf

End Sequence

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ A094Legend ³ Autor ³ Carlos E. Chigres    ³ Data ³ 13/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Apresenta a Legenda do Browse                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA094                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A094Legend()

Local aLegenda := {	{ "ENABLE"	,  STR0008},;	// "Entidade Liberada para uso"
				   	{ "DISABLE"	,  STR0009} }	// "Entidade Bloqueada para uso"

BrwLegenda( cCadastro, STR0007, aLegenda ) 	//"Legenda"

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Nereu Humberto Junior ³ Data ³12/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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


PRIVATE aRotina := { { STR0002, "AxPesqui"  , 0, 1,,.F. },;  // "Pesquisar"
					 { STR0003, "A094Manut" , 0, 2 },;       // "Visualizar"
					 { STR0004, "A094Manut" , 0, 3 },;       // "Incluir"
					 { STR0005, "A094Manut" , 0, 4 },;       // "Alterar"
					 { STR0006, "A094Manut" , 0, 5 },;       // "Excluir"					 
					 { STR0007, "A094Legend", 0, 6,,.F. } }  //"Legenda"
					 
If cPaisLoc == "ARG"
	aAdd( aRotina, { STR0015, "A094Imp"   , 0, 3 } )       // "Importacao"
EndIf

Return( aRotina )  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AXDelete  ³ Autor ³ Fabio Jadao Caires    ³ Data ³ 14/07/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica vinculos em outras tabelas antes da exclusao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AXDelete( ExpC1 , ExpC2 )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Array com matriz: coluna 1=Alias, coluna 2=Campo     ³±±
±±³          ³ ExpC2 = O que procurar se ha vinculo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO     	   								            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AXDelete( aTables, cChave1 )   

Local lRet 		:= .F.
Local cQuery	:= ""
Local x			:= 0
Local cAlias	:= alias()
Local cTopArea  := " "

For x := 1 To Len( aTables )

    cTopArea := GetNextAlias()

     If Select( cTopArea ) > 0
       (cTopArea)->( dbCloseArea() )
     Endif

	cQuery := "SELECT * "
	cQuery += "FROM  " + RetSQLName( aTables[x][1] ) + " " + aTables[x][1] + " "
	cQuery += "WHERE " + aTables[x][1] + "." + aTables[x][2] + " = '" + cChave1 + "' AND "
	cQuery += "      " + aTables[x][1] + ".D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cTopArea, .F., .T.)
	
	DbSelectArea( cTopArea )

 	lRet := (cTopArea)->( Eof() )

 	If lRet
       DbCloseArea()
 	Else
       Exit
 	EndIf

Next x

If Select( cTopArea ) > 0
   (cTopArea)->( dbCloseArea() )
Endif

DbSelectArea( cAlias )
	
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A094Imp  ³ Autor ³ Carlos Eduardo Chigres ³ Data ³ 17/07/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao das Entidades Bancarias via arquivo CSV           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A094Imp()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA094       	   								            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A094Imp( cAlias, nReg, nOpc )

Local aRet := {}

//--- Mostra o arquivo de LOG
Local oDlgEr
Local oMemo
Local cErroTxt := ""
Local cTitle   := OemToAnsi( STR0038 )   // "Log de Erros na Importação"
Local cTexto   := ""

//---Variaveis para manipular o TXT
Private cFile   := ""
Private nHdlErr := 0
Private lFirst  := .T.
Private lOcorre := .F.   // trigger de ocorrencia de erros

If FIN84Han()   // Criacao do arquivo texto de Log

   If ParamBox( {	{ 6, STR0012, padr("",150),"",,"", 90 ,.T.,STR0013,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;	 //"Estrut. de Entidades Bancárias"###"Arquivo .CSV |*.CSV" 
		STR0014,@aRet)  //"Importar entidades bancarias"

	   oProcess:= MsNewProcess():New( {|lEnd| FJNImpCSV( lEnd, oProcess, aRet[1] ) } )

	   oProcess:Activate()

        If lOcorre

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³  cErroTxt := "Foram encontrados erros durante o processamento." + Chr(13)+Chr(10)  ³
            //³  cErroTxt += "Arquivo de log de erros  " + Chr(13)+Chr(10)                         ³
            //³  cErroTxt += cFile + " disponivel para consulta. " + Chr(13)+Chr(10)               ³
            //³  cErroTxt += "Deseja visualizar o Arquivo de log agora ?"                          ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            cErroTxt := STR0042 + Chr(13)+Chr(10)
            cErroTxt += STR0043 + Chr(13)+Chr(10)
            cErroTxt += cFile + STR0044 + Chr(13)+Chr(10)
            cErroTxt += STR0045

            //        Atencao               Sim     Nao
            If Aviso( STR0010, cErroTxt , {STR0046,STR0047} ) == 1

			   DEFINE MSDIALOG oDlgEr TITLE cTitle From 0,0 TO 340,550 OF oMainWnd PIXEL

                   cTexto := MemoRead( cFile )

                   @ 5, 5 GET oMemo Var cTexto Of oDlgEr MEMO SIZE 267,145 PIXEL
                   oMemo:bRClicked := {||AllwaysTrue()}

                   DEFINE SBUTTON FROM 153,230 TYPE 1 ACTION oDlgEr:End() ENABLE OF oDlgEr PIXEL
	
		       ACTIVATE MSDIALOG oDlgEr CENTER
	
		    EndIf
       
        EndIf

   EndIf

EndIf

dbGoTop()

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FJNImpCSV ³ Autor ³ Marcelo Akama         ³ Data ³ 12/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao de tabelas de arquivo .CSV                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FJNImpCSV(lEnd, oProcess, cArq, aCfg)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = lEnd do MsNewProcess                               ³±±
±±³          ³ ExpO1 = Objeto MsNewProcess                                ³±±
±±³          ³ ExpC1 = Nome do arquivo a ser importado                    ³±±
±±³          ³ ExpA1 = Array com configuracoes de importacao no formato:  ³±±
±±³          ³                 {cAlias [ , [cCampos] [,bBloco] ] }        ³±±
±±³          ³         Onde:                                              ³±±
±±³          ³            cAlias  = Alias da tabela                       ³±±
±±³          ³            cCampos = Campos para importar (default: Todos) ³±±
±±³          ³            bBloco  = Bloco de codigo para inclusao custom. ³±±
±±³          ³         Ex.: { {"CT1","CT1_CONTA,CT1_CLASSE",{|| } }       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FJNImpCSV( lEnd, oProcess, cArq )

Local lOk		:= .T.
Local cLinha    := ""
Local cCodigo   := ""
Local cAgencia  := ""
Local cTexto    := " "

Local _cCod     := CriaVar( "FJO_COD" )
Local _cNome    := CriaVar( "FJO_NOME" )

Local cChave    := xFilial( "FJN" )
Local cNamCamp  := " "
Local nAt       := 1
Local nX        := 1
Local nTot      := 1
Local nPos      := 1
Local nCounter  := 0
Local xConteudo := Nil
Local xAutoCab  := {}
Local aTxt      := {}
Local aTables	:= {}
Local bAppend
Local aCampos   := FJN->( DbStruct() )
Local aObrigats := { "FJN_COD", "FJN_AGENCI" , "FJN_NOME", "FJN_POSTAL" }

SaveInter()

If (nHandle := FT_FUse(AllTrim(cArq)))== -1
	Help(" ",1,"NOFILEIMPOR")
	RestInter()
	Return .F.
EndIf

nTot:=FT_FLASTREC()
oProcess:SetRegua1(nTot)

FT_FGOTOP()

cLinha 	:= FT_FREADLN()
FT_FSKIP()
nCounter ++
oProcess:IncRegua1(STR0018) //"Lendo arquivo..."

nAt :=	1
//--- aTables armazena os Campos, lidos da primeira linha
Do While nAt > 0
	nAt	:=	AT(";",cLinha)
	If nAt == 0
		cToken := cLinha
	Else	
		cToken	:=	Substr(cLinha,1,nAt-1)
	EndIf
	AADD( aTables, cToken )
	cLinha	:=	Substr(cLinha,nAt+1)
EndDo


lOk := .T.
//--- Verifica a existencia dos campos
For nX := 1 To Len( aTables )

   nPos := aScan( aCampos, { |x| AllTrim( x[ 1 ] ) == AllTrim( aTables[ nX ] ) } )
   
   If nPos == 0
      //--- Excecao feita para o campo FJN_NOME, que passou para FJO ... _BLOCK tambem.
      If ! ( AllTrim( aTables[ nX ] ) $ "FJN_NOME/FJN_BLOCK" )

         lOk := .F.
         Exit

      EndIf
   EndIf

Next nX

If !lOk

    Aviso( STR0019, STR0023 + " " + aTables[nX] + " " + STR0024, {STR0020} ) 
    //"Estrutura incorreta."###"O campo "###" nao foi achado na estrutura, por favor verificar."###"Abandona"
    FT_FUSE()
    RestInter()
	Return .F.

EndIf

//--- Loop Principal
Do While !FT_FEOF()

	cLinha	:= FT_FREADLN()
	FT_FSKIP()
    nCounter ++
	oProcess:IncRegua1(STR0018)
	
	aTxt := {}
    //--- Bloco que extrai os Campos de uma Linha e armazena em aTxt
	Do While At(";",cLinha)>0

		aAdd( aTxt, Substr(cLinha,1,At(";",cLinha)-1) )
		cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')

	EndDo

    //--- Adiciona o ultimo campo 
	If Len( AllTrim( cLinha ) ) > 0
		aAdd(aTxt,StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
	Else
		aAdd(aTxt,"")
	EndIf	
	
	xAutoCab := {}
    _cCod    := CriaVar( "FJO_COD" )
    _cNome   := CriaVar( "FJO_NOME" )

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Construcao do array AutoCab com Nome Campo , Counteudo ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len( aTables )

        nPos := aScan( aCampos, { |x| AllTrim( x[ 1 ] ) == AllTrim( aTables[ nX ] ) } )
        
        If nPos == 0

           If AllTrim( aTables[ nX ] ) == "FJN_NOME"

		      AADD( xAutoCab, { "FJN_NOME" , aTxt[ nX ] , Nil } )
           
           EndIf
        
        Else
	
		   Do Case
    					
			  Case aCampos[ nPos ][ 2 ] == "C"

				  AADD( xAutoCab, { aCampos[ nPos ][ 1 ], aTxt[ nX ] , Nil } )
							
			  Case aCampos[ nPos ][ 2 ] == "D"

				  AADD( xAutoCab, { aCampos[ nPos ][ 1 ], STOD( aTxt[ nX ] ) , Nil } )
					
			  Case aCampos[ nPos ][ 2 ] == "N"

				  AADD( xAutoCab, { aCampos[ nPos ][ 1 ], Val( aTxt[ nX ] ) , Nil } )
						
		   EndCase

        EndIf 
				
	Next nX

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Validacao e Ajuste do array AutoCab ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    lOk      := .T.
    cCodigo  := " "
    cAgencia := " "
    //
	For nX := 1 To Len( xAutoCab )

        //--- Busco array de campos obrigatorios
        nPos := aScan( aObrigats, { |x| AllTrim( x ) == AllTrim( xAutoCab[ nX ][ 1 ] ) } )

        If nPos > 0

           cNamCamp  := AllTrim( xAutoCab[ nX ][ 1 ] )  // Nome do Campo
        
           xConteudo := xAutoCab[ nX ][ 2 ]
           
           If Empty( xConteudo )
              //
              lOk := .F.                
              //
              If !lOcorre
                 lOcorre := .T.
              EndIf
              //
              // "Inconsistencia." ### "Localizado Campo Obrigatorio não preenchido na linha " + 99999 : <nome do campo>
              cTexto := STR0032 + STR0033 + AllTrim( Str( nCounter, 5 ) ) + " : " + cNamCamp + "."
              //
		      FIN84Grv( cTexto )
              //
           EndIf

        EndIf

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Ajuste do tamanho dos campos Chave ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If AllTrim( xAutoCab[ nX ][ 1 ] ) == "FJN_COD"

           cCodigo := A094Ajus( "FJN_COD" , xConteudo )

           xAutoCab[ nX ][ 2 ] := cCodigo                      

           //--- Variavel a ser destinada a tabela FJO
           _cCod := cCodigo                      
           //-----------------------------------------

        EndIf
        //
        If AllTrim( xAutoCab[ nX ][ 1 ] ) == "FJN_AGENCI"

           cAgencia := A094Ajus( "FJN_AGENCI" , xConteudo )

           xAutoCab[ nX ][ 2 ] := cAgencia 

        EndIf
        //
        If AllTrim( xAutoCab[ nX ][ 1 ] ) == "FJN_NOME"

           //--- Variavel a ser destinada a tabela FJO
           _cNome := xConteudo
           //-----------------------------------------

        EndIf

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Validacao da Provincia ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If AllTrim( xAutoCab[ nX ][ 1 ] ) == "FJN_PROV"

           lOk := ExistCpo( "SX5", "12" + xAutoCab[ nX ][ 2 ],,,.F. )   
           // dbSelectArea("SX5")
           // dbSetOrder(1)

           If !lOk
              // 
              If !lOcorre
                 lOcorre := .T.
              EndIf
              //
              // "Informação da Provincia." ### "A informação de Provincia está incorreta na linha " + 99999.
              cTexto := STR0031 + STR0034 + AllTrim( Str( nCounter, 5 ) ) + "."
              //
		      FIN84Grv( cTexto )
              //
           EndIf

        EndIf

	Next nX
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ FIM da Validacao no array AutoCab ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Validacao de Chave Unica ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lOk
       //
       If !Empty( cCodigo + cAgencia )

          dbSetOrder( 1 )

          If dbSeek( cChave + cCodigo + cAgencia )
             lOk := .F.
          EndIf

       EndIf			

    EndIf 

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Validacao realizada ... ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lOk

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Verifica a tabela Pai ...  ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       dbSelectArea("FJO")
       dbSetOrder( 1 )
       If !dbSeek( xFilial("FJO") + cCodigo )

          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³ Grava registro Pai ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          RecLock( "FJO" , .T. )

             FJO->FJO_FILIAL := xFilial("FJO")
             FJO->FJO_COD    := _cCod
             FJO->FJO_NOME   := _cNome
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Por definicao de requisito, fixa o Status como Bloqueado ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             FJO->FJO_BLOCK  := "1"             
              
          MsUnLock()

       EndIf

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Prossegue com a gravacao ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       dbSelectArea("FJN")

       RecLock( "FJN" , .T. )

          FJN->FJN_FILIAL := cChave
          
     	    For nX := 1 To Len( xAutoCab )

               If !( AllTrim( xAutoCab[ nX ][ 1 ] ) $ "FJN_NOME/FJN_BLOCK" )

	     		  FieldPut( FieldPos( xAutoCab[ nX ][ 1 ] ), xAutoCab[ nX ][ 2 ] )

               EndIf
       
     		Next nX

       MsUnLock()

    EndIf

EndDo

FT_FUSE()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento do arquivo de LOG ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FClose( nHdlErr )

If lOcorre
   Aviso(STR0025,STR0041,{STR0027}) //"Finalizado" //"Importacao finalizada com erros"   //###"Fechar"
Else
   Aviso(STR0025,STR0026,{STR0027}) //"Finalizado" //"Importacao finalizada com sucesso" //###"Fechar"
EndIf

RestInter()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A094Ajus ³ Autor ³ Carlos Eduardo Chigres ³ Data ³ 17/07/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenchimento a Esquerda dos campos FJN_COD e FJN_AGENCI     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A094Imp()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA094, A094Imp()  								            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A094Ajus( cCampo, xContenido )

Local cReto := xContenido

If Len( xContenido ) < TamSX3( cCampo )[1] 

   cReto := PadL( xContenido , TamSX3( cCampo )[1], '0' )

EndIf

Return( cReto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MEM2REG  º Autor ³ Andre Schwartz     º Data ³  17/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava as variaveis de memoria criadas pela funcao Regtomemorº±±
±±º          ³Modificado por Carlos Queiroz em 07/12/04.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Mem2Reg( cAlias, lIncluir )          // Mem2Reg("SB1",cOpca == 3)

Local nFilial := 0     							   // Variavel utilizada para receber a filial
Local cAuxRec, cAuxMem, aArea := GetArea(), x     //  Declaração de variaveis locais

dbSelectArea(cAlias)                              // Seciona a area da tabela SB1
nFilial := aScan(dbStruct(), {|x| "_FILIAL" $ x[1]})    // Procura no array pelo aScan o conteudo de _FILIAL

RecLock(cALias, lIncluir)                         // Trava a tabela para a gravacao

for x:= 1 TO FCount()                             // For de 1 ateh o numero de campos que sao utilizados na tabela SB1(FCount())
	cAuxMem := Alltrim("M->"+FieldName(x))       // Armazena o conteudo do campo da tabela em uma variavel auxiliar.
	FieldPut(x, &(cAuxMem))                      // Grava o conteudo do campo armazenado na auxilar no Banco de Dados.
next			 								 // Proximo campo da tabela SB1

If nFilial > 0                                // Se Filial for Maior que Zero, ou seja, se ele localizou no aScan a filial
	FieldPut(nFilial, xFilial(cAlias))       // Grava-se o conteudo da filial no registro do campo que estah ativo no FOR
Endif

msUnlock()  	 // Destrava a tabela da gravacao
// RestArea(aArea)  //Retorna a area da tabela anterior
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  GCOL    ºAutor  ³Andre Schwartz      º Data ³  17/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava o Conteudo do Acols da tabela FJN.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GCol(aCols, aHeader, aRegCol, cAlias, bBloco, cCampos)      // Parametros passados pela ACSA080

Local nFilial := 0              											  //Declara a variavel
Local i, j, z, lEmpty := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao default: Caso nao seje passado nenhum parametro cAlias    ³
//³na chamada da GCol ele joga na variavel o conteudo chamado na funcao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default cAlias := Alias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao default com bloco de rotina: Caso nao seje passado nenhum    ³
//³parametro bBloco na chamada do GCol ele executa o bloco que se encontra ³
//³no fonte ACSA080. bBloco{|| PA3->PA3_FILIAL + PA3->PA3_CODPRO} .        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default bBloco := {||}

dbSelectArea(cAlias)
nFilial := aScan(dbStruct(), {|x| "_FILIAL" $ x[1]})  // Procura no array a filial
For i := 1 to Len(aCols)                               // FOR de 1 ateh a quantidade do numero do aCols
	If i <= Len(aRegCol)                               // Se for menor ou igual a quantidade do aRegCol
		dbGoto(aRegCol[i])                             // Salva o registro aRegCol que se encontrava antes de entrar no FOR, para quando sair do laco ele posicionar no registro que estava anteriormente
		RecLock(cAlias, .f.)                           // Trava a tabela e retorna falso para ela para nao inclusao
		If aCols[i, Len(aHeader)+1]                    // Posiciona na linha do aCols e na coluna que se encontra apos a ultima.
			dbDelete()
			MsUnlock()
			Loop         								// Sai da condicao For
		Endif
	Else
		If ValType(cCampos) == "C"                  // Valida se o tipo do campo eh caracter
			For j := 1 to Len(aHeader)
				If AllTrim(aHeader[j, 2]) $ Upper(cCampos)
					If Empty(aCols[i, j])
						lEmpty := .T.
						Loop
					Endif
				Endif
			Next
		Endif
		If ! aCols[i, Len(aHeader)+1] .And. ! lEmpty
			RecLock(cAlias, .T.)
		Else
			Loop
		Endif
	Endif
	For z := 1 to Len(aHeader)
		If (nFieldPos := FieldPos(aHeader[z, 2])) > 0
			FieldPut(nFieldPos, aCols[i, z])
		Endif
	Next
	If nFilial > 0
		FieldPut(nFilial, xFilial(cAlias))         // Grava o conteudo da filial
	Endif
	Eval(bBloco)			// Executa os blocos de validacao
	MsUnlock()
Next
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FJNCON   º Autor ³ Microsiga          º Fecha³  02/26/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta Padrao dos campos EL_BCOCHQ e E5_BCOCHQ.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FJNCON()

    //--- Ambiente
	Local aArea := GetArea()
    
    //--- Select
	Local cQuery	:= ""
	Local cAliasFJN	:= ""
	Local aItens	:= {}

    //--- Dialog Principal
	Local oDlgFJN
	Local oBrwFJN
    
    //--- Variavel Get para Pesquisa 
	Local cDesc		:= ""
	Local cDesc2	:= ""
	Local oDesc
	Local oDesc2 := Nil
	Local oSayDesc
	Local oSayDesc2 := Nil

    //--- Genericas
	Local aScrRes	:= {}
	Local cFilFJN	:= xFilial( "FJN" )
	Local cDescFJN	:= OemToAnsi(STR0035)   // "ENTIDADES BANCARIAS"
	Local nItem		:= 0
	Local xRet		:= .F.

	//--- Paineis
	Local oPnlTopo
	Local oPnlEsq
	Local oPnlDir
	Local oPnlBase
	Local oPnlCons
	Local oPnlCons1 := Nil
	Local oPnlCons2 := Nil
	Local oPnlBot
	Local oSep0
	Local oSep1
	Local oSep2
	Local oSep3
	Local oSep4
	Local oSep5
	Local oSepSpace := Nil

	//--- Botoes	
	Local oBtnSair
	Local oBtnOk
	Local oBtnPesq

	
		#IFDEF TOP
			If cPaisLoc == "ARG"
				cQuery := " Select FJN.R_E_C_N_O_, FJN_COD,FJN_AGENCI,FJN_POSTAL,FJO_NOME"
			Else
				cQuery := " Select FJN.R_E_C_N_O_, FJN_COD,FJN_AGENCI,FJO_NOME"
			EndIf 
			 
			cQuery += " From " + RetSqlName("FJN") + " FJN , " + RetSqlName("FJO") + " FJO"

			cQuery += " Where FJN.FJN_FILIAL = '" + cFilFJN + "'"
			cQuery += " And FJN.FJN_FILIAL = FJO.FJO_FILIAL"
			cQuery += " And FJN.FJN_COD = FJO.FJO_COD"
			cQuery += " And FJO.FJO_BLOCK <> '1'"
			cQuery += " And FJN.D_E_L_E_T_ = ' '" 
			cQuery += " And FJO.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY FJN_COD"

			cAliasFJN := GetNextAlias()

			cQuery := ChangeQuery( cQuery )

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFJN,.T.,.T.)

			dbSelectArea( cAliasFJN )

			While !Eof()
			   If cPaisLoc == "ARG"
			   		Aadd( aItens, { FJN_COD, FJN_AGENCI, FJN_POSTAL, FJO_NOME, R_E_C_N_O_ } )
			   Else
			   		Aadd( aItens, { FJN_COD, FJN_AGENCI, FJO_NOME, R_E_C_N_O_ } )
			   EndIf
			   DbSkip()
			Enddo

			dbCloseArea()

		#ELSE

			dbSelectArea("FJN")
			dbSetOrder(1)

			While !EOF()

			   dbSelectArea("FJO")
			   dbSetOrder(1)

               If dbSeek( xFilial("FJO")+FJN->FJN_COD )

                  If FJO_BLOCK == 2 

			         Aadd( aItens, { FJN->FJN_COD, FJN->FJN_AGENCI, FJN->FJN_POSTAL, FJO_NOME, FJN->(RECNO()) } )
                  
                  EndIf

   		       EndIf

			   dbSelectArea("FJN")
			   dbSkip()
			Enddo

		#ENDIF
		
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Montagem dos Paineis ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( aItens )

            //--- Variavel Get para Pesquisa 
			cDesc := Space(GetSX3Cache("FJN_COD", "X3_TAMANHO")) 
			cDesc2:= Space(GetSX3Cache("FJO_NOME", "X3_TAMANHO")) 

			aScrRes := MsAdvSize(.F.,.F.,300)

			oDlgFJN := TDialog():New(aScrRes[7],0,aScrRes[6]-250,aScrRes[5]-450,AllTrim(cDescFJN),,,,,,,,,.T.,,,,,)

				oPnlEsq := TPanel():New(01,01,,oDlgFJN,,,,,,5,5,.F.,.F.)
					oPnlEsq:Align := CONTROL_ALIGN_LEFT
					oPnlEsq:nWidth := 10
				oPnlDir := TPanel():New(01,01,,oDlgFJN,,,,,,5,5,.F.,.F.)
					oPnlDir:Align := CONTROL_ALIGN_RIGHT
					oPnlDir:nWidth := 10
				oPnlBase := TPanel():New(01,01,,oDlgFJN,,,,,,5,30,.F.,.F.)
					oPnlBase:Align := CONTROL_ALIGN_BOTTOM
					oPnlBase:nHeight := 10
				oPnlTopo := TPanel():New(01,01,,oDlgFJN,,,,,,5,30,.F.,.F.)
					oPnlTopo:Align := CONTROL_ALIGN_TOP
					oPnlTopo:nHeight := 10

                //--- Painel da Pesquisa 
				oPnlCons := TPanel():New(01,01,,oDlgFJN,,,,,,5,30,.F.,.F.)
					oPnlCons:Align := CONTROL_ALIGN_TOP
					oPnlCons:nHeight := 40

				IF cPaisLoc != "BRA"
					oSep4 := TPanel():New(10,10,,oPnlCons,,,,,,5,30,.F.,.F.)
					oSep4:Align := CONTROL_ALIGN_LEFT
					oSep4:nWidth := 10
						
					oPnlCons1 := TPanel():New(10,10,,oPnlCons,,,,,,200,30,.F.,.F.)
					oPnlCons1:Align := CONTROL_ALIGN_LEFT

						@00,00 MSGET oDesc VAR cDesc SIZE 5,100 PIXEL OF oPnlCons1 WHEN (VAZIO(cDesc2))
							oDesc:Align := CONTROL_ALIGN_BOTTOM
							oDesc:nHeight := 20
						oSayDesc := TSay():New(10,10,{|| FJN->(RetTitle("FJN_COD"))},oPnlCons1,,,,,,.T.,,,10,10)
							oSayDesc:Align := CONTROL_ALIGN_TOP
							oSayDesc:nHeight := 20
					
					// Separador entre Banco y Nombre
					oSepSpace := TPanel():New(0,0,,oPnlCons,,,,,,5,30,.F.,.F.)
					oSepSpace:Align  := CONTROL_ALIGN_LEFT
					oSepSpace:nWidth := 20   

					oPnlCons2 := TPanel():New(10,10,,oPnlCons,,,,,,200,30,.F.,.F.)
					oPnlCons2:Align := CONTROL_ALIGN_LEFT

						@00,00 MSGET oDesc2 VAR cDesc2 SIZE 5,100 PIXEL OF oPnlCons2 WHEN (VAZIO(cDesc))
							oDesc2:Align := CONTROL_ALIGN_BOTTOM
							oDesc2:nHeight := 20
						oSayDesc2 := TSay():New(10,10,{|| FJN->(RetTitle("FJO_NOME"))},oPnlCons2,,,,,,.T.,,,10,10)
							oSayDesc2:Align := CONTROL_ALIGN_TOP
							oSayDesc2:nHeight := 20
						
					oSep5 := TPanel():New(10,10,,oPnlCons,,,,,,5,30,.F.,.F.)
					oSep5:Align := CONTROL_ALIGN_RIGHT
					oSep5:nWidth := 10
					
					oPnlBot := TPanel():New(20,10,,oPnlCons,,,,,,5,30,.F.,.F.)
						oPnlBot:Align := CONTROL_ALIGN_RIGHT
						oPnlBot:nWidth := 100

					//--- Botao Pesquisar 
					oPnlBot1 := TPanel():New(01,01,,oPnlBot,,,,,,5,30,.F.,.F.)
						oPnlBot1:Align := CONTROL_ALIGN_BOTTOM
						oPnlBot1:nHeight := 20
						oBtnPesq := TButton():New(0,0,STR0002,oPnlBot1,{|| oBrwFJN:nAt := FJNBan(cDesc,cDesc2,aItens,oBrwFJN:nAt) },30,10,,,,.T.,,"",,,,)		//"Pesquisar"
						oBtnPesq:Align := CONTROL_ALIGN_RIGHT
						oBtnPesq:nWidth := 80
				ELSE
					oPnlCons1 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
					oPnlCons1:Align := CONTROL_ALIGN_ALLCLIENT

						@00,00 MSGET oDesc VAR cDesc SIZE 5,100 PIXEL OF oPnlCons1
							oDesc:Align := CONTROL_ALIGN_BOTTOM
							oDesc:nHeight := 20
						oSayDesc := TSay():New(0,0,{|| FJN->(RetTitle("FJN_COD"))},oPnlCons1,,,,,,.T.,,,10,10)
							oSayDesc:Align := CONTROL_ALIGN_TOP
							oSayDesc:nHeight := 20

					oSep4 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep4:Align := CONTROL_ALIGN_RIGHT
						oSep4:nWidth := 10
					oSep5 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep5:Align := CONTROL_ALIGN_LEFT
						oSep5:nWidth := 10
					oPnlBot := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oPnlBot:Align := CONTROL_ALIGN_RIGHT
						oPnlBot:nWidth := 100

                    //--- Botao Pesquisar 
					oPnlBot1 := TPanel():New(01,01,,oPnlBot,,,,,,5,30,.F.,.F.)
						oPnlBot1:Align := CONTROL_ALIGN_BOTTOM
						oPnlBot1:nHeight := 20
						oBtnPesq := TButton():New(0,0,STR0002,oPnlBot1,{|| oBrwFJN:nAt := FJNPes(cDesc,aItens,oBrwFJN:nAt) },30,10,,,,.T.,,"",,,,)		//"Pesquisar"
							oBtnPesq:Align := CONTROL_ALIGN_RIGHT
							oBtnPesq:nWidth := 80
				ENDIF

				oSep3 := TPanel():New(01,01,,oDlgFJN,,,,,,5,30,.F.,.F.)
					oSep3:Align := CONTROL_ALIGN_TOP
					oSep3:nHeight := 10

				oPnlBotoes := TPanel():New(01,01,,oDlgFJN,,,,,,5,30,.F.,.F.)
					oPnlBotoes:Align := CONTROL_ALIGN_BOTTOM
					oPnlBotoes:nHeight := 20
					oSep0 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep0:Align := CONTROL_ALIGN_TOP
						oSep0:nHeight := 5
					oSep1 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep1:Align := CONTROL_ALIGN_RIGHT

					oBtnSair := TButton():New(0,0,STR0020,oPnlBotoes,{|| nItem := 0,oDlgFJN:End()},30,10,,,,.T.,,"",,,,)	//"Abandona"
						oBtnSair:Align := CONTROL_ALIGN_RIGHT

					oSep2 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep2:Align := CONTROL_ALIGN_RIGHT

					oBtnOk := TButton():New(0,0,STR0036,oPnlBotoes,{|| nItem := oBrwFJN:nAt,oDlgFJN:End()},30,10,,,,.T.,,"",,,,) //"Selecionar"
						oBtnOk:Align := CONTROL_ALIGN_RIGHT

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Montagem das Colunas ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oBrwFJN := TCBrowse():New(0,0,100,100,,,,oBrwFJN,,,,,,,,,,,,.T.,"",.T.,{|| .T.},,,,)

				oBrwFJN:AddColumn(TCColumn():New(FJN->(RetTitle("FJN_COD"))   ,{|| aItens[oBrwFJN:nAt,1]},,,,"LEFT",20,.F.,.F.,,,,,))
				oBrwFJN:AddColumn(TCColumn():New(FJN->(RetTitle("FJN_AGENCI")),{|| aItens[oBrwFJN:nAt,2]},,,,"LEFT",25,.F.,.F.,,,,,))
				
				If cPaisLoc == "ARG"
					oBrwFJN:AddColumn(TCColumn():New(FJN->(RetTitle("FJN_POSTAL")),{|| aItens[oBrwFJN:nAt,3]},,,,"LEFT",20,.F.,.F.,,,,,))
					oBrwFJN:AddColumn(TCColumn():New(FJO->(RetTitle("FJO_NOME"))  ,{|| aItens[oBrwFJN:nAt,4]},,,,"LEFT",45,.F.,.F.,,,,,))
				Else				
					oBrwFJN:AddColumn(TCColumn():New(FJO->(RetTitle("FJO_NOME"))  ,{|| aItens[oBrwFJN:nAt,3]},,,,"LEFT",45,.F.,.F.,,,,,))
				EndIf

				oBrwFJN:Align     := CONTROL_ALIGN_ALLCLIENT
				oBrwFJN:lAutoEdit := .F.
				oBrwFJN:lReadOnly := .F.
				oBrwFJN:SetArray(aItens)
				oDlgFJN:lCentered := .T.

			oDlgFJN:Activate(,,,,)

		Else

			ApMsgAlert( STR0037 ) //"Não foram encontrados itens para a tabela FJN"

		EndIf

	RestArea( aArea )

	If nItem > 0
		If cPaisLoc == "ARG"
			FJN->(DbGoTo(aItens[nItem,5]))
		Else
			FJN->(DbGoTo(aItens[nItem,4]))
		EndIf		
		xRet := .T.
	Endif

Return( xRet )

Static Function FJNPes( cTarget, aSearch, nPos )

Local nPes := 0

   nPes := aScan( aSearch, { |x| x[ 1 ] == cTarget } )
   
   If nPes == 0
      nPes := nPos
   EndIf
   
Return( nPes )

/*/{Protheus.doc} FJNBan
Funcion que retornara la pocisión del banco de acuerdo al filtro (codigo o nombre de banco) utilizado en la consulta especifica
@type function
@version  1
@author luis.aboytes
@since 15/12/2025
@param cTarget, character, codigo del banco
@param cTarget2, character, nombre del banco
@param aSearch, array, param_ lista de bancos disponibles 
@param nPos, numeric, param_ posicion original del focus en el grid
@return nPes, numeric, posición del banco encontrado
/*/
Static Function FJNBan( cTarget As Character, cTarget2 As Character, aSearch As Array, nPos As Numeric)
Local nPes 			As Numeric 

Default cTarget 	:= ""
Default cTarget2 	:= ""
Default aSearch 	:= {}
Default nPos		:= 0

nPes		:= 0

	// 9 = TAB en ASCII
    Keyboard( Chr( 9 ) )

	IF !VAZIO(cTarget) .OR. !VAZIO(cTarget2) 
		nPes := aScan( aSearch, { |x| IIF(VAZIO(cTarget),RTRIM(cTarget2),RTRIM(cTarget)) $ IIF(VAZIO(cTarget),x[4],x[1])  } )
	ENDIF

   If nPes == 0
      nPes := nPos
   EndIf
   
Return(nPes)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FIN84Han ³ Autor ³ Carlos Eduardo Chigres ³ Data ³ 05/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Criacao do Arquivo de Log de erros                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACSA110                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FIN84Han()

Local lRet := .T.

//--- Monta o nome do arquivo
cFile += Str( Year( dDataBase ), 4 )
cFile += "_"
cFile += StrZero( Month( dDataBase ), 2 )
cFile += "_"
cFile += StrZero( Day( dDataBase ), 2 )
cFile += "_"
cFile += "Log_Import.TXT"
cFile := Upper( cFile )

//--- Tenta gerar o arquivp
nHdlErr := FCreate( cFile, 0 )

//--- Verifica o sucesso da operacao
If nHdlErr == -1

   lRet := .F.

// "Não foi possivel criar o arquivo de log "
   ApMsgAlert( STR0039 + cFile + "." ) 

EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FIN84Grv ³ Autor ³ Carlos Eduardo Chigres ³ Data ³ 05/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava registros de erro no arquivo de Log                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ Linha de texto a ser gravada no Log                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA094                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FIN84Grv( cLinha )

Local cAlias := Alias()
Local cCR    := Chr(13)+Chr(10)
Local cReg   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava cabecalho no arquivo TXT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFirst
	lFirst := .F.
	
	cReg := STR0040  // "Registros de Inconsistencias na Importação de Entidades Bancarias."
	cReg += cCR
	
	FWrite( nHdlErr, cReg )
	
	//---Insere uma linha em branco
	cReg := " "
	cReg += cCR
	FWrite( nHdlErr, cReg )
	
EndIf

cReg := cLinha
cReg += cCR

FWrite( nHdlErr, cReg )

dbSelectArea( cAlias )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A094ChgP ³ Autor ³ Carlos Eduardo Chigres ³ Data ³ 17/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao de alteracao dos campos FJN_POSTAL e FJN_AGENCI    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A094ChgP                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA094 ( MsGetDados )       					            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A094ChgP()

//--- Retorno
Local lValida := .T.

//--- Lido da Edicao
Local cCampo := ReadVar()
Local xConte := &( ReadVar() )

//--- Lido do aCols
Local cAgenPrev := GDFieldGet( "FJN_AGENCI", n, ,oGet:aHeader, oGet:aCols )
Local cPostPrev := GDFieldGet( "FJN_POSTAL", n, ,oGet:aHeader, oGet:aCols )

//--- Genericas
Local lApaga   := .F.
Local aApagAGE := {}
Local aApagPOS := {}

 Aadd( aApagAGE, { "SEL", "EL_BCOCHQ", "EL_AGECHQ" } )

 Aadd( aApagPOS, { "SEL", "EL_BCOCHQ", "EL_AGECHQ", "EL_POSTAL" } )


If cCampo == "M->FJN_AGENCI"

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Comparo conteudo editado com o Previo ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   If ( xConte <> cAgenPrev ) .And. !Empty( cAgenPrev )
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Verifica possiveis Vinculos Ativos com as Tabelas SEL e SE5, antes da confirmacao de Delecao ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

      //--- Funcao que avalia vinculo
      lApaga := AYDelete( cCampo, aApagAGE, cAgenPrev )   

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³ Caso existir vinculo com outra tabela nao permite exclusao ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If !lApaga

         Aviso( OemToAnsi(STR0010), OemToAnsi(STR0049), {"Ok"} )  // "Atenção", "Esse Conteúdo não pode ser alterado, pois se encontra em uso no Sistema." 

         lValida := .F.

      EndIf

   EndIf
   
ElseIf cCampo == "M->FJN_POSTAL"

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Comparo conteudo editado com o Previo ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

   If ( xConte <> cPostPrev )  .And. !Empty( cPostPrev )
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Verifica possiveis Vinculos Ativos com as Tabelas SEL e SE5, antes da confirmacao de Delecao ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

      //--- Funcao que avalia vinculo
      lApaga := AYDelete( cCampo, aApagPOS, cAgenPrev, cPostPrev )   

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³ Caso existir vinculo com outra tabela nao permite exclusao ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If !lApaga

         Aviso( OemToAnsi(STR0010), OemToAnsi(STR0049), {"Ok"} )  // "Atenção", "Esse Conteúdo não pode ser alterado, pois se encontra em uso no Sistema." 

         lValida := .F.

      EndIf

   EndIf

EndIf

Return( lValida )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A094DelK ³ Autor ³ Carlos Eduardo Chigres ³ Data ³ 17/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao de exclusao de linha da GetDados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A094DelK                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA094 ( MsGetDados )       					            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A094DelK()

//--- Retorno
Local lValida := .T.

//--- Lido do aCols
Local cAgeChq := GDFieldGet( "FJN_AGENCI", n, ,oGet:aHeader, oGet:aCols ) 
Local cPostal := GDFieldGet( "FJN_POSTAL", n, ,oGet:aHeader, oGet:aCols ) 

//--- Genericas
Local cCampo := "M->FJN_POSTAL"
Local lApaga := .F.
Local aApaga := {}

 Aadd( aApaga, { "SEL", "EL_BCOCHQ", "EL_AGECHQ", "EL_POSTAL" } )

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Verifica possiveis Vinculos Ativos com as Tabelas SEL e SE5, antes da confirmacao de Delecao ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

 //--- Funcao que avalia vinculo
 lApaga := AYDelete( cCampo, aApaga, cAgeChq, cPostal )   

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Caso existir vinculo com outra tabela nao permite exclusao ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If !lApaga

    Aviso( OemToAnsi(STR0010), OemToAnsi(STR0048), {"Ok"} )  // "Atenção", "Esse Conteúdo não pode ser excluído, pois se encontra em uso no Sistema." 

    lValida := .F.

 EndIf

Return( lValida )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AYDelete  ³ Autor ³ Fabio Jadao Caires    ³ Data ³ 14/07/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica vinculos em outras tabelas antes da exclusao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AYDelete( ExpC1 , ExpC2 )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Array com matriz: coluna 1=Alias, coluna 2=Campo     ³±±
±±³          ³ ExpC2 = O que procurar se ha vinculo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO     	   								            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AYDelete( cCampo, aTables, cAgeChq, cPostal )   

Local lRet 		:= .F.
Local cQuery	:= ""
Local x			:= 0
Local cAlias	:= alias()
Local cBcoChq   := FJO->FJO_COD
Local cTopArea  := " "

For x := 1 To Len( aTables )

    cTopArea := GetNextAlias()

     If Select( cTopArea ) > 0
       (cTopArea)->( dbCloseArea() )
     Endif

    If cCampo == "M->FJN_AGENCI"

       cQuery := "SELECT * "
	   cQuery += "FROM  " + RetSQLName( aTables[x][1] ) + " " + aTables[x][1] + " "
	   cQuery += "WHERE " + aTables[x][1] + "." + aTables[x][2] + " = '" + cBcoChq + "' AND "
	   cQuery += "      " + aTables[x][1] + "." + aTables[x][3] + " = '" + cAgeChq + "' AND "
	   cQuery += "      " + aTables[x][1] + ".D_E_L_E_T_ = ' ' "
    
    ElseIf cCampo == "M->FJN_POSTAL"

       cQuery := "SELECT * "
	   cQuery += "FROM  " + RetSQLName( aTables[x][1] ) + " " + aTables[x][1] + " "
	   cQuery += "WHERE " + aTables[x][1] + "." + aTables[x][2] + " = '" + cBcoChq + "' AND "
	   cQuery += "      " + aTables[x][1] + "." + aTables[x][3] + " = '" + cAgeChq + "' AND "
	   cQuery += "      " + aTables[x][1] + "." + aTables[x][4] + " = '" + cPostal + "' AND "
	   cQuery += "      " + aTables[x][1] + ".D_E_L_E_T_ = ' ' "
    
    EndIf
    
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cTopArea, .F., .T.)
	
	DbSelectArea( cTopArea )

 	lRet := (cTopArea)->( Eof() )

 	If lRet
       DbCloseArea()
 	Else
       Exit
 	EndIf

Next x

If Select( cTopArea ) > 0
   (cTopArea)->( dbCloseArea() )
Endif

DbSelectArea( cAlias )
	
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º GDFILL  A  º Autor º        Nava        º Data º 18/10/01 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   Preenche aHeader e Acols da GetDados retornando Array de Gravacao    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º GDFill         ( cAlias, nOrder, cSeekKey, bSeekWhile, ;  º±±
±±º            º                  bSeekFor, aNoFields, aYesFields,lOnlyYes)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                                           º±±
±±º         01 º nOpcx      - Opcao PADRAO do Mbrowse                      º±±
±±º         02 º cAlias     - Alias                                        º±±
±±º         03 º nOrder     - Ordem                                        º±±
±±º         04 º cSeekKey   - Chave de Seek para montar aCols              º±±
±±º         05 º bSeekWhile - Condicao While                               º±±
±±º         06 º bSeekFor   - Condicao For                                 º±±
±±º         07 º aNoFields  - Campos a serem excluidos                     º±±
±±º         08 º aYesFields - Campos a serem incluidos                     º±±
±±º         09 º lOnlyYes   - Flag indicando se considera somente os camposº±±
±±º            º declarados no aYesFields + campos do usuario              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º aColsRecno - Contem os Recno()'s que serao gravados       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º Generico                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º Supoe aHeader e Acols declarados como Private PELO progr. º±±
±±º            º e inicializadas como um array vazio.                      º±±
±±º            º O array do retorno contem todos os 'recno()' do arquivo   º±±
±±º            º que foi alterado/incluido. Portanto BASTA chamar a funcao º±±
±±º            º TMSRecGetD com este mesmo Array.                          º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A094Fill( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, bSeekFor, aNoFields, aYesFields, lOnlyYes )

LOCAL aArea 		:= GetArea()
LOCAL aAreaAlias  := ( cAlias )->( GetArea() )
LOCAL lNoFields	:= ( aNoFields <> NIL )
LOCAL lYesFields	:= ( aYesFields <> NIL )
LOCAL aColsRecno  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aHeader e Acols devem vir definidos OBRIGATORIAMENTE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nUsado      := Len( aHeader )

DEFAULT nOrder	  := 1
DEFAULT bSeekFor  := { || .T. }
DEFAULT lOnlyYes  := .F.

// aHeader e aCols jah VEM PREECHIDOS OU VAZIO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX3->( DbSetOrder( 1 ) )
SX3->( DbSeek( cAlias ) )

SX3->( DbEval( {||	++nUsado, ;
		 					AADD(	aHeader, {	;
												AllTrim( X3Titulo()), ;
												RTrim(X3_CAMPO),; 
												X3_PICTURE, ;
												X3_TAMANHO, ;
												X3_DECIMAL, ;
												X3_VALID, 	;
												X3_USADO,	;
												X3_TIPO, 	;
												X3_F3,	    ;
												X3_CONTEXT  ;
		                           } ) },;
					{ || 	( lYesFields .AND. Ascan( aYesFields, Rtrim( X3_CAMPO ) ) > 0 ) .OR. ;
							If(lOnlyYes,X3_PROPRI == "U" .And. X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL,;
							( X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. ;
							( !lNoFields .OR. Ascan( aNoFields, Rtrim( X3_CAMPO ) ) = 0 ) )) },;
					{ || 	! Eof() .AND. X3_ARQUIVO == cAlias } )	)			
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aCols para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

( cAlias )->( DbSetOrder( nOrder ) )
( cAlias )->( DbSeek( cSeekKey ) )

( cAlias )->( DbEval( {||	Aadd( aColsRecno, Recno() ), ;
									Aadd( aCols, Array( nUsado + 1 ) ), ;
									Aeval( aHeader, {|aCampo, nI|	aCols[Len(aCols),nI] := IF( aCampo[10] != 'V'.AND.nOpcx<>3,;
																				FieldGet(FieldPos(aHeader[nI,2])), ;
																				CriaVar(aHeader[nI,2],.T.) )  } ),;
									aCols[Len(aCols),nUsado+1]:=.F. },;
									bSeekFor,;
								{||!Eof() .AND. Eval( bSeekWhile ) == cSeekKey } )	)	
					
If ( Empty(aCols) ) // Coloca ao menos 1 em branco para a Inclusao ...
	Aadd(aCols,Array(nUsado+1))
	Aeval( aHeader, {|aCampo, nI| aCols[1][nI] := ( cAlias )->( CriaVar(aHeader[nI,2],.T.) ) } )
	aCols[Len(aCols)][nUsado+1] := .F. 
EndIf

RestArea( aAreaAlias )
RestArea( aArea )

RETURN ( aColsRecno )
