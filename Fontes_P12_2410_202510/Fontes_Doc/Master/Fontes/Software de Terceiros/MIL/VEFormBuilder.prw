#include 'totvs.ch''
#include "parmtype.ch"
#Include "TOPCONN.CH"

/*/{Protheus.doc} VEFormBuilder
	A classe visa criar formulários dinânimicos
	Em alguns casos, poderá ser olhando alguma tabela de questionários como os motivos de rejeição por exemplo
	Mas a ideia é que ela faça isso também olhando o dicionário de dados, trazendo um form básico de maneira dinâmica
	Caso seja adicionado um novo campo na tabela, o request que chama essa classse já montaria o novo formulário no front do usuário
	@author Renan Migliaris
	@since 28/03/2025	
/*/
Class VEFormBuilder from LongNameClass
	public data form as object

	method new() constructor
	method getFromSx3(aCampos)
	method getFromVds(cCod)
	method tipToPoUi(cTipo)
	method setPoOpt(cBox)
	method _handleCustomFields(aCustom)
	// method execPe(aFields, aPeFields)
EndClass

/*/{Protheus.doc} VEFormBuilder
	Método construtor da classe
	@author Renan Migliaris
	@since 28/03/2025	
/*/
method new() class VEFormBuilder
	self:form := nil
return self

method getFromVds(cCod, cCodMot) class VEFormBuilder
	local cQuery 	:= ''
	Local cFinalQuery := ''
	Local oStatement := FWPreparedStatement():New()
	default cCod 	:= "000016" //código default na aprovação de margem retirado da chamada da OFIOA210VDT na OFIXA015
	default cCodMot := "000001"
	oResp	:= nil
	oJAux 	:= nil
	aCampos := {}

	cQuery :=  " SELECT " 
	cQuery +=  " VDS.R_E_C_N_O_,VDS.D_E_L_E_T_,VDS.VDS_FILIAL,VDS.VDS_TIPASS,VDS.VDS_CODMOT,VDS.VDS_CPOCOD,VDS.VDS_CPOSEQ,VDS.VDS_CPOTIT,VDS.VDS_CPOTIP,VDS.VDS_CPOTAM,VDS.VDS_CPOPIC,VDS.VDS_CPOOBR "
	cQuery +=  " FROM "+ RetSqlName("VDS") + " VDS "
	cQuery +=  " WHERE "
	cQuery += " VDS.VDS_FILIAL = '"+xFilial("VDS")+"'"
	cQuery += " AND VDS.VDS_TIPASS = ?"
	cQuery += " AND VDS.VDS_CODMOT = ?"
	cQuery += " AND VDS.D_E_L_E_T_ = ' '"

	//Define a consulta e os parâmetros
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1,cCod)
	oStatement:SetString(2,cCodMot)
	cFinalQuery := oStatement:GetFixQuery()

	TcQuery cFinalQuery New Alias "TMPVDS"

	While !TMPVDS->(Eof())
		oJaux := JsonObject():new()
		
		oJaux["property"	] 	:= "VDS_CPOCOD_"+TMPVDS->VDS_CPOCOD
		oJaux['label'		] 	:= encodeUTF8(TMPVDS->VDS_CPOTIT)
		oJaux['type'		] 	:= ::tipToPoUi(TMPVDS->VDS_CPOTIP)
		oJaux['maxLength'	] 	:= TMPVDS->VDS_CPOTAM
		if TMPVDS->VDS_CPOOBR == "1" //verificando se a resposta da pergunta é obrigatória no form 
			oJaux['required'		]	:= .t.
			oJaux['showRequired'	]	:= .t.
		endif
		oJaux['VDS_CPOCOD'	]	:= TMPVDS->VDS_CPOCOD
		oJaux['VDS_CPOSEQ'	]	:= TMPVDS->VDS_CPOSEQ
		oJaux['VDS_CODMOT'	]	:= TMPVDS->VDS_CODMOT
		oJaux['VDS_CPOPIC'	]	:= TMPVDS->VDS_CPOPIC
		
		aadd(aCampos, oJaux)
		freeobj(oJaux)
		TMPVDS->(DbSkip())
	endDo

	TMPVDS->(DbCloseArea())

	
	oResp := JsonObject():new()
	oResp["form"]	:= aCampos

return oResp:toJson()

/*/{Protheus.doc} tipToPoUi
	Método do builder para tratar os tipos registrados 
	C -> String
	N -> Number
	D -> Date
	@type  Static Function
	@author Renan Migliaris
	@since 28/03/2025	
/*/
method tipToPoUi(cTipo) class VEFormBuilder
	
	if cTipo == "C" .or. cTipo == "M"
		cTipo := "string"
	elseif cTipo == "N"
		cTipo := "number"
	elseif cTipo == "D"
		cTipo := "date"
	endif

Return cTipo

/*/{Protheus.doc} getFromSx3
	Método que irá retornar um form PO-UI dinamicamente 
	Os campos deverão ser setados na propriedade da classe aCampos
	que nada mais é do que um array.
	Além disso, o método também poderá receber um array de campos customizados (que não estão presentes no dicionário)
	Esse array será composto por dois arrays, sendo o primeiro a estrutura do Form que será enviada via Json e suas respectivas propriedades para o casting no front-end
	algo parecido com o que temos hoje que temos hoje nas classes que herdam a FWAdapterBaseV2
	Exemplo de array {"VAI_NOMTEC", "VAI_CODTEC", "VAI_CODUSR"} 
	O método irá "olhar" para a SX3 pelo campo X3_CAMPO do qual partirá o form a ser construído pelo Front-End
	@author Renan Migliaris
	@since 28/03/2025	
/*/
method getFromSx3(aCampos, aCustom) class VEFormBuilder
	local oForm 		 := nil
	local oJAux			 := nil
	local ni			 := 0
	local aForm			 := {}
	local aHandledCustom := {}
	
	default aCustom 	 := {}

	oForm := JsonObject():new()
	
	for ni := 1 to len(aCampos)
		if empty(getSx3Cache(aCampos[ni], "X3_CAMPO"))
			loop
		endif
		
		oJaux := JsonObject():new()
		oJaux["property"		] 	:= lower(getSx3Cache(aCampos[ni], "X3_CAMPO"))
		oJaux["label"			]	:= encodeUtf8(alltrim(getSx3Cache(aCampos[ni], "X3_DESCRIC")))
		oJaux["maxLength"		]	:= getSx3Cache(aCampos[ni], "X3_TAMANHO")
		oJaux["order"			]	:= ni //TODO posso também pegar a X3_ORDEM, entretanto é necessário estudar como lidar com origens diferentes. A princípio pega a ordem do array 
		oJaux["gridColumns"		]  	:= 6
		oJaux["gridSmColumns"	]	:= 12
		oJaux["type"			]	:= ::tipToPoUi(getSx3Cache(aCampos[ni], "X3_TIPO"))
		
		if !empty(getSx3Cache(aCampos[ni], "X3_OBRIGAT"))
			oJaux["required"		]	:= .t.
			oJaux["showRequired"	]	:= .t.
		endif
		
		if !Empty(getSx3Cache(aCampos[ni], "X3_CBOX"))
			oJaux["options"] := self:setPoOpt(getSx3Cache(aCampos[ni], "X3_CBOX"))
			oJaux:DelName("maxLength")
		endif
		
		if !Empty(getSx3Cache(aCampos[ni], "X3_VISUAL")) .and. getSx3Cache(aCampos[ni], "X3_VISUAL") == "V" 
			oJaux["disabled"] := .t.
		endif

		aadd(aForm, oJaux)
		freeobj(oJaux)
	next

	if len(aCustom) > 0
		aHandledCustom := self:_handleCustomFields(aCustom)

		for ni := 1 to len(aHandledCustom)
			aadd(aForm, aHandledCustom[ni])
		next
	endif

	oForm["form"] := aForm
	self:form := aForm
return oForm:toJson()

/*/{Protheus.doc} setPoOpt
	Função responsável por lidar com campos cBox da X3, de forma com que ele retorne um objeto válido para ser usado no PO-UI
	@type  Static Function
	@author Renan Migliaris
	@since 31/03/2025
/*/
method setPoOpt(cBox) class VEFormBuilder
	local oJaux		:= nil
	local aOpts 	:= {}
	local aCbox		:= {}
	local ni 		:= 0
	local cToken	:= ''
	local nPos		:= 0

	aCbox := StrTokArr(cBox, ";")

	for ni := 1 to len(aCbox)
		cToken := alltrim(aCbox[ni])
		nPos := At("=", cToken)
		oJaux := JsonObject():new()
		oJaux["label"] 	:= cToken
		oJaux["value"]	:= alltrim(substr(cToken, 1, npos - 1))
		aadd(aOpts, oJaux)
		freeobj(oJaux)
 	next

Return aOpts

/*/{Protheus.doc} _handleCustomFields
	Nesse método ele vai realizar o tratamento dos campos privados 
	ou seja campos que por algum motivo desejo exibir no front-end porém não eu não os tenho no dicionário
	A estrutura do array vai ser composto pelo seguinte formato {{aStru}, {aProps}}
	Lembrando que o array "aStru" tem que ser um array de string, se não o front vai de F
	sendo que o segundo array será um array de arrays. 
	@author Renan Migliaris 
	@since 31/08/2025
	/*/
Method _handleCustomFields(aCustomFields) class VEFormBuilder
	local aJson := {}
	local oJson := nil
	local nValue, nKey
	local aKeys := aCustomFields[1]
	local aValues := aCustomFields[2]

	for nValue := 1 to len(aValues)
		oJson := JsonObject():new()
		
		//montando o formulário brabo com as props a partir do primeiro array
		for nKey := 1 to len(aKeys)
			oJson[aKeys[nKey]] := aValues[nValue][nKey]
		next

		aadd(aJson, oJson)
		FreeObj(oJson)
	next
Return aJson

/*/{Protheus.doc} execPe
	Método que irá ajustar os campos do array original da rotina com os campos solicitados no ponto de entrada
	@author Renan Migliaris
	@since 18/06/2025
	@version version
	@param aFields, array, array original (passado por referência)
	@param aPeFields, array, array ennviado pelo ponto de entrada
	@return aFields, array, array já ajustado
	/*/
// Method execPe(aFields, aPeFields) class VEFormBuilder
// 	local nx := 0

// 	for nx := 1 to len(aPeFields)
// 		if aScan(aFields, aPeFields[nx]) == 0 //verifico se já está presente nos campos originais da rotina para que não gere properties duplicadas
// 			aadd(aFields, aPeFields[nx])
// 		endif
// 	next
	
// Return aFields
