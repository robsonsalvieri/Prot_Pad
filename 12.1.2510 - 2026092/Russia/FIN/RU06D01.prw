#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU06D01.CH'

/*/{Protheus.doc} RU06D01
@author Andrews Egas
@since 22/12/2016
@version P10
/*/
Function RU06D01()
Local oBrowse

// Initalization of tables, if they do not exist.
DBSelectArea("FIZ")
FIZ->(DbSetOrder(1))
DBSelectArea("F42")
F42->(DbSetOrder(1))

If pergunte('RU06D01',.T.)
	If MV_PAR01 == 1
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('FIZ')
		oBrowse:SetDescription(STR0012) // FI SIGNERS
		oBrowse:Activate()
	Else
		RU06D01a() //Call Function Report x Signers	
	EndIf

EndIf

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003	 		ACTION 'VIEWDEF.RU06D01' OPERATION 2 ACCESS 0 // View
ADD OPTION aRotina TITLE STR0002    		ACTION 'VIEWDEF.RU06D01' OPERATION 3 ACCESS 0 // Add
ADD OPTION aRotina TITLE STR0004    		ACTION 'VIEWDEF.RU06D01' OPERATION 4 ACCESS 0 // Edit
ADD OPTION aRotina TITLE STR0005    		ACTION 'VIEWDEF.RU06D01' OPERATION 5 ACCESS 0 // Delete

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruFIZ 	:= FWFormStruct( 1, 'FIZ', /*bAvalCampo*/,/*lViewUsado*/ )
    Local oStruF42 	:= FWFormStruct( 1, 'F42')
    Local oModel

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New('RU06D01', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    oStruF42:SetProperty( 'F42_DATETO' , MODEL_FIELD_OBRIGAT, .F.)

oModel:AddFields( 'FIZMASTER', /*cOwner*/, oStruFIZ, {|oMdl, cAction, cIDField, xValue| FillItemModel(oMdl, cAction, cIDField, xValue)}, {|oMdl| ChkDupl(oMdl)}, /*bCarga*/ )
oModel:AddGrid(   'F42DETAIL','FIZMASTER', oStruF42, /*bLinePre*/, {|oMdl| ChkDates(oMdl)}, {|oMdl, nLine, cAction| FillItemGrid(oMdl, nLine, cAction)}, /*bPosVal*/, /*BLoad*/ )

    oModel:SetPrimaryKey( { "FIZ_FILIAL", "FIZ_COD"} )

    // Faz relaciomaneto entre os compomentes do model
    oModel:SetRelation( 'F42DETAIL', {{ 'F42_FILIAL', 'xFilial( "F42" )' },  { 'F42_ROLE', 'FIZ_COD' }}, F42->( IndexKey( 1 ) ) )

    oModel:GetModel( 'F42DETAIL' ):SetUniqueLine( { 'F42_REPORT','F42_ITEM' } )


    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription( STR0012 )

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( 'FIZMASTER' ):SetDescription( STR0012 )
    oModel:GetModel( 'F42DETAIL' ):SetDescription( STR0011 )
    // Liga a validasso da ativacao do Modelo de Dados

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oModel   := FWLoadModel( 'RU06D01' )
    // Cria a estrutura a ser usada na View
    Local oStruFIZ 	:= FWFormStruct( 2, 'FIZ' ) 
    Local oStruF42 := FWFormStruct( 2, 'F42' )
    Local oView

    oStruFIZ:SetNoFolder()
    oStruF42:RemoveField("F42_ROLE")

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados sers utilizado
    oView:SetModel( oModel )


    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( 	'FIELD_FIZ', oStruFIZ, 'FIZMASTER' )
    oView:AddGrid( 	'GRID_F42', oStruF42, 'F42DETAIL')

    oView:AddIncrementField('GRID_F42','F42_ITEM')

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'TELA' , 30 )
    oView:CreateHorizontalBox( 'TELA2' , 70 )


    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView( 'FIELD_FIZ', 'TELA' )
    oView:SetOwnerView( 'GRID_F42', 'TELA2' )

Return oView

Function R0601aVld()

    Local lRet
    Local oModelDT := FwModelActive()
    Local oDetail := oModelDT:GetModel('F42DETAIL')
    Local cReadVar := ReadVar()
    Local cCampo := If("DFROM" $ cReadVar, "F42_DATETO", "F42_DFROM")
    Local cCampoF42 := If("DATETO" $ cReadVar, "F42_DATETO", "")

    If cCampoF42 == "F42_DATETO"
        If(!Empty(oDetail:GetValue("F42_DATETO")))
            lRet := oDetail:GetValue("F42_DFROM") <= oDetail:GetValue("F42_DATETO")
        Else
            lRet := .T.
        EndIf
    Else
        lRet := Vazio() .Or. oDetail:GetValue("F42_DFROM") <= oDetail:GetValue("F42_DATETO") .Or. Empty(oDetail:GetValue(cCampo))
    EndIf

Return lRet

/*/{Protheus.doc} ChkSigAcc
ChkSigAcc must check if chief acc. can sign this report or not.
@author felipe.morais
@since 28/09/2017
@version undefined

@type function
/*/

Function ChkSigAcc(dDate as date, cReport As Char)
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array
Default cReport	:= "TORG12"
DEFAULT dDate  := Ctod("//")
if EMPTY(dDate)
    dDate := Iif(Empty(F35->F35_PDATE),dDataBase,F35->F35_PDATE)
endif


lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

cReport	+= "|ALL|"

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "CHFACC")
		If (AllTrim(F42->F42_REPORT) $ cReport)
			If ((dDate >= F42->F42_DFROM) .And. (dDate <= F42->F42_DATETO)) .OR. ((dDate >= F42->F42_DFROM) .And. (Empty(F42->F42_DATETO)))
				lRet := .T.
			Endif
		Endif
	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)


/*/{Protheus.doc} ChkSigDir
ChkSigDir must check if chief dir. can sign this report or not.
@author felipe.morais
@since 28/09/2017
@version undefined

@type function
/*/

Function ChkSigDir(dDate as date, cReport As Char)
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array
Default cReport	:= "TORG12"
DEFAULT dDate  := Ctod("//")

if EMPTY(dDate)
    dDate := Iif(Empty(F35->F35_PDATE),dDataBase,F35->F35_PDATE)
endif


lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

cReport	+= "|ALL|"

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "CHFDIR")
		If (AllTrim(F42->F42_REPORT) $ cReport)
			If ((dDate >= F42->F42_DFROM) .And. (dDate <= F42->F42_DATETO)) .OR. ((dDate >= F42->F42_DFROM) .And. (Empty(F42->F42_DATETO)))
				lRet := .T.
			Endif
		Endif

	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} ChkSigStc
ChkSigStc must check if stockman can sign this report or not.
@author felipe.morais
@since 28/09/2017
@version undefined

@type function
/*/

Function ChkSigStc()
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array

lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "STCMAN")
		If (FwIsInCallStack("RU02R01") .Or. FwIsInCallStack("MATA101N"))
			If (AllTrim(F42->F42_REPORT) $ "M4|ALL|")
				If ((dDataBase >= F42->F42_DFROM) .And. (dDataBase <= F42->F42_DATETO)) .OR. ((dDate >= F42->F42_DFROM) .And. (Empty(F42->F42_DATETO)))
					lRet := .T.
				Endif
			Endif
		Else
			If (AllTrim(F42->F42_REPORT) $ "TORG12|ALL|")
				If ((dDataBase >= F42->F42_DFROM) .And. (dDataBase <= F42->F42_DATETO)) .OR. ((dDate >= F42->F42_DFROM) .And. (Empty(F42->F42_DATETO)))
					lRet := .T.
				Endif
			Endif
		Endif
	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)



/*/{Protheus.doc} ChkSigDir
ChkSigDir must check if chief dir. can sign this report or not.
@author Nikitenko Artem
@since 16/03/2018
@version undefined

@type function
/*/

Function ChkCHMCOM()
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array

lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "CHMCOM")
		If (AllTrim(F42->F42_REPORT) $ "TORG-1|TORG-2|M-7|ALL|")
			If ((dDataBase >= F42->F42_DFROM) .And. (dDataBase <= F42->F42_DATETO)) .OR. ((dDate >= F42->F42_DFROM) .And. (Empty(F42->F42_DATETO)))
				lRet := .T.
			Endif
		Endif
	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)


/*/{Protheus.doc} ChkSigDir
ChkSigDir must check if chief dir. can sign this report or not.
@author Nikitenko Artem
@since 16/03/2018
@version undefined

@type function
/*/

Function ChkMEMCOM()
Local lRet as Logical
Local aArea as Array
Local aAreaF42 as Array

lRet := .F.
aArea := GetArea()
aAreaF42 := F42->(GetArea())

If (xFilial("F42") == F42->F42_FILIAL)
	If (AllTrim(F42->F42_ROLE) == "MEMCOM")
		If (AllTrim(F42->F42_REPORT) $ "TORG-1|TORG-2|M-7|ALL|")
			If ((dDataBase >= F42->F42_DFROM) .And. (dDataBase <= F42->F42_DATETO)) .OR. ((dDate >= F42->F42_DFROM) .And. (Empty(F42->F42_DATETO)))
				lRet := .T.
			Endif
		Endif
	Endif
Endif

RestArea(aAreaF42)
RestArea(aArea)
Return(lRet)



/*/{Protheus.doc} SRAoverFIL
This function provides the UI for a specific standard query, which selects employees over all the filials.
@author artem.kostin
@since 11/06/2018
@type function
/*/
Function SRAoverFIL()
Static cEmplCode := ""
Static cEmplName := ""

Local cQuery := ""
Local lRet := .T.
Local oDlg := nil
Local aIndex := {}
Local aSeek   := {}

Local bOk := { || TRB->(dbGoTo(oBrowse:At())),;
				cEmplCode := TRB->RA_MAT,;
				cEmplName := SubStr(TRB->RA_NSOCIAL,1,GetSX3Cache("F42_NAME", "X3_TAMANHO")),;
				oDlg:End();
			}

cQuery := " select RA_FILIAL, RA_MAT, RA_NOME, RA_NSOCIAL from " + RetSQLName("SRA") + " where d_e_l_e_t_ = ' ' order by ra_filial, ra_mat, RA_NOME;"

Aadd( aIndex, "RA_FILIAL" )
Aadd( aIndex, "RA_MAT" )
Aadd( aIndex, "RA_NOME" )

Aadd( aSeek, { "Filial + Code" , {;
	{"","C",GetSX3Cache("RA_FILIAL", "X3_TAMANHO"),0,STR0008};
	,{"","C",GetSX3Cache("RA_MAT", "X3_TAMANHO"),0,STR0009};
	} } )
Aadd( aSeek, { "Filial + Name + Code" , {;
	{"","C",GetSX3Cache("RA_FILIAL", "X3_TAMANHO"),0,STR0008};
	,{"","C",GetSX3Cache("RA_NOME", "X3_TAMANHO"),0,STR0009};
	,{"","C",GetSX3Cache("RA_MAT", "X3_TAMANHO"),0,STR0010};
	} } )

DEFINE MSDIALOG oDlg FROM 0,0 TO 600,800 PIXEL
	DEFINE FWFORMBROWSE oBrowse DATA QUERY ALIAS "TRB" QUERY cQuery FILTER SEEK ORDER aSeek INDEXQUERY aIndex DOUBLECLICK bOk OF oDlg
		ADD BUTTON oButton TITLE "Ok" ACTION bOk OF oBrowse
		ADD BUTTON oButton TITLE "Cancel" ACTION { || oDlg:End() } OF oBrowse
		ADD COLUMN oColumn DATA { ||  RA_FILIAL  } TITLE STR0008    SIZE GetSX3Cache("RA_FILIAL", "X3_TAMANHO") OF oBrowse
		ADD COLUMN oColumn DATA { ||  RA_MAT     } TITLE STR0009    SIZE GetSX3Cache("RA_MAT", "X3_TAMANHO") OF oBrowse
		ADD COLUMN oColumn DATA { ||  RA_NOME } TITLE STR0010	SIZE 50 OF oBrowse
	ACTIVATE FWFORMBROWSE oBrowse
ACTIVATE MSDIALOG oDlg CENTERED

Return(lRet)



/*/{Protheus.doc} ret1SRAoverFIL
This function returns the content of the static variable, which holds an employee's code.
@author artem.kostin
@since 11/06/2018
@type function
/*/
Function ret1SRAoverFIL()
Return(cEmplCode)



/*/{Protheus.doc} ret2SRAoverFIL
This function returns the content of the static variable, which holds an employee's name.
@author artem.kostin
@since 11/06/2018
@type function
/*/
Function ret2SRAoverFIL()
Return(cEmplName)


/*/{Protheus.doc} RU06D01GetSigner
Function for searching signers
@author Artem Niitenko
@since 09-12-2021
@type function
/*/
Function RU06D01GetSigner(cMvparN,cKeyOfReport)
	Local aSigners 	as array
	Local cDESCSU 	as Char
	Local cRNome 	as Char
	Local cRANome 	as Char
	Local cAliasTM 	as Char
	Local cQuery 	as Char
	Local lSQ3Using as logical
	Local cCargo 	as Char

	lSQ3Using:=.F.
	aSigners := {}
	IF cMvparN==''
		cRANome := ''
		cDESCSU := ''
	ELSE	
		IF TCCanOpen('SQ3')
			DbSelectArea('SQ3')
			IF SELECT('SQ3')>0
				lSQ3Using:=.T.
				cQuery := "SELECT DISTINCT F42_NAME, Q3_DESCSUM "
				cQuery += "FROM " + RetSqlName("F42") + " AS F42 "

				cQuery += "INNER JOIN " + RetSqlName("SQ3") + " AS SQ3 " 
				cQuery += "ON F42.F42_CARGO = SQ3.Q3_CARGO "

				cQuery += "AND SQ3.Q3_FILIAL = '"+xFilial('SQ3')+"' "
				cQuery += "AND F42.F42_EMPL = '" + cMvparN + "' " 
				cQuery += "AND F42.F42_REPORT " + cKeyOfReport  //example "('M-15', 'ALL', 'M15')"
				cQuery += " AND F42.D_E_L_E_T_=' ' "
				cQuery += "AND SQ3.D_E_L_E_T_=' '"
			ENDIF
			SQ3->(dbCloseArea())
		ENDIF
		If !lSQ3Using
			cQuery := "SELECT F42_NAME, F42_DSCCRG AS Q3_DESCSUM, F42_CARGO " 
			cQuery += "FROM " + RetSqlName("F42") + " AS F42 "

			cQuery += "WHERE F42.F42_EMPL = '" + cMvparN + "' "
			cQuery += "AND F42.F42_REPORT " + cKeyOfReport //example "('M-15', 'ALL', 'M15')"
			cQuery += " AND F42.D_E_L_E_T_ = ' ' "
		ENDIF
		cQuery := ChangeQuery(cQuery)

		cAliasTM := GetNextAlias()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTM,.T.,.T.)
		DbSelectArea(cAliasTM)
		(cAliasTM)->(DbGoTop())
		cDESCSU := alltrim((cAliasTM)->Q3_DESCSUM)
		cRNome 	:= alltrim((cAliasTM)->F42_NAME)
		
		cRANome := substr(cRNome,1,at(' ',cRNome,1))
		cRANome += ' ' + substr(cRNome,at(' ',cRNome,1),2)
		cRANome += '.' + substr(cRNome,at(' ',cRNome,len(cRANome)),2) +'.'
		cCargo:=Alltrim((cAliasTM)->F42_CARGO)
		(cAliasTM)->(dbCloseArea())

	ENDIF
	Aadd(aSigners,cRNome) //Full name F42_NAME
	Aadd(aSigners,cRANome)//Initials
	Aadd(aSigners,cDESCSU)//Description of Profession's Name F42_DSCCRG or Q3_DESCSUM
	Aadd(aSigners,cCargo) //Profession F42_CARGO

RETURN aSigners

/*/{Protheus.doc} ChkDupl()
    This function check duplicates records in FIZ table

    @type Static Function
    @param oModel, obejct with model
    @return lRet

    @author Dmitry Borisov
    @since 2024/01/10
    @example ChkDupl(oModel)
*/
Static Function ChkDupl(oModel)
    Local lRet := .T.

    lRet := ExistChav("FIZ", oModel:GetValue("FIZ_COD"))
    If !lRet
        Help("",1,"RU01D06",,STR0020,1,0,,,,,,{STR0019}) 
    EndIf
Return lRet

/*/{Protheus.doc} ChkDates()
    This function check cross periods for employee

    @type Static Function
    @param oModel, object with model
    @return lRet

    @author Dmitry Borisov
    @since 2024/01/10
    @example ChkDates(oModel)
*/
Static Function ChkDates(oModel)
    Local lRet   := .T.
    Local nLine  := oModel:GetLine()
    Local nI     := 0
    Local dStart := oModel:GetValue('F42_DFROM')
    Local cRole  := oModel:GetValue('F42_ROLE')
    Local cEmpl  := oModel:GetValue('F42_EMPL')
    Local cRepo  := oModel:GetValue('F42_REPORT')

    If oModel:Length() > 1
        For nI := 1 To oModel:Length()
            If nI <> nLine .And. cRole == oModel:GetValue('F42_ROLE', nI) .And. ;
            cEmpl == oModel:GetValue('F42_EMPL', nI) .And. cRepo == oModel:GetValue('F42_REPORT', nI)
                If dStart >= oModel:GetValue('F42_DFROM', nI) .And. (Empty(oModel:GetValue('F42_DATETO', nI)) .Or. dStart <= oModel:GetValue('F42_DATETO', nI))
                    lRet := .F.
                    Exit
                EndIf
            EndIf
        Next nI
    EndIf

    If !lRet
        Help("",1,"RU01D06",,STR0017,1,0,,,,,,{STR0018}) 
    EndIf
Return lRet

/*/{Protheus.doc} FillItemGrid()
    This function change incremental field: assign role (FIZ_COD) to F42_ITEM field
    Calls from grid item (F42DETAIL)

    @type Static Function
    @param oModel , object with submodel
    @param nLine  , numeric, grid row number
    @param cAction, string with current action
    @return lRet

    @author Dmitry Borisov
    @since 2024/03/06
    @example FillItemGrid(oModel, nLine, cAction)
*/
Static Function FillItemGrid(oModel, nLine, cAction)
    Local lRet      := .T.
    Local oView     := FWViewActive()
    Local oMdlMain  := FWModelActive()

    If cAction == 'SETVALUE'
        If !Empty(oMdlMain:GetValue("FIZMASTER","FIZ_COD")) .And. At(oMdlMain:GetValue("FIZMASTER","FIZ_COD"), oModel:GetValue("F42_ITEM")) == 0
            oModel:LoadValue("F42_ITEM",StrTran(oModel:GetValue("F42_ITEM"),Replicate("0",Len(oMdlMain:GetValue("FIZMASTER","FIZ_COD"))),oMdlMain:GetValue("FIZMASTER","FIZ_COD")))
            oView:Refresh("GRID_F42")
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} FillItemModel()
    This function change incremental field: assign role (FIZ_COD) to F42_ITEM field
    Calls from parent model (FIZMASTER)

    @type Static Function
    @param oModel  , object with model (FIZMASTER)
    @param cAction , string with current action
    @param cIDField, string with field name
    @param xValue  , new field value
    @return lRet

    @author Dmitry Borisov
    @since 2024/03/06
    @example FillItemModel(oModel, cAction, cIDField, xValue)
*/
Static Function FillItemModel(oModel, cAction, cIDField, xValue)
    Local lRet      := .T.
    Local nI        := 0
    Local oView     := FWViewActive()
    Local oMdlMain  := FWModelActive()
    Local oSubModel := oMdlMain:GetModel("F42DETAIL")

    If cAction == "SETVALUE" .And. cIDField == "FIZ_COD" .And. xValue != Nil .And. xValue != oModel:GetValue("FIZ_COD")
        If oSubModel:IsEmpty()
            oSubModel:LoadValue("F42_ITEM",StrTran(oSubModel:GetValue("F42_ITEM", 1),Replicate("0",Len(xValue)),xValue))
        Else
            For nI := 1 To oSubModel:Length()
                oSubModel:GoLine(nI)
                If At(xValue, oSubModel:GetValue("F42_ITEM")) == 0
                    oSubModel:LoadValue("F42_ITEM",StrTran(oSubModel:GetValue("F42_ITEM"),Replicate("0",Len(xValue)),xValue))
                EndIf
            Next nI
            oSubModel:GoLine(1)
        EndIf
        oView:Refresh("GRID_F42")
    EndIf
Return lRet
                   
//Merge Russia R14 
                   
