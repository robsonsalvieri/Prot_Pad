#INCLUDE "JURA204C.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA204C
Modelo simplificado da Fatura para carregar os Docs. Relacionados

@author Reginaldo Borges
@since  009/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA204C()

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
	aAdd( aRotina, {'',"VIEWDEF.JURA204C", 0, 2, 0, NIL } ) // "Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados resumido da Fatura

@author Reginaldo Borges
@since  03/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel      := Nil
Local oStructNXA  := FWFormStruct( 1, 'NXA', , , .F.) // Fatura
Local oStructNXM  := FWFormStruct( 1, 'NXM', , , .F.) // Docs. Relacionados
Local oEvtJURA204 := JA204COMMIT():New()

	If !FWAliasInDic("OHT") .Or. !FwIsInCallStack("J243SE1Opt") // Cobrança
		oStructNXM:AddField(                                          ;
				"ORDEM"                                              ,; // [01]  C   Titulo do campo
				"ORDEM"                                              ,; // [02]  C   ToolTip do campo
				"__ORDEM"                                            ,; // [03]  C   Id do Field
				"N"                                                  ,; // [04]  C   Tipo do campo
				2                                                    ,; // [05]  N   Tamanho do campo
				0                                                    ,; // [06]  N   Decimal do campo
				NIL                                                  ,; // [07]  B   Code-block de validação do campo
				NIL                                                  ,; // [08]  B   Code-block de validação When do campo
				NIL                                                  ,; // [09]  A   Lista de valores permitido do campo
				NIL                                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
				FwBuildFeature(STRUCT_FEATURE_INIPAD, "IIf(INCLUI, 0, NXM->NXM_ORDEM)"),; // [11]  B   Code-block de inicializacao do campo
				NIL                                                  ,; // [12]  L   Indica se trata-se de um campo chave
				NIL                                                  ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
				.T.                                                   ) // [14]  L   Indica se o campo é virtual

		oStructNXM:RemoveField("NXM_CESCR")
		If NXM->(ColumnPos("NXM_CPREFT")) > 0 // @12.1.2310
			oStructNXM:RemoveField('NXM_CPREFT')
		EndIf
		oStructNXM:RemoveField("NXM_CFATUR")
	EndIf

	oModel := MPFormModel():New('JURA204C', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields('NXAMASTER', /*cOwner*/, oStructNXA, { || }/*bPreValidacao*/, { || }/*bPosValidacao*/, /*bLoad*/)
	oModel:AddGrid("NXMDETAIL", "NXAMASTER" , oStructNXM, /*bLinePre*/, /*bLinePost*/, /*bPre*/, {|| J204PDFPos()} /*bPost*/, {|oGrid| J204LdLanc("NXM", oGrid, "")})
	oModel:SetDescription(STR0001) // "Modelo de Dados Resumido da Fatura"

	oModel:GetModel('NXAMASTER'):SetDescription(STR0001) // "Modelo de Dados de Fatura"
	oModel:GetModel('NXMDETAIL'):SetDescription(STR0002) // "Docs. Relacionados"

	// Docs. Relacionados
	oModel:SetRelation("NXMDETAIL", {{"NXM_FILIAL", "xFilial('NXM')"}, {"NXM_CESCR", "NXA_CESCR"}, {"NXM_CFATUR", "NXA_COD" }}, NXM->(IndexKey(1))) // Documentos da Fatura

	oModel:InstallEvent("JA204COMMIT", /*cOwner*/, oEvtJURA204)	

Return oModel
