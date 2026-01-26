#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA548.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA548
Cadastro MVC do R-4099 - Fechamento dos Eventos Periódicos Série R-4000

@author Katielly Feitosa Rezende 		
@since 14/08/2019
@version 1.0
*/
Function TAFA548()

If TAFAlsInDic( "V3W" )
	BrowseDef()
Else
	Aviso( STR0001, TafAmbInvMsg(), { STR0002 }, 3 ) //O ambiente do TAF encontra-se desatualizado. //Finalizar
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao MVC com as opcoes de menu

@author Katielly Rezende			
@since 14/08/2019
@version 1.0
/*/
Static Function MenuDef()

Local aFuncao   as array
Local aRotina   as array
Local lReinf20  as logical

aFuncao := {}
aRotina := {}

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )
lReinf20 := AllTrim(StrTran(SuperGetMv('MV_TAFVLRE',.F.,''),'_','')) >= '20101'

If lReinf20
	aAdd( aFuncao, { "", "xFunNewHis( 'V3W', 'TAFA548' )", "3" } )
	aAdd( aFuncao, { "", "TAF548Xml", "1" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V3W', 'R-4099', 'Fech', 'TAF548Xml', 5, oBrowse)", "5" } )

	If lMenuDif
		ADD OPTION aRotina Title STR0009 ACTION 'VIEWDEF.TAFA548' OPERATION 2 ACCESS 0
		ADD OPTION aRotina Title STR0010 ACTION "xFunNewHis( 'V3W', 'TAFA548' )" OPERATION 2 ACCESS 0
	Else
		aRotina := TAFMenuReinf( "TAFA548", aFuncao)
	EndIf
else
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.TAFA548' OPERATION 2 ACCESS 0
EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao  MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Rezende			
@since 14/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV3W  as object
Local oModel	as object

oModel    :=  MPFormModel():New( 'TAFA548' ,,,{|oModel| SaveModel(oModel)}) 

oStruV3W  :=  FWFormStruct( 1, 'V3W' )

oModel:AddFields('MODEL_V3W',, oStruV3W)
oModel:GetModel( "MODEL_V3W" ):SetPrimaryKey( { "V3W_PERAPU" } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Rezende			
@since 14/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oStruV3W	as object
Local oStruV3Wb	as object
Local oView		as object
Local cCmp	    as char
Local cCmp2	    as char
Local cCmp3	    as char
Local cCmp4	    as char
Local aCmpGrp	as array
Local nI		as numeric

oModel	:= FWLoadModel( 'TAFA548' )
oView	:= FWFormView():New()
cCmp    := ""
cCmp2   := ""
cCmp3   := ""
cCmp4   := ""
aCmpGrp	:= {}
nI		:= 0

cCmp	:= "V3W_PERAPU|V3W_TPAMB|"
cCmp2   := "V3W_NMRESP|V3W_CPFRES|V3W_DDDFON|V3W_FONE|V3W_EMAIL|"
cCmp3   := "V3W_SITPER|"
cCmp4	:= "V3W_PROTUL|" 

oStruV3W  := FwFormStruct( 2, "V3W" )
oStruV3Wb := FwFormStruct( 2, "V3W", { |x| AllTrim( x ) + "|" $ cCmp4 } )

oStruV3W:AddGroup( "GRP_FECHA_PERIODICOS", STR0003, "", 1 ) //"Fechamento dos Eventos Periódicos"
oStruV3W:AddGroup( "GRP_RESP_INFORMAÇÕES", STR0004, "", 1 ) //"Responsável pelas informações"
oStruV3W:AddGroup( "GRP_INFO_FECHAMENTO" , STR0005, "", 1 ) //"Informações do Fechamento" 

aCmpGrp := StrToKarr( cCmp, "|" )
For nI := 1 to Len( aCmpGrp )
    oStruV3W:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_FECHA_PERIODICOS" )
Next nI

aCmpGrp := StrToKarr( cCmp2, "|" )
For nI := 1 to Len( aCmpGrp )
    oStruV3W:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_RESP_INFORMAÇÕES" )
Next nI

aCmpGrp := StrToKarr( cCmp3, "|" )
For nI := 1 to Len( aCmpGrp )
    oStruV3W:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_INFO_FECHAMENTO" )
Next nI

oStruV3W:RemoveField('V3W_ID'    )
oStruV3W:RemoveField('V3W_PROTUL')
oStruV3W:RemoveField('V3W_XMLID' )
oStruV3W:RemoveField('V3W_PROCID')

oView:SetModel( oModel )

oView:AddField( 'VIEW_V3W' , oStruV3W , 'MODEL_V3W' )
oView:AddField( 'VIEW_V3Wb', oStruV3Wb, 'MODEL_V3W' )

oView:CreateHorizontalBox( 'PAINEL', 100 )
oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL' )

oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0003 ) //"Fechamento dos Eventos Periódicos"
oView:CreateHorizontalBox( 'PAINEL_01', 100,,, 'FOLDER_SUPERIOR', 'ABA01' )

oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0006 ) //"Protocolo de Transmissão"
oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )

oView:SetOwnerView( 'VIEW_V3W' , 'PAINEL_01')
oView:SetOwnerView( 'VIEW_V3Wb', 'PAINEL_02')

xFunRmFStr(@oStruV3W, 'V3W')	

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Katielly Rezende		
@since 14/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	as numeric
Local lRetorno		as logical
Local cChvRegAnt	as character
Local lExcPer 		as character 

nOperation	:= oModel:GetOperation()
lExcPer		:= IsInCallStack("TAFExcReg2") 
lRetorno	:= .T.
cChvRegAnt 	:= ""

Begin Transaction 
	If nOperation == MODEL_OPERATION_DELETE 
		//Se o registro ja foi transmitido não permite excluir
		if V3W->V3W_STATUS == "2" .And. !lExcPer
			//Não é possível excluir um registro com aguardando validação
			TAFMsgVldOp(oModel,"2")
			lRetorno := .F. 
		Else
			oModel:DeActivate()
			oModel:SetOperation( 5 ) 	
			oModel:Activate()
			FwFormCommit( oModel )
		EndIf			
	EndIf
End Transaction   
     
Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse 

@author Katielly Rezende
@since 14/08/2019
@version 1.0
/*/
Static Function BrowseDef()

Local cFiltro as char
Private oBrowse	as object

oBrowse	:= FWmBrowse():New()
cFiltro := "V3W_ATIVO == '1'"

//Legenda para visualização do campo V3W_SITPER (Situacao do Periodo)
oBrowse:AddLegend( "V3W_SITPER == '1' ", "GREEN"	, STR0007 )
oBrowse:AddLegend( "V3W_SITPER == '0' ", "YELLOW"	, STR0008 )

oBrowse:SetDescription( "R-4099 - " + STR0003 )	//"Fechamento dos Eventos Periódicos"
oBrowse:SetAlias( 'V3W')
oBrowse:SetMenuDef( 'TAFA548' )	
oBrowse:SetFilterDefault( "V3W_ATIVO == '1'" )

oBrowse:Activate()

Return( oBrowse )

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF548Xml
Retorna o Xml do Registro Posicionado 
	
@author almeida.veronica
@since 22/11/2022
@version 1.0

@return
cXml - Estrutura do Xml do Layout S-4099
/*/
//-------------------------------------------------------------------
Function TAF548Xml(cAlias as character, nRecno as Numeric, nOpc as integer, lJob as logical)
Local cXml    	as character
Local cLayout 	as character
Local cReg    	as character
Local cPeriodo	as character
Local cNameXSD  as character

Default lJob 	:= .F.

cNameXSD	:= '4099FechamentoDirf'

cLayout 	:= "4099"
cXml    	:= ""
cReg    	:= "Fech" 
cPeriodo	:= Substr(V3W->V3W_PERAPU,3) +"-"+ Substr(V3W->V3W_PERAPU,1,2) 

xTafTagGroup("ideRespInf" ,{;
						{ "nmResp"   ,V3W->V3W_NMRESP	,,.F. },;
						{ "cpfResp"  ,V3W->V3W_CPFRES	,,.F. },;
						{ "telefone" ,AllTrim(V3W->V3W_DDDFON) + StrTran(V3W->V3W_FONE,"-",""),,.T. },;
						{ "email"    ,V3W->V3W_EMAIL  ,,.T. }},;
						@cXml)

xTafTagGroup("infoFech" ,{;
						{ "fechRet"   ,V3W->V3W_SITPER	,,.F. }},;
						@cXml)

// Estrutura do cabecalho
cXml := TAFXmlReinf( cXml, "V3W", cLayout, cReg, cPeriodo,, cNameXSD )

// Executa gravacao do registro
If !lJob
	xTafGerXml(cXml,cLayout,,,,,,"R-" )
EndIf

Return(cXml)
