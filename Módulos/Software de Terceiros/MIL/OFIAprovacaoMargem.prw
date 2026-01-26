#include 'protheus.ch'
#include 'TopConn.ch'

Class OFIAprovacaoMargem from VERegistroSQL
	method New() constructor
	method rejectCredit(oReq)
	method salvaMotivos(oMotivos)
	method aprovaDesc()
EndClass

/*/{Protheus.doc} New
	Método construtor da classe
	@author Renan Migliaris
	@since 26/03/2025
/*/
Method new() class OFIAprovacaoMargem
	_Super:new('VS6')
    ::AddFields({;
        'R_E_C_N_O_', 'VS6_FILIAL', 'VS6_DOC', 'VS6_NUMIDE', 'VS6_DATOC0',;
        'VS6_HOROC0', 'VS6_TIPITEM', 'VS6_TIPOCO', 'VS6_DESOCO', 'VS6_USUARI',;
        'VS6_LIBPRO', 'VS6_DATAUT', 'VS6_HORAUT', 'VS6_NUMORC', 'VS6_TIPAUT',;
        'VS6_CODCLI', 'VS6_LOJA', 'VS6_OBSMEM', 'VS6_FORPAG', 'VS6_LIBVOO',;
        'VS6_USUARL', 'VS6_DATREJ', 'VS6_HORREJ', 'VS6_MOTREJ', 'VS6_DESPER',;
        'VS6_PERREM', 'D_E_L_E_T_' })
	::PermiteAssign({;
		'VS6_USUREJ','VS6_DATREJ', 'VS6_HORREJ', 'VS6_MOTREJ','VS6_NUMORC';
	})

	::SetPKField(::cQAlias + "VS6_NUMIDE")
return self

/*/{Protheus.doc} rejectCredit
	Realiza a rejeição da análise de crédito
	Vai receber o json do request para realziar as gravações necessárias
	No payload enviado pelo front deverão ser enviados além do motivo da rejeição 
	As respostas dos questionários presentes na tabela  VDS (que foram fornecedias por outro endpoint)
	@author Renan Migliaris
	@since 27/03/2025
/*/
Method rejectCredit(oReq) class OFIAprovacaoMargem
	local lRet 		:= .t.
	local cOrigem 	:= ''
	local oSaveVdt 	:= JsonObject():new() 

	If OXA015REJ(/*cAlias*/,/*nReg*/,/*nOpc*/,oReq)
		oSaveVdt["tipoAssunto"	]	:= "000016"
		oSaveVdt["tipoOrigem"	] 	:= cOrigem
		oSaveVdt["filialOrigem"	]	:= VS6->VS6_FILIAL
		oSaveVdt["codOrigem"	]	:= VS6->VS6_NUMORC
		oSaveVdt["codMot"		]	:= oReq["VDS_CODMOT"]
		//a função abaixo é chamada na OFIXA015 para a gravação de motivo  
		// OFA210VDT("000016",oReq["codmot"],cOrigem,VS6->VS6_FILIAL,VS6->VS6_NUMORC,oReq["formmot"])
		::salvaMotivos(oReq["questions"], oSaveVdt)
		VS6->(DbCloseArea())
	endif
return lRet

/*/{Protheus.doc} New
	Salva os motivos de rejeição na tabela VDT
	@author Renan Migliaris
	@since 26/03/2025
/*/
method salvaMotivos(aMotivos, oSaveVdt) class OFIAprovacaoMargem
   local lRet      := .t.
   local i         := 0
   local cTime     := Time()
   local aMotFunc  := {}
   cTime := SubStr(cTime, 1, 2) + SubStr(cTime, 4, 2)

   	if Len(aMotivos) == 0
   		oSaveVdt["reason"] := ''
   		oSaveVdt["codMot"] := ''
   		aAdd(aMotFunc, { "", "", "", "", "", "", "", "", 0 })
  	else
		for i := 1 to Len(aMotivos)
		aAdd(aMotFunc, { ;
			aMotivos[i]["label"], ;        
			aMotivos[i]["value"], ;        
			aMotivos[i]["VDS_CPOCOD"], ;   
			"", "", ;                      
			aMotivos[i]["VDS_CPOPIC"], ;   
			"", "", ;                      
			0 })                           
		next
	endif
	
   	OFA210VDT(;
      oSaveVdt["tipoAssunto"], ;
      oSaveVdt["reason"], ;
      oSaveVdt["tipoOrigem"], ;
      oSaveVdt["filialOrigem"], ;
      oSaveVdt["codOrigem"], ;
      aMotFunc )
return lRet

/*/{Protheus.doc} aprovar
    Realiza a aprovação de margem e desconto
    @author Renan Migliaris
    @since 03/07/2025
    @version version
    @param cId, char, id da aprovação
    @param cText, char, texto do motivo 
    @return oResult, JsonObject (statusCode e message)
/*/
Method aprovaDesc(cId, cText) class OFIAprovacaoMargem
	Local jLiberacao := JsonObject():New()
	Local oResult := JsonObject():New()
	Local oMessages := OFIMensagensPadrao():New()
	Local cQuery := ""
	Local cFinalQuery := ''
	Local lRet := .t.
	Local oStatement := FWPreparedStatement():New()
	local aPeca := JsonObject():New()
	local aServico := JsonObject():New()
	Default cText := ""

	VS6->(DbSetOrder(1))
	VS6->(DbSeek(xFilial("VS6") + cId))

	cQuery := "SELECT * "
	cQuery += "FROM " + RetSqlName("VS7") + " VS7 "
	cQuery += "WHERE "
	cQuery += " VS7.VS7_FILIAL = '" + xFilial("VS7") + "' AND "
	cQuery += " VS7.VS7_NUMIDE = ? AND "
	cQuery += " VS7.D_E_L_E_T_ = ' ' "

	//Define a consulta e os parâmetros
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1,cId)
	cFinalQuery := oStatement:GetFixQuery()

	TCQuery cFinalQuery New Alias "TMPVS7"

	// Montagem do JSON de liberação
	jLiberacao["VS6_OBSERV"] := cText
	jLiberacao["Pecas"]  := {}
	jLiberacao["Servicos"] := {}

	If Empty(TMPVS7->VS7_NUMIDE)
		oResult["status"]  := 404
		oResult["message"] := encodeUTF8(oMessages:ERR_DADOS_NAO_ENCONTRADOS)
		TMPVS7->(DbCloseArea())
		VS6->(DbCloseArea())
		Return oResult
	EndIf

	While !TMPVS7->(Eof())
		aPeca := JsonObject():New()
		aServico := JsonObject():New()

		If !Empty(TMPVS7->VS7_CODITE)
			aPeca["VS7_CODITE"] := TMPVS7->VS7_CODITE
			aPeca["VS7_DIVERG"] := TMPVS7->VS7_DIVERG
			aPeca["VS7_SEQUEN"] := TMPVS7->VS7_SEQUEN
			aadd(jLiberacao["Pecas"], aPeca)
		EndIf

		If !Empty(TMPVS7->VS7_CODSER)
			aServico["VS7_CODSER"] := TMPVS7->VS7_CODSER
			aServico["VS7_DIVERG"] := TMPVS7->VS7_DIVERG
			aServico["VS7_SEQUEN"] := TMPVS7->VS7_SEQUEN
			aadd(jLiberacao["Servicos"], aServico)
		EndIf

		TMPVS7->(DbSkip())
	EndDo

	// Realiza a liberação
	lRet := OX0030032_Libera(4, .T., jLiberacao)

	TMPVS7->(DbCloseArea())
	VS6->(DbCloseArea())

	If lRet
		oResult["status"]  := 200
		oResult["message"] := encodeUTF8(oMessages:SUCCESS_REQUEST_CONCLUIDO)
	Else
		oResult["status"]  := 400
		oResult["message"] := encodeUTF8(oMessages:ERR_ERRO_LIBERACAO_DESCONTO)
	EndIf

Return oResult
