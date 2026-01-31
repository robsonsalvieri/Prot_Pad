#include 'PROTHEUS.CH'
#include 'TOTVS.CH'
#include 'FWMVCDEF.CH'
#include 'EICLP501.CH'
#include "AVERAGE.CH"

#define DUIMP_INTEGRADA "1"
#define DUIMP_MANUAL    "2"
#Define ATT_CLASSTRIB      "ATT_15540"
#Define ATT_CLASSTRIB_VAL  "ATT_20130"

/*
Objetivo   : Função para realizar a atualização do modelo EICLP500 a partir de um processo de embarque já salvo
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
function EICLP501(cHawb, jModelo, lAtuSeqDU)
	local lRet       := .F.
	local cAliasSel  := alias()
	local oModelo    := nil
	local aAreaSW8   := {}

	default cHawb      := ""
	default lAtuSeqDU  := .T.

	dbSelectArea("SW8")
	aAreaSW8 := SW8->(getArea())

	SW8->(dbSetOrder(1)) //W8_FILIAL + W8_HAWB + W8_INVOICE + W8_FORN + W8_FORLOJ
	if !empty(cHawb) .and. SW8->(dbSeek(xFilial("SW8") + cHawb ))

		if jModelo <> nil .or. LP500VlPrc(.F., .F., .F.)
			LP500Atu(.T.)
			oModelo := FwLoadModel("EICLP500")
			oModelo:SetOperation(MODEL_OPERATION_UPDATE)
			oModelo:GetModel("SW9DETAIL"):SetNoDeleteLine(.F.) // devido a exclusão da invoice do desembaraço
			lRet := oModelo:Activate()

			lRet := lRet .and. loadModel(oModelo, jModelo, lAtuSeqDU)

			iif( lRet .and. oModelo:VldData(), lRet := oModelo:CommitData(), ( lRet := .F. , EasyHelp(STR0001 + CRLF + if( valtype(xError := oModelo:GetErrorMessage()) == "C", alltrim(xError), if( valtype(xError) == "A" .and. len(xError) >= 7 , CHR(10) + CHR(10) + STR0003 + ": " + allToChar( xError[6]) + CHR(10) + STR0004 + ": " + allToChar( xError[7] ) , "") ) ,STR0002,"") ) ) // "Não foi possível realizar a atualização dos Itens DUIMP" ## "Atenção" ## "Mensagem do erro" ## "Mensagem do solução"

			oModelo:DeActivate()
			oModelo:Destroy()
			FwFreeObj(oModelo)
		endif

	endIf

	restArea(aAreaSW8)

	if !empty(cAliasSel)
		dbSelectArea(cAliasSel)
	endIf

return lRet

/*
Objetivo   : Função para realizar a atualização do modelo EICLP500 com base no json
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
static function loadModel(oModelo, jModelo, lAtuSeqDU)
	local lRet       := .T.
	local aNames     := {}
	local oModSW9    := nil
	local nLine      := 0
	local jModelSW9  := nil
	local cChave     := ""
	local lSeek      := .F.

	default lAtuSeqDU:= .T.

	if valtype(jModelo) == "J" //atualização a partir da integração DUIMP

		aNames := jModelo:getnames()
		if aScan( aNames , { |X| X == "SW9DETAIL" } ) > 0

			oModSW9 := oModelo:getModel("SW9DETAIL")
			if lAtuSeqDU .And. LP500SeqD(oModelo, oModSW9)
				lRet := MsgYesNo( STR0005, STR0003 ) // "Foram identificados itens com a sequência da DUIMP informada. Deseja sobrescrever estas informações?"###"Atenção"
				if lRet
					LP500ClrSq()
				endif
			endif

			if lRet

				for nLine := 1 to len(jModelo["SW9DETAIL"])

					jModelSW9 := jModelo["SW9DETAIL"][nLine]

					if valtype(jModelSW9) == "J"
						aNames := jModelSW9:getnames()
						lRet := setModel("", oModelo, "SW9DETAIL", oModSW9, jModelSW9, aNames, @cChave, @lSeek )

						if lRet .and. lSeek .and. aScan( aNames , { |X| X == "RELACIONAMENTOS" } ) > 0
							lRet := len(jModelSW9["RELACIONAMENTOS"]) == 0 .or. setRelations(oModelo, "SW9DETAIL", jModelSW9["RELACIONAMENTOS"] )
							if !lRet
								exit
							endif
						endif

					endif

				next

				// para executar o método VldData
				lRet := .T.

			endif

		endif
	else //atualização a partir da gravação do desembaraço
		updSubModels(oModelo)
	endIf

return lRet

/*
Objetivo   : Função para realizar o set dos modelos relacionados
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
static function setRelations(oModPai, cModSup, aRelations )
	local lRet       := .F.
	local nRel       := 0
	local jRelation  := nil
	local aNames     := {}
	local nModRel    := 0
	local cModelo    := ""
	local oModRel    := nil
	local jModelRel  := nil
	local nModelos    := 0

	default aRelations := {}

	begin sequence

		for nRel := 1 to len( aRelations )

			jRelation := aRelations[nRel]
			aNames := jRelation:getnames()

			for nModRel := 1 to len( aNames )

				cModelo := aNames[nModRel]
				oModRel := oModPai:getModel(cModelo)

				if valtype(oModRel) == "O"
					jModelRel := jRelation[cModelo]
					cChave := ""
					lSeek := .F.

					for nModelos := 1 to len(jModelRel)

						jModel := jModelRel[nModelos]
						if valtype(jModel) == "J"

							aNames := jModel:getnames()
							lRet := setModel(cModSup, oModPai, cModelo, oModRel, jModel, aNames, @cChave, @lSeek )

							if lRet .and. lSeek .and. aScan( aNames , { |X| X == "RELACIONAMENTOS" } ) > 0
								lRet := len(jModel["RELACIONAMENTOS"]) == 0 .or. setRelations(oModPai, cModelo, jModel["RELACIONAMENTOS"] )
								if !lRet
									break
								endIf
							endIf

						endIf

					next

				endIf

			next nModRel

		next nRel

	end sequence

return lRet

/*
Objetivo   : Função para realizar o posicionamnento do registros do modelo e assim realizar o setvalue
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
static function setModel(cModPai, oModPai, cModelo, oModelo, jModel, aNames, cChave, lSeek )
	local lRet       := .F.
	local aSeek      := {}

	default cModelo    := oModelo:getId()
	default aNames     := jModel:getnames()
	default cChave     := ""
	default lSeek      := .F.

	if aScan( aNames , { |X| X == "SEEK" } ) > 0 .and. aScan( aNames , { |X| X == "CHAVE" } ) > 0 .and. ( empty(cChave) .or. !(cChave == jModel["CHAVE"]) )
		cChave := jModel["CHAVE"]
		aSeek := jModel["SEEK"]
		lSeek := .F.
	endIf

	if !lSeek
		lSeek := len(aSeek) == 0 .or. ( oModelo:ClassName() == "FWFORMGRID" .and. oModelo:SeekLine(aSeek, .F., .T.) )
		lRet := lSeek
	endIf

	if lSeek .and. aScan( aNames , { |X| X == "DADOS" } ) > 0
		lRet := len(jModel["DADOS"]) == 0 .or. setValue(oModelo, jModel["DADOS"])
	endIf

return lRet

/*
Objetivo   : Função para realizar o setValue do modelo
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
static function setValue(oModel, aDados)
	local lRet       := .T.
	local nInf       := 0

	default aDados     := {}

	for nInf := 1 to len( aDados )
		lRet := oModel:SetValue( aDados[nInf][1], aDados[nInf][2] )
		if !lRet
			exit
		endIf
	next

return lRet

/*/{Protheus.doc} updSubModels
Gravação dos submodelos do modelo EICLP500 a partir da gravação do embarque/ desembaraço
@type function
@version  1.0.0
@author wilsimar
@since 12/19/2024
@param oModel, object, modelo de dados com todos os submodelos
/*/
Static Function updSubModels(oModel)
	local nInvoice as numeric
	local nTotalInvoice as numeric
	local oModSW9 as object
	local nTotalItems as numeric

	oModSW9:= oModel:getModel("SW9DETAIL")
	nTotalInvoice:= oModSW9:Length(.T.)

	//régua de progresso
	nTotalItems:= TotalItems()
	procRegua(nTotalItems)

	if SW6->W6_FORMREG == DUIMP_INTEGRADA
		LP500DelSeq()
	endif

	//para cada invoice, criar ou atualizar o item da DUIMP
	oModel:getModel("SWVDETAIL"):SetNoInsertLine(.F.)
	for nInvoice:= 1 to nTotalInvoice

		oModSW9:goline(nInvoice)

		//a atualização dos itens da DUIMP será feita a partir dos itens da Invoice
		updDuimpItems(oModel, oModSW9, oModSW9:getValue("W9_HAWB"), oModSW9:getValue("W9_INVOICE"))

	next

Return .T.

/*/{Protheus.doc} updDuimpItems
Atualiza os itens da DUIMP (SWVDETAIL) a partir dos dados do modelo EICLP500
@type function
@version  1.0.0
@author wilsimar
@since 28/08/2025
/*/
Static Function updDuimpItems(oModel, oModSW9, cHawb, cInvoice)
	local oModSWV as object 
	local nTotalItems as numeric
	local lAddItems as logical
	local lExcInvoic as logical
	oModSWV:= oModel:getModel("SWVDETAIL")
	nTotalItems:= oModSWV:Length(.T.)

	//pelo instanciamento do modelo de dados, os itens da DUIMP (SWV) são relacionados diretamente com a capa da Inovice (SW9), por isso nascem sem itens
	//primeiro é necessário excluir os registros da SWV que foram instanciados sem o código do produto para depois iniciar a inclusão dos itens a partir dos itens da Invoice (SW8)
	//isso ocorrerá apenas quando houver apenas um item no modelo SWV, ou seja, o item que nasceu do instanciamento do modelo
	lAddItems:= nTotalItems == 1 .and. checkItems(oModSWV)

	SW8->(DBSetOrder(6)) //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
	// Tratamento para excluir a invoice que não tem mais itens vinculados
	lExcInvoic := VldInvoice( oModSW9, cHawb, cInvoice)
	if !lExcInvoic .and. !lAddItems
		// Tratamento para retirar os itens que não fazem mais parte da Invoice
		delDuimpItems(oModSWV, nTotalItems)
	endif

	//caso tenha excluído o registro, significa que não há itens desta invoice no modelo de dados
	//então é necessário incluir os itens a partir dos itens da Invoice (SW8), o que se aplica quando lAddItems for verdadeiro
	//também é necessário verificar se não é necessário atualizar informações dos itens da DUIMP a partir de atualizações de dados do processo ou da invoice,
	//o que se aplica quando o lAddItems for falso, ou seja, já havia itens da DUIMP no modelo
	addSwvDetail(oModel, lAddItems, cHawb, cInvoice)

Return

/*/{Protheus.doc} getModelsUpdate
recupera os submodelos que devem ser gravados pelo commit
@type function
@version  1.0.0
@author wilsimar
@since 12/23/2024
@param oModel, object, modelo de dados
@return variant, array com os submodelos que devem ser gravados
/*/
static function getModelsUpdate(oModel)
	local aDependecyModels as array
	local aModels as array

	//recupera os submodelos que são dependências dos itens
	aDependecyModels:= oModel:getDependency("SWVDETAIL")

	aModels:= {}
	AEval(aDependecyModels, {|aModel| AAdd(aModels, aModel[MODEL_STRUCT_ID])} )

return aClone(aModels)

/*/{Protheus.doc} checkItems
Verifica se o item da DUIMP é real; se for apenas um item gerado pelo instanciamento do modelo sem vínculo com o produto (item) da invoice, exclui o registro do modelo
@type function
@version  
@author wilsimar
@since 8/29/2025
@param oModSWV, object, modelo de dados SWVDETAIL
@return true se fez a exclusão da linha, false se não fez
/*/
Static Function checkItems(oModSWV)
	local cPurchaseOrder as character
	local lExcluded as logical

	cPurchaseOrder:= oModSWV:getValue("WV_PO_NUM")

	lExcluded:= .F.
	if empty(cPurchaseOrder)
		lExcluded:= oModSWV:DeleteLine()
	endIf

Return lExcluded

/*/{Protheus.doc} LP501WVNCM
Função para ser chamada de outro fonte (addSwvDetail)

@type function
@version  
@author wilsimar
@since 8/29/2025
@param oModel, object, modelo de dados principal
@param lAddItems, logical, indica se deve adicionar os itens
@param cHawb, character, processo
@param cInvoice, character, invoice
@return variant, lógico, .T. se sucesso, .F. se erro
/*/
Function LP501WVNCM(oModel, lAddItems, cHawb, cInvoice, lSetNCM)
Return addSwvDetail(oModel, lAddItems, cHawb, cInvoice, lSetNCM)

/*/{Protheus.doc} addSwvDetail
Adicionar ou atualizar os itens da DUIMP (SWVDETAIL) a partir dos itens da Invoice (SW8)
@type function
@version  
@author wilsimar
@since 8/29/2025
@param oModel, object, modelo de dados principal
@param lAddItems, logical, indica se deve adicionar os itens
@param cHawb, character, processo
@param cInvoice, character, invoice
@return variant, lógico, .T. se sucesso, .F. se erro
/*/
Static Function addSwvDetail(oModel, lAddItems, cHawb, cInvoice, lSetNCM)
	Local lRet as logical

	lRet:= .F.
	//a atualização dos itens da DUIMP será feita a partir dos itens da Invoice
	SW8->(DBSetOrder(6)) //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
	if SW8->(DbSeek(xFilial("SW8") + cHawb + cInvoice))
		while SW8->(!Eof()) .and.;
				SW8->W8_FILIAL == xFilial("SW8") .and.;
				SW8->W8_HAWB == cHawb .and.;
				SW8->W8_INVOICE == cInvoice

			lRet:= updSwvDetail(oModel, lAddItems, lSetNCM)

			// Processar os registros encontrados
			SW8->(DbSkip())
		enddo
	endIf

Return lRet

/*/{Protheus.doc} updSwvDetail
Atualização dos itens da DUIMP (SWVDETAIL) 
@type function
@version  
@author wilsimar
@since 8/29/2025
@param oModel, object, modelo de dados principal
@param lAddItems, logical, indica se deve adicionar os itens
@return variant, lógico, .T. se sucesso, .F. se erro
/*/
Static Function updSwvDetail(oModel, lAddItems, lSetNCM, cSequencia, nQtdSW8)
	Local lRet as logical
	Local lSeek as logical
	Local aSeek as array
	local oModelSWV as object
	local nPos as numeric
	local nSW8Recno as numeric
	local cWVId as character
	local lVisualiza as logical
	local nQtdSWV as numeric
	local nQtdSW8Tot as numeric
	local nQtdSWVTot as numeric
	local nQtdSW8Atu as numeric
	local nSaldoSWV as numeric

	default lSetNCM := .F.
	default cSequencia := ""
	default nQtdSW8 := 0

	oModelSWV:= oModel:getModel("SWVDETAIL")
	lRet:= .F.
	nQtdSWV := 0

	if empty(cSequencia)
		cSequencia := strZero(1, AVSX3("WV_SEQUENC",3))
	endif

	nSW8Recno := SW8->(RecNo())

	if lAddItems

		SW3->(DBSetOrder(8)) //W3_FILIAL+W3_PO_NUM+W3_POSICAO

		//inclusão dos itens a partir do item da Invoice
		lRet := addline(oModelSWV)

		SW8->(dbgoto(nSW8Recno))
		if nQtdSW8 == 0
			nQtdSW8 := SW8->W8_QTDE
		endif

		lRet := lRet .and. oModelSWV:SetValue("WV_CC", SW8->W8_CC)
		lRet := lRet .and. oModelSWV:SetValue("WV_SI_NUM", SW8->W8_SI_NUM)
		lRet := lRet .and. oModelSWV:SetValue("WV_PO_NUM", SW8->W8_PO_NUM)
		lRet := lRet .and. oModelSWV:SetValue("WV_PGI_NUM", SW8->W8_PGI_NUM)
		lRet := lRet .and. oModelSWV:SetValue("WV_INVOICE", SW8->W8_INVOICE)
		lRet := lRet .and. oModelSWV:SetValue("WV_POSICAO", SW8->W8_POSICAO)
		lRet := lRet .and. oModelSWV:SetValue("WV_REG", SW8->W8_REG)
		lRet := lRet .and. oModelSWV:SetValue("WV_FORN", SW8->W8_FORN)
		lRet := lRet .and. oModelSWV:SetValue("WV_FORLOJ", SW8->W8_FORLOJ)
		lRet := lRet .and. oModelSWV:SetValue("WV_COD_I", SW8->W8_COD_I)
		lRet := lRet .and. oModelSWV:SetValue("WV_NCM", SW8->W8_TEC)
		lRet := lRet .and. oModelSWV:SetValue("WV_EX_NCM", SW8->W8_EX_NCM)
		lRet := lRet .and. oModelSWV:SetValue("WV_SEQUENC", cSequencia)
		lRet := lRet .and. oModelSWV:SetValue("WV_QTDE", nQtdSW8)
		lRet := lRet .and. oModelSWV:SetValue("WV_DESC_DI", LP500GetInfo("SB1", 1, XFILIAL("SB1") + SW8->W8_COD_I, "B1_DESC",,, "WV_DESC_DI"))
		lRet := lRet .and. oModelSWV:SetValue("WV_SEQDUIM", getSeqDuimp())
		lRet := lRet .and. oModelSWV:SetValue("WV_CODREG", getRegTrb(SW8->W8_PO_NUM, SW8->W8_POSICAO, SW8->W8_COD_I, SW6->W6_DEST, SW6->W6_PAISPRO))
		lRet := lRet .and. oModelSWV:SetValue("WV_MODAL", AtoDuimp("WV_MODAL"))
		lRet := lRet .and. oModelSWV:SetValue("WV_AC", AtoDuimp("WV_AC"))
		lRet := lRet .and. oModelSWV:SetValue("WV_SEQSIS", AtoDuimp("WV_SEQSIS"))
		lRet := lRet .and. oModelSWV:SetValue("WV_LPCOPND", LP500PdLPCO(oModel))
	
		updateSubModels(oModel, oModelSWV:getValue("WV_ID"), SW8->W8_COD_I, SW8->W8_TEC, lAddItems)

		lRet:= .T.
	else

		SW8->(dbgoto(nSW8Recno))
		if nQtdSW8 == 0
			nQtdSW8 := SW8->W8_QTDE
			nQtdSW8Tot := nQtdSW8
		endif

		//atualização dos itens da DUIMP a partir do item da Invoice
		aSeek:= {}
		aadd(aSeek, {"WV_FILIAL" , xFilial("SWV")})
		aadd(aSeek, {"WV_HAWB"   , SW8->W8_HAWB})
		aadd(aSeek, {"WV_INVOICE", SW8->W8_INVOICE})
		aadd(aSeek, {"WV_FORN"   , SW8->W8_FORN})
		aadd(aSeek, {"WV_FORLOJ" , SW8->W8_FORLOJ})
		aadd(aSeek, {"WV_PO_NUM" , SW8->W8_PO_NUM})
		aadd(aSeek, {"WV_POSICAO", SW8->W8_POSICAO})
		aadd(aSeek, {"WV_SEQUENC", cSequencia})	

		//primeiro deve-se verificar se o item da Invoice refere-se há um item existente da DUIMP
		//caso não encontre, deve-se incluir um novo item
		//chamada recursiva
		lSeek := oModelSWV:SeekLine(aSeek , .F., .T.)
		If !lSetNCM .And. !lSeek
			updSwvDetail(oModel, !lSeek)
		endIf

		//caso encontre, deve-se atualizar as informações dos complementos do item da DUIMP
		//devem ser consideradas as quebras de sequência do item na SWV
		nPos:= AScan(aSeek, {|x| x[1] == "WV_SEQUENC"})
		lVisualiza := oModel:GetOperation() == MODEL_OPERATION_VIEW
		nQtdSWVTot := 0
		nSaldoSWV := 0
		While lSeek

			nQtdSWV := oModelSWV:GetValue("WV_QTDE")
			nQtdSWVTot += nQtdSWV
			nQtdSW8 -= nQtdSWV

			//campos convertidos para real e que podem ser modificados no item do desembaraço
			If lSetNCM .And. lVisualiza
				oModelSWV:LoadValue("WV_NCM", SW8->W8_TEC)
				oModelSWV:LoadValue("WV_EX_NCM", SW8->W8_EX_NCM)
			Else
				lRet := oModelSWV:SetValue("WV_NCM", SW8->W8_TEC)
				lRet := lRet .and. oModelSWV:SetValue("WV_EX_NCM", SW8->W8_EX_NCM)
				if lRet .and. SW6->W6_FORMREG == DUIMP_INTEGRADA
					lRet := oModelSWV:LoadValue("WV_SEQDUIM", getSeqDuimp())
				endif

				// se quantidade do item na invoice for negativo, significa que a quantidade na swv era maior, deverá atualizar a quantidade na swv com a quantidade da invoice
				if nQtdSW8 < 0 .and. nQtdSWVTot > nQtdSW8Tot
					nQtdSW8Atu := nQtdSW8Tot - nSaldoSWV
					lRet := oModelSWV:SetValue("WV_QTDE", nQtdSW8Atu )
					LP500SetVar(,'__oLstQtdInf','SET',  oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC") , nQtdSW8Atu )
				endif
				nSaldoSWV += nQtdSWV
			EndIf

			If !lSetNCM
				//para tratar cenário onde o processo do tipo DI contendo controle de lote foi convertido para DUIMP
				//***** precisa ser testado para comprovar se resolve o cenário *****
				cWVId:= oModelSWV:getValue("WV_ID")
				if empty(cWVId)
					lRet := lRet .and. oModelSWV:SetValue("WV_ID" , LP500ini("WV_ID"))

					// caso não tenha sido gravado ainda o WV_ID
					lRet := lRet .and. oModelSWV:SetValue("WV_CODREG", getRegTrb(SW8->W8_PO_NUM, SW8->W8_POSICAO, SW8->W8_COD_I, SW6->W6_DEST, SW6->W6_PAISPRO))
					lRet := lRet .and. oModelSWV:SetValue("WV_MODAL", AtoDuimp("WV_MODAL"))
					lRet := lRet .and. oModelSWV:SetValue("WV_AC", AtoDuimp("WV_AC"))
					lRet := lRet .and. oModelSWV:SetValue("WV_SEQSIS", AtoDuimp("WV_SEQSIS"))
					lRet := lRet .and. oModelSWV:SetValue("WV_LPCOPND", LP500PdLPCO(oModel))
				endif

				//atualização dos submodelos, relacionados à SWVDETAIL
				updateSubModels(oModel, cWVId, SW8->W8_COD_I, SW8->W8_TEC, lAddItems)
			EndIf
			cSequencia:= SomaIt(cSequencia)
			aSeek[nPos, 2]:= cSequencia
			lSeek := oModelSWV:SeekLine(aSeek , .F., .T.)
			
			// Caso tenha encontrado com a proxima sequencia
			if lSeek .and. nQtdSW8 <= 0
				while lSeek
					LP500SetVar(,'__oLstQtdInf','SET',  oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC") , 0 )
					lRet := delModSWV(oModelSWV)
					cSequencia:= SomaIt(cSequencia)
					aSeek[nPos, 2]:= cSequencia
					lSeek := oModelSWV:SeekLine(aSeek , .F., .T.)
				end
			endif 

		EndDo

		// Adiciona o restante da quantidade do item dentro do lote
		if nQtdSWV > 0 .and. nQtdSW8 > 0 .and. !lSetNCM .and. !lSeek .and. !lVisualiza
			lRet := updSwvDetail(oModel,  !lSeek, , cSequencia, nQtdSW8)
		endif

		lRet:= .T.
	endIf

Return lRet

/*/{Protheus.doc} getRegTrb
Utilizada para chamar a função getRegTrb do programa EICLP500 a partir do EICLP501
Primeiro posicionará no item do Purchase Order (SW3) para recuperar o código do regime de tributação desta fase
@type static function
@version  
@author wilsimar
@since 9/1/2025
@param cPoNum, character, código do Purchase Order
@param cPosicao, character, posição do item no Purchase Order
@param cCodItem, character, código do produto
@param cDestino, character, destino da importação, conforme via de transporte
@param cPaisPro, character, país de procedência
@return variant, código do regime de tributação DUIMP
/*/
Static Function getRegTrb(cPoNum, cPosicao, cCodItem, cDestino, cPaisPro)
	local cCodRegime := ""

	SW3->(DbSeek(xFilial("SW3") + cPoNum + cPosicao))
	cCodRegime := if(!empty(SW3->W3_CODREG), SW3->W3_CODREG, TRB100GetEKR(cCodItem, cDestino, .T., cPaisPro))

return cCodRegime

/*/{Protheus.doc} getSeqDuimp
description
@type function
@version  
@author wilsimar
@since 9/1/2025
@return variant, return_description
/*/
Static Function getSeqDuimp()
	local nSeqDuimp as numeric
	local cSeqDuimp as character

	cSeqDuimp:= ""
	if SW6->W6_FORMREG == DUIMP_INTEGRADA
		nSeqDuimp:= LP500NextSeqDUIMP()
		cSeqDuimp:= strZero(nSeqDuimp, AVSX3("WV_SEQDUIM", AV_TAMANHO))
	endIf

Return cSeqDuimp

/*/{Protheus.doc} AtoDuimp
Recuperar as informações do ato concessório para o item da DUIMP
@type function
@version  
@author 
@since 
@param cCampo, character, param_description
@return variant, return_description
/*/
Static Function AtoDuimp(cCampo)
	Local cRet := ""
	Local lDrawBack := EasyGParam("MV_EIC_EDC",,".F.")

	If lDrawBack
		Do Case
			Case cCampo == "WV_AC"
				cRet := SW8->W8_AC
			Case cCampo == "WV_SEQSIS"
				cRet := SW8->W8_SEQSIS
			Case cCampo == "WV_MODAL"
				cRet := If(!Empty(SW8->W8_AC), Posicione("ED0", 2, xFilial("ED0") + SW8->W8_AC, "ED0_MODAL"), " ")
		EndCase
	Else
		Do Case
			Case cCampo == "WV_AC"
				cRet := Posicione("SW4", 1, xFilial("SW4") + SW8->W8_PGI_NUM, "W4_ATO_CON")
			OtherWise
				cRet := avKey("", cCampo)
		EndCase
	endIf

Return cRet

/*/{Protheus.doc} updateSubModels
Atualização das informações dos submodelos dependentes da SWVDETAIL - complemento dos itens da DUIMP
@type function
@version  
@author wilsimar
@since 9/1/2025
@param oModel, object, modelo de dados principal
@param cProduto, character, código do produto do item da DUIMP
@param cNcm, character, código NCM do item da DUIMP
@param lAddNewItem, logical, variável que indicará se estamos incluindo ou atualizando um item
@return variant, return_description
/*/
Static Function updateSubModels(oModel, cIdSWVLote, cProduto, cNcm, lAddNewItem)
	local aModels as array
	local nTotalModels as numeric
	local nModel as numeric
	local oSubModel as object
	local cModel as character
	local nSW8Recno as numeric 

	default cIdSWVLote := ""

	nSW8Recno := SW8->(RecNo())
	//régua de progresso
	incProc(cProduto)

	//recupera os submodelos que devem ser gravados
	aModels:= getModelsUpdate(oModel)
	nTotalModels:= len(aModels)

	for nModel:= 1 to nTotalModels

		cModel:= aModels[nModel]
		oSubModel:= oModel:getModel(cModel)

		do Case

			Case cModel == "EKQDETAIL"

				//os formulários LPCO serão adicionados apenas quando for a inclusão de um item
				if lAddNewItem .or. empty(cIdSWVLote)
					updEKQDetail(oSubModel, cProduto, cNcm)
				endIf

			Case cModel == "EIJMASTER"

				if !lAddNewItem
					//verificar se o item já possui EIJ_IDWV preenchido, caso não, é como se fosse uma inclusão
					lAddNewItem := empty(oSubModel:getValue("EIJ_IDWV"))
				endif

				updEIJDetail(oModel, oSubModel, lAddNewItem)

			// Case cModel == "EIKDETAIL"

			// 	updEIKDetail(oSubModel)

			// Case cModel == "EINADETAIL"

			// 	updEINADetail(oSubModel)

			// Case cModel == "EINDDETAIL"

			// 	updEINDDetail(oSubModel)

			// Case cModel == "EJ9DETAIL"

			// 	updEJ9Detail(oSubModel)

			Case cModel == "EKWGRID_II"

				updEKWDetail(oModel, oSubModel, "1", lAddNewItem, cIdSWVLote)

			Case cModel == "EKWGRID_IPI"

				updEKWDetail(oModel, oSubModel, "2", lAddNewItem, cIdSWVLote)

			Case cModel == "EKWGRID_PIS"

				updEKWDetail(oModel, oSubModel, "3", lAddNewItem, cIdSWVLote)

			Case cModel == "EKWGRID_COFINS"

				updEKWDetail(oModel, oSubModel, "4", lAddNewItem, cIdSWVLote)

			Case cModel == "EKWGRID_ANTIDUMPING"

				updEKWDetail(oModel, oSubModel, "5", lAddNewItem, cIdSWVLote)

			Case cModel == "EKXMASTER"

				updEKXDetail(oModel , oSubModel, lAddNewItem)

		EndCase

	next

	SW8->(dbgoto(nSW8Recno))

Return

/*/{Protheus.doc} updEKQDetail
Vinculação od formulários LPCO aos itens da DUIMP
@type function
@version  
@author wilsimar
@since 9/8/2025
@param oModelEKQ, object, submodelo de dados referente aos formulários LPCO
@param cProduto, character, código do produto do item da DUIMP
@param cNcm, character, código NCM do item da DUIMP
@return variant, return_description
/*/
static function updEKQDetail(oModelEKQ, cProduto, cNcm)
local aForms as array
local nPosNcm as numeric
local lFirstData as logical
local nForm as numeric
local nPosProduto as numeric
local lRet as logical

	aForms:= lp500LPCO("GET") // o SET está no activate do modelo
	nPosNcm:= AScan(aForms, {|x| x[1] == cNcm })
	lFirstData:= .T.
	lRet := .T.

	//Existem Formulários para carregar para o item
	If nPosNcm > 0
		lFirstData := oModelEKQ:Length(.T.) == 1 .and. empty(oModelEKQ:getValue("EKQ_ORGANU"))
		For nForm := 1 To Len(aForms[nPosNcm][2])

			if lFirstData
				lFirstData:= .F.
			else
				lRet := AddLine(oModelEKQ)
			endIf

			lRet := lRet .and. oModelEKQ:SetValue("EKQ_ORGANU", aForms[nPosNcm][2][nForm][1] )	
			lRet := lRet .and. oModelEKQ:SetValue("EKQ_FRMLPC", aForms[nPosNcm][2][nForm][2] )
			lRet := lRet .and. oModelEKQ:SetValue("EKQ_OBRFRM", iif( (nPosProduto:= AScan(aForms[nPosNcm][2][nForm][4], {|x| x[1] == cProduto} )) > 0, aForms[nPosNcm][2][nForm][4][nPosProduto][2], aForms[nPosNcm][2][nForm][3] ) )

		Next
	else
		//excluir as linhas em branco do modelo
		//oModelEKQ:deleteLine()
	endIf

Return

/*/{Protheus.doc} updEIJDetail
Atualização dos dados do submodelo EIJDETAIL - detalhes dos itens da DUIMP
@type function
@version  
@author wilsimar
@since 9/10/2025
@param oModel, object, modelo de dados principal
@param oModelEIJ, object, submodelo EIJ
@param lAddNewItem, logical, variável que indicará se estamos incluindo ou atualizando um item
@return variant, return_description
/*/
static function updEIJDetail(oModel, oModelEIJ, lAddNewItem)
local oModelSWV as object
local oModelSW9 as object
local aFields as array
local nField as numeric
local cField as character
local cUnid_Ncm as character
Local lRegTrib as logical
local lTribDUIMP as logical
local lClassTrib as logical
local xSetValue as variant
local cCnpjRaiz  as character
local cRegime as character
local cTpAliq as character
local aDados as array
local xOldValue as variant
local aDadosSW8 as array
Local lAplicaII  := .T. as logical
Local lAplicaIPI := .T. as logical
Local lAplicaPIS := .T. as logical
Local lAplicaCOF := .T. as logical
Local lAplicaADU := .T. as logical
Local lAplicaICM := .T. as logical
Local lPUProduc := EasyGParam("MV_EIC0074",.F.,"1") == "1" as logical

	lTribDUIMP:= avFlags("TRIBUTACAO_DUIMP")
	lRegTrib  := AvFlags("REGIME_TRIBUTACAO_DUIMP")
	lClassTrib:= AvFlags("REFORMA_CCLASSTRIB")
	oModelSWV := oModel:getModel("SWVDETAIL")
	oModelSW9 := oModel:getModel("SW9DETAIL")
	LP500Aplic(oModelSWV:getValue("WV_CODREG"), lClassTrib, lRegTrib, oModelSWV, @lAplicaII, @lAplicaIPI, @lAplicaPIS, @lAplicaCOF, @lAplicaADU, @lAplicaICM, .T., .T.)

	aFields:= getFielsEIJ(lAddNewItem, oModelEIJ)

	for nField:= 1 to len(aFields)

		cField:= aFields[nField]

		if !lAddNewItem
			xOldValue:= oModelEIJ:getValue(cField)
			xSetValue:= xOldValue
		else
			xSetValue:= nil
		endIf

		do Case

			case cField == "EIJ_IDWV"

				//para tratar cenário onde o processo do tipo DI contendo controle de lote foi convertido para DUIMP
				//***** precisa ser testado para comprovar se resolve o cenário *****
				xSetValue:= oModelEIJ:getValue("EIJ_IDWV")
				if empty(xSetValue)
					xSetValue:= oModelSWV:getValue("WV_ID")
				endIf

			case cField == "EIJ_HAWB"

				xSetValue:= oModelSWV:getValue("WV_HAWB")

			case cField == "EIJ_PO_NUM"

				xSetValue:= oModelSWV:getValue("WV_PO_NUM")

			case cField == "EIJ_DSCCIT"

				xSetValue := ""
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_DESC_DI", "W8_COD_I"})
				If Len(aDadosSW8) > 0
					If !EMPTY(aDadosSW8[1])
						xSetValue := MSMM(aDadosSW8[1], AvSx3("W8_DESC_VM", 3))
					endIf
				endIf

			case cField == "EIJ_QT_EST"
				aDadosSW8:= LP500GetW7W8(oModelSWV, {"W8_UNID"})
				xSetValue:= 0
				if Len(aDadosSW8) > 0 .and. !empty(oModelSWV:getValue("WV_NCM"))
					cUnid_Ncm := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + if( avFlags("REGIME_TRIBUTACAO_DUIMP"), oModelSWV:getValue("WV_EX_NCM"), ""), "YD_UNID",,, "EIJ_UNDEST")
					xSetValue := AVTransUnid( aDadosSW8[1], cUnid_Ncm, oModelSWV:getValue("WV_COD_I"), oModelSWV:getValue("WV_QTDE") )
				endIf

			case cField == "EIJ_PESOL"
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W7_PESO"})
				xSetValue := 0
				if Len(aDadosSW8) > 0
					xSetValue := DI500TRANS( aDadosSW8[1] * oModelSWV:getValue("WV_QTDE"), AvSX3("EIJ_PESOL", AV_DECIMAL) )
				endIf

			case cField == "EIJ_MOEDA"
				xSetValue := oModelSW9:getValue("W9_MOE_FOB")

			case cField = "EIJ_VLMLE"
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_PRECO"})
				xSetValue := 0
				If Len(aDadosSW8) > 0
					xSetValue := aDadosSW8[1]
				endIf

			case cField == "EIJ_FABFOR"
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FABR", "W8_FABLOJ", "W8_FORN", "W8_FORLOJ"})
				xSetValue := ""
				If Len(aDadosSW8) > 0
					xSetValue := '2'
					If aDadosSW8[1] + aDadosSW8[2] == aDadosSW8[3] + aDadosSW8[4]
						xSetValue := '1'
					endIf
				endIf

			case cField == "EIJ_FABR"
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FABR"})
				xSetValue := ""
				If Len(aDadosSW8) > 0
					xSetValue := aDadosSW8[1]
				endIf

			case cField == "EIJ_FABLOJ"
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FABR", "W8_FABLOJ"})
				xSetValue := ""
				If Len(aDadosSW8) > 0
					xSetValue := aDadosSW8[2]
				endIf

			case cField == "EIJ_TINFA"
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FABR", "W8_FABLOJ"})
				xSetValue := ""
				If Len(aDadosSW8) > 0
					cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT") + AvKey(SW6->W6_IMPORT, "YT_COD_IMP"), "YT_CGC" ) , 8 )
					xSetValue := LP500OpEst("EKJ_TIN", cCnpjRaiz, aDadosSW8[1], aDadosSW8[2])
					if !empty(xSetValue) .and. empty(EKJ->EKJ_VERSAO)
						xSetValue := ""
					endif
				endIf

			case cField == "EIJ_VRSFAB"
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FABR", "W8_FABLOJ"})
				xSetValue := ""
				If Len(aDadosSW8) > 0
					cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT") + AvKey(SW6->W6_IMPORT, "YT_COD_IMP"), "YT_CGC" ) , 8 )
					xSetValue := LP500OpEst("EKJ_VERSAO", cCnpjRaiz, aDadosSW8[1], aDadosSW8[2])
				endIf

			case cField == "EIJ_PAISOR"
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FABR", "W8_FABLOJ"})
				xSetValue := ""
				If Len(aDadosSW8) > 0
					xSetValue := LP500GetInfo("SA2", 1, xFilial("SA2") + aDadosSW8[1] + aDadosSW8[2], "A2_PAIS")
				endIf

			case cField == "EIJ_FORN"
				xSetValue := ""
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FORN"})
				If Len(aDadosSW8) > 0
					xSetValue := aDadosSW8[1]
				endIf

			case cField == "EIJ_FORLOJ"
				xSetValue := ""
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FORN", "W8_FORLOJ"})
				If Len(aDadosSW8) > 0
					xSetValue := aDadosSW8[2]
				endIf

			case cField == "EIJ_TINFO"
				xSetValue := ''
				// Caso ja esteja informado o EIJ_TINFO, não deve ser atualizado pois é uma duimp manual
				if !lAddNewItem .and. !empty(xOldValue) .and. SW6->W6_FORMREG == DUIMP_MANUAL
					xSetValue := xOldValue
				endif

				if empty(xSetValue)
					aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FORN", "W8_FORLOJ"})
					if Len(aDadosSW8) > 0
						cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT") + AvKey(SW6->W6_IMPORT, "YT_COD_IMP"), "YT_CGC" ) , 8 )
						xSetValue := LP500OpEst("EKJ_TIN", cCnpjRaiz, aDadosSW8[1], aDadosSW8[2])
						if !empty(xSetValue) .and. empty(EKJ->EKJ_VERSAO)
							xSetValue := ""
						endif
					endif
				endif

			case cField == "EIJ_VRSFOR"
				xSetValue := ''
				// Caso ja esteja informado a EIJ_VRSFOR, não deve ser atualizado pois é uma duimp manual
				if !lAddNewItem .and. !empty(xOldValue) .and. SW6->W6_FORMREG == DUIMP_MANUAL
					xSetValue := xOldValue
				endif

				if empty(xSetValue)
					aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FORN", "W8_FORLOJ"})
					If Len(aDadosSW8) > 0
						cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT") + AvKey(SW6->W6_IMPORT, "YT_COD_IMP"), "YT_CGC" ) , 8 )
						xSetValue := LP500OpEst("EKJ_VERSAO", cCnpjRaiz, aDadosSW8[1], aDadosSW8[2])
					endIf
				endif

			case cField == "EIJ_PAISPR"
				aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_FORN", "W8_FORLOJ"})
				xSetValue := ""
				If Len(aDadosSW8) > 0
					xSetValue := LP500GetInfo("SA2", 1, xFilial("SA2") + aDadosSW8[1] + aDadosSW8[2], "A2_PAIS")
				endIf

			case cField == "EIJ_INCOTE"
				xSetValue := oModelSW9:getValue("W9_INCOTER")

			case cField == "EIJ_TIPCOB"
				xSetValue := LP500GetInfo("SY6", 1, xFilial("SY6") + oModelSW9:getValue("W9_COND_PA"), "Y6_TIPOCOB")

			case cField == "EIJ_MODALI"
				xSetValue := LP500GetInfo("SY6", 1, xFilial("SY6") + oModelSW9:getValue("W9_COND_PA"), "Y6_TABELA")

			case cField == "EIJ_MOTIVO"
				xSetValue := LP500GetInfo("SY6", 1, xFilial("SY6") + oModelSW9:getValue("W9_COND_PA"), "Y6_MOTIVO")

			case cField == "EIJ_VL_FIN"
				If LP500GetInfo("SY6", 1, xFilial("SY6") + oModelSW9:getValue("W9_COND_PA"), "Y6_TIPOCOB") == '4'
					xSetValue := 0
				Else
					aDadosSW8 := LP500GetW7W8(oModelSWV, {"W8_PRECO"})
					xSetValue:= 0
					If Len(aDadosSW8) > 0
						xSetValue:= aDadosSW8[1]
					endIf
					xSetValue := DI500Trans(oModelSWV:getValue("WV_QTDE") * xSetValue )
				endIf

			case cField == "EIJ_CODREG"
				xSetValue := oModelSWV:getValue("WV_CODREG")
				If lClassTrib .And. !Empty(xSetValue)
					setClasTrb(oModelSWV, xSetValue, lPUProduc, lRegTrib)
				EndIf

			case cField == "EIJ_REGTRI"
				xSetValue := IIF(lAplicaII, LP500retCp( "", "EKR_REGTRI", oModelSWV, "1", cField, lRegTrib ), "1")

			case cField == "EIJ_FUNREG"
				xSetValue := LP500retCp( "", "EKR_FUNREG", oModelSWV, , cField, lRegTrib )

			case cField == "EIJ_TPAII"
				xSetValue := IIF(lAplicaII, LP500retCp( "", "EKR_TPAII", oModelSWV, "1", cField, lRegTrib ), "1") // 1-Ad Valorem por padrão

			case cField == "EIJ_ALI_II"
				if lRegTrib .and. lTribDUIMP
					cRegime := LP500retCp( "", "EKR_REGTRI", oModelSWV, "1", "EIJ_REGTRI", .T. )
					cTpAliq := LP500retCp( "", "EKR_TPAII", oModelSWV, "1", "EIJ_TPAII", .T. )
					aDados := LP500GetAl("II", oModelSWV:getValue("WV_CODREG"), cRegime, cTpAliq, oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaII, .T., cField)
					xSetValue := 0
					if len(aDados) > 0
						xSetValue := aDados[1][2]
					endIf
				else
					xSetValue := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + if( lRegTrib , oModelSWV:getValue("WV_EX_NCM") ,""), "YD_PER_II" )
					xSetValue := IIF(lAplicaII, LP500retCp( "", "EKR_ALI_II", oModelSWV, xSetValue , cField, lRegTrib ), xSetValue)
				endIf

			case cField == "EIJ_REGIPI"
				xSetValue := IIF(lAplicaIPI, LP500retCp( "", "EKR_REGIPI", oModelSWV, if(lTribDUIMP,"1", nil), cField, lRegTrib ), if(lTribDUIMP,"1", nil))

			case cField == "EIJ_ASSIPI"
				xSetValue := LP500retCp( "", "EKR_ASSIPI", oModelSWV, , cField, lRegTrib )

			case cField == "EIJ_TPAIPI"
				xSetValue := IIF(lAplicaIPI, LP500retCp( "", "EKR_TPAIPI", oModelSWV, "1", cField, lRegTrib ), "1") // 1-Ad Valorem por padrão

			case cField == "EIJ_ALAIPI"
				if lRegTrib .and. lTribDUIMP
					cRegime := LP500retCp( "", "EKR_REGIPI", oModelSWV, if(lTribDUIMP,"1", nil), "EIJ_REGIPI", .T. )
					cTpAliq := LP500retCp( "", "EKR_TPAIPI", oModelSWV, "1" , "EIJ_TPAIPI", .T. )
					aDados := LP500GetAl("IPI", oModelSWV:getValue("WV_CODREG"), cRegime, cTpAliq, oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaIPI, .T., cField)
					xSetValue := 0
					if len(aDados) > 0
						xSetValue := aDados[1][2]
					endIf
				else
					xSetValue := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + if( lRegTrib , oModelSWV:getValue("WV_EX_NCM") ,""), "YD_PER_IPI")
					xSetValue := IIF(lAplicaIPI, LP500retCp( "", "EKR_ALAIPI", oModelSWV, xSetValue , cField, lRegTrib ), xSetValue)
				endIf

			case cField == "EIJ_ALUIPI"
				xSetValue := 0
				If lAplicaIPI
					cRegime := LP500retCp( "", "EKR_REGIPI", oModelSWV, "1", "EIJ_REGIPI", lRegTrib )
					cTpAliq := LP500retCp( "", "EKR_TPAIPI", oModelSWV, "1", "EIJ_TPAIPI", lRegTrib )
					if lTribDUIMP .and. LP500UseAl("IPI", "ESPECIFICA", cRegime, cTpAliq)
						xSetValue := LP500retCp( oModelSWV:getValue("WV_CODREG"), "EKR_ALUIPI",,,,.T. )
					endIf
				EndIf

			case cField == "EIJ_REG_PC"
				xSetValue := LP500retCp( "", "EKR_REG_PC", oModelSWV, , cField, lRegTrib )

			case cField == "EIJ_FUN_PC"
				xSetValue := LP500retCp( "", "EKR_FUN_PC", oModelSWV, , cField, lRegTrib )

			case cField == "EIJ_REGPIS"
				xSetValue := IIF(lAplicaPIS, LP500retCp( "", "EKR_REGPIS", oModelSWV, "1", cField, lRegTrib ), "1")

			case cField == "EIJ_TPAPIS"
				xSetValue := IIF(lAplicaPIS, LP500retCp( "", "EKR_TPAPIS", oModelSWV, "1", cField, lRegTrib ), "1") //1-Ad Valorem por padrão

			case cField == "EIJ_ALAPIS"
				if lRegTrib .and. lTribDUIMP
					cRegime := LP500retCp( "", "EKR_REGPIS", oModelSWV, "1", "EIJ_REGPIS", .T. )
					cTpAliq := LP500retCp( "", "EKR_TPAPIS", oModelSWV, "1", "EIJ_TPAPIS", .T. )
					aDados := LP500GetAl("PIS", oModelSWV:getValue("WV_CODREG"), cRegime, cTpAliq, oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaPIS, .T., cField)
					xSetValue := 0
					if len(aDados) > 0
						xSetValue := aDados[1][2]
					endIf
				else
					xSetValue := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + if( lRegTrib , oModelSWV:getValue("WV_EX_NCM") ,""), "YD_PER_PIS")
					xSetValue := IIF(lAplicaPIS, LP500retCp( "", "EKR_ALAPIS", oModelSWV, xSetValue , cField, lRegTrib ), xSetValue)
				endIf

			case cField == "EIJ_REGCOF"
				xSetValue := IIF(lAplicaCOF, LP500retCp( "", "EKR_REGCOF", oModelSWV, "1", cField, lRegTrib ), "1")

			case cField == "EIJ_TPACOF"
				xSetValue := IIF(lAplicaCOF, LP500retCp( "", "EKR_TPACOF", oModelSWV, "1", cField, lRegTrib ), "1") //1-Ad Valorem por padrão"

			case cField == "EIJ_ALACOF"
				if lRegTrib .and. lTribDUIMP
					cRegime := LP500retCp( "", "EKR_REGCOF", oModelSWV, "1", "EIJ_REGCOF", .T. )
					cTpAliq := LP500retCp( "", "EKR_TPACOF", oModelSWV, "1", "EIJ_TPACOF", .T. )
					aDados := LP500GetAl("COFINS", oModelSWV:getValue("WV_CODREG"), cRegime, cTpAliq, oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaCOF, .T., cField)
					xSetValue := 0
					if len(aDados) > 0
						xSetValue := aDados[1][2]
					endIf
				else
					xSetValue := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + if( lRegTrib , oModelSWV:getValue("WV_EX_NCM") ,""), "YD_PER_COF")
					xSetValue := IIF(lAplicaCOF, LP500retCp( "", "EKR_ALACOF", oModelSWV, xSetValue , cField, lRegTrib ), xSetValue)
				endIf

			case cField == "EIJ_OPERAC"
				xSetValue := IIF(lAplicaICM, LP500retCp( "", "EKR_OPERAC", oModelSWV, , cField, lRegTrib ), "")

			case cField == "EIJ_APLICM"
				xSetValue := LP500retCp( "", "EKR_TPAPLI", oModelSWV, , cField, lRegTrib )

			case cField == "EIJ_MATUSA"
				xSetValue := LP500retCp( "", "EKR_MATUSA", oModelSWV, , cField, lRegTrib )

			case cField == "EIJ_FUNII"
				xSetValue := LP500FundL( "ii", "EKR_FUNII", oModelSWV, cField, lRegTrib, oModel, lAPlicaII )

			case cField == "EIJ_FUNIPI"
				xSetValue := LP500FundL( "ipi", "EKR_FUNIPI", oModelSWV, cField, lRegTrib, oModel, lAplicaIPI )

			case cField == "EIJ_FUNPIS"
				xSetValue := LP500FundL( "pis", "EKR_FUNPIS", oModelSWV, cField, lRegTrib, oModel, lAplicaPIS )

			case cField == "EIJ_FUNCOF"
				xSetValue := LP500FundL( "cofins", "EKR_FUNCOF", oModelSWV, cField, lRegTrib, oModel, lAplicaCOF )

			case cField == "EIJ_FUNADU"
				xSetValue := LP500FundL( "antidumping", "EKR_FUNADU", oModelSWV, cField, lRegTrib, oModel, lAplicaADU )

			case cField == "EIJ_REDPIS"
				cRegime := ""
				cTpAliq := "1"
				if !empty(oModelSWV:getValue("WV_CODREG"))
					cRegime := if( lTribDUIMP, LP500retCp( "", "EKR_REGPIS", oModelSWV, "1" , "EIJ_REGPIS", lRegTrib ), LP500retCp( "", "EKR_REG_PC", oModelSWV, "" , "EIJ_REG_PC", lRegTrib ))
					cTpAliq := LP500retCp( "", "EKR_TPAPIS", oModelSWV, "1", "EIJ_TPAPIS", lRegTrib )
				endIf
				aDados := LP500GetAl("PIS", oModelSWV:getValue("WV_CODREG"), cRegime, cTpAliq, oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaPIS, .T., cField)
				xSetValue := 0
				if len(aDados) > 0
					xSetValue := aDados[1][2]
				endIf

			case cField == "EIJ_ALUPIS"
				cRegime := ""
				cTpAliq := "1"
				if !empty(oModelSWV:getValue("WV_CODREG"))
					cRegime := if( lTribDUIMP, LP500retCp( "", "EKR_REGPIS", oModelSWV, "1" , "EIJ_REGPIS", lRegTrib ), LP500retCp( "", "EKR_REG_PC", oModelSWV, "" , "EIJ_REG_PC", lRegTrib ))
					cTpAliq := LP500retCp( "", "EKR_TPAPIS", oModelSWV, "1", "EIJ_TPAPIS", lRegTrib )
				endIf
				aDados := LP500GetAl("PIS", oModelSWV:getValue("WV_CODREG"), cRegime, cTpAliq, oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaPIS, .T., cField)
				xSetValue := 0
				if len(aDados) > 0
					xSetValue := aDados[1][2]
				endIf

			case cField == "EIJ_ALPISM"
				aDados := LP500GetAl("PIS", oModelSWV:getValue("WV_CODREG"), "", "", oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaPIS, .T., cField)
				xSetValue := 0
				if len(aDados) > 0
					xSetValue := aDados[1][2]
				endIf

			case cField == "EIJ_REDCOF"
				cRegime := ""
				cTpAliq := "1"
				if !empty(oModelSWV:getValue("WV_CODREG"))
					cRegime := if( lTribDUIMP, LP500retCp( "", "EKR_REGCOF", oModelSWV, "1" , "EIJ_REGCOF", lRegTrib ), LP500retCp( "", "EKR_REG_PC", oModelSWV, "" , "EIJ_REG_PC", lRegTrib ))
					cTpAliq := LP500retCp( "", "EKR_TPACOF", oModelSWV, "1", "EIJ_TPACOF", lRegTrib )
				endIf
				aDados := LP500GetAl("COFINS", oModelSWV:getValue("WV_CODREG"), cRegime, cTpAliq, oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaCOF, .T., cField)
				xSetValue := 0
				if len(aDados) > 0
					xSetValue := aDados[1][2]
				endIf

			case cField == "EIJ_ALUCOF"
				cRegime := ""
				cTpAliq := "1"
				if !empty(oModelSWV:getValue("WV_CODREG"))
					cRegime := if( lTribDUIMP, LP500retCp( "", "EKR_REGCOF", oModelSWV, "1" , "EIJ_REGCOF", lRegTrib ), LP500retCp( "", "EKR_REG_PC", oModelSWV, "" , "EIJ_REG_PC", lRegTrib ))
					cTpAliq := LP500retCp( "", "EKR_TPACOF", oModelSWV, "1", "EIJ_TPACOF", lRegTrib )
				endIf
				aDados := LP500GetAl("COFINS", oModelSWV:getValue("WV_CODREG"), cRegime, cTpAliq, oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaCOF, .T., cField)
				xSetValue := 0
				if len(aDados) > 0
					xSetValue := aDados[1][2]
				endIf

			case cField == "EIJ_ALCOFM"
				aDados := LP500GetAl("COFINS", oModelSWV:getValue("WV_CODREG"), "", "", oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM"), !empty(oModelSWV:getValue("WV_CODREG")) .And. lAplicaCOF, .T., cField)
				xSetValue := 0
				if len(aDados) > 0
					xSetValue := aDados[1][2]
				endIf

			case cField == "EIJ_TPADUM"
				xSetValue := IIF(lAplicaADU, LP500retCp( "", "EKR_TPADUM", oModelSWV, "1", cField, lRegTrib ), "1")

			case cField == "EIJ_ALADDU"
				cTpAliq := LP500retCp( "", "EKR_TPADUM", oModelSWV, "1", "EIJ_TPADUM", lRegTrib )
				xSetValue := 0
				if LP500UseAl("ANTIDUMPING", "AD VALOREM", "", cTpAliq)
					xSetValue := IIF(lAplicaADU, LP500retCp( oModelSWV:getValue("WV_CODREG"), "EKR_ALADDU",,,,.T. ), xSetValue)
				endIf

			case cField == "EIJ_ALEADU"
				cTpAliq := LP500retCp( "", "EKR_TPADUM", oModelSWV, "1", "EIJ_TPADUM", lRegTrib )
				xSetValue := 0
				if LP500UseAl("ANTIDUMPING", "ESPECIFICA", "", cTpAliq)
					xSetValue := IIF(lAplicaADU, LP500retCp( oModelSWV:getValue("WV_CODREG"), "EKR_ALEADU",,,,.T. ), xSetValue)
				endIf

			case cField == "EIJ_ALR_II"
				xSetValue := 0
				If lAplicaII
					cRegime := LP500retCp( "", "EKR_REGTRI", oModelSWV, "1", "EIJ_REGTRI", lRegTrib )
					cTpAliq := LP500retCp( "", "EKR_TPAII", oModelSWV, "1", "EIJ_TPAII", lRegTrib )
					if lTribDUIMP .and. LP500UseAl("II", "REDUZIDA", cRegime, cTpAliq)
						xSetValue := LP500retCp( oModelSWV:getValue("WV_CODREG"), "EKR_ALR_II",,,,.T. )
					endIf
				EndIf

			case cField == "EIJ_ALRIPI"
				xSetValue := 0
				If lAplicaIPI
					cRegime := LP500retCp( "", "EKR_REGIPI", oModelSWV, "1", "EIJ_REGIPI", lRegTrib )
					cTpAliq := LP500retCp( "", "EKR_TPAIPI", oModelSWV, "1", "EIJ_TPAIPI", lRegTrib )
					if lTribDUIMP .and. LP500UseAl("IPI", "REDUZIDA", cRegime, cTpAliq)
						xSetValue := LP500retCp( oModelSWV:getValue("WV_CODREG"), "EKR_ALRIPI",,,,.T. )
					endIf
				EndIf
		end case

		
		if (lAddNewItem .and. !empty(xSetValue)) .or. !(xSetValue == xOldValue)
			oModelEIJ:loadValue(cField, xSetValue)
		endIf

	next
return

Static Function setClasTrb(oModelSWV, cCodRegime, lPUProduc, lRegTrib)
Local cAtributo := IIF(lPUProduc, ATT_CLASSTRIB, ATT_CLASSTRIB_VAL)
Local cValor	:=  LP500retCp(cCodRegime, "EKR_CSTCCT", oModelSWV, "", , lRegTrib )
Local oJson
/*
{
	"atributosDuimp": [
		{
			"codigo": "ATT_20130",
			"valor": [
				"000001"
			]
		}
	]
}
*/
If !Empty(cValor)
	oJson := jsonObject():New()
	oJson['atributosDuimp'] := {}
	aAdd(oJson['atributosDuimp'], jSonObject():New())
	oJson['atributosDuimp'][1]['codigo'] := cAtributo
	oJson['atributosDuimp'][1]['valor'] := {cValor}
	oModelSWV:setValue("WV_ATRIBUT", oJson:toJson())
	FreeObj(oJson)
EndIf
Return 


Static Function LP500FundL( cTributo, cCampoEKR, oModelSWV, cField, lRegTrib, oModel, lAplica )
Local cRet := ""
Local oEKWRegTri
If lAplica
	cRet := LP500retCp( "", cCampoEKR, oModelSWV, , cField, lRegTrib )
	If !Empty(cRet) .And. AvFlags("FUNDAMENTO_LEGAL_ITEM")
		oEKWRegTri := jSonObject():New()
		oEKWRegTri['listaOpcional'] := jSonObject():New()
		oEKWRegTri['listaOpcional'][cTributo] := jSonObject():New()

		setAtriOpc(@oEKWRegTri, cTributo, oModelSWV:getValue("WV_HAWB"), oModelSWV:getValue("WV_ID"), oModelSWV:getValue("WV_NCM"), cRet)					
		IncRegTrib(oModel, oEKWRegTri, "SWVDETAIL")
		FreeObj(oEKWRegTri)		
	EndIf
EndIf

Return cRet

/*/{Protheus.doc} getFielsEIJ
Verificar quais campos do modelo EIJ serão atualizados nos processamentos de inclusão e alteração dos itens da DUIMP
@type function
@version  1.0.0
@author wilsimar
@since 9/11/2025
@param lAddItems, logical, indica se estamos incluindo ou atualizando os itens da DUIMP
@return variant, array com os campos que serão atualizados
/*/
static function getFielsEIJ(lAddItems, oModelEIJ)
local aFields:= {} as array
local aAllFields as array
local aAltFields:= {} as array
local nCount as numeric

	aAllFields:= oModelEIJ:getStruct():GetFields()
	if lAddItems
		AEval(aAllFields, {|x| iif( !x[MODEL_FIELD_VIRTUAL], AAdd(aFields, x[MODEL_FIELD_IDFIELD]), ) })
	else
		AAdd(aAltFields, "EIJ_DSCCIT") //Desc. Comp. It	- Descrição complemento do Item
		AAdd(aAltFields, "EIJ_QT_EST") //Qtde Estatic - Quantidade estatística do item
		AAdd(aAltFields, "EIJ_PESOL")  //Peso  - Peso total do item
		AAdd(aAltFields, "EIJ_VLMLE")  //VMLV Moeda - Valor moeda local de venda do item
		AAdd(aAltFields, "EIJ_INCOTE") //Incoterm	- Incoterm do item
		AAdd(aAltFields, "EIJ_MOEDA")  //Moeda Venda - Moeda de venda do item
		AAdd(aAltFields, "EIJ_MODALI") //Modalidade - Modalidade de pagamento do item
		AAdd(aAltFields, "EIJ_MOTIVO") //Motivo - Motivo cobertura do item
		AAdd(aAltFields, "EIJ_TIPCOB") //Tipo de cobertura do item
		AAdd(aAltFields, "EIJ_VL_FIN") //Vl.Tot.Prazo - Valor Total a Prazo do item
		AAdd(aAltFields, "EIJ_TINFO")
		AAdd(aAltFields, "EIJ_VRSFOR")

		for nCount:= 1 to len(aAltFields)
			if AScan(aAllFields, {|x| x[MODEL_FIELD_IDFIELD] == aAltFields[nCount] }) > 0
				AAdd(aFields, aAltFields[nCount])
			endIf
		next

	endIf

Return AClone(aFields)

/*/{Protheus.doc} updEIKDetail
description
@type function
@version  
@author wilsimar
@since 9/9/2025
@param oModelEIK, object, param_description
@return variant, return_description
/*/
// static function updEIKDetail(oModelEIK)

// 	//oModelEIK:deleteLine()

// return

/*/{Protheus.doc} updEINADetail
description
@type function
@version  
@author wilsimar
@since 9/9/2025
@param oModelEIK, object, param_description
@return variant, return_description
/*/
// static function updEINADetail(oModelEINA)

// 	//oModelEINA:deleteLine()

// return

/*/{Protheus.doc} updEINDDetail
description
@type function
@version  
@author wilsimar
@since 9/9/2025
@param oModelEIK, object, param_description
@return variant, return_description
/*/
// static function updEINDDetail(oModelEIND)

// 	//oModelEIND:deleteLine()

// return

/*/{Protheus.doc} updEJ9Detail
description
@type function
@version  
@author wilsimar
@since 9/9/2025
@param oModelEIK, object, param_description
@return variant, return_description
/*/
// static function updEJ9Detail(oModelEJ9)

// 	//oModelEJ9:deleteLine()

// return

/*
Função     : updEKWDetail
Objetivo   : Função de load chamada do addGrid para carregar os grids de Fundamento Legal
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
Revisão    : 16/09/2025: função original: LP500LDEKW, migrada para o load pela gravação do desembaraço
*/
Static Function updEKWDetail(oModel, oModelEKW, cType, lAddNewItem, cIdSWV)
Local cAliasEKW as character
Local cPais as character
Local cNcm as character
Local cHawb as character
Local cId as character
Local oModelSWV as object

default cIdSWV := ""

// somente para os novos itens ou quebra de lote que serão adicionados os fundamentos do tipo Normal e Teto
// caso ja tenha sido gravado o item da duimp, mas depois que foi atualizado os fundamentos, deverá ser incluido manualmente na rotina Itens DUIMP
if lAddNewItem .or. empty(cIdSWV)
	oModelSWV := oModel:GetModel("SWVDETAIL")
	cAliasEKW := getNextAlias()
	cPais := LP500GetPais()
	cNcm := oModelSWV:GetValue("WV_NCM")
	cHawb := oModelSWV:GetValue("WV_HAWB")
	cId := oModelSWV:GetValue("WV_ID")

	LoadEKWEKV(@cAliasEKW, cNcm, cType, cPais, cHawb, cId)
	SetGridEKW(cAliasEKW, oModelEKW, cType)

	If Select(cAliasEKW) > 0
		(cAliasEKW)->(dbCloseArea())
	EndIf
endif

Return

/*
Função     : setGridEKW
Objetivo   : Função para Carregar os dados selecionados de fundamento legal no grid da tabela EKW
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
Revisão    : 16/09/2025: migrada para o load pela gravação do desembaraço
*/
Static Function setGridEKW(cAliasEKW, oModEKW, cTributo)
	local lFirstData as logical
	local lRet as logical

	lFirstData := oModEKW:Length(.T.) == 1 .and. empty(oModEKW:getValue("EKW_FDTLGL"))
	lRet := .T.

	(cAliasEKW)->(dbgotop())
	While (cAliasEKW)->(!EOF())

		if lFirstData
			lFirstData:= .F.
		else
			lRet := AddLine(oModEKW)
		endIf

		oModEKW:LoadValue("EKW_TRIBUT", cTributo)
		oModEKW:LoadValue("EKW_FDTLGL", (cAliasEKW)->EKW_FDTLGL)
		oModEKW:LoadValue("EKW_REGIME", (cAliasEKW)->EKW_REGIME)
		oModEKW:LoadValue("EKW_TIPO"  , (cAliasEKW)->EKW_TIPO)
		oModEKW:LoadValue("EKW_NCM"   , (cAliasEKW)->EKW_NCM)

		(cAliasEKW)->(dbSkip())

	EndDo

Return

/*
Função     : LoadEKWEKV
Objetivo   : Função para buscar os dados da tabela EKV e EKW para montar os grids de Fundamento Legal
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
Revisão    : 16/09/2025: migrada para o load pela gravação do desembaraço
*/
Static Function LoadEKWEKV(cAliasEKW, cNcm, cTributo, cPais, cHawb, cId)
Local cQuery := ""
Local oQuery

cQuery += " SELECT  "
cQuery += "   EKV_NCM EKW_NCM,  "
cQuery += "   EKV_FDTLGL EKW_FDTLGL,  "
cQuery += "   EKV_TRIBUT EKW_TRIBUT,  "
cQuery += "   EKV_TIPO EKW_TIPO,  "
cQuery += "   EKV_PAIS EKW_PAIS,  "
cQuery += "   EKV.R_E_C_N_O_ RECNOEKV, "
cQuery += "   EKU_REGIME EKW_REGIME  "
cQuery += " FROM  "
cQuery +=     RetSqlName("EKV") + " EKV  "
cQuery += "   INNER JOIN " + RetSqlName("EKU") + " EKU ON ( "
cQuery += "     EKU_FILIAL          = ?  "
cQuery += "     AND EKU_FDTLGL      = EKV_FDTLGL  "
cQuery += "     AND EKU_REGIME      <> ? "
cQuery += "     AND EKU.D_E_L_E_T_  = ? "
cQuery += "   )  "
cQuery += " WHERE  "
cQuery += "   EKV_FILIAL         = ?  "
cQuery += "   AND EKV_NCM        = ?  "
cQuery += "   AND EKV_TRIBUT     = ?  "
cQuery += "   AND EKV_PAIS       = ?  "
cQuery += "   AND (EKV_TIPO = ? OR EKV_TIPO = ?)"
cQuery += "   AND EKV.D_E_L_E_T_ = ?  "

oQuery := FWPreparedStatement():New(cQuery)
oQuery:SetString( 1, xFilial("EKU") )  // EKU_FILIAL
oQuery:SetString( 2, ' '            )  // EKU_REGIME
oQuery:SetString( 3, ' '            )  // EKU.D_E_L_E_T_
oQuery:SetString( 4, xFilial("EKV") )  // EKV_FILIAL
oQuery:SetString( 5, cNcm           )  // EKV_NCM
oQuery:SetString( 6, cTributo       )  // EKV_TRIBUT
oQuery:SetString( 7, cPais          ) // EKV_PAIS
oQuery:SetString( 8, '1'           )  // EKV_TIPO
oQuery:SetString( 9, '2'           )  // EKV_TIPO
oQuery:SetString( 10, ' '           )  // EKV.D_E_L_E_T_

cQuery := oQuery:GetFixQuery()
FwFreeObj(oQuery)

MPSysOpenQuery(cQuery, cAliasEKW)

Return

/*/{Protheus.doc} TotalItems
contagem dos registros para régua de progresso
@type function
@version  
@author wilsimar
@since 9/18/2025
@return variant, total de itens do processo
/*/
static Function TotalItems()
local nTotal as numeric
local nTotalWV as numeric
local nTotalW9 as numeric
local cQuery as character
local cAlias as character

	nTotal := 0
	nTotalWV := 0
	nTotalW9 := 0

	//contagem dos registros da SWV
	cQuery := "SELECT WV_HAWB FROM " + RetSqlName("SWV") + " WV WHERE  WV.D_E_L_E_T_ = ' ' and WV_HAWB = '" + SW6->W6_HAWB + "' and WV_FILIAL = '" + xFilial("SWV") + "' "
	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)
	dbSelectArea(cAlias)       
	//Conta quantos registros existem, e seta no tamanho da régua
	Count To nTotalWV
	(cAlias)->(dbCloseArea())

	//contagem dos registros da SW9
	cQuery := "SELECT W9_HAWB FROM " + RetSqlName("SW9") + " W9 WHERE  W9.D_E_L_E_T_ = ' ' and W9_HAWB = '" + SW6->W6_HAWB + "' and W9_FILIAL = '" + xFilial("SW9") + "' "
	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)
	dbSelectArea(cAlias)       
	//Conta quantos registros existem, e seta no tamanho da régua
	Count To nTotalW9
	(cAlias)->(dbCloseArea())

	nTotal:= iif(nTotalWV > nTotalW9, nTotalWV, nTotalW9)

return nTotal

/*
Função     : updEKXDetail
Objetivo   : Função para Carregar os dados de tributos da duimp CBS e IBS
Autor      : Tiago Tudisco
Data/Hora  : 22/09/2025
Revisão    : 22/09/2025: migrada para o load pela gravação do desembaraço
*/
Static Function updEKXDetail(oModel, oModelEKX, lAddNewItem)
local aCpoEKX as array
local nContCpo as numeric
local cCampo as character
local cValue as character
local lRet as logical
local oModelSWV as object

oModelSWV := oModel:GetModel("SWVDETAIL")
aCpoEKX := oModelEKX:getStruct():GetFields()
lRet := .T.

if lAddNewItem .Or. empty( oModelEKX:GetValue("EKX_IDWV") )
	for nContCpo := 1 to len(aCpoEKX)
		cCampo := aCpoEKX[nContCpo][3]
		If cCampo == "EKX_FILIAL"
			cValue := xFilial("EKX")
		ElseIf cCampo == "EKX_HAWB"
			cValue := oModelSWV:GetValue("WV_HAWB")
		ElseIf cCampo == "EKX_IDWV"
			cValue := oModelSWV:GetValue("WV_ID")
		Else
			cValue := AliqRefTri(cCampo, oModelSWV:GetValue("WV_NCM"), oModelSWV:GetValue("WV_EX_NCM"), oModelSWV:getValue("WV_CODREG"))
		EndIf
		lRet := lRet .and. oModelEKX:setValue(cCampo, cValue)
	next nContCpo
endif

return nil

/*
Função     : AliqRefTri
Objetivo   : Função para Carregar Aliquotas dos tributos da duimp CBS do cadastro de NCM
Autor      : Tiago Tudisco
Data/Hora  : 22/09/2025
*/
Static Function AliqRefTri(cCampo, cNcm, cExNcm, cCodRegime)
Local nRet  := 0
Local aArea := SYD->(getArea()) 
Local lNcm  := .T.
Local cCbsIbs:= '{"CBS":{"EKX_ALADCB":"EKR_ALADCB","EKX_ALRDCB":"EKR_ALRDCB","EKX_ALRBCB":"EKR_ALRBCB"},"IBS":{"EKX_ALADIB":"EKR_ALADIB","EKX_ALRDIB":"EKR_ALRDIB","EKX_ALRBIB":"EKR_ALRBIB"}}'
Local oCbsIbs

If AvFlags("REFORMA_CCLASSTRIB") .And. !Empty(cCodRegime)
	EKR->(dbSetOrder(1)) //EKR_FILIAL+EKR_CODREG+EKR_DESTIN
	If EKR->(dbSeek( xFilial("EKR") + cCodRegime))
		oCbsIbs := JsonObject():new()
		oCbsIbs:fromJson(cCbsIbs)

		If oCbsIbs['CBS']:hasProperty(cCampo) .And. EKR->EKR_APLCBS != "2"
			nRet := EKR->&(oCbsIbs['CBS'][cCampo])
			lNcm := .F.
		ElseIf oCbsIbs['IBS']:hasProperty(cCampo) .And. EKR->EKR_APLIBS != "2"
			nRet := EKR->&(oCbsIbs['IBS'][cCampo])
			lNcm := .F.
		Else
			lNcm := .T.
		EndIf
		FreeObj(oCbsIbs)
	EndIf
EndIf

If lNcm
	SYD->(dbSetOrder(1)) //YD_FILIAL+YD_TEC+YD_EX_NCM+YD_EX_NBM+YD_DESTAQU
	If SYD->(dbSeek( xFilial("SYD") + cNcm + iif( !empty(cExNcm), cExNcm, " " ) ))
		Do Case
			Case cCampo == "EKX_ALADCB"
				nRet := SYD->YD_ALADCBS
			Case cCampo == "EKX_ALRDCB"
				nRet := SYD->YD_ALRDCBS
			Case cCampo == "EKX_ALADIB"
				nRet := SYD->YD_ALADIBS
			Case cCampo == "EKX_ALRDIB"
				nRet := SYD->YD_ALRDIBS
			Case cCampo == "EKX_ALRBCB"
				nRet := SYD->YD_ALRBCBS
			Case cCampo == "EKX_ALRBIB"
				nRet := SYD->YD_ALRBIBS
		EndCase
	EndIf
EndIf
restArea(aArea)
Return nRet

/*/{Protheus.doc} delDuimpItems
	Retira os itens da INVOICE que não fazem mais parte devido a alteração do desembaraço

	@type  Static Function
	@author user
	@since 01/10/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
static function delDuimpItems(oModelSWV, nTotalItems )
	local cHawb as character
	local cInvoice as character
	local cPONum as character
	local cPosicao as character
	local cPGINum as character
	local nItemSWV as numeric
	local lRet as logical

	cHawb := oModelSWV:getValue("WV_HAWB")

	for nItemSWV := 1 to nTotalItems

		oModelSWV:goLine(nItemSWV)

		cInvoice := oModelSWV:getValue("WV_INVOICE")
		cPONum := oModelSWV:getValue("WV_PO_NUM")
		cPosicao := oModelSWV:getValue("WV_POSICAO")
		cPGINum := oModelSWV:getValue("WV_PGI_NUM")

		if !empty(cInvoice) .and. !empty(cPosicao) .and. !SW8->(DbSeek(xFilial("SW8") + cHawb + cInvoice + cPONum + cPosicao + cPGINum))
			lRet := delModSWV(oModelSWV)
		endIf

	next nItemSWV

	oModelSWV:goLine(1)

return nil

/*/{Protheus.doc} delModSWV
	Realiza a exclusão da linha do modelo de dados da SWV

	@type  Static Function
	@author user
	@since 02/10/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
static function delModSWV(oModelSWV)
	local lRet as logical

	oModelSWV:loadValue("WV_SEQUENC", "") // devido a validação do delete, não deixa excluir, se a WV_SEQUENC for igual a 1
	lRet := oModelSWV:deleteLine()

return lRet

/*/{Protheus.doc} LP501Estor
	Realiza o estorno do itens da duimp

	@type  Function
	@author user
	@since 08/10/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
function LP501Estor( cHawb, aItensExec )
	local lRet as logical
	local cAliasSel as character
	local aAreaSW8 as array

	default cHawb      := SW6->W6_HAWB
	default aItensExec := {}

	cAliasSel  := alias()
	dbSelectArea("SW8")
	aAreaSW8 := SW8->(getArea())
	lRet := .F.

	SW8->(dbSetOrder(1)) //W8_FILIAL + W8_HAWB + W8_INVOICE + W8_FORN + W8_FORLOJ
	if !empty(cHawb) .and. SW8->(dbSeek(xFilial("SW8") + cHawb )) .and. len(aItensExec) > 0

		oModelo := FwLoadModel("EICLP500")
		oModelo:SetOperation(MODEL_OPERATION_UPDATE)
		oModelo:SetOptional("SWVDETAIL", .T.)
		lRet := oModelo:Activate()

		lRet := lRet .and. execEstor(oModelo, cHawb, aItensExec)

		iif( lRet .and. oModelo:VldData(), lRet := oModelo:CommitData(), ( lRet := .F. , EasyHelp(STR0006 + CRLF + if( valtype(xError := oModelo:GetErrorMessage()) == "C", alltrim(xError), if( valtype(xError) == "A" .and. len(xError) >= 7 , CHR(10) + CHR(10) + STR0003 + ": " + allToChar( xError[6]) + CHR(10) + STR0004 + ": " + allToChar( xError[7] ) , "") ) ,STR0002,"") ) ) // "Não foi possível realizar o estorno dos Itens DUIMP" ## "Atenção" ## "Mensagem do erro" ## "Mensagem do solução"

		oModelo:DeActivate()
		oModelo:Destroy()
		FwFreeObj(oModelo)

		if lRet
			LP500IDEWQ( cHawb, STRZERO(0, AVSX3("WV_ID",AV_TAMANHO)) )
		endif
	endIf

	restArea(aAreaSW8)

	if !empty(cAliasSel)
		dbSelectArea(cAliasSel)
	endIf

return lRet

/*/{Protheus.doc} execEstor
	Realizar a exclusão de todos os itens da duimp

	@type  Static Function
	@author user
	@since 08/10/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
static function execEstor(oModelo, cHawb, aItensExec)
	local lRet as logical
	local cFilSW9 as character
	local cFilSWV as character
	local nTamSeq as numeric
	local oModelSW9 as object
	local nTotItens as numeric
	local nItens as numeric
	local cInvoice as character
	local cForn as character
	local cForloj as character
	local aSeek as array
	local lSeekSW9 as logical
	local oModelSWV as object
	local cSequenc as character
	local lSeekSWV as logical

	default cHawb      := SW6->W6_HAWB
	default aItensExec := {}

	lRet := .T.
	cFilSW9 := xFilial("SW9")
	cFilSWV := xFilial("SWV")
	nTamSeq := getSX3Cache("WV_SEQUENC", "X3_TAMANHO")

	oModelSW9 := oModelo:GetModel("SW9DETAIL")
	cInvoice := ""
	cForn := ""
	cForloj := ""
	lSeekSW9 := .F.

	nTotItens := len(aItensExec) // { W9_INVOICE, W7_FORN, W7_FORLOJ, W7_PO_NUM, W7_POSICAO }
	for nItens := 1 to nTotItens

		if lRet .and. (!(cInvoice == aItensExec[nItens][1]) .or. ;
		   !(cForn    == aItensExec[nItens][2]) .or. ;
		   !(cForloj  == aItensExec[nItens][3]))

			aSeek := {{"W9_FILIAL" , cFilSW9 },;
				  {"W9_HAWB"   , cHawb },;
				  {"W9_INVOICE", aItensExec[nItens][1] },;
				  {"W9_FORN"   , aItensExec[nItens][2] },;
				  {"W9_FORLOJ" , aItensExec[nItens][3] }}
		
			if (lSeekSW9 := oModelSW9:SeekLine(aSeek, .F., .T.))
				cInvoice := oModelSW9:GetValue("W9_INVOICE")
				cForn := oModelSW9:GetValue("W9_FORN")
				cForloj := oModelSW9:GetValue("W9_FORLOJ")
			endif
		endif

		if lRet .and. lSeekSW9
			oModelSWV := oModelo:GetModel("SWVDETAIL")		
			lSeekSWV := .F.
			cSequenc := strZero(1, nTamSeq)
			aSeek := {{"WV_FILIAL"  , cFilSWV },;
				  	  {"WV_HAWB"    , cHawb },;
					  {"WV_INVOICE" , aItensExec[nItens][1] },;
					  {"WV_FORN"    , aItensExec[nItens][2] },;
					  {"WV_FORLOJ"  , aItensExec[nItens][3] },;
					  {"WV_PO_NUM"  , aItensExec[nItens][4] },;
					  {"WV_POSICAO" , aItensExec[nItens][5] },;
					  {"WV_SEQUENC" , cSequenc }}
			lSeekSWV := oModelSWV:SeekLine(aSeek , .F., .T.)
			while lSeekSWV .and. lRet
				lRet := delModSWV(oModelSWV)
				cSequenc:= SomaIt(cSequenc)
				aSeek[8, 2]:= cSequenc
				lSeekSWV := lRet .and. oModelSWV:SeekLine(aSeek , .F., .T.)
			end
		endif

	next nItens

return lRet

/*/{Protheus.doc} addLine
	(long_description)
	@type  Static Function
	@author user
	@since 09/10/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function addline(oModelGrid)
	local lRet as logical
	local nQtdItem as numeric

	nQtdItem := oModelGrid:length()
	if nQtdItem == 1
		nQtdItem := 0
	endif
	lRet := !(oModelGrid:AddLine() == nQtdItem)

return lRet

/*/{Protheus.doc} VldInvoice
   Realiza a validação da invoice se possui mais itens SW8, para que seja excluida no modelo de dados SW9DETAIL e seus relacionamentos, não havendo necessidade de excluir item a item

   @type  Static Function
   @author user
   @since 16/09/2025
   @version version
   @param param_name, param_type, param_descr
   @return lRet, logico, .T. se foi excluida a invoice, .F. se ainda possui itens
   @example
   (examples)
   @see (links_or_references)
/*/
static function VldInvoice(oModSW9, cHawb, cInvoice)
	local lRet       := .F.

	default cHawb      := oModSW9:getValue("W9_HAWB")
	default cInvoice   := oModSW9:getValue("W9_INVOICE")

	if !SW8->(DbSeek(xFilial("SW8") + cHawb + cInvoice ))
		oModSW9:deleteLine()
		lRet := .T.
	endIf

return lRet
