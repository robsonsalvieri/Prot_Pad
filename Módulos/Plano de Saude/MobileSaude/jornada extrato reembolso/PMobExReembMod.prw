#Include "PROTHEUS.CH"
#Include "PMOBEXREEMBMOD.CH"

#Define cLineBreak Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobExReembMod
Classe responsavel por retornar os dados dos protocolos de reembolso
do beneficiário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Class PMobExReembMod From PMobJornMod

	// Propriedades obrigatorias nas API da Mobile
	Data oParametersMap
	Data Message
	Data oConfig
	// Dados de Entrada	
	Data cChaveBeneficiario	
	Data cDataInicial
	Data cDataFinal
	Data cChaveReembolso
	Data cMatriculaBenef
	// Dados de Saida
	Data oReeExtratoMap
	Data oReeDetalheMap
	Data oReeHistoricoMap
	Data oReeStatusMap

	Method New(oParametersMap) CONSTRUCTOR 

	// Metodos das regras de negocio da Classe
	Method reeExtrato()
	Method QueryExtrato()
	Method getReeExtrato()

	Method reeDetalhe()
	Method QueryDetalhe()
	Method documentoAnexo(cChaveDocument)
	Method QueryAnexo(cChaveDocument)
	Method getReeDetalhe()

	Method reeHistorico()
	Method QueryHistorico()
	Method getReeHistorico()

	Method reeStatus()
	Method GetStatus()
	Method getReeStatus()

	// Métodos de apoio para a regra de negocio
	Method GetReembStatus(cStatus)
	Method CopyArqWeb(cNomeArquivo)
	Method GetMessage()
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method New(oParametersMap) Class PMobExReembMod

	_Super:New()

	Self:oParametersMap	:= oParametersMap	
	Self:Message := ""	
	Self:oConfig := Nil

	Self:oReeExtratoMap := JsonObject():New() 
	Self:oReeExtratoMap["extrato"] := {}

	Self:oReeDetalheMap	:= JsonObject():New()
	Self:oReeDetalheMap["itens"] := {}
	Self:oReeDetalheMap["documentos"] := {}
	
	Self:oReeHistoricoMap := JsonObject():New()
	Self:oReeHistoricoMap["historico"] := {}

	Self:oReeStatusMap	:= JsonObject():New()
	Self:oReeStatusMap["reembolsoStatus"] := {}

	Self:cChaveBeneficiario := ""
	Self:cDataInicial := ""
	Self:cDataFinal := ""
	Self:cChaveReembolso := ""
	Self:cMatriculaBenef := ""

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} guiaAutorizacoes
Retorna uma lista com todos os protocolos de reembolso do beneficiário 
e do seu grupo familiar, conforme regra de negócio da sua operadora

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method reeExtrato() Class PMobExReembMod

	Local cQuery := ""
	Local cAliasTemp := ""
	Local nAddReembolso := 0
	Local i := 0
	Local lTemReemb := .F.

	// Dados recebidos do Json
	Self:cChaveBeneficiario := Self:oParametersMap["chaveBeneficiario"]
	Self:cDataInicial := Self:oParametersMap["dataInicial"]
	Self:cDataFinal := Self:oParametersMap["dataFinal"]

	aMatricula := _Super:GetCPFMatriculas(.T., Self:cChaveBeneficiario, .T.)

	If Len(aMatricula) > 0 .And. !Empty(aMatricula[1][1])
		cMatricula := ""

		For i := 1 to Len(aMatricula)
	
			Self:cMatriculaBenef := aMatricula[i][1] + aMatricula[i][2] + aMatricula[i][3] + aMatricula[i][4] + aMatricula[i][5]

			cQuery := Self:QueryExtrato()
			cAliasTemp := GetNextAlias()

			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTemp, .T., .F.)
			
	
			While !(cAliasTemp)->(Eof())

				aAdd(Self:oReeExtratoMap["extrato"], JsonObject():New())
				nAddReembolso := Len(Self:oReeExtratoMap["extrato"])
				
				lTemReemb := .T.

				Self:oReeExtratoMap["extrato"][nAddReembolso]["chaveReembolso"] := _Super:SetAtributo((cAliasTemp)->CHAVEREEMB, "String")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["beneficiarioMatricula"] := _Super:SetAtributo((cAliasTemp)->MATRICULA, "String")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["beneficiarioNome"] := _Super:SetAtributo((cAliasTemp)->NOME, "String")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["statusId"] := _Super:SetAtributo(Self:GetReembStatus((cAliasTemp)->STATUS), "Integer")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["cidade"] := _Super:SetAtributo((cAliasTemp)->CIDADE, "String")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["estado"] := _Super:SetAtributo((cAliasTemp)->ESTADO, "String")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["dataInclusao"] := _Super:SetAtributo((cAliasTemp)->DATAINCLUSAO, "Date")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["previsaoPagamento"] := _Super:SetAtributo((cAliasTemp)->DATAPAGAMENTO, "Date")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["prestadorCodigo"] := _Super:SetAtributo((cAliasTemp)->PRESTADOR, "String")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["prestadorNome"] := _Super:SetAtributo((cAliasTemp)->NOMEPRESTADOR, "String")	
				Self:oReeExtratoMap["extrato"][nAddReembolso]["prestadorCpfCnpj"] := _Super:SetAtributo(Posicione("BAU", 1, xFilial("BAU")+(cAliasTemp)->PRESTADOR, "BAU_CPFCGC"), "String")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["tipoServicoId"] := ""
				Self:oReeExtratoMap["extrato"][nAddReembolso]["tipoServicoDescricao"] := ""
				Self:oReeExtratoMap["extrato"][nAddReembolso]["valorApresentado"] := _Super:SetAtributo((cAliasTemp)->VLRAPRESENTADO, "Float")
				Self:oReeExtratoMap["extrato"][nAddReembolso]["valorReembolsado"] := _Super:SetAtributo((cAliasTemp)->VLRREEMBOLSADO, "Float")	
				Self:oReeExtratoMap["extrato"][nAddReembolso]["observacao"] := _Super:SetAtributo(Posicione("BOW", 1, xFilial("BAU")+(cAliasTemp)->CHAVEREEMB, "BOW_OBS"), "String")

				(cAliasTemp)->(DbSkip())
			Enddo

			(cAliasTemp)->(DbCloseArea())

		Next i			

		If !lTemReemb

			Self:Message := STR0001 // "Não existem protocolos de reembolso a serem visualizados"
			Return .F.
		Endif

	EndIf

	
		
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryExtrato
Monta Query para ser utilizado no método reeExtrato

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method QueryExtrato() Class PMobExReembMod

	Local cQuery := ""
	Local cDataInicial := ""
	Local cDataFinal := ""
	Local cMatricula := ""
	Local nMesesGuiaReemb := Self:oConfig["extrato"]["numberMonthsGuia"]


	If !Empty(Self:cDataInicial) .And. !Empty(Self:cDataFinal)
		cDataInicial := StrTran(Self:cDataInicial, "-", "")
		cDataFinal := StrTran(Self:cDataFinal, "-", "")
	Else
		cDataInicial := DToS(MonthSub(dDataBase, nMesesGuiaReemb))
		cDataFinal := DToS(dDataBase)
	EndIf

	cMatricula	:= Self:cMatriculaBenef

	// Guias/Protocolos de Reembolso
	cQuery := " SELECT BOW.BOW_PROTOC AS CHAVEREEMB," + cLineBreak
	cQuery += "  	   BOW.BOW_USUARI AS MATRICULA," + cLineBreak
	cQuery += "  	   BOW.BOW_NOMUSR AS NOME," + cLineBreak
	cQuery += "  	   BOW.BOW_STATUS AS STATUS," + cLineBreak
	cQuery += "  	   BOW.BOW_DESMUN AS CIDADE," + cLineBreak
	cQuery += "  	   BOW.BOW_UFATE AS ESTADO," + cLineBreak
	cQuery += "  	   BOW.BOW_DTDIGI AS DATAINCLUSAO," + cLineBreak
	cQuery += "  	   BOW.BOW_DATPAG AS DATAPAGAMENTO," + cLineBreak
	cQuery += "  	   BOW.BOW_CODRDA AS PRESTADOR," + cLineBreak
	cQuery += "  	   BOW.BOW_NOMRDA AS NOMEPRESTADOR," + cLineBreak
	cQuery += "  	   BOW.BOW_VLRAPR AS VLRAPRESENTADO," + cLineBreak
	cQuery += "  	   BOW.BOW_VLRREE AS VLRREEMBOLSADO" + cLineBreak
	
	cQuery += " FROM "+RetSQLName("BOW")+" BOW " + cLineBreak
	cQuery += " WHERE BOW.BOW_FILIAL = '"+xFilial("BOW")+"' " + cLineBreak
	
		If !Empty(cMatricula)
		cQuery += "   AND BOW.BOW_USUARI LIKE '"+cMatricula+"%' " + cLineBreak
	Else	
		cQuery += "   AND BOW.BOW_USUARI = '' " + cLineBreak
	EndIf

	cQuery += "   AND (BOW.BOW_DTDIGI >= '"+cDataInicial+"' AND BOW.BOW_DTDIGI <= '"+cDataFinal+"'  )" + cLineBreak
	cQuery += "   AND BOW.D_E_L_E_T_ = ' ' " + cLineBreak

	cQuery += " ORDER BY DATAINCLUSAO DESC" + cLineBreak

Return cQuery 


//-------------------------------------------------------------------
/*/{Protheus.doc} getReeExtrato
Retorna o Map da lista de Protocolos de Reembolso do Beneficiário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method getReeExtrato() Class PMobExReembMod
Return (Self:oReeExtratoMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} reeDetalhe
Retorna os detalhes (itens) do protocolo de reembolso

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 11/02/2022
/*/
//------------------------------------------------------------------- 
Method reeDetalhe() Class PMobExReembMod

	Local cQuery := ""
	Local cAliasTemp := ""
	Local cChaveDocument := ""
	Local nAddItem := 0

	// Dados recebidos do Json
	Self:cChaveReembolso := Self:oParametersMap["chaveReembolso"]

	cQuery := Self:QueryDetalhe()
	cAliasTemp := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTemp, .T., .F.)
	
	If (cAliasTemp)->(Eof())
		Self:Message := STR0002 // "Não existem detalhes a serem visualizados"

		(cAliasTemp)->(DbCloseArea())
		Return .F.
	Else
		cChaveDocument := xFilial("BOW")+(cAliasTemp)->(OPERADORA+PROTOCOLO)
	Endif

	While !(cAliasTemp)->(Eof())

		aAdd(Self:oReeDetalheMap["itens"], JsonObject():New())
		nAddItem := Len(Self:oReeDetalheMap["itens"])

		Self:oReeDetalheMap["itens"][nAddItem]["itemId"] := _Super:SetAtributo((cAliasTemp)->ITEMID, "String")
		Self:oReeDetalheMap["itens"][nAddItem]["procedimento"] := _Super:SetAtributo((cAliasTemp)->PROCEDIMENTO, "String")
		Self:oReeDetalheMap["itens"][nAddItem]["procedimentoDescricao"] := _Super:SetAtributo(Posicione("BR8", 1, xFilial("BR8")+(cAliasTemp)->(TABELAPROC+PROCEDIMENTO), "BR8_DESCRI"), "String")
		Self:oReeDetalheMap["itens"][nAddItem]["statusId"] := _Super:SetAtributo(Self:GetReembStatus((cAliasTemp)->STATUS), "Integer")
		Self:oReeDetalheMap["itens"][nAddItem]["cidade"] := _Super:SetAtributo((cAliasTemp)->CIDADE, "String")
		Self:oReeDetalheMap["itens"][nAddItem]["estado"] := _Super:SetAtributo((cAliasTemp)->ESTADO, "String")
		Self:oReeDetalheMap["itens"][nAddItem]["dataExecucao"] := _Super:SetAtributo((cAliasTemp)->DATAEXECUCAO, "Date")
		Self:oReeDetalheMap["itens"][nAddItem]["documentoTipo"] := _Super:SetAtributo((cAliasTemp)->TIPODOCUMENTO, "String")
		Self:oReeDetalheMap["itens"][nAddItem]["documentoNumero"] := _Super:SetAtributo((cAliasTemp)->NUMDOCUMENTO, "String")
		Self:oReeDetalheMap["itens"][nAddItem]["quantidadeExecutada"] := _Super:SetAtributo((cAliasTemp)->QTDEXECUTADA, "Float")
		Self:oReeDetalheMap["itens"][nAddItem]["valorApresentado"] := _Super:SetAtributo((cAliasTemp)->VLRAPRESENTADO, "Float")
		Self:oReeDetalheMap["itens"][nAddItem]["valorReembolsado"] := _Super:SetAtributo((cAliasTemp)->VLRREEMBOLSADO, "Float")
		Self:oReeDetalheMap["itens"][nAddItem]["observacao"] := ""

		(cAliasTemp)->(DbSkip())
	EndDo

	(cAliasTemp)->(DbCloseArea())

	Self:documentoAnexo(cChaveDocument)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryDetalhe
Monta Query para ser utilizado no método reeDetalhe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method QueryDetalhe() Class PMobExReembMod

	Local cQuery := ""
	Local cBancoDados := AllTrim(TCGetDB())
	Local cOperadorSql := ""

	cOperadorSql := IIf(cBancoDados $ "ORACLE|DB2|POSTGRES", "||", "+")

	cQuery := " SELECT B1N.B1N_PROTOC "+cOperadorSql+" B1N.B1N_SEQUEN AS ITEMID," + cLineBreak
	cQuery += " 	   B1N.B1N_CODPAD AS TABELAPROC," + cLineBreak
	cQuery += " 	   B1N.B1N_CODPRO AS PROCEDIMENTO," + cLineBreak
	cQuery += " 	   B1N.B1N_IMGSTA AS STATUS," + cLineBreak
	cQuery += " 	   B1N.B1N_DESMUN AS CIDADE," + cLineBreak
	cQuery += " 	   B1N.B1N_EST AS ESTADO," + cLineBreak
	cQuery += " 	   B1N.B1N_DATPRO AS DATAEXECUCAO," + cLineBreak
	cQuery += " 	   B1N.B1N_TIPDOC AS TIPODOCUMENTO," + cLineBreak
	cQuery += " 	   B1N.B1N_NUMDOC AS NUMDOCUMENTO," + cLineBreak
	cQuery += " 	   B1N.B1N_QTDPRO AS QTDEXECUTADA," + cLineBreak
	cQuery += " 	   B1N.B1N_VLRAPR AS VLRAPRESENTADO," + cLineBreak
	cQuery += " 	   B1N.B1N_VLRREE AS VLRREEMBOLSADO," + cLineBreak
	cQuery += " 	   BOW.BOW_OPEMOV AS OPERADORA," + cLineBreak
	cQuery += " 	   BOW.BOW_PROTOC AS PROTOCOLO" + cLineBreak

	cQuery += " FROM "+RetSQLName("B1N")+" B1N " + cLineBreak

	cQuery += " INNER JOIN "+RetSQLName("BOW")+" BOW " + cLineBreak
	cQuery += "	   ON BOW.BOW_FILIAL = '"+xFilial("BOW")+"' " + cLineBreak
	cQuery += "   AND BOW.BOW_PROTOC = B1N.B1N_PROTOC " + cLineBreak
	cQuery += "   AND BOW.D_E_L_E_T_ = ' ' " + cLineBreak

	cQuery += " WHERE B1N.B1N_FILIAL = '"+xFilial("B1N")+"' " + cLineBreak
	cQuery += "   AND B1N.B1N_PROTOC = '"+Self:cChaveReembolso+"' " + cLineBreak
	cQuery += "   AND B1N.D_E_L_E_T_ = ' ' " + cLineBreak

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} documentoAnexo
Adiciona ao DetalheMap os documentos em anexo do protocolo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 11/02/2022
/*/
//------------------------------------------------------------------- 
Method documentoAnexo(cChaveDocument) Class PMobExReembMod

	Local cQuery := ""
	Local cAliasTemp := ""
	Local nAddAnexo := 0
	Local cEndDocument := Self:oConfig["extrato"]["urlDocuments"]

	cQuery := Self:QueryAnexo(cChaveDocument)
	cAliasTemp := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTemp, .T., .F.)
	
	If (cAliasTemp)->(Eof())

		(cAliasTemp)->(DbCloseArea())
		Return

	Endif

	While !(cAliasTemp)->(Eof())

		aAdd(Self:oReeDetalheMap["documentos"], JsonObject():New())
		nAddAnexo := Len(Self:oReeDetalheMap["documentos"])

		Self:oReeDetalheMap["documentos"][nAddAnexo]["nomeApresentacao"] := _Super:SetAtributo((cAliasTemp)->NOME, "String")
		Self:oReeDetalheMap["documentos"][nAddAnexo]["nomeArquivo"] := _Super:SetAtributo((cAliasTemp)->ARQUIVO, "String")
		Self:oReeDetalheMap["documentos"][nAddAnexo]["caminhoArquivo"] := _Super:SetAtributo(cEndDocument + (cAliasTemp)->ARQUIVO, "String")

		Self:CopyArqWeb(Alltrim((cAliasTemp)->ARQUIVO))

		(cAliasTemp)->(DbSkip())
	EndDo

	(cAliasTemp)->(DbCloseArea())

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryAnexo
Monta Query para ser utilizado no método documentoAnexo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 11/02/2022
/*/
//------------------------------------------------------------------- 
Method QueryAnexo(cChaveDocument) Class PMobExReembMod

	Local cQuery := ""
	
	cQuery := " SELECT ACB.ACB_DESCRI AS NOME, " + cLineBreak
	cQuery += " 	   ACB.ACB_OBJETO AS ARQUIVO " + cLineBreak

	cQuery += " FROM "+RetSQLName("AC9")+" AC9 " + cLineBreak
	cQuery += " INNER JOIN "+RetSQLName("ACB")+" ACB " + cLineBreak
	cQuery += "	  ON ACB.ACB_FILIAL = '"+xFilial("ACB")+"' " + cLineBreak
	cQuery += "  AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ " + cLineBreak
	cQuery += "  AND ACB.D_E_L_E_T_ = ' ' " + cLineBreak

	cQuery += "	 WHERE AC9.AC9_FILIAL = '"+xFilial("AC9")+"' " + cLineBreak
	cQuery += "    AND AC9.AC9_ENTIDA = 'BOW' " + cLineBreak
	cQuery += "    AND AC9.AC9_CODENT = '"+cChaveDocument+"' " + cLineBreak
	cQuery += "    AND AC9.D_E_L_E_T_ = ' ' " + cLineBreak

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} getReeDetalhe
Retorna o Map da lista de Itens do protocolo de reembolso

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method getReeDetalhe() Class PMobExReembMod
Return (Self:oReeDetalheMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} reeHistorico
Este método irá retornar o histórico de alterações de status do 
protocolo/guia de reembolso

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/02/2022
/*/
//------------------------------------------------------------------- 
Method reeHistorico() Class PMobExReembMod

	Local cQuery := ""
	Local cAliasTemp := ""
	Local nAddHist := 0

	// Dados recebidos do Json
	Self:cChaveReembolso := Self:oParametersMap["chaveReembolso"]

	cQuery := Self:QueryHistorico()
	cAliasTemp := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTemp, .T., .F.)
	
	If (cAliasTemp)->(Eof())
		Self:Message := STR0003 // "Não existem históricos a serem visualizados"

		(cAliasTemp)->(DbCloseArea())
		Return .F.
	Endif

	While !(cAliasTemp)->(Eof())

		aAdd(Self:oReeHistoricoMap["historico"], JsonObject():New())
		nAddHist := Len(Self:oReeHistoricoMap["historico"])

		Self:oReeHistoricoMap["historico"][nAddHist]["dataHora"] := _Super:SetAtributo((cAliasTemp)->DATA, "Date") + " " + _Super:SetAtributo((cAliasTemp)->HORA, "String")
		Self:oReeHistoricoMap["historico"][nAddHist]["statusId"] := _Super:SetAtributo(Self:GetReembStatus((cAliasTemp)->STATUS), "String")

		(cAliasTemp)->(DbSkip())
	EndDo

	(cAliasTemp)->(DbCloseArea())

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryHistorico
Monta Query para ser utilizado no método reeHistorico

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/02/2022
/*/
//------------------------------------------------------------------- 
Method QueryHistorico() Class PMobExReembMod

	Local cQuery := ""
	Local cOperadora := PlsIntPad()

	cQuery := " SELECT BOX.BOX_DATA AS DATA," + cLineBreak
	cQuery += " 	   BOX.BOX_HORA AS HORA," + cLineBreak
	cQuery += " 	   BOX.BOX_STATUS AS STATUS " + cLineBreak

	cQuery += " FROM "+RetSQLName("BOX")+" BOX " + cLineBreak

	cQuery += " WHERE BOX.BOX_FILIAL = '"+xFilial("BOX")+"' " + cLineBreak
	cQuery += "   AND BOX.BOX_CODOPE = '"+cOperadora+"' " + cLineBreak
	cQuery += "   AND BOX.BOX_PROTOC = '"+Self:cChaveReembolso+"' " + cLineBreak
	cQuery += "   AND BOX.D_E_L_E_T_ = ' ' " + cLineBreak

	cQuery += " ORDER BY DATA,HORA DESC" + cLineBreak
	
Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} getReeHistorico
Retorna o Map do histórico de alteração do status do reembolso

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method getReeHistorico() Class PMobExReembMod
Return (Self:oReeHistoricoMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} reeStatus
Retorna a tabela de domínio dos status dos reembolsos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/02/2022
/*/
//------------------------------------------------------------------- 
Method reeStatus() Class PMobExReembMod

	Local aStatus := {}
	Local nX := 0
	Local nAddItem := 0
	Local lRetorno := .F.

	aStatus := Self:GetStatus()

	Self:Message := IIf(Len(aStatus) == 0, STR0004, "") // "Não existem status a serem visualizados"

	If Empty(Self:Message)
		For nX := 1 To Len(aStatus)

			aAdd(Self:oReeStatusMap["reembolsoStatus"], JsonObject():New())
			nAddItem := Len(Self:oReeStatusMap["reembolsoStatus"])

			Self:oReeStatusMap["reembolsoStatus"][nAddItem]["chaveStatus"] := _Super:SetAtributo(aStatus[nX][1], "String")
			Self:oReeStatusMap["reembolsoStatus"][nAddItem]["descricao"] := _Super:SetAtributo(aStatus[nX][2], "String")

		Next nX

		lRetorno := .T.
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Retorna o status os status do Reembolso de acordo com X3_CBOX do campo
BOW_STATUS

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/02/2022
/*/
//------------------------------------------------------------------- 
Method GetStatus() Class PMobExReembMod

	Local aRetorno := {}	

	aAdd(aRetorno, {"0", STR0005}) // "Solicitação não concluida"
	aAdd(aRetorno, {"1", STR0006}) // "Protocolado"
	aAdd(aRetorno, {"2", STR0007}) // "Em Analise"
	aAdd(aRetorno, {"3", STR0008}) // "Aprovado"
	aAdd(aRetorno, {"4", STR0009}) // "Rejeitado"
	aAdd(aRetorno, {"5", STR0010}) // "Aguardando informação do beneficiário"
	aAdd(aRetorno, {"6", STR0011}) // "Aprovado parcialmente"
	aAdd(aRetorno, {"7", STR0012}) // "Cancelado"
	aAdd(aRetorno, {"8", STR0013}) // "Reembolso revertido"

Return aRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiaStatus
Retorna o Map da lista de status do Reembolso

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/02/2022
/*/
//------------------------------------------------------------------- 
Method getReeStatus() Class PMobExReembMod
Return (Self:oReeStatusMap)


//-----------------------------------------------------------------
/*/{Protheus.doc} GetReembStatus
Retorna o Status do Reembolso

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 11/02/2022
/*/
//-----------------------------------------------------------------
Method GetReembStatus(cStatus) Class PMobExReembMod

	Local cRetorno := ""

	cStatus := Alltrim(cStatus) 

	Do Case
		Case cStatus == "A" 
			cRetorno := "0" // Solicitação não concluida
		
		Case cStatus == "0" .Or. cStatus == "1"
			cRetorno := "1" // Protocolado

		Case cStatus == "2" .Or. cStatus == "3" .Or. cStatus == "5" .Or. cStatus == "9"
			cRetorno := "2" // Em Analise

		Case cStatus == "6" .Or. cStatus == "ENABLE" 
			cRetorno := "3" // Aprovado

		Case cStatus == "4" .Or. cStatus == "7" .Or. cStatus == "8" .Or. cStatus == "DISABLE"
			cRetorno := "4" // Rejeitado

		Case cStatus == "B" 
			cRetorno := "5" // Aguardando informação do beneficiário

		Case cStatus == "C" 
			cRetorno := "6" // Aprovado parcialmente

		Case cStatus == "D"
			cRetorno := "7" // Cancelado
		
		Case cStatus == "E"
			cRetorno := "8" // Reembolso revertido

	EndCase

Return cRetorno


//-----------------------------------------------------------------
/*/{Protheus.doc} CopyArqWeb
Copia o arquivo da base de conhecimento (Anexo) para a pasta web para
realizar o download

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 11/02/2022
/*/
//-----------------------------------------------------------------
Method CopyArqWeb(cNomeArquivo) Class PMobExReembMod

	Local cPathRelWeb := PLSMUDSIS(getWebDir()+getSkinPls()+"\relatorios\")	
	Local lRetorno := .F.

	cDirDocs := IIf(FindFunction("MsMultDir") .And. MsMultDir(), MsRetPath(), MsDocPath())

	If !File(cPathRelWeb+cNomeArquivo)
		If File(MsDocPath()+"\"+cNomeArquivo)

			__CopyFile(MsDocPath()+"\"+cNomeArquivo, cPathRelWeb+cNomeArquivo)

			If File(cPathRelWeb+cNomeArquivo)
				lRetorno := .T.
			EndIf
		Endif
	Else
		lRetorno := .T.
	EndIf
 
Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMessage
Retorna mensagens de erro dos métodos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method GetMessage() Class PMobExReembMod
Return (Self:Message)