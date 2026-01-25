#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU20D01RUS.CH"
#INCLUDE "INKEY.CH"


#DEFINE EXPERIENCE_CODES "01|02|03"

/*/{Protheus.doc} RU20D01Event()
    Class of events for routine RU20D01RUS.

    @type Class
    @author iprokhorenko
    @since 2024/02/12
    @version 12.1.2310
*/
Class RU20D01Event From FWModelEvent

    Method New() Constructor
    Method Activate(oSubModel, lCopy)
    Method BeforeTTS(oModel, cModelId)
    Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xNewValue, xCurrentValue)

Endclass

/*/{Protheus.doc} New()
    Creates a new class element.

    @type Method
    @author iprokhorenko
    @since 2024/02/12
    @version 12.1.2310
*/
Method New() Class RU20D01Event
Return





/*/{Protheus.doc} Activate(oSubModel, cModelID)
    Interception of grid post-validation check.

    @type Method
    @author iprokhorenko
    @since 2024/02/12
    @version 12.1.2310
*/
Method Activate(oSubModel, lCopy) Class RU20D01Event
 
    Local oStrF6KMas
    Local oStrF6IGrd

    Local nOperation as Numeric

    nOperation := oSubModel:GetOperation() 

    oStrF6KMas := oSubModel:GetModel("MASTER_F6I")
    oStrF6IGrd := oSubModel:GetModel("GRID_F6I")

    If nOperation != MODEL_OPERATION_INSERT .And. nOperation != MODEL_OPERATION_DELETE
        oStrF6KMas:LoadValue( "NTABLE", F6I->F6I_CODIGO)
        oStrF6KMas:LoadValue( "DTABLE", F6I->F6I_DESC)
    EndIf

Return 


/*/{Protheus.doc} BeforeTTS(oModel, cModelId)
    Interception of grid post-validation check.

    @type Method
    @author iprokhorenko
    @since 2024/05/02
    @version 12.1.2310
*/
Method BeforeTTS(oModel, cModelId) Class RU20D01Event
    Local nI As Numeric
    Local nJ As Numeric

    Local oStrF6KMas As Object
    Local oStrF6IGrd As Object

    Local nOperation as Numeric

    nOperation := oModel:GetOperation() 

    oStrF6KMas := oModel:GetModel("MASTER_F6I")
    oStrF6IGrd := oModel:GetModel("GRID_F6I")

    cTabNum := oStrF6KMas:GetValue("NTABLE") 
    cTabDesc := oStrF6KMas:GetValue("DTABLE") 

    iF nOperation != MODEL_OPERATION_DELETE
        For nI := 1 To oStrF6IGrd:Length()
            oStrF6IGrd:GoLine(nI)
            If Empty(oStrF6IGrd:GetValue("F6I_CODIGO"))
                oStrF6IGrd:LoadValue( "F6I_CODIGO", cTabNum)
                oStrF6IGrd:LoadValue( "F6I_PROCES", "005")
                oStrF6IGrd:LoadValue( "F6I_MODULO", "3")
                oStrF6IGrd:LoadValue( "F6I_FILIAL", xFilial("F6I"))
                oStrF6IGrd:LoadValue( "F6I_SHOWMA", "N")
                oStrF6IGrd:LoadValue( "F6I_PESQ", "1")
            EndIf
            If Empty(oStrF6IGrd:GetValue("F6I_DESC"))
                oStrF6IGrd:LoadValue( "F6I_DESC", cTabDesc)
            EndIf
            If Empty(oStrF6IGrd:GetValue("F6I_ORDEM"))
                oStrF6IGrd:LoadValue( "F6I_ORDEM", Right("0" + cValToChar(nI), 2))
            EndIf
        Next nI
    EndIf

Return .T.





/*/{Protheus.doc} GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xNewValue, xCurrentValue)
    Interception of grid post-validation check.

    @type Method
    @author iprokhorenko
    @since 2024/05/02
    @version 12.1.2310
*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xNewValue, xCurrentValue)  Class RU20D01Event

    Local nI As Numeric
    Local nJ As Numeric

    Local oStrF6KMas As Object
    Local oStrF6IGrd As Object
    Local oModel As Object

    Local lRet as logic

    Local nOperation as Numeric

    nOperation := oSubModel:GetOperation() 
    oModel := FWLoadModel("RU20D01")

    oStrF6KMas := oModel:GetModel("MASTER_F6I")
    oStrF6IGrd := oModel:GetModel("GRID_F6I")

    If nOperation == MODEL_OPERATION_UPDATE
        cTabNum := F6I->F6I_CODIGO
        cTabDesc := F6I->F6I_DESC
    ElseIf nOperation == MODEL_OPERATION_INSERT
        cTabNum := M->NTABLE 
        cTabDesc := M->DTABLE
    EndIf

    lRet := .T.
    
    If nOperation != MODEL_OPERATION_DELETE
        For nI := 1 To oSubModel:Length()
            oSubModel:GoLine(nI)
            If Empty(oSubModel:GetValue("F6I_CODIGO"))
                oSubModel:LoadValue( "F6I_VERSAO", "005")
                oSubModel:LoadValue( "F6I_FILIAL", xFilial("F6I"))
                oSubModel:LoadValue( "F6I_PROCES", "")
                oSubModel:LoadValue( "F6I_MODULO", "3")
                oSubModel:LoadValue( "F6I_CODIGO", cTabNum)
                oSubModel:LoadValue( "F6I_SHOWMA", "N") 
                oSubModel:LoadValue( "F6I_PESQ", "1")   
            EndIf
            If Empty(oSubModel:GetValue("F6I_DESC"))
                oSubModel:LoadValue( "F6I_DESC", cTabDesc)
            EndIf
            If Empty(oSubModel:GetValue("F6I_ORDEM"))
                oSubModel:LoadValue( "F6I_ORDEM", Right("0" + cValToChar(nI), 2))
            EndIf
        Next nI
    EndIf

Return (lRet)




