#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RU06D07.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"


/*{Protheus.doc} RU06D07EventRUS
@type 		class
@author 	natasha
@version 	1.0
@since		27.04.2018
@description class for RU06D07
*/

Class RU06D07EventRUS From FwModelEvent 

	Method New() CONSTRUCTOR
	Method GridLinePosVld()
	Method GridLinePreVld()
	Method BeforeTTS()
	Method Activate()
	Method ModelPosVld()

EndClass


/*{Protheus.doc} RU06D07EventRUS
@type 		method
@author 	natasha
@version 	1.0
@since		27.04.2018
@description Basic constructor. 
*/
Method New() Class RU06D07EventRUS
Return Nil


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld

<Short description>

@param       <Parameter type> <Parameter name>
@return      Logical          lRet
@example     
@author      astepanov
@since       August/01/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Method GridLinePosVld(oSubModel, cModelID, nLine)                     Class RU06D07EventRUS

	Local lRet       As Logical
	Local oModel     As Object
	local oMdlHdr    As Object

	lRet := .T.
	oModel  := oSubModel:GetModel()
	oMdlHdr := oModel:GetModel("RU06D07_MHEAD")
	If cModelID == "RU06D07_MVIRT"
		If !oSubModel:IsEmpty() .AND. !oSubModel:IsDeleted()
			lRet := RU06D07E9_UpdateF5MLine(oSubModel, oMdlHdr, "UPDATE")
		EndIf
	EndIf
	
Return (lRet) /*-----------------------------------------------------------GridLinePosVld*/



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld METHOD

<Short description>

@param       <Parameter type> <Parameter name>
@return      Logical          lRet
@example     
@author      astepanov
@since       July/26/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Method GridLinePreVld(oSubModel, cModelID, nLine,;
                      cAction, cID, xNVal, xCVal)                      Class RU06D07EventRUS

    Local lRet       As Logical
	Local lInflow    As Logical
	Local oModel     As Object
	Local oMdlHdr    As Object
	Local nValue     As Numeric
	Local nVATAMT    As Numeric
	Local nDiffVA    As Numeric
	Local aNewCnvVal As Array
	Local aTmp       As Array
	Static lAtUpdExRt  := .F.
	Static lAtUpdValP  := .F.
	Static lAtUpdCnv   := .F.
	lRet := .T.

	oModel  := oSubModel:GetModel()
	oMdlHdr := oModel:GetModel("RU06D07_MHEAD")
	oMdlVrt := oModel:GetModel("RU06D07_MVIRT")
	lInflow := (oMdlHdr:GetValue("F4C_OPER") == "1")
	If cModelID == "RU06D07_MVIRT" .AND. cAction == "CANSETVALUE" .AND.;
		(cID == "B_CHECK" .OR. cID == "B_EXGRAT")
		// We can change B_CHECK when B_CURREN != F4C_CURREN
		If !(RU06D06011_CanChangeExchangeRateInLine(oMdlVrt,oMdlHdr))
			lRet := .F.
			RU06D05514_ShowHelp(1)
		EndIf
	EndIf
	If cModelID == "RU06D07_MVIRT" .AND. cAction == "SETVALUE"
		If !oSubModel:IsEmpty()
			If     cID == "B_CHECK"
				If xNVal == .F. .AND. xCVal == .T.
					lRet := lRet .AND. RU06D07047_AskAboutUncheckManualExRate(oMdlHdr:GetValue("F4C_DTTRAN"))
					lAskAMErRU := .F.
				EndIf
				If lRet .AND. RU06D05516_CanAutoUpdateExchangeRate(xNVal,xCVal)
					// we autoupdate exchange rate to default value
					// we set static lAtUpdExRt equal .T., because when we change
					// exchange rate automatically we should leave B_CHECK as .F.
					lAtUpdExRt := .T.
					lRet := oSubModel:SetValue("B_EXGRAT",RU06D05508_RetExgRat(oMdlVrt, oMdlHdr))
					lAtUpdExRt := .F.
				EndIf
				lRet := lRet .AND. oSubModel:SetValue("B_RATUSR", IIF(xNVal,"1","0"))
			ElseIf cID == "B_EXGRAT"
				lRet := lRet .AND. RU06D07046_AskAboutManualExRate()
				If xNVal <= 0 //B_EXGRAT should be > 0
					lRet := .F.
					RU06D05514_ShowHelp(4)
				EndIf
				If lRet .AND. lAtUpdExRt == .F.
					// load value for excluding recursion
					lRet := oSubModel:LoadValue("B_CHECK",.T.)
					lRet := lRet .AND. oSubModel:LoadValue("B_RATUSR","1")
				EndIf
				If lRet
					If AllTrim(oMdlVrt:GetValue("B_TYPE")) $ "PA|RA" .AND. oMdlVrt:GetValue("B_CURREN") != Val(oMdlHdr:GetValue("F4C_CURREN"))
						//in case we change exchange rate for advance line we change B_VALPAY
						lAtUpdValP := .T. //set .T. we don't update cnv values when set Valpay
						If lAtUpdCnv == .F.
							lRet := oSubModel:SetValue("B_VALPAY",RU06D07041_GetNewValpay(oMdlVrt:GetValue("B_VALCNV"),xNVal))
						EndIf
						lAtUpdValP := .F.
						nVATAMT := Round(oMdlVrt:GetValue("B_VLVATC")/xNVal,GetSX3Cache("E2_VALIMP1","X3_DECIMAL"))
						lRet := lRet .AND. oSubModel:LoadValue("B_VLIMP1",nVATAMT)
						lRet := lRet .AND. oSubModel:LoadValue("B_BSIMP1",oMdlVrt:GetValue("B_VALPAY") - nVATAMT)
					Else
						If lAtUpdCnv == .F.
							aNewCnvVal := RU06XFUN81_RetCnvValues(oMdlVrt:GetValue("B_VALPAY"),oMdlVrt:GetValue("B_VLIMP1"),xNVal,GetSX3Cache("F5M_VALCNV","X3_DECIMAL"))
							AADD(aNewCnvVal,oMdlVrt:GetValue("B_VLIMP1"))
							AADD(aNewCnvVal,oMdlVrt:GetValue("B_BSIMP1"))
							lRet := RU06D05510_LoadNewCnvValues(oMdlVrt,oMdlHdr,aNewCnvVal)
							lRet := lRet .AND. RU06D05511_UpdateReason()
						EndIf
					EndIf
				EndIf
			ElseIf cID == "B_VALPAY"
				If xNVal <= 0 // B_VALPAY should be > 0
					lRet := .F.
					RU06D05514_ShowHelp(4)
				EndIf
				If lRet
					If AllTrim(oMdlVrt:GetValue("B_TYPE")) $ "PA|RA"
						lRet := lRet .AND. oSubModel:LoadValue("B_OPBAL",xNVal)
						lRet := lRet .AND. oSubModel:LoadValue("B_VALUE",xNVal)
						If lRet .AND. lAtUpdValP == .F.
							aNewCnvVal := {}
							nVATAMT    := oMdlVrt:GetValue("B_VLVATC")
							If oMdlVrt:GetValue("B_CURREN") != Val(oMdlHdr:GetValue("F4C_CURREN"))
								If lAtUpdCnv == .F.
									lRet := lRet .AND. RU06D07046_AskAboutManualExRate()
									lRet := lRet .AND. oSubModel:LoadValue("B_EXGRAT",RU06D07042_GetNewExgrat(oMdlVrt:GetValue("B_VALCNV"),xNVal))
								EndIf
								AADD(aNewCnvVal, oMdlVrt:GetValue("B_VALCNV"))
								AADD(aNewCnvVal, nVATAMT)
								AADD(aNewCnvVal, oMdlVrt:GetValue("B_VALCNV") - nVATAMT)
							Else
								AADD(aNewCnvVal, xNVal)
								nVATAMT := RU06XFUN18_VATFormula(xNVal,{oMdlHdr:GetValue("F4C_VATRAT"),100},GetSX3Cache("F5M_VLVATC", "X3_DECIMAL"),.T.)
								AADD(aNewCnvVal, nVATAMT)
								AADD(aNewCnvVal, xNVal - nVATAMT)
							EndIf
							nVATAMT := Round(nVATAMT/oMdlVrt:GetValue("B_EXGRAT"),GetSX3Cache("E2_VALIMP1","X3_DECIMAL"))
							AADD(aNewCnvVal, nVATAMT)
							AADD(aNewCnvVal, xNVal - nVATAMT)
						EndIf
						If oMdlVrt:GetValue("B_CURREN") != Val(oMdlHdr:GetValue("F4C_CURREN"))
							If lAtUpdCnv == .F.
								lRet := lRet .AND. oSubModel:LoadValue("B_CHECK",.T.)
								lRet := lRet .AND. oSubModel:LoadValue("B_RATUSR","1")
							EndIf
							lRet := lRet .AND. oSubModel:LoadValue("B_VLCRUZ",oMdlVrt:GetValue("B_VALCNV"))
						Else
							lRet := lRet .AND. oSubModel:LoadValue("B_VLCRUZ",xMoeda(xNVal,oMdlVrt:GetValue("B_CURREN"),1,oMdlHdr:GetValue("F4C_DTTRAN"),TamSx3("E2_VLCRUZ")[2]))
						EndIf
						If lRet .AND. aNewCnvVal != Nil
							lRet := RU06D05510_LoadNewCnvValues(oMdlVrt,oMdlHdr,aNewCnvVal)
							lRet := lRet .AND. RU06D05511_UpdateReason()
						EndIf
					Else
						//check B_OPBAL and update it if it was changed
						aTmp := RU06XFUN50_RetVATSaldoValues(oMdlVrt,oMdlHdr)
						nValue := IIF(lRet,aTmp[1],oMdlVrt:GetValue("B_OPBAL"))
						If lRet .AND. (oMdlVrt:GetValue("B_OPBAL") != nValue)
							lRet := oMdlVrt:LoadValue("B_OPBAL", nValue)
						EndIf
						If lRet .AND. (nValue < xNVal) //B_OPBAL less than available balance
							lRet := .F.
							RU06D05514_ShowHelp(3)
						EndIf
						nVATAMT := Nil
						If lRet .AND. (nValue == xNVal) //B_OPBAL == Valpay, so we set to  VAT amount VAT saldo
							nVATAMT := aTmp[2]
						EndIf
						If lRet //change values in cnv values
							If nVATAMT != Nil
								aNewCnvVal := RU06XFUN81_RetCnvValues(xNVal,nVATAMT,oMdlVrt:GetValue("B_EXGRAT"),GetSX3Cache("F5M_VALCNV","X3_DECIMAL"))	
								AADD(aNewCnvVal,nVATAMT)
								AADD(aNewCnvVal,xNVal - nVATAMT)
							Else
								aNewCnvVal := RU06D05509_GetNewCnvValues(oMdlVrt:GetValue("B_EXGRAT"),xNVal,oMdlVrt,oMdlHdr)
							EndIf
							lRet := RU06D05510_LoadNewCnvValues(oMdlVrt,oMdlHdr,aNewCnvVal)
							lRet := lRet .AND. RU06D05511_UpdateReason() //check this fun
						EndIf
					EndIf
				EndIf
			ElseIf cID == "B_VALCNV"
				If AllTrim(oMdlVrt:GetValue("B_TYPE")) $ "PA|RA"
					If oMdlVrt:GetValue("B_CURREN") != Val(oMdlHdr:GetValue("F4C_CURREN"))
						lAtUpdCnv := .T.
						lRet := lRet .AND. oSubModel:SetValue("B_EXGRAT",RU06D07042_GetNewExgrat(xNVal,oMdlVrt:GetValue("B_VALPAY")))
						lAtUpdCnv := .F.
						aNewCnvVal := RU06D07045_GetVLVATC_BSVATCforPA(xNVal,oMdlVrt,oMdlHdr)
						lRet := lRet .AND. oSubModel:LoadValue("B_VLCRUZ",xNVal)
					Else
						lAtUpdCnv  := .T.
						lRet    := lRet .AND. oSubModel:SetValue("B_VALPAY",RU06D07041_GetNewValpay(xNVal,oMdlVrt:GetValue("B_EXGRAT")))
						lAtUpdCnv  := .F.
						lRet := lRet .AND. oSubModel:LoadValue("B_VLCRUZ",xMoeda(oMdlVrt:GetValue("B_VALPAY"),oMdlVrt:GetValue("B_CURREN"),1,oMdlHdr:GetValue("F4C_DTTRAN"),TamSx3("E2_VLCRUZ")[2]))
					EndIf
				Else
					If oMdlVrt:GetValue("B_CURREN") == Val(oMdlHdr:GetValue("F4C_CURREN")) // for identical currencies we set Valpay same to Valcnv
						lRet := oSubModel:SetValue("B_VALPAY",xNVal)
					Else
						lAtUpdCnv := .T.
						lRet := lRet .AND. oSubModel:SetValue("B_EXGRAT",RU06D07042_GetNewExgrat(xNVal,oMdlVrt:GetValue("B_VALPAY")))
						lAtUpdCnv := .F.
						aNewCnvVal := RU06D07043_GetVLVATC_BSVATC(xNVal,oMdlVrt,oMdlHdr)
					EndIf
				EndIf
				If aNewCnvVal != Nil
					lRet := lRet .AND. RU06D05510_LoadNewCnvValues(oMdlVrt,oMdlHdr,aNewCnvVal)
					lRet := lRet .AND. RU06D05511_UpdateReason()
				EndIf
			ElseIf cID == "B_BSVATC"
				If lRet .AND. xNVal > oMdlVrt:GetValue("B_VALCNV")
					lRet := .F.
					RU06D05514_ShowHelp(6)
				EndIf
				If lRet .AND. xNVal < 0 //value should be equal 0 or more
					lRet := .F.
					RU06D05514_ShowHelp(9)	
				EndIf
				If lRet
					nVATAMT := oMdlVrt:GetValue("B_VLIMP1")
					If AllTrim(oMdlVrt:GetValue("B_TYPE")) $ "PA|RA" .OR. oMdlVrt:GetValue("B_CURREN") == Val(oMdlHdr:GetValue("F4C_CURREN"))
						nVATAMT := Round((oMdlVrt:GetValue("B_VALCNV") - xNVal)/oMdlVrt:GetValue("B_EXGRAT"),GetSX3Cache("E2_VALIMP1","X3_DECIMAL"))
						lRet := lRet .AND. oMdlVrt:SetValue("B_VLIMP1",nVATAMT)
						If AllTrim(oMdlVrt:GetValue("B_TYPE")) $ "PA|RA" .AND. oMdlVrt:GetValue("B_CURREN") != Val(oMdlHdr:GetValue("F4C_CURREN"))
							lRet := RU06D07044_ChangeHdrVATAMT("B_BSVATC",xNVal,xCVal,oMdlVrt,oMdlHdr)
						EndIf
					Else
						lRet := RU06D07044_ChangeHdrVATAMT("B_BSVATC",xNVal,xCVal,oMdlVrt,oMdlHdr)
					EndIf
				EndIf
			ElseIf cID == "B_VLVATC"
				If lRet .AND. xNVal > oMdlVrt:GetValue("B_VALCNV")
					lRet := .F.
					RU06D05514_ShowHelp(5)
				EndIf
				If lRet .AND. xNVal < 0 //value should be equal 0 or more
					lRet := .F.
					RU06D05514_ShowHelp(9)	
				EndIf
				If lRet
					nVATAMT := oMdlVrt:GetValue("B_VLIMP1")
					If AllTrim(oMdlVrt:GetValue("B_TYPE")) $ "PA|RA" .OR. oMdlVrt:GetValue("B_CURREN") == Val(oMdlHdr:GetValue("F4C_CURREN"))
						nVATAMT := Round(xNVal/oMdlVrt:GetValue("B_EXGRAT"),GetSX3Cache("E2_VALIMP1","X3_DECIMAL"))
						lRet := lRet .AND. oMdlVrt:SetValue("B_VLIMP1",nVATAMT)
						If AllTrim(oMdlVrt:GetValue("B_TYPE")) $ "PA|RA" .AND. oMdlVrt:GetValue("B_CURREN") != Val(oMdlHdr:GetValue("F4C_CURREN"))
							lRet := RU06D07044_ChangeHdrVATAMT("B_VLVATC",xNVal,xCVal,oMdlVrt,oMdlHdr)
						EndIf
					Else
						lRet := RU06D07044_ChangeHdrVATAMT("B_VLVATC",xNVal,xCVal,oMdlVrt,oMdlHdr)
					EndIf
				EndIf
			ElseIf cID == "B_BSIMP1"
				If lRet .AND. xNVal > oMdlVrt:GetValue("B_VALPAY")
					lRet := .F.
					RU06D05514_ShowHelp(5)
				EndIf
				If lRet .AND. xNVal < 0 //value should be equal 0 or more
					lRet := .F.
					RU06D05514_ShowHelp(9)	
				EndIf
				If lRet
					If oMdlVrt:GetValue("B_CURREN") == Val(oMdlHdr:GetValue("F4C_CURREN")) .OR.;
						(!(AllTrim(oMdlVrt:GetValue("B_TYPE")) $ "PA|RA") .AND. oMdlVrt:GetValue("B_CURREN") != Val(oMdlHdr:GetValue("F4C_CURREN")))
						aNewCnvVal := RU06XFUN81_RetCnvValues(oMdlVrt:GetValue("B_VALPAY"),oMdlVrt:GetValue("B_VALPAY") - xNVal,oMdlVrt:GetValue("B_EXGRAT"),GetSX3Cache("F5M_VALCNV","X3_DECIMAL"))	
						AADD(aNewCnvVal,oMdlVrt:GetValue("B_VALPAY") - xNVal)
						AADD(aNewCnvVal,xNVal)
						lRet := lRet .AND. RU06D05510_LoadNewCnvValues(oMdlVrt,oMdlHdr,aNewCnvVal)
						lRet := lRet .AND. RU06D05511_UpdateReason()
					EndIf
					lRet := lRet .AND. oMdlVrt:LoadValue("B_VLIMP1",oMdlVrt:GetValue("B_VALPAY") - xNVal)
				EndIf
			ElseIf cID == "B_VLIMP1"
				If lRet .AND. xNVal > oMdlVrt:GetValue("B_VALPAY")
					lRet := .F.
					RU06D05514_ShowHelp(5)
				EndIf
				If lRet .AND. xNVal < 0 //value should be equal 0 or more
					lRet := .F.
					RU06D05514_ShowHelp(9)	
				EndIf
				If lRet
					If oMdlVrt:GetValue("B_CURREN") == Val(oMdlHdr:GetValue("F4C_CURREN")) .OR.;
						(!(AllTrim(oMdlVrt:GetValue("B_TYPE")) $ "PA|RA") .AND. oMdlVrt:GetValue("B_CURREN") != Val(oMdlHdr:GetValue("F4C_CURREN")))
						aNewCnvVal := RU06XFUN81_RetCnvValues(oMdlVrt:GetValue("B_VALPAY"),xNVal,oMdlVrt:GetValue("B_EXGRAT"),GetSX3Cache("F5M_VALCNV","X3_DECIMAL"))	
						AADD(aNewCnvVal,xNVal)
						AADD(aNewCnvVal,oMdlVrt:GetValue("B_VALPAY") - xNVal)
						lRet := lRet .AND. RU06D05510_LoadNewCnvValues(oMdlVrt,oMdlHdr,aNewCnvVal)
						lRet := lRet .AND. RU06D05511_UpdateReason()
					EndIf
					lRet := lRet .AND. oMdlVrt:LoadValue("B_BSIMP1",oMdlVrt:GetValue("B_VALPAY") - xNVal)
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
	If cModelID == "RU06D07_MVIRT" .AND. (cAction == "DELETE" .OR. cAction == "UNDELETE")
		lRet    := RU06D07E9_UpdateF5MLine(oSubModel, oMdlHdr, cAction)
		If lRet
			If lInflow
				nValue  := oMdlHdr:GetValue("F4C_ITTOTA" )
				nVATAMT := oMdlHdr:GetValue("F4C_ITVATF")
				nDiffVA := oMdlHdr:GetValue("F4C_ITVATO")
			Else
				nValue  := oMdlHdr:GetValue("F4C_VALUE" )
				nVATAMT := oMdlHdr:GetValue("F4C_VATAMT")
			EndIf
			If     cAction == "DELETE"
				nValue  := nValue  - oSubModel:GetValue("B_VALCNV")
				nVATAMT := nVATAMT - oSubModel:GetValue("B_VLVATC")
				If lInflow
					nDiffVA	:= nDiffVA - Round(oSubModel:GetValue("B_VLVATC")/RecMoeda(oMdlHdr:GetValue("F4C_DTTRAN"),Val(oMdlHdr:GetValue("F4C_CURREN"))),TamSx3("F4C_ITVATO")[2])
				EndIf
			ElseIf cAction == "UNDELETE"
				nValue  := nValue  + oSubModel:GetValue("B_VALCNV")
				nVATAMT := nVATAMT + oSubModel:GetValue("B_VLVATC")
				If lInflow
					nDiffVA	:= nDiffVA + Round(oSubModel:GetValue("B_VLVATC")/RecMoeda(oMdlHdr:GetValue("F4C_DTTRAN"),Val(oMdlHdr:GetValue("F4C_CURREN"))),TamSx3("F4C_ITVATO")[2])
				EndIf
				lRet    := lRet .AND. RU06D07E9_UpdateF5MLine(oSubModel, oMdlHdr, "UPDATE")
			EndIf
			If lInflow
				lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_ITTOTA", nValue )
				lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_ITBALA", oMdlHdr:GetValue("F4C_VALUE" ) - oMdlHdr:GetValue("F4C_ITTOTA" ))
				lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_ITVATF",nVATAMT)
				lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_ITVATO",nDiffVA)
			Else
				lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_VALUE", nValue )
				lRet    := lRet .AND. oMdlHdr:LoadValue("F4C_VATAMT",nVATAMT)
			EndIf
			RU06D0717_Rsn(,nLine,cAction)
			oSubModel:GoLine(nLine)
			RU06D07054_UpdateViews()
		EndIf
	EndIf
Return (lRet) /*-----------------------------------------------------------GridLinePreVld>*/


/*{Protheus.doc} RU06D07EventRUS
@type 		method
@author 	natasha
@version 	1.0
@since		27.04.2018
@description field prevalidation 
*/

Method BeforeTTS(oModel, cModelID) Class RU06D07EventRUS
Local lNewBS 		as Logical
Local oModelF4C 	as Object
Local cNumStt 		as Character
Local aArea 		as Array

aArea:= GetArea()

oModelF4C:=oModel:GetModel("RU06D07_MHEAD")
lNewBS:=oModel:GetOperation()==MODEL_OPERATION_INSERT .or. oModel:GetOperation()==9 // Insert or Copy
 
If lNewBS
	cNumStt:=RU09D03NMB("BNKSTM")
	oModelF4C:LoadValue("F4C_INTNUM",cNumStt)
	If !IsBlind() .And. !RU06D07740_GetAutoBs()
		MsgInfo(STR0017 + alltrim(cNumStt) + STR0032) // BS ## created
	EndIf
EndIf

RestArea(aArea)
Return (.T.)

Method Activate(oModel, lCopy) Class RU06D07EventRUS

	Local oView    as Object
	Local oMdlVrt  as Object
	Local oMdlF4C  as Object
	Local nPos     as Numeric
	Local nTotDiff as Numeric
	Local nVATDiff as Numeric
	Local nX       as Numeric

	oMdlVrt := oModel:GetModel("RU06D07_MVIRT")
	oMdlF4C := oModel:GetModel("RU06D07_MHEAD")

	oView:= FWViewActive()
	If ValType(oView) == "O" .AND. oView:GetModel():GetId()=="RU06D07"
		RU06D0748_ViewConfig(oView)
	EndIf

	//added according to JIRA task: 
	//https://jiraproducao.totvs.com.br/browse/RULOC-456
	If oMdlF4C:GetValue("F4C_OPER") == "2" .AND. oMdlF4C:GetValue("F4C_ADVANC") == "1"
		// Outflow and only prepayment
		// When we copy BS, we don't copy F5M lines
		// so we are in case when SUM(F5M_VALCNV) != F4C_VALUE.
		// We need to check this case and return a help message to the user
		// if we are in.
		nPos := oMdlVrt:GetLine()
		nTotDiff := oMdlF4C:GetValue("F4C_VALUE")
		nVATDiff := oMdlF4C:GetValue("F4C_VATAMT")
		For nX := 1 To oMdlVrt:Length()
			oMdlVrt:GoLine(nX)
			If !oMdlVrt:IsDeleted()
				nTotDiff -= oMdlVrt:GetValue("B_VALCNV")
				nVATDiff -= oMdlVrt:Getvalue("B_VLVATC")
			EndIf
		Next nX
		oMdlVrt:GoLine(nPos)
		If nTotDiff != 0 .OR. nVATDiff != 0
			HELP("",1,  STR0017 + STR0052,,; //BS - information
			STR0078+cValToChar(nTotDiff)+;   //BS value exceeds total amount by lns on:
			STR0079+cValToChar(nVATDiff),;   //incl. VAT: 
			1,0,,,,,,;
			{STR0202})
		//STR0202:
		//If you do not wish to change the value of prepayment, nevertheless 
		//you should go to the folder "Values", change the total value to any 
		//other and then to change it back.
		EndIf
	EndIf

	//Lock virtual grid for adding new lines
	oMdlVrt:SetNoInsertLine(.T.)

Return (Nil)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld

Model pos validation method

@param       Object           oModel
             Character        cModelID
@return      Logical          lRet
@example     
@author      astepanov
@since       May/07/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Method ModelPosVld(oModel, cModelID) Class RU06D07EventRUS

	Local lRet       As Logical
	Local oMdlVrt    As Object
	Local oMdlF4C    As Object
	Local nX         As Numeric
	Local nPos       As Numeric
	Local nVATDiff   As Numeric
	Local nTotDiff   As Numeric
	Local cAdvFlgFld As Character
	Local cAdvTipo   As Character

	lRet := .T.

	If cModelID == "RU06D07"
		cAdvFlgFld := "F4C_ADVANC"
		If oModel:GetValue("RU06D07_MHEAD", "F4C_OPER") == "1"      // Inflow
			cAdvTipo   := "RA"
			If Empty(oModel:GetValue("RU06D07_MHEAD" , "F4C_CUST")) .OR.;
			   Empty(oModel:GetValue("RU06D07_MHEAD", "F4C_CUNI"))
				oModel:SetErrorMessage("RU06D07_MHEAD", "F4C_CUST",;
				                       "RU06D07_MHEAD", "F4C_CUST",;
									   "RU06D07_CustEmpty"        ,;
									   STR0101  /*Customer Empty*/,; 
									   STR0102) /*In an Inflow Bank 
									              statement we must have 
									              a customer*/
				lRet := .F.
			EndIf
		ElseIf oModel:GetValue("RU06D07_MHEAD", "F4C_OPER") == "2"  // Outflow
			cAdvTipo   := "PA"
			If Empty(oModel:GetValue("RU06D07_MHEAD", "F4C_SUPP")) .OR.;
			   Empty(oModel:GetValue("RU06D07_MHEAD", "F4C_UNIT"))
				oModel:SetErrorMessage("RU06D07_MHEAD", "F4C_SUPP" ,;
				                       "RU06D07_MHEAD", "F4C_SUPP" ,;
									   "RU06D07_SuppEmpty"         ,;
									    STR0098  /*Supplier Empty*/,;
										STR0099) /*In an Outflow Bank 
										           statement we must have
										           a Supplier*/
				lRet := .F.
			Endif
		EndIf
		If lRet .AND. !Empty(cAdvFlgFld) .AND.;
		   oModel:GetValue("RU06D07_MHEAD", cAdvFlgFld) == "2"
			oMdlVrt := oModel:GetModel("RU06D07_MVIRT")
			lRet := .F.
			nPos := oMdlVrt:GetLine()
			For nX := 1 To oMdlVrt:Length()
				oMdlVrt:GoLine(nX)
				If !oMdlVrt:IsDeleted() .AND.;
					!(Empty(oMdlVrt:GetValue("B_TYPE"))) .AND.;
					!(AllTrim(oMdlVrt:GetValue("B_TYPE")) == cAdvTipo)
					lRet := .T.
					Exit
				EndIf
			Next nX
			oMdlVrt:GoLine(nPos)
			If !lRet
			HELP("",1,  STR0017 + STR0052,,; //BS - information
				STR0180,;                    // Need 1 or more postpayment APs
				1,0,,,,,,;
				{STR0181})                   //Please add AP
			EndIf
		EndIf
	EndIf

	If lRet .AND. cModelID == "RU06D07"
		oMdlVrt := oModel:GetModel("RU06D07_MVIRT")
		oMdlF4C := oModel:GetModel("RU06D07_MHEAD")
		If oMdlF4C:GetValue("F4C_OPER") == "1"      // Inflow
			If (oMdlF4C:GetValue("F4C_ITBALA") < 0)
				HELP("",1,  STR0017 + STR0052,,; //BS - information
					 STR0128,;  //The sum of the accounts paybles 
					 1,0,,,,,,; //is higher than the amount in the header
					 {}) //Solution
				lRet := .F.
			EndIf
			//If ITBALA > 0 we add new RA line
			If lRet .AND. (oMdlF4C:GetValue("F4C_ITBALA") > 0)
				// After adding new RA Line VAT difference should be equal 0
				lRet := RU06D07012_CommitRALine(oModel)
			EndIf
			//case "F4C_ITVATF - F4C_VATAMT must be equal 0" for InflowBS removed according to:
			//https://jiraproducao.totvs.com.br/browse/RULOC-3016
		EndIf
		If oMdlF4C:GetValue("F4C_OPER") == "2"      // Outflow
			// When we copy BS, we don't copy F5M lines
			// so we are in case when SUM(F5M_VALCNV) != F4C_VALUE.
			// We need to check this case and return a help message to the user
			// if we are in.
			nPos := oMdlVrt:GetLine()
			nTotDiff := oMdlF4C:GetValue("F4C_VALUE")
			nVATDiff := oMdlF4C:GetValue("F4C_VATAMT")
			For nX := 1 To oMdlVrt:Length()
				oMdlVrt:GoLine(nX)
				If !oMdlVrt:IsDeleted()
					nTotDiff -= oMdlVrt:GetValue("B_VALCNV")
					nVATDiff -= oMdlVrt:Getvalue("B_VLVATC")
				EndIf
			Next nX
			oMdlVrt:GoLine(nPos)
			If nTotDiff != 0 .OR. nVATDiff != 0
				HELP("",1,  STR0017 + STR0052,,; //BS - information
				STR0078+cValToChar(nTotDiff)+;   //BS value exceeds total amount by lns on:
				STR0079+cValToChar(nVATDiff),;   //incl. VAT: 
				1,0,,,,,,;
				{STR0072})                       //Please check the data
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
Return (lRet) /*---------------------------------------------------------------ModelPosVld*///------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07041_GetNewValpay
Calculate new B_VALPAY
@param       Numeric          nCnvVal   B_VALCNV value
             Numeric          nExgrat   exchange rate value
@return      Numeric          nRet
@author      astepanov
@since       June/01/2021
@project     MA3
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07041_GetNewValpay(nCnvVal,nExgrat)
	Local nRet As Numeric
	nRet := Round(nCnvVal/nExgRat,GetSX3Cache("F5M_VALPAY","X3_DECIMAL"))
Return nRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07042_GetNewExgrat
Calculate new B_EXGRAT
@param       Numeric          nCnvVal   B_VALCNV value
             Numeric          nValpay   B_VALPAY value
@return      Numeric          nRet
@author      astepanov
@since       June/01/2021
@project     MA3
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07042_GetNewExgrat(nCnvVal,nValpay)
	Local nRet As Numeric
	nRet := Round(nCnvVal/nValpay,GetSX3Cache("F4B_EXGRAT","X3_DECIMAL"))
Return nRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07043_GetVLVATC_BSVATC
Calculate new B_VALCNV, B_VLVATC, B_BSVATC
@param       Numeric          nCnvVal   B_VALCNV value
             Object           oMdlVrt   Vrt grid model
             Object           oMdlHdr   Header model
@return      Array            aRet {B_VALCNV, B_VLVATC, B_BSVATC, B_VLIMP1, B_BSIMP1}
@author      astepanov
@since       June/01/2021
@project     MA3
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07043_GetVLVATC_BSVATC(nCnvVal,oMdlVrt,oMdlHdr)
	Local aRet As Array
	Local nVATRAT As Numeric
	Local nNewVAT As Numeric
	aRet    := {}
	AADD(aRet, nCnvVal) //B_VALCNV
	nVATRAT := IIF(Empty(oMdlHdr:GetValue("F4C_VATRAT")),0,oMdlHdr:GetValue("F4C_VATRAT"))
    nNewVAT := RU06XFUN18_VATFormula(nCnvVal,{nVATRAT,100},GetSX3Cache("F5M_VLVATC", "X3_DECIMAL"),.T.)
	AADD(aRet, nNewVAT) //B_VLVATC
	AADD(aRet, nCnvVal - nNewVAT) //B_BSVATC
	AADD(aRet, oMdlVrt:GetValue("B_VLIMP1")) //B_VLIMP1
	AADD(aRet, oMdlVrt:GetValue("B_BSIMP1")) //B_BSIMP1
Return aRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07044_ChangeHdrVATAMT
Function changes F4C_VATAMT after changing B_BSVATC or B_VLVATC and updates
F4C_REASON
@param       Character        cField    "B_VLVATC" or "B_BSVATC"
             Numeric          xNVal     new value for cField
             Numeric          xCVal     current value for cField
             Object           oMdlVrt   Vrt grid model
             Object           oMdlHdr   Header model
@return      Logical          lRet
@author      astepanov
@since       June/01/2021
@project     MA3
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07044_ChangeHdrVATAMT(cField,xNVal,xCVal,oMdlVrt,oMdlHdr)
	Local lRet := .T.
	If     cField == "B_VLVATC"
		lRet := oMdlVrt:LoadValue("B_BSVATC",oMdlVrt:GetValue("B_VALCNV") - xNVal)
		lRet := lRet .AND. oMdlHdr:LoadValue("F4C_VATAMT",oMdlHdr:GetValue("F4C_VATAMT")+(xNVal-xCVal))
	ElseIf cField == "B_BSVATC"
		lRet := oMdlVrt:LoadValue("B_VLVATC",oMdlVrt:GetValue("B_VALCNV") - xNVal)
		lRet := lRet .AND. oMdlHdr:LoadValue("F4C_VATAMT",oMdlHdr:GetValue("F4C_VATAMT")+(xCVal-xNVal))	
	EndIf
	lRet := lRet .AND. RU06D05511_UpdateReason()
Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07045_GetVLVATC_BSVATCforPA
Calculate new B_VALCNV, B_VLVATC, B_BSVATC, B_VLIMP1 and B_BSIMP1 for PA
@param       Numeric          nCnvVal   B_VALCNV value
             Object           oMdlVrt   Vrt grid model
             Object           oMdlHdr   Header model
@return      Array            aRet {B_VALCNV, B_VLVATC, B_BSVATC, B_VLIMP1, B_BSIMP1}
@author      astepanov
@since       June/01/2021
@project     MA3
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07045_GetVLVATC_BSVATCforPA(nCnvVal,oMdlVrt,oMdlHdr)
	Local aRet      As Array
	Local nVATRAT   As Numeric
	Local nNewVAT   As Numeric
	Local nNewVLIMP As Numeric
	aRet    := {}
	AADD(aRet, nCnvVal) //B_VALCNV
	nVATRAT := IIF(Empty(oMdlHdr:GetValue("F4C_VATRAT")),0,oMdlHdr:GetValue("F4C_VATRAT"))
    nNewVAT := RU06XFUN18_VATFormula(nCnvVal,{nVATRAT,100},GetSX3Cache("F5M_VLVATC", "X3_DECIMAL"),.T.)
	AADD(aRet, nNewVAT) //B_VLVATC
	AADD(aRet, nCnvVal - nNewVAT) //B_BSVATC
	nNewVLIMP := ROUND(nNewVAT/oMdlVrt:GetValue("B_EXGRAT"),GetSX3Cache("E2_VALIMP1","X3_DECIMAL"))
	AADD(aRet, nNewVLIMP) //B_VLIMP1
	AADD(aRet, oMdlVrt:GetValue("B_VALPAY") - nNewVLIMP) //B_BSIMP1
Return aRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07046_AskAboutManualExRate
When we try to change exchange rate manually we ask about it, if
private var lAskAMErRU was set to .F., we don't ask.
@private     Logical            lAskAMErRU
@return      Logical            lRet // Result of MsgYesNo or .F.
@author      astepanov
@since       June/01/2021
@project     MA3
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07046_AskAboutManualExRate()
	Local lRet       As Logical
	lRet  := .T.
	lAsk  := .T.
	If Type("lAskAMErRU") == "L"
		lAsk := lAskAMErRU
	EndIf
	If lAsk .AND. !IsBlind() .And. !RU06D07740_GetAutoBs()
		lRet := MsgYesNo(STR0211,STR0210) // --Currency rate
	EndIf
Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07047_AskAboutUncheckManualExRate
When we try to uncheck flag for line with manually changed exchange rate we ask about
it, after that exchange rate and values related to it will be calculated automatically.
If private var lAskAMErRU was set to .F., we don't ask.
@param       Date               dDate // date which will be used for currency rate
@private     Logical            lAskAMErRU
@return      Logical            lRet // Result of MsgYesNo or .F.
@author      astepanov
@since       June/01/2021
@project     MA3
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07047_AskAboutUncheckManualExRate(dDate)
	Local lRet       As Logical
	lRet  := .T.
	lAsk  := .T.
	If Type("lAskAMErRU") == "L"
		lAsk := lAskAMErRU
	EndIf
	If lAsk .AND. !IsBlind() .And. !RU06D07740_GetAutoBs()
		lRet := MsgYesNo(STR0212+DTOC(dDate)+STR0213,STR0210) //--Currency rate
	EndIf
Return lRet

/*/{Protheus.doc} RU06D07054_UpdateViews
	This functon used for force update F4C fields when we delete or undelete lines
	in virtual grid. This function is abnormal, because system must automatically
	update views when we change field value.
	@type  Static Function
	@author astepanov
	@since 16/04/2024
	@version version
	@param Nil, Nil,
	@return Nil, Nil,
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RU06D07054_UpdateViews()
	Local oView As Object
	Local aViews As Array
	Local oMainField As Object
	oView	:= FWViewActive()
	If oView != Nil
		aViews := oView:AVIEWS
		If ASCAN(aViews[1], {|x| IIF(Valtype(x) == "C",x == "RU06D07_MHEAD",.F.)}) > 0
			oMainField:= oView:GetViewObj("RU06D07_MHEAD")[3]
			oMainField:Refresh( .T. /* lEvalChanges */, .F. /* lGoTop */)
		EndIf
	EndIf
Return Nil
                   
//Merge Russia R14 
                   
