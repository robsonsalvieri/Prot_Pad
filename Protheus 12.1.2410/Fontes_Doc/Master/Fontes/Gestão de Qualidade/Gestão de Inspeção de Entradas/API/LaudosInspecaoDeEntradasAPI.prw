#Include "laudosinspecaodeentradasapi.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} incominginspectiontestreports
API Laudos Ensaios Inspeção de Entradas
@author brunno.costa
@since  22/09/2022
/*/
WSRESTFUL incominginspectiontestreports DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Laudos Inspeções de Entradas"

    WSDATA HasMeasurement       as LOGICAL OPTIONAL
    WSDATA Laboratories         as STRING OPTIONAL
    WSDATA Laboratory           as STRING OPTIONAL
    WSDATA Login                as STRING OPTIONAL
    WSDATA ProductID            as STRING OPTIONAL
	WSDATA RecnoQEK             as INTEGER OPTIONAL
    WSDATA ReportLevel          as STRING OPTIONAL
    WSDATA ReportLevelPage      as STRING OPTIONAL
    WSDATA ReportSelected       as STRING OPTIONAL
    WSDATA ShelfLife            as DATE OPTIONAL
    WSDATA SpecificationVersion as STRING OPTIONAL

    WSMETHOD GET standardreportpage;
    DESCRIPTION STR0002; //"Identifica Página de Laudo Padrão Relacionada"
    WSSYNTAX "api/qie/v1/standardreportpage/{Login}/{RecnoQEK}" ;
    PATH "/api/qie/v1/standardreportpage" ;
    TTALK "v1"

	WSMETHOD GET canusergeneratereport;
    DESCRIPTION STR0003; //"Identifica se o usuário pode gerar laudo"
    WSSYNTAX "api/qie/v1/canusergeneratereport/{Login}/{ReportLevel}" ;
    PATH "/api/qie/v1/canusergeneratereport" ;
    TTALK "v1"

    WSMETHOD GET canview;
    DESCRIPTION STR0019; //"Identifica se o usuário pode consultar laudo"
    WSSYNTAX "api/qie/v1/canview/{Login}/{ReportLevel}" ;
    PATH "/api/qie/v1/canview" ;
    TTALK "v1"

    WSMETHOD GET suggestsopinionreport;
    DESCRIPTION STR0004; //"Sugere Parecer Laudo"
    WSSYNTAX "api/qie/v1/suggestsopinionreport/{Login}/{RecnoQEK}/{ReportLevel}/{Laboratories}" ;
    PATH "/api/qie/v1/suggestsopinionreport" ;
    TTALK "v1"

    WSMETHOD GET opinionlist;
    DESCRIPTION STR0020; //"Lista Laudos SIGAQIE"
    WSSYNTAX "api/qie/v1/opinionlist" ;
    PATH "/api/qie/v1/opinionlist" ;
    TTALK "v1"

    WSMETHOD GET shelflifereport;
    DESCRIPTION STR0005; //"Identifica a data de laudo para sugestão"
    WSSYNTAX "api/qie/v1/shelflifereport/{ProductID}/{SpecificationVersion}" ;
    PATH "/api/qie/v1/shelflifereport" ;
    TTALK "v1"

    WSMETHOD GET reportDateValid;
    DESCRIPTION STR0006; //"Valida a data de validade do laudo digitado"
    WSSYNTAX "api/qie/v1/reportDateValid/{ShelfLife}/{ReportSelected}" ;
    PATH "/api/qie/v1/reportDateValid" ;
    TTALK "v1"

    WSMETHOD POST savegeneralreport;
	DESCRIPTION STR0007; //"Salva Laudo Geral"
	WSSYNTAX "api/qie/v1/savegeneralreport" ;
	PATH "/api/qie/v1/savegeneralreport" ;
	TTALK "v1"

    WSMETHOD POST savelaboratoryreport;
	DESCRIPTION STR0008; //"Salva Laudo de Laboratório"
	WSSYNTAX "api/qie/v1/savelaboratoryreport" ;
	PATH "/api/qie/v1/savelaboratoryreport" ;
	TTALK "v1"

    WSMETHOD GET generalreport;
    DESCRIPTION STR0009; //"Retorna Laudo Geral"
    WSSYNTAX "api/qie/v1/generalreport/{RecnoQEK}" ;
    PATH "/api/qie/v1/generalreport" ;
    TTALK "v1"

    WSMETHOD GET laboratoryreport;
    DESCRIPTION STR0010; //"Retorna Laudo do Laboratório"
    WSSYNTAX "api/qie/v1/laboratoryreport/{RecnoQEK}/{Laboratory}" ;
    PATH "/api/qie/v1/laboratoryreport" ;
    TTALK "v1"

    WSMETHOD GET reopeninspection;
    DESCRIPTION STR0011; //"Reabre a inspeção"
    WSSYNTAX "api/qie/v1/reopeninspection/{Login}/{RecnoQEK}/{HasMeasurement}" ;
    PATH "/api/qie/v1/reopeninspection" ;
    TTALK "v1"

    WSMETHOD GET caneditreport;
    DESCRIPTION STR0012; //"Avalia se o Laudo Pode Ser Editado"
    WSSYNTAX "api/qie/v1/caneditreport/{RecnoQEK}/{Laboratory}/{ReportLevelPage}" ;
    PATH "/api/qie/v1/caneditreport" ;
    TTALK "v1"

    WSMETHOD GET hasallaccessininspection;
    DESCRIPTION STR0013; //"Avalia se o Usuário possui acesso a toda a inspeção"
    WSSYNTAX "api/qie/v1/hasallaccessininspection/{Login}/{RecnoQEK}" ;
    PATH "/api/qie/v1/hasallaccessininspection" ;
    TTALK "v1"

    WSMETHOD GET dellabrep;
    DESCRIPTION STR0014; //"Exclui Laudo do Laboratório"
    WSSYNTAX "api/qie/v1/dellabrep/{Login}/{RecnoQEK}/{Laboratory}/{HasMeasurement}" ;
    PATH "/api/qie/v1/dellabrep" ;
    TTALK "v1"

    WSMETHOD GET delgenrep;
    DESCRIPTION STR0015; //"Exclui Laudo Geral"
    WSSYNTAX "api/qie/v1/delgenrep/{Login}/{RecnoQEK}/{HasMeasurement}" ;
    PATH "/api/qie/v1/delgenrep" ;
    TTALK "v1"

    WSMETHOD GET alllaboratorieshavereports;
    DESCRIPTION STR0016;  //"Todos os Laboratórios Possuem Laudos"
    WSSYNTAX "api/qie/v1/alllaboratorieshavereports/{Login}/{RecnoQEK}" ;
    PATH "/api/qie/v1/alllaboratorieshavereports" ;
    TTALK "v1"
    
    WSMETHOD get failintegrationmessages;
	DESCRIPTION STR0017; //"Retorna mensagens de erro em caso de integraçao com outros módulos"
	WSSYNTAX "api/qie/v1/failintegrationmessages" ;
	PATH "/api/qie/v1/failintegrationmessages" ;
	TTALK "v1"

    WSMETHOD GET integrationStock;
    DESCRIPTION STR0018; //"Identifica se tem integração com o estoque habilitado"
    WSSYNTAX "api/qie/v1/integrationStock/" ;
    PATH "/api/qie/v1/integrationStock" ;
    TTALK "v1"
    
ENDWSRESTFUL

WSMETHOD GET standardreportpage PATHPARAM Login, RecnoQEK WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := Nil
    Local cError            := Nil

	oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
	cPagina           := oQIELaudosEnsaios:DirecionaParaTelaDeLaudoPorInspecaoEUsuario(Self:RecnoQEK, Self:Login, @cError)
    
    If Empty(cPagina) .OR. cPagina == "X"
        oQIELaudosEnsaios:oAPIManager:lWarningError := .T.
	    oQIELaudosEnsaios:oAPIManager:RespondeValor("reportLevelPage", cPagina, cError)
    Else
        oQIELaudosEnsaios:oAPIManager:RespondeValor("reportLevelPage", cPagina)
    EndIf

Return 

WSMETHOD GET hasallaccessininspection PATHPARAM Login, RecnoQEK WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := Nil
    Local lSucesso          := Nil

	oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
	lSucesso          := oQIELaudosEnsaios:AvaliaAcessoATodaInspecao(Self:RecnoQEK, Self:Login)
    oQIELaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET canusergeneratereport PATHPARAM Login, ReportLevel WSSERVICE incominginspectiontestreports
	
	Local cError            := Nil
    Local oQIELaudosEnsaios := Nil

	oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
	If oQIELaudosEnsaios:UsuarioPodeGerarLaudo(Self:Login, Self:ReportLevel, @cError)
		oQIELaudosEnsaios:oAPIManager:RespondeValor("success", .T., "")
    Else
        oQIELaudosEnsaios:oAPIManager:lWarningError := .T.
		oQIELaudosEnsaios:oAPIManager:RespondeValor("success", .F., cError)
	EndIf

Return 

WSMETHOD GET canview PATHPARAM Login, ReportLevel WSSERVICE incominginspectiontestreports
	
	Local cError            := Nil
    Local oQIELaudosEnsaios := Nil

	oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
	If oQIELaudosEnsaios:UsuarioPodeConsultarLaudo(Self:Login, Self:ReportLevel, @cError)
		oQIELaudosEnsaios:oAPIManager:RespondeValor("success", .T., "")
    Else
        oQIELaudosEnsaios:oAPIManager:lWarningError := .T.
		oQIELaudosEnsaios:oAPIManager:RespondeValor("success", .F., cError)
	EndIf

Return 

WSMETHOD GET suggestsopinionreport PATHPARAM Login, RecnoQEK, ReportLevel, Laboratories WSSERVICE incominginspectiontestreports
	
	Local cError            := Nil
    Local cParecer          := ""
    Local oQIELaudosEnsaios := Nil
    Local aLaboratorios     := StrToKArr(Self:Laboratories, ",")

	oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    cParecer := oQIELaudosEnsaios:SugereParecerLaudo(Self:ReportLevel, Self:RecnoQEK, aLaboratorios, Self:Login, @cError)
    If Empty(cError)
		oQIELaudosEnsaios:oAPIManager:RespondeValor("suggestionOpinion", cParecer, "")
	Else
		oQIELaudosEnsaios:oAPIManager:RespondeValor("suggestionOpinion", "", cError)
	EndIf

Return 

WSMETHOD GET opinionlist PATHPARAM WSSERVICE incominginspectiontestreports
	
	Local aDados      := {}
	Local bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})
    Local cAlias      := Nil
    Local cQuery      := ""
	Local oAPIManager := QualityAPIManager():New(, Self,)
	Local oItemAPI    := Nil
	
	If oAPIManager:ValidaPrepareInDoAmbiente()

        Begin Sequence

            cQuery +=  " SELECT DISTINCT QED_CODFAT, QED_DESCPO, QED_CATEG "
            cQuery +=  " FROM  " + RetSqlName("QED")
            cQuery +=  " WHERE (D_E_L_E_T_ = ' ') "
            cQuery +=    " AND (QED_FILIAL = '" + xFilial("QED") +"') "
            cQuery +=  " ORDER BY QED_CATEG, QED_DESCPO "

            cQuery := oAPIManager:ChangeQueryAllDB(cQuery)
            cAlias := oAPIManager:oQueryManager:executeQuery(cQuery)

            While !(cAlias)->(Eof())
                
                oItemAPI                := JsonObject():New()
				oItemAPI["opinionCode"] := (cAlias)->QED_CODFAT
				oItemAPI["opinion"    ] := Capital(Acentuacao(Upper((cAlias)->QED_DESCPO)))
                oItemAPI["category"   ] := (cAlias)->QED_CATEG
				aAdd(aDados, oItemAPI)

                (cAlias)->(DbSkip())
            EndDo

        End Sequence	
        ErrorBlock(bErrorBlock)
		
	EndIf
	oAPIManager:RespondeArray(aDados, .F.)

Return 

WSMETHOD GET shelflifereport PATHPARAM ProductID, SpecificationVersion WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    Local cReturn           := ""

	cReturn := oQIELaudosEnsaios:BuscaDataDeValidadeDoLaudo(Self:ProductID, Self:SpecificationVersion)
    oQIELaudosEnsaios:oAPIManager:RespondeValor("date", cReturn)

Return 

WSMETHOD GET reportDateValid PATHPARAM ShelfLife, ReportSelected WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    Local lReturn           := .T.
    Local cError            := ""

	lReturn := oQIELaudosEnsaios:ValidaDataDeValidadeDoLaudo(Self:ShelfLife, Self:ReportSelected, @cError )
    oQIELaudosEnsaios:oAPIManager:RespondeValor("ValidDate", lReturn, cError)

Return 

WSMETHOD POST savegeneralreport QUERYPARAM Fields WSSERVICE incominginspectiontestreports
    
    Local cError     := ""
    Local cJsonData  := DecodeUTF8(Self:GetContent())
    Local oAPIClass  := QIELaudosEnsaios():New(Self)
    Local oDadosJson := JsonObject()      :New()
    Local lSucesso   := .T.

    cError   := oDadosJson:fromJson(cJsonData)
    lSucesso := Empty(cError)
    If lSucesso
        lSucesso := oAPIClass:GravaLaudoGeral(oDadosJson["Login"]            ,;
                                              oDadosJson["RecnoInspection"]  ,;
                                              oDadosJson["ReportSelected"]   ,;
                                              oDadosJson["Justification"]    ,;
                                              oDadosJson["RejectedQuantity"] ,;
                                              oDadosJson["ShelfLife"]        ,;
                                              oDadosJson["ReleaseStock"]     )
    EndIf
    cError := Iif(Empty(cError), oAPIClass:oAPIManager:cErrorMessage, cError)

    If lSucesso .And. !Empty(cError)
        oAPIClass:oApiManager:cSuccessMessage := STR0021 //"Laudo incluído com sucesso."
    EndIf

    oAPIClass:oAPIManager:RespondeValor("success", lSucesso, cError)
    oAPIClass:oApiManager:cSuccessMessage := ""

Return 

WSMETHOD POST savelaboratoryreport QUERYPARAM Fields WSSERVICE incominginspectiontestreports
    
    Local cError     := ""
    Local cJsonData  := DecodeUTF8(Self:GetContent())
    Local oAPIClass  := QIELaudosEnsaios():New(Self)
    Local oDadosJson := JsonObject()      :New()
    Local lSucesso   := .T.

    cError   := oDadosJson:fromJson(cJsonData)
    lSucesso := Empty(cError)
    If lSucesso
        lSucesso := oAPIClass:GravaLaudoLaboratorio(oDadosJson["Login"]            ,;
                                                    oDadosJson["RecnoInspection"]  ,;
                                                    oDadosJson["Laboratory"]       ,;
                                                    oDadosJson["ReportSelected"]   ,;
                                                    oDadosJson["Justification"]    ,;
                                                    oDadosJson["RejectedQuantity"] ,;
                                                    oDadosJson["ShelfLife"])

    EndIf
    cError := Iif(Empty(cError), oAPIClass:oAPIManager:cErrorMessage, cError)
    oAPIClass:oAPIManager:RespondeValor("success", lSucesso, cError)

Return 

WSMETHOD GET generalreport PATHPARAM RecnoQEK WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    Local oDados            := Nil

	oDados := oQIELaudosEnsaios:RetornaLaudoGeral(Self:RecnoQEK)
    oDados['shelfLife'] := oQIELaudosEnsaios:oAPIManager:FormataDado("D", oDados['shelfLife'], "2", 10)
    oQIELaudosEnsaios:oAPIManager:RespondeJson(oDados)

Return 

WSMETHOD GET laboratoryreport PATHPARAM RecnoQEK, Laboratory WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    Local oDados            := Nil

	oDados := oQIELaudosEnsaios:RetornaLaudoLaboratorio(Self:RecnoQEK, Self:Laboratory)
    oDados['shelfLife'] := oQIELaudosEnsaios:oAPIManager:FormataDado("D", oDados['shelfLife'], "2", 10)
    oQIELaudosEnsaios:oAPIManager:RespondeJson(oDados)

Return 

WSMETHOD GET reopeninspection PATHPARAM Login, RecnoQEK, HasMeasurement WSSERVICE incominginspectiontestreports
	
    Local lSucesso          := .F.
    Local nOpc              := -1
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)

    Self:HasMeasurement := Iif(ValType(Self:HasMeasurement) == "C", Self:HasMeasurement == "true", Self:HasMeasurement)
    lSucesso := oQIELaudosEnsaios:ReabreInspecaoEEstornaMovimentosCQ(Self:Login, Self:RecnoQEK, Self:HasMeasurement, nOpc)
    oQIELaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET caneditreport PATHPARAM RecnoQEK, Laboratory, ReportLevelPage WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    Local lSucesso          := .F.

	lSucesso := oQIELaudosEnsaios:LaudoPodeSerEditado(Self:RecnoQEK, Self:Laboratory, Self:ReportLevelPage)
    oQIELaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET dellabrep PATHPARAM Login, RecnoQEK, Laboratory, HasMeasurement WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    Local lSucesso          := .F.

    Self:HasMeasurement := Iif(ValType(Self:HasMeasurement) == "C", Self:HasMeasurement == "true", Self:HasMeasurement)
	lSucesso := oQIELaudosEnsaios:ExcluiLaudoLaboratorio(Self:Login, Self:RecnoQEK, Self:Laboratory, Self:HasMeasurement)
    oQIELaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET delgenrep PATHPARAM Login, RecnoQEK, HasMeasurement WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    Local lSucesso          := .F.

    Self:HasMeasurement := Iif(ValType(Self:HasMeasurement) == "C", Self:HasMeasurement == "true", Self:HasMeasurement)
	lSucesso := oQIELaudosEnsaios:ExcluiLaudoGeralEEstornaMovimentosCQ(Self:Login, Self:RecnoQEK, Self:HasMeasurement)
    oQIELaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET alllaboratorieshavereports PATHPARAM Login, RecnoQEK WSSERVICE incominginspectiontestreports
	
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    Local lTodosLaudos      := .F.

	lTodosLaudos := oQIELaudosEnsaios:ChecaTodosOsLaboratoriosComLaudos(Self:Login, Self:RecnoQEK)
    oQIELaudosEnsaios:oAPIManager:RespondeValor("success", lTodosLaudos)

Return 

WSMETHOD GET failintegrationmessages WSSERVICE incominginspectiontestreports

    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)
    Local aMensagens        := oQIELaudosEnsaios:RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos()

    oQIELaudosEnsaios:oAPIManager:RespondeValor("integrationMessage", aMensagens)

Return

WSMETHOD GET integrationStock WSSERVICE incominginspectiontestreports
	
    Local lReturn           := .F.
    Local oQIEA215Estoque   := QIEA215Estoque()  :New(-1)
    Local oQIELaudosEnsaios := QIELaudosEnsaios():New(Self)

    lReturn                 := oQIEA215Estoque:lIntegracaoEstoqueHabilitada
    oQIELaudosEnsaios:oAPIManager:RespondeValor("integrationEnabled", lReturn)

Return 

/*/{Protheus.doc} Acentuacao
Capitaliza e Acentua Dicionário Padrão
@author brunno.costa
@since  10/02/2025
@param 01 - cTitulo, caracter, faz a correção de acentuação do dicionário padrão
@return cReturn, caracter, retorna o título com a correção de acentuação
/*/
Static Function Acentuacao(cTitulo)
	Local cReturn := Capital(StrTran(Upper(cTitulo), "RESTRICOES", "Restrições")) //"Restrições"
Return cReturn
