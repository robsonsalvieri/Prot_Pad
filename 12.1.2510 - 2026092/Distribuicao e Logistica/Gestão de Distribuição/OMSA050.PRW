#Include "Protheus.ch"
#Include "OMSA050.CH"
#Include "FWMVCDEF.CH"
#INCLUDE 'fwmbrowse.ch'

//===========================================================================================================
/* Cadastramento de Ajudante
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		13/11/2012
@return 	*/
//===========================================================================================================
Function OMSA050( aRotAuto, nOpcAuto )

Local oMBrowse	:= Nil
Local l050Auto	:= ( ValType( aRotAuto ) == "A" )
Local aAutoCab	:= {}

Private aRotina	:= MenuDef()

Default nOpcAuto	:= 0


If l050Auto
//===========================================================================================================
// Chamada da rotina automatica através do MVC
//===========================================================================================================
	aAutoCab   := Aclone( aRotAuto )
	FwMvcRotAuto( ModelDef(), "DAU", nOpcAuto, { { "MdFieldDAU", aAutoCab } } )  

Else
//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================
	oMBrowse	:= FwMBrowse():New()
	oMBrowse:SetAlias( "DAU" )
	oMBrowse:SetDescription( OemToAnsi(STR0001) )
	If hasSmartX() 					//-- indica se ambiente está apto para rodar uma rotina em SmartX
		oMBrowse:setSmartX() 		//-- Aqui está a chamada do método que define a utilização do novo browse
	EndIf
	oMBrowse:Activate()

EndIf

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Ajudante
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		13/11/2012
@return 	oModel - Modelo de Dados */
//===========================================================================================================

Static Function ModelDef()

Local oModel	:= Nil
Local oStruDAU	:= FwFormStruct( 1, "DAU" )

oModel	:= MpFormModel():New( "OMSA050", /*bPre*/, { |oModel| PosVldMdl( oModel ) },  { |oModel| CommitMdl( oModel ) }, /*bCancel*/ )

oModel:SetDescription( OemToAnsi(STR0001) )

oModel:AddFields( "MdFieldDAU", Nil, oStruDAU )

oModel:SetPrimaryKey( { "DAU_FILIAL", "DAU_COD" } )

Return( oModel )

//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro de Ajudante
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		14/11/2012
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()

Local oModel	:= FwLoadModel( "OMSA050" )
Local oView		:= Nil
Local oStruDAU	:= FwFormStruct( 2, "DAU" )

oView := FwFormView():New()

oView:SetModel( oModel )

oView:CreateHorizontalBox( "Field"	, 100 )

oView:AddField( "VwFieldDAU", oStruDAU, "MdFieldDAU"	)

oView:SetOwnerView( "VwFieldDAU"	, "Field"	)

Return( oView )

//===========================================================================================================
/* PÓS validacao do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		14/11/2012
@return 	lRet */
//===========================================================================================================
Static Function PosVldMdl( oMdl )

Local lRet    := .T.
Local aArea	:= GetArea()
Local nOpcx	:= oMdl:GetOperation()

If nOpcx == 3 .Or. nOpcx == 4

	If lRet
		If ExistBlock( "OM050VLD" )
			lRet := ExecBlock( "OM050VLD", .F., .F. )
		EndIf
	EndIf

EndIf

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* Gravação do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		14/11/2012
@return 	lRet */
//===========================================================================================================
Static Function CommitMdl( oMdl )

Local lRet	:= .T.
Local nOpcx	:= oMdl:GetOperation()

lRet := FwFormCommit( oMdl )

//-- Ponto de Entrada apos a gravacao dos dados
If ExistBlock("OS050GRV")
	ExecBlock("OS050GRV",.F.,.F.,{nOpcx})
EndIf

Return( lRet )

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Ajudante
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 		14/11/2012
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Local aRotina		:= {	{ STR0002		,"AxPesqui"				,0 , 1,,.F. },;  	//"Pesquisar"
							{ STR0003		,"VIEWDEF.OMSA050"		,0 , 2 },;  		//"Visualizar"
							{ STR0004		,"VIEWDEF.OMSA050"		,0 , 3 },;  		//"Incluir"
							{ STR0005		,"VIEWDEF.OMSA050"		,0 , 4 },;  		//"Alterar"
							{ STR0006		,"VIEWDEF.OMSA050"		,0 , 5 } }  		//"Excluir"

Return( aRotina )


