#Include "ensaioscalculadosinspecaodeentradasapi.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} incominginspectioncalculedtests
API Ensaios Calculados da Inspeção de Entradas - Qualidade
@author brunno.costa
@since  28/10/2022
/*/
WSRESTFUL incominginspectioncalculedtests DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ensaios Calculados Inspeção de Entradas"

    WSDATA RecnoQEK  as STRING  OPTIONAL

    WSMETHOD POST calculedtests;
    DESCRIPTION STR0002; //"Retorna Ensaios Calculados"
    	WSSYNTAX "api/qie/v1/calculedtests" ;
	PATH "/api/qie/v1/calculedtests" ;
	TTALK "v1"

ENDWSRESTFUL

WSMETHOD POST calculedtests WSSERVICE incominginspectioncalculedtests
	
	Local aAmostrasMemoria      := Nil
	Local nRecnoQEK             := Nil
	Local oData                 := JsonObject():New()
    Local oQIEEnsaiosCalculados := Nil
	Local oQualityAPIManager    := QualityAPIManager():New(, Self,)

	oData:fromJson(DecodeUTF8(Self:GetContent()))
	nRecnoQEK        := oData['recno']
	aAmostrasMemoria := oData['items']
	oQIEEnsaiosCalculados := QIEEnsaiosCalculados():New(nRecnoQEK, aAmostrasMemoria)
	oQIEEnsaiosCalculados:ProcessaEnsaiosCalculados()
	oQualityAPIManager:RespondeArray(oQIEEnsaiosCalculados:SintetizaERetornaApenasUltimaAmostraEnsaios(), .F.)

Return 
