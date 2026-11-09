#include "FWMBROWSE.CH"
#include "QIEA270.CH"
#include "TOTVS.CH"

// Constantes do aviso de descontinuacao
#Define QIEA270_PROG    "QIEA270"       // Chave do programa no FWProfile (nOpcao 1 - Fatores I.A.)
#Define QIEA271_PROG    "QIEA271"       // Chave do programa no FWProfile (nOpcao 2 - Fatores I.Q.S.)
#Define QIEA270_TASK    "AVSNOVA270"    // Chave da task (max 10 chars!)
#Define QIEA270_DIAS    7               // Dias para suprimir o aviso

/*/{Protheus.doc} QIEA270AuxClass
Classe agrupadora de métodos auxiliares do QIEA270/QIEA271
@author willian.ramalho
@since 25/08/2026
@version P12
/*/
CLASS QIEA270AuxClass FROM LongNameClass

    METHOD new() Constructor

	METHOD verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx(nOpcao)
	METHOD exibeAvisoSubstituicaoPorSmartx(nOpcao)

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author willian.ramalho
@since 25/08/2026
@version P12
/*/
METHOD new() CLASS QIEA270AuxClass
Return Self

Static Function MenuDef()

	Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},; // "Pesquisar" 
						{OemToAnsi(STR0002),"AxVisual"  , 0 , 2    },; // "Visualizar"
						{OemToAnsi(STR0003),"A270ITab"  , 0 , 3    },; // "Incluir"   
						{OemToAnsi(STR0004),"A270ITab"  , 0 , 4    },; // "Alterar"   
						{OemToAnsi(STR0005),"A270DTab"  , 0 , 5, 3 } } // "Excluir"

Return aRotina

/* {Protheus.doc} QIEA270  Programa Atualizacao Tabela IA(K) e IQS(FC)
@author   Vera Lucia S. Simoes
@since    19/11/1997
@param01  nOpcao, numeric, Opcao selecionada (1 = Tabela - IA, 2 = Tabela - IQS)
Alteracoes:
- Paulo Emidio, 02/10/2000: Alteracao no filtro para que o mesmo seja efetuado atraves da mBrowse().
*/
function QIEA270(nOpcao)

	Local oQIEA270Aux := Nil

	// Define o cabecalho da tela de atualizacoes
	Private cCadastro := ""
	Private nTab      := 0
	Private uCodTab   := ""

	/*
	 Define Array contendo as Rotinas a executar do programa 
	 ----------- Elementos contidos por dimensao ------------
	 1. Nome a aparecer no cabecalho                         
	 2. Nome da Rotina associada                             
	 3. Usado pela rotina                                    
	 4. Tipo de Transacao a ser efetuada                     
	    1 - Pesquisa e Posiciona em um Banco de Dados        
	    2 - Simplesmente Mostra os Campos                    
	    3 - Inclui registros no Bancos de Dados              
	    4 - Altera o registro corrente                       
	    5 - Remove o registro corrente do Banco de Dados     
	*/
	PRIVATE aRotina := MenuDef()

	If nOpcao == nil
		nOpcao := 1
		cCadastro := OemtoAnsi(STR0006)  // "Fatores I.A."
		uCodTab := "1"	// Consultar somente os dados CODTAB = 1 no QEJ: Fatores IA
	Else
		cCadastro := OemtoAnsi(STR0007)  // "Fatores I.Q.S."
		uCodTab := "2"	// Consultar somente os dados CODTAB = 2 no QEJ: Fatores IQS
	EndIf
	nTab := nOpcao

	If GetRPORelease() < '12.1.2710'

		oQIEA270Aux := QIEA270AuxClass():New()
		oQIEA270Aux:verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx(nOpcao)

	EndIf

	dbSelectArea("QEJ")
	// Endereca a funcao de BROWSE
	mBrowse(06,01,22,75,"QEJ",,,,,,,"q270FilFat()","q270FilFat()")
	Set Filter to

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A270DTab ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prog. Atualizacao Tabela IA(K) e IQS(FC) - Delecao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A270DTab(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A270DTab(cAlias,nReg,nOpc)
LOCAL nOpcA 
LOCAL oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0012))  //"Quanto … exclus„o?" 
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	IF nOpcA == 2

		Begin Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apos passar por todas as verificacoes , deleta o registro    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()

			If nOpcA == 2 // Confirmou
				// Recalcula os Fatores Inferiores QEJ
				A270CINF()

				// Se houver relat. Ind. Qual., apresenta mensagem p/ gera-lo novamente
				QEV->(dbSeek(xFilial("QEV")))
				If ! QEV->(Eof())
					MessageDlg(STR0013,,3)	// "Indices de Qualidade dever„o ser gerados novamente." 
				EndIf
			Endif
	
		End Transaction
	Else 
		MsUnLock()

   EndIf
	
   Exit
EndDo

dbSelectArea(cAlias)
dbSeek(xFilial("QEJ")+uCodTab)
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A270ITab ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prog. Atualizacao Tabela IA(K) e IQS(FC) - Incl./Alteracao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A270ITab(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A270ITab(cAlias,nReg,nOpc)
LOCAL nOpcA:=0
// private aEnch := { {QEJ_VLSUP}, {QEJ_FATOR} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

While .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0

	Begin Transaction

		if nOpc == 3  // Inclusao
			nOpcA:=AxInclui( cAlias, nReg, nOpc)

			If nOpcA == 1   // Confirmou a inclusao
				RecLock("QEJ",.F.)
				If nTab == 1
					QEJ->QEJ_CODTAB := '1' // Fatores IA
				Elseif nTab == 2
					QEJ->QEJ_CODTAB := '2' // Fatores IQS
				Endif
			Endif

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc)
		endif

		If nOpcA == 1 // Confirmou
			// Recalcula os Fatores Inferiores QEJ
			A270CINF()

			// Se houver relat. Ind. Qual., apresenta mensagem p/ gera-lo novamente
			QEV->(dbSeek(xFilial("QEV")))
			If ! QEV->(Eof())
				MessageDlg(STR0013,,3)	// "Indices de Qualidade dever„o ser gerados novamente." 
			EndIf
		EndIf
	
	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
dbSeek(xFilial("QEJ")+uCodTab)
return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEA271  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 19.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa funcao QIEA270 como Fator IQS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIEA271
QIEA270(2)	// Chamar o programa indicando Tabela IQS
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A270CInf ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 20.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que calcula os Fatores Inferiores da Tabela         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A270CInf()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A270CInf()
Local nInf 

nInf := 0.00
DbSelectArea("QEJ")
QEJ->(Dbseek(xFilial("QEJ") + uCodTab))
While ! Eof() .and. QEJ_CODTAB == uCodTab .and. QEJ_FILIAL == xFilial("QEJ")
	RecLock("QEJ",.F.)
	QEJ->QEJ_VLINF := nInf
	nInf := QEJ->QEJ_VLSUP + 0.01
	DbSkip()
Enddo
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A270VlFa ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 02/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Fator                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QieA270 - E' chamada no X3_VALID do cpo. QEJ_FATOR  - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A270VlFa()
Local lRet := .T.
Local cVar := M->QEJ_FATOR

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor digitado e' um numero valido    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Positivo(val(cVar))
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor digitado e' um numero valido    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If ! QA_VerNum(@cVar)
		Help(" ",1,"QA_NUMINV")
		lRet := .F.
	EndIf
	M->QEJ_FATOR := cVar   // atualizacao p/ enchoice
EndIf

If lRet
	If QEJ->(dbSeek(xFilial("QEJ") + M->QEJ_CODTAB + M->QEJ_FATOR))
		Help(" ",1,"JAGRAVADO")
		lRet:= .F.
	EndIf
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q270FILFAT³ Autor ³ Paulo Emidio de Barros³ Data ³ 02/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornao o filtro dos fatores IA(K) e IQS(FC) 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function q270FilFat()
	Local cFiltro
	
	If nTab == 1
		//Para Fatores IA
		cFiltro := xFilial('QEJ')+'1'		
	ElseIf nTab == 2
		//Para Fatores IQS
		cFiltro := xFilial('QEJ')+'2'
	Endif
Return(cFiltro)

/*/{Protheus.doc} verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx
Verifica e exibe o aviso de substituicao das rotinas QIEA270/QIEA271 pelas novas QIEA270SX/QIEA271SX.
A preferencia de supressao e persistida por usuario via FWProfile, de forma independente para cada rotina.
Deve ser chamada no inicio da rotina QIEA270 (nOpcao 1 ou 2), antes de qualquer processamento.
@author willian.ramalho
@since 25/08/2026
@version P12
@param nOpcao, numerico, 1 para QIEA270 (Fatores I.A.) ou 2 para QIEA271 (Fatores I.Q.S.)
/*/
Method verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx(nOpcao) Class QIEA270AuxClass

    Local cDataGrava := ""
    Local cProg      := If(nOpcao == 2, QIEA271_PROG, QIEA270_PROG)
    Local dDataExp   := CToD("")
    Local lExibir    := .F.
    Local oProfile   := FWProfile():New()

    // Carrega o profile do usuario atual
    oProfile:SetUser(RetCodUsr())
    oProfile:SetProgram(cProg)
    oProfile:SetTask(QIEA270_TASK)
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
        If Self:exibeAvisoSubstituicaoPorSmartx(nOpcao)
            // Grava a data de expiracao: hoje + 7 dias
            oProfile:SetStringProfile(DToS(Date() + QIEA270_DIAS))
            oProfile:Save()
        EndIf
    EndIf

    FreeObj(oProfile)
	oProfile := NIL

Return

/*/{Protheus.doc} exibeAvisoSubstituicaoPorSmartx
Monta e exibe o dialogo modal de aviso de substituicao da QIEA270/QIEA271.
Dois botoes: "OK" (fecha sem suprimir) e "Lembrar mais tarde (7 dias)" (suprime).
@author willian.ramalho
@since 25/08/2026
@version P12
@param nOpcao, numerico, 1 para QIEA270 (Fatores I.A.) ou 2 para QIEA271 (Fatores I.Q.S.)
@return lLembrar, logico, .T. se o usuario clicou em "Lembrar mais tarde"
/*/
Method exibeAvisoSubstituicaoPorSmartx(nOpcao) Class QIEA270AuxClass

    Local aButtons   := {}
    Local cMsg       := ""
    Local lLembrar   := .F.   // .T. = clicou em "Lembrar mais tarde"
    Local oContainer := NIL
	Local oFont      := NIL   // objeto de fonte para o texto da mensagem
    Local oModal     := NIL

    If nOpcao == 2
        cMsg := OemToAnsi(STR0018) // STR0018 - "A partir da versão 12.1.2710 a rotina QIEA271 deve ser substituída pela nova QIEA271SX que já está disponível para uso a partir da versão 12.1.2610."
    Else
        cMsg := OemToAnsi(STR0017) // STR0017 - "A partir da versão 12.1.2710 a rotina QIEA270 deve ser substituída pela nova QIEA270SX que já está disponível para uso a partir da versão 12.1.2610."
    EndIf

    // --- Cria a fonte: Arial, 14px, sem negrito ---
    // nAltura negativo = tamanho exato em pixels
    oFont := TFont():New('Arial', /*nLargura*/, -14, /*lBold*/ .F.)

    oModal := FWDialogModal():New()
    oModal:SetTitle(OemToAnsi(STR0014)) // STR0014 - "Atenção!"
    oModal:SetEscClose(.F.)         // Nao fecha com ESC (forcando escolha consciente)
    oModal:SetCloseButton(.F.)      // Remove o X do canto superior direito
    oModal:setSize(100, 300)        // Altura x Largura em pixels
    oModal:createDialog()

    // --- Botao "Lembrar mais tarde (7 dias)" ---
    // Fica a esquerda, e a acao menos urgente
    AAdd(aButtons, { ;
        "",                                        ; // [1] Compatibilidade (descontinuado no P12)
        OemToAnsi(STR0015),                        ; // [2] Titulo do botao STR0015 - "Lembrar mais tarde (7 dias)"
        {|| lLembrar := .T., oModal:DeActivate()}, ; // [3] Bloco de codigo
        OemToAnsi(STR0016),                        ; // [4] Tooltip STR0016 - "Suprimir este aviso pelos próximos 7 dias"
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
        {|| OemToAnsi(cMsg)}, ;
        oContainer, /*cPicture*/, oFont, , , , .T., , , 285, 20, , , , , , .T.)

    oModal:Activate()

Return lLembrar
