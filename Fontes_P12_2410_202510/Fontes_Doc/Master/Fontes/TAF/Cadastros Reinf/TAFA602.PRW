#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA602.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA602
Cadastro MVC - R-4080 - Retenção Recebimento

@author Denis Souza
@since 18/04/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA602()

If TAFAlsInDic( "V97" ) .And. TAFAlsInDic( "V98" ) .And. TAFAlsInDic( "V99" ) .And. TAFAlsInDic( "V9A" )
	BrowseDef()
Else
	Aviso( "TAF", 'TAFA602', { "OK" }, 2 )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis Souza
@since 18/04/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array
Local lReinf20  as logical

aFuncao	:= {}
aRotina	:= {}

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )
lReinf20 := AllTrim(StrTran(SuperGetMv('MV_TAFVLRE',.F.,''),'_','')) >= '20101'

If lReinf20
	aAdd( aFuncao, { "", "TAF602Xml", "1" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V97', 'R-4080', 'RetRec', 'TAF602Xml', 5, oBrowse)", "5" } )

	If lMenuDif 
		ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.TAFA602" OPERATION 2 ACCESS 0 //"Visualizar"
		ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.TAFA602" OPERATION 3 ACCESS 0 //"Incluir"
	Else
		aRotina := TAFMenuReinf( "TAFA602", aFuncao )
	EndIf
else
	ADD OPTION aRotina Title STR0016 Action 'VIEWDEF.TAFA602' OPERATION 2 ACCESS 0
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis Souza
@since 18/04/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV97 as object
Local oStruV98 as object
Local oStruV99 as object
Local oStruV9A as object
Local oModel   as object

oStruV97 := FWFormStruct( 1, 'V97' )
oStruV98 := FWFormStruct( 1, 'V98' )
oStruV99 := FWFormStruct( 1, 'V99' )
oStruV9A := FWFormStruct( 1, 'V9A' )

oModel	 := MPFormModel():New( 'TAFA602' , , , {|oModel| SaveModel( oModel ) })

oModel:AddFields('MODEL_V97',,oStruV97)
oModel:GetModel('MODEL_V97'):SetPrimaryKey({'V97_FILIAL','V97_ID','V97_VERSAO'})

oModel:addgrid('MODEL_V98','MODEL_V97', oStruV98)
oModel:GetModel("MODEL_V98"):SetUniqueLine({"V98_NATREN"})
oModel:SetRelation("MODEL_V98",{{"V98_FILIAL","xFilial('V98')"},{"V98_ID","V97_ID"},{"V98_VERSAO","V97_VERSAO"}},V98->(IndexKey(1)))

oModel:addgrid('MODEL_V99','MODEL_V98', oStruV99)
oModel:GetModel("MODEL_V99"):SetUniqueLine({"V99_DATAFG"})
oModel:SetRelation("MODEL_V99",{{"V99_FILIAL","xFilial('V99')"},{"V99_ID","V97_ID"},{"V99_VERSAO","V97_VERSAO"},{"V99_NATREN","V98_NATREN"}},V99->(IndexKey(1)))
 
oModel:addgrid('MODEL_V9A','MODEL_V99', oStruV9A)
oModel:GetModel('MODEL_V9A'):SetOptional(.T.)
oModel:GetModel("MODEL_V9A"):SetUniqueLine({'V9A_IDPROC','V9A_CODSUS'})
oModel:GetModel('MODEL_V9A'):SetMaxLine(50)
oModel:SetRelation("MODEL_V9A",{{"V9A_FILIAL","xFilial('V9A')"},{"V9A_ID","V97_ID"},{"V9A_VERSAO","V97_VERSAO"},{"V9A_NATREN","V98_NATREN"},{"V9A_DATAFG","V99_DATAFG"}},V9A->(IndexKey(1)))

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis Souza
@since 18/04/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

local oView    as object
local oModel   as object
local oStrV97a as object
local oStrV97b as object
local oStrV98  as object
local oStrV99  as object
local oStrV9A  as object
local cCmpFil  as character

oView   := FWFormView():new()
oModel  := FWLoadModel('TAFA602')

cCmpFil  := "V97_PERAPU|V97_IDESTA|V97_DESTAB|V97_TPINSC|V97_NRINSC|V97_CODPAR|V97_NRINSF|V97_DPARTI|"
oStrV97a := FwFormStruct( 2, "V97", {|x| AllTrim(x) + "|" $ cCmpFil } )

cCmpFil  := "V97_PROTUL|"
oStrV97b := FwFormStruct( 2, "V97", {|x| AllTrim(x) + "|" $ cCmpFil } )

cCmpFil  := "V98_NATREN|V98_DNATRE|V98_OBS|"
oStrV98  := FwFormStruct( 2, "V98", {|x| AllTrim(x) + "|" $ cCmpFil } )

oStrV99 := FwFormStruct(2,"V99")
oStrV9A := FwFormStruct(2,"V9A")

oView:SetModel( oModel )
oView:SetContinuousForm(.T.)

oView:CreateHorizontalBox( 'BOXH_MASTER', 100)
oView:CreateFolder("FOLDER_MASTER","BOXH_MASTER")
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_MASTER', STR0007 ) //"R-4080"
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_PROTUL', STR0008 ) //"Recibo"

oView:AddField("VIEW_V97A", oStrV97a, "MODEL_V97" )
oView:EnableTitleView("VIEW_V97A", STR0006 ) //"R-4080 - Retenção no Recebimento"
oView:CreateHorizontalBox("PAINEL_SUPERIOR", 30,,,"FOLDER_MASTER","SHEET_MASTER" )
oView:SetOwnerView( "VIEW_V97A", "PAINEL_SUPERIOR" )

oView:AddField("VIEW_V97B", oStrV97b, "MODEL_V97" )
oView:EnableTitleView("VIEW_V97B", STR0009) //"Recibo R-4080 - Retenção no Recebimento"
oView:CreateHorizontalBox("PAINEL_SUPERIORB", 30,,,"FOLDER_MASTER","SHEET_PROTUL" )
oView:SetOwnerView( "VIEW_V97B", "PAINEL_SUPERIORB" )

//Nivel1
oView:CreateHorizontalBox( 'BOXH0_PAI', 30,,,"FOLDER_MASTER","SHEET_MASTER")
oView:CreateFolder("FOLDER_TOPLEFT","BOXH0_PAI")
oView:AddSheet( 'FOLDER_TOPLEFT', 'SHEET_TOPLEFT', STR0010 ) //"ideRend"

oView:CreateHorizontalBox("BOXH1_PAI",30,,,"FOLDER_TOPLEFT","SHEET_TOPLEFT")
oView:AddGrid("VIEW_V98", oStrV98,"MODEL_V98" )
oView:EnableTitleView("VIEW_V98", STR0011 ) //"Identificação do rendimento"
oView:SetOwnerView( "VIEW_V98", "BOXH1_PAI" )

//Nivel2
oView:CreateHorizontalBox( 'BOXH0_FILHO', 20,,,"FOLDER_TOPLEFT","SHEET_TOPLEFT")
oView:CreateFolder("FOLDER_INFOREC","BOXH0_FILHO")
oView:AddSheet( 'FOLDER_INFOREC', 'SHEET_INFOREC', STR0012 ) //"infoRec"

oView:CreateHorizontalBox( 'BOXH1_FILHO', 20,,,"FOLDER_INFOREC","SHEET_INFOREC")
oView:AddGrid("VIEW_V99", oStrV99,"MODEL_V99" )
oView:EnableTitleView("VIEW_V99", STR0013 ) //"Informações relativas ao recebimento do rendimento."
oView:SetOwnerView( "VIEW_V99", "BOXH1_FILHO" )

//Nivel3
oView:CreateHorizontalBox( 'BOXH0_NETO', 20,,,"FOLDER_TOPLEFT","SHEET_TOPLEFT")
oView:CreateFolder("FOLDER_PROCRET","BOXH0_NETO")
oView:AddSheet( 'FOLDER_PROCRET', 'SHEET_PROCRET', STR0014 ) //"infoProcRet"

oView:CreateHorizontalBox( 'BOXH1_NETO', 20,,,"FOLDER_PROCRET","SHEET_PROCRET")
oView:AddGrid("VIEW_V9A", oStrV9A,"MODEL_V9A" )
oView:EnableTitleView("VIEW_V9A", STR0015 ) //"Informações de processos relacionados a não retenção de tributos ou a depósitos judiciais."
oView:SetOwnerView( "VIEW_V9A", "BOXH1_NETO" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Denis Souza
@since 18/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

Private oBrowse	as object

oBrowse	:=	FWMBrowse():New()

oBrowse:SetDescription( STR0006 ) //"Retenção no Recebimento"
oBrowse:SetAlias( "V97" )
oBrowse:SetMenuDef( "TAFA602" )
oBrowse:SetFilterDefault( "V97_ATIVO == '1'" )

TAFLegReinf( "V97", oBrowse)

oBrowse:Activate()

Return( oBrowse )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao para validação de gravação do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Denis Souza
@Since 18/04/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation as numeric
Local lRetorno	 as logical

nOperation := oModel:GetOperation()
lRetorno   := .T.

FWFormCommit( oModel )

Return( lRetorno )

//---------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
@type			function
@description	Função com o objetivo de gerar o Evento de Exclusão
@author			Carlos Eduardo
@since			04/11/2022
@version		1.0
@param			oModel	-	Modelo de dados
@param			nRecno	-	Número do registro
@param			lRotExc	-	Variavel que controla se a function é chamada pelo TafIntegraESocial
/*/
//---------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )
Local lRet 		:= .t.
Local lSubModel	:= .f.
Local i 		:= 0
Local J			:= 0
Local oJsonGrv	:= JsonObject():New()
Local cModel	:= ''
Local cVersao	:= ''
Local cField	:= ''
Local xValue	:= nil
Local cType		:= ''
Local cVerAnt	:= ''
Local cRecibo	:= ''

//Transforma dos dados do Model em Json e guarda no objeto para ser usado na nova gravação.
oJsonGrv:FromJson( oModel:GetJSONData(.t.,,.f.,.f.,.t.))

//Posiciono a tabela Pai no registro que esta sendo alterado
DBSelectArea('V97')
V97->(DBGoTo(nRecno))

//Informações para gravação do rastro
cVerAnt := V97->V97_VERSAO
cRecibo := V97->V97_PROTUL

//Gero uma nova versão para o registro que será incluido!
cVersao := xFunGetVer() 

Begin Transaction

	//Seto o registro como Inativo
	FAltRegAnt( 'V97', '2' )

	//Operação de inclusão do novo registro
	oModel:DeActivate()
	oModel:SetOperation(3)
	oModel:Activate()
	
	//Grava as informações do Model e Submodel
	for i := 1 to len(oJsonGrv['models'])

		//Pega o nome do Model Principal
		cModel := oJsonGrv['models'][i]['id']

		//Pega nome e conteudo dos campos que precisam ser gravado e carrega no model
		for j := 1 to len(oJsonGrv['models'][i]['fields'])
			cField := oJsonGrv['models'][i]['fields'][j]['id']
			if x3uso(getSx3Cache(cField,'X3_USADO')) 
				do case //Campos com tratamentos específicos para inclusão do novo registro.
					case '_VERSAO' $ cField
						xValue := cVersao
					case '_VERANT' $ cField
						xValue := cVerAnt
					case '_PROTPN' $ cField
						xValue := cRecibo
					case '_PROTUL' $ cField
						xValue := ''
					case '_EVENTO' $ cField
						xValue	:= 'E'
					case '_ATIVO'  $ cField
						xValue := '1'
					otherwise
						xValue := oJsonGrv['models'][i]['fields'][j]:GetJsonText('value') 
				endcase

				if xValue == 'null'; xValue := ''; endif
				cType := oJsonGrv['models'][i]['fields'][j]['datatype'] //Pega o tipo de dado do campo
				//Comverte para o tipo correto de dado
				if cType == 'C'
					xValue := decodeutf8(xValue)
				endif	
				//Carrega o dado no model
				lRet := oModel:LoadValue( cModel, cField , xValue )	

			endif	
		next

		//Verifica se existem submodels para serem gravados
		lSubModel := aScan( oJsonGrv['models'][i]:GetNames(), {|x| x == 'models'}) > 0
		if lSubModel
			//Faz a chamada da função de gravação dos submodes caso seja necessário
			for j := 1 to len(oJsonGrv['models'][i]['models'])
				GrvSubMdl(oModel, oJsonGrv['models'][i]['models'][j] )
			next
		endif		

		//Commita o novo registro
		FWFormCommit( oModel )
		TAFAltStat( 'V97', '6' )

	next	

end Transaction

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA602Xml
Funcao de geracao do XML para atender o registro R-4080
Quando a rotina for chamada o registro deve estar posicionado

@Return:cXml
cXml - Estrutura do Xml do Layout R-4080

@author almeida.veronica
@since 25/11/2022

@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF602Xml(cAlias as character, nRecno as numeric, nOpc as numeric, lJob as logical)
	Local cXml        as character
	Local cLayout     as character
	Local cReg        as character
	Local cId         as character
	Local cVerAnt     as character
	Local cNameXSD	  as character
	Local cAliasTemp  as character
	Local cPeriodo    as character
	Local cDataFg     as character
	Local lReinf212   as logical

	V98->( DBSetOrder( 1 ) ) // V98_FILIAL+V98_ID+V98_VERSAO+V98_NATREN
	V99->( DBSetOrder( 1 ) ) // V99_FILIAL+V99_ID+V99_VERSAO+V99_NATREN+DTOS(V99_DATAFG)
	V9A->( DBSetOrder( 1 ) ) // V9A_FILIAL+V9A_ID+V9A_VERSAO+V9A_NATREN+DTOS(V9A_DATAFG)+V9A_IDPROC+V9A_CODSUS

	cXml        := ""
	cLayout     := "4080"
	cReg        := "RetRec"
	cId         := ""
	cVerAnt     := ""
	cNameXSD    := "4080RetencaoRecebimento"
	cAliasTemp  := GetNextAlias()
	cPeriodo	:= Substr( V97->V97_PERAPU, 3 ) + "-" + Substr( V97->V97_PERAPU, 1, 2 )
	lReinf212   := TAFColumnPos( "V4N_EVADIC" )



	cXml += "<ideEstab>"	
	cXml += xTafTag( "tpInscEstab", V97->V97_TPINSC )
	cXml += xTafTag( "nrInscEstab", V97->V97_NRINSC )
	
	cXml += "<ideFont>"
	cXml +=		xTafTag("cnpjFont"  , V97->V97_NRINSF)
	If V98->( MsSeek( xFilial( "V98", V97->V97_FILIAL ) + V97->( V97_ID + V97_VERSAO) ) )
		While V98->( !Eof() ) .And. V98->( V98_FILIAL + V98_ID + V98_VERSAO ) == V97->( V97_FILIAL + V97_ID + V97_VERSAO )
			
			cXml += "<ideRend>"
			cXml +=		xTafTag("natRend"  , V98->V98_NATREN)
			cXml +=		xTafTag("observ"  , V98->V98_OBS,,.T.)
			If V99->( MsSeek( xFilial( "V99", V97->V97_FILIAL) + V97->( V97_ID + V97_VERSAO) + V98->V98_NATREN ) )
				While V99->( !Eof() ) .And. V99->( V99_FILIAL + V99_ID + V99_VERSAO + V99_NATREN ) == V97->( V97_FILIAL + V97_ID + V97_VERSAO ) + V98->V98_NATREN
					cDataFg := DToS(V99->V99_DATAFG)
					cXml += "<infoRec>"
					cXml +=		xTafTag( "dtFG"		, Substr( cDataFg, 1, 4 ) + '-' + Substr( cDataFg, 5, 2 ) + '-' + Substr( cDataFg ,7 ) )
					cXml +=		xTafTag( "vlrBruto"	, V99->V99_VLRBRU, "@E 99999999999.99",,.F. )
					cXml +=		xTafTag( "vlrBaseIR", V99->V99_BASEIR, "@E 99999999999.99",,.F. )
					cXml +=		xTafTag( "vlrIR"	, V99->V99_VLRIR , "@E 99999999999.99",.T.,.F., .F. )
					If lReinf212
						cXml +=		xTafTag( "observ"   , V99->V99_OBSERV,,.T.)
					Endif

					If V9A->( MsSeek( xFilial( "V9A", V97->V97_FILIAL) + V97->( V97_ID + V97_VERSAO) + V98->V98_NATREN + dToS(V99->V99_DATAFG) ) )
						While V9A->( !Eof() ) .And. V9A->( V9A_FILIAL + V9A_ID + V9A_VERSAO + V9A_NATREN + dToS(V9A_DATAFG) ) == V97->( V97_FILIAL + V97_ID + V97_VERSAO ) + V98->V98_NATREN + dToS(V99->V99_DATAFG)
							
							xTafTagGroup("infoProcRet",{;
											{	"tpProcRet"		,V9A->V9A_TPPROC ,,.F.},;
											{	"nrProcRet"		,AllTrim(V9A->V9A_NRPROC) ,,.F.},;
											{	"codSusp"		,AllTrim(V9A->V9A_CODSUS) ,,.T.},;
											{	"vlrBaseSuspIR"	,V9A->V9A_BSUSIR , "@E 99999999999.99",.T.,.F.},;
											{	"vlrNIR"		,V9A->V9A_VSUSIR , "@E 99999999999.99",.T.,.F.},;
											{	"vlrDepIR"		,V9A->V9A_VLRDEP , "@E 99999999999.99",.T.,.F.}},;
										@cXml)
							
							V9A->( DbSkip() )
						EndDo
					EndIf
					
					cXml += "</infoRec>"
					V99->( DbSkip() )
				EndDo
			EndIf
			cXml += "</ideRend>"
			
			V98->( DbSkip() )
		EndDo
	EndIf
	cXml += "</ideFont>"
	cXml += "</ideEstab>"
	cXml := TAFXmlReinf( cXml, "V97", cLayout, cReg, cPeriodo,, cNameXSD)

	If !lJob
		xTafGerXml( cXml, cLayout,,,,,,"R-" )
	EndIf


Return(cXml)
