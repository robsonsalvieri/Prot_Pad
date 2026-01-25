#include "protheus.ch"

/*/
    {Protheus.doc} FINA138B
    (long_description)
    @type  Function
    @author Daniel Moda
    @since 13/03/2023
    @version 1.0
 /*/
Function FINA138B()
    
Return

/*/
    {Protheus.doc} FINA138BTFRegistry
    Classe resposável para obter os registros do Registry
    @type  Class
    @author Daniel Moda
    @since 27/12/2022
    @version 1.0
/*/
Class FINA138BTFRegistry from LongNameClass

Data oUrlTF As Object

Method New() CONSTRUCTOR
Method Read()
Method Update()
Method GetListURL()
Method GetDataExpiracao()
Method GetEndPointRegistry()
 
EndClass

/*/
    {Protheus.doc} FINA138BTFRegistry::New
    construtor
    @type method
/*/
Method New() Class FINA138BTFRegistry

Self:Read()

Return self
 
/*/
    {Protheus.doc} FINA138BTFRegistry::Read
    Responsável pela leitura das URLs cadastradas no Registry.
    @type method
    @return Array, Lista as URLs utilizadas nos produtos TechFin cadastradas no Registry.
/*/
Method Read() Class FINA138BTFRegistry

Local aUrlTF      As Array
Local cRegistry   As Character
Local cContent    As Character
Local cDataExp    As Character
Local cUrlConfig  As Character
Local nTotalUrl   As Numeric
Local nI          As Numeric
Local oParam      As Object
Local oUrl        As Object

aUrlTF     := {}
cRegistry  := ''
cContent   := ''
cDataExp   := ''
cUrlConfig := ''
nTotalUrl  := 00
nI         := 01
oParam     := Nil
oUrl       := Nil

cDataExp  := Self:GetDataExpiracao()
cRegistry := GetSrvProfString("fw-tf-registry-endpoint", "")
If Empty( cRegistry )
    cRegistry := "https://endpoint-registry.totvs.app/"
EndIf

If Empty( cDataExp ) .Or. cDataExp <= FWTimeStamp() .Or. Self:GetEndPointRegistry() <> cRegistry

    Self:Update( aUrlTF )

EndIf

aUrlTF    := Self:GetListURL()
nTotalUrl := Len( aUrlTF )
oParam    := FwTfConfig()

Self:oUrlTF := oParam

FWFreeArray( aUrlTF )

FreeObj( oParam )
FreeObj( oUrl )

Return

/*/
    {Protheus.doc} FINA138BTFRegistry::Update
    Responsável pela atualização dos dados, tabela SYS_APP_PARAM.
    @type method
    @param aUrlTF, logical, URLs que serão verificadas no Registry
    @param oRegistry, object, URLs no Registry
    @return Nil
/*/
Method Update( aUrlTF As Array, oRegistry As Json ) Class FINA138BTFRegistry

Local cUrlApps  As Character
Local cVerUrlA  As Character
Local nTotalUrl As Numeric
Local nX        As Numeric
Local oParam    As Object
Local lAutomato As Logical

Default aUrlTF    := {}
Default oRegistry := Nil

cUrlApps  := ""
cVerUrlA  := ""
lAutomato := ValType(oRegistry) == "J"

If Len( aUrlTF ) == 0
    aUrlTF := Self:GetListURL()
EndIf
nTotalUrl := Len( aUrlTF )
nX        := 01
oParam    := JsonObject():New()

If .Not. lAutomato
    For nX := 1 To nTotalUrl
        cVerUrlA := "1"
        cUrlApps := FwTotvsAppsRegistry():GetServiceURL( aUrlTF[nX][01], cVerUrlA )
        While .Not. Empty( cUrlApps )
            cUrlApps := FwTotvsAppsRegistry():GetServiceURL( aUrlTF[nX][01], cVerUrlA )
            If .Not. Empty( cUrlApps )
                oParam[ aUrlTF[nX][01] + "-V" + cVerUrlA ] := cUrlApps
            EndIf
            cVerUrlA := Soma1(cVerUrlA)
        EndDo
    Next
Else
    oParam := oRegistry
EndIf

oParam[ 'risk-dataexpiracao' ]      := FWTimeStamp( 1, date() + 01 )
oParam[ 'fw-tf-registry-endpoint' ] := GetSrvProfString("fw-tf-registry-endpoint", "")
FwTFSetConfig( oParam )

FreeObj( oParam )

Return

/*/
    {Protheus.doc} FINA138BTFRegistry::GetListURL
    Responsável para definir as URLs utilizadas nos produtos TechFin.
    aUrlTF := { 'Service', 'Version' }
    Service = tfmn (techfin Mais Negocios)
    @type method
    @return Array, lista com as URLs utilizadas pelos produtos TechFin.
/*/
Method GetListURL() Class FINA138BTFRegistry

Local aUrlTF As Array

aUrlTF := { {'risk-totvsrisk-position'},;
            {'risk-totvsrisk-installment-sale'},;
            {'risk-totvsrisk-bankslip'},;
            {'risk-riskapi-clearbalance'},;
            {'risk-riskapi-organizations'},;
            {'risk-riskapi-invoicefooter'},;
            {'risk-riskapi-invoicecancelation'},;
            {'risk-riskapi-creditconcession'},;
            {'risk-riskapi-invoice'},;
            {'risk-riskapi-credit-ticket'},;
            {'risk-riskapi-simulate_condition'},;
            {'risk-riskapi-concession-creditconcession'},;
            {'risk-protheusapi-conciliation'},;
            {'risk-protheusapi-conciliation-opendate'},;
            {'risk-protheusapi-credit-ticket'},;
            {'risk-protheusapi-position'},;
            {'risk-protheusapi-credit-concession'},;
            {'risk-protheusapi-invoice-cancellation'},;
            {'risk-protheusapi-invoice-partner'},;
            {'risk-protheusapi-erp-general-params'},;
            {'risk-protheusapi-advance-payment'},;
            {'risk-antecipa-bearers'},;
            {'rac-token'};
          }

Return aUrlTF

/*/
    {Protheus.doc} FINA138BTFRegistry::GetDataExpiracao
    Responsável por retornar a data de expiração da consulta.
    @type method
    @return Character, data de expiração.
/*/
Method GetDataExpiracao() Class FINA138BTFRegistry

Local cDataExp As Character
Local oParam   As Object

oParam   := FwTfConfig()
cDataExp := oParam[ 'risk-dataexpiracao' ]

FreeObj( oParam )

Return cDataExp

/*/
    {Protheus.doc} FINA138BTFRegistry::GetEndPointRegistry
    Responsável por retornar o ambiente utilizado no appserver.ini para o registry.
    @type method
    @return cEndPointReg, endpoint do registry.
/*/
Method GetEndPointRegistry() Class FINA138BTFRegistry

Local cEndPointReg As Character
Local oParam       As Object

cEndPointReg := ''

oParam       := FwTfConfig()
cEndPointReg := oParam[ 'fw-tf-registry-endpoint' ]
If Empty( cEndPointReg )
    cEndPointReg := "https://endpoint-registry.totvs.app/"
EndIf

FreeObj( oParam )

Return cEndPointReg
