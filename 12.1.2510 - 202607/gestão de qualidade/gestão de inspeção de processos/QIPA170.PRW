#Include "TOTVS.CH"
#Include "QIPA170.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPA170  ³ Autor ³ Cleber Souza          ³ Data ³ 22/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Skip-Teste Individual           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { 		{OemToAnsi(STR0001) ,"AxPesqui"    , 0 , 1,,.F.},; //"Pesquisar" 
						{OemToAnsi(STR0002) ,"QIP170PROC"  , 0 , 2     },; //"Visualizar"
						{OemToAnsi(STR0003) ,"QIP170PROC"  , 0 , 3     },; //"Incluir"
						{OemToAnsi(STR0004) ,"QIP170PROC"  , 0 , 4     },; //"Alterar" 
						{OemToAnsi(STR0005) ,"QIP170PROC"  , 0 , 5 , 3 } } //"Excluir" 

Return aRotina

Function QIPA170
// Define o cabecalho da tela de atualizacoes
PRIVATE __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
PRIVATE cCadastro  := OemtoAnsi(STR0006) //"Skip-Teste Individual"
PRIVATE lFase3     := ChkFile("QQ4")
PRIVATE lProduto   := .F.

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
//³    6 - Nao permite inclusao na getdados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina:= MenuDef()

// Endereca a funcao de BROWSE
mBrowse( 6, 1,22,75,"QPH")

Return .T.  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIP170PROC³ Autor ³ Cleber Souza          ³ Data ³ 22/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao Skip-Teste Individual              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIP170PROC(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIP170PROC(cAlias,nReg,nOpc)

Local cSeek    := ''
Local cWhile   := ''
Local nOpcA    := 1
Local oDlg     := Nil
Local oGetDesc := Nil
Local oGetHis  := Nil
Local oGetProd := Nil
Local oGetRot  := Nil
Local oGroup1  := Nil
Local oGroup2  := Nil
Local oSize    := Nil

Private aCols      := {}
Private aHeader    := {}
Private aHistorico := {}
Private cCod       := ""
Private cDesPro    := Space(TamSX3("B1_DESC")[1])
Private cEspecie   := "QIPA170 " //Utilizado para gravacao de textos
Private cGetHis    := ""
Private cProduto   := Space(TamSX3("QPH_PRODUT")[1])
Private cRoteiro   := Space(TamSX3("QPH_CODREC")[1])
Private nHisAnt    := 1
Private nPosChave  := 0
Private nPosEns    := 0
Private nPosOper   := 0
Private nPosSkT    := 0
Private nUsado     := 0
Private oGet       := Nil

FillGetDados(	nOpc,; 							// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	"QPH",;       					// area a ser utilizada;
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
               	
nUsado := Len(aHeader)

// Guarda as posicoes dos campos p/ posterior consistencia
nPosAliWT := Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_ALI_WT' } )
nPosChave := Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_CHAVE'  } )
nPosEns   := Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_ENSAIO' } )
nPosOper  := Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_OPERAC' } )
nPosRecWT := Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_REC_WT' } )
nPosSkT   := Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_SKPTES' } )
nPosDesc  := Ascan(aHeader, { |x| Alltrim(x[2]) == 'QPH_DESENS' } )

If nOpc # 3
	cProduto := QPH->QPH_PRODUT 
	cRoteiro := QPH->QPH_CODREC
	cDesPro  := QIPXDePr(cProduto)
	QP170ENSA(nOpc)
EndIF	

oSize := FwDefSize():New(.T.) 
                 
oSize:AddObject( "CABECALHO" ,  100, 35, .T.,.F.)
oSize:AddObject( "GETDADOS1" ,  100, 35, .T.,.T.) 
oSize:AddObject( "GETDADOS2" ,  100, 30, .T.,.T.)     
           
oSize:aMargins := { 3, 3, 0, 3 }

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; // "Plano de Amostragem por Ensaio"	 
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

@ oSize:GetDimension('CABECALHO'  , 'LININI'),oSize:GetDimension('CABECALHO'  , 'COLINI') GROUP oGroup1 TO ;
  oSize:GetDimension('CABECALHO'  , 'LINEND'),oSize:GetDimension('CABECALHO'  , 'COLEND')-5	LABEL "" OF oDlg PIXEL      
@ oSize:GetDimension('GETDADOS2'  , 'LININI'),oSize:GetDimension('GETDADOS2'  , 'COLINI') GROUP oGroup2 TO ;
  oSize:GetDimension('GETDADOS2'  , 'LINEND'),oSize:GetDimension('GETDADOS2'  , 'COLEND')-5	LABEL OemToAnsi(STR0012) OF oDlg PIXEL  //"Historico"


@ oSize:GetDimension('CABECALHO'  , 'LININI')+5,10 SAY TitSX3("QPH_PRODUT")[1] SIZE 35,7 OF oDlg PIXEL	//"Produto"
@ oSize:GetDimension('CABECALHO'  , 'LININI')+5,45 MSGET oGetProd VAR cProduto PICTURE PesqPict("QPH","QPH_PRODUT"); 
					VALID Q170VLPROD(oGetDesc,nOpc);	
					When nOpc==3 F3 "QP6" SIZE 136,10 OF oDlg PIXEL
@ oSize:GetDimension('CABECALHO'  , 'LININI')+5,185 SAY OemToAnsi(STR0007)  SIZE 35,7 OF oDlg PIXEL		    //"Cód. Roteiro"
@ oSize:GetDimension('CABECALHO'  , 'LININI')+5,220 MSGET oGetRot VAR cRoteiro PICTURE PesqPict("QPH","QPH_CODREC");
					VALID QP170ENSA(nOpc) When nOpc==3 SIZE 13,10 OF oDlg PIXEL			
@ oSize:GetDimension('CABECALHO'  , 'LININI')+20,10 SAY OemToAnsi(STR0017)  SIZE 35,7 OF oDlg PIXEL		    //Descricao
@ oSize:GetDimension('CABECALHO'  , 'LININI')+20,45 MSGET oGetDesc VAR cDesPro	PICTURE PesqPict("QPH","QPH_PRODUT") When .F. SIZE 180,10 OF oDlg PIXEL	


oGet:= MSGetDados():New(oSize:GetDimension('GETDADOS1'  , 'LININI')+5,oSize:GetDimension('GETDADOS1'  , 'COLINI')+5,;
							oSize:GetDimension('GETDADOS1'  , 'LINEND')-5,oSize:GetDimension('GETDADOS1'  , 'COLEND')-5,;
							nOpc,"AllwaysTrue","QIPA170TOK("+cValtoChar(nOpc)+")","",.T.,,,,Len(aCols))      
oGet:oBrowse:bChange    := {|| IIF(Len(aHistorico)>0,(aHistorico[nHisAnt] := cGetHis, cGetHis:=aHistorico[N],nHisAnt:=N,oGetHis:Refresh()),.T.)}  


@ oSize:GetDimension('GETDADOS2'  , 'LININI')+10,oSize:GetDimension('GETDADOS2'  , 'COLINI')+5;
	GET oGetHis VAR cGetHis MEMO NO VSCROLL VALID .T. Size oSize:GetDimension('GETDADOS2'  , 'XSIZE')-20,oSize:GetDimension('GETDADOS2'  , 'YSIZE')-15;
	 When .T. Of oDlg Pixel 	


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||;
							IIF(oGet:TudoOK(),(nOpcA:=1,aHistorico[n]:=cGetHis,oDlg:End()),nOpcA:=2)},{||nOpcA:=2,oDlg:End()})

If nOpcA == 1
	A170GrvAll(nOpc)	
EndIf

Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP170Ens  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 16/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QP170Ens(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1: Opcao selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QP170ENSA(nOpc)

Local cGrupo := ""
Local cRevi  := ""
Local lGrupo := .F.
Local lRetu  := .T.
Local nCnt   := 0
Local nX     := 0
Local nY     := 0

cRoteiro := Iif(Empty(cRoteiro),QIPRotGene("QPH_CODREC"),cRoteiro)

If nOpc == 3
	If QPH->(dbSeek(xFilial("QPH")+cProduto+cRoteiro))
		MsgAlert(OemToAnsi(STR0018),OemToAnsi(STR0009)) //"Já existe Skip Teste definido para esse Produto x Roteiro." ###"Atencao"
		lRetu := .F.
	EndIF
EndIF

If !Empty(cProduto) .And. !Empty(cRoteiro) .And. lRetu
	aCols:={}

	// Identifica a revisao vigente do Produto
	cRevi := QA_UltRevEsp(cProduto,,,,"QIP")
	
	// Alimenta vetor aCols com os Ensaios associados ao Produto
	// Identifica o Grupo do Produto, se houver
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA")+cProduto))
		cGrupo := QPA->QPA_GRUPO		
	EndIf
	QPA->(dbSetOrder(1))

	//Ensaios mensuraveis
	dbSelectArea("QP7")
	dbSetOrder(1)
	dbSeek( xFilial("QP7")+cProduto+cRevi+cRoteiro)
	While !Eof() .And. QP7_FILIAL+QP7_PRODUT+QP7_REVI+QP7_CODREC == xFilial("QP7")+cProduto+cRevi+cRoteiro
		// Verifica se existe operacoes por grupo relacionadas com o prod.
		If QQK->(dbSeek(xFilial("QQK")+Padr(cGrupo,15)+QP7->QP7_REVI+cRoteiro+QP7->QP7_OPERAC))
			lGrupo := .T.
		EndIf
		
		aadd(aCols,Array(nUsado+1))	// Cria novo elemento no acols
		nCnt := Len(aCols)
		
		// Alimenta o aCols
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_ENSAIO'})] := QP7->QP7_ENSAIO
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_DESENS'})] := QIPXDeEn(QP7->QP7_ENSAIO)
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_OPERAC'})] := QP7->QP7_OPERAC
		
		If QPH->(dbSeek(xFilial("QPH")+cProduto+cRoteiro+QP7->QP7_OPERAC+QP7->QP7_ENSAIO))
			aCols[nCnt,nPosSkT]		:= QPH->QPH_SKPTES
			aCols[nCnt,nPosChave]	:= QPH->QPH_CHAVE
		Else
			aCols[nCnt,nPosSkT] := 0
		EndIf

		If QPI->(dbSeek( xFilial("QPI")+QPA->QPA_GRUPO+cRoteiro+QP7->QP7_OPERAC+QP7->QP7_ENSAIO))
			aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_SKPGRU'})] := QPI->QPI_SKPTES
		Else
			aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_SKPGRU'})] := 0
		EndIf 
		
		For nY:=1 to Len(aHeader)
			If Empty(aCols[nCnt,nY])
				If !Empty(GetSX3Cache(aHeader[nY,2],"X3_CAMPO"))
					If Empty(aCols[nCnt,nPosSkT])
						If Empty(GetSx3Cache(aHeader[nY,2], "X3_RELACAO"))         
					 		If GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "C"
					   	    		aCols[nCnt,nY] := Space(GetSx3Cache(aHeader[nY,2], "X3_TAMANHO"))
						   	Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "N"
					   	    		aCols[nCnt,nY] := 0
						    Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "D"
						        aCols[nCnt,nY] := dDataBase
						   	Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "M"
						        aCols[nCnt,nY] := ""
						    Else
						  	    aCols[nCnt,nY] := .F.
						    EndIf         
					 	Else
					 		aCols[nCnt,nY] :=InitPad(GetSx3Cache(aHeader[nY,2], "X3_RELACAO"))
					 	EndIF
					Else 
						If GetSx3Cache(aHeader[nY,2], "X3_CONTEXT")#"V" .and. GetSx3Cache(aHeader[nY,2], "X3_PROPRI") == "U"
							aCols[nCnt,nY] := &("QPH->"+aHeader[nY,2])
						EndIF
					EndIF
				EndIf
			EndIF	
		Next nY
		aCOLS[nCnt,nUsado+1] := .F.
		If nPosAliWT > 0
			aCols[nCnt,nPosAliWT] := "QPH"
		EndIf
		If nPosRecWT > 0
			If nOpc # 3
				aCols[nCnt,nPosRecWT] := QPH->(RecNo())
			Else
				aCols[nCnt,nPosRecWT] := 0
			EndIf
		EndIf
		dbSelectArea("QP7")
		dbSkip()
	Enddo
	//Ensaios Texto
	dbSelectArea("QP8")
	dbSeek( xFilial("QP8")+cProduto+cRevi+cRoteiro)
	While !Eof() .And. QP8_FILIAL+QP8_PRODUT+QP8_REVI+QP8_CODREC == xFilial("QP8")+cProduto+cRevi+cRoteiro
		aadd(aCols,Array(nUsado+1))	// Cria novo elemento no acols

		If QQK->( dbSeek( xFilial("QQK")+Padr(cGrupo,15)+QP8->QP8_REVI+cRoteiro+QP8->QP8_OPERAC ) )
			lGrupo := .T.
		EndIf
		
		nCnt := Len(aCols)
		// Alimenta o aCols
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_ENSAIO'})]:=QP8->QP8_ENSAIO
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_DESENS'})]:=QIPXDeEn(QP8->QP8_ENSAIO)
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_OPERAC'})]:=QP8->QP8_OPERAC
		
		If QPH->(dbSeek(xFilial("QPH")+cProduto+cRoteiro+QP8->QP8_OPERAC+QP8->QP8_ENSAIO))
			aCols[nCnt,nPosSkT]		:= QPH->QPH_SKPTES
			aCols[nCnt,nPosChave]	:= QPH->QPH_CHAVE
		Else
			aCols[nCnt,nPosSkT] := 0
		EndIf
		If QPI->(dbSeek( xFilial("QPI")+QPA->QPA_GRUPO+cRoteiro+QP8->QP8_OPERAC+QP8->QP8_ENSAIO))
			aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_SKPGRU'})] := QPI->QPI_SKPTES
		Else
			aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_SKPGRU'})] := 0
		EndIf 
		
		For nY:=1 to Len(aHeader)
			If Empty(aCols[nCnt,nY])
				
				If ( !Empty(GetSx3Cache(aHeader[nY,2], "X3_RELACAO")) )
					If Empty(aCols[nCnt,nPosSkT])
						If Empty(GetSx3Cache(aHeader[nY,2], "X3_RELACAO"))         
					 		If GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "C"
					   	    		aCols[nCnt,nY] := Space(GetSx3Cache(aHeader[nY,2], "X3_TAMANHO"))
						   	Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "N"
					   	    		aCols[nCnt,nY] := 0
						    Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "D"
						        aCols[nCnt,nY] := dDataBase
						   	Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "M"
						        aCols[nCnt,nY] := ""
						    Else
						  	    aCols[nCnt,nY] := .F.
						    EndIf         
					 	Else
					 		aCols[nCnt,nY] :=InitPad(GetSx3Cache(aHeader[nY,2], "X3_RELACAO"))
					 	EndIF
					Else 
						If GetSx3Cache(aHeader[nY,2], "X3_CONTEXT")#"V" .and. GetSx3Cache(aHeader[nY,2], "X3_PROPRI") == "U"
							aCols[nCnt,nY] := &("QPH->"+aHeader[nY,2])
						EndIF
					EndIF
				EndIf
			EndIF	
		Next nY
		aCOLS[nCnt,nUsado+1] := .F. 
		If nPosAliWT > 0
			aCols[nCnt,nPosAliWT] := "QPH"
		EndIf
		If nPosRecWT > 0
			If nOpc # 3
				aCols[nCnt,nPosRecWT] := QPH->(RecNo())
			Else
				aCols[nCnt,nPosRecWT] := 0
			EndIf
		EndIf		
		dbSelectArea("QP8")
		dbSkip()
	Enddo
	// Ordena Ensaios de acordo com o campo Ensaio
	aCols := asort(aCols,,, { | x,y | x[nPosOper]+x[nPosEns] < y[nPosOper]+x[nPosEns]})
	
	// Posiciona o arquivo de Skip-Teste Individual
	dbSelectArea("QPH")
	dbseek(xFilial()+cProduto)
EndIf	

If lRetu
	// Monta Array com os Historicos relacionados aos Ensaios.
	If Len(aCols) > 0
		
		For nX:=1 to Len(aCols)
			// Gera/obtem a chave de ligacao com o texto do Produto/Rv
			If Empty(aCols[nX,nPosChave])
				AADD(aHistorico,"")
			Else
				AADD(aHistorico,QA_RecTxt(aCols[nX,nPosChave],cEspecie))
			EndIf
		Next nX
		cGetHis := aHistorico[1]
		
	EndIF
	
	If Len(aCols) == 0 .Or. lGrupo
		If lGrupo
			MsgAlert(OemToAnsi(STR0010),OemToAnsi(STR0009)) //"Seq.Operação está relacionada com roteiro por grupo."###"Atenção"
		Else
			MsgAlert(OemToAnsi(STR0011),OemToAnsi(STR0009)) //"Produto/Revisão não tem ensaios relacionados."###"Atenção"
		EndIf
		lRetu:= .F.
	Else
		If nOpc == 3 //Inclusão
			n:=1
			oGet:ForceRefresh()
		EndIf
	EndIf
	
EndIf

Return(lRetu)

/*/{Protheus.doc} Q170VLPROD
Função para gatilhar os dados do campo roteiro
@type  Function
@author Jefferson Possidonio
@since 31/10/2024
@version P12
@param 01 oGetDesc , objeto  , Campo Get da descrição
@param 02 nOpc, numerico, Operação que está sendo executada na tela
@return lRet  , lógico  , Retorna se encontrou o produto na tabela QP6
/*/
Function Q170VLPROD(oGetDesc,nOpc)

Local cRevisa := QA_UltRevEsp(cProduto,,,,"QIP")
Local lRet    := .T.

If ExistCpo("QP6",cProduto)
	cDesPro:= QIPXDePr(cProduto)
	oGetDesc:Refresh()
	QP6->(dbSetorder(1))
	QP6->(dbseek(xFilial("QP6")+cProduto+Inverte(cRevisa)))
	If QP6->QP6_CODREC == QIPRotGene("QP6_CODREC")
		QP170ENSA(nOpc)
	Endif
Else
	lRet := .F.
Endif

Return lRet

/*/{Protheus.doc} QIPA170TOK
Função de Validação do MSGetDados
@type  Function
@author Jefferson Possidonio
@since 30/10/2024
@version P12
@param nOpc , numerico, Operação que está sendo executada na tela
@return lRet, lógico  , Retorna se a grid foi preenchida corretamente
/*/
Function QIPA170TOK(nOpc)

Local lRet      := .T.
Local nMaxArray := Len(aCols)
Local nX        := 0
Local nCont     := 0

If nOpc == 4 .Or. nOpc == 3
	For nX := 1 to nMaxArray 
		If aCols[nX,nPosSkT] == 0 .And. aCols[nX,len(aheader)+1] == .F.
			nCont ++			
		Endif
	Next nX
Endif

If nCont == nMaxArray
	msgalert(OemToAnsi(STR0019),OemToAnsi(STR0009)) // "Coluna skip-teste não foi preenchida. Verifique!" // "Atenção"
	lRet := .F.
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A170GrvST ³ Autor ³ Marcelo Pimentel      ³ Data ³ 16/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os Skip-Testes Individuais                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A170GrvAll(nOpc)
Local axtextos  := {} //Vetor que contem os textos dos Produtos
Local cChvQPY   := ""
Local nMaxArray := Len(aCols)
Local nx        := 0
Local ny        := 0

If ExistBlock("QP170GRV")
	ExecBlock("QP170GRV",.F.,.F.,{cProduto,cRoteiro})
Endif

// Grava o arquivo QPH 
For nX := 1 to nMaxArray
	dbSelectArea("QPH")
	axTextos := {}
	If !Acols[nX,nUsado+1] .And. nOpc#5
		If !Empty(aCols[nX,nPosSkT]).And. aCols[nX,nPosSkT] <> 0 .And.!Empty(cProduto).And.;
			!Empty(cRoteiro) .And. !Empty(aCols[nX,nPosEns]) 
			
			If Empty(aCols[nX,nPosChave]) .and. !Empty(aHistorico[nX])
				aCols[nX,nPosChave] := QA_CvKey(xFilial("QPH")+cProduto+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns],"QPH", 3)
			EndIF
			
			// Grava Historico.
			If !Empty(aCols[nX,nPosChave])
				Aadd(axTextos,{1,aHistorico[nX]})
				Qa_GrvTxt(aCols[nX,nPosChave],cEspecie,1,axTextos)   
			EndIf

			If dbSeek(xFilial("QPH")+cProduto+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns])
				RecLock("QPH",.F.)   // Lock
				QPH->QPH_SKPTES := aCols[nX,4]
				QPH->QPH_CHAVE  := aCols[nX,nPosChave]
			Else
				RecLock("QPH",.T.)   // Append
				QPH->QPH_FILIAL := xFilial("QPH")
				QPH->QPH_PRODUT := cProduto
				QPH->QPH_ENSAIO := aCols[nX,nPosEns]
				QPH->QPH_CODREC := cRoteiro
				QPH->QPH_OPERAC := aCols[nX,nPosOper]
				QPH->QPH_SKPTES := aCols[nX,nPosSkT]   
				QPH->QPH_CHAVE  := aCols[nX,nPosChave]
			Endif
		
			For ny := 1 to Len(aHeader)
				If aHeader[ny,10] <> "V"
					cVar := alltrim(aHeader[ny,2])
					Replace &cVar. With aCols[nx,ny]
				Endif 
			Next ny 
			MsUnlock()
		EndIf	
	Else		//Se cancelou ou alterou para zero
		// Cancela o Skip-Teste do Ensaio
		If dbSeek(xFilial("QPH")+cProduto+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns])
			RecLock("QPH",.F.)
			dbDelete()

			// Deleta o Controle Skip-Teste Individual
			If QPN->(dbSeek(xFilial("QPN")+cProduto+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns]))
				RecLock("QPN", .F.)
				QPN->(dbDelete()) 
			EndIf
			
			// Deleta o Historico Skip-Teste do Ensaio
			cChvQPY := QPH->QPH_PRODUT+cRoteiro+aCols[nX,nPosOper]+QPH->QPH_ENSAIO
			QPY->(dbSetOrder(2))
			QPY->(dbSeek(xFilial("QPY")+cChvQPY))
			While QPY->QPY_FILIAL+QPY->QPY_PRODUT+QPY->QPY_CODREC+QPY->QPY_OPERAC+QPY->QPY_ENSAIO ==;
				xFilial("QPY")+cChvQPY .And. !QPY->(Eof())
				RecLock("QPY", .F.)
				QPY->(dbDelete())
				QPY->(dbSkip())
			Enddo
			QPY->(dbSetOrder(1))
		EndIf
	EndIf
Next nx

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A170WhST ³ Autor ³ Marcelo Pimentel      ³ Data ³ 16/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula WHEN para o campo Skip-Teste             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A170WhST()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A170WhST()
Local lRetu := .T.

// Verifica se já  definiu o skip-teste por grupo
QPA->(dbSetOrder(2))
If QPA->(dbSeek(xFilial("QPA")+cProduto))
	If QPI->(dbSeek( xFilial("QPI")+QPA->QPA_GRUPO+cRoteiro+aCols[n,nPosOper]+aCols[n,nPosEns]))
		MsgInfo(OemToAnsi(STR0008),OemToAnsi(STR0009))	// "O Skip-Teste referente a ensaio está definido por grupo."###"Atenção"
		lRetu := .F.
	EndIf
EndIf
QPA->(dbSetOrder(1))
Return(lRetu) 
