#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'COMA222CHI.CH'

/*/{Protheus.doc} COMA222CHI
Browse para el documento de Facturas de Entrada
@author 	adrian.perez
@since 		19/08/2025
@version	12.1.2210 / Superior
/*/

Function COMA222CHI()
Local oBrowse	:= Nil

	If FindFunction("MxChkPE")
		MxChkPE("COMA222")
	EndIf

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	adrian.perez
@since 		19/08/2025
@return		oBrowse - objeto - objeto tipo FWMBrowse para la construcción del browse
@version	12.1.2210 / Superior
/*/

Static Function BrowseDef()
Local oBrowse := Nil
Local oTableAtt	:= Nil
Local nX		:= 0

	oBrowse := FwLoadBrw('COMA222')

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
@author 	adrian.perez
@since 		19/08/2025
@return		aRotina - array - array con opciones de la rutina
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := FWLoadMenuDef('COMA222')

    aAdd(aRotina[1][2],{STR0001, 'LxViewNFe("AF", 3)', 0, MODEL_OPERATION_INSERT, 0, NIL, NIL, NIL}) //'"Autofacturación"'
	
Return aRotina

/*/{Protheus.doc} TableAttDef
Definición de las visiones utilizadas en la rutina de Facturas de entrada.
@author 	adrian.perez
@since 		19/08/2025
@version	12.1.2210 / Superior
@Return     oTableAtt - FWTableAtt - objeto con la definición de las visiones de la rutina.
/*/
Static Function TableAttDef()

Local oTableAtt 		:= Nil
//Visiones
Local oAutoFac			:= Nil // ""Autofacturación""

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SF1")

	oAutoFac := FWDSView():New()
	oAutoFac:SetName(STR0001)// ""Autofacturación""
	oAutoFac:SetID("AutoFac")
	oAutoFac:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	oAutoFac:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_TIPO"})
	oAutoFac:SetPublic( .T. )
	oAutoFac:AddFilter(STR0001, "F1_TIPO == 'N' .AND. F1_TIPODOC == '10' .AND. F1_AUTOFAC == '1'") // ""Autofacturación""
	oTableAtt:AddView(oAutoFac)

Return (oTableAtt)

