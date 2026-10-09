#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'


Static cTitulo := FWX2Nome( "I21" )

/*/{Protheus.doc} PINSA020
Funcao MVC paara a tabela I21, Modelo 2 MVC
@author valter.carvalho@totvspartners.com.br
@since 03/09/2024
@version 1.0
@return Nil
/*/
Function PINSA020()

	Local oBrowse as Object

	oBrowse := FwLoadBrw("PINSA020")

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
    oBrowse:SetAlias("I21")
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

    Local oModel    as Object
    Local oStruI21  as Object
    
    oModel    := MPFormModel():New('PINSA020')
    oStruI21  := FWFormStruct(1, 'I21' )
       
    oModel:AddFields('I21MASTER',NIL, oStruI21)
    oModel:SetPrimaryKey({"I21_FILIAL", "I21_UIDINS"})

Return oModel
