#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA543.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA543
Cadastro MVC do R-4040 - Pagamentos/créditos a beneficiários não identificados

@author Katielly Feitosa Rezende / Denis Souza 		
@since 10/05/2022
@version 1.0
*/
Function TAFA543()

If TAFAlsInDic( "V4N" ) 
	BrowseDef()
Else
	Aviso(STR0001, TafAmbInvMsg(), { STR0002 }, 3 ) //"O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário aplicar o dicionário de dados do REINF 2.0."
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao MVC com as opcoes de menu

@author Katielly Rezende / Denis Souza			
@since 10/05/2022
@version 1.0
/*/
Static Function MenuDef()

Local aFuncao   as array
Local aRotina   as array
Local lReinf20  as logical

aFuncao := {}
aRotina := {}
lReinf20 := AllTrim(StrTran(SuperGetMv('MV_TAFVLRE',.F.,''),'_','')) >= '20101'

If lReinf20
	aAdd( aFuncao, { "", "TAF543Xml", "1" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V4N', 'R-4040', 'BenefNId', 'TAF543Xml', 5, oBrowse)", "5" } )
	aRotina := TAFMenuReinf( "TAFA543", aFuncao )

else
	ADD OPTION aRotina Title STR0024 Action 'VIEWDEF.TAFA543' OPERATION 2 ACCESS 0
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao  MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Rezende / Denis Souza		
@since 10/05/2022
@version 1.0
/*/
Static Function ModelDef()

Local oStruV4N as object
Local oStruV4O as object                                                                      
Local oStruV4P as object
Local oStruV9C as object
Local oModel   as object

oModel :=  MPFormModel():New( 'TAFA543')

oStruV4N := FWFormStruct( 1, 'V4N')
oStruV4O := FWFormStruct( 1, 'V4O')
oStruV4P := FWFormStruct( 1, 'V4P')
oStruV9C := FWFormStruct( 1, 'V9C')

oModel:AddFields( 'MODEL_V4N', , oStruV4N)
oModel:GetModel ( 'MODEL_V4N' ):SetPrimaryKey( { "V4N_PERAPU" } )

oModel:AddGrid ( 'MODEL_V4O', 'MODEL_V4N', oStruV4O)
oModel:GetModel( 'MODEL_V4O'):SetUniqueLine({ 'V4O_NATREN' })
oModel:GetModel( 'MODEL_V4O' ):SetOptional( .F. )

oModel:AddGrid ( 'MODEL_V4P', 'MODEL_V4O', oStruV4P)
oModel:GetModel( 'MODEL_V4P'):SetUniqueLine({'V4P_DATAFG'})
oModel:GetModel( 'MODEL_V4P' ):SetOptional( .F. )

oModel:addgrid('MODEL_V9C','MODEL_V4P', oStruV9C)
oModel:GetModel('MODEL_V9C'):SetOptional(.T.)
oModel:GetModel("MODEL_V9C"):SetUniqueLine({'V9C_IDPROC','V9C_CODSUS'})
oModel:GetModel('MODEL_V9C'):SetMaxLine(50)

oModel:SetRelation("MODEL_V4O",{ {"V4O_FILIAL","xFilial('V4O')"}, {"V4O_ID","V4N_ID"}, {"V4O_VERSAO","V4N_VERSAO"}} , V4O->(IndexKey(1)) )
oModel:SetRelation("MODEL_V4P",{ {"V4P_FILIAL","xFilial('V4P')"}, {"V4P_ID","V4N_ID"}, {"V4P_VERSAO","V4N_VERSAO"}, {"V4P_NATREN" ,"V4O_NATREN"}}, V4P->(IndexKey(1)) )

//V9C_FILIAL, V9C_ID, V9C_VERSAO, V9C_NATREN, V9C_DATAFG, V9C_IDPROC, V9C_CODSUS, R_E_C_N_O_, D_E_L_E_T_
oModel:SetRelation("MODEL_V9C",{ {"V9C_FILIAL","xFilial('V9C')"}, {"V9C_ID","V4N_ID"}, {"V9C_VERSAO","V4N_VERSAO"}, {"V9C_NATREN","V4O_NATREN"}, {"V9C_DATAFG","V4P_DATAFG"}},V9C->(IndexKey(1)))

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Rezende / Denis Souza			
@since 10/05/2022
@version 1.0
/*/
Static Function ViewDef()
Local oModel   	as object
Local oView		as object
Local oStruV4N  as object
Local oStruV4Nb as object
Local oStruV4O  as object                                                                      
Local oStruV4P  as object
Local oStruV9C  as object
Local cCmpFil   as char
 
cCmpFil   := ''
oModel    := FWLoadModel( 'TAFA543' )
oView	  := FWFormView():New()
oStruV4N  := FWFormStruct( 2, 'V4N')
oStruV4O  := FWFormStruct( 2, 'V4O')
oStruV4P  := FWFormStruct( 2, 'V4P')
oStruV9C  := FWFormStruct( 2, 'V9C')

cCmpFil   := 'V4N_PROTUL|'
oStruV4Nb := FwFormStruct( 2, 'V4N', {|x| AllTrim( x ) + "|" $ cCmpFil } )

oStruV4N:RemoveField('V4N_ID')
oStruV4N:RemoveField('V4N_VERSAO')
oStruV4N:RemoveField('V4N_VERANT')
oStruV4N:RemoveField('V4N_STATUS')
oStruV4N:RemoveField('V4N_PROTPN')
oStruV4N:RemoveField('V4N_EVENTO')
oStruV4N:RemoveField('V4N_ATIVO')
oStruV4N:RemoveField('V4N_PROTUL')

oStruV4O:RemoveField('V4O_IDNTRE')

oStruV9C:RemoveField('V9C_ID')
oStruV9C:RemoveField('V9C_VERSAO')

oView:SetModel( oModel )
oView:SetContinuousForm(.T.)

oView:CreateHorizontalBox( 'BOXH_MASTER', 100)
oView:CreateFolder("FOLDER_MASTER","BOXH_MASTER")
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_MASTER', STR0010 ) //"R-4040 ideEstab"
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_PROTUL', STR0011 ) //"Recibo"

oView:AddField("VIEW_V4N", oStruV4N, "MODEL_V4N" )
oView:EnableTitleView("VIEW_V4N", STR0012 ) //"Informações de identificação do estabelecimento"
oView:CreateHorizontalBox("PAINEL_SUPERIOR", 30,,,"FOLDER_MASTER","SHEET_MASTER" )
oView:SetOwnerView( "VIEW_V4N", "PAINEL_SUPERIOR" )

oView:AddField("VIEW_V4Nb", oStruV4Nb, "MODEL_V4N" )
oView:EnableTitleView("VIEW_V4Nb", STR0013 ) //"Recibo R-4040 - Pagamentos/créditos a beneficiários não identificados"

oView:CreateHorizontalBox("PAINEL_SUPERIORB", 30,,,"FOLDER_MASTER","SHEET_PROTUL" )
oView:SetOwnerView( "VIEW_V4Nb", "PAINEL_SUPERIORB" )

//Nivel1
oView:CreateHorizontalBox( 'BOXH0_PAI', 30,,,"FOLDER_MASTER","SHEET_MASTER")
oView:CreateFolder("FOLDER_TOPLEFT","BOXH0_PAI")
oView:AddSheet( 'FOLDER_TOPLEFT', 'SHEET_TOPLEFT', STR0014 ) //"ideNat"

oView:CreateHorizontalBox("BOXH1_PAI",30,,,"FOLDER_TOPLEFT","SHEET_TOPLEFT")
oView:AddGrid("VIEW_V4O", oStruV4O,"MODEL_V4O" )
oView:EnableTitleView("VIEW_V4O", STR0015 ) //"Identificação da natureza do rendimento"
oView:SetOwnerView( "VIEW_V4O", "BOXH1_PAI" )

//Nivel2
oView:CreateHorizontalBox( 'BOXH0_FILHO', 20,,,"FOLDER_TOPLEFT","SHEET_TOPLEFT")
oView:CreateFolder("FOLDER_INFOREC","BOXH0_FILHO")
oView:AddSheet( 'FOLDER_INFOREC', 'SHEET_INFOREC', STR0016 ) //"infoPgto"

oView:CreateHorizontalBox( 'BOXH1_FILHO', 20,,,"FOLDER_INFOREC","SHEET_INFOREC")
oView:AddGrid("VIEW_V4P", oStruV4P,"MODEL_V4P" )
oView:EnableTitleView("VIEW_V4P", STR0017 ) //"Informações de pagamentos a beneficiários não indentificados."
oView:SetOwnerView( "VIEW_V4P", "BOXH1_FILHO" )

//Nivel3
oView:CreateHorizontalBox( 'BOXH0_NETO', 20,,,"FOLDER_TOPLEFT","SHEET_TOPLEFT")
oView:CreateFolder("FOLDER_PROCRET","BOXH0_NETO")
oView:AddSheet( 'FOLDER_PROCRET', 'SHEET_PROCRET', STR0018 ) //"infoProcRet"

oView:CreateHorizontalBox( 'BOXH1_NETO', 20,,,"FOLDER_PROCRET","SHEET_PROCRET")
oView:AddGrid("VIEW_V9C", oStruV9C,"MODEL_V9C" )
oView:EnableTitleView("VIEW_V9C", STR0019 ) //"Informações de processos relacionados a não retenção de tributos ou a depósitos judiciais."
oView:SetOwnerView( "VIEW_V9C", "BOXH1_NETO" )

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Denis Souza
@since 18/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local aFuncao := {}
Local aRotina := {}

Private oBrowse	as object

oBrowse	:=	FWMBrowse():New()

aRotina := TAFMenuReinf( "TAFA543", aFuncao )

oBrowse:SetDescription( STR0020 ) //"Pagamentos/créditos a beneficiários não identificados"
oBrowse:SetAlias( "V4N" )
oBrowse:SetMenuDef( "TAFA543" )
oBrowse:SetFilterDefault( "V4N_ATIVO == '1'" )

TAFLegReinf( "V4N", oBrowse)

oBrowse:Activate()

Return( oBrowse )

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
DBSelectArea('V4N')
V4N->(DBGoTo(nRecno))

//Informações para gravação do rastro
cVerAnt := V4N->V4N_VERSAO
cRecibo := V4N->V4N_PROTUL

//Gero uma nova versão para o registro que será incluido!
cVersao := xFunGetVer() 

Begin Transaction

	//Seto o registro como Inativo
	FAltRegAnt( 'V4N', '2' )

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
				xValue := decodeutf8(xValue)
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
		TAFAltStat( 'V4N', '6' ) 

	next	

end Transaction

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA543Xml
Funcao de geracao do XML para atender o registro R-4040
Quando a rotina for chamada o registro deve estar posicionado

@Return:cXml
cXml - Estrutura do Xml do Layout R-4040

@author almeida.veronica
@since 17/11/2022

@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF543Xml(cAlias,nRecno,nOpc,lJob)
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

	V4O->( DBSetOrder( 1 ) ) // V4O_FILIAL+V4O_ID+V4O_VERSAO+V4O_NATREN
	V4P->( DBSetOrder( 1 ) ) // V4P_FILIAL+V4P_ID+V4P_VERSAO+V4P_NATREN+DTOS(V4P_DATAFG)
	V9C->( DBSetOrder( 1 ) ) // V9C_FILIAL+V9C_ID+V9C_VERSAO+V9C_NATREN+DTOS(V9C_DATAFG)+V9C_IDPROC+V9C_CODSUS

	cXml        := ""
	cLayout     := "4040"
	cReg        := "BenefNId"
	cId         := ""
	cVerAnt     := ""
	cNameXSD    := "4040PagtoBenefNaoIdentificado"
	cAliasTemp  := GetNextAlias()
	cPeriodo	:= Substr( V4N->V4N_PERAPU, 3 ) + "-" + Substr( V4N->V4N_PERAPU, 1, 2 )
	lReinf212   := TAFColumnPos( "V4N_EVADIC" )

	cXml += "<ideEstab>"	
	cXml += xTafTag( "tpInscEstab", V4N->V4N_TPINSC )
	cXml += xTafTag( "nrInscEstab", V4N->V4N_NRINSC )

	If lReinf212
		cXml +=	xTafTag("ideEvtAdic" , V4N->V4N_EVADIC,,.T.)
	EndIf

	If V4O->( MsSeek( xFilial( "V4O", V4N->V4N_FILIAL ) + V4N->( V4N_ID + V4N_VERSAO) ) )
		While V4O->( !Eof() ) .And. V4O->( V4O_FILIAL + V4O_ID + V4O_VERSAO ) == V4N->( V4N_FILIAL + V4N_ID + V4N_VERSAO )
			
			cXml += "<ideNat>"
			cXml +=		xTafTag("natRend"  , V4O->V4O_NATREN)

			If V4P->( MsSeek( xFilial( "V4P", V4N->V4N_FILIAL) + V4N->( V4N_ID + V4N_VERSAO) + V4O->V4O_NATREN ) )
				While V4P->( !Eof() ) .And. V4P->( V4P_FILIAL + V4P_ID + V4P_VERSAO + V4P_NATREN ) == V4N->( V4N_FILIAL + V4N_ID + V4N_VERSAO ) + V4O->V4O_NATREN

					cDataFg := DToS(V4P->V4P_DATAFG)

					cXml += "<infoPgto>"

					cXml +=		xTafTag( "dtFG"		, Substr( cDataFg, 1, 4 ) + '-' + Substr( cDataFg, 5, 2 ) + '-' + Substr( cDataFg ,7 ) )

					If V4O->V4O_NATREN != "12052"
						cXml +=	xTafTag( "vlrLiq"	, V4P->V4P_VLRLIQ, "@E 99999999999.99",,.F. )
					Endif

					cXml +=		xTafTag( "vlrBaseIR", V4P->V4P_BASEIR, "@E 99999999999.99",,.F. )
					cXml +=		xTafTag( "vlrIR"	, V4P->V4P_VLRIR , "@E 99999999999.99",.T.,.F. , .F. )															

					If lReinf212 
						If V4O->V4O_NATREN == "12052" .And. !Empty(V4P->V4P_DTESCO)
							cXml +=	xTafTag("dtEscrCont", Substr(DTOS(V4P->V4P_DTESCO),1,4 ) + '-' + Substr(DTOS(V4P->V4P_DTESCO),5,2 )+ '-' + Substr(DTOS(V4P->V4P_DTESCO),7,2 ) )
						EndIf	
					EndIf	
					
					cXml +=		xTafTag( "descr"	, AllTrim( V4P->V4P_DESCRI ) )

					If V9C->( MsSeek( xFilial( "V9C", V4N->V4N_FILIAL) + V4N->( V4N_ID + V4N_VERSAO) + V4O->V4O_NATREN + dToS(V4P->V4P_DATAFG) ) )
						While V9C->( !Eof() ) .And. V9C->( V9C_FILIAL + V9C_ID + V9C_VERSAO + V9C_NATREN + dToS(V9C_DATAFG) ) == V4N->( V4N_FILIAL + V4N_ID + V4N_VERSAO ) + V4O->V4O_NATREN + dToS(V4P->V4P_DATAFG)
							
							xTafTagGroup("infoProcRet",{;
											{	"tpProcRet"		,V9C->V9C_TPPROC ,,.F.},;
											{	"nrProcRet"		,AllTrim(V9C->V9C_NRPROC) ,,.F.},;
											{	"codSusp"		,AllTrim(V9C->V9C_CODSUS) ,,.T.},;
											{	"vlrBaseSuspIR"	,V9C->V9C_BSUSIR , "@E 99999999999.99",.T.,.F.},;
											{	"vlrNIR"		,V9C->V9C_VSUSIR , "@E 99999999999.99",.T.,.F.},;
											{	"vlrDepIR"		,V9C->V9C_VLRDEP , "@E 99999999999.99",.T.,.F.}},;
										@cXml)
							
							V9C->( DbSkip() )
						EndDo
					EndIf
					
					cXml += "</infoPgto>"
					V4P->( DbSkip() )
				EndDo
			EndIf

			cXml += "</ideNat>"
			
			V4O->( DbSkip() )
		EndDo
	EndIf

	cXml += "</ideEstab>"

	cXml := TAFXmlReinf( cXml, "V4N", cLayout, cReg, cPeriodo,, cNameXSD)

	If !lJob
		xTafGerXml( cXml, cLayout,,,,,,"R-" )
	EndIf

Return(cXml)
