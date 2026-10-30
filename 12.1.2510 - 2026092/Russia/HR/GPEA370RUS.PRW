#INCLUDE "Protheus.ch"
#INCLUDE "GPEA370.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEA370RUS 
Positions Register File (Russia)

@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Function GPEA370RUS(xRotAuto)
	Local oBrowse as object

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Local oBrowse as object

	oBrowse := FWLoadBrw("GPEA370")
Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina :=  FWLoadMenuDef("GPEA370")
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados
@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel as object
	
	oModel 	:= FwLoadModel('GPEA370')
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oModel   As Object
    Local oView    As Object
    Local oStruSQ3 As Object

    oView := FWLoadView("GPEA370")

    oStruSQ3 := oView:GetViewStruct("VIEW_GPEA370")

    oStruSQ3:RemoveField("Q3_ACUM")
    oStruSQ3:RemoveField("Q3_CTESP")
    oStruSQ3:RemoveField("Q3_DEDEXC")
    oStruSQ3:RemoveField("Q3_SIT")

Return oView
//Checked and merged by AS for Russia_R4 * *
// Russia_R5