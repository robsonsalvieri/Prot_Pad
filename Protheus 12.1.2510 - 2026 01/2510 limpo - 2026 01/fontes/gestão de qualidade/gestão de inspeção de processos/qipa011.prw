#INCLUDE "QIPA011.CH"
#INCLUDE "TOTVS.CH"

#Define _ROT 1 //Roteiro
#Define _OPE 2 //Operacao
#Define _RAS 3 //Rastreabilidade
#Define _TXT 4 //Observacoes da Operacao
#Define _ENS 5 //Ensaio
#Define _INS 6 //Instrumentos
#Define _NCO 7 //Nao-conformidades
#Define _PAE 8 //Plano de Amostragem por Ensaio

#DEFINE CONFIRMOU_TELA   1
#DEFINE MODO_SELECIONADO 2

Static lPriModTel := .T. //Controle primeira exibição de inclusão contínua
Static lQP010TeDB := FindFunction("QPA010TeDB")
Static lQP010Tela := FindFunction("QPA010Tela")
Static nCacheTela := 0 //Guarda o último modo de tela escolhido em inclusão na Thread
Static slQAXA090  := FindFunction("QAXA090")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QIPA011  ³ Autor ³ Cleber Souza          ³ Data ³14/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de atualizacao das Especificacoes de Produtos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIP													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado -> STR0029                                ³±±
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

Local aRotina := { 	{OemtoAnsi(STR0001),"AxPesqui"   ,0, 1,,.F.},; //"Pesquisar"
					{OemtoAnsi(STR0002),"QPA011Atu"  ,0, 2   },;   //"Visualizar"
					{OemtoAnsi(STR0003),"QPA011Atu"  ,0, 3   },;   //"Incluir"
					{OemtoAnsi(STR0004),"QPA011Atu"  ,0, 4, 2},;   //"Alterar"
					{OemtoAnsi(STR0005),"QPA011Atu"  ,0, 5, 1},;   //"Excluir"
					{OemtoAnsi(STR0006),"QPA011BLOQ" ,0, 5   },;   //"Bloqueio / Desbloqueio"
					{OemToAnsi(STR0008),"QPA011Dup"  ,0, 4   },;   //"Gera Rev."
					{OemtoAnsi(STR0007),"QPA011LegOp",0, 5,,.F.}}  //"Legenda"


Return aRotina

Function QIPA011()

Local   cAlias     := "QQC"
Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo
Private aSitEsp    := {}
Private cCadastro  := OemtoAnsi(STR0009) //"Especificacao por Grupo"
Private lAPS       := TipoAps() //Inicia a variavel lAPS que e utilizada no Roteiro de Operacoes do PCP

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

Aadd(aSitEsp,{"QQC->QQC_SITREV=='0'.OR.QQC->QQC_SITREV==' '","BR_VERDE"}) //Revisão Disponivel
Aadd(aSitEsp,{"QQC->QQC_SITREV=='1'","BR_VERMELHO"})                      //Revisão Bloqueada
Aadd(aSitEsp,{"QQC->QQC_SITREV=='2'","BR_AMARELO"})                       //Revisão Pendente

mBrowse(06,01,22,75,cAlias,,,,,,aSitEsp)
dbSelectArea(cAlias)

dbClearFilter()

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA011Atu ³ Autor ³Cleber Souza           ³ Data ³14/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o status dos Documentos Anexos aos Ensaios     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011Atu(cAlias,nReg,nOpc)					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias											  ³±±
±±³			 ³ EXPN1 = Numero do Registro								  ³±±
±±³			 ³ EXPN2 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 		 = Nulo												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPA011Atu(cAlias,nReg,nOpc)

Local aCampos    := {}
Local aFiltroQQO := {}
Local aPagEns    := Nil
Local aPagEsp    := Nil
Local aPagFldPr  := Nil
Local aRetTela   := {}
Local aTitEns    := Nil
Local aTitEsp    := Nil
Local aTitFldPr  := Nil
Local bCancel    :={||lPriModTel := .T.                     , nOpcA := 0              , oDlg:End()}
Local bOk        :={||lPriModTel := Iif(nOpc == 3, .F., .T.), nOpcA := QPA011bOk(nOpc), IIF(nOpcA == 1,oDlg:End(),"")}
Local nCkDel     := 0
Local nFatDiv    := 1
Local nOpcA      := 0
Local nOpcGD     := If(nOpc==3 .Or. nOpc==4,GD_UPDATE+GD_INSERT+GD_DELETE,0) //Opcao utilizada na NewGetDados
Local oDlg       := NIL
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

Private cEspecie := "QIPA010 " //Chave que indentifica a gravacao do texto dos produtos definidos no Grupo
Private lOrdLab  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros utilizados na rotina							     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lDelSG2 := GetMv("MV_QPDELG2",.F.,.F.)
Private lIntQMT := If(GetMV('MV_QIPQMT')=="S",.T.,.F.) //Define a Integracao com o QMT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pontos de Entradas utilizados na rotina de Especificacao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private __lQP010DEL    := ExistBlock("QP010DEL")
Private __lQP010GRV    := ExistBlock("QP010GRV")
Private __lQP010OPE    := ExistBlock("QP010OPE")
Private __lQPA010R     := ExistBlock("QPA010R")
Private aEspecificacao := {} //Armazena os dados referentes a Especificacao do Produto
Private aGets          := {}
Private aRoteiros	   := {} //Armazena os Roteiros de Operação relacionados ao Produto
Private aTela          := {}
Private lQIP011JR      := ExistBlock("QIP011JR")
Private lQP011J11      := ExistBlock("QP011J11")
Private lQPATUGRV      := ExistBlock("QPATUGRV")
Private oEncEsp        := NIL//Cabecalho da Especificacao do Produto
Private oGetEns        := NIL//Ensaios associados aos Roteiros de Operacoes
Private oGetIns        := NIL//Familia de Instrumentos
Private oGetNCs        := NIL//Nao-conformidades
Private oGetOper       := NIL//Roteiro de Operacoes Quality
Private oGetRas        := NIL//Rastreabilidade
Private oGetRot        := NIL//Roteiros relacionados a especificação

//Define as coordenadas da Tela
Private aInfo	 := {}
Private aObjects := {}
Private aSize	 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os aHeaders utilizados na Especificacao do Produto (Estrutura)	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeaderROT := {}
Private aHeaderQQK := aClone(QP10FillG("QQK", Nil, Nil, Nil, Nil))
Private aHeaderQP7 := aClone(QPA010HeadEsp(aClone(QP10FillG("QP7", Nil, Nil, Nil, Nil)))) //Prepara o aHeader com os demais campos a serem utilizados na Especificacao
Private aHeaderQQ1 := aClone(QP10FillG("QQ1", Nil, Nil, Nil, Nil))
Private aHeaderQP9 := aClone(QP10FillG("QP9", Nil, Nil, Nil, Nil))
Private aHeaderQQ2 := aClone(QP10FillG("QQ2", Nil, Nil, Nil, Nil))
Private aHeaderQQH := aClone(QP10FillG("QQH", Nil, Nil, Nil, Nil))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Roteiros (QQK)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosChav    := AsCan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_CHAVE"  })
Private nPosDescri  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_DESCRI" })
Private nPosGruRec  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_GRUPRE" })
Private nPosLauObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_LAU_OB" })
Private nPosOpeGrp  := Ascan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_OPERGR" })
Private nPosOpeObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPE_OB" })
Private nPosOper    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPERAC" })
Private nPosRecurso := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_RECURS" })
Private nPosSeqObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_SEQ_OB" })
Private nPosSetUp   := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_SETUP"  })
Private nPosTemPad  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPAD" })
Private nPosTpOper  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPOPER" })
Private nTempDes    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPDES"})
Private nTempSobre  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPSOB"})
Private nTipoDes    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPDESD" })
Private nTipoSobre  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPSOBRE"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados Rastreabilidade (QQ2) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosDesc  := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_DESC"  })
Private nPosRastr := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_PRODUT"})
Private nPosTipo  := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_TIPO"  })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o texto do produto por Operacao 					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cTexto := Space(TamSX3("QA2_TEXTO")[1])
Private oTexto := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Ensaios (QP7/QP8) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosAFI   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFI"   })
Private nPosAFS   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFS"   })
Private nPosCer   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_CERTIF"})
Private nPosDEn   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_DESENS"})
Private nPosDoc	  := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosDPl   := Ascan(aHeaderQP7,{|x|AllTrim(x[2])=="QP7_DESPLA"})
Private nPosEns   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSAIO"})
Private nPosFor   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_FORMUL"})
Private nPosLab   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LABOR" })
Private nPosLIC   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LIC"   })
Private nPosLSC   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LSC"   })
Private nPosMet   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosMin   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_MINMAX"})
Private nPosNiv   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NIVEL" })
Private nPosNom   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NOMINA"})
Private nPosObr   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSOBR"})
Private nPosPlA   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_PLAMO" })
Private nPosRvDoc := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_RVDOC" })
Private nPosSeq   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_SEQLAB"})
Private nPosTipIn := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_TIPO"  })
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
Private nEnsaio    := 1   //Indica a posicao do Ensaio corrente
Private nOperacao  := 1   //Indica a posicao da Operacao corrente
Private nPosAmo    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_AMOST" })
Private nPosDscPAE := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_DESCRI"})
Private nPosNivel  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NIVAMO"})
Private nPosNQA    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NQA"   })
Private nPosPlano  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_PLANO"})
Private nRoteiro   := 1   //Indica a posicao do Roteiro corrente

Private nModoTela := Iif(lPriModTel, 0, nCacheTela)
Private aDataQQO  := Nil

If cPrioriR == "3" .AND. nOpc==3 .AND. nModoTela == 0 .AND. lQP010Tela//Inclusão
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

If (nOpc==3) //Inclusão
	If cPrioriR == "3"
		cCadastro := AllTrim(OemtoAnsi(STR0009)) + " [" + cValToChar(nModoTela) +"]"       //"Especificacao por Grupo"
		cCadastro   += " - " + Capital(AllTrim(aRotina[nOpc, 1]))
	Else
		cCadastro   := AllTrim(OemtoAnsi(STR0009)) + " - " + Capital(AllTrim(aRotina[nOpc, 1]))//"Especificacao por Grupo"
	EndIf
Else
	If cPrioriR == "3" .AND. lQP010TeDB
		nModoTela := QPA010TeDB(.T.)
		cCadastro := AllTrim(OemtoAnsi(STR0009)) + " [" + cValToChar(nModoTela) +"]"       //"Especificacao por Grupo"
		cCadastro += " - " + Capital(AllTrim(aRotina[nOpc, 1]))
	Else
		cCadastro   := AllTrim(OemtoAnsi(STR0009)) + " - " + Capital(AllTrim(aRotina[nOpc, 1]))//"Especificacao por Grupo"
	EndIf
EndIf

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

If (nOpc <> 3)
	QPA->(dbSetOrder(1))
	If QPA->(!dbSeek( xFilial("QPA")+M->QQC_GRUPO))
		Help(" ",1,"QP010NGRUP",,M->QQC_GRUPO,1) //O Grupo nao esta definido na Amarracao   Grupo x Produtos.
		Return(NIL)
	EndIf
EndIf

If (nOpc==4 .Or. nOpc==5) //Alteracao ou Exclusao
	If ( QIPCheckEsp(M->QQC_GRUPO,M->QQC_REVI,.T.,,nOpc) )
		// Se houver OP associada na especificação não permite alterar a especificação
		If ( !QIPChkEspOP(M->QQC_GRUPO,M->QQC_REVI,.T.,,nOpc) )
			Return(NIL)
		EndIf
	Else
		Return(NIL)
	EndIf 
EndIf

If (nOpc==5)    	// inserido para evitar a exclusão do grupo quando existem laudos, antes
	nCkDel := 0     // era validado em QP011AtuGru, porem excluia o grupo
	dbselectarea("QP6")
	QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
	QP6->(dbSeek(xFilial("QP6")+M->QQC_GRUPO+M->QQC_REVI))
	While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(xFilial("QP6")+M->QQC_GRUPO+M->QQC_REVI)
		If QP6->QP6_RESULT == "S"
			nCkDel := 1
		EndiF
		QP6->(dbSkip())
	EndDo
	if nCkDel > 0
		HELP(" ",1,"QIP011LAUD")
		Return (NIL)
	EndIf
Endif

//Monta estrutuda da array dos roteiros de operacao
Aadd(aHeaderRot,{STR0015,"ROT_CODREC","@!",GetSx3Cache("QP6_CODREC","X3_TAMANHO"),0,"QIP010GARO()",,"C","SG2",,,,".T."})   //"Roteiro"
Aadd(aHeaderRot,{STR0016,"ROT_CODDES","@!",100,0,,,"C",,,,,".T."})  //"Tipo do Roteiro"

//Calcula dimensões da Tela Principal
oSizeDlg := FwDefSize():New(.T.,,,oDlg)
oSizeDlg:AddObject( "FULL"   , 100, 100, .T., .T. ) // Totalmente dimensionavel
oSizeDlg:lProp    := .T.                            // Proporcional
oSizeDlg:aMargins := { 3, 3, 3, 3 }                 // Espaco ao lado dos objetos 0, entre eles 3
oSizeDlg:Process()                                  // Dispara os calculos

//Tela principal da Rotina
DEFINE MSDIALOG oDlg TITLE cCadastro From oSizeDlg:aWindSize[1],oSizeDlg:aWindSize[2] to oSizeDlg:aWindSize[3],oSizeDlg:aWindSize[4] OF oMainWnd PIXEL

aTitFldPr := {}
Aadd(aTitFldPr,OemToAnsi(STR0039)) //"Grupo"
If cPrioriR != "3" .OR. cPrioriR == "3" .AND. nModoTela == 3
	Aadd(aTitFldPr,OemToAnsi(STR0040)) //"Especificação do Roteiro"
Else
	Aadd(aTitFldPr,OemToAnsi(STR0041)) //"Especificação"
EndIf

aPagFldPr := {}
Aadd(aPagFldPr,OemToAnsi("GRUPO"))
Aadd(aPagFldPr,OemToAnsi("ESPECIFICACAO"))

//Cria FOLDER PRIMÁRIO Aba "Grupo" [1] x Aba "Especificação" [2]
oFldMain            := TFolder():New(oSizeDlg:aWindSize[1],oSizeDlg:aWindSize[2],aTitFldPr,aPagFldPr,oDlg,,,,.T.,.F.,oSizeDlg:aWindSize[3],oSizeDlg:aWindSize[4])
oFldMain:bSetOption := {|nPos| QP10ROTUOK(nPos) }
oFldMain:Align      := CONTROL_ALIGN_ALLCLIENT


//Cria componentes para Aba "Grupo" [1]
oPanelAbaA       := TPanel():New(0,0,'', oFldMain:aDialogs[1],,,,,,oDlg:nClientWidth, oDlg:nClientHeight)
oPanelAbaA:Align := CONTROL_ALIGN_ALLCLIENT

oSplitAbaA       := tSplitter():New(0, 0, oPanelAbaA, oPanelAbaA:nClientWidth, oPanelAbaA:nClientHeight, 1)
oSplitAbaA:Align := CONTROL_ALIGN_ALLCLIENT

oSizeA           := FwDefSize():New(.T.,,,oSplitAbaA)


//Cria componentes para Aba "Especificação" [2]
oPanelAbaB       := TPanel():New(0,0,'', oFldMain:aDialogs[2],,,,,,oDlg:nClientWidth, oDlg:nClientHeight)
oPanelAbaB:Align := CONTROL_ALIGN_ALLCLIENT

oSplitAbaB       := tSplitter():New(0, 0, oPanelAbaB, oPanelAbaB:nClientWidth, oPanelAbaB:nClientHeight, 1)
oSplitAbaB:Align := CONTROL_ALIGN_ALLCLIENT

oSizeB := FwDefSize():New(.T.,,,oSplitAbaB)


//Controla Exibição de Componentes conforme seleção de tela quando MV_QIPOPEP = 3
If cPrioriR != "3" .OR. cPrioriR == "3" .AND. nModoTela == 3
	oSizeA:AddObject( "CABECALHO"     , 100, 40, .T., .T. ) // Totalmente dimensionavel
	oSizeA:AddObject( "ROTEIRO"       , 100, 60, .T., .T. ) // Totalmente dimensionavel

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


//[1.1 - Folder Grupo + Cabecalho da Especificacao do Produto]
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)

If cPrioriR == "3" .AND. nModoTela != 3
	M->QQC_CODREC := QIPRotGene("QQC_CODREC")
	cRoteiro      := QIPRotGene("QQC_CODREC")
EndIf

aCampos := QIPA011AuxClass():retornaCamposDaTabelaDeEspecificacacaoDeGruposConformeMVQIPOPEPeModoEscolhido(cPrioriR, nModoTela)

nLinIni := oSizeA:GetDimension("CABECALHO","LININI")
nColIni := oSizeA:GetDimension("CABECALHO","COLINI")
nLinEnd := oSizeA:GetDimension("CABECALHO","LINEND")*0.60
nColEnd := oSizeA:GetDimension("CABECALHO","COLEND")*0.50

oEncEsp := MsMGet():New(cAlias,nReg,nOpc,,,,aCampos,{nLinIni,nColIni,nLinEnd,nColEnd},,3,,,,oSplitAbaA,,.F.,,,,,,,.T.)
oEncEsp:oBox:Align := CONTROL_ALIGN_ALLCLIENT


//Prepara os dados da Especificacao por Grupo para Edicao
If !(QPA011FilGrp(M->QQC_GRUPO,M->QQC_REVI))
	Return(NIL)
EndIf


//[1.2 - Folder Grupo + Grid de Roteiros relacionados à Especificação]
nLinIni := oSizeA:GetDimension("ROTEIRO","LININI")
nColIni := oSizeA:GetDimension("ROTEIRO","COLINI")
nLinEnd := oSizeA:GetDimension("ROTEIRO","LINEND")
nColEnd := oSizeA:GetDimension("ROTEIRO","COLEND")

oGetRot := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||!Empty(oGetRot:aCols[oGetRot:oBrowse:nAT,1])}, {|| IIf(nOpc != 5,QP10ROTUOK(), .T.) } ,"",aAlterRot,,9999,,,,oSplitAbaA,aHeaderROT,aRoteiros)
oGetRot:oBrowse:bChange    := {||FolderChange("7",nOpc)}
oGetRot:oBrowse:bDelOk     := {||FolderDelete("7")}
oGetRot:oBrowse:bGotFocus  := {||FolderValid("0")}
oGetRot:oBrowse:bLostFocus := {||FolderSave("7")}
oGetRot:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

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
oGetOper:oBrowse:bChange    := {||FolderChange("1",nOpc)}
oGetOper:oBrowse:bDelOk     := {||FolderDelete("14")}
oGetOper:oBrowse:bGotFocus  := {||FolderValid("0")}
oGetOper:oBrowse:bLostFocus := {||FolderSave("1")}
//oGetOper:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT - NÃO USAR, DISTORCE FUNCIONAMENTO COM MUITA ALTURA

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
Aadd(aTitEsp, OemToAnsi(STR0042)) //"Ensaios"
Aadd(aTitEsp, OemToAnsi(STR0011)) //"Rastreabilidade"
Aadd(aTitEsp, OemToAnsi(STR0012)) //"Observacao da Operacao"

aPagEsp := {}
Aadd(aPagEsp, "ENSAIOS")
Aadd(aPagEsp, "RASTREABILIDADE")
Aadd(aPagEsp, "OBSERVACAO-DA-OPERACAO")

oFldEsp := TFolder():New(nLinIni,nColIni,aTitEsp,aPagEsp,oSplitAbaB,,,,.T.,.F.,nLinEnd,nColEnd)
oFldEsp:Align := CONTROL_ALIGN_ALLCLIENT

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
oSizeC:AddObject( "ENSAIOS"        , 100, 50, .T., .T. )        // Totalmente dimensionavel
oSizeC:AddObject( "FOLDER_INSTRUMENTOS"   , 100, 50, .T., .T. ) // Totalmente dimensionavel
oSizeC:lProp    := .T.                                          // Proporcional
oSizeC:aMargins := { 3, 3, 3, 3 }                               // Espaco ao lado dos objetos 0, entre eles 3
oSizeC:Process()                                                // Dispara os calculos

nLinIni := oSizeC:GetDimension("ENSAIOS","LININI")
nColIni := oSizeC:GetDimension("ENSAIOS","COLINI")
nLinEnd := oSizeC:GetDimension("ENSAIOS","LINEND")
nColEnd := oSizeC:GetDimension("ENSAIOS","COLEND")


//[2.2.1.1 - Folder Especificação + Folder de Ensaios + Aba Ensaios + GRID de Ensaios]
//[GRID de Ensaios relacionada A CADA OPERAÇÃO]
oGetEns := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10ENLIOK()},{||QP10ENTUOK()},,,,9999,,,,oSplitEns,aHeaderQP7,aEspecificacao[nRoteiro,_ENS,nOperacao])
oGetEns:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGetEns:oBrowse:bChange    := {||FolderChange("4",nOpc)}
oGetEns:oBrowse:bDelOk     := {||FolderDelete("4")}
oGetEns:oBrowse:bGotFocus  := {||FolderValid("01")}
oGetEns:oBrowse:bLostFocus := {||FolderSave("4")}
oGetEns:oBrowse:bEditCol   := {||QP010Ordena()}
oGetEns:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


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
oGetIns := MsNewGetDados():New(000,000,047,380,nOpcGD,{||QP10INSLIOK()},{||QP10INSTUOK()},,aAlterIns,,9999,,,,oFldEns:aDialogs[1],aHeaderQQ1,aEspecificacao[nRoteiro,_INS,nOperacao,nEnsaio])
oGetIns:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGetIns:oBrowse:bGotFocus  := {||FolderValid("014")}
oGetIns:oBrowse:bLostFocus := {||FolderSave("5")}
oGetIns:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


//[2.2.1.2.2 - Folder Especificação + Folder de Ensaios + Aba Ensaios + Folder Família de Instrumentos + Aba Não Conformidades]
//[GRID Nao-conformidades A CADA ENSAIO]
oGetNCs := MsNewGetDados():New(000,000,047,380,nOpcGD,{||QP10NCLIOK()},{||QP10NCTUOK()},,,,9999,,,,oFldEns:aDialogs[2],aHeaderQP9,aEspecificacao[nRoteiro,_NCO,nOperacao,nEnsaio])
oGetNCs:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGetNCs:oBrowse:bGotFocus  := {||FolderValid("014")}
oGetNCs:oBrowse:bLostFocus := {||FolderSave("6")}
oGetNCs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT



//[2.2.2 - Folder Especificação + Folder de Ensaios + Aba Rastreabilidade]
//[GRID de Rastreabilidade a CADA OPERACAO]
oGetRas := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10RSLIOK(Nil,.T.)},{||QP10RSTUOK(Nil,.T.)},,,,9999,,,,oFldEsp:aDialogs[2],aHeaderQQ2,aEspecificacao[nRoteiro,_RAS,nOperacao])
oGetRas:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGetRas:oBrowse:bGotFocus  := {||FolderValid("01")}
oGetRas:oBrowse:bLostFocus := {||FolderSave("2")}
oGetRas:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


//[2.2.3 - Folder Especificação + Folder de Ensaios + Aba Observacao do Operacao]
//[MEMO de Observações a CADA OPERACAO]
@ 001.5,001.5 GET oTexto VAR cTexto MEMO NO VSCROLL OF oFldEsp:aDialogs[3] SIZE nFatDiv,108 PIXEL COLOR CLR_BLUE
oTexto:bGotFocus  := {||FolderValid("01")}
oTexto:bLostFocus := {||FolderSave("3")}
oTexto:lReadOnly  := If(Inclui .Or. Altera,.F.,.T.)
oTexto:Align := CONTROL_ALIGN_ALLCLIENT


//Adiciona Botao para Visualizacao do Documento anexo ao Ensaio
//STR0017 - "Visualizar o conteudo do Documento..."
//STR0018 - "Cont.Doc"
Aadd(aButtons,{"VERNOTA",{||If(oFldEsp:nOption<>1,Help(" ",1,"QPNVIEWDOC"),QDOVIEW(,oGetEns:aCols[oGetEns:oBrowse:nAt,nPosDoc],QA_UltRvDc(oGetEns:aCols[oGetEns:oBrowse:nAt,nPosDoc],dDataBase,.f.,.f.)))},STR0017,STR0018})

If slQAXA090
	Aadd(aButtons,{"VERNOTA",{|| QAXA090B(nOpc, Nil, "QQC") },STR0045,STR0045}) // STR0045 - "Arquivos Especificação"
EndIf

//Ponto de Entrada criado para mudar os botoes da enchoicebar
If ExistBlock("QP010BUT")
	aButtons := ExecBlock( "QP010BUT",.F.,.F.,{nOpc,aButtons})
EndIf

If ( nOpc <> 2 )
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,bOk,bCancel,,aButtons));
		VALID If(lQIP011JR,ExecBlock("QIP011JR"),.T.)
Else
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,bOk,bCancel,,aButtons))
EndIf

	//Realiza a atualizacao da Especificacao do Produto
	If nOpcA == 1

		BEGIN TRANSACTION

			QPA011Grv(nOpc) //Atualiza a Especificacao

			EvalTrigger() //Processa os gatilhos

			//Ponto de Entrada para gravacoes diversas
			If lQPATUGRV
				ExecBlock("QPATUGRV",.F.,.F.,{nOpc})
			EndIf

			If slQAXA090
				//Exclui Relacionamentos Arquivos da Manufatura
				If nOpc == 5
					aFiltroQQO := {}
					aAdd(aFiltroQQO, {"QQO_GRUPO  = ?", {{QQC->QQC_GRUPO, "S"}}})
					aAdd(aFiltroQQO, {"QQO_REVIGR = ?", {{QQC->QQC_REVI , "S"}}})

					QAXA090GEA("QQC", aFiltroQQO)

				//Atualiza Relacionamentos Arquivos da Manufatura
				ElseIf nOpc <> 2
					QAXA090GRV(aDataQQO)
				EndIf
			EndIf

		END TRANSACTION
						
	EndIf

Return nOpcA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA011Grv ³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os dados referentes a Especificacao do Produto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011Grv(nOpc)					 			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 		 = Nulo												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA011Grv(nOpc)
Local aStruAlias := FWFormStruct(3, "QQC")[3]
Local nX

Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Especificacao por Grupo de Produtos							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QP011AtuGru(M->QQC_GRUPO,M->QQC_REVI,M->QQC_CODREC,M->QQC_SITREV,nOpc,M->QQC_DTINI)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os dados referentes a Especificacao do Produto      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("QQC",If(nOpc==3,.T.,.F.))
If (nOpc == 5)
	QQC->(dbDelete())
EndIf

If (nOpc == 3 .Or. nOpc == 4) //Inclusao ou Alteracao
	For nX := 1 To Len(aStruAlias)
		If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") <> "V"
			If !(AllTrim(aStruAlias[nX,1]) $ "QQC_GRUPOßQQC_REVIßQQC_CODREVßQQC_REVINV")
				FieldPut(FieldPos(AllTrim(aStruAlias[nX,1])),&("M->"+aStruAlias[nX,1]))
			EndIf	
		EndIf
	Next nX
EndIf

If (nOpc == 3) //Inclusao
	QQC->QQC_FILIAL := xFilial("QQC")
	QQC->QQC_GRUPO  := M->QQC_GRUPO
	QQC->QQC_REVI   := M->QQC_REVI
	QQC->QQC_DTINI  := M->QQC_DTINI
	QQC->QQC_CODREC := M->QQC_CODREC
	QQC->QQC_SITREV := M->QQC_SITREV
EndIf

MsUnLock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Revisao Invertida especificacao por produto			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3)
	RecLock("QQC",.F.)
	QQC->QQC_REVINV := Inverte(QQC->QQC_REVI)
	MsUnlock()
EndIf

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada especifico para o cliente JNJ				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQP011J11
	ExecBlock('QP011J11',.F.,.F.)
EndIf

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPA011FilGrp³ Autor³Paulo Emidio de Barros³ Data ³20/02/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche os dados referentes as Operacoes vinculadas ao Gru³±±
±±³			 ³ po de Produtos.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011FilGrp(EXPC1,EXPC2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPA011FilGrp(cGrupo,cRevGrp)
Local aAreaAnt := GetArea()
Local cProduto := CriaVar("QP6_PRODUT")
Local cRevisao := CriaVar("QP6_REVI" )
Local cRoteiro := CriaVar("QP6_CODREC")
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o primeiro Produto associado ao Grupo, para carregar   ³
//³ as Operacoes e suas amarracoes.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cGrupo) .And. !Empty(cRevGrp)
	QP6->(dbSetOrder(4)) //Grupo+Revisao
	QP6->(dbSeek(xFilial("QP6")+cGrupo+cRevGrp))
	If QP6->(!Eof())
		cProduto := QP6->QP6_PRODUT
		cRevisao := QP6->QP6_REVI
		cRoteiro := QP6->QP6_CODREC
	EndIf
EndIf

//Preenche os dados referentes a Especificacao do Grupo
QPA010FilEsp(cProduto,cRevisao,cRoteiro)

RestArea(aAreaAnt)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QP011AtuGru ³ Autor³Paulo Emidio de Barros³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche os dados referentes as Operacoes vinculadas ao Gru³±±
±±³			 ³ po de Produtos.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QP011AtuGru(EXPC1,EXPC2,EXPC3,EXPC4,nOpc)   			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP011AtuGru(cGrupo,cRevGrp,cRotGrp,cStatus,nOpc,dDataIni)

Local aAreaAnt     := GetArea()
Local aAreaQP6     := QP6->(GetArea()) //Salva a Area do QP6
Local aRegist      := {}
Local cFilQP6      := xFilial("QP6")
Local cProduto     := " "
Local cQP6SQLNam   := RetSqlName("QP6")
Local cUltRev      := " "
Local lGeraRevisao := .F.
Local nMenorRecn   := 0
Local nNxtRec      := 0
Local nx           := 0
Local oQIPA012Aux  := QIPA012AuxClass():New()

Default dDataIni := M->QQC_DTINI

If (nOpc == 3) //Inclusao

	QPA->(dbSetorder(1))
	QPA->(dbSeek(xFilial("QPA")+cGrupo))
	While QPA->(!Eof()) .And. QPA->(QPA_FILIAL+QPA_GRUPO)==(xFilial("QPA")+cGrupo)
	    //Obtem a ultima Revisao do Produto
	    cProduto := QPA->QPA_PRODUT
		cUltRev  := QA_UltRevEsp(cProduto,,,.T.,"QIP", '0|1')

		DbSelectArea("QP6")
		QP6->(dbSetorder(1))

		If oQIPA012Aux:possuiOperacoesOuEnsaios(cProduto, cUltRev) .AND. QP6->(dbSeek(cFilQP6+cProduto+Inverte(cUltRev)))
			lGeraRevisao := .T.
			aRegist      := {}

			For nX := 1 to QP6->(fCount())
				cNomCpo :=  QP6->(FieldName(nX))
				Aadd(aRegist,{cNomCpo,QP6->(&cNomCpo)})
	
			Next nX
		
		Else
			lGeraRevisao := .F.

		Endif

		If lGeraRevisao

			cNextRev        := oQIPA012Aux:retornaProximaRevisao(cProduto, cUltRev)

			//Realiza limpeza de resíduo da base relacionado registros gerados a partir do PCP indevidamente quando MV_QIPOPEP = 2 - DMANQUALI-6695
			If FindFunction("QIPA010LRB") .AND. !Empty(cProduto) .AND. !Empty(cNextRev)
				QIPA010LRB(cProduto, cNextRev)

			EndIf

			RecLock("QP6",.T.)

			For nX := 1 To Len(aRegist)
				QP6->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))

			Next nX

			QP6->QP6_REVI   := cNextRev
			QP6->QP6_REVINV	:= Inverte(cNextRev)
			QP6->QP6_GRUPO  := cGrupo
			QP6->QP6_REVIGR := cRevGrp
			QP6->QP6_CODREC := cRotGrp
			QP6->QP6_SITREV := cStatus
			QP6->QP6_DTINI	:= dDataIni
			QP6->QP6_RESULT := "N"
			MsUnLock()
			QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nOpc,cGrupo,cRevGrp)

		Else
			QP6->(dbSetorder(1))
			If QP6->(dbSeek(cFilQP6+cProduto+Inverte(cUltRev)))

		        //Atualiza os dados referentes a Especificacao dos Produtos
				QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nOpc,cGrupo,cRevGrp)

				//Atualiza os dados referentes ao Grupo
				RecLock("QP6",.F.)
				QP6->QP6_GRUPO  := cGrupo
				QP6->QP6_REVIGR := cRevGrp
				QP6->QP6_CODREC := cRotGrp
				QP6->QP6_SITREV := cStatus
				QP6->QP6_DTINI	:= dDataIni
				MsUnLock()

			Else
			
				cNextRev        := Iif(Empty(cUltRev),"00",cUltRev)

				//Realiza limpeza de resíduo da base relacionado registros gerados a partir do PCP indevidamente quando MV_QIPOPEP = 2 - DMANQUALI-6695
				If FindFunction("QIPA010LRB") .AND. !Empty(cProduto) .AND. !Empty(cNextRev)
					QIPA010LRB(cProduto, cNextRev)

				EndIf

				SB1->(DbGoTop())

				RecLock("QP6",.T.)
				QP6->QP6_FILIAL := cFilQP6
				QP6->QP6_PRODUT := cProduto
			
				QP6->QP6_DESCPO := CriaVar("QP6_DESCPO")
				QP6->QP6_TIPO   := CriaVar("QP6_TIPO")
				QP6->QP6_UNAMO1 := CriaVar("QP6_UNAMO1")
				QP6->QP6_UNMED1 := CriaVar("QP6_UNMED1")
				QP6->QP6_SITPRD := CriaVar("QP6_SITPRD")
				QP6->QP6_TMPLIM := CriaVar("QP6_TMPLIM")

				QP6->QP6_DESCPO := Iif(Empty(QP6->QP6_DESCPO), Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"), QP6->QP6_DESCPO)
				QP6->QP6_TIPO   := Iif(Empty(QP6->QP6_TIPO)  , Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_TIPO"), QP6->QP6_TIPO)
				QP6->QP6_UNAMO1 := Iif(Empty(QP6->QP6_UNAMO1), Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")  , QP6->QP6_UNAMO1)
				QP6->QP6_UNMED1 := Iif(Empty(QP6->QP6_UNMED1), Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")  , QP6->QP6_UNMED1)
				QP6->QP6_SITPRD := Iif(Empty(QP6->QP6_SITPRD), "C"                                                 , QP6->QP6_SITPRD)
				QP6->QP6_TMPLIM := Iif(Empty(QP6->QP6_TMPLIM), 99                                                  , QP6->QP6_TMPLIM)
					
				QP6->QP6_DTCAD  := Date()
				QP6->QP6_CADR   := cUserName
				QP6->QP6_REVI   := cNextRev
				QP6->QP6_REVINV	:= Inverte(cNextRev)
				QP6->QP6_GRUPO  := cGrupo
				QP6->QP6_REVIGR := cRevGrp
				QP6->QP6_CODREC := cRotGrp
				QP6->QP6_SITREV := cStatus
				QP6->QP6_DTINI	:= dDataIni
				MsUnLock()
				QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nOpc,cGrupo,cRevGrp)

			EndIf

		Endif
		
		QPA->(dbSkip())

	EndDo

ElseIf (nOpc == 4) .Or. (nOpc == 5) //Alteracao ou Exclusao

	QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
	QP6->(dbSeek(cFilQP6+cGrupo+cRevGrp))
	While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(cFilQP6+cGrupo+cRevGrp)

		//Posiciona no Proximo registro, para manter a sequencia na exclusao
     	QP6->(dbSkip())
     	nNxtRec := QP6->(Recno())
     	QP6->(dbSkip(-1))

   		RecLock("QP6",.F.)
			QP6->QP6_SITREV := cStatus
			QP6->QP6_DTINI	:= dDataIni
		QP6->(MsUnLock())

		//Retorna o menor/primeiro R_E_C_N_O_ da QP6 (para o produto) para que valide e não permita a exclusão deste registro
		nMenorRecn := fRetMinRec(cQP6SQLNam, cFilQP6, QP6->QP6_PRODUT)

		If nOpc == 5 .And. QP6->(Recno()) <> nMenorRecn //Deleção e não primeira especificação

			//Atualiza os dados referentes a Especificacao dos Produtos
			QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nOpc,cGrupo,cRevGrp)

			RecLock("QP6",.F.)
				QP6->(DbDelete())
			QP6->(MsUnLock())
		
		Else
			//Atualiza os dados referentes a Especificacao dos Produtos
			QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nOpc,cGrupo,cRevGrp)

			If nOpc == 5
				RecLock("QP6",.F.)
					QP6->QP6_GRUPO  := CriaVar("QP6_GRUPO")
					QP6->QP6_REVIGR := CriaVar("QP6_REVIGR")
				QP6->(MsUnLock())
			EndIf
		EndIf

	 	If (nOpc==5) .And. QP6->QP6_RESULT == "S"
   	    	HELP(" ",1,"QIP011LAUD")
   	    	Return .F.
   		Endif

   		QP6->(dbGoTo(nNxtRec))
	EndDo

EndIf

RestArea(aAreaQP6) //Restaura a Area do QP6
RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QIP011VLGR³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do Campo Grupo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIP011VLGR()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIP011VLGR()
Local lRetorno :=.T.

M->QQC_REVI := QA_NxtRevGrp(M->QQC_GRUPO)

If !Empty(M->QQC_REVI)

	//Verifica a existencia do Produto/Grupo+Revisao
	dbSelectArea("QQC")
	dbSetOrder(1)
	If dbSeek(xFilial("QQC")+M->QQC_GRUPO+M->QQC_REVI)
		Help(" ",1,"QP010EXIGP")
		lRetorno := .F.
	Else
		//Verifica se existe produto associado ao grupo informado
		dbSelectArea("QPA")
		dbSetOrder(1)
		If !dbSeek(xFilial("QPA")+M->QQC_GRUPO)
			Help(" ",1,"QP010NPRGP") //Grupo nao tem produto associado, devera incluir produto ao grupo de produto
			lRetorno := .F.
		EndIf

		//Verifica a existencia do Grupo de Produtos
		If lRetorno
			QP3->(dbSetorder(1))
			If QP3->(!dbSeek(xfilial("QP3")+M->QQC_GRUPO))
				Help(" ",1,"QP010NOGRP") //Nao existe o Grupo de Produtos informado
				lRetorno := .F.
			Else
				M->QQC_DESCRI := QP3->QP3_DESCRI //Descricao do Grupo
			EndIf
		EndIf
    EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QIP011VINI³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o campo Data de Inicio de Vigencia 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIP011VINI()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_VALID do campo QQC_DTINI e B1_DTINI 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIP011VINI(cGrupo,cRevi,dVigencia)
Local aAreaAnt := GetArea()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a Data Inicio Vigencia da revisao anterior			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(cRevi) > 0
	dbSelectArea("QQC")
	QQC->(dbSetOrder(1))

	If !QQC->(dbSeek(xFilial("QQC")+cGrupo+Inverte(cRevi)))
		QQC->(dbSeek(xFilial("QQC")+cGrupo))
		While QQC->(!Eof()) .And. QQC->(QQC_FILIAL+QQC_GRUPO) == (xFilial("QQC")+cGrupo)
			If QQC->QQC_REVI < cRevi
				Exit
			EndIf
			QQC->(dbSkip())
		Enddo
	Else
		QQC->(dbskip())
	EndIf

	If QQC->(!Eof()) .And. QQC->(QQC_FILIAL+QQC_GRUPO) == (xFilial("QQC")+cGrupo)
		If QQC->QQC_DTINI > dVigencia
			HELP(" ",1,"A010REVANT",,DTOC(QQC->QQC_DTINI),2,1) //Rev. anterior e' valida a partir de
			lRetorno := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)

EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QIP011WHRV³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula When para a Revisao					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIP011WHRV()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIP011WHRV()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao exista Revisao disponivel, a mesma sera sugerida co ³
//³ mo "00".													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->QQC_REVI)
	M->QQC_REVI := "00"
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QP011VldRot ³ Autor³Paulo Emidio de Barros³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do Roteiro de Operacoes						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QP011VldRot()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Naum esta sendo utilizado na rotina de Especif. por Grupo  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP011VldRot()
Local cRot := &(ReadVar())
Local ny   := 0

For nY:=1 to Len(oGetRot:aCols)
	If oGetRot:aCols[nY,1]== cRot
		oGetRot:aCols[nY,2] := STR0030 //"Roteiro Primario"
		oGetRot:Refresh()
	Else
	  	oGetRot:aCols[nY,2] := STR0031 //"Roteiro Secundario"
		oGetRot:Refresh()
	Endif

Next nY
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA011LegOp³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas nas OPs				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011LegOp()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA011LegOp()
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0019)}) //"Revisão Disponivel"
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0020)}) //"Revisão Bloqueada"
Aadd(aLegenda,{"BR_AMARELO", OemToAnsi(STR0021)}) //"Revisão Pendente"

BrwLegenda(cCadastro,OemToAnsi(STR0022),aLegenda) //"Status das Operações"
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA011BLOQ ³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina que bloqueia / desbloqueia a especificação          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011BLOQ()	    										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA011BLOQ()

Local cGrupo     := ""
Local cMsg       := ""
Local cRev       := ""
Local lLib       := .T.
Local nNxtRec    := 00
Local nRecQQC    := 0
Local oQIP010Aux := QIPA010AuxClass():New()

If QQC->QQC_SITREV == "1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vericica se existem especificação vigente.					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRecQQC   := QQC->(Recno())
	cGrupo    := QQC->QQC_GRUPO
	cRev      := QQC->QQC_REVI

    dbSelectArea("QQC")
    dbSetOrder(1)
    If dbSeek(xFilial("QQC")+cGrupo+INVERTE(SOMA1(cRev)))
       IF QQC->QQC_DTINI <= dDataBase
       		lLib := .F.
       EndIF
    EndIF

	If lLib

		If oQIP010Aux:verificaSeGrupoDeEspecificacaoPossuiOperacaoSemEnsaio(cGrupo, cRev)

			QQC->(dbGoTo(nRecQQC))
			cMsg := STR0023+CHR(13)+CHR(10) //"Esta sendo realizado a Liberação da Especificação do Grupo : "
			cMsg += STR0024 + QQC->QQC_GRUPO+CHR(13)+CHR(10) //"Grupo : "
			cMsg += STR0025 + QQC->QQC_REVI+CHR(13)+CHR(10) //"Revisao : "
			cMsg += STR0026 //"Deseja confirmar a liberação dessa especificação ?"

			If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0024))  //"Atencao"
				dbSelectArea("QQC")
				RecLock("QQC",.f.)
				QQC->QQC_SITREV := "0"
				MsUnlock()
			EndIf

			QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
			QP6->(dbSeek(xFilial("QP6")+QQC->QQC_GRUPO+QQC->QQC_REVI))
			While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(xFilial("QP6")+QQC->QQC_GRUPO+QQC->QQC_REVI)

				//Posiciona no Proximo registro, para manter a sequencia na exclusao
				QP6->(dbSkip())
				nNxtRec := QP6->(Recno())
				QP6->(dbSkip(-1))

				RecLock("QP6",.F.)
				QP6->QP6_SITREV := "0"
				MsUnLock()

				QP6->(dbGoTo(nNxtRec))
			EndDo
		EndIf
	Else

		HELP(" ",1,"A010BLOQ")
		Return

	EndIF
Else

	cMsg := STR0027+CHR(13)+CHR(10) //"Esta sendo realizado o Bloqueio da Especificação do Grupo : "
	cMsg += STR0024 + QQC->QQC_GRUPO+CHR(13)+CHR(10) //"Grupo : "
	cMsg += STR0025 + QQC->QQC_REVI+CHR(13)+CHR(10) //"Revisao : "
	cMsg += STR0028 //"Deseja confirmar o bloqueio dessa especificação ?"

	If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0029))  //"Atencao"
		dbSelectArea("QQC")
		RecLock("QQC",.f.)
		QQC->QQC_SITREV := "1"
		MsUnlock()
	EndIf

	QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
	QP6->(dbSeek(xFilial("QP6")+QQC->QQC_GRUPO+QQC->QQC_REVI))
	While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(xFilial("QP6")+QQC->QQC_GRUPO+QQC->QQC_REVI)

		//Posiciona no Proximo registro, para manter a sequencia na exclusao
		QP6->(dbSkip())
		nNxtRec := QP6->(Recno())
		QP6->(dbSkip(-1))

		RecLock("QP6",.F.)
		QP6->QP6_SITREV := "1"
		MsUnLock()

		QP6->(dbGoTo(nNxtRec))
	EndDo

EndIF

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QPA011Dup ³ Autor ³Paulo Emidio de Barros³ Data ³28/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a Duplicacao da Especificacao de um Grupo de Produ ³±±
±±³			 ³ tos.                                                    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011Dup()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA011Dup(cAlias,nReg,nOpc)
	
	Local aArea    := GetArea()
	Local aAreaQP6 := QP6->(GetArea())
	Local aAreaQQC := QQC->(GetArea())
	Local cGrupo   := QQC->QQC_GRUPO
	Local nOpcA    := Nil

	BEGIN TRANSACTION
		If QPA011Dupl(cAlias,nReg,nOpc)
			QQC->(DbSetOrder(1))
			If QQC->(DbSeek(xFilial("QQC") + cGrupo + Inverte(mv_par01)))
				nOpcA := QPA011Atu("QQC",QQC->(Recno()),4)
				If nOpcA == NIL .OR. nOpcA != 1
					DisarmTransaction()
				EndIf
			Else
				DisarmTransaction()
			Endif
		Endif
	END TRANSACTION

	RestArea(aAreaQP6)
	RestArea(aAreaQQC)
	RestArea(aArea)
Return(NIL)

/*/{Protheus.doc} QPA011Dupl 
Realiza a Duplicação da Especificação de Produtos por Grupo
@author brunno.costa
@since 08/05/2022
@version 1.0
@param 01 - cAlias , caracter, alias do browser
@param 02 - nReg   , número  , recno do registro posicionado no browser
@param 03 - nOpc   , número  , opção escolhida no browser conforme MenuDef()
@return lRetorno, lógico, indica se realizou a duplicação
/*/
Function QPA011Dupl(cAlias,nReg,nOpc)
	
	Local aAreaAnt    := GetArea()
	Local cFilQQC     := QQC->QQC_FILIAL
	Local cGrpOri     := QQC->QQC_GRUPO //Armazena os Dados referente ao Grupo a ser duplicado.
	Local cPerg       := "QPA011A"
	Local cRevOri     := QQC->QQC_REVI //Armazena os Dados referente ao Grupo a ser duplicado.
	Local lRetorno    := .T.
	Local oQIPXFUNAux := QIPXFUNAuxClass():New()

	lRetorno := !(QIPA011AuxClass():verificaSeExistemEnsaiosComPlanoDeAmostragemInconsistentesGrupoDeProdutos(cGrpOri, cRevOri))
		
	// MV_PAR01 - Revisao Destino
	// MV_PAR02 - Roteiro Primario
	If (lRetorno .And. Pergunte(cPerg,.T.))
		// Realiza a duplicacao do Grupo de Produtos

		Processa({|| lRetorno := QIPDupGrp(cGrpOri,cRevOri,mv_par01,mv_par02,.T.) }, OemToAnsi(STR0043), OemToAnsi(STR0044),.F.) //"Processando"###"Aguarde..."
		
		IF lRetorno
			QP6->(dbSetOrder(4)) // Grupo + Revisao Grupo
			QP6->(dbSeek(xFilial("QP6")+cGrpOri+mv_par01))  // Busco grupo duplicado e mudo resultado = N por não ter resultado ainda
			While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(xFilial("QP6")+cGrpOri+mv_par01)
				If QP6->QP6_RESULT == "S"
					RecLock("QP6",.F.)
					QP6->QP6_RESULT := "N"
					MsUnLock()
				EndiF
				QP6->(dbSkip())
			EndDo

			If FWAliasIndic("QQO", .F.)
				oQIPXFUNAux:copiaVinculoDosArquivosDaManufaturaPorGrupo(cFilQQC, cGrpOri, cRevOri, mv_par01)
			EndIf

		EndIF
	EndIf

	RestArea(aAreaAnt)
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ	
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QPA011VDup³ Autor ³Paulo Emidio de Barros³ Data ³28/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do Grupo de Produto e Revisao a ser criada na du ³±±
±±³			 ³ plicacao.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011VDup()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPA011VDup()
Local lRetorno := .T.
Local aAreaQQC := QQC->(GetArea())

If Empty(mv_par01)
	Help(" ",1,"QIPNGRPREV") //Nao sera possivel a duplicacao do Grupo de Produtos.
	lRetorno := .F.
Else
	QQC->(dbSetOrder(1))
	If QQC->(dbSeek(xFilial("QQC")+QQC->QQC_GRUPO+Inverte(mv_par01)))
		//Verifica se a especificação possui Operação e ensaio
		If QIPExisEsp(QQC->QQC_GRUPO, QQC->QQC_REVI)
			Help(" ",1,"QIPGRPEXIS") //Ja existe Grupo de Produtos com a Revisao informada.
			lRetorno := .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaQQC)
Return(lRetorno)

/*/{Protheus.doc} QPA011PREV
Validação Campo Grupo de Produtos da Especificação e Preenche Variáveis Private do Processo
@author Microsiga
@since  12/26/07
@return lReturn, lógico, valida o preenchimento do grupo de produtos para a especificação
*/
Function QPA011PREV()

	Local aArea   := GetArea()
	Local cGrupo  := M->QQC_GRUPO
	Local cRev    := If(M->QQC_REVI<>"00",Strzero((VAL(M->QQC_REVI)-1),2),M->QQC_REVI)
	Local lReturn := .T.

	Default cProduto := CriaVar("QP6_PRODUT")
	Default cRevisao := CriaVar("QP6_REVI")
	Default cRoteiro := CriaVar("QP6_CODREC")

	If M->QQC_REVI <> "00"
		lReturn := VldEspcPrd(cGrupo, cRev)
		If lReturn
			QP6->(dbSetOrder(4)) //Grupo+Revisao
			If QP6->(dbSeek(xFilial("QP6")+cGrupo+cREv))
				cProduto := QP6->QP6_PRODUT
				cRevisao := QP6->QP6_REVI
				cRoteiro := QP6->QP6_CODREC
				QP010FilRot(cProduto,QA_UltRevEsp(cProduto,,,.T.,"QIP"),M->QQC_ROTSIM)
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lReturn

/*/{Protheus.doc} VldEspcPrd
Indica se existem especificações de produtos válidas para a operação
@author brunno.costa
@since  12/01/2021
@param 01 - cGrupo  , caracter, código do grupo de especificação relacionado
@param 02 - cRevisao, caracter, código da revisão da especificação por grupo relacionada
@return lEspecProd, lógico, indica se existem especificações de produtos válidas para a operação
/*/
Static Function VldEspcPrd(cGrupo, cRevisao)
	Local cAlias     := GetNextAlias()
	Local lEspecProd := .F.

    BeginSql Alias cAlias
        SELECT COUNT(*) AS QTD

		FROM (SELECT QP6_PRODUT, QP6_REVI, QP6_GRUPO, QP6_REVIGR, QP6_SITREV
			  FROM %Table:QP6%
			  WHERE (%NotDel%)
			        AND (QP6_FILIAL = %xfilial:QP6%)
			        AND (QP6_SITREV = '0')) 
			      AS ESPECIFICACOES_PRODUTOS 
			
		INNER JOIN
			(SELECT QPA_GRUPO, QPA_PRODUT
			 FROM %Table:QPA%
			 WHERE (%NotDel%)
			       AND (QPA_FILIAL = %xfilial:QPA%)
			       AND (QPA_GRUPO  = %Exp:cGrupo%)) 
			 	AS GRUPOS_PRODUTOS
			 	ON ESPECIFICACOES_PRODUTOS.QP6_PRODUT = GRUPOS_PRODUTOS.QPA_PRODUT 
				
		INNER JOIN
			(SELECT QQC_GRUPO, QQC_REVI
			 FROM %Table:QQC%
			 WHERE (%NotDel%)
			    AND (QQC_FILIAL = %xfilial:QQC%)
			 	AND (QQC_GRUPO  = %Exp:cGrupo%)
			 	AND (QQC_REVI   = %Exp:cRevisao%))
			 	AS ESPECIFICACOES_GRUPOS
				ON    (ESPECIFICACOES_PRODUTOS.QP6_GRUPO  = ESPECIFICACOES_GRUPOS.QQC_GRUPO OR (ESPECIFICACOES_PRODUTOS.QP6_GRUPO   = ' '))
				  AND (ESPECIFICACOES_PRODUTOS.QP6_REVIGR = ESPECIFICACOES_GRUPOS.QQC_REVI  OR (ESPECIFICACOES_PRODUTOS.QP6_REVIGR  = ' '))
				  AND  GRUPOS_PRODUTOS.QPA_GRUPO          = ESPECIFICACOES_GRUPOS.QQC_GRUPO
    EndSql

    If !(cAlias)->(Eof()) .AND. (cAlias)->QTD > 0
        lEspecProd := .T.
	Else
		//STR0032 - "Operação não permitida, não existem especificações de produtos válidas para continuidade na operação."
		//STR0033 - "Cancele esta inclusão (ESC + Cancelar), selecione a especificação por grupo origem na tela e gere uma nova revisão através da opção"
		//STR0008 - "Gera Rev."
		//STR0034 - "no menu Outras Ações."
		Help( " ", 1, ProcName(1) + "-" + cValToChar(ProcLine()),,STR0032,1, 1, NIL, NIL, NIL, NIL, NIL, {STR0033 + " '" + STR0008 + "' " + STR0034})
    EndIf 

    (cAlias)->(DbCloseArea())

Return lEspecProd

/*/{Protheus.doc} fRetMinRec
Retorna o menor/primeiro R_E_C_N_O_ da QP6 (para o produto) para que valide e não permita a exclusão deste registro
@type  Static Function
@author rafael.kleestadt
@since 29/03/2022
@version 1.0
@param cQP6SQLNam, caractere, nome da tabela QP6 na base de dados
@param cFilQP6, caractere, código da filial corrente da QP6
@param cProd, caractere, código do produto para consulta do menor/primeiro R_E_C_N_O_ da QP6
@return nMenorRecn, numeric, numero do menor/primeiro R_E_C_N_O_ da QP6
@example
(examples)
@see (links_or_references)
/*/
Static Function fRetMinRec(cQP6SQLNam, cFilQP6, cProd)
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local nMenorRecn := 0
DEFAULT cQP6SQLNam := RetSqlName("QP6")
DEFAULT cFilQP6    := xFilial("QP6")

//Somente na exclusão
cQuery := " SELECT MIN(QP6.R_E_C_N_O_) AS MENORREC "
cQuery +=   " FROM "+cQP6SQLNam+" QP6 "
cQuery +=  " WHERE QP6.QP6_PRODUT = '"+cProd+"' "
cQuery +=    " AND QP6.D_E_L_E_T_ = ' ' "   
cQuery +=    " AND QP6.QP6_FILIAL = '"+cFilQP6+"' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),cAlias,.F.,.T.)

If (cAlias)->(!EOF())
	nMenorRecn := (cAlias)->MENORREC
Endif
(cAlias)->(DbCloseArea())
	
Return nMenorRecn


/*/{Protheus.doc} QPA011bOk 
Validação bOk QPA011Atu
@author rafael.hesse
@since 22/04/2022
@version 1.0
@param 01 - nOpc , número, valor da opção escolhida no browse da tela, conforme Static Function MenuDef()
/*/
Static Function QPA011bOk(nOpc)
Local nRet	:= 0

	FolderSave("1234567")

    If nOpc != 5
		If Obrigatorio(aGets,aTela) .and. QP10ValIns() .and. QP10ROTUOK() 
			nRet := 1
		else
			nRet := 0
		EndIf	
	else
		nRet := 1
	EndIf

Return nRet


/*/{Protheus.doc} QIPA011AuxClass
Classe agrupadora de métodos auxiliares do QIPA011
@author thiago.rover
@since 03/11/2023
@version 1.0
/*/
CLASS QIPA011AuxClass FROM LongNameClass

    METHOD new() Constructor
	STATIC METHOD verificaSeExistemEnsaiosComPlanoDeAmostragemInconsistentesGrupoDeProdutos(cGrupoProd, cRevGrupo)
	STATIC METHOD retornaCamposDaTabelaDeEspecificacacaoDeGruposConformeMVQIPOPEPeModoEscolhido(cPrioriR, nModoTela)
    
ENDCLASS


/*/{Protheus.doc} retornaCamposDaTabelaDeEspecificacacaoDeGruposConformeMVQIPOPEPeModoEscolhido
Retorna campos da tabela de Especificacação de Grupos conforme MV_QIPOPEP e modo da especificação escolhida
@author rafael.kleestadt
@since 14/03/2024
@version 1.0
@param cPrioriR, caractere, conteúdo do MV_QIPOPEP
@param nModoTela, numérico, modo da especificação escolhido
@return aCampos, array, campos da tabela QQC conforme regras de uso, MV_QIPOPEP e tipo de especificação.
/*/
Method retornaCamposDaTabelaDeEspecificacacaoDeGruposConformeMVQIPOPEPeModoEscolhido(cPrioriR, nModoTela) CLASS QIPA011AuxClass

Local aCampos    := {}
Local aCamposQQC := FWSX3Util():GetAllFields("QQC")
Local nCont      := 0

For nCont := 1 To Len(aCamposQQC)
	If cPrioriR == "3" .AND. nModoTela != 3
		If !(ALLTRIM(aCamposQQC[nCont]) $ "|QQC_CODSIM|QQC_ROTSIM|QQC_CODREC|");
		   .AND. X3Uso(GetSx3Cache(aCamposQQC[nCont],"X3_USADO"),24)

			aAdd(aCampos, AllTrim(aCamposQQC[nCont]))

		EndIf
	ElseIf !Inclui;
		   .AND. !(ALLTRIM(aCamposQQC[nCont]) $ "|QQC_CODSIM|QQC_ROTSIM|");
		   .AND. X3Uso(GetSx3Cache(aCamposQQC[nCont],"X3_USADO"),24)

		aAdd(aCampos, AllTrim(aCamposQQC[nCont]))

	EndIf
Next nCont

Return aCampos


/*/{Protheus.doc} verificaSeExistemEnsaiosComPlanoDeAmostragemInconsistentesGrupoDeProdutos
Verifica se os planos de amostragem vinculados aos ensaios da especificação estão cadastrados corretamente.
@author thiago.rover
@since 06/11/2023
@version 1.0
@param cCodGrp, caractere, código do grupo de produto da especificação
@param cCodRevi, caractere, código da revisão do grupo de produtos
@return .T., lógico, indica que existem ensaios com planos de amostragem inconsistentes
		.F., lógico, indica que não existem ensaios com planos de amostragem inconsistentes
/*/
METHOD verificaSeExistemEnsaiosComPlanoDeAmostragemInconsistentesGrupoDeProdutos(cGrupoProd, cRevGrupo) CLASS QIPA011AuxClass
	
	Local cAliasQP6  := ""
	Local cEnsaio    := ""
	Local cQuery     := {}
	Local oQLTQueryM := QLTQueryManager():New()

	cQuery := " SELECT DISTINCT SEMQQH.FILIAL, SEMQQH.ENSAIO "
	cQuery += " FROM "+ RetSqlName("QP6") + " QP6 "
	cQuery += " INNER JOIN "
	cQuery +=   " ( SELECT QP7.QP7_FILIAL AS FILIAL,"
	cQUery +=            " QP7.QP7_PRODUT AS PRODUTO, "
	cQuery +=            " QP7.QP7_REVI AS REVISAO, "
	cQuery +=            " QP7.QP7_ENSAIO AS ENSAIO "
    cQuery +=     " FROM "+ RetSqlName("QQH") + " QQH "
	cQuery +=     " RIGHT JOIN "+ RetSqlName("QP7") + " QP7 "
	cQuery +=             " ON " + oQLTQueryM:MontaQueryComparacaoFiliaisComCamposEspecificos("QQH", "QQH_FILIAL", "QP7", "QP7_FILIAL")
	cQuery +=             " AND QQH.QQH_PRODUT = QP7.QP7_PRODUT "
	cQuery +=             "	AND QQH.QQH_REVI = QP7.QP7_REVI "
	cQuery +=             "	AND QQH.QQH_ENSAIO = QP7.QP7_ENSAIO "
	cQuery +=             " AND QQH.D_E_L_E_T_ = ' ' " 
	cQuery +=     " WHERE QP7.QP7_PLAMO <> ' ' "
	cQuery +=             "	AND QP7.D_E_L_E_T_ = ' ' "
	cQuery +=             " AND QQH.QQH_PRODUT IS NULL "
	cQuery +=     " UNION ALL "
	cQuery +=     " SELECT QP8.QP8_FILIAL AS FILIAL, "
	cQUery +=            " QP8.QP8_PRODUT AS PRODUTO, "
    cQuery +=            " QP8.QP8_REVI AS REVISAO, "
    cQuery +=            " QP8.QP8_ENSAIO AS ENSAIO "
	cQuery +=     " FROM "+ RetSqlName("QQH") + " QQH "
	cQuery +=     " RIGHT JOIN "+ RetSqlName("QP8") + " QP8 "
	cQuery +=             " ON " + oQLTQueryM:MontaQueryComparacaoFiliaisComCamposEspecificos("QQH", "QQH_FILIAL", "QP8", "QP8_FILIAL")
	cQuery +=             " AND QQH.QQH_PRODUT = QP8_PRODUT "
	cQuery +=             "	AND QQH.QQH_REVI = QP8_REVI "
	cQuery +=             "	AND QQH.QQH_ENSAIO = QP8.QP8_ENSAIO "
	cQuery +=             " AND QQH.D_E_L_E_T_ = ' ' " 
	cQuery +=     "	WHERE QP8.QP8_PLAMO <> ' ' "
	cQuery +=       " AND QP8.D_E_L_E_T_ = ' ' "
	cQuery +=       " AND QQH.QQH_PRODUT IS NULL " 
	cQuery +=   " ) SEMQQH "
	cQuery += " ON SEMQQH.PRODUTO = QP6.QP6_PRODUT "
	cQuery += " AND SEMQQH.REVISAO = QP6.QP6_REVI "
	cQuery += " WHERE QP6.QP6_FILIAL =  '"+xFilial("QP6")+"' "
	cQuery +=   " AND QP6.QP6_GRUPO = '"+cGrupoProd+"' "
	cQuery +=   " AND QP6.QP6_REVIGR = '"+cRevGrupo+"' "
	cQuery +=   " AND " + oQLTQueryM:MontaQueryComparacaoFiliaisComCamposEspecificos("QP6", "QP6.QP6_FILIAL", "QP7", "SEMQQH.FILIAL")
	cQuery +=   " AND QP6.D_E_L_E_T_ = ' ' "

	cQuery := oQLTQueryM:changeQuery(cQuery)
	cAliasQP6 := oQLTQueryM:executeQuery(cQuery)

	While (cAliasQP6)->(!Eof()) 

		cEnsaio += " "+ CHR(13)+CHR(10) 
		cEnsaio += AllTrim((cAliasQP6)->(ENSAIO)) + ' - '+AllTrim(Posicione("QP1", 1, xFilial("QP1")+(cAliasQP6)->(ENSAIO), "QP1_DESCPO"))
	
		(cAliasQP6)->(DbSkip())
	ENDDO
	(cAliasQP6)->(DbCloseArea())

	If !Empty(cEnsaio)
		//STR0035 - "Plano de Amostragem"
		//STR0036 - "Os dados referentes ao plano de amostragem do(s) ensaio(s): "
		//STR0037 - " nas especificação estão incompletos."
		//STR0038 - "Verifique a especificação do produto e ajuste os dados referentes ao Plano de Amostragem."
		Help(NIL, NIL, STR0035, NIL, STR0036 +cEnsaio+ CHR(13)+CHR(10) + STR0037, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0038})
		Return .T.
	Endif

Return .F.

