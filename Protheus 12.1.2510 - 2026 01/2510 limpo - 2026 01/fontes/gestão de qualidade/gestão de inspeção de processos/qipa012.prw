#INCLUDE "QIPA012.CH"
#INCLUDE "TOTVS.CH"

#DEFINE CRLF chr(13) + chr(10)

#DEFINE CONFIRMOU_TELA   1
#DEFINE MODO_SELECIONADO 2

#DEFINE PARAM_COPIA_PRODUTO_DESTINO  1
#DEFINE PARAM_COPIA_REVISAO_DESTINO  2
#DEFINE PARAM_COPIA_ROTEIRO_DE       3
#DEFINE PARAM_COPIA_ROTEIRO_ATE      4
#DEFINE PARAM_COPIA_ROTEIRO_PRIMARIO 5
#DEFINE PARAM_COPIA_MESCLA_ROTEIRO   6
#DEFINE PARAM_COPIA_ARQUIV_ESPECIFIC 8


#DEFINE PARAM_COPIA_ENSAIOS_ROTEIRO_BASE     1
#DEFINE PARAM_COPIA_ENSAIOS_OPERACAO_BASE    2
#DEFINE PARAM_COPIA_ENSAIOS_DO_ENSAIO        3
#DEFINE PARAM_COPIA_ENSAIOS_ATE_O_ENSAIO     4
#DEFINE PARAM_COPIA_ENSAIOS_PRODUTO_DESTINO  5
#DEFINE PARAM_COPIA_ENSAIOS_REVISAO_DESTINO  6
#DEFINE PARAM_COPIA_ENSAIOS_ROTEIRO_DESTINO  7
#DEFINE PARAM_COPIA_ENSAIOS_OPERACAO_DESTINO 8


Static _ROT := 1 //Roteiro
Static _OPE := 2 //Operacao
Static _RAS := 3 //Rastreabilidade 
Static _TXT := 4 //Observacoes da Operacao                                                                                 
Static _ENS := 5 //Ensaio
Static _INS := 6 //Instrumentos
Static _NCO := 7 //Nao-conformidades
Static _PAE := 8 //Plano de Amostragem por Ensaio

Static lPriModTel := .T. //Controle primeira exibição de inclusão contínua
Static lQP010TeDB := FindFunction("QPA010TeDB")
Static lQP010Tela := FindFunction("QPA010Tela")
Static nCacheTela := 0 //Guarda o último modo de tela escolhido em inclusão na Thread
Static slQAXA090  := FindFunction("QAXA090")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ QPM010 - Variaveis utilizadas para parametros					³
//³ mv_par01				// Produto Origem    					³
//³ mv_par02				// Revisao Origem 						³
//³ mv_par03				// Produto Destino                		³
//³ mv_par04				// Revisao Destino						³
//³ mv_par05				// Origem da Descricao                  ³
//³ mv_par06				// Descricao do Produto Destino         ³
//³ mv_par07				// Roteiro De       	                ³
//³ mv_par08				// Roteiro Ate		                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static sMvPar05 := Nil
Static sMvPar06 := Nil
Static sMvPar07 := Nil
Static sMvPar08 := Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QIPA012  ³ Autor ³ Cleber Souza          ³ Data ³11/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de atualizacao das Especificacoes de Produtos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIP													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado -> STR0000                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			   ³        ³	   ³										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()

	Local aRotAdic  := {} 
	Private aRotina := {	{OemtoAnsi(STR0001),"AxPesqui"   ,0, 1,,.F.},;	//"Pesquisar"
							{OemtoAnsi(STR0002),"QPA012Atu"  ,0, 2   },;	//"Visualizar"
							{OemtoAnsi(STR0003),"QPA012Atu"  ,0, 3   },;	//"Incluir"
							{OemtoAnsi(STR0004),"QPA012Atu"  ,0, 4, 2},;	//"Alterar"
							{OemtoAnsi(STR0005),"QPA012Atu"  ,0, 5, 1},;	//"Excluir"
							{OemtoAnsi(STR0006),"QPA012BLOQ" ,0, 5   },;	//"Bloqueio"    
							{OemtoAnsi(STR0068),"QPA012CpyP" ,0, 4   },;	//"Copiar"
							{OemtoAnsi(STR0069),"QPA012CpyE" ,0, 4   },;	//"Copiar Ensaios"
							{OemtoAnsi(STR0070),"QPA012RevP" ,0, 4   },;	//"Gerar Revisão"
							{OemtoAnsi(STR0071),"QPA012RevS" ,0, 4   },;	//"Gerar Revisão Simplificada"
							{OemtoAnsi(STR0007),"QPA012LegOp",0, 5,,.F.},;	//"Legenda"
							{OemtoAnsi(STR0040),"QPA012Atu"  ,0, 9   }}	    //"Alterar Grupo"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QP010ROT")
		aRotAdic := ExecBlock("QP010ROT", .F., .F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf

Return aRotina

Function QIPA012()                   

	Local   cAlias     := " " 

	Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
	Private aSitEsp    := {}
	Private cCadastro  := " "
	Private lAPS       := Nil
	Private oQIP010Aux := QIPA010AuxClass():New()

	cCadastro := OemtoAnsi(STR0009)       //"Especificacao de Produtos" 
	lAPS      := TipoAps()                //Inicia a variavel lAPS que e utilizada no Roteiro de Operacoes do PCP
	cAlias    := "QP6"

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
	//³    6 - Altera determinados campos sem incluir novos Regs     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRotina := MenuDef()

	Aadd(aSitEsp,{"QP6->QP6_SITREV=='0'.OR.QP6->QP6_SITREV==' '","BR_VERDE"})  //Revisão Disponivel
	Aadd(aSitEsp,{"QP6->QP6_SITREV=='1'","BR_VERMELHO"})                       //Revisão Bloqueada
	Aadd(aSitEsp,{"QP6->QP6_SITREV=='2'","BR_AMARELO"})                        //Revisão Pendente  

	mBrowse(06,01,22,75,cAlias,,,,,,aSitEsp)
	dbSelectArea(cAlias)

	dbClearFilter()

Return(NIL)                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012Atu ³ Autor ³Cleber Souza           ³ Data ³11/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o status dos Documentos Anexos aos Ensaios     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA012Atu(cAlias,nReg,nOpc)					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias											  ³±±
±±³			 ³ EXPN1 = Numero do Registro								  ³±±
±±³			 ³ EXPN2 = Opcao do aRotina									  ³±±
±±³			 ³ EXPN3 = Opcao do aRotina Auxiliar (Descrição)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 		 = Nulo												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012Atu(cAlias,nReg,nOpc,nOpcX)

Local aCampos    := {}
Local aEditaveis := {}
Local aFiltroQQO := {}
Local aPagEns    := Nil
Local aPagEsp    := Nil
Local aPagFldPr  := Nil
Local aRetTela   := {}
Local aTitEns    := Nil
Local aTitEsp    := Nil
Local aTitFldPr  := Nil
Local bCancel    := Nil
Local bOk        := Nil
Local lPrototipo := IsProdProt(QP6->QP6_PRODUT)
Local nColEnd    := 0
Local nColIni    := 0
Local NFATDIV    := 1
Local nLinEnd    := 0
Local nLinIni    := 0
Local nOpcA      := 0
Local nOpcGD     := If(nOpc==3 .Or. nOpc==4 .Or. nOpc==9,GD_UPDATE+GD_INSERT+GD_DELETE,0) //Opcao utilizada na NewGetDados
Local nOpcRot    := If(!lPrototipo .Or. nOpc==3,nOpcGD,0)
Local oFldEns    := NIL
Local oFldEsp    := NIL
Local oPanelAbaA := NIL
Local oPanelEns  := NIL
Local oSizeA     := Nil
Local oSizeB     := Nil
Local oSizeC     := Nil
Local oSizeDlg   := Nil
Local oSplitAbaA := NIL
Local oSplitAbaB := NIL
Local oSplitEns  := NIL

Default nOpcX := nOpc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros utilizados na rotina							     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cPrioriR := GetMv("MV_QIPOPEP",.F.,"2") //Prioriza dados do Roteiro/Operacoes de 1 = Materiais / 2 - Quality
Private lDelSG2  := GetMv("MV_QPDELG2",.F.,.F.)
Private lIntQMT  := If(GetMV( 'MV_QIPQMT' )=="S",.T.,.F.) //Define a Integracao com o QMT 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pontos de Entradas utilizados na rotina de Especificacao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private __lQP010GRV    := ExistBlock("QP010GRV")
Private __lQP010OPE    := ExistBlock("QP010OPE")
Private __lQPA010R     := ExistBlock("QPA010R")
Private lQIP010JR      := ExistBlock("QIP010JR")
Private lQP010DEL      := ExistBlock("QP010DEL")
Private lQP010GRV      := ExistBlock("QP010GRV")
Private lQP010J11      := ExistBlock("QP010J11")
Private lQP010OPE      := ExistBlock("QP010OPE")
Private lQPA010R       := ExistBlock("QPA010R")
Private lQPATUGRV      := ExistBlock("QPATUGRV")
Private lQPATUSB1      := ExistBlock("QPATUSB1")

Private aEspecificacao := {} //Armazena os dados referentes a Especificacao do Produto
Private aGets          := {}
Private aRoteiros      := {} //Armazena os Roteiros de Operação relacionados ao Produto           
Private aTela          := {}
Private cEspecie       := "QIPA010 " //Chave que indentifica a gravacao do texto
Private lDeGrupo       := .F.
Private lOrdLab        := .F.
Private lRotMod        := .T.
Private oDlgQIP012     := NIL
Private oEncEsp        := NIL //Cabecalho da Especificacao do Produto
Private oGetEns        := NIL //Ensaios associados aos Roteiros de Operacoes
Private oGetIns        := NIL //Familia de Instrumentos
Private oGetNCs        := NIL //Nao-conformidades
Private oGetOper       := NIL //Roteiro de Operacoes Quality
Private oGetRas        := NIL //Rastreabilidade
Private oGetRot        := NIL //Roteiros relacionados a especificação 

//Define as coordenadas da Tela
Private aInfo    := {}
Private aObjects := {}
Private aPosObj  := {}
Private aSize    := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os aHeaders utilizados na Especificacao do Produto (Estrutura)	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeaderQP7 := aClone(QPA010HeadEsp(aClone(QP10FillG("QP7", Nil, Nil, Nil, Nil)))) //Prepara o aHeader com os demais campos a serem utilizados na Especificacao
Private aHeaderQP9 := aClone(QP10FillG("QP9", Nil, Nil, Nil, Nil))
Private aHeaderQQ1 := aClone(QP10FillG("QQ1", Nil, Nil, Nil, Nil))
Private aHeaderQQ2 := aClone(QP10FillG("QQ2", Nil, Nil, Nil, Nil))
Private aHeaderQQH := aClone(QP10FillG("QQH", Nil, Nil, Nil, Nil))
Private aHeaderQQK := aClone(QP10FillG("QQK", Nil, Nil, Nil, Nil))
Private aHeaderROT := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Roteiros (QQK)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosChav    := AsCan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_CHAVE" })
Private nPosDescri  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_DESCRI" })
Private nPosGruRec  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_GRUPRE" })
Private nPosLauObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_LAU_OB" })
Private nPosOpeGrp  := Ascan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_OPERGR" })
Private nPosOpeObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPE_OB" })
Private nPosOper    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPERAC" })
Private nPosRecurso := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_RECURS" })
Private nPosSeqObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_SEQ_OB" })
Private nPosSetUp   := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_SETUP" })
Private nPosTemPad  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPAD" })
Private nPosTpOper  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPOPER" })
Private nTempDes    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPDES"})
Private nTempSobre  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPSOB"})
Private nTipoDes    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPDESD" })
Private nTipoSobre  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPSOBRE"})
                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados Rastreabilidade (QQ2) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosDesc  := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_DESC" })
Private nPosRastr := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_PRODUT"})
Private nPosTipo  := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_TIPO" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o texto do produto por Operacao 					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cTexto    := Space(TamSX3("QA2_TEXTO")[1])
Private oTexto    := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Ensaios (QP7/QP8) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosAFI   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFI" })
Private nPosAFS   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFS" })
Private nPosCer   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_CERTIF"})
Private nPosDEn   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_DESENS"})
Private nPosDoc   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosDPl   := Ascan(aHeaderQP7,{|x|AllTrim(x[2])=="QP7_DESPLA"})
Private nPosEns   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSAIO"})
Private nPosFor   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_FORMUL"})
Private nPosLab   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LABOR" })
Private nPosLIC   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LIC" })
Private nPosLSC   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LSC" })
Private nPosMet   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosMin   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_MINMAX"})
Private nPosNiv   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NIVEL" })
Private nPosNom   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NOMINA"})
Private nPosObr   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSOBR"})
Private nPosPlA   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_PLAMO" })
Private nPosRvDoc := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_RVDOC" })
Private nPosSeq   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_SEQLAB"})
Private nPosTipIn := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_TIPO" })
Private nPosTxt   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP8_TEXTO" })
Private nPosUM    := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_UNIMED"})


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Instrumentos (QQ1)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aAlterIns := {}
Private aAlterRot := {}
Private nPosDescr := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_DESCR"})
Private nPosInstr := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_INSTR"})
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos referentes ao Plano de Amostrag. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nEnsaio    := 1 //Indica a posicao do Ensaio corrente 
Private nOperacao  := 1 //Indica a posicao da Operacao corrente
Private nPosAmo    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_AMOST" })
Private nPosDscPAE := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_DESCRI"})
Private nPosNivel  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NIVAMO"})
Private nPosNQA    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NQA" })
Private nPosPlano  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_PLANO"})
Private nRoteiro   := 1 //Indica a posicao do Roteiro corrente

Private nModoTela := Iif(lPriModTel, 0, nCacheTela)
Private aDataQQO  := Nil

If cPrioriR == "3" .AND. nOpcX==3 .and. nModoTela == 0 .AND. lQP010Tela//Inclusao
	aRetTela := QPA010Tela()
	If !aRetTela[CONFIRMOU_TELA]
		Return (NIL)
	EndIf
	nModoTela  := aRetTela[MODO_SELECIONADO]
	nCacheTela := nModoTela
ElseIf cPrioriR != "3" 
	nModoTela := 3
EndIf

nModoTela := Iif(!lQP010Tela .OR. !lQP010TeDB, 3, nModoTela)

If nOpcX == 3 //Inclusão
	If cPrioriR == "3"
		cCadastro := AllTrim(OemtoAnsi(STR0009)) + " [" + cValToChar(nModoTela) +"]"       //"Especificacao de Produtos" 
		cCadastro   += " - " + Capital(AllTrim(aRotina[nOpcX, 1]))
	Else
		cCadastro   := AllTrim(OemtoAnsi(STR0009)) + " - " + Capital(AllTrim(aRotina[nOpcX, 1]))//"Especificacao de Produtos" 
	EndIf
Else
	If cPrioriR == "3" .AND. lQP010TeDB
		nModoTela := QPA010TeDB()
		cCadastro := AllTrim(OemtoAnsi(STR0009)) + " [" + cValToChar(nModoTela) +"]"       //"Especificacao de Produtos" 
		cCadastro += " - " + Capital(AllTrim(aRotina[nOpcX, 1]))
	Else
		cCadastro   := AllTrim(OemtoAnsi(STR0009)) + " - " + Capital(AllTrim(aRotina[nOpc, 1]))//"Especificacao de Produtos" 
	EndIf
EndIf

bCancel := {|| lPriModTel := .T., nOpcA := 0, oDlgQIP012:End() }
bOk     := {|| lPriModTel := Iif(nOpc == 3, .F., .T.), QPA012lOK(nOpc, @nOpcA)}

//Reseta controle de re-exibição de help da QP6
lHlpLinQP6 := .T.
              
//Define os campos para alteracao na Getdados
Aadd(aAlterIns,"QQ1_INSTR")
If lIntQMT
	Aadd(aAlterIns,"QQ1_DESCR")
EndIf

//Define os campos para alteracao na Getdados (Roteiro)
Aadd(aAlterRot,"ROT_CODREC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nas NC's (QP9)		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private __cGRPPROD := CriaVar("QP6_PRODUT") //Codigo do Produto ou Grupo
Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo 
Private __cREVISAO := CriaVar("QP6_REVI") //Revisao do Produto ou Grupo
Private __cROTEIRO := CriaVar("QP6_CODREC") //Roteiro de Operacoes do Produto ou Grupo
Private __dREVISAO := CriaVar("QP6_DTINI") //Vigencia do Produto ou Grupo
Private aButtons   := {} //Rotinas especificas na barra de ferramentas  
Private nPosCla    := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_CLASSE"})
Private nPosDCl    := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESCLA"})
Private nPosDNC    := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESNCO"})
Private nPosNC     := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_NAOCON"})
Private oFldMain   := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina de inclusao do roteiro de outros produtos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F4,{ || QPATUROTF4() })         
              
//Cria as variaveis para edicao na Enchoice
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)            

If (nOpc==4 .Or. nOpc==5 .Or. nOpc==6) //Alteracao ou Exclusao

	If oQIP010Aux:especicicacaoComEnsaios(M->QP6_PRODUT, M->QP6_REVI)

		If !QIPCheckEsp(M->QP6_PRODUT,M->QP6_REVI,,,nOpc)
			HELP(" ",1,"QPCHKESPRV") //A especificacao do Grupo de produtos  nao podera ser alterada ou excluida, pois existem ordens de producoes cadastradas com a revisao vigente de produtos definidos para o Grupo. 
			Return(NIL)
		EndIf	

		//Verifica se a Especificacao possui medicoes cadastradas
		If !QPA010VerMed(M->QP6_PRODUT,M->QP6_REVI)
			Return(NIL)
		EndIf

	EndIf
	
    //Verifica se o Produto esta definido para algum Grupo		 
	If (nOpc==4) .And. !Empty(QP6->QP6_GRUPO)
		lDeGrupo := .T.		
		//Problema: STR0061 + STR0062 - Este produto pertence ao grupo de produtos ALLTRIM(QP6->QP6_GRUPO) + "/" + AllTrim(QP6->QP6_REVIGR) e não poderá ser editado integralmente via Alteração da Especificação por Produto.
		//Solução: STR0063 - Caso necessite realizar algum ajuste bloqueado via Especificação por Produto, utilize o botão 'Alterar Grupo' para alterar toda a Especificação por Grupo.
		Help(NIL, NIL, "QP010TGRU", NIL, STR0061 + " " + ALLTRIM(QP6->QP6_GRUPO) + "/" + AllTrim(QP6->QP6_REVIGR)+ " " + STR0062 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0063})
	EndIf 

	//Verifica se o Produto esta definido para algum Grupo		 
	If (nOpc==5) .And. !Empty(QP6->QP6_GRUPO)
		Help(" ",1,"QP010EXGR")  //("Não será possível excluir a especificação,pois pertence a um Grupo de Produtos.")
		Return (Nil)
	EndIf
	
	// Verifica se o Produto não está associado a algum Grupo - botão Alterar Grupo
    If (nOpc==6).and. (Empty(QP6->QP6_GRUPO) .And. Empty(QP6->QP6_REVIGR))
	   Help(" ",1,"QP010SGRU")
	   Return(NIL)
	Endif                                                            

EndIf 

//Verifica se esta alterando grupo de produto (botão alterar grupo) para Produto sem grupo
If (nOpc==9).and. (Empty(QP6->QP6_GRUPO) .And. Empty(QP6->QP6_REVIGR))
   Help(" ",1,"QP010SGRU")
   Return(NIL)
Endif  

//Botão Altera Grupo
If nOpc==9
	DbSelectArea("QQC")
	QQC->(dbSetOrder(1))
	If QQC->(dbSeek(xFilial("QQC")+QP6->QP6_GRUPO+Inverte(QP6->QP6_REVIGR)))
		QPA011Atu('QQC',QQC->(Recno()),4)
	EndIf
	QQC->(dbCloseArea())
	Return(NIL)	
EndIF


//Monta estrutuda da array dos roteiros de operacao
Aadd(aHeaderRot,{STR0016,"ROT_CODREC","@!",2,0,"QIP010GARO()",,"C","SG2",,,,".T."})   //"Roteiro"		

If IsProdProt(M->QP6_PRODUT)
	Aadd(aHeaderRot,{STR0043,"ROT_CODDES","@!",100,0,,,"C",,,,,".T."})  //"Produto Desenvolvido"
Else
	Aadd(aHeaderRot,{STR0017,"ROT_CODDES","@!",100,0,,,"C",,,,,".T."})  //"Tipo do Roteiro"
EndIf


//Calcula dimensões da Tela Principal
oSizeDlg := FwDefSize():New(.T.,,,oDlgQIP012)
oSizeDlg:AddObject( "FULL"   , 100, 100, .T., .T. ) // Totalmente dimensionavel
oSizeDlg:lProp    := .T.                            // Proporcional
oSizeDlg:aMargins := { 3, 3, 3, 3 }                 // Espaco ao lado dos objetos 0, entre eles 3
oSizeDlg:Process()                                  // Dispara os calculos

//Tela principal da Rotina
DEFINE MSDIALOG oDlgQIP012 TITLE cCadastro From oSizeDlg:aWindSize[1],oSizeDlg:aWindSize[2] to oSizeDlg:aWindSize[3],oSizeDlg:aWindSize[4] OF oMainWnd PIXEL    

aTitFldPr := {}
Aadd(aTitFldPr,OemToAnsi(STR0066)) //"Produto"
If cPrioriR != "3" .OR. cPrioriR == "3" .AND. nModoTela == 3
	Aadd(aTitFldPr,OemToAnsi(STR0064)) //"Especificação do Roteiro"
Else
	Aadd(aTitFldPr,OemToAnsi(STR0065)) //"Especificação"
EndIf

aPagFldPr := {}
Aadd(aPagFldPr,OemToAnsi("PRODUTO"))
Aadd(aPagFldPr,OemToAnsi("ESPECIFICACAO"))

//Cria FOLDER PRIMÁRIO Aba "Produto" [1] x Aba "Especificação" [2]
oFldMain            := TFolder():New(oSizeDlg:aWindSize[1],oSizeDlg:aWindSize[2],aTitFldPr,aPagFldPr,oDlgQIP012,,,,.T.,.F.,oSizeDlg:aWindSize[3],oSizeDlg:aWindSize[4])
oFldMain:bSetOption := {|nPos| Obrigatorio(aGets,aTela) }
oFldMain:Align      := CONTROL_ALIGN_ALLCLIENT


//Cria componentes para Aba "Produto" [1]
oPanelAbaA       := TPanel():New(0,0,'', oFldMain:aDialogs[1],,,,,,oDlgQIP012:nClientWidth, oDlgQIP012:nClientHeight)
oPanelAbaA:Align := CONTROL_ALIGN_ALLCLIENT

oSplitAbaA       := tSplitter():New(0, 0, oPanelAbaA, oPanelAbaA:nClientWidth, oPanelAbaA:nClientHeight, 1)
oSplitAbaA:Align := CONTROL_ALIGN_ALLCLIENT

oSizeA           := FwDefSize():New(.T.,,,oSplitAbaA)


//Cria componentes para Aba "Especificação" [2]
oPanelAbaB       := TPanel():New(0,0,'', oFldMain:aDialogs[2],,,,,,oDlgQIP012:nClientWidth, oDlgQIP012:nClientHeight)
oPanelAbaB:Align := CONTROL_ALIGN_ALLCLIENT

oSplitAbaB       := tSplitter():New(0, 0, oPanelAbaB, oPanelAbaB:nClientWidth, oPanelAbaB:nClientHeight, 1)
oSplitAbaB:Align := CONTROL_ALIGN_ALLCLIENT

oSizeB := FwDefSize():New(.T.,,,oSplitAbaB)


//Controla Exibição de Componentes conforme seleção de tela quando MV_QIPOPEP = 3
If cPrioriR != "3" .OR. cPrioriR == "3" .AND. nModoTela == 3
	oSizeA:AddObject( "CABECALHO"     , 100, 80, .T., .T. ) // Totalmente dimensionavel
	oSizeA:AddObject( "ROTEIRO"       , 100, 20, .T., .T. ) // Totalmente dimensionavel

	oSizeB:AddObject( "OPERACAO"      , 100, 20, .T., .T. ) // Totalmente dimensionavel
	oSizeB:AddObject( "FOLDER_ENSAIOS", 100, 80, .T., .T. ) // Totalmente dimensionavel

ElseIf cPrioriR == "3" .AND. nModoTela == 2
	oSizeA:AddObject( "CABECALHO"     , 100, 100, .T., .T. ) // Totalmente dimensionavel
	oSizeA:AddObject( "ROTEIRO"       , 100, 0  , .T., .T. ) // Totalmente dimensionavel

	oSizeB:AddObject( "OPERACAO"      , 100, 20 , .T., .T. ) // Totalmente dimensionavel
	oSizeB:AddObject( "FOLDER_ENSAIOS", 100, 80 , .T., .T. ) // Totalmente dimensionavel

ElseIf cPrioriR == "3" .AND. nModoTela == 1
	oSizeA:AddObject( "CABECALHO"     , 100, 100, .T., .T. ) // Totalmente dimensionavel
	oSizeA:AddObject( "ROTEIRO"       , 100, 0  , .T., .T. ) // Totalmente dimensionavel

	oSizeB:AddObject( "OPERACAO"      , 100, 0  , .T., .T. ) // Totalmente dimensionavel
	oSizeB:AddObject( "FOLDER_ENSAIOS", 100, 100 , .T., .T. ) // Totalmente dimensionavel

EndIf

oSizeA:lProp    := .T.            // Proporcional
oSizeA:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
oSizeA:Process()                  // Dispara os calculos

oSizeB:lProp    := .T.            // Proporcional
oSizeB:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
oSizeB:Process()                  // Dispara os calculos


//[1.1 - Folder Produto + Cabecalho da Especificacao do Produto]
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.T.)

If cPrioriR == "3" .AND. nModoTela != 3
	M->QP6_CODREC := QIPRotGene("QP6_CODREC")
	cRoteiro      := QIPRotGene("QP6_CODREC")
EndIf

QIPA012AuxClass():retornaCamposDaTabelaDeEspecificacacaoDeProdutosConformeMVQIPOPEPeModoEscolhido(cPrioriR, nModoTela, @aCampos, @aEditaveis)

nLinIni := oSizeA:GetDimension("CABECALHO","LININI")
nColIni := oSizeA:GetDimension("CABECALHO","COLINI")
nLinEnd := oSizeA:GetDimension("CABECALHO","LINEND")*0.60
nColEnd := oSizeA:GetDimension("CABECALHO","COLEND")*0.50

oEncEsp := MsMGet():New(cAlias,nReg,nOpc,,,,aCampos,{nLinIni,nColIni,nLinEnd,nColEnd},aEditaveis,,,,"QIP010ENOK",oSplitAbaA,,.T.,,,,,,,.T.)
oEncEsp:oBox:Align := CONTROL_ALIGN_TOP


//Prepara os dados da Especificacao do Produto para Edicao
QPA010FilEsp(M->QP6_PRODUT,M->QP6_REVI,M->QP6_CODREC)		


//[1.2 - Folder Grupo + Grid de Roteiros relacionados à Especificação]
nLinIni := oSizeA:GetDimension("ROTEIRO","LININI")
nColIni := oSizeA:GetDimension("ROTEIRO","COLINI")
nLinEnd := oSizeA:GetDimension("ROTEIRO","LINEND")
nColEnd := oSizeA:GetDimension("ROTEIRO","COLEND")

oGetRot := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcRot,{||!Empty(oGetRot:aCols[oGetRot:oBrowse:nAT,1])},IIf(nOpc != 5,{|| oQIP010Aux:validaRoteirosDaEspecificacao()}, .T.),"",aAlterRot,,9999,,,,oSplitAbaA,aHeaderROT,aRoteiros)
oGetRot:oBrowse:bChange    := {||Iif(lRotMod,FolderChange("7",nOpc), Nil)} 
oGetRot:oBrowse:bDelOk     := {||IF(nOpc!=2,FolderDelete("7"),"")}
oGetRot:oBrowse:bGotFocus  := {||FolderValid("0",lRotMod)} 
oGetRot:oBrowse:bLostFocus := {||FolderSave("7")} 
oGetRot:oBrowse:Align      := CONTROL_ALIGN_BOTTOM

If cPrioriR == "3" .AND. (nModoTela == 2 .OR. nModoTela == 1)
	oGetRot:Hide() //Oculta GRID de Roteiros
EndIF

RegToMemory("QQK",If(nOpc==3,.T.,.F.),.F.)            


//[2.1 - Folder Especificação + GRID Operações relacionadas ao Roteiro de Operação]
nLinIni := oSizeB:GetDimension("OPERACAO","LININI")
nColIni := oSizeB:GetDimension("OPERACAO","COLINI")
nLinEnd := oSizeB:GetDimension("OPERACAO","LINEND")
nColEnd := oSizeB:GetDimension("OPERACAO","COLEND")

oGetOper := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10OPLIOK()},{||QP10OPTUOK()},"",,,9999,,,,oSplitAbaB,aHeaderQQK,aEspecificacao[nRoteiro,_OPE])	
oGetOper:oBrowse:bChange    := {||Iif(lRotMod,FolderChange("1",nOpc),Nil)} 
oGetOper:oBrowse:bDelOk     := {||IF(nOpc!=2,FolderDelete("1"),"")} 
oGetOper:oBrowse:bGotFocus  := {||FolderValid("0",lRotMod),Iif(lRotMod,FolderChange("1",nOpc),Nil)} 
oGetOper:oBrowse:bLostFocus := {||FolderSave("1")} 
//oGetOper:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT - NÃO USAR, DISTORCE FUNCIONAMENTO COM MUITA ALTURA EM WEBAPP

If cPrioriR == "3" .AND. nModoTela == 1
	oGetOper:Hide() //Oculta GRID de Operações
EndIf


//[2.2 - Folder Especificação + Definição do Folder de Ensaios]
//Definição do Folder relacionada a cada Operação: "Ensaios / Rastreabilidade / Observacao da Operacao"
nLinIni := oSizeB:GetDimension("FOLDER_ENSAIOS","LININI")
nColIni := oSizeB:GetDimension("FOLDER_ENSAIOS","COLINI")
nLinEnd := oSizeB:GetDimension("FOLDER_ENSAIOS","LINEND")
nColEnd := oSizeB:GetDimension("FOLDER_ENSAIOS","COLEND")

aTitEsp := {}
Aadd(aTitEsp, OemToAnsi(STR0067)) //"Ensaios"
Aadd(aTitEsp, OemToAnsi(STR0011))   //"Rastreabilidade"
Aadd(aTitEsp, OemToAnsi(STR0012))   //"Observacao da Operacao"

aPagEsp := {}
Aadd(aPagEsp, "ENSAIOS")
Aadd(aPagEsp, "RASTREABILIDADE")
Aadd(aPagEsp, "OBSERVACAO-DA-OPERACAO")

oFldEsp := TFolder():New(nLinIni,nColIni,aTitEsp,aPagEsp,oSplitAbaB,,,,.T.,.F.,nLinEnd,nColEnd)
oFldEsp:Align:= CONTROL_ALIGN_ALLCLIENT

//Oculta Observações da Operação no Modo Apenas Ensaio e MV_QIPOPEP = 3
If cPrioriR == "3" .AND. nModoTela == 1
	oFldEsp:HidePage(3)
	oFldEsp:SetOption(1)
EndIf


//[2.2.1 - Folder Especificação + Folder de Ensaios + Aba Ensaios]
oPanelEns       := TPanel():New(nLinIni,nColIni,'', oFldEsp:aDialogs[1],,,,,,nColIni, nLinEnd)
oPanelEns:Align := CONTROL_ALIGN_ALLCLIENT

oSplitEns       := tSplitter():New(0, 0, oPanelEns, oPanelEns:nClientWidth, oPanelEns:nClientHeight, 1)
oSplitEns:Align := CONTROL_ALIGN_ALLCLIENT


//[2.2.1] Calcula dimensões Ensaios x Folder de Instrumentos [Aba Ensaios]
oSizeC := FwDefSize():New(.T.,,,oSplitEns)
oSizeC:AddObject( "ENSAIOS"            , 100, 50, .T., .T. ) // Totalmente dimensionavel
oSizeC:AddObject( "FOLDER_INSTRUMENTOS", 100, 50, .T., .T. ) // Totalmente dimensionavel
oSizeC:lProp    := .T.                                       // Proporcional
oSizeC:aMargins := { 3, 3, 3, 3 }                            // Espaco ao lado dos objetos 0, entre eles 3
oSizeC:Process()                                             // Dispara os calculos

nLinIni := oSizeC:GetDimension("ENSAIOS","LININI")
nColIni := oSizeC:GetDimension("ENSAIOS","COLINI")
nLinEnd := oSizeC:GetDimension("ENSAIOS","LINEND")
nColEnd := oSizeC:GetDimension("ENSAIOS","COLEND")


//[2.2.1.1 - Folder Especificação + Folder de Ensaios + Aba Ensaios + GRID de Ensaios]
//[GRID de Ensaios relacionada A CADA OPERAÇÃO]
oGetEns := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10ENLIOK()},{||QP10ENTUOK()},,,,9999,,,,oSplitEns,aHeaderQP7,aEspecificacao[nRoteiro,_ENS,nOperacao])
oGetEns:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGetEns:oBrowse:bChange    := {||FolderChange("4",nOpc)} 
oGetEns:oBrowse:bDelOk     := {||IF(nOpc!=2,FolderDelete("4"),"")} 
oGetEns:oBrowse:bGotFocus  := {||FolderValid("01")} 
oGetEns:oBrowse:bLostFocus := {||FolderSave("4"), QP012VldEn(.F.,@lRotMod)}
oGetEns:oBrowse:bEditCol   := {||QP010Ordena()}


//[2.2.1.2 - Folder Especificação + Folder de Ensaios + Aba Ensaios + Folder Família de Instrumentos]
//[FOLDER Relacionado A CADA ENSAIO]
aTitEns := {}
Aadd(aTitEns,OemToAnsi(STR0013)) //"Familia de Instrumentos"
Aadd(aTitEns,OemToAnsi(STR0014)) //"Nao-Conformidades"

aPagEns := {}
Aadd(aPagEns,"FAMILIA DE INSTRUMENTOS")
Aadd(aPagEns,"NAO-CONFORMIDADES")

nLinIni := oSizeC:GetDimension("FOLDER_INSTRUMENTOS","LININI")
nColIni := oSizeC:GetDimension("FOLDER_INSTRUMENTOS","COLINI")
nLinEnd := oSizeC:GetDimension("FOLDER_INSTRUMENTOS","LINEND")
nColEnd := oSizeC:GetDimension("FOLDER_INSTRUMENTOS","COLEND")

oFldEns := TFolder():New(nLinIni,nColIni,aTitEns,aPagEns,oSplitEns,,,,.T.,.F.,nLinEnd,nColEnd)
oFldEns:Align := CONTROL_ALIGN_ALLCLIENT


//[2.2.1.2.1 - Folder Especificação + Folder de Ensaios + Aba Ensaios + Folder Família de Instrumentos + Aba Família de Instrumentos]
//[GRID Familia de Instrumentos A CADA ENSAIO]
oGetIns := MsNewGetDados():New(000,000,040,380,nOpcGD,{||QP10INSLIOK()},{||QP10INSTUOK()},,aAlterIns,,9999,,,,oFldEns:aDialogs[1],aHeaderQQ1,aEspecificacao[nRoteiro,_INS,nOperacao,nEnsaio])
oGetIns:oBrowse:bGotFocus  := {||FolderValid("014")} 
oGetIns:oBrowse:bLostFocus := {||FolderSave("5")} 
oGetIns:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT


//[2.2.1.2.2 - Folder Especificação + Folder de Ensaios + Aba Ensaios + Folder Família de Instrumentos + Aba Não Conformidades]
//[GRID Nao-conformidades A CADA ENSAIO]
oGetNCs := MsNewGetDados():New(000,000,040,380,nOpcGD,{||QP10NCLIOK()},{||QP10NCTUOK()},,,,9999,,,,oFldEns:aDialogs[2],aHeaderQP9,aEspecificacao[nRoteiro,_NCO,nOperacao,nEnsaio])
oGetNCs:oBrowse:bGotFocus  := {||FolderValid("014")} 
oGetNCs:oBrowse:bLostFocus := {||FolderSave("6")} 
oGetNCs:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT


//Ponto de Entrada criado para alterar os valores dos campos de ensaio
If ExistBlock("QP010ENS") .AND. nOpc!=3
	ExecBlock("QP010ENS",.F.,.F.,{aEspecificacao[nRoteiro,_ENS,nOperacao]})
EndIf


//[2.2.2 - Folder Especificação + Folder de Ensaios + Aba Rastreabilidade]
//[GRID de Rastreabilidade a CADA OPERACAO]
oGetRas := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10RSLIOK()},{||QP10RSTUOK()},,,,9999,,,,oFldEsp:aDialogs[2],aHeaderQQ2,aEspecificacao[nRoteiro,_RAS,nOperacao])
oGetRas:oBrowse:bGotFocus  := {||FolderValid("01")} 
oGetRas:oBrowse:bLostFocus := {||FolderSave("2")}
oGetRas:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT


//[2.2.3 - Folder Especificação + Folder de Ensaios + Aba Observacao do Operacao]
//[MEMO de Observações a CADA OPERACAO]
@ 001.5,001.5 GET oTexto VAR cTexto MEMO NO VSCROLL OF oFldEsp:aDialogs[3] SIZE nFatDiv,108 PIXEL COLOR CLR_BLUE  
oTexto:bGotFocus  := {||FolderValid("01")} 
oTexto:bLostFocus := {||FolderSave("3")}  
oTexto:lReadOnly  := If(INCLUI .Or. ALTERA,.F.,.T.)   
oTexto:lActive    := .T.  
oTexto:Align := CONTROL_ALIGN_ALLCLIENT


If lDeGrupo
	oGetRot:Disable()
	oGetOper:Disable()
	oGetEns:Disable()
	oGetRas:Disable()
	oGetIns:Disable()
	oGetNCs:Disable()
EndIf


//Botao para Visualizacao do Documento anexo ao Ensaio
Aadd(aButtons,{"VERNOTA",{||If(oFldEsp:nOption<>1,Help(" ",1,"QPNVIEWDOC"),QDOVIEW(,oGetEns:aCols[oGetEns:oBrowse:nAt,nPosDoc],QA_UltRvDc(oGetEns:aCols[oGetEns:oBrowse:nAt,nPosDoc],dDataBase,.f.,.f.)))},STR0018,STR0019}) //"Visualizar o conteudo do Documento..." ### "Cont.Doc"

If slQAXA090
	Aadd(aButtons,{"VERNOTA",{|| QAXA090B(nOpc, Nil, "QP6", "Empty(M->QP6_GRUPO)") },STR0102,STR0102}) //"Arquivos Especificação"
EndIf

//Ponto de Entrada criado para mudar os botoes da enchoicebar
If ExistBlock("QP010BUT")
	aButtons := ExecBlock( "QP010BUT",.F.,.F.,{nOpc,aButtons})
EndIf


If oQIP010Aux:especicicacaoComEnsaios(M->QP6_PRODUT, M->QP6_REVI)
	If ( !QIPCheckEsp(M->QP6_PRODUT,M->QP6_REVI,,,nOpc))
		oEncEsp:Disable()  //Cabecalho da Especificacao do Produto
		oGetRot:Disable()
	EndIf
EndIf

If ( nOpc <> 2 )                                                           
	ACTIVATE MSDIALOG oDlgQIP012 ON INIT (EnchoiceBar(oDlgQIP012,bOk,bCancel,,aButtons));
								VALID If(lQIP010JR,ExecBlock("QIP010JR"),.T.)	
Else                                              
	ACTIVATE MSDIALOG oDlgQIP012 ON INIT (EnchoiceBar(oDlgQIP012,bOk,bCancel,,aButtons))
EndIf	  


	//Realiza a atualizacao da Especificacao do Produto
	If nOpcA == 1               
	      
		BEGIN TRANSACTION

			QPA012Grv(nOpc) //Atualiza a Especificacao
			
			EvalTrigger() //Processa os gatilhos
			
			//Ponto de Entrada para gravacoes diversas
			If lQPATUGRV
				ExecBlock("QPATUGRV",.F.,.F.,{nOpc})
			EndIf

			If slQAXA090
				//Exclui Relacionamentos Arquivos da Manufatura
				If nOpc == 5
					aFiltroQQO := {}
					aAdd(aFiltroQQO, {"QQO_PRODUT = ?", {{QP6->QP6_PRODUT, "S"}}})
					aAdd(aFiltroQQO, {"QQO_REVI   = ?", {{QP6->QP6_REVI  , "S"}}})

					QAXA090GEA("QP6", aFiltroQQO)

				//Atualiza Relacionamentos Arquivos da Manufatura
				ElseIf nOpc <> 2
					QAXA090GRV(aDataQQO)
				EndIf
			EndIF
						
		END TRANSACTION

	EndIf

SetKey(VK_F4,Nil)

Return nOpcA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012Grv ³ Autor ³Cleber Souza           ³ Data ³11/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os dados referentes a Especificacao do Produto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA012Grv(nOpc)			 			             		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±             EXPN2 = Opcao do aRotina Auxiliar (Descrição)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 		 = Nulo												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012Grv(nOpc)

Local aStruAlias := FWFormStruct(3, "QP6")[3]
Local lLibEsp    := .T.
Local nX         := 0

// Especificacao por Produto
If (nOpc == 3 .Or. nOpc == 4 .Or. nOpc ==6) //Inclusao ou Alteracao/Alteração Grupo

	// Atualiza o SB1 (Cadastro de Produtos);
	//³ o QP6 deve ser posicionado no momento.
	QP010AtuSB1(M->QP6_PRODUT)        
			     
	// Ponto de Entrada Final da Alteracao da Especificacao - JNJ
	If lQPATUSB1
		ExecBlock("QPATUSB1",.F.,.F.,{nOpc})
	EndIf	           
		
EndIf
		                                
//Atualizacao dos dados referentes a Especificacao do Produto 
QPAAtuEsp(M->QP6_PRODUT,M->QP6_REVI,M->QP6_CODREC," "," ",nOpc)
		

// Atualiza os dados referentes a Especificacao do Produto
RecLock("QP6",If(nOpc==3,.T.,.F.))
If (nOpc == 5)	
	QP6->(dbDelete())
EndIf

If (nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6) //Inclusao ou Alteracao/Alterar Grupo

	For nX := 1 To Len(aStruAlias)
		If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") <> "V"
			FieldPut(FieldPos(AllTrim(aStruAlias[nX,1])),&("M->"+aStruAlias[nX,1]))
		EndIf
	Next nX
EndIf

If (nOpc == 3 .OR. nOpc == 4) //Inclusao ou alteração
	QP6->QP6_FILIAL := xFilial("QP6")
	QP6->QP6_CADR   := cUserName
	QP6->QP6_DTCAD  := dDataBase

	If !lBloquear .And. nOpc == 4 .And. QP6->QP6_SITREV == "1" .And. QP6->QP6_DTINI <= dDatabase
		//STR0096 - "Especificação do produto completa."  
		//STR0097 - "Deseja liberar a revisão?"
		If MsgYesNo(STR0096 + CRLF + STR0097) 
			QP6->QP6_SITREV := "0"
		Else
			lLibEsp := .F.
		Endif
	Endif
	
	If lLibEsp
		If lBloquear
			QP6->QP6_SITREV := "1"
		ElseIf QP6->QP6_DTINI <= dDatabase
			QP6->QP6_SITREV := "0"
		Else 
			QP6->QP6_SITREV := "2"	
		Endif
	Endif

EndIf 
    
MsUnlock()               

// Grava Revisao Invertida especificacao por produto
If (nOpc == 3) 
	RecLock("QP6",.F.)
	QP6->QP6_REVINV := Inverte(QP6->QP6_REVI)
	MsUnlock()               
EndIf

// Grava o Historico da Especificacao do Produto ou Grupo
If (nOpc == 3) .Or. (nOpc == 4 .Or. nOpc == 6 ) //Inclusao/Alteracao/Alterar Grupo
	MsMM(QP6_HISTOR,,,M->QP6_MEMO1,1,,,"QP6","QP6_HISTOR")
ElseIf (nOpc == 5)	//Exclusao
	MSMM(QP6_HISTOR,,,,2)
EndIf

// Ponto de Entrada especifico para o cliente JNJ
If lQP010J11
	ExecBlock('QP010J11',.F.,.F.)
EndIf
	
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPAAtuEsp ³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os dados referentes ao Roteiro de Operacoes		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPAAtuEsp(cProduto,cRevisao,cRoteiro,lGrupo,nOpc)	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³			 ³ EXPC2 = Revisao do Produto								  ³±±
±±³			 ³ EXPC3 = Roteiro da Operacao								  ³±±
±±³			 ³ EXPC4 = Grupo de Produtos 								  ³±±
±±³			 ³ EXPC5 = Revisao do Grupo de Produtos 			  	      ³±±
±±³			 ³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPAAtuEsp(cProduto,cRevisao,cRoteiro,cGrupo,cRevGrp,nOpc)
Local aAreaAnt   := GetArea()
Local nRot       := 0
Local nOper      := 0
Local nEns       := 0
Local nIns       := 0
Local nNco       := 0
Local nRas       := 0
Local nPAE       := 0
Local nPosDelOpe := 0
Local nPosDelEns := 0         
Local nPosDelIns := 0
Local nPosDelRas := 0
Local nPosDelPAE := 0
Local cOperacao  := " "
Local cEnsaio    := " "
Local cNorma     := " " 
Local nCpo       := 0
Local cAlias     := " "
Local cConteudo  := " "
Local nDec       := 0
Local nLIE       := 0
Local nLSE       := 0
Local cVlrLIE    := " "
Local cVlrLSE    := " "
Local aTexto     := {}
Local cTxtOpe    := " "
Local cChave     := " "
Local aAreaQQK   := {} 
Local cRvDoc     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao das Operacoes 									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nRot := 1 to Len(aEspecificacao)
	
	//Armazena a Roteiro corrente
	cRoteiro := aEspecificacao[nRot,_ROT]
	
	If !Empty(cRoteiro) //Verifica se existe Roteiro Vazio
		
		For nOper := 1 to Len(aEspecificacao[nRot,_OPE])
			
			If nOper > Len(aEspecificacao[nRot,_ENS])
				Exit
			EndIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao das Operacoes									 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			//Armazena a Operacao corrente
			cOperacao := aEspecificacao[nRot,_OPE,nOper,nPosOper]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto especifico para gravacao da Atualizacao				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(FunName()) == "QIPA010"
				If lQPA010R
					If cRoteiro == "01" .And. cOperacao == "01"
						ExecBlock("QPA010R",.F.,.F.,{ALTERA})
					EndIf
				EndIf
			EndIf
			If !Empty(aEspecificacao[nRot,_OPE,nOper,nPosOper])
				
				nPosDelOpe := Len(aEspecificacao[nRot,_OPE,nOper]) //Indica se esta deletado
				
				QQK->(dbSetOrder(1))
				QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+aEspecificacao[nRot,_OPE,nOper,nPosOper]))
				
				If !aEspecificacao[nRot,_OPE,nOper,nPosDelOpe] .And. nOpc <> 5 //Exclusao
					
					If QQK->(!Eof())
						RecLock("QQK",.F.)
					Else
						RecLock("QQK",.T.)
						QQK->QQK_FILIAL := xFilial("QQK")
						QQK->QQK_CODIGO	:= cRoteiro
						QQK->QQK_OPERAC	:= cOperacao
						QQK->QQK_PRODUT := cProduto
						QQK->QQK_REVIPR	:= cRevisao
						QQK->QQK_GRUPO  := cGrupo
						QQK->QQK_REVIGR := cRevGrp
						
						//Indica que o Produto faz parte de um Grupo
						If !Empty(cGrupo)
							QQK->QQK_OPERGR := "S"
						EndIf
						
					EndIf
					
					For nCpo := 1 to Len(aHeaderQQK)
						If aHeaderQQK[nCpo,10] <> "V" .And.;
							!(AllTrim(aHeaderQQK[nCpo,2]) $ "QQK_OPERACßQQK_OPERGR")  //nao considera o campo Operacao, pois o mesmo faz poarte da chave
							QQK->(FieldPut(FieldPos(AllTrim(aHeaderQQK[nCpo,2])),;
							aEspecificacao[nRot,_OPE,nOper,nCpo]))
						EndIf
					Next nCpo
					MsUnLock() 
					FkCommit()
					
					//Atualiza a Chave de Ligacao da Operacao
					If Empty(QQK->QQK_CHAVE)
						aAreaQQK := QQK->(GetArea())
						dbSelectArea("QQK")
						dbSetOrder(2)
						cChave := QA_SXESXF("QQK","QQK_CHAVE",,2)
						ConfirmSX8()
						RestArea(aAreaQQK)
						
						RecLock("QQK",.F.)
						QQK->QQK_CHAVE := cChave
						MsUnLock()
						FkCommit()
						aEspecificacao[nRot,_OPE,nOper,nPosChav] := cChave
					EndIf
					
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao do Texto associado a Operacao                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aEspecificacao[nRot,_OPE,nOper,nPosChav]) //Se a chave nao estiver vazia
				If QQK->(!Deleted())
					cTxtOpe := aEspecificacao[nRot,_TXT,nOper]
					aTexto  := {{1,cTxtOpe}}
					
					//Atualiza o Texto relacionado a Operacao
					QA_GrvTXT(aEspecificacao[nRot,_OPE,nOper,nPosChav],cEspecie,1,aTexto)
					
				Else
					//Exclui o Texto relacionado a Operacao
					QA_DelTXT(aEspecificacao[nRot,_OPE,nOper,nPosChav],cEspecie)
					
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao dos Ensaios										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nEns := 1 to Len(aEspecificacao[nRot,_ENS,nOper])
				
				//Armazena o Ensaio corrente
				cEnsaio := aEspecificacao[nRot,_ENS,nOper,nEns,nPosEns]
				
				//Armazena a Norma de Inspecao utilizada no Plano de Amostragem
				cNorma := aEspecificacao[nRot,_ENS,nOper,nEns,nPosPlA]
				cNorma := If(!Empty(cNorma),QA_Plano(cNorma),cNorma)
				
				//Verifica se o Ensaio esta em branco
				If !Empty(aEspecificacao[nRot,_ENS,nOper,nEns,nPosEns])
					
					nPosDelEns := Len(aEspecificacao[nRot,_ENS,nOper,nEns]) //Indica se esta deletado
					
					QP1->(dbSetOrder(1))
					QP1->(dbSeek(xFilial("QP1")+aEspecificacao[nRot,_ENS,nOper,nEns,nPosEns]))
					If QP1->QP1_TPCART <> "X" //Mensuraveis
						cAlias    := "QP7"
						cConteudo := "QP8_TEXTOßQQK_OPERGR"
					Else //Texto
						cAlias    := "QP8"
						cConteudo := "QP7_UNIMEDßQP7_NOMINAßQP7_AFIßQP7_AFSßQP7_LICßQP7_LSCßQP7_MINMAXßQQK_OPERGR"
					EndIf
					
					(cAlias)->(dbSetOrder(1))
					(cAlias)->(dbSeek(xFilial(cAlias)+cProduto+cRevisao+cRoteiro+cOperacao+aEspecificacao[nRot,_ENS,nOper,nEns,nPosEns]))
					
					//Verifica se o Ensaio nao esta marcado para exclusao
					If !aEspecificacao[nRot,_ENS,nOper,nEns,nPosDelEns] .And. nOpc <> 5 //Exclusao
						
						If !Empty(aEspecificacao[nRot,_ENS,nOper,nEns,nPosDoc])
				    	    cRvDoc := QA_UltRvDc(aEspecificacao[nRot,_ENS,nOper,nEns,nPosDoc],dDataBase,.F.,.F.)
						EndIF
						
						If (cAlias)->(!Eof())
							RecLock(cAlias,.F.)
						Else
							RecLock(cAlias,.T.)
							(cAlias)->&(cAlias+"_FILIAL") := xFilial(cAlias)
							(cAlias)->&(cAlias+"_PRODUT") := cProduto
							(cAlias)->&(cAlias+"_REVI")   := cRevisao
							(cAlias)->&(cAlias+"_CODREC") := cRoteiro
							(cAlias)->&(cAlias+"_OPERAC") := cOperacao
							(cAlias)->&(cAlias+"_GRUPO")  := cGrupo
							(cAlias)->&(cAlias+"_REVIGR") := cRevGrp  
						EndIf
						
						For nCpo := 1 to Len(aHeaderQP7)
							If aHeaderQP7[nCpo,10] <> "V"
								If !(AllTrim(aHeaderQP7[nCpo,2]) $ cConteudo)
									(cAlias)->(FieldPut(FieldPos(cAlias+SubStr(AllTrim(aHeaderQP7[nCpo,2]),4)),;
									aEspecificacao[nRot,_ENS,nOper,nEns,nCpo]))
								EndIf
							EndIf
						Next nCpo  
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Alteração ececutada para  corrigir problemas  na  integridade - FNC 003128  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(aEspecificacao[nRot,_ENS,nOper,nEns,nPosDoc])
				    	    (cAlias)->&(cAlias+"_RVDOC")  := cRvDoc
						EndIF
						  
						MsUnLock()
						FkCommit()
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula e atualiza o LIE e LSE							     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cAlias == "QP7"
							                
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Efetua e Atualiza o Calculo em polegadas					 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cVlrLIE := ""
							cVlrLSE := ""
							nLIE    := 0
							nLSE    := 0
							If At(":",AllTrim(QP7->QP7_NOMINA)) > 0
								If QP7_MINMAX $ "1.2"   //Minimo ou Minimo e Maximo
									cVlrLIE := CalcHora(aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom],aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFI],"I")
								EndIf
								If QP7_MINMAX $ "1.3"   //Maximo ou Minimo e Maximo
									cVlrLSE := CalcHora(aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom],aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFS],"S")
								EndIF
							ElseIf At('i',AllTrim(QP7->QP7_NOMINA)) > 0
								If QP7_MINMAX $ "1.2"   //Minimo ou Minimo e Maximo
									cVlrLIE := qCalPol({aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom],aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFI]},1,QP7->QP7_LIE)
								EndIF
								If QP7_MINMAX $ "1.3"   //Maximo ou Minimo e Maximo
									cVlrLSE := qCalPol({aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom],aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFS]},1,QP7->QP7_LSE)
								EndIf
							Else
								If QP7_MINMAX $ "1.2"   //Minimo ou Minimo e Maximo
									nLIE    := SuperVal(aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom])+SuperVal(aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFI])
								EndIF
								If QP7_MINMAX $ "1.3"   //Maximo ou Minimo e Maximo
									nLSE    := SuperVal(aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom])+SuperVal(aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFS])
								EndIf
								If cPaisLoc <> "MEX"
								    nDec    := If(","$AllTrim(QP7->QP7_NOMINA),Len(AllTrim(QP7->QP7_NOMINA))-At(",",AllTrim(QP7->QP7_NOMINA)),0)
								    cVlrLIE := AllTrim(StrTran(Str(nLIE,TamSX3("QP7_LIE")[1],nDec),".",","))
								    cVlrLSE := AllTrim(StrTran(Str(nLSE,TamSX3("QP7_LSE")[1],nDec),".",","))
								Else
							       nDec     := If("."$AllTrim(QP7->QP7_NOMINA),Len(AllTrim(QP7->QP7_NOMINA))-At(".",AllTrim(QP7->QP7_NOMINA)),0)  	
								   cVlrLIE  := AllTrim(StrTran(Str(nLIE,TamSX3("QP7_LIE")[1],nDec),",","."))
								   cVlrLSE  := AllTrim(StrTran(Str(nLSE,TamSX3("QP7_LSE")[1],nDec),",","."))
							    Endif
							EndIf
							
							RecLock("QP7",.F.)
							QP7->QP7_LIE := cVlrLIE
							QP7->QP7_LSE := cVlrLSE
							MsUnlock()
							
						EndIf
					Else
						If (cAlias)->(!Eof())
							RecLock(cAlias,.F.)
							dbDelete()
							MsUnLock()
						EndIf
						
					EndIf
					
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a Familia de Instrumentos							 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nIns := 1 to Len(aEspecificacao[nRot,_INS,nOper,nEns])
					
					If !Empty(aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosInstr])
						
						nPosDelIns := Len(aEspecificacao[nRot,_INS,nOper,nEns,nIns]) //Indica se esta deletado
						
						QQ1->(dbSetOrder(3))
						QQ1->(dbSeek(xFilial("QQ1")+cProduto+cRevisao+cRoteiro+cOperacao+cEnsaio+aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosInstr]))
						
						If !aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosDelIns] .And. nOpc <> 5 //Exclusao
							
							If QQ1->(!Eof())
								RecLock("QQ1",.F.)
							Else
								RecLock("QQ1",.T.)
								QQ1->QQ1_FILIAL	:= xFilial("QQ1")
								QQ1->QQ1_PRODUT	:= cProduto
								QQ1->QQ1_REVI	:= cRevisao
								QQ1->QQ1_ROTEIR	:= cRoteiro
								QQ1->QQ1_OPERAC	:= cOperacao
								QQ1->QQ1_ENSAIO	:= cEnsaio
								QQ1->QQ1_INSTR	:= aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosInstr]
								QQ1->QQ1_GRUPO  := cGrupo
								QQ1->QQ1_REVGRP := cRevGrp
							EndIf
							QQ1->QQ1_DESCR := aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosDescr]
							MsUnLock()
							
						Else
							If QQ1->(!Eof())
								RecLock("QQ1",.F.)
								dbDelete()
								MsUnLock()
							EndIf
							
						EndIf
						
					EndIf
					
				Next nIns
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza as Nao-Conformidades associadas					 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nNco := 1 to Len(aEspecificacao[nRot,_NCO,nOper,nEns])
					
					If !Empty(aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosNc])
						
						nPosDelNco := Len(aEspecificacao[nRot,_NCO,nOper,nEns,nNco]) //Indica se esta deletado
						
						QP9->(dbSetOrder(3))
						QP9->(dbSeek(xFilial("QP9")+cProduto+cRevisao+cRoteiro+cOperacao+cEnsaio+aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosNc]))
						
						If !aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosDelNco]	 .And. nOpc <> 5 //Exclusao
							If QP9->(!Eof())
								RecLock("QP9",.F.)
							Else
								RecLock("QP9",.T.)
								QP9->QP9_FILIAL	:= xFilial("QP9")
								QP9->QP9_PRODUT	:= cProduto
								QP9->QP9_REVI	:= cRevisao
								QP9->QP9_ROTEIR	:= cRoteiro
								QP9->QP9_OPERAC	:= cOperacao
								QP9->QP9_ENSAIO	:= cEnsaio
								QP9->QP9_NAOCON := aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosNc]
								QP9->QP9_GRUPO  := cGrupo
								QP9->QP9_REVIGR := cRevGrp
							EndIf
							QP9->QP9_CLASSE := aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosCla]
							MsUnLock()
							
						Else
							If QP9->(!Eof())
								RecLock("QP9",.F.)
								dbDelete()
								MsUnLock()
							EndIf
							
						EndIf
						
					EndIf
					
				Next nNco
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o Plano de Amostragem por Ensaio					 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nPAE := 1 to Len(aEspecificacao[nRot,_PAE,nOper,nEns])
					
					nPosDelPAE := Len(aEspecificacao[nRot,_PAE,nOper,nEns,nPAE]) //Indica se esta deletado
					
					QQH->(dbSetOrder(1))
					QQH->(dbSeek(xFilial("QQH")+cProduto+cRevisao+cRoteiro+cOperacao+cEnsaio))
					
					If !aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosDelPAE] .And. nOpc <> 5 //Exclusao
						
						If !Empty(aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNQA]) .Or. ;
							( Empty(aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNQA]) .And. ("TEXTO" $ aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosPlano]) )
							If QQH->(!Eof())
								RecLock("QQH",.F.)
							Else
								RecLock("QQH",.T.)
								QQH->QQH_FILIAL	:= xFilial("QQH")
								QQH->QQH_PRODUT	:= cProduto
								QQH->QQH_REVI	:= cRevisao
								QQH->QQH_CODREC	:= cRoteiro
								QQH->QQH_OPERAC	:= cOperacao
								QQH->QQH_ENSAIO	:= cEnsaio
								QQH->QQH_GRUPO  := cGrupo
								QQH->QQH_REVIGR := cRevGrp
							EndIf
							QQH->QQH_PLANO  := aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosPlano]
							QQH->QQH_NQA    := aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNQA]
							QQH->QQH_NIVAMO := aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNivel]
							If QQH->QQH_PLANO == "INTERN"
								QQH->QQH_AMOST := "PI"
							Else
								QQH->QQH_AMOST  := aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosAmo]
							Endif
							If Empty(aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNQA]) .And. ("TEXTO" $ aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosPlano])
								QP1->(dbSetOrder(1))
								QP1->(dbSeek(xFilial("QP1")+aEspecificacao[nRot,_ENS,nOper,nEns,1]))
								If QP1->QP1_TPCART <> "X" //Mensuraveis
									QQH->QQH_DESCRI := QP7->QP7_DESPLA
								Else //Texto
									QQH->QQH_DESCRI := QP8->QP8_DESPLA
								EndIf
							EndIf	
							
							MsUnLock()
						EndIf
						
					Else
						If QQH->(!Eof())
							RecLock("QQH",.F.)
							dbDelete()
							MsUnLock()
						EndIf
					EndIf
					
				Next nPAE
				
			Next nEns
			
			//Exclusao do roteiro de operações
			If !Empty(aEspecificacao[nRot,_OPE,nOper,nPosOper])
				
				nPosDelOpe := Len(aEspecificacao[nRot,_OPE,nOper]) //Indica se esta deletado
				
				QQK->(dbSetOrder(1))
				QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+aEspecificacao[nRot,_OPE,nOper,nPosOper]))
				
				If aEspecificacao[nRot,_OPE,nOper,nPosDelOpe] .Or. nOpc == 5 //Exclusao
					
					//Verifica se ira excluir tambem a operação da tabela SG2
					If lDelSG2					
						dbSelectArea("SG2")
						dbSetOrder(1)
						If dbSeek(xFilial("SG2")+cProduto+cRoteiro+aEspecificacao[nRot,_OPE,nOper,nPosOper])
							RecLock("SG2",.F.)                                   
							dbDelete()
							MsUnLock()						
						EndIF
					EndIF
		
					If QQK->(!Eof())
						RecLock("QQK",.F.)
						dbDelete()
						MsUnLock()
					EndIf
				EndIF
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao da Rastreabilidade								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nRas := 1 to Len(aEspecificacao[nRot,_RAS,nOper])
				
				If !Empty(aEspecificacao[nRot,_RAS,nOper,nRas,nPosRastr])
					
					nPosDelRas := Len(aEspecificacao[nRot,_RAS,nOper,nRas]) //Indica se esta deletado
					
					QQ2->(dbSetorder(1))
					QQ2->(dbSeek(xFilial("QQ2")+cProduto+cRevisao+cRoteiro+cOperacao+aEspecificacao[nRot,_RAS,nOper,nRas,nPosRastr]))
					
					If !aEspecificacao[nRot,_RAS,nOper,nRas,nPosDelRas] .And. nOpc <> 5 //Exclusao
						
						If QQ2->(!Eof())
							RecLock("QQ2",.F.)
						Else
							RecLock("QQ2",.T.)
							QQ2->QQ2_FILIAL := xFilial("QQ2")
							QQ2->QQ2_CODIGO	:= cProduto
							QQ2->QQ2_REVI	:= cRevisao
							QQ2->QQ2_ROTEIR	:= cRoteiro
							QQ2->QQ2_OPERAC	:= cOperacao
							QQ2->QQ2_GRUPO  := cGrupo
							QQ2->QQ2_REVIGR := cRevGrp
						EndIf
						
						For nCpo := 1 to Len(aHeaderQQ2)
							If aHeaderQQ2[nCpo,10] <> "V"
								QQ2->(FieldPut(FieldPos(AllTrim(aHeaderQQ2[nCpo,2])),;
								aEspecificacao[nRot,_RAS,nOper,nRas,nCpo]))
							EndIf
						Next nCpo
						MsUnLock()
						
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de Entrada para exclusao do QQ2 (especifico JNJ)		 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lQP010DEL
							ExecBlock("QP010DEL",.F.,.F.,{cProduto,cRevisao,cRoteiro,.F.})
						Else
							If QQ2->(!Eof())
								RecLock("QQ2",.F.)
								dbDelete()
								MsUnLock()
							EndIf
						EndIf
						
					EndIf
					
				EndIf
				
			Next nRas
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. para Atualizacao da Especificacao						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(FunName()) == "QIPA010"
				If lQP010GRV
					ExecBlock("QP010GRV",.F.,.F.,{cProduto,cRevisao,cRoteiro,cOperacao})
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. para exclusao do QQ2, apos excluir a operacao corrente  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QQK->(deleted())
				If AllTrim(FunName()) == "QIPA010"
					If lQP010OPE
						ExecBlock("QP010OPE",.F.,.F.,{cProduto,cRoteiro,cOperacao,cRevisao})
					EndIf
				EndIf
			EndIf
			
		Next nOper
		
	EndIf
	
Next nRot
                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao QIP x PCP										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
QAtuMatQIP(cProduto,cRevisao,cRoteiro,"QIP",If(nOpc==5,.T.,.F.),cPrioriR)


RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012BLOQ ³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina que bloqueia a especificação evitando o uso.	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA012BLOQ()	    										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA0120													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012BLOQ()

Local aArea    := QP6->(GetArea())
Local cMsg     := ""
Local cProduto := ""
Local lLib     := .T.
Local nRecQP6  := 0

If QP6->QP6_SITREV == "1"

	// Vericica se existem especificação vigente.
	nRecQP6   := QP6->(Recno())	
	cProduto  := QP6->QP6_PRODUT
	cRev      := QP6->QP6_REVI

	If oQIP010Aux:verificaSeEspecificacaoDeProdutoPossuiOperacaoSemEnsaio(cProduto, cRev)
	 
		dbSelectArea("QP6")
		QP6->(dbSetOrder(1))
		If QP6->(dbSeek(xFilial("QP6")+cProduto+INVERTE(SOMA1(cRev))))
			If QP6->QP6_DTINI <= dDataBase
				lLib := .F.
			EndIF
		ElseIf QP6->(dbSeek(xFilial("QP6")+cProduto+INVERTE(cRev)))
			If QP6->QP6_DTINI > dDataBase
				//STR0098 - Desbloqueio Não Permitido
				//STR0099 - Data de Vigência da especificação
				//STR0100 - é maior que a data de atual do sistema
				//STR0101 - "Liberação será feito somente com data de vigência menor ou igual a data atual do sistema."
				Help(NIL, NIL, STR0098, NIL, STR0099 + cValToChar(QP6->QP6_DTINI) + STR0100 + cValToChar(dDataBase) + ".", 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0101})
				Return(NIL)
			EndIF
		EndIF
		
		If lLib

			QP6->(dbGoTo(nRecQp6))
			cMsg := STR0023+CHR(13)+CHR(10) //"Esta sendo realizado a Liberação da Especificação do Produto : "
			cMsg += STR0024 + QP6->QP6_PRODUT+CHR(13)+CHR(10) //"Produto : "
			cMsg += STR0025 + QP6->QP6_REVI+CHR(13)+CHR(10) //"Revisao : "
			cMsg += STR0026 + QP6->QP6_DESCPO+CHR(13)+CHR(10) //"Descrição : "
			cMsg += STR0027 //"Deseja confirmar a liberação dessa especificação ?" 
			
			If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0028)) //"Atencao"
				dbSelectArea("QP6")
				RecLock("QP6",.f.)
				QP6->QP6_SITREV := "0"
				MsUnlock()
			EndIF
		Else   
			QP6->(dbGoTo(nRecQp6))
			HELP(" ",1,"A010BLOQ")
		EndIF
	EndIf
Else
	
	cMsg := STR0029+CHR(13)+CHR(10) //"Esta sendo realizado o Bloqueio da Especificação do Produto : "
	cMsg += STR0024 + QP6->QP6_PRODUT+CHR(13)+CHR(10) //"Produto : "
	cMsg += STR0025 + QP6->QP6_REVI+CHR(13)+CHR(10) //"Revisao : "
	cMsg += STR0026 + QP6->QP6_DESCPO+CHR(13)+CHR(10) //"Descrição : "
	cMsg += STR0030 //"Deseja confirmar o bloqueio dessa especificação ?"
	
	If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0028)) //"Atencao"
		dbSelectArea("QP6")
		RecLock("QP6",.f.)
		QP6->QP6_SITREV := "1"
		MsUnlock()
	EndIf
	
EndIF 

RestArea(aArea)
          
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A010VPro   ³ Autor ³ Cicero Cruz     	  ³ Data ³ 04/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza descricao do Produto de acordo com a opcao escolhida³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                               						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP010VPro()  
Local aAreas := {QP6->(GetArea()), SB1->(GetArea())}
Local cDes   := Space(TamSX3("B1_DESC")[1])  
Local lRet   := .T.
DEFAULT lPrimeira := .F.
DEFAULT cProdPosi := QP6->QP6_PRODUT

PergQPM010()

If lPrimeira
	if MV_PAR01 <> QP6->QP6_PRODUT
		MV_PAR03 := QP6->QP6_CODREC
		MV_PAR04 := QP6->QP6_CODREC
	endif
	lPrimeira := .F.
EndIf

If (sMvPar05 == 1)     //Informado pelo Operador
	sMvPar06 := cDes
ElseIf (sMvPar05 == 2) //Produto Origem
	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cProdPosi))
		sMvPar06 := SB1->B1_DESC
	EndIf
ElseIf (sMvPar05 == 3) //Produto Destino
	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+MV_PAR01))
		sMvPar06 := SB1->B1_DESC
	Else
		sMvPar06 := cDes
		sMvPar05 := 1
	EndIf
EndIf       

aEval(aAreas, {|x| RestArea(x)})
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A010VPro   ³ Autor ³ Cicero Cruz     	  ³ Data ³ 05/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o roteiro origem e valido                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                               						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP012VROT(cProd, cRev, cRot, cOper) 
Local lRet   := .T. 
Local aArea  := GetArea() 

Default cProd := QP6->QP6_PRODUT
Default cRev  := QP6->QP6_REVI
Default cRot  := MV_PAR01
Default cOper := MV_PAR02

dbSelectArea("QP7")
dbSetOrder(1)
If !dbSeek(xFilial("QP7")+cProd+cRev+cRot+cOper)
	dbSelectArea("QP8")
	dbSetOrder(1)
	If !dbSeek(xFilial("QP8")+cProd+cRev+cRot+cOper)
		MsgAlert(STR0036)
		lRet:=.F.
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A010VPro   ³ Autor ³ Cicero Cruz     	  ³ Data ³ 04/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza descricao do Produto de acordo com a opcao escolhida³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                               						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP010VROT()  
Local lRet   := .T.

PergQPM010()

If !Empty(Alltrim(sMvPar07))
	// Formata o codigo do Roteiro
	sMvPar07 := Strzero(val(sMvPar07),2)
	// Consiste se o Roteiro faz parte dos roteiros a serem copiados
	If !(sMvPar07 >= MV_PAR03 .AND. sMvPar07 <= MV_PAR04)
	    sMvPar07 := "  "
	    lRet := .F.  
	    MsgAlert(STR0035)
	EndIf       
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012LegOp ³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas nas OPs				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QP012Legend()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012LegOp() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0031)}) //"Revisão Disponivel"  
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0032)}) //"Revisão Bloqueada"  
Aadd(aLegenda,{"BR_AMARELO", OemToAnsi(STR0033)}) //"Revisão Pendente" 

BrwLegenda(OemtoAnsi(STR0009) ,OemToAnsi(STR0034),aLegenda) //"Status das Operações"
Return(NIL) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012TDup³ Autor ³Cicero Odilio Cruz     ³ Data ³02/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Seleciona o Tipo de Duplicacao (Especificacao/Ensaios)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA012TDup()												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012TDup()
Local lOk       := .F.
Local nOpc		:= 0
Local nRadio	:= 1
Local oDlg      := NIL
Local oRadio    := NIL

DEFAULT lPrimeira := .F.

DEFINE MSDIALOG oDlg FROM	35,37 TO 140,300 TITLE OemToAnsi(STR0037) PIXEL	//" Tipo de Duplicacao "

@ 005,005 TO 040,080 OF oDlg PIXEL
@ 013,011 RADIO oRadio VAR nRadio 3D SIZE 050,011 PROMPT OemToAnsi(STR0038), OemToAnsi(STR0039) OF oDlg PIXEL //"Especificacao" ### "Ensaios"

DEFINE SBUTTON FROM 024, 090 TYPE 1 ENABLE OF oDlg Action Eval({||nOpc:=1,oDlg:End()})

ACTIVATE MSDIALOG oDlg Centered         

lOk := If(nRadio==1,.T.,.F.)

If nOpc == 1
	lPrimeira := .T.
EndIf

Return(lOk)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QP012VldEn ³ Autor ³Adalberto mendes Neto ³ Data ³04/09/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o aCols, campo Formula, quando o ensaio for Mensu-  ³±±
±±³          ³ ravel e Calculado e o campo Nominal, quando o enasio for do³±±
±±³          ³ tipo Mensuravel. Executada no botao OK                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QP012VldEn()	  										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ lRet       									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP012VldEn(lMsg,lRotMod)

Local lRet 		:= .T.
Local lHelp		:= .F.
Local nForEns 	:= 0 
Local cEnsaio 	:= ""
Local cFormula	:= ""                               
Local nNominal	:= 0
Local lTipo 	:= .F.

Default lMsg := .T. 

For nForEns := 1 to Len(oGetEns:aCols)    
	If !oGetEns:aCols[nForEns,Len(oGetEns:aCols[nForEns])]
		cEnsaio := oGetEns:aCols[nForEns,nPosEns]  
		cFormula:= oGetEns:aCols[nForEns,nPosFor]
		nNominal:= oGetEns:aCols[nForEns,nPosNom]  
		QP1->(dbSetOrder(1))
		QP1->(dbSeek(xFilial("QP1")+cEnsaio)) 
		If QP1->QP1_TIPO == "C"
			lTipo := .T.
		EndIf
		If (lTipo .AND. Empty(cFormula)) .Or. (QP1->QP1_TPCART == "D" .AND. Empty(nNominal))
			lHelp := .T.
		    lRet  := .F.
		    Exit
		Endif
	Endif 
	
	If lRet
		QP1->(dbSetOrder(1))
		QP1->(dbSeek(xFilial("QP1")+oGetEns:aCols[oGetEns:oBrowse:nAt,nPosEns]))
		cCarta 	 := QP1->QP1_CARTA
		cTpCarta := QP1->QP1_TPCART
		nQtdEns  := QP1->QP1_QTDE
		lTipo := .F.
	EndIf   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao dos Ensaios calculados							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QP1->QP1_TIPO == "C"
		lTipo := .T.
	EndIf 
	
	If !oGetEns:aCols[nForEns,Len(oGetEns:aCols[nForEns])] .AND. lTipo
		lRet := QP010ValCalc(lRet, cFormula, lTipo, cTpCarta, nPosEns, cCarta, nQtdEns, lMsg)
	EndIf
	
	lTipo := .F.
Next  

If ValType(lRotMod) == "L"
	lRotMod := lRet
EndIf

If lHelp
	Help(" ",1,"QA_CPOOBR")
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcaao	 ³QPA012ROT  ³ Autor ³ Sergio S. Fuzinaka   ³ Data ³ 27.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se existe o Roteiro de Operacoes para determinada  ³±±
±±³          ³Especificacao do Produto.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012Rot()

Local lRet		:= .F.
Local lFound	:= .F.
Local aArea		:= GetArea()
Local aAreaQQK	:= QQK->(GetArea())
Local aAreaSG2

If IntQIP()
	aAreaSG2 := SG2->(GetArea()	)
	dbSelectArea("SG2")
	dbSetOrder(1)
	If dbSeek(xFilial("SG2")+mv_par01+mv_par02)
		lRet	:= .T.
		lFound	:= .T.
	Endif
Endif

If !lFound
	dbSelectArea("QQK")
	dbSetOrder(1)
	If dbSeek(xFilial("QQK")+mv_par01)
		While !Eof() .And. QQK->(QQK_FILIAL+QQK_PRODUT) == xFilial("QQK")+mv_par01
			If QQK->QQK_CODIGO == mv_par02
				lRet	:= .T.
				lFound	:= .T.
				Exit
			Endif
			dbSkip()
		Enddo
	Endif
Endif

If !lFound
	MsgAlert(OemToAnsi(STR0041),Upper(OemToAnsi(STR0028)))		//Produto / Roteiro nao cadastrado
Endif

If IntQIP()
	RestArea( aAreaSG2 )
Endif

RestArea( aAreaQQK )
RestArea( aArea )

Return( lRet )          

/*/{Protheus.doc} PergQPM010 
Proteção Error.log Chamadas Pergunte QPM010 com dicionário imcompatível
@author brunno.costa
@since 28/02/2022
@version 1.0
/*/
Static Function PergQPM010()
	If ValType(mv_par05) == "N"
		sMvPar05 := mv_par05
		sMvPar06 := mv_par06
		sMvPar07 := mv_par07
		sMvPar08 := mv_par08
	Else
		If ValType(mv_par08) == "N"
			sMvPar05 := mv_par08
		Else
			sMvPar05 := 1
		EndIf
		sMvPar06 := mv_par05
		sMvPar07 := mv_par06
		sMvPar08 := mv_par07
	EndIf

Return

/*/{Protheus.doc} QPA012lOK 
Validação bOk QPA012Atu
@author brunno.costa
@since 03/03/2022
@version 1.0
@param 01 - nOpc , número, valor da opção escolhida no browse da tela, conforme Static Function MenuDef()
@param 02 - nOpcA, número, retorna por referência nOpcA, sendo:
                          1 -> Realiza a atualizacao da Especificacao do Produto;
						  0 -> Cancela a operação
/*/

Static Function QPA012lOK(nOpc, nOpcA)
	
	Local lReturn 	 := .T.

	If nOpc == 2 			
		nOpcA := 0
		oDlgQIP012:End()

	ElseIf nOpc == 5

		FolderSave("1234567")
		
		lReturn := .T.

		nOpcA := 1
		oDlgQIP012:End()

	Else
		FolderSave("1234567")
		
		If !Obrigatorio(aGets, aTela)
			lReturn := .F.
		EndIf

		If lReturn .AND. nOpc != 5
			lReturn := oQIP010Aux:validaRoteirosDaEspecificacao() .AND. QP012VldEn() .And. QP10ValIns()
		EndIf

		If lReturn					
			nOpcA := 1
			oDlgQIP012:End()

		Else
			nOpcA := 0

		EndIf

	EndIf

Return lReturn

/*/{Protheus.doc} QIPA012AuxClass
Classe agrupadora de métodos auxiliares do QIPA012
@author rafael.kleestadt
@since 05/04/2023
@version 1.0
/*/
CLASS QIPA012AuxClass FROM LongNameClass

    METHOD new() Constructor

    METHOD atribuiProximaRevisaoParametroCopia()
	METHOD compativelRevisaoApenasEnsaios()
	METHOD compativelRevisaoOperacoesEEnsaios()
	METHOD copia()
	METHOD copiaEnsaios()
    METHOD criaTelaParametrosCopia()
	METHOD criaTelaParametrosCopiaEnsaios()
	METHOD geraRevisao()
	METHOD geraRevisaoSimplificada()
	METHOD retornaCamposDaTabelaDeEspecificacacaoDeProdutosConformeMVQIPOPEPeModoEscolhido(cPrioriR, nModoTela, aCampos, aEditaveis)
    METHOD retornaDescricaoProdutoDestino(cProduto, cProdPosi)
	METHOD retornaPercentualUsoRoteiroEOperacaoUnicosGenericos(cProduto, cRevisao)
	METHOD retornaPercentualUsoRoteiroEOperacaoUnicosNaoGenericos(cProduto, cRevisao)
	METHOD retornaPercentualUsoRoteiroUnicoGenerico(cProduto, cRevisao)
	METHOD retornaPercentualUsoRoteiroUnicoNaoGenerico(cProduto, cRevisao)
	METHOD retornaProximaRevisao(cProduto, cRevisao)
	METHOD validaBaseCopiaEnsaios()
    Method validaDestinoCopiaDisponivel(cProduto, cRevisao)
	METHOD validaDestinoCopiaEnsaios()
    METHOD validaPlanosDeAmostragem(cCodProdut, cRevEspPro)
	METHOD validaRoteiroPrimarioCopia()
    METHOD validaSeProdutoPertenceAGrupodeEspecificacao(cProduto, cRevisao)
	METHOD whenOperacaoGenerica(cProduto, cRevisao, cRoteiro)
	METHOD whenRoteiroGenerico(cProduto, cRevisao)
	METHOD possuiOperacoesOuEnsaios(cProduto, cRevisao)
    
ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author rafael.kleestadt
@since 05/04/2023
@version 1.0
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
/*/
METHOD new() CLASS QIPA012AuxClass
Return Self

/*/{Protheus.doc} criaTelaParametrosCopia
Monta tela de parametos para a cópia da especificação completa
@author rafael.kleestadt
@since 06/04/2023
@version 1.0
@return lReturn, lógico, indica se os parâmetros foram confirmados (.T.) ou se a operação foi cancelada (.F.)
/*/
Method criaTelaParametrosCopia() CLASS QIPA012AuxClass

	Local aPergs     := {}
	Local lReturn    := .F.
	Local nTamaProdu := GetSx3Cache("QP6_PRODUT", "X3_TAMANHO")
	Local nTamaRevis := GetSx3Cache("QP6_REVI"  , "X3_TAMANHO")
	Local nTamaRotei := GetSx3Cache("QP6_CODREC", "X3_TAMANHO")

	Private oSelf    := QIPA012AuxClass():New()

	DEFAULT aParamDup := {}

	/* 	[1]: Tipo do parâmetro  (numérico) -> 1 - MsGet
		[2]: Descrição
		[3]: String contendo o inicializador do campo
		[4]: String contendo a Picture do campo
		[5]: String contendo a validação
		[6]: Consulta F3
		[7]: String contendo a validação When
		[8]: Tamanho do MsGet
		[9]: Flag .T./.F. Parâmetro Obrigatório ? */
	
	aAdd(aPergs, {1, STR0046, SPACE(nTamaProdu), , 'NaoVazio() .And. oSelf:atribuiProximaRevisaoParametroCopia()',  "QP61" , "", 100       , .T.}) //"Produto Destino" 
	aAdd(aPergs, {1, STR0047, SPACE(nTamaRevis), , 'oSelf:validaDestinoCopiaDisponivel()'                        ,     ""  , "", nTamaRevis, .T.}) //"Revisão Destino" 
	aAdd(aPergs, {1, STR0048, SPACE(nTamaRotei), , '.T.'                                                         ,     ""  , "", nTamaRotei, .F.}) //"Roteiro De"      
	aAdd(aPergs, {1, STR0049, SPACE(nTamaRotei), , '.T.'                                                         ,     ""  , "", nTamaRotei, .F.}) //"Roteiro Até"     
	aAdd(aPergs, {1, STR0050, SPACE(nTamaRotei), , 'oSelf:validaRoteiroPrimarioCopia()'                          ,     ""  , "", nTamaRotei, .F.}) //"Roteiro Primário"
	aAdd(aPergs, {2, STR0072, STR0073, {STR0074, STR0073 }, 40,"",.T.}) //"Mescla Roteiro" # "Não" # "Sim" # "Não"
	aAdd(aPergs, {9, STR0075, 200, 30, .F.}) //"Mescla Roteiro: agrega no roteiro destino existente as operações inexistentes."
	If FWAliasIndic("QQO", .F.)
		aAdd(aPergs, {2, STR0103, NIL, {STR0074, STR0073 }, 40, ".T.", .F.}) // STR0103 - "Copia Arquivos da Especificação?" # STR0074 - "Sim" # STR0073 - "Não"
	EndIf
	
	If ParamBox(aPergs, STR0051, @aParamDup,,, .T.,,, NIL, "qipa012", .F., .F.) //"Parâmetros"
		lReturn  := .T.
		MV_PAR04 := Iif(Empty(MV_PAR04), PadR( "", nTamaRotei, "z" ), MV_PAR04)
		aParamDup[PARAM_COPIA_ROTEIRO_ATE] := MV_PAR04
	EndIf

Return lReturn

/*/{Protheus.doc} criaTelaParametrosCopiaEnsaios
Monta tela de parametos para a cópia ensaios da especificação.
@author brunno.costa
@since 28/08/2024
@version 1.0
@return lReturn, lógico, indica se os parâmetros foram confirmados (.T.) ou se a operação foi cancelada (.F.)
/*/
Method criaTelaParametrosCopiaEnsaios() CLASS QIPA012AuxClass

	Local aArea      := GetArea()
	Local aAreaQP6   := QP6->(GetArea())
	Local aAreaQQK   := QQK->(GetArea())
	Local aPergs     := {}
	Local lReturn    := .F.
	Local nTamaProdu := GetSx3Cache("QP6_PRODUT", "X3_TAMANHO")
	Local nTamaRevis := GetSx3Cache("QP6_REVI"  , "X3_TAMANHO")
	Local nTamaRotei := GetSx3Cache("QP6_CODREC", "X3_TAMANHO")
	Local nTamEnsaio := GetSx3Cache("QP7_ENSAIO", "X3_TAMANHO")
	Local nTamOperac := GetSx3Cache("QQK_OPERAC", "X3_TAMANHO")

	Private cProdBase := QP6->QP6_PRODUT
	Private cRevBase  := QP6->QP6_REVI
	Private oSelf     := QIPA012AuxClass():New()

	DEFAULT aParamDup := {}

	/* 	[1]: Tipo do parâmetro  (numérico) -> 1 - MsGet
		[2]: Descrição
		[3]: String contendo o inicializador do campo
		[4]: String contendo a Picture do campo
		[5]: String contendo a validação
		[6]: Consulta F3
		[7]: String contendo a validação When
		[8]: Tamanho do MsGet
		[9]: Flag .T./.F. Parâmetro Obrigatório ? */

	aAdd(aPergs, {1, STR0076, SPACE(nTamaRotei), , 'NaoVazio() .And. oSelf:validaBaseCopiaEnsaios()'    , "QQK02" , "oSelf:whenRoteiroGenerico(cProdBase , cRevBase, 'MV_PAR01')"          , nTamaRotei * 5, .T.}) //"Roteiro Base"
	aAdd(aPergs, {1, STR0077, SPACE(nTamOperac), , 'NaoVazio() .And. oSelf:validaBaseCopiaEnsaios()'    , "QQK04" , "oSelf:whenOperacaoGenerica(cProdBase, cRevBase, MV_PAR01, 'MV_PAR02')", nTamOperac * 5, .T.}) //"Operação Base"
	aAdd(aPergs, {1, STR0078, SPACE(nTamEnsaio), , 'oSelf:validaBaseCopiaEnsaios()'                     ,      "" , ""                                                                     , nTamEnsaio * 5, .F.}) //"Do Ensaio"
	aAdd(aPergs, {1, STR0079, SPACE(nTamEnsaio), , 'oSelf:validaBaseCopiaEnsaios()'                     ,      "" , ""                                                                     , nTamEnsaio * 5, .F.}) //"Até o Ensaio"
	aAdd(aPergs, {1, STR0046, SPACE(nTamaProdu), , 'NaoVazio() .And. oSelf:validaDestinoCopiaEnsaios() .AND. Iif(!Empty(MV_PAR06), !oSelf:validaSeProdutoPertenceAGrupodeEspecificacao(MV_PAR05, MV_PAR06), .T.)' , "QP602" , "" , nTamaProdu * 5, .T.}) //"Produto Destino"
	aAdd(aPergs, {1, STR0047, SPACE(nTamaRevis), , 'NaoVazio() .And. oSelf:validaDestinoCopiaEnsaios() .AND. !oSelf:validaSeProdutoPertenceAGrupodeEspecificacao(MV_PAR05, MV_PAR06)' ,     ""  , "" , nTamaRevis * 5, .T.}) //"Revisão Destino"
	aAdd(aPergs, {1, STR0080, SPACE(nTamaRotei), , 'NaoVazio() .And. oSelf:validaDestinoCopiaEnsaios()' ,     ""  , "oSelf:whenRoteiroGenerico(MV_PAR05,MV_PAR06,'MV_PAR07')"              , nTamaRotei * 5, .T.}) //"Roteiro Destino"
	aAdd(aPergs, {1, STR0081, SPACE(nTamOperac), , 'NaoVazio() .And. oSelf:validaDestinoCopiaEnsaios()' ,     ""  , "oSelf:whenOperacaoGenerica(MV_PAR05,MV_PAR06,MV_PAR07,'MV_PAR08')"    , nTamOperac * 5, .T.}) //"Operação Destino"
	aAdd(aPergs, {9, STR0082, 200, 30, .F.}) //"Nota: a operação será mesclada, ou seja, agrega na operação destino existente os ensaios inexistentes."

	If ParamBox(aPergs, STR0051, @aParamDup,,, .T.,,, NIL, "qipa012", .F., .F.) //"Parâmetros"
		lReturn  := .T.
		MV_PAR04                           := Iif(Empty(MV_PAR04), PadR( "", nTamEnsaio, "z" ), MV_PAR04)
		aParamDup[PARAM_COPIA_ENSAIOS_ATE_O_ENSAIO] := MV_PAR04
	EndIf

	RestArea(aAreaQQK)
	RestArea(aAreaQP6)
	RestArea(aArea)

Return lReturn

/*/{Protheus.doc} whenRoteiroGenerico
Avalia o modo de edição de campos Roteiro Genérico e atribui conteúdo genérico (quando for o caso)
@author brunno.costa
@since 28/08/2024
@version 1.0
@param 01 - cProduto  , caracter, codigo do produto para avaliacao
@param 02 - cRevisao  , caracter, codigo da revisao para avaliacao
@param 03 - cMVAtribui, caracter, retorna por referencia conteudo para exibicao no parmetro relacionado ao roteiro generico
@return lEditavel, lógico, indica o modo de edição de campos Roteiro Genérico
/*/
Method whenRoteiroGenerico(cProduto, cRevisao, cMVAtribui) CLASS QIPA012AuxClass

	Local aArea     := Nil
	Local aAreaQP6  := Nil
	Local lEditavel := .T.
	Local nPosAtrib := NIl

	If !Empty(cProduto) .AND. !Empty(cRevisao)

		aArea     := GetArea()
		aAreaQP6  := QP6->(GetArea())

		nPosAtrib := Val(Right(cMVAtribui, 2))

		QP6->(dbSetOrder(1))
		If QP6->(DbSeek(xFilial('QP6') + cProduto + Inverte(cRevisao)), .T.) .AND. QP6->QP6_CODREC == QIPRotGene("QP6_CODREC")
			&(cMVAtribui) := QP6->QP6_CODREC
			lEditavel     := .F.
		EndIf

		RestArea(aAreaQP6)
		RestArea(aArea)
	EndIf

Return lEditavel

/*/{Protheus.doc} whenOperacaoGenerica
Avalia o modo de edição de campos Operação Genérica e atribui conteúdo genérico (quando for o caso)
@author brunno.costa
@since 28/08/2024
@version 1.0
@param 01 - cProduto  , caracter, codigo do produto para avaliacao
@param 02 - cRevisao  , caracter, codigo da revisao para avaliacao
@param 03 - cRoteiro  , caracter, codigo da roteiro para avaliacao
@param 04 - cMVAtribui, caracter, retorna por referencia conteudo para exibicao no parametro relacionado a operacao generica
@return lEditavel, lógico, indica o modo de edição de campos Operação Genérica
/*/
Method whenOperacaoGenerica(cProduto, cRevisao, cRoteiro, cMVAtribui) CLASS QIPA012AuxClass

	Local aArea     := Nil
	Local aAreaQQK  := Nil
	Local lEditavel := .T.
	Local nPosAtrib := Nil

	If !Empty(cProduto) .And. !Empty(cRevisao) .And. !Empty(cRoteiro)

		aArea     := GetArea()
		aAreaQQK  := QQK->(GetArea())

		nPosAtrib := Val(Right(cMVAtribui, 2))

		QQK->(dbSetOrder(1))
		If QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro)) .AND. QQK->QQK_OPERAC == QIPRotGene("QQK_OPERAC")
			&(cMVAtribui)  := QQK->QQK_OPERAC
			lEditavel      := .F.
		EndIf

		RestArea(aAreaQQK)
		RestArea(aArea)

	EndIf

Return lEditavel

/*/{Protheus.doc} validaBaseCopiaEnsaios
Avalia se os parâmetros base para copia de ensaios são válidos
@author brunno.costa
@since 28/08/2024
@version 1.0
@return lValidos, lógico, indica se os parâmetros base para cóia de ensaios são válidos
/*/
Method validaBaseCopiaEnsaios() CLASS QIPA012AuxClass

	Local lValidos     := .F.
	Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""

    cQuery += " SELECT COUNT(*) ENSAIOS "
    cQuery += " FROM "
    cQuery += 	" ( "
	cQuery += 	" SELECT QP7_PRODUT, QP7_REVI, QP7_CODREC, QP7_OPERAC, QP7_ENSAIO "
    cQuery += 	" FROM " + RetSqlName("QP7")
    cQuery += 	" WHERE D_E_L_E_T_ = ' '  "
    cQuery += 	  " AND QP7_FILIAL = '" + xFilial("QP7") + "' "
	cQuery += 	  " AND QP7_PRODUT = '" + cProdBase + "' "
	cQuery += 	  " AND QP7_REVI   = '" + cRevBase  + "' "
	
	//PARAM_COPIA_ENSAIOS_ROTEIRO_BASE
	If !Empty(MV_PAR01)
		cQuery += 	  " AND QP7_CODREC = '" + MV_PAR01 + "' "
	EndIf

	//PARAM_COPIA_ENSAIOS_OPERACAO_BASE
	If !Empty(MV_PAR02)
		cQuery += 	  " AND QP7_OPERAC = '" + MV_PAR02 + "' "
	EndIf

	//PARAM_COPIA_ENSAIOS_DO_ENSAIO
	//PARAM_COPIA_ENSAIOS_ATE_O_ENSAIO
	If !Empty(MV_PAR03) .OR. !Empty(MV_PAR04)
		cQuery += 	  " AND QP7_ENSAIO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	EndIf

    cQuery += 	" UNION "
    cQuery += 	" SELECT QP8_PRODUT, QP8_REVI, QP8_CODREC, QP8_OPERAC, QP8_ENSAIO "
    cQuery += 	" FROM " + RetSqlName("QP8")
    cQuery += 	" WHERE D_E_L_E_T_=' ' "
    cQuery += 	  " AND QP8_FILIAL = '" + xFilial("QP8") + "' "
	cQuery += 	  " AND QP8_PRODUT = '" + cProdBase + "' "
	cQuery += 	  " AND QP8_REVI   = '" + cRevBase  + "' "
	
	//PARAM_COPIA_ENSAIOS_ROTEIRO_BASE
	If !Empty(MV_PAR01)
		cQuery += 	  " AND QP8_CODREC = '" + MV_PAR01 + "' "
	EndIf

	//PARAM_COPIA_ENSAIOS_OPERACAO_BASE
	If !Empty(MV_PAR02)
		cQuery += 	  " AND QP8_OPERAC = '" + MV_PAR02 + "' "
	EndIf

	//MV_PAR03 - PARAM_COPIA_ENSAIOS_DO_ENSAIO
	//MV_PAR04 - PARAM_COPIA_ENSAIOS_ATE_O_ENSAIO
	If !Empty(MV_PAR03) .OR. !Empty(MV_PAR04)
		cQuery += 	  " AND QP8_ENSAIO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	EndIf

    cQuery += 	" ) ENSAIOS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!EOF())
        lValidos := (cAliasQry)->ENSAIOS > 0
    EndIf
    (cAliasQry)->(DbCloseArea())

	If !lValidos
		//STR0083 - "Não existem ensaios válidos neste Roteiro, Operação e Ensaios."
		//STR0084 - "Selecione outro Roteiro, Operação e Ensaios."
		Help(NIL, NIL, "QIPA012NOENSBASE", NIL, STR0083 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0084})
	EndIf

Return lValidos

/*/{Protheus.doc} validaDestinoCopiaEnsaios
Avalia se os parâmetros de destino para cópia dos ensaios são válidos
@author brunno.costa
@since 28/08/2024
@version 1.0
@return lValidos, lógico, indica se os parâmetros de destino para cópia dos ensaios são válidos
/*/
Method validaDestinoCopiaEnsaios() CLASS QIPA012AuxClass
	Local lValidos     := .F.

	Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""

    cQuery += " SELECT COUNT(*) OPERACOES "
    cQuery += " FROM  " + RetSqlName("QQK")
    cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=   " AND QQK_FILIAL = '" + xFilial("QQK") + "' "
	
	//PARAM_COPIA_ENSAIOS_PRODUTO_DESTINO
	If !Empty(MV_PAR05)
		cQuery +=   " AND QQK_PRODUT = '" + MV_PAR05 + "' "
	EndIf
	
	//PARAM_COPIA_ENSAIOS_REVISAO_DESTINO
	If !Empty(MV_PAR06)
		cQuery +=   " AND QQK_REVIPR = '" + MV_PAR06 + "' "
	EndIf
	
	//PARAM_COPIA_ENSAIOS_ROTEIRO_DESTINO
	If !Empty(MV_PAR07)
		cQuery +=   " AND QQK_CODIGO = '" + MV_PAR07 + "' "
	EndIf
	
	//PARAM_COPIA_ENSAIOS_OPERACAO_DESTINO
	If !Empty(MV_PAR08)
		cQuery +=   " AND QQK_OPERAC = '" + MV_PAR08 + "' "
	EndIf

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!EOF())
        lValidos := (cAliasQry)->OPERACOES > 0
    EndIf
    (cAliasQry)->(DbCloseArea())

	If lValidos
		lValidos := Self:validaDestinoCopiaDisponivel(MV_PAR05, MV_PAR06)
	Else
		//STR0085 - "Produto, Revisão, Roteiro e operação inválidos como Destino de cópia."
		//STR0086 - "Selecione um Produto, Revisão, Roteiro e Operação com especificação cadastrada."
		Help(NIL, NIL, "QIPA012NOOPERDES", NIL, STR0085 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0086})
	EndIf

Return lValidos

/*/{Protheus.doc} atribuiProximaRevisaoParametroCopia
Atribui a revisão da especificação com base na revisão do produto destino nos parâmetros de copia da especificação
@author rafael.kleestadt
@since 06/04/2023
@version 1.0
@return lExecutou, lógico, indica término da execução (sempre true)
/*/
Method atribuiProximaRevisaoParametroCopia() CLASS QIPA012AuxClass

	MV_PAR01 := Upper(MV_PAR01)
	MV_PAR02 := Self:retornaProximaRevisao(MV_PAR01, MV_PAR02)

Return (.T.)

/*/{Protheus.doc} validaRoteiroPrimarioCopia
Valida se o roteiro primario escolhido é valido em operação de cópia da especificação
@author rafael.kleestadt
@since 06/04/2023
@version 1.0
@return lRet, lógico, indica se o roteiro primario escolhido é valido em operação de cópia da especificação
/*/
Method validaRoteiroPrimarioCopia() CLASS QIPA012AuxClass
	Local lRet := .T.

	If !Empty(Alltrim(MV_PAR05))
		// Formata o codigo do Roteiro
		If MV_PAR05 != QIPRotGene("QQK_CODIGO")
			MV_PAR05 := Strzero(val(MV_PAR05), GetSx3Cache("QQK_CODIGO","X3_TAMANHO"))
		EndIf

		// Consiste se o Roteiro faz parte dos roteiros a serem copiados
		If !(MV_PAR05 >= MV_PAR03 .AND. MV_PAR05 <= MV_PAR04)
			MV_PAR05 := "  "
			lRet     := .F.  
			MsgAlert(STR0035) //Informe um roteiro dentro do range a ser duplicado.
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc} validaDestinoCopiaDisponivel
Valida se o produto e revisão destino estão disponíveis para utilização em operações de Copia ou Revisão:
-> Não foi utilizado em ordem de produção
-> Não faz parte de um grupo de especificação

@author rafael.kleestadt
@since 06/04/2023
@version 1.0
@param 01 - cProduto, caracter, codigo do produto destino para analise
@param 02 - cRevisao, caracter, codigo da revisão destino para analise
@return lDisponivel, lógico, Indica se o produto e revisão destino estão disponíveis para utilização em operações de Copia ou Revisão
/*/
Method validaDestinoCopiaDisponivel(cProduto, cRevisao) CLASS QIPA012AuxClass

	Local aAreaQP6 := QP6->(GetArea())
	Local aAreaSC2 := SC2->(GetArea())
	Local lDisponivel := .T.

	Default cProduto := MV_PAR01
	Default cRevisao := MV_PAR02

	//Verifica se tem OP
	SC2->(dbSetOrder(8))
	IF !Empty(cProduto) .And. !Empty(cRevisao) .And. SC2->(dbSeek(xFilial("SC2")+cProduto+cRevisao))
		//STR0087 - "Não será possível a utilização deste Produto e Revisão Destino pois a especificação de produtos já foi utilizada em uma ordem de produção."
		//STR0088 - "Utilize um produto e revisão sem uso em ordem de produção."
		Help(NIL, NIL, "QIPExistSC2", NIL, STR0087 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0088})
		lDisponivel := .F.
	Else
		lDisponivel := !Self:validaSeProdutoPertenceAGrupodeEspecificacao(cProduto, cRevisao)
	EndIf

	RestArea(aAreaSC2)
	RestArea(aAreaQP6)

Return (lDisponivel)

/*/{Protheus.doc} validaSeProdutoPertenceAGrupodeEspecificacao
Valida se o produto esta em um grupo de especificação
@author rafael.kleestadt
@since 10/04/2023
@version 1.0
@param cProduto, caractere, código do produto a ser buscado na QP6
@return lPertence, Lógico, TRUE se encontrar registros com grupo e revisão de grupo na QP6
/*/
Method validaSeProdutoPertenceAGrupodeEspecificacao(cProduto, cRevisao) CLASS QIPA012AuxClass
	Local cAliasQP6        := Nil
	Local cArquivQP6       := RetSqlName("QP6")
	Local cGrpQP6Vaz       := Space(GetSx3Cache("QP6_GRUPO", "X3_TAMANHO"))
	Local cQuery           := ""
	Local cRGrQP6Vaz       := Space(GetSx3Cache("QP6_REVIGR", "X3_TAMANHO"))
	Local lPertence        := .F.
	Local oQLTQueryM       := Nil

	If FindClass("QLTQueryManager")
		If !Empty(cRevisao)
			oQLTQueryM := QLTQueryManager():New()
			
			cQuery :=  " SELECT DISTINCT QP6.QP6_GRUPO, QP6.QP6_REVIGR "
			cQuery +=   " FROM " + cArquivQP6 + " QP6 "
			cQuery +=  " WHERE QP6.QP6_PRODUT =  '" + cProduto + "' "
			cQuery +=    " AND QP6.QP6_REVI   =  '" + cRevisao + "' "
			cQuery +=    " AND QP6.QP6_FILIAL =  '" + xFilial("QP6") + "' "
			cQuery +=    " AND QP6.QP6_GRUPO  <> '" + cGrpQP6Vaz + "' "
			cQuery +=    " AND QP6.QP6_REVIGR <> '" + cRGrQP6Vaz + "' "
			cQuery +=    " AND QP6.D_E_L_E_T_ =  ' ' "

			cQuery    := oQLTQueryM:changeQuery(cQuery)
			cAliasQP6 := oQLTQueryM:executeQuery(cQuery)

			If (cAliasQP6)->(!Eof())
				Help(NIL, NIL, STR0028+"!", NIL, STR0052+ALLTRIM((cAliasQP6)->QP6_GRUPO)+STR0053+ALLTRIM((cAliasQP6)->QP6_REVIGR)+"." , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0054})
				//STR0028 - "Atenção"
				//STR0052 - "Não será possível a duplicação da especificação pois este produto destino faz parte do grupo de especificação: "
				//STR0053 - " revisão: "
				//STR0054 - "Altere o grupo de especificação ou escolha outro produto."
				lPertence := .T.
			EndIf
			(cAliasQP6)->(DbCloseArea())
		EndIf
	Else
		lPertence  := .T.
		//STR0059 - "Ambiente desatualizado."
		//STR0060 - "Atualize o path mais recente de expedição contínua do módulo SIGAQIP."
		Help(NIL, NIL, "NOQLTQueryManager", NIL, STR0059, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0060})
	EndIf

	QPA->(dbSetOrder(2))
	If !lPertence .And. QPA->(dbSeek(xFilial("QPA")+cProduto)) 
		Help(NIL, NIL, STR0028+"!", NIL, STR0052+ALLTRIM(QPA->QPA_GRUPO)+"." , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0054})
		//STR0028 - "Atenção"
		//STR0052 - "Não será possível a duplicação da especificação pois este produto destino faz parte do grupo de especificação: "
		//STR0054 - "Altere o grupo de especificação ou escolha outro produto."
		lPertence := .T.
	EndIf


Return lPertence

/*/{Protheus.doc} validaPlanosDeAmostragem
Verifica se os planos de amostragem vinculados aos ensaios da especificação estão cadastrados corretamente.
@author rafael.kleestadt
@since 04/05/2023
@version 1.0
@param 01 - cCodProdut, caractere, código do produto da especificação
@param 02 - cRevEspPro, caractere, revisão da especificação
@return lConsistente, lógico, indica se os planos de amostragem dos ensaios estão consistentes
/*/
METHOD validaPlanosDeAmostragem(cCodProdut, cRevEspPro) CLASS QIPA012AuxClass
Local aAlias     := {"QP7","QP8"}
Local cAlias     := ""
Local cEnsaio    := ""
Local nContAlias := 0

For nContAlias := 1 To Len(aAlias)
	cAlias := aAlias[nContAlias]

	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(1))
	If (cAlias)->(dbSeek(xFilial(cAlias)+cCodProdut+cRevEspPro))
		While (cAlias)->(&(cAlias+"->(!Eof())")) .And.;
		      (cAlias)->(&(cAlias+"_FILIAL")) == xFilial(cAlias) .And.;
			  (cAlias)->(&(cAlias+"_PRODUT")+&(cAlias+"_REVI")) == cCodProdut+cRevEspPro

			If !EMPTY( (cAlias)->(&(cAlias+"_PLAMO")) )

				DbSelectArea("QQH")
				QQH->(dbSetOrder(1)) //QQH_FILIAL+QQH_PRODUT+QQH_REVI+QQH_CODREC+QQH_OPERAC+QQH_ENSAIO+QQH_NQA
				If !QQH->(dbSeek(xFilial("QQH")+(cAlias)->(&(cAlias+"_PRODUT")+&(cAlias+"_REVI")+&(cAlias+"_CODREC")+&(cAlias+"_OPERAC")+&(cAlias+"_ENSAIO"))))
					cEnsaio := AllTrim((cAlias)->(&(cAlias+"_ENSAIO")))+' - '+AllTrim(Posicione("QP1", 1, xFilial("QP1")+(cAlias)->(&(cAlias+"_ENSAIO")), "QP1_DESCPO"))
					//STR0058 - "Plano de Amostragem"
					//STR0055 - "Os dados referentes ao plano de amostragem do ensaio: "
					//STR0056 - " na especificação estão incompletos."
					//STR0057 - "Verifique a especificação do produto e ajuste os dados referentes ao Plano de Amostragem."
					Help(NIL, NIL, STR0058, NIL, STR0055 +cEnsaio+ STR0056, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0057})
					Return .F.
				EndIf

			EndIf
			(cAlias)->(&(cAlias+"->(!DbSkip())"))
		EndDo
	EndIf
Next nContAlias

Return .T.

/*/{Protheus.doc} retornaCamposDaTabelaDeEspecificacacaoDeProdutosConformeMVQIPOPEPeModoEscolhido
Retorna campos da tabela de Especificacação de Grupos conforme MV_QIPOPEP e modo da especificação escolhida
@author rafael.kleestadt
@since 06/05/2024
@version 1.0
@param cPrioriR, caractere, conteúdo do MV_QIPOPEP
@param nModoTela, numérico, modo da especificação escolhido
@param aCampos, array, campos da tabela QP6 conforme regras de uso, MV_QIPOPEP e tipo de especificação.
@param aEditaveis, array, campos editaveis conforme regras da rotina
@return return_var, return_type, return_description
/*/
Method retornaCamposDaTabelaDeEspecificacacaoDeProdutosConformeMVQIPOPEPeModoEscolhido(cPrioriR, nModoTela, aCampos, aEditaveis) CLASS QIPA012AuxClass

Local aCamposQP6 := FWSX3Util():GetAllFields("QP6")
Local nCont      := 0

For nCont := 1 To Len(aCamposQP6)
	If cPrioriR == "3" .AND. nModoTela != 3
		If !(ALLTRIM(aCamposQP6[nCont]) $ "|QP6_CODSIM|QP6_ROTSIM|QP6_CODREC|");
		   .AND. X3Uso(GetSx3Cache(aCamposQP6[nCont],"X3_USADO"))

			aAdd(aCampos, AllTrim(aCamposQP6[nCont]))

		EndIf
	ElseIf !Inclui;
		   .AND. !(ALLTRIM(aCamposQP6[nCont]) $ "|QP6_CODSIM|QP6_ROTSIM|");
		   .AND. X3Uso(GetSx3Cache(aCamposQP6[nCont],"X3_USADO"))

		aAdd(aCampos,AllTrim(aCamposQP6[nCont]))

	EndIf

	If lDeGrupo
		If !(ALLTRIM(aCamposQP6[nCont]) $ "|QP6_CODREC|QP6_DTINI|")
			aAdd(aEditaveis, AllTrim(aCamposQP6[nCont]))
		EndIf
	Else
		aAdd(aEditaveis, AllTrim(aCamposQP6[nCont]))
	EndIf

Next nCont

Return Nil

/*/{Protheus.doc} QPA012CpyP
Copia Especificação de Produtos
@author brunno.costa
@since 27/08/2024
@version 1.0
/*/
Function QPA012CpyP(cAlias,nReg,nOpc)

	Local aArea      := GetArea()
	Local aAreaQP6   := QP6->(GetArea())
	Local lSucesso   := .F.
	Local nOpcA      := Nil
	Local oQIP012Aux := QIPA012AuxClass():New()

    Private aParamDup := {}
	Private cDescEs   := ""
	Private cDescIn   := ""
	Private cProdPosi := QP6->QP6_PRODUT
	Private lPrimeira := .F.

	BEGIN TRANSACTION

		//STR0089 - "Processando..."
		//STR0090 - "Aguarde o processamento da operação..."
		Processa({|| lSucesso := oQIP012Aux:copia() }, STR0089, STR0090)

		If lSucesso
			QP6->(DbSetOrder(2))
			If QP6->(DbSeek(xFilial("QP6") + aParamDup[PARAM_COPIA_PRODUTO_DESTINO] + aParamDup[PARAM_COPIA_REVISAO_DESTINO]))
				nOpcA := QPA012Atu("QP6",QP6->(Recno()), 4, 7)
				If nOpcA == NIL .OR. nOpcA != 1
					DisarmTransaction()
				EndIf
			Endif
		Endif
	END TRANSACTION

	RestArea(aAreaQP6)
	RestArea(aArea)

Return

/*/{Protheus.doc} copia
Copia Especificação de Produtos
@author brunno.costa
@since 27/08/2024
@version 1.0
@return lSucesso, lógico, indica se realizou a copia com sucesso
/*/
METHOD copia() CLASS QIPA012AuxClass

	Local aOperDel    := Nil
	Local cDesPro     := Nil
	Local cFilQP6     := ""
	Local cGrupo      := Nil
	Local cOrigem     := Nil
	Local cPrioRot    := Nil
	Local cProdDes    := Nil
	Local cProdOri    := Nil
	Local cRevDes     := Nil
	Local cRevGrp     := Nil
	Local cRevOri     := Nil
	Local cRotAte     := Nil
	Local cRotDe      := Nil
	Local cRotDes     := Nil
	Local cRotPrim    := Nil
	Local lDelSG2     := Nil
	Local lHelp       := Nil
	Local lMescla     := Nil
	Local lSucesso    := .F.
	Local nForcaModo  := Nil
	Local oQIPXFUNAux := QIPXFUNAuxClass():New()

	If Self:criaTelaParametrosCopia()

		//Popula parâmetros da copia da Especificação
		cProdOri   := QP6->QP6_PRODUT
		cRevOri    := QP6->QP6_REVI
		cRotDe     := aParamDup[PARAM_COPIA_ROTEIRO_DE]
		cProdDes   := aParamDup[PARAM_COPIA_PRODUTO_DESTINO]
		cRevDes    := aParamDup[PARAM_COPIA_REVISAO_DESTINO]
		cRotAte    := aParamDup[PARAM_COPIA_ROTEIRO_ATE]
		cDesPro    := Self:retornaDescricaoProdutoDestino(aParamDup[PARAM_COPIA_PRODUTO_DESTINO], QP6->QP6_PRODUT)
		cGrupo     := " "
		cRevGrp    := " "
		lHelp      := .T.
		cRotPrim   := Iif(Empty(aParamDup[PARAM_COPIA_ROTEIRO_PRIMARIO]), aParamDup[PARAM_COPIA_ROTEIRO_DE], aParamDup[PARAM_COPIA_ROTEIRO_PRIMARIO] )
		cPrioRot   := cPrioriR
		aOperDel   := Nil
		lDelSG2    := Nil
		cDescIn    := QP6->QP6_DESCIN
		cDescEs    := QP6->QP6_DESCES
		cRotDes    := Nil
		cOrigem    := Nil
		nForcaModo := 0
		lMescla    := aParamDup[PARAM_COPIA_MESCLA_ROTEIRO] == STR0074 //"Sim"
		cFilQP6    := QP6->QP6_FILIAL

		lSucesso := Self:validaPlanosDeAmostragem(cProdOri, cRevOri)

		If lSucesso

			//Realiza a Duplicacao da Especificacao do Produto
			lSucesso := QIPDupEsp( cProdOri, cRevOri ,   cRotDe, cProdDes, cRevDes,;
								   cRotAte , cDesPro ,   cGrupo, cRevGrp , lHelp  ,;
								   cRotPrim, cPrioRot, aOperDel, lDelSG2 ,cDescIn , cDescEs, cRotDes, cOrigem, nForcaModo, lMescla)
			
			If FWAliasIndic("QQO", .F.) .And. aParamDup[PARAM_COPIA_ARQUIV_ESPECIFIC] == STR0074 //"Sim"
				oQIPXFUNAux:copiaVinculoDosArquivosDaManufaturaPorProduto(cFilQP6, cProdOri, cRevOri , cProdDes, cRevDes)
			EndIf

		EndIf
		
	EndIf 

Return lSucesso

/*/{Protheus.doc} retornaDescricaoProdutoDestinoEspecificacao
Retorna Descrição do Produto Destino para Copia da Especificação
@author brunno.costa
@since 27/08/2024
@version 1.0
@param 01 - cProdDes , caracter, codigo do produto destino
@param 02 - cProdPosi, caracter, codigo do produto posicionado
@return cDes, caracter, descrição do produto destino

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ QP012Verif ³ Autor ³ Cleber Souza          ³ Data ³ 25/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica de onde vira a descricao do produto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012                                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Method retornaDescricaoProdutoDestino(cProdDes, cProdPosi) CLASS QIPA012AuxClass

	Local cDes        := Space(TamSX3("B1_DESC")[1])  

	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cProdDes))
		cDes := SB1->B1_DESC
	Else
		If SB1->(DbSeek(xFilial("SB1")+cProdPosi))
			cDes := SB1->B1_DESC
		EndIf
	EndIf
	SB1->(DbCloseArea())

Return cDes

/*/{Protheus.doc} QPA012CpyE
Copia Especificação Ensaios
@author brunno.costa
@since 27/08/2024
@version 1.0
/*/
Function QPA012CpyE()
	
	Local aArea       := GetArea()
	Local aAreaQP6    := QP6->(GetArea())
	Local lSucesso    := .F.
	Local nOpcA       := Nil
	Local oQIP012Aux  := QIPA012AuxClass():New()

    Private aParamDup := {}
	Private cDescEs   := ""
	Private cDescIn   := ""
	Private cProdPosi := QP6->QP6_PRODUT
	Private lPrimeira := .F.

	BEGIN TRANSACTION

		//STR0089 - "Processando..."
		//STR0090 - "Aguarde o processamento da operação..."
		Processa({|| lSucesso := oQIP012Aux:copiaEnsaios() }, STR0089, STR0090)

		If lSucesso
			QP6->(DbSetOrder(2))
			If QP6->(DbSeek(xFilial("QP6") + aParamDup[PARAM_COPIA_ENSAIOS_PRODUTO_DESTINO] + aParamDup[PARAM_COPIA_ENSAIOS_REVISAO_DESTINO]))
				nOpcA := QPA012Atu("QP6",QP6->(Recno()), 4, 8)
				If nOpcA == NIL .OR. nOpcA != 1
					DisarmTransaction()
				EndIf
			Endif
		Endif
	END TRANSACTION

	RestArea(aAreaQP6)
	RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} copiaEnsaios
Copia Ensaios da Especificação de Produtos
@author brunno.costa
@since 27/08/2024
@version 1.0
@return lSucesso, lógico, indica se realizou a copia dos ensaios com sucesso
/*/
METHOD copiaEnsaios() CLASS QIPA012AuxClass

	Local cEnsAte   := Nil
	Local cEnsDe    := Nil
	Local cOperBase := Nil
	Local cOperDest := Nil
	Local cPrioR    := Nil
	Local cProdBase := Nil
	Local cProdDest := Nil
	Local cRevBase  := Nil
	Local cRevDest  := Nil
	Local cRotBase  := Nil
	Local cRotDest  := Nil
	Local lSucesso  := .F.

	If Self:criaTelaParametrosCopiaEnsaios()
		
		cProdBase := QP6->QP6_PRODUT
		cRevBase  := QP6->QP6_REVI
		cRotBase  := aParamDup[PARAM_COPIA_ENSAIOS_ROTEIRO_BASE]
		cOperBase := aParamDup[PARAM_COPIA_ENSAIOS_OPERACAO_BASE]
		cEnsDe    := aParamDup[PARAM_COPIA_ENSAIOS_DO_ENSAIO]
		cEnsAte   := aParamDup[PARAM_COPIA_ENSAIOS_ATE_O_ENSAIO]
		cProdDest := aParamDup[PARAM_COPIA_ENSAIOS_PRODUTO_DESTINO]
		cRevDest  := aParamDup[PARAM_COPIA_ENSAIOS_REVISAO_DESTINO]
		cRotDest  := aParamDup[PARAM_COPIA_ENSAIOS_ROTEIRO_DESTINO]
		cOperDest := aParamDup[PARAM_COPIA_ENSAIOS_OPERACAO_DESTINO]
		cPrioR    := "2"

		QIPDupEns( cProdBase ,; //Produto Base
				   cRevBase  ,; //Revisao Base
				   cRotBase  ,; //Roteiro Base
				   cOperBase ,; //Operacao Base
				   cEnsDe    ,; //Ensaio Base de 
				   cEnsAte   ,; //Ensaio Base ate
				   cProdDest ,; //Produto Destino
				   cRevDest  ,; //Revisao Destino
				   cRotDest  ,; //Roteiro Destino
				   cOperDest ,; //Operacao Destino
				   cPrioR    )  //Indica a prioridade 1 - Materiais / 2 - Quality

		lSucesso := .T.

	EndIf

Return lSucesso

/*/{Protheus.doc} QPA012RevP
Gerar Revisão do Produto
@author brunno.costa
@since 27/08/2024
@version 1.0
/*/
Function QPA012RevP()

	Local aArea      := GetArea()
	Local aAreaQP6   := QP6->(GetArea())
	Local lSucesso   := .F.
	Local nOpcA      := Nil
	Local oQIP012Aux := QIPA012AuxClass():New()

	Private cDescEs   := ""
	Private cDescIn   := ""
	Private cProdDes  := QP6->QP6_PRODUT
	Private cProdPosi := QP6->QP6_PRODUT
	Private cRevDes   := oQIP012Aux:retornaProximaRevisao(QP6->QP6_PRODUT, QP6->QP6_REVI)
	Private lPrimeira := .F.

	BEGIN TRANSACTION
		
		//STR0089 - "Processando..."
		//STR0090 - "Aguarde o processamento da operação..."
		Processa({|| lSucesso := oQIP012Aux:geraRevisao() }, STR0089, STR0090)

		If lSucesso
			QP6->(DbSetOrder(2))
			If QP6->(DbSeek(xFilial("QP6") + cProdDes + cRevDes))
				nOpcA := QPA012Atu("QP6",QP6->(Recno()), 4, 9)
				If nOpcA == NIL .OR. nOpcA != 1
					DisarmTransaction()
				EndIf
			Endif
		Endif
	END TRANSACTION

	RestArea(aAreaQP6)
	RestArea(aArea)
	
Return

/*/{Protheus.doc} geraRevisao
Gera Revisão da Especificação de Produtos
@author brunno.costa
@since 27/08/2024
@version 1.0
@return lSucesso, lógico, indica se realizou a geração de revisão com sucesso
/*/
METHOD geraRevisao() CLASS QIPA012AuxClass

	Local aOperDel    := Nil
	Local cDesPro     := Nil
	Local cFilQP6     := ""
	Local cGrupo      := Nil
	Local cOrigem     := Nil
	Local cPrioRot    := Nil
	Local cProdOri    := Nil
	Local cRevDes     := Nil
	Local cRevGrp     := Nil
	Local cRevOri     := Nil
	Local cRotAte     := Nil
	Local cRotDe      := Nil
	Local cRotPrim    := Nil
	Local lDelSG2     := Nil
	Local lHelp       := Nil
	Local lMescla     := Nil
	Local lSucesso    := .T.
	Local nForcaModo  := Nil
	Local oQIPXFUNAux := QIPXFUNAuxClass():New()

	//Popula parâmetros da copia da Especificação
	cProdOri   := QP6->QP6_PRODUT
	cRevOri    := QP6->QP6_REVI
	cRotDe     := PadR( "", GetSx3Cache("QP6_CODREC", "X3_TAMANHO"), " " )
	cProdDes   := QP6->QP6_PRODUT
	cRevDes    := QA_NxtRevEsp(cProdDes,"QIP")
	cRotAte    := PadR( "", GetSx3Cache("QP6_CODREC", "X3_TAMANHO"), "z" )
	cDesPro    := Self:retornaDescricaoProdutoDestino(QP6->QP6_PRODUT, QP6->QP6_PRODUT)
	cGrupo     := " "
	cRevGrp    := " "
	lHelp      := .T.
	cRotPrim   := QP6->QP6_CODREC
	cPrioRot   := cPrioriR
	aOperDel   := Nil
	lDelSG2    := Nil
	cDescIn    := QP6->QP6_DESCIN
	cDescEs    := QP6->QP6_DESCES
	cRotDes    := Nil
	cOrigem    := Nil
	nForcaModo := 0
	lMescla    := .F.
	cFilQP6    := QP6->QP6_FILIAL

	lSucesso := Self:validaPlanosDeAmostragem(cProdOri, cRevOri)

	lSucesso := lSucesso .And. !Self:validaSeProdutoPertenceAGrupodeEspecificacao(cProdDes, cRevDes)

	If lSucesso
	
		//Realiza limpeza de resíduo da base relacionado registros gerados a partir do PCP indevidamente quando MV_QIPOPEP = 2 - DMANQUALI-6695
		If FindFunction("QIPA010LRB") .AND.;
			!Empty(cProdDes)          .AND.;
			!Empty(cRevDes)

			QIPA010LRB(cProdDes, cRevDes)

		EndIf

		//Realiza a Duplicacao da Especificacao do Produto
		lSucesso := QIPDupEsp( cProdOri, cRevOri ,   cRotDe, cProdDes, cRevDes,;
							   cRotAte , cDesPro ,   cGrupo, cRevGrp , lHelp  ,;
							   cRotPrim, cPrioRot, aOperDel, lDelSG2 ,cDescIn , cDescEs, cRotDes, cOrigem, nForcaModo, lMescla)
		
		If FWAliasIndic("QQO", .F.)
			oQIPXFUNAux:copiaVinculoDosArquivosDaManufaturaPorProduto(cFilQP6, cProdOri, cRevOri , cProdDes, cRevDes)
		EndIf

	EndIf

Return lSucesso

/*/{Protheus.doc} retornaProximaRevisao
Incrementa a revisão da especificação com base na revisão do produto destino
@author rafael.kleestadt
@since 06/04/2023
@version 1.0
@param 01 - cProduto, caracter, código do produto para analise
@param 02 - cRevisao, caracter, código da revisao para analise
@return return_var, return_type, return_description
/*/
Method retornaProximaRevisao(cProduto, cRevisao) CLASS QIPA012AuxClass
    Local nRec    := 0
    
    cRevisao := Iif(Empty(cRevisao), PadR( "", GetSx3Cache("QP6_REVI", "X3_TAMANHO"), "0" ), cRevisao)
    
    nRec := QP6->(recno())
    QP6->(dbSetOrder(1))
    While QP6->(DbSeek(xFilial('QP6') + cProduto + Inverte(cRevisao))) .AND. QP6->(!EOF())
        cRevisao := Soma1(QP6->QP6_REVI)
    EndDo
    QP6->(dbSetOrder(1))
    QP6->(DbGoTo(nRec))

Return cRevisao

/*/{Protheus.doc} QPA012RevS
Gerar Revisão para Especificação Simplificada (MV_QIPOPEP = 3)
@author brunno.costa
@since 27/08/2024
@version 1.0
/*/
Function QPA012RevS()

	Local aArea      := GetArea()
	Local aAreaQP6   := QP6->(GetArea())
	Local lSucesso   := .F.
	Local nOpcA      := Nil
	Local oQIP012Aux := QIPA012AuxClass():New()

	Private cDescEs   := ""
	Private cDescIn   := ""
	Private cProdDes  := QP6->QP6_PRODUT
	Private cProdPosi := QP6->QP6_PRODUT
	Private cRevDes   := oQIP012Aux:retornaProximaRevisao(QP6->QP6_PRODUT, QP6->QP6_REVI)
	Private lPrimeira := .F.

	BEGIN TRANSACTION

		//STR0089 - "Processando..."
		//STR0090 - "Aguarde o processamento da operação..."
		Processa({|| lSucesso := oQIP012Aux:geraRevisaoSimplificada() }, STR0089, STR0090)

		If lSucesso
			QP6->(DbSetOrder(2))
			If QP6->(DbSeek(xFilial("QP6") + cProdDes + cRevDes))
				nOpcA := QPA012Atu("QP6",QP6->(Recno()), 4, 10)
				If nOpcA == NIL .OR. nOpcA != 1
					DisarmTransaction()
				EndIf
			Endif
		Endif
	END TRANSACTION

	RestArea(aAreaQP6)
	RestArea(aArea)

Return

/*/{Protheus.doc} geraRevisaoSimplificada
Gera Revisão Simplificada da Especificação de Produtos
@author brunno.costa
@since 27/08/2024
@version 1.0
@return lSucesso, lógico, indica se realizou a geração da revisão simplificada com sucesso
/*/
METHOD geraRevisaoSimplificada() CLASS QIPA012AuxClass

	Local aOperDel    := Nil
	Local aRetTela    := Nil
	Local cDesPro     := Nil
	Local cFilQP6     := ""
	Local cGrupo      := Nil
	Local cOrigem     := Nil
	Local cPrioRot    := Nil
	Local cProdOri    := Nil
	Local cRevDes     := Nil
	Local cRevGrp     := Nil
	Local cRevOri     := Nil
	Local cRotAte     := Nil
	Local cRotDe      := Nil
	Local cRotPrim    := Nil
	Local lDelSG2     := Nil
	Local lHelp       := Nil
	Local lMescla     := Nil
	Local lSucesso    := .T.
	Local nForcaModo  := 0
	Local oQIPXFUNAux := QIPXFUNAuxClass():New()

	If GetMv("MV_QIPOPEP",.F.,"2") != "3"
		//STR0091 - "Réplica de dados dos roteiros entre QIP e PCP habilitada."
		//STR0092 - "Altere o parâmetro 'MV_QIPOPEP = 3' para desabilitar a réplica e tente novamente."
		Help(NIL, NIL, "NOPEPE3", NIL, STR0091 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0092})
		lSucesso := .F.
	EndIf

	lSucesso := lSucesso .And. !Self:validaSeProdutoPertenceAGrupodeEspecificacao(QP6->QP6_PRODUT, QA_NxtRevEsp(QP6->QP6_PRODUT,"QIP"))

	If lSucesso
		
		//Apresenta modo de cadastro destino para escolha do usuário
		aRetTela := QPA010Tela(2)
		If !aRetTela[CONFIRMOU_TELA]
			Return (NIL)
		EndIf
		nForcaModo  := aRetTela[MODO_SELECIONADO]

		//Valida se a especificação origem é compatível com o modo de cadastro selecionado (nForcaModo)
		If     nForcaModo == 1
			lSucesso := Self:compativelRevisaoApenasEnsaios(QP6->QP6_PRODUT, QP6->QP6_REVI)
		ElseIf nForcaModo == 2
			lSucesso := Self:compativelRevisaoOperacoesEEnsaios(QP6->QP6_PRODUT, QP6->QP6_REVI)
		EndIf

	EndIf


	If lSucesso 

		//Popula parâmetros da copia da Especificação
		cProdOri := QP6->QP6_PRODUT
		cRevOri  := QP6->QP6_REVI
		cRotDe   := PadR( "", GetSx3Cache("QP6_CODREC", "X3_TAMANHO"), " " )
		cProdDes := QP6->QP6_PRODUT
		cRevDes  := Self:retornaProximaRevisao(QP6->QP6_PRODUT, QP6->QP6_REVI)
		cRotAte  := PadR( "", GetSx3Cache("QP6_CODREC", "X3_TAMANHO"), "z" )
		cDesPro  := Self:retornaDescricaoProdutoDestino(QP6->QP6_PRODUT, QP6->QP6_PRODUT)
		cGrupo   := " "
		cRevGrp  := " "
		lHelp    := .T.
		cRotPrim := QP6->QP6_CODREC
		cPrioRot := cPrioriR
		aOperDel := Nil
		lDelSG2  := Nil
		cDescIn  := QP6->QP6_DESCIN
		cDescEs  := QP6->QP6_DESCES
		cRotDes  := Nil
		cOrigem  := Nil
		lMescla  := .F.
		cFilQP6  := QP6->QP6_FILIAL

		lSucesso := Self:validaPlanosDeAmostragem(cProdOri, cRevOri)

		If lSucesso
		
			//Realiza limpeza de resíduo da base relacionado registros gerados a partir do PCP indevidamente quando MV_QIPOPEP = 2 - DMANQUALI-6695
			If FindFunction("QIPA010LRB") .AND.;
			  !Empty(cProdDes)            .AND.;
			  !Empty(cRevDes)

				QIPA010LRB(cProdDes, cRevDes)

			EndIf

			//Realiza a Duplicacao da Especificacao do Produto
			lSucesso := QIPDupEsp( cProdOri, cRevOri ,   cRotDe, cProdDes, cRevDes,;
								   cRotAte , cDesPro ,   cGrupo, cRevGrp , lHelp  ,;
								   cRotPrim, cPrioRot, aOperDel, lDelSG2 ,cDescIn , cDescEs, cRotDes, cOrigem, nForcaModo, lMescla)
			If FWAliasIndic("QQO", .F.)
				oQIPXFUNAux:copiaVinculoDosArquivosDaManufaturaPorProduto(cFilQP6, cProdOri, cRevOri , cProdDes, cRevDes)
			EndIf
		EndIf

		
	Else

		lSucesso := .F.

	EndIf

Return lSucesso

/*/{Protheus.doc} compativelRevisaoApenasEnsaios
Valida se a Especificação de Produtos origem é compatível nova revisão do modo de tela "1 - Apenas Ensaios"
@author brunno.costa
@since 27/08/2024
@version 1.0
@param 01 - cProduto, caracter, código do produto origem
@param 02 - cRevisao, caracter, código da revisão origem
@return lCompativel, lógico, indica se é compatível com a copia 1 - Apenas Ensaios
/*/
METHOD compativelRevisaoApenasEnsaios(cProduto, cRevisao) CLASS QIPA012AuxClass
	Local lCompativel  := .T.
	Local nNaoGenerico := Self:retornaPercentualUsoRoteiroEOperacaoUnicosNaoGenericos(cProduto, cRevisao)
	Local nGenerico    := Self:retornaPercentualUsoRoteiroEOperacaoUnicosGenericos(cProduto, cRevisao)

	If nNaoGenerico != 1
		If nGenerico != 1
			lCompativel := .F.
			//STR0093 - "A especificação de produtos origem é incompatível com o modo de cadastro 1 - Apenas Ensaios."
			//STR0094 - "Utilize outra opção de revisão ou cópia."
			Help(NIL, NIL, "QP012NoTela1", NIL, STR0093 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0094})
		EndIf
	EndIf

Return lCompativel

/*/{Protheus.doc} compativelRevisaoOperacoesEEnsaios
Valida se a Especificação de Produtos origem é compatível nova revisão do modo de tela "2 - Operações e Ensaios"
@author brunno.costa
@since 27/08/2024
@version 1.0
@param 01 - cProduto, caracter, código do produto origem
@param 02 - cRevisao, caracter, código da revisão origem
@return lCompativel, lógico, indica se é compatível com a copia 2 - Operações e Ensaios
/*/
METHOD compativelRevisaoOperacoesEEnsaios(cProduto, cRevisao) CLASS QIPA012AuxClass
	Local lCompativel   := .T.
	Local nNaoGenerico  := Self:retornaPercentualUsoRoteiroUnicoNaoGenerico(cProduto, cRevisao)
	Local nGenerico     := Self:retornaPercentualUsoRoteiroUnicoGenerico(cProduto, cRevisao)
	Local nFullGenerico := Self:retornaPercentualUsoRoteiroEOperacaoUnicosGenericos(cProduto, cRevisao)

	If nNaoGenerico != 1
		If nGenerico != 1
			lCompativel := .F.
			//STR0095 - "A especificação de produtos origem é incompatível com o modo de cadastro 2 - Operações e Ensaios."
			//STR0094 - "Utilize outra opção de revisão ou cópia."
			Help(NIL, NIL, "QP012NoTela2", NIL, STR0095 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0094})
		EndIf
	EndIf

	If nFullGenerico
		lCompativel := .F.
		//STR0095 - "A especificação de produtos origem é incompatível com o modo de cadastro 2 - Operações e Ensaios."
		//STR0094 - "Utilize outra opção de revisão ou cópia."
		Help(NIL, NIL, "QP012NoTela3", NIL, STR0095 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0094})
	EndIf
	
Return lCompativel

/*/{Protheus.doc} retornaPercentualUsoRoteiroUnicoNaoGenerico
Retorna percentual do uso de roteiros únicos e não genéricos na base
@since 27/08/2023
@version P12.1.2310
@return nResultados, numérico, percentual do uso de roteiros únicos e não genéricos na base
/*/
METHOD retornaPercentualUsoRoteiroUnicoNaoGenerico(cProduto, cRevisao) CLASS QIPA012AuxClass

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0

    cQuery += " SELECT ROTEIROS, ROTEIROS_UNICOS "
    cQuery += " FROM (SELECT COUNT(QQK_CODIGO) ROTEIROS "
    cQuery +=       " FROM " + RetSQLName("QQK")
    cQuery +=       " WHERE (D_E_L_E_T_ = ' ') AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "')) CONTAGEM_TOTAL, "
    cQuery +=      " (SELECT COALESCE(SUM(ROTEIROS_UNICOS), 0) ROTEIROS_UNICOS "
    cQuery +=       " FROM (SELECT COUNT(QQK_CODIGO) ROTEIROS_UNICOS "
    cQuery +=             " FROM (SELECT DISTINCT QQK_PRODUT, QQK_REVIPR, QQK_CODIGO "
    cQuery +=                    " FROM " + RetSQLName("QQK")
    cQuery +=                    " WHERE (D_E_L_E_T_ = ' ') AND (QQK_CODIGO <> '**') AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "') ) ROTEIROS "
    cQuery +=             " GROUP BY QQK_PRODUT, QQK_REVIPR "
    cQuery +=             " HAVING   (COUNT(QQK_CODIGO) = 1)) ROTEIROS_UNICOS) SOMA_UNICOS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!EOF())
        nResultados := Round((cAliasQry)->ROTEIROS_UNICOS / (cAliasQry)->ROTEIROS, 2)
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} retornaPercentualUsoRoteiroEOperacaoUnicosNaoGenericos
Retorna percentual do uso de roteiros e operações únicos e não genéricos na base
@since 27/08/2023
@version P12.1.2310
@return nResultados, numérico, percentual do uso de roteiros e operações únicos e não genéricos na base
/*/
METHOD retornaPercentualUsoRoteiroEOperacaoUnicosNaoGenericos(cProduto, cRevisao) CLASS QIPA012AuxClass

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0
	Local oQLTQueryM  := QLTQueryManager():New()

    cQuery += " SELECT OPERACOES, OPERACOES_UNICAS "
    cQuery += " FROM (SELECT COUNT(QQK_OPERAC) OPERACOES "
    cQuery +=       " FROM " + RetSQLName("QQK")
    cQuery +=       " WHERE (D_E_L_E_T_ = ' ') AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "')) CONTAGEM_TOTAL, "
    cQuery +=      " (SELECT COALESCE(SUM(OPERACOES_UNICAS), 0) OPERACOES_UNICAS "
    cQuery +=       " FROM (SELECT QQK_PRODUT, QQK_REVIPR, QQK_CODIGO , COUNT(QQK_OPERAC) OPERACOES_UNICAS "
    cQuery +=             " FROM  " + RetSQLName("QQK")
    cQuery +=             " WHERE (D_E_L_E_T_ = ' ') AND ((QQK_CODIGO <> '**') OR (QQK_OPERAC <> '**')) AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "') "
    cQuery +=             " GROUP BY QQK_PRODUT, QQK_REVIPR, QQK_CODIGO "
    cQuery +=             " HAVING   (COUNT(CONCAT(QQK_CODIGO,QQK_OPERAC)) = 1)) CONTAGEM_UNICAS "
    cQuery +=       " INNER JOIN "
    cQuery +=            " (SELECT QQK_PRODUT, QQK_REVIPR, COUNT(QQK_CODIGO) ROTEIROS_UNICOS "
    cQuery +=             " FROM  " + RetSQLName("QQK")
    cQuery +=             " WHERE (D_E_L_E_T_ = ' ') AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "') "
    cQuery +=             " GROUP BY QQK_PRODUT, QQK_REVIPR "
    cQuery +=             " HAVING   (COUNT(QQK_CODIGO) = 1)) CONTAGEM_UNICOS "
    cQuery +=       " ON CONTAGEM_UNICAS.QQK_PRODUT = CONTAGEM_UNICOS.QQK_PRODUT AND CONTAGEM_UNICAS.QQK_REVIPR = CONTAGEM_UNICOS.QQK_REVIPR "
    cQuery +=       " ) SOMA_UNICAS "
		
	cQuery    := oQLTQueryM:changeQuery(cQuery)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!EOF())
        nResultados := Round((cAliasQry)->OPERACOES_UNICAS / (cAliasQry)->OPERACOES, 2)
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} retornaPercentualUsoRoteiroUnicoGenerico
Retorna percentual do uso de roteiros únicos e genéricos na base
@since 27/08/2023
@version P12.1.2310
@return nResultados, numérico, percentual do uso de roteiros únicos e genéricos na base
/*/
METHOD retornaPercentualUsoRoteiroUnicoGenerico(cProduto, cRevisao) CLASS QIPA012AuxClass

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0

    cQuery += " SELECT ROTEIROS, ROTEIROS_UNICOS "
    cQuery += " FROM (SELECT COUNT(QQK_CODIGO) ROTEIROS "
    cQuery +=       " FROM " + RetSQLName("QQK")
    cQuery +=       " WHERE (D_E_L_E_T_ = ' ') AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "')) CONTAGEM_TOTAL, "
    cQuery +=      " (SELECT COALESCE(SUM(ROTEIROS_UNICOS), 0) ROTEIROS_UNICOS "
    cQuery +=       " FROM (SELECT COUNT(QQK_CODIGO) ROTEIROS_UNICOS "
    cQuery +=             " FROM (SELECT DISTINCT QQK_PRODUT, QQK_REVIPR, QQK_CODIGO "
    cQuery +=                    " FROM " + RetSQLName("QQK")
    cQuery +=                    " WHERE (D_E_L_E_T_ = ' ') AND (QQK_CODIGO = '**') AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "') ) ROTEIROS "
    cQuery +=             " GROUP BY QQK_PRODUT, QQK_REVIPR "
    cQuery +=             " HAVING   (COUNT(QQK_CODIGO) = 1)) ROTEIROS_UNICOS) SOMA_UNICOS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!EOF())
        nResultados := Round((cAliasQry)->ROTEIROS_UNICOS / (cAliasQry)->ROTEIROS, 2)
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} retornaPercentualUsoRoteiroEOperacaoUnicosGenericos
Retorna percentual do uso de roteiros e operações únicos e genéricos na base
@since 27/08/2023
@version P12.1.2310
@return nResultados, numérico, percentual do uso de roteiros e operações únicos e genéricos na base
/*/
METHOD retornaPercentualUsoRoteiroEOperacaoUnicosGenericos(cProduto, cRevisao) CLASS QIPA012AuxClass

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0

    cQuery += " SELECT OPERACOES, OPERACOES_UNICAS "
    cQuery += " FROM (SELECT COUNT(QQK_OPERAC) OPERACOES "
    cQuery +=       " FROM " + RetSQLName("QQK")
    cQuery +=       " WHERE (D_E_L_E_T_ = ' ') AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "')) CONTAGEM_TOTAL, "
    cQuery +=      " (SELECT COALESCE(SUM(OPERACOES_UNICAS), 0) OPERACOES_UNICAS "
    cQuery +=       " FROM (SELECT QQK_PRODUT, QQK_REVIPR, QQK_CODIGO , COUNT(QQK_OPERAC) OPERACOES_UNICAS "
    cQuery +=             " FROM  " + RetSQLName("QQK")
    cQuery +=             " WHERE (D_E_L_E_T_ = ' ') AND (QQK_CODIGO = '**') AND (QQK_OPERAC = '**') AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "') "
    cQuery +=             " GROUP BY QQK_PRODUT, QQK_REVIPR, QQK_CODIGO "
    cQuery +=             " HAVING   (COUNT(CONCAT(QQK_CODIGO,QQK_OPERAC)) = 1)) CONTAGEM_UNICAS "
    cQuery +=       " INNER JOIN "
    cQuery +=            " (SELECT QQK_PRODUT, QQK_REVIPR, COUNT(QQK_CODIGO) ROTEIROS_UNICOS "
    cQuery +=             " FROM  " + RetSQLName("QQK")
    cQuery +=             " WHERE (D_E_L_E_T_ = ' ') AND (QQK_PRODUT = '" + cProduto + "') AND (QQK_REVIPR = '" + cRevisao + "') "
    cQuery +=             " GROUP BY QQK_PRODUT, QQK_REVIPR "
    cQuery +=             " HAVING   (COUNT(QQK_CODIGO) = 1)) CONTAGEM_UNICOS "
    cQuery +=       " ON CONTAGEM_UNICAS.QQK_PRODUT = CONTAGEM_UNICOS.QQK_PRODUT AND CONTAGEM_UNICAS.QQK_REVIPR = CONTAGEM_UNICOS.QQK_REVIPR "
    cQuery +=       " ) SOMA_UNICAS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!EOF())
        nResultados := Round((cAliasQry)->OPERACOES_UNICAS / (cAliasQry)->OPERACOES, 2)
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} possuiOperacoesOuEnsaios
Indica se o produto e revisão possui especificação com roteiro ou operacoes
@author brunno.costa
@since 17/09/2024
@version 1.0
@param 01 - cProduto, caracter, codigo do produto
@param 02 - cRevisao, caracter, codigo da revisao
@return lPossui, logico, indica se o produto e revisão possui especificação com roteiro ou operacoes
/*/

METHOD possuiOperacoesOuEnsaios(cProduto, cRevisao) CLASS QIPA012AuxClass

	Local cAliasQry  := Nil
    Local cQuery     := ""
    Local lPossui    := .F.
	Local oQLTQueryM := Nil

    cQuery += " SELECT QQK_PRODUT AS PRODUTO "
    cQuery += " FROM " + RetSQLName("QQK")
    cQuery += " WHERE "
	cQuery +=     " QQK_FILIAL = '" + xFilial("QQK") + "' "
	cQuery += " AND QQK_PRODUT = '" + cProduto + "' "
	cQuery += " AND QQK_REVIPR = '" + cRevisao + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " UNION "
    cQuery += " SELECT QP7_PRODUT AS PRODUTO "
    cQuery += " FROM " + RetSQLName("QP7")
    cQuery += " WHERE "
	cQuery +=     " QP7_FILIAL = '" + xFilial("QP7") + "' "
	cQuery += " AND QP7_PRODUT = '" + cProduto + "' "
	cQuery += " AND QP7_REVI   = '" + cRevisao + "' "
	cQuery += " AND QP7_ENSAIO <> ' ' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " UNION "
    cQuery += " SELECT QP8_PRODUT AS PRODUTO "
    cQuery += " FROM " + RetSQLName("QP8")
    cQuery += " WHERE  " "
	cQuery +=     " QP8_FILIAL = '" + xFilial("QP8") + "' "
	cQuery += " AND QP8_PRODUT = '" + cProduto + "' "
	cQuery += " AND QP8_REVI   = '" + cRevisao + "' "
	cQuery += " AND QP8_ENSAIO <> ' ' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	lPossui := !FindClass("QLTQueryManager")

	If (!lPossui)
		oQLTQueryM := QLTQueryManager():New()
		cQuery     := oQLTQueryM:changeQuery(cQuery)
		cAliasQry  := oQLTQueryM:executeQuery(cQuery)

		(cAliasQry)->(DbGoTop())
		If (cAliasQry)->(!EOF())
			lPossui := !Empty((cAliasQry)->PRODUTO)
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

Return lPossui
