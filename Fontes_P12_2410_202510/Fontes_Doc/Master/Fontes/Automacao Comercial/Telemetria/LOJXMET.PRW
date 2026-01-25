#INCLUDE "TOTVS.CH"
#INCLUDE 'FWLIBVERSION.CH' 

Static __lMetric := FWLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6" //Verifica se está atualizado para utilização do componente de Metrica

//----------------------------------------------------------------------------
/*/{Protheus.doc} LojxMetric
Função para registro de Métricas.

@type    function
@author  Alberto Deviciente
@since   04/10/2022
@version P12

@param cType        , Caractere , Tipo de Métrica.              [Obrigatório]
@param cSubRoutine  , Caractere , Nome da Sub-Rotina.           [Obrigatório]
@param cIdMetric    , Caractere , ID da Métrica                 [Obrigatório]
@param uValue       , Indefinido, Valor coletado na métrica.    [Obrigatório]
@param dDateSend    , Data      , Data em que a Telemetria deve ser sincronizada.
@param nLapTime     , Numérico  , Tempo de uso (em segundos).
@param cRotina      , Caractere , Nome da Rotina.

@return Nil, Nulo
/*/
//----------------------------------------------------------------------------
Function LojxMetric(cType, cSubRoutine, cIdMetric, uValue, dDateSend, nLapTime, cRotina)

Default dDateSend   := Nil
Default nLapTime    := Nil
Default cRotina     := Nil

If Empty(cSubRoutine)
    cSubRoutine := "UNDEFINED" //Atribui como "INDEFINIDA" caso não seja passada ou seja em branco, pois é um conteúdo obrigatorio
EndIf

//Foi adicionado "false" (.F.) aqui para desabiliar a geração de métricas a pedido da alta gestão. Quando for redefinido o ajuste das métricas, voltaremos a habilitar a geração novamente
If .F. //__lMetric

    Do Case
        Case cType == "SUM"

            //Método responsável por registrar a métrica de SOMA. 
            FWCustomMetrics():setSumMetric(     cSubRoutine     ,;  //SubRotina Utilizada
                                                cIdMetric       ,;  //ID da Métrica
                                                uValue          ,;  //Valor da métrica (Numérico)
                                                dDateSend       ,;  //Data que a telemetria deve ser sincronizada
                                                nLapTime        ,;  //Tempo de uso, em segundos
                                                cRotina         )   //Sobrescreve a rotina que está definindo a métrica

        Case cType == "UNQ"

            //Método responsável por registrar a métrica uma ÚNICA vez, somente se esta não existir (independente do valor).
            FWCustomMetrics():setUniqueMetric(  cSubRoutine     ,;  //SubRotina Utilizada
                                                cIdMetric       ,;  //ID da Métrica
                                                uValue          ,;  //Valor da métrica (Caractere)
                                                dDateSend       ,;  //Data que a telemetria deve ser sincronizada
                                                nLapTime        ,;  //Tempo de uso, em segundos
                                                cRotina         )   //Sobrescreve a rotina que está definindo a métrica
        /*
        Case cType == "AVG"
        
            //Método responsável por registrar a métrica de MÉDIA.
            FWCustomMetrics():setAverageMetric( cSubRoutine     ,;  //SubRotina Utilizada
                                                cIdMetric       ,;  //ID da Métrica
                                                uValue          ,;  //Valor da métrica (Numérico)
                                                dDateSend       ,;  //Data que a telemetria deve ser sincronizada
                                                nLapTime        ,;  //Tempo de uso, em segundos
                                                cRotina         )   //Sobrescreve a rotina que está definindo a métrica
        */
    EndCase

EndIf

Return
