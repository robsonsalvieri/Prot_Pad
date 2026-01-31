#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIC200.CH" // mesmo CH do OFIC200

/*/{Protheus.doc} OFIC201()
Consulta Consolidada por Campo DEF

@author Andre Luis Almeida
@since 12/07/2022
@version 1.0
@return NIL
/*/
Function OFIC201()
Local cQAlias     := "SQLAUX"
Local cQuery      := ""
Local aVD7        := {}
Local aVDB        := {}
Local aParamBox   := {}
Local aRet        := {}
Private cCadastro := STR0008 // Consulta Consolidada por Campo DEF
Private aRotina   := {}
//
// Validacao de Licencas DMS
//
If !OFValLicenca():ValidaLicencaDMS()
	Return
EndIf
//
// Monta vetores do VD7 (Cabeçalho do DEF) e do VDB (Histórico DEF) para montar tela de Filtro
//
cQuery := "SELECT DISTINCT VD7_CODDEF, VD7_DESDEF "
cQuery += "  FROM "+ RetSQLName("VD7")
cQuery += " WHERE VD7_FILIAL IN (SELECT DISTINCT VD7_FILIAL FROM "+ RetSQLName("VD7") + " WHERE D_E_L_E_T_ = ' ')"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VD7_CODDEF"
DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .f., .t.)
Do While !(cQAlias)->(EoF())
	AAdd(aVD7, (cQAlias)->VD7_CODDEF+"="+(cQAlias)->VD7_DESDEF )
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(DbCloseArea())
//
cQuery := "SELECT DISTINCT VDB_DATA "
cQuery += "  FROM "+ RetSQLName("VDB")
cQuery += " WHERE VDB_FILIAL IN (SELECT DISTINCT VDB_FILIAL FROM " + RetSQLName("VDB") + " WHERE D_E_L_E_T_ = ' ')"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VDB_DATA DESC"
DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .f., .t.)
Do While !(cQAlias)->(EoF())
	AAdd(aVDB, Transform( stod((cQAlias)->VDB_DATA) , "@D" ) )
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(DbCloseArea())
//
If len(aVD7) > 0 .and. len(aVDB) > 0
	// Parambox - Filtros
	aAdd(aParamBox,{2,STR0011,aVD7[1],aVD7,120,"",.T.}) // Código do DEF
	aAdd(aParamBox,{2,STR0012,aVDB[1],aVDB, 55,"",.T.}) // Data Fechamento
	If ParamBox(aParamBox,STR0010,@aRet,,,,,,,,.F.) // Filtro
		//
		OC2010011_DetalharDEF( aRet[1] , ctod(aRet[2]) )
		//
	EndIf
	//
EndIf
//
Return NIL

/*/{Protheus.doc} OC2010011_DetalharDEF
Browsers da Consulta Consolidada por Campo DEF

@author Andre Luis Almeida
@since 12/07/2022
/*/
Static Function OC2010011_DetalharDEF( cCodDEF , dDatDEF )
Local aSizeAut := MsAdvSize(.f.)
Local aCposDEF := {}
Local nCntFor  := 0

Private oVCUBrwStruct
Private oVCVBrwStruct

// Tabela Temporaria VCU
oVCUBrwStruct := OFBrowseStruct():New({"VD7","VCU"})
oVCUBrwStruct:AddField( "VCU_CODDEF" )
oVCUBrwStruct:AddField( "VCU_CPODEF" )
oVCUBrwStruct:AddField( "VCU_DATA"   )
oVCUBrwStruct:AddField( "VCU_VALOR"  )
if VD7->(FieldPos("VD7_MOEDAC")) > 0
	oVCUBrwStruct:AddField( "VD7_MOEDAC" )
endif
//if VCU->(FieldPos("VCU_MOEDA")) > 0
//	oVCUBrwStruct:AddField( "VCU_MOEDA" )
//
//	oVCUBrwStruct:AddFieldManual( DMS_DataContainer():New({;
//										{ 'cIdField' , 'VCU_DMOEDA' },;
//										{ 'cTitulo' , RetTitle("VCU_DMOEDA")  },;
//										{ 'cTipo' , 'C' },;
//										{ 'nTamanho' , tamSX3("VCU_DMOEDA")[1] },;
//										{ 'nDecimal' , 0 },;
//										{ 'cPicture' , '@!' } } ) )
//endif


oVCUBrwStruct:AddIndex( "VCU_CPODEF" )
oVCUBrwStruct:AddSeek( {"VCU_CPODEF"} )

oVCUBrwStruct:CriaTabTmp()

// Tabela Temporaria VCV
oVCVBrwStruct := OFBrowseStruct():New({"VCV"})
oVCVBrwStruct:AddField( "VCV_CPODEF" , , .f. )
oVCVBrwStruct:AddField( "VCV_CCUSTO" )
oVCVBrwStruct:AddField( "VCV_CCTCTB" )
oVCVBrwStruct:AddField( "VCV_ITEMCT" )
if VCV->(FieldPos("VCV_CLVL")) > 0
	oVCVBrwStruct:AddField( "VCV_CLVL" )
endif
oVCVBrwStruct:AddField( "VCV_VALOR"  )

oVCVBrwStruct:AddIndex( "VCV_CCUSTO" )
oVCVBrwStruct:AddSeek( {"VCV_CCUSTO"} )

oVCVBrwStruct:AddIndex( "VCV_CCTCTB+VCV_ITEMCT" )
oVCVBrwStruct:AddSeek( {"VCV_CCTCTB","VCV_ITEMCT"} )

oVCVBrwStruct:CriaTabTmp()

// Tabela Temporaria Filiais
oBrwStrF := OFBrowseStruct():New({"VCU"})
oBrwStrF:AddField( "VCU_FILIAL" , STR0009 ) // Filiais Contempladas
oBrwStrF:CriaTabTmp()

aCposDEF := OC2010021_LevantaDados( cCodDEF , dDatDEF ) // Levanta os Dados VCU/VCV/Filiais

oOFIC201 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],STR0008,,,,128,,,,,.t.) // Consulta Consolidada por Campo DEF

// Paineis na Tela
oTPanVCU := TPanel():New(0,0,"",oOFIC201,NIL,.T.,.F.,NIL,NIL,100,(oOFIC201:nClientHeight/4)-10,.F.,.F.)
oTPanVCU:Align := CONTROL_ALIGN_TOP
oTPanVCV := TPanel():New(0,0,"",oOFIC201,NIL,.T.,.F.,NIL,NIL,(oOFIC201:nClientWidth/2)*0.8,(oOFIC201:nClientHeight/4)-10,.F.,.F.)
oTPanVCV:Align := CONTROL_ALIGN_LEFT
oTPanFil := TPanel():New(0,(oOFIC201:nClientWidth/2)*0.8,"",oOFIC201,NIL,.T.,.F.,NIL,NIL,(oOFIC201:nClientWidth/2)*0.2,(oOFIC201:nClientHeight/4)-10,.F.,.F.)
oTPanFil:Align := CONTROL_ALIGN_RIGHT

// Browse VCU - Histórico DEF por Campo DEF
oBrwVCU := FWmBrowse():New()
oVCUBrwStruct:SetBrwOwner(oBrwVCU)
oBrwVCU:SetMenuDef('')
oBrwVCU:AddButton(STR0016,{ || OFIR201( cCodDEF , dDatDEF ) } ) // Imprimir Lista Analítica
oBrwVCU:SetUseFilter( .T. )
oBrwVCU:SetDescription(STR0008) // Consulta Consolidada por Campo DEF
oBrwVCU:SetUseFilter()
oBrwVCU:SetWalkThru(.F.)
oBrwVCU:SetAmbiente(.F.)
oBrwVCU:DisableDetails()
oBrwVCU:ForceQuitButton()
oBrwVCU:AddFilter( STR0004 , " VCU_CODDEF=='"+cCodDEF+"' .and. DTOS(VCU_DATA)=='"+dtos(dDatDEF)+"'" ,.t.,.t.,,,, "OFIC201" ) // Filtro Padrão
For nCntFor := 1 to len(aCposDEF)
	oBrwVCU:AddFilter( aCposDEF[nCntFor] , " VCU_CPODEF=='"+aCposDEF[nCntFor]+"'",.f.,.f.,,,, aCposDEF[nCntFor] )
Next
oBrwVCU:SetSeek(.T.,oVCUBrwStruct:GetSeek())
oBrwVCU:SetFieldFilter(oVCUBrwStruct:GetColFilter())
oBrwVCU:SetQueryIndex(oVCUBrwStruct:GetIndexes())
oVCUBrwStruct:AddBrwColumn()
oBrwVCU:SetAlias(oVCUBrwStruct:GetAlias())
oBrwVCU:SetOwner(oTPanVCU)
oBrwVCU:Activate()

// Browse VCV - Histórico DEF Analitico
oBrwVCV := FWmBrowse():New()
oVCVBrwStruct:SetBrwOwner(oBrwVCV)
oBrwVCV:SetMenuDef('')
oBrwVCV:SetUseFilter( .T. ) 
oBrwVCV:SetDescription(STR0005) // Analitico por Centro de Custo, Conta e Item Contabil
oBrwVCV:SetUseFilter()
oBrwVCV:SetWalkThru(.F.)
oBrwVCV:SetAmbiente(.F.)
oBrwVCV:DisableDetails()
oBrwVCV:SetSeek(.T.,oVCVBrwStruct:GetSeek())
oBrwVCV:SetFieldFilter(oVCUBrwStruct:GetColFilter())
oBrwVCV:SetQueryIndex(oVCUBrwStruct:GetIndexes())
oVCVBrwStruct:AddBrwColumn()
oBrwVCV:SetAlias(oVCVBrwStruct:GetAlias())
oBrwVCV:SetOwner(oTPanVCV)
oBrwVCV:Activate()

// Relacionamento entre os Browses VCU - Histórico DEF por Campo DEF e VCV - Histórico DEF Analitico
oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrwVCU , oBrwVCV , { { "VCV_CPODEF" , "VCU_CPODEF" } } )
oRelac:Activate()

// Filiais
oBrwFil := FWmBrowse():New()
oBrwStrF:SetBrwOwner(oBrwFil)
oBrwFil:SetMenuDef('')
oBrwFil:SetUseFilter( .F. ) 
oBrwFil:SetDescription(STR0009) // Filiais Contempladas
oBrwFil:SetWalkThru(.F.)
oBrwFil:SetAmbiente(.F.)
oBrwFil:DisableDetails()
oBrwFil:DisableReport()
oBrwFil:DisableConfig()
oBrwStrF:AddBrwColumn()
oBrwFil:SetAlias(oBrwStrF:GetAlias())
oBrwFil:SetOwner(oTPanFil)
oBrwFil:Activate()

oOFIC201:Activate()

// Limpar Tabelas Temporarias
oVCUBrwStruct:DelTrabTmp()
oVCVBrwStruct:DelTrabTmp()
oBrwStrF:DelTrabTmp()

Return NIL

/*/{Protheus.doc} OC2010021_LevantaDados
Levanta Dados para popular os Browsers da Consulta

@author Andre Luis Almeida
@since 14/07/2022
/*/
Static Function OC2010021_LevantaDados( cCodDEF , dDatDEF )
Local aCposDEF := {}
Local cQAlias  := "SQLAUX"
Local cQuery   := ""
Local lMOEDA := VD7->(FieldPos("VD7_MOEDAC")) > 0
local lVCVCLVL := VCV->(FieldPos("VCV_CLVL")) > 0

// Levanta as Filiais do VCU - Histórico DEF por Campo DEF
cQuery := "SELECT DISTINCT VCU_FILIAL "
cQuery += "  FROM "+ RetSQLName("VCU")
cQuery += " WHERE D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VCU_FILIAL"
oBrwStrF:LoadData( cQuery , .t. )
dbSelectArea(oBrwStrF:GetAlias())
dbGoTop()

// Levanta VCU ( Histórico DEF por Campo DEF ) agrupado por campo DEF / Data
cQuery := "SELECT VCU_CODDEF , VCU_CPODEF , VCU_DATA , SUM(VCU_VALOR) AS VCU_VALOR "
if lMOEDA
	cQuery += " , VD7_MOEDAC "
endif
cQuery += "  FROM "+RetSQLName("VCU") + " VCU "
if lMOEDA
	cQuery += " LEFT JOIN "+RetSQLName("VD7")+" VD7 ON VD7_FILIAL = '" + xFilial("VD7") + "' AND VD7_CODDEF = VCU_CODDEF AND VD7.D_E_L_E_T_ = ' ' "
endif
cQuery += " WHERE VCU_FILIAL IN (SELECT DISTINCT VCU_FILIAL FROM " + RetSQLName("VCU") + " WHERE D_E_L_E_T_ = ' ') "
cQuery += "   AND VCU_CODDEF = '"+cCodDEF+"'"
cQuery += "   AND VCU_DATA   = '"+dtos(dDatDEF)+"'"
cQuery += "   AND VCU.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY VCU_CODDEF , VCU_CPODEF , VCU_DATA "
if lMOEDA
	cQuery += " , VD7_MOEDAC "
endif
DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .f., .t.)
Do While !(cQAlias)->(EoF())
	aAdd(aCposDEF,(cQAlias)->( VCU_CPODEF ) ) // Vetor a ser utilizado no Filtro do Browse
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(DbCloseArea())

oVCUBrwStruct:LoadData( cQuery , .t. )
dbSelectArea(oVCUBrwStruct:GetAlias())
dbGoTop()
//

cQuery := "SELECT VCV_CPODEF , VCV_CCUSTO , VCV_CCTCTB , VCV_ITEMCT "
if lVCVCLVL
	cQuery += " , VCV_CLVL "
endif
cQuery += " , SUM(VCV_VALOR) AS VCV_VALOR "
cQuery += "  FROM "+RetSQLName("VCV")
cQuery += " WHERE VCV_FILIAL IN (SELECT DISTINCT VCV_FILIAL FROM " + RetSQLName("VCV") + " WHERE D_E_L_E_T_ = ' ') "
cQuery += "   AND VCV_CODDEF = '"+cCodDEF+"'"
cQuery += "   AND VCV_DATA   = '"+dtos(dDatDEF)+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " GROUP BY VCV_CPODEF , VCV_CCUSTO , VCV_CCTCTB , VCV_ITEMCT"
if lVCVCLVL
	cQuery += " , VCV_CLVL "
endif
oVCVBrwStruct:LoadData( cQuery , .t. )
dbSelectArea(oVCVBrwStruct:GetAlias())
dbGoTop()

DbSelectArea("VCU")

Return aClone(aCposDEF)


//Static Function OC2010031_QueryDescricaoMoeda()
//	Local cQAlias := "SQLDMOEDA"
//	Local cQuery := "SELECT DISTINCT VCU_MOEDA FROM " + RetSQLName("VCU") + " WHERE VCU_MOEDA > 0 AND D_E_L_E_T_  = ' '"
//	lOCAL nPos
//	Local aMoedasUtilizadas := {}
//
//	DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .f., .t.)
//	Do While !(cQAlias)->(EoF())
//		cAuxDescMoeda := GetNewPar("MV_MOEDA"+Str( (cQAlias)->VCU_MOEDA , 1 ),"")
//		if ! empty(cAuxDescMoeda)
//			aadd(aMoedasUtilizadas, {Str( (cQAlias)->VCU_MOEDA , 1 ),PadR(cAuxDescMoeda,tamSX3("VCU_DMOEDA")[1])})
//		endif
//		(cQAlias)->(dbSkip())
//	EndDo
//	(cQAlias)->(DBCloseArea())
//
//	
//	cQuery := ""
//	for nPos := 1 to len(aMoedasUtilizadas)
//		cQuery += " WHEN " + aMoedasUtilizadas[nPos][1] + " THEN '" + aMoedasUtilizadas[nPos][2] + "'"
//	next
//
//	if empty(cQuery)
//		cQuery := ",'REAL' AS VCU_DMOEDA "
//	else
//		cQuery := ", CASE VCU_MOEDA " + cQuery + " END AS VCU_DMOEDA "
//	endif
//
//Return cQuery