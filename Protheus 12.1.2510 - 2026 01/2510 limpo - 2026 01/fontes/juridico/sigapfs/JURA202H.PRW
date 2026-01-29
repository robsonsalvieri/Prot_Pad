#INCLUDE "JURA202H.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202H
Modelo simplificado da Pre-fatura para carregar os Docs. Relacionados

@author Reginaldo Borges
@since  009/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA202H()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Reginaldo Borges
@since  03/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	aAdd( aRotina, {'',"VIEWDEF.JURA202H", 0, 2, 0, NIL}) // "Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados resumido da Pré-fatura

@author Reginaldo Borges
@since  03/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := Nil
Local oStructNX0 := FWFormStruct( 1, 'NX0',{ | cCampo | AllTrim(cCampo) $ "NX0_FILIAL|NX0_COD|NX0_SITUAC|NX0_DMAXEM|NX0_CCLIEN|NX0_CLOJA|NX0_CESCR"}, , .F.) // Pré-fatura
Local oStructNXM := FWFormStruct( 1, 'NXM',{ | cCampo | AllTrim(cCampo) $ "NXM_TKRET|NXM_NOMARQ|NXM_EMAIL|NXM_ORDEM|NXM_CTIPO|NXM_CTPARQ|NXM_CESCR"}, , .F.) // Docs. Relacionados

	oModel := MPFormModel():New('JURA202H', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields('NX0MASTER', /*cOwner*/, oStructNX0, { || }/*bPreValidacao*/, { || } /*bPosValidacao*/, /*bLoad*/)
	oModel:AddGrid('NXMDETAIL', 'NX0MASTER', oStructNXM, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
	oModel:SetDescription(STR0001) // "Modelo de Dados Resumido da Pré-Fatura" 

	oModel:GetModel('NX0MASTER'):SetDescription(STR0001) // "Modelo de Dados de Pré-Fatura"
	oModel:GetModel('NXMDETAIL'):SetDescription(STR0002) // "Docs. Relacionados"

	// Docs. Relacionados
	oModel:SetRelation("NXMDETAIL", {{"NXM_FILIAL", "xFilial('NXM')"}, {"NXM_CPREFT", "NX0_COD"}}, NXM->(IndexKey(7))) // Documentos da Pré-Fatura

Return oModel
