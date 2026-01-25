#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FichasNaoConformidadesAPI.CH"

/*/{Protheus.doc} nonconformancerecords
API de Fichas Não Conformidades - Qualidade
@author brunno.costa
@since  03/04/2024
/*/
WSRESTFUL nonconformancerecords DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Fichas de Não Conformidades"

	WSDATA OperationID          as STRING OPTIONAL
	WSDATA OperationRoutinesID  as STRING OPTIONAL
	WSDATA ProductID            as STRING OPTIONAL
	WSDATA RecnoQER             as INTEGER OPTIONAL
	WSDATA RecnoQPR             as INTEGER OPTIONAL
	WSDATA SpecificationVersion as STRING OPTIONAL
	WSDATA TestID               as STRING OPTIONAL

	WSMETHOD GET processinspectionintegrationstatus;
    DESCRIPTION STR0002; //"Retorna o Status da Integração com Inspeção de Processos"
    WSSYNTAX "api/qnc/v1/processinspectionintegrationstatus" ;
    PATH "/api/qnc/v1/processinspectionintegrationstatus" ;
    TTALK "v1"

	
	WSMETHOD GET incominginspectionintegrationstatus;
    DESCRIPTION STR0015; //"Retorna o Status da Integração com Inspeção de Entradas"
    WSSYNTAX "api/qnc/v1/incominginspectionintegrationstatus" ;
    PATH "/api/qnc/v1/incominginspectionintegrationstatus" ;
    TTALK "v1"

	WSMETHOD GET qiptypesofnonconformances;
    DESCRIPTION STR0003; //"Retorna lista de tipos de Não Conformidades do QIP"
    WSSYNTAX "/api/qnc/v1/qiptypesofnonconformances/{ProductID}/{SpecificationVersion}/{OperationID}/{OperationRoutinesID}/{TestID}" ;
    PATH "/api/qnc/v1/qiptypesofnonconformances" ;
    TTALK "v1"

	WSMETHOD GET qietypesofnonconformances;
    DESCRIPTION STR0016; //"Retorna lista de tipos de Não Conformidades do QIE"
    WSSYNTAX "/api/qnc/v1/qietypesofnonconformances/{ProductID}/{SpecificationVersion}/{TestID}" ;
    PATH "/api/qnc/v1/qietypesofnonconformances" ;
    TTALK "v1"

	WSMETHOD GET qipinspectionrelatednonconformance;
    DESCRIPTION STR0004; //"Retorna lista de Não Conformidades relacionadas à Inspeção de Processo"
    WSSYNTAX "/api/qnc/v1/qipinspectionrelatednonconformance/{RecnoQPR}" ;
    PATH "/api/qnc/v1/qipinspectionrelatednonconformance" ;
    TTALK "v1"

	WSMETHOD GET qieinspectionrelatednonconformance;
    DESCRIPTION STR0017; //"Retorna lista de Não Conformidades relacionadas à Inspeção de Entrada"
    WSSYNTAX "/api/qnc/v1/qieinspectionrelatednonconformance/{RecnoQER}" ;
    PATH "/api/qnc/v1/qieinspectionrelatednonconformance" ;
    TTALK "v1"

	WSMETHOD GET qpuextrafields;
    DESCRIPTION STR0018; //"Campos Extras QPU para APP Minha Produção"
    WSSYNTAX "/api/qnc/v1/qpuextrafields" ;
    PATH "/api/qnc/v1/qpuextrafields" ;
    TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET processinspectionintegrationstatus WSSERVICE nonconformancerecords

	Local bErrorBlock := Nil
	Local cResp       := ""
	Local lReturnPE   := Nil
	Local lUsaPE      := ExistBlock("QIPINTAPI")
	Local oAPIClass   := FichasNaoConformidadesAPI():New(Self)
	Local oError      := Nil
	Local oResponse   := JsonObject():New()

	Self:SetContentType("application/json")
	HTTPSetStatus(200)
	oResponse['code'  ] := 200
	oResponse['result'] := oAPIClass:validaIntegracaoQIPHabilitada()

	If lUsaPE
		bErrorBlock := ErrorBlock({|e| oError := e, .T. })
		Begin Sequence
			lReturnPE   := Execblock('QIPINTAPI',.F.,.F.,{oResponse, "nonconformancerecords/api/qip/v1/processinspectionintegrationstatus", "FichasNaoConformidadesAPI", "qpuInclusaoSemQIPQNC"})
			If Valtype(lReturnPE) == 'L'
				oResponse['result'] := lReturnPE
			EndIf
		Recover
		End Sequence
		ErrorBlock(bErrorBlock)
	EndIf	

	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:SetResponse( cResp )

	If oError != Nil
		LogMsg('QIPINTAPI', 0, 0, 1, '', '', "QIPINTAPI Fail - " + oError:Description + CHR(10) + oError:ErrorStack + CHR(10) + oError:ErrorEnv)
	EndIf

Return 

WSMETHOD GET incominginspectionintegrationstatus WSSERVICE nonconformancerecords

	Local cResp     := ""
    Local oAPIClass := FichasNaoConformidadesAPI():New(Self)
	Local oResponse := JsonObject()               :New()

	Self:SetContentType("application/json")
	HTTPSetStatus(200)
	oResponse['code'  ] := 200
	oResponse['result'] := oAPIClass:validaIntegracaoQIEHabilitada()
	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:SetResponse( cResp )

Return 

WSMETHOD GET qpuextrafields PATHPARAM WSSERVICE nonconformancerecords

	Local cEndPoint := "nonconformancerecords/api/qip/v1/qpuextrafields"
	Local cResp     := ""
	Local oAPIClass := FichasNaoConformidadesAPI():New(Self)
	Local oResponse := JsonObject()               :New()

	Self:SetContentType("application/json")
	HTTPSetStatus(200)

	oResponse['code'  ] := 200
	oResponse['result'] := oAPIClass:retornaCamposExtrasPEQPU(cEndPoint)

	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:SetResponse( cResp )

Return 

WSMETHOD GET qiptypesofnonconformances PATHPARAM OperationID, OperationRoutinesID, ProductID, SpecificationVersion, TestID  WSSERVICE nonconformancerecords

	Local cResp     := ""
    Local oAPIClass := FichasNaoConformidadesAPI():New(Self)
	Local oResponse := JsonObject()               :New()

	Default Self:OperationID          := ""
	Default Self:OperationRoutinesID  := ""
	Default Self:ProductID            := ""
	Default Self:SpecificationVersion := ""
	Default Self:TestID               := ""

	Self:SetContentType("application/json")
	HTTPSetStatus(200)
	oResponse['code'  ] := 200
	oResponse['result'] := oAPIClass:retornaTiposNCsQIP(Self:ProductID, Self:SpecificationVersion, Self:OperationID, Self:OperationRoutinesID, Self:TestID)
	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:SetResponse( cResp )

Return 

WSMETHOD GET qietypesofnonconformances PATHPARAM ProductID, SpecificationVersion, TestID  WSSERVICE nonconformancerecords

	Local cResp     := ""
    Local oAPIClass := FichasNaoConformidadesAPI():New(Self)
	Local oResponse := JsonObject()               :New()

	Default Self:OperationID          := ""
	Default Self:OperationRoutinesID  := ""
	Default Self:ProductID            := ""
	Default Self:SpecificationVersion := ""
	Default Self:TestID               := ""

	Self:SetContentType("application/json")
	HTTPSetStatus(200)
	oResponse['code'  ] := 200
	oResponse['result'] := oAPIClass:retornaTiposNCsQIE(Self:ProductID, Self:SpecificationVersion, Self:TestID)
	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:SetResponse( cResp )

Return 

WSMETHOD GET qipinspectionrelatednonconformance PATHPARAM RecnoQPR WSSERVICE nonconformancerecords

	Local cResp     := ""
	Local oAPIClass := FichasNaoConformidadesAPI():New(Self)
	Local oResponse := JsonObject()               :New()

	Default Self:RecnoQPR := 0

	Self:SetContentType("application/json")
	HTTPSetStatus(200)
	oResponse['code'  ] := 200
	oResponse['result'] := oAPIClass:retornaNCsDaInspecaoDeProcesso(Self:RecnoQPR)
	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:SetResponse( cResp )

Return 

WSMETHOD GET qieinspectionrelatednonconformance PATHPARAM RecnoQER WSSERVICE nonconformancerecords

	Local cResp     := ""
	Local oAPIClass := FichasNaoConformidadesAPI():New(Self)
	Local oResponse := JsonObject()               :New()

	Default Self:RecnoQER := 0

	Self:SetContentType("application/json")
	HTTPSetStatus(200)
	oResponse['code'  ] := 200
	oResponse['result'] := oAPIClass:retornaNCsDaInspecaoDeEntrada(Self:RecnoQER)
	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:SetResponse( cResp )

Return 

/*/{Protheus.doc} FichasNaoConformidadesAPI
Regras de Negocio - API de Fichas Não Conformidades
@author brunno.costa
@since  03/04/2024
/*/
CLASS FichasNaoConformidadesAPI FROM LongNameClass
    
	data cDetailedMessage as string
	data cErrorMessage    as string
	data oAPIManager      as object
	data oQueryManager    as object
	data oWSRestFul       as object
	data aCamposPEQPU     as Array

    public method new(oWSRestFul) CONSTRUCTOR
	
	private METHOD incluiRelacionamentoNCQIE(nRecnoQER, oItemNC)                                   as logical
	private method incluiRelacionamentoNCQIP(nRecnoQPR, oItemNC)                                   as logical
	private method retornaTiposNCsQE2(cEnsaio)                                                     as array
	private method retornaTiposNCsQE9(cProduto, cRevisao, cEnsaio)                                 as array
	private method retornaTiposNCsQP2(cEnsaio)                                                     as array
	private method retornaTiposNCsQP9(cProduto, cRevisao, cOperacao, cRoteiro, cEnsaio)            as array
	private method retornaTiposNCsSAG()                                                            as array
	private method retornaValorMedicao(cMedicao, cTipoCarta, nMedicoes)                            as string

	public method excluiRelacionamentoNCQIE(nRecnoQER, oItemNC, cErrorMessage, lVerificaStatusFNC) as logical
	public method excluiRelacionamentoNCQIP(nRecnoQPR, oItemNC, cErrorMessage, lVerificaStatusFNC) as logical
	public METHOD processaRelacionamentoNCQIE(nRecnoQER, aListaNC, cErrorMessage)                  as logical
	public method processaRelacionamentoNCQIP(nRecnoQPR, aListaNC, cErrorMessage)                  as logical
	public method retornaCamposExtrasPEQPU(cEndPoint)                                              as array
	public method retornaNCsDaInspecaoDeEntrada(nRecnoQER)                                         as array
	public method retornaNCsDaInspecaoDeProcesso(nRecnoQPR)                                        as array
	public method retornaTiposNCsQIE(cProduto, cRevisao, cEnsaio)                                  as array
	public method retornaTiposNCsQIP(cProduto, cRevisao, cOperacao, cRoteiro, cEnsaio)             as array
	public method validaIntegracaoQIEHabilitada()                                                  as logical
	public method validaIntegracaoQIPHabilitada()                                                  as logical
	
ENDCLASS

METHOD new(oWSRestFul) CLASS FichasNaoConformidadesAPI
	Self:oWSRestFul    := oWSRestFul
	Self:oAPIManager   := QualityAPIManager():New(Nil, oWSRestFul, Nil)
	Self:oQueryManager := QLTQueryManager()  :New()

	Self:cErrorMessage               := ""
	Self:cDetailedMessage            := ""
Return Self

/*/{Protheus.doc} validaIntegracaoQIEHabilitada
Indica se a integração com o Módulo QIE está implantado
@author brunno.costa
@since  03/04/2024
@return lIntegrado, lógico, indica se a integração com o Módulo QIE está implantado
/*/
METHOD validaIntegracaoQIEHabilitada() CLASS FichasNaoConformidadesAPI
	Local lIntegrado := (AlLTrim(SuperGetMV("MV_QINTQNC", .F., "N")) == "S")
Return lIntegrado

/*/{Protheus.doc} validaIntegracaoQIPHabilitada
Indica se a integração com o Módulo QIP está implantado
@author brunno.costa
@since  03/04/2024
@return lIntegrado, lógico, indica se a integração com o Módulo QIP está implantado
/*/
METHOD validaIntegracaoQIPHabilitada() CLASS FichasNaoConformidadesAPI
	Local lIntegrado := (AlLTrim(SuperGetMV("MV_QIPQNC", .F., "2")) == "1")
Return lIntegrado

/*/{Protheus.doc} retornaCamposExtrasPEQPU
Retorna lista dos campos extras do QPU válidos para inclusão
@author brunno.costa
@since  03/04/2024
@return aCampos, array, lista dos campos extras do QPU válidos para inclusão
	{
		JsonObject -> {codigo, default, placeHolder, titulo, tamanho, tabelasx5}, ...
	}

/*/
METHOD retornaCamposExtrasPEQPU(cEndPoint) CLASS FichasNaoConformidadesAPI
	
	Local aCampos     := {}
	Local aReturnPE   := Nil
	Local bErrorBlock := Nil
	Local lExistX3    := .F.
	Local lUsaPE      := ExistBlock("QIPINTAPI")
	Local nIndice     := 0
	Local oError      := Nil

	Default cEndPoint := "nonconformancerecords/api/qip/v1/qpuextrafields"
	
	If lUsaPE

		bErrorBlock := ErrorBlock({|e| oError := e, .T. })

		Begin Sequence
			
			aReturnPE   := Execblock('QIPINTAPI',.F.,.F.,{Nil, cEndPoint, "FichasNaoConformidadesAPI", "qpuCamposAdicionais"})

			If Valtype(aReturnPE) == 'A'

				For nIndice := 1 to Len(aReturnPE)

					If Valtype(aReturnPE[nIndice]) == 'J'

						aReturnPE[nIndice]['codigo'] := Upper(AllTrim(aReturnPE[nIndice]['codigo']))

						If !Empty(aReturnPE[nIndice]['codigo'])

							lExistX3 := !Empty(GetSx3Cache(aReturnPE[nIndice]['codigo'], "X3_TAMANHO"))
							
							If lExistX3

								If GetSx3Cache(aReturnPE[nIndice]['codigo'], "X3_TIPO") != "C"
									//STR0019 - "Campo"
									//STR0021 - "ignorado, somente permitido uso de campo do dicionario do tipo caracter."
									LogMsg('QIPINTAPI', 0, 0, 1, '', '', "QIPINTAPI Fail - " + STR0019 + " '" + aReturnPE[nIndice]['codigo'] + "' " + STR0021)
									Loop

								EndIf

								aReturnPE[nIndice]['tamanho']     := GetSx3Cache(aReturnPE[nIndice]['codigo'], "X3_TAMANHO")
								aReturnPE[nIndice]['tituloSX3']   := GetSx3Cache(aReturnPE[nIndice]['codigo'], "X3_TITULO")
								aReturnPE[nIndice]['obrigatorio'] := X3Obrigat(aReturnPE[nIndice]['codigo'])

							Else
								aReturnPE[nIndice]['tamanho']     := Iif(aReturnPE[nIndice]['tamanho']     == Nil, 250                                 , aReturnPE[nIndice]['tamanho'])
								aReturnPE[nIndice]['tituloSX3']   := Iif(aReturnPE[nIndice]['tituloSX3']   == Nil, aReturnPE[nIndice]['tituloConsulta'], aReturnPE[nIndice]['tituloSX3'])
								aReturnPE[nIndice]['obrigatorio'] := Iif(aReturnPE[nIndice]['obrigatorio'] == Nil, .F.                                 , aReturnPE[nIndice]['obrigatorio'])

							EndIf

							aReturnPE[nIndice]['permiteInclusao'] := Iif(aReturnPE[nIndice]['permiteInclusao'] == Nil, .F., aReturnPE[nIndice]['permiteInclusao'])
							aReturnPE[nIndice]['permiteEdicao']   := Iif(aReturnPE[nIndice]['permiteEdicao']   == Nil, .F., aReturnPE[nIndice]['permiteEdicao'])
							aReturnPE[nIndice]['grid']            := Iif(aReturnPE[nIndice]['grid']            == Nil, .F., aReturnPE[nIndice]['grid'])
							aReturnPE[nIndice]['tituloConsulta']  := Iif(aReturnPE[nIndice]['tituloConsulta']  == Nil, aReturnPE[nIndice]['tituloSX3'], aReturnPE[nIndice]['tituloConsulta'])

							If aReturnPE[nIndice]['permiteInclusao'] .And. Empty(aReturnPE[nIndice]['tituloInclusao']) .And. Empty(aReturnPE[nIndice]['placeHolder'])
								
								//STR0019 - "Campo"
								//STR0020 - "ignorado - Requer uso de 'tituloInclusao' ou 'placeHolder' preenchidos - Evento 'qpuCamposAdicionais'."
								LogMsg('QIPINTAPI', 0, 0, 1, '', '', "QIPINTAPI Fail - " + STR0019 + " '" + aReturnPE[nIndice]['codigo'] + "' " + STR0020)

							ElseIf Empty(aReturnPE[nIndice]['tituloConsulta'])

								//STR0019 - "Campo"
								//STR0022 - "ignorado - Requer uso de 'tituloConsulta' preenchido - Evento 'qpuCamposAdicionais'."
								LogMsg('QIPINTAPI', 0, 0, 1, '', '', "QIPINTAPI Fail - " + STR0019 + " '" + aReturnPE[nIndice]['codigo'] + "' " + STR0022)

							ElseIf Empty(aReturnPE[nIndice]['conteudoConsulta'])

								//STR0019 - "Campo"
								//STR0023 - "ignorado - Requer uso de 'conteudoConsulta' preenchido - Evento 'qpuCamposAdicionais'."
								LogMsg('QIPINTAPI', 0, 0, 1, '', '', "QIPINTAPI Fail - " + STR0019 + " '" + aReturnPE[nIndice]['codigo'] + "' " + STR0023)

							Else

								aReturnPE[nIndice]['default']     := Iif(Empty(aReturnPE[nIndice]['default'])    , "", aReturnPE[nIndice]['default'])
								aReturnPE[nIndice]['defaultB']    := aReturnPE[nIndice]['default'] //Controle interno para recuperação de valor default
								aReturnPE[nIndice]['placeHolder'] := Iif(Empty(aReturnPE[nIndice]['placeHolder']), "", aReturnPE[nIndice]['placeHolder'])
								aReturnPE[nIndice]['titulo']      := Iif(Empty(aReturnPE[nIndice]['titulo'])     , "", aReturnPE[nIndice]['titulo'])
								aReturnPE[nIndice]['tabelaSX5']   := Iif(Empty(aReturnPE[nIndice]['tabelaSX5'])  , "", aReturnPE[nIndice]['tabelaSX5'])

								aAdd(aCampos, aReturnPE[nIndice])
							EndIf

						EndIf

					EndIf

				Next
			EndIf
		Recover
		End Sequence

		ErrorBlock(bErrorBlock)
		
	EndIf	

	If oError != Nil
		LogMsg('QIPINTAPI', 0, 0, 1, '', '', "QIPINTAPI Fail - " + oError:Description + CHR(10) + oError:ErrorStack + CHR(10) + oError:ErrorEnv)
	EndIf

Return aCampos

/*/{Protheus.doc} retornaTiposNCsQIP
Retorna lista dos tipos de NCs relacionados
@author brunno.costa
@since  08/04/2024
@param 01 - cProduto , caracter, código do Produto relacionado a amostra
@param 02 - cRevisao , caracter, código da Revisao relacionado a amostra
@param 03 - cOperacao, caracter, código da Operacao relacionado a amostra
@param 04 - cRoteiro , caracter, código do Roteiro relacionado a amostra
@param 05 - cEnsaio  , caracter, código do Ensaio relacionado a amostra
@return aLista, array, lista de tipos de NCs relacionadas: 
{
	{AG_NAOCON, AG_DESCPO, AG_CLASSE, QEE_DESCPO}, ...
}
/*/
METHOD retornaTiposNCsQIP(cProduto, cRevisao, cOperacao, cRoteiro, cEnsaio) as array CLASS FichasNaoConformidadesAPI
	
	Local aLista := {}
	Local lOkQP2 := .F.
	Local lOkQP9 := .F.

	cProduto := PADR(cProduto, GetSx3Cache("QPR_PRODUT", "X3_TAMANHO"))

	//Verifica se existe NC associada no QP9 - Não Conformidades do Produto
	DbSelectArea("QP9")
	QP9->(dbSetOrder(3))
	If QP9->(DbSeek( xFilial("QP9") + cProduto + cRevisao + cRoteiro + cOperacao + cEnsaio))
		lOkQP9 := .T.
	EndIf

	//Caso nao exista NC no QP9 verifica no QP2 - Não Conformidade do Ensaio
	If !lOkQP9
		DbSelectArea("QP2")
		QP2->(dbSetOrder(1))
		If QP2->(dbSeek( xFilial("QP2") + cEnsaio ))
			lOkQP2 := .T.
		EndIf
	EndIf

	If lOkQP9     //Não Conformidades do Produto
		aLista := self:retornaTiposNCsQP9(cProduto, cRevisao, cOperacao, cRoteiro, cEnsaio)

	Elseif lOkQP2 //Não Conformidades do Ensaio
		aLista := self:retornaTiposNCsQP2(cEnsaio)

	Else          //Não Conformidades
		aLista := self:retornaTiposNCsSAG()

	EndIf

Return aLista

/*/{Protheus.doc} retornaTiposNCsQP9
Retorna lista dos tipos de NCs relacionados à QP9 - Não Conformidades do Produto
@author brunno.costa
@since  08/04/2024
@return aLista, array, lista de tipos de NCs relacionadas: 
{
	{AG_NAOCON, AG_DESCPO, AG_CLASSE, QEE_DESCPO}, ...
}
/*/
METHOD retornaTiposNCsQP9(cProduto, cRevisao, cOperacao, cRoteiro, cEnsaio) as array CLASS FichasNaoConformidadesAPI
	
	Local aLista   := {}
	Local cFilQEE  := xFilial("QEE")
	Local cFilQP9  := xFilial("QP9")
	Local cFilSAG  := xFilial("SAG")
	Local oJsonAux := Nil

	While !QP9->(Eof()) .AND.;
		   cFilQP9         + cProduto        + cRevisao      + cRoteiro        + cOperacao       + AllTrim(cEnsaio)         == ;
		   QP9->QP9_FILIAL + QP9->QP9_PRODUT + QP9->QP9_REVI + QP9->QP9_ROTEIR + QP9->QP9_OPERAC + AllTrim(QP9->QP9_ENSAIO)

		oJsonAux               := JsonObject():new()
		oJsonAux['AG_NAOCON']  := QP9->QP9_NAOCON
		oJsonAux['AG_DESCPO']  := Posicione("SAG", 1, cFilSAG + QP9->QP9_NAOCON,"AG_DESCPO")
		oJsonAux['AG_CLASSE']  := QP9->QP9_CLASSE
		oJsonAux['QEE_DESCPO'] := Posicione("QEE", 1, cFilQEE + QP9->QP9_CLASSE,"QEE_DESCPO")

		aAdd(aLista, oJsonAux )

		QP9->(DbSkip())
	EndDo

Return aLista

/*/{Protheus.doc} retornaTiposNCsQP2
Retorna lista dos tipos de NCs relacionados à QP2 - Não Conformidades do Ensaio
@author brunno.costa
@since  08/04/2024
@return aLista, array, lista de tipos de NCs relacionadas: 
{
	{AG_NAOCON, AG_DESCPO, AG_CLASSE, QEE_DESCPO}, ...
}
/*/
METHOD retornaTiposNCsQP2(cEnsaio) as array CLASS FichasNaoConformidadesAPI
	
	Local aLista   := {}
	Local cFilQEE  := xFilial("QEE")
	Local cFilQP2  := xFilial("QP2")
	Local cFilSAG  := xFilial("SAG")
	Local oJsonAux := Nil

	While !QP2->(Eof()) .AND.;
		   cFilQP2         + AllTrim(cEnsaio)         == ;
		   QP2->QP2_FILIAL + AllTrim(QP2->QP2_ENSAIO)

		oJsonAux               := JsonObject():new()
		oJsonAux['AG_NAOCON']  := QP2->QP2_NAOCON
		oJsonAux['AG_DESCPO']  := Posicione("SAG", 1, cFilSAG + QP2->QP2_NAOCON,"AG_DESCPO")
		oJsonAux['AG_CLASSE']  := QP2->QP2_CLASSE
		oJsonAux['QEE_DESCPO'] := Posicione("QEE", 1, cFilQEE + QP2->QP2_CLASSE,"QEE_DESCPO")

		aAdd(aLista, oJsonAux )

		QP2->(DbSkip())
	EndDo

Return aLista

/*/{Protheus.doc} retornaTiposNCsSAG
Retorna lista dos tipos de NCs relacionados à SAG - Não Conformidades
@author brunno.costa
@since  08/04/2024
@return aLista, array, lista de tipos de NCs relacionadas: 
{
	{AG_NAOCON, AG_DESCPO, AG_CLASSE, QEE_DESCPO}, ...
}
/*/
METHOD retornaTiposNCsSAG() as array CLASS FichasNaoConformidadesAPI
	
	Local aLista   := {}
	Local cFilQEE  := xFilial("QEE")
	Local cFilSAG  := xFilial("SAG")
	Local oJsonAux := Nil

	DbSelectArea("SAG")
	SAG->(DbGoTop())

	While !SAG->(Eof()) .AND. cFilSAG == SAG->AG_FILIAL
		
		oJsonAux               := JsonObject():new()
		oJsonAux['AG_NAOCON']  := SAG->AG_NAOCON
		oJsonAux['AG_DESCPO']  := SAG->AG_DESCPO
		oJsonAux['AG_CLASSE']  := SAG->AG_CLASSE
		oJsonAux['QEE_DESCPO'] := Posicione("QEE", 1, cFilQEE + SAG->AG_CLASSE,"QEE_DESCPO")

		aAdd(aLista, oJsonAux )

		SAG->(DbSkip())
	EndDo

Return aLista

/*/{Protheus.doc} retornaTiposNCsQIE
Retorna lista dos tipos de NCs relacionados ao QIE
@author brunno.costa
@since  08/04/2024
@param 01 - cProduto , caracter, código do Produto relacionado a amostra
@param 02 - cRevisao , caracter, código da Revisao relacionado a amostra
@param 03 - cEnsaio  , caracter, código do Ensaio relacionado a amostra
@return aLista, array, lista de tipos de NCs relacionadas: 
{
	{AG_NAOCON, AG_DESCPO, AG_CLASSE, QEE_DESCPO}, ...
}
/*/
METHOD retornaTiposNCsQIE(cProduto, cRevisao, cEnsaio) as array CLASS FichasNaoConformidadesAPI
	
	Local aLista := {}
	Local lOkQE2 := .F.
	Local lOkQE9 := .F.

	cProduto := PADR(cProduto, GetSx3Cache("QPR_PRODUT", "X3_TAMANHO"))

	//Verifica se existe NC associada no QE9 - Não Conformidades do Produto
	DbSelectArea("QE9")
	QE9->(dbSetOrder(1))
	If QE9->(DbSeek( xFilial("QE9") + cProduto + cRevisao + cEnsaio))
		lOkQE9 := .T.
	EndIf

	//Caso nao exista NC no QE9 verifica no QE2 - Não Conformidade do Ensaio
	If !lOkQE9
		DbSelectArea("QE2")
		QE2->(dbSetOrder(1))
		If QE2->(dbSeek( xFilial("QE2") + cEnsaio ))
			lOkQE2 := .T.
		EndIf
	EndIf

	If lOkQE9     //Não Conformidades do Produto
		aLista := self:retornaTiposNCsQE9(cProduto, cRevisao, cEnsaio)

	Elseif lOkQE2 //Não Conformidades do Ensaio
		aLista := self:retornaTiposNCsQE2(cEnsaio)

	Else          //Não Conformidades
		aLista := self:retornaTiposNCsSAG()

	EndIf

Return aLista

/*/{Protheus.doc} retornaTiposNCsQE9
Retorna lista dos tipos de NCs relacionados à QE9 - Não Conformidades do Produto
@author brunno.costa
@since  08/04/2024
@param 01 - cProduto , caracter, código do Produto relacionado a amostra
@param 02 - cRevisao , caracter, código da Revisao relacionado a amostra
@param 03 - cEnsaio  , caracter, código do Ensaio relacionado a amostra
@return aLista, array, lista de tipos de NCs relacionadas: 
{
	{AG_NAOCON, AG_DESCPO, AG_CLASSE, QEE_DESCPO}, ...
}
/*/
METHOD retornaTiposNCsQE9(cProduto, cRevisao, cEnsaio) as array CLASS FichasNaoConformidadesAPI
	
	Local aLista   := {}
	Local cFilQEE  := xFilial("QEE")
	Local cFilQE9  := xFilial("QE9")
	Local cFilSAG  := xFilial("SAG")
	Local oJsonAux := Nil

	While !QE9->(Eof()) .AND.;
		   cFilQE9         + cProduto        + cRevisao      + AllTrim(cEnsaio)         == ;
		   QE9->QE9_FILIAL + QE9->QE9_PRODUT + QE9->QE9_REVI + AllTrim(QE9->QE9_ENSAIO)

		oJsonAux               := JsonObject():new()
		oJsonAux['AG_NAOCON']  := QE9->QE9_NAOCON
		oJsonAux['AG_DESCPO']  := Posicione("SAG", 1, cFilSAG + QE9->QE9_NAOCON,"AG_DESCPO")
		oJsonAux['AG_CLASSE']  := QE9->QE9_CLASSE
		oJsonAux['QEE_DESCPO'] := Posicione("QEE", 1, cFilQEE + QE9->QE9_CLASSE,"QEE_DESCPO")

		aAdd(aLista, oJsonAux )

		QE9->(DbSkip())
	EndDo

Return aLista

/*/{Protheus.doc} retornaTiposNCsQE2
Retorna lista dos tipos de NCs relacionados à QE2 - Não Conformidades do Ensaio
@author brunno.costa
@since  08/04/2024
@param 01 - cEnsaio  , caracter, código do Ensaio relacionado a amostra
@return aLista, array, lista de tipos de NCs relacionadas: 
{
	{AG_NAOCON, AG_DESCPO, AG_CLASSE, QEE_DESCPO}, ...
}
/*/
METHOD retornaTiposNCsQE2(cEnsaio) as array CLASS FichasNaoConformidadesAPI
	
	Local aLista   := {}
	Local cFilQEE  := xFilial("QEE")
	Local cFilQE2  := xFilial("QE2")
	Local cFilSAG  := xFilial("SAG")
	Local oJsonAux := Nil

	While !QE2->(Eof()) .AND.;
		   cFilQE2         + AllTrim(cEnsaio)         == ;
		   QE2->QE2_FILIAL + AllTrim(QE2->QE2_ENSAIO)

		oJsonAux               := JsonObject():new()
		oJsonAux['AG_NAOCON']  := QE2->QE2_NAOCON
		oJsonAux['AG_DESCPO']  := Posicione("SAG", 1, cFilSAG + QE2->QE2_NAOCON,"AG_DESCPO")
		oJsonAux['AG_CLASSE']  := QE2->QE2_CLASSE
		oJsonAux['QEE_DESCPO'] := Posicione("QEE", 1, cFilQEE + QE2->QE2_CLASSE,"QEE_DESCPO")

		aAdd(aLista, oJsonAux )

		QE2->(DbSkip())
	EndDo

Return aLista

/*/{Protheus.doc} retornaNCsDaInspecaoDeProcesso
Retorna relação de NCs relacionadas à inspeção de processo
@author brunno.costa
@since  08/04/2024
@param 01 - nRecnoQPR, número, recno da amostra na QPR relacionada
@return aLista, array, lista de NCs relacionadas
{
	{QPU_NAOCON, AG_DESCPO, QPU_NUMNC, QPU_CLASSE, QEE_DESCPO, QPU_CHAVE, QPU_CODNC, QPU_REVNC, DETALHES}, ...
}
/*/
METHOD retornaNCsDaInspecaoDeProcesso(nRecnoQPR) as array CLASS FichasNaoConformidadesAPI

	Local aLista      := {}
	Local bErrorBlock := Nil
	Local cCampo      := Nil
	Local cChaveQPR   := ""
	Local cConteudo   := Nil
	Local cFilQEE     := xFilial("QEE")
	Local cFilQPU     := xFilial("QPU")
	Local cFilSAG     := xFilial("SAG")
	Local nIndice     := 0
	Local oError      := Nil
	Local oJsonAux    := Nil

	Default nRecnoQPR := -1

	If nRecnoQPR > 0

		DbSelectArea("QPR")
		QPR->(DbGoTo(nRecnoQPR))
		cChaveQPR := QPR->QPR_CHAVE

		If !Empty(cChaveQPR)

			Self:aCamposPEQPU := Iif(Self:aCamposPEQPU == Nil, Self:retornaCamposExtrasPEQPU("nonconformancerecords/api/qip/v1/qipinspectionrelatednonconformance"), Self:aCamposPEQPU)
			
			DbSelectArea("QPU")
			QPU->(DbSetOrder(1))
			QPU->(DbSeek(cFilQPU + cChaveQPR))
			While !QPU->(Eof())              .AND. ;
				cFilQPU   == QPU->QPU_FILIAL .AND. ;
				cChaveQPR == QPU->QPU_CODMED
				
				oJsonAux               := JsonObject():new()
				oJsonAux['QPU_NAOCON'] := QPU->QPU_NAOCON
				oJsonAux['AG_DESCPO']  := Posicione("SAG", 1, cFilSAG + QPU->QPU_NAOCON,"AG_DESCPO")
				oJsonAux['QPU_NUMNC']  := QPU->QPU_NUMNC
				oJsonAux['QPU_CLASSE'] := QPU->QPU_CLASSE
				oJsonAux['QEE_DESCPO'] := Posicione("QEE", 1, cFilQEE + QPU->QPU_CLASSE,"QEE_DESCPO")
				oJsonAux['QPU_CHAVE']  := QPU->QPU_CHAVE
				oJsonAux['QPU_CODNC']  := QPU->QPU_CODNC
				oJsonAux['QPU_REVNC']  := QPU->QPU_REVNC
				oJsonAux['DETALHES']   := QP215FilTxt(QPU->QPU_CHAVE)

				//Tratamento Campos Customizados PE QIPIntAPI - Evento 'qpuCamposAdicionais'

				If Len(Self:aCamposPEQPU) > 0
					bErrorBlock := ErrorBlock({|e| oError := e, .T. })
					Begin Sequence
						For nIndice := 1 to Len(Self:aCamposPEQPU)
							cCampo           := Self:aCamposPEQPU[nIndice]["codigo"]
							cConteudo        := &(Self:aCamposPEQPU[nIndice]["conteudoConsulta"])

							IF !Empty(Self:aCamposPEQPU[nIndice]["tabelaSX5"])
								cConteudo := PadR(Rtrim(cConteudo), GetSx3Cache("QP7_LABOR", "X3_TAMANHO"))
							EndIf

							oJsonAux[cCampo] := cConteudo
						Next
					Recover
					End Sequence
					ErrorBlock(bErrorBlock)

					If oError != Nil
						LogMsg('QIPINTAPI', 0, 0, 1, '', '', "QIPINTAPI Fail - " + oError:Description + CHR(10) + oError:ErrorStack + CHR(10) + oError:ErrorEnv)
						oError := Nil
					EndIf
					
				EndIf

				aAdd(aLista, oJsonAux )

				QPU->(DbSkip())
			EndDo
		EndIf

	EndIf
	
Return aLista

/*/{Protheus.doc} retornaNCsDaInspecaoDeEntrada
Retorna relação de NCs relacionadas à inspeção de entrada
@author brunno.costa
@since  08/04/2024
@param 01 - nRecnoQER, número, recno da amostra na QER relacionada
@return aLista, array, lista de NCs relacionadas
{
	{QEU_NAOCON, AG_DESCPO, QEU_NUMNC, QEU_CLASSE, QEE_DESCPO, QEU_CHAVE, QEU_CODNC, QEU_REVNC, DETALHES}, ...
}
/*/
METHOD retornaNCsDaInspecaoDeEntrada(nRecnoQER) as array CLASS FichasNaoConformidadesAPI

	Local aLista    := {}
	Local cChaveQER := ""
	Local cFilQEE   := xFilial("QEE")
	Local cFilQEU   := xFilial("QEU")
	Local cFilSAG   := xFilial("SAG")
	Local oJsonAux  := Nil

	Default nRecnoQER := -1

	If nRecnoQER > 0

		DbSelectArea("QER")
		QER->(DbGoTo(nRecnoQER))
		cChaveQER := QER->QER_CHAVE

		If !Empty(cChaveQER)
			DbSelectArea("QEU")
			QEU->(DbSetOrder(1))
			QEU->(DbSeek(cFilQEU + cChaveQER))
			While !QEU->(Eof())              .AND. ;
				cFilQEU   == QEU->QEU_FILIAL .AND. ;
				cChaveQER == QEU->QEU_CODMED
				
				oJsonAux               := JsonObject():new()
				oJsonAux['QEU_NAOCON'] := QEU->QEU_NAOCON
				oJsonAux['AG_DESCPO']  := Posicione("SAG", 1, cFilSAG + QEU->QEU_NAOCON,"AG_DESCPO")
				oJsonAux['QEU_NUMNC']  := QEU->QEU_NUMNC
				oJsonAux['QEU_CLASSE'] := QEU->QEU_CLASSE
				oJsonAux['QEE_DESCPO'] := Posicione("QEE", 1, cFilQEE + QEU->QEU_CLASSE,"QEE_DESCPO")
				oJsonAux['QEU_CHAVE']  := QEU->QEU_CHAVE
				oJsonAux['QEU_CODNC']  := QEU->QEU_CODNC
				oJsonAux['QEU_REVNC']  := QEU->QEU_REVNC
				oJsonAux['DETALHES']   := QP215FilTxt(QEU->QEU_CHAVE)

				aAdd(aLista, oJsonAux )

				QEU->(DbSkip())
			EndDo
		EndIf

	EndIf
	
Return aLista

/*/{Protheus.doc} processaRelacionamentoNCQIP
Processa relacionamento da NC (Inclui, altera ou excluí)
@author brunno.costa
@since  08/04/2024
@param 01 - nRecnoQPR, número, recno da amostra na QPR relacionada
@param 02 - aListaNC , array , lista de não conformidades relacionadas
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se processou com sucesso a lista de NC relacionadas
/*/
METHOD processaRelacionamentoNCQIP(nRecnoQPR, aListaNC, cErrorMessage) as logical CLASS FichasNaoConformidadesAPI

	Local lSucesso := .T.
	Local nItemNCs := 0
	Local nTotal   := Len(aListaNC)

	//Grava Nao Conformidades
	DbSelectArea("QPU")
	QPU->(dbSetOrder(1))
	For nItemNCs := 1 To nTotal

		//Inclusão / Alteração
		If !aListaNC[nItemNCs,"deleted"]
			lSucesso := self:incluiRelacionamentoNCQIP(nRecnoQPR, aListaNC[nItemNCs])
		Else
			lSucesso := self:excluiRelacionamentoNCQIP(nRecnoQPR, aListaNC[nItemNCs], @cErrorMessage, .T.)
		EndIf

		If !lSucesso
			Break
		Endif

	Next nItemNCs

Return lSucesso

/*/{Protheus.doc} processaRelacionamentoNC
Processa relacionamento da NC (Inclui, altera ou excluí)
@author brunno.costa
@since  08/11/2024
@param 01 - nRecnoQER, número, recno da amostra na QER relacionada
@param 02 - aListaNC , array , lista de não conformidades relacionadas
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@return lSucesso, lógico, indica se processou com sucesso a lista de NC relacionadas
/*/
METHOD processaRelacionamentoNCQIE(nRecnoQER, aListaNC, cErrorMessage) as logical CLASS FichasNaoConformidadesAPI

	Local lSucesso := .T.
	Local nItemNCs := 0
	Local nTotal   := Len(aListaNC)

	//Grava Nao Conformidades
	DbSelectArea("QEU")
	QEU->(dbSetOrder(1))
	For nItemNCs := 1 To nTotal

		//Inclusão / Alteração
		If !aListaNC[nItemNCs,"deleted"]
			lSucesso := self:incluiRelacionamentoNCQIE(nRecnoQER, aListaNC[nItemNCs])
		Else
			lSucesso := self:excluiRelacionamentoNCQIE(nRecnoQER, aListaNC[nItemNCs], @cErrorMessage, .T.)
		EndIf

		If !lSucesso
			Break
		Endif

	Next nItemNCs

Return lSucesso


/*/{Protheus.doc} incluiRelacionamentoNC
Processa inclusão de relacionamento de Amostra com NC
@author brunno.costa
@since  08/04/2024
@param 01 - nRecnoQPR, número, recno da amostra na QPR relacionada
@param 02 - oItemNC  , objeto, item de NC para inclusão de relacionamento
@return lSucesso, lógico, indica se processou com sucesso a inclusão do relacionamento NC
/*/
METHOD incluiRelacionamentoNCQIP(nRecnoQPR, oItemNC) as logical CLASS FichasNaoConformidadesAPI

	Local aCpoQNC   := {}
	Local aStrQPU   := {}
	Local axTexto   := {}
	Local cChaveQPR := ""
	Local cQNCVeri  := ""
	Local cQuebra   := Chr(13)+Chr(10)
	Local cTxtNC    := ""
	Local lSucesso  := .T.
	Local nIndice   := 0
	Local cEndPoint := "nonconformancerecords/api/qip/v1/qpuextrafields"

	Private cModulo := "QIP"

	Self:aCamposPEQPU := Iif(Self:aCamposPEQPU == Nil, Self:retornaCamposExtrasPEQPU("processinspectiontestresults/api/qip/v1/save"), Self:aCamposPEQPU)

	//Posiciona na QPR
	QPR->(DbGoTo(nRecnoQPR))
	cChaveQPR := QPR->QPR_CHAVE

	//Posiciona na QPK
	DbSelectArea('QPK')
	QPK->(dbSetOrder(1))
	QPK->(dbSeek(xFilial('QPK')+QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER))

	If !QPU->(dbSeek(xFilial("QPU")+cChaveQPR+oItemNC['code']))
		RecLock("QPU",.T.)
		QPU->QPU_FILIAL := xFilial("QPU")
		QPU->QPU_CODMED := cChaveQPR
		MsUnLock()
		FkCommit()
	EndIf

	RecLock("QPU",.F.)
	QPU->QPU_NAOCON := oItemNC['code']
	QPU->QPU_NUMNC  := oItemNC['quantity']
	QPU->QPU_CLASSE := oItemNC['codeClass']

	//Tratamento Campos Customizados PE QIPIntAPI - Evento 'qpuCamposAdicionais'
	For nIndice := 1 to Len(Self:aCamposPEQPU)
		If "QPU_" $ Self:aCamposPEQPU[nIndice]["codigo"] .ANd. FieldPos(Self:aCamposPEQPU[nIndice]["codigo"]) > 0 .And. ValType(oItemNC[Self:aCamposPEQPU[nIndice]["codigo"]]) == "C"
			&("QPU->" + Self:aCamposPEQPU[nIndice]["codigo"]) := oItemNC[Self:aCamposPEQPU[nIndice]["codigo"]]
		EndIf
	Next

	//Tratamento Campos Customizados PE QIPIntAPI - Evento 'qpuGravacaoComplementar'
	If Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIP")
		Execblock('QIPINTAPI',.F.,.F.,{oItemNC, cEndPoint, "FichasNaoConformidadesAPI", "qpuGravacaoComplementar"})
	Endif

	MsUnLock()
	FkCommit()

	If Empty(QPU->QPU_CHAVE)
		
		cChaveQPU := QA_NewChave("QPU",3)

		RecLock("QPU",.F.)
		QPU->QPU_CHAVE  := cChaveQPU
		MsUnLock()
		FkCommit()

	Endif

	//Grava o texto da Nco
	If !Empty(oItemNC['details'])
		axTexto := {{1, oItemNC['details']}}
		Qa_GrvTxt(QPU->QPU_CHAVE,"QIPA210C",1,axTexto,"QA2", 68)
	EndIf

	If !Self:validaIntegracaoQIPHabilitada()
		lSucesso := .F.
		Return lSucesso
	EndIf

	//Integracao  QIP x QNC
	If !Empty(QPU->QPU_CODNC) .And. !Empty(QPU->QPU_REVNC)
		cQNCVeri :=	"QNCVERI(QPU->QPU_CODNC, QPU->QPU_REVNC, 'QIP')"
	Else
		cQNCVeri := ".T."
	EndIf

	If &cQNCVeri
		//Se existirem os novos campos realiza a integracao
		aStrQPU := QPU->(dbStruct())

		//Caso haja alteracao no Resultado, apaga a NC corrente
		If !Empty(QPU->QPU_CODNC) .And. !Empty(QPU->QPU_REVNC)
			aCpoQNC := {}
			Aadd(aCpoQNC, xFilial("QI2"))
			Aadd(aCpoQNC, QPU->QPU_CODNC)
			Aadd(aCpoQNC, QPU->QPU_REVNC)
			QNCGERA(2,aCpoQNC)
		EndIf

		aCpoQNC := {}
		Aadd(aCpoQNC, {"QI2_MEMO1" , oItemNC['details']                                         })
		Aadd(aCpoQNC, {"QI2_ORIGEM", "QIP"                                                      })
		Aadd(aCpoQNC, {"QI2_TPFIC" , "2"                                                        })
		Aadd(aCpoQNC, {"QI2_CODPRO", QPK->QPK_PRODUT                                            })
		Aadd(aCpoQNC, {"QI2_LOTE"  , QPK->QPK_LOTE                                              })
		Aadd(aCpoQNC, {"QI2_QTDPRO", Padr(Alltrim(Str(QPK->QPK_TAMLOT)),TamSx3("QPL_TAMLOT")[1])})

		//STR0007 - "Produto: "
		//STR0008 - "Revisao: "
		//STR0009 - "OP: "
		Aadd(aCpoQNC, {"QI2_DESCR" , STR0007 + AllTrim(QPK->QPK_PRODUT) + "  " +;
		                             STR0008 + QPR->QPR_REVI + "  " +;
									 STR0009 + QPR->QPR_OP})

		//STR0005 - "Nao-Conformidade: " - Descrição da Não-Conformidade
		cTxtNC := STR0005 + AllTrim(oItemNC['code']) + " - " + AllTrim(oItemNC['description']) + cQuebra
		
		//Gravidade
		cTxtNC += AllTrim(oItemNC['class']) + cQuebra

		//STR0006 - "Operacao: "
		cTxtNC += STR0006+QPR->QPR_OPERAC+' '+AllTrim(Posicione('SG2',1,xFilial('SG2')+QPR->(QPR_PRODUT+QPR_ROTEIR)+QPR->QPR_OPERAC,'G2_DESCRI')) + cQuebra

		QP1->(dbSetOrder(1))
		QP1->(dbSeek(xFilial("QP1")+QPR->QPR_ENSAIO))

		//STR0010 - //"Ensaio: " XXX Descrição
		cTxtNC += STR0010 + AllTrim(QPR->QPR_ENSAIO) + ' ' + AllTrim(QP1->QP1_DESCPO) + cQuebra

		//STR0011 - "Laboratorio: "
		cTxtNC += STR0011 + AllTrim(QPR->QPR_LABOR) + cQuebra
		
		//Data e Hora da medição
		cTxtNC += AllTrim(FWX3Titulo('QPR_DTMEDI'))+': '+ AllTrim(DTOC(QPR->QPR_DTMEDI)) + ' ' + AllTrim(FWX3Titulo('QPR_HRMEDI'))+': '+ AllTrim(QPR->QPR_HRMEDI) + cQuebra
		
		//Ordem de Produção
		cTxtNC += AllTrim(FWX3Titulo('QPR_OP'))    +': '+ AllTrim(QPR->QPR_OP) + cQuebra

		//Resultado da Amostra
		cTxtNC += AllTrim(FWX3Titulo('QPR_RESULT'))+': '+ X3COMBO('QPR_RESULT',QPR->QPR_RESULT) + cQuebra

		//Medição
		cTxtNC += AllTrim(FWX3Titulo('QPS_MEDICA'))+': '+ self:retornaValorMedicao(QPR->QPR_CHAVE, QP1->QP1_TPCART, QP1->QP1_QTDE) + cQuebra
		
		QAA->(dbSetOrder(1))
		If QAA->(dbSeek(QPR->QPR_FILMAT+QPR->QPR_ENSR     ))
			Aadd(aCpoQNC, {"QI2_MATDEP", QAA->QAA_CC      })
			Aadd(aCpoQNC, {"QI2_FILDEP", QPR->QPR_FILMAT  })
			Aadd(aCpoQNC, {"QI2_ORIDEP", QAA->QAA_CC      })
			Aadd(aCpoQNC, {"QI2_FILORI", QPR->QPR_FILMAT  })
			cTxtNC += AllTrim(FWX3Titulo('QPR_ENSR'))+': '+ QPR->QPR_ENSR + ' ' + AllTrim(QA_NuSr(xFilial('QAA'),QP215ENS(),.T.,'A')) //Ensaiador
		EndIf
		
		Aadd(aCpoQNC, {"QI2_MEMO2" , cTxtNC               })
		Aadd(aCpoQNC, {"QI2_FILMAT", QPR->QPR_FILMAT      })
		Aadd(aCpoQNC, {"QI2_MAT"   , QPR->QPR_ENSR        })
		Aadd(aCpoQNC, {"QI2_OCORRE", QPR->QPR_DTMEDI      })
		Aadd(aCpoQNC, {"QI2_UNIMED", QPK->QPK_UM          })
		Aadd(aCpoQNC, {"QI2_ANO"   , Year(QPR->QPR_DTMEDI)})

		aRetQNC := QNCGERA(1,aCpoQNC)
		RecLock("QPU",.F.)
		QPU->QPU_CODNC := aRetQNC[2] //Codigo da Nao-conformidade
		QPU->QPU_REVNC := aRetQNC[3] //Revisao da Nao-conformidade
		QPU->(MsUnLock())
	Endif

Return lSucesso

/*/{Protheus.doc} incluiRelacionamentoNCQIE
Processa inclusão de relacionamento de Amostra com NC
@author brunno.costa
@since  08/11/2024
@param 01 - nRecnoQER, número, recno da amostra na QER relacionada
@param 02 - oItemNC  , objeto, item de NC para inclusão de relacionamento
@return lSucesso, lógico, indica se processou com sucesso a inclusão do relacionamento NC
/*/
METHOD incluiRelacionamentoNCQIE(nRecnoQER, oItemNC) as logical CLASS FichasNaoConformidadesAPI

	Local aCpoQNC   := {}
	Local aStrQEU   := {}
	Local axTexto   := {}
	Local cChaveQER := ""
	Local cChaveQEU := ""
	Local cDescr    := ""
	Local cQuebra   := Chr(13)+Chr(10)
	Local cTxtNC    := ""
	Local lQReinsp  := QieReinsp()
	Local lSucesso  := .T.

	Private cModulo := "QIE"

	If !Self:validaIntegracaoQIEHabilitada()
		lSucesso := .F.
		Return lSucesso
	EndIf

	DbSelectArea("QEU")
	QEU->(dbSetOrder(1))

	//Posiciona na QER
	QER->(DbGoTo(nRecnoQER))
	cChaveQER := QER->QER_CHAVE

	//Posiciona na QEK
	DbSelectArea('QEK')
	QEK->(DbSetOrder(11))
	If QEK->(dbSeek(xFilial('QEK')+QER->(QER_FORNEC+QER_LOJFOR+QER_NTFISC+QER_SERINF+QER_ITEMNF+QER_TIPONF+QER_LOTE) + Iif(lQReinsp, QER->QER_NUMSEQ, "")))

		If !QEU->(dbSeek(xFilial("QEU")+cChaveQER+oItemNC['code']))
			RecLock("QEU",.T.)
			QEU->QEU_FILIAL := xFilial("QEU")
			QEU->QEU_CODMED := cChaveQER
			MsUnLock()
			FkCommit()
		EndIf

		RecLock("QEU",.F.)
		QEU->QEU_NAOCON := oItemNC['code']
		QEU->QEU_NUMNC  := oItemNC['quantity']
		QEU->QEU_CLASSE := oItemNC['codeClass']
		MsUnLock()
		FkCommit()

		If Empty(QEU->QEU_CHAVE)
			
			cChaveQEU := QA_NewChave("QEU",3)

			RecLock("QEU",.F.)
			QEU->QEU_CHAVE  := cChaveQEU
			MsUnLock()
			FkCommit()

		Endif

		//Grava o texto da Nco
		If !Empty(oItemNC['details'])
			axTexto := {{1, oItemNC['details']}}
			Qa_GrvTxt(QEU->QEU_CHAVE,"QIEA210C",1,axTexto,"QA2", 68)
		EndIf

		//Se existirem os novos campos realiza a integracao
		aStrQEU := QEU->(dbStruct())

		//Caso haja alteracao no Resultado, apaga a NC corrente
		If !Empty(QEU->QEU_CODNC) .And. !Empty(QEU->QEU_REVNC)
			QI2->(dbSetOrder(2))
			If QI2->(MsSeek(xFilial("QI2")+QEU->QEU_CODNC+QEU->QEU_REVNC))
				If QI2->QI2_STATUS == "1"
					aCpoQNC := {}
					Aadd(aCpoQNC,xFilial("QI2"))
					Aadd(aCpoQNC,QEU->QEU_CODNC)
					Aadd(aCpoQNC,QEU->QEU_REVNC)
					aRetQNC := QNCGERA(2,aCpoQNC)
				Else
					lSucesso := .F.
				EndIf
			EndIf
		EndIf

		If lSucesso
			//Posiciona nos da Medicao
			QER->(dbSetOrder(4))
			QER->(dbSeek(xFilial("QER")+cChaveQER))

			aCpoQNC := {}
			Aadd(aCpoQNC,{"QI2_MEMO1" ,Q215FilTxt(QEU->QEU_CHAVE)}) 
			Aadd(aCpoQNC,{"QI2_ORIGEM","QIE"})
			Aadd(aCpoQNC,{"QI2_TPFIC" ,"2"})
			Aadd(aCpoQNC,{"QI2_CODPRO",QEK->QEK_PRODUT})
			Aadd(aCpoQNC,{"QI2_LOTE",  QEK->QEK_LOTE})
			Aadd(aCpoQNC,{"QI2_QTDPRO",QEK->QEK_TAMLOT})                                                     
			Aadd(aCpoQNC,{"QI2_DESCR", " Produto: "+AllTrim(QEK->QEK_PRODUT)+" "+"Revisao: "+QER->QER_REVI}) //" Produto: " ### "Revisao: "
								
			If QEK->QEK_TIPONF $ "BD"
				Aadd(aCpoQNC,{"QI2_CODCLI",QEK->QEK_FORNEC})
				Aadd(aCpoQNC,{"QI2_LOJCLI",QEK->QEK_LOJFOR})
				cDescr  := Posicione("SA1",1,xFilial("SA1")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR,"A1_NOME")
				cTxtNC := "Cliente :"+AllTrim(QEK->QEK_FORNEC)+"-"+QEK->QEK_LOJFOR+" - "+cDescr+cQuebra //"Cliente :"
			Else
				Aadd(aCpoQNC,{"QI2_CODFOR",QEK->QEK_FORNEC})
				Aadd(aCpoQNC,{"QI2_LOJFOR",QEK->QEK_LOJFOR})
				cDescr  := Posicione("SA2",1,xFilial("SA2")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR,"A2_NOME")
				cTxtNC := "Fornecedor :"+AllTrim(QEK->QEK_FORNEC)+"-"+QEK->QEK_LOJFOR+" - "+cDescr+cQuebra //"Fornecedor :"
			EndIf

			//Posiciona na não conformidade da Medicao
			DbSelectArea("QEU")
			QEU->(dbSetOrder(3))
			If QEU->(dbSeek(xFilial("QEU")+QEU->QEU_CHAVE))
				//"Nao-Conformidade: "
				cTxtNC += AllTrim(GetSx3Cache('QEU_NAOCON', 'X3_TITULO'))+': '+ AllTrim(QEU->QEU_NAOCON) +" - "
				//"Descrição da Não-Conformidade"
				cTxtNC += A020DNCo(QEU->QEU_NAOCON) + cQuebra
				//"Gravidade"
				cTxtNC += AllTrim(GetSx3Cache('QEU_CLASSE', 'X3_TITULO'))+': '+ A040DCla(QEU->QEU_CLASSE) + cQuebra
			EndIf
			//"Ensaio: "###" "Descrição"
			cTxtNC += AllTrim(GetSx3Cache('QER_ENSAIO', 'X3_TITULO'))+': '+ ALLTRIM(QER->QER_ENSAIO)+" - "+ALLTRIM(Posicione("QE1", 1, xFilial("QE1")+QER->QER_ENSAIO, "QE1_DESCPO")) + cQuebra
			//"Laboratorio: "###"
			cTxtNC += AllTrim(GetSx3Cache('QER_LABOR', 'X3_TITULO'))+': '+ ALLTRIM(QER->QER_LABOR) + cQuebra
			//"Data e Hora da medição"
			cTxtNC += AllTrim(GetSx3Cache('QER_DTMEDI', 'X3_TITULO'))+': '+ AllTrim(DTOC(QER->QER_DTMEDI)) + ' ' + AllTrim(GetSx3Cache('QER_HRMEDI', 'X3_TITULO'))+': '+ AllTrim(QER->QER_HRMEDI)+cQuebra // Data e Hora da medição
			//"Documento de Entrada"
			cTxtNC += AllTrim(GetSx3Cache('QEK_NTFISC', 'X3_TITULO'))+': '+ AllTrim(QEK->QEK_NTFISC)  + ' ' + AllTrim(GetSx3Cache('QEK_SERINF', 'X3_TITULO'))+': '+ AllTrim(QEK->QEK_SERINF)+cQuebra // QEK->QEK_SERINF
			//"Resultado"
			cTxtNC += AllTrim(GetSx3Cache('QER_RESULT', 'X3_TITULO'))+': '+ AllTrim(X3COMBO('QER_RESULT',QER->QER_RESULT)) + cQuebra
			//"Medição"
			If QE1->QE1_CARTA $ "XBR/XBS/IND/XMR/HIS"
				cTxtNC += AllTrim(GetSx3Cache('QES_MEDICA', 'X3_TITULO'))+': '+ AllTrim(Posicione("QES", 1, xFilial("QES")+QEU->QEU_CODMED, "QES_MEDICA")) + cQuebra
			Else
				cTxtNC += AllTrim(GetSx3Cache('QEQ_MEDICA', 'X3_TITULO'))+': '+ AllTrim(Posicione("QEQ", 1, xFilial("QEQ")+QEU->QEU_CODMED, "QEQ_MEDICA")) + cQuebra
			EndIf
			
			QAA->(dbSetOrder(1))
			If QAA->(dbSeek(QER->QER_FILMAT+QER->QER_ENSR))
				Aadd(aCpoQNC,{"QI2_MATDEP", QAA->QAA_CC})
				Aadd(aCpoQNC,{"QI2_FILDEP", QER->QER_FILMAT})
				Aadd(aCpoQNC,{"QI2_ORIDEP", QAA->QAA_CC})
				Aadd(aCpoQNC,{"QI2_FILORI", QER->QER_FILMAT})
				cTxtNC += AllTrim(GetSx3Cache('QER_ENSR', 'X3_TITULO'))+': '+ AllTrim(QER->QER_ENSR) + ' ' + AllTrim(Posicione("QAA", 1, xFilial("QAA")+QER->QER_ENSR, "QAA_APELID")) //Ensaiador
			EndIf

			Aadd(aCpoQNC,{"QI2_MEMO2", cTxtNC + cQuebra})
			
			Aadd(aCpoQNC,{"QI2_FILMAT",QER->QER_FILMAT})
			Aadd(aCpoQNC,{"QI2_MAT"   ,QER->QER_ENSR})
			Aadd(aCpoQNC,{"QI2_OCORRE",QER->QER_DTMEDI})
			Aadd(aCpoQNC,{"QI2_UNIMED",QEK->QEK_UNIMED})
			Aadd(aCpoQNC,{"QI2_ANO"   ,Year(QER->QER_DTMEDI)})

			aRetQNC := QNCGERA(1,aCpoQNC)
			RecLock("QEU",.F.)
			QEU->QEU_CODNC := aRetQNC[2] //Codigo da Nao-conformidade
			QEU->QEU_REVNC := aRetQNC[3] //Revisao da Nao-conformidade
			QEU->(MsUnLock())
		EndIf
	Endif

Return lSucesso

/*/{Protheus.doc} retornaValorMedicao
Retorna o valor da medição
@author brunno.costa
@since  08/04/2024
@param 01 - cChave    , caracter, valor correspondente ao QPR_CHAVE para localização dos registros na QPS e QPQ
@param 02 - cTipoCarta, caracter, tipo da carta conforme QP1_TPCART
@param 03 - nMedicoes , número  , quantidade de medições conforme QP1_QTDE
@return cMedicao, caracter, conteúdo da medição da amostra
/*/
METHOD retornaValorMedicao(cChave, cTipoCarta, nMedicoes) as array CLASS FichasNaoConformidadesAPI

	Local cMedicao := ""
	Local cFilAux  := ""
	Local nRegistros := 0

	If cTipoCarta == "X"
		cFilAux := xFilial("QPQ")
		DbSelectArea("QPQ")
		QPQ->(dbSetOrder(1))
		If QPQ->(dbSeek(cFilAux+cChave))
			cMedicao := QPQ->QPQ_MEDICA
		EndIf
	Else
		cFilAux := xFilial("QPS")
		DbSelectArea("QPS")
		QPS->(dbSetOrder(1))
		If QPS->(dbSeek(cFilAux+cChave))
			While !QPS->(Eof())                                         .AND.;
				  QPS->QPS_FILIAL + QPS->QPS_CODMED == cFilAux + cChave .AND.;
				  nRegistros < nMedicoes
				cMedicao   += Iif(Empty(cMedicao), '', ', ') + QPS->QPS_MEDICA
				nRegistros += 1
				QPS->(DbSkip())
			EndDo
		EndIf
	EndIf

Return cMedicao

/*/{Protheus.doc} excluiRelacionamentoNCQIP
Processa exclusão de relacionamento de Amostra com NC - QIP
@author thiago.rover
@since  22/04/2024
@param 01 - nRecnoQPR, número, recno da amostra na QPR relacionada
@param 02 - oItemNC  , objeto, item de NC para inclusão de relacionamento
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@param 04 - lVerificaStatusFNC, lógico, indica se validará ou não o status da FNC antes de deletar
@return lSucesso, lógico, indica se processou com sucesso a exclusão do relacionamento NC
/*/
METHOD excluiRelacionamentoNCQIP(nRecnoQPR, oItemNC, cErrorMessage, lVerificaStatusFNC) as Logical CLASS FichasNaoConformidadesAPI
	Local aCpoQNC     := {}
	Local bErrorBlock := Nil
	Local cChaveQPR   := ""
	Local cCodigoNC   := IIF(oItemNC[ 'code' ] == NIL, oItemNC[ 'QPU_NAOCON' ], oItemNC[ 'code' ])
	Local cError      := Nil
	Local cQNCVeri    := ""
	Local lSucesso    := .T.

	Default cErrorMessage      := ""
	Default lVerificaStatusFNC := .T.

	bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e), lSucesso := .F., cError := e:Description, })

	If !Self:validaIntegracaoQIPHabilitada()
		lSucesso := .F.
		Return lSucesso
	EndIf

	//Posiciona na QPR
	QPR->(DbGoTo(nRecnoQPR))
	cChaveQPR := QPR->QPR_CHAVE

	//Posiciona na QPU
	If QPU->(dbSeek(xFilial("QPU")+cChaveQPR+cCodigoNC))

		//Integracao  QIP x QNC
		If !Empty(QPU->QPU_CODNC) .And. !Empty(QPU->QPU_REVNC) .And. lVerificaStatusFNC
			cQNCVeri :=	"QNCVERI(QPU->QPU_CODNC, QPU->QPU_REVNC, 'QIP')"
		Else
			cQNCVeri := ".T."
		EndIf

		If &cQNCVeri
			//Se existirem os novos campos, envia os mesmos para a exclusao das NC's
			aStrQPU := QPU->(dbStruct())
			aCpoQNC := {}
			Aadd(aCpoQNC, xFilial("QI2"))
			Aadd(aCpoQNC, QPU->QPU_CODNC)
			Aadd(aCpoQNC, QPU->QPU_REVNC)
			QNCGERA(2, aCpoQNC)
			lSucesso   := .T.

		Else
			If !Empty(QPU->QPU_CODNC) .And. !Empty(QPU->QPU_REVNC)
				lSucesso := .F.
			EndIf
		Endif

		If lSucesso
			RecLock("QPU",.F.)
			dbDelete()
			MsUnLock()

			//Deleta cada texto ligado a cada nco
			axTexto := {}
			Aadd(axTexto,{1, "" })  // Deleta o Texto
			Qa_GrvTxt(QPU->QPU_CHAVE,"QIPA210C",1,axTexto,"QA2", 68)
		EndIf
	EndIf

	If !lSucesso .And. Empty(cErrorMessage)
		cError := Iif(cError == Nil, "", cError)
	
		cErrorMessage := STR0012         + " " +; // STR0012 - Não foi possivel excluir a não conformidade ( "###" ),
		                "'"+ Alltrim(Posicione("SAG", 1, xFilial("SAG") + QPU->QPU_NAOCON,"AG_DESCPO")) + "'. " +;
				        STR0013                +; // STR0013 - Existe uma FNC ( "###" )
						Alltrim(QPU->QPU_CODNC)+;
				   	    "/"                    +; 
			            Alltrim(QPU->QPU_REVNC)+ " " +; 
			            STR0014         + ". " +; // STR0014 - relacionada com status diferente de 'Registrada'
			            cError
	EndIf

	ErrorBlock(bErrorBlock)

Return lSucesso

/*/{Protheus.doc} excluiRelacionamentoNCQIE
Processa exclusão de relacionamento de Amostra com NC - QIE
@author thiago.rover
@since  22/04/2024
@param 01 - nRecnoQER, número, recno da amostra na QER relacionada
@param 02 - oItemNC  , objeto, item de NC para inclusão de relacionamento
@param 03 - cErrorMessage, string, retorna por referência a mensagem de erro
@param 04 - lVerificaStatusFNC, lógico, indica se validará ou não o status da FNC antes de deletar
@return lSucesso, lógico, indica se processou com sucesso a exclusão do relacionamento NC
/*/
METHOD excluiRelacionamentoNCQIE(nRecnoQER, oItemNC, cErrorMessage, lVerificaStatusFNC) as Logical CLASS FichasNaoConformidadesAPI
	Local aCpoQNC     := {}
	Local bErrorBlock := Nil
	Local cChaveQER   := ""
	Local cCodigoNC   := IIF(oItemNC[ 'code' ] == NIL, oItemNC[ 'QEU_NAOCON' ], oItemNC[ 'code' ])
	Local cError      := Nil
	Local lSucesso    := .T.

	Default cErrorMessage      := ""
	Default lVerificaStatusFNC := .T.

	bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e), lSucesso := .F., cError := e:Description, })

	If !Self:validaIntegracaoQIEHabilitada()
		lSucesso := .F.
		Return lSucesso
	EndIf

	//Posiciona na QER
	QER->(DbGoTo(nRecnoQER))
	cChaveQER := QER->QER_CHAVE

	//Posiciona na QEU
	If QEU->(dbSeek(xFilial("QEU")+cChaveQER+cCodigoNC))

		//Se existirem os novos campos, envia os mesmos para a exclusao das NC's
		aStrQEU := QEU->(dbStruct())
		
		If !Empty(QEU->QEU_CODNC) .And. !Empty(QEU->QEU_REVNC)
			QI2->(dbSetOrder(2))
			If QI2->(MsSeek(xFilial("QI2")+QEU->QEU_CODNC+QEU->QEU_REVNC))
				If QI2->QI2_STATUS == "1"
					aCpoQNC := {}
					Aadd(aCpoQNC, xFilial("QI2"))
					Aadd(aCpoQNC, QEU->QEU_CODNC)
					Aadd(aCpoQNC, QEU->QEU_REVNC)
					aRetQNC := QNCGERA(2,aCpoQNC)
					lSucesso   := .T.
				Else
					lSucesso := .F.
				EndIf
			EndIf
		EndIf

		If lSucesso
			RecLock("QEU",.F.)
			dbDelete()
			MsUnLock()

			//Deleta cada texto ligado a cada nco
			axTexto := {}
			Aadd(axTexto,{1, "" })  // Deleta o Texto
			Qa_GrvTxt(QEU->QEU_CHAVE,"QIEA210C",1,axTexto,"QA2", 68)
		EndIf
	EndIf

	If !lSucesso .And. Empty(cErrorMessage)
		cError := Iif(cError == Nil, "", cError)
	
		cErrorMessage := STR0012         + " " +; // STR0012 - Não foi possivel excluir a não conformidade ( "###" ),
		                "'"+ Alltrim(Posicione("SAG", 1, xFilial("SAG") + QEU->QEU_NAOCON,"AG_DESCPO")) + "'. " +;
				        STR0013                +; // STR0013 - Existe uma FNC ( "###" )
						Alltrim(QEU->QEU_CODNC)+;
				   	    "/"                    +; 
			            Alltrim(QEU->QEU_REVNC)+ " " +; 
			            STR0014         + ". " +; // STR0014 - relacionada com status diferente de 'Registrada'
			            cError
	EndIf

	ErrorBlock(bErrorBlock)

Return lSucesso

