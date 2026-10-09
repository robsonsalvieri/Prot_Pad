#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECNPS

Serviços utilizados pelo NPS

@author     Augusto Albuquerque
@since      15/12/2021
/*/
//------------------------------------------------------------------------------
WSRESTFUL TECNPS  DESCRIPTION "NPS"

    WSDATA nGrade       AS INTEGER
    WSDATA cComment     AS STRING
    WSDATA nAction     	AS INTEGER
    WSDATA lSendEmail   AS BOOLEAN 
    WSDATA cProduct     AS STRING

    WSMETHOD GET gradeclass	      DESCRIPTION 'Nota de NPS'            PATH "gradeclass"	        PRODUCES APPLICATION_JSON 

END WSRESTFUL

//------------------------------------------------------------------------------
/*/{Protheus.doc} gradeclass

@description Realiza a gravação do nps
@author   Augusto Albuquerque
@since    15/12/2021
/*/
//------------------------------------------------------------------------------
WSMETHOD GET gradeclass WSRECEIVE nGrade, cComment, nAction, lSendEmail, cProduct  WSREST TECNPS
Local cTypeEnv          := totvs.framework.environment.type.get() //1-Produção 2-Homologação 3-Desenvolvimento
Local cResponse         := ""
Local cComentario       := Self:cComment
Local cProduto          := Self:cProduct
Local nOpc              := Self:nAction
Local nNota             := Self:nGrade
Local lEmail            := Self:lSendEmail
Local lTeste            := cProduto == "PrestServTerc" .AND. cTypeEnv <> "1"
Local oGsNps            := GsNps():New()

oGsNps:setRating(nNota)
oGsNps:setShareEmail(lEmail)
oGsNps:setShareName(lEmail)
oGsNps:setComment(cComentario)

/*
Caso for realizar algum teste no envio de NPS por favor comentar a linha: oGsNps:setProductName("PrestServTerc") e descomentar a linha oGsNps:setProductName("Tercerização")
*/
//oGsNps:setProductName("PrestServTerc") //Envio do cliente
oGsNps:setProductName(cProduto) //Envio do cliente
If !lTeste
    oGsNps:sendAnswer(nOpc)
EndIf
cResponse := '{"total": "'+cValToChar(10)+'" }'
Self:SetResponse( EncodeUTF8(cResponse) )

Return .T.
