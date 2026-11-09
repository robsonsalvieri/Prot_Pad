#include "totvs.ch"

/*/{Protheus.doc} RnkInsPost
Monta e processa a mensagem TenantInsight de ranking de vendedores.
@type class
@author Nilson Sacchi Junior
@since 03/09/2026
@version 1.0
/*/
Class RnkInsPost  From GravarRanking
    Data cTransId As Character
    Data cMsgId   As Character

    Method New() Constructor
    Method Gravar()
EndClass

/*/{Protheus.doc} RnkInsPost::New
Inicializa os identificadores da transacao e da mensagem.
@type method
@author Nilson Sacchi Junior
@since 03/09/2026
@return object, Instancia da classe
/*/
Method New() Class RnkInsPost
Return Self

/*/{Protheus.doc} RnkInsPost::Gravar
Configura e processa a mensagem TenantInsight.
@type method
@author Nilson Sacchi Junior
@since 03/09/2026
@param jDados, json, Payload do lynn
@return logical, Indica se a mensagem foi processada com sucesso
/*/
Method Gravar(jDados) Class RnkInsPost
    Local lRet       As Logical
    Local oLinkMsg   As Object
    Local oTenantRd  As Object

    PinsSaveConfig() //Não pode ficar aqui, precisa ficar na chama da tela, é acionado apenas uma vez

    oLinkMsg  := FwTotvsLinkMessage():New(jDados)
    oTenantRd := TenantInsightMessageReader():New()
    lRet      := oTenantRd:Read(oLinkMsg)
Return lRet

