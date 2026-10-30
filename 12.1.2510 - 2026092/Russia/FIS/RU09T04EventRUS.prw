#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'RU09T08.ch'
#Include "RU09T04.ch"
#include 'RU09XXX.ch'


/*{Protheus.doc} RU09T04EventRUS
@type 		class
@author Artem Kostin
@since 13/08/2018
@version 	P12.1.21
@description Class to handle business procces of RU09T04
*/
Class RU09T04EventRUS From FwModelEvent
	Method New() CONSTRUCTOR
	Method ModelPosVld()
	Method GridLinePreVld()
	Method GridLinePosVld()
	Method R09T4AInc(oModel)
	Method R09T4APay(oModel)
	Method R09T4ARec(oModel)
	Method Activate(oModel, lCopy)
	Method FillRecordOfSalesBook(oSubModel, oSalVatMvs, cTab, nLine)
	Method FillVATSalesBook(oSubModel, oSalVatMvs, cTab, nLine)
	Method RfrshF39Ttl(nValDiff)
	Method FillF3ATable(oSubModel, cTab)
	Method FillF63Table(oSubModel, cTab)
	Method GetSheetNumberTable(cTaxPrdBeg, cTaxPrdEnd, cInterCode)
	Method DeleteUndeleteUpdate(oSubModel, cKey, cAction)
	Method PrevalidateGridLine(oSubModel, cAction, cField, xValue)
	Method SetFieldsOfAdditionalSheet(cTab, oSubModel, aSheetNums)
EndClass


Method Activate(oModel, lCopy) Class RU09T04EventRUS
	Local lRet := .T.

	If (oModel:GetOperation()<>MODEL_OPERATION_INSERT .And. (F39->F39_STATUS $ "2|3| " .Or. F39->F39_AUTO == "1") .And. !(FwIsInCallStack("gravaBook")))
		oModel:GetModel("F3ADETAIL"):SetNoInsertLine()

		If (F39->F39_STATUS $ "2|3| ")
			oModel:GetModel("F3ADETAIL"):SetNoDeleteLine()
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} RU09T04EventRUS:New()
@type       method
@author     Artem Kostin
@since      27/07/2018
@version    P12.1.21
@description    Method - constructor of the class RU09T04EventRUS
*/
Method New() Class RU09T04EventRUS
Return Nil



/*{Protheus.doc} RU09T04EventRUS:ModelPosVld()
@type       method
@author     Artem Kostin
@since      08/08/2018
@version    P12.1.21
*/
Method ModelPosVld(oModel, cModelId) Class RU09T04EventRUS
	Local lRet := .T.

	Local nLine as Numeric
	Local oModelF39 := oModel:GetModel("F39MASTER")
	Local oModelF3A := oModel:GetModel("F3ADETAIL")
	Local oModelF54 := oModel:GetModel("F54DETAIL")
	Local oModelF63P := oModel:GetModel("F63PDETAIL")
	Local oModelF54P := oModel:GetModel("F54PDETAIL")
	Local oModelF63R := oModel:GetModel("F63RDETAIL")
	Local oModelF54R := oModel:GetModel("F54RDETAIL")
	Local nOperation := oModel:GetOperation()

	If (cModelId == 'RU09T04')
		For nLine := 1 to oModelF3A:Length()
			oModelF3A:GoLine(nLine)
			If !oModelF3A:IsDeleted() .and. ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE))

				//Filed code at F3A
				lRet := lRet .and. oModelF3A:LoadValue("F3A_CODE", oModelF39:GetValue("F39_CODE"))
				//F54 - type
				lRet := lRet .and. oModelF54:LoadValue("F54_TYPE", "02") //sales book
				// F54_FILIAL is in relations
				lRet := lRet .and. oModelF54:LoadValue("F54_DIRECT", "-")
				lRet := lRet .and. oModelF54:LoadValue("F54_DATE", oModelF39:GetValue("F39_FINAL"))
				// F54_TYPE is in relations
				lRet := lRet .and. oModelF54:LoadValue("F54_CLIENT", oModelF3A:GetValue("F3A_CLIENT"))
				lRet := lRet .and. oModelF54:LoadValue("F54_CLIBRA", oModelF3A:GetValue("F3A_BRANCH"))
				// F54_KEY is fullfiled in the function FillF53Table()
				lRet := lRet .and. oModelF54:LoadValue("F54_DOC", oModelF3A:GetValue("F3A_DOC"))
				lRet := lRet .and. oModelF54:LoadValue("F54_PDATE", oModelF3A:GetValue("F3A_PDATE"))
				// F54_VATCOD is in relations
				lRet := lRet .and. oModelF54:LoadValue("F54_VATBS", oModelF3A:GetValue("F3A_VATBS"))
				lRet := lRet .and. oModelF54:LoadValue("F54_VATRT", oModelF3A:GetValue("F3A_VATRT"))
				lRet := lRet .and. oModelF54:LoadValue("F54_VALUE", oModelF3A:GetValue("F3A_VATVL"))
				// F54_REGKEY is in relations
				lRet := lRet .and. oModelF54:LoadValue("F54_REGDOC", oModelF39:GetValue("F39_CODE"))
				lRet := lRet .and. oModelF54:LoadValue("F54_USER", __cUserID)

				lRet := lRet .and. oModelF54:LoadValue("F54_ORIGIN", "F35")
			EndIf

			If !lRet
				RU99XFUN05_Help(STR0008)
				Exit
			EndIf
		Next nLine

		For nLine := 1 to oModelF63P:Length()
			oModelF63P:GoLine(nLine)
			If !oModelF63P:IsDeleted() .and. ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE))

				//F54 - type
				lRet := lRet .and. oModelF54P:LoadValue("F54_TYPE", "02") //sales book
				// F54_FILIAL is in relations
				lRet := lRet .and. oModelF54P:LoadValue("F54_DIRECT", "-")
				lRet := lRet .and. oModelF54P:LoadValue("F54_DATE", oModelF39:GetValue("F39_FINAL"))
				// F54_TYPE is in relations
				lRet := lRet .and. oModelF54P:LoadValue("F54_CLIENT", oModelF63P:GetValue("F63_SUCL"))
				lRet := lRet .and. oModelF54P:LoadValue("F54_CLIBRA", oModelF63P:GetValue("F63_SUCLBR"))
				// F54_KEY is fullfiled in the function FillF53Table()
				lRet := lRet .and. oModelF54P:LoadValue("F54_DOC", oModelF63P:GetValue("F63_DOC"))
				lRet := lRet .and. oModelF54P:LoadValue("F54_PDATE", oModelF63P:GetValue("F63_PDATE"))
				// F54_VATCOD is in relations
				lRet := lRet .and. oModelF54P:LoadValue("F54_VATBS", oModelF63P:GetValue("F63_VATBS"))
				lRet := lRet .and. oModelF54P:LoadValue("F54_VATRT", oModelF63P:GetValue("F63_VATRT"))
				lRet := lRet .and. oModelF54P:LoadValue("F54_VALUE", oModelF63P:GetValue("F63_VATVL"))
				// F54_REGKEY is in relations
				lRet := lRet .and. oModelF54P:LoadValue("F54_REGDOC", oModelF39:GetValue("F39_CODE"))
				lRet := lRet .and. oModelF54P:LoadValue("F54_USER", __cUserID)

				lRet := lRet .and. oModelF54P:LoadValue("F54_ORIGIN", "F37")
			EndIf

			If !lRet
				RU99XFUN05_Help(STR0008)
				Exit
			EndIf
		Next nLine

		For nLine := 1 to oModelF63R:Length()
			oModelF63R:GoLine(nLine)
			If !oModelF63R:IsDeleted() .and. ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE))

				//F54 - type
				lRet := lRet .and. oModelF54R:LoadValue("F54_TYPE", "02") //sales book
				// F54_FILIAL is in relations
				lRet := lRet .and. oModelF54R:LoadValue("F54_DIRECT", "-")
				lRet := lRet .and. oModelF54R:LoadValue("F54_DATE", oModelF39:GetValue("F39_FINAL"))
				// F54_TYPE is in relations
				lRet := lRet .and. oModelF54R:LoadValue("F54_CLIENT", oModelF63R:GetValue("F63_SUCL"))
				lRet := lRet .and. oModelF54R:LoadValue("F54_CLIBRA", oModelF63R:GetValue("F63_SUCLBR"))
				// F54_KEY is fullfiled in the function FillF53Table()
				lRet := lRet .and. oModelF54R:LoadValue("F54_DOC", oModelF63R:GetValue("F63_DOC"))
				lRet := lRet .and. oModelF54R:LoadValue("F54_PDATE", oModelF63R:GetValue("F63_PDATE"))
				// F54_VATCOD is in relations
				lRet := lRet .and. oModelF54R:LoadValue("F54_VATBS", oModelF63R:GetValue("F63_VATBS"))
				lRet := lRet .and. oModelF54R:LoadValue("F54_VATRT", oModelF63R:GetValue("F63_VATRT"))
				lRet := lRet .and. oModelF54R:LoadValue("F54_VALUE", oModelF63R:GetValue("F63_VATVL"))
				// F54_REGKEY is in relations
				lRet := lRet .and. oModelF54R:LoadValue("F54_REGDOC", oModelF39:GetValue("F39_CODE"))
				lRet := lRet .and. oModelF54R:LoadValue("F54_USER", __cUserID)

				lRet := lRet .and. oModelF54R:LoadValue("F54_ORIGIN", "F35")
			EndIf

			If !lRet
				RU99XFUN05_Help(STR0008)
				Exit
			EndIf
		Next nLine
	EndIf
Return(lRet)

/*{Protheus.doc} GridLinePreVld
@description GridLinePreVld
@author Ruslan Burkov
@since 10/03/2018
@version 1.0
@project MA3 - Russia
*/
Method GridLinePreVld(oSubModel, cModelID, nLinVld, cAction, cField, xValue, xOldValue) Class RU09T04EventRUS
	Local lValid as Logical

	lValid := .T.
	// Prevent prevalidation from recursive calls
	If Type("lFirstCall") == "U"
		Private lFirstCall := .T.
	EndIf

	If lFirstCall
		// we need just one time to call this validation on delete
		lFirstCall := .F.
		// PrevalidateGridLine has oView:Refresh, so we don't need call it more.
		lValid := self:PrevalidateGridLine(oSubModel, cAction, cField, xValue)
	EndIf


Return lValid

/*{Protheus.doc} PrevalidateGridLine
@description Implementation of GridLinePreVld without useless params
@author alexander.ivanov
@since 26/11/2020
@version 1.0
@project MA3 - Russia
*/
Method PrevalidateGridLine(oSubModel, cAction, cField, xValue) Class RU09T04EventRUS
	Local aSavedRows as Array
	Local cKey       as Character
	Local cPrintDate as Character
	Local cQuery     as Character
	Local cSalesVAT  as Character
	Local cTab       as Character
	Local lDelUndel  as Logical
	Local lEntDocNum as Logical
	Local lInsDoc    as Logical
	Local lIsEmptyLn as Logical
	Local lValid     as Logical

	lValid := .T.
	aSavedRows := FWSaveRows()

	If oSubModel:GetId() == "F3ADETAIL"
		lIsEmptyLn := Empty(AllTrim(oSubModel:GetValue("F3A_KEY")))
		// If user put something into the Doc. Num. field and pressed enter.
		lEntDocNum := (cAction == "SETVALUE") .And. (cField $ "F3A_KEY   |F3A_DOC   |")
		lDelUndel := (cAction == "DELETE") .Or. (cAction == "UNDELETE")
		lInsDoc := oSubModel:IsInserted() .And. .Not. Empty(oSubModel:GetValue("F3A_DOC")) .And. .Not. lIsEmptyLn
		lInsDoc := lInsDoc .Or. .Not.(oSubModel:IsInserted())

		// If it is the deletion of an empty line return Nil.
		If (cAction == "DELETE") .And. lIsEmptyLn
			lValid := Nil

		ElseIf (cAction == "CANSETVALUE") .And. (cField == "F3A_DOC")
			If .Not. lIsEmptyLn
				lValid := .F.
			EndIf

		ElseIf lEntDocNum

			If (lIsEmptyLn .And. (cField == "F3A_DOC")) .or. (cField == "F3A_KEY")

				cSalesVAT := AllTrim(F35->F35_DOC)
				cPrintDate := DToS(F35->F35_PDATE)
				cQuery := RU09T04_01getSQLquery(oSubModel)
				cQuery += " AND T0.F35_DOC = '" + cSalesVAT + "'"
				cQuery += " AND T0.F35_PDATE = '" + cPrintDate + "'"

				If (cField == "F3A_DOC")
					cQuery += " AND T0.F35_DOC = '" + xValue + "' "
				ElseIf (cField == "F3A_KEY")
					cQuery += " AND T0.F35_KEY = '" + xValue + "' "
				EndIf

				cQuery += RU09T04_02getSQLGroupOrder()
				cTab := MPSysOpenQuery(ChangeQuery(cQuery))

				// If no VAT Invoices with such Document Number were found.
				If (cTab)->(Eof())
					lValid := .F.
					RU99XFUN05_Help(STR0953)
				EndIf

				lValid := lValid .And. self:FillF3ATable(oSubModel, cTab)
				CloseTempTable(cTab)
			EndIf

		ElseIf lDelUndel .And. lInsDoc
			cKey := AllTrim(oSubModel:GetValue("F3A_KEY"))
			self:DeleteUndeleteUpdate(oSubModel, cKey, cAction)
		EndIf
	ElseIf oSubModel:GetId() $ "F63PDETAIL|F63RDETAIL"
		lIsEmptyLn := Empty(AllTrim(oSubModel:GetValue("F63_KEY")))
		// If user put something into the Doc. Num. field and pressed enter.
		lEntDocNum := (cAction == "SETVALUE") .And. (cField $ "F63_KEY   |F63_DOC   |")
		lDelUndel := (cAction == "DELETE") .Or. (cAction == "UNDELETE")
		lInsDoc := oSubModel:IsInserted() .And. .Not. Empty(oSubModel:GetValue("F63_DOC")) .And. .Not. lIsEmptyLn
		lInsDoc := lInsDoc .Or. .Not.(oSubModel:IsInserted())

		// If it is the deletion of an empty line return Nil.
		If (cAction == "DELETE") .And. lIsEmptyLn
			lValid := Nil

		ElseIf (cAction == "CANSETVALUE") .And. (cField == "F63_DOC")
			If .Not. lIsEmptyLn
				lValid := .F.
			EndIf

		ElseIf lDelUndel .And. lInsDoc
			cKey := AllTrim(oSubModel:GetValue("F63_KEY"))
			self:DeleteUndeleteUpdate(oSubModel, cKey, cAction)
		EndIf
	EndIf

	FWRestRows(aSavedRows)

	If lValid .And. (cAction != "CANSETVALUE") .And. (cAction != "ISENABLE")
		RU99XFUN18_RefreshView("RU09T04")
	EndIf

Return lValid


/*{Protheus.doc} RU09T04EventRUS:GridLinePosVld()
@type       method
@author     Artem Kostin
@since      18/01/2019
*/
Method GridLinePosVld(oSubModel, cSubModelID) Class RU09T04EventRUS
	Local lRet := .T.

	If lRet .and. (cSubModelID == "F3ADETAIL")
		If (oSubModel:GetValue("F3A_ADSHNR") != 0 .AND. Empty(oSubModel:GetValue("F3A_ADSHDT")))
			lRet := .F.
			RU99XFUN05_Help(STR0954)
		ElseIf (oSubModel:GetValue("F3A_ADSHNR") == 0 .AND. !Empty(oSubModel:GetValue("F3A_ADSHDT")))
			lRet := .F.
			RU99XFUN05_Help(STR0955)
		EndIf
	EndIf

Return(lRet)


/*/{Protheus.doc} R09T4AInc
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Method R09T4AInc(oModel) Class RU09T04EventRUS
	Local lRet := .T.

	Local aParam as Array
	Local aPerguntas as Array
	Local oModelF39 as Object
	Local oModelF3A as Object
	Local oModelF54 as Object
	Local nItem as Numeric
	Local nLine as Numeric
	Local cTab as Character
	Local cQuery as Character
	Local cCodeF3A as Character
	Local cCode as Character
	Local nLinha as Numeric

	Default nLine := 0

	aParam :={}
	aPerguntas	:= {}
	nItem := 1
	nLine := 0
	cTab :=''
	cQuery := ""
	cCodeF3A :=""
	cCode		:=""
	nLinha := 1
	oModelF39 := oModel:GetModel("F39MASTER")
	oModelF3A := oModel:GetModel("F3ADETAIL")
	oModelF54 := oModel:GetModel("F54DETAIL")
	oModelF3A:GoLine(1)
	cCodeF3A := oModelF3A:GetValue("F3A_CODE")

	AAdd(aPerguntas,{ 1, STR0016+ ' '+ STR0022	, Space(TamSX3("F35_DOC")[1])            ,"@!",'.T.',"F35",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0016+ ' '+ STR0023	, Replicate("Z", TamSX3("F35_DOC")[1])   ,"@!",'.T.',"F35",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0017+ ' '+ STR0022	, oModelF39:GetValue("F39_INIT")         ,	 ,'.T.',"",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0017+ ' '+ STR0023	, oModelF39:GetValue("F39_FINAL")        ,	 ,'.T.',"",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0020+ ' '+ STR0022	, Space(TamSX3("F35_CLIENT")[1])         ,"@!",'.T.',"SA1",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0021+ ' '+ STR0022	, Space(TamSX3("F35_BRANCH")[1])         ,"@!",'.T.',"",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0020+ ' '+ STR0023	, Replicate("Z", TamSX3("F35_CLIENT")[1]),"@!",'.T.',"SA1",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0021+ ' '+ STR0023	, Replicate("Z", TamSX3("F35_BRANCH")[1]),"@!",'.T.',"",".T.",60, .F.})

	If ParamBox(aPerguntas,STR0030,aParam, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		cQuery := RU09T04_01getSQLquery(oModelF3A)
		cQuery += " AND T0.F35_DOC BETWEEN '"+aParam[1]+"' AND '"+aParam[2]+"'"
		cQuery += " AND T0.F35_PDATE BETWEEN '"+ DToS(aParam[3])+"' AND '"+ DToS(aParam[4])+"'"
		cQuery += " AND T0.F35_CLIENT BETWEEN '"+aParam[5]+"' AND '"+aParam[7]+"'"
		cQuery += " AND T0.F35_BRANCH BETWEEN '"+aParam[6]+"' AND '"+aParam[8]+"'"
		cQuery += RU09T04_02getSQLGroupOrder()
		cTab := MPSysOpenQuery(ChangeQuery(cQuery))
		lRet := lRet .and. self:FillF3ATable(oModelF3A, cTab)
	EndIf

	CloseTempTable(cTab)
	oModelF3A:GoLine(1)
Return

/*/{Protheus.doc} RU09T04EventRUS::R09T4ARec
Autofill F63 table on Sales Book (Receivement)
@type method
@author Fernando Nicolau
@since 08/01/2024
@param oModel, object, param_description
/*/
Method R09T4ARec(oModel) Class RU09T04EventRUS
	Local lRet := .T.

	Local aParam as Array
	Local aPerguntas as Array
	Local oModelF39 as Object
	Local oModelF63R as Object
	Local oModelF54 as Object
	Local nItem as Numeric
	Local nLine as Numeric
	Local cTab as Character
	Local cQuery as Character
	Local cCode as Character
	Local nLinha as Numeric

	Default nLine := 0

	aParam :={}
	aPerguntas	:= {}
	nItem := 1
	nLine := 0
	cTab :=''
	cQuery := ""
	cCode		:=""
	nLinha := 1
	oModelF39 := oModel:GetModel("F39MASTER")
	oModelF63R := oModel:GetModel("F63RDETAIL")
	oModelF54 := oModel:GetModel("F54DETAIL")
	oModelF63R:GoLine(1)

	AAdd(aPerguntas,{ 1, STR0016+ ' '+ STR0022	, Space(TamSX3("F35_DOC")[1])            ,"@!",'.T.',"F35",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0016+ ' '+ STR0023	, Replicate("Z", TamSX3("F35_DOC")[1])   ,"@!",'.T.',"F35",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0017+ ' '+ STR0022	, oModelF39:GetValue("F39_INIT")         ,	 ,'.T.',"",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0017+ ' '+ STR0023	, oModelF39:GetValue("F39_FINAL")        ,	 ,'.T.',"",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0020+ ' '+ STR0022	, Space(TamSX3("F35_CLIENT")[1])         ,"@!",'.T.',"SA1",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0021+ ' '+ STR0022	, Space(TamSX3("F35_BRANCH")[1])         ,"@!",'.T.',"",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0020+ ' '+ STR0023	, Replicate("Z", TamSX3("F35_CLIENT")[1]),"@!",'.T.',"SA1",".T.",60, .F.})
	AAdd(aPerguntas,{ 1, STR0021+ ' '+ STR0023	, Replicate("Z", TamSX3("F35_BRANCH")[1]),"@!",'.T.',"",".T.",60, .F.})

	If ParamBox(aPerguntas,STR0030,aParam, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		cQuery := RU09T04_01getSQLquery(oModelF63R)
		cQuery += " AND T0.F35_DOC BETWEEN '"+aParam[1]+"' AND '"+aParam[2]+"'"
		cQuery += " AND T0.F35_PDATE BETWEEN '"+ DToS(aParam[3])+"' AND '"+ DToS(aParam[4])+"'"
		cQuery += " AND T0.F35_CLIENT BETWEEN '"+aParam[5]+"' AND '"+aParam[7]+"'"
		cQuery += " AND T0.F35_BRANCH BETWEEN '"+aParam[6]+"' AND '"+aParam[8]+"'"
		cQuery += RU09T04_02getSQLGroupOrder()
		cTab := MPSysOpenQuery(ChangeQuery(cQuery))
		lRet := lRet .and. self:FillF63Table(oModelF63R, cTab)
	EndIf

	CloseTempTable(cTab)
	oModelF63R:GoLine(1)
Return


/*{Protheus.doc} RfrshF39Ttl
@description Changes totsl VAT (F39_TOTAL) by given value
@author alexander.ivanov
@since 11/11/2020
@version 1.0
@project MA3 - Russia
*/
Method RfrshF39Ttl(nValDiff) Class RU09T04EventRUS
	Local lRefreshed := .T.
	Local nValTotal := FWFldGet("F39_TOTAL") + nValDiff

	If FWFldPut("F39_TOTAL", nValTotal, /*nLinha*/, /*oModel*/, .T., .T.)
		lRefreshed := RU99XFUN18_RefreshView("RU09T04")
	Else
		lRefreshed := .F.
		RU99XFUN05_Help(STR0008)
	EndIf
Return lRefreshed

/*{Protheus.doc} FillRecordOfSalesBook
@description Fill one record in Sales Book
@author alexander.ivanov
@since 11/11/2020
@version 1.0
@project MA3 - Russia
*/
Method FillRecordOfSalesBook(oSubModel as Object, oSalVatMvs as Object, cTab as Character, nLine as Numeric) Class RU09T04EventRUS
	Local lOk as Logical

	lOk := oSubModel:LoadValue("F3A_KEY", (cTab)->F35_KEY)
	lOk := lOk .And. oSubModel:LoadValue("F3A_DOC", (cTab)->F35_DOC)
	lOk := lOk .And. oSubModel:LoadValue("F3A_PDATE", SToD((cTab)->F35_PDATE))
	lOk := lOk .And. oSubModel:LoadValue("F3A_VATCOD", (cTab)->F36_VATCOD)
	lOk := lOk .And. oSubModel:LoadValue("F3A_VATCD2", (cTab)->F36_VATCD2)
	lOk := lOk .And. oSubModel:LoadValue("F3A_INVSER", (cTab)->F35_INVSER)
	lOk := lOk .And. oSubModel:LoadValue("F3A_INVDOC", (cTab)->F35_INVDOC)
	lOk := lOk .And. oSubModel:LoadValue("F3A_CLIENT", (cTab)->F35_CLIENT)
	lOk := lOk .And. oSubModel:LoadValue("F3A_BRANCH", (cTab)->F35_BRANCH)
	lOk := lOk .And. oSubModel:LoadValue("F3A_INVDT", SToD((cTab)->F35_INVDT))
	lOk := lOk .And. oSubModel:LoadValue("F3A_INVCUR", (cTab)->F35_INVCUR)
	lOk := lOk .And. oSubModel:LoadValue("F3A_VATVL", (cTab)->F36_VATVL)
	lOk := lOk .And. oSubModel:LoadValue("F3A_VALGR", (cTab)->F36_VALGR)
	lOk := lOk .And. oSubModel:LoadValue("F3A_VATRT", (cTab)->F36_VATRT)
	lOk := lOk .And. oSubModel:LoadValue("F3A_VATBS", (cTab)->F36_VATBS)
	lOk := lOk .And. oSubModel:LoadValue("F3A_NAME", SubStr((cTab)->A1_NOME, 1, TamSX3("F3A_NAME")[1]))
	lOk := lOk .And. oSubModel:LoadValue("F3A_CNOR_C", (cTab)->F35_CNOR_C)
	lOk := lOk .And. oSubModel:LoadValue("F3A_CNOR_B", (cTab)->F35_CNOR_B)
	lOk := lOk .And. oSubModel:LoadValue("F3A_CNEE_C", (cTab)->F35_CNEE_C)
	lOk := lOk .And. oSubModel:LoadValue("F3A_CNEE_B", (cTab)->F35_CNEE_B)
	lOk := lOk .And. oSubModel:LoadValue("F3A_ADJNR", (cTab)->F35_ADJNR)
	lOk := lOk .And. oSubModel:LoadValue("F3A_ADJDT", SToD((cTab)->F35_ADJDT))
	lOk := lOk .And. oSubModel:LoadValue("F3A_ITEM", StrZero(nLine, TamSX3("F3A_ITEM")[1]))
	lOk := lOk .And. oSalVatMvs:LoadValue("F54_KEY", (cTab)->F35_KEY)

	If Empty(F54->F54_KEYORI)
		lOk := lOk .And. oSubModel:LoadValue("F3A_VATVL", (cTab)->F36_VATVL)
		lOk := lOk .And. oSubModel:LoadValue("F3A_VALGR", (cTab)->F36_VALGR)
		lOk := lOk .And. oSubModel:LoadValue("F3A_VATRT", (cTab)->F36_VATRT)
		lOk := lOk .And. oSubModel:LoadValue("F3A_VATBS", (cTab)->F36_VATBS)
	Else
		lOk := lOk .And. oSubModel:LoadValue("F3A_VATVL", F54->F54_VALUE)
		lOk := lOk .And. oSubModel:LoadValue("F3A_VALGR", F54->F54_VALUE + F54->F54_VATBS)
		lOk := lOk .And. oSubModel:LoadValue("F3A_VATRT", F54->F54_VATRT)
		lOk := lOk .And. oSubModel:LoadValue("F3A_VATBS", F54->F54_VATBS)
	EndIf

	self:RfrshF39Ttl(oSubModel:GetValue("F3A_VATVL"))
	lOk := lOk .And. oSalVatMvs:LoadValue("F54_KEYORI", F54->F54_KEYORI)
	lOk := lOk .And. oSubModel:LoadValue("F3A_KEYORI", F54->F54_KEYORI)
Return lOk

/*{Protheus.doc} GetSheetNumberTable
@description Returns temp. table with sheet numbers
@author alexander.ivanov
@since 12/11/2020
@version 1.0
@project MA3 - Russia
*/
Method GetSheetNumberTable(cPerStart, cPeriodEnd, cInterCode) Class RU09T04EventRUS
	Local cQuery    as Character
	Local cQueryStd as Character
	Local cShNumTab as Character
	Default cInterCode := "NO CODE"

	cQuery := "SELECT MAX(F3A.F3A_ADSHNR) AS F3A_ADSHNR "
	cQuery += "FROM " + RetSQLName("F3A") + " F3A "
	cQuery += "WHERE F3A.F3A_PDATE >= '" + cPerStart + "' AND F3A.F3A_PDATE < '" + cPeriodEnd + "' AND "
	cQuery += "F3A.D_E_L_E_T_ = ' ' AND F3A.F3A_FILIAL = '" + xFilial("F3A") + "' "

	If cInterCode != "NO CODE"
		cQuery +=  " AND F3A.F3A_BOOKEY = '" + cInterCode + "' "
	EndIf

	cQueryStd := ChangeQuery(cQuery)
	cShNumTab := MPSysOpenQuery(cQueryStd)
Return cShNumTab

/*{Protheus.doc} FillF3ATable
@description Fill Sales Book (F3A table)
@author alexander.ivanov
@since 10/11/2020
@version 1.0
@project MA3 - Russia
*/
Method FillF3ATable(oSubModel, cTab) Class RU09T04EventRUS
	Local aSheetNums as Array
	Local cTaxPrdBeg as Character
	Local lAddLine   as Logical
	Local lInPeriod  as Logical
	Local lTooLate   as Logical
	Local lZeroVatVl as Logical
	Local lOk        as Logical
	Local nLine      as Numeric
	Local nSBRecNum  as Numeric
	Local oModel     as Object // Sales book root model
	Local oSalVatMvs as Object // Sales VAT Movements model

	lAddLine := .Not. Empty(AllTrim(oSubModel:GetValue("F3A_KEY")))
	lOk := .T.
	oModel := oSubModel:oFormModel
	oSalVatMvs := oModel:GetModel("F54DETAIL")
	aSheetNums := {}

	While lOk .And. (cTab)->(.Not. Eof())
		DBSelectArea("F54")
		F54->(DbSetOrder(2))
		F54->(DbSeek(xFilial('F54') + Space(Len(F54->F54_REGKEY)) + (cTab)->F35_KEY + (cTab)->F36_VATCOD))

		While lOk .And. RU09T04003_IsCorrectRecord(cTab)
			// If there is no empty line, add new line and push new data to the bottom of the grid.
			// If there is already an empty line, data could be inserted starting from this empty line.
			If lAddLine
				nSBRecNum := F54->(Recno())
				nLine := oSubModel:AddLine()
				F54->(dbGoto(nSBRecNum))
			Else
				nLine := oSubModel:Length(.F.)
				lAddLine := .T.
			EndIf

			lTooLate := SToD((cTab)->F35_PDATE) > FWFldGet("F39_FINAL")
			lZeroVatVl := (cTab)->F36_VATVL == 0

			If lTooLate .Or. lZeroVatVl
				(cTab)->(DbSkip())
				lAddLine := .F.
				Loop
			EndIf

			lOk := lOk .And. self:FillRecordOfSalesBook(oSubModel, oSalVatMvs, cTab, nLine)
			cTaxPrdBeg := RU09T04001_GetTaxPeriodStart(FWFldGet("F39_INIT"))
			lInPeriod := SToD((cTab)->F35_PDATE) < SToD(cTaxPrdBeg)

			If lInPeriod
				lOk := lOk .And. self:SetFieldsOfAdditionalSheet(cTab, oSubModel, @aSheetNums)
			EndIf

			If .Not. lOk
				RU99XFUN05_Help(STR0927)
				Exit
			EndIf
			DBSelectArea("F54")
			F54->(DbSkip())
		EndDo
		(cTab)->(DbSkip())
	EndDo

	RU05XFN008_Help(oModel)
Return lOk


/*{Protheus.doc} RU09T04_01getSQLquery
It is an attempt to generalize common things.
@author Artem Kostin
@since 01/28/2019
@version P12.1.23
@type function
*/
Function RU09T04_01getSQLquery(oSubModel as Object)
	Local cQuery 	as Character
	Local nLine 	as Numeric
	Local cPrefix	as Character
	Local cKey		as Character
	Local cVatCod   as Character 

	cQuery := "SELECT T0.F35_DOC,"
	cQuery += " T0.F35_PDATE,"
	cQuery += " T0.F35_KEY,"
	cQuery += " T0.F35_INVSER,"
	cQuery += " T0.F35_INVDOC,"
	cQuery += " T0.F35_CLIENT,"
	cQuery += " T0.F35_BRANCH,"
	cQuery += " T0.F35_INVCUR,"
	cQuery += " T0.F35_ADJNR,"
	cQuery += " T0.F35_ADJDT,"
	cQuery += " T1.F36_VATCOD,"
	cQuery += " T1.F36_VATCD2,"
	cQuery += " SUM(T1.F36_VATVL1) F36_VATVL,"
	cQuery += " SUM(T1.F36_VATVL1 + T1.F36_VATBS1) F36_VALGR,"
	cQuery += " SUM(T1.F36_VATBS1) F36_VATBS,"
	cQuery += " T1.F36_VATRT,"
	cQuery += " T2.A1_NOME,"
	cQuery += " T0.F35_INVDT,"
	cQuery += " T0.F35_CNEE_B,"
	cQuery += " T0.F35_CNOR_C,"
	cQuery += " T0.F35_CNOR_B,"
	cQuery += " T0.F35_CNEE_C"
	cQuery += " FROM " + RetSQLName("F35") + " T0"
	cQuery += " LEFT JOIN " + RetSQLName("F36") + " T1"
	cQuery += " ON T1.F36_FILIAL = '" + xFilial("F36") + "'"
	cQuery += " AND T1.D_E_L_E_T_ = ' '"
	cQuery += " AND T1.F36_KEY = T0.F35_KEY"
	cQuery += " LEFT JOIN " + RetSQLName("SA1") + " T2"
	cQuery += " ON T2.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " AND T2.D_E_L_E_T_ = ' '"
	cQuery += " AND T2.A1_COD = T0.F35_CLIENT"
	cQuery += " AND T2.A1_LOJA = T0.F35_BRANCH"
	cQuery += " WHERE T0.F35_FILIAL = '" + xFilial("F35") + "'"
	cQuery += " AND T0.D_E_L_E_T_ = ' '"
	cQuery += " AND T0.F35_BOOK = ' '"

	If oSubModel:GetId() == "F3ADETAIL" .or. oSubModel:GetId() == "F63PDETAIL" .OR. oSubModel:GetId() == "F63RDETAIL" 
		cPrefix	:= Left(oSubModel:GetId(),3) //Take firts 3 positions 
		For nLine := 1 to oSubModel:Length(.F.)
			oSubModel:GoLine(nLine)
			cKey 	:= oSubModel:GetValue(cPrefix+"_KEY")
			cVatCod	:= oSubModel:GetValue(cPrefix+"_VATCOD") 
			If !Empty(cKey)
				// Excludes the records which are already in the model from SQL select.
				cQuery += " AND NOT ("
				cQuery += " T1.F36_KEY = '" + cKey + "'"
				cQuery += " AND T1.F36_VATCOD = '" + cVatCod + "'"
				cQuery += " )"
			EndIf
		Next nLine
	EndIf		

Return(cQuery)


/*{Protheus.doc} RU09T04_02getSQLGroupOrder
It is an attempt to generalize common things.
@author Artem Kostin
@since 01/28/2019
@version P12.1.23
@type function
*/
Function RU09T04_02getSQLGroupOrder()
	Local cQuery as Character
	cQuery := " GROUP BY T0.F35_DOC,"
	cQuery += " T0.F35_PDATE,"
	cQuery += " T0.F35_KEY,"
	cQuery += " T1.F36_VATCOD,"
	cQuery += " T1.F36_VATCD2,"
	cQuery += " T0.F35_INVDT,"
	cQuery += " T0.F35_INVSER,"
	cQuery += " T0.F35_INVDOC,"
	cQuery += " T0.F35_CLIENT,"
	cQuery += " T0.F35_BRANCH,"
	cQuery += " T0.F35_INVCUR,"
	cQuery += " T0.F35_CNEE_B,"
	cQuery += " T0.F35_CNOR_C,"
	cQuery += " T0.F35_CNOR_B,"
	cQuery += " T0.F35_CNEE_C,"
	cQuery += " T0.F35_ADJNR,"
	cQuery += " T0.F35_ADJDT,"
	cQuery += " T1.F36_VATRT,"
	cQuery += " T2.A1_NOME"
	cQuery += " ORDER BY T0.F35_DOC,"
	cQuery += " T0.F35_PDATE,"
	cQuery += " T1.F36_VATCOD,"
	cQuery += " T1.F36_VATCD2"
Return(cQuery)

/*{Protheus.doc} RU09T04001_GetTaxPeriodStart
@description The first date of a quarter which contains given date
@author alexander.ivanov
@since 06/03/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T04001_GetTaxPeriodStart(dDate as Date)
	Local aQrtStarts as Array
	Local cFirstDay  as Character
	Local cYear      as Character
	Local nQuarter   as Numeric
	nQuarter   := 1 + Int((Month(dDate) - 1) / 3)
	cYear      := Str(Year(dDate))
	aQrtStarts := {"01","04","07","10"}
	cMonth     := aQrtStarts[nQuarter]
	cFirstDay  := "01"
Return LTrim(cYear) + cMonth + cFirstDay

/*{Protheus.doc} RU09T04002_GetTaxPeriodEnd
@description The first date of a quarter next to the one containing given date
@author alexander.ivanov
@since 06/03/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T04002_GetTaxPeriodEnd(dDate as Date)
	Local aQrtEnds as Array
	Local cFirstDay  as Character
	Local cYear      as Character
	Local nQuarter   as Numeric
	nQuarter  := 1 + Int((Month(dDate) - 1) / 3)
	cYear     := Str(Year(dDate) + Int(nQuarter / 4))
	aQrtEnds  := {"04","07","10","01"}
	cMonth    := aQrtEnds[nQuarter]
	cFirstDay := "01"
Return LTrim(cYear) + cMonth + cFirstDay

/*{Protheus.doc} RU09T04003_IsCorrectRecord
@description
@author alexander.ivanov
@since 10/11/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T04003_IsCorrectRecord(cTab as Character) as Logical
	Local cF54_I2Key as Character
	Local cTabKey    as Character
	Local lOk        as Logical

	lOk := F54->(.Not. EOF()) .And. F54->F54_TYPE == "01"
	cF54_I2Key := F54->F54_FILIAL + F54->F54_REGKEY + F54->F54_KEY + F54->F54_VATCOD
	cTabKey := xFilial('F54') + Space(Len(F54->F54_REGKEY)) + (cTab)->F35_KEY + (cTab)->F36_VATCOD
	lOk := lOk .And. cF54_I2Key == cTabKey
Return lOk

// Deletes or undeletes all lines related to this Sales VAT Invoices. Recalculates values for other lines
/*{Protheus.doc} Method DeleteUndeleteUpdate
@description 
@author alexander.ivanov
@since 25/11/2020
@version 1.0
@project MA3 - Russia
*/
Method DeleteUndeleteUpdate(oSubModel as Object, cKey as Char, cAction as Char) Class RU09T04EventRUS
	Local lNeedDelet as Logical
	Local lNeedUndel as Logical
	Local lValid     as Logical
	Local nCurDelta  as Numeric
	Local nLine      as Numeric
	Local nVatValue  as Numeric

	lValid := .T.
	lNeedDelet := (cAction == "DELETE") .And. .Not.(oSubModel:IsDeleted())
	lNeedUndel := (cAction == "UNDELETE") .And. (oSubModel:IsDeleted())
	nCurDelta := 0

	For nLine := 1 To oSubModel:Length()
		
		oSubModel:GoLine(nLine)

		If oSubModel:GetId() == "F3ADETAIL"

			If (cKey == AllTrim(oSubModel:GetValue("F3A_KEY")))
				nVatValue := oSubModel:GetValue("F3A_VATVL")

				If lNeedDelet
					nCurDelta--
					oSubModel:DeleteLine()
					lValid := lValid .And. self:RfrshF39Ttl(-nVatValue)
				ElseIf lNeedUndel
					oSubModel:UnDeleteLine()
					nCurDelta++
					lValid := lValid .And. self:RfrshF39Ttl(nVatValue)
				EndIf
			Else
				RU99XFUN20_AddToField(oSubModel, "F3A_ITEM", nCurDelta)
			EndIf

		ElseIf  oSubModel:GetId() $ "F63PDETAIL|F63RDETAIL"

			If (cKey == AllTrim(oSubModel:GetValue("F63_KEY")))
				nVatValue := oSubModel:GetValue("F63_VATVL")

				If lNeedDelet
					nCurDelta--
					oSubModel:DeleteLine()
					lValid := lValid .And. self:RfrshF39Ttl(-nVatValue)
				ElseIf lNeedUndel
					oSubModel:UnDeleteLine()
					nCurDelta++
					lValid := lValid .And. self:RfrshF39Ttl(nVatValue)
				EndIf
			Else
				RU99XFUN20_AddToField(oSubModel, "F63_ITEM", nCurDelta)
			EndIf

		EndIf

	Next nLine
Return lValid

/*{Protheus.doc} SetFieldsOfAdditionalSheet
@description Sets number and date of additional Sales Book sheet
@author alexander.ivanov
@since 02/12/2020
@version 1.0
@project MA3 - Russia
*/
Method SetFieldsOfAdditionalSheet(cTab as Character, oSubModel as Object, aSheetNums as Array) Class RU09T04EventRUS
	Local cShtNumTab as Character
	Local cTaxPrdBeg as Character
	Local cTaxPrdEnd as Character
	Local dPostDate  as Date
	Local dPrintDate as Date
	Local dSheetDate as Date
	Local lOk 		 as Logical
	Local nAddShtNum as Numeric
	Local nCnt       as Numeric
	Local nSheetNum  as Numeric
	Local nTmpMaxNr  as Numeric

	lOk := .T.
	dPostDate := Stod((cTab)->F35_PDATE)
	cTaxPrdBeg := RU09T04001_GetTaxPeriodStart(dPostDate)
	cTaxPrdEnd := RU09T04002_GetTaxPeriodEnd(dPostDate)

	nTmpMaxNr := 0
	For nCnt := 1 To Len(aSheetNums)
		dSheetDate := aSheetNums[nCnt][1]
		nSheetNum := aSheetNums[nCnt][2]
		If nTmpMaxNr < nSheetNum .And. dSheetDate >= SToD(cTaxPrdBeg) .And. dSheetDate < STOD(cTaxPrdEnd)
			nTmpMaxNr := nSheetNum
		EndIf
	Next

	// Get existing numbers in saved and added rows. If exist - set max num, else create new num = max + 1
	cShtNumTab := self:GetSheetNumberTable(cTaxPrdBeg, cTaxPrdEnd, FWFldGet("F39_BOOKEY"))

	If (cShtNumTab)->F3A_ADSHNR > 0 .Or. nTmpMaxNr > 0
		nAddShtNum := Max((cShtNumTab)->F3A_ADSHNR, nTmpMaxNr)
		lOk := lOk .And. oSubModel:LoadValue("F3A_ADSHNR", nAddShtNum)
	Else
		cShtNumTab := self:GetSheetNumberTable(cTaxPrdBeg, cTaxPrdEnd, "NO CODE")

		dPrintDate := SToD((cTab)->F35_PDATE)
		nAddShtNum := 1 + Max((cShtNumTab)->F3A_ADSHNR, nTmpMaxNr)
		AAdd(aSheetNums, {dPrintDate, nAddShtNum})
		lOk := lOk .And. oSubModel:LoadValue("F3A_ADSHNR", nAddShtNum)
	EndIf

	lOk := lOk .And. oSubModel:LoadValue("F3A_ADSHDT", SToD(cTaxPrdEnd))

Return lOk

/*/{Protheus.doc} RU09T04EventRUS::R09T4APay
Autofill F63 table on Sales Book (Payment)
@type method
@author Fernando Nicolau
@since 08/01/2024
@param oModel, object, param_description
@return variant, return_description
/*/
Method R09T4APay(oModel) Class RU09T04EventRUS
	Local lRet := .T.

	Local aParam as Array
	Local aPerguntas as Array
	Local oModelF39 as Object
	Local oModelF63 as Object
	Local oModelF54 as Object
	Local cTab as Character
	Local cQuery as Character
	Local cSepNeg as Character
	Local cSepPag as Character

    Local cTitMov As Character
    Local cTitSup As Character
    Local cTitBra As Character

	aParam :={}
	aPerguntas	:= {}
	cTab :=''
	cQuery := ""

	cSepNeg := Iif("|" $ MV_CPNEG, "|", ",")
	cSepPag := Iif("|" $ MVPAGANT, "|", ",")

	oModelF39 := oModel:GetModel("F39MASTER")
	oModelF63 := oModel:GetModel("F63PDETAIL")
	oModelF54 := oModel:GetModel("F54PDETAIL")
	oModelF63:GoLine(1)

    cTitMov := Posicione("SX3", 2, "FK2_DATA", "X3Titulo()")
    cTitSup := Posicione("SX3", 2, "F37_FORNEC", "X3Titulo()")
    cTitBra := Posicione("SX3", 2, "F37_BRANCH", "X3Titulo()")

	AAdd(aPerguntas, {1, cTitMov/* STR0016 */ + ' ' + STR0022, oModelF39:GetValue("F39_INIT") , "", '.T.' , "", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitMov/* STR0016 */ + ' ' + STR0023, oModelF39:GetValue("F39_FINAL"), "", '.T.' , "", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, STR0016 + ' ' + STR0022, Space(TamSX3("F37_DOC")[1])            , "@!", '.T.', "F37", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, STR0016 + ' ' + STR0023, Replicate("Z", TamSX3("F37_DOC")[1])   , "@!", '.T.', "F37", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitSup + ' ' + STR0022, Space(TamSX3("F37_FORNEC")[1])         , "@!", '.T.', "SA2", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitBra + ' ' + STR0022, Space(TamSX3("F37_BRANCH")[1])         , "@!", '.T.', ""   , ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitSup + ' ' + STR0023, Replicate("Z", TamSX3("F37_FORNEC")[1]), "@!", '.T.', "SA2", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitBra + ' ' + STR0023, Replicate("Z", TamSX3("F37_BRANCH")[1]), "@!", '.T.', ""   , ".T.", 60, .F.})

	If ParamBox(aPerguntas, STR0030, aParam, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		cQuery := RU09XFN023_AdvancesVATSqlQuery(oModelF63)
		cQuery += " AND FK2.FK2_DATA BETWEEN '" + DtoS(aParam[1]) + "' AND '" + DtoS(aParam[2]) + "'"
		cQuery += " AND F37.F37_DOC BETWEEN '" + aParam[3] + "' AND '" + aParam[4] + "'"
		cQuery += " AND F37.F37_FORNEC BETWEEN '" + aParam[5] + "' AND '" + aParam[7] + "'"
		cQuery += " AND F37.F37_BRANCH BETWEEN '" + aParam[6] + "' AND '" + aParam[8] + "'"
		cQuery += " AND (F37.F37_TIPO IN " + FormatIn(MVPAGANT, cSepPag) + " OR "
		cQuery += "      F37.F37_TIPO IN " + FormatIn(MV_CPNEG, cSepNeg) + " ) "

		cQuery += RU09XFN024_AdvancesVATGroupBy(oModelF63)
		cTab := MPSysOpenQuery(ChangeQuery(cQuery))
		lRet := lRet .and. self:FillF63Table(oModelF63, cTab)
	EndIf

	CloseTempTable(cTab)
	oModelF63:GoLine(1)
Return

/*/{Protheus.doc} RU09T04EventRUS::FillF63Table
Fill Sales Book (F63 table)
@type method
@version  
@author Fernando Nicolau
@since 08/01/2024
@param oSubModel, object, param_description
@param cTab, character, param_description
@return variant, return_description
/*/
Method FillF63Table(oSubModel, cTab) Class RU09T04EventRUS
	Local aSheetNums as Array
	Local lAddLine   as Logical
	Local lTooLate   as Logical
	Local lZeroVatVl as Logical
	Local lOk        as Logical
	Local nLine      as Numeric
	Local oModel     as Object // Sales book root model

	lAddLine := !Empty(AllTrim(oSubModel:GetValue("F63_KEY")))
	lOk := .T.
	oModel := oSubModel:oFormModel

	aSheetNums := {}

	While lOk .And. !(cTab)->(Eof())

		// Skip lines with zero VAT amount or date not belongs to Ledger's period:
		If oSubModel:GetId() == "F63PDETAIL"
			lTooLate := SToD((cTab)->F37_PDATE) > FWFldGet("F39_FINAL")
			lZeroVatVl := (cTab)->F38_VATVL == 0
		ElseIf oSubModel:GetId() == "F63RDETAIL"
			lTooLate := SToD((cTab)->F35_PDATE) > FWFldGet("F39_FINAL")
			lZeroVatVl := (cTab)->F36_VATVL == 0
		EndIf

		If lTooLate .Or. lZeroVatVl
			(cTab)->(DbSkip())
			Loop
		EndIf
		
		// If there is no empty line, add new line and push new data to the bottom of the grid.
		// If there is already an empty line, data could be inserted starting from this empty line.
		If lAddLine
			nLine := oSubModel:AddLine()
		Else
			nLine := oSubModel:Length(.F.)
			lAddLine := .T.
		EndIf		

		lOk := lOk .And. self:FillVATSalesBook(oSubModel, cTab, nLine)

		If !lOk
			RU99XFUN05_Help(STR0927)
			Exit
		EndIf
		(cTab)->(DbSkip())
	EndDo

	RU05XFN008_Help(oModel)
Return lOk

/*/{Protheus.doc} RU09T04EventRUS::FillVATSalesBook
Fill Sales Book Grid (F63 table)
@type method
@version  
@author Fernando Nicolau
@since 08/01/2024
@param oSubModel, object, param_description
@param cTab, character, param_description
@param nLine, numeric, param_description
@return variant, return_description
/*/
Method FillVATSalesBook(oSubModel as Object, cTab as Character, nLine as Numeric) Class RU09T04EventRUS
	Local aArea As Array
    Local lOk as Logical
	Local cTabFK As Character
    Local cTabVAT As Character
    Local cTabVATDet As Character
    Local cTabSupCli As Character
    Local cFldSupCli As Character
    Local cTabBS as Character
	Local cQuery as Character

	aArea := GetArea()
	cTabBS := ""
	cQuery := ""

    If oSubModel:GetId() == "F63PDETAIL"
        cTabFK := "FK2"
        cTabVAT := "F37"
        cTabVATDet := "F38"
        cTabSupCli := "A2"
        cFldSupCli := "_FORNEC"
    ElseIf oSubModel:GetId() == "F63RDETAIL"
        cTabFK := "FK1"
        cTabVAT := "F35"
        cTabVATDet := "F36"
        cTabSupCli := "A1"
        cFldSupCli := "_CLIENT"
    EndIf

	lOk := oSubModel:LoadValue("F63_KEY", &("(cTab)->" + cTabVAT + "_KEY"))
	lOk := lOk .And. oSubModel:LoadValue("F63_DOC", Rtrim(&("(cTab)->" + cTabVAT + "_DOC")))
	lOk := lOk .And. oSubModel:LoadValue("F63_PDATE", SToD(&("(cTab)->" + cTabVAT + "_PDATE")))
	lOk := lOk .And. oSubModel:LoadValue("F63_ADJNR", &("(cTab)->" + cTabVAT + "_ADJNR"))
	lOk := lOk .And. oSubModel:LoadValue("F63_ADJDT", SToD(&("(cTab)->" + cTabVAT + "_ADJDT")))
	lOk := lOk .And. oSubModel:LoadValue("F63_VATCOD", &("(cTab)->" + cTabVATDet + "_VATCOD"))
	lOk := lOk .And. oSubModel:LoadValue("F63_VATCD2", &("(cTab)->" + cTabVATDet + "_VATCD2"))

	lOk := lOk .And. oSubModel:LoadValue("F63_SUCL", &("(cTab)->" + cTabVAT + cFldSupCli))
	lOk := lOk .And. oSubModel:LoadValue("F63_SUCLBR", &("(cTab)->" + cTabVAT + "_BRANCH"))
	lOk := lOk .And. oSubModel:LoadValue("F63_SUCLNM", SubStr(&("(cTab)->" + cTabSupCli + "_NOME"), 1, TamSX3("F63_SUCLNM")[1]))
	lOk := lOk .And. oSubModel:LoadValue("F63_INVCUR", &("(cTab)->" + cTabVAT + "_INVCUR"))

	lOk := lOk .And. oSubModel:LoadValue("F63_VALGR", &("(cTab)->" + cTabVATDet + "_VALGR"))
	lOk := lOk .And. oSubModel:LoadValue("F63_VATBS", &("(cTab)->" + cTabVATDet + "_VATBS"))
	lOk := lOk .And. oSubModel:LoadValue("F63_VATRT", &("(cTab)->" + cTabVATDet + "_VATRT"))
	lOk := lOk .And. oSubModel:LoadValue("F63_VATVL", &("(cTab)->" + cTabVATDet + "_VATVL"))

	lOk := lOk .And. oSubModel:LoadValue("F63_ORIGGR", &("(cTab)->" + cTabVATDet + "_VALGR"))
	lOk := lOk .And. oSubModel:LoadValue("F63_C_RATE", 1.0)		// As we operate only with local currency, so the rate must be 1.0 in all cases &("(cTab)->" + cTabVAT + "_C_RATE")
	
    DbSelectArea(cTabVAT)
	(cTabVAT)->(DbSetOrder(3))
	If (cTabVAT)->(MsSeek(xFilial(cTabVAT) + &("(cTab)->" + cTabVAT + "_KEY")))

		If oSubModel:GetId() == "F63PDETAIL"
			cF5MKey := xFilial("F5M") + "|" + (cTabVAT)->F37_PREFIX + "|"+ (cTabVAT)->F37_NUM + "|" + (cTabVAT)->F37_PARCEL + "|"+ (cTabVAT)->F37_TIPO +"|" + (cTabVAT)->F37_FORNEC + "|" + (cTabVAT)->F37_BRANCH
		ElseIf oSubModel:GetId() == "F63RDETAIL"
			cF5MKey := xFilial("F5M") + "|" + (cTabVAT)->F35_PREFIX + "|"+ (cTabVAT)->F35_NUM + "|" + (cTabVAT)->F35_PARCEL + "|"+ (cTabVAT)->F35_TIPO +"|" + (cTabVAT)->F35_CLIENT + "|" + (cTabVAT)->F35_BRANCH
		EndIf

		cQuery := " SELECT F4C_BNKORD, F4C_DTPAYM "
		cQuery += " FROM " + RetSQLName("F4C") + " F4C "
		cQuery += " INNER JOIN " + RetSQLName("F5M") + " F5M ON (F5M_IDDOC = F4C_CUUID and F5M_FILIAL = '" + xFilial("F5M") + "') "
		cQuery += " WHERE F4C.D_E_L_E_T_ = ' ' AND F5M.D_E_L_E_T_= ' ' "
		cQuery += " AND F5M_KEY like '" + cF5MKey + "%' and F5M_ALIAS = 'F4C' "
		cTabBS := MPSysOpenQuery(ChangeQuery(cQuery))

		If !(cTabBS)->(Eof())
			lOk := lOk .And. oSubModel:LoadValue("F63_BNKORD", (cTabBS)->F4C_BNKORD)
			lOk := lOk .And. oSubModel:LoadValue("F63_DTPAYM", StoD((cTabBS)->F4C_DTPAYM))
		EndIf

	EndIf

	self:RfrshF39Ttl(oSubModel:GetValue("F63_VATVL"))

    CloseTempTable(cTabBS)
	RestArea(aArea)
Return lOk
                   
//Merge Russia R14 
                   
