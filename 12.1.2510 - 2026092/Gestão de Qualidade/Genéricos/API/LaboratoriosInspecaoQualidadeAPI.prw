#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "LaboratoriosInspecaoQualidadeAPI.CH"

#DEFINE X5_FILIAL     1
#DEFINE X5_TABELA     2
#DEFINE X5_CHAVE      3
#DEFINE X5_DESCRICAO  4

/*/{Protheus.doc} qualityinspectionlaboratory
API Laboratório da Inspeção da Qualidade - Qualidade
@author brunno.costa
@since  31/10/2024
/*/
WSRESTFUL qualityinspectionlaboratory DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ensaios Calculados Inspeção da Qualidade"
	
	WSDATA Login  as STRING OPTIONAL
	WSDATA Modulo as STRING OPTIONAL
	WSDATA Table  as STRING OPTIONAL

    WSMETHOD GET list;
    DESCRIPTION STR0001; //"Retorna Lista de Laboratórios"
    WSSYNTAX "api/qip/v1/list/{Login}" ;
	PATH "/api/qip/v1/list" ;
	TTALK "v1"

	WSMETHOD GET sx5list;
    DESCRIPTION STR0004; //"Retorna Lista da SX5"
    WSSYNTAX "api/qip/v1/sx5list/{Table}" ;
    PATH "api/qip/v1/sx5list" ;
    TTALK "v1"

ENDWSRESTFUL


WSMETHOD GET list PATHPARAM Login, Modulo WSSERVICE qualityinspectionlaboratory
	Local aDados      := {}
	Local aQ2SX5      := {}
	Local nIndSX5     := Nil
	Local nTotal      := 1
	Local oAPIManager := QualityAPIManager():New(, Self,)
	Local oItemAPI    := Nil

	Default Self:Login := ""
	Default Self:Modulo := ""
	
	If oAPIManager:ValidaPrepareInDoAmbiente()
		oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario(Self:Modulo)
		
		aQ2SX5 := FWGetSX5( "Q2" )
		nTotal := Len(aQ2SX5)

		For nIndSX5 := 1 to nTotal
			If aQ2SX5[nIndSX5][X5_FILIAL] == xFilial("SX5")

				If oAPIManager:lPELaboratoriosRelacionadosAoUsuario
					If !oAPIManager:ChecaLaboratorioValidoParaUsuario(Self:Login, "qualityinspectionlaboratory/api/qip/v1/list", aQ2SX5[nIndSX5][X5_CHAVE])
						Loop
					EndIf
				EndIf

				oItemAPI                   := JsonObject():New()
				oItemAPI["laboratoryCode"] := aQ2SX5[nIndSX5][X5_CHAVE]
				oItemAPI["laboratory"    ] := Acentuacao(aQ2SX5[nIndSX5][X5_DESCRICAO])
				aAdd(aDados, oItemAPI)
			EndIf
		Next
	EndIf
	oAPIManager:RespondeArray(aDados, .F.)
Return 

WSMETHOD GET sx5list PATHPARAM Table WSSERVICE qualityinspectionlaboratory

	Local aDados      := {}
	Local aQ2SX5      := {}
	Local nIndSX5     := Nil
	Local nTotal      := 1
	Local oAPIManager := QualityAPIManager():New(, Self,)
	Local oItemAPI    := Nil

	Default Self:Table := "Q2"
	
	If oAPIManager:ValidaPrepareInDoAmbiente()		
		aQ2SX5 := FWGetSX5( Self:Table )
		nTotal := Len(aQ2SX5)

		For nIndSX5 := 1 to nTotal
			If aQ2SX5[nIndSX5][X5_FILIAL] == xFilial("SX5")
				oItemAPI          := JsonObject():New()
				oItemAPI["value"] := aQ2SX5[nIndSX5][X5_CHAVE]
				oItemAPI["label"] := AllTrim(Acentuacao(aQ2SX5[nIndSX5][X5_DESCRICAO])) + " ("+AllTrim(aQ2SX5[nIndSX5][X5_CHAVE])+")"
				aAdd(aDados, oItemAPI)
			EndIf
		Next
	EndIf

	oAPIManager:RespondeArray(aDados, .F.)
	
Return 

/*/{Protheus.doc} Acentuacao
Capitaliza e Acentua Dicionário Padrão
@author brunno.costa
@since  31/10/2024
/*/
Static Function Acentuacao(cTitulo)
	Local cReturn := StrTran(Capital(cTitulo), "Laboratorio", STR0002) //"Laboratório"
	cReturn := StrTran(cReturn, "Fisico", STR0003) //"Físico"
Return cReturn






