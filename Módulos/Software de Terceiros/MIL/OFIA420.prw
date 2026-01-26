#INCLUDE "TOTVS.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "OFIA420.CH"

Function OFIA420()

Local oOFIA420
Local cQuery  := ""
Local cAux1   := ""
Local cAux2   := ""
Local cQAlias := "SQLVBLSE4"
Local aSize   := FWGetDialogSize( oMainWnd )
Private oBrwVBK
Private oBrwVBL

oOFIA420 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],STR0001,,,,128,,,,,.t.) // Condições de Pagamento x Remuneração de Prazos

	oTPanVBK := TPanel():New(0,0,"",oOFIA420,NIL,.T.,.F.,NIL,NIL,120,(oOFIA420:nClientHeight/4)-10,.F.,.F.)
	oTPanVBK:Align := CONTROL_ALIGN_TOP

	oTPanVBL := TPanel():New(0,0,"",oOFIA420,NIL,.T.,.F.,NIL,NIL,120,(oOFIA420:nClientHeight/4)-10,.F.,.F.)
	oTPanVBL:Align := CONTROL_ALIGN_BOTTOM 

	oBrwVBK := FWMBrowse():New()
	oBrwVBK:SetAlias('VBK')
	oBrwVBK:SetOwner(oTPanVBK)
	oBrwVBK:ForceQuitButton()
	oBrwVBK:SetDescription(STR0001) // Condições de Pagamento x Remuneração de Prazos
	oBrwVBK:AddLegend(" VBK_ATIVO == '1' ", "GREEN" , STR0002) // Ativo
	oBrwVBK:AddLegend(" VBK_ATIVO == '0' ", "RED"   , STR0003) // Não Ativo
	//
	cAux1 := "@ EXISTS ("
	cAux1 += "SELECT VBL.R_E_C_N_O_"
	cAux1 += "  FROM "+RetSQLName("VBL")+" VBL"
	cAux1 += " WHERE VBL.VBL_FILIAL = VBK_FILIAL"
	cAux1 += "   AND VBL.VBL_CODVBK = VBK_CODIGO"
	cAux1 += "   AND VBL.VBL_CONPAG = '"
	//
	cAux2 := "'  AND VBL.D_E_L_E_T_ = ' ')"
	//
	cQuery := "SELECT DISTINCT VBL.VBL_CONPAG , SE4.E4_DESCRI "
	cQuery += "  FROM "+RetSQLName("VBL")+" VBL "
	cQuery += "  JOIN "+RetSQLName("SE4")+" SE4 "
	cQuery += "    ON SE4.E4_FILIAL  = '"+xFilial("SE4")+"'"
	cQuery += "   AND SE4.E4_CODIGO  = VBL.VBL_CONPAG"
	cQuery += "   AND SE4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VBL.VBL_FILIAL = '" + xFilial("VBL") + "'"
	cQuery += "   AND VBL.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VBL.VBL_CONPAG"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
	Do While !( cQAlias )->( Eof() )
		oBrwVBK:AddFilter(( cQAlias )->VBL_CONPAG+" - "+( cQAlias )->E4_DESCRI , ( cAux1 + ( cQAlias )->VBL_CONPAG + cAux2 ) ,.f.,.f.,)
		( cQAlias )->(dbSkip())
	Enddo
	( cQAlias )->( dbCloseArea() )
	//
	oBrwVBK:AddButton(STR0004,{ || OFA420041_ListaCondicaoPagamento()}) // Lista ativa dos % de Remuneração por Cond.Pagamento
	oBrwVBK:DisableDetails()
	oBrwVBK:Activate()

	oBrwVBL := FwMBrowse():New()
	oBrwVBL:SetDescription( STR0005 ) // Percentuais
	oBrwVBL:SetMenuDef( '' )
	oBrwVBL:SetAlias('VBL')
	oBrwVBL:SetOwner(oTPanVBL)
	oBrwVBL:AddLegend(" VBL_ATIVO == '1' ", "GREEN" , STR0002) // Ativo
	oBrwVBL:AddLegend(" VBL_ATIVO == '0' ", "RED"   , STR0003) // Não Ativo
	oBrwVBL:DisableLocate()
	oBrwVBL:DisableDetails()
	oBrwVBL:SetAmbiente(.F.)
	oBrwVBL:SetWalkthru(.F.)
	oBrwVBL:SetInsert(.f.)
	oBrwVBL:SetUseFilter()
	oBrwVBL:lOptionReport := .f.
	oBrwVBL:Activate()

	oRelac:= FWBrwRelation():New()
	oRelac:AddRelation( oBrwVBK , oBrwVBL , {{ "VBL_FILIAL", "VBK_FILIAL" }, { "VBL_CODVBK", "VBK_CODIGO" } })
	oRelac:Activate()

oOFIA420:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('OFIA420')

Return aRotina

Static Function ModelDef()

Local oModel
Local oStrVBK := FWFormStruct(1, "VBK")
Local oStrVBL := FWFormStruct(1, "VBL")

oStrVBL:SetProperty( 'VBL_CODVBK' , MODEL_FIELD_INIT , { || FWFldGet('VBK_CODIGO') } )

OFA420011_AddTrigger( oStrVBL , FwStruTrigger("VBL_CONPAG","VBL_DESPAG","SE4->E4_DESCRI",.T.,"SE4",1,"xFilial('SE4') + FWFldGet('VBL_CONPAG')") )

oModel := MPFormModel():New('OFIA420',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

oModel:AddFields('VBKMASTER',/*cOwner*/ , oStrVBK)
oModel:SetPrimaryKey( { "VBK_FILIAL", "VBK_CODIGO" } )

oModel:AddGrid("VBLDETAIL","VBKMASTER",oStrVBL)
oModel:SetRelation( 'VBLDETAIL', { { 'VBL_FILIAL', 'xFilial( "VBL" )' }, { 'VBL_CODVBK', 'VBK_CODIGO' } }, VBL->( IndexKey( 1 ) ) )

oModel:SetDescription(STR0001) // Condições de Pagamento x Remuneração de Prazos
oModel:GetModel('VBKMASTER'):SetDescription(STR0001) // Condições de Pagamento x Remuneração de Prazos
oModel:GetModel('VBLDETAIL'):SetDescription(STR0005) // Percentuais

//oModel:InstallEvent("OFIA420LOG", /*cOwner*/, MVCLOGEV():New("OFIA420") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("OFIA420EVDEF", /*cOwner*/, OFIA420EVDEF():New("OFIA420"))

Return oModel

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStrVBK:= FWFormStruct(2, "VBK")
Local oStrVBL:= FWFormStruct(2, "VBL", { |cCampo| !ALLTRIM(cCampo)+"|" $ "VBL_CODVBK|VBL_CODIGO|" })

oView := FWFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox( 'BOXVBK', 30)
oView:AddField('VIEW_VBK', oStrVBK, 'VBKMASTER')
oView:EnableTitleView('VIEW_VBK', STR0001) // Condições de Pagamento x Remuneração de Prazos
oView:SetOwnerView('VIEW_VBK','BOXVBK')

oView:CreateHorizontalBox( 'BOXVBL', 70)
oView:AddGrid("VIEW_VBL",oStrVBL, 'VBLDETAIL')
oView:EnableTitleView('VIEW_VBL', STR0005) // Percentuais
oView:SetOwnerView('VIEW_VBL','BOXVBL')

Return oView

/*/{Protheus.doc} OFA420011_AddTrigger
Adiciona Trigger para disparar no MVC

@author Andre Luis Almeida
@since 02/02/2022
@version undefined
@type static function
/*/
Static Function OFA420011_AddTrigger(oAuxStru, aAuxTrigger)
	oAuxStru:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
Return

/*/{Protheus.doc} OFA420021_LevantaRemuneracao
Retorna o % de Remuneração e Promoção pela Condição de Pagamento + Valor Minimo.

@author Andre Luis Almeida
@since 03/02/2022
@version undefined
@type function
/*/
Function OFA420021_LevantaRemuneracao( cCdPag , nVlInf , cCdCli , cLjCli )
Local aRet    := { 0 , "2" }
Local nRecVBL := OFA420031_Remuneracao( cCdPag , nVlInf ) // RecNo da Remuneração Cadastrada
If nRecVBL > 0
	VBL->(DbGoto(nRecVBL))
	aRet := { VBL->VBL_PERREM , VBL->VBL_PROMOC }
	If ExistBlock("OF420PCR")
		aRet := ExecBlock("OF420PCR",.f.,.f.,{ aRet , cCdPag , nVlInf , cCdCli , cLjCli , nRecVBL })
	EndIf
EndIf
Return aClone(aRet)

/*/{Protheus.doc} OFA420031_Remuneracao
Retorna o RecNo da Remuneração - pesquisa pela Condição de Pagamento + Valor Minimo.

@author Andre Luis Almeida
@since 09/02/2022
@version undefined
@type function
/*/
Function OFA420031_Remuneracao( cCdPag , nVlInf )
Local cQuery := ""
cQuery += "SELECT VBL.R_E_C_N_O_"
cQuery += "  FROM "+RetSQLName("VBL")+" VBL "
cQuery += "  JOIN "+RetSQLName("VBK")+" VBK "
cQuery += "    ON VBK.VBK_FILIAL = VBL.VBL_FILIAL"
cQuery += "   AND VBK.VBK_CODIGO = VBL.VBL_CODVBK"
cQuery += "   AND VBK.VBK_ATIVO  = '1'"
cQuery += "   AND VBK.D_E_L_E_T_ = ' '"
cQuery += " WHERE VBL.VBL_FILIAL = '" + xFilial("VBL") + "'"
cQuery += "   AND VBL.VBL_CONPAG = '" + cCdPag + "'"
cQuery += "   AND VBL.VBL_VLRMIN <= " + Alltrim(str(nVlInf))
cQuery += "   AND VBL.VBL_ATIVO  = '1'"
cQuery += "   AND VBL.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VBL.VBL_PERREM DESC"
Return FM_SQL(cQuery)

/*/{Protheus.doc} OFA420041_ListaCondicaoPagamento
Lista % por Condição de Pagamento

@author Andre Luis Almeida
@since 10/02/2022
@version undefined
@type function
/*/
Static Function OFA420041_ListaCondicaoPagamento()

Local oOF420Lista
Local aSize   := FWGetDialogSize( oMainWnd )
Local aCpoTab := {} // Array para campos da tabela temporária e campos da View
Local cQAlias := "SQLVBKVBL"
Local cQuery  := ""
Local nCntFor := 0
Local aPromoc := X3CBOXAVET("VBL_PROMOC","0")
Local aCond   := {}
// Criando tabela temporária
aadd(aCpoTab, {"ZZ1_CONPAG",GetSX3Cache("VBL_CONPAG","X3_TIPO"),GetSX3Cache("VBL_CONPAG","X3_TAMANHO"),0} ) // Codição de Pagamento
aadd(aCpoTab, {"ZZ1_DESCRI",GetSX3Cache("E4_DESCRI","X3_TIPO") ,GetSX3Cache("E4_DESCRI","X3_TAMANHO") ,0} ) // Descrição
aadd(aCpoTab, {"ZZ1_VLRMIN",GetSX3Cache("VBL_VLRMIN","X3_TIPO"),GetSX3Cache("VBL_VLRMIN","X3_TAMANHO"),GetSX3Cache("VBL_VLRMIN","X3_DECIMAL")} ) // Valor Minimo
aadd(aCpoTab, {"ZZ1_PERREM",GetSX3Cache("VBL_PERREM","X3_TIPO"),GetSX3Cache("VBL_PERREM","X3_TAMANHO"),GetSX3Cache("VBL_PERREM","X3_DECIMAL")} ) // % Remuneração
aadd(aCpoTab, {"ZZ1_PROMOC",GetSX3Cache("VBL_PROMOC","X3_TIPO"),40,0} ) // Promoção
oTmpTab := OFDMSTempTable():New()
oTmpTab:cAlias := "TEMPA"
oTmpTab:aVetCampos := aCpoTab
oTmpTab:AddIndex(, {"ZZ1_CONPAG","ZZ1_VLRMIN"} )
oTmpTab:CreateTable()
aCpoTab := {;
			{STR0006,"ZZ1_CONPAG", GetSX3Cache("VBL_CONPAG","X3_TIPO"),20,0, Alltrim(GetSX3Cache("VBL_CONPAG","X3_PICTURE")),0,.f.},;// Codição de Pagamento
			{STR0007,"ZZ1_DESCRI", GetSX3Cache("E4_DESCRI" ,"X3_TIPO"),30,0, Alltrim(GetSX3Cache("E4_DESCRI" ,"X3_PICTURE")),0,.f.},;// Descrição
			{STR0008,"ZZ1_VLRMIN", GetSX3Cache("VBL_VLRMIN","X3_TIPO"),15,2, Alltrim(GetSX3Cache("VBL_VLRMIN","X3_PICTURE")),GetSX3Cache("VBL_VLRMIN","X3_DECIMAL"),.f.},;// Valor Minimo
			{STR0009,"ZZ1_PERREM", GetSX3Cache("VBL_PERREM","X3_TIPO"), 8,2, Alltrim(GetSX3Cache("VBL_PERREM","X3_PICTURE")),GetSX3Cache("VBL_PERREM","X3_DECIMAL"),.f.},;// % Remuneração
			{STR0013,"ZZ1_PROMOC", GetSX3Cache("VBL_PROMOC","X3_TIPO"),40,0, Alltrim(GetSX3Cache("VBL_PROMOC","X3_PICTURE")),0,.f.} ;// Promoção
}
cQuery := "SELECT VBL.VBL_CONPAG , SE4.E4_DESCRI , VBL.VBL_VLRMIN , VBL.VBL_PROMOC , MAX(VBL.VBL_PERREM) AS PERREM"
cQuery += "  FROM "+RetSQLName("VBL")+" VBL "
cQuery += "  JOIN "+RetSQLName("VBK")+" VBK "
cQuery += "    ON VBK.VBK_FILIAL = VBL.VBL_FILIAL"
cQuery += "   AND VBK.VBK_CODIGO = VBL.VBL_CODVBK"
cQuery += "   AND VBK.VBK_ATIVO  = '1'"
cQuery += "   AND VBK.D_E_L_E_T_ = ' '"
cQuery += "  JOIN "+RetSQLName("SE4")+" SE4 "
cQuery += "    ON SE4.E4_FILIAL  = '"+xFilial("SE4")+"'"
cQuery += "   AND SE4.E4_CODIGO  = VBL.VBL_CONPAG"
cQuery += "   AND SE4.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VBL.VBL_FILIAL = '" + xFilial("VBL") + "'"
cQuery += "   AND VBL.VBL_ATIVO  = '1'"
cQuery += "   AND VBL.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY VBL.VBL_CONPAG , SE4.E4_DESCRI , VBL.VBL_VLRMIN , VBL.VBL_PROMOC "
cQuery += " ORDER BY VBL.VBL_CONPAG , SE4.E4_DESCRI , VBL.VBL_VLRMIN , VBL.VBL_PROMOC "
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
Do While !( cQAlias )->( Eof() )
	// Adicionado endereço
	RecLock("TEMPA",.T.)
		TEMPA->ZZ1_CONPAG := ( cQAlias )->VBL_CONPAG
		TEMPA->ZZ1_DESCRI := ( cQAlias )->E4_DESCRI
		TEMPA->ZZ1_VLRMIN := ( cQAlias )->VBL_VLRMIN
		TEMPA->ZZ1_PERREM := ( cQAlias )->PERREM
		TEMPA->ZZ1_PROMOC := X3CBOXDESC("VBL_PROMOC",( cQAlias )->VBL_PROMOC)
	TEMPA->(MsUnlock())
	If AScan( aCond , { |x| x[1] == ( cQAlias )->VBL_CONPAG } ) <= 0
		aAdd( aCond , { ( cQAlias )->VBL_CONPAG , ( cQAlias )->E4_DESCRI })
	EndIf
	( cQAlias )->(dbSkip())
Enddo
( cQAlias )->( dbCloseArea() )
//
oOF420Lista := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],STR0004,,,,128,,,,,.t.) // Lista ativa dos % de Remuneração por Cond.Pagamento
//
oBrwCond := FWMBrowse():New( )
oBrwCond:SetTemporary(.T.) 
oBrwCond:DisableDetails()
oBrwCond:ForceQuitButton()
oBrwCond:SetAlias("TEMPA")
oBrwCond:SetFields(aCpoTab)
For nCntFor := 1 to len(aCond)
	oBrwCond:AddFilter(aCond[nCntFor,1]+" - "+aCond[nCntFor,2],"@ ZZ1_CONPAG = '"+aCond[nCntFor,1]+"'",.f.,.f.,) // Filtro por Condicao de Pagamento
Next
oBrwCond:AddFilter(STR0014,"@ ZZ1_VLRMIN > 0 ",.f.,.f.,) // Com Valor Minimo
oBrwCond:AddFilter(STR0015,"@ ZZ1_VLRMIN = 0 ",.f.,.f.,) // Sem Valor Minimo
For nCntFor := 1 to len(aPromoc)
	oBrwCond:AddFilter(STR0013+": "+Alltrim(substr(aPromoc[nCntFor],3)),"@ ZZ1_PROMOC = '"+Alltrim(substr(aPromoc[nCntFor],3))+"'",.f.,.f.,) // Promoção
Next
oBrwCond:SetMenuDef("")
oBrwCond:SetDescription(STR0004) // Lista ativa dos % de Remuneração por Cond.Pagamento
oBrwCond:AddButton(STR0010,{ || oOF420Lista:End() }) // Fechar
oBrwCond:Activate(oOF420Lista)
//
oOF420Lista:Activate()
//
oTmpTab:CloseTable()
//
Return

/*/{Protheus.doc} OFA420051_ClienteConsideraRemuneracao
Lista % por Condição de Pagamento

@author Andre Luis Almeida
@since 10/02/2022
@version undefined
@type function
/*/
Function OFA420051_ClienteConsideraRemuneracao(cCodCli,cLojCli)
Local lRet   := .t.
Local cNICli := GetNewPar("MV_MIL0173","") // Niveis de Importancia de Clientes que devem desprezar a Remuneração
If !Empty(cNICli)
	VCF->(DbSetOrder(1))
	If VCF->(DbSeek(xFilial("VCF")+cCodCli+cLojCli))
		If !Empty(VCF->VCF_NIVIMP) .and. VCF->VCF_NIVIMP $ cNICli
			lRet := .f. // Desconsiderar clientes que estão com o Nivel de Importancia relacionado no parametro MV_MIL0173
		EndIf
	EndIf
EndIf
Return lRet