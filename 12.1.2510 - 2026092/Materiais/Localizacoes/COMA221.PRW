#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'coma221.ch'
#include "fwmbrowse.ch"

/*/{Protheus.doc} COMA221
Browse para el documento de Remitos de Entrada
@author 	raul.medina
@since 		03/2024
@version	12.1.2210 / Superior
/*/

Function COMA221()
	Local oBrowse	:= Nil

	If !(cPaisLoc $ "ARG|COL|MEX|PAR|PER|EQU|CHI|BOL|URU|EUA")
		SetFunName("MATA102N")
		Mata102n()
	Else
		If FindFunction("MxChkPE")
			MxChkPE("COMA221")
		EndIf

		oBrowse := BrowseDef()
		oBrowse:Activate()

		oBrowse:DeActivate()
		oBrowse:Destroy()
		oBrowse := Nil
	EndIf

Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
/*/

Static Function BrowseDef()
	Local oBrowse	:= Nil
	Local oTableAtt          := Nil
	Local nIndex             := 1
	Local lOrderAsc          := .T.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('SF1')

	oBrowse:SetFilterDefault("@F1_FILIAL='"+xFilial('SF1')+"' AND F1_TIPODOC IN ('60','62')")

	If hasSmartX()
		oBrowse:setSmartX(nIndex, lOrderAsc) // indice 1 = F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	EndIf

	oBrowse:addLegend('F1_TIPO	==	"B"	.AND. F1_TIPODOC	<>	"63"   ','BR_CINZA',OemToAnsi(STR0005),,,"caption-tag-33")
	oBrowse:addLegend('F1_TIPO	==	"N"	.AND. F1_TIPODOC	==	"60"   ','BR_MARROM',OemToAnsi(STR0004),,,"caption-tag-10")	// Remito

	oBrowse:SetAttach(.T.)

	oTableAtt := TableAttDef()

	//--------------------------------------------------------------------------------------
	//  Carga todas las visiones y graficos disponibles para actividades en la función TableAttDef
	//---------------------------------------------------------------------------------------
	If oTableAtt <> Nil
		oBrowse:SetViewsDefault( oTableAtt:aViews )
	EndIf

	SetKey(VK_F12,{||Pergunte("MTXRED",.T.)})

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
	Local aRotina := {}
	Local aRotInc := {}
	Local aRotAux := {}
	Local lC221Mnu := ExistBlock("COMA221MNU")

	ADD OPTION aRotInc TITLE STR0004    ACTION 'LxViewRen("N", 3)'	OPERATION MODEL_OPERATION_INSERT    ACCESS 0 PAGEACTION // 'Remito'
	ADD OPTION aRotInc TITLE STR0005  	ACTION 'LxViewRen("B", 3)'	OPERATION MODEL_OPERATION_INSERT   	ACCESS 0 PAGEACTION // 'Beneficiamiento'

	ADD OPTION aRotina TITLE STR0001	ACTION aRotInc				OPERATION MODEL_OPERATION_INSERT	ACCESS 0 PAGEACTION // 'Incluir'
	ADD OPTION aRotina TITLE STR0002 	ACTION 'LxViewRen("", 1)' 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0003	ACTION 'LxViewRen("", 5)' 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0 // 'Excluir'
	ADD OPTION aRotina TITLE "Imprimir"	ACTION 'VIEWDEF.LOCX60' 		OPERATION OP_IMPRIMIR				ACCESS 0 // 'Imprimir - teste LOCX60 fixo, Beneficiamiento ainda nao coberto'
	ADD OPTION aRotina TITLE STR0010	ACTION 'CTBC662' 			OPERATION 2    						ACCESS 0 // 'Tracker Contábil'
	ADD OPTION aRotina TITLE STR0011	ACTION 'LxLegendIn()' 		OPERATION 2    						ACCESS 0 // 'Leyenda'


	If lC221Mnu
		aRotAux := ExecBlock("COMA221MNU",.F.,.F.,{aRotina})
		If (ValType(aRotAux) == "A")
			aRotina := aClone(aRotAux)
		EndIf
	EndIf

Return aRotina

/*/{Protheus.doc} LxViewRen
Función utilizada para realizar la selección de la view de acuerdo al documento.
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
Parametros
    cType - caracter - tipo de documento.
    nOperation - numerico - operación a ser realizada.
@Return 
/*/
Function LxViewRen(cType, nOperation)
	Local cOperation := OemToAnsi(STR0002) // 'Visualizar'

	Default nOperation	:= 3
	Default cType 		:= ""

	If Empty(cType)
		If SF1->F1_TIPODOC == "62"
			cType := "B"
		Else
			cType := "N"
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_INSERT
		cOperation := OemToAnsi(STR0001) // 'Incluir'
	ElseIf nOperation == MODEL_OPERATION_DELETE
		cOperation := OemToAnsi(STR0003) // 'Excluir'
	ElseIf nOperation == OP_IMPRIMIR
		cOperation := "Imprimir"
	EndIf

	If cType == "B"
		aCfgNf  := MontaCfgNf(62,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX62",nOperation,,{|| .T.})
	Else
		aCfgNf  := MontaCfgNf(60,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX60",nOperation,,{|| .T.})
	EndIf

Return

/*/{Protheus.doc} TableAttDef
Definición de las visiones utilizadas en la rutina de remitos.
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
Parametros
    oTableAtt - FWTableAtt - objeto con la definición de las visiones de la rutina.
@Return 
/*/
Static Function TableAttDef()

	Local oTableAtt 		:= Nil
//Visiones
	Local oRemNormal		:= Nil // Remitos Normales
	Local oRemBenef			:= Nil // Remitos Benef.

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SF1")


	oRemNormal := FWDSView():New()
	oRemNormal:SetName(STR0008)// "Remitos"
	oRemNormal:SetID("RemNormal")
	oRemNormal:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	oRemNormal:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_NOMFOR","F1_TIPO","F1_DESCCP"})
	oRemNormal:SetPublic( .T. )
	oRemNormal:AddFilter(STR0008, "F1_TIPO == 'N' .AND. F1_TIPODOC == '60'") // "Remitos"
	oTableAtt:AddView(oRemNormal)

	oRemBenef := FWDSView():New()
	oRemBenef:SetName(STR0009)// "Remitos"
	oRemBenef:SetID("RemBenef")
	oRemBenef:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	oRemBenef:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_NOMFOR","F1_TIPO","F1_DESCCP"})
	oRemBenef:SetPublic( .T. )
	oRemBenef:AddFilter(STR0009, "F1_TIPO == 'B' .AND. F1_TIPODOC == '62'") // "Remitos Benef."
	oTableAtt:AddView(oRemBenef)

Return (oTableAtt)

/*/{Protheus.doc} COM221FoNo
Gatilho para exibir o nome do fornecedor no browse (SmartX).
Usado em SX3->X3_INIBRW do campo virtual F1_NOMFOR.
@type Function
@author Rodrigo Correia
@since 05/08/2026
@version 1.0
@return cRet, Character, Retorna el valor del campo A2_NOME
/*/
Function COM221FoNo()
	Local cRet := Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")
Return cRet

/*/{Protheus.doc} COM221CpDs
Gatilho para exibir a descricao da condicao de pagamento no browse (SmartX).
Usado em SX3->X3_INIBRW do campo virtual F1_DESCCP.
@type Function
@author Rodrigo Correia
@since 05/08/2026
@version 1.0
@return cRet, Character, Retorna el valor del campo E4_DESCRI
/*/
Function COM221CpDs()
	Local cRet := Posicione("SE4",1,xFilial("SE4")+SF1->F1_COND,"E4_DESCRI")
Return cRet
