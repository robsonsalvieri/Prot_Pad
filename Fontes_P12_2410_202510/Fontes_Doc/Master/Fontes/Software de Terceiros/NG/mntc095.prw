#INCLUDE	"Protheus.ch"
#INCLUDE	"MsGraphi.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTC095   บAutor  ณWagner S. de Lacerdaบ Data ณ  12/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta de Variacao dos Contadores.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบTabelas   ณ ST9 - Bem                                                  บฑฑ
ฑฑบ          ณ STP - Ordens de Servico de Acompanhamento (Contador 1)     บฑฑ
ฑฑบ          ณ TPP - Ordens de Servico de Acompanhamento (Contador 2)     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cParCodBem -> Opcional;                                    บฑฑ
ฑฑบ          ณ               Indica o Codigo do Bem para a consulta.      บฑฑ
ฑฑบ          ณ               Default: Codigo do Bem atual (a partir do    บฑฑ
ฑฑบ          ณ                        registro posicionado atualmente na  บฑฑ
ฑฑบ          ณ                        tabela ST9)                         บฑฑ
ฑฑบ          ณ cParCodFil -> Opcional;                                    บฑฑ
ฑฑบ          ณ               Indica o Codigo da Filial para a consulta.   บฑฑ
ฑฑบ          ณ               Default: xFilial("ST9")                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC095(cParCodBem, cParCodFil)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aNGBEGINPRM := NGBEGINPRM()

Local aTempColor := aClone( NGCOLOR() )

Local cOldCadast := If(Type("cCadastro") == "C",cCadastro,"")
Local lOldINCLUI := If(Type("INCLUI") == "L",INCLUI,.F.)
Local lOldALTERA := If(Type("ALTERA") == "L",ALTERA,.F.)

Default cParCodBem := ""
Default cParCodFil := ""

/* Variaveis da Tela */
Private oDlgVar, oPnlVar, aBtnDlgVar
Private oObjVar
Private oPnlCabec

Private oFontVar := TFont():New(, , 16, .T., .T.)
Private nCorVarF := CLR_BLACK
Private nCorVarB := CLR_WHITE
/**/

/* Variaveis Padroes da Rotina */
Private cVerCodBem := "", cVerNomBem := ""
Private cVerCodFil := ""

Private aContador1 := {}
Private aContador2 := {}
Private lContador1 := .F.
Private lContador2 := .F.

Private dDeData   := CTOD("")
Private dAteData  := CTOD("")
Private lTodoHist := .F.
Private oCbxCont, aCbxCont, cCbxCont
Private nTipPeriod := 0 //Visualizacao da Variacao

Private aSize    := MsAdvSize()
Private nLargura := 0
Private nAltura  := 0
/**/

Private cSrvBarra := If(IsSrvUnix(),"/","\")
Private cMV_Path  := Alltrim( SuperGetMV("MV_DIRACA",.F.,cSrvBarra+CurDir()) )// Path do arquivo logo .bmp do cliente
/**/

//Define Altura e Largura
If !(Alltrim(GetTheme()) == "FLAT") .And. !SetMdiChild()
	aSize[7] -= 50
	aSize[6] -= 30
ElseIf SetMdiChild()
	aSize[5] -= 03
EndIf
nAltura  := aSize[6]
nLargura := aSize[5]

INCLUI := .F.
ALTERA := .F.

//Define a Barra do Caminho da Imagem
If SubStr(cMV_Path,Len(cMV_Path)) <> cSrvBarra
	cMV_Path += cSrvBarra
EndIf

//Inicio funcional da Consulta
cCadastro := OemToAnsi("Consulta de Varia็ใo de Contadores")

dbSelectArea("ST9")
cVerCodBem := If(!Empty(cParCodBem), PADR(cParCodBem,TAMSX3("T9_CODBEM")[1]," "), ST9->T9_CODBEM)
cVerCodFil := If(!Empty(cParCodFil), cParCodFil, xFilial("ST9"))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Valida o Bem                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !fValidaBem()
	fExit(cOldCadast, lOldINCLUI, lOldALTERA, aNGBEGINPRM)
	Return .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca os Contadores do Bem  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dAteData := dDataBase //Data Atual
dDeData  := dAteData - (30 * 6) //Data Atual - 6 Meses

aCbxCont := {}
If lContador1 .Or. lContador2 //O primeiro contador DEVE estar disponivel caso haja o segundo contador
	aAdd(aCbxCont,"1"+"บ"+" "+"Contador")
EndIf
If lContador2
	aAdd(aCbxCont,"2"+"บ"+" "+"Contador")
EndIf
If lContador1 .And. lContador2
	aAdd(aCbxCont,"Ambos")
EndIf
cCbxCont := aCbxCont[1]

nTipPeriod := 4 //Mensal

Processa({|| fContador(1), fContador(2) }, "Aguarde...")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a Tela                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nCorVarF := aTempColor[1]
nCorVarB := aTempColor[2]

DEFINE MSDIALOG oDlgVar TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] COLOR CLR_BLACK, CLR_WHITE OF oMainWnd PIXEL
	
	oDlgVar:lEscClose := .F.
	
	oDlgVar:lMaximized := .T.
	
	//Painel do Dialog
	oPnlVar := TPanel():New(01, 01, , oDlgVar, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oPnlVar:Align := CONTROL_ALIGN_ALLCLIENT
	
	//Layer
	oLayerVar := FWLayer():New()
	oLayerVar:Init(oPnlVar, .F.)
	
	fLayout() //Cria o Layout da Tela
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cabecalho                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Painel Pai do Cabecalho
	oPnlCabec := TPanel():New(01, 01, , oObjVar, , , , CLR_BLACK, nCorVarB, 100, 035, .T., .T.)
	oPnlCabec:Align := CONTROL_ALIGN_TOP
	
		//Bem
		TSay():New(005, 012, {|| OemToAnsi("Bem"+":")}, oPnlCabec, , oFontVar, , ;
									, ,.T., nCorVarF, , 050, 015)
		TSay():New(005, 050, {|| OemToAnsi(AllTrim(cVerCodBem) + " - " + AllTrim(cVerNomBem))}, oPnlCabec, , oFontVar, , ;
									, ,.T., nCorVarF, , 400, 015)
		
		//Visualizando Contador
		TSay():New(020, 012, {|| OemToAnsi("Contador"+":")}, oPnlCabec, , oFontVar, , ;
									, ,.T., nCorVarF, , 050, 010)
		oCbxCont := TComboBox():New(019, 050, {|u| If(PCount() > 0, cCbxCont := u, cCbxCont)},;
										aCbxCont, 060, 015, oPnlCabec, ,;
										, , , , .T., , , , , , , , ,"cCbxCont")
		oCbxCont:bHelp := {|| ShowHelpCpo("Contador",;
								{"Selecione o Contador para mostrar no grแfico."},2,;
								{},2)}
	
ACTIVATE MSDIALOG oDlgVar ON INIT EnchoiceBar(oDlgVar, {|| oDlgVar:End() }, {|| oDlgVar:End() }, , aBtnDlgVar) CENTERED

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
fExit(cOldCadast, lOldINCLUI, lOldALTERA, aNGBEGINPRM)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfExit     บAutor  ณWagner S. de Lacerdaบ Data ณ  12/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para retornar as variaveis ao sair da consulta.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOldCadast --> Obrigatorio;                                บฑฑ
ฑฑบ          ณ                Indica o 'cCadastro' anterior.              บฑฑ
ฑฑบ          ณ lOldINCLUI --> Opcional;                                   บฑฑ
ฑฑบ          ณ                Indica o 'INCLUI' anterior.                 บฑฑ
ฑฑบ          ณ lOldALTERA --> Opcional;                                   บฑฑ
ฑฑบ          ณ                Indica o 'ALTERA' anterior.                 บฑฑ
ฑฑบ          ณ aNGBEGINPRM -> Opcional;                                   บฑฑ
ฑฑบ          ณ                Indica as demais variaveis para retornar.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC095                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fExit(cOldCadast, lOldINCLUI, lOldALTERA, aNGBEGINPRM)

cCadastro := cOldCadast

INCLUI := lOldINCLUI
ALTERA := lOldALTERA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfLayout   บAutor  ณWagner S. de Lacerdaบ Data ณ  12/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o Layout da tela.                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC095                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLayout()

//Linhas
oLayerVar:AddLine("Linha_Consulta" , 100, .F.)

//Colunas
oLayerVar:AddCollumn("Coluna_Consulta", 100, .F., "Linha_Consulta")

//Janelas
oLayerVar:AddWindow("Coluna_Consulta", "Janela_Consulta" , , 100,;
					.F., .F., /*bAction*/, "Linha_Consulta", /*bGotFocus*/)

//Objetos
oObjVar := oLayerVar:GetWinPanel("Coluna_Consulta" , "Janela_Consulta" , "Linha_Consulta")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfValidaBemบAutor  ณWagner S. de Lacerdaบ Data ณ  12/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o Bem.                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC095                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fValidaBem()

dbSelectArea("ST9")
dbSetOrder(1)
If !dbSeek(cVerCodFil+cVerCodBem)
	ApMsgInfo("Nใo foi possํvel montar a consulta."+CRLF+CRLF+;
				"Motivo"+": "+"O Bem nใo estแ cadastrado no sistema.","Aten็ใo")
	Return .F.
EndIf
cVerNomBem := ST9->T9_NOME

lContador1 := ( AllTrim(ST9->T9_TEMCONT) <> "N" )

dbSelectArea("TPE")
dbSetOrder(1)
lContador2 := dbSeek(ST9->T9_FILIAL+ST9->T9_CODBEM)

If !lContador1 .And. !lContador2
	ApMsgInfo("Nใo foi possํvel montar a consulta."+CRLF+CRLF+;
				"Motivo"+": "+"O Bem nใo ้ controlado por contador.","Aten็ใo")
	Return .F.
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfContador บAutor  ณWagner S. de Lacerdaบ Data ณ  12/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca os Contadors do Bem no periodo determinado.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTipCont -> Opcional;                                      บฑฑ
ฑฑบ          ณ             Indica qual o Contador a buscar.               บฑฑ
ฑฑบ          ณ              1 - Contador 1 do Bem                         บฑฑ
ฑฑบ          ณ              2 - Contador 2 do Bem                         บฑฑ
ฑฑบ          ณ             Default: 1.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC095                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fContador(nTipCont)

Local aDadosCont := {}
Local cCodFilTMP := ""

Local aBuscaCont := {}
Local lBuscaCont := .T.

Default nTipCont := 1

If nTipCont == 1
	aDadosCont := {"STP",;
					"STP->TP_CODBEM" , "STP->TP_ORDEM", "STP->TP_PLANO"  ,;
					"STP->TP_DTLEITU", "STP->TP_HORA" , "STP->TP_POSCONT",;
					"STP->TP_FILIAL"}
	
	lBuscaCont := lContador1
Else
	aDadosCont := {"TPP",;
					"TPP->TPP_CODBEM", "TPP->TPP_ORDEM", "TPP->TPP_PLANO"  ,;
					"TPP->TPP_DTLEIT", "TPP->TPP_HORA" , "TPP->TPP_POSCON",;
					"TPP->TPP_FILIAL"}
	
	lBuscaCont := lContador2
EndIf

cCodFilTMP := If(NGSX2MODO(aDadosCont[1]) == "E", cVerCodFil, xFilial(aDadosCont[1]))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca Contador              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aBuscaCont := {}

If lBuscaCont
	dbSelectArea(aDadosCont[1])
	dbSetOrder(5)
	dbSeek(cCodFilTMP+cVerCodBem+If(!lTodoHist,DTOS(dDeData),""),.T.)
	
	ProcRegua(LastRec() - RecNo())
	While !Eof() .And. &(aDadosCont[8]) == cCodFilTMP .And. AllTrim(&(aDadosCont[2])) == AllTrim(cVerCodBem) .And. If(!lTodoHist,&(aDadosCont[5]) <= dAteData,.T.)
		IncProc("Carregando"+" "+"Contador"+" "+cValToChar(nTipCont)+"...")
		
		//1             ; 2                ; 3                   ; 4               ; 5               ; 6
		//Codigo do Bem ; Ordem de Servico ; Plano de Manutencao ; Data da Leitura ; Hora da Leitura ; Posicao do Contador
		aAdd(aBuscaCont, {&(aDadosCont[2]), &(aDadosCont[3]), &(aDadosCont[4]), &(aDadosCont[5]), &(aDadosCont[6]), &(aDadosCont[7])})
		
		dbSelectArea(aDadosCont[1])
		dbSkip()
	End
EndIf

If Len(aBuscaCont) > 0
	aSort(aBuscaCont, , , {|x,y| DTOS(x[4])+x[5] < DTOS(y[4])+y[5] })
EndIf

If nTipCont == 1
	aContador1 := aClone( aBuscaCont )
Else
	aContador2 := aClone( aBuscaCont )
EndIf

Return .T.
