#Include 'TMSAE60.ch'
#Include 'Protheus.ch'

Static lRestRepom := SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE60  ³ Autor ³ Vitor Raspa           ³ Data ³ 09.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Gerenciadores de Frota (Operadoras)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAE60()

Private cCadastro := STR0001 //'Gerenciadores de Frota'
Private aRotina   := MenuDef()

mBrowse( ,,,,'DEG')

RetIndex('DEG')
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE60Mnt³ Autor ³ Vitor Raspa           ³ Data ³ 09.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Gerenciadores de Frota (Operadoras)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE60Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAE60Mnt( cAlias, nReg, nOpc ) 

//-- EnchoiceBar
Local oEnchoice
Local lOk        := .F.

//-- Dialog
Local oDlg
Local aButtons   := {}

//-- GetDados
Local aNoFields  := {'DEH_CODOPE', 'DEH_NOMOPE'}
Local aYesFields := {}

//-- Controle de dimensoes de objetos
Local aObjects   := {}
Local aInfo      := {}

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- GetDados
Private oGetDados
Private aHeader    := {}
Private aCols      := {}
Private aPosObj    := {}

//--Operacoes X Operadoras
Private aHeaderDEJ := {}
Private aColsDEJ   := {}
Private aOperac    := {}

//--Municipios X Operadoras
Private aHeaderDEI := {}
Private aColsDEI   := {}

DEFAULT cAlias := 'DEG'
DEFAULT nReg   := 1
DEFAULT nOpc   := 2

AAdd(aButtons, {"PEDIDO",{|| TMSAE60Ope(nOpc)}, STR0008, STR0007 } ) //"Operac."###"Operacoes da Operadora"
AAdd(aButtons, {"NORMAS",{|| TMSAE60Mun(nOpc)}, STR0010, STR0009 } ) //"MunXOper"###"Municipios X Operadores"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura variaveis da Enchoice³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( cAlias, nOpc==3 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura variaveis da GetDados Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSFillGetDados( 	nOpc, 'DEH', 1, xFilial( 'DEH' ) + M->DEG_CODOPE ,; 
						{ ||  DEH->(DEH_FILIAL + DEH_CODOPE ) },;
					 	{ || .T. }, aNoFields,	aYesFields )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche o Numero do Item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(GDFieldGet("DEH_ITEM",1))
	GDFieldPut("DEH_ITEM",StrZero(1,Len(DEH->DEH_ITEM)),1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Dados do aCols e aHeader - DEJ ³
//³ Operadores X Produtos                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSAE60DEJ(nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Dados do aCols e aHeader - DEI ³
//³ Operadores X Municipios                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSAE60DEI(nOpc)

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 65, 100, .T., .T. } )
AAdd( aObjects, { 235, 110, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

//-- Enchoice
oEnchoice := MsMGet():New( cAlias, nReg, nOpc,,,,, aPosObj[1],, 3,,,,,,.T. )

//--GetDados
oGetDados := MSGetDados():New(	aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ],; 
											nOpc, 'TMSAE60LOk','TMSAE60TOk','+DEH_ITEM',;
											IIf(nOpc == 3 .Or. nOpc == 4,.T.,Nil),,,,99)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,	{|| If(TMSAE60TOk(), ( lOk := .T.,oDlg:End()), lOk := .F. )} ,;
													{|| lOk := .F., oDlg:End()},,aButtons )

If nOpc != 2 .And. lOk
	TMSAE60Grv( M->DEG_CODOPE, nOpc )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE60LOk³ Autor ³ Vitor Raspa           ³ Data ³ 09.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE60LOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAE60LOk()
Local lRet      := .T.
Local aCpoCheck := {'DEH_CODPRO'}

If !GDDeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey(aCpoCheck,4)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE60TOk³ Autor ³ Vitor Raspa           ³ Data ³ 09.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tudo Ok da GetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAE60TOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAE60TOk()
Local lRet := .T.
Local nAux                                              
Local nDel := 0

/*Variáveis para quebra do Arquivo .PFX*/ 
Local cRet 			:= ""
Local cDirectory 	:= GetSrvProfString("Startpath","")
Local cBarra		:= If(IsSrvUnix(), "/", "\")
Local aFilial 		:= FWArrFilAtu(cEmpAnt, cFilAnt)
Local cArqCERT 		:= cDirectory+AllTrim(aFilial[18])+"_certif_cert"
Local cArqKEY 		:= cDirectory+AllTrim(aFilial[18])+"_certif_key"
Local cCERTDig		:= ""
Local lTMAE60BCer   := FindFunction("TMAE60BCer")

cDirectory := GetSrvProfString("StartPath","") + If(Right(GetSrvProfString("StartPath",""),1) == cBarra,"",cBarra)
If	SubStr(cDirectory, Len(cDirectory), 1 ) != '\' .And. SubStr(cDirectory, Len(cDirectory), 1 ) != '/'
	cDirectory := cDirectory + '\'
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a Enchoice³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := Obrigatorio( aGets, aTela )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a GetDados Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := TAE60OpLOk()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as linhas estao Ativas³
//³GetDados Principal                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. M->DEG_CODOPE <> "02" .And. !lRestRepom //Projeto Pamcard
	nDel := 0
	For nAux := 1 To Len(aCols)
		If aCols[nAux,Len(aHeader)+1]
			nDel++
		EndIf
	Next
	If Len(aCols) == nDel
		Help('',1,'TMSAE6001') //--'Produto não Informado!'
		lRet := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as linhas estao Ativas³
//³GetDados - Operacoes X Operadoras ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. M->DEG_CODOPE == "01" .And. !lRestRepom //Projeto Pamcard
	If Empty(aColsDEJ)	
		Help('',1,'TMSAE6002') //-- 'Operações não Informadas!'
		lRet := .F.
	Else
		nDel := 0
		For nAux := 1 To Len(aColsDEJ)
			If aColsDEJ[nAux,Len(aHeaderDEJ)+1]
				nDel++
			EndIf
		Next
		If Len(aColsDEJ) == nDel
			Help('',1,'TMSAE6002') //-- 'Operações não Informadas!'
			lRet := .F.
		EndIf
	EndIf
ElseIf lRet 
	cCERTDig := AllTrim(M->DEG_CERTDG)
	
	If Len(AllTrim(cCERTDig)) == TamSx3("DEG_CERTDG")[1] .AND. Upper( SubStr( cCERTDig, Len(cCERTDig) - 2, 3 ) ) <> 'PFX'
		lRet := .F.
		Help( "", 1, "TMSAE60TOk", , STR0024, 1, 0, , , , , , { STR0025 } ) //"O campo Certificado Digital excedeu o limite de caracteres." - //"Verifique o conteudo do campo Certif. Dig. (DEG_CERTDG)."
	EndIf
	
	If lRet .AND. Upper(SubStr(cCERTDig,Len(cCERTDig) - 2,3)) == 'PFX'
		If Empty(M->DEG_CODACE)
			Help('',1,'TMSAE6009') //-- 'Chave de acesso do certificado não Informada!'
			lRet := .F.
		Else		
			If lTMAE60BCer //Função para a geração do arquivo  .PEM, todas as alterações serão concetradas na função que está no fonte TMSAE60B 'Novo Cadastro de Operadoras'
				lRet:= TMAE60BCer(M->DEG_CERTDG,M->DEG_CODACE,cArqCERT,cArqKey, @cRet)
			Else
				lRet:= TMAE60CCer(M->DEG_CERTDG,M->DEG_CODACE,cArqCERT,cArqKey, @cRet)
			EndIf
			If !lRet 
				Help(Nil,Nil,'HELP',Nil, cRet , 1, 0) 
			EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE60Grv³ Autor ³ Vitor Raspa          ³ Data ³ 09.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar dados                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE60Grv( ExpC1, ExpN1 )                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Codigo da Operadora                                 ³±±
±±³          ³ ExpN1: Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAE60Grv( cCodOpe, nOpc )
Local nAux  := 0
Local nAux2 := 0

Local aArea    := GetArea()
Local aAreaDEG := DEG->(Getarea())
Local aAreaDEH := DEH->(Getarea())
Local aAreaDEJ := DEJ->(GetArea())
Local aAreaDEI := DEI->(GetArea())

Local nItemDEJ := Ascan(aHeaderDEJ, {|x| AllTrim(x[2]) == 'DEJ_ITEM'})
Local nItemDEI := Ascan(aHeaderDEI, {|x| AllTrim(x[2]) == 'DEI_ITEM'})

If	nOpc == 5
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³ EXCLUSAO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄ¿
		//³CABECALHO³
		//ÀÄÄÄÄÄÄÄÄÄÙ
		RecLock('DEG', .F.)
		DbDelete()
		MsUnLock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OPERADORES x PRODUTOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEH->(DbSetOrder(1))
		While DEH->( MsSeek( xFilial('DEH') + cCodOpe, .F. ) )
			RecLock('DEH', .F.)
			DbDelete()
			MsUnLock()
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OPERADORES x OPERACOES³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEJ->(DbSetOrder(2))
		While DEJ->( MsSeek( xFilial('DEJ') + cCodOpe, .F. ) )
			RecLock('DEJ',.F.)
			DbDelete()
			MsUnLock()
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OPEARDORES x MUNICIPIOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEI->( DbSetOrder(1))
		While DEI->( MsSeek( xFilial('DEI') + cCodOpe, .F. ) )
			RecLock('DEI',.F.)
			DbDelete()
			MsUnLock()
		EndDo

	End Transaction

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ INCLUSAO/ALTERACAO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction

		//-- Cabecalho
		RecLock("DEG",(nOpc == 3))
		Aeval( dbStruct(),{|aFieldName,nI| FieldPut( nI, If('FILIAL' $ aFieldName[1],;
													   xFilial( "DEG" ), M->&(aFieldName[1]) ) ) } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OPERADORES x PRODUTOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nAux := 1 To Len( aCols )
			If	!GDDeleted( nAux )
				DEH->(dbSetOrder(1))
				If	DEH->( MsSeek( xFilial('DEH') + cCodOpe + GDFieldGet( 'DEH_ITEM', nAux ), .F. ) )
					RecLock('DEH', .F.)
				Else
					RecLock('DEH', .T.)
					DEH->DEH_FILIAL := xFilial('DEH')
					DEH->DEH_CODOPE := cCodOpe
				EndIf

				For nAux2 := 1 To Len(aHeader)
					If	aHeader[nAux2,10] != 'V'
						FieldPut(FieldPos(aHeader[nAux2,2]), aCols[nAux,nAux2])
					EndIf
				Next
				MsUnLock()
			Else
				If	DEH->( MsSeek( xFilial('DEH') + cCodOpe + GDFieldGet( 'DEH_ITEM', nAux ), .F. ) )
					RecLock('DEH',.F.)
					DbDelete()
					MsUnLock()
				EndIf
			EndIf
		Next
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OPERADORES x OPERACOES³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nAux := 1 To Len(aColsDEJ)
			If !aColsDEJ[nAux,Len(aHeaderDEJ)+1]
				DEJ->(DbSetOrder(1))
				If DEJ->(MsSeek( xFilial('DEJ') + cCodOpe + aColsDEJ[nAux,nItemDEJ], .F. ) )
					RecLock('DEJ',.F.)
				Else
					RecLock('DEJ',.T.)
					DEJ->DEJ_FILIAL := xFilial('DEJ')
					DEJ->DEJ_CODOPE := cCodOpe
				EndIf
				For nAux2 := 1 To Len(aHeaderDEJ)
					If aHeaderDEJ[nAux2,10] != 'V'
						FieldPut(FieldPos(aHeaderDEJ[nAux2,2]), aColsDEJ[nAux,nAux2])
					EndIf
				Next
				MsUnLock()
			Else
				DEJ->(DbSetOrder(1))
				If	DEJ->( MsSeek( xFilial('DEJ') + cCodOpe + aColsDEJ[nAux,nItemDEJ], .F. ) )
					RecLock('DEJ', .F.)
					DbDelete()
					MsUnLock()
				EndIf
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OPERADORES x MUNICIPIOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nAux := 1 To Len(aColsDEI)
			If !aColsDEI[nAux,Len(aHeaderDEI)+1]
				DEI->(DbSetOrder(1))
				If DEI->(MsSeek( xFilial('DEI') + cCodOpe + aColsDEI[nAux,nItemDEI], .F. ) )
					RecLock('DEI',.F.)
				Else
					RecLock('DEI',.T.)
					DEI->DEI_FILIAL := xFilial('DEI')
					DEI->DEI_CODOPE := cCodOpe
				EndIf
				For nAux2 := 1 To Len(aHeaderDEI)
					If aHeaderDEI[nAux2,10] != 'V'
						FieldPut(FieldPos(aHeaderDEI[nAux2,2]), aColsDEI[nAux,nAux2])
					EndIf
				Next 
				MsUnLock()
			Else
				DEI->(DbSetOrder(1))
				If	DEI->( MsSeek( xFilial('DEI') + cCodOpe + aColsDEI[nAux,nItemDEI], .F. ) )
					RecLock('DEI', .F.)
					DbDelete()
					MsUnLock()
				EndIf
			EndIf
		Next

	End Transaction

EndIf

RestArea(aAreaDEG)
RestArea(aAreaDEH)
RestArea(aAreaDEJ)
RestArea(aAreaDEI)
RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE60Vld³ Autor ³ Vitor Raspa           ³ Data ³ 09.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE60Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE60                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAE60Vld()

Local lRet   := .T.
Local nAchou := 0
Local cCampo := ReadVar()

If !TmsNewOper()
	If cCampo $ 'M->DEJ_SERTMS'
		If GDFieldPos('DEJ_DESSVT') > 0
			GDFieldPut('DEJ_DESSVT', TMSValField("M->DEJ_SERTMS",.F.,"DEJ_DESSVT"),n)
		EndIf
	
	ElseIf cCampo $ 'M->DEJ_TIPTRA'
		If GDFieldPos('DEJ_DESTPT') > 0
			GDFieldPut('DEJ_DESTPT', TMSValField('M->DEJ_TIPTRA',.F.,'DEJ_DESTPT'),n)
		EndIf
	
	ElseIf cCampo $ 'M->DEJ_OPERAC'
		If Empty(aOperac) .And. !Empty(M->DEJ_OPERAC)
			TMSOper(.F., M->DEG_CODOPE)
		EndIf
	
		If !Empty(aOperac)
			nAchou := AScan(aOperac, {|x| AllTrim( x[1] ) == AllTrim( M->DEJ_OPERAC )})
			If nAchou > 0 
				If GDFieldPos('DEJ_DESOPE') > 0
					GDFieldPut('DEJ_DESOPE', aOperac[nAchou,2],n)
				EndIf
			Else
				Help('',1,'TMSAE6003') //-- 'Operação Inválida!'
				lRet := .F.
			EndIf
		Else
			Help('',1,'TMSAE6004') //-- "Problemas na Comunicação com a Operadora impedem a Validação do Campo!"
		EndIf
	
	ElseIf cCampo $ 'M->DEI_REGORI'
		If GDFieldPos('DEI_REGORI') > 0
			GDFieldPut('DEI_REGORI', Posicione('DUY',1,xFilial('DUY')+GDFieldGet('DEI_CDRORI',n),'DUY_DESCRI') )
		EndIf
	
	ElseIf cCampo $ 'M->DEH_CODPRO'
		SB1->(DbSetOrder(1))
		If SB1->(MsSeek(xFilial('SB1')+M->DEH_CODPRO)) 
			If IsProdMod(SB1->B1_COD) .Or. (SB1->B1_TIPO == "BN" .Or. (SB1->B1_TIPO == "BN" .And. !MatBuyBN()))
				lRet := .F.
				Help('',1,'TMSAE6008') //-- 'Produto invalido!'
			EndIf
		Else
			lRet := .F.
		EndIf
	ElseIf cCampo $ 'M->DEG_FILCTR'
		M->DEG_NOMCTR := Posicione('SM0',1,cEmpAnt+M->DEG_FILCTR,'M0_FILIAL')      
	
	ElseIf cCampo $ 'M->DEG_TMPESP'
		If Empty(M->DEG_TMPESP) 
			If lRestRepom .And. M->DEG_CODOPE == '01'
				Help('',1,"OBRIGAT2",,RetTitle('DEG_TMPESP'),04,01)
				lRet:= .F.
			EndIf
		Else
			lRet:= IsNumeric(M->DEG_TMPESP)
		EndIf
		
	ElseIf cCampo $ "M->DEG_GERCTC"
		If Empty(M->DEG_GERCTC) 
			If lRestRepom .And. M->DEG_CODOPE == '01'
				Help('',1,"OBRIGAT2",,RetTitle('DEG_GERCTC'),04,01)
				lRet:= .F.
			EndIf
		EndIf
	
	ElseIf cCampo $ "M->DEG_USAAGE"
		If M->DEG_USAAGE == "1" .And. M->DEG_AUTPAG == "1"
			Help("",1,"TMSAE6010") //-- "Não é possível que o uso do agendamento e a autorização de pagamento estejam ativos ao mesmo tempo."
			lRet := .F.
		EndIf
	
	ElseIf cCampo $ "M->DEG_AUTPAG"
		If M->DEG_AUTPAG == "1" .And. M->DEG_USAAGE == "1"
			Help("",1,"TMSAE6010") //-- "Não é possível que o uso do agendamento e a autorização de pagamento estejam ativos ao mesmo tempo."
			lRet := .F.
		EndIf
	
	EndIf
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE60Ope³ Autor ³Vitor Raspa            ³ Data ³ 12.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Operacoes da Operadora                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAE60Ope( ExpN1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSAE60                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAE60Ope(nOpc)
Local oDlg
Local oGetDEJ
Local nAux := 0
Local lOk  := .F.

If  M->DEG_CODOPE <> "02" //Projeto Pamcard
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SaveInter()

	n       := 1
	aHeader := aClone(aHeaderDEJ)
	aCols   := {}

	If Len(aColsDEJ)  > 0
		aCols	:= aClone(aColsDEJ)
		Aeval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols	nao poderao estar deletados 
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aCols,Array(Len(aHeader)+1))
		For nAux := 1 to Len(aHeader)
			aCols[1][nAux] := CriaVar(aHeader[nAux][2])
			aCols[1][Len(aHeader)+1] := .F.
		Next

		GDFieldPut('DEJ_ITEM',StrZero(1,Len(DEJ->DEJ_ITEM)),1)	
	EndIf

	DEFINE MSDIALOG oDlg FROM 94 ,104 TO 310,650 TITLE STR0008 Of oMainWnd PIXEL //"Operacoes do Gerenciador de Frotas"
	oGetDEJ := MSGetDados():New(30,2,105,270,nOpc,'TAE60OpLOk','AllwaysTrue()','+DEJ_ITEM',;
											IIf(nOpc == 3 .Or. nOpc == 4,.T.,Nil))

	@ 18,03 SAY STR0011 Of oDlg PIXEL SIZE 80 ,9 //"Gerenciador de Frotas (Operador):"
	@ 18,90 SAY M->DEG_CODOPE + '/' + M->DEG_NOMOPE Of oDlg PIXEL SIZE 100,9

	//-- Esta Funcao corrige uma falha da GetDados ao mostrar os itens deletados
	TMSA011AjuMin(aColsDEJ, aCols)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDEJ:TudoOk(), ( lOk := .T., oDlg:End()), (lOk := .F.))},;
													{|| oDlg:End()} ) CENTERED

	If lOk
		aColsDEJ := aClone(aCols)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura as Variaveis da GetDados Anterior                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestInter()
Else
	Help('',1,'TMSAE6007') //Opção não disponível para","essa operadora."
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TAE60OpLOk³ Autor ³ Vitor Raspa           ³ Data ³ 09.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TAE60OpLOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TAE60OpLOk()
Local lRet      := .T.
Local aCpoCheck := {'DEJ_SERTMS','DEJ_TIPTRA','DEJ_OPERAC'}

DbSelectArea('DEJ')

//-- Nao avalia linhas deletadas.
If M->DEG_CODOPE == "01" //-- Repom
	If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
		//-- Analisa se ha itens duplicados na GetDados.
		lRet := GDCheckKey(aCpoCheck,4)
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE60DEJ³ Autor ³ Vitor Raspa           ³ Data ³ 12.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o aCols e aHeader do DEJ (Operacoes da Operadora) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE60                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAE60DEJ( nOpc )
Local nAux 		:= 0
Local cTmsRepom := SuperGetMV( 'MV_VSREPOM',, '1' )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeaderDEJ := ApBuildHeader("DEJ", {"DEJ_CODOPE", "DEJ_NOMOPE"})

//-- Tratamento para as Operacoes da Operadora
If nOpc <> 3 .And. DEG->DEG_CODOPE == "01" //Projeto Pamcard
	DEJ->(DbSetOrder(1))
	DEJ->(MsSeek(xFilial('DEJ')+DEG->DEG_CODOPE))
	While DEJ->(!Eof() .And. DEJ_FILIAL+DEJ_CODOPE == xFilial('DEJ') + DEG->DEG_CODOPE)
		Aadd(aColsDEJ,Array(Len(aHeaderDEJ)+1))
		For nAux := 1 To Len(aHeaderDEJ)
			If	aHeaderDEJ[nAux,10] != "V"
				aColsDEJ[Len(aColsDEJ),nAux] := DEJ->(FieldGet(FieldPos(aHeaderDEJ[nAux,2])))
			Else
				aColsDEJ[Len(aColsDEJ),nAux] := CriaVar(aHeaderDEJ[nAux,2])
			EndIf
		Next

		aColsDEJ[Len(aColsDEJ),Len(aHeaderDEJ)+1] := .F.

		DEJ->(dbSkip())
	EndDo

	For nAux := 1 To Len(aColsDEJ)
		If Empty(aOperac)
			TMSOper(.F., M->DEG_CODOPE)
		EndIf

		If !Empty(aOperac)
			If AScan(aOperac,{|x| AllTrim(x[1]) == AllTrim(aColsDEJ[nAux, AScan(aHeaderDEJ,{|x| AllTrim(x[2]) == "DEJ_OPERAC"})])}) > 0
				If AScan(aHeaderDEJ, {|x| AllTrim(x[2]) == "DEJ_DESOPE"}) > 0
					aColsDEJ[nAux,AScan(aHeaderDEJ,{|x| AllTrim(x[2]) == "DEJ_DESOPE"})] := aOperac[ AScan(aOperac,{|x| AllTrim(x[1]) == AllTrim(aColsDEJ[nAux,AScan(aHeaderDEJ,{|x| AllTrim(x[2]) == "DEJ_OPERAC"})])}),2]
				EndIf
			EndIf
		Else
			If AllTrim(cTmsRepom) <> '2.2'
				Help('',1,'TMSAE6004') //-- "Problemas na Comunicação com a Operadora impedem a Validação do Campo!"
			EndIf
		EndIf
	Next
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE60Mun ³ Autor ³Vitor Raspa           ³ Data ³ 12.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Muncipios da Operadora                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAE60Oper( ExpN1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSAE60                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE60Mun(nOpc)
Local oDlg
Local oGetDEI
Local nAux
Local lOk := .F.

If M->DEG_CODOPE <> "02" //Projeto Pamcard
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SaveInter()

	n       := 1
	aHeader := aClone(aHeaderDEI)
	aCols	  := {}

	If Len(aColsDEI)  > 0
		aCols	:= aClone(aColsDEI)
		Aeval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols	nao poderao estar deletados 
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aCols,Array(Len(aHeader)+1))
		For nAux := 1 to Len(aHeader)
			aCols[1][nAux] := CriaVar(aHeader[nAux][2])
			aCols[1][Len(aHeader)+1] := .F.
		Next

		GDFieldPut('DEI_ITEM',StrZero(1,Len(DEI->DEI_ITEM)),1)	
	EndIf

	DEFINE MSDIALOG oDlg FROM 94 ,104 TO 310,650 TITLE STR0010 Of oMainWnd PIXEL //"Municipios X Operadores"

	oGetDEI := MSGetDados():New(30,2,105,270,nOpc,'TAE60MuLOk','AllwaysTrue()','+DEI_ITEM',;
											IIf(nOpc == 3 .Or. nOpc == 4,.T.,Nil))

	@ 18,03 SAY STR0011 Of oDlg PIXEL SIZE 80 ,9 //"Gerenciador de Frotas (Operador):"
	@ 18,90 SAY M->DEG_CODOPE + '/' + M->DEG_NOMOPE Of oDlg PIXEL SIZE 100,9

	//-- Esta Funcao corrige uma falha da GetDados ao mostrar os itens deletados
	TMSA011AjuMin(aColsDEI, aCols)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If( oGetDEI:TudoOk(),( lOk := .T., oDlg:End()),(lOk := .F.))},;
													{|| oDlg:End()} ) CENTERED

	If lOk
		aColsDEI := aClone(aCols)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura as Variaveis da GetDados Anterior                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestInter()

Else
	Help('',1,'TMSAE6007')   //Opção não disponível para","essa operadora."
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE60DEI³ Autor ³ Vitor Raspa           ³ Data ³ 12.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o aCols e aHeader do DEI (Municipios da Operadora)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE60                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAE60DEI(nOpc)
Local nAux

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeaderDEI := ApBuildHeader("DEI", {"DEI_CODOPE", "DEI_NOMOPE"})

//-- Tratamento para as Operacoes da Operadora
If nOpc <> 3 .And. DEG->DEG_CODOPE <> "02" //Projeto Pamcard
	DEI->(DbSetOrder(1))
	DEI->(MsSeek(xFilial('DEI')+DEG->DEG_CODOPE))
	While DEI->(DEI_FILIAL+DEI_CODOPE) == xFilial('DEI') + DEG->DEG_CODOPE
		Aadd(aColsDEI,Array(Len(aHeaderDEI)+1))
		For nAux := 1 To Len(aHeaderDEI)
			If	aHeaderDEI[nAux,10] != "V"
				aColsDEI[Len(aColsDEI),nAux] := DEI->(FieldGet(FieldPos(aHeaderDEI[nAux,2])))
			Else
				aColsDEI[Len(aColsDEI),nAux] := CriaVar(aHeaderDEI[nAux,2])
			EndIf
		Next

		aColsDEI[Len(aColsDEI),Len(aHeaderDEI)+1] := .F.

		DEI->(dbSkip())
	EndDo
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TAE60MuLOk³ Autor ³ Vitor Raspa           ³ Data ³ 09.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TAE60MuLOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TAE60MuLOk()
Local lRet      := .T.
Local aCpoCheck := {'DEI_CDRORI'}

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey(aCpoCheck,4)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSOper  ³ Autor ³ Vitor Raspa           ³ Data ³ 12.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3( DEJ ) para visualizar as Operacoes da Operado_³±±
±±³          ³ ra (Gerenciador de Frotas)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE60                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSOper(lF3, cCodOpe)
Local lRet := .T.
Local cTitulo
Local nTMSItem

Default lF3     := .T.
Default cCodOpe := M->DEG_CODOPE

If Empty( aOperac )
	If TmsNewOper()
		If !lRestRepom
			MsgRun( STR0013 , STR0012 , {|| CursorWait(), aOperac := TMSE60BOpe(cCodOpe,@lRet), CursorArrow()}) //"Realizando comunicação com a Operadora..." ### "Aguarde..."
		Else
			MsgRun( STR0013 , STR0012 , {|| CursorWait(), aOperac := TMSE60BGet(cCodOpe,@lRet), CursorArrow()}) //"Realizando comunicação com a Operadora..." ### "Aguarde..."
		EndIf
	Else
		If !lRestRepom
			MsgRun( STR0013 , STR0012 , {|| CursorWait(), aOperac := F3TMSOper(cCodOpe), CursorArrow()}) //"Realizando comunicação com a Operadora..." ### "Aguarde..."
		Else
			MsgRun( STR0013 , STR0012 , {|| CursorWait(), aOperac := F3GETOper(cCodOpe), CursorArrow()}) //"Realizando comunicação com a Operadora..." ### "Aguarde..."
		EndIf
	EndIf
EndIf

If !Empty( aOperac ) .And. lF3
	//-- Apresenta a tela para selecao do item.
	cTitulo		:= Posicione('SX3', 2, 'DEG_CODOPE', 'X3Titulo()')
	nTMSItem	:= TMSF3Array( {STR0014,STR0015}, aOperac, cTitulo ) //"Codigo"###"Descricao"
	If	nTMSItem > 0
		//-- VAR_IXB eh utilizada como retorno da consulta F3 DEJ.
		VAR_IXB := aOperac[ nTMSItem, 1 ]
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ F3TMSOper³ Autor ³ Vitor Raspa           ³ Data ³ 12.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acessa o WebService para obter as operacoes da Operadora   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array contendo o Codigo e Descricao da Operacao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE60                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F3TMSOper( cCodOpe )
Local oObj
Local cError   := ""
Local cWarning := ""
Local oXML
Local nAux
Local aMsgErr  := {}
Local lTMSXML  := GetMV( 'MV_TMSXML',, .F. )
Local lRet     := .T.

If cCodOpe == '01' .And. AllTrim( SuperGetMV( 'MV_VSREPOM',, '1' ) ) <> '2.2'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PREPARACAO PARA CONECTAR AO WS - REPOM³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj := WSIntegracao():New()
	oObj:cStrCliente           := AllTrim(M->DEG_IDOPE)
	oObj:cstrAssinaturaDigital := AllTrim(M->DEG_CODACE)
	oObj:_URL                  := M->DEG_URLWS //-- Seta a URL para acesso aos servicos da Operadora

	If oObj:ConsultaOperacoes()
		If oObj:lConsultaOperacoesResult

			//-- Remove acentos e caracteres especiais
			oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )

			//-- Gera XML em disco
			If lTMSXML
				TMSLogXML( oObj:cStrXMLOut, 'ConsultaOperacoesResult.XML' )
			EndIf

			//Gera o Objeto XML ref. ao script
			oXML := XmlParser( oObj:cStrXMLOut, "_", @cError, @cWarning )

			If XMLChildCount( oXML:_Operacoes ) > 0
				If ValType( oXML:_Operacoes:_Operacao ) == 'A'
					For nAux := 1 To Len(oXML:_OPERACOES:_OPERACAO)
						AAdd(aOperac, { oXML:_OPERACOES:_OPERACAO[nAux]:_OPERACAO_CODIGO:Text,;
										 oXML:_OPERACOES:_OPERACAO[nAux]:_OPERACAO_DESCRICAO:Text } )
					Next
					ASort( aOperac,,, {|x,y| Val(x[1]) < Val(y[1])} )
				Else
					AAdd(aOperac, { oXML:_OPERACOES:_OPERACAO:_OPERACAO_CODIGO:Text,;
									 oXML:_OPERACOES:_OPERACAO:_OPERACAO_DESCRICAO:Text } )
				EndIf
			EndIf
		Else
			aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
			lRet := .F.
		EndIf
	Else
		aMsgErr := TMSErrOper(cCodOpe,, '2')
		lRet := .F.
	EndIf
EndIf

//-- Trata os erros ocorridos na comunicacao com a Operadora
If !lRet .And. !Empty(aMsgErr)
	TmsMsgErr( aMsgErr )
EndIf

Return(aOperac)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
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
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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

Private aRotina	:= {	{ STR0002, 'AxPesqui',		0, 1, 0, .F. },; //'Pesquisar'
						{ STR0003, 'TMSAE60Mnt',	0, 2, 0, NIL },; //'Visualizar'
						{ STR0004, 'TMSAE60Mnt',	0, 3, 0, NIL },; //'Incluir'
						{ STR0005, 'TMSAE60Mnt',	0, 4, 0, NIL },; //'Alterar'
						{ STR0006, 'TMSAE60Mnt',	0, 5, 0, NIL } } //'Excluir'

If FindFunction("TMS15TstR")
	AAdd( aRotina, { STR0023, 'TMS15TstR', 0, 6, 0, NIL } ) //"Teste Comunicação"
EndIf

If ExistBlock("TME60MNU")
	ExecBlock("TME60MNU",.F.,.F.)
EndIf

Return(aRotina)


/*/{Protheus.doc} TMAE60CCer
Função que converte o certificado em 3 arquivos .PEM, sendo eles:
Certificado de Autorização, Certificado de Cliente e Chave Privada.90

@param cArquivo, Caminho do arquivo .PFX do certificado
@param cPsw, Senha de autorização do certificado
@param cArqCA, Caminho do arquivo CA que será criado
@param cArqCERT, Caminho do arquivo CERT que será criado
@param cArqKEY, Caminho do arquivo KEY que será criado 
@param cRet, Mensagem de retorno, em caso de erro

@author Leandro Paulino	
@since 02/04/2018
@version 12.1.17
/*/
Static Function TMAE60CCer( cCamArq, cPsw, cArqCERT,cArqKey, cRet )	

	Local cError 		:= ""
	Local cDirectory 	:= GetSrvProfString("Startpath","")
	Local aChvExt		:= {}
	Local nTamArq		:= 0
	Local cArquivo 		:= ""
	Local lRet			:= .T.	
	Local cBarra		:= If(IsSrvUnix(), "/", "\")
	Local aFilial 		:= FWArrFilAtu(cEmpAnt, cFilAnt)
	Local cContent      := ""
	Local cArqCA 	    := aFilial[18]+"_certif_ca"
	Local cArqCLCERT 	:= aFilial[18]+"_certif_cl"

	Default cCamArq 	:= ""	
	Default cPsw 		:= ""	
	Default cArqCERT 	:= aFilial[18]+"_certif_cert"
	Default cArqKEY 	:= aFilial[18]+"_certif_key"
	Default cRet 		:= ""
	
	cCamArq	:= AllTrim( cCamArq )
	
	If !Empty(cCamArq)

		If IsSrvUnix()
			If At("\", cCamArq) > 0
				cBarra := "\"
			EndIf 
		EndIf 
	
		aChvExt 	:= Str2Arr(Upper(cCamArq), cBarra)  
		nTamArq 	:= Len(aChvExt[Len(aChvExt)])
		cArquivo	:= Lower(AllTrim(aChvExt[Len(aChvExt)]))
		
		cPsw 		:= AllTrim( cPsw )
		
		//Garante que os arquivos serão gerados com a extensão correta
		If Right( Upper( cArqCERT ), 4 ) != ".PEM"			
			cArqCERT += ".pem"
		Endif
		If Right( Upper( cArqCLCERT ), 4 ) != ".PEM"			
			cArqCLCERT += ".pem"
		Endif
		If Right( Upper( cArqKEY ), 4 ) != ".PEM"
			cArqKEY += ".pem"
		EndIf
		If Right( Upper( cArqCA ), 4 ) != ".PEM"
			cArqCA += ".pem"
		EndIf
		
		If IsSrvUnix()
			Copy File &(cCamArq) To &(cDirectory+ "/"+ cArquivo)
		Else 
			Copy File &(cCamArq) To &(cDirectory+cArquivo)
		EndIf 

		//Gera o arquivo de Chave Privada
		If ! PFXCA2PEM( cArquivo, cArqCA, @cError, cPsw )
			cRet := OemToAnsi(STR0020) + cError //"Erro ao extrair a chave privada. "
			lRet := .F.
		Endif

		//Gera o arquivo de Certificado de Cliente
		If PFXCert2PEM( cArquivo, cArqCLCERT, @cError, cPsw )
			//Gera o arquivo de Chave Privada
			If ! PFXKey2PEM( cArquivo, cArqKEY, @cError, cPsw )
				cRet := OemToAnsi(STR0020) + cError //"Erro ao extrair a chave privada. "
				lRet := .F.
			Endif
		Else
			cRet := OemToAnsi(STR0021) + cError //"Erro ao extrair o Certificado de Cliente. "
			lRet := .F.
		Endif		
	EndIf
	
	    // lê certificados do cliente + CA 
    cContent := MemoRead( cArqCLCERT )
    cContent += MemoRead( cArqCA )

    // grava novo certificado no formato PEM contendo certificados do cliente + CA
    MemoWrite( cArqCERT , cContent )


Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} F3GETOper()
Consulta Operação na Repom - Versao 2.2  (GET /Operation)
@author Katia
@since 20/11/2020
@version 12.1.31
/*/
//--------------------------------------------------------------------
Static Function F3GETOper( cCodOpe )
Local aMsgErr  := {}
Local lRet     := .T.
Local aOperac  := {}
Local aRet     := {}
Local nX       := 0

If cCodOpe == '01'	
	aRet:= TM15GetOpe()  

	For nX:= 1 To Len(aRet)
		AAdd(aOperac,{aRet[nx][1],aRet[nx][2]})
	Next nX

	If Len(aOperac) == 0
		aMsgErr := TMSErrOper(cCodOpe,'', '1')
		lRet := .F.
	EndIf

EndIf

//-- Trata os erros ocorridos na comunicacao com a Operadora
If !lRet .And. !Empty(aMsgErr)
	TmsMsgErr( aMsgErr )
EndIf

FWFreeArray(aRet)
Return(aOperac)

//-----------------------------------------------------------------
/*/{Protheus.doc} 	TMSAE60Whe()
Validacoes p/ edicao do campo (X3_WHEN)
@author Katia
@since 24/11/2020
@version 12.1.31
/*/
//--------------------------------------------------------------------
Function TMSAE60Whe(cCampo)
Local lRet     := .F.

Default cCampo := ReadVar()

If cCampo $ 'DEG_TMPESP|DEG_REPQUI|DEG_GERCTC' 
	If lRestRepom .And. M->DEG_CODOPE == "01"
		lRet:= .T.
	EndIf
EndIf

Return lRet

