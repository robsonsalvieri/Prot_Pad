#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSTAF045.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TAFEsocialRemoveCompany
API e-Social - Remove dados do empregador do e-Social da base de dados do RET 

@author Melkz Siqueira
@since 13/12/2021
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSRESTFUL TAFEsocialRemoveCompany DESCRIPTION STR0001 FORMAT APPLICATION_JSON // "API e-Social - Remove dados do empregador do e-Social da base de dados do RET"

    WSMETHOD DELETE companyId;
        DESCRIPTION STR0002; // "Remove dados do empregador do e-Social da base de dados do RET"
        PATH "/api/rh/esocial/v1/TAFEsocialRemoveCompany/{companyId}";
        TTALK "v1";
 
END WSRESTFUL 

//------------------------------------------------------------------------------
/*/{Protheus.doc} DELETE
Método DELETE para remover os dados do empregador do e-Social da base de dados do RET

@param companyId - Empresa e Filial que fará a requisição no formato Empresa|Filial

@return lRet - Informa se a requisição foi realizada com sucesso

@author Melkz Siqueira
@since 13/12/2021
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSMETHOD DELETE companyId WSSERVICE TAFEsocialRemoveCompany

    Local cResponse     := ""
    Local lRet          := .T.
    Local oResponse     := JSONObject():New()

    ::SetContentType("application/json")

    If PrepEnvFil(::aURLParms, @cResponse) 
        
        If RemoveComp(@cResponse)

            oResponse["statusMessage"] := EncodeUTF8(cResponse)

            ::SetResponse(oResponse:toJSON())

        Else

            SetRestFault(400, EncodeUTF8(cResponse))

            lRet := .F.

        EndIf

    Else

        SetRestFault(400, EncodeUTF8(cResponse))
        
        lRet := .F.   

    Endif

    FWFreeObj(oResponse)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrepEnvFil
Prepara o ambiente de acordo com o parâmetro 'companyId'

@param aCompanyId - Array contendo Empresa e Filial que fará a requisição no formato Empresa|Filial
@param cResponse - Retorna a resposta da requisição por referência

@return lRet - Informa se a preparação do ambiente foi realizada com sucesso

@author Melkz Siqueira
@since 13/12/2021
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function PrepEnvFil(aCompanyId, cResponse)

    Local aCompany		:= {}
    Local lRet			:= .T.

    Default aCompanyId  := {}
    Default cResponse   := ""

    If !Empty(aCompanyId)

        aCompany := StrTokArr(aCompanyId[1], "|")

        If Len(aCompany) < 2

            cResponse   := STR0004 // "Empresa|Filial não informado no parâmetro 'companyId'."
            lRet        := .F.

        Else

            If !PrepEnv(aCompany[1], PadR(aCompany[2], FWSizeFilial()))

                cResponse   := STR0005 // "Falha na preparação do ambiente para o parâmetro 'companyId'."
                lRet        := .F.

            EndIf

        EndIf

    Else

        cResponse := STR0003 // "O parâmetro companyId é obrigatório."

        lRet := .F.   

    Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RemoveComp
Posiciona na filial Matriz e remove os dados do empregador do e-Social da base de dados do RET

@param cResponse - Retorna a resposta da requisição por referência

@return lRet - Informa se função de remoção dos dados do empregador do e-Social da 
base de dados do RET foi executada 

@author Melkz Siqueira
@since 13/12/2021
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function RemoveComp(cResponse)

    Local aArea         := SM0->(GetArea())
    Local aRetEvts      := {}   
    Local cFilBackUp    := cFilAnt
    Local cMsgErro      := ""
    Local lJob          := .T.
    Local lRet          := .T.

    Default cResponse   := ""

    If TAFChgFil(@cMsgErro)

        aRetEvts := TafTrmLimp(@cResponse, lJob)

        If !Empty(aRetEvts)

            TAFMErrT0X(aRetEvts, lJob)

        EndIf

    Else    

        cResponse   := cMsgErro
        lRet        := .F.
    
    EndIf

    RestArea(aArea)

	cFilAnt := cFilBackUp   

Return lRet
