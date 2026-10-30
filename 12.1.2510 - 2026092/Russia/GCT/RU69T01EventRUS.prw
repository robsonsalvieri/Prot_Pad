#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU69T01RUS.CH"


/*{Protheus.doc} RU06D06EventRUS
@type 		class
@author Konstantin Cherchik 
@since 10/31/2018
@version P12.1.23
@description Class to handle business procces of RU69T01RUS
*/

Class RU69T01EventRUS From FwModelEvent 
		
	Method New() CONSTRUCTOR
    Method ModelPosVld()
    Method BeforeTTS()
	Method AfterTTS()
	Method ModelPreVld()
EndClass

Method New() Class RU69T01EventRUS
Return Nil

/*{Protheus.doc} RU69T01EventRUS
@type 		method
@author Konstantin Cherchik 
@since 10/31/2018
@version P12.1.23
@description Model pos validation
*/
Method ModelPosVld(oModel, cModelId) Class RU69T01EventRUS
Local lRet      as logical
Local oModelF5Q as object
Local aRuleItems := {}
Local aArea      := {}
Local cDocNum    := ''
Local oView    := FwViewActive()

lRet    := .T.
If cModelId == "RU69T01RUS"
    oModelF5Q   := oModel:GetModel("F5QMASTER")
    If (Empty(oModelF5Q:GetValue("F5Q_A1COD")) .Or. Empty(oModelF5Q:GetValue("F5Q_A1LOJ"))) .And. (Empty(oModelF5Q:GetValue("F5Q_A2COD")) .Or. Empty(oModelF5Q:GetValue("F5Q_A2LOJ")))
        lRet    := .F.
        MsgStop(STR0010)
   /* ElseIf ! Empty(oModelF5Q:GetValue("F5Q_A1COD")) .And. ! Empty(oModelF5Q:GetValue("F5Q_A2COD"))    
        lRet    := .F.
        MsgStop(STR0011)*/  //According to the demand of the consultant, it is possible to fill both the buyer and the supplier at the same time, with the appropriate choice of relationships. Maybe this approach will be changed over time.
    EndIf

    If AllTrim(oModelF5Q:GetValue("F5Q_TYPE")) == '01' .And. (!Empty(oModelF5Q:GetValue("F5Q_A2COD")) .Or. !Empty(oModelF5Q:GetValue("F5Q_A2LOJ"))) 
        If MsgYesNo(STR0018,STR0017)
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A2COD","")
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A2LOJ","")
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A2NAME","") 
            lRet := .T.
        Else
            lRet := .F.
        EndIf
    ElseIf AllTrim(oModelF5Q:GetValue("F5Q_TYPE")) == '02' .And. (!Empty(oModelF5Q:GetValue("F5Q_A1COD")) .Or. !Empty(oModelF5Q:GetValue("F5Q_A1LOJ")))
        If MsgYesNo(STR0019,STR0017)
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A1COD","")
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A1LOJ","")
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A1NAME","")
            lRet := .T.
        Else
            lRet := .F.
        EndIf
    EndIf

EndIf

    If lRet .And. (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)

        If oModel:GetValue("F5QMASTER", "F5Q_TDOC") == '2' .And. Empty(AllTrim(oModel:GetValue("F5QMASTER", "F5Q_MAINDC")))
            lRet := .F.
            Help("",1,"RU69T01RUS",,STR0031,1,0,,,,,,{STR0027 +" " + AllTrim(FwX3Titulo('F5Q_MAINDC'))})
        EndIf

        If Empty(AllTrim(oModel:GetValue("F5QMASTER", "F5Q_CODE"))) .And. !Empty(AllTrim(oModel:GetValue("F5QMASTER", "F5Q_CTYPE"))) .And. !Empty(AllTrim(oModel:GetValue("F5QMASTER", "F5Q_TDOC")))
            If !F65->(DbSeek(xFilial('F65')+oModel:GetValue("F5QMASTER", "F5Q_CTYPE")+oModel:GetValue("F5QMASTER", "F5Q_TDOC")))
                lRet := .F.
                Help("",1,"RU69T01RUS",,STR0031,1,0,,,,,,{STR0031})
            Else
                cDocNum := RU69T01002(oModel:GetValue("F5QMASTER","F5Q_CTYPE"), oModel:GetValue("F5QMASTER","F5Q_TDOC"))
                If Empty(cDocNum)
                    lRet := .F.
                EndIf
                If lRet
                    lRet := oModel:LoadValue("F5QMASTER", "F5Q_CODE", cDocNum)
                    lRet := oModel:LoadValue("F5RDETAIL", "F5R_CODE", cDocNum)
                    oView:Refresh()
                EndIf
            EndIf
        EndIf

        If lRet
            aRuleItems := RU69T01001(oModel:GetValue("F5QMASTER", "F5Q_CTYPE"), DTOS(oModel:GetValue("F5QMASTER", "F5Q_EDATE")), oModel:GetValue("F5QMASTER", "F5Q_CODE" ), oModel:GetValue("F5QMASTER", "F5Q_GRCNS" ))
            If Len(aRuleItems) > 0
                aArea := F5S->(GetArea())
                DbSelectArea("F5S")
                DbGoTo(aRuleItems[1])
                oModel:LoadValue("F5QMASTER", "F5Q_PAYAC" , F5S->F5S_PAYAC )
                oModel:LoadValue("F5QMASTER", "F5Q_PAYAR" , F5S->F5S_PAYAR )
                oModel:LoadValue("F5QMASTER", "F5Q_ADVAC" , F5S->F5S_ADVAC )
                oModel:LoadValue("F5QMASTER", "F5Q_ADVAR" , F5S->F5S_ADVAR )
                oModel:LoadValue("F5QMASTER", "F5Q_CFAR"  , F5S->F5S_CFAR  )
                If oModel:GetModel("F5QMASTER"):GetStruct():HasField("F5Q_EC09DB")
                    oModel:LoadValue("F5QMASTER", "F5Q_EC09DB", F5S->F5S_EC09DB)
                EndIf
                oModel:LoadValue("F5QMASTER", "F5Q_PRFAC" , F5S->F5S_PRFAC )
                oModel:LoadValue("F5QMASTER", "F5Q_CSTAC" , F5S->F5S_CSTAC )
                oModel:LoadValue("F5QMASTER", "F5Q_PRFAR" , F5S->F5S_PRFAR )
                oModel:LoadValue("F5QMASTER", "F5Q_CSTAR" , F5S->F5S_CSTAR )
                oModel:LoadValue("F5QMASTER", "F5Q_LEGAC" , F5S->F5S_LEGAC )
                oModel:LoadValue("F5QMASTER", "F5Q_VATAC" , F5S->F5S_VATAC )
                oModel:LoadValue("F5QMASTER", "F5Q_LEGAR" , F5S->F5S_LEGAR )
                oModel:LoadValue("F5QMASTER", "F5Q_VATAR" , F5S->F5S_VATAR )

                RestArea(aArea)
            Else
                lRet := .F.
                Help("",1,"RU69T01RUS",,STR0031,1,0,,,,,,{STR0032})
            EndIf
        EndIf
    EndIf

Return lRet

/*{Protheus.doc} RU69T01EventRUS
@type 		method
@author Konstantin Cherchik 
@since 04/02/2020
@version 	P12.1.27
@description Key transfer from the header table.  
*/
Method BeforeTTS(oModel, cModelId) Class RU69T01EventRUS 

    Local lRet as logical

    lRet := .T.

    If (oModel:GetOperation() != 5)     //if operation is not a delete 
        lRet := oModel:GetModel("F5RDETAIL"):SetValue("F5R_UIDF5Q",oModel:GetModel("F5QMASTER"):GetValue("F5Q_UID"))
    EndIf

Return lRet

/*{Protheus.doc} RU69T01EventRUS
@type 		method
@author Dmitry Borisov
@since 04/10/2023
@version 
@description Run syncronization with analytics on insert  
*/
Method AfterTTS(oModel, cModelId) Class RU69T01EventRUS 

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        RU34XREP01("RU69T01RUS", .F.)
    EndIf

Return Nil

/*{Protheus.doc} RU69T01EventRUS
@type 		method
@author Dmitry Borisov
@since 21/11/2023
@version 
@description Code transfer from the header table.  
*/
Method ModelPreVld(oModel, cModelId) Class RU69T01EventRUS 

    Local lRet := .T.

    If oModel:GetOperation() <> MODEL_OPERATION_DELETE .And. oModel:GetOperation() <> MODEL_OPERATION_VIEW .And. ;
    !Empty(AllTrim(oModel:GetValue("F5QMASTER","F5Q_CODE"))) .And. oModel:GetValue("F5RDETAIL","F5R_CODE") <> oModel:GetValue("F5QMASTER","F5Q_CODE")
        lRet := oModel:LoadValue("F5RDETAIL", "F5R_CODE", oModel:GetValue("F5QMASTER","F5Q_CODE"))
    EndIf

    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        lRet := RU34XFUN08(STR0031, STR0033, "RU69T01RUS", "F5Q")
    EndIf

Return (lRet)
                   
//Merge Russia R14 
                   
