#Include 'PROTHEUS.CH'
#Include 'SCHEDGCPPCP.ch'

/*/{Protheus.doc} SCHEDGCPPCP
    (Responsável por consultar edital/processo e atualizar a DKF e DKG )
    @type  Static Function
    @author Thiago Rodrigues
    @since 28/03/2024
/*/
Function SCHEDGCPPCP(aParam)
local oApiPCP := nil 

FWLogMsg('INFO',, 'SIGAGCP', funName(), '', '01', STR0001 , 0, 0, {}) //"Execução da atualização de status GCP x PCP."

oApiPCP := GCPApiPCP():New()
oApiPCP:GetListaProcessos() //Chamada do lista e obter processos

FWLogMsg('INFO',, 'SIGAGCP', funName(), '', '01', STR0002, 0, 0, {}) //"Execução do job SCHEDGCPPCP finalizada."

Return


/*/{Protheus.doc} Scheddef
    (Retorna as perguntas definidas no schedule.)
    @author Thiago Rodrigues
    @since 19/06/2024
    @version version
/*/

Static Function Scheddef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "",;	//Pergunte do relatorio, caso nao use passar ParamDef
            ,;			//Alias
            ,;			//Array de ordens
            }				//Titulo

Return aParam
