#INCLUDE "QIEA020.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"

// Constantes do aviso
#Define QIEA020_PROG    "QIEA020"       // Chave do programa no FWProfile
#Define QIEA020_TASK    "AVSNOVA020"    // Chave da task (max 10 chars!)
#Define QIEA020_DIAS    7               // Dias para suprimir o aviso

/*/{Protheus.doc} QIEA020AuxClass
Classe agrupadora de métodos auxiliares do QIEA020
@author rafael.kleestadt
@since 13/05/2026
@version P12
/*/
CLASS QIEA020AuxClass FROM LongNameClass

    METHOD new() Constructor

	METHOD verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx()
	METHOD exibeAvisoSubstituicaoPorSmartx()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author rafael.kleestadt
@since 13/05/2026
@version P12
/*/
METHOD new() CLASS QIEA020AuxClass
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIEA020	³ Autor ³ Cleber Souza          ³ Data ³ 28/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Ensaios						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³  			                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEA020()

	Local oQIEA020Aux := Nil

	Private aRotina   := MenuDef()          // Array contendo as Rotinas a executar do programa
	Private cCadastro := OemtoAnsi(STR0006) // "Ensaios"
	Private cEspecie  := "QIEA020 "         // Para gravação de textos
	Private cFilDep   := xFilial("QAD")     // Utilizada no SXB
	
	If GetRPORelease() < '12.1.2710'

		oQIEA020Aux := QIEA020AuxClass():New()
		oQIEA020Aux:verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx()
		
	EndIf

	//Endereça a função de BROWSE
	mBrowse( 6, 1,22,75,"QE1")

Return .T.

/*/{Protheus.doc} MenuDef
Define Array contendo as Rotinas a executar do programa
@type  Static Function
@author Cleber Souza
@since 28/05/2004
@version P12
/*/
Static Function MenuDef()

// ----------- Elementos contidos por dimensao ------------	 
// 1. Nome a aparecer no cabecalho
// 2. Nome da Rotina associada
// 3. Usado pela rotina
// 4. Tipo de Transa‡„o a ser efetuada
//	 1 - Pesquisa e Posiciona em um Banco de Dados
//	 2 - Simplesmente Mostra os Campos
//	 3 - Inclui registros no Bancos de Dados
//	 4 - Altera o registro corrente
//	 5 - Remove o registro corrente do Banco de Dados
Local aRotina := { {OemToAnsi(STR0001), "AxPesqui", 0, 1,,.F.},;  //"Pesquisar"	
				   {OemToAnsi(STR0002), "QE020Ens", 0, 2},;       //"Visualizar"	
				   {OemToAnsi(STR0003), "QE020Ens", 0, 3},;       //"Incluir"		
				   {OemToAnsi(STR0004), "QE020Ens", 0, 4},;       //"Alterar"		
				   {OemToAnsi(STR0005), "QE020Ens", 0, 5, 3} }    //"Excluir"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QE020Ens ³ Autor ³ Cleber Souza          ³ Data ³ 28/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Ensaios - Inclusao/Alteracao	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QE020Ens(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION QE020Ens(cAlias,nReg,nOpc)

Local aAreaAnt := {}   
Local lCont	   := .F.
Local nOpcA    := 0  
Local nSeq	   := 0
Local oDlg     := Nil
Local oEnsaio  := Nil
Local oFont    := Nil
Local oGroup1  := Nil
Local oGroup2  := Nil
Local oSize    := Nil
Local oTexto   := Nil

Private cTexto    := "" 
Private lDuplDoc  := .T.
Private lQE020EXE := ExistBlock("QE020EXE")
Private nPosCla   := 0
Private nPosDCl   := 0    
Private nPosDNC   := 0
Private nPosNC    := 0
Private nSaveSX8  := GetSX8Len()
Private oGetNC    := Nil

RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.T.)

If !Empty(M->QE1_ENSAIO)
	nSeq := M->QE1_ENSAIO
Else
	nSeq := QA_SXESXF("QE1","QE1_ENSAIO",,1)
EndIf

If !Empty(QE1->QE1_CHAVE) .and. nOpc<>3
	cTexto := QA_RecTxt( QE1->QE1_CHAVE, cEspecie )
EndIf

// Validar se pode alterar ou excluir ensaio
If nOpc==4 .Or. nOpc==5
	If ExistBlock("QE020AENS") 
		lcont := Execblock("QE020AENS",.F.,.F.)	// PE para Permitir a alteração do Ensaio mesmo existindo medições
	Endif
	If !lCont
		aAreaAnt := GetArea()
		DbSelectArea("QER")
		QER->(dbSetOrder(2))
		If QER->(dbSeek(xFilial("QER")+M->QE1_ENSAIO))
			Help(" ",1,"A020ENSMED")   // "Ensaio apresenta medicoes cadastradas"
			Return
		EndIf
		RestArea(aAreaAnt)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]
Private aHeader := {}
Private aCols	:= {}

oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"  ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS1" ,  100, 35, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS2" ,  100, 35, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE cCadastro ;//"Ensaios"
							FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

oEnsaio := MsMGet():New(cAlias,nReg,nOpc,,,,,;
							{oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),;
						 	oSize:GetDimension("ENCHOICE","LINEND") ,oSize:GetDimension("ENCHOICE","COLEND")};
						 	,,,,,,oDlg,,.T.,,,,,,,.T.)

/* Documentação dos parametros do Metodo FillGetDados
FillGetDados  (nOpc,; 			// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               Alias,       	// area a ser utilizada;
               nOrdem,      	// ordem correspondente a chave de índice para preencher o  acols;
               cSeek,       	// chave utilizada no posicionamento da área para preencher o acols; 
               bSeekWhile,  	// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               uSeekFor,    	// pode ser utilizados de duas maneiras:
							 	   1 - bloco-de-codigo, condicao a ser utilizado para executar o Loop no While;
							 	   2 - array bi-dimensional contendo N condicoes, em que o 1 elemento o bloco condicional, o 2 bloco a ser executado se verdadeiro e o 3 e bloco a ser executado se falso:
							 	   Exemplo:
							 	   {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
               aNoFields,   	// array contendo os campos que não estarão no aHeader;
               aYesFields,  	// array contendo somente os campos que estarão no aHeader;
               lOnlyYes,    	// se verdadeiro, exibe apenas os campos de usuário;
               cQuery,      	// query a ser executada para preencher o acols;
               bMontCols,    	// bloco contendo funcao especifica para preencher o aCols; 
               lEmpty,       	// 
               aHeaderAux,   	// 
               aColsAux,     	// 
               bAfterCols,   	// 
               bBeforeCols,  	// 
               bAfterHeader,    // 
               cAliasQry)       // 
*/

cWhile  := Alltrim(RetSIX("QE2","1",.T.,{"QE2_NAOCON"}))
cSeek 	:= RetSIX("QE1","1",.T.)

FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QE2",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpc == 3),"",&cSeek),;  	// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 					// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usuário;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpc == 3),.T.,.F.),;  	// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a posicao dos campos no aHeadAux p/ posterior consistencia	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosNC  := Ascan(aHeader,{|x| x[2] = "QE2_NAOCON"})
nPosCla := Ascan(aHeader,{|x| x[2] = "QE2_CLASSE"})
nPosDNC := Ascan(aHeader,{|x| x[2] = "QE2_DESNCO"})
nPosDCl := Ascan(aHeader,{|x| x[2] = "QE2_DESCLA"})

QE020AfCols(  aHeader, @aCols, nOpc, nSeq )

@ oSize:GetDimension("GETDADOS1","LININI")+3,oSize:GetDimension("GETDADOS1","COLINI") GROUP oGroup1 TO ; //"Nao Conformidades"
			oSize:GetDimension("GETDADOS1","LINEND")-5,oSize:GetDimension("GETDADOS1","COLEND")-1 LABEL STR0007  OF oDlg PIXEL    
oGroup1:oFont:= oFont

oGetNC := MsNewGetDados():New(oSize:GetDimension("GETDADOS1","LININI")+10,oSize:GetDimension("GETDADOS1","COLINI")+3,;
						 oSize:GetDimension("GETDADOS1","LINEND")-6,oSize:GetDimension("GETDADOS1","COLEND")-5,;
						 Iif(nOpc==3 .Or. nOpc==4, GD_INSERT+GD_DELETE+GD_UPDATE, 0),"QE020LOk","QE020TOk","",,,,,,,oDlg,aHeader,aCols)

@ oSize:GetDimension("GETDADOS2","LININI"),oSize:GetDimension("GETDADOS2","COLINI") GROUP oGroup2 TO ; //"Metodo" 
				 oSize:GetDimension("GETDADOS2","LINEND"),oSize:GetDimension("GETDADOS2","COLEND")-1 LABEL STR0008  OF oDlg PIXEL    
oGroup2:oFont:= oFont

oTexto := TMultiGet():New(oSize:GetDimension("GETDADOS2","LININI")+7,oSize:GetDimension("GETDADOS2","COLINI")+4,;
									{|u| if(Pcount()>0,cTexto:=u,cTexto)} ,oDlg,oSize:GetDimension("GETDADOS2","XSIZE")-7,oSize:GetDimension("GETDADOS2","YSIZE")-11,,,,,,.T.,,,,,,IIf( nOpc==4 .Or. nOpc==3,.F.,.T.),,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(Obrigatorio(aGets,aTela) .and. QE020VLDEL(nOpc) .and. FQIE020(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{|| nOpcA:=0,oDlg:End()})

If nOpcA==1 .and. nOpc<>2
	QE020GrvAll(nOpc)
Else
	While (GetSX8Len() > nSaveSx8)
	    RollBackSX8()
	EndDo
EndIf

If lQE020EXE
	Execblock("QE020EXE",.F.,.F.,{"2",nOpc,nOpcA,nSeq})	
Endif

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QE020AfCols ºAutor  ³Cicero Cruz         º Data ³  17/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que carrega o aHeader e aCols da GetDados.            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com o Cabecalho da GetDados				    ³±±
±±³			 ³ ExpA2 = Array com as linhas da GetDados					    ³±±
±±³			 ³ ExpN1 = Opcao selecionada								    ³±±
±±³			 ³ ExpN2 = Sequencia do Ensaio								    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ QIEA020                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE020AfCols( aHeader, aCols, nOpc, nSeq )
Local nLinha := 0

For nLinha := 1 to Len(aCols)
	aCols[nLinha,nPosDNC] := Iif(!Empty(aCols[nLinha,nPosNC]),A020DNCo(aCols[nLinha,nPosNC]),"")
	aCols[nLinha,nPosDCl] := Iif(!Empty(aCols[nLinha,nPosCla]),A040DCla(aCols[nLinha,nPosCla]),"")  
Next

//Ponto de entrada para codigo sequencial do ensaio
If ExistBlock("QE020EXE") 
	Execblock("QE020EXE",.F.,.F.,{"1",nOpc,If(INCLUI,3,4),nSeq})
Endif

Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QE020LOk ³ Autor ³ Cleber Souza           ³ Data ³ 28/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE020LOk(o)

Local lRet     := .T.
Local nAchou   := 0
Local aCols    := oGetNC:aCols
Local n        := oGetNC:nAT
Local cProcura := aCols[n,nPosNC]
Local nDel     := Len(oGetNC:aHeader)+1
                   
If !(aCols[n,nDel])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campo NC esta' preenchido                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aCols[n,nPosNC])
		Help(" ",1,"QA_CPOOBR")
		lRet:=.F.	
	EndIf

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a NC ja' existe                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAchou := Ascan(aCols,{|x| x[nPosNC] == cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			Help(" ",1,"A020EXINCE")
			lRet:=.F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a NC esta' cadastrada               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If ! ExistCpo("SAG",aCols[n,nPosNC])
			aCols[n,nPosNC] := Space(TamSX3("QP9_NAOCON")[1])
			lRet := .f.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Classe da NC esta' cadastrada     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If ! ExistCpo("QEE",aCols[n,nPosCla])
			lRet := .f.
		EndIf
	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QE020TOk³ Autor ³ Cleber Souza            ³ Data ³ 28/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE020TOk(o)
Local nI, lRet := .t.

For nI := 1 to Len(aCols)
	If ! QE020LOk(o)
		lRet := .f.
		Exit
	EndIf
Next

Return(lRet)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QE020GrvAll ºAutor  ³Cleber Souza      º Data ³  25/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de gravação dos Ensaios, Não Conformidade e Metodo. º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao selecionada								  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIEA020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE020GrvAll(nOpc)       

Local nX      := 0 
Local nY      := 0
Local cVar    := ""
Local nDel    := Len(oGetNC:aHeader)+1
Local aCols   := oGetNC:aCols
Local aHeader := oGetNC:aHeader  
Local cChave  := "" 
Local aTexto  := {}
Local aStruct

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os dados referentes ao Ensaio                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("QE1",If(nOpc==3,.T.,.F.))
If (nOpc == 3 .Or. nOpc == 4) //Inclusao ou Alteracao
	
	aStruct := FWFormStruct(3,"QE1")[3] // Busca os campos usados (X3_USADO) da tabela
	For nX := 1 to Len(aStruct)
		If GetSx3Cache(aStruct[nX,1],"X3_CONTEXT") # "V"
			FieldPut(FieldPos(AllTrim(aStruct[nX,1])),&("M->"+aStruct[nX,1]))
		EndIf
	Next nX
	
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()   // Atualiza o ultimo roteiro em SX8
	Enddo
EndIf

If (nOpc == 3) //Inclusao
	QE1->QE1_FILIAL := xFilial("QE1")
	QE1->QE1_DTCAD  := dDataBase
EndIf
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Nao Conformidades Relacionadas ao Ensaio               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QE2 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(oGetNC:aCols)
	If !Empty(aCols[nX,nPosNC]) // Cod. NC nao vazio
		If !Acols[nX,nDel] .and. (nOpc==3 .or. nOpc==4)// Nao esta deletado 
			dbSelectArea("QE2")
			dbSetOrder(1)
			If dbSeek(xFilial("QE2") + QE1->QE1_ENSAIO + aCols[nX,nPosNC])         
				RecLock("QE2",.F.)   // Lock
			Else
				RecLock("QE2",.T.)   // Append
				QE2->QE2_FILIAL := xFilial("QE2")
				QE2->QE2_ENSAIO := QE1->QE1_ENSAIO
			Endif
			For nY := 1 to Len(aHeader)
				If aHeader[ny,10] # "V"
					cVar := Trim(aHeader[ny,2])
					Replace &cVar. With aCols[nx,ny]
				Endif
			Next nY
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela a NC no QE2 				  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QE2")
			dbSetOrder(1)
			If dbSeek(xFilial("QE2") + QE1->QE1_ENSAIO + aCols[nX,nPosNC])         
				RecLock("QE2",.F.)
				dbDelete()
			EndIf
		EndIf
		MsUnlock()
	EndIf
Next nX        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Metodo Informado.						                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpc==3 .or. nOpc==4
	AADD(aTexto,{1,cTexto})
	If !Empty(cTexto)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera/Obtem a chave ligacao com o Texto do Ensaio ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(QE1->QE1_CHAVE)
			cChave := QA_CvKey(xFilial("QE1")+QE1_ENSAIO,"QE1",2)
			// Grava a chave gerada
			RecLock("QE1",.F.)
			QE1->QE1_CHAVE := cChave
			MsUnLock()
		Else
			cChave := QE1->QE1_CHAVE
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Texto do Ensaio no QA2 							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QA_GrvTxt(cChave,cEspecie,1,aTexto) 	// QAXFUN
	Else
		If !Empty(QE1->QE1_CHAVE)
			QA_GrvTxt(QE1->QE1_CHAVE,cEspecie,1,aTexto) 	// QAXFUN
		EndIF
	EndIF
EndIf 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Na Rotina de exlusão, Ensaio tem de ser excluido por ultimo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 5)	
	dbSelectArea("QE1")
	RecLock("QE1",.F.)
	QE1->(dbDelete())
	MsUnlock()
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qie020VqTd³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 28.10.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o campo Qtde na entrada de dados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_VALID do campo QE1_QTDE 								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qie020VqTd(cCarta,nQtde)

local lRetu := .t.
if cCarta $ 'HIS.XBR.XBS.XMR.IND'
	if nQtde < 2 .or. nQtde > 10
		lRetu := .f.
		Help(" ",1,"A020CARTAX")
	endif
elseif cCarta $ 'NP .C  '
	if nQtde == 0
		lRetu := .f.
		Help(" ",1,"A020CARTAC")
		M->QE1_QTDE := 1
	endif
else
	if nQtde <> 0
		lRetu := .f.
		Help(" ",1,"A020CARTAP")
		M->QE1_QTDE := 0
	endif
endif
return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qie020VlNc³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Nao Conformidade 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qie020VlNc(ExpC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Nao Conformidade						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico - E' chamada no X3_VALID do cpo. QE?_NAOCON - SX3 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qie020VlNc(cNC)
	Local cVar  := &(readvar()) // Conteúdo da variável do campo NC
	Local lRetu := .t.
	Local nCont := 0

	If !hasSmartX()
		//Verifica se mudou a NC (Alterou o campo já digitado)
		If !Empty(oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC]) .and. !Empty(cVar) .and. oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC] <> cVar
			Help(" ",1,"A010ALTCHA")   //Campo não pode ser alterado
			lRetu := .f.
		EndIf

		If lRetu
			//Verifica se a NC está cadastrada
			oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC] := cNc
			
			SAG->(dbSetOrder(1))
			If SAG->(dbSeek(xFilial("SAG")+cNc))
				oGetNC:aCols[oGetNC:oBrowse:nAt][nPosCla] := SAG->AG_CLASSE
			Else
				oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC] := Space(TamSX3("QE9_NAOCON")[1])
				lRetu := .f.
			EndIf
			
		EndIf

		//Verifica se a NC já existe
		If lRetu
			For nCont := 1 To Len(oGetNC:aCols)
				If cVar == oGetNC:acols[nCont][nPosNC] .and. nCont <> oGetNC:oBrowse:nAt // Se já existir este cod. NC
					Help(" ",1,"A020EXINCE")
					lRetu := .f.
					EXIT
				EndIf
			Next nCont
		EndIf

		If lRetu
			//Preenche a Descrição da NC
			oGetNC:aCols[oGetNC:oBrowse:nAt][nPosDNC] := A020DNCo(oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC])
			
			//Preenche a Descrição da Classe
			oGetNC:aCols[oGetNC:oBrowse:nAt][nPosDCl] := A040DCla(oGetNC:aCols[oGetNC:oBrowse:nAt][nPosCla])
		EndIf
		
	EndIf

Return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qie020VlCl³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Classe da Nao Conformidade					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qie020VlNc(ExpC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Classe da Nao Conformidade						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico - E' chamada no X3_VALID do cpo. QE?_CLASSE - SX3 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qie020VlCl(cClasse)
	Local lRetu := ExistCpo("QEE", cClasse)

				   //Verifica se a origem da pilha de chamadas até a chamada dessa função, originou-se da execução de uma rotina SmartX.
	If lRetu .And. Findfunction( "totvs.framework.smartx.context.amIIn",.T. ) .And. !totvs.framework.smartx.context.amIIn()
		aCols[n][nPosCla] := cClasse
		aCols[n][nPosDCl] := A040DCla(aCols[n][nPosCla])
	EndIf

Return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A020DNCo ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a descricao da NC								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A020DNCo(cCodNC)
SAG->(dbSetOrder(1))
SAG->(dbSeek(xFilial("SAG") + cCodNC)) // NC posicionada na getdados
Return(SAG->AG_DESCPO)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qie020WhQt³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Determina X3_WHEN do campo QTDE de acordo com a Carta 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QieA020 - Chamada pelo cpo. QE1_QTDE - X3_WHEN			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qie020WhQt()
Local lRetu := .t.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Carta permite entrada da Qtde 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ReadVar() == "M->QE1_QTDE"
	If M->QE1_CARTA $ 'P  .U  .TXT'
		lRetu := .f.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se houver medicoes p/ o ensaio, nao altera a Qtde.			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetu
		QER->(dbSetOrder(2))
		If QER->(dbSeek(xFilial("QER")+M->QE1_ENSAIO))
			Help(" ",1,"A020ENSMED")   // "Ensaio apresenta medicoes cadastradas"
			lRetu := .f.
		EndIf
		QER->(dbSetOrder(1))
	EndIf
EndIf
Return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qie020IqTd³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 28.10.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa o campo Qtde na entrada de dados (X3_RELACAO)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gatilho do campo QE1_QTDE, a partir do QE1_CARTA			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qie020IqTd(cCarta)

Local nQtde := nRetu := M->QE1_QTDE

If Empty(nQtde)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se campo Qtde vazio, sugere as Qtdes defaults				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCarta == 'IND'
		nRetu := 2
	ElseIf cCarta $ 'HIS.XBR.XBS.XMR'
		nRetu := 5
	ElseIf cCarta $ 'NP .C  '
		nRetu := 1
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste o campo Qtde, porque pode ter alterado a Carta    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cCarta $ 'HIS.XBR.XBS.XMR.IND'
	if nQtde < 2 .or. nQtde > 10
		nRetu := Iif(cCarta == 'IND',2,5)
	endif
elseif cCarta $ 'NP .C  '
	if nQtde == 0
		nRetu := 1
	endif
else
	if nQtde <> 0
		nRetu := 0
	endif
endif
Return(nRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qie020dCar³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 28.01.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher a descricao da Carta do Ensaio 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qie020dCar(ExpC1,ExpL1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Carta 									  ³±±
±±³			 ³ ExpL1 = Indica se e' gatilho                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (QE1_CARTA)  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qie020dCar(cCodCa,lGatilho)
	Local aSx5Q4 := FWGetSX5( "Q4", cCodCa )
	Local cDescri := Space(Len(X5Descri()))

	lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)
	Inclui := Iif(Inclui == NIL,.f.,Inclui)

	IF !Inclui .or. lGatilho .And. (ValType(aSx5Q4) == "A" .And. Len(aSx5Q4) > 0)
		cDescri := aSx5Q4[1,4]
	Endif

Return cDescri

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qie020EnsC³ Autor ³ Paulo Emidio de Barros³ Data ³16/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ habilita o campo somente para as cartas Individuais		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qie020EnsC()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN do QE1_TIPO										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qie020EnsC()
Local lRetorno := .F.

If M->QE1_CARTA $ "XBR/XBS/XMR/IND/HIS"  
	lRetorno := .T.   
Else
	M->QE1_TIPO := 	'2'
EndIf 

Return(lRetorno)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QE020VLDEL³ Autor ³ Cleber Souza          ³ Data ³28/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ habilita o campo somente para as cartas Individuais		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qie020EnsC()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao Selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE020VLDEL(nOpc)

Local lRet       := .T.
Local aFiliais   := {}
Local nY         := 0
Local cFilQE1    := xFilial("QE1")
Local lGestEmp   := ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() )

If nOpc == 5  
	
	If FWModeAccess("QE6") == "E"
		aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual	
	Else 
		AADD(aFiliais,{Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial())}) //Space(2)
	EndIF                                                     
	If !(lGestEmp)
		For nY:=1 to Len(aFiliais)  
		    If aFiliais[nY,2]==cFilQE1 .or. FWModeAccess("QE1") == "C" //Empty(cFilQE1)
				dbSelectArea('QE7')  // Ensaios Mensuraveis do Produto
				dbSetOrder(3)
				dbSeek(aFiliais[nY,2] + QE1->QE1_ENSAIO)
				dbSetOrder(1)
				If Found()
					HELP(" ",1,"A020DENSPR",,QE7->QE7_PRODUT+' - '+QE7->QE7_REVI,3,1)
					dbSelectArea("QE1")
					lRet := .F. 
					Exit
				EndIf
			EndIf    
		Next nY
		
		If lRet
			For nY:=1 to Len(aFiliais)  
			    If aFiliais[nY,2]==cFilQE1 .or. FWModeAccess("QE1") == "C" //Empty(cFilQE1)
					dbSelectArea('QE8')  // Ensaios Textos do Produto
					dbSetOrder(3)
					dbSeek(aFiliais[nY,2] + QE1->QE1_ENSAIO)
					dbSetOrder(1)
					If Found()
						HELP(" ",1,"A020DENSPR",,QE8->QE8_PRODUT+' - '+QE8->QE8_REVI,3,1)
						dbSelectArea("QE1")
						lRet := .F. 
						Exit
					EndIf
				EndIF
			Next nY
		EndIf
	Else		
		dbSelectArea('QE7')  // Ensaios Mensuraveis do Produto
		dbSetOrder(3)
		dbSeek(cFilQE1 + QE1->QE1_ENSAIO)
		dbSetOrder(1)
		If Found()
			HELP(" ",1,"A020DENSPR",,QE7->QE7_PRODUT+' - '+QE7->QE7_REVI,3,1)
			dbSelectArea("QE1")
			lRet := .F. 
		EndIf		
		If lRet
			dbSelectArea('QE8')  // Ensaios Textos do Produto
			dbSetOrder(3)
			dbSeek(cFilQE1 + QE1->QE1_ENSAIO)
			dbSetOrder(1)
			If Found()
				HELP(" ",1,"A020DENSPR",,QE8->QE8_PRODUT+' - '+QE8->QE8_REVI,3,1)
				dbSelectArea("QE1")
				lRet := .F. 
			EndIf
		EndIf
	Endif 	
EndIf

Return(lRet)

/*/{Protheus.doc} FQIE020
Função que valida a existencia de aspas simples no campo Ensaio 
@type function
@version  
@author thiago.rover
@since 15/04/2021
@return return_type, return_description
/*/
Static Function FQIE020()
Local lRet := .T.
Local nI   := 0

	If At('??',M->QE1_ENSAIO) != 0 // Foi identificado que com duas interrogações, ocorre erro na geração de querys
		lRet := .F.  
	Else
		For nI:= 1 to len(M->QE1_ENSAIO)
			If cValTOChar(ASC(Substr(M->QE1_ENSAIO,nI,1)) ) $ '37|39' // ASC(" ' ") Aspas simples
				lRet := .F.  
				exit
			EndIf
		Next nI
	EndIf
	
	If !lRet
		Help("", 1, STR0009, NIL, STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011}) //#"ATENÇÃO" //#"Foi digitado algum caracter de controle" //#"Utilize outro caracter, evite aspas simples, caracteres especiais e operadores"
		Return .F. 
	EndIf


Return .T.


/*/{Protheus.doc} verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx
Verifica e exibe o aviso de substituicao da rotina QIEA020 pela QIEA020SX.
A preferencia de supressao e persistida por usuario via FWProfile.
Deve ser chamada no inicio da rotina QIEA020, antes de qualquer processamento.
@author rafael.kleestadt
@since 13/05/2026
@version P12
/*/
Method verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx() Class QIEA020AuxClass

    Local cDataGrava := ""
    Local dDataExp   := CToD("")
    Local lExibir    := .F.
    Local oProfile   := FWProfile():New()

    // Carrega o profile do usuario atual
    oProfile:SetUser(RetCodUsr())
    oProfile:SetProgram(QIEA020_PROG)
    oProfile:SetTask(QIEA020_TASK)
    oProfile:Load()

    cDataGrava := AllTrim(oProfile:GetStringProfile())

    If Empty(cDataGrava)
        // Nunca suprimiu: exibe o aviso
        lExibir := .T.
    Else
        // Verifica se o periodo de supressao ja expirou
        dDataExp := SToD(cDataGrava)
        lExibir  := (dDataBase >= dDataExp)
    EndIf

    If lExibir
        // Retorna .T. se o usuario clicou em "Lembrar mais tarde"
        If Self:exibeAvisoSubstituicaoPorSmartx()
            // Grava a data de expiracao: hoje + 7 dias
            oProfile:SetStringProfile(DToS(Date() + QIEA020_DIAS))
            oProfile:Save()
        EndIf
    EndIf

    FreeObj(oProfile)
	oProfile := NIL

Return

/*/{Protheus.doc} methodName
Monta e exibe o dialogo modal de aviso de substituicao da QIEA020.
Dois botoes: "OK" (fecha sem suprimir) e "Lembrar mais tarde (7 dias)" (suprime).
@author rafael.kleestadt
@since 13/05/2026
@version P12
@return lLembrar, logico, .T. se o usuario clicou em "Lembrar mais tarde"
/*/
Method exibeAvisoSubstituicaoPorSmartx() Class QIEA020AuxClass

    Local aButtons   := {}
    Local lLembrar   := .F.   // .T. = clicou em "Lembrar mais tarde"
    Local oContainer := NIL
	Local oFont      := NIL   // objeto de fonte para o texto da mensagem
    Local oModal     := NIL

    // --- Cria a fonte: Arial, 14px, sem negrito ---
    // nAltura negativo = tamanho exato em pixels
    oFont := TFont():New('Arial', /*nLargura*/, -14, /*lBold*/ .F.)

    oModal := FWDialogModal():New()
    oModal:SetTitle(OemToAnsi(STR0012)) //"Atenção!"
    oModal:SetEscClose(.F.)         // Nao fecha com ESC (forcando escolha consciente)
    oModal:SetCloseButton(.F.)      // Remove o X do canto superior direito
    oModal:setSize(100, 300)        // Altura x Largura em pixels
    oModal:createDialog()

    // --- Botao "Lembrar mais tarde (7 dias)" ---
    // Fica a esquerda, e a acao menos urgente
    AAdd(aButtons, { ;
        "",                                        ; // [1] Compatibilidade (descontinuado no P12)
        OemToAnsi(STR0013),                        ; // [2] Titulo do botao STR0013 - "Lembrar mais tarde (7 dias)"
        {|| lLembrar := .T., oModal:DeActivate()}, ; // [3] Bloco de codigo
        OemToAnsi(STR0014),                        ; // [4] Tooltip STR0014 - "Suprimir este aviso pelos próximos 7 dias"
        0,                                         ; // [5] ShortCut
        .T.,                                       ; // [6] Visivel na barra
        .F.                                        ; // [7] Visivel na configuracao
    })

    oModal:AddButtons(aButtons)

    // --- Botao "OK" ---
    // Fica a direita (padrao), e o botao principal/focal
    oModal:addOkButton({|| lLembrar := .F., oModal:DeActivate()}, "OK")

    // --- Conteudo do dialogo ---
    oContainer := TPanel():New(,,, oModal:getPanelMain())
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	TSay():New(15, 10, ;
        {|| OemToAnsi(STR0015)}, ; // "A partir da versão 12.1.2710 esta rotina deve ser substituída pela nova QIEA020SX que já está disponível para uso a partir da versão 12.1.2610."
        oContainer, /*cPicture*/, oFont, , , , .T., , , 285, 20, , , , , , .T.)

    oModal:Activate()

Return lLembrar
