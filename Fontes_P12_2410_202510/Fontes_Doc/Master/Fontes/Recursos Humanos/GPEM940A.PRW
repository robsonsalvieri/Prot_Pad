#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEM940A.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM940A
Exibe os lotes de integração com a Swile
@author  Allyson Luiz Mesashi
@since   18/10/2022
/*/
//-------------------------------------------------------------------
Function GPEM940A()

Private oBrowse

If !ChkFile("RUC")
	//"Atenção"###"A tabela RUC não existe no dicionário. É necessário atualização do ambiente para acesso à rotina"###"Contate o administrador do sistema para efetuar a atualização do ambiente"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0002), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0003) } )
	Return .F.
EndIf

oBrowse := FWMarkBrowse():New()

If !FWIsAdmin()
    oBrowse:SetFilterDefault( "RUC_USER == '" + RetCodUsr() + "'" )
EndIf

oBrowse:SetAlias( "RUC" )
oBrowse:SetDescription( STR0004 )//"Lote de integração Swile"
oBrowse:SetMenuDef( "GPEM940A" )

//Legendas
oBrowse:AddLegend( "RUC->RUC_STATUS == '1'", "GREEN", STR0005 )//"Concluído"
oBrowse:AddLegend( "RUC->RUC_STATUS == '2'", "RED", STR0006 )//"Erro de validação"

oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função com a regra do Model
@author  Allyson Luiz Mesashi
@since   18/10/2022
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructRUC    := FWFormStruct( 1, "RUC" )
Local oModel        := MpFormModel():New( "GPEM940A", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/ )

oModel:AddFields( "RUCMASTER", /*cOwner*/, oStructRUC, /*Pre-Validacao*/, /*Pos-Validacao*/, /*Carga*/ )
oModel:SetPrimaryKey( {} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função com a regra da View
@author  Allyson Luiz Mesashi
@since   18/10/2022
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel        := FwLoadModel( "GPEM940A" )
Local oStructRUC    := FWFormStruct( 2, "RUC" )
Local oView         := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_RUC", oStructRUC, "RUCMASTER" )
oView:CreateHorizontalBox( "TELA", 100 )
oView:SetOwnerView( "VIEW_RUC", "TELA" )
oView:addUserButton( OemToAnsi(STR0007), "MAGIC_BMP", { || ShellExecute( "open", "https://tdn.totvs.com/pages/viewpage.action?pageId=707370134", "", "", 1 ) }, OemToAnsi(STR0007), Nil, {MODEL_OPERATION_VIEW}, .T. )//"Documentação no TDN"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função com as opções de menu
@author  Allyson Luiz Mesashi
@since   18/10/2022
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina :=  {}

ADD OPTION aRotina TITLE OemToAnsi( STR0008 ) ACTION "VIEWDEF.GPEM940A" OPERATION 2 ACCESS 0//"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi( STR0007 ) ACTION "f940ATDN(1)" 	    OPERATION 10 ACCESS 0//"Documentação no TDN"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} f940ATDN()
Função para abrir página de documentação do TDN
@author  Allyson Luiz Mesashi
@since   18/10/2022
/*/
//-------------------------------------------------------------------
Function f940ATDN( nPag )

If nPag == 1
    ShellExecute( "open", "https://tdn.totvs.com/pages/viewpage.action?pageId=707370134", "", "", 1 )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} f940AAPI
Retorna as opções de combobox do campo RUC_TIPO
@author  Allyson Luiz Mesashi
@since   18/10/2022
/*/
//-------------------------------------------------------------------
Function f940AAPI()

Local cOpcBox := STR0009//"1=Filiais;2=Grupos de benefícios;3=Funcionários;4=Pedidos"

Return cOpcBox

//-------------------------------------------------------------------
/*/{Protheus.doc} f940AStat
Retorna as opções de combobox do campo RUC_STATUS
@author  Allyson Luiz Mesashi
@since   18/10/2022
/*/
//-------------------------------------------------------------------
Function f940AStat()

Local cOpcBox := STR0010//"1=Concluído;2=Erro de validação"

Return cOpcBox
