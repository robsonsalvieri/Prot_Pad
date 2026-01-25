#include 'protheus.ch'
#include 'fwmvcdef.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCompanyStartup
Classe responsável pela criação de empresa/filial no startup do 
 TAF Cloud

Baseada na especificação http://tdn.totvs.com/display/TAF/Web+Service+REST+-+TAFSETUP

@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
CLASS TAFCompanyStartup FROM LongNameClass
    DATA aResult
    METHOD New()
    METHOD CreateCompanies()
    METHOD GetBranchFromJSON()
    METHOD GetCompanyFromJSON()
    METHOD ExcludeCompanies()

    METHOD GetResult()
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor

@since   13/04/2018
/*/
//-------------------------------------------------------------------
METHOD New() CLASS TAFCompanyStartup
    self:aResult := {}
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCompanyFromJSON
Retorna o modelo de empresa para inclusão baseado no objeto JSON (JsonObject)

@param oCompany Objeto do Tipo JsonObject
@return oModel Modelo de dados de Empresa

@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
METHOD GetCompanyFromJSON(oCompany) CLASS TAFCompanyStartup
Local nProperty AS NUMERIC
Local oModel AS OBJECT
Local oModelXX8 AS OBJECT
Local cField AS CHARACTER

oModel := FWLoadModel('apcfg210')

If FWXX8SeekFil('01',oCompany['CODEMPRESA'],oCompany['CODFILIAL'])
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()
    oModelXX8 := oModel:GetModel("SIGAMAT_XX8")
Else
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
    oModelXX8 := oModel:GetModel("SIGAMAT_XX8")
    oModelXX8:SetValue("XX8_GRPEMP",oCompany['XX8_GRPEMP'])
    oModelXX8:SetValue("XX8_CODIGO",oCompany['CODEMPRESA'])        
EndIf

oModelXX8:SetValue("XX8_DESCRI",oCompany['M0_NOME'])

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBranchFromJSON
Retorna o modelo de filial para inclusão baseado no objeto JSON (JsonObject)

@param oCompany Objeto do Tipo JsonObject
@return oModel Modelo de dados de Filial

@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
METHOD GetBranchFromJSON(oCompany) CLASS TAFCompanyStartup
Local nProperty AS NUMERIC
Local oModel AS OBJECT
Local oModelSM0 AS OBJECT
Local oModelXX8 AS OBJECT
Local cField AS CHARACTER
Local lUpdMode AS LOGICAL

lUpdMode := FWXX8SeekFil('01',oCompany['CODEMPRESA'],oCompany['CODFILIAL'])

oModel := FWLoadModel('apcfg230')

If lUpdMode
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
Else
    oModel:SetOperation(MODEL_OPERATION_INSERT)
EndIf

oModel:Activate()

If !lUpdMode
    oModelXX8 := oModel:GetModel("SIGAMAT_XX8")

    oModelXX8:SetValue("XX8_GRPEMP", '01')
    oModelXX8:SetValue("XX8_EMPR"  , oCompany['CODEMPRESA'])
    oModelXX8:SetValue("XX8_CODIGO", oCompany['CODFILIAL'])
    oModelXX8:SetValue("XX8_DESCRI", oCompany['M0_FILIAL'])
EndIf

oModelSM0 := oModel:GetModel("SIGAMAT_SM0")

aProperties := oCompany:GetProperties()

If aScan(aProperties, "M0_TPINSC") > 0
    oModelSM0:SetValue("M0_TPINSC", oCompany["M0_TPINSC"])
EndIf

For nProperty := 1 To Len(aProperties)

    cField := aProperties[nProperty]

    If("M0_" $ cField) .AND. !Empty(oCompany[cField]) .AND. !(cField == "M0_TPINSC")
        oModelSM0:SetValue(cField, oCompany[cField])
    // ElseIf("XX8_" $ cField) .AND. !Empty(oCompany[cField])
    //    oModelXX8:SetValue(cField, oCompany[cField])
    EndIf
Next

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateCompanies
Método principal para criação das empresas e filiais

@param aCompanies Array de objetos Json com empresas (JsonObject)

@since   13/04/2018
/*/
//-------------------------------------------------------------------
Method CreateCompanies( aCompanies ) CLASS TAFCompanyStartup
Local aProperties AS ARRAY
Local oCompany AS OBJECT
Local oBranch AS OBJECT
Local lAnyFailed AS LOGICAL
Local cError AS CHARACTER
Local lCreateBranch AS LOGICAL

lAnyFailed := .F.
lCreateBranch := .F.

If !FWXX8SeekFil('01',aCompanies['CODEMPRESA'],aCompanies['CODFILIAL'])
    aCompanies['XX8_GRPEMP'] := '01'
EndIf

cError := ValidCompanies(aCompanies)

If Empty(cError)
    // tratativa para preenchimento do nome da filial caso não seja informado.
    If Empty(aCompanies['M0_FILIAL']) .And. !Empty(aCompanies['M0_NOME'])
        aCompanies['M0_FILIAL'] := aCompanies['M0_NOME']
    Endif
    If Empty(aCompanies['M0_NOMECOM']) .And. !Empty(aCompanies['M0_NOME'])
        aCompanies['M0_NOMECOM'] := aCompanies['M0_NOME']
    Endif

    oCompany := self:GetCompanyFromJSON(aCompanies)

    If oCompany:VldData() .AND. oCompany:CommitData()
        lCreateBranch := .T.
    Else
        cError := oCompany:GetErrorMessage()[MODEL_MSGERR_MESSAGE]

        If ("REGISTRO COM ESTA INFORMA" $ Upper(alltrim(NoAcento(cError))))
            lCreateBranch := .T.
            cError:= ""
        EndIf
    EndIf

    oCompany:DeActivate() 
    FreeObj(oCompany)

    If lCreateBranch
        oBranch  := self:GetBranchFromJSON(aCompanies)

        If  !(oBranch:VldData() .AND. oBranch:CommitData())
            cError := "Branch:" + oBranch:GetErrorMessage()[MODEL_MSGERR_MESSAGE]
        EndIf

        oBranch:DeActivate() 
        FreeObj(oBranch)
    EndIf
EndIf

If Empty(cError)
    aAdd(self:aResult,{"OK",""})
Else
    aAdd(self:aResult,{"NOK",cError})
    Conout(FWTimeStamp(3) + "   - [TAFCompanyStartup|CreateCompanies] - Empresa: [" + aCompanies['CODEMPRESA'] + "] Filial: [" + aCompanies['CODFILIAL'] + "] | Erro: " + cError )	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetResult
Retorna o resultado do método CreateCompanies

@param aResult Array com padrão definido de resultado das inclusões

@since   13/04/2018
/*/
//-------------------------------------------------------------------
METHOD GetResult() CLASS TAFCompanyStartup

Return self:aResult
//-------------------------------------------------------------------
/*/{Protheus.doc} ExcludeCompanies
Excluí uma empresa e filial indicada

@param aCompany Código das Filiais a serem excluída

@since   18/05/2018
/*/
//-------------------------------------------------------------------
METHOD ExcludeCompanies( aCompanies ) CLASS TAFCompanyStartup
Local oModel AS OBJECT
Local cError AS CHARACTER
    
oModel := FWLoadModel('apcfg230')

If aCompanies['excluir']
    If FWXX8SeekFil('01',aCompanies['CODEMPRESA'],aCompanies['CODFILIAL'])
        oModel:SetOperation(MODEL_OPERATION_DELETE)
        oModel:Activate()

        If  !(oModel:VldData() .AND. oModel:CommitData())
            cError := oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE]
        EndIf
    EndIf

    If Empty(cError)
        aAdd(self:aResult,{"OK",""})
    Else
        aAdd(self:aResult,{"NOK",cError})
        Conout(FWTimeStamp(3) + "   - [TAFCompanyStartup|ExcludeCompanies] - " + cError )	
    EndIf
EndIf

oModel:DeActivate() 
FreeObj(oModel)

Return cError

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCompanies
Realiza a validação primaria dos dados enviadas pelo Json dos ERPs

@param aCompany Empresas enviadas pelo Json

@since   17/08/2018
/*/
//-------------------------------------------------------------------
Static Function ValidCompanies(aCompany)
Local cMsg   := ""


If Empty(aCompany['CODEMPRESA'])
    cMsg += "Nao foi informado o codigo da empresa." + CRLF
Endif

If Empty(aCompany['CODFILIAL'])
    cMsg += "Nao foi informado o codigo da filial." + CRLF
Endif

If Empty(aCompany['M0_NOME'])
    cMsg += "Nao foi informado o nome da empresa." + CRLF
EndIf

If Empty(aCompany['M0_CGC'])
    cMsg += "Nao foi informado o CNPJ/CPF da empresa." + CRLF
EndIf

If !Empty(cMsg)
    cMsg += "Empresa informada nao sera importada para dentro do SMART." + CRLF + CRLF 
    cMsg += "Verifique dentro do ERP se a informacao supracitada esta cadastrada, realize o ajuste e tente novamente realizar a contratação."
Endif

Return cMsg

// Dummy
Function __TAFCompany()
Return
