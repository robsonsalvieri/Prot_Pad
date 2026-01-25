#INCLUDE "TOTVS.CH" 
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "PONM430.CH"

Static lPort1510 	:= Port1510() 	//Verifica se Portaria 1510/2009 esta em vigor.
Static cFilIni		:= ""
Static cFilAte		:= Replicate("Z",FWGETTAMFILIAL)
Static cMatDe		:= ""
Static cMatAte		:= ""
Static cFuncDe		:= ""
Static cFuncAte		:= ""
Static cSindDe		:= ""
Static cSindAte		:= ""
Static cTurnoDe		:= ""
Static cTurnoAte	:= ""
Static cCcDe		:= ""
Static cCcAte		:= ""
Static cMotAfaDe	:= ""
Static cMotAfaAte	:= ""
Static dDataDe		:= Ctod(" / / ")
Static dDataAte		:= Ctod(" / / ")
Static lReproces	:= .F.

/*/{Protheus.doc} PONM430
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function PONM430()
Local lSchedule 	:= IsBlind()

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Se Portaria estiver ativada, verifica se base esta OK		   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If lPort1510
	If !fVerBasePort()
		Break
	EndIf
EndIf

If !lSchedule
	If !SuperGetMv("MV_TSREP", NIL, .F.)
		Alert(STR0002 + Chr(13) + STR0003) //"Rotina disponivel somente para integração TSREP" + Chr(13) + "Para utilizá-la, configure os parametros 'MV_TSREP' e 'MV_TSASERV'")
		Return
	EndIf
	If GetMv("MV_TSASERV") == ''
		Alert(STR0002 + Chr(13) + STR0003) //"**** Endereco do WebService nao informado!" + Chr(13) + "Para utilizá-la, configure o parametro 'MV_TSASERV'")
		Return
	EndIf

	Pergunte("PONM430", .F.)
	
	TNewProcess():New("PONM430", STR0001, {|oSelf| PONM430Process(oSelf,lSchedule)}, STR0004, "PONM430", NIL, NIL, NIL, NIL, .T., .F.)	//"Integração Ponto x TSREP" / "Esta rotina realiza a verificação de registros pendentes de integração!"
Else
	PONM430Process(,lSchedule)
EndIf


Return


/*/{Protheus.doc} PONM430Process
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function PONM430Process(oProcess,lSchedule)   
	Local nOldSet 	:= SetVarNameLen(255)
	Local aArea		:= GetArea()
	Local aItems	:= {}
	Local nCount	:= 0
	Local oObjMail 	:= PTSREPOBJ():New()	
	Local cInicio	:= Time()
	Local nAtuMSA	:= 2
	
	Private aRetLog  := {}

	Default lSchedule := .F.
	
	nAtuMSA := If(Empty(mv_par04),2,mv_par04)
	
	cFilDe	:= mv_par02
	cFilAte	:= mv_par03

	If !Empty(mv_par19)
		cMatDe		:= mv_par05
		cMatAte		:= mv_par06
		cFuncDe		:= mv_par07
		cFuncAte	:= mv_par08
		cSindDe		:= mv_par09
		cSindAte	:= mv_par10
		cTurnoDe	:= mv_par11
		cTurnoAte	:= mv_par12
		cCcDe		:= mv_par13
		cCcAte		:= mv_par14
		cMotAfaDe	:= mv_par15
		cMotAfaAte	:= mv_par16
		dDataDe		:= mv_par17
		dDataAte	:= mv_par18
		lReproces	:= If (mv_par19 == 1, .T., .F.)

		If lReproces 
			If (Empty(cFuncAte), cFuncAte := Replicate("Z",TamSX3("RJ_FUNCAO")[1]), Nil)
			If (Empty(cSindAte), cSindAte := Replicate("Z",TamSX3("RCE_CODIGO")[1]), Nil)
			If (Empty(cTurnoAte), cTurnoAte := Replicate("Z",TamSX3("R6_TURNO")[1]), Nil)
			If (Empty(cCcAte), cCcAte := Replicate("Z",TamSX3("CTT_CUSTO")[1]), Nil)
			If (Empty(cMotAfaAte), cMotAfaAte := Replicate("Z",TamSX3("RCM_TIPO")[1]), Nil)
			If (Empty(cMatAte), cMatAte := Replicate("Z",TamSX3("RA_MAT")[1]), Nil)
		EndIf
	EndIf
	
	//Perguntas incluidas para possibilitar o processamento por filial
	If nAtuMSA == 2 .And. (cFilDe > cFilAte .Or. Empty(cFilAte)) .And. !lSchedule
		If lSchedule
			Conout(AnsiToOEM(STR0029)) //"Filial Até deve ser maior que Filial De"
		Else
			Alert(STR0029) //"Filial Até deve ser maior que Filial De"
		EndIf
		Return
	ElseIf nAtuMSA == 1
		If !fTemTabMSA()
			fCriaTab()
		Else
			fVldMSA671()
		EndIf
	EndIf

	If lSchedule
		If "04" $ mv_par01
			Conout(AnsiToOEM(STR0030)) //"Atenção"
			Conout(AnsiToOEM(STR0032)) //"Quando a Carga Inicial é executada pelo Schedule, apenas os turnos e horários serão integrados."
			ProcP03(,lSchedule)
		Else
			Conout(AnsiToOEM(STR0033)) //"Apenas o Turnos e Horarios sao integrados com o Suricato via Schedule. Por favor selecione a opçao 4 (Turnos e horarios) na pergunta Itens a Enviar."
		EndIf
	ElseIf nAtuMSA == 2	
		If ("01" $ mv_par01)
			AAdd(aItems, {STR0005, { || ProcP01(oProcess) } })			//"Empresa, Unidade e Lotacao" 
		EndIf
		If ("02" $ mv_par01)
			AAdd(aItems, {STR0011, { || ProcP07(oProcess) } })			//"Cargos e Funcoes"
		EndIf
		If ("03" $ mv_par01)
			AAdd(aItems, {STR0006, { || ProcP02(oProcess) } })			//"Sindicatos"
		EndIf
		If ("04" $ mv_par01)
			AAdd(aItems, {STR0007, { || ProcP03(oProcess) } })			//"Turnos de Trabalho e Escala"
		EndIf
		If ("05" $ mv_par01)
			AAdd(aItems, {STR0009, { || ProcP05(oProcess) } })		    //"Controle de Ausencias"
		EndIf
		If ("06" $ mv_par01)
			AAdd(aItems, {STR0012, { || ProcP08(oProcess) } })	  		//"Centros de Custo"
		EndIf
		If ("07" $ mv_par01)
			AAdd(aItems, {STR0013, { || ProcP09(oProcess) } })			//"Situacao de Afastamento"
		EndIf
		If ("08" $ mv_par01)
			AAdd(aItems, {STR0008, { || ProcP04(oProcess) } })			//"Funcionarios"
		EndIf
		If ("09" $ mv_par01)
			AAdd(aItems, {STR0014, { || ProcP10(oProcess) } }) 			//"Cadastro de Afastamento"
		EndIf
		If ("10" $ mv_par01)
			AAdd(aItems, {STR0010, { || ProcP06(oProcess) } })			//"Excecoes"
		EndIf
		If ("11" $ mv_par01)
			AAdd(aItems, {STR0015, { || ProcP11(oProcess) } })			//"Ferias Afastamentos"
		EndIf	
		
		oProcess:SetRegua1(Len(aItems))
		oProcess:SaveLog(STR0019)	//"Inicio de processamento"

		ConOUt(STR0024 + Time()) // Inicio da Carga
		For nCount:= 1 to Len(aItems)
			If (oProcess:lEnd)
				Break
			EndIf
					
			oProcess:IncRegua1(aItems[nCount, 1])
			oProcess:SetRegua2(0)
			oProcess:IncRegua2("")
			
			ConOUt(STR0025 + aItems[nCount , 1] + STR0027 + Time()) // Inicio do Processo : #  Hora : 
			Eval(aItems[nCount, 2])
			ConOut('')
			ConOUt(STR0026 + aItems[nCount , 1] + STR0027 + Time())
			ConOut('')
		Next
		
		ConOut(STR0028 + Time()) // " Fim da Carga : "

		oProcess:IncRegua1("")
		
		SetVarNameLen(nOldSet)			

		If !oProcess:lEnd
			Aviso(STR0001, STR0020, {"Ok"})		//"Integracao TSREP", "Fim do processamento!"
			oProcess:SaveLog(STR0020)			//"Fim do processamento"
			oObjMail:WSSendMail("Carga Inicial" , "Processamento Iniciado as " + cInicio +" e terminado as " + Time()+CRLF+CRLF+CRLF+CRLF)
		Else
			Aviso(STR0001, STR0021, {"Ok"})		//"Integracao TSREP", "Processamento cancelado pelo usuario!"
			oProcess:SaveLog(STR0021)			//"Processamento cancelado pelo usuario!"
		EndIf
	EndIf
	RestArea(aArea)
Return .T.                                     


/*/{Protheus.doc} ProcP01
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP01(oProcess)
	// Avaliacao "Empresa, Unidade e Lotacao"
	// PONXFUN1 - WSRHLegal() - SRA

	/* Servicos:
		WSLegal(1)		- PJ
		WSUnit(1)		- Unidades
		WSAllocation(1)	- Lotacao
		WSLocation(1)	- Lotacao
    */

	aRetLog := {}
	WSRHLegal(oProcess,cFilDe,cFilAte)
	ProcMail(aRetLog,STR0005,oProcess)
Return


/*/{Protheus.doc} ProcP02
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP02(oProcess)
	// Avaliacao "Sindicatos"
	// PONXFUN1 - WSRHSindicatoLegal() - RCE

	/* Servicos:
		WSSindicatoLegal(1) - Sindicato
    */

	aRetLog := {}
	WSRHSindicatoLegal(oProcess, cFilDe, cFilAte, cSindDe, cSindAte, lReproces)
	ProcMail(aRetLog,STR0006,oProcess)
Return


/*/{Protheus.doc} ProcP03
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP03(oProcess,lSchedule)
Default lSchedule := .F.
	// Avaliacao "Turnos de Trabalho e Escala"
	// PONXFUN1 - WSRHShiftWork() - SR6

	/* Servicos:
		WSShiftWork(1)	- Turno de Trabalho
		WSScala(1)		- Escalas
    */
    
	aRetLog := {}
	WSRHShiftWork(oProcess, cFilDe, cFilAte, lSchedule, cTurnoDe, cTurnoAte, lReproces)
	If !lSchedule
		ProcMail(aRetLog,STR0007,oProcess)
	EndIf
Return


/*/{Protheus.doc} ProcP04
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP04(oProcess)
	// Avaliacao "Funcionarios"
	// PONXFUN1 - WSRHUser() - SRA

	/* Servicos:
		WSNatural(1)- Pessoa Fisica
		WSUser(1)	- Usuarios
    */
    
	aRetLog := {}
	WSRHUser(oProcess, cFilDe, cFilAte, cMatDe, cMatAte, lReproces) //Inclusao-alteracao
	WSRHDUser(oProcess, cFilDe, cFilAte, cMatDe, cMatAte, lReproces)
	WSRHTUser(,,, .T., cFilDe, cFilAte, cMatDe, cMatAte, lReproces)
	ProcMail(aRetLog,STR0008,oProcess)
Return


/*/{Protheus.doc} ProcP05
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP05(oProcess)
	// Avaliacao "Controle de Ausencias"
	// PONXFUN1 - WSRHDayNotWorked() - SP3

	/* Servicos:
		WSDayNotWorked(1) - Dias nao trabalhados
    */
    
	aRetLog := {}
	WSRHDayNotWorked(oProcess, cFilDe, cFilAte, dDataDe, dDataAte, lReproces)
	ProcMail(aRetLog,STR0009,oProcess)
Return


/*/{Protheus.doc} ProcP06
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP06(oProcess)
	// Avaliacao "Excecoes"
	// PONXFUN1 - WSRHEDayNotWorked() - SP2

	/* Servicos:
		WSDayNotWorked(4) - Excecoes
    */
    
	aRetLog := {}
	WSRHEDayNotWorked(oProcess, cFilDe, cFilAte, cMatDe, cMatAte, dDataDe, dDataAte, lReproces)
	ProcMail(aRetLog,STR0010,oProcess)
Return


/*/{Protheus.doc} ProcP07
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP07(oProcess)
	// Avaliacao "Cargos e Funcoes"
	// PONXFUN1 - WSRHPositionLevel() - SRJ

	/* Servicos:
		WSPositionLevel(1) - Cargos e Funcoes
    */

	aRetLog := {}
	WSRHPositionLevel(oProcess, cFilDe, cFilAte, cFuncDe, cFuncAte, lReproces)
	ProcMail(aRetLog,STR0011,oProcess)
Return


/*/{Protheus.doc} ProcP08
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP08(oProcess)
	// Avaliacao "Centro de Custo"
	// PONXFUN1 - WSRHCostCenter() - CTT

	/* Servicos:
		WSCostCenter(1) - Centro de Custo
    */
    
	aRetLog := {}
	WSRHCostCenter(oProcess, cFilDe, cFilAte, cCcDe, cCcAte, lReproces)
	ProcMail(aRetLog,STR0012,oProcess)
Return


/*/{Protheus.doc} ProcP09
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP09(oProcess)
	// Avaliacao "Situacao de Afastamento"
	// PONXFUN1 - WSRHAbsenceReason() - SX5

	/* Servicos:
		WSAbsenceReason(1) - Situacao de Afastamento
    */
      
	aRetLog := {}
	WSRHAbsenceReason(oProcess, cFilDe, cFilAte, cMotAfaDe, cMotAfaAte, lReproces)
	ProcMail(aRetLog,STR0013,oProcess)
Return


/*/{Protheus.doc} ProcP10
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP10(oProcess)
	// Avaliacao "Cadastro de Afastamento"
	// PONXFUN1 - WSRHAbsenceReason() - SR8

	/* Servicos:
		WSAbsenceReason(5) - Cadastro de Afastamento
    */
      
	aRetLog := {}
	WSRHUserAbsence(oProcess, cFilDe, cFilAte, cMatDe, cMatAte, dDataDe, dDataAte, lReproces)
	ProcMail(aRetLog,STR0014,oProcess)
Return


/*/{Protheus.doc} ProcP11
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function ProcP11(oProcess)
	// Avaliacao "Ferias Afastamento"
	// PONXFUN1 - WSRHAbsenceReason() - SRH

	/* Servicos:
		WSAbsenceReason(7) - Ferias Afastamento
    */
      
	aRetLog := {}
	WSRHUserVacationAbsence(oProcess, cFilDe, cFilAte, cMatDe, cMatAte, dDataDe, dDataAte, lReproces)
	ProcMail(aRetLog,STR0015,oProcess)
Return


/*/{Protheus.doc} TSREPJobOpcoes
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function TSREPJobOpcoes()
	Local MvPar
	Local MvParDef := ""	
	Local aItems := {}	
	Local aArea := GetArea()
	
	MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	MvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	
	AAdd(aItems, "01 - " + STR0005)		//"Empresa, Unidade e Lotacao"
	AAdd(aItems, "02 - " + STR0011)		//"Cargos e Funcoes"
	AAdd(aItems, "03 - " + STR0006)		//"Sindicatos"
	AAdd(aItems, "04 - " + STR0007)		//"Turnos de Trabalho e Escala"
	AAdd(aItems, "05 - " + STR0009)		//"Controle de Ausencias"
	AAdd(aItems, "06 - " + STR0012)		//"Centros de Custo"
	AAdd(aItems, "07 - " + STR0013)		//"Situacao de Afastamento"
	AAdd(aItems, "08 - " + STR0008)		//"Funcionarios"
	AAdd(aItems, "09 - " + STR0014)		//"Cadastro de Afastamento"
	AAdd(aItems, "10 - " + STR0010)		//"Excecoes"
	AAdd(aItems, "11 - " + STR0015)		//"Ferias Afastamentos"

	MvParDef := "0102030405060708091011"

	IF f_Opcoes(@MvPar, STR0017, aItems, MvParDef, 11, 47, .F., 2)  // "Opcoes"
		&MvRet := MvPar                                             // Devolve Resultado
	EndIF	
	
	RestArea(aArea) 						   					 	// Retorna Alias
Return MvParDef


/*/{Protheus.doc} Menudef
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
	Local aRotina := {}
	aAdd(aRotina, {STR0016,	"PONM430",	0, 3, 0, NIL}) //"Processar"
Return aRotina

/*/{Protheus.doc} ProcMail
@author Marcelo Faria
@since 15/07/2011
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function ProcMail(aRet, cServico, oProcess)
	Local cHead	   := ""
	Local cBody    := ""
	Local nCount   := 0
	Local oObjMail := PTSREPOBJ():New()	
	
	cBody := STR0022 +CRLF 		  		  //"As mensagens abaixo foram identificadas no processo de carga "
	cBody += STR0023 +cServico +CRLF+CRLF //"e atualização para o web-service:"
	cHead	:= cBody
	For nCount:= 1 to Len(aRet)
		oProcess:SaveLog(aRet[nCount])
		cBody += aRet[nCount] +CRLF				
		IF Len(cBody) >  30000 //Verifica se a variavel caracter eh maior +- que 30K para evitar StringOverflow 
			oObjMail:WSSendMail(cServico , cBody)
			cBody:= cHead 
		Endif		
	Next
	cBody += Chr(13)+Chr(10)
	If Len(aRet) > 0
	   oObjMail:WSSendMail(cServico , cBody)
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Scheddef    ³ Autor ³ Marco Nakazawa     ³ Data ³08/03/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trazer o grupo de perguntas PONM430 quando houver schedule ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SchedDef()
Local aOrd		:= {}
Local aParam	:= {}

aParam := {	"P"			, ; // Tipo R para relatorio P para processo
			"PONM430"	, ;	// Pergunte do relatorio, caso nao use passar ParamDef
			""			, ; // Alias para o relatório
			aOrd		, ; // Array de ordens para o relatório
			""			}
Return aParam
