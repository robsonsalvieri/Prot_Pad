#INCLUDE "RESTFUL.CH"
#INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TAFSmartView
API TAFSmartView - Catálogo dos Objetos Disponíveis no TAF
@author Denis Souza
@since 03/10/2023
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSRESTFUL TAFSmartView DESCRIPTION "API TAFSmartView - Catálogo dos Objetos Disponíveis no TAF" FORMAT APPLICATION_JSON

WSDATA companyId  AS STRING
WSDATA branchCode AS STRING
WSDATA scope	  AS STRING
WSDATA svOption   AS STRING

WSMETHOD GET getBusinessObject;
DESCRIPTION "Retorna a lista dos objetos de negócio que pertencem ao TAF";
WSSYNTAX "/api/tsi/v1/TAFSmartView/getBusinessObject/?{companyId}&{scope}";
PATH "/api/tsi/v1/TAFSmartView/getBusinessObject/";
TTALK "v1";

WSMETHOD GET getConfigured;
DESCRIPTION "Retorna a lista dos objetos de negócio que pertencem ao TAF";
WSSYNTAX "/api/tsi/v1/TAFSmartView/getConfigured/?{companyId}";
PATH "/api/tsi/v1/TAFSmartView/getConfigured/";
TTALK "v1";

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type		 method
@description Retorna o stamp da V80 de acordo com o alias e companyId
@author      Denis Souza
@since       03/10/2023
@return		 lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET getBusinessObject QUERYPARAM companyId,scope WSRESTFUL TAFSmartView

Local lRet 			   as logical
Local nCodeError       as numeric
Local cMessage         as character
Local cDetailedMessage as character
Local aCompany		   as array
Local oResponse        as object
Local cEmpRequest	   as character
Local cFilRequest	   as character

lRet 			 := .T.
nCodeError       := 404
cMessage         := ""
cDetailedMessage := EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição.")
aCompany		 := {}
oResponse        := JsonObject():New()
cEmpRequest	     := ""
cFilRequest	     := ""

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault(nCodeError,EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId' ." ),.T.,,cDetailedMessage)
elseIf self:scope == Nil .Or. Empty(self:scope)
	lRet := .F.
	SetRestFault(nCodeError,EncodeUTF8("Escopo não informado no parâmetro 'scope' ." ),.T.,,EncodeUTF8("Verifique o parâmetro 'scope' enviado na requisição."))
Else
	aCompany := StrTokArr( self:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,EncodeUTF8("Empresa|Filial inválida informado no parâmetro 'companyId' ." ),.T.,,cDetailedMessage)
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())
		If PrepEnv( cEmpRequest, cFilRequest )

			TafSvScope(self:scope,@oResponse)

			self:SetResponse(oResponse:toJSON())
		Else
			lRet := .F.
			cMessage := EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
			SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage)
		EndIf
	Endif
Endif

FreeObj( oResponse )
oResponse := Nil
DelClassIntF() //Exclui todas classes de interface da thread..

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type		 method
@description Retorna o stamp da V80 de acordo com o alias e companyId
@author      Denis Souza
@since       03/10/2023
@return		 lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET getConfigured QUERYPARAM companyId WSRESTFUL TAFSmartView

Local lRet 			   as logical
Local nCodeError       as numeric
Local cMessage         as character
Local cDetailedMessage as character
Local aCompany		   as array
Local oResponse        as object
Local cEmpRequest	   as character
Local cFilRequest	   as character
Local lSmartView       as logical

lRet 			 := .T.
nCodeError       := 404
cMessage         := ""
cDetailedMessage := EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição.")
aCompany		 := {}
oResponse        := JsonObject():New()
cEmpRequest	     := ""
cFilRequest	     := ""

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault(nCodeError,EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId' ." ),.T.,,cDetailedMessage)
Else
	aCompany := StrTokArr( self:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,EncodeUTF8("Empresa|Filial inválida informado no parâmetro 'companyId' ." ),.T.,,cDetailedMessage)
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())
		If PrepEnv( cEmpRequest, cFilRequest )
			lSmartView  := GetRpoRelease() >= '12.1.2310' .and. totvs.framework.smartview.util.isConfig()
            oResponse["configured"] := lSmartView
			self:SetResponse(oResponse:toJSON())
		Else
			lRet := .F.
			cMessage := EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
			SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage)
		EndIf
	Endif
Endif

FreeObj( oResponse )
oResponse := Nil
DelClassIntF() //Exclui todas classes de interface da thread..

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafSvScope

@author Denis Souza
@since 02/10/2023
@version 1.0
*/
//-------------------------------------------------------------------  
Static Function TafSvScope(cScope,oResponse)

local aList := {}
local nCont := 0
local nAte  := 0

default cScope := ''
default oResponse := nil

oResponse["svOptions"] := {}

if cScope = 'all' .Or. cScope == 'reinf'
	if TafSvPerg("TAFTR00001")
		aadd(aList,{EncodeUTF8("R-2010 / R-2020"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock2010and2020"),;
		EncodeUTF8("Retenção de contribuição previdenciária - (R-2010) serviços tomados / (R-2020) serviços prestados"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir os movimentos do TAF que são utilizados na apuração do respectivo evento de forma analítica, já na opção de relatório (report) é possível confrontar esses movimentos com o retorno do governo (se a apuração estiver transmitida e protocolada)."),;
		EncodeUTF8("Objeto ReinfBlock2010and2020"),;
		EncodeUTF8("Visão(data-grid) e Relatório(report)"),;
		EncodeUTF8("(C20,C30,C35,C8C,T9C,C1H,LEM,T5M,V0W)"),;
		EncodeUTF8("https://tdn.totvs.com/x/Wn0ELg")})
	endif
	if TafSvPerg("TAFTR00008")
		aadd(aList,{EncodeUTF8("R-2030 / R-2040"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock2030and2040"),;
		EncodeUTF8("Recursos recebidos por associação desportiva (R-2030) / Recursos repassados para associação desportiva (R-2040)"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir os movimentos do TAF que são utilizados na apuração do respectivo evento de forma analítica, já na opção de relatório (report) é possível confrontar esses movimentos com o retorno do governo (se a apuração estiver transmitida e protocolada)."),;
		EncodeUTF8("Objeto ReinfBlock2030and2040"),;
		EncodeUTF8("Visão(data-grid) e Relatório(report)"),;
		EncodeUTF8("C20,C30,T9Q,C35,C1H,C1L,C1G,T9Q,LEM,T5M,T5P,T9E"),;
		EncodeUTF8("https://tdn.totvs.com/x/Aar1Lw")})
	endif
	if TafSvPerg("TAFTR00002")
		aadd(aList,{EncodeUTF8("R-2050 / R-2055"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock2050and2055"),;
		EncodeUTF8("Comercialização de produção (R-2050) / Aquisição de produção rural (R-2055)"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir os movimentos do TAF que são utilizados na apuração do respectivo evento de forma analítica, já na opção de relatório (report) é possível confrontar esses movimentos com o retorno do governo (se a apuração estiver transmitida e protocolada)."),;
		EncodeUTF8("Objeto ReinfBlock2050and2055"),;
		EncodeUTF8("Visão(data-grid) e Relatório(report)"),;
		EncodeUTF8("(C20,C30,C35,T9Q,C1G,T5L,LEM,T9E,C1H,V0X,V0W,V6B,V5S)"),;
		EncodeUTF8("https://tdn.totvs.com/x/8o9CLg")})
	endif
	if TafSvPerg("TAFTR00003")
		aadd(aList,{EncodeUTF8("R-2060"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock2060"),;
		EncodeUTF8("R-2060 - Contribuição previdenciária sobre a receita bruta - CPRB"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir os movimentos do TAF que são utilizados na apuração do respectivo evento de forma analítica, já na opção de relatório (report) é possível confrontar esses movimentos com o retorno do governo (se a apuração estiver transmitida e protocolada)."),;
		EncodeUTF8("Objeto ReinfBlock2060"),;
		EncodeUTF8("Visão(data-grid) e Relatório(report)"),;
		EncodeUTF8("(C5M,C5V,V48,T9T,T9C,V0W,V0Z)"),;
		EncodeUTF8("https://tdn.totvs.com/x/_vuJLg")})
	endif
	if TafSvPerg("TAFTR00006")
		aadd(aList,{EncodeUTF8("R-2099 / R-9011"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock2099and9011"),;
		EncodeUTF8("Fechamento dos eventos da série R-2000 (R-2099) / Consolidação de bases e tributos - Contrib. previdenciária (R-9011)"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir o(s) fechamento(s) do bloco 20 de forma analítica, já na opção de relatório (report) é possível confrontar as totalizações do governo (se o fechamento estiver transmitido e protocolado)."),;
		EncodeUTF8("Objeto ReinfBlock2099and9011"),;
		EncodeUTF8("Visão(data-grid) e Relatório(report)"),;
		EncodeUTF8("(V0C,V0E,V0F,V0G,V0H,V0I,V6C,V0J)"),;
		EncodeUTF8("https://tdn.totvs.com/x/VwcgLw")})
	endif
	if TafSvPerg("TAFTR00010")
		aadd(aList,{EncodeUTF8("R-3010"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock3010"),;
		EncodeUTF8("R-3010 - Receita de espetáculo desportivo"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir os movimentos do TAF que são utilizados na apuração do respectivo evento de forma analítica."),;
		EncodeUTF8("Objeto ReinfBlock3010"),;
		EncodeUTF8("Visão(data-grid)"),;
		EncodeUTF8("(T9F,C1E,T9G,T9H,T9J,C1G,C07,C09)"),;
		EncodeUTF8("https://tdn.totvs.com/x/PtWcM")})
	endif
	if TafSvPerg("TAFTR00004")
		aadd(aList,{EncodeUTF8("R-4010"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock4010"),;
		EncodeUTF8("Pagamentos/créditos a beneficiário pessoa física - R-4010"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir os movimentos do TAF que são utilizados na apuração do respectivo evento de forma analítica, já na opção de relatório (report) é possível confrontar esses movimentos com o retorno do governo (se a apuração estiver transmitida e protocolada)."),;
		EncodeUTF8("Objeto ReinfBlock4010"),;
		EncodeUTF8("Visão(data-grid) e Relatório(report)"),;
		EncodeUTF8("(C1H,T9A,V3O,V3X,C1G,V4F,V4G,C20,C30,C35,V4C,V84,V4D,T9Q,V88,LEM,V3S,V47,V4L,V83,V4M,T9E,V89,V3U,V3V,V46,V4I,V85,V4J,V4H,V90,V4Q,V9D,V9G)"),;
		EncodeUTF8("https://tdn.totvs.com/x/VSmhLg")})
	endif
	if TafSvPerg("TAFTR00005")
		aadd(aList,{EncodeUTF8("R-4020"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock4020"),;
		EncodeUTF8("R-4020 - Pagamentos/créditos a beneficiário pessoa jurídica"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir os movimentos do TAF que são utilizados na apuração do respectivo evento de forma analítica, já na opção de relatório (report) é possível confrontar esses movimentos com o retorno do governo (se a apuração estiver transmitida e protocolada)."),;
		EncodeUTF8("Objeto ReinfBlock4020"),;
		EncodeUTF8("Visão(data-grid) e Relatório(report)"),;
		EncodeUTF8("(V4F,V4G,V3O,C1G,V3X,C1H,T9A,C20,C30,C35,T9Q,LEM,V3S,V47,T9E,V3U,V3V,V46,V4H,V5C,V9D,V9G)"),;
		EncodeUTF8("https://tdn.totvs.com/x/LPPGLg")})
	endif
	if TafSvPerg("TAFTR00009")
		aadd(aList,{EncodeUTF8("R-4040 / R-4080"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock4040and4080"),;
		EncodeUTF8("R-4040 Pagamentos/créditos a beneficiários não identificados / R-4080 Retenção no recebimento"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir os movimentos do TAF que são utilizados na apuração do respectivo evento de forma analítica, já na opção de relatório (report) é possível confrontar esses movimentos com o retorno do governo (se a apuração estiver transmitida e protocolada)."),;
		EncodeUTF8("Objeto ReinfBlock4040and4080"),;
		EncodeUTF8("Visão(data-grid) e Relatório(report)"),;
		EncodeUTF8("(V4K,V9B,C1H,V3O,V4N,V97,V9D,V9G)"),;
		EncodeUTF8("https://tdn.totvs.com/x/qw0pM")})
	endif
	if TafSvPerg("TAFTR00007")
		aadd(aList,{EncodeUTF8("R-4099 / R-9015"),;
		EncodeUTF8("fiscal.sv.taf.reinfblock4099and9015"),;
		EncodeUTF8("Fechamento dos eventos da série R-4000 (R-4099) / Consolidação das retenções na fonte (R-9015)"),;
		EncodeUTF8("Com a opção de visão (data-grid) é possível conferir o(s) fechamento(s) do bloco 40 de forma analítica, já na opção de relatório (report) é possível confrontar as totalizações do governo (se o fechamento estiver transmitido e protocolado)."),;
		EncodeUTF8("Objeto ReinfBlock4099and9015"),;
		EncodeUTF8("Visão(data-grid) e Relatório(report)"),;
		EncodeUTF8("(V3W,V9F,V9Q)"),;
		EncodeUTF8("https://tdn.totvs.com/x/RfmjLw")})
	endif
endif

if cScope = 'all' .Or. cScope == 'tsi'
	if TafSvPerg("TAFTRR1261")
		aadd(aList,{EncodeUTF8("Documentos Divergentes"),;
		EncodeUTF8("fiscal.sv.taf.integrateddocuments"),;
		EncodeUTF8("Conferência dos documentos fiscais entre o SIGAFIS e o SIGATAF"),;
		EncodeUTF8("Com a opção de tabela dinâmica(pivot-table) é possível confrontar os valores dos documentos fiscais entre o SIGAFIS e o SIGATAF, através dos níveis: Filial, Data, CFOP e Documento."),;
		EncodeUTF8("Objeto IntegratedDocuments"),;
		EncodeUTF8("Somente Tabela Dinâmica(pivot-table)"),;
		EncodeUTF8("(C20,C30,C35,C1H,C1L,C0Y,SFT)"),;
		EncodeUTF8("https://tdn.totvs.com/x/saFjLQ")})
	endif
endif

nAte := len(aList)
for nCont := 1 to nAte
	aadd(oResponse['svOptions'],JsonObject():new())
	oResponse['svOptions'][nCont]['id']    		 := aList[nCont][1]
	oResponse['svOptions'][nCont]['object']		 := aList[nCont][2]
	oResponse['svOptions'][nCont]['title'] 		 := aList[nCont][3]
	oResponse['svOptions'][nCont]['description'] := aList[nCont][4]
	oResponse['svOptions'][nCont]['name'] 		 := aList[nCont][5]
	oResponse['svOptions'][nCont]['mode'] 		 := aList[nCont][6]
	oResponse['svOptions'][nCont]['tables'] 	 := aList[nCont][7]
	oResponse['svOptions'][nCont]['url'] 		 := aList[nCont][8]
next nCont

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TafSvPerg
Verifica se o pergunte existe para renderizar o item na api do SmartView
@author Denis Souza
@since 02/10/2023
@version 1.0
*/
//-------------------------------------------------------------------  
Function TafSvPerg(cPerg)

	Local aArea	:= GetArea()
	Local lRet	:= .F.
	Local aPergunte := {}
	Local oFWSX1 := Nil

	oFWSX1 := FWSX1Util():New()
	oFWSX1:AddGroup(cPerg)
	oFWSX1:SearchGroup()
	aPergunte := oFWSX1:GetGroup(cPerg)
	if !Empty(aPergunte) .And. Len(oFWSX1:aGrupo) >= 1 .And. Len(oFWSX1:aGrupo[1][2]) >= 1
		lRet := .T.
	endif
	FreeObj(oFWSX1)

	RestArea(aArea)

Return lRet
