#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "EnsaiosCalculadosAPI.CH"

/*/{Protheus.doc} processinspectioncalculedtests
API Ensaios Calculados da Inspeção de Processos - Qualidade
@author brunno.costa
@since  22/09/2022
/*/
WSRESTFUL processinspectioncalculedtests DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ensaios Calculados Inspeção de Processos"

    WSDATA RecnoQPK  as STRING  OPTIONAL

    WSMETHOD POST calculedtests;
    DESCRIPTION STR0002; //"Retorna Ensaios Calculados"
    	WSSYNTAX "api/qip/v1/calculedtests" ;
	PATH "/api/qip/v1/calculedtests" ;
	TTALK "v1"

ENDWSRESTFUL

WSMETHOD POST calculedtests WSSERVICE processinspectioncalculedtests
	
	Local aAmostrasMemoria      := Nil
	Local cOperacao             := Nil
	Local nRecnoQPK             := Nil
	Local oData                 := JsonObject():New()
    Local oQIPEnsaiosCalculados := Nil
	Local oQualityAPIManager    := QualityAPIManager():New(, Self,)

	oData:fromJson(DecodeUTF8(Self:GetContent()))
	nRecnoQPK        := oData['recno']
	cOperacao        := oData['operation']
	aAmostrasMemoria := oData['items']
	oQIPEnsaiosCalculados := QIPEnsaiosCalculados():New(nRecnoQPK, cOperacao, aAmostrasMemoria)
	oQIPEnsaiosCalculados:ProcessaEnsaiosCalculados()
	oQualityAPIManager:RespondeArray(oQIPEnsaiosCalculados:SintetizaERetornaApenasUltimaAmostraEnsaios(), .F.)

Return 




