#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIC231.CH"
/*/{Protheus.doc} OFIC231()
Consulta Itens dos Volumes da Entrada - com Endereço DMS (LOCALI2)

@author Andre Luis Almeida
@since 11/05/2024
@version 1.0
@return NIL
/*/
Function OFIC231()
Local oTmpTable
Private cCadastro := STR0001 // Consulta Itens dos Volumes da Entrada - Endereço DMS
Private aRotina   := {} // Necessario deixar em branco para poder chamar a Consulta de outras rotinas
Private cFiltVol  := space(GetSX3Cache("VCX_VOLUME","X3_TAMANHO")) // Filtro - Cod.Volume
Private cFiltFor  := space(GetSX3Cache("VCX_FORNEC","X3_TAMANHO")) // Filtro - Fornecedor
Private cFiltLoj  := space(GetSX3Cache("VCX_LOJA"  ,"X3_TAMANHO")) // Filtro - Loja do Fornecedor
//
oTmpTable := OFDMSTempTable():New()
oTmpTable:cAlias := "TEMP"
oTmpTable:aVetCampos := OC2310031_Campos( 1 ) // 1 = Campos Tabela Temporaria
oTmpTable:AddIndex(, {"XXX_FILIAL","XXX_VOLUME","XXX_FORNEC","XXX_LOJA"} )
oTmpTable:CreateTable()
OC2310041_CarregaTabelaTemporaria() // Carregar a Tabela Temporaria para o Browse
//
// Browse Volumes Entrada
oBrwVCX := FWMBrowse():New( )
oBrwVCX:SetTemporary(.T.) 
oBrwVCX:SetMenuDef("")
oBrwVCX:DisableDetails()
oBrwVCX:DisableConfig()
oBrwVCX:SetWalkThru(.F.)
oBrwVCX:SetAmbiente(.F.)
oBrwVCX:SetUseFilter(.f.)
oBrwVCX:SetFixedBrowse(.T.)
oBrwVCX:SetAlias("TEMP")
oBrwVCX:SetFields( OC2310031_Campos( 2 ) ) // 2 = Campos do Browse
oBrwVCX:AddButton(STR0002,{ || OC2310021_Visualizar( 1 , STR0002 , TEMP->XXX_VOLUME ) } ) // Visualizar Todos os Itens
oBrwVCX:AddButton(STR0003,{ || OC2310021_Visualizar( 2 , STR0003 , TEMP->XXX_VOLUME ) } ) // Visualizar Itens com Endereço DMS
oBrwVCX:AddButton(STR0004,{ || OC2310021_Visualizar( 3 , STR0004 , TEMP->XXX_VOLUME ) } ) // Visualizar Itens sem Endereço DMS
oBrwVCX:AddButton(STR0006,{ || OC2310051_Filtro() } ) // Filtro
oBrwVCX:ForceQuitButton()
oBrwVCX:SetDescription(cCadastro)
oBrwVCX:Activate()
//
oTmpTable:CloseTable()
//
Return

/*/{Protheus.doc} OC2310021_Visualizar
Lista Itens da NF Entrada selecionada

@author Andre Luis Almeida
@since 09/05/2024
@version 1.0
@return NIL
/*/
Static Function OC2310021_Visualizar( nTp , cTitulo , cVolume )
Local cQuery  := ""
Local cAlias  := "SQLVCX"
Local cLocPad := ""
Local cLocal2 := ""
Local aIntCab := {}
Local aIntIte := {}
Local lOk     := .f.
//
aAdd(aIntCab,{RetTitle("B1_GRUPO")  ,"C", 25,"@!"}) // Grupo
aAdd(aIntCab,{RetTitle("B1_CODITE") ,"C", 55,"@!"}) // Codigo do Item
aAdd(aIntCab,{RetTitle("B1_DESC")   ,"C",200,"@!"}) // Descrição
aAdd(aIntCab,{RetTitle("B1_LOCPAD") ,"C", 55,"@!"}) // Local Padrão
aAdd(aIntCab,{RetTitle("B5_LOCALI2"),"C", 55,"@!"}) // Endereço DMS
//
cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1"
cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
cQuery += "  JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=VCX.VCX_COD AND SB1.D_E_L_E_T_=' ' "
cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "'"
cQuery += "   AND VCX.VCX_VOLUME = '" + cVolume        + "'"
cQuery += "   AND VCX.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY SB1.B1_GRUPO , SB1.B1_CODITE "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias, .F., .T. )
while !(cAlias)->(eof())
	SB1->(DbGoto( (cAlias)->(RECSB1) ))
	SB5->(DbSetOrder(1))
	SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
	cLocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	cLocal2 := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
	lOk     :=  (nTp == 1) // Todos os Itens
	If nTp == 2 .and. !Empty(cLocal2) // Com Endereço
		lOk := .t.
	ElseIf nTp == 3 .and. Empty(cLocal2) // Sem Endereço
		lOk := .t.
	EndIf
	If lOk
		aAdd(aIntIte,{	SB1->B1_GRUPO ,;
						SB1->B1_CODITE ,; 
						SB1->B1_DESC ,;
						cLocPad ,;
						cLocal2 })
	EndIf
	(cAlias)->(DBSkip())
enddo
//
(cAlias)->(DBCloseArea())
DbSelectArea("VCX")
//
If len(aIntIte) == 0
	FMX_HELP("OFIC231",STR0005+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cTitulo) // Não existem dados para esta Consulta.
Else
	FGX_VISINT( cTitulo , Alltrim(RetTitle("VCX_VOLUME"))+": "+cVolume , aIntCab , aIntIte , .f. )
EndIf
//
Return

/*/{Protheus.doc} OC2310031_Campos
Retorna os campos: 1 = Tabela Temporaria ou 2 = Browse

@author Andre Luis Almeida
@since 11/05/2024
@version 1.0
@return NIL
/*/
Static Function OC2310031_Campos( nTp )
Local aCampos := {}
If nTp == 1 // Campos Tabela Temporaria
	aadd(aCampos, {"XXX_FILIAL",GetSX3Cache("VCX_FILIAL","X3_TIPO"),GetSX3Cache("VCX_FILIAL","X3_TAMANHO")	,0} ) // VCX_FILIAL
	aadd(aCampos, {"XXX_VOLUME",GetSX3Cache("VCX_VOLUME","X3_TIPO"),GetSX3Cache("VCX_VOLUME","X3_TAMANHO")	,0} ) // VCX_VOLUME
	aadd(aCampos, {"XXX_FORNEC",GetSX3Cache("VCX_FORNEC","X3_TIPO"),GetSX3Cache("VCX_FORNEC","X3_TAMANHO")	,0} ) // VCX_FORNEC
	aadd(aCampos, {"XXX_LOJA"  ,GetSX3Cache("VCX_LOJA"  ,"X3_TIPO"),GetSX3Cache("VCX_LOJA"  ,"X3_TAMANHO")	,0} ) // VCX_LOJA
	aadd(aCampos, {"XXX_NOME"  ,GetSX3Cache("A2_NOME"   ,"X3_TIPO"),GetSX3Cache("A2_NOME"   ,"X3_TAMANHO")	,0} ) // A2_NOME
Else // Campos do Browse
	aadd(aCampos,{RetTitle("VCX_FILIAL"),"XXX_FILIAL", GetSX3Cache("VCX_FILIAL","X3_TIPO"), 20,0, Alltrim(GetSX3Cache("VCX_FILIAL","X3_PICTURE")),GetSX3Cache("VCX_FILIAL","X3_DECIMAL"),.f.})// VCX_FILIAL
	aadd(aCampos,{RetTitle("VCX_VOLUME"),"XXX_VOLUME", GetSX3Cache("VCX_VOLUME","X3_TIPO"), 30,0, Alltrim(GetSX3Cache("VCX_VOLUME","X3_PICTURE")),GetSX3Cache("VCX_VOLUME","X3_DECIMAL"),.f.})// VCX_VOLUME
	aadd(aCampos,{RetTitle("VCX_FORNEC"),"XXX_FORNEC", GetSX3Cache("VCX_FORNEC","X3_TIPO"), 20,0, Alltrim(GetSX3Cache("VCX_FORNEC","X3_PICTURE")),GetSX3Cache("VCX_FORNEC","X3_DECIMAL"),.f.})// VCX_FORNEC
	aadd(aCampos,{RetTitle("VCX_LOJA")  ,"XXX_LOJA"  , GetSX3Cache("VCX_LOJA"  ,"X3_TIPO"), 10,0, Alltrim(GetSX3Cache("VCX_LOJA"  ,"X3_PICTURE")),GetSX3Cache("VCX_LOJA"  ,"X3_DECIMAL"),.f.})// VCX_LOJA
	aadd(aCampos,{RetTitle("A2_NOME")   ,"XXX_NOME"  , GetSX3Cache("A2_NOME"   ,"X3_TIPO"),200,0, Alltrim(GetSX3Cache("A2_NOME"   ,"X3_PICTURE")),GetSX3Cache("A2_NOME"   ,"X3_DECIMAL"),.f.})// A2_NOME
EndIf
Return aCampos

/*/{Protheus.doc} OC2310041_CarregaTabelaTemporaria
Carregar Tabela Temporaria para montar o Browse principal do VCX

@author Andre Luis Almeida
@since 11/05/2024
@version 1.0
@return NIL
/*/
Static Function OC2310041_CarregaTabelaTemporaria()
Local cQuery    := ""
Local cAliasVCX := "TEMPVCX"
cQuery := "SELECT DISTINCT VCX.VCX_FILIAL ,"
cQuery += "                VCX.VCX_VOLUME ,"
cQuery += "                VCX.VCX_FORNEC ,"
cQuery += "                VCX.VCX_LOJA   ,"
cQuery += "                SA2.A2_NOME "
cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
cQuery += "  JOIN " + RetSqlName("SA2") + " SA2 "
cQuery += "    ON SA2.A2_FILIAL='"+xFilial("SA2")+"'"
cQuery += "   AND SA2.A2_COD=VCX.VCX_FORNEC"
cQuery += "   AND SA2.A2_LOJA=VCX.VCX_LOJA"
cQuery += "   AND SA2.D_E_L_E_T_=' '"
cQuery += " WHERE VCX.VCX_FILIAL='"+xFilial("VCX")+"'"
cQuery += "   AND VCX.D_E_L_E_T_=' '"
cQuery += " ORDER BY VCX.VCX_FILIAL ,"
cQuery += "          VCX.VCX_VOLUME ,"
cQuery += "          VCX.VCX_FORNEC ,"
cQuery += "          VCX.VCX_LOJA"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVCX, .T., .T. )
Do While !( cAliasVCX )->( Eof() )
	// Cria Registros Temportarios
	RecLock("TEMP",.T.)
		TEMP->XXX_FILIAL := ( cAliasVCX )->VCX_FILIAL
		TEMP->XXX_VOLUME := ( cAliasVCX )->VCX_VOLUME
		TEMP->XXX_FORNEC := ( cAliasVCX )->VCX_FORNEC
		TEMP->XXX_LOJA   := ( cAliasVCX )->VCX_LOJA
		TEMP->XXX_NOME   := ( cAliasVCX )->A2_NOME
	TEMP->(MsUnlock())
	( cAliasVCX )->(DbSkip())
Enddo
( cAliasVCX )->( dbCloseArea() )
DbSelectArea("VCX")
Return

/*/{Protheus.doc} OC2310051_Filtro
Filtro do Browse

@author Andre Luis Almeida
@since 11/05/2024
@version 1.0
@return NIL
/*/
Static Function OC2310051_Filtro()
Local cFiltro   := ""
Local aParambox := {}
Local aRetParam := {}
aAdd(aParamBox,{1,RetTitle("VCX_VOLUME"),cFiltVol,"@!","",""   ,"",100,.F.}) // Volume
aAdd(aParamBox,{1,RetTitle("VCX_FORNEC"),cFiltFor,"@!","","FOR","", 50,.F.}) // Fornecedor
aAdd(aParamBox,{1,RetTitle("VCX_LOJA")  ,cFiltLoj,"@!","",""   ,"", 25,.F.}) // Loja
If ParamBox(aParamBox,STR0006,@aRetParam,,,,,,,,.f.) // Filtro
	oBrwVCX:DeleteFilter("filtro_usr")
	oBrwVCX:Refresh()
	cFiltVol := aRetParam[1]
	cFiltFor := aRetParam[2]
	cFiltLoj := aRetParam[3]
	If !Empty(cFiltVol)
		cFiltro += "XXX_VOLUME='"+cFiltVol+"'"
	EndIf
	If !Empty(cFiltFor)
		cFiltro += IIf(!Empty(cFiltro)," AND ","")
		cFiltro += "XXX_FORNEC='"+cFiltFor+"'"
	EndIf
	If !Empty(cFiltLoj)
		cFiltro += IIf(!Empty(cFiltro)," AND ","")
		cFiltro += "XXX_LOJA='"+cFiltLoj+"'"
	EndIf
	If !Empty(cFiltro)
		oBrwVCX:AddFilter( STR0006 ,"@ "+cFiltro,.f.,.t.,,,,"filtro_usr") // Filtro
		oBrwVCX:ExecuteFilter( .t. )
	EndIf
EndIf
Return