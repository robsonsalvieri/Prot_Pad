#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA316.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA316VEI
Função responsavel pela browse da amarração de Veículo x documentos
@type Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA316VEI()

Local oBrowse   := Nil

If ( !FindFunction("GTPHASACCESS") .Or.; 
    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

    oBrowse   := FWLoadBrw('GTPA316')
    oBrowse:SetMenuDef('GTPA316VEI')
    oBrowse:SetDescription(STR0027)//'Amarração do Veículo x Documento'

    oBrowse:SetFilterDefault ( " G6V_TRECURS == '2' ")//Filtra apenas registros de Veículo

    oBrowse:Activate()
    oBrowse:Destroy()

    GTPDestroy(oBrowse)

EndIf 

Return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0023    ACTION 'VIEWDEF.GTPA316VEI' OPERATION OP_VISUALIZAR	    ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0024    ACTION 'VIEWDEF.GTPA316VEI' OPERATION OP_INCLUIR		ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0025    ACTION 'VIEWDEF.GTPA316VEI' OPERATION OP_ALTERAR		ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0026    ACTION 'VIEWDEF.GTPA316VEI' OPERATION OP_EXCLUIR		ACCESS 0 // "Excluir"
    ADD OPTION aRotina TITLE STR0035    ACTION "GP316VEANX()"       OPERATION OP_ALTERAR        ACCESS 0 //"Anexos de Documentos"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView         := FwLoadView('GTPA316')
Local oModel        := oView:GetModel()
Local oStrMdlG6V    := oModel:GetModel('G6VMASTER'):GetStruct()
Local oStrMdlG6W    := oModel:GetModel('G6WDETAIL'):GetStruct() 
Local oStrViwG6V    := oView:GetViewStruct('VIEW_G6V')

SetModelStruct(oStrMdlG6V,oStrMdlG6W)
SetViewStruct(oStrViwG6V)

oModel:SetDescription(STR0027)  //'Amarração do Veículo x Documento'
oView:SetDescription(STR0027)   //'Amarração do Veículo x Documento'

If IsInCallStack("GP316VEANX")
    oView:SetNoDeleteLine('G6WDETAIL')
    oView:SetNoInsertLine('G6WDETAIL')
EndIf

Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela estrutura de dados do modelo
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oStrG6V, object, (Descrição do parâmetro)
@param oStrG6W, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrG6V,oStrG6W)

oStrG6V:SetProperty('G6V_RECURS'	, MODEL_FIELD_TAMANHO	,TamSx3('T9_CODBEM')[1] )
oStrG6V:SetProperty('G6V_DRECUR'	, MODEL_FIELD_TAMANHO	,TamSx3('T9_NOME')[1] )

oStrG6V:SetProperty('G6V_TRECUR'	,MODEL_FIELD_INIT	    ,{||'2'})//Veículo

If IsInCallStack("GP316VEANX")
    oStrG6V:SetProperty("*", MODEL_FIELD_WHEN, {|| .F.} )
    oStrG6W:SetProperty("*", MODEL_FIELD_WHEN, {|| .F.} )
    oStrG6W:SetProperty("ANEXO", MODEL_FIELD_WHEN, {|| .T.} )
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da view
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oStrG6V, object, (Descrição do parâmetro)
@param oStrG6W, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrG6V,oStrG6W)

oStrG6V:SetProperty("G6V_RECURS"	,MVC_VIEW_LOOKUP		, 'ST9' )

Return

/*/{Protheus.doc} GP316VEANX(oView)
Função para tratamento do MsDocument trazendo os documentos anexados em modo de visualização da rotina dem tipos de documentos operacionais.
@type  Static Function
@author Eduardo Silva
@since 18/03/2024
/*/

Function GP316VEANX(oView)
FWExecView(STR0035,"VIEWDEF.GTPA316VEI",MODEL_OPERATION_UPDATE,,{|| .T.})   // "Anexos de Documentos"
Return
