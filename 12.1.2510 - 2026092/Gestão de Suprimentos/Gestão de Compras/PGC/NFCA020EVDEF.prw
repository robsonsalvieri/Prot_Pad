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
    Method GridLinePreVld()
    Method GridLinePosVld()
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


/*/{Protheus.doc} GridLinePreVld
	Bloco de pre-validação do grid
@author Mateus Ribeiro - Manutenção Prime
@since 05/2026
/*/

Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class NFCA020EVDEF
	Local aRefImpos	:= {}	as Array 

	Local cField 	:= ""	as Character
	Local cFornece 	:= "" 	as Character
	Local cLojaFor 	:= ""	as Character

	Local nI 		:= 0	as Numeric
	Local lRet 		:= .T.	as Logical 
    Local oModel    := Nil
	Local oModelSC8 := Nil	as Object
	Local oModelDHU := Nil  as Object


    If cModelId == 'SC8DETAIL' .And. cAction $ 'CANSETVALUE|SETVALUE' .And. cId == 'C8_TES'
        oModel    := oSubModel:GetModel()
        oModelSC8 := oModel:GetModel('SC8DETAIL')
        oModelDHU := oModel:GetModel('DHUMASTER')

        cField 	  := Strtran(ReadVar(),"M->","")
        cFornece  := oModelDHU:GetValue("DHU_CODFOR")
        cLojaFor  := oModelDHU:GetValue("DHU_LOJAFOR")

        MaFisEnd()

        If !MaFisFound("NF")
            aRefImpos	:= MaFisRelImp('MT100',{"SC8"})

            MaFisIni( cFornece, cLojaFor, "F", "N", Nil, aRefImpos, , .T.)

            For nI := 1 To oModelSC8:Length()
                MaFisIniLoad(nI)
            Next nI 
        EndIf
    EndIf

	FwFreeArray(aRefImpos)
Return lRet

/*/{Protheus.doc} GridLinePreVld
	Bloco de POS-validação do grid
@author juan.felipe
@since 05/2026
/*/

Method GridLinePosVld(oSubModel, cModelID, nLine) Class NFCA020EVDEF
    Local lRet := .T. as Logical
    Default oSubModel := Nil
    Default cModelID := ""
    Default nLine   := 0

    If cModelId == 'SC8DETAIL' .And. MaFisFound("NF") .And. !FwIsInCallStack("NF020Calc")
        MaFisEnd()
    EndIf
Return lRet
