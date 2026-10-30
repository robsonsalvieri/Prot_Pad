#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWTicket.ch'
#INCLUDE "CFGA050.ch"
#INCLUDE "POSCSS.CH"  

#DEFINE CON_HTTP	1
#DEFINE CON_RPC	2
#DEFINE CON_WS	3


Static lWizard			:= .F.
Static oHostDAO
Static cHostID
Static aProfile := {}
Static lConnVld := .F.
Static aSrvAux 	:= {}

//-------------------------------------------------------------------
/*/{Protheus.doc} CFGA050A
Rotina de manutenção de hosts
Está rotina é chamada pela rotina CFGA050 do Framework
@author  Totvs
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Function CFGA050A()
Local aColumns	
Local aCoors	
Local aFields	
Local aSeek		
Local nCol		
Local nX		
Local oDlg, oColumn, oButton, oBrwLayOut, oView, oStruct
Local cLocalId  
Local bCommit 

aColumns	:= {}
aCoors	:= FWGetDialogSize( oMainWnd )
aFields	:= {}
aSeek		:= {}
nCol		:= 0
nX		:= 0
cLocalId := GetPvProfString("FwCommunication","ID","",GetAdv97())
bCommit := {|| FWCFGA050Commit() }


CursorWait()
FWMsgRun( , { || If(oHostDAO == NIL,oHostDAO := FwHostDao():New(),), cHostID := AllTrim(oHostDAO:GetLocalId()) } , , STR0002+"..." )
CursorArrow()

oView		:= ViewDef()
oStruct	:= oView:GetModel():GetModel('XXPMASTER'):GetStruct()

aSeek := CreateSeek(oStruct)
If select("XXP") >0
	If Empty(cLocalId) .or. !XXP->(DbSeek(cLocalId)) .or. GetPvProfString("FwCommunication","Replica","0",GetAdv97()) == "1"
		CFGA050AWizard()
	Else			
		Define MsDialog oDlg Title I18N( STR0001 ) FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) Pixel
		
		//-------------------------------------------------------------------
		// Define o Browse
		//-------------------------------------------------------------------
		oBrwLayOut:= FWFormBrowse():New()
		oBrwLayOut:SetDataTable(.T.)
		oBrwLayOut:SetAlias("XXP")
		oBrwLayOut:DisableReport()
		oBrwLayOut:DisableDetails()
		oBrwLayOut:SetSeek(Nil,aSeek)
		oBrwLayOut:SetOwner(oDlg)
		oBrwLayOut:SetDescription( I18N( STR0001 ) )
		oBrwLayOut:AddLegend({|| AllTrim(XXP->XXP_ID) == cHostID},'BLUE',STR0058) 
		
		//-------------------------------------------------------------------
		// Adiciona as colunas do Browse
		//-------------------------------------------------------------------
		aFields := FWXXPFields() 
		
		For nX := 1 to Len(aFields)
			If aFields[nX][7]
				nCol++
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[nCol]:SetData( &("{||" + aFields[nX][1] + "}") )
				aColumns[nCol]:SetTitle(aFields[nX][2])	
				aColumns[nCol]:SetSize(aFields[nX][4])	
			EndIf
		Next nX
		
		oBrwLayOut:SetColumns(aColumns)
		
		//-------------------------------------------------------------------
		// Adiciona os botoes do Browse
		//-------------------------------------------------------------------
		oBrwLayOut:AddButton(I18N(STR0059)	,'VIEWDEF.CFGA050A'	,,MODEL_OPERATION_VIEW 	,,.F.)
		oBrwLayOut:AddButton(I18N(STR0060)	,'CFGA050AWizard'		,,MODEL_OPERATION_INSERT	,,.F.)
		oBrwLayOut:AddButton(I18N(STR0061)	,'VIEWDEF.CFGA050A'	,,MODEL_OPERATION_UPDATE	,,.F.)
		oBrwLayOut:AddButton("Excluir Host"	,'CfgDelHost')
		
		//-------------------------------------------------------------------
		// Adiciona os botoes do Filtro
		//-------------------------------------------------------------------
		oBrwLayOut:SetUseFilter(.T.)
		
		//-------------------------------------------------------------------
		// Ativação do Browse
		//-------------------------------------------------------------------
		oBrwLayOut:Activate()
		
		Activate MsDialog oDlg Centered
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados

@author  TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oModelXXX
Local oStruXXP	:= DefStrModel("XXP")
Local oStruXXX	:= DefStrModel("XXX")
Local oStruAUX	:= DefStrAuxModel()
Local oStruUSER	:= UserModel()
Local bPosValid	:= {|| RunHostUpdate() }
Local bCommit	:= {|| FWCFGA050Commit() }

DEFAULT oHostDAO := FwHostDao():New()
DEFAULT cHostID := AllTrim(oHostDAO:GetLocalId())

FWOpenXXX()
FwCheckDic("XXP")
FwCheckDic("XXX") 

oModel := MPFormModel():New( 'CFGA050A', /*bPreValidacao*/, bPosValid, bCommit )

oModel:AddFields('XXPMASTER', /*cOwner*/, oStruXXP, /*bPreValidacao*/, /*bPosValid*/, /*bCarga*/ )
oModel:AddGrid('XXXDETAIL'	, 'XXPMASTER', oStruXXX, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| XXXLoad(oGrid)})
oModel:AddFields('AUXDETAIL'	, 'XXPMASTER', oStruAUX, /*bPreValidacao*/, /*bPosValid*/, {|oField| AuxLoad(oField)})

oModel:AddFields('USRDETAIL'	, 'XXPMASTER', oStruUSER, /*bPreValidacao*/, /*bPosValid*/, {|| UserLoad() })
oModel:GetModel('USRDETAIL'):SetDescription("Usuario")

oModel:SetRelation('XXXDETAIL'	,{{'XXX_ID','XXP_ID'}},XXX->(IndexKey(1)))

oModelXXX := oModel:GetModel('XXXDETAIL')
oModelXXX:SetUniqueLine({"XXX_PROTOC"})
oModelXXX:SetNoInsertLine(.T.)

oModel:GetModel("AUXDETAIL"):SetOnlyQuery(.T.)

oModel:SetDescription( STR0001 )   
oModel:SetPrimaryKey( {"XXP_ID"} )
oModel:SetVldActive( { | oModel | CanUpdate( oModel ) } )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface

@author  TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel( 'CFGA050A' )
Local oStruXXP	:= DefStrView("XXP")
Local oStruXXX	:= DefStrView("XXX")
Local oStruAUX	:= DefStrAuxView()
Local oStruUSER := DefStrUser()
Local oView		:= Nil
Local nOperation := oModel:GetOperation()

oStruXXP:RemoveField('XXP_UPDATE')
oStruXXX:RemoveField('XXX_ID')

oView := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_XXP', oStruXXP, 'XXPMASTER' )
oView:AddGrid( 'VIEW_XXX', oStruXXX, 'XXXDETAIL' )
oView:AddField( 'VIEW_AUX', oStruAUX, 'AUXDETAIL' )
oView:AddField( 'VIEW_USER', oStruUSER, 'USRDETAIL' )

oView:AddOtherObject('ACTIONS',{|oPanel| ActionPanel(oPanel) })
oView:AddOtherObject('SPACE',{||})
oView:AddOtherObject('SRVAUX',{|oPanel| SrvAuxPanel(oPanel) })

oView:CreateHorizontalBox( 'TOP' , 30 )
oView:CreateHorizontalBox( 'BOTTOM1' , 25 )
oView:CreateHorizontalBox( 'SPACE' , 03 )
oView:CreateHorizontalBox( 'BOTTOM2' , 19 )
oView:CreateHorizontalBox( 'USER' , 23 )

oView:CreateVerticalBox( 'BOTTOMLEFT',  90, 'BOTTOM1' )
oView:CreateVerticalBox( 'BOTTOMRIGHT', 10, 'BOTTOM1' )

oView:CreateVerticalBox( 'BOTTOM2LEFT',  70, 'BOTTOM2' )
oView:CreateVerticalBox( 'BOTTOM2RIGHT', 30, 'BOTTOM2' )

oView:SetOwnerView( 'VIEW_XXP', 'TOP' )    
oView:SetOwnerView( 'VIEW_XXX', 'BOTTOMLEFT' )    
oView:SetOwnerView( 'ACTIONS', 'BOTTOMRIGHT' )   
oView:SetOwnerView( 'VIEW_AUX', 'BOTTOM2LEFT' )   
oView:SetOwnerView( 'SRVAUX', 'BOTTOM2RIGHT' )
oView:SetOwnerView( 'VIEW_USER', 'USER' )

oView:EnableTitleView("VIEW_XXP"	, "Host"		)
oView:EnableTitleView("VIEW_XXX"	, STR0003)
oView:EnableTitleView("ACTIONS"		, STR0004	)
oView:EnableTitleView("VIEW_AUX"	, STR0105	)//"Dados do Servidor Auxiliar"
oView:EnableTitleView("SRVAUX"		, STR0106	)//"Testar Conexão"
oView:EnableTitleView("VIEW_USER"	, "Usuario e Senha de Autenticação do WS" )

oView:SetCloseOnOk({||.T.})

FWModelActive( oModel )

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} DefStrModel
Monta um Struct para utilização da tabela XXP (Model)

@author TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function DefStrModel(cTable,aYesFields)

Local aArea		:= GetArea()
Local aAux		:= {}
Local aFields	:= {}
Local aIndex	:= {}
Local aTriggers := {}
Local bRelac	:= Nil
Local bValid	:= { ||.T.}
Local bWhen		:= Nil
Local cChave	:= ""
Local nX		:= 0
Local nLen

oStruct := FWFormModelStruct():New()

//-------------------------------------------------------------------
// Tabela  
//-------------------------------------------------------------------
If cTable == "XXP"
	oStruct:AddTable("XXP",FWXXPPrimary(),"Hosts")
	aIndex := FWXXPIndex()
	aFields := FWXXPFields()
ElseIf cTable == "XXX"
	oStruct:AddTable("XXX",FWXXXPrimary(),STR0003)
	aIndex := FWXXXIndex()
	aFields := FWXXXFields()
EndIf

//-------------------------------------------------------------------
// Indices
//-------------------------------------------------------------------


For nX := 1 to Len(aIndex)
	cChave :=""
	aEval( aIndex[nX][2], { |cX| cChave+= "+"+cX } ) 
	cChave := SubStr(cChave,2,Len(cChave))   

	oStruct:AddIndex( 		;
	nX						,;	// [01] Ordem do indice
	"XXP"+StrZero(nX,2)		,;	// [02] ID
	cChave					,;	// [03] Chave do indice
	""						,;	// [04] Descrição do indice
	""						,;	// [05] Expressão de lookUp dos campos de indice
	""						,;	// [06] Nickname do indice
	.T.						)	// [07] Indica se o indice pode ser utilizado pela interface

Next nX

//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------

For nX := 1 to Len(aFields)

	If aYesFields <> Nil .AND. aScan(aYesFields,AllTrim(aFields[nX][1])) == 0
		Loop
	EndIf
	
	nLen := Len(aFields[nX])
	cGSC     := 'GET'
	bRelac := If(nLen > 12,aFields[nX][13],Nil)
	bValid := If(nLen > 13,aFields[nX][14],Nil)
	bWhen := If(nLen > 15,aFields[nX][16],Nil)
	
	oStruct:AddField(			;
	AllTrim( aFields[nX][2] )	,;		// [01] Titulo do campo
	AllTrim( aFields[nX][2] )	,;		// [02] ToolTip do campo
	AllTrim( aFields[nX][1] )	,;		// [03] Id do Field
	aFields[nX][3]				,;		// [04] Tipo do campo
	aFields[nX][4]				,;		// [05] Tamanho do campo
	aFields[nX][5]				,;		// [06] Decimal do campo
	bValid						,;		// [07] Code-block de validação do campo
	bWhen						,;		// [08] Code-block de validação When do campo
	{}							,;		// [09] Lista de valores permitido do campo
	bRelac						,;		// [11] Code-block de inicializacao do campo
	NIL							,;		// [12] Indica se trata-se de um campo chave
	NIL							,;		// [13] Indica se o campo pode receber valor em uma operação de update.
	aFields[nX][9]				)		// [14] Indica se o campo é virtual

Next nX

For nX := 1 To Len(aTriggers)
	If aYesFields <> Nil .AND. aScan(aYesFields,AllTrim(aTriggers[nX][1])) == 0
		Loop
	EndIf

	oStruct:AddTrigger(aTriggers[nX][1],aTriggers[nX][2],aTriggers[nX][3],aTriggers[nX][4])
Next

RestArea( aArea )

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} DefStrView
Monta um Struct para utilização da tabela XXP (View)

@author TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function DefStrView(cTable,aYesFields)

Local aFields	:= {}
Local cGSC      := ''
Local nX        := 0
Local oStruct   := FWFormViewStruct():New()
Local uLookUp

If cTable == "XXP"
	aFields	:= FWXXPFields()
ElseIf cTable == "XXX"
	aFields	:= FWXXXFields()
EndIf

//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------

For nX := 1 to Len(aFields)

	If !aFields[nX][11]
		Loop
	EndIf
	
	If aYesFields <> Nil .AND. aScan(aYesFields,AllTrim(aFields[nX][1])) == 0
		Loop
	EndIf
	
	If ValType(aFields[nX][12]) == "A"
		cGSC := "COMBO"
	Else
		cGSC := 'GET'
	EndIf
	
	uLookUp := If(Len(aFields[nX]) > 14,aFields[nX][15],Nil)

	oStruct:AddField( ;
	AllTrim( aFields[nX][1] ),;		// [01] Campo
	StrZero(nX,2)				,;		// [02] Ordem
	AllTrim( aFields[nX][2] ),;		// [03] Titulo
	AllTrim( aFields[nX][2] ),;		// [04] Descricao
	NIL							,;		// [05] Help
	cGSC						,;		// [06] Tipo do campo   COMBO, Get ou CHECK
	aFields[nX][6]			,;		// [07] Picture
	Nil							,;		// [08] PictVar
	uLookUp					,;		// [09] F3
	!aFields[nX][8]			,;		// [10] Editavel
	""							,;		// [11] Folder
	"" 							,;		// [12] Group
	aFields[nX][12]			,;		// [13] Lista Combo
	0							,;		// [14] Tam Max Combo
	""							,;		// [15] Inic. Browse
	aFields[nX][9] 			)		// [16] Virtual

Next nX

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} DefStrAuxModel
Monta um Struct sem tabela, que será utilizado apenas para visualização (Model)
Fields da conexão com o servidor auxiliar

@author TOTVS
@since 14/12/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DefStrAuxModel()
Local oStruct := FWFormModelStruct():New()

oStruct:AddTable('AUX',{},STR0087)

oStruct:AddField( ;
'IP', ;				// [01] Titulo do campo
STR0086, ;		// [02] ToolTip do campo
'AUX_IP', ;			// [03] Id do Field
'C', ;					// [04] Tipo do campo
020, ;					// [05] Tamanho do campo
0, ;					// [06] Decimal do campo
/*bValid*/, ;			// [07] Code-block de validação do campo
/*bWhen*/, ;			// [08] Code-block de validação When do campo
/*aValues*/, ;		// [09] Lista de valores permitido do campo
/*lObrigat*/, ;		// [10] Indica se o campo tem preenchimento obrigatório
/*bRelac*/, ;			// [11] Code-block de inicializacao do campo
/*lKey*/, ;			// [12] Indica se trata-se de um campo chave
/*lNoUpd*/, ; 		// [13] Indica se o campo pode receber valor em uma operação de update.
/*lVirtual*/)			// [14] Indica se o campo é virtual

oStruct:AddField( ;
'Porta', ;				// [01] Titulo do campo
STR0085, ;		// [02] ToolTip do campo
'AUX_PORT', ;			// [03] Id do Field
'C',;					// [04] Tipo do campo
006, ;					// [05] Tamanho do campo
0, ;					// [06] Decimal do campo
/*bValid*/, ;			// [07] Code-block de validação do campo
/*bWhen*/, ;			// [08] Code-block de validação When do campo
/*aValues*/, ;		// [09] Lista de valores permitido do campo
/*lObrigat*/, ;		// [10] Indica se o campo tem preenchimento obrigatório
/*bRelac*/, ;			// [11] Code-block de inicializacao do campo
/*lKey*/, ;			// [12] Indica se trata-se de um campo chave
/*lNoUpd*/, ; 		// [13] Indica se o campo pode receber valor em uma operação de update.
/*lVirtual*/)			// [14] Indica se o campo é virtual

oStruct:AddField( ;
STR0016, ;		// [01] Titulo do campo
STR0084, ;		// [02] ToolTip do campo
'AUX_ENV', ;			// [03] Id do Field
'C',;					// [04] Tipo do campo
020, ;					// [05] Tamanho do campo
0, ;					// [06] Decimal do campo
/*bValid*/, ;			// [07] Code-block de validação do campo
/*bWhen*/, ;			// [08] Code-block de validação When do campo
/*aValues*/, ;		// [09] Lista de valores permitido do campo
/*lObrigat*/, ;		// [10] Indica se o campo tem preenchimento obrigatório
/*bRelac*/, ;			// [11] Code-block de inicializacao do campo
/*lKey*/, ;			// [12] Indica se trata-se de um campo chave
/*lNoUpd*/, ; 		// [13] Indica se o campo pode receber valor em uma operação de update.
/*lVirtual*/)			// [14] Indica se o campo é virtual


Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} UserModel
Monta um Struct sem tabela, que será utilizado apenas para visualização (Model)
Fields de usuario e senha de autenticação do WS

@author Bruno Almeida
@since 15/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function UserModel()
Local oStruct := FWFormModelStruct():New()

oStruct:AddField( ;
	'Usuário', ;		// [01] Titulo do campo
	'Usuário', ;		// [02] ToolTip do campo
	'USR_USER', ;		// [03] Id do Field
	'C', ;				// [04] Tipo do campo
	30, ;				// [05] Tamanho do campo
	0, ;				// [06] Decimal do campo
	/*bValid*/, ;		// [07] Code-block de validação do campo
	/*bWhen*/, ;		// [08] Code-block de validação When do campo
	/*aValues*/, ;		// [09] Lista de valores permitido do campo
	/*lObrigat*/, ;		// [10] Indica se o campo tem preenchimento obrigatório
	/*bRelac*/, ;		// [11] Code-block de inicializacao do campo
	/*lKey*/, ;			// [12] Indica se trata-se de um campo chave
	/*lNoUpd*/, ; 		// [13] Indica se o campo pode receber valor em uma operação de update.
	.T.;				// [14] Indica se o campo é virtual
)			

oStruct:AddField( ;
	'Senha', ;			// [01] Titulo do campo
	'Senha', ;			// [02] ToolTip do campo
	'USR_SENHA', ;		// [03] Id do Field
	'C',;				// [04] Tipo do campo
	20, ;				// [05] Tamanho do campo
	0, ;				// [06] Decimal do campo
	/*bValid*/, ;		// [07] Code-block de validação do campo
	/*bWhen*/, ;		// [08] Code-block de validação When do campo
	/*aValues*/, ;		// [09] Lista de valores permitido do campo
	/*lObrigat*/, ;		// [10] Indica se o campo tem preenchimento obrigatório
	/*bRelac*/, ;		// [11] Code-block de inicializacao do campo
	/*lKey*/, ;			// [12] Indica se trata-se de um campo chave
	/*lNoUpd*/, ; 		// [13] Indica se o campo pode receber valor em uma operação de update.
	.T.;				// [14] Indica se o campo é virtual
)			

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} DefStrAuxView
Monta um Struct sem tabela, que será utilizado apenas para visualização (View)
Fields da conexaão com o servidor auxiliar

@author TOTVS
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DefStrAuxView()
Local oStruct   := FWFormViewStruct():New()

oStruct:AddField( ;
'AUX_IP',;				// [01] Campo
'01',;					// [02] Ordem
'IP:',;				// [03] Titulo
'IP',;					// [04] Descricao
/*aHelp*/,;			// [05] Help
'CHECK',;				// [06] Tipo do campo   COMBO, Get ou CHECK
/*cPicture*/,;		// [07] Picture
/*bPictVar*/,;		// [08] PictVar
/*cLookUp*/,;			// [09] F3
.T.,;					// [10] Editavel
/*cFolder*/,;			// [11] Folder
/*cGroup*/;			// [12] Group
/*aComboValues*/,;	// [13] Lista Combo
/*nMaxLenCombo*/,;	// [14] Tam Max Combo
/*cIniBrow*/)			// [15] Inic. Browse

oStruct:AddField( ;
'AUX_PORT',;			// [01] Campo
'02',;					// [02] Ordem
STR0015+":",;				// [03] Titulo
STR0015+":",;				// [04] Descricao
/*aHelp*/,;			// [05] Help
'GET',;				// [06] Tipo do campo   COMBO, Get ou CHECK
'@!',;					// [07] Picture
/*bPictVar*/,;		// [08] PictVar
/*cLookUp*/,;			// [09] F3
/*lCanChange*/,;		// [10] Editavel
/*cFolder*/,;			// [11] Folder
/*cGroup*/;			// [12] Group
/*aComboValues*/,;	// [13] Lista Combo
/*nMaxLenCombo*/,;	// [14] Tam Max Combo
/*cIniBrow*/)			// [15] Inic. Browse

oStruct:AddField( ;
'AUX_ENV',;			// [01] Campo
'03',;					// [02] Ordem
STR0016+":",;		// [03] Titulo
STR0016+":",;		// [04] Descricao
/*aHelp*/,;			// [05] Help
'GET',;				// [06] Tipo do campo   COMBO, Get ou CHECK
'@!',;					// [07] Picture
/*bPictVar*/,;		// [08] PictVar
/*cLookUp*/,;			// [09] F3
/*lCanChange*/,;		// [10] Editavel
/*cFolder*/,;			// [11] Folder
/*cGroup*/;			// [12] Group
/*aComboValues*/,;	// [13] Lista Combo
/*nMaxLenCombo*/,;	// [14] Tam Max Combo
/*cIniBrow*/)			// [15] Inic. Browse
Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} DefStrUser
Monta um Struct sem tabela, que será utilizado apenas para visualização (View)
Alteração de usuario e senha do host

@author Bruno Almeida
@since 15/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DefStrUser()

Local oStruct   := FWFormViewStruct():New()

oStruct:AddField( ;
	'USR_USER',;		// [01] Campo
	'01',;				// [02] Ordem
	'Usuario:',;		// [03] Titulo
	'Usuario',;			// [04] Descricao
	{"Informe o usuário da retaguarda para realizar a autenticação do WebService do Host."},; // [05] Help
	'GET',;				// [06] Tipo do campo   COMBO, Get ou CHECK
	/*cPicture*/,;		// [07] Picture
	/*bPictVar*/,;		// [08] PictVar
	/*cLookUp*/,;		// [09] F3
	.T.,;				// [10] Editavel
	/*cFolder*/,;		// [11] Folder
	/*cGroup*/;			// [12] Group
	/*aComboValues*/,;	// [13] Lista Combo
	/*nMaxLenCombo*/,;	// [14] Tam Max Combo
	/*cIniBrow*/; 		// [15] Inic. Browse
)			

oStruct:AddField( ;
	'USR_SENHA',;		// [01] Campo
	'02',;				// [02] Ordem
	"Senha:",;			// [03] Titulo
	"Senha:",;			// [04] Descricao
	{"Informe a senha do usuário."},; // [05] Help
	'GET',;				// [06] Tipo do campo   COMBO, Get ou CHECK
	'@*',;				// [07] Picture
	/*bPictVar*/,;		// [08] PictVar
	/*cLookUp*/,;		// [09] F3
	.T.,;				// [10] Editavel
	/*cFolder*/,;		// [11] Folder
	/*cGroup*/;			// [12] Group
	/*aComboValues*/,;	// [13] Lista Combo
	/*nMaxLenCombo*/,;	// [14] Tam Max Combo
	/*cIniBrow*/; 		// [15] Inic. Browse
)			

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateSeek
Cria as chaves de pesquisa do Seek no FWFormBrowse

@param   oStruct Estrutura da tabela XXP associada ao Model

@author TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function CreateSeek(oStruct)

Local aSeek := {}

Aadd( aSeek,{ 	oStruct:GetProperty( "XXP_ID", MODEL_FIELD_TITULO ), ;
				{	{"",;
					oStruct:GetProperty( "XXP_ID", MODEL_FIELD_TIPO    ), ;
					oStruct:GetProperty( "XXP_ID", MODEL_FIELD_TAMANHO ), ;
					oStruct:GetProperty( "XXP_ID", MODEL_FIELD_DECIMAL ), ;
					oStruct:GetProperty( "XXP_ID", MODEL_FIELD_TITULO  )}}})

Aadd( aSeek,{ 	oStruct:GetProperty( "XXP_FATHER", MODEL_FIELD_TITULO ), ;
				{	{"",;
					oStruct:GetProperty( "XXP_FATHER", MODEL_FIELD_TIPO    ), ;
					oStruct:GetProperty( "XXP_FATHER", MODEL_FIELD_TAMANHO ), ;
					oStruct:GetProperty( "XXP_FATHER", MODEL_FIELD_DECIMAL ), ;
					oStruct:GetProperty( "XXP_FATHER", MODEL_FIELD_TITULO  )}}})

Return aSeek

//-------------------------------------------------------------------
/*/{Protheus.doc} CFGA050AWizard
Wizard para cadastro de um novo Host, vinculando-o à máquina local

@param   cAlias Alias da tabela de Hosts
@param   nRecno Registro atual da tabela de hosts
@param   nOpc Código da opção selecionada no browse

@author TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Function CFGA050AWizard(cAlias,nRecno,nOpc)
Local i
Local cTitle		:= STR0021
Local lConfirm := .F.
Local cLocalID := PadR(GetPvProfString("FwCommunication","ID","",GetAdv97()),19)
Local cDesc		:= Space(50)
Local aHeadSrv	:= {}
Local aHeadLoc	:= {}
Local aColsSrv	:= {}
Local aColsLoc	:= {}
Local aBrwFun		:= {}
Local aParamFun
Local cProfile	:= ""
Local oWizard		:= Nil
Local oGetDLoc	:= Nil
Local oPanel		:= Nil
Local oEnv			:= Nil
Local oCmbConLoc	:= Nil
Local oFatherHost	:= Nil
Local lPosLight	:= FwPosLight()
Local nRdServer	:= If(lPosLight,2,1)
Local bFinish		:= {|| lConfirm := .T. }
Local lYesNo := .T.
Local bAction := {||}
Local oBrwPanel
Local oBrwFun
Local oColumn
Local lNext

Local oIP
Local oPort
Local oCmbConSrv
Local lOk			:= .F.
Local aConn		:= {"1=HTTP","2=RPC","3=WebService"}
Local oGetDSrv
Local oProfile
Local cIP			:= Space(40)
Local cPort		:= Space(6)
Local cEnv			:= Space(60)
Local cSrvConTp	:= ""
Local nSrvConTp	:= 0
Local aProtocols
Local lReplica := GetPvProfString("FwCommunication","Replica","0",GetAdv97()) == "1"

Local oIPLocal
Local oIPMain			
Local oPortMain	
Local oEnvMain
Local cIPMain		:= Padr(GetServerIP(),15)
Local cIPSec		:= Space(15)
Local cPortMain	:=  AllTrim(GetPvProfString("TCP","PORT","0",GetAdv97()))
Local cEnvMain	:= GetEnvServer()
Local oIPAux		
Local oPortAux	
Local oEnvAux		
Local cPortAux		:= Space(6)
Local cEnvAux			:= Space(30)
Local cConnStatus := Space(200)
Local lAux := .F.
Local oFont
Local aBrowse := {}
Local oSchedule
Local oFWUISchedulePersist
Local aEmpFil := {}
Local nIPType := 1 
Local lMobile := FindFunction("STFIsMobile") .AND. STFIsMobile() //Valida versao mobile
Local oButPesq := Nil //Botão Pesquisar
Local lEdtIp	:= .T. //Habilitado edição do IP?

Local oUser := Nil 			//Objeto para criação do edit do usuario
Local cUser := Space(20) 	//Variavel para receber o usuario
Local oPwd	:= Nil 			//Objeto para criação do edit da senha
Local cPwd	:= Space(20)	//Variavel para receber a senha

If lMobile //Mobile somente WS
	aConn  := {"3=WebService"}
EndIf

//Valida a execucao do Wizard
If !Empty(cLocalID)
	XXP->(DbSetOrder(1))
	If XXP->(DbSeek(cLocalID))
		If lReplica
			cProfile := XXP->XXP_PROFIL
			oFatherHost := FwHost():New()
			oFatherHost:load(XXP->XXP_FATHER)
			cIP := Padr(oFatherHost:getIP(),40)

			aProtocols:= oFatherHost:getAllProtocols()
			For i := 1 To Len(aProtocols)
				If aProtocols[i]:isEnabled()
					nSrvConTp := aProtocols[i]:getProtocolId()
					cPort := Padr(cValToChar(aProtocols[i]:getPort()),6)
					cEnv := Padr(aProtocols[i]:getEnvironment(),60)
					Exit
				EndIf
			Next
		Else
			Help( ,, 'HELP',, I18n(STR0019,{cLocalID}), 1, 0)
			Return .F.
		EndIf
	EndIf
EndIf

PrepareGrids(@aHeadSrv,@aHeadLoc,@aColsSrv,@aColsLoc,@aBrwFun)

oWizard := ApWizard():New(cTitle,STR0020,STR0021,STR0022,{|| .T. },bFinish,.T.,/*cResHead*/,/*bExecute*/,.F.,{0,0,490,710})
				
oWizard:newPanel( cTitle, STR0023, {||.T.}, ; 
	{|| lNext := VldLocal(@oGetDLoc,cDesc,cIPMain,Val(cPortMain),cEnvMain)}, bFinish, .F., {||.T.} )

oWizard:newPanel( cTitle, STR0024, {||.T.}, {|| lNext := .T., aParamFun := Aclone(aBrwFun),.T.}, bFinish, .F., ; 
	{|| If(nRdServer == 1,,oWizard:SetPanel(If(lNext,4,2))), .T.} )

oWizard:newPanel( cTitle, STR0025, {|| lNext := .F.,.T.}, ;
	{|| VldParent(cIP, lOk, cProfile)}, bFinish, .F., {||If(nRdServer == 1,oWizard:SetPanel(If(lNext,7,2)),),.T.} )

oWizard:newPanel( cTitle, STR0063, {|| .T.}, ;
	{|| .T. }, bFinish, .F., {||.T.} )

oWizard:newPanel( cTitle, STR0026, {||.T.}, {||VldSched(oFWUISchedulePersist,@oSchedule)}, bFinish, .F., ;
	{|| If(nRdServer == 1,oWizard:SetPanel(3),(If(oFWUISchedulePersist == NIL,oFWUISchedulePersist := ConfigSched( ;
		@oSchedule,FUNCTIONUPDATE, SCHEDMODULE,oWizard:GetPanel(6),AllTrim(UPPER(cEnvAux))),)))} )

oWizard:newPanel( cTitle, STR0096, {||.T.}, {|| .T. }, {|| lConfirm := VldEmpFil(aBrowse,aEmpFil) }, .F., ;
	{|| .T. } )


lEdtIp  := nIPType=2

//Painel para selecionar o servidor e com informacoes do host local
oPanel := oWizard:GetPanel(2)

@ 005,007 TO 65,345 PROMPT STR0027 PIXEL OF oPanel

@ 015,015 RADIO nRdServer ITEMS STR0028, STR0029 OF oPanel SIZE 100,100 PIXEL WHEN !lPosLight

@ 037,015 SAY STR0009 PIXEL OF oPanel
@ 047,015 MSGET cDesc OF oPanel SIZE 150,10 PIXEL

@ 015,175 RADIO nIPType ITEMS STR0102, STR0103 ON CHANGE (if(lEdtIp := (nIPType=2),oIPLocal:Enable(),oIPLocal:Disable())) OF oPanel SIZE 100,100 PIXEL // "IP dinâmico" ### "IP estático"

@ 037,175 SAY STR0099 OF oPanel PIXEL SIZE 70,10 // "Endereço IP"
@ 047,175 MSGET oIPLocal VAR cIPMain OF oPanel SIZE 70,10 PIXEL WHEN lEdtIp

oIPLocal:bF3 := {|| cIPMain := Padr(GetServerIP(),Len(cIPMain)),oIPLocal:Refresh(),.T.}

@ 037,255 SAY STR0104 OF oPanel PIXEL SIZE 70,10 // "Endereço IP Secundário"
@ 047,255 MSGET cIPSec OF oPanel SIZE 70,10 PIXEL

@ 067,007 TO 152,345 PROMPT STR0030 PIXEL OF oPanel
@ 079,015 SAY STR0031 OF oPanel PIXEL SIZE 200,9

oGetDLoc := MsNewGetDados():New(089,015,145,340,GD_UPDATE,/*cLinhaOk*/,/*cTudoOk*/,/*cIniCpos*/,;
	{"XXX_UP","XXX_DOWN","XXX_ENABLE","XXX_PORT","XXX_ENV"},/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,;
	oPanel,aHeadLoc,aColsLoc,/*uChange*/,/*cTela*/)
	
oGetDLoc:AddAction("XXX_UP",{||TrocaLinha(oGetDLoc,-1),"UP3"})
oGetDLoc:AddAction("XXX_DOWN",{||TrocaLinha(oGetDLoc,1),"DOWN3"})


//Painel para selecionar as funcionalidades
oPanel := oWizard:GetPanel(3)
		
@ 005,007 TO 150,345 PROMPT STR0032 PIXEL OF oPanel

@ 18,15 MSPANEL oBrwPanel SIZE 325,125 LOWERED OF oPanel

DEFINE FWBROWSE oBrwFun DATA ARRAY ARRAY aBrwFun NO LOCATE NO REPORT NO CONFIG OF oBrwPanel

ADD MARKCOLUMN oColumn DATA {|oBrowse| If(aBrwFun[oBrwFun:At()][1],'LBOK','LBNO')} DOUBLECLICK {|| aBrwFun[oBrwFun:At()][1] := !aBrwFun[oBrwFun:At()][1]}  HEADERCLICK { |oBrowse| MarkAllFunc(oBrowse,aBrwFun) } OF oBrwFun
ADD COLUMN oColumn DATA {|| aBrwFun[oBrwFun:At()][2]} TITLE 'ID' SIZE 10 OF oBrwFun
ADD COLUMN oColumn DATA {|| aBrwFun[oBrwFun:At()][3]} TITLE STR0009 SIZE 100 OF oBrwFun

oBrwFun:Activate()	


//Painel com informacoes do host pai
oPanel := oWizard:GetPanel(4)

@ 005,007 TO 170,345 PROMPT STR0033 OF oPanel PIXEL

@ 015,015 SAY STR0034 OF oPanel PIXEL SIZE 90,9
@ 025,015 MSGET oIP VAR cIP OF oPanel SIZE 90,10 PIXEL

// A porta sera informada diretamente na URL do WebService
@ 015,110 SAY STR0015 OF oPanel PIXEL SIZE 50,10  //"Porta
@ 025,110 MSGET oPort VAR cPort OF oPanel SIZE 50,10 PIXEL WHEN cSrvConTp <> cValToChar(CON_WS) 
	
@ 015,165 SAY STR0035 OF oPanel PIXEL SIZE 50,9 //"Protocolo inicial"
@ 025,165 COMBOBOX oCmbConSrv VAR cSrvConTp ITEMS aConn SIZE 50,10 OF oPanel PIXEL
If nSrvConTp > 0
	oCmbConSrv:nAt := nSrvConTp
EndIf

@ 015,220 SAY STR0036 OF oPanel PIXEL SIZE 140,10 // "Ambiente (apenas para RPC)"
@ 025,220 MSGET oEnv VAR cEnv OF oPanel SIZE 80,10 PIXEL WHEN cSrvConTp == cValToChar(CON_RPC) // Apenas para RPC

@ 050,620 BTNBMP oButPesq RESOURCE "RELOAD" SIZE 030,030 OF oPanel PIXEL; 
	ACTION FWMsgRun(Nil,{|| SaveUser(AllTrim(cUser), AllTrim(cPwd)), lOk := TestConnection(cIP,cPort,cEnv, Val(SubStr(AllTrim(cSrvConTp),1,1)),@oFatherHost,@oGetDSrv)},/*'cHeader'*/,STR0038)
		
oButPesq:cToolTip  := STR0037

If lMobile
	oButPesq:SetCSS( POSCSS (GetClassName(oButPesq), CSS_BTN_LUPA ))
EndIf	

@ 042,015 SAY "Usuário:" OF oPanel PIXEL SIZE 100,10
@ 052,015 MSGET oUser VAR cUser OF oPanel SIZE 90,10 PIXEL

@ 042,110 SAY "Senha:" OF oPanel PIXEL SIZE 100,10
@ 052,110 MSGET oPwd VAR cPwd PASSWORD OF oPanel SIZE 80,10 PIXEL

//Informação
@ 046,195 SAY "Os campos usuário e senha são necessarios apenas a partir da relese 12.1.33, caso" +;
				" contrário deixe os campos vazio. Saiba mais em: https://tdn.totvs.com/pages/viewpage.action?pageId=640207780" OF oPanel PIXEL SIZE 130,35

@ 070,015 SAY STR0039 OF oPanel PIXEL SIZE 100,10

oGetDSrv := MsNewGetDados():New(80,015,135,340,0,/*cLinhaOk*/,/*cTudoOk*/,/*cIniCpos*/,	/*aAlter*/,;
	/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,oPanel,aHeadSrv,aColsSrv,/*uChange*/,/*cTela*/)

@ 140,015 SAY STR0040 OF oPanel PIXEL SIZE 70,10
@ 150,015 MSGET oProfile VAR cProfile OF oPanel SIZE 80,10 PIXEL 
oProfile:lHasButton := .T.
oProfile:bF3 := {|| ConsProfile(@cProfile), oProfile:Refresh(), oPanel:Refresh()}

//Painel com informacoes do host pai
oPanel := oWizard:GetPanel(5)

@ 010,007 TO 100,172 PROMPT STR0065 PIXEL OF oPanel

@ 020,015 SAY STR0099 OF oPanel PIXEL SIZE 90,9 // "Endereço IP"
@ 030,015 MSGET oIPMain VAR cIPMain OF oPanel SIZE 90,10 PIXEL

// A porta sera informada diretamente na URL do WebService
@ 045,015 SAY STR0015 OF oPanel PIXEL SIZE 50,10
@ 055,015 MSGET oPortMain VAR cPortMain OF oPanel SIZE 50,10 PIXEL //WHEN cSrvConTp <> cValToChar(CON_WS) 

@ 070,015 SAY STR0036 OF oPanel PIXEL SIZE 70,10
@ 080,015 MSGET oEnvMain VAR cEnvMain OF oPanel SIZE 80,10 PIXEL// WHEN cSrvConTp == cValToChar(CON_RPC) // Apenas para RPC

oIPMain:Disable()
oPortMain:Disable()
oEnvMain:Disable()

@ 010,180 TO 100,343 PROMPT STR0066 PIXEL OF oPanel

cPortAux :=  AllTrim(GetPvProfString("FWCOMMUNICATION","AUXPORT","",GetAdv97())) 
cEnvAux :=  AllTrim(GetPvProfString("FWCOMMUNICATION","AUXENV","",GetAdv97())) 

cPortAux := Padr(cPortAux,LEN(XXX->XXX_PORT))
cEnvAux := Padr(cEnvAux,LEN(XXX->XXX_ENV))

@ 020,188 SAY STR0099 OF oPanel PIXEL SIZE 90,9 // "Endereço IP"
@ 030,188 MSGET oIPAux VAR cIPMain OF oPanel SIZE 90,10 PIXEL
oIPAux:Disable()

// A porta sera informada diretamente na URL do WebService
@ 045,188 SAY STR0015 OF oPanel PIXEL SIZE 50,10
@ 055,188 MSGET oPortAux VAR cPortAux OF oPanel SIZE 50,10 PICTURE "@9999" PIXEL //WHEN cSrvConTp <> cValToChar(CON_WS) 

@ 070,188 SAY STR0036 OF oPanel PIXEL SIZE 70,10
@ 080,188 MSGET oEnvAux VAR cEnvAux OF oPanel SIZE 80,10 PIXEL// WHEN cSrvConTp == cValToChar(CON_RPC) // Apenas para RPC

@ 110,007 TO 150,343 PROMPT STR0067 PIXEL OF oPanel

@ 125,015 BUTTON STR0068	SIZE 50, 12 ACTION FWMsgRun(Nil,{|| lAux := VldServers( cIPMain, cPortAux, cEnvAux, oConnSrv, @cConnStatus, .F. )},/*'cHeader'*/,STR0069) PIXEL OF oPanel
oFont := TFont():New('Arial',,-11,,.T.)
oConnSrv := TSay():New(125,080,{||cConnStatus},oPanel,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,255,20,,,,,,.T.)


oPanel := oWizard:GetPanel(7)
aBrowse := FWSM0_Panel(oPanel, FWEmpLoad(),,"",.F., .f.)

oWizard:activate( .T., /*bValid*/ , {||oWizard:oNext:SetFocus()}, /*<bWhen>*/ )

If lConfirm
	FWMsgRun( Nil, {|| SaveHost(cIPMain, cIPSec, cDesc,nRdServer,oSchedule,oFatherHost,oGetDLoc,aHeadLoc,aParamFun,cProfile,lReplica,aEmpFil,cPortAux,cEnvAux,nIPType)},/*'cHeader'*/, STR0044 )
EndIf
Return

Static Function SaveHost(cIP, cIPSec, cDesc,nRdServer,oSchedule,oFatherHost,oGetDLoc,aHeadLoc,aBrwFun,cProfile,lReplica,aEmpFil,cPortAux,cEnvAux,nIPType)
Local nX
Local oFatherAux
Local oHost  
Local oProtocol
Local cAuxIP
Local cAuxPort
Local cAuxEnv
Local oHostAux
Local oConn
Local aFun := {}
Local lRet := .F.
Local lYesNo := .T.

If nRdServer == 2 .and. !lReplica
	XA2->(DbGoTop())
	If !XA2->(Eof())
		lYesNo := MsgYesNo(STR0041)
	EndIf
	XXY->(DbGoTop())
	If !XXY->(Eof()) .AND. lYesNo
		lYesNo := MsgYesNo(STR0042)
	EndIf
EndIf

If !lYesNo
	Return .F.
EndIf

lWizard := .T.

//Cria o host atual
oHost := FwHost():New()
oHost:setIP(cIP)
oHost:setIPSecondary(cIPSec)
oHost:setDescription(cDesc)
oHost:setEmpFil(aEmpFil)

If nRdServer == 1
	//funcionalidades
	For nX := 1 To Len(aBrwFun)
		If aBrwFun[nX][1]
			Aadd(aFun,aBrwFun[nX][2])
		EndIf
	Next
	oHost:setIsFather(.T.)
	oHost:setIdProfile(oHostDAO:createMasterProfile(aFun))
Else
	oHost:setIdProfile(cProfile)
	oHost:setFather(oFatherHost)
	
	// salva funcionalidade e perfil
	CleanProfXFunc()
	oHostDAO:saveFunctionality(oFatherHost:getFunctionality())
	oHostDAO:saveProfile(oFatherHost:getAllProfiles())

	SaveNewSched(oSchedule, FUNCTIONUPDATE, "Special" )

	oFatherAux := oFatherHost
	While oFatherAux <> Nil
		oFatherAux:setIsFather(.T.)
		If !Empty(oFatherAux:getId())
			oHostDAO:save(oFatherAux)
		EndIf
		oFatherAux := oFatherAux:getFather()
	End
EndIf

//Descarga dos protocolos configurados
For nX := 1 to Len(oGetDLoc:aCols)
	oProtocol := FwProtocol():New()
	oProtocol:setProtocolId( Val(oGetDLoc:aCols[nX][aScan(aHeadLoc,{|x|AllTrim(x[2]) == "XXX_PROTOC" })]) )
	oProtocol:setPort( oGetDLoc:aCols[nX][aScan(aHeadLoc,{|x|AllTrim(x[2]) == "XXX_PORT" })] )
	oProtocol:setEnvironment( oGetDLoc:aCols[nX][aScan(aHeadLoc,{|x|AllTrim(x[2]) == "XXX_ENV" })] )
	oProtocol:setEnabled( oGetDLoc:aCols[nX][aScan(aHeadLoc,{|x|AllTrim(x[2]) == "XXX_ENABLE"})] == "1" )
	oHost:addProtocol( oProtocol )
Next nX

oHostDAO:setIPType(nIPType)

//Obtem o numero sequencial e salva no ini do server
lYesNo := .T.
While lYesNo
	If !Empty(oHost:registrate())
		If nRdServer == 2
			
			VldServers( cIP, cPortAux, cEnvAux, , , .T., nIPType ) 
			
			cAuxIP := AllTrim(GetPvProfString("FwCommunication","auxip","",GetAdv97()))
			cAuxPort := AllTrim(GetPvProfString("FwCommunication","auxport","",GetAdv97()))
			cAuxEnv := AllTrim(GetPvProfString("FwCommunication","auxenv","",GetAdv97()))
			If lReplica
				WritePProString("FwCommunication","Replica","0",GetAdv97())
			EndIf
			
			If !Empty(cAuxIP) .And. !Empty(cAuxPort) .And. !Empty(cAuxEnv)
				oHostAux := FwHostCreate(cAuxIP,cAuxPort,cAuxEnv,2)
				oConn := FwHostConnection():New( oHostAux )
				If oConn:connect()
					oConn:oCon:startJob("POSStartSchd",.F.,{cEmpAnt, cFilAnt, PadR(GetPvProfString("FwCommunication","ID","",GetAdv97()),19), __cUserID, cAuxEnv, PadR(GetPvProfString("FwCommunication","PREPAREIN","",GetAdv97()),19)})					
					oConn:disconnect()		
				EndIf
				FreeObj(oConn)
				FreeObj(oHostAux)
			EndIf
		EndIf
		
		lRet := .T.
		MsgInfo(STR0043) // "Host configurado com sucesso"
		lYesNo := .F.
	Else
		lYesNo := MsgYesNo(STR0045 + CRLF + "Tentar novamente?")
	EndIf
End
lWizard := .F.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldEmpFil
Valida o browse de empresa filial

@param   oGD Referência do objeto da GetDados
@param   nDirection Direção da troca ( < 0, para cima, > 0 para baixo)

@author TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function VldEmpFil(aBrowse,aEmpFil)
Local nI := 0
Local lRet := .F.

For nI := 1 to len(aBrowse)
	If ( aBrowse[nI][1] == "S" )
		aADD(aEmpFil,aBrowse[nI][2])
		aADD(aEmpFil,aBrowse[nI][3])
	EndIf
Next nI
If LEN(aEmpFil) > 0
	lRet := .T.
Else
	Help( ,, 'HELP',, STR0097, 1, 0)
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TrocaLinha
Troca a linha de um elemento da GetDados em uma direção

@param   oGD Referência do objeto da GetDados
@param   nDirection Direção da troca ( < 0, para cima, > 0 para baixo)

@author TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function TrocaLinha(oGD,nDirection)

Local nLinAtu	:= oGd:oBrowse:nAt
Local nMax		:= Len(oGd:aCols)
Local aBkp		:= Nil

If nDirection < 0 .AND. nLinAtu > 1
	//Move linha para cima
	aBkp := aClone(oGd:aCols[nLinAtu-1])
	aCols[nLinAtu-1]	:= aClone(aCols[nLinAtu])
	aCols[nLinAtu]		:= aClone(aBkp)
ElseIf nDirection > 0 .AND. nLinAtu < nMax
	//Move linha para baixo
	aBkp := aClone(oGd:aCols[nLinAtu+1])
	aCols[nLinAtu+1]	:= aClone(aCols[nLinAtu])
	aCols[nLinAtu]		:= aClone(aBkp)
EndIf

aBkp := Nil
oGd:Refresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PrepareGrids
Monta os arrays aCols e aHeader utilizados nas duas Getdados do Wizard

@param   aHeadSrv aHeader de protocolos do host pai
@param   aHeadLoc aHeader de protocolos do host local
@param   aColsSrv aCols de protocolos do host pai
@param   aColsLoc aCols de protocolos do host local

@author Norbert Waage Jr.
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function PrepareGrids(aHeadSrv, aHeadLoc, aColsSrv, aColsLoc, aBrwFun)

	Local aFieldsXXX:= FWXXXFields()
	Local nX		:= 0
	Local nCols		:= 0
	Local cCombo	:= ""
	Local cPort		:= ""
	Local lEnable	:= .F.
	Local aBkp := {}
	// Criacao do aHeader dos protocolos do superior
	For nX := 1 to Len(aFieldsXXX)
		If aFieldsXXX[nX][1] <> "XXX_ID"
			cCombo := ""
			If !Empty(aFieldsXXX[nX][12])
				aEval(aFieldsXXX[nX][12],{|cOpc|cCombo += cOpc+";" })
				cCombo := Substr(cCombo,1,Len(cCombo)-1)
			EndIf
			AAdd(aHeadSrv,{	aFieldsXXX[nX][2], aFieldsXXX[nX][1], aFieldsXXX[nX][6], aFieldsXXX[nX][4], aFieldsXXX[nX][5],;
							"", "?????????????? ", aFieldsXXX[nX][3], "", "R", cCombo })
		EndIf
	Next nX

	//Ajusta o nome apresentado em tela
	aHeadSrv[aScan(aHeadSrv,{|x|AllTrim(x[2])=="XXX_ENV"})][1] := STR0016 + " / URL(Web Service)"
	
	//Criacao do aCols que listara os protocolos do no superior
	nCols := Len(aHeadSrv)
	AAdd(aColsSrv,Array(nCols+1))
	For nX := 1 to Len(aHeadSrv)
		aColsSrv[1][nX] := Space(aHeadSrv[nX][4])
	Next nX
	aColsSrv[1][nCols+1] := .F.
	
	//Criacao do aHeader dos protocolos locais
	Aadd(aHeadLoc,{"-","XXX_UP"    ,"@BMP",1 ,0,"","","C","","","","",""})
	Aadd(aHeadLoc,{"+","XXX_DOWN"  ,"@BMP",1 ,0,"","","C","","","","",""})
	
	For nX :=1 to Len(aHeadSrv)
		If aHeadSrv[nX][2] <> "XXX_ORDER"
			AAdd(aHeadLoc,aClone(aHeadSrv[nX]))
		EndIf
	Next nX
	nCols := Len(aHeadLoc)
	
	//Criacao do aCols que armazenara os protocolos locais
	AAdd(aColsLoc,Array(nCols+1))
	
	aColsLoc[1][1] := "UP3"
	aColsLoc[1][2] := "DOWN3"
	aColsLoc[1][nCols+1] := .F.
	
	For nX := 3 to Len(aHeadLoc)
		aColsLoc[1][nX] := Space(aHeadLoc[nX][4])
	Next nX
	
	For nX := 1 to 3
		If nX > 1
			AAdd(aColsLoc,aClone(aColsLoc[1]))
		EndIf
		aColsLoc[nX][aScan(aHeadLoc,{|x| AllTrim(x[2])=="XXX_PROTOC"})]	:= cValToChar(nX)
				
		Do Case
			Case nX == CON_HTTP
				lEnable := GetPvProfString("HTTP","ENABLE","",GetAdv97()) == "1"
				cPort	:= GetPvProfString("HTTP","PORT","",GetAdv97())
			Case nX == CON_RPC
				lEnable := .T.
				cPort	:= GetPvProfString(GetPvProfString("DRIVERS","ACTIVE","",GetAdv97()),"PORT","",GetAdv97())
				aColsLoc[nX][aScan(aHeadLoc,{|x| AllTrim(x[2])=="XXX_ENV"})]	:= GetEnvServer()
			Case nX == CON_WS
				lEnable := .F.
				cPort	:= ""
		EndCase

		aColsLoc[nX][aScan(aHeadLoc,{|x| AllTrim(x[2])=="XXX_ENABLE"})]	:= Iif(lEnable,"1","2")
		aColsLoc[nX][aScan(aHeadLoc,{|x| AllTrim(x[2])=="XXX_PORT"})]		:= cPort
		
	Next nX
	
	//Inverte as duas primeiras posições de modo a trazer o RPC como primeira opção
	aBkp := aClone(aColsLoc[2])
	aColsLoc[2]	:= aClone(aColsLoc[1])
	aColsLoc[1]	:= aClone(aBkp)
	aBkp := Nil
	
	If Select('XA2') == 0
		FWOpenXA2()
	EndIf
	// array com funcionalidades
	If Select('XXY') == 0
		FWOpenXXY()
	EndIf
	aBrwFun := {}
	XXY->(DbSetOrder(1))
	XXY->(DbGoTop())
	XXY->(Dbeval({|| Aadd(aBrwFun,{.F.,XXY->XXY_ID,XXY->XXY_DESC})}))
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TestConnection
Testa a conexão e recupera o código do host a ser criado.

@param   cIP Ip do host pai 
@param   cPort Porta a ser utilizada na conexão
@param   cEnv Environment do RPC utilizado na conexão
@param   nConnType Id do protocolo utilizado (RPC, HTTP ou WS)
@param   oFatherHost Referência do objeto do host pai
@param   oGetDSrv Referência do objeto da getdados de protocolos do host pai

@author TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function TestConnection(cIP,cPort,cEnv,nConnType,oFatherHost,oGetDSrv)

Local lRet 		:= .F.

Local oSerial		:= nil

Local aProtocols	:= {}
Local aRefLine	:= {}

Local nX			:= 0
Local nPOrder		:= aScan(oGetDSrv:aHeader,{|x|AllTrim(x[2]) == "XXX_ORDER" })
Local nPEnabled		:= aScan(oGetDSrv:aHeader,{|x|AllTrim(x[2]) == "XXX_ENABLE" })
Local nPProtocol	:= aScan(oGetDSrv:aHeader,{|x|AllTrim(x[2]) == "XXX_PROTOC" })
Local nPPort		:= aScan(oGetDSrv:aHeader,{|x|AllTrim(x[2]) == "XXX_PORT" })
Local nPEnv		:= aScan(oGetDSrv:aHeader,{|x|AllTrim(x[2]) == "XXX_ENV" })

Local oConn 		:= nil
Local oHost		:= FwHost():New()
Local oProtocol	:= FwProtocol():New()
Local oErro		:= ErrorBlock({|e| ConnError(e)})

Local cSerial

If !Empty(cIP) .and. (nConnType <> CON_RPC .or. !Empty(cEnv))

	oProtocol:setEnvironment(AllTrim(cEnv))	
	oProtocol:setProtocolId(nConnType)	
	oProtocol:setPort(AllTrim(cPort))	

	oHost:setIp(AllTrim(cIP))
	oHost:addProtocol(oProtocol)
	
	oConn := FwHostConnection():New( oHost )

   	Begin Sequence	

		oConn:setRmtCompany(.T.)
		If oConn:connect()
			
			oSerial := FwHost():new()
			cSerial := oConn:runMethod(oSerial,"getSerial")
			oConn:disconnect()
			FreeObj(oConn)
			oSerial:Deserializer(cSerial)
	
			aProtocols:= oSerial:getAllProtocols()
			aProfile := oSerial:getAllProfiles()
			If Len(aProtocols) > 0
			
				aRefLine := aClone(oGetDSrv:aCols[1])
				oGetDSrv:aCols := {}
				
				For nX := 1 to Len(aProtocols)
					aadd(oGetDSrv:aCols,aClone(aRefLine))
					oGetDSrv:aCols[nX][nPOrder]		:= cValToChar(nX)
					oGetDSrv:aCols[nX][nPEnabled]	:= iif(aProtocols[nX]:isEnabled(),"1","2")
					oGetDSrv:aCols[nX][nPProtocol]	:= cValToChar(aProtocols[nX]:getProtocolId())
					oGetDSrv:aCols[nX][nPPort]		:= aProtocols[nX]:getPort()
					oGetDSrv:aCols[nX][nPEnv]		:= aProtocols[nX]:getEnvironment()
				Next nX		
	
				oGetDSrv:GoTo(1)
				oGetDSrv:Refresh()
			
			EndIf
			
			// testa novamente a conexão mas com a configuração enviada pelo superior
			oConn := FwHostConnection():New(oSerial)
			If oConn:connect()
				oConn:disconnect()
				oFatherHost := oSerial
				lRet := .T.
			Else
				Help( ,, 'HELP',, STR0045+CRLF+STR0101+CRLF+STR0099+' '+oSerial:getIP()+CRLF+oSerial:getIPSecondary(), 1, 0) //"Não foi possível estabelecer conexão com o host" ### "Os dados informados diferem da configurada no host superior" ### "Endereço IP"
				FreeObj(oSerial)
			EndIf
			FreeObj(oConn)

		Else
			Help( ,, 'HELP',, STR0045, 1, 0) //"Não foi possível estabelecer conexão com o host"
		EndIf

    End Sequence
    ErrorBlock(oErro)
EndIf

FreeObj(oHost)
oHost := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ConnError
Funcao acionada caso a conexao provoque uma exceção

@param   e Objeto do erro

@author TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function ConnError(e)

If e:gencode > 0
	Help( ,, 'HELP',, STR0046 + CRLF + e:Description, 1, 0) // "Erro ao estabelecer a conexão:"
	BREAK
EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} VldLocal
Validação da configuracao local

@param oGetDLoc Referência do objeto da GetDados

@return lRet Indica se o wizard foi validado

@author TOTVS
@since 24/04/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function VldLocal(oGetDLoc,cDesc,cIP,nPort,cEnv)

	Local i
	Local nPosPrt		:= aScan(oGetDLoc:aHeader,{|x| AllTrim(x[2]) == "XXX_PORT"	 	})
	Local nPosProt	:= aScan(oGetDLoc:aHeader,{|x| AllTrim(x[2]) == "XXX_PROTOC" 	})
	Local nPosEnv		:= aScan(oGetDLoc:aHeader,{|x| AllTrim(x[2]) == "XXX_ENV" 		})
	Local nPosEnable	:= aScan(oGetDLoc:aHeader,{|x| AllTrim(x[2]) == "XXX_ENABLE" 	})
	Local nX			:= 0
	Local cMsg			:= '' 
	Local oRPC
	Local aRPCInfo
	Local aInfo
	Local bError
	Local nLen:=0
	
	If Empty(cDesc) .or. Empty(cIP)
		cMsg := STR0098 // "Informe o Nome e Endereço IP"
	Else
	
		// valida IP informado
		oRPC := TRPC():New(AllTrim(cEnv))
		CursorWait()
		If oRPC:Connect(AllTrim(cIP), nPort)
			
			bError := ErrorBlock({|e| RPCHandle(e), cMsg := STR0100}) // "Endereço IP inválido"
			BEGIN SEQUENCE
			aRPCInfo := oRPC:CallProc("GetSrvInfo")
			END SEQUENCE
			ErrorBlock(bError)
			
			
			oRPC:Disconnect()
			FreeObj(oRPC)
			
			If Empty(cMsg)
				aInfo := &("GetSrvInfo()") //Add Macro execução para evitar erro
				nLen:=Len(aInfo)
				iif(nLen>8,nLen:=8,)
				For i := 1 To nLen
					If aInfo[i] != aRPCInfo[i]
						cMsg := STR0100 // "Endereço IP inválido"
						Exit
					EndIf
				Next
				
				Asize(aRPCInfo,0)
				Asize(aInfo,0)
			EndIf
			CursorArrow()
		Else
			CursorArrow()
			cMsg := STR0100 // "Endereço IP inválido"
		EndIf
		
		If Empty(cMsg)
			//Valida se as portas foram informadas
			For nX := 1 to Len(oGetDLoc:aCols)
				If oGetDLoc:aCols[nX][nPosEnable] == "1"
					If Empty(oGetDLoc:aCols[nX][nPosPrt]) .AND. Val(oGetDLoc:aCols[nX][nPosProt]) <> CON_WS
						cMsg := I18n(STR0047,{cValToChar(nX)})
						Exit
					EndIf
					If Val(oGetDLoc:aCols[nX][nPosProt]) == CON_RPC .AND. Empty(oGetDLoc:aCols[nX][nPosEnv])
						cMsg := I18n(STR0048,{cValToChar(nX)})
						Exit
					EndIf
					If Val(oGetDLoc:aCols[nX][nPosProt]) == CON_WS .AND. !("http://" $ Lower(oGetDLoc:aCols[nX][nPosEnv]))
						cMsg := I18n(STR0049 +" http://127.0.0.1/ws",{cValToChar(nX)})
						Exit
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf
	
	If !Empty(cMsg)
		Help( ,, 'HELP',, cMsg, 1, 0)
		Return .F.
	EndIf
Return .T.

Static Function VldParent(cIP, lOk, cProfile)
Local lRet := .T.

If Empty(cIP) .or. !lOk
	Help( ,, 'HELP',, STR0050, 1, 0)
	lRet := .F.
ElseIf Empty(cProfile)
	Help( ,, 'HELP',, STR0051, 1, 0)
	lRet := .F.
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldServers
Função responsável por validar a conexão com o servidor auxiliar
e seus possíveis erros de configuração

@param cIPAux			IP do servidor auxiliar
@param cPortAux		Porta do servidor auxiliar
@param cEnvAux		Ambiente do servidor auxiliar
@param oConnSrv		Objeto TSAY que atualiza o log de status
@param cConnStatus	Variável que recebe o conteúdo do status da conexão
@param lUpdate		Indica se será salvo no .ini

@return clRet		Sucesso ou falha de conexão

@author TOTVS
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldServers( cIPAux, cPortAux, cEnvAux, oConnSrv, cConnStatus, lUpdate , nIPType )
Local oRPC
Local aAuxInfo := {}
Local lRet := .F.
Local cInstallPath := AllTrim(UPPER(GetPvProfString("GENERAL","INSTALLPATH","",GetAdv97()))) 
Local cService := AllTrim(UPPER(GetPvProfString("SERVICE","NAME","",GetAdv97()))) 
Local cUpdate := ""
Local oErro
Local cPortMain := AllTrim(GetPvProfString("TCP","PORT","0",GetAdv97())) 

Default cIPAux := GetPvProfString("FwCommunication","auxip","",GetAdv97())
Default cPortAux := GetPvProfString("FwCommunication","auxport","",GetAdv97())
Default cEnvAux := GetPvProfString("FwCommunication","auxenv","",GetAdv97())
Default lUpdate := .T. 

// cria .bat para para serviços do server
FwHostBatch(.T.)
FwHostBatch(.F.)

lConnVld := .F.
cIPAux := ALLTRIM(UPPER(cIPAux))
cPortAux := ALLTRIM(cPortAux)
cEnvAux := ALLTRIM(cEnvAux)
cConnStatus := ""
If !Empty(cIPAux) .AND. !Empty(cPortAux) .AND. !Empty(cEnvAux)
	If ALLTRIM(cPortMain) != ALLTRIM(cPortAux)
		If ExistDir(cInstallPath) .AND. !Empty(cService)
			oErro := ErrorBlock({|e| RPCHandle(e,@cConnStatus,oConnSrv)})
			Begin Sequence
				oRPC := TRPC():New( cEnvAux )
				If oRPC:Connect( cIPAux,VAL(cPortAux) )
					aAuxInfo := oRPC:CallProc("__LjVldSrvAux",cInstallPath,cService,nIPType,lUpdate) 
					oRPC:Disconnect()
					If Empty(aAuxInfo)
						If Empty(cConnStatus)
							cConnStatus := STR0070 + " [SERVICE] - NAME " + STR0077 + " [GENERAL] - INSTALLPATH "+ STR0071
						EndIf
						If oConnSrv != NIL
							oConnSrv:nClrText := CLR_RED
						Else
							conout(cConnStatus)	
						EndIf
					Else			
						If Empty(cConnStatus)
							Do Case
								Case !aAuxInfo[3] .AND. !(File(cInstallPath+"\appserver\downserver.bat") .AND. File(cInstallPath+"\appserver\upserver.bat"))
									cConnStatus := STR0072 + ' <font color="#000000">(' + STR0073 + ')</font>'
								Case !aAuxInfo[3] .AND. File(cInstallPath+"\appserver\downserver.bat") .AND. File(cInstallPath+"\appserver\upserver.bat")
									cConnStatus := STR0072 + ' <font color="#000000">(' + STR0074 + ')</font>'
								Case !(File(cInstallPath+"\appserver\downserver.bat") .AND. File(cInstallPath+"\appserver\upserver.bat")) .AND. aAuxInfo[3]
									cConnStatus := STR0072 + ' <font color="#000000">(' + STR0075 + ')</font>'	
								Otherwise
									cConnStatus := STR0080
							EndCase
						EndIf
						If oConnSrv != NIL
							oConnSrv:nClrText := CLR_GREEN
						Else
							conout(cConnStatus)
						EndIf
						If lUpdate
							WritePProString("FWCOMMUNICATION", "BinPath", ALLTRIM(UPPER(aAuxInfo[1])), GetAdv97() )
							WritePProString("FWCOMMUNICATION", "Service", ALLTRIM(UPPER(aAuxInfo[2])), GetAdv97() )
							WritePProString("FWCOMMUNICATION", "auxip", ALLTRIM(UPPER(cIPAux)), GetAdv97() )
							WritePProString("FWCOMMUNICATION", "auxport", ALLTRIM(UPPER(cPortAux)), GetAdv97() )
							WritePProString("FWCOMMUNICATION", "auxenv", ALLTRIM(UPPER(cEnvAux)), GetAdv97() )
						else
							aSrvAux := {cIPAux,cPortAux,cEnvAux}
							lConnVld := .T.
						EndIf
						lRet := .T.
					EndIf
				Else
					If Empty(cConnStatus)
						cConnStatus := STR0076
					EndIf
					If oConnSrv != NIL
						oConnSrv:nClrText := CLR_RED
					Else
						conout(cConnStatus)
					EndIf
				EndIf			
			End Sequence
			ErrorBlock(oErro)
		Else
			cConnStatus := STR0070 + " [SERVICE] - NAME " + STR0077 + " [GENERAL] - INSTALLPATH "+ STR0078
			If oConnSrv != NIL
				oConnSrv:nClrText := CLR_RED
			Else
				conout(cConnStatus)
			EndIf
		EndIf
	Else
		cConnStatus := STR0079
		If oConnSrv != NIL
			oConnSrv:nClrText := CLR_RED
		Else
			conout(cConnStatus)
		EndIf
	EndIf
Else
	cConnStatus := STR0081
	If oConnSrv != NIL
		oConnSrv:nClrText := CLR_RED
	Else
		conout(cConnStatus)
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} __LjVldSrvAux
Função chamada por RPC para validar o servidor auxiliar

@param cText cInstallPath+"|*|"+cService+"|*|"+cValidBat

@return cSrvInfo cInstallPathAux+"|*|"+cServiceAux+"|*|"+cValidBatAux

@author TOTVS
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function __LJVldSrvAux(cMainPath,cMainService,nIPType,lUpdate)
Local aSrvInfo := {}
Local cInstallPath := AllTrim(UPPER(GetPvProfString("GENERAL","INSTALLPATH","",GetAdv97()))) 
Local cService := AllTrim(UPPER(GetPvProfString("SERVICE","NAME","",GetAdv97())))
Local cIni

// cria .bat para para serviços do server
FwHostBatch(.T.)
FwHostBatch(.F.)

If ExistDir(cInstallPath,1) .AND. !Empty(cService)
	If lUpdate
		cIni := GetAdv97()
		WritePProString("FWCOMMUNICATION", "BinPath", cMainPath, cIni )
		WritePProString("FWCOMMUNICATION", "Service", cMainService, cIni )
		If nIPType != NIL
			WritePProString("FWCOMMUNICATION", "IPType", cValToChar(nIPType), cIni )
		EndIf
	EndIf

	Asize(aSrvInfo,3)
	aSrvInfo[1] := cInstallPath
	aSrvInfo[2] := cService
	aSrvInfo[3] := File(cInstallPath+"\appserver\downserver.bat",-1) .AND. File(cInstallPath+"\appserver\upserver.bat",-1)
EndIf
Return aSrvInfo 

//-------------------------------------------------------------------
/*/{Protheus.doc} RPCHandle
Desvia os erros de RPC

@param e 				Objeto de erro
@param cConnStatus 	Variável texto que receberá o conteúdo
@param oConnSrv 		Objeto do TSay

@return lRet Indica se a alteração pode prosseguir

@author TOTVS
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RPCHandle(e,cConnStatus,oConnSrv)
Default cConnStatus := ""
	If e:gencode > 0
		cConnStatus := STR0088 
		If oConnSrv != NIL
			oConnSrv:nClrText := CLR_RED
		Else
			conout(cConnStatus)
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CanUpdate
Indica se a alteracao e permitida no host

@param oModel Referencia do Model ativo

@return lRet Indica se a alteração pode prosseguir

@author TOTVS
@since 29/06/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function CanUpdate(oModel)

	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.
	
	If !IsBlind() .AND. !lWizard
		If (nOperation == MODEL_OPERATION_UPDATE) .AND. !( AllTrim(XXP->XXP_ID) == cHostID )
			lRet := .F.
				Help( ,, 'Help',,STR0052, 1, 0 )
		EndIf
	EndIf		
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RunHostUpdate
Dispara a atualização nos hosts remotos quanto às novas configurações

@author TOTVS
@since 29/06/2012
@version 10.1.1.4
/*/
//-------------------------------------------------------------------
Static Function RunHostUpdate()

	Local lRet 			:= .T.
	Local nX			:= 0  
	Local aBkp			:= {}
	Local aProtocols	:= {}
	Local oModel		:= FwModelActive()
	Local oModelXXX		:= Nil
	Local oModelXXP		:= Nil
	Local oLocalHost	:= Nil
	Local oFatherHost	:= Nil
	Local oModelUsr		:= Nil

	oModelUsr := oModel:getModel('USRDETAIL')

	If !Empty(oModelUsr:getValue('USR_USER')) .Or. !Empty(oModelUsr:getValue('USR_SENHA'))
		If Empty(oModelUsr:getValue('USR_USER'))
			lRet := .F.
			Help( ,,'Help',,'Campo usuário não informado!', 1, 0,,,,,,{"Necessario informar o usuário ou deixe os campos usuário e senha em branco para prosseguir"})  
		ElseIf Empty(oModelUsr:getValue('USR_SENHA'))
			lRet := .F.
			Help( ,,'Help',,'Campo senha não informado!', 1, 0,,,,,,{"Necessario informar a senha ou deixe os campos usuário e senha em branco para prosseguir"})
		EndIf
	EndIf

	If lRet

		aBkp		:= FwSaveRows()
		oModelXXX	:= oModel:getModel('XXXDETAIL')
		oModelXXP	:= oModel:getModel('XXPMASTER')
		
		//Monta o host atual
		oLocalHost := FwHost():New()
		oLocalHost:setId(AllTrim(oModelXXP:getValue("XXP_ID")))
		oLocalHost:setDescription(AllTrim(oModelXXP:getValue("XXP_DESC")))
		oLocalHost:setIP(AllTrim(oModelXXP:getValue("XXP_IP")))
		oLocalHost:setIPSecondary(AllTrim(oModelXXP:getValue("XXP_IPSEC")))
		oLocalHost:setBackupOf(AllTrim(oModelXXP:getValue("XXP_BKPID")))
		oLocalHost:setIdProfile(AllTrim(oModelXXP:getValue("XXP_PROFIL")))

		oLocalHost:setLastUpdate(DtoS(Date()) + StrTran(Time(),":"))
		If oModelXXP:GetOperation() != MODEL_OPERATION_DELETE     
			oModelXXP:setValue("XXP_UPDATE",oLocalHost:getLastUpdate())
		EndIf
		//Define o host pai
		If !Empty(oModelXXP:getValue("XXP_FATHER"))
			oFatherHost := FwHost():New()
			oFatherHost:load(oModelXXP:getValue("XXP_FATHER"))
			oLocalHost:setFather(oFatherHost)
		EndIf
		
		//Descarga dos protocolos configurados
		For nX := 1 to oModelXXX:Length()
			
			oModelXXX:goLine(nX)

			AAdd(aProtocols,{	oModelXXX:getValue("XXX_ORDER")				,;
								Val(oModelXXX:getValue("XXX_PROTOC"))		,;
								oModelXXX:getValue("XXX_PORT")				,;
								oModelXXX:getValue("XXX_ENV")				,;
								oModelXXX:getValue("XXX_ENABLE") == "1" 	})
			
		Next nX

		//Ordena protocolos por prioridade
		aSort(aProtocols,,,{|x,y| x[1] < y[1] })

		For nX := 1 to Len(aProtocols)
			
			oProtocol := FwProtocol():New()
			
			oProtocol:setProtocolId( aProtocols[nX][2] )
			oProtocol:setPort( aProtocols[nX][3] )
			oProtocol:setEnvironment( aProtocols[nX][4] )
			oProtocol:setEnabled( aProtocols[nX][5] )
			
			oLocalHost:addProtocol( oProtocol )
			
		Next nX

		//Aciona o mecanismo atualizador
		FwHostUpdater(cEmpAnt,cFilAnt,oLocalHost)

		If oFatherHost <> Nil
			FreeObj(oFatherHost)
			oFatherHost	:= Nil
		EndIf
		
		FreeObj(oLocalHost)
		oLocalHost	:= Nil

	EndIf
Return lRet

Static Function ActionPanel(oPanel)

Local nWidth	:= (oPanel:nClientWidth/2) - 2

@015,000 BUTTON STR0053 	SIZE nWidth, 12 ACTION GridChange(-1) 	PIXEL OF oPanel
@030,000 BUTTON STR0054	SIZE nWidth, 12 ACTION GridChange(1)	PIXEL OF oPanel

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SrvAuxPanel
Cria o painel adicional OTHEROBJECT de status do servidor auxiliar

@author TOTVS
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SrvAuxPanel(oPanel)
Local oFont
Local oConnSrv
Local nWidth	:= (oPanel:nClientWidth/2) - 5
Local nHeight	:= (oPanel:nClientHeight/2) - 40
Local cConnStatus := ""

@ 020,005 BUTTON STR0068	SIZE 50, 12 ACTION PreVldSrv(oConnSrv,@cConnStatus)/*FWMsgRun(Nil,{|lAux| lAux := VldServers( , , , oConnSrv, @cConnStatus, .F. )},,STR0069)*/ PIXEL OF oPanel
oFont := TFont():New('Arial',,-11,,.T.)
oConnSrv := TSay():New(040,005,{||cConnStatus},oPanel,,oFont,,,,.T.,CLR_GREEN,CLR_WHITE,nWidth,nHeight,,,,,,.T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PreVldSrv
Valida as infomações do servidor auxiliar provenientes do MVC

@author TOTVS
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PreVldSrv(oConnSrv,cConnStatus)
Local oModel:=FWModelActive()
Local oFieldSrv := oModel:GetModel("AUXDETAIL")
If oFieldSrv != NIL
	FWMsgRun(Nil,{|lAux| lAux := VldServers( oFieldSrv:GetValue("AUX_IP"),  oFieldSrv:GetValue("AUX_PORT"),  oFieldSrv:GetValue("AUX_ENV"), oConnSrv, @cConnStatus, .F. )},/*'cHeader'*/,STR0069)
EndIf
Return Nil

//------------------------------------------------------------------------
/*/{Protheus.doc} GridChange

Troca linha do Grid

@author TOTVS
@since 15/08/2011
@version P11
/*/
//------------------------------------------------------------------------
Static Function GridChange( nDirection )

Local oModel	:= FwModelActive()
Local aRows	:= Nil
Local oView	:= FwViewActive()
Local oGrid	:= oModel:GetModel( 'XXXDETAIL' )
Local nLine	:= oGrid:GetLine()
Local nTam		:= oGrid:Length()
Local nTo		:= 0
Local cOrder1	:= ""  
Local cOrder2	:= ""  

//Se for para cima e a linha for maior que 1
If nDirection < 0 .AND. nLine > 1
	nTo := nLine-1
//Se for para baixo e não for a última linha
ElseIf nDirection > 0 .AND. nLine < nTam
	nTo := nLine+1	
EndIf

If nTo <> 0
	aRows    := FwSaveRows()
	
	cOrder1 := oGrid:GetValue( "XXX_ORDER", nTo   )
	cOrder2 := oGrid:GetValue( "XXX_ORDER", nLine )

	oGrid:LineShift( nLine, nTo )

	oGrid:GoLine( nTo )
	oGrid:LoadValue( "XXX_ORDER", cOrder1 )
	oGrid:GoLine( nLine )
	oGrid:LoadValue( "XXX_ORDER", cOrder2 )
	
	FwRestRows(aRows)

	oView:Refresh('XXXDETAIL')
EndIf

Return NIL

//------------------------------------------------------------------------
/*/{Protheus.doc} XXXLoad
Carrega as linhas do grid da tabela XXX

@param oGrid Model do grid

@author TOTVS
@since 01/02/2013
@version P11
/*/
//------------------------------------------------------------------------
Static Function XXXLoad(oGrid)
Local aArea := GetArea()
Local aRet	:= {}
Local nOperation := oGrid:GetModel():GetOperation()
Local oModel := oGrid:GetModel()
Local cHost
Local oAux

If nOperation != MODEL_OPERATION_INSERT
	oModel:GetIdField('XXP_ID',@oAux)
	cHost := oAux:GetValue('XXP_ID')
	DbSelectArea('XXX')
	DbSetOrder(1)
	DbSeek(cHost)
	While !Eof() .and. XXX->XXX_ID == cHost
		Aadd(aRet,{Recno(),{XXX->XXX_ID,XXX->XXX_ORDER,XXX->XXX_ENABLE,XXX->XXX_PROTOC,XXX->XXX_PORT,XXX->XXX_ENV}})
		DbSkip()
	End
EndIf

RestArea(aArea)
Return aRet

//------------------------------------------------------------------------
/*/{Protheus.doc} XXPValid
Valida os campos do grid da tabela XXP

@param oGrid Model do grid
@param cField Campo a ser validade
@param xValue Novo valor
@param nLine Numero da linha do grid
@param xOldValue Valor anterior

@author TOTVS
@since 03/09/2012
@version P11
/*/
//------------------------------------------------------------------------
Static Function XXPValid(oModel,cField,xValue,xOldValue)
Local lRet := .T.
Local aIP
Local nLen
Local i,j

If xValue != xOldValue
	If cField == 'XXP_IP'
		aIP := StrTokArr(xValue,'.')
		nLen := Len(aIP)
		If nLen != 4
			lRet := .F.
		Else
			For i := 1 To nLen
				If i == nLen
					aIP[i] := Rtrim(aIP[i])
				EndIf
				If Len(aIP[i]) > 3
					lRet := .F.
					Exit
				Else
					For j := 1 To Len(aIP[i])
						If !IsDigit(Subs(aIP[i],j,1))
							lRet := .F.
							Exit
						EndIf
					Next
					
					If !lRet
						Exit
					EndIf
				EndIf
			Next
		EndIf
	EndIf
EndIf
Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} XXYLookUp
Consulta da tabela XXY

@author TOTVS
@since 03/09/2012
@version P11
/*/
//------------------------------------------------------------------------
Static oXA2LookUp
Function LJXA2LookUP()
	Local oStruct
	
	If Select('XA2') == 0
		FWOpenXA2()
	EndIf
	If oXA2LookUp == NIL
		oXA2LookUp := FWLookUp():New()
		oStruct := FWLookUPStruct():New()
		oStruct:AddTable("XA2",{'XA2_ID'},STR0055)
		oStruct:AddIndex(1, "01", 'XA2_ID') //"Código"
		oStruct:AddField(1, 'ID', "XA2_ID", "C" , 06, 0) //"Código"
		oStruct:AddField(1, STR0083, "XA2_DESC", "C" , 100, 0) //"Descrição"
		oStruct:SetReturnsFields({'XA2->XA2_ID'}) //Array com o numero da coluna que deve ser retornado
		oStruct:SetFilter('XA2->XA2_MASTER != 0') 
		FWMakeLookup('XA2',STR0055,oStruct)
	EndIf
Return 'XA2'

//-------------------------------------------------------------------
/*/{Protheus.doc} ConsProfile
Cria a consulta padrão do perfil

@param cProfile		ID do Perfil

@author TOTVS
@since 15/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConsProfile(cProfile)
Local oOK
Local oDlg
Local oBrowse
Local oColumn
Local oPanelBottom
Local oPanelGrid
Local nAt     := 0
Local aSeek   := {}
Local aProfiles := {}
Local nI
Local oProfile
Local aBkpProfiles := {}

For nI:=1 TO LEN(aProfile)
	If aProfile[nI]:getIsMaster() < 1
		aADD(aProfiles,{aProfile[nI]:getId(),aProfile[nI]:getDescription()})
	EndIf
Next
If LEN(aProfiles) > 0
	aBkpProfiles := aClone(aProfiles)
	DEFINE MSDIALOG oDlg TITLE STR0055 FROM 178,0 TO 543,800 PIXEL //"Papel de Trabalho"
		oPanelBottom := TPanel():New(0,0,"",oDlg,,,,,,0,20)
		oPanelBottom:Align := CONTROL_ALIGN_BOTTOM
			
		oPanelGrid := TPanel():New(0,0,"",oDlg,,,,,,0,0)
		oPanelGrid:Align := CONTROL_ALIGN_ALLCLIENT

		//-------------------------------------------------------------------
		// Chave de pesquisa do Seek
		//-------------------------------------------------------------------
		Aadd( aSeek, { STR0056 , {{"","C",06,0,STR0056}}} ) //"Código"

		DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aProfiles SEEK ORDER aSeek NO REPORT DOUBLECLICK {|| nAt := oBrowse:At(), oDlg:End() } OF oPanelGrid
			ADD COLUMN oColumn DATA { || aProfiles[oBrowse:At(),1] } TITLE STR0056 SIZE 10 OF oBrowse //"Código"
			ADD COLUMN oColumn DATA { || aProfiles[oBrowse:At(),2] } TITLE STR0009 SIZE 50 OF oBrowse //"Descrição"
		ACTIVATE FWBROWSE oBrowse		

		@ 5,09 Button oOK PROMPT "OK" Size 037,012 PIXEL OF oPanelBottom ACTION (nAt := oBrowse:At(),oDlg:End())
		@ 5,49 Button STR0057 Size 037,012 PIXEL OF oPanelBottom ACTION oDlg:End() //"Cancelar"
	ACTIVATE MSDIALOG oDlg CENTERED 
	If nAt > 0 .AND. LEN(aBkpProfiles) > 0
		cProfile := aBkpProfiles[nAt,1]
	EndIf
	aBkpProfiles := aSize(aBkpProfiles,0)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CleanProfXFunc
Limpa as tabelas de perfil, funcionalidades e relacionamentos

@author TOTVS
@since 15/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CleanProfXFunc()
Local nX := 1
Local aAlias := {"XA2","XA5","XXZ","XXY"}
For nX:=1 TO LEN(aAlias) 
	(aAlias[nX])->(DbGoTop())
	While !(aAlias[nX])->(Eof())
		If (aAlias[nX])->(RLock())
			(aAlias[nX])->(DbDelete())
		EndIf	
		(aAlias[nX])->(DbSkip())
	End
Next
Return

Static Function FWXXPValid(nType)
Local lAction := .T.
Local cDriver	:= RddName()
Local oModel := FWModelActive()
Local aFields := {}
Local oFields
Local lReturn := .T.

#IFDEF WAXS
	cDriver := "DBFCDXAX"
#ENDIF 
#IFDEF TOP
	cDriver := "TOPCONN"
#ENDIF

If !("TOP" $ cDriver) .AND. File("\system\xxp.dbf")
	If Select("XXP") == 0
		FWOpenXXP()
		//Use &("XXP") Alias &("XXP") SHARED NEW Via cDriver
	EndIf
	
	//cID := PadR(GetPvProfString("FwCommunication","ID","",GetAdv97()),19)
	cID := oModel:GetValue("XXPMASTER","XXP_ID")
	XXP->(DbSetOrder(1))
	If XXP->(DbSeek(cID,.T.))
		If ALLTRIM(XXP->XXP_ID) == ALLTRIM(cID) .AND. !Empty(XXP->XXP_FATHER)
			lAction := .F.
		EndIf
	EndIf
	//XXP->(DbCloseArea())
ElseIf "TOP" $ cDriver
	If Select("XXP") == 0
		FWOpenXXP()
	EndIf
EndIf
If oModel:GetOperation() == 4 .AND. nType == 1 //VALID
	If !lAction
		oField := oModel:GetModel("XXPMASTER")
		aFields := oField:GetStruct():GetFields()
		If select("XA2") == 0
			FWOpenXA2()
		EndIf
		XA2->(DbSetOrder(1))
		If XA2->(DbSeek(oField:GetValue("XXP_PROFIL"),.T.))
			If XA2->XA2_MASTER > 0
				lReturn := .F.
			Else
				lReturn := .T.
			EndIf		
		EndIf		
	Else
		lFather := .T.
	EndIf
ElseIf oModel:GetOperation() == 4 .AND. nType == 2 //bWHEN
	oField := oModel:GetModel("XXPMASTER")
	aFields := oField:GetStruct():GetFields()
	If lAction
		aFields[aScan(aFields,{|x| x[3] == "XXP_PROFIL" })][8] := {|| .F. }
		lReturn := .F.
	Else
		aFields[aScan(aFields,{|x| x[3] == "XXP_PROFIL" })][8] := {|| .T. }	
		lReturn := .T.
	EndIf
EndIf
Return lReturn

//---------------------------------------------------------------------------
// Valida o agendamento
//---------------------------------------------------------------------------
Static Function VldSched(oFWUISchedulePersist,oSchedule)
Local lRet := .F.
	oFWUISchedulePersist:Submit(.T., @oSchedule)
	If oSchedule != NIL
		lRet := .T.
	EndIf
Return lRet

//---------------------------------------------------------------------------
// Configuração de agendamento de atualização
//---------------------------------------------------------------------------
Static Function ConfigSched( uFWVOSchedule, cFunction, nModule , oOwner , cEnv)
	Local oFWUISchedulePersist := FWUISchedulePersist():new()

	oFWUISchedulePersist:setButtonOkCancel(.F.)
	oFWUISchedulePersist:init( oOwner, .T., @uFWVOSchedule)

	oFWUISchedulePersist:setFunctionCtrl( UPPER(ALLTRIM(cFunction)) )
	oFWUISchedulePersist:setModuleCtrl( nModule )
	oFWUISchedulePersist:setEnv(cEnv)	
	oFWUISchedulePersist:setNoEndDate(.T.)

Return oFWUISchedulePersist

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxLoad
Efetua o Load das informações do Fields da conexão com o servidor auxiliar

@author TOTVS
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AuxLoad(oField)
Local oModel := oField:GetModel()
Local oMaster := oModel:GetModel("XXPMASTER")
Local aFields := oField:GetStruct():GetFields()
Local nI := 0
Local aLoad := {}
If !Empty(oMaster:getvalue("XXP_FATHER"))
	aADD(aLoad,{AllTrim(GetPvProfString("FwCommunication","auxip","",GetAdv97())),AllTrim(GetPvProfString("FwCommunication","auxport","",GetAdv97())),AllTrim(GetPvProfString("FwCommunication","auxenv","",GetAdv97()))})
	aADD(aLoad,0)
Else
	For nI:=1 TO LEN(aFields)
		aFields[nI][8] := {|| .F. }
	Next
EndIf
Return aLoad


//-------------------------------------------------------------------
/*/{Protheus.doc} UserLoad
Efetua o Load das informações do Fields de Usuario de Senha do WS

@author Bruno Almeida
@since 15/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function UserLoad()
Local aLoad := {}

aADD(aLoad,{Space(30),Space(20)})
aADD(aLoad,0)

Return aLoad



//-------------------------------------------------------------------
/*/{Protheus.doc} FWCFGA050Commit
Função responsável efetuar o commit da rotina

@author TOTVS
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FWCFGA050Commit()
Local oModel 	:= FWModelActive()
Local lRet 		:= .F.
Local lValid 	:= .F.
Local oModelUsr := oModel:getmodel('USRDETAIL')

If oModel:GetOperation() == 4
	If oModel:GetModel("AUXDETAIL"):IsModified()
	 	If lConnVld .AND. LEN(aSrvAux) > 2
			lValid := .T.
			FWMsgRun(Nil,{|| lAux := VldServers( aSrvAux[1], aSrvAux[2], aSrvAux[3], , , .T. )},/*'cHeader'*/,STR0069)
		Else
			lValid := .F.
		EndIf
	Else
		lValid := .T.
	EndIf
	If lValid
		lRet := FWFormCommit(oModel)
		If lRet .And. !Empty(oModelUsr:getValue('USR_USER')) 
			//Grava usuario e senha do host
			SaveUser(oModelUsr:getValue('USR_USER'), oModelUsr:getValue('USR_SENHA'))
		EndIf
	Else
		lRet := .F.
		oModel:SetErrorMessage(,,,,,STR0082)
	EndIf
Else
	lRet := FWFormCommit(oModel)
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAllFunc
Função responsável marcar ou desmarcar todas as funcionalidades

@author	TOTVS
@since		21/12/2012
/*/
//-------------------------------------------------------------------
Static Function MarkAllFunc(oBrowse,aBrwFun)
Local lMark	:= .T.

Default oBrowse := Nil
Default aBrwFun := {}

//De acordo com o primeiro, marca todos ou desmarca todos
If Len(aBrwFun) > 0
	lMark := !aBrwFun[1][1]
EndIf

AEval(aBrwFun,{|x| x[1] := lMark})

oBrowse:Refresh(.T.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveUser
Função responsavel em salver o usuario e senha a partir da função
desenvolvida pelo framework

@author	Varejo
@since	14/09/2021
/*/
//-------------------------------------------------------------------
Static Function SaveUser(cUsuario, cSenha)

	Local lRet 		:= .T.
	Local lCanUse 	:= ExistFunc("CanUsePDVAuth") .AND. ExistFunc("PDVSaveUsr") .AND. CanUsePDVAuth()

	If lCanUse
		lRet := PDVSaveUsr(cUsuario, cSenha)
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CfgDelHost
Faz a exclusão dos registros do Host

@author Bruno Almeida
@since 17/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function CfgDelHost()

If FWAlertNoYes("Deseja excluir toda a configuração do Host?" + CHR(10) + CHR(13) + "IMPORTANTE: Após a exclusão será necessário refazer a configuração do Host!", "Atenção - Exclusão do Host")
	MsgRun("Exclusão do Host","Aguarde...",{|| CfgDelReg() })
	FWAlertSuccess("Cadastro de host excluído!", "Exclusão do Host")
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} CfgDelReg
Função apenas para exclusão dos registros

@author Bruno Almeida
@since 17/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function CfgDelReg()

Local aTabelas 	:= {"XXP","XXX","XXY","XXZ","XA2"}
Local nX 		:= 0
Local lDelXxy	:= LjGetCPDV()[1] .Or. STFIsPOS()
Local cLocalId 	:= GetPvProfString("FwCommunication","ID","",GetAdv97())
Local cQuery	:= ""
Local cAlias	:= ""
Local aId		:= {}
Local cIds		:= ""
Local nI		:= 0

For nX := 1 To Len(aTabelas)

	If aTabelas[nX] $ "XXY|XA2|XXZ" .And. !lDelXxy
		/*
			As tabelas XXY, XA2 e XXZ não é excluida da retaguarda apenas para facilitar para o cliente.
			São tabelas apenas de cadastros onde não necessitam que sejam zeradas no ambiente da retaguarda para refazer o host.
				XXY -> Cadastro de processos
				XA2 -> Cadastro de perfil
				XXZ -> Amarração do perfil com a funcionalidade. Essa amarração pode ser alterada no cadastro de funcionalidades no ambiente da retaguarda.
		*/
		Loop
	EndIf

	If Select(aTabelas[nX]) > 0

		If aTabelas[nX] $ "XXP" .And. !lDelXxy
			/*
				No ambiente da retaguarda, é excluído apenas o ID do host que o cliente esta conectado, se excluirmos tudo da tabela XXP pode acontecer
				de excluir um host de outro grupo de empresa. As tabelas do Host não tem o campo Filial para realizarmos o filtro.
			*/
			cQuery := " SELECT R_E_C_N_O_ "
			cQuery += "   FROM XXP "
			cQuery += "  WHERE (XXP_ID = '" + AllTrim(cLocalId) + "' OR XXP_FATHER = '" + AllTrim(cLocalId) + "')"

			cQuery := ChangeQuery(cQuery)
			cAlias := GetNextAlias()

			DbUseArea(.T., "TOPCONN", TcGenQry2( , , cQuery,{}), cAlias, .T., .F.)

			While (cAlias)->( !Eof() )
				XXP->(dbGoTo( (cAlias)->R_E_C_N_O_ ))

				Aadd(aId,AllTrim(XXP->XXP_ID))

				XXP->(RecLock("XXP", .F.))
				XXP->(dbDelete())
				XXP->(msUnlock())

				(cAlias)->( DbSkip() )
			EndDo

			(cAlias)->( DbCloseArea() )
  
		ElseIf aTabelas[nX] $ "XXX" .And. !lDelXxy
			/*
				No ambiente da retaguarda, é excluído apenas o ID do host que o cliente esta conectado, se excluirmos tudo da tabela XXX pode acontecer
				de excluir um host de outro grupo de empresa. As tabelas do Host não tem o campo Filial para realizarmos o filtro.
			*/
			For nI := 1 To Len(aId)
				cIds += "'" + aId[nI] + "',"				
			Next nI

			cIds := SubStr(cIds, 1, Len(cIds) - 1)

			cQuery := ""
			cQuery := " SELECT R_E_C_N_O_ "
			cQuery += "   FROM XXX "
			cQuery += "  WHERE XXX_ID IN (" + cIds + ")"

			cQuery := ChangeQuery(cQuery)
			cAlias := GetNextAlias()

			DbUseArea(.T., "TOPCONN", TcGenQry2( , , cQuery,{}), cAlias, .T., .F.)

			While (cAlias)->( !Eof() )
				XXX->(dbGoTo( (cAlias)->R_E_C_N_O_ ))
				XXX->(RecLock("XXX", .F.))
				XXX->(dbDelete())
				XXX->(msUnlock())
				(cAlias)->( DbSkip() )
			EndDo

			(cAlias)->( DbCloseArea() )

		Else
			(aTabelas[nX])->(dbGoTop())
			While (aTabelas[nX])->(!Eof())
				(aTabelas[nX])->(RecLock(aTabelas[nX], .F.))
				(aTabelas[nX])->(dbDelete())
				(aTabelas[nX])->(msUnlock())
				(aTabelas[nX])->(dbSkip())
			End
		EndIf

	EndIf

Next nX

Return .T.
