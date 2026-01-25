#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'COMA223COL.CH'

/*/{Protheus.doc} COMA223COL
Browse para el documento de Facturas de Entrada
@author 	raul.medina
@since 		02/2024
@version	12.1.2210 / Superior
/*/

Function COMA223COL()
Local oBrowse	:= Nil

	If FindFunction("MxChkPE")
		MxChkPE("COMA223")
	EndIf

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	raul.medina
@since 		02/2024
@version	12.1.2210 / Superior
/*/

Static Function BrowseDef()
Local oBrowse := Nil
Local oTableAtt	:= Nil
Local nX		:= 0

	oBrowse := FwLoadBrw('COMA223')
	oBrowse:SetFilterDefault( "F1_TIPODOC $ '09/23'" )
	oTableAtt := TableAttDef()
	//--------------------------------------------------------------------------------------
	//  Carga todas las visiones y graficos disponibles para actividades en la función TableAttDef
	//---------------------------------------------------------------------------------------
	If ValType(oTableAtt:aViews) == "A"
		For nX := 1 To Len(oTableAtt:aViews)
			Aadd(oBrowse:aViewsDefault, oTableAtt:aViews[nX])
		Next
	EndIf

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		02/2024
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := FWLoadMenuDef('COMA223')

    aAdd(aRotina[1][2],{STR0001, 'LxViewNDE("NDPS", 3)', 0, MODEL_OPERATION_INSERT, 0, NIL, NIL, NIL}) //"Nota de Débito - Nota Ajuste"
	
Return aRotina

/*/{Protheus.doc} TableAttDef
Definición de las visiones utilizadas en la rutina de Facturas de entrada.
@author 	raul.medina
@since 		02/2024
@version	12.1.2210 / Superior
Parametros
    oTableAtt - FWTableAtt - objeto con la definición de las visiones de la rutina.
@Return 
/*/
Static Function TableAttDef()

Local oTableAtt 		:= Nil
//Visiones
Local oFacSop			:= Nil // "Nota de Débito - Nota Ajuste"

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SF1")

	oFacSop := FWDSView():New()
	oFacSop:SetName(STR0001)// "Nota de Débito - Nota Ajuste"
	oFacSop:SetID("FacSop")
	oFacSop:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	oFacSop:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_TIPO"})
	oFacSop:SetPublic( .T. )
	oFacSop:AddFilter(STR0001, "F1_TIPO == 'C' .AND. F1_TIPODOC == '23'") // "Nota de Débito - Nota Ajuste"
	oTableAtt:AddView(oFacSop)

Return (oTableAtt)
