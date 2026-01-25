#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIC200.CH"

/*/{Protheus.doc} OFIC200()
Consulta Detalhada por Campo DEF

@author Andre Luis Almeida
@since 05/03/2021
@version 1.0
@return NIL
/*/
Function OFIC200()
Local cQuery      := ""
Local cQAlias     := "SQLVD7"
Local aVD7        := {}
Local nCntFor     := 0
Private aRotina   := MenuDef()
Private cCadastro := STR0001 // Consulta Detalhada por Campo DEF
//
// Validacao de Licencas DMS
//
If !OFValLicenca():ValidaLicencaDMS()
	Return
EndIf
//
// Monta Browse do VDB (Histórico DEF) com Filtros por VDB_CODDEF partindo do VD7 (Cabeçalho do DEF)
//
cQuery := "SELECT VD7_CODDEF, VD7_DESDEF "
cQuery += "  FROM "+ RetSQLName("VD7")
cQuery += " WHERE VD7_FILIAL='"+ xFilial("VD7")+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .f., .t.)
Do While !(cQAlias)->(EoF())
	AAdd(aVD7, { (cQAlias)->VD7_CODDEF , (cQAlias)->VD7_DESDEF })
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(DbCloseArea())
//
DbSelectArea("VDB")
oBrwVDB := FWMBrowse():New()
oBrwVDB:SetAlias("VDB") // Browse do VDB (Histórico DEF)
oBrwVDB:SetDescription(STR0001) // Consulta Detalhada por Campo DEF
For nCntFor := 1 to len(aVD7)
	oBrwVDB:AddFilter( Alltrim(aVD7[nCntFor,2])+" ( "+aVD7[nCntFor,1]+" )" , "VDB_CODDEF=='"+aVD7[nCntFor,1]+"'" ,.f.,.f.,) // Filtro por VDB_CODDEF com VD7
Next
oBrwVDB:DisableDetails()
oBrwVDB:ForceQuitButton(.T.)
oBrwVDB:Activate()
//
Return NIL

/*/{Protheus.doc} MenuDef
MenuDef aRotina

@author Andre Luis Almeida
@since 05/03/2021
@version 1.0
@return NIL
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0002,"AxPesqui"           , 0 , 1},;	// Pesquisar
					{ STR0003,"OC2000011_Consultar", 0 , 2},;	// Consultar
					{ STR0007,"OFIC201"            , 0 , 2}}	// Consulta Consolidada
Return aRotina

/*/{Protheus.doc} OC2000011_Consultar
Chamada pelo MENU - Consulta Detalhada por Campo DEF

@author Andre Luis Almeida
@since 05/03/2021
@version 1.0
@return NIL
/*/
Function OC2000011_Consultar(cAlias,nReg,nOpc)
//
OC2000021_DetalharDEF( VDB->VDB_FILIAL , VDB->VDB_CODDEF , VDB->VDB_DATA ) // Montagem da Tela com os Browsers
//
Return .t.

/*/{Protheus.doc} OC2000021_DetalharDEF
Browsers da Consulta Detalhada por Campo DEF

@author Andre Luis Almeida
@since 05/03/2021
@version 1.0
@return NIL
/*/
Static Function OC2000021_DetalharDEF( cFilDEF , cCodDEF , dDatDEF )
Local cQAlias   := "SQLVCU"
Local cQuery    := ""
Local nCntFor   := 0
Local aCposDEF  := {}
Local aSizeAut  := MsAdvSize(.f.)
Local cTitTela  := STR0001+" - "+Alltrim(RetTitle("VCU_FILIAL"))+": "+cFilDEF // Consulta Detalhada por Campo DEF
Private aRotina := {}
Default cFilDEF := VDB->VDB_FILIAL
Default cCodDEF := VDB->VDB_CODDEF
Default dDatDEF := VDB->VDB_DATA

cQuery := "SELECT DISTINCT VCU_CPODEF "
cQuery += "  FROM "+RetSQLName("VCU")
cQuery += " WHERE VCU_FILIAL = '"+cFilDEF+"'"
cQuery += "   AND VCU_CODDEF = '"+cCodDEF+"'"
cQuery += "   AND VCU_DATA   = '"+dtos(dDatDEF)+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .f., .t.)
Do While !(cQAlias)->(EoF())
	aAdd(aCposDEF,(cQAlias)->( VCU_CPODEF ) ) // Vetor a ser utilizado no Filtro do Browse
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(DbCloseArea())
DbSelectArea("VCU")

oOFIC200 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cTitTela,,,,128,,,,,.t.)

// Paineis na Tela
oTPanVCU := TPanel():New(0,0,"",oOFIC200,NIL,.T.,.F.,NIL,NIL,100,(oOFIC200:nClientHeight/4)-10,.F.,.F.)
oTPanVCU:Align := CONTROL_ALIGN_TOP
oTPanVCV := TPanel():New(0,0,"",oOFIC200,NIL,.T.,.F.,NIL,NIL,100,(oOFIC200:nClientHeight/4)-10,.F.,.F.)
oTPanVCV:Align := CONTROL_ALIGN_BOTTOM 

// Browse VCU - Histórico DEF por Campo DEF
oBrwVCU := FWMBrowse():New()
oBrwVCU:SetAlias("VCU")
oBrwVCU:SetOwner(oTPanVCU)
oBrwVCU:SetDescription(cTitTela)
oBrwVCU:SetMenuDef('')
If !Empty( cFilDEF + cCodDEF ) // Monta Filtro pelo Codigo DEF
	oBrwVCU:AddFilter( STR0004 , " VCU_FILIAL=='"+cFilDEF+"' .and. VCU_CODDEF=='"+cCodDEF+"' .and. DTOS(VCU_DATA)=='"+dtos(dDatDEF)+"'" ,.t.,.t.,,,, "OFIC200" ) // Filtro Padrão
EndIf
For nCntFor := 1 to len(aCposDEF) // Monta Filtro pelo Campo DEF
	oBrwVCU:AddFilter( aCposDEF[nCntFor] , " VCU_CPODEF=='"+aCposDEF[nCntFor]+"'",.f.,.f.,,,, aCposDEF[nCntFor] )
Next
oBrwVCU:DisableDetails()
oBrwVCU:AddButton(STR0016,{ || OFIR200( cFilDEF , cCodDEF , dDatDEF ) } ) // Imprimir Lista Analítica
oBrwVCU:ForceQuitButton(.T.)
oBrwVCU:Activate()
oBrwVCU:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

// Browse VCV - Histórico DEF Analitico
oBrwVCV := FWMBrowse():New()
oBrwVCV:SetAlias("VCV")
oBrwVCV:SetOwner(oTPanVCV)
oBrwVCV:SetDescription(STR0005) // Analitico por Centro de Custo, Conta e Item Contabil
oBrwVCV:SetMenuDef('')
oBrwVCV:DisableDetails()
oBrwVCV:ForceQuitButton(.T.)
oBrwVCV:Activate()
oBrwVCV:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

// Relacionamento entre os Browses VCU e VCV
oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrwVCU , oBrwVCV , { { "VCV_FILIAL" , "VCU_FILIAL" } , { "VCV_CODDEF" , "VCU_CODDEF" } , { "VCV_CPODEF" , "VCU_CPODEF" } , { "DTOS(VCV_DATA)" , "DTOS(VCU_DATA)" } } )
oRelac:Activate()

oOFIC200:Activate()

Return NIL