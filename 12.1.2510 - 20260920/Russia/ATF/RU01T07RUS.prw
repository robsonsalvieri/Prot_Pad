#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RU01T07.CH"

#DEFINE FIELDS_STRUCT_RELACAO 11
#DEFINE FIELDS_STRUCT_ID 3
#DEFINE OPERATION_INSERT '1'

//Date of the last depreciation
Static dUltDepr	:= SuperGetMV("MV_ULTDEPR",.F., STOD(cValToChar(Year(dDataBase))+cValToChar(Month(dDataBase))+"31"))

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T07RUS

Main routine function

@param		None
@return		None
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------
Function RU01T07RUS()//change depr elements
    Private oBrowse := BrowseDef()

    DBSELECTAREA("F6N")
    DBSELECTAREA("F6O")

    If ExistCPO('F33', 'CHGLIQ', 2)
        oBrowse:Activate()
    Else
        Help(" ",1,"RU01T07RUS",,'',1,0,,,,,,{STR0011}) 
    EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Default browse inicialization

@param		None
@return		Object oBrowse
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Static function BrowseDef()
Local oBrowse
Local aStruct := {}
Local aGetStruct := {}
Local nI

    oBrowse	:= FWmBrowse():New()
    oBrowse:SetAlias('F6N')
    oBrowse:SetDescription(STR0001)
    oBrowse:DisableDetails()
    oBrowse:AddLegend( "F6N_OPER == '1'", "GREEN", STR0002)
    oBrowse:AddLegend( "F6N_OPER == '2'", "RED", STR0003)

    aGetStruct := F6N->(DBStruct())
        For nI := 2 to Len(aGetStruct)
            AAdd(aStruct, {RetTitle(aGetStruct[nI,1]), &('{|| F6N->'+ aGetStruct[nI,1] +'}'), aGetStruct[nI,2],'',0,aGetStruct[nI,3],aGetStruct[nI,4],.F.,,.T.})
        Next nI
    oBrowse:SetFields(aStruct)

Return oBrowse

//-----------------------------------------------------------------------
/*/{Protheus.doc} Menudef

Menu definition

@param		None
@return		Array aRotina
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

    ADD OPTION aRotina TITLE STR0004 ACTION 'RU01T07002()' OPERATION MODEL_OPERATION_INSERT ACCESS 0 
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.RU01T07RUS' OPERATION MODEL_OPERATION_VIEW ACCESS 0 
    ADD OPTION aRotina TITLE STR0006 ACTION 'RU01T07004()' OPERATION MODEL_OPERATION_DELETE ACCESS 0 

Return aRotina

Static Function ModelDef()
Local oStruF6N := FWFormStruct( 1, "F6N", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruF6O := FWFormStruct( 1, "F6O", /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel
Private oModelEvent as object

    oModel := MPFormModel():New('RU01T07RUS')
    oModel:AddFields('F6NMASTER',/*cOwner*/,oStruF6N)
    oModel:AddGrid('F6OGRID','F6NMASTER',oStruF6O)
    oModel:SetRelation('F6OGRID',{{xFilial('F6O'),'F6N_FILIAL'},{'F6O_LOT','F6N_LOT'}}, F6O->(IndexKey(1)) )
    oModel:SetPrimarykey({'F6N_FILIAL','F6N_LOT'})

    oModelEvent 	:= RU01T07EventRUS():New()
    oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Model View inicialization

@param		None
@return		Object oView
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Static Function ViewDef()
Local oModel	:= FWLoadModel( 'RU01T07RUS' )
Local oView		:= Nil
Local oStruF6N	:= FWFormStruct(2, 'F6N' )	
Local oStruF6O	:= FWFormStruct(2, 'F6O' )

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField('MASTER',oStruF6N,'F6NMASTER') 
    oView:AddGrid('GRID',oStruF6O,'F6OGRID') 

    oStruF6O:SetProperty( "F6O_NLQVAL" , MVC_VIEW_CANCHANGE, .T.  )
    oStruF6O:SetProperty( "F6O_NPERDP" , MVC_VIEW_CANCHANGE, .T.  )
    oStruF6O:SetProperty( "F6O_NTPDPR" , MVC_VIEW_CANCHANGE, .T.  )
    oStruF6O:SetProperty( "F6O_LOT" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_DATSTR" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_CBASE" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_ITEM" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_FADESC" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_TIPO" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_HISTOR" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_COMMEN" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_LIQVAL" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_PERDEP" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_OSPRDP" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_TPDEPR" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_SN3UID" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_UUID" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_SN4UID" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_BAIXA" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_SEQ" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6O:SetProperty( "F6O_TPSALD" , MVC_VIEW_CANCHANGE, .F.  )    
    oStruF6O:SetProperty( "F6O_SEQREA" , MVC_VIEW_CANCHANGE, .F.  ) 

    oStruF6N:SetProperty( "F6N_LOT" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6N:SetProperty( "F6N_DATE" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6N:SetProperty( "F6N_OPER" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6N:SetProperty( "F6N_USRCOD" , MVC_VIEW_CANCHANGE, .F.  )
    oStruF6N:SetProperty( "F6N_USER" , MVC_VIEW_CANCHANGE, .F.  )

    oView:CreateHorizontalBox('MASTERBODY' , 25)
    oView:SetOwnerView( "MASTER", 'MASTERBODY' )

    oView:CreateHorizontalBox('GRIDBODY' , 75)
    oView:SetOwnerView( "GRID", 'GRIDBODY' )
    oView:addUserButton(STR0007, '', {||RU01T07001_History(xFilial('F6O'),oModel:GetValue('F6OGRID', 'F6O_CBASE'),oModel:GetValue('F6OGRID','F6O_ITEM'))})
    oView:SetCloseOnOk({|| .T.})

Return oView

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T07001_History

Opens SD4 view on current asset by solution RU01S01RUS

@param		xFil - Current filial
            cBase - Asset code
            cItem - Asset position
@return		None
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Function RU01T07001_History( xFil, cBase, cItem)
Local aSN1Area := SN1->(GetArea())

    SN1->(DBSeek(xFil+cBase+cItem))
    RU01S01RUS()

    RestArea(aSN1Area)

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T07002_Open_MarkBrowse

Creates MarkBrowse on any existing and avialiable to change assets

@param		None
@return		None
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Function RU01T07002_Open_MarkBrowse()
Local aColumns := {}
Local aStru	:= SN3->(DBSTRUCT())
Local aStruSN1 := SN1->(DBSTRUCT())
Local nX
Local cQuery := ''
Local oDlgMrk := Nil
Private cArqTrab := ''
Private oMrkBrowse := Nil
Private oTrbTab as object

    oTrbTab := Nil
    SN3->(DBCloseArea())
    SN1->(DBCloseArea())
    For nX := 1 to Len(aStruSN1)
        AAdd(aStru, aStruSN1[nX])
    Next nX

    If dDataBase == dUltDepr+1        
        If Pergunte('RU01T07RUS',.T.)
            cQuery := " SELECT N3_FILIAL, N3_CBASE, N3_ITEM, N3_TIPO, N3_HISTOR, N3_TPSALDO, N1_DESCRIC, N3_HISTOR, N3_LIQVAL1, "
            cQuery += " N3_PERDEPR, N3_TPDEPR, N3_UUID, N3_SEQ, N3_BAIXA, N3_SEQREAV from "+ RetSqlName('SN3') 
            cQuery += " N3, "+ RetSqlName('SN1') +" N1 WHERE N1_CBASE = N3_CBASE AND N1_ITEM = N3_ITEM AND N1_FILIAL = N3_FILIAL AND N1.D_E_L_E_T_ = '' AND N3.D_E_L_E_T_ = ''"
            cQuery += " AND N1_CBASE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"
            cQuery += " AND N1_GRUPO BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
            cQuery += " AND N3_TIPO BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
            cQuery += " AND N1_DEPGRP BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
            cQuery += " AND N1_STATUS BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
            cQuery += " AND N1_FILIAL = '" + xFilial('SN1') + "'  AND not exists ("
            cQuery += " SELECT F6N_OPER FROM "+ RetSqlName('F6O') +" FO, "+ RetSqlName('F6N') +" FN"
            cQuery += " WHERE F6O_LOT = F6N_LOT AND F6O_FILIAL = F6N_FILIAL AND FN.D_E_L_E_T_ = ''"
            cQuery += " AND FO.D_E_L_E_T_ = '' AND F6O_CBASE = N3_CBASE AND F6O_ITEM = N3_ITEM AND F6O_TIPO = N3_TIPO AND F6N_OPER = '" 
            cQuery += OPERATION_INSERT + "' and F6N_DATE = '" + DTOS(dDataBase) + "')"

            cQuery := ChangeQuery(cQuery)

            DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBN13",.F.,.T.)

            TCSQLEXEC("Update " + cQuery + "SET N3_OK = '  '")

            For nX := 1 To Len(aStru)
                If	aStru[nX][1] $ "N3_FILIAL|N3_CBASE|N3_ITEM|N3_TIPO|N3_HISTOR|N3_TPSALDO|N1_DESCRIC|N3_HISTOR|N3_LIQVAL1|N3_PERDEPR|N3_TPDEPR|N3_UUID|N3_BAIXA|N3_SEQ"
                    AAdd(aColumns,FWBrwColumn():New())
                    aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
                    aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1])) 
                    aColumns[Len(aColumns)]:SetSize(aStru[nX][3]) 
                    aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
                    aColumns[Len(aColumns)]:SetPicture(PesqPict("S"+Left(aStru[nX][1],2),aStru[nX][1]))
                EndIf 	
            Next nX 


            cArqTrab := GetNextAlias()

            oTrbTab := FWTemporaryTable():New( cArqTrab )  
            oTrbTab:SetFields(aStru) 
            oTrbTab:AddIndex("1", {"N3_FILIAL","N3_CBASE","N3_ITEM"})

            oTrbTab:Create()  

            Processa({||SqlToTrb(cQuery, aStru, cArqTrab)})

            oMrkBrowse:= FWMarkBrowse():New()
            oMrkBrowse:SetFieldMark("N3_OK")
            oMrkBrowse:SetOwner(oDlgMrk)
            oMrkBrowse:SetOnlyFields({"N3_FILIAL","N3_CBASE","N3_ITEM","N3_TIPO","N3_HISTOR","N3_TPSALDO","N3_BAIXA","N3_SEQ"})
            oMrkBrowse:SetAlias(cArqTrab)
            oMrkBrowse:SetDescription(STR0008)
            oMrkBrowse:SetMenuDef('')
            oMrkBrowse:AddButton(STR0004, {||RU01T07003()},,3)//Добавить
            oMrkBrowse:bAllMark := {|| RU01T07005_Is_All_Marked()}
            oMrkBrowse:SetColumns(aColumns)
            oMrkBrowse:DisableReport()
            oMrkBrowse:Activate()

            TRBN13->(DBCloseArea())
            (cArqTrab)->(DBCloseArea())
        EndIf
    Else 
        MsgAlert(STR0009 +"(" +;
                DTOC(dUltDepr+1) + ")", STR0010)
    EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T07003_Show_View

Executes View on operation Insert

@param		None
@return		None
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Function RU01T07003_Show_View()

    FWExecView(STR0001 , 'RU01T07RUS', MODEL_OPERATION_INSERT, /*oDlg*/, /*bCloseOnOk*/ ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)
    oMrkBrowse:GetOwner():End()

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T07004_Storno

Executes View on operation Update
@param		None
@return		None
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Function RU01T07004_Storno()

    If F6N->F6N_DATE < dUltDepr
        MsgAlert(STR0012, STR0013)
    Else
        FWExecView(STR0014 , 'RU01T07RUS', MODEL_OPERATION_UPDATE, /*oDlg*/, /*bCloseOnOk*/ ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)
    EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T07005_Is_All_Marked

Marks all positions on MarkBrowse
@param		None
@return		lRet
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Static Function RU01T07005_Is_All_Marked()
Local lRet := .T.

    oMrkBrowse:AllMark()
    oMrkBrowse:Refresh()

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T07006_Valid

Validates new depreciation period
@param		nOstDep - new depreciation period
@return		lRet
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Function RU01T07006_Valid(nOstDep)
Local aArea := GetArea()
Local aAreaSN1 := SN1->(GetArea())
Local aAreaF44 := F44->(GetArea())
Local lRet := .T.
Local oModel := FwModelActive()
Default nOstDep := 0


    If oModel <> Nil
        SN1->(DBSeek(xFilial('F6O')+oModel:GetValue('F6OGRID', 'F6O_CBASE')+oModel:GetValue('F6OGRID', 'F6O_ITEM')))
    EndIf

    nOstDep := IIF(oModel <> Nil,oModel:GetValue('F6OGRID', 'F6O_NPERDP'),SN3->N3_PERDEPR) - ;
            ((Year(dUltDepr) - Year(SN1->N1_AQUISIC))*12 + (Month(dUltDepr) - Month(SN1->N1_AQUISIC)) )
    If nOstDep < 0 
        lRet := .F.
    EndIf

    RestArea(aAreaF44)
    RestArea(aAreaSN1)
    RestArea(aArea)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T07007_Ret_Rem_Dep

Validates new depreciation period
@param		none
@return		nOstDep - remain depreciation
@author 	eradchinskii   
@since 		04.04.2024
@version 	1.3
@project	MA3
/*/
//-----------------------------------------------------------------------

Function RU01T07007_Ret_Rem_Dep()
Local nOstDep := 0
    RU01T07006(@nOstDep)
    If nOstDep < 0
        MsgAlert(STR0015, STR0016)
    EndIf

Return nOstDep
