#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA624.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA624

Nome menu: Reg.x485-Benefícios Fiscais Pt.II

@author Denis de Souza Naves
@since 06/03/2024
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA624()

Local oBrw := FWmBrowse():New()

If TAFAlsInDic( "V55" )
	oBrw:SetDescription(STR0001) //"Benef. Fiscais – Parte II"
	oBrw:SetAlias( 'V55')
	oBrw:SetMenuDef( 'TAFA624' )
	V55->( DBSetOrder( 1 ) )
	oBrw:Activate()
else
	Aviso(STR0002,TafAmbInvMsg(),{STR0003},3) //##"Dicionário Incompatível" ##"Encerrar"
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis de Souza Naves
@since 06/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf624Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA624" , , aFuncao )

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis de Souza Naves
@since 06/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV55	as object
Local oModel	as object

oStruV55 :=	FWFormStruct( 1, "V55" )

oModel	 :=	MPFormModel():New( "TAFA624",,, { |oModel| SaveModel( oModel ) } )

oModel:AddFields( "MODEL_V55", /*cOwner*/, oStruV55 )
oModel:GetModel( "MODEL_V55" ):SetPrimaryKey( { "V55_FILIAL", "V55_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis de Souza Naves
@since 06/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FWLoadModel( 'TAFA624' )
Local oStruV55 := FWFormStruct( 2, "V55" )
Local oView	   := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_V55", oStruV55, "MODEL_V55")
oView:EnableTitleView("VIEW_V55",STR0004) //"Benefícios Fiscais – Parte II"

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL", 100 )
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_V55', 'PAINEL_PRINCIPAL' )

/*-----------------------------------------------------------------------------------
Esconde campos de controle interno
-------------------------------------------------------------------------------------*/
oStruV55:RemoveField( "V55_ID" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis de Souza Naves
@since 06/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "V55", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf624Vld

Funcao que valida os dados do registro posicionado, verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Denis de Souza Naves
@since 06/03/2024
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf624Vld( cAlias as char, nRecno as numeric, nOpc as numeric, lJob as logical )

Local aLogErro := {}  as array
Local cStatus  := ""  as character
Local lValida  := .F. as logical

Default cAlias := "V55"
Default nRecno := V55->( Recno() )
Default nOpc   := 0
Default lJob   := .F.

lValida := ( V55->V55_STATUS $ ( " |1" ) )

If lValida
	If !Empty( V55->V55_CNPJIN ) .and. Len( Alltrim( V55->V55_CNPJIN ) ) <> 14
		aAdd( aLogErro, { "V55_CNPJIN", "000001", cAlias, nRecno } ) //"Campo inconsistente ou vazio."
	EndIf

	//Atualiza o Status do Registro
	//1 = Registro Inválido
	//0 = Registro Válido
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	TAFAltStat( cAlias, cStatus )
endif

//Não apresenta o alerta quando utiliza o Job para validar
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro )

//-------------------------------------------------------------------
/*{Protheus.doc} TAF624Cbox
Combo no campo tipo de benefício V55_TPBENE

@author Denis Souza
@since 06/03/2024
@version 1.0
*/
Function TAF624Cbox( cCampo )

	Local cString := ""

	cString := "01=" + STR0005 + ";" //"REPES"
	cString += "02=" + STR0006 + ";" //"RECAP"
	cString += "03=" + STR0007 + ";" //"PADIS"
	cString += "04=" + STR0008 + ";" //"REIDI"
	cString += "05=" + STR0009 + ";" //"RECINE"
	cString += "06=" + STR0010 + ";" //"RETID"
	cString += "07=" + STR0011 + ";" //"ÓLEO BUNKER"
	cString += "08=" + STR0012 + ";" //"REPORTO"
	cString += "09=" + STR0013 + ";" //"RET II"
	cString += "10=" + STR0014 + ";" //"RET PMCMV e ou RET PCVA"
	cString += "11=" + STR0015 + ";" //"RET EEI"
	cString += "12=" + STR0016 + ";" //"ENTIDADE BENEFICENTE DE ASSISTÊNCIA SOCIAL IMUNE DE CONTRIBUIÇÕES SOCIAIS"
	cString += "13=" + STR0017 + ";" //"REPETRO INDUSTRIALIZAÇÃO"
	cString += "14=" + STR0018 + ";" //"REPETRO NACIONAL"
	cString += "15=" + STR0019 + ";" //"REPETRO PERMANENTE"
	cString += "16=" + STR0020 		 //"REPETRO TEMPORÁRIO"

Return( cString )
