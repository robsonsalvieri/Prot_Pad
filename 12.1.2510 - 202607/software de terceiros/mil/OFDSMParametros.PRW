#include "totvs.ch"

function OFDSMParametros()
return .t.

/*/{Protheus.doc} OFDSMParametros
	Classe responsavel por retornar os parametros de configuracao do DSM
	@type class
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Class OFDSMParametros
	Data oDados
	Data oUltExec

	Method New() CONSTRUCTOR
	Method filiais()
	Method warehouse_id()
	Method filial_warehouse_id()
	Method grupos()
	Method operator_id()
	Method owner_id()
	Method codigo_moeda()
	Method grupo_principal()
	Method url_xml()
	Method user_webservice()
	Method pass_webservice()
	Method DataHoraInit()
	Method NumSeqInit()
	Method tags_tiks()
	Method agrega_resblq()
	Method agrega_transito()
	Method tipos_assunto() 
	Method codigos_motivo()
	Method diretorio_XML()
	Method precoVenda_Forml()
	Method precoReposicao_Forml()
	Method envia_glass()
	Method envia_atualizacao_preco()
EndClass

/*/{Protheus.doc} New
	Simples construtor
	@type function
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Method New() Class OFDSMParametros
	::oDados   := OA010008C_getConfig( .T. )
	::oUltExec := OA030035C_getConfig()
return self

/*/{Protheus.doc} filiais
	Retorna as filiais que usam DSM
	@type function
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Method filiais() Class OFDSMParametros
Return ::oDados["FILIAIS_DSM"]

/*/{Protheus.doc} warehouse_id
	Retorna os warehouse_id das filiais que usam DSM
	@type function
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Method warehouse_id() Class OFDSMParametros
Return ::oDados["WAREHOUSE_ID"]

/*/{Protheus.doc} filial_warehouse_id
	Retorna o warehouse_id da filial logada
	@type function
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Method filial_warehouse_id() Class OFDSMParametros
local nPos      := 0
local aFiliais  := self:oDados["FILIAIS_DSM"]
local aWHouseID := self:oDados["WAREHOUSE_ID"]
local cWHouseID := ""
	nPos := aScan( aFiliais , cFilAnt ) // Pesquisa se a Filial Logada esta nas Filiais disponiveis para DSM
	If nPos > 0 .and. len(aWHouseID) >= nPos
		cWHouseID := aWHouseID[nPos] // Warehouse ID esta na mesma posicao da Filial nos vetores aFiliais/aWHouseID
	EndIf
Return cWHouseID

/*/{Protheus.doc} Grupos
	Retorna os grupos de peças DSM
	@type function
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Method grupos() Class OFDSMParametros
Return self:oDados["GRUPOS"]

/*/{Protheus.doc} operator_id
	Retorna o operator_id do DSM
	@type function
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Method operator_id() Class OFDSMParametros
Return self:oDados["OPERATOR_ID"]

/*/{Protheus.doc} owner_id
	Retorna o owner_id do DSM
	@type function
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Method owner_id() Class OFDSMParametros
Return self:oDados["OWNER_ID"]

/*/{Protheus.doc} codigo_moeda
	Retorna o codigo_moeda do DSM
	@type function
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Method codigo_moeda() Class OFDSMParametros
Return self:oDados["CODIGO_MOEDA"]

/*/{Protheus.doc} grupo_principal
	Retorna o grupo_principal do DSM
	@type function
	@author Andre Luis Almeida
	@since 20/09/2018
/*/
Method grupo_principal() Class OFDSMParametros
Return self:oDados["GRUPO_PRINCIPAL"]

/*/{Protheus.doc} url_xml
	Retorna a url do XML do DSM
	@type function
	@author Andre Luis Almeida
	@since 03/09/2018
/*/
Method url_xml() Class OFDSMParametros
Return Alltrim(self:oDados["URL_XML"])

/*/{Protheus.doc} user_webservice
	Retorna a Usuario do WebService do DSM
	@type function
	@author Andre Luis Almeida
	@since 07/08/2019
/*/
Method user_webservice() Class OFDSMParametros
Return self:oDados["USER_WEBSERVICE"]

/*/{Protheus.doc} pass_webservice
	Retorna a Senha do Usuario do WebService do DSM
	@type function
	@author Andre Luis Almeida
	@since 07/08/2019
/*/
Method pass_webservice() Class OFDSMParametros
Return self:oDados["PASS_WEBSERVICE"]

/*/{Protheus.doc} DataHoraInit
	Data/Hora em que foi delimitado init
	@type function
	@author Andre Luis Almeida
	@since 14/08/2018
/*/
Method DataHoraInit() Class OFDSMParametros
local nI
local aRet := { StoD( "19000101" ), "00:00:00" }
local oAux

	for nI := 1 to len( ::oUltExec["FILIAIS"] )
		oAux := ::oUltExec["FILIAIS"][nI]
		if oAux["FILIAL"] == cFilAnt
			aRet[1] := StoD( oAux["ULTIMA_EXECUCAO"]["DATA"] )
			aRet[2] := oAux["ULTIMA_EXECUCAO"]["HORA"]
			exit
		endif
	next
	freeObj("oAux")
return aRet

/*/{Protheus.doc} NumSeqInit
	NUMSEQ (SD1/SD2/SD3/VE9/VBJ) que foi delimitado init
	@type function
	@author Andre Luis Almeida
	@since 29/08/2018
/*/
Method NumSeqInit(cTabela,cCampo) Class OFDSMParametros
local nI
local cRet := iif( cCampo == "NROSUB", "0000000000", "000000" )
local oAux

	for nI := 1 to len( ::oUltExec["FILIAIS"] )
		oAux := ::oUltExec["FILIAIS"][nI]
		if oAux["FILIAL"] == cFilAnt
			cRet := oAux[cTabela][cCampo]
			exit
		endif
	next
	freeObj("oAux")
return cRet

/*/{Protheus.doc} tags_tiks
	Retorna o Tik (1=Sim/0=Nao) para levantar as TAGs
	@type function
	@author Andre Luis Almeida
	@since 22/05/2020
/*/
Method tags_tiks(nTik) Class OFDSMParametros
Return self:oDados["TAG_TIK"+strzero(nTik,2)]

/*/{Protheus.doc} agrega_resblq
	Retorna se Agrega a Qtde.Reservada/Bloqueada
	@type function
	@author Andre Luis Almeida
	@since 22/05/2020
/*/
Method agrega_resblq() Class OFDSMParametros
Return self:oDados["AGREGA_QTDE_RESBLQ"]

/*/{Protheus.doc} agrega_transito
	Retorna se Agrega a Qtde. Estoque Em Transito
	@type function
	@author Andre Luis Almeida
	@since 22/05/2020
/*/
Method agrega_transito() Class OFDSMParametros
Return self:oDados["AGREGA_QTDE_TRANSITO"]

/*/{Protheus.doc} tipos_assunto
	Retorna os TIPOS ASSUNTO do DSM lost sales - 
	@type function
	@author emanuel bezerra
	@since 11/02/2026
/*/
Method tipos_assunto() Class OFDSMParametros
Return self:oDados["TIPOS_ASSUNTO"]

/*/{Protheus.doc} codigos_motivo
	Retorna os codigos_motivo do DSM lost sales - 
	@type function
	@author emanuel bezerra
	@since 11/02/2026
/*/
Method codigos_motivo() Class OFDSMParametros
Return self:oDados["CODIGOS_MOTIVO"]

/*/{Protheus.doc} diretorio_XML
	Retorna o diretório XML onde o arquivo será salvo
	@type function
	@author emanuel bezerra
	@since 11/02/2026
/*/
Method diretorio_XML() Class OFDSMParametros
Return Alltrim(self:oDados["PASTA"])

/*/{Protheus.doc} precoVenda_Forml
	Retorna a fórmula a formula de preço de venda definida pelo usuário
	@type function
	@author Lucas Oliveira
	@since 11/02/2026
/*/
Method precoVenda_Forml() Class OFDSMParametros
Return self:oDados["PRC_VENDA"]

/*/{Protheus.doc} precoReposicao_Forml
	Retorna a fórmula a formula de preço de reposição definida pelo usuário
	@type function
	@author Lucas Oliveira
	@since 11/02/2026
/*/
Method precoReposicao_Forml() Class OFDSMParametros
Return self:oDados["PRC_REPOSICAO"]

/*/{Protheus.doc} precoReposicao_Forml
	Retorna a fórmula a formula de preço de reposição definida pelo usuário
	@type function
	@author Lucas Oliveira
	@since 11/02/2026
/*/
Method envia_atualizacao_preco() Class OFDSMParametros
Return self:oDados["TAG_TIK12"] == "1"

/*/{Protheus.doc} precoReposicao_Forml
	Retorna a fórmula a formula de preço de reposição definida pelo usuário
	@type function
	@author Lucas Oliveira
	@since 11/02/2026
/*/
Method envia_glass() Class OFDSMParametros
Return self:oDados["TAG_TIK13"] == "1"