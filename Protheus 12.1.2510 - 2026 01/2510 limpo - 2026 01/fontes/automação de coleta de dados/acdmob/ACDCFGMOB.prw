#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'protheus.ch'
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "ACDCFGMOB.ch"



//------------------------------------------------------------------------------
/*/{Protheus.doc} ACDCFGMOB
Classe responsável por retornar uma Listagem com as configurações do MOBILE
@author	 	Andre Maximo 
@since		02/03/2020
@version	12.1.25
/*/
//------------------------------------------------------------------------------
WSRESTFUL ACDCFGMOB DESCRIPTION "retornar uma Listagem com as configurações do MOBILE

WSDATA AcdUserName      AS STRING   OPTIONAL
WSDATA AcdParam         AS STRING   OPTIONAL

/*-------------------Get config--------------------------------------*/
WSMETHOD GET  OPERATOR ;
DESCRIPTION "Retorna as permissoes do operador";
WSSYNTAX "api/acdcfgmob/v1/operator/{AcdUserName}";
PATH "api/acdcfgmob/v1/operator"       PRODUCES APPLICATION_JSON

WSMETHOD GET  Configure_mob ;
DESCRIPTION "Retorna dados relacionados ao dicionario dados.";
WSSYNTAX "api/acdcfgmob/v1/config";
PATH "api/acdcfgmob/v1/config"       PRODUCES APPLICATION_JSON

WSMETHOD GET  identification_mob ;
DESCRIPTION "Retorna nome e CNPJ da empresa.";
WSSYNTAX "api/acdcfgmob/v1/identification";
PATH "api/acdcfgmob/v1/identification"       PRODUCES APPLICATION_JSON

WSMETHOD GET  parameters_mob ;
DESCRIPTION "Traz os parametros do acd e do mobile.";
WSSYNTAX "api/acdcfgmob/v1/parameters/{acdParam}";
PATH "api/acdcfgmob/v1/parameters"       PRODUCES APPLICATION_JSON

END WSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET/Code/ACDMOB
Traz a configuração do campo b2_QTATU para o mobile

@param  Code    , caracter, Codigo para Pesquisa.
@return cResponse	, Array, JSON com Array

@author	 	André Maximo
@since		03/03/2020
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET  Configure_mob WSSERVICE ACDCFGMOB
Local cPesqPict 
Local cResponse := " " 
Local nQuanti   := 0
Local nDecimal  := 0
Local lRet      := .F.
Local oJConfig  := JsonObject():New()

Self:SetContentType("application/json")

//Recebe a configuração do B2_QATU para ajuste de casas decimais.
cPesqPict   := CBPictQtde()
aQtdcpo     := TamSX3("B2_QATU")
If len(aQtdcpo) > 0 
    nQuanti    :=  aQtdcpo[1] 
    nDecimal   :=  aQtdcpo[2]
Endif

If !Empty(cPesqPict)  
    oJConfig["picture"] :=  cPesqPict
    oJConfig["quantity"] := nQuanti
    oJConfig["decimal"]  := nDecimal
    lRet:= .T.
EndIf

If setError(lRet)
	cResponse := oJConfig:toJson()
    Self:SetResponse(cResponse)
EndIf

FreeObj(oJConfig)
oJConfig := Nil

Return (lRet)


/*/{Protheus.doc} retorna itens da nota/pre nota
 Altera o Status da separacao ou finaliza no protheus

@param	tabela Temp
@author	 	andre.maximo
@since		06/03/2020
@version	12.1.25
/*/
 
function AcdMobEmb(cProd,nQtdOri)

Local aEtiqueta	:= {}
Local nQtdEmb	:= 0
Local nQE		:= 1
Local nQtdeProd := 0
Default cProd	:= CriaVar("B1_COD",.F.)
Default nQtdOri := 0

aEtiqueta := CBRetEtiEAN(cProd)
If len(aEtiqueta) > 0
	nQtdEmb := aEtiqueta[2]
EndIf


If ! CBProdUnit(cProd)
	nQE := CBQtdEmb(cProd)	
EndIf
nQtdeProd:= nQtdOri * nQE * nQtdEmb


Return nQtdeProd



//-------------------------------------------------------------------
/*/{Protheus.doc} GET/Code/ACDMOB
Retorna dados da configuração do Mobile

@return cResponse	, Array, JSON com Array
@author	 	Robson Santos
@since		12/06/2020
@version	12.1.25
/*/
//-------------------------------------------------------------------
WSMETHOD GET  identification_mob WSSERVICE ACDCFGMOB
Local aFil      := {}
Local cResponse := " " 
Local lRet      := .F.
Local oJIdent   := JsonObject():New()

Self:SetContentType("application/json")

aFil := FWArrFilAtu()

If Len(aFil) > 0
    oJIdent["companyName"]  := aFil[17]
    oJIdent["id"]           := aFil[18]
    lRet:= .T.
EndIf

If setError(lRet)
	cResponse := oJIdent:toJson()
    Self:SetResponse(cResponse)
EndIf

FreeObj(oJIdent)
oJIdent := Nil

Return (lRet)


/*/{Protheus.doc} operator
    Traz as permissões do operador no mobile
    @type  Method
    @author rodrigo.lombardi
    @since 10/10/2025
    @version v1.0
    @param acdUserName, string, Nome do usuario logado no mobile
    @return cResponse, jSon, Json de retorno com nome de usuario e permissoes
/*/
WSMETHOD GET OPERATOR WSRECEIVE AcdUserName WSSERVICE ACDCFGMOB

Local cResponse := " "
Local lRet := .F.
Local cUsrCod  := ''
Local n := 0
Local oResponse := JsonObject():New()
Local aRotina := menudef()
Default self:AcdUserName := ''

if !Empty(self:AcdUserName)
    cUsrCod := retCodUsr(self:AcdUserName)
EndIf
Self:SetContentType("application/json")

if !Empty(cUsrCod)
    //Monto as permissões baseado nas rotinas do menuDef
    for n := 1 to Len(aRotina)
        oResponse[ aRotina[n][2] ] := MPUserHasAccess('ACDCFGMOB', n, cUsrCod ,.f.)
    next
    
    lRet := .T.
EndIf

if setError(lRet,,STR0007) // "Usuário não informado ou inválido."
    cResponse := FwJsonSerialize(oResponse)
    Self:SetResponse(cResponse) 
EndIf

FwFreeArray(aRotina)
FreeObj(oResponse)

return (lRet)

/*/{Protheus.doc} parameters_mob
    Traz os parâmetros do mobile e do ACD
    @type  Method
    @author rodrigo.lombardi
    @since 30/10/2025
    @version v1.0
    @param acdParam, string, Nome do parametro a ser retornado
    @return cResponse, jSon, retorno do parametro solicitado
    @example
        GET api/acdcfgmob/v1/parameters?acdParam=MV_MCDCLTE
/*/

WSMETHOD GET parameters_mob WSRECEIVE acdParam WSSERVICE ACDCFGMOB
Local cResponse := " "
Local lRet := .F.
Local oResponse := JsonObject():New()
Local aParams := {"MV_MCDCLTE","MV_CLACFDV","MV_MCDTPBE","MV_MCDSQTD","MV_MCDFCP","MV_SUBNSER"}
default self:AcdParam := ''

if !Empty(self:AcdParam)
    if aScan(aParams,self:AcdParam) > 0
        //Traz o parametro do ACD
        oResponse[self:AcdParam] := SuperGetMV(self:AcdParam,.f.,'')          
        lRet := .T.
    EndIf
EndIf

if setError(lRet,,STR0008)//Parâmetro inválido ou não informado. 
    cResponse := FwJsonSerialize(oResponse)
    Self:SetResponse(cResponse) 
EndIf

FwFreeArray(aParams)
FreeObj(oResponse)


Return (lRet)

/*/{Protheus.doc} menudef
    Monta o menu para controle de privilegios de acesso do Aplicativo Mobile
    @type  Static Function
    @author rodrigo.lombardi
    @since 10/10/2025
    @version v1.0
/*/
static function menudef()
local aRotina := {} as array

ADD OPTION aRotina TITLE STR0002 ACTION "mcdConf" OPERATION 1 ACCESS 0  // "Conferencia"
ADD OPTION aRotina TITLE STR0003 ACTION "mcdSep"  OPERATION 2 ACCESS 0  // "Separacao"
ADD OPTION aRotina TITLE STR0004 ACTION "mcdInv"  OPERATION 3 ACCESS 0  // "Inventario"
ADD OPTION aRotina TITLE STR0005 ACTION "mcdEnd"  OPERATION 4 ACCESS 0  // "Enderecamento"
ADD OPTION aRotina TITLE STR0006 ACTION "mcdTran" OPERATION 5 ACCESS 0  // "Transferencia"

return(aRotina)


/*/{Protheus.doc} setError
    Controla o retorno de erro da API
    @type  Static Function
    @author Rodrigo Lombardi
    @since 23/10/2025
    @version v1.0
    @param lError, boolean, Recebe se houve algum erro no processamento
    @param nCode, numeric, Codigo de erro customizado
    @param cMessage, character, Mensagem de erro customizada
    @return lRet, boolean, Habilita se deve gerar o response ou erro
/*/
Static Function setError(lError,nCode,cMessage)
Local lRet := .t.
Default nCode := 400
Default cMessage := STR0001 //Erro interno

if !lError
    SetRestFault( nCode, EncodeUTF8(cMessage) )
    lRet := .f.
EndIf

Return lRet

