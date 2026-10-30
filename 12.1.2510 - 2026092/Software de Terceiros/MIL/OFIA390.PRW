#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA390.CH"

/*/{Protheus.doc} OFIA390
	Cadastro de Grupos de Serviço Especializado

	@author Andre Luis Almeida
	@since 17/08/2022
/*/
Function OFIA390()

Private cCadastro := STR0001 // Cadastro de Grupos de Serviço Especializado

oBrwVPW := FWMBrowse():New()
oBrwVPW:SetAlias('VPW')
oBrwVPW:SetDescription(cCadastro)
oBrwVPW:AddButton(STR0002,{|| OA3900021_EstoqueTotal(VPW->VPW_CODGRU,VPW->VPW_DESGRU) },,2,2) // Totais de Estoque do Grupo de Serviço Especializado
oBrwVPW:AddButton(STR0003,{|| OFIA450(VPW->VPW_CODGRU,"") },,2,2) // Visualiza Serviços Especializados do Grupo posicionado
oBrwVPW:DisableDetails()
oBrwVPW:SetAmbiente(.F.)
oBrwVPW:SetWalkthru(.F.)
oBrwVPW:SetUseFilter()
oBrwVPW:ForceQuitButton()
oBrwVPW:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}
	aRotina := FWMVCMenu('OFIA390')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVPW := FWFormStruct(1, "VPW")

	oModel := MPFormModel():New('OFIA390',,,,)
	oModel:AddFields('VPWMASTER',/*cOwner*/ , oStrVPW)
	oModel:SetDescription(STR0001) // Cadastro de Grupos de Serviço Especializado
	oModel:GetModel('VPWMASTER'):SetDescription(STR0001) // Cadastro de Grupos de Serviço Especializado
//	oModel:InstallEvent("OFIA390LOG", /*cOwner*/, MVCLOGEV():New("OFIA390") ) // CONSOLE.LOG para verificar as chamadas dos eventos
	oModel:InstallEvent("OFIA390EVDEF", /*cOwner*/, OFIA390EVDEF():New("OFIA390"))

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVPW:= FWFormStruct(2, "VPW")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'BOXVPW', 100)
	oView:AddField('VIEW_VPW', oStrVPW, 'VPWMASTER')
	oView:EnableTitleView('VIEW_VPW', STR0001) // Cadastro de Grupos de Serviço Especializado
	oView:SetOwnerView('VIEW_VPW','BOXVPW')

Return oView

/*/{Protheus.doc} OA3900011_GrupoUsado()
Verifica se foi utilizado o Grupo no Servico Especializado

@author Andre Luis Almeida
@since 19/08/2022
/*/
Function OA3900011_GrupoUsado(cCodigo)
Local cQuery := ""
cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM "+RetSQLName('VPX')
cQuery += " WHERE VPX_FILIAL = '"+xFilial("VPX")+"'"
cQuery += "   AND VPX_GRUSER = '"+cCodigo+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
Return ( FM_SQL( cQuery ) > 0 )

/*/{Protheus.doc} OA3900021_EstoqueTotal()
Retorna a Qtde do Estoque Total de um determinado Grupo de Serviço Especializado

@author Andre Luis Almeida
@since 26/08/2022
/*/
Function OA3900021_EstoqueTotal(cCodigo,cDescr)
Local aIntCab   := {}
Local aIntLin   := {}
Local cQuery    := ""
Local cAuxAlias := "SQLAUX"
Default cDescr  := FM_SQL("SELECT VPW_DESGRU FROM "+RetSQLName('VPW')+" WHERE VPW_FILIAL='"+xFilial("VPW")+"' AND VPW_CODGRU='"+cCodigo+"' AND D_E_L_E_T_=' '")
Private cCadastro := STR0004+" - "+STR0005+": "+Alltrim(cCodigo)+" - "+Alltrim(cDescr) // Estoque do Serviço Especializado / Grupo de Serviço
aadd( aIntLin , { STR0006 , 0 }) // TODAS FILIAIS
cQuery := "SELECT VPY.VPY_FILEST , SUM(VPY.VPY_QTDEST) AS QTDEST"
cQuery += "  FROM "+RetSQLName('VPY')+" VPY "
cQuery += "  JOIN "+RetSQLName('VPX')+" VPX ON VPX.VPX_FILIAL = VPY.VPY_FILIAL AND VPX.VPX_SERINT = VPY.VPY_SERINT AND VPX.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VPY.VPY_FILIAL = '"+xFilial("VPY")+"'"
cQuery += "   AND VPX.VPX_GRUSER = '"+cCodigo+"'"
cQuery += "   AND VPY.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY VPY.VPY_FILEST"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	aadd( aIntLin , { (cAuxAlias)->(VPY_FILEST)+" - "+FWFilialName( , (cAuxAlias)->(VPY_FILEST) ) , (cAuxAlias)->(QTDEST) })
	aIntLin[1,2] += (cAuxAlias)->(QTDEST)
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())
DbSelectArea("VPX")
If len(aIntLin) > 1
	aAdd(aIntCab,{ Alltrim(cCodigo)+" - "+Alltrim(cDescr) , "C" , 300 , "@!" })
	aAdd(aIntCab,{ RetTitle("VPY_QTDEST") , "N" , 100 , "@E 999,999,999,999,999" })
	FGX_VISINT( "OFIA390" , cCadastro , aIntCab , aIntLin , .t. )
Else
	MsgStop(STR0008,STR0007) // Estoque inexistente para o Grupo de Serviço Especializado. Impossível continuar. / Atencao
EndIf
Return