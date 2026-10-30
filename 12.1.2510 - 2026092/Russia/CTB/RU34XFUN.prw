#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} 
// Management Accounting Generic Function

@author Victor Guberniev
@since 28/03/2018
@version MA3 - Russia
/*/

Function SelectNotEmpty(cPar1 as Character, cPar2 as Character)
Local cRet as Character

If !(Empty(cPar1))
   cRet := cPar1
Else 
   cRet := cPar2
EndIf         

Return cRet

/*/{Protheus.doc} RU34XFUN
Function to get the value of the specified parameters from the table Accounting groups

description:
    The parameter cRequested may have two states - '1' or '2'
    '1' - for F46_OWNER == 'PD' (Product)
        Other parameters:
        cCode - Account Group Code (F46_CODE)
        cProdCode - Product Code (B1_COD)
        cWarOrCon - Warehouse Code (NNR_CODIGO)
    '2' - for F46_OWNER == 'PT' (Parther)
        Other parameters:
        cCode - Account Group Code (F46_CODE)
        cProdCode - not use for Partners
        cWarOrCon - Contract code (F5Q_CODE)
    cExpected - The field that you want to return. It may have a four states:
      '1' - returns Ledger Account (F46_CONTA)
      '2' - returns Cost Center (F46_CCUSTO)
      '3' - returns Accounting Item (F46_ITEMCC)
      '4' - returns Value Class (F46_CLVL)

FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function GetAccEnt(cRequested as Character, cCode as Character, cProdCode as Character, cWarOrCon as Character, cExpected as Character)

Local cTab              as Character
Local nCurType          as Numeric
Local cCurType          as Character
Local lPriority         as Logical
Local lPriorDif         as Logical
Local cWHType           as Character
Local cContrType        as Character
Local aArea             as Array
Local cQuery            as Character
Local aRawResult        as Array 
Local cProdType         as Character
Local cResult           as Character
Local aMvPar            as Array
Local nX                as Numeric  

Default cCode       := ''
Default cProdCode   := '' 
Default cWarOrCon   := ''
Default cRequested  := ''
Default cExpected   := ''

nX          := 1
aMvPar      := {}
cWHType     := PadR(cWHType, GetSX3Cache("F46_WHSETP", "X3_TAMANHO"), " ")
cProdType   := PadR(cProdType, GetSX3Cache("F46_PRDGRP", "X3_TAMANHO"), " ")
cContrType  := PadR(cContrType, GetSX3Cache("F46_CNTRTP", "X3_TAMANHO"), " ")
nCurType    := 1
aArea       := GetArea()
cCode       := PadR(cCode, GetSX3Cache("F46_CODE", "X3_TAMANHO"), " ")

//Save parameters pergunte to be restored in the end of the function 
While TYPE( ( "MV_PAR" + StrZero( nX, 2, 0 ) ) ) != "U"
    aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
    nX++
EndDo

IF (cRequested == '1')

    RU34XFUN03_GetTipoProduct(cProdCode, cWarOrCon, @cProdType, @cWHType)
    Pergunte("RU34D01PRD", .F.)
    lPriority := Iif(MV_PAR01 == 1, .T., .F.)
    lPriorDif := MV_PAR02 < MV_PAR03

    Do Case

        Case (lPriority .AND. lPriorDif)
            aRawResult := RU34XFUN04_GetRawResult(cCode, 2, cProdType, cWHType)
        Case (lPriority .AND. !lPriorDif)
            aRawResult := RU34XFUN04_GetRawResult(cCode, 3, cWHType, cProdType)
        Case (!lPriority)
            
            cQuery :=   "SELECT F46_CONTA, F46_CCUSTO, F46_ITEMCC, F46_CLVL FROM " +  RetSQLName("F46") + " MYF46"+;
                        " WHERE (MYF46.F46_FILIAL = '" + xFilial("F46") + "' OR MYF46.F46_FILIAL = '')"+;
                        " AND MYF46.F46_CODE = '" + cCode + "'"+;
                        " AND MYF46.F46_PRDGRP = '" + cProdType + "'"+;
                        " AND MYF46.F46_WHSETP = '" + cWHType + "'"+;
                        " AND MYF46.D_E_L_E_T_ = ''"
            cQuery := ChangeQuery(cQuery)

            cTab := MPSysOpenQuery(cQuery)
            DbSelectArea((cTab))
            If !((cTab)->(Eof()))
                aRawResult := {(cTab)->F46_CONTA, (cTab)->F46_CCUSTO, (cTab)->F46_ITEMCC, (cTab)->F46_CLVL}
            Else
                aRawResult := {'','','',''}
            EndIf
            (cTab)->(DbCloseArea())

    EndCase

Else

    RU34XFUN02_GetTipoPartners(cWarOrCon, @cContrType, @nCurType)
    cCurType := ALLTRIM(Str(nCurType))
    cContrType := PadR(cContrType, GetSX3Cache("F46_CNTRTP", "X3_TAMANHO"), " ")
    Pergunte("RU34D01PRN", .F.)
    lPriority := Iif(MV_PAR01 == 1, .T., .F.)
    lPriorDif := MV_PAR02 < MV_PAR03

    Do Case

        Case (lPriority .AND. lPriorDif)
            aRawResult := RU34XFUN04_GetRawResult(cCode, 5, cContrType, cCurType)
        Case (lPriority .AND. !lPriorDif)            
            aRawResult := RU34XFUN04_GetRawResult(cCode, 4, cCurType, cContrType)
        Case (!lPriority)

            cQuery :=   "SELECT F46_CONTA, F46_CCUSTO, F46_ITEMCC, F46_CLVL FROM " +  RetSQLName("F46") + " MYF46"+;
                        " WHERE (MYF46.F46_FILIAL = '" + xFilial("F46") + "' OR MYF46.F46_FILIAL = '')"+;
                        " AND MYF46.F46_CODE = '" + cCode + "'"+;
                        " AND MYF46.F46_CURRTP = '" + cCurType + "'"+;
                        " AND MYF46.F46_CNTRTP = '" + cContrType + "'"+;
                        " AND MYF46.D_E_L_E_T_ = ''"
            cQuery := ChangeQuery(cQuery)

            cTab := MPSysOpenQuery(cQuery)
            DbSelectArea((cTab))
            If !((cTab)->(Eof()))
                aRawResult := {(cTab)->F46_CONTA, (cTab)->F46_CCUSTO, (cTab)->F46_ITEMCC, (cTab)->F46_CLVL}
            Else                
                aRawResult := {'','','',''}
            EndIf
            (cTab)->(DbCloseArea())       

    EndCase

Endif

Do Case
    Case (cExpected == '1')
        cResult = aRawResult[1]
    Case (cExpected == '2')
        cResult = aRawResult[2]
    Case (cExpected == '3')
        cResult = aRawResult[3]
    Case (cExpected == '4')
        cResult = aRawResult[4]
    Otherwise
        cResult = '' 
EndCase

// Restore the MV_ from PERGUNTES so it will not crash the caller routine 
For nX := 1 To Len( aMvPar )
    &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
Next nX

RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} RU34XFUN01

It is returns a currency type for a contract

author:   Vadim Ivanov
since:    23/05/2019
version:  1.0
project:  MA3 - Russia
-------------------------------------------------------------------/*/

Function RU34XFUN01(cCode as Character)

Local cCurType  as Character
Local cRet      as Character
Local aArea     as Array

aArea := GetArea()

cCurType := "1" // Available currency types: 1 - Rubles, 2 - Foreign, 3 - Conventional units

If !Empty(cCode)
    dbSelectArea("F5Q")
    dbSetOrder(2)
    If Posicione("F5Q", 2, xFilial("F5Q") + cCode, "F5Q_MOEDA") != 1
        cRet := Posicione("F5Q", 2, xFilial("F5Q") + cCode, "F5Q_CONUNI")
        Do Case
            Case cRet == "1"
                cCurType := "3"
            Case cRet == "2"
                cCurType := "2"
        EndCase
    EndIf
EndIf

RestArea(aArea)

Return cCurType
 
/*/{Protheus.doc} CTBC662PRT

Print

@return		Nil
@author 	Alexandra Menyashina
@since 		21/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function CTBC662PRT()
	Local oReport	AS OBJECT
	Local cName		AS CHARACTER

	cName	:= 'CTBC662'
	oReport := CTBC662RDF(cName)
	oReport:PrintDialog()
return Nil

/*/{Protheus.doc} CTBC662RDF

Print report definition

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		21/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function CTBC662RDF(cName)
	Local oReport	AS OBJECT
	Local oSecSN1	AS OBJECT
	Local oSecCT2	AS OBJECT
	Local oStruSN1	AS OBJECT
	Local oStruCT2	AS OBJECT
	Local nX		AS NUMERIC

	oStruSN1 := FWFormStruct(2, "SN1", {|x| (AllTrim(x) $ "N1_FILIAL|N1_CBASE|N1_ITEM|N1_DESCRIC")})
	oStruCT2 := FWFormStruct( 2, 'CT2' )

	oReport := TReport():New(cName/*cReport*/,"Print FA Accounting Enteries"/*cTitle*/,cName,{|oReport| CTBC662PR(oReport)},"PRINT", .F./*<lLandscape>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<cPageTText>*/ , .F./*<lPageTInLine>*/ , .F./*<lTPageBreak>*/ , /*<nColSpace>*/ )

	oReport:lParamPage	:= .F.	//Don't print patameter page
	//Header info
	oSecSN1 := TRSection():New(oReport,"",{'SN1'} , , .F., .T.)
	For nX := 1 To Len(oStruSN1:aFields)
		If ! oStruSN1:aFields[nX, MVC_VIEW_VIRTUAL]
			TRCell():New(oSecSN1,oStruSN1:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"SN1", alltrim(oStruSN1:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
		EndIf
	Next nX

	//Detail info
	oSecCT2 := TRSection():New(oReport,"",{'CT2'} , , .F., .T.)
	For nX := 1 To Len(oStruCT2:aFields)
		If ! oStruCT2:aFields[nX, MVC_VIEW_VIRTUAL]
			TRCell():New(oSecCT2,oStruCT2:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"CT2", alltrim(oStruCT2:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
		EndIf
	Next nX
	
Return oReport

/*/{Protheus.doc} CTBC662PR

Print prepare data

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		21/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
STATIC Function CTBC662PR(oReport)
	Local oSecSN1 		AS OBJECT
	Local oSecCT2		AS OBJECT
	Local oStruSN1		AS OBJECT
	Local oStruCT2		AS OBJECT
	Local cAliasQry		AS CHARACTER
	Local cQuery		AS CHARACTER
	Local cBase			AS CHARACTER
	Local cItem			AS CHARACTER
	local lRet			AS LOGICAL
	Local nX			AS NUMERIC
	Local xValor

	oStruSN1 := FWFormStruct(2, "SN1", {|x| (AllTrim(x) $ "N1_FILIAL|N1_CBASE|N1_ITEM|N1_DESCRIC")})
	oStruCT2 := FWFormStruct( 2, 'CT2' )

	oSecSN1		:= oReport:Section(1)
	oSecCT2		:= oReport:Section(2)
	cAliasQry	:= GetNextAlias()
	cQuery		:= ""
	lRet		:= .T.

	If oReport:Cancel()
		Return .T.
	EndIf

	oSecSN1:Init()
	oReport:IncMeter()

	cBase := SN1->N1_CBASE
	cItem := SN1->N1_ITEM

	dbSelectArea('SN1')
	SN1->(DBSeek( xFilial('SN1') + cBase + cItem))

	For nX := 1 To Len(oStruSN1:aFields)
		oSecSN1:Cell(oStruSN1:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(SN1->&(oStruSN1:aFields[nX, MVC_VIEW_IDFIELD]))
	Next nX		
	oSecSN1:Printline()

	oSecCT2:init()

	cQuery	:= " select  CT2.R_E_C_N_O_ CT2RECNO "

	For nX := 1 To Len(oStruCT2:aFields)
		If ! oStruCT2:aFields[nX, MVC_VIEW_VIRTUAL]
			cQuery  += "," + oStruCT2:aFields[nX, MVC_VIEW_IDFIELD]
		EndIf
	Next nX

	cQuery	+= " FROM "+ RetSQLName("SN1") +" N1 "
	cQuery	+= " JOIN "	+ RetSQLName("SN4") +" N4 "
	cQuery	+= " ON N4_CBASE = N1_CBASE"
	cQuery	+= " AND N4_ITEM = N1_ITEM"
	cQuery	+= " JOIN "	+ RetSQLName("CV3") +" CV3 "
	cQuery	+= " ON CV3_RECORI = CAST(N4.R_E_C_N_O_ AS BPCHAR(17))"
	cQuery	+= " JOIN "	+ RetSQLName("CT2") +" CT2 "
	cQuery	+= " ON CT2.R_E_C_N_O_ = CAST(CV3_RECDES AS INT4)"
	cQuery	+= " WHERE	CT2.CT2_FILIAL = '" + xFilial("CT2") + "'"
	cQuery	+= " AND 	N1.N1_FILIAL = '" + xFilial("SN1") + "'"
	cQuery	+= " AND 	CV3.CV3_FILIAL = '" + xFilial("CV3") + "'"
	cQuery	+= " AND 	N4.N4_FILIAL = '" + xFilial("SN4") + "'"
	cQuery	+= " AND	N4.D_E_L_E_T_ = ' '"
	cQuery	+= " AND	CT2.D_E_L_E_T_ = ' '"
	cQuery	+= " AND	N1.D_E_L_E_T_ = ' '"
	cQuery	+= " AND	CV3.D_E_L_E_T_ = ' '"
	cQuery	+= " AND 	CV3_RECDES <> ' '"
	cQuery	+= " AND 	CV3_TABORI = 'SN4'"
	cQuery	+= " AND 	N1.N1_CBASE	= '" + cBase + "' "
	cQuery	+= " AND	N1.N1_ITEM	= '" + cItem + "' "

	cQuery   := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	Dbselectarea(cAliasQry)
	dbgotop()

	While (cAliasQry)->(!EOF())
		For nX := 1 To Len(oStruCT2:aFields)
			If ! oStruCT2:aFields[nX, MVC_VIEW_VIRTUAL]
				If GetSx3Cache(oStruCT2:aFields[nX, MVC_VIEW_IDFIELD],'X3_TIPO') == 'D'
					xValor := CT2->&(oStruCT2:aFields[nX, MVC_VIEW_IDFIELD])
					xValor := StrTran(DTOC(xValor), "/", ".")
					oSecCT2:Cell(oStruCT2:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(xValor)
				Else
					oSecCT2:Cell(oStruCT2:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)-> &(oStruCT2:aFields[nX, MVC_VIEW_IDFIELD]))
				EndIf
			EndIf
		Next nX
		oSecCT2:Printline()
		(cAliasQry)->(dbSkip())
	EndDo
	oSecCT2:Finish()
	//Separator
	oReport:ThinLine()
	oSecSN1:Finish()
Return(NIL)

/*/{Protheus.doc} RU34XFUN
Function to get the type of contract and currency from F5Q table
FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU34XFUN02_GetTipoPartners(cContrCode as Character, cContrType as Character, nCurType as Numeric)

Local cQuery        as Character
Local cTab        as Character

If cContrCode != ''

    cQuery :=   "SELECT F5Q_TYPE, F5Q_MOEDA, F5Q_CONUNI FROM " +  RetSQLName("F5Q") + " MYF5Q"+;
                " WHERE (MYF5Q.F5Q_FILIAL = '" + xFilial("F5Q") + "' OR MYF5Q.F5Q_FILIAL = '')"+;
                " AND MYF5Q.F5Q_UID = '" + cContrCode + "'"+;
                " AND MYF5Q.D_E_L_E_T_ = ''"
    cQuery := ChangeQuery(cQuery)

    cTab := MPSysOpenQuery(cQuery)
    DbSelectArea((cTab))
    If !((cTab)->(Eof()))

        If (cTab)->F5Q_MOEDA > 1
            If (cTab)->F5Q_CONUNI == "2"
                nCurType := 2
            Else
                nCurType := 3
            EndIf
        Else
            nCurType := (cTab)->F5Q_MOEDA
        EndIf
        cContrType := (cTab)->F5Q_TYPE

    EndIf
    (cTab)->(DbCloseArea())

Endif

Return

/*/{Protheus.doc} RU34XFUN
Function to get the type of product group and warehouse type(group!) from SB1 and NNR tables
FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU34XFUN03_GetTipoProduct(cProdCode as Character, cWHCode as Character, cProdType as Character, cWHType as Character)

Local cQuery        as Character
Local cTab          as Character

If cWHCode != ''

    cQuery :=   "SELECT NNR_WHSETP FROM " +  RetSQLName("NNR") + " MYNNR"+;
                " WHERE (MYNNR.NNR_FILIAL = '" + xFilial("NNR") + "' OR MYNNR.NNR_FILIAL = '')"+;
                " AND MYNNR.NNR_CODIGO = '" + cWHCode + "'"+;
                " AND MYNNR.D_E_L_E_T_ = ''"
    cQuery := ChangeQuery(cQuery)

    cTab := MPSysOpenQuery(cQuery)
    DbSelectArea((cTab))

    If !((cTab)->(Eof()))

        cWHType := (cTab)->NNR_WHSETP 

    EndIf

    (cTab)->(DbCloseArea())

Endif

If cProdCode != ''

    cQuery :=   "SELECT MYSBM.BM_TIPGRU FROM " +  RetSQLName("SB1") + " MYSB1"+;
                " LEFT JOIN " + RetSQLName("SBM") + " MYSBM ON MYSB1.B1_GRUPO = MYSBM.BM_GRUPO"+;
                " WHERE (MYSB1.B1_FILIAL = '" + xFilial("SB1") + "' OR MYSB1.B1_FILIAL = '')"+;
                " AND MYSB1.B1_COD = '" + cProdCode + "'"+;
                " AND MYSB1.D_E_L_E_T_ = ''"+;
                " AND MYSBM.D_E_L_E_T_ = ''"
    cQuery := ChangeQuery(cQuery)

    cTab := MPSysOpenQuery(cQuery)
    DbSelectArea((cTab))

    If !((cTab)->(Eof()))

        cProdType := (cTab)->BM_TIPGRU

    EndIf

    (cTab)->(DbCloseArea())

Endif

Return .T.

/*/{Protheus.doc} RU34XFUN
Function to get the all returned values from F46 to Products
FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU34XFUN04_GetRawResult(cCode as Character, nOrder as Numeric, cFirstParam as Character, cSecondParam as Character)
Local aAreaF46      as Character
Local aRawResult    as Array
LOCAL aIndex        as Array
Local aPadr         as Array
Local nCurtyp       as Numeric



aPadr:= {}
nCurtyp := 0 
aRawResult = {'','','',''}
aAreaF46 := F46->(GetArea())

DbSelectArea('F46')
F46->(DbSetOrder(nOrder))
aIndex := StrTokArr( IndexKey( nOrder), "+" )

AADD( aPadr, {aIndex[3], PadR(" ", GetSX3Cache(aIndex[3], "X3_TAMANHO"), " ")} )
AADD( aPadr, {aIndex[4], PadR(" ", GetSX3Cache(aIndex[4], "X3_TAMANHO"), " ")} )
If  aScan(aPadr, {|x| AllTrim(x[1]) == "F46_CURRTP" } ) > 0 
    nCurtyp = aScan(aPadr, {|x| AllTrim(x[1]) == "F46_CURRTP" } )
    aPadr[nCurtyp][2] :=PadR("1", GetSX3Cache(aPadr[nCurtyp][1], "X3_TAMANHO"), " ")
ENDIF


If (F46->(Dbseek(xFilial("F46") + cCode + cFirstParam + cSecondParam)) )
    aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
ElseIf (F46->(Dbseek(xFilial("F46") + cCode + cFirstParam + aPadr[2][2])) )
    aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
ElseIf (F46->(Dbseek(xFilial("F46") + cCode + aPadr[1][2] + cSecondParam)) )
    aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
ElseIf (F46->(Dbseek(xFilial("F46") + cCode  +aPadr[1][2]+ aPadr[2][2])) )
    aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
ElseIf nCurtyp > 0 
    aPadr[nCurtyp][2] :=PadR(" ", GetSX3Cache(aPadr[nCurtyp][1], "X3_TAMANHO"), " ")
    If (F46->(Dbseek(xFilial("F46") + cCode + cFirstParam + aPadr[2][2])) )
        aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
    ElseIf (F46->(Dbseek(xFilial("F46") + cCode  +aPadr[1][2]+ cSecondParam)) )
        aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
    ElseIf (F46->(Dbseek(xFilial("F46") + cCode  +aPadr[1][2]+ aPadr[2][2])) )
        aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
    EndIf        
EndIf
RestArea(aAreaF46)

Return aRawResult

/*/{Protheus.doc} RU34XFUN
Function to validation perguntas in RU34D01 and RU34D02
FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU34XFUN05_RU34D01VPr()

Local lResult as Logical

lResult := .T.

If((MV_PAR01 == 1 .AND. MV_PAR02 == MV_PAR03) .OR. MV_PAR02 == 0 .OR. MV_PAR03 == 0)
    lResult := .F.
EndIf

Return lResult

/*/{Protheus.doc} RU34XFUN06_CopyOperation(cOper, cProgram)
    This function performs copy operation

    @type Function
    @param cOper, string with operation name
    @param cProgram, string with program name, example: "RU34D06"
    @return Nil

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example RU34XFUN06()
*/
Function RU34XFUN06_CopyOperation(cOper, cProgram)
    Local oModel As Object
    If cProgram <> 'RU34D08'
        FWExecView(cOper,cProgram,9,,{|| .T.})
    Else
        oModel := FWLoadModel("RU34D08")
        oModel:SetOperation(MODEL_OPERATION_INSERT)
        oModel:Activate() 

        oModel:SetValue('F65MASTER', 'F65_CTYPE', F65->F65_CTYPE)
        oModel:SetValue('F65MASTER', 'F65_TDOC' , F65->F65_TDOC)
        FWExecView(cOper,cProgram,MODEL_OPERATION_INSERT,,{|| .T.},, /*nPercReducao*/, , /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,oModel)
    EndIf
Return (Nil)

/*/{Protheus.doc} RU34XFUN07_FillVirtualFields(cTable, cField, cDescField, lBrowse)
    This function fill up virtual fields, calls from SX3 (x3_relacao, x3_inibrw)

    @type Function
    @param cTable, string with current table alias
    @param cField, string with field name (without table alias) which has f3 query
    @param cDescField, string with target field name, which will be returned
    @param lBrowse, logical defines place where function had been called (.T. = called from browse, .F. = called from MVC)
    @return cRet

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example RU34XFUN07()
*/
Function RU34XFUN07_FillVirtualFields(cTable, cField, cDescField, lBrowse)
    Local cRet       := ""
    Local cSearchTab := StrTokArr(cDescField, "_")[1]
    Local cFieldPref := Iif(Len(cTable) == 3 .And. Substr(cTable, 1, 1) == "S",Substr(cTable, 2, 3),cTable)

    If Len(cSearchTab) < 3
        cSearchTab := "S" + cSearchTab
    EndIf
    Do Case
        Case cField == 'TYPE'
            cRet := IIF(!lBrowse, ;
                IIF(!INCLUI .And. !Empty(AllTrim(FWFldGet(cFieldPref+"_TYPE" ))),AllTrim(Posicione(cSearchTab,1,xFilial(cSearchTab)+"OT"+FwFldGet(cFieldPref+"_TYPE"),"X5DESCRI()")),""),;
                IIF(!Empty(AllTrim((cTable)->&(cFieldPref+"_TYPE"))),AllTrim(Posicione(cSearchTab,1,xFilial(cSearchTab)+"OT"+(cTable)->&(cFieldPref+"_TYPE"),"X5DESCRI()")),""))
        Case cField == 'CTYPE'
            cRet := IIF(!lBrowse, ;
                IIF(!INCLUI .And. !Empty(AllTrim(FWFldGet(cFieldPref+"_CTYPE"))),AllTrim(Posicione(cSearchTab,1,xFilial(cSearchTab)+FwFldGet(cFieldPref+"_CTYPE"),cDescField)),""),;
                IIF(!Empty(AllTrim((cTable)->&(cFieldPref+"_CTYPE"))),AllTrim(Posicione(cSearchTab,1,xFilial(cSearchTab)+(cTable)->&(cFieldPref+"_CTYPE"),cDescField)),""))
        Case cField == 'GRCNS'
            cRet := IIF(!lBrowse, ;
                IIF(!INCLUI .And. !Empty(AllTrim(FWFldGet(cFieldPref+"_GRCNS"))),AllTrim(Posicione(cSearchTab,1,xFilial(cSearchTab)+FwFldGet(cFieldPref+"_GRCNS"),cDescField)),""),;
                IIF(!Empty(AllTrim((cTable)->&(cFieldPref+"_GRCNS"))),AllTrim(Posicione(cSearchTab,1,xFilial(cSearchTab)+(cTable)->&(cFieldPref+"_GRCNS"),cDescField)),""))
    End Do
Return (cRet)

/*/{Protheus.doc} RU34XFUN08_DeleteValidations(cHeader, cMessage, cRoutine, cSTable)
    This function validates data on delete operations
    Calls from: CRM980EventDEF, MATA020EVDEF, RU34D04, RU34D06EventRUS, RU34D07, RU34D08, RU69T01EventRUS

    @type Function
    @param cHeader  = string, header message
    @param cMessage = string, error message
    @param cRoutine = string, routine name, example "RU34D07"
    @param cSTable  = string, source table name from SX2, example "F43"
    @return lRet

    @author Dmitry Borisov
    @since 2023/11/03
    @version 12.1.33
    @example RU34XFUN08(cHeader, cMessage, cRoutine, cSTable)
*/
Function RU34XFUN08_DeleteValidations(cHeader, cMessage, cRoutine, cSTable)

    Local oModel    := FWModelActive()
    Local cModelId  := oModel:GetModelIds()[1]
    Local cKey      := ''
    Local lRet      := .T.
    Local nI        := 0
    Local aTables   := {}
    Local mTables   := RU34XFUN11(cSTable)
    Local aArea     := {}
    Local cFilter   := ""

    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        If Len(mTables:get(cSTable)) > 0
            If Len(mTables:get(cSTable)[1]) > 0
                // search key generation
                For nI := 1 To Len(mTables:get(cSTable)[1])
                    cKey += oModel:GetValue(cModelId , mTables:get(cSTable)[1,nI])
                Next nI
                If Len(mTables:get(cSTable)[2]) > 0
                    For nI := 1 To Len(mTables:get(cSTable)[2])
                        aArea := (mTables:get(cSTable)[2,nI,1])->(GetArea())
                        DbSelectArea(mTables:get(cSTable)[2,nI,1])  // get search table
                        DbSetOrder(mTables:get(cSTable)[2,nI,2])    // get search index
                        If mTables:get(cSTable)[2,nI,1] == "SC5"
                            cFilter  := "C5_FILIAL == '"+ xFilial(mTables:get(cSTable)[2,nI,1]) + "' .AND. C5_F5QCODE == '" + cKey + "' "
                            cKey := ""
                            DbSetFilter({ || &cFilter},cFilter)
                        EndIf
                        DbGoTop()
                        If (mTables:get(cSTable)[2,nI,1])->(DbSeek(xFilial(mTables:get(cSTable)[2,nI,1])+cKey))
                            aAdd(aTables, mTables:get(cSTable)[2,nI,1])
                        EndIf
                        cFilter := ""
                        RestArea(aArea)
                    Next nI
                EndIf
            EndIf
        EndIf
    EndIf
    If Len(aTables) > 0
        lRet := .F.
        cMessage += " : " + CHR(13)+CHR(10)
        For nI := 1 To Len(aTables)
            cMessage += aTables[nI] + CHR(13)+CHR(10)
        Next nI
    EndIf
    If !lRet
        Help("",1,cRoutine,,cHeader,1,0,,,,,,{cMessage}) // Record can't be deleted
    EndIf
    

Return (lRet)

/*/{Protheus.doc} RU34XFUN09_GetFilter()
    This function calls from SXB table, and needed for filter F43 table records
	used in next standard queries: QF43_1

    @type Function
    @return cRet

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example RU34XFUN09()
*/
Function RU34XFUN09_GetFilter()

    Local cRet   := ''
    Local cType  := ''
    Local cRuPrf := ''
    Local aArea  := {}
    Local oModel := FwModelActive()

    If AllTrim(ReadVar()) != ''
        cRuPrf:=StrTokArr(ReadVar(), "->")[2]
    EndIf

    If cRuPrf == 'F5O_GRCNS' .And. !Empty(AllTrim(oModel:GetValue('F5OMASTER', 'F5O_CTYPE'))) .And. AllTrim(oModel:GetValue('F5OMASTER', 'F5O_CTYPE')) == AllTrim(F4K->F4K_CTYPE)
        cRet := "F43->F43_CLISUP == '" + F4K->F4K_CLISUP + "'"
    EndIf
    If cRuPrf == 'F5Q_CTYPE' .And. !Empty(AllTrim(oModel:GetValue('F5QMASTER', 'F5Q_TYPE')))
        aArea := F4Y->(GetArea())
        DbSelectArea("F4Y")
        DbSetOrder(1)
        If F4Y->(DbSeek(xFilial("F4Y")+oModel:GetValue('F5QMASTER', 'F5Q_TYPE')))
            While F4Y->(!EOF()) .And. F4Y->F4Y_TYPE == oModel:GetValue('F5QMASTER', 'F5Q_TYPE')
                cType := F4Y->F4Y_CLISUP
                F4Y->(dbSkip())
            Enddo
            If Len(cType) > 0
                cRet := "F4K->F4K_CLISUP == '" + cType + "'"
            EndIf
        EndIf
        RestArea(aArea)
    EndIf
    If cRuPrf == 'AI0_GRCNS'
        cRet := "F43->F43_CLISUP == '1'"
    EndIf
    If cRuPrf == 'A2_GRCNS'
        cRet := "F43->F43_CLISUP == '2'"
    EndIf
Return (cRet)

/*/{Protheus.doc} RU34XFUN10_GetWhen()
    This function calls from SX3 table, and needed for allow edit fields
	used for next: F5Q_A1COD, F5Q_A2COD, F5Q_A1LOJ, F5Q_A2LOJ, F5O_F5QCOD, AI0_GRCNS, A2_GRCNS

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/11/08
    @version 12.1.33
    @example RU34XFUN10()
*/
Function RU34XFUN10_GetWhen()

    Local lRet      := .T.
    Local oModel    := FwModelActive()
    Local cFieldInd := ''
    
    If AllTrim(ReadVar()) != ''
        cFieldInd:=StrTokArr(ReadVar(), "->")[2]
    EndIf

    Do Case
        Case cFieldInd == 'F5Q_A1COD' .Or. cFieldInd == 'F5Q_A1LOJ'
            lRet := Posicione("F4K",1,xFilial("F4K")+FwFldGet('F5Q_CTYPE'),"F4K_CLISUP") == "1" 
        Case cFieldInd == 'F5Q_A2COD' .Or. cFieldInd == 'F5Q_A2LOJ'
            lRet := Posicione("F4K",1,xFilial("F4K")+FwFldGet('F5Q_CTYPE'),"F4K_CLISUP") == "2" 
        Case cFieldInd == 'F5O_F5QCOD'
            lRet := !Empty(AllTrim(FwFldGet('F5O_CTYPE'))) .And. !Empty(AllTrim(FwFldGet('F5O_GRCNS ')))
        Case cFieldInd == 'F5O_GRCNS'
            lRet := oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !Empty(AllTrim(FwFldGet('F5O_CTYPE')))
        Case cFieldInd == 'AI0_GRCNS'
            lRet := oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. (Empty(AllTrim(AI0->AI0_GRCNS)) .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
        Case cFieldInd == 'A2_GRCNS'
            lRet := oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. (Empty(AllTrim(SA2->A2_GRCNS)) .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
    End Do

Return (lRet)

/*/{Protheus.doc} RU34XFUN11_GetMap(cTable)
    This function needs for preparation map with params, which uses in 
    validations on delete operations
    Calls from: RU34XFUN08

    @type Function
    @param cTable = string, with table alias from SX3
        mTables params:
            @key - string, with table alias from SX3
            @value - array with params
            array[1] - array of string, with fields from source table, which will be used for check
            array[2] - multidimentional array, with params for check target table
            array[2,1,1] - string, with target table alias from SX3
            array[2,1,2] - numeric, index for search in target table
    @return mTables

    @author Dmitry Borisov
    @since 2023/11/12
    @version 12.1.33
    @example RU34XFUN11(cTable)
*/
Function RU34XFUN11_GetMap(cTable)

    Local mTables := FwHashMap():New()
    Do Case
        Case cTable == 'F4K'
            mTables:put('F4K', {{'F4K_CTYPE'}, {{'F5Q', 9}, {'F5O', 1}}})
        Case cTable == 'F5O'
            mTables:put('F5O', {{'F5O_CTYPE','F5O_GRCNS','F5O_F5QCOD'}, {{'F5Q', 10}}})
        Case cTable == 'F43'
            mTables:put('F43', {{'F43_GRCNS'}, {{'AI0', 2}, {'SA2', 10}, {'F5O', 2}}})
        Case cTable == 'SA1'
            mTables:put('SA1', {{'A1_COD', 'A1_LOJA'}, {{'F5Q', 6}}})
        Case cTable == 'SA2'
            mTables:put('SA2', {{'A2_COD', 'A2_LOJA'}, {{'F5Q', 7}}})
        Case cTable == 'F65'
            mTables:put('F65', {{'F65_CTYPE', 'F65_TDOC'}, {{'F5Q', 9}}})
        Case cTable == 'F5Q'
            mTables:put('F5Q', {{'F5Q_CODE'}, {{'SF1', 9}, {'SF2', 15}, {'SC7', 23},{'SC5', 1}}})
    End Do

Return (mTables)

/*/{Protheus.doc} RU34XFUN12
    Function Responsible for returning the name of the master Submodel of a given Model
    @type  Function
    @author eduardo.Flima   
    @since 10/04/2024
    @version R14
    @param oModel   , Object    , Main Model
    @return cModNam , Character ,  name of the master Submodel
/*/
Function RU34XFUN12_GetModMAsNam(oModel AS Object)
    Local cModNam as Character
    cModNam := oModel:GetDependency()[1][2]
Return (cModNam)


/*/{Protheus.doc} RU34XFUN13_FWGnFlByTpRUS
    Function responsible to check if the table SX2 is opened before to call function FWGnFlByTp
    @type  Function
    @author eduardo.Flima
    @since 28/01/2025
    @version 28/01/2025
    @param cCodPrj  , Character , Code of the project
    @return cPath   , Character , Path to be used in FWGnFlByTp
/*/
Function RU34XFUN13_FWGnFlByTpRUS(cCodPrj as Character ,cPath as Character)
    Local lSx2Closed As Logical

	lSx2Closed := select( "SX2")== 0
    If lSx2Closed
        OpenSxs(,,,,cEmpAnt,"SX2","SX2",,.F.)
    EndIf
    
	FWGnFlByTp(cCodPrj,cPath) 

    If lSx2Closed
        DbSelectArea( "SX2")
        dbcloseArea()
    EndIf

Return 


/*/{Protheus.doc} RU34XFUN14_DefDlgBalRus
    Set dialog to update Account Balances
    @type  Function
    @author eduardo.Flima
    @since 20/02/2025
    @version R14
    @param nOpcao   , Character     , Option of the operation 
    @param aCols    , Array         , Array with the Account Balances registers
    @param nCols    , Numeric       , Number of the positioned registers in the acols
    @param cCod130  , Character     , Code of the positionated Account Balances register
    @param cDescEng , Character     , English Description
    @param cDescRus , Character     , Russian Description
    @param cDesc130 , Character     , Old Description
    @param aItens   , Numeric       , Icons collor Array 
    @param cCor130  , Character     , Current Collor selected
    @param cSTR0033 , Character     , String Edition of Account Balances
    @param cSTR0034 , Character     , String Account Balances
    @param cSTR0035 , Character     , String Code
    @param cSTR0037 , Character     , String Caption
    @param cSTR0086 , Character     , String Russian Description 
    @param cSTR0087 , Character     , String English description
    @param cAcao    , Character     , String with the action taken
    @param lSldInt  , Logical       , If it is a system standart balance
/*/
Function RU34XFUN14_DefDlgBalRus(nOpcao,aCols,nCols,cCod130,cDescEng,cDescRus,cDesc130,aItens,cCor130,cSTR0033,cSTR0034,cSTR0035,cSTR0037,cSTR0086,cSTR0087,cAcao,lSldInt)
    Local aCores	:= Ct130CorSl()
    Local cResource := CtbLegRes(cCod130)    
    Local nItens    := 0 
    Local nOpc 		:= 0
    Local oJdescri  := JsonObject():New()

    DbSelectArea('SX5')
    DbSetOrder(1)
    SX5->(DbSeek(xFilial("SX5")+ "SL"+cCod130)) 
    oJdescri := RU34XFUN15_GetTrnsEnt("SX5")
    cDescRus :=oJdescri['ru']
    cDescEng :=oJdescri['en']
    cDesc130 :=oJdescri[FwRetIdiom()]

    For nItens := 1 To Len(aCores)
        Aadd(aItens, AllTrim(Str(nItens, 2)) + "-" + aCores[nItens][2] )
    Next

    nItens := Ascan(aCores, { |x| x[1] = cResource })
    If nItens = 0
        cCor130 := aItens[1]
    Else
        cCor130 := aItens[nItens]
    Endif

	DEFINE 	MSDIALOG oDlgAux FROM  86,1 TO 220,400;
			TITLE cSTR0033 + cAcao PIXEL //"Edicao dos Saldos Contabeis - "
	@ 05, 04 TO 64, 154 LABEL cSTR0034 OF oDlgAux PIXEL //"Saldo contabil"

	@ 14, 08 SAY cSTR0035    	SIZE 53, 07 OF oDlgAux PIXEL //"Codigo"

	@ 27, 08 SAY cSTR0086  		SIZE 53, 07 OF oDlgAux PIXEL
	@ 40, 08 SAY cSTR0087  		SIZE 53, 07 OF oDlgAux PIXEL
	@ 53, 08 SAY cSTR0037  		SIZE 53, 07 OF oDlgAux PIXEL


    @ 12, 68 MSGET cCod130		SIZE 18, 10 OF oDlgAux PIXEL Picture "!";
            When nOpcao = 1 .And. ! lSldInt;
            Valid 	! Empty(cCod130) .And. If(Ascan(aCols, { |x| x[1] = cCod130} ) > 0,;
                    (HELP(" ", 1, "JAGRAVADO"), .F.), .T.)
	@ 25, 68 MSGET cDescRus	SIZE 51, 10 OF oDlgAux PIXEL Valid ! Empty(cDescRus);
			When !lSldInt .And. nOpcao != 3

	@ 38, 68 MSGET cDescEng	SIZE 51, 10 OF oDlgAux PIXEL Valid ! Empty(cDescEng);
			When !lSldInt .And. nOpcao != 3
	@ 51, 68 	MSCOMBOBOX oCores VAR cCor130 ITEMS aItens SIZE 70,08	PIXEL;
				Valid Ctb130ChkCor(	cCor130, aItens, aCores, aCols, If(nOpcao = 1, 0, aCols[nCols][3]));
				When nOpcao != 3

	DEFINE 	SBUTTON oBtnOk FROM 07,160 TYPE 1 ENABLE OF oDlgAux;
			Action (nOpc:=1,If(Ctb130ChkCor(	cCor130, aItens, aCores, aCols,;
							If(nOpcao = 1, 0, aCols[nCols][3])), oDlgAux:End(), nOpc:=0))
	DEFINE 	SBUTTON oBtnCn FROM 21,160 TYPE 2 ENABLE OF oDlgAux Action (nOpc:=0,oDlgAux:End())
	ACTIVATE MSDIALOG oDlgAux Centered


Return nOpc



/*/{Protheus.doc} GetTrnsEnt
    This function is responsible for returning information from different entities when they have descriptions in both English and Russian.
    @type  Static Function
    @author eduardo.Flima
    @since 02/05/2024
    @version R14
    @param cEntity  , Character     , Entities that we will return the informations. Available: "SX2" "SIX" "SXA" "SXB" "SX5" "SX1" "SX6" "SX3"
    @param cProper  , Character     , Property that we should return from the entity when available; SX1("TITLE","OPC1","OPC2","OPC3","OPC4","OPC5");SX6("DESCRIC","DESCRI1","DESCRI2","CONTEUD");SX6("TITULO","DESCRIC","HELP","COMBO")    
    @return oJRet   , JsonObject    , JSon Object with the Descriptions in Russian and Englis
/*/
Function RU34XFUN15_GetTrnsEnt(cEntity AS Character ,cProper AS Character) AS Character
    Local cStanIdom     as Character
    Local cRet          as Character
    Local nX            as Numeric
    Local oJRet     := JsonObject():New() 
    Default cProper     :=""

    cStanIdom := FwRetIdiom()
    cRet      :=""
    aIdiom :={'ru','en'}
    
    for nX := 1 to len(aIdiom)
        FwSetIdiom(aIdiom[nX])
        Do Case
            Case cEntity=="SX2"
                cRet := FWX2Nome( SX2->X2_CHAVE )
            Case cEntity=="SIX"
                cRet :=SIX->(SixDescricao())
            Case cEntity=="SXA"
                cRet :=XADescric()
            Case cEntity=="SXB"
                cRet :=XBDescri()
            Case cEntity=="SX5"
                cRet :=X5Descri()            
            Case cEntity=="SX1"
                Do Case
                    Case cProper=="TITLE"
                        cRet :=X1Pergunt()
                    Case cProper=="OPC1"
                        cRet :=X1Def01()
                    Case cProper=="OPC2"
                        cRet :=X1Def02()
                    Case cProper=="OPC3"
                        cRet :=X1Def03()
                    Case cProper=="OPC4"
                        cRet :=X1Def04()
                    Case cProper=="OPC5"
                        cRet :=X1Def05()                    
                EndCase
            Case cEntity=="SX6"
                Do Case
                    Case cProper=="DESCRIC"
                        cRet :=X6Descric()
                    Case cProper=="DESCRI1"
                        cRet :=X6Desc1()
                    Case cProper=="DESCRI2"
                        cRet :=X6Desc2()
                    Case cProper=="CONTEUD"
                        cRet :=X6Conteud()
                EndCase
            Case cEntity=="SX3"
                Do Case
                    Case cProper=="TITULO"
                        cRet :=X3Titulo()               
                    Case cProper=="DESCRIC"
                        cRet :=X3DescriC()               
                    Case cProper=="HELP"
                        cRet :=Ap5GetHelp(SX3->X3_CAMPO)
                    Case cProper=="COMBO"
                        iF LEFT(SX3->X3_CBOXENG,1) == "#"// For functions does not macro execute 
                            cRet :=alltrim(SX3->X3_CBOXENG)
                        Else
                            cRet :=X3Cbox()                    
                        Endif
                EndCase
        EndCase
    oJRet[aIdiom[nX]] := cRet
    next
    FwSetIdiom(cStanIdom)
Return oJRet

/*/{Protheus.doc} RU34XFUN16_UpdXAcolsCtba130
    Function responsible for updating the SX5 and accounting balance columns
    @type  Function
    @author eduardo.Flima
    @since 20/02/2025
    @version R14
    @param aCols    , Array         , Original Array with the Account Balances registers
    @param nCols    , Numeric       , Number of the positioned registers in the acols
    @param cDescEng , Character     , English Description
    @param cDescRus , Character     , Russian Description
    @return aCols   , Array         , Modified Array with the Account Balances registers
/*/
Function RU34XFUN16_UpdXAcolsCtba130(aCols,nCols,cDescEng,cDescRus)
    Local oJdescri  := JsonObject():New()
    Local cStanIdom := FwRetIdiom()
    FwSetIdiom('ru')
	FwPutSX5("TRANSL", "SL", aCols[nCols][1],,cDescEng,,cDescRus)
    SX5->(DbSeek(xFilial("SX5")+ "SL"+aCols[nCols][1])) 
    FwSetIdiom(cStanIdom)
    oJdescri := RU34XFUN15_GetTrnsEnt("SX5")
    aCols[nCols][2] := oJdescri[FwRetIdiom()]
Return aCols
                   
//Merge Russia R14 
                   
