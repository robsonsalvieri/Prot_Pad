#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#DEFINE B5PCODOPE   01
#DEFINE B5PNUMLOT	02
#DEFINE B5PCOMLOT	03
#DEFINE B5PNUMG	    04
#DEFINE B5PCNES	    05
#DEFINE B5PCNPJ	    06
#DEFINE CAMPO       01
#DEFINE TIPO        02
#DEFINE TAMANHO     03
#DEFINE DECIMAL     04

Static Function MenuDef()
	Local cFiltro   := " B5P_FILIAL=xFilial( 'B5I' ) .AND. B5P_CODOPE=B5I->B5I_CODOPE .AND. B5P_CMPLOT=B5I->B5I_CMPLOT .AND. B5P_NUMLOT=B5I->B5I_NUMLOT .AND. B5P->B5P_NMGOPE='"+ALLTRIM(GRPB5P->B5P_NMGOPE)+"'"
	Private aRotina	:= {}

	aAdd( aRotina, { "Ocorrências"	, 'CENMVCB5P(.f.,"Ocorrências por Guia")'	        , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Guia"         , "VISGUIMO(.t.)"              , 0 , 2 , 0 , NIL } )

Return aRotina

Function TempB5P(cCodOpe,cCompLot,cNumLot,lAuto)   
	Local oBrw    	    := FWmBrowse():New()
	Local aCampos       := RetorCampos()
	Local oTmpTab       := CriaTabTemp(aCampos)
	default cCodOpe     := ""
	default cCompLot    := ""
	default cNumLot     := ""
	default lAuto  		:= .F.

	If BscGuias(cCodOpe,cCompLot,cNumLot,lAuto)
		CarregaArqTmp() 
	EndIf

	oBrw:SetDescription( "Guias" )
	oBrw:SetAlias( oTmpTab:getAlias() )
	oBrw:SetFields(montaFields(aCampos))
	oBrw:SetProfileID( '1' )
	oBrw:SetMenuDef('CENMVCTB5')
	oBrw:DisableDetails()
	oBrw:SetWalkthru(.F.)
	oBrw:SetAmbiente(.F.)
	If !lAuto
		oBrw:Activate()		
	EndIf

	oTmpTab:delete()

Return oBrw

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetorCampos

Retorna os campos para criar o arquivo temporario 

@author José Paulo
@since 29/01/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetorCampos()

	Local aFields := {}

	aAdd(aFields,{"B5P_CODOPE"	,"C",006,0})
	aAdd(aFields,{"B5P_NUMLOT"	,"C",012,0})
	aAdd(aFields,{"B5P_CMPLOT"	,"C",006,0})
	aAdd(aFields,{"B5P_NMGOPE"	,"C",020,0})

Return aFields

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTemp

Cria o arquivo temporario 

@author José Paulo
@since 29/01/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaTabTemp(aCampos)

	Local oTmpTab   := Nil
	Default aCampos := {}

	oTmpTab := FWTemporaryTable():New( 'GRPB5P' )
	oTmpTab:SetFields( aCampos )
	oTmpTab:AddIndex("01",{"B5P_CODOPE"})
	oTmpTab:AddIndex("02",{"B5P_NUMLOT"})
	oTmpTab:AddIndex("03",{"B5P_CMPLOT"})
	oTmpTab:AddIndex("04",{"B5P_NMGOPE"})
	oTmpTab:Create()

Return oTmpTab

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscGuias

retorna guias

@author José Paulo
@since 29/01/2020
/*/
//--------------------------------------------------------------------------------------------------
Function BscGuias(cCodOpe,cCompLot,cNumLot,lAuto)
	Local cAliasTmp := "TRBB5P"
	Local cSql 		:= ""
	Local lFound	:= .F.
	Default cNumLot := ""
	Default cCompLot:= ""
	Default cCodOpe := ""
	Default lAuto   := .F.

	cSql := " SELECT DISTINCT B5P_CODOPE, B5P_NUMLOT,B5P_CMPLOT,B5P_NMGOPE "
	cSql += " FROM " 
	cSql += "   " + RetSqlName("B5P") + " B5P "
	cSql += " WHERE "
	cSQL += " B5P_FILIAL = '"+xFilial("B5P")+"' "
	cSQL += " AND B5P_CODOPE = '"  + cCodOpe  + "'"
	cSQL += " AND B5P_CMPLOT = '"  + cCompLot + "'"
	cSQL += " AND B5P_NUMLOT = '"  + cNumLot  + "'"
	cSQL += " AND B5P.D_E_L_E_T_ = ''  "
	cSql += " ORDER BY B5P_NMGOPE "

	If (Select('TRBB5P') <> 0)
		dbSelectArea('TRBB5P')
		TRBB5P->(dbCloseArea())
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasTmp,.F.,.T.)

	lFound := !TRBB5P->(Eof())
	If !lFound
		TRBB5P->(dbCloseArea())
	EndIf

Return lFound


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaArqTmp

Preenche o arquivo temporario com os registros 

@author José Paulo
@since 29/01/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaArqTmp(oTmpTab)
	Local lRet := .F.
	
	While !TRBB5P->(Eof())
		RecLock('GRPB5P',.T.)
		GRPB5P->B5P_CODOPE	:= TRBB5P->B5P_CODOPE
		GRPB5P->B5P_NUMLOT	:= TRBB5P->B5P_NUMLOT
		GRPB5P->B5P_CMPLOT 	:= TRBB5P->B5P_CMPLOT
		GRPB5P->B5P_NMGOPE	:= TRBB5P->B5P_NMGOPE

		GRPB5P->(MsUnlock())
		TRBB5P->(DbSkip())

	EndDo

	TRBB5P->(dbCloseArea())
	lRet := .T.

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaFields

Carrega os campos do browse 

@author José Paulo
@since 29/01/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function montaFields(aCampos)

	Local cPicture := "@!"
	Local nAlign   := 1 
	Local aFields  := {}

	aAdd(aFields,GetColuna(aCampos[B5PCODOPE,CAMPO],"Registro ANS"  ,aCampos[B5PCODOPE,TIPO],cPicture,nAlign,aCampos[B5PCODOPE,TAMANHO],aCampos[B5PCODOPE,DECIMAL]))
	aAdd(aFields,GetColuna(aCampos[B5PNUMLOT,CAMPO],"Numero Lote"   ,aCampos[B5PNUMLOT,TIPO],cPicture,nAlign,aCampos[B5PNUMLOT,TAMANHO],aCampos[B5PNUMLOT,DECIMAL]))
	aAdd(aFields,GetColuna(aCampos[B5PCOMLOT,CAMPO],"Competência"   ,aCampos[B5PCOMLOT,TIPO],cPicture,nAlign,aCampos[B5PCOMLOT,TAMANHO],aCampos[B5PCOMLOT,DECIMAL]))
	aAdd(aFields,GetColuna(aCampos[B5PNUMG,CAMPO]  ,"Num.Guia Op."  ,aCampos[B5PNUMG,TIPO],cPicture,nAlign,aCampos[B5PNUMG,TAMANHO],aCampos[B5PNUMG,DECIMAL]))

Return aFields 


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetColuna

Retorna uma coluna para o markbrowse 

@author José Paulo
@since 29/01/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal)

	Local   aColuna  := {}
	Local   bData    := &("{||" + cCampo +"}") 
	Default nAlign   := 1
	Default nSize    := 20
	Default nDecimal := 0
	Default cTipo    := "C"
	
	aColuna := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return aColuna