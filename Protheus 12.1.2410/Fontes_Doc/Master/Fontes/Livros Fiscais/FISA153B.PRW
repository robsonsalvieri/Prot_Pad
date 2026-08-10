#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA153B
Realiza a apuração do Simples Nacional via Job/Schedule

@param cCodEmp    - Código do grupo de empresa (cEmpAnt)
@param cCodFil    - Código da filial (cFilAnt)
@param cMesRef    - Mês e ano do período a ser processado. Exemplo: "012023" onde 01 é o mês de janeiro e 2023 o ano.
@param nAprvAliq  - Indica se as alíquotas deverão ser aprovadas de forma automática: 1=Sim e 2=Não.
@param nRegime    - Regime de apuração das receitas: 1=Competência e 2=Regime de Caixa.
@param nMovFinCtb - Indica se serão geradas movimentações financeiras e contábeis: 1=Não, 2=Somente Título, 3=Título+Contábil.
@param nAgrpFil   - 1=Indica que as filiais serão agrupadas, centralizando a apuração na filial logada. 2=A apuração será realizada apenas para a filial logada
@param cFilDe     - Caso o agrupamento de filiais esteja habilitado, indica a primeira filial do range
@param cFilAte    - Caso o agrupamento de filiais esteja habilitado, indica a ultima filial do range
@param lTestAuto  - Indica se a rotina foi chamada por um script de automação.


@author leandro.faggyas
@since 01/03/2023
@version 12.1.2210

/*/
//-------------------------------------------------------------------
Function FISA153B(cCodEmp,cCodFil, cMesRef, nAprvAliq, nRegime, nMovFinCtb, nAgrpFil, cFilDe, cFilAte,  lTestAuto )
	Local lAliqAuto    := .F.
	Local lSchedule    := ValType(cCodEmp) == "U" // Se é execuçao via Schedule
	Local dDataAnt     := Ctod("") //Guarda a data do período anterior à data base.
	Local oSX1         := FWSX1Util():New()
	Local oGrupoSX1    := Nil
	Local aFilSel      := {} //Caso seja passado um range de filiais, esse array irá guardar todas as filiais passadas.

	Default cCodEmp    := ""
	Default cCodFil    := ""
	Default cMesRef    := ""
	Default nAprvAliq  := 1
	Default nRegime    := 1
	Default nMovFinCtb := 1
	Default nAgrpFil   := 2
	Default cFilDe     := ""
	Default cFilAte    := ""
	Default lTestAuto  := .F.  //Esse parâmetro será passado como verdadeiro pelas nossas suites de teste

	Private lAutomato   := .T. //Indica que a execução será via Job
	Private lPosPerRed 	:= .F.
	Private lPosPredRed := .F.

	//Mensagem simples, de forma reduzida, somente parâmetros obrigatórios
	FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Inicio do servico de apuracao automatico do Simples Nacional." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	lSchedule := Empty(cCodEmp) .And. !Empty(cEmpAnt) .And. !Empty(cFilAnt)

	If lSchedule

		oSX1:AddGroup("FSA153JOB")
		oSX1:SearchGroup()
		oGrupoSX1 := oSX1:GetGroup("FSA153JOB")

		IF Len(oGrupoSX1[2]) > 0 //Caso o método GetGroup retorne um array vazio, significa que o sistema não encontrou o pergunte FSA153JOB.
			nAprvAliq     := MV_PAR01
			nRegime       := MV_PAR02
			nMovFinCtb    := MV_PAR03
			cMesRef       := MV_PAR04
			nAgrpFil      := MV_PAR05
			cFilDe        := MV_PAR06
			cFilAte       := MV_PAR07
		EndIf

	ElseIf !lTestAuto

		RpcSetType( 3 )
		RpcSetEnv(cCodEmp,cCodFil,,,'FIS')
		FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Ambiente acessado.", /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	EndIf

	If Empty(cMesRef)
		dDataAnt     := FirstDay(dDataBase)-1
		cMesRef      := StrZero(Month(dDataAnt), 2) + cValtochar(Year(dDataAnt))
	EndIf

	lAliqAuto := nAprvAliq == 1
	
	IF Pergunte("FSA153")
		//Atualizo os parâmetros do pergunte FSA153 conforme o esperado pela rotina de apuração.
		MV_PAR01 := cMesRef
		If nAgrpFil==1 .And. !Empty(cFilAte)
			MV_PAR02 := 1 //Seleciona Filiais = 1-Sim
			aFilSel := F153FRange(cFilDe,cFilAte)
		Else
			MV_PAR02 := 2 //Seleciona Filiais = 2-Não
		EndIf
		MV_PAR03 := nRegime
		MV_PAR04 := nMovFinCtb

		If FISA153() //A função FISA153 é chamada para posicionar todas as tabelas necessárias, fazer algumas verificações e realizar Carga Inicial

			FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Iniciando apuracao referente ao periodo " + SubStr(cMesRef,1,2) + "/" + SubStr(cMesRef,3) + "." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/) 
			FS153Apura( aFilSel )
			FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Apuracao concluida!" , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

			If lAliqAuto 
				AprvAlqAut( aFilSel, cMesRef )
			EndIf

			FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Processamento finalizado." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

		EndIf

	EndIf

	If !lSchedule .And. !lTestAuto
		RESET ENVIRONMENT
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AprvAlqAut
Efetua a aprovação das aliquotas de forma automática quando chamado via JOB ou Schedule.
Verifica todas as filiais que foram consideradas na apuração e faz a aprovação de todas as filiais envolvidas, levando em consideração o nível de compartilhamento das tabelas.
Caso as aliquotas por algum motivo já estejam aprovadas, essa rotina não fará desaprovações.

@author  leandro.faggyas
@since   01.03.2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function AprvAlqAut( aFilSel, cMesRef )
	Local nX       := 0
	Local cFilBkp  := cFilAnt
	Local cFilPos  := ""
	Local aAreaF1E := F1E->(GetArea())
	Local cMesApu  := SubStr(cMesRef,1,2)
	Local cAnoApu  := SubStr(cMesRef,3)

	DbSelectArea("F1E")
	F1E->(DbSetOrder(1)) //F1E_FILIAL+F1E_ANO+F1E_MES+F1E_APROV+F1E_ID

	FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Iniciando da aprovacao automatica de aliquotas." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	For nX := 1 To Len(aFilSel)

		cFilPos := PADR(aFilSel[nX,2], LEN(cFilAnt))

		If F1E->(MsSeek(xFilial( "F1E", cFilPos ) + cAnoApu + cMesApu + "2")) //Faço o Seek por Filial, levando em consideração somente as aliquotas que não estão aprovadas.
			cFilAnt := cFilPos
			FSA155ALQOK( .T. )
		EndIf

	Next nX

	cFilAnt := cFilBkp

	FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Finalizando a aprovacao automatica de aliquotas." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	RestArea( aAreaF1E )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.

@return aParam - Array com os parametros

@author  leandro.faggyas
@since   01.03.2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function Scheddef()

Local aParam  := {}

aParam := { "P",;           //Tipo R para relatorio P para processo
            "FSA153JOB",;   //Pergunte do relatorio, caso nao use passar ParamDef
            ,;              //Alias
            ,;              //Array de ordens
            }               //Titulo

Return aParam
