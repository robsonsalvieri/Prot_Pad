#include "QIPA040.CH"
#include "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPA040  ³ Autor ³ Cleber Souza          ³ Data ³ 05/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Grupo de Produtos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001)  ,"AxPesqui"  , 0 , 1,,.F.},; //"Pesquisa" 
                     {OemToAnsi(STR0002)  ,"QP040GPr"  , 0 , 2},;     //"Visualiza"
                     {OemToAnsi(STR0003)  ,"QP040GPr"  , 0 , 3},;     //"Incluir" 
                     {OemToAnsi(STR0004)  ,"QP040GPr"  , 0 , 4},;     //"Alterar" 
                     {OemToAnsi(STR0005)  ,"QP040GPr"  , 0 , 5 , 3} } //"Excluir"


Return aRotina

Function QIPA040(xAutoCab,xAutoItens,nOpcAuto)

Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private aAutoCab   := {}
Private aAutoItens := {}
Private l040Auto   := xAutoCab <> NIL .And. xAutoItens <> NIL
Private lProduto   := .F.

//Parametros utilizados na rotina
Private cPrioriR := GetMv("MV_QIPOPEP",.F.,"2") //Prioriza dados do Roteiro/Operacoes de 1 = Materiais / 2 - Quality
Private lDelSG2  := GetMv("MV_QPDELG2",.F.,.F.)
Private lIntQMT  := If(GetMV( 'MV_QIPQMT' )=="S",.T.,.F.) //Define a Integracao com o QMT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Grupos de Produtos" 

DEFAULT nOpcAuto := 3

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento de Rotina Automatica            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ( Type("l040Auto") <> "U" .And. l040Auto )
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"QP3")
	xAutoCab   := aAutoCab
	xAutoItens := aAutoItens	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"QP3")
EndIf

Return .T.

/*/{Protheus.doc} QP040AutoGetVal
Busca o valor de um campo dentro do array de rotina automatica (aAutoCab/aAutoItens),
no formato { {"CAMPO",valor,...}, {"CAMPO",valor,...}, ... }
@param aAuto, array, array de campos da rotina automatica
@param cCampo, caractere, nome do campo procurado
@return valor do campo, ou Nil se nao encontrado
/*/
Static Function QP040AutoGetVal(aAuto,cCampo)

Local nPos := aScan(aAuto,{|x| AllTrim(x[1]) == cCampo})

Return If(nPos > 0, aAuto[nPos][2], Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A040GPr  ³ Autor ³ Cleber Souza          ³ Data ³ 05/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Produtos dos Grupos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040GPr(ExpC1,ExpN1,ExpN2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada no menu                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

Function QP040GPr(cAlias,nReg,nOpc)                 

Local aPosObj     := {}
Local aStruAlias  := FWFormStruct(3, "QP3")[3]
Local cFilQP6     := xFilial("QP6")
Local lExecuta    := .T.
Local lNovo       := Nil
Local nOpcA       := 0
Local nX          := 0
Local nY          := 0
Local oQIPA012Aux := QIPA012AuxClass():New()
Local oQIPA040Aux := QIPA040AuxClass():New()
Local oSize       := Nil

Private __cPRODUTO     := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo 
Private __cREVISAO     := CriaVar("QP6_REVI") //Revisao do Produto ou Grupo
Private __cROTEIRO     := CriaVar("QP6_CODREC") //Roteiro de Operacoes do Produto ou Grupo 
Private __dREVISAO     := CriaVar("QP6_DTINI") //Vigencia do Produto ou Grupo
Private __lQIP010JR    := ExistBlock("QIP010JR")
Private __lQP010DEL    := ExistBlock("QP010DEL")
Private __lQP010GRV    := ExistBlock("QP010GRV")
Private __lQP010J11    := ExistBlock("QP010J11")
Private __lQP010OPE    := ExistBlock("QP010OPE")
Private __lQPA010R     := ExistBlock("QPA010R")
Private __lQPATUGRV    := ExistBlock("QPATUGRV")
Private __lQPATUSB1    := ExistBlock("QPATUSB1")
Private aCols          := {}
Private aColsAnt       := {}
Private aCpoQP3        := {{}, {}}
Private aespecificacao := {}
Private aGets          := {}
Private aHeader        := {}
Private aHeaderQP7     := QPA010HeadEsp(aClone(APBuildHeader("QP7"))) //Prepara o aHeader com os demais campos a serem utilizados na Especificacao
Private aHeaderQP9     := aClone(APBuildHeader("QP9"))
Private aHeaderQQ1     := aClone(APBuildHeader("QQ1"))
Private aHeaderQQ2     := AClone(APBuildHeader("QQ2"))
Private aHeaderQQH     := AClone(APBuildHeader("QQH")) //somente para montagem da estrutura 
Private aHeaderQQK     := aClone(APBuildHeader("QQK"))
Private aroteiros      := {}
Private aTela          := {}
Private cEspecie       := "QIPA010 "
Private cProduto       := ""
Private cUltRev        := ""
Private lIntQMT        := If(GetMV( 'MV_QIPQMT' )=="S",.T.,.F.) //Define a Integracao com o QMT  
Private nPosAFI        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFI" })
Private nPosAFS        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFS" })
Private nPosAli        := 0
Private nPosAmo        := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_AMOST" })
Private nPosChav       := AsCan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_CHAVE" })
Private nPosCla        := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_CLASSE"})
Private nPosDCl        := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESCLA"})
Private nPosDesc       := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_DESC" })
Private nPosDescr      := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_DESCR"})
Private nPosDNC        := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESNCO"})
Private nPosDoc        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosDPl        := Ascan(aHeaderQP7,{|x|AllTrim(x[2])=="QP7_DESPLA"})
Private nPosDPr        := 0
Private nPosEns        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSAIO"})
Private nPosInstr      := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_INSTR"})
Private nPosLab        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LABOR" })
Private nPosNC         := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_NAOCON"})
Private nPosNiv        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NIVEL" })
Private nPosNivel      := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NIVAMO"})
Private nPosNom        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NOMINA"})
Private nPosNQA        := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NQA" })
Private nPosOper       := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPERAC" })
Private nPosPlA        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_PLAMO" })
Private nPosPlano      := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_PLANO"})
Private nPosPro        := 0
Private nPosRastr      := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_PRODUT"})
Private nPosRec        := 0
Private nPosRvDoc      := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_RVDOC" })
Private nPosSeq        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_SEQLAB"})
Private nPosTipIn      := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_TIPO" })
Private nPosTipo       := 0
Private nPosUM         := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_UNIMED"})
Private oEncQP3        := Nil
Private oGet           := Nil

Default cRotGrp := CriaVar("QP6_CODREC")
Default cStatus := CriaVar("QP6_SITREV")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o vetor com os campos a serem utilizados na Enchoice    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruAlias)
	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") 
		Aadd(aCpoQP3[1],aStruAlias[nX,1])
		Aadd(aCpoQP3[2],GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT"))
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as variaveis para edicao na Enchoice     		         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)  

If nOpc != 3
	FillGetDados(nOpc,"QPA" ,1     ,       ,            ,         ,         ,          ,        ,     ,{|| QP040Cols(nOpc)},       ,          ,        ,          ,           ,            ,)
Else
	FillGetDados(nOpc,"QPA" ,1     ,      ,             ,         ,         ,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva aCols original                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Altera
	aColsAnt := aClone( aCols )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a posicao dos campos no aHeader p/ posterior consistencia   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosPro  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_PRODUT"})
nPosDPr  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_DESPRO"})
nPosTipo := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_TIPO"})
nPosAli  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_ALI_WT"})
nPosRec  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_REC_WT"})

If ( Type("l040Auto") == "U" .Or. ! l040Auto )
	oSize := FwDefSize():New(.T.)
	
	oSize:AddObject('HEADER',100,70,.T.,.F.)
	oSize:AddObject('GRID'  ,100,10,.T.,.T.)
	
	oSize:aMargins 	:= { 3, 3, 3, 3 }
	oSize:Process()
	
	aAdd(aPosObj,{oSize:GetDimension('HEADER', 'LININI'),oSize:GetDimension('HEADER', 'COLINI'),oSize:GetDimension('HEADER', 'LINEND'),oSize:GetDimension('HEADER', 'COLEND')})
	aAdd(aPosObj,{oSize:GetDimension('GRID'  , 'LININI'),oSize:GetDimension('GRID'  , 'COLINI'),oSize:GetDimension('GRID'  , 'LINEND'),oSize:GetDimension('GRID'  , 'COLEND')})

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL	 //"Grupos de Produtos"

		oEncQP3 := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,.F.,,,,,,,.T.)
		oGet    := MsGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"QP040lOk","QP040TOk",,.T.,NIL,NIL,NIL,99999,,,,,oDlg)			

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,IIf(Obrigatorio(aGets,aTela) .AND. oGet:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()}) CENTERED  
Else  
	
	//Importacao via rotina automatica (MILE): o layout nao monta   
	//a estrutura de grid multipla exigida por EnchAuto/MsGetDAuto, 
	//entao os dados sao atribuidos diretamente ao cabecalho (QP3)  
	//e a grade (QPA) antes da gravacao.
	
	M->QP3_GRUPO := QP040AutoGetVal(aAutoCab,"QPA_GRUPO")

	If Len(aCols) == 0
		Aadd(aCols,Array(Len(aHeader)+1))
		Aeval(aHeader,{|x,y|aCols[Len(aCols),y]:=CriaVar(AllTrim(aHeader[y,2]))})
		aCols[Len(aCols),Len(aHeader)+1] := .F.
	EndIf

	if nPosTipo > 0
		aCols[1,nPosTipo] := QP040AutoGetVal(aAutoCab,"QPA_TIPO")
	EndIf
	If nPosDPr > 0
		aCols[1,nPosDPr] := QIPXDePr(aCols[1,nPosPro])
	EndIf

	if nPosPro > 0
		aCols[1,nPosPro]  := QP040AutoGetVal(aAutoCab,"QPA_PRODUT")
        QPA->(DBSetOrder(2))
        If !QPA->(dbSeek(xFilial("QPA") + aCols[1,nPosPro]))
	        nOpcA := If(!Empty(M->QP3_GRUPO) .And. !Empty(aCols[1,nPosPro]), 1, 0)
        EndIf
	EndIf

 

EndIF

IF nOpcA == 1	// Confirma
                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotina de Exclusao do Grupo x Produtos						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 5
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe  especificao para o Grupo antes de  exclui-lo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QQC")
		dbSetorder(1)
		DbSeek(xFilial("QQC")+QP3->QP3_GRUPO)
		IF !EOF() .AND. (QQC_FILIAL+QQC_GRUPO==xFilial("QQC")+QP3->QP3_GRUPO)
			lExecuta := .F.		
			MsgAlert(OemToAnsi(STR0008))
		EndIf
		If lExecuta
			Begin Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apaga tambem do QPA -> Amarracao Grupo X Produtos    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea('QPA')
			dbSetOrder(1)
			dbSeek( xFilial("QPA")+QP3->QP3_GRUPO )
			While !EOF() .And. QPA_FILIAL+QPA_GRUPO==xFilial("QPA")+QP3->QP3_GRUPO
				RecLock("QPA",.F.,.t.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apos passar por todas as verificacoes , deleta o registro    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.)
			dbDelete()
			MsUnLock()
	
			End Transaction
        EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Rotina de Alteração / Inclusão do Grupo x Produtos			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    ElseIf nOpc == 4 .or. nOpc == 3
    
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao do Cabecalho (QP3).								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QP3")
		dbSetOrder(1)
		If !dbSeek(xFilial("QP3")+M->QP3_GRUPO)		    
			RecLock("QP3",.T.)
			QP3->QP3_FILIAL := xFilial("QP3")
		Else
			RecLock("QP3",.F.)
		EndIf
        Aeval(aCpoQP3[1],{|x,y|QP3->&(aCpoQP3[1,y]):=M->&(aCpoQP3[1,y])})
 		MsUnlock()

	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o arquivo QPA											 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For nX := 1 to Len(aCols)

			If !Acols[nX,Len(aHeader)+1] // Nao esta deletado

				dbSelectArea("QPA")
				QPA->(dbSetOrder(1))
				If QPA->(dbSeek(xFilial("QPA") + QP3->QP3_GRUPO + aCols[nX,nPosPro]))
					RecLock("QPA",.F.)
				Else
					RecLock("QPA",.T.)
					lNovo := .T.
				EndIf

				If oQIPA040Aux:verificaSeHouveAlteracaoNaLinhaDaGridDeProdutosDoGrupo(aHeader, aCols[nX])
					
					DbSelectArea("QPA")
					For nY := 1 to Len(aHeader)
						If aHeader[nY,10] # "V"
							cVar := Trim(aHeader[nY][2])
							Replace &cVar. With aCols[nX,nY]
						Endif
					Next nY

					QPA->QPA_GRUPO  := QP3->QP3_GRUPO
					QPA->QPA_FILIAL := xFilial("QPA")

					If nOpc == 4
						
						cProduto := QPA->QPA_PRODUT
						
						//Obtem a ultima Revisao do Produto
						cRevGrp  := QA_UltRvG(QPA->QPA_GRUPO,,.F.)
						
						QQC->(DbSetOrder(1))
						If QQC->(DbSeek(xFilial("QQC")+QPA->QPA_GRUPO))
							cRotGrp:= QQC->QQC_CODREC
							cStatus:= QQC->QQC_SITREV
						Endif

						cUltRev := QA_UltRevEsp(cProduto,,,.T.,"QIP")
						cUltRev := Iif(Empty(cUltRev),"00",cUltRev)
						If lNovo .And. oQIPA012Aux:possuiOperacoesOuEnsaios(cProduto, cUltRev)
							cUltRev := oQIPA012Aux:retornaProximaRevisao(cProduto, cUltRev)
						EndIf
						
						oQIPA040Aux:criaEspecificacaodeProdutoIndividualComOsDadosDaEspecificacaoDeGrupoDeProdutos(cFilQP6, cProduto, cUltRev)				
					
					Endif
				Endif 

				QPA->(MsUnLock())
				
			Else
			 	//Cancela o Produto no QPA
				dbSelectArea("QPA")
				If QPA->(dbSeek(xFilial("QPA") + QP3->QP3_GRUPO + aCols[nX,nPosPro]))			
					RecLock("QPA",.F.)
						QPA->(dbDelete())
					QPA->(MsUnLock())
				EndIf

				oQIPA040Aux:desvinculaDoGrupoDeProdutoOsItensDaEspecificacao(QP3->QP3_GRUPO, aCols[nX,nPosPro])
	 		EndIf
		Next nX
    EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto ode entrada QP040GRV executado apos a gravacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QP040GRV")
		ExecBlock("QP040GRV",.F.,.F.,{nOpc,aClone(aHeader),aClone(aCols)})
	EndIf
EndIF

Return
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A040Cols  ºAutor  ³ Cleber Souza       º Data ³  05/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carega aCols com os Produtos.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIPA040                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QP040Cols(nOpc)

Local nX       := 0
Local nPosAli  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_ALI_WT"})
Local nPosRec  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_REC_WT"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega aCols com os produtos relacionados.	                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc<> 3 
	dbSelectArea("QPA")
	DbSetOrder(1)
	dbSeek(xFilial("QPA")+QP3->QP3_GRUPO)
	While !EOF() .And. QPA_FILIAL+QPA_GRUPO == xFilial("QPA")+QP3->QP3_GRUPO 
		Aadd(aCols,Array(Len(aHeader)+1))
	    For nX := 1 to Len(aHeader) 
		    If aHeader[nX,10] <> "V"
				aCols[Len(aCols),nX] := &("QPA->"+aHeader[nX,2])
			ElseIF aHeader[nX,10] == "V"
				If !(aHeader[nX,2] $ "QPA_ALI_WT | QPA_REC_WT")
					If aHeader[nX,2] == "QPA_DESPRO"
						aCols[Len(aCols),nX] := QIPXDePr(QPA->QPA_PRODUT)
					Else
						aCols[Len(aCols),nX] := CriaVar(AllTrim(aHeader[nX,2]))
					EndIf
				ElseIf nPosAli > 0 .and. nPosRec > 0
					aCols[Len(aCols),nPosAli] := "QPA"
					If IsHeadRec(aHeader[nPosRec,2])
						aCols[Len(aCols),nPosRec] := QPA->(RecNo())
					EndIf
				Endif	
			Endif
		Next nX	
		aCols[Len(aCols),Len(aHeader)+1] := .F.
		QPA->(dbSkip())
	Enddo    
	
Else
    Aadd(aCols,Array(Len(aHeader)+1))
	Aeval(aHeader,{|x,y|aCols[Len(aCols),y]:=CriaVar(AllTrim(aHeader[y,2]))})
	aCols[Len(aCols),Len(aHeader)+1] := .F.    
EndIf
       
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP040lOk  ³ Autor ³ Cleber Souza          ³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP040lOk(o)

Local lRetu    :=.T.
Local nAchou   :=0
Local cProcura := aCols[n][nPosPro]

If !(aCols[n,Len(aCols[n])])  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se campo Produto esta' preenchido                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[n][Len(aHeader)+1] .And. LastKey() != 5 .And. LastKey() != 27 .And. lRetu
		If Empty(aCols[n][nPosPro])
			Help(" ",1,"QA_CPOOBR")
			lRetu:=.F.	
		EndIf
	EndIf 
	
	If lRetu
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto ja' existe                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAchou := Ascan(aCols,{|x| x[nPosPro] == cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			Help(" ",1,"A040EXIPRG")
			lRetu:=.F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto esta' cadastrado          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetu
		If ! Empty(aCols[n][nPosPro])
			If !ExistCpo("SB1",aCols[n][nPosPro])
				lRetu := .f.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto esta' relacionado a outro Grupo      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetu
		If !Empty(aCols[n][nPosPro])
			nReg := QPA->(Recno())
			QPA->(dbSetOrder(2))
			If QPA->(dbSeek(xFilial("QPA") + aCols[n][nPosPro]))
				If QPA->QPA_GRUPO <> M->QP3_GRUPO
					HELP(" ",1,"A040GRPEXI",,QPA->QPA_GRUPO,3,1)
					lRetu := .f.
				EndIf
			EndIf
			QPA->(dbSetOrder(1))
			QPA->(dbGoto(nReg))
		EndIf
	EndIf
EndIf
Return lRetu

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP040TOk  ³ Autor ³ Cleber Souza          ³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP040TOk(o)

	Local cComEspec   := ""
	Local cUltRev     := ""
	Local lRetu       := .T.
	Local nAchado     := -1
	Local nI          := NIL
	Local oQIPA012Aux := QIPA012AuxClass():New()

	For nI := 1 to Len(aCols)
		If !aCols[nI][Len(aCols[nI])]	//Deletado
			If !QP040lOk(o)
				lRetu := .f.
				Exit
			EndIf
			If Altera
				If aScan( aColsAnt, {|x| x[1] == aCols[nI][1]} ) > 0
					Loop
				Endif
			Endif

			//Recupera a revisao ativa do produto
			If lRetu .And. !Empty(aCols[ni][nPosPro])

				cUltRev := QA_UltRevEsp(aCols[ni][nPosPro],,,.T.,"QIP")

				// Verifica se o Produto ja contem roteiro/operacoes/ensaios
				If oQIPA012Aux:possuiOperacoesOuEnsaios(aCols[ni][nPosPro], cUltRev)
					cComEspec += Iif(Empty(cComEspec), "", Chr(13)+Chr(10)) + aCols[ni][nPosPro] + "/" + cUltRev
					Loop
				EndIf

			EndIf

		Endif
	Next

	//STR0014 - "Deseja prosseguir?"
	//STR0009 - "Os produtos a seguir já possuem Roteiro de Operação / Ensaios cadastrados, ao prosseguir,  serão geradas novas revisões vinculadas a este grupo. Deseja prosseguir?"
	If !Empty(cComEspec) .And. !ApMsgYesNo(STR0009 + Chr(13) + Chr(10) + cComEspec,STR0014)
		lRetu := .f.
	EndIf

	nAchado := Ascan(aCols,{|x| x[Len(aCols[n])] == .F.})
	If nAchado == 0
		lRetu := .F.
		Help(" ",1,"SQP040VLD",,OemToAnsi(STR0007),1,0)
	Endif

Return(lRetu)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A040DEqu ³ Autor ³ Cleber Souza          ³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher a descricao da Equipe Follow-up     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040DEqu(ExpC1,ExpL1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Equipe                                   ³±±
±±³          ³ ExpL1 = Indica se e' gatilho                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (QP3_EQUIPE) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040DEqu(cCodEq,lGatilho)
Local lnOpc := Iif(Type('Inclui') == 'U',.T.,Inclui)
lGatilho    := Iif(lGatilho == NIL,.t.,lGatilho)

IF !lnOpc .or. lGatilho	// Se Inic. Padrao ou gatilho a partir do cod. equipe
	QP4->(dbSeek(xFilial("QP4") + cCodEq))
	Return(QP4->QP4_DESCRI)
Else
	Return Space(Len(QP4->QP4_DESCRI))
Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A040VlPr ³ Autor ³ Cleber Souza          ³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Produto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA040 - E' chamada no X3_VALID do cpo. QPA_PRODUT - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040VlPr()

Local lRetu := .T.
Local nI	:= 0
Local nReg	:= 0	
Local cVar	:= &(readvar()) // Conteudo da variavel do campo NC 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou o Produto (Alterou o campo ja' digitado)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[n,nPosPro]) .and. !Empty(cVar) .and. aCols[n,nPosPro] <> cVar
	Help(" ",1,"A010ALTCHA")	// Campo nao pode ser alterado	
	lRetu := .f.
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto esta' cadastrado          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[n,nPosPro] := M->QPA_PRODUT
	If !ExistCpo("SB1",aCols[n,nPosPro])
		lRetu := .f.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Produto esta' relacionado a outro Grupo      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetu
	nReg := QPA->(Recno())
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA") + aCols[n,nPosPro]))
		If QPA->QPA_GRUPO <> QP3->QP3_GRUPO
			HELP(" ",1,"a040GRPEXI",,QPA->QPA_GRUPO,3,1)
			lRetu := .f.
		EndIf
	EndIf
	QPA->(dbSetOrder(1))
	QPA->(dbGoto(nReg))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Produto ja' existe                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetu
	For nI := 1 to len(aCols)
		If cVar == acols[nI,nPosPro] .and. nI <> n
			Help(" ",1,"A040EXIPRD")
			acols[n,nPosPro]	:= CriaVar("QPA_PRODUT")
			M->QPA_PRODUT		:= acols[n,nPosPro]
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche a Descricao e Tipo do Produto          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetu
	aCols[n,nPosDPr] := QIPXDePr(aCols[n,nPosPro])
	aCols[n,nPosTipo]:= QIPXTipo(aCols[n,nPosPro])
EndIf

Return(lRetu)


/*/{Protheus.doc} QIPA040AuxClass
Classe que agrupa novos métodos da rotina QIPA040
@author rafael.kleestadt
@since 05/06/2024
@version 1.0
/*/
CLASS QIPA040AuxClass FROM LongNameClass

    METHOD new() Constructor
	STATIC METHOD desvinculaDoGrupoDeProdutoOsItensDaEspecificacao(cGrupo, cProduto)
	STATIC METHOD verificaSeHouveAlteracaoNaLinhaDaGridDeProdutosDoGrupo(aCabecalho, aDadosLinha)
	STATIC METHOD criaEspecificacaodeProdutoIndividualComOsDadosDaEspecificacaoDeGrupoDeProdutos(cFilialQP6, cProduto, cRevisao)
    
ENDCLASS

/*/{Protheus.doc} new
Método construtor da classe
@author thiago.rover
@since 17/07/2024
@version 1.0
/*/
METHOD new() CLASS QIPA040AuxClass 
Return Self

/*/{Protheus.doc} desvinculaDoGrupoDeProdutoOsItensDaEspecificacao
Limpa os campos de grupo e revisão do grupo da especificação
@author user
@since 05/06/2024
@version version
@param cGrupo, caractere, código do grupo de produtos
@param cProduto, caractere, código do produto
@return return_var, return_type, return_description
/*/
Method desvinculaDoGrupoDeProdutoOsItensDaEspecificacao(cGrupo, cProduto) Class QIPA040AuxClass

	Local aAreaAtual := {}
	Local aAreaQP6   := QP6->(GetArea())
	Local cFilQP6    := xFilial("QP6")
	Local cVarGrupo  := CriaVar("QQC_GRUPO")
	Local cVarRev    := CriaVar("QQC_REVI")

	DbSelectArea("QP6")
	QP6->(dbSetOrder(4))//QP6_FILIAL+QP6_GRUPO+QP6_REVIGR+QP6_PRODUT+QP6_REVI+QP6_CODREC
	QP6->(dbSeek(cFilQP6+cGrupo))
	While !QP6->(Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_PRODUT) == cFilQP6+cGrupo+cProduto
 	
		aAreaAtual := GetArea()

		FwFreeArray(aEspecificacao)
		aEspecificacao := {}

		//Preenche os dados referentes a Especificacao do Grupo
		QPA010FilEsp(QP6->QP6_PRODUT, QP6->QP6_REVI, QP6->QP6_CODREC)

		QPAAtuEsp(QP6->QP6_PRODUT, QP6->QP6_REVI, .T., 4)
		
		RestArea(aAreaAtual)

		RecLock("QP6",.F.)
			QP6->QP6_GRUPO  := cVarGrupo 
			QP6->QP6_REVIGR := cVarRev
		QP6->(MsUnLock())
		QP6->(FKCOMMIT())
		
		QP6->(DbSkip()())
	EndDo
	RestArea(aAreaQP6)

Return Nil

/*/{Protheus.doc} verificaSeHouveAlteracaoNaLinhaDaGridDeProdutosDoGrupo
Verifica se houve alteração nos dados da grid de produtos do grupo(QPA)
@author rafael.kleestadt
@since 07/06/2024
@version 1.0
@param aCabecalho, array, array com os campos da grid de produtos do grupo(QPA)
@param aDadosLinha, array, array com os dados da linha da grid de produtos do grupo(QPA)
@return lAlterado, lógico, verdadeiro se houve alteração dos dados
/*/
Method verificaSeHouveAlteracaoNaLinhaDaGridDeProdutosDoGrupo(aCabecalho, aDadosLinha) Class QIPA040AuxClass
Local lAlterado  := .F.	
Local nCont      := 0
Local nPosHead   := 0

//Percorre todos os campos
For nCont := 1 To Len(aCabecalho)
	//Busca no aCabecalho a posição
	nPosHead := GDFieldPos(aCabecalho[nCont,2])
	//Somente se o campo não for Virtual
	If aCabecalho[nCont,10] # "V" .And. nPosHead > 0
		//Se o campo salvo na tabela for diferente do da memória
		If &("QPA->"+aCabecalho[nCont,2]) != aDadosLinha[nPosHead]
			lAlterado := .T.
			EXIT
		EndIf
	EndIf
Next nCont

Return lAlterado

/*/{Protheus.doc} criaEspecificacaodeProdutoIndividualComOsDadosDaEspecificacaoDeGrupoDeProdutos
Cria especificação de produto individual com base nos dados da especificação de grupo de produtos
@author thiago.rover
@since 11/07/2024
@version 1.0
@param cFilialQP6      , string, filial da tabela QP6
@param cProduto        , string, código do produto vinculado ao grupo de produtos
@param cUltimaRevisao  , string, código da revisão do produto para inclusão
/*/
Method criaEspecificacaodeProdutoIndividualComOsDadosDaEspecificacaoDeGrupoDeProdutos(cFilialQP6, cProduto, cRevisao) Class QIPA040AuxClass

	Local aAreaQP6      := QP6->(GetArea())
	Local cCodigoGrupo  := QPA->QPA_GRUPO
	Local cFilialSB1    := xFilial("SB1")
	Local cRevGrpInvert := Nil
	Local cRevisaoGrupo := QA_UltRvG(QPA->QPA_GRUPO,,.F.)
	Local cRoteiro      := Nil
	Local cStatus       := Nil
	Local lInsere       := Nil

	//Proteção para garantir que seja criado vínculo com o grupo quando a vigência do grupo é futura
	cRevGrpInvert := Iif(Empty(cRevisaoGrupo), "", Inverte(cRevisaoGrupo))

	//Realiza limpeza de resíduo da base relacionado registros gerados a partir do PCP indevidamente quando MV_QIPOPEP = 2 - DMANQUALI-6695
	If FindFunction("QIPA010LRB") .AND. !Empty(cProduto) .AND. !Empty(cRevisao)
		QIPA010LRB(cProduto, cRevisao)
	EndIf	

	//Força posicionamento na QQC
	If QQC->(Eof())
		QQC->(DbSetOrder(1))
		QQC->(DbSeek(xFilial("QQC") + QPA->QPA_GRUPO + cRevGrpInvert))
	EndIf

	If !QQC->(Eof())
		cRoteiro := Iif(Empty(QQC->QQC_CODREC), "01", QQC->QQC_CODREC)
		cStatus  := Iif(Empty(QQC->QQC_SITREV),CriaVar("QP6_SITREV"),QQC->QQC_SITREV)

		QP6->(dbSetOrder(1))
		lInsere  := !QP6->(DbSeek(xFilial('QP6') + cProduto + Inverte(cRevisao)))

		SB1->(DbGoTop())

		RecLock("QP6", lInsere)
		QP6->QP6_FILIAL := cFilialQP6
		QP6->QP6_PRODUT := cProduto

		QP6->QP6_DESCPO := CriaVar("QP6_DESCPO")
		QP6->QP6_TIPO   := CriaVar("QP6_TIPO")
		QP6->QP6_UNAMO1 := CriaVar("QP6_UNAMO1")
		QP6->QP6_UNMED1 := CriaVar("QP6_UNMED1")
		QP6->QP6_SITPRD := CriaVar("QP6_SITPRD")
		QP6->QP6_TMPLIM := CriaVar("QP6_TMPLIM")

		QP6->QP6_DESCPO := Iif(Empty(QP6->QP6_DESCPO), Posicione("SB1",1,cFilialSB1 + cProduto,"B1_DESC"), QP6->QP6_DESCPO)
		QP6->QP6_TIPO   := Iif(Empty(QP6->QP6_TIPO)  , Posicione("SB1",1,cFilialSB1 + cProduto,"B1_TIPO"), QP6->QP6_TIPO)
		QP6->QP6_UNAMO1 := Iif(Empty(QP6->QP6_UNAMO1), Posicione("SB1",1,cFilialSB1 + cProduto,"B1_UM")  , QP6->QP6_UNAMO1)
		QP6->QP6_UNMED1 := Iif(Empty(QP6->QP6_UNMED1), Posicione("SB1",1,cFilialSB1 + cProduto,"B1_UM")  , QP6->QP6_UNMED1)
		QP6->QP6_SITPRD := Iif(Empty(QP6->QP6_SITPRD), "C"                                               , QP6->QP6_SITPRD)
		QP6->QP6_TMPLIM := Iif(Empty(QP6->QP6_TMPLIM), 99                                                , QP6->QP6_TMPLIM)

		QP6->QP6_DTCAD  := Date()
		QP6->QP6_CADR   := cUserName
		QP6->QP6_REVI   := cRevisao
		QP6->QP6_REVINV	:= Inverte(cRevisao)
		QP6->QP6_CODREC := cRoteiro
		QP6->QP6_SITREV := cStatus
		QP6->QP6_DTINI	:= Iif(Empty(QQC->QQC_DTINI), dDataBase, QQC->QQC_DTINI)
		QP6->QP6_GRUPO  := QQC->QQC_GRUPO 
		QP6->QP6_REVIGR := QQC->QQC_REVI
		MsUnLock()

		//Posiciona na primeira especificação vinculado ao grupo de produtos(Especificação base para criação das demais)
		QP6->(dbSetOrder(4)) 
		QP6->(dbSeek(xFilial("QP6")+cCodigoGrupo+cRevisaoGrupo))
		While !EOF()
			If QP6->QP6_PRODUT <> cProduto
				//Carrega dados da Especificação
				QPA010FilEsp(QP6->QP6_PRODUT, QP6->QP6_REVI, QP6->QP6_CODREC, cCodigoGrupo, cRevisaoGrupo)

				//Realizar a criação das tabelas filhas da QP6
				QPAAtuEsp(cProduto, cRevisao, .T., 4, cCodigoGrupo, cRevisaoGrupo)
				Exit
			EndiF
			QP6->(DbSkip())
		EndDo 
		RestArea(aAreaQP6)
								
	EndIf

Return
