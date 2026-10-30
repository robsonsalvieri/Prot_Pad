#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA200NIV.CH"

/*/{Protheus.doc} PCPA200NIV
Fonte para executar a procedure referentes ao recálculo dos níveis da estrutura
@author vivian.beatriz
@since 28/04/2023
@version P12
@param cErro  , caracter, mensagem de erro (passado por referência)
@param lAllFil, Lógico  , indica se deve calcular o nível em todas as filiais.
@return lOk, lógico, indica se tudo foi executado com sucesso
/*/
Function PCPA200NIV(lCalcNivel,l200Auto,lPreEstru,cErro)
Local oDlg

Local nOpca := 0

Local cLinha1:=""
Local cLinha2:=""
Local cLinha3:=""
Local cLinha4:=OemToAnsi(STR0011)
Local cLinha5:=OemToAnsi(STR0012)
Local cLinha6:=""
Local cTitulo:=""

Default cArqTrb       :=""
Default lPreEstru     :=.F.
Default lCompartilhado:=.F.
Default cFil330		  := cFilAnt

PRIVATE lNivelOk := .F.

cTitulo:=IF(lPreEstru,OemToAnsi(STR0016),OemToAnsi(STR0007))
cLinha1:=IF(lPreEstru,OemToAnsi(STR0017),OemToAnsi(STR0008))
cLinha2:=IF(lPreEstru,OemToAnsi(STR0018),OemToAnsi(STR0009))
cLinha3:=IF(lPreEstru,OemToAnsi(STR0019),OemToAnsi(STR0010))
cLinha6:=IF(lPreEstru,OemToAnsi(STR0020),OemToAnsi(STR0013))

l200Auto  := IIF(Valtype(l200Auto) == "L",l200Auto,.T.)
lCalcNivel:= IIF(Valtype(lCalcNivel) == "L",lCalcNivel,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha a tela do programa                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l200Auto
	DEFINE MSDIALOG oDlg FROM  90,78 TO 385,490 TITLE cTitulo PIXEL    //"Rec lculo dos N¡veis dos Produtos na Estrutura"
	@ 8, 18 TO 108, 180 LABEL "" OF oDlg  PIXEL
	@ 20, 27 SAY cLinha1 SIZE 151, 7 OF oDlg PIXEL     //"Foram feitas altera‡”es no cadastro de estruturas. Esta rotina"
	@ 33, 27 SAY cLinha2 SIZE 151, 7 OF oDlg PIXEL     //"recalcula o n¡vel dos produtos e seus componentes em  suas "
	@ 47, 27 SAY cLinha3 SIZE 151, 7 OF oDlg PIXEL     //"respectivas estruturas."
	@ 61, 27 SAY cLinha4 SIZE 151, 7 OF oDlg PIXEL     //"O rec lculo se faz necess rio para que cada produto receba "
	@ 75, 27 SAY cLinha5 SIZE 151, 7 OF oDlg PIXEL     //"um  tratamento  nas rotinas a serem executadas  de  acordo "
	@ 89, 27 SAY cLinha6 SIZE 151, 7 OF oDlg PIXEL     //"com sua hierarquia dentro da estrutura."
	DEFINE SBUTTON FROM 119, 125 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
	DEFINE SBUTTON FROM 119, 152 TYPE 2 ACTION  oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
Else 
	nOpca := IF(lCalcNivel,1,0)
EndIf

If nOpca == 1
	If IsBlind()
		lNivelOk := CalcNivel(@cErro)
	Else
		MsgMeter( {|oMeter, oText, oDlg, lEnd| lNivelOk := CalcNivel(@cErro) },If(lPreEstru,STR0021,STR0015),OemToAnsi(STR0014))  //"Rec lculo de N¡veis" //"Recalculando Estrutura..."
	EndIf
EndIf
Return(lNivelOk)

/*/{Protheus.doc} CalcNivel
Calcula o nível de cada Produto (SB1) de acordo com a Estrutura (SG1)
@author vivian.beatriz
@since 28/04/2023
@version P12
@param cErro  , caracter, mensagem de erro (passado por referência)
@param lAllFil, Lógico  , indica se deve calcular o nível em todas as filiais.
@return lOk, lógico, indica se foi executada com sucesso
/*/
Static Function CalcNivel(cErro)

	Local aResult   := {}
	Local cProcNam  := GetSPName("PCP001","28")
	Local lOk       := .T.
	Local lAbreTran := .F.
	Local nInicio   := MicroSeconds()

	LogNiv(STR0004) //"Inicio do recalculo dos niveis."

	//Proteção para DbAccess desatualizado, referente a abertura indevida de transação
	//para banco de dados oracle na execução da Procedure. Correção estará disponível a partir da build 22.1.1.1 do DbAccess
	If TCGetDB() == "ORACLE" .And. TCVersion() < "22.1.1.1"
		lAbreTran := .T.
		LogNiv("[ABRE_TRANCACAO]=TRUE")
	EndIf

	//Verifica se a procedure existe
	If ExistProc(cProcNam, VerIDProc())
		cProcNam := xProcedures(cProcNam)
		//Executa a procedure no banco recuperando o retorno
		aResult := Executa(lAbreTran, cProcNam, xFilial("SG1"))
		//Se ocorreu algum erro, retorna o status de execuçã o como falso
		If Empty(aResult) .Or. Valtype(aResult) <> "A"
		   cErro := STR0001 + AllTrim(cProcNam) + ": " + TcSqlError() //"Erro na execução da Stored Procedure "
		   lOk   := .F.
		EndIf
	EndIf

	LogNiv(STR0005 + cValToChar(MicroSeconds()-nInicio)) //"Termino do recalculo de niveis. Tempo total: "

	If !lOk
		LogNiv(STR0006 + cErro) // "Recalculo de niveis processado com erro. "
	EndIf

Return lOk

/*/{Protheus.doc} Executa
Faz a execução da Stored Procedure de recálculo de níveis do MRP.

@type  Static Function
@author vivian.beatriz
@since 28/04/2023
@version P12
@param lAbreTran, Logic, Indica se deve abrir transação para executar a procedure
@return aResult, Array, Array com o retorno da stored procedure
/*/
Static Function Executa(lAbreTran, cProcName, cFilSG1)
	Local aResult := {}

	//Executa a procedure no banco recuperando o retorno
	//Caso seja banco de dados Oracle e não esteja com DbAccess atualizado, irá executar a 
	//procedure dentro de transação para efetuar o commit dos dados de forma correta.
	If lAbreTran
		BEGIN TRANSACTION
			aResult := TCSPEXEC(cProcName, cFilSG1)
		END TRANSACTION
	Else
		aResult := TCSPEXEC(cProcName, cFilSG1)
	EndIf
Return aResult

/*/{Protheus.doc} LogNiv
Função para exibição de mensagens de log

@type  Static Function
@author vivian.beatriz
@since 28/04/2023
@version P12
@param cMessage, Character, Mensagem de log
@return Nil
/*/
Static Function LogNiv(cMessage)
	Local dDate := Date()
	Local cTime := Time()

	cMessage := "PCPA200NIV - " + DtoC(dDate) + " - " + cTime + ": " + cMessage

	LogMsg('PCPA200NIV', 0, 0, 1, '', '', cMessage)
Return Nil

/*/{Protheus.doc} VerIDProc
Identifica a sequência de controle do fonte ADVPL com a stored procedure.
Qualquer alteração que envolva diretamente a procedure a variavel será incrementada.
@author vivian.beatriz
@since 28/04/2023
@version P12
@return versão da procedure (compatibilidade)
/*/
Static Function VerIDProc()
Return '001' 

/* ---------------------------------------------------------------------------------
Funções executadas durante a exibição de informações detalhadas do processo na 
interface de gestão de procedures.
Faz a execução de funções STATIC proprietárias das rotinas donas dos processos.IMPORTANTE: 
- Essas funções não podem ter interface alguma, nem interação com usuário.
--------------------------------------------------------------------------------- */
// Processo 28 - RECALCULO DO NIVEL DA ESTRUTURA
Function EngSPS28Signature()
Return VerIDPROc()

// GERAR PACOTE
