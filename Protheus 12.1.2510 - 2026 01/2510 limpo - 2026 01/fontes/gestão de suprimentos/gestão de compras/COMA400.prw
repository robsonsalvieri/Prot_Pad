#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "COMA400.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA400()
Esta rotina é responsável por atualizar o valor do item XML
do documento de entrada e consolidar os itens da NF de acordo.

Estes dados serão utilizados em notas de crédito e débito.

@author Leandro Fini
@since 11/2025
/*/
//-------------------------------------------------------------------
Function COMA400()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Leandro Fini
@since 11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0001		Action 'VIEWDEF.COMA400' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina Title STR0002   		Action 'VIEWDEF.COMA400' OPERATION 4 ACCESS 0 //'Alterar'


Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Estrutura do Modelo de Dados

@author Leandro Fini
@since 11/2025
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStrSF1 := FWFormStruct( 1, 'SF1' )
	Local oStrSD1 := FWFormStruct( 1, 'SD1' )
	Local oStrDKA := FWFormStruct( 1, 'DKA' )
	Local oModel 	 := Nil

	oModel := MPFormModel():New('COMA400',/*bPreVld*/, {|oModel| A400PosVld(oModel)},{|oModel| A400Commit(oModel)} )

	oModel:AddFields( 'SF1MASTER', /*cOwner*/ , oStrSF1)
	oModel:AddGrid  ( 'SD1DETAIL', 'SF1MASTER', oStrSD1,,,,, )
	oModel:SetRelation('SD1DETAIL', { { 'D1_FILIAL', 'fwxFilial("SF1")' }, { 'D1_EMISSAO', 'F1_EMISSAO' }, { 'D1_DOC', 'F1_DOC' }, { 'D1_SERIE', 'F1_SERIE' }, { 'D1_FORNECE', 'F1_FORNECE'},{ 'D1_LOJA', 'F1_LOJA'} }, SD1->(IndexKey(3)) )//D1_FILIAL, D1_EMISSAO, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA

	oModel:AddGrid  ( 'DKADETAIL', 'SF1MASTER', oStrDKA,,,,, )
	oModel:SetRelation('DKADETAIL', {{'DKA_FILIAL','fwxFilial("SF1")'},{'DKA_DOC','F1_DOC'},{'DKA_SERIE','F1_SERIE'},{'DKA_FORNEC','F1_FORNECE'},{'DKA_LOJA','F1_LOJA'}},DKA->(IndexKey(1)))

// --------------------------------------------
// Desabilita todos os campos obrigatórios
// --------------------------------------------
	oModel:GetModel('SD1DETAIL'):SetOptional(.T.)
	oModel:GetModel('DKADETAIL'):SetOptional(.T.)
	oStrSF1:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
	oStrSD1:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
	oStrDKA:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )

// --------------------------------------------
// Não permitir serem inseridas linhas na grid
// --------------------------------------------
	oModel:GetModel('SD1DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('DKADETAIL'):SetNoInsertLine(.T.)

// --------------------------------------------
// Não permite apagar linhas do grid
// --------------------------------------------
	oModel:GetModel('SD1DETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('DKADETAIL'):SetNoDeleteLine(.T.)

	oModel:SetDescription( STR0003 ) //"Itens XML x NF"
	oModel:GetModel( 'SF1MASTER' ):SetDescription( STR0004 ) //"Documento"
	oModel:GetModel( 'SD1DETAIL' ):SetDescription( STR0005 ) //"Itens do Documento"
	oModel:GetModel( 'DKADETAIL' ):SetDescription( STR0006 ) //"Itens do XML"


	oModel:SetVldActivate( {|| .T. } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Estrutura de Visualização

@author Leandro Fini
@since 11/2025
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

	Local oModel 	:= FWLoadModel('COMA400')
	Local oStrSF1 	:= FWFormStruct( 2, 'SF1', {|cCampo| AllTrim(cCampo)$ "F1_DOC|F1_SERIE|F1_FORNECE|F1_LOJA"} )
	Local oStrSD1 	:= FWFormStruct( 2, 'SD1' , {|cCampo| AllTrim(cCampo)$ "D1_ITXML|D1_ITEM|D1_COD|D1_UM|D1_QUANT|D1_VUNIT|D1_TOTAL|D1_PEDIDO|D1_ITEMPC|D1_LOTECTL"} )
	Local oStrDKA 	:= FWFormStruct( 2, 'DKA', {|cCampo| AllTrim(cCampo)$ "DKA_ITXML|DKA_PRODUT|DKA_UM|DKA_QUANT|DKA_UMXML|DKA_QTDXML"} )

	Private oView := Nil

// ----------------------------------------------------------------------
// Trava todos os campos para edição, com exceção do campo D1_ITXML
// ----------------------------------------------------------------------
	oStrSF1:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
	oStrSD1:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
	oStrSD1:SetProperty("D1_ITXML",MVC_VIEW_CANCHANGE, .T.)
	oStrDKA:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
	oStrDKA:SetProperty("DKA_UMXML",MVC_VIEW_CANCHANGE, .T.)
	oStrDKA:SetProperty("DKA_QTDXML",MVC_VIEW_CANCHANGE, .T.)

	oStrDKA:SetProperty("DKA_UMXML",MVC_VIEW_LOOKUP,"SAH")

	oView:= FWFormView():New()

	oView:SetModel( oModel )

	oStrSF1:SetNoFolder()

	oView:AddField( 'VIEW_SF1' , oStrSF1, 'SF1MASTER' )
	oView:AddGrid ( 'VIEW_SD1' , oStrSD1, 'SD1DETAIL' )
	oView:AddGrid ( 'VIEW_DKA' , oStrDKA, 'DKADETAIL' )

	oView:CreateHorizontalBox	( 'SUPERIOR'   , 015 )
	oView:CreateHorizontalBox	( 'INFERIOR1'  , 040 )
	oView:CreateHorizontalBox	( 'INFERIOR2'  , 045 )

	oView:SetOwnerView( 'VIEW_SF1', 'SUPERIOR'	)
	oView:SetOwnerView( 'VIEW_SD1', 'INFERIOR1'	)
	oView:SetOwnerView( 'VIEW_DKA', 'INFERIOR2'	)

	oStrDKA:SetProperty("DKA_ITXML", MVC_VIEW_ORDEM, "01")
	oStrDKA:SetProperty("DKA_PRODUT", MVC_VIEW_ORDEM, "02")
	oStrDKA:SetProperty("DKA_UM", MVC_VIEW_ORDEM, "03")
	oStrDKA:SetProperty("DKA_QUANT", MVC_VIEW_ORDEM, "04")
	oStrDKA:SetProperty("DKA_UMXML", MVC_VIEW_ORDEM, "05")
	oStrDKA:SetProperty("DKA_QTDXML", MVC_VIEW_ORDEM, "06")

	oStrSD1:SetProperty("D1_ITXML", MVC_VIEW_ORDEM, "01")
	oStrSD1:SetProperty("D1_ITEM", MVC_VIEW_ORDEM, "02")
	oStrSD1:SetProperty("D1_COD", MVC_VIEW_ORDEM, "03")
	oStrSD1:SetProperty("D1_UM", MVC_VIEW_ORDEM, "04")
	oStrSD1:SetProperty("D1_QUANT", MVC_VIEW_ORDEM, "05")
	oStrSD1:SetProperty("D1_VUNIT", MVC_VIEW_ORDEM, "06")
	oStrSD1:SetProperty("D1_TOTAL", MVC_VIEW_ORDEM, "07")
	oStrSD1:SetProperty("D1_PEDIDO", MVC_VIEW_ORDEM, "08")
	oStrSD1:SetProperty("D1_ITEMPC", MVC_VIEW_ORDEM, "09")

	oView:EnableTitleView('VIEW_SD1', STR0005 )//'Itens do Documento'
	oView:EnableTitleView('VIEW_DKA', STR0006 )//'Itens do XML'

	oView:AddUserButton(STR0007, "", {|oModel| A400CONSIT(oModel)},,,) //"Consolidar Itens"
	oView:AddUserButton(STR0008, "", {|| setItXML(oModel,1)},,, {MODEL_OPERATION_UPDATE})//"Auto Preencher Item XML"
	oView:AddUserButton(STR0009, "", {|| setItXML(oModel,2)},,, {MODEL_OPERATION_UPDATE})//"Limpar Item XML"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} A400Commit
Função de commit.
@sample	 	A400Commit()
@return		lRet
@since		11/2025
@author		Leandro Fini
/*/
//------------------------------------------------------------------------------
Static Function A400Commit(oModel)

	Local lRet := .T.
	Local oModelSF1 := nil as object
	Local oModelSD1 := nil as object
	Local oModelDKA	:= nil as object
	Local nX		:= 1 as numeric
	Local cDoc      := "" as character
	Local cSerie    := "" as character
	Local cForn     := "" as character
	Local cLoja     := "" as character
	Local cProd     := "" as character
	Local cItem     := "" as character
	Local cItXML    := "" as character
	Local nTamIt    := TamSX3("D1_ITXML")[1] as numeric
	Local nQtd      := 0 as numeric
	Local cUm       := "" as character
	Local cUmXml    := "" as character
	Local nQtdXml   := "" as numeric
	Local lIntegTaf := SuperGetMv('MV_TAFISCH',, '0') == '1' .And. C30->(FieldPos("C30_ITEXML")) > 0 as boolean

	Default oModel := FwModelActive()

	oModelSF1 := oModel:GetModel("SF1MASTER")
	oModelSD1 := oModel:GetModel("SD1DETAIL")
	oModelDKA	:= oModel:GetModel("DKADETAIL")

	cDoc      := oModelSF1:GetValue("F1_DOC")
	cSerie    := oModelSF1:GetValue("F1_SERIE")
	cForn     := oModelSF1:GetValue("F1_FORNECE")
	cLoja     := oModelSF1:GetValue("F1_LOJA")

	Begin Transaction

		DbSelectArea("SD1")
		SD1->(DbSetOrder(1)) //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM

		DbSelectArea("DKN")
		DKN->(DbSetOrder(4)) //DKN_FILIAL+DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF+DKN_ITNFRE+DKN_TPMOV

		if SD1->(Msseek(fwxFilial("SD1") + cDoc + cSerie + cForn + cLoja))

			while SD1->(!Eof()) .and. SD1->D1_DOC == cDoc .and. SD1->D1_SERIE == cSerie .and. SD1->D1_FORNECE == cForn .and. SD1->D1_LOJA == cLoja
				if (oModelSD1:SeekLine({{"D1_ITEM",SD1->D1_ITEM},{"D1_COD",SD1->D1_COD}}))

					cItXml := StrZero(Val(oModelSD1:GetValue("D1_ITXML")), nTamIt)

					Reclock("SD1",.F.)
					SD1->D1_ITXML := cItXml
					SD1->(MsUnlock())

					// -- Atualiza o item XML se o item estiver referenciado a nota de crédito/débito
					if DKN->(dbseek(fwxFilial("DKN") + cDoc + cSerie + cForn + cLoja + oModelSD1:GetValue("D1_ITEM") + "1"))
						Reclock("DKN", .F.)
						DKN->DKN_ITXML := cItXml
						DKN->(MsUnlock())
					endif
				endif
				SD1->(DbSkip())
			enddo
		endif

		// -- Deleto os registros consolidados para garantir possiveis mudanças de registros como re-inclusão do documento com registros diferentes.
		A400DELDKA(cDoc,cSerie,cForn,cLoja)

		For nX := 1 to oModelDKA:Length()
			oModelDKA:GoLine(nX)

			if !oModelDKA:IsDeleted() .and. !empty(oModelDKA:GetValue("DKA_ITXML"))

				cProd   := oModelDKA:GetValue("DKA_PRODUT")
				cItem   := oModelDKA:GetValue("DKA_ITXML")
				nQtd    := oModelDKA:GetValue("DKA_QUANT")
				cUm     := oModelDKA:GetValue("DKA_UM")
				cUmXml  := oModelDKA:GetValue("DKA_UMXML")
				nQtdXml := oModelDKA:GetValue("DKA_QTDXML")


				Reclock("DKA", .T.)
				DKA->DKA_FILIAL := fwxFilial("DKA")
				DKA->DKA_DOC    := cDoc
				DKA->DKA_SERIE  := cSerie
				DKA->DKA_FORNEC := cForn
				DKA->DKA_LOJA   := cLoja
				DKA->DKA_ITXML  := cItem
				DKA->DKA_PRODUT := cProd
				DKA->DKA_QUANT  := nQtd
				DKA->DKA_UM     := cUm
				DKA->DKA_UMXML  := cUmXml
				DKA->DKA_QTDXML := nQtdXml
				DKA->DKA_CSDXML := "2" //-- Registro não é proveniente do sefaz-am (MV_CSDXML)
				DKA->(MsUnlock())
			endif

		Next nX

		if lIntegTaf .And. tlpp.ffunc( 'GravaDadosXMLDKA')
			tlpp.call('GravaDadosXMLDKA', cDoc,cSerie,cForn,cLoja)
		endif

	End Transaction

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} setItXML
    Facilitador para preenchimento automático do item XML sequencialmente.
@sample	 	setItXML()
@return		nil
@since		11/2025
@params     nOpc == 1 - Auto preencher item xml,
            nOpc == 2 - Limpar item xml e consolidação
@author		Leandro Fini  
/*/
//------------------------------------------------------------------------------
Static Function setItXML(oModel,nOpc)

	Local oModelSD1  := nil as object
	Local nX		    := 1 as numeric
	Local cItem      := "" as character

	Default oModel := FwModelActive()
	Default nOpc   := 1

	oModelSD1 := oModel:GetModel("SD1DETAIL")

	For nX := 1 to oModelSD1:Length()
		oModelSD1:GoLine(nX)
		cItem  := StrZero(Val(oModelSD1:GetValue("D1_ITEM")), TamSX3("D1_ITXML")[1])
		oModelSD1:LoadValue("D1_ITXML", if(nOpc==1,cItem,"") )
	Next nX

	if nOpc == 2
		clearCons(oModel,2)
	endif

	oModelSD1:GoLine(1)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} A400CONSIT
    Realiza a consolidação de acordo com o valor do item XML informado
@sample	 	setItXML()
@return		nil
@since		11/2025
@author		Leandro Fini  
/*/
//------------------------------------------------------------------------------
Function A400CONSIT(oModel, cMsg)

	Local oModelSF1 := nil as object
	Local oModelSD1 := nil as object
	Local oModelDKA := nil as object
	Local nX        := 1  as numeric
	Local nY        := 1  as numeric
	Local nPos      := 0  as numeric
	Local aAux      := {} as array
	Local aItensDKA := {} as array
	Local lDocSDT   := .F. as boolean
	Local cUmXml    := "" as character
	Local nQtdXML   := 0 as numeric
	Local lOk       := .T. as boolean
	Local lCons     := .T. as boolean

	Default oModel := FwModelActive()
	Default cMsg   := ""

	oModelSF1 := oModel:GetModel("SF1MASTER")
	oModelSD1 := oModel:GetModel("SD1DETAIL")
	oModelDKA := oModel:GetModel("DKADETAIL")

	if !empty(oModelDKA:GetValue("DKA_ITXML")) .and. !isBlind() .and. !MsgYesNo(STR0010)//"Os dados já estão consolidados, deseja limpar e consolidar novamente?"
		lOk := .F.
	else
		clearCons(oModel,2)
	endif

	if lOk
		For nX := 1 to oModelSD1:Length()

			oModelSD1:GoLine(nX)

			if empty(oModelSD1:GetValue("D1_ITXML"))
				//"Não foi possível realizar a consolidação dos dados, o item: " ## " não possui o valor correspondente ao item xml."
				cMsg := STR0011 + oModelSD1:GetValue("D1_ITEM") + STR0012
				Help(NIL, NIL, "A400CONSIT", NIL, cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lCons := .F.
				exit
			endif

			//Realiza a consolidação de acordo com o item do XML.
			nPos := aScan(aItensDKA, {|x|AllTrim(x[1])== Alltrim(StrZero(Val(oModelSD1:GetValue("D1_ITXML")), TamSX3("D1_ITXML")[1])) })
			if nPos == 0

				aAux := {}
				aAux := {;
					StrZero(Val(oModelSD1:GetValue("D1_ITXML")), TamSX3("D1_ITXML")[1]),; 	//[1] - Item XML
				oModelSD1:GetValue("D1_COD"),; 		    //[2] - Produto
				oModelSD1:GetValue("D1_ITEM") + "|",;   //[3] - Item NFE
				oModelSD1:GetValue("D1_UM"),; 		    //[4] - Unidade de medida
				oModelSD1:GetValue("D1_QUANT"),; 		//[5] - Quantidade SD1
				oModelSD1:GetValue("D1_TOTAL");		    //[6] - Valor Total
				}

				aAdd(aItensDKA,aClone(aAux))
			else
				if Alltrim(aItensDKA[nPos][1]+Alltrim(aItensDKA[nPos][2])) <> Alltrim(StrZero(Val(oModelSD1:GetValue("D1_ITXML")), TamSX3("D1_ITXML")[1])+Alltrim(oModelSD1:GetValue("D1_COD")))
					//"Há divergência no item XML " ## " / Produto " ## " Os produtos devem ser iguais quando são parte do mesmo item XML"
					cMsg := STR0013 + oModelSD1:GetValue("D1_ITXML") + STR0014 + Alltrim(oModelSD1:GetValue("D1_COD")) + STR0015
					Help(,, "A400CONSIT",, cMsg , 1, 0,,,,,,)
					lCons := .F.
					Exit
				else
					aItensDKA[nPos][3] += oModelSD1:GetValue("D1_ITEM") + "|"
					aItensDKA[nPos][5] += oModelSD1:GetValue("D1_QUANT")
					aItensDKA[nPos][6] += oModelSD1:GetValue("D1_TOTAL")
				endif

			endif

		next nX


		if len(aItensDKA) > 0 .and. lCons

			oModelDKA:SetNoInsertLine(.F.)
			oModelDKA:GetStruct():SetProperty("*",MVC_VIEW_CANCHANGE, .T.)
			oModelDKA:GetStruct():SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
			oModelDKA:GetStruct():SetProperty("DKA_DESCFO",MODEL_FIELD_OBRIGAT,.F.)
			oModelDKA:GetStruct():SetProperty("DKA_UMXML",MODEL_FIELD_OBRIGAT,.F.)
			oModelDKA:GetStruct():SetProperty("DKA_FATOR",MODEL_FIELD_OBRIGAT,.F.)
			oModelDKA:GetStruct():SetProperty("DKA_QTDXML",MODEL_FIELD_OBRIGAT,.F.)
			if oModelDKA:HasField("DKA_CSDXML")
				oModelDKA:GetStruct():SetProperty("DKA_CSDXML",MODEL_FIELD_OBRIGAT,.F.)
			endif
			for nY := 1 to Len(aItensDKA)

				if nY > 1 .or. oModelDKA:IsDeleted()
					oModelDKA:AddLine()
				endif

				oModelDKA:LoadValue("DKA_FILIAL" , fwxFilial("DKA"))
				oModelDKA:LoadValue("DKA_DOC"	, oModelSF1:GetValue("F1_DOC"))
				oModelDKA:LoadValue("DKA_SERIE"	, oModelSF1:GetValue("F1_SERIE"))
				oModelDKA:LoadValue("DKA_FORNEC"	, oModelSF1:GetValue("F1_FORNECE"))
				oModelDKA:LoadValue("DKA_LOJA"	, oModelSF1:GetValue("F1_LOJA"))
				oModelDKA:LoadValue("DKA_ITXML"	    , aItensDKA[nY][1])
				oModelDKA:LoadValue("DKA_PRODUT"	, aItensDKA[nY][2])
				if oModelDKA:HasField("DKA_CSDXML")
					oModelDKA:LoadValue("DKA_CSDXML"	, "2")
				endif

				cUmXml := ""
				nQtdXML := 0

				//Verifica se documento é originado do Totvs Colaboração / Importador XML
				lDocSDT := !COLFINSDS(1,oModelSF1:GetValue("F1_DOC") + oModelSF1:GetValue("F1_SERIE") + oModelSF1:GetValue("F1_FORNECE") + oModelSF1:GetValue("F1_LOJA"))

				If lDocSDT //Busca informação nos itens do documento do Totvs Colaboração / Importador XML
					cUmXml  := GetAdvFVal("SDT","DT_UMXML" ,fwxFilial("SDT") + oModelDKA:GetValue("DKA_FORNEC") + oModelDKA:GetValue("DKA_LOJA") + oModelDKA:GetValue("DKA_DOC") + oModelDKA:GetValue("DKA_SERIE") + oModelDKA:GetValue("DKA_PRODUT"),3)
					nQtdXML := A103CSDQTD(oModelDKA:GetValue("DKA_FORNEC"),oModelDKA:GetValue("DKA_LOJA"),oModelDKA:GetValue("DKA_DOC"),oModelDKA:GetValue("DKA_SERIE"),oModelDKA:GetValue("DKA_PRODUT"),aItensDKA[nY][1])
				Endif

				If Empty(cUmXml) //Busca informação na amarração produto x fornecedor
					cUmXml := GetAdvFVal("SA5","A5_UNID",fwxFilial("SA5") + oModelSF1:GetValue("F1_FORNECE") + oModelSF1:GetValue("F1_LOJA") + Alltrim(aItensDKA[nY][2])  ,1)//Unidade de medida do fornecedor - Produto x Fornecedor
				Endif

				oModelDKA:LoadValue("DKA_UMXML"	, cUmXml)
				oModelDKA:LoadValue("DKA_ITEMNF"	, aItensDKA[nY][3])
				oModelDKA:LoadValue("DKA_UM"		, Alltrim(aItensDKA[nY][4]))
				oModelDKA:LoadValue("DKA_QUANT"	, aItensDKA[nY][5])
				oModelDKA:LoadValue("DKA_VLRTOT"	, aItensDKA[nY][6])
				oModelDKA:LoadValue("DKA_QTDXML", if(nQtdXML > 0 .and. lDocSDT, nQtdXML, 0))
			next nY
			oModelDKA:GoLine(1)
			oModelSD1:GoLine(1)
			oModelDKA:SetNoInsertLine(.T.)
			oModelDKA:GetStruct():SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
			oModelDKA:GetStruct():SetProperty("DKA_UMXML",MODEL_FIELD_OBRIGAT,.T.)
			oModelDKA:GetStruct():SetProperty("DKA_QTDXML",MODEL_FIELD_OBRIGAT,.T.)
		endif
	endif
Return

/*/{Protheus.doc} A103CPosDKA
	Pós validação da linha do modelo da DKA(Itens XML)

	@oModelDKA = Modelo ativo
@author Leandro Fini
@since 11/2025
/*/
Function A400PosVld(oModel)

	Local lRet      := .T. as boolean
	Local nX        := 1 as numeric
	Local oModelDKA := nil as object
	Local oModelSD1 := nil as object

	Default oModel := FwModelActive()

	oModelDKA := oModel:GetModel("DKADETAIL")
	oModelSD1 := oModel:GetModel("SD1DETAIL")

	if isBlind() .and. (!FwAliasInDic("DKN") .or. !(DKA->(FieldPos("DKA_CSDXML")) > 0))
		lRet := .F.
		Help(NIL, NIL, "A400PosVld", NIL, STR0021, 1, 0, NIL, NIL, NIL, NIL, NIL,)//"Há dicionário de dados ausentes e são necessários para o funcionamento da rotina, verifique a existência da tabela DKN e campo DKA_CSDXML"
	endif

	if lRet .and. (oModelSD1:SeekLine({{"D1_ITXML","  "}}))
		lRet := .F.
		Help(NIL, NIL, "A400PosVld", NIL, STR0016 + Alltrim(oModelSD1:GetValue("D1_COD"))+" / "+oModelSD1:GetValue("D1_ITEM"), 1, 0, NIL, NIL, NIL, NIL, NIL,)//"Preencher o item XML do produto/item NF "
	endif

	if lRet .and. (oModelDKA:SeekLine({{"DKA_ITXML","  "}}))
		lRet := .F.
		Help(NIL, NIL, "A400PosVld", NIL, STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL,)//"Realize a consolidação dos itens clicando em Outras ações > Consolidar Itens"
	endif

	if lRet .and. !empty(oModelDKA:GetValue("DKA_ITXML"))
		for nX := 1 to oModelSD1:Length()
			oModelSD1:GoLine(nX)
			if !oModelSD1:IsDeleted() .and. !(oModelDKA:SeekLine({{"DKA_ITXML",oModelSD1:GetValue("D1_ITXML")},{"DKA_PRODUT",oModelSD1:GetValue("D1_COD")}}))
				lRet := .F.
				//"O produto/item NF " ## " Não foi encontrado nos dados consolidados, realize a atualização da consolidação clicando em 'Outras Ações > 'Consolidar Itens'"
				Help(NIL, NIL, "A400PosVld", NIL, STR0018 + Alltrim(oModelSD1:GetValue("D1_COD"))+" / "+ oModelSD1:GetValue("D1_ITEM");
					+ STR0019, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				exit
			endif
		next nX
	endif

	oModelSD1:GoLine(1)
	oModelDKA:GoLine(1)

Return lRet

/*/{Protheus.doc} clearCons
	Limpa a consolidação dos dados.

	@oModelDKA = Modelo ativo
@author Leandro Fini
@since 11/2025
/*/
Static Function clearCons(oModel, nOpc)

	Local nX      := 1 as numeric
	Local oModelDKA := nil as object
	Local lOk       := .T. as boolean

	Default oModel := FwModelActive()
	Default nOpc := 1

	oModelDKA := oModel:GetModel("DKADETAIL")

	if nOpc == 1 .and. !isBlind() .and. !empty(oModelDKA:GetValue("DKA_ITXML")) .and.  !MsgYesNo(STR0020)//"Deseja limpar os dados consolidados?"
		lOk := .F.
	endif

	if !empty(oModelDKA:GetValue("DKA_ITXML")) .and. lOk
		oModelDKA:SetNoDeleteLine(.F.)

		for nX := 1 to oModelDKA:Length()

			oModelDKA:GoLine(nX)

			oModelDKA:DeleteLine()

		next nX

		oModelDKA:SetNoDeleteLine(.T.)
	endif

Return

/*/{Protheus.doc} A400DELDKA
	
    Deleta a DKA vinculada ao documento passado via parametro
@author Leandro Fini
@since 11/2025
/*/
Function A400DELDKA(cDoc,cSerie,cForn,cLoja)

	Default cDoc   := ""
	Default cSerie := ""
	Default cForn  := ""
	Default cLoja  := ""

	DbSelectArea("DKA")
	DKA->(DbSetOrder(1))// DKA_FILIAL, DKA_DOC, DKA_SERIE, DKA_FORNEC, DKA_LOJA, DKA_ITXML

	if DKA->(FieldPos("DKA_CSDXML")) > 0

		if DKA->(Msseek(fwxFilial("DKA") + cDoc + cSerie + cForn + cLoja))
			while DKA->(!Eof()) .and. DKA->DKA_DOC == cDoc .and. DKA->DKA_SERIE == cSerie .and. DKA->DKA_FORNEC == cForn .and. DKA->DKA_LOJA == cLoja
				if DKA->DKA_CSDXML == "2" //-- Registro criado pelo Complemento de Itens XML
					Reclock("DKA",.F.)
					DKA->(DbDelete())
					DKA->(MsUnlock())
				endif

				DKA->(DbSkip())
			enddo
		endif

	endif

Return
