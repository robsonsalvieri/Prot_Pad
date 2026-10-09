#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FISA174DET.CH" 

PUBLISH MODEL REST NAME FISA174DET SOURCE FISA174DET
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA174DET
 
@author Erick G. Dias
@since 26/09/2013
@version 11.90

/*/
//-------------------------------------------------------------------
Function FISA174DET(cAlias, cDescr, cFiltro)

Local oBrw := FWmBrowse():New()

PRIVATE c174Als := cAlias

oBrw:SetDescription(cDescr)
oBrw:SetAlias(FSA174ALIAS())
oBrw:SetMenuDef('FISA174DET')
oBrw:DisableDetails()
oBrw:ForceQuitButton()
oBrw:SetFilterDefault( cFiltro )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina := {}

ADD OPTION aRotina TITLE STR0001 ACTION 'VIEWDEF.FISA174DET' OPERATION 2 ACCESS 0 //'Visualizar'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruGener := FWFormStruct(1, FSA174ALIAS())
Local oModel := NIL
Local cCmpoPK := Iif(SubStr(FSA174ALIAS(),1,1) == 'S', SubStr(FSA174ALIAS(),2,2), FSA174ALIAS()) + '_FILIAL'

oModel	:=	MPFormModel():New('FISA174DET',,{ |oModel| .T. } , { |oModel| .T. } )

oModel:AddFields( 'MODEL_GEN' ,, oStruGener )

//A passagem de chave primária para o modelo se deve ao fato de existirem tabelas do legado do sistema que não possuem
//chave primária definida X2_UNICO, para estas tabelas exibe erro.
//Por este motivo passo de forma genérica a filial para o modelo para não ficar sem nenhuma chave primária
//e exibir tanto as tabelas que está corretas quanto as tabelas de legado.
oModel:SetPrimaryKey( {cCmpoPK} )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel     := FWLoadModel('FISA174DET')
Local oStruGener := Nil
Local oView      := FWFormView():New()
Local cDescri    := 'Visualização'

oView:SetModel( oModel )
oStruGener := FWFormStruct( 2, FSA174ALIAS())
oView:AddField( 'VIEW_GEN', oStruGener, 'MODEL_GEN' )

oView:EnableTitleView( 'VIEW_GEN', cDescri )

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA174ALIAS
Função utilizada para retornar alias do modelo genériuco FISA174.

@author Renato Rezende
@since 13/11/2020
@version 12.1.31

/*/
//-------------------------------------------------------------------
Function FSA174ALIAS()
Return Iif (type("c174Als") == 'C', c174Als, "")
