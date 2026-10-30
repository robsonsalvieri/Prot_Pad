#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'COMA227.CH'
#include "fwmbrowse.ch"

/*/{Protheus.doc} COMA227
Browse para el documento de Remito Devolución (Compras)
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
/*/

Function COMA227()
Local oBrowse	:= Nil

	If !(cPaisLoc $ "ARG")
		SetFunName("MATA102DN")
    	MATA102DN()
	Else
		If FindFunction("MxChkPE")
			MxChkPE("COMA227")
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
@since 		07/2026
@version	12.1.2510 / Superior
/*/

Static Function BrowseDef()
Local oBrowse		:= Nil
Local aCores    	:= {}
Local nX			:= 0
Local oTableAtt		:= Nil
Local nIndex		:= 1
Local lOrderAsc		:= .T.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('SF2')


    If hasSmartX()
		oBrowse:setSmartX(nIndex, lOrderAsc)
		oBrowse:AddFilterSmartX( "@F2_TIPODOC = '61'")
	EndIf
	
	AAdd(aCores,{  'F2_TIPO	==	"D"	.AND. F2_TIPODOC = "61"', 'BR_AZUL', STR0001})	// 'Remito Devolución'

	For nX :=1 To Len(aCores)
        oBrowse:addLegend(aCores[nX][1],aCores[nX][2],aCores[nX][3])
    Next nX
    oBrowse:SetFilterDefault( "F2_TIPODOC $ '61'" )

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
@since 		07/2026
@version	12.1.2510 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
Local aRotInc := {}
Local aRotAux := {}
Local lC227Mnu := ExistBlock("COMA227MNU")
	
	ADD OPTION aRotInc TITLE STR0001    ACTION 'LxViewRCD("RCD", 3)'	OPERATION MODEL_OPERATION_INSERT    ACCESS 0 // 'Remito Devolución'

    ADD OPTION aRotina TITLE STR0002	ACTION aRotInc				OPERATION MODEL_OPERATION_INSERT	ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0003 	ACTION 'LxViewRCD("", 1)' 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0004	ACTION 'LxViewRCD("", 5)' 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0 // 'Excluir'
	ADD OPTION aRotina TITLE STR0005	ACTION 'CTBC662' 			OPERATION 2    						ACCESS 0 // 'Tracker Contábil'
	ADD OPTION aRotina TITLE STR0006	ACTION 'LxLegndOut()' 		OPERATION 2    						ACCESS 0 // 'Leyenda'
	
	If lC227Mnu
		aRotAux := ExecBlock("COMA227MNU",.F.,.F.,{aRotina})
		If (ValType(aRotAux) == "A")
			aRotina := aClone(aRotAux)
			FwFreeArray(aRotAux)
		EndIf
	EndIf

Return aRotina

/*/{Protheus.doc} LxViewRCD
Función utilizada para realizar la selección de la view de acuerdo al documento.
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
Parametros
    cType - caracter - tipo de documento.
    nOperation - numerico - operación a ser realizada.
@Return 
/*/
Function LxViewRCD(cType, nOperation)
Local cOperation := OemToAnsi(STR0003) //'Visualizar'

Default cType 		:= ""
Default nOperation	:= 3

	If Empty(cType)
		If SF2->F2_TIPODOC == "61"
			cType := "RCD"
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_INSERT
		cOperation := OemToAnsi(STR0002) //'Incluir'
	ElseIf nOperation == MODEL_OPERATION_DELETE
		cOperation := OemToAnsi(STR0004) //'Excluir'
	EndIf

	If cType == "RCD"
		aCfgNf  := MontaCfgNf(61,{},.F.)
		FwExecView(cOperation,"VIEWDEF.LOCX61",nOperation,,{|| .T.}) 
	EndIf

Return

/*/{Protheus.doc} TableAttDef
Definición de las visiones utilizadas en la rutina de notas de crédito proveedor.
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
Parametros
    oTableAtt - FWTableAtt - objeto con la definición de las visiones de la rutina.
@Return 
/*/
Static Function TableAttDef()

Local oTableAtt 		:= Nil
//Visiones
Local oRemitoDev		:= Nil // Remito Delovución

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SF2")

	oRemitoDev := FWDSView():New()
	oRemitoDev:SetName(STR0001)// "Remito Delovución"
	oRemitoDev:SetID("NotaDebProv")
	oRemitoDev:SetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO 
	oRemitoDev:SetCollumns({"F2_FILIAL","F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA","F2_TIPO"})
	oRemitoDev:SetPublic( .T. )
	oRemitoDev:AddFilter(STR0001, "F2_TIPO == 'D' .AND. F2_TIPODOC == '61'") // "NRemito Delovución"
	oTableAtt:AddView(oRemitoDev)

Return (oTableAtt)
