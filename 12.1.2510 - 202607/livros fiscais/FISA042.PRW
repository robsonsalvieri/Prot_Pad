#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA042.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FISA042  ºAutor  ³ Vitor Felipe       º Data ³ 11/11/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Cadastro da tabela de Ajuste EFD PIS/COFINS               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA042()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CF5")
	oBrowse:SetDescription(STR0001) //"Cadastro de Ajustes de Credito SPED PIS e COFINS"
	oBrowse:AddLegend( "CF5_INDAJU=='0'", "RED", STR0002 ) // "Ajuste de Redução"
	oBrowse:AddLegend( "CF5_INDAJU=='1'", "GREEN", STR0003 ) // "Ajuste de Acréscimo"
	oBrowse:Activate()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef       ºAutor  ³ Vitor Felipe       º Data ³ 11/11/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definicao do MenuDef para o MVC                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

	Local aRotina    := {}	
	Local lAjuPisCof := FindFunction('totvs.protheus.backoffice.fiscal.fisa001.adjustment.facilitatorPisCofins', .T.) .And. fExistCF5()
	
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA042' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA042' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA042' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA042' OPERATION 5 ACCESS 0 //'Excluir'
		
	If lAjuPisCof
		ADD OPTION aRotina TITLE 'Facilitador de Lançamentos' ACTION 'totvs.protheus.backoffice.fiscal.fisa001.adjustment.facilitatorPisCofins' OPERATION 3 ACCESS 0 //'Facilitador PIS/COFINS'
	EndIf

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ModelDef      ºAutor  ³ Vitor Felipe       º Data ³ 11/11/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definicao do ModelDef para o MVC.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Objeto                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct( 1 , "CF5" )
	
	oModel	:=	MPFormModel():New('FISA042MOD', ,{ |oModel| ValidForm(oModel) }  )
	
	oModel:AddFields( 'FISA042MOD' ,, oStructCAB )
	 
	oModel:SetPrimaryKey({"CF5_CODIGO"},{"CF5_INDAJU"},{"CF5_PISCOF"},{"CF5_CODAJU"},{"DTOS(CF5_DTREF)"})

	oModel:SetDescription(STR0009) // "Ajuste de Creditos PIS e Cofins"
	
Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ViewDef       ºAutor  ³ Vitor Felipe       º Data ³ 11/11/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definicao da Visualizacao para o MVC.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Objeto                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel( "FISA042" )
	Local oStructCAB := FWFormStruct( 2 , "CF5" )

	oView:SetModel(oModel)

	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA042MOD')

	oView:CreateHorizontalBox( "CABEC" , 100 )

	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )
	
Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidForm     ºAutor  ³ Erick G Dias       º Data ³ 03/0102011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação das informações digitadas no form.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Objeto                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidForm(oModel)

	Local lRet			:=	.T.
	Local cEndAju		:=	oModel:GetValue ('FISA042MOD','CF5_INDAJU')
	Local cPISCOF		:=	oModel:GetValue ('FISA042MOD','CF5_PISCOF')
	Local cCodAju		:=	oModel:GetValue ('FISA042MOD','CF5_CODAJU')
	Local cDtRef		:=	oModel:GetValue ('FISA042MOD','CF5_DTREF')
	Local cCodCred		:=	""
	Local cChave		:=	""
	Local nOperation	:=	oModel:GetOperation()
	
	If nOperation == 3  //Inclusão de informações ou alterações.
		DbSelectArea ("CF5")
		CF5->(DbSetOrder (1))
		
		cCodCred:= oModel:Getvalue('FISA042MOD','CF5_CODCRE')
		cChave  := oModel:Getvalue('FISA042MOD','CF5_CODIGO') + (cEndAju+cPISCOF+cCodAju+Dtos(cDtRef)+cCodCred) 
		If CF5->(DbSeek(xFilial("CF5")+cChave))
			lRet := .F.
			Help("",1,"Help","Help",STR0010,1,0) //"Ind. de Ajuste, Pis ou COFINS, Cod. de Ajuste e Data Referencial já cadastrados!"
		EndIF
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A042TIPAJU
Cria opcoes e o valid para o campo CF5_TIPAJU (X3_CBOX)
Parametro: nOpc -> 0 retorna validacao para funcao pertence
                   1 retorna as opcoes de escolha para o usuario

@author flavio.luiz
@since 05/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function A042TIPAJU(nOpc)
Local nI   := 1
Local cRet := ""
Local aOpc := {}

AADD(aOpc,"01=Ajuste da CPRB: Adoção do Regime de Caixa")
AADD(aOpc,"02=Ajuste da CPRB: Diferimento de Valores a recolher no período")
AADD(aOpc,"03=Adição de valores Diferidos em Período(s) Anteriores(es)")
AADD(aOpc,"04=Exportações diretas")
AADD(aOpc,"05=Transporte internacional de cargas")
AADD(aOpc,"06=Vendas canceladas e os descontos incondicionais concedidos")
AADD(aOpc,"07=IPI, se incluído na receita bruta")
AADD(aOpc,"08=ICMS, quando cobrado pelo vendedor dos bens ou prestador dos serviços na condição de substituto tributário")
AADD(aOpc,"09=Receita bruta reconhecida pela construção, recuperação, reforma, ampliação ou melhoramento da infraestrutura, cuja contrapartida seja ativo intangível representativo de direito de exploração, no caso de contratos de concessão de serviços públicos")
AADD(aOpc,"10=O valor do aporte de recursos realizado nos termos do art 6 §3 inciso III da Lei 11.079/2004")
AADD(aOpc,"11=Demais ajustes oriundos da Legislação Tributária, estorno ou outras situações")

For nI:=1 To Len(aOpc)
	If nOpc==0
		cRet += IIf(empty(cRet),' ',';') + Left(aOpc[nI],2)
	Else
		cRet += IIf(empty(cRet),'',';') + aOpc[nI]
	Endif
Next

If nOpc==0
	cRet := &("Pertence('"+cRet+"')")
Endif

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Mensagem Unica

@return aRet

@author Flavio L Vicco
@since 05/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage, cVersion)

Local aRet

// Chama a rotina que trata a parte principal
aRet := FISI042( cXML, nTypeTrans, cTypeMessage, cVersion )
//
Return aRet


/*/ {Protheus.doc} A042CODAJU
	(Cria opcoes para o campo CF5_CODAJU (X3_CBOX)
	Conteúdo da tabela: 4.3.8 - Tabela Código de Ajustes de Contribuição ou Crédito)
	@type Function
	@author Delleon Fernandes
	@Data 23/04/2026
	@return xRetorno, caracter ou array, retorna o combobox do campo CF5_CODAJU
/*/

Function A042CODAJU()
Local cRet := ""

cRet := "01=Ajuste Oriundo de Ação Judicial"
cRet += ";02=Ajuste Oriundo de Processo Administrativo"
cRet += ";03=Ajuste Oriundo da Legislação Tributária"
cRet += ";04=Ajuste Oriundo Especificamente do RTT"
cRet += ";05=Ajuste Oriundo de Outras Situações"
cRet += ";06=Estorno"
cRet += ";07=Ajuste Oriundo da Legislação Tributária - Adoção do Regime de Caixa - CPRB (Lei nº 12.546/2011, art. 9º, § 12)"
cRet += ";08=Ajuste Oriundo da Legislação Tributária - Diferimento de Valores a Recolher no Período - CPRB (Lei nº 12.546/2011, art. 9º, § 12)"
cRet += ";09=Ajuste Oriundo da Legislação Tributária - Adição de Valores Diferidos em Período(s) Anterior(es) - CPRB (Lei nº 12.546/2011, art. 9º, § 12)"
cRet += ";10=Ajuste referente à redução linear dos incentivos e benefícios de natureza tributária, financeira ou creditícia - isenção (LCP nº 224/2025 e art. 8º da IN RFB nº 2.305/2025)"
cRet += ";11=Ajuste referente à redução linear dos incentivos e benefícios de natureza tributária, financeira ou creditícia - alíquota zero (LCP nº 224/2025 e art. 8º da IN RFB nº 2.305/2025)"
cRet += ";12=Ajuste referente à redução linear dos incentivos e benefícios de natureza tributária, financeira ou creditícia - concessão de crédito tributário (LCP nº 224/2025 e art. 10º da IN RFB nº 2.305/2025)"

Return (cRet)

/*/{Protheus.doc} fExistCF5
	(Verifica se os campos necessários da tabela CF5 estão na base de dados)
	@type  Static Function
	@author Delleon Fernandes
	@since 12/05/2026
	@version 12.1.2510
	@param n/a
	@return lógico, retorna verdadeiro se os campos necessários existirem ou falso caso contrário
/*/
Static Function fExistCF5()
Local aArea := GetArea()
Local lFieldsCF5 := .F.
Local lFieldsCLA := .F.

DbSelectArea("CF5")
lFieldsCF5 := FieldPos("CF5_FILDOC") > 0 .And. ;
				FieldPos("CF5_TIPOMO") > 0 .And. ;
				FieldPos("CF5_SERDOC") > 0 .And. ;
				FieldPos("CF5_DOCNF") > 0 .And. ;
				FieldPos("CF5_CLIFOR") > 0 .And. ;
				FieldPos("CF5_LOJA") > 0 .And. ;
				FieldPos("CF5_CHVDFE") > 0
	
DbSelectArea("CLA")
lFieldsCLA := FieldPos("CLA_CHVDFE") > 0

RestArea(aArea)
Return  lFieldsCF5 .And. lFieldsCLA
