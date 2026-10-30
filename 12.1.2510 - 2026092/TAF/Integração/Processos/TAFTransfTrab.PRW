#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} TafTransfTrab
Classe para gerenciamento do processo de transferência de funcionários
celetistas e TSV utilizando a integração online. 

@type class
@author Evandro dos Santos O. Teixeira
@since 24/04/2021
@version 1.0
/*/
Class TafTransfTrab

    Data oJson           
    Data aInterface 

    Method New() Constructor

    Method setErrorTransfer(lError,cErrorCode,cErrorDescription)
    Method setTransferGroup(lTransferGroup)
    Method setSameBaseCNPJ(lSameBaseCNPJ)
    Method setOriginKey(cOriginKey)
    Method setDestinyKey(cDestinyKey)
    Method setErrorCode(cErrorCode)
    Method setErrorDescription(cErrorDescription)
    Method setReceipt(cReceipt)
    Method setStatus(cStatus)
    Method setIndKey(nIndKey)
    Method setOrigBranch(cOriginBranch) 
    Method setDestBranch(cDestinyBranch)
    Method setOrigGroup(cOriginGroup) 
    Method setDestGroup(cDestinyGroup)

    Method thereIsError()
    Method isTransferGroup()
    Method isSameBaseCNPJ()
    Method getOriginKey()
    Method getDestinyKey()
    Method getErrorCode()
    Method getErrorDescription()
    Method getReceipt()
    Method getStatus()
    Method getIndKey()
    Method getOrigBranch() 
    Method getDestBranch()
    Method getOrigGroup() 
    Method getDestGroup()
    Method getJson()

EndClass

/*/{Protheus.doc} New
Metodo Construtor

@param - cJsonTransf (opcional) - String Json com chaves e valores
correspondentes a Classe. 
Esse parâmetro é util quando há necessidade de enviar o objeto para outra thread,
desta forma é possível gerar um Json da classe através do método getJson() e realizar
a passagem de parâmetro para o StarJob/ManualJob etc .. Então na nova thread você
instancia novamente a classe passando o Json no método construtor. 
Obs: Não é possível passar um objeto por parâmetro para outra thread.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/04/2021
@version 1.0
/*/
Method New(cJsonTransf) Class TafTransfTrab

    Local nX := 0
    Local cKey := ""
    Local cValue := ""	

    Default cJsonTransf := ""

    ::oJson := JsonObject():new()
    ::aInterface := {}

    If Empty(cJsonTransf)

        //Queria ter criado uma Interface utilizando tlpp para garantir os atributos da classe, porém os 
        //clientes protheus GPE podem estar em garantia extendida e utilizando binários incompatíveis
        //Estou utilizando um objeto Json no lugar dos atributos por que não é possível passar um objeto   
        //como parâmetro para outra Thread, utilizando um objeto Json encapsulado consigo fazer o Deserialize  
        //e enviar uma String Json como parâemtro. 
        aAdd(::aInterface,{'lError',.F.})
        aAdd(::aInterface,{'lTransferGroup',.F.})
        aAdd(::aInterface,{'lSameBaseCNPJ',.F.})
        aAdd(::aInterface,{'cOriginKey',""})
        aAdd(::aInterface,{'cDestinyKey',""})
        aAdd(::aInterface,{'cErrorCode',""})
        aAdd(::aInterface,{'cErrorDescription',""})
        aAdd(::aInterface,{'cReceipt',""})
        aAdd(::aInterface,{'cStatus',""})
        aAdd(::aInterface,{'cOriginBranch',""})
        aAdd(::aInterface,{'cDestinyBranch',""})
        aAdd(::aInterface,{'cOriginGroup',""})
        aAdd(::aInterface,{'cDestinyGroup',""})
        aAdd(::aInterface,{'nIndKey',0})

        For nX := 1 To Len(::aInterface)
            cKey := ::aInterface[nX][1]
            cValue := ::aInterface[nX][2]
            ::oJson[&('cKey')] := cValue 
        Next nX
    Else 
        ::oJson:FromJSON(cJsonTransf)
    EndIf 

Return Nil   

/*/{Protheus.doc} setErrorTransfer
O objetivo deste método é informar que houve erro em alguma etapa do processo 
de transferência.

@param lError (obrigatório) - Informa se houve erro (.T. - Sim, .F. - não)
@param cErrorCode - Código do Erro conforme definições do processo de integração 
TAF eSocial 
@param cErrorDescription - Descrição do Erro  

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/04/2021
@version 1.0
/*/
Method setErrorTransfer(lError,cErrorCode,cErrorDescription) Class TafTransfTrab 

    Default cErrorCode := ""
    Default cErrorDescription := ""

    ::oJson['lError'] := lError
    ::oJson['cErrorCode'] := cErrorCode
    ::oJson['cErrorDescription'] := cErrorDescription 
Return Nil  

//Todos os métodos abaixo são Setters e Getters

Method setTransferGroup(lTransferGroup) Class TafTransfTrab
    ::oJson['lTransferGroup'] := lTransferGroup 
Return Nil 

Method setSameBaseCNPJ(lSameBaseCNPJ) Class TafTransfTrab
    ::oJson['lSameBaseCNPJ'] := lSameBaseCNPJ 
Return Nil 

Method setOriginKey(cOriginKey) Class TafTransfTrab
    ::oJson['cOriginKey'] := cOriginKey
Return Nil 

Method setDestinyKey(cDestinyKey ) Class TafTransfTrab
    ::oJson['cDestinyKey'] := cDestinyKey 
Return Nil 

Method setErrorCode(cErrorCode) Class TafTransfTrab
    ::oJson['cErrorCode'] := cErrorCode
Return Nil 

Method setErrorDescription(cErrorDescription) Class TafTransfTrab
    ::oJson['cErrorDescription'] := cErrorDescription 
Return Nil 

Method setReceipt (cReceipt) Class TafTransfTrab
    ::oJson['cReceipt'] := cReceipt 
Return Nil 

Method setStatus (cStatus) Class TafTransfTrab
    ::oJson['cStatus'] := cStatus 
Return Nil 

Method setIndKey (nIndKey) Class TafTransfTrab
    ::oJson['nIndKey'] := nIndKey 
Return Nil 

Method setOrigBranch(cOriginBranch) Class TafTransfTrab
    ::oJson['cOriginBranch'] := cOriginBranch 
Return Nil 

Method setDestBranch(cDestinyBranch) Class TafTransfTrab
    ::oJson['cDestinyBranch'] := cDestinyBranch 
Return Nil 

Method setOrigGroup(cOriginGroup) Class TafTransfTrab
    ::oJson['cOriginGroup'] := cOriginGroup 
Return Nil 

Method setDestGroup(cDestinyGroup) Class TafTransfTrab
    ::oJson['cDestinyGroup'] := cDestinyGroup 
Return Nil 

Method thereIsError() Class TafTransfTrab 
Return ::oJson:GetJsonObject('lError')

Method isTransferGroup() Class TafTransfTrab 
Return ::oJson:GetJsonObject('lTransferGroup') 

Method isSameBaseCNPJ() Class TafTransfTrab 
Return ::oJson:GetJsonObject('lSameBaseCNPJ')

Method getOriginKey() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cOriginKey')  

Method getDestinyKey() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cDestinyKey')  

Method getErrorCode() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cErrorCode')  

Method getErrorDescription() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cErrorDescription')   

Method getReceipt() Class TafTransfTrab
Return ::oJson:GetJsonObject('cReceipt')   

Method getStatus() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cStatus')   

Method getIndKey() Class TafTransfTrab 
Return ::oJson:GetJsonObject('nIndKey')    

Method getOrigBranch() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cOriginBranch')  

Method getDestBranch() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cDestinyBranch')  

Method getOrigGroup() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cOriginGroup')  

Method getDestGroup() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cDestinyGroup')  

Method getJson() Class TafTransfTrab
Return ::oJson:toJSON() 
