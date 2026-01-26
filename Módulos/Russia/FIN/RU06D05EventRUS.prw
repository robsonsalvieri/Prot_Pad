#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RU06D05.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"

//PO F49_PREPAY
Static   __ONLY_PREPAY := "1" //only prepayment
Static   __NONL_PREPAY := "2" //not only prepayment
//For F5M_CTRBAL
Static   __CNTRL_BALAN := "1" //control balance
Static   __NOCTR_BALAN := "2" //do not control balance
//PR statuses
Static   __PR_CREATED  := "1" //created
Static   __PR_INCINPO  := "2" //included in PO
Static   __PR_PAID     := "3" //paid
Static   __PR_APPROVED := "4" //approved
Static   __PR_REJECTED := "5" //rejected
//PO statuses
Static   __PO_CREATED  := "1" //created
Static   __PO_SENTBANK := "2" //sent to bank
Static   __PO_REJECTED := "3" //rejected
Static   __PO_PAID     := "4" //paid



/*{Protheus.doc} RU06D05EventRUS
@type 		class
@author 	natalia.khozyainova
@version 	1.0
@since		27.07.2018
@description class for RU06D05
*/

Class RU06D05EventRUS From FwModelEvent 

	Method New() CONSTRUCTOR
	Method FieldPreVld()
	Method GridLinePreVld()
	Method GridLinePosVld()
	Method ModelPosVld()
	Method InTTS()

EndClass

/*{Protheus.doc} RU06D04EventRUS
@type 		method
@author 	natalia.khozyainova
@version 	1.0
@since		27.07.2018
@description Basic constructor. 
*/
Method New() Class RU06D05EventRUS
Return Nil


Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class RU06D05EventRUS
Local lRet       as Logical
Local oModel     as Object
Local oModelF49  as Object
Local oModelF4B  as Object
Local oModelVirt as Object

lRet:=.T.


If cAction == 'SETVALUE' .and. cModelId=="RU06D05_MF49"
	oModel:=oSubModel:GetModel()
	oModelF49:=oModel:GetModel("RU06D05_MF49")
	oModelF4B:=oModel:GetModel("RU06D05_MF4B")
	oModelVirt:=oModel:GetModel("RU06D05_MVIRT")
	if (cId == "F49_DTACTP" .and. xValue<FwFldGet("F49_DTPAYM") .and. !Empty(xValue)).or. (cId=="F49_DTPAYM" .and. xValue>FwFldGet("F49_DTACTP") .and. TRIM(DTOS(FwFldGet("F49_DTACTP")))!="" )
		lRet:=.F.
		Help("",1,STR0048,,STR0047,1,0,,,,,,{STR0049}) // Actual date of payment can not be before listed date of payment -- Dates -- Change dates
	EndIf
	If lRet .AND. cId == "F49_VALUE"
		lRet := RU06D05517_Check_HeaderValue(xValue, oModelF49, oModelVirt)
	EndIf
	If lRet .AND. cId == "F49_VATAMT"
		lRet := RU06D05518_Check_HeaderVATAMT(xValue, oModelF49, oModelVirt)
	EndIf
EndIf


Return (lRet)



Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class RU06D05EventRUS
Local lRet as Logical
Local lNdel as Logical
Local oModel as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local oModelF4B as Object
Local oModelVirt as Object
Local nX as Numeric
Local nY as Numeric
Local nVal As Numeric
Local nTheLine as Numeric
Local oView as Object
Local aNewCnvVal as Array
Local aViews     as Array

Local oGridF4A as Object
Local oGridF4B as Object
Local oGridFake as Object
Static lAtUpdExRt  := .F.

lRet:=.T.
lNdel:=.F.

oModel:=oSubModel:GetModel()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4B:=oModel:GetModel("RU06D05_MF4B")
oModelVirt:=oModel:GetModel("RU06D05_MVIRT")

If oModel:GetID() == "RU06D06" .AND. cModelID == "RU06D05_MVIRT"
	If lRet .AND. (cID == "B_CHECK" .OR. cID == "B_EXGRAT") .AND. cAction == "CANSETVALUE"
		// We can change B_CHECK when B_CURREN != F49_CURREN
		If lRet .AND. !(RU06D06011_CanChangeExchangeRateInLine(oModelVirt,oModelF49))
			lRet := .F.
			RU06D05514_ShowHelp(1)
		EndIf
	EndIf
	If lRet .AND. cID == "B_CHECK" .AND. cAction == "SETVALUE"
		lRet := oModelVirt:SetValue("B_RATUSR", IIF(xValue,"1","0"))
		If lRet .AND. RU06D05516_CanAutoUpdateExchangeRate(xValue, xCurrentValue)
			// we autoupdate exchange rate to default value
			// we set static lAtUpdExRt equal .T., because when we change
			// exchange rate automatically we should leave B_CHECK as .F.
			lAtUpdExRt := .T.
			lRet := oModelVirt:SetValue("B_EXGRAT",RU06D05508_RetExgRat(oModelVirt, oModelF49))
			lAtUpdExRt := .F.
		EndIf
	EndIf
	If lRet .AND. cID == "B_EXGRAT" .AND. cAction == "SETVALUE"
		If lRet .AND. xValue <= 0 // B_EXGRAT should be > 0
			lRet := .F.
			RU06D05514_ShowHelp(4)
		EndIf
		If lRet .AND. lAtUpdExRt == .F.
			// load value for excluding recursion
			lRet := oModelVirt:LoadValue("B_CHECK" , .T.)
			lRet := lRet .AND. oModelVirt:LoadValue("B_RATUSR", "1")
		EndIf
		If lRet
			aNewCnvVal := RU06D05509_GetNewCnvValues(xValue,oModelVirt:GetValue("B_VALPAY"),oModelVirt,oModelF49)
			lRet := RU06D05510_LoadNewCnvValues(oModelVirt,oModelF49,aNewCnvVal)
			lRet := lRet .AND. RU06D05511_UpdateReason()
		EndIf
	EndIf
	If lRet .AND. cId == "B_VALPAY" .AND. cAction == "SETVALUE"
		If lRet .AND. xValue <= 0 // B_VALPAY should be > 0
			lRet := .F.
			RU06D05514_ShowHelp(4)
		EndIf
		//check B_OPBAL and update it if it was changed
		lRet := lRet .AND. RU06D05507_SeekF4BbyVRT(oModelVirt,oModelF4B,.F.,.T.)
		nVal := IIF(lRet,RU06D05506_Ret_OPBAL(oModelF4B,oModelF49),0)
		If lRet .AND. (oModelVirt:GetValue("B_OPBAL") != nVal)
			// Update B_OPBAL
			// we use loadvalue, becase B_OPBAL closed for editing by user
			lRet := oModelVirt:LoadValue("B_OPBAL", nVal)
		EndIf
		If 	lRet .AND. (nVal < xValue) // B_OPBAL less than new B_VALPAY
			lRet := .F.
			RU06D05514_ShowHelp(3)
		EndIf
		If lRet
			aNewCnvVal := RU06D05509_GetNewCnvValues(oModelVirt:GetValue("B_EXGRAT"),xValue,oModelVirt,oModelF49)
			lRet := RU06D05510_LoadNewCnvValues(oModelVirt,oModelF49,aNewCnvVal)
			lRet := lRet .AND. RU06D05511_UpdateReason()
		EndIf
	EndIf
	If lRet .AND. cId == "B_VLVATC" .AND. cAction == "SETVALUE"
		If lRet .AND. xValue > oModelVirt:GetValue("B_VALCNV")
			lRet := .F.
			RU06D05514_ShowHelp(5)
		EndIf
		If lRet .AND. xValue < 0 //value should be equal 0 or more
			lRet := .F.
			RU06D05514_ShowHelp(9)	
		EndIf
		If lRet
			lRet := oModelVirt:LoadValue("B_BSVATC",oModelVirt:GetValue("B_VALCNV") - xValue)
			lret := lRet .AND. oModelF49:LoadValue("F49_VATAMT",oModelF49:GetValue("F49_VATAMT")+(xValue-xCurrentValue))
			lRet := lRet .AND. RU06D05511_UpdateReason()
		EndIf
	EndIf
	If lRet .AND. cId == "B_BSVATC" .AND. cAction == "SETVALUE"
		If lRet .AND. xValue > oModelVirt:GetValue("B_VALCNV")
			lRet := .F.
			RU06D05514_ShowHelp(6)
		EndIf
		If lRet .AND. xValue < 0 //value should be equal 0 or more
			lRet := .F.
			RU06D05514_ShowHelp(9)	
		EndIf
		If lRet
			lRet := oModelVirt:LoadValue("B_VLVATC",oModelVirt:GetValue("B_VALCNV") - xValue)
			lRet := lRet .AND. oModelF49:LoadValue("F49_VATAMT",oModelF49:GetValue("F49_VATAMT")+(xCurrentValue-xValue))
			lRet := lRet .AND. RU06D05511_UpdateReason()
		EndIf
	EndIf
	If lRet .AND. cAction == "DELETE"
		lRet := RU06D05512_UpdateF4BLine(oModelVirt, oModelF4B, cAction)
		lRet := lRet .AND. oModelF49:LoadValue("F49_VALUE", oModelF49:GetValue("F49_VALUE")  - oModelVirt:GetValue("B_VALCNV"))
		lRet := lRet .AND. oModelF49:LoadValue("F49_VATAMT",oModelF49:GetValue("F49_VATAMT") - oModelVirt:GetValue("B_VLVATC"))
		lRet := lRet .AND. RU06D05511_UpdateReason()
		RU06D05515_RefreshView("RU06D05_VHEAD")
	EndIf
	If lRet .AND. cAction == "UNDELETE"
		lRet := .F.
		//impossible to undelete line, becasue
		//for one supplier we can undelete AP which
		//relates to other supplier 
		//it will be a bug
		//for excluding this we should change vrt model and f4b model structers
		RU06D05514_ShowHelp(7)
	EndIf
EndIf


If cModelID=='RU06D05_MF4A'

	oModelF4A:=oModel:GetModel("RU06D05_MF4A")

	if cAction = "UNDELETE" 
		lRet:=RU06D0539_OkToUnDelete(nLine)
	EndIf

	If lRet
		RU06D0531_TOTLS(.T., nLine, cAction) // Recalculate total Value, Total VAT
		RU06D0536_POReason(nLine,cAction) // Update Reason of Payment
		oModelF4A:GoLine(nLine)
	EndIf

	If cAction = "UNDELETE" .and. lRet 
		oModelF4B:SetNoDeleteLine(.F.)
		oModelVirt:SetNoDeleteLine(.F.)

		For nX:=1 to oModelF4B:Length() // On undeletion a line in Model F4A delete all conected lines from F4B
			oModelF4B:GoLine(nX)
			If oModelF4B:IsDeleted()
				oModelF4B:UnDeleteLine()
			EndIf
		Next nX

		For nY:=1 to oModelVirt:Length() // On undeletion a line in Model F4A delete all conected lines from Virtual Grid
			oModelVirt:GoLine(nY)
			if oModelVirt:GetValue("B_CODREQ")==oSubModel:GetValue("F4A_CODREQ")
				oModelVirt:UnDeleteLine()
			EndIf
		Next nY

		oModelF4B:SetNoDeleteLine(.T.)
		oModelVirt:SetNoDeleteLine(.T.)
	EndIf

	if cAction == "DELETE" 
		oModelF4B:SetNoDeleteLine(.F.)
		oModelVirt:SetNoDeleteLine(.F.)
		
		// check if there is another valid payment request in the model F4A otherwise clean the field F49_FILREQ	
		nTheLine:=oModelF4A:GetLine()
		nx:=1
		While nX <=  oModelF4A:Length() .and. !lNdel
			oModelF4A:GoLine(nX)
			if !(oModelF4A:IsDeleted()) .and. nX != nTheLine
				lNdel:=.T.
			EndIf
			nX++
		EndDo 
		oModelF4A:GoLine(nTheLine)
		if (!lNdel)
			oModelF49:ClearField("F49_FILREQ")
		Endif 
		for nX:=1 to oModelF4B:Length()
			oModelF4B:GoLine(nX)
			if !Empty(FwFldGet("F4B_IDF4A"))
				oModelF4B:DeleteLine()
			EndIf
		next nX

		for nY:=1 to oModelVirt:Length()
			oModelVirt:GoLine(nY)
			if oModelVirt:GetValue("B_CODREQ")==oSubModel:GetValue("F4A_CODREQ")
				oModelVirt:DeleteLine()
			EndIf
		next nY

		oModelF4B:SetNoDeleteLine(.T.)
		oModelVirt:SetNoDeleteLine(.T.)
	EndIf

	oView	:= FWViewActive()
	If oView != Nil
		aViews := oView:AVIEWS
		If ASCAN(aViews[1], {|x| IIF(Valtype(x) == "C",x == "RU06D05_VVIRT",.F.)}) > 0
			oGridFake:= oView:GetViewObj("RU06D05_VVIRT")[3]
			oGridF4A:Refresh( .T. /* lEvalChanges */, .F. /* lGoTop */)
		EndIf
		If ASCAN(aViews[1], {|x| IIF(Valtype(x) == "C",x == "RU06D05_VLNS",.F.)}) > 0
			oGridF4A:= oView:GetViewObj("RU06D05_VLNS")[3]
			oGridFake:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
		ENDIF
		If ASCAN(aViews[1], {|x| IIF(Valtype(x) == "C",x == "RU06D05_VGLNS",.F.)}) > 0
			oGridF4B:= oView:GetViewObj("RU06D05_VGLNS")[3]
			oGridF4B:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
		EndIf
		oModelVirt:GoLine(1)
	EndIf
EndIf

Return (lRet)



Method ModelPosVld(oModel, cModelID) Class RU06D05EventRUS
Local lRet      as Logical
Local oModelF49 as Object
Local oModelF4A as Object
Local oModelVrt as Object
Local nVal      as Numeric
Local nX        as Numeric
Local cNumOrd   as Character
Local cNumBnk   as Character
Local aError    as Array

lRet:=.T.
oModelF49:=oModel:GetModel("RU06D05_MF49")
nVal:=0
If oModel:cSource == "RU06D05"
	//validation for PO with PR
	oModelF4A:=oModel:GetModel("RU06D05_MF4A")  
	For nX:=1 to oModelF4A:Length()
		oModelF4A:GoLine(nX)
		If !(oModelF4A:IsDeleted()) 
			nVal+=oModelF4A:GetValue("F4A_VALUE")
		EndIf
	Next nX
	If nVal>oModelF49:GetValue("F49_VALUE")
		lRet:= .F.
		Help("",1,STR0078,,STR0079,1,0,,,,,,{STR0080,STR0081}) // Total Value is not correct -- Total value can not be less then sum from PRs -- Recalculate totals -- Update total value of PO manually
	EndIf
ElseIf oModel:cSource == "RU06D06"
	//validation for PO without PR
	oModelVrt := oModel:GetModel("RU06D05_MVIRT")
	lRet := RU06D05517_Check_HeaderValue(oModelF49:GetValue("F49_VALUE"), oModelF49, oModelVrt)
EndIf
//Insert bank order and payorder numbers
If lRet .AND. (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == 9 /*Copy*/)
	cNumOrd := ""
	cNumBnk := ""
	cNumOrd := RU09D03NMB("PAYORD")
	While Right(cNumOrd,3) == "000" //generate payorder number until last 3 digits not equal to 0
		cNumOrd := RU09D03NMB("PAYORD")
	EndDo
	If RU99XFUN08_IsInteger(Right(cNumOrd,GetSX3Cache("F49_BNKORD","X3_TAMANHO")))
		cNumBnk := alltrim(str(val(right(cNumOrd,GetSX3Cache("F49_BNKORD","X3_TAMANHO")))))
	Else
		lRet := .F.
		Help("",1,STR0063,,STR0076,1,0,,,,,,{STR0065}) // Bank Number is not allowed -- Can not include any letters -- Change the number
	EndIf
	lRet := lRet .AND. oModelF49:LoadValue("F49_BNKORD",cNumBnk)
	lRet := lRet .AND. oModelF49:LoadValue("F49_PAYORD",right(cNumOrd,TamSX3("F49_PAYORD")[1]))
	If oModel:HasErrorMessage()
		lRet   := .F.
		aError := oModel:GetErrorMessage()
		HELP("",1, aError[MODEL_MSGERR_IDFORM],,;  //Form
			aError[MODEL_MSGERR_IDFIELDERR] + " "+;
			aError[MODEL_MSGERR_MESSAGE],;    //Field and error
			1,0,,,,,,;
			{aError[MODEL_MSGERR_SOLUCTION]}) //Solution   
	EndIf
EndIf

Return (lRet)


Method InTTS (oModel, cModelId) Class RU06D05EventRUS
Local nOper     as Numeric
Local nX        as Numeric
Local nVALCNV   as Numeric
Local nVLVATC   as Numeric
Local nBSVATC   as Numeric
Local oModelF49 as Object
Local oModelF4A as Object
Local oModelF4B as Object
Local aArea     as Array
Local aAreaF47  as Array
Local cPayOrd   as Character
Local cKeyF47   as Character
Local cStatusPO as Character
Local cStatusPR as Character
Local lPOwithPR as Logical
Local lOk       as Logical

nOper     := oModel:GetOperation()
oModelF49 := oModel:GetModel("RU06D05_MF49")
oModelF4A := oModel:GetModel("RU06D05_MF4A")
oModelF4B := oModel:GetModel("RU06D05_MF4B")
lOk       := .T.
aArea     := GetArea()
aAreaF47  := F47->(GetArea())
cStatusPO := oModelF49:GetValue("F49_STATUS")
lPOwithPR := IIF(oModel:cSource == "RU06D05",.T.,.F.)

If (nOper == MODEL_OPERATION_INSERT .or. nOper == MODEL_OPERATION_UPDATE .or. nOper==9 /*Copy*/) .and. cStatusPO == __PO_CREATED
	If oModelF49:GetValue("F49_PREPAY") == __ONLY_PREPAY //only prepayment payment order
		nVALCNV := oModelF49:GetValue("F49_VALUE")
		nVLVATC := oModelF49:GetValue("F49_VATAMT")
		nBSVATC := nVALCNV - nVLVATC
		If lPOwithPR
			nX := 1
			While lOk .AND. nX <= oModelF4A:Length()
				oModelF4A:GoLine(nX)
				cStatusPR := IIF(oModelF4A:IsDeleted(), RU06D05505_RetStatusForPRWhenDeletePO(), __PR_INCINPO)
				cPayOrd   := IIF(oModelF4A:IsDeleted(), "", oModelF49:GetValue("F49_PAYORD"))
				cKeyF47   := RU06D05504_Return_cKeyF47FromF4ALine(oModelF4A)
				lOk := RU06D0550_WrModelRU06D04(cKeyF47, cStatusPR, cPayOrd)
				nX := nX + 1
			EndDo
		EndIf
		lOk := lOk .AND. RU06XFUN07_WrToF5(oModelF49:GetValue("F49_IDF49"), "F49", "", oModelF49:GetValue("F49_VALUE"), __NOCTR_BALAN, 1,;
		                  /*cFil*/,/*lCtrBalOnl*/,nVALCNV,nBSVATC,nVLVATC                                               ) // write line 'F49'
	Else //not only prepayment payment order F49_PREPAY == 2
		If lPOwithPR
			nX := 1
			While lOk .AND. nX <= oModelF4A:Length()
				oModelF4A:GoLine(nX)
				cStatusPR := IIF(oModelF4A:IsDeleted(), RU06D05505_RetStatusForPRWhenDeletePO(), __PR_INCINPO)
				cPayOrd   := IIF(oModelF4A:IsDeleted(), "", oModelF49:GetValue("F49_PAYORD"))
				cKeyF47   := RU06D05504_Return_cKeyF47FromF4ALine(oModelF4A)
				lOk := RU06D0550_WrModelRU06D04(cKeyF47, cStatusPR, cPayOrd)
				If !oModelF4A:IsDeleted() 
					lOk := lOk .AND. RU06D05500_WriteF4BLinesToF5MTable(oModelF4B, oModelF49)
				Else
					lOk := lOk .AND. RU06D05501_DeleteF4BLinesFromF5MTable(oModelF4B, oModelF49)
				EndIf
				nX := nX + 1
			EndDo
		Else // in case payment order witout payment requests
			lOk := lOk .AND. RU06D05500_WriteF4BLinesToF5MTable(oModelF4B, oModelF49)
		EndIf
	EndIf

EndIf
 
If nOper == MODEL_OPERATION_DELETE .or. (nOper == MODEL_OPERATION_UPDATE .and. cStatusPO == __PO_SENTBANK)
	cStatusPR := IIF(nOper == MODEL_OPERATION_DELETE, RU06D05505_RetStatusForPRWhenDeletePO(), __PR_INCINPO)
	cPayOrd   := IIF(nOper == MODEL_OPERATION_DELETE, "", oModelF49:GetValue("F49_PAYORD"))
	If oModelF49:GetValue("F49_PREPAY") == __ONLY_PREPAY
		If lPOwithPR
			nX := 1
			While  lOk .AND. nX <= oModelF4A:Length()
				oModelF4A:GoLine(nX)			
				cKeyF47 := RU06D05504_Return_cKeyF47FromF4ALine(oModelF4A)
				lOk := RU06D0550_WrModelRU06D04(cKeyF47, cStatusPR, cPayOrd)
				nX := nX + 1
			EndDo
		EndIf
		If nOper == MODEL_OPERATION_DELETE
			lOk := RU06XFUN07_WrToF5(oModelF49:GetValue("F49_IDF49"), "F49", "", , __NOCTR_BALAN, 2) // del line in F5M with alias to 'F49'
		Else // update F5M_CTRBAL
			lOk := RU06XFUN07_WrToF5(oModelF49:GetValue("F49_IDF49"), "F49", "", , __NOCTR_BALAN, 1, Nil, .T.) // upd CTRBAL in F5M line
		EndIf
	Else
		If lPOwithPR
			nX := 1
			While lOk .AND. nX <= oModelF4A:Length()
				oModelF4A:GoLine(nX)
				cKeyF47 := RU06D05504_Return_cKeyF47FromF4ALine(oModelF4A)
				lOk := RU06D0550_WrModelRU06D04(cKeyF47, cStatusPR, cPayOrd)
				If nOper == MODEL_OPERATION_DELETE
					lOk := lOk .AND. RU06D05501_DeleteF4BLinesFromF5MTable(oModelF4B, oModelF49)
				Else
					lOk := lOk .AND. RU06D05503_ChangeF5M_CTRBAL_inF5MRecordwithAliasToF4B(oModelF4B, oModelF49)
				EndIf
				nX := nX +1
			EndDo
		Else
			If nOper == MODEL_OPERATION_DELETE
				lOk := lOk .AND. RU06D05501_DeleteF4BLinesFromF5MTable(oModelF4B, oModelF49)
			Else
				lOk := lOk .AND. RU06D05503_ChangeF5M_CTRBAL_inF5MRecordwithAliasToF4B(oModelF4B, oModelF49)
			EndIf
		EndIf
	EndIf
EndIf

If nOper == MODEL_OPERATION_UPDATE /*4*/ .and. cStatusPO == __PO_PAID /*paid*/ .and. lPOwithPR /* only for PO with PR */
	// so status of BS was posted in finance and we should change PO status
	// included to this BS and PR statuses included in PO
	nX := 1
	While lOk .AND. nX <= oModelF4A:Length()
		oModelF4A:GoLine(nX)
		cStatusPR := __PR_PAID
		cKeyF47   := RU06D05504_Return_cKeyF47FromF4ALine(oModelF4A)
		lOk := RU06D0550_WrModelRU06D04(cKeyF47, cStatusPR, oModelF49:GetValue("F49_PAYORD"))
		nX := nX + 1
	EndDo
EndIf

//update statutes in related PR's
If lPOwithPR
	cStatusPR := ""
	If     cStatusPO == __PO_PAID
		cStatusPR := __PR_PAID
	ElseIf cStatusPO == __PO_REJECTED
		cStatusPR := __PR_INCINPO
	EndIf
	If cStatusPR == __PR_INCINPO .OR. cStatusPR == __PR_PAID
		nX := 1
		While lOk .AND. nX <= oModelF4A:Length()
			oModelF4A:GoLine(nX)
			If !oModelF4A:IsDeleted()
				DBSELECTAREA("F47")
				DBSETORDER(1) //F47_FILIAL+F47_CODREQ+DTOS(F47_DTREQ)
				cKeyF47 := RU06D05504_Return_cKeyF47FromF4ALine(oModelF4A)
				If DBSEEK(cKeyF47)
					If RECLOCK("F47",.F.)
						If F47->F47_PAYORD == oModelF49:GetValue("F49_PAYORD")
							F47->F47_STATUS := cStatusPR
						Else
							lOk := .F.
						EndIf
						MSUNLOCK()
					Else
						lOk := .F.
					EndIf
				Else
					lOk := .F.
				EndIf
			EndIf
			nX := nX + 1
		EndDo
	EndIf
EndIf

If !lOk
    DisarmTransaction()
    RU06D05Sta("__lDsrmTra",.T.) //Indicate that transaction was Disarmed
EndIf

RestArea(aAreaF47)
RestArea(aArea)

Return (Nil)


Method GridLinePosVld(oSubModel, cModelID, nLine)                     Class RU06D05EventRUS

	Local lRet       As Logical
	Local oModel     As Object
	Local oMdlF4B    As Object
	Local oMdlVrt    As Object

	lRet := .T.
	oModel  := oSubModel:GetModel()

	oMdlF4B := oModel:GetModel("RU06D05_MF4B")
	oMdlVrt := oModel:GetModel("RU06D05_MVIRT")

	If oModel:GetID() == "RU06D06" .AND. cModelID == "RU06D05_MVIRT"
		If !oMdlVrt:IsEmpty() .AND. !oMdlVrt:IsDeleted()
			lRet := RU06D05512_UpdateF4BLine(oMdlVrt, oMdlF4B, "UPDATE")
		EndIf
	EndIf
	
Return (lRet) /*-----------------------------------------------------------GridLinePosVld*/



Static Function RU06D0550_WrModelRU06D04(cKeyF47 as Character, cStatus as Character, cPayOrd as Character)
Local oModelPR as Object
Local lRet     as Logical
Local aArea    As Array
Local aAreaF47 As Array
lRet := .T.
aArea := GetArea()
DbSelectArea("F47")
aAreaF47 := F47->(GetArea())
F47->(DbSetOrder(1)) //F47_FILIAL+F47_CODREQ+DTOS(F47_DTREQ)
If F47->(DBSEEK(cKeyF47))
	If RecLock("F47", .F.)
		oModelPR:= FwLoadModel("RU06D04")
		oModelPR:SetOperation(MODEL_OPERATION_UPDATE)
		oModelPR:Activate()
		oModelPR:GetModel("RU06D04_MHEAD"):SetValue("F47_STATUS", cStatus)
		oModelPR:GetModel("RU06D04_MHEAD"):SetValue("F47_PAYORD", cPayOrd)
		If oModelPR:VldData() 
			lRet := oModelPR:CommitData()
		Else
			lRet := .F.
		EndIf
		oModelPR:DeActivate()
	Else
		lRet := .F.
	EndIf
EndIf
RestArea(aAreaF47)
RestArea(aArea)
Return (lRet)

Static Function RU06D05500_WriteF4BLinesToF5MTable(oModelF4B, oModelF49)
	Local nY          As Numeric
	Local nVALCNV     As Numeric
	Local nBSVATC     As Numeric
	Local nVLVATC     As Numeric
	Local cKeyF5M     As Character
	Local lOk         As Logical
	lOk := .T.
	nY  := 1
	While lOk .AND. nY <= oModelF4B:Length()
		//Write line F4B
		oModelF4B:GoLine(nY)
		nVALCNV := oModelF4B:GetValue("F4B_VALCNV")
		nBSVATC := oModelF4B:GetValue("F4B_BSVATC")
		nVLVATC := oModelF4B:GetValue("F4B_VLVATC")
		cKeyF5M := RU06D05502_GetF5MKeyFromF4BLine(oModelF4B, oModelF49)
		lOk := RU06XFUN07_WrToF5(oModelF4B:GetValue("F4B_UUID"), "F4B", cKeyF5M, oModelF4B:GetValue("F4B_VALPAY"), __CNTRL_BALAN, 1,;
		                  /*cFil*/,/*lCtrBalOnl*/,nVALCNV,nBSVATC,nVLVATC                                          ) // write line 'F4B'
		nY := nY + 1
	EndDo
Return lOk

Static Function RU06D05501_DeleteF4BLinesFromF5MTable(oModelF4B, oModelF49)
	Local nY          As Numeric
	Local cKeyF5M     As Character
	Local lOk         As Logical
	lOk := .T.
	nY := 1
	While lOk .AND. nY <= oModelF4B:Length()
		oModelF4B:GoLine(nY)
		cKeyF5M := RU06D05502_GetF5MKeyFromF4BLine(oModelF4B, oModelF49)
		lOk := RU06XFUN07_WrToF5(oModelF4B:GetValue("F4B_UUID"), "F4B", cKeyF5M, oModelF4B:GetValue("F4B_VALPAY"), __CNTRL_BALAN, 2) // delete line 'F4B'
		nY := nY + 1
	EndDo
Return lOk


Static Function RU06D05503_ChangeF5M_CTRBAL_inF5MRecordwithAliasToF4B(oModelF4B, oModelF49)
	Local cKeyF5M     As Character
	Local nY          As Numeric
	Local lOk         As Logical
	lOk := .T.
	nY := 1
	While lOk .AND. nY <= oModelF4B:Length()
		oModelF4B:GoLine(nY)
		cKeyF5M := RU06D05502_GetF5MKeyFromF4BLine(oModelF4B, oModelF49)
		// so payment order sent to bank, change F5M_CTRBAL field in F5M record with alias to F4B
		lOk := RU06XFUN07_WrToF5(oModelF4B:GetValue("F4B_UUID"), "F4B", cKeyF5M, oModelF4B:GetValue("F4B_VALPAY"), __NOCTR_BALAN, 1, Nil, .T.)
		nY := nY + 1
	EndDo
Return lOk

Static Function RU06D05504_Return_cKeyF47FromF4ALine(oModelF4A)
	Local cRet     As Character
	cRet := oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ"))
Return cRet

Static Function RU06D05505_RetStatusForPRWhenDeletePO()
	Local cRet        As Character
	cRet := IIF(SuperGetMv("MV_REQAPR",, 0) == 1 , __PR_APPROVED, __PR_CREATED)
Return cRet

Static Function RU06D05507_SeekF4BbyVRT(oMdlVrt,oMdlGrid,lDeleted,lLocate)

	Local lRet       As Logical
	Local aBusca     As Array
	aBusca := {}
	lRet   := .T.
	AADD(aBusca, {"F4B_PREFIX", oMdlVrt:GetValue("B_PREFIX")})
	AADD(aBusca, {"F4B_NUM"   , oMdlVrt:GetValue("B_NUM"   )})
	AADD(aBusca, {"F4B_PARCEL", oMdlVrt:GetValue("B_PARCEL")})
	AADD(aBusca, {"F4B_TYPE"  , oMdlVrt:GetValue("B_TYPE"  )})
	AADD(aBusca, {"F4B_IDF4A" , oMdlVrt:GetValue("B_IDF4A" )})
	lRet := lRet .AND. oMdlGrid:SeekLine(aBusca, lDeleted, lLocate)

Return lRet

Function RU06D05508_RetExgRat(oModelVirt, oModelHdr)

	Local nRet    As Numeric
	Local cCurren As Character
	Local cDate   As Character
	If oModelHdr:GetID() == "RU06D07_MHEAD"
		cCurren := "F4C_CURREN"
		cDate   := "F4C_DTTRAN"
	ElseIf oModelHdr:GetID() == "RU06D05_MF49"
		cCurren := "F49_CURREN"
		cDate   := "F49_DTPAYM"
	EndIf
	nRet := xMoeda(1, oModelVirt:GetValue("B_CURREN"),;
	                  Val(oModelHdr:GetValue(cCurren)),;
	                  oModelHdr:GetValue(cDate),;
	                  GetSX3Cache("F4B_EXGRAT","X3_DECIMAL"))

Return nRet


/* {Protheus.doc} RU06D05509_GetNewCnvValues
This function calculates conventional values, VLIMP1, BSIMP1
according to passed exchange rate and payyment value
@param  Numeric      nExgRate    // Excahnge rate for calculating conventional values
        Numeric      nValPay     // payment value in currency of the bill
		Object       oModelVirt  // link to grid model
		Object       oModelHdr   // link to haeder model
@return Array        aRet        // {B_VALCNV,B_VLVATC,B_BSVATC,B_VLIMP1,B_BSIMP1}
@author astepanov
@since 31 October 2020
@version 1.0
@project MA3 - Russia
*/
Function RU06D05509_GetNewCnvValues(nExgRate, nValPay, oModelVirt, oModelHdr)

	Local aRet        As Array
	Local aImp        As Array
	Local aCnvVls     As Array

	aRet := {}
	aImp    := RU06D05513_CalculateBVLIMP1(nValPay, oModelVirt, oModelHdr)
	aCnvVls := RU06XFUN81_RetCnvValues(nValPay,aImp[1],nExgRate,GetSX3Cache("F4B_VALCNV","X3_DECIMAL"))
	AADD(aRet,aCnvVls[1]) 
	AADD(aRet,aCnvVls[2])
	AADD(aRet,aCnvVls[3])
	AADD(aRet,aImp[1]) 
	AADD(aRet,aImp[2])

Return aRet

Function RU06D05510_LoadNewCnvValues(oModelVirt,oModelHdr,aNewCnvVal)

	Local lRet       As Logical
	Local nDiffVLCNV As Numeric
	Local nDiffVLVAT As Numeric
	Local nDiffBSVAT As Numeric
	Local cValue     As Character
	Local cVATAMT    As Character
	Local lUpdVALUE  As Logical
	Local lUpdVATAMT As Logical
	Local lUpdITTOTA As Logical
	Local lUpdITBALA As Logical
	Local lUpdITVATF As Logical
	Local lUpdITVATO As Logical

	lRet  := .T.
	//when calculate difference, we get new value and minus old value
	nDiffVLCNV := aNewCnvVal[1] - oModelVirt:GetValue("B_VALCNV")
	nDiffVLVAT := aNewCnvVal[2] - oModelVirt:GetValue("B_VLVATC")
	nDiffBSVAT := aNewCnvVal[3] - oModelVirt:GetValue("B_BSVATC")
	lRet := lRet .AND. oModelVirt:LoadValue("B_VALCNV", aNewCnvVal[1])
	lRet := lRet .AND. oModelVirt:LoadValue("B_VLVATC", aNewCnvVal[2])
	lRet := lRet .AND. oModelVirt:LoadValue("B_BSVATC", aNewCnvVal[3])
	lRet := lRet .AND. oModelVirt:LoadValue("B_VLIMP1", aNewCnvVal[4])
	lRet := lRet .AND. oModelVirt:LoadValue("B_BSIMP1", aNewCnvVal[5])
	lUpdVALUE  := .F.
	lUpdVATAMT := .F.
	lUpdITTOTA := .F.
	lUpdITBALA := .F.
	lUpdITVATF := .F.
	lUpdITVATO := .F.
	If oModelHdr:GetID() == "RU06D07_MHEAD"
		cValue  := "F4C_VALUE"
		cVATAMT := "F4C_VATAMT"
		If     RU06D07722_IsInflow(Nil, oModelHdr:GetValue("F4C_OPER"))
			If RU06D07721_IsReturnFromSupplier(Nil,oModelHdr:GetValue("F4C_OPER"),oModelHdr:GetValue("F4C_RECTYP"))
				lUpdVALUE  := .T.
				lUpdVATAMT := .T.
			Else
				lUpdITTOTA := .T.
				lUpdITBALA := .T.
				lUpdITVATF := .T.
				lUpdITVATO := .T.
			EndIf
		ElseIf RU06D07723_IsOutflow(Nil, oModelHdr:GetValue("F4C_OPER"))
			lUpdVALUE  := .T.
			lUpdVATAMT := .T.
		EndIf
	ElseIf oModelHdr:GetID() == "RU06D05_MF49"
		cValue  := "F49_VALUE"
		cVATAMT := "F49_VATAMT"
		lUpdVALUE  := .T.
		lUpdVATAMT := .T.
	EndIf
	If nDiffVLCNV != 0
		If lUpdVALUE
			lRet := lRet .AND. oModelHdr:LoadValue(cValue,oModelHdr:GetValue(cValue)+nDiffVLCNV)
		EndIf
		If lUpdITTOTA
			lRet := lRet .AND. oModelHdr:LoadValue("F4C_ITTOTA",oModelHdr:GetValue("F4C_ITTOTA" ) + nDiffVLCNV)
		EndIf
		If lUpdITBALA
			lRet := lRet .AND. oModelHdr:LoadValue("F4C_ITBALA",oModelHdr:GetValue("F4C_VALUE" ) - oModelHdr:GetValue("F4C_ITTOTA" ))
		EndIf
	EndIf
	If nDiffVLVAT != 0
		If lUpdVATAMT
			lRet := lRet .AND. oModelHdr:LoadValue(cVATAMT,oModelHdr:GetValue(cVATAMT)+nDiffVLVAT)
		EndIf
		If lUpdITVATF
			lRet := lRet .AND. oModelHdr:LoadValue("F4C_ITVATF",oModelHdr:GetValue("F4C_ITVATF") + nDiffVLVAT)
		EndIf
		If lUpdITVATO
			lRet := lRet .AND. oModelHdr:LoadValue("F4C_ITVATO",oModelHdr:GetValue("F4C_ITVATO") + xMoeda(nDiffVLVAT,Val(oModelHdr:GetValue("F4C_CURREN")),oModelVirt:GetValue("B_CURREN"),oModelHdr:GetValue("F4C_DTTRAN"),TamSx3("F4C_ITVATO")[2]))
		EndIf
	EndIf
	
Return lRet

Function RU06D05511_UpdateReason()
	Local lRet As Logical
	Local lUpd As Logical
	lRet  := .T.
	lUpd  := .T.

	//check private logical var lUpdReason
	//if it exist we set lUpd equal to it
	If Type("lUpdReason") == "L"
		lUpd := lUpdReason
	EndIf
	If lRet .AND. lUpd
		lRet := RU06D06008_UpdateReason()
	EndIf
Return lRet

Static Function RU06D05512_UpdateF4BLine(oModelVirt, oModelF4B, cAction)
	Local lRet       As Logical
	lRet := .T.
	If     cAction == "DELETE"
		lRet := lRet .AND. RU06D05507_SeekF4BbyVRT(oModelVirt,oModelF4B,.F.,.T.)
		lRet := lRet .AND. oModelF4B:DeleteLine()
	ElseIf cAction == "UPDATE"
		lRet := lRet .AND. RU06D05507_SeekF4BbyVRT(oModelVirt,oModelF4B,.F.,.T.)
		If lRet
			lRet := oModelF4B:LoadValue("F4B_OPBAL",oModelVirt:GetValue("B_OPBAL")  )
			lRet := lRet .AND. oModelF4B:LoadValue("F4B_EXGRAT",oModelVirt:GetValue("B_EXGRAT"))
			lRet := lRet .AND. oModelF4B:LoadValue("F4B_VALPAY",oModelVirt:GetValue("B_VALPAY"))
			lRet := lRet .AND. oModelF4B:LoadValue("F4B_VALCNV",oModelVirt:GetValue("B_VALCNV"))
			lRet := lRet .AND. oModelF4B:LoadValue("F4B_BSVATC",oModelVirt:GetValue("B_BSVATC"))
			lRet := lRet .AND. oModelF4B:LoadValue("F4B_VLVATC",oModelVirt:GetValue("B_VLVATC"))
			lRet := lRet .AND. oModelF4B:LoadValue("F4B_CONUNI",oModelVirt:GetValue("B_CONUNI"))
			lRet := lRet .AND. oModelF4B:LoadValue("F4B_VLIMP1",oModelVirt:GetValue("B_VLIMP1"))
			lRet := lRet .AND. oModelF4B:LoadValue("F4B_FLORIG",oModelVirt:GetValue("B_FLORIG"))
			lRet := lRet .AND. oModelF4B:LoadValue("F4B_RATUSR",oModelVirt:GetValue("B_RATUSR"))
		EndIf
	EndIf
Return lRet

/* {Protheus.doc} RU06D05513_CalculateBVLIMP1
This function calculates VLIMp1, BSIMP1
according to passed payment value and data which contained in oModelVirt and oModelHdr
@param  Numeric      nVALPAY     // payment value
		Object       oModelVirt  // link to grid model
		Object       oModelHdr   // link to haeder model
@return Array        aVal        // {B_VLIMP1,B_BSIMP1}
@author astepanov
@since 31 October 2020
@edit 25 May 2022
@version 1.0
@project MA3 - Russia
*/
Static Function RU06D05513_CalculateBVLIMP1(nVALPAY, oModelVirt, oModelHdr)
	Local cIndice    As Character
	Local aVal       As Array
	Local aInp       As Array
	Local nVlIMP1    As Numeric
	Local nBSIMP1    As Numeric
	Local cTab       As Character
	lRet  := .T.
	If oModelHdr:GetID() == "RU06D07_MHEAD"
		If     RU06D07722_IsInflow(Nil, oModelHdr:GetValue("F4C_OPER"))
			If RU06D07721_IsReturnFromSupplier(Nil,oModelHdr:GetValue("F4C_OPER"),oModelHdr:GetValue("F4C_RECTYP"))
				cForCli := "F4C_SUPP"
				cUnit   := "F4C_UNIT"
				cTab    := "SE2"
			Else
				cForCli := "F4C_CUST"
				cUnit   := "F4C_CUNI"
				cTab    := "SE1"
			EndIf
		ElseIf RU06D07723_IsOutflow(Nil,oModelHdr:GetValue("F4C_OPER"))
			cForCli := "F4C_SUPP"
			cUnit   := "F4C_UNIT"
			cTab    := "SE2"
		EndIf
	ElseIf oModelHdr:GetID() == "RU06D05_MF49"
		cForCli := "F49_SUPP"
		cUnit   := "F49_UNIT"
		cTab    := "SE2"
	EndIf
	If     cTab == "SE2"
		cIndice := PADR(oModelVirt:GetValue("B_FLORIG"),GetSX3Cache("E2_FILIAL" ,"X3_TAMANHO"), " ")+;
		           PADR(oModelVirt:GetValue("B_PREFIX"),GetSX3Cache("E2_PREFIXO","X3_TAMANHO"), " ")+;
		           PADR(oModelVirt:GetValue("B_NUM")   ,GetSX3Cache("E2_NUM"    ,"X3_TAMANHO"), " ")+;
		           PADR(oModelVirt:GetValue("B_PARCEL"),GetSX3Cache("E2_PARCELA","X3_TAMANHO"), " ")+;
		           PADR(oModelVirt:GetValue("B_TYPE")  ,GetSX3Cache("E2_TIPO"   ,"X3_TAMANHO"), " ")+;
		           PADR(oModelHdr:GetValue(cForCli)    ,GetSX3Cache("E2_FORNECE","X3_TAMANHO"), " ")+;
		           PADR(oModelHdr:GetValue(cUnit)      ,GetSX3Cache("E2_LOJA"   ,"X3_TAMANHO"), " ")
	ElseIf cTab == "SE1"
		cIndice := PADR(oModelVirt:GetValue("B_FLORIG"),GetSX3Cache("E1_FILIAL" ,"X3_TAMANHO"), " ")+;
		           PADR(oModelHdr:GetValue(cForCli)    ,GetSX3Cache("E1_CLIENTE","X3_TAMANHO"), " ")+;
		           PADR(oModelHdr:GetValue(cUnit)      ,GetSX3Cache("E1_LOJA"   ,"X3_TAMANHO"), " ")+;
		           PADR(oModelVirt:GetValue("B_PREFIX"),GetSX3Cache("E1_PREFIXO","X3_TAMANHO"), " ")+;
		           PADR(oModelVirt:GetValue("B_NUM")   ,GetSX3Cache("E1_NUM"    ,"X3_TAMANHO"), " ")+;
		           PADR(oModelVirt:GetValue("B_PARCEL"),GetSX3Cache("E1_PARCELA","X3_TAMANHO"), " ")+;
		           PADR(oModelVirt:GetValue("B_TYPE")  ,GetSX3Cache("E1_TIPO"   ,"X3_TAMANHO"), " ")
	EndIf
	aInp := RU06XFUN80_Ret_VLIMP1_BSIMP1(cIndice,nVALPAY,oModelVirt:GetValue("B_VALUE"),GetSX3Cache("F4B_VLIMP1","X3_DECIMAL"),cTab)
	nVlIMP1   := aInp[1]
	nBSIMP1   := aInp[2]
	aVal      := {nVlIMP1, nBSIMP1}
Return aVal

Function RU06D05514_ShowHelp(nMsg)
	Local cMsg   As Character
	Local cSlt   As Character
	Local cTitle As Character
	Local oModel As Object
	// nMsg
	// 1 - Impossible to change exchange rate for identical currencies in the grid and in the header
	// 2 - Impossible to change exchange rate manually
	// 3 - Payment value more than open balance
	// 4 - Value should be more than 0
	// 5 - VAT amount cannot be more than payment value
	// 6 - VAT base cannot be more than payment value
	// 7 - Impossible to undelete this line
	// 8 - Header value less than total value by lines
	// 9 - Value cannot be negative
	cSlt := "" // solution message
	If     nMsg == 1
		cMsg := STR0102
	ElseIf nMsg == 2
		cMsg := STR0103
	ElseIf nMsg == 3
		cMsg := STR0104
	ElseIf nMsg == 4
		cMsg := STR0105
	ElseIf nMsg == 5
		cMsg := STR0106
	ElseIf nMsg == 6
		cMsg := STR0107
	ElseIf nMsg == 7
		cMsg := STR0108
	ElseIf nMsg == 8
		cMsg := STR0109
	ElseIf nMsg == 9
		cMsg := STR0110
	EndIf
	cTitle := STR0002 //PO
	oModel := FWModelActive()
	If oModel != Nil .AND. oModel:GetID() == "RU06D07"
		cTitle := STR0111 //Bank statement
	EndIf
	Help("",1,cTitle,,cMsg,1,0,,,,,,{cSlt})
Return Nil


Static Function RU06D05515_RefreshView(cViewID)
	Local oView As Object
	Local lRet  As Logical
	Local nX    As Numeric
	lRet := .T.
	oView := FWViewActive()
	If oView != Nil
		nX := 0
		nX := ASCAN(oView:AVIEWS, {|x| x[1] == cViewID})
		If nX > 0
			oView:Refresh(cViewID)
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet


/* {Protheus.doc} RU06D06011_CanChangeExchangeRateInLine
This function we for check possibility to set default
exchange rate in B_EXGRAT field
It is possible when current value for B_CHECK is .T. (it means
exchange rate was set manually by the user) and new value is .F. (it
means excahnge rate was set by the system)
@param  Logical      lNB_CHECK   // New value for B_CHECK
        Logical      lCB_CHECK   // Current value for B_CHECK
@return Logical      lRet        // .T. - possible, .F. - impossible
@author astepanov
@since 31 October 2020
@version 1.0
@project MA3 - Russia
*/
Function RU06D05516_CanAutoUpdateExchangeRate(lNB_CHECK, lCB_CHECK)
	Local lRet     As Logical
	If lCB_CHECK == .T. .AND. lNB_CHECK == .F.
		lRet := .T.
	Else
		lRet := .F.
	EndIf
Return lRet

Static Function RU06D05517_Check_HeaderValue(nValue, oModelHdr, oModelVirt)
	Local lRet    As Logical
	Local nTotl   As Logical
	lRet := .T.
	If nValue < 0 // value cannot be negative
		lRet := .F.
		RU06D05514_ShowHelp(9)
	EndIf
	If lRet
		nTotl := RU06D07E7_RetTotalsForHeader(oModelVirt, "VRT", .F.)[1]
		If nValue < nTotl //header value cannot be less than total amount by lines
			lRet := .F.
			RU06D05514_ShowHelp(8)
		EndIf
	EndIf
Return lRet

Static Function RU06D05518_Check_HeaderVATAMT(nValue, oModelHdr, oModelVirt)
	Local lRet    As Logical
	Local nTotl   As Logical
	lRet := .T.
	If nValue < 0 // value cannot be negative
		lRet := .F.
		RU06D05514_ShowHelp(9)
	EndIf
	If lRet
		nTotl := RU06D07E7_RetTotalsForHeader(oModelVirt, "VRT", .F.)[2]
		If nValue < nTotl //header VATAMT cannot be less than total amount by lines
			lRet := .F.
			RU06D05514_ShowHelp(8)
		EndIf
	EndIf
Return lRet                   
//Merge Russia R14 
                   
