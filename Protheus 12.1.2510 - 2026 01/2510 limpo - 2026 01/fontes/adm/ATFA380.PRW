#Include 'Protheus.CH'
#Include "ApWizard.ch"
#Include "ATFA380.ch"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES DE NOPC DA ROTINAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE VISUALIZAR		2
#DEFINE INCLUIR			3
#DEFINE ALTERAR			4
#DEFINE EXCLUIR			5
#DEFINE EFETIVAR		6
#DEFINE IMPORTAR		7
#DEFINE EXPORTAR		8

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFlag de processamento escrito no arquivo de controle ณ
//ณde threads                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE OK		 		"OK"
#DEFINE ERRO		 	"ERRO"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do array para controle do processamento MultThreadณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE ARQUIVO		 		1
#DEFINE MARCA		 		2
#DEFINE QTD_REGISTROS		3
#DEFINE REC_MIN				4
#DEFINE REC_MAX				5

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do array para controle de Limte /Perda / Reversใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE LIMITE		 		1
#DEFINE PERDAACM		 	2
#DEFINE REVERACM		    3

//********************************
// Controle de multiplas moedas  *
//********************************
Static lMultMoed := .T.
STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location
Static lIsBrasil := (cPaisLoc $ "BRA")
Static _oATFA3801
Static lEfetImp  := .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA380   บAutor  ณ Acacio Egas        บ Data ณ  29/12/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Redu็ใo ao Valor Recuperแvel do Ativo					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/                                        
Function ATFA380()
Local nNumProc		:= SuperGetMv("MV_ATFMTHR", .F., 1 )
Local cTipoGer		:= SuperGetMv( "MV_ATFTIOA", .F., "12" )
Local cTypesNM		:= IIF(lIsRussia,"/" + AtfNValMod({1,2}, "/"),"") // CAZARINI - 07/04/2017 - If is Russia, add new valuations models - main and recoverable models

Private cCadastro 	:= STR0001 //"Redu็ใo ao Valor Recuperแvel do Ativo"
Private aRotina 	:= MenuDef()
Private cMarca 		:= GetMark()
Private aPanels		:= {}
Private oGetD 		:= Nil	
Private cPerg		:= "AF380S"
Private EDITWIZAR	:= .F.
Private cMsgConta   := ""

Pergunte(cPerg,.F.)
SetKey( VK_F12, { || Pergunte(cPerg,.T.) } )

If !(cTipoGer $ '10/12' + cTypesNM)
	Help( " ", 1, "AF380PARAM",, STR0107, 1, 0 ) // "Parโmetro MV_ATFTIOA configurado incorretamente, por favor verificar "
	Return
EndIf

If nNumProc < 1 .or. nNumProc > 15
	Help(" ",1,"AF380Thread",,STR0003+CTRL+STR0004,1,0)
	nNumProc := 1
EndIf

DbSelectArea( "SNI" )
SNI->( DbSetOrder( 1 ) ) 

mBrowse( ,,,, "SNI", ,,,,, /*aCores*/ )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf380WizarบAutor  ณ Acacio Egas        บ Data ณ  29/12/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclui movimento de Redu็ใo ao valor recuperavel de ativos บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Af380Wizar(cAlias, nReg, nOpc, lAutomato) 
Local oWizard 		:= Nil
Local oWPanel		:= Nil
Local aPBox1	 	:= {}
Local aPBox2		:= {}
Local nOpcRot		:= 0
LOCAL nSaveSx8Len 	:= GetSx8Len()
Local lRet 			:= .T.
Local nNumProc		:= SuperGetMv("MV_ATFMTHR", .F., 1 )
Local aRet2			:= { 1 }
Local aRetPer 	:= Array( 12 ) // Respostas da perguntas do 1 parambox (Parametros Gerais)

Default lAutomato := .F.

If nOpc <> INCLUIR
	If xFilial( "SNI") # SNI->NI_FILIAL .OR. ( SNI->( Eof() ) .AND. SNI->( Bof() ) )
		Help( " ", 1, "ARQVAZIO" )
		Return
	EndIf
EndIf

Pergunte("AF380S",.F.)
If nNumProc > 1 .And. !A380VAgl("AF380S")
	Return
EndIf

If nOpc==INCLUIR
	EDITWIZAR := .T.
Else
	EDITWIZAR := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIncializa็ใo dos array de resposta do paramboxณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRetPer[01] 	:= Space( TamSx3('N1_CBASE')[1] )
aRetPer[02] 	:= Space( TamSx3('N1_CBASE')[1] )
aRetPer[03] 	:= Space( TamSx3('N1_GRUPO')[1] )
aRetPer[04] 	:= Space( TamSx3('N1_GRUPO')[1] )
aRetPer[05] 	:= Space( TamSx3('N3_CUSTBEM')[1] )
aRetPer[06] 	:= Space( TamSx3('N3_CUSTBEM')[1] )
aRetPer[07] 	:= Space( TamSx3('N3_CCONTAB')[1] )
aRetPer[08] 	:= Space( TamSx3('N3_CCONTAB')[1] )
aRetPer[09] 	:= StoD("")
aRetPer[10] 	:= StoD("")
aRetPer[11] 	:= Space( TamSx3('N1_ITEM')[1] )
aRetPer[12] 	:= Space( TamSx3('N1_ITEM')[1] )

If nOpc <> INCLUIR
	If SNI->NI_ROTINA == "1"
		aRetPer	:= StrArray(SNI->NI_PARAM,aRetPer)
	ElseIf nOpc != EFETIVAR
	    aRetPer	:= StrArray(SNI->NI_PARAM)
	EndIf
EndIf


//Primeira pagina do Wizard
aAdd(aPBox1,{ 1,    STR0005,	Space(TamSx3('N1_CBASE')[1]),       "@!"    ,""                 ,"SN1"  ,"EDITWIZAR",                          50,  .F.}) //"Bem de"
aAdd(aPBox1,{ 1,    STR0006,	Space(TamSx3('N1_CBASE')[1]),       "@!"    ,""                 ,"SN1"  ,"EDITWIZAR",                          50,  .F.}) //"Bem at้"
aAdd(aPBox1,{ 1,    STR0007,	Space(TamSx3('N1_GRUPO')[1]),       "@!"    ,""                 ,"SNG"  ,"EDITWIZAR",                          50,  .F.}) //"Grupo de"
aAdd(aPBox1,{ 1,    STR0008,	Space(TamSx3('N1_GRUPO')[1]),       "@!"    ,""                 ,"SNG"  ,"EDITWIZAR",                          50,  .F.}) //"Grupo at้"
aAdd(aPBox1,{ 1,    STR0009,	Space(TamSx3('N3_CUSTBEM')[1]),     "@!"    ,""                 ,"CTT"  ,"EDITWIZAR",                          50,  .F.}) //"Centro de Custo de"
aAdd(aPBox1,{ 1,    STR0010,	Space(TamSx3('N3_CUSTBEM')[1]),     "@!"    ,""                 ,"CTT"  ,"EDITWIZAR",                          50,  .F.}) //"Centro de Custo at้"
aAdd(aPBox1,{ 1,    STR0011,	Space(TamSx3('N3_CCONTAB')[1]),     "@!"    ,""                 ,"CT1"  ,"EDITWIZAR",                          50,  .F.}) //"Conta de"
aAdd(aPBox1,{ 1,    STR0012,	Space(TamSx3('N3_CCONTAB')[1]),     "@!"    ,""                 ,"CT1"  ,"EDITWIZAR",                          50,  .F.}) //"Conta at้"
aAdd(aPBox1,{ 1,    STR0102,	StoD("")					  ,     "@D"    ,""                 ,""     ,"EDITWIZAR",                          50,  .F.}) //"Data De "
aAdd(aPBox1,{ 1,    STR0103,	StoD("")                      ,     "@D"    ,""                 ,""     ,"EDITWIZAR",                          50,  .F.}) //"Data at้"
aAdd(aPBox1,{ 1,    STR0104 ,	Space(TamSx3('N1_ITEM')[1]),       "@!"    ,""                 ,""  ,"EDITWIZAR",                          	   50,  .F.}) //"Item de"
aAdd(aPBox1,{ 1,    STR0105,	Space(TamSx3('N1_ITEM')[1]),       "@!"    ,""                 ,""  ,"EDITWIZAR",                          	   50,  .F.}) //"Item at้"

//**************************
// Valida็ใo da efetiva็ใo *
//**************************
If nOpc==EFETIVAR
	If SNI->NI_STATUS <> "1"
		Aviso(STR0040, STR0041 , {STR0042}) //"Aten็ใo"##"Nใo ้ possivel efetivar novamente!"##"OK"
		Return
	ElseIf SNI->NI_DTEMIS > dDataBase
		Aviso(STR0042, STR0043 , {STR0042})//"Aten็ใo"##"A data de efetiva็ใo nใo pode ser anterior a data de emissใo da simula็ใo!"##"OK"
		Return
	EndIf
	aRet2	:= {2}
	//Validacao para o bloqueio do processo
	If !CtbValiDt(,dDataBase  ,,,,{"ATF001"},)
		Return 
	EndIf
EndIf

//**************************
// Valida็ใo para excluir  *
//**************************
If nOpc==EXCLUIR
	If SNI->NI_STATUS <> "1"
		Aviso(STR0040, STR0047, {STR0042}) //"Aten็ใo"## "Nใo ้ possivel excluir uma simula็ใo efetivada!"  ##"OK"
		Return
	EndIf
EndIf

//**************************
// Valida็ใo para alterar  *
//**************************
If nOpc == ALTERAR
	If SNI->NI_STATUS <> "1"
		Aviso(STR0040, STR0135, {STR0042}) //"Aten็ใo"## "Nใo ้ possivel alterar uma simula็ใo efetivada!"  ##"OK"
		Return
	EndIf
EndIf

aAdd(aPBox2,{3,STR0013,2,{ STR0014, STR0015 },60,".T.",.T.,IIF(nOPC == INCLUIR .Or. nOPC == ALTERAR , .T. , .F. )})  //"O que deseja fazer"###"Simular"###"Efetivar"

DEFINE WIZARD oWizard TITLE STR0001;//"Redu็ใo ao Valor Recuperแvel do Ativo"
HEADER STR0016 ; 			//"Simula็ใo e Efetiva็ใo do Redu็ใo ao Valor Recuperแvel do Ativo"
MESSAGE "";//STR0017; 			//"Parโmetros Iniciais..."
TEXT STR0018 + CRLF +;		//"O objetivo desta rotina ้ definir procedimentos visando a assegurar que"
STR0019 + CRLF +;		//"os ativos nใo estejam registrados contabilmente por um valor superior"
STR0020;				//"aquele passivel de ser recuperado por uso ou por venda."
NEXT {||.T.} ;
	FINISH {|| .T. } ;
	PANEL

	//Segunda Pagina 
CREATE PANEL oWizard ;
	HEADER STR0044 ; 	//"Dados da Sinula็ใo da redu็ใo ao valor recuperavel de ativos."
MESSAGE ;
	BACK {|| .T. } ;
	NEXT {|| .T. } ;
	FINISH {|| if (SNI->NI_ROTINA = "2" .and. nOpc==VISUALIZAR, nOpcRot := 1,.t.), .T. } ;
	PANEL

 
RegToMemory("SNI", If(nOpc==INCLUIR,.T.,.F.),,,Iif(!lAutomato,FunName(),))
If nOpc==INCLUIR
	M->NI_PROC 	:= GetSx8Num("SNI","NI_PROC",,1)
	M->NI_DTEMIS:= dDatabase
	M->NI_STATUS	:= "1"
Else
	M->NI_PROC 	:= SNI->NI_PROC
	M->NI_DTEMIS:= SNI->NI_DTEMIS
	M->NI_STATUS:= SNI->NI_STATUS
	M->NI_DTIOA	:= SNI->NI_DTIOA
EndIf
  //	oWPanel	:= TPanel():New(0,0,'',oWizard:GetPanel(2),, .T., .T.,, ,280,150,.T.,.T. ) 
oMsmSNI	:= MsMGet():New("SNI",SNI->(RECNO()),nOpc,,,,,/*{0, 0, 640, 480}*/,,4,,,,oWizard:GetPanel(2),,,.F.)
oMsmSNI:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oMsmSNI:Disable()
If SNI->NI_ROTINA != '2' .Or. nOpc==INCLUIR
	//Terceira Pagina
	CREATE PANEL oWizard ;
		HEADER STR0021 ; 	//"Informe Parโmetros Iniciais" ;
		MESSAGE ; 	//"Determine o filtro para sele็ใo."
	BACK {|| .T. } ;
		NEXT {|| .T. } ;
		FINISH {|| If(nOpc = VISUALIZAR,nOpcRot := 1,.T.),  .T. } ;
		PANEL

	ParamBox(aPBox1,STR0027, @aRetPer,,,,,,oWizard:GetPanel(3)) //"Parโmetros..."
EndIf
If nOpc = INCLUIR .Or. nOpc != VISUALIZAR 
	CREATE PANEL oWizard ;
		HEADER STR0025; 	//"Processamento" ;
		MESSAGE STR0026; 	//"Informe o que deseja fazer..."
	BACK {|| .T. } ;
		NEXT {|| .T. } ;
		FINISH {|| nOpcRot := 1 , .T.} ;
		PANEL
		
	If SNI->NI_ROTINA == "2" .And. ( nOpc == EFETIVAR .OR. nOpc == ALTERAR .OR. nOpc == EXCLUIR )  
		ParamBox(aPBox2,STR0028, @aRet2  ,,,,,,oWizard:GetPanel(3))
	Else
		ParamBox(aPBox2,STR0028, @aRet2  ,,,,,,oWizard:GetPanel(4)) //"Processamento..."
	EndIf
	
Else
	nOpcRot := 0
EndIf

If !lAutomato
	ACTIVATE WIZARD oWizard CENTERED
Else
	If FindFunction("GetParAuto")
		aRetAuto	:= GetParAuto("ATFA380TestCase")
		aRetPer	:= aRetAuto[1]
		nOpcRot := 1
	EndIf
EndIf

If nOpcRot == 1
	//Validacao para o bloqueio do processo
	If nOpc == INCLUIR .And. aRet2[1] == 2
		lRet := CtbValiDt(,dDataBase  ,,,,{"ATF001"},) 
	EndIf
	If lRet 
		M->NI_PARAM := StrArray(aRetPer)
		lRet := Af380SelIOA(aRetPer,aRet2[1] == 2, nOpc,,,,lAutomato)
	EndIF
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณRetorna a numera็ใo caso o usuแrio nใo confirmeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If (nOpcRot == 0 .or. !lRet) .And. nOpc == INCLUIR
	While GetSx8Len() > nSaveSx8Len
		RollBackSx8()
	End
ElseIf nOpc == INCLUIR
	ConfirmSx8()
EndIf

Return                                                                                                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf380SelIOAบAutor  ณAlvaro Camillo Netoบ Data ณ  05/05/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra a tela de sele็ใo dos bens  para processamento      บฑฑ
ฑฑบ          ณ do IOA                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA380                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Af380SelIOA(aRetPer,lEfetiva,nOpc,aAutoHeader,aAutoaCols,aRecnoSN3, lAutomato)

Local lRet 			:= .T.
Local nOpcA			:= 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsNewGetDados()      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Local aHeader  		:= {} 		//-	Necessario declara็ใo como private para uso interno no MsGetDAuto
//Local aCols			:= {}     //-	Necessario declara็ใo como private para uso interno no MsGetDAuto
Local nOpcX			:= GD_UPDATE							 				//GD_INSERT+GD_UPDATE+GD_DELETE					// Op็ใo da MsNewGetDados
Local cLinhaOk     	:= "AFA380LIN()"  										// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"										// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""			               			  		   		// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              									// Campos estaticos na GetDados.
Local nMax         	:= Val( Replicate( "9",TamSX3("NJ_ITEM")[1]) )              									// Numero maximo de linhas permitidas.
Local aAlter    	:= {}                                      				// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"						  				// Funcao executada na validacao do campo
Local cSuperDel     := "AllwaysTrue"          			  			 		// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        := "AllwaysTrue"    					 				// Funcao executada para validar a exclusao de uma linha do aCols
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis para a MsAdvSize e MsObjSizeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lEnchBar   		:= .F. // Se a janela de diแlogo possuirแ enchoicebar (.T.)
Local lPadrao    		:= .F. // Se a janela deve respeitar as medidas padr๕es do Protheus (.T.) ou usar o mแximo disponํvel (.F.)
Local nMinY	    		:= 400 // Altura mํnima da janela
Local aSize	   	   		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 			:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects	  		:= {}
Local aPosObj	   		:= {}

Local oDlg			:= Nil
Local oPanelSup		:= Nil
Local oPanelMed		:= Nil

Local aButton As Array

Private aHeader	//- Necessario declara็ใo como private para uso interno no MsGetDAuto  		 
Private aCols		//- Necessario declara็ใo como private para uso interno no MsGetDAuto

Private oGetSNJ 	:= Nil

Default aAutoHeader:= {}
Default aAutoaCols := {}
Default aRecnoSN3  := {}
Default lAutomato  := .F.

aButton := {}

lEfetImp := lEfetiva

IF !Empty(aAutoHeader) .And. !Empty(aAutoaCols)
	aHeader := aClone(aAutoHeader)
	aCOls 	:= aClone(aAutoaCols)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefini็ใo das posi็๕es dos objetos na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para os dados Enchoice
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.}) 
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do acols da get de modificadoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(aHeader) .And. Empty(aCOls)
	aHeader := CriaHeader(NIL,"NJ_PROC",aHeader,"SNJ") 
	aCols	:= CriaAcols( aHeader, @aRecnoSN3, aRetPer , nOpc )
EndIf

If Empty(aCols) .And. nOpc <> EXCLUIR 
	Help( " ",1,"AF380EOF",,STR0039,1,0)//"Nenhum registro foi encontrado com os parametros especificados"
	lRet 		:= .F.
	Return(lRet)
EndIf

If Len(aCols) > nMax
	Help( " ",1,"AF380MAX",,STR0073+ cValtoChar(nMax) + STR0074 ,1,0)//"O numero de registros ultrapassou o limite de " ##" linhas"
	lRet 		:= .F.
	Return(lRet)
EndIf

If lRet 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefini็ใod dos Objetosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If !lAutomato
		oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEstrutura de Panelsณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPanelSup 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
	oPanelSup:Align 	:= CONTROL_ALIGN_TOP
	oPanelMed 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,100,100,.T.,.T. )
	oPanelMed:Align 	:= CONTROL_ALIGN_ALLCLIENT
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMsNewGetDadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOpc == INCLUIR .Or. nOpc == ALTERAR  .Or. nOpc == IMPORTAR
		nOpcX := GD_DELETE+GD_UPDATE
	Else
		nOpcX := 0
	EndIf  
	
	If nOpc == EXCLUIR
		cLinhaOk := ""
	EndIf
	
	aAlter	:= {"NJ_VLREC01","NJ_VLTAX01","NJ_VLACM01"} 	
	aAdd(aAlter,"NJ_VLVEN01")
	aAdd(aAlter,"NJ_TPDEPR")
	aAdd(aAlter,"NJ_PERDEPR")
	aAdd(aAlter,"NJ_VMXDEPR")
	aAdd(aAlter,"NJ_VLSALV1")
	aAdd(aAlter,"NJ_PRODANO")
	aAdd(aAlter,"NJ_PRODMES")
	aAdd(aAlter,"NJ_PRODACM")
	aAdd(aAlter,"NJ_CODIND")
	aAdd(aAlter,"NJ_VLVEN02")
	aAdd(aAlter,"NJ_VLREC02")
	aAdd(aAlter,"NJ_TXDEPR2")
	aAdd(aAlter,"NJ_VRDACM2")
	aAdd(aAlter,"NJ_VLVEN03")
	aAdd(aAlter,"NJ_VLREC03")
	aAdd(aAlter,"NJ_TXDEPR3")
	aAdd(aAlter,"NJ_VRDACM3")
	aAdd(aAlter,"NJ_VLVEN04")
	aAdd(aAlter,"NJ_VLREC04")
	aAdd(aAlter,"NJ_TXDEPR4")	
	aAdd(aAlter,"NJ_VRDACM4")
	aAdd(aAlter,"NJ_VLREC05")
	aAdd(aAlter,"NJ_VLVEN05")	
	aAdd(aAlter,"NJ_TXDEPR5")	
	aAdd(aAlter,"NJ_VRDACM5")

	If SNJ->(ColumnPos("NJ_CCONTAB")) > 0
		aAdd(aAlter,"NJ_CCONTAB")
	Endif
	If SNJ->(ColumnPos("NJ_CUSTBEM")) > 0
		aAdd(aAlter,"NJ_CUSTBEM")
	Endif
	If SNJ->(ColumnPos("NJ_CDEPREC")) > 0
		aAdd(aAlter,"NJ_CDEPREC")
	Endif
	If SNJ->(ColumnPos("NJ_CCUSTO")) > 0
		aAdd(aAlter,"NJ_CCUSTO")
	Endif 
	If SNJ->(ColumnPos("NJ_CCDEPR")) > 0
		aAdd(aAlter,"NJ_CCDEPR")
	Endif 
	If SNJ->(ColumnPos("NJ_CDESP")) > 0
		aAdd(aAlter,"NJ_CDESP") 
	Endif 
	If SNJ->(ColumnPos("NJ_CCORREC")) > 0
		aAdd(aAlter,"NJ_CCORREC")
	Endif
	If SNJ->(ColumnPos("NJ_CCDESP")) > 0
		aAdd(aAlter,"NJ_CCDESP") 
	Endif
	If SNJ->(ColumnPos("NJ_CCCDEP")) > 0
		aAdd(aAlter,"NJ_CCCDEP")
	Endif 
	If SNJ->(ColumnPos("NJ_CCCDES")) > 0
		aAdd(aAlter,"NJ_CCCDES")
	Endif 
	If SNJ->(ColumnPos("NJ_CCCORR")) > 0
		aAdd(aAlter,"NJ_CCCORR")
	Endif 
	If SNJ->(ColumnPos("NJ_SUBCTA")) > 0
		aAdd(aAlter,"NJ_SUBCTA")
	Endif 
	If SNJ->(ColumnPos("NJ_SUBCCON")) > 0
		aAdd(aAlter,"NJ_SUBCCON")
	Endif
	If SNJ->(ColumnPos("NJ_SUBCDEP")) > 0
		aAdd(aAlter,"NJ_SUBCDEP")
	Endif
	If SNJ->(ColumnPos("NJ_SUBCCDE")) > 0
		aAdd(aAlter,"NJ_SUBCCDE")
	Endif
	If SNJ->(ColumnPos("NJ_SUBCDES")) > 0
		aAdd(aAlter,"NJ_SUBCDES")
	Endif
	If SNJ->(ColumnPos("NJ_SUBCCOR")) > 0
		aAdd(aAlter,"NJ_SUBCCOR")
	Endif
	If SNJ->(ColumnPos("NJ_CLVL")) > 0
		aAdd(aAlter,"NJ_CLVL")
	Endif
	If SNJ->(ColumnPos("NJ_CLVLCON")) > 0
		aAdd(aAlter,"NJ_CLVLCON")
	Endif
	If SNJ->(ColumnPos("NJ_CLVLDEP")) > 0
		aAdd(aAlter,"NJ_CLVLDEP")
	Endif
	If SNJ->(ColumnPos("NJ_CLVLCDE")) > 0
		aAdd(aAlter,"NJ_CLVLCDE")
	Endif
	If SNJ->(ColumnPos("NJ_CLVLDES")) > 0
		aAdd(aAlter,"NJ_CLVLDES")
	Endif
	If SNJ->(ColumnPos("NJ_CLVLCOR")) > 0
		aAdd(aAlter,"NJ_CLVLCOR")
	Endif
	If SNJ->(ColumnPos("NJ_TPAJUST")) > 0
		aAdd(aAlter,"NJ_TPAJUST")
	Endif
	If SNJ->(ColumnPos("NJ_CPERREV")) > 0
		aAdd(aAlter,"NJ_CPERREV")
	Endif
	If SNJ->(ColumnPos("NJ_CRECDES")) > 0
		aAdd(aAlter,"NJ_CRECDES")
	Endif
	If SNJ->(ColumnPos("NJ_VLRIMPT")) > 0
		aAdd(aAlter,"NJ_VLRIMPT")
	Endif
	If SNJ->(ColumnPos("NJ_DTAVALI")) > 0
		aAdd(aAlter,"NJ_DTAVALI")
	Endif
	
	oGetSNJ	:= 	MsNewGetDados():New(0,0,100,100,nOpcX,;
	cLinhaOk ,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oPanelMed,aHeader,aCols)
	oGetSNJ:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
	
	If ExistBlock("AF380ACOLS")
		aColsAux := ExecBlock("AF380ACOLS",.F.,.F.,{nOpc, oGetSNJ:aHeader, oGetSNJ:aCols})
		If Valtype(aColsAux) == "A"
			oGetSNJ:aCols := aClone(aColsAux)	
		EndIf
	Endif
	
	If !lAutomato
	
		If nOpc == INCLUIR .Or. nOpc == ALTERAR
			Aadd( aButton, {"ATFREPLA"   ,{ || Atf380Repl()}, STR0179, STR0180} ) //"Replicar o conteudo do campo posicionado"###"Replicar"
		EndIf

		oDlg:bInit 		:= EnchoiceBar(oDlg,{||nOpca:=1,If(AFA380TOK(nOpc),oDlg:End(),nOpca:=0)},{||RollBackSX8(),oDlg:End()},,aButton)
		oDlg:lCentered	:= .T.
		oDlg:Activate()
	Else
		If FindFunction("GetParAuto")
			aRetAuto := GetParAuto("ATFA380TestCase")
			If MsGetDAuto( aRetAuto[2], /*uLinhaOk*/, /*uTudoOk*/, /*aEnchAuto*/, nOpc, /*lClear*/)
				oGetSNJ:aCols 	:= aCols
				If AFA380TOK(nOpc)
					nOpcA := 1 
				EndIf
	         EndIf
        EndIf
	EndIf
			
EndIf

If nOpcA == 1 .And. nOpc != VISUALIZAR
	MsgRun( STR0075,, {||	lRet := Af380GrvWz(oGetSNJ ,lEfetiva, aRecnoSN3, nOpc,aRetPer) } )//"Realizando IOA dos bens Selecionados..."
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf380GrvWzบAutor  ณ Evaldo V. Batista  บ Data ณ  10/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava as Informacoes do Wizard                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Af380GrvWz( oGetD, lEfetiva, aRecNo , nOpc, aRet)
 
Local nPosValor := aScan( oGetD:aHeader, {|x| Upper( AllTrim( x[2] ) ) == "NJ_VLREC01" } )
Local nPosTaxa	:= aScan( oGetD:aHeader, {|x| Upper( AllTrim( x[2] ) ) == "NJ_VLTAX01" } )
Local nPosVlVend:= aScan( oGetD:aHeader, {|x| Upper( AllTrim( x[2] ) ) == "NJ_VLVEN01" } )
Local nPosTpDepr:= aScan( oGetD:aHeader, {|x| Upper( AllTrim( x[2] ) ) == "NJ_TPDEPR"  } )
   
Local lRet		:= .T.
Local nInc		:= 0
Local nRecNo	:= 0 
Local lTpDepr	:=.F.  
Local lVldLin   := .F.
Local lPeVldlin := ExistBlock("AF380VLIN") 	
  
lTpDepr   := SNJ->(FieldPos("NJ_TPDEPR")) > 0 .And. nPosTpDepr > 0

If nOpc <> EXCLUIR
	For nInc := 1 To Len( oGetD:aCols )
		nRecNo := aRecNo[nInc]
		If !oGetD:aCols[nInc,Len(oGetD:aCols[nInc])]
	
			lVldLin := .T.  //passei pela validacao no minino uma vez
			// Valida Valor 
			If nPosValor > 0 .And. oGetD:aCols[nInc,nPosValor]<=0 
				Help(" ",1,"OBRIGAT1",,STR0141+RetTitle(oGetD:aHeader[nPosValor,2]),4)  // "Faltou informar  o Campo : "
				lRet := .F.
				Exit
			EndIf
			
			If nPosVlVend > 0 .And. nPosTaxa > 0
				//Premissa Help: Quando o valor de venda for maior ou igual ao valor de aquisi็ใo, a taxa de deprecia็ใo pode ser igual a zero.
				//se o valor de venda for menor que o valor a taxa nao pode ser zero
				If oGetD:aCols[nInc,nPosVlVend] < oGetD:aCols[nInc,nPosValor]  .And. oGetD:aCols[nInc,nPosTaxa]<=0
					Help(" ",1,"OBRIGAT1",,STR0141+RetTitle(oGetD:aHeader[nPosTaxa,2]),4)  // "Faltou informar  o Campo : "
					lRet := .F.
					Exit
				EndIf
			EndIf
					
			If lTpDepr .And. nPosTpDepr > 0 .And. nPosTaxa > 0 
				If oGetD:aCols[nInc,nPosTpDepr] $ "1|7|8|9"  //linear / linear com valor maximo de depreciacao 
					// Valida Taxa
					If  oGetD:aCols[nInc,nPosTaxa] <= 0
						Help(" ",1,"OBRIGAT1",,STR0141+RetTitle(oGetD:aHeader[nPosTaxa,2]),4)  //"Faltou informar  o Campo : "
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
	
			//ponto de entrada para validar linha
			If lPeVldlin
				lRet := ExecBlock( "AF380VLIN", .F., .F.,{oGetD:aHeader,oGetD:aCols,nInc,nOpc,lEfetiva } )
				If !lRet
					Exit
				EndIf
			EndIf
		
		EndIf
	Next
Else
	lVldLin := .T. //nao precisa validar linha na exclusao portanto seta como .T.
EndIf
If lVldLin .And. lRet // se passou pela validacao da linha 
	If nOPC == EXPORTAR
		MsgRun( STR0076, STR0077 , {|| lRet := IOAExpCSV(Alltrim(aRet[2])+Alltrim(aRet[1]), SNI->NI_PROC ) } )//"Processando Exporta็ใo"##"Processando ..."
 	Else
    	MsgRun( STR0032, STR0033, {|| lRet := af380Proc(oGetD , aRecNo, lEfetiva, nOpc ) } )		
 	EndIf
Else
	If !lRet
		Help(" ",1,"ERR_VLD",,STR0142,4)  //"Erro na validacao da grade do valor recuperavel. Verifique!"
	EndIf
	If !lVldLin
		Help(" ",1,"GRD_VAZIA",,STR0143,4)  //"Grade vazia  -  valor recuperavel. Verifique!"
	EndIf
	lRet := .F. 
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf250Proc บAutor  ณ Acacio Egas        บ Data ณ  29/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Iniciando Processamento para Mult Thread                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA380                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function af380Proc(oGetD ,aRecNo, lEfetiva , nOpc)
Local cCodigo			:= M->NI_PROC
Local lRet				:= .T.
Local nNumProc			:= SuperGetMv("MV_ATFMTHR", .F., 1 )
Local cFilde			:= cFilAnt
Local cFilAte			:= cFilAnt
Local cCalcDep			:= SuperGetMv("MV_CALCDEP",.F.,"") 
Local lContabiliza		:= .F.        
Local cTipoGer			:= SuperGetMv( "MV_ATFTIOA", .F., "12" )
Local lOnOff			:= .T.
Local cTypes12			:= IIF(lIsRussia,"/" + AtfNValMod({2}, "/"),"") // CAZARINI - 07/04/2017 - If is Russia, add new valuations models - recoverable model
Local cPadraoImp        := "894"
Private dUltDepr		:= GetMV("MV_ULTDEPR")+1

lOnOff   := MV_PAR03 == 1

If ALLtrim(cTipoGer) $ ('12' + cTypes12)
	cPadraoAQ := "80A"
	cPadraoBai := "81A"
Else
	cPadraoAQ := "801"
	cPadraoBai := "810"
EndIf

If lEfetiva .And. ( VerPadrao(cPadraoAQ) .Or. VerPadrao(cPadraoBai) .or. VerPadrao(cPadraoImp) ) .And. lOnOff
	lContabiliza	:= .T.
EndIf

If lEfetiva
	If (cCalcDep == "0" .and. !(dDataBase >= dUltDepr .and. dDataBase <= LastDay(dUltDepr))) .OR.;
		(cCalcDep == "1" .and. !(Year(dDataBase) == Year(dUltDepr)))
		Help("  ",1,"AF010CVDT",,STR0046,1,0) //"Periodo para efetiva็ใo invalido."##
		lRet := .F.
	Endif
EndIf

If lRet
	lRet := IniTread(oGetD,cCodigo,aRecNo,lEfetiva,nNumProc,cFilDe,cFilAte,nOpc)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava o status do processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	lSeek := SNI->(MsSeek(xFilial("SNI") + cCodigo))
	If nOpc==EXCLUIR
		RecLock("SNI",.F.,.T.)
		DbDelete()
		MsUnlock()
	Else
		RecLock("SNI",!lSeek)
		SNI->NI_FILIAL 	:= xFilial("SNI")
		SNI->NI_PROC 	:= M->NI_PROC
		SNI->NI_DTEMIS	:= M->NI_DTEMIS
		SNI->NI_STATUS 	:= If(lEfetiva,"2","1")
		SNI->NI_PARAM	:= M->NI_PARAM
		If Empty(SNI->NI_ROTINA)
			SNI->NI_ROTINA	:= IIF(nOpc==IMPORTAR, '2','1')
		EndIf
		If lEfetiva
			SNI->NI_DTIOA	:= dDatabase
			If lContabiliza .And. lOnOff .and. VerPadrao(cPadraoImp)
				SNI->NI_LA := "S"
			EndIf
		EndIF
		
		MsUnlock()
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIniTread  บAutor  ณ Acacio Egas        บ Data ณ  05/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o preparo e o controle do processamento multi threadบฑฑ
ฑฑบ          ณda rotina                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA380                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IniTread(oGetD,cCodigo,aRecNo,lEfetiva,nNumProc,cFilDe,cFilAte,nOpc)
Local lRet   		   			:= .T.
Local nX	 					:= 0
Local nCpoIt				:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_ITEM"		})
Local nCpoBem			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_BEM"			})
Local nCpoItBem			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_ITBEM"		})
Local nCpoTipo			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_TIPO"		})

Local nCpoVlr1			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLREC01"	})
Local nCpoTaxa1			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLTAX01"	})
Local nCpoDpAc1   		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLACM01"	})
Local nCpoVend1		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLVEN01"	})
Local nCpoOri1	   		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLORI01"	})

Local nCpoTpDepr 		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_TPDEPR"		})
Local nCpoPerDepr		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_PERDEPR"	})
Local nCpoVlSalv1		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLSALV1"	})
Local nCpoProdAno		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_PRODANO"	})
Local nCpoProdMes		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_PRODMES"	})
Local nCpoVmxDepr	:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VMXDEPR"	})
Local nCpoProdAcm	:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_PRODACM"	})
Local nCpoCodind		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_CODIND"		})

Local nCpoVlr2			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLREC02"	})
Local nCpoTaxa2			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_TXDEPR2"	})
Local nCpoDpAc2   		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VRDACM2"	})
Local nCpoVend2		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLVEN02"	})
Local nCpoOri2			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VORIG2"	})

Local nCpoVlr3			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLREC03"	})
Local nCpoTaxa3			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_TXDEPR3"	})
Local nCpoDpAc3   		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VRDACM3"	})
Local nCpoVend3		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLVEN03"	})
Local nCpoOri3			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VORIG3"	})

Local nCpoVlr4			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLREC04"	})
Local nCpoTaxa4			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_TXDEPR4"	})
Local nCpoDpAc4		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VRDACM4"	})
Local nCpoVend4   		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLVEN04"	})
Local nCpoOri4			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VORIG4"	})

Local nCpoVlr5			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLREC05"	})
Local nCpoTaxa5			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_TXDEPR5"	})
Local nCpoDpAc5		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VRDACM5"	})
Local nCpoVend5   		:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLVEN05"	})
Local nCpoOri5			:= aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VORIG5"	})

Local nCpoCctab :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CCONTAB" })
Local nCpoCustb :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CUSTBEM" })
Local nCpoCdepr :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CDEPREC" })
Local nCpoCcust :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CCUSTO" })
Local nCpoCcdr  :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CCDEPR" })
Local nCpoCdesp :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CDESP" })  
Local nCpoCorrec :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CCORREC" })
Local nCpoCcdes  :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CCDESP" }) 
Local nCpoCccde  :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CCCDEP" }) 
Local nCpoCccds  :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CCCDES" }) 
Local nCpoCccor  :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CCCORR" }) 
Local nCpoSbcta  :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_SUBCTA" }) 
Local nCpoSbCon  :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_SUBCCON" })
Local nCpoSbcdep :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_SUBCDEP" })
Local nCpoSbccde :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_SUBCCDE" })
Local nCpoSbcdes :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_SUBCDES" })
Local nCpoSbccor :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_SUBCCOR" })
Local nCpoClvl 	 :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CLVL" })   
Local nCpoClvlco :=	aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CLVLCON" })
Local nCpoClvdep := aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CLVLDEP" })
Local nCpoClvcde := aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CLVLCDE" })
Local nCpoClvdes := aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CLVLDES" })
Local nCpoClvcor := aScan(oGetD:aHeader,{|x| alltrim(x[2])=="NJ_CLVLCOR" })
Local nCpoTpAjus  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_TPAJUST"})
Local nCpoCperre  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_CPERREV"})
Local nCpoCrecde  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_CRECDES"})
Local nCpoPerAc1  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_PERACM1"})
Local nCpoRevAc1  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_REVACM1"})
Local nCpoPerAc2  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_PERACM2"})
Local nCpoRevAc2  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_REVACM2"})
Local nCpoPerAc3  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_PERACM3"})
Local nCpoRevAc3  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_REVACM3"})
Local nCpoPerAc4  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_PERACM4"})
Local nCpoRevAc4  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_REVACM4"})
Local nCpoPerAc5  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_PERACM5"})
Local nCpoRevAc5  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_REVACM5"})
Local nCpoTstImp  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_VLRIMPT"})
Local nCpoDtAval  := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_DTAVALI"})

// Posi็ใo a aHeader do campo de tipo de saldo dos movimentos da redu็ใo de valor recuperแvel
Local nCpoTpSal	:= 0
Local aProcs 	:= {}
Local cDirSem   := "\Semaforo\"
Local cRaizNome	:= 'ATFA380Proc'
Local cNomeArq	:= ""
Local cMarca	:= ""
Local aArea		:= GetArea()
Local nTotalReg	:= 0 // Total de Registros
Local nRegAProc	:= 0 // Registros a processar
Local nRegJProc	:= 0 // Total de registros jแ processados
Local cQuery	:= ""
Local cTabMult	:= AF380NextAlias() // Tabela para o processamento multi thread
Local aStruSQL	:= {}
Local lTpDepr:= .F.
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local cTableName:= ""
/*
 * Verifica se trata o tipo de saldo para utiliza็ใo da redu็ใo de valor recuperแvel com o tipo 10 - Gerencial
 */
DbSelectArea("SNJ")
lTpSaldo	:= .T.
lTpDepr		:= .T.
If lTpSaldo
	nCpoTpSal := aScan(oGetD:aHeader, {|x| alltrim(x[2])=="NJ_TPSALDO"	})
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria a pasta do semaforo caso nใo existaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !ExistDir(cDirSem)
	MontaDir(cDirSem)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados Bแsicos do Bemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aStruSQL,{"NJ_FILIAL"	,"C",TAMSX3("NJ_FILIAL")[1]		,00})
AADD(aStruSQL,{"NJ_OK" 	   	,"C",TAMSX3("N3_OK")[1]			,00})
AADD(aStruSQL,{"NJ_ITEM"   	,"C",TAMSX3("NJ_ITEM")[1]		,00})
AADD(aStruSQL,{"NJ_BEM"   	,"C",TAMSX3("NJ_BEM")[1]		,00})
AADD(aStruSQL,{"NJ_ITBEM"	,"C",TAMSX3("NJ_ITBEM")[1]		,00})
AADD(aStruSQL,{"NJ_VLREC01"	,"N",TAMSX3("NJ_VLREC01")[1]	,TAMSX3("NJ_VLREC01")[2]	})
AADD(aStruSQL,{"NJ_VLTAX01"	,"N",TAMSX3("NJ_VLTAX01")[1]	,TAMSX3("NJ_VLTAX01")[2]	})
AADD(aStruSQL,{"NJ_TIPO"  	,"C",TAMSX3("NJ_TIPO")[1]		,TAMSX3("NJ_TIPO")[2]		})
AADD(aStruSQL,{"NJ_VLACM01"	,"N",TAMSX3("NJ_VLACM01")[1]	,TAMSX3("NJ_VLACM01")[2]	})
AADD(aStruSQL,{"NJ_VLVEN01"	,"N",TAMSX3("NJ_VLVEN01")[1]	,TAMSX3("NJ_VLVEN01")[2]	})
AADD(aStruSQL,{"NJ_VLORI01"	,"N",TAMSX3("NJ_VLORI01")[1]	,TAMSX3("NJ_VLORI01")[2]	})
If lTpSaldo
	AADD(aStruSQL,{"NJ_TPSALDO"	,"C",TAMSX3("NJ_TPSALDO")[1]	,TAMSX3("NJ_TPSALDO")[2]	})
EndIf 
If SNJ->(ColumnPos("NJ_TPAJUST")) > 0
	AADD(aStruSQL,{"NJ_TPAJUST"  ,"C",TAMSX3("NJ_TPAJUST")[1]		,TAMSX3("NJ_TPAJUST")[2]		})
Endif
If SNJ->(ColumnPos("NJ_CPERREV")) > 0
	AADD(aStruSQL,{"NJ_CPERREV"  ,"C",TAMSX3("NJ_CPERREV")[1]		,TAMSX3("NJ_CPERREV")[2]		})
Endif
If SNJ->(ColumnPos("NJ_CRECDES")) > 0
	AADD(aStruSQL,{"NJ_CRECDES"  ,"C",TAMSX3("NJ_CRECDES")[1]		,TAMSX3("NJ_CRECDES")[2]		})
Endif
If SNJ->(ColumnPos("NJ_PERACM1")) > 0
	AADD(aStruSQL,{"NJ_PERACM1"  ,"N",TAMSX3("NJ_PERACM1")[1]		,TAMSX3("NJ_PERACM1")[2]		})
EndIf
If	SNJ->(ColumnPos("NJ_PERACM2")) > 0
	AADD(aStruSQL,{"NJ_PERACM2"  ,"N",TAMSX3("NJ_PERACM2")[1]		,TAMSX3("NJ_PERACM2")[2]		})
EndIf
If SNJ->(ColumnPos("NJ_PERACM3")) > 0
	AADD(aStruSQL,{"NJ_PERACM3"  ,"N",TAMSX3("NJ_PERACM3")[1]		,TAMSX3("NJ_PERACM3")[2]		})
EndIf
If SNJ->(ColumnPos("NJ_PERACM4")) > 0
	AADD(aStruSQL,{"NJ_PERACM4"  ,"N",TAMSX3("NJ_PERACM4")[1]		,TAMSX3("NJ_PERACM4")[2]		})
EndIf
If SNJ->(ColumnPos("NJ_PERACM5")) > 0
	AADD(aStruSQL,{"NJ_PERACM5"  ,"N",TAMSX3("NJ_PERACM5")[1]		,TAMSX3("NJ_PERACM5")[2]		})
Endif
If SNJ->(ColumnPos("NJ_REVACM1")) > 0
	AADD(aStruSQL,{"NJ_REVACM1"  ,"N",TAMSX3("NJ_REVACM1")[1]		,TAMSX3("NJ_REVACM1")[2]		})
EndIf
If SNJ->(ColumnPos("NJ_REVACM2")) > 0
	AADD(aStruSQL,{"NJ_REVACM2"  ,"N",TAMSX3("NJ_REVACM2")[1]		,TAMSX3("NJ_REVACM2")[2]		})
EndIf
If SNJ->(ColumnPos("NJ_REVACM3")) > 0
	AADD(aStruSQL,{"NJ_REVACM3"  ,"N",TAMSX3("NJ_REVACM3")[1]		,TAMSX3("NJ_REVACM3")[2]		})
EndIf
If SNJ->(ColumnPos("NJ_REVACM4")) > 0	
	AADD(aStruSQL,{"NJ_REVACM4"  ,"N",TAMSX3("NJ_REVACM4")[1]		,TAMSX3("NJ_REVACM4")[2]		})
EndIf
If SNJ->(ColumnPos("NJ_REVACM5")) > 0	
	AADD(aStruSQL,{"NJ_REVACM5"  ,"N",TAMSX3("NJ_REVACM5")[1]		,TAMSX3("NJ_REVACM5")[2]		})
Endif
If SNJ->(ColumnPos("NJ_VLRIMPT")) > 0	
	AADD(aStruSQL,{"NJ_VLRIMPT"  ,"N",TAMSX3("NJ_VLRIMPT")[1]		,TAMSX3("NJ_VLRIMPT")[2]		})
Endif
If SNJ->(ColumnPos("NJ_DTAVALI")) > 0	
	AADD(aStruSQL,{"NJ_DTAVALI"  ,"D",TAMSX3("NJ_DTAVALI")[1]		,TAMSX3("NJ_DTAVALI")[2]		})
Endif
If lTpDepr
		AADD(aStruSQL,{"NJ_TPDEPR"  ,"C",TAMSX3("NJ_TPDEPR")[1]		,TAMSX3("NJ_TPDEPR")[2]		})
		AADD(aStruSQL,{"NJ_PERDEPR" ,"N",TAMSX3("NJ_PERDEPR")[1]	,TAMSX3("NJ_PERDEPR")[2]		})
		AADD(aStruSQL,{"NJ_VLSALV1" ,"N",TAMSX3("NJ_VLSALV1")[1]	,TAMSX3("NJ_VLSALV1")[2]		})
		AADD(aStruSQL,{"NJ_PRODANO" ,"N",TAMSX3("NJ_PRODANO")[1]	,TAMSX3("NJ_PRODANO")[2]		})
		AADD(aStruSQL,{"NJ_PRODMES" ,"N",TAMSX3("NJ_PRODMES")[1]	,TAMSX3("NJ_PRODMES")[2]		})
		AADD(aStruSQL,{"NJ_VMXDEPR" ,"N",TAMSX3("NJ_VMXDEPR")[1]	,TAMSX3("NJ_VMXDEPR")[2]		})
		AADD(aStruSQL,{"NJ_PRODACM" ,"N",TAMSX3("NJ_PRODACM")[1]	,TAMSX3("NJ_PRODACM")[2]		})
		AADD(aStruSQL,{"NJ_CODIND"  ,"C",TAMSX3("NJ_CODIND")[1]		,TAMSX3("NJ_CODIND")[2]		})
		
		AADD(aStruSQL,{"NJ_VORIG2"	,"N",TAMSX3("NJ_VORIG2")[1]		,TAMSX3("NJ_VORIG2")[2]	})
		AADD(aStruSQL,{"NJ_VLVEN02"	,"N",TAMSX3("NJ_VLVEN02")[1]	,TAMSX3("NJ_VLVEN02")[2]	})
		AADD(aStruSQL,{"NJ_VLREC02"	,"N",TAMSX3("NJ_VLREC02")[1]	,TAMSX3("NJ_VLREC02")[2]	})
		AADD(aStruSQL,{"NJ_TXDEPR2","N",TAMSX3("NJ_TXDEPR2")[1]		,TAMSX3("NJ_TXDEPR2")[2]})
		AADD(aStruSQL,{"NJ_VRDACM2"	,"N",TAMSX3("NJ_VRDACM2")[1]	,TAMSX3("NJ_VRDACM2")[2]	})
		
		AADD(aStruSQL,{"NJ_VORIG3"	,"N",TAMSX3("NJ_VORIG3")[1]		,TAMSX3("NJ_VORIG3")[2]	})
		AADD(aStruSQL,{"NJ_VLVEN03"	,"N",TAMSX3("NJ_VLVEN03")[1]	,TAMSX3("NJ_VLVEN03")[2]	})
		AADD(aStruSQL,{"NJ_VLREC03"	,"N",TAMSX3("NJ_VLREC03")[1]	,TAMSX3("NJ_VLREC03")[2]	})
		AADD(aStruSQL,{"NJ_TXDEPR3"	,"N",TAMSX3("NJ_TXDEPR3")[1]	,TAMSX3("NJ_TXDEPR3")[2]})
		AADD(aStruSQL,{"NJ_VRDACM3"	,"N",TAMSX3("NJ_VRDACM3")[1]	,TAMSX3("NJ_VRDACM3")[2]	})
		
		AADD(aStruSQL,{"NJ_VORIG4"	,"N",TAMSX3("NJ_VORIG4")[1]		,TAMSX3("NJ_VORIG4")[2]	})
		AADD(aStruSQL,{"NJ_VLVEN04"	,"N",TAMSX3("NJ_VLVEN04")[1]	,TAMSX3("NJ_VLVEN04")[2]	})
		AADD(aStruSQL,{"NJ_VLREC04"	,"N",TAMSX3("NJ_VLREC04")[1]	,TAMSX3("NJ_VLREC04")[2]	})
		AADD(aStruSQL,{"NJ_TXDEPR4"	,"N",TAMSX3("NJ_TXDEPR4")[1]	,TAMSX3("NJ_TXDEPR4")[2]})
		AADD(aStruSQL,{"NJ_VRDACM4"	,"N",TAMSX3("NJ_VRDACM4")[1]	,TAMSX3("NJ_VRDACM4")[2]	})
		
		AADD(aStruSQL,{"NJ_VORIG5"	,"N",TAMSX3("NJ_VORIG5")[1]		,TAMSX3("NJ_VORIG5")[2]	})
		AADD(aStruSQL,{"NJ_VLVEN05"	,"N",TAMSX3("NJ_VLVEN05")[1]	,TAMSX3("NJ_VLVEN05")[2]	})
		AADD(aStruSQL,{"NJ_VLREC05"	,"N",TAMSX3("NJ_VLREC05")[1]	,TAMSX3("NJ_VLREC05")[2]	})
		AADD(aStruSQL,{"NJ_TXDEPR5"	,"N",TAMSX3("NJ_TXDEPR5")[1]	,TAMSX3("NJ_TXDEPR5")[2]	})
		AADD(aStruSQL,{"NJ_VRDACM5"	,"N",TAMSX3("NJ_VRDACM5")[1]	,TAMSX3("NJ_VRDACM5")[2]	})

		If SNJ->(ColumnPos("NJ_CCONTAB")) > 0
			AADD(aStruSQL,{"NJ_CCONTAB"  ,"C",TAMSX3("NJ_CCONTAB")[1]	,TAMSX3("NJ_CCONTAB")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_CUSTBEM")) > 0
			AADD(aStruSQL,{"NJ_CUSTBEM"  ,"C",TAMSX3("NJ_CUSTBEM")[1]	,TAMSX3("NJ_CUSTBEM")[2]	})
		Endif
		If SNJ->(ColumnPos("NJ_CDEPREC")) > 0
			AADD(aStruSQL,{"NJ_CDEPREC"  ,"C",TAMSX3("NJ_CDEPREC")[1]	,TAMSX3("NJ_CDEPREC")[2]	})
		Endif	
		If SNJ->(ColumnPos("NJ_CCUSTO")) > 0
			AADD(aStruSQL,{"NJ_CCUSTO"   ,"C",TAMSX3("NJ_CCUSTO")[1]	,TAMSX3("NJ_CCUSTO")[2]	})	
		Endif	
		If SNJ->(ColumnPos("NJ_CCDEPR")) > 0
			AADD(aStruSQL,{"NJ_CCDEPR"   ,"C",TAMSX3("NJ_CCDEPR")[1]	,TAMSX3("NJ_CCDEPR")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_CDESP")) > 0
			AADD(aStruSQL,{"NJ_CDESP"    ,"C",TAMSX3("NJ_CDESP")[1]		,TAMSX3("NJ_CDESP")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_CCORREC")) > 0
			AADD(aStruSQL,{"NJ_CCORREC"  ,"C",TAMSX3("NJ_CCORREC")[1]	,TAMSX3("NJ_CCORREC")[2]	})	
		Endif	
		If SNJ->(ColumnPos("NJ_CCDESP")) > 0
			AADD(aStruSQL,{"NJ_CCDESP"   ,"C",TAMSX3("NJ_CCDESP")[1]	,TAMSX3("NJ_CCDESP")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_CCCDEP")) > 0
			AADD(aStruSQL,{"NJ_CCCDEP"   ,"C",TAMSX3("NJ_CCCDEP")[1]	,TAMSX3("NJ_CCCDEP")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_CCCDES")) > 0
			AADD(aStruSQL,{"NJ_CCCDES"   ,"C",TAMSX3("NJ_CCCDES")[1]	,TAMSX3("NJ_CCCDES")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_CCCORR")) > 0
			AADD(aStruSQL,{"NJ_CCCORR"   ,"C",TAMSX3("NJ_CCCORR")[1]	,TAMSX3("NJ_CCCORR")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_SUBCTA")) > 0
			AADD(aStruSQL,{"NJ_SUBCTA"   ,"C",TAMSX3("NJ_SUBCTA")[1]	,TAMSX3("NJ_SUBCTA")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_SUBCCON")) > 0
			AADD(aStruSQL,{"NJ_SUBCCON"  ,"C",TAMSX3("NJ_SUBCCON")[1]	,TAMSX3("NJ_SUBCCON")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_SUBCDEP")) > 0
			AADD(aStruSQL,{"NJ_SUBCDEP"  ,"C",TAMSX3("NJ_SUBCDEP")[1]	,TAMSX3("NJ_SUBCDEP")[2]	})
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCDE")) > 0
			AADD(aStruSQL,{"NJ_SUBCCDE"  ,"C",TAMSX3("NJ_SUBCCDE")[1]	,TAMSX3("NJ_SUBCCDE")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_SUBCDES")) > 0
			AADD(aStruSQL,{"NJ_SUBCDES"  ,"C",TAMSX3("NJ_SUBCDES")[1]	,TAMSX3("NJ_SUBCDES")[2]	})
		Endif	
		If SNJ->(ColumnPos("NJ_SUBCCOR")) > 0
			AADD(aStruSQL,{"NJ_SUBCCOR"  ,"C",TAMSX3("NJ_SUBCCOR")[1]	,TAMSX3("NJ_SUBCCOR")[2]	})
		Endif	
		If SNJ->(ColumnPos("NJ_CLVL")) > 0
			AADD(aStruSQL,{"NJ_CLVL"     ,"C",TAMSX3("NJ_CLVL")[1]		,TAMSX3("NJ_CLVL")[2]	})
		Endif	
		If SNJ->(ColumnPos("NJ_CLVLCON")) > 0
			AADD(aStruSQL,{"NJ_CLVLCON"  ,"C",TAMSX3("NJ_CLVLCON")[1]	,TAMSX3("NJ_CLVLCON")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_CLVLDEP")) > 0
			AADD(aStruSQL,{"NJ_CLVLDEP"  ,"C",TAMSX3("NJ_CLVLDEP")[1]	,TAMSX3("NJ_CLVLDEP")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_CLVLCDE")) > 0
			AADD(aStruSQL,{"NJ_CLVLCDE"  ,"C",TAMSX3("NJ_CLVLCDE")[1]	,TAMSX3("NJ_CLVLCDE")[2]	})
		Endif
		If SNJ->(ColumnPos("NJ_CLVLDES")) > 0
			AADD(aStruSQL,{"NJ_CLVLDES"  ,"C",TAMSX3("NJ_CLVLDES")[1]	,TAMSX3("NJ_CLVLDES")[2]	})
		Endif		
		If SNJ->(ColumnPos("NJ_CLVLCOR")) > 0
			AADD(aStruSQL,{"NJ_CLVLCOR"  ,"C",TAMSX3("NJ_CLVLCOR")[1]	,TAMSX3("NJ_CLVLCOR")[2]	})
		Endif	
Endif
AADD(aStruSQL,{"N3RECNO"  	,"N",08,00})
AADD(aStruSQL,{"RECDEL"  	,"C",01,00})

If _oATFA3801 <> Nil
	_oATFA3801:Delete()
	_oATFA3801 := Nil
Endif

_oATFA3801 := FWTemporaryTable():New(cTabMult)  
_oATFA3801:SetFields(aStruSQL) 
_oATFA3801:AddIndex("1", {"N3RECNO"})
_oATFA3801:Create()  
cTableName := _oATFA3801:GetRealName()

//*********************
// Grava Acols no TRB *
//*********************
DbSelectArea("SNJ")
DbSetOrder(1)
If Len(aRecno) > 0
	For nX := 1 to Len(oGetD:aCols)
		
		RecLock(cTabMult,.T.)
	
		(cTabMult)->NJ_FILIAL	:= xFilial("SNJ")  
		(cTabMult)->NJ_ITEM		:= oGetD:aCols[nX,nCpoIt]
		(cTabMult)->NJ_BEM		:= oGetD:aCols[nX,nCpoBem]
		(cTabMult)->NJ_ITBEM 	:= oGetD:aCols[nX,nCpoItBem]
		(cTabMult)->NJ_VLREC01	:= oGetD:aCols[nX,nCpoVlr1]
		(cTabMult)->NJ_VLTAX01	:= oGetD:aCols[nX,nCpoTaxa1]
		(cTabMult)->NJ_TIPO		:= oGetD:aCols[nX,nCpoTipo]		
		(cTabMult)->NJ_VLACM01	:= oGetD:aCols[nX,nCpoDpAc1]
		(cTabMult)->NJ_VLVEN01	:= oGetD:aCols[nX,nCpoVend1]
		(cTabMult)->NJ_VLORI01	:= oGetD:aCols[nX,nCpoOri1]

		If SNJ->(ColumnPos("NJ_TPAJUST")) > 0
			(cTabMult)->NJ_TPAJUST	:= oGetD:aCols[nX,nCpoTpAjus]
		EndIf
		If SNJ->(ColumnPos("NJ_CPERREV")) > 0
			(cTabMult)->NJ_CPERREV	:= oGetD:aCols[nX,nCpoCperre]
		EndIf
		If SNJ->(ColumnPos("NJ_CRECDES")) > 0
			(cTabMult)->NJ_CRECDES	:= oGetD:aCols[nX,nCpoCrecde]
		EndIf		
		If SNJ->(ColumnPos("NJ_PERACM1")) > 0
			(cTabMult)->NJ_PERACM1	:= oGetD:aCols[nX,nCpoPerAc1]
		EndIf
		If SNJ->(ColumnPos("NJ_PERACM2")) > 0
			(cTabMult)->NJ_PERACM2	:= oGetD:aCols[nX,nCpoPerAc2]
		EndIf
		If SNJ->(ColumnPos("NJ_PERACM3")) > 0
			(cTabMult)->NJ_PERACM3	:= oGetD:aCols[nX,nCpoPerAc3]
		EndIf
		If SNJ->(ColumnPos("NJ_PERACM4")) > 0
			(cTabMult)->NJ_PERACM4	:= oGetD:aCols[nX,nCpoPerAc4]
		EndIf
		If SNJ->(ColumnPos("NJ_PERACM5")) > 0
			(cTabMult)->NJ_PERACM5	:= oGetD:aCols[nX,nCpoPerAc5]
		EndIf
		If SNJ->(ColumnPos("NJ_REVACM1")) > 0
			(cTabMult)->NJ_REVACM1	:= oGetD:aCols[nX,nCpoRevAc1]
		EndIf
		If SNJ->(ColumnPos("NJ_REVACM2")) > 0
			(cTabMult)->NJ_REVACM2	:= oGetD:aCols[nX,nCpoRevAc2]
		EndIf
		If SNJ->(ColumnPos("NJ_REVACM3")) > 0
			(cTabMult)->NJ_REVACM3	:= oGetD:aCols[nX,nCpoRevAc3]
		EndIf
		If SNJ->(ColumnPos("NJ_REVACM4")) > 0
			(cTabMult)->NJ_REVACM4	:= oGetD:aCols[nX,nCpoRevAc4]
		EndIf			
		If SNJ->(ColumnPos("NJ_REVACM5")) > 0
			(cTabMult)->NJ_REVACM5	:= oGetD:aCols[nX,nCpoRevAc5]			
		EndIf
		If SNJ->(ColumnPos("NJ_VLRIMPT")) > 0
			(cTabMult)->NJ_VLRIMPT	:= oGetD:aCols[nX,nCpoTstImp]			
		EndIf
		If SNJ->(ColumnPos("NJ_DTAVALI")) > 0
			(cTabMult)->NJ_DTAVALI	:= Iif(ValType(oGetD:aCols[nX,nCpoDtAval])<>"D",Stod(oGetD:aCols[nX,nCpoDtAval]), oGetD:aCols[nX,nCpoDtAval])
		EndIf
		If lTpSaldo
			(cTabMult)->NJ_TPSALDO	:= oGetD:aCols[nX,nCpoTpSal]
		EndIf
		If lTpDepr		
			(cTabMult)->NJ_TPDEPR	:= oGetD:aCols[nX,nCpoTpDepr]
			
			(cTabMult)->NJ_PERDEPR	:= oGetD:aCols[nX,nCpoPerDepr]
			(cTabMult)->NJ_VLSALV1	:= oGetD:aCols[nX,nCpoVlSalv1]
			(cTabMult)->NJ_PRODANO	:= oGetD:aCols[nX,nCpoProdAno]
			(cTabMult)->NJ_PRODMES	:= oGetD:aCols[nX,nCpoProdMes]
			(cTabMult)->NJ_VMXDEPR	:= oGetD:aCols[nX,nCpoVmxDepr]
			(cTabMult)->NJ_PRODACM	:= oGetD:aCols[nX,nCpoProdAcm]
			(cTabMult)->NJ_CODIND	:= oGetD:aCols[nX,nCpoCodind]
	
			(cTabMult)->NJ_VORIG2	:= oGetD:aCols[nX,nCpoOri2]
			(cTabMult)->NJ_VLVEN02	:= oGetD:aCols[nX,nCpoVend2]
			(cTabMult)->NJ_VLREC02	:= oGetD:aCols[nX,nCpoVlr2]
			(cTabMult)->NJ_TXDEPR2	:= oGetD:aCols[nX,nCpoTaxa2]
			(cTabMult)->NJ_VRDACM2	:= oGetD:aCols[nX,nCpoDpAc2]
			
			(cTabMult)->NJ_VORIG3	:= oGetD:aCols[nX,nCpoOri3]
			(cTabMult)->NJ_VLVEN03	:= oGetD:aCols[nX,nCpoVend3]
			(cTabMult)->NJ_VLREC03	:= oGetD:aCols[nX,nCpoVlr3]
			(cTabMult)->NJ_TXDEPR3	:= oGetD:aCols[nX,nCpoTaxa3]
			(cTabMult)->NJ_VRDACM3	:= oGetD:aCols[nX,nCpoDpAc3]
	
			(cTabMult)->NJ_VORIG4	:= oGetD:aCols[nX,nCpoOri4]
			(cTabMult)->NJ_VLVEN04	:= oGetD:aCols[nX,nCpoVend4]
			(cTabMult)->NJ_VLREC04	:= oGetD:aCols[nX,nCpoVlr4]
			(cTabMult)->NJ_TXDEPR4	:= oGetD:aCols[nX,nCpoTaxa4]
			(cTabMult)->NJ_VRDACM4	:= oGetD:aCols[nX,nCpoDpAc4]
	
			(cTabMult)->NJ_VORIG5	:= oGetD:aCols[nX,nCpoOri5]
			(cTabMult)->NJ_VLVEN05	:= oGetD:aCols[nX,nCpoVend5]
			(cTabMult)->NJ_VLREC05	:= oGetD:aCols[nX,nCpoVlr5]
			(cTabMult)->NJ_TXDEPR5	:= oGetD:aCols[nX,nCpoTaxa5]
			(cTabMult)->NJ_VRDACM5	:= oGetD:aCols[nX,nCpoDpAc5]

			If SNJ->(ColumnPos("NJ_CCONTAB")) > 0
				(cTabMult)->NJ_CCONTAB	:= oGetD:aCols[nX,nCpoCctab]
			Endif
			If SNJ->(ColumnPos("NJ_CUSTBEM")) > 0
				(cTabMult)->NJ_CUSTBEM	:= oGetD:aCols[nX,nCpoCustb]
			Endif
			If SNJ->(ColumnPos("NJ_CDEPREC")) > 0
				(cTabMult)->NJ_CDEPREC	:= oGetD:aCols[nX,nCpoCdepr]
			Endif
			If SNJ->(ColumnPos("NJ_CCUSTO")) > 0
				(cTabMult)->NJ_CCUSTO 	:= oGetD:aCols[nX,nCpoCcust]
			Endif
			If SNJ->(ColumnPos("NJ_CCDEPR")) > 0
				(cTabMult)->NJ_CCDEPR 	:= oGetD:aCols[nX,nCpoCcdr]
			Endif
			If SNJ->(ColumnPos("NJ_CDESP")) > 0
				(cTabMult)->NJ_CDESP  	:= oGetD:aCols[nX,nCpoCdesp]
			Endif
			If SNJ->(ColumnPos("NJ_CCORREC")) > 0
				(cTabMult)->NJ_CCORREC	:= oGetD:aCols[nX,nCpoCorrec]
			Endif
			If SNJ->(ColumnPos("NJ_CCDESP")) > 0
				(cTabMult)->NJ_CCDESP 	:= oGetD:aCols[nX,nCpoCcdes]
			Endif
			If SNJ->(ColumnPos("NJ_CCCDEP")) > 0
				(cTabMult)->NJ_CCCDEP 	:= oGetD:aCols[nX,nCpoCccde]
			Endif
			If SNJ->(ColumnPos("NJ_CCCDES")) > 0
				(cTabMult)->NJ_CCCDES 	:= oGetD:aCols[nX,nCpoCccds]
			Endif
			If SNJ->(ColumnPos("NJ_CCCORR")) > 0
				(cTabMult)->NJ_CCCORR 	:= oGetD:aCols[nX,nCpoCccor]
			Endif
			If SNJ->(ColumnPos("NJ_SUBCTA")) > 0
				(cTabMult)->NJ_SUBCTA 	:= oGetD:aCols[nX,nCpoSbcta]
			Endif
			If SNJ->(ColumnPos("NJ_SUBCCON")) > 0
				(cTabMult)->NJ_SUBCCON	:= oGetD:aCols[nX,nCpoSbCon]
			Endif
			If SNJ->(ColumnPos("NJ_SUBCDEP")) > 0
				(cTabMult)->NJ_SUBCDEP	:= oGetD:aCols[nX,nCpoSbcdep]
			Endif
			If SNJ->(ColumnPos("NJ_SUBCCDE")) > 0
				(cTabMult)->NJ_SUBCCDE	:= oGetD:aCols[nX,nCpoSbccde]
			Endif
			If SNJ->(ColumnPos("NJ_SUBCDES")) > 0
				(cTabMult)->NJ_SUBCDES	:= oGetD:aCols[nX,nCpoSbcdes]
			Endif
			If SNJ->(ColumnPos("NJ_SUBCCOR")) > 0
				(cTabMult)->NJ_SUBCCOR	:= oGetD:aCols[nX,nCpoSbccor]
			Endif
			If SNJ->(ColumnPos("NJ_CLVL")) > 0
				(cTabMult)->NJ_CLVL   	:= oGetD:aCols[nX,nCpoClvl]
			Endif
			If SNJ->(ColumnPos("NJ_CLVLCON")) > 0
				(cTabMult)->NJ_CLVLCON	:= oGetD:aCols[nX,nCpoClvlco]
			Endif
			If SNJ->(ColumnPos("NJ_CLVLDEP")) > 0
				(cTabMult)->NJ_CLVLDEP	:= oGetD:aCols[nX,nCpoClvdep]
			Endif
			If SNJ->(ColumnPos("NJ_CLVLCDE")) > 0
				(cTabMult)->NJ_CLVLCDE	:= oGetD:aCols[nX,nCpoClvcde]
			Endif
			If SNJ->(ColumnPos("NJ_CLVLDES")) > 0
				(cTabMult)->NJ_CLVLDES	:= oGetD:aCols[nX,nCpoClvdes]
			Endif
			If SNJ->(ColumnPos("NJ_CLVLCOR")) > 0
				(cTabMult)->NJ_CLVLCOR	:= oGetD:aCols[nX,nCpoClvcor]
			Endif

		Endif
		(cTabMult)->N3RECNO		:= aRecno[nX]
	
		If !(oGetD:aCols[nX,Len(oGetD:aHeader)+1])
			(cTabMult)->RECDEL		:= "N"
		Else
			(cTabMult)->RECDEL		:= "S"
		EndIf
		MsUnLock()
		
	Next
EndIf
(cTabMult)->(dbGoTop())
(cTabMult)->(dbEval({|| nTotalReg++ }))
(cTabMult)->(dbGoTop())

If nTotalReg>0
	If nTotalReg < nNumProc
		aProcs := Array(1)
	Else
		aProcs := Array(nNumProc)
	EndIf
	
	If Len(aProcs) > 1 // MultiThread
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o calculos das quantidades de registrosณ
		//ณque cada thread irแ processar e                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX := 1 to Len(aProcs)
			cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX) + '.lck'
			cMarca		:= GetMark()
			nRegAProc	:= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
			nRegJProc	+= nRegAProc
			aProcs[nX]	:= {cNomeArq ,cMarca,nRegAProc,0,0}
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o Update dos campos de flag setando quais registrosณ
		//ณcada thread irแ processar.                                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		A380FlagTab(cTabMult,aProcs,'N3RECNO',"NJ_OK",cTableName)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicializa as Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX := 1 to Len(aProcs)
			StartJob("A380JOBSIM",GetEnvServer(),.F.,dDataBase,cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],cTableName,cCodigo,cValToChar(nX),aStruSQL,lEfetiva, nOpc)
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o controle das Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Sleep(3000)
		lRet := AF380Monitor(aProcs)
	Else
		lRet := A380SSim(cTabMult,cCodigo,lEfetiva,nOpc,oGetD)
	EndIf
Else
	If nOpc == EXCLUIR
		lRet := .T.
	Else
		Help(" ",1,"AF380NoRec",,STR0034,1,0) //"Nใo ha registros a serem processados"
		lRet := .F.
	EndIf
EndIf

//Deleta tabela temporaria criada no banco de dados
If _oATFA3801 <> Nil
	_oATFA3801:Delete()
	_oATFA3801 := Nil
Endif

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA380SSim  บAutor  ณAlvaro Camillo Neto บ Data ณ  02/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o processamento da simula็ใo da deprecia็ใo         บฑฑ
ฑฑบ          ณEm uma thread (Single)                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA380                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A380SSim(cTab,cCodigo,lEfetiva,nOpc,oGetD)
Local aArea	   		:= GetArea()
Local nRecno	 	:= 0
Local nNumProc		:= SuperGetMv("MV_ATFMTHR", .F., 1 )
Local cPadraoAQ		:= ""
Local cPadraoBai	:= ""
Local cTipoGer		:= SuperGetMv( "MV_ATFTIOA", .F., "12" )
Local lTpSaldo		:= .F.
Local cTpSaldo		:= "1"
Local lOnOff		:= .T.
Local lJob			:= IsInCallStack( "A380JOBSIM" )
Local cItem			:= ""
Local lExecEfet 	:= .T.
Local cTypes12		:= IIF(lIsRussia,"/" + AtfNValMod({2}, "/"),"") // CAZARINI - 07/04/2017 - If is Russia, add new valuations models - recoverable model
Local lRetEfet		:= .T.
Local cPadraoImp	:= "894"

// Variaveis para contabiliza็ใo
Private lMostra	 	:= .F.
Private lAglutina 	:= .F.
Private cArquivo 	:= ""
Private nTotal 		:= 0
Private nHdlPrv		:= 0
Private cPadrao   	:= ""
Private aCtbDia		:= {}
Private cLoteAtf 	:= LoteCont("ATF")

DbSelectArea("SNJ")
lTpSaldo := .T.

Pergunte("AF380S",.F.)
lOnOff := MV_PAR03 == 1
If nNumProc == 1
	lMostra	 := MV_PAR01 == 1
EndIf
lAglutina := MV_PAR02 == 1

If Alltrim(cTipoGer) $ ('12' + cTypes12)
	cPadraoAQ := "80A"
	cPadraoBai := "81A"
Else
	cPadraoAQ := "801"
	cPadraoBai := "810"
EndIf

If lEfetiva .And. ( VerPadrao(cPadraoAQ) .Or. VerPadrao(cPadraoBai) .or. VerPadrao(cPadraoImp)  ) .And. lOnOff
	nHdlPrv := HeadProva(cLoteAtf,"ATFA380",Substr(cUsername,1,6),@cArquivo)
EndIf

cItem := StrZero(0,TamSx3('NJ_ITEM')[1] )

While (cTab)->(!Eof())
	If lTpSaldo
		cTpSaldo := (cTab)->NJ_TPSALDO
	EndIf

	If lJob
		cItem := (cTab)->NJ_ITEM
	Else
		cItem := Soma1(cItem)
	EndIf
		lExecEfet := .T. 
		If (cTab)->RECDEL == "S"  //se registro foi deletado
			nRecno	:= ATFIOASimu(cCodigo,cItem,(cTab)->N3RECNO,.T.,cTab)
			If lIsRussia .and. ((nOpc==EFETIVAR) .or. (nOpc==EFETIVAR .and. lEfetiva))
				lExecEfet := .F.
			Endif
		Else
			nRecno	:= ATFIOASimu(cCodigo,cItem,(cTab)->N3RECNO,nOpc==EXCLUIR,cTab)
		EndIf

		If lIsRussia
			If lExecEfet .and. lEfetiva
				ATFIOAEfet(nRecno,cTab)
			EndIf
		Else
			If lEfetiva
				lRetEfet:= ATFIOAEfet(nRecno)
			EndIf
		EndIf
		(cTab)->(dbSkip())
End

If nHdlPrv > 0 .And. ( nTotal > 0 ) .And. lOnOff .and. lRetEfet
	RodaProva(nHdlPrv,nTotal)
	cA100Incl( cArquivo, nHdlPrv , 3 , cLoteAtf, lMostra, lAglutina)
Endif

RestArea(aArea)
Return lRetEfet

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็oes acessorias para o processamento MultiThreadณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA380FlagTabบAutor ณAlvaro Camillo Neto บ Data ณ  02/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o Update dos campos de flag setando quais registros บฑฑ
ฑฑบ          ณcada thread irแ processar.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA380                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A380FlagTab(cTabMult,aProcs,cCpoRecno,cCpoFlag,cTableName)
Local aArea		:= GetArea()
Local nRecMin   := 0
Local nRecMax   := 0
Local nX		:= 0
Local nCount	:= 0
Local cQuery	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDescobre o Recno Mแximo e Minimo de cada ณ
//ณintervalo                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
(cTabMult)->(dbGoTop())
For nX := 1 to Len(aProcs)
	nRecMin := (cTabMult)->&(cCpoRecno)
	nCount	:= 0
	While (cTabMult)->(!EOF())
		nRecMax := (cTabMult)->&(cCpoRecno)
		(cTabMult)->(dbSkip())
		nCount++
		If nCount >= aProcs[nX][QTD_REGISTROS] .Or. (cTabMult)->(EOF())
			aProcs[nX][REC_MIN] := nRecMin
			aProcs[nX][REC_MAX]	:= nRecMax
			Exit
		EndIf
	End
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o Updateณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aProcs)
	cQuery := " UPDATE "+cTableName+" SET "+cCpoFlag+" = '"+	aProcs[nX][MARCA]+"'  "
	cQuery += " WHERE "+cCpoRecno+" BETWEEN "+cValtoChar(aProcs[nX][REC_MIN])+ " AND " +cValtoChar(aProcs[nX][REC_MAX])
	TCSQLExec(cQuery)
Next nX

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF380MonitorบAutorณAlvaro Camillo Neto บ Data ณ  03/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsavel por monitorar as threads de processamen บฑฑ
ฑฑบ          ณ to                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA380                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF380Monitor(aProcs)
Local lRet			:= .T.
Local nX			:= 0
Local aConcluido	:= {}
Local nHandle		:= 0
Local cMsg			:= ""

While .T.
	For nX := 1 to Len(aProcs)
		nHandle := a380Lock(aProcs[nX][ARQUIVO])
		If  nHandle >= 0
			fClose(nHandle)
			If aScan(aConcluido,{|aItem| aItem[3] == aProcs[nX][MARCA]} ) == 0
				AADD(aConcluido, { nHandle, aProcs[nX][ARQUIVO], aProcs[nX][MARCA]})
			EndIf
		EndIf
	Next nX
	
	If Len(aConcluido) >= Len(aProcs)
		Exit
	EndIF
	Sleep(5000)
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se todas a threads foram processadas corretamenteณ
//ณlibera o recurso e apaga o arquivo                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aConcluido)
	FT_FUse(aConcluido[nX][2])
	FT_FGoTop()
	cMsg := FT_FReadLn()
	FT_FUse()
	fErase(aConcluido[nX][2])
	If lRet .And. ALLTRIM(cMsg) != OK
		lRet := .F.
	EndIf
Next nX

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA380JOBSIMบAutor  ณ Acaci Egas         บ Data ณ  07/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJob respnsavel por subir o ambiente e processar a simulacao บฑฑ
ฑฑบ          ณde seus registros                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA380                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A380JOBSIM(dData,cEmpX,cFilX,cMarca,cFileLck,cTabMaster,cCodigo,cId,aStruSQL,lEfetiva,nOpc)

Local nHandle	 := 0
Local cTabJob	 := ""
Local cQuery	 := ""
Local nX		 := 0
Local lRet		 := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o arquivo de Lock parao controle externo das threadsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := a380Lock(cFileLck)

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX, cFilX,,,'ATF')

//******************
// For็a data base *
//******************
dDataBase	:= dData

Conout(STR0057+ cCodigo +" Thread: "+cId + " as " + TIME()) // "Processando Simulacao do IOA:"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a query dos registros a serem processadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery += " SELECT "
For nX := 1 to Len(aStruSQL)
	cQuery += " "+aStruSQL[nX][1]+"  ,"
Next nX
cQuery := Left(cQuery,Len(cQuery)-1)
cQuery +=" FROM "+cTabMaster+" SNJ "
cQuery +=" WHERE NJ_OK = '"+cMarca+"'"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),(cTabJob := AF380NextAlias()), .F., .T.)

For nX := 1 to Len(aStruSQL)
	If aStruSQL[nX][2] <> "C"
		TcSetField(cTabJob ,aStruSQL[nX][1],aStruSQL[nX][2],aStruSQL[nX][3],aStruSQL[nX][4])
	EndIf
Next nX

(cTabJob)->(dbGotop())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lRet := A380SSim(cTabJob,cCodigo,lEfetiva,nOpc)

a380UnLock(nHandle,lRet)
Conout(STR0057+ cCodigo +" Thread: "+cId + " as " + TIME()) //"Finalizada Simulacao do IOA:"

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณA380Lock  ณ Autor ณAlvaro Camillo Neto    ณ Data ณ 03/02/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณCria arquivo para travar processos e garantir que sao unicosณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณATFA380                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function A380Lock(cFile)
Local nHJob := 0
If File(cFile)
	nHJob := FOPEN(cFile,2)
Else
	nHJob := FCREATE(cFile)
EndIf
Return nHJob

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณA380UnLockณ Autor ณAlvaro Camillo Neto    ณ Data ณ 03/02/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณEncerra a trava                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณATFA380                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function A380UnLock(nHandle,lOk)
Local cMsg := IIF(lOk,OK,ERRO)
FWRITE(nHandle,cMsg)
FCLOSE(nHandle)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaAcols บAutor  ณ Acacio Egas        บ Data ณ  04/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunc๕a que cria Acols                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoGetDados : painel										  บฑฑ
ฑฑบ          ณaHeader : aHeader aonde o aCOls serแ baseado                บฑฑ
ฑฑบ          ณaCols   : Opcional caso queira iniciar com algum elemento   บฑฑ
ฑฑบ          ณaRecNo  : recno do SN3.                                     บฑฑ
ฑฑบ          ณaRetPer : parametros                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaAcols( aHeader, aRecNo, aRetPer , nOpc )
Local nX			:= 0
Local nCols		    := 0
Local aArea			:= GetArea()
Local cQuery		:= ""
Local cTipoGer		:= SuperGetMv( "MV_ATFTIOA", .F., "12" )
Local aCols			:= {}
Local cFilTipGer	:= ""
Local cFilTipRed	:= ""
Local lTpSaldo		:= .F.
Local cFilSN3		:= XFILIAL("SN3") 
Local cTabSN3		:= RetSqlName("SN3") 

Local cTypes10		:= IIF(lIsRussia,AtfNValMod({1}, "|"),"") // CAZARINI - 24/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10		:= {}
Local nTypes10		:= 0
	
Local cTypes12		:= IIF(lIsRussia,"|" + AtfNValMod({2}, "|"),"") // CAZARINI - 07/04/2017 - If is Russia, add new valuations models - recoverable model
Local lCalc			:= .T.
Local nCpoPerAc1    := aScan(aHeader, {|x| alltrim(x[2])=="NJ_PERACM1"})
aTypes10 := Separa(cTypes10, '|', .f.)
Pergunte("AF380S",.F.)


/*
 * Verifica se trata o tipo de saldo para utiliza็ใo da redu็ใo de valor recuper?el com o tipo 10 - Gerencial
 */
DbSelectArea("SNJ")
lTpSaldo	:= .T.
lTpDepr		:= .T.

/*
 * Filtro para considera็ใo dos bens com o item fiscal, e de somente o tipo gerencial na aus?cia do tipo fiscal na tabela SN3
 */
If lIsRussia
	cFilTipGer += " (N01.N3_TIPO = '01' AND NOT EXISTS ( "
Else
	cFilTipGer += " (N01.N3_TIPO = '01' AND '10' NOT IN ( "
EndIf
cFilTipGer += " SELECT SN3.N3_TIPO "
cFilTipGer += " FROM " + cTabSN3 + " SN3 "
cFilTipGer += " WHERE SN3.D_E_L_E_T_ = ' '
cFilTipGer += " AND SN3.N3_FILIAL = '" + cFilSN3 + "' "
cFilTipGer += " AND N01.N3_CBASE = SN3.N3_CBASE "
cFilTipGer += " AND N01.N3_ITEM = SN3.N3_ITEM "
If lIsRussia
	cFilTipGer += " AND SN3.N3_OPER = '1' " // CAZARINI - 22.01.2017 - Asset Into Operation?
Endif

If lIsRussia
	If len(aTypes10) = 0
		cFilTipGer += " AND SN3.N3_TIPO = '10' "
	Else
		cFilTipGer += " AND SN3.N3_TIPO IN ('10' "
		For nTypes10 := 1 to len(aTypes10)
			cFilTipGer += ", '" + aTypes10[nTypes10] + "'"
		Next nTypes10
		cFilTipGer += " ) "
	Endif
EndIf

cFilTipGer += " AND SN3.N3_BAIXA = '0' GROUP BY SN3.N3_TIPO ) ) "

If lIsRussia
	If len(aTypes10) = 0
		cFilTipGer += " OR N01.N3_TIPO = '10' "
	Else
		cFilTipGer += " OR N01.N3_TIPO IN ('10' "
		For nTypes10 := 1 to len(aTypes10)
			cFilTipGer += ", '" + aTypes10[nTypes10] + "'"
		Next nTypes10
		cFilTipGer += " ) "
	Endif	
Else
	cFilTipGer += " OR N01.N3_TIPO = '10' "
EndIf
/*
* Filtro para considera็ใo dos bens com o item fiscal ou gerencial que n? contenha itens do tipo Redu็ใo de Valor Recuper?el na tabela SN3
*/
If lIsRussia
	cFilTipRed += " ( NOT EXISTS ( "
Else
	cFilTipRed += " ('" + cTipoGer + "' NOT IN ( "
EndIf
cFilTipRed += " SELECT SN312.N3_TIPO "
cFilTipRed += " FROM " + cTabSN3 + " SN312 "
cFilTipRed += " WHERE SN312.D_E_L_E_T_ = ' '
If lIsRussia
	cFilTipRed += " AND SN312.N3_TIPO IN " + FormatIn( cTipoGer + cTypes12, "|") + " "
EndIf
cFilTipRed += " AND SN312.N3_FILIAL = '" + cFilSN3 + "' "
cFilTipRed += " AND N01.N3_CBASE = SN312.N3_CBASE "
cFilTipRed += " AND N01.N3_ITEM = SN312.N3_ITEM "

If lIsRussia
	cFilTipRed += " AND SN312.N3_OPER = '1' " // CAZARINI - 22.01.2017 - Asset Into Operation?
Endif

cFilTipRed += " AND SN312.N3_BAIXA = '0' GROUP BY SN312.N3_TIPO ) ) "

If nOpc == INCLUIR
   
	/*
	 *  Query para a buscar dos itens de bens  com tipo 10 - Deprecia็ใo Gerencial e o tipo 01 - Deprecia็ใo Fiscal para Redu็ใo do Valor Recuper?el
	 */
	cQuery += " SELECT N1_CBASE NJ_BEM, N1_ITEM NJ_ITBEM, 0 NJ_VLVEN01, "
	If lTpSaldo
		cQuery += " COALESCE(N12.N3_TPSALDO,'1') NJ_TPSALDO, "
	EndIf
	cQuery += " COALESCE(N12.N3_VRDACM1,0) NJ_VLACM01, "
	cQuery += " COALESCE(N12.N3_TIPO,'') NJ_TIPO, "
	cQuery += " COALESCE(N12.N3_VORIG1,0)  NJ_VLORI01, "
	cQuery += " COALESCE(N12.N3_VORIG1,0)  NJ_VLREC01, "
	cQuery += " COALESCE(N12.N3_TXDEPR1,0) NJ_VLTAX01, " 
	If lTpDepr

		cQuery += " COALESCE(N12.N3_TPDEPR,'') NJ_TPDEPR, "		
		cQuery += " COALESCE(N12.N3_PERDEPR,0)  NJ_PERDEPR, "
		cQuery += " COALESCE(N12.N3_VLSALV1,0)  NJ_VLSALV1, "					
		cQuery += " COALESCE(N12.N3_PRODANO,0)  NJ_PRODANO, "								
		cQuery += " COALESCE(N12.N3_PRODMES,0)  NJ_PRODMES, "						
		cQuery += " COALESCE(N12.N3_VMXDEPR,0)  NJ_VMXDEPR, "					
		cQuery += " COALESCE(N12.N3_PRODACM,0)  NJ_PRODACM, "						
		cQuery += " COALESCE(N12.N3_CODIND,'')  NJ_CODIND, "						

		cQuery += " COALESCE(N12.N3_VRDACM2,0) NJ_VRDACM2, "
		cQuery += " COALESCE(N12.N3_VORIG2,0) NJ_VLREC02, "
		cQuery += " COALESCE(N12.N3_VORIG2,0) NJ_VORIG2, "
		cQuery += " COALESCE(N12.N3_TXDEPR2,0) NJ_TXDEPR2, "

		cQuery += " COALESCE(N12.N3_VRDACM3,0) NJ_VRDACM3, "
		cQuery += " COALESCE(N12.N3_VORIG3,0) NJ_VLREC03, "
		cQuery += " COALESCE(N12.N3_VORIG3,0) NJ_VORIG3, "
		cQuery += " COALESCE(N12.N3_TXDEPR3,0) NJ_TXDEPR3, "

		cQuery += " COALESCE(N12.N3_VRDACM4,0) NJ_VRDACM4, "
		cQuery += " COALESCE(N12.N3_VORIG4,0) NJ_VLREC04, "
		cQuery += " COALESCE(N12.N3_VORIG4,0) NJ_VORIG4, "
		cQuery += " COALESCE(N12.N3_TXDEPR4,0) NJ_TXDEPR4, " 

		cQuery += " COALESCE(N12.N3_VRDACM5,0) NJ_VRDACM5, "
		cQuery += " COALESCE(N12.N3_VORIG5,0) NJ_VLREC05, "
		cQuery += " COALESCE(N12.N3_VORIG5,0) NJ_VORIG5, "
		cQuery += " COALESCE(N12.N3_TXDEPR5,0) NJ_TXDEPR5, "

		If SNJ->(ColumnPos("NJ_CCONTAB")) > 0
			cQuery += " COALESCE(N12.N3_CCONTAB,'')	NJ_CCONTAB, "
		Endif
		If SNJ->(ColumnPos("NJ_CUSTBEM")) > 0
			cQuery += " COALESCE(N12.N3_CUSTBEM,'')	NJ_CUSTBEM, "
		Endif
		If SNJ->(ColumnPos("NJ_CDEPREC")) > 0
			cQuery += " COALESCE(N12.N3_CDEPREC,'')	NJ_CDEPREC, "
		Endif
		If SNJ->(ColumnPos("NJ_CCUSTO")) > 0
			cQuery += " COALESCE(N12.N3_CCUSTO,'')	NJ_CCUSTO, "
		Endif
		If SNJ->(ColumnPos("NJ_CCDEPR")) > 0
			cQuery += " COALESCE(N12.N3_CCDEPR,'')	NJ_CCDEPR, "
		Endif
		If SNJ->(ColumnPos("NJ_CDESP")) > 0
			cQuery += " COALESCE(N12.N3_CDESP,'') 	NJ_CDESP, "
		Endif
		If SNJ->(ColumnPos("NJ_CCORREC")) > 0
			cQuery += " COALESCE(N12.N3_CCORREC,'')	NJ_CCORREC, "
		Endif
		If SNJ->(ColumnPos("NJ_CCDESP")) > 0
			cQuery += " COALESCE(N12.N3_CCDESP,'') 	NJ_CCDESP, "
		Endif
		If SNJ->(ColumnPos("NJ_CCCDEP")) > 0
			cQuery += " COALESCE(N12.N3_CCCDEP,'')	NJ_CCCDEP, "
		Endif
		If SNJ->(ColumnPos("NJ_CCCDES")) > 0
			cQuery += " COALESCE(N12.N3_CCCDES,'')	NJ_CCCDES, "
		Endif
		If SNJ->(ColumnPos("NJ_CCCORR")) > 0
			cQuery += " COALESCE(N12.N3_CCCORR,'')	NJ_CCCORR, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCTA")) > 0
			cQuery += " COALESCE(N12.N3_SUBCTA,'')	NJ_SUBCTA, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCON")) > 0
			cQuery += " COALESCE(N12.N3_SUBCCON,'')	NJ_SUBCCON, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCDEP")) > 0
			cQuery += " COALESCE(N12.N3_SUBCDEP,'')	NJ_SUBCDEP, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCDE")) > 0
			cQuery += " COALESCE(N12.N3_SUBCCDE,'')	NJ_SUBCCDE, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCDES")) > 0
			cQuery += " COALESCE(N12.N3_SUBCDES,'')	NJ_SUBCDES, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCOR")) > 0
			cQuery += " COALESCE(N12.N3_SUBCCOR,'')	NJ_SUBCCOR, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVL")) > 0
			cQuery += " COALESCE(N12.N3_CLVL,'')	NJ_CLVL, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCON")) > 0
			cQuery += " COALESCE(N12.N3_CLVLCON,'')	NJ_CLVLCON, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLDEP")) > 0
			cQuery += " COALESCE(N12.N3_CLVLDEP,'')	NJ_CLVLDEP, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCDE")) > 0
			cQuery += " COALESCE(N12.N3_CLVLCDE,'')	NJ_CLVLCDE, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLDES")) > 0
			cQuery += " COALESCE(N12.N3_CLVLDES,'')	NJ_CLVLDES, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCOR")) > 0
			cQuery += " COALESCE(N12.N3_CLVLCOR,'')	NJ_CLVLCOR, "
		Endif
	Endif		
	If SNJ->(ColumnPos("NJ_PERACM1")) > 0  .AND. SN3->(FieldPos("N3_PERACM1")) > 0
		cQuery += "	COALESCE(N12.N3_PERACM1,0)	NJ_PERACM1, "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM2")) > 0  .AND. SN3->(FieldPos("N3_PERACM2")) > 0
		cQuery += "	COALESCE(N12.N3_PERACM2,0)	NJ_PERACM2, "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM3")) > 0  .AND. SN3->(FieldPos("N3_PERACM3")) > 0
		cQuery += "	COALESCE(N12.N3_PERACM3,0)	NJ_PERACM3, "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM4")) > 0  .AND. SN3->(FieldPos("N3_PERACM4")) > 0
		cQuery += "	COALESCE(N12.N3_PERACM4,0)	NJ_PERACM4, "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM5")) > 0  .AND. SN3->(FieldPos("N3_PERACM5")) > 0
		cQuery += "	COALESCE(N12.N3_PERACM5,0)	NJ_PERACM5, "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM1")) > 0 .AND. SN3->(FieldPos("N3_REVACM1")) > 0
		cQuery += "	COALESCE(N12.N3_REVACM1,0)	NJ_REVACM1, "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM2")) > 0 .AND. SN3->(FieldPos("N3_REVACM2")) > 0
		cQuery += "	COALESCE(N12.N3_REVACM2,0)	NJ_REVACM2, "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM3")) > 0 .AND. SN3->(FieldPos("N3_REVACM3")) > 0
		cQuery += "	COALESCE(N12.N3_REVACM3,0)	NJ_REVACM3, "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM4")) > 0 .AND. SN3->(FieldPos("N3_REVACM4")) > 0
		cQuery += "	COALESCE(N12.N3_REVACM4,0)	NJ_REVACM4, "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM5")) > 0 .AND. SN3->(FieldPos("N3_REVACM5")) > 0
		cQuery += "	COALESCE(N12.N3_REVACM5,0)	NJ_REVACM5, "
	Endif
	cQuery += " COALESCE(N12.R_E_C_N_O_,0) N3RECNO "
	
	
	cQuery += " FROM " + RetSqlName( "SN1" ) + " SN1 "
	
	//***********************************
	// Left Join do SN1 com movimentos  *
	// nao baixados com tipo 12 no SN3  *
	//***********************************

	cQuery += " INNER JOIN " + cTabSN3 + " N12 "
	If lIsRussia
		cQuery += " ON N12.N3_FILIAL = '" + cFilSN3 + "' AND N12.D_E_L_E_T_ = ' ' AND N12.N3_TIPO IN " + FormatIn( cTipoGer + cTypes12, "|") + " AND "
	Else
		cQuery += " ON N12.N3_FILIAL = '" + cFilSN3 + "' AND N12.D_E_L_E_T_ = ' ' AND N12.N3_TIPO = '" + cTipoGer + "' AND "
	EndIf
	cQuery += "	N12.N3_DTBAIXA='' AND N12.N3_CBASE=N1_CBASE AND N12.N3_ITEM=N1_ITEM "

	If lIsRussia
		cQuery += " AND N12.N3_OPER = '1' " // CAZARINI - 22.01.2017 - Asset Into Operation?
	Endif
	
	If !Empty( aRetPer[06] )
		cQuery += " AND N12.N3_CUSTBEM >= '" + aRetPer[05] + "' AND "
		cQuery += " N12.N3_CUSTBEM <= '" + aRetPer[06] + "' "
	EndIf
	
	If !Empty( aRetPer[08] )
		cQuery += " AND N12.N3_CCONTAB >= '" + aRetPer[07] + "' AND "
		cQuery += " N12.N3_CCONTAB <= '" + aRetPer[08] + "'  "
	EndIf
	
	cQuery += " WHERE SN1.D_E_L_E_T_ = ' ' AND "
	cQuery += " SN1.N1_FILIAL = '" + xFilial( "SN1" ) + "' AND "
	cquery += " ( SN1.N1_STATUS = ' ' OR SN1.N1_STATUS = '1') AND"  
	If !Empty( aRetPer[04] )
		cQuery += " SN1.N1_GRUPO BETWEEN '"+aRetPer[03]+"' AND '"+aRetPer[04]+"' AND " 
	EndIf
	
	If !Empty( aRetPer[10] )
		cQuery += " SN1.N1_AQUISIC BETWEEN '"+DtoS(aRetPer[09])+"' AND '"+DtoS(aRetPer[10])+"' AND " 
	EndIf

	If !Empty( aRetPer[12] )
   		cQuery += " SN1.N1_ITEM BETWEEN '"+aRetPer[11]+"' AND '"+aRetPer[12]+"' AND " 
	EndIf
	
	cQuery += " COALESCE(N12.R_E_C_N_O_,0) > 0 "

	If !Empty( aRetPer[02] )
		cQuery += " AND SN1.N1_CBASE   >= '" + aRetPer[01] + "' AND "
		cQuery += " SN1.N1_CBASE   <= '" + aRetPer[02] + "' "
	EndIf
		
	cQuery += " UNION "
	
	/*
	 *  Query para a busca dos itens de bens com 12/XX - Deprecia็ใo Gerencial nova Redu็ใo do Valor Recuper?el
	 */
	cQuery += " SELECT N1_CBASE NJ_BEM, N1_ITEM NJ_ITBEM, 0 NJ_VLVEN01, "
	
	If lTpSaldo
		cQuery += " COALESCE(N01.N3_TPSALDO,'1') NJ_TPSALDO, "
	EndIf
	cQuery += " COALESCE(N01.N3_VRDACM1,0) NJ_VLACM01, "
	cQuery += " COALESCE(N01.N3_TIPO,'') NJ_TIPO, "
	cQuery += " COALESCE(N01.N3_VORIG1,0) NJ_VLORI01, "
	cQuery += " COALESCE(N01.N3_VORIG1,0) NJ_VLREC01, "
	cQuery += " COALESCE(N01.N3_TXDEPR1,0) NJ_VLTAX01, "
	If lTpDepr

		cQuery += " COALESCE(N01.N3_TPDEPR,'') NJ_TPDEPR, "		
		cQuery += " COALESCE(N01.N3_PERDEPR,0)  NJ_PERDEPR, "
		cQuery += " COALESCE(N01.N3_VLSALV1,0)  NJ_VLSALV1, "					
		cQuery += " COALESCE(N01.N3_PRODANO,0)  NJ_PRODANO, "								
		cQuery += " COALESCE(N01.N3_PRODMES,0)  NJ_PRODMES, "						
		cQuery += " COALESCE(N01.N3_VMXDEPR,0)  NJ_VMXDEPR, "					
		cQuery += " COALESCE(N01.N3_PRODACM,0)  NJ_PRODACM, "						
		cQuery += " COALESCE(N01.N3_CODIND,'')  NJ_CODIND, "						

		cQuery += " COALESCE(N01.N3_VRDACM2,0) NJ_VRDACM2, "
		cQuery += " COALESCE(N01.N3_VORIG2,0) NJ_VLREC02, "
		cQuery += " COALESCE(N01.N3_VORIG2,0) NJ_VORIG2, "
		cQuery += " COALESCE(N01.N3_TXDEPR2,0) NJ_TXDEPR2, " 

		cQuery += " COALESCE(N01.N3_VRDACM3,0) NJ_VRDACM3, "
		cQuery += " COALESCE(N01.N3_VORIG3,0) NJ_VLREC03, "
		cQuery += " COALESCE(N01.N3_VORIG3,0) NJ_VORIG3, "
		cQuery += " COALESCE(N01.N3_TXDEPR3,0) NJ_TXDEPR3, " 

		cQuery += " COALESCE(N01.N3_VRDACM4,0) NJ_VRDACM4, "
		cQuery += " COALESCE(N01.N3_VORIG4,0) NJ_VLREC04, "
		cQuery += " COALESCE(N01.N3_VORIG4,0) NJ_VORIG4, "
		cQuery += " COALESCE(N01.N3_TXDEPR4,0) NJ_TXDEPR4, " 

		cQuery += " COALESCE(N01.N3_VRDACM5,0) NJ_VRDACM5, "
		cQuery += " COALESCE(N01.N3_VORIG5,0) NJ_VLREC05, "
		cQuery += " COALESCE(N01.N3_VORIG5,0) NJ_VORIG5, "
		cQuery += " COALESCE(N01.N3_TXDEPR5,0) NJ_TXDEPR5, " 

		If SNJ->(ColumnPos("NJ_CCONTAB")) > 0
			cQuery += " COALESCE(N01.N3_CCONTAB,'')	NJ_CCONTAB, "
		Endif
		If SNJ->(ColumnPos("NJ_CUSTBEM")) > 0
			cQuery += " COALESCE(N01.N3_CUSTBEM,'')	NJ_CUSTBEM, "
		Endif
		If SNJ->(ColumnPos("NJ_CDEPREC")) > 0
			cQuery += " COALESCE(N01.N3_CDEPREC,'')	NJ_CDEPREC, "
		Endif
		If SNJ->(ColumnPos("NJ_CCUSTO")) > 0
			cQuery += " COALESCE(N01.N3_CCUSTO,'')	NJ_CCUSTO, "
		Endif
		If SNJ->(ColumnPos("NJ_CCDEPR")) > 0
			cQuery += " COALESCE(N01.N3_CCDEPR,'')	NJ_CCDEPR, "
		Endif
		If SNJ->(ColumnPos("NJ_CDESP")) > 0
			cQuery += " COALESCE(N01.N3_CDESP,'') 	NJ_CDESP, "
		Endif
		If SNJ->(ColumnPos("NJ_CCORREC")) > 0
			cQuery += " COALESCE(N01.N3_CCORREC,'')	NJ_CCORREC, "
		Endif
		If SNJ->(ColumnPos("NJ_CCDESP")) > 0
			cQuery += " COALESCE(N01.N3_CCDESP,'') 	NJ_CCDESP, "
		Endif
		If SNJ->(ColumnPos("NJ_CCCDEP")) > 0
			cQuery += " COALESCE(N01.N3_CCCDEP,'')	NJ_CCCDEP, "
		Endif
		If SNJ->(ColumnPos("NJ_CCCDES")) > 0
			cQuery += " COALESCE(N01.N3_CCCDES,'')	NJ_CCCDES, "
		Endif
		If SNJ->(ColumnPos("NJ_CCCORR")) > 0
			cQuery += " COALESCE(N01.N3_CCCORR,'')	NJ_CCCORR, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCTA")) > 0
			cQuery += " COALESCE(N01.N3_SUBCTA,'')	NJ_SUBCTA, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCON")) > 0
			cQuery += " COALESCE(N01.N3_SUBCCON,'')	NJ_SUBCCON, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCDEP")) > 0
			cQuery += " COALESCE(N01.N3_SUBCDEP,'')	NJ_SUBCDEP, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCDE")) > 0
			cQuery += " COALESCE(N01.N3_SUBCCDE,'')	NJ_SUBCCDE, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCDES")) > 0
			cQuery += " COALESCE(N01.N3_SUBCDES,'')	NJ_SUBCDES, "
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCOR")) > 0
			cQuery += " COALESCE(N01.N3_SUBCCOR,'')	NJ_SUBCCOR, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVL")) > 0
			cQuery += " COALESCE(N01.N3_CLVL,'')	NJ_CLVL, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCON")) > 0
			cQuery += " COALESCE(N01.N3_CLVLCON,'')	NJ_CLVLCON, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLDEP")) > 0
			cQuery += " COALESCE(N01.N3_CLVLDEP,'')	NJ_CLVLDEP, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCDE")) > 0
			cQuery += " COALESCE(N01.N3_CLVLCDE,'')	NJ_CLVLCDE, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLDES")) > 0
			cQuery += " COALESCE(N01.N3_CLVLDES,'')	NJ_CLVLDES, "
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCOR")) > 0
			cQuery += " COALESCE(N01.N3_CLVLCOR,'')	NJ_CLVLCOR, "
		Endif
	Endif
	If SNJ->(ColumnPos("NJ_PERACM1")) > 0  .AND. SN3->(FieldPos("N3_PERACM1")) > 0
		cQuery += "	COALESCE(N01.N3_PERACM1,0)	NJ_PERACM1, "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM2")) > 0  .AND. SN3->(FieldPos("N3_PERACM2")) > 0
		cQuery += "	COALESCE(N01.N3_PERACM2,0)	NJ_PERACM2, "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM3")) > 0  .AND. SN3->(FieldPos("N3_PERACM3")) > 0
		cQuery += "	COALESCE(N01.N3_PERACM3,0)	NJ_PERACM3, "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM4")) > 0  .AND. SN3->(FieldPos("N3_PERACM4")) > 0
		cQuery += "	COALESCE(N01.N3_PERACM4,0)	NJ_PERACM4, "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM5")) > 0  .AND. SN3->(FieldPos("N3_PERACM5")) > 0
		cQuery += "	COALESCE(N01.N3_PERACM5,0)	NJ_PERACM5, "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM1")) > 0 .AND. SN3->(FieldPos("N3_REVACM1")) > 0
		cQuery += "	COALESCE(N01.N3_REVACM1,0)	NJ_REVACM1, "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM2")) > 0 .AND. SN3->(FieldPos("N3_REVACM2")) > 0
		cQuery += "	COALESCE(N01.N3_REVACM2,0)	NJ_REVACM2, "
	Endif	
	If SNJ->(ColumnPos("NJ_REVACM3")) > 0 .AND. SN3->(FieldPos("N3_REVACM3")) > 0
		cQuery += "	COALESCE(N01.N3_REVACM3,0)	NJ_REVACM3, "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM4")) > 0 .AND. SN3->(FieldPos("N3_REVACM4")) > 0
		cQuery += "	COALESCE(N01.N3_REVACM4,0)	NJ_REVACM4, "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM5")) > 0 .AND. SN3->(FieldPos("N3_REVACM5")) > 0
		cQuery += "	COALESCE(N01.N3_REVACM5,0)	NJ_REVACM5, "
	Endif		
	cQuery += " COALESCE(N01.R_E_C_N_O_,0) N3RECNO "
		
	cQuery += " FROM " + RetSqlName( "SN1" ) + " SN1 "
	
	//*****************************************
	// Left Join do SN1 com movimentos  	  *
	// nao baixados com tipo 01 ou 10 no SN3  *
	//*****************************************

	cQuery += " INNER JOIN " + cTabSN3 + " N01 "
	cQuery += " ON N01.N3_FILIAL = '" + cFilSN3 + "' AND N01.D_E_L_E_T_ = ' ' AND "
	cQuery += "	N01.N3_DTBAIXA='' AND N01.N3_CBASE=N1_CBASE AND N01.N3_ITEM=N1_ITEM "
	
	If lIsRussia
		cQuery += " AND N01.N3_OPER = '1' " // CAZARINI - 22.01.2017 - Asset Into Operation?
	Endif
	If !Empty( aRetPer[06] )
		cQuery += " AND N01.N3_CUSTBEM >= '" + aRetPer[05] + "' AND "
		cQuery += " N01.N3_CUSTBEM <= '" + aRetPer[06] + "' "
	EndIf
	
	If !Empty( aRetPer[08] )
		cQuery += " AND N01.N3_CCONTAB >= '" + aRetPer[07] + "' AND "
		cQuery += " N01.N3_CCONTAB <= '" + aRetPer[08] + "'  "
	EndIf
	
	cQuery += " WHERE SN1.D_E_L_E_T_ = ' ' AND "
	cQuery += " SN1.N1_FILIAL = '" + xFilial( "SN1" ) + "' AND "
	cquery += " ( SN1.N1_STATUS = ' ' OR SN1.N1_STATUS = '1') AND "  
	If !Empty( aRetPer[04] )
		cQuery += " SN1.N1_GRUPO BETWEEN '"+aRetPer[03]+"' AND '"+aRetPer[04]+"' AND " 
	EndIf
	
	If !Empty( aRetPer[10] )
		cQuery += " SN1.N1_AQUISIC BETWEEN '"+DtoS(aRetPer[09])+"' AND '"+DtoS(aRetPer[10])+"' AND " 
	EndIf

	If !Empty( aRetPer[12] )
   		cQuery += " SN1.N1_ITEM BETWEEN '"+aRetPer[11]+"' AND '"+aRetPer[12]+"' AND " 
	EndIf
	
	cQuery += " COALESCE(N01.R_E_C_N_O_,0) > 0 "
	
	If !Empty( aRetPer[02] )
		cQuery += " AND SN1.N1_CBASE   >= '" + aRetPer[01] + "' AND "
		cQuery += " SN1.N1_CBASE   <= '" + aRetPer[02] + "' "
	EndIf
	cQuery += "AND ( " + cFilTipGer + " ) "
	cQuery += "AND " + cFilTipRed
	cQuery += "AND SN1.N1_PATRIM <> 'T' "
	
Else
	cQuery := " SELECT NJ_ITEM, NJ_BEM, NJ_ITBEM, NJ_VLREC01, NJ_VLTAX01,NJ_TIPO,NJ_VLACM01,NJ_VLVEN01,NJ_VLORI01"
	If lTpSaldo
		cQuery += " ,NJ_TPSALDO "
	EndIf                                      
	If lTpDepr
		cQuery += " ,NJ_TPDEPR,NJ_PERDEPR,NJ_VLSALV1,NJ_PRODANO,NJ_PRODMES,NJ_VMXDEPR,NJ_PRODACM,NJ_CODIND,"
		cQuery += " NJ_VRDACM2,NJ_VLREC02,NJ_VORIG2,NJ_VLVEN02,NJ_TXDEPR2,"
		cQuery += " NJ_VRDACM3,NJ_VLREC03,NJ_VORIG3,NJ_VLVEN02,NJ_TXDEPR3,"
		cQuery += " NJ_VRDACM4,NJ_VLREC04,NJ_VORIG4,NJ_VLVEN02,NJ_TXDEPR4,"
		cQuery += " NJ_VRDACM5,NJ_VLREC05,NJ_VORIG5,NJ_VLVEN02,NJ_TXDEPR5"
		If SNJ->(ColumnPos("NJ_CCONTAB")) > 0
			cQuery += " ,NJ_CCONTAB"
		Endif
		If SNJ->(ColumnPos("NJ_CUSTBEM")) > 0
			cQuery += " ,NJ_CUSTBEM"
		Endif
		If SNJ->(ColumnPos("NJ_CDEPREC")) > 0
			cQuery += " ,NJ_CDEPREC"
		Endif 
		If SNJ->(ColumnPos("NJ_CCUSTO")) > 0
			cQuery += " ,NJ_CCUSTO"
		Endif 
		If SNJ->(ColumnPos("NJ_CCDEPR")) > 0
			cQuery += " ,NJ_CCDEPR"
		Endif
		If SNJ->(ColumnPos("NJ_CDESP")) > 0
			cQuery += " ,NJ_CDESP"
		Endif 
		If SNJ->(ColumnPos("NJ_CCORREC")) > 0
			cQuery += " ,NJ_CCORREC"
		Endif
		If SNJ->(ColumnPos("NJ_CCDESP")) > 0
			cQuery += " ,NJ_CCDESP"
		Endif
		If SNJ->(ColumnPos("NJ_CCCDEP")) > 0
			cQuery += " ,NJ_CCCDEP"
		Endif
		If SNJ->(ColumnPos("NJ_CCCDES")) > 0
			cQuery += " ,NJ_CCCDES"
		Endif
		If SNJ->(ColumnPos("NJ_CCCORR")) > 0
			cQuery += " ,NJ_CCCORR"
		Endif
		If SNJ->(ColumnPos("NJ_SUBCTA")) > 0
			cQuery += " ,NJ_SUBCTA"
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCON")) > 0
			cQuery += " ,NJ_SUBCCON"
		Endif
		If SNJ->(ColumnPos("NJ_SUBCDEP")) > 0
			cQuery += " ,NJ_SUBCDEP"
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCDE")) > 0
			cQuery += " ,NJ_SUBCCDE"
		Endif
		If SNJ->(ColumnPos("NJ_SUBCDES")) > 0
			cQuery += " ,NJ_SUBCDES"
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCOR")) > 0
			cQuery += " ,NJ_SUBCCOR"
		Endif
		If SNJ->(ColumnPos("NJ_CLVL")) > 0
			cQuery += " ,NJ_CLVL"
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCON")) > 0
			cQuery += " ,NJ_CLVLCON"
		Endif
		If SNJ->(ColumnPos("NJ_CLVLDEP")) > 0
			cQuery += " ,NJ_CLVLDEP"
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCDE")) > 0
			cQuery += " ,NJ_CLVLCDE"
		Endif
		If SNJ->(ColumnPos("NJ_CLVLDES")) > 0
			cQuery += " ,NJ_CLVLDES"
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCOR")) > 0
			cQuery += " ,NJ_CLVLCOR"
		Endif

	Endif
	If SNJ->(ColumnPos("NJ_PERACM1")) > 0  
		cQuery += "	,NJ_PERACM1 "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM2")) > 0  
		cQuery += "	,NJ_PERACM2 "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM3")) > 0  
		cQuery += "	,NJ_PERACM3 "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM4")) > 0  
		cQuery += "	,NJ_PERACM4 "
	Endif
	If SNJ->(ColumnPos("NJ_PERACM5")) > 0 
		cQuery += "	,NJ_PERACM5 "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM1")) > 0
		cQuery += "	,NJ_REVACM1 "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM2")) > 0	
		cQuery += "	,NJ_REVACM2 "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM3")) > 0
		cQuery += "	,NJ_REVACM3 "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM4")) > 0
		cQuery += "	,NJ_REVACM4 "
	Endif
	If SNJ->(ColumnPos("NJ_REVACM5")) > 0
		cQuery += "	,NJ_REVACM5 "
	Endif
	If SNJ->(ColumnPos("NJ_TPAJUST")) > 0
		cQuery += "	,NJ_TPAJUST "
	Endif
	If SNJ->(ColumnPos("NJ_CPERREV")) > 0
		cQuery += "	,NJ_CPERREV "
	Endif
	If SNJ->(ColumnPos("NJ_CRECDES")) > 0
		cQuery += "	,NJ_CRECDES "
	Endif
	If SNJ->(ColumnPos("NJ_VLRIMPT")) > 0
		cQuery += "	,NJ_VLRIMPT "
	Endif
	If SNJ->(ColumnPos("NJ_DTAVALI")) > 0
		cQuery += "	,NJ_DTAVALI "
	Endif
	          
	If nOpc <> VISUALIZAR          
		cQuery += " ,COALESCE(N01.R_E_C_N_O_,0) N3RECNO "
	Else
		cQuery += " ,COALESCE(R_E_C_N_O_,0) N3RECNO "
	EndIf
	
	cQuery += " FROM " + RetSqlName( "SNJ" ) + " SNJ "
	                                     	
	//***********************************
	// Left Join do SN1 com movimentos  *
	// nao baixados com tipo 01 no SN3  *
	//***********************************
	If nOpc <> VISUALIZAR 
		cQuery += " INNER JOIN " + cTabSN3 + " N01 "
		cQuery += " ON N01.N3_FILIAL = '" + cFilSN3 + "' AND N01.D_E_L_E_T_ = ' ' AND "
		cQuery += "	N01.N3_DTBAIXA='' AND N01.N3_CBASE=NJ_BEM AND N01.N3_ITEM=NJ_ITBEM AND N01.N3_TIPO = NJ_TIPO "
		If lTpSaldo
			cQuery += " AND N01.N3_TPSALDO = NJ_TPSALDO "
		EndIf
		
		If lIsRussia
			cQuery += " AND N01.N3_OPER = '1' " // CAZARINI - 22.01.2017 - Asset Into Operation?	
		Endif
	EndIf
	cQuery += " WHERE SNJ.NJ_FILIAL='" + xFilial("SNJ") + "' AND SNJ.NJ_PROC='" + M->NI_PROC + "' AND SNJ.D_E_L_E_T_= ' '	ORDER BY NJ_ITEM"
Endif

cQuery := ChangeQuery( cQuery )

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery ), "TMPSN3", .T.,.F. )
If TMPSN3->( Eof() )
	Help( " ",1,"AF380EOF",,STR0039,1,0)//"Nenhum registro foi encontrado com os parametros especificados"
	TMPSN3->( DbCloseArea() )
	Return(aCols)  //deve retornar acols vazio
EndIf

While TMPSN3->( !Eof() )

	//Bens relacionados a projeto nao podem ser selecionados para o processo
	If ATFXVerPrj(TMPSN3->NJ_BEM,TMPSN3->NJ_ITBEM,.f.)
		TMPSN3->( DbSkip() )
		Loop
	EndIf   

	aAdd(aCols,Array(Len(aHeader)+1))
	nCols ++
	lCalc := .T.
	If TMPSN3->N3RECNO >0
		For nX := 1 To Len(aHeader)
			If Alltrim(aHeader[nX][02]) == "NJ_ITEM"
				If TMPSN3->(FieldPos( aHeader[nX][2] )) >0
					aCols[nCols][nX] := TMPSN3->( FieldGet( FieldPos( aHeader[nX][2] ) ) )
				Else
					aCols[nCols][nX] := StrZero(nCols,TamSx3("NJ_ITEM")[1])
				EndIf
			ElseIf TMPSN3->(FieldPos( aHeader[nX][2] ))>0
				If SNJ->(ColumnPos("NJ_TPAJUST")) > 0 .and. SNJ->(ColumnPos("NJ_PERACM1")) > 0 .and. SNJ->(ColumnPos("NJ_REVACM1")) > 0				    
					If "NJ_PERACM" $ Alltrim(aHeader[nX][02]) .or. "NJ_REVACM" $ Alltrim(aHeader[nX][02])						
						If lCalc .and. nCpoPerAc1 > 0 .and. TMPSN3->( FieldGet( FieldPos( aHeader[nCpoPerAc1][2] ) ) ) > 0
							lCalc := .F.
						EndIf
						If !lCalc
							aCols[nCols][nX] := TMPSN3->( FieldGet( FieldPos( aHeader[nX][2] ) ) )							
						Else
							aRetImp:=AF380REVER(TMPSN3->NJ_BEM,TMPSN3->NJ_ITBEM,Right(Alltrim(aHeader[nX][02]),1),cFilSN3 )
							If "NJ_PERACM" $ Alltrim(aHeader[nX][02])
								aCols[nCols][nX] :=aRetImp[PERDAACM]
							Else
								aCols[nCols][nX] :=aRetImp[REVERACM]
							EndIf
						EndIf
					Else
						If FWSX3Util():GetFieldType( aHeader[nX][2] ) =="D"
							aCols[nCols][nX] := Stod(TMPSN3->( FieldGet( FieldPos( aHeader[nX][2] ) ) ))
						Else
							aCols[nCols][nX] := TMPSN3->( FieldGet( FieldPos( aHeader[nX][2] ) ) )
						EndIf
					EndIf
				Else
					aCols[nCols][nX] := TMPSN3->( FieldGet( FieldPos( aHeader[nX][2] ) ) )
				EndIf
			Else
				aCols[nCols][nX] := CriaVar( aHeader[nX][2], .T. )
			EndIf
		Next nX
		aCols[nCols][Len(aHeader)+1] := .F.
		
		aAdd( aRecNo, TMPSN3->N3RECNO )
		
	EndIf
	
	TMPSN3->( DbSkip() )
End

TMPSN3->( DbCloseArea() )

RestArea( aArea )

Return aCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF380NextAliasบAutorณAlvaro Camillo Neto บ Data ณ  14/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProte็ใo para retornar o pr๓ximo alias disponivel no Banco  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF380NextAlias()
Local cNextAlias := ""
Local aArea := GetArea()

While .T.
	cNextAlias := CriaTrab( , .F.)
	If !TCCanOpen(cNextAlias) .And. Select(cNextAlias) == 0
		Exit
	EndIf
EndDo

RestArea(aArea)
Return cNextAlias


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSTRARRAY บAutor  ณMicrosiga           บ Data ณ  03/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Transforma os parametos em array                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function StrArray(xVal,aDefault)
Local nX
Local Ret 
Local aAux:= {}
Default aDefault := {} 

If VALTYPE(xVal)=="A"
	Ret := ""
	For nX := 1 to Len(xVal)
		If Valtype(xVal[nX]) == "C"
			Ret += "C%"+ xVal[nX] + "#"
		ElseIf Valtype(xVal[nX]) == "N"
			Ret += "N%"+ cValToCHar(xVal[nX]) + "#"
		ElseIf Valtype(xVal[nX]) == "D"
			Ret += "D%"+ dToS(xVal[nX]) + "#"
		EndIf
	Next
ElseIf VALTYPE(xVal)=="C"
	Ret := {}
	aAux := StrtoKarr(xVal,"#")
	For nX := 1 to Len(aAux)
		If Left(aAux[nX],2) == "N%"
			aAux[nX] := Val( Right( aAux[nX], Len(aAux[nX]) -2 ) )		
		ElseIf Left(aAux[nX],2) == "D%"
			aAux[nX] := StoD( Right( aAux[nX], Len(aAux[nX]) -2 ) )	
		ElseIf "%" $ aAux[nX] 
			aAux[nX] := Right( aAux[nX], Len(aAux[nX]) -2 )
		EndIf 
	Next Nx
	
	If Len(aDefault) > 0
		For nX := 1 to Len(aDefault)
			If nX <= Len(aAux)
				aAdd(Ret,aAux[nX])
			Else
				aAdd(Ret,aDefault[nX])
			EndIf
		Next
	Else
		Ret := aClone(aAux)
	EndIf	
EndIf

Return Ret

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF380BaixAcบAutor ณAlvaro Camillo Neto บ Data ณ  10/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a baixa da acelera็ใo                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA380                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF380BaixAc(cN3Filial,cN3CBase,cN3Item,cN3Tipo,cN3Baixa,cN3Seq,cIdMov)
Local aArea 	:= GetArea()
Local aAreaSN3  := SN3->(GetArea())
Local aAreaSN1	:= SN1->(GetArea())
Local lRet		:= .T.
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local xAtivo := {}
Local xCab := {}
Local aParam	:= {}
Local nQuant 	:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariavel Private para a baixa dos Bens de aceleracaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lMsErroAuto := .F.

Default cIdMov	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdena็ใo das tabelas envolvidasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SN1->(dbSetOrder(1))	//N1_FILIAL+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(1))	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

aAdd( aParam, {"MV_PAR01", 2} )
aAdd( aParam, {"MV_PAR02", 2} )
aAdd( aParam, {"MV_PAR03", 2} )

If SN1->(MSSeek(cN3Filial+cN3CBase+cN3Item)) .And. SN3->(MSSeek(cN3Filial+cN3CBase+cN3Item+cN3Tipo+cN3Baixa+cN3Seq))
	cSeq	 := SN3->N3_SEQ

	If 	SN3->N3_TIPO $ '10'	
		nQuant := SN1->N1_QUANTD //atualiza a quantidade do tipo 10 para relatorio ATFR072 // Tipo 12 nใo controla quantidade
	EndIF	

	xCab :={	{"FN6_FILIAL"	,xFilial("SN3")		,NIL},;
				{"FN6_CBASE"	,SN3->N3_CBASE		,NIL},;
				{"FN6_CITEM"	,SN3->N3_ITEM			,NIL},;
				{"FN6_MOTIVO"	,"08"					,NIL},;
				{"FN6_QTDATU"	,SN1->N1_QUANTD		,NIL},;
				{"FN6_BAIXA"	,100					,NIL},;
				{"FN6_QTDBX"	,nQuant		    		,NIL},; 
				{"FN6_DTBAIX"	,dDatabase				,NIL},;
				{"FN6_PERCBX"	,100			,NIL},;
				{"FN6_DEPREC"	,'0'					,NIL} }
				
	xAtivo:={ 	{"N3_FILIAL"	, xFilial("SN3")		,NIL},;
				{"N3_CBASE"	, SN3->N3_CBASE		,NIL},;
				{"N3_ITEM"		, SN3->N3_ITEM		,NIL},;
		   	   	{"N3_TIPO"		, SN3->N3_TIPO		,NIL},;
				{"N3_BAIXA"   , SN3->N3_BAIXA		,NIL},;
	   		  	{"N3_TPSALDO"	, SN3->N3_TPSALDO		,NIL} }
	

	MsExecAuto({|a,b,c,d,e,f| ATFA036(a,b,c,d,e,f)},xCab,xAtivo,3,,.F.,aParam)  
	If lMsErroAuto
   		MostraErro() 
   		lRet := .F.
	Endif
EndIf

//--------------------------------------------------------------------------------------------------------------
// Executa o Pergunte para recarga das variaveis MV_PAR, pois a MSExecAuto substitui pelos perguntes da ATFA036
//--------------------------------------------------------------------------------------------------------------
Pergunte("AF380S",.F.)

RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFIOASimuบAutor  ณ Acacio Egas        บ Data ณ  26/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetiva็ใo da Reducao ao valor recuperavel de ativos       บฑฑ
ฑฑบ          ณ  (IAS 36) IFRS. IOA - Impairment of Assets.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IFRS                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATFIOASimu(cProc,cSeq, nRecnoSN3,lDelet,cTab)

Local aAreaSNI 	:= SNI->(GetArea())
Local aAreaSNJ 	:= SNJ->(GetArea())
Local aAreaSN3 	:= SN3->(GetArea())
Local aArea 	:= GetArea()
Local nRecno	:= 0
Local lTpSaldo	:= .F.
Local lTpDepr	:= .F.
Local nX

Default lDelet	:= .F.

DbSelectArea("SN3")
DbGoto(nRecnoSN3)

DbSelectArea("SNJ")
SNJ->(DbSetOrder(1))
lTpSaldo	:= .T.
lTpDepr		:= .T.
If lDelet
	If DbSeek(xFilial("SNJ") + cProc + cSeq)
		RecLock("SNJ",.F.,.T.)
		DbDelete()
		MsUnLock()
	EndIf
	nRecno := 0
Else

	If DbSeek(xFilial("SNJ") + cProc + cSeq)
		RecLock("SNJ",.F.)
	Else
		RecLock("SNJ",.T.)
	EndIf

	SNJ->NJ_FILIAL		:= xFilial("SNJ")
	SNJ->NJ_PROC	   	:= cProc
	SNJ->NJ_ITEM		:= cSeq
	SNJ->NJ_BEM		   	:= SN3->N3_CBASE
	SNJ->NJ_ITBEM		:= SN3->N3_ITEM
	SNJ->NJ_TIPO		:= (cTab)->NJ_TIPO
	SNJ->NJ_VLTAX01		:= (cTab)->NJ_VLTAX01
	SNJ->NJ_VLORI01     := (cTab)->NJ_VLORI01
	SNJ->NJ_VLREC01		:= (cTab)->NJ_VLREC01
	SNJ->NJ_VLVEN01     := (cTab)->NJ_VLVEN01
	SNJ->NJ_VLACM01		:= (cTab)->NJ_VLACM01

	If lTpSaldo
		SNJ->NJ_TPSALDO		:= (cTab)->NJ_TPSALDO
	EndIf
	
	If lTpDepr
		SNJ->NJ_TPDEPR		:= (cTab)->NJ_TPDEPR
		SNJ->NJ_PERDEPR		:= (cTab)->NJ_PERDEPR
		SNJ->NJ_VMXDEPR		:= (cTab)->NJ_VMXDEPR
		SNJ->NJ_VLSALV1		:= (cTab)->NJ_VLSALV1
		SNJ->NJ_PRODANO		:= (cTab)->NJ_PRODANO
		SNJ->NJ_PRODMES		:= (cTab)->NJ_PRODMES
		SNJ->NJ_PRODACM		:= (cTab)->NJ_PRODACM
		SNJ->NJ_CODIND	   	:= (cTab)->NJ_CODIND
			
		For nx := 2 to 5
			SNJ->&("NJ_VORIG"+cValToChar(nX))	   	:= (cTab)->&("NJ_VORIG"+cValToChar(nX))
			SNJ->&("NJ_VLVEN"+STRZERO(nX,2))		:= (cTab)->&("NJ_VLVEN"+STRZERO(nX,2))
			SNJ->&("NJ_VLREC"+STRZERO(nX,2))		:= (cTab)->&("NJ_VLREC"+STRZERO(nX,2))
			SNJ->&("NJ_TXDEPR"+cValToChar(nX))		:= (cTab)->&("NJ_TXDEPR"+cValToChar(nX))
			SNJ->&("NJ_VRDACM"+cValToChar(nX))		:= (cTab)->&("NJ_VRDACM"+cValToChar(nX))
		Next nX
		
		If SNJ->(ColumnPos("NJ_CCONTAB")) > 0
			SNJ->NJ_CCONTAB := (cTab)->NJ_CCONTAB
		Endif
		If SNJ->(ColumnPos("NJ_CUSTBEM")) > 0
			SNJ->NJ_CUSTBEM := (cTab)->NJ_CUSTBEM
		Endif
		If SNJ->(ColumnPos("NJ_CDEPREC")) > 0
			SNJ->NJ_CDEPREC	:= (cTab)->NJ_CDEPREC
		Endif
		If SNJ->(ColumnPos("NJ_CCUSTO")) > 0
			SNJ->NJ_CCUSTO	:= (cTab)->NJ_CCUSTO
		Endif
		If SNJ->(ColumnPos("NJ_CCDEPR")) > 0
			SNJ->NJ_CCDEPR	:= (cTab)->NJ_CCDEPR
		Endif 
		If SNJ->(ColumnPos("NJ_CDESP")) > 0
			SNJ->NJ_CDESP 	:= (cTab)->NJ_CDESP
		Endif  
		If SNJ->(ColumnPos("NJ_CCORREC")) > 0
			SNJ->NJ_CCORREC	:= (cTab)->NJ_CCORREC
		Endif
		If SNJ->(ColumnPos("NJ_CCDESP")) > 0
			SNJ->NJ_CCDESP 	:= (cTab)->NJ_CCDESP
		Endif 
		If SNJ->(ColumnPos("NJ_CCCDEP")) > 0
			SNJ->NJ_CCCDEP 	:= (cTab)->NJ_CCCDEP
		Endif 
		If SNJ->(ColumnPos("NJ_CCCDES")) > 0
			SNJ->NJ_CCCDES 	:= (cTab)->NJ_CCCDES
		Endif 
		If SNJ->(ColumnPos("NJ_CCCORR")) > 0
			SNJ->NJ_CCCORR	:= (cTab)->NJ_CCCORR
		Endif
		If SNJ->(ColumnPos("NJ_SUBCTA")) > 0
			SNJ->NJ_SUBCTA	:= (cTab)->NJ_SUBCTA
		Endif 
		If SNJ->(ColumnPos("NJ_SUBCCON")) > 0
			SNJ->NJ_SUBCCON	:= (cTab)->NJ_SUBCCON
		Endif
		If SNJ->(ColumnPos("NJ_SUBCDEP")) > 0
			SNJ->NJ_SUBCDEP	:= (cTab)->NJ_SUBCDEP
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCDE")) > 0
			SNJ->NJ_SUBCCDE	:= (cTab)->NJ_SUBCCDE
		Endif
		If SNJ->(ColumnPos("NJ_SUBCDES")) > 0
			SNJ->NJ_SUBCDES	:= (cTab)->NJ_SUBCDES
		Endif
		If SNJ->(ColumnPos("NJ_SUBCCOR")) > 0
			SNJ->NJ_SUBCCOR	:= (cTab)->NJ_SUBCCOR
		Endif
		If SNJ->(ColumnPos("NJ_CLVL")) > 0
			SNJ->NJ_CLVL	:= (cTab)->NJ_CLVL
		Endif   
		If SNJ->(ColumnPos("NJ_CLVLCON")) > 0
			SNJ->NJ_CLVLCON	:= (cTab)->NJ_CLVLCON
		Endif
		If SNJ->(ColumnPos("NJ_CLVLDEP")) > 0
			SNJ->NJ_CLVLDEP	:= (cTab)->NJ_CLVLDEP
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCDE")) > 0
			SNJ->NJ_CLVLCDE	:= (cTab)->NJ_CLVLCDE
		Endif
		If SNJ->(ColumnPos("NJ_CLVLDES")) > 0
			SNJ->NJ_CLVLDES	:= (cTab)->NJ_CLVLDES
		Endif
		If SNJ->(ColumnPos("NJ_CLVLCOR")) > 0
			SNJ->NJ_CLVLCOR	:= (cTab)->NJ_CLVLCOR
		Endif

	Endif

	If SNJ->(ColumnPos("NJ_PERACM1")) > 0 .and. SNJ->(ColumnPos("NJ_REVACM1")) > 0
		For nx := 1 to 5
			If SNJ->(ColumnPos("NJ_PERACM"+cValToChar(nX))) > 0
				SNJ->&("NJ_PERACM"+cValToChar(nX))	:= (cTab)->&("NJ_PERACM"+cValToChar(nX))
			EndIf
			If SNJ->(ColumnPos("NJ_REVACM"+cValToChar(nX))) > 0 
				SNJ->&("NJ_REVACM"+cValToChar(nX))	   	:= (cTab)->&("NJ_REVACM"+cValToChar(nX))
			EndIf
		Next
	Endif
	If SNJ->(ColumnPos("NJ_TPAJUST")) > 0
		SNJ->NJ_TPAJUST		:= (cTab)->NJ_TPAJUST
	Endif
	If SNJ->(ColumnPos("NJ_CPERREV")) > 0
		SNJ->NJ_CPERREV		:= (cTab)->NJ_CPERREV
	EndIf
	If SNJ->(ColumnPos("NJ_CRECDES")) > 0
		SNJ->NJ_CRECDES		:= (cTab)->NJ_CRECDES
	EndIf	
	
	If SNJ->(ColumnPos("NJ_VLRIMPT")) > 0
		SNJ->NJ_VLRIMPT		:= (cTab)->NJ_VLRIMPT
	EndIf	
	If SNJ->(ColumnPos("NJ_DTAVALI")) > 0
		SNJ->NJ_DTAVALI		:= (cTab)->NJ_DTAVALI
	EndIf
	
	SNJ->(MsUnLock())
	nRecno := SNJ->(RECNO())

	lSeek := SNI->(MsSeek(xFilial("SNI") + cProc))
	If !lSeek
		If SNI->(RecLock("SNI",!lSeek))
			SNI->NI_FILIAL 	:= xFilial("SNI")
			SNI->NI_PROC 	:= cProc
			SNI->(MsUnlock())
		EndIf
	EndIf	
EndIf


RestArea(aAreaSNI)
RestArea(aAreaSNJ)
RestArea(aAreaSN3)
RestArea(aArea)

Return nRecno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFIOAEfetบAutor  ณ Acacio Egas        บ Data ณ  26/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetiva็ใo da Reducao ao valor recuperavel de ativos       บฑฑ
ฑฑบ          ณ  (IAS 36) IFRS. IOA - Impairment of Assets.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IFRS                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATFIOAEfet(nRecnoSNJ,cTab)
//**********************
// Variaveis da fun็ใo *
//**********************
Local i				:= 0
Local nI				:= 0
Local aArea			:= GetArea()
Local aAreaSN3		:= SN3->(GetArea())
Local lRet				:= .T.
Local dDtMovto		:= dDataBase
Local cTpSaldo		:= ""
Local aRecAtf		:= {}

//*************************
// variaveis de Processo  *
//*************************
Local nVlrRec,nTaxa,nDepACM
Local aStru			:= {}
Local aCposZera		:= {}
Local aDados		:= {}
Local __nQuantas	:= If(lMultMoed,AtfMoedas(),5)
Local cMoed			:= ""
//*****************************
// Variaves de Contabilizacao *
//*****************************
Local cTipoGer		:= GetMv( "MV_ATFTIOA", .F., "12" )
Local cPadrao		:= ""
Local dUltDepr		:= GetMV("MV_ULTDEPR")+1
Local aVlrAtual	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Local cIdMov		:= ""
Local lSN3Saldo := .T.
Local cMoedaAtf  := GetMV("MV_ATFMOEDA")
// Verifica็ใo da classifica็ใo de Ativo se sofre deprecia็ใo
Local lAtClDepr 	:= .F.
Local cTpSld		:= ""
Local lTp10			:= .F.
Local lTp01			:= .F.
Local cFIlSN3		:= XFILIAL("SN3")
Local cQrySN3		:= ""
Local cAlsSN3		:= ""
Local lTpSaldo 	:= .F.
Local lBuscSeq	:= .T.
Local lTpDepr		:= .F.
Local aVlrAtf     := {}
Local aVlrTx      := {}
Local aVlrDepACM := {}
Local lOnOff	:= .T.	
Local cRecNoTp10  := ""
Local cTypes10	:= IIF(lIsRussia,AtfNValMod({1}, "|"),"") // CAZARINI - 24/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10	:= {}
Local nTypes10	:= 0
Local cTp10		:= IIF(lIsRussia,(cTab)->NJ_TIPO,"10")
Local cTypes12	:= IIF(lIsRussia,AtfNValMod({2}, "|"),"") // CAZARINI - 07/04/2017 - If is Russia, add new valuations models - recoverable models
Local aTypes12	:= {}
Local nTypes12	:= 0
Local aTp12		:= {}
Local cTp12		:= ""
Local cCCONTAB  := ""
Local cCUSTBEM  := ""
Local cCDEPREC  := ""
Local cCCUSTO 	:= ""
Local cCCDEPR   := ""
Local cCDESP    := ""
Local cCCORREC  := ""
Local cCCDESP   := ""
Local cCCCDEP   := ""
Local cCCCDES   := ""
Local cCCCORR   := ""
Local cSUBCTA   := ""
Local cSUBCCON  := ""
Local cSUBCDEP  := ""
Local cSUBCCDE  := ""
Local cSUBCDES  := ""
Local cSUBCCOR  := ""
Local cCLVL     := ""
Local cCLVLCON  := ""
Local cCLVLDEP  := ""
Local cCLVLCDE  := ""
Local cCLVLDES  := ""
Local cCLVLCOR  := ""
Local cPausaTp  := SuperGetMV("MV_ATFPA01",, "") //Indica o(s) tipo(s) de ativo para pausar a deprecia็ใo.
Local nvlPerRev := 0
Local aVlPerRev := {}
Local aVlrAcuPer:= {}
Local aVlrAcuRev:= {}
Local cPadraoImp:= "894"

If lIsRussia
	aTp12 := ATFNValNM( cTp10 )
	cTp12 := aTp12[01]
EndIf

lOnOff := MV_PAR03 == 1

//***************************
// Posiciona SN3 do tipo 01 *
//***************************
DbSelectArea("SNJ")
SNJ->(DbSetOrder(1))
SNJ->(DbGoto(nRecnoSNJ))

DbSelectArea("SNI")
SNI->(DbSetOrder(1))
SNI->(DbSeek(FWxFilial("SNI") + SNJ->NJ_PROC))

lTpSaldo 	:= .T.

lTpDepr 	:= .T.

If !lTpDepr
	nVlrRec		  := SNJ->NJ_VLREC01
	nTaxa			  := SNJ->NJ_VLTAX01
	nDeprecACM  := SNJ->NJ_VLACM01
Else
	For i:= 1 to __nQuantas
		cMoed := Alltrim(Str(i))
		If SNJ->(FieldPos("NJ_VLREC"+strzero(i,2))) > 0
			aAdd(aVlrAtf,SNJ->&( "NJ_VLREC"+strzero(i,2)) )
			If i == 1
				aAdd(aVlrTx,SNJ->NJ_VLTAX01)
				aAdd(aVlrDepACM,SNJ->NJ_VLACM01) 
			Else
				aAdd(aVlrTx,SNJ->&("NJ_TXDEPR"+cMoed))
				aAdd(aVlrDepACM,SNJ->&("NJ_VRDACM"+cMoed))
			EndIf
			
		EndIf
	Next i
	cTpDepr		:= SNJ->NJ_TPDEPR
	nPerDepr	:= SNJ->NJ_PERDEPR
	nVlSalv1	:= SNJ->NJ_VLSALV1
	nProdAno	:= SNJ->NJ_PRODANO //Produ็ใo Estimada
	nProdMes	:= SNJ->NJ_PRODMES //Produ็ใo do perํodo
	nProdAcm	:= SNJ->NJ_PRODACM //Produ็ใo acumulada
	cCondInd	:= SNJ->NJ_CODIND  //อndice de deprecia็ใo
	nVmxDepr	:= SNJ->NJ_VMXDEPR //Valor mแximo de deprecia็ใo
	
	If SNJ->(ColumnPos("NJ_CCONTAB")) > 0
		cCCONTAB 	:= SNJ->NJ_CCONTAB //Conta Contabil
	Endif           
	If SNJ->(ColumnPos("NJ_CUSTBEM")) > 0
		cCUSTBEM 	:= SNJ->NJ_CUSTBEM //C Custo da Conta do Bem
	Endif
	If SNJ->(ColumnPos("NJ_CDEPREC")) > 0
		cCDEPREC 	:= SNJ->NJ_CDEPREC //Conta Despesa Depreciacao
	Endif
	If SNJ->(ColumnPos("NJ_CCUSTO")) > 0
		cCCUSTO  	:= SNJ->NJ_CCUSTO //Centro de Custo Despesa
	Endif
	If SNJ->(ColumnPos("NJ_CCDEPR")) > 0
		cCCDEPR  	:= SNJ->NJ_CCDEPR //Conta Deprec. Acumulada
	Endif
	If SNJ->(ColumnPos("NJ_CDESP")) > 0
		cCDESP   	:= SNJ->NJ_CDESP  //Cta Correcao Depreciacao
	Endif
	If SNJ->(ColumnPos("NJ_CCORREC")) > 0
		cCCORREC 	:= SNJ->NJ_CCORREC //Conta Correcao Bem
	Endif
	If SNJ->(ColumnPos("NJ_CCDESP")) > 0
		cCCDESP  	:= SNJ->NJ_CCDESP //Centro Custo Desp Depr.
	Endif
	If SNJ->(ColumnPos("NJ_CCCDEP")) > 0
		cCCCDEP  	:= SNJ->NJ_CCCDEP //Centro Custo Dep. Acumul.
	Endif
	If SNJ->(ColumnPos("NJ_CCCDES")) > 0
		cCCCDES		:= SNJ->NJ_CCCDES //Centro Custo Corr. Depr. 
	Endif
	If SNJ->(ColumnPos("NJ_CCCORR")) > 0
		cCCCORR		:= SNJ->NJ_CCCORR //Centro Custo Corr. Monet.
	Endif
	If SNJ->(ColumnPos("NJ_SUBCTA")) > 0
		cSUBCTA		:= SNJ->NJ_SUBCTA //Item Despesa
	Endif
	If SNJ->(ColumnPos("NJ_SUBCCON")) > 0
		cSUBCCON	:= SNJ->NJ_SUBCCON //Item Conta do Bem
	Endif
	If SNJ->(ColumnPos("NJ_SUBCDEP")) > 0
		cSUBCDEP	:= SNJ->NJ_SUBCDEP //Item Despesa Depreciacao 
	Endif
	If SNJ->(ColumnPos("NJ_SUBCCDE")) > 0
		cSUBCCDE	:= SNJ->NJ_SUBCCDE //Item Deprecia็ใo Acm
	Endif
	If SNJ->(ColumnPos("NJ_SUBCDES")) > 0
		cSUBCDES	:= SNJ->NJ_SUBCDES //Item Cor.Des. Depreciacao
	Endif
	If SNJ->(ColumnPos("NJ_SUBCCOR")) > 0
		cSUBCCOR	:= SNJ->NJ_SUBCCOR //Item Correcao Monetaria
	Endif
	If SNJ->(ColumnPos("NJ_CLVL")) > 0
		cCLVL		:= SNJ->NJ_CLVL   //Classe de Valor Despesa
	Endif
	If SNJ->(ColumnPos("NJ_CLVLCON")) > 0
		cCLVLCON	:= SNJ->NJ_CLVLCON //Classe de Valor do Bem
	Endif
	If SNJ->(ColumnPos("NJ_CLVLDEP")) > 0
		cCLVLDEP	:= SNJ->NJ_CLVLDEP //Classe Vlr Despesa Dep.
	Endif
	If SNJ->(ColumnPos("NJ_CLVLCDE")) > 0
		cCLVLCDE	:= SNJ->NJ_CLVLCDE //Classe de Vlr Dep. Acum.
	Endif
	If SNJ->(ColumnPos("NJ_CLVLDES")) > 0
		cCLVLDES	:= SNJ->NJ_CLVLDES //Classe de Vlr Cor. Depr. 
	Endif
	If SNJ->(ColumnPos("NJ_CLVLCOR")) > 0
		cCLVLCOR	:= SNJ->NJ_CLVLCOR //Classe de Vlr Correc Bem 
	Endif

Endif

//****************
// Posiciona SN1 *
//****************

If ALLtrim(cTipoGer) $ ('12' + "|" + cTypes12)
	cPadrao := "80A"
Else
	cPadrao := "801"
EndIf

// verifica se o valor foi alterado
If SNJ->NJ_VLREC01 <> SNJ->NJ_VLORI01
	If SNJ->(ColumnPos("NJ_TPAJUST")) > 0 .and. SNJ->(ColumnPos("NJ_PERACM1")) > 0 .and. SNJ->(ColumnPos("NJ_REVACM1")) > 0
		If SNJ->NJ_TPAJUST == '1' // Ajuste de Perda/Reversใo CPC01
			nvlPerRev	:= SNJ->NJ_VLORI01 - SNJ->NJ_VLREC01 //Valor Perda/Reversao
			aAdd(aVlPerRev,nvlPerRev )
			aAdd(aVlrAcuPer  ,SNJ->NJ_PERACM1+ Iif(nvlPerRev>=0,nvlPerRev,0))
			aAdd(aVlrAcuRev  ,SNJ->NJ_REVACM1+ Iif(nvlPerRev<0,Abs(nvlPerRev),0)) 
			For i:= 2 to 5
				cMoed := Alltrim(Str(i))	
				If SNJ->(ColumnPos( "NJ_PERACM"+cMoed)) > 0	.and. SNJ->(ColumnPos("NJ_REVACM"+cMoed)) > 0		
					aAdd(aVlPerRev   ,SNJ->&( "NJ_VORIG"+cMoed) - SNJ->&( "NJ_VLREC"+strzero(i,2)) )				
					aAdd(aVlrAcuPer  ,SNJ->&( "NJ_PERACM"+cMoed) + Iif(aVlPerRev[i]>=0,aVlPerRev[i],0)) 
					aAdd(aVlrAcuRev  ,SNJ->&( "NJ_REVACM"+cMoed) + Iif(aVlPerRev[i]<0,Abs(aVlPerRev[i]),0))
				EndIf
			Next i	
		Else
			aAdd(aVlrAcuPer  ,SNJ->NJ_PERACM1)
			aAdd(aVlrAcuRev  ,SNJ->NJ_REVACM1) 
			For i:= 2 to 5
				cMoed := Alltrim(Str(i))
				If SNJ->(ColumnPos( "NJ_PERACM"+cMoed)) > 0	.and. SNJ->(ColumnPos("NJ_REVACM"+cMoed)) > 0								
					aAdd(aVlrAcuPer  ,SNJ->&( "NJ_PERACM"+cMoed) ) 
					aAdd(aVlrAcuRev  ,SNJ->&( "NJ_REVACM"+cMoed) )
				EndIf
			Next i			
		EndIf
	EndIf

	DbSelectArea("SN1")
	SN1->(DbSetOrder(1)) // Filial + C?igo Base + Item
	If DbSeek(xFilial("SN1") + SNJ->NJ_BEM + SNJ->NJ_ITBEM)
		aTypes10 := Separa(cTypes10, '|', .f.)

		If lIsRussia
			lTp10 := SN3->(dbSeek( cFIlSN3 + SN1->N1_CBASE + SN1->N1_ITEM + "10" ))
			If !lTp10
				For nTypes10 := 1 to len(aTypes10)
					lTp10 := SN3->(dbSeek( cFIlSN3 + SN1->N1_CBASE + SN1->N1_ITEM + aTypes10[nTypes10] ))
					If lTp10
						exit
					Endif
				Next nTypes10
			Endif
		Else
			lTp10 := SN3->(dbSeek( cFIlSN3 + SN1->N1_CBASE + SN1->N1_ITEM + "10"+"0" ))
			If lTp10 .And. ( !Empty(cPausaTp) .And. "10" $ cPausaTp ) .And. lIsBrasil .And. cTipoGer == "12"
				If SN3->(ColumnPos('N3_DTBLOQ')) > 0 .And. Empty(SN3->N3_DTBLOQ)
					RecLock('SN3', .F.)
						SN3->N3_DTBLOQ := dDataBase
					SN3->(MSUnlock())
				EndIf
			EndIf
		EndIf

		lTp01 := SN3->(dbSeek( cFIlSN3 + SN1->N1_CBASE + SN1->N1_ITEM + "01" ))
		If lTp01 .And. ( !Empty(cPausaTp) .And. "01" $ cPausaTp ) .And. lIsBrasil .And. cTipoGer == "12"
			If SN3->(ColumnPos('N3_DTBLOQ')) > 0 .And. Empty(SN3->N3_DTBLOQ)
				RecLock('SN3', .F.)
					SN3->N3_DTBLOQ := dDataBase
				SN3->(MSUnlock())
			EndIf
		EndIf

		If lIsRussia
			aTypes12 := Separa( cTypes12, '|', .f.)
			Aadd( aTypes12, cTipoGer)
		EndIF
		
		If lIsRussia
			For nTypes12 := 1 to len(aTypes12)
				If SN3->(dbSeek( cFIlSN3 + SN1->N1_CBASE + SN1->N1_ITEM + aTypes12[nTypes12] + "0" ))
					While SN3->(!Eof() .AND. cFIlSN3 + SN1->N1_CBASE + SN1->N1_ITEM + aTypes12[nTypes12] + "0" == SN3->(N3_FILIAL + N3_CBASE + N3_ITEM + N3_TIPO) + "0")
						If (lTpSaldo  .AND. SN3->N3_TPSALDO == SNJ->NJ_TPSALDO) .OR. !lTpSaldo
							lRet := AF380BaixAc( cFIlSN3,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,@cIdMov)
							Exit
						EndIf
						SN3->(DbSkip())
					EndDo
				ElseIf !lTp10 .AND. !lTp01
					lRet := .F.
				EndIf
			Next nTypes12
		Else
			// se nao tem tipo 01 nem 10 lRet eh .F.
			lRet := IIf(!lTp10 .And. !lTp01, .F., .T.)
			
			// tenho tipos de saldos informado no parametro MV_ATFTIOA
			If SN3->(dbSeek( cFIlSN3 + SN1->N1_CBASE + SN1->N1_ITEM + cTipoGer))
				
				// enquanto for saldo do mesmo ativo
				While cFIlSN3+SN1->(N1_CBASE+N1_ITEM)+cTipoGer == SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO) ;
						.And. !SN3->(Eof())
						
					// se for o tipo de saldo que marquei e ainda nao foi baixado baixa
					If SN3->N3_TPSALDO == SNJ->NJ_TPSALDO .And. SN3->N3_BAIXA == "0"
						lRet := AF380BaixAc( cFIlSN3,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,@cIdMov)
						cRecNoTp10 += cValToChar( SN3->( RecNo() ) ) + "|"
						Exit
					EndIf
					
					SN3->(DbSkip())
				EndDo
				
			EndIf
		EndIf
		
		If lRet
			//****************
			// copia do SN3  *
			//****************
			aStru 		:= SN3->(dbStruct())
			aCposZera	:= {"N3_VRDME","N3_VRDBA","N3_VLACE","N3_VRCME","N3_VRCBA","N3_VRCAC",;
				"N3_VRCDA","N3_BAIXA","N3_DTBAIXA","N3_IDBAIXA"}
			
			cAlsSN3 := GetNextAlias()
			
			If Select(cAlsSN3) > 0
				(cAlsSN3)->(dbCloseArea())
			EndIf
			
			cQrySN3 := "SELECT "
			For i := 1 to Len(aStru)
				If i == 1
					cQrySN3 +=  "SN3." + aStru[i,1]
				Else
					cQrySN3 +=  ", SN3." + aStru[i,1]
				EndIf
			Next i
			cQrySN3 += " FROM " + RetSqlName("SN3") + " SN3 "
			cQrySN3 += " WHERE "
			cQrySN3 += " SN3.N3_FILIAL 		= '" + cFIlSN3 + 		"' "
			cQrySN3 += " AND SN3.N3_CBASE	= '" + SN1->N1_CBASE + 	"' "
			cQrySN3 += " AND SN3.N3_ITEM	= '" + SN1->N1_ITEM	+ 	"' "
			If lTp01 .AND. !lTp10
				cQrySN3 += " AND SN3.N3_TIPO	= '01' "
			Else
				cQrySN3 += " AND SN3.N3_TIPO	= '10' "
			EndIf

			//Quando jแ existem registros do TP10 e o sistema se baseiou no TP10 para a gera็ใo, os mesmo jแ foram baixados, por isso ้ necessแrio buscar os jแ baixados durante a rotina, por RecNo
			If lTp10 .And. !Empty( cRecNoTp10 ) .And. cTipoGer = '10'
				cQrySN3 += " AND SN3.N3_BAIXA = '1' "
				cQrySN3 += " AND SN3.R_E_C_N_O_ IN " + FormatIn( SubStr( cRecNoTp10 , 1 , Len( cRecNoTp10 ) - 1 ) , '|' ) 
			Else
				cQrySN3 += " AND SN3.N3_BAIXA = '0' "
			EndIf

			If lTpSaldo
				cQrySN3 += " AND SN3.N3_TPSALDO = '" + SNJ->NJ_TPSALDO + " '"
			EndIf
			If lIsRussia
				cQrySN3 += " AND SN3.N3_OPER = '1' " // CAZARINI - 22.01.2017 - Asset Into Operation?	
			Endif
			cQrySN3 += " AND SN3.D_E_L_E_T_ = ' ' "

			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQrySN3 ), cAlsSN3, .T.,.F. )
			aEval(aStru, {|e| If(e[2] != "C", TCSetField(cAlsSN3, e[1], e[2],e[3],e[4]),Nil)})
					
			While (cAlsSN3)->(!Eof())
				cSeq		:= (cAlsSN3)->N3_SEQ
				dDinDepr	:= (cAlsSN3)->N3_DINDEPR
				If lTpSaldo
					cTpSld		:= (cAlsSN3)->N3_TPSALDO
				EndIf
				
				aDados		:= {}
				For i := 1 to Len(aStru)
					If aScan(aCposZera, {|x| x $ aStru[i,1]} ) == 0
						AAdd(aDados,{ aStru[i,1] , (cAlsSN3)->&(aStru[i,1]) })
					Else
						AAdd(aDados,{ aStru[i,1] , CriaVar( aStru[i,1] , .F. ) })
					EndIf
				Next i
			
				For i := 1 to __nQuantas
					If i == 1
						aVlrAtual[i] := nVlrRec
					Else
						aVlrAtual[i] := 0
					EndIf
				Next i
						
				SN3->(Reclock("SN3",.T.))
				For nI := 1 to Len(aDados)
					SN3->(&(aDados[nI][1])) := aDados[nI][2]
				Next nX
				If lIsRussia
					If cTp10 == "10"
						SN3->N3_TIPO  		:= cTipoGer
					Else
						SN3->N3_TIPO  		:= cTp12
					Endif
				Else
					SN3->N3_TIPO  		:= cTipoGer
					If !Empty(cPausaTp) .And. SN3->(ColumnPos("N3_DTBLOQ")) > 0
						SN3->N3_DTBLOQ	:= cToD('')
					Endif
				EndIf

				If 	ExistBlock("AF380HIST")
					SN3->N3_HISTOR := ExecBlock( "AF380HIST", .F., .F. )
				Else
					SN3->N3_HISTOR := STR0059 //"RED. AO VALOR RECUPERAVEL"
				EndIf
				SN3->N3_DINDEPR	:= dDinDepr
				SN3->N3_AQUISIC	:= (cAlsSN3)->N3_AQUISIC
				
				If lTpSaldo
					SN3->N3_TPSALDO	:= cTpSld
				EndIf
				
				If lBuscSeq .AND. lTpSaldo
					cSeq := AF380UTSEQ((cAlsSN3)->N3_FILIAL,(cAlsSN3)->N3_CBASE,(cAlsSN3)->N3_ITEM,(cAlsSN3)->N3_TPSALDO)
				Else
					cSeq := Soma1(cSeq)
				EndIf
				
				SN3->N3_SEQ		:= cSeq
				SN3->N3_BAIXA 	:= '0'
				SN3->N3_DTBAIXA := STOD("")
				SN3->N3_FIMDEPR := STOD("")
				
				If  lTpDepr
					SN3->N3_TPDEPR 	:= cTpDepr
					SN3->N3_PERDEPR := nPerDepr
					SN3->N3_VLSALV1 := nVlSalv1
					SN3->N3_PRODANO := nProdAno	//Produ็ใo Estimada
					SN3->N3_PRODMES := nProdMes	//Produ็ใo do perํodo
					SN3->N3_PRODACM := nProdAcm	//Produ็ใo acumulada
					SN3->N3_CODIND 	:= cCondInd	//อndice de deprecia็ใo
					SN3->N3_VMXDEPR := nVmxDepr	//Valor mแximo de deprecia็ใo
					If SNJ->(ColumnPos("NJ_CCONTAB")) > 0
						SN3->N3_CCONTAB	:= cCCONTAB	//Conta Contabil
					Endif
					If SNJ->(ColumnPos("NJ_CUSTBEM")) > 0
						SN3->N3_CUSTBEM	:= cCUSTBEM	//C Custo da Conta do Bem
					Endif  	
					If SNJ->(ColumnPos("NJ_CDEPREC")) > 0
						SN3->N3_CDEPREC	:= cCDEPREC	//Conta Despesa Depreciacao	
					Endif
					If SNJ->(ColumnPos("NJ_CCUSTO")) > 0
						SN3->N3_CCUSTO 	:= cCCUSTO 	//Centro de Custo Despesa
					Endif  	
					If SNJ->(ColumnPos("NJ_CCDEPR")) > 0
						SN3->N3_CCDEPR 	:= cCCDEPR 	//Conta Deprec. Acumulada
					Endif  	
					If SNJ->(ColumnPos("NJ_CDESP")) > 0
						SN3->N3_CDESP  	:= cCDESP  	//Cta Correcao Depreciacao 
					Endif	
					If SNJ->(ColumnPos("NJ_CCORREC")) > 0
						SN3->N3_CCORREC	:= cCCORREC	//Conta Correcao Bem
					Endif      	
					If SNJ->(ColumnPos("NJ_CCDESP")) > 0
						SN3->N3_CCDESP 	:= cCCDESP 	//Centro Custo Desp Depr.
					Endif
					If SNJ->(ColumnPos("NJ_CCCDEP")) > 0
						SN3->N3_CCCDEP 	:= cCCCDEP 	//Centro Custo Dep. Acumul.
					Endif	
					If SNJ->(ColumnPos("NJ_CCCDES")) > 0
						SN3->N3_CCCDES 	:= cCCCDES 	//Centro Custo Corr. Depr.
					Endif 	
					If SNJ->(ColumnPos("NJ_CCCORR")) > 0
						SN3->N3_CCCORR 	:= cCCCORR 	//Centro Custo Corr. Monet.
					Endif	
					If SNJ->(ColumnPos("NJ_SUBCTA")) > 0
						SN3->N3_SUBCTA 	:= cSUBCTA 	//Item Despesa
					Endif
					If SNJ->(ColumnPos("NJ_SUBCCON")) > 0
						SN3->N3_SUBCCON	:= cSUBCCON	//Item Conta do Bem
					Endif
					If SNJ->(ColumnPos("NJ_SUBCDEP")) > 0
						SN3->N3_SUBCDEP	:= cSUBCDEP	//Item Despesa Depreciacao
					Endif
					If SNJ->(ColumnPos("NJ_SUBCCDE")) > 0
						SN3->N3_SUBCCDE	:= cSUBCCDE	//Item Deprecia็ใo Acm
					Endif
					If SNJ->(ColumnPos("NJ_SUBCDES")) > 0
						SN3->N3_SUBCDES	:= cSUBCDES	//Item Cor.Des. Depreciacao
					Endif	
					If SNJ->(ColumnPos("NJ_SUBCCOR")) > 0
						SN3->N3_SUBCCOR	:= cSUBCCOR	//Item Correcao Monetaria
					Endif
					If SNJ->(ColumnPos("NJ_CLVL")) > 0
						SN3->N3_CLVL   	:= cCLVL   	//Classe de Valor Despesa
					Endif
					If SNJ->(ColumnPos("NJ_CLVLCON")) > 0
						SN3->N3_CLVLCON	:= cCLVLCON	//Classe de Valor do Bem
					Endif
					If SNJ->(ColumnPos("NJ_CLVLDEP")) > 0
						SN3->N3_CLVLDEP	:= cCLVLDEP	//Classe Vlr Despesa Dep.
					Endif
					If SNJ->(ColumnPos("NJ_CLVLCDE")) > 0
						SN3->N3_CLVLCDE	:= cCLVLCDE	//Classe de Vlr Dep. Acum.
					Endif
					If SNJ->(ColumnPos("NJ_CLVLDES")) > 0
						SN3->N3_CLVLDES	:= cCLVLDES	//Classe de Vlr Cor. Depr.
					Endif
					If SNJ->(ColumnPos("NJ_CLVLCOR")) > 0
						SN3->N3_CLVLCOR	:= cCLVLCOR	//Classe de Vlr Correc Bem.
					Endif
				
					For i:= 1 to Len(aVlrAtf)
						cMoed := Alltrim(Str(i))
						SN3->&("N3_VORIG" +cMoed)						:= aVlrAtf[i]
						SN3->&(If(i>9,"N3_TXDEP","N3_TXDEPR")+cMoed)	:= aVlrTx[i]
						SN3->&(If(i>9,"N3_VRDAC","N3_VRDACM")+cMoed)	:= aVlrDepACM[i]
					Next i
				Else
					For i:= 1 to __nQuantas
						cMoed := Alltrim(Str(i))
						If i==1
							SN3->N3_VORIG1	:= nVlrRec
							SN3->N3_TXDEPR1	:= nTaxa
							SN3->N3_VRDACM1	:= nDeprecACM
						Else
							SN3->&("N3_VORIG" +cMoed)						:= 0
							SN3->&(If(i>9,"N3_TXDEP","N3_TXDEPR")+cMoed)	:= 0
							SN3->&(If(i>9,"N3_VRDAC","N3_VRDACM")+cMoed)	:= 0
						Endif
					Next i
				Endif
		
				If SNJ->(ColumnPos("NJ_TPAJUST")) > 0 .and. SN3->(FieldPos("N3_PERACM1")) > 0 .and. SN3->(FieldPos("N3_REVACM1")) > 0						
					For i:= 1 to Len(aVlrAcuPer)
						cMoed := Alltrim(Str(i))
						If SN3->(FieldPos("N3_PERACM"+cMoed)) > 0 .and. SN3->(FieldPos("N3_REVACM"+cMoed)) > 0
							SN3->&("N3_PERACM" +cMoed) := aVlrAcuPer[i]
							SN3->&("N3_REVACM" +cMoed) := aVlrAcuRev[i]					
						EndIf
					Next i																		
				EndIf
				SN3->(MsUnlock())

				If SNJ->(ColumnPos("NJ_SEQSN3")) > 0
					If SNJ->(Reclock("SNJ",.F.))
						SNJ->NJ_SEQSN3 := SN3->N3_SEQ
						SNJ->(MsUnlock())
					EndIf
				EndIf
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณMovimento de Aquisi็ใoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cOcorr 	   := "05"
				aDadosComp := ATFXCompl( 0 , &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+'1'),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
				aValorMoed := AtfMultMoe(,,{|x| SN3->&("N3_VORIG" + Alltrim(Str(x)) ) })
				If lSN3Saldo
					cTpSaldo := SN3->N3_TPSALDO
				EndIf
				ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"1",SN1->N1_QUANTD,cTpSaldo,,aValorMoed,aDadosComp,,.T.,,,lOnOff,cPadrao)
				
				Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Atualiza arquivo movimentao (Correo)                               ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				IF SN3->N3_VRCACM1 > 0
					cOcorr 	   := "07"
					aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+'1'),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
					aValorMoed   := If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
					aValorMoed[1] := Round(SN3->N3_VRCACM1 , X3Decimal("N4_VLROC1") )
					If lSN3Saldo
						cTpSaldo := SN3->N3_TPSALDO
					EndIf
					ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"1",0,cTpSaldo,,aValorMoed,aDadosComp,,,,,lOnOff,cPadrao)
					
					Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
				EndIF
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Atualiza arquivo movimentao (Correo)                               ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				IF SN3->N3_VRCACM1 > 0
					cOcorr 	   := "07"
					aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+'1'),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
					aValorMoed   := If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
					aValorMoed[1] := Round(SN3->N3_VRCACM1 , X3Decimal("N4_VLROC1") )
					If lSN3Saldo
						cTpSaldo := SN3->N3_TPSALDO
					EndIf
					ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"2",0,cTpSaldo,,aValorMoed,aDadosComp,,,,,lOnOff,cPadrao)
					
					Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
				EndIf
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Atualiza arquivo Movimenta”es (Correo da Depreciao)               ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				IF SN3->N3_VRCDA1 > 0
					cOcorr 	   := "08"
					aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+'1'),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
					aValorMoed   := If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
					aValorMoed[1] := Round(SN3->N3_VRCDA1 , X3Decimal("N4_VLROC1") )
					If lSN3Saldo
						cTpSaldo := SN3->N3_TPSALDO
					EndIf
					ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"5",0,cTpSaldo,,aValorMoed,aDadosComp,,,,,lOnOff,cPadrao)
					
					Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
				EndIf
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Atualiza arquivo Movimenta”es (Depreciao)                           ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				IF &('SN3->N3_VRDACM1') > 0
					cOcorr 	   := IIF( SN3->N3_TIPO $ ("10,12,50,51,52,53,54" + "," + cTypes10) , "20", IIF(SN3->N3_TIPO == "07","10",IIF(SN3->N3_TIPO=="08","12",IIF(SN3->N3_TIPO == "09","11","06"))))
					aDadosComp := ATFXCompl( SN3->N3_VRDACM1 / &(If(Val(cMoedaAtf)>9,'SN3->N3_VRDAC','SN3->N3_VRDACM')+'1') , &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+'1'),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
					aValorMoed := AtfMultMoe(,,{|x| SN3->&(IIf(x>9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) })
					If lSN3Saldo
						cTpSaldo := SN3->N3_TPSALDO
					EndIf
					ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"4",0,cTpSaldo,,aValorMoed,aDadosComp,,.T.,,,lOnOff,cPadrao)
					
					Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
				EndIf
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Atualiza arquivo Movimenta”es (Correo da Depreciao)               ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				IF SN3->N3_VRCDA1 > 0
					cOcorr 	   := "08"
					aDadosComp := ATFXCompl( 0 , &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+'1'),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
					aValorMoed := AtfMultMoe(,,{|x| SN3->&(IIf(x>9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) })
					If lSN3Saldo
						cTpSaldo := SN3->N3_TPSALDO
					EndIf
					ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"4",0,cTpSaldo,,aValorMoed,aDadosComp,,Inclui,,,lOnOff,cPadrao)
					
					Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
				EndIf
				
				// Verifica็ใo da classifica็ใo de Ativo se sofre deprecia็ใo
				lAtClDepr := AtClssVer(SN1->N1_PATRIM)
				
				//Grava os Saldos
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava no SN5 o tipo da Imobilizao.                    ณ
				//ณ Se for imobilizao normal             = 1              ณ
				//ณ Se                  Reavalio         = 3              ณ
				//ณ Se                  Capital            = A              ณ
				//ณ Se                  Capital Prejuizo   = B              ณ
				//ณ Se Baixa Capital                       = C              ณ
				//ณ Se ""               Capital Prejuizo   = D              ณ
				//ณ Se ""               Correcao de Capital= P              ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
				IF lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)
					cTipoImob := Iif(SN3->N3_TIPO$"02/05","3","1")
					cTipoCorr := "6"
				Elseif SN1->N1_PATRIM $ "CSA"
					cTipoImob := "A"
					cTipoCorr := "O"
				Else
					cTipoImob := "B"
					cTipoCorr := "6"
				End
				
				If !(SN3->N3_TIPO $ "07,08,09")
					//********************************
					// Controle de multiplas moedas  *
					//********************************
					If lMultMoed
						aValorMoed := AtfMultMoe("SN3","N3_VORIG")
					EndIf
					ATFSaldo(	SN3->N3_CCONTAB,dDtMovto,cTipoImob,SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3,SN3->N3_VORIG4,SN3->N3_VORIG5,"+",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
					//********************************
					// Controle de multiplas moedas  *
					//********************************
					If lMultMoed
						aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
					EndIf
					ATFSaldo(	SN3->N3_CCONTAB,dDtMovto,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,"+",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
				Endif
				//********************************
				// Controle de multiplas moedas  *
				//********************************
				If lMultMoed
					aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
				EndIf
				ATFSaldo(	SN3->N3_CCORREC,dDtMovto,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,"+",,SN3->N3_SUBCCOR,,SN3->N3_CLVLCOR,SN3->N3_CCCORR,"2", aValorMoed )
		
				IF lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)
					cTipoImob := If( !SN3->N3_TIPO $ ("08,09,10,12,50,51,52,53,54" + "," + cTypes10), "4", If(SN3->N3_TIPO $ ("10,12,50,51,52,53,54" + "," + cTypes10),"Y",If(SN3->N3_TIPO=="09","L","K")))
					//********************************
					// Controle de multiplas moedas  *
					//********************************
					If lMultMoed
						aValorMoed := AtfMultMoe("SN3","N3_VRDACM")
					EndIf
					ATFSaldo(	SN3->N3_CCDEPR ,dDtMovto,cTipoImob, SN3->N3_VRDACM1,SN3->N3_VRDACM2  ,;
						SN3->N3_VRDACM3,SN3->N3_VRDACM4,SN3->N3_VRDACM5 ,"+",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )
					//********************************
					// Controle de multiplas moedas  *
					//********************************
					If lMultMoed
						aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCDA1,0) })
					EndIf
					ATFSaldo(	SN3->N3_CCDEPR ,dDtMovto,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
						"+",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )
					//********************************
					// Controle de multiplas moedas  *
					//********************************
					If lMultMoed
						aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCDA1,0) })
					EndIf
					ATFSaldo(	SN3->N3_CDESP  ,dDtMovto,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
						"+",,SN3->N3_SUBCDES,,SN3->N3_CLVLDES,SN3->N3_CCCDES,"5", aValorMoed )
				Endif
				
				If lOnOff
					If VerPadrao(cPadrao) 
						nTotal += DetProva(nHdlPrv,cPadraoBai,"ATFA380",cLoteAtf)
						nTotal += DetProva(nHdlPrv,cPadrao,"ATFA380",cLoteAtf)
					Endif
					If VerPadrao(cPadraoImp) 
						nTotal += DetProva(nHdlPrv,cPadraoImp,"ATFA380",cLoteAtf)
					EndIf
				EndiF
				(cAlsSN3)->(DbSkip())
			EndDo
			
			If Select(cAlsSN3) > 0
				(cAlsSN3)->(dbCloseArea())
			EndIf
			
		EndIf
	Else
		Help("  ",1,"") // bem nใo encontrado
	EndIf
EndIf

RestArea(aAreaSN3)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA380LIN บAutor  ณMicrosiga           บ Data ณ  03/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo do LINOK                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA380LIN(nAt,lHelp)
Local aCols	  	  	:= oGetSNJ:aCols
Local aHeader  		:= oGetSNJ:aHeader
Local nPosVorig	 	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_VLORI01" })
Local nPosVlRec	 	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_VLREC01" })
Local nPosVAcm 		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_VLACM01" })
Local nCpoBem 		:= aScan(aHeader, {|x| Alltrim(x[2]) == "NJ_BEM"	 })
Local nCpoItBem		:= aScan(aHeader, {|x| Alltrim(x[2]) == "NJ_ITBEM"   })
Local nCpoCAcm		:= aScan(aHeader, {|x| Alltrim(x[2]) == "NJ_CCDEPR"  }) //Conta Deprec. Acumulada  
Local nCpovlOri		:= aScan(aHeader, {|x| Alltrim(x[2]) == "NJ_VLORI01" })
Local nCpovlAcu		:= aScan(aHeader, {|x| Alltrim(x[2]) == "NJ_VLACM01" })
Local nPosVmxDp		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_VMXDEPR" })
Local nPosTipDp		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_TPDEPR" })
Local nPosTPAjus	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_TPAJUST" })
Local nPosPerAcm	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_PERACM1" })
Local nPosRevAcm	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_REVACM1" })
Local nPosCntImp	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_CPERREV" })
Local nPosRecDes	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_CRECDES" })
Local nPosTipo  	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_TIPO" })
Local nPosDtAval	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_DTAVALI" })
Local cPadraoImp    := "894"
Local aAreaSN4		:= SN4->(GetArea())

Local lRet 			:= .T.
Local lTpDepr		:= .T.
Local nVlrPerRev	:= 0
Local dUltDepr	    := SuperGetMV("MV_ULTDEPR",.F.,STOD("19800101"))
Local lOcorr		:= .F.
Local cFilSN4		:= FwxFilial("SN4")

Default nAt 	:= oGetSNJ:nAt
Default lHelp 	:= .T.
If  !(aCols[nAt][Len(aHeader) + 1])

	If lRet .And. Empty(aCols[nAT][nPosVlRec]) 
		lRet := .F.
		If lHelp
			Help("AF380Rec",1,"HELP","AF380Rec",STR0136+cvalTochar(nAT)+STR0137,2,0) //"Valor recuperแvel "##" com valor invalido "
		EndIf
	EndIf
	
	If lRet .And. aCols[nAT][nPosVlRec] < aCols[nAT][nPosVAcm]
		lRet := .F.
		If lHelp
			Help("AF380PER",1,"HELP","AF380PER",STR0147+cvalTochar(nAT)+STR0137,2,0,NIL, NIL, NIL, NIL, NIL, {STR0151}) //"Valor de Perda do Item: "##" com valor invalido " "Valor de perda n? pode ser maior que Saldo a Depreciar"
		EndIf
	EndIf
	
	If lRet .And. ATFXVerPrj(aCols[nAT][nCpoBem],aCols[nAT][nCpoItBem], lHelp )
		lRet := .F.
	EndIf   
	
	If lTpDepr .And. lRet  ///Executa esta parte se estiver com os campos novos.
		If !ATF380VlTpDep(aCols[nAT],aHeader,lHelp,nAT)
			lRet := .F.
		EndIf	
	EndIf

	If nCpoCAcm > 0
		If lRet .And. aCols[nAT][nPosVAcm] > 0 .AND. Empty(aCols[nAT][nCpoCAcm])
			lRet := .F.
			If lHelp
				Help(' ', NIL, "AF380CACM", NIL, STR0144 + STR0145, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0146}) //ษ obrigatorio o preenchimento da Conta Deprec. Acumulada se o valor de depreciacao acumulada foi informado. - Preencha a Conta Deprec. Acumulada.
			EndIf
		EndIf
	Endif

	If lRet .and. nPosDtAval > 0 .and. !Empty(aCols[nAT][nPosDtAval])
		dIniDepr := GetAdvFVal("SN3","N3_AQUISIC", xFilial("SN3") + aCols[nAT][nCpoBem]+aCols[nAT][nCpoItBem] + aCols[nAT][nPosTipo] ,1)
		If aCols[nAT][nPosDtAval] < dIniDepr
			lRet := .F.
			If lHelp
				Help(' ', NIL, "AF380DTAVAL", NIL, STR0177, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0178}) //"Data de Avalia็ใo invแlida"#"Informe uma data maior que a aquisi็ใo do bem"
			EndIf
		EndIf
	EndIf
	
	If nPosTPAjus > 0 .and. aCols[nAT][nPosTPAjus] == '1'
		If VerPadrao(cPadraoImp) .And. IsInCallStack("AFA380TOK")
			If lRet
				If lRet .and. ((nPosCntImp > 0 .and. Empty(aCols[nAT][nPosCntImp])) .or. (nPosRecDes > 0 .and. Empty(aCols[nAT][nPosRecDes])))
					cMsgConta += cValTochar(nAT)+", "							
				EndIf
			EndIf
		EndIf
		If lRet .and. aCols[nAT][nPosVlRec] <> 0 .and. aCols[nAT][nPosVorig] > 0
			nVlResid := Iif(aCols[nAT][nPosTipDp] == '7',aCols[nAT][nPosVmxDp],aCols[nAT][nCpovlOri])
			nSldCont :=  Round(nVlResid - aCols[nAT][nCpovlAcu],2)		
			nVlrPerRev   :=  nVlResid - aCols[nAT][nPosVlRec] 
			If nVlrPerRev <= 0		
				nVlTot := aCols[nAT][nPosPerAcm] - aCols[nAT][nPosRevAcm]
				If lRet .AND. Abs(nVlrPerRev) > nVlTot //1บ Limitador de Reversใo
					lRet := .F.
					If lHelp
						Help("AF380REV",1,"HELP","AF380REV",STR0148+cvalTochar(nAT)+STR0137,2,0,NIL, NIL, NIL, NIL, NIL, {STR0149})  //"Valor reversใo "##" com valor invalido " " Valor da somatoria de reversao nใo pode ser maior que a somแtoria de perda."
					EndIf
				EndIf
				If  lRet
					nVal   := AF380REVER(aCols[nAT][nCpoBem],aCols[nAT][nCpoItBem],"1")[LIMITE]
					
					If nVal < 0 .or. (nVal > 0  .AND. Abs(nVlrPerRev) > nVal )
						lRet := .F.
						If lHelp	
							Help("AF380REV",1,"HELP","AF380REV",STR0148+cvalTochar(nAT)+STR0137,2,0,NIL, NIL, NIL, NIL, NIL, {STR0150})  //"Valor reversใo  "##" com valor invalido " "Valor de reversใo deve ser menor que Saldo a Depreciar definido pelo 2บ limitador de reversใo conforme CPC01."" 
						EndIf
					Endif
				EndIf
			EndIf
		Endif
	EndIf

	If lEfetImp
		dbSelectArea("SN4")
		SN4->(DbSetOrder(1))
		SN4->(dbSeek( cFilSN4 + aCols[nAT][nCpoBem] + aCols[nAT][nCpoItBem] + aCols[nAT][nPosTipo] + Dtos(dULTDEPR),.T.))
		While SN4->(!EOF()) .And. SN4->N4_FILIAL ==  cFilSN4 .And. ;
				SN4->N4_CBASE	==  aCols[nAT][nCpoBem]	.And. ;
				SN4->N4_ITEM	==  aCols[nAT][nCpoItBem]	.And. ;
				SN4->N4_TIPO	==  aCols[nAT][nPosTipo]
			IF SN4->N4_DATA > dDatabase
				lOcorr := .T.
				Exit
			EndIf
			SN4->(dbSkip())
		EndDo
		If lOcorr
			lRet:= .F.
			If lHelp
				Help("AF380DATA",1,"HELP","AF380DATA",STR0156,2,0,NIL, NIL, NIL, NIL, NIL, {STR0157+cValtoChar(nAT)+ " - " +aCols[nAT][nCpoBem]+ "/"+aCols[nAT][nCpoItBem]})  //"Data do movimento nใo pode ser anterior a data do ๚ltimo movimento do bem."## Verifique as movimenta็๕es ou a database do sistema e tente novamente para o bem, no item: ##			
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSN4)

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA380TOK บAutor  ณAlvaro Camillo Neto   Data ณ  08/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tudo OK da rotina                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AFA380TOK(nOpc)
Local lRet 		  := .T.
Local nX	  	  := 0
Local aCols	  	  := oGetSNJ:aCols 

DEFAULT nOpc := INCLUIR

If nOpc == VISUALIZAR .OR. nOpc == EXCLUIR
	lRet := .T.   //NAO PRECISA VALIDAR ACOLS NO CASO DE VISUALIZAR E EXCLUIR
	  
Else
	If nOpc == 6
		lEfetImp := .T.
	EndIf
	cMsgConta := ""
	For nX := 1 to Len(aCols)
		If !AFA380LIN(nX)	
			lRet := .F.
			Exit
		EndIf
	Next nX 
	If !Empty(cMsgConta)
		cMsgConta:= Substr(cMsgConta,1,Len(cMsgConta)-2)
		If !MsgYesNo(STR0152+ FWX3Titulo( "NJ_CPERREV" )+ " | "+FWX3Titulo( "NJ_CRECDES" )+STR0154+cMsgConta+". "+STR0153,STR0155) 
			lRet := .F.
		EndIf
	EndIf

EndIf

Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA380VAgl	บAutor  ณAlvaro Camillo Neto บ Data ณ  14/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o usuario concorda que o lan็amento aglutinado  นฑฑ
ฑฑบ          ณquebre em n documentos por causa do processamento			  นฑฑ
ฑฑบ          ณmultithread                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA380                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A380VAgl(cPerg)
Local lRet := .T.
Local nNumProc		:= SuperGetMv("MV_ATFMTHR", .F., 1 )

Pergunte(cPerg,.F.)

If lRet .And. nNumProc > 1
	lRet := CTBINTRAN(1,.F.)
EndIf

If lRet .And. nNumProc > 1 .And. MV_PAR01 == 1 
	lRet := MsgYesNo( STR0065 + cValtoChar(nNumProc) + STR0066 +CRLF+ STR0067 )//"A rotina estแ configurada para executar em "##" processos, por isso nใo serแ mostrada a tela de contabiliza็ใo"##" Concorda com a opera็ใo? "
EndIf

If lRet .And. nNumProc > 1 .And. MV_PAR02 == 1 
	lRet := MsgYesNo( STR0068 + cValtoChar(nNumProc) + STR0069 +CRLF+ STR0070 +cValtoChar(nNumProc)+ STR0071+CRLF+ STR0067  )//"A rotina estแ configurada para executar em "##" processos, sendo "##" assim irแ gerar "##" lan็amentos aglutinados. "##" Concorda com a opera็ใo? " 
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Acacio Egas           ณ Data ณ29/12/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ	  1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef()
Private aRotina :=  {}

aAdd(aRotina , { STR0029,	"AxPesqui", 	1, 1} ) //'Pesquisar'
aAdd(aRotina , { STR0045,	"Af380Wizar", 	2, 2} ) //'Visualizar'
aAdd(aRotina , { STR0030,	"Af380Wizar", 	3, 3} ) //'Incluir'
aAdd(aRotina , { STR0048,	"Af380Wizar", 	4, 4} ) //'Alterar'
aAdd(aRotina , { STR0049,	"Af380Wizar", 	5, 5} ) //'Excluir'
aAdd(aRotina , { STR0031,	"Af380Wizar",	6, 6} ) //"Efetivar"
aAdd(aRotina , { STR0078,    "Af380CSV",	7, 3} ) //"Importar"
aAdd(aRotina , { STR0079,    "Af380CSV",	8, 8} ) //"Exportar"
aAdd(aRotina , { STR0170,    "Af380Est",	9, 5} ) //"Estornar"

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf380CSV  บAutor  ณAlvaro Camillo Neto บ Data ณ  17/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Wizard de importa็ใo e exporta็ใo de arquivo .CSV          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Af380CSV(cAlias, nReg, nOpc)
Local oWizard 		:= Nil
Local aPBox1	 	:= {} 
Local aPBox2		:= {}
Local nOpcRot		:= 0
LOCAL nSaveSx8Len 	:= GetSx8Len()
Local lRet 			:= .T.
Local nNumProc		:= SuperGetMv("MV_ATFMTHR", .F., 1 )
Local aRet2			:= { 1 }
Local aRetPer   	:= {}  
Local aCols			:= {}
Local aHeader		:= {}
Local aRecnoSN3		:= {}

EDITWIZAR := .F.

If nOpc == EXPORTAR
	If xFilial( "SNI") # SNI->NI_FILIAL .OR. ( SNI->( Eof() ) .AND. SNI->( Bof() ) )
		Help( " ", 1, "ARQVAZIO" )
		Return
	EndIf
EndIf

Pergunte("AF380S",.F.)

If nNumProc > 1 .And. !A380VAgl("AF380S")
	Return	
EndIf 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIncializa็ใo dos array de resposta do paramboxณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc==EXPORTAR
	aRetPer := Array(2)
	aRetPer[01] 	:= Space( 50 )
	aRetPer[02] 	:= Space( 100 )
	aAdd(aPBox1,{ 1,STR0080,Space(50),"","","","",50,	.T.})           //"Nome do arquivo"
	aAdd(aPBox1,{ 6,STR0081,Space(100),"","","",100,.T.,STR0084 + " (*.*) |*.* ", "",GETF_LOCALHARD + GETF_RETDIRECTORY }) //"Diret๓rio de Grava็ใo"###"Todos os arquivos (*.*) |*.*"
Else
	aRetPer := Array(1)
	aRetPer[01]:= Space( 150 )
	aAdd(aPBox1,{ 6,STR0083,Space(100),"","","",100,.T.,STR0084 + " (*.CSV) |*.CSV ", "",GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE}) //"Diret๓rio de Grava็ใo"###"Todos os arquivos (*.*) |*.*"
EndIf

aAdd(aPBox2,{3,STR0013,2,{ STR0014, STR0015 },60,".T.",.T.,.T.})  //"O que deseja fazer"###"Simular"###"Efetivar"

DEFINE WIZARD oWizard TITLE STR0001;//"Redu็ใo ao Valor Recuperแvel do Ativo"
       HEADER STR0016 ; 			//"Simula็ใo e Efetiva็ใo do Redu็ใo ao Valor Recuperแvel do Ativo"
       MESSAGE "";//STR0017; 			//"Parโmetros Iniciais..."
       TEXT STR0018 + CRLF +;		//"O objetivo desta rotina ้ definir procedimentos visando a assegurar que"
       		STR0019 + CRLF +;		//"os ativos nใo estejam registrados contabilmente por um valor superior"
       		STR0020;				//"aquele passivel de ser recuperado por uso ou por venda."
       NEXT {||.T.} ;
       FINISH {|| .T. } ;
       PANEL

	//Segunda Pagina 
   CREATE PANEL oWizard ;
          HEADER STR0044 ; 	//"Dados da Sinula็ใo da redu็ใo ao valor recuperavel de ativos."
          MESSAGE ;
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .T. } ;
          PANEL

	RegToMemory("SNI", If(nOpc==IMPORTAR,.T.,.F.),,, FunName())
	If nOpc==IMPORTAR
		M->NI_PROC 	:= GetSx8Num("SNI","NI_PROC",,1)
		M->NI_DTEMIS:= dDatabase
		M->NI_STATUS	:= "1"
	Else
		M->NI_PROC 	:= SNI->NI_PROC
		M->NI_DTEMIS:= SNI->NI_DTEMIS
		M->NI_STATUS:= SNI->NI_STATUS
		M->NI_DTIOA	:= SNI->NI_DTIOA
	EndIf
	oMsmSNI	:= MsMGet():New("SNI",SNI->(RECNO()),nOpc,,,,,/*{0, 0, 640, 480}*/,,4,,,,oWizard:GetPanel(2),,,.F.)
	oMsmSNI:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oMsmSNI:Disable()

	//Terceira Pagina
   CREATE PANEL oWizard ;
          HEADER STR0021 ; 	//"Informe Parโmetros Iniciais" ;
          MESSAGE ; 	//"Determine os arquivos da sele็ใo " 
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| nOpcRot := 1 , .T.} ;
          PANEL
          
	ParamBox(aPBox1,STR0027, @aRetPer,,,,,,oWizard:GetPanel(3)) //"Parโmetros..."
	If nOpc == IMPORTAR
		//Quarta Pagina
	   CREATE PANEL oWizard ;
	          HEADER STR0025; 	//"Processamento" ;
	          MESSAGE STR0026; 	//"Informe o que deseja fazer..."
	          BACK {|| .T. } ;
	          NEXT {|| .T. } ;
	          FINISH {|| nOpcRot := 1 , .T.} ;
	          PANEL
	
		ParamBox(aPBox2,STR0028, @aRet2  ,,,,,,oWizard:GetPanel(4)) //"Processamento..."
	EndIF

ACTIVATE WIZARD oWizard CENTERED

If nOpcRot == 1 
	If nOPC == EXPORTAR
		If Empty(aRetPer[1]) .Or. Empty(aRetPer[2])
			nOpcRot := 0
			Help( " ", 1, "OBRIGAT" )
		EndIf  
	Else
		If Empty(aRetPer[1]) 
			nOpcRot := 0
			Help( " ", 1, "OBRIGAT" )
		EndIf  
	EndIf
EndIf


If nOPC == IMPORTAR .And. nOpcRot == 1  
	MsgRun( STR0085, STR0086, {|| lRet := IOAImpCSV(aRetPer[1],@aHeader,@aCols,@aRecnoSN3 ) } )//"Processando Importa็ใo"##"Processando ..." 
	If !lRet
		nOpcRot := 0
	EndIf	
EndIf 

If nOpcRot == 1 
	//Validacao para o bloqueio do processo
	If nOPC == IMPORTAR .And. aRet2[1] == 2
		lRet := CtbValiDt(,dDataBase  ,,,,{"ATF001"},) 
	EndIf
	If lRet
		M->NI_PARAM := StrArray(aRetPer)
		lRet := Af380SelIOA(aRetPer,aRet2[1] == 2, nOpc,aHeader,aCols,aRecnoSN3)
	EndIf	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณRetorna a numera็ใo caso o usuแrio nใo confirmeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If (nOpcRot == 0 .or. !lRet) .And. nOpc == IMPORTAR
	While GetSx8Len() > nSaveSx8Len
		RollBackSx8()
	End
ElseIf nOpc == IMPORTAR
	ConfirmSx8()
EndIf

Return .T.

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณIOAExpCSV ณ Autor ณ Alvaro Camillo Neto   ณ Data ณ 06/05/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Exportacao de tabelas para arquivo .CSV                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณIOAExpCSV(cArq, Chave)                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณATFA380                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function IOAExpCSV(cArq, cProcesso)
Local aStruct	:=	{}
Local cLin		:=	""
Local aArea		:= GetArea()
Local aAreaAux  := SNJ->(GetArea())
Local nX
Local cStringCmp := "NJ_CCDESP,NJ_CCCDEP,NJ_CCCDES,NJ_CCCORR,NJ_SUBCTA,NJ_SUBCCON,NJ_SUBCDEP,NJ_SUBCCDE,NJ_SUBCDES,NJ_SUBCCOR,NJ_CLVL,NJ_CLVLCON,NJ_CLVLDEP,NJ_CLVLCDE,NJ_CLVLDES,NJ_CLVLCOR,NJ_CCUSTO,NJ_CUSTBEM,NJ_CDEPREC,NJ_CDESP,NJ_CCORREC,NJ_CCONTAB,NJ_CPERREV,NJ_CRECDES"
DbSelectArea("SNJ")

SAVEINTER()

If At('.',cArq) == 0
	cArq	:=	AllTrim(cArq)+'.CSV'
EndIf
If (nHandle := FCreate(cArq))== -1
	Alert(STR0087)//"Erro na criacao do arquivo!"
	RestInter()
	Return .F.
EndIf

aStruct	:=SNJ->(DbStruct())
For nX:=1 To Len(aStruct)
	cLin	+=	aStruct[nX,1] + ';'
Next
cLin := Left(cLin,Len(cLin)-1)
cLin += CRLF
FWrite(nHandle,cLin,Len(cLin))

SNJ->(DbSetOrder(1)) //NJ_FILIAL+NJ_PROC+NJ_ITEM
SNJ->(DbSeek(xFilial("SNJ") + cProcesso ))

Do While  SNJ->(NJ_FILIAL+NJ_PROC) == xFilial("SNJ") + cProcesso .And. SNJ->(!Eof())
	cLin := ""
	For nX := 1 To Len(aStruct)
		Do Case
			Case aStruct[nX,2] == "C"
				If aStruct[nX,1] $ 'NJ_FILIAL,NJ_BEM,NJ_ITBEM,NJ_SEQSN3,NJ_CODIND'  
					cLin +=  FieldGet(FieldPos(aStruct[nX,1])) + ';'
				Elseif aStruct[nX,1] $ cStringCmp
					cLin +=  RTRIM(FieldGet(FieldPos(aStruct[nX,1]))) + ';'
				Else
					cLin +=  ALLTRIM(FieldGet(FieldPos(aStruct[nX,1]))) + ';'
				EndIf
			Case aStruct[nX,2] == "L"
				cLin += IIf(FieldGet(FieldPos(aStruct[nX,1])),"T","F") + ';'
			Case aStruct[nX,2] == "D"
				cLin += Dtos(FieldGet(FieldPos(aStruct[nX,1]))) + ';'
			Case aStruct[nX,2] == "N"
				cLin += ALLTRIM(Str(FieldGet(FieldPos(aStruct[nX,1])))) + ';'
			Otherwise
				cLin += ';'
		EndCase
	Next
	cLin := Left(cLin,Len(cLin)-1)
	cLin += CRLF
	FWrite(nHandle,cLin,Len(cLin))
	SNJ->(DbSkip())
EndDo
RestArea(aAreaAux)

FClose(nHandle)

Aviso(STR0088,STR0089,{"Ok"}) //"Finalizado"###"Exportacao gerada com sucesso" //"Ok"

RestInter()

RestArea(aArea)

Return .T.

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณIOAImpCSV ณ Autor ณ Alvaro Camillo Neto   ณ Data ณ 06/05/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Importa็ใo de tabelas para arquivo .CSV                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณIOAImpCSV(cArq, Chave)                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณATFA380                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function IOAImpCSV(cArq,aHeader,aCols,aRecnoSN3)
Local aArea		:= GetArea()
Local nX
Local cLinha 	:= ""
Local aCpoCSV	:= {}
Local aDadosCSV := {}
Local aObrigat	:= {}
Local lRet		:= .T.
Local nMax      := Val( Replicate( "9",TamSX3("NJ_ITEM")[1]) )
Local nNumLin	:= 0        
Private aErros	:= {}

Default aHeader	:= {}
Default aCols	:= {}


// Campos Obrigatorio
aAdd(aObrigat,"NJ_FILIAL")
aAdd(aObrigat,"NJ_BEM")
aAdd(aObrigat,"NJ_ITBEM")

SaveInter()

DbSelectArea("SNJ")

If At('.',cArq) == 0
	cArq	:=	AllTrim(cArq)+'.CSV'
EndIf

If lRet .And. (nHandle := FT_FUse(AllTrim(cArq)))== -1
	aAdd(aErros,STR0090+STR0091)//"Erro de Arquivo: "##" Nใo ้ possivel abrir arquivo"
	lRet := .F.
EndIf

nNumLin := FT_FLASTREC()
If lRet .And.  nNumLin < 2
	aAdd(aErros,STR0090+STR0091)//"Erro de Arquivo: "##"Arquivo Vazio"
	lRet := .F.
EndIf

If lRet .And.  nNumLin > nMax
	aAdd(aErros,STR0090+STR0100 + cValToChar(nMax) + STR0101 )//"Erro de Arquivo: "##"Tamanho mแximo ้ de "## " linhas."
	lRet := .F.
EndIf

If lRet
	FT_FGOTOP()
	// Monta o Aheader
	aHeader := CriaHeader(NIL,"NJ_PROC",aHeader,"SNJ")
	nPosITem := aScan(aHeader,{|x| Alltrim(x[2]) == "NJ_ITEM"})
	 
	//Monta a strutura do arquivo
	clinha 	:= ft_freadln()
	nAt		:=	1
	Do While nAt > 0
		nAt	:=	AT(";",cLinha)
		If nAt > 0
			cToken	:=	Substr(cLinha,1,nAt-1)
		Else
			cToken	:=	Alltrim(cLinha)
		EndIf
		If SNJ->(FieldPos(cToken)) > 0
			AADD( aCpoCSV, Alltrim(Upper(cToken)) )
		Else
			lRet := .F.
			aAdd(aErros,STR0092+cValToChar (1)+" - "+ STR0093 +cToken )//"Erro de Estrutura na Linha :"##"Campos Invแlido "
		EndIf
		cLinha	:=	Substr(cLinha,nAt+1)
	EndDo
	
	If Len(aCpoCSV) > 0
		For nX := 1 to Len(aObrigat)
			If aScan(aCpoCSV,{|x| Alltrim(x) == Alltrim(aObrigat[nX]) }) <= 0
				aAdd(aErros,STR0092+cValToChar (1)+" - "+STR0094 +aObrigat[nX] + STR0095 )//"Erro de Estrutura na Linha :"##"Campo: "##" nใo estแ na estrutura"
				lRet := .F.
			EndIf
		Next nX
	EndIf
	
	If lRet
		FT_FSKIP()
		Do While !FT_FEOF()
			clinha 	:= ft_freadln()
			aAdd(aDadosCSV,Array(Len(aCpoCSV)))
			nLin := Len(aDadosCSV)
			nCpo := 1
			nAt		:=	1
			Do While nAt > 0
				nAt	:=	AT(";",cLinha)
				If nAt > 0
					cToken	:=	Substr(cLinha,1,nAt-1)
				Else
					cToken	:=	Alltrim(cLinha)
				EndIf
				aDadosCSV[nLin][nCpo] := cToken
				cLinha	:=	Substr(cLinha,nAt+1)
				nCpo++
			EndDo
			FT_FSKIP()
		EndDo
		// Monta o aCols
		For nX := 1 To Len(aDadosCSV)
			aLinha := MontaLinCSV(aDadosCSV[nX],aHeader,aCpoCSV,nX)
			If !Empty(aLinha)
				aAdd(aCols,aClone(aLinha))
				nCols := Len(aCols) 
				aCols[nCols][nPosITem] := StrZero(nCols,TamSx3("NJ_ITEM")[1])
			Else
				lRet := .F.
			EndIf
		Next nX
		
		//Monta o Array de Recnos
		If lRet
			aRecnoSN3 := AF380Rec(aHeader,aCols)	
		EndIf
	EndIf
EndIf

If !lRet
	If MsgYesNo(STR0096)//"Ocorreram inconsistencia no processo, deseja imprimir o relatorio de erros?"
		CtRConOut(aErros)
	EndIf
EndIf


RestInter()
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaLinCSVบAutor  ณAlvaro Camillo Neto บ Data ณ  18/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta e valida a linha do arquivo                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaLinCSV(aLinha,aHeader,aCpoCSV,nLinha)
Local aLinAcol 		   := Array(Len(aHeader)+1)
Local nX	   		   := 0
Local nY	   		   := 0
Local i:= 0
Local lRet	   		   := .T.
Local nPosHeader	   := 0
Local __nQuantas := AtfMoedas()
Local cTipo	   := ""
Local nPLinFil := aScan(aCpoCSV,{|x| x == "NJ_FILIAL" })
Local nPLinBem := aScan(aCpoCSV,{|x| x == "NJ_BEM" })
Local nPLinItem := aScan(aCpoCSV,{|x| x =="NJ_ITBEM" })
Local nPLinTip := aScan(aCpoCSV,{|x| x == "NJ_TIPO" })            
Local lTpDepr		:= .T.

Local nPHeadVe := aScan(aHeader,{|x| x[2] == "NJ_VLVEN01" })
Local nPHeadOri:= aScan(aHeader,{|x| x[2] == "NJ_VLORI01" })
Local nPHeadRc:= aScan(aHeader,{|x| x[2] == "NJ_VLREC01" })

If lTpDepr
		For i:= 1 to __nQuantas
			cMoed := Alltrim(Str(i))
			If i==1  
					&("nPHeadOri" +cMoed)	:= aScan(aHeader,{|x| AllTrim(x[2]) == "NJ_VLORI01" }) 
					&("nPHeadRc"+cMoed)	:= aScan(aHeader,{|x| AllTrim(x[2]) == "NJ_VLREC0"  +cMoed }) 
					&("nPHeadVe" +cMoed)	:= aScan(aHeader,{|x| AllTrim(x[2]) == "NJ_VLVEN0"  +cMoed })		
			Else
					&("nPHeadOri" +cMoed)	:= aScan(aHeader,{|x| AllTrim(x[2]) == "NJ_VORIG"    +cMoed  })	  
					&("nPHeadRc"+cMoed)	:= aScan(aHeader,{|x| AllTrim(x[2]) == "NJ_VLREC0"  +cMoed }) 
					&("nPHeadVe" +cMoed)	:= aScan(aHeader,{|x| AllTrim(x[2]) == "NJ_VLVEN0"  +cMoed })
			Endif
		Next i	                        
Endif		
		
SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

If Len(aLinha) > Len(aCpoCSV) 
	aAdd(aErros,STR0092+cValToChar(nLinha)+" - "+STR0097 )//"Erro de Estrutura na Linha :"##"Estrura incorreta na linha "
	lRet := .F.	
EndIf
//Valida os campos
If aLinha[nPLinFil] != cFilAnt
	aAdd(aErros,STR0092+cValToChar(nLinha)+" - "+STR0098 )//"Erro de Estrutura na Linha :"##"Filial invแlida "
	lRet := .F.
EndIf

If nPLinTip > 0 .And. !Empty(aLinha[nPLinTip])
	cTipo := aLinha[nPLinTip]
Else
	cTipo := '01'
EndIf

If !SN3->(MsSeek(xFilial("SN3") + aLinha[nPLinBem] + aLinha[nPLinItem] + cTipo ))
	aAdd(aErros,STR0092+cValToChar(nLinha)+" - "+STR0099 )//"Erro de Estrutura na Linha :"##"Bem nใo encontrado "
	lRet := .F.
EndIf

//Preenche os acols
If lRet
	For nX := 1 to Len(aHeader)
		aLinAcol[nX] := CriaVar(aHeader[nX][2],.T.)
	Next nX
	aLinAcol[Len(aLinAcol)] := .F.
	
	For nX := 1 to Len(aLinha)
		nPosHeader := aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim(aCpoCSV[nX])})
		If nPosHeader > 0
			If aHeader[nPosHeader][8] == 'C'
				aLinAcol[nPosHeader] := aLinha[nX]
			ElseIf aHeader[nPosHeader][8] == 'D'
				aLinAcol[nPosHeader] := Stod(aLinha[nX])
			ElseIf aHeader[nPosHeader][8] == 'N'
				aLinha[nX] = STRTRAN( aLinha[nX] ,",","." ) 
				aLinAcol[nPosHeader] := Val(aLinha[nX])
			EndIf
		EndIf
	Next nX
	
	//Gatilha os campos
	SN3->(MsSeek(xFilial("SN3") + aLinha[nPLinBem] + aLinha[nPLinItem] + cTipo ))
	
	For nX := 1 to Len(aHeader)
		For nY := 1 to __nQuantas
			If aHeader[nX][2] == 'NJ_VLORI0'+ AllTrim(Str(nY)) .And. Empty(aLinAcol[nX])
				cCampo := 'SN3->N3_VORIG' + AllTrim(Str(nY))
				aLinAcol[nX] := &cCampo
			ElseIf aHeader[nX][2] == 'NJ_VORIG' + AllTrim(Str(nY)) .And. Empty(aLinAcol[nX])
				cCampo := 'SN3->N3_VORIG' + AllTrim(Str(nY))
				aLinAcol[nX] := &cCampo
			ElseIf aHeader[nX][2] == 'NJ_VLACM0' + AllTrim(Str(nY)) .And. ( aScan(aCpoCSV,{|x| x == aHeader[nX][2]  }) == 0 )	
				cCampo := 'SN3->N3_VRDACM' + AllTrim(Str(nY))			
				aLinAcol[nX] := &cCampo   
			EndIf
		Next nY             
		
		If aHeader[nX][2] == "NJ_TIPO" .And. Empty(aLinAcol[nX])
			aLinAcol[nX] := SN3->N3_TIPO
		Endif
		
	Next nX   
	
	If lTpDepr
			IIF (__nQuantas > 5, __nQuantas := 5, Nil)
			For nY := 1 to __nQuantas
				If  Empty(aLinAcol[&("nPHeadRc"+AllTrim(Str(nY)))])
					If aLinAcol[&("nPHeadVe"+AllTrim(Str(nY)))]  >= aLinAcol[&("nPHeadOri"+AllTrim(Str(nY)))]
							aLinAcol[&("nPHeadRc"+AllTrim(Str(nY)))] := aLinAcol[&("nPHeadOri"+AllTrim(Str(nY)))]
					Else
							aLinAcol[&("nPHeadRc"+AllTrim(Str(nY)))] := aLinAcol[&("nPHeadOri"+AllTrim(Str(nY)))] - aLinAcol[&("nPHeadVe"+AllTrim(Str(nY)))]
					EndIf
				EndIf     
			Next nY
	ElseIf  Empty(aLinAcol[nPHeadRc])
		If aLinAcol[nPHeadVe]  >= aLinAcol[nPHeadOri]
			aLinAcol[nPHeadRc] := aLinAcol[nPHeadOri]
		Else
			aLinAcol[nPHeadRc] := aLinAcol[nPHeadOri] - aLinAcol[nPHeadVe]
		EndIf
	EndIf
EndIf
	
If !lRet 
	aLinAcol := {}
EndIf

Return aLinAcol


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF380Rec  บAutor  ณMicrosiga           บ Data ณ  08/20/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Array de Recnos do SN3 para o processamento        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF380Rec(aHeader,aCols)
Local aRecno	:= {}
Local nX		:= 0
Local nPBem := aScan(aHeader,{|x| Alltrim(x[2]) == "NJ_BEM" })
Local nPItem := aScan(aHeader,{|x| Alltrim(x[2]) =="NJ_ITBEM" })
Local nPTip := aScan(aHeader,{|x| Alltrim(x[2]) == "NJ_TIPO" })

SN3->(dbSetOrder(1))
For nX := 1 to Len(aCols)
	If SN3->(MsSeek(xFilial("SN3") + aCols[nX][nPBem] + aCols[nX][nPItem] + aCols[nX][nPTip] ))
		aAdd(aRecno,SN3->(Recno()))	
	EndIf	
Next nX
 
Return aRecno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF380VREC บAutor  ณAlvaro Camillo Neto บ Data ณ  16/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGatilho do campo NJ_VLVEN01                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function AF380VREC()
Local nAt 		:= oGetSNJ:nAt
Local aHeader	:= aClone(oGetSNJ:aHeader)
Local nPosVOri	:= 0
Local nVlVenda	:= 0 
Local nPosVRec	:= 0
Local cCampo     	:= ""
Local nX			:= 0
Local nY			:= 0
Local cVar       := ""                   

//********************************
// Controle de multiplas moedas  *
//********************************

Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local aPosVVenX  := {}
Local lRet := .T.
Local cMoedaErr :=""
Local cMoedaAtf := GetMV("MV_ATFMOEDA")
Local nValorconv:= 0
Local nValor:=&(ReadVar())
Local nPosVR := Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLREC01" } )
Local nValRec01 := aCols[n,nPosVR]

DbSelectArea("SN1")
SN1->(DbSetOrder(1))
SN1->(DbSeek(xFilial("SNJ")+aCols[n][2]+aCols[n][3]))
              
DbSelectArea("SN3")
SN3->(DbSetOrder(1))
SN3->(DbSeek(xFilial("SNJ")+aCols[n][2]+aCols[n][3]))  

dDtConv := If( aCols[n][Ascan(aHeader, {|e| Alltrim(e[2]) = "NJ_TIPO"})]="02", dDataBase, SN1->N1_AQUISIC)
nPosVVenAtf := Ascan(aHeader	, {|e| Alltrim(e[2]) = "NJ_VLVEN0"+cMoedaAtf} )

If lMultMoed == .F.  
	Aadd(aPosVVenX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLVEN01" } ))   
	Aadd(aPosVVenX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLVEN02" } ))   
	Aadd(aPosVVenX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLVEN03" } ))
	Aadd(aPosVVenX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLVEN04" } ))
	Aadd(aPosVVenX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLVEN05" } ))      
Elseif __nQuantas >= 1 
	For nX := 1 to __nQuantas 
   		Aadd(aPosVVenX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLVEN"+AllTrim(StrZero(nX,2)) } )) 
 	Next nX
 	nX := 0  
EndIf

// Nao converte as linhas de reavaliacao, pois ela ja foi convertida pela rotina Af010Valor
If (! aCols[n][Ascan(aHeader, {|e| Alltrim(e[2]) = "NJ_TIPO"})]$"02/05" .Or. !GetNewPar("MV_ZRADEPR",.F.))
	
	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	
	If IsInCallStack("ATFA380VAL") .or. IsInCallStack("AF380TSTIM")
		cVar  := "M->NJ_VLVEN01"
		nValor:=  M->NJ_VLVEN01
	Else
		cVar:=ReadVar()
	EndIf
	For nY := 1 to __nQuantas
	    For nX := 1 to Len(aHeader)
			If AllTrim(aHeader[nX][2]) == 'NJ_VLORI0' + AllTrim(Str(nY))
				cCampo := "NJ_VLORI0" + AllTrim(Str(nY))
				nPosVOri := Ascan(aHeader, {|x| AllTrim(x[2]) == cCampo })
			ElseIf AllTrim(aHeader[nX][2]) == 'NJ_VORIG' + AllTrim(Str(nY))
				cCampo := "NJ_VORIG" + AllTrim(Str(nY))
				nPosVOri := Ascan(aHeader, {|x| AllTrim(x[2]) == cCampo })
			ElseIf AllTrim(aHeader[nX][2]) == 'NJ_VLVEN0' + AllTrim(Str(nY))
				cCampo := "NJ_VLVEN0" + AllTrim(Str(nY))
				nVlVenda :=  Ascan(aHeader, {|x| AllTrim(x[2]) == cCampo })
			ElseIf AllTrim(aHeader[nX][2]) == 'NJ_VLREC0' + AllTrim(Str(nY))
				cCampo := 'NJ_VLREC0' + AllTrim(Str(nY))
				nPosVRec := Ascan(aHeader, {|x| AllTrim(x[2]) == cCampo })
			EndIf
		Next nX
	
		If  &cVar >= oGetSNJ:aCols[nAt][nPosVOri]
			oGetSNJ:aCols[nAt][nPosVRec] := oGetSNJ:aCols[nAt][nPosVOri]
		Else
			oGetSNJ:aCols[nAt][nPosVRec] := oGetSNJ:aCols[nAt][nPosVOri] - &cVar
		EndIf
	Next nY
	
	If nValRec01 <> aCols[n,nPosVR]
		ATFA380VAL(aHeader,aCols,nAt)
	EndIf	
	
	//Converte apenas com base na moeda 1, pois o valor do ativo na outra moeda nใo necessita ter base na cota็ใo do dia.
	If "NJ_VLVEN01" $ cVar
		For nX := 2 to __nQuantas	// Checa se os valores convertidos vใo ultrapassar o tamanho de casas Inteiras
			If aPosVVenX[nX] > 0
				nValorConv:= nValor / RecMoeda(dDtConv,nX)
				If Len(AllTrim(Str(int(nValorConv)))) > TamSX3(aHeader[aPosVVenX[nX]][2])[1]-(TamSX3(aHeader[aPosVVenX[nX]][2])[2]+1)
					cMoedaErr += aHeader[aPosVVenX[nX]][1] + " ,"
					lRet := .F.
				Endif
			EndIf
			
		Next nX
		If !lRet
			Help( " ", 1, "AF380ESTVAL",, STR0086+cMoedaErr, 1, 0 ) // "A conversใo do valor Original na Moeda 1 para as seguintes moedas, ultrapassara o tamanho maximo permitido: "
		Else
			For nX := 2 to __nQuantas
				
				If aPosVVenX[nX] > 0
					aCols[n][aPosVVenX[nX]] := nValor / RecMoeda(dDtConv,nX)
					&("M->NJ_VLVEN0"+AllTrim(StrZero(nX,2))) := aCols[n][aPosVVenX[nX]]
				
					If Type("SN1->N1_MOEDAQU") == "N" .And. Type("SN1->N1_TXMOEDA") == "N"
						If nX == SN1->N1_MOEDAQU
							aCols[n][aPosVVenX[nX]] := nValor / If(Empty(SN1->N1_TXMOEDA),RecMoeda(dDtConv,nX),SN1->N1_TXMOEDA)
							&("M->NJ_VLVEN"+AllTrim(StrZero(nX))) := aCols[n][aPosVVenX[nX]]
						Endif
					Endif
				EndIf
			Next nX
		EndIf
	EndIf
	
	
Endif
	
oGetSNJ:oBrowse:Refresh()

Return(lRet)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็๕es Genericasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaHeaderบAutor  ณAlvaro Camillo Neto บ Data ณ  21/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o Aheader da getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaHeader(cCampos,cExcessao,aHeader,cAlias)
Local 	aArea		:= GetArea()
Local	cCombo		:= ""
Default aHeader 	:= {}
DEFAULT cCampos 	:= "" // Campos a serem conciderados
DEFAULT cExcessao	:= "" // Campos que nใo conciderados

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If (X3USO(SX3->X3_USADO) .Or. ( AllTrim(SX3->X3_CAMPO) $ Alltrim(cCampos) )) .AND. (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessao))
		
		//Transformo em string o conteudo de SX3->X3_CBOX
		//Este tratamento eh feito pois a MsNewGetDados nao trata como combo
		// se SX3->X3_CBOX for igual a #Function()
		cCombo := SX3->X3_CBOX
		If Substr(cCombo,1,1) == "#"
			cCombo := &(Alltrim(Substr(cCombo,2)))
		Endif
		aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
		SX3->X3_CAMPO	, ;			// 02 - Campo
	 	SX3->X3_Picture	, ;			// 03 - Picture
		SX3->X3_TAMANHO	, ;			// 04 - Tamanho
		SX3->X3_DECIMAL	, ;			// 05 - Decimal
		SX3->X3_Valid  	, ;			// 06 - Valid
		SX3->X3_USADO  	, ;			// 07 - Usado
		SX3->X3_TIPO   	, ;			// 08 - Tipo
		SX3->X3_F3		, ;			// 09 - F3
		SX3->X3_CONTEXT , ; 		// 10 - Contexto
		cCombo			, ; 		// 11 - ComboBox
		SX3->X3_RELACAO    } )   	// 12 - Relacao
		
	Endif
	SX3->(dbSkip())
End
RestArea(aArea)
Return(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaADSAcolsบAutor  ณ Totvs            บ Data ณ  04/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunc๕a que cria Acols                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoGetDados : painel										  บฑฑ
ฑฑบ          ณaHeader : aHeader aonde o aCOls serแ baseado                บฑฑ
ฑฑบ          ณaCols   : Opcional caso queira iniciar com algum elemento   บฑฑ
ฑฑบ          ณaRecNo  : recno do SN3.                                     บฑฑ
ฑฑบ          ณaRetPer : parametros                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaADSAcols( oGetD, aHeader, aCols, aRecNo, aRetPer , nOpc )
Local nX			:= 0
Local nCols		    := 0
Local aArea			:= GetArea()
Local cFields		:= "R_E_C_N_O_, "
Local lForce		:= .F.
Local lIncItem		:= .F.
Local cTipoGer		:= SuperGetMv( "MV_ATFTIOA", .F., "12" )
Local aTpDepr        := {AdmCBGener(xFilial("SN0"),"SN0","04","01")}
Local cTypes12		:= IIF(lIsRussia,"/" + AtfNValMod({2}, "/"),"") // CAZARINI - 07/04/2017 - If is Russia, add new valuations models - recoverable model

For nx := 1 To Len( aHeader )
	cFields += aHeader[nx][2]
	
	If nx < Len( aHeader )
		cFields += ", "
	EndIf
Next

If EDITWIZAR .and. Len(aCols)>0
	If Aviso( STR0040, STR0050, { STR0051, STR0052 } ) == 2 // "Atenþาo"##"Deseja consultar a base de ativos novamente?"##"Sim","Nao"
		Return .T.
	Else
		lForce	:= .T.
	EndIf
EndIf

aCols := {}

If nOpc==INCLUIR .or. lForce
	DbSelectArea( "SN1" )
	SN1->( DbSetOrder( 1 ) )
	SN1->( DbSeek( xFilial( "SN1" ) + AllTrim( aRetPer[01] ) ) )
	While SN1->( !Eof() ) .AND. SN1->N1_FILIAL == xFilial( "SN1" )
		If Empty( aRetPer[02] ) .OR. SN1->N1_CBASE >= aRetPer[01] .AND. SN1->N1_CBASE <= aRetPer[02] .and. Alltrim(SN1->N1_STATUS) $ " #1"
			DbSelectArea( "SN3" )
			SN3->( DbSetOrder( 1 ) )
			SN3->( DbSeek( xFilial( "SN3" ) + SN1->( N1_CBASE + N1_ITEM ) ) )
			While SN3->( !Eof() ) .AND. SN3->( N3_FILIAL + N3_CBASE + N3_ITEM ) == xFilial( "SN3" ) + SN1->( N1_CBASE + N1_ITEM )
				If !Empty( aRetPer[04] ) .AND. SN3->N3_CUSTBEM < aRetPer[03] .AND. SN3->N3_CUSTBEM > aRetPer[04]
					SN3->( DbSkip() )
					Loop
				EndIf

				If !Empty( aRetPer[06] ) .AND. SN3->N3_CCONTAB < aRetPer[05] .AND. SN3->N3_CCONTAB > aRetPer[06]
					SN3->( DbSkip() )
					Loop
				EndIf
				
				If lIsRussia
					If SN3->N3_OPER <> "1" // CAZARINI - 22.01.2017 - Asset Into Operation?
						SN3->( DbSkip() )
						Loop
					Endif
				Endif

				lIncItem := .F.

				// SN1 com movimentos nao baixados com tipo 12 no SN3
				If Empty( SN3->N3_DTBAIXA ) .AND. SN3->N3_TIPO $ (cTipoGer + cTypes12)
					lIncItem := .T.
				EndIf

				// SN1 com movimentos nao baixados com tipo 01 no SN3
				If Empty( SN3->N3_DTBAIXA ) .AND. SN3->N3_TIPO == "01"
					lIncItem := .T.
				EndIf

				If lIncItem
					nPos := aScan( aCols, { |x| Alltrim(x[2])+AllTrim(x[3]) == SN1->( N1_CBASE + N1_ITEM ) } )
					If nPos == 0
						aAdd(aCols,Array(Len(aHeader)+1))
						nCols++
						nPos := nCols
					EndIf

					For nX := 1 To Len(aHeader)    
					
						If AllTrim( aHeader[nX][02] ) == "NJ_ITEM"
							aCols[nPos][nX] := StrZero( nPos, 2 )

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_BEM"
							aCols[nPos][nX] := SN1->N1_CBASE

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_ITBEM"
							aCols[nPos][nX] := SN1->N1_ITEM

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_TIPO"
							aCols[nPos][nX] := SN3->N3_TIPO
							nTipo:= SN3->N3_TIPO
											
						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_TPDEPR"
							IIf(nTipo $ "1|10", aCols[nPos][nX] := aTpDepr, aCols[nPos][nX] := SN3->N3_TPDEPR)
							
						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_VLORI01"
							aCols[nPos][nX] := SN3->N3_VORIG1

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_VLTAX01"
							aCols[nPos][nX] := SN3->N3_TXDEPR1

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_TXDEPR2"
							aCols[nPos][nX] := SN3->N3_TXDEPR2

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_VORIG2"
							aCols[nPos][nX] := SN3->N3_VORIG2

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_TXDEPR3"
							aCols[nPos][nX] := SN3->N3_TXDEPR3

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_VORIG3"
							aCols[nPos][nX] := SN3->N3_VORIG3

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_TXDEPR4"
							aCols[nPos][nX] := SN3->N3_TXDEPR4

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_VORIG4"
							aCols[nPos][nX] := SN3->N3_VORIG4

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_TXDEPR5"
							aCols[nPos][nX] := SN3->N3_TXDEPR5

						ElseIf AllTrim( aHeader[nX][02] ) == "NJ_VORIG5"
							aCols[nPos][nX] := SN3->N3_VORIG5																																
						Else
							aCols[nPos][nX] := CriaVar( aHeader[nX][2], .T. )
						EndIf
					Next nX

					aCols[nPos][Len(aHeader)+1] := .F.
					aAdd( aRecNo, SN3->( RecNo() ) )
				EndIf

				SN3->( DbSkip() )
			End
		EndIf

		SN1->( DbSkip() )
	End
Else

	DbSelectArea( "SNJ" )
	SNJ->( DbSetOrder( 1 ) )
	SNJ->( DbSeek( xFilial( "SNJ" ) + M->NI_PROC ) )
	While SNJ->( !Eof() ) .AND. SNJ->( NJ_FILIAL + NJ_PROC ) == xFilial( "SNJ" ) + M->NI_PROC
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++

		For nX := 1 To Len(aHeader)
			If AllTrim( aHeader[nX][02] ) == "NJ_ITEM"
				If SNJ->(FieldPos( aHeader[nX][2] )) >0
					aCols[nCols][nX] := SNJ->( FieldGet( FieldPos( aHeader[nX][2] ) ) )
				Else
					aCols[nCols][nX] := StrZero(nCols,2)
				EndIf
			ElseIf SNJ->(FieldPos( aHeader[nX][2] ))>0
				aCols[nCols][nX] := SNJ->( FieldGet( FieldPos( aHeader[nX][2] ) ) )
			Else
				aCols[nCols][nX] := CriaVar( aHeader[nX][2], .T. )
			EndIf
		Next nX

		aCols[nCols][Len(aHeader)+1] := .F.

		DbSelectArea( "SN3" )
		SN3->( DbSetOrder( 1 ) )
		SN3->( DbSeek( xFilial( "SN3" ) + SNJ->( NJ_BEM + NJ_ITBEM ) ) )
		aAdd( aRecNo, SN3->( RecNo() ) )

		SNJ->( DbSkip() )
	End

EndIf

If Empty( aCols )
	Help( " ",1,"AF380EOF",,STR0039,1,0)//"Nenhum registro foi encontrado com os parametros especificados"
	Return .F.
EndIf

RestArea( aArea )

Return aCols


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA380   บAutor  ณMarylly A. Silva    บ Data ณ  25/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que busca a ๚ltima seqü๊ncia gravada nos itens de   บฑฑ
ฑฑบ          ณ bem e retorna a pr๓xima seqüencia para utiliza็ใo.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF380UTSEQ(cSN3Fil,cSN3BASE,cSN3ITEM)
Local aArea	:= GetArea()
Local cSN3Qry	:= ""
Local cSN3Als	:= GetNextAlias()
Local cSequencia:= REPLICATE("0",TamSX3("N3_SEQ")[1])

If Select(cSN3Als) > 0
	(cSN3Als)->(dbCloseArea())
EndIf

cSN3Qry := " SELECT "
cSN3Qry += " MAX(SN3.N3_SEQ) SEQUENCIA "
cSN3Qry += " FROM " + RetSqlName("SN3") + " SN3 "
cSN3Qry += " WHERE SN3.N3_FILIAL = '" + cSN3Fil + "' "
cSN3Qry += " AND SN3.N3_CBASE = '" + cSN3BASE + "' "
cSN3Qry += " AND SN3.N3_ITEM = '" + cSN3ITEM + "' "
cSN3Qry += " AND SN3.D_E_L_E_T_ = ' ' "

dbUseArea(.T., "TOPCONN", TcGenQry(,, cSN3Qry ), cSN3Als, .T.,.F. )

If (cSN3Als)->(!EOF()) 
	cSequencia := (cSN3Als)->SEQUENCIA
EndIf

/*
 * Incrementa a seqü๊ncia para inclusใo de novo item na tabela SN3.
 */
cSequencia := Soma1(cSequencia)

(cSN3Als)->(dbCloseArea())

RestArea(aArea)
Return(cSequencia)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATF380VlTpDep   บAutor  ณAlvaro Camillo Neto บ Data ณ  25/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de valida็ใo de tipo de deprecia็ใo                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATF380VlTpDep(aCol,aHeader,lHelp,nLinha)
Local lRet := .T.
Local nPosTax1 	   	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_VLTAX01" })
Local nPosVAcm 		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_VLACM01" })
Local nPosTipDp		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_TPDEPR" })
Local nPosPerDp		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_PERDEPR" })
Local nPosVlSav		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_VLSALV1" })
Local nPosPrEst		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_PRODANO" })
Local nPosPrPer		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_PRODMES" })
Local nPosPrAcm		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_PRODACM" })
Local nPosIndDp 		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_CODIND" })
Local nPosVmxDp		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_VMXDEPR" })
Local nPosVlRec		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "NJ_VLREC01" })
Local aCampos			:= {}
Local cTipDepr 		:= aCol[nPosTipdp]
Local nPosX			:= 0
Local nX				:= 0

aAdd(aCampos,"NJ_VLTAX01")
aAdd(aCampos,"NJ_TXDEPR2")
aAdd(aCampos,"NJ_TXDEPR3")
aAdd(aCampos,"NJ_TXDEPR4")
aAdd(aCampos,"NJ_TXDEPR5")
aAdd(aCampos,"NJ_PERDEPR")
aAdd(aCampos,"NJ_VLSALV1")
aAdd(aCampos,"NJ_PRODANO")
aAdd(aCampos,"NJ_PRODMES")
aAdd(aCampos,"NJ_PRODACM")
aAdd(aCampos,"NJ_CODIND" )
aAdd(aCampos,"NJ_VMXDEPR")

For nX := 1 to Len(aCampos)
	nPosX 	:= Ascan(aHeader, {|x| Alltrim(x[2]) == Alltrim(aCampos[nX]) })
	If nPosX > 0 
		lRet := AF380AVlTP(aCampos[nX],aCol[nPosX],cTipDepr,lHelp)
		If !lRet 
			Exit
		EndIf
	EndIf
Next nX


If lRet .And. cTipDepr == '2' // Redu็ใo de Saldos
	If aCol[nPosPerDp] == 0
		lRet := .F.
		If lHelp
			Help("AF380Rec2",1,"HELP","AF380Rec2",STR0111+cvalTochar(nLinha)+" : "+STR0140,2,0) //"Periodo Depreciacao na linha "##" ้ obrigat๓rio para Tipo de Depreciacao Redu็ใo de Saldos "
		EndIf
	ElseIf aCol[nPosVlSav] == 0
		lRet := .F.
		If lHelp
			Help("AF380Rec3",1,"HELP","AF380Rec3",STR0112+cvalTochar(nLinha)+" : "+STR0140,2,0) //"Valor Salvamento na linha "##" ้ obrigat๓rio para Tipo de Depreciacao Redu็ใo de Saldos "
		EndIf
	Endif
EndIf

If lRet .And. ( cTipDepr $ "4589") // Unidades Produzidas / Horas Trabalhadas / Exaustใo linear / Exaustใo por saldo residual

	If aCol[nPosPrEst] == 0
		lRet := .F.
		If lHelp
			Help("AF380Rec4",1,"HELP","AF380Rec4",STR0113+cvalTochar(nLinha)+" : "+STR0140,2,0) //"Produ็ใo Estimada na linha "##" ้ obrigat๓rio para esse tipo de Depreciacao" Unidades Produzidas  / Horas Trabalhadas / Exaustใo linear / Exaustใo por saldo residual
		EndIf
	ElseIf aCol[nPosPrPer] == 0
		lRet := .F.
		If lHelp
			Help("AF380Rec5",1,"HELP","AF380Rec5",STR0114+cvalTochar(nLinha)+" : "+STR0140,2,0) //"Produ็ใo Perํodo na linha "##" ้ obrigat๓rio para Tipo de Depreciacao" Unidades Produzidas  / Horas Trabalhadas / Exaustใo linear / Exaustใo por saldo residual
		EndIf
	ElseIf aCol[nPosPrPer] > aCol[nPosPrEst]
		lRet := .F.
		If lHelp
			Help("AF380Rec6",1,"HELP","AF380Rec6",STR0114+" "+cvalTochar(nLinha)+" : "+STR0126,2,0) //"Produ็ใo Perํodo na linha Nใo deve ser "##" Maior que Produ็ใo Estimada para Tipo de Depreciacao" Unidades Produzidas  / Horas Trabalhadas / Exaustใo linear / Exaustใo por saldo residual
		EndIf
	ElseIf  aCol[nPosVAcm] # 0  											  			// se Deprecia็ใo Acumulada Moeda 1 estiver prenchida
		If  aCol[nPosPrAcm] == 0 													// Produ็ใo Acumulada serแ Obrigat๓ria.
			lRet := .F.
			If lHelp
				Help("AF380Rec7",1,"HELP","AF380Rec7",STR0115+" "+cvalTochar(nLinha)+" : "+STR0140,2,0) //"Produ็ใo Acumulada na linha "##" ้ obrigat๓rio para Tipo de Deprecia็ใo"##" se Deprecia็ใo Acumulada estiver prenchida"  Unidades Produzidas  / Horas Trabalhadas / Exaustใo linear / Exaustใo por saldo residual
			EndIf
		Endif
	Endif
EndIf

If lRet .And. aCol[nPosTipdp] == '6'  //Soma de Digitos
	If aCol[nPosPerDp] == 0
		lRet := .F.
		If lHelp
			Help("AF380Rec8",1,"HELP","AF380Rec8",STR0111+cvalTochar(nLinha)+" : "+STR0140,2,0) //"Periodo Depreciacao na linha "##" ้ obrigat๓rio para Tipo de Depreciacao Soma dos Dํgitos "
		EndIf
	EndIf
EndIf

If lRet .And. aCol[nPosTipdp] == '7' //Linear com Valor Max. Deprecia็ใo
	If aCol[nPosTax1] == 0
		lRet := .F.
		If lHelp
			Help("AF380Rec9",1,"HELP","AF380Rec9",STR0110+cvalTochar(nLinha)+" : "+STR0140,2,0) //"Valor da Taxa na linha  "##" ้ obrigat๓rio para Tipo de Depreciacao Linear com Vlr.Maximo "
		EndIf
	ElseIf aCol[nPosVmxDp] == 0
		lRet := .F.
		If lHelp
			Help("AF380Rec10",1,"HELP","AF380Rec10",STR0117+cvalTochar(nLinha)+" : "+STR0140,2,0) //"Valor mแximo de deprecia็ใo na linha  "##" ้ obrigat๓rio para Tipo de Depreciacao Linear com Vlr.Maximo "
		EndIf
	ElseIf aCol[nPosVlRec] < aCol[nPosVmxDp]
		lRet := .F.
		If lHelp
			Help("AF380Rec11",1,"HELP","AF380Rec11",STR0117+cvalTochar(nLinha)+" : "+STR0131,2,0) //"Valor mแximo de deprecia็ใo deve ser na linha "##" Menor que Valor Original da Moeda 1 para Tipo de Depreciacao Linear com Vlr.Maximo "
		EndIf
	Endif
EndIf

If lRet .And. aCol[nPosTipdp] == 'A' //อndice de deprecia็ใo
	If Empty(aCol[nPosIndDp])
		lRet := .F.
		If lHelp
			Help("AF380Rec12",1,"HELP","AF380Rec12",STR0116+cvalTochar(nLinha)+" : "+STR0140,2,0) //"อndice de deprecia็ใo na linha "##" ้ obrigat๓rio para Tipo de Depreciacao อndice de deprecia็ใo "
		EndIf
	EndIf
Endif


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF380AVlTPบAutor  ณAlvaro Camillo Neto บ Data ณ  04/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo dos campos dos metodos de depreciacao gerencial   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF380AVlTP(cField,cConteud,cTipDepr,lHelp)
Local lRet			:= .T.
Local aArea		:= GetArea()
Local aAreaSX3		:= SX3->(GetArea())
Local cTitulo     := ""

If !Empty(cConteud)
	Do Case
		Case cTipDepr$'1'
			lRet := cField $ "NJ_VLTAX01,NJ_TXDEPR2,NJ_TXDEPR3,NJ_TXDEPR4,NJ_TXDEPR5"
		Case cTipDepr=='2'
			lRet := cField $ "NJ_PERDEPR,NJ_VLSALV1"
		Case cTipDepr=='3'
			lRet := cField $ "NJ_PERDEPR"
		Case cTipDepr=='6'
			lRet := cField $ "NJ_PERDEPR"
		Case cTipDepr$'7'
			lRet := cField $ "NJ_VMXDEPR,NJ_VLTAX01,NJ_TXDEPR2,NJ_TXDEPR3,NJ_TXDEPR4,NJ_TXDEPR5"
		Case cTipDepr$'4/5/8/9'
			lRet := cField $ "NJ_PRODANO/NJ_PRODMES/NJ_PRODACM"
		Case cTipDepr=='A'
			lRet := cField $ "NJ_CODIND"
		Otherwise // =='1'
			lRet := .F.
	EndCase
	If !lRet .And. lHelp
		SX3->(dbSetOrder(2))
		SX3->(MsSeek(cField))
		cTitulo := SX3->(X3Titulo())
		Help( " ", 1, "AF0380NAOPER",, STR0138+cTitulo+STR0139, 1, 0 )//"O campo "##" nใo ้ utilizado nesse tipo de deprecia็ใo" 
	EndIf
EndIf

RestArea(aAreaSX3)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF380AVAL บAutor  ณCaique Bispo Ferreiraบ Data ณ  27/12/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo de Conversใo e Replica็ใo de Taxas para as demais บฑฑ
ฑฑบ          ณMoedas                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFA380VAL(aHeader,aCols,n)

Local nValor:=IIf(!FwIsInCallStack("AF380VREC"),&(ReadVar()),aCols[n][Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLREC01" } )] )
Local cCampo:=  ReadVar()
Local cMoedaAtf := GetMV("MV_ATFMOEDA")
// Data de conversao das moedas para reavaliacao sera a data base.
Local dDtConv
Local nPosVRecAtf        
Local nPosTx02		:=  Ascan(aHeader,{|x| AllTrim(x[2]) == "NJ_TXDEPR2"})  
Local nPosTx03		:=  Ascan(aHeader,{|x| AllTrim(x[2]) == "NJ_TXDEPR3"})
Local nPosTx04		:=  Ascan(aHeader,{|x| AllTrim(x[2]) == "NJ_TXDEPR4"})
Local nPosTx05		:=  Ascan(aHeader,{|x| AllTrim(x[2]) == "NJ_TXDEPR5"})
Local nPosVlOri		:=  Ascan(aHeader,{|x| AllTrim(x[2]) == "NJ_VLORI01"})
Local nPosvlVen		:=  Ascan(aHeader,{|x| AllTrim(x[2]) == "NJ_VLVEN01"})

// *******************************
// Controle de multiplas moedas  *
// *******************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local aPosVRecX  := {}
Local nX
Local lRet := .T.
Local cMoedaErr :=""
Local nValorconv:= 0

DbSelectArea("SN1")
SN1->(DbSetOrder(1))
SN1->(DbSeek(xFilial("SNJ")+aCols[n][2]+aCols[n][3]))
              
DbSelectArea("SN3")
SN3->(DbSetOrder(1))
SN3->(DbSeek(xFilial("SNJ")+aCols[n][2]+aCols[n][3]))  

If !FwIsInCallStack("AF380VREC") .and. "NJ_VLREC01" $ cCampo
	M->NJ_VLVEN01 		:= aCols[n][nPosVlOri] -  M->NJ_VLREC01
	aCols[n][nPosvlVen] := aCols[n][nPosVlOri] -  M->NJ_VLREC01
	AF380VREC()
EndIf

dDtConv := If( aCols[n][Ascan(aHeader, {|e| Alltrim(e[2]) = "NJ_TIPO"})]="02", dDataBase, SN1->N1_AQUISIC)      
nPosVRecAtf := Ascan(aHeader	, {|e| Alltrim(e[2]) = "NJ_VLREC0"+cMoedaAtf} )    


If lMultMoed == .F.  
	Aadd(aPosVRecX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLREC01" } ))   
	Aadd(aPosVRecX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLREC02" } ))   
	Aadd(aPosVRecX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLREC03" } ))
	Aadd(aPosVRecX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLREC04" } ))
	Aadd(aPosVRecX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLREC05" } ))   
Elseif __nQuantas >= 1 
	For nX := 1 to __nQuantas
   		Aadd(aPosVRecX,Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLREC0"+AllTrim(Str(nX)) } )) 
 	Next nX
 	nX := 0  
EndIf

// Nao converte as linhas de reavaliacao, pois ela ja foi convertida pela rotina Af010Valor
If (! aCols[n][Ascan(aHeader, {|e| Alltrim(e[2]) = "NJ_TIPO"})]$"02/05" .Or. !GetNewPar("MV_ZRADEPR",.F.))
	
	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	//Converte apenas com base na moeda 1, pois o valor do ativo na outra moeda nใo necessita ter base na cota็ใo do dia.
	If "NJ_VLREC01" $ cCampo .or. FwIsInCallStack("AF380VREC")
		For nX := 2 to __nQuantas	// Checa se os valores convertidos vใo ultrapassar o tamanho de casas Inteiras
			If aPosVRecX[nX] > 0
				nValorConv:= nValor / RecMoeda(dDtConv,nX)
				If Len(AllTrim(Str(int(nValorConv)))) > TamSX3(aHeader[aPosVRecX[nX]][2])[1]-(TamSX3(aHeader[aPosVRecX[nX]][2])[2]+1)
					cMoedaErr += aHeader[aPosVRecX[nX]][1] + " ,"
					lRet := .F.
				Endif
			EndIf
		Next
		If !lRet
			Help( " ", 1, "AF380ESTVAL",, STR0086+cMoedaErr, 1, 0 ) // "A conversใo do valor Original na Moeda 1 para as seguintes moedas, ultrapassara o tamanho maximo permitido: "
		Else
			For nX := 2 to __nQuantas
				If aPosVRecX[nX] > 0
					aCols[n][aPosVRecX[nX]] := nValor / RecMoeda(dDtConv,nX)
					&("M->NJ_VLREC0"+AllTrim(Str(nX))) := aCols[n][aPosVRecX[nX]]
				
					If Type("SN1->N1_MOEDAQU") == "N" .And. Type("SN1->N1_TXMOEDA") == "N"
						If nX == SN1->N1_MOEDAQU
							aCols[n][aPosVRecX[nX]] := nValor / If(Empty(SN1->N1_TXMOEDA),RecMoeda(dDtConv,nX),SN1->N1_TXMOEDA)
							&("M->NJ_VLREC0"+AllTrim(Str(nX))) := aCols[n][aPosVRecX[nX]]
						Endif
					Endif
				EndIf
			Next
		EndIf
	Elseif "NJ_VLTAX01" $ cCampo
		aCols[n][nPosTx02] := 	aCols[n][nPosTx03] := 	aCols[n][nPosTx04] := 	aCols[n][nPosTx05] := nValor
	EndIf
	
	If nPosVRecAtf > 0 .And. ExistBlock("A30EMBRA")
		aCols[n][nPosVRecAtf] := Iif(ExistBlock("A30EMBRA"),nValor/ExecBlock("A30EMBRA",.F.,.F.),nValor / RecMoeda(dDtConv,Val(cMoedaAtf)))
		&("M->NJ_VLREC0"+AllTrim(Str(Val(cMoedaAtf)))) := aCols[n][nPosVRecAtf]
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  AF380REVER บAutor  ณEwerton Franklinบ Data ณ  28/05/24       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Retorna o limite para calculo do 2บlimitador             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AF380REVER(cBaseSN3 as Character,cItemSN3 as Character,cMoed as Character,cFil as Character ) as Array

 	Local cQuery  := ""  as character
    Local nParam  := 1   as numeric
	Local cAlias  := ""  as character
	Local oQryExec       as Object
	Local nVlrPer := 0   as numeric
	Local nVlrRev := 0   as numeric
	Local nSumPer := 0   as numeric
	Local nSumRev := 0   as numeric
	Local nValLim := 0   as numeric
	Local aImpair := {}  as Array 
	
	DEFAULT cBaseSN3 := "" 
	DEFAULT cItemSN3 := "" 
	DEFAULT cMoed   := "1"
	DEFAULT cFil 	 := FWxFilial("SNI") 
	
	If cMoed == "1"
		cCampos:= "NJ_VLORI01 NJ_VLORI ,NJ_VLREC01 NJ_VLREC,NJ_VLVEN01 NJ_VLVEN, NJ_VLTAX01 NJ_VLTAX" 
	Else
		cCampos:= "NJ_VORIG"+cMoed+" NJ_VLORI ,NJ_VLREC0"+cMoed+" NJ_VLREC,NJ_VLVEN0"+cMoed+" NJ_VLVEN, NJ_TXDEPR"+cMoed+" NJ_VLTAX" 
	EndIf

    cQuery := "SELECT NI_FILIAL,NI_DTIOA,NI_PROC,NJ_BEM,NJ_ITBEM,"+cCampos +"  FROM ? SNJ " 
    cQuery += " INNER JOIN ? SNI ON NJ_FILIAL = NI_FILIAL AND NJ_PROC = NI_PROC 
	cQuery += " WHERE NI_FILIAL = ? "
	cQuery += " AND NJ_BEM = ? "
	cQuery += " AND NJ_ITBEM =  ? "
	cQuery += " AND NJ_TPAJUST <> ? "
	cQuery += " AND NI_STATUS = ? "
	cQuery += " AND SNI.D_E_L_E_T_ = ? "
	cQuery += " AND SNJ.D_E_L_E_T_ = ? "

	cQuery += " ORDER BY NI_DTIOA "
    cQuery := ChangeQuery(cQuery)

    oQryExec := FWExecStatement():New(cQuery)

    oQryExec:SetUnsafe(nParam++, RetSQLName("SNJ"))
	oQryExec:SetUnsafe(nParam++, RetSQLName("SNI"))
	oQryExec:SetString(nParam++, cFil)
    oQryExec:SetString(nParam++, cBaseSN3)
    oQryExec:SetString(nParam++, cItemSN3)
	oQryExec:SetString(nParam++, '2' )
	oQryExec:SetString(nParam++, '2' )
    oQryExec:SetString(nParam++, Space(1)) 
	oQryExec:SetString(nParam++, Space(1)) 

	cAlias := oQryExec:OpenAlias(GetNextAlias())
	
	While (cAlias)->(! Eof() ) 
		nVlrImp := (cAlias)->NJ_VLORI - (cAlias)->NJ_VLREC 
		nQtdDepr:= AF380QTDEP((cAlias)->NJ_BEM,(cAlias)->NJ_ITBEM,Stod((cAlias)->NI_DTIOA)) 
		If nVlrImp > 0
			nVlrPer += NoRound(NoRound(((nVlrImp/12) * ((cAlias)->NJ_VLTAX/100)),3) * nQtdDepr,2)
			nSumPer += nVlrImp
		Else
			nVlrRev += NoRound(NoRound(((Abs(nVlrImp)/12) * ((cAlias)->NJ_VLTAX/100)),3) * nQtdDepr,2)
			nSumRev += Abs(nVlrImp)
		EndIf

		(cAlias)->(DbSkip())
	EndDo

	nValLim:= Round((nSumPer - nSumRev ) - (nVlrPer - nVlrRev),2)

	Aadd(aImpair,nValLim)
	Aadd(aImpair,nSumPer)
	Aadd(aImpair,nSumRev)

	(cAlias)->(DbCloseArea())
	oQryExec:Destroy()
	oQryExec:=Nil

Return aImpair


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  AF380QTDEP บAutor  ณEwerton Franklinบ Data ณ  28/05/24  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna quantide deprecia็๕es para calculo limitador de     บฑฑ
ฑฑบ          ณ reversใo                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AF380QTDEP(cBaseSN4 as Character,cItemSN4 as Character,dIniDepr as Date) as Numeric

 	Local cQuery  := ""  as character
    Local nParam  := 1   as numeric
	Local cAlias  := ""  as character
	Local nQtdDep := 0   as numeric
	Local oQryExec	     as Object

	DEFAULT cBaseSN4 := "" 
	DEFAULT cItemSN4 := "" 
	DEFAULT dIniDepr := CTOD("") 
	
    cQuery := "SELECT COUNT(DISTINCT(N4_DATA)) QTD  FROM ? N4 " 
	cquery += " WHERE N4_FILIAL = ? "
	cQuery += " AND N4_CBASE = ? "
	cQuery += " AND N4_ITEM =  ? "
	cQuery += " AND N4_DATA >= ? "
	cQuery += " AND N4_OCORR  = ? "
	cQuery += " AND N4_TIPOCNT = ? "
	cQuery += " AND N4_ORIGEM =  ? "
	cQuery += " AND N4.D_E_L_E_T_ = ? "
	
    cQuery := ChangeQuery(cQuery)

    oQryExec := FWExecStatement():New(cQuery)

    oQryExec:SetUnsafe(nParam++, RetSQLName("SN4"))
	oQryExec:SetString(nParam++, FWxFilial("SN4"))
    oQryExec:SetString(nParam++, cBaseSN4)
    oQryExec:SetString(nParam++, cItemSN4)
	oQryExec:SetDate(nParam++, dIniDepr)
    oQryExec:SetString(nParam++, '20')
    oQryExec:SetString(nParam++, '3') 
    oQryExec:SetString(nParam++, 'ATFA050') 
    oQryExec:SetString(nParam++, Space(1)) 

	cAlias := oQryExec:OpenAlias(GetNextAlias())

	If (cAlias)->(! Eof() )
		nQtdDep	:= (cAlias)->QTD
	EndIf

	(cAlias)->(DbCloseArea())
	oQryExec:Destroy()
	oQryExec:=Nil

Return nQtdDep


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF380TSTIM บAutor  ณEwerton Franklin บ Data ณ  24/07/2024   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValid campo NJ_VLRIMPT para Teste de Impairment             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF380TSTIM()  as Logical

Local aHeader	:= aClone(oGetSNJ:aHeader) as Array
Local nValor	:=&(ReadVar())             as Numeric
Local nPosvlVen := Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLVEN01" } ) as Numeric
Local nPosVlDep := Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLACM01" } ) as Numeric
Local nPosVlOri := Ascan(aHeader	, {|e| Alltrim(e[2]) == "NJ_VLORI01" } ) as Numeric
Local nCpoBem   := Ascan(aHeader	, {|x| alltrim(x[2]) == "NJ_BEM"	 } ) as Numeric
Local nCpoItBem	:= Ascan(aHeader	, {|x| alltrim(x[2]) == "NJ_ITBEM"	 } ) as Numeric
Local nCpoTpAju	:= Ascan(aHeader	, {|x| alltrim(x[2]) == "NJ_TPAJUST" } ) as Numeric

Local nValRet    := 0  	as Numeric
Local aRetImpair := {}  as Array
Local nSaldoCont := 0	as Numeric
Local nValTstImp := 0	as Numeric
Local lRet		 := .T. as Logical

If nValor < 0 
	lRet := .F.
	Help("AF380IMP",1,"HELP","AF380IMP",STR0158,2,0,NIL, NIL, NIL, NIL, NIL, {STR0159}) //"Valor de teste de Impairment nใo pode ser menor que 0"#"Informe valor maior que 0"
ElseIf nCpoTpAju > 0 .and. aCols[n,nCpoTpAju] == "1"
	nSaldoCont :=  aCols[n,nPosVlOri] - aCols[n,nPosVlDep]
	nValTstImp :=  nValor - nSaldoCont

	If nValTstImp < 0 //Perda
		nValRet := Abs(nValTstImp)
	ElseIf nValTstImp > 0
		aRetImpair:= AF380REVER(aCols[n][nCpoBem],aCols[n][nCpoItBem],"1")
		nValRet:= If(nValTstImp > aRetImpair[LIMITE],-aRetImpair[LIMITE],-nValTstImp)
	EndIf

	M->NJ_VLVEN01 		:= nValRet
	aCols[n][nPosvlVen] := nValRet
	oGetSNJ:aCols[n][nPosvlVen] := nValRet
	AF380VREC()
EndIf

Return lRet

/* {Protheus.doc}
	af380Est - Fun็ใo de validacoes para saber se pode cancelar classifica็ใo

	@author Totvs
	@since 
	@param CodBase as Character, CodItem as Character return as logical 
	@version P12
*/
Function af380Est(cAlias, nReg, nOpc ) as Logical

Local lRetVld  as Logical
Local lTemMov  as Logical
Local cCodProc as Character
Local lCtbPrim as Logical
Local cTypes12 as Character
Local cCalcDep as Character
Local dUltDepr as character

Private cArquivo 	:= ""
Private __nHdlPrv	:= 0
Private __cLoteAtf 	:= LoteCont("ATF")
Private __nTotal	:= 0
Private nNumProc	:= SuperGetMv("MV_ATFMTHR", .F., 1 )
Private cPadraoEst  := "895"
Private cPadraoAQ	:= ""
Private cPadraoBai	:= ""
Private lMostra	 	:= .F.
Private lAglutina 	:= .F.
Private lOnOff	 	:= .T.
Private  cTipoGer 	:= SuperGetMv( "MV_ATFTIOA", .F., "12" ) 
		
Pergunte("AF380S",.F.)

cCalcDep	:= SuperGetMv("MV_CALCDEP",.F.,"")
cTypes12	:= IIF(lIsRussia,"/" + AtfNValMod({2}, "/"),"")
lOnOff 		:= MV_PAR03 == 1
If nNumProc == 1
	lMostra	:= MV_PAR01 == 1
EndIf
lAglutina 	:= MV_PAR02 == 1

If Alltrim(cTipoGer) $ ('12' + cTypes12)
	cPadraoAQ := "80B"
	cPadraoBai := "81B"
Else
	cPadraoAQ := "805"
	cPadraoBai := "814"
EndIf

lRetVld 	:= .T.
lTemMov 	:= .F.
cTipoGer	:= SuperGetMv( "MV_ATFTIOA", .F., "12" )
cCodProc 	:= SNI->NI_PROC
lCtbPrim    := .T.
dUltDepr	:= SuperGetMV("MV_ULTDEPR",.F.,STOD("19800101"))+1

lRetVld		:= SNI->(DbSeek(FWxfilial("SNI")+cCodProc))

DbSelectArea("SNJ")
SNJ->(DbSetOrder(1))

If !SNJ->(ColumnPos("NJ_SEQSN3")) > 0 
	Help(" ",1,"AF380NOPERM",,STR0161,1,0,,,,,,{STR0160}) //"Favor aplicar pacote atualizado"#"Nใo ้ possํvel estornar"
	lRetVld := .F.
EndIf

If  lRetVld .AND. (cCalcDep == "0" .and. !(dDataBase >= dUltDepr .and. dDataBase <= LastDay(dUltDepr))) .OR.;
	(cCalcDep == "1" .and. !(Year(dDataBase) == Year(dUltDepr))) 
	Help("  ",1,"AF380PERIOD",,STR0171,1,0,,,,,,{STR0172}) //"A data atual nใo pode ser anterior a data da ๚ltima deprecia็ใo"##"Verifique a database do sistema ou o parโmetro MV_ULTDEPR." 
	lRetVld := .F.
Endif

If lRetVld .AND. (dDataBase < SNI->NI_DTIOA)
	Help("  ",1,"AF380PERIOD",,STR0173,1,0,,,,,,{STR0174}) //"A data atual nใo pode ser anterior a data da efetiva็ใo do processo"##Verifique a database do sistema e tente novamente."
	lRetVld := .F.
Endif

If lRetVld 
	If SNI->NI_STATUS == '1' //Simula็ใo
		Help(" ",1,"AF380SIMUL",,STR0162,1,0,,,,,,{STR0161}) //"Status invแlido para estorno, processo nใo foi efetivado" #"Nใo ้ possํvel estornar"
		lRetVld := .F.
	ElseIf	SNI->NI_STATUS == '3'	
		Help(" ",1,"AF380JAEST",,STR0163,1,0,,,,,,{STR0161}) //"Processo jแ foi estornado" #"Nใo ้ possํvel estornar"
		lRetVld := .F.
	EndIf
	If lRetVld
		lTemMov	:=	VldEst380(FWxfilial("SNI"),cCodProc)
	EndIf

	If lTemMov
		Help(" ",1,"AF380MOV",,STR0166,1,0,,,,,,{STR0161}) //"Nใo serแ permitido realizar estorno, pois este processo jแ possui movimento em um ou mais bens"#"Nใo ้ possํvel estornar"
		lRetVld := .F.
	ElseIf lRetVld
		If MsgYesNo(STR0164 + cCodProc + STR0165 ) //"Processo: #  Deseja realmente confirmar o Estorno ? "
		
			If ( VerPadrao(cPadraoEst) .or. VerPadrao(cPadraoAQ) .or. VerPadrao(cPadraoBai) ) .and. lOnOff
				__nHdlPrv := HeadProva(__cLoteAtf,"ATFA380",Substr(cUsername,1,6),@cArquivo)
			EndIf

			DbSelectArea("SN3")
			SN3->(DbSetOrder(1))

			SNJ->(DbSeek(FWxfilial("SN1")+cCodProc))
			Begin TRANSACTION
				While !SNJ->(EOF()) .AND. cCodProc == SNJ->NJ_PROC
					If Empty(SNJ->NJ_SEQSN3) .AND. SNJ->NJ_VLVEN01 <> 0	
						Help(" ",1,"AF380NOSEQ",,STR0175,1,0,,,,,,{STR0176}) //"Campo Sequ๊ncia(NJ_SEQSN3) nใo existe ou nใo estแ preenchido."#"S๓ ้ possํvel estornar movimentos cujo o campo NJ_SEQSN3 esteja gravado."
						lRetVld := .F.
						Exit
					Endif
					If lRetVld .AND. SN3->(dbSeek( SNJ->NJ_FILIAL + SNJ->NJ_BEM + SNJ->NJ_ITBEM +cTipoGer+"0"+ SNJ->NJ_SEQSN3))
						FWMsgRun(, {||  lRetVld := af380CanEst(SN3->(RECNO()),SNI->NI_DTIOA) }, STR0033, STR0167+SNJ->NJ_ITEM) //"Aguarde" # "Estornando Item"
						If !lRetVld
							DisarmTransaction()
							Exit
						EndIf
					EndIf
					SNJ->(DbSkip())
				EndDo
			End Transaction
		Else
			lRetVld := .F.
		EndIf

		If lRetVld
			If __nHdlPrv > 0 .And. ( __nTotal > 0 ) .and. lOnOff 
				RodaProva(__nHdlPrv, __nTotal)
				cA100Incl(cArquivo,__nHdlPrv,3,__cLoteAtf,lMostra,lAglutina)
			Endif
		EndIf

		If lRetVld
			If SNI->(RecLock("SNI",.F.))
				SNI->NI_STATUS 	:= "3"	
				SNI->(MsUnlock())		
			EndIf
			Aviso(STR0088,STR0088,{STR0042}) //"Finalizado"###"Exportacao gerada com sucesso" //"Ok"
		EndIf
	EndIf
EndIf

Return 


/* {Protheus.doc}
	VldEst380 - Funcao que verifica se existe qualquer tipo de movimento ou depreciacao
	no bem posicionado para possibilidade de estorno

	@author Totvs
	@since 
	@param CodBase as Character, CodItem as Character,cTipo as Character return as logical 
	@version P12
*/
Static Function VldEst380(cFil as Character,cCodProc as Character) as Logical

	Local cQry			as Character
	Local lRetQry		as Logical
	Local nSeq			as Numeric
	
	Default cFil 		:= ""
	Default CodBase 	:= ""
	Default CodItem 	:= ""
	Default cTipo   	:= ""
	Default cTod    	:= ("")

	lRetQry		:= .T.
	nSeq		:= 1

	cQry	:= " SELECT Count(1) MOV "
	cQry	+= " FROM "+ RetSqlName("SNI") +" NI "
	cQry	+= " INNER JOIN "+RetSqlName("SNJ") +" NJ on NI.NI_FILIAL = NJ.NJ_FILIAL AND NI.NI_PROC = NJ.NJ_PROC "
	cQry	+= " INNER JOIN "+RetSqlName("SN4") +" N4 ON NJ.NJ_FILIAL = N4.N4_FILIAL AND NJ.NJ_BEM  = N4.N4_CBASE AND NJ.NJ_ITBEM = N4.N4_ITEM  "
	cQry	+= " WHERE "
	cQry	+= " N4.N4_FILIAL = ? "
	cQry	+= " AND NI.NI_PROC = ? "
	cQry	+= " AND N4.N4_TIPO = ?"
	cQry	+= " AND N4.N4_ORIGEM <> ? "
	cQry	+= " AND N4.N4_DATA >= NI_DTIOA  "
	cQry	+= " AND N4.N4_SEQ >= NJ_SEQSN3 "
	cQry	+= " AND N4.D_E_L_E_T_ = ? AND NJ.D_E_L_E_T_ = ? AND NI.D_E_L_E_T_ = ?"
	cQry 	:= ChangeQuery(cQry)

	oQueryQry := FwExecStatement():New(cQry)

	oQueryQry:SetString(nSeq++,		cFil)
	oQueryQry:SetString(nSeq++,		cCodProc)
	oQueryQry:SetString(nSeq++,		cTipoGer)
	oQueryQry:SetString(nSeq++,		'ATFA380')
	oQueryQry:SetString(nSeq++,		Space(1))
	oQueryQry:SetString(nSeq++,		Space(1))
	oQueryQry:SetString(nSeq++,		Space(1))
	
	lRetQry := oQueryQry:ExecScalar('MOV') > 0 

	oQueryQry:Destroy()
	oQueryQry := Nil
	

Return lRetQry


//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CvCan
Realiza o cancelamento da conversใo, realizando o cancelamento da baixa e excluindo o tipo atual
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function af380CanEst(nNewRecSN3 as Numeric,dDataMov as Date) as Logical
Local aArea		:= GetArea() 		as Array
Local aAreaSN3	:= SN3->(GetArea()) as Array
Local aAreaSN4	:= SN4->(GetArea()) as Array
Local aAreaSN1	:= SN1->(GetArea()) as Array
Local cBase		:= ""               as Character
Local cItem		:= ""				as Character
Local cTipo		:= ""				as Character
Local cSeq		:= ""				as Character
Local nRecSn3 	:= 0				as Numeric
Local lRet		:= .T.              as Logical
Local cSeqAnt	:= ""               as Character
Local cTypes10	:= IIF(lIsRussia,AtfNValMod({1}, "|"),"") as Character
Local aParam	:= {} 				as Array	
local nQtdMov   := 0				as Numeric

Private cPausaTp					as Character
Private lMsErroAuto := .F.

DEFAULT nNewRecSN3 := 0
DEFAULT dDataMov   := Ctod("")

cPausaTp  := SuperGetMV("MV_ATFPA01",, "") //Indica o(s) tipo(s) de ativo para pausar a deprecia็ใo.

SN3->(dbSetOrder(8)) //N3_FILIAL+N3_CODBAIX+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ

SN3->(dbGoto(nNewRecSN3))

DbSelectArea("SN1")
SN1->(DbSetOrder(1))
SN1->(DbSeek(xFilial("SN1")+SN3->N3_CBASE+SN3->N3_ITEM))
cBase	:= SN3->N3_CBASE
cItem	:= SN3->N3_ITEM
cTipo	:= SN3->N3_TIPO
cSeq	:= SN3->N3_SEQ
cSeqAnt := StrZero(Val(cSeq)-1,TamSx3('N3_SEQ')[1]) 
cIdMov := GetAdvFVal("SN4","N4_IDMOV", xFilial("SN4") + SN3->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQREAV )+cSeqAnt+Dtos(dDataMov)+"01" ,9)

If lOnOff
	If VerPadrao(cPadraoEst) 
		__nTotal += DetProva(__nHdlPrv,cPadraoEst,AllTrim("ATFA380"),__cLoteAtf)
	EndIf
	If VerPadrao(cPadraoAQ)
		__nTotal += DetProva(__nHdlPrv,cPadraoAQ,AllTrim("ATFA380"),__cLoteAtf)			
	Endif
EndIf

//Verifica Se possui pausa na deprecia็ใo e retira caso tenha apenas um impairment realizado
If !Empty(cPausaTp) .And. SN3->(ColumnPos("N3_DTBLOQ")) > 0
	nQtdMov :=  AF380QTIMP(SN3->N3_FILIAL, SN3->N3_CBASE,SN3->N3_ITEM)
	If nQtdMov == 1
		AF380CLEAN(SN3->N3_FILIAL, SN3->N3_CBASE,SN3->N3_ITEM)
	EndIf
Endif

//Exclui os movimentos do Bem
SN4->(dbSetOrder(5)) //N4_FILIAL+N4_CODBAIX+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQ
If SN4->(dbSeek(xFilial("SN4") + SN3->(N3_CODBAIX+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ) ))
	While SN4->(!EOF()) .And. SN4->(N4_FILIAL+N4_CODBAIX+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQ) == xFilial("SN4") + SN3->(N3_CODBAIX+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ)
		RecLock("SN4",.F.)
		SN4->(dbDelete())
		MsUnLock()
		SN4->(dbSkip())
	EndDo
EndIf

// Verifica็ใo da classifica็ใo de Ativo se sofre deprecia็ใo
lAtClDepr := AtClssVer(SN1->N1_PATRIM)

//Grava os Saldos

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Grava no SN5 o tipo da Imobilizao.                    ณ
//ณ Se for imobilizao normal             = 1              ณ
//ณ Se                  Reavalio         = 3              ณ
//ณ Se                  Capital            = A              ณ
//ณ Se                  Capital Prejuizo   = B              ณ
//ณ Se Baixa Capital                       = C              ณ
//ณ Se ""               Capital Prejuizo   = D              ณ
//ณ Se ""               Correcao de Capital= P              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
IF lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)
	cTipoImob := Iif(SN3->N3_TIPO$"02/05","3","1")
	cTipoCorr := "6"
Elseif SN1->N1_PATRIM $ "CSA"
	cTipoImob := "A"
	cTipoCorr := "O"
Else
	cTipoImob := "B"
	cTipoCorr := "6"
End

If !(SN3->N3_TIPO $ "07,08,09")
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	If lMultMoed
		aValorMoed := AtfMultMoe("SN3","N3_VORIG")
	EndIf
	ATFSaldo(	SN3->N3_CCONTAB,dDataMov,cTipoImob,SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3,SN3->N3_VORIG4,SN3->N3_VORIG5,"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	If lMultMoed
		aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
	EndIf
	ATFSaldo(	SN3->N3_CCONTAB,dDataMov,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
Endif
//********************************
// Controle de multiplas moedas  *
//********************************
If lMultMoed
	aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
EndIf
ATFSaldo(	SN3->N3_CCORREC,dDataMov,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,"-",,SN3->N3_SUBCCOR,,SN3->N3_CLVLCOR,SN3->N3_CCCORR,"2", aValorMoed )

IF lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)
	cTipoImob := If( !SN3->N3_TIPO $ ("08,09,10,12,50,51,52,53,54" + "," + cTypes10), "4", If(SN3->N3_TIPO $ ("10,12,50,51,52,53,54" + "," + cTypes10),"Y",If(SN3->N3_TIPO=="09","L","K")))
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	If lMultMoed
		aValorMoed := AtfMultMoe("SN3","N3_VRDACM")
	EndIf
	ATFSaldo(	SN3->N3_CCDEPR ,dDataMov,cTipoImob, SN3->N3_VRDACM1,SN3->N3_VRDACM2  ,;
		SN3->N3_VRDACM3,SN3->N3_VRDACM4,SN3->N3_VRDACM5 ,"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	If lMultMoed
		aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCDA1,0) })
	EndIf
	ATFSaldo(	SN3->N3_CCDEPR ,dDataMov,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
		"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	If lMultMoed
		aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCDA1,0) })
	EndIf
	ATFSaldo(	SN3->N3_CDESP  ,dDataMov,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
		"-",,SN3->N3_SUBCDES,,SN3->N3_CLVLDES,SN3->N3_CCCDES,"5", aValorMoed )
Endif

//Exclui o SN3
RecLock("SN3",.F.)
SN3->(dbDelete())
MsUnLock()

//Busco o Movimento de Baixa para cancelar a Baixa
SN4->(dbSetOrder(6)) //N4_FILIAL+N4_IDMOV+N4_OCORR
If SN4->(dbSeek( xFilial("SN4") + cIdMov + "01" ))
	If SN3->(dbSeek(xFilial("SN3") + SN4->(N4_CODBAIX+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQ) ))
		nRecSn3 := SN3->(Recno())
		aAdd( aParam, {"MV_PAR01", 2} )
		aAdd( aParam, {"MV_PAR02", 2} )
		aAdd( aParam, {"MV_PAR03", 2} )
	EndIf
EndIf

//Cancela a Baixa do Bem Anterior
If nRecSn3 > 0
	SN3->(dbGoto(nRecSn3))

	If lOnOff
		If VerPadrao(cPadraoBai)
			__nTotal += DetProva(__nHdlPrv,cPadraoBai,AllTrim("ATFA380"),__cLoteAtf)
		EndIf
	EndIf

	aCab :={ 	{"FN6_FILIAL"	,xFilial("SN3") 	,NIL},;
				{"FN6_CBASE"	,SN3->N3_CBASE		,NIL},;
				{"FN6_CITEM"	,SN3->N3_ITEM		,NIL},;
				{"FN6_MOTIVO"	,"08"				,NIL},;
				{"FN6_DEPREC"	,'0'				,NIL} }

	aAtivo:={ 	{"N3_FILIAL"	, xFilial("SN3")	,NIL},;
				{"N3_CBASE"		, SN3->N3_CBASE		,NIL},;
				{"N3_ITEM"		, SN3->N3_ITEM		,NIL},;
				{"N3_TIPO"		, SN3->N3_TIPO		,NIL},;
				{"N3_BAIXA"  	, SN3->N3_BAIXA		,NIL},;
				{"N3_TPSALDO"	, SN3->N3_TPSALDO	,NIL},;
				{"N3_SEQREAV"	, SN3->N3_SEQREAV	,NIL},;
				{"N3_SEQ"		, SN3->N3_SEQ		,NIL}}

	MsExecAuto({|a,b,c,d,e,f| ATFA036(a,b,c,d,e,f)},aCab,aAtivo,5,,.F.,aParam)
	If lMsErroAuto
		Help( " ", 1 ,"AF380BAIXA",,STR0168+SN3->N3_CBASE+"|"+SN3->N3_ITEM+"|"+SN3->N3_TIPO,1,0,,,,,,{STR0169}) //"Nใo foi possivel realizar o estorno da baixa referente ao bem: " #"Favor verifica possํveis movimentos no bem"
		lRet := .F.
		MostraErro() 
	EndIf
	Pergunte("AF380S",.F.)
EndIf

RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lRet


/* {Protheus.doc}
	AF380QTIMP - Funcao que verifica quantidade de Impairments realizados
	
	@author Totvs
	@since 
	@param CodBase as Character, CodItem as Character,cTipo as Character return as logical 
	@version P12
*/
Static Function AF380QTIMP(cFilSN4 as Character, cBaseSN4 as Character,cItemSN4 as Character) as Numeric

	Local cQry			as Character
	Local nQuant		as Numeric
	Local nSeq			as Numeric

	Default cFilSN4		:= ""
	Default cBaseSN4 	:= ""
	Default cItemSN4 	:= ""
	
	lRetQry		:= .T.
	nSeq		:= 1
	nQuant		:= 0

	cQry	:= " SELECT Count(1) QTD "
	cQry	+= " FROM "+ RetSqlName("SN4") +" N4 "
	cQry	+= " WHERE "
	cQry	+= " N4.N4_FILIAL = ? "
	cQry	+= " AND N4.N4_CBASE = ? "
	cQry	+= " AND N4.N4_ITEM = ?"
	cQry	+= " AND N4.N4_OCORR = ?"
	cQry	+= " AND N4.N4_ORIGEM = ? "
	cQry	+= " AND N4.D_E_L_E_T_ = ? "
	cQry 	:= ChangeQuery(cQry)

	oQueryQry := FwExecStatement():New(cQry)

	oQueryQry:SetString(nSeq++,		cFilSN4)
	oQueryQry:SetString(nSeq++,		cBaseSN4)
	oQueryQry:SetString(nSeq++,		cItemSN4)
	oQueryQry:SetString(nSeq++,		'05')
	oQueryQry:SetString(nSeq++,		'ATFA380')
	oQueryQry:SetString(nSeq++,		Space(1))
	
	nQuant := oQueryQry:ExecScalar('QTD')

	oQueryQry:Destroy()
	oQueryQry := Nil
	
Return nQuant


/* {Protheus.doc}
	AF380CLEAN - Funcao que limpa pausa na deprecia็ใo caso houver estorno
	
	@author Ewerton Franklin
	@since 
	@param CodBase as Character, CodItem as Character,cTipo as Character return as logical 
	@version P12
*/
Static Function AF380CLEAN(cFilBem as Character, cBaseBem as Character,cItemBem as Character) 

Local lTp10 	:= .F.  			as Logical
Local lTp01 	:= .F.  			as Logical
Local aArea		:= GetArea() 		as Array
Local aAreaSN3	:= SN3->(GetArea()) as Array

SN3->(dbSetOrder(1))
lTp10 := SN3->(dbSeek( cFilBem + cBaseBem + cItemBem + "10" ))
If lTp10 .And. ( !Empty(cPausaTp) .And. "10" $ cPausaTp ) .And.  cTipoGer == "12"
	If SN3->(ColumnPos('N3_DTBLOQ')) > 0 .And. !Empty(SN3->N3_DTBLOQ)
		RecLock('SN3', .F.)
			SN3->N3_DTBLOQ := cTod("")
		SN3->(MSUnlock())
	EndIf
EndIf

lTp01 := SN3->(dbSeek( cFilBem + cBaseBem + cItemBem + "01" ))
If lTp01 .And. ( !Empty(cPausaTp) .And. "01" $ cPausaTp ) .And.  cTipoGer == "12"
	If SN3->(ColumnPos('N3_DTBLOQ')) > 0 .And. !Empty(SN3->N3_DTBLOQ)
		RecLock('SN3', .F.)
			SN3->N3_DTBLOQ := cTod("")
		SN3->(MSUnlock())
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaSN3)

Return

/* {Protheus.doc}
	Atf380Repl - Funcao que replica informa็ใo da coluna posicionada no Browse pra outras linhas
	
	@author Pierre Martins do Nascimento
	@since 
	@version P12
*/

Function Atf380Repl()
	Local aArea		As Array
	Local aRet		As Array
	Local cCampo 	As Character
	Local nLineAtu	As Numeric
	Local aMvPars 	As Array
	Local nI        As Numeric
	Local nJ        As Numeric
	Local lCont     As Logical
	Local cValidSX3 As Character
	local aAreaSNJ  As Array

	Local xConteudo 	:= oGetSNJ:aCols[oGetSNJ:nAt][oGetSNJ:oBrowse:nColPos] // Variแvel sem tipo definido
	
	Private n As Numeric
	
	aArea		:= GetArea()
	aRet		:= {}
	cCampo 		:= AllTrim(aHeader[oGetSNJ:oBrowse:nColPos][2])
	nLineAtu	:= oGetSNJ:nAt
	nI          := 0
	nJ          := 0
	lCont       := .F.
	cValidSX3   := GetSX3Cache(cCampo, "X3_VALID")
	aAreaSNJ    := GetArea(oGetSNJ)

	n           := 0 //Variแvel privada do grid que cont้m a linha atual e usada nas fun็๕es de valida็ใo, mas como estamos na EnchoiceBar nใo vem preenchida

	/// GUARDA CONTEUDO DOS MV_PAR Jม ABERTOS (SE HOUVER) - Chamada de ParamBox na tela fun็ใo Atf380Repl (muda os mv_pars)
	aMvPars := GuardPars()

	For nI := 1 to len(oGetSNJ:aAlter)
		If(cCampo $ oGetSNJ:aAlter[nI])
			lCont := .T. //Continuo a Replica apenas se o campo for alterแvel pelo usuแrio
		End
	Next

	If lCont .AND. Parambox({ 	{5, STR0181, .F., 160,,.F.},; //"Replicar conte๚do do campo em todas linhas anteriores"
								{5, STR0182, .T., 160,,.F.},; //"Replicar conte๚do do campo em todas linhas abaixo"
								{7, STR0183,"SNJ",""}		}, STR0180 + " " +AllTrim(aHeader[oGetSNJ:oBrowse:nColPos][1]), aRet)  //"Condi็ใo"###"Replicar "

		If Aviso(STR0040,STR0184,{STR0051,STR0052},2)==1 //"Aten็ใo"###"Confirma substitui็ใo do conte๚do nos campos selecionados ?"###"Sim"###"Nใo"
			RegToMemory("SNJ",.T.) //Inicia variแveis de mem๓ria
			__ReadVar := "M->" + cCampo
			oGetSNJ:GoTo(nLineAtu)

			If !Empty(aRet[3])
				for nJ := 1 to Len(aHeader)
					If AllTrim(aHeader[nJ][2]) $ aRet[3]
						aRet[3] := STRTRAN(aRet[3], AllTrim(aHeader[nJ][2]), "oGetSNJ:aCols[nI,"+cValToChar(nJ)+"]")
					EndIf
				next
			Else
				aRet[3] := ".T."	
			EndIf

			If aRet[1] //Replicar p/ linhas anteriores 
				For nI := 1 to nLineAtu-1
					If !oGetSNJ:aCols[nI,Len(oGetSNJ:aCols[nI])] .AND. &(aRet[3])//Ultimo campo do Acols ้ sempre se estแ deletado(.T.) ou nใo
						aCols[nI, oGetSNJ:oBrowse:nColPos] := xConteudo
						oGetSNJ:aCols[nI, oGetSNJ:oBrowse:nColPos] := xConteudo 
						If !Empty(cValidSX3)
							n := nI
							M->&(cCampo) := xConteudo
							oGetSNJ:GoTo(n)
							&(cValidSX3) //Execu็ใo da valida็ใo do campo, ้ necessแrio principalmente para gatilho dos campos de valor
						EndIf
					EndIf
				Next
			EndIf
			If aRet[2] //Replicar p/ proximas linhas
				For nI := nLineAtu+1 to Len(oGetSNJ:aCols)
					If !oGetSNJ:aCols[nI,Len(oGetSNJ:aCols[nI])] .AND. &(aRet[3])//Ultimo campo do Acols ้ sempre se estแ deletado(.T.) ou nใo
						aCols[nI, oGetSNJ:oBrowse:nColPos] := xConteudo
						oGetSNJ:aCols[nI, oGetSNJ:oBrowse:nColPos] := xConteudo 
						If !Empty(cValidSX3)
							n := nI
							M->&(cCampo) := xConteudo
							oGetSNJ:GoTo(n)
							&(cValidSX3) //Execu็ใo da valida็ใo do campo, ้ necessแrio principalmente para gatilho dos campos de valor
						EndIf
					EndIf	
				Next
			EndIf

			oGetSNJ:GoTo(nLineAtu)
			oGetSNJ:Refresh()
			oGetSNJ:oBrowse:SetFocus()
			
		EndIf
	EndIf

	RestPars(aMvPars)
	RestArea(aArea)
	RestArea(aAreaSNJ)

Return
