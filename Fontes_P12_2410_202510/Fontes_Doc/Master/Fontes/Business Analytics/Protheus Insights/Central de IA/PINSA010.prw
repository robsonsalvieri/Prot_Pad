#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'


Static cTitulo := FWX2Nome( "I19" )

/*/{Protheus.doc} PINSA010
Função para cadastro I19, Modelo 1 MVC
@author valter.carvalho@totvspartners.com.br
@since 03/09/2024
@version 1.0
	@return Nil, Função sem retorno
/*/
Function PINSA010()
	Local oBrowse := FwLoadBrw("PINSA010")

	oBrowse:Activate()
Return
/** {Protheus.doc} BrowseDef    
@author valter.carvalho@totvspartners.com.br
@since 03/09/2024
@version 1.0
@return aRotina
**/
Static Function BrowseDef()

    Local oBrowse as Object
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("I19")
    oBrowse:SetDescription(cTitulo)

Return oBrowse
/** {Protheus.doc} ModelDef    
Retorna o model dos dados
@author valter.carvalho@totvspartners.com.br
@since 03/09/2024
@version 1.0
@return oModel Objeto com o modelo
**/
Static Function ModelDef()

	Local oModel   as Object
	Local oStruI19 as Object	

	oModel    := MPFormModel():New('PINSA010')
    oStruI19  := FWFormStruct(1, 'I19' )

	oModel:AddFields( 'I19MASTER', Nil, oStruI19)

	oModel:SetPrimaryKey( { "I19_FILIAL", "I19_UIDMSG" } )

Return oModel
