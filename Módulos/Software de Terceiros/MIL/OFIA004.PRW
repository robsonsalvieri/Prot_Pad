#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA004.CH"

/*/{Protheus.doc} OFIA004()
Cadastro de Locações Auxiliares do DMS ( LOCALI2 )

@author Andre Luis Almeida
@since 13/08/2025
@version 1.0
@return NIL
/*/
Function OFIA004()
Local oBrwSB1
Local cFiltSB1 := ""
Local cFiltVBU := ""
//
If cPaisLoc <> "ARG"
	FMX_HELP("OFIA004",STR0008) // Funcionalidade disponível apenas para Argentina
    Return
EndIf
//
cFiltSB1 := "SELECT SBM.BM_GRUPO "
cFiltSB1 += "  FROM "+ RetSqlName("SBM") + " SBM "
cFiltSB1 += " WHERE SBM.BM_FILIAL = '"+xFilial("SBM")+"'"
cFiltSB1 += "   AND SBM.BM_GRUPO = B1_GRUPO "
cFiltSB1 += "   AND SBM.BM_TIPGRU NOT IN ('4','7') " // Não considerar 4-SERVICOS e 7-VEICULOS
cFiltSB1 += "   AND SBM.D_E_L_E_T_ = ' '"
//
cFiltVBU := "SELECT VBU.VBU_CODIGO "
cFiltVBU += "  FROM "+ RetSqlName("VBU") + " VBU "
cFiltVBU += " WHERE VBU.VBU_FILIAL = '"+xFilial("VBU")+"'"
cFiltVBU += "   AND VBU.VBU_CODSB1 = B1_COD "
cFiltVBU += "   AND VBU.D_E_L_E_T_ = ' '"
//
oBrwSB1 := FWMBrowse():New()
oBrwSB1:SetAlias("SB1")
oBrwSB1:SetMenuDef("OFIA004")
oBrwSB1:SetDescription( STR0001 ) // Cadastro de Locações Auxiliares do DMS
oBrwSB1:SetFilterDefault("@ EXISTS ("+cFiltSB1+")")
oBrwSB1:AddFilter(STR0002,"@ EXISTS ("+cFiltVBU+")",.f.,.f.) // Produtos com Locações Auxiliares do DMS cadastradas
oBrwSB1:AddFilter(STR0003,"@ NOT EXISTS ("+cFiltVBU+")",.f.,.f.) // Produtos sem Locações Auxiliares do DMS cadastradas
oBrwSB1:DisableLocate()
oBrwSB1:DisableDetails()
oBrwSB1:SetAmbiente(.F.)
oBrwSB1:SetWalkthru(.F.)
oBrwSB1:SetUseFilter()
oBrwSB1:lOptionReport := .f.
oBrwSB1:Activate()
//
Return

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 02/10/2024
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.OFIA004' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.OFIA004' OPERATION 4 ACCESS 0 // Manutenção
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 02/10/2024
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrSB1 := FWFormStruct( 1, "SB1")
Local oStrVBU := FWFormStruct( 1, "VBU")
//
oStrSB1:AddField(STR0006,STR0006,"B5_LOCALI2", "C", GetSX3Cache("B5_LOCALI2","X3_TAMANHO") , 0, { || .T.}, { || .F. },,, { || }, .F.,,,) // Locação Principal
oStrVBU:SetProperty("VBU_CODSB1", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, SB1->B1_COD )) // Inicializador Padrão
//
oModel := MPFormModel():New("OFIA004", /* bPre */ , /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields( 'SB1MASTER', /*cOwner*/, oStrSB1, /* <bPre> */ , /* <bPost> */ , /* <bLoad>  { |oModel| loadCab(oModel) }*/ )
oModel:AddGrid( 'VBUDETAIL', 'SB1MASTER', oStrVBU)
oModel:GetModel('SB1MASTER'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR
oModel:SetDescription( STR0001 ) // Cadastro de Locações Auxiliares do DMS
oModel:GetModel("VBUDETAIL"):SetUniqueLine({"VBU_ALMOXA","VBU_LOCAUX"})
oModel:GetModel('VBUDETAIL'):SetOptional( .T. ) // Deixar passar em branco
oModel:SetRelation('VBUDETAIL', { { 'VBU_FILIAL' , 'xFilial("VBU")' } , { 'VBU_CODSB1' , 'B1_COD' } }, VBU->( IndexKey(2) ) )
oModel:SetPrimaryKey( { "VBU_FILIAL","VBU_CODIGO" } )
oModel:InstallEvent("OFIA004EVDEF", /*cOwner*/, OFIA004EVDEF():New() ) // Eventos do OFIA004
//
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 02/10/2024
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrSB1 := FWFormStruct(2, "SB1", { |cCampo|  ALLTRIM(cCampo)+"/" $ "B1_GRUPO/B1_CODITE/B1_DESC/" } )
Local oStrVBU := FWFormStruct(2, "VBU", { |cCampo| !ALLTRIM(cCampo)+"/" $ "VBU_FILIAL/VBU_CODSB1/VBU_CODIGO/" } )
Local aStrFields := oStrSB1:GetFields()
Local aOrdFields := {}
Local nForFields := 0
Local nPosFields := 0
Local cField     := ""
aAdd(aOrdFields,{"B1_GRUPO" ,"01"})
aAdd(aOrdFields,{"B1_CODITE","02"})
aAdd(aOrdFields,{"B1_DESC"  ,"03"})
For nForFields := 1 to Len(aStrFields)
	cField := aStrFields[nForFields,MVC_VIEW_IDFIELD]
    nPosFields := aScan( aOrdFields , { |x| x[1] == cField })
    If nPosFields > 0
        oStrSB1:SetProperty( cField , MVC_VIEW_ORDEM , aOrdFields[nPosFields,2] )
    EndIf
Next
oStrSB1:AddField('B5_LOCALI2','04',STR0006,'',,'Get' ,'@!',,,.F.,,,,,,.T.,, ) // Locação Principal
oStrSB1:SetProperty( "*" ,MVC_VIEW_CANCHANGE, .f. )
oStrSB1:SetNoFolder()
//
oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:CreateHorizontalBox( 'TELASB1' , 35 )
oView:CreateHorizontalBox( 'TELAVBU' , 65 )
oView:AddField('VIEW_SB1', oStrSB1, 'SB1MASTER' )
oView:AddGrid( 'VIEW_VBU', oStrVBU, 'VBUDETAIL' )
oView:SetOwnerView( "VIEW_SB1" , "TELASB1" )
oView:SetOwnerView( "VIEW_VBU" , "TELAVBU" )
//
Return oView

/*/{Protheus.doc} OA0040011_Locacoes_Auxiliares
Retorna Vetor com as Locações Auxiliares do DMS referente ao Produto

@author Andre Luis Almeida
@since 15/08/2025
/*/
Function OA0040011_Locacoes_Auxiliares(cCodSB1,cAlmox)
Local cQuery    := ""
Local cSQLAlias := "SQLVBU"
Local aRetVBU   := {}
Default cAlmox  := ""
cQuery := "SELECT VBU_ALMOXA , VBU_LOCAUX "
cQuery += "  FROM "+RetSQLName("VBU")
cQuery += " WHERE VBU_FILIAL = '"+xFilial("VBU")+"'"
cQuery += "   AND VBU_CODSB1 = '"+cCodSB1+"'"
If !Empty(cAlmox)
    cQuery += "   AND VBU_ALMOXA = '"+cAlmox+"'"
EndIf
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VBU_SEQUEN"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())
    aAdd(aRetVBU,{ (cSQLAlias)->( VBU_ALMOXA ) , (cSQLAlias)->( VBU_LOCAUX ) })
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
DbSelectArea("VBU")
Return aClone(aRetVBU)

/*/{Protheus.doc} OA0040021_Visualizar_Locacoes_Auxiliares
Chama o VISUALIZAR do MVC das Locações Auxiliares do DMS referente ao Produto

@author Andre Luis Almeida
@since 15/08/2025
/*/
Function OA0040021_Visualizar_Locacoes_Auxiliares(cCodSB1)
If OA0040031_Existe_Locacoes_Auxiliares(cCodSB1)
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+cCodSB1)
	oView := FWViewExec():New()
	oView:setSource("OFIA004")
	oView:setModal(.F.)
	oView:setTitle(STR0004) // Visualizar
	oView:setOperation( MODEL_OPERATION_VIEW ) // View
	oView:openView(.F.)
	oView:DeActivate()
Else
	FMX_HELP("OA0040021",STR0007) // Produto sem Locações Auxiliares cadastradas.
EndIf
Return

/*/{Protheus.doc} OA0040031_Existe_Locacoes_Auxiliares
Verifica se existe Locações Auxiliares do DMS cadastradas ao Produto

@author Andre Luis Almeida
@since 18/08/2025
/*/
Function OA0040031_Existe_Locacoes_Auxiliares(cCodSB1)
Local cQuery := ""
cQuery := "SELECT COUNT(*) "
cQuery += "  FROM "+RetSQLName("VBU")
cQuery += " WHERE VBU_FILIAL = '"+xFilial("VBU")+"'"
cQuery += "   AND VBU_CODSB1 = '"+cCodSB1+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
Return( FM_SQL(cQuery) > 0 )