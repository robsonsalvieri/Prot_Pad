#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RU34XREP.CH'

#DEFINE CLRF CHR(13)+CHR(10)

Static __cNotFound  := 'notfound'
Static __cCredit    := '02'
Static __mParams
/*/{Protheus.doc} RU34XREP01(cProgName, lBrowse)
    This function runs synchronization with analytics

    @type Function
    @param cProgName = String with program name, example CRMA980RUS
    @param lBrowse = Logical, if called from browse then true, else false

    @return lRet

    @author Dmitry Borisov
    @since 2023/10/02
    @version 12.1.33
    @example RU34XREP01(cProgName, lBrowse)
*/
Function RU34XREP01(cProgName, lBrowse)
    Local lRet        := .T.
    Local cTabName    := ''
    Local cDesc       := ''
    Local cKey        := ''
    Local cTabAlias   := ''
    Local nNivEnt     := 0
    Default cProgName := ''

    If __mParams == Nil
        RU34XREP08()
    EndIf

    If __mParams == Nil .Or. __mParams:get(cProgName) == Nil .Or. Empty(AllTrim(cProgName))
        If !IsBlind()
            ApMsgInfo(STR0016,STR0003)//Analytics synchronization is not configured
        EndIf
        lRet := .F.
    EndIf

    If lRet
        // Get params from F5A
        nNivEnt     := IIf(!Empty(AllTrim(__mParams:get(cProgName)[1])) .And. __mParams:get(cProgName)[1] <> Nil, Val(__mParams:get(cProgName)[1]), 0)
        cKey        := IIf(!Empty(AllTrim(__mParams:get(cProgName)[3])) .And. __mParams:get(cProgName)[3] <> Nil, __mParams:get(cProgName)[3], __cNotFound)
        cDesc       := IIf(!Empty(AllTrim(__mParams:get(cProgName)[4])) .And. __mParams:get(cProgName)[4] <> Nil, __mParams:get(cProgName)[4], __cNotFound)
        cTabName    := IIf(!Empty(AllTrim(__mParams:get(cProgName)[5])) .And. __mParams:get(cProgName)[5] <> Nil, __mParams:get(cProgName)[5], __cNotFound)

        If lBrowse
            cKey := StrTran(cKey,'M->', cTabName + '->',1, Len(cKey))
            cDesc := StrTran(cDesc,'M->',cTabName + '->',1, Len(cDesc))
            cTabAlias := cTabName
        Else
            cKey := StrTran(cKey, cTabName + '->','M->',1, Len(cKey))
            cDesc := StrTran(cDesc, cTabName + '->','M->',1, Len(cDesc))
            cTabAlias := 'M'
        EndIf
        If lRet := RU34XREP02_DataValidation(nNivEnt, cKey, cTabName, cDesc, cProgName) 
            RU34XREP03_AnalyticsAutofill(nNivEnt, &(cKey), &(cDesc), cTabName, cProgName, lBrowse, cTabAlias)
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} RU34XREP02_DataValidation(nNivEnt, cKey, cTabName)
    This function runs validation logic

    @type Function
    @param nNivEnt = Numeric, number of analytic
    @param cKey = String with field name, which will be used as key, example: M->N1_CHAPA
    @param cTabName = String with table name, example: SN1
    @param cDesc = String, description key , example: SN1->N1_CHAPA
    @param cProgName = String, with routine name, example: "CRMA980"

    @return lRet

    @author Dmitry Borisov
    @since 2023/10/02
    @version 12.1.33
    @example RU34XREP02_DataValidation(nNivEnt, cKey, cTabName, cDesc, cProgName)
*/
Function RU34XREP02_DataValidation(nNivEnt, cKey, cTabName, cDesc, cProgName)
    Local lRet      := .T.
    Local cMessage  := ''
    Local aTable    := {} 
    Local aArea     := {}

    If lRet .And. nNivEnt == 0 .Or. cKey == __cNotFound .Or. cDesc == __cNotFound .Or. cTabName == __cNotFound// Analytics parameter2 exists validation
        cMessage := STR0014
        lRet := .F.
    EndIf

    // Access validation
    If lRet .And. nNivEnt > 4

        aArea := CT0->(GetArea())

        dbSelectArea("CT0")
        dbSetOrder(1) // CT0_FILIAL+CT0_ID

        If !CT0->(dbSeek(xFilial("CT0") + __mParams:get(cProgName)[1]))
            lRet := .F.
            cMessage := STR0020 // Analytics cannot be created because its use is not configured in the system.
        Else
            If CT0->CT0_ENTIDA <> __mParams:get(cProgName)[1]
                lRet := .F.
                cMessage := STR0020 // Analytics cannot be created because its use is not configured in the system.
            EndIf
        EndIf

        RestArea(aArea)
    EndIf

    // Sharing settings validation
    If lRet .And. __mParams:get(cProgName)[2] == 'CV0'

        aArea := SX2->(GetArea())

        dbSelectArea("SX2")
        dbSetOrder(1) // X2_CHAVE
        If !SX2->(dbSeek(cTabName))
            lRet := .F.
            cMessage := cTabName + STR0021 // table not found. 
        Else
            While SX2->(!Eof()) .And. SX2->X2_CHAVE == cTabName
                aAdd(aTable, SX2->X2_MODO)
                aAdd(aTable, SX2->X2_MODOUN)
                aAdd(aTable, SX2->X2_MODOEMP)
                SX2->(dbSkip())
            EndDo
            If lRet .And. !Empty(aTable)
                If !SX2->(dbSeek(__mParams:get(cProgName)[2]))
                    lRet := .F.
                    cMessage := __mParams:get(cProgName)[2] + STR0021 // table not found. 
                Else
                    While SX2->(!Eof()) .And. SX2->X2_CHAVE == __mParams:get(cProgName)[2]
                        If (SX2->X2_MODO <> aTable[1] .And. SX2->X2_MODO == 'E') .Or.;
                        (SX2->X2_MODOUN <> aTable[2] .And. SX2->X2_MODOUN == 'E') .Or.;
                        (SX2->X2_MODOEMP <> aTable[3] .And. SX2->X2_MODOEMP == 'E')
                            lRet := .F.
                            cMessage := STR0019 // Synchronization with analytics was not performed. Access to branches of the register table and analytics tables is not set up correctly. 
                        EndIf
                        SX2->(dbSkip())
                    EndDo
                EndIf
            EndIf
        EndIf

        RestArea(aArea)
    EndIf

    // Data validation
    If lRet .And. Empty(AllTrim(&(cKey))) // Analytics parameter2 value validation
        cMessage := STR0015 // In parameter 2, the key for generating the code is not specified
        lRet := .F.
    EndIf
    If lRet .And. (Len(AllTrim(&(cKey))) > TamSX3('CTT_CUSTO')[1] .And. nNivEnt == 2) .Or.;
        (Len(AllTrim(&(cKey))) > TamSX3('CTD_ITEM')[1] .And. nNivEnt == 3) .Or.;
        (Len(AllTrim(&(cKey))) > TamSX3('CTH_CLVL')[1] .And. nNivEnt == 4) .Or.;
        (Len(AllTrim(&(cKey))) > TamSX3('CV0_CODIGO')[1] .And. nNivEnt >= 6)
        cMessage := STR0001 // The code size exceeds the maximum length of the Analytics code.
        lRet := .F.
    EndIf

    If !lRet
        If !IsBlind()
            ApMsgInfo(STR0006 + cMessage) //Validation error
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} RU34XREP03_AnalyticsAutofill(nNivEnt, cKey, cRepDescPar, cTabName, cTabAlias)
    This function runs validation logic

    @type Function
    @param nNivEnt = Numeric, number of analytic
    @param cKey = String with field value, which will be used as key
    @param cDesc = String with description field value
    @param cTabName = String with table name, example: SN1
    @param lBrowse = Logical, if called from browse then true, else false
    @param cTabAlias = String with param for data request, example: "SN1->" or "M->"

    @return lRet

    @author Dmitry Borisov
    @since 2023/10/02
    @version 12.1.33
    @example RU34XREP03_AnalyticsAutofill(nNivEnt, cKey, cDesc, cTabName, cTabAlias)
*/
Function RU34XREP03_AnalyticsAutofill(nNivEnt, cKey, cDesc, cTabName, cProgName, lBrowse, cTabAlias)
    Local lRet         := .T.
    Local aMemosClo    := {}
    Local aArea        := {}
    Local nDirection as Numeric
    Private aDadosAuto := {}
    Private lMsHelpAut := .F.
    Private lMsErroAut := .F.

    If IsBlind()
        lRet := .F.
    EndIf

    If lRet
        If __mParams:get(cProgName)[2] == 'CTT'.Or. __mParams:get(cProgName)[2] == 'CTD' .Or. __mParams:get(cProgName)[2] == 'CTH'
            If Len(cDesc) > TamSX3(__mParams:get(cProgName)[2] + '_DESC01')[1]
                cDesc := LEFT(cDesc, TamSX3(__mParams:get(cProgName)[2] + '_DESC01')[1])
            EndIf

            aArea := (__mParams:get(cProgName)[2])->(GetArea())

            DbSelectArea(__mParams:get(cProgName)[2])
            (__mParams:get(cProgName)[2])->(DBSetOrder(1))
            nOper := IIf((__mParams:get(cProgName)[2])->(DBSeek(xFilial(__mParams:get(cProgName)[2]) + cKey)),4,3)

            If !IsBlind() .And. nOper == 3
                lRet := RU34XREP04_UserDecision(cValToChar(nNivEnt), cKey, cDesc)
            EndIf

            If lRet
                If __mParams:get(cProgName)[2] == 'CTT'
                    aDadosAuto := {{'CTT_CUSTO', cKey, Nil}}
                ElseIf __mParams:get(cProgName)[2] == 'CTD'
                    aDadosAuto := {{'CTD_ITEM' , cKey, Nil}}
                ElseIf __mParams:get(cProgName)[2] == 'CTH'
                    aDadosAuto := {{'CTH_CLVL' , cKey, Nil}}
                EndIf
                
                aAdd(aDadosAuto, {__mParams:get(cProgName)[2] + '_CLASSE', '2', Nil})
                aAdd(aDadosAuto, {__mParams:get(cProgName)[2] + '_DESC01', cDesc, Nil})
                aAdd(aDadosAuto, {__mParams:get(cProgName)[2] + '_BLOQ', IIF(nOper==3,'2',(__mParams:get(cProgName)[2])->&(__mParams:get(cProgName)[2] + '_BLOQ')), Nil})
                
                lRet := CtbMovSaldo(__mParams:get(cProgName)[2])
                lMsErroAut := .F.
                RU34XREP09(aMemosClo,.T.)
                MSExecAuto({|x, y| IIf(__mParams:get(cProgName)[2] == 'CTT', CTBA030(x, y), IIf(__mParams:get(cProgName)[2] == 'CTD', CTBA040(x, y), CTBA060(x, y)))}, aDadosAuto, nOper)
                RU34XREP09(aMemosClo,.F.)

                If lMsErroAut
                    MostraErro()
                    lRet := .F.
                EndIf
            EndIf

            RestArea(aArea)

        ElseIf __mParams:get(cProgName)[2] == 'CV0'
            If Len(cDesc) > TamSX3(__mParams:get(cProgName)[2] + '_DESC')[1]
                cDesc := LEFT(cDesc, TamSX3(__mParams:get(cProgName)[2] + '_DESC')[1])
            EndIf
            cPlano := StrZero(nNivEnt,GetSx3Cache(__mParams:get(cProgName)[2] + '_PLANO','X3_TAMANHO'))

            If cTabName == 'F5Q'
                Do Case
                    Case AllTrim(&((cTabAlias) + "->F5Q_TYPE")) == __cCredit
                        nDirection := 2
                    Otherwise
                        nDirection := 1
                EndCase
            EndIf

            aArea := CV0->(GetArea())
            DBSelectArea('CV0')
            CV0->(DBSetOrder(1))
            nOper := IIf(CV0->(DBSeek(xFilial('CV0') + cPlano + cKey)),4,3)
            cItem := CtbCV0Item(cPlano, cKey, nOper) //get next item number

            If !IsBlind() .And. nOper == 3
                lRet := RU34XREP04_UserDecision(cValToChar(nNivEnt), cKey, cDesc)
            EndIf

            If lRet
                RecLock('CV0', IIf(nOper == 3,.T.,.F.))
                    ('CV0')->(FieldPut(FieldPos('CV0_FILIAL') , xFilial('CV0')))
                    ('CV0')->(FieldPut(FieldPos('CV0_PLANO') , cPlano))
                    ('CV0')->(FieldPut(FieldPos('CV0_CODIGO'), cKey))
                    ('CV0')->(FieldPut(FieldPos('CV0_ITEM')  , cItem))
                    ('CV0')->(FieldPut(FieldPos('CV0_DESC')  , cDesc))
                    ('CV0')->(FieldPut(FieldPos('CV0_CLASSE'), '2'))
                    ('CV0')->(FieldPut(FieldPos('CV0_BLOQUE'), IIF(nOper == 3,'2', CV0->CV0_BLOQUE)))
                    ('CV0')->(FieldPut(FieldPos('CV0_NORMAL'), IIF(nDirection == 1,'1', '2')))
                CV0->(MSUnlock())
            EndIf
            RestArea(aArea)
        Else
            lRet := .F.
            If !IsBlind()
                ApMsgInfo(STR0002,STR0003) //Incorrect analytics number, An error has occurred
            EndIf
        EndIf
    EndIf

    If lRet
        RU34XREP05_UpdateRegisterTable(nNivEnt, cKey, cTabName, cTabAlias)
        If !IsBlind()
            ApMsgInfo(STR0004,STR0005) //Analytics fields updated successfully, Done
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} RU34XREP05_UpdateRegisterTable(nNivEnt, cKey, cTabName, cTabAlias)
    This function runs update fields in defined groups

    @type Function
    @param nNivEnt = Numeric, number of analytic
    @param cKey = String with field value, which will be used as key
    @param cTabName = String with table name, example: SN1
    @param cTabAlias = String with request param, it's store variable "M", or table alias, example: "M" or "SN1"

    @return lRet

    @author Dmitry Borisov
    @since 2023/10/02
    @version 12.1.33
    @example RU34XREP05_UpdateRegisterTable(nNivEnt, cKey, cTabName, cTabAlias)
*/

Function RU34XREP05_UpdateRegisterTable(nNivEnt, cKey, cTableName, cTabAlias)
	Local lRet       := .T.
	Local aGroups    := {{2, '004'},;
                         {3, '005'},;
                         {4, '006'},;
                         {5, '040'},;
                         {6, '042'},;
                         {7, '043'},;
                         {8, '044'},;
                         {9, '045'}}
    Local cFieldGrp  := aGroups[AScan(aGroups, { |x| x[1] == nNivEnt}),2]
    Local cAliasTMP  := GetNextAlias()
    Local aGrpFields := {}
    Local aFieldPos  := {}
    Local aArea      := {}
    Local cQuery As Character
    Local nCount As Numeric
    Local nX     As Numeric
    Local nPos   As Numeric
    Local oModel As Object

	//Getting fields for choosen group from SX3
	cQuery := "SELECT X3_ARQUIVO, X3_CAMPO "
	cQuery += "FROM " + RetSqlName("SX3") + " SX3 "
	cQuery += "WHERE "
	If cTableName == 'SN1'
		cQuery += "X3_ARQUIVO IN ('SN1','SN3"
	Else
		cQuery += "X3_ARQUIVO IN ('" + cTableName
	EndIf
	cQuery += "') AND X3_GRPSXG = '" + cFieldGrp + "'"
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAliasTMP)
	While .Not.(cAliasTMP)->(EOF())
		If X3USO(GetSX3Cache(alltrim((cAliasTMP)->X3_CAMPO), "X3_USADO"))
			AAdd(aGrpFields, {alltrim((cAliasTMP)->X3_ARQUIVO),alltrim((cAliasTMP)->X3_CAMPO)})
		EndIf
		(cAliasTMP)->(dbSkip())
	Enddo
	
	//Update fields in register table
	If Len(aGrpFields) > 0
		For nCount := 1 To Len(aGrpFields)
			nPos := (aGrpFields[nCount][1])->(FieldPos(aGrpFields[nCount][2]))
			If nPos > 0
				AAdd(aFieldPos, nPos)
			Else
				lRet := .F.
				Exit
			EndIf
		Next nCount

        aArea := GetArea()
		If cTableName == 'SN1' .And. lRet
            oModel := FWModelActive()
            If oModel <> Nil .And. (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
                oModel := oModel:GetModel("SN3DETAIL")
                For nCount := 1 To oModel:Length()
                    oModel:GoLine(nCount)
                    If !oModel:IsDeleted()
                        For nX := 1 To Len(aGrpFields)
                            oModel:SetValue(aGrpFields[nX][2],AllTrim(cKey))
                        Next nX
                    EndIf
                Next nCount
            Else
                SN3->(dbSetOrder(1))//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
                SN3->(dbGoTop())
                SN3->(DBSeek(xFilial('SN3')+&((cTabAlias) + "->N1_CBASE")+&((cTabAlias) + "->N1_ITEM")))
                While SN3->N3_CBASE == &((cTabAlias) + "->N1_CBASE") .And. SN3->N3_ITEM == &((cTabAlias) + "->N1_ITEM") .And. &((cTabAlias) + "->N1_STATUS") == '0' .And. SN3->(!EOF())
                    For nCount := 1 To Len(aGrpFields)
                        RecLock(aGrpFields[nCount][1], .F.)
                        If (aGrpFields[nCount][1])->&(aGrpFields[nCount][2]) != cKey
                            (aGrpFields[nCount][1])->(FieldPut(aFieldPos[nCount],cKey))
                        EndIf
                        MSUnlock(aGrpFields[nCount][1])
                    Next nCount
                    SN3->(DbSkip())
                EndDo
            EndIf
		ElseIf lRet
			For nCount := 1 To Len(aGrpFields)
				RecLock(aGrpFields[nCount][1], .F.)
				If (aGrpFields[nCount][1])->&(aGrpFields[nCount][2]) != cKey
					(aGrpFields[nCount][1])->(FieldPut(aFieldPos[nCount],cKey))
				EndIf
				MSUnlock(aGrpFields[nCount][1])
			Next nCount
		EndIf
        RestArea(aArea)
	EndIf
Return lRet

/*/{Protheus.doc} RU34XREP04_UserDecision(cNivEnt, cKey, cDesc)
    This function open message with choice Yes/No

    @type Function
    @param cNivEnt = String with number of analytic
    @param cKey = String with field value, which will be used as key
    @param cDesc = String with description field value

    @return lRet

    @author Dmitry Borisov
    @since 2023/10/02
    @version 12.1.33
    @example RU34XREP04_UserDecision(cNivEnt, cKey, cDesc)
*/

Static Function RU34XREP04_UserDecision(cNivEnt, cKey, cDesc)
	Local lRet := .T.

    lRet := ApMsgYesNo(STR0007 + cNivEnt + STR0008 + cKey + STR0009 + cDesc + CLRF + STR0010, STR0011)
	// Analytic + cNivEnt + record will be created with code + cKey +  and name + cDesc + Proceed?, Attention
Return lRet

/*/{Protheus.doc} RU34XREP08_GetParams()
    This function prepare map with analytis params
    Key - string, routine name (F5A_PRNAME), example: "CRMA980"
    Value - array with analityc table name (F5A_ANTABL), and analytic key (F5A_ANKEY)
    Value[1] - String, with analytic code from CT0 table (CT0_ID field), example: "07"
    Value[2] - String, with analytic table alias from CT0 table (CT0_ALIAS field), example: "CV0"
    Value[3] - String, with analytic unique key, example: "M->AF8_PROJET"
    Value[4] - String, with analytic description, example: "M->AF8_DESCRI"
    Value[5] - String, with source table alias, example: "AF8"

    @type Function
    @return

    @author Dmitry Borisov
    @since 2023/10/17
    @version 12.1.33
    @example RU34XREP08_GetParams()
*/
Function RU34XREP08_GetParams()
    Local aArea := F5A->(GetArea())

    __mParams := FwHashMap():New()
    DbSelectArea('F5A')
    DbSetOrder(1)
    DbGoTop()

    While !F5A->(Eof())
        If xFilial('F5A') == F5A->F5A_FILIAL
            __mParams:put(AllTrim(POSICIONE("SX5",1,XFILIAL("SX5")+"2B"+F5A->F5A_PRCODE,"X5DESCRI()")), {AllTrim(F5A->F5A_ANCODE), AllTrim(POSICIONE("CT0",1,XFILIAL("CT0")+F5A->F5A_ANCODE,"CT0->CT0_ALIAS")), AllTrim(F5A->F5A_ANKEY), AllTrim(F5A->F5A_PRDESC), AllTrim(F5A->F5A_PRTABL)})
        EndIf
        F5A->(DbSkip())
    EndDo
    RestArea(aArea)
Return 

/*/{Protheus.doc} RU34XREP09_ReassignaMemos(aMemosClo, lReplace)
    This function change values in private array aMemos

    @type Function
    @param aMemosClo = Array, for keep aMemos values
    @param lReplace = Logic, if true then replace values in aMemos, if false then restore previous values aMemos

    @return aMemos

    @author Dmitry Borisov
    @since 2023/10/12
    @version 12.1.33
    @example RU34XREP09_ReassignaMemos(aMemosClo, lReplace)
*/

Function RU34XREP09_ReassignaMemos(aMemosClo, lReplace)
    Local nPos := 0

    If lReplace
        If Type("aMemos") == "A" .And. !Empty(aMemos)
            aMemosClo := aClone(aMemos)
            nPos := aScan(aMemos[1], "AF8_CODMEM" ) 
            If nPos > 0
                aMemos[1,nPos] :=""
            EndIf
        EndIf
    Else
        aMemos := aMemosClo
    EndIf
Return 
                   
//Merge Russia R14 
                   
