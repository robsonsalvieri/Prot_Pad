#INCLUDE 'TOTVS.ch'
#INCLUDE "FILEIO.CH"

//Geração de Log (MV_LOGCRP)
#DEFINE CABECALHO_ARQUIVO "Data Hora;Milisegundo;Thread;Etapa;Identificador;Mensagem"
#DEFINE QUEBRA_LINHA CHR(13) + CHR(10)

//Estáticas para controle por fora do MRP
Static _lLogMrp := Nil
Static _oLogs   := Nil

/*/{Protheus.doc} MrpDados_Logs
Classe responsável pela gravação dos logs do MRP
@author marcelo.neumann
@since 14/08/2024
@version P12
/*/
CLASS MrpDados_Logs FROM LongNameClass
	DATA aBkpProd  AS ARRAY
	DATA cFileName AS STRING
	DATA cUIDLogs  AS STRING
	DATA lLogAtivo AS LOGICAL
	DATA lErroArq  AS LOGICAL
	DATA oArquivo  AS OBJECT
	DATA oDescTipo AS OBJECT

	//Declaracao de metodos publicos
	Method new(cFilAux) CONSTRUCTOR
	Method destroy()

	Method iniciaGravacaoLogs(cTicket, cLogMrp)
	Method gravaLog(cEtapa, cIdentif, aMensagem, lWrite, lWriteAll, lPrefixo)
	Method logAtivado()
	Method finalizaGravacaoLogs()

	//Métodos Auxiliares
	Method descricaoTipoDocPai(cTipoDoc)
	Method descricaoTipoFatorConversao(cTipo)
	Method erroNaGravacao()
	Method gravaBackupProduto(cChave)
	Method gravaIgnorados()
	Method gravaPontosDeEntrada()
	Method limpaGlobal()
	Method montaChaveLog(cFilAux, cProduto, cIdOpc, nPeriodo)
	Method restauraBackupProduto(cChave)

	Static Method gravaLogMrp(cEtapa, cIdentif, aMensagem)
	Static Method finalizaLogs(cEtapa, cMensagem)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author marcelo.neumann
@since 14/08/2024
@version P12
@param cFilAux, Caracter, Filial corrente
@return Self, objeto, referência da classe MrpDados_Logs instanciada
/*/
Method new(cFilAux) CLASS MrpDados_Logs
	Default cFilAux := cFilAnt

	cFilAux        := RTrim(cFilAux)
	Self:cUIDLogs  := "UID_LOGMRP_" + cFilAux
	Self:cFileName := GetSrvProfString("STARTPATH","") + "logMRP_" + cFilAux + ".csv"
	Self:aBkpProd  := {}
	Self:lLogAtivo := Nil
	Self:lErroArq  := .F.

	Self:oDescTipo := JsonObject():New()
	Self:oDescTipo["0"]          := "Consolidado"
	Self:oDescTipo["1"]          := "Plano Mestre"
	Self:oDescTipo["2"]          := "Previsao de Vendas"
	Self:oDescTipo["3"]          := "Pedido de Venda"
	Self:oDescTipo["4"]          := "Empenhos de Projeto"
	Self:oDescTipo["5"]          := "Importacao CSV"
	Self:oDescTipo["9"]          := "Manual"
	Self:oDescTipo["AGL"]        := "Necessidade aglutinada"
	Self:oDescTipo["ESTNEG"]     := "Estoque inicial negativo"
	Self:oDescTipo["Est.Seg."]   := "Estoque de Seguranca"
	Self:oDescTipo["LTVENC"]     := "Lote vencido"
	Self:oDescTipo["OP"]         := "Ordem de Producao"
	Self:oDescTipo["Ponto Ped."] := "Ponto de Pedido"
	Self:oDescTipo["Pré-OP"]     := "Empenho Pre-Existente"
	Self:oDescTipo["SUBPRD"]     := "Subproduto de OP"
	Self:oDescTipo["TRANF_ES"]   := "Transferencia de estoque"
	Self:oDescTipo["TRANF_PR"]   := "Transferencia de producao"

Return Self

/*/{Protheus.doc} destroy
Metodo destrutor da classe
@author marcelo.neumann
@since 14/08/2024
@version P12
@return Nil
/*/
Method destroy() CLASS MrpDados_Logs

	Self:limpaGlobal()
	FwFreeArray(Self:aBkpProd)

	Self:lLogAtivo := Nil
	Self:lErroArq  := Nil

	FreeObj(Self:oDescTipo)

Return Nil

/*/{Protheus.doc} limpaGlobal
Limpa a variável global (proteção para não usar lixo de outra execução)
@author marcelo.neumann
@since 17/09/2024
@version P12
@return Nil
/*/
Method limpaGlobal() Class MrpDados_Logs

	If VarIsUID(Self:cUIDLogs)
		VarClean(Self:cUIDLogs)
	EndIf

Return

/*/{Protheus.doc} iniciaGravacaoLogs
Cria o arquivo para gravação de logs (em disco) e grava o cabeçalho e início do ticket

@author marcelo.neumann
@since 15/08/2024
@version P12
@param 01 cTicket, Caracter, Número do ticket que está sendo executado
@param 02 cLogMrp, Caracter, Parâmetro MV_LOGMRP indicando se deve gerar ou não o log
@return Nil
/*/
Method iniciaGravacaoLogs(cTicket, cLogMrp) Class MrpDados_Logs
	Local lGravaLog := cLogMrp == "1"
	Local lSucesso  := .T.

	//Global exclusiva do MrpDados_Logs (independente do MRP)
	Self:limpaGlobal()
	If VarSetUID(Self:cUIDLogs, .T.)
		VarSetXD(Self:cUIDLogs, "lGravaLog", lGravaLog)
	EndIf

	If Self:logAtivado()
		Self:oArquivo := FWFileWriter():New(Self:cFileName, .F.)

		If Self:oArquivo:exists()
			lSucesso := Self:oArquivo:clear(.T.)
		Else
			lSucesso := Self:oArquivo:create()
		EndIf

		If lSucesso
			Self:oArquivo:write(CABECALHO_ARQUIVO)
			Self:oArquivo:write(getPrefixo() + "Inicio do ticket " + cTicket)
			Self:gravaPontosDeEntrada()
		Else
			LogMsg("PCPA712", 0, 0, 1, "", "", "Nao foi possivel criar o arquivo " + Self:cFileName + IIf(Empty(Self:oArquivo:error():Message), "", ". Erro: "+ AllTrim(Self:oArquivo:error():Message)))
			VarSetXD(Self:cUIDLogs, "lGravaLog", .F.)
			VarSetXD(Self:cUIDLogs, "lErroArq" , .T.)
		EndIf

		Self:oArquivo:close()
	EndIf
Return

/*/{Protheus.doc} gravaLog
Grava uma mensagem no arquivo de log (em disco)

@author marcelo.neumann
@since 05/03/2024
@version P12
@param 01 cEtapa   , Caracter, Etapa que gerou o log
@param 02 cIdentif , Caracter, Identificador do log (codigo da tabela, chave do produto, etc)
@param 03 aMensagem, Array   , Mensagens de log a serem gravadas no arquivo
@param 04 lWrite   , Lógico  , Indica se deve gravar no arquivo ou armazenar em global para gravar posteriormente
@param 05 lWriteAll, Lógico  , Indica se deve imprimir todo o bloco de mensagens (armazenados na chave cIdentif)
@param 06 lPrefixo , Lógico  , Indica se deve preencher o prefixo na mensagem (getPrefixo)
@return Nil
/*/
Method gravaLog(cEtapa, cIdentif, aMensagem, lWrite, lWriteAll, lPrefixo) Class MrpDados_Logs
	Local aMsgSalva   := {}
	Local cPrefixo    := ""
	Local lMsgSalva   := .F.
	Local lGravou     := .T.
	Local nIndex      := 1
	Local nQtdMsg     := 0
	Default aMensagem := {}
	Default lWrite    := .T.
	Default lWriteAll := .F.
	Default lPrefixo  := .T.

	If !Self:logAtivado()
		Return
	EndIf

	If lPrefixo
		cPrefixo := getPrefixo(cEtapa, cIdentif)
	EndIf

	If lWrite
		If Self:oArquivo == Nil
			Self:oArquivo := FWFileWriter():New(Self:cFileName, .F.)
		EndIf

		//Controle de lock para duas threads não tentarem abrir o arquivo ao mesmo tempo
		VarBeginT(Self:cUIDLogs, "PCPA712Log")

		lGravou := Self:oArquivo:open(FO_WRITE)

		If lGravou
			Self:oArquivo:goBottom()

			If lWriteAll .And. VarGetA(Self:cUIDLogs, cIdentif, @aMsgSalva)
				nQtdMsg   := Len(aMsgSalva)
				lMsgSalva := nQtdMsg > 0
				VarDelA(Self:cUIDLogs, cIdentif)
			EndIf

			If lMsgSalva
				lGravou := Self:oArquivo:write(cPrefixo + "------------------------------------------------------------------------------------------------------------------------------------------")
				nIndex  := 1
				While lGravou .And. nIndex <= nQtdMsg
					lGravou := Self:oArquivo:write(aMsgSalva[nIndex])
					nIndex++
				End
			EndIf

			nIndex  := 1
			nQtdMsg := Len(aMensagem)
			While lGravou .And. nIndex <= nQtdMsg
				lGravou := Self:oArquivo:write(cPrefixo + aMensagem[nIndex])
				nIndex++
			End

			If lGravou .And. lMsgSalva
				lGravou := Self:oArquivo:write(cPrefixo + "------------------------------------------------------------------------------------------------------------------------------------------")
			EndIf
		EndIf

		If !lGravou
			LogMsg("PCPA152", 0, 0, 1, "", "", "Nao foi possivel abrir o arquivo " + Self:cFileName + IIf(Empty(Self:oArquivo:error():Message), "", ". Erro: " + AllTrim(Self:oArquivo:error():Message)))
			VarSetXD(Self:cUIDLogs, "lErroArq", .T.)
		EndIf

		Self:oArquivo:close()
		VarEndT(Self:cUIDLogs, "PCPA712Log")
	Else
		nQtdMsg := Len(aMensagem)
		For nIndex := 1 To nQtdMsg
			VarSetA(Self:cUIDLogs, cIdentif, {}, 1, cPrefixo + aMensagem[nIndex])
		Next nIndex
	EndIf

	aSize(aMensagem, 0)
	aSize(aMsgSalva, 0)
Return

/*/{Protheus.doc} montaChaveLog
Monta a chave identificadora do produto (calculo)

@author marcelo.neumann
@since 15/08/2024
@version P12
@param 01 cFilAux , Caracter, Filial do registro
@param 02 cProduto, Caracter, Produto do log
@param 03 cIdOpc  , Caracter, ID Opcional do produto do log
@param 04 nPeriodo, Numérico, Numero do periodo do log
@return Nil
/*/
Method montaChaveLog(cFilAux, cProduto, cIdOpc, nPeriodo) Class MrpDados_Logs
	Default cFilAux  := ""
	Default cProduto := ""
	Default cIdOpc   := ""
	Default nPeriodo := 1

Return RTrim(cFilAux) + "|" + RTrim(cProduto) + "|" + RTrim(cIdOpc) + "|" + cValToChar(nPeriodo)

/*/{Protheus.doc} gravaBackupProduto
Grava um backup dos logs de cálculo de um produto (cChave)

@author marcelo.neumann
@since 15/08/2024
@version P12
@param cChave, Caracter, Chave identificadora do produto
@return Nil
/*/
Method gravaBackupProduto(cChave) Class MrpDados_Logs

	VarGetA(Self:cUIDLogs, cChave, @Self:aBkpProd)

Return Nil

/*/{Protheus.doc} restauraBackupProduto
Restaura o backup de logs de um produto (cChave)

@author marcelo.neumann
@since 15/08/2024
@version P12
@param cChave, Caracter, Chave identificadora do produto
@return Nil
/*/
Method restauraBackupProduto(cChave) Class MrpDados_Logs

	If Self:logAtivado()
		VarSetA(Self:cUIDLogs, cChave, Self:aBkpProd)
	EndIf

Return

/*/{Protheus.doc} getPrefixo
Retorna o prefixo para o log com data, hora, thread, etapa e identificador formatados

@author marcelo.neumann
@since 15/08/2024
@version P12
@param 01 cEtapa  , Caracter, Etapa que gerou o log
@param 02 cIdentif, Caracter, Identificador do log (codigo da tabela, chave do produto, etc)
@return Caracter  , Retorna o prefixo do log
/*/
Static Function getPrefixo(cEtapa, cIdentif)
	Default cEtapa   := ""
	Default cIdentif := ""

Return QUEBRA_LINHA + DToS(Date()) + " " + TimeFull() + ";" + PadR(cValToChar(Round(MicroSeconds(),5)),17,"0") + "; [Thread " + cValToChar(ThreadID()) + "]; " + cEtapa + "; " + RTrim(cIdentif) + "; "

/*/{Protheus.doc} logAtivado
Indica se está sendo gerado log

@author marcelo.neumann
@since 15/08/2024
@version P12
@return Self:lLogAtivo, Lógico, Indica se o log está ativo ou não
/*/
Method logAtivado() Class MrpDados_Logs

	If Self:lLogAtivo == Nil
		If !VarGetXD(Self:cUIDLogs, "lGravaLog", @Self:lLogAtivo) .Or. Self:lLogAtivo == Nil
			Self:lLogAtivo := .F.
		EndIf
	EndIf

	If Self:lLogAtivo .And. Self:erroNaGravacao()
		Self:lLogAtivo := .F.
	EndIf

Return Self:lLogAtivo

/*/{Protheus.doc} erroNaGravacao
Indica se houve erro na gravação ou na criação do arquivo

@author marcelo.neumann
@since 15/08/2024
@version P12
@return Self:lErroArq, Lógico, Indica se houve erro na gravação/criação do arquivo
/*/
Method erroNaGravacao() Class MrpDados_Logs

	If Self:lErroArq == .F.
		If !VarGetXD(Self:cUIDLogs, "lErroArq", @Self:lErroArq) .Or. Self:lErroArq == Nil
			Self:lErroArq := .F.
		EndIf
	EndIf

Return Self:lErroArq

/*/{Protheus.doc} descricaoTipoDocPai
Retorna a descrição do tipo de documento pai para gravar no log

@author marcelo.neumann
@since 15/08/2024
@version P12
@param  cTipoDoc , Caracter, Tipo do documento pai
@return cDescTipo, Caracter, Descrição do tipo do documento pai
/*/
Method descricaoTipoDocPai(cTipoDoc) Class MrpDados_Logs
	Local cDescTipo := ""

	cTipoDoc  := AllTrim(cTipoDoc)
	cDescTipo := cTipoDoc

	If Self:oDescTipo:hasProperty(cTipoDoc)
		cDescTipo := Self:oDescTipo[cTipoDoc]
	EndIf

Return cDescTipo

/*/{Protheus.doc} descricaoTipoFatorConversao
Retorna a descrição do tipo de fator de conversão para gravar no log

@author marcelo.neumann
@since 15/08/2024
@version P12
@param  cTipo    , Caracter, Tipo do fator de conversão
@return cDescTipo, Caracter, Descrição do tipo do fator de conversão
/*/
Method descricaoTipoFatorConversao(cTipo) Class MrpDados_Logs
	Local cDescTipo := ""

	If AllTrim(cTipo) == "1"
		cDescTipo := "Multiplicacao"
	Else
		cDescTipo := "Divisao"
	EndIf

Return cDescTipo

/*/{Protheus.doc} gravaIgnorados
Grava no arquivo de logs os produtos que foram ignorados durante o processamento

@author marcelo.neumann
@since 15/08/2024
@version P12
@return Nil
/*/
Method gravaIgnorados() Class MrpDados_Logs
	Local aChaves := {}
	Local nIndex  := 1
	Local nTotal  := 0

	If Self:logAtivado() .And. VarGetAA(Self:cUIDLogs, @aChaves) .And. !Empty(aChaves)
		nTotal := Len(aChaves)
		For nIndex := 1 To nTotal
			Self:gravaLog(/*cEtapa*/, /*cIdentif*/, {aChaves[nIndex][2][1]}, .T. /*lWrite*/, .F. /*lWriteAll*/, .F. /*lPrefixo*/)
		Next nIndex
	EndIf

Return

/*/{Protheus.doc} finalizaGravacaoLogs
Finaliza a gravação dos Logs

@author marcelo.neumann
@since 15/08/2024
@version P12
@return Nil
/*/
Method finalizaGravacaoLogs() Class MrpDados_Logs

	If Self:logAtivado()
		Self:gravaLog(/*cEtapa*/, /*cIdentif*/, {"Termino do processamento do MRP (PCPA712)"})
		Self:destroy()
	EndIf

Return

/*/{Protheus.doc} gravaPontosDeEntrada
Grava quais pontos de entrada do MRP estão compilados

@author marcelo.neumann
@since 13/09/2024
@version P12
@return Nil
/*/
Method gravaPontosDeEntrada() Class MrpDados_Logs
	Local cPEs := ""

	cPEs += IIf(ExistBlock("P712EXEC"  ), ", P712EXEC"  , "")
	cPEs += IIf(ExistBlock("P712FIM"   ), ", P712FIM"   , "")
	cPEs += IIf(ExistBlock("P712LDTL"  ), ", P712LDTL"  , "")
	cPEs += IIf(ExistBlock("P712PERI"  ), ", P712PERI"  , "")
	cPEs += IIf(ExistBlock("P712SINI"  ), ", P712SINI"  , "")
	cPEs += IIf(ExistBlock("P712SQL"   ), ", P712SQL"   , "")
	cPEs += IIf(ExistBlock("P712VLD"   ), ", P712VLD"   , "")
	cPEs += IIf(ExistBlock("PA145GER"  ), ", PA145GER"  , "")
	cPEs += IIf(ExistBlock("P145NUMOP" ), ", P145NUMOP" , "")
	cPEs += IIf(ExistBlock("MRPUSARVPA"), ", MRPUSARVPA", "")

	If Empty(cPEs)
		Self:oArquivo:write(getPrefixo("", "pontos_de_entrada") + "Nenhum ponto de entrada compilado")
	Else
		cPEs := AllTrim( Stuff(cPEs, 1, 2, "") )
 		Self:oArquivo:write(getPrefixo("", "pontos_de_entrada") + "Pontos de entrada compilados: " + cPEs)
	EndIf

Return

/*/{Protheus.doc} gravaLogMrp
Grava uma mensagem no arquivo de log (em disco)

@author marcelo.neumann
@since 05/03/2024
@version P12
@param 01 cEtapa   , Caracter, Etapa que gerou o log
@param 02 cIdentif , Caracter, Identificador do log (codigo da tabela, chave do produto, etc)
@param 03 aMensagem, Array   , Mensagens de log a serem gravadas no arquivo
@return Nil
/*/
Method gravaLogMrp(cEtapa, cIdentif, aMensagem) Class MrpDados_Logs
	Local lSucesso := .T.

	If _lLogMrp == Nil
		_lLogMrp := SuperGetMV("MV_LOGMRP", .F., "2") == "1"

		If _lLogMrp
			_oLogs := MrpDados_Logs():New(cFilAnt)

			//Global exclusiva do MrpDados_Logs (independente do MRP)
			If VarSetUID(_oLogs:cUIDLogs, .T.)
				VarSetXD(_oLogs:cUIDLogs, "lGravaLog", _lLogMrp)
			EndIf

			_oLogs:oArquivo := FWFileWriter():New(_oLogs:cFileName, .F.)

			lSucesso := _oLogs:oArquivo:exists()
			If !lSucesso
				lSucesso := _oLogs:oArquivo:create()
				If lSucesso
					lSucesso :=_oLogs:oArquivo:write(CABECALHO_ARQUIVO)
				EndIf
				If lSucesso
					lSucesso := _oLogs:oArquivo:write(getPrefixo(cEtapa) + "Arquivo criado nesta etapa pois o mesmo nao foi encontrado")
				EndIF
			EndIf
			_oLogs:oArquivo:close()

			If !lSucesso
				LogMsg("PCPA712", 0, 0, 1, "", "", "Nao foi possivel criar o arquivo " + _oLogs:cFileName + IIf(Empty(_oLogs:oArquivo:error():Message), "", ". Erro: "+ AllTrim(_oLogs:oArquivo:error():Message)))
				VarSetXD(_oLogs:cUIDLogs, "lGravaLog", .F.)
				VarSetXD(_oLogs:cUIDLogs, "lErroArq" , .T.)
			EndIf
		EndIf
	EndIf

	If lSucesso .And. _lLogMrp
		_oLogs:gravaLog(cEtapa, cIdentif, aMensagem)
	EndIf

Return

/*/{Protheus.doc} finalizaLogs
Finaliza a gravação dos Logs (método estático)

@author marcelo.neumann
@since 24/09/2024
@version P12
@param 01 cEtapa   , Caracter, Etapa que gerou o log
@param 02 cMensagem, Caracter, Mensagem de log a ser gravada
@return Nil
/*/
Method finalizaLogs(cEtapa, cMensagem) Class MrpDados_Logs

	If _lLogMrp <> Nil .And. _lLogMrp
		_oLogs:gravaLog(cEtapa, /*cIdentif*/, {cMensagem})
		_oLogs:destroy()
	EndIf

Return
