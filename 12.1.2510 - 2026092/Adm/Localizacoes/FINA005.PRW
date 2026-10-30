#include "fina005.ch"
#include "totvs.ch"
#include "fwmbrowse.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINA005  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutencao do cadastro de grupos de gestores   ³±±
±±³          ³financeiros.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA005()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA005()
Local oBrowse As object
Local cFilter := "FRR_ITEM = '01'"
Local nIndex as numeric
Local lOderAsc as logical
Private cCadastro := STR0001	//"Grupo de Gestores Financeiros"
Private aRotina   := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("FRR")
dbSetOrder(1)
	If HasSmartX()
		nIndex := 1 // FRR_FILIAL+FRR_COD+FRR_ITEM
		lOderAsc := .T.
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("FRR")
		oBrowse:SetDescription(cCadastro)
		oBrowse:AddFilterSmartX( "@"+cFilter )
		oBrowse:setSmartX(nIndex,  lOderAsc) //Aqui está a chamada do método que define a utilização do novo browser
		oBrowse:Activate()
		FWFreeObj(oBrowse) 
	Else
		mBrowse( 006, 001, 022, 075, "FRR",,,,,,,,,,,,,,cFilter)
	Endif

Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³08/11/2006³±±
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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Private aRotina	:=     {{OemToAnsi(STR0002),"AxPesqui",0,1,0,.F.},;	//"Pesquisar"
 						{OemToAnsi(STR0003),"FA005MAN",0,2,0,nil},;	//"Visualizar"
						{OemToAnsi(STR0004),"FA005MAN",0,3,0,nil},; //"Incluir"
						{OemToAnsi(STR0005),"FA005MAN",0,4,0,nil},; //"Alterar"
						{OemToAnsi(STR0006),"FA005MAN",0,5,0,nil} } //"Excluir"					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FA005MNU")
	ExecBlock("FA005MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA005MAN  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada pelo aRotina, opcoes Visualizar, Incluir,  ³±±
±±³			 ³Alterar e Excluir.  										  ³±±
±±³			 ³Responsavel pela manutencao de cadastro, atraves da montagem³±±
±±³			 ³da tela, das chamadas as funcoes de validacoes dos dados    ³±±
±±³			 ³e da chamada da funcao que grava, altera e exclui registros ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA005MAN(cAlias,nReg,nOpc)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias	- String: Alias da Tabela corrente ("FRR")		  ³±±
±±³			 ³nReg		- Numeric: Nro do registro posicionado.			  ³±±
±±³			 ³nOpc		- Numeric: Opcao de manipulacao de dados 		  ³±±
±±³			 ³			2 - Visualizar 		  							  ³±±
±±³			 ³			3 - Incluir 		  							  ³±±
±±³			 ³			4 - Alterar 		  							  ³±±
±±³			 ³			5 - Excluir 		  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil									    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA005MAN(cAlias,nReg,nOpc,lAutomato)

Local nOpcA		:= 0

Local oDlg
Local oEnch
Local oMsNewGD

Local aFields	:= {"FRR_COD","FRR_DESC","FRR_MOEDA"}
Local aEditFld	:= {}
Local aPosEnch	:= {}
Local aObjects	:= {}
Local aPosObj	:= {}
Local aInfo		:= {}
Local aSizeAut	:= MsAdvSize()
Local aHeader	:= FA005HeadFRR()
Local aCols		:= FA005CargaGD(aHeader,nOpc)
Local aAlter	:= {}
Local aButtons	:= {}
Local aUsButtons:= {}

Local lInsert	:= (nOpc == 3 .or. nOpc == 4)
Local lUpdate	:= (nOpc == 3 .or. nOpc == 4)
Local lDelete	:= (nOpc == 3 .or. nOpc == 4)
Local lPreVld	:= .t.

Local bLinhaOk	:= {|lRet| 	lRet := FA005LINOK(oMsNewGd), lRet }
Local bTudoOk	:= {|lRet|	lRet := Obrigatorio(oEnch:aGets,oEnch:aTela), Iif(lRet,lRet := FA005ALLOK(oMsNewGd,nOpc),nil), lRet }
Local bDelOk	:= {|lRet|	lRet := FA005DELOK(oMsNewGd), lRet	}
Local bCancel	:= {||oDlg:End(),nOpcA := 0}
Local bUpdate	:= {|| Iif(Eval(bTudoOk),nOpcA := 1,nOpcA := 0),Iif(nOpcA == 1,oDlg:End(),nil)}

Default lAutomato	:=  .F. //Se inicializa en .T. cuando viene por automatización, en todos los demás casos es .F.

If ExistBlock("FA005PVD")
	lPreVld := ExecBlock("FA005PVD",.f.,.f.,{nOpc})
Endif

If !lPreVld
	Return()
Endif

If ExistBlock("FA005BTN")
	If ValType( aUsButtons := ExecBlock( "FA005BTN", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
Endif

If nOpc == 3 .or. nOpc == 4
	If nOpc == 3
		aEditFld	:= aClone(aFields)
	Endif
	aEval( aHeader, {|x| Iif(ALLTRIM(x[2]) <> "FRR_ITEM",aAdd(aAlter,x[2]),nil) } )
Endif

AAdd( aObjects, { 000, 025, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo  		:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj		:= MsObjSize( aInfo, aObjects )
aPosEnch	:= {aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]}

RegToMemory(cAlias,(nOpc == 3),.T.,.T.)
If !lAutomato
DEFINE MSDIALOG oDlg TITLE STR0001 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] PIXEL OF oMainWnd //"Cadastro de Grupo de Gestores"

oEnch := MsMGet():New(cAlias,nReg,nOpc,,,STR0001,aFields,aPosEnch,aEditFld,,,,,oDlg,,,.F.) //"Cadastro de Grupo de Gestores"
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oMsNewGD := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue","AllwaysTrue","+FRR_ITEM",aAlter,,999,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeader,aCols)


oMsNewGD:bLinhaOk	:= bLinhaOk  
oMsNewGD:bDelOk		:= bDelOk

oMsNewGD:lInsert 	:= lInsert
oMsNewGD:lUpdate 	:= lUpdate
oMsNewGD:lDelete 	:= lDelete
Endif



IF !lAutomato
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bUpdate,bCancel,,aButtons) CENTERED
Else
	oMsNewGD	:= R_MSRoboGetDados():New(@aHeader,@aCols)
	aHeader 	:= oMsNewGD:aHeader
	aCols 		:= oMsNewGD:aCols
	nOpcA := 1
Endif
If nOpcA == 1
	Begin Transaction
		FA005GRV(nOpc,oMsNewGD,lAutomato)
		ConfirmSx8()
	End Transaction
Else
	RollbackSX8()
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA005HeadFRR³ Rev.  ³Fernando Radu Muscalu  ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Campos para composicao do objeto MsNewGetDados.			   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA005HeadFRR()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nenhum			                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³aRetHead	- Array: Campos do Header da MsNewGetDados        	³±±
±±³          ³	aRetHead[n,01]- Char: Titulo do Campo			        	³±±
±±³          ³	aRetHead[n,02]- Char: Nome do Campo	(Ex: FRR_CODGES)       	³±±
±±³          ³	aRetHead[n,03]- Char: Mascara do Campo				       	³±±
±±³          ³	aRetHead[n,04]- Char: Tamanho do Campo 				       	³±±
±±³          ³	aRetHead[n,05]- Char: Decimal do Campo				       	³±±
±±³          ³	aRetHead[n,06]- Char: Validacao de sistema do campo       	³±±
±±³          ³	aRetHead[n,07]- Char: Campo Usado					       	³±±
±±³          ³	aRetHead[n,08]- Char: Tipo de campo					       	³±±
±±³          ³	aRetHead[n,09]- Char: Consulta padrao				       	³±±
±±³          ³	aRetHead[n,10]- Char: Contexto do campo				       	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA005HeadFRR()

Local aRetHead	:= {}
Local aArea	:= GetArea()
Local cNoFields	:= "FRR_FILIAL|FRR_COD|FRR_DESC|FRR_MOEDA"
Local cAlias    := "FRR" 
Local cX3_NIVEL
Local cX3_USADO
Local _i        := 0

aSX3 := FWSX3Util():GetAllFields(cAlias , .T.)
for _i := 1 to len(aSX3)
    If !(Alltrim(aSX3[_i]) $ cNoFields)
	    cX3_NIVEL := GetSx3Cache(aSX3[_i], "X3_NIVEL")
	    cX3_USADO := GetSx3Cache(aSX3[_i], "X3_USADO")
	    if cNivel >= cX3_NIVEL .and. X3Uso(cX3_USADO)
			AADD(aRetHead,{ TRIM(fwx3Titulo(aSX3[_i])),;
							aSX3[_i],;
							GetSx3Cache(aSX3[_i], "X3_PICTURE"),;
							GetSx3Cache(aSX3[_i], "X3_TAMANHO"),;
							GetSx3Cache(aSX3[_i], "X3_DECIMAL"),;
							GetSx3Cache(aSX3[_i], "X3_VALID"),;
							cX3_USADO,;
							GetSx3Cache(aSX3[_i], "X3_TIPO"),;
							GetSx3Cache(aSX3[_i], "X3_F3"),;
							GetSx3Cache(aSX3[_i], "X3_CONTEXT")})
		EndIf
	Endif
next _i

RestArea(aArea)

Return(aRetHead)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA005CargaGD³ Rev.  ³Fernando Radu Muscalu  ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carga dos dados para o aCols do objeto MsNewGetDados.		   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA005CargaGD(aHeadGD,nOpc)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aHeadGd	- Array: aHeader do objeto MsNewGetDados            ³±±
±±³          ³nOpc		- Numeric: opcao da manipulacao de dados            ³±±
±±³          ³			2 - Visualizacao						            ³±±
±±³          ³			3 - Inclusao							            ³±±
±±³          ³			4 - Alteracao							            ³±±
±±³          ³			5 - Exclusao							            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³aRetCols	- Array: aCols preenchida da MsNewGetDados        	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA005CargaGD( aHeadGD, nOpc )

Local cChave	:= ""

Local nI		:= 0

Local aRetCols	:= {}
Local aAux		:= {}
Local aAreaFRR	:= {}
Local cUsrFullName := ""

If nOpc == 3
	aAdd( aRetCols, array( len(aHeadGD) + 1 ) )

	For nI  := 1 to len(aHeadGD)
		If Alltrim(aHeadGD[nI,2]) == "FRR_ITEM"
			aRetCols[len(aRetCols),nI] := strzero(1,TAMSX3("FRR_ITEM")[1])
		Else
			aRetCols[len(aRetCols),nI] := CriaVar(aHeadGD[nI,2])
		Endif
	Next nI

	aRetCols[len(aRetCols),len(aHeadGD) + 1] := .f.
Else

   	aAreaFRR := FRR->(GetArea())
   	cChave := xFilial("FRR") + Padr(FRR->FRR_COD,TamSX3("FRR_COD")[1])

	FRR->(DbSetOrder(1))

	If FRR->(DbSeek(cChave))
		While FRR->(!Eof()) .AND. cChave == FRR->FRR_FILIAL + Padr(FRR->FRR_COD,TamSX3("FRR_COD")[1])
            cUsrFullName := UsrFullName( FRR->FRR_USER )
			For nI := 1 to len(aHeadGD)
				If aHeadGD[nI,10] != "V"
					aAdd(aAux,FRR->&(aHeadGD[nI,2]))
				Else
					If AllTrim(aHeadGD[nI,2]) == "FRR_NOME"
				   		aAdd( aAux, cUsrFullName)
				 	EndIf
				EndIf
			Next nI

			aAdd(aAux,.f.)
			aAdd(aRetCols,aAux)
			aAux := {}
			FRR->(dbSkip())
		EndDo

	Endif

	RestArea(aAreaFRR)
Endif

Return(aRetCols)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA005LINOK  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da linha do objeto MsNewGetDados.				   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA005LINOK(oGetDados,nLin)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oGetDados	- objeto: instancia de MsNewGetDados            	³±±
±±³          ³nLin		- Numeric: Nro da Linha do array aCols do objeto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³lRet	- Boolean: Se a linha foi validada			         	³±±
±±³       	 ³		.t. - linha validada									³±±
±±³       	 ³		.f. - linha invalidada									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FA005LINOK(oGetDados,nLin)

Local lRet		:= .t.

Local nI		:= 0
Local nX		:= 0
Default nLin	:= oGetDados:nAt

If !oGetDados:aCols[nLin,len(oGetDados:aHeader)+1]
	For nI := 1 to Len(oGetDados:aCols[nLin])-1

		If Alltrim(oGetDados:aHeader[nI,2]) == "FRR_CODGES"
			For nX := 1 to len(oGetDados:aCols)
				If !oGetDados:aCols[nX,len(oGetDados:aHeader)+1]
					If nX <> nLin
						If oGetDados:aCols[nX,nI] == oGetDados:aCols[nLin,nI]
							Help(" ",1,"FA005LINOK",,STR0007 + alltrim(oGetDados:aCols[nLin,nI]) + STR0008 + strzero(nI,3),1,0) //"O Gestor selecionado, "#", é o mesmo que da linha "
							lRet := .f.
							Exit
						Endif
					Endif
				Endif
			Next nX
		Endif

	Next nI
Endif

If lRet
	If ExistBlock("FA005LOK")
		lRet := ExecBlock("FA005LOK",.f.,.f.,{nLin,oGetDados})
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA005ALLOK  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do formulario de cadastro de grupo de gestores.   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA005ALLOK(oGetDados,nOpcao)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oGetDados	- objeto: instancia de MsNewGetDados            	³±±
±±³			 ³nOpcao	- Numeric: Opcao de manipulacao de dados 		    ³±±
±±³			 ³				2 - Visualizar 		  							³±±
±±³			 ³				3 - Incluir 		  							³±±
±±³			 ³				4 - Alterar 		  							³±±
±±³			 ³				5 - Excluir 		  							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³lRet	- Boolean: Se o formulario foi validado			        ³±±
±±³       	 ³		.t. - formulario validado								³±±
±±³       	 ³		.f. - formulario invalidado								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA005ALLOK( oGetDados, nOpcao )

Local lRet		:= .T.
Local nI		:= 0
Local nX		:= 0
Local nDel		:= 0
Local aAreaFRR	:= FRR->(GetArea())
Local nPos      := aScan( oGetDados:aHeader, { |x| Alltrim(x[2]) $ "FRR_CODGES" } )

For nI := 1 to len(oGetDados:aCols)

	If nOpcao == 3 .or. nOpcao == 4

		If !oGetDados:aCols[nI,len(oGetDados:aHeader)+1]

			For nX := 1 to len(oGetDados:aHeader)
				If oGetDados:aHeader[nX,17] .Or. nX == nPos
					If Empty(oGetDados:aCols[nI,nX])
						Help( oGetDados:aHeader[nX,2], 1, "OBRIGAT" )
						lRet := .f.
						Exit
					Endif
				Endif
			Next nX

			If lRet
				lRet := FA005LINOK(oGetDados,nI)
			Endif

			If !lRet
				Exit
			Endif

		Else
			nDel++
		Endif

		If lRet
			If nDel == len(oGetDados:aCols)
				lRet := .f.
				Help( " ", 1, "FA005ALLOK", , STR0009, 1, 0 )	//"Todos os itens foram excluídos."
			Endif
		Endif

	Elseif nOpcao == 5

		lRet := FA005DELOK(oGetDados,nI)

		If !lRet
			Exit
		Endif
	Endif
Next nI

If lRet
	If ExistBlock("FA005VOK")
		lRet := ExecBlock("FA005VOK",.f.,.f.,{nOpcao,oGetDados})
	Endif
Endif

RestArea(aAreaFRR)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA005DELOK  ³ Rev.  ³Fernando Radu Muscalu  ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da exclusao da linha do objeto MsNewGetDados.   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA005DELOK(oGetDados,nLin)                             	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oGetDados	- objeto: instancia de MsNewGetDados            	³±±
±±³          ³nLin		- Numeric: Nro da Linha do array aCols do objeto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³lRet	- Boolean: Se exclusao da linha foi validada			³±±
±±³       	 ³		.t. - exclusao da linha validada						³±±
±±³       	 ³		.f. - exclusao da linha invalidada						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA005DELOK(oGetDados,nLin)

Local lRet		:= .t.

Local nPGes		:= aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == "FRR_CODGES" })
Local nPNome	:= aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == "FRR_NOME" })
Local aSaldo	:= {}

Default nLin	:= oGetDados:nAt

//Para se retornar as movimentacoes de todo o periodo ate a data atua, nao deve informar a data no parametro 2 da funcao abaixo.
//Como ha uma necessidade de checar se ha movimentacoes para este aprovador, diferente de saldo inicial, omiti o parametro data.
aSaldo := fXAlcSld(FRR->FRR_MOEDA,,oGetDados:aCols[nLin,nPGes])

If FXALCCHKTP(aSaldo,"2|3|4|5")//CHECA SE EXISTE MOVIMENTACAO PARA OS TIPOS DE SALDO PARAMETRIZADOS
	lRet := .f.
	Help(" ",1,"FA005DELOK",,STR0010 + Alltrim(oGetDados:aCols[nLin,nPNome]) + STR0011,1,0) //"O Aprovador "#" possui movimentações além do SALDO INICIAL."
Endif

If lRet
	If ExistBlock("FA005DLN")
		lRet := ExecBlock("FA005DLN",.f.,.f.,{nLin,oGetDados})
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA005VLDNV	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacoes para o nivel do gestor do grupo.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA005VLDNV()												      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nenhum													   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Boolean: Retorna a validacao do Nivel.				  ³±±
±±³			 ³					moeda.										  ³±±
±±³			 ³					.t. - Nivel validado					      ³±±
±±³			 ³					.f. - Nivel invalidado		    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Tabela FRR, validacoes de campos (X3_VALID)		              ³±±
±±³			 ³	- FRR_NIVEL													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA005VLDNV()

Local lRet	:= .t.

If Substr(ReadVar(),4) == "FRR_NIVEL"

	If !(IsDigit(M->FRR_NIVEL)) .OR. Empty(M->FRR_NIVEL)
		M->FRR_NIVEL := "00"
	Endif

	If Val(M->FRR_NIVEL) < 0 .or. Val(M->FRR_NIVEL) > 99
		lRet := .f.
	Endif
Endif

If lRet
	If len(alltrim(M->FRR_NIVEL)) == 1
		M->FRR_NIVEL := "0"+alltrim(M->FRR_NIVEL)
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA005TRIGG	³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para retorna conteudo do contra-dominio de acordo com	  ³±±
±±³          ³parametro														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA005TRIGG(cCampo)										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCampo	-String: Campo contra-dominio do gatilho			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³xRetTrigger	- Any: Retorna conteudo do campo de contra-dominio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gatilhos para o arquivo FRR, Regras do gatilho (X7_REGRA)		  ³±±
±±³			 ³	- FRR_CODGES Sequencia 001									  ³±±
±±³			 ³	- FRR_CODGES Sequencia 002									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA005TRIGG(cCampo)

Local cChave1 := xFilial("FRP") + PadR(M->FRR_CODGES,TamSX3("FRP_COD")[1]) + PadR(M->FRR_MOEDA,TAMSX3("FRP_MOEDA")[1])
Local xRetTrigger := FRP->(GetAdvFVal("FRP",cCampo,cChave1,1,""))

Return(xRetTrigger)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA005GRV		³ Rev.  ³Fernando Radu Muscalu  ³ Data ³24.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de atualizacao do arquivo FRR.						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FA005GRV(nOpcao,oGetDados)								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpcao	- Numeric: Opcao de manipulacao de dados de aRotina   ³±±
±±³          ³				3 - Inclusao    								  ³±±
±±³          ³				4 - Alteracao    								  ³±±
±±³          ³				5 - Exclusao    								  ³±±
±±³          ³oGetDados	- Objeto: Instancia de MsNewGetDados				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil.														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAFIN										                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FA005GRV(nOpcao,oGetDados,lAutomato)

Local nI	:= 0
Local nX	:= 0

Local cChave1	:= ""

Local lInsert	:= .f.
Local lExcPE	:= .t.
local lFA005DEL := ExistBlock("FA005DEL")
Default lAutomato	:= .F. //Se inicializa en .T. cuando viene por automatización, en todos los demás casos es .F.

   If lAutomato  .and. (nOpcao == 3 .OR. nOpcao == 4)
      If FindFunction ("GetParAuto")  // Tratamiento para scripts automatizados
         aRetAuto  := GetParAuto("FINA005TESTCASE")
         M->FRR_DESC 	:= aRetAuto[1]
         M->FRR_MOEDA 	:= aRetAuto[2]  
         oGetDados:aCols:= aRetAuto[3] 
         
         	
     Endif
   Endif

For nI := 1 to  len(oGetDados:aCols)

	cChave1 := xFilial("FRR") +;
				PadR(M->FRR_COD,TamSx3("FRR_COD")[1]) +;
				PadR(M->FRR_MOEDA,TamSx3("FRR_MOEDA")[1]) +;
				PadR(oGetDados:aCols[nI,1],TamSx3("FRR_ITEM")[1])

	FRR->(DbSetOrder(1))

	lSeek := FRR->(DbSeek(cChave1))

	Do Case
		Case nOpcao == 3 .OR. nOpcao == 4

			If nOpcao == 3 .Or. !lSeek
				lInsert := .t.
			Else
				lInsert := .f.
			Endif

			If !oGetDados:aCols[nI,len(oGetDados:aHeader)+1]

				RecLock("FRR",lInsert)

				If lInsert
					FRR->FRR_FILIAL	:= xFilial("FRR")
					FRR->FRR_COD	:= M->FRR_COD
					FRR->FRR_DESC	:= M->FRR_DESC
					FRR->FRR_MOEDA	:= M->FRR_MOEDA
                Endif

				For nX := 1 to len(oGetDados:aHeader)
					FRR->&(oGetDados:aHeader[nX,2]) := oGetDados:aCols[nI,nX]
				Next nX

				FRR->(MSUnlock())

			Else
				If lSeek
					RecLock("FRR",.F.)
						FRR->(DbDelete())
					FRR->(MsUnlock())
				Endif
			Endif

		Case nOpcao == 5
			If lSeek
				If lFA005DEL
					lExcPE := ExecBlock("FA005DEL",.f.,.f.)
				Endif

				If lExcPE
					RecLock("FRR",.F.)
						FRR->(DbDelete())
					FRR->(MsUnlock())
				Endif

			Endif
	End Case
Next nI

If nOpcao == 3 .or. nOpcao == 4
	If ExistBlock("FA5GRAVA")
		ExecBlock("FA5GRAVA",.f.,.f.,{nOpcao})
	Endif
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ F005VldCpo º Autor ³ Danilo Dias      º Data ³ 11/07/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o campo digitado na MsGetDados já existe e se o  º±±
±±º          ³ mesmo foi deletado.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function F005VldCpo( cAlias, cCampo )

Local aArea      := GetArea()
Local lRet       := .T.
Local nI         := 1
Local aCHeader   := aClone(aHeader)
Local aCCols     := aClone(aCols)
Local nLenCols   := Len(aCCols)
Local nLenHeader := Len(aCHeader)
Local nPosHeader := aScan( aCHeader, { |nPos| AllTrim(nPos[2]) == cCampo } )

For nI := 1 To ( nLenCols - 1 )
	If !(aCCols[nI,nLenHeader+1]) .And. AllTrim(aCCols[nI,nPosHeader]) == &( 'M->' + cCampo )
		lRet := .F.
		Help( " ", 1, "F005VldCpo", , STR0013, 1, 0 )	//"Registro já gravado!"
		Exit
	EndIf
Next nI

RestArea(aArea)

Return lRet
