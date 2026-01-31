#DEFINE SOURCEFATHER "RSPA100"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RSPA100.CH"
#INCLUDE "INKEY.CH"


#DEFINE EXPERIENCE_CODES "01|02|03"

/*/{Protheus.doc} RSPA100Event()
    Class of events for routine RSPA100RUS.

    @type Class
    @author iprokhorenko
    @since 2024/02/12
    @version 191205P
*/
Class RSPA100Event From FWModelEvent

    Method New() Constructor
    Method Activate(oSubModel, lCopy)
    Method BeforeTTS(oModel, cModelId)

Endclass

/*/{Protheus.doc} New()
    Creates a new class element.

    @type Method
    @author iprokhorenko
    @since 2024/02/12
    @version 191205P
*/
Method New() Class RSPA100Event
Return



/*/{Protheus.doc} Activate(oSubModel, cModelID)
    Interception of grid post-validation check.

    @type Method
    @author iprokhorenko
    @since 2024/02/12
    @version 191205P
*/
Method Activate(oSubModel, lCopy) Class RSPA100Event
    
    Local oModel As Object
    Local aData as Array
    Local aDatTemp as Array
    Local aGetCoBrRusInfo as Array
    Local nOperation as Numeric

    nOperation := oSubModel:GetOperation() 

    If nOperation == MODEL_OPERATION_INSERT
        aGetCoBrRusInfo := GetCoBrRUS(M->QS_FILPOST)

        aDatTemp := {}
        aData := {}

        If !Empty(AGETCOBRRUSINFO[3][1])
            cAddrKey := FwXFilial("AGA") + 'SM0' + AGETCOBRRUSINFO[3][1][4] + '0'
            
            aAGAArea := AGA->(GetArea())
            DbSelectArea("AGA")
            DbSetOrder(1) // AGA_FILIAL+AGA_ENTIDA+AGA_CODENT+AGA_TIPO
            DbGoTop()

            If !Empty(Posicione("AGA", 1, cAddrKey , "AGA_FULL"))
                aAdd(aDatTemp, {"AGA_FULL", AllTrim(AGA->AGA_FULL)})
                aAdd(aDatTemp, {"AGA_MUNDES", AllTrim(AGA_MUNDES)})
                aAdd(aDatTemp, {"AGA_HOUSE", AllTrim(AGA_HOUSE)})
                aAdd(aDatTemp, {"AGA_END", AllTrim(AGA_END)})
            EndIf

            RestArea(aAGAArea)
        Else
            aAdd(aDatTemp, {"AGA_FULL", ''})
            aAdd(aDatTemp, {"AGA_MUNDES", ''})
            aAdd(aDatTemp, {"AGA_HOUSE", ''})
            aAdd(aDatTemp, {"AGA_END", ''})
        EndIf
        
        oModel := oSubModel:GetModel("SQSMASTER")

        oModel:SetValue( "QS_DCITY", AllTrim(aDatTemp[2][2]))
        oModel:SetValue( "QS_DSTRIT", AllTrim(aDatTemp[4][2]))
        oModel:SetValue( "QS_DBUILD", AllTrim(aDatTemp[3][2]))
        oModel:SetValue( "QS_WPLACE", AllTrim(aDatTemp[1][2]))
    EndIf
Return 



/*/{Protheus.doc} BeforeTTS(oModel, cModelId)
    Interception of grid post-validation check.

    @type Method
    @author iprokhorenko
    @since 2024/05/02
    @version 12.1.2310
*/
Method BeforeTTS(oModel, cModelId) Class RSPA100Event
    Local nI As Numeric
    Local nJ As Numeric

    Local lRes
    Local cText as Character
    Local oStrF6IGrd As Object

    Local nOperation as Numeric

    nOperation := oModel:GetOperation() 
    lRes := .T.

    If nOperation == 1
        If M->QS_TIPO $ "1*3"
            cText := STR0030 + RU20XFUN02("R004", M->QS_CODSITE, 1, 6, 7, 40)
            lRes := MsgYesNo(cText +"?")
        EndIf
    ElseIf nOperation == 4
        If M->QS_TIPO $ "1*3"
            cText := STR0030 + RU20XFUN02("R004", M->QS_CODSITE, 1, 6, 7, 40)
            lRes := MsgYesNo(cText +"?")
            If lRes
                cMsgText := STR0032
            EndIf
        EndIf
    EndIf

Return lRes
