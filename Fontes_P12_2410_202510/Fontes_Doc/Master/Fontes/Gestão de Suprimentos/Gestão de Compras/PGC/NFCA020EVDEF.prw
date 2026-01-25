#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} NFCA020EVDEF
    Eventos padrões da rotina de cotações
    Documentação sobre eventos do MVC: https://tdn.totvs.com/x/pgoRE
@author juan.felipe
@since 02/02/2023
/*/
CLASS NFCA020EVDEF FROM FWModelEvent
	Method New() CONSTRUCTOR
    Method ModelPosVld()
    Method BeforeTTS()
    Method InTTS()
    Method AfterTTS()
ENDCLASS


/*/{Protheus.doc} New
Construtor da classe.

@author juan.felipe
@since 02/02/2023
@version 1.0
 
/*/
Method New() CLASS NFCA020EVDEF
Return Self

/*/{Protheus.doc} ModelPosVld
    Metodo executado uma vez no contexto de validação do modelo principal.
@author juan.felipe
@since 04/01/2021
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method ModelPosVld(oModel, cModelId) CLASS NFCA020EVDEF
Return .T.

/*/{Protheus.doc} BeforeTTS
    Metodo executado uma vez no contexto de gravação do modelo principal e antes da transação.
@author juan.felipe
@since 02/02/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method BeforeTTS(oModel) CLASS NFCA020EVDEF
Return Nil

/*/{Protheus.doc} InTTS
    Metodo executado uma vez no contexto de gravação do modelo principal e durante a transação.
@author juan.felipe
@since 02/02/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method InTTS(oModel) CLASS NFCA020EVDEF
    Local oModelDHU As Object
    Default oModel := FwModelActive()

    oModelDHU := oModel:GetModel('DHUMASTER')

    If oModel <> Nil .And. oModel:IsActive() .And. oModel:GetId() == 'NFCA020'
        setQuoteStatus(oModelDHU:GetValue('DHU_NUM')) //-- Atualiza status da cotação
    EndIf
Return Nil

/*/{Protheus.doc} AfterTTS
    Metodo executado uma vez no contexto de gravação do modelo principal e após a transação.
@author juan.felipe
@since 02/02/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method AfterTTS(oModel) Class NFCA020EVDEF
Return Nil


