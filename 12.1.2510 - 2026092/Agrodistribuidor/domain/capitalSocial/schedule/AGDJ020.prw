#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AGDJ020.CH"

#DEFINE AGD_JOB "AGDJ020"
#DEFINE NAMESPACEAGD totvs.protheus.agrobusiness.agd

/*/{Protheus.doc} AGDJ020
Rotina responsável por realizar os calculos pendentes de Juros (Capital Social) 
Somente via Job/Schedule.
@type Function
@version 12
@author jc.maldonado
@since 03/08/2026
/*/
Function AGDJ020()
	If ! isBlind()
		FWAlertError(STR0001) //"Rotina de uso restrito para Job/Schedule."
		Return
	EndIf

	If ! LockByName(AGD_JOB, .T. , .T.)
		FWLogMsg("WARN", Nil, AGD_JOB, procName(), Nil, Nil, i18n(STR0002, {cEmpAnt, cFilant})) //"A rotina ja esta sendo executada em outra thread. Grupo: #1[CODIGO_GRUPO]#  Filial: #2[CODIGO_FILIAL]#"
		Return
	EndIf

	FWLogMsg("INFO", Nil, AGD_JOB, procName(), Nil, Nil, STR0003) //"Iniciando Job..."

	processPend()

	FWLogMsg("INFO", Nil, AGD_JOB, procName(), Nil, Nil, STR0004) //"Fim do Job."

	UnlockByName(AGD_JOB, .T., .T.)
Return

/*/{Protheus.doc} SchedDef
As definições de agendamento são determinadas por rotina, sendo configuradas pela função SCHEDDEF().
Ao agendar uma rotina no Schedule, o sistema verIfica a existência da função e aplica as configurações 
retornadas, permitindo controlar dinamicamente opções de execução.
@type Function
@version 12
@author jc.maldonado
@since 03/08/2026
@Return array, lista de configurações esperadas pelo SchedDef.
/*/
Static Function SchedDef()
	Local aParam := {}

	aParam := {;
		"P"   ,; // R=relatorio; P=processo
	"PARAMDEF",; // Pergunte do relatorio, caso nao use, informar "PARAMDEF"
	Nil       ,; // cAliasNF7 (Quando R=Relatório)
	Nil       ,; // aArray (Quando R=Relatório)
	Nil       ,; // Titulo (Quando R=Relatório)
	Nil       ,; // Nome  (Quando R=Relatório)
	.F.       ,; // Permite agendamento sempre ativo?
	.T.        ; // Permite agendamento por filiais?
	}
Return aParam

/*/{Protheus.doc} processPend
Seleciona os calculos de Juros (Capital Social) com status passívels de calculo ou confirmação.
@type Function
@version 12
@author jc.maldonado
@since 03/08/2026
/*/
Static Function processPend()
	Local cQuery     := ""
	Local aBindParam := {}
	Local cFilialNF7 := FWxFilial("NF7")
	Local cAliasNF7  := ""
	Local nRecnoNF7  := 0

	cQuery := " SELECT NF7_CODIGO AS CODIGO, NF7_STATUS as STATUS"
	cQuery += " FROM " + retSQLname("NF7")
	cQuery += " WHERE"
	cQuery += "    NF7_FILIAL = ?" ; aAdd(aBindParam, cFilialNF7)
	cQuery += "    AND (NF7_STATUS = '1' OR NF7_STATUS = '8')" //1=PENDENTE, 8=APROVADO
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY NF7_DTGERA, NF7_HRGERA"
	cQuery := changeQuery(cQuery)

	cAliasNF7 := MpSysOpenQuery(cQuery, Nil, Nil, Nil, aBindParam)

	If (cAliasNF7)->(EOF())
		(cAliasNF7)->(DBCloseArea())
		FWLogMsg("INFO", Nil, AGD_JOB, procName(), Nil, Nil, STR0005) //"Nenhum calculo de juros disponi­vel para processar."
		Return
	EndIf

	dbSelectArea("NF7")
	NF7->(DBSetOrder(1))
	While (cAliasNF7)->(! EOF())
		If NF7->(DBSeek(cFilialNF7 + (cAliasNF7)->CODIGO))
			If ! NF7->(SimpleLock())
				FWLogMsg("ERROR", Nil, AGD_JOB, procName(), Nil, Nil, i18n(STR0006, {(cAliasNF7)->CODIGO})) //"Nao foi possi­vel reservar o registro na tabela NF7. NF7_CODIGO=#1[CODIGO]#"
				(cAliasNF7)->(DBSkip())
				Loop
			EndIf

			nRecnoNF7 := NF7->(Recno())

			if (cAliasNF7)->STATUS == "1" //Pendente
				runCalc((cAliasNF7)->CODIGO)
			elseIf (cAliasNF7)->STATUS == "8" //Aprovado
				runAprov((cAliasNF7)->CODIGO)
			EndIf

			NF7->(MsRUnlock(nRecnoNF7))
		EndIF

		(cAliasNF7)->(DBSkip())
	EndDo

	(cAliasNF7)->(DBCloseArea())
Return

/*/{Protheus.doc} runCalc
Realiza o calculo de Juros
@type function
@version 12
@author jc.maldonado
@since 06/08/2026
@param cCodigoNF7, character, Código NF7
/*/
Static Function runCalc(cCodigoNF7)
	Local oIntCapSrv := Nil

	oIntCapSrv := NAMESPACEAGD.CalculationInterestCapitalService():New()

	oIntCapSrv:calcular(cCodigoNF7)

	If ! oIntCapSrv:isSuccess()
		FWLogMsg("ERROR", Nil, AGD_JOB, procName(), Nil, Nil, i18n(STR0007, {cCodigoNF7, oIntCapSrv:getMessageError()})) //"Nao foi possi­vel realizar o calculo de juros para NF7_CODIGO=#1[CODIGO]# Erro: #2[MSG_ERROR]#"
	EndIf

	FWFreeObj(oIntCapSrv)
Return

/*/{Protheus.doc} runAprov
Realiza a aprovação de Juros
@type function
@version 12
@author jc.maldonado
@since 06/08/2026
@param cCodigoNF7, character, Código NF7
/*/
Static Function runAprov(cCodigoNF7)
	Local oIntCapSrv := Nil

	oIntCapSrv := NAMESPACEAGD.CalculationInterestCapitalService():New()

	oIntCapSrv:concluir(cCodigoNF7)

	If ! oIntCapSrv:isSuccess()
		FWLogMsg("ERROR", Nil, AGD_JOB, procName(), Nil, Nil, i18n(STR0008, {cCodigoNF7, oIntCapSrv:getMessageError()})) //"Nao foi possi­vel realizar o calculo de juros para NF7_CODIGO=#1[CODIGO]# Erro: #2[MSG_ERROR]#"
	EndIf

	FWFreeObj(oIntCapSrv)
Return
