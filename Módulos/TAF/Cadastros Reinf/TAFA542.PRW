#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA542.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} TAFA542
Cadastro MVC Pagamentos a Beneficiários não identificados

@author Katielly Rezende/Denis Souza
@since 09/05/2022
@version 1.0
*/
Function TAFA542()

If TAFAlsInDic("V4K")
    BrowseDef()
Else
    Aviso( STR0001, STR0002, { STR0004 }, 3 ) // Aviso / "O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário aplicar o dicionário de dados do REINF 2.0."
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} browsedef
Browse Pagamentos beneficiarios não identificados

@author Katielly Rezende/Denis Souza		
@since 09/05/2022
@version 1.0
/*/
Static Function BrowseDef()

Local oBrw := FWMBrowse():New()

DBSelectArea("V4K")
DbSetOrder(1)

oBrw:SetDescription(STR0003) //Pagamentos a beneficiários não identificados
oBrw:SetAlias( 'V4K' ) 
oBrw:SetMenuDef( 'TAFA542' )
oBrw:Activate()

Return oBrw

//-------------------------------------------------------------------
 /*{Protheus.doc} MENUDEF
Funcao generica MVC com as opcoes de menu

@author Katielly Rezende/Denis Souza        
@since 09/05/2022
@version 1.0
*/
Static Function MenuDef()

Local aRotina   := {}

aRotina := xFunMnuTAF("TAFA542")

Return( aRotina )

//-------------------------------------------------------------------
 /*{Protheus.doc} ModelDef
Funcao generica MVC do model

@author Katielly Rezende/Denis Souza
@since 09/05/2022
@version 1.0
*/
Static Function ModelDef()

Local oStruV4K  := FWFormStruct( 1, 'V4K' )
Local oStruV9B  := FWFormStruct( 1, 'V9B' )
Local oModel 	:= MPFormModel():new("TAFA542",,,{|oModel| SaveModel( oModel ) })

oModel:AddFields('MODEL_V4K',, oStruV4K)
oModel:GetModel('MODEL_V4K'):SetPrimaryKey({"V4K_FILIAL","V4K_INDNAT","V4K_IDNATR","V4K_CODDOC","V4K_IDPART","V4K_DTPAG"})

oModel:addgrid('MODEL_V9B','MODEL_V4K', oStruV9B)
oModel:GetModel('MODEL_V9B'):SetOptional(.T.)
oModel:GetModel("MODEL_V9B"):SetUniqueLine({'V9B_IDPROC','V9B_CODSUS'})
oModel:GetModel('MODEL_V9B'):SetMaxLine(50)
oModel:SetRelation("MODEL_V9B",{{"V9B_FILIAL","xFilial('V9B')"},{"V9B_ID","V4K_ID"}},V9B->(IndexKey(1)))

Return (oModel)

//-------------------------------------------------------------------
 /*{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Katielly Rezende/Denis Souza
@since 09/05/2022
@version 1.0
*/
Static Function ViewDef()

local oView    as object
local oModel   as object
Local oStruV4K as object
Local oStruV9B as object

oView    := FWFormView():New()
oModel   := FWLoadModel('TAFA542')
oStruV4K := FWFormStruct(2, 'V4K')
oStruV9B := FWFormStruct(2, 'V9B')

oView:SetModel( oModel )

oView:CreateHorizontalBox( 'BOXH_MASTER', 100)
oView:CreateFolder("FOLDER_MASTER","BOXH_MASTER")
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_MASTER', STR0005 ) //"Beneficiários não identificados"

oView:AddField( "VIEW_V4K", oStruV4K, "MODEL_V4K" )
oView:EnableTitleView( "VIEW_V4K",  STR0006 ) //"Pagamentos/créditos a beneficiários não identificados"
oView:CreateHorizontalBox("PAINEL_SUPERIOR", 50,,,"FOLDER_MASTER","SHEET_MASTER" )
oView:SetOwnerView( "VIEW_V4K", "PAINEL_SUPERIOR" )

oView:CreateHorizontalBox( 'BOXH0_PAI', 50,,,"FOLDER_MASTER","SHEET_MASTER")
oView:CreateFolder("FOLDER_TOPLEFT","BOXH0_PAI")
oView:AddSheet( 'FOLDER_TOPLEFT', 'SHEET_TOPLEFT', STR0007 ) //"Processos Referenciados"

oView:CreateHorizontalBox("BOXH1_PAI",100,,,"FOLDER_TOPLEFT","SHEET_TOPLEFT")
oView:AddGrid("VIEW_V9B", oStruV9B,"MODEL_V9B" )
oView:EnableTitleView("VIEW_V9B", STR0008 ) //"Informações de processos relacionados a não retenção de tributos ou a depósitos judiciais"
oView:SetOwnerView( "VIEW_V9B", "BOXH1_PAI" )

oStruV4K:RemoveField('V4K_ID')
oStruV4K:RemoveField( "V4K_IDPART" )
oStruV4K:RemoveField( "V4K_IDNATR" )
oStruV9B:RemoveField( "V9B_IDSUSP" )

Return(oView)

//--------------------------------------------------
 /*{Protheus.doc} SaveModel
Salva o modelo
@author Katielly Rezende/Denis Souza
@since 09/05/2022
@version 1.0
*/
Static Function SaveModel(oModel)

Local lRet As Logical
Local nOper := oModel:getOperation()


lRet := TafVlV4K()
Begin Transaction
	if lRet
		If FWFormCommit( oModel ) 
			If  ( nOper == MODEL_OPERATION_UPDATE ) .Or. ( nOper == MODEL_OPERATION_DELETE ) 
				TafEndGRV( "V4K","V4K_PRID40", '', V4K->(Recno())  )
			Endif
		Endif
	Endif
End Transaction

Return lRet

//-------------------------------------------------------------------
/*/	{Protheus.doc} TafVlV4K
Validacao de campo para proteger erro de chave duplicada
V4K_FILIAL+V4K_INDNAT+V4K_IDNATR+V4K_CODDOC+V4K_IDPART+V4K_DTPAG, R_E_C_N_O_, D_E_L_E_T_
@param  
@return lRet
@author  Denis Souza
@since   15/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafVlV4K()

Local lRet 		:= .T.
Local alGetV4K 	:= V4K->( GetArea() )

If !IsBlind()
	dbSelectArea("V4K")
	V4K->(dbSetOrder(2)) //V4K_FILIAL+V4K_INDNAT+V4K_IDNATR+V4K_CODDOC+V4K_IDPART+V4K_DTPAG, R_E_C_N_O_, D_E_L_E_T_

	//Tratamento protecao chave duplicada
	if V4K->( DbSeek( xFilial("V4K") + FwFldGet("V4K_INDNAT") + FwFldGet("V4K_IDNATR") + FwFldGet("V4K_CODDOC") + FwFldGet("V4K_IDPART") + Dtos(FwFldGet("V4K_DTPAG"))) )
		if V4K->V4K_ID <> FwFldGet("V4K_ID")
			lRet := .F.
			Help("",1,"Help","Help",STR0009, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0010})//"O conteúdo preenchido forma uma chave já cadastrada."#"Informe outro contéudo."
		endif
	endif

	RestArea( alGetV4K )
endif

Return lRet
