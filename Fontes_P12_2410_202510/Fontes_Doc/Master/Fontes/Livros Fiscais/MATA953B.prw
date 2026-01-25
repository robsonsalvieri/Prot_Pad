#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} MATA953B
	(Rotina para chamar o MATA953 através do schedule)
	@author rhuan.carvalho
	@since 08/08/2024
	@version version
	@param none
	@return none
/*/
Function MATA953B()
    Local cRotina := "apuraLote"
    MATA953(.T.,,,cRotina)

return


/*/{Protheus.doc} Scheddef
	(Retorna as perguntas parametrizadas no schedule)
	@type  Static Function
	@author rhuan.carvalho
	@since 08/08/2024
	@version version
	@param none
	@return aParam, array, array contendo pregunte referenciado na SX1
/*/
Static Function Scheddef()
	Local aParam := {}

	aParam := { "P",;       //Tipo R para relatorio P para processo
			"MTA951",;      //Pergunte do relatorio, caso nao use passar ParamDef
			,;              //Alias
			,;              //Array de ordens
			}               //Titulo

Return aParam


























/*
// apura o ICMS em lote gravando resultado individualizado
// para cada filial
Function MATA953B()
    local cPerg := "MTA951" // pergunte usado na MATA953
    //local aCodigosFiliais := escolhaFiliais() // abro tela de escolha de filiais apra processamento
    local nI
    local cFilBack := cFilAnt // guardo a filial corrente
    local aAreaSM0 := SM0->(GetArea()) // guardo a área da SM0
    local cRotina := "apuraLote"


    conout("Realizando apuração da filial: " + cFilAnt)    
    
    //Pergunte(cPerg, .F.) //Pergunte da MATA953. Essa configuração será usada em todas as filiais

    // efetuo loop executando a MATA953 para cada filial
    //for nI := 1 to Len(aCodigosFiliais)
        // altero a filial corrente em tempo de execução
     //   alteraFilial(aCodigosFiliais[nI])
        // rodo a MATA953 com lAutomato True.
        // a rotina foi preparada para ser executada dessa forma pois o lAutomato
        // era utilizado para rodar a MATA953 para casos de teste.
    MATA953(.T.,,,cRotina)

    conout("Realizada apuração: " + cFilAnt)
   // next nI
    // volto para a filial logada
    //alteraFilial(cFilBack)
    //RestArea(aAreaSM0)
return


// habilita a tela de escolhas de filiais
// e devolve um array com os códigos das filiais escolhidas
function escolhaFiliais()
    local aLisFil := MatFilCalc(.T.)
    local aFiliais := {}
    local nI

    // Separo os códigos das filiais escolhidas pelo usuário
    for nI := 1 to len(aLisFil)
        if aLisFil[nI][1]
            aadd(aFiliais, aLisFil[nI][2])
        endif
    next nX
// retorno um array com os códigos das filiais
return aFiliais


// Altera o posicionamento da SM0
// esse método não é o mais indicado
// verificar se há funções do frame
// para obter o mesmo resultado
function alteraFilial(cCodFilial)

    SM0->(dbSetOrder(1))
    if SM0->(MsSeek(cEmpAnt+cCodFilial))
        cFilAnt := cCodFilial
    endif

return

*/
