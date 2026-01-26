#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc}  MESA OPERACIONAL PO-UI

Classe WSRESTFUL - API Web Service RESTFUL - Mesa Operacional PO UI

@Metodos WSMETHOD

@author     Serviços - Mesa Operacional PO UI
@since      10/04/2024
/*/
//------------------------------------------------------------------------------
WSRESTFUL TECWSALOC DESCRIPTION "Mesa Operacional - Alocações"

	WSDATA cFil      AS STRING //Filial
	WSDATA cContrato AS STRING //Código Contrato
	WSDATA cRevisao  AS STRING //Código Revisão
	WSDATA cTFL      AS STRING //Código do Local (TFL)

	//FOLGA TRABALHADA / ALOCAÇÃO POR HORA
	WSMETHOD GET fthArea		 DESCRIPTION 'Filtro Area FT/Hora trabalhada'		PATH "fthArea"		PRODUCES APPLICATION_JSON	
	WSMETHOD POST fthFuncao		 DESCRIPTION 'Filtro Função FT/Hora trabalhada'		PATH "fthFuncao"	PRODUCES APPLICATION_JSON	
	WSMETHOD POST fthAtend		 DESCRIPTION 'Filtro Atendente FT/Hora trabalhada'	PATH "fthAtend"		PRODUCES APPLICATION_JSON	
	WSMETHOD POST fthCliente	 DESCRIPTION 'Filtro Cliente FT/Hora trabalhada'	PATH "fthCliente"	PRODUCES APPLICATION_JSON	
	WSMETHOD POST fthContrat	 DESCRIPTION 'Filtro Contrato FT/Hora trabalhada'	PATH "fthContrat"	PRODUCES APPLICATION_JSON	
	WSMETHOD POST fthLocal		 DESCRIPTION 'Filtro Local FT/Hora trabalhada'		PATH "fthLocal"		PRODUCES APPLICATION_JSON	
	WSMETHOD POST fthPosto		 DESCRIPTION 'Filtro Posto FT/Hora trabalhada'		PATH "fthPosto"		PRODUCES APPLICATION_JSON	
	WSMETHOD POST fthBuscar		 DESCRIPTION 'Botão Buscar FT/Hora trabalhada'		PATH "fthBuscar"	PRODUCES APPLICATION_JSON	
	WSMETHOD GET contFTH		 DESCRIPTION 'Buscar contratos para alocação'		PATH "contFTH"		PRODUCES APPLICATION_JSON	
	WSMETHOD GET locaisFTH		 DESCRIPTION 'Buscar locais para alocação'			PATH "locaisFTH"	PRODUCES APPLICATION_JSON	
	WSMETHOD GET postosFTH		 DESCRIPTION 'Buscar postos para alocação'			PATH "postosFTH"	PRODUCES APPLICATION_JSON	
	WSMETHOD POST projFT		 DESCRIPTION 'Projeção de Folga Trabalhada'			PATH "projFT"		PRODUCES APPLICATION_JSON	
	WSMETHOD POST projAlocHora	 DESCRIPTION 'Projeção de Alocação por hora'		PATH "projAlocHora" PRODUCES APPLICATION_JSON	
	WSMETHOD POST gravFT		 DESCRIPTION 'Gravação de Folga Trabalhada'			PATH "gravFT"		PRODUCES APPLICATION_JSON	
	WSMETHOD POST gravAlocHora	 DESCRIPTION 'Gravação de Alocação por hora'		PATH "gravAlocHora" PRODUCES APPLICATION_JSON

END WSRESTFUL

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método GET de Áreas para fluxo de FT e Alocação por Hora

@Param cFil - filial(String) - Apenas uma (Combo Box no front)

@author     Jack Junior
@since      04/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET fthArea WSRECEIVE cFil WSREST TECWSALOC
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cWhereTGS := ''

cFilTMP := self:cFil

cWhereTGS := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "TGS", "TGS", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT TGS.TGS_COD, TGS.TGS_DESCRI
    FROM %table:TGS% TGS
        WHERE %exp:cWhereTGS%
            AND TGS.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Area'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['Area'], JsonObject():New())
		aTail(oResponse['Area'])['codigo']	:= AllTrim((cAliasTmp)->TGS_COD)
		aTail(oResponse['Area'])['desc']	:= EncodeUTF8(AllTrim((cAliasTmp)->TGS_DESCRI))
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método POST de Funções para fluxo de FT e Alocação por Hora

@Param cBody Exemplo1: 
{
    "filial":"D MG 01 ",
    "areas":[{"value":"000001"},{"value":"000002"}]
}

Exemplo2: (sem areas selecionadas no front-end)
{
    "filial":"D MG 01 ",
    "areas":[]
}

@author     Jack Junior
@since      04/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST fthFuncao WSREST TECWSALOC
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cInArea	:= ""
Local cFilTMP   := ""
Local cWhereArea:= ""
Local aArea		:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP	:= oParamBody['filial']
aArea	:= oParamBody['areas']

//Monta o where de clientes com base na seleção do filtro anterior no Front-End
If ValType(aArea) = 'U' .Or. Len(aArea) = 0
	cWhereArea := "1 = 1"
ElseIf Len(aArea) = 1
	cWhereArea := "TGS.TGS_COD = '" + aArea[1]["value"]  + "'"
Else
	For nX = 1 To Len(aArea)
		If nX > 1
			cInArea += ","
		EndIf
		cInArea +=  "'" + aArea[nX]["value"]  + "'"
	Next nX
	cWhereArea := "TGS.TGS_COD IN ("+cInArea+")"
EndIf

cWhereArea := sqlEmbeded(cWhereArea)

cJoinAA1  := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "SRJ", "AA1", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "AA1", "TGY", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TGY", "TFF", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL", "AA1", "SRA", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cWhereSRJ := JoinSQL(lMultFil, "SRJ.RJ_FILIAL", "SRJ", "SRJ", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT SRJ.RJ_FUNCAO, SRJ.RJ_DESC
    FROM %table:SRJ% SRJ
		LEFT JOIN %table:AA1% AA1 
			ON %exp:cJoinAA1% 
			AND AA1.AA1_FUNCAO = SRJ.RJ_FUNCAO
			AND AA1.%NotDel%
		LEFT JOIN %table:TGY% TGY 
			ON %exp:cJoinTGY% 
			AND TGY.TGY_ATEND = AA1.AA1_CODTEC
			AND TGY.%NotDel%
		LEFT JOIN %table:TFF% TFF 
			ON %exp:cJoinTFF% 
			AND TFF.TFF_COD = TGY.TGY_CODTFF
			AND TFF.%NotDel%
		LEFT JOIN %table:TFL% TFL 
			ON %exp:cJoinTFL% 
			AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
			AND TFL.%NotDel%
		LEFT JOIN %table:TFJ% TFJ 
			ON %exp:cJoinTFJ% 
			AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
			AND TFJ.%NotDel%
		LEFT JOIN %table:CN9% CN9 
			ON %exp:cJoinCN9% 
			AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT 
			AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
			AND CN9.%NotDel%
		LEFT JOIN %table:SRA% SRA 
			ON %exp:cJoinSRA% 
			AND SRA.RA_MAT = AA1.AA1_CDFUNC
			AND SRA.%NotDel%
		LEFT JOIN %table:ABS% AB 
			ON %exp:cJoinABS% 
			AND AB.ABS_LOCAL = TFL.TFL_LOCAL
			AND AB.%NotDel%
		LEFT JOIN %table:TGS% TGS 
			ON %exp:cJoinTGS% 
			AND TGS.TGS_COD = AB.ABS_CODSUP
			AND TGS.%NotDel%
	WHERE %exp:cWhereSRJ%
		AND %exp:cWhereArea%
        AND SRJ.%NotDel%
		AND CN9.CN9_SITUAC = '05'
  		AND TFJ.TFJ_STATUS = '1'
	GROUP BY SRJ.RJ_FUNCAO, SRJ.RJ_DESC
	ORDER BY SRJ.RJ_FUNCAO
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Funcao'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['Funcao'], JsonObject():New())
		aTail(oResponse['Funcao'])['codigo'] := AllTrim((cAliasTmp)->RJ_FUNCAO)
		aTail(oResponse['Funcao'])['desc']	 := EncodeUTF8(AllTrim((cAliasTmp)->RJ_DESC))
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL
return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método POST de Atendentes para fluxo de FT e Alocação por Hora

@Param cBody Exemplo1: 
{
    "filial":"D MG 01 ",
    "areas":[{"value":"000001"}],
    "funcoes":[{"value":"00002"},{"value":"00003"}]
}

Exemplo2: (sem areas e funções selecionadas no front-end)
{
    "filial":"D MG 01 ",
    "areas":[],
	"funcoes":[]
}

@author     Jack Junior
@since      04/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST fthAtend WSREST TECWSALOC
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cFilTMP   := ""
Local cInArea	:= ""
Local cInFunc	:= ""
Local cWhereArea:= ""
Local cWhereFunc:= ""
Local cJoinSRJ  := ""
Local cJoinTGY  := ""
Local cJoinTFF  := ""
Local cJoinTFL  := ""
Local cJoinTFJ  := ""
Local cJoinCN9  := ""
Local cJoinSRA  := ""
Local cJoinABS  := ""
Local cJoinTGS  := ""
Local cWhereAA1 := ""
Local aArea		:= {}
Local aFuncoes	:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP	:= oParamBody['filial']
aArea	:= oParamBody['areas']
aFuncoes:= oParamBody['funcoes']

//Monta o where de Areas com base na seleção do filtro anterior no Front-End
If ValType(aArea) = 'U' .Or. Len(aArea) = 0
	cWhereArea := "1 = 1"
ElseIf Len(aArea) = 1
	cWhereArea := "TGS.TGS_COD = '" + aArea[1]["value"]  + "' AND TGY.TGY_ULTALO != ' '"
Else
	For nX = 1 To Len(aArea)
		If nX > 1
			cInArea += ","
		EndIf
		cInArea +=  "'" + aArea[nX]["value"]  + "'"
	Next nX
	cWhereArea := "TGS.TGS_COD IN ("+cInArea+") AND TGY.TGY_ULTALO != ' '"
EndIf

cWhereArea := sqlEmbeded(cWhereArea)

//Monta o where de Funcoes com base na seleção do filtro anterior no Front-End
If ValType(aFuncoes) = 'U' .Or. Len(aFuncoes) = 0
	cWhereFunc := "1 = 1"
ElseIf Len(aFuncoes) = 1
	cWhereFunc := "SRJ.RJ_FUNCAO = '" + aFuncoes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aFuncoes)
		If nX > 1
			cInFunc += ","
		EndIf
		cInFunc +=  "'" + aFuncoes[nX]["value"]  + "'"
	Next nX
	cWhereFunc := "SRJ.RJ_FUNCAO IN ("+cInFunc+")"
EndIf

cWhereFunc := sqlEmbeded(cWhereFunc)

cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL", "AA1", "SRJ", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "AA1", "TGY", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TGY", "TFF", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL", "AA1", "SRA", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cWhereAA1 := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "AA1", "AA1", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT AA1.AA1_CODTEC, 
			AA1.AA1_NOMTEC, 
			COALESCE(SRA.RA_MAT, ' ') AS RA_MAT
    FROM %table:AA1% AA1
		LEFT JOIN %table:SRJ% SRJ 
			ON %exp:cJoinSRJ% 
			AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO
			AND SRJ.%NotDel%
		LEFT JOIN %table:TGY% TGY 
			ON %exp:cJoinTGY% 
			AND TGY.TGY_ATEND = AA1.AA1_CODTEC
			AND TGY.%NotDel%
		LEFT JOIN %table:TFF% TFF 
			ON %exp:cJoinTFF% 
			AND TFF.TFF_COD = TGY.TGY_CODTFF
			AND TFF.%NotDel%
		LEFT JOIN %table:TFL% TFL 
			ON %exp:cJoinTFL% 
			AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
			AND TFL.%NotDel%
		LEFT JOIN %table:TFJ% TFJ 
			ON %exp:cJoinTFJ% 
			AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
			AND TFJ.%NotDel%
		LEFT JOIN %table:CN9% CN9 
			ON %exp:cJoinCN9% 
			AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT 
			AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
			AND CN9.%NotDel%
		LEFT JOIN %table:SRA% SRA 
			ON %exp:cJoinSRA% 
			AND SRA.RA_MAT = AA1.AA1_CDFUNC
			AND SRA.%NotDel%
		LEFT JOIN %table:ABS% AB 
			ON %exp:cJoinABS% 
			AND AB.ABS_LOCAL = TFL.TFL_LOCAL
			AND AB.%NotDel%
		LEFT JOIN %table:TGS% TGS 
			ON %exp:cJoinTGS% 
			AND TGS.TGS_COD = AB.ABS_CODSUP
			AND TGS.%NotDel%
	WHERE %exp:cWhereAA1%
		AND %exp:cWhereArea%
		AND %exp:cWhereFunc%
        AND AA1.%NotDel%
		AND AA1.AA1_ALOCA = '1'
	GROUP BY AA1.AA1_CODTEC, AA1.AA1_NOMTEC, SRA.RA_MAT
	ORDER BY AA1.AA1_CODTEC
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Atendente'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['Atendente'], JsonObject():New())
		aTail(oResponse['Atendente'])['codigo']		:= AllTrim((cAliasTmp)->AA1_CODTEC)
		aTail(oResponse['Atendente'])['desc']		:= EncodeUTF8(AllTrim((cAliasTmp)->AA1_NOMTEC))
		aTail(oResponse['Atendente'])['matricula']	:= AllTrim((cAliasTmp)->RA_MAT)
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método POST de Clientes para Filtro no fluxo de FT e Alocação por Hora

@Param cBody Exemplo1: 
{
    "filial":"D MG 01 ",
    "areas":[{"value":"000001"}],
    "funcoes":[{"value":"00002"},{"value":"00003"}],
	"atendentes":[{"value":"00000000000028"},{"value":"D MG 01 000001"}]
}

Exemplo2: (filtros anteriores do front-end sem seleções)
{
    "filial":"D MG 01 ",
    "areas":[],
	"funcoes":[],
	"atendentes":[]
}

@author     Jack Junior
@since      04/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST fthCliente WSREST TECWSALOC
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cFilTMP   := ""
Local cInArea	:= ""
Local cInFunc	:= ""
Local cInAtend	:= ""
Local cWhereArea:= ""
Local cWhereAtend:= ""
Local cWhereFunc:= ""
Local cJoinSRJ  := ""
Local cJoinTGY  := ""
Local cJoinTFF  := ""
Local cJoinTFL  := ""
Local cJoinTFJ  := ""
Local cJoinCN9  := ""
Local cJoinSRA  := ""
Local cJoinABS  := ""
Local cJoinTGS  := ""
Local cJoinAA1	:= ""
Local cWhereSA1 := ""
Local aArea		:= {}
Local aFuncoes	:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP	:= oParamBody['filial']
aArea	:= oParamBody['areas']
aFuncoes:= oParamBody['funcoes']
aAtend  := oParamBody['atendentes']

//Monta o where de Areas com base na seleção do filtro anterior no Front-End
If ValType(aArea) = 'U' .Or. Len(aArea) = 0
	cWhereArea := "1 = 1"
ElseIf Len(aArea) = 1
	cWhereArea := "TGS.TGS_COD = '" + aArea[1]["value"]  + "' AND TGY.TGY_ULTALO != ' '"
Else
	For nX = 1 To Len(aArea)
		If nX > 1
			cInArea += ","
		EndIf
		cInArea +=  "'" + aArea[nX]["value"]  + "'"
	Next nX
	cWhereArea := "TGS.TGS_COD IN ("+cInArea+") AND TGY.TGY_ULTALO != ' '"
EndIf

cWhereArea := sqlEmbeded(cWhereArea)

//Monta o where de Funcoes com base na seleção do filtro anterior no Front-End
If ValType(aFuncoes) = 'U' .Or. Len(aFuncoes) = 0
	cWhereFunc := "1 = 1"
ElseIf Len(aFuncoes) = 1
	cWhereFunc := "SRJ.RJ_FUNCAO = '" + aFuncoes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aFuncoes)
		If nX > 1
			cInFunc += ","
		EndIf
		cInFunc +=  "'" + aFuncoes[nX]["value"]  + "'"
	Next nX
	cWhereFunc := "SRJ.RJ_FUNCAO IN ("+cInFunc+")"
EndIf

cWhereFunc := sqlEmbeded(cWhereFunc)

//Monta o where de Funcoes com base na seleção do filtro anterior no Front-End
If ValType(aAtend) = 'U' .Or. Len(aAtend) = 0
	cWhereAtend := "1 = 1"
ElseIf Len(aAtend) = 1
	cWhereAtend := "AA1.AA1_CODTEC = '" + aAtend[1]["value"]  + "'"
Else
	For nX = 1 To Len(aAtend)
		If nX > 1
			cInAtend += ","
		EndIf
		cInAtend +=  "'" + aAtend[nX]["value"]  + "'"
	Next nX
	cWhereAtend := "AA1.AA1_CODTEC IN ("+cInAtend+")"
EndIf

cWhereAtend := sqlEmbeded(cWhereAtend)

cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL", "AA1", "SRJ", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "SA1", "TFJ", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL", "AA1", "SRA", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cJoinAA1  := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "TGY", "AA1", cFilTMP, "JOIN")
cWhereSA1 := JoinSQL(lMultFil, "SA1.A1_FILIAL", "SA1", "SA1", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT SA1.A1_COD, 
			SA1.A1_LOJA,
			SA1.A1_NOME
    FROM %table:SA1% SA1
		LEFT JOIN %table:TFJ% TFJ 
			ON %exp:cJoinTFJ% 
			AND TFJ.TFJ_CODENT = SA1.A1_COD
			AND TFJ.TFJ_LOJA = SA1.A1_LOJA
			AND TFJ.%NotDel%
		LEFT JOIN %table:CN9% CN9 
			ON %exp:cJoinCN9% 
			AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT 
			AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
			AND CN9.%NotDel%
		LEFT JOIN %table:TFL% TFL 
			ON %exp:cJoinTFL% 
			AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO
			AND TFL.%NotDel%
		LEFT JOIN %table:TFF% TFF 
			ON %exp:cJoinTFF% 
			AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
			AND TFF.%NotDel%
		LEFT JOIN %table:TGY% TGY 
			ON %exp:cJoinTGY% 
			AND TGY.TGY_CODTFF = TFF.TFF_COD
			AND TGY.%NotDel%
		LEFT JOIN %table:AA1% AA1 
			ON %exp:cJoinAA1% 
			AND AA1.AA1_CODTEC = TGY.TGY_ATEND
			AND AA1.%NotDel%
		LEFT JOIN %table:SRJ% SRJ 
			ON %exp:cJoinSRJ% 
			AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO
			AND SRJ.%NotDel%
		LEFT JOIN %table:SRA% SRA 
			ON %exp:cJoinSRA% 
			AND SRA.RA_MAT = AA1.AA1_CDFUNC
			AND SRA.%NotDel%
		LEFT JOIN %table:ABS% AB 
			ON %exp:cJoinABS% 
			AND AB.ABS_LOCAL = TFL.TFL_LOCAL
			AND AB.%NotDel%
		LEFT JOIN %table:TGS% TGS 
			ON %exp:cJoinTGS% 
			AND TGS.TGS_COD = AB.ABS_CODSUP
			AND TGS.%NotDel%
	WHERE %exp:cWhereSA1%
		AND %exp:cWhereArea%
		AND %exp:cWhereFunc%
		AND %exp:cWhereAtend%
        AND SA1.%NotDel%
		AND CN9.CN9_SITUAC = '05'
  		AND TFJ.TFJ_STATUS = '1'
	GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME
	ORDER BY SA1.A1_COD
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Cliente'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['Cliente'], JsonObject():New())
		aTail(oResponse['Cliente'])['codigo']	:= AllTrim((cAliasTmp)->A1_COD)
		aTail(oResponse['Cliente'])['loja']	:= AllTrim((cAliasTmp)->A1_LOJA)
		aTail(oResponse['Cliente'])['nome']	:= EncodeUTF8(AllTrim((cAliasTmp)->A1_NOME))
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método POST de Contratos para Filtro no fluxo de FT e Alocação por Hora

@Param cBody Exemplo1: 
{
    "filial":"D MG 01 ",
    "areas":[{"value":"000001"}],
    "funcoes":[{"value":"00002"},{"value":"00003"}],
    "atendentes":[{"value":"D MG 01 000002"}],
    "clientes":[{"value":"00000101"}] //Cliente+Loja
}

Exemplo2: (filtros anteriores do front-end sem seleções)
{
    "filial":"D MG 01 ",
    "areas":[],
	"funcoes":[],
	"atendentes":[],
	"clientes":[]
}

@author     Jack Junior
@since      04/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST fthContrat WSREST TECWSALOC
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cFilTMP   := ""
Local cInArea	:= ""
Local cInFunc	:= ""
Local cInAtend	:= ""
Local cInCli	:= ""
Local cWhereArea:= ""
Local cWhereAtend:= ""
Local cWhereFunc:= ""
Local cWhereCli	:= ""
Local cJoinSRJ  := ""
Local cJoinTGY  := ""
Local cJoinTFF  := ""
Local cJoinTFL  := ""
Local cJoinCN9  := ""
Local cJoinSRA  := ""
Local cJoinABS  := ""
Local cJoinTGS  := ""
Local cJoinSA1	:= ""
Local cJoinAA1	:= ""
Local cWhereTFJ := ""
Local aArea		:= {}
Local aFuncoes	:= {}
Local aAtend	:= {}
Local aClientes	:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aArea		:= oParamBody['areas']
aFuncoes	:= oParamBody['funcoes']
aAtend		:= oParamBody['atendentes']
aClientes	:= oParamBody['clientes']

//Monta o where de Areas com base na seleção do filtro anterior no Front-End
If ValType(aArea) = 'U' .Or. Len(aArea) = 0
	cWhereArea := "1 = 1"
ElseIf Len(aArea) = 1
	cWhereArea := "TGS.TGS_COD = '" + aArea[1]["value"]  + "' AND TGY.TGY_ULTALO != ' '"
Else
	For nX = 1 To Len(aArea)
		If nX > 1
			cInArea += ","
		EndIf
		cInArea +=  "'" + aArea[nX]["value"]  + "'"
	Next nX
	cWhereArea := "TGS.TGS_COD IN ("+cInArea+") AND TGY.TGY_ULTALO != ' '"
EndIf

cWhereArea := sqlEmbeded(cWhereArea)

//Monta o where de Funcoes com base na seleção do filtro anterior no Front-End
If ValType(aFuncoes) = 'U' .Or. Len(aFuncoes) = 0
	cWhereFunc := "1 = 1"
ElseIf Len(aFuncoes) = 1
	cWhereFunc := "SRJ.RJ_FUNCAO = '" + aFuncoes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aFuncoes)
		If nX > 1
			cInFunc += ","
		EndIf
		cInFunc +=  "'" + aFuncoes[nX]["value"]  + "'"
	Next nX
	cWhereFunc := "SRJ.RJ_FUNCAO IN ("+cInFunc+")"
EndIf

cWhereFunc := sqlEmbeded(cWhereFunc)

//Monta o where de Atendentes com base na seleção do filtro anterior no Front-End
If ValType(aAtend) = 'U' .Or. Len(aAtend) = 0
	cWhereAtend := "1 = 1"
ElseIf Len(aAtend) = 1
	cWhereAtend := "AA1.AA1_CODTEC = '" + aAtend[1]["value"]  + "'"
Else
	For nX = 1 To Len(aAtend)
		If nX > 1
			cInAtend += ","
		EndIf
		cInAtend +=  "'" + aAtend[nX]["value"]  + "'"
	Next nX
	cWhereAtend := "AA1.AA1_CODTEC IN ("+cInAtend+")"
EndIf

cWhereAtend := sqlEmbeded(cWhereAtend)

//Monta o where de Clientes com base na seleção do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "SA1.A1_COD+SA1.A1_LOJA = '" + aClientes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli +=  "'" + aClientes[nX]["value"]  + "'"
	Next nX
	cWhereCli := "SA1.A1_COD+SA1.A1_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cJoinAA1  := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "TGY", "AA1", cFilTMP, "JOIN")
cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL", "AA1", "SRJ", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL", "TFJ", "SA1", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL", "AA1", "SRA", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cWhereTFJ := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFJ", "TFJ", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT TFJ.TFJ_CONTRT, 
			TFJ.TFJ_CONREV
    FROM %table:TFJ% TFJ
		LEFT JOIN %table:CN9% CN9 
			ON %exp:cJoinCN9% 
			AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT 
			AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
			AND CN9.%NotDel%
		LEFT JOIN %table:TFL% TFL 
			ON %exp:cJoinTFL% 
			AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO
			AND TFL.%NotDel%
		LEFT JOIN %table:TFF% TFF 
			ON %exp:cJoinTFF% 
			AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
			AND TFF.%NotDel%
		LEFT JOIN %table:TGY% TGY 
			ON %exp:cJoinTGY% 
			AND TGY.TGY_CODTFF = TFF.TFF_COD
			AND TGY.%NotDel%
		LEFT JOIN %table:AA1% AA1 
			ON %exp:cJoinAA1% 
			AND AA1.AA1_CODTEC = TGY.TGY_ATEND
			AND AA1.%NotDel%
		LEFT JOIN %table:SRJ% SRJ 
			ON %exp:cJoinSRJ% 
			AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO
			AND SRJ.%NotDel%
		INNER JOIN %table:SA1% SA1
			ON %exp:cJoinSA1%
	        AND SA1.A1_COD = TFJ.TFJ_CODENT
			AND SA1.A1_LOJA = TFJ.TFJ_LOJA
            AND SA1.%NotDel% 
		LEFT JOIN %table:SRA% SRA 
			ON %exp:cJoinSRA% 
			AND SRA.RA_MAT = AA1.AA1_CDFUNC
			AND SRA.%NotDel%
		LEFT JOIN %table:ABS% AB 
			ON %exp:cJoinABS% 
			AND AB.ABS_LOCAL = TFL.TFL_LOCAL
			AND AB.%NotDel%
		LEFT JOIN %table:TGS% TGS 
			ON %exp:cJoinTGS% 
			AND TGS.TGS_COD = AB.ABS_CODSUP
			AND TGS.%NotDel%
	WHERE %exp:cWhereTFJ%
		AND %exp:cWhereArea%
		AND %exp:cWhereFunc%
		AND %exp:cWhereAtend%
		AND %exp:cWhereCli%
        AND TFJ.%NotDel%
		AND CN9.CN9_SITUAC = '05'
  		AND TFJ.TFJ_STATUS = '1'
	GROUP BY TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV
	ORDER BY TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Contrato'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['Contrato'], JsonObject():New())
		aTail(oResponse['Contrato'])['contrato']:= AllTrim((cAliasTmp)->TFJ_CONTRT)
		aTail(oResponse['Contrato'])['revisao']	:= AllTrim((cAliasTmp)->TFJ_CONREV)
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método POST de Locais para Filtro no fluxo de FT e Alocação por Hora

@Param cBody Exemplo1: 
{
    "filial":"D MG 01 ",
    "areas":[{"value":"000001"}],
    "funcoes":[{"value":"00002"},{"value":"00003"}],
    "atendentes":[{"value":"D MG 01 000002"}],
    "clientes":[{"value":"00000101"}], //Cliente+Loja
    "contratos":[{"value":"000000000000225"}] //Contrato+Revisão
}

Exemplo2: (filtros anteriores do front-end sem seleções)
{
    "filial":"D MG 01 ",
    "areas":[],
	"funcoes":[],
	"atendentes":[],
	"clientes":[],
	"contratos":[]
}

@author     Jack Junior
@since      04/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST fthLocal WSREST TECWSALOC
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cFilTMP   := ""
Local cInArea	:= ""
Local cInFunc	:= ""
Local cInAtend	:= ""
Local cInCli	:= ""
Local cInContr	:= ""
Local cWhereArea:= ""
Local cWhereAtend:= ""
Local cWhereFunc:= ""
Local cWhereContr:= ""
Local cJoinSRJ  := ""
Local cJoinTGY  := ""
Local cJoinTFF  := ""
Local cJoinAA1  := ""
Local cJoinTFJ  := ""
Local cJoinCN9  := ""
Local cJoinSRA  := ""
Local cJoinABS  := ""
Local cJoinTGS  := ""
Local cJoinSA1	:= ""
Local cWhereTFL := ""
Local aArea		:= {}
Local aFuncoes	:= {}
Local aAtend	:= {}
Local aClientes	:= {}
Local aContratos:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aArea		:= oParamBody['areas']
aFuncoes	:= oParamBody['funcoes']
aAtend		:= oParamBody['atendentes']
aClientes	:= oParamBody['clientes']
aContratos	:= oParamBody['contratos']

//Monta o where de Areas com base na seleção do filtro anterior no Front-End
If ValType(aArea) = 'U' .Or. Len(aArea) = 0
	cWhereArea := "1 = 1"
ElseIf Len(aArea) = 1
	cWhereArea := "TGS.TGS_COD = '" + aArea[1]["value"]  + "' AND TGY.TGY_ULTALO != ' '"
Else
	For nX = 1 To Len(aArea)
		If nX > 1
			cInArea += ","
		EndIf
		cInArea +=  "'" + aArea[nX]["value"]  + "'"
	Next nX
	cWhereArea := "TGS.TGS_COD IN ("+cInArea+") AND TGY.TGY_ULTALO != ' '"
EndIf

cWhereArea := sqlEmbeded(cWhereArea)

//Monta o where de Funcoes com base na seleção do filtro anterior no Front-End
If ValType(aFuncoes) = 'U' .Or. Len(aFuncoes) = 0
	cWhereFunc := "1 = 1"
ElseIf Len(aFuncoes) = 1
	cWhereFunc := "SRJ.RJ_FUNCAO = '" + aFuncoes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aFuncoes)
		If nX > 1
			cInFunc += ","
		EndIf
		cInFunc +=  "'" + aFuncoes[nX]["value"]  + "'"
	Next nX
	cWhereFunc := "SRJ.RJ_FUNCAO IN ("+cInFunc+")"
EndIf

cWhereFunc := sqlEmbeded(cWhereFunc)

//Monta o where de Atendentes com base na seleção do filtro anterior no Front-End
If ValType(aAtend) = 'U' .Or. Len(aAtend) = 0
	cWhereAtend := "1 = 1"
ElseIf Len(aAtend) = 1
	cWhereAtend := "AA1.AA1_CODTEC = '" + aAtend[1]["value"]  + "'"
Else
	For nX = 1 To Len(aAtend)
		If nX > 1
			cInAtend += ","
		EndIf
		cInAtend +=  "'" + aAtend[nX]["value"]  + "'"
	Next nX
	cWhereAtend := "AA1.AA1_CODTEC IN ("+cInAtend+")"
EndIf

cWhereAtend := sqlEmbeded(cWhereAtend)

//Monta o where de Clientes com base na seleção do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "SA1.A1_COD+SA1.A1_LOJA = '" + aClientes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli +=  "'" + aClientes[nX]["value"]  + "'"
	Next nX
	cWhereCli := "SA1.A1_COD+SA1.A1_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Monta o where de Contratos com base na seleção do filtro anterior no Front-End
If ValType(aContratos) = 'U' .Or. Len(aContratos) = 0
	cWhereContr := "1 = 1"
ElseIf Len(aContratos) = 1
	cWhereContr := "TFJ.TFJ_CONTRT+TFJ.TFJ_CONREV = '" + aContratos[1]["value"]  + "'"
Else
	For nX = 1 To Len(aContratos)
		If nX > 1
			cInContr += ","
		EndIf
		cInContr +=  "'" + aContratos[nX]["value"]  + "'"
	Next nX
	cWhereContr := "TFJ.TFJ_CONTRT+TFJ.TFJ_CONREV IN ("+cInContr+")"
EndIf

cWhereContr := sqlEmbeded(cWhereContr)

cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL", "AA1", "SRJ", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL", "AA1", "SRA", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL", "TFJ", "SA1", cFilTMP, "JOIN")
cJoinAA1  := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "TGY", "AA1", cFilTMP, "JOIN")
cWhereTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFL", "TFL", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT TFL.TFL_CODIGO, 
			TFL.TFL_LOCAL, 
			AB.ABS_DESCRI
    FROM %table:TFL% TFL
		LEFT JOIN %table:TFJ% TFJ 
			ON %exp:cJoinTFJ% 
			AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
			AND TFJ.%NotDel%
		LEFT JOIN %table:CN9% CN9 
			ON %exp:cJoinCN9% 
			AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT 
			AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
			AND CN9.%NotDel%
		LEFT JOIN %table:TFF% TFF 
			ON %exp:cJoinTFF% 
			AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
			AND TFF.%NotDel%
		LEFT JOIN %table:TGY% TGY 
			ON %exp:cJoinTGY% 
			AND TGY.TGY_CODTFF = TFF.TFF_COD
			AND TGY.%NotDel%
		LEFT JOIN %table:AA1% AA1 
			ON %exp:cJoinAA1% 
			AND AA1.AA1_CODTEC = TGY.TGY_ATEND
			AND AA1.%NotDel%
		LEFT JOIN %table:SRJ% SRJ 
			ON %exp:cJoinSRJ% 
			AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO
			AND SRJ.%NotDel%
		INNER JOIN %table:SA1% SA1
			ON %exp:cJoinSA1%
	        AND SA1.A1_COD = TFJ.TFJ_CODENT
			AND SA1.A1_LOJA = TFJ.TFJ_LOJA
            AND SA1.%NotDel% 
		LEFT JOIN %table:SRA% SRA 
			ON %exp:cJoinSRA% 
			AND SRA.RA_MAT = AA1.AA1_CDFUNC
			AND SRA.%NotDel%
		LEFT JOIN %table:ABS% AB 
			ON %exp:cJoinABS% 
			AND AB.ABS_LOCAL = TFL.TFL_LOCAL
			AND AB.%NotDel%
		LEFT JOIN %table:TGS% TGS 
			ON %exp:cJoinTGS% 
			AND TGS.TGS_COD = AB.ABS_CODSUP
			AND TGS.%NotDel%
	WHERE %exp:cWhereTFL%
		AND %exp:cWhereArea%
		AND %exp:cWhereFunc%
		AND %exp:cWhereAtend%
		AND %exp:cWhereCli%
		AND %exp:cWhereContr%
        AND TFL.%NotDel%
		AND CN9.CN9_SITUAC = '05'
  		AND TFJ.TFJ_STATUS = '1'
	GROUP BY TFL.TFL_CODIGO, TFL.TFL_LOCAL, AB.ABS_DESCRI
	ORDER BY TFL.TFL_CODIGO
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Local'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['Local'], JsonObject():New())
		aTail(oResponse['Local'])['tflcod']	:= AllTrim((cAliasTmp)->TFL_CODIGO)
		aTail(oResponse['Local'])['abscod']	:= AllTrim((cAliasTmp)->TFL_LOCAL)
		aTail(oResponse['Local'])['desc']	:= EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método POST de Postos para Filtro no fluxo de FT e Alocação por Hora

@Param cBody Exemplo1: 
{
    "filial":"D MG 01 ",
    "areas":[{"value":"000001"}],
    "funcoes":[{"value":"00002"},{"value":"00003"}],
    "atendentes":[{"value":"D MG 01 000002"}],
    "clientes":[{"value":"00000101"}], //Cliente+Loja
    "contratos":[{"value":"000000000000225"}],  //Contrato+Revisão
    "locais":[{"value":"000389"}]
}

Exemplo2: (filtros anteriores do front-end sem seleções)
{
    "filial":"D MG 01 ",
    "areas":[],
	"funcoes":[],
	"atendentes":[],
	"clientes":[],
	"contratos":[],
    "locais":[]
}

@author     Jack Junior
@since      04/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST fthPosto WSREST TECWSALOC
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cFilTMP   := ""
Local cInArea	:= ""
Local cInFunc	:= ""
Local cInAtend	:= ""
Local cInCli	:= ""
Local cInContr	:= ""
Local cInLoc	:= ""
Local cWhereArea:= ""
Local cWhereAtend:= ""
Local cWhereFunc:= ""
Local cWhereContr:= ""
Local cWhereLoc	:= ""
Local cJoinSRJ  := ""
Local cJoinTGY  := ""
Local cJoinTFF  := ""
Local cJoinTFL  := ""
Local cJoinTFJ  := ""
Local cJoinCN9  := ""
Local cJoinSRA  := ""
Local cJoinABS  := ""
Local cJoinTGS  := ""
Local cJoinSA1	:= ""
Local cJoinSB1	:= ""
Local cWhereTFF := ""
Local aArea		:= {}
Local aFuncoes	:= {}
Local aAtend	:= {}
Local aClientes	:= {}
Local aContratos:= {}
Local aLocais	:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aArea		:= oParamBody['areas']
aFuncoes	:= oParamBody['funcoes']
aAtend		:= oParamBody['atendentes']
aClientes	:= oParamBody['clientes']
aContratos	:= oParamBody['contratos']
aLocais		:= oParamBody['locais']

//Monta o where de Areas com base na seleção do filtro anterior no Front-End
If ValType(aArea) = 'U' .Or. Len(aArea) = 0
	cWhereArea := "1 = 1"
ElseIf Len(aArea) = 1
	cWhereArea := "TGS.TGS_COD = '" + aArea[1]["value"]  + "' AND TGY.TGY_ULTALO != ' '"
Else
	For nX = 1 To Len(aArea)
		If nX > 1
			cInArea += ","
		EndIf
		cInArea +=  "'" + aArea[nX]["value"]  + "'"
	Next nX
	cWhereArea := "TGS.TGS_COD IN ("+cInArea+") AND TGY.TGY_ULTALO != ' '"
EndIf

cWhereArea := sqlEmbeded(cWhereArea)

//Monta o where de Funcoes com base na seleção do filtro anterior no Front-End
If ValType(aFuncoes) = 'U' .Or. Len(aFuncoes) = 0
	cWhereFunc := "1 = 1"
ElseIf Len(aFuncoes) = 1
	cWhereFunc := "SRJ.RJ_FUNCAO = '" + aFuncoes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aFuncoes)
		If nX > 1
			cInFunc += ","
		EndIf
		cInFunc +=  "'" + aFuncoes[nX]["value"]  + "'"
	Next nX
	cWhereFunc := "SRJ.RJ_FUNCAO IN ("+cInFunc+")"
EndIf

cWhereFunc := sqlEmbeded(cWhereFunc)

//Monta o where de Atendentes com base na seleção do filtro anterior no Front-End
If ValType(aAtend) = 'U' .Or. Len(aAtend) = 0
	cWhereAtend := "1 = 1"
ElseIf Len(aAtend) = 1
	cWhereAtend := "AA1.AA1_CODTEC = '" + aAtend[1]["value"]  + "'"
Else
	For nX = 1 To Len(aAtend)
		If nX > 1
			cInAtend += ","
		EndIf
		cInAtend +=  "'" + aAtend[nX]["value"]  + "'"
	Next nX
	cWhereAtend := "AA1.AA1_CODTEC IN ("+cInAtend+")"
EndIf

cWhereAtend := sqlEmbeded(cWhereAtend)

//Monta o where de Clientes com base na seleção do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "SA1.A1_COD+SA1.A1_LOJA = '" + aClientes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli +=  "'" + aClientes[nX]["value"]  + "'"
	Next nX
	cWhereCli := "SA1.A1_COD+SA1.A1_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Monta o where de Contratos com base na seleção do filtro anterior no Front-End
If ValType(aContratos) = 'U' .Or. Len(aContratos) = 0
	cWhereContr := "1 = 1"
ElseIf Len(aContratos) = 1
	cWhereContr := "TFJ.TFJ_CONTRT+TFJ.TFJ_CONREV = '" + aContratos[1]["value"]  + "'"
Else
	For nX = 1 To Len(aContratos)
		If nX > 1
			cInContr += ","
		EndIf
		cInContr +=  "'" + aContratos[nX]["value"]  + "'"
	Next nX
	cWhereContr := "TFJ.TFJ_CONTRT+TFJ.TFJ_CONREV IN ("+cInContr+")"
EndIf

cWhereContr := sqlEmbeded(cWhereContr)

//Monta o where de Locais com base na seleção do filtro anterior no Front-End
If ValType(aLocais) = 'U' .Or. Len(aLocais) = 0
	cWhereLoc := "1 = 1"
ElseIf Len(aLocais) = 1
	cWhereLoc := "TFL.TFL_CODIGO = '" + aLocais[1]["value"]  + "'"
Else
	For nX = 1 To Len(aLocais)
		If nX > 1
			cInLoc += ","
		EndIf
		cInLoc +=  "'" + aLocais[nX]["value"]  + "'"
	Next nX
	cWhereLoc := "TFL.TFL_CODIGO IN ("+cInLoc+")"
EndIf

cWhereLoc := sqlEmbeded(cWhereLoc)

cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL", "AA1", "SRJ", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TGY", "TFF", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL", "AA1", "SRA", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL", "TFJ", "SA1", cFilTMP, "JOIN")
cJoinSB1  := JoinSQL(lMultFil, "SB1.B1_FILIAL", "TFF", "SB1", cFilTMP, "JOIN")
cJoinAA1  := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "TGY", "AA1", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT TFF.TFF_COD, 
			TFF.TFF_PRODUT, 
			SB1.B1_DESC
    FROM %table:TFF% TFF
		LEFT JOIN %table:TFL% TFL 
			ON %exp:cJoinTFL% 
			AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
			AND TFL.%NotDel%
		LEFT JOIN %table:TFJ% TFJ 
			ON %exp:cJoinTFJ% 
			AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
			AND TFJ.%NotDel%
		LEFT JOIN %table:CN9% CN9 
			ON %exp:cJoinCN9% 
			AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT 
			AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
			AND CN9.%NotDel%
		LEFT JOIN %table:TGY% TGY 
			ON %exp:cJoinTGY% 
			AND TGY.TGY_CODTFF = TFF.TFF_COD
			AND TGY.%NotDel%
		LEFT JOIN %table:AA1% AA1 
			ON %exp:cJoinAA1% 
			AND AA1.AA1_CODTEC = TGY.TGY_ATEND
			AND AA1.%NotDel%
		LEFT JOIN %table:SRJ% SRJ 
			ON %exp:cJoinSRJ% 
			AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO
			AND SRJ.%NotDel%
		INNER JOIN %table:SA1% SA1
			ON %exp:cJoinSA1%
	        AND SA1.A1_COD = TFJ.TFJ_CODENT
			AND SA1.A1_LOJA = TFJ.TFJ_LOJA
            AND SA1.%NotDel% 
		LEFT JOIN %table:SRA% SRA 
			ON %exp:cJoinSRA% 
			AND SRA.RA_MAT = AA1.AA1_CDFUNC
			AND SRA.%NotDel%
		LEFT JOIN %table:ABS% AB 
			ON %exp:cJoinABS% 
			AND AB.ABS_LOCAL = TFL.TFL_LOCAL
			AND AB.%NotDel%
		LEFT JOIN %table:TGS% TGS 
			ON %exp:cJoinTGS% 
			AND TGS.TGS_COD = AB.ABS_CODSUP
			AND TGS.%NotDel%
		LEFT JOIN %table:SB1% SB1 
			ON %exp:cJoinSB1% 
			AND SB1.B1_COD = TFF.TFF_PRODUT
			AND SB1.%NotDel%
	WHERE %exp:cWhereTFF%
		AND %exp:cWhereArea%
		AND %exp:cWhereFunc%
		AND %exp:cWhereAtend%
		AND %exp:cWhereCli%
		AND %exp:cWhereContr%
		AND %exp:cWhereLoc%
        AND TFF.%NotDel%
		AND CN9.CN9_SITUAC = '05'
  		AND TFJ.TFJ_STATUS = '1'
	GROUP BY TFF.TFF_COD, TFF.TFF_PRODUT, SB1.B1_DESC
	ORDER BY TFF.TFF_COD
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Posto'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['Posto'], JsonObject():New())
		aTail(oResponse['Posto'])['tffcod']	:= AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['Posto'])['abscod']	:= AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['Posto'])['desc']	:= EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método POST de botão de Busca para fluxo de FT e Alocação por Hora

@Param cBody Exemplo1: 
{
    "filial":"D MG 01 ",
    "areas":[{"value":"000001"}],
    "funcoes":[{"value":"00002"},{"value":"00003"}],
    "atendentes":[{"value":"D MG 01 000002"}],
    "clientes":[{"value":"00000101"}],  //Cliente+Loja
    "contratos":[{"value":"000000000000225"}], //Contrato+Revisão
    "locais":[{"value":"000389"}],
    "postos":[{"value":"000531"},{"value":"000532"}],
    "status":[{"value":"1"},{"value":"2"},{"value":"3"}] //A depender do que selecionou NOVO = '1', EFETIVO = '2', RESERVA = '3'
}

Exemplo2: (filtros anteriores do front-end sem seleções)
{
    "filial":"D MG 01 ",
    "areas":[],
	"funcoes":[],
	"atendentes":[],
	"clientes":[],
	"contratos":[],
    "locais":[],
    "postos":[],
    "status":[]
}

@author     Jack Junior
@since      04/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST fthBuscar WSREST TECWSALOC
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cFilTMP   := ""
Local cInArea	:= ""
Local cInFunc	:= ""
Local cInAtend	:= ""
Local cInCli	:= ""
Local cInContr	:= ""
Local cInLoc	:= ""
Local cInPostos	:= ""
Local cWhereArea:= ""
Local cWhereAtend:= ""
Local cWhereFunc:= ""
Local cWhereContr:= ""
Local cWhereLoc	:= ""
Local cWherePost:= ""
Local cJoinSRJ  := ""
Local cJoinTGY  := ""
Local cJoinTFF  := ""
Local cJoinTFL  := ""
Local cJoinTFJ  := ""
Local cJoinCN9  := ""
Local cJoinSRA  := ""
Local cJoinABS  := ""
Local cJoinTGS  := ""
Local cJoinSA1	:= ""
Local cJoinSB1	:= ""
Local cWhereAA1 := ""
Local aArea		:= {}
Local aFuncoes	:= {}
Local aAtend	:= {}
Local aClientes	:= {}
Local aContratos:= {}
Local aLocais	:= {}
Local aStatus	:= {}
Local aAuxiliar := {}
Local aRetorno	:= {}
Local aPostos	:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()
Local lNovo		:= .F.
Local lReserva	:= .F.
Local lEfetivo	:= .F.

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aArea		:= oParamBody['areas']
aFuncoes	:= oParamBody['funcoes']
aAtend		:= oParamBody['atendentes']
aClientes	:= oParamBody['clientes']
aContratos	:= oParamBody['contratos']
aLocais		:= oParamBody['locais']
aPostos		:= oParamBody['postos']
aStatus		:= oParamBody['status'] //aStatus - NOVO = '1', EFETIVO = '2', RESERVA = '3'

If Len(aStatus) > 0
	//NOVO
	If aScan(aStatus, {|x| x["value"] == '1'}) != 0
		lNovo	:= .T.
	EndIf
	//EFETIVO
	If aScan(aStatus, {|x| x["value"] == '2'}) != 0
		lEfetivo:= .T.
	EndIf
	//RESERVA
	If aScan(aStatus, {|x| x["value"] == '3'}) != 0
		lReserva:= .T.
	EndIf
Else
	lNovo	:= .T.
	lReserva:= .T.
	lEfetivo:= .T.
EndIf

//Monta o where de Areas com base na seleção do filtro anterior no Front-End
If ValType(aArea) = 'U' .Or. Len(aArea) = 0
	cWhereArea := "1 = 1"
ElseIf Len(aArea) = 1
	cWhereArea := "TGS.TGS_COD = '" + aArea[1]["value"]  + "' AND TGY.TGY_ULTALO != ' '"
Else
	For nX = 1 To Len(aArea)
		If nX > 1
			cInArea += ","
		EndIf
		cInArea +=  "'" + aArea[nX]["value"]  + "'"
	Next nX
	cWhereArea := "TGS.TGS_COD IN ("+cInArea+") AND TGY.TGY_ULTALO != ' '"
EndIf

cWhereArea := sqlEmbeded(cWhereArea)

//Monta o where de Funcoes com base na seleção do filtro anterior no Front-End
If ValType(aFuncoes) = 'U' .Or. Len(aFuncoes) = 0
	cWhereFunc := "1 = 1"
ElseIf Len(aFuncoes) = 1
	cWhereFunc := "SRJ.RJ_FUNCAO = '" + aFuncoes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aFuncoes)
		If nX > 1
			cInFunc += ","
		EndIf
		cInFunc +=  "'" + aFuncoes[nX]["value"]  + "'"
	Next nX
	cWhereFunc := "SRJ.RJ_FUNCAO IN ("+cInFunc+")"
EndIf

cWhereFunc := sqlEmbeded(cWhereFunc)

//Monta o where de Atendentes com base na seleção do filtro anterior no Front-End
If ValType(aAtend) = 'U' .Or. Len(aAtend) = 0
	cWhereAtend := "1 = 1"
ElseIf Len(aAtend) = 1
	cWhereAtend := "AA1.AA1_CODTEC = '" + aAtend[1]["value"]  + "'"
Else
	For nX = 1 To Len(aAtend)
		If nX > 1
			cInAtend += ","
		EndIf
		cInAtend +=  "'" + aAtend[nX]["value"]  + "'"
	Next nX
	cWhereAtend := "AA1.AA1_CODTEC IN ("+cInAtend+")"
EndIf

cWhereAtend := sqlEmbeded(cWhereAtend)

//Monta o where de Clientes com base na seleção do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "SA1.A1_COD+SA1.A1_LOJA = '" + aClientes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli +=  "'" + aClientes[nX]["value"]  + "'"
	Next nX
	cWhereCli := "SA1.A1_COD+SA1.A1_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Monta o where de Contratos com base na seleção do filtro anterior no Front-End
If ValType(aContratos) = 'U' .Or. Len(aContratos) = 0
	cWhereContr := "1 = 1"
ElseIf Len(aContratos) = 1
	cWhereContr := "TFJ.TFJ_CONTRT+TFJ.TFJ_CONREV = '" + aContratos[1]["value"]  + "'"
Else
	For nX = 1 To Len(aContratos)
		If nX > 1
			cInContr += ","
		EndIf
		cInContr +=  "'" + aContratos[nX]["value"]  + "'"
	Next nX
	cWhereContr := "TFJ.TFJ_CONTRT+TFJ.TFJ_CONREV IN ("+cInContr+")"
EndIf

cWhereContr := sqlEmbeded(cWhereContr)

//Monta o where de Locais com base na seleção do filtro anterior no Front-End
If ValType(aLocais) = 'U' .Or. Len(aLocais) = 0
	cWhereLoc := "1 = 1"
ElseIf Len(aLocais) = 1
	cWhereLoc := "TFL.TFL_CODIGO = '" + aLocais[1]["value"]  + "'"
Else
	For nX = 1 To Len(aLocais)
		If nX > 1
			cInLoc += ","
		EndIf
		cInLoc +=  "'" + aLocais[nX]["value"]  + "'"
	Next nX
	cWhereLoc := "TFL.TFL_CODIGO IN ("+cInLoc+")"
EndIf

cWhereLoc := sqlEmbeded(cWhereLoc)

//Monta o where de Postos com base na seleção do filtro anterior no Front-End
If ValType(aPostos) = 'U' .Or. Len(aPostos) = 0
	cWherePost := "1 = 1"
ElseIf Len(aPostos) = 1
	cWherePost := "TFF.TFF_COD = '" + aPostos[1]["value"]  + "'"
Else
	For nX = 1 To Len(aPostos)
		If nX > 1
			cInPostos += ","
		EndIf
		cInPostos +=  "'" + aPostos[nX]["value"]  + "'"
	Next nX
	cWherePost := "TFF.TFF_COD IN ("+cInPostos+")"
EndIf

cWherePost := sqlEmbeded(cWherePost)

cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL", "AA1", "SRJ", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "AA1", "TGY", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TGY", "TFF", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL", "AA1", "SRA", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL", "TFJ", "SA1", cFilTMP, "JOIN")
cJoinSB1  := JoinSQL(lMultFil, "SB1.B1_FILIAL", "TFF", "SB1", cFilTMP, "JOIN")
cWhereAA1 := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "AA1", "AA1", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT COALESCE(SRA.RA_MAT, ' ') AS RA_MAT,
			AA1.AA1_CODTEC, 
			AA1.AA1_NOMTEC,
			COALESCE(SRJ.RJ_FUNCAO, ' ') AS RJ_FUNCAO,
			COALESCE(SRJ.RJ_DESC, ' ') AS RJ_DESC,
			COALESCE(SA1.A1_COD, ' ') AS A1_COD,
			COALESCE(SA1.A1_LOJA, ' ') AS A1_LOJA,
			COALESCE(SA1.A1_NOME, ' ') AS A1_NOME,
			COALESCE(TFL.TFL_LOCAL, ' ') AS TFL_LOCAL,
			COALESCE(AB.ABS_DESCRI, ' ') AS ABS_DESCRI,
			COALESCE(TFF.TFF_COD, ' ') AS TFF_COD,
			COALESCE(TFF.TFF_PRODUT, ' ') AS TFF_PRODUT,
			COALESCE(SB1.B1_DESC, ' ') AS B1_DESC,
			COALESCE(TGY.TGY_ULTALO, ' ') AS TGY_ULTALO,
			COALESCE(TGY.TGY_RESTEC, ' ') AS TGY_RESTEC
    FROM %table:AA1% AA1
		LEFT JOIN %table:TGY% TGY 
			ON %exp:cJoinTGY% 
			AND TGY.TGY_ATEND = AA1.AA1_CODTEC
			AND TGY.%NotDel%
		LEFT JOIN %table:TFF% TFF 
			ON %exp:cJoinTFF% 
			AND TFF.TFF_COD = TGY.TGY_CODTFF
			AND TFF.%NotDel%
		LEFT JOIN %table:TFL% TFL 
			ON %exp:cJoinTFL% 
			AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
			AND TFL.%NotDel%
		LEFT JOIN %table:TFJ% TFJ 
			ON %exp:cJoinTFJ% 
			AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
			AND TFJ.%NotDel%
		LEFT JOIN %table:CN9% CN9 
			ON %exp:cJoinCN9% 
			AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT 
			AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
			AND CN9.%NotDel%
		LEFT JOIN %table:SRA% SRA 
			ON %exp:cJoinSRA% 
			AND SRA.RA_MAT = AA1.AA1_CDFUNC
			AND SRA.%NotDel%
		LEFT JOIN %table:SRJ% SRJ 
			ON %exp:cJoinSRJ% 
			AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO
			AND SRJ.%NotDel%
		LEFT JOIN %table:ABS% AB 
			ON %exp:cJoinABS% 
			AND AB.ABS_LOCAL = TFL.TFL_LOCAL
			AND AB.%NotDel%
		LEFT JOIN %table:TGS% TGS 
			ON %exp:cJoinTGS% 
			AND TGS.TGS_COD = AB.ABS_CODSUP
			AND TGS.%NotDel%
		LEFT JOIN %table:SA1% SA1
			ON %exp:cJoinSA1%
	        AND SA1.A1_COD = TFJ.TFJ_CODENT
			AND SA1.A1_LOJA = TFJ.TFJ_LOJA
            AND SA1.%NotDel% 
		LEFT JOIN %table:SB1% SB1 
			ON %exp:cJoinSB1% 
			AND SB1.B1_COD = TFF.TFF_PRODUT
			AND SB1.%NotDel%
	WHERE %exp:cWhereAA1%
		AND %exp:cWhereArea%
		AND %exp:cWhereFunc%
		AND %exp:cWhereAtend%
		AND %exp:cWhereCli%
		AND %exp:cWhereContr%
		AND %exp:cWhereLoc%
		AND %exp:cWherePost%
		AND AA1.AA1_ALOCA = '1'
        AND AA1.%NotDel%
	GROUP BY RA_MAT,AA1.AA1_CODTEC,AA1.AA1_NOMTEC,RJ_FUNCAO,RJ_DESC,A1_COD,A1_LOJA,
       A1_NOME,TFL_LOCAL,ABS_DESCRI,TFF_COD,TFF_PRODUT,B1_DESC,TGY_ULTALO,TGY_RESTEC
	ORDER BY AA1.AA1_CODTEC, TGY_ULTALO DESC
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Adiciona apenas o Atendente com a maior TGY_ULTALO (Sempre o primeiro pois TGY_ULTALO DESC)
		If aScan(aAuxiliar, {|x| x[2] == (cAliasTmp)->AA1_CODTEC}) == 0
			Aadd(aAuxiliar, {(cAliasTmp)->RA_MAT,;
				(cAliasTmp)->AA1_CODTEC, ;
				(cAliasTmp)->AA1_NOMTEC,;
				(cAliasTmp)->RJ_FUNCAO,;
				(cAliasTmp)->RJ_DESC,;
				(cAliasTmp)->A1_COD,;
				(cAliasTmp)->A1_LOJA,;
				(cAliasTmp)->A1_NOME,;
				(cAliasTmp)->TFL_LOCAL,;
				(cAliasTmp)->ABS_DESCRI,;
				(cAliasTmp)->TFF_COD,;
				(cAliasTmp)->TFF_PRODUT,;
				(cAliasTmp)->B1_DESC,;
				(cAliasTmp)->TGY_ULTALO,;
				(cAliasTmp)->TGY_RESTEC})
		EndIf
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

For nX := 1 To Len(aAuxiliar)
	If (lNovo .And. Empty(aAuxiliar[nX,14])) .Or.; //Verifica se é novo
		(lEfetivo .And. aAuxiliar[nX,15] != '1') .Or.; //Verifica se é efetivo
		(lReserva .And. aAuxiliar[nX,15] == '1') //Verifica se é Reserva
		Aadd(aRetorno, {aAuxiliar[nX,1],;  //Matricula
						aAuxiliar[nX,2],;  //Cód atendente
				AllTrim(aAuxiliar[nX,3]),; //Nome atendente
						aAuxiliar[nX,4],;  //Cód Função
				AllTrim(aAuxiliar[nX,5]),; //Desc Função
						aAuxiliar[nX,6],;  //Cód Cliente
						aAuxiliar[nX,7],;  //Loja Cliente
				AllTrim(aAuxiliar[nX,8]),; //Nome Cliente
						aAuxiliar[nX,9],;  //Cód TFL
				AllTrim(aAuxiliar[nX,10]),;//Desc Local 
						aAuxiliar[nX,11],; //Cód Posto (TFF)
						aAuxiliar[nX,12],; //Cód Produto (ABS)
				AllTrim(aAuxiliar[nX,13]),;//Desc Produto
						aAuxiliar[nX,14],; //Data da Última Alocação
						aAuxiliar[nX,15]}) //Reserva Técnica ?
	EndIf
Next nX

oResponse['Busca'] := {}

//Monta o retorno da API:
For nX := 1 To Len(aRetorno)
	Aadd(oResponse['Busca'], JsonObject():New())
	aTail(oResponse['Busca'])['matricula']	:= aRetorno[nX,1]
	aTail(oResponse['Busca'])['codAtend']	:= aRetorno[nX,2]
	aTail(oResponse['Busca'])['nomeAtend']	:= EncodeUTF8(aRetorno[nX,3])
	aTail(oResponse['Busca'])['codFunc']	:= aRetorno[nX,4]
	aTail(oResponse['Busca'])['descFunc']	:= EncodeUTF8(aRetorno[nX,5])
	aTail(oResponse['Busca'])['codCli']		:= aRetorno[nX,6]
	aTail(oResponse['Busca'])['lojaCli']	:= aRetorno[nX,7]
	aTail(oResponse['Busca'])['nomeCli']	:= EncodeUTF8(aRetorno[nX,8])
	aTail(oResponse['Busca'])['tfl']		:= aRetorno[nX,9]
	aTail(oResponse['Busca'])['descloc']	:= EncodeUTF8(aRetorno[nX,10])
	aTail(oResponse['Busca'])['tff']		:= aRetorno[nX,11]
	aTail(oResponse['Busca'])['codProd']	:= aRetorno[nX,12]
	aTail(oResponse['Busca'])['descProd']	:= EncodeUTF8(aRetorno[nX,13])
	aTail(oResponse['Busca'])['ultalo']		:= aRetorno[nX,14]
	If Empty(aRetorno[nX,14])
		aTail(oResponse['Busca'])['status']	:= 'Novo'
	ElseIf aRetorno[nX,15] != '1'
		aTail(oResponse['Busca'])['status']	:= 'Efetivo'
	Else
		aTail(oResponse['Busca'])['status']	:= 'Reserva'
	EndIf
Next nX

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL
Return

WSMETHOD GET contFTH WSRECEIVE cFil WSREST TECWSALOC
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cWhereCN9 := ''

cFilTMP := self:cFil

cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "CN9", "TFJ", cFilTMP, "JOIN")
cWhereCN9 := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "CN9", "CN9", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT CN9.CN9_NUMERO, CN9.CN9_REVISA
	    FROM %table:CN9% CN9
			INNER JOIN %table:TFJ% TFJ 
			ON %exp:cJoinTFJ% 
			AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO
			AND TFJ.TFJ_CONREV = CN9.CN9_REVISA
			AND TFJ.%NotDel%
        WHERE %exp:cWhereCN9%
			AND CN9.CN9_SITUAC = '05'
  			AND TFJ.TFJ_STATUS = '1'
            AND CN9.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['contrato'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['contrato'], JsonObject():New())
		aTail(oResponse['contrato'])['contrato']	:= AllTrim((cAliasTmp)->CN9_NUMERO)
		aTail(oResponse['contrato'])['revisao']	:= AllTrim((cAliasTmp)->CN9_REVISA)
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return

WSMETHOD GET locaisFTH WSRECEIVE cFil, cContrato, cRevisao WSREST TECWSALOC
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cCont		:= ''
Local cRev		:= ''
Local cJoinABS	:= ''
Local cJoinTFJ	:= ''
Local cJoinCN9	:= ''
Local cWhereTFL := ''

cFilTMP := self:cFil
cCont 	:= self:cContrato
cRev 	:= self:cRevisao

cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cWhereTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFL", "TFL", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT TFL.TFL_CODIGO, TFL.TFL_LOCAL, AB.ABS_DESCRI
	    FROM %table:TFL% TFL
			INNER JOIN %table:ABS% AB 
				ON %exp:cJoinABS% 
				AND AB.ABS_LOCAL = TFL.TFL_LOCAL
				AND AB.%NotDel%
			INNER JOIN %table:TFJ% TFJ 
				ON %exp:cJoinTFJ% 
				AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
				AND TFJ.%NotDel%
			INNER JOIN %table:CN9% CN9 
				ON %exp:cJoinCN9% 
				AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT
				AND CN9.CN9_REVISA = TFJ.TFJ_CONREV 				
				AND CN9.%NotDel%
        WHERE %exp:cWhereTFL%
			AND CN9.CN9_NUMERO = %exp:cCont%
  			AND CN9.CN9_REVISA = %exp:cRev%
            AND CN9.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['local'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['local'], JsonObject():New())
		aTail(oResponse['local'])['tflcod']	:= AllTrim((cAliasTmp)->TFL_CODIGO)
		aTail(oResponse['local'])['local']	:= AllTrim((cAliasTmp)->TFL_LOCAL)
		aTail(oResponse['local'])['desc']   := EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return


WSMETHOD GET postosFTH WSRECEIVE cFil, cTFL WSREST TECWSALOC
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cCodTFL	:= ''
Local cJoinSB1	:= ''
Local cJoinTFL	:= ''
Local cJoinTDW	:= ''
Local cWhereTFF := ''

cFilTMP := self:cFil
cCodTFL	:= self:cTFL

cJoinSB1  := JoinSQL(lMultFil, "SB1.B1_FILIAL", "TFF", "SB1", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinTDW  := JoinSQL(lMultFil, "TDW.TDW_FILIAL", "TFF", "TDW", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT TFF.TFF_COD, TFF.TFF_PRODUT, SB1.B1_DESC, 
					TFF.TFF_ESCALA, COALESCE(TDW.TDW_DESC,' ') AS TDW_DESC, 
					TFF.TFF_ITEXOP, TFF.TFF_QTDHRS, TFF.TFF_QTDVEN
	    FROM %table:TFF% TFF
			INNER JOIN %table:SB1% SB1
				ON (%exp:cJoinSB1% 
				AND SB1.B1_COD = TFF.TFF_PRODUT
				AND SB1.%NotDel%)
			INNER JOIN %table:TFL% TFL
				ON (%exp:cJoinTFL% 
				AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
				AND TFL.%NotDel%)
			LEFT JOIN %table:TDW% TDW
                ON (%exp:cJoinTDW%
                AND TDW.TDW_COD = TFF.TFF_ESCALA
                AND TDW.%NotDel%)
        WHERE %exp:cWhereTFF%
			AND TFL.TFL_CODIGO = %exp:cCodTFL%
            AND TFF.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['posto'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['posto'], JsonObject():New())
		aTail(oResponse['posto'])['tffcod']		:= AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['posto'])['codprod']	:= AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['posto'])['descprod']   := EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))
		aTail(oResponse['posto'])['codprod']	:= AllTrim((cAliasTmp)->TFF_QTDVEN)
		aTail(oResponse['posto'])['escala']		:= AllTrim((cAliasTmp)->TFF_ESCALA)
		aTail(oResponse['posto'])['descescala']	:= EncodeUTF8(AllTrim((cAliasTmp)->TDW_DESC))
		aTail(oResponse['posto'])['itemextra']	:= AllTrim((cAliasTmp)->TFF_ITEXOP)
		aTail(oResponse['posto'])['qtdhoras']	:= AllTrim((cAliasTmp)->TFF_QTDHRS)
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return

//aaaaaaaaaaaaaaaaaaaaaaaaaaaa

WSMETHOD POST projFT WSREST TECWSALOC

Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local oMdl190D	:= NIL
Local oMdl190G	:= NIL
Local oMdlAA1	:= NIL
Local oMdlTGY	:= NIL
Local oMdlALC	:= NIL
Local aDias		:= {}
Local cBody     := Self:GetContent()
Local cFilTMP	:= ""
Local cContrato	:= ""
Local cLocal	:= ""
Local cPosto	:= ""
Local cAtendente:= ""
Local cTipoAloc	:= ""
Local cMsg		:= ""
Local nDiasAdd	:= 0
Local nTamGrid	:= 0
Local nX		:= 0
Local lMultFil  := IsMultFil()
Local lRet		:= .T.

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

If At680Perm(NIL, __cUserId, "039", .T.)
	//Inicializa parametros do Body JSON passado do Front:
	cFilTMP     := oParamBody['filial']
	aDias		:= oParamBody['dias']
	cContrato	:= oParamBody['contrato']
	cLocal      := oParamBody['local']
	cPosto      := oParamBody['posto']
	cAtendente	:= oParamBody['atendente']
	cTipoAloc	:= oParamBody['tipoAloc'] //Folga Trabalhada sempre

	//aDias = {1,{1data,2entrada,3saída,4turno,5sequencia,6tipo,7saída intervalo,8intrajornada?}}

	//MODELO MESA OPERACIONAL:
	oMdl190D:= FWLoadModel("TECA190D")
	oMdl190D:SetOperation(3)
	oMdl190D:Activate()

	oMdlAA1 := oMdl190D:GetModel("AA1MASTER") //Atendente
	oMdlTGY := oMdl190D:GetModel("TGYMASTER") //Alocação

	//Carga do atendente AA1MASTER/ Demais dados TGYMASTER(Alocação):
	lRet := lRet .And. oMdlAA1:SetValue("AA1_CODTEC",cAtendente)
	If lMultFil
		lRet := lRet .And. oMdlTGY:SetValue("TGY_FILIAL",cFilTMP)
	EndIf
	lRet := lRet .And. oMdlTGY:SetValue("TGY_CONTRT",cContrato)
	lRet := lRet .And. oMdlTGY:SetValue("TGY_CODTFL",cLocal)
	lRet := lRet .And. oMdlTGY:SetValue("TGY_TFFCOD",cPosto)
	lRet := lRet .And. oMdlTGY:SetValue("TGY_TIPALO",cTipoAloc)

	If lRet
		//MODELO ALOCAÇÃO AVULSA:
		oMdl190G:= FWLoadModel("TECA190G")
		oMdl190G:SetOperation(3)
		oMdl190G:Activate()

		oMdlALC := oMdl190G:GetModel("ALCDETAIL") //Atendente
		At190GPOUI(.T.,2,.T.) //visualizar (projetar)
		
		For nX := 1 To Len(aDias)

			nTamGrid := oMdlALC:Length()
			oMdlALC:GoLine(nTamGrid)

			If nX > 1 //Inclui linha apenas a partir do segundo dado:
				// If oMdlALC:AddLine() != (nTamGrid+1) //Valida inclusão de linha nova:
				// 	lRet := .F.
				// 	cMsg := "Falha ao incluir linha. " + oMdl190G:GetErrorMessage()[6]
				// 	Exit
				// EndIf
				oMdlALC:AddLine()
			EndIf

			lRet := lRet .And. oMdlALC:SetValue("ALC_DATREF",StoD(aDias[nX]["data"])) //DATA
			lRet := lRet .And. oMdlALC:SetValue("ALC_ENTRADA",aDias[nX]["entrada"]) // HORA ENTRADA
			lRet := lRet .And. oMdlALC:SetValue("ALC_SAIDA",aDias[nX]["saida"]) 	//HORA SAIDA
			lRet := lRet .And. oMdlALC:SetValue("ALC_TURNO",aDias[nX]["turno"]) 	//TURNO
			lRet := lRet .And. oMdlALC:SetValue("ALC_SEQ",aDias[nX]["sequencia"])		//SEQUENCIA
			lRet := lRet .And. oMdlALC:SetValue("ALC_TIPO",aDias[nX]["tipo"]) 	//S-TRABALHADO; 2-NÃO TRABALHADO
			lRet := lRet .And. oMdlALC:SetValue("ALC_INTERV",aDias[nX]["intervalo"])	//S-SIM; N-NAO
			lRet := lRet .And. oMdlALC:SetValue("ALC_HEPLAN",aDias[nX]["intrajornada"]) 	//1-SIM; 2-NAO

			If lRet
				nDiasAdd ++
			Else
				cMsg := oMdl190G:GetErrorMessage()[6]
				Exit
			EndIf
		Next nX

		//Commit Alocação Avulsa:
		If lRet
			//seta variavel estatica para "desvio" de telas protheus
			If oMdl190G:VldData()// .And. oMdl190G:CommitData()
				lRet := .T.
				cMsg := "Projeção efetuada."
			Else
				lRet := .F.
				cMsg := oMdl190G:GetErrorMessage()[6]
			EndIf

			If lRet
				For nX := 1 To oMdlALC:Length()
					oMdlALC:GoLine(nX)
					aDias[nX]["legenda"] := oMdlALC:GetValue("ALC_SITABB")
				Next nX
			EndIf
		EndIf
	Else
		cMsg := oMdl190D:GetErrorMessage()[6]
	EndIf
Else
	lRet := .F.
	cMsg := "Usuário sem permissão de projetar agenda"
EndIf

//Limpeza de variavel estática:
At190GPOUI(.F.,0,.F.)

oResponse['projFT'] := {}

Aadd(oResponse['projFT'], JsonObject():New())
aTail(oResponse['projFT'])['retorno']	:= lRet
aTail(oResponse['projFT'])['mensagem']	:= EncodeUTF8(cMsg)
aTail(oResponse['projFT'])['projecao']	:= aDias

//Retorna o JSon com informações solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

WSMETHOD POST projAlocHora WSREST TECWSALOC

Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local oMdl190D	:= NIL
Local oMdl190G	:= NIL
Local oMdlAA1	:= NIL
Local oMdlTGY	:= NIL
Local oMdlALC	:= NIL
Local aDias		:= {}
Local cBody     := Self:GetContent()
Local cFilTMP	:= ""
Local cContrato	:= ""
Local cLocal	:= ""
Local cPosto	:= ""
Local cAtendente:= ""
Local cTipoAloc	:= ""
Local cMsg		:= ""
Local nDiasAdd	:= 0
Local nTamGrid	:= 0
Local nX		:= 0
Local lMultFil  := IsMultFil()
Local lRet		:= .T.

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

If At680Perm(NIL, __cUserId, "039", .T.)
	//Inicializa parametros do Body JSON passado do Front:
	cFilTMP     := oParamBody['filial']
	aDias		:= oParamBody['dias']
	cContrato	:= oParamBody['contrato']
	cLocal      := oParamBody['local']
	cPosto      := oParamBody['posto']
	cAtendente	:= oParamBody['atendente']
	cTipoAloc	:= oParamBody['tipoAloc']

	//aDias = {1,{1data,2entrada,3saída,4turno,5sequencia,6tipo,7saída intervalo,8intrajornada?}}

	//MODELO MESA OPERACIONAL:
	oMdl190D:= FWLoadModel("TECA190D")
	oMdl190D:SetOperation(3)
	oMdl190D:Activate()

	oMdlAA1 := oMdl190D:GetModel("AA1MASTER") //Atendente
	oMdlTGY := oMdl190D:GetModel("TGYMASTER") //Alocação

	//Carga do atendente AA1MASTER/ Demais dados TGYMASTER(Alocação):
	lRet := lRet .And. oMdlAA1:SetValue("AA1_CODTEC",cAtendente)
	If lMultFil
		lRet := lRet .And. oMdlTGY:SetValue("TGY_FILIAL",cFilTMP)
	EndIf
	lRet := lRet .And. oMdlTGY:SetValue("TGY_CONTRT",cContrato)
	lRet := lRet .And. oMdlTGY:SetValue("TGY_CODTFL",cLocal)
	lRet := lRet .And. oMdlTGY:SetValue("TGY_TFFCOD",cPosto)
	lRet := lRet .And. oMdlTGY:SetValue("TGY_TIPALO",cTipoAloc)

	If lRet
		//MODELO ALOCAÇÃO AVULSA:
		oMdl190G:= FWLoadModel("TECA190G")
		oMdl190G:SetOperation(3)
		oMdl190G:Activate()

		oMdlALC := oMdl190G:GetModel("ALCDETAIL") //Atendente
		At190GPOUI(.T.,2,.F.) //visualizar (projetar)
		
		For nX := 1 To Len(aDias)

			nTamGrid := oMdlALC:Length()
			oMdlALC:GoLine(nTamGrid)

			If nX > 1 //Inclui linha apenas a partir do segundo dado:
				// If oMdlALC:AddLine() != (nTamGrid+1) //Valida inclusão de linha nova:
				// 	lRet := .F.
				// 	cMsg := "Falha ao incluir linha. " + oMdl190G:GetErrorMessage()[6]
				// 	Exit
				// EndIf
				oMdlALC:AddLine()
			EndIf

			lRet := lRet .And. oMdlALC:SetValue("ALC_DATREF",StoD(aDias[nX]["data"])) //DATA
			lRet := lRet .And. oMdlALC:SetValue("ALC_ENTRADA",aDias[nX]["entrada"]) // HORA ENTRADA
			lRet := lRet .And. oMdlALC:SetValue("ALC_SAIDA",aDias[nX]["saida"]) 	//HORA SAIDA
			lRet := lRet .And. oMdlALC:SetValue("ALC_TURNO",aDias[nX]["turno"]) 	//TURNO
			lRet := lRet .And. oMdlALC:SetValue("ALC_SEQ",aDias[nX]["sequencia"])		//SEQUENCIA
			lRet := lRet .And. oMdlALC:SetValue("ALC_TIPO",aDias[nX]["tipo"]) 	//S-TRABALHADO; 2-NÃO TRABALHADO
			lRet := lRet .And. oMdlALC:SetValue("ALC_INTERV",aDias[nX]["intervalo"])	//S-SIM; N-NAO
			lRet := lRet .And. oMdlALC:SetValue("ALC_HEPLAN",aDias[nX]["intrajornada"]) 	//1-SIM; 2-NAO

			If lRet
				nDiasAdd ++
			Else
				cMsg := oMdl190G:GetErrorMessage()[6]
				Exit
			EndIf
		Next nX

		//Commit Alocação Avulsa:
		If lRet
			//Modelo retorna falso para visualizar:
			If !oMdl190G:VldData()// .And. oMdl190G:CommitData()
				lRet := .T.
				cMsg := "Projeção efetuada."

				For nX := 1 To oMdlALC:Length()
					oMdlALC:GoLine(nX)
					aDias[nX]["legenda"] := oMdlALC:GetValue("ALC_SITABB")
				Next nX
			EndIf
		EndIf
	Else
		cMsg := oMdl190D:GetErrorMessage()[6]
	EndIf
Else
	lRet := .F.
	cMsg := "Usuário sem permissão de projetar agenda"
EndIf

//Limpeza de variavel estática:
At190GPOUI(.F.,0,.F.)

oResponse['projFT'] := {}

Aadd(oResponse['projFT'], JsonObject():New())
aTail(oResponse['projFT'])['retorno']	:= lRet
aTail(oResponse['projFT'])['mensagem']	:= EncodeUTF8(cMsg)
aTail(oResponse['projFT'])['projecao']	:= aDias

//Retorna o JSon com informações solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

WSMETHOD POST gravFT WSREST TECWSALOC

Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local oMdl190D	:= NIL
Local oMdl190G	:= NIL
Local oMdlAA1	:= NIL
Local oMdlTGY	:= NIL
Local oMdlALC	:= NIL
Local aDias		:= {}
Local cBody     := Self:GetContent()
Local cFilTMP	:= ""
Local cContrato	:= ""
Local cLocal	:= ""
Local cPosto	:= ""
Local cAtendente:= ""
Local cTipoAloc	:= ""
Local cMsg		:= ""
Local nDiasAdd	:= 0
Local nTamGrid	:= 0
Local nX		:= 0
Local lMultFil  := IsMultFil()
Local lRet		:= .T.

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

If At680Perm(NIL, __cUserId, "040", .T.)
	//Inicializa parametros do Body JSON passado do Front:
	cFilTMP     := oParamBody['filial']
	aDias		:= oParamBody['dias']
	cContrato	:= oParamBody['contrato']
	cLocal      := oParamBody['local']
	cPosto      := oParamBody['posto']
	cAtendente	:= oParamBody['atendente']
	cTipoAloc	:= oParamBody['tipoAloc'] //Folga Trabalhada sempre
	lAlocConf	:= oParamBody['alocConf']

	//MODELO MESA OPERACIONAL:
	oMdl190D:= FWLoadModel("TECA190D")
	oMdl190D:SetOperation(3)
	oMdl190D:Activate()

	//lPermConfl-----True:---------------False:
	//lAlocConf = 1 |apenas disponíveis	|apenas disponíveis
	//lAlocConf = 2 |todos os dias		|cancelar
	At190DPOUI(.T.,lAlocConf)

	oMdlAA1 := oMdl190D:GetModel("AA1MASTER") //Atendente
	oMdlTGY := oMdl190D:GetModel("TGYMASTER") //Alocação

	//Carga do atendente AA1MASTER/ Demais dados TGYMASTER(Alocação):
	lRet := lRet .And. oMdlAA1:SetValue("AA1_CODTEC",cAtendente)
	If lMultFil
		lRet := lRet .And. oMdlTGY:SetValue("TGY_FILIAL",cFilTMP)
	EndIf
	lRet := lRet .And. oMdlTGY:SetValue("TGY_CONTRT",cContrato)
	lRet := lRet .And. oMdlTGY:SetValue("TGY_CODTFL",cLocal)
	lRet := lRet .And. oMdlTGY:SetValue("TGY_TFFCOD",cPosto)
	lRet := lRet .And. oMdlTGY:SetValue("TGY_TIPALO",cTipoAloc)

	If lRet
		//MODELO ALOCAÇÃO AVULSA:
		oMdl190G:= FWLoadModel("TECA190G")
		oMdl190G:SetOperation(3)
		oMdl190G:Activate()

		oMdlALC := oMdl190G:GetModel("ALCDETAIL") //Atendente
		At190GPOUI(.T.,1,.T.) //visualizar (projetar)
		
		For nX := 1 To Len(aDias)

			nTamGrid := oMdlALC:Length()
			oMdlALC:GoLine(nTamGrid)

			If nX > 1 //Inclui linha apenas a partir do segundo dado:
				//If oMdlALC:AddLine() != (nTamGrid+1) //Valida inclusão de linha nova:
					//lRet := .F.
					//cMsg := "Falha ao incluir linha. " + oMdl190G:GetErrorMessage()[6]
					//Exit
				//EndIf
				oMdlALC:AddLine()
			EndIf

			lRet := lRet .And. oMdlALC:SetValue("ALC_DATREF",StoD(aDias[nX]["data"])) //DATA
			lRet := lRet .And. oMdlALC:SetValue("ALC_ENTRADA",aDias[nX]["entrada"]) // HORA ENTRADA
			lRet := lRet .And. oMdlALC:SetValue("ALC_SAIDA",aDias[nX]["saida"]) 	//HORA SAIDA
			lRet := lRet .And. oMdlALC:SetValue("ALC_TURNO",aDias[nX]["turno"]) 	//TURNO
			lRet := lRet .And. oMdlALC:SetValue("ALC_SEQ",aDias[nX]["sequencia"])		//SEQUENCIA
			lRet := lRet .And. oMdlALC:SetValue("ALC_TIPO",aDias[nX]["tipo"]) 	//S-TRABALHADO; 2-NÃO TRABALHADO
			lRet := lRet .And. oMdlALC:SetValue("ALC_INTERV",aDias[nX]["intervalo"])	//S-SIM; N-NAO
			lRet := lRet .And. oMdlALC:SetValue("ALC_HEPLAN",aDias[nX]["intrajornada"]) 	//1-SIM; 2-NAO

			If lRet
				nDiasAdd ++
			Else
				cMsg := oMdl190G:GetErrorMessage()[6]
				Exit
			EndIf
		Next nX

		//Commit Alocação Avulsa:
		If lRet
			//seta variavel estatica para "desvio" de telas protheus
			If oMdl190G:VldData() .And. oMdl190G:CommitData()
				lRet := .T.
				cMsg := "Gravação efetuada."
			Else
				lRet := .F.
				cMsg := oMdl190G:GetErrorMessage()[6]
			EndIf
		EndIf
	Else
		cMsg := oMdl190D:GetErrorMessage()[6]
	EndIf
Else
	lRet := .F.
	cMsg := "Usuário sem permissão de gravar agenda"
EndIf

//Limpeza de variaveis estáticas:
At190GPOUI(.F.,2,.F.)
At190DPOUI(.F.,3)

oResponse['gravFT'] := {}

Aadd(oResponse['gravFT'], JsonObject():New())
aTail(oResponse['gravFT'])['retorno']	:= lRet
aTail(oResponse['gravFT'])['mensagem']	:= EncodeUTF8(cMsg)
aTail(oResponse['gravFT'])['gravação']	:= aDias

//Retorna o JSon com informações solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return
