#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'

/*-------------------------------------------------------------------
{Protheus.doc} MATA020EVTAF
Classe responsável pelo evento das regras de negócio do cadastro de 
participantes do TAF (Fornecedor)
 
@author Carlos Eduardo Boy
@since  06/12/2024
-------------------------------------------------------------------*/
Class Mata020EvTaf From FwModelEvent 
	
public method new() 

//Bloco com regras de negócio antes transação do modelo de dados.
private method beforeTts()	

EndClass

/*-------------------------------------------------------------------
{Protheus.doc} New
Metodo responsável pela construção da classe.

@author Carlos Eduardo Boy
@since  06/12/2024
-------------------------------------------------------------------*/
Method new() Class Mata020EvTaf
Return self


/*--------------------------------------------------------------
{Protheus.doc} BeforeTTS
Método responsável por executar regras de negócio genéricas do 
cadastro antes da transação do modelo de dados.

@author Carlos Eduardo Boy
@since  06/12/2024

---------------------------------------------------------------*/
Method beforeTts(oModel,cID) Class Mata020EvTaf
Local nOperation := oModel:GetOperation() as integer
Local oModelSA2  := oModel:GetModel('SA2MASTER') as object
Local oModelDKE  := oModel:GetModel('SA2DKE') as object
Local lIntTAF     := .F.                            as logical
Local xMV_TAFISCH :=  GetMV('MV_TAFISCH',, '0' )              //Integracao via Smart Schedule com o TAF 		

//Valida tipo e conteudo do parâmetro MV_TAFISCH
do case
	case ValType( xMV_TAFISCH ) == 'C'
		lIntTAF := iif( xMV_TAFISCH == '1', .t., .f. )
	case ValType( xMV_TAFISCH ) == 'L'
		lIntTAF := .F.
endcase

//Só integra com o TAF caso a operação seja alteração
if nOperation = MODEL_OPERATION_UPDATE .and. lIntTAF
    TafIntegUpdPart('SA2' ,oModelSA2, oModelDKE)
endif    

return self
