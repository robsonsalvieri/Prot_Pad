#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA622.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA622
Nome menu: Reg.x365-info.contrapartes.trans.controladas

Registro X365: Informações Sobre as Contrapartes nas Transações Controladas
Registro X366: Entidades Com as Quais Realiza Transações Controladas

Inspirado no TAFA336/TAFA507

@author Denis de Souza Naves
@since 22/02/2024
@version 1.0
  
/*/
//-------------------------------------------------------------------
Function TAFA622()
Local oBrw as object

oBrw := FWmBrowse():New()

If TAFAlsInDic( "V15" )
	oBrw:SetDescription(STR0001) //"Info Contrapartes Trans. Controladas"
	oBrw:SetAlias( 'V15')
	oBrw:SetMenuDef( 'TAFA622' )
	V15->( DBSetOrder( 1 ) )
	oBrw:Activate()
else
	Aviso(STR0002, TafAmbInvMsg(), { STR0003 }, 3 ) //##"Dicionário Incompatível" ##"Encerrar"
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis de Souza Naves
@since 22/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao as array 
Local aRotina as array

aFuncao := {}
aRotina := {}

Aadd( aFuncao, { "" , "Taf622Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA622" , , aFuncao )

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis de Souza Naves
@since 22/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV15	as object
Local oModel	as object

oStruV15 :=	FWFormStruct( 1, "V15" )

oModel	 :=	MPFormModel():New( "TAFA622",,, { |oModel| SaveModel( oModel ) } )
//Registro X365 e X366: Informações Sobre as Contrapartes nas Transações Controladas
oModel:AddFields( "MODEL_V15", /*cOwner*/, oStruV15 )
oModel:GetModel( "MODEL_V15" ):SetPrimaryKey( {"V15_IDENT"} )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis de Souza Naves
@since 22/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	as object
Local oStruV15A	as object
Local oStruV15B	as object
Local oView		as object
Local cCmpFil	as character

oModel 	  :=  FWLoadModel( 'TAFA622' )
oView	  :=  FWFormView():New()

cCmpFil   := "V15_PERIOD|V15_IDENT|V15_NOME|"
oStruV15A := FwFormStruct( 2, "V15",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //X365

cCmpFil   := "V15_NIF|V15_PAIS|V15_DPAIS|V15_PARREL|V15_HIPOTE|V15_VLRPGT|V15_VLRREC|"
oStruV15B := FwFormStruct( 2, "V15",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //X366
oStruV15B:SetProperty('V15_PARREL', MVC_VIEW_TITULO ,STR0008 )//'Essa empresa é parte relacionada nos termos do art. 4o. da Lei No. 14.596, de 14/06/2023?'
oStruV15B:SetProperty('V15_HIPOTE', MVC_VIEW_TITULO , STR0009) //'Essa entidade é caracterizada nas hipóteses previstas nos arts. 24 e 24-A da Lei No. 9.430/1996?'

oView:SetModel( oModel )

oView:AddField( "VIEW_V15A", oStruV15A, "MODEL_V15")
oView:EnableTitleView("VIEW_V15A",STR0004) //"Informações sobre as Contrapartes nas Transações Controladas"

oView:AddField( "VIEW_V15B", oStruV15B, "MODEL_V15")
oView:EnableTitleView("VIEW_V15B",STR0005) //"Dados das Entidades com as quais realiza Transações Controladas"

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL", 30 )
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

oView:CreateHorizontalBox("PAINEL_INFERIOR",70)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")  

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_V15A', 'PAINEL_PRINCIPAL' )   
oView:SetOwnerView( 'VIEW_V15B', 'PAINEL_INFERIOR' )   

/*-----------------------------------------------------------------------------------
Esconde campos de controle interno
-------------------------------------------------------------------------------------*/
oStruV15A:RemoveField( "V15_ID" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis de Souza Naves
@since 22/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation as numeric
nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "V15", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf622Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Denis de Souza Naves
@since 22/02/2024
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf622Vld( cAlias as char, nRecno as numeric, nOpc as numeric, lJob as logical )

Local aLogErro := {}  as array
Local cStatus  := ""  as character
Local lValida  := .F. as logical

Default cAlias := "V15"
Default nRecno := V15->( Recno() )
Default nOpc   := 0
Default lJob   := .F.

lValida := ( V15->V15_STATUS $ ( " |1" ) )
If lValida
	If Empty( V15->V15_PERIOD )
		aAdd( aLogErro, { "V15_PERIOD", "000001", cAlias, nRecno } ) //"Campo inconsistente ou vazio."
	EndIf
	If Empty( V15->V15_IDENT )
		aAdd( aLogErro, { "V15_IDENT", "000001", cAlias, nRecno } ) //"Campo inconsistente ou vazio."
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
/*/	{Protheus.doc} TafVlV15
Validacao de campo para proteger erro de chave duplicada

@param  
@return lRet
@author  Rafael Leme
@since   15/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafVlV15()

Local lRet 	   as logical
Local alGetV15 as array 

lRet 	 := .T.
alGetV15 := V15->( GetArea() )

dbSelectArea("V15")
V15->(dbSetOrder(2)) //V15_FILIAL+V15_IDENT

//Tratamento protecao chave duplicada
If V15->( DbSeek( xFilial("V15") + FwFldGet( "V15_IDENT" ) ) )
	If V15->V15_ID <> FwFldGet("V15_ID")
		lRet := .F.
		If !IsBlind()
			Help("",1,"Help","Help", STR0006, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0007})//"O conteúdo preenchido forma uma chave já cadastrada."#"Informe outro contéudo."
		EndIf
	Endif
Endif

RestArea( alGetV15 )


Return lRet
