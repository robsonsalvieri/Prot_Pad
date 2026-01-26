#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'COMA222MEX.CH'

/*/{Protheus.doc} COMA222MEX
Browse para el documento de Facturas de Entrada
@author 	raul.medina
@since 		02/2024
@version	12.1.2210 / Superior
/*/

Function COMA222MEX()
Local oBrowse	:= Nil

	If FindFunction("MxChkPE")
		MxChkPE("COMA222")
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
Local oBrowse 	:= Nil
Local oTableAtt	:= Nil
Local nX		:= 0

	oBrowse := FwLoadBrw('COMA222')
    oBrowse:SetFilterDefault( "F1_TIPODOC $ '10/12/13/14/20'" )

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
Local aRotina := FWLoadMenuDef('COMA222')

    aAdd(aRotina[1][2],{STR0001, 'LxViewNFe("A", 3)', 0, MODEL_OPERATION_INSERT, 0, NIL, NIL, NIL})
	
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
Local oFacAnti			:= Nil // "Anticipo"

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("SF1")

	oFacAnti := FWDSView():New()
	oFacAnti:SetName(STR0001)// "Anticipo"
	oFacAnti:SetID("FacAnti")
	oFacAnti:SetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	oFacAnti:SetCollumns({"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_TIPO"})
	oFacAnti:SetPublic( .T. )
	oFacAnti:AddFilter(STR0001, "F1_TIPO == 'A' .AND. F1_TIPODOC == '20'") // "Anticipo"
	oTableAtt:AddView(oFacAnti)

Return (oTableAtt)
