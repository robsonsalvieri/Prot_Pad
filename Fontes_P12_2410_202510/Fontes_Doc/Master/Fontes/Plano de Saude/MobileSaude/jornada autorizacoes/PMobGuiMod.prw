#Include "PROTHEUS.CH"
#Include "PMOBGUIMOD.CH"

#Define cLineBreak Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobGuiMod
Classe responsavel por retornar os dados das autorizações do beneficiário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 04/02/2022
/*/
//------------------------------------------------------------------- 
Class PMobGuiMod From PMobJornMod

	// Propriedades obrigatorias nas API da Mobile
	Data oParametersMap
	Data Message
	Data oConfig
	// Dados de Entrada
	Data lMultiContract 	
	Data lLoginByCPF		
	Data cChaveBeneficiario	
	Data cDataInicial
	Data cDataFinal
	Data cMatriculaContrato
	Data cChaveAutorizacao
	// Dados de Saida
	Data oGuiaAutorizacoesMap
	Data oDetalheAutorizacaoMap
	Data oGuiaPdfMap
	Data oStatusAutorizacaoMap
	Data cBinaryFile
	Data cURLFile

	Method New(oParametersMap) CONSTRUCTOR 

	// Metodos das regras de negocio da Classe
	Method guiaAutorizacoes()
	Method QueryAutorizacoes()
	Method getGuiaAutorizacoes()

	Method guiaDetalhe()
	Method QueryDetalhe()
	Method getGuiaDetalhe()

	Method guiaPdf()
	Method GeraPdf()
	Method PdfGuiaSADT(cGuia, cPathRelWeb)
	Method PdfGuiaInternacao(cGuia, cPathRelWeb)
	Method PdfGuiaProrrogacao(cGuia, cPathRelWeb)
	Method PdfGuiaAnexo(cGuia, cPathRelWeb)
	Method getGuiaPdf()

	Method guiaStatus()
	Method GetStatus()
	Method getGuiaStatus()

	// Métodos de apoio para a regra de negocio
	Method WhereMatriculas(cTabela, aMatriculas)
	Method WhereChaveGuia(cTabela, cChaveAutorizacao)	
	Method GetNomeEspecialidade(cCodEspecialidade)
	Method GetNomeTratamento(cTipoTratamento)
	Method GetMessage()
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method New(oParametersMap) Class PMobGuiMod

	_Super:New()

	Self:oParametersMap	:= oParametersMap	
	Self:Message := ""	
	Self:oConfig := Nil

	Self:oGuiaAutorizacoesMap := JsonObject():New() 
	Self:oGuiaAutorizacoesMap["autorizacoes"] := {}

	Self:oDetalheAutorizacaoMap	:= JsonObject():New()
	Self:oDetalheAutorizacaoMap["itens"] := {}

	Self:oGuiaPdfMap := JsonObject():New()

	Self:oStatusAutorizacaoMap	:= JsonObject():New()
	Self:oStatusAutorizacaoMap["autorizacaoStatus"] := {}

	Self:cBinaryFile := ""
	Self:cURLFile := ""
	
	Self:lMultiContract := .F.
	Self:lLoginByCPF := .F.
	Self:cChaveBeneficiario := ""
	Self:cDataInicial := ""
	Self:cDataFinal := ""
	Self:cMatriculaContrato := ""
	Self:cChaveAutorizacao := ""

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} guiaAutorizacoes
Retorna uma lista com todos os protocolos de autorização do beneficiário 
e do seu grupo familiar, conforme regra de negócio da sua operadora.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/01/2022
/*/
//------------------------------------------------------------------- 
Method guiaAutorizacoes() Class PMobGuiMod

	Local cQuery := ""
	Local cAliasTemp := ""
	Local nAddAutorizacao := 0

	// Dados recebidos do Json
	Self:lMultiContract := Self:oParametersMap["multiContract"]
	Self:lLoginByCPF := Self:oParametersMap["chaveBeneficiarioTipo"] == 'CPF'
	Self:cChaveBeneficiario := Self:oParametersMap["chaveBeneficiario"]
	Self:cDataInicial := Self:oParametersMap["dataInicial"]
	Self:cDataFinal := Self:oParametersMap["dataFinal"]
	Self:cMatriculaContrato := Self:oParametersMap["matriculaContrato"]
	
	cQuery := Self:QueryAutorizacoes()
	cAliasTemp := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTemp, .T., .F.)
	
	If (cAliasTemp)->(Eof())
		Self:Message := STR0001 // "Não existem autorizações a serem visualizadas"

		(cAliasTemp)->(DbCloseArea())
		Return .T.
	Endif

	While !(cAliasTemp)->(Eof())

		aAdd(Self:oGuiaAutorizacoesMap["autorizacoes"], JsonObject():New())
		nAddAutorizacao := Len(Self:oGuiaAutorizacoesMap["autorizacoes"])

		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["chaveAutorizacao"] := _Super:SetAtributo((cAliasTemp)->TABELA+"|"+(cAliasTemp)->CHAVEGUIA, "String")
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["beneficiarioMatricula"] := _Super:SetAtributo((cAliasTemp)->MATRICULA, "String")
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["beneficiarioNome"] := _Super:SetAtributo((cAliasTemp)->NOMEBENEFICIARIO, "String")
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["statusId"] := _Super:SetAtributo((cAliasTemp)->STATUS, "Integer")
		
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["dataSolicitacao"] := _Super:SetAtributo(Iif(!Empty((cAliasTemp)->DATASOLICITACAO),(cAliasTemp)->DATASOLICITACAO,(cAliasTemp)->DATAAUTORIZACAO), "Date")
		
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["dataAutorizacao"] := _Super:SetAtributo((cAliasTemp)->DATAAUTORIZACAO, "Date")
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["nomePrestador"] := _Super:SetAtributo((cAliasTemp)->NOMEPRESTADOR, "String")
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["especialidade"] := _Super:SetAtributo(Self:GetNomeEspecialidade((cAliasTemp)->ESPECIALIDADE), "String")
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["tipoTratamento"] := _Super:SetAtributo(Self:GetNomeTratamento((cAliasTemp)->TIPOTRATAMENTO), "String")
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["numeroPedido"] := _Super:SetAtributo((cAliasTemp)->NUMEROPEDIDO, "String")
		Self:oGuiaAutorizacoesMap["autorizacoes"][nAddAutorizacao]["senha "] := _Super:SetAtributo((cAliasTemp)->SENHA, "String")

		(cAliasTemp)->(DbSkip())
	Enddo

	(cAliasTemp)->(DbCloseArea())
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryAutorizacoes
Monta Query para ser utilizado no método guiaAutorizacoes

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/01/2022
/*/
//------------------------------------------------------------------- 
Method QueryAutorizacoes() Class PMobGuiMod

	Local cQuery := ""
	Local cBancoDados := AllTrim(TCGetDB())
	Local cOperadorSql := "" 
	Local cSubstrSql := ""
	Local aMatriculas := {}
	Local cDataInicial := ""
	Local cDataFinal := ""
	Local nMesesGuia := Self:oConfig["extrato"]["numberMonthsGuia"]

	cOperadorSql := IIf(cBancoDados $ "ORACLE|DB2|POSTGRES", "||", "+")
	cSubstrSql := IIf(cBancoDados $ "ORACLE|DB2|POSTGRES", "SUBSTR", "SUBSTRING")

	aMatriculas := _Super:GetMatriculas(Self:cMatriculaContrato, .T.)

	If !Empty(Self:cDataInicial) .And. !Empty(Self:cDataFinal)
		cDataInicial := StrTran(Self:cDataInicial, "-", "")
		cDataFinal := StrTran(Self:cDataFinal, "-", "")
	Else	
		cDataInicial := DToS(MonthSub(dDataBase, nMesesGuia))
		cDataFinal := DToS(dDataBase)
	EndIf

	// Guias SADT/Consulta/Odontologica
	cQuery := " SELECT 'BEA' AS TABELA," + cLineBreak
	cQuery += " 	   BEA.BEA_OPEMOV "+cOperadorSql+" BEA.BEA_ANOAUT "+cOperadorSql+" BEA.BEA_MESAUT "+cOperadorSql+" BEA.BEA_NUMAUT AS CHAVEGUIA," + cLineBreak
	cQuery += " 	   BEA.BEA_OPEUSR "+cOperadorSql+" BEA.BEA_CODEMP "+cOperadorSql+" BEA.BEA_MATRIC "+cOperadorSql+" BEA.BEA_TIPREG "+cOperadorSql+" BEA.BEA_DIGITO AS MATRICULA," + cLineBreak
	cQuery += " 	   BEA.BEA_NOMUSR AS NOMEBENEFICIARIO," + cLineBreak
	cQuery += " 	   BEA.BEA_STTISS AS STATUS," + cLineBreak
	cQuery += "		   BEA.BEA_DATSOL AS DATASOLICITACAO," + cLineBreak
	cQuery += "		   BEA.BEA_DATPRO AS DATAAUTORIZACAO," + cLineBreak
	cQuery += "		   BEA.BEA_NOMRDA AS NOMEPRESTADOR," + cLineBreak
	cQuery += "		   BEA.BEA_CODESP AS ESPECIALIDADE," + cLineBreak
	cQuery += "		   (CASE BEA.BEA_TIPO WHEN '4' THEN '13' ELSE BEA.BEA_TIPGUI END) AS TIPOTRATAMENTO," + cLineBreak
	cQuery += "		   BEA.BEA_ANOAUT "+cOperadorSql+" BEA.BEA_MESAUT "+cOperadorSql+" BEA.BEA_NUMAUT AS NUMEROPEDIDO," + cLineBreak
	cQuery += "		   BEA.BEA_SENHA AS SENHA " + cLineBreak

	cQuery += " FROM "+RetSQLName("BEA")+" BEA " + cLineBreak
	cQuery += " WHERE BEA.BEA_FILIAL = '"+xFilial("BEA")+"' " + cLineBreak
	cQuery += Self:WhereMatriculas("BEA", aMatriculas)
	cQuery += "   AND (BEA.BEA_DATPRO >= '"+cDataInicial+"' AND BEA.BEA_DATPRO <= '"+cDataFinal+"'  )" + cLineBreak
	cQuery += "   AND BEA.BEA_TIPO <> '3' " + cLineBreak
	cQuery += "   AND BEA.D_E_L_E_T_ = ' ' " + cLineBreak

	cQuery += " UNION" + cLineBreak

	// Guias Internação
	cQuery += " SELECT 'BE4' AS TABELA," + cLineBreak
	cQuery += " 	   BE4.BE4_CODOPE "+cOperadorSql+" BE4.BE4_ANOINT "+cOperadorSql+" BE4.BE4_MESINT "+cOperadorSql+" BE4.BE4_NUMINT AS CHAVEGUIA," + cLineBreak
	cQuery += " 	   BE4.BE4_OPEUSR "+cOperadorSql+" BE4.BE4_CODEMP "+cOperadorSql+" BE4.BE4_MATRIC "+cOperadorSql+" BE4.BE4_TIPREG "+cOperadorSql+" BE4.BE4_DIGITO AS MATRICULA," + cLineBreak
	cQuery += " 	   BE4.BE4_NOMUSR AS NOMEBENEFICIARIO," + cLineBreak
	cQuery += " 	   BE4.BE4_STTISS AS STATUS," + cLineBreak
	cQuery += "		   BE4.BE4_DTDIGI AS DATASOLICITACAO," + cLineBreak
	cQuery += "		   BE4.BE4_DATPRO AS DATAAUTORIZACAO," + cLineBreak
	cQuery += "		   BE4.BE4_NOMRDA AS NOMEPRESTADOR," + cLineBreak
	cQuery += "		   BE4.BE4_CODESP AS ESPECIALIDADE," + cLineBreak
	cQuery += "		   BE4.BE4_TIPGUI AS TIPOTRATAMENTO," + cLineBreak
	cQuery += "		   BE4.BE4_ANOINT "+cOperadorSql+" BE4.BE4_MESINT "+cOperadorSql+" BE4.BE4_NUMINT AS NUMEROPEDIDO," + cLineBreak
	cQuery += "		   BE4.BE4_SENHA AS SENHA " + cLineBreak

	cQuery += " FROM "+RetSQLName("BE4")+" BE4 " + cLineBreak
	cQuery += " WHERE BE4.BE4_FILIAL = '"+xFilial("BE4")+"' " + cLineBreak
	cQuery += Self:WhereMatriculas("BE4", aMatriculas)
	cQuery += "   AND (BE4.BE4_DTDIGI >= '"+cDataInicial+"' AND BE4.BE4_DTDIGI <= '"+cDataFinal+"'  )" + cLineBreak
	cQuery += "   AND BE4.D_E_L_E_T_ = ' ' " + cLineBreak

	cQuery += " UNION" + cLineBreak

	// Guias Prorrogação de Internação
	cQuery += " SELECT 'B4Q' AS TABELA," + cLineBreak
	cQuery += " 	   B4Q.B4Q_OPEMOV "+cOperadorSql+" B4Q.B4Q_ANOAUT "+cOperadorSql+" B4Q.B4Q_MESAUT "+cOperadorSql+" B4Q.B4Q_NUMAUT AS CHAVEGUIA," + cLineBreak
	cQuery += " 	   B4Q.B4Q_OPEUSR "+cOperadorSql+" B4Q.B4Q_CODEMP "+cOperadorSql+" B4Q.B4Q_MATRIC "+cOperadorSql+" B4Q.B4Q_TIPREG "+cOperadorSql+" B4Q.B4Q_DIGITO AS MATRICULA," + cLineBreak
	cQuery += " 	   B4Q.B4Q_NOMUSR AS NOMEBENEFICIARIO," + cLineBreak
	cQuery += " 	   B4Q.B4Q_STTISS AS STATUS," + cLineBreak
	cQuery += "		   B4Q.B4Q_DATSOL AS DATASOLICITACAO," + cLineBreak
	cQuery += "		   B4Q.B4Q_DATPRO AS DATAAUTORIZACAO," + cLineBreak
	cQuery += "		   B4Q.B4Q_NOMRDA AS NOMEPRESTADOR," + cLineBreak
	cQuery += "		   BE4.BE4_CODESP AS ESPECIALIDADE," + cLineBreak
	cQuery += "		   '11' AS TIPOTRATAMENTO," + cLineBreak
	cQuery += "		   B4Q.B4Q_ANOAUT "+cOperadorSql+" B4Q.B4Q_MESAUT "+cOperadorSql+" B4Q.B4Q_NUMAUT AS NUMEROPEDIDO," + cLineBreak
	cQuery += "		   B4Q.B4Q_SENHA AS SENHA " + cLineBreak

	cQuery += " FROM "+RetSQLName("B4Q")+" B4Q " + cLineBreak
	cQuery += " INNER JOIN "+RetSQLName("BE4")+" BE4 " + cLineBreak
	cQuery += "	   ON BE4.BE4_FILIAL = '"+xFilial("BE4")+"' " + cLineBreak
	cQuery += "   AND BE4.BE4_CODOPE = "+cSubstrSql+"(B4Q.B4Q_GUIREF, 1, 4) " + cLineBreak
	cQuery += "   AND BE4.BE4_ANOINT = "+cSubstrSql+"(B4Q.B4Q_GUIREF, 5, 4) " + cLineBreak
	cQuery += "   AND BE4.BE4_MESINT = "+cSubstrSql+"(B4Q.B4Q_GUIREF, 9, 2) " + cLineBreak
	cQuery += "   AND BE4.BE4_NUMINT = "+cSubstrSql+"(B4Q.B4Q_GUIREF, 11, 8) " + cLineBreak

	cQuery += " WHERE B4Q.B4Q_FILIAL = '"+xFilial("B4Q")+"' " + cLineBreak
	cQuery += Self:WhereMatriculas("B4Q", aMatriculas)
	cQuery += "   AND (B4Q.B4Q_DATPRO >= '"+cDataInicial+"' AND B4Q.B4Q_DATPRO <= '"+cDataFinal+"'  )" + cLineBreak
	cQuery += "   AND B4Q.D_E_L_E_T_ = ' ' " + cLineBreak
	cQuery += "   AND BE4.D_E_L_E_T_ = ' ' " + cLineBreak

	cQuery += " UNION" + cLineBreak

	// Guias Anexo Clinico
	cQuery += " SELECT 'B4A' AS TABELA," + cLineBreak
	cQuery += " 	   B4A.B4A_OPEMOV "+cOperadorSql+" B4A.B4A_ANOAUT "+cOperadorSql+" B4A.B4A_MESAUT "+cOperadorSql+" B4A.B4A_NUMAUT AS CHAVEGUIA," + cLineBreak
	cQuery += " 	   B4A.B4A_OPEUSR "+cOperadorSql+" B4A.B4A_CODEMP "+cOperadorSql+" B4A.B4A_MATRIC "+cOperadorSql+" B4A.B4A_TIPREG "+cOperadorSql+" B4A.B4A_DIGITO AS MATRICULA," + cLineBreak
	cQuery += " 	   B4A.B4A_NOMUSR AS NOMEBENEFICIARIO," + cLineBreak
	cQuery += " 	   B4A.B4A_STTISS AS STATUS," + cLineBreak
	cQuery += "		   B4A.B4A_DATSOL AS DATASOLICITACAO," + cLineBreak
	cQuery += "		   B4A.B4A_DATPRO AS DATAAUTORIZACAO," + cLineBreak
	cQuery += "		   BEA.BEA_NOMRDA AS NOMEPRESTADOR," + cLineBreak
	cQuery += "		   BEA.BEA_CODESP AS ESPECIALIDADE," + cLineBreak
	cQuery += "		   B4A.B4A_TIPGUI AS TIPOTRATAMENTO," + cLineBreak
	cQuery += "		   B4A.B4A_ANOAUT "+cOperadorSql+" B4A.B4A_MESAUT "+cOperadorSql+" B4A.B4A_NUMAUT AS NUMEROPEDIDO," + cLineBreak
	cQuery += "		   B4A.B4A_SENHA AS SENHA " + cLineBreak

	cQuery += " FROM "+RetSQLName("B4A")+" B4A " + cLineBreak
	cQuery += " INNER JOIN "+RetSQLName("BEA")+" BEA " + cLineBreak
	cQuery += "	   ON BEA.BEA_FILIAL = '"+xFilial("BEA")+"' " + cLineBreak
	cQuery += "   AND BEA.BEA_OPEMOV = "+cSubstrSql+"(B4A.B4A_GUIREF, 1, 4) " + cLineBreak
	cQuery += "   AND BEA.BEA_ANOAUT = "+cSubstrSql+"(B4A.B4A_GUIREF, 5, 4) " + cLineBreak
	cQuery += "   AND BEA.BEA_MESAUT = "+cSubstrSql+"(B4A.B4A_GUIREF, 9, 2) " + cLineBreak
	cQuery += "   AND BEA.BEA_NUMAUT = "+cSubstrSql+"(B4A.B4A_GUIREF, 11, 8) " + cLineBreak

	cQuery += " WHERE B4A.B4A_FILIAL = '"+xFilial("B4A")+"' " + cLineBreak
	cQuery += Self:WhereMatriculas("B4A", aMatriculas)
	cQuery += "   AND (B4A.B4A_DATPRO >= '"+cDataInicial+"' AND B4A.B4A_DATPRO <= '"+cDataFinal+"'  )" + cLineBreak
	cQuery += "   AND B4A.D_E_L_E_T_ = ' ' " + cLineBreak
	cQuery += "   AND BEA.D_E_L_E_T_ = ' ' " + cLineBreak

	cQuery += " ORDER BY DATASOLICITACAO DESC"

Return cQuery 


//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiaAutorizacoes
Retorna o Map da lista de Autorizacoes do Beneficiário.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/01/2022
/*/
//------------------------------------------------------------------- 
Method getGuiaAutorizacoes() Class PMobGuiMod
Return (Self:oGuiaAutorizacoesMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} guiaDetalhe
Retorna os detalhes (itens) de uma guia de autorização.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/01/2022
/*/
//------------------------------------------------------------------- 
Method guiaDetalhe() Class PMobGuiMod

	Local cQuery := ""
	Local cAliasTemp := ""
	Local nAddItem := 0

	// Dados recebidos do Json
	Self:cChaveAutorizacao := Self:oParametersMap["chaveAutorizacao"]

	cQuery := Self:QueryDetalhe()
	cAliasTemp := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTemp, .T., .F.)
	
	If (cAliasTemp)->(Eof())
		Self:Message := STR0002 // "Não existem itens a serem visualizados"

		(cAliasTemp)->(DbCloseArea())
		Return .F.
	Endif

	While !(cAliasTemp)->(Eof())

		aAdd(Self:oDetalheAutorizacaoMap["itens"], JsonObject():New())
		nAddItem := Len(Self:oDetalheAutorizacaoMap["itens"])

		Self:oDetalheAutorizacaoMap["itens"][nAddItem]["itemId"] := _Super:SetAtributo((cAliasTemp)->CHAVEITEM, "String")
		Self:oDetalheAutorizacaoMap["itens"][nAddItem]["procedimento"] := _Super:SetAtributo((cAliasTemp)->PROCEDIMENTO, "String")
		Self:oDetalheAutorizacaoMap["itens"][nAddItem]["procedimentoDescricao"] := _Super:SetAtributo((cAliasTemp)->DESCRICAO, "String")
		Self:oDetalheAutorizacaoMap["itens"][nAddItem]["statusId"] := _Super:SetAtributo(IIf((cAliasTemp)->STATUS == "0", "3", (cAliasTemp)->STATUS), "Integer")
		Self:oDetalheAutorizacaoMap["itens"][nAddItem]["quantidadeSolicitada"] := _Super:SetAtributo((cAliasTemp)->QTDSOLICITADA, "Float")
		Self:oDetalheAutorizacaoMap["itens"][nAddItem]["quantidadeAutorizada"] := _Super:SetAtributo((cAliasTemp)->QTDAUTORIZADA, "Float")
		Self:oDetalheAutorizacaoMap["itens"][nAddItem]["dataAutorizacao"] := _Super:SetAtributo((cAliasTemp)->DATAAUTORIZACAO, "Date")

		(cAliasTemp)->(DbSkip())
	EndDo

	(cAliasTemp)->(DbCloseArea())

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryDetalhe
Monta Query para ser utilizado no método guiaDetalhe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 28/01/2022
/*/
//------------------------------------------------------------------- 
Method QueryDetalhe() Class PMobGuiMod

	Local cQuery := ""
	Local cBancoDados := AllTrim(TCGetDB())
	Local cOperadorSql := ""
	Local aChaveAutorizacao := {}
	Local cTabela := ""
	Local cGuiaAutorizacao := ""

	cOperadorSql := IIf(cBancoDados $ "ORACLE|DB2|POSTGRES", "||", "+")

	aChaveAutorizacao := StrTokArr(Self:cChaveAutorizacao, "|")

	If Len(aChaveAutorizacao) >= 2
		cTabela := aChaveAutorizacao[1]
		cGuiaAutorizacao := aChaveAutorizacao[2]

		Do Case
			Case cTabela == "BEA" // Guias SADT/Consulta/Odontologica
				
				cQuery := " SELECT BE2.BE2_OPEMOV "+cOperadorSql+" BE2.BE2_ANOAUT "+cOperadorSql+" BE2.BE2_MESAUT "+cOperadorSql+" BE2.BE2_NUMAUT "+cOperadorSql+" BE2.BE2_SEQUEN AS CHAVEITEM," + cLineBreak
				cQuery += " 	   BE2.BE2_CODPRO AS PROCEDIMENTO," + cLineBreak
				cQuery += " 	   BE2.BE2_DESPRO AS DESCRICAO," + cLineBreak
				cQuery += "		   (CASE BE2.BE2_AUDITO WHEN '1' THEN '2' ELSE BE2.BE2_STATUS END) AS STATUS," + cLineBreak
				cQuery += "		   BE2.BE2_QTDSOL AS QTDSOLICITADA," + cLineBreak
				cQuery += "		   BE2.BE2_QTDPRO AS QTDAUTORIZADA," + cLineBreak
				cQuery += "		   BE2.BE2_DATPRO AS DATAAUTORIZACAO " + cLineBreak

				cQuery += " FROM "+RetSQLName("BE2")+" BE2 " + cLineBreak
				cQuery += " WHERE BE2.BE2_FILIAL = '"+xFilial("BE2")+"' " + cLineBreak
				cQuery += Self:WhereChaveGuia("BE2", cGuiaAutorizacao)
				cQuery += "   AND BE2.D_E_L_E_T_ = ' ' "
			
			Case cTabela == "BE4" // Guias Internação

				cQuery := " SELECT BEJ.BEJ_CODOPE "+cOperadorSql+" BEJ.BEJ_ANOINT "+cOperadorSql+" BEJ.BEJ_MESINT "+cOperadorSql+" BEJ.BEJ_NUMINT "+cOperadorSql+" BEJ.BEJ_SEQUEN AS CHAVEITEM," + cLineBreak
				cQuery += " 	   BEJ.BEJ_CODPRO AS PROCEDIMENTO," + cLineBreak
				cQuery += " 	   BEJ.BEJ_DESPRO AS DESCRICAO," + cLineBreak
				cQuery += "		   (CASE BEJ.BEJ_AUDITO WHEN '1' THEN '2' ELSE BEJ.BEJ_STATUS END) AS STATUS," + cLineBreak
				cQuery += "		   BEJ.BEJ_QTDSOL AS QTDSOLICITADA," + cLineBreak
				cQuery += "		   BEJ.BEJ_QTDPRO AS QTDAUTORIZADA," + cLineBreak
				cQuery += "		   BEJ.BEJ_DATPRO AS DATAAUTORIZACAO " + cLineBreak

				cQuery += " FROM "+RetSQLName("BEJ")+" BEJ " + cLineBreak
				cQuery += " WHERE BEJ.BEJ_FILIAL = '"+xFilial("BEJ")+"' " + cLineBreak
				cQuery += Self:WhereChaveGuia("BEJ", cGuiaAutorizacao)
				cQuery += "   AND BEJ.D_E_L_E_T_ = ' ' "
			
			Case cTabela == "B4Q" // Guias Prorrogação de Internação
				
				cQuery := " SELECT BQV.BQV_CODOPE "+cOperadorSql+" BQV.BQV_ANOINT "+cOperadorSql+" BQV.BQV_MESINT "+cOperadorSql+" BQV.BQV_NUMINT "+cOperadorSql+" BQV.BQV_SEQUEN AS CHAVEITEM," + cLineBreak
				cQuery += " 	   BQV.BQV_CODPRO AS PROCEDIMENTO," + cLineBreak
				cQuery += " 	   BQV.BQV_DESPRO AS DESCRICAO," + cLineBreak
				cQuery += "		   (CASE BQV.BQV_AUDITO WHEN '1' THEN '2' ELSE BQV.BQV_STATUS END) AS STATUS," + cLineBreak
				cQuery += "		   BQV.BQV_QTDSOL AS QTDSOLICITADA," + cLineBreak
				cQuery += "		   BQV.BQV_QTDPRO AS QTDAUTORIZADA," + cLineBreak
				cQuery += "		   BQV.BQV_DATPRO AS DATAAUTORIZACAO " + cLineBreak

				cQuery += " FROM "+RetSQLName("BQV")+" BQV " + cLineBreak
				cQuery += " WHERE BQV.BQV_FILIAL = '"+xFilial("BQV")+"' " + cLineBreak
				cQuery += Self:WhereChaveGuia("BQV", cGuiaAutorizacao)
				cQuery += "   AND BQV.D_E_L_E_T_ = ' ' "

			Case cTabela == "B4A" // Guias Anexo Clinico

				cQuery := " SELECT B4C.B4C_OPEMOV "+cOperadorSql+" B4C.B4C_ANOAUT "+cOperadorSql+" B4C.B4C_MESAUT "+cOperadorSql+" B4C.B4C_NUMAUT "+cOperadorSql+" B4C.B4C_SEQUEN AS CHAVEITEM," + cLineBreak
				cQuery += " 	   B4C.B4C_CODPRO AS PROCEDIMENTO," + cLineBreak
				cQuery += " 	   B4C.B4C_DESPRO AS DESCRICAO," + cLineBreak
				cQuery += "		   (CASE B4C.B4C_AUDITO WHEN '1' THEN '2' ELSE B4C.B4C_STATUS END) AS STATUS," + cLineBreak
				cQuery += "		   B4C.B4C_QTDSOL AS QTDSOLICITADA," + cLineBreak
				cQuery += "		   B4C.B4C_QTDPRO AS QTDAUTORIZADA," + cLineBreak
				cQuery += "		   B4C.B4C_DATPRO AS DATAAUTORIZACAO " + cLineBreak

				cQuery += " FROM "+RetSQLName("B4C")+" B4C " + cLineBreak
				cQuery += " WHERE B4C.B4C_FILIAL = '"+xFilial("B4C")+"' " + cLineBreak
				cQuery += Self:WhereChaveGuia("B4C", cGuiaAutorizacao)
				cQuery += "   AND B4C.D_E_L_E_T_ = ' ' "		
		EndCase
	EndIf

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiaDetalhe
Retorna o Map da lista de Itens da Autorização

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 28/01/2022
/*/
//------------------------------------------------------------------- 
Method getGuiaDetalhe() Class PMobGuiMod
Return (Self:oDetalheAutorizacaoMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} guiaPdf
Este método irá retornar uma URL ou uma string BASE64 do arquivo PDF 
da guia completa

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/02/2022
/*/
//------------------------------------------------------------------- 
Method guiaPdf() Class PMobGuiMod

	Local lRetorno := .F.

	// Dados recebidos do Json
	Self:cChaveAutorizacao := Self:oParametersMap["chaveAutorizacao"]

	If Self:GeraPdf()
		Self:oGuiaPdfMap["binario"] := Self:cBinaryFile
		Self:oGuiaPdfMap["url"] := Self:cURLFile

		lRetorno := .T.
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraPdf
Realiza a geração do arquivo PDF da guia

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/02/2022
/*/
//------------------------------------------------------------------- 
Method GeraPdf() Class PMobGuiMod

	Local lRetorno := .F.
	Local cPathRelWeb := PLSMUDSIS(getWebDir()+getSkinPls()+"\relatorios\")	
	Local cNameArquivo := ""
	Local cTabela := ""
	Local cGuia := ""
	Local lUrlPDF := Self:oConfig["financeiro"]["pdfMode"] == "1"
	Local lBase64PDF := Self:oConfig["financeiro"]["pdfMode"] == "2"
	Local cEnderecoPDF := Self:oConfig['security']['pdfUrl']
	Local aChaveAutorizacao := {}

	aChaveAutorizacao := StrTokArr(Self:cChaveAutorizacao, "|")

	If Len(aChaveAutorizacao) >= 2

		cTabela := aChaveAutorizacao[1]
		cGuia := aChaveAutorizacao[2]

		Do Case
			Case cTabela == "BEA" // Guias SADT/Consulta/Odontologica
				cNameArquivo := Self:PdfGuiaSADT(cGuia, cPathRelWeb)
			
			Case cTabela == "BE4" // Guias Internação
				cNameArquivo := Self:PdfGuiaInternacao(cGuia, cPathRelWeb)
			
			Case cTabela == "B4Q" // Guias Prorrogação de Internação
				cNameArquivo := Self:PdfGuiaProrrogacao(cGuia, cPathRelWeb)
				
			Case cTabela == "B4A" // Guias Anexo Clinico
				cNameArquivo := Self:PdfGuiaAnexo(cGuia, cPathRelWeb)		
		EndCase

		If Empty(Self:message)

			// Validar geração do arquivo
			Self:message := IIf(Empty(cNameArquivo), STR0003, Self:message) // "Não foi possível gerar o PDF da Guia"
			Self:message := IIf(!File(cPathRelWeb+cNameArquivo) .And. Empty(Self:message), STR0004, Self:message) // "Não foi possível localizar o PDF da Guia"

			If Empty(Self:message)
				Self:cURLFile := IIf(lUrlPDF, Lower(cEnderecoPDF+cNameArquivo), "")
				Self:cBinaryFile := IIf(lBase64PDF, PMobFile64(cPathRelWeb+cNameArquivo), "")
				lRetorno := .T.
			EndIf
		EndIf
	Else
		Self:message := STR0005 // "Chave da autorização invalida"	
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} PdfGuiaSADT
Gera o arquivo PDF da Guias de SADT/Consulta/Odontologica

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/02/2022
/*/
//------------------------------------------------------------------- 
Method PdfGuiaSADT(cGuia, cPathRelWeb) Class PMobGuiMod

	Local cNameArquivo := ""
	Local aDadosGuia := {}
	Local cVersaoTISS := PLSTISSVER()
	Local lImpLibSaldo := GetNewPar("MV_PLIMSAE", "0") == "0"
	Local lImpNoAutoriza := GetNewPar("MV_IGUINE", .F.)

	BEA->(DbSetOrder(1))
	If BEA->(MsSeek(xFilial("BEA")+cGuia))

		// Validações para Imprimir
		Self:message := IIf(BEA->BEA_CANCEL == "1", STR0006, Self:message) // "Guia cancelada"
		Self:message := IIf(BEA->BEA_STATUS == "3" .And. !lImpNoAutoriza, STR0007, Self:message) // "Guia não autorizada"
		Self:message := IIf(BEA->BEA_STATUS == "6" .And. !lImpNoAutoriza, STR0008, Self:message) // "Guia em analise"
		Self:message := IIf(BEA->BEA_LIBERA == "1" .And. !PLSSALDO("",BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)) .And. lImpLibSaldo, STR0009, Self:message) // "Esta guia de solicitação ja foi executada ou não possui saldo, proceda com a impressão da guia de execução"
		
		If Empty(Self:message)
			Do Case 
				Case BEA->BEA_TIPO == "1" // Guia Consulta
					aAdd(aDadosGuia, PLSGSADT(BEA->BEA_TIPO))

					If ExistBlock("PLR430CONS")
						aDadosGuia := ExecBlock("PLR430CONS", .F., .F., {aDadosGuia})
					EndIf
						
					cNameArquivo := IIf(cVersaoTISS >=  "3", PlsTISSD(aDadosGuia, .F., 2, "", .T., cPathRelWeb), PlsTISS1(aDadosGuia, .F., 2, "", .T., cPathRelWeb))

				Case BEA->BEA_TIPO == "2" // Guia SADT	
					aAdd(aDadosGuia, PLSGSADT(BEA->BEA_TIPO))

					If ExistBlock("PLR430SADT")
						aDadosGuia := ExecBlock("PLR430SADT", .F., .F., {aDadosGuia})
					EndIf

					cNameArquivo := IIf(cVersaoTISS >= "3", PlsTISSC(aDadosGuia, .F., 2, "", .T., cPathRelWeb), PlsTISS2(aDadosGuia, .F., 2, "", .T., cPathRelWeb))
					
				Case BEA->BEA_TIPO == "4" // Guia Odontologica
					aAdd(aDadosGuia, PLSGODCO())
					
					cNameArquivo := PLSTISS9(aDadosGuia, 2, "", .F., .T., cPathRelWeb)
			EndCase
		EndIf
	EndIf

Return cNameArquivo


//-------------------------------------------------------------------
/*/{Protheus.doc} PdfGuiaInternacao
Gera o arquivo PDF da Guias de Internação

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/02/2022
/*/
//------------------------------------------------------------------- 
Method PdfGuiaInternacao(cGuia, cPathRelWeb) Class PMobGuiMod

	Local cNameArquivo := ""
	Local cVersaoTISS := PLSTISSVER()
	Local aDadosGuia := {}
	Local lImpNoAutoriza := GetNewPar("MV_IGUINE", .F.)

	BE4->(DbSetOrder(2))
	If BE4->(MsSeek(xFilial("BE4")+cGuia))

		// Validações para Imprimir
		Self:message := IIf(BE4->BE4_CANCEL == "1", STR0006, Self:message) // "Guia cancelada"
		Self:message := IIf(BE4->BE4_STATUS == "3" .And. !lImpNoAutoriza, STR0007, Self:message) // "Guia não autorizada"
		Self:message := IIf(BE4->BE4_STATUS == "6" .And. !lImpNoAutoriza, STR0008, Self:message) // "Guia em analise"
		
		If Empty(Self:message)
			aAdd(aDadosGuia, PLSGINT(1))

			If ExistBlock("PLR430INT")
				aDadosGuia := ExecBlock("PLR430INT", .F., .F., {aDadosGuia})
			EndIf

			cNameArquivo := IIf(cVersaoTISS >= "3", PlsTISSE(aDadosGuia, .F., 2, "", .F., .T., cPathRelWeb)[3], PlsTISS3(aDadosGuia, .F., 2, "", .F., .T., cPathRelWeb)[3])
		Endif
	EndIf

Return cNameArquivo


//-------------------------------------------------------------------
/*/{Protheus.doc} PdfGuiaProrrogacao
Gera o arquivo PDF da Guias de Prorrogação de Internação

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/02/2022
/*/
//------------------------------------------------------------------- 
Method PdfGuiaProrrogacao(cGuia, cPathRelWeb) Class PMobGuiMod

	Local cNameArquivo := ""
	Local aDadosGuia := {}	
	Local lImpNoAutoriza := GetNewPar("MV_IGUINE", .F.)

	B4Q->(DbSetOrder(1))
	If B4Q->(MsSeek(xFilial("B4Q")+cGuia))

		// Validações para Imprimir
		Self:message := IIf(B4Q->B4Q_CANCEL == "1", STR0006, Self:message) // "Guia cancelada"
		Self:message := IIf(B4Q->B4Q_STATUS == "3" .And. !lImpNoAutoriza, STR0007, Self:message) // "Guia não autorizada"
		Self:message := IIf(B4Q->B4Q_STATUS == "6" .And. !lImpNoAutoriza, STR0008, Self:message) // "Guia em analise"

		If Empty(Self:message)
			aAdd(aDadosGuia, PLSGINT(3))
			cNameArquivo := PLSTISSP(aDadosGuia, .F., 2, "", .F., .T., cPathRelWeb)[3]
		EndIf
	EndIf

Return cNameArquivo


//-------------------------------------------------------------------
/*/{Protheus.doc} PdfGuiaAnexo
Gera o arquivo PDF da Guias de Anexo Clinico

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/02/2022
/*/
//------------------------------------------------------------------- 
Method PdfGuiaAnexo(cGuia, cPathRelWeb) Class PMobGuiMod

	Local aArquivo := {}
	Local cNameArquivo := ""

	B4A->(DbSetOrder(1))
	If B4A->(MsSeek(xFilial("B4A")+cGuia))
		
		aArquivo := PLS09AIma(.T., cPathRelWeb)

		If aArquivo[1]
			cNameArquivo := aArquivo[3]
		EndIf

		Self:message := IIf(aArquivo[1], Self:message, aArquivo[2])

	Endif

Return cNameArquivo


//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiaPdf
Retorna o Map do PDF da Autorização

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/02/2022
/*/
//------------------------------------------------------------------- 
Method getGuiaPdf() Class PMobGuiMod
Return (Self:oGuiaPdfMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} guiaStatus
Retorna a tabela de domínio dos status da autorização

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/02/2022
/*/
//------------------------------------------------------------------- 
Method guiaStatus() Class PMobGuiMod

	Local aStatus := {}
	Local nX := 0
	Local nAddItem := 0
	Local lRetorno := .F.

	aStatus := Self:GetStatus()

	Self:Message := IIf(Len(aStatus) == 0, STR0010, "") // "Não existem status a serem visualizados"

	If Empty(Self:Message)
		For nX := 1 To Len(aStatus)

			aAdd(Self:oStatusAutorizacaoMap["autorizacaoStatus"], JsonObject():New())
			nAddItem := Len(Self:oStatusAutorizacaoMap["autorizacaoStatus"])

			Self:oStatusAutorizacaoMap["autorizacaoStatus"][nAddItem]["chaveStatus"] := _Super:SetAtributo(aStatus[nX][1], "String")
			Self:oStatusAutorizacaoMap["autorizacaoStatus"][nAddItem]["descricao"] := _Super:SetAtributo(aStatus[nX][2], "String")

		Next nX

		lRetorno := .T.
	EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Retorna o status das guias do atendimento de acordo com o conteudo
preenchido no X3_CBOX dos campos XXX_STATUS

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/02/2022
/*/
//------------------------------------------------------------------- 
Method GetStatus() Class PMobGuiMod

	Local cStatus := ""
	Local cChaveStatus := ""
	Local cDescricao := ""
	Local nX := 0
	Local aRetorno := {}
	
	Local aBoxStatus := {}
	Local aItemStatus := {}

	cStatus := PLSGUTISS()

	aBoxStatus := StrTokArr(cStatus, ";")

	For nX := 1 To Len(aBoxStatus)

		aItemStatus := StrTokArr(aBoxStatus[nX], "=")

		If Len(aItemStatus) >= 2

			cChaveStatus := aItemStatus[1]
			cDescricao := aItemStatus[2]

			aAdd(aRetorno, {Alltrim(cChaveStatus), Alltrim(cDescricao)})

		EndIf

	Next nX

Return aRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiaStatus
Retorna o Map da lista de status da Autorização

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/02/2022
/*/
//------------------------------------------------------------------- 
Method getGuiaStatus() Class PMobGuiMod
Return (Self:oStatusAutorizacaoMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} QueryWhereMatric
Monta condição na query para buscar as Guias pelas Matriculas Informadas

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/01/2022
/*/
//------------------------------------------------------------------- 
Method WhereMatriculas(cTabela, aMatriculas) Class PMobGuiMod

	Local nX := 0
	Local cWhere := ""

	Default cTabela := ""
	Default aMatriculas := {}

	For nX := 1 To Len(aMatriculas)

			If nX == 1
				cWhere += " AND ( " + cLineBreak
			EndIf 
	
			cWhere += " ( " + cLineBreak
			cWhere += cTabela+"."+cTabela+"_OPEUSR = '"+aMatriculas[nX][1]+"' AND " + cLineBreak
			cWhere += cTabela+"."+cTabela+"_CODEMP = '"+aMatriculas[nX][2]+"' AND " + cLineBreak
			cWhere += cTabela+"."+cTabela+"_MATRIC = '"+aMatriculas[nX][3]+"' " + cLineBreak

			If !Empty(aMatriculas[nX][4])
				cWhere += " AND "+cTabela+"."+cTabela+"_TIPREG = '"+aMatriculas[nX][4]+"' " + cLineBreak
				cWhere += " AND "+cTabela+"."+cTabela+"_DIGITO = '"+aMatriculas[nX][5]+"' " + cLineBreak
			EndIf

			cWhere += " ) " + cLineBreak

			cWhere += IIf(nX == Len(aMatriculas), " ) ", " OR ") + cLineBreak
	
	Next nX

Return cWhere


//-------------------------------------------------------------------
/*/{Protheus.doc} WhereChaveGuia
Monta condição na query para buscar as Guias pela chave informada

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 28/01/2022
/*/
//------------------------------------------------------------------- 
Method WhereChaveGuia(cTabela, cChaveAutorizacao) Class PMobGuiMod

	Local cWhere := ""
	Local cCampoOperadora := ""
	Local cCampoAno := ""
	Local cCampoMes := ""
	Local cCampoNumero := ""
	Local oGuiaAutorizacao := JsonObject():New()

	cCampoOperadora := IIf(cTabela $ "BQV/BEJ", "_CODOPE", "_OPEMOV")
	cCampoAno := IIf(cTabela $ "BQV/BEJ", "_ANOINT", "_ANOAUT")
	cCampoMes := IIf(cTabela $ "BQV/BEJ", "_MESINT", "_MESAUT")
	cCampoNumero := IIf(cTabela $ "BQV/BEJ", "_NUMINT", "_NUMAUT") 

	oGuiaAutorizacao := _Super:BreakAutorizacao(cChaveAutorizacao)

	cWhere := " AND "+cTabela+"."+cTabela+cCampoOperadora+" = '"+oGuiaAutorizacao["operadora"]+"' " + cLineBreak
	cWhere += " AND "+cTabela+"."+cTabela+cCampoAno+" = '"+oGuiaAutorizacao["ano"]+"' " + cLineBreak
	cWhere += " AND "+cTabela+"."+cTabela+cCampoMes+" = '"+oGuiaAutorizacao["mes"]+"' " + cLineBreak
	cWhere += " AND "+cTabela+"."+cTabela+cCampoNumero+" = '"+oGuiaAutorizacao["numero"]+"' " + cLineBreak

Return cWhere


//-----------------------------------------------------------------
/*/{Protheus.doc} GetNomeEspecialidade
Retorna o nome da Especialidade da Guia

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 26/01/2022
/*/
//-----------------------------------------------------------------
Method GetNomeEspecialidade(cCodEspecialidade) Class PMobGuiMod

	Local cNomeEspecialidade := ""
	Local cOperadora := PlsIntPad()

	cNomeEspecialidade := Posicione("BAQ", 1, xFilial("BAQ")+cOperadora+cCodEspecialidade, "BAQ_DESCRI")                                   

Return cNomeEspecialidade


//-----------------------------------------------------------------
/*/{Protheus.doc} GetNomeTratamento
Retorna o nome do tratamento de acordo com o tipo informado

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 26/01/2022
/*/
//-----------------------------------------------------------------
Method GetNomeTratamento(cTipoTratamento) Class PMobGuiMod

	Local cNomeTratamento := STR0011 // "OUTRO TRATAMENTO"

	Do Case
		Case cTipoTratamento == "01"
			cNomeTratamento := STR0012 // "CONSULTA"

		Case cTipoTratamento == "02"
			cNomeTratamento := STR0013 // "SP/SADT"

		Case cTipoTratamento == "03"
			cNomeTratamento := STR0014 // "INTERNACAO"

		Case cTipoTratamento == "07"
			cNomeTratamento := STR0015 // "QUIMIOTERAPIA"

		Case cTipoTratamento == "08"
			cNomeTratamento := STR0016 // "RADIOTERAPIA"

		Case cTipoTratamento == "09"
			cNomeTratamento := STR0017 // "OPME"

		Case cTipoTratamento == "11"
			cNomeTratamento := STR0018 // "PRORROGACAO DE INTERNACAO"
		
		Case cTipoTratamento == "13"
			cNomeTratamento := STR0019 // "ODONTOLOGIA"
	EndCase

Return cNomeTratamento


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMessage
Retorna mensagens de erro dos métodos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/01/2022
/*/
//------------------------------------------------------------------- 
Method GetMessage() Class PMobGuiMod
Return (Self:Message)