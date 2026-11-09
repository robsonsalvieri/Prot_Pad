#INCLUDE "QIEA280.CH"
#include "TOTVS.CH"

// Constantes do aviso
#Define QIEA280_PROG    "QIEA280"       // Chave do programa no FWProfile
#Define QIEA280_TASK    "AVSNOVA280"    // Chave da task (max 10 chars!)
#Define QIEA280_DIAS    7               // Dias para suprimir o aviso

/*/{Protheus.doc} QIEA280AuxClass
Classe agrupadora de métodos auxiliares do QIEA280
@author rafael.kleestadt
@since 19/08/2026
@version P12
/*/
CLASS QIEA280AuxClass FROM LongNameClass

    METHOD new() Constructor

	METHOD verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx()
	METHOD exibeAvisoSubstituicaoPorSmartx()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author rafael.kleestadt
@since 19/08/2026
@version P12
/*/
METHOD new() CLASS QIEA280AuxClass
Return Self

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEA280  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 27/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualiza‡Æo do Indice de Qualidade (Informado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIE                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui", 0, 1,,.F.},;  // "Pesquisar"
                   {OemToAnsi(STR0002),"AxVisual", 0, 2},;  	 // "Visualizar"
                   {OemToAnsi(STR0003),"AxInclui", 0, 3},;  	 // "Incluir"
                   {OemToAnsi(STR0004),"AxAltera", 0, 4},;       // "Alterar"
                   {OemToAnsi(STR0005),"A280Del",  0, 5, 3}}     // "Excluir"
                    
Return aRotina

Function QIEA280()

	Local oQIEA280Aux := Nil
	
	// Define o cabecalho da tela de atualizacoes
	PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Indice de Qualidade"

	/* Define Array contendo as Rotinas a executar do programa   
	 1. Nome a aparecer no cabecalho                              
	 2. Nome da Rotina associada                                  
	 3. Usado pela rotina                                         
	 4. Tipo de Transa‡„o a ser efetuada                          
	    1 - Pesquisa e Posiciona em um Banco de Dados             
	    2 - Simplesmente Mostra os Campos                         
	    3 - Inclui registros no Bancos de Dados                   
	    4 - Altera o registro corrente                            
	    5 - Remove o registro corrente do Banco de Dados */
	PRIVATE aRotina := MenuDef()

	If GetRPORelease() < '12.1.2710'

		oQIEA280Aux := QIEA280AuxClass():New()
		oQIEA280Aux:verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx()
		
	EndIf

	// Endereca a funcao de BROWSE
	mBrowse( 6, 1,22,75,"QE0")

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A280Del  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 27/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao do Indice de Qualidade - Dele‡Æo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A280Del(ExpC1,ExpN1,ExpN2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A280Del(cAlias,nReg,nOpc)

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
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009))  //"Quanto … exclus„o?" 
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	IF nOpcA == 2
		
		Begin Transaction
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.t.)
			dbDelete()
			MsUnLock()
		End Transaction
	Else
		MsUnlock()
	EndIf
	Exit
	
EndDo

dbSelectArea(cAlias)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A280Obrig³ Autor ³ Marcelo Pimentel      ³ Data ³ 28/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida‡Æo dos campos obrigat¢rios                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QieA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A280Obrig(cInd)

LOCAL lBack:=.T.

dbSelectArea("QF1")
dbSetOrder(1)
If dbSeek(xFilial("QF1")+cInd)
	If QF1_CALC != "I"
		MessageDlg(OemToAnsi(STR0010),,1)	// "Indice n„o ‚ do tipo Informado."
		Return .F.
	EndIf	
Else
	MessageDlg(OemToAnsi(STR0011),,1)	// "Indice n„o cadastrado."
	Return .F.
EndIf

If !Empty(M->QE0_ANO) .And. !Empty(M->QE0_MES) .And. !Empty(M->QE0_FORNEC);
	.And.	!Empty(M->QE0_PRODUT).And.!Empty(M->QE0_INDICE)
	
	dbSelectArea("QE0")
	dbSetOrder(1)
	If dbSeek(xFilial("QE0")+M->QE0_ANO+M->QE0_MES+M->QE0_FORNEC+M->QE0_PRODUT+;
		M->QE0_INDICE )
					
		Help( " ", 1, "JAGRAVADO" )
		lBack:= .F.
	EndIf
EndIf

Return(lBack)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A280Descr³ Autor ³ Marcelo Pimentel      ³ Data ³ 28/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra as descri‡äes ( Produto / Fornecedor )              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QieA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A280Descr(cCod,cPF,lGatilho)
Local	cBack := Space(TamSX3("QE6_DESCPO")[1])
lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)

If !Inclui .Or. lGatilho
	If !Empty(cCod)
		If cPF == "P"		//Produto
			QE6->(dbSetOrder(1))
			QE6->(dbSeek(xFilial("QE6")+cCod))
			cBack:= QE6->QE6_DESCPO
		Else					//Fornecedor
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+cCod))
			cBack:= SA2->A2_NOME
		EndIf	
	EndIf	
EndIf

Return(cBack)

/*/{Protheus.doc} verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx
Verifica e exibe o aviso de substituicao da rotina QIEA280 pela QIEA280SX.
A preferencia de supressao e persistida por usuario via FWProfile.
Deve ser chamada no inicio da rotina QIEA280, antes de qualquer processamento.
@author rafael.kleestadt
@since 19/08/2026
@version P12
/*/
Method verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx() Class QIEA280AuxClass

    Local cDataGrava := ""
    Local dDataExp   := CToD("")
    Local lExibir    := .F.
    Local oProfile   := FWProfile():New()

    // Carrega o profile do usuario atual
    oProfile:SetUser(RetCodUsr())
    oProfile:SetProgram(QIEA280_PROG)
    oProfile:SetTask(QIEA280_TASK)
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
            oProfile:SetStringProfile(DToS(Date() + QIEA280_DIAS))
            oProfile:Save()
        EndIf
    EndIf

    FreeObj(oProfile)
	oProfile := NIL

Return

/*/{Protheus.doc} exibeAvisoSubstituicaoPorSmartx
Monta e exibe o dialogo modal de aviso de substituicao da QIEA280.
Dois botoes: "OK" (fecha sem suprimir) e "Lembrar mais tarde (7 dias)" (suprime).
@author rafael.kleestadt
@since 19/08/2026
@version P12
@return lLembrar, logico, .T. se o usuario clicou em "Lembrar mais tarde"
/*/
Method exibeAvisoSubstituicaoPorSmartx() Class QIEA280AuxClass

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
        {|| OemToAnsi(STR0015)}, ; // "A partir da release 12.1.2710, esta rotina deverá ser substituída pela nova versão QIEA280SX."
        oContainer, /*cPicture*/, oFont, , , , .T., , , 285, 20, , , , , , .T.)

    oModal:Activate()

Return lLembrar
