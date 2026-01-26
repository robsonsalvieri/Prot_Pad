#Include "Protheus.ch"
#Include "FwMVCDef.ch"
#Include "RU09T04.ch"
#include 'RU09XXX.ch'

/*/{Protheus.doc} RU09T04
@author felipe.morais
@since 27/10/2017
@version 1.0
@return ${return}, ${return_description}

@history 11/12/2023, Fernando Nicolau, FI-VAT-37 implementations.

@type function
/*/

Function RU09T04()
	Local lRet := .T.
	Local oBrowse as Object

	Private aRotina as Array

// Initalization of tables, if they do not exist.
	DbSelectArea("F54")
	F54->(dbSetOrder(1))

	DbSelectArea("F3A")
	F3A->(dbSetOrder(2))

	DbSelectArea("F63")
	F63->(dbSetOrder(1))

	aRotina := MenuDef()

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return(lRet)

/*/{Protheus.doc} BrowseDef
@author felipe.morais
@since 27/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function BrowseDef()
	Local oBrowse as Object

	oBrowse := FwMBrowse():New()
	oBrowse:SetAlias("F39")
	oBrowse:SetDescription(STR0001)
	oBrowse:DisableDetails()

	SetKey(VK_F12, {|a,b| AcessaPerg("RU09T04", .T.)})
Return(oBrowse)

/*/{Protheus.doc} MenuDef
@author felipe.morais
@since 27/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function MenuDef()
	Local aRotina as Array

	aRotina := {}

	Add Option aRotina Title STR0002 Action "PesqBrw" Operation 1 Access 0
	Add Option aRotina Title STR0003 Action "RU09T04Vis" Operation 2 Access 0
	Add Option aRotina Title STR0004 Action "RU09T04Inc" Operation 3 Access 0
	Add Option aRotina Title STR0005 Action "RU09T04Upd" Operation 4 Access 0
	Add Option aRotina Title STR0006 Action "RU09T04Exc" Operation 5 Access 0
	Add Option aRotina Title STR0040 Action "RU09R02()" Operation 2 Access 0
Return(aRotina)

/*/{Protheus.doc} ModelDef
@author felipe.morais
@since 27/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function ModelDef()
	Local oModel as Object
	Local aStruF39 as Array
	Local aStruF3A as Array
	Local aStruF54 as Array
	Local aStruF63P as Array
	Local aStruF63R as Array

	Local aArea as Array
	Local aAreaSX3 as Array

	Local oModelEvent as Object

	aStruF39 := FwFormStruct(1, "F39")
	aStruF3A := FwFormStruct(1, "F3A")
	aStruF54 := FwFormStruct(1, "F54")
	aStruF63P := FwFormStruct(1, "F63")
	aStruF63R := FwFormStruct(1, "F63")



	aArea := GetArea()
	aAreaSX3 := SX3->(GetArea())

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If (SX3->(DbSeek("F39_FILIAL")))
		aStruF39:AddField(     X3Titulo(),;                                                  //       [01]  C   Titulo do campo
		X3Descric(),;                                                  //    [02]  C   ToolTip do campo
		"XX_FILIAL",;                                              //    [03]  C   Id do Field
		"C",;                                                      //    [04]  C   Tipo do campo
		TamSX3("F39_FILIAL")[1],;                            //       [05]  N   Tamanho do campo
		TamSX3("F39_FILIAL")[2],;                            //       [06]  N   Decimal do campo
		NIL,;                                                      //    [07]  B   Code-block de validação do campo
		NIL,;                                                      //    [08]  B   Code-block de validação When do campo
		NIL,;                                                      //    [09]  A   Lista de valores permitido do campo
		.F.,;                                                      //    [10]  L   Indica se o campo tem preenchimento obrigatório
		{|| xFilial("F39")},;                  //    [11]  B   Code-block de inicializacao do campo
		NIL,;                                                      //    [12]  L   Indica se trata-se de um campo chave
		.T.,;                                                      //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.)                                                       //    [14]  L   Indica se o campo é virtual
	EndIf


	RestArea(aAreaSX3)
	RestArea(aArea)

	oModel := MpFormModel():New("RU09T04",{|| RU09T0401(oModel) }, , {|| ModelRec(oModel)})

	oModel:AddFields("F39MASTER", , aStruF39)
	oModel:AddGrid("F3ADETAIL", "F39MASTER", aStruF3A,/*bLinePre*/,/*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:AddGrid("F63PDETAIL", "F39MASTER", aStruF63P)
	oModel:AddGrid("F63RDETAIL", "F39MASTER", aStruF63R)
	oModel:AddGrid("F54DETAIL", "F3ADETAIL", aStruF54)

	oModel:AddGrid("F54PDETAIL", "F63PDETAIL", aStruF54)
	oModel:AddGrid("F54RDETAIL", "F63RDETAIL", aStruF54)

	oModel:SetDescription(STR0001)
	oModel:GetModel("F39MASTER"):SetDescription(STR0008)
	oModel:GetModel("F3ADETAIL"):SetDescription(STR0009)

	oModel:SetRelation("F3ADETAIL", {{"F3A_FILIAL", "xFilial('F3A')"}, {"F3A_BOOKEY", "F39_BOOKEY"}}, F3A->(IndexKey(1)))

	oModel:SetRelation("F63PDETAIL", {{"F63_FILIAL", "xFilial('F63')"}, {"F63_BOOKEY", "F39_BOOKEY"}}, F63->(IndexKey(1)))
	oModel:SetRelation("F63RDETAIL", {{"F63_FILIAL", "xFilial('F63')"}, {"F63_BOOKEY", "F39_BOOKEY"}}, F63->(IndexKey(1)))

	oModel:SetRelation("F54DETAIL", {;
		{"F54_FILIAL",  "xFilial('F54')"};
		, {"F54_REGKEY","F39_BOOKEY"};
		, {"F54_KEY",   "F3A_KEY"};
		, {"F54_VATCOD","F3A_VATCOD"};
		, {"F54_KEYORI","F3A_KEYORI"};
		}, F54->(IndexKey(2)))

	oModel:SetRelation("F54PDETAIL", {;
		{"F54_FILIAL",  "xFilial('F54')"};
		, {"F54_REGKEY","F39_BOOKEY"};
		, {"F54_KEY",   "F63_KEY"};
		, {"F54_VATCOD","F63_VATCOD"};
		}, F54->(IndexKey(2)))

	oModel:SetRelation("F54RDETAIL", {;
		{"F54_FILIAL",  "xFilial('F54')"};
		, {"F54_REGKEY","F39_BOOKEY"};
		, {"F54_KEY",   "F63_KEY"};
		, {"F54_VATCOD","F63_VATCOD"};
		}, F54->(IndexKey(2)))

//oModel:GetModel("F3ADETAIL"):SetUniqueLine({"F3A_KEY", "F3A_CODE", "F3A_DOC", "F3A_PDATE", "F3A_VATCOD", "F3A_VATCD2"})
	oModel:GetModel("F63PDETAIL"):SetUniqueLine({"F63_ITEM"})
	oModel:GetModel("F63RDETAIL"):SetUniqueLine({"F63_ITEM"})

	oModel:GetModel("F3ADETAIL"):SetOptional(.T.)
	oModel:GetModel("F63PDETAIL"):SetOptional(.T.)
	oModel:GetModel("F63RDETAIL"):SetOptional(.T.)
	oModel:GetModel("F54DETAIL"):SetOptional(.T.)
	oModel:GetModel("F54PDETAIL"):SetOptional(.T.)
	oModel:GetModel("F54RDETAIL"):SetOptional(.T.)

	oModel:GetModel("F63PDETAIL"):GetStruct():SetProperty('F63_TYPE', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'1'"))
	oModel:GetModel("F63RDETAIL"):GetStruct():SetProperty('F63_TYPE', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'2'"))

	oModel:GetModel("F63PDETAIL"):SetLoadFilter({{"F63_TYPE", "'1'"}})
	oModel:GetModel("F63RDETAIL"):SetLoadFilter({{"F63_TYPE", "'2'"}})

	oModelEvent 	:= RU09T04EventRUS():New()
	oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)

Return(oModel)



/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author felipe.morais
@since 27/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function ViewDef()
	Local oView as Object
	Local oModel as Object
	Local aStruF39 as Array
	Local aStruF3A as Array
	Local aStruF63P as Array
	Local aStruF63R as Array
	Local aStructTotal as Array
	Local cFldF3A as Character

	Local aArea as Array
	Local aAreaSX3 as Array

	Local oModelEvent := RU09T04EventRUS():New()


	cFldF3A := "F3A_FILIAL|F3A_CODE|F3A_BOOKEY"
	oModel := FwLoadModel("RU09T04")
	aStruF39 := FwFormStruct(2, "F39")
	aStruF3A := FwFormStruct(2, "F3A", {|x| !(AllTrim(x) $ cFldF3A)})
	aStruF63P := FwFormStruct(2, "F63", {|x| !(AllTrim(x) $ "F63_FILIAL|F63_KEY|F63_BOOKEY")})
	aStruF63R := FwFormStruct(2, "F63", {|x| !(AllTrim(x) $ "F63_FILIAL|F63_KEY|F63_BOOKEY")})
	aStructTotal := FWFormStruct(2, "F39", {|x| (x == "F39_TOTAL ")})

	aStruF39 := RU09XFN013(aStruF39, "F39", {"_TOTAL", "_VRCMNT", "_BOOKEY"})
	aStruF3A := RU09XFN013(aStruF3A, "F3A", {"_CNEE_B", "_CNEE_C", "_CNOR_B", "_CNOR_C"})

	aArea := GetArea()
	aAreaSX3 := SX3->(GetArea())

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If (SX3->(DbSeek("F39_FILIAL")))
		aStruF39:AddField( ;                                                         // Ord. Tipo Desc.
		"XX_FILIAL" , ;              // [01] C Nome do Campo
		"00" , ;                      // [02] C Ordem
		X3Titulo() , ;                             // [03] C Titulo do campo
		X3Descric() , ; // [04] C Descrição do campo
		{ '' } , ;        // [05] A Array com Help
		'C' , ;                       // [06] C Tipo do campo
		PesqPict("F39", "F39_FILIAL") , ;                    // [07] C Picture
		NIL , ;                       // [08] B Bloco de Picture Var
		'' , ;                        // [09] C Consulta F3
		.F. , ;                       // [10] L Indica se o campo é evitável
		NIL , ;                       // [11] C Pasta do campo
		NIL , ;                       // [12] C Agrupamento do campo
		NIL , ;                       // [13] A Lista de valores permitido do campo (Combo)
		NIL , ;                       // [14] N Tamanho Maximo da maior opção do combo
		NIL , ;                       // [15] C Inicializador de Browse
		.T. , ;                       // [16] L Indica se o campo é virtual
		NIL )                         // [17] C Picture Variável
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

	oView := FwFormView():New()

	oView:SetModel(oModel)

	oView:AddField("VIEW_F39", aStruF39, "F39MASTER")

	oView:CreateHorizontalBox("HEADER", Iif(INCLUI, 90, 40))

	oView:SetOwnerView("VIEW_F39", "HEADER")

	If !(INCLUI .Or. (FwIsInCallStack("gravaBook")))
		oView:AddGrid("VIEW_F3A", aStruF3A, "F3ADETAIL")
		oView:AddGrid("VIEW_F63P", aStruF63P, "F63PDETAIL")
		oView:AddGrid("VIEW_F63R", aStruF63R, "F63RDETAIL")

		oView:CreateHorizontalBox("DETAIL", 50)

		oView:CreateFolder('FOLDER1', 'DETAIL')
		oView:AddSheet('FOLDER1', 'Sheet1', STR0041) // "Commercial Invoices"
		oView:AddSheet('FOLDER1', 'Sheet2', STR0042) // "Advances Paid"
		oView:AddSheet('FOLDER1', 'Sheet3', STR0043) // "Advances Received"

		oView:CreateHorizontalBox("F3ABOX", 100/*%*/,,,'FOLDER1', 'Sheet1')
		oView:SetOwnerView("VIEW_F3A", "F3ABOX")
		oView:SetViewProperty("VIEW_F3A", "GRIDFILTER", {.T.})
		oView:SetViewProperty("VIEW_F3A", "GRIDSEEK", {.T.})

		oView:CreateHorizontalBox("F63PBOX", 100/*%*/,,,'FOLDER1', 'Sheet2')
		oView:SetOwnerView("VIEW_F63P", "F63PBOX")
		oView:AddIncrementField("VIEW_F63P", "F63_ITEM")

		oView:CreateHorizontalBox("F63RBOX", 100/*%*/,,,'FOLDER1', 'Sheet3')
		oView:SetOwnerView("VIEW_F63R", "F63RBOX")
		oView:AddIncrementField("VIEW_F63R", "F63_ITEM")

		If ((F39->F39_STATUS $ "2|3| " .Or. F39->F39_AUTO == "1") .And. !(FwIsInCallStack("gravaBook")))
			aStruF3A:SetProperty('F3A_DOC',	MVC_VIEW_CANCHANGE, .F.)
		ElseIf (F39->F39_AUTO == "2")
			oView:AddUserButton(STR0044, '', {|| oModelEvent:R09T4AInc(oModel)}) //Aut. Commercial Inv.
			oView:AddUserButton(STR0045, '', {|| oModelEvent:R09T4APay(oModel)}) //Aut. Payment Adv.
			oView:AddUserButton(STR0046, '', {|| oModelEvent:R09T4ARec(oModel)}) //Aut. Receivement Adv.
		EndIf

		oView:AddUserButton(STR0012, '', {|| RUVATInvcV(oModel)})
		oView:AddUserButton(STR0047, '', {|| RUVATInExp(oModel, 1)}) //Export All
		oView:AddUserButton(STR0048, '', {|| RUVATInExp(oModel, 2)}) //Export Commercial Invoice
		oView:AddUserButton(STR0049, '', {|| RUVATInExp(oModel, 3)}) //Export Advances Paid
		oView:AddUserButton(STR0050, '', {|| RUVATInExp(oModel, 4)}) //Export Advances Received
	EndIf

	oView:AddField("F39_TOTAL", aStructTotal, "F39MASTER")

	oView:CreateHorizontalBox("TOTAL_BOX", 10)

	oView:SetOwnerView("F39_TOTAL", "TOTAL_BOX")

	oView:SetViewCanActivate({|oView| RU09T0401(oView)})

Return(oView)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T0401

Model prevalidation, check if we have the key at F33 table

@param       OBJECT oModel
@return      LOGICAL lOk
@example     
@author      rafael.goncalves
@since       06/04/2020
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU09T0401(oView)
	Local lRet     AS LOGICAL
	Local aArea 	as Array
	Local aAreaF33 	as Array

	aArea		:= GetArea()
	aAreaF33	:= F33->(GetArea())
	lRet := .T.

//RU09D03NMB("SABOID") at F39_BOOKEY                                                                                                        
	If oView:GetOperation() == MODEL_OPERATION_INSERT
		//Check if we have the index auto numering at F33 Table, if not avoid continues the routine
		//Position head F33 register
		F33->(dbSetOrder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
		If 	F33->(! dbSeek(xFilial("F33") + "SABOID" + Space(GetSX3Cache("F33_SERIE", "X3_TAMANHO")) + "1" + "1" + cFilAnt)) .And. ;
				F33->(! dbSeek(xFilial("F33") + "SABOID" + Space(GetSX3Cache("F33_SERIE", "X3_TAMANHO")) + "1" + "2"))
			lRet := .F.
			RU99XFUN05_Help(STR0039) //"No active numbering record control exists for this key series combination, before continues is madatory add the key SABOID at routine RU06D03."
		EndIf
	EndIf
	RestArea(aAreaF33)
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} ModelRec
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/

Static Function ModelRec(oModel)
	Local lRet := .T.
	Local oModelF3A as Object
	Local cCode := ''
	Local cBooKey as Character
	Local nItem as numeric
	Local cKey as Char
	Local nOperation as numeric
	Local aArea as array
	Local oModelF39	:= oModel:GetModel('F39MASTER')
	oModelF3A := oModel:GetModel('F3ADETAIL')

	nOperation := oModel:GetOperation()
	BEGIN TRANSACTION
		If((nOperation == MODEL_OPERATION_UPDATE) .OR. (nOperation == MODEL_OPERATION_DELETE) .Or. (FwIsInCallStack("gravaBook")))
			aArea := GetArea()
			oModelF3A:GoLine(1)
			For nItem := 1 To oModelF3A:Length()
				oModelF3A:GoLine(nItem)
				cKey		:= AllTrim(oModelF3A:GetValue('F3A_KEY'))
				cCode		:= oModelF39:GetValue('F39_CODE')
				cBooKey		:= oModelF39:GetValue('F39_BOOKEY')
				DbSelectArea("F35")
				F35->(DbSetOrder(3))
				If !(Empty(cKey))
					If F35->(DbSeek(xFilial('F35')+ cKey))
						RecLock("F35", .F.)
						If (nOperation == MODEL_OPERATION_DELETE)
							F35->F35_BOOK := ''
							F35->F35_BOOKEY := ''
						Else
							F35->F35_BOOK := Iif(oModelF3A:IsDeleted(), "", cCode)
							F35->F35_BOOKEY := Iif(oModelF3A:IsDeleted(), "", cBooKey)
							F35->F35_BOOKEY := Iif(oModelF3A:IsDeleted(), "", cBooKey)
						EndIf
						F35->(MsUnlock())
					EndIf
				EndIf
			Next nItem
			RestArea(aArea)

			// Commit.
			lRet := lRet .and. FWFormCommit(oModel)
		Else
			// Just commit.
			lRet := lRet .and. FWFormCommit(oModel)
		EndIf
//Confirme SXE
		If lRet .and.  ((nOperation == MODEL_OPERATION_INSERT) .Or. (FwIsInCallStack("gravaBook")))
			ConfirmSX8()
		Endif


	END TRANSACTION
Return lRet

/*/{Protheus.doc} RU09T04Vis
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function RU09T04Vis()
	Local lRet := .T.
	lRet := lRet .and. FwExecView(STR0003, "RU09T04", MODEL_OPERATION_VIEW)
Return(lRet)

/*/{Protheus.doc} RU09T04Inc
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function RU09T04Inc()
	Local lRet := .T.
	lRet := lRet .and. FwExecView(STR0004, "RU09T04", MODEL_OPERATION_INSERT)
Return(lRet)

/*/{Protheus.doc} RU09T04Upd
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function RU09T04Upd()
	Local lRet := .T.
	If F39->F39_STATUS != "3"
		lRet := lRet .and. FwExecView(STR0005, "RU09T04", MODEL_OPERATION_UPDATE)
	Else
		RU99XFUN05_Help(STR0032) //This Sales Book is closed. Only deletion is possible.
	EndIf
Return(lRet)

/*/{Protheus.doc} RU09T04Exc
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function RU09T04Exc()
	Local lRet := .T.
	lRet := lRet .and. FwExecView(STR0006, "RU09T04", MODEL_OPERATION_DELETE)
Return(lRet)



/*/{Protheus.doc} RUVATInvcV
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function RUVATInvcV(oModel)
	Local aAreaF35 as Array
	Local oModelInvc as Object
	Local cKey as Character

	aAreaF35 := getArea()
	oModelInvc := oModel:GetModel('F3ADETAIL')
	cKey := AllTrim(oModelInvc:GetValue("F3A_KEY"))

	If !Empty(cKey)
		dbSelectArea('F35')
		F35->(DbSetOrder(3))
		If F35->(DbSeek(xFilial('F35')+ cKey))
			FWExecView(STR0003,"RU09T02",MODEL_OPERATION_VIEW,,{|| .T.})
		EndIf
		RestArea(aAreaF35)
	EndIf
	oModelInvc:GoLine(1)
Return

/*/{Protheus.doc} RUVATInExp
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/

Function RUVATInExp(oModel, nOpc)
	Local lRet := .T.
	Local cArq as Character
	Local nHandle as Numeric

	cArq := cGetFile("File CSV | *.csv", "File .CSV", 1, "C:\", .F., GETF_LOCALHARD, .F., .T.)

	If (!Empty(cArq))
		nHandle := FCreate(cArq)

		If !(nHandle == -1)
			Processa({|| gravaReg(@nHandle, oModel, nOpc)}, STR0028, STR0029, .F.)

			FClose(nHandle)

			RU99XFUN05_Help(STR0025)
		Else
			RU99XFUN05_Help(STR0026)
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc} gravaReg
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}
@param nHandle, numeric, descricao
@param oModel, object, descricao
@type function
/*/

Static Function gravaReg(nHandle, oModel, nOpc)
	Local lRet := .T.
	Local aArea as Array
	Local aAreaF3A as Array
	Local aAreaF39 as Array
	Local aAreaF63 as Array
	Local aStructF39 as Array
	Local aStructF3A as Array
	Local aStructF63 as Array
	Local oModelF39 as Object
	Local cBookKey :=''
	Local cFilF39 :=''

	aArea := GetArea()
	aAreaF3A := F3A->(GetArea())
	aAreaF39 := F39->(GetArea())
	aAreaF63 := F63->(GetArea())
	aStructF3A := F3A->(DbStruct())
	aStructF39 := F39->(DbStruct())
	aStructF63 := F63->(DbStruct())
	oModelF39 := oModel:GetModel("F39MASTER")
	cBookKey := oModelF39:GetValue("F39_BOOKEY")
	cFilF39 := oModelF39:GetValue("F39_FILIAL")

	DbSelectArea("F39")
	F39->(DbSetOrder(1)) //F39_FILIAL+F39_BOOKEY
	DbSelectArea("F3A")
	F3A->(DbSetOrder(1)) // F3A_FILIAL+F3A_BOOKEY+F3A_DOC+DTOS(F3A_PDATE)+F3A_VATCOD+F3A_VATCD2
	F3A->(DbGoTop())

	If (F39->(DbSeek(cFilF39+cBookKey)))
		// Writes the titles of header data.
		RU09XFN021_WriteHead(nHandle, aStructF39)

		// Writes the header data.
		While ((F39->(!Eof())) .And. (F39->(F39_FILIAL+F39_BOOKEY) == cFilF39+cBookKey))
			RU09XFN022_WriteData(nHandle, aStructF39, "F39", STR0029)
			F39->(DbSkip())
		EndDo

		If nOpc == 1 .Or. nOpc == 2
			If (F3A->(DbSeek(cFilF39+cBookKey)))
				// Writes the titles of details data.
				FWrite(nHandle, "" + CRLF)
				RU09XFN021_WriteHead(nHandle, aStructF3A)

				// Writes details data.
				While (F3A->(!Eof())) .And. F3A->(F3A_FILIAL + F3A_BOOKEY) == cFilF39 + cBookKey
					
					RU09XFN022_WriteData(nHandle, aStructF3A, "F3A", STR0029)
					F3A->(DbSkip())

				EndDo
			EndIf
		EndIf

		If nOpc == 1 .Or. nOpc == 3

			If (F63->(DbSeek(xFilial("F63", cFilF39) + cBookKey)))
				// Writes the titles of details data.
				FWrite(nHandle, "" + CRLF)
				RU09XFN021_WriteHead(nHandle, aStructF63)

				// Writes details data.
				While !F63->(Eof()) .And. F63->F63_FILIAL == xFilial("F63", cFilF39) .And. F63->F63_BOOKEY == cBookKey
					If F63->F63_TYPE == "1" //Adv Payment
						RU09XFN022_WriteData(nHandle, aStructF63, "F63", STR0029)
					EndIf
					F63->(DbSkip())
				EndDo
			EndIf

		EndIf

		If nOpc == 1 .Or. nOpc == 4

			If (F63->(DbSeek(xFilial("F63", cFilF39) + cBookKey)))
				// Writes the titles of details data.
				FWrite(nHandle, "" + CRLF)
				RU09XFN021_WriteHead(nHandle, aStructF63)

				// Writes details data.
				While !F63->(Eof()) .And. F63->F63_FILIAL == xFilial("F63", cFilF39) .And. F63->F63_BOOKEY == cBookKey
					If F63->F63_TYPE == "2" //Adv Received
						RU09XFN022_WriteData(nHandle, aStructF63, "F63", STR0029)
					EndIf
					F63->(DbSkip())
				EndDo
			EndIf
		EndIf

	EndIf

	RestArea(aAreaF63)
	RestArea(aAreaF39)
	RestArea(aAreaF3A)
	RestArea(aArea)
Return(lRet)
// The end of the Function gravaReg

/*{Protheus.doc} RU09T04Name
@description Used in X3_RELACAO of F3A_NAME field
@author UNKNOWN
@since UNKNOWN DATE
@version 1.0
@project MA3 - Russia
*/
Function RU09T04Name()
	Local cName := ""
	Local cKey := ""
	Local aArea := GetArea()
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaF35 := F35->(GetArea())

	DbSelectArea("F35")
	F35->(DbSetOrder(3))

	If (F35->(DbSeek(xFilial("F35") + F3A->F3A_KEY)))
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		cKey := F35->(F35_CLIENT + F35_BRANCH)
		If !Empty(AllTrim(cKey)) .and. (SA1->(DbSeek(xFilial("SA1") + cKey)))
			cName := SA1->A1_NREDUZ
		EndIf
	EndIf

	RestArea(aAreaF35)
	RestArea(aAreaSA1)
	RestArea(aArea)
Return(cName)
                   
//Merge Russia R14 
                   
