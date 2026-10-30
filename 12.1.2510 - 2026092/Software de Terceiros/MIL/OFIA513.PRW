
#Include "Protheus.ch"
#include "FWMVCDEF.CH"
#include "OFIA513.CH"

Static oModel01
Static oArrHelper

/*/{Protheus.doc} OFIA513
	Importação de faturas de pedidos ambiente Mexicano
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OFIA513()

	If cPaisLoc <> "MEX"
		FMX_HELP("OFIA513MEX", STR0001, STR0002)   // "Esta rotina não pode ser executada para esta configuração de país" | "Executar em outra configuração de país ou verifique o procedimento"
		Return
	Endif

	Private oConfig := OFJDConfig():New("OFIA513")	

	Private oProcImpXML
	Private aNatTpMov := {}
	Private aNatConst := {}
	Private aNatAgric := {}

	FWExecView(STR0003, "OFIA513", MODEL_OPERATION_UPDATE) //"Importação de Faturas - América Latina"
Return

/*/{Protheus.doc} ViewDef
	Definicao da view	
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
static function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1

	oStr1    := oModel01:GetView()
	
	oStr1:RemoveField("ERROR")
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FIELD_BOX'   , oStr1   , 'BASE')

	oView:CreateHorizontalBox('BOX', 100)

	oView:SetOwnerView('FIELD_BOX','BOX')

	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})
	oView:SetUpdateMessage(STR0004, STR0005) //"Concluído" | "Processamento do arquivo finalizado!"

	// Retira o botão de "Salvar e Criar um Novo"
	oView:SetCloseOnOk({||.t.})
	oView:SetAfterOkButton( {|oView| OA5130057_consulta_erro(oView)})

	oView:AddUserButton(STR0006,'IMPRESSAO', {|| OFIC020("OFIA513","VQL_AGROUP=='OFIA513'",.f.) }) // "Consultar Logs"

return oView

/*/{Protheus.doc} ModelDef
	Definicao do modelo	
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
static function ModelDef()
	Local oModel
	Local oStr1

	If oModel01 == Nil
		oArrHelper := DMS_ArrayHelper():New()
		oModel01   := OA5130027_GetModel01()		
	EndIf
	oStr1    := oModel01:GetModel()
	
	oModel := MPFormModel():New('OFIA513',,,{ |oModel| OA5130137_Importar(oModel) })
	oModel:SetDescription(STR0007) // "Dados para importação"	
	oModel:AddFields("BASE",,oStr1,,,{|| OA5130267_ler_dados() })
	oModel:GetModel("BASE"):SetDescription(STR0007) //"Dados para importação"

	oModel:SetPrimaryKey({})
return oModel

/*/{Protheus.doc} OA5130017_ler_vars_layout
	Layout das faturas ambiente Mexicano
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OA5130017_Ler_Vars_Layout()
	aFatHdStr := {}
	aFatItStr := {}

	aadd(aFatHdStr, {"NUMERO_FATURA"       , Nil }) // "Nro Fatura"
	aadd(aFatHdStr, {"DATA_FATURA"         , {|z| Ctod(z) }}) // "Fecha Factura"
	aadd(aFatHdStr, {"VALOR_TOTAL"         , {|z| val(z) }}) // "Valor Total"	
	aadd(aFatHdStr, {"MOEDA"		       , Nil }) // "Moeda
	aadd(aFatHdStr, {"TIPO"			       , Nil }) // "Tipo
			
	aadd(aFatItStr, { "PECA"               , Nil }) //Pieza    
	aadd(aFatItStr, { "QUANTIDADE"         , { |z| val(z) } }) //Cant.
	aadd(aFatItStr, { "PRECO_UNITARIO"     , { |z| val(z) } }) //Precio unitario
	aadd(aFatItStr, { "NUMERO_PEDIDO"      , Nil }) //Referencia 
	aadd(aFatItStr, { "PRECO_TOTAL"        , { |z| val(z) } }) //Precio total
Return

/*/{Protheus.doc} OA5130027_GetModel01
	Definicao da struct usada no filtro	
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Static Function OA5130027_GetModel01()
	Local oMd := OFDMSStruct():New()
	
	oMd:AddField({;
		{'cTitulo'     , STR0009 },; // "Caminho do arquivo"
		{'cIdField'    , "ARQUIVO" },;
		{'nTamanho'    , 400 },;
		{'bValid'      , { |a,b,c,d| OA5130037_Selecionar_Arquivo(a,b,c,d) }},;
		{'lObrigat'    , .T. },;
		{'cTooltip'    , STR0010 } ; //"Caminho para o arquivo que será importado"
	})

	oMd:AddFieldDictionary( "VE4" , "VE4_PREFAB" , {;
		{'cIdField' , "MARCA" },;
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| OA5130047_vld_cpo(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_FORNECE" , {;
		{'cIdField' , "FORNECEDOR" },;
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| OA5130047_vld_cpo(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_LOJA" , {;
		{'cIdField' , "LOJA_FORNECEDOR" },;
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| OA5130047_vld_cpo(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SD1" , "D1_TES" , {;
		{'cIdField' , "TES_ENTRADA" },;
		{'cTitulo'  , STR0011 },; //"TES Fatura"
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| OA5130047_vld_cpo(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_SERIE" , {;
		{'cIdField' , "FATURA_SERIE" },;
		{'cTitulo'  , STR0012 },; //"Série da Fatura"
		{'lObrigat' , .t. } ;
	})

	oMd:AddFieldDictionary( "SE2" , "E2_NATUREZ" , {;
		{'cIdField' , "NATUREZA" },;
		{'cTitulo'  , STR0014},; // "Natureza"
		{'bValid'   , FWBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. ExistCpo("SED")') }, ;
		{'lObrigat' , .f. } ;
	})

	oMd:AddField({;
		{'cTitulo'      , STR0015 },; // "Erro"
		{'cIdField'     , "ERROR" },;
		{'nTamanho'     , 1 },;
		{'aComboValues' , {"0="+STR0016,"1="+STR0017}},; // "NÃO" | "SIM"
		{'lObrigat'     , .F. },;
		{'lWhen'        , .F. },;
		{'cTooltip'     , STR0018 } ; //"Ocorreu erro na importação"
	})

return oMd

/*/{Protheus.doc} OA5130037_selecionar_arquivo
	Selecinar o arquivo para importação
	@type function
    @author Leandro Henrique Rodrigues
    @since 13/12/2025
/*/
Static Function OA5130037_Selecionar_Arquivo(oModel, cField, xValue, xValueAntigo)
	Local oView := FWViewActive()

	cPath := cGetFile("",STR0019,,"",.T.,GETF_LOCALHARD,.T., .T.) // "Local"
	If Empty(cPath)
		Return .F.
	Endif
	oModel:LoadValue(cField, cPath)
	oView:Refresh()

Return .T.

/*/{Protheus.doc} OA5130047_vld_cpo
	validacao dos campos na tela
	@type function
    @author Leandro Henrique Rodrigues
    @since 13/12/2025
/*/
Static Function OA5130047_Vld_Cpo(oModel, cField, xValue, xValueAntigo)
	Local lRet     := .t.
	Local cSeek    := cvaltochar(xValue)

	If Empty(cSeek)
		Return .t.
	EndIf
	
	Do Case
		Case cField == "MARCA"
			dbSelectArea("VE1")
			dbSetOrder(1)
			lRet := dbSeek(xFilial("VE1") + cSeek )

		Case cField == "FORNECEDOR"
			dbSelectArea("SA2")
			dbSetOrder(1)
			lRet := dbSeek(xFilial("SA2") + cSeek + alltrim(oModel:GetValue("LOJA_FORNECEDOR")))

		Case cField == "LOJA_FORNECEDOR"
			dbSelectArea("SA2")
			dbSetOrder(1)
			lRet := dbSeek(xFilial("SA2") + oModel:GetValue("FORNECEDOR") + cSeek)

		Case cField == "TES_ENTRADA"
			dbSelectArea("SF4")
			dbSetOrder(1)

			lRet := (dbSeek(xFilial("SF4") + cSeek))

			If lRet
				If SF4->F4_TIPO == 'S'	 
					FMX_HELP("OA513TES", STR0051, STR0052) //"Tes inválida!" | "TES do tipo serviço não é permitido para esta operação."
					lRet := .f.	
				Else
					if (SF4->F4_ESTOQUE == 'S' .and. SF4->F4_DUPLIC == 'S')
						lRet := .T.
					Else
						FMX_HELP("OA513TES", STR0051, STR0053) //"Tes inválida!" | "TES deve ser de controle de estoque e permitir duplicatas."
						lRet := .f.
					EndIf				
				EndIf								
			Else
				lRet := .f.
			endif
	EndCase

return lRet

/*/{Protheus.doc} OA5130267_ler_dados	
	Lendo os dados da configuração para popular a tela
	@type function
	@author Leandro Henrique
	@since 13/12/2025
/*/
Static Function OA5130267_ler_dados()
	Local aDados := {}

	AAdd(aDados, Space(400))
	AAdd(aDados, oConfig:GetValue("CFG_MARCA", Left(GetMV("MV_MIL0006") + Space(GetSX3Cache("VE4_PREFAB", "X3_TAMANHO")), GetSX3Cache("VE4_PREFAB", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_FORNECEDOR", Space(GetSX3Cache("A2_COD", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_LOJA_FORNECEDOR", Space(GetSX3Cache("A2_LOJA", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_TES_ENTRADA", Space(GetSX3Cache("F4_CODIGO", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_FATURA_SERIE", Space(GetSX3Cache("F1_SERIE", "X3_TAMANHO"))))	
	AAdd(aDados, oConfig:GetValue("CFG_NATUREZA", Space(GetSX3Cache("E2_NATUREZ", "X3_TAMANHO"))))

	AAdd(aDados, "0")

Return {aDados, 0}

/*/{Protheus.doc} OA5130137_Importar
	Importa o arquivo selecionado
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OA5130137_Importar(oModel)

	Local lOk := .t.

	oProcImpXML := MsNewProcess():New({ |lEnd| lOk := OA5130127_Executa_Importacao(oModel) }, STR0020, "", .f.) //"Importando"
	oProcImpXML:Activate()

Return lOk

/*/{Protheus.doc} OA5130127_Executa_Importacao
	Executa a importação do arquivo.
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OA5130127_Executa_Importacao(oModel)
	Private aFatHdStr := {}
	Private aFatItStr := {}
	Private aFatRdp   := {}
	Private aRemStr   := {}

	oProcImpXML:SetRegua1(3)

	oProcImpXML:IncRegua1(STR0021) // "Processando"

	oModelBase := oModel:GetModel("BASE")

	OA5130067_Gravar_Configuracao(oModelBase)

	OA5130017_ler_vars_layout()

	cMarca := oModelBase:GetValue("MARCA")
	// if empty(cMarca)
	// 	MsgStop(STR0022) //"A marca é obrigatória"
	// 	return .f.
	// endif

	// tem pedido jdprism pendente?
	cQuery := " SELECT COUNT(*) FROM "+RetSqlName('SC7')
	cQuery += "  WHERE C7_FILIAL  = '"+xFilial('SC7')+"' "
	cQuery += "    AND C7_PEDFAB  = 'JDPRISM' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	if FM_SQL(cQuery) > 0
		cMsg := STR0023 // "Um pedido importado via jdprism encontras-se pendente, "
		cMsg += STR0024  + chr(13) + chr(10) //"tem certeza que deseja continuar com a importação?"
		cMsg += STR0025 //"Isto pode fazer com que um pedido seja duplicado e o estoque encomendado seja alterado."
		if ! MsgNoYes(cMsg, STR0026) //"Atenção!"
			MsgStop(STR0027)//"Operação cancelada, o pedido pendente pode ser adequado na rotina de Importações JDPRISM (OFINJD44)"
			return .f.
		endif
	endif

	OA5130147_Importar_Arquivo(oModel, cMarca, oModelBase:GetValue("ARQUIVO") )

Return .t.

/*/{Protheus.doc} OA5130147_Importar_Arquivo
	Importa o arquivo realmente e adequa o SC7 conforme
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OA5130147_Importar_Arquivo(oModel, cMarca, cFullPathToFile)
	local nX := 1
	local cBckFlal := cFilAnt
	Local lErro := .f.
	Local nProc := 0
	Local oModelBase	
	Local cFilFat := ""

	Private oLogger := DMS_Logger():New("OFIA513.LOG")
	Private cSegmto := ""

	if ! OA5130247_Filial_Fatura(@cFilFat)
		Return .f.		
	EndIf	
	
	cFilAnt := cFilFat // Atualizar a filial de importação da fatura conforme seleção do usuário

	if ! OA5130257_segmento_filial_dealer()
		Return .f.		
	EndIf

	lSucesso := .f.

	oProcImpXML:IncRegua1(STR0021) // "Processando"

	oModelBase := oModel:GetModel("BASE")

	aFaturas := OA5130207_Ler_Fatura(cFullPathToFile)
	
	oProcImpXML:SetRegua2(len(aFaturas))
	oProcImpXML:IncRegua2(STR0028) // "Importando faturas..."

	for nX := 1 to len(aFaturas)
		lSucesso := OA5130177_Importar_Faturas(aFaturas[nX], aFaturas[nX, "ITENS"], cMarca, oModel, @lErro) // faturas da filial corrente			
		if ! lSucesso
			exit
		endif
		nProc++
		oProcImpXML:IncRegua2(STR0028 + " " + cvaltochar(nX) + " / " + cvaltochar(len(aFaturas)))
	next

	oProcImpXML:IncRegua1(STR0021) // "Processando"

	If lErro
		oModelBase:SetValue("ERROR", "1")
	EndIf

	cFilAnt := cBckFlal

	if ValType(oModelBase) != "U" .and. lSucesso
		oModelBase:LoadValue("ARQUIVO", STR0030 + " " + cFullPathToFile + " " + STR0031)// "Arquivo" | "Importado com sucesso."
	endif
	aLinha := {}
	aDadFat := {}
	oProcImpXML := nil
return .t.

/*/{Protheus.doc} OA5130157_Interpreta_Linha
	Interpreta a linha do arquivo conforme layout
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OA5130157_Interpreta_Linha(cLinha, aEstrutura, lVldLayout, nLinha)
	local nX := 1
	local jJson := JsonObject():new()
	Local aDadosLin := strtokarr2(StrTran(cLinha,'"',''), ',')
	Local nMoedaFat := 0

	if Len(aDadosLin) == Len(aEstrutura)

		if nLinha == 1 // Linha 1 - Cabeçalho
			nMoedaFat := OA5130217_Valid_Moeda_Fatura(aDadosLin[4]) // quarta é posição da moeda no layout
			If nMoedaFat == 0
				lVldLayout := .F. // Variavel passada por referência (@lVldLayout) para informar que o layout está incorreto
				return jJson
			Endif
		Endif

		for	nX := 1 to len(aEstrutura)
			cAttr := aEstrutura[nX, 1]
			if nLinha == 1 // Linha 1 - Cabeçalho
				xValue := iif(nX == 4, nMoedaFat, aDadosLin[nX]) // nX é posição da estrutura que retornará o conteúdo da posição da linha do array aDadosLin
			Else
				if nX == 4 // Posição 4 do layout para os itens da faturaQ será o dealer referente (C7_NUM) 
					xValue := OA5130237_buscar_pedido_fabrica(aDadosLin[nX])
				Else
					xValue := aDadosLin[nX] // nX é posição da estrutura que retornará o conteúdo da posição da linha do array aDadosLin
				EndIf				
			EndIf
			if ValType(aEstrutura[nX, 2]) == "B"
				xValue := eval(aEstrutura[nX, 2], xValue)
			endif
			jJson[cAttr] := xValue
		next
	Else 
		lVldLayout := .F. // Variavel passada por referência (@lVldLayout) para informar que o layout está incorreto
	EndIF
	
return jJson

/*/{Protheus.doc} OA5130177_Importar_Faturas
	importar fatura identificando pedido
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OA5130177_Importar_Faturas(jFatura, jItensFatura, cMarca, oModel, lErro)
	Local oArrHelper := DMS_ArrayHelper():New()
	Local aItens     := jItensFatura
	Local oModelBase := oModel:GetModel("BASE")
	Local cObserv    := ""
	Local cNota      := jFatura["NUMERO_FATURA"] //PadL(jFatura["NUMERO_FATURA"]), GetSX3Cache("F1_DOC","X3_TAMANHO") , "0")
	Local cFunName   := FunName()
	Local aPedsFat   := {}
	Local nY         := 0

	dbSelectArea("SA2")
	dbSetOrder(1)
	if ! dbSeek(xFilial("SA2") + oModelBase:GetValue("FORNECEDOR") + oModelBase:GetValue("LOJA_FORNECEDOR"))
		MsgStop(STR0033) //"Não foi possível selecionar fornecedor, abortando."
		return .f.
	endif

	DbSelectArea("VE4")
	nRecnoVE4 := FM_SQL("SELECT R_E_C_N_O_ FROM " + RetSqlName("VE4") + " WHERE VE4_FILIAL = '"+xfilial("VE4")+"' AND VE4_CODFOR = '"+SA2->A2_COD+"' AND VE4_LOJFOR = '"+SA2->A2_LOJA+"' AND VE4_PREFAB = '"+cMarca+"' AND D_E_L_E_T_ = ' ' ")
	If nRecnoVE4 <= 0
		MsgStop(STR0034 + Alltrim(SA2->A2_CGC) +; //"Não foi possível encontrar o cadastro do fornecedor com CNPJ "
			STR0035,STR0036) //" na rotina Parâmetro Marca (OFIPA980). A operação será abortada.| Por favor verifique!" 
		Return .f.
	else
		DbGoTo(nRecnoVE4)
	EndIf

	if Empty(SA2->A2_COND) .and. Empty(VE4->VE4_PGTNFP)
		MsgStop(STR0037) //"Nenhuma condição de pagamento detectada, campos lidos: A2_COND e VE4_PGTNFP")
		return .F.
	EndIf

	aPedsFat := oArrHelper:GroupByBlock(aItens, { |jItemFat| jItemFat["NUMERO_PEDIDO"] })
	for nY := 1 to len(aPedsFat)
		if ! Empty(aPedsFat[nY,1])
			if ! OA5130227_Atualizar_Pedido(cMarca, SA2->A2_COD, SA2->A2_LOJA, VE4->VE4_PGTNFP, aPedsFat[nY,1])
				return .F.
			EndIf
		endif
	next

	aItens := oArrHelper:Map(aItens, { |jItemFat| OA5130167_Localiza_Pedido(jItemFat, @cObserv) })

	aCabFactura := {}
	aItsFactura := {}

	lMsErroAuto := .F.
	
	lRet := OA5130187_Array_Fatura( @aCabFactura, @aItsFactura, jFatura, aItens, oModel, cNota, @cObserv)

	if lRet
		SetFunName("MATA101N")
		MsExecAuto({|x,y,z| MATA101N(x,y,z)}, aCabFactura, aItsFactura, 3)
		SetFunName(cFunName)
	EndIf

	if lMsErroAuto
		cObserv += MostraErro("\")
	endif

	lErro := !Empty(cObserv)

	If lErro
		oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFIA513'             },;
				{'VQL_TIPO'       , STR0038               },;
				{'VQL_DADOS'      , cNota                 },;
				{'VQL_FILORI'     , xFilial("SD2")        },;
				{'VQL_MSGLOG'     , cObserv               } ;
		})
	EndIf

return .t.

/*/{Protheus.doc} OA5130167_Localiza_Pedido
	Localiza o pedido da fatura 
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OA5130167_Localiza_Pedido(jItemFat,cObserv)
	local cQuery := ""
	local nX := 1
	local oSql := DMS_SqlHelper():New()
	local aServem := {} // a ideia é colocar aqui os pedidos que servem para baixar, ou seja, sao os mais proximos da qtd faltante e recebida
	local aPerfeito := {}
	local oEscolha, oItem
	Local nFaltante := 0
	
	If Empty(jItemFat["NUMERO_PEDIDO"])
		Return jItemFat
	EndIf

	cQuery := " SELECT C7_FILIAL, C7_NUM, C7_ITEM, R_E_C_N_O_ as RECNO, C7_QUANT, "
	cQuery += "        C7_SLITPED, C7_RESIDUO, C7_ENCER, C7_QUJE, C7_LOCAL  "
	cQuery += "   FROM " + RetSqlName("SC7")
	cQuery += "  WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	cQuery += "    AND C7_PRODUTO = '"+AllTrim(jItemFat["PECA"])+"' "
	cQuery += "    AND C7_PEDFAB = '"+AllTrim(jItemFat["NUMERO_PEDIDO"])+"' "
	cQuery += "    AND C7_RESIDUO = ' ' "
	cQuery += "    AND C7_ENCER   = ' ' "
	cQuery += "    AND C7_QUANT > C7_QUJE "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	
	aDados := oSql:GetSelect({ ;
		{ 'campos', {"C7_FILIAL", "C7_NUM", "C7_ITEM", "RECNO", "C7_SLITPED", "C7_QUANT", "C7_RESIDUO", "C7_ENCER", "C7_QUJE", "C7_LOCAL"} }, ;
		{ 'query' , cQuery } ;
	})

	for nX := 1 to len(aDados) //todo: tratar o substituto de forma melhor, acho que tem que sincronizar o pedido qdo tem substituto, bom de qlqr  jeito nao da pra fazer agora por falta de tempo
		oItem := aDados[nX]
		nFaltante := oItem:GetValue("C7_QUANT") - oItem:GetValue("C7_QUJE", 0)

		if nFaltante == jItemFat["QUANTIDADE"]
			aadd(aPerfeito, oItem)
		else
			oItem:SetValue("diferenca", nFaltante - jItemFat["QUANTIDADE"])
			aadd(aServem, oItem)
		endif
	next

	if len(aPerfeito) >= 1
		oEscolha := aPerfeito[1]
	else
		for nX := 1 to len(aServem)
			oItem := aServem[nX]
			if oItem:GetValue("diferenca", -1) <= 0
				loop
			endif

			if valtype(oEscolha) == "U" .or. oItem:GetValue("diferenca", 999) < oEscolha:Gv("diferenca", 999)
				oEscolha := oItem
			endif
		next
	endif

	if valtype(oEscolha) != "U"
		jItemFat["C7_NUM"]   := oEscolha:GetValue("C7_NUM")
		jItemFat["C7_ITEM"]  := oEscolha:GetValue("C7_ITEM")
		jItemFat["C7_LOCAL"] := oEscolha:GetValue("C7_LOCAL")
	else
		// todo: se nao encontrou C7 o que fazer? logar algo?
		cObserv += STR0039 + " ( " + AllTrim(jItemFat["PECA"]) + " - " + jItemFat["NUMERO_PEDIDO"] + " )" + chr(13) + chr(10) // "Item não encontrado ou cancelado no pedido de compra "
	endif
return jItemFat

/*/{Protheus.doc} OA5130187_Array_Fatura
	Retorna o D1_ITEM da Fatura de Origem (ARGENTINA)
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OA5130187_Array_Fatura( aCabFactura, aItsFactura, jFatura, aItens, oModelPrinc, cNota, cObserv)
	Local aD1Data    := {}
	Local nY         := 0
	local cNumIte    := Repl("0", GetSX3Cache("D1_ITEM", "X3_TAMANHO"))	
	Local cCodTes    := ""
	Local oModelBase := oModelPrinc:GetModel("BASE")
	Local nMoedaFat  := jFatura["MOEDA"]
	Local nTaxMoeFat := xMoeda(1, nMoedaFat, 1, jFatura["DATA_FATURA"], TamSX3("F1_TXMOEDA")[2])

	aAdd(aCabFactura, { "F1_EMISSAO" , jFatura["DATA_FATURA"]   , Nil })
	if ! Empty(SA2->A2_COND)
		aAdd(aCabFactura, { "F1_COND", SA2->A2_COND             , Nil })
	elseif ! Empty(VE4->VE4_PGTNFP)
		aAdd(aCabFactura, { "F1_COND", VE4->VE4_PGTNFP          , Nil })
	endif
	aAdd(aCabFactura, { "F1_FORNECE" , SA2->A2_COD              , Nil })
	aAdd(aCabFactura, { "F1_LOJA"    , SA2->A2_LOJA             , Nil })
	aAdd(aCabFactura, { "F1_EST"     , SA2->A2_EST              , Nil })
	aAdd(aCabFactura, { "F1_DOC"     , cNota                    , Nil })
	aAdd(aCabFactura, { "F1_FORMUL"  , "N"                      , Nil })
	aAdd(aCabFactura, { "F1_TIPODOC" , " "                      , Nil }) // precisa passar mesmo que em branco pois no fonte do backoffice identifica o tipo da nota usando existencia desse campo
	aAdd(aCabFactura, { "F1_MOEDA"   , nMoedaFat		        , Nil })
	aAdd(aCabFactura, { "F1_TXMOEDA" , nTaxMoeFat               , Nil })
	aadd(aCabFactura, { "F1_VALMERC" , jFatura["VALOR_TOTAL"]   , Nil })
	aadd(aCabFactura, { "F1_VALBRUT" , jFatura["VALOR_TOTAL"]   , Nil })

	if ! Empty(oModelBase:GetValue("NATUREZA"))
		aadd(aCabFactura, { "F1_NATUREZ" , oModelBase:GetValue("NATUREZA"    ), Nil })
	endif

	if ! Empty(oModelBase:GetValue("FATURA_SERIE"))
		aAdd(aCabFactura, { "F1_SERIE"   , oModelBase:GetValue("FATURA_SERIE"), Nil })
	endif

	aItsFactura := {}

	for nY := 1 to len(aItens)
		jItemPedido := aItens[nY]

		aD1Data := {}

		cCodItem := AllTRim(jItemPedido["PECA"])
		cCodTes := oModelBase:GetValue("TES_ENTRADA")
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + AvKey(cCodItem,"B1_COD"))

		cNumIte := SOMA1(cNumIte)
		AADD( aD1Data , { "D1_ITEM"    , cNumIte                                  , Nil })
		AADD( aD1Data , { "D1_COD"     , SB1->B1_COD                              , Nil })
		AADD( aD1Data , { "D1_UM"      , SB1->B1_UM                               , Nil })
		AADD( aD1Data , { "D1_DOC"     , cNota                                    , Nil })
		AADD( aD1Data , { "D1_TES"     , cCodTes                                  , Nil })

		If ! Empty(jItemPedido["C7_NUM"])
			AADD( aD1Data , { "D1_PEDIDO"  , jItemPedido["C7_NUM"]                , Nil })
		EndIf
		If ! Empty(jItemPedido["C7_ITEM"])
			AADD( aD1Data , { "D1_ITEMPC"  , jItemPedido["C7_ITEM"]               , Nil })
		endif
		if ! Empty(jItemPedido["C7_LOCAL"])
			AADD( aD1Data , { "D1_LOCAL"   , jItemPedido["C7_LOCAL"]              , Nil })
		else
			AADD( aD1Data , { "D1_LOCAL"   , SB1->B1_LOCPAD                       , Nil }) // se nao achou C7 usa o locpad
		endif
		AADD( aD1Data , { "D1_QUANT"   , jItemPedido["QUANTIDADE"]                , Nil })
		AADD( aD1Data , { "D1_VUNIT"   , Round( jItemPedido["PRECO_UNITARIO"] , GetSX3Cache("D1_VUNIT","X3_DECIMAL")) , Nil })
		AADD( aD1Data , { "D1_TOTAL"   , jItemPedido["PRECO_TOTAL"] , Nil })		

		aadd(aItsFactura, aclone(aD1Data))
	next

Return Len(aItsFactura) > 0

/*/{Protheus.doc} OA5130067_Gravar_Configuracao
	Salva os dados preenchidos na tela	
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Static Function OA5130067_Gravar_Configuracao(oModel)

	Local jJson := JsonObject():New()
	Local nI := 0
	Local cCpoNGrv := "ARQUIVO/ERROR/"

	Local oModBase := oModel

	Local oStructCab := oModBase:GetStruct()
	Local aFieldsCab := oStructCab:GetFields()

	For nI := 1 to Len(aFieldsCab)

		cCampo := aFieldsCab[nI,3]

		If !(cCampo $ cCpoNGrv)

			jJson["CFG_"+cCampo] := oModBase:GetValue(cCampo)
		
		EndIf

	Next

	oConfig:Save(jJson)
return .t.

/*/{Protheus.doc} OA5130057_consulta_erro
	Consulta se houve erro na importação do arquivo de remito
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
Function OA5130057_Consulta_Erro(oView)

	Local oModel := oView:GetModel()
	Local oModelBase := oModel:GetModel("BASE")

	If oModelBase:GetValue("ERROR") == "1"
		If MsgYesNo(STR0040) // "Houve inconsistencias na importação. Deseja visualizar?"
			OFIC020("OFIA513","@ VQL_AGROUP='OFIA513' AND VQL_DATAI='" + DtoS(dDataBase) + "'",.f.)
		EndIf
	EndIf

Return

/*/{Protheus.doc} OA5130117_Campos_Fatura
	Campos customizados de 1=Fatura (SF1/SD1)	
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
/*/
// Static Function OA5130117_Campos_Fatura()
// 	Local oMd := OFDMSStruct():New()
// 	Local nX := 1
// 	Local aFldCus := {}
// 	Local lDic := .f.

// 	// filtrar somente os campos dessa integracao
// 	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == "1" })

// 	for nX := 1 to len(aFldCus)
// 		jFld := aFldCus[nX]

// 		lDic := jFld["isDic"]
// 		if lDic
// 			oMd:AddFieldDictionary(jFld["alias"], jFld["campo"], {})
// 		else
// 			oMd:AddField(OA507284_jToa(jFld))
// 		endif
		
// 	next

// return oMd

/*{Protheus.doc} OA5130107_Tem_Cpos_Customizados
	Verifica se existem campos customizados do determinado tipo
	@type function
	@author Leandro Henrique Rodrigues
	@since 13/12/2025
*/
Function OA5130107_Tem_Cpos_Customizados(oArrHelper)
	local aFldCus := {}
	Default oArrHelper := DMS_ArrayHelper():New()

	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == cTipo })

Return len(aFldCus) > 0

/*{Protheus.doc} OA5130207_Ler_Fatura
	Realizando a leitura do arquivo de fatura
	@type function
	@author Leandro Henrique Rodrigues
	@since 19/12/2025
*/
Static Function OA5130207_Ler_Fatura(cFullPathToFile)
	local aPedidos  := {}
	local jLastPed
	Local nLinha    := 1
	Local lVldLayout:= .t.

	oFile := FWFileReader():New(cFullPathToFile)
    if oFile:Open()
		while oFile:hasLine()
			cLinha := oFile:getLine()
			if !Empty(cLinha)
				if nLinha == 1			
					jLastPed := OA5130157_Interpreta_Linha(cLinha, aFatHdStr, @lVldLayout, nLinha)
					aadd(aPedidos, jLastPed)
					nLinha++
				else
					// if ValType(jLastPed) == "U"
					// 	alert(STR0032) //"Layout de arquivo inválido, impossível continuar.")
					// 	return {}
					// endif
					if ValType(jLastPed["ITENS"]) == "U"
						jLastPed["ITENS"] := {}
					endif
					aadd(jLastPed["ITENS"], OA5130157_Interpreta_Linha(cLinha, aFatItStr, @lVldLayout, nLinha))
				Endif

				IF !lVldLayout
					Alert(STR0032) //"Layout de arquivo inválido, impossível continuar.")
					return {}
				endif
			Endif
		EndDo
	endif
Return aPedidos

/*/{Protheus.doc} OA5130217_Valid_Moeda_Fatura
	Mercado Internacional - valida/retorna a moeda enviado no arquivo de Fatura
	@type function
	@author Leandro Henrique Rodrigues
	@since 26/12/2025
/*/
Static Function OA5130217_Valid_Moeda_Fatura(cMoeArqFat)
	Local cAux       := ""
	Local nPos	     := 0
	Local nMoedFat   := 0
	Local aMoedasFat := {{"P",1},{"D",2}} // Peso , Dólar
	
	nPos := aScan(aMoedasFat, {|x| x[1] == AllTrim(Upper(cMoeArqFat))})
	if nPos > 0
		nMoedFat := aMoedasFat[nPos][2]
	EndIf
	
	if nMoedFat > 0
		cAux := GETMV("MV_MOEDA"+Alltrim(STR(nMoedFat))) // Valida se a moeda está ativa no sistema
		If Empty(cAux)
			MsgStop(STR0043 + Alltrim(cMoeArqFat), STR0029) //"Moeda da fatura no layout inválida. Moeda arquivo: " | "Processo abortado.""
			nMoedFat := 0	
		EndIf
	Else
		MsgStop(STR0043 + Alltrim(cMoeArqFat), STR0029) //"Moeda da fatura no layout inválida. Moeda arquivo: " | "Processo abortado.""		
	EndIf

Return nMoedFat

/*/{Protheus.doc} OA5130227_Atualizar_Pedido
	Atualiza o pedido com o Jdpoint e antes busca os itens, eu preencho o aVetped 
	aqui pois a regra é um pouco diferente pra argentina visto que a linha
	não parece funcionar bem lá pois não vem na nota

	@type method
	@author Leandro Henrique Rodrigues
	@since 05/01/2026
/*/
Function OA5130227_Atualizar_Pedido(cMarca, cForn, cLoja, cCond, cPedFab)
	local cAliasSC7 := GetNextAlias()
	local aVetPed   := {}
	local lProblema := .f.

	cQuery := " SELECT SC7.R_E_C_N_O_ SC7RECNO, SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRODUTO, SC7.C7_PEDFAB, "
	cQuery += "        SC7.C7_ITEPED , SC7.C7_QUANT  , SC7.C7_QUJE , SC7.C7_QTDACLA,  "
	cQuery += "        SC7.C7_SLITPED, SC7.C7_RESIDUO, SC7.C7_ENCER, "
	cQuery += "        (SC7.C7_QUANT - SC7.C7_QUJE - SC7.C7_QTDACLA) SALDOPED "
	cQuery += "   FROM " + RetSqlName("SC7") + " SC7 "
	cQuery += "   JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SC7.C7_PRODUTO  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE "
	cQuery += "        SC7.C7_FILIAL  = '" + xFilial("SC7") + "'  "
	cQuery += "    AND SC7.C7_PEDFAB  = '" + cPedFab        + "'  "
	cQuery += "    AND SC7.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSC7, .T., .T. )
	while !(cAliasSC7)->( Eof() )

		cNumPedC7 := (cAliasSC7)->C7_NUM

		lProblema := (cAliasSC7)->C7_RESIDUO == 'S' .or. (cAliasSC7)->C7_ENCER == 'E' .or. (cAliasSC7)->C7_QUJE <> 0 .or. (cAliasSC7)->C7_QTDACLA <> 0

		aAdd(aVetPed, {;
			(cAliasSC7)->C7_PEDFAB,;
			(cAliasSC7)->C7_PRODUTO,;
			(cAliasSC7)->C7_ITEPED,;
			(cAliasSC7)->C7_NUM,;
			(cAliasSC7)->C7_ITEM,;
			0,;
			(cAliasSC7)->SC7RECNO,;
			IIf( lProblema , "residuo" , "naousado" ) ;
		})
		(cAliasSC7)->(dbSkip())

	End do
	(cAliasSC7)->(dbCloseArea())

	lOk := OFJD10I( ;
		cPedFab    ,; // cPedJD 
		cForn      ,; // cFornece 
		cLoja      ,; // cLoja 
		cCond      ,; // cCondicao 
		cMarca     ,; // cCodMarca 
		.T.        ,; // lImpXml // isso só serve pra atualizar uma coisa na tela que nao existe aqui, então false
		aVetPed    ,; // aVetPed // copiei do 44 mas pra mim nao deveria passar aqui
	) 
return lOk

/*/{Protheus.doc} OA5130237_buscar_pedido_fabrica
	Busca o numero do pedido da fabrica de acordo com o dealer references (C7_NUM) enviado no arquivo da faturaQ

	@type Function
	@author Leandro Henrique Rodrigues
	@since 06/01/2026
/*/
Static Function OA5130237_buscar_pedido_fabrica(cNumPedC7)
	Local aArea     := GetArea()
	Local cQuery    := "" 
	Local cAliasSC7 := GetNextAlias()
	Local cPedFab   := ""
	Local oSqlHlp   := DMS_SqlHelper():New()
	
	cQuery := " SELECT C7_PEDFAB  "
	cQuery += "   FROM "+RetSqlName('SC7') "
	cQuery += "  WHERE C7_FILIAL = '"+xFilial('SC7')+"' "
	cQuery += "    AND C7_NUM = '"+AllTrim(cNumPedC7)+"' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery := oSqlHlp:TopFunc(cQuery, 1)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAliasSC7, .F., .T. )
	
	If !(cAliasSC7)->(EOF())
		cPedFab := AllTrim((cAliasSC7)->C7_PEDFAB)
	EndIf

	(cAliasSC7)->(dbCloseArea())
	RestArea(aArea)
Return cPedFab

/*/{Protheus.doc} OA5130247_Filial_Fatura
Carregar FILIAIS para o usuário selecionar a desejada para importar a fatura
@author Leandro Henrique
@since 12/01/2026
@version undefined
@type function
/*/
Static Function OA5130247_Filial_Fatura(cFilFat)
	Local aParamBox   := {}
	Local aRet        := {}
	
	cFilFat := Space(TamSX3("F2_FILIAL")[1])
	
	AADD(aParamBox,{1,STR0044,cFilFat,"@!","ExistCpo('SM0',cEmpAnt + MV_PAR01)","SM0",".T.",50,.T.}) // "Sel. Filial Fatura"
	If ParamBox(aParamBox,STR0045,@aRet,,,,,,,,.f.) // "Importação Fatura"
		cFilFat := aRet[1] // Filial selecionada
	Else
		Alert(STR0046) //"Processo cancelado."
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} OA5130257_segmento_filial_dealer
Retorna o Segmento para a importação da fatura.
@author Leandro Henrique
@since 12/01/2026
@version undefined
@type function
/*/
Static Function OA5130257_segmento_filial_dealer()
	Local nX        := 0
	Local oConfig   := OFJDConfig():New()
	Local aDados    := oConfig:GetValue("FILIAIS", {})
	Local nCount    := 0
	Local aSegmto   := {}
	Local aParamBox := {}
	Local aRet      := {}

	For nX := 1 to len(aDados)
		if cFilAnt == aDados[nX]['FILIAL']
			if aDados[nX]['SEGMENTO'] <> "2" // 2 é igual a segmento indefinido
				cSegmto := aDados[nX]['SEGMENTO']
				aAdd(aSegmto, IIF(aDados[nX]['SEGMENTO']=="0", "0="+STR0047, "1="+STR0048))  // "agricola" | "construcao"
				nCount++
			EndIf
		EndIf
	Next

	if nCount > 1 
		AADD(aParamBox,{2, STR0049, SubStr(aSegmto[1],1,1),aSegmto,090, ".T.", .T.}) // "Sel. Segmento da Fatura"
		If ParamBox(aParamBox,STR0045,@aRet,,,,,,,,.f.) // Importação Fatura
			cSegmto := aRet[1] // Segmento
		Else
			Alert(STR0046) //"Processo cancelado."
			Return .F.
		EndIf
	EndIF

	if Empty(cSegmto)
		Alert(STR0050) // "Segmento inválido! Processo abortado."
		return .F.
	endif

Return .T. 
