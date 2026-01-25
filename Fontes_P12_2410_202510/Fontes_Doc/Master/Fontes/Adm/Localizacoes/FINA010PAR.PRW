#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#DEFINE SOURCEFATHER "FINA010"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010PAR
Cadastro de Natureza localizado para PARAGUAI.

O fonte contém browse, menu, model e view propria, todos herdados do FINA010. 
Qualquer regra que se aplique somente para o PARAGUAI deve ser definida aqui.

As validações e integrações realizadas após/durante a gravação estão definidas nos eventos do modelo, 
na classe FINA010EVPAR.

@type function
 
@author Alan Lunardi
@since 30/03/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------------------------------------------------
Function FINA010PAR()
Local oBrowse As Object
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Define o browse padrão para o cadastro de natureza.

@type function
 
@author Alan Lunardi
@since 30/03/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse As Object 
	
	oBrowse := FwLoadBrw(SOURCEFATHER) 

Return oBrowse
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o model padrão para o cadastro de natureza.

@type function
 
@author Alan Lunardi
@since 30/03/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel As Object
Local oEvent As Object
	
	oModel := FWLoadModel(SOURCEFATHER)
	oEvent := FINA010EVPAR():New()
	oModel:InstallEvent("PARAGUAI",,oEvent)
	
Return oModel
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view padrão para o cadastro de natureza.

@type function
 
@author Alan Lunardi
@since 30/03/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView As Object

	oView := FWLoadView(SOURCEFATHER)

Return oView

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu padrão para o cadastro de natureza.

@type function
 
@author Alan Lunardi
@since 30/03/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	As Array 

	aRotina  := FWLoadMenuDef(SOURCEFATHER)

	
Return aRotina
