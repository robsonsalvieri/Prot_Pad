#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TenantInsight
Exemplo de classe de processamento de mensagens
(esta classe deve ser mantida em um .prw pois o smartlink não reconhece TLPP)

@type Class
@author Renan Fragoso
/*/
Class TenantInsightMessageReader from LongNameClass
 
    method New()
    method Read()
 
EndClass
 
/*/{Protheus.doc} New
Metodo Contrutor

@type Method
@author Renan Fragoso
/*/
method New() Class TenantInsightMessageReader
return Self
 
/*/{Protheus.doc} Read
Handler de leitura e processamento da mensagem do tipo InsightModel chamado pelo Smartlink

@type Method
@author Renan Fragoso

@param oLinkMessage, Object, Instância de FwTotvsLinkMesage da mensagem
@return Logical, sucesso ou falha. Determina se deve ou não retirar a mensagem da fila.
/*/
Method Read(oLinkMessage) Class TenantInsightMessageReader
    
    Local oInsightsConsumer

    oInsightsConsumer := totvs.protheus.backoffice.ba.insights.InsightMessageConsumer():New()
    
    ConOut("TenantInsight started consuming message ...")
    
    oInsightsConsumer:Read(oLinkMessage)

    ConOut("TenantInsight finished consuming message.")

Return .T.
