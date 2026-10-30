#INCLUDE "TOTVS.CH"     
#INCLUDE "QIEA331.CH" 
#INCLUDE "FWMBROWSE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QIEA331   ³ Autor ³ Paulo Emidio de Barros³ data ³03/04/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Plano de Amostragem Produto x Fornecedores x Ensaios.	  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado -> STR0006                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³ 										 		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()
Local aRotAdic := {}
Local lPageAction := .T.
Local aRotina  := {{OemToAnsi(STR0001),"AxPesqui"    ,0,1,,.F.},;  //"Pesquisar"
					 {OemToAnsi(STR0002),"Q331AtPlAm"  ,0,2},;  //"Visualizar"
					 {OemToAnsi(STR0003),"Q331AtPlAm"  ,0,3,,,,,, lPageAction},;  //"Incluir"
					 {OemToAnsi(STR0004),"Q331AtPlAm"  ,0,6},;  //"Alterar"
					 {OemToAnsi(STR0005),"Q331AtPlAm"  ,0,5,3},; //"Excluir"
					 {OemToAnsi(STR0012),"Q331Dupli"   ,0,5}}    //"Duplicacao"
					 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("Q331MENU")
	aRotAdic := ExecBlock("Q331MENU", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf
					 
Return aRotina

Function QIEA331()  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do Browse  										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0006) //"Plano de Amostragem por Ensaios"         

Private Inclui := .F.
Private Altera := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ 1 - Nome a aparecer no cabecalho                             ³
//³ 2 - Nome da Rotina associada                                 ³
//³ 3 - Usado pela rotina                                        ³
//³ 4 - Tipo de Transa‡„o a ser efetuada                         ³
//³    1) Pesquisa e Posiciona em um Banco de Dados              ³
//³    2) Simplesmente Mostra os Campos                          ³
//³    3) Inclui registros no Bancos de Dados                    ³
//³    4) Altera o registro corrente                             ³
//³    5) Remove o registro corrente do Banco de Dados           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oQf4Browse
Private aRotina := MenuDef()

dbSelectArea("QF4") 

oQf4Browse:=FWMBrowse():New()
oQf4Browse:SetDescription(cCadastro)
oQf4Browse:SetAlias('QF4')
If hasSmartX()
    oQf4Browse:setSmartX(0,.F.)
EndIf
oQf4Browse:Activate()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q331AtPlAm³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualizacao do Plano de Amostragens vinculados a Fornecedo-³±±
±±³			 ³ res.														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q331AtPlAm(EXPC1,EXPN1,EXPN2)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo									  ³±±
±±³			 ³ EXPN1 = Numero do registro 								  ³±±
±±³			 ³ EXPN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q331AtPlAm(cAlias,nReg,nOpc)
Local nOpcA    	:= 0
Local nSavRot  	:= 0
Local nIniCol  	:= 0
Local lDelete  	:= If(nOpc==2 .Or. nOpc==5,.F.,.T.)
Local lQ331QF4 	:= ExistBlock("Q331QF4")            
Local aAreaAnt 	:= GetArea()
Local aCpoQF4  	:= {}
Local oDlg
Local oEnchoice
Local oSize 

Private aTela    	 := {}
Private aGets    	 := {}                                           
Private aHeader  	 := {}   
Private aHeaderAux := {}
Private aCols    	 := {}
Private N        	 := 1
Private aColsAux 	 := {}
Private nUsado   	 := 0                     
Private oGetPAE  

Private cProduto   := ""   
Private cRevi      := ""
Private lPlano     := .F. //Indica se o campo Plano de Amostragem sera editado
Private lNivel     := .F. //Indica se o campo Nivel do Plano sera editado
Private lNQA       := .T. //Indica se o campo NQA sera editado
Private lTipAmo    := .T. //Indica se o campo Tipo do Plano de Amostragem sera editado
Private lDesPlaTxt := .F. //Indica se o campo Descricao do Plano sera editado

Private cEnsRev    := "ß" //Obsoleto, apenas para compatibilizar a consulta SXB Q78
Private nPosLab    := 0
Private nPosSeq    := 0
Private nPosEns    := 0
Private nPosTPA    := 0
Private nPosPla    := 0
Private nPosNiv    := 0
Private nPosNQA    := 0
Private nPosNonEns := 0
Private nPosDescri := 0

Private aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos a serem editados na Enchoice							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCpoEnc  := {} 

//Define as coordenadas da Tela
Private aSize	 := {}

aSize	:= MsAdvSize(,.F.,400)

Aadd(aCpoEnc,'QF4_FORNEC')
Aadd(aCpoEnc,'QF4_LOJFOR')
Aadd(aCpoEnc,'QF4_DESFOR')
Aadd(aCpoEnc,'QF4_PRODUT')
Aadd(aCpoEnc,'QF4_REVI')
Aadd(aCpoEnc,'QF4_DESPRO')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para inclusao de novos campos na Enchoice   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQ331QF4
	aCpoQF4 := ExecBlock("Q331QF4",.F.,.F.)
	Aeval(aCpoQF4,{|x|Aadd(aCpoEnc,AllTrim(x))})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as variaveis para edicao na enchoice					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QF4",If(nOpc==3,.T.,.F.),.T.)            


cWhile  := RetSIX("QF4","1",.T.)
cSeek 	:= RetSIX("QF4","1",.T.)
aNoFields := {	"QF4_FILIAL", "QF4_FORNEC", "QF4_LOJFOR", "QF4_DESFOR",;
				"QF4_PRODUT", "QF4_REVI"  , "QF4_DESPRO", "QF4_PA"    }

Aadd(aHeaderAux, Q331GetSX3("QE7_LABOR", "V"))
Aadd(aHeaderAux, Q331GetSX3("QE7_SEQLAB", "V"))

FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QF4",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpc == 3),"",&cSeek),;  	// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 					// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  					// uSeekFor
               	aNoFields,;  					// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usuário;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpc == 3),.T.,.F.),;  	// lEmpty 
               	aHeaderAux,; 					// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry
                                                              
nPosLab    := Ascan(aHeader,{|x|AllTrim(x[2])=="QE7_LABOR"})
nPosSeq    := Ascan(aHeader,{|x|AllTrim(x[2])=="QE7_SEQLAB"})                            
nPosEns    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF4_ENSAIO"})
nPosTPA    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF4_TIPAMO"})
nPosPla    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF4_PLAMO"})
nPosNiv    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF4_NIVEL"})
nPosNQA    := Ascan(aHeader,{|x|AllTrim(x[2])=="QF4_NQA"})
nPosNonEns := Ascan(aHeader,{|x|AllTrim(x[2])=="QF4_DESENS"})
nPosDescri := Ascan(aHeader,{|x|AllTrim(x[2])=="QF4_DESCRI"})

aCols := {}
Q331FilCol(cAlias,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum Plano associado a Entrada, antes da ³
//³ Alteracao ou Exclusao.										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc==4) .Or. (nOpc==5)
	For nIniCol := 1 to Len(aCols)
		QF5->(dbSetOrder(3))
		If QF5->(MsSeek(xFilial('QF5')+M->QF4_FORNEC+M->QF4_LOJFOR+M->QF4_PRODUT+M->QF4_REVI+aCols[nIniCol,nPosEns]+"B")) .Or. ;
			QF5->(MsSeek(xFilial('QF5')+M->QF4_FORNEC+M->QF4_LOJFOR+M->QF4_PRODUT+M->QF4_REVI+aCols[nIniCol,nPosEns]+"D")) .Or. ;
			QF5->(MsSeek(xFilial('QF5')+M->QF4_FORNEC+M->QF4_LOJFOR+M->QF4_PRODUT+M->QF4_REVI+aCols[nIniCol,nPosEns]+"N"))
	    	Help(" ",1,"Q331EXIENS") //"Existe(m) Entrada(s) dadastrada(s), com Plano(s) definido(s) nesta Revisao"
	    	RestArea(aAreaAnt)
		    Return(NIL)
		EndIf    	
	Next nIniCol
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a opcao do aRotina Inclusao							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	nSavRot     := aRotina[3,4] //Inclusao
	aRotina[3,4]:= 6	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia a Validacao dos Ensaios validos quando nao for inclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 3
	Q331IniEsp()
EndIf
                                            
//Ordena o aCols por Laboratorio+Sequencia
aSort(aCols,,,{|x,y| x[nPosLab]+x[nPosSeq]<y[nPosLab]+y[nPosSeq]})
                
Aadd(aButtons,{"BMPINCLUIR",{||Q331AtuPla()},OemToAnsi(STR0007),STR0011}) //"Atualizacao Automatica do Plano de Amostragem..."###"Atual.PA"

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],000 To aSize[6],aSize[5] OF oMainWnd Pixel	  	
oSize := FwDefSize():New(.T.,,,oDlg)

oSize:AddObject('HEADER',100,70,.T.,.F.)
oSize:AddObject('GRID'  ,100,10,.T.,.T.)

oSize:aMargins 	:= { 3, 3, 3, 3 }
oSize:Process()

oEnchoice := Msmget():New(cAlias,nReg,nOpc,,,,aCpoEnc,{oSize:GetDimension('HEADER','LININI'),oSize:GetDimension('HEADER','COLINI'),oSize:GetDimension('HEADER','LINEND'),oSize:GetDimension('HEADER','COLEND')},,3,,,,,,)


oGetPAE := MSGetDados():New(oSize:GetDimension('GRID','LININI'),oSize:GetDimension('GRID','COLINI'),oSize:GetDimension('GRID','LINEND'),oSize:GetDimension('GRID','COLEND'),nOpc,"Q331LinOk","Q331TudOk","",lDelete,,,.F.,,,,,If(lDelete,"Q331VlDel",),oDlg)
oGetPAE:oBrowse:bChange := {||lDesPlaTxt:= If(!Empty(aCols[oGetPAE:oBrowse:nAt,nPosTPA]) .And. aCols[oGetPAE:oBrowse:nAt,nPosTPA] == "4",.T.,.F.)}


oGetPAE:aInfo[nPosLab,5]:='V' //forca o modo de visualizacao do Laboratorio
oGetPAE:aInfo[nPosSeq,5]:='V' //forca o modo de visualizacao da Sequencia do Laboratorio

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nOpcA :=1,If(oGetPAE:TudoOk(),;
	If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA:=0)},{||oDlg:End()},,aButtons))

//Realiza a gravacao dos dados
If (nOpcA==1) .And. (nOpc#2)
	Q331GrvAll(nOpc,aCpoQF4)
EndIf                       

//Restaura a opcao do aRotina Inclusao
If nOpc == 3
	aRotina[3,4] := nSavRot
EndIf                       
      
RestArea(aAreaAnt)

Return(NIL)                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q331FilCol³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q331FilCol(EXPN1,EXPL1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias 											  ³±±
±±³			 ³ EXPL1 = Indica se o aHeader foi definido		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA2 = Estrutura do aCols								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q331FilCol(cAlias,lHeader)
Local nIteCol  := 0
Local aAreaQF4 := QF4->(GetArea())
Local aAreaQE6 := QE6->(GetArea())
Local aAreaQE7 := QE7->(GetArea())
Local aAreaQE8 := QE8->(GetArea())
Local cKeyQF4  := ""
Local nCpo     := 0
Local nEns     := 0
Local nNiv     := 0
Local nUsado   := Len(aHeader) 

nEns := Ascan(aHeader,{|x|AllTrim(x[2])=="QF4_ENSAIO"})
nNiv := Ascan(aHeader,{|x|AllTrim(x[2])=="QF4_NIVEL"})
N    := 1 
aCols:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a opcao seja diferente de Inclusao, preenche o aCols com³
//³ os Planos ja associados aos Ensaios.						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cKeyQF4 := M->QF4_FORNEC+M->QF4_LOJFOR+M->QF4_PRODUT+M->QF4_REVI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os ensaios mensuraveis de acordo com a revisao	atual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE7->(dbSetOrder(1))
QE7->(MsSeek(xFilial("QE7")+M->QF4_PRODUT+M->QF4_REVI))
While QE7->(!Eof()) .And. QE7->QE7_FILIAL == xFilial("QE7") .And.;  
	(QE7->QE7_PRODUT+QE7->QE7_REVI) == (M->QF4_PRODUT+M->QF4_REVI)
		
	cEnsRev+=QE7->QE7_ENSAIO+"ß"     
		
	Aadd(aCols,Array(nUsado+1))
		
	QF4->(dbSetOrder(1))
	QF4->(MsSeek(xFilial("QF4")+cKeyQF4+QE7->QE7_ENSAIO))
	For nCpo := 1 to Len(aHeader)
		If aHeader[nCpo,10] # "V"          
			If QF4->(!Eof())		
			    aCols[Len(aCols),nCpo] := QF4->(FieldGet(FieldPos(aHeader[nCpo,2])))
			Else                                                                    
				If AllTrim(aHeader[nCpo,2]) == "QF4_ENSAIO"
					aCols[Len(aCols),nCpo] := QE7->QE7_ENSAIO
				Else	
					aCols[Len(aCols),nCpo] := CriaVar(aHeader[nCpo,2])				    
				EndIf	
			EndIf    
		Else                                                                      
			If AllTrim(aHeader[nCpo,2]) == "QE7_LABOR"
				aCols[Len(aCols),nCpo] := QE7->QE7_LABOR
			ElseIf AllTrim(aHeader[nCpo,2]) == "QE7_SEQLAB"
				aCols[Len(aCols),nCpo] := QE7->QE7_SEQLAB
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF4_DESENS"    
			    aCols[Len(aCols),nCpo] := Posicione("QE1",1,xFilial("QE1")+aCols[Len(aCols),nEns],"QE1_DESCPO")
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF4_DESCRI"
				aCols[Len(aCols),nCpo] := Posicione("QQB",2,xFilial("QQB")+QA_Plano(aCols[Len(aCols),nPosTPA])+aCols[Len(aCols),nPosNiv],"QQB_DESCRI")
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF4_ALI_WT" .OR. AllTrim(aHeader[nCpo,2]) == "QF4_REC_WT"
				If QF4->(!Eof())		
					If AllTrim(aHeader[nCpo,2]) == "QF4_ALI_WT"
						aCols[Len(aCols),nCpo] := "QF4"
					ElseIf IsHeadRec(aHeader[nCpo,2])
						aCols[Len(aCols),nCpo] := IIf(lQuery,QF4->QF4RECNO,QF4->(RecNo()))
					EndIf                                        
				Else
					If AllTrim(aHeader[nCpo,2]) == "QF4_ALI_WT"
						aCols[Len(aCols),nCpo] := "QF4"
					ElseIf AllTrim(aHeader[nCpo,2]) == "QF4_REC_WT" 
						aCols[Len(aCols),nCpo] := 0
					EndIf
				EndIf
			Else
				aCols[Len(aCols),nCpo] := CriaVar(aHeader[nCpo,2])
			EndIf
		EndIf				    
	Next nCpo 		
	aCols[Len(aCols),nUsado+1] := .F.

	QE7->(dbSkip())	
	
EndDo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os ensaios textos de acordo com a revisao atual	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE8->(dbSetOrder(1))
QE8->(MsSeek(xFilial("QE8")+M->QF4_PRODUT+M->QF4_REVI))
While QE8->(!Eof()) .And. QE8->QE8_FILIAL == xFilial("QE8") .And.;  
	(QE8->QE8_PRODUT+QE8->QE8_REVI) == (M->QF4_PRODUT+M->QF4_REVI)  
		
	cEnsRev+=QE8->QE8_ENSAIO+"ß"

	Aadd(aCols,Array(nUsado+1))
		
	QF4->(dbSetOrder(1))
	QF4->(MsSeek(xFilial("QF4")+cKeyQF4+QE8->QE8_ENSAIO))
	For nCpo := 1 to Len(aHeader)
		If aHeader[nCpo,10] # "V"                          
			If !QF4->(Eof())
		    	aCols[Len(aCols),nCpo] := QF4->(FieldGet(FieldPos(aHeader[nCpo,2])))
		    Else 
				If AllTrim(aHeader[nCpo,2]) == "QF4_ENSAIO"
					aCols[Len(aCols),nCpo] := QE8->QE8_ENSAIO
				Else	
					aCols[Len(aCols),nCpo] := CriaVar(aHeader[nCpo,2])				    
				EndIf	
		    EndIf	
		Else                                                                      
			If AllTrim(aHeader[nCpo,2]) == "QE7_LABOR"
				aCols[Len(aCols),nCpo] := QE8->QE8_LABOR
			ElseIf AllTrim(aHeader[nCpo,2]) == "QE7_SEQLAB"
				aCols[Len(aCols),nCpo] := QE8->QE8_SEQLAB
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF4_DESENS"    
			    aCols[Len(aCols),nCpo] := Posicione("QE1",1,xFilial("QE1")+aCols[Len(aCols),nEns],"QE1_DESCPO")
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF4_DESCRI"
				aCols[Len(aCols),nCpo] := Posicione("QQB",2,xFilial("QQB")+QA_Plano(aCols[Len(aCols),nPosTPA])+aCols[Len(aCols),nPosNiv],"QQB_DESCRI")
			ElseIf AllTrim(aHeader[nCpo,2]) == "QF4_ALI_WT" .OR. AllTrim(aHeader[nCpo,2]) == "QF4_REC_WT"
				If QF4->(!Eof())		
					If AllTrim(aHeader[nCpo,2]) == "QF4_ALI_WT"
						aCols[Len(aCols),nCpo] := "QF4"
					ElseIf IsHeadRec(aHeader[nCpo,2])
						aCols[Len(aCols),nCpo] := IIf(lQuery,QF4->QF4RECNO,QF4->(RecNo()))
					EndIf                                        
				Else
					If AllTrim(aHeader[nCpo,2]) == "QF4_ALI_WT"
						aCols[Len(aCols),nCpo] := "QF4"
					ElseIf AllTrim(aHeader[nCpo,2]) == "QF4_REC_WT" 
						aCols[Len(aCols),nCpo] := 0
					EndIf
				EndIf
			Else
				aCols[Len(aCols),nCpo] := CriaVar(aHeader[nCpo,2])
			EndIf
		EndIf				    
	Next nCpo 		
	aCols[Len(aCols),nUsado+1] := .F.

	QE8->(dbSkip())	
		
EndDo	
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria uma dimensao vazia no aCols,caso nao haja especificacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) == 0
	Aadd(aCols,Array(nUsado+1))
	For nIteCol = 1 To Len(aHeader)
		If aHeader[nIteCol,8] == "C"
			aCols[1,nIteCol] := Space(aHeader[nIteCol,4])
		ElseIf aHeader[nIteCol,8] == "N"
			aCols[1,nIteCol] := 0
		ElseIf aHeader[nIteCol,8] == "D"
			aCols[1,nIteCol] := dDataBase
		ElseIf aHeader[nIteCol,8] == "M"
			aCols[1,nIteCol] := ""
		EndIf
    Next nIteCol
	aCols[1,nUsado+1] := .F.
EndIf 
            
RestArea(aAreaQF4)
RestArea(aAreaQE6)
RestArea(aAreaQE7)
RestArea(aAreaQE8)

Return(aCols)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q331GrvAll³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q331GrvAll(nOpc,aCpoQF4)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±³			 ³ EXPA1 = Campos utilizados na Enchoice					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q331GrvAll(nOpc,aCpoQF4)   
Local nIteCol   := 0
Local nCpoQF4   := 0
Local lAddRec 
Local nPosDel   := 0        
Local cSeekQF4  := ""
Local lAtualiza
Local lQ331Grv := ExistBlock("Q331Grv")    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a manutencao nos registros do Plano de Amostragem por³
//³ Ensaios.													 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nIteCol := 1 to Len(aCols)
	        
    If Empty(aCols[nIteCol,nPosEns]) .Or. Empty(aCols[nIteCol,nPosTPA])
    	lAtualiza := .F.
    Else	
        lAtualiza := .T.
    EndIf

	If lAtualiza	                    
	
	    If nOpc == 5
			cSeekQF4 := QF4->(QF4_FORNEC+QF4_LOJFOR+QF4_PRODUT+QF4_REVI+aCols[nIteCol,nPosEns])
	    Else
			cSeekQF4 := M->QF4_FORNEC+M->QF4_LOJFOR+M->QF4_PRODUT+M->QF4_REVI+aCols[nIteCol,nPosEns]
		EndIf	
			
		nPosDel := Len(aCols[nIteCol])
		lAddRec := .F.  
			
		If nOpc == 3
			lAddRec := .T.
		Else
			QF4->(dbSetorder(1))
			If QF4->(!dbSeek(xFilial("QF4")+cSeekQF4))
				lAddRec := .T.
		    EndIf
		EndIf

		If !(lAddRec .And. aCols[nIteCol,nPosDel])
			RecLock("QF4",lAddRec) 
		EndIf	                         
			
		If aCols[nIteCol,nPosDel] .Or. (nOpc == 5)
			If !lAddRec
				QF4->(dbDelete())
			EndIf
		Else
			//Grava os campos editados na enchoice
			QF4->QF4_FILIAL := xFilial("QF4")
			QF4->QF4_FORNEC := M->QF4_FORNEC
			QF4->QF4_LOJFOR := M->QF4_LOJFOR
			QF4->QF4_PRODUT := M->QF4_PRODUT
			QF4->QF4_REVI   := M->QF4_REVI  
					     
			//Grava os campos definidos atraves do ponto de Entrada Q331QF4	
			If Len(aCpoQF4) > 0
				For nCpoQF4 := 1 to Len(aCpoQF4)
					FieldPut(FieldPos(AllTrim(aCpoQF4[nCpoQF4])),M->&(aCpoQF4[nCpoQF4]))
				Next nCpoQF4
			EndIf
				
			For nCpoQF4 := 1 to Len(aHeader)
				If aHeader[nCpoQF4,10] # "V"                                                 
					FieldPut(FieldPos(AllTrim(aHeader[nCpoQF4,2])),aCols[nIteCol,nCpoQF4])
				EndIf	
			Next nCpoQF4
					
		EndIf
		MsUnLock()
		
		//Atualiza QE7/QE8
		dbSelectArea("QE7")
		dbSetOrder(1)
		If dbSeek(xFilial("QE7")+QF4->QF4_PRODUT+QF4->QF4_REVI+QF4->QF4_ENSAIO)
			RecLock("QE7",.f.)
			QE7->QE7_PLAMO := QF4->QF4_PLAMO                          
		    MsUnlock()
		Else 
			dbSelectArea("QE8")
			dbSetOrder(1)
			If dbSeek(xFilial("QE8")+QF4->QF4_PRODUT+QF4->QF4_REVI+QF4->QF4_ENSAIO)
				RecLock("QE8",.f.)
				QE8->QE8_PLAMO := QF4->QF4_PLAMO                          
			    MsUnlock()
			EndIF
		EndIF
			
	EndIf
		
Next nIteCol

If lQ331Grv
	ExecBlock("Q331Grv",.F.,.F., {aHeader, aCols, nOpc})
EndIF

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331IniEsp³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicia as validacoes dos Ensaios validos na revisao do pro-³±±
±±³ 		 ³ duto.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331IniEsp()
Local lRetorno := .T.
                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a validacao dos ensaios, caso haja alteracao na revi- ³
//³ sao do produto a serem associados os planos de amostragem.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->QF4_PRODUT) .And. !Empty(M->QF4_REVI)

	If (cProduto # M->QF4_PRODUT) .Or. (cRevi # M->QF4_REVI)  
	                                                             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe o aCols vazio, caso a revisao do produto seja alterada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oGetPAE # NIL
			oGetPAE:oBrowse:lDisablePaint := .T.
			aCols := aClone(aColsAux)
			N     := 1
			oGetPAE:oBrowse:lDisablePaint := .F.
		EndIf
					
		//Armazena a Revisao alterada
		cProduto := M->QF4_PRODUT
		cRevi    := M->QF4_REVI     
			
	EndIf                                                      
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331VldPAE³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza as validacoes do Plano de Amostragem por Ensaios   ³±±
±±³ 		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331VldPAE()
Local lRetorno := .T.
Local aAreaAnt := GetArea()
Local aAreaSA5 := SA5->(GetArea())

If !Empty(M->QF4_FORNEC) .And. !Empty(M->QF4_LOJFOR) .And. !Empty(M->QF4_PRODUT)
    
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+M->QF4_FORNEC+M->QF4_LOJFOR))
		If SA2->A2_MSBLQL == "1" // Fornecedor / Loja bloqueado
			Help(" ",1,"REGBLOQ")
			lRetorno := .f.
		Endif
	Else
		Help(" ",1,"REGNOIS") // Fornecedor / Loja nao encontrado
	Endif

	If lRetorno
		SA5->(dbSetOrder(1))
		If SA5->(!dbSeek(xFilial("SA5")+M->QF4_FORNEC+M->QF4_LOJFOR+M->QF4_PRODUT))
			Help(" ",1,"Q331NOFOR")
			lRetorno := .F.
		Else	
			If !Empty(M->QF4_REVI)
				QF4->(dbSetOrder(1))
				If QF4->(dbSeek(xFilial("QF4")+M->QF4_FORNEC+M->QF4_LOJFOR+M->QF4_PRODUT+M->QF4_REVI))
			         Help("",1,"Q331JAPLAN")
			         lRetorno := .F.
			    EndIf
			EndIf
		EndIf
	
	EndIf                   
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prenche o aCols de acordo com o Fornecedor x Produto+Revisao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Inclui .And. lRetorno

	Q331FilCol("QF4",.F.)
	oGetPAE:oBrowse:Refresh(.T.)               
	
EndIf
	
RestArea(aAreaSA5)
RestArea(aAreaAnt)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331VldEns³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do Ensaio digitado.					  ³±±
±±³ 		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331VldEns()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331VldTPA³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do Tipo do Plano de Amostragem selecio-³±±
±±³ 		 ³ nado.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331VldTPA()
Local cCarta   := " "

If lTipAmo                                        

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Tipo da Carta associada ao Ensaio 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (M->QF4_TIPAMO == "5") //NBR5429
		If !Empty(aCols[N,nPosEns])
			cCarta := QA_CartEns(aCols[N,nPosEns]) 
			If Alltrim(cCarta)$("TXT/U/P")	
				Help(" ",1,"Q331CARINV",,,1)
				Return(.F.)
			EndIf	
		EndIf	
	EndIf

	//Zera os campos referentes ao Plano utilizado
	aCols[N,nPosPla]   := Space(TamSX3("QF4_PLAMO")[1])
	aCols[N,nPosNiv]   := Space(TamSX3("QF4_NIVEL")[1])
	aCols[N,nPosNQA]   := Space(TamSX3("QF4_NQA")[1])    
	aCols[N,nPosDescri]:= Space(TamSX3("QF4_DESCRI")[1])
	
	If (M->QF4_TIPAMO == "1") //NBR5426
		lPlano     := If(lPlano,lPlano,.T.)
		lNivel     := If(lNivel,lNivel,.T.)
		lNQA       := If(lNQA,lNQA,.T.)      
		lDesPlaTxt := If(!lDesPlatxt,lDesPlaTxt,.F.)
		
	ElseIf (M->QF4_TIPAMO == "2") //QS9000 
		lPlano     := If(!lPlano,lPlano,.F.)
		lNivel     := If(!lNivel,lNivel,.F.)
		lNQA       := If(lNQA,lNQA,.T.)                          
		lDesPlaTxt := If(!lDesPlaTxt,lDesPlaTxt,.F.)
	
		aCols[N,nPosPla]    := "QS" //Sugere o Plano como QS9000 para a Tabela Zero Defeito
		aCols[N,nPosNiv]    := "01" //Nivel utilizado na QS9000
		aCols[N,nPosNQA]    := Space(TamSX3("QF4_NQA")[1])    
		aCols[N,nPosDescri] := Tabela("QI",QA_Plano(M->QF4_TIPAMO,.F.))
	
	ElseIf (M->QF4_TIPAMO == "3") //Interno
		lPlano     := If(!lPlano,lPlano,.F.)
		lNivel     := If(lNivel,lNivel,.T.)
		lNQA       := If(!lNQA,lNQA,.F.)  
		lDesPlaTxt := If(!lDesPlaTxt,lDesPlaTxt,.F.)

	ElseIf (M->QF4_TIPAMO == "4") //Texto	
		lPlano     := If(!lPlano,lPlano,.F.)
		lNivel     := If(!lNivel,lNivel,.F.)
		lNQA       := If(lNQA,lNQA,.T.)  
		lDesPlaTxt := If(lDesPlaTxt,lDesPlaTxt,.T.)
		
		aCols[N,nPosPla] := "TX" //Sugere a sigla no Plano TX para indicar o tipo Texto
		aCols[N,nPosNiv] := "01" //Sugere o Nivel utilizado no Plano do Tipo Texto

	ElseIf (M->QF4_TIPAMO == "5") //NBR5429
		lPlano     := If(lPlano,lPlano,.T.)
		lNivel     := If(lNivel,lNivel,.T.)
		lNQA       := If(lNQA,lNQA,.T.)      
		lDesPlaTxt := If(!lDesPlatxt,lDesPlaTxt,.F.)
		
	EndIf	
EndIf

Return(.T.)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331VldPlA³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do Plano de Amostragem selecionado.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331VldPlA()
Local lRetorno := .T.
Local cPlaAmo  := " "                  
Local cSeekTab := " "                  

cPlaAmo  := &(ReadVar()) 
cSeekTab := If(M->QF4_TIPAMO=='5',"QJ","Q5")
lRetorno := ExistCpo("SX5",cSeekTab+cPlaAmo)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331VldNQA³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do NQA selecionado.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331VldNQA()
Local lRetorno := .T.
Local cNivPla
Local cTabF3   := " "

cNivPla  := &(ReadVar()) 
cTabF3   := If(aCols[N,nPosTPA]=="5","Q0","Q1")
lRetorno := ExistCpo("SX5",cTabF3+cNivPla)

Return(lRetorno)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331VldNiv³ Autor ³Paulo Emidio de Barros ³ Data ³17/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao do Nivel do Plano de Amostragem.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331VldNiv()
Local lRetorno  := .F. 
Local cNiv      := &(ReadVar())      

QQB->(dbSetOrder(1))
If NaoVazio(cNiv) .And. ExistCpo("QQB")    
	lRetorno := .T.
EndIf
	
If lRetorno	
	If aCols[N,nPosTPA] == "3" //Plano Interno
		aCols[N,nPosPla] := "PI" //Plano de Amostragem Interno
		aCols[N,nPosNQA] := ("ESP"+cNiv) 
	EndIf
	
	If (aCols[N,nPosTPA] == "1") .Or. (aCols[N,nPosTPA] == "3") .Or. (aCols[N,nPosTPA] == "5") 
		QQB->(dbSetOrder(2))                         
		If QQB->(dbSeek(xFilial("QQB")+QA_Plano(M->QF4_TIPAMO)+cNiv))
			aCols[N,nPosDescri] := QQB->QQB_DESCRI 
		Else	                                  
			aCols[N,nPosDescri] := Space(TamSX3("QQB_DESCRI")[1])
		EndIf                     
	EndIf
EndIf

Return(lRetorno) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331WhnEns³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o campo Ensaio sera editado na Alteracao dos   ³±±
±±³			 ³ Planos associados aos Ensaios.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331WhnEns()  
Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331LinOK ³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao dos Ensaios digitados na Getdados	  ³±±
±±³ 		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331LinOk()
Local lRetorno   := .T.
Local nPosDel    := Len(aCols[N])
Local aPlanos    := {"01","02","03","S1","S2","S3","S4"}
Local nPosPlAm    := 0

If !aCols[N,nPosDel]

	If lRetorno 
		nPosPlAm := Ascan(aPlanos,{|x|x==aCols[N,nPosNiv]})
		If aCols[N,nPosTPA] == "1"
			If Empty(aCols[N,nPosPla]) .Or. Empty(aCols[N,nPosNiv]) .Or.;
				Empty(aCols[N,nPosNQA]) .Or. (nPosPlAm == 0) .Or. (SubStr(aCols[N,nPosNQA],1,3) == "ESP")
				lRetorno := .F.
		    EndIf      

		ElseIf aCols[N,nPosTPA] == "2"    
			If Empty(aCols[N,nPosNQA]) .Or. (SubStr(aCols[N,nPosNQA],1,3) == "ESP")			
				lRetorno := .F.
			EndIf	

		ElseIf aCols[N,nPosTPA] == "3"
			If Empty(aCols[N,nPosNiv]) .Or. Empty(aCols[N,nPosNQA]) .Or. (SubStr(aCols[N,nPosNQA],1,3) # "ESP")			
				lRetorno := .F.
			EndIf	
		ElseIf aCols[N,nPosTPA] == "4"
			If !(aCols[N,nPosPla]=='TX' .And. aCols[N,nPosNiv]=='01' .And. !Empty(aCols[N,nPosDescri]))
//				!Empty(aCols[N,nPosNQA]) .And. !Empty(aCols[N,nPosDescri]))
				lRetorno := .F.			
            EndIf
		EndIf
	EndIf
	
EndIf

If !lRetorno
    Help("",1,"Q331NAOPLA")
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331TudOK ³ Autor ³Paulo Emidio de Barros ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a validacao dos Ensaios digitados apos a confirma- ³±±
±±³ 		 ³ cao na GetDados.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331TudOk()
Local lRetorno   := .T.
Local nPosDel    := 0
Local nLinCol    := 0
Local aPlanos    := {"01","02","03","S1","S2","S3","S4"}
Local nPosPlAm    := 0

For nLinCol := 1 to Len(aCols)

	nPosDel := Len(aCols[nLinCol])
	
	If !aCols[nLinCol,nPosDel]
	
		nPosPlAm := Ascan(aPlanos,{|x|x==aCols[nLinCol,nPosNiv]})
	
		If aCols[nLinCol,nPosTPA] == "1"
			If Empty(aCols[nLinCol,nPosPla]) .Or. Empty(aCols[nLinCol,nPosNiv]) .Or.;
				Empty(aCols[nLinCol,nPosNQA]) .Or. (nPosPlAm == 0) .Or. (SubStr(aCols[nLinCol,nPosNQA],1,3) == "ESP")
				lRetorno := .F.
				Exit
		    EndIf

		ElseIf aCols[nLinCol,nPosTPA] == "2" 
			If Empty(aCols[nLinCol,nPosNQA]) .Or. (SubStr(aCols[nLinCol,nPosNQA],1,3) == "ESP")
				lRetorno := .F.
				Exit
			EndIf	

		ElseIf aCols[nLinCol,nPosTPA] == "3" 
			If Empty(aCols[nLinCol,nPosNiv]) .Or. Empty(aCols[nLinCol,nPosNQA]) .Or. (SubStr(aCols[nLinCol,nPosNQA],1,3) # "ESP")			
				lRetorno := .F.  
				Exit
			EndIf	
			
		ElseIf aCols[nLinCol,nPosTPA] == "4"
			If !(aCols[nLinCol,nPosPla]=='TX' .And. aCols[nLinCol,nPosNiv]=='01' .And.  !Empty(aCols[nLinCol,nPosDescri]))
//				!Empty(aCols[nLinCol,nPosNQA]) .And. !Empty(aCols[nLinCol,nPosDescri]))
				lRetorno := .F.
				Exit			
            EndIf

		EndIf  
	EndIf
Next nLinCol          

If !lRetorno 
	Help("",1,"Q331NAOPLA")
EndIf

Return(lRetorno)          

//Compatibiliza a chamada nas funcoes anteriores
Function QIEA330()
QIEA331()
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331AtuPla³ Autor ³Paulo Emidio de Barros ³ Data ³04/12/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os demais ensaios com o Plano de Amostragem suge- ³±±
±±³ 		 ³ rido na linha corrente da GetDados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Static Function Q331AtuPla()
Local nLinCol
Local aAreaQE6 := QE6->(GetArea())
Local aAreaQE7 := QE7->(GetArea())
Local aAreaQE8 := QE8->(GetArea())
Local cCarta   := ""
           
//Verifica se a Especificacao do Produto esta preenchida           
If Empty(M->QF4_PRODUT) .Or. Empty(M->QF4_REVI)          
	Help(" ",1,"Q331NOREVI") //"Nao foi informado a Especificacao do Produto"
	Return(NIL)
EndIf

If !Empty(aCols[oGetPAE:oBrowse:nAt,nPosEns]) .And.;  //Ensaio
	!Empty(aCols[oGetPAE:oBrowse:nAt,nPosTPA]) .And.; //Tipo 
	!Empty(aCols[oGetPAE:oBrowse:nAt,nPosPla]) .And.; //Plano de Amostragem
	!Empty(aCols[oGetPAE:oBrowse:nAt,nPosNiv]) .And.; //Nivel 
	!Empty(aCols[oGetPAE:oBrowse:nAt,nPosNQA])        //NQA

	For nLinCol := 1 to Len(aCols)
		If nLinCol # oGetPAE:oBrowse:nAt   
			cCarta := QA_CartEns(aCols[nLinCol,nPosEns]) 
		
			If aCols[oGetPAE:oBrowse:nAt,nPosTPA]#"5" .or. !(Alltrim(cCarta)$("TXT/U/P"))	
				If Empty(aCols[nLinCol,nPosTPA]) .Or.; //Tipo 
					Empty(aCols[nLinCol,nPosPla]) .Or.; //Plano de Amostragem
					Empty(aCols[nLinCol,nPosNiv]) .Or.; //Nivel 	
					Empty(aCols[nLinCol,nPosNQA])        //NQA
					aCols[nLinCol,nPosTPA]    := aCols[oGetPAE:oBrowse:nAt,nPosTPA]
					aCols[nLinCol,nPosPla]    := aCols[oGetPAE:oBrowse:nAt,nPosPla]
					aCols[nLinCol,nPosNiv]    := aCols[oGetPAE:oBrowse:nAt,nPosNiv]
					aCols[nLinCol,nPosNQA]    := aCols[oGetPAE:oBrowse:nAt,nPosNQA]
					aCols[nLinCol,nPosDescri] := aCols[oGetPAE:oBrowse:nAt,nPosDescri]
				EndIf	
			EndIf
		EndIF	
	Next nLinCol
	
	//Atualiza o browse
	oGetPAE:oBrowse:Refresh()
	
EndIf	
           
RestArea(aAreaQE6)
RestArea(aAreaQE7)
RestArea(aAreaQE8)

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331VlDel ³ Autor ³ Eduardo de Souza      ³ Data ³ 21/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se linha pode ser deletada.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q331VlDel()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q331VlDel()

Local lRet:= .T.

If Empty(Acols[n,nPosTPA]) .And. Empty(Acols[n,nPosPla]) .And. ;
	Empty(Acols[n,nPosNiv]) .And. Empty(Acols[n,nPosNQA])
	lRet:= .F.
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QA331TpAmo³ Autor ³ Marcos Cesar          ³ Data ³01.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o codigo da norma escolhida pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpC1 := QA331TpAmo()                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 = O codigo da Norma.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q331TpAmo()
Local cNorma  := QA_Plano(aCols[N,nPosTPA],.F.)
Return(cNorma)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q33XF3NQA ³ Autor ³Paulo Emidio de Barros ³ Data ³26/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Consulta especifica para o NQA, de acordo com o Plano de   ³±±
±±³			 ³ Amostragem selecionado.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q33XF3NQA()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = Retorno da Consulta padrao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331/QIEA332											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q33XF3NQA()
Local lRetorno := .T.              
Local cTipAmo  := If(AllTrim(FunName())=="QIEA331",M->QF4_TIPAMO,M->QF6_TIPAMO)

If cTipAmo == '5' //NBR5429
	lRetorno := ConPad1(,,,"Q0",,,.F.)
Else
	lRetorno := ConPad1(,,,"Q1",,,.F.)
EndIf 
Return(lRetorno)                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q33XF3PlAm³ Autor ³Paulo Emidio de Barros ³ Data ³26/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Consulta especifica para o tipo de Inspecao de acordo com  ³±±
±±³			 ³ o Plano de Amostragem selecionado.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q33XF3PlAm()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = Retorno da Consulta padrao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331/QIEA332											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q33XF3PlAm()
Local lRetorno := .T.
Local cTipAmo  := If(AllTrim(FunName())=="QIEA331",M->QF4_TIPAMO,M->QF6_TIPAMO)

If cTipAmo == '5' //NBR5429
	lRetorno := ConPad1(,,,"QJ",,,.F.)
Else
	lRetorno := ConPad1(,,,"Q5",,,.F.)
EndIf 
Return(lRetorno)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q331DUPLI   ³ Autor ³ Cleber Souza          ³ data ³13/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Duplicação do Plano de Amostragem.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q331DUPLI()			          						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q331DUPLI() 

Local oDlg         
Local oCodPro
Local oCodFor
Local oLoja
Local oSize
Local aStru      := {}
Local aCpos      := {}
Local oTempTable := NIL 
Local nOpcA      := 0
Local aAreaqf4   := QF4->(GetArea())

Private oMark
Private oGetOri
Private oDesPro 
Private oNomFor 
Private oRevi     
Private cDesPro  := "" 
Private cNomFor  := ""     
Private cCodPro  := QF4->QF4_PRODUT
Private cRevi    := QF4->QF4_REVI
Private cCodFor  := QF4->QF4_FORNEC
Private cLoja    := QF4->QF4_LOJFOR
Private nUsado   := 0                   
Private aHeadOr  := {}
Private aColsOr  := {}
Private lInverte := .F.
Private cMarca    

Q331DFilCol("QF4",.T.) 
Q331DMonTRB(@aStru,@aCpos,@oTempTable,.T.)
cMarca   := GetMark(,"TRB","TB_OK")

oSize := FwDefSize():New() 
                 
oSize:AddObject( "CABECALHO" ,  100, 70, .T.,.F.)
oSize:AddObject( "GETDADOS1" ,  100, 15, .T.,.T.) 
oSize:AddObject( "GETDADOS2" ,  100, 15, .T.,.T.)     
           
oSize:aMargins := { 3, 3, 0, 3 }

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; // "Plano de Amostragem por Ensaio"	 
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
          
@ 038,008 SAY   OemToAnsi(STR0016)    Of oDlg PIXEL //"Produto "
@ 038,145 SAY   OemToAnsi(STR0017)    Of oDlg PIXEL //"Revisao "
@ 051,008 SAY   OemToAnsi(STR0018)    Of oDlg PIXEL //"Desc Prod "
@ 064,008 SAY   OemToAnsi(STR0019)    Of oDlg PIXEL //"Fornecedor "
@ 064,145 SAY   OemToAnsi(STR0020)    Of oDlg PIXEL //"Loja "
@ 077,008 SAY   OemToAnsi(STR0021)    Of oDlg PIXEL //"Nome "           	 

@ 037,040 MSGET oCodPro    VAR cCodPro SIZE 080,8 PIXEL Of oDlg WHEN .F.
@ 037,168 MSGET oRevi      VAR cRevi   SIZE 020,8 PIXEL Of oDlg WHEN .F.  
@ 050,040 MSGET oDesPro    VAR SB1->B1_DESC Picture PesqPict("SB1","B1_DESC ") SIZE 220,8 PIXEL Of oDlg WHEN .F.
@ 063,040 MSGET oCodFor    VAR cCodFor SIZE 050,8 PIXEL Of oDlg WHEN .F. 
@ 063,168 MSGET oLoja      VAR cLoja   SIZE 020,8 PIXEL Of oDlg WHEN .F. 
@ 078,040 MSGET oNomFor    VAR SA2->A2_NOME Picture PesqPict("SA2","A2_NOME")  SIZE 220,8 PIXEL Of oDlg WHEN .F.		

oGetOri := MsNewGetDados():New(oSize:GetDimension("GETDADOS1","LININI"),oSize:GetDimension("GETDADOS1","COLINI"),;
	     							   oSize:GetDimension("GETDADOS1","LINEND"),oSize:GetDimension("GETDADOS1","COLEND"),;
	     							   0,"AllwaysTrue()","AllwaysTrue()","",,,,,,,oDlg,aHeadOr,aColsOr)             
           
oMark := MsSelect():New("TRB","TB_OK",,acpos,lInverte,cMarca,{;
									oSize:GetDimension("GETDADOS2","LININI"),oSize:GetDimension("GETDADOS2","COLINI"),;
									oSize:GetDimension("GETDADOS2","LINEND"),oSize:GetDimension("GETDADOS2","COLEND")})
oMark:oBrowse:lCanAllMark 	:=.T.
oMark:oBrowse:lHasMark		:=.T.
oMark:oBrowse:bAllMark		:= {| | Q331DMarkAll(cMarca,oDlg)}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(Q331DTudOk(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||nOpcA:=0,oDlg:End()}) CENTERED 

If nOpcA == 1
	Q331DGrvAll()
EndIf	

oTempTable:Delete()
RestArea(aAreaqf4)
Return(NIL) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q331DFilCol³ Autor ³Cleber Souza           ³ Data ³13/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q331DFilCol(EXPN1,EXPL1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias 											  ³±±
±±³			 ³ EXPL1 = Indica se o aHeader foi definido		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA2 = Estrutura do aCols								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q331DFilCol(cAlias,lHeader)
Local nIteCol  := 0
Local aAreaQF4 := QF4->(GetArea())
Local aAreaQE6 := QE6->(GetArea())
Local aAreaQE7 := QE7->(GetArea())
Local aAreaQE8 := QE8->(GetArea())
Local cKeyQF4  := ""
Local nCpo     := 0
Local nEns     := 0
Local nNiv     := 0    
Local nFor     := 0    
Local nLoj     := 0     
Local nPro     := 0
Local nX
Local aStruct

//limpa aCols dos resultados anteriores.
aColsOr := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a montagem do aHeadOr								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lHeader

	Aadd(aHeadOr, Q331GetSX3("QE7_LABOR", "V"))
	nUsado++
	Aadd(aHeadOr, Q331GetSX3("QE7_SEQLAB", "V"))
	nUsado++
	
	aStruct := FWFormStruct(3, cAlias)[3] // Busca os campos usados (X3_USADO) da tabela
	For nX := 1 to Len(aStruct)
		If cNivel >= GetSx3Cache(aStruct[nX,1],"X3_NIVEL")
			nUsado++
			Aadd(aHeadOr, Q331GetSX3(aStruct[nX,1]))
		EndIf 
	Next nX
EndIf

nEns := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF4_ENSAIO"})
nNiv := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF4_NIVEL"}) 
nFor := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF4_FORNEC"}) 
nLoj := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF4_LOJFOR"}) 
nPro := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF4_PRODUT"})
nTPA := Ascan(aHeadOr,{|x|AllTrim(x[2])=="QF4_TIPAMO"})
N    := 1 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a opcao seja diferente de Inclusao, preenche o aColsOr com ³
//³ os Planos ja associados aos Ensaios.			     			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cKeyQF4 := cCodFor+cLoja+cCodPro+cRevi

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os ensaios mensuraveis de acordo com a revisao	atual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE7->(dbSetOrder(1))
QE7->(MsSeek(xFilial("QE7")+cCodPro+cRevi))
While QE7->(!Eof()) .And. QE7->QE7_FILIAL == xFilial("QE7") .And.;  
	(QE7->QE7_PRODUT+QE7->QE7_REVI) == (cCodPro+cRevi)
		
	Aadd(aColsOr,Array(nUsado+1))
	QF4->(dbSetOrder(1))
	QF4->(MsSeek(xFilial("QF4")+cKeyQF4+QE7->QE7_ENSAIO))
	For nCpo := 1 to Len(aHeadOr)
		If aHeadOr[nCpo,10] # "V"          
			If QF4->(!Eof())		
			    aColsOr[Len(aColsOr),nCpo] := QF4->(FieldGet(FieldPos(aHeadOr[nCpo,2])))
			Else                                                                    
				If AllTrim(aHeadOr[nCpo,2]) == "QF4_ENSAIO"
					aColsOr[Len(aColsOr),nCpo] := QE7->QE7_ENSAIO
				Else	
					aColsOr[Len(aColsOr),nCpo] := CriaVar(aHeadOr[nCpo,2])				    
				EndIf	
			EndIf    
		Else                                                                      
			If AllTrim(aHeadOr[nCpo,2]) == "QE7_LABOR"
				aColsOr[Len(aColsOr),nCpo] := QE7->QE7_LABOR
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QE7_SEQLAB"
				aColsOr[Len(aColsOr),nCpo] := QE7->QE7_SEQLAB
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF4_DESENS"    
			    aColsOr[Len(aColsOr),nCpo] := Posicione("QE1",1,xFilial("QE1")+aColsOr[Len(aColsOr),nEns],"QE1_DESCPO")
   			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF4_DESCRI"
				aCols[Len(aColsOr),nCpo] := Posicione("QQB",2,xFilial("QQB")+QA_Plano(aColsOr[Len(aColsOr),nTPA]+aColsOr[Len(aColsOr),nNiv]),"QQB_DESCRI")
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF4_DESFOR"
				aColsOr[Len(aColsOr),nCpo] := Posicione("SA2",1,xFilial("SA2")+aColsOr[Len(aColsOr),nFor]+aColsOr[Len(aColsOr),nLoj],"A2_NOME")
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF4_DESPRO"
				aColsOr[Len(aColsOr),nCpo] := Posicione("SB1",1,xFilial("SB1")+aColsOr[Len(aColsOr),nPro],"B1_DESC")
			Else
				aColsOr[Len(aColsOr),nCpo] := CriaVar(aHeadOr[nCpo,2])
			EndIf
		EndIf				    
	Next nCpo 		
	aColsOr[Len(aColsOr),nUsado+1] := .F.

	QE7->(dbSkip())	
	
EndDo
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os ensaios textos de acordo com a revisao atual	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE8->(dbSetOrder(1))
QE8->(MsSeek(xFilial("QE8")+cCodPro+cRevi))
While QE8->(!Eof()) .And. QE8->QE8_FILIAL == xFilial("QE8") .And.;  
	(QE8->QE8_PRODUT+QE8->QE8_REVI) == (cCodPro+cRevi)  
		
	Aadd(aColsOr,Array(nUsado+1))
	QF4->(dbSetOrder(1))
	QF4->(MsSeek(xFilial("QF4")+cKeyQF4+QE8->QE8_ENSAIO))
	For nCpo := 1 to Len(aHeadOr)
		If aHeadOr[nCpo,10] # "V"                          
			If !QF4->(Eof())
		    	aColsOr[Len(aColsOr),nCpo] := QF4->(FieldGet(FieldPos(aHeadOr[nCpo,2])))
		    Else 
				If AllTrim(aHeadOr[nCpo,2]) == "QF4_ENSAIO"
					aColsOr[Len(aColsOr),nCpo] := QE8->QE8_ENSAIO
				Else	
					aColsOr[Len(aColsOr),nCpo] := CriaVar(aHeadOr[nCpo,2])				    
				EndIf	
		    EndIf	
		Else                                                                      
			If AllTrim(aHeadOr[nCpo,2]) == "QE7_LABOR"
				aColsOr[Len(aColsOr),nCpo] := QE8->QE8_LABOR
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QE7_SEQLAB"
				aColsOr[Len(aColsOr),nCpo] := QE8->QE8_SEQLAB
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF4_DESENS"    
			    aColsOr[Len(aColsOr),nCpo] := Posicione("QE1",1,xFilial("QE1")+aColsOr[Len(aColsOr),nEns],"QE1_DESCPO")
   			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF4_DESCRI"
				aCols[Len(aCols),nCpo] := Posicione("QQB",2,xFilial("QQB")+QA_Plano(aColsOr[Len(aColsOr),nTPA]+aColsOr[Len(aColsOr),nNiv]),"QQB_DESCRI")
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF4_DESFOR"
				aColsOr[Len(aColsOr),nCpo] := Posicione("SA2",1,xFilial("SA2")+aColsOr[Len(aColsOr),nFor]+aColsOr[Len(aColsOr),nLoj],"A2_NOME")
			ElseIf AllTrim(aHeadOr[nCpo,2]) == "QF4_DESPRO"
				aColsOr[Len(aColsOr),nCpo] := Posicione("SB1",1,xFilial("SB1")+aColsOr[Len(aColsOr),nPro],"B1_DESC")
			Else
				aColsOr[Len(aColsOr),nCpo] := CriaVar(aHeadOr[nCpo,2])
			EndIf
		EndIf				    
	Next nCpo 		
	aColsOr[Len(aColsOr),nUsado+1] := .F.

	QE8->(dbSkip())	
		
EndDo	
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria uma dimensao vazia no aColsOr,caso nao haja especificacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsOr) == 0
	Aadd(aColsOr,Array(nUsado+1))
	For nIteCol = 1 To Len(aHeadOr)
		If aHeadOr[nIteCol,8] == "C"
			aColsOr[1,nIteCol] := Space(aHeadOr[nIteCol,4])
		ElseIf aHeadOr[nIteCol,8] == "N"
			aColsOr[1,nIteCol] := 0
		ElseIf aHeadOr[nIteCol,8] == "D"
			aColsOr[1,nIteCol] := dDataBase
		ElseIf aHeadOr[nIteCol,8] == "M"
			aColsOr[1,nIteCol] := ""
		EndIf
    Next nIteCol
	aColsOr[1,nUsado+1] := .F.
EndIf 
            
RestArea(aAreaQF4)
RestArea(aAreaQE6)
RestArea(aAreaQE7)
RestArea(aAreaQE8)

Return()	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Q331DMonTRB ³ Autor ³ Cleber Souza       ³ Data ³ 13/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta browse para a escolha dos Fornecedores - MarkBrowse  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q331DMonTRB()				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA331                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Q331DMonTRB(aStru,aCpos,oTempTable,lMonta)

If lMonta

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aStru,{ "TB_OK"     ,	"C",02,0} )
	Aadd( aStru,{ "TB_FORNE"  ,	"C",TamSX3("QF4_FORNEC")[1],0} )
	Aadd( aStru,{ "TB_LOJA"   , "C",TamSX3("QF4_LOJFOR")[1],0} )
	Aadd( aStru,{ "TB_DESCRI" , "C",TamSX3("QF4_DESFOR")[1],0} )

	oTempTable := FWTemporaryTable():New( "TRB" )
	oTempTable:SetFields( aStru )
	oTempTable:AddIndex("indice1", {"TB_FORNE","TB_LOJA"} )
	oTempTable:Create()
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Redefinicao do acpos para utilizar no MarkBrow               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	acpos := { {"TB_OK"		,"",OemToAnsi(STR0023)},; //"OK" 
		  	   {"TB_FORNE"	,"",OemToAnsi(STR0024)},; //"Fornecedor"	 
		  	   {"TB_LOJA"	,"",OemToAnsi(STR0025)},; //"Loja"
			   {"TB_DESCRI"	,"",OemToAnsi(STR0026)}}  //"Descricao" 
EndIF

If !lMonta
	dbSelectArea("TRB")
	dbGoTop()
	While TRB->(!EOF())
		RecLock("TRB",.F.)
		dbDelete()
		MsUnlock()
		TRB->(dbSkip())
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta arquivo temporario dos Fornecedores                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA5->(dbSetOrder(2))
SA5->(dbSeek(xFilial("SA5")+cCodPro))
While !SA5->(Eof()) .And. SA5->A5_FILIAL == xFilial("SA5");
		.And. SA5->A5_PRODUTO == cCodPro
	
	dbSelectArea("QF4")
	dbSetOrder(1)
	If !dbSeek(xFilial("QF4")+SA5->A5_FORNECE+SA5->A5_LOJA+cCodPro+cRevi)
		RecLock("TRB",.T.)
		TRB->TB_FORNE	:= SA5->A5_FORNECE
		TRB->TB_LOJA 	:= SA5->A5_LOJA
		TRB->TB_DESCRI  := Posicione("SA2",1,xFilial("SA5")+SA5->A5_FORNECE+SA5->A5_LOJA,"A2_NOME")
		MsUnlock()    
    EndIF
    
	SA5->(dbSkip())
EndDo

dbSelectArea("TRB")
dbGoTop()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q331DVPAE³ Autor ³Cleber Souza           ³ Data ³13/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza as validacoes do Plano de Amostragem por Ensaios   ³±±
±±³ 		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA331												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function Q331DVPAE(nOpc)
Local lRetorno := .T.
Local aAreaAnt := GetArea()
Local aAreaSA5 := SA5->(GetArea()) 
Default nOpc   := 0

If !Empty(cCodFor) .And. !Empty(cLoja)
	cNomFor := Posicione("SA2",1,xFilial("SA2")+cCodFor+cLoja,"A2_NOME")
	oNomFor:Refresh()
EndIf

If !Empty(cCodPro) 
	cDesPro := Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_DESC")
	oDesPro:Refresh()
	cRevi   := QA_UltRevEsp(cCodPro,dDataBase,.F.,,"QIE")
	If Empty(cRevi) .And. nOpc == 5
		Help(" ",1,"QA_NREVDIS",,cCodPro,2,1) //O produto nao possui Revisao Disponivel
		lRetorno := .F.
	Endif
	oRevi:Refresh()
EndIf

If !Empty(cCodFor) .And. !Empty(cLoja) .And. !Empty(cCodPro)

	SA5->(dbSetOrder(1))
	If SA5->(!dbSeek(xFilial("SA5")+cCodFor+cLoja+cCodPro))
		Help(" ",1,"Q331NOFOR ")
		lRetorno := .F.
	Else	
		If !Empty(cRevi)
			QF4->(dbSetOrder(1))
			If QF4->(!dbSeek(xFilial("QF4")+cCodFor+cLoja+cCodPro+cRevi))
				 Help(" ",1,"Q331NOPLA")
		         lRetorno := .F.
		    EndIf
		EndIf
	EndIf

	If lRetorno
		
		//Monta aCols com os dados do Plano de Amostragem
		Q331DFilCol("QF4",.F.)
		oGetOri:aCols := aColsOr
		oGetOri:oBrowse:Refresh(.T.)  
				
		//Monta tabela de Fornecedores (temporario)
		Q331DMonTRB(,,,.F.)
		oMark:oBrowse:SetFocus()
		oMark:oBrowse:Refresh(.T.)
		
    EndIF

EndIf

RestArea(aAreaSA5)
RestArea(aAreaAnt) 

Return(lRetorno)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q331DGrvAll³ Autor ³Cleber Souza          ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q331GrvAll()							   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q331DGrvAll()   
Local nIteCol   := 0
Local nCpoQF4   := 0
Local aCols     := oGetOri:aCols
Local aHeader   := oGetOri:aHeader

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a manutencao nos registros do Plano de Amostragem por³
//³ Ensaios.													 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
While TRB->(!EOF())
	If !Empty(TRB->TB_OK)
		For nIteCol := 1 to Len(aCols)

			RecLock("QF4",.T.)
			//Grava os campos editados na enchoice
			QF4->QF4_FILIAL := xFilial("QF4")
			QF4->QF4_FORNEC := TRB->TB_FORNE
			QF4->QF4_LOJFOR := TRB->TB_LOJA
			QF4->QF4_PRODUT := cCodPro
			QF4->QF4_REVI   := cRevi
			
			For nCpoQF4 := 1 to Len(aHeader)
				If aHeader[nCpoQF4,10] # "V" .and. !(Alltrim(aHeader[nCpoQF4,2]) $("QF4_FORNEC,QF4_LOJFOR,QF4_PRODUT,QF4_REVI"))
					FieldPut(FieldPos(AllTrim(aHeader[nCpoQF4,2])),aCols[nIteCol,nCpoQF4])
				EndIf
			Next nCpoQF4
			
			MsUnLock()
		Next nIteCol
	EndIf
	TRB->(dbSkip())
EndDo

Return(NIL)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q331DTudOk³ Autor ³Cleber Souza           ³ Data ³03/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o aHeader e aCols utilizado na edicao do Plano de Amos³±±
±±³			 ³ tragem.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q331DTudOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA331													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q331DTudOk()

Local lRet := .T.

If Empty(cCodFor) .Or. Empty(cLoja) .Or. Empty(cCodPro)
	Help(" ",1,"Q331OBRIG")
	lRet := .F.
EndIF           

Return(lRet) 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Q331DMarkAll  ³ Autor ³ Cleber Souza     ³ Data ³ 08/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe os Ensaios                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA331                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q331DMarkAll(cMarca,oDlg)
LOCAL nRecno:=Recno()
dbGotop()
Do While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock() 
	FKCommit()
	dbSkip()
EndDo
dbGoto(nRecno)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±± Q200FilPro                             18/07/2013 ±±
±± Devolve o filtro com os Produtos por fornecedor  ³±±
±± Uso QIEA331 - X3_F3 do campo QF4_PRODUT          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Q331FilPro()   
Local xRetorno 

If !Empty(M->QF4_FORNEC)
	
	//Posiciona no registro da Amarracao Produto x Fornecedor
	SA5->(dbSetorder(1))
	SA5->(MsSeek(xFilial("SA5")+M->QF4_FORNEC+M->QF4_LOJFOR+QE6->QE6_PRODUT))
	xRetorno := QE6->QE6_FILIAL==xFilial("QE6") .And. QE6->QE6_PRODUT ==SA5->A5_PRODUTO
Else
	xRetorno := .T.
EndIf	

Return(xRetorno)

//----------------------------------------------------------------------
/*/{Protheus.doc} Q215GetSX3 
Busca dados da SX3 
@author Gustavo Della Giustina
@since 12/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q331GetSX3(cCampo, cContext)
Local aHeaderTmp := {}
aHeaderTmp:= {AllTrim(QAGetX3Tit(cCampo)),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_ARQUIVO'),;
              IIF(Empty(cContext), GetSx3Cache(cCampo,'X3_CONTEXT'), cContext)}
Return aHeaderTmp 
