#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc}  MESA OPERACIONAL PO-UI

Classe WSRESTFUL - API Web Service RESTFUL - Mesa Operacional PO UI

@Metodos WSMETHOD

@author     ServiÁos - Mesa Operacional PO UI
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSRESTFUL MESAOPERACIONAL DESCRIPTION "Mesa Operacional"

	WSDATA cFil      AS STRING //Filial
	WSDATA cData     AS STRING //Data ˙nica
	WSDATA cArea     AS STRING //¡rea supervis„o
	WSDATA cOrc      AS STRING //CÛdigo do OrÁamento
	WSDATA cLoc      AS STRING //CÛdigo do Local (ABS)
	WSDATA cEscala   AS STRING //CÛdigo Escala
	WSDATA cContrato AS STRING //CÛdigo Contrato
	WSDATA cRevisao  AS STRING //CÛdigo Revis„o
	WSDATA cData1    AS STRING //Data inicial Range
	WSDATA cData2    AS STRING //Data final Range
	WSDATA cPosto    AS STRING //CÛdigo do Posto (TFF)
	WSDATA cFunc     AS STRING //CÛdigo da FunÁ„o
	WSDATA cAtend    AS STRING //CÛdigo do Atendente
	WSDATA cTFL      AS STRING //CÛdigo do Local (TFL)
	WSDATA cSeqTur   AS STRING //Sequencia da escala/turno
	WSDATA cTurno	 AS STRING //Turno
	WSDATA cCodABB	 AS STRING //CÛdigo da Agenda
	WSDATA cCodManut AS STRING //CÛdigo da manutenÁ„o
	WSDATA cSequencia AS STRING //Sequencia do Turno

	//ALOCA«’ES
	WSMETHOD GET filial          DESCRIPTION 'filtro Filial'                     PATH "filial"          PRODUCES APPLICATION_JSON
	WSMETHOD GET novoAtendente   DESCRIPTION 'buscar novos atendentes'           PATH "novoAtendente"   PRODUCES APPLICATION_JSON
	WSMETHOD GET resAtendente    DESCRIPTION 'buscar atendentes da reserva'      PATH "resAtendente"    PRODUCES APPLICATION_JSON
	WSMETHOD GET resOrc          DESCRIPTION 'buscar orÁamentos de reserva'      PATH "resOrc"          PRODUCES APPLICATION_JSON
	WSMETHOD GET resLoc          DESCRIPTION 'buscar Locais do orc de reserva'   PATH "resLoc"          PRODUCES APPLICATION_JSON
	WSMETHOD GET resPostos       DESCRIPTION 'buscar postos de um local'         PATH "resPostos"       PRODUCES APPLICATION_JSON
	WSMETHOD GET resMotivos      DESCRIPTION 'buscar motivos alocaÁ„o reserva'   PATH "resMotivos"      PRODUCES APPLICATION_JSON
	WSMETHOD GET resSequencias   DESCRIPTION 'buscar sequencias da escala'       PATH "resSequencias"   PRODUCES APPLICATION_JSON
	WSMETHOD GET resBase         DESCRIPTION 'buscar bases do local'             PATH "resBase"         PRODUCES APPLICATION_JSON
	WSMETHOD GET impLocais       DESCRIPTION 'buscar locais na implantaÁ„o'      PATH "impLocais"       PRODUCES APPLICATION_JSON
	WSMETHOD GET impPostos       DESCRIPTION 'buscar postos na implantaÁ„o'      PATH "impPostos"       PRODUCES APPLICATION_JSON
	WSMETHOD GET impVagas        DESCRIPTION 'buscar vagas posto na implantaÁ„o' PATH "impVagas"        PRODUCES APPLICATION_JSON
	WSMETHOD GET projEsc         DESCRIPTION 'Projetar Escala'                   PATH "projEsc"         PRODUCES APPLICATION_JSON
	WSMETHOD POST compAloc       DESCRIPTION 'compara funÁ„o/salario/beneficios' PATH "compAloc"        PRODUCES APPLICATION_JSON
	WSMETHOD POST infPosto       DESCRIPTION 'buscar informaÁıes do posto/benef.'PATH "infPosto"        PRODUCES APPLICATION_JSON
	WSMETHOD POST infAtend       DESCRIPTION 'buscar informaÁıes do atend/benef.'PATH "infAtend"        PRODUCES APPLICATION_JSON
	WSMETHOD POST impContrato    DESCRIPTION 'buscar contratos na implantaÁ„o'   PATH "impContrato"     PRODUCES APPLICATION_JSON
	WSMETHOD POST alocEfe        DESCRIPTION "Alocacao Efetivo"                  PATH "alocEfe"         PRODUCES APPLICATION_JSON
	WSMETHOD POST alocRes        DESCRIPTION "Alocacao Reserva"                  PATH "alocRes"         PRODUCES APPLICATION_JSON
	WSMETHOD POST area           DESCRIPTION 'filtro areas'                      PATH "area"            PRODUCES APPLICATION_JSON
	WSMETHOD POST cliente        DESCRIPTION 'filtro clientes'                   PATH "cliente"         PRODUCES APPLICATION_JSON
	WSMETHOD POST contrato       DESCRIPTION 'filtro contrato'                   PATH "contrato"        PRODUCES APPLICATION_JSON
	WSMETHOD POST localidade     DESCRIPTION 'filtro localidade'                 PATH "local"           PRODUCES APPLICATION_JSON
	WSMETHOD POST posto          DESCRIPTION 'filtro posto'                      PATH "posto"           PRODUCES APPLICATION_JSON
	WSMETHOD POST buscar         DESCRIPTION 'buscar postos'                     PATH "buscar"          PRODUCES APPLICATION_JSON
	WSMETHOD GET parametro       DESCRIPTION 'Busca par‚metro MV_TESGSNE'        PATH "parametro"
	WSMETHOD POST benefPosto     DESCRIPTION 'buscar benefÌcios'                 PATH "benefPosto"      PRODUCES APPLICATION_JSON
	WSMETHOD GET atendOcioso     DESCRIPTION 'buscar atendentes ociosos'         PATH "atendOcioso"     PRODUCES APPLICATION_JSON
	WSMETHOD GET areaSup 		 DESCRIPTION 'buscar area supervis„o'			 PATH "areaSup"         PRODUCES APPLICATION_JSON
	//MANUTEN«’ES - PLANEJAMENTO OPERACIONAL:
	WSMETHOD GET agendasABB      DESCRIPTION 'retorna agendas do atendente'      PATH "agendasABB"      PRODUCES APPLICATION_JSON
	WSMETHOD GET impMotivos      DESCRIPTION 'buscar motivos alocaÁ„o'           PATH "impMotivos"      PRODUCES APPLICATION_JSON
	WSMETHOD GET manutencoes     DESCRIPTION 'buscar tipos de manutencoes'       PATH "manutencoes"     PRODUCES APPLICATION_JSON
	WSMETHOD POST markManut		 DESCRIPTION 'buscar manutenÁıes de acordo com seleÁ„o de agendas'       PATH "markManut"     PRODUCES APPLICATION_JSON
	WSMETHOD GET substitutos     DESCRIPTION 'buscar funcionarios substitutos'   PATH "substitutos"     PRODUCES APPLICATION_JSON
	WSMETHOD GET manutABB		 DESCRIPTION 'buscar manutenÁıes de uma agenda'	 PATH "manutABB"		PRODUCES APPLICATION_JSON
	WSMETHOD GET detailManut	 DESCRIPTION 'retorna detalhes da manutenÁ„o'	 PATH "detailManut"		PRODUCES APPLICATION_JSON
	WSMETHOD GET conflitaHora	 DESCRIPTION 'verifica conflito de horas na exclus„o de manutenÁ„o'	 PATH "conflitaHora"		PRODUCES APPLICATION_JSON	
	WSMETHOD POST alterManut	 DESCRIPTION 'alterar manutenÁıes de uma agenda' PATH "alterManut"		PRODUCES APPLICATION_JSON
	WSMETHOD POST manutencao     DESCRIPTION 'grava manutenÁ„o e substituto'     PATH "manutencao"      PRODUCES APPLICATION_JSON
	WSMETHOD GET tipAlocManut	 DESCRIPTION 'tipos de alocaÁ„o manutenÁ„o'		 PATH "tipAlocManut"	PRODUCES APPLICATION_JSON
	//FLUXO MANUTEN«√O DE REALOCA«√O:
	WSMETHOD GET contratoRealoc	 DESCRIPTION 'Carga de contrato na realocaÁ„o'	 PATH "contratoRealoc"	PRODUCES APPLICATION_JSON
	WSMETHOD GET localRealoc	 DESCRIPTION 'Carga de local na realocaÁ„o'	 	 PATH "localRealoc"		PRODUCES APPLICATION_JSON
	WSMETHOD GET postoRealoc	 DESCRIPTION 'Carga de posto na realocaÁ„o'	 	 PATH "postoRealoc"		PRODUCES APPLICATION_JSON
	WSMETHOD GET escalaRealoc	 DESCRIPTION 'Carga de escala na realocaÁ„o'	 PATH "escalaRealoc"	PRODUCES APPLICATION_JSON
	WSMETHOD GET tpMovRealoc	 DESCRIPTION 'Carga de tipo de movimentaÁ„o na realocaÁ„o'	  PATH "tpMovRealoc"	PRODUCES APPLICATION_JSON
	WSMETHOD GET seqIniRealoc	 DESCRIPTION 'Carga de sequencia inicial na realocaÁ„o'	 	  PATH "seqIniRealoc"	PRODUCES APPLICATION_JSON
	WSMETHOD GET confAlocRealoc	 DESCRIPTION 'Carga de configuraÁ„o de alocaÁ„o na realocaÁ„o'PATH "confAlocRealoc"	PRODUCES APPLICATION_JSON
	WSMETHOD POST projRealoc	 DESCRIPTION 'projeta manutenÁ„o de realocaÁ„o'	 PATH "projRealoc"	PRODUCES APPLICATION_JSON
	WSMETHOD POST gravRealoc	 DESCRIPTION 'grava manutenÁ„o de realocaÁ„o'	 PATH "gravRealoc"	PRODUCES APPLICATION_JSON
	//FLUXO MANUTEN«√O DE COMPENSA«√O:
	WSMETHOD POST projCompen	 DESCRIPTION 'inicia manutenÁ„o de compensaÁ„o'	 PATH "projCompen"	PRODUCES APPLICATION_JSON
	WSMETHOD POST gravCompen	 DESCRIPTION 'grava manutenÁ„o de compensaÁ„o'	 PATH "gravCompen"	PRODUCES APPLICATION_JSON
	//ITEM EXTRA OPERACIONAL - AMBOS
	WSMETHOD GET ieoCliente		 DESCRIPTION 'Filtro Cliente Item extra oper.'	 PATH "ieoCliente"		PRODUCES APPLICATION_JSON	
	//ITEM EXTRA OPERACIONAL - FLUXO CONTRATO:
	WSMETHOD POST ieocOrc		 DESCRIPTION 'Filtro orÁamentos de item extra'	 PATH "ieocOrc"			PRODUCES APPLICATION_JSON
	WSMETHOD POST ieocLocal		 DESCRIPTION 'Filtro locais de item extra'		 PATH "ieocLocal"		PRODUCES APPLICATION_JSON
	WSMETHOD POST ieocPosto		 DESCRIPTION 'Filtro postos de item extra'		 PATH "ieocPosto"		PRODUCES APPLICATION_JSON
	WSMETHOD POST ieocBuscar	 DESCRIPTION 'Buscar orÁamentos de item extra'	 PATH "ieocBuscar"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieocLoc		 DESCRIPTION 'locais Item Extra na implantaÁ„o'	 PATH "ieocLoc"       	PRODUCES APPLICATION_JSON
	WSMETHOD GET ieocPostos		 DESCRIPTION 'Postos Item Extra na implantaÁ„o'	 PATH "ieocPostos"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieocFuncao		 DESCRIPTION 'buscar funcıes Item extra operac.' PATH "ieocFuncao"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieocCargo		 DESCRIPTION 'buscar cargos Item extra operac.'  PATH "ieocCargo"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieocProduto	 DESCRIPTION 'buscar serviÁos Item extra operac.'PATH "ieocProduto"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieocEscala		 DESCRIPTION 'buscar Escala Item extra operac.'	 PATH "ieocEscala"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieocSeq		 DESCRIPTION 'buscar Seq Escala Item extra'		 PATH "ieocSeq"			PRODUCES APPLICATION_JSON
	WSMETHOD GET ieocTurno		 DESCRIPTION 'buscar Turno Item extra operac.'	 PATH "ieocTurno"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieoCalend		 DESCRIPTION 'buscar Calendario de feriados IEO' PATH "ieoCalend"		PRODUCES APPLICATION_JSON	
	WSMETHOD GET ieocTES		 DESCRIPTION 'buscar TES Item extra operacional' PATH "ieocTES"			PRODUCES APPLICATION_JSON	
	WSMETHOD POST addItemExtra	 DESCRIPTION 'aplicaÁ„o de item extra no orÁ.'	 PATH "addItemExtra"	PRODUCES APPLICATION_JSON
	//ITEM EXTRA OPERACIONAL - FLUXO PESSOA:
	WSMETHOD POST ieopOrc		 DESCRIPTION 'Filtro orÁamentos de item extra'	 PATH "ieopOrc"			PRODUCES APPLICATION_JSON
	WSMETHOD POST ieopLocal		 DESCRIPTION 'Filtro locais de item extra'		 PATH "ieopLocal"		PRODUCES APPLICATION_JSON
	WSMETHOD POST ieopPosto		 DESCRIPTION 'Filtro postos de item extra'		 PATH "ieopPosto"		PRODUCES APPLICATION_JSON
	WSMETHOD POST ieopBuscar	 DESCRIPTION 'Buscar orÁamentos de item extra'	 PATH "ieopBuscar"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieopLoc		 DESCRIPTION 'locais Item Extra na implantaÁ„o'	 PATH "ieopLoc"       	PRODUCES APPLICATION_JSON
	WSMETHOD GET ieopPost		 DESCRIPTION 'postos Item Extra na implantaÁ„o'	 PATH "ieopPost"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieopVagas		 DESCRIPTION 'vagas Item Extra na implantaÁ„o'	 PATH "ieopVagas"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieopAtend		 DESCRIPTION 'Atendentes Item Extra implantaÁ„o' PATH "ieopAtend"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieopEscala		 DESCRIPTION 'Retorna escalas com base no turno' PATH "ieopEscala"		PRODUCES APPLICATION_JSON
	WSMETHOD GET ieopSeq		 DESCRIPTION 'Retorna escalas com base no turno' PATH "ieopSeq"			PRODUCES APPLICATION_JSON
	WSMETHOD GET ieopTipAloc	 DESCRIPTION 'Retorna escalas com base no turno' PATH "ieopTipAloc"		PRODUCES APPLICATION_JSON
	WSMETHOD POST ieoProj		 DESCRIPTION 'Atendentes Item Extra implantaÁ„o' PATH "ieoProj"			PRODUCES APPLICATION_JSON
	WSMETHOD POST ieoGrav		 DESCRIPTION 'Atendentes Item Extra implantaÁ„o' PATH "ieoGrav"			PRODUCES APPLICATION_JSON

END WSRESTFUL

//------------------------------------------------------------------------------
/*/{Protheus.doc}  MESA OPERACIONAL PO-UI

MÈtodo Get retorna valor do par‚metro MV_TESGSNE


@author     ServiÁos - Mesa Operacional PO UI
@since      17/01/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET parametro WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local valueParam
Self:SetContentType("application/json")

oResponse := SuperGetMv("MV_TESGSNE",.T.,.F.)
valueParam  := oResponse

Self:SetResponse(valueParam)
RETURN

//------------------------------------------------------------------------------
/*/{Protheus.doc}  MESA OPERACIONAL PO-UI

MÈtodo Get retorna JSON com array de filiais nas condiÁıes:

Multifilial .T. -> Todas filiais em que o usu·rio tem permiss„o

Multifilial .F. -> Filial logada

Retorno Json: "filial":"D MG 01"

@author     ServiÁos - Mesa Operacional PO UI
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET filial WSREST MESAOPERACIONAL
Local oResponse  := JsonObject():New()
Local nX         := 0
Local aFilial    := {}
Local cNomeFil	 := ""

Self:SetContentType("application/json")

oResponse['Filial'] := {}

lMultFil := isMultFil()

If lMultFil
	aFilial := FWLoadSM0(,.T.)
	For nX := 1 To Len(aFilial)
		If aFilial[nX][11] //Verifica se o usu·rio logado tem permiss„o de acesso na filial.
			Aadd(oResponse['Filial'], JsonObject():New())
			aTail(oResponse['Filial'])['codigo'] := aFilial[nX][2] //Filial Ex: "D MG 01"
			//Nome da filial
			cNomeFil := FwFilialName(,aFilial[nX][2])
			aTail(oResponse['Filial'])['nome'] := EncodeUTF8(AllTrim(cNomeFil))
		Endif
	Next nX
Else
	Aadd(oResponse['Filial'], JsonObject():New())
	aTail(oResponse['Filial'])['codigo'] := cFilAnt //Filial do sistema logado
	//Nome da filial
	cNomeFil := FwFilialName(,cFilAnt)
	aTail(oResponse['Filial'])['nome'] := EncodeUTF8(AllTrim(cNomeFil))
EndIF

//Resposta Json:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

aSize(aFilial, 0)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de retorno de Areas de acordo com as Filiais selecionadas.

Recebe cBody - JSON com filial selecionada no filtro

Retorna Json (ARRAY) de areas:

    "areas":[
        {
            "codigo": "000001"
            "descriÁ„o": "exemplo"
        }
    ]

@author     ServiÁos
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST area WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Query mÈtodo posto
cAliasTmp := qryFormer(oParamBody, "area")

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Area'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Area'], JsonObject():New())
		aTail(oResponse['Area'])['codigo']      := AllTrim((cAliasTmp)->ABS_CODSUP)
		aTail(oResponse['Area'])['descricao']   := EncodeUTF8(AllTrim((cAliasTmp)->TGS_DESCRI))
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de retorno de Clientes de acordo com as Filiais e Areas selecionadas

Recebe cBody - JSON com filial e areas selecionada no filtro

Retorna Json (ARRAY) de clientes:

    "clientes":[
        {
            "codigo": "000001",
            "loja": "01",
            "nome": "Maria JosÈ"
        }
    ]

@author     ServiÁos
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST cliente WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Query mÈtodo cliente
cAliasTmp := qryFormer(oParamBody, "cliente")

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Cliente'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['Cliente'], JsonObject():New())
		aTail(oResponse['Cliente'])['codigo']   := AllTrim((cAliasTmp)->TFJ_CODENT)
		aTail(oResponse['Cliente'])['loja']     := AllTrim((cAliasTmp)->TFJ_LOJA)
		aTail(oResponse['Cliente'])['nome']     := AllTrim((cAliasTmp)->A1_NOME)
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

MÈtodo POST de retorno de Areas de acordo com as Filiais e/ou Area e/ou clientes selecionadas

Recebe cBody - JSON com filial, areas e clientes selecionada no filtro

Retorna Json (ARRAY) de contratos:

    "contrato": [
        {
            "codigo": "000000000000XYZ",
            "revisao": "00X"
        }
    ]

@author     ServiÁos
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST contrato WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Query mÈtodo contrato
cAliasTmp := qryFormer(oParamBody, "contrato")

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Contrato'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Contrato'], JsonObject():New())
		aTail(oResponse['Contrato'])['codigo']  := AllTrim((cAliasTmp)->TFJ_CONTRT)
		aTail(oResponse['Contrato'])['revisao'] := AllTrim((cAliasTmp)->TFJ_CONREV)
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de retorno de Areas de acordo com as Filiais e/ou Area e/ou 
clientes e/ou contratos selecionados

Recebe cBody - JSON com filial, areas, clientes e contratos selecionada no filtro

Retorna Json (ARRAY) de contratos:

    "localidade": [
        {
            "codigo": "00000001",
            "descricao": "TOTVS MATRIZ",
            "filcusto": "D MG 01",
            "ccusto": "CC0000001"
        }
    ]

@author     ServiÁos
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST localidade WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Query mÈtodo localidade
cAliasTmp := qryFormer(oParamBody, "localidade")

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Localidade'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Localidade'], JsonObject():New())
		aTail(oResponse['Localidade'])['codigo']    := AllTrim((cAliasTmp)->ABS_LOCAL)
		aTail(oResponse['Localidade'])['descricao'] := EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		aTail(oResponse['Localidade'])['filcusto']  := AllTrim((cAliasTmp)->ABS_FILCC)
		aTail(oResponse['Localidade'])['ccusto']    := AllTrim((cAliasTmp)->ABS_CCUSTO)
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de retorno de Areas de acordo com as Filiais e/ou Area e/ou 
clientes e/ou localidade e/ou posto selecionadas

Recebe cBody - JSON com filial, areas, clientes e contratos selecionada no filtro

Retorna Json (ARRAY) de contratos:

    "Posto": [
        {
            "codigo": "000001",
            "produto": "000000000000001",
            "descricao": "SERVI«O DE VIGILANCIA"
        }
    ]
@author     ServiÁos
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST posto WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Query mÈtodo posto
cAliasTmp := qryFormer(oParamBody, "posto")

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Posto'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Posto'], JsonObject():New())
		aTail(oResponse['Posto'])['codigo']    := AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['Posto'])['produto']   := AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['Posto'])['descricao'] := EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de retorno de Areas de acordo com as Filiais e/ou Area e/ou 
clientes e/ou localidade e/ou posto selecionadas

    {
        "status": "Coberto",
        "nomefil": "Filial 01",
        "codposto": "000463",
        "produto": "000000000000002",
        "descprod": "SERVI«O DE VIGILANCIA",
        "perini": "20230101",
        "perfim": "20491231",
        "codarea": "000001",
        "descarea": "AREA 01",
        "codtec": "D MG 01 000055",
        "nomtec": "EFETIVO",
        "codmat": "000055",
        "codcli": "000001",
        "loja": "01",
        "nomcli": "TOTVS",
        "contrato": "000000000000199",
        "revisao": "002",
        "escala": "000001",
        "descescala": "5X2 08:00 AS 17:00",
        "codfuncao": "00003",
        "funcao": "VIGILANTE ARMADO",
        "periculosidade": "N„o Possui",
        "insalubridade": "N„o Possui"
    }

@author     Jack Junior
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST buscar WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cFuncao   := ""
Local cFilTMP   := ""
Local cNomeFil  := ""
Local cDataIni  := ""
Local cDataFim  := ""
Local lIncManut := .F.

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP  := oParamBody['filial']
cDataIni := oParamBody['dataIni']
cDataFim := oParamBody['dataFim']

//Nome da filial
cNomeFil := FwFilialName(,cFilTMP)

//Query mÈtodo posto
cAliasTmp := qryFormer(oParamBody, "busca")

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Busca'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//DescriÁ„o da FunÁ„o do posto:
		cFuncao := Posicione("SRJ",1,xFilial("SRJ", cFilTMP)+(cAliasTmp)->TFF_FUNCAO,"RJ_DESC")

		//Checa se existe manutenÁ„o sem substituto no posto:
		lIncManut := ExistIncon(cFilTMP, (cAliasTmp)->TFJ_CONTRT, (cAliasTmp)->TFF_COD, cDataIni, cDataFim)

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Busca'], JsonObject():New())

		//STATUS DO POSTO
		If lIncManut
			aTail(oResponse['Busca'])['status']   := "Inconsistencia"
		Else
			aTail(oResponse['Busca'])['status']   := "Coberto"
		EndIf

		//NOME FILIAL
		aTail(oResponse['Busca'])['nomefil']   := EncodeUtf8(AllTrim(cNomeFil))
		//POSTO
		aTail(oResponse['Busca'])['codposto']   := AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['Busca'])['produto']    := AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['Busca'])['descprod']   := EncodeUtf8(AllTrim((cAliasTmp)->B1_DESC))
		//FUNCIONARIO
		aTail(oResponse['Busca'])['codtec']     := AllTrim((cAliasTmp)->AA1_CODTEC)
		aTail(oResponse['Busca'])['nomtec']     := EncodeUtf8(AllTrim((cAliasTmp)->AA1_NOMTEC))
		aTail(oResponse['Busca'])['codmat']     := AllTrim((cAliasTmp)->AA1_CDFUNC)
		//CLIENTE
		aTail(oResponse['Busca'])['codcli']     := AllTrim((cAliasTmp)->TFJ_CODENT)
		aTail(oResponse['Busca'])['loja']       := AllTrim((cAliasTmp)->TFJ_LOJA)
		aTail(oResponse['Busca'])['nomcli']     := EncodeUtf8(AllTrim((cAliasTmp)->A1_NOME))
		//CONTRATO
		aTail(oResponse['Busca'])['contrato']   := AllTrim((cAliasTmp)->TFJ_CONTRT)
		aTail(oResponse['Busca'])['revisao']    := AllTrim((cAliasTmp)->TFJ_CONREV)
		//FUN«√O E ESCALA
		aTail(oResponse['Busca'])['escala']     := AllTrim((cAliasTmp)->TFF_ESCALA)
		aTail(oResponse['Busca'])['descescala'] := EncodeUtf8(AllTrim((cAliasTmp)->TDW_DESC))
		aTail(oResponse['Busca'])['codfuncao']  := AllTrim((cAliasTmp)->TFF_FUNCAO)
		aTail(oResponse['Busca'])['funcao']     := AllTrim(cFuncao)
		aTail(oResponse['Busca'])['sequencia']  := ((cAliasTmp)->TGY_SEQ)
		//C”DIGO LOCAL ABS
		aTail(oResponse['Busca'])['codabs']  := ((cAliasTmp)->TFL_LOCAL)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Funcion·rios novos

@Param cFil - Filial selecionada no front end

@author     Jack Junior
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET novoAtendente WSRECEIVE cFil WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cABBID    := ""
Local cJoinABS  := ""
Local cJoinTFJ  := ""
Local cJoinTFL  := ""
Local cJoinSA1  := ""
Local cJoinSRA  := ""
Local cJoinTGY  := ""
Local cJoinSQG  := ""
Local cJoinSQS  := ""
Local cJoinCN9  := ""
Local cJoinTGS  := ""
Local cJoinSRJ  := ""
Local cJoinAA0  := ""
Local cWhereAA1 := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cABBID  := "% ABB.ABB_IDCFAL = CN9.CN9_NUMERO || ABQ.ABQ_ITEM || 'CN9' %"

cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL",  "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFF", "TFJ", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL" , "TFJ", "SA1", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL",  "AA1", "SRA", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "AA1", "TGY", cFilTMP, "JOIN")
cJoinSQG  := JoinSQL(lMultFil, "SQG.QG_FILIAL",  "SRA", "SQG", cFilTMP, "JOIN")
cJoinSQS  := JoinSQL(lMultFil, "SQS.QS_FILIAL",  "SQG", "SQS", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL",  "SRA", "SRJ", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cJoinAA0  := JoinSQL(lMultFil, "AA0.AA0_FILIAL", "ABS", "AA0", cFilTMP, "JOIN")
cWhereAA1 := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "AA1", "AA1", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT DISTINCT AA1.AA1_CODTEC, AA1.AA1_NOMTEC, SRA.RA_MAT, SRA.RA_ADMISSA, SRJ.RJ_FUNCAO, 
            SRJ.RJ_DESC, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, AB.ABS_LOCAL, AB.ABS_DESCRI, TFF.TFF_COD, 
            TFF.TFF_PERINI, TGS.TGS_COD, TGS.TGS_DESCRI, AA1.AA1_FONE, AA1.AA1_REGIAO,
            TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV, TFL.TFL_CODIGO
    FROM %table:AA1% AA1
        LEFT JOIN %table:SRA% SRA //Funcion·rios
            ON %exp:cJoinSRA%
	        	AND SRA.RA_MAT = AA1.AA1_CDFUNC
            AND SRA.%NotDel%
        LEFT JOIN %table:SRJ% SRJ //FunÁ„o
            ON %exp:cJoinSRJ%
	        	AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC
            AND SRJ.%NotDel%
        LEFT JOIN %table:TGY% TGY //TGY - ALOCA«√O
            ON %exp:cJoinTGY%
	        	AND TGY.TGY_ATEND = AA1.AA1_CODTEC
            AND TGY.%NotDel%
        LEFT JOIN %table:SQG% SQG //CURRÕCULO - RS
            ON %exp:cJoinSQG%
            AND SQG.QG_MAT = SRA.RA_MAT
            AND SQG.%NotDel%
        LEFT JOIN %table:SQS% SQS //RECRUTAMENTO E SELE«√O
            ON %exp:cJoinSQS%
            AND SQS.QS_VAGA = SQG.QG_VAGA
            AND SQS.%NotDel%
        LEFT JOIN %table:TFF% TFF //Posto - Contrato
            ON TFF.TFF_FILIAL = SQS.QS_FILTFF
	        	AND TFF.TFF_COD = SQS.QS_CODTFF
            AND TFF.%NotDel%
        LEFT JOIN %table:TFJ% TFJ //OrÁamento
            ON %exp:cJoinTFJ%
            AND TFJ.TFJ_CONTRT = TFF.TFF_CONTRT
            AND TFJ.TFJ_CONREV = TFF.TFF_CONREV
            AND TFJ.TFJ_STATUS = '1'
            AND TFJ.%NotDel%
        LEFT JOIN %table:CN9% CN9 //Contrato
            ON %exp:cJoinCN9%
            AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT
            AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
            AND CN9.CN9_SITUAC = '05'
            AND CN9.%NotDel%
        LEFT JOIN %table:TFL% TFL //Local - Contrato
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO 
            AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
            AND TFL.%NotDel%
        LEFT JOIN %table:ABS% AB //Local - Cadastro
            ON %exp:cJoinABS%
            AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
            AND AB.%NotDel%
        LEFT JOIN %table:TGS% TGS //¡rea de Supervis„o
            ON %exp:cJoinTGS%
	        AND TGS.TGS_COD = AB.ABS_CODSUP
            AND TGS.%NotDel%
        LEFT JOIN %table:SA1% SA1 //Clientes
            ON %exp:cJoinSA1%
            AND SA1.A1_COD = TFJ.TFJ_CODENT
            AND SA1.A1_LOJA = TFJ.TFJ_LOJA
            AND SA1.%NotDel%
        LEFT JOIN %table:AA0% AA0 //Base Operacional - AA0_FILIAL+AA0_CODIGO
            ON %exp:cJoinAA0%
            AND AA0.AA0_CODIGO = AB.ABS_BASEOP
            AND AA0.%NotDel% 
    WHERE %exp:cWhereAA1%
			AND AA1.AA1_ALOCA = '1'
            AND TGY.TGY_ATEND IS NULL //N√O POSSUI AGENDA !
            AND AA1.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['NovoAtendente'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['NovoAtendente'], JsonObject():New())

		aTail(oResponse['NovoAtendente'])['codtec']     := AllTrim((cAliasTmp)->AA1_CODTEC)
		aTail(oResponse['NovoAtendente'])['nomtec']     := EncodeUTF8(AllTrim((cAliasTmp)->AA1_NOMTEC))
		aTail(oResponse['NovoAtendente'])['codmat']     := AllTrim((cAliasTmp)->RA_MAT)
		aTail(oResponse['NovoAtendente'])['admissao']   := AllTrim((cAliasTmp)->RA_ADMISSA)
		aTail(oResponse['NovoAtendente'])['funcao']     := AllTrim((cAliasTmp)->RJ_FUNCAO)
		aTail(oResponse['NovoAtendente'])['descfunc']   := EncodeUTF8(AllTrim((cAliasTmp)->RJ_DESC))
		aTail(oResponse['NovoAtendente'])['codcliente'] := AllTrim((cAliasTmp)->A1_COD)
		aTail(oResponse['NovoAtendente'])['cliloja']    := AllTrim((cAliasTmp)->A1_LOJA)
		aTail(oResponse['NovoAtendente'])['clinome']    := AllTrim((cAliasTmp)->A1_NOME)
		aTail(oResponse['NovoAtendente'])['codlocal']   := AllTrim((cAliasTmp)->ABS_LOCAL)
		aTail(oResponse['NovoAtendente'])['desclocal']  := EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		aTail(oResponse['NovoAtendente'])['codposto']   := AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['NovoAtendente'])['iniposto']   := AllTrim((cAliasTmp)->TFF_PERINI)
		aTail(oResponse['NovoAtendente'])['codarea']    := AllTrim((cAliasTmp)->TGS_COD)
		aTail(oResponse['NovoAtendente'])['descarea']   := EncodeUTF8(AllTrim((cAliasTmp)->TGS_DESCRI))
		aTail(oResponse['NovoAtendente'])['telatend']   := AllTrim((cAliasTmp)->AA1_FONE)
		aTail(oResponse['NovoAtendente'])['regiaoatend']:= IIF(!Empty((cAliasTmp)->AA1_REGIAO),FWGetSX5('A2',(cAliasTmp)->AA1_REGIAO)[1,4],"")
		aTail(oResponse['NovoAtendente'])['contrato']   := AllTrim((cAliasTmp)->TFJ_CONTRT)
		aTail(oResponse['NovoAtendente'])['revisao']    := AllTrim((cAliasTmp)->TFJ_CONREV)
		aTail(oResponse['NovoAtendente'])['codtff']     := AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['NovoAtendente'])['codtfl']     := AllTrim((cAliasTmp)->TFL_CODIGO)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Funcion·rios alocados na reserva

@Param cFil - Filial selecionada no front end
        cData - Data selecionada no front end

oResponse - Json Object:

{
    "resAtendente": [
        {
            "codtec": "D0MG0010F00020",
            "nomtec": "MARIA JOS…",
            "codmat": "",
            "admissao": "",
            "funcao": "",
            "descfunc": "",
            "codcliente": "000001",
            "cliloja": "01",
            "clinome": "TOTVS",
            "codlocal": "00000003",
            "desclocal": "TOTVS BH",
            "codposto": "000089",
            "iniposto": "20230101",
            "codarea": "",
            "descarea": ""
        }
    ]
}

@author     Jack Junior
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET resAtendente WSRECEIVE cFil, cData WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cDate     := ""
Local cJoinABS  := ""
Local cJoinTFJ  := ""
Local cJoinTFL  := ""
Local cJoinSA1  := ""
Local cJoinSRA  := ""
Local cJoinTGY  := ""
Local cJoinSQG  := ""
Local cJoinSQS  := ""
Local cJoinCN9  := ""
Local cJoinTGS  := ""
Local cJoinSRJ  := ""
Local cWhereAA1 := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cDate := self:cData

//Tratamento de multifilial:
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL",  "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFF", "TFJ", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL" , "TFJ", "SA1", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL",  "AA1", "SRA", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "AA1", "TGY", cFilTMP, "JOIN")
cJoinSQG  := JoinSQL(lMultFil, "SQG.QG_FILIAL",  "SRA", "SQG", cFilTMP, "JOIN")
cJoinSQS  := JoinSQL(lMultFil, "SQS.QS_FILIAL",  "SQG", "SQS", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL",  "SRA", "SRJ", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TGY", "TFF", cFilTMP, "JOIN")
cWhereAA1 := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "AA1", "AA1", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT AA1.AA1_CODTEC, AA1.AA1_NOMTEC, SRA.RA_MAT, SRA.RA_ADMISSA, SRJ.RJ_FUNCAO,;
           SRJ.RJ_DESC, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, AB.ABS_LOCAL, AB.ABS_DESCRI,;
           TFF.TFF_COD, TFF.TFF_PERINI, TGS.TGS_COD, TGS.TGS_DESCRI, TGY.TGY_ATEND, TFJ.TFJ_CODIGO
    FROM %table:AA1% AA1
        LEFT JOIN %table:SRA% SRA //Funcion·rios
            ON %exp:cJoinSRA%
	        AND SRA.RA_MAT = AA1.AA1_CDFUNC
            AND SRA.%NotDel%
        LEFT JOIN %table:SRJ% SRJ //FunÁ„o/
            ON %exp:cJoinSRJ%
	        AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC
            AND SRJ.%NotDel%
        LEFT JOIN %table:TGY% TGY //TGY - ALOCA«√O
            ON %exp:cJoinTGY%
	        AND TGY.TGY_ATEND = AA1.AA1_CODTEC
            AND TGY.%NotDel%
        LEFT JOIN %table:TFF% TFF //Posto - Contrato
            ON %exp:cJoinTFF%
	        AND TFF.TFF_COD = TGY.TGY_CODTFF
            AND TFF.%NotDel%
        LEFT JOIN %table:TFL% TFL //Local - Contrato
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
            AND TFL.%NotDel%
        LEFT JOIN %table:TFJ% TFJ //OrÁamento
            ON %exp:cJoinTFJ%
            AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
            AND TFJ.TFJ_STATUS = '1'
            AND TFJ.%NotDel%
        LEFT JOIN %table:ABS% AB //Local - Cadastro
            ON %exp:cJoinABS%
            AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
            AND AB.%NotDel%
        LEFT JOIN %table:TGS% TGS //¡rea de Supervis„o
            ON %exp:cJoinTGS%
	        AND TGS.TGS_COD = AB.ABS_CODSUP
            AND TGS.%NotDel%
        LEFT JOIN %table:SA1% SA1 //Clientes
            ON %exp:cJoinSA1%
            AND SA1.A1_COD = TFJ.TFJ_CODENT
            AND SA1.A1_LOJA = TFJ.TFJ_LOJA
            AND SA1.%NotDel%
    WHERE %exp:cWhereAA1%
            AND TGY.TGY_RESTEC = '1' //TGY RESERVA T…CNICA
            AND (TGY.TGY_DTINI <= %exp:cDate%
            AND TGY.TGY_DTFIM >= %exp:cDate%)
            AND AA1.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['resAtendente'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['resAtendente'], JsonObject():New())

		aTail(oResponse['resAtendente'])['codtec']     := AllTrim((cAliasTmp)->AA1_CODTEC)
		aTail(oResponse['resAtendente'])['nomtec']     := EncodeUTF8(AllTrim((cAliasTmp)->AA1_NOMTEC))
		aTail(oResponse['resAtendente'])['codmat']     := AllTrim((cAliasTmp)->RA_MAT)
		aTail(oResponse['resAtendente'])['admissao']   := AllTrim((cAliasTmp)->RA_ADMISSA)
		aTail(oResponse['resAtendente'])['funcao']     := AllTrim((cAliasTmp)->RJ_FUNCAO)
		aTail(oResponse['resAtendente'])['descfunc']   := EncodeUTF8(AllTrim((cAliasTmp)->RJ_DESC))
		aTail(oResponse['resAtendente'])['codcliente'] := AllTrim((cAliasTmp)->A1_COD)
		aTail(oResponse['resAtendente'])['cliloja']    := AllTrim((cAliasTmp)->A1_LOJA)
		aTail(oResponse['resAtendente'])['clinome']    := AllTrim((cAliasTmp)->A1_NOME)
		aTail(oResponse['resAtendente'])['codorc']     := AllTrim((cAliasTmp)->TFJ_CODIGO)
		aTail(oResponse['resAtendente'])['codlocal']   := AllTrim((cAliasTmp)->ABS_LOCAL)
		aTail(oResponse['resAtendente'])['desclocal']  := EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		aTail(oResponse['resAtendente'])['codposto']   := AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['resAtendente'])['iniposto']   := AllTrim((cAliasTmp)->TFF_PERINI)
		aTail(oResponse['resAtendente'])['codarea']    := AllTrim((cAliasTmp)->TGS_COD)
		aTail(oResponse['resAtendente'])['descarea']   := EncodeUTF8(AllTrim((cAliasTmp)->TGS_DESCRI))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de OrÁamentos de Reserva tÈcnica

@Param cFil - Filial selecionada no front end

oResponse - Json Object:

{
    "resOrc": [
        {
            "codorc": "00000000047"
        },
        {
            "codorc": "00000000050"
        }
    ]
}

@author     Jack Junior
@since      03/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET resOrc WSRECEIVE cFil WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cWhereTFJ := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil

//Tratamento de multifilial:
cWhereTFJ := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFJ", "TFJ", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TFJ.TFJ_CODIGO
    FROM %table:TFJ% TFJ
    WHERE %exp:cWhereTFJ%
            AND TFJ.TFJ_RESTEC = '1' //TGY RESERVA T…CNICA
            AND TFJ.TFJ_STATUS = '1' //ATIVO
            AND TFJ.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['resOrc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['resOrc'], JsonObject():New())

		aTail(oResponse['resOrc'])['codorc']     := AllTrim((cAliasTmp)->TFJ_CODIGO)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de OrÁamentos de Reserva tÈcnica

@Param cFil - Filial selecionada no front end
        cOrc - CÛdigo do OrÁamento de Reserva selecionado no front end

oResponse - Json Object:

{
    "resLoc": [
        {
            "codtfl": "000074",
            "codloc": "00000001",
            "descloc": "TOTVS MATRIZ",
            "filcc": "D MG 01",
            "ccusto": "CC0000001"
        }
    ]
}

@author     Jack Junior
@since      03/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET resLoc WSRECEIVE cFil, cOrc WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodOrc   := ""
Local cJoinABS  := ""
Local cWhereTFL := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cCodOrc := self:cOrc

//Tratamento de multifilial:
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL",  "TFL", "ABS", cFilTMP, "JOIN")
cWhereTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFL", "TFL", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TFL.TFL_CODIGO, TFL.TFL_LOCAL, AB.ABS_DESCRI, AB.ABS_FILCC, AB.ABS_CCUSTO
    FROM %table:TFL% TFL
        INNER JOIN %table:ABS% AB //Local - Cadastro
            ON %exp:cJoinABS%
            AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
            AND AB.%NotDel%
    WHERE %exp:cWhereTFL%
            AND TFL.TFL_CODPAI = %exp:cCodOrc%
            AND TFL.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['resLoc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['resLoc'], JsonObject():New())

		aTail(oResponse['resLoc'])['codtfl']    := AllTrim((cAliasTmp)->TFL_CODIGO)
		aTail(oResponse['resLoc'])['codloc']    := AllTrim((cAliasTmp)->TFL_LOCAL)
		aTail(oResponse['resLoc'])['descloc']   := EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		aTail(oResponse['resLoc'])['filcc']     := AllTrim((cAliasTmp)->ABS_FILCC)
		aTail(oResponse['resLoc'])['ccusto']    := AllTrim((cAliasTmp)->ABS_CCUSTO)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Postos de um local de reserva

@Param cFil - Filial selecionada no front end
        cLoc - CÛdigo do Local selecionado no front end

oResponse - Json Object:

{
    "resPostos": [
        {
            "codtff": "000084",
            "codprod": "000000000000002",
            "descprod": "SERVIùO DE VIGILANCIA",
            "codescala": "000002",
            "descescala": "12X36 06:00 AS 18:00"
        }
    ]
}

@author     Jack Junior
@since      03/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET resPostos WSRECEIVE cFil, cLoc WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodLocal := ""
Local cJoinSB1  := ""
Local cJoinTDW  := ""
Local cWhereTFF := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cCodLocal := self:cLoc

//Tratamento de multifilial:
cJoinSB1  := JoinSQL(lMultFil, "SB1.B1_FILIAL",  "TFF", "SB1", cFilTMP, "JOIN")
cJoinTDW  := JoinSQL(lMultFil, "TDW.TDW_FILIAL", "TFF", "TDW", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TFF.TFF_COD, TFF.TFF_PRODUT, TFF.TFF_ESCALA, SB1.B1_DESC, TDW.TDW_DESC
    FROM %table:TFF% TFF
        INNER JOIN %table:SB1% SB1 //Produtos
            ON %exp:cJoinSB1%
	        AND SB1.B1_COD = TFF.TFF_PRODUT
            AND SB1.%NotDel%
        INNER JOIN %table:TDW% TDW //Escalas
            ON %exp:cJoinTDW%
	        AND TDW.TDW_COD = TFF.TFF_ESCALA
            AND TDW.%NotDel%
    WHERE %exp:cWhereTFF%
	        AND TFF.TFF_CODPAI = %exp:cCodLocal%
            AND TFF.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['resPostos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['resPostos'], JsonObject():New())

		aTail(oResponse['resPostos'])['codtff']     := AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['resPostos'])['codprod']    := AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['resPostos'])['descprod']   := EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))
		aTail(oResponse['resPostos'])['codescala']  := AllTrim((cAliasTmp)->TFF_ESCALA)
		aTail(oResponse['resPostos'])['descescala'] := EncodeUTF8(AllTrim((cAliasTmp)->TDW_DESC))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Motivos de alocaÁ„o para reserva

@Param cFil - Filial selecionada no front end

oResponse - Json Object:

{
    "resMotivos": [
        {
            "codmotivo": "008",
            "descmotivo": "RESERVA",
            "tipomotivo": "1"
        }
    ]
}

@author     Jack Junior
@since      03/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET resMotivos WSRECEIVE cFil WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cWhereTCU := ""
Local cCondRes  := "1"
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil

cWhereTCU := JoinSQL(lMultFil, "TCU.TCU_FILIAL", "TCU", "TCU", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TCU.TCU_COD, TCU.TCU_DESC
    FROM %table:TCU% TCU
    WHERE %exp:cWhereTCU%
	        AND TCU.TCU_RESTEC = %exp:cCondRes%
            AND TCU.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['resMotivos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['resMotivos'], JsonObject():New())

		aTail(oResponse['resMotivos'])['codmotivo']     := AllTrim((cAliasTmp)->TCU_COD)
		aTail(oResponse['resMotivos'])['descmotivo']    := EncodeUTF8(AllTrim((cAliasTmp)->TCU_DESC))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno das Sequencias de uma escala

@Param cFil - Filial selecionada no front end
        cLoc - CÛdigo do Local selecionado no front end

oResponse - Json Object:

{
    "resSequencias": [
        {
            "codtdx": "000002",
            "codturno": "002",
            "sequencia": "01"
        },
        {
            "codtdx": "000003",
            "codturno": "002",
            "sequencia": "02"
        }
    ]
}

@author     Jack Junior
@since      03/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET resSequencias WSRECEIVE cFil, cEscala WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodEscala:= ""
Local cWhereTDX := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cCodEscala := self:cEscala

//Tratamento de multifilial:
cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TDX.TDX_COD, TDX.TDX_TURNO, TDX.TDX_SEQTUR
    FROM %table:TDX% TDX
    WHERE %exp:cWhereTDX%
	        AND TDX.TDX_CODTDW = %exp:cCodEscala%
            AND TDX.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['resSequencias'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['resSequencias'], JsonObject():New())

		aTail(oResponse['resSequencias'])['codtdx']     := AllTrim((cAliasTmp)->TDX_COD)
		aTail(oResponse['resSequencias'])['codturno']   := AllTrim((cAliasTmp)->TDX_TURNO)
		aTail(oResponse['resSequencias'])['sequencia']  := AllTrim((cAliasTmp)->TDX_SEQTUR)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Postos de um local de reserva

@Param cFil - Filial selecionada no front end
        cLoc - CÛdigo do Local selecionado no front end

oResponse - Json Object:

{
    "resBase": [
        {
            "codbase": "000002",
            "descbase": "BASE OPERACIONAL SP",
            "armazem": "01",
            "centrocusto": "CC0000001"
        }
    ]
}

@author     Jack Junior
@since      06/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET resBase WSRECEIVE cFil, cLoc WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cCodLocal := ""
Local cFilTMP   := ""
Local cJoinAA0  := ""
Local cWhereABS := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cCodLocal := self:cLoc

//Tratamento de multifilial:
cJoinAA0  := JoinSQL(lMultFil, "AA0.AA0_FILIAL", "ABS", "AA0", cFilTMP, "JOIN")
cWhereABS := JoinSQL(lMultFil, "AB.ABS_FILIAL", "ABS", "ABS", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT AA0.AA0_CODIGO, AA0.AA0_DESCRI, AA0.AA0_LOCPAD, AA0.AA0_CCUSTO
    FROM %table:ABS% AB
        INNER JOIN %table:AA0% AA0 //Base Operacional - AA0_FILIAL+AA0_CODIGO
            ON %exp:cJoinAA0%
            AND AA0.AA0_CODIGO = AB.ABS_BASEOP
            AND AA0.%NotDel%
    WHERE %exp:cWhereABS% //Local cadastro - ABS_FILIAL+ABS_LOCAL
	        AND AB.ABS_LOCAL = %exp:cCodLocal%
            AND AB.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['resBase'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['resBase'], JsonObject():New())

		aTail(oResponse['resBase'])['codbase']      := AllTrim((cAliasTmp)->AA0_CODIGO)
		aTail(oResponse['resBase'])['descbase']     := EncodeUTF8(AllTrim((cAliasTmp)->AA0_DESCRI))
		aTail(oResponse['resBase'])['armazem']      := AllTrim((cAliasTmp)->AA0_LOCPAD)
		aTail(oResponse['resBase'])['centrocusto']  := AllTrim((cAliasTmp)->AA0_CCUSTO)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de retorno de Contratos e status

@Param Body ->  {
                    "cFil":"D MG 01",
                    "dataIni":"20231101",
                    "dataFim":"20231131",
                    "base":[{"value":"000001"},{"value":"000002"},{"value":"000003"}]
                }

oResponse - Json Object:

                {
                    "impContrato": [
                        {
                            "codcontrato": "000000000000195",
                            "codrevisao": "",
                            "codcliente": "000001",
                            "nomecliente": "TOTVS",
                            "lojacliente": "01",
                            "status": ""
                        },
                        {
                            "codcontrato": "000000000000197",
                            "codrevisao": "",
                            "codcliente": "000001",
                            "nomecliente": "TOTVS",
                            "lojacliente": "01",
                            "status": "INCONSISTENCIA"
                        }
                    ]
                }

@author     Jack Junior
@since      06/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST impContrato WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local aBase     := ""
Local cAliasTmp := GetNextAlias()
Local cBody     := Self:GetContent()
Local cDataIni  := ""
Local cDataFim  := ""
Local cFilTMP   := ""
Local cInBase   := "%%"
Local cStatus   := ""
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
cDataIni    := oParamBody['dataIni']
cDataFim    := oParamBody['dataFim']
aBase       := oParamBody['base']

//Monta o In da condiÁ„o de acordo com a quantidade de registros no Array
cInBase := whereSQL("BASE", aBase)

//AdiÁ„o de %% Embedded
cInBase := sqlEmbeded(cInBase)

//Tratamento de multifilial:
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL", "TFJ", "SA1", cFilTMP, "JOIN")
cJoinAA0  := JoinSQL(lMultFil, "AA0.AA0_FILIAL", "ABS", "AA0", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cWhereTFJ := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFJ", "TFJ", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TFJ.TFJ_CONTRT,  
            TFJ.TFJ_CONREV,  	
            SUM(TFF_QTPREV) QTD_PREV,  
            MAX(COALESCE(B.QTD_TGY,0)) QTD_TGY,
            TFJ.TFJ_CODENT,
            TFJ.TFJ_LOJA,
            SA1.A1_NOME
    //CONTRATOS
    FROM %table:TFJ% TFJ
        //LOCAL - CONTRATO
        INNER JOIN %table:TFL% TFL  
                ON (%exp:cJoinTFL%
                    AND TFL.TFL_CODPAI = TFJ_CODIGO  
                    AND TFL.%NotDel%)
        //RH/POSTO - CONTRATO
        INNER JOIN %table:TFF% TFF 
                ON (%exp:cJoinTFF%
                    AND TFF.TFF_CODPAI = TFL.TFL_CODIGO  
                    AND TFF.%NotDel%)
        //LOCAL - CADASTRO
        INNER JOIN %table:ABS% AB 
                ON (%exp:cJoinABS%
                    AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
                    AND AB.%NotDel%)
        //BASE OPERACIONAL
        INNER JOIN %table:AA0% AA0
                ON %exp:cJoinAA0%
                AND AA0.AA0_CODIGO = AB.ABS_BASEOP
                AND AA0.%NotDel% 
         //Cliente - Cadastro
        INNER JOIN %table:SA1% SA1
                ON %exp:cJoinSA1%
                AND SA1.A1_COD = TFJ.TFJ_CODENT
                AND SA1.A1_LOJA = TFJ.TFJ_LOJA
                AND SA1.%NotDel%
        LEFT JOIN
            (
                SELECT  
                    TFJ_CONTRT,  
                    TFJ_CONREV,  	
                    COUNT(TGY_CODTFF) QTD_TGY,
                    TGY.TGY_CODTFF,
                    TGY.TGY_SEQ,
                    TGY.TGY_GRUPO,
                    TFJ.TFJ_CODENT,
                    TFJ.TFJ_LOJA,
                    SA1.A1_NOME
                //CONTRATOS
                FROM %table:TFJ% TFJ
                    //LOCAL - CONTRATO  
                    INNER JOIN %table:TFL% TFL   
                        ON (%exp:cJoinTFL% 
                            AND TFL.TFL_CODPAI = TFJ_CODIGO  
                            AND TFL.%NotDel%)
                    //RH/POSTO - CONTRATO 
                    INNER JOIN %table:TFF% TFF   
                        ON (%exp:cJoinTFF% 
                            AND TFF.TFF_CODPAI = TFL.TFL_CODIGO  
                            AND TFF.%NotDel%)
                    //LOCAL - CADASTRO
                    INNER JOIN %table:ABS% AB   
                        ON (%exp:cJoinABS%
                            AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
                            AND AB.%NotDel%)
                    //BASE OPERACIONAL
                    INNER JOIN %table:AA0% AA0
                            ON %exp:cJoinAA0%
                            AND AA0.AA0_CODIGO = AB.ABS_BASEOP
                            AND AA0.%NotDel%
                    //Rel. Escala x Func. Efetivo - TGY
                    INNER JOIN %table:TGY% TGY   
                        ON (%exp:cJoinTGY%
                            AND TGY.TGY_CODTFF = TFF.TFF_COD
                            AND TGY.TGY_FILIAL = TFF.TFF_FILIAL	
                            AND TGY.%NotDel%)
                    //Cliente - Cadastro
                    INNER JOIN %table:SA1% SA1
                            ON %exp:cJoinSA1%
                            AND SA1.A1_COD = TFJ.TFJ_CODENT
                            AND SA1.A1_LOJA = TFJ.TFJ_LOJA
                            AND SA1.%NotDel%
                WHERE %exp:cWhereTFJ%  
                    AND TFJ.TFJ_STATUS = '1' 
                    AND TGY.TGY_DTINI <= %exp:cDataFim% AND TGY.TGY_DTFIM >= %exp:cDataIni%
                    AND TFJ.%NotDel% 
                GROUP BY
                    TFJ_CONTRT,  
                    TFJ_CONREV,
                    TGY.TGY_CODTFF,
                    TGY.TGY_SEQ,
                    TGY.TGY_GRUPO,
                    TFJ.TFJ_CODENT,
                    TFJ.TFJ_LOJA,
                    SA1.A1_NOME
            ) B
        ON B.TFJ_CONTRT = TFJ.TFJ_CONTRT
            AND B.TFJ_CONREV = TFJ.TFJ_CONREV
    WHERE %exp:cWhereTFJ% 
        AND TFJ.TFJ_CONTRT <> ' '
        AND TFJ.TFJ_STATUS = '1' 
        AND (TFF.TFF_DTENCE > %exp:cDataIni% OR TFF_DTENCE = ' ')
        AND TFF.TFF_GERVAG != '2'
        AND TFJ.%NotDel% 
        %exp:cInBase%
    GROUP BY
        TFJ.TFJ_CONTRT,  
        TFJ.TFJ_CONREV,
        TFJ.TFJ_CODENT,
        TFJ.TFJ_LOJA,
        SA1.A1_NOME
    ORDER BY
        TFJ.TFJ_CONTRT,  
        TFJ.TFJ_CONREV
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['impContrato'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())

		If (cAliasTmp)->QTD_TGY < (cAliasTmp)->QTD_PREV
			//recebe flag de posto VAGO:
			cStatus := "VAGO"
		Else
			//recebe flag de posto COBERTO:
			cStatus := "COBERTO"
		EndIf

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['impContrato'], JsonObject():New())

		aTail(oResponse['impContrato'])['codcontrato']  := AllTrim((cAliasTmp)->TFJ_CONTRT)
		aTail(oResponse['impContrato'])['codrevisao']   := AllTrim((cAliasTmp)->TFJ_CONREV)
		aTail(oResponse['impContrato'])['codcliente']   := AllTrim((cAliasTmp)->TFJ_CODENT)
		aTail(oResponse['impContrato'])['nomecliente']  := AllTrim((cAliasTmp)->TFJ_LOJA)
		aTail(oResponse['impContrato'])['lojacliente']  := AllTrim((cAliasTmp)->A1_NOME)
		aTail(oResponse['impContrato'])['status']       := cStatus

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Locais e condiÁ„o (vago/coberto) de acordo com um contrato selecionado

@Param  cFil - Filial 
        cContrato - Contrato
        cRevisao -Revis„o
        cData1 - Data inicial
        cData2 - Data final

oResponse - Json Object:

{
    "impLocais": [
        {
            "codtfl": "000346",
            "codlocal": "00000001",
            "desclocal": "TOTVS MATRIZ",
            "status": "VAGO"
        }
    ]
}

@author     Jack Junior
@since      06/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET impLocais WSRECEIVE cFil, cContrato, cRevisao, cData1, cData2 WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodContr := ""
Local cCodRevis := ""
Local cDataIni  := ""
Local cDataFim  := ""
Local lMultFil  := IsMultFil()

cFilTMP   := self:cFil
cCodContr := self:cContrato
cCodRevis := self:cRevisao
cDataIni  := self:cData1
cDataFim  := self:cData2

//Tratamento de multifilial:
cJoinAA0  := JoinSQL(lMultFil, "AA0.AA0_FILIAL", "ABS", "AA0", cFilTMP, "JOIN")
cWhereABS := JoinSQL(lMultFil, "AB.ABS_FILIAL", "ABS", "ABS", cFilTMP, "WHERE")

//Tratamento de multifilial:
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL" , "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL" , "TFJ", "SA1", cFilTMP, "JOIN")
cJoinAA0  := JoinSQL(lMultFil, "AA0.AA0_FILIAL", "ABS", "AA0", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cWhereTFJ := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFL", "TFL", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT 	TFL.TFL_LOCAL,
            TFL.TFL_CODIGO,
            SUM(TFF_QTPREV) QTD_PREV,  
            MAX(COALESCE(B.QTD_TGY,0)) QTD_TGY,
            AB.ABS_DESCRI
    //LOCAL - CONTRATO
    FROM %table:TFL% TFL  
        //RH/POSTO - CONTRATO
        INNER JOIN %table:TFF% TFF 
                ON (%exp:cJoinTFF%
                    AND TFF.TFF_CODPAI = TFL.TFL_CODIGO  
                    AND TFF.%NotDel%)
        //LOCAL - CADASTRO
        INNER JOIN %table:ABS% AB 
                ON (%exp:cJoinABS%
                    AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
                    AND AB.%NotDel%)
        LEFT JOIN
            (
                SELECT  TFL.TFL_LOCAL,
                        TFL.TFL_CODIGO,
                        COUNT(TGY_CODTFF) QTD_TGY,
                        TGY.TGY_CODTFF,
                        TGY.TGY_SEQ,
                        TGY.TGY_GRUPO,
                        AB.ABS_DESCRI
                //CONTRATOS
                FROM %table:TFL% TFL   

                    //RH/POSTO - CONTRATO 
                    INNER JOIN %table:TFF% TFF   
                        ON (%exp:cJoinTFF% 
                            AND TFF.TFF_CODPAI = TFL.TFL_CODIGO  
                            AND TFF.%NotDel%)
                    //LOCAL - CADASTRO
                    INNER JOIN %table:ABS% AB   
                        ON (%exp:cJoinABS%
                            AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
                            AND AB.%NotDel%)
                    //Rel. Escala x Func. Efetivo - TGY
                    INNER JOIN %table:TGY% TGY   
                        ON (%exp:cJoinTGY%
                            AND TGY.TGY_CODTFF = TFF.TFF_COD
                            AND TGY.TGY_FILIAL = TFF.TFF_FILIAL	
                            AND TGY.%NotDel%)

                WHERE %exp:cWhereTFJ%  
                    AND TFL.TFL_CONTRT = %exp:cCodContr%
                    AND TFL.TFL_CONREV = %exp:cCodRevis% 
                    AND TGY.TGY_DTINI <= %exp:cDataFim% AND TGY.TGY_DTFIM >= %exp:cDataIni%
                    AND TFL.%NotDel% 
                GROUP BY
                    TFL.TFL_CODIGO,
                    TFL.TFL_LOCAL,
                    TGY.TGY_CODTFF,
                    TGY.TGY_SEQ,
                    TGY.TGY_GRUPO,
                    AB.ABS_DESCRI
            ) B
        ON B.TFL_LOCAL = TFL.TFL_LOCAL
    WHERE %exp:cWhereTFJ% 
        AND TFL.TFL_CONTRT = %exp:cCodContr%
        AND TFL.TFL_CONREV = %exp:cCodRevis%  
        AND (TFF.TFF_DTENCE > %exp:cDataIni% OR TFF_DTENCE = ' ')
        AND TFF.TFF_GERVAG != '2'
        AND TFL.%NotDel% 

    GROUP BY
        TFL.TFL_CODIGO,
        TFL.TFL_LOCAL,
        AB.ABS_DESCRI
    ORDER BY
        TFL.TFL_CODIGO
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['impLocais'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())

		If (cAliasTmp)->QTD_TGY < (cAliasTmp)->QTD_PREV
			//recebe flag de posto VAGO:
			cStatus := "VAGO"
		Else
			//recebe flag de posto COBERTO:
			cStatus := "COBERTO"
		EndIf

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['impLocais'], JsonObject():New())

		aTail(oResponse['impLocais'])['codtfl']     := AllTrim((cAliasTmp)->TFL_CODIGO)
		aTail(oResponse['impLocais'])['codlocal']   := AllTrim((cAliasTmp)->TFL_LOCAL)
		aTail(oResponse['impLocais'])['desclocal']  := EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		aTail(oResponse['impLocais'])['status']     := cStatus

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de postos e condiÁ„o (vago/coberto) de acordo com um local selecionado

@Param  cFil - Filial 
        cLoc - cÛdigo da TFL (local)
        cData1 - data inicial do range
        cData2 - data final do range

oResponse - Json Object:

{
    "impPostos": [
        {
            "codposto": "000434",
            "descposto": "SERVIùO DE BOMBEIRO",
            "status": "VAGO",
            "escala": "000002",
            "qtdvenda": 1,
            "qtdprevista": 2
        }
    ]
}

@author     Jack Junior
@since      06/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET impPostos WSRECEIVE cFil, cTFL, cData1, cData2 WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodTFL   := ""
Local cDataIni  := ""
Local cDataFim  := ""
Local cFuncao   := ""
Local cJoinSB1  := ""
Local cJoinTGY  := ""
Local cWhereTFF := ""
Local lMultFil  := IsMultFil()

cFilTMP     := self:cFil
cCodTFL     := self:cTFL
cDataIni    := self:cData1
cDataFim    := self:cData2

//Tratamento de multifilial:
cJoinSB1  := JoinSQL(lMultFil, "SB1.B1_FILIAL" , "TFF", "SB1", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT 	TFF.TFF_COD,
            TFF.TFF_FUNCAO,
            TFF.TFF_PRODUT,
            TFF.TFF_QTPREV,  
            MAX(COALESCE(B.QTD_TGY,0)) QTD_TGY,
            SB1.B1_COD,
            SB1.B1_DESC,
            TFF.TFF_ESCALA,
            TFF.TFF_QTDVEN
    //POSTOS
    FROM %table:TFF% TFF  
        //CADASTRO DE PRODUTOS
        INNER JOIN %table:SB1% SB1 
	        ON (%exp:cJoinSB1%
            AND SB1.B1_COD = TFF.TFF_PRODUT
            AND SB1.%NotDel%)
        LEFT JOIN
            (
                SELECT TFF.TFF_COD,
                        TFF.TFF_FUNCAO,
                        TFF.TFF_PRODUT,
                        COUNT(TGY_CODTFF) QTD_TGY,
                        TGY.TGY_CODTFF,
                        TGY.TGY_SEQ,
                        TGY.TGY_GRUPO,
                        SB1.B1_DESC,
                        SB1.B1_COD
                //POSTOS
                FROM %table:TFF% TFF   
                    //PRODUTOS
                    INNER JOIN %table:SB1% SB1
                        ON (%exp:cJoinSB1%
                        AND SB1.B1_COD = TFF.TFF_PRODUT
                        AND SB1.%NotDel%)
                    //Rel. Escala x Func. Efetivo - TGY
                    INNER JOIN %table:TGY% TGY   
                        ON (%exp:cJoinTGY%
                            AND TGY.TGY_CODTFF = TFF.TFF_COD
                            AND TGY.%NotDel%)

                WHERE %exp:cWhereTFF%  
                    AND TFF.TFF_CODPAI = %exp:cCodTFL%
                    AND TGY.TGY_DTINI <= %exp:cDataFim% AND TGY.TGY_DTFIM >= %exp:cDataIni%
                    AND TFF.%NotDel% 
                GROUP BY
                    TFF.TFF_COD,
                    TFF.TFF_FUNCAO,
                    TFF.TFF_PRODUT,
                    TGY.TGY_CODTFF,
                    TGY.TGY_SEQ,
                    TGY.TGY_GRUPO,
                    SB1.B1_DESC,
                    SB1.B1_COD
            ) B
        ON B.TFF_COD = TFF.TFF_COD
    WHERE %exp:cWhereTFF% 
        AND TFF.TFF_CODPAI = %exp:cCodTFL%
        AND (TFF.TFF_DTENCE > %exp:cDataIni% OR TFF_DTENCE = ' ')
        AND TFF.TFF_GERVAG != '2'
        AND TFF.%NotDel% 
    GROUP BY
        TFF.TFF_QTPREV,
        TFF.TFF_FUNCAO,
        TFF.TFF_COD,
        TFF.TFF_PRODUT,
        SB1.B1_DESC,
        TFF.TFF_ESCALA,
        TFF.TFF_QTDVEN,
        SB1.B1_COD
    ORDER BY
        TFF.TFF_COD
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['impPostos'] := {}

If (cAliasTmp)->(! Eof())

	cFuncao := Posicione("SRJ",1,xFilial('SRJ',cFilTMP)+((cAliasTmp)->TFF_FUNCAO),"RJ_DESC")


	While (cAliasTmp)->(! Eof())

		If (cAliasTmp)->QTD_TGY < (cAliasTmp)->TFF_QTPREV
			//recebe flag de posto VAGO:
			cStatus := "VAGO"
		Else
			//recebe flag de posto COBERTO:
			cStatus := "COBERTO"
		EndIf

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['impPostos'], JsonObject():New())

		aTail(oResponse['impPostos'])['codposto']   := AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['impPostos'])['descposto']  := EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))
		aTail(oResponse['impPostos'])['descfuncao'] := EncodeUTF8(AllTrim(cFuncao))
		aTail(oResponse['impPostos'])['status']     := cStatus
		aTail(oResponse['impPostos'])['escala']     := AllTrim((cAliasTmp)->TFF_ESCALA)
		aTail(oResponse['impPostos'])['qtdvenda']   := (cAliasTmp)->TFF_QTDVEN
		aTail(oResponse['impPostos'])['qtdprevista']:= (cAliasTmp)->TFF_QTPREV
		aTail(oResponse['impPostos'])['codtff']     := (cAliasTmp)->TFF_COD

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de vagas de um posto e condiÁ„o (vago/coberto) de acordo com um local selecionado

@Param  cFil - Filial 
        cPosto - cÛdigo da TFF (Posto)
        cData1 - data inicial do range
        cData2 - data final do range

oResponse - Json Object:

{
    "impVagas": [
        {
            "codigo": "D MG 01 000053",
            "nome": "JACK JOHNSON",
            "dtini": "20231020",
            "dtfim": "20231030",
            "escala": "000002",
            "sequencia": "01"
        }
    ]
}

@author     Jack Junior
@since      06/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET impVagas WSRECEIVE cFil, cPosto, cData1, cData2 WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodTFF   := ""
Local cDataIni  := ""
Local cDataFim  := ""
Local cJoinAA1  := ""
Local cJoinTGY  := ""
Local cWhereTFF := ""
Local cTFFEscala:= ""
Local nAlocPrev := 0
Local nQtdVend  := 0
Local nX        := 0
Local nVagas    := 0
Local aAtendent := {}
Local lMultFil  := IsMultFil()

cFilTMP     := self:cFil
cCodTFF     := self:cPosto
cDataIni    := self:cData1
cDataFim    := self:cData2

//Tratamento de multifilial:
cJoinAA1  := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "TGY", "AA1", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
        SELECT AA1.AA1_NOMTEC,
                TFF.TFF_QTPREV,
                TFF.TFF_QTDVEN,
                TFF.TFF_ESCALA,
                TGY.TGY_ATEND,
                TGY.TGY_DTINI,
                TGY.TGY_DTFIM,
                TFF.TFF_COD,
                TGY.TGY_ESCALA,
                TGY.TGY_SEQ
        //POSTOS
        FROM %table:TFF% TFF  
                    //Rel. Escala x Func. Efetivo - TGY
                    INNER JOIN %table:TGY% TGY   
                        ON (%exp:cJoinTGY%
                            AND TGY.TGY_CODTFF = TFF.TFF_COD
                            AND TGY.%NotDel%)
                    //ATENDENTES
                    INNER JOIN %table:AA1% AA1   
                        ON (%exp:cJoinAA1%
                            AND AA1.AA1_CODTEC = TGY.TGY_ATEND 
                            AND AA1.%NotDel%)
        WHERE %exp:cWhereTFF% 
            AND TFF.TFF_COD = %exp:cCodTFF%
            AND TGY.TGY_DTINI <= %exp:cDataFim% AND TGY.TGY_DTFIM >= %exp:cDataIni%
            AND (TFF.TFF_DTENCE > %exp:cDataIni% OR TFF_DTENCE = ' ')
            AND TFF.TFF_GERVAG != '2'
            AND TFF.%NotDel% 

EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['impVagas'] := {}

If (cAliasTmp)->(! Eof())

	cTFFEscala:= (cAliasTmp)->TFF_ESCALA
	nQtdVend  := (cAliasTmp)->TFF_QTDVEN

	While (cAliasTmp)->(! Eof())

		AADD(aAtendent, {AllTrim((cAliasTmp)->TGY_ATEND),;
			EncodeUTF8(AllTrim((cAliasTmp)->AA1_NOMTEC)),;
			AllTrim((cAliasTmp)->TGY_DTINI),;
			AllTrim((cAliasTmp)->TGY_DTFIM),;
			AllTrim((cAliasTmp)->TGY_ESCALA),;
			AllTrim((cAliasTmp)->TGY_SEQ)})

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

nAlocPrev := Posicione("TFF",1,cFilTMP+cCodTFF,"TFF_QTPREV")

nVagas := nAlocPrev - Len(aAtendent)

If nVagas > 0
	For nX := 1 to nVagas
		AADD(aAtendent, {"VAGO","","","","",""})
	Next nX
EndIf

For nX := 1 To Len(aAtendent)
	//Monta o Objeto JSon a ser retornado:
	Aadd(oResponse['impVagas'], JsonObject():New())

	aTail(oResponse['impVagas'])['codigo']      := aAtendent[nX,1]
	aTail(oResponse['impVagas'])['nome']        := aAtendent[nX,2]
	aTail(oResponse['impVagas'])['dtini']       := aAtendent[nX,3]
	aTail(oResponse['impVagas'])['dtfim']       := aAtendent[nX,4]
	aTail(oResponse['impVagas'])['escala']      := aAtendent[nX,5]
	aTail(oResponse['impVagas'])['sequencia']   := aAtendent[nX,6]
Next nX

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de alocacao de orcamento de reserva

Recebe cBody - JSON

{
    "filial": "D MG 01 ",
    "escala": "000001",
    "posto": "000527",
    "atend": "D MG 01 000053",
    "grupo": 1,
    "dataIni": "0240103",
    "dataFim": "0240103",
    "seq": "01",
    "tipMov": "009"
}

@author     ServiÁos
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST alocRes WSREST MESAOPERACIONAL

Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()

Local oModel    := NIL
Local oMdlGRE   := NIL
Local oMdlRTE   := NIL

Local aAlocRES  := {}
Local aRetorno  := {}
Local cFilTMP   := ""
Local cEscala   := ""
Local cPosto    := ""
Local cAtend    := ""
Local nGrupo    := ""
Local cConFal   := ""
Local cDataIni  := ""
Local cDataFim  := ""
Local cSeq      := ""
Local cTipMov   := ""
Local cTipoAl   := ""
Local nX        := 0
Local nY        := 0
Local nAux      := 0
Local nPos      := 0
Local lContinua := .T. //Cancelar operacao
Local lAlocConf := .F. //Alocar apenas dias sem conflitos
Local lStatus   := .T.
Local cQry      := GetNextAlias()
Local cWhereTDX := ""
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIf

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
cEscala     := oParamBody['escala']
cPosto      := oParamBody['posto']
cAtend      := oParamBody['atend']
nGrupo      := oParamBody['grupo']
cDataIni    := oParamBody['dataIni']
cDataFim    := oParamBody['dataFim']
cSeq        := oParamBody['seq']
cTipMov     := oParamBody['tipMov']
cTipoAl     := '1'

oModel:= FWLoadModel("TECA190D")
oModel:SetOperation(3)
oModel:Activate()

oMdlGRE := oModel:GetModel("RESDETAIL")
oMdlRTE := oModel:GetModel("RTEDETAIL")

// Busca Conf Aloc
cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

BeginSQL Alias cQry
	SELECT COALESCE(TDX.TDX_COD,' ') CONFAL
	FROM %Table:TDX% TDX
	WHERE %Exp:cWhereTDX%
		AND TDX.TDX_CODTDW = %Exp:cEscala%
		AND TDX.TDX_SEQTUR = %Exp:cSeq%
		AND TDX.%NotDel%
EndSql

cConFal := (cQry)->(CONFAL)
(cQry)->(DbCloseArea())

// Carga do atendente / Orcamento / etc

oMdlGRE:LoadValue("GRE_FILIAL",cFilTMP)
oMdlGRE:LoadValue("GRE_ESCALA",cEscala)
oMdlGRE:LoadValue("GRE_CODTFF",cPosto)
oMdlGRE:LoadValue("GRE_CODTEC",cAtend)
oMdlGRE:LoadValue("GRE_GRUPO" ,nGrupo)
oMdlGRE:LoadValue("GRE_CONFAL",cConFal)
oMdlGRE:LoadValue("GRE_DTINI" ,stod(cDataIni))
oMdlGRE:LoadValue("GRE_DTFIM" ,stod(cDataFim))
oMdlGRE:LoadValue("GRE_SEQ"   ,cSeq)
oMdlGRE:LoadValue("GRE_TIPTCU",cTipMov)
oMdlGRE:LoadValue("GRE_TIPOAL",cTipoAl)

// Projetar aloc reserva

oMdlRTE:SetNoInsertLine(.F.)
oMdlRTE:SetNoDeleteLine(.F.)

oMdlRTE:ClearData()
oMdlRTE:InitLine()

If !EMPTY(oMdlGRE:GetValue("GRE_ESCALA"))
	AADD(aAlocRES, {})
	nAux := LEN(aAlocRES)
	aAlocRES[nAux] := GsAloc():New()
	If TecMultFil()
		aAlocRES[nAux]:defFil(oMdlGRE:GetValue("GRE_FILIAL"))
	EndIf
	aAlocRES[nAux]:defEscala(oMdlGRE:GetValue("GRE_ESCALA"))
	aAlocRES[nAux]:defPosto(oMdlGRE:GetValue("GRE_CODTFF"))
	aAlocRES[nAux]:defTec(oMdlGRE:GetValue("GRE_CODTEC"))
	aAlocRES[nAux]:defGrupo(oMdlGRE:GetValue("GRE_GRUPO"))
	aAlocRES[nAux]:defConfal(oMdlGRE:GetValue("GRE_CONFAL"))
	aAlocRES[nAux]:defDate(oMdlGRE:GetValue("GRE_DTINI"),oMdlGRE:GetValue("GRE_DTFIM"))
	aAlocRES[nAux]:defSeq(oMdlGRE:GetValue("GRE_SEQ"))
	aAlocRES[nAux]:defTpAloca(oMdlGRE:GetValue("GRE_TIPTCU"))
	aAlocRES[nAux]:defTpAlo(oMdlGRE:GetValue("GRE_TIPTCU"))
	aAlocRES[nAux]:defCob((oMdlGRE:GetValue("GRE_TIPOAL") == '2'))
	aAlocRES[nAux]:defResTec("1") //Reserva Tecnica

	If TecXHasEdH()
		aAlocRES[nAux]:defGeHor	({;
			{oMdlGRE:GetValue("GRE_ENTRA1"),;
			oMdlGRE:GetValue("GRE_SAIDA1")},;
			{oMdlGRE:GetValue("GRE_ENTRA2"),;
			oMdlGRE:GetValue("GRE_SAIDA2")},;
			{oMdlGRE:GetValue("GRE_ENTRA3"),;
			oMdlGRE:GetValue("GRE_SAIDA3")},;
			{oMdlGRE:GetValue("GRE_ENTRA4"),;
			oMdlGRE:GetValue("GRE_SAIDA4")}})
	EndIf
	aAlocRES[nAux]:projAloc()
	If !EMPTY( aAlocRES[nAux]:defMessage() )
		oMdlGRE:LoadValue("GRE_DETALH", LEFT(aAlocRES[nAux]:defMessage(), 185))
	Endif
	If aAlocRES[nAux]:getConfl()
		oMdlGRE:LoadValue("GRE_STATUS", "BR_PRETO")
	ElseIf aAlocRES[nAux]:temBloqueio() .OR. aAlocRES[nAux]:temAviso()
		oMdlGRE:LoadValue("GRE_STATUS", "BR_PINK")
	Else
		oMdlGRE:LoadValue("GRE_STATUS", "BR_AMARELO")
	EndIf

	For nY := 1 To LEN(aAlocRES[nAux]:getProj())
		If oMdlRTE:GetMaxLines() < LEN(aAlocRES[nAux]:getProj())
			oMdlRTE:SetMaxLine(LEN(aAlocRES[nAux]:getProj()))
		EndIf
		If nY != 1
			oMdlRTE:AddLine()
		EndIf
		oMdlRTE:LoadValue("RTE_SITABB", aAlocRES[nAux]:getProj()[nY][1])
		oMdlRTE:LoadValue("RTE_SITALO", At330ACLgS(aAlocRES[nAux]:getProj()[nY][11]))
		oMdlRTE:LoadValue("RTE_GRUPO", 	aAlocRES[nAux]:getProj()[nY][3])
		oMdlRTE:LoadValue("RTE_DATREF", aAlocRES[nAux]:getProj()[nY][4])
		oMdlRTE:LoadValue("RTE_DATA", 	aAlocRES[nAux]:getProj()[nY][5])
		oMdlRTE:LoadValue("RTE_SEMANA", aAlocRES[nAux]:getProj()[nY][6])
		oMdlRTE:LoadValue("RTE_ENTRADA",aAlocRES[nAux]:getProj()[nY][7])
		oMdlRTE:LoadValue("RTE_SAIDA", 	aAlocRES[nAux]:getProj()[nY][8])
		oMdlRTE:LoadValue("RTE_TIPO",	aAlocRES[nAux]:getProj()[nY][11])
		oMdlRTE:LoadValue("RTE_SEQ",	aAlocRES[nAux]:getProj()[nY][15])
		oMdlRTE:LoadValue("RTE_EXSABB", aAlocRES[nAux]:getProj()[nY][19])
		oMdlRTE:LoadValue("RTE_KEYTGY",	aAlocRES[nAux]:getProj()[nY][17])
		oMdlRTE:LoadValue("RTE_ITTGY",	aAlocRES[nAux]:getProj()[nY][18])
		oMdlRTE:LoadValue("RTE_TURNO",	aAlocRES[nAux]:getProj()[nY][14])
		oMdlRTE:LoadValue("RTE_ITEM", 	aAlocRES[nAux]:getProj()[nY][16])
		oMdlRTE:LoadValue("RTE_CODTEC",	aAlocRES[nAux]:getProj()[nY][9])
		oMdlRTE:LoadValue("RTE_NOMTEC",	aAlocRES[nAux]:getProj()[nY][10])
		oMdlRTE:LoadValue("RTE_TIPTCU",	aAlocRES[nAux]:getProj()[nY][24])
		oMdlRTE:LoadValue("RTE_DSCONF", LEFT(aAlocRES[nAux]:getProj()[nY][23],35))
	Next nY
EndIf

// Gravar aloc reserva

For nX := 1 To oMdlGRE:Length()
	oMdlGRE:GoLine(nX)
	If oMdlGRE:GetValue("GRE_STATUS") == "BR_PRETO"
		// nAviso := Aviso(STR0124,; //AtenÁ„o
		//         STR0125,; //"Um ou mais dias possuem conflito de alocaÁ„o. Deseja alocar todos os atendentes mesmo com os conflitos ou alocar apenas nos dias disponÌveis? Esta opÁ„o ser· aplicada em todos os atendentes."
		//         {STR0126,; //"Apenas disponiveis"
		//         STR0127,; //"Todos os dias"
		//         STR0128},2) //
		// If nAviso == 3 //Cancelar
		//     lContinua := .F.
		// ElseIf nAviso == 1 //Alocar mesmo com conflito
		//     lAlocConf := .T.
		// ElseIf nAviso == 2 //Alocar apenas dias sem conflitos
		//     lAlocConf := .F.
		// EndIf
		Exit
	EndIf
Next nX

For nX := 1 To oMdlGRE:Length()
	oMdlGRE:GoLine(nX)
	If oMdlGRE:GetValue("GRE_STATUS") == "BR_PINK"
		// lContinua := MsgYesNo(STR0123) //"Um ou mais atendentes possuem restriÁıes no perÌodo. Deseja continuar?"
		Exit
	EndIf
Next nX

If lContinua
	For nX := 1 To oMdlGRE:Length()
		nPos := 0
		oMdlGRE:GoLine(nX)
		For nY := 1 TO Len(aAlocRES)
			If VALTYPE(aAlocRES[nY]) == 'O' .AND.;
					aAlocRES[nY]:defCob() == (oMdlGRE:GetValue("GRE_TIPOAL") == '2') .AND.;
					aAlocRES[nY]:defEscala() == oMdlGRE:GetValue("GRE_ESCALA") .AND.;
					aAlocRES[nY]:defPosto() == oMdlGRE:GetValue("GRE_CODTFF") .AND.;
					aAlocRES[nY]:defSeq() == oMdlGRE:GetValue("GRE_SEQ") .AND.;
					aAlocRES[nY]:defTec() == oMdlGRE:GetValue("GRE_CODTEC") .AND.;
					aAlocRES[nY]:defGrupo() == oMdlGRE:GetValue("GRE_GRUPO") .AND.;
					aAlocRES[nY]:defConfal() == oMdlGRE:GetValue("GRE_CONFAL") .AND.;
					aAlocRES[nY]:defDate()[1] == oMdlGRE:GetValue("GRE_DTINI") .AND.;
					aAlocRES[nY]:defDate()[2] == oMdlGRE:GetValue("GRE_DTFIM")
				If TecXHasEdH()
					If aAlocRES[nY]:defGeHor()[1][1] == oMdlGRE:GetValue("GRE_ENTRA1") .AND.;
							aAlocRES[nY]:defGeHor()[1][2] == oMdlGRE:GetValue("GRE_SAIDA1") .AND.;
							aAlocRES[nY]:defGeHor()[2][1] == oMdlGRE:GetValue("GRE_ENTRA2") .AND.;
							aAlocRES[nY]:defGeHor()[2][2] == oMdlGRE:GetValue("GRE_SAIDA2") .AND.;
							aAlocRES[nY]:defGeHor()[3][1] == oMdlGRE:GetValue("GRE_ENTRA3") .AND.;
							aAlocRES[nY]:defGeHor()[3][2] == oMdlGRE:GetValue("GRE_SAIDA3") .AND.;
							aAlocRES[nY]:defGeHor()[4][1] == oMdlGRE:GetValue("GRE_ENTRA4") .AND.;
							aAlocRES[nY]:defGeHor()[4][2] == oMdlGRE:GetValue("GRE_SAIDA4")
						nPos := nY
						Exit
					Endif
				Else
					nPos := nY
					Exit
				EndIf
			EndIf
		Next nY
		If nPos > 0
			If !(oMdlGRE:isDeleted())
				lStatus := .F.
				aAlocRES[nPos]:alocaConflitos(lAlocConf)
				If aAlocRES[nPos]:gravaAloc()
					lStatus := .T.
					oMdlGRE:LoadValue("GRE_STATUS","BR_VERDE")
					// If !Empty(aAlocRES[nPos]:getLastSeq())
					// 	oMdlGRE:LoadValue("GRE_SEQ",aAlocRES[nPos]:getLastSeq())
					// EndIf
				Else
					oMdlGRE:LoadValue("GRE_STATUS","BR_LARANJA")
				EndIf
				oMdlGRE:LoadValue("GRE_DETALH",LEFT(aAlocRES[nPos]:defMessage(), 185))
				aAdd(aRetorno,{aAlocRES[nAux]:DDTINI, EncodeUtf8(aAlocRES[nAux]:CMESSAGE), lStatus})
			EndIf
			oMdlRTE:GoLine(1)
			oMdlRTE:ClearData()
			oMdlRTE:InitLine()
		EndIf
	Next nX

	For nX := 1 To LEN(aAlocRES)
		If VALTYPE(aAlocRES[nX]) == 'O'
			aAlocRES[nX]:destroy()
			aAlocRES[nX] := nil
		EndIf
	Next nX
	aAlocRES := {}
Else
	// MsgAlert(STR0122) //"OperaÁ„o Cancelada"
EndIf

oResponse['retorno'] := aRetorno

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de alocacao de orcamento de reserva

Recebe cBody - JSON

{
    "filial": "D MG 01 ",
    "escala": "000001",
    "posto": "000526",
    "atend": "D MG 01 000053",
    "grupo": 1,
    "dataIni": "0240104",
    "dataFim": "0240104",
    "seq": "01",
    "tipMov": "001"
}
    
@author     ServiÁos
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST alocEfe WSREST MESAOPERACIONAL

Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()

Local oModel    := NIL
Local oMdlLAC   := NIL
Local oMdlLGY   := NIL

Local aAlocLGY  := {}
Local aRetorno  := {}
Local cFilTMP   := ""
Local cEscala   := ""
Local cPosto    := ""
Local cAtend    := ""
Local nGrupo    := ""
Local cConFal   := ""
Local cDataIni  := ""
Local cDataFim  := ""
Local cSeq      := ""
Local cTipMov   := ""
Local cTipoAl   := ""
Local nX        := 0
Local nY        := 0
Local nAux      := 0
Local nPos      := 0
Local lContinua := .T. //Cancelar operacao
Local lAlocConf := .F. //Alocar apenas dias sem conflitos
Local lStatus   := .T.
Local cQry      := GetNextAlias()
Local cWhereTDX := ""
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIf

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
cEscala     := oParamBody['escala']
cPosto      := oParamBody['posto']
cAtend      := oParamBody['atend']
nGrupo      := oParamBody['grupo']
cDataIni    := oParamBody['dataIni']
cDataFim    := oParamBody['dataFim']
cSeq        := oParamBody['seq']
cTipMov     := oParamBody['tipMov']
cTipoAl     := '1'

oModel:= FWLoadModel("TECA190D")
oModel:SetOperation(3)
oModel:Activate()

oMdlLAC := oModel:GetModel("LACDETAIL")
oMdlLGY := oModel:GetModel("LGYDETAIL")

// Busca Conf Aloc
cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

BeginSQL Alias cQry
	SELECT COALESCE(TDX.TDX_COD,' ') CONFAL
	FROM %Table:TDX% TDX
	WHERE %Exp:cWhereTDX%
		AND TDX.TDX_CODTDW = %Exp:cEscala%
		AND TDX.TDX_SEQTUR = %Exp:cSeq%
		AND TDX.%NotDel%
EndSql

cConFal := (cQry)->(CONFAL)
(cQry)->(DbCloseArea())

// Carga do atendente / Orcamento / etc

oMdlLGY:LoadValue("LGY_FILIAL",cFilTMP)
oMdlLGY:LoadValue("LGY_ESCALA",cEscala)
oMdlLGY:LoadValue("LGY_CODTFF",cPosto)
oMdlLGY:LoadValue("LGY_CODTEC",cAtend)
oMdlLGY:LoadValue("LGY_GRUPO" ,nGrupo)
oMdlLGY:LoadValue("LGY_CONFAL",cConFal)
oMdlLGY:LoadValue("LGY_DTINI" ,stod(cDataIni))
oMdlLGY:LoadValue("LGY_DTFIM" ,stod(cDataFim))
oMdlLGY:LoadValue("LGY_SEQ"   ,cSeq)
oMdlLGY:LoadValue("LGY_TIPTCU",cTipMov)
oMdlLGY:LoadValue("LGY_TIPOAL",cTipoAl)

// Projetar aloc

oMdlLAC:SetNoInsertLine(.F.)
oMdlLAC:SetNoDeleteLine(.F.)

oMdlLAC:ClearData()
oMdlLAC:InitLine()

If !EMPTY(oMdlLGY:GetValue("LGY_ESCALA"))
	AADD(aAlocLGY, {})
	nAux := LEN(aAlocLGY)
	aAlocLGY[nAux] := GsAloc():New()
	If TecMultFil()
		aAlocLGY[nAux]:defFil(oMdlLGY:GetValue("LGY_FILIAL"))
	EndIf
	aAlocLGY[nAux]:defEscala(oMdlLGY:GetValue("LGY_ESCALA"))
	aAlocLGY[nAux]:defPosto(oMdlLGY:GetValue("LGY_CODTFF"))
	aAlocLGY[nAux]:defTec(oMdlLGY:GetValue("LGY_CODTEC"))
	aAlocLGY[nAux]:defGrupo(oMdlLGY:GetValue("LGY_GRUPO"))
	aAlocLGY[nAux]:defConfal(oMdlLGY:GetValue("LGY_CONFAL"))
	aAlocLGY[nAux]:defDate(oMdlLGY:GetValue("LGY_DTINI"),oMdlLGY:GetValue("LGY_DTFIM"))
	aAlocLGY[nAux]:defSeq(oMdlLGY:GetValue("LGY_SEQ"))
	aAlocLGY[nAux]:defTpAlo(oMdlLGY:GetValue("LGY_TIPTCU"))

	aAlocLGY[nAux]:defCob((oMdlLGY:GetValue("LGY_TIPOAL") == '2'))

	If TGY->( ColumnPos("TGY_PROXFE")) > 0
		aAlocLGY[nAux]:defProxFe(oMdlLGY:GetValue("LGY_PROXFE"))
	EndIf
	If TecXHasEdH()
		aAlocLGY[nAux]:defGeHor	({;
			{oMdlLGY:GetValue("LGY_ENTRA1"),;
			oMdlLGY:GetValue("LGY_SAIDA1")},;
			{oMdlLGY:GetValue("LGY_ENTRA2"),;
			oMdlLGY:GetValue("LGY_SAIDA2")},;
			{oMdlLGY:GetValue("LGY_ENTRA3"),;
			oMdlLGY:GetValue("LGY_SAIDA3")},;
			{oMdlLGY:GetValue("LGY_ENTRA4"),;
			oMdlLGY:GetValue("LGY_SAIDA4")};
			})
	EndIf
	aAlocLGY[nAux]:projAloc()
	// If !EMPTY( aAlocLGY[nAux]:defMessage() )
	//     If Empty(cMsg)
	//         oMdlLGY:LoadValue("LGY_DETALH", LEFT(aAlocLGY[nAux]:defMessage(), 185))
	//     Else
	//         oMdlLGY:LoadValue("LGY_DETALH", LEFT(aAlocLGY[nAux]:defMessage() + " ## " + cMsg  , 185 ))
	//     EndIf
	// EndIf
	If aAlocLGY[nAux]:getConfl()
		oMdlLGY:LoadValue("LGY_STATUS", "BR_PRETO")
	ElseIf aAlocLGY[nAux]:temBloqueio() .OR. aAlocLGY[nAux]:temAviso()
		oMdlLGY:LoadValue("LGY_STATUS", "BR_PINK")
	ElseIf !(aAlocLGY[nAux]:PermAlocarInter())
		oMdlLGY:LoadValue("LGY_STATUS", "BR_CANCEL")
	Else
		oMdlLGY:LoadValue("LGY_STATUS", "BR_AMARELO")
	EndIf

	For nY := 1 To LEN(aAlocLGY[nAux]:getProj())
		If oMdlLAC:GetMaxLines() < LEN(aAlocLGY[nAux]:getProj())
			oMdlLAC:SetMaxLine(LEN(aAlocLGY[nAux]:getProj()))
		EndIf
		If nY != 1
			oMdlLAC:AddLine()
		EndIf
		oMdlLAC:LoadValue("LAC_SITABB", aAlocLGY[nAux]:getProj()[nY][1])
		oMdlLAC:LoadValue("LAC_SITALO", At330ACLgS(aAlocLGY[nAux]:getProj()[nY][11]))
		oMdlLAC:LoadValue("LAC_GRUPO", 	aAlocLGY[nAux]:getProj()[nY][3])
		oMdlLAC:LoadValue("LAC_DATREF", aAlocLGY[nAux]:getProj()[nY][4])
		oMdlLAC:LoadValue("LAC_DATA", 	aAlocLGY[nAux]:getProj()[nY][5])
		oMdlLAC:LoadValue("LAC_SEMANA", aAlocLGY[nAux]:getProj()[nY][6])
		oMdlLAC:LoadValue("LAC_ENTRADA",aAlocLGY[nAux]:getProj()[nY][7])
		oMdlLAC:LoadValue("LAC_SAIDA", 	aAlocLGY[nAux]:getProj()[nY][8])
		oMdlLAC:LoadValue("LAC_TIPO",	aAlocLGY[nAux]:getProj()[nY][11])
		oMdlLAC:LoadValue("LAC_SEQ",	aAlocLGY[nAux]:getProj()[nY][15])
		oMdlLAC:LoadValue("LAC_EXSABB", aAlocLGY[nAux]:getProj()[nY][19])
		oMdlLAC:LoadValue("LAC_KEYTGY",	aAlocLGY[nAux]:getProj()[nY][17])
		oMdlLAC:LoadValue("LAC_ITTGY",	aAlocLGY[nAux]:getProj()[nY][18])
		oMdlLAC:LoadValue("LAC_TURNO",	aAlocLGY[nAux]:getProj()[nY][14])
		oMdlLAC:LoadValue("LAC_ITEM", 	aAlocLGY[nAux]:getProj()[nY][16])
		oMdlLAC:LoadValue("LAC_CODTEC",	aAlocLGY[nAux]:getProj()[nY][9])
		oMdlLAC:LoadValue("LAC_NOMTEC",	aAlocLGY[nAux]:getProj()[nY][10])
		oMdlLAC:LoadValue("LAC_DSCONF", LEFT(aAlocLGY[nAux]:getProj()[nY][23],35))
	Next nY
EndIf

// Gravar aloc

For nX := 1 To oMdlLGY:Length()
	oMdlLGY:GoLine(nX)
	If oMdlLGY:GetValue("LGY_STATUS") == "BR_PRETO"
		// If !lPermConfl
		// 	IF !(lContinua := MsgYesNo(STR0511)) //"Existem dias com conflito de alocaÁ„o e o usu·rio n„o possui permiss„o para alocaÁ„o. Alocar apenas os dias sem conflito? (Esta opÁ„o ser· aplicada em todos os atendentes)"
		// 		Help(,,"NOALOC",,STR0212,1,0)	//"OperaÁ„o de alocaÁ„o cancelada."
		// 	EndIf
		// 	lAlocConf := .F.
		// Else
		// 	nAviso := Aviso(STR0187,; //"AtenÁ„o"
		// 			STR0512,; //"Um ou mais dias possuem conflito de alocaÁ„o. Deseja alocar todos os atendentes mesmo com os conflitos ou alocar apenas nos dias disponÌveis? Esta opÁ„o ser· aplicada em todos os atendentes."
		// 			{STR0288,; //"Apenas disponiveis"
		// 			STR0287,; //"Todos os dias"
		// 			STR0338},2) //"Cancelar"
		// 	If nAviso == 3 //Cancelar
		// 		lContinua := .F.
		// 	ElseIf nAviso == 1 //Alocar mesmo com conflito
		// 		lAlocConf := .T.
		// 	ElseIf nAviso == 2 //Alocar apenas dias sem conflitos
		// 		lAlocConf := .F.
		// 	EndIf
		// EndIf
		Exit
	EndIf
Next nX

For nX := 1 To oMdlLGY:Length()
	oMdlLGY:GoLine(nX)
	If oMdlLGY:GetValue("LGY_STATUS") == "BR_PINK"
		// lContinua := MsgYesNo(STR0513) //"Um ou mais atendentes possuem restriÁıes no perÌodo. Deseja continuar?"
		Exit
	EndIf
Next nX

If lContinua
	For nX := 1 To oMdlLGY:Length()
		nPos := 0
		oMdlLGY:GoLine(nX)
		For nY := 1 TO Len(aAlocLGY)
			If VALTYPE(aAlocLGY[nY]) == 'O' .AND.;
					aAlocLGY[nY]:defCob() == (oMdlLGY:GetValue("LGY_TIPOAL") == '2') .AND.;
					aAlocLGY[nY]:defEscala() == oMdlLGY:GetValue("LGY_ESCALA") .AND.;
					aAlocLGY[nY]:defPosto() == oMdlLGY:GetValue("LGY_CODTFF") .AND.;
					aAlocLGY[nY]:defSeq() == oMdlLGY:GetValue("LGY_SEQ") .AND.;
					aAlocLGY[nY]:defTec() == oMdlLGY:GetValue("LGY_CODTEC") .AND.;
					aAlocLGY[nY]:defGrupo() == oMdlLGY:GetValue("LGY_GRUPO") .AND.;
					aAlocLGY[nY]:defConfal() == oMdlLGY:GetValue("LGY_CONFAL") .AND.;
					aAlocLGY[nY]:defDate()[1] == oMdlLGY:GetValue("LGY_DTINI") .AND.;
					aAlocLGY[nY]:defDate()[2] == oMdlLGY:GetValue("LGY_DTFIM")
				If TecXHasEdH()
					If aAlocLGY[nY]:defGeHor()[1][1] == oMdlLGY:GetValue("LGY_ENTRA1") .AND.;
							aAlocLGY[nY]:defGeHor()[1][2] == oMdlLGY:GetValue("LGY_SAIDA1") .AND.;
							aAlocLGY[nY]:defGeHor()[2][1] == oMdlLGY:GetValue("LGY_ENTRA2") .AND.;
							aAlocLGY[nY]:defGeHor()[2][2] == oMdlLGY:GetValue("LGY_SAIDA2") .AND.;
							aAlocLGY[nY]:defGeHor()[3][1] == oMdlLGY:GetValue("LGY_ENTRA3") .AND.;
							aAlocLGY[nY]:defGeHor()[3][2] == oMdlLGY:GetValue("LGY_SAIDA3") .AND.;
							aAlocLGY[nY]:defGeHor()[4][1] == oMdlLGY:GetValue("LGY_ENTRA4") .AND.;
							aAlocLGY[nY]:defGeHor()[4][2] == oMdlLGY:GetValue("LGY_SAIDA4")
						nPos := nY
						Exit
					Endif
				Else
					nPos := nY
					Exit
				EndIf
			EndIf
		Next nY
		If nPos > 0
			If !(oMdlLGY:isDeleted())
				lStatus := .F.
				aAlocLGY[nPos]:alocaConflitos(lAlocConf)
				nPosLGYPrj := nPos
				If aAlocLGY[nPos]:gravaAloc()
					lStatus := .T.
					oMdlLGY:LoadValue("LGY_STATUS","BR_VERDE")
					If !Empty(aAlocLGY[nPos]:getLastSeq())
						oMdlLGY:LoadValue("LGY_SEQ",aAlocLGY[nPos]:getLastSeq())
					EndIf
				Else
					oMdlLGY:LoadValue("LGY_STATUS","BR_LARANJA")
				EndIf
				oMdlLGY:LoadValue("LGY_DETALH",LEFT(aAlocLGY[nPos]:defMessage(), 185))
				aAdd(aRetorno,{aAlocLGY[nAux]:DDTINI, EncodeUtf8(aAlocLGY[nAux]:CMESSAGE), lStatus})
			EndIf
			oMdlLAC:GoLine(1)
			oMdlLAC:ClearData()
			oMdlLAC:InitLine()
		EndIf
	Next nX

	For nX := 1 To LEN(aAlocLGY)
		If VALTYPE(aAlocLGY[nX]) == 'O'
			aAlocLGY[nX]:destroy()
			aAlocLGY[nX] := nil
			nPosLGYPrj := 0
		EndIf
	Next nX
	aAlocLGY := {}
EndIf

oResponse['retorno'] := aRetorno

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de ConfiguraÁ„o da Escala

@Param cFil - Filial selecionada no front end
       cTurno - CÛdigo do turno selecionado no front end
       cSeqTur - CÛdigo do turno selecionado no front end

projEsc?cFil=D MG 01 &cTurno=001&cSeqTur=01

@return

{
    "dias": [
        {
            "diaSemana": "1",
            "horaInicio": "08:00",
            "horaFinal": "12:30",
            "status": "1"
        }
    ]
}

@author     ServiÁos
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD Get projEsc WSRECEIVE cFil, cEscala, cSeqTur WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local aRet      := {}
Local cFilTMP   := ""
Local cEsc      := ""
Local cSeq      := ""
Local nX        := 0

cFilTMP  := self:cFil
cEsc     := self:cEscala
cSeq     := self:cSeqTur

cFilAnt  := cFilTMP

//ProjeÁ„o dos dias da semana:
aRet := projSemana(cFilTMP, cEsc, cSeq)

oResponse['dias'] := {}

For nX := 1 To Len(aRet)
	Aadd(oResponse['dias'], JsonObject():New())
	aTail(oResponse['dias'])['diaSemana']  := aRet[nX,1]
	aTail(oResponse['dias'])['horaInicio'] := aRet[nX,2]
	aTail(oResponse['dias'])['horaFinal']  := aRet[nX,3]
	aTail(oResponse['dias'])['status']     := aRet[nX,4]
Next nX

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

// //------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno das agendas de um atendente de acordo com um range de datas e posto

@Param  cFil - Filial 
        cPosto - cÛdigo da TFF (Posto)
        cAtend - CÛdigo do Atendente
        cData1 - data inicial
        cData2 - data final

oResponse - Json Object:

@author     Jack Junior
@since      13/11/2023
/*/
// //------------------------------------------------------------------------------

WSMETHOD GET agendasABB WSRECEIVE cFil, cPosto, cAtend, cData1, cData2 WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local cAliasABN := ""
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cAtendente:= ""
Local dDataDe   := ""
Local dDataAte  := ""
Local cCodTFF   := ""
Local cJoinTDV  := ""
Local cJoinABQ  := ""
Local cJoinSB1  := ""
Local cJoinABS  := ""
Local cJoinTCU  := ""
Local cWhereABB := ""
Local cTipoMV   := ""
Local cTCU_DESC := PadR("Outros Tipos", TamSx3("TCU_DESC")[1])
Local cStatus   := ""
Local lMultFil  := IsMultFil()
Local cDataAux	:= ""  //Data auxiliar (ABB_DTINI) para saber se trocou o PerÌodo
Local cPeriodo	:= "1" //N˙mero de ordenaÁ„o do da agenda PerÌodo 
Local cPerMax	:= "0"
Local nPerMax	:= 0
Local nX		:= 0
Local nPos		:= 1

cFilTMP     := self:cFil
cAtendente	:= self:cAtend
dDataDe     := self:cData1
dDataAte   	:= self:cData2
cCodTFF     := self:cPosto

//Tratamento de multifilial:
cJoinTDV  := JoinSQL(lMultFil, "TDV.TDV_FILIAL" , "ABB", "TDV", cFilTMP, "JOIN")
cJoinABQ  := JoinSQL(lMultFil, "ABQ.ABQ_FILIAL" , "ABB", "ABQ", cFilTMP, "JOIN")
cJoinSB1  := JoinSQL(lMultFil, "SB1.B1_FILIAL" , "ABQ", "SB1", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL" , "ABB", "ABS", cFilTMP, "JOIN")
cJoinTCU  := JoinSQL(lMultFil, "TCU.TCU_FILIAL" , "ABB", "TCU", cFilTMP, "JOIN")
cWhereABB := JoinSQL(lMultFil, "ABB.ABB_FILIAL", "ABB", "ABB", cFilTMP, "WHERE")

//AGENDAS ABB
BeginSql Alias cAliasTmp
    SELECT TDV.TDV_DTREF,
            SB1.B1_DESC,
            AB.ABS_DESCRI,
			ABB.ABB_MANUT,
            ABB.ABB_TIPOMV,
            ABB.ABB_ATIVO,
            ABB.ABB_CODIGO,
            ABB.ABB_HRINI,
            ABB.ABB_HRFIM,
            ABB.ABB_HRCHIN,
            ABB.ABB_HRCOUT,
            ABB.ABB_DTINI,
            ABB.ABB_DTFIM,
            ABB.ABB_FILIAL,
            ABB.R_E_C_N_O_ REC,
            ABB.ABB_ATENDE,
            ABB.ABB_CHEGOU,
            ABB.ABB_IDCFAL,
            ABQ.ABQ_CODTFF,
            ABB.ABB_OBSERV,
            CASE WHEN TCU.TCU_DESC IS NOT NULL THEN TCU.TCU_DESC ELSE %exp:cTCU_DESC% END TCU_DESC
    FROM %table:ABB% ABB 
        INNER JOIN %table:TDV% TDV
            ON %exp:cJoinTDV%
            AND TDV.TDV_CODABB = ABB.ABB_CODIGO
            AND TDV.%NotDel%
        INNER JOIN %table:ABQ% ABQ
            ON %exp:cJoinABQ%
            AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
            AND ABQ.%NotDel%
        INNER JOIN %table:SB1% SB1 
            ON %exp:cJoinSB1% 
            AND SB1.B1_COD = ABQ.ABQ_PRODUT
            AND SB1.%NotDel%
        INNER JOIN %table:ABS% AB 
            ON %exp:cJoinABS% 
            AND ABB.ABB_LOCAL = AB.ABS_LOCAL
            AND AB.%NotDel%
        LEFT JOIN %table:TCU% TCU 
            ON %exp:cJoinTCU%
            AND TCU.TCU_COD = ABB.ABB_TIPOMV
            AND TCU.%NotDel%
    WHERE %exp:cWhereABB% 
        AND TDV.TDV_DTREF >= %exp:dDataDe% 
        AND TDV.TDV_DTREF <= %exp:dDataAte% 
        AND ABB.ABB_CODTEC = %exp:cAtendente%
        AND ABQ.ABQ_CODTFF = %exp:cCodTFF%
        AND ABB.%NotDel%
    ORDER BY 
        TDV.TDV_DTREF,
        ABB.ABB_DTINI,
        ABB.ABB_HRINI
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['agendasABB'] := {}
oResponse['periodoMax'] := {}

While !(cAliasTmp)->(EOF())

	cTipoMV := (cAliasTmp)->(ABB_TIPOMV)

	If (cAliasTmp)->(ABB_ATENDE) == '1' .AND. (cAliasTmp)->(ABB_CHEGOU) == 'S'
		cStatus := "Agenda atendida"
	ElseIf (cAliasTmp)->(ABB_ATIVO) == '2' .OR. ExisteABR((cAliasTmp)->(ABB_CODIGO),(cAliasTmp)->(ABB_FILIAL))
		cStatus := "Agenda com ManutenÁ„o"
	ElseIf cTipoMV == '004'
		cStatus := "Excedente"
	ElseIf cTipoMV == '002'
		cStatus := "Cobertura"
	ElseIf cTipoMV == '001'
		cStatus := "Efetivo"
	ElseIf cTipoMV == '003'
		cStatus := "Apoio"
	ElseIf cTipoMV == '006'
		cStatus := "Curso"
	ElseIf cTipoMV == '007'
		cStatus := "Cortesia"
	ElseIf cTipoMV == '005'
		cStatus := "Treinamento"
	Else
		cStatus := "Outros Tipos"
	EndIf

	//LÛgica para saber o PerÌodo das agendas:
	If cDataAux == (cAliasTmp)->(ABB_DTINI)
		cPeriodo := Soma1(cPeriodo)
	Else
		cPeriodo := '1'
	EndIf

	//Coleta a quantidade m·xima de PerÌodos:
	If cPerMax < cPeriodo
		cPerMax := cPeriodo
	EndIf

	cDataAux := (cAliasTmp)->(ABB_DTINI)

	//Monta o Objeto JSon a ser retornado:
	Aadd(oResponse['agendasABB'], JsonObject():New())

	aTail(oResponse['agendasABB'])['status']    :=  EncodeUtf8(AllTrim(cStatus))
	aTail(oResponse['agendasABB'])['dataref']   :=  STOD((cAliasTmp)->(TDV_DTREF))
	aTail(oResponse['agendasABB'])['diasemana'] :=  EncodeUtf8(TECCdow(DOW(STOD((cAliasTmp)->(TDV_DTREF)))))
	aTail(oResponse['agendasABB'])['horaini']   :=  AllTrim((cAliasTmp)->(ABB_HRINI))
	aTail(oResponse['agendasABB'])['horafim']   :=  AllTrim((cAliasTmp)->(ABB_HRFIM))
	aTail(oResponse['agendasABB'])['desclocal'] :=  EncodeUTF8(AllTrim((cAliasTmp)->(ABS_DESCRI)))
	aTail(oResponse['agendasABB'])['descserv']  :=  EncodeUTF8(AllTrim((cAliasTmp)->(B1_DESC)))
	aTail(oResponse['agendasABB'])['tipomov']   :=  (cAliasTmp)->(ABB_TIPOMV)
	aTail(oResponse['agendasABB'])['abbstatus'] :=  (cAliasTmp)->(ABB_ATIVO)
	aTail(oResponse['agendasABB'])['codabb']    :=  (cAliasTmp)->(ABB_CODIGO)
	aTail(oResponse['agendasABB'])['descmotiv'] :=  EncodeUTF8(AllTrim((cAliasTmp)->(TCU_DESC)))
	aTail(oResponse['agendasABB'])['datainiabb']:=  STOD((cAliasTmp)->(ABB_DTINI))
	aTail(oResponse['agendasABB'])['datafimabb']:=  STOD((cAliasTmp)->(ABB_DTFIM))
	aTail(oResponse['agendasABB'])['abbatende'] :=  (cAliasTmp)->(ABB_ATENDE)
	aTail(oResponse['agendasABB'])['abbchegou'] :=  (cAliasTmp)->(ABB_CHEGOU)
	aTail(oResponse['agendasABB'])['idcfal']    :=  (cAliasTmp)->(ABB_IDCFAL)
	aTail(oResponse['agendasABB'])['abqcodtff'] :=  (cAliasTmp)->(ABQ_CODTFF)
	aTail(oResponse['agendasABB'])['observacao']:=  EncodeUtf8(AllTrim((cAliasTmp)->(ABB_OBSERV)))
	aTail(oResponse['agendasABB'])['abbfilial'] :=  (cAliasTmp)->(ABB_FILIAL)
	aTail(oResponse['agendasABB'])['recno']     :=  (cAliasTmp)->(REC)
	aTail(oResponse['agendasABB'])['checkin']   :=  (cAliasTmp)->(ABB_HRCHIN)
	aTail(oResponse['agendasABB'])['checkout']  :=  (cAliasTmp)->(ABB_HRCOUT)
	aTail(oResponse['agendasABB'])['periodo']	:=  cPeriodo
	aTail(oResponse['agendasABB'])['arraymanut']:=  {}
	
	If (cAliasTmp)->(ABB_MANUT) == '1'
		cJoinABR  := JoinSQL(lMultFil, "ABR.ABR_FILIAL", "ABB", "ABR", cFilTMP, "JOIN")
		cJoinABN  := JoinSQL(lMultFil, "ABN.ABN_FILIAL", "ABR", "ABN", cFilTMP, "JOIN")
		cWhereABB := JoinSQL(lMultFil, "ABB.ABB_FILIAL", "ABB", "ABB", cFilTMP, "WHERE")
		cABB	  := (cAliasTmp)->(ABB_CODIGO)

		cAliasABN := GetNextAlias()

		BeginSql Alias cAliasABN
			SELECT ABR_MANUT, ABR_MOTIVO, ABN_DESC
			FROM %table:ABB% ABB
				INNER JOIN %table:ABR% ABR 
					ON (%exp:cJoinABR% 
						AND ABR.ABR_AGENDA = ABB.ABB_CODIGO
						AND ABR.%NotDel%)
				INNER JOIN %table:ABN% ABN 
					ON (%exp:cJoinABN% 
						AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
						AND ABN.%NotDel%)
			WHERE %exp:cWhereABB%
				AND ABB.ABB_CODIGO = %exp:cABB%
				AND ABB.%NotDel%
		EndSql

		DbSelectArea(cAliasABN)
		(cAliasABN)->(DbGoTop())

		If (cAliasABN)->(! Eof())
			While (cAliasABN)->(! Eof())
				//Monta o Objeto JSon a ser retornado:
				Aadd(oResponse['agendasABB'][nPos]['arraymanut'], JsonObject():New())

				aTail(oResponse['agendasABB'][nPos]['arraymanut'])['codmanut']	:=  AllTrim((cAliasABN)->ABR_MANUT)
				aTail(oResponse['agendasABB'][nPos]['arraymanut'])['codmotiv']	:=  AllTrim((cAliasABN)->ABR_MOTIVO)
				aTail(oResponse['agendasABB'][nPos]['arraymanut'])['desc']		:=  EncodeUtf8(AllTrim((cAliasABN)->ABN_DESC))

				(cAliasABN)->(DbSkip())
			Enddo
		EndIf
		(cAliasABN)->(DbCloseArea())
	EndIf
	nPos ++
	(cAliasTmp)->(dbSkip())
End

//Populando Array de PerÌodos para Front:
nPerMax := Val(cPerMax)
For nX := 1 To nPerMax
	Aadd(oResponse['periodoMax'], JsonObject():New())
	aTail(oResponse['periodoMax'])['periodo']:=  EncodeUtf8(cValToChar(nX))
	aTail(oResponse['periodoMax'])['desc']	 :=  EncodeUtf8(cValToChar(nX) + "-PerÌodo")
Next nX

Aadd(oResponse['periodoMax'], JsonObject():New())
aTail(oResponse['periodoMax'])['periodo']:=  "0"
aTail(oResponse['periodoMax'])['desc']	 :=  EncodeUtf8("Todo PerÌodo")

(cAliasTmp)->(dbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Motivos de alocaÁ„o

@Param cFil - Filial selecionada no front end

oResponse - Json Object:

{
    "impMotivos": [
        {
            "codmotivo": "008",
            "descmotivo": "RESERVA",
            "tipomotivo": "1"
        }
    ]
}

@author     Jack Junior
@since      03/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET impMotivos WSRECEIVE cFil WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cWhereTCU := ""
Local cCondRes  := "1"
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil

cWhereTCU := JoinSQL(lMultFil, "TCU.TCU_FILIAL", "TCU", "TCU", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TCU.TCU_COD, TCU.TCU_DESC
    FROM %table:TCU% TCU
    WHERE %exp:cWhereTCU%
	        AND TCU.TCU_RESTEC <> %exp:cCondRes%
            AND TCU.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['impMotivos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['impMotivos'], JsonObject():New())

		aTail(oResponse['impMotivos'])['codmotivo']     := AllTrim((cAliasTmp)->TCU_COD)
		aTail(oResponse['impMotivos'])['descmotivo']    := EncodeUTF8(AllTrim((cAliasTmp)->TCU_DESC))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Tipos de manutenÁıes

@Param cFil - Filial selecionada no front end

oResponse - Json Object:

{
    "manutencoes": [
        {
            "codmotivos": "000001",
            "descmotivos": "ATRASO",
            "tipomotivos": "02"
        },
        {
            "codmotivos": "000002",
            "descmotivos": "FALTA",
            "tipomotivos": "01"
        },
        {
            "codmotivos": "000003",
            "descmotivos": "SAIDA ANTECIPADA",
            "tipomotivos": "03"
        }
    ]
}

@author     Jack Junior
@since      15/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET manutencoes WSRECEIVE cFil WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cWhereABN := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil

cWhereABN := JoinSQL(lMultFil, "ABN.ABN_FILIAL", "ABN", "ABN", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT ABN.ABN_CODIGO, ABN.ABN_DESC, ABN.ABN_TIPO
    FROM %table:ABN% ABN
    WHERE %exp:cWhereABN%
            AND ABN.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['manutencoes'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		If AllTrim((cAliasTmp)->ABN_TIPO) $ '01|02|03|04|05'
			//Monta o Objeto JSon a ser retornado:
			Aadd(oResponse['manutencoes'], JsonObject():New())

			aTail(oResponse['manutencoes'])['codmotivos']   := AllTrim((cAliasTmp)->ABN_CODIGO)
			aTail(oResponse['manutencoes'])['descmotivos']  := EncodeUTF8(AllTrim((cAliasTmp)->ABN_DESC))
			aTail(oResponse['manutencoes'])['tipomotivos']  := AllTrim((cAliasTmp)->ABN_TIPO)
		EndIf

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de gravaÁ„o da manutenÁ„o substituiÁ„o do atendente.

@Param BODY:
{
    "filial":"D MG 01 ",
    "atendente":"D MG 01 000054",
    "dataIni":"20230101",
    "dataFim":"20231231",
    "agendas":[{"value":"000000012871"},{"value":"000000012872"}],
    "motivo":"000002",
    "horaIni":"",
    "horaFim":"",
    "atendSub":"",
    "tipoDia":"S"
}

oResponse - Json Object:

{
    "retorno": "ManutenÁıes Gravadas com sucesso."
}

@author     Jack Junior
@since      15/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST manutencao WSREST MESAOPERACIONAL
Local oModel      := Nil
Local oMdlDTS     := Nil
Local oMdlABB     := Nil
Local oMdlMAN     := Nil
Local oParamBody  := JsonObject():New()
Local oResponse   := JsonObject():New()
Local cBody       := Self:GetContent()
Local aAgendas    := {}
Local aErrors     := {}
Local cMsgRet     := ""
Local cFilTMP     := ""
Local cAtendente  := ""
Local cDataIni    := ""
Local cDataFim    := ""
Local cManutMot   := ""
Local cHoraIni    := ""
Local cHoraFim    := ""
Local cAtendSub   := ""
Local cTipoDia    := ""
Local cTipo		  := ""
Local cValTipo	  := ""
Local lError      := .F.
Local lFindLine	  := .F.
Local nX          := 0
Local lRet        := .T.
Local lAlter	  := .F.

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']     //Filial
cAtendente  := oParamBody['atendente']  //Atendente da agenda
cDataIni    := oParamBody['dataIni']    //Data inicial Filtro
cDataFim    := oParamBody['dataFim']    //Data Final Filtro
aAgendas    := oParamBody['agendas']    //Array de Agendas selecionadas !
cManutMot   := oParamBody['motivo']     //Motivo da manutenÁ„o
cHoraIni    := oParamBody['horaIni']    //Hora inicial alterada
cHoraFim    := oParamBody['horaFim']    //Hora final alterada
cAtendSub   := oParamBody['atendSub']   //Atendente substituto na manutenÁ„o
cTipoDia    := oParamBody['tipoDia']    //Trabalhado / N„o Trabalhado
cValTipo	:= oParamBody['tipaloc'] 	//Tipo de AlocaÁ„o

//Valida se dados obrigatÛrios est„o vindo do Front End
If !Empty(cFilTMP) .And. !Empty(cAtendente) .And. !Empty(cDataIni) .And.;
	!Empty(cDataFim) .And. !Empty(aAgendas) .And. !Empty(cManutMot)
	//ABN_FILIAL+ABN_CODIGO+ABN_TIPO
	cTipo := Posicione("ABN",1,xFilial("ABN", cFilTMP)+cManutMot,"ABN_TIPO")

	//Ativa teca190D - Mesa Operacional - Inclus„o
	oModel:= FWLoadModel("TECA190D")
	oModel:SetOperation(3)
	oModel:Activate()

	oMdlAA1 := oModel:GetModel("AA1MASTER")
	oMdlDTS := oModel:GetModel("DTSMASTER")
	oMdlABB := oModel:GetModel("ABBDETAIL")
	oMdlMAN := oModel:GetModel("MANMASTER")

	//Preenche o Atendente:
	lRet := lRet .And. oMdlAA1:SetValue("AA1_CODTEC",cAtendente)

	//Filtra o range de Datas para Busca das agendas:
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTINI",sTod(cDataIni))
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTFIM",sTod(cDataFim))

	//Marca as agendas selecionadas para manutenÁ„o no grid ABB:
	If lRet
		For nX := 1 To Len(aAgendas)
			If oMdlABB:SeekLine({{"ABB_CODIGO",aAgendas[nX]['value']}},.F.,.T.)
				lRet := lRet .And. oMdlABB:SetValue("ABB_MARK",.T.)
				lFindLine := .T.
			EndIf
		Next nX
	EndIf

	If lFindLine
		//Seta vari·veis Est·ticas no TECA550 para evitar mensagens em tela e outros desvios:
		At550MPOUI(.T., cValTipo)

		//Se INCLUS√O de manutenÁ„o:
		If !Empty(cManutMot) .And. cManutMot != "999999" 

			//Preenche o motivo da manutenÁ„o:
			If lRet
				lRet := lRet .And. oMdlMAN:SetValue("MAN_MOTIVO",cManutMot)
			EndIf

			//Preenche a Hora Inicial se houver hor·rio:
			If lRet .And. !Empty(cHoraIni) .And. cTipo $ "02|04" //ATRASO, HORA EXTRA
				If AllTrim(cHoraIni) != AllTrim(oMdlMAN:GetValue("MAN_HRINI"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_HRINI",cHoraIni)
					lAlter := .T.
				EndIf
			EndIf

			//Preenche a Hora Final se houver hor·rio:
			If lRet .And. !Empty(cHoraFim) .And. cTipo $ "03|04" //SAÕDA ANTECIPADA, HORA EXTRA
				If AllTrim(cHoraFim) != AllTrim(oMdlMAN:GetValue("MAN_HRFIM"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_HRFIM",cHoraFim)
					lAlter := .T.
				EndIf
			EndIf

			//Preenche o CÛdigo do substituto se houver:
			If lRet .And. !Empty(cAtendSub) .And. cTipo $ "01|02|03" //FALTA, ATRASO, SAÕDA ANTECIPADA
				If AllTrim(cAtendSub) != AllTrim(oMdlMAN:GetValue("MAN_CODSUB"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_CODSUB",cAtendSub)
					If lRet .And. Empty(cValTipo)
						lRet := .F.
						oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"WSMESA","Tipo de AlocaÁ„o n„o pode estar vazio com atendente substituto")
					EndIf
					lAlter := .T.
				EndIf
			EndIf

			//Preenche o CÛdigo do tipo do dia se houver:
			If lRet .And. !Empty(cTipoDia) .And. cTipo $ "01|02|03" //FALTA, ATRASO, SAÕDA ANTECIPADA
				If AllTrim(cTipoDia) != AllTrim(oMdlMAN:GetValue("MAN_TIPDIA"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_TIPDIA",cTipoDia)
					lAlter := .T.
				EndIf
			EndIf

			//Falta - Preenche alteraÁ„o
			If lRet .And. cTipo == "01" 
				lAlter := .T.
			EndIf

			If lRet
				aErrors := AT190dIMn2(.T.)
				If !EMPTY(aErrors)
					cMsgRet += "As manutenÁıes abaixo n„o foram inseridas: " + CRLF + CRLF	//"As manutenÁıes abaixo n„o foram inseridas: "
					For nX := 1 To LEN(aErrors)
						If LEN(aErrors[nX]) < 3
							cMsgRet += aErrors[nX][1] + CRLF + aErrors[nX][2] + CRLF
						Else
							cMsgRet += aErrors[nX][4] + CRLF + aErrors[nX][6] + CRLF
						EndIf
						cMsgRet += CRLF + REPLICATE("-",30) + CRLF
					Next
					lError := .T.
				ElseIf !lAlter
					lError := .T.
					cMsgRet := "Nenhuma alteraÁ„o foi efetuada."
				Else
					lError := .F.
					cMsgRet := "ManutenÁıes Gravadas com sucesso."
				EndIf
			Else
				lError := .T.
				cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]+oModel:GetErrorMessage()[4]
			EndIf
		Else
			//Exclus„o de agendas
			BEGIN TRANSACTION
				lRet := At190DDlt(, , , , .T.)
			END TRANSACTION
			If lRet
				lError := .F.
				cMsgRet := "Agenda(s) excluÌda(s) com sucesso."
			Else
				lError := .T.
				cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]+oModel:GetErrorMessage()[4]
			EndIf
		EndIf
	Else
		lError := .T.
		cMsgRet := "Nenhuma agenda localizada no grid."
	EndIf
Else
	lError := .T.
	cMsgRet := "Dados faltantes na requisiÁ„o HTTP."
EndIf

oResponse['retorno'] := {}
Aadd(oResponse['retorno'], JsonObject():New())

aTail(oResponse['retorno'])['error']    := lError
aTail(oResponse['retorno'])['mensagem'] := EncodeUtf8(AllTrim(cMsgRet))

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

//Limpa as est·ticas
At550MPOUI(.F., "")

Return

WSMETHOD POST projRealoc WSREST MESAOPERACIONAL
Local oModel	:= Nil
Local oMdlAA1 	:= Nil
Local oMdlDTS 	:= Nil
Local oMdlABB 	:= Nil
Local oMdlMAN 	:= Nil
Local oMdl190F	:= Nil
Local oMdlTGY	:= Nil
Local oMdlDTA	:= Nil
Local oMdlALC	:= Nil
Local oParamBody:= JsonObject():New()
Local oResponse	:= JsonObject():New()
Local cBody		:= Self:GetContent()
Local aErrors	:= {}
Local aAgendas	:= {}
Local aDias		:= {}
Local cMsgRet	:= ""
Local cFilTMP	:= ""
Local cAtendente:= ""
Local cDataIni	:= ""
Local cDataFim	:= ""
Local cManutMot	:= ""
Local cAtendSub	:= ""
Local cTipoDia	:= ""
Local cTipoAloc	:= ""
Local cContrato	:= ""
Local cLocal	:= ""
Local cPosto	:= ""
Local cEscala	:= ""
Local cTipoMov	:= ""
Local cSeq		:= ""
Local cGrupo	:= ""
Local cConfAloc	:= ""
Local cIniAloc	:= ""
Local cFimAloc	:= ""
Local lRet		:= .T.
Local lFindLine := .T.
Local lPermConfl:= AT680Perm(NIL, __cUserID, "017")
Local nX		:= 0

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
//Modelo inicial teca 190D:
cFilTMP     := oParamBody['filial']     //Filial
cAtendente  := oParamBody['atendente']  //Atendente da agenda
cDataIni    := oParamBody['dataIni']    //Data inicial FILTRO
cDataFim    := oParamBody['dataFim']    //Data Final FILTRO
aAgendas	:= oParamBody['agendas']  	//Agendas marcadas no front-end
cManutMot	:= oParamBody['motivo']    	//Motivo da ManutenÁ„o da agenda
cAtendSub	:= oParamBody['atendsub']	//Atendente Substituto
cTipoDia	:= oParamBody['tipodia']	//Tipo do dia - Trabalhado/N„o Trab.

//Tipo de alocaÁ„o (quando h· substituto)
cTipoAloc	:= oParamBody['tipoaloc']	//Tipo do dia - Trabalhado/N„o Trab.

//Modelo ManutenÁ„o RealocaÁ„o TECA190F:
cContrato   := oParamBody['contrato']	//Contrato
cLocal		:= oParamBody['local']		//Local
cPosto		:= oParamBody['posto']		//Posto
cEscala		:= oParamBody['escala']		//Escala
cTipoMov    := oParamBody['tipoMov']    //Tipo de MovimentaÁ„o
cSeq		:= oParamBody['sequencia'] 	//Sequencia Inicial
cGrupo		:= oParamBody['grupo']		//Grupo
cConfAloc	:= oParamBody['confAloc'] 	//ConfiguraÁ„o de AlocaÁ„o
cIniAloc	:= oParamBody['inialoc'] 	//AlocaÁ„o de:
cFimAloc	:= oParamBody['fimaloc'] 	//AlocaÁ„o atÈ:

BEGIN TRANSACTION

//Valida se dados obrigatÛrios est„o vindo do Front-End
If !Empty(cFilTMP) .And. !Empty(cAtendente) .And. !Empty(cDataIni) .And.;
	!Empty(cDataFim) .And. !Empty(cManutMot) .And. !Empty(cContrato) .And.;
	!Empty(cLocal) .And. !Empty(cPosto) .And. !Empty(cTipoMov) .And.;
	!Empty(cSeq) .And. !Empty(cGrupo) .And. !Empty(cConfAloc) .And.;
	!Empty(cIniAloc) .And. !Empty(cFimAloc) .And. !Empty(aAgendas)

	//Ativa teca190D - Mesa Operacional - Inclus„o
	oModel:= FWLoadModel("TECA190D")
	oModel:SetOperation(3)
	oModel:Activate()

	oMdlAA1 := oModel:GetModel("AA1MASTER")
	oMdlDTS := oModel:GetModel("DTSMASTER")
	oMdlABB := oModel:GetModel("ABBDETAIL")
	oMdlMAN := oModel:GetModel("MANMASTER")

	//Preenche o Atendente:
	lRet := lRet .And. oMdlAA1:SetValue("AA1_CODTEC",cAtendente)

	//Filtra o range de Datas para Busca das agendas:
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTINI",sTod(cDataIni))
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTFIM",sTod(cDataFim))

	//Marca as agendas selecionadas para manutenÁ„o no grid ABB:
	If lRet
		For nX := 1 To Len(aAgendas)
			If oMdlABB:SeekLine({{"ABB_CODIGO",aAgendas[nX]['value']}},.F.,.T.)
				lRet := lRet .And. oMdlABB:SetValue("ABB_MARK",.T.)
				lFindLine := .T.
			EndIf
		Next nX
	EndIf

	If lFindLine
		If lRet
			//Seta Staticas 190D
			At190DPOUI(.T.)

			//Preenche o motivo da manutenÁ„o:
			If lRet
				lRet := lRet .And. oMdlMAN:SetValue("MAN_MOTIVO",cManutMot)
			EndIf

			//Preenche o CÛdigo do substituto se houver:
			If lRet .And. !Empty(cAtendSub)
				If AllTrim(cAtendSub) != AllTrim(oMdlMAN:GetValue("MAN_CODSUB"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_CODSUB",cAtendSub)
				EndIf
			EndIf

			//Preenche o CÛdigo do tipo do dia se houver:
			If lRet .And. !Empty(cTipoDia)
				If AllTrim(cTipoDia) != AllTrim(oMdlMAN:GetValue("MAN_TIPDIA"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_TIPDIA",cTipoDia)
				EndIf
			EndIf

			If lRet
				//Salva manutenÁ„o
				aErrors := AT190dIMn2(.T.)
				If !EMPTY(aErrors)
					cMsgRet += "As manutenÁıes abaixo n„o foram inseridas: " + CRLF + CRLF	//"As manutenÁıes abaixo n„o foram inseridas: "
					For nX := 1 To LEN(aErrors)
						If LEN(aErrors[nX]) < 3
							cMsgRet += aErrors[nX][1] + CRLF + aErrors[nX][2] + CRLF
						Else
							cMsgRet += aErrors[nX][4] + CRLF + aErrors[nX][6] + CRLF
						EndIf
						cMsgRet += CRLF + REPLICATE("-",30) + CRLF
					Next
				Else
					//ProjeÁ„o teca190F
					If At680Perm(NIL, __cUserId, "039", .T.)
						//Ativa teca190F - RealocaÁ„o - Inclus„o
						oMdl190F:= FWLoadModel("TECA190F")
						oMdl190F:SetOperation(3)
						oMdl190F:Activate()

						oMdlTGY := oMdl190F:GetModel("TGYMASTER")
						oMdlDTA := oMdl190F:GetModel("DTAMASTER")
						oMdlALC := oMdl190F:GetModel("ALCDETAIL")

						//ConfiguraÁ„o de AlocaÁ„o:
						lRet := lRet .And. oMdlTGY:SetValue("TGY_FILIAL",cFilTMP)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_CONTRT",cContrato)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_CODTFL",cLocal)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_TFFCOD",cPosto)
						If Empty(oMdlTGY:GetValue("TGY_ESCALA"))
							lRet := lRet .And. oMdlTGY:LoadValue("TGY_ESCALA",cEscala)
						EndIf
						lRet := lRet .And. oMdlTGY:SetValue("TGY_TIPALO",cTipoMov)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_SEQ",cSeq)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_GRUPO",cGrupo)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_CONFAL",cConfAloc)
						//PerÌodo de AlocaÁ„o:
						lRet := lRet .And. oMdlDTA:SetValue("DTA_DTINI",StoD(cIniAloc))
						lRet := lRet .And. oMdlDTA:SetValue("DTA_DTFIM",StoD(cFimAloc))

						If lRet
							If At190dExec("ProjAloc2()")
								For nX := 1 To oMdlALC:Length()
									oMdlALC:GoLine(nX)
									cAgenda := oMdlALC:GetValue("ALC_SITABB")
									cStatus := oMdlALC:GetValue("ALC_SITALO")
									AADD(aDias,{1,2,3,4,5,6,7,8,9,10,11,12})
									//Agenda:
									If cAgenda == "BR_VERMELHO"
										aDias[nX][1] := "color-07"
										aDias[nX][2] := EncodeUTF8("Agenda Gerada")
									ElseIf cAgenda == "BR_AMARELO"
										aDias[nX][1] := "color-05"
										aDias[nX][2] := EncodeUTF8("Agenda Atendida")
									ElseIf cAgenda == "BR_VERDE"
										aDias[nX][1] := "color-09"
										aDias[nX][2] := EncodeUTF8("Agenda N„o Gerada")
									ElseIf cAgenda == "BR_LARANJA"
										aDias[nX][1] := "color-08"
										aDias[nX][2] := EncodeUTF8("Agenda com ManutenÁ„o")
									ElseIf cAgenda == "BR_PRETO"
										aDias[nX][1] := "color-04"
										aDias[nX][2] := EncodeUTF8("Conflito de AlocaÁ„o")
									ElseIf cAgenda == "BR_PINK"
										aDias[nX][1] := "color-06"
										aDias[nX][2] := EncodeUTF8("Atendente com agenda em reverva tÈcnica")
									ElseIf cAgenda == "BR_AZUL"
										aDias[nX][1] := "color-01"
										aDias[nX][2] := EncodeUTF8("Sem convocaÁ„o")
									Else
										aDias[nX][1] := ""
										aDias[nX][2] := ""
									EndIf
									//Status:
									If cStatus == "BR_VERDE"
										aDias[nX][3] := "color-09"
										aDias[nX][4] := EncodeUTF8("Trabalhado")
									ElseIf cStatus == "BR_AMARELO"
										aDias[nX][3] := "color-05"
										aDias[nX][4] := EncodeUTF8("Compensado")
									ElseIf cStatus == "BR_AZUL"
										aDias[nX][3] := "color-01"
										aDias[nX][4] := EncodeUTF8("D.S.R.")
									ElseIf cStatus == "BR_LARANJA"
										aDias[nX][3] := "color-08"
										aDias[nX][4] := EncodeUTF8("Hora Extra")
									ElseIf cStatus == "BR_PRETO"
										aDias[nX][3] := "color-04"
										aDias[nX][4] := EncodeUTF8("Intervalo")
									ElseIf cStatus == "BR_VERMELHO"
										aDias[nX][3] := "color-07"
										aDias[nX][4] := EncodeUTF8("N„o trabalhado")
									Else
										aDias[nX][3] := ""
										aDias[nX][4] := ""
									EndIf
									aDias[nX][5] := oMdlALC:GetValue("ALC_DATREF")
									aDias[nX][6] := oMdlALC:GetValue("ALC_DATA")
									aDias[nX][7] := AllTrim(oMdlALC:GetValue("ALC_SEMANA"))
									aDias[nX][8] := oMdlALC:GetValue("ALC_ENTRADA")
									aDias[nX][9] := oMdlALC:GetValue("ALC_SAIDA")
									aDias[nX][10]:= oMdlALC:GetValue("ALC_SEQ")
									aDias[nX][11]:= oMdlALC:GetValue("ALC_TIPO")
									aDias[nX][12]:= oMdlALC:GetValue("ALC_INTERV")
								Next nX
							EndIf
						Else
							lRet := .F.
							cMsgRet := "Falha no Modelo: "+ oMdl190F:GetErrorMessage()[6]
						EndIf
					Else
						lRet := .F.
						cMsgRet := "Usu·rio sem permiss„o de projetar agenda"
					EndIf
				EndIf
			Else
				lRet := .F.
				cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]
			EndIf
		Else
			lRet := .F.
			cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]
		EndIf
	Else
		lRet := .F.
		cMsgRet := "Nenhuma agenda localizada no grid."
	EndIf
Else
	lRet := .F.
	cMsgRet := "Dados faltantes na requisiÁ„o HTTP."
EndIf
/*Disarma a transaÁ„o pois a mesa est· 
salvando a manutenÁ„o de RealocaÁ„o atÈ na projeÁ„o:*/
DisarmTransaction()

END TRANSACTION

oResponse['projRealoc'] := {}
Aadd(oResponse['projRealoc'], JsonObject():New())

aTail(oResponse['projRealoc'])['error']    := lRet
aTail(oResponse['projRealoc'])['mensagem'] := EncodeUtf8(AllTrim(cMsgRet))
aTail(oResponse['projRealoc'])['projecao'] := aDias
aTail(oResponse['projRealoc'])['permissao']:= lPermConfl

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

//Limpa as est·ticas
At190DPOUI(.F.)

Return

WSMETHOD POST gravRealoc WSREST MESAOPERACIONAL
Local oModel	:= Nil
Local oMdlAA1 	:= Nil
Local oMdlDTS 	:= Nil
Local oMdlABB 	:= Nil
Local oMdlMAN 	:= Nil
Local oMdl190F	:= Nil
Local oMdlTGY	:= Nil
Local oMdlDTA	:= Nil
Local oMdlALC	:= Nil
Local oParamBody:= JsonObject():New()
Local oResponse	:= JsonObject():New()
Local cBody		:= Self:GetContent()
Local aErrors	:= {}
Local aAgendas	:= {}
Local aDias		:= {}
Local cMsgRet	:= ""
Local cFilTMP	:= ""
Local cAtendente:= ""
Local cDataIni	:= ""
Local cDataFim	:= ""
Local cManutMot	:= ""
Local cAtendSub	:= ""
Local cTipoDia	:= ""
Local cTipoAloc	:= ""
Local cContrato	:= ""
Local cLocal	:= ""
Local cPosto	:= ""
Local cEscala	:= ""
Local cTipoMov	:= ""
Local cSeq		:= ""
Local cGrupo	:= ""
Local cConfAloc	:= ""
Local cIniAloc	:= ""
Local cFimAloc	:= ""
Local lRet		:= .T.
Local lFindLine := .T.
Local nX		:= 0

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
//Modelo inicial teca 190D:
cFilTMP     := oParamBody['filial']     //Filial
cAtendente  := oParamBody['atendente']  //Atendente da agenda
cDataIni    := oParamBody['dataIni']    //Data inicial FILTRO
cDataFim    := oParamBody['dataFim']    //Data Final FILTRO
aAgendas	:= oParamBody['agendas']  	//Agendas marcadas no front-end
cManutMot	:= oParamBody['motivo']    	//Motivo da ManutenÁ„o da agenda
cAtendSub	:= oParamBody['atendsub']	//Atendente Substituto
cTipoDia	:= oParamBody['tipodia']	//Tipo do dia - Trabalhado/N„o Trab.

//Tipo de alocaÁ„o (quando h· substituto)
cTipoAloc	:= oParamBody['tipoaloc']	//Tipo do dia - Trabalhado/N„o Trab.

//Modelo ManutenÁ„o RealocaÁ„o TECA190F:
cContrato   := oParamBody['contrato']	//Contrato
cLocal		:= oParamBody['local']		//Local
cPosto		:= oParamBody['posto']		//Posto
cEscala		:= oParamBody['escala']		//Escala
cTipoMov    := oParamBody['tipoMov']    //Tipo de MovimentaÁ„o
cSeq		:= oParamBody['sequencia'] 	//Sequencia Inicial
cGrupo		:= oParamBody['grupo']		//Grupo
cConfAloc	:= oParamBody['confAloc'] 	//ConfiguraÁ„o de AlocaÁ„o
cIniAloc	:= oParamBody['inialoc'] 	//AlocaÁ„o de:
cFimAloc	:= oParamBody['fimaloc'] 	//AlocaÁ„o atÈ:

//Alocar todos os dias/apenas disponÌveis
lAlocConf	:= oParamBody['alocConf']

BEGIN TRANSACTION

//Valida se dados obrigatÛrios est„o vindo do Front-End
If !Empty(cFilTMP) .And. !Empty(cAtendente) .And. !Empty(cDataIni) .And.;
	!Empty(cDataFim) .And. !Empty(cManutMot) .And. !Empty(cContrato) .And.;
	!Empty(cLocal) .And. !Empty(cPosto) .And. !Empty(cTipoMov) .And.;
	!Empty(cSeq) .And. !Empty(cGrupo) .And. !Empty(cConfAloc) .And.;
	!Empty(cIniAloc) .And. !Empty(cFimAloc) .And. !Empty(aAgendas)

	//Ativa teca190D - Mesa Operacional - Inclus„o
	oModel:= FWLoadModel("TECA190D")
	oModel:SetOperation(3)
	oModel:Activate()

	//lPermConfl-----True:---------------False:
	//lAlocConf = 1 |apenas disponÌveis	|apenas disponÌveis
	//lAlocConf = 2 |todos os dias		|cancelar
	At190DPOUI(.T.,lAlocConf)

	oMdlAA1 := oModel:GetModel("AA1MASTER")
	oMdlDTS := oModel:GetModel("DTSMASTER")
	oMdlABB := oModel:GetModel("ABBDETAIL")
	oMdlMAN := oModel:GetModel("MANMASTER")

	//Preenche o Atendente:
	lRet := lRet .And. oMdlAA1:SetValue("AA1_CODTEC",cAtendente)

	//Filtra o range de Datas para Busca das agendas:
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTINI",sTod(cDataIni))
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTFIM",sTod(cDataFim))

	//Marca as agendas selecionadas para manutenÁ„o no grid ABB:
	If lRet
		For nX := 1 To Len(aAgendas)
			If oMdlABB:SeekLine({{"ABB_CODIGO",aAgendas[nX]['value']}},.F.,.T.)
				lRet := lRet .And. oMdlABB:SetValue("ABB_MARK",.T.)
				lFindLine := .T.
			EndIf
		Next nX
	EndIf

	If lFindLine
		If lRet
			//Preenche o motivo da manutenÁ„o:
			If lRet
				lRet := lRet .And. oMdlMAN:SetValue("MAN_MOTIVO",cManutMot)
			EndIf

			//Preenche o CÛdigo do substituto se houver:
			If lRet .And. !Empty(cAtendSub)
				If AllTrim(cAtendSub) != AllTrim(oMdlMAN:GetValue("MAN_CODSUB"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_CODSUB",cAtendSub)
				EndIf
			EndIf

			//Preenche o CÛdigo do tipo do dia se houver:
			If lRet .And. !Empty(cTipoDia)
				If AllTrim(cTipoDia) != AllTrim(oMdlMAN:GetValue("MAN_TIPDIA"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_TIPDIA",cTipoDia)
				EndIf
			EndIf

			If lRet
				//Salva manutenÁ„o
				aErrors := AT190dIMn2(.T.)
				If !EMPTY(aErrors)
					cMsgRet += "As manutenÁıes abaixo n„o foram inseridas: " + CRLF + CRLF	//"As manutenÁıes abaixo n„o foram inseridas: "
					For nX := 1 To LEN(aErrors)
						If LEN(aErrors[nX]) < 3
							cMsgRet += aErrors[nX][1] + CRLF + aErrors[nX][2] + CRLF
						Else
							cMsgRet += aErrors[nX][4] + CRLF + aErrors[nX][6] + CRLF
						EndIf
						cMsgRet += CRLF + REPLICATE("-",30) + CRLF
					Next
				Else
					//ProjeÁ„o teca190F
					If At680Perm(NIL, __cUserId, "039", .T.)
						//Ativa teca190F - RealocaÁ„o - Inclus„o
						oMdl190F:= FWLoadModel("TECA190F")
						oMdl190F:SetOperation(3)
						oMdl190F:Activate()

						oMdlTGY := oMdl190F:GetModel("TGYMASTER")
						oMdlDTA := oMdl190F:GetModel("DTAMASTER")
						oMdlALC := oMdl190F:GetModel("ALCDETAIL")

						//ConfiguraÁ„o de AlocaÁ„o:
						lRet := lRet .And. oMdlTGY:SetValue("TGY_FILIAL",cFilTMP)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_CONTRT",cContrato)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_CODTFL",cLocal)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_TFFCOD",cPosto)
						If Empty(oMdlTGY:GetValue("TGY_ESCALA"))
							lRet := lRet .And. oMdlTGY:LoadValue("TGY_ESCALA",cEscala)
						EndIf
						lRet := lRet .And. oMdlTGY:SetValue("TGY_TIPALO",cTipoMov)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_SEQ",cSeq)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_GRUPO",cGrupo)
						lRet := lRet .And. oMdlTGY:SetValue("TGY_CONFAL",cConfAloc)
						//PerÌodo de AlocaÁ„o:
						lRet := lRet .And. oMdlDTA:SetValue("DTA_DTINI",StoD(cIniAloc))
						lRet := lRet .And. oMdlDTA:SetValue("DTA_DTFIM",StoD(cFimAloc))

						If lRet
							If At190dExec("ProjAloc2()")
								//Realiza a gravaÁ„o da realocaÁ„o:
								If oMdl190F:VldData() .And. oMdl190F:CommitData()
									lRet := .T.
									cMsg := "GravaÁ„o da realocaÁ„o efetuada com sucesso."
								Else
									lRet := .F.
									cMsg := oMdl190F:GetErrorMessage()[6]
								EndIf
							EndIf
						Else
							lRet := .F.
							cMsgRet := "Falha no Modelo: "+ oMdl190F:GetErrorMessage()[6]
						EndIf
					Else
						lRet := .F.
						cMsgRet := "Usu·rio sem permiss„o de projetar agenda"
					EndIf
				EndIf
			Else
				lRet := .F.
				cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]
			EndIf
		Else
			lRet := .F.
			cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]
		EndIf
	Else
		lRet := .F.
		cMsgRet := "Nenhuma agenda localizada no grid."
	EndIf
Else
	lRet := .F.
	cMsgRet := "Dados faltantes na requisiÁ„o HTTP."
EndIf
If !lRet
	/*Disarma a transaÁ„o pois a mesa est· 
	salvando a manutenÁ„o de RealocaÁ„o atÈ na projeÁ„o:*/
	DisarmTransaction()
EndIf

END TRANSACTION

oResponse['projRealoc'] := {}
Aadd(oResponse['projRealoc'], JsonObject():New())

aTail(oResponse['projRealoc'])['error']    := lRet
aTail(oResponse['projRealoc'])['mensagem'] := EncodeUtf8(AllTrim(cMsgRet))
aTail(oResponse['projRealoc'])['projecao'] := aDias

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

//Limpeza de variaveis est·ticas:
At190DPOUI(.F.,3)

Return

WSMETHOD POST projCompen WSREST MESAOPERACIONAL
Local oModel	:= Nil
Local oMdlAA1 	:= Nil
Local oMdlDTS 	:= Nil
Local oMdlABB 	:= Nil
Local oMdlMAN 	:= Nil
Local oMdl190H	:= Nil
Local oMdlDTA	:= Nil
Local oParamBody:= JsonObject():New()
Local oResponse	:= JsonObject():New()
Local cBody		:= Self:GetContent()
Local aErrors	:= {}
Local aAgendas	:= {}
Local aDias		:= {}
Local cMsgRet	:= ""
Local cFilTMP	:= ""
Local cAtendente:= ""
Local cDataIni	:= ""
Local cDataFim	:= ""
Local cManutMot	:= ""
Local cAtendSub	:= ""
Local cTipoDia	:= ""
Local cTipoAloc	:= ""
Local lRet		:= .T.
Local lFindLine := .T.
Local nX		:= 0

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
//Modelo inicial teca 190D:
cFilTMP     := oParamBody['filial']     //Filial
cAtendente  := oParamBody['atendente']  //Atendente da agenda
cDataIni    := oParamBody['dataIni']    //Data inicial FILTRO
cDataFim    := oParamBody['dataFim']    //Data Final FILTRO
aAgendas	:= oParamBody['agendas']  	//Agendas marcadas no front-end
cManutMot	:= oParamBody['motivo']    	//Motivo da ManutenÁ„o da agenda
cAtendSub	:= oParamBody['atendsub']	//Atendente Substituto
cTipoDia	:= oParamBody['tipodia']	//Tipo do dia - Trabalhado/N„o Trab.

//Tipo de alocaÁ„o (quando h· substituto)
cTipoAloc	:= oParamBody['tipoaloc']	//Tipo do dia - Trabalhado/N„o Trab.

BEGIN TRANSACTION

//Valida se dados obrigatÛrios est„o vindo do Front-End
If !Empty(cFilTMP) .And. !Empty(cAtendente) .And. !Empty(cDataIni) .And.;
	!Empty(cDataFim) .And. !Empty(cManutMot) .And. !Empty(cTipoAloc) .And.;
	!Empty(aAgendas)

	//Ativa teca190D - Mesa Operacional - Inclus„o
	oModel:= FWLoadModel("TECA190D")
	oModel:SetOperation(3)
	oModel:Activate()

	oMdlAA1 := oModel:GetModel("AA1MASTER")
	oMdlDTS := oModel:GetModel("DTSMASTER")
	oMdlABB := oModel:GetModel("ABBDETAIL")
	oMdlMAN := oModel:GetModel("MANMASTER")

	//Preenche o Atendente:
	lRet := lRet .And. oMdlAA1:SetValue("AA1_CODTEC",cAtendente)

	//Filtra o range de Datas para Busca das agendas:
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTINI",sTod(cDataIni))
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTFIM",sTod(cDataFim))

	//Marca as agendas selecionadas para manutenÁ„o no grid ABB:
	If lRet
		For nX := 1 To Len(aAgendas)
			If oMdlABB:SeekLine({{"ABB_CODIGO",aAgendas[nX]['value']}},.F.,.T.)
				lRet := lRet .And. oMdlABB:SetValue("ABB_MARK",.T.)
				lFindLine := .T.
			EndIf
		Next nX
	EndIf

	If lFindLine
		If lRet
			//Seta Staticas 190D
			At190DPOUI(.T.)

			//Preenche o motivo da manutenÁ„o:
			If lRet
				lRet := lRet .And. oMdlMAN:SetValue("MAN_MOTIVO",cManutMot)
			EndIf

			//Preenche o CÛdigo do substituto se houver:
			If lRet .And. !Empty(cAtendSub)
				If AllTrim(cAtendSub) != AllTrim(oMdlMAN:GetValue("MAN_CODSUB"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_CODSUB",cAtendSub)
				EndIf
			EndIf

			//Preenche o CÛdigo do tipo do dia se houver:
			If lRet .And. !Empty(cTipoDia)
				If AllTrim(cTipoDia) != AllTrim(oMdlMAN:GetValue("MAN_TIPDIA"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_TIPDIA",cTipoDia)
				EndIf
			EndIf

			If lRet
				//Salva manutenÁ„o
				aErrors := AT190dIMn2(.T.)
				If !EMPTY(aErrors)
					lRet := .F.
					cMsgRet += "As manutenÁıes abaixo n„o foram inseridas: " + CRLF + CRLF	//"As manutenÁıes abaixo n„o foram inseridas: "
					For nX := 1 To LEN(aErrors)
						If LEN(aErrors[nX]) < 3
							cMsgRet += aErrors[nX][1] + CRLF + aErrors[nX][2] + CRLF
						Else
							cMsgRet += aErrors[nX][4] + CRLF + aErrors[nX][6] + CRLF
						EndIf
						cMsgRet += CRLF + REPLICATE("-",30) + CRLF
					Next
				Else
					//Ativa teca190H - CompensaÁ„o - Inclus„o
					oMdl190H:= FWLoadModel("TECA190H")
					oMdl190H:SetOperation(3)
					oMdl190H:Activate()

					oMdlDTA := oMdl190H:GetModel("DTADETAIL")

					For nX := 1 To oMdlDTA:Length()
						oMdlDTA:GoLine(nX)
						AADD(aDias,{1,2})
						
						aDias[nX][1] := oMdlDTA:GetValue("DTA_DTCOMP")
						aDias[nX][2] := AllTrim(oMdlDTA:GetValue("DTA_DSCOMP"))
					Next nX
				EndIf
			Else
				lRet := .F.
				cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]
			EndIf
		Else
			lRet := .F.
			cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]
		EndIf
	Else
		lRet := .F.
		cMsgRet := "Nenhuma agenda localizada no grid."
	EndIf
Else
	lRet := .F.
	cMsgRet := "Dados faltantes na requisiÁ„o HTTP."
EndIf

//Disarma para n„o inserir a manutenÁ„o na "projeÁ„o"
DisarmTransaction()

END TRANSACTION

oResponse['projCompen'] := {}
Aadd(oResponse['projCompen'], JsonObject():New())

aTail(oResponse['projCompen'])['error']    := lRet
aTail(oResponse['projCompen'])['mensagem'] := EncodeUtf8(AllTrim(cMsgRet))
aTail(oResponse['projCompen'])['projecao'] := aDias

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

//Limpa as est·ticas
At190DPOUI(.F.)

Return

WSMETHOD POST gravCompen WSREST MESAOPERACIONAL
Local oModel	:= Nil
Local oMdlAA1 	:= Nil
Local oMdlDTS 	:= Nil
Local oMdlABB 	:= Nil
Local oMdlMAN 	:= Nil
Local oMdl190H	:= Nil
Local oMdlDTA	:= Nil
Local oParamBody:= JsonObject():New()
Local oResponse	:= JsonObject():New()
Local cBody		:= Self:GetContent()
Local aErrors	:= {}
Local aAgendas	:= {}
Local aDias		:= {}
Local cMsgRet	:= ""
Local cFilTMP	:= ""
Local cAtendente:= ""
Local cDataIni	:= ""
Local cDataFim	:= ""
Local cManutMot	:= ""
Local cAtendSub	:= ""
Local cTipoDia	:= ""
Local cTipoAloc	:= ""
Local lRet		:= .T.
Local lFindLine := .T.
Local nX		:= 0

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
//Modelo inicial teca 190D:
cFilTMP     := oParamBody['filial']     //Filial
cAtendente  := oParamBody['atendente']  //Atendente da agenda
cDataIni    := oParamBody['dataIni']    //Data inicial FILTRO
cDataFim    := oParamBody['dataFim']    //Data Final FILTRO
aAgendas	:= oParamBody['agendas']  	//Agendas marcadas no front-end
cManutMot	:= oParamBody['motivo']    	//Motivo da ManutenÁ„o da agenda
cAtendSub	:= oParamBody['atendsub']	//Atendente Substituto
cTipoDia	:= oParamBody['tipodia']	//Tipo do dia - Trabalhado/N„o Trab.

//Tipo de alocaÁ„o (quando h· substituto)
cTipoAloc	:= oParamBody['tipoaloc']	//Tipo do dia - Trabalhado/N„o Trab.

aDias		:= oParamBody['diasCompensado']	//Dias compensado

BEGIN TRANSACTION

//Valida se dados obrigatÛrios est„o vindo do Front-End
If !Empty(cFilTMP) .And. !Empty(cAtendente) .And. !Empty(cDataIni) .And.;
	!Empty(cDataFim) .And. !Empty(cManutMot) .And. !Empty(cTipoAloc) .And.;
	!Empty(aAgendas)

	//Ativa teca190D - Mesa Operacional - Inclus„o
	oModel:= FWLoadModel("TECA190D")
	oModel:SetOperation(3)
	oModel:Activate()

	oMdlAA1 := oModel:GetModel("AA1MASTER")
	oMdlDTS := oModel:GetModel("DTSMASTER")
	oMdlABB := oModel:GetModel("ABBDETAIL")
	oMdlMAN := oModel:GetModel("MANMASTER")

	//Preenche o Atendente:
	lRet := lRet .And. oMdlAA1:SetValue("AA1_CODTEC",cAtendente)

	//Filtra o range de Datas para Busca das agendas:
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTINI",sTod(cDataIni))
	lRet := lRet .And. oMdlDTS:SetValue("DTS_DTFIM",sTod(cDataFim))

	//Marca as agendas selecionadas para manutenÁ„o no grid ABB:
	If lRet
		For nX := 1 To Len(aAgendas)
			If oMdlABB:SeekLine({{"ABB_CODIGO",aAgendas[nX]['value']}},.F.,.T.)
				lRet := lRet .And. oMdlABB:SetValue("ABB_MARK",.T.)
				lFindLine := .T.
			EndIf
		Next nX
	EndIf

	If lFindLine
		If lRet
			//Seta Staticas 190D
			At190DPOUI(.T.)

			//Preenche o motivo da manutenÁ„o:
			If lRet
				lRet := lRet .And. oMdlMAN:SetValue("MAN_MOTIVO",cManutMot)
			EndIf

			//Preenche o CÛdigo do substituto se houver:
			If lRet .And. !Empty(cAtendSub)
				If AllTrim(cAtendSub) != AllTrim(oMdlMAN:GetValue("MAN_CODSUB"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_CODSUB",cAtendSub)
				EndIf
			EndIf

			//Preenche o CÛdigo do tipo do dia se houver:
			If lRet .And. !Empty(cTipoDia)
				If AllTrim(cTipoDia) != AllTrim(oMdlMAN:GetValue("MAN_TIPDIA"))
					lRet := lRet .And. oMdlMAN:SetValue("MAN_TIPDIA",cTipoDia)
				EndIf
			EndIf

			If lRet
				//Salva manutenÁ„o
				aErrors := AT190dIMn2(.T.)
				If !EMPTY(aErrors)
					cMsgRet += "As manutenÁıes abaixo n„o foram inseridas: " + CRLF + CRLF	//"As manutenÁıes abaixo n„o foram inseridas: "
					For nX := 1 To LEN(aErrors)
						If LEN(aErrors[nX]) < 3
							cMsgRet += aErrors[nX][1] + CRLF + aErrors[nX][2] + CRLF
						Else
							cMsgRet += aErrors[nX][4] + CRLF + aErrors[nX][6] + CRLF
						EndIf
						cMsgRet += CRLF + REPLICATE("-",30) + CRLF
					Next
				Else
					//Ativa teca190H - CompensaÁ„o - Inclus„o
					oMdl190H:= FWLoadModel("TECA190H")
					oMdl190H:SetOperation(3)
					oMdl190H:Activate()

					oMdlDTA := oMdl190H:GetModel("DTADETAIL")

					For nX := 1 To aDias
						If oMdlDTA:SeekLine({{"DTA_DTCOMP",StoD(aDias[nX]['DTCOMP'])}},.F.,.T.)
							lRet := lRet .And. oMdlDTA:SetValue("DTA_DTTRAB",StoD(aDias[nX]['DTTRAB']))
						Else
							lRet := .F.
							cMsgRet := "Data n„o localizada: "+aDias[nX]['DTCOMP']
							Exit
						EndIf
					Next nX

					If lRet
						If oMdl190H:VldData() .And. oMdl190H:CommitData()
							lRet := .T.
							cMsgRet := "GravaÁ„o da compensaÁ„o efetuada com sucesso."
						Else
							lRet := .F.
							cMsgRet := oMdl190H:GetErrorMessage()[6]
						EndIf
					Else
						lRet := .F.
						cMsgRet := "Falha no Modelo: "+oMdl190H:GetErrorMessage()[6]
					EndIf
				EndIf
			Else
				lRet := .F.
				cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]
			EndIf
		Else
			lRet := .F.
			cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]
		EndIf
	Else
		lRet := .F.
		cMsgRet := "Nenhuma agenda localizada no grid."
	EndIf
Else
	lRet := .F.
	cMsgRet := "Dados faltantes na requisiÁ„o HTTP."
EndIf
If !lRet
	DisarmTransaction()
EndIf

END TRANSACTION

oResponse['gravCompen'] := {}
Aadd(oResponse['gravCompen'], JsonObject():New())

aTail(oResponse['gravCompen'])['error']    := lRet
aTail(oResponse['gravCompen'])['mensagem'] := EncodeUtf8(AllTrim(cMsgRet))

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

//Limpa as est·ticas
At190DPOUI(.F.)

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET Tipo de alocaÁ„o na alteraÁ„o da manutenÁ„o

@Param cFil - Filial selecionanda no front end

@author     Jack Junior
@since      15/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET tipAlocManut WSRECEIVE cFil WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local cFilTMP   := ""

cFilTMP := self:cFil

DbSelectArea('TCU')
TCU->(DbSetOrder(1)) //TCU_FILIAL+TCU_COD

If !TCU->(DbSeek(xFilial("TCU", cFilTMP))) // caso n„o encontre informaÁıes
	At690Unit()  // crias os tipos padr„o para a filial
	TCU->(DbSeek(xFilial("TCU", cFilTMP)))  // apÛs criar... reposiciona no primeiro registro da filial
EndIf

oResponse['detailManut'] := {}

While TCU->(!EOF()) .And. TCU->TCU_FILIAL==xFilial('TCU', cFilTMP)

	// Valida se o tipo deve ser mostrado na alocacao/manuntencao da agenda
	If (TCU->TCU_EXMANU <> "1")
		TCU->(DbSkip())
		Loop
	Else
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['detailManut'], JsonObject():New())

		aTail(oResponse['detailManut'])['tipo']		:= AllTrim(TCU->TCU_COD)
		aTail(oResponse['detailManut'])['desc']		:= EncodeUtf8(AllTrim(TCU->TCU_DESC))
		TCU->(DbSkip())
	EndIf
End

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Funcionarios substitutos para manutenÁ„o

@Param cFil - Filial selecionada no front end

oResponse - Json Object:

{
    "substitutos": [
        {
            "codigo": "00000000000028",
            "nome": "LEVYSSIMO",
            "matricula": "", //APENAS ATENDENTE DO GS (N√O TEM MATRICULA)
            "tipocontr": ""  //APENAS ATENDENTE DO GS
        },
        {
            "codigo": "D MG 01 000053",
            "nome": "JACK JOHNSON",
            "matricula": "000053",
            "tipocontr": "Indeterminado"
        },
        {
            "codigo": "D MG 01 000054",
            "nome": "VICCO ITALIAN",
            "matricula": "000054",
            "tipocontr": "Intermitente"
        },
        {
            "codigo": "D MG 01 000055",
            "nome": "AUGUSTO PO MINEIRO",
            "matricula": "000055",
            "tipocontr": "Determinado"
        }
    ]
}

@author     Jack Junior
@since      15/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD GET substitutos WSRECEIVE cFil WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cWhereAA1 := ""
Local cSRABloq  := "%%"
Local cAA1Bloq  := "%%"
Local cTipoContr:= ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil

If SRA->(FieldPos('RA_MSBLQL')) > 0
	cSRABloq := "% AND SRA.RA_MSBLQL <> '1'%"
EndIf
//-- Necess·rio utilizar FieldPos, pois o campo de bloqueio de registro È opcional para o cliente.
If AA1->(FieldPos('AA1_MSBLQL')) > 0
	cAA1Bloq := "% AND AA1.AA1_MSBLQL <> '1'%"
EndIf

cJoinSRA := JoinSQL(lMultFil, "SRA.RA_FILIAL",  "AA1", "SRA", cFilTMP, "JOIN")
cWhereAA1 := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "AA1", "AA1", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT AA1.AA1_CODTEC, 
            AA1.AA1_NOMTEC, 
            AA1.AA1_CDFUNC, 
            CASE WHEN SRA.RA_TPCONTR IS NULL 
                THEN ""
                ELSE SRA.RA_TPCONTR 
                END RA_TPCONTR
	FROM %table:AA1% AA1
	    LEFT JOIN %table:SRA% SRA 
            ON (%exp:cJoinSRA% 
                AND SRA.RA_MAT = AA1.AA1_CDFUNC
                %exp:cSRABloq%
	            AND SRA.%NotDel%)
	WHERE %exp:cWhereAA1%
        AND AA1.AA1_ALOCA = '1'
	    AND AA1.%NotDel%
	    %exp:cAA1Bloq%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['substitutos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['substitutos'], JsonObject():New())

		If (cAliasTmp)->RA_TPCONTR = '1'
			cTipoContr := "Indeterminado"
		ElseIf (cAliasTmp)->RA_TPCONTR = '2'
			cTipoContr := "Determinado"
		ElseIf (cAliasTmp)->RA_TPCONTR = '3'
			cTipoContr := "Intermitente"
		Else
			cTipoContr := ""
		EndIf

		aTail(oResponse['substitutos'])['codigo']    := AllTrim((cAliasTmp)->AA1_CODTEC)
		aTail(oResponse['substitutos'])['nome']      := EncodeUtf8(AllTrim((cAliasTmp)->AA1_NOMTEC))
		aTail(oResponse['substitutos'])['matricula'] := AllTrim((cAliasTmp)->AA1_CDFUNC)
		aTail(oResponse['substitutos'])['tipocontr'] := cTipoContr

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de ManutenÁıes de uma agenda especÌfica

@Param cFil - Filial selecionada no front end
		cCodABB - CÛdigo da Agenda (ABB)

@author     Jack Junior
@since      09/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET manutABB WSRECEIVE cFil, cCodABB WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cABB		:= ""
Local cJoinABR  := ""
Local cJoinABN  := ""
Local cWhereABB := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cABB 	:= self:cCodABB

cJoinABR  := JoinSQL(lMultFil, "ABR.ABR_FILIAL", "ABB", "ABR", cFilTMP, "JOIN")
cJoinABN  := JoinSQL(lMultFil, "ABN.ABN_FILIAL", "ABR", "ABN", cFilTMP, "JOIN")
cWhereABB := JoinSQL(lMultFil, "ABB.ABB_FILIAL", "ABB", "ABB", cFilTMP, "JOIN")

BeginSql Alias cAliasTmp
    SELECT ABR_MOTIVO, ABN_DESC
	FROM %table:ABB% ABB
	    INNER JOIN %table:ABR% ABR 
            ON (%exp:cJoinABR% 
                AND ABR.ABR_AGENDA = ABB.ABB_CODIGO
	            AND ABR.%NotDel%)
		INNER JOIN %table:ABN% ABN 
            ON (%exp:cJoinABN% 
                AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
	            AND ABN.%NotDel%)
	WHERE %exp:cWhereABB%
        AND ABB.ABB_CODIGO = %exp:cABB%
	    AND ABB.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['manutABB'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['manutABB'], JsonObject():New())

		aTail(oResponse['manutABB'])['codigo']	:= AllTrim((cAliasTmp)->ABR_MOTIVO)
		aTail(oResponse['manutABB'])['desc']	:= EncodeUtf8(AllTrim((cAliasTmp)->ABN_DESC))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de informaÁıes da manutenÁ„o para alteraÁ„o da mesma.

@Param cFil - Filial selecionada no front end
		cCodABB - CÛdigo da Agenda (ABB_COD)
		cCodManut - CÛdigo da ManutenÁ„o (ABR_MANUT)

@author     Jack Junior
@since      15/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET detailManut WSRECEIVE cFil, cCodABB, cCodManut WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cABB		:= ""
Local cManut	:= ""
Local cJoinABN  := ""
Local cWhereABR := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cABB 	:= self:cCodABB
cManut 	:= self:cCodManut

cJoinABN  := JoinSQL(lMultFil, "ABN.ABN_FILIAL", "ABR", "ABN", cFilTMP, "JOIN")
cWhereABR := JoinSQL(lMultFil, "ABR.ABR_FILIAL", "ABR", "ABR", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT ABN_DESC, ABN_TIPO, ABR_HRINI, ABR_HRFIM, ABR_CODSUB, ABR_TIPDIA
	FROM %table:ABR% ABR
	    INNER JOIN %table:ABN% ABN 
            ON (%exp:cJoinABN% 
                AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
	            AND ABN.%NotDel%)
	WHERE %exp:cWhereABR%
        AND ABR.ABR_AGENDA = %exp:cABB%
		AND ABR.ABR_MANUT = %exp:cManut%
	    AND ABR.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['detailManut'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['detailManut'], JsonObject():New())

		aTail(oResponse['detailManut'])['tipo']		:= AllTrim((cAliasTmp)->ABN_TIPO)
		aTail(oResponse['detailManut'])['desc']		:= EncodeUtf8(AllTrim((cAliasTmp)->ABN_DESC))
		aTail(oResponse['detailManut'])['hrini']	:= AllTrim((cAliasTmp)->ABR_HRINI)
		aTail(oResponse['detailManut'])['hrfim']	:= AllTrim((cAliasTmp)->ABR_HRFIM)
		aTail(oResponse['detailManut'])['codsub']	:= AllTrim((cAliasTmp)->ABR_CODSUB)
		aTail(oResponse['detailManut'])['tpdia']	:= AllTrim((cAliasTmp)->ABR_TIPDIA)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de retorno de InformaÁ„o do posto e benefÌcios do atendente

oResponse - Json Object:

@author     Jack Junior
@since      15/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST infAtend WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cAliasTmp := GetNextAlias()
Local cAliasSRA := GetNextAlias()
Local cAliasTFF := GetNextAlias()
Local cAliasRI4 := GetNextAlias()
Local cBody     := Self:GetContent()
Local cCodCCT   := ""
Local cCodFuncao:= ""
Local cCodMat   := ""
Local cCodTFF   := ""
Local cData     := ""
Local cFilTMP   := ""
Local cEscala   := ""
Local cPericul  := ""
Local cInsalub  := ""
Local cSeq      := ""
Local cDtDemissa:= ""
Local cWhereSRA := ""
Local cWhereSLY := ""
Local cWhereTFF := ""
Local aBenef    := {}
Local aBeneficio:= {}
Local aRetProj  := {}
Local aInfTFF   := {}
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
cCodFuncao  := oParamBody['funcao']
cCodMat     := oParamBody['matricula']
cCodTFF     := oParamBody['codposto']
cEscala     := oParamBody['escala']
cSeq        := oParamBody['sequencia']

cData := DtoS(dDataBase)

//SituaÁ„o do atendente-------------------------------------------------
cWhereSRA := JoinSQL(lMultFil, "SRA.RA_FILIAL", "SRA", "SRA", cFilTMP, "WHERE")

BeginSql Alias cAliasSRA
    SELECT RA_DEMISSA
    FROM %table:SRA% SRA
    WHERE %exp:cWhereSRA%
        AND SRA.RA_MAT = %exp:cCodMat%
        AND SRA.%NotDel%
EndSql

DbSelectArea(cAliasSRA)
(cAliasSRA)->(DbGoTop())

If (cAliasSRA)->(! Eof())
	cDtDemissa := (cAliasSRA)->RA_DEMISSA
EndIf

(cAliasSRA)->(DbCloseArea())

//ProjeÁ„o dos dias da semana:------------------------------------------
aRetProj := projSemana(cFilTMP, cEscala, cSeq)

//InformaÁıes do Posto:-------------------------------------------------
cJoinTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinABS := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTGS := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

BeginSql Alias cAliasTFF
    SELECT TFF.TFF_PERINI, 
            TFF.TFF_PERFIM, 
            TFF.TFF_PERICU, 
            TFF.TFF_INSALU, 
            TGS.TGS_COD, 
            TGS.TGS_DESCRI
    FROM %table:TFF% TFF
            INNER JOIN %table:TFL% TFL //Local - Contrato
                ON (%exp:cJoinTFL%
                AND TFL.TFL_CODIGO = TFF.TFF_CODPAI 
                AND TFL.%NotDel%)
            INNER JOIN %table:ABS% AB //Local - Cadastro
                ON (%exp:cJoinABS%
                AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
                AND AB.%NotDel%)
            INNER JOIN %table:TGS% TGS //Area de Supervis„o
                ON (%exp:cJoinTGS%
                AND TGS.TGS_COD = AB.ABS_CODSUP
                AND TGS.%NotDel%)
    WHERE %exp:cWhereTFF%
        AND TFF.TFF_COD = %exp:cCodTFF%
        AND TFF.%NotDel%
EndSql

DbSelectArea(cAliasTFF)
(cAliasTFF)->(DbGoTop())

If (cAliasTFF)->(!Eof())
	//STATUS INSALUBRIDADE/PERICULOSIDADE:
	If (cAliasTFF)->TFF_PERICU = '3'
		cPericul := "Proporcional"
	ElseIf (cAliasTFF)->TFF_PERICU = '2'
		cPericul := "Integral"
	Else
		cPericul := "N„o Possui"
	EndIf

	If (cAliasTFF)->TFF_INSALU = '3'
		cInsalub := "Proporcional"
	ElseIf (cAliasTFF)->TFF_INSALU = '2'
		cInsalub := "Integral"
	Else
		cInsalub := "N„o Possui"
	EndIf

	AADD(aInfTFF, {(cAliasTFF)->TFF_PERINI, ;
		(cAliasTFF)->TFF_PERFIM, ;
		EncodeUtf8(cPericul), ;
		EncodeUtf8(cInsalub), ;
		(cAliasTFF)->TGS_COD, ;
		(cAliasTFF)->TGS_DESCRI})
Else
	AADD(aInfTFF, {"","","","","",""})
EndIf

(cAliasTFF)->(DbCloseArea())


//CÛdigo da CCT:--------------------------------------------------------
cWhereRI4 := JoinSQL(lMultFil, "RI4.RI4_FILIAL", "RI4", "RI4", cFilTMP, "WHERE")
cFilSRJ := xFilial("SRJ", cFilTMP)

BeginSql Alias cAliasRI4
    SELECT RI4_CODCCT
    FROM %table:RI4% RI4
    WHERE %exp:cWhereRI4%
        AND RI4.RI4_FILSRJ = %exp:cFilSRJ%
        AND RI4.RI4_CODSRJ = %exp:cCodFuncao%
        AND RI4.%NotDel%
EndSql

DbSelectArea(cAliasRI4)
(cAliasRI4)->(DbGoTop())

If (cAliasRI4)->(! Eof())
	cCodCCT := (cAliasRI4)->RI4_CODCCT
EndIf

(cAliasRI4)->(DbCloseArea())

//BenefÌcios do Posto:---------------------------------------------
If !Empty(cCodCCT)
	cWhereSLY := JoinSQL(lMultFil, "SLY.LY_FILIAL", "SLY", "SLY", cFilTMP, "WHERE")

	BeginSql Alias cAliasTmp
        SELECT LY_CODIGO, LY_TIPO
        FROM %table:SLY% SLY
        WHERE %exp:cWhereSLY%
            AND SLY.LY_CHVENT = %exp:cCodCCT%
            AND SLY.LY_DTINI <= %exp:cData%
            AND SLY.LY_DTFIM >= %exp:cData%
            AND SLY.%NotDel%
	EndSql

	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())

	If (cAliasTmp)->(! Eof())
		While (cAliasTmp)->(! Eof())
			aBeneficio := mesaxBenef(Alltrim((cAliasTmp)->LY_CODIGO),Alltrim((cAliasTmp)->LY_TIPO)) //descriÁ„o e valor
			AADD(aBenef, {Alltrim((cAliasTmp)->LY_TIPO),; //Cod. tipo benefÌcio
			EncodeUtf8(AllTrim(aBeneficio[1,1])),; //DescriÁ„o benefÌcio
			aBeneficio[1,2]}) //Valor benefÌcio
			(cAliasTmp)->(DbSkip())
		Enddo
	EndIf
	(cAliasTmp)->(DbCloseArea())
EndIf

oResponse['infatend'] := {}

//Monta o Objeto JSon a ser retornado:
Aadd(oResponse['infatend'], JsonObject():New())

aTail(oResponse['infatend'])['nomfil']          := EncodeUtf8(AllTrim(FWFilialName(,cFilTMP)))
aTail(oResponse['infatend'])['iniposto']        := AllTrim(aInfTFF[1,1])
aTail(oResponse['infatend'])['fimposto']        := AllTrim(aInfTFF[1,2])
aTail(oResponse['infatend'])['periculosidade']  := AllTrim(aInfTFF[1,3])
aTail(oResponse['infatend'])['insalubridade']   := AllTrim(aInfTFF[1,4])
aTail(oResponse['infatend'])['codarea']         := AllTrim(aInfTFF[1,5])
aTail(oResponse['infatend'])['descarea']        := EncodeUtf8(AllTrim(aInfTFF[1,6]))
aTail(oResponse['infatend'])['projecao']        := aRetProj
aTail(oResponse['infatend'])['beneficios']      := aBenef
aTail(oResponse['infatend'])['dtDemissao']      := cDtDemissa

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de retorno de InformaÁ„o do posto e benefÌcios

oResponse - Json Object:

@author     Jack Junior
@since      15/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST infPosto WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cAliasTGY := GetNextAlias()
Local cAliasTDX := GetNextAlias()
Local cAliasTmp := GetNextAlias()
Local cAliasTFF := GetNextAlias()
Local cAliasRI4 := GetNextAlias()
Local cBody     := Self:GetContent()
Local cCodCCT   := ""
Local cCodFuncao:= ""
Local cCodMat   := ""
Local cCodTFF   := ""
Local cData     := ""
Local cFilTMP   := ""
Local cEscala   := ""
Local cPericul  := ""
Local cInsalub  := ""
Local cWhereTGY := ""
Local cWhereSLY := ""
Local cWhereTFF := ""
Local aBenef    := {}
Local aBeneficio:= {}
Local aProj     := {}
Local aRetProj  := {}
Local cSituacao := ""
Local aInfTFF   := {}
Local aSequenc  := {}
Local nQtPrev   := 0
Local nQtAloc   := 0
Local nX        := {}
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
cCodFuncao  := oParamBody['funcao']
cCodMat     := oParamBody['matricula']
cCodTFF     := oParamBody['codposto']
cEscala     := oParamBody['escala']
cDataIni    := oParamBody['dataIni']
cDataFim    := oParamBody['dataFim']

cData := DtoS(dDataBase)

//Sequencias da Escala:-----------------------------------------------
cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

BeginSql Alias cAliasTDX
    SELECT TDX.TDX_SEQTUR
    FROM %table:TDX% TDX
    WHERE %exp:cWhereTDX%
        AND TDX.TDX_CODTDW = %exp:cEscala%
        AND TDX.%NotDel%
EndSql

DbSelectArea(cAliasTDX)
(cAliasTDX)->(DbGoTop())

If (cAliasTDX)->(!Eof())
	While (cAliasTDX)->(! Eof())
		AADD(aSequenc, (cAliasTDX)->TDX_SEQTUR)
		(cAliasTDX)->(DbSkip())
	Enddo
EndIf

(cAliasTDX)->(DbCloseArea())

//ProjeÁ„o dos dias da semana de cada sequencia da escala:-------------
For nX := 1 To Len(aSequenc)
	aProj := projSemana(cFilTMP, cEscala, aSequenc[nX])
	AADD(aRetProj, {aSequenc[nX], aProj})
	aProj := {}
Next nX

//InformaÁıes do Posto:-------------------------------------------------
cJoinTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinABS := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTGS := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

BeginSql Alias cAliasTFF
    SELECT TFF.TFF_PERINI, 
            TFF.TFF_PERFIM, 
            TFF.TFF_PERICU, 
            TFF.TFF_INSALU, 
            TGS.TGS_COD, 
            TGS.TGS_DESCRI,
            TFF.TFF_QTPREV
    FROM %table:TFF% TFF
            INNER JOIN %table:TFL% TFL //Local - Contrato
                ON (%exp:cJoinTFL%
                AND TFL.TFL_CODIGO = TFF.TFF_CODPAI 
                AND TFL.%NotDel%)
            INNER JOIN %table:ABS% AB //Local - Cadastro
                ON (%exp:cJoinABS%
                AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
                AND AB.%NotDel%)
            INNER JOIN %table:TGS% TGS //Area de Supervis„o
                ON (%exp:cJoinTGS%
                AND TGS.TGS_COD = AB.ABS_CODSUP
                AND TGS.%NotDel%)
    WHERE %exp:cWhereTFF%
        AND TFF.TFF_COD = %exp:cCodTFF%
        AND TFF.%NotDel%
EndSql

DbSelectArea(cAliasTFF)
(cAliasTFF)->(DbGoTop())

If (cAliasTFF)->(!Eof())
	//STATUS INSALUBRIDADE/PERICULOSIDADE:
	If (cAliasTFF)->TFF_PERICU = '3'
		cPericul := "Proporcional"
	ElseIf (cAliasTFF)->TFF_PERICU = '2'
		cPericul := "Integral"
	Else
		cPericul := "N„o Possui"
	EndIf

	If (cAliasTFF)->TFF_INSALU = '3'
		cInsalub := "Proporcional"
	ElseIf (cAliasTFF)->TFF_INSALU = '2'
		cInsalub := "Integral"
	Else
		cInsalub := "N„o Possui"
	EndIf

	AADD(aInfTFF, {(cAliasTFF)->TFF_PERINI, ;
		(cAliasTFF)->TFF_PERFIM, ;
		EncodeUtf8(cPericul), ;
		EncodeUtf8(cInsalub), ;
		(cAliasTFF)->TGS_COD, ;
		(cAliasTFF)->TGS_DESCRI})

	nQtPrev := (cAliasTFF)->TFF_QTPREV
Else
	AADD(aInfTFF, {"","","","","",""})
EndIf

(cAliasTFF)->(DbCloseArea())

//N˙mero de pessoas alocadas no posto:
cWhereTGY := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TGY", "TGY", cFilTMP, "WHERE")

BeginSql Alias cAliasTGY
    SELECT COUNT (TGY_CODTFF) TGY_CODTFF
    FROM %table:TGY% TGY 
    WHERE %exp:cWhereTGY%
        AND TGY.TGY_CODTFF = %exp:cCodTFF%
        AND ((TGY.TGY_DTINI BETWEEN %exp:cDataIni% AND %exp:cDataFim%)
        OR (TGY.TGY_DTFIM BETWEEN %exp:cDataIni% AND %exp:cDataFim%)
        OR (%exp:cDataIni% BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM))
EndSql

DbSelectArea(cAliasTGY)
(cAliasTGY)->(DbGoTop())

If (cAliasTGY)->(!Eof())
	nQtAloc := (cAliasTGY)->TGY_CODTFF
EndIf

(cAliasTGY)->(DbCloseArea())

//CÛdigo da CCT:--------------------------------------------------------
cWhereRI4 := JoinSQL(lMultFil, "RI4.RI4_FILIAL", "RI4", "RI4", cFilTMP, "WHERE")
cFilSRJ := xFilial("SRJ", cFilTMP)

BeginSql Alias cAliasRI4
    SELECT RI4_CODCCT
    FROM %table:RI4% RI4
    WHERE %exp:cWhereRI4%
        AND RI4.RI4_FILSRJ = %exp:cFilSRJ%
        AND RI4.RI4_CODSRJ = %exp:cCodFuncao%
        AND RI4.%NotDel%
EndSql

DbSelectArea(cAliasRI4)
(cAliasRI4)->(DbGoTop())

If (cAliasRI4)->(! Eof())
	cCodCCT := (cAliasRI4)->RI4_CODCCT
EndIf

(cAliasRI4)->(DbCloseArea())

//BenefÌcios do Posto:---------------------------------------------
If !Empty(cCodCCT)
	cWhereSLY := JoinSQL(lMultFil, "SLY.LY_FILIAL", "SLY", "SLY", cFilTMP, "WHERE")

	BeginSql Alias cAliasTmp
        SELECT LY_CODIGO, LY_TIPO
        FROM %table:SLY% SLY
        WHERE %exp:cWhereSLY%
            AND SLY.LY_CHVENT = %exp:cCodCCT%
            AND SLY.LY_DTINI <= %exp:cData%
            AND SLY.LY_DTFIM >= %exp:cData%
            AND SLY.%NotDel%
	EndSql

	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())

	If (cAliasTmp)->(! Eof())
		While (cAliasTmp)->(! Eof())
			aBeneficio := mesaxBenef(Alltrim((cAliasTmp)->LY_CODIGO),Alltrim((cAliasTmp)->LY_TIPO)) //descriÁ„o e valor
			AADD(aBenef, {Alltrim((cAliasTmp)->LY_TIPO),; //Cod. tipo benefÌcio
			EncodeUtf8(AllTrim(aBeneficio[1,1])),; //DescriÁ„o benefÌcio
			aBeneficio[1,2]}) //Valor benefÌcio
			(cAliasTmp)->(DbSkip())
		Enddo
	EndIf
	(cAliasTmp)->(DbCloseArea())
EndIf

//SituaÁ„o do Posto:
If (nQtPrev-nQtAloc) < 1
	cSituacao := "Coberto"
ElseIf (nQtPrev-nQtAloc) > 0
	cSituacao := "Vago"
EndIf

oResponse['infPosto'] := {}

//Monta o Objeto JSon a ser retornado:
Aadd(oResponse['infPosto'], JsonObject():New())

aTail(oResponse['infPosto'])['nomfil']          := EncodeUtf8(AllTrim(FWFilialName(,cFilTMP)))
aTail(oResponse['infPosto'])['situacao']        := cSituacao
aTail(oResponse['infPosto'])['iniposto']        := AllTrim(aInfTFF[1,1])
aTail(oResponse['infPosto'])['fimposto']        := AllTrim(aInfTFF[1,2])
aTail(oResponse['infPosto'])['periculosidade']  := AllTrim(aInfTFF[1,3])
aTail(oResponse['infPosto'])['insalubridade']   := AllTrim(aInfTFF[1,4])
aTail(oResponse['infPosto'])['codarea']         := AllTrim(aInfTFF[1,5])
aTail(oResponse['infPosto'])['descarea']        := EncodeUtf8(AllTrim(aInfTFF[1,6]))
aTail(oResponse['infPosto'])['projecoes']       := aRetProj
aTail(oResponse['infPosto'])['beneficios']      := aBenef

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de verificaÁ„o de divergencia de Salario, Cargo, FunÁ„o e VT

oResponse - Json Object:

@author     Jack Junior
@since      24/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST compAloc WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local oFWSheet  := Nil
Local cAliasSRA := GetNextAlias()
Local cAliasTFF := GetNextAlias()
Local cBody     := Self:GetContent()
Local cFilTMP   := ""
Local cCodAtend := ""
Local cCodTFF   := ""
Local cCodMat   := ""
Local cFunAtend := ""
Local cCargAtend:= ""
Local cFunTFF   := ""
Local cCargTFF  := ""
Local cJoinSRJ  := ""
Local cJoinSM7  := ""
Local cJoinSRN  := ""
Local cWhereSRA := ""
Local cWhereTFF := ""
Local cMsgDiff  := ""
Local cMsgRet   := ""
Local cXmlPlan  := ""
Local nSalaTFF  := 0
Local nVTFunc  := 0
Local nSalaAtend:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
cCodAtend   := oParamBody['atendente'] //Atendente que est· alocando
cCodTFF     := oParamBody['codposto']  //Cod do posto

//codigo da funcao AA1
cCodMat := Posicione("AA1",1,xFilial("AA1", cFilTMP)+cCodAtend,"AA1_CDFUNC")

//InformaÁıes Atendente sendo alocado:--------------------------------
If !Empty(cCodMat)
	cJoinSM7 := JoinSQL(lMultFil, "SM7.M7_FILIAL", "SRA", "SM7", cFilTMP, "JOIN")
	cJoinSRN := JoinSQL(lMultFil, "SRN.RN_FILIAL", "SRA", "SRN", cFilTMP, "JOIN")
	cWhereSRA := JoinSQL(lMultFil, "SRA.RA_FILIAL", "SRA", "SRA", cFilTMP, "WHERE")

	BeginSql Alias cAliasSRA
        SELECT SRA.RA_CODFUNC, 
                SRA.RA_CARGO, 
                SRA.RA_SALARIO,
                SRN.RN_VUNIATU
        FROM %table:SRA% SRA
            LEFT JOIN %table:SM7% SM7
                ON %exp:cJoinSM7%
                AND SM7.M7_MAT = SRA.RA_MAT
                AND SM7.%NotDel%
            LEFT JOIN %table:SRN% SRN
                ON %exp:cJoinSRN%
                AND SRN.RN_COD = SM7.M7_CODIGO
                AND SRN.%NotDel%
        WHERE %exp:cWhereSRA%
            AND SRA.RA_MAT = %exp:cCodMat%
            AND SRA.%NotDel%
	EndSql

	DbSelectArea(cAliasSRA)
	(cAliasSRA)->(DbGoTop())

	If (cAliasSRA)->(!Eof())
		cFunAtend  := (cAliasSRA)->RA_CODFUNC
		cCargAtend := (cAliasSRA)->RA_CARGO
		nSalaAtend := (cAliasSRA)->RA_SALARIO
		nVTFunc   := (cAliasSRA)->RN_VUNIATU
	EndIf

	(cAliasSRA)->(DbCloseArea())
EndIf

//InformaÁıes Vaga do Posto:--------------------------------
If !Empty(cCodMat)
	cJoinSRJ := JoinSQL(lMultFil, "SRJ.RJ_FILIAL", "TFF", "SRJ", cFilTMP, "JOIN")
	cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

	BeginSql Alias cAliasTFF
        SELECT TFF.TFF_FUNCAO, 
                TFF.TFF_CARGO, 
                SRJ.RJ_SALARIO,
                TFF.TFF_CALCMD
        FROM %table:TFF% TFF
            INNER JOIN %table:SRJ% SRJ //Contrato
                ON %exp:cJoinSRJ%
                AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO
                AND SRJ.%NotDel%
        WHERE %exp:cWhereTFF%
            AND TFF.TFF_COD = %exp:cCodTFF%
            AND TFF.%NotDel%
	EndSql

	DbSelectArea(cAliasTFF)
	(cAliasTFF)->(DbGoTop())

	If (cAliasTFF)->(!Eof())
		cFunTFF  := (cAliasTFF)->TFF_FUNCAO
		cCargTFF := (cAliasTFF)->TFF_CARGO
		nSalaTFF := (cAliasTFF)->RJ_SALARIO
		cXmlPlan := (cAliasTFF)->TFF_CALCMD
	EndIf

	(cAliasTFF)->(DbCloseArea())
EndIf

//COMPARA«√O FUN«√O ATEND X POSTO
If !Empty(cFunAtend) .And. !Empty(cFunTFF)
	If cFunAtend != cFunTFF
		cMsgDiff := "FunÁ„o"
	EndIf
EndIf
//COMPARA«√O CARGO ATEND X POSTO
If !Empty(cCargAtend) .And. !Empty(cCargTFF)
	If cCargAtend != cCargTFF
		If !Empty(cMsgDiff)
			cMsgDiff += ", "
		EndIf
		cMsgDiff += "Cargo"
	EndIf
EndIf
//COMPARA«√O SALARIO ATEND X POSTO
If nSalaAtend != 0 .And. nSalaTFF != 0
	If nSalaAtend > nSalaTFF
		If !Empty(cMsgDiff)
			cMsgDiff += ", "
		EndIf
		cMsgDiff += "Sal·rio"
	EndIf
EndIf
//COMPARA«√O VT ATEND X POSTO
If !Empty(cXmlPlan) .And. nVTFunc != 0
	oFWSheet := FWUIWorkSheet():New(,.F. ) //instancia a planilha sem exibiÁ„o
	If MethIsMemberOf(oFWSheet,"ShowAllErr")
		oFWSheet:ShowAllErr(.F.)
	EndIf
	oFwSheet:LoadXmlModel(cXmlPlan)
	If oFWSheet:CellExists("VT_DIA")
		nVtPosto := oFwSheet:GetCellValue("VT_DIA")
	EndIf
	If ValType(nVtPosto) != 'N'
		nVtPosto := Val(nVtPosto)
	EndIf
	If nVTFunc > nVtPosto .And. nVtPosto > 0
		If !Empty(cMsgDiff)
			cMsgDiff += ", "
		EndIf
		cMsgDiff += "Vale Transporte"
	EndIf
EndIf

If !Empty(cMsgDiff)
	cMsgRet := "DivergÍncias: " + cMsgDiff
EndIf

oResponse['compAloc'] := {}

//Monta o Objeto JSon a ser retornado:
Aadd(oResponse['compAloc'], JsonObject():New())
aTail(oResponse['compAloc'])['divergencias']    := EncodeUTF8(cMsgRet)

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de retorno de InformaÁ„o de benefÌcios do posto/local/CCT nessa hierarquia !

oResponse - Json Object:

@author     Jack Junior
@since      01/02/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST benefPosto WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cAliasABS := GetNextAlias()
Local cAliasCCT := GetNextAlias()
Local cAliasTFF := GetNextAlias()
Local cAliasRI4 := GetNextAlias()
Local cBody     := Self:GetContent()
Local cCodCCT   := ""
Local cCodFuncao:= ""
Local cCodTFF   := ""
Local cData     := ""
Local cFilTMP   := ""
Local cWhereSLY := ""
Local aBenef    := {}
Local aBeneficio:= {}
Local lMultFil  := IsMultFil()
Local cAliasSLY := ""
Local cLikeTFF := ""
Local aTests011:= {}

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
cCodFuncao  := oParamBody['funcao']
cCodTFF     := oParamBody['codposto']
cCodABS     := oParamBody['codlocal']
cDataIni    := oParamBody['dataIni']
cDataFim    := oParamBody['dataFim']

cData := DtoS(dDataBase)

aTests011 := TabelaS011()

//CÛdigo da CCT:--------------------------------------------------------
cWhereRI4 := JoinSQL(lMultFil, "RI4.RI4_FILIAL", "RI4", "RI4", cFilTMP, "WHERE")
cFilSRJ := xFilial("SRJ", cFilTMP)

BeginSql Alias cAliasRI4
    SELECT RI4_CODCCT
    FROM %table:RI4% RI4
    WHERE %exp:cWhereRI4%
        AND RI4.RI4_FILSRJ = %exp:cFilSRJ%
        AND RI4.RI4_CODSRJ = %exp:cCodFuncao%
        AND RI4.%NotDel%
EndSql

DbSelectArea(cAliasRI4)
(cAliasRI4)->(DbGoTop())

If (cAliasRI4)->(! Eof())
	cCodCCT := (cAliasRI4)->RI4_CODCCT
EndIf

(cAliasRI4)->(DbCloseArea())

//BenefÌcios do Posto: TFF---------------------------------------------
cWhereSLY := JoinSQL(lMultFil, "SLY.LY_FILIAL", "SLY", "SLY", cFilTMP, "WHERE")
cAliasSLY := 'TDX'
cLikeTFF := cCodTFF+"%"

BeginSql Alias cAliasTFF
    SELECT LY_CODIGO, LY_TIPO
    FROM %table:SLY% SLY
    WHERE %exp:cWhereSLY%
        AND SLY.LY_ALIAS = %exp:cAliasSLY%
        AND SLY.LY_CHVENT LIKE %exp:cLikeTFF%
        AND SLY.LY_DTINI <= %exp:cData%
        AND SLY.LY_DTFIM >= %exp:cData%
        AND SLY.%NotDel%
EndSql

DbSelectArea(cAliasTFF)
(cAliasTFF)->(DbGoTop())

If (cAliasTFF)->(! Eof())
	While (cAliasTFF)->(! Eof())
		aBeneficio := mesaxBenef(Alltrim((cAliasTFF)->LY_CODIGO),Alltrim((cAliasTFF)->LY_TIPO)) //descriÁ„o e valor
		AADD(aBenef, {EncodeUtf8(Alltrim((cAliasTFF)->LY_TIPO)),; //Cod. tipo benefÌcio
		EncodeUtf8(AllTrim(aBeneficio[1,1])),; //DescriÁ„o benefÌcio
		EncodeUtf8(MascReais(aBeneficio[1,2])),; //Valor benefÌcio
		EncodeUtf8(DescBenS011(((cAliasTFF)->LY_TIPO),aTests011)),; //DescriÁ„o S011 Tipo BenefÌcio
		EncodeUtf8("Posto")}) //Origem do benefÌcio
		(cAliasTFF)->(DbSkip())
	Enddo
EndIf
(cAliasTFF)->(DbCloseArea())

//BenefÌcios do Posto: Local---------------------------------------------
cWhereSLY := JoinSQL(lMultFil, "SLY.LY_FILIAL", "SLY", "SLY", cFilTMP, "WHERE")
cAliasSLY := 'ABS'

BeginSql Alias cAliasABS
    SELECT LY_CODIGO, LY_TIPO
    FROM %table:SLY% SLY
    WHERE %exp:cWhereSLY%
        AND SLY.LY_ALIAS = %exp:cAliasSLY%
        AND SLY.LY_CHVENT = %exp:cCodABS%
        AND SLY.LY_DTINI <= %exp:cData%
        AND SLY.LY_DTFIM >= %exp:cData%
        AND SLY.%NotDel%
EndSql

DbSelectArea(cAliasABS)
(cAliasABS)->(DbGoTop())

If (cAliasABS)->(! Eof())
	While (cAliasABS)->(! Eof())
		//Verifica se j· foi adicionado o beneficio
		If aScan(aBenef,{|x| x[1] == Alltrim((cAliasABS)->LY_TIPO)}) == 0
			aBeneficio := mesaxBenef(Alltrim((cAliasABS)->LY_CODIGO),Alltrim((cAliasABS)->LY_TIPO)) //descriÁ„o e valor
			AADD(aBenef, {EncodeUtf8(Alltrim((cAliasABS)->LY_TIPO)),; //Cod. tipo benefÌcio
			EncodeUtf8(AllTrim(aBeneficio[1,1])),; //DescriÁ„o benefÌcio
			EncodeUtf8(MascReais(aBeneficio[1,2])),; //Valor benefÌcio
			EncodeUtf8(DescBenS011(((cAliasABS)->LY_TIPO),aTests011)),; //DescriÁ„o S011 Tipo BenefÌcio
			EncodeUtf8("Local")}) //Origem do benefÌcio
		EndIf
		(cAliasABS)->(DbSkip())
	Enddo
EndIf
(cAliasABS)->(DbCloseArea())

//BenefÌcios do Posto: CCT---------------------------------------------
If !Empty(cCodCCT)
	cWhereSLY := JoinSQL(lMultFil, "SLY.LY_FILIAL", "SLY", "SLY", cFilTMP, "WHERE")
	cAliasSLY := 'SWY'

	BeginSql Alias cAliasCCT
        SELECT LY_CODIGO, LY_TIPO
        FROM %table:SLY% SLY
        WHERE %exp:cWhereSLY%
            AND SLY.LY_ALIAS = %exp:cAliasSLY%
            AND SLY.LY_CHVENT = %exp:cCodCCT%
            AND SLY.LY_DTINI <= %exp:cData%
            AND SLY.LY_DTFIM >= %exp:cData%
            AND SLY.%NotDel%
	EndSql

	DbSelectArea(cAliasCCT)
	(cAliasCCT)->(DbGoTop())

	If (cAliasCCT)->(! Eof())
		While (cAliasCCT)->(! Eof())
			//Verifica se j· foi adicionado o beneficio
			If aScan(aBenef,{|x| x[1] == Alltrim((cAliasCCT)->LY_TIPO)}) == 0
				aBeneficio := mesaxBenef(Alltrim((cAliasCCT)->LY_CODIGO),Alltrim((cAliasCCT)->LY_TIPO)) //descriÁ„o e valor
				AADD(aBenef, {EncodeUtf8(Alltrim((cAliasCCT)->LY_TIPO)),; //Cod. tipo benefÌcio
				EncodeUtf8(AllTrim(aBeneficio[1,1])),; //DescriÁ„o benefÌcio
				EncodeUtf8(MascReais(aBeneficio[1,2])),; //Valor benefÌcio
				EncodeUtf8(DescBenS011(((cAliasCCT)->LY_TIPO),aTests011)),; //DescriÁ„o S011 Tipo BenefÌcio
				EncodeUtf8("ConvenÁ„o Coletiva de Trabalho")}) //Origem do benefÌcio
			EndIf
			(cAliasCCT)->(DbSkip())
		Enddo
	EndIf
	(cAliasCCT)->(DbCloseArea())
EndIf

oResponse['benefPosto'] := {}

//Monta o Objeto JSon a ser retornado:
Aadd(oResponse['benefPosto'], JsonObject():New())

aTail(oResponse['benefPosto'])['nomfil']      := EncodeUtf8(AllTrim(FWFilialName(,cFilTMP)))
aTail(oResponse['benefPosto'])['beneficios']  := aBenef

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de retorno de Funcion·rios Ociosos

@Param cFil - Filial selecionada no front end
        cData - Data selecionada no front end

oResponse - Json Object:

{
    "atendOcioso": [
        {
            "codtec": "D0MG0010F00020",
            "nomtec": "MARIA JOS…",
            "codmat": "",
            "admissao": "",
            "funcao": "",
            "descfunc": "",
            "codcliente": "000001",
            "cliloja": "01",
            "clinome": "TOTVS",
            "codlocal": "00000003",
            "desclocal": "TOTVS BH",
            "codposto": "000089",
            "iniposto": "20230101",
            "codarea": "",
            "descarea": ""
        }
    ]
}

@author     Weverton Lima
@since      31/02/2024
/*/
//------------------------------------------------------------------------------

WSMETHOD GET atendOcioso WSRECEIVE cFil, cData, cArea WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cDate     := ""
Local cAreaIdle := ""
Local cJoinABS  := ""
Local cJoinTFJ  := ""
Local cJoinTFL  := ""
Local cJoinSA1  := ""
Local cJoinSRA  := ""
Local cJoinTGY  := ""
Local cJoinSQG  := ""
Local cJoinSQS  := ""
Local cJoinCN9  := ""
Local cJoinTGS  := ""
Local cJoinSRJ  := ""
Local cWhereAA1 := ""
Local lMultFil  := IsMultFil()

cFilTMP     := self:cFil
cDate       := self:cData
cAreaIdle   := self:cArea

//Tratamento de multifilial:
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL",  "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFF", "TFJ", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL" , "TFJ", "SA1", cFilTMP, "JOIN")
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL",  "AA1", "SRA", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "AA1", "TGY", cFilTMP, "JOIN")
cJoinSQG  := JoinSQL(lMultFil, "SQG.QG_FILIAL",  "SRA", "SQG", cFilTMP, "JOIN")
cJoinSQS  := JoinSQL(lMultFil, "SQS.QS_FILIAL",  "SQG", "SQS", cFilTMP, "JOIN")
cJoinCN9  := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL",  "SRA", "SRJ", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TGY", "TFF", cFilTMP, "JOIN")
cWhereAA1 := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "AA1", "AA1", cFilTMP, "WHERE")


BeginSql Alias cAliasTmp
    SELECT AA1.AA1_CODTEC, AA1.AA1_NOMTEC, SRA.RA_MAT, SRA.RA_ADMISSA, SRJ.RJ_FUNCAO,;
           SRJ.RJ_DESC, AB.ABS_LOCAL, AB.ABS_DESCRI,TFF.TFF_COD, TFF.TFF_PERINI,;
					 TFF.TFF_PRODUT, TFF.TFF_CONTRT, SA1.A1_NOME, SA1.A1_LOJA, SA1.A1_COD,TGS.TGS_COD,;
					 TGS.TGS_DESCRI, TGY.TGY_ATEND
    FROM %table:AA1% AA1
        LEFT JOIN %table:SRA% SRA //Funcion·rios
            ON %exp:cJoinSRA%
	        	AND SRA.RA_MAT = AA1.AA1_CDFUNC
            AND SRA.%NotDel%
        LEFT JOIN %table:SRJ% SRJ //FunÁ„o/
            ON %exp:cJoinSRJ%
	        	AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC
            AND SRJ.%NotDel%
        LEFT JOIN %table:TGY% TGY //TGY - ALOCA«√O
            ON %exp:cJoinTGY%
	        	AND TGY.TGY_ATEND = AA1.AA1_CODTEC
            AND TGY.%NotDel%
        LEFT JOIN %table:TFF% TFF //Posto - Contrato
            ON %exp:cJoinTFF%
	        	AND TFF.TFF_COD = TGY.TGY_CODTFF
          	AND TFF.%NotDel%		
        LEFT JOIN %table:TFL% TFL //Local - Contrato
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
            AND TFL.%NotDel%
        LEFT JOIN %table:TFJ% TFJ //CONTRATOS
						ON %exp:cJoinTFJ%
						AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
						AND TFJ.%NotDel%
				LEFT JOIN %table:SA1% SA1 //CLIENTES
						ON %exp:cJoinSA1%
						AND SA1.A1_COD = TFJ.TFJ_CODENT
						AND SA1.A1_LOJA = TFJ.TFJ_LOJA
						AND SA1.%NotDel%
				LEFT JOIN %table:ABS% AB //Local - Cadastro
            ON %exp:cJoinABS%
            AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
            AND AB.%NotDel%
        LEFT JOIN %table:TGS% TGS //¡rea de Supervis„o
            ON %exp:cJoinTGS%
	        	AND TGS.TGS_COD = AB.ABS_CODSUP
            AND TGS.%NotDel%
        WHERE %exp:cWhereAA1%
            AND TGY.TGY_RESTEC != '1' //N√O … RESERVA T…CNICA 
            AND TGY.TGY_ULTALO != ''
						AND TGS.TGS_COD = %exp:cAreaIdle%
            AND TGY.TGY_ULTALO < %exp:cDate%
            AND NOT (TGY.TGY_DTINI < %exp:cDate% AND TGY.TGY_DTFIM > %exp:cDate%) 
            AND AA1.%NotDel%  
EndSql


DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['atendOcioso'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['atendOcioso'], JsonObject():New())

		aTail(oResponse['atendOcioso'])['codtec']     := AllTrim((cAliasTmp)->AA1_CODTEC)
		aTail(oResponse['atendOcioso'])['nomtec']     := EncodeUTF8(AllTrim((cAliasTmp)->AA1_NOMTEC))
		aTail(oResponse['atendOcioso'])['codmat']     := AllTrim((cAliasTmp)->RA_MAT)
		aTail(oResponse['atendOcioso'])['admissao']   := AllTrim((cAliasTmp)->RA_ADMISSA)
		aTail(oResponse['atendOcioso'])['funcao']     := AllTrim((cAliasTmp)->RJ_FUNCAO)
		aTail(oResponse['atendOcioso'])['descfunc']   := EncodeUTF8(AllTrim((cAliasTmp)->RJ_DESC))
		aTail(oResponse['atendOcioso'])['codcliente'] := AllTrim((cAliasTmp)->A1_COD)
		aTail(oResponse['atendOcioso'])['cliloja']    := AllTrim((cAliasTmp)->A1_LOJA)
		aTail(oResponse['atendOcioso'])['clinome']    := AllTrim((cAliasTmp)->A1_NOME)
		aTail(oResponse['atendOcioso'])['codlocal']   := AllTrim((cAliasTmp)->ABS_LOCAL)
		aTail(oResponse['atendOcioso'])['desclocal']  := EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		aTail(oResponse['atendOcioso'])['codposto']   := AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['atendOcioso'])['iniposto']   := AllTrim((cAliasTmp)->TFF_PERINI)
		aTail(oResponse['atendOcioso'])['codcot']			:= AllTrim((cAliasTmp)->TFF_CONTRT)
		aTail(oResponse['atendOcioso'])['descposto']  := EncodeUTF8(AllTrim((cAliasTmp)->TFF_PRODUT))
		aTail(oResponse['atendOcioso'])['codarea']    := AllTrim((cAliasTmp)->TGS_COD)
		aTail(oResponse['atendOcioso'])['descarea']   := EncodeUTF8(AllTrim((cAliasTmp)->TGS_DESCRI))


		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL
return


WSMETHOD GET areaSup WSRECEIVE cFil WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cFilTMP   := ''
Local cWhereTGS := ''


cWhereTGS := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "TGS", "TGS", cFilTMP, "WHERE")


Self:SetContentType("application/json")

cFilTMP := self:cFil

BeginSql Alias cAliasTmp
    SELECT TGS.TGS_COD, TGS.TGS_DESCRI
    FROM %table:TGS% TGS
    WHERE %exp:cWhereTGS%  //FILIAL IGUAL A DA SOLICITA«√O DO FRONT
    AND TGS.%NotDel% //N√O PEGA O QUE EST¡ APAGADO DADOS VAZIO 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['areaSup'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['areaSup'], JsonObject():New())

		aTail(oResponse['areaSup'])['codarea']     := AllTrim((cAliasTmp)->TGS_COD)
		aTail(oResponse['areaSup'])['descarea']   := EncodeUTF8(AllTrim((cAliasTmp)->TGS_DESCRI))

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

MÈtodo POST de orÁamentos para filtro de Item Extra Operacional - Fluxo Contrato

@Param cBody - Exemplo:
{
    "filial":"D MG 01 ",
    "clientes":[{"value":"00000101"},{"value":"00000201"}]
}

filial(String) - Apenas uma (Combo Box no front)
clientes(Array) - CLIENTE+LOJA nenhum ou mais (Mult-select no front)

@author     Jack Junior
@since      12/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieocOrc WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cFilTMP   := ""
Local cInCli	:= ""
Local cWhereCli	:= ""
Local cWhereTFJ	:= ""
Local cJoinTFL  := ""
Local cJoinTFF  := ""
Local CJoinCN9	:= ""
Local aClientes := {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP   := oParamBody['filial']
aClientes := oParamBody['clientes']

//Monta o where de clientes com base na seleÁ„o do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA = '" + aClientes[1]["value"] + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli += "'" +aClientes[nX]["value"] + "'"
	Next nX
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Ajusta Chave FILIAL de acordo com par‚metro Multifilial
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
CJoinCN9 := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cWhereTFJ := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFJ", "TFJ", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFJ.TFJ_CODIGO, TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV, TFJ.TFJ_PROPOS, TFJ.TFJ_PREVIS
    FROM %table:TFJ% TFJ
        INNER JOIN %table:TFL% TFL //Local - Contrato
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO 
            AND TFL.%NotDel%
        INNER JOIN %table:TFF% TFF //Posto - Contrato
            ON %exp:cJoinTFF%
	        AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
            AND TFF.%NotDel%
		INNER JOIN %table:CN9% CN9 //Contrato
            ON %exp:cJoinCN9%
            AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT
            AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
            AND CN9.%NotDel%
    WHERE %exp:cWhereTFJ%
            AND TFJ.TFJ_STATUS = '1' //OrÁamentos ativos
			AND %exp:cWhereCli%		 //Filtra clientes
			AND CN9.CN9_SITUAC = '05' //Contratos ativos
            AND TFJ.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Orcamentos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Orcamentos'], JsonObject():New())

		//OR«AMENTO
		aTail(oResponse['Orcamentos'])['codOrcamento']	:= AllTrim((cAliasTmp)->TFJ_CODIGO)
		aTail(oResponse['Orcamentos'])['codContrato']	:= AllTrim((cAliasTmp)->TFJ_CONTRT)
		aTail(oResponse['Orcamentos'])['codRevisCont']	:= AllTrim((cAliasTmp)->TFJ_CONREV)
		aTail(oResponse['Orcamentos'])['codProposta']	:= AllTrim((cAliasTmp)->TFJ_PROPOS)
		aTail(oResponse['Orcamentos'])['codRevisProp']	:= AllTrim((cAliasTmp)->TFJ_PREVIS)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de LOCAIS para filtro de Item Extra Operacional - Fluxo Contrato

@Param cBody - Exemplo:
{
    "filial":"D MG 01 ",
    "clientes":[],
    "orcamentos":[{"value":"00000000266"}]
}

filial(String) - Apenas uma (Combo Box no front)
clientes(Array) - CLIENTE+LOJA (SA1_COD+SA1_LOJA) nenhum ou mais (Mult-select no front)
orcamentos(Array) - COD OR«AMENTO (TFJ_CODIGO) nenhum ou mais (Mult-select no front)

@author     Jack Junior
@since      12/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieocLocal WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cInCli	:= ""
Local cInOrc	:= ""
Local cFilTMP   := ""
Local cJoinTFJ	:= ""
Local cJoinABS	:= ""
Local cJoinTFF	:= ""
Local CJoinCN9	:= ""
Local cWhereCli	:= ""
Local cWhereOrc	:= ""
Local cWhereTFL := ""
Local aOrcamento:= {}
Local aClientes := {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aClientes	:= oParamBody['clientes']
aOrcamento  := oParamBody['orcamentos']

//Monta o where de clientes com base na seleÁ„o do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA = '" + aClientes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli +=  "'" + aClientes[nX]["value"]  + "'"
	Next nX
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Monta o where de orÁamentos com base na seleÁ„o do filtro anterior no Front-End
If ValType(aOrcamento) = 'U' .Or. Len(aOrcamento) = 0
	cWhereOrc := "1 = 1"
ElseIf Len(aOrcamento) = 1
	cWhereOrc := "TFJ.TFJ_CODIGO = '" + aOrcamento[1]["value"] + "'"
Else
	For nX = 1 To Len(aOrcamento)
		If nX > 1
			cInOrc += ","
		EndIf
		cInOrc +=  "'" + aOrcamento[nX]["value"] + "'"
	Next nX
	cWhereOrc := "TFJ.TFJ_CODIGO IN ("+cInOrc+")"
EndIf

cWhereOrc := sqlEmbeded(cWhereOrc)

//Ajusta Chave FILIAL de acordo com par‚metro Multifilial
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
CJoinCN9 := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cWhereTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFL", "TFL", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFL.TFL_CODIGO, TFL.TFL_LOCAL, AB.ABS_DESCRI
    FROM %table:TFL% TFL
        INNER JOIN %table:TFJ% TFJ //OrÁamento
            ON %exp:cJoinTFJ%
            AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
            AND TFJ.%NotDel%
		INNER JOIN %table:TFF% TFF //Posto - Contrato
            ON %exp:cJoinTFF%
	        AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
            AND TFF.%NotDel% 
        INNER JOIN %table:ABS% AB //Local cadastro
            ON %exp:cJoinABS%
	        AND AB.ABS_LOCAL = TFL.TFL_LOCAL
            AND AB.%NotDel% 
		INNER JOIN %table:CN9% CN9 //Contrato
            ON %exp:cJoinCN9%
            AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT
            AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
            AND CN9.%NotDel%
    WHERE %exp:cWhereTFL%
	        AND TFJ.TFJ_STATUS = '1' //OrÁamentos ativos
			AND %exp:cWhereOrc%	  //Filtra orÁamentos
			AND %exp:cWhereCli%	  //Filtra clientes
			AND CN9.CN9_SITUAC = '05' //Contratos ativos
            AND TFL.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Locais'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Locais'], JsonObject():New())

		//OR«AMENTO
		aTail(oResponse['Locais'])['codTFL']	:= AllTrim((cAliasTmp)->TFL_CODIGO)
		aTail(oResponse['Locais'])['codLocal']	:= AllTrim((cAliasTmp)->TFL_LOCAL)
		aTail(oResponse['Locais'])['descLocal']	:= AllTrim((cAliasTmp)->ABS_DESCRI)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de POSTOS para filtro de Item Extra Operacional - Fluxo Contrato

@Param cBody - Exemplo:
{
    "filial":"D MG 01 ",
    "clientes":[{"value":"00000101"},{"value":"00000201"}],
    "orcamentos":[{"value":"00000000266"}],
    "locais":[{"value":"000388"}]
}

filial(String) - Apenas uma (Combo Box no front)
clientes(Array) - CLIENTE+LOJA (SA1_COD+SA1_LOJA) nenhum ou mais (Mult-select no front)
orcamentos(Array) - COD OR«AMENTO (TFJ_CODIGO) nenhum ou mais (Mult-select no front)
locais(Array) - COD LOCAL (TFL_CODIGO) nenhum ou mais (Mult-select no front)

@author     Jack Junior
@since      12/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieocPosto WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cInCli	:= ""
Local cInLoc	:= ""
Local cInOrc	:= ""
Local cFilTMP   := ""
Local cJoinTFL	:= ""
Local cJoinTFJ	:= ""
Local cJoinSB1	:= ""
Local CJoinCN9	:= ""
Local cWhereTFF	:= ""
Local cWhereCli	:= ""
Local cWhereLoc	:= ""
Local cWhereOrc	:= ""
Local aClientes := {}
Local aLocais	:= {}
Local aOrcamento:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aClientes	:= oParamBody['clientes']
aOrcamento  := oParamBody['orcamentos']
aLocais		:= oParamBody['locais']

//Monta o where de clientes com base na seleÁ„o do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA = '" + aClientes[1]["value"] + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli += "'" + aClientes[nX]["value"] + "'"
	Next nX
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Monta o where de orÁamentos com base na seleÁ„o do filtro anterior no Front-End
If ValType(aOrcamento) = 'U' .Or. Len(aOrcamento) = 0
	cWhereOrc := "1 = 1"
ElseIf Len(aOrcamento) = 1
	cWhereOrc := "TFJ.TFJ_CODIGO = '" + aOrcamento[1]["value"] + "'"
Else
	For nX = 1 To Len(aOrcamento)
		If nX > 1
			cInOrc += ","
		EndIf
		cInOrc +=  "'" + aOrcamento[nX]["value"] + "'"
	Next nX
	cWhereOrc := "TFJ.TFJ_CODIGO IN ("+cInOrc+")"
EndIf

cWhereOrc := sqlEmbeded(cWhereOrc)

//Monta o where de locais com base na seleÁ„o do filtro anterior no Front-End
If ValType(aLocais) = 'U' .Or. Len(aLocais) = 0
	cWhereLoc := "1 = 1"
ElseIf Len(aLocais) = 1
	cWhereLoc := "TFL.TFL_CODIGO = '" + aLocais[1]["value"] + "'"
Else
	For nX = 1 To Len(aLocais)
		If nX > 1
			cInLoc += ","
		EndIf
		cInLoc += "'" + aLocais[nX]["value"] + "'"
	Next nX
	cWhereLoc := "TFL.TFL_CODIGO IN ("+cInLoc+")"
EndIf

cWhereLoc := sqlEmbeded(cWhereLoc)

//Ajusta Chave FILIAL de acordo com par‚metro Multifilial
cJoinTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinTFJ := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinSB1 := JoinSQL(lMultFil, "SB1.B1_FILIAL", "TFF", "SB1", cFilTMP, "JOIN")
CJoinCN9 := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFF.TFF_COD, TFF.TFF_PRODUT, SB1.B1_DESC
    FROM %table:TFF% TFF
	    INNER JOIN %table:TFL% TFL //Local
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
            AND TFL.%NotDel%
        INNER JOIN %table:TFJ% TFJ //OrÁamento
            ON %exp:cJoinTFJ%
            AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
            AND TFJ.%NotDel%
        INNER JOIN %table:SB1% SB1 //Cadastro Produtos
            ON %exp:cJoinSB1%
	        AND SB1.B1_COD = TFF.TFF_PRODUT
            AND SB1.%NotDel% 
		INNER JOIN %table:CN9% CN9 //Contrato
            ON %exp:cJoinCN9%
            AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT
            AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
            AND CN9.%NotDel%
    WHERE %exp:cWhereTFF%
	        AND TFJ.TFJ_STATUS = '1' //OrÁamentos ativos
			AND %exp:cWhereOrc%	  //Filtra orÁamentos
			AND %exp:cWhereCli%	  //Filtra clientes
			AND %exp:cWhereLoc%	  //Filtra locais
			AND CN9.CN9_SITUAC = '05' //Contratos ativos
            AND TFF.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Postos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Postos'], JsonObject():New())

		//OR«AMENTO
		aTail(oResponse['Postos'])['codTFF']	:= AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['Postos'])['codProd']	:= AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['Postos'])['descProd']	:= EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de Busca dos OrÁamentos/Contratos / Item Extra Operacional - Fluxo Contrato

@Param cBody - Exemplo:
{
    "filial":"D MG 01 ",
    "clientes":[{"value":"00000101"},{"value":"00000201"}],
    "orcamentos":[{"value":"00000000266"}],
    "locais":[{"value":"000388"}]
}

filial(String) - Apenas uma (Combo Box no front)
clientes(Array) - CLIENTE+LOJA (SA1_COD+SA1_LOJA) nenhum ou mais (Mult-select no front)
orcamentos(Array) - COD OR«AMENTO (TFJ_CODIGO) nenhum ou mais (Mult-select no front)
locais(Array) - COD LOCAL (TFL_CODIGO) nenhum ou mais (Mult-select no front)

@author     Jack Junior
@since      12/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieocBuscar WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cInCli	:= ""
Local cInLoc	:= ""
Local cInOrc	:= ""
Local cInPost	:= ""
Local cFilTMP   := ""
Local cJoinTFL	:= ""
Local cJoinTFF	:= ""
Local cJoinSA1	:= ""
Local CJoinCN9	:= ""
Local cWhereTFF	:= ""
Local cWhereCli	:= ""
Local cWhereLoc	:= ""
Local cWhereOrc	:= ""
Local cWherePost:= ""
Local aClientes := {}
Local aLocais	:= {}
Local aOrcamento:= {}
Local aPostos	:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aClientes	:= oParamBody['clientes']
aOrcamento  := oParamBody['orcamentos']
aLocais		:= oParamBody['locais']
aPostos		:= oParamBody['postos']

//Monta o where de clientes com base na seleÁ„o do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA = '" + aClientes[1]["value"] + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli += "'" + aClientes[nX]["value"] + "'"
	Next nX
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Monta o where de orÁamentos com base na seleÁ„o do filtro anterior no Front-End
If ValType(aOrcamento) = 'U' .Or. Len(aOrcamento) = 0
	cWhereOrc := "1 = 1"
ElseIf Len(aOrcamento) = 1
	cWhereOrc := "TFJ.TFJ_CODIGO = '" + aOrcamento[1]["value"] + "'"
Else
	For nX = 1 To Len(aOrcamento)
		If nX > 1
			cInOrc += ","
		EndIf
		cInOrc += "'" + aOrcamento[nX]["value"] + "'"
	Next nX
	cWhereOrc := "TFJ.TFJ_CODIGO IN ("+cInOrc+")"
EndIf

cWhereOrc := sqlEmbeded(cWhereOrc)

//Monta o where de locais com base na seleÁ„o do filtro anterior no Front-End
If ValType(aLocais) = 'U' .Or. Len(aLocais) = 0
	cWhereLoc := "1 = 1"
ElseIf Len(aLocais) = 1
	cWhereLoc := "TFL.TFL_CODIGO = '" + aLocais[1]["value"] + "'"
Else
	For nX = 1 To Len(aLocais)
		If nX > 1
			cInLoc += ","
		EndIf
		cInLoc += "'" + aLocais[nX]["value"] + "'"
	Next nX
	cWhereLoc := "TFL.TFL_CODIGO IN ("+cInLoc+")"
EndIf

cWhereLoc := sqlEmbeded(cWhereLoc)

//Monta o where de postos com base na seleÁ„o do filtro anterior no Front-End
If ValType(aPostos) = 'U' .Or. Len(aPostos) = 0
	cWherePost := "1 = 1"
ElseIf Len(aPostos) = 1
	cWherePost := "TFF.TFF_COD = '" + aPostos[1]["value"] + "'"
Else
	For nX = 1 To Len(aPostos)
		If nX > 1
			cInPost += ","
		EndIf
		cInPost += "'" + aPostos[nX]["value"] + "'"
	Next nX
	cWherePost := "TFF.TFF_COD IN ("+cInPost+")"
EndIf

cWherePost := sqlEmbeded(cWherePost)

//Ajusta Chave FILIAL de acordo com par‚metro Multifilial
cJoinTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cJoinSA1 := JoinSQL(lMultFil, "SA1.A1_FILIAL", "TFJ", "SA1", cFilTMP, "JOIN")
CJoinCN9 := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "TFJ", "CN9", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFJ.TFJ_CODIGO, TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV, TFJ.TFJ_PROPOS, TFJ.TFJ_PREVIS, SA1.A1_NOME, SA1.A1_LOJA
    FROM %table:TFJ% TFJ
	    INNER JOIN %table:TFL% TFL //Local
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO
            AND TFL.%NotDel%
		INNER JOIN %table:TFF% TFF //Posto - Contrato
            ON %exp:cJoinTFF%
	        AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
            AND TFF.%NotDel% 
		INNER JOIN %table:SA1% SA1 //Cliente - Cadastro
			ON %exp:cJoinSA1%
	        AND SA1.A1_COD = TFJ.TFJ_CODENT
			AND SA1.A1_LOJA = TFJ.TFJ_LOJA
            AND SA1.%NotDel%
		INNER JOIN %table:CN9% CN9 //Contrato
            ON %exp:cJoinCN9%
            AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT
            AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
            AND CN9.%NotDel%
    WHERE %exp:cWhereTFF%
			AND %exp:cWhereOrc%	  //Filtra orÁamentos
			AND %exp:cWhereCli%	  //Filtra clientes
			AND %exp:cWhereLoc%	  //Filtra locais
			AND %exp:cWherePost%  //Filtra postos
			AND CN9.CN9_SITUAC = '05' //Contratos ativos
			AND TFJ.TFJ_STATUS = '1' //OrÁamentos ativos
            AND TFF.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Orcamentos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Orcamentos'], JsonObject():New())

		//OR«AMENTO 
		aTail(oResponse['Orcamentos'])['codOrc']	:= AllTrim((cAliasTmp)->TFJ_CODIGO)
		aTail(oResponse['Orcamentos'])['codContr']	:= AllTrim((cAliasTmp)->TFJ_CONTRT)
		aTail(oResponse['Orcamentos'])['codConrev']	:= AllTrim((cAliasTmp)->TFJ_CONREV)
		aTail(oResponse['Orcamentos'])['codPropos']	:= AllTrim((cAliasTmp)->TFJ_PROPOS)
		aTail(oResponse['Orcamentos'])['codPrevis']	:= AllTrim((cAliasTmp)->TFJ_PREVIS)
		aTail(oResponse['Orcamentos'])['cliNome']	:= EncodeUTF8(AllTrim((cAliasTmp)->A1_NOME))
		aTail(oResponse['Orcamentos'])['cliLoja']	:= AllTrim((cAliasTmp)->A1_LOJA)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de Locais para item extra operacional - Fluxo CONTRATO

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cOrc - Codigo do orÁamento (TFJ_CODIGO)

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieocLoc WSRECEIVE cFil, cOrc WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodOrc	:= ""
Local cJoinABS	:= ""
Local cJoinTFL	:= ""
Local cWhereTFJ := ""
Local lMultFil  := IsMultFil()

cFilTMP	:= self:cFil
cCodOrc	:= self:cOrc

//Tratamento de multifilial:
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL" , "TFJ", "TFL", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL" , "TFL", "ABS", cFilTMP, "JOIN")
cWhereTFJ := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFJ", "TFJ", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT 	TFL.TFL_LOCAL,
            TFL.TFL_CODIGO,
            AB.ABS_DESCRI
    FROM %table:TFJ% TFJ  
        INNER JOIN %table:TFL% TFL 
                ON (%exp:cJoinTFL% //TFL_FILIAL+TFL_CODPAI
                    AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO  
                    AND TFL.%NotDel%)
		INNER JOIN %table:ABS% AB 
                ON (%exp:cJoinABS% //ABS_FILIAL+ABS_LOCAL
                    AND AB.ABS_LOCAL = TFL.TFL_LOCAL  
                    AND AB.%NotDel%)
    WHERE %exp:cWhereTFJ% 
		AND TFJ.TFJ_STATUS = '1' //OrÁamentos ativos
        AND TFJ.TFJ_CODIGO = %exp:cCodOrc%
        AND TFJ.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieocLoc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['ieocLoc'], JsonObject():New())

		aTail(oResponse['ieocLoc'])['codtfl']     := AllTrim((cAliasTmp)->TFL_CODIGO)
		aTail(oResponse['ieocLoc'])['codlocal']   := AllTrim((cAliasTmp)->TFL_LOCAL)
		aTail(oResponse['ieocLoc'])['desclocal']  := EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de Postos para item extra operacional - Fluxo CONTRATO

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cTFL - Codigo do Local TFL (TFL_CODIGO)

@author     Jack Junior
@since      14/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieocPostos WSRECEIVE cFil, cTFL WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cTGY		:= ""
Local cPosto	:= ""
Local cQry		:= ""
Local cCodTFL	:= ""
Local cJoinTFF	:= ""
Local cJoinSB1	:= ""
Local cJoinSRJ	:= ""
Local cJoinSR6	:= ""
Local cJoinSQ3	:= ""
Local cJoinTDW	:= ""
Local cJoinAC0	:= ""
Local cWhereTFL := ""
Local lMultFil  := IsMultFil()

cFilTMP	:= self:cFil
cCodTFL	:= self:cTFL

//Tratamento de multifilial:
cJoinTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL" , "TFL", "TFF", cFilTMP, "JOIN")
cJoinSB1 := JoinSQL(lMultFil, "SB1.B1_FILIAL" , "TFF", "SB1", cFilTMP, "JOIN")
cJoinSRJ := JoinSQL(lMultFil, "SRJ.RJ_FILIAL" , "TFF", "SRJ", cFilTMP, "JOIN")
cJoinSR6 := JoinSQL(lMultFil, "SR6.R6_FILIAL" , "TFF", "SR6", cFilTMP, "JOIN")
cJoinSQ3 := JoinSQL(lMultFil, "SQ3.Q3_FILIAL" , "TFF", "SQ3", cFilTMP, "JOIN")
cJoinTDW := JoinSQL(lMultFil, "TDW.TDW_FILIAL" , "TFF", "TDW", cFilTMP, "JOIN")
cJoinAC0 := JoinSQL(lMultFil, "AC0.AC0_FILIAL" , "TFF", "AC0", cFilTMP, "JOIN")
cWhereTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFL", "TFL", cFilTMP, "WHERE")
cWhereTGY := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TGY", "TGY", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT 	TFF.TFF_COD, TFF.TFF_COBCTR, TFF.TFF_ITEM, TFF.TFF_GERVAG, TFF.TFF_PRODUT,
			SB1.B1_DESC, TFF.TFF_QTDVEN, TFF.TFF_PERINI, TFF.TFF_PERFIM, TFF.TFF_TESPED,
			TFF.TFF_HORAIN, TFF.TFF_HORAFI, TFF.TFF_FUNCAO, SRJ.RJ_DESC, TFF.TFF_TURNO,
			SR6.R6_DESC, TFF.TFF_SEQTRN, TFF.TFF_CARGO, SQ3.Q3_DESCSUM, TFF.TFF_ESCALA,
			TDW.TDW_DESC, TFF.TFF_CODLIM, TFF.TFF_CALEND, AC0.AC0_DESC, TFF.TFF_INSALU,
			TFF.TFF_GRAUIN, TFF.TFF_PERICU, TFF.TFF_QTDHRS, TFF.TFF_PRDRET, TFF.TFF_TPCOBR,
			TFF.TFF_FINDME
    FROM %table:TFL% TFL  
        INNER JOIN %table:TFF% TFF 
                ON (%exp:cJoinTFF% //TFF_FILIAL+TFF_CODPAI+TFF_ITEM
                    AND TFF.TFF_CODPAI = TFL.TFL_CODIGO  
                    AND TFF.%NotDel%)
		INNER JOIN %table:SB1% SB1 
                ON (%exp:cJoinSB1% //B1_FILIAL+B1_COD
                    AND SB1.B1_COD = TFF.TFF_PRODUT
                    AND SB1.%NotDel%)
		INNER JOIN %table:SRJ% SRJ //FUN«√O
                ON (%exp:cJoinSRJ% //RJ_FILIAL+RJ_FUNCAO
                    AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO
                    AND SRJ.%NotDel%)
		LEFT JOIN %table:TDW% TDW //ESCALA
                ON (%exp:cJoinTDW% //TDW_FILIAL+TDW_COD
                    AND TDW.TDW_COD = TFF.TFF_ESCALA
                    AND TDW.%NotDel%)
		LEFT JOIN %table:SR6% SR6 //TURNO
                ON (%exp:cJoinSR6% //R6_FILIAL+R6_TURNO
                    AND SR6.R6_TURNO = TFF.TFF_TURNO
                    AND SR6.%NotDel%)
		LEFT JOIN %table:SQ3% SQ3 //CARGO
                ON (%exp:cJoinSQ3% //Q3_FILIAL+Q3_CARGO+Q3_CC
                    AND SQ3.Q3_CARGO = TFF.TFF_CARGO
                    AND SQ3.%NotDel%)
		LEFT JOIN %table:AC0% AC0 //FERIADOS
                ON (%exp:cJoinAC0% //AC0_FILIAL+AC0_CODIGO
                    AND AC0.AC0_CODIGO = TFF.TFF_CALEND
                    AND AC0.%NotDel%)					
    WHERE %exp:cWhereTFL% 
        AND TFL.TFL_CODIGO = %exp:cCodTFL%
        AND TFL.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieocPostos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['ieocPostos'], JsonObject():New())

		aTail(oResponse['ieocPostos'])['codtff']		:= AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['ieocPostos'])['cobracontr']   := AllTrim((cAliasTmp)->TFF_COBCTR)
		aTail(oResponse['ieocPostos'])['item']			:= AllTrim((cAliasTmp)->TFF_ITEM)
		aTail(oResponse['ieocPostos'])['geravaga']     := AllTrim((cAliasTmp)->TFF_GERVAG)
		aTail(oResponse['ieocPostos'])['produto']		:= AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['ieocPostos'])['descprod']		:= EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))	
		aTail(oResponse['ieocPostos'])['quantidade']	:= (cAliasTmp)->TFF_QTDVEN
		aTail(oResponse['ieocPostos'])['periodoini']   := AllTrim((cAliasTmp)->TFF_PERINI)
		aTail(oResponse['ieocPostos'])['periodofim']	:= AllTrim((cAliasTmp)->TFF_PERFIM)
		aTail(oResponse['ieocPostos'])['tes']			:= AllTrim((cAliasTmp)->TFF_TESPED)
		aTail(oResponse['ieocPostos'])['horaini']		:= AllTrim((cAliasTmp)->TFF_HORAIN)
		aTail(oResponse['ieocPostos'])['horafim']		:= AllTrim((cAliasTmp)->TFF_HORAFI)
		aTail(oResponse['ieocPostos'])['funcao']		:= AllTrim((cAliasTmp)->TFF_FUNCAO)
		aTail(oResponse['ieocPostos'])['descfunc']		:= EncodeUTF8(AllTrim((cAliasTmp)->RJ_DESC))
		aTail(oResponse['ieocPostos'])['turno']		:= AllTrim((cAliasTmp)->TFF_TURNO)
		aTail(oResponse['ieocPostos'])['descturno']	:= EncodeUTF8(AllTrim((cAliasTmp)->R6_DESC))
		aTail(oResponse['ieocPostos'])['seqturno']     := AllTrim((cAliasTmp)->TFF_SEQTRN)
		aTail(oResponse['ieocPostos'])['cargo']		:= AllTrim((cAliasTmp)->TFF_CARGO)
		aTail(oResponse['ieocPostos'])['desccargo']	:= EncodeUTF8(AllTrim((cAliasTmp)->Q3_DESCSUM))
		aTail(oResponse['ieocPostos'])['escala']		:= AllTrim((cAliasTmp)->TFF_ESCALA)
		aTail(oResponse['ieocPostos'])['descescala']	:= EncodeUTF8(AllTrim((cAliasTmp)->TDW_DESC))
		aTail(oResponse['ieocPostos'])['limite']		:= AllTrim((cAliasTmp)->TFF_CODLIM)
		aTail(oResponse['ieocPostos'])['calendario']	:= AllTrim((cAliasTmp)->TFF_CALEND)
		aTail(oResponse['ieocPostos'])['desccalend']	:= EncodeUTF8(AllTrim((cAliasTmp)->AC0_DESC))
		aTail(oResponse['ieocPostos'])['insalub']		:= AllTrim((cAliasTmp)->TFF_INSALU)
		aTail(oResponse['ieocPostos'])['grauinsa']		:= AllTrim((cAliasTmp)->TFF_GRAUIN)
		aTail(oResponse['ieocPostos'])['periculos']	:= AllTrim((cAliasTmp)->TFF_PERICU)
		aTail(oResponse['ieocPostos'])['qtdhrs']		:= AllTrim((cAliasTmp)->TFF_QTDHRS)
		aTail(oResponse['ieocPostos'])['prodretro']	:= AllTrim((cAliasTmp)->TFF_PRDRET)
		aTail(oResponse['ieocPostos'])['tpcobr']		:= AllTrim((cAliasTmp)->TFF_TPCOBR)
		aTail(oResponse['ieocPostos'])['desctpcobr']	:= EncodeUTF8(AllTrim(FWGetSX5("GZ", (cAliasTmp)->TFF_TPCOBR)[1,4]))
		aTail(oResponse['ieocPostos'])['findme']		:= AllTrim((cAliasTmp)->TFF_FINDME)
		//Verifica se n„o È um Posto-Item Extra:
		If AllTrim((cAliasTmp)->TFF_COBCTR) == "1"
			aTail(oResponse['ieocPostos'])['altera']	:= .F.
		Else
			cQry := GetNextAlias()
			//Verifica se o Item extra j· tem Atendente alocado:
			cPosto := (cAliasTmp)->TFF_COD
			BeginSQL Alias cQry
				SELECT COALESCE(TGY.TGY_ESCALA,' ') ALOCADO
				FROM %Table:TGY% TGY
				WHERE %Exp:cWhereTGY%
					AND TGY.TGY_CODTFF = %Exp:cPosto%
					AND TGY.%NotDel%
			EndSql
			cTGY := (cQry)->(ALOCADO)
			(cQry)->(DbCloseArea())

			If !Empty(cTGY)
				aTail(oResponse['ieocPostos'])['altera']	:= .F.
			Else
				aTail(oResponse['ieocPostos'])['altera']	:= .T.
			EndIf
		EndIf
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de funÁıes para item extra operacional (apenas funÁıes do local)

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cTFL - CÛdigo do LOCAL(String) - (TFL_CODIGO)

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieocFuncao WSRECEIVE cFil, cTFL WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cCodTFL	:= ''
Local cFilTMP   := ''
Local cJoinSRJ	:= ''
Local cWhereTFF := ''

cFilTMP := self:cFil
cCodTFL := self:cTFL

cJoinSRJ  := JoinSQL(lMultFil, "SRJ.RJ_FILIAL",  "TFF", "SRJ", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFF.TFF_FUNCAO, SRJ.RJ_DESC
    FROM %table:TFF% TFF
        INNER JOIN %table:SRJ% SRJ //Funcion·rios
            ON %exp:cJoinSRJ%
	        	AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO
				AND SRJ.%NotDel%
        WHERE %exp:cWhereTFF%
            AND TFF.TFF_CODPAI = %exp:cCodTFL%
            AND TFF.%NotDel%  
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieocFuncao'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['ieocFuncao'], JsonObject():New())

		aTail(oResponse['ieocFuncao'])['codfuncao']	:= AllTrim((cAliasTmp)->TFF_FUNCAO)
		aTail(oResponse['ieocFuncao'])['descfuncao']	:= EncodeUTF8(AllTrim((cAliasTmp)->RJ_DESC))

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

MÈtodo GET de cargos para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieocCargo WSRECEIVE cFil WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cWhereSQ3 := ''

cFilTMP := self:cFil

cWhereSQ3 := JoinSQL(lMultFil, "SQ3.Q3_FILIAL", "SQ3", "SQ3", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT SQ3.Q3_CARGO, SQ3.Q3_DESCSUM
    FROM %table:SQ3% SQ3
        WHERE %exp:cWhereSQ3%
            AND SQ3.%NotDel%  
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieocCargo'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['ieocCargo'], JsonObject():New())

		aTail(oResponse['ieocCargo'])['codcargo']	:= AllTrim((cAliasTmp)->Q3_CARGO)
		aTail(oResponse['ieocCargo'])['desccargo']	:= EncodeUTF8(AllTrim((cAliasTmp)->Q3_DESCSUM))

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

MÈtodo GET de produtos/serviÁos para item extra operacional (apenas produtos do local)

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cTFL - CÛdigo do LOCAL(String) - (TFL_CODIGO)

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieocProduto WSRECEIVE cFil, cTFL WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cCodTFL	:= ''
Local cFilTMP   := ''
Local cJoinSB1	:= ''
Local cWhereTFF := ''

cFilTMP := self:cFil
cCodTFL := self:cTFL

cJoinSB1  := JoinSQL(lMultFil, "SB1.B1_FILIAL" , "TFF", "SB1", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFF_PRODUT, B1_DESC, B1_UM
    FROM %table:TFF% TFF
        INNER JOIN %table:SB1% SB1 //Funcion·rios
            ON %exp:cJoinSB1%
	        	AND SB1.B1_COD = TFF.TFF_PRODUT
				AND SB1.%NotDel%
        WHERE %exp:cWhereTFF%
            AND TFF.TFF_CODPAI = %exp:cCodTFL%
            AND TFF.%NotDel%  
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieocProduto'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['ieocProduto'], JsonObject():New())

		aTail(oResponse['ieocProduto'])['codproduto']	:= AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['ieocProduto'])['descproduto']	:= EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))
		aTail(oResponse['ieocProduto'])['codum']			:= AllTrim((cAliasTmp)->B1_UM)
		aTail(oResponse['ieocProduto'])['codTES']		:= TecTesPRod((cAliasTmp)->TFF_PRODUT, "_TS") //MV_ARQPROD

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

MÈtodo GET de escala para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cTurno - Turno - Apenas um (Combo Box no front)

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieocEscala WSRECEIVE cFil, cTurno WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cCodTurno	:= ''
Local cWhereTDW := ''

cFilTMP := self:cFil
cCodTurno := self:cTurno

//Monta o where de Turno com base na seleÁ„o do filtro anterior no Front-End
If Empty(cCodTurno)
	cWhereSR6 := "1 = 1"
Else
	cWhereSR6 := "TDX.TDX_TURNO = '" +cCodTurno+ "'"
EndIf

cWhereSR6 := sqlEmbeded(cWhereSR6)

cJoinTDX  := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDW", "TDX", cFilTMP, "JOIN")
cWhereTDW := JoinSQL(lMultFil, "TDW.TDW_FILIAL", "TDW", "TDW", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TDW.TDW_COD, TDW.TDW_DESC
    FROM %table:TDW% TDW
        INNER JOIN %table:TDX% TDX
            ON %exp:cJoinTDX%
            AND TDX.TDX_CODTDW = TDW.TDW_COD
            AND TDX.%NotDel%
	WHERE %exp:cWhereTDW%
			AND %exp:cWhereSR6% //Turno
			AND TDW.%NotDel%
	ORDER BY TDW_COD
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieocEscala'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['ieocEscala'], JsonObject():New())

		aTail(oResponse['ieocEscala'])['codescala']	:= AllTrim((cAliasTmp)->TDW_COD)
		aTail(oResponse['ieocEscala'])['descescala'] := EncodeUTF8(AllTrim((cAliasTmp)->TDW_DESC))

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

MÈtodo GET de sequencias de uma escala para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cEscala -Escala(String) - Apenas uma

@author     Jack Junior
@since      14/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieocSeq WSRECEIVE cFil, cEscala WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cEscPosto	:= ''
Local cWhereTDX := ''

cFilTMP		:= self:cFil
cEscPosto	:= self:cEscala

cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TDX.TDX_SEQTUR
    FROM %table:TDX% TDX
        WHERE %exp:cWhereTDX%
			AND TDX.TDX_CODTDW = %exp:cEscPosto%
            AND TDX.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieocSeq'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['ieocSeq'], JsonObject():New())

		aTail(oResponse['ieocSeq'])['sequencia']	:= AllTrim((cAliasTmp)->TDX_SEQTUR)

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

MÈtodo GET de turnos para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)

@author     Jack Junior
@since      04/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieocTurno WSRECEIVE cFil WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cWhereSR6 := ''

cFilTMP := self:cFil

cWhereSR6 := JoinSQL(lMultFil, "SR6.R6_FILIAL", "SR6", "SR6", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT SR6.R6_TURNO, SR6.R6_DESC
    FROM %table:SR6% SR6
        WHERE %exp:cWhereSR6%
            AND SR6.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieocTurno'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['ieocTurno'], JsonObject():New())

		aTail(oResponse['ieocTurno'])['codturno']	:= AllTrim((cAliasTmp)->R6_TURNO)
		aTail(oResponse['ieocTurno'])['descturno'] := EncodeUTF8(AllTrim((cAliasTmp)->R6_DESC))

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

MÈtodo GET de calend·rio de feriados para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieoCalend WSRECEIVE cFil WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cWhereAC0 := ''

cFilTMP := self:cFil

cWhereAC0 := JoinSQL(lMultFil, "AC0.AC0_FILIAL", "AC0", "AC0", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT AC0.AC0_CODIGO, AC0.AC0_DESC
    FROM %table:AC0% AC0
        WHERE %exp:cWhereAC0%
            AND AC0.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieoCalend'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['ieoCalend'], JsonObject():New())

		aTail(oResponse['ieoCalend'])['codcalend']	:= AllTrim((cAliasTmp)->AC0_CODIGO)
		aTail(oResponse['ieoCalend'])['desccalend']	:= EncodeUTF8(AllTrim((cAliasTmp)->AC0_DESC))

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

MÈtodo GET de TES para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieocTES WSRECEIVE cFil WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cWhereSF4 := ''

cFilTMP := self:cFil

cWhereSF4 := JoinSQL(lMultFil, "SF4.F4_FILIAL", "SF4", "SF4", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT SF4.F4_CODIGO, SF4.F4_TIPO, SF4.F4_CF, SF4.F4_DUPLIC, SF4.F4_ESTOQUE, SF4.F4_TEXTO
    FROM %table:SF4% SF4
        WHERE %exp:cWhereSF4%
			AND SF4.F4_TIPO = 'S'
            AND SF4.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieocTES'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['ieocTES'], JsonObject():New())

		aTail(oResponse['ieocTES'])['codTES']			:= AllTrim((cAliasTmp)->F4_CODIGO)
		aTail(oResponse['ieocTES'])['tipo']				:= EncodeUTF8("SAÕDA")
		aTail(oResponse['ieocTES'])['codFiscal']			:= AllTrim((cAliasTmp)->F4_CF)
		aTail(oResponse['ieocTES'])['geraDuplicata']		:= AllTrim((cAliasTmp)->F4_DUPLIC)
		aTail(oResponse['ieocTES'])['atualizaEstoque']	:= AllTrim((cAliasTmp)->F4_ESTOQUE)
		aTail(oResponse['ieocTES'])['descTES']			:= EncodeUTF8(AllTrim((cAliasTmp)->F4_TEXTO))

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

MÈtodo POST de inclus„o de items extras inseridos no front end.

Exemplo de BODY que precisa ser enviado do front:
{
    "filial":"D MG 01 ",
    "orcamento":"00000000266",
    "local":"000388",
    "agendas":[{"1":"", //CÛdigo da TFF (POSTO) - Vazio se NOVA inclus„o
                "2":"000000000000001", //ServiÁo/Posto OBRIGAT”RIO
                "3":2, //Quantidade vendida OBRIGAT”RIO
                "4":"20230101", //PerÌodo inicial OBRIGAT”RIO
                "5":"", //PerÌodo Final
                "6":"501", //TES OBRIGAT”RIO
                "7":"00002", //FunÁ„o OBRIGAT”RIO
                "8":"",  //Turno
				"9":"000001", //Escala OBRIGAT”RIO
                "10":"", //Cargo
                "11":"", //Calend·rio de feriados
                "12":"", //Insalubridade? OBRIGAT”RIO
                "13":"", //Grau de insalubridade OBRIGAT”RIO
                "14":"", //Periculosidade? OBRIGAT”RIO
                "15":"", //Qnt de horas disponiveis para alocaÁ„o
                "16":"", //Produto retroativo ?
                "17":"2"}]//Integra Find-me ?
}

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST addItemExtra WSREST MESAOPERACIONAL
Local oParamBody  := JsonObject():New()
Local oResponse   := JsonObject():New()
Local cBody       := Self:GetContent()
Local cErrorMsg	  := ""
Local cFilTMP     := ""
Local cOrcamento  := ""
Local cLocal	  := ""
Local lRet		  := .F.
Local aItens	  := {}
Local aMesaPOUI	  := {}

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']     //Filial
cOrcamento  := oParamBody['orcamento']  //CÛdigo do orÁamento (TFJ_CODIGO)
cLocal		:= oParamBody['local']		//CÛdigo do local
aItens		:= oParamBody['agendas']    //Array de Itens extra a serem adicionados

If ValType(aItens) != 'U' .And. Len(aItens) > 0
	aMesaPOUI := {.T.,cFilTMP,cOrcamento,cLocal,aItens}
	lRet := At870GerOrc( , , , , aMesaPOUI, @cErrorMsg)
Else
	lRet := .F.
	cErrorMsg := "Nenhum item Extra inserido."
EndIf

oResponse['addItemExtra'] := {}
Aadd(oResponse['addItemExtra'], JsonObject():New())

aTail(oResponse['addItemExtra'])['insert']	 := lRet
aTail(oResponse['addItemExtra'])['mensagem'] := EncodeUtf8(AllTrim(cErrorMsg))

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de Clientes para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)

@author     Jack Junior
@since      13/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieoCliente WSRECEIVE cFil WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cWhereSA1 := ''

cFilTMP := self:cFil

cWhereSA1 := JoinSQL(lMultFil, "SA1.A1_FILIAL", "SA1", "SA1", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME
    FROM %table:SA1% SA1
        WHERE %exp:cWhereSA1%
            AND SA1.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Cliente'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['Cliente'], JsonObject():New())
		aTail(oResponse['Cliente'])['codigo']   := AllTrim((cAliasTmp)->A1_COD)
		aTail(oResponse['Cliente'])['loja']     := AllTrim((cAliasTmp)->A1_LOJA)
		aTail(oResponse['Cliente'])['nome']     := AllTrim((cAliasTmp)->A1_NOME)
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

MÈtodo POST de orÁamentos para filtro de Item Extra Operacional - Fluxo Pessoa

@Param cBody - Exemplo:
{
    "filial":"D MG 01 ",
    "clientes":[{"value":"00000101"},{"value":"00000201"}],
	"data":"20240201"
}

filial(String) - Apenas uma (Combo Box no front)
clientes(Array) - CLIENTE+LOJA nenhum ou mais (Mult-select no front)
data(String) - Data (apenas uma)

@author     Jack Junior
@since      13/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieopOrc WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cData		:= ""
Local cFilTMP   := ""
Local cInCli	:= ""
Local cWhereCli	:= ""
Local cWhereTFJ	:= ""
Local aClientes := {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP   := oParamBody['filial']
aClientes := oParamBody['clientes']
cData	  := oParamBody['data']

//Monta o where de clientes com base na seleÁ„o do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA = '" + aClientes[1]["value"] + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli += "'" +aClientes[nX]["value"] + "'"
	Next nX
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

cData := sqlEmbeded("'"+cData+"'")

//Ajusta Chave FILIAL de acordo com par‚metro Multifilial
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cWhereTFJ := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFJ", "TFJ", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFJ.TFJ_CODIGO, TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV, TFJ.TFJ_PROPOS, TFJ.TFJ_PREVIS
    FROM %table:TFJ% TFJ
        INNER JOIN %table:TFL% TFL //Local - Contrato
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO 
            AND TFL.%NotDel%
        INNER JOIN %table:TFF% TFF //Posto - Contrato
            ON %exp:cJoinTFF%
	        AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
            AND TFF.%NotDel% 
    WHERE %exp:cWhereTFJ%
            AND TFJ.TFJ_STATUS = '1' //OrÁamentos ativos
			AND TFF.TFF_COBCTR = '2' //Item extra operacional - Sem cobranÁa no contrato
			AND %exp:cWhereCli%		 //Filtra clientes
			AND %exp:cData% >= TFF.TFF_PERINI
			AND TFF.TFF_PERFIM >= %exp:cData%
            AND TFJ.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Orcamentos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Orcamentos'], JsonObject():New())

		//OR«AMENTO
		aTail(oResponse['Orcamentos'])['codOrcamento']	:= AllTrim((cAliasTmp)->TFJ_CODIGO)
		aTail(oResponse['Orcamentos'])['codContrato']	:= AllTrim((cAliasTmp)->TFJ_CONTRT)
		aTail(oResponse['Orcamentos'])['codRevisCont']	:= AllTrim((cAliasTmp)->TFJ_CONREV)
		aTail(oResponse['Orcamentos'])['codProposta']	:= AllTrim((cAliasTmp)->TFJ_PROPOS)
		aTail(oResponse['Orcamentos'])['codRevisProp']	:= AllTrim((cAliasTmp)->TFJ_PREVIS)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de LOCAIS para filtro de Item Extra Operacional - Fluxo Pessoa

@Param cBody - Exemplo:
{
    "filial":"D MG 01 ",
    "clientes":[],
    "orcamentos":[{"value":"00000000266"}],
	"data":"20240201"
}

filial(String) - Apenas uma (Combo Box no front)
clientes(Array) - CLIENTE+LOJA (SA1_COD+SA1_LOJA) nenhum ou mais (Mult-select no front)
orcamentos(Array) - COD OR«AMENTO (TFJ_CODIGO) nenhum ou mais (Mult-select no front)
data(String) - Data (apenas uma)

@author     Jack Junior
@since      12/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieopLocal WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cData		:= ""
Local cInCli	:= ""
Local cInOrc	:= ""
Local cFilTMP   := ""
Local cJoinTFJ	:= ""
Local cJoinABS	:= ""
Local cJoinTFF	:= ""
Local cWhereCli	:= ""
Local cWhereOrc	:= ""
Local cWhereTFL := ""
Local aOrcamento:= {}
Local aClientes := {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aClientes	:= oParamBody['clientes']
aOrcamento  := oParamBody['orcamentos']
cData	    := oParamBody['data']

//Monta o where de clientes com base na seleÁ„o do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA = '" + aClientes[1]["value"]  + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli +=  "'" + aClientes[nX]["value"]  + "'"
	Next nX
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Monta o where de orÁamentos com base na seleÁ„o do filtro anterior no Front-End
If ValType(aOrcamento) = 'U' .Or. Len(aOrcamento) = 0
	cWhereOrc := "1 = 1"
ElseIf Len(aOrcamento) = 1
	cWhereOrc := "TFJ.TFJ_CODIGO = '" + aOrcamento[1]["value"] + "'"
Else
	For nX = 1 To Len(aOrcamento)
		If nX > 1
			cInOrc += ","
		EndIf
		cInOrc +=  "'" + aOrcamento[nX]["value"] + "'"
	Next nX
	cWhereOrc := "TFJ.TFJ_CODIGO IN ("+cInOrc+")"
EndIf

cWhereOrc := sqlEmbeded(cWhereOrc)

cData := sqlEmbeded("'"+cData+"'")

//Ajusta Chave FILIAL de acordo com par‚metro Multifilial
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cWhereTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFL", "TFL", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFL.TFL_CODIGO, TFL.TFL_LOCAL, AB.ABS_DESCRI
    FROM %table:TFL% TFL
        INNER JOIN %table:TFJ% TFJ //OrÁamento
            ON %exp:cJoinTFJ%
            AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
            AND TFJ.%NotDel%
		INNER JOIN %table:TFF% TFF //Posto - Contrato
            ON %exp:cJoinTFF%
	        AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
            AND TFF.%NotDel% 
        INNER JOIN %table:ABS% AB //Local cadastro
            ON %exp:cJoinABS%
	        AND AB.ABS_LOCAL = TFL.TFL_LOCAL
            AND AB.%NotDel% 
    WHERE %exp:cWhereTFL%
	        AND TFJ.TFJ_STATUS = '1' //OrÁamentos ativos
			AND TFF.TFF_COBCTR = '2' //Item extra operacional - Sem cobranÁa no contrato
			AND %exp:cWhereOrc%	  //Filtra orÁamentos
			AND %exp:cWhereCli%	  //Filtra clientes
			AND %exp:cData% >= TFF.TFF_PERINI
			AND TFF.TFF_PERFIM >= %exp:cData%
            AND TFL.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Locais'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Locais'], JsonObject():New())

		//OR«AMENTO
		aTail(oResponse['Locais'])['codTFL']	:= AllTrim((cAliasTmp)->TFL_CODIGO)
		aTail(oResponse['Locais'])['codLocal']	:= AllTrim((cAliasTmp)->TFL_LOCAL)
		aTail(oResponse['Locais'])['descLocal']	:= AllTrim((cAliasTmp)->ABS_DESCRI)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de POSTOS para filtro de Item Extra Operacional - Fluxo Contrato

@Param cBody - Exemplo:
{
    "filial":"D MG 01 ",
    "clientes":[{"value":"00000101"},{"value":"00000201"}],
    "orcamentos":[{"value":"00000000266"}],
    "locais":[{"value":"000388"}],
	"data":"20240201"
}

filial(String) - Apenas uma (Combo Box no front)
clientes(Array) - CLIENTE+LOJA (SA1_COD+SA1_LOJA) nenhum ou mais (Mult-select no front)
orcamentos(Array) - COD OR«AMENTO (TFJ_CODIGO) nenhum ou mais (Mult-select no front)
locais(Array) - COD LOCAL (TFL_CODIGO) nenhum ou mais (Mult-select no front)

@author     Jack Junior
@since      12/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieopPosto WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cData		:= ""
Local cInCli	:= ""
Local cInLoc	:= ""
Local cInOrc	:= ""
Local cFilTMP   := ""
Local cJoinTFL	:= ""
Local cJoinTFJ	:= ""
Local cJoinSB1	:= ""
Local cWhereTFF	:= ""
Local cWhereCli	:= ""
Local cWhereLoc	:= ""
Local cWhereOrc	:= ""
Local aClientes := {}
Local aLocais	:= {}
Local aOrcamento:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aClientes	:= oParamBody['clientes']
aOrcamento  := oParamBody['orcamentos']
aLocais		:= oParamBody['locais']
cData	    := oParamBody['data']

//Monta o where de clientes com base na seleÁ„o do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA = '" + aClientes[1]["value"] + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli += "'" + aClientes[nX]["value"] + "'"
	Next nX
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Monta o where de orÁamentos com base na seleÁ„o do filtro anterior no Front-End
If ValType(aOrcamento) = 'U' .Or. Len(aOrcamento) = 0
	cWhereOrc := "1 = 1"
ElseIf Len(aOrcamento) = 1
	cWhereOrc := "TFJ.TFJ_CODIGO = '" + aOrcamento[1]["value"] + "'"
Else
	For nX = 1 To Len(aOrcamento)
		If nX > 1
			cInOrc += ","
		EndIf
		cInOrc +=  "'" + aOrcamento[nX]["value"] + "'"
	Next nX
	cWhereOrc := "TFJ.TFJ_CODIGO IN ("+cInOrc+")"
EndIf

cWhereOrc := sqlEmbeded(cWhereOrc)

//Monta o where de locais com base na seleÁ„o do filtro anterior no Front-End
If ValType(aLocais) = 'U' .Or. Len(aLocais) = 0
	cWhereLoc := "1 = 1"
ElseIf Len(aLocais) = 1
	cWhereLoc := "TFL.TFL_CODIGO = '" + aLocais[1]["value"] + "'"
Else
	For nX = 1 To Len(aLocais)
		If nX > 1
			cInLoc += ","
		EndIf
		cInLoc += "'" + aLocais[nX]["value"] + "'"
	Next nX
	cWhereLoc := "TFL.TFL_CODIGO IN ("+cInLoc+")"
EndIf

cWhereLoc := sqlEmbeded(cWhereLoc)

cData := sqlEmbeded("'"+cData+"'")

//Ajusta Chave FILIAL de acordo com par‚metro Multifilial
cJoinTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFF", "TFL", cFilTMP, "JOIN")
cJoinTFJ := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFL", "TFJ", cFilTMP, "JOIN")
cJoinSB1 := JoinSQL(lMultFil, "SB1.B1_FILIAL", "TFF", "SB1", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFF.TFF_COD, TFF.TFF_PRODUT, SB1.B1_DESC
    FROM %table:TFF% TFF
	    INNER JOIN %table:TFL% TFL //Local
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
            AND TFL.%NotDel%
        INNER JOIN %table:TFJ% TFJ //OrÁamento
            ON %exp:cJoinTFJ%
            AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
            AND TFJ.%NotDel%
        INNER JOIN %table:SB1% SB1 //Cadastro Produtos
            ON %exp:cJoinSB1%
	        AND SB1.B1_COD = TFF.TFF_PRODUT
            AND SB1.%NotDel% 
    WHERE %exp:cWhereTFF%
	        AND TFJ.TFJ_STATUS = '1' //OrÁamentos ativos
			//AND TFF.TFF_COBCTR = '2' //Item extra operacional - Sem cobranÁa no contrato
			AND %exp:cWhereOrc%	  //Filtra orÁamentos
			AND %exp:cWhereCli%	  //Filtra clientes
			AND %exp:cWhereLoc%	  //Filtra locais
			AND %exp:cData% >= TFF.TFF_PERINI
			AND TFF.TFF_PERFIM >= %exp:cData%
            AND TFF.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Postos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Postos'], JsonObject():New())

		//OR«AMENTO
		aTail(oResponse['Postos'])['codTFF']	:= AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['Postos'])['codProd']	:= AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['Postos'])['descProd']	:= EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de Busca dos OrÁamentos/Contratos / Item Extra Operacional - Fluxo Pessoa
Apenas OrÁamentos com ITEM(s) EXTRA(s) adicionados !

@Param cBody - Exemplo:
{
    "filial":"D MG 01 ",
    "clientes":[{"value":"00000101"},{"value":"00000201"}],
    "orcamentos":[{"value":"00000000266"}],
    "locais":[{"value":"000388"}],
	"data":"20240201"
}

filial(String) - Apenas uma (Combo Box no front)
clientes(Array) - CLIENTE+LOJA (SA1_COD+SA1_LOJA) nenhum ou mais (Mult-select no front)
orcamentos(Array) - COD OR«AMENTO (TFJ_CODIGO) nenhum ou mais (Mult-select no front)
locais(Array) - COD LOCAL (TFL_CODIGO) nenhum ou mais (Mult-select no front)
data(String) - Data (apenas uma)

@author     Jack Junior
@since      12/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieopBuscar WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local oParamBody:= JsonObject():New()
Local cBody     := Self:GetContent()
Local cData		:= ""
Local cInCli	:= ""
Local cInLoc	:= ""
Local cInOrc	:= ""
Local cInPost	:= ""
Local cFilTMP   := ""
Local cJoinTFL	:= ""
Local cJoinTFF	:= ""
Local cJoinSA1	:= ""
Local cWhereTFJ	:= ""
Local cWhereCli	:= ""
Local cWhereLoc	:= ""
Local cWhereOrc	:= ""
Local cWherePost:= ""
Local aClientes := {}
Local aLocais	:= {}
Local aOrcamento:= {}
Local aPostos	:= {}
Local nX		:= 0
Local lMultFil  := IsMultFil()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Pega a filial e range de datas
cFilTMP		:= oParamBody['filial']
aClientes	:= oParamBody['clientes']
aOrcamento  := oParamBody['orcamentos']
aLocais		:= oParamBody['locais']
aPostos		:= oParamBody['postos']
cData	    := oParamBody['data']

//Monta o where de clientes com base na seleÁ„o do filtro anterior no Front-End
If ValType(aClientes) = 'U' .Or. Len(aClientes) = 0
	cWhereCli := "1 = 1"
ElseIf Len(aClientes) = 1
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA = '" + aClientes[1]["value"] + "'"
Else
	For nX = 1 To Len(aClientes)
		If nX > 1
			cInCli += ","
		EndIf
		cInCli += "'" + aClientes[nX]["value"] + "'"
	Next nX
	cWhereCli := "TFJ.TFJ_CODENT+TFJ.TFJ_LOJA IN ("+cInCli+")"
EndIf

cWhereCli := sqlEmbeded(cWhereCli)

//Monta o where de orÁamentos com base na seleÁ„o do filtro anterior no Front-End
If ValType(aOrcamento) = 'U' .Or. Len(aOrcamento) = 0
	cWhereOrc := "1 = 1"
ElseIf Len(aOrcamento) = 1
	cWhereOrc := "TFJ.TFJ_CODIGO = '" + aOrcamento[1]["value"] + "'"
Else
	For nX = 1 To Len(aOrcamento)
		If nX > 1
			cInOrc += ","
		EndIf
		cInOrc += "'" + aOrcamento[nX]["value"] + "'"
	Next nX
	cWhereOrc := "TFJ.TFJ_CODIGO IN ("+cInOrc+")"
EndIf

cWhereOrc := sqlEmbeded(cWhereOrc)

//Monta o where de locais com base na seleÁ„o do filtro anterior no Front-End
If ValType(aLocais) = 'U' .Or. Len(aLocais) = 0
	cWhereLoc := "1 = 1"
ElseIf Len(aLocais) = 1
	cWhereLoc := "TFL.TFL_CODIGO = '" + aLocais[1]["value"] + "'"
Else
	For nX = 1 To Len(aLocais)
		If nX > 1
			cInLoc += ","
		EndIf
		cInLoc += "'" + aLocais[nX]["value"] + "'"
	Next nX
	cWhereLoc := "TFL.TFL_CODIGO IN ("+cInLoc+")"
EndIf

cWhereLoc := sqlEmbeded(cWhereLoc)

//Monta o where de postos com base na seleÁ„o do filtro anterior no Front-End
If ValType(aPostos) = 'U' .Or. Len(aPostos) = 0
	cWherePost := "1 = 1"
ElseIf Len(aPostos) = 1
	cWherePost := "TFF.TFF_COD = '" + aPostos[1]["value"] + "'"
Else
	For nX = 1 To Len(aPostos)
		If nX > 1
			cInPost += ","
		EndIf
		cInPost += "'" + aPostos[nX]["value"] + "'"
	Next nX
	cWherePost := "TFF.TFF_COD IN ("+cInPost+")"
EndIf

cWherePost := sqlEmbeded(cWherePost)

cData := sqlEmbeded("'"+cData+"'")

//Ajusta Chave FILIAL de acordo com par‚metro Multifilial
cJoinTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cJoinSA1 := JoinSQL(lMultFil, "SA1.A1_FILIAL", "TFJ", "SA1", cFilTMP, "JOIN")
cWhereTFJ := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "TFJ", "TFJ", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TFJ.TFJ_CODIGO, TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV, TFJ.TFJ_PROPOS, TFJ.TFJ_PREVIS, SA1.A1_NOME, SA1.A1_LOJA
    FROM %table:TFJ% TFJ
	    INNER JOIN %table:TFL% TFL //Local
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO
            AND TFL.%NotDel%
		INNER JOIN %table:TFF% TFF //Posto - Contrato
            ON %exp:cJoinTFF%
	        AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
            AND TFF.%NotDel% 
		INNER JOIN %table:SA1% SA1 //Cliente - Cadastro
			ON %exp:cJoinSA1%
	        AND SA1.A1_COD = TFJ.TFJ_CODENT
			AND SA1.A1_LOJA = TFJ.TFJ_LOJA
            AND SA1.%NotDel% 
    WHERE %exp:cWhereTFJ%
	        AND TFJ.TFJ_STATUS = '1' //OrÁamentos ativos
			AND TFF.TFF_COBCTR = '2' //Item extra operacional - Sem cobranÁa no contrato
			AND %exp:cWhereOrc%	  //Filtra orÁamentos
			AND %exp:cWhereCli%	  //Filtra clientes
			AND %exp:cWhereLoc%	  //Filtra locais
			AND %exp:cWherePost%  //Filtra postos
			AND %exp:cData% >= TFF.TFF_PERINI
			AND TFF.TFF_PERFIM >= %exp:cData%
            AND TFJ.%NotDel%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['Orcamentos'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['Orcamentos'], JsonObject():New())

		//OR«AMENTO 
		aTail(oResponse['Orcamentos'])['codOrc']	:= AllTrim((cAliasTmp)->TFJ_CODIGO)
		aTail(oResponse['Orcamentos'])['codContr']	:= AllTrim((cAliasTmp)->TFJ_CONTRT)
		aTail(oResponse['Orcamentos'])['codConrev']	:= AllTrim((cAliasTmp)->TFJ_CONREV)
		aTail(oResponse['Orcamentos'])['codPropos']	:= AllTrim((cAliasTmp)->TFJ_PROPOS)
		aTail(oResponse['Orcamentos'])['codPrevis']	:= AllTrim((cAliasTmp)->TFJ_PREVIS)
		aTail(oResponse['Orcamentos'])['cliNome']	:= EncodeUTF8(AllTrim((cAliasTmp)->A1_NOME))
		aTail(oResponse['Orcamentos'])['cliLoja']	:= AllTrim((cAliasTmp)->A1_LOJA)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de Locais para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cOrc - Codigo do orÁamento (TFJ_CODIGO)

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieopLoc WSRECEIVE cFil, cOrc, cData WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodOrc	:= ""
Local cDia		:= ""
Local cStatus	:= ""
Local cJoinABS  := ""
Local cJoinTFF  := ""
Local cJoinTGY  := ""
Local cWhereTFL := ""
Local lMultFil  := IsMultFil()

cFilTMP	:= self:cFil
cCodOrc	:= self:cOrc
cDia := self:cData

//Tratamento de multifilial:
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL" , "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cWhereTFL := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFL", "TFL", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT 	TFL.TFL_LOCAL,
            TFL.TFL_CODIGO,
            SUM(TFF_QTPREV) QTD_PREV,  
            SUM(COALESCE(B.QTD_TGY,0)) QTD_TGY,
            AB.ABS_DESCRI
    //LOCAL - CONTRATO
    FROM %table:TFL% TFL  
        //RH/POSTO - CONTRATO
        INNER JOIN %table:TFF% TFF 
                ON (%exp:cJoinTFF%
                    AND TFF.TFF_CODPAI = TFL.TFL_CODIGO  
                    AND TFF.%NotDel%)
        //LOCAL - CADASTRO
        INNER JOIN %table:ABS% AB 
                ON (%exp:cJoinABS%
                    AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
                    AND AB.%NotDel%)
        LEFT JOIN
            (
                SELECT  TFL.TFL_LOCAL,
                        TFL.TFL_CODIGO,
                        COUNT(TGY_CODTFF) QTD_TGY,
                        TGY.TGY_CODTFF,
                        TGY.TGY_SEQ,
                        TGY.TGY_GRUPO,
                        AB.ABS_DESCRI
                //CONTRATOS
                FROM %table:TFL% TFL   

                    //RH/POSTO - CONTRATO 
                    INNER JOIN %table:TFF% TFF   
                        ON (%exp:cJoinTFF% 
                            AND TFF.TFF_CODPAI = TFL.TFL_CODIGO  
                            AND TFF.%NotDel%)
                    //LOCAL - CADASTRO
                    INNER JOIN %table:ABS% AB   
                        ON (%exp:cJoinABS%
                            AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
                            AND AB.%NotDel%)
                    //Rel. Escala x Func. Efetivo - TGY
                    LEFT JOIN %table:TGY% TGY   
                        ON (%exp:cJoinTGY%
                            AND TGY.TGY_CODTFF = TFF.TFF_COD
                            AND TGY.TGY_FILIAL = TFF.TFF_FILIAL	
                            AND TGY.%NotDel%)

                WHERE %exp:cWhereTFL%  
                    AND TFL.TFL_CODPAI = %exp:cCodOrc%
                    AND TFF.TFF_COBCTR = '2'
                    AND TGY.TGY_DTINI <= %exp:cDia% AND TGY.TGY_DTFIM >= %exp:cDia%
                    AND TFL.%NotDel% 
                GROUP BY
                    TFL.TFL_CODIGO,
                    TFL.TFL_LOCAL,
                    TGY.TGY_CODTFF,
                    TGY.TGY_SEQ,
                    TGY.TGY_GRUPO,
                    AB.ABS_DESCRI
            ) B
        ON B.TFL_LOCAL = TFL.TFL_LOCAL
    WHERE %exp:cWhereTFL% 
		AND TFL.TFL_CODPAI = %exp:cCodOrc%
		AND TFF.TFF_COBCTR = '2' 
        AND (TFF.TFF_DTENCE > %exp:cDia% OR TFF_DTENCE = ' ')
        AND TFF.TFF_GERVAG != '2'
        AND TFL.%NotDel% 

    GROUP BY
        TFL.TFL_CODIGO,
        TFL.TFL_LOCAL,
        AB.ABS_DESCRI
    ORDER BY
        TFL.TFL_CODIGO
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieopLoc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())

		If (cAliasTmp)->QTD_TGY < (cAliasTmp)->QTD_PREV
			//recebe flag de posto VAGO:
			cStatus := "VAGO"
		Else
			//recebe flag de posto COBERTO:
			cStatus := "COBERTO"
		EndIf

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['ieopLoc'], JsonObject():New())

		aTail(oResponse['ieopLoc'])['codtfl']     := AllTrim((cAliasTmp)->TFL_CODIGO)
		aTail(oResponse['ieopLoc'])['codlocal']   := AllTrim((cAliasTmp)->TFL_LOCAL)
		aTail(oResponse['ieopLoc'])['desclocal']  := EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		aTail(oResponse['ieopLoc'])['status']     := cStatus

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de Postos para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cTFL - Codigo do local (TFL_CODIGO)
		cData - Data

@author     Jack Junior
@since      05/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieopPost WSRECEIVE cFil, cTFL, cData WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodTFL   := ""
Local cDia		:= ""
Local cFuncao   := ""
Local cJoinSB1  := ""
Local cJoinTGY  := ""
Local cStatus	:= ""
Local cWhereTFF := ""
Local lMultFil  := IsMultFil()

cFilTMP     := self:cFil
cCodTFL     := self:cTFL
cDia		:= self:cData

//Tratamento de multifilial:
cJoinSB1  := JoinSQL(lMultFil, "SB1.B1_FILIAL" , "TFF", "SB1", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT 	TFF.TFF_COD,
            TFF.TFF_FUNCAO,
            TFF.TFF_PRODUT,
            TFF.TFF_QTPREV,  
            MAX(COALESCE(B.QTD_TGY,0)) QTD_TGY,
            SB1.B1_COD,
            SB1.B1_DESC,
            TFF.TFF_ESCALA,
            TFF.TFF_QTDVEN
    //POSTOS
    FROM %table:TFF% TFF  
        //CADASTRO DE PRODUTOS
        INNER JOIN %table:SB1% SB1 
	        ON (%exp:cJoinSB1%
            AND SB1.B1_COD = TFF.TFF_PRODUT
            AND SB1.%NotDel%)
        LEFT JOIN
            (
                SELECT TFF.TFF_COD,
                        TFF.TFF_FUNCAO,
                        TFF.TFF_PRODUT,
                        COUNT(TGY_CODTFF) QTD_TGY,
                        TGY.TGY_CODTFF,
                        TGY.TGY_SEQ,
                        TGY.TGY_GRUPO,
                        SB1.B1_DESC,
                        SB1.B1_COD
                //POSTOS
                FROM %table:TFF% TFF   
                    //PRODUTOS
                    INNER JOIN %table:SB1% SB1
                        ON (%exp:cJoinSB1%
                        AND SB1.B1_COD = TFF.TFF_PRODUT
                        AND SB1.%NotDel%)
                    //Rel. Escala x Func. Efetivo - TGY
                    INNER JOIN %table:TGY% TGY   
                        ON (%exp:cJoinTGY%
                            AND TGY.TGY_CODTFF = TFF.TFF_COD
                            AND TGY.%NotDel%)

                WHERE %exp:cWhereTFF%  
                    AND TFF.TFF_CODPAI = %exp:cCodTFL%
					AND TFF.TFF_COBCTR = '2' 
                    AND TGY.TGY_DTINI <= %exp:cDia% AND TGY.TGY_DTFIM >= %exp:cDia%
                    AND TFF.%NotDel% 
                GROUP BY
                    TFF.TFF_COD,
                    TFF.TFF_FUNCAO,
                    TFF.TFF_PRODUT,
                    TGY.TGY_CODTFF,
                    TGY.TGY_SEQ,
                    TGY.TGY_GRUPO,
                    SB1.B1_DESC,
                    SB1.B1_COD
            ) B
        ON B.TFF_COD = TFF.TFF_COD
    WHERE %exp:cWhereTFF% 
		AND TFF.TFF_COBCTR = '2' 
        AND TFF.TFF_CODPAI = %exp:cCodTFL%
        AND (TFF.TFF_DTENCE > %exp:cDia% OR TFF_DTENCE = ' ')
        AND TFF.TFF_GERVAG != '2'
        AND TFF.%NotDel% 
    GROUP BY
        TFF.TFF_QTPREV,
        TFF.TFF_FUNCAO,
        TFF.TFF_COD,
        TFF.TFF_PRODUT,
        SB1.B1_DESC,
        TFF.TFF_ESCALA,
        TFF.TFF_QTDVEN,
        SB1.B1_COD
    ORDER BY
        TFF.TFF_COD
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieopPost'] := {}

If (cAliasTmp)->(! Eof())

	cFuncao := Posicione("SRJ",1,xFilial('SRJ',cFilTMP)+((cAliasTmp)->TFF_FUNCAO),"RJ_DESC")


	While (cAliasTmp)->(! Eof())

		If (cAliasTmp)->QTD_TGY < (cAliasTmp)->TFF_QTPREV
			//recebe flag de posto VAGO:
			cStatus := "VAGO"
		Else
			//recebe flag de posto COBERTO:
			cStatus := "COBERTO"
		EndIf

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['ieopPost'], JsonObject():New())

		aTail(oResponse['ieopPost'])['codposto']   := AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['ieopPost'])['descposto']  := EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))
		aTail(oResponse['ieopPost'])['descfuncao'] := EncodeUTF8(AllTrim(cFuncao))
		aTail(oResponse['ieopPost'])['status']     := cStatus
		aTail(oResponse['ieopPost'])['escala']     := AllTrim((cAliasTmp)->TFF_ESCALA)
		aTail(oResponse['ieopPost'])['qtdvenda']   := (cAliasTmp)->TFF_QTDVEN
		aTail(oResponse['ieopPost'])['qtdprevista']:= (cAliasTmp)->TFF_QTPREV
		aTail(oResponse['ieopPost'])['codtff']     := (cAliasTmp)->TFF_COD

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de Vagas para item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cPosto - Codigo do posto (TFF_COD)
		cData - Data

@author     Jack Junior
@since      13/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieopVagas WSRECEIVE cFil, cPosto, cData WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodTFF   := ""
Local cDia		:= ""
Local cJoinAA1  := ""
Local cJoinTGY  := ""
Local cWhereTFF := ""
Local cTFFEscala:= ""
Local nAlocPrev := 0
Local nQtdVend  := 0
Local nX        := 0
Local nVagas    := 0
Local aAtendent := {}
Local lMultFil  := IsMultFil()

cFilTMP     := self:cFil
cCodTFF     := self:cPosto
cDia		:= self:cData

//Tratamento de multifilial:
cJoinAA1  := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "TGY", "AA1", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
        SELECT AA1.AA1_NOMTEC,
                TFF.TFF_QTPREV,
                TFF.TFF_QTDVEN,
                TFF.TFF_ESCALA,
                TGY.TGY_ATEND,
                TGY.TGY_DTINI,
                TGY.TGY_DTFIM,
                TFF.TFF_COD,
                TGY.TGY_ESCALA,
                TGY.TGY_SEQ
        //POSTOS
        FROM %table:TFF% TFF  
                    //Rel. Escala x Func. Efetivo - TGY
                    INNER JOIN %table:TGY% TGY   
                        ON (%exp:cJoinTGY%
                            AND TGY.TGY_CODTFF = TFF.TFF_COD
                            AND TGY.%NotDel%)
                    //ATENDENTES
                    INNER JOIN %table:AA1% AA1   
                        ON (%exp:cJoinAA1%
                            AND AA1.AA1_CODTEC = TGY.TGY_ATEND 
                            AND AA1.%NotDel%)
        WHERE %exp:cWhereTFF% 
            AND TFF.TFF_COD = %exp:cCodTFF%
            AND TGY.TGY_DTINI <= %exp:cDia% AND TGY.TGY_DTFIM >= %exp:cDia%
            AND (TFF.TFF_DTENCE > %exp:cDia% OR TFF_DTENCE = ' ')
			And TFF.TFF_COBCTR = '2'
            AND TFF.TFF_GERVAG != '2'
            AND TFF.%NotDel% 

EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieopVagas'] := {}

If (cAliasTmp)->(! Eof())

	cTFFEscala:= (cAliasTmp)->TFF_ESCALA
	nQtdVend  := (cAliasTmp)->TFF_QTDVEN

	While (cAliasTmp)->(! Eof())

		AADD(aAtendent, {AllTrim((cAliasTmp)->TGY_ATEND),;
			EncodeUTF8(AllTrim((cAliasTmp)->AA1_NOMTEC)),;
			AllTrim((cAliasTmp)->TGY_DTINI),;
			AllTrim((cAliasTmp)->TGY_DTFIM),;
			AllTrim((cAliasTmp)->TGY_ESCALA),;
			AllTrim((cAliasTmp)->TGY_SEQ)})

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

nAlocPrev := Posicione("TFF",1,cFilTMP+cCodTFF,"TFF_QTPREV")

nVagas := nAlocPrev - Len(aAtendent)

If nVagas > 0
	For nX := 1 to nVagas
		AADD(aAtendent, {"VAGO","","","","",""})
	Next nX
EndIf

For nX := 1 To Len(aAtendent)
	//Monta o Objeto JSon a ser retornado:
	Aadd(oResponse['ieopVagas'], JsonObject():New())

	aTail(oResponse['ieopVagas'])['label']       := aAtendent[nX,1] + ' - ' + aAtendent[nX,2]
	aTail(oResponse['ieopVagas'])['value']       := aAtendent[nX,1]
	aTail(oResponse['ieopVagas'])['codigo']      := aAtendent[nX,1]
	aTail(oResponse['ieopVagas'])['nome']        := aAtendent[nX,2]
	aTail(oResponse['ieopVagas'])['dtini']       := aAtendent[nX,3]
	aTail(oResponse['ieopVagas'])['dtfim']       := aAtendent[nX,4]
	aTail(oResponse['ieopVagas'])['escala']      := aAtendent[nX,5]
	aTail(oResponse['ieopVagas'])['sequencia']   := aAtendent[nX,6]
Next nX

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de Atendentes para AlocaÁ„o no item extra operacional

@Param cFil - filial(String) - Apenas uma (Combo Box no front)

@author     Jack Junior
@since      13/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieopAtend WSRECEIVE cFil WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cJoinSRA  := ""
Local cWhereAA1	:= ""
Local lMultFil  := IsMultFil()

cFilTMP     := self:cFil

//Tratamento de multifilial:
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL", "AA1", "SRA", cFilTMP, "JOIN")
cWhereAA1 := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "AA1", "AA1", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
        SELECT AA1.AA1_CODTEC, AA1.AA1_NOMTEC, AA1.AA1_CDFUNC, AA1.AA1_FUNFIL
        //Atendentes
        FROM %table:AA1% AA1
				LEFT JOIN %table:SRA% SRA   
					ON (%exp:cJoinSRA%
						AND SRA.RA_MAT = AA1.AA1_CDFUNC
						AND SRA.RA_MSBLQL <> '1'
						AND SRA.%NotDel%)
        WHERE %exp:cWhereAA1% 
            AND AA1.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['ieopAtend'] := {}

While (cAliasTmp)->(! Eof())

	//Monta o Objeto JSon a ser retornado:
	Aadd(oResponse['ieopAtend'], JsonObject():New())

	aTail(oResponse['ieopAtend'])['codigo']      := AllTrim((cAliasTmp)->AA1_CODTEC)
	aTail(oResponse['ieopAtend'])['nome']        := EncodeUTF8(AllTrim((cAliasTmp)->AA1_NOMTEC))
	aTail(oResponse['ieopAtend'])['matricula']	 := AllTrim((cAliasTmp)->AA1_CDFUNC)
	aTail(oResponse['ieopAtend'])['filial']		 := AllTrim((cAliasTmp)->AA1_FUNFIL)

	(cAliasTmp)->(DbSkip())
Enddo

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de Escalas para Item Extra - Fluxo Pessoa

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cPosto - posto(String) - Posto selecionado

@Return Retorna a escala do Posto ou a escala baseada no Turno do Posto

@author     Jack Junior
@since      29/05/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieopEscala WSRECEIVE cFil, cPosto WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cCodTurno	:= ''
Local cCodPosto := ''
Local cCodEscala:= ''
Local cJoinTDX	:= ''
Local cWhereTDW := ''
Local cWhereSR6	:= ''

cFilTMP	  := self:cFil
cCodPosto := self:cPosto

If !Empty(cFilTMP) .And. !Empty(cCodPosto)
	If !Empty(cCodPosto)
		cCodTurno  := Posicione("TFF",1,cFilTMP+cCodPosto,"TFF_TURNO")
		cCodEscala := Posicione("TFF",1,cFilTMP+cCodPosto,"TFF_ESCALA")
	EndIf

	//Caso posto n„o tenha Escala, retorna escalas com base no Turno:
	If Empty(cCodEscala)
		If Empty(cCodTurno)
			cWhereSR6 := "1 = 1"
		Else
			cWhereSR6 := "TDX.TDX_TURNO = '" +cCodTurno+ "'"
		EndIf

		cWhereSR6 := sqlEmbeded(cWhereSR6)

		cJoinTDX  := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDW", "TDX", cFilTMP, "JOIN")
		cWhereTDW := JoinSQL(lMultFil, "TDW.TDW_FILIAL", "TDW", "TDW", cFilTMP, "WHERE")

		Self:SetContentType("application/json")

		BeginSql Alias cAliasTmp
			SELECT DISTINCT TDW.TDW_COD, TDW.TDW_DESC
			FROM %table:TDW% TDW
				INNER JOIN %table:TDX% TDX
					ON %exp:cJoinTDX%
					AND TDX.TDX_CODTDW = TDW.TDW_COD
					AND TDX.%NotDel%
			WHERE %exp:cWhereTDW%
					AND %exp:cWhereSR6% //Turno
					AND TDW.%NotDel%
			ORDER BY TDW_COD
		EndSql
	Else
		//Retorna a escala do posto na requisiÁ„o
		cWhereSR6 := "TDW.TDW_COD = '" +cCodEscala+ "'"

		cWhereSR6 := sqlEmbeded(cWhereSR6)

		cWhereTDW := JoinSQL(lMultFil, "TDW.TDW_FILIAL", "TDW", "TDW", cFilTMP, "WHERE")

		Self:SetContentType("application/json")

		BeginSql Alias cAliasTmp
			SELECT DISTINCT TDW.TDW_COD, TDW.TDW_DESC
			FROM %table:TDW% TDW
			WHERE %exp:cWhereTDW%
					AND %exp:cWhereSR6%
					AND TDW.%NotDel%
			ORDER BY TDW_COD
		EndSql
	EndIf

	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())

	oResponse['ieopEscala'] := {}

	If (cAliasTmp)->(! Eof())

		While (cAliasTmp)->(! Eof())
			Aadd(oResponse['ieopEscala'], JsonObject():New())

			aTail(oResponse['ieopEscala'])['codescala']	 := AllTrim((cAliasTmp)->TDW_COD)
			aTail(oResponse['ieopEscala'])['descescala'] := EncodeUTF8(AllTrim((cAliasTmp)->TDW_DESC))

			(cAliasTmp)->(DbSkip())
		Enddo
	EndIf
	
	(cAliasTmp)->(DbCloseArea())
Else
	oResponse['ieopEscala'] := {}
	Aadd(oResponse['ieopEscala'], JsonObject():New())

	aTail(oResponse['ieopEscala'])['codescala']	 := '999999'
	aTail(oResponse['ieopEscala'])['descescala'] := EncodeUTF8('Filial e posto obrigatÛrio.')
EndIf

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de Sequencias para Item Extra - Fluxo Pessoa

@Param cFil - filial(String) - Apenas uma
		cEscala - escala(String) - Escala selecionado

@Return Retorna as sequencias com base na Escala

@author     Jack Junior
@since      29/05/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieopSeq WSRECEIVE cFil, cEscala WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cEscPosto	:= ''
Local cWhereTDX := ''

cFilTMP		:= self:cFil
cEscPosto	:= self:cEscala

If !Empty(cFilTMP) .And. !Empty(cEscPosto)
	cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

	Self:SetContentType("application/json")

	BeginSql Alias cAliasTmp
		SELECT DISTINCT TDX.TDX_SEQTUR
		FROM %table:TDX% TDX
			WHERE %exp:cWhereTDX%
				AND TDX.TDX_CODTDW = %exp:cEscPosto%
				AND TDX.%NotDel%
	EndSql

	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())

	oResponse['ieopSeq'] := {}

	If (cAliasTmp)->(! Eof())

		While (cAliasTmp)->(! Eof())
			Aadd(oResponse['ieopSeq'], JsonObject():New())

			aTail(oResponse['ieopSeq'])['sequencia'] := AllTrim((cAliasTmp)->TDX_SEQTUR)

			(cAliasTmp)->(DbSkip())
		Enddo
	EndIf
	
	(cAliasTmp)->(DbCloseArea())
Else
	oResponse['ieopSeq'] := {}
	Aadd(oResponse['ieopSeq'], JsonObject():New())

	aTail(oResponse['ieopSeq'])['sequencia'] := '00'
EndIf

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET Tipo de alocaÁ„o na alocaÁ„o de Item Extra

@Param cFil - Filial selecionanda no front end

@author     Jack Junior
@since      15/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ieopTipAloc WSRECEIVE cFil WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local cFilTMP   := ""

cFilTMP := self:cFil

DbSelectArea('TCU')
TCU->(DbSetOrder(1)) //TCU_FILIAL+TCU_COD

If !TCU->(DbSeek(xFilial("TCU", cFilTMP))) // caso n„o encontre informaÁıes
	At690Unit()  // crias os tipos padr„o para a filial
	TCU->(DbSeek(xFilial("TCU", cFilTMP)))  // apÛs criar... reposiciona no primeiro registro da filial
EndIf

oResponse['ieopTipAloc'] := {}

While TCU->(!EOF()) .And. TCU->TCU_FILIAL==xFilial('TCU', cFilTMP)

	// Valida se o tipo deve ser mostrado na alocacao/manuntencao da agenda
	If (TCU->TCU_EXALOC <> "1")
		TCU->(DbSkip())
		Loop
	Else
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['ieopTipAloc'], JsonObject():New())

		aTail(oResponse['ieopTipAloc'])['tipo']		:= AllTrim(TCU->TCU_COD)
		aTail(oResponse['ieopTipAloc'])['desc']		:= EncodeUtf8(AllTrim(TCU->TCU_DESC))
		TCU->(DbSkip())
	EndIf
End

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de ProjeÁ„o da agenda para Item Extra Operacional - Fluxo Pessoa
Apenas OrÁamentos com ITEM(s) EXTRA(s) adicionados !

@Param cBody - Exemplo:
{
    "filial": "D MG 01 ",
    "escala": "000002",
    "posto": "000309",
    "atend": "D MG 01 000054",
    "grupo": 1,
    "dataIni": "20240101",
    "dataFim": "20240115",
    "seq": "01",
    "tipMov": "001"
}

filial(String) - Apenas uma
escala(String) - Apenas uma
posto(String) - Apenas um
atend(String) - Apenas um
grupo(NumÈrico) - Apenas um
dataIni(String) - Apenas uma
dataFim(String) - Apenas uma
seq(String) - Apenas uma
tipMov(String) - Apenas um

@author     Jack Junior
@since      12/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieoProj WSREST MESAOPERACIONAL

Local aProjecao := {}
Local cAtend    := ""
Local cBody     := Self:GetContent()
Local cConFal   := ""
Local cCodContr := ""
Local cCodTFL	:= ""
Local cDataFim  := ""
Local cDataIni  := ""
Local cEscala   := ""
Local cFilTMP   := ""
Local cMsg      := ""
Local cPosto    := ""
Local cQry      := GetNextAlias()
Local cSeq      := ""
Local cTipMov   := ""
Local cTipoAl   := ""
Local cWhereTDX := ""
Local lMultFil  := IsMultFil()
Local lPermConfl:= AT680Perm(NIL, __cUserID, "017")
Local lRet      := .T.
Local lSucesso  := .T.
Local nGrupo    := 0
Local nX		:= 0
Local oAlocLGY  := NIL
Local oMdlLGY   := NIL
Local oModel    := NIL
Local oParamBody:= JsonObject():New()
Local oResponse := JsonObject():New()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIf

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
cEscala     := oParamBody['escala']
cCodTFL		:= oParamBody['local']
cCodContr	:= oParamBody['contrato']
cPosto      := oParamBody['posto']
cAtend      := oParamBody['atend']
nGrupo      := oParamBody['grupo']
cDataIni    := oParamBody['dataIni']
cDataFim    := oParamBody['dataFim']
cSeq        := oParamBody['seq']
cTipMov     := oParamBody['tipMov']
cTipoAl     := '1'

oModel:= FWLoadModel("TECA190D")
oModel:SetOperation(3)
oModel:Activate()

oMdlLGY := oModel:GetModel("LGYDETAIL")

// Busca Conf Aloc
cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

BeginSQL Alias cQry
	SELECT COALESCE(TDX.TDX_COD,' ') CONFAL
	FROM %Table:TDX% TDX
	WHERE %Exp:cWhereTDX%
		AND TDX.TDX_CODTDW = %Exp:cEscala%
		AND TDX.TDX_SEQTUR = %Exp:cSeq%
		AND TDX.%NotDel%
EndSql

cConFal := (cQry)->(CONFAL)
(cQry)->(DbCloseArea())

//Carga no Modelo dos dados para alocaÁ„o
lRet := lRet .And. oMdlLGY:SetValue("LGY_TIPOAL",cTipoAl)
lRet := lRet .And. oMdlLGY:SetValue("LGY_CODTEC",cAtend)
lRet := lRet .And. oMdlLGY:SetValue("LGY_DTINI" ,stod(cDataIni))
lRet := lRet .And. oMdlLGY:SetValue("LGY_DTFIM" ,stod(cDataFim))
lRet := lRet .And. oMdlLGY:SetValue("LGY_FILIAL",cFilTMP)
lRet := lRet .And. oMdlLGY:SetValue("LGY_CONTRT",cCodContr)
lRet := lRet .And. oMdlLGY:SetValue("LGY_CODTFL",cCodTFL)
lRet := lRet .And. oMdlLGY:SetValue("LGY_CODTFF",cPosto)
If Empty(oMdlLGY:GetValue("LGY_ESCALA"))
	lRet := lRet .And. oMdlLGY:SetValue("LGY_ESCALA",cEscala)
EndIf
lRet := lRet .And. oMdlLGY:SetValue("LGY_SEQ"   ,cSeq)
lRet := lRet .And. oMdlLGY:SetValue("LGY_TIPTCU",cTipMov)
lRet := lRet .And. oMdlLGY:SetValue("LGY_GRUPO" ,nGrupo)
If Empty(oMdlLGY:GetValue("LGY_CONFAL"))
	lRet := lRet .And. oMdlLGY:SetValue("LGY_CONFAL",cConFal)
EndIf

If lRet
	If !EMPTY(oMdlLGY:GetValue("LGY_ESCALA"))
		//INSTANCIA O OBJETO GSALOC
		oAlocLGY := GsAloc():New()

		//DEFINE AS PROPRIEDADES DO OBJETO
		oAlocLGY:defEscala(oMdlLGY:GetValue("LGY_ESCALA"))
		oAlocLGY:defPosto(oMdlLGY:GetValue("LGY_CODTFF"))
		oAlocLGY:defTec(oMdlLGY:GetValue("LGY_CODTEC"))
		oAlocLGY:defGrupo(oMdlLGY:GetValue("LGY_GRUPO"))
		oAlocLGY:defConfal(oMdlLGY:GetValue("LGY_CONFAL"))
		oAlocLGY:defDate(oMdlLGY:GetValue("LGY_DTINI"),oMdlLGY:GetValue("LGY_DTFIM"))
		oAlocLGY:defSeq(oMdlLGY:GetValue("LGY_SEQ"))
		oAlocLGY:defTpAlo(oMdlLGY:GetValue("LGY_TIPTCU"))
		oAlocLGY:defCob((oMdlLGY:GetValue("LGY_TIPOAL") == '2'))
		If TecMultFil()
			oAlocLGY:defFil(oMdlLGY:GetValue("LGY_FILIAL"))
		EndIf
		If TGY->( ColumnPos("TGY_PROXFE")) > 0
			oAlocLGY:defProxFe(oMdlLGY:GetValue("LGY_PROXFE"))
		EndIf
		If TecXHasEdH() //Indica se o Editor de Hor·rios est· habilitado (MV_GSGEHOR)
			oAlocLGY:defGeHor({{oMdlLGY:GetValue("LGY_ENTRA1"),oMdlLGY:GetValue("LGY_SAIDA1")},;
								{oMdlLGY:GetValue("LGY_ENTRA2"),oMdlLGY:GetValue("LGY_SAIDA2")},;
								{oMdlLGY:GetValue("LGY_ENTRA3"),oMdlLGY:GetValue("LGY_SAIDA3")},;
								{oMdlLGY:GetValue("LGY_ENTRA4"),oMdlLGY:GetValue("LGY_SAIDA4")}})
		EndIf

		//PROJETA A AGENDA:
		aProjecao := oAlocLGY:projAloc()

		//VERIFICA SE OUVE CONFLITOS:
		If oAlocLGY:getConfl()
			lSucesso := .F.
			cMsg := "Existem conflitos na alocaÁ„o."
		ElseIf oAlocLGY:temBloqueio() .OR. oAlocLGY:temAviso()
			lSucesso := .F.
			cMsg := "Existem bloqueios ou avisos na alocaÁ„o."
		ElseIf !(oAlocLGY:PermAlocarInter())
			lSucesso := .F.
			cMsg := "N„o È possÌvel alocar atendente intermitente fora do perÌodo."
		Else
			cMsg := "Agenda sem conflitos!"
		EndIf
	EndIf
Else
	lSucesso := .F.
	cMsg := "Falha ao atribuir valor no Modelo de Dados."
EndIf

//Ajustes de cores de legendas para o Front-end:
For nX := 1 To Len(aProjecao)
	//Aumenta o array acrescentando dois elementos NIL no final do array
	aadd(aProjecao[nX],NIL)
	aadd(aProjecao[nX],NIL)
	//Insiro um elemento NIL na segunda posiÁ„o, descartando o ˙ltimo
	aIns(aProjecao[nX],2) 
	If aProjecao[nX][1] == "BR_VERMELHO"
		aProjecao[nX][1] := "color-07"
		aProjecao[nX][2] := EncodeUTF8("Agenda Gerada")
	ElseIf aProjecao[nX][1] == "BR_AMARELO"
		aProjecao[nX][1] := "color-05"
		aProjecao[nX][2] := EncodeUTF8("Agenda Atendida")
	ElseIf aProjecao[nX][1] == "BR_VERDE"
		aProjecao[nX][1] := "color-09"
		aProjecao[nX][2] := EncodeUTF8("Agenda N„o Gerada")
	ElseIf aProjecao[nX][1] == "BR_LARANJA"
		aProjecao[nX][1] := "color-08"
		aProjecao[nX][2] := EncodeUTF8("Agenda com ManutenÁ„o")
	ElseIf aProjecao[nX][1] == "BR_PRETO"
		aProjecao[nX][1] := "color-04"
		aProjecao[nX][2] := EncodeUTF8("Conflito de AlocaÁ„o")
	ElseIf aProjecao[nX][1] == "BR_PINK"
		aProjecao[nX][1] := "color-06"
		aProjecao[nX][2] := EncodeUTF8("Atendente com agenda em reverva tÈcnica")
	ElseIf aProjecao[nX][1] == "BR_AZUL"
		aProjecao[nX][1] := "color-01"
		aProjecao[nX][2] := EncodeUTF8("Sem convocaÁ„o")
	EndIf

	//Insiro um elemento NIL na quarta posiÁ„o, descartando o ˙ltimo
	aIns(aProjecao[nX],4) 
	If aProjecao[nX][3] == "BR_VERDE"
		aProjecao[nX][3] := "color-09"
		aProjecao[nX][4] := EncodeUTF8("Trabalhado")
	ElseIf aProjecao[nX][3] == "BR_AMARELO"
		aProjecao[nX][3] := "color-05"
		aProjecao[nX][4] := EncodeUTF8("Compensado")
	ElseIf aProjecao[nX][3] == "BR_AZUL"
		aProjecao[nX][3] := "color-01"
		aProjecao[nX][4] := EncodeUTF8("D.S.R.")
	ElseIf aProjecao[nX][3] == "BR_LARANJA"
		aProjecao[nX][3] := "color-08"
		aProjecao[nX][4] := EncodeUTF8("Hora Extra")
	ElseIf aProjecao[nX][3] == "BR_PRETO"
		aProjecao[nX][3] := "color-04"
		aProjecao[nX][4] := EncodeUTF8("Intervalo")
	ElseIf aProjecao[nX][3] == "BR_VERMELHO"
		aProjecao[nX][3] := "color-07"
		aProjecao[nX][4] := EncodeUTF8("N„o trabalhado")
	EndIf
Next nX

oResponse['Projecao'] := {}

//Monta o Objeto JSon a ser retornado:
Aadd(oResponse['Projecao'], JsonObject():New())

//Retorno 
aTail(oResponse['Projecao'])['sucesso']		:= lSucesso
aTail(oResponse['Projecao'])['mensagem']	:= EncodeUTF8(cMsg)
aTail(oResponse['Projecao'])['projecao']	:= aProjecao
aTail(oResponse['Projecao'])['permConfl']	:= lPermConfl

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de ProjeÁ„o da agenda para Item Extra Operacional - Fluxo Pessoa
Apenas OrÁamentos com ITEM(s) EXTRA(s) adicionados !

@Param cBody - Exemplo:
{
    "filial": "D MG 01 ",
    "escala": "000002",
    "posto": "000309",
    "atend": "D MG 01 000054",
    "grupo": 1,
    "dataIni": "20240101",
    "dataFim": "20240115",
    "seq": "01",
    "tipMov": "001",
	"lPermConfl": .T.,
	"lAlocConf": .T.,
	"lContinua": .T.
}

filial(String) - Apenas uma
escala(String) - Apenas uma
posto(String) - Apenas um
atend(String) - Apenas um
grupo(NumÈrico) - Apenas um
dataIni(String) - Apenas uma
dataFim(String) - Apenas uma
seq(String) - Apenas uma
tipMov(String) - Apenas um
lPermConfl(Booleano) - Apenas um
lAlocConf(Booleano) - Apenas um
lContinua(Booleano) - Apenas um

@author     Jack Junior
@since      12/03/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST ieoGrav WSREST MESAOPERACIONAL

Local aRetorno  := {}
Local cAtend    := ""
Local cBody     := Self:GetContent()
Local cConFal   := ""
Local cDataFim  := ""
Local cDataIni  := ""
Local cEscala   := ""
Local cFilTMP   := ""
Local cPosto    := ""
Local cQry      := GetNextAlias()
Local cSeq      := ""
Local cTipMov   := ""
Local cTipoAl   := ""
Local cWhereTDX := ""
Local cCodTFL	:= ""
Local cCodContr	:= ""
Local lMultFil  := IsMultFil()
Local lAlocConf := .F. //Alocar apenas dias sem conflitos
Local lRet      := .T.
Local lStatus   := .F.
Local nGrupo    := ""
Local oAlocLGY  := NIL
Local oMdlLGY   := NIL
Local oModel    := NIL
Local oParamBody:= JsonObject():New()
Local oResponse := JsonObject():New()

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIf

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
cEscala     := oParamBody['escala']
cCodTFL		:= oParamBody['local']
cCodContr	:= oParamBody['contrato']
cPosto      := oParamBody['posto']
cAtend      := oParamBody['atend']
nGrupo      := oParamBody['grupo']
cDataIni    := oParamBody['dataIni']
cDataFim    := oParamBody['dataFim']
cSeq        := oParamBody['seq']
cTipMov     := oParamBody['tipMov']
lAlocConf	:= oParamBody['alocConf']
cTipoAl     := '1' //Efetivo

If lAlocConf == 1 //Alocar apenas dias sem conflitos
	lAlocConf := .F.
Else //Alocar todos os dias mesmo com conflito
	lAlocConf := .T.
EndIf

oModel := FWLoadModel("TECA190D")
oModel:SetOperation(3)
oModel:Activate()

//oMdlLAC := oModel:GetModel("LACDETAIL")
oMdlLGY := oModel:GetModel("LGYDETAIL")

//Busca Conf Aloc
cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

BeginSQL Alias cQry
	SELECT COALESCE(TDX.TDX_COD,' ') CONFAL
	FROM %Table:TDX% TDX
	WHERE %Exp:cWhereTDX%
		AND TDX.TDX_CODTDW = %Exp:cEscala%
		AND TDX.TDX_SEQTUR = %Exp:cSeq%
		AND TDX.%NotDel%
EndSql

cConFal := (cQry)->(CONFAL)
(cQry)->(DbCloseArea())

//Carga no Modelo dos dados para alocaÁ„o
lRet := lRet .And. oMdlLGY:SetValue("LGY_TIPOAL",cTipoAl)
lRet := lRet .And. oMdlLGY:SetValue("LGY_CODTEC",cAtend)
lRet := lRet .And. oMdlLGY:SetValue("LGY_DTINI" ,stod(cDataIni))
lRet := lRet .And. oMdlLGY:SetValue("LGY_DTFIM" ,stod(cDataFim))
lRet := lRet .And. oMdlLGY:SetValue("LGY_FILIAL",cFilTMP)
lRet := lRet .And. oMdlLGY:SetValue("LGY_CONTRT",cCodContr)
lRet := lRet .And. oMdlLGY:SetValue("LGY_CODTFL",cCodTFL)
lRet := lRet .And. oMdlLGY:SetValue("LGY_CODTFF",cPosto)
If Empty(oMdlLGY:GetValue("LGY_ESCALA"))
	lRet := lRet .And. oMdlLGY:SetValue("LGY_ESCALA",cEscala)
EndIf
lRet := lRet .And. oMdlLGY:SetValue("LGY_SEQ"   ,cSeq)
lRet := lRet .And. oMdlLGY:SetValue("LGY_TIPTCU",cTipMov)
lRet := lRet .And. oMdlLGY:SetValue("LGY_GRUPO" ,nGrupo)
If Empty(oMdlLGY:GetValue("LGY_CONFAL"))
	lRet := lRet .And. oMdlLGY:SetValue("LGY_CONFAL",cConFal)
EndIf

If lRet
	If !EMPTY(oMdlLGY:GetValue("LGY_ESCALA"))
		//Instancia Objeto GSALOC
		oAlocLGY := GsAloc():New()

		//Seta as propriedades do Objeto:
		oAlocLGY:defEscala(oMdlLGY:GetValue("LGY_ESCALA"))
		oAlocLGY:defPosto(oMdlLGY:GetValue("LGY_CODTFF"))
		oAlocLGY:defTec(oMdlLGY:GetValue("LGY_CODTEC"))
		oAlocLGY:defGrupo(oMdlLGY:GetValue("LGY_GRUPO"))
		oAlocLGY:defConfal(oMdlLGY:GetValue("LGY_CONFAL"))
		oAlocLGY:defDate(oMdlLGY:GetValue("LGY_DTINI"),oMdlLGY:GetValue("LGY_DTFIM"))
		oAlocLGY:defSeq(oMdlLGY:GetValue("LGY_SEQ"))
		oAlocLGY:defTpAlo(oMdlLGY:GetValue("LGY_TIPTCU"))
		oAlocLGY:defCob((oMdlLGY:GetValue("LGY_TIPOAL") == '2'))
		If TecMultFil()
			oAlocLGY:defFil(oMdlLGY:GetValue("LGY_FILIAL"))
		EndIf
		If TGY->( ColumnPos("TGY_PROXFE")) > 0
			oAlocLGY:defProxFe(oMdlLGY:GetValue("LGY_PROXFE"))
		EndIf
		If TecXHasEdH() //Indica se o Editor de Hor·rios est· habilitado (MV_GSGEHOR)
			oAlocLGY:defGeHor({{oMdlLGY:GetValue("LGY_ENTRA1"),oMdlLGY:GetValue("LGY_SAIDA1")},;
								{oMdlLGY:GetValue("LGY_ENTRA2"),oMdlLGY:GetValue("LGY_SAIDA2")},;
								{oMdlLGY:GetValue("LGY_ENTRA3"),oMdlLGY:GetValue("LGY_SAIDA3")},;
								{oMdlLGY:GetValue("LGY_ENTRA4"),oMdlLGY:GetValue("LGY_SAIDA4")}})
		EndIf

		//ProjeÁ„o da Agenda
		oAlocLGY:projAloc()

		//Aloca conflitos ?
		oAlocLGY:alocaConflitos(lAlocConf)

		//GravaÁ„o da AlocaÁ„o
		If oAlocLGY:gravaAloc()
			lStatus := .T.
		EndIf

		aAdd(aRetorno,{oAlocLGY:DDTINI, EncodeUtf8(oAlocLGY:cMessage), lStatus})

		//DestrÛi o Objeto
		If VALTYPE(oAlocLGY) == 'O'
			oAlocLGY:destroy()
			oAlocLGY:= nil
		EndIf
	EndIf
Else
	aRetorno := {cDataIni,EncodeUTF8("Falha ao atribuir valor no Modelo de Dados."),.F.}
EndIf

oResponse['retorno'] := aRetorno

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de gravaÁ„o da manutenÁ„o substituiÁ„o do atendente.

@Param BODY:
{
    "filial":"D MG 01 ",
    "atendente":"D MG 01 000054",
    "dataIni":"20230101",
    "dataFim":"20231231",
    "agendas":[{"value":"000000012871"},{"value":"000000012872"}]
}

oResponse - Json Object:

{
    "retorno": "ManutenÁıes Gravadas com sucesso."
}

@author     Jack Junior
@since      15/11/2023
/*/
//------------------------------------------------------------------------------
WSMETHOD POST markManut WSREST MESAOPERACIONAL
Local oModel      := Nil
Local oMdlDTS     := Nil
Local oMdlABB     := Nil
Local oMdlMAN     := Nil
Local oParamBody  := JsonObject():New()
Local oResponse   := JsonObject():New()
Local cBody       := Self:GetContent()
Local aAgendas    := {}
Local cAliasTmp	  := GetNextAlias()
Local inABN		  := ""
Local cMsgRet     := ""
Local cFilTMP     := ""
Local cAtendente  := ""
Local cDataIni    := ""
Local cDataFim    := ""
Local nX          := 0
Local lRet        := .T.
Local aManut	  := {}
Local aMarks	  := {}
Local lMultFil	  := IsMultFil()
Local aRetManut	  := {}

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']     //Filial
cAtendente  := oParamBody['atendente']  //Atendente da agenda
cDataIni    := oParamBody['dataIni']    //Data inicial Filtro
cDataFim    := oParamBody['dataFim']    //Data Final Filtro
aAgendas    := oParamBody['agendas']    //Array de Agendas selecionadas !

//Ativa teca190D - Mesa Operacional - Inclus„o
oModel:= FWLoadModel("TECA190D")
oModel:SetOperation(3)
oModel:Activate()

oMdlAA1 := oModel:GetModel("AA1MASTER")
oMdlDTS := oModel:GetModel("DTSMASTER")
oMdlABB := oModel:GetModel("ABBDETAIL")
oMdlMAN := oModel:GetModel("MANMASTER")

//Preenche o Atendente do Posto:
lRet := lRet .And. oMdlAA1:SetValue("AA1_CODTEC",cAtendente)

//Filtra o range de Datas para Busca das agendas:
lRet := lRet .And. oMdlDTS:SetValue("DTS_DTINI",sTod(cDataIni))
lRet := lRet .And. oMdlDTS:SetValue("DTS_DTFIM",sTod(cDataFim))

//Marca as agendas selecionadas para manutenÁ„o no grid ABB:
For nX := 1 To Len(aAgendas)
	If oMdlABB:SeekLine({{"ABB_CODIGO",aAgendas[nX]['value']}},.F.,.T.)
		lRet := lRet .And. oMdlABB:SetValue("ABB_MARK",.T.)
		AADD(aMarks, {oMdlABB:GetValue("ABB_CODIGO"),;
				oMdlABB:GetValue("ABB_DTINI"),;
				oMdlABB:GetValue("ABB_HRINI"),;
				oMdlABB:GetValue("ABB_DTFIM"),;
				oMdlABB:GetValue("ABB_HRFIM"),;
				oMdlABB:GetValue("ABB_ATENDE"),;
				oMdlABB:GetValue("ABB_CHEGOU"),;
				oMdlABB:GetValue("ABB_IDCFAL"),;
				oMdlABB:GetValue("ABB_DTREF"),;
				.F.,;
				"",;
				oMdlABB:GetValue("ABB_FILIAL");
				})
	EndIf
Next nX

If lRet
	aRetManut := MesaManType(aMarks)
	aManut	:= aRetManut[1]
	lRet	:= aRetManut[2]
	If lRet
		inABN := "%( "
		For nX := 1 To LEN(aManut)
			inABN += "'" + aManut[nX] + "'"
			If nX != LEN(aManut)
				inABN += " , "
			EndIf
		Next nX
		inABN += " )%"

		cWhereABN := JoinSQL(lMultFil, "ABN.ABN_FILIAL", "ABN", "ABN", cFilTMP, "WHERE")
		
		BeginSql Alias cAliasTmp
			SELECT ABN.ABN_FILIAL, ABN.ABN_CODIGO, ABN.ABN_DESC, ABN.ABN_TIPO
			//Motivos de ManutenÁıes
			FROM %table:ABN% ABN
			WHERE %exp:cWhereABN% 
				AND ABN.ABN_TIPO IN %exp:inABN%
				AND ABN.%NotDel% 
		EndSql
		DbSelectArea(cAliasTmp)
		(cAliasTmp)->(DbGoTop())
	Else
		lRet := .F.
		cMsgRet := "A inclus„o de manutenÁıes em lote sÛ pode ser executada em registros da mesma filial. Selecione apenas registros da mesma filial e execute a inclus„o."
	EndIf
Else
	lRet := .F.
	cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]+oModel:GetErrorMessage()[4]
EndIf

oModel:DeActivate()

oResponse['retorno'] := {}

If lRet
	If (cAliasTmp)->(! Eof())
		Aadd(oResponse['retorno'], JsonObject():New())
		aTail(oResponse['retorno'])['error']    := .F.
		aTail(oResponse['retorno'])['mensagem'] := EncodeUtf8(AllTrim("ManutenÁıes encontradas!"))

		//Tipo Exclus„o de agenda FIXO:
		Aadd(oResponse['retorno'], JsonObject():New())
		aTail(oResponse['retorno'])['ABN_FILIAL']:= ""
		aTail(oResponse['retorno'])['ABN_CODIGO']:= "999999"
		aTail(oResponse['retorno'])['ABN_DESC']  := EncodeUTF8("Exclus„o de Agenda")
		aTail(oResponse['retorno'])['ABN_TIPO']  := "EA"

		While (cAliasTmp)->(! Eof())
			//Monta o Objeto JSon a ser retornado:
			Aadd(oResponse['retorno'], JsonObject():New())
			aTail(oResponse['retorno'])['ABN_FILIAL']	:= AllTrim((cAliasTmp)->ABN_FILIAL)
			aTail(oResponse['retorno'])['ABN_CODIGO']   := AllTrim((cAliasTmp)->ABN_CODIGO)
			aTail(oResponse['retorno'])['ABN_DESC']		:= EncodeUTF8(AllTrim((cAliasTmp)->ABN_DESC))
			aTail(oResponse['retorno'])['ABN_TIPO']		:= AllTrim((cAliasTmp)->ABN_TIPO)
			(cAliasTmp)->(DbSkip())
		Enddo
		(cAliasTmp)->(DbCloseArea())
	Else
		Aadd(oResponse['retorno'], JsonObject():New())
		aTail(oResponse['retorno'])['error']    := .T.
		aTail(oResponse['retorno'])['mensagem'] := EncodeUtf8(AllTrim("Nenhum tipo de manutenÁ„o encontrado."))
	EndIf
Else
	Aadd(oResponse['retorno'], JsonObject():New())
	aTail(oResponse['retorno'])['error']    := .T.
	aTail(oResponse['retorno'])['mensagem'] := EncodeUtf8(AllTrim(cMsgRet))
EndIf

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo POST de AlteraÁ„o de uma manutenÁ„o j· existente

@Param BODY:
{
    "filial": "D MG 01 ",
    "hrini": "06:00",
    "hrfim": "06:00",
    "codsub": "D MG 01 000053",
    "tipodia": "S",
    "agenda": "000000012867",
    "manut": "000000000000001",
    "motivo": "000002",
    "tipaloc": "002"
}

oResponse - Json Object:

{
    "retorno": [
        {
            "retorno": true,
            "mensagem": "ManutenÁ„o alterada com sucesso."
        }
    ]
}

@author     Jack Junior
@since      15/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD POST alterManut WSREST MESAOPERACIONAL
Local oModel      := Nil
Local oParamBody  := JsonObject():New()
Local oResponse   := JsonObject():New()
Local cBody       := Self:GetContent()
Local cMsgRet     := ""
Local cFilTMP     := ""
Local cHrIni	  := ""
Local cHrFim	  := ""
Local cCodSub	  := ""
Local cTipDia	  := ""
Local cAgenda	  := ""
Local cManut	  := ""
Local cMotivo	  := ""
Local cValTipo	  := ""
Local lRet        := .T.
Local lAlter	  := .F.

//Transforma Body em objeto JSon
If !Empty(cBody)
	oParamBody:FromJson(cBody)
EndIF

//Inicializa parametros do Body JSON passado do Front:
cFilTMP	:= oParamBody['filial']	//Filial
cHrIni	:= oParamBody['hrini']	//Hora Inicial
cHrFim	:= oParamBody['hrfim']	//Hora Final
cCodSub	:= oParamBody['codsub']	//Cod ABB
cTipDia	:= oParamBody['tipodia']	//Cod ABB
cAgenda	:= oParamBody['agenda']	//Cod ABB
cManut	:= oParamBody['manut']	//Cod ABB
cMotivo := oParamBody['motivo']	//Cod ABB
cValTipo:= oParamBody['tipaloc'] //Tipo de AlocaÁ„o

If !Empty(cManut) .And. !Empty(cMotivo) .And. !Empty(cAgenda) .And. !Empty(cFilTMP) 
	If AllTrim(cMotivo) == "999999"
		cTipo := "EA" //Exclus„o de Agenda
	Else
		//ABN_FILIAL+ABN_CODIGO+ABN_TIPO
		cTipo := Posicione("ABN",1,xFilial("ABN", cFilTMP)+cMotivo,"ABN_TIPO")
	EndIf

	//Select area MANUTEN«’ES
	dbSelectArea('ABR')
	ABR->(dbSetOrder(2)) //ABR_FILIAL+ABR_MANUT+ABR_AGENDA

	//Posiciona na manutenÁ„o
	If ABR->(dbSeek(xFilial("ABR", cFilTMP)+cManut+cAgenda))

		BEGIN TRANSACTION
			At550SetAlias('ABB')
			At550SetGrvU(.T.)

			//Select area AGENDAS
			dbSelectArea('ABB')
			ABB->(dbSetOrder(8)) //ABB_FILIAL+ABB_CODIGO

			If (ABB->(DbSeek(xFilial('ABB')+cAgenda)))
				//Ativa TECA550 - ManutenÁıes ABR
				oModel:= FWLoadModel("TECA550")

				//Seta vari·veis Est·ticas no TECA550 para evitar mensagens em tela.
				At550MPOUI(.T., cValTipo)

				//Se n„o for exclus„o
				If cMotivo != "999999"
					//ALTERA«√O DE MANUTEN«√O:
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
					oModel:Activate()

					//ALTERAR HORA INI
					If cTipo $ "02|04" //ATRASO, HORA EXTRA
						If AllTrim(cHrIni) != AllTrim(oModel:GetValue("ABRMASTER","ABR_HRINI"))
							lAlter := .T.
							lRet := lRet .And. oModel:SetValue("ABRMASTER","ABR_HRINI", cHrIni)
						EndIF
					EndIf
					//ALTERAR HORA FIM
					If lRet .And. cTipo $ "03|04" //SAÕDA ANTECIPADA, HORA EXTRA 
						If AllTrim(cHrFim) != AllTrim(oModel:GetValue("ABRMASTER","ABR_HRFIM"))
							lAlter := .T.
							lRet := lRet .And. oModel:SetValue("ABRMASTER","ABR_HRFIM", cHrFim)
						EndIf
					EndIf
					//ALTERAR COD SUBSTITUTO
					If lRet .And. cTipo $ "01|02|03" //FALTA, ATRASO, SAÕDA ANTECIPADA
						If AllTrim(cCodSub) != AllTrim(oModel:GetValue("ABRMASTER","ABR_CODSUB"))
							lAlter := .T.
							lRet := lRet .And. oModel:SetValue("ABRMASTER","ABR_CODSUB", cCodSub)
							If lRet .And. Empty(cValTipo)
								lRet := .F.
								oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"WSMESA","Tipo de AlocaÁ„o n„o pode estar vazio com atendente substituto")
							EndIf
						EndIf
					EndIf
					//ALTERAR TIPO DO DIA
					If lRet .And. cTipo $ "01|02|03" //FALTA, ATRASO, SAÕDA ANTECIPADA
						If AllTrim(cTipDia) != AllTrim(oModel:GetValue("ABRMASTER","ABR_TIPDIA"))
							lAlter := .T.
							lRet := lRet .And. oModel:SetValue("ABRMASTER","ABR_TIPDIA", cTipDia)
						EndIf
					EndIf

					If lRet
						//Caso algo tenha sido alterado, commita o modelo
						If lAlter
							If oModel:VldData() .And. oModel:CommitData()
								lRet := .T.
								cMsgRet := "ManutenÁ„o alterada com sucesso."
							Else
								lRet := .F.
								cMsgRet := oModel:GetErrorMessage()[4] + " - " + oModel:GetErrorMessage()[6]
							EndIf
						Else
							lRet := .F.
							cMsgRet := "Nenhuma alteraÁ„o foi efetuada."
						EndIf
					Else
						lRet := .F.
						cMsgRet := "Falha no Modelo: "+CRLF+oModel:GetErrorMessage()[6]+oModel:GetErrorMessage()[4]
					EndIf
				Else
					//EXCLUS√O DE MANUTEN«√O:
					oModel:SetOperation(MODEL_OPERATION_DELETE)
					oModel:Activate()
					If !oModel:VldData() .OR. !oModel:CommitData()
						cMsgRet := "Falha na Exclus„o da ManutenÁ„o de Agenda: "+CRLF+oModel:GetErrorMessage()[6]+oModel:GetErrorMessage()[4]
					Else
						lRet := .T.
						cMsgRet := "ManutenÁ„o de agenda excluÌda com sucesso."
					EndIf
				EndIf
				oModel:DeActivate()
			Else
				lRet := .F.
				cMsgRet := "Agenda n„o encontrada."
			EndIf
		END TRANSACTION
	Else
		lRet := .F.
		cMsgRet := "ManutenÁ„o n„o encontrada."
	EndIf
Else
	lRet := .F.
	cMsgRet := "Exitem dados faltantes na requisiÁ„o HTTP."
EndIf

oResponse['retorno'] := {}

Aadd(oResponse['retorno'], JsonObject():New())
aTail(oResponse['retorno'])['retorno']	:= lRet
aTail(oResponse['retorno'])['mensagem'] := EncodeUtf8(AllTrim(cMsgRet))

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

//Limpa as est·ticas
At550MPOUI(.F., "")

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

MÈtodo GET de ValidaÁ„o de conflito de hor·rios na exclus„o da manutenÁ„o

@Param cFil - filial(String) - Apenas uma (Combo Box no front)
		cCodABB - CÛdigo da Agenda
		cAtend - CÛdigo do Atendente
		cCodManut - CÛdigo da ManutenÁ„o

@author     Jack Junior
@since      23/04/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET conflitaHora WSRECEIVE cFil, cCodABB, cAtend, cCodManut WSREST MESAOPERACIONAL
Local cAbbAlias := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cABB		:= ""
Local cCodTec	:= ""
Local cManut	:= ""
Local cWhereABB := ""
Local cTipo		:= ""
Local cMsg		:= ""
Local lConf		:= .F.
Local lRet		:= .T.
Local lPermConfl:= AT680Perm(NIL, __cUserID, "017")
Local dDtIni	:= StoD("")
Local dDtFim	:= StoD("")
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cABB 	:= self:cCodABB
cCodTec	:= self:cAtend
cManut	:= self:cCodManut

//Select area MANUTEN«’ES
dbSelectArea('ABR')
ABR->(dbSetOrder(2)) //ABR_FILIAL+ABR_MANUT+ABR_AGENDA

//Posiciona na manutenÁ„o
If ABR->(dbSeek(xFilial("ABR", cFilTMP)+cManut+cABB))

	//ABN_FILIAL+ABN_CODIGO+ABN_TIPO
	cTipo := Posicione("ABN",1,xFilial("ABN", cFilTMP)+ABR->ABR_MOTIVO,"ABN_TIPO")

	dDtIni := ABR->ABR_DTINIA
	dDtFim := ABR->ABR_DTFIMA

	//Atualiza status da agenda
	DbSelectArea('ABB')		//Agenda de Atendentes
	ABB->(DbSetOrder(8))	//ABB_FILIAL + ABB_CODIGO
	
	//Posiciona na Agenda ABB
	If ( ABB->( DbSeek( xFilial('ABB') + cABB ) ) )

		cWhereABB := JoinSQL(lMultFil, "ABB.ABB_FILIAL", "ABB", "ABB", cFilTMP, "WHERE")

		// VerificaÁ„o de conflito de hor·rios ao excluir manutenÁ„o de agenda
		BeginSQL Alias cAbbAlias
		SELECT  ABB_HRINI,
				ABB_HRFIM
		FROM %Table:ABB% ABB
			WHERE %Exp:cWhereABB%
				AND ABB.ABB_CODTEC = %Exp:cCodTec%
				AND ABB.ABB_DTINI = %Exp:DToS( dDtIni )%
				AND ABB.ABB_DTFIM = %Exp:DToS( dDtFim )%
				AND ABB.ABB_ATIVO = '1'
				AND ABB.ABB_CODIGO <> %Exp:cABB%
				AND ABB.%NotDel%
		EndSQL

		If (cAbbAlias)->(!Eof()) .AND. cTipo <> "04" //HORA EXTRA
			While (cAbbAlias)->(!Eof())
				If ABB->ABB_HRINI < (cAbbAlias)->ABB_HRINI .OR. ABB->ABB_HRINI > (cAbbAlias)->ABB_HRFIM
					If !lConf
						If ABB->ABB_HRINI < (cAbbAlias)->ABB_HRINI
							If ABB->ABB_HRFIM <= (cAbbAlias)->ABB_HRINI
								lConf := .F.
							Else
								lConf := .T.
							EndIf
						Else
							lConf := .F.
						EndIf
					EndIf
				Else
					lConf := .T.
				EndIf
			(cAbbAlias)->(dbSkip())
			EndDo
		Else
			lConf := .F.
		EndIf
		(cAbbAlias)->(DbCloseArea())

		If lConf
			If lPermConfl
				lRet := .T.
				cMsg := "Agenda com conflito de hor·rios. Deseja continuar ?"
			Else
				lRet := .F.
				cMsg := "Existe(m) conflito(s) entre horario(s). N„o È possÌvel excluir essa manutenÁ„o."
			EndIf
		Else
			lRet := .T.
			cMsg := ""
		EndIf
	Else
		lRet := .F.
		cMsg := "Agenda n„o encontrada."
	EndIf
Else
	lRet := .F.
	cMsg := "ManutenÁ„o n„o encontrada."
EndIf

//Monta o Objeto JSon a ser retornado:
oResponse['conflitaHora'] := {}
Aadd(oResponse['conflitaHora'], JsonObject():New())
aTail(oResponse['conflitaHora'])['valid']	:= lRet
aTail(oResponse['conflitaHora'])['msg']		:= EncodeUtf8(AllTrim(cMsg))

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

WSMETHOD GET contratoRealoc WSRECEIVE cFil WSREST MESAOPERACIONAL
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

oResponse['contratoRealoc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['contratoRealoc'], JsonObject():New())
		aTail(oResponse['contratoRealoc'])['contrato']	:= AllTrim((cAliasTmp)->CN9_NUMERO)
		aTail(oResponse['contratoRealoc'])['revisao']	:= AllTrim((cAliasTmp)->CN9_REVISA)
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return

WSMETHOD GET localRealoc WSRECEIVE cFil, cContrato, cRevisao WSREST MESAOPERACIONAL
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

oResponse['localRealoc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['localRealoc'], JsonObject():New())
		aTail(oResponse['localRealoc'])['tflcod']	:= AllTrim((cAliasTmp)->TFL_CODIGO)
		aTail(oResponse['localRealoc'])['local']	:= AllTrim((cAliasTmp)->TFL_LOCAL)
		aTail(oResponse['localRealoc'])['desc']		:= EncodeUTF8(AllTrim((cAliasTmp)->ABS_DESCRI))
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return

WSMETHOD GET postoRealoc WSRECEIVE cFil, cTFL WSREST MESAOPERACIONAL
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

oResponse['postoRealoc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['postoRealoc'], JsonObject():New())
		aTail(oResponse['postoRealoc'])['tffcod']		:= AllTrim((cAliasTmp)->TFF_COD)
		aTail(oResponse['postoRealoc'])['codprod']		:= AllTrim((cAliasTmp)->TFF_PRODUT)
		aTail(oResponse['postoRealoc'])['descprod']  	:= EncodeUTF8(AllTrim((cAliasTmp)->B1_DESC))
		aTail(oResponse['postoRealoc'])['codprod']		:= AllTrim((cAliasTmp)->TFF_QTDVEN)
		aTail(oResponse['postoRealoc'])['escala']		:= AllTrim((cAliasTmp)->TFF_ESCALA)
		aTail(oResponse['postoRealoc'])['descescala']	:= EncodeUTF8(AllTrim((cAliasTmp)->TDW_DESC))
		aTail(oResponse['postoRealoc'])['itemextra']	:= AllTrim((cAliasTmp)->TFF_ITEXOP)
		aTail(oResponse['postoRealoc'])['qtdhoras']		:= AllTrim((cAliasTmp)->TFF_QTDHRS)
		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return

WSMETHOD GET escalaRealoc WSRECEIVE cFil WSREST MESAOPERACIONAL
Local oResponse := JsonObject():New()
Local lMultFil  := IsMultFil()
Local cAliasTmp := GetNextAlias()
Local cFilTMP   := ''
Local cWhereTDW := ''

cFilTMP := self:cFil

cWhereTDW := JoinSQL(lMultFil, "TDW.TDW_FILIAL", "TDW", "TDW", cFilTMP, "WHERE")

Self:SetContentType("application/json")

BeginSql Alias cAliasTmp
    SELECT DISTINCT TDW.TDW_COD, TDW.TDW_DESC
    FROM %table:TDW% TDW
	WHERE %exp:cWhereTDW%
			AND TDW.%NotDel%
	ORDER BY TDW_COD
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['escalaRealoc'] := {}

If (cAliasTmp)->(! Eof())

	While (cAliasTmp)->(! Eof())
		Aadd(oResponse['escalaRealoc'], JsonObject():New())

		aTail(oResponse['escalaRealoc'])['codescala']	:= AllTrim((cAliasTmp)->TDW_COD)
		aTail(oResponse['escalaRealoc'])['descescala'] := EncodeUTF8(AllTrim((cAliasTmp)->TDW_DESC))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf

(cAliasTmp)->(DbCloseArea())

Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

return

WSMETHOD GET seqIniRealoc WSRECEIVE cFil, cEscala WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodEscala:= ""
Local cWhereTDX := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil
cCodEscala := self:cEscala

//Tratamento de multifilial:
cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TDX.TDX_COD, TDX.TDX_TURNO, TDX.TDX_SEQTUR
    FROM %table:TDX% TDX
    WHERE %exp:cWhereTDX%
	        AND TDX.TDX_CODTDW = %exp:cCodEscala%
            AND TDX.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['seqIniRealoc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['seqIniRealoc'], JsonObject():New())

		aTail(oResponse['seqIniRealoc'])['codtdx']     := AllTrim((cAliasTmp)->TDX_COD)
		aTail(oResponse['seqIniRealoc'])['codturno']   := AllTrim((cAliasTmp)->TDX_TURNO)
		aTail(oResponse['seqIniRealoc'])['sequencia']  := AllTrim((cAliasTmp)->TDX_SEQTUR)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

WSMETHOD GET tpMovRealoc WSRECEIVE cFil WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cWhereTCU := ""
Local cCondRes  := "1"
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil

cWhereTCU := JoinSQL(lMultFil, "TCU.TCU_FILIAL", "TCU", "TCU", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TCU.TCU_COD, TCU.TCU_DESC
    FROM %table:TCU% TCU
    WHERE %exp:cWhereTCU%
	        AND TCU.TCU_RESTEC <> %exp:cCondRes%
            AND TCU.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['tpMovRealoc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['tpMovRealoc'], JsonObject():New())

		aTail(oResponse['tpMovRealoc'])['codmotivo']  := AllTrim((cAliasTmp)->TCU_COD)
		aTail(oResponse['tpMovRealoc'])['descmotivo'] := EncodeUTF8(AllTrim((cAliasTmp)->TCU_DESC))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

WSMETHOD GET confAlocRealoc WSRECEIVE cFil, cEscala, cSequencia WSREST MESAOPERACIONAL
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cCodEscala:= ""
Local cSeq		:= ""
Local cJoinSR6	:= ""
Local cWhereTDX := ""
Local lMultFil  := IsMultFil()

cFilTMP 	:= self:cFil
cCodEscala 	:= self:cEscala
cSeq 		:= self:cSequencia
//Tratamento de multifilial:
cJoinSR6  := JoinSQL(lMultFil, "SR6.R6_FILIAL", "TDX", "SR6", cFilTMP, "JOIN")
cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

BeginSql Alias cAliasTmp
    SELECT TDX.TDX_COD, TDX.TDX_TURNO, TDX.TDX_SEQTUR, SR6.R6_DESC
    FROM %table:TDX% TDX
		INNER JOIN %table:SR6% SR6
			ON (%exp:cJoinSR6% 
			AND SR6.R6_TURNO = TDX.TDX_TURNO
			AND SR6.%NotDel%)
    WHERE %exp:cWhereTDX%
	        AND TDX.TDX_CODTDW = %exp:cCodEscala%
			AND TDX.TDX_SEQTUR = %exp:cSeq%
            AND TDX.%NotDel% 
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['confAlocRealoc'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())
		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['confAlocRealoc'], JsonObject():New())

		aTail(oResponse['confAlocRealoc'])['codtdx']  := AllTrim((cAliasTmp)->TDX_COD)
		aTail(oResponse['confAlocRealoc'])['descr']   := EncodeUTF8(AllTrim((cAliasTmp)->R6_DESC))

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informaÁıes solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return
