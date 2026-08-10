#INCLUDE 'TECA740.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"

STATIC oCharge		:= Nil
STATIC lDoCommit	:= .F.
STATIC cXmlDados	:= ''
STATIC cXmlCalculo	:= ''
STATIC aCancReserv	:= {}
STATIC nTLuc		:= 0
STATIC nTAdm		:= 0
STATIC nDeduc		:= 0
STATIC lCalcEnc		:= .T.
STATIC aObriga		:= {}
STATIC lTotLoc		:= .F.
STATIC lDelTWO		:= .F.
STATIC lUnDel		:= .F.
STATIC aPlanData 	:= {}
Static aRevPlaIten	:= {}
STATIC lImpToADZ 	:= .F.
STATIC lTEC740FUn 	:= .F.
STATIC lPutLeg		:= .F.
Static aEnceCpos	:= {}
STATIC lAlterTWO 	:= .F.
Static dPerCron		:= CtoD('')
Static lGsPrecific  := .F.
Static lGsOrcVerb	:= .F.
Static lNovoFacil	:= At740NvFac()
Static cRetFunc		:= ""
Static lTemRUK		:= FWAliasInDic("RUK")
Static _oQryVlLoc	:= Nil
Static nSaveSx8Len  := 0 
Static cGridFocus   := ""
Static aControle    := {}
Static aBenefTFF	:= {}

/*
Array aEnceCpos - Este array é preenchido automáticamente sempre que um campo de um item encerrado é alterado.
Apenas campos que influênciam o valor do orçamento entram nesse array.
Para locação de equipamento, considera-se a grid da TEV


	aEnceCpos[x]
		[1] = Nome da tabela que o campo pertence
		[2] = Código único do campo (Exemplo: TFF_COD)
		[3] = Código único do pai do campo
		[4] = Nome do campo
		[5] = Valor do campo antes da primeira alteração
*/
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA740
Nova interface para orçamento de serviços

@sample 	 TECA740()
@since		 20/08/2013
@version 	 P11
/*/
//------------------------------------------------------------------------------
Function TECA740()

Local oBrw := FwMBrowse():New()

oBrw:SetAlias( 'TFJ' )
oBrw:SetMenudef( 'TECA740' )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) //'Orçamento para Serviços'
If !(isBlind())
	oBrw:Activate()
Else
	oBrw := nil
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Criacao do MenuDef.

@sample 	Menudef()
@param		Nenhum
@return	 	aMenu, Array, Opção para seleção no Menu
@since		20/00/2013
@version	P11
/*/
//------------------------------------------------------------------------------
Static Function Menudef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA740' OPERATION 2 ACCESS 0	// "Visualizar"

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@since 10/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel  := Nil
Local oMdlCalc:= Nil
Local oStrTFJ := FWFormStruct(1,'TFJ')
Local oStrTFL := FWFormStruct(1,'TFL')
Local oStrTFF := FWFormStruct(1,'TFF')
Local oStrTFG := FWFormStruct(1,'TFG')
Local oStrTFH := FWFormStruct(1,'TFH')
Local oStrTFI := FWFormStruct(1,'TFI')
Local oStrTFU := FWFormStruct(1,'TFU')
Local oStrABP := FWFormStruct(1,'ABP')
Local oStrTEV := FWFormStruct(1,'TEV')
Local oStrTXQ := Nil
Local oStrTXP := Nil
Local oStrABZ := Nil
Local xAux    := Nil
//referente fonte TECA741 - Habilidades, Características e Cursos para o item de RH
Local oStrTGV := FWFormStruct(1,'TGV')
Local oStrTDS := FWFormStruct(1,'TDS')
Local oStrTDT := FWFormStruct(1,'TDT')
//Referente aos itens do Facilitador
Local oStrTWO     := FwFormStruct(1,'TWO')
Local oStrCusto   := Nil
Local nI	      := 1
Local aModelsId   := {}
Local lVersion23  := HasOrcSimp()
Local lTecItExtOp := IsInCallStack("At190dGrOrc")
Local lGsOrcUnif  := FindFunction("TecGsUnif") .And. TecGsUnif()
Local bFormTot	  := {|oModel| oModel:GetValue("TOTAIS","TOT_RH")+oModel:GetValue("TOTAIS","TOT_MI")+oModel:GetValue("TOTAIS","TOT_MC")+oModel:GetValue("TOTAIS","TOT_LE")}
Local bFormTotEn  := {|oModel| oModel:GetValue("CALC_TFL_NE","TOT_RH_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MI_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MC_EN")+oModel:GetValue("CALC_TFL_NE","TOT_LE_EN") - nDeduc}
Local lGsOrcArma  := FindFunction("TecGsArma") .And. TecGsArma()
Local cFormula    := ""
Local lTec855 	  := IsInCallStack("TECA855")
Local lVlrCon     := TFF->( ColumnPos('TFF_VLRCON') ) > 0
Local lQtdUni     := TXP->( ColumnPos('TXP_QTDUNI') ) > 0
Local lDesagrupad	:= SuperGetMv("MV_GSITORC",,"2") == "1"

//Fernando Radu Muscalu. Acrescentado em 10/11/2023 - DSERSGS-17319
Local bCalendGatilho := {	|oSubTFL,cCampo,xConteudo| CalendGatilho(oSubTFL,cCampo,xConteudo)}
Local bCalendInicia	:= {	|oSubTFF,cCampo| CalendInicia(oSubTFF,cCampo)}
//Carrega staticas
lGsPrecific := At740Prcif()
lGsOrcVerb  := TableInDic("ABZ") //Verbas de Folha
nSaveSx8Len := GetSx8Len() 

If lGsOrcUnif
	oStrTXP := FWFormStruct(1,'TXP')
Endif

If lGsOrcArma
	oStrTXQ := FWFormStruct(1,'TXQ')
Endif

If lGsOrcVerb
	oStrABZ := FWFormStruct(1,'ABZ')
EndIf

If TFJ->(ColumnPos("TFJ_RESTEC"))>0
    oStrTFJ:RemoveField("TFJ_RESTEC")
EndIf 

If TFJ->(ColumnPos("TFJ_TREINA"))>0
    oStrTFJ:RemoveField("TFJ_TREINA")
EndIf

oStrCusto := FwFormStruct(1, "TFJ", {|cCpo| AllTrim( cCpo ) $ "TFJ_TOTCUS|TFJ_TOTGER" } )

If oStrTFJ:HasField("TFJ_TOTCUS")
    oStrTFJ:RemoveField("TFJ_TOTCUS")
EndIf
If oStrTFJ:HasField("TFJ_TOTGER")
    oStrTFJ:RemoveField("TFJ_TOTGER")
EndIf

lPutLeg := A740PutLeg()
nDeduc := 0
lCalcEnc := .T.

oStrTFF:AddField(	"" , ;						// [01] C Titulo do campo
					"" , ;						// [02] C ToolTip do campo
					"TFF_LEGEND" , ;			// [03] C identificador (ID) do Field
					"C" , ;						// [04] C Tipo do campo
					50 , ;						// [05] N Tamanho do campo
					0 , ;						// [06] N Decimal do campo
					NIL , ;						// [07] B Code-block de validação do campo
					NIL , ;						// [08] B Code-block de validação When do campo
					NIL , ;						// [09] A Lista de valores permitido do campo
					NIL , ;						// [10] L Indica se o campo tem preenchimento obrigatório
					{|| "BR_BRANCO"} , ;		// [11] B Code-block de inicializacao do campo
					NIL , ;						// [12] L Indica se trata de um campo chave
					NIL , ;						// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )						// [14] L Indica se o campo é virtual

xAux := FwStruTrigger( 'TFJ_GESMAT', 'TFJ_GESMAT', 'At740TrGMat()')
oStrTFJ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

If lVlrCon
	xAux := FwStruTrigger( 'TFF_VLRMAT', 'TFF_VLRMAT', 'At740TrgGer( "CALC_TFG", "TOT_MI", "TFF_RH", "TFF_TOTMI" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_VLRCON', 'TFF_VLRCON', 'At740TrgGer( "CALC_TFH", "TOT_MC", "TFF_RH", "TFF_TOTMC" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

xAux := FwStruTrigger( 'TFG_TOTGER', 'TFG_TOTGER', 'At740TrgGer( "CALC_TFG", "TOT_MI", "TFF_RH", "TFF_TOTMI" )', .F. )
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_TOTGER', 'TFH_TOTGER', 'At740TrgGer( "CALC_TFH", "TOT_MC", "TFF_RH", "TFF_TOTMC" )', .F. )
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

If !IsInCallStack("At870GerOrc")
	xAux := FwStruTrigger( 'TFF_SUBTOT', 'TFF_SUBTOT', 'At740TrgGer( "CALC_TFF", "TOT_RH", "TFL_LOC", "TFL_TOTRH" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTMI',  'TFF_TOTMI',  'At740TrgGer( "CALC_TFF", "TOT_RHMI", "TFL_LOC", "TFL_TOTMI" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTMC',  'TFF_TOTMC',  'At740TrgGer( "CALC_TFF", "TOT_RHMC", "TFL_LOC", "TFL_TOTMC" )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TEV_VLTOT',  'TEV_VLTOT',  'At740TrgGer( "CALC_TEV", "TOT_ADICIO", "TFI_LE", "TFI_TOTAL", "TFI_DESCON" )', .F. )
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFI_TOTAL',  'TFI_TOTAL',  'At740TrgGer( "CALC_TFI", "TOT_LE", "TFL_LOC", "TFL_TOTLE" )', .F. )
		oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

If TecABBPRHR()
	If IsInCallStack('At870Revis')
		xAux := FwStruTrigger( 'TFF_QTDVEN', 'TFF_QTDHRS', 'At740QTDHr( .T. )', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf
	xAux := FwStruTrigger( 'TFF_QTDHRS', 'TFF_HRSSAL', 'At740Horas()', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

If !IsInCallStack("At870GerOrc")
	xAux := FwStruTrigger( 'TFL_TOTRH',  'TFL_TOTRH', 'At740TrgGer( "TOTAIS", "TOT_RH", "TFJ_REFER", "TFJ_TOTRH" )', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMI',  'TFL_TOTMI', 'At740TrgGer( "TOTAIS", "TOT_MI", "TFJ_REFER", "TFJ_TOTMI" )', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMC',  'TFL_TOTMC', 'At740TrgGer( "TOTAIS", "TOT_MC", "TFJ_REFER", "TFJ_TOTMC" )', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTLE',  'TFL_TOTLE', 'At740TrgGer( "TOTAIS", "TOT_LE", "TFJ_REFER", "TFJ_TOTLE" )', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFI_TOTAL',  'TFI_VALDES', 'At740LeTot( "2" )',.F.) // calcula o valor de desconto
		oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFI_DESCON', 'TFI_VALDES', 'At740LeTot( "2" )',.F.)  // calcula o valor de desconto
		oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFI_DESCON', 'TFI_TOTAL', 'At740LeTot( "1" )',.F.)  // calcula o valor total considerando o desconto
		oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

xAux := FwStruTrigger( 'TFF_SUBTOT', 'TFF_TOTAL', 'At740InPad()',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_TOTMI', 'TFF_TOTAL', 'At740InPad()',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_TOTMC', 'TFF_TOTAL', 'At740InPad()',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
If GSGetIns('LE') .AND. !SuperGetMv("MV_ORCPRC",,.F.)
	xAux := FwStruTrigger( 'TFF_TXLUCR', 'TFF_SUBTOT', 'At740InSub()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TXADM', 'TFF_SUBTOT', 'At740InSub()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif
xAux := FwStruTrigger( 'TFH_DESCON', 'TFH_TOTGER', 'At740CDesc("TFH_MC","TFH_QTDVEN","TFH_PRCVEN","TFH_DESCON","TFH_TOTGER")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_DESCON', 'TFG_TOTGER', 'At740CDesc("TFG_MI","TFG_QTDVEN","TFG_PRCVEN","TFG_DESCON","TFG_TOTGER")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFF_DESCON', 'TFF_SUBTOT',  'At740CDesc("TFF_RH","TFF_QTDVEN","TFF_PRCVEN","TFF_DESCON","TFF_TOTAL")',.F.)
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TFU_CODABN', 'TFU_ABNDES', 'At740TrgABN()',.F.)
	oStrTFU:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'ABP_BENEFI', 'ABP_DESCRI', 'At740DeBenefi()',.F.)
	oStrABP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'ABP_VERBA', 'ABP_DSVERB', 'Posicione("SRV", 1, xFilial("SRV")+M->ABP_VERBA, "RV_DESC" )',.F.)
	oStrABP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'ABP_VERBA', 'ABP_TPVERB', 'At740TpVerb()',.F.)
	oStrABP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_UM', 'At740TrgTEV( "TEV_MODCOB" )',.F.)
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_MODCOB', 'At740SmTEV()',.F.)  // atribui zero ao valor unitário sempre que troca o modo de cobrança
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_QTDE', 'At740TEVQt()',.F.,/*Alias*/,/*Ordem*/,/*Chave*/,"M->TEV_MODCOB=='2'")
	oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_QTDVEN', 'TFI_QTDVEN', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_PERINI', 'TFI_PERINI', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_PERFIM', 'TFI_PERFIM', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_APUMED', 'TFI_APUMED', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_PRODUT', 'TFI_PRODUT', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_ENTEQP', 'TFI_ENTEQP', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFI_COLEQP', 'TFI_COLEQP', 'At740TEVQt(.T.)',.F.)
	oStrTFI:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//----------------------------------------------------------------------------------------
If !lGsPrecific
	xAux := FwStruTrigger( 'TFJ_LUCRO', 'TFJ_LUCRO', 'At740LdLuc("1")',.F.)
		oStrTFJ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFJ_ADM', 'TFJ_ADM', 'At740LdLuc("2")',.F.)
		oStrTFJ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif
//------------------------------------------------------------------------------------------
// Gatilhos - Recursos Humanos
//------------------------------------------------------------------------------------------
If GSGetIns('LE') .AND. !SuperGetMv("MV_ORCPRC",,.F.)
	xAux := FwStruTrigger( 'TFF_LUCRO', 'TFF_TXLUCR', 'At740RhVlr("1","TFF_RH","TFF")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_ADM', 'TFF_TXADM', 'At740RhVlr("2","TFF_RH","TFF")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFF_QTDVEN', 'TFF_TXLUCR', 'At740RhVlr("1","TFF_RH","TFF")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFF_QTDVEN', 'TFF_TXADM', 'At740RhVlr("2","TFF_RH","TFF")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFF_PRCVEN', 'TFF_TXLUCR', 'At740RhVlr("1","TFF_RH","TFF")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFF_PRCVEN', 'TFF_TXADM', 'At740RhVlr("2","TFF_RH","TFF")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif
If TecVlPrPar()
	xAux := FwStruTrigger( 'TFF_ADM', 'TFF_VLPRPA', 'At740PrxPa("TFF") ',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	If GSGetIns('LE') .AND. !SuperGetMv("MV_ORCPRC",,.F.)
		xAux := FwStruTrigger( 'TFF_LUCRO', 'TFF_VLPRPA', 'At740PrxPa("TFF") ',.F.)
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

		xAux := FwStrutrigger( 'TFF_VLPRPA', 'TFF_VLPRPA', 'At740AtTpr()',.F.)
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif
EndIf
//------------------------------------------------------------------------------------------
// Gatilhos - Cobrança Locação Equipamento
//------------------------------------------------------------------------------------------
If !lGsPrecific
	xAux := FwStruTrigger( 'TEV_LUCRO', 'TEV_TXLUCR', 'At740VlAcr("1","TEV_ADICIO","TEV")',.F.)
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TEV_ADM', 'TEV_TXADM', 'At740VlAcr("2","TEV_ADICIO","TEV")',.F.)
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TEV_QTDE', 'TEV_TXLUCR', 'At740VlAcr("1","TEV_ADICIO","TEV")',.F.)
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TEV_TXLUCR', 'TEV_VLTOT', 'At740VlTEV("TEV_ADICIO")',.F.)
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TEV_VLRUNI', 'TEV_TXLUCR', 'At740VlAcr("1","TEV_ADICIO","TEV")' ,.F.)
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TEV_QTDE', 'TEV_TXADM', 'At740VlAcr("2","TEV_ADICIO","TEV")',.F.)
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TEV_TXADM', 'TEV_VLTOT', 'At740VlTEV("TEV_ADICIO")',.F.)
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TEV_VLRUNI', 'TEV_TXADM', 'At740VlAcr("2","TEV_ADICIO","TEV")',.F.)
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif
//------------------------------------------------------------------------------------------
// Gatilhos - Materiais de Implantação
//------------------------------------------------------------------------------------------
If !lGsPrecific
	xAux := FwStrutrigger( 'TFG_LUCRO', 'TFG_TXLUCR', 'At740MatAc("1","TFG_MI","TFG")',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFG_LUCRO', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif
xAux := FwStrutrigger( 'TFG_TOTAL',  'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_PRCVEN', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_QTDVEN', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFG_VIDMES', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
If !lGsPrecific
	xAux := FwStrutrigger( 'TFG_ADM', 'TFG_TXADM', 'At740MatAc("2","TFG_MI","TFG")',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFG_ADM', 'TFG_TOTGER', 'At740VlTot("TFG_MI","TFG")',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFG_TOTGER', 'TFG_TXLUCR', 'At740MatAc("1","TFG_MI","TFG")',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFG_TOTGER', 'TFG_TXADM', 'At740MatAc("2","TFG_MI","TFG")',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif

If TecVlPrPar()
	If !lGsPrecific
		xAux := FwStruTrigger( 'TFG_ADM', 'TFG_VLPRPA', 'At740PrxPa("TFG") ',.F.)
			oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		xAux := FwStruTrigger( 'TFG_LUCRO', 'TFG_VLPRPA', 'At740PrxPa("TFG") ',.F.)
			oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif
	xAux := FwStruTrigger( 'TFG_VIDMES', 'TFG_VLPRPA', 'At740PrxPa("TFG")', .F. )
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFG_VLPRPA', 'TFG_VLPRPA', 'At740AtTpr()',.F.)
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
//------------------------------------------------------------------------------------------
// Gatilhos - Materiais de Consumo
//------------------------------------------------------------------------------------------
If !lGsPrecific
	xAux := FwStrutrigger( 'TFH_LUCRO', 'TFH_TXLUCR', 'At740MatAc("1","TFH_MC","TFH")',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFH_LUCRO', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif
xAux := FwStrutrigger( 'TFH_TOTAL',  'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_PRCVEN', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_QTDVEN', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TFH_VIDMES', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
If !lGsPrecific
	xAux := FwStrutrigger( 'TFH_ADM', 'TFH_TXADM', 'At740MatAc("2","TFH_MC","TFH")',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFH_ADM', 'TFH_TOTGER', 'At740VlTot("TFH_MC","TFH")',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFH_TOTGER', 'TFH_TXLUCR', 'At740MatAc("1","TFH_MC","TFH")',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TFH_TOTGER', 'TFH_TXADM', 'At740MatAc("2","TFH_MC","TFH")',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif
If TecVlPrPar()
	If !lGsPrecific
		xAux := FwStruTrigger( 'TFH_ADM', 'TFH_VLPRPA', 'At740PrxPa("TFH") ',.F.)
			oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

		xAux := FwStruTrigger( 'TFH_LUCRO', 'TFH_VLPRPA', 'At740PrxPa("TFH") ',.F.)
			oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif
	xAux := FwStrutrigger( 'TFH_VIDMES', 'TFH_VLPRPA', 'At740PrxPa("TFH")', .F. )
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	If TFF->( ColumnPos('TFF_VLRCOB') ) > 0
		xAux := FwStrutrigger( 'TFF_VLRCOB', 'TFF_VLPRPA', 'Iif(FwFldGet("TFJ_CNTREC")=="1",FwFldGet("TFF_VLRCOB"),0)',.F.)
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif
	xAux := FwStrutrigger( 'TFH_VLPRPA', 'TFH_VLPRPA', 'At740AtTpr()',.F.)
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
//-----------------------------------------------------------------------------------------
// Descrição do calendario
//-----------------------------------------------------------------------------------------
xAux := FwStruTrigger('TFF_CALEND','TFF_DSCALE','ALLTRIM( POSICIONE("AC0",1,XFILIAL("AC0")+M->TFF_CALEND,"AC0_DESC") )',.F.,Nil,Nil,Nil)
oStrTFF:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
//-----------------------------------------------------------------------------------------
// Descrição da escala
//-----------------------------------------------------------------------------------------
xAux := FwStruTrigger('TFF_ESCALA','TFF_NOMESC','ALLTRIM( POSICIONE("TDW",1,XFILIAL("TDW")+M->TFF_ESCALA,"TDW_DESC") )',.F.,Nil,Nil,Nil)
oStrTFF:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
//-----------------------------------------------------------------------------------------
// Descrição da regra de apontamento
//-----------------------------------------------------------------------------------------
If (TFF->(ColumnPos('TFF_REGRA')) > 0)
	xAux := FwStruTrigger('TFF_REGRA','TFF_NOMSPA','ALLTRIM( POSICIONE("SPA",1,XFILIAL("SPA")+M->TFF_REGRA,"PA_DESC") )',.F.,Nil,Nil,Nil)
	oStrTFF:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
EndIf
//-----------------------------------------------------------------------------------------
// Recalculo do Total de Uniformes
//-----------------------------------------------------------------------------------------
xAux := FwStruTrigger('TFF_ESCALA','TFF_TOTUNI','FwFldGet("TFF_QTDVEN") * (FwFldGet("TXP_TOTGER") * At740QtdAloc(FwFldGet("TFF_ESCALA")))',.F.,Nil,Nil,Nil)
oStrTFF:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Caracteristicas
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TDS_CODTCZ', 'TDS_DSCTCZ', 'At740TDS()',.F.)
	oStrTDS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Habilidades
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TDT_CODHAB', 'TDT_DSCHAB', 'At740TDT("1")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TDT_ESCALA', 'TDT_DSCESC', 'At740TDT("2")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TDT_ITESCA', 'TDT_DSCITE', 'At740TDT("3")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStrutrigger( 'TDT_HABX5' , 'TDT_DHABX5', 'At740TDT("4")',.F.)
	oStrTDT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//------------------------------------------------------------------------------------------
// Gatilhos - Cursos
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TGV_CURSO', 'TGV_DCURSO', 'At740TGV()',.F.)
	oStrTGV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
//-----------------------------------------------------------------------------------------
// gatilho para preencher os percentuais de lucro e tx adm quando inserido produto na linha
//-----------------------------------------------------------------------------------------
If GSGetIns('LE') .AND. !SuperGetMv("MV_ORCPRC",,.F.)
	xAux := FwStruTrigger( 'TFF_PRODUT', 'TFF_LUCRO', 'At740LuTxA("TFJ_LUCRO")')
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_PRODUT', 'TFF_ADM', 'At740LuTxA("TFJ_ADM")')
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif

IF lDesagrupad
	xAux := FwStruTrigger( 'TFF_PRODUT', 'TFF_TESPED', 'TecTesPRod(FwFldGet("TFF_PRODUT"), "_TS")')
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFG_PRODUT', 'TFG_TESPED', 'TecTesPRod(FwFldGet("TFG_PRODUT"), "_TS")')
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFH_PRODUT', 'TFH_TESPED', 'TecTesPRod(FwFldGet("TFH_PRODUT"), "_TS")')
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

If (TFF->(ColumnPos('TFF_QTPREV')) > 0)
	xAux := FwStruTrigger( 'TFF_QTDVEN', 'TFF_QTPREV', 'AtCalcPrev()')
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TURNO', 'TFF_QTPREV', 'AtCalcPrev()')
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_ESCALA', 'TFF_QTPREV','AtCalcPrev()')
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	If (TFF->(ColumnPos('TFF_GERVAG')) > 0)
		xAux := FwStruTrigger( 'TFF_GERVAG', 'TFF_QTPREV','AtCalcPrev()')
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif

EndIf
//-----------------------------------------------------------------
If !lGsPrecific
	xAux := FwStruTrigger( 'TFG_PRODUT', 'TFG_LUCRO', 'At740LuTxA("TFJ_LUCRO")')
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFG_PRODUT', 'TFG_ADM', 'At740LuTxA("TFJ_ADM")')
		oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFH_PRODUT', 'TFH_LUCRO', 'At740LuTxA("TFJ_LUCRO")')
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFH_PRODUT', 'TFH_ADM', 'At740LuTxA("TFJ_ADM")')
		oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_LUCRO', 'At740LuTxA("TFJ_LUCRO")')
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TEV_MODCOB', 'TEV_ADM', 'At740LuTxA("TFJ_ADM")')
		oStrTEV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif

xAux := FwStruTrigger( 'TFG_PRODUT', 'TFG_CHVTWO', '')
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFG_PRODUT', 'TFG_CODTWO', '')
	oStrTFG:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_PRODUT', 'TFH_CHVTWO', '')
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TFH_PRODUT', 'TFH_CODTWO', '')
	oStrTFH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

If lGsOrcUnif
	xAux := FwStruTrigger('TXP_CODUNI','TXP_DSCUNI','AllTrim( Posicione("SB1", 1, xFilial("SB1")+FwFldGet("TXP_CODUNI"), "B1_DESC") )',.F.)
		oStrTXP:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStruTrigger('TXP_CODUNI','TXP_CHVTWO','',.F.)
		oStrTXP:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStruTrigger('TXP_CODUNI','TXP_CODTWO','',.F.)
		oStrTXP:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	If lQtdUni
		//Quantidade Total de uniforme TXP_QTDVEN * QUANTIDADE DE PESSOAS DA ESCALA!:
		xAux := FwStrutrigger( 'TXP_QTDVEN', 'TXP_QTDUNI', 'FwFldGet("TXP_QTDVEN")*IIF(FwFldGet("TFF_GERVAG") == "1", FwFldGet("TFF_QTPREV"), 1)',.F.)
			oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		//Atualiza Qtd Unif (TXP_QTDUNI) quando mudar alocação prevista (TFF_QTPREV):
		xAux := FwStrutrigger( 'TFF_QTPREV', 'TFF_QTPREV', 'At740QtdUni(FwFldGet("TFF_QTPREV"))',.F.)
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		//Atualiza TXP_TOTGER sempre que mudar TXP_QTDUNI
		xAux := FwStrutrigger( 'TXP_QTDUNI', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
			oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf
	xAux := FwStrutrigger( 'TXP_QTDVEN', 'TXP_TOTAL', 'FwFldGet("TXP_QTDVEN")*FwFldGet("TXP_PRCVEN")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_PRCVEN', 'TXP_TOTAL', 'FwFldGet("TXP_QTDVEN")*FwFldGet("TXP_PRCVEN")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	If !lGsPrecific
		xAux := FwStrutrigger( 'TXP_LUCRO', 'TXP_TXLUCR', 'At740MatAc("1","TXPDETAIL","TXP")',.F.)
			oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		xAux := FwStrutrigger( 'TXP_LUCRO', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
			oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif
	xAux := FwStrutrigger( 'TXP_TOTAL', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_PRCVEN', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXP_QTDVEN', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	If TXP->( ColumnPos('TXP_VIDMES') ) > 0
		xAux := FwStrutrigger( 'TXP_VIDMES', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
			oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf
	If !lGsPrecific
		xAux := FwStrutrigger( 'TXP_ADM', 'TXP_TXADM', 'At740MatAc("2","TXPDETAIL","TXP")',.F.)
			oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		xAux := FwStrutrigger( 'TXP_ADM', 'TXP_TOTGER', 'At740VlTot("TXPDETAIL","TXP")',.F.)
			oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		xAux := FwStrutrigger( 'TXP_TOTGER', 'TXP_TXLUCR', 'At740MatAc("1","TXPDETAIL","TXP")',.F.)
			oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		xAux := FwStrutrigger( 'TXP_TOTGER', 'TXP_TXADM', 'At740MatAc("2","TXPDETAIL","TXP")',.F.)
			oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif
	xAux := FwStruTrigger( 'TXP_TOTGER', 'TXP_TOTGER', 'At740TrgGer( "CALC_TXP", "TOT_TXP", "TFF_RH", "TFF_TOTUNI" )', .F. )
		oStrTXP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTUNI', 'TFF_TOTAL', 'At740InPad()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	If !IsInCallStack("At870GerOrc")
		xAux := FwStruTrigger( 'TFF_TOTUNI', 'TFF_TOTUNI', 'At740TrgGer( "CALC_TFF", "TOT_RHUNI", "TFL_LOC", "TFL_TOTUNI" )', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf

	xAux := FwStruTrigger( 'TFL_TOTLE', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMC', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTRH', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTUNI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	If !IsInCallStack("At870GerOrc")
		xAux := FwStruTrigger( 'TFL_TOTUNI', 'TFL_TOTUNI', 'At740TrgGer( "TOTAIS", "TOT_TXP", "TFJ_REFER", "TFJ_TOTUNI" )', .F. )
			oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf

	If lQtdUni
		If !lGsPrecific
			cFormula := 'TXP->(TXP_QTDUNI*TXP_PRCVEN)+(TXP->(TXP_QTDUNI*TXP_PRCVEN)*(TXP->TXP_LUCRO/100))+(TXP->(TXP_QTDUNI*TXP_PRCVEN)*(TXP->TXP_ADM/100))'
		Else
			cFormula := 'TXP->(TXP_QTDUNI*TXP_PRCVEN)'
		Endif
	Endif
	oStrTXP:SetProperty('TXP_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TXPDETAIL",'TXP_TOTGER',,,,cFormula) } )
	bFormTot :=  {|oModel| oModel:GetValue("TOTAIS","TOT_RH")+oModel:GetValue("TOTAIS","TOT_MI")+oModel:GetValue("TOTAIS","TOT_MC")+oModel:GetValue("TOTAIS","TOT_LE")+oModel:GetValue("TOTAIS","TOT_TXP")}
	bFormTotEn := {|oModel| oModel:GetValue("CALC_TFL_NE","TOT_RH_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MI_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MC_EN")+oModel:GetValue("CALC_TFL_NE","TOT_LE_EN")+oModel:GetValue("CALC_TFL_NE","TOT_TXP_EN") - nDeduc}

Endif

If lGsOrcArma
	xAux := FwStruTrigger('TXQ_ITEARM','TXQ_CODPRD','',.F.)
		oStrTXQ:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStruTrigger('TXQ_ITEARM','TXQ_DSCPRD','',.F.)
		oStrTXQ:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStruTrigger('TXQ_CODPRD','TXQ_DSCPRD','AllTrim( Posicione("SB1", 1, xFilial("SB1")+FwFldGet("TXQ_CODPRD"), "B1_DESC") )',.F.)
		oStrTXQ:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStruTrigger('TXQ_CODPRD','TXQ_CHVTWO','',.F.)
		oStrTXQ:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStruTrigger('TXQ_CODPRD','TXQ_CODTWO','',.F.)
		oStrTXQ:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])
	xAux := FwStrutrigger( 'TXQ_QTDVEN', 'TXQ_TOTAL', 'FwFldGet("TXQ_QTDVEN")*FwFldGet("TXQ_PRCVEN")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_PRCVEN', 'TXQ_TOTAL', 'FwFldGet("TXQ_QTDVEN")*FwFldGet("TXQ_PRCVEN")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	If !lGsPrecific
		xAux := FwStrutrigger( 'TXQ_LUCRO', 'TXQ_TXLUCR', 'At740MatAc("1","TXQDETAIL","TXQ")',.F.)
			oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		xAux := FwStrutrigger( 'TXQ_LUCRO', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
			oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif
	xAux := FwStrutrigger( 'TXQ_TOTAL', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_PRCVEN', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStrutrigger( 'TXQ_QTDVEN', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	If TXQ->( ColumnPos('TXQ_VIDMES') ) > 0
		xAux := FwStrutrigger( 'TXQ_VIDMES', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
			oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf
	If !lGsPrecific
		xAux := FwStrutrigger( 'TXQ_ADM', 'TXQ_TXADM', 'At740MatAc("2","TXQDETAIL","TXQ")',.F.)
			oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		xAux := FwStrutrigger( 'TXQ_ADM', 'TXQ_TOTGER', 'At740VlTot("TXQDETAIL","TXQ")',.F.)
			oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		xAux := FwStrutrigger( 'TXQ_TOTGER', 'TXQ_TXLUCR', 'At740MatAc("1","TXQDETAIL","TXQ")',.F.)
			oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		xAux := FwStrutrigger( 'TXQ_TOTGER', 'TXQ_TXADM', 'At740MatAc("2","TXQDETAIL","TXQ")',.F.)
			oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif
	xAux := FwStruTrigger( 'TXQ_TOTGER', 'TXQ_TOTGER', 'At740TrgGer( "CALC_TXQ", "TOT_TXQ", "TFF_RH", "TFF_TOTARM" )', .F. )
		oStrTXQ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_TOTARM', 'TFF_TOTAL', 'At740InPad()',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	If !IsInCallStack("At870GerOrc")
		xAux := FwStruTrigger( 'TFF_TOTARM', 'TFF_TOTARM', 'At740TrgGer( "CALC_TFF", "TOT_RHARM", "TFL_LOC", "TFL_TOTARM" )', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf

	xAux := FwStruTrigger( 'TFL_TOTLE', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMC', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTRH', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTARM', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	If !IsInCallStack("At870GerOrc")
		xAux := FwStruTrigger( 'TFL_TOTARM', 'TFL_TOTARM', 'At740TrgGer( "TOTAIS", "TOT_TXQ", "TFJ_REFER", "TFJ_TOTARM" )', .F. )
			oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf

	If !lGsPrecific
		cFormula := 'TXQ->(TXQ_QTDVEN*TXQ_PRCVEN)+(TXQ->(TXQ_QTDVEN*TXQ_PRCVEN)*(TXQ->TXQ_LUCRO/100))+(TXQ->(TXQ_QTDVEN*TXQ_PRCVEN)*(TXQ->TXQ_ADM/100))'
	Else
		cFormula := 'TXQ->(TXQ_QTDVEN*TXQ_PRCVEN)'
	Endif

	oStrTXQ:SetProperty('TXQ_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TXQDETAIL",'TXQ_TOTGER',,,,cFormula) } )

	bFormTot :=  {|oModel| oModel:GetValue("TOTAIS","TOT_RH")+oModel:GetValue("TOTAIS","TOT_MI")+oModel:GetValue("TOTAIS","TOT_MC")+oModel:GetValue("TOTAIS","TOT_LE")+oModel:GetValue("TOTAIS","TOT_TXQ")}
	bFormTotEn := {|oModel| oModel:GetValue("CALC_TFL_NE","TOT_RH_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MI_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MC_EN")+oModel:GetValue("CALC_TFL_NE","TOT_LE_EN")+oModel:GetValue("CALC_TFL_NE","TOT_TXQ_EN") - nDeduc}

Endif

If !lVlrCon
	xAux := FwStruTrigger( 'TFF_VLRMAT', 'TFF_SUBTOT', 'At740RegPc()', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

If lGsOrcArma .And. lGsOrcUnif
	xAux := FwStruTrigger( 'TFL_TOTLE', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMC', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTMI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTRH', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTARM', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTARM")+FwFldGet("TFL_TOTUNI")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_TOTUNI', 'TFL_TOTAL', 'FwFldGet("TFL_TOTRH")+FwFldGet("TFL_TOTMI")+FwFldGet("TFL_TOTMC")+FwFldGet("TFL_TOTLE")+FwFldGet("TFL_TOTUNI")+FwFldGet("TFL_TOTARM")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	bFormTot :=  {|oModel| oModel:GetValue("TOTAIS","TOT_RH")+oModel:GetValue("TOTAIS","TOT_MI")+oModel:GetValue("TOTAIS","TOT_MC")+oModel:GetValue("TOTAIS","TOT_LE")+oModel:GetValue("TOTAIS","TOT_TXP")+oModel:GetValue("TOTAIS","TOT_TXQ")}
	bFormTotEn := {|oModel| oModel:GetValue("CALC_TFL_NE","TOT_RH_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MI_EN")+oModel:GetValue("CALC_TFL_NE","TOT_MC_EN")+oModel:GetValue("CALC_TFL_NE","TOT_LE_EN")+oModel:GetValue("CALC_TFL_NE","TOT_TXP_EN")+oModel:GetValue("CALC_TFL_NE","TOT_TXQ_EN") - nDeduc}

Endif

If TFF->( ColumnPos('TFF_TOTPLA') ) > 0 .And. TFF->( ColumnPos('TFF_GERPLA') ) > 0 ;
  .And. TFJ->( ColumnPos('TFJ_GERPLA') ) > 0  .And. TFL->( ColumnPos('TFL_GERPLA') ) > 0

	xAux := FwStruTrigger( 'TFF_TOTPLA', 'TFF_GERPLA', 'FwFldGet("TFF_QTDVEN")*FwFldGet("TFF_TOTPLA")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_QTDVEN', 'TFF_GERPLA', 'FwFldGet("TFF_QTDVEN")*FwFldGet("TFF_TOTPLA")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_GERPLA', 'TFF_GERPLA', 'At984aGtTt("TFF_RH","TFF_GERPLA","TFL_LOC","TFL_GERPLA")', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFL_GERPLA', 'TFL_GERPLA', 'At984aGtTt("TFL_LOC","TFL_GERPLA","TFJ_REFER","TFJ_GERPLA")', .F. )
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif

If TFF->( ColumnPos('TFF_TPCOBR') ) > 0
	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_DSCCOB', 'AllTrim( Posicione("SX5", 1, xFilial("SX5")+"GZ"+FwFldGet("TFF_TPCOBR"), "X5_DESCRI") )', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif

If TFF->( ColumnPos('TFF_TPCOBR') ) > 0 .And. TFF->( ColumnPos('TFF_QTDTIP') ) > 0 .And.;
	TFF->( ColumnPos('TFF_VLRPRP') ) > 0 .And.  TFF->( ColumnPos('TFF_VLRCOB') ) > 0

	If !(Isincallstack("At870GerOrc"))
		xAux := FwStruTrigger( 'TFF_QTDVEN', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

		xAux := FwStruTrigger( 'TFF_TOTUNI', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
			
		xAux := FwStruTrigger( 'TFF_TOTARM', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
			
		xAux := FwStruTrigger( 'TFF_PRCVEN', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
			
		xAux := FwStruTrigger( 'TFF_ESCALA', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
			
		xAux := FwStruTrigger( 'TFF_TURNO', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf
	xAux := FwStruTrigger( 'TFF_TOTUNI', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TOTARM', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_QTDVEN', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_PRCVEN', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_ESCALA', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TURNO', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_DESCON', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TXADM', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TXLUCR', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_QTDTIP', '0', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_VLRPRP', '0', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_VLRCOB', '0', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_TPCOBR', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_QTDTIP', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TFF_QTDTIP', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	If TFF->( ColumnPos('TFF_GERPLA') ) > 0
		If !(Isincallstack("At870GerOrc"))
			xAux := FwStruTrigger( 'TFF_GERPLA', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
				oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		EndIf

		xAux := FwStruTrigger( 'TFF_GERPLA', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	Endif

	xAux := FwStruTrigger( 'TFF_VLRMAT', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	If !(Isincallstack("At870GerOrc"))
		xAux := FwStruTrigger( 'TFF_VLRMAT', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	EndIf

	If lVlrCon
		xAux := FwStruTrigger( 'TFF_VLRCON', 'TFF_VLRCOB', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRCOB",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
			oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
			
		If !(Isincallstack("At870GerOrc"))
			xAux := FwStruTrigger( 'TFF_VLRCON', 'TFF_VLRPRP', 'At740ClPrp(FwFldGet("TFF_TPCOBR"),FwFldGet("TFF_SUBTOT")+FwFldGet("TFF_TOTUNI")+FwFldGet("TFF_TOTARM"),"TFF_VLRPRP",FwFldGet("TFF_ESCALA"),FwFldGet("TFF_TURNO"),FwFldGet("TFF_PRCVEN"))', .F. )
				oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
		EndIf
	EndIf
EndIf

If lGsPrecific
	xAux := FwStruTrigger( 'TFF_PLACOD', 'TFF_PLAREV', 'At740TrgPla(FwFldGet("TFF_PLACOD"),FwFldGet("TFF_FUNCAO"))', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'TFF_PLACOD', 'TFF_DPLAN', 'Posicione("ABW",1,xFilial("ABW")+FwFldGet("TFF_PLACOD")+FwFldGet("TFF_PLAREV"),"ABW_DESC")', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

If lGsOrcVerb
	xAux := FwStruTrigger( 'TFF_FUNCAO', 'TFF_FUNCAO', 'at740VbRun(.F.,FwFldGet("TFL_LOCAL"),FwFldGet("TFF_FUNCAO"),FwFldGet("TFF_PLACOD"),FwFldGet("TFF_PLAREV"))', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

//------------------------------------------------------------------------------------------
// Gatilhos - Reprocessamento Planilha
//------------------------------------------------------------------------------------------
xAux := FwStrutrigger( 'TFF_QTDVEN', 'TFF_QTDVEN', 'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_INSALU', 'TFF_INSALU', 'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_PERICU', 'TFF_PERICU', 'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_GRAUIN', 'TFF_GRAUIN', 'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_ESCALA', 'TFF_ESCALA', 'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_FUNCAO', 'TFF_FUNCAO', 'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_TOTMI',  'TFF_TOTMI',  'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_TOTMC',  'TFF_TOTMC',  'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_TOTUNI', 'TFF_TOTUNI', 'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_TOTARM', 'TFF_TOTARM', 'TEC740Legen( FwFldGet("TFF_PLACOD"), FwFldGet("TFF_LEGEND") )', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
xAux := FwStrutrigger( 'TFF_PLACOD', 'TFF_CALCMD', '" "', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )

xAux := FwStrutrigger( 'TFF_VLFIXO', 'TFF_VLFIXO', 'g740VlFixo()', .F. )
oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )

//Fernando Radu Muscalu. Acrescentado em 10/11/2023 - DSERSGS-17319
If ( ABS->(ColumnPos("ABS_CALEND")) > 0 )
	oStrTFL:AddTrigger( 'TFL_LOCAL', 'TFL_LOCAL', { || .T. }, bCalendGatilho  )	
	oStrTFF:AddTrigger( 'TFF_GERVAG', 'TFF_CALEND', { || .T. }, bCalendGatilho  )	
	oStrTFF:SetProperty( "TFF_CALEND", MODEL_FIELD_INIT,bCalendInicia )
	oStrTFF:SetProperty( "TFF_DSCALE", MODEL_FIELD_INIT,bCalendInicia )
	oStrTFF:SetProperty( "TFF_CALEND", MODEL_FIELD_WHEN, { |oSubTFF| TemCalend(oSubTFF) } )
EndIf

If ( TFF->(ColumnPos("TFF_REGRA")) > 0 ) .AND. isincallstack("At870Revis")
	oStrTFF:SetProperty( "TFF_REGRA", MODEL_FIELD_WHEN, { |oSubTFF| revisaoRegra(oSubTFF) } )
EndIf

If lVlrCon
	oStrTFF:SetProperty( "TFF_VLRMAT", MODEL_FIELD_WHEN, { || .T. } )
	oStrTFF:SetProperty( "TFF_VLRCON", MODEL_FIELD_WHEN, { || .T. } )
EndIf

If lTemRUK
	xAux := FwStruTrigger( 'TFL_LOCAL', 'TFL_LOCAL', 'At740VlLoc()', .F. )
	oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4] )
EndIf

oStrTFF:SetProperty( "TFF_PLACOD", MODEL_FIELD_WHEN, { || lGsPrecific } )
oStrTFL:SetProperty( "TFL_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFF:SetProperty( "TFF_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFF:SetProperty( "TFF_LOCAL" , MODEL_FIELD_OBRIGAT, .F. )
oStrTFF:SetProperty( "TFF_COBCTR", MODEL_FIELD_WHEN, { || .F.} )
oStrTFG:SetProperty( "TFG_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFG:SetProperty( "TFG_LOCAL" , MODEL_FIELD_OBRIGAT, .F. )
oStrTFG:SetProperty( "TFG_COBCTR", MODEL_FIELD_WHEN, { || .F. } )
oStrTFH:SetProperty( "TFH_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFH:SetProperty( "TFH_LOCAL" , MODEL_FIELD_OBRIGAT, .F. )
oStrTFH:SetProperty( "TFH_COBCTR", MODEL_FIELD_WHEN, { || .F. } )
oStrTFI:SetProperty( "TFI_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
oStrTFI:SetProperty( "TFI_LOCAL" , MODEL_FIELD_OBRIGAT, .F. )
oStrTFI:SetProperty( "TFI_TOTAL" , MODEL_FIELD_OBRIGAT, .F. )
oStrTFU:SetProperty( "TFU_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTFU:SetProperty( "TFU_LOCAL" , MODEL_FIELD_OBRIGAT, .F. )
oStrTFU:SetProperty( "TFU_VALOR" , MODEL_FIELD_OBRIGAT, .F. )
oStrTDS:SetProperty( "TDS_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTDT:SetProperty( "TDT_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTGV:SetProperty( "TGV_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStrTGV:SetProperty( "TGV_CODTFF", MODEL_FIELD_INIT,{|oMdl| oMdl:GetModel():GetModel("TFF_RH"):GetValue("TFF_COD") } )
oStrTDS:SetProperty( "TDS_CODTFF", MODEL_FIELD_INIT,{|oMdl| oMdl:GetModel():GetModel("TFF_RH"):GetValue("TFF_COD") } )
oStrTDT:SetProperty( "TDT_CODTFF", MODEL_FIELD_INIT,{|oMdl| oMdl:GetModel():GetModel("TFF_RH"):GetValue("TFF_COD") } )
If TXP->( ColumnPos('TXP_COBCTR') ) > 0 .AND. lGsOrcUnif
	oStrTXP:SetProperty( "TXP_COBCTR", MODEL_FIELD_WHEN, { || .F. } )
EndIf
If TXQ->( ColumnPos('TXQ_COBCTR') ) > 0 .AND. lGsOrcArma
	oStrTXQ:SetProperty( "TXQ_COBCTR", MODEL_FIELD_WHEN, { || .F. } )
EndIf
If (TFF->(ColumnPos('TFF_GERVAG')) > 0)
	oStrTFF:SetProperty( "TFF_FUNCAO", MODEL_FIELD_OBRIGAT, .F. )
EndIf

If lGsPrecific
	oStrTFF:SetProperty( "TFF_PLACOD", MODEL_FIELD_VALID,{|oModel,cCampo,xValueNew,nLine,xValueOld|At740VlPla(oModel,cCampo,xValueNew,nLine,xValueOld)})
EndIf
If isInCallStack("At870GerOrc")
	oStrTFF:SetProperty( "TFF_COBCTR", MODEL_FIELD_INIT, {||"2"} )
	oStrTFG:SetProperty( "TFG_COBCTR", MODEL_FIELD_INIT, {||"2"} )
	oStrTFH:SetProperty( "TFH_COBCTR", MODEL_FIELD_INIT, {||"2"} )
	If TXP->( ColumnPos('TXP_COBCTR') ) > 0 .AND. lGsOrcUnif
		oStrTXP:SetProperty( "TXP_COBCTR", MODEL_FIELD_INIT, {||"2"} )
	EndIf
	If TXQ->( ColumnPos('TXQ_COBCTR') ) > 0 .AND. lGsOrcArma
		oStrTXQ:SetProperty( "TXQ_COBCTR", MODEL_FIELD_INIT, {||"2"} )
	EndIf	
EndIf

If TFJ->( ColumnPos('TFJ_DTPLRV') ) > 0 .AND. !isInCallStack("AT870PlaRe")
	oStrTFJ:SetProperty( "TFJ_DTPLRV", MODEL_FIELD_OBRIGAT, .F. )
	If isInCallStack("AplicaRevi")
		oStrTFJ:SetProperty( "TFJ_DTPLRV", MODEL_FIELD_WHEN, {|| .F. } )
	EndIf
EndIf

If TFL->( ColumnPos('TFL_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi"))
	oStrTFL:SetProperty( "TFL_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

If TFF->( ColumnPos('TFF_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	oStrTFF:SetProperty( "TFF_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

If TFG->( ColumnPos('TFG_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	oStrTFG:SetProperty( "TFG_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

If TFH->( ColumnPos('TFH_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	oStrTFH:SetProperty( "TFH_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

If TFU->( ColumnPos('TFU_MODPLA') ) > 0 .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	oStrTFU:SetProperty( "TFU_MODPLA", MODEL_FIELD_INIT, {||"1"} )
EndIf

IF lTecItExtOp
	oStrTFF:SetProperty( "TFF_ITEXOP", MODEL_FIELD_INIT, {||"1"} )
Endif
oStrABP:SetProperty( "ABP_ITRH"  , MODEL_FIELD_OBRIGAT, .F. )
oStrTEV:SetProperty( "TEV_CODLOC", MODEL_FIELD_OBRIGAT, .F. )

oStrTFH:SetProperty('TFH_PERINI',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFH_MC","TFH_PERINI","TFH_PERINI","TFH_PERFIM")})
oStrTFH:SetProperty('TFH_PERFIM',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFH_MC","TFH_PERFIM","TFH_PERINI","TFH_PERFIM")})

oStrTFG:SetProperty('TFG_PERINI',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFG_MI","TFG_PERINI","TFG_PERINI","TFG_PERFIM")})
oStrTFG:SetProperty('TFG_PERFIM',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFG_MI","TFG_PERFIM","TFG_PERINI","TFG_PERFIM")})

oStrTFF:SetProperty('TFF_PERINI',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFF_RH","TFF_PERINI","TFF_PERINI","TFF_PERFIM")})
oStrTFF:SetProperty('TFF_PERFIM',MODEL_FIELD_VALID,{|oMdlVld|At740VldDt("TFF_RH","TFF_PERFIM","TFF_PERINI","TFF_PERFIM")})

oStrTFI:SetProperty('TFI_PERINI',MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|;
				At740VldDt("TFI_LE","TFI_PERINI","TFI_PERINI","TFI_PERFIM") .And. ;  // valida o período selecionado
				At740Reserv(oMdlVld,cCampo,xValueNew,nLine,xValueOld) } )  // verifica se há reserva de equipamento
oStrTFI:SetProperty('TFI_PERFIM',MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|;
				At740VldDt("TFI_LE","TFI_PERFIM","TFI_PERINI","TFI_PERFIM") .And. ;  // valida o período selecionado
				At740Reserv(oMdlVld,cCampo,xValueNew,nLine,xValueOld) } )  // verifica se há reserva de equipamento
oStrTFI:SetProperty('TFI_QTDVEN',MODEL_FIELD_VALID, {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|;
				xValueNew >= 0 .And. ;
				At740Reserv(oMdlVld,cCampo,xValueNew,nLine,xValueOld) } )

oStrTFL:SetProperty('TFL_DTFIM',MODEL_FIELD_VALID,{|oModel,cCampo,xValueNew,nLine,xValueOld|At740VlVig(oModel,cCampo,xValueNew,nLine,xValueOld)})

oStrTFL:SetProperty('TFL_DTINI',MODEL_FIELD_VALID,{|oModel,cCampo,xValueNew,nLine,xValueOld|At740VlVig(oModel,cCampo,xValueNew,nLine,xValueOld)})

oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)

If TecABBPRHR()
	oStrTFF:SetProperty('TFF_HRSSAL',MODEL_FIELD_WHEN, {|| .F. })
EndIf

//Adiciona valid na revisão do contrato e no item extra
If TecBHasGvg() .And. (IsInCallStack("At870Revis") .Or. isInCallStack("At870GerOrc"))
	oStrTFF:SetProperty('TFF_GERVAG',MODEL_FIELD_VALID,{|oModel|At740VldVg(oModel)})
EndIf

oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_WHEN ,{|oModel|At740BlTot(oModel)})
oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_VALID,{|oModel|At740VlVlr("TFF_RH","TFF_PRCVEN",oModel)})

oStrABP:SetProperty('ABP_DESCRI',MODEL_FIELD_INIT,{|| At740DscBe()} )
oStrABP:SetProperty('ABP_TPVERB',MODEL_FIELD_INIT,{|| At740ConvTp( ATINIPADMVC("TECA740","ABP_BENEF","RV_TIPO","SRV",1, "xFilial('SRV')+ABP->ABP_VERBA") ) } )

oStrTFG:SetProperty('TFG_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrTFG:SetProperty('TFG_PRCVEN',MODEL_FIELD_VALID,{|oModel|At740VlVlr("TFG_MI","TFG_PRCVEN",oModel)})
If !lGsPrecific
	cFormula := 'TFG->(TFG_QTDVEN*TFG_PRCVEN)+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_LUCRO/100))+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_ADM/100))'
Else
	cFormula := 'TFG->(TFG_QTDVEN*TFG_PRCVEN)'
Endif
oStrTFG:SetProperty('TFG_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TFG_MI",'TFG_TOTGER',,,,cFormula) } )

oStrTFH:SetProperty('TFH_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrTFH:SetProperty('TFH_PRCVEN',MODEL_FIELD_VALID,{|oModel|At740VlVlr("TFH_MC","TFH_PRCVEN",oModel)})

If lGsOrcUnif
	oStrTXP:SetProperty('TXP_CODUNI',MODEL_FIELD_OBRIGAT,.T.)
	oStrTXP:SetProperty('TXP_QTDVEN',MODEL_FIELD_OBRIGAT,.T.)
EndIf

If lGsOrcArma
	oStrTXQ:SetProperty('TXQ_CODPRD',MODEL_FIELD_OBRIGAT,.T.)
	oStrTXQ:SetProperty('TXQ_QTDVEN',MODEL_FIELD_OBRIGAT,.T.)
EndIf

If !lGsPrecific
	cFormula := 'TFH->(TFH_QTDVEN*TFH_PRCVEN)+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_LUCRO/100))+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_ADM/100))'
Else
	cFormula := 'TFH->(TFH_QTDVEN*TFH_PRCVEN)'
Endif
oStrTFH:SetProperty('TFH_TOTGER',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740","TFH_MC",'TFH_TOTGER',,,,cFormula) } )

oStrTEV:SetProperty('TEV_UM',MODEL_FIELD_WHEN,{|| IsInCallStack('RunTrigger') .Or. FwFldGet('TEV_MODCOB') <> '2' } )

If !lGsPrecific
	cFormula := 'TEV->(TEV_VLRUNI*TEV_QTDE)+TEV->(TEV_TXADM+TEV_TXLUCR)'
Else
	cFormula := 'TEV->(TEV_VLRUNI*TEV_QTDE)'
Endif
oStrTEV:SetProperty('TEV_VLTOT',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA740", "TEV_ADICIO", "TEV_VLTOT",,,,cFormula)} )

If oStrCusto:HasField("TFJ_TOTCUS")
    oStrCusto:SetProperty( "TFJ_TOTCUS", MODEL_FIELD_WHEN, { || .F. } )
EndIf
If oStrCusto:HasField("TFJ_TOTGER")
    oStrCusto:SetProperty( "TFJ_TOTGER", MODEL_FIELD_WHEN, { || .F. } )
EndIf

If SuperGetMv("MV_GSITORC",,"2") == "1" .And. TecGsPrecf()
	oStrTWO:SetProperty('TWO_CODFAC', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c,d),lValFac := Vazio() .Or. ExistCpo('TXR',Alltrim(c),1) ,FWCloseCpo(a,b,c,lValFac,.T.),lValFac})
	oStrTWO:SetProperty('TWO_QUANT', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c,d),lValFac := Positivo() ,FWCloseCpo(a,b,c,lValFac,.T.),lValFac})
	xAux := FwStruTrigger( 'TWO_CODFAC', 'TWO_DESCRI', 'At174TXR()', .F. )
	oStrTWO:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Else
	oStrTWO:SetProperty('TWO_CODFAC', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c,d),lValFac := Vazio() .Or. ExistCpo("TWM"),FWCloseCpo(a,b,c,lValFac,.T.),lValFac})
EndIf
oModel := MPFormModel():New('TECA740',,{|oModel| At740TdOk(oModel) },{|oModel| At740Cmt( oModel ) }, {|a,b,c,d| At740Canc( a,b,c,d ) } )

If lTec855
    oModel:SetDescription( STR0338 ) //"Aprovação Operacional
Else
	oModel:SetDescription( STR0001 ) //'Orçamento para Serviços'
Endif

oModel:addFields('TFJ_REFER',,oStrTFJ)

If lVersion23
	oModel:SetPrimaryKey({"TFJ_FILIAL","TFJ_CODIGO"})
EndIf

oModel:addGrid('TFL_LOC','TFJ_REFER', oStrTFL, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFL(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) }, , Nil, Nil, {|oModel|AtLoadTFL(oModel)})

oModel:SetRelation('TFL_LOC', { { 'TFL_FILIAL', 'xFilial("TFJ")' }, { 'TFL_CODPAI', 'TFJ_CODIGO' } }, TFL->(IndexKey(1)) )

If oStrCusto:HasField( "TFJ_TOTGER" ) .And. oStrCusto:HasField( "TFJ_TOTCUS" )
	oModel:addFields("TFJ_TOT","TFJ_REFER", oStrCusto, Nil, , Nil, Nil, Nil )
	oModel:GetModel("TFJ_TOT"):SetOnlyQuery(.T.) // Quanto ativado não efetua gravação no campo físico
EndIf

If lVersion23
	oModel:GetModel("TFJ_REFER"):SetFldNoCopy( { 'TFJ_CODVIS' } )
EndIf

oModel:addGrid('TFF_RH','TFL_LOC',oStrTFF, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },;
{|oMdlG,nLine,cAcao,cCampo| PosLinTFF(oMdlG, nLine, cAcao, cCampo)}, Nil, { |oMdlG| PosTFF( oMdlG ) }, {|oModel|AtLoadTFF(oModel)})

oModel:SetRelation('TFF_RH', { { 'TFF_FILIAL', 'xFilial("TFF")' }, { 'TFF_CODPAI', 'TFL_CODIGO' }, { 'TFF_LOCAL', 'TFL_LOCAL' } }, TFF->(IndexKey(1)) )

oModel:addGrid('ABP_BENEF','TFF_RH',oStrABP, {|oMdlG,nLine,cAcao,cCampo,xValue,xCurrentValue| PreLinABP(oMdlG, nLine, cAcao, cCampo, xValue, xCurrentValue) } )
oModel:SetRelation('ABP_BENEF', { { 'ABP_FILIAL', 'xFilial("ABP")' }, { 'ABP_ITRH', 'TFF_COD' } }, ABP->(IndexKey(1)) )
oModel:GetModel( 'ABP_BENEF' ):SetUniqueLine( { 'ABP_BENEFI' } )

oModel:addGrid('TFG_MI','TFF_RH',oStrTFG, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFG(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdlG,nLine,cAcao,cCampo| PosLinTFG(oMdlG, nLine, cAcao, cCampo)};
,{|oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue| PreGridTFG(oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue)}, Nil, {|oModel|AtLoadTFG(oModel)})
oModel:SetRelation('TFG_MI', { { 'TFG_FILIAL', 'xFilial("TFG")' }, { 'TFG_CODPAI', 'TFF_COD' } }, TFG->(IndexKey(1)) )

oModel:addGrid('TFH_MC','TFF_RH',oStrTFH, {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFH(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdlG,nLine,cAcao,cCampo| PosLinTFH(oMdlG, nLine, cAcao, cCampo)};
 ,{|oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue| PreGridTFH(oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue)}, Nil, {|oModel|AtLoadTFH(oModel)})

oModel:SetRelation('TFH_MC', { { 'TFH_FILIAL', 'xFilial("TFH")' }, { 'TFH_CODPAI', 'TFF_COD' } }, TFH->(IndexKey(1)) )

oModel:addGrid('TFU_HE','TFF_RH',oStrTFU,  {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTFU(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) }, {|oMdlG,nLine,cAcao,cCampo| PosLinTFU(oMdlG, nLine, cAcao, cCampo)} )
oModel:SetRelation('TFU_HE', { { 'TFU_FILIAL', 'xFilial("TFU")' }, { 'TFU_CODTFF', 'TFF_COD' }}, TFU->(IndexKey(1)) )

oModel:addGrid('TFI_LE','TFL_LOC',oStrTFI, {|oMdlG,nLine,cAcao,cCampo| PreLinTFI(oMdlG, nLine, cAcao, cCampo) },{|oMdlG,nLine,cAcao,cCampo| PosLinTFI(oMdlG, nLine, cAcao, cCampo)},;
	Nil,Nil,{|oModel|AtLoadTFI(oModel)} )
oModel:SetRelation('TFI_LE', { { 'TFI_FILIAL', 'xFilial("TFI")' }, { 'TFI_CODPAI', 'TFL_CODIGO' }, { 'TFI_LOCAL', 'TFL_LOCAL' } }, TFI->(IndexKey(1)) )

oModel:addGrid('TEV_ADICIO','TFI_LE',oStrTEV, {|oMdlG,nLine,cAcao,cCampo,xValue,xOldValue| PreLinTEV(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) } )
oModel:SetRelation('TEV_ADICIO', { { 'TEV_FILIAL', 'xFilial("TEV")' }, { 'TEV_CODLOC', 'TFI_COD' } }, TEV->(IndexKey(1)) )
oModel:GetModel( 'TEV_ADICIO' ):SetUniqueLine( { 'TEV_MODCOB' } )

//referente fonte TECA741 - Habilidades, Características e Cursos para o item de RH
oModel:AddGrid( "TGV_RH", "TFF_RH", oStrTGV,/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oModel:SetRelation('TGV_RH', { { 'TGV_FILIAL', 'xFilial("TGV")' }, { 'TGV_CODTFF', 'TFF_COD' } }, TGV->(IndexKey(2)) )
oModel:GetModel( 'TGV_RH' ):SetUniqueLine( { 'TGV_CODTFF','TGV_CURSO' } )

oModel:AddGrid( "TDS_RH", "TFF_RH", oStrTDS,/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oModel:SetRelation('TDS_RH', { { 'TDS_FILIAL', 'xFilial("TDS")' }, { 'TDS_CODTFF', 'TFF_COD' } }, TDS->(IndexKey(2)) )
oModel:GetModel( 'TDS_RH' ):SetUniqueLine( { 'TDS_CODTFF','TDS_CODTCZ' } )

oModel:AddGrid( "TDT_RH", "TFF_RH", oStrTDT,/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
oModel:SetRelation('TDT_RH', { { 'TDT_FILIAL', 'xFilial("TDT")' }, { 'TDT_CODTFF', 'TFF_COD' } }, TDT->(IndexKey(2)) )

If lNovoFacil
	oModel:AddGrid( "TWODETAIL", "TFF_RH", oStrTWO, {|oModelGrid,  nLine,cAction,  cField, xValue, xOldValue|A740LoadFa(oModelGrid, nLine, cAction, cField, xValue, xOldValue)}/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
	oModel:SetRelation('TWODETAIL', { { 'TWO_FILIAL', 'xFilial("TWO")' }, {'TWO_CODRH','TFF_COD'} }, TWO->(IndexKey(4)) )
Else
	oModel:AddGrid( "TWODETAIL", "TFL_LOC", oStrTWO, {|oModelGrid,  nLine,cAction,  cField, xValue, xOldValue|A740LoadFa(oModelGrid, nLine, cAction, cField, xValue, xOldValue)}/*bLinePre*/,/*bLinePos*/,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad*/)
	oModel:SetRelation('TWODETAIL', { { 'TWO_FILIAL', 'xFilial("TWO")' }, {'TWO_CODORC', 'TFJ_CODIGO'}, {'TWO_PROPOS', 'TFJ_PROPOS'}, {'TWO_LOCAL','TFL_CODIGO'} }, TWO->(IndexKey(1)) )
EndIf

If lGsOrcUnif
	oModel:addGrid('TXPDETAIL','TFF_RH',oStrTXP, {|oMdlG,nLine,cAction, cCampo, xValue, xOldValue| PreLinTXP(oMdlG,nLine,cAction, cCampo, xValue, xOldValue)},Nil,{|oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue| PreGridTXP(oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue)}, Nil, {|oModel|AtLoadTXP(oModel)} )
	oModel:SetRelation('TXPDETAIL', { { 'TXP_FILIAL', 'xFilial("TXP")' }, { 'TXP_CODTFF', 'TFF_COD' } }, TXP->(IndexKey(2)) )
Endif

If lGsOrcArma
	oModel:addGrid('TXQDETAIL','TFF_RH',oStrTXQ, {|oMdlG,nLine,cAction,cField,xValue,xOldValue| PreLinTXQ(oMdlG,nLine,cAction,cField,xValue,xOldValue)},Nil,{|oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue| PreGridTXQ(oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue)}, Nil, {|oModel|AtLoadTXQ(oModel)})
	oModel:SetRelation('TXQDETAIL', { { 'TXQ_FILIAL', 'xFilial("TXQ")' }, { 'TXQ_CODTFF', 'TFF_COD' } }, TXQ->(IndexKey(2)) )
Endif

If lGsOrcVerb
	oModel:addGrid('ABZDETAIL','TFF_RH',oStrABZ,,,Nil, Nil,)
	oModel:SetRelation('ABZDETAIL', { { 'ABZ_FILIAL', 'xFilial("ABZ")' }, { 'ABZ_CODTFF', 'TFF_COD' } }, ABZ->(IndexKey(1)) )
EndIf

If ExistBlock("a740GrdM")
	For nI := 1 To Len(oModel:GetAllSubModels())
		Aadd(aModelsId, {oModel:aAllSubModels[nI]:GetId(), oModel:aAllSubModels[nI]:GetDescription()})
	Next nI
	ExecBlock("a740GrdM",.F.,.F.,{oModel,aModelsId})
EndIf

oModel:getModel('TFJ_REFER'):SetDescription(STR0004)	// 'Ref. Proposta'
oModel:getModel('TFL_LOC'):SetDescription(STR0005)		// 'Locais'
oModel:getModel('TFF_RH'):SetDescription(STR0006)		// 'Recursos Humanos'
oModel:getModel('TFG_MI'):SetDescription(STR0007)		// 'Materiais de Implantação'
oModel:getModel('TFH_MC'):SetDescription(STR0008)		// 'Material de Consumo'
oModel:getModel('TFU_HE'):SetDescription(STR0031)		// 'Hora Extra'
oModel:getModel('TFI_LE'):SetDescription(STR0009)		// 'Locação de Equipamentos'
oModel:getModel('ABP_BENEF'):SetDescription(STR0010)	// 'Beneficios'
oModel:getModel('TEV_ADICIO'):SetDescription(STR0011)	// 'Cobrança da Locação'
oModel:getModel('TGV_RH'):SetDescription(STR0072)		// 'Cursos'
oModel:getModel('TDS_RH'):SetDescription(STR0073)		// 'Habilidades'
oModel:getModel('TDT_RH'):SetDescription(STR0074)		// 'Caracteristicas'
oModel:getModel('TWODETAIL'):SetDescription(STR0096)	// 'Facilitador'

oModel:getModel('TEV_ADICIO'):SetOptional(.T.)
oModel:getModel('TFI_LE'):SetOptional(.T.)
oModel:getModel('TFH_MC'):SetOptional(.T.)
oModel:getModel('TFG_MI'):SetOptional(.T.)
oModel:getModel('TFU_HE'):SetOptional(.T.)
oModel:getModel('ABP_BENEF'):SetOptional(.T.)
oModel:getModel('TFF_RH'):SetOptional(.T.)
oModel:getModel('TGV_RH'):SetOptional(.T.) //ref. fonte TECA741 - Cursos
oModel:getModel('TDS_RH'):SetOptional(.T.) //ref. fonte TECA741 - Características
oModel:getModel('TDT_RH'):SetOptional(.T.) //ref. fonte TECA741 - Habilidades
oModel:getModel('TWODETAIL'):SetOptional(.T.) //Facilitador

If lGsOrcUnif
	oModel:getModel('TXPDETAIL'):SetDescription(STR0326)	// 'Uniforme'
	oModel:getModel('TXPDETAIL'):SetOptional(.T.) //Uniformes
Endif
If lGsOrcArma
	oModel:getModel('TXQDETAIL'):SetDescription(STR0331) // "Armamento"
	oModel:getModel('TXQDETAIL'):SetOptional(.T.) //Uniformes
Endif

If lGsOrcVerb
	oModel:getModel('ABZDETAIL'):SetDescription("Verbas CCT") // "Verbas CCT"
	oModel:getModel('ABZDETAIL'):SetOptional(.T.) //"Verbas CCT"

	oModel:getModel('ABZDETAIL'):SetNoInserLine(.T.)
	oModel:getModel('ABZDETAIL'):SetNoUpdateLine(.T.)
	oModel:getModel('ABZDETAIL'):SetNoDeleteLine(.T.)
EndIf

//CALCULOS TFL:
oModel:AddCalc( 'CALC_TFI', 'TFL_LOC', 'TFI_LE', 'TFI_TOTAL' , 'TOT_LE', 'SUM',/*bCondition*/, /*bInitValue*/, STR0012 /*cTitle*/, /*bFormula*/) // 'Tot. Loc. Equipamento'
oModel:AddCalc( 'CALC_TFF', 'TFL_LOC', 'TFF_RH', 'TFF_SUBTOT', 'TOT_RH', 'SUM',{|oModel| oModel:GetValue( "TFF_RH", "TFF_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0013 /*cTitle*/, /*bFormula*/)  // 'Tot. Rec. Humanos'
oModel:AddCalc( 'CALC_TFF', 'TFL_LOC', 'TFF_RH', 'TFF_TOTMI' , 'TOT_RHMI', 'SUM',{|oModel| oModel:GetValue( "TFF_RH", "TFF_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0014 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Implantação'
oModel:AddCalc( 'CALC_TFF', 'TFL_LOC', 'TFF_RH', 'TFF_TOTMC' , 'TOT_RHMC', 'SUM',{|oModel| oModel:GetValue( "TFF_RH", "TFF_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,STR0015 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Consumo'
If lGsOrcUnif
	oModel:AddCalc( 'CALC_TFF'	 , 'TFL_LOC'	, 'TFF_RH'	 	, 'TFF_TOTUNI', 'TOT_RHUNI'	, 'SUM',{|oModel| oModel:GetValue( "TFF_RH", "TFF_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,"Tot. Uniforme" /*cTitle*/, /*bFormula*/)  // "Tot. Uniforme"
Endif
If lGsOrcArma
	oModel:AddCalc( 'CALC_TFF'	 , 'TFL_LOC'	, 'TFF_RH'	 	, 'TFF_TOTARM', 'TOT_RHARM'	, 'SUM',{|oModel| oModel:GetValue( "TFF_RH", "TFF_COBCTR" ) <> "2" }/*bCondition*/, /*bInitValue*/,"Tot. Armamento" /*cTitle*/, /*bFormula*/)  // "Tot. Armamento"
Endif

//CALCULOS TFF:
oModel:AddCalc( 'CALC_TFG', 'TFF_RH', 'TFG_MI'	 , 'TFG_TOTGER', 'TOT_MI', 'SUM', /*bCondition*/, /*bInitValue*/,STR0014 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Implantação'
oModel:AddCalc( 'CALC_TFH', 'TFF_RH', 'TFH_MC'	 , 'TFH_TOTGER', 'TOT_MC', 'SUM', /*bCondition*/, /*bInitValue*/,STR0015 /*cTitle*/, /*bFormula*/)  // 'Tot. Mat. Consumo'
If lGsOrcUnif
	oModel:AddCalc( 'CALC_TXP'	 , 'TFF_RH'		, 'TXPDETAIL'	, 'TXP_TOTGER', 'TOT_TXP'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Tot. Uniforme" /*cTitle*/, /*bFormula*/)  // "Tot. Uniforme"
Endif
If lGsOrcArma
	oModel:AddCalc( 'CALC_TXQ'	 , 'TFF_RH'		, 'TXQDETAIL'	, 'TXQ_TOTGER', 'TOT_TXQ'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Tot. Armamento" /*cTitle*/, /*bFormula*/)  // "Tot. Armamento"
Endif

//Somatória de TOTAIS TFJ:
oModel:AddCalc( 'CALC_TEV', 'TFI_LE', 'TEV_ADICIO', 'TEV_VLTOT', 'TOT_ADICIO', 'SUM', {|oMdl| At740WhCob( oMdl) }/*bCondition*/, /*bInitValue*/,STR0016 /*cTitle*/, /*bFormula*/)  // 'Tot. Cobrança Loc. Equip.'
oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTRH', 'TOT_RH', 'SUM',/*bCondition*/, /*bInitValue*/,STR0017 /*cTitle*/, /*bFormula*/)  // 'Geral RH'
oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMI', 'TOT_MI', 'SUM', /*bCondition*/, /*bInitValue*/,STR0018 /*cTitle*/, /*bFormula*/)  // 'Geral MI'
oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMC', 'TOT_MC', 'SUM', /*bCondition*/, /*bInitValue*/,STR0019 /*cTitle*/, /*bFormula*/)  // 'Geral MC'
oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTLE', 'TOT_LE', 'SUM', /*bCondition*/, /*bInitValue*/,STR0020 /*cTitle*/, /*bFormula*/)  // 'Geral LE'
If lGsOrcUnif
	oModel:AddCalc( 'CALC_TFL'	 , 'TFJ_REFER' 	, 'TFL_LOC'	 	, 'TFL_TOTUNI', 'TOT_TXP'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Geral Uniforme" /*cTitle*/, /*bFormula*/)  // 'Geral Uniforme'
Endif
If lGsOrcArma
	oModel:AddCalc( 'CALC_TFL'	 , 'TFJ_REFER' 	, 'TFL_LOC'	 	, 'TFL_TOTARM', 'TOT_TXQ'	, 'SUM', /*bCondition*/, /*bInitValue*/,"Geral Armamento" /*cTitle*/, /*bFormula*/)  // "Geral Armamento"
Endif

oModel:AddCalc( 'CALC_TFL', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL', 'SUM', /*bCondition*/, /*bInitValue*/,STR0021 /*cTitle*/, /*bFormula*/) // 'Geral Proposta'

oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTRH', 'TOT_RH_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_RH", @nDeduc,'TECA740')},,STR0258) // "Tot.RH Real"
oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMI', 'TOT_MI_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_MI")},, STR0259) //"Tot.MI Real"
oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMC', 'TOT_MC_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_MC")},, STR0260) //"Tot.MC Real"
oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTLE', 'TOT_LE_EN', 'SUM',{|oMdl|TC740VLCL(oMdl,"TOT_LE", @nDeduc,'TECA740')},, STR0261) //"Tot.LE Real"
If lGsOrcUnif
	oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER'	, 'TFL_LOC'		, 'TFL_TOTUNI', 'TOT_TXP_EN', 'SUM',/*{|oMdl|TC740VLCL(oMdl,"TOT_TXP", @nDeduc,'TECA740')}*/,, "Tot.Uni. Real") //"Tot.LE Real"
Endif
If lGsOrcArma
	oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER'	, 'TFL_LOC'		, 'TFL_TOTARM', 'TOT_TXQ_EN', 'SUM',/*{|oMdl|TC740VLCL(oMdl,"TOT_TXP", @nDeduc,'TECA740')}*/,, "Tot.Arm. Real") //"Tot.LE Real"
Endif
oModel:AddCalc( 'CALC_TFL_NE', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL_EN', 'SUM',{|oMdl|TC740VLCL(oMdl," ")},, STR0262) //"Total Ativo"
//--------------------------------------------------------------
//  Totais que são exibidos na interface
//--------------------------------------------------------------
oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTRH' , 'TOT_RH', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0017 /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_RH")} /*bFormula*/) // 'Geral RH'
oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMI' , 'TOT_MI', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0018 /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_MI")} /*bFormula*/)  // 'Geral MI'
oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTMC' , 'TOT_MC', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0019 /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_MC")} /*bFormula*/)  // 'Geral MC'
oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTLE' , 'TOT_LE', 'FORMULA',{||.T.} /*bCondition*/, /*bInitValue*/,STR0020 /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_LE")} /*bFormula*/)  // 'Geral LE'
If lGsOrcUnif
	oModel:AddCalc( 'TOTAIS'	 , 'TFJ_REFER'	, 'TFL_LOC'		, 'TFL_TOTUNI', 'TOT_TXP'	, 'FORMULA',/*bCondition*/, /*bInitValue*/,"Total Uniforme" /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_TXP")} /*bFormula*/)  // "Total Uniforme"
Endif
If lGsOrcArma
	oModel:AddCalc( 'TOTAIS'	 , 'TFJ_REFER'	, 'TFL_LOC'		, 'TFL_TOTARM', 'TOT_TXQ'	, 'FORMULA',/*bCondition*/, /*bInitValue*/,"Total Armamento" /*cTitle*/,{|oModel| oModel:GetValue("CALC_TFL","TOT_TXQ")} /*bFormula*/)  // "Total Uniforme"
Endif

oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_TOTAL', 'TOT_GERAL_EN', 'FORMULA',{|| .T.}  /*bCondition*/, /*bInitValue*/,STR0262 /*cTitle*/, bFormTotEn/*bFormula*/)  // "Total Ativo"

If TFL->( ColumnPos('TFL_GERPLA') )
	oModel:AddCalc( 'TOTAIS', 'TFJ_REFER', 'TFL_LOC', 'TFL_GERPLA', 'TOT_GERPLA', 'SUM',  /*bCondition*/, /*bInitValue*/,"Total Geral Planilha" /*cTitle*/, /*bFormula*/)  // "Total Ativo"
Endif
//--------------------------------------
//fim dos totais exibidos
//--------------------------------------
oMdlCalc := oModel:GetModel("TOTAIS")

If lVersion23
	// Altera estrutura do modelo para orçamento simplificado
	At740MdSm(oStrTFJ)
EndIf
If lPutLeg
	At740AddLeg(.T.,{oStrTFL},{oStrTFF},{oStrTFI})
EndIf


oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} At740GtDes
	Função para cálculo dos valores gerais da proposta

@since   	04/10/2013
@version 	P11.90
/*/
//-------------------------------------------------------------------
Function At740GtDes()

Local oModel := FwModelActive()
Local oMdlCalc := oModel:GetModel("TOTAIS")


oMdlCalc:LoadValue('TOT_RH',(oMdlCalc:GetValue('TOT_RH')),.T.)
oMdlCalc:LoadValue('TOT_MI',(oMdlCalc:GetValue('TOT_MI')),.T.)
oMdlCalc:LoadValue('TOT_MC',(oMdlCalc:GetValue('TOT_MC')),.T.)
oMdlCalc:LoadValue('TOT_LE',(oMdlCalc:GetValue('TOT_LE')),.T.)
oMdlCalc:LoadValue('TOT_GERAL',oMdlCalc:GetValue('TOT_RH')+oMdlCalc:GetValue('TOT_MI')+oMdlCalc:GetValue('TOT_MC')+oMdlCalc:GetValue('TOT_LE'),.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@since   	10/09/2013
@version 	P11.90

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView   		:= Nil
Local oModel  		:= If( oCharge <> NIl, oCharge, ModelDef() )
Local lConExt 		:= IsInCallStack("At870GerOrc")
Local oStrTFJ  		:= Nil
Local oStrTFL  		:= Nil
Local oStrTFF  		:= Nil
Local oStrABP  		:= Nil
Local oStrTFG  		:= Nil
Local oStrTFH  		:= Nil
Local oStrTFI  		:= Nil
Local oStrTFU  		:= Nil
Local oStrTEV  		:= Nil
Local oStrTWO  		:= Nil
Local oStrTXP		:= Nil
Local oStrTXQ		:= Nil
Local oStrABZ		:= Nil
Local oStrCalc 		:= FWCalcStruct( oModel:GetModel('TOTAIS') )
Local oStrCusto		:= Nil
Local lOkSly 		:= AliasInDic('SLY')
Local cGsDsGcn		:= ""
Local lAt870Revi 	:= IsInCallStack("At870Revis")
Local aTFJFields 	:= Nil
Local lCreateLE 	:= .F. //Cria a pasta RH
Local lGSRH 		:= GSGetIns("RH")
Local lGSMIMC  		:= GSGetIns("MI")
Local lGSLE 		:= GSGetIns("LE")
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lVersion23	:= HasOrcSimp()
Local lOrcsim		:= SuperGetMV("MV_ORCSIMP",,'2') == '1' .AND. lVersion23
Local lTecXRh		:= SuperGetMv("MV_TECXRH",,.F.)
Local lTecItExtOp 	:= IsInCallStack("At190dGrOrc")
Local nI			:= 0
Local aStrTbl		:= {}
Local aFields		:= {}
Local cNExibCmp		:= ""
Local lTec855 		:= IsInCallStack("TECA855")
Local lGsOrcUnif 	:= FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()
Local lVlrCon		:= TFF->( ColumnPos('TFF_VLRCON') ) > 0
Local lTotGer		:= .F.
Local lTotCus		:= .F.
Local lRet			:= .F.

oStrTFJ  := FWFormStruct(2, 'TFJ', {|cCpo| At740SelFields( 'TFJ', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFL  := FWFormStruct(2, 'TFL', {|cCpo| At740SelFields( 'TFL', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFF  := FWFormStruct(2, 'TFF', {|cCpo| At740SelFields( 'TFF', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrABP  := FWFormStruct(2, 'ABP', {|cCpo| At740SelFields( 'ABP', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFG  := FWFormStruct(2, 'TFG', {|cCpo| At740SelFields( 'TFG', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFH  := FWFormStruct(2, 'TFH', {|cCpo| At740SelFields( 'TFH', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFI  := FWFormStruct(2, 'TFI', {|cCpo| At740SelFields( 'TFI', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTFU  := FWFormStruct(2, 'TFU', {|cCpo| At740SelFields( 'TFU', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTEV  := FWFormStruct(2, 'TEV', {|cCpo| At740SelFields( 'TEV', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrTWO  := FwFormStruct(2, 'TWO', {|cCpo| At740SelFields( 'TWO', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
oStrCusto:= FwFormStruct(2, 'TFJ', {|cCpo| AllTrim( cCpo ) $ "TFJ_TOTCUS|TFJ_TOTGER" } )

lTotGer := oStrCusto:HasField( "TFJ_TOTGER" )
lTotCus := oStrCusto:HasField( "TFJ_TOTCUS" )

If lGsOrcUnif
	oStrTXP  := FwFormStruct(2, 'TXP', {|cCpo| At740SelFields( 'TXP', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
Endif
If lGsOrcArma
	oStrTXQ  := FwFormStruct(2, 'TXQ', {|cCpo| At740SelFields( 'TXQ', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
Endif
If lGsOrcVerb
	oStrABZ  := FwFormStruct(2, 'ABZ', {|cCpo| At740SelFields( 'ABZ', Alltrim(cCpo),lOrcPrc,lVersion23 ) } )
EndIf

oStrTFF:AddField(	"TFF_LEGEND",;		// [01]  C   Nome do Campo
					"00",;				// [02]  C   Ordem
					"",;				// [03]  C   Titulo do campo
					STR0376,;			// [04]  C   Descricao do campo	// STR0376 - 'Legenda'
					{STR0376},;			// [05]  A   Array com Help // STR0376 - 'Legenda'
					"C",;				// [06]  C   Tipo do campo
					"@BMP",;			// [07]  C   Picture
					NIL,;				// [08]  B   Bloco de Picture Var
					"",;				// [09]  C   Consulta F3
					.F.,;				// [10]  L   Indica se o campo é alteravel
					NIL,;				// [11]  C   Pasta do campo
					NIL,;				// [12]  C   Agrupamento do campo
					NIL,;				// [13]  A   Lista de valores permitido do campo (Combo)
					NIL,;				// [14]  N   Tamanho maximo da maior opção do combo
					NIL,;				// [15]  C   Inicializador de Browse
					.T.,;				// [16]  L   Indica se o campo é virtual
					NIL,;				// [17]  C   Picture Variavel
					.F.)				// [18]  L   Indica pulo de linha após o campo

aTFJFields := oStrTFJ:GetFields()

oStrTFJ:SetProperty('TFJ_OBSREJ', MVC_VIEW_CANCHANGE, .F.)
oStrTFJ:SetProperty('TFJ_GESMAT', MVC_VIEW_CANCHANGE, .F.)

If lConExt

	oStrTFJ:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

	If IsinCallstack("At855Brow") .And. TFJ->( ColumnPos('TFJ_OBSREJ') ) > 0

		oStrTFL:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		oStrTFF:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		oStrABP:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		oStrTFG:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		oStrTFH:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		If lGsOrcUnif
			oStrTXP:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		EndIf
		If lGsOrcArma
			oStrTXQ:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		EndIf
		oStrTFI:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		oStrTFU:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		oStrTEV:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		oStrTWO:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		oStrTFJ:SetProperty('TFJ_OBSREJ', MVC_VIEW_CANCHANGE, .T.)
		oStrTFJ:SetProperty('TFJ_APRVOP', MVC_VIEW_CANCHANGE, .T.)
		
		If TFF->( ColumnPos('TFF_QTDVAG') ) > 0
			oStrTFF:SetProperty('TFF_QTDVAG', MVC_VIEW_CANCHANGE, .T.)
			oStrTFF:SetProperty('TFF_QTDVAG', MVC_VIEW_ORDEM,'34')
		EndIf
		
		oStrTFF:SetProperty('TFF_QTPREV', MVC_VIEW_ORDEM,'33')
	Endif

ElseIf lAt870Revi
	At740Habil(aTFJFields, oStrTFJ)
EndIf

If lGsPrecific
	oStrTFF:SetProperty( "TFF_PLACOD", MVC_VIEW_LOOKUP, 'ABW')
	oStrTFF:SetProperty("TFF_PLACOD", MVC_VIEW_CANCHANGE, .T.)
EndIf
//ordena os campos TFI.
oStrTFI:SetProperty( "TFI_ENTEQP", MVC_VIEW_ORDEM, "13" )
oStrTFI:SetProperty( "TFI_COLEQP", MVC_VIEW_ORDEM, "14" )
oStrTFI:SetProperty( "TFI_TOTAL" , MVC_VIEW_ORDEM, "15" )

If (TFF->(ColumnPos('TFF_GERVAG')) > 0)
	oStrTFF:SetProperty( "TFF_GERVAG", MVC_VIEW_ORDEM, "03" )
Endif

// Ordem dos campo de Valor Materiais Implantação e Consumo
If lVlrCon
	oStrTFF:SetProperty("TFF_VLRCON" ,MVC_VIEW_ORDEM, Soma1(oStrTFF:GetProperty('TFF_VLRMAT' , MVC_VIEW_ORDEM)))
EndIf

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_REFER', oStrTFJ, 'TFJ_REFER' )
oView:AddGrid('VIEW_LOC'   , oStrTFL, 'TFL_LOC')
oView:AddGrid('VIEW_RH'    , oStrTFF, 'TFF_RH')
oView:AddGrid('VIEW_MI'    , oStrTFG, 'TFG_MI', , {|| F740LockGrd(oView:GetModel()), oView:Refresh( 'VIEW_MI' ) } )
oView:AddGrid('VIEW_MC'    , oStrTFH, 'TFH_MC', , {|| F740LockGrd(oView:GetModel()), oView:Refresh( 'VIEW_MC' ) })
If !lConExt
	oView:AddGrid('VIEW_BENEF' , oStrABP, 'ABP_BENEF')
	oView:AddGrid('VIEW_HE'    , oStrTFU, 'TFU_HE')
	oView:AddGrid('VIEW_LE'    , oStrTFI, 'TFI_LE')
	oView:AddGrid('VIEW_ADICIO', oStrTEV, 'TEV_ADICIO')
EndIf

If lGsOrcUnif
	oView:AddGrid('VIEW_UNIF'  , oStrTXP, 'TXPDETAIL')
Endif

If lGsOrcArma
	oView:AddGrid('VIEW_ARMA'  , oStrTXQ, 'TXQDETAIL')
Endif

If lGsOrcVerb
	oView:AddGrid('VIEW_VBCCT'  , oStrABZ, 'ABZDETAIL')
Endif

oStrTFL:RemoveField("TFL_TOTIMP")
oStrTFJ:RemoveField("TFJ_PRDRET")

If !GetNewPar("MV_GSLE")
	oStrTFJ:RemoveField("TFJ_TPFRET")
EndIf

If !lOrcPrc
	If TFF->( ColumnPos('TFF_QTDTIP') ) > 0
		oStrTFF:RemoveField("TFF_QTDTIP")
	Endif
EndIf

If lGsPrecific
	If TFJ->( ColumnPos('TFJ_LUCRO') ) > 0
		oStrTFJ:RemoveField("TFJ_LUCRO")
	Endif
	If TFJ->( ColumnPos('TFJ_ADM') ) > 0
		oStrTFJ:RemoveField("TFJ_ADM")
	Endif
	If !GSGetIns('LE') .AND. TFF->( ColumnPos('TFF_LUCRO') ) > 0
		oStrTFF:RemoveField("TFF_LUCRO")
	Endif
	If !GSGetIns('LE') .AND. TFF->( ColumnPos('TFF_ADM') ) > 0
		oStrTFF:RemoveField("TFF_ADM")
	Endif
	If !GSGetIns('LE') .AND. TFF->( ColumnPos('TFF_TXLUCR') ) > 0
		oStrTFF:RemoveField("TFF_TXLUCR")
	Endif
	If !GSGetIns('LE') .AND. TFF->( ColumnPos('TFF_TXADM') ) > 0
		oStrTFF:RemoveField("TFF_TXADM")
	Endif
	If TFF->( ColumnPos('TFF_NARMA') ) > 0
		oStrTFF:RemoveField("TFF_NARMA")
	Endif
	If TFF->( ColumnPos('TFF_NCOLE') ) > 0
		oStrTFF:RemoveField("TFF_NCOLE")
	Endif
	If TFH->( ColumnPos('TFH_LUCRO') ) > 0
		oStrTFH:RemoveField("TFH_LUCRO")
	Endif
	If TFH->( ColumnPos('TFH_ADM') ) > 0
		oStrTFH:RemoveField("TFH_ADM")
	Endif
	If TFH->( ColumnPos('TFH_TXLUCR') ) > 0
		oStrTFH:RemoveField("TFH_TXLUCR")
	Endif
	If TFH->( ColumnPos('TFH_TXADM') ) > 0
		oStrTFH:RemoveField("TFH_TXADM")
	Endif
	If TFG->( ColumnPos('TFG_LUCRO') ) > 0
		oStrTFG:RemoveField("TFG_LUCRO")
	Endif
	If TFG->( ColumnPos('TFG_ADM') ) > 0
		oStrTFG:RemoveField("TFG_ADM")
	Endif
	If TFG->( ColumnPos('TFG_TXLUCR') ) > 0
		oStrTFG:RemoveField("TFG_TXLUCR")
	Endif
	If TFG->( ColumnPos('TFG_TXADM') ) > 0
		oStrTFG:RemoveField("TFG_TXADM")
	Endif
	If TEV->( ColumnPos('TEV_LUCRO') ) > 0
		oStrTEV:RemoveField("TEV_LUCRO")
	Endif
	If TEV->( ColumnPos('TEV_ADM') ) > 0
		oStrTEV:RemoveField("TEV_ADM")
	Endif
	If TEV->( ColumnPos('TEV_TXLUCR') ) > 0
		oStrTEV:RemoveField("TEV_TXLUCR")
	Endif
	If TEV->( ColumnPos('TEV_TXADM') ) > 0
		oStrTEV:RemoveField("TEV_TXADM")
	Endif
	If TXP->( ColumnPos('TXP_LUCRO') ) > 0 .AND. lGsOrcUnif
		oStrTXP:RemoveField("TXP_LUCRO")
	Endif
	If TXP->( ColumnPos('TXP_ADM') ) > 0 .AND. lGsOrcUnif
		oStrTXP:RemoveField("TXP_ADM")
	Endif
	If TXP->( ColumnPos('TXP_TXLUCR') ) > 0 .AND. lGsOrcUnif
		oStrTXP:RemoveField("TXP_TXLUCR")
	Endif
	If TXP->( ColumnPos('TXP_TXADM') ) > 0 .AND. lGsOrcUnif
		oStrTXP:RemoveField("TXP_TXADM")
	Endif
	If lGsOrcUnif
		If TXP->( ColumnPos('TXP_VIDMES') ) > 0
			oStrTXP:SetProperty('TXP_VIDMES', MVC_VIEW_ORDEM, Soma1(oStrTXP:GetProperty('TXP_TOTAL', MVC_VIEW_ORDEM)))
		Else
			oStrTXP:RemoveField("TXP_TOTAL")
		EndIf
	EndIf
 	If TXQ->( ColumnPos('TXQ_LUCRO') ) > 0 .AND. lGsOrcArma
		oStrTXQ:RemoveField("TXQ_LUCRO")
	Endif
	If TXQ->( ColumnPos('TXQ_ADM') ) > 0 .AND. lGsOrcArma
		oStrTXQ:RemoveField("TXQ_ADM")
	Endif
	If TXQ->( ColumnPos('TXQ_TXLUCR') ) > 0 .AND. lGsOrcArma
		oStrTXQ:RemoveField("TXQ_TXLUCR")
	Endif
	If TXQ->( ColumnPos('TXQ_TXADM') ) > 0 .AND. lGsOrcArma
		oStrTXQ:RemoveField("TXQ_TXADM")
	Endif
	If lGsOrcArma
		If TXQ->( ColumnPos('TXQ_VIDMES') ) > 0
			oStrTXQ:SetProperty('TXQ_VIDMES', MVC_VIEW_ORDEM, Soma1(oStrTXQ:GetProperty('TXQ_TOTAL', MVC_VIEW_ORDEM)))
		Else
			oStrTXQ:RemoveField("TXQ_TOTAL")
		EndIf
	EndIf
Endif

If TFJ->( ColumnPos('TFJ_DTPLRV') ) > 0 .AND. !((isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ))
	oStrTFJ:RemoveField("TFJ_DTPLRV")
EndIf

If TFJ->( ColumnPos('TFJ_CODREL') ) > 0
	oStrTFJ:RemoveField("TFJ_CODREL")
EndIf

If TFL->( ColumnPos('TFL_MODPLA') ) > 0
	oStrTFL:RemoveField("TFL_MODPLA")
EndIf

If TFL->( ColumnPos('TFL_CODREL') ) > 0
	oStrTFL:RemoveField("TFL_CODREL")
EndIf

If TFF->( ColumnPos('TFF_MODPLA') ) > 0
	oStrTFF:RemoveField("TFF_MODPLA")
EndIf

If TFF->( ColumnPos('TFF_CODREL') ) > 0
	oStrTFF:RemoveField("TFF_CODREL")
EndIf

If TFG->( ColumnPos('TFG_MODPLA') ) > 0
	oStrTFG:RemoveField("TFG_MODPLA")
EndIf

If TFG->( ColumnPos('TFG_CODREL') ) > 0
	oStrTFG:RemoveField("TFG_CODREL")
EndIf

If TFH->( ColumnPos('TFH_MODPLA') ) > 0
	oStrTFH:RemoveField("TFH_MODPLA")
EndIf

If TFH->( ColumnPos('TFH_CODREL') ) > 0
	oStrTFH:RemoveField("TFH_CODREL")
EndIf

If TFU->( ColumnPos('TFU_MODPLA') ) > 0
	oStrTFU:RemoveField("TFU_MODPLA")
EndIf

If TFU->( ColumnPos('TFU_CODREL') ) > 0
	oStrTFU:RemoveField("TFU_CODREL")
EndIf

If TFL->( ColumnPos('TFL_ATCC') ) > 0 .AND. !(isInCallStack("At870PRev"))
	oStrTFL:RemoveField("TFL_ATCC")
EndIf

If TFF->( ColumnPos('TFF_CODTWO') ) > 0
	oStrTFF:RemoveField("TFF_CODTWO")
EndIf

If TFG->( ColumnPos('TFG_CODTWO') ) > 0
	oStrTFG:RemoveField("TFG_CODTWO")
EndIf

If ABP->( ColumnPos('ABP_NICKPO') ) > 0
	oStrABP:RemoveField("ABP_NICKPO")
EndIf

If TFH->( ColumnPos('TFH_CODTWO') ) > 0
	oStrTFH:RemoveField("TFH_CODTWO")
EndIf

If lGsOrcUnif
	If TXP->( ColumnPos('TXP_CODTWO') ) > 0
		oStrTXP:RemoveField("TXP_CODTWO")
	EndIf
	If TXP->( ColumnPos('TXP_CHVTWO') ) > 0
		oStrTXP:RemoveField("TXP_CHVTWO")
	EndIf
EndIf

If lGsOrcArma
	If TXQ->( ColumnPos('TXQ_CODTWO') ) > 0
		oStrTXQ:RemoveField("TXQ_CODTWO")
	EndIf
	If TXQ->( ColumnPos('TXQ_CHVTWO') ) > 0
		oStrTXQ:RemoveField("TXQ_CHVTWO")
	EndIf
	If  TXQ->( ColumnPos('TXQ_QTDAPO') ) > 0
		oStrTXQ:RemoveField("TXQ_QTDAPO")
	EndIf
EndIf

oStrTFF:RemoveField("TFF_CALCMD")

oStrTFI:RemoveField("TFI_CALCMD")
oStrTFI:RemoveField("TFI_SEPSLD")
oStrTFI:RemoveField("TFI_CONENT")
oStrTFI:RemoveField("TFI_CONCOL")
oStrTFI:RemoveField( "TFI_PLACOD" )
oStrTFI:RemoveField( "TFI_PLAREV" )
oStrTFH:RemoveField( "TFH_TES" )
oStrTFG:RemoveField( "TFG_TES" )

If (oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !(IsInCallStack("TECA870"))) .OR.;
		 ((IsInCallStack("TECA745") .AND. IsInCallStack("a745IncOrc")) .AND. lVersion23)
	cGsDsGcn	:= SuperGetMv("MV_GSDSGCN",,"2")
Else
	cGsDsGcn	:= TFJ->TFJ_DSGCN
EndIf

If  cGsDsGcn == "1"
	//Retira os campos da View
	oStrTFJ:RemoveField('TFJ_GRPRH')
	oStrTFJ:RemoveField('TFJ_GRPMI')
	oStrTFJ:RemoveField('TFJ_GRPMC')
	oStrTFJ:RemoveField('TFJ_GRPLE')
	oStrTFJ:RemoveField('TFJ_TES')
	oStrTFJ:RemoveField('TFJ_TESMI')
	oStrTFJ:RemoveField('TFJ_TESMC')
	oStrTFJ:RemoveField('TFJ_TESLE')
	oStrTFJ:RemoveField('TFJ_DSCRH')
	oStrTFJ:RemoveField('TFJ_DSCMI')
	oStrTFJ:RemoveField('TFJ_DSCMC')
	oStrTFJ:RemoveField('TFJ_DSCLE')

	oStrTFF:SetProperty('TFF_TESPED', MVC_VIEW_ORDEM, Soma1(oStrTFF:GetProperty('TFF_PERFIM', MVC_VIEW_ORDEM)))
	oStrTFG:SetProperty('TFG_TESPED', MVC_VIEW_ORDEM, Soma1(oStrTFG:GetProperty('TFG_PERFIM', MVC_VIEW_ORDEM)))
	oStrTFH:SetProperty('TFH_TESPED', MVC_VIEW_ORDEM, Soma1(oStrTFH:GetProperty('TFH_PERFIM', MVC_VIEW_ORDEM)))
	oStrTFI:SetProperty('TFI_TESPED', MVC_VIEW_ORDEM, Soma1(oStrTFI:GetProperty('TFI_PERFIM', MVC_VIEW_ORDEM)))
Else
	oStrTFF:RemoveField('TFF_TESPED')
	oStrTFG:RemoveField('TFG_TESPED')
	oStrTFH:RemoveField('TFH_TESPED')
	oStrTFI:RemoveField('TFI_TESPED')
	//RH
	If !lGSRH
		oStrTFJ:RemoveField('TFJ_GRPRH')
		oStrTFJ:RemoveField('TFJ_DSCRH')
		oStrTFJ:RemoveField('TFJ_TES')
	EndIf

	//MI
	If !lGSRH .OR. !lGSMIMC
		oStrTFJ:RemoveField('TFJ_GRPMI')
		oStrTFJ:RemoveField('TFJ_DSCMI')
		oStrTFJ:RemoveField('TFJ_TESMI')
		oStrTFJ:RemoveField('TFJ_GRPMC')
		oStrTFJ:RemoveField('TFJ_DSCMC')
		oStrTFJ:RemoveField('TFJ_TESMC')
	EndIf
	//LE
	If !lGSLE
		oStrTFJ:RemoveField('TFJ_GRPLE')
		oStrTFJ:RemoveField('TFJ_DSCLE')
		oStrTFJ:RemoveField('TFJ_TESLE')
	EndIf
EndIf

If lTecXRh .OR. !lGSLE
	oStrTFJ:RemoveField('TFJ_CLIPED')
EndIf

If isInCallStack("At870GerOrc")
	oStrTFF:SetProperty('TFF_COBCTR', MVC_VIEW_ORDEM, '02')
	oStrTFG:SetProperty('TFG_COBCTR', MVC_VIEW_ORDEM, '02')
	oStrTFH:SetProperty('TFH_COBCTR', MVC_VIEW_ORDEM, '02')
	If TXP->( ColumnPos('TXP_COBCTR') ) > 0 .AND. lGsOrcUnif
		oStrTXP:SetProperty('TXP_COBCTR', MVC_VIEW_ORDEM, '02')
	EndIf
	If TXQ->( ColumnPos('TXQ_COBCTR') ) > 0 .AND. lGsOrcArma
		oStrTXQ:SetProperty('TXQ_COBCTR', MVC_VIEW_ORDEM, '02')
	EndIf
EndIf

If TFL->( ColumnPos('TFL_ATCC') ) > 0 .AND. isInCallStack("At870PRev")
	oStrTFL:SetProperty('TFL_ATCC', MVC_VIEW_ORDEM, Soma1(oStrTFL:GetProperty('TFL_DTFIM', MVC_VIEW_ORDEM)))
EndIf

oStrTFG:SetProperty('TFG_VIDMES', MVC_VIEW_ORDEM, Soma1(oStrTFG:GetProperty('TFG_TOTAL', MVC_VIEW_ORDEM)))
oStrTFH:SetProperty('TFH_VIDMES', MVC_VIEW_ORDEM, Soma1(oStrTFH:GetProperty('TFH_TOTAL', MVC_VIEW_ORDEM)))

If lVersion23
	If !lOrcsim
		oStrTFJ:RemoveField('TFJ_VEND')
	EndIf
EndIf

//Item extra operacional
If lTecItExtOp
	//Ponto de entrada para não exibir os campos no item extra operacional
	If ExistBlock("a740NExib")
		cNExibCmp := ExecBlock("a740NExib",.F.,.F.)
	EndIf
	aStrTbl := oModel:Getmodel("TFL_LOC"):GetStruct():GetFields()
	For nI := 1 To Len(aStrTbl)
		If aStrTbl[nI,4] == "N" .Or. AllTrim(aStrTbl[nI,3]) $ cNExibCmp
			oStrTFL:RemoveField(aStrTbl[nI,3])
		Endif
	Next nI
	aStrTbl := oModel:Getmodel("TFF_RH"):GetStruct():GetFields()
	For nI := 1 To Len(aStrTbl)
		If (aStrTbl[nI,4] == "N" .And. aStrTbl[nI,3] <> "TFF_QTDVEN") .Or.;
		 	AllTrim(aStrTbl[nI,3]) $ cNExibCmp
			If !(IsInCallStack("At855Brow") .And. (aStrTbl[nI,3] $ "TFF_QTDVAG|TFF_QTPREV")) //Apresentar campos TFF_QTDVAG e TFF_QTPREV na aprovação operacional
				oStrTFF:RemoveField(aStrTbl[nI,3])
			EndIf
		Endif
	Next nI

	//Troca regra de Consulta F3 na inclusão de Item Extra Operacional para o campo TFF_FUNCAO:
	oStrTFF:SetProperty( 'TFF_FUNCAO', MVC_VIEW_LOOKUP, 'TFFSRJ' )
Endif

If (TFL->( ColumnPos('TFL_DTENCE') ) > 0 .AND. TFF->( ColumnPos('TFF_DTENCE') ) == 0) .OR. (TFL->( ColumnPos('TFL_DTENCE') ) == 0 .AND. TFF->( ColumnPos('TFF_DTENCE') ) > 0)
	If TFL->( ColumnPos('TFL_DTENCE') ) > 0
		oStrTFL:RemoveField('TFL_DTENCE')
	EndIf

	If TFF->( ColumnPos('TFF_DTENCE') ) > 0
		oStrTFF:RemoveField('TFF_DTENCE')
	EndIf
Else
	If TFL->( ColumnPos('TFL_DTENCE') ) > 0
		oStrTFL:SetProperty("TFL_DTENCE", MVC_VIEW_CANCHANGE, .F.)
	EndIf

	If TFF->( ColumnPos('TFF_DTENCE') ) > 0
		oStrTFF:SetProperty("TFF_DTENCE", MVC_VIEW_CANCHANGE, .F.)
	EndIf
EndIf
If (SuperGetMv("MV_ORCPRC",,.F.) .And. SuperGetMv("MV_GSAPROV",,"2") == "1") .Or. SuperGetMv("MV_GSAPROV",,"2") == "2"
	If TFJ->(ColumnPos('TFJ_APRVOP')) > 0
		oStrTFJ:RemoveField('TFJ_APRVOP')
	Endif
	If TFJ->(ColumnPos('TFJ_OBSREJ')) > 0
		oStrTFJ:RemoveField('TFJ_OBSREJ')
	Endif
	If TFJ->(ColumnPos('TFJ_USAPRO')) > 0
		oStrTFJ:RemoveField('TFJ_USAPRO')
	Endif
	If TFJ->(ColumnPos('TFJ_DTAPRO')) > 0
		oStrTFJ:RemoveField('TFJ_DTAPRO')
	Endif
Endif

If TFJ->(ColumnPos("TFJ_RESTEC"))>0
    oStrTFJ:RemoveField("TFJ_RESTEC")
EndIf

If TFJ->(ColumnPos("TFJ_TREINA"))>0
    oStrTFJ:RemoveField("TFJ_TREINA")
EndIf

If oStrTFJ:HasField("TFJ_TOTCUS")
    oStrTFJ:RemoveField("TFJ_TOTCUS")
EndIf
If oStrTFJ:HasField("TFJ_TOTGER")
    oStrTFJ:RemoveField("TFJ_TOTGER")
EndIf

If TFF->( ColumnPos('TFF_CODLIM') ) > 0
	oStrTFF:RemoveField("TFF_CODLIM")
EndIf

If lTec855
	aAdd(aFields,{'TFG_PRCVEN','TFG_TOTAL','TFG_DESCON','TFG_VALDES','TFG_TOTGER','TFG_VIDMES','TFG_DPRMES','TFG_RESRET','TFG_VLATIV','TFG_VLPRPA'})
	aAdd(aFields,{'TFH_PRCVEN','TFH_TOTAL','TFH_DESCON','TFH_VALDES','TFH_TOTGER','TFH_VIDMES','TFH_DPRMES','TFH_VLPRPA'})
	For nI := 1 To Len(aFields[1])
		oStrTFG:RemoveField(aFields[1,nI])
	Next nI
	For nI := 1 To Len(aFields[2])
		oStrTFH:RemoveField(aFields[2,nI])
	Next nI
	If lGsOrcUnif
		oStrTXP:RemoveField("TXP_PRCVEN")
		oStrTXP:RemoveField("TXP_TOTGER")
		oStrTXP:RemoveField("TXP_TOTAL")
	EndIf
	If lGsOrcArma
		oStrTXQ:RemoveField("TXQ_PRCVEN")
		oStrTXQ:RemoveField("TXQ_TOTGER")
		oStrTXQ:RemoveField("TXQ_TOTAL")
	EndIf
EndIf

oView:SetViewProperty( 'VIEW_RH', 'GRIDDOUBLECLICK', { { |oFormulario, cFieldName, nLineGrid, nLineModel| at740LDClk( oFormulario, cFieldName ) } } )

// Adiciona as visões na tela
oView:CreateHorizontalBox( 'TOP'   , 30 )
oView:CreateHorizontalBox( 'MIDDLE', 70 )

oView:CreateFolder( 'ABAS', 'MIDDLE')
oView:AddSheet('ABAS','ABA01',STR0022)  // 'Locais de Atendimento'
oView:AddSheet('ABAS','ABA02',STR0006)  // 'Recursos Humanos'

If !lConExt
	oView:AddSheet('ABAS','ABA03',STR0009)  // 'Locação de Equipamentos'
	lCreateLE := .T.
EndIf
oView:AddSheet('ABAS','ABA05',STR0263, { || TC740RCCL( @nDeduc ) } ) // 'Totais'
If lTotGer .And. lTotCus
	oView:AddSheet('ABAS','ABA06',STR0375, {|| A740TFJCus()}) // STR0375 - 'Custos'
EndIf

// cria as abas e sheet para incluir
oView:CreateHorizontalBox( 'ID_ABA01' , 100,,, 'ABAS', 'ABA01' ) // Define a área de Locais
oView:CreateHorizontalBox( 'ID_ABA02' , 060,,, 'ABAS', 'ABA02' ) // Define a área de RH
oView:CreateHorizontalBox( 'ID_ABA02A', 040,,, 'ABAS', 'ABA02' ) // área dos acionais relacionados com RH

// cria folder e sheets para Abas de Material Consumo, Implantação e Benefícios
oView:CreateFolder( 'RH_ABAS', 'ID_ABA02A')
oView:AddSheet('RH_ABAS','RH_ABAXX','') // 'Aba Dummy'
oView:AddSheet('RH_ABAS','RH_ABA02',STR0007) // 'Materiais de Implantação'
oView:AddSheet('RH_ABAS','RH_ABA03',STR0008) // 'Materiais de Consumo'

If !lConExt
	oView:AddSheet('RH_ABAS','RH_ABA01',STR0023) // 'Benefícios RH'
	oView:AddSheet('RH_ABAS','RH_ABA04',STR0031) // 'Hora Extra'
	oView:CreateHorizontalBox( 'ID_RH_01' , 100,,, 'RH_ABAS', 'RH_ABA01' ) // Define a área de Benefícios item de Rh
	oView:CreateHorizontalBox( 'ID_RH_04' , 100,,, 'RH_ABAS', 'RH_ABA04' ) // Define a área da Hora Extra
	oView:CreateHorizontalBox( 'ID_ABA03' , 060,,, 'ABAS', 'ABA03' ) // Define a área de Locação de Equipamentos
	oView:CreateHorizontalBox( 'ID_ABA03A', 040,,, 'ABAS', 'ABA03' )
	oView:SetOwnerView( 'VIEW_BENEF', 'ID_RH_01')  // Grid Benefícios
	oView:SetOwnerView( 'VIEW_HE'   , 'ID_RH_04')  // Grid Hora Extra
	oView:SetOwnerView( 'VIEW_LE'  , 'ID_ABA03')  // Grid Locação de Equipamentos
	oView:SetOwnerView( 'VIEW_ADICIO'  , 'ID_ABA03A')
	oView:EnableTitleView('VIEW_ADICIO', STR0011)  // 'Cobrança da Locação'
	oView:AddIncrementField('VIEW_BENEF' , 'ABP_ITEM' )
	oView:AddIncrementField('VIEW_ADICIO' , 'TEV_ITEM' )
	oView:AddIncrementField('VIEW_LE' , 'TFI_ITEM' )
	oView:SetViewProperty( 'VIEW_LE', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )
	If TableInDic( "TX8", .F. )
		oView:AddUserButton(STR0182,"",{|oModel| At740ApP(oModel)},,,) // "Aplica Config Planilha"
	EndIf
	If lGSLE
		oView:AddUserButton(STR0087,"",{|| At740ConEq()},,,) //"Consulta Equipamentos"
	EndIf

	// Somente habilita o menu caso nao for vistoria
	If lOkSly .And. !FT600GETVIS() .AND. !isInCallStatck("AT870PlaRe")
		oView:AddUserButton(STR0068,"",{|oModel| AT352TDX(oModel)},,,) //"Vinculo de Beneficios"
	EndIf
	If FindFunction("TecBHasCrn") .AND. TecBHasCrn() .AND. !isInCallStatck("AT870PlaRe")
		oView:AddUserButton(STR0300,"",{|oView| TECA740I(oView,,,cGridFocus)},,,) //"Cronog. Cobrança"
	EndIf
EndIf

If lGsOrcUnif
	oView:AddSheet('RH_ABAS','RH_ABA06',STR0326) // 'Uniforme'
	oView:CreateHorizontalBox( 'ID_RH_06' , 100,,, 'RH_ABAS', 'RH_ABA06' ) // Define a área da Uniforme
	oView:SetOwnerView( 'VIEW_UNIF'  , 'ID_RH_06')
Endif

If lGsOrcArma
	oView:AddSheet('RH_ABAS','RH_ABA07',STR0331) // 'Armamento'
	oView:CreateHorizontalBox( 'ID_RH_07' , 100,,, 'RH_ABAS', 'RH_ABA07' ) // Define a área da Armamento
	oView:SetOwnerView( 'VIEW_ARMA'  , 'ID_RH_07')
Endif

If lGsOrcVerb
	oView:AddSheet('RH_ABAS','RH_ABA08',STR0404) // 'Verbas Folha'
	oView:CreateHorizontalBox( 'ID_RH_08' , 100,,, 'RH_ABAS', 'RH_ABA08' ) // Define a área de Verbas Folha
	oView:SetOwnerView( 'VIEW_VBCCT'  , 'ID_RH_08')
EndIf

oView:AddUserButton(STR0096,"",{|oModel,oView| TEC740NFac(oModel)},,,)	// "Facilitador"

If lTec855
	oView:AddUserButton(STR0068,"",{|oModel| AT352TDX(oModel)},,,) //"Vinculo de Beneficios"
EndIf

// Inclusão da area de totais
oView:CreateHorizontalBox( "ID_ABA05" , 100,,, "ABAS", "ABA05" ) // Area de totais
oView:CreateVerticalBox( "MES_CONTR", 100, "ID_ABA05",, "ABAS", "ABA05" )
oView:AddField( "VIEW_TOT", oStrCalc, "TOTAIS" )

If lTotGer .And. lTotCus
	// Inclusão da area de custos
	oView:CreateHorizontalBox( "ID_ABA06" , 100,,, "ABAS", "ABA06" ) // Area de custos
	oView:CreateVerticalBox( "TOT_CUSTOS", 100, "ID_ABA06",, "ABAS", "ABA06" )
	oView:AddField( "VIEW_CUSTO", oStrCusto, "TFJ_TOT" )
	oView:SetOwnerView("VIEW_CUSTO" ,"TOT_CUSTOS" )
EndIf

oView:CreateHorizontalBox( 'ID_RH_02' , 100,,, 'RH_ABAS', 'RH_ABA02' ) // Define a área de Materiais de Implantação
oView:CreateHorizontalBox( 'ID_RH_03' , 100,,, 'RH_ABAS', 'RH_ABA03' ) // Define a área de Materiais de Consumo

// Faz a amarração das VIEWs dos modelos com as divisões na interface
oView:SetOwnerView('VIEW_REFER'	,'TOP')			// Cabeçalho
oView:SetOwnerView('VIEW_LOC'	,'ID_ABA01')	// Grid Locais
oView:SetOwnerView('VIEW_RH'	,'ID_ABA02')	// Grid RH
oView:SetOwnerView('VIEW_MI'    ,'ID_RH_02')  // Grid Materiais de Implantação
oView:SetOwnerView('VIEW_MC'    ,'ID_RH_03')  // Grid Materiais de Consumo
oView:SetOwnerView("VIEW_TOT"   ,"MES_CONTR" )

oView:EnableTitleView( "VIEW_TOT", STR0264) //"Valor Total do Contrato"

oView:AddIncrementField('VIEW_MC' , 'TFH_ITEM' )
oView:AddIncrementField('VIEW_MI' , 'TFG_ITEM' )
oView:AddIncrementField('VIEW_RH' , 'TFF_ITEM' )

oView:SetAfterViewActivate({|oView| At740Refre(oView)})

SetKey( VK_F4, { || AT740F4() } )

If !lTecItExtOp
	oView:AddUserButton(STR0032,"",{|oModel| TECA998(oModel,oView)},,,) // "Planilha Preço"
	oView:AddUserButton(STR0033,"",{|oModel| At740CpCal(oModel)},,,) //"Copiar Cálculo"
	oView:AddUserButton(STR0034,"",{|oModel| At740ClCal(oModel)},,,) //"Colar Cálculo"
	oView:AddUserButton(STR0352,"",{|oModel| At740PlLot(oModel)},,,) //"Aplicar Planilha em Lote"

	If FindFunction("TECA740J") .And. TCX->( ColumnPos('TCX_OBRGT') ) > 0
		oView:AddUserButton(STR0353,"",{|oModel| lRet := TECA740J(oModel), TC740Mnt(oModel, lRet)},,,) //"Verbas Adicionais - Folha (F8)"
	    SetKey(VK_F8,{|| lRet := TECA740J(oModel), TC740Mnt(oModel, lRet)})
	EndIf
	If FindFunction("TECA740K") .And. TableInDic("TXO") .And. TXO->( ColumnPos('TXO_COD') ) > 0
		oView:AddUserButton(STR0354,"",{|oModel| lRet := TECA740K(oModel), TC740Mnt(oModel, lRet)},,,) //"Verbas Adicionais - Benefícios (F9)"
	    SetKey(VK_F9,{|| lRet := TECA740K(oModel), TC740Mnt(oModel, lRet)})
	EndIf
	If FindFunction("TECA740L") .And. TCX->( ColumnPos('TCX_OBRGT') ) > 0
		oView:AddUserButton(STR0366,"",{|oModel| lRet := TECA740L(oModel), TC740Mnt(oModel, lRet)},,,) //"Verbas Adicionais - Despesas (F10)"
	    SetKey(VK_F10,{|| lRet := TECA740L(oModel), TC740Mnt(oModel, lRet)})
	EndIf
	If FindFunction("TECA740M") .And. TDZ->( ColumnPos('TDZ_ALTERA') ) > 0
		oView:AddUserButton(STR0384,"",{|oModel| lRet := TECA740M(oModel), TC740Mnt(oModel, lRet)},,,) //"Benefícios (F11)"
	    SetKey(VK_F11,{|| lRet := TECA740M(oModel), TC740Mnt(oModel, lRet)})
	EndIf
Endif

// Ativa evento ao mudar de linha
oView:SetViewProperty( 'VIEW_LOC', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )
oView:SetViewProperty( 'VIEW_RH', "CHANGELINE", {{ |oView, cViewID| a740ChgLine(oView, cViewID) }} )

If lPutLeg
	At740AddLeg(.F.,{oStrTFL,'VIEW_LOC' },{oStrTFF,'VIEW_RH'},{oStrTFI,'VIEW_LE'},oView)
EndIf

If lVersion23
	If IsInCallStack("TECA745")
		oView:AddUserButton(STR0152,"",{|| At745ImpVs()},,,)
	EndIf
	At740VwSm(oStrTFJ)
EndIf

oView:AddUserButton(STR0223,"",{|oView| At740PosRg(oView)},,,) //"Posicionar"

If !lGSRH
	oView:HideFolder('ABAS',STR0006,  2)// 'Recursos Humanos'
Else
	If (!lGSMIMC .Or. lTecItExtOp) .AND. !lTec855
		oView:HideFolder('RH_ABAS',STR0007,2) //'Materiais de Implantação'
		oView:HideFolder('RH_ABAS',STR0008,2) //'Materiais de Consumo'
	EndIf
EndIf

If (lCreateLE .AND. !lGSLE) .Or. lTecItExtOp
	oView:HideFolder('ABAS',STR0009,2)  // 'Locação de Equipamentos'
EndIf

If lTecItExtOp
	oView:HideFolder('ABAS',STR0263,2) //'Totais'
	oView:HideFolder('ABAS',STR0375,2) //'Custos'
	oView:HideFolder('RH_ABAS',STR0404,2) //'Verbas Folha'
	//oView:HideFolder('RH_ABAS',STR0326,2) //'Uniforme'
	//oView:HideFolder('RH_ABAS',STR0331,2) //'Armamento'
EndIf

oView:HideFolder('RH_ABAS','',2) //'Aba Dummy'

If FindFunction("TECA998A")
	SetKey(VK_F7,{|| FwMsgRun(Nil,{|| TECA998A(oModel,oView)}, Nil, "Carregando")})
EndIf

oView:GetViewObj("VIEW_RH")[3]:SetGotFocus({||cGridFocus := "VIEW_RH"})
oView:GetViewObj("VIEW_MI")[3]:SetGotFocus({||cGridFocus := "VIEW_MI"})
oView:GetViewObj("VIEW_MC")[3]:SetGotFocus({||cGridFocus := "VIEW_MC"})

If ExistBlock("a740GrdV")
	ExecBlock("a740GrdV",.F.,.F.,{@oView,oView:aFolders})
EndIf

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SelFields
	Filtra os campos de controle da rotina para não serem exibidos na view
@sample 	At740SelFields()
@since		27/11/2013
@version	P11.90
@param   	cTab, Caracter, Código da tabela a ter o campo avaliado
@param   	cCpoAval, Caracter, Código do campo a ser avaliado

@return 	lRet, Logico, define se o campo deve ser apresentado na view
/*/
//------------------------------------------------------------------------------
Function At740SelFields( cTab, cCpoAval, lOrcPrc, lVersion23 )

Local lRet   	 	:= .T.
Local lCpoTWO 		:= TWO->( ColumnPos('TWO_CODIGO') ) > 0

Default lOrcPrc	 	:= SuperGetMv("MV_ORCPRC",,.F.)
Default lVersion23  := HasOrcSimp()

If !Empty( cTab ) .And. !Empty( cCpoAval )
	If cTab == 'TFJ'
		If lVersion23
			lRet := !( cCpoAval $ 'TFJ_PROPOS#TFJ_PREVIS#TFJ_ENTIDA#TFJ_ITEMRH#TFJ_ITEMMI#TFJ_ITEMMI#TFJ_DESCON#TFJ_DSGCN#TFJ_ORCSIM' )
		Else
			lRet := !( cCpoAval $ 'TFJ_PROPOS#TFJ_PREVIS#TFJ_ENTIDA#TFJ_ITEMRH#TFJ_ITEMMI#TFJ_ITEMMI#TFJ_DESCON#TFJ_DSGCN' )
		EndIf
		lRet := lRet .And. !( cCpoAval $ 'TFJ_ITEMMC#TFJ_ITEMLE#TFJ_CONTRT#TFJ_CONREV#TFJ_STATUS#TFJ_TOTRH#TFJ_TOTMI#TFJ_TOTMC#TFJ_TOTLE#TFJ_CODVIS#TFJ_TABXML#TFJ_TOTUNI#TFJ_TOTARM#TFJ_GERPLA' )

		If !lOrcPrc // Retirar campos para o modelo antigo de orçamento de serviços
			lRet := lRet .And. !( cCpoAval $ 'TFJ_CODTAB#TFJ_TABREV')
		EndIf
	ElseIf cTab == 'TFL'
		lRet := !( cCpoAval $ 'TFL_CODIGO#TFL_CODPAI#TFL_CONTRT#TFL_CONREV#TFL_CODSUB' )
		lRet := lRet .And. !( cCpoAval $ 'TFL_ITPLRH#TFL_ITPLMI#TFL_ITPLMC#TFL_ITPLLE#TFL_ENCE' )
		If !lOrcPrc // Retirar campos para o modelo antigo de orçamento de serviços
			lRet := lRet .And. !( cCpoAval $ 'TFL_MESRH#TFL_MESMI#TFL_MESMC' )
		EndIf
	ElseIf cTab == 'TFF'
		lRet := !( (cCpoAval +"#") $ 'TFF_LOCAL#TFF_CODPAI#TFF_CONTRT#TFF_CONREV#TFF_CODSUB#TFF_CHVTWO#TFF_ENCE#TFF_PROCES#TFF_ITCNB#TFF_TABXML#TFF_ITEXOP#' )

		If lOrcPrc // Retirar campos para o novo modelo de orçamento de serviços
			lRet := lRet .And. !( cCpoAval $ 'TFF_TOTMI#TFF_TOTMC#TFF_TOTUNI' )
		Else
			lRet := lRet .And. !( cCpoAval $ 'TFF_TOTMES' )
		EndIf

		If !IsinCallstack("At855Brow")
			lRet := lRet .And. !( cCpoAval $ 'TFF_QTDVAG' )
		EndIf
	ElseIf cTab == 'TFI'
		lRet := !( cCpoAval $ 'TFI_COD#TFI_LOCAL#TFI_OK#TFI_SEPARA#TFI_CODPAI#TFI_CONTRT#TFI_CONREV#TFI_CODSUB#TFI_CHVTWO#TFI_ITCNB' )
		lRet := lRet .And. !( cCpoAval $ 'TFI_CODTGQ#TFI_ITTGR#TFI_CODATD#TFI_NOMATD#TFI_CONENT#TFI_CONCOL#TFI_ENCE#TFI_DTPFIM' )
	ElseIf cTab == 'ABP'
		If cCpoAval == "ABP_ITEM"
			lRet := .T.
		Else
			lRet := !( cCpoAval $ 'ABP_COD#ABP_REVISA#ABP_CODPRO#ABP_ENTIDA#ABP_ITRH#ABP_ITEMPR#ABP_CODTWO#ABP_CHVTWO' )
		EndIf
	ElseIf cTab == 'TFG'
		lRet := !( cCpoAval $ 'TFG_COD#TFG_LOCAL#TFG_CODPAI#TFG_SLD#TFG_CODSUB#TFG_CHVTWO#TFG_ITCNB#TFG_CONTRT#TFG_CONREV' )
	ElseIf cTab == 'TFH'
		lRet := !( cCpoAval $ 'TFH_COD#TFH_LOCAL#TFH_CODPAI#TFH_SLD#TFH_CODSUB#TFH_CHVTWO#TFH_ITCNB#TFH_CONTRT#TFH_CONREV' )
	ElseIf cTab == 'TFU'
		lRet := !( cCpoAval $ 'TFU_CODIGO#TFU_CODTFF#TFU_LOCAL' )
	ElseIf cTab == 'TEV'
		lRet := !( cCpoAval $ 'TEV_CODLOC#TEV_SLD' )
	ElseIf cTab == 'TWO'
		If lCpoTWO
			lRet := !( cCpoAval $ 'TWO_CODORC#TWO_PROPOS#TWO_OPORTU#TWO_LOCAL#TWO_CODIGO' )
		Else
			lRet := !( cCpoAval $ 'TWO_CODORC#TWO_PROPOS#TWO_OPORTU#TWO_LOCAL' )
		EndIf
	ElseIf cTab == 'TXP'
		lRet := !( cCpoAval $ 'TXP_CONTRT#TXP_CONREV#TXP_CODSUB#TXP_CODTFF' )
	ElseIf cTab == 'TXQ'
		lRet := !( cCpoAval $ 'TXQ_CONTRT#TXQ_CONREV#TXQ_CODSUB#TXQ_CODTFF' )
	ElseIf cTab == 'ABZ'
		lRet := !( cCpoAval $ 'ABZ_CODTFF#ABZ_FILSRV#ABZ_FILCCT#ABZ_CCTCOD' )
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SubTot
	Inicializa o subtotal da linha
@sample 	At740SubTot()
@since		12/09/2013
@version	P11.90
@return 	nValor, NUMERIC, valor da multiplicação do preço unitário com a quantidade
/*/
//------------------------------------------------------------------------------
Function At740SubTot()

Local nValor     := 0
Local oMdlAtivo  := FwModelActive()
Local oMdlGrid   := Nil

If oMdlAtivo <> Nil .And. (oMdlAtivo:GetId()=="TECA740" .Or. oMdlAtivo:GetId()=="TECA740F")

	oMdlGrid := oMdlAtivo:GetModel( "TEV_ADICIO" )

	If oMdlGrid:GetLine()<>0

		nValor := oMdlGrid:GetValue("TEV_VLRUNI") * oMdlGrid:GetValue("TEV_QTDE")
	EndIf

EndIf

Return nValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Cmt
	Realizar a gravação dos dados
@sample 	At740Cmt()
@since		20/09/2013
@version	P11.90
@return 	oModel, Object, instância do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At740Cmt( oModel )

Local lRet 				:= .T.
Local aCriaSb2 			:= {}
Local nLocais 			:= 0
Local nRHs    			:= 0
Local nMateriais 		:= 0
Local lOrcPrc			:= !EMPTY( oModel:GetValue('TFJ_REFER','TFJ_CODTAB') )
Local aRows    			:= {}
Local aItemRH  			:= {}
Local lGrvOrc	 		:= At740GCmt()
Local cGsdsgcn 	 		:= oModel:GetValue( 'TFJ_REFER', 'TFJ_DSGCN')
Local cCodOrc			:= ""
Local cContrato			:= oModel:GetValue( 'TFJ_REFER', 'TFJ_CONTRT')
Local cRevisa			:= oModel:GetValue( 'TFJ_REFER', 'TFJ_PREVIS')
Local lOrcSim	 		:= .F.
Local nForcaCalc 		:= 1
Local nMaxRhs 			:= 0
Local lFillPropVist 	:= ( IsInCallStack('FATA600') .Or. IsInCallStack('TECA270') .Or. At740ToADZ() )
Local nLastPosVal := 0 //Guarda ultima linha valida
Local lVersion23	:= HasOrcSimp()
Local lContExt	:= IsInCallStack("At870GerOrc")
Local cTabXML := "" //MXL de gravação do orçamento
Local oMdlTFL   := oModel:GetModel('TFL_LOC')
Local oMdlTFF	:= oModel:GetModel('TFF_RH')
Local oMdlTFI	:= oModel:GetModel('TFI_LE')
Local oMdlTFG	:= oModel:GetModel('TFG_MI')
Local oMdlTFH	:= oModel:GetModel('TFH_MC')
Local oMdlTFU	:= oModel:GetModel('TFU_HE')
Local oMdlTXQ	:= Nil
Local oMdlTXP	:= Nil
Local oMdlTDS	:= Nil
Local oMdlTDT	:= Nil
Local oMdlTGV	:= Nil
Local aOldRec := {}
Local nPosTFL := 0
Local lAtuCod :=  oModel:IsCopy() .OR. (isInCallStack("AT870RvPlC") .AND. !isInCallStack("At870Eftrv"))
Local nI := 1
Local aRecSubCod := {}
Local cNewCod := ""
Local nX	:= 1
Local lRevi := (isInCallStatck("At870Revis") .And. TFJ->TFJ_STATUS == '1') .OR. isInCallStatck("AT870PlaRe")
Local aArea
Local aTFFOrg := {}
Local aAreaTFF := {}
Local lMdtGS 	:= SuperGetMv("MV_NG2GS",.F.,.F.) .And. TableInDic("TN5") .And. TableInDic("TN6") //Parâmetro de integração entre o SIGAMDT x SIGATEC
Local cMensagem := ""
Local cEventID := "062"
Local cCodLoc  := ""
Local lAprovOp	:= SuperGetMv("MV_GSAPROV" , .F. , "2")  == "1"
Local aAreaTFJ	:= {}
Local lProcessa := .T.
Local lTec855 		:= IsInCallStack("TECA855")
Local lGsOrcUnif 	:= FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()

If lVersion23
	lOrcSim 		:= oModel:GetValue( 'TFJ_REFER', 'TFJ_ORCSIM') == '1'
EndIF

iF lTec855
	If oModel:GetModel('TFJ_REFER'):GetValue('TFJ_APRVOP') $ '|1|3|' .And. Empty(oModel:GetModel('TFJ_REFER'):GetValue('TFJ_OBSREJ'))
		lRet := .F.
		lProcessa := .F.
		Help( , , "At740Cmt", Nil, STR0339, 1, 0,,,,,,{STR0340}) //"Código de orçamento está em branco."#"Execute a rotina novamemte e informe um código de orçamento existente."
	Endif
Endif

// Atualiza as informações dos recursos humanos calculando conforme o preenchimento
If lProcessa .And. lOrcPrc .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE
	If !lContExt
		//Se não for item extra, habilita o cálculo usando a planilha de precificação do orçamento de serviços
		At740GSC(.T.)
	Else
		At740GSC(.F.)
	EndIf
	For nLocais := 1 To oMdlTFL:Length()
		oMdlTFL:GoLine( nLocais )
		nMaxRhs := oMdlTFF:Length()
		nLastPosVal := 0
		For nX := 1 To oMdlTFG:Length()
			oMdlTFG:GoLine(nX)
			If IsInCallStack("At870GerOrc") .AND. oMdlTFG:GetValue("TFG_COBCTR") == "2" .AND.;
			 		!Empty(oMdlTFG:GetValue('TFG_PRODUT')) .AND. !(oMdlTFG:IsDeleted())
				If oMdlTFG:IsInserted()
					oMdlTFG:LoadValue('TFG_SLD', oMdlTFG:GetValue('TFG_QTDVEN') )
					oMdlTFG:LoadValue("TFG_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
					oMdlTFG:LoadValue("TFG_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
				Else
					At870revMt(oModel,"TFG",oMdlTFG:GetValue("TFG_COD"))
				EndIf
			Endif
			If lAtuCod
				If !oMdlTFG:IsDeleted() .And. !Empty(oMdlTFG:GetValue('TFG_PRODUT')) .And. !oMdlTFG:IsInserted()
					//-- Atualiza saldo do item
					If lRevi
						At870revMt(oModel,"TFG",oMdlTFG:GetValue("TFG_COD"))
					Endif
					cNewCod := CriaVar("TFG_COD",.T.)
					Aadd(aRecSubCod, {"TFG",oMdlTFG:GetValue("TFG_COD"),cNewCod})
					oMdlTFG:LoadValue("TFG_COD",cNewCod)
				ElseIf !Empty(oMdlTFG:GetValue('TFG_PRODUT')) .And. oMdlTFG:IsInserted()
					oMdlTFG:LoadValue('TFG_SLD', oMdlTFG:GetValue('TFG_QTDVEN') )
				EndIf
			EndIf
		Next nX
		For nX := 1 To oMdlTFH:Length()
			oMdlTFH:GoLine(nX)
			If IsInCallStack("At870GerOrc") .AND. oMdlTFH:GetValue("TFH_COBCTR") == "2" .AND.;
			 		!Empty(oMdlTFH:GetValue('TFH_PRODUT')) .AND. !(oMdlTFH:IsDeleted())
				If oMdlTFH:IsInserted()
					oMdlTFH:LoadValue("TFH_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
					oMdlTFH:LoadValue("TFH_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
					oMdlTFH:LoadValue('TFH_SLD', oMdlTFH:GetValue('TFH_QTDVEN') )
				Else
					At870revMt(oModel,"TFH",oMdlTFH:GetValue("TFH_COD"))
				EndIf
			EndIf
			If lAtuCod
				If !oMdlTFH:IsDeleted() .And. !Empty(oMdlTFH:GetValue('TFH_PRODUT')) .And. !oMdlTFH:IsInserted()
					If lRevi
						At870revMt(oModel,"TFH",oMdlTFH:GetValue("TFH_COD"))
					EndIf
					cNewCod := CriaVar("TFH_COD",.T.)
					Aadd(aRecSubCod, {"TFH",oMdlTFH:GetValue("TFH_COD"),cNewCod})
					oMdlTFH:LoadValue("TFH_COD",cNewCod)
				ElseIf !Empty(oMdlTFH:GetValue('TFH_PRODUT')) .And. oMdlTFH:IsInserted()
					oMdlTFH:LoadValue('TFH_SLD', oMdlTFH:GetValue('TFH_QTDVEN') )
				EndIf
			EndIf
		Next nX
		If lAtuCod .And. !oMdlTFL:IsDeleted() .And. !oMdlTFL:IsInserted()
			cNewCod := CriaVar("TFL_CODIGO",.T.)
			Aadd(aRecSubCod, {"TFL",oMdlTFL:GetValue("TFL_CODIGO"),cNewCod})
			oMdlTFL:LoadValue("TFL_CODIGO",cNewCod)
		EndIf
		For nRHs := 1 To nMaxRhs
			oMdlTFF:GoLine( nRHs )
			If ((isInCallStack("At190dGrOrc") .Or. lContExt) .AND. (oMdlTFF:IsUpdated() .OR. oMdlTFF:IsInserted()) .AND. oMdlTFF:GetValue("TFF_COBCTR") == "2" .AND. oMdlTFF:GetValue("TFF_ITEXOP") == "1"  )
				If Empty(cMensagem)
					cMensagem  := STR0270 +  oMdlTFL:GetValue('TFL_CONTRT') + Chr(13) + Chr(10) + "" //Contrato
					cMensagem  += STR0271 + oMdlTFL:GetValue('TFL_CODPAI') + Chr(13) + Chr(10) + "" //Orçamento
					cMensagem  += STR0272 + oMdlTFL:GetValue('TFL_CODIGO') + Chr(13) + Chr(10) + "" // Local de Atendimento
					cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
					cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
					cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
					cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
					cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
					cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
					cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
					cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
					cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
					cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
					cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
					cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
					cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
					cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
					cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
				Else
					If cCodLoc != oMdlTFL:GetValue('TFL_CODIGO')
						cMensagem  += STR0272 + oMdlTFL:GetValue('TFL_CODIGO') + Chr(13) + Chr(10) + "" // Local de Atendimento
						cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
						cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
						cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
						cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
						cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
						cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
						cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
						cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
						cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
						cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
						cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
						cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
						cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
						cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
						cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
					Else
						cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
						cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
						cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
						cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
						cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
						cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
						cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
						cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
						cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
						cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
						cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
						cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
						cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
						cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
						cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
					EndIf
				EndIf
				cMensagem  += Chr(13) + Chr(10)
				cCodLoc := oMdlTFL:GetValue('TFL_CODIGO')
			EndIf
			If isInCallStack("At870GerOrc") .AND. oMdlTFF:isDeleted() .AND. oMdlTFF:GetValue("TFF_COBCTR") == "2"
				aArea := GetArea()
				DbSelectArea("ABQ")
				ABQ->(DbSetOrder(3))
				If ABQ->( dbSeek( xFilial("ABQ") + oMdlTFF:GetValue("TFF_COD") + xFilial("TFF") ) )
					RecLock( "ABQ", .F. )
					ABQ->( dbDelete() )
					ABQ->( MsUnlock() )
				EndIf
				RestArea(aArea)
			EndIf
			// Antes de Utilizar qualquer valor da tabela de precificação efetua o calculo
			If !Empty(oMdlTFF:GetValue('TFF_PRODUT'))
				// verifica se é o último item para forçar atualização dos acumuladores base para impostos
				If nRHs == nMaxRhs
					nForcaCalc := 2
				Else
					nForcaCalc := 1
					nLastPosVal := nRHs
				EndIf
				// Identifica o objeto conforme o array com as planilhas / FwWorkSheet
				// Captura as tabela de precificação em uso pelo orçamento de serviços
				// modelo para captura do preenchimento e dados
				If ((oMdlTFF:GetValue('TFF_COBCTR') <> '2' .AND. !(isInCallStack("At870GerOrc"))) .OR.;
						(oMdlTFF:GetValue('TFF_COBCTR') == '2' .AND. isInCallStack("At870GerOrc"))) // pertence ao contrato
					//Colocar If para verificar se a tabela foi carregada ou se é uma linha nova
					If (oMdlTFF:GetValue("TFF_LOADPRC") .And. !oMdlTFF:IsInserted()) .Or. (!oMdlTFF:GetValue("TFF_LOADPRC") .And. oMdlTFF:IsInserted())
					Processa( {|| ( At740EEPC( At740FGSS(oModel), At740FORC(), oModel, , nForcaCalc ) ) }, STR0082, STR0083,.F.) // "Aguarde..." ### "Executando cálculo ..."
					EndIf
				ElseIf oMdlTFF:GetValue('TFF_COBCTR') == '2' .AND. !(isInCallStack("At870GerOrc") .OR. isInCallStack("At870PRev") .OR. isInCallStack("At870AprRv"))
					If Len(At40GetAFWS()) > 0
                        At40GetAFWS()[nLocais][2][nRHs][1] := oMdlTFF:GetValue('TFF_COD')
                    EndIf
				EndIf
				If lAtuCod .And. !oMdlTFF:IsInserted()
					nPosTFL := Ascan(aOldRec, {|x| x[1] == nLocais })
					If nPosTFL == 0
						Aadd(aOldRec,{nLocais,{oMdlTFF:GetValue("TFF_COD")}})
					Else
						Aadd(aOldRec[nPosTFL,2],oMdlTFF:GetValue("TFF_COD"))
					EndIf
					cNewCod := CriaVar("TFF_COD",.T.)
					Aadd(aRecSubCod, {"TFF",oMdlTFF:GetValue("TFF_COD"),cNewCod})
					oMdlTFF:LoadValue("TFF_COD",cNewCod)
					If lRevi .AND. !(isInCallStatck("AT870PlaRe"))
						At740UpSLY(aRecSubCod[Len(aRecSubCod)][2],aRecSubCod[Len(aRecSubCod)][3])
					EndIf
				EndIf
			EndIf
		Next nRHs
		If nForcaCalc == 1 .AND. nLastPosVal > 0  //Nao recalculou todos os itens de RH, então posiciona no ultimo valido e força atualização dos acumuladores base para impostos
			nForcaCalc := 2
			oMdlTFF:GoLine( nLastPosVal )
			Processa( {|| ( At740EEPC( At740FGSS(oModel), At740FORC(), oModel, , nForcaCalc ) ) }, STR0082, STR0083,.F.) // "Aguarde..." ### "Executando cálculo ..."
 		EndIf
	Next nLocais
	If TFF->( ColumnPos('TFF_TABXML') ) > 0
		At740FMXML(oModel,,aOldRec)
	Else
		cTabXML := At740FMXML(oModel,,aOldRec)
		oModel:GetModel('TFJ_REFER'):LoadValue('TFJ_TABXML',cTabXML)
	EndIf
	// desabilita os cálculos
	At740GSC(.F.)
EndIf
If lProcessa .And. lGrvOrc
	If lVersion23
		// Seta os valores de referência para os itens agrupadores do orçamento, caso o parâmetro MV_GSDSGCN esteja ativo
		IF lOrcSim .AND. cGsdsgcn <> '1' .AND. oModel:GetOperation() != MODEL_OPERATION_DELETE
			AT745RefProd(oModel)
		EndIf
	EndIf
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If lVersion23
			cCodOrc := oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO')
		EndIf
		If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
			Tec740IExc(oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO'),;
				/*cTFL*/,;
				/*cTFF*/,;
				/*cTFG*/,;
				/*cTFH*/,;
				oModel:GetOperation())
		EndIf
		//Deleta os critérios de benefícios da revisão na exclusão da revisão:
		If lRet .And. IsInCallStack("At870ExcR")
			If Len(aBenefTFF) > 0
				AtDelBenef()
			EndIf
		EndIf
		If ( lRet := FwFormCommit( oModel ) )
			aEnceCpos := {}
			If lVersion23
				If lRet .AND. lOrcSim
					aArea := GetArea()
					DbSelectArea("AAT")
					DbSetOrder(4) //filial + codorc
					If DbSeek(xFilial("AAT") + cCodOrc)
						RecLock("AAT",.F.)
							AAT->AAT_CODORC := ""
						MsUnlock()
					EndIf
					RestArea(aArea)
				EndIf
			EndIf
		EndIf
	Else
		//----------------------------------------------------------
		//  Identifica os produtos que ainda não estão com o saldo inicial
		// criado
		aRows := FwSaveRows()
		DbSelectArea('SB1')
		SB1->( DbSetOrder( 1 ) ) // B1_FILIAL+B1_COD
		DbSelectArea('SB2')
		SB2->( DbSetOrder( 1 ) ) // B2_FILIAL+B2_COD+B2_LOCAL
		//Atualização TFL - Local de Atendimento:
		For nLocais := 1 To oMdlTFL:Length()
			oMdlTFL:GoLine( nLocais )
			If !lOrcPrc .And. lAtuCod .And. !oMdlTFL:IsDeleted() .And. !oMdlTFL:IsInserted()
				If isInCallStack("AT870RvPlC")
					cNewCod := oMdlTFL:GetValue("TFL_CODIGO")
				Else
					cNewCod := CriaVar("TFL_CODIGO",.T.)
				EndIf
				If isInCallStack("AT870RvPlC")
					Aadd(aRecSubCod, {"TFL",oMdlTFL:GetValue("TFL_CODREL"),cNewCod})
				Else
					Aadd(aRecSubCod, {"TFL",oMdlTFL:GetValue("TFL_CODIGO"),cNewCod})
				EndIf
				oMdlTFL:LoadValue("TFL_CODIGO",cNewCod)
				If isInCallStack("AT870PlaRe")
					oMdlTFL:LoadValue("TFL_CONTRT", "")
				EndIf
			EndIf
			//Atualização TFI: LOCAÇÃO DE EQUIPAMENTOS
			If lAtuCod
				For nI := 1 To oMdlTFI:Length()
					oMdlTFI:GoLine(nI)
					If !oMdlTFI:IsDeleted() .And. !Empty(oMdlTFI:GetValue('TFI_PRODUT')) .And. !oMdlTFI:IsInserted()
						cNewCod := CriaVar("TFI_COD",.T.)
						Aadd(aRecSubCod, {"TFI",oMdlTFI:GetValue("TFI_COD"),cNewCod})
						oMdlTFI:LoadValue("TFI_COD",cNewCod)
					EndIf
				Next nI
			EndIf
			//Atualização TFF: ITENS DE RH - POSTO
			For nRHs := 1 To oMdlTFF:Length()
				oMdlTFF:GoLine( nRHs )
				If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
					If oMdlTFF:isDeleted() .OR. oMdlTFL:isDeleted()
						Tec740IExc(oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO'),;
													/*cTFL*/,;
													oMdlTFF:GetValue("TFF_COD"),;
													/*cTFG*/,;
													/*cTFH*/,;
													oModel:GetOperation())
					EndIf
				EndIf
				If ((isInCallStack("At190dGrOrc") .Or. lContExt) .AND. !lOrcPrc .AND. (oMdlTFF:IsUpdated() .OR. oMdlTFF:IsInserted()) .AND. oMdlTFF:GetValue("TFF_COBCTR") == "2" .AND. oMdlTFF:GetValue("TFF_ITEXOP") == "1" )
					If Empty(cMensagem)
						cMensagem  := STR0270 +  oMdlTFL:GetValue('TFL_CONTRT') + Chr(13) + Chr(10) + "" //Contrato
						cMensagem  += STR0271 + oMdlTFL:GetValue('TFL_CODPAI') + Chr(13) + Chr(10) + "" //Orçamento
						cMensagem  += STR0272 + oMdlTFL:GetValue('TFL_CODIGO') + Chr(13) + Chr(10) + "" // Local de Atendimento
						cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
						cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
						cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
						cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
						cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
						cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
						cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
						cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
						cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
						cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
						cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
						cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
						cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
						cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
						cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
					Else
						If cCodLoc != oMdlTFL:GetValue('TFL_CODIGO')
							cMensagem  += STR0272 + oMdlTFL:GetValue('TFL_CODIGO') + Chr(13) + Chr(10) + "" // Local de Atendimento
							cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
							cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
							cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
							cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
							cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
							cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
							cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
							cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
							cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
							cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
							cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
							cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
							cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
							cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
							cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
						Else
							cMensagem  += STR0273 + oMdlTFF:GetValue('TFF_COD') +  Chr(13) + Chr(10) + "" // Recursos Humanos
							cMensagem  += STR0274 + oMdlTFF:GetValue('TFF_ITEM') +  Chr(13) + Chr(10) + "" // Item
							cMensagem  += STR0275 + oMdlTFF:GetValue('TFF_PRODUT') +  Chr(13) + Chr(10) + "" // Código do Produto
							cMensagem  += STR0249 + oMdlTFF:GetValue('TFF_DESCRI') +  Chr(13) + Chr(10) + "" //Produto
							cMensagem  += STR0276 + cValToChar(oMdlTFF:GetValue('TFF_QTDVEN')) +  Chr(13) + Chr(10) +  "" //Quantidade
							cMensagem  += STR0277 + dToC(oMdlTFF:GetValue('TFF_PERINI')) +  Chr(13) + Chr(10) + "" //Data Inicial
							cMensagem  += STR0278 + dToC(oMdlTFF:GetValue('TFF_PERFIM')) +  Chr(13) + Chr(10) +  "" // Data Final
							cMensagem  += STR0279 + oMdlTFF:GetValue('TFF_FUNCAO') +  Chr(13) + Chr(10) + "" // Código da Função
							cMensagem  += STR0280 + oMdlTFF:GetValue('TFF_DFUNC') +  Chr(13) + Chr(10) + "" // Função
							cMensagem  += STR0281 + oMdlTFF:GetValue('TFF_TURNO') +  Chr(13) + Chr(10) + "" //Código do Turno
							cMensagem  += STR0282 + oMdlTFF:GetValue('TFF_DTURNO') +  Chr(13) + Chr(10) + "" // Turno
							cMensagem  += STR0283 + oMdlTFF:GetValue('TFF_CARGO') +  Chr(13) + Chr(10) + "" // Código do Cargo
							cMensagem  += STR0284 + oMdlTFF:GetValue('TFF_DCARGO') +  Chr(13) + Chr(10) + "" // Cargo
							cMensagem  += STR0285 + oMdlTFF:GetValue('TFF_ESCALA') +  Chr(13) + Chr(10) + "" // Código da Escala
							cMensagem  += STR0286 + oMdlTFF:GetValue('TFF_NOMESC') +  Chr(13) + Chr(10) + "" // Escala
						EndIf
					EndIf
					cMensagem  += Chr(13) + Chr(10)
					cCodLoc := oMdlTFL:GetValue('TFL_CODIGO')
				EndIf
				If isInCallStack("At870GerOrc") .AND. oMdlTFF:isDeleted() .AND. oMdlTFF:GetValue("TFF_COBCTR") == "2"
					aArea := GetArea()
					DbSelectArea("ABQ")
					ABQ->(DbSetOrder(3))
					If ABQ->( dbSeek( xFilial("ABQ") + oMdlTFF:GetValue("TFF_COD") + xFilial("TFF") ) )
						RecLock( "ABQ", .F. )
						ABQ->( dbDelete() )
						ABQ->( MsUnlock() )
					EndIf
					RestArea(aArea)
				EndIf
				If lAtuCod
					//Atualização TFU: VLR EXTRA X MOTIVO MANUTENCAO
					For nI := 1 To oMdlTFU:Length()
						oMdlTFU:GoLine(nI)
						If !oMdlTFU:IsDeleted() .And. !Empty(oMdlTFU:GetValue('TFU_CODABN')) .And. !oMdlTFU:IsInserted()
							If isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi")
								If isInCallStack("AT870RvPlC")
									cNewCod := oMdlTFU:GetValue("TFU_CODIGO")
								Else
									cNewCod := CriaVar("TFU_CODIGO",.T.)
								EndIF
								If isInCallStack("AT870RvPlC")
									Aadd(aRecSubCod, {"TFU",oMdlTFU:GetValue("TFU_CODREL"),cNewCod})
								Else
									Aadd(aRecSubCod, {"TFU",oMdlTFU:GetValue("TFU_CODIGO"),cNewCod})
								EndIf
								oMdlTFU:LoadValue("TFU_CODIGO",cNewCod)
							Else
								oMdlTFU:LoadValue("TFU_CODIGO",CriaVar("TFU_CODIGO",.T.))
							EndIf
						EndIf
					Next nI
				EndIf
				If !lOrcPrc
					If lAtuCod
						If !oMdlTFF:IsDeleted() .And. !Empty(oMdlTFF:GetValue('TFF_PRODUT')) .And. !oMdlTFF:IsInserted()
							If isInCallStack("AT870RvPlC")
								cNewCod := oMdlTFF:GetValue("TFF_COD")
							Else
								cNewCod := CriaVar("TFF_COD",.T.)
							EndIf
							If isInCallStack("AT870RvPlC")
								Aadd(aRecSubCod, {"TFF",oMdlTFF:GetValue("TFF_CODREL"),cNewCod})
							Else
								Aadd(aRecSubCod, {"TFF",oMdlTFF:GetValue("TFF_COD"),cNewCod})
							EndIf
							oMdlTFF:LoadValue("TFF_COD",cNewCod)
							If isInCallStack("AT870PlaRe")
								oMdlTFF:LoadValue("TFF_CONTRT", "")
							EndIf
							If lRevi .AND. !(isInCallStatck("AT870PlaRe"))
								At740UpSLY(aRecSubCod[Len(aRecSubCod)][2]   ,aRecSubCod[Len(aRecSubCod)][3])
							EndIf
						EndIf
					EndIf
					//Atualização TFG: MATERIAIS DE IMPLANTAÇÃO
					For nX := 1 To oMdlTFG:Length()
						oMdlTFG:GoLine(nX)
						If !Empty(oMdlTFG:GetValue('TFG_PRODUT')) .AND. !(oMdlTFG:IsDeleted())
							oMdlTFG:LoadValue("TFG_LOCAL", oMdlTFL:GetValue("TFL_LOCAL"))
						EndIf
						If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
							If oMdlTFG:isDeleted() .OR. oMdlTFL:isDeleted() .OR. oMdlTFF:isDeleted()
								Tec740IExc(oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO'),;
										/*cTFL*/,;
										/*cTFF*/,;
										oMdlTFG:GetValue("TFG_COD"),;
										/*cTFH*/,;
										oModel:GetOperation())
							EndIf
						EndIf
						If IsInCallStack("At870GerOrc") .AND. oMdlTFG:GetValue("TFG_COBCTR") == "2" .AND.;
						 		!Empty(oMdlTFG:GetValue('TFG_PRODUT')) .AND. !(oMdlTFG:IsDeleted())
							If oMdlTFG:IsInserted()
								oMdlTFG:LoadValue('TFG_SLD', oMdlTFG:GetValue('TFG_QTDVEN') )
								oMdlTFG:LoadValue("TFG_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
								oMdlTFG:LoadValue("TFG_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
							Else
								At870revMt(oModel,"TFG",oMdlTFG:GetValue("TFG_COD"))
							EndIf
						Endif
						If lAtuCod
							If !oMdlTFG:IsDeleted() .And. !Empty(oMdlTFG:GetValue('TFG_PRODUT')) .And. !oMdlTFG:IsInserted()
								If lRevi
									At870revMt(oModel,"TFG",oMdlTFG:GetValue("TFG_COD"))
								EndIf
								If isInCallStack("AT870RvPlC")
									cNewCod := oMdlTFG:GetValue("TFG_COD")
								Else
									cNewCod := CriaVar("TFG_COD",.T.)
								EndIf
								If isInCallStack("AT870RvPlC")
									Aadd(aRecSubCod, {"TFG",oMdlTFG:GetValue("TFG_CODREL"),cNewCod})
								Else
									Aadd(aRecSubCod, {"TFG",oMdlTFG:GetValue("TFG_COD"),cNewCod})
								EndIf
								oMdlTFG:LoadValue("TFG_COD",cNewCod)
								If isInCallStack("AT870PlaRe")
									oMdlTFG:LoadValue("TFG_CONTRT", "")
								EndIf
							ElseIf !Empty(oMdlTFG:GetValue('TFG_PRODUT')) .And. oMdlTFG:IsInserted()
								oMdlTFG:LoadValue('TFG_SLD', oMdlTFG:GetValue('TFG_QTDVEN') )
							EndIf
						EndIf
					Next nX
					//Atualização TFH: MATERIAIS DE CONSUMO
					For nX := 1 To oMdlTFH:Length()
						oMdlTFH:GoLine(nX)
						If !Empty(oMdlTFH:GetValue('TFH_PRODUT')) .AND. !(oMdlTFH:IsDeleted())
							oMdlTFH:LoadValue("TFH_LOCAL", oMdlTFL:GetValue("TFL_LOCAL"))
						EndIf
						If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
							If oMdlTFH:isDeleted() .OR. oMdlTFL:isDeleted() .OR. oMdlTFF:isDeleted()
								Tec740IExc(oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO'),;
										/*cTFL*/,;
										/*cTFF*/,;
										/*cTFG*/,;
										oMdlTFH:GetValue("TFH_COD"),;
										oModel:GetOperation())
							EndIf
						EndIf
						If IsInCallStack("At870GerOrc") .AND. oMdlTFH:GetValue("TFH_COBCTR") == "2" .AND.;
						 		!Empty(oMdlTFH:GetValue('TFH_PRODUT')) .AND. !(oMdlTFH:IsDeleted())
							If oMdlTFH:IsInserted()
								oMdlTFH:LoadValue("TFH_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
								oMdlTFH:LoadValue("TFH_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
								oMdlTFH:LoadValue('TFH_SLD', oMdlTFH:GetValue('TFH_QTDVEN') )
							Else
								At870revMt(oModel,"TFH",oMdlTFH:GetValue("TFH_COD"))
							EndIf
						EndIf
						If lAtuCod
							If !oMdlTFH:IsDeleted() .And. !Empty(oMdlTFH:GetValue('TFH_PRODUT')) .And. !oMdlTFH:IsInserted()
								If lRevi
									At870revMt(oModel,"TFH",oMdlTFH:GetValue("TFH_COD"))
								EndIf
								If isInCallStack("AT870RvPlC")
									cNewCod := oMdlTFH:GetValue("TFH_COD")
								Else
									cNewCod := CriaVar("TFH_COD",.T.)
								EndIf
								If isInCallStack("AT870RvPlC")
									Aadd(aRecSubCod, {"TFH",oMdlTFH:GetValue("TFH_CODREL"),cNewCod})
								Else
									Aadd(aRecSubCod, {"TFH",oMdlTFH:GetValue("TFH_COD"),cNewCod})
								EndIf
								oMdlTFH:LoadValue("TFH_COD",cNewCod)
								If isInCallStack("AT870PlaRe")
									oMdlTFH:LoadValue("TFH_CONTRT", "")
								EndIf
							ElseIf !Empty(oMdlTFH:GetValue('TFH_PRODUT')) .And. oMdlTFH:IsInserted()
								oMdlTFH:LoadValue('TFH_SLD', oMdlTFH:GetValue('TFH_QTDVEN') )
							EndIf
						EndIf
					Next nX
					//Atualização TXQ: ARMAMENTOS
					If lGsOrcArma
						oMdlTXQ	:= oModel:GetModel('TXQDETAIL')
						For nX := 1 To oMdlTXQ:Length()
							oMdlTXQ:GoLine(nX)
							If lAtuCod
								If !oMdlTXQ:IsDeleted() .And. !Empty(oMdlTXQ:GetValue('TXQ_CODPRD')) .And. !oMdlTXQ:IsInserted()
									If isInCallStack("AT870RvPlC")
										//cNewCod := oMdlTXQ:GetValue("TXQ_CODIGO")
										//Aadd(aRecSubCod, {"TXQ",oMdlTXQ:GetValue("TXQ_CODREL"),cNewCod})
									Else
										cNewCod := CriaVar("TXQ_CODIGO",.T.)
										Aadd(aRecSubCod, {"TXQ",oMdlTXQ:GetValue("TXQ_CODIGO"),cNewCod})
									EndIf
									oMdlTXQ:LoadValue("TXQ_CODIGO",cNewCod)
								EndIf
							EndIf
						Next nX
					EndIf
					//Atualização TXP: UNIFORME
					If lGsOrcUnif
						oMdlTXP	:= oModel:GetModel('TXPDETAIL')
						For nX := 1 To oMdlTXP:Length()
							oMdlTXP:GoLine(nX)
							If lAtuCod
								If !oMdlTXP:IsDeleted() .And. !Empty(oMdlTXP:GetValue('TXP_CODIGO')) .And. !oMdlTXP:IsInserted()
									If isInCallStack("AT870RvPlC")
										//cNewCod := oMdlTXP:GetValue("TXP_CODIGO")
										//Aadd(aRecSubCod, {"TXP",oMdlTXP:GetValue("TXP_CODREL"),cNewCod})
									Else
										cNewCod := CriaVar("TXP_CODIGO",.T.)
										Aadd(aRecSubCod, {"TXP",oMdlTXP:GetValue("TXP_CODIGO"),cNewCod})
									EndIf
									oMdlTXP:LoadValue("TXP_CODIGO",cNewCod)
								EndIf
							EndIf
						Next nX
					EndIf
					If lAtuCod .And. !isInCallStack("AT870RvPlC")
						//Atualização TDS: Caracteristicas
						oMdlTDS	:= oModel:GetModel('TDS_RH')
						For nX := 1 To oMdlTDS:Length()
							oMdlTDS:GoLine(nX)
							If !oMdlTDS:IsDeleted() .And. !Empty(oMdlTDS:GetValue('TDS_CODTCZ')) .And. !oMdlTDS:IsInserted()
								cNewCod := CriaVar("TDS_COD",.T.)
								oMdlTDS:LoadValue("TDS_COD",cNewCod)
							EndIf
						Next nX
						//Atualização TDT: Habilidades
						oMdlTDT	:= oModel:GetModel('TDT_RH')
						For nX := 1 To oMdlTDT:Length()
							oMdlTDT:GoLine(nX)
							If !oMdlTDT:IsDeleted() .And. !Empty(oMdlTDT:GetValue('TDT_CODHAB')) .And. !oMdlTDT:IsInserted()
								cNewCod := CriaVar("TDT_COD",.T.)
								oMdlTDT:LoadValue("TDT_COD",cNewCod)
							EndIf
						Next nX
						//Atualização TGV: CURSOS
						oMdlTGV	:= oModel:GetModel('TGV_RH')
						For nX := 1 To oMdlTGV:Length()
							oMdlTGV:GoLine(nX)
							If !oMdlTGV:IsDeleted() .And. !Empty(oMdlTGV:GetValue('TGV_CURSO')) .And. !oMdlTGV:IsInserted()
								cNewCod := CriaVar("TGV_COD",.T.)
								oMdlTGV:LoadValue("TGV_COD",cNewCod)
							EndIf
						Next nX
					EndIF
				EndIf

				// pesquisa os produtos que não possuem registro criado na tabela SB2
				At740AvSb2(aCriaSb2, oModel)
				If oMdlTFF:GetValue("TFF_COBCTR") == "2" .And. ;
						IsInCallStack("At870GerOrc") // Verifica as operações dos itens extras do contrato
					If oMdlTFF:isInserted() .AND. !(isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
						oMdlTFF:LoadValue("TFF_CONTRT", oMdlTFL:GetValue("TFL_CONTRT"))
						oMdlTFF:LoadValue("TFF_CONREV", oMdlTFL:GetValue("TFL_CONREV"))
					EndIf
					lRecLock := At740VldTFF(	oMdlTFL:GetValue("TFL_CONTRT"),;
												oMdlTFF:GetValue("TFF_COD"),;
													xFilial("TFF", cFilAnt))
					If !(oMdlTFF:isDeleted())
						If !lRecLock  .and. !oMdlTFF:isInserted() .AND. oModel:GetModel('TFJ_REFER'):GetValue('TFJ_CNTREC') <> "1"
							aAreaTFF := TFF->(GetArea())
							TFF->(DbSetOrder(1))
							If TFF->(DbSeek(xFilial("TFF")+ oMdlTFF:GetValue("TFF_COD")))
								aTFFOrg := { 	TFF->TFF_FILIAL, ; //1
												TFF->TFF_COD,  ; //2
												TFF->TFF_CALEND,; //3
												TFF->TFF_TURNO,; //4
												TFF->TFF_ESCALA, ;//5
												IIF(Empty(TFF->TFF_SEQTRN), "01", TFF->TFF_SEQTRN), ;//6
												TFF->TFF_PERINI, ; //7
												TFF->TFF_PERFIM, ;//8
												TFF->TFF_QTDVEN,; //9
												TFF->TFF_CALEND ,; //10
												oMdlTFF:GetValue("TFF_CALEND") ,;//11
												oMdlTFF:GetValue("TFF_ESCALA")  }  //12
							EndIf
							RestArea(aAreaTFF)
						EndIf
						Aadd(aItemRH,{ oMdlTFF:GetValue("TFF_PRODUT"),; //1
										oMdlTFF:GetValue("TFF_CARGO")	,; //2
										oMdlTFF:GetValue("TFF_FUNCAO"),;//3
										oMdlTFF:GetValue("TFF_PERINI"),;//4
										oMdlTFF:GetValue("TFF_PERFIM"),;//5
										oMdlTFF:GetValue("TFF_TURNO")	,;//6
										oMdlTFF:GetValue("TFF_QTDVEN"),;//7
										oMdlTFF:GetValue("TFF_COD"),;//8
										oMdlTFF:GetValue("TFF_SEQTRN"),;//9
										lRecLock,;//10
										xFilial("TFF", cFilAnt),;//11
										aClone(aTFFOrg),; //12
										IIF(TecABBPRHR(), TecConvHr(oMdlTFF:GetValue("TFF_QTDHRS")), 0),;//13
										Iif( (TFF->( ColumnPos("TFF_RISCO")) > 0 ), oModel:GetModel("TFF_RH"):GetValue("TFF_RISCO"), "" ) } ) //14
						aTFFOrg := {}
					EndIf
				EndIf
			Next nRHs
			If Len(aItemRH) > 0 // Cria a configuração de alocação para os itens extras
				At850CnfAlc(	oMdlTFL:GetValue("TFL_CONTRT"),;
								oMdlTFL:GetValue("TFL_LOCAL"), aItemRH, , ,.F., oModel:GetModel('TFJ_REFER'):GetValue('TFJ_CNTREC') == "1"  )
				//Cria a integração para o MDT
				If lMdtGS .And. TFF->( ColumnPos("TFF_RISCO")) > 0
					At740TarEx(oModel:GetModel("TFL_LOC"):GetValue("TFL_LOCAL"),aItemRH)
				EndIf
			Endif
			aItemRH := {}
		Next nLocais
		FwRestRows( aRows )
		// Captura e repassa quando é atualização da vistoria
		aVistoria := N600GetVis()
		// não define a origem como vistoria quando está importando para a proposta comercial
		If aVistoria[1] .And. IsInCallStack("A600IMPVIS")
			aVistoria[1] := .F.
		EndIf
		If lFillPropVist
			SetDadosOrc( aVistoria[1], aVistoria[2], oModel )
		EndIf
		If isInCallStatck("AplicaRevi")
			ATTOrcPla( oModel, cContrato, cRevisa )
		EndIf
		cCodTfj := oModel:GetValue( 'TFJ_REFER', 'TFJ_CODIGO')
		If  TFJ->(ColumnPos('TFJ_APRVOP')) > 0 .And. TFJ->TFJ_APRVOP != "2"
			lAprovOp := .T.
		Endif
		//--------------------------------------------
		//ExecAuto geração de vagas Recrutamento e Seleção
		If lRet
			If lAprovOp .And. lTec855 .And. AT740VldRS()
				If oModel:GetModel('TFJ_REFER'):GetValue('TFJ_APRVOP') == '1'
					FwMsgRun(Nil,{|| lRet := ExecAutoRS(oModel)}, Nil, STR0342)//"Gerando solicitação de vagas..."
				EndIf
			EndIf
		EndIf
		//--------------------------------------------
		If lRet
			If ( lRet := FwFormCommit( oModel ) )
				If lAtucod
					At740UCdSb(aRecSubCod, cCodTfj)
				EndIf
				aEnceCpos := {}
			EndIf
		EndIf
		//--------------------------------------------
		//  Cria o saldo inicial dos produtos não encontrados na SB2
		For nMateriais := 1 To Len( aCriaSb2 )
			CriaSb2( aCriaSb2[nMateriais,1], aCriaSb2[nMateriais,2] )
		Next nMateriais
		//--------------------------------------------
		//  Chama a rotina para cancelamento das reservas
		If lRet .And. Len(aCancReserv) > 0
			At740FinRes( oModel, .T. )
		EndIf
		//---------------------------------------------
		//  Elimina as informações de controle do orçamento com precificação
		If lOrcPrc
			AT740FGXML(,,.T.)
			At600STabPrc( "", "" )
		EndIf
		If lRet .And. isInCallStatck("At870Revis") .And. !SuperGetMv("MV_ORCPRC",,.F.) .And.;
		 	SuperGetMv("MV_GSAPROV",,"2") == "1" .And. TFJ->(ColumnPos('TFJ_APRVOP')) > 0
			If lAprovOp
				DbSelectArea("TFJ")
				aAreaTFJ := TFJ->(GetArea())
				TFJ->(DbSetOrder(1))
				If TFJ->(DbSeek(xFilial("TFJ")+cCodTfj))
					RecLock('TFJ',.F.)
					If At740AltOp(oModel)
						TFJ->TFJ_APRVOP := "2"
					Else
						TFJ->TFJ_APRVOP := "1"
					Endif
					TFJ->(MsUnlock())
				Endif
				RestArea(aAreaTFJ)
			Endif
		Endif
	EndIf
Else
	cXmlDados := ( oModel:GetXmlData(Nil, Nil, Nil, Nil, Nil, .T. ))
EndIf
If ValType(nSaveSx8Len) <> 'U'
	While ( GetSx8Len() > nSaveSx8Len )
		ConfirmSX8()
	EndDo
EndIf
cXmlCalculo  := ''
If lOrcPrc
	at740ClSht()
EndIf

If lRet .AND. (isInCallStack("At190dGrOrc") .Or. lContExt)
	If FindFunction("at870DefMsg")
		at870DefMsg(cMensagem) // Usado no envio de WF de Item Extra Operacional
	EndIf
	EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,"",STR0269,cMensagem,.F.) //"Item Extra Operacional"
EndIf

Return lRet

/*/{Protheus.doc} At740AvSb2
	Verifica se os produtos indicados nos materiais possuem saldo indicado na tabela SB2
@sample 	At740AvSb2(aCriaSb2, oModel)
@since		20/10/2015
@version	P12
@param aCriaSB2, Array, variável que conterá a lista no formato { codigo produto, código local } que deverá ter o conteúdo gerado
@param oModelGeral, Objeto, modelo do tipo TECA740 ou TECA740F para avaliação dos produtos sem o registro de saldo na tabela SB2
/*/
Static Function At740AvSb2( aCriaSb2, oModelGeral )

Local nMateriais := 0
Local oMdlParte  := Nil

oMdlParte := oModelGeral:GetModel('TFG_MI')
For nMateriais := 1 To oMdlParte:Length()

	oMdlParte:GoLine( nMateriais )

	If !oMdlParte:IsDeleted() .And. ;
		aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFG_PRODUT') } ) == 0 .And. ;
		SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFG_PRODUT') ) ) .And. ;
		SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

		aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
	EndIf

Next nMateriais

oMdlParte := oModelGeral:GetModel('TFH_MC')
For nMateriais := 1 To oMdlParte:Length()
	oMdlParte:GoLine( nMateriais )

	If !oMdlParte:IsDeleted() .And. ;
		aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFH_PRODUT') } ) == 0 .And. ;
		SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFH_PRODUT') ) ) .And. ;
		SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )


		aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
	EndIf
Next nMateriais

oMdlParte := oModelGeral:GetModel('TFJ_REFER')
// produto referência de RH
If !Empty(oMdlParte:GetValue('TFJ_GRPRH')) .And. ;
	aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFJ_GRPRH') } ) == 0 .And. ;
	SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFJ_GRPRH') ) ) .And. ;
	SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

	aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
EndIf

// produto referência de MC
If !Empty(oMdlParte:GetValue('TFJ_GRPMC')) .And. ;
	aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFJ_GRPMC') } ) == 0 .And. ;
	SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFJ_GRPMC') ) ) .And. ;
	SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

	aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
EndIf

// produto referência de MI
If !Empty(oMdlParte:GetValue('TFJ_GRPMI')) .And. ;
	aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFJ_GRPMI') } ) == 0 .And. ;
	SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFJ_GRPMI') ) ) .And. ;
	SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

	aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
EndIf

// produto referência de LE
If !Empty(oMdlParte:GetValue('TFJ_GRPLE')) .And. ;
	aScan( aCriaSb2, {|pos| pos[1]==oMdlParte:GetValue('TFJ_GRPLE') } ) == 0 .And. ;
	SB1->( DbSeek( xFilial('SB1')+oMdlParte:GetValue('TFJ_GRPLE') ) ) .And. ;
	SB2->( !DbSeek( xFilial('SB2')+SB1->(B1_COD+B1_LOCPAD) ) )

	aAdd( aCriaSb2, { SB1->B1_COD, SB1->B1_LOCPAD } )
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Canc
	Bloco no momento de cancelamento dos dados da rotina
@sample 	At740Canc()
@since		03/10/2013
@version	P11.90
@return 	oModel, Object, Classo do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At740Canc( oMdl,b,c,d )

Local lOrcPrc	 := SuperGetMv("MV_ORCPRC",,.F.)

If ValType(nSaveSx8Len) <> 'U'
	While ( GetSx8Len() > nSaveSx8Len )
		RollBackSX8()
	EndDo
EndIf

cXmlCalculo  := ''

If Len(aCancReserv) > 0
	At740FinRes( oMdl, .F. )
EndIf
//  Só chama a limpeza das variáveis static do 740F quando não está copiando os dados
// para o objeto sem interface ligado ao modelo da proposta comercial
If lOrcPrc .And. !IsInCallStack('At600SeAtu')
	AT740FGXML(nil,nil,.T.)
EndIf

At740GSC(.F.)

If isInCallStack("a745IncOrc") .OR. (isInCallStack("At870Revis") .AND. oMdl:GetOperation() == MODEL_OPERATION_INSERT) .OR.;
		(oMdl:GetOperation() == MODEL_OPERATION_UPDATE .AND. isInCallStack("AplicaRevi"))
	If FindFunction("TecBHasCrn") .AND. TecBHasCrn()
		Tec740IExc(oMdl:GetValue("TFJ_REFER","TFJ_CODIGO"),;
		/*cTFL*/, /*cTFF*/, /*cTFG*/, /*cTFH*/, /*nOper*/)
	EndIf
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtIniPadMvc
	Função para inicializador padrão genérico de descrição ou conteúdos relacionados
a uma chave

@sample 	AtIniPadMvc( "TECA740", "TEV_ADICIO", cTab, nInd, cKey, cCampo, cFormula )
@sample 	AtIniPadMvc( "TECA740", "TEV_ADICIO", , , , , 'FWFLDGET("TEV_VLRUNI") * FWFLDGET("TEV_QTDE")' )

@since		23/09/2013
@version	P11.90

@return 	xConteudo, Qualquer, retorna o conteúdo conforme a pesquisa ou tipo do campo

@param  	cIdMdlMain, Objeto, id do objeto do modelo de dados principal
@param  	cIdMdlGrd, Objeto, id do objeto do modelo do grid
@param  	cCampo, Caracter, Conteúdo a ser retornado quando a pesquisa ocorrer com sucesso
				ou o campo alvo para recepção do valor (quando usado fórmula)
@param  	cTab, Caracter, nome da tabela para pesquisa
@param  	nInd, Numerico, índice para ordem na busca do registro
@param  	cKey, Caracter, chave de pesquisa do registro
@param  	cFormula, Caracter, conteúdo para ser macro executado
/*/
//------------------------------------------------------------------------------
Function AtIniPadMvc( cIdMdlMain, cIdMdlGrd, cCampo, cTab, nInd, cKey, cFormula, cTipoDefault )

Local xConteudo := Nil
Local cTipo     := ""
Local cCodAux 	:= ""
Local cMdlAtivo := ""
Local oMdlAtivo := FwModelActive()
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lOrcServ	:= cIdMdlMain $ "TECA740|TECA740F"
Local lFacilit 	:= cIdMdlMain == "TECA984"
Local lExecuta 	:= .F.
Local lContinua	:= .T.

cTipo := If( cCampo<>Nil, GetSx3Cache( PadR( cCampo, 10 ), 'X3_TIPO' ), If( cTipoDefault<>Nil, cTipoDefault, Nil ) )

If !Empty(cTipo)
	If cTipo $ 'C#M'
		xConteudo := ''
	ElseIf cTipo == 'N'
		xConteudo := 0
	ElseIf cTipo == 'D'
		xConteudo := CtoD('')
	ElseIf cTipo == 'L'
		xConteudo := .F.
	EndIf
Else
	xConteudo := ''
EndIf

If !lOrcPrc
	If (!isInCallStack("AtLoadTFH") .AND. cIdMdlGrd == 'TFH_MC') .OR. (!isInCallStack("AtLoadTFG") .AND. cIdMdlGrd == 'TFG_MI')
		lContinua := .F.
	EndIf
EndIf

cIdMdlMain := oMdlAtivo:GetId()

// Encerramento de Postos
If cIdMdlMain == "TECA871"
	lOrcServ := .F.
	If cIdMdlGrd == "TFL_LOCAL"
		cIdMdlGrd := "TFLDETAIL"
	ElseIf cIdMdlGrd == "TFF_RH"
		cIdMdlGrd := "TFFDETAIL"
	EndIf
EndIf

If lContinua .AND. oMdlAtivo <> Nil .And. ;
	( cIdMdlMain == cIdMdlMain .Or. ( lOrcPrc .And. cIdMdlMain == "TECA740F" ) ) .And. ;
	(oMdlAtivo:GetModel( cIdMdlGrd ) <> Nil .And. (oMdlAtivo:GetModel( cIdMdlGrd ):GetOperation() <> MODEL_OPERATION_INSERT) )

	If oMdlAtivo:GetModel( cIdMdlGrd ):GetLine() == 0 // a linha posicionada do grid
		If lOrcServ
			If (Left( cIdMdlGrd, 3 ) == "TFL" .Or. !oMdlAtivo:GetModel( "TFL_LOC" ):IsInserted())
				If Left( cIdMdlGrd, 3 ) <> "TFL"
					cCodAux := oMdlAtivo:GetModel("TFL_LOC"):GetValue("TFL_CODIGO")
				Else
					cCodAux := ""
				EndIf
				lExecuta := At740IsOrc( cIdMdlGrd, TFJ->TFJ_CODIGO, cCodAux, oMdlAtivo )
			EndIf
		ElseIf lFacilit
			cCodAux := If( lOrcPrc, "", TWN->TWN_ITEMRH )
			lExecuta := At984IsFac(cIdMdlGrd, TWM->TWM_CODIGO, cCodAux)
		Else
			lExecuta := .T.
		EndIf

		If lExecuta
			If !Empty( cFormula )
				If !( 'FWFLDGET' $ Upper( cFormula ) )  // verifica se tem get de conteúdo da linha do model
					xConteudo := &cFormula
				EndIf
			Else
				cKey := &cKey
				xConteudo := GetAdvFVal( cTab, cCampo, cKey, nInd, xConteudo )
			EndIf
		EndIf
	ElseIf !(oMdlAtivo:GetModel( cIdMdlGrd ):IsInserted())
		If !Empty( cFormula )
			xConteudo := &cFormula
		EndIf
	EndIf
EndIf

Return xConteudo

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TrgGer
	Função para preencher o conteúdo de grids superiores com a somatória

@sample 	At740TrgGer( "CALC_TFH", "TOT_MC", "TFF_RH", "TFF_TOTMC" )

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740TrgGer( cMdlCalc, cCpoTot, cMdlCDom, cCpoCDOM, cCpoDesc )

Local nValor  := 0
Local nVlMat  := 0
Local lVlrCon := TFF->(ColumnPos('TFF_VLRCON')) > 0
Local oMdl    := FwModelActive()

Default cCpoDesc := ''

If oMdl:GetId() == 'TECA740' .Or. oMdl:GetId() == 'TECA740F'

	nValor := oMdl:GetModel(cMdlCalc):GetValue(cCpoTot)

	If !Empty( cCpoDesc )
		nValor := ( nValor * ( 1 - ( oMdl:GetModel( cMdlCDom ):GetValue( cCpoDesc ) / 100 ) ) )
	EndIf

	If lVlrCon
		If cMdlCalc == "CALC_TFG"
			nVlMat := oMdl:GetModel( "TFF_RH" ):GetValue("TFF_VLRMAT")
			nValor += nVlMat
		ElseIf cMdlCalc == "CALC_TFH"
			nVlMat := oMdl:GetModel( "TFF_RH" ):GetValue("TFF_VLRCON")
			nValor += nVlMat
		ElseIf cMdlCalc == "CALC_TFF"
			If cCpoCDOM == "TFL_TOTMI"
				nValor := A740CalcTFF(oMdl, "TFF_TOTMI")
			ElseIf cCpoCDOM == "TFL_TOTMC"
				nValor := A740CalcTFF(oMdl, "TFF_TOTMC")
			EndIf
		ElseIf cMdlCalc == "CALC_TXP"
			If cCpoCDOM == "TFF_TOTUNI"
				nValor := A740CalcTXP( oMdl )
			EndIf
		EndIf
	EndIf

	oMdl:GetModel(cMdlCDom):SetValue(cCpoCDOM, nValor)

EndIf

Return 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} A740CalcTFF
	Totaliza o valor de um campo da grid de Recursos Humanos (TFF) para o local
	de atendimento posicionado (TFJ).
	@type Function
	@version 12.1.2210
	@author Guilherme Bigois
	@since 25/08/2023
	@param oMdl, Object, Modelo de dados MVC completo
	@param cField, Character, Campo da TFF que será totalizado
	@return Numeric, Valor total das linhas da TFF para o campo informado
	@example nValue := A740CalcTFF(oMdl, "TFF_TOTMI")
/*/
//------------------------------------------------------------------------------
Function A740CalcTFF(oMdl As Object, cField As Character) As Numeric
	Local nTotTFF As Numeric // Valor totalizado para a coluna informada
	Local nLinTFF As Numeric // Contador de linhas da grid de Recursos Humanos (TFF)
	Local oMdlTFF As Object  // Submodelo TFF_RH (Recursos Humanos)

	// Inicialização de variáveis
	nTotTFF := 0
	nLinTFF := 0
	oMdlTFF := oMdl:GetModel("TFF_RH")

	// Percorre cada linha da grid de Recursos Humanos
	For nLinTFF := 1 To oMdlTFF:Length()
		// Apenas incrementa o valor total se a linha não estiver deletada
		If (!oMdlTFF:IsDeleted(nLinTFF))
			nTotTFF += oMdlTFF:GetValue(cField, nLinTFF)
		EndIf
	Next nLinTFF

Return (nTotTFF)

//------------------------------------------------------------------------------
/*/{Protheus.doc} A740CalcTXP
	Totaliza o valor de um campo da grid de Recursos Humanos (TFF) para o local
	de atendimento posicionado (TFJ).
	@type Function
	@version 12.1.2210
	@author Guilherme Bigois
	@since 25/08/2023
	@param oMdl, Object, Modelo de dados MVC completo
	@param cField, Character, Campo da TFF que será totalizado
	@return Numeric, Valor total das linhas da TFF para o campo informado
	@example nValue := A740CalcTXP(oMdl, "TFF_TOTMI")
/*/
//------------------------------------------------------------------------------
Function A740CalcTXP( oMdl As Object ) As Numeric
	Local nTotTXP As Numeric // Valor totalizado para a coluna informada
	Local nLinTXP As Numeric // Contador de linhas da grid de Uniformes (TXP)
	Local oMdlTFF As Object  // Submodelo TFF_RH (Recursos Humanos)
	Local oMdlTXP As Object  // Submodelo TXPDETAIL (Uniformes)

	// Inicialização de variáveis
	nTotTXP := 0
	nLinTXP := 0
	oMdlTFF := oMdl:GetModel("TFF_RH")
	oMdlTXP := oMdl:GetModel("TXPDETAIL")

	// Percorre cada linha da grid de Uniformes
	For nLinTXP := 1 To oMdlTXP:Length()
		// Apenas incrementa o valor total se a linha não estiver deletada
		If !oMdlTXP:IsDeleted( nLinTXP )
			nTotTXP += oMdlTXP:GetValue("TXP_TOTGER", nLinTXP)
		EndIf
	Next nLinTXP

Return nTotTXP

//------------------------------------------------------------------------------
/*/{Protheus.doc} A740TFJCus
	Retorna os totais geral e de custo do orçamento referente a todos os locais.
	@type Function
	@author Anderson F. Gomes
	@since 07/12/2023
	@param oMdl, Object, Modelo de dados MVC completo
	@return Array, Array com 2 posições aRat[1] = Total Geral / aRet[2] = Total de Custo
	@example aRet := A740TFJCus( oMdl)
/*/ 
//------------------------------------------------------------------------------
Function A740TFJCus(oMdl As Object) As Array

	Local nTotGeral  As Numeric
	Local nTotCusto  As Numeric
	Local nLinTFL    As Numeric
	Local nLinTFF    As Numeric
	Local nLinTFG    As Numeric
	Local nLinTFH    As Numeric
	Local nLinTFLBkp As Numeric
	Local nLinTFFBkp As Numeric
	Local oMdlTFL    As Object
	Local oMdlTFF    As Object
	Local oMdlTFG    As Object
	Local oMdlTFH    As Object
	Local oView      As Object
	Local aSaveRows  As Array

	Default oMdl := FwModelActive()

	nTotGeral := 0
	nTotCusto := 0
	oMdlTFL   := oMdl:GetModel("TFL_LOC")
	oMdlTFF   := oMdl:GetModel("TFF_RH" )
	oMdlTFG   := oMdl:GetModel("TFG_MI" )
	oMdlTFH   := oMdl:GetModel("TFH_MC" )

	nLinTFLBkp := oMdlTFL:GetLine()
	nLinTFFBkp := oMdlTFF:GetLine()
	
	If nLinTFLBkp > 0
		aSaveRows := FwSaveRows()
		//Percorre os Locais de atendimento (TFL):
		For nLinTFL := 1 To oMdlTFL:Length()
			If !oMdlTFL:IsDeleted()
				//Percorre os Postos/Serviços (TFF):
				For nLinTFF := 1 To oMdlTFF:Length()
					If !oMdlTFF:IsDeleted()
						If oMdlTFF:GetValue("TFF_COBCTR",nLinTFF) <> "2" .And. ( oMdlTFF:GetValue("TFF_ENCE",nLinTFF) <> "1" .Or. ( oMdlTFF:GetValue("TFF_ENCE",nLinTFF) == "1" .And. oMdlTFF:GetValue("TFF_DTENCE",nLinTFF) > dDataBase ) )
							If !Empty( oMdlTFF:GetValue("TFF_PERFIM",nLinTFF) ) .And. dDataBase <= oMdlTFF:GetValue("TFF_PERFIM",nLinTFF)
								//Somatória de Total COM Planilha de Preços:
								If !Empty( oMdlTFF:GetValue("TFF_PLACOD",nLinTFF))
									nTotGeral += oMdlTFF:GetValue("TFF_QTDVEN",nLinTFF) * oMdlTFF:GetValue("TFF_TOTPLA",nLinTFF)
									nTotCusto += oMdlTFF:GetValue("TFF_SUBTOT",nLinTFF)
								Else
									//Somatória de Total SEM Planilha de Preços:
									nTotGeral += oMdlTFF:GetValue("TFF_SUBTOT",nLinTFF) + ;
												oMdlTFF:GetValue("TFF_TOTMI",nLinTFF) + ;
												oMdlTFF:GetValue("TFF_TOTMC",nLinTFF) + ;
												oMdlTFF:GetValue("TFF_TOTUNI",nLinTFF) + ;
												oMdlTFF:GetValue("TFF_TOTARM",nLinTFF)
									nTotCusto += oMdlTFF:GetValue("TFF_QTDVEN",nLinTFF) * oMdlTFF:GetValue("TFF_PRCVEN",nLinTFF) + ;
													oMdlTFF:GetValue("TFF_TOTUNI",nLinTFF) + ;
													oMdlTFF:GetValue("TFF_TOTARM",nLinTFF) 
									For nLinTFG := 1 To oMdlTFG:Length()
										If !oMdlTFG:IsDeleted(nLinTFG) .And. !Empty(oMdlTFG:GetValue("TFG_PERFIM",nLinTFG)) .And. dDataBase <= oMdlTFG:GetValue("TFG_PERFIM",nLinTFG)
											nTotCusto += oMdlTFG:GetValue("TFG_TOTAL", nLinTFG)
										Else
											nTotGeral -= oMdlTFG:GetValue("TFG_TOTAL", nLinTFG)
										EndIf
									Next nLinTFG
									For nLinTFH := 1 To oMdlTFH:Length()
										If !oMdlTFH:IsDeleted(nLinTFH) .And. !Empty(oMdlTFH:GetValue("TFH_PERFIM",nLinTFH) ) .And. dDataBase <= oMdlTFH:GetValue("TFH_PERFIM",nLinTFH)
											nTotCusto += oMdlTFH:GetValue("TFH_TOTAL", nLinTFH)
										Else
											nTotGeral -= oMdlTFH:GetValue("TFH_TOTAL", nLinTFH)
										EndIf
									Next nLinTFH
								EndIf
							EndIf
						EndIf
					EndIf
				Next nLinTFF
			EndIf
		Next nLinTFL

		oMdl:GetModel("TFJ_TOT"):LoadValue("TFJ_TOTGER", nTotGeral)
		oMdl:GetModel("TFJ_TOT"):LoadValue("TFJ_TOTCUS", nTotCusto)

		FWRestRows(aSaveRows)

		If !IsBlind()
			oView := FwViewActive()
			If ValType( oView ) == "O" .And. AScan( oView:AVIEWS, {|x| x[1] == "VIEW_CUSTO" } ) > 0
				oView:GetSubView("VIEW_CUSTO"):Refresh()
			EndIf
		Endif
	EndIf

Return {nTotGeral, nTotCusto}

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TrgABN


@sample 	At740TrgABN()

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740TrgABN(cCodAbn)

Local cRetABN	 := ""
Local oMdl   	 := FwModelActive()
Local aAreaABN := ABN->(GetArea())
Default cCodAbn  := ""

If EMPTY( cCodAbn )
	If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

		cCodAbn := oMdl:GetModel( "TFU_HE" ):GetValue( "TFU_CODABN" )

		ABN->(dbSetOrder(1))
		If ABN->(dbSeek(xFilial("ABN")+cCodAbn))
			cRetABN := ABN->ABN_DESC
		EndIf

	EndIf
Else
	ABN->(dbSetOrder(1))
	If ABN->(dbSeek(xFilial("ABN")+cCodAbn))
		cRetABN := ABN->ABN_DESC
	EndIf
EndIf

RestArea(aAreaABN)

Return(cRetABN)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TrgTEV
	Dispara o preenchimento do campo de unidade de medida
@sample 	At740TrgTEV()

@since		23/09/2013
@version	P11.90

@param   	cCpoOrigem, Caracter, Id do campo que disparou o gatilho
@return  	xRet, Qualquer, conteúdo a ser inserido no contra-domínio
/*/
//------------------------------------------------------------------------------
Function At740TrgTEV( cCpoOrigem )

Local xRet := Nil

If cCpoOrigem == 'TEV_MODCOB'

	If M->TEV_MODCOB == '2'  // Modo de Cobrança igual a disponibilidade
		xRet := 'UN'
	ElseIf M->TEV_MODCOB == '4' .Or. M->TEV_MODCOB == '5'  // Modo de Cobrança igual a horimetro
		xRet := 'HR'
	Else
		xRet := '  '
	EndIf

EndIf

Return xRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740DeBenefi
	Função executada no gatilho do código do benefício para captura da descrição

@sample 	At740DeBenefi()

@since		27/11/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At740DeBenefi()

Local cRet := ' '

DbSelectArea('SX5')
SX5->( DbSetOrder( 1 ) )

If SX5->( DbSeek( xFilial("SX5")+"AZ"+M->ABP_BENEFI) )
	cRet := X5Descri()
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@sample 	InitDados(  )

@since		23/09/2013
@version	P11.90

@param  	oMdlGer, Objeto, objeto geral do model que será alterado

/*/
//------------------------------------------------------------------------------
Static Function InitDados(oMdlGer)

Local aSaveRows  := {}
Local cGsDsGcn   := ""
Local lGSLE      := GSGetIns("LE")
Local lGSMIMC    := GSGetIns("MI")
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGSRH      := GSGetIns("RH")
Local lVersion23 := HasOrcSimp()
Local lOrcSim    := SuperGetMv("MV_ORCSIMP",,'2') == '1' .AND. lVersion23
Local lTeca270   := IsInCallStack("TECA270")
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local oMdlHrExtr := oMdlGer:GetModel("TFU_HE")
Local oMdlLe     := oMdlGer:GetModel("TFI_LE")
Local oMdlLoc    := oMdlGer:GetModel("TFL_LOC")
Local oMdlMc     := oMdlGer:GetModel("TFH_MC")
Local oMdlMi     := oMdlGer:GetModel("TFG_MI")
Local oMdlRh     := oMdlGer:GetModel("TFF_RH")
Local oStrTFF    := oMdlRh:GetStruct()
Local oStrTFG    := oMdlMi:GetStruct()
Local oStrTFH    := oMdlMc:GetStruct()
Local oStrTFI    := oMdlLE:GetStruct()
Local oStrTFJ    := oMdlGer:GetModel('TFJ_REFER'):GetStruct()

aBenefTFF := {}

oMdlMc:SetMaxLine(9999)
oMdlMi:SetMaxLine(9999)

If ExistBlock('AT740INITD')
	ExecBlock('AT740INITD', .F., .F., {oMdlGer} )
EndIf

If oMdlGer:GetOperation() == MODEL_OPERATION_INSERT .And. !IsInCallStack("TECA870")
	cGsDsGcn	:= SuperGetMv("MV_GSDSGCN",,"2")
Else
	cGsDsGcn	:= TFJ->TFJ_DSGCN
EndIf

If lVersion23
	If !IsInCallStack("At270Orc")
		IF lTeca270 .AND. lOrcSim

			oMdlGer:GetModel("TFJ_REFER"):LoadValue("TFJ_CODVIS",M->AAT_CODVIS)

		EndIf
	EndIf
EndIf

oStrTFH:SetProperty('TFH_TES',MODEL_FIELD_OBRIGAT, .F. )
oStrTFG:SetProperty('TFG_TES',MODEL_FIELD_OBRIGAT, .F. )

If cGsDsGcn == "1"
	//Retira a obrigatoriedade dos campos
	oStrTFJ:SetProperty('TFJ_GRPRH',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_GRPMI',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_GRPMC',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_GRPLE',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_TES', MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_TESMI',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_TESMC',MODEL_FIELD_OBRIGAT,.F.)
	oStrTFJ:SetProperty('TFJ_TESLE',MODEL_FIELD_OBRIGAT,.F.)
	//Novos campos de TES obrigatórios

	oStrTFF:SetProperty('TFF_TESPED',MODEL_FIELD_OBRIGAT,.T.)
	oStrTFG:SetProperty('TFG_TESPED',MODEL_FIELD_OBRIGAT,.T.)
	oStrTFH:SetProperty('TFH_TESPED',MODEL_FIELD_OBRIGAT,.T.)
	oStrTFI:SetProperty('TFI_TESPED',MODEL_FIELD_OBRIGAT,.T.)
Else
	//Retira a obrigatoriedade dos campos caso o contexto não seja utilizado
	//RH
	If !lGSRH
		oStrTFJ:SetProperty('TFJ_GRPRH',MODEL_FIELD_OBRIGAT,.F.)
		oStrTFJ:SetProperty('TFJ_TES',MODEL_FIELD_OBRIGAT,.F.)
	EndIf

	//MI
	If !lGSRH .Or. !lGSMIMC
			oStrTFJ:SetProperty('TFJ_GRPMI',MODEL_FIELD_OBRIGAT,.F.)
			oStrTFJ:SetProperty('TFJ_GRPMC',MODEL_FIELD_OBRIGAT,.F.)
			oStrTFJ:SetProperty('TFJ_TESMI',MODEL_FIELD_OBRIGAT,.F.)
			oStrTFJ:SetProperty('TFJ_TESMC',MODEL_FIELD_OBRIGAT,.F.)
	EndIf

	//LE
	If !lGSLE
		oStrTFJ:SetProperty('TFJ_GRPLE',MODEL_FIELD_OBRIGAT,.F.)
		oStrTFJ:SetProperty('TFJ_TESLE',MODEL_FIELD_OBRIGAT,.F.)
	EndIf
EndIf

aSaveRows := FwSaveRows()

If !lGsPrecific
	nTLuc := oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_LUCRO")
	nTAdm := oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_ADM")
Endif
//Muda  valor do TFJ_GESMAT
If oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT") == "3"
	At740Set(oMdlGer:GetModel("TFJ_REFER"), "TFJ_GESMAT", "2")
EndIf
If oMdlGer:GetOperation() <> MODEL_OPERATION_DELETE
	If  oMdlGer:GetModel('TOTAIS') <> NIL
		At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTRH', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_RH'))
		At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTMI', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_MI'))
		At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTMC', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_MC'))
		At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTLE', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_LE'))
		If lGsOrcUnif
			At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTUNI', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_TXP'))
		Endif
		If lGsOrcArma
			At740Set(oMdlGer:GetModel("TFJ_REFER"), 'TFJ_TOTARM', oMdlGer:GetModel('TOTAIS'):GetValue('TOT_TXQ'))
		Endif
	EndIf
EndIf

If VALTYPE(oMdlHrExtr) == 'O' .AND. oMdlHrExtr:GetOperation() <> MODEL_OPERATION_DELETE
	At740HrEtr(oMdlHrExtr)
EndIf

FwRestRows( aSaveRows )

If IsInCallStack("At870GerOrc") // Verifica as operações dos itens extras do contrato
	oMdlGer:GetModel("TFL_LOC"):SetNoInsertLine(.T.)
	oMdlGer:GetModel("TFL_LOC"):SetNoDeleteLine(.T.)
	oMdlGer:GetModel("TFL_LOC"):SetNoUpdateLine(.T.)
EndIf

If oMdlGer:GetOperation() <> MODEL_OPERATION_INSERT
	oMdlGer:GetModel('TFL_LOC'):GoLine( 1 )
EndIf

If oMdlGer:GetOperation() == MODEL_OPERATION_VIEW
	oMdlGer:lModify := .F.
EndIf

If IsInCallStack("At870Revis") .OR. IsInCallStack("AT870PlaRe")
	a740ChgLine()
	If IsInCallStack("At870Revis") .And. !IsInCallStack("At870EFTRV") .And. oMdlGer:GetOperation() == MODEL_OPERATION_INSERT
		a740AjDtEnc(oMdlLoc,oMdlRh)
	EndIf
EndIf

If IsInCallStack("AT870PlaRe") .AND. oMdlGer:GetOperation() == MODEL_OPERATION_INSERT
	For nZ := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine(nZ)
		oMdlLoc:LoadValue("TFL_MODPLA","2")
		For nY := 1 To oMdlRh:Length()
			oMdlRh:GoLine(nY)
			oMdlRh:LoadValue("TFF_MODPLA","2")

			If !EMPTY(oMdlMi:GetValue("TFG_PRODUT"))
				For nX := 1 To oMdlMi:Length()
					oMdlMi:GoLine(nX)
					oMdlMi:LoadValue("TFG_MODPLA","2")
				Next nX
				oMdlMi:GoLine(1)
			EndIf

			If !EMPTY(oMdlMc:GetValue("TFH_PRODUT"))
				For nX := 1 To oMdlMc:Length()
					oMdlMc:GoLine(nX)
					oMdlMc:LoadValue("TFH_MODPLA","2")
				Next nX
				oMdlMc:GoLine(1)
			EndIf

			If !EMPTY(oMdlHrExtr:GetValue("TFU_CODABN"))
				For nX := 1 To oMdlHrExtr:Length()
					oMdlHrExtr:GoLine(nX)
					oMdlHrExtr:LoadValue("TFU_MODPLA","2")
				Next nX
				oMdlHrExtr:GoLine(1)
			EndIf
		Next nY
		oMdlRh:GoLine(1)
	Next nZ
	oMdlLoc:GoLine(1)
EndIf

If (IsInCallStack("At870Revis") .AND. oMdlGer:GetOperation() == MODEL_OPERATION_INSERT) .OR.;
	(IsInCallStack("At870ExcR") .AND. oMdlGer:GetOperation() == MODEL_OPERATION_DELETE)
	For nZ := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine(nZ)
		For nY := 1 To oMdlRh:Length()
			//Verifica a existencia de Beneficios SLY salvos e popula array statico aBenefTFF:
			saveTFFSLY(oMdlRh:GetValue("TFF_COD",nY))
		Next nY
	Next nZ
	oMdlLoc:GoLine(1)
EndIf

If oMdlGer:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdlGer:GetOperation() == MODEL_OPERATION_UPDATE
	If SuperGetMv("MV_GSAPROV",,"2") == "1" .And. !SuperGetMv("MV_ORCPRC",,.F.) .And. TFJ->(ColumnPos('TFJ_APRVOP')) > 0 .And.;
		(Empty(oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_APRVOP")) .Or. oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_APRVOP") == "1")
		oMdlGer:GetModel("TFJ_REFER"):LoadValue("TFJ_APRVOP","2")
		If TFJ->(ColumnPos('TFJ_USAPRO')) > 0 .And. TFJ->(ColumnPos('TFJ_DTAPRO')) > 0
			oMdlGer:LoadValue( 'TFJ_REFER', 'TFJ_USAPRO', "")
			oMdlGer:LoadValue( 'TFJ_REFER', 'TFJ_DTAPRO', sTod(""))
		Endif
	Endif
Endif
If lVersion23
	At740StSm(oMdlGer:GetModel("TFJ_REFER"))
EndIf

lCalcEnc := .F.

For nX := 1 To oMdlLoc:Length()
	oMdlLoc:GoLine(nX)
	For nY := 1 To oMdlRh:Length()
		oMdlRh:GoLine(nY)
		TEC740Legen( oMdlRh:GetValue( "TFF_PLACOD" ), Nil )
	Next nY
	oMdlRh:GoLine(1)
Next nX
oMdlLoc:GoLine(1)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Set


@sample 	At740Set( oModel, cField, xValue)

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740Set(oModel, cField, xValue, lAlwaysLoad)

Local lRet := .T.
Default lAlwaysLoad := .F.

If oModel:GetOperation() == MODEL_OPERATION_VIEW .Or. ;
		oModel:GetOperation() == MODEL_OPERATION_DELETE .Or.;
			lAlwaysLoad
	oModel:LoadValue( cField, xValue )
Else
	lRet := oModel:SetValue( cField, xValue )
EndIf
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At600IniTot


@sample 	AT600INITOT( "TFH_MC", "TFH_TOTAL" )

@since		23/09/2013
@version	P11.90

@param cMdlAlvo, Caractere, Id do modelo de dados grid com o campo para soma do conteúdo
@param cCpoSoma, Caractere, Campo alvo para somar o conteúdo
@param oMdlGer, Objeto, objeto do mvc para considerar para realizar a soma do conteúdo, default: FwModelActive()
@return nValor, Numérico, valor correspondente a soma dos valores no campo nas linhas
/*/
//------------------------------------------------------------------------------
Function At600IniTot( cMdlAlvo, cCpoSoma, oMdlGer, lVerCobCTR )

Local nValor    := 0
Local oMdlGrid  := Nil
Local nLinhaMdl := 0
Local aSaveRows := {}
Local lSoma
Default oMdlGer := FwModelActive()
Default lVerCobCTR := .T.
If oMdlGer <> Nil .And. (oMdlGer:GetId()=='TECA740' .Or. oMdlGer:GetId()=='TECA740F')

	aSaveRows := FwSaveRows()

	oMdlGrid := oMdlGer:GetModel(cMdlAlvo)
	If !oMdlGrid:IsEmpty()
		// ----------------------------------------------------
		//   Varre as linhas do grid para capturar o conteúdo dos campos
		For nLinhaMdl := 1 To oMdlGrid:Length()

			oMdlGrid:GoLine( nLinhaMdl )

			If !oMdlGrid:IsDeleted()
				lSoma := .T.

				If cMdlAlvo $ "TFG_MI|TFH_MC|TFF_RH"
					If oMdlGrid:GetValue( LEFT(cMdlAlvo,4)+"COBCTR" ) == '2' .AND. lVerCobCTR
						lSoma := .F.
					EndIf
				EndIf

				If lSoma
					nValor += oMdlGrid:GetValue(cCpoSoma)
				EndIf
			EndIf

		Next nLinhaMdl
	EndIf
	FwRestRows( aSaveRows )

EndIf

Return nValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740CpyMdl
	Realiza a cópia dos dados de um modelo para outro
evitando sobrepor conteudo de alguns campos, informados na exceção

@sample 	At740CpyMdl

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740CpyMdl( oObjFrom, oObjTo )

Local lRet      := .T.
Local lOrcPrecif := SuperGetMv("MV_ORCPRC",,.F.)
Local oStrTFJ := oObjTo:GetModel('TFJ_REFER'):GetStruct()
Local oStrTFF := oObjTo:GetModel('TFF_RH'):GetStruct()
Local oStrTFG := oObjTo:GetModel('TFG_MI'):GetStruct()
Local oStrTFH := oObjTo:GetModel('TFH_MC'):GetStruct()
Local oStrTFI := oObjTo:GetModel('TFI_LE'):GetStruct()
Local oStrTXP := oObjTo:GetModel('TXPDETAIL'):GetStruct()
Local oStrTXQ := oObjTo:GetModel('TXQDETAIL'):GetStruct()

FillModel( @lRet, 'TFJ_REFER', oObjFrom, @oObjTo, lOrcPrecif )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FillModel
	Função para preenchimento dos dados do modelo indicado pelos parâmetros e
identifica a necessidade de preenchimento de grid/modelos filhos

@sample 	FillModel

@since		23/09/2013
@version	P11.90

@param 		lRet, Logico, indice/define o status do processamento pela rotina (referência)
@param 		cIdMdl, Caracter, id do model a ser preenchido
@param 		oFrom, Objeto, Modelo de dados para cópia das informações
@param 		oTo, Objeto, Modelo de dados para inclusão das informações

/*/
//------------------------------------------------------------------------------
Static Function FillModel( lRet, cIdModl, oFrom, oTo, lOrcPrecif )

                      // ID_MODEL     CAMPO_CHAVE, LISTA_SUBMODELS
Local aElementos := { }
Local aNoCpos  := {'TFJ_CODIGO', 'TFJ_PREVIS', 'TFL_CODIGO', 'TFL_CODPAI', 'TFF_CODPAI', 'TFF_LOCAL', 'TFF_PROCES', 'TFG_COD', 'TFG_CODPAI', 'TFG_LOCAL', ;
						'TFH_COD', 'TFH_CODPAI', 'TFH_LOCAL','TFI_COD', 'TFI_CODPAI', 'TFI_LOCAL','ABP_ITRH', 'TEV_CODLOC', 'TFU_CODIGO', 'TFU_CODTFF',;
						'TFU_LOCAL','TGV_COD','TDT_COD','TDS_COD','TWO_CODORC','TWO_PROPOS','TWO_LOCAL', 'TXP_CODIGO', 'TXP_CODTFF', 'TXQ_CODIGO', 'TXQ_CODTFF' }
Local nPosElem := 0
Local nPosSub  := 0
Local oFromAux := 0
Local oToAux   := 0
Local nForTo   := 0
Local nSubMdls  := 0
Local aLocaisMdls := {}
Local aRhMdls 	:= {}

Default lOrcPrecif := .F.

// quando for o orçamento com precificação
// ajusta a estrutura hierárquica dos modelos deixando os materiais abaixo do local
If lOrcPrecif
	aLocaisMdls := { 'TFF_RH', 'TFG_MI', 'TFH_MC', 'TFI_LE', 'TWODETAIL' }
	aRhMdls := { 'ABP_BENEF', 'TFU_HE', 'TGV_RH', 'TDS_RH', 'TDT_RH' }
Else
	aLocaisMdls := { 'TFF_RH', 'TFI_LE', 'TWODETAIL' }
	aRhMdls := { 'ABP_BENEF', 'TFG_MI', 'TFH_MC', 'TXPDETAIL', 'TXQDETAIL', 'TFU_HE', 'TGV_RH', 'TDS_RH', 'TDT_RH' }
EndIf

                // ID_MODEL     CAMPO_CHAVE, LISTA_SUBMODELS
aElementos := { { 'TFJ_REFER' , ''         , { 'TFL_LOC' }} , ;
				{'TFL_LOC'   , 'TFL_LOCAL' , aLocaisMdls } , ;
					{'TFF_RH'    , 'TFF_PRODUT', aRhMdls } , ;
					{'ABP_BENEF' , 'ABP_BENEFI', {} }, ;
					{'TFG_MI'    , 'TFG_PRODUT', {} }, ;
					{'TFH_MC'    , 'TFH_PRODUT', {} }, ;
					{'TXPDETAIL' , 'TXP_CODUNI', {} }, ;
					{'TXQDETAIL' , 'TXQ_CODPRD', {} }, ;
					{'TFU_HE'    , 'TFU_CODABN', {} }, ;
					{'TFI_LE'    , 'TFI_PRODUT', { 'TEV_ADICIO' } },  ;
					{'TEV_ADICIO', 'TEV_MODCOB', {} }, ;
					{'TGV_RH'    , 'TGV_CURSO' , {} }, ;
					{'TDS_RH'    , 'TDS_CODTCZ', {} }, ;
					{'TDT_RH'    , {'TDT_CODHAB','TDT_HABX5'}, {} }, ;
					{'TWODETAIL', 'TWO_CODFAC', {} } ;
					}
/*
	ID_MODEL - identificador do model para cópia dos dados
	CAMPO_CHAVE - campo para verificar se é necessário copiar o conteúdo da linha (somente utilizado quando for grid)
	LISTA_SUBMODELS -
*/

nPosElem := aScan( aElementos, {|x| x[1]==cIdModl} )
nPosSub  := 0

oFromAux := oFrom:GetModel( aElementos[nPosElem,1] )
oToAux   := oTo:GetModel( aElementos[nPosElem,1] )

//  caso os totalizadores estejam habilitados para a rotina
// inibe a cópia dos campos que são totalizados por gatilhos
If oToAux:ClassName()=='FWFORMGRID'

	For nForTo := 1 To oFromAux:Length()

		oFromAux:GoLine( nForTo )

		// verifica se o campo principal do grid está preenchido, ou seja
		// se há necessidade de copiar
		If !oFromAux:IsDeleted() .And. ;
			At740VlEmpty( aElementos[nPosElem,2], oFromAux )

			// testa quando é necessário adicionar uma nova linha
			If At740VlEmpty( aElementos[nPosElem,2], oToAux )
				oToAux:AddLine()
			EndIf

			lRet := AtCpyData( oFromAux, oToAux, aNoCpos )

			If lRet
				For nSubMdls := 1 To Len( aElementos[nPosElem,3] )
					cIdModl := aElementos[nPosElem,3,nSubMdls]

					FillModel( @lRet, cIdModl, oFrom, oTo, lOrcPrecif )

					If !lRet
						Exit
					EndIf

				Next nSubMdls

			EndIf

		EndIf

		If !lRet
			Exit
		EndIf

	Next nForTo

Else

	lRet := AtCpyData( oFromAux, oToAux, aNoCpos )

	If lRet
		For nSubMdls := 1 To Len( aElementos[nPosElem,3] )
			cIdModl := aElementos[nPosElem,3,nSubMdls]

			FillModel( @lRet, cIdModl, oFrom, oTo, lOrcPrecif  )

			If !lRet
				Exit
			EndIf

		Next nSubMdls

	EndIf

EndIf

Return

/*/{Protheus.doc} At740VlEmpty
	Função para verificar se o campo chave de preenchimento do grid está com conteúdo válido
@sample 	At740VlEmpty( aElementos[nPosElem,2], oFromAux )
@since		11/03/2016
@version	P2

@param 		xLista, Caracter ou Array, indica o campo ou a lista de campos a terem o conteúdo verificado
@param 		oMdlAlvo, Objeto FwFormGridModel ou FwFormFieldsModel, modelo de dados a receber a verificação do campo
@return 	lRet, Logico, indica se o campo está com conteúdo (.T.) ou não (.F.)
/*/
Static Function At740VlEmpty( xLista, oMdlAlvo )

Local lPreenchido := .F.
Local nI := 0

Default xLista := ""
// verifica o conteúdo no campo quando é caracter
If ValType(xLista)=="C" .And. !Empty(xLista) .And. !Empty(oMdlAlvo:GetValue(xLista))
	lPreenchido := .T.
// verifica o conteúdo nos campos quando é array
ElseIf ValType(xLista)=="A" .And. !Empty(xLista)

	For nI := 1 To Len(xLista)
		// ao identificar algum campo preenchido (condição OU para o preenchimento dos campos)
		// já encerra o loop
		lPreenchido := !Empty(oMdlAlvo:GetValue(xLista[nI]))
		If lPreenchido
			Exit
		EndIf
	Next nI
EndIf
Return lPreenchido

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740InPad

Função para inicializador padrão do total

@sample 	AtIniPadMvc()

@since		02/10/2013
@version	P11.90

@return 	nRet, retorna o resultado do cálculo

/*/
//------------------------------------------------------------------------------
Function At740InPad(oMdl)

Local aArea	:= GetArea()
Local aSaveLines	:= {}
Local oModel	:= If( oMdl == nil, FwModelActive(), oMdl)
Local oMdlRh	:= nil
Local nTotRh 	:= 0
Local nTotMI	:= 0
Local nTotMC	:= 0
Local nRet		:= 0
Local lExtra 	:= .F.	//item extra
Local nTotUni	:= 0
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()
Local nTotArm	 := 0

If oModel <> nil .and. oModel:GetID() $ 'TECA740;TECA740F'
	aSaveLines := FWSaveRows()
	oMdlRh	:= oModel:GetModel("TFF_RH")
	nTotRh	:= oMdlRh:GetValue("TFF_SUBTOT")
	nTotMI	:= oMdlRh:GetValue("TFF_TOTMI")
	nTotMC	:= oMdlRh:GetValue("TFF_TOTMC")
	If lGsOrcUnif
		nTotUni	:= oMdlRh:GetValue("TFF_TOTUNI")
	Endif
	If lGsOrcArma
		nTotArm := oMdlRh:GetValue("TFF_TOTARM")
	Endif
	lExtra := (oMdlRh:GetValue("TFF_COBCTR") == '2')
	FWRestRows( aSaveLines )
EndIf

If !lExtra
	If (!Empty(oMdlRh:GetValue("TFF_PLACOD"))) .OR. isInCallStack('At998ExPla') .OR. isInCallStack('At998MdPla')
		nRet := nTotRh
	Else
		nRet := nTotRh+nTotMI+nTotMC+nTotUni+nTotArm
	EndIf
EndIf

RestArea(aArea)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740InSub

Função para calcular SubTotal da Aba Recursos Humanos

@sample 	At740InSub()

@since		02/10/2013
@version	P12

@return 	nRet, retorna o resultado do cálculo

/*/
//------------------------------------------------------------------------------
Function At740InSub()
Local aArea	:= GetArea()
Local oModel	:= FwModelActive()
Local oMdlRh	:= oModel:GetModel("TFF_RH")
Local nQtde	:= 	oMdlRh:GetValue("TFF_QTDVEN")
Local nTotRh 	:= oMdlRh:GetValue("TFF_PRCVEN")
Local nLucro	:= oMdlRh:GetValue("TFF_TXLUCR")
Local nTxAdm	:= oMdlRh:GetValue("TFF_TXADM")
Local nRet		:= 0

//Arredondo valores conforme tamanho do campos campos
nLucro := Round(nLucro,TamSX3("TFF_TXLUCR")[2])
nTxAdm := Round(nTxAdm,TamSX3("TFF_TXADM")[2])

nRet := (nQtde*nTotRh)+nLucro+nTxAdm

RestArea(aArea)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740CDesc

Função para cálcular o desconto do produto.

@sample 	At740CDesc(cMdlDom,cCmpQtd,cCmpVlr,cCmpDesc,cCmpAlvo)

@since		02/10/2013
@version	P11.90

@return 	nResp, Númerico, retorna o conteúdo do cálculo.

@param  	cMdlDom, Caracter, nome do modelo de dados principal
@param  	cCmpQtd, Caracter, nome do campo para cálculo
@param  	cCmpVlr, Caracter, nome do campo para cálculo
@param  	cCmpDesc, Caracter, nome do campo para cálculo
@param  	cCmpAlvo, Caracter, nome do campo para receber resultado
/*/
//------------------------------------------------------------------------------
Function At740CDesc(cMdlDom,cCmpQtd,cCmpVlr,cCmpDesc,cCmpAlvo)

Local oModel	:= FwModelActive()
Local oMdlPr	:= oModel:GetModel(cMdlDom)
Local nQtd		:= oMdlPr:GetValue(cCmpQtd)
Local nVlr		:= oMdlPr:GetValue(cCmpVlr)
Local nDesc		:= oMdlPr:GetValue(cCmpDesc)
Local nResp		:= 0

nResp := (nQtd*nVlr)*(1-(nDesc/100))

//Adicionar o valor das taxas de lucro e administrativas ao valor do SubTotal
If cCmpDesc == "TFF_DESCON" .And. !lGsPrecific
	nResp := nResp+oMdlPr:GetValue("TFF_TXLUCR")+oMdlPr:GetValue("TFF_TXADM")
EndIf

oMdlPr:SetValue( cCmpAlvo, nResp )

Return nResp

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldDt

Função para validação dos períodos iniciais e finais dos materiais e alocações.

@sample 	At740VldDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm)

@since		02/10/2013
@version	P11.90

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	cModelo, Caracter, nome do modelo de dados principal.
@param  	cCpoSelec, Caracter, nome do campo da data selecionada para validação.
@param  	cCpoDtIn, Caracter, nome do campo da data inicial.
@param  	cCpoDtFm, Caracter, nome do campo da data final.
/*/
//------------------------------------------------------------------------------
Function At740VldDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm,oModel,lExtra)

Local oMdl			:= nil
Local dDtIniLoc		:= CToD('')
Local dDtFimLoc		:= CToD('')
Local dPrIniRh		:= CToD('')
Local dPrFimRh		:= CToD('')
Local dDtFimRH	 	:= CToD('')
Local lRet			:= .F.
Local cMdlLoc
Local cMdlRH
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lNotRH 		:= lExtra .And. lOrcPrc
Local lDTEncTFF 	:= FindFunction("TecEncDtFt") .AND. TecEncDtFt() .AND. !GSGetIns("LE")

Default oModel	:= FwModelActive()
Default lExtra	:= .F.

oMdl		:= oModel:GetModel(cModelo)

If lExtra
	cMdlLoc := 'TFL_CAB'
	cMdlRH  := 'TFF_GRID'
Else
	cMdlLoc := 'TFL_LOC'
	cMdlRH  := 'TFF_RH'
EndIf

dDtIniLoc := oModel:GetModel(cMdlLoc):GetValue('TFL_DTINI')
dDtFimLoc := oModel:GetModel(cMdlLoc):GetValue('TFL_DTFIM')

If !lNotRH
	dPrIniRh := oModel:GetModel(cMdlRH):GetValue('TFF_PERINI')
	dPrFimRh := oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM')
EndIf

If Left(cCpoSelec,3) $ "TFI#TFF" .And. SubStr(cCpoSelec,5) == "PERINI"

	If DTOS(oMdl:GetValue(cCpoDtIn)) >= DTOS(dDtIniLoc) .AND. (DTOS(oMdl:GetValue(cCpoDtIn)) <= DTOS(dDtFimLoc) .OR. Empty(dDtFimLoc) )
		lRet := .T.
	EndIf

ElseIf Left(cCpoSelec,3) $ "TFI#TFF" .And. SubStr(cCpoSelec,5) == "PERFIM"

	If cModelo == "TFF_RH" .AND. lDTEncTFF .AND. oModel:GetModel(cMdlRH):GetValue('TFF_ENCE') == '1'
	    dDtFimRH := Posicione("TFF",1,oModel:GetModel(cMdlRH):GetValue("TFF_FILIAL")+oModel:GetModel(cMdlRH):GetValue("TFF_COD"),"TFF_PERFIM")
	 	If !Empty(oModel:GetModel(cMdlRH):GetValue('TFF_DTENCE'));
		 	.AND. (oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM') >= oModel:GetModel(cMdlRH):GetValue('TFF_DTENCE');
	 		.AND. oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM') <= dDtFimRH)

	 		lRet := .T.
	 	Else
	 		If Empty(oModel:GetModel(cMdlRH):GetValue('TFF_DTENCE'));
			 	.AND. oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM') <= dDtFimRH
	 			lRet := .T.
	 		EndIf
	 	EndIf
	ElseIf cModelo == "TFF_RH" .AND. !lDTEncTFF .AND. oModel:GetModel(cMdlRH):GetValue('TFF_ENCE') == '1'
	    dDtFimRH := Posicione("TFF",1,oModel:GetModel(cMdlRH):GetValue("TFF_FILIAL")+oModel:GetModel(cMdlRH):GetValue("TFF_COD"),"TFF_PERFIM")
		If oModel:GetModel(cMdlRH):GetValue('TFF_PERFIM') <= dDtFimRH
			lRet := .T.
	 	EndIf
	Else
		If !Empty(oMdl:GetValue(cCpoDtIn))
			If DTOS(oMdl:GetValue(cCpoDtFm)) >= DTOS(oMdl:GetValue(cCpoDtIn)) .AND. (DTOS(oMdl:GetValue(cCpoDtFm)) <= DTOS(dDtFimLoc) .OR. Empty(dDtFimLoc) )
				lRet := .T.
			EndIf
		EndIf
	EndIf
ElseIf SubStr(cCpoSelec,5) == "PERINI"

	If !lNotRH
		If DTOS(oMdl:GetValue(cCpoDtIn)) >= DTOS(dPrIniRh) .AND. ;
		  (DTOS(oMdl:GetValue(cCpoDtIn)) <= DTOS(dPrFimRh) .OR. ;
		  Empty(oModel:GetModel(cMdlRH):GetValue("TFF_PERFIM")) )
			lRet := .T.
		EndIf

	Else
		If DTOS(oMdl:GetValue(cCpoDtIn)) >= DTOS(dDtIniLoc) .AND. ;
		  (DTOS(oMdl:GetValue(cCpoDtIn)) <= DTOS(dDtFimLoc) .OR. ;
		  Empty(oModel:GetModel(cMdlLoc):GetValue("TFL_DTFIM")) )
			lRet := .T.
		EndIf
	EndIf

ElseIf SubStr(cCpoSelec,5) == "PERFIM"
	If !lNotRH
		If !Empty(oMdl:GetValue(cCpoDtIn))
			If DTOS(oMdl:GetValue(cCpoDtFm)) >= DTOS(oMdl:GetValue(cCpoDtIn)) .AND. ;
			  (DTOS(oMdl:GetValue(cCpoDtFm)) <= DTOS(dPrFimRh) .OR. ;
			  Empty(dPrFimRh) )
				lRet := .T.
			EndIf
		EndIf
	Else
		If !Empty(oMdl:GetValue(cCpoDtIn))
			If DTOS(oMdl:GetValue(cCpoDtFm)) >= DTOS(oMdl:GetValue(cCpoDtIn)) .AND. ;
			  (DTOS(oMdl:GetValue(cCpoDtFm)) <= DTOS(dDtFimLoc) .OR. ;
			  Empty(dDtFimLoc) )
				lRet := .T.
			EndIf
		EndIf
	EndIf
EndIf

If lRet .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") )
	If !oMdl:IsInserted() .AND. VldLineRvP( cCpoSelec, DTOS(oMdl:GetValue(cCpoSelec)), IIF(Empty(oMdl:GetValue(Left(cCpoSelec,3)+"_CODREL")), oMdl:GetValue(Left(cCpoSelec,3)+"_COD"), oMdl:GetValue(Left(cCpoSelec,3)+"_CODREL")), Left(cCpoSelec,3))
		oMdl:LoadValue(Left(cCpoSelec,3)+"_MODPLA", "2")
	Else
		oMdl:LoadValue(Left(cCpoSelec,3)+"_MODPLA", "1")
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldHr

Função para validação dos horarios do periodos iniciais e finais dos materiais e alocações.

@sample 	At740VldDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm)

@since		23/10/2013
@version	P11.90

@return 	lRet, Lógico, retorna .T. se o horario for válido.

@param  	cModelo, Caracter, nome do modelo de dados principal.
@param  	cCpoSelec, Caracter, nome do campo da hora selecionada para validação.
@param  	cCpoHrIn, Caracter, nome do campo da hora inicial.
@param  	cCpoHrFm, Caracter, nome do campo da hora final.
/*/
//------------------------------------------------------------------------------
Function At740VldHr(cModelo,cCpoSelec,cCpoHrIn,cCpoHrFm)

Local oModel  := FwModelActive()
Local oMdl		:= oModel:GetModel(cModelo)
Local lRet    := (Len(Alltrim(oMdl:GetValue(cCpoSelec))) == 1)

If !lRet

	If SubStr(cCpoSelec,5) == "HORAIN" .And. ! Empty(FwFldGet("TFF_HORAIN"))

		If oMdl:GetValue(cCpoHrIn) >= FwFldGet("TFF_HORAIN") .And. ;
		   (oMdl:GetValue(cCpoHrIn) <= FwFldGet("TFF_HORAFI") .OR. Empty(FwFldGet("TFF_HORAFI")))
			lRet := .T.
		EndIf

	ElseIf SubStr(cCpoSelec,5) == "HORAFI" .And. ! Empty(FwFldGet("TFF_HORAFI"))

		If !Empty(oMdl:GetValue(cCpoHrIn))
			If oMdl:GetValue(cCpoHrFm) >= oMdl:GetValue(cCpoHrIn) .And. ;
				(oMdl:GetValue(cCpoHrFm) >= FwFldGet("TFF_HORAIN") .Or. Empty(FwFldGet("TFF_HORAIN"))) .And. ;
				(oMdl:GetValue(cCpoHrFm) <= FwFldGet("TFF_HORAFI") .Or. Empty(FwFldGet("TFF_HORAFI")))
				lRet := .T.
			EndIf
		EndIf

	EndIf

EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlVig
	Valida a fata de vigência em todos os grids dependentes da tabela TFL

@sample 	At740VlVig(oModel)

@since		05/10/2013
@version	P11.90

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	oModel, Objeto, modelo de dados da tabela TFL
/*/
//------------------------------------------------------------------------------
Function At740VlVig(oModel, cCampo, xValueNew, nLine, xValueOld)

Local oMdlGeral     := oModel:GetModel()
Local oView         := nil
Local oMdlRH        := nil
Local oMdlMI        := nil
Local oMdlMC        := nil
Local oMdlLE        := nil
Local oMdlTFJ       := nil
Local nLinRh        := 0
Local nLinMi        := 0
Local nLinMc        := 0
Local nLinLe        := 0
Local aSaveRows     := {}
Local aItens        := {}
Local aAreaCN9      := {}
Local cDtIniCtr     := CToD('')
Local dDtIniLoc     := CToD('')
Local dDtFimLoc     := CToD('')
Local lRet          := .T.
Local lReplica      := .F.
Local lDTEncTFF 	:= FindFunction("TecEncDtFt") .AND. TecEncDtFt() .AND. !GSGetIns("LE")

If !IsBlind()
    oView := FwViewActive()
EndIf

If oMdlGeral == nil
    oMdlGeral := FwModelActive()
EndIf

dDtIniLoc   := oMdlGeral:GetModel('TFL_LOC'):GetValue('TFL_DTINI')
dDtFimLoc   := oMdlGeral:GetModel('TFL_LOC'):GetValue('TFL_DTFIM')

oMdlRH  := oMdlGeral:GetModel("TFF_RH")
oMdlMI  := oMdlGeral:GetModel("TFG_MI")
oMdlMC  := oMdlGeral:GetModel("TFH_MC")
oMdlLE  := oMdlGeral:GetModel("TFI_LE")
oMdlTFJ := oMdlGeral:GetModel("TFJ_REFER")

If IsInCallStack("At870Revis") .OR. IsInCallStack("AT870PlaRe")
    If !GSGetIns('LE') .AND. cCampo == "TFL_DTFIM" .AND. !Empty(xValueOld) .AND. xValueNew <> xValueOld
        If !IsBlind()
            lReplica := MsgYesNo(STR0303) //"Deseja replicar esta data para os demais itens deste contrato? "
		Else
            lReplica := .F.
        EndIf
    EndIf
    If !Empty(oMdlTFJ:GetValue('TFJ_CONTRT'))
        dbSelectArea("CN9")
        aAreaCN9 := CN9->(GetArea())
        CN9->(dbSetOrder(8))
        If CN9->(DbSeek(XFilial("CN9")+ oMdlTFJ:GetValue('TFJ_CONTRT')+oMdlTFJ:GetValue('TFJ_CONREV')))
            cDtIniCtr := CN9->CN9_DTINIC
        EndIf
        RestArea(aAreaCN9)
    EndIf
EndIf

aSaveRows := FwSaveRows()

For nLinRh := 1 to oMdlRH:Length() // Aba Recursos humanos

    oMdlRH:GoLine( nLinRh )
    If !oMdlRH:IsDeleted() .And. !Empty(oMdlRH:GetValue("TFF_COD")) .And. !Empty(oMdlRH:GetValue("TFF_PERFIM"))
        If lReplica .OR. DTOS(dDtFimLoc) >= DTOS(oMdlRH:GetValue("TFF_PERFIM"))
            If lReplica
                AADD( aItens, { oMdlRH:GetValue("TFF_COD"), nLinRh, oMdlRH:GetValue("TFF_PERFIM"), {}, {}})
                If oMdlRH:GetValue('TFF_COBCTR') == '2' .Or. oMdlRH:GetValue('TFF_ENCE') == '1'
					If oMdlRH:GetValue('TFF_COBCTR') == '2'
						If oMdlRH:GetValue('TFF_PERFIM') > dDtFimLoc
							lRet := .F.
							oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFF_PERFIM",oModel:GetModel():GetId(), "TFF_PERFIM",'TFF_PERFIM',	STR0308,'' ) // "Não é possivel reduzir a data deste posto, existem itens extra com a data superior a nova data."
							oView:Refresh("VIEW_RH")
						EndIf
					Else
						If lDTEncTFF .And. !Empty(oMdlRH:GetValue('TFF_DTENCE'))
							If oMdlRH:GetValue('TFF_DTENCE') > dDtFimLoc
								lRet := .F.
								oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFF_PERFIM",oModel:GetModel():GetId(), "TFF_PERFIM",'TFF_PERFIM',	STR0325,'' ) // "Não é possivel reduzir a data deste posto, existem itens encerrados com a data superior a nova data."
								oView:Refresh("VIEW_RH")
							Else
								If oMdlRH:GetValue('TFF_DTENCE') <> oMdlRH:GetValue('TFF_PERFIM') .And. oMdlRH:GetValue('TFF_PERFIM') > oMdlRH:GetValue('TFF_DTENCE')
									oMdlRH:LoadValue('TFF_PERFIM', oMdlRH:GetValue('TFF_DTENCE'))
								EndIf
							EndIf
						Else
							If oMdlRH:GetValue('TFF_PERFIM') > dDtFimLoc
								lRet := .F.
								oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFF_PERFIM",oModel:GetModel():GetId(), "TFF_PERFIM",'TFF_PERFIM',	STR0325,'' ) // "Não é possivel reduzir a data deste posto, existem itens encerrados com a data superior a nova data."
								oView:Refresh("VIEW_RH")
							EndIf
						EndIf
					EndIf
				Else
					If !oMdlRH:SetValue('TFF_PERFIM', dDtFimLoc)
                    	lRet := .F.
                        Exit
                    EndIf
				EndIf
			Else
                If DTOS(dDtFimLoc) < DTOS(oMdlRH:GetValue("TFF_PERFIM"))
                     lRet := .F.
                EndIf
            EndIf
            If lRet
                For nLinMi := 1 to oMdlMI:Length() // Aba Materiais de Implantação
                    oMdlMI:GoLine( nLinMi )
                    If !oMdlMI:IsDeleted() .AND. !Empty(oMdlMI:GetValue("TFG_COD")) .AND. !Empty(oMdlMI:GetValue("TFG_PERFIM"))
                        If lReplica
                            AADD( aItens[nLinRh][4], { oMdlRH:GetValue("TFF_COD"), nLinMi, oMdlMI:GetValue("TFG_PERFIM"), oMdlMI:GetValue("TFG_COD")})
							If oMdlMI:GetValue('TFG_COBCTR') == '2'
								If oMdlMI:GetValue('TFG_PERFIM') > dDtFimLoc
									lRet := .F.
									oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFG_PERFIM",oModel:GetModel():GetId(), "TFG_PERFIM",'TFG_PERFIM',	STR0308,'' ) // "Não é possivel reduzir a data deste posto, existem itens extra com a data superior a nova data."
									oView:Refresh("VIEW_MI")
								EndIf
							Else
								If lDTEncTFF .And. oMdlRH:GetValue('TFF_ENCE') == '1' .And. (oMdlMI:GetValue('TFG_PERFIM') > oMdlRH:GetValue('TFF_DTENCE') .Or. oMdlMI:GetValue('TFG_PERFIM') > oMdlRH:GetValue('TFF_PERFIM'))
									oMdlMI:LoadValue('TFG_PERFIM', oMdlRH:GetValue('TFF_PERFIM'))
								Else
									If !oMdlMI:SetValue('TFG_PERFIM', dDtFimLoc)
										lRet := .F.
										Exit
									EndIf
								EndIf
							EndIf
                        Else
                            If DTOS(dDtFimLoc) < DTOS(oMdlMI:GetValue("TFG_PERFIM"))
                                lRet := .F.
                            EndIf
                        EndIf
                    EndIf

                Next nLinMi
            Else
                Exit
            EndIf
            If lRet
                For nLinMc := 1 to oMdlMC:Length() // Aba Materiais de Consumo

                    oMdlMC:GoLine( nLinMc )

                    If !oMdlMC:IsDeleted() .AND. !Empty(oMdlMC:GetValue("TFH_COD")) .AND. !Empty(oMdlMC:GetValue("TFH_PERFIM"))
                        If lReplica
                            AADD( aItens[nLinRh][5], { oMdlRH:GetValue("TFF_COD"), nLinMc, oMdlMC:GetValue("TFH_PERFIM"), oMdlMC:GetValue("TFH_COD")})

							If oMdlMC:GetValue('TFH_COBCTR') == '2'
								If oMdlMC:GetValue('TFH_PERFIM') > dDtFimLoc
									lRet := .F.
									oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFH_PERFIM",oModel:GetModel():GetId(), "TFH_PERFIM",'TFH_PERFIM',	STR0308,'' ) // "Não é possivel reduzir a data deste posto, existem itens extra com a data superior a nova data."
								EndIf
							Else
								If lDTEncTFF .And. oMdlRH:GetValue('TFF_ENCE') == '1' .And. (oMdlMC:GetValue('TFH_PERFIM') > oMdlRH:GetValue('TFF_DTENCE') .Or. oMdlMC:GetValue('TFH_PERFIM') > oMdlRH:GetValue('TFF_PERFIM'))
									oMdlMC:LoadValue('TFH_PERFIM', oMdlRH:GetValue('TFF_PERFIM'))
								Else
									If !oMdlMC:SetValue('TFH_PERFIM', dDtFimLoc)
										lRet := .F.
										Exit
									EndIf
								EndIf
							EndIf
                        Else
                            If DTOS(dDtFimLoc) < DTOS(oMdlMC:GetValue("TFH_PERFIM"))
                                lRet := .F.
                            EndIf
                        EndIf
                    EndIf
                Next nLinMc
            Else
                Exit
            EndIf
        Else
            lRet := .F.
        EndIf
    EndIf
Next nLinRh

If !lReplica
    For nLinLe := 1 to oMdlLE:Length()
        oMdlLE:GoLine( nLinLe )
        If !oMdlLE:IsDeleted()
            If DTOS(dDtFimLoc) < DTOS(oMdlLE:GetValue("TFI_PERFIM"))
                lRet := .F.
            EndIf
        EndIf
    Next nLinLe
Else
    If !lRet
        For nLinRh := 1 to Len(aItens) // Aba Recursos humanos
            oMdlRH:GoLine( aItens[nLinRh][2] )
            oMdlRH:LoadValue('TFF_PERFIM', aItens[nLinRh][3])
            For nLinMi := 1 to Len(aItens[nLinRh][4]) // Aba Materiais de Implanta??o
                oMdlMI:GoLine( aItens[nLinRh][4][nLinMi][2] )
                oMdlMI:LoadValue('TFG_PERFIM', aItens[nLinRh][4][nLinMi][3] )
            Next nLinMi
            For nLinMc := 1 to Len(aItens[nLinRh][5]) // Aba Materiais de Consumo
                oMdlMC:GoLine( aItens[nLinRh][5][nLinMc][2] )
                oMdlMC:LoadValue('TFH_PERFIM', aItens[nLinRh][5][nLinMc][3] )
            Next nLinMc
        Next nLinRh
        oMdlGeral:GetModel('TFL_LOC'):LoadValue("TFL_DTFIM",xValueOld)
        If !IsBlind()
            oView:Refresh()
        EndIf

    EndIf
EndIf

FwRestRows( aSaveRows )

If !lRet .AND. !lReplica
    oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_DTFIM",oModel:GetModel():GetId(), "TFL_DTFIM",'TFL_DTFIM',;
        STR0025, STR0026 )  // 'Data final de vigência menor que o período final dos recursos, materiais e locação' ### 'Digite uma data maior.'
EndIf

If  lRet .and. !Empty(dDtFimLoc) .and. !Empty(dDtIniLoc) .And. (dDtFimLoc < dDtIniLoc)
    oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_DTFIM",oModel:GetModel():GetId(), "TFL_DTFIM",'TFL_DTFIM',;
        STR0026,'' )  // 'Digite uma data maior.'###'Atenção!'
    lRet := .F.
EndIf

If !Empty(cDtIniCtr) .And. !Empty(dDtIniLoc) .And. dDtIniLoc < cDtIniCtr

    oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_DTINI",oModel:GetModel():GetId(), "TFL_DTINI",'TFL_DTINI',;
    STR0287, STR0026 )  // 'Data Inicial de vigência menor que o período inicial do contrato' ### 'Digite uma data maior.'
    lRet := .F.
EndIf

If lReplica .AND. lRet
	MsgInfo(STR0307) //"Itens do local alterados com sucesso!"
EndIf

If !IsBlind() .AND. lReplica
	oView:Refresh()
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SCmt / At740GCmt
	Altera o conteúdo da variável

@sample 	At740CpyMdl

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740SCmt( lValor )

lDoCommit := lValor

Return

Function At740GCmt()
Local lVersion23	:= HasOrcSimp()
Return lDoCommit .Or. (IsInCallStack('TECA745') .Or. IsInCallStack('TECA270') .AND. lVersion23)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SLoad
	Realiza a cópia dos dados de um modelo para outro
evitando sobrepor conteudo de alguns campos, informados na exceção

@sample 	At740CpyMdl

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740SLoad( oObj )

oCharge := oObj

Return

Function At740GLoad()

Return( oCharge )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740GXML
	Realiza a cópia dos dados de um modelo para outro
evitando sobrepor conteudo de alguns campos, informados na exceção

@sample 	At740GXML

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740GXML()

Return cXmlDados


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SLuc / At740GLuc
	Altera o conteúdo da variável

@sample 	At740CpyMdl

@since		26/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740SLuc( nValor )

nTLuc := nValor

Return

Function At740GLuc()

Return nTLuc


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740SAdm / At740GAdm
	Altera o conteúdo da variável

@sample 	At740CpyMdl

@since		26/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740SAdm( nValor )

nTAdm := nValor

Return

Function At740GAdm()

Return nTAdm


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldPrd
	Valida o produto selecionado conforme o tipo Rec. Humano, Mat. consumo, etc

@sample  	At740VldPrd

@since   	23/09/2013
@version 	P11.90

@param   	ExpN, Numerico, define qual o tipo do produto para validar sendo:
				1 - Recurso Humano
				2 - Material de Implantação
				3 - Material de Consumo
				4 - Equipamentos para Locação
@param   	ExpC, Caracter, código do produto a ser validado

@return  	ExpL, Logico, indica de se é valido (.T.) ou não (.F.)
/*/
//------------------------------------------------------------------------------
Function At740VldPrd( nTipo, cCodProd )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet := .F.

DEFAULT nTipo := 0
DEFAULT cCodProd := ''
//--------------------------------------------------------------------
// Posiciona na tabela SB5 para verificar a configuração do produto
// conforme cada tipo exige

DbSelectArea('SB5')
SB5->( DbSetOrder( 1 ) ) //B5_FILIAL+B5_COD

If !Empty(cCodProd) .And. SB5->( DbSeek( xFilial('SB5')+cCodProd ) )
	Do Case

		CASE nTipo == 1 // Recurso Humano
			lRet := SB5->B5_TPISERV == '4'

		CASE nTipo == 2 // Material de Implantação
			lRet := SB5->B5_TPISERV $ '1235' .And. SB5->B5_GSMI == '1'

		CASE nTipo == 3 // Material de Consumo
			lRet := SB5->B5_TPISERV $ '5' .And. SB5->B5_GSMC == '1'

		CASE nTipo == 4 // Locação de Equipamentos
			lRet := SB5->B5_TPISERV $ '5' .And. SB5->B5_GSLE == '1'

	End Case

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TdOk
	Validação geral do modelo

@sample 	At740TdOk

@since		23/09/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740TdOk( oMdlGer )

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local aValidMat		:= {}	//Estrutura com locais e itens de RH com sem valor de materiais
Local oMdlLoc		:= oMdlGer:GetModel('TFL_LOC')
Local oMdlGrid		:= oMdlGer:GetModel('TFI_LE')
Local oMdlCobLoc	:= oMdlGer:GetModel('TEV_ADICIO')
Local oMdlRH		:= oMdlGer:GetModel('TFF_RH')
Local oModMI		:= oMdlGer:GetModel('TFG_MI')
Local oModMC		:= oMdlGer:GetModel('TFH_MC')
Local oModTFJ		:= oMdlGer:GetModel('TFJ_REFER')
Local oMdlSLY		:= Nil
Local oMdl352		:= Nil
Local nLinGrd		:= 0
Local nLinFil		:= 0
Local nLinTev		:= 0
Local nI			:= 0
Local nJ			:= 0
Local nK			:= 0
Local lExit         := .F.
Local nPrcVenda		:= 0
Local lCobrContr	:= .F.
Local lOk			:= .T.
Local lRet			:= .T.
Local lExclusao 	:= oMdlGer:GetOperation() == MODEL_OPERATION_DELETE
Local lOrcPrc 	:= !EMPTY(oModTFJ:GetValue("TFJ_CODTAB"))
Local lPermLocZero 	:= .F. //At680Perm( , __cUserId, '032' )
Local lAlgumTemValor 	:= .F.
Local lNotRhMts 		:= .F.
Local lVldLe		:= .F.
Local nValOrc        := 0

// não realiza validaçaõ alguma quando é exclusão
If lExclusao
	lRet := oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_STATUS") == "2" .Or. ; // Só permite a exclusão de orçamentos com status em revisão
				Empty( oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_CONTRT") ); // ou que não tenha contrato ainda
			.OR. (isInCallStack("AT870PlaRe") .AND. oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_STATUS") == "8" )
	If !lRet
            oMdlGer:GetModel():SetErrorMessage( oMdlGer:GetId(),"TFJ_STATUS","TFJ_REFER", "TFJ_STATUS",;
			oMdlGer:GetModel("TFJ_REFER"):GetValue("TFJ_STATUS"),;
			STR0125,"" )  // "Não é permitido excluir orçamentos de serviços neste status"
	EndIf
Else
	// verifica se foram inseridos produtos/recursos nos Locais
	If lRet
		For nI := 1 To oMdlLoc:Length()
			oMdlLoc:GoLine( nI )
			If !oMdlLoc:IsDeleted()
				lVldLe := At740VldLe(oMdlGer)
				If ( lRet := lVldLe )
					If oMdlLoc:GetValue("TFL_TOTAL") == 0
						lNotRhMts := ( oMdlRH:IsEmpty() .And. oModMI:IsEmpty() .And. oModMC:IsEmpty() )
						If !lPermLocZero .Or. lNotRhMts
							lRet := .F.
							Help(,, "AT740TDOKRH",, STR0209, 1, 0) // "Não é possivel ter local de atendimento com valor zerado. Por favor verifique os itens."
							Exit
						EndIf
					Else
						lAlgumTemValor := .T.
						Exit
					EndIf
				Else
					Exit
				EndIf
			EndIf
		Next
		If !lAlgumTemValor .And. lPermLocZero
			lRet := .F.
		EndIf
    EndIf

	If lRet

		If IsInCallStack("At600SeAtu")//Realiza validação somente dentro da tela do TECA740
			If ! (Empty(oMdlGer:GetModel('TFJ_REFER'):GetValue('TFJ_GESMAT')) .OR. (oMdlGer:GetModel('TFJ_REFER'):GetValue('TFJ_GESMAT') = '1'))//Material por valor ou por percentual do recurso
				For nI:=1 To oMdlLoc:Length()
					oMdlLoc:GoLine(nI)

					If !oMdlLoc:IsDeleted()
						For nJ:=1 To oMdlRH:Length()
							oMdlRH:GoLine(nJ)
							If !oMdlRh:IsDeleted() .AND. !Empty(oMdlRh:GetValue("TFF_PRODUT")) .AND. oMdlRh:GetValue("TFF_VLRMAT") == 0
								aAdd(aValidMat, { oMdlLoc:GetValue("TFL_LOCAL"),;
												oMdlLoc:GetValue("TFL_DESLOC"),;
												oMdlRH:GetValue("TFF_ITEM"),;
												oMdlRH:GetValue("TFF_PRODUT"),;
												oMdlRH:GetValue("TFF_DESCRI") })
							EndIf
						Next nJ
					EndIf
				Next nI

				If Len(aValidMat) > 0
					If !At740ExbIt(aValidMat)//Apresenta itens em tela
						lRet := .F.
					EndIf
				EndIf
			EndIf

		EndIf

		If lRet
			For nI := 1 To oMdlLoc:Length()

				oMdlLoc:GoLine(nI)

				If !oMdlLoc:IsDeleted()
					// verifica o preenchimento dos recursos humanos
					For nJ := 1 To oMdlRH:Length()
						oMdlRH:GoLine(nJ)
						If TecVlPrPar() .AND. !oMdlRH:IsDeleted() .AND.;
								!Empty( oMdlRH:GetValue("TFF_PRODUT") ) .AND. oMdlRH:GetValue("TFF_VLPRPA") == 0 .AND.;
									!isInCallStack("At870GerOrc")
							oMdlRH:LoadValue("TFF_VLPRPA", At740PrxPa("TFF") )
						EndIf
						// verifica o preenchimento dos campos de valores
						If !oMdlRH:IsDeleted() .And. !Empty( oMdlRH:GetValue("TFF_PRODUT") )
							lRet := oMdlRH:GetValue("TFF_PRCVEN") >= 0
						EndIf
						If !lRet
							Help(,,"AT740TDOKRH",,STR0126,1,0) // "O valor dos itens de recursos humanos não pode ser zero para itens pertencentes ao contrato."
						EndIf

						If !lOrcPrc
							// verifica o preenchimento dos valores dos materiais
							lRet := lRet .And. At740VlrMts( oModMI, "TFG", lPermLocZero, oMdlLoc:GetValue("TFL_TOTAL") )
							lRet := lRet .And. At740VlrMts( oModMC, "TFH", lPermLocZero, oMdlLoc:GetValue("TFL_TOTAL") )
						EndIf
						For nK := 1 To oModMI:Length()
							oModMI:GoLine(nK)
							If TecVlPrPar() .AND. !oModMI:IsDeleted() .AND.;
									!Empty( oModMI:GetValue("TFG_PRODUT") ) .AND. oModMI:GetValue("TFG_VLPRPA") == 0 .AND.;
										!isInCallStack("At870GerOrc")
								oModMI:LoadValue("TFG_VLPRPA", At740PrxPa("TFG") )
							EndIf
						Next nK
						For nK := 1 To oModMC:Length()
							oModMC:GoLine(nK)
							If TecVlPrPar() .AND. !oModMC:IsDeleted() .AND.;
									!Empty( oModMC:GetValue("TFH_PRODUT") ) .AND. oModMC:GetValue("TFH_VLPRPA") == 0 .AND.;
										!isInCallStack("At870GerOrc")
								oModMC:LoadValue("TFH_VLPRPA", At740PrxPa("TFH") )
							EndIf
						Next nK
						If !lRet
							EXIT
						EndIf
					Next nJ

					If lOrcPrc
						// verifica o preenchimento dos valores dos materiais
						lRet := lRet .And. At740VlrMts( oModMI, "TFG", lPermLocZero, oMdlLoc:GetValue("TFL_TOTAL") )
						lRet := lRet .And. At740VlrMts( oModMC, "TFH", lPermLocZero, oMdlLoc:GetValue("TFL_TOTAL") )
					EndIf

					If TecVlPrPar() .AND. !oMdlLoc:IsDeleted() .AND.;
							!Empty( oMdlLoc:GetValue("TFL_LOCAL") ) .AND. !isInCallStack("At870GerOrc")
						At740AtTpr()
					EndIf

				EndIf

				If !lRet
					EXIT
				EndIf
			Next nI
		EndIf

		If lRet
			//--------------------------------------------------------------------------------
			//  Valida a existência de cobrança para os itens de locação de equipamentos
			For nLinGrd := 1 To oMdlLoc:Length()

			oMdlLoc:GoLine( nLinGrd )

			If !oMdlLoc:IsDeleted()

                If lRet
					For nLinFil := 1 To oMdlGrid:Length()

						oMdlGrid:GoLine( nLinFil )

						If !oMdlGrid:IsDeleted() .And. !Empty( oMdlGrid:GetValue('TFI_PRODUT') )
							If lOk
								//Validação dos campos de Entrega e Coleta
								If lRet
									If (!Empty(oMdlGrid:GetValue('TFI_ENTEQP')) .And. Empty(oMdlGrid:GetValue('TFI_COLEQP')));
										.Or. (Empty(oMdlGrid:GetValue('TFI_ENTEQP')) .And. !Empty(oMdlGrid:GetValue('TFI_COLEQP')))
										lRet := .F.
										Help(,,"AT740OPC1",,STR0095,1,0) //"Não é possivel deixar um dos campos de Entrega/Coleta preenchidos, ou os campos deve estar em branco ou os dois preenchidos! "
										Exit
									Elseif (!Empty(oMdlGrid:GetValue("TFI_ENTEQP")) .AND. !At740VldAg("TFI_ENTEQP",;
												oMdlGrid:GetValue("TFI_PERINI"),;
												oMdlGrid:GetValue("TFI_PERFIM"),;
												oMdlGrid:GetValue("TFI_ENTEQP"),;
												oMdlGrid:GetValue("TFI_COLEQP"))) .OR. (!Empty(oMdlGrid:GetValue("TFI_COLEQP")) .AND. !At740VldAg("TFI_COLEQP",;
												oMdlGrid:GetValue("TFI_PERINI"),;
												oMdlGrid:GetValue("TFI_PERFIM"),;
												oMdlGrid:GetValue("TFI_ENTEQP"),;
												oMdlGrid:GetValue("TFI_COLEQP")))

										lRet := .F.
										Exit
									Elseif Empty(oMdlGrid:GetValue("TFI_TES"))
										Help(,, "At740TdOk",,STR0098,1,0,,,,,,{STR0099}) //"O campo TES do grid de Locação de Equipamentos não pode ser vazio." # "Informe a TES."
										lRet := .F.
										Exit
									ElseIf (!Empty(oMdlGrid:GetValue("TFI_APUMED")) .and. oMdlGrid:GetValue("TFI_APUMED") <> '1') .And. ( Empty(oMdlGrid:GetValue('TFI_ENTEQP')) .or. Empty(oMdlGrid:GetValue('TFI_COLEQP')) )
										Help(,, "At740TdOk",,STR0112,1,0,,,,,,{STR0113})//#"Quando Tipo de Apuração for diferente de Branco ou '1' é necessario fazer o preenchimento dos campos de Entrega e Coleta"#"Favor preencher os campos de Entrega e Coleta para Processeguir"
										lRet := .F.
										Exit
									Endif
								EndIf

								//  quando identifica uma cobrança, vai para a próxima linha
								// dos itens de locação
								Loop
							Else
								//  quando identifica erro, sai com erro e força o preenchimento
								lRet := .F.
								Help(,,'AT740COBLOC',, STR0027 + CRLF + ;  // 'Cobrança da locação não preenchida para o item: '
														STR0028 + STR(nLinGrd) + CRLF + ;  // 'Item Local '
														STR0029 + STR(nLinFil) + CRLF + ;  // 'Item Locação '
														STR0030 ,1,0)  // 'Preencha a cobrança e depois confirme o Orçamento'
								Exit
							EndIf

						EndIf

					Next nLinFil  // itens da locação

					If oMdlGer:GetModel('TFJ_REFER'):GetValue('TFJ_AGRUP') <> "1"
						DbSelectArea("ABS")
						DbSetOrder(1)
						If ABS->(DbSeek(xFilial("ABS")+oMdlLoc:GetValue('TFL_LOCAL')))
							If Empty(ABS->ABS_CLIFAT) .AND. Empty(ABS->ABS_LJFAT) .AND. ABS->ABS_ENTIDA == '1'
								lRet := .F.
								Help(,,'AT740CLIFAT',,STR0045,1,0) // "Os campos ABS_CLIFAT e ABS_LJFAT são necessarios o preenchimento devido o campo TFJ_AGRUP estar como Não"
								Exit
							EndIf
						EndIf
					EndIf

				EndIf
            EndIf
		Next nLinGrd  // locais de atendimento
		EndIf
	EndIf
EndIf


If lRet
	lRet := At870DelIn(oMdlGer)
EndIf

If Valtype(lRet) == "U"
	lRet := .T.
EndIf

If lRet .And. isInCallStack("At870Revis") .OR. IsInCallStack("AT870PlaRe")
	For nI := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine(nI)

		If !EMPTY(oModTFJ:GetValue("TFJ_GRPMI"))

			If TecSumInMdl(oMdlLoc, oModTFJ, oModTFJ:GetValue("TFJ_GRPMI")) <= 0
				If TecMedPrd(oModTFJ:GetValue("TFJ_CONTRT"),;
								 oModTFJ:GetValue("TFJ_CONREV"),;
								 oMdlLoc:GetValue("TFL_PLAN"),;
								 oModTFJ:GetValue("TFJ_GRPMI")) > 0

					lRet := .F.
					Help(,,'AT740DELMI',,STR0185,1,0) //"A operação de exclusão de Materias de Implantação não pode ser realizada pois já existem medições para o produto relacionado."
					Exit
				EndIf
			EndIf
		EndIf

		If !EMPTY(oModTFJ:GetValue("TFJ_GRPMC"))

			If TecSumInMdl(oMdlLoc, oModTFJ, oModTFJ:GetValue("TFJ_GRPMC")) <= 0
				If TecMedPrd(oModTFJ:GetValue("TFJ_CONTRT"),;
								 oModTFJ:GetValue("TFJ_CONREV"),;
								 oMdlLoc:GetValue("TFL_PLAN"),;
								 oModTFJ:GetValue("TFJ_GRPMC")) > 0

					lRet := .F.
					Help(,,'AT740DELMC',, STR0186,1,0) //"A operação de exclusão de Materias de Consumo não pode ser realizada pois já existem medições para o produto relacionado."
					Exit
				EndIf
			EndIf
		EndIf

	Next
EndIf

If lOrcPrc .and. lRet .and. aScan( At740FORC(), { |x| x[1] == Replicate( " ", 30 ) } ) > 0// verificar se tiver imposto
	For nI := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine( nI )
		If !oMdlLoc:IsDeleted()
		   For nJ:=1 To oMdlRH:Length()
		   		oMdlRH:GoLine(nJ)
		   		If !oMdlRh:IsDeleted() .AND. Empty(oMdlRh:GetValue("TFF_PRODUT"))
		   			lRet := MsgYesNo(STR0207 )// Orçamento gerado sem itens de RH, os impostos serão desconsiderados, deseja continuar?
		   			lExit := .T.
		   			Exit
		   		EndIf
	       Next nJ
	    EndIf
	    If lExit
	    	Exit
	    EndIf
	Next nI
EndIf

//Verifica se existem TFF apagada para deletar os vinculos de benefícios:
If lRet .AND. !lOrcPrc
	For nI := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine( nI )
		For nJ:=1 To oMdlRH:Length()
			oMdlRH:GoLine(nJ)
			If oMdlRh:IsDeleted() .Or. oMdlLoc:IsDeleted()
				//Exclui Vinculo de Beneficios
				AT352TDX(oMdlGer,,.T.)
			EndIf
		Next nJ
	Next nI
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

/*/{Protheus.doc} At740VlrMts
	Valida o preenchimento de valores nos grids de materiais
@since 		05/12/2016
@version 	12.15
@param 		oModMat, Objeto FwFormGridModel, modelo de dados de algum dos materiais (implantação ou consumo) do orçamento de serviços
@param 		cTab, caracter, tabela a ser validada e que pertence ao modelo
@return 		Lógico, indica se o processamento aconteceu ou não com sucesso
/*/
Static Function At740VlrMts( oModMat, cTab, lPermLocZero, nTotLocal )
Local lRet := .T.
Local nK := 0

Default lPermLocZero := .F.
Default nTotLocal	:= 0

For nK := 1 To oModMat:Length()
	oModMat:GoLine(nK)
	If ! oModMat:IsDeleted() .And. ! Empty(oModMat:GetValue(cTab+'_PRODUT'))
		nPrcVenda	:= oModMat:GetValue(cTab+"_PRCVEN")
		If nPrcVenda < 0
			Help(,,"At740TdOk",,STR0115,1,0) //"O valor do preço de venda do material de implantação não pode ser negativo."
			lRet := .F.
			EXIT
		EndIf
		lCobrContr := (oModMat:GetValue(cTab+"_COBCTR") <> "2")
		If nPrcVenda == 0 .And. lCobrContr .And. !IsInCallStack("LoadXmlData") .And. !lPermLocZero .AND. nTotLocal == 0
			Help(,,"At740TdOk",,STR0116,1,0) // "O valor do preço de venda do material de implantação deve ser maior do que zeros."
			lRet	:= .F.
			EXIT
		EndIf
	EndIf
Next nK

Return lRet

/*/{Protheus.doc} At740ExbIt
Exibe Itens em tela
@since 17/07/2015
@version 1.0
@param aItens, array, (Descrição do parâmetro)
@return lRet, Indica confirmação ou cancelamento
/*/
Static Function At740ExbIt(aItens)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local aSize	:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local lRet 	:= .T.
Local cTexto 	:= ""
Local nI 		:= 1
Local cLocOld := ""
Local cTitItem := STR0074//ITEM

//Monta texto a ser apresentado
cTexto := UPPER(STR0072) + CRLF

For nI:=1 To Len(aItens)

	If cLocOld != aItens[nI][1]
		cTexto += CRLF + aItens[nI][1] + " - " + aItens[nI][2] + CRLF//Local de Atendimento
	EndIf
	cTexto += cTitItem+": "+aItens[nI][3]+" - "//Item
	cTexto += aItens[nI][4]+ " - "+aItens[nI][5]+CRLF//Produto

	cLocOld := aItens[nI][1]

Next nI

DEFINE DIALOG oDlg TITLE STR0073 FROM 0,0 TO 285, 540 PIXEL

@ 000, 000 MsPanel oTop Of oDlg Size 000, 200 // Coordenada para o panel
oTop:Align := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

@ 5, 5 Get oMemo Var cTexto Memo Size 260, 100  Of oTop Pixel When .F.
oMemo:bRClicked := { || AllwaysTrue() }

Define SButton From 115, 230 Type  1 Action (lRet := .T., oDlg:End()) Enable Of oTop Pixel // OK
Define SButton From 115, 195 Type  2 Action (lRet := .F., oDlg:End()) Enable Of oTop Pixel // Cancelar

ACTIVATE DIALOG oDlg CENTERED

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740BlTot
	Validação da edição do campo preço de venda de recursos humanos

@sample 	At740BlTot

@since		24/10/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740BlTot(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lBloq := SuperGetMv("MV_ATBLTOT",,.F.)
Local lRet	:= .T.

If lBloq .And. !Empty(oModel:GetValue("TFF_CALCMD"))
	lRet	:= .F.
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet


/*/{Protheus.doc} At740QtdVen

@since 31/10/2013
@version 11.9

@return lRet, regra para when do campo TFI_QTDVEN

@description
Função com regras para WHEN do campo TFI_QTDVEN

/*/
Function At740QtdVen()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet := .T.

If IsInCallStack("TECA870")
	lRet := .F.
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740CpCal
	Copiar a planilha de preço do item posicionado

@sample 	At740CpCal

@since		11/11/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740CpCal(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdlRh := oModel:GetModel("TFF_RH")
Local lOk := .T.

If isInCallStack("At870GerOrc")
	If oMdlRh:GetValue("TFF_COBCTR") != "2"
		//Manipular Planilha de item cobrado dentro da rotina de Item Extra
		lOk := .F.
		Help(,, "CpCalCOBCTR1",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
	EndIf
Else
	If oMdlRh:GetValue("TFF_COBCTR") == "2"
		//Manipular Planilha de item não-cobrado fora da rotina de Item Extra
		lOk := .F.
		Help(,, "CpCalCOBCTR2",,STR0195,1,0,,,,,,{STR0196})//"Não é possível modificar itens que não são cobrados no contrato nesta rotina" ## "Para alterar este item, acesse a opção Item Extra dentro da Gestão dos Contratos (TECA870)"
	EndIf
EndIf

If lOk
	cXmlCalculo := oMdlRh:GetValue("TFF_CALCMD")
	aPlanData := { oMdlRh:GetValue("TFF_PLACOD"), oMdlRh:GetValue("TFF_PLAREV") }

	FWRestRows( aSaveLines )
	RestArea(aArea)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ClCal
	Colar a planilha de preço e executar cálculo no item posicionado.

@sample 	At740ClCal

@since		11/11/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740ClCal(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdlRh		:= oModel:GetModel("TFF_RH")
Local cPreco		:= ""
Local nTotPlan		:= 0
Local nTotRh		:= 0
Local nPLucro		:= 0
Local lOk 			:= .T.
Local lCpoCustom	:= ExistBlock('A998CPOUSR')
Local lPLucro		:= TFF->( ColumnPos('TFF_PLUCRO') ) > 0
Local lFacilit		:= SuperGetMv("MV_GSITORC",,"2") == "1"

If isInCallStack("At870GerOrc")
	If oMdlRh:GetValue("TFF_COBCTR") != "2"
		//Manipular Planilha de item cobrado dentro da rotina de Item Extra
		lOk := .F.
		Help(,, "ClCalCOBCTR1",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
	EndIf
Else
	If oMdlRh:GetValue("TFF_COBCTR") == "2"
		//Manipular Planilha de item não-cobrado fora da rotina de Item Extra
		lOk := .F.
		Help(,, "ClCalCOBCTR2",,STR0195,1,0,,,,,,{STR0196})//"Não é possível modificar itens que não são cobrados no contrato nesta rotina" ## "Para alterar este item, acesse a opção Item Extra dentro da Gestão dos Contratos (TECA870)"
	EndIf
EndIf

If lOk
	If !Empty(cXmlCalculo)
		oFWSheet := FWUIWorkSheet():New(,.F. ) //instancia a planilha sem exibição

		If MethIsMemberOf(oFWSheet,"ShowAllErr")
			oFWSheet:ShowAllErr(.F.)
		EndIf

		If isBlind()
			oFwSheet:LoadXmlModel(cXmlCalculo)
		Else
			FwMsgRun(Nil,{|| oFwSheet:LoadXmlModel(cXmlCalculo)}, Nil, STR0252) //"Carregando..."
		EndIf
		If lFacilit
			If oFwSheet:CellExists("TOTAL_CUSTOS")
				cPreco := oFwSheet:GetCellValue("TOTAL_CUSTOS")
			ElseIf oFwSheet:CellExists("TOTAL_CUSTO")
				nTotRh := oFwSheet:GetCellValue("TOTAL_CUSTO")
			EndIf
			If oFWSheet:CellExists("TOTAL_BRUTO")
				nTotPlan := oFwSheet:GetCellValue("TOTAL_BRUTO")
			Endif
			If lPLucro .AND. oFWSheet:CellExists("TX_LR")
				nPLucro := oFwSheet:GetCellValue("TX_LR")
			EndIf
		Else
			If oFwSheet:CellExists("TOTAL_RH")
				cPreco := oFwSheet:GetCellValue("TOTAL_RH")
			EndIf
		Endif
		If oMdlRh:GetOperation() <> MODEL_OPERATION_VIEW
			nTotRh   := at998Val(nTotRh)
			nTotPlan := at998Val(nTotPlan)
			nPLucro  := at998Val(nPLucro)
			
			oMdlRh:SetValue("TFF_CALCMD",cXmlCalculo)

			If Len(aPlanData) >= 2  // caso seja necessário copiar mais dados tvz seja melhor guardar a linha original da cópia
				oMdlRh:SetValue("TFF_PLACOD", aPlanData[1])
				oMdlRh:SetValue("TFF_PLAREV", aPlanData[2])
			EndIf
			oMdlRh:SetValue("TFF_PRCVEN",ROUND(nTotRh, TamSX3("TFF_PRCVEN")[2]))
			oMdlRh:SetValue("TFF_TOTPLA",Round(nTotPlan, TamSX3("TFF_TOTPLA")[2]))
			If lPLucro
				oMdlRh:LoadValue("TFF_PLUCRO",Round(nPLucro, TamSX3("TFF_PLUCRO")[2]))
			EndIf
			If lCpoCustom
				ExecBlock('A998CPOUSR', .F., .F., {oMdlRh,oFwSheet} )
			EndIf
		EndIf
	Else
		Aviso(STR0035, STR0036, {STR0037}, 2)	//"Atenção!"#"Para utilizar o botão Colar Cálculo, necessário posicionar no item de recursos humanos que tenha formação de preço"{"OK"}
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740LeTot
	Função para cálculo do desconto e valor total dos itens da locação

@sample 	At740LeTot( cTipoCalc )

@since		10/12/2013
@version	P11.90

@param 		cTipoCalc, Char, Define o formato do cálculo retornado o valor total ou o valor do desconto
				'1' = deve retornar o valor Total
				'2' = deve retornar o valor de desconto
@return 	nValor, Numeric, valor para atribuição no campo
/*/
//------------------------------------------------------------------------------
Function At740LeTot( cTipoCalc )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdlAtivo := FwModelActive()
Local nValor    := 0

Default cTipoCalc := '1'

If oMdlAtivo <> Nil .And. (oMdlAtivo:GetId()=='TECA740' .Or. oMdlAtivo:GetId()=='TECA740F')

	If oMdlAtivo:GetModel('CALC_TEV') <> Nil
		nValor := oMdlAtivo:GetModel('CALC_TEV'):GetValue('TOT_ADICIO')
	Else
		nValor := IterTev( oMdlAtivo:GetModel('TEV_ADICIO') )
	EndIf

	If cTipoCalc == '2'
		nValor := ( nValor )*(oMdlAtivo:GetModel('TFI_LE'):GetValue('TFI_DESCON')/100)
	Else
		nValor := ( nValor )*(1-(oMdlAtivo:GetModel('TFI_LE'):GetValue('TFI_DESCON')/100))
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} IterTev
	Soma os valores da TEV na definição de cobrança da locação

@sample 	IterTev( cTipoCalc )

@since		10/12/2013
@version	P11.90

@param 		oMdlTEV, Object, Model com as informações da cobrança da locação

@return 	nValor, Numeric, valor para atribuição no campo
/*/
//------------------------------------------------------------------------------
Function IterTev( oMdlTEV )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local nValTev := 0
Local nLinhas := 0
Local nLinTev := oMdlTEV:GetLine()

For nLinhas := 1 To oMdlTEV:Length()

	oMdlTEV:GoLine( nLinhas )
	// não considera linhas deletadas e com o modo de cobrança como 5-Franquia/Excedente
	If !oMdlTEV:IsDeleted() .And. oMdlTEV:GetValue('TEV_MODCOB') <> "5"
		nValTev += oMdlTEV:GetValue('TEV_VLTOT')
	EndIf

Next nLinhas

oMdlTev:GoLine( nLinTev )

FWRestRows( aSaveLines )
RestArea(aArea)
Return nValTEV

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLin[Tab]
	Executa a atualização dos valores quando excluída linha de grid que replica informação
a grids superiores

@sample 	PreLinTEV(oMdlG, nLine, cAcao, cCampo)

@since		11/12/2013
@version	P11.90

@param 		oMdlGrid, Objeto, objeto do grid em validação
@param 		nLine, Numerico, linha em ação
@param 		cAcao, Caracter, tipo da ação (DELETE, UNDELETE, etc)
@param 		cCampo, Caracter, campo da ação

@return 	lOk, Logico, permite ou não a atualização
/*/
//------------------------------------------------------------------------------
Function PreLinTEV(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lOk      := .T.
Local oMdlFull := oMdlG:GetModel()
Local nValDel  := 0
Local nTotAtual := 0
Local nTotDesc := 0
Local oMdlUse  := Nil
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local nAux := 0
Local cLiberados := "TEV_VLRUNI|TEV_QTDE|TEV_SUBTOT|TEV_VLTOT|TEV_TXLUCR|TEV_LUCRO|TEV_ADM|TEV_TXADM"
Local cControle := "TEV_SUBTOT|TEV_VLTOT"

FWModelActive(oMdlG)//seta o model

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	// só realiza a atualização dos valores quando o modo de cobrança for diferente de
	// 5-Franquia/Excedente
	If cAcao == 'SETVALUE' .and. !isInCallStack("at870eftrv")
		If !isInCallStack("FillModel") .AND. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )
			If oMdlFull:GetModel('TFI_LE'):GetValue('TFI_ENCE') == '1' .Or. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
				If UPPER(cCampo) $ cLiberados
					If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TEV" .AND.;
															s[2] == (oMdlFull:GetModel('TFI_LE'):GetValue("TFI_COD") + oMdlG:GetValue('TEV_ITEM')) .AND.;
															s[3] == oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO') .AND.;
															s[4] == cCampo }) ) > 0
						If aEnceCpos[nAux][5] < xValue
							lOk		 := .F.
							Help( ,, 'PreLinTEV',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
						EndIf
					ElseIf UPPER(cCampo) $ cControle
						If xValue > xOldValue
							lOk		 := .F.
							Help( ,, 'PreLinTEV',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
						Else
							AADD(aEnceCpos , {"TEV",(oMdlFull:GetModel('TFI_LE'):GetValue("TFI_COD") + oMdlG:GetValue('TEV_ITEM')),oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO'),cCampo,xOldValue} )
						EndIf
					EndIf
				Else
					lOk		 := .F.
					Help( ,, 'PreLinTEV',, STR0149, 1, 0 ) //"Não é possível editar esse registro, pois o item de locação ou o local de atendimento estão finalizados"
				EndIf
			EndIf
		EndIf
	ElseIf cAcao == 'DELETE' .and. !Empty(oMdlG:getValue("TEV_MODCOB"))
		If oMdlFull:GetModel('TFI_LE'):GetValue('TFI_ENCE') == '1' .Or. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
			lOk := .F.
			Help( ,, 'PreLinTEV',, STR0149, 1, 0 ) //"Não é possível editar esse registro, pois o item de locação ou o local de atendimento estão finalizados"
		Else
			If oMdlG:GetValue('TEV_MODCOB') <> '5'

				//Valida se a linha pode ser deletada na Revisao de Contrato
				oMdlUse := oMdlFull:GetModel('TFI_LE')
				If IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe")
					lOk := !At740ExTEV(oMdlUse:GetValue('TFI_COD'),oMdlG:GetValue('TEV_ITEM'),oMdlG:IsInserted())

					If !lOk
						Help( ,, 'PreLinTEV',, STR0151, 1, 0 ) 	//Não é possível excluir esse item.
					EndIf
				EndIf

				//  Atualiza o item da locação vinculado
				If lOk
					nValDel := oMdlG:GetValue('TEV_VLTOT')
					nTotAtual := ( oMdlUse:GetValue('TFI_TOTAL') + oMdlUse:GetValue('TFI_VALDES') )
					nTotAtual -= nValDel

					nTotDesc := ( nTotAtual * ( oMdlUse:GetValue('TFI_DESCON')/100 ) )
					nTotAtual := ( nTotAtual * ( 1- ( oMdlUse:GetValue('TFI_DESCON')/100 ) ) )

					lOk := oMdlUse:SetValue('TFI_TOTAL', nTotAtual )
					lOk := oMdlUse:SetValue('TFI_VALDES', nTotDesc )
				EndIf
			EndIf
		EndIf
		ElseIf cAcao == 'UNDELETE'
			If oMdlG:GetValue('TEV_MODCOB') <> '5'
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				oMdlUse := oMdlFull:GetModel('TFI_LE')

				nValDel := oMdlG:GetValue('TEV_VLTOT')
				nTotAtual := ( oMdlUse:GetValue('TFI_TOTAL') + oMdlUse:GetValue('TFI_VALDES') )
				nTotAtual += nValDel

				nTotDesc := ( nTotAtual * ( oMdlUse:GetValue('TFI_DESCON')/100 ) )
				nTotAtual := ( nTotAtual * ( 1 - ( oMdlUse:GetValue('TFI_DESCON')/100 ) ) )

				lOk := oMdlUse:SetValue('TFI_TOTAL', nTotAtual )
				lOk := oMdlUse:SetValue('TFI_VALDES', nTotDesc )
			EndIf

		EndIf
	EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk

//-----------------------------------------------
// atualização de exclusão da TFI
Function PreLinTFI(oMdlG, nLine, cAcao, cCampo)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lOk      := .T.
Local oMdlFull := FwModelActive()
Local nValDel  := 0
Local nTotAtual := 0
Local oMdlUse  := Nil
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')

	If cAcao == 'SETVALUE' .and. !isInCallStack("at870eftrv") .And. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )
		If ( oMdlG:GetValue('TFI_ENCE') == '1' .Or. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1' ) .And. !isInCallStack("FillModel") .And.;
			UPPER(cCampo) $ UPPER("tfi_tpcobr|tfi_perini|tfi_perfim|tfi_horain|tfi_horafi|tfi_descon|tfi_tes|tfi_enteqp|tfi_coleqp|tfi_apumed|tfi_osmont")

			lOk := .F.
			Help( ,, 'PreLinTFI',, STR0149, 1, 0 ) //"Não é possível editar esse registro, pois o item de locação ou o local de atendimento estão finalizados"
		EndIf
	ElseIf cAcao == 'DELETE'

		If (oMdlG:GetValue('TFI_ENCE') == '1' .Or. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1')

			lOk := .F.
			Help( ,, 'PreLinTFI',, STR0149, 1, 0 ) //"Não é possível editar esse registro, pois o item de locação ou o local de atendimento estão finalizados"

		Else
			If lOk .And. !Empty(oMdlG:GetValue('TFI_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFI_PRODUT'))
				lOk := .F.
				Help(,,'A740TFITWOD',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
			EndIf

			//Valida se a linha pode ser deletada na Revisao
			If IsIncallStack('At870Revis')
				lOk := !At740ExtIt('TFI', oMdlG:GetValue('TFI_COD'), 'TFI_CONTRT', oMdlG:IsInserted())

				If !lOk
					Help(,,'A740TFITWOD',, STR0151,1,0) //Não é possível excluir esse item.
				EndIf
			EndIf
			If lOk
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				oMdlUse := oMdlFull:GetModel('TFL_LOC')

				nValDel := oMdlG:GetValue('TFI_TOTAL')
				nTotAtual := oMdlUse:GetValue('TFL_TOTLE')
				nTotAtual -= nValDel

				lOk := oMdlUse:SetValue('TFL_TOTLE', nTotAtual )
			EndIf
		EndIf
	ElseIf cAcao == 'UNDELETE'

		//-----------------------------------------------
		//  Atualiza o item da locação vinculado
		oMdlUse := oMdlFull:GetModel('TFL_LOC')

		nValDel := oMdlG:GetValue('TFI_TOTAL')
		nTotAtual := oMdlUse:GetValue('TFL_TOTLE')
		nTotAtual += nValDel

		lOk := oMdlUse:SetValue('TFL_TOTLE', nTotAtual )

		If lOk .And. !Empty(oMdlG:GetValue('TFI_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFI_PRODUT'))
			lOk := .F.
			Help(,,'A740TFITWOH',, STR0101,1,0)	//"Item não pode ser habilitado, pois o mesmo foi adicionado pelo facilitador"
		EndIf

	EndIf
EndIf

Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFG
	Função de Prevalidacao da grade de Materiais de Implantação
@sample 	PreLinTFG(oMdlG, nLine, cAcao, cCampo, xValue, xOldValueo)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValue],Indefinido,Novo valor inserido no campo.
@param		[xOldValue],Indefinido,Antigo valor do campo.

@since		17/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function PreLinTFG(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea := GetArea()
Local aSaveLines := FWSaveRows()
Local lOk       := .T.
Local oMdlFull  := oMdlG:GetModel()
Local nValDel   := 0
Local nTotAtual := 0
local nValorPrd := 0
local nLineTFG  := 0
Local oMdlUse   := Nil
Local lHelp     := .T.
Local lInclui   := oMdlFull:GetOperation() == MODEL_OPERATION_INSERT
Local nAux      := 0
Local cControle := "TFG_TOTAL|TFG_TOTGER"
Local cLiberados := "TFG_QTDVEN|TFG_TOTAL|TFG_VALDES|TFG_TOTGER|TFG_TXLUCR|TFG_TXADM|TFG_PRCVEN|TFG_DESCON|TFG_ADM|TFG_LUCRO|TFG_VLRMESMI|TFG_DPRMES|TFG_VLPRPA"
Local lDesagrp  := oMdlFull:GetValue("TFJ_REFER","TFJ_DSGCN") == '1'
Local lUpdGrid  := .T. //Indica se o grid pode ser atualizado - CanUpdateLine()
Local lCodTWO   := TFG->( ColumnPos('TFG_CODTWO') ) > 0

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F') .AND. !lTEC740FUn
	cModelId	:= oMdlFull:GetId()
	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND.!(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl(TFJ->TFJ_CODIGO) .AND. AT870ItPla( oMdlG:GetValue("TFG_COD"), "TFG" )
		lOk := .F.
		lHelp	:= .F.
		Help(,,'PreLinTFG',, STR0298,1,0) // "Não é possivel alterar itens de uma Manutenção Planejada em uma revisão!."
	EndIf
	If isInCallStack("At870GerOrc")
		If cAcao $ "DELETE|SETVALUE" .AND. oMdlG:GetValue('TFG_COBCTR') != "2"
			lOk := .F.
			lHelp := .F.
			Help(,, "TFGNAOEXTRA",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
		EndIf

		If cAcao == "DELETE" .AND. oMdlG:GetValue("TFG_COBCTR") == "2" .AND. Len(TecGetApnt(oMdlG:GetValue("TFG_COD"),"TFS")) > 0
			lOk := .F.
			lHelp := .F.
			Help( ,, 'DELMIAPT',, STR0194, 1, 0 ) //"Não é possível apagar item com Apontamento de Material registrado"
		EndIf

		If cCampo == "TFG_QTDVEN" .AND. cAcao == "SETVALUE" .AND. xOldValue > xValue .AND. !(oMdlG:isInserted()) .AND.;
		 		(oMdlG:GetValue("TFG_SLD") - (At740getQt(oMdlG:GetValue("TFG_COD"),"TFG") - xValue) < 0)
			lOk := .F.
			lHelp := .F.
			Help(,, "SALDOMI",,STR0197,1,0,,,,,,{STR0198}) //"Operação de decréscimo não permitida pois não há saldo suficiente." ## "Verifique na rotina de Apontamento de Materiais (TECA890) a quantidade já apontada para este recurso"
		EndIf
	Endif

	If lOk
		If cAcao == 'DELETE' .and. !Empty(oMdlG:GetValue("TFG_PRODUT"))
			If oMdlG:GetValue("TFG_COBCTR") <> "2"
				If lDesagrp .AND. !EMPTY(oMdlG:GetValue("TFG_ITCNB"))
					If TecMedPrd(oMdlFull:GetValue("TFJ_REFER","TFJ_CONTRT"),;
										oMdlFull:GetValue("TFJ_REFER","TFJ_CONREV"),;
										oMdlFull:GetValue("TFL_LOC","TFL_PLAN"),;
										oMdlG:GetValue("TFG_PRODUT"),;
										oMdlG:GetValue("TFG_ITCNB")) > 0
						lOk := .F.
						lHelp := .F.
						Help(,,'A740DELMI',, STR0187,1,0) //"Itens com medições não podem ser apagados."
					EndIf
				EndIf
			Else
				lOk := (IsInCallStack("A600GrvOrc") .Or. IsInCallStack("At870GerOrc") )
			EndIf

			If lOk .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") .OR. (FindFunction("AT870CtRev") .AND. AT870CtRev( oMdlFull:GetValue("TFJ_REFER", "TFJ_CODIGO") ) ))
				If lInclui .AND. (oMdlG:getValue("TFG_MODPLA") <> "1" .OR. ValidPlane( oMdlG:getValue("TFG_COD") , "TFG"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFG',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				ElseIf oMdlG:getValue("TFG_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFG_CODREL"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFG',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				EndIf
			EndIf

			If lOk .And. !Empty(oMdlG:GetValue('TFG_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFG_PRODUT')) .And. !IsInCallStack('At740VlGMat')
				If !lCodTWO
					lOk := .F.
					Help(,,'A740TFGTWOD',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
				EndIf
			EndIf
			If (cModelId == 'TECA740' .AND. (oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1')) .OR. ;
			   (cModelId == 'TECA740F' .AND. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1' )
			   lOK := .F.
			   lHelp := .F.
			   Help( ,, 'PreLinTFG',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
		   EndIf

			//Valida se a linha pode ser deletada na Revisao
			If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. lOk

				lOk := lOk .AND. !At740ExtIt('TFG', oMdlG:GetValue('TFG_COD'), 'TFG_CONTRT', oMdlG:IsInserted())

				If !lOk
					Help(,,'A740TFGTWOD',, STR0151,1,0) //Não é possível excluir esse item.
					lHelp := .F.
				EndIf
			EndIf

			If lOk .AND. oMdlG:GetValue('TFG_COBCTR') != "2"
				nLineTFG := oMdlG:GetLine()
				//-----------s------------------------------------
				//  Atualiza o item da locação vinculado
				If oMdlFull:GetId() == 'TECA740F'
					oMdlUse   := oMdlFull:GetModel('TFL_LOC')
					nValDel   := oMdlG:GetValue('TFG_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMI')
					nTotAtual -= nValDel
					lOk :=  lOk .AND. oMdlUse:SetValue('TFL_TOTMI', nTotAtual ) .Or. IsInCallStack('A740LoadFa')
				Else
					oMdlUse   := oMdlFull:GetModel('TFF_RH')
					nValDel   := oMdlG:GetValue('TFG_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFF_TOTMI')
					nTotAtual -= nValDel
					lOk := lOk .AND. oMdlUse:SetValue('TFF_TOTMI', nTotAtual ) .Or. (IsInCallStack('A740LoadFa') .Or. IsInCallStack('TEC740NFAC'))
				EndIf
				oMdlG:GoLine(nLineTFG)
			EndIf
			If lOk .AND. TecVlPrPar()
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")-oMdlG:GetValue("TFG_VLPRPA"))
			EndIf
		ElseIf cAcao == 'UNDELETE'
			If oMdlG:GetValue("TFG_COBCTR") <> "2"
				nLineTFG := oMdlG:GetLine()
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				If oMdlFull:GetId() == 'TECA740F'
					oMdlUse := oMdlFull:GetModel('TFL_LOC')

					nValDel := oMdlG:GetValue('TFG_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMI')
					nTotAtual += nValDel
					lOk := oMdlUse:SetValue('TFL_TOTMI', nTotAtual ) .Or. IsInCallStack('A740LoadFa')
				Else
					oMdlUse := oMdlFull:GetModel('TFF_RH')

					nValDel := oMdlG:GetValue('TFG_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFF_TOTMI')
					nTotAtual += nValDel
					lOk := oMdlUse:SetValue('TFF_TOTMI', nTotAtual ) .Or. IsInCallStack('A740LoadFa')
				EndIf
				oMdlG:GoLine(nLineTFG)
			Else
				lOk := IsInCallStack("At870GerOrc")
			EndIf

			If lOk .And. !Empty(oMdlG:GetValue('TFG_CHVTWO')) .And. !IsInCallStack('A740LoadFa');
				   .And. !Empty(oMdlG:GetValue('TFG_PRODUT')) .And. !IsInCallStack('At740VlGMat')
				If !lCodTWO
					lOk := .F.
					Help(,,'A740TFGTWOH',, STR0101,1,0)	//"Item não pode ser habilitado, pois o mesmo foi adicionado pelo facilitador"
				EndIf
			EndIf
			If lOk .AND. TecVlPrPar()
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")+oMdlG:GetValue("TFG_VLPRPA"))
			EndIf
		ElseIf cAcao == "SETVALUE"

			If !IsInCallStack("ATCPYDATA") .And.;
				!IsInCallStack("A600GrvOrc") .And. !IsInCallStack("At870GerOrc") .And.;
				!IsInCallStack("LoadXmlData")
				If !(cCampo $ "TFG_VLRMESMI")
					lOk := oMdlG:GetValue("TFG_COBCTR") != "2"
				EndIf
			EndIf
			If !isInCallStack("FillModel") .and. !isInCallStack("at870eftrv") .AND. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") ) .AND.;
					!IsInCallStack('At870GerOrc')
				If cModelId == 'TECA740'
					If oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						If UPPER(cCampo) $ cLiberados
							If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFG" .AND.;
																s[2] == oMdlG:GetValue('TFG_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD') .AND.;
																s[4] == cCampo }) ) > 0
								If aEnceCpos[nAux][5] < xValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFG',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								EndIf
							ElseIf UPPER(cCampo) $ cControle
								If xValue > xOldValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFG',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								Else
									AADD(aEnceCpos , {"TFG",oMdlG:GetValue('TFG_COD'),oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD'),cCampo,xOldValue} )
								EndIf
							ElseIf lDesagrp .And. (cCampo == 'TFG_PRCVEN')  .And. xValue == 0
								lOk		 := .F.
								lHelp 	 := .F.
								Help( ,, 'PreLinTFG',, STR0290, 1, 0 ) //"Não é possível zerar este item, pois o parâmetro MV_GSDSGCN está desagrupado"
							EndIf
						Else
							lOk := .F.
							lHelp := .F.
							Help( ,, 'PreLinTFG',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
						EndIf
					EndIf
				ElseIf cModelId == 'TECA740F'
					If oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						If UPPER(cCampo) $ cLiberados
							If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFG" .AND.;
																s[2] == oMdlG:GetValue('TFG_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO') .AND.;
																s[4] == cCampo }) ) > 0
								If aEnceCpos[nAux][5] < xValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFG',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								EndIf
							ElseIf UPPER(cCampo) $ cControle
								If xValue > xOldValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFG',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								Else
									AADD(aEnceCpos , {"TFG",oMdlG:GetValue('TFG_COD'),oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO'),cCampo,xOldValue} )
								EndIf
							EndIf
						Else
							lOk	:= .F.
							lHelp := .F.
							Help( ,, 'PreLinTFG',, STR0148, 1, 0 ) //"Não é possível editar esse registro, pois o local de atendimento está finalizado"
						EndIf
					EndIf
				EndIf
			EndIf
			If lOk .AND. TecVlPrPar()
				If cCampo == "TFG_VLPRPA" .AND. xValue != 0
					If oMdlG:GetValue('TFG_COBCTR') == '2'
						Help( ' ' , 1 , 'AT740PRPA' , , STR0265, 1 , 0 ) //"Não é possível informar este valor para itens extras."
						lOk 	:= .F.
						lHelp 	:= .F.
					ElseIf oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") != '1'
						Help( ' ' , 1 , 'AT740PRPA' , , STR0266, 1 , 0 ) //"Campo disponível apenas para contratos recorrentes."
						lOk 	:= .F.
						lHelp 	:= .F.
					EndIf
				EndIf
			EndIf
			If lOk .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .AND. !(cCampo $ "TFG_PERINI|TFG_PERFIM")
				aStruct  := oMdlG:GetStruct():GetFields()
				nPos := Ascan( aStruct, {|x| x[3] == cCampo })
				If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
					If !oMdlG:IsInserted() .AND. VldLineRvP( cCampo, xValue, IIF(Empty(oMdlG:getValue("TFG_CODREL")), oMdlG:getValue("TFG_COD"), oMdlG:getValue("TFG_CODREL")), "TFG", aStruct[nPos][4] == 'D' )
						oMdlG:LoadValue('TFG_MODPLA', "2")
					Else
						oMdlG:LoadValue('TFG_MODPLA', "1")
					EndIf
				EndIf
			EndIf
			If cCampo == 'TFG_PRCVEN' .AND. SuperGetMv("MV_ORCVLB1",,.F.)
				nValorPrd := POSICIONE("SB1",1,xFilial("SB1")+oMdlG:GetValue("TFG_PRODUT"),"B1_PRV1")
				If nValorPrd > 0 .AND. xValue < nValorPrd
					lOk		 := .F.
					lHelp 	 := .F.
					Help( ,, 'PreLinTFG',, "Não é Possivel diminuir o valor do produto uma vez que o mesmo tem valor de venda no cadastro de produto.", 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
				EndIf
			EndIf
		EndIf

		If "DELETE"$cAcao .and. !Empty(oMdlG:GetValue("TFG_PRODUT"))
			If oMdlG:GetValue("TFG_COBCTR") <> "2" .AND. lOk .AND. oMdlFull:GetId() == 'TECA740F'
				If cAcao == 'DELETE'

					/*Ao deletar a linha do Grid, atualiza o valor do campo TFG_VLRMESMI para 0, corrigindo os totalizadores*/
					lUpdGrid	:= oMdlG:CanUpdateLine() //Indica se o grid pode ser atualizado - CanUpdateLine()
					If !lUpdGrid
						oMdlG:SetNoUpdateLine(.F.)
					EndIf
					oMdlG:SetValue('TFG_VLRMESMI',0)
					If !lUpdGrid
						oMdlG:SetNoUpdateLine(.T.)
					EndIf
				ElseIf cAcao == 'UNDELETE' .And. oMdlG:isDeleted()
					/*Ao recuperar a linha do Grid, atualiza o valor do campo TFG_VLRMESMI para o seu valor original, corrigindo os totalizadores*/
					lTEC740FUn := .T.
					oMdlG:UnDeleteLine() //Necessário fazer UNDELETE para o SetValue ocorrer. A variavel lTEC740FUn garante que esse UNDELETE não passe pelo PréValid
					oMdlG:SetValue('TFG_VLRMESMI',At740FTGMes( "TFG_MI", "TFG_PERINI", "TFG_PERFIM", "TFG_TOTGER" ))
					oMdlG:DeleteLine() //Volta a linha para o seu estado original, para que a cAcao de UNDELETE ocorra normalmente
					lTEC740FUn := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !lOk .AND. lHelp
	Help(,,"AT740OK",,STR0046,1,0) // "Operação não permitida para os itens adicionais!"
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFH
	Função de Prevalidacao da grade de Materiais de Consumo
@sample 	PreLinTFH(oMdlG, nLine, cAcao, cCampo, xValue, xOldValueo)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValue],Indefinido,Novo valor inserido no campo.
@param		[xOldValue],Indefinido,Antigo valor do campo.

@since		17/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function PreLinTFH(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea := GetArea()
Local aSaveLines := FWSaveRows()
Local lOk       := .T.
Local oMdlFull  := oMdlG:GetModel()
Local nValDel   := 0
Local nTotAtual := 0
Local nValorPrd	:= 0
Local nLineTFH  := 0
Local oMdlUse   := Nil
Local lInclui	:= oMdlFull:GetOperation() == MODEL_OPERATION_INSERT
Local cModelId  := ""
Local lHelp     := .T.
Local nAux      := 0
Local cControle := "TFH_TOTAL|TFH_TOTGER"
Local cLiberados := "TFH_QTDVEN|TFH_TOTAL|TFH_VALDES|TFH_TOTGER|TFH_TXLUCR|TFH_TXADM|TFH_PRCVEN|TFH_DESCON|TFH_ADM|TFH_LUCRO|TFH_VLRMESMC|TFH_DPRMES|TFH_VLPRPA"
Local lDesagrp  := oMdlFull:GetValue("TFJ_REFER","TFJ_DSGCN") == '1'
Local lUpdGrid  := .T. //Grid pode ser atualizado
Local lCodTWO   := TFH->( ColumnPos('TFH_CODTWO') ) > 0

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F') .AND. !lTEC740FUn
	cModelId	:= oMdlFull:GetId()

	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND.!(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl(TFJ->TFJ_CODIGO) .AND. AT870ItPla( oMdlG:GetValue("TFH_COD"), "TFH" )
		lOk := .F.
		lHelp	:= .F.
		Help(,,'PreLinTFH',, STR0298,1,0) // "Não é possivel alterar itens de uma Manutenção Planejada em uma revisão!."
	EndIf

	If isInCallStack("At870GerOrc")
		If cAcao $ "DELETE|SETVALUE" .AND. oMdlG:GetValue('TFH_COBCTR') != "2"
			lOk := .F.
			lHelp := .F.
			Help(,, "TFHNAOEXTRA",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
		EndIf

		If cAcao == "DELETE" .AND. oMdlG:GetValue("TFH_COBCTR") == "2" .AND. Len(TecGetApnt(oMdlG:GetValue("TFH_COD"),"TFT")) > 0
			lOk := .F.
			lHelp := .F.
			Help( ,, 'DELMCAPT',, STR0194, 1, 0 ) //"Não é possível apagar item com Apontamento de Material registrado"
		EndIf

		If cCampo == "TFH_QTDVEN" .AND. cAcao == "SETVALUE" .AND. xOldValue > xValue .AND. !(oMdlG:isInserted()) .AND.;
		 		(oMdlG:GetValue("TFH_SLD") - (At740getQt(oMdlG:GetValue("TFH_COD"),"TFH") - xValue) < 0)
			lOk := .F.
			lHelp := .F.
			Help(,, "SALDOMC",,STR0197,1,0,,,,,,{STR0198}) //"Operação de decréscimo não permitida pois não há saldo suficiente." ## "Verifique na rotina de Apontamento de Materiais (TECA890) a quantidade já apontada para este recurso"
		EndIf

	Endif

	If lOk
		If cAcao == 'DELETE'.and. !Empty(oMdlG:GetValue("TFH_PRODUT"))
			If isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") .OR. ( FindFunction("AT870CtRev") .AND. AT870CtRev( oMdlFull:GetValue("TFJ_REFER", "TFJ_CODIGO")) )
				If lInclui .AND. (oMdlG:getValue("TFH_MODPLA") <> "1" .OR. ValidPlane( oMdlG:getValue("TFH_COD") , "TFH"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFH',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				ElseIf oMdlG:getValue("TFH_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFH_CODREL"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFH',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				EndIf
			EndIf

			If oMdlG:GetValue("TFH_COBCTR") <> "2"
				If lDesagrp .AND. !EMPTY(oMdlG:GetValue("TFH_ITCNB"))
					If TecMedPrd(oMdlFull:GetValue("TFJ_REFER","TFJ_CONTRT"),;
										oMdlFull:GetValue("TFJ_REFER","TFJ_CONREV"),;
										oMdlFull:GetValue("TFL_LOC","TFL_PLAN"),;
										oMdlG:GetValue("TFH_PRODUT"),;
										oMdlG:GetValue("TFH_ITCNB")) > 0
						lOk := .F.
						lHelp := .F.
						Help(,,'A740DELMC',, STR0187,1,0) //"Itens com medições não podem ser apagados."
					EndIf
				EndIf
			Else
				lOk := IsInCallStack("A600GrvOrc") .Or.;
				 		IsInCallStack('A740LoadFa') .OR. IsInCallStack("At870GerOrc")
			EndIf

			If lOk .And. !Empty(oMdlG:GetValue('TFH_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFH_PRODUT')) .And. !IsInCallStack('At740VlGMat')
				If !lCodTWO
					lOk := .F.
					Help(,,'A740TFHTWOD',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
				EndIf
			EndIf

			//Valida se a linha pode ser deletada na Revisao
			If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. lOk
				lOk := lOk .AND. !At740ExtIt('TFH', oMdlG:GetValue('TFH_COD'), 'TFH_CONTRT', oMdlG:IsInserted())

				If !lOk
					Help(,,'A740TFHTWOD',, STR0151,1,0) //Não é possível excluir esse item.
					lHelp := .F.
				EndIf
			EndIf

			If lOk .AND. oMdlG:GetValue("TFH_COBCTR") <> "2"
				nLineTFH := oMdlG:GetLine()
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				If oMdlFull:GetId() == 'TECA740F'
					oMdlUse   := oMdlFull:GetModel('TFL_LOC')
					nValDel   := oMdlG:GetValue('TFH_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMC')
					nTotAtual -= nValDel
					lOk	:= oMdlUse:SetValue('TFL_TOTMC', nTotAtual ) .Or. IsInCallStack('A740LoadFa')
				Else
					oMdlUse   := oMdlFull:GetModel('TFF_RH')
					nValDel   := oMdlG:GetValue('TFH_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFF_TOTMC')
					nTotAtual -= nValDel
					lOk	:= oMdlUse:SetValue('TFF_TOTMC', nTotAtual ) .Or. (IsInCallStack('A740LoadFa') .Or. IsInCallStack('TEC740NFAC'))
				EndIf
				oMdlG:GoLine(nLineTFH)
			EndIf
			If lOk .AND. TecVlPrPar()
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")-oMdlG:GetValue("TFH_VLPRPA"))
			EndIf
		ElseIf cAcao == 'UNDELETE'

			If oMdlG:GetValue("TFH_COBCTR") <> "2"
				nLineTFH := oMdlG:GetLine()
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				If oMdlFull:GetId() == 'TECA740F'
					oMdlUse   := oMdlFull:GetModel('TFL_LOC')
					nValDel   := oMdlG:GetValue('TFH_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMC')
					nTotAtual += nValDel
					lOk := oMdlUse:SetValue('TFL_TOTMC', nTotAtual )
				Else
					oMdlUse   := oMdlFull:GetModel('TFF_RH')
					nValDel   := oMdlG:GetValue('TFH_TOTGER')
					nTotAtual := oMdlUse:GetValue('TFF_TOTMC')
					nTotAtual += nValDel
					lOk := oMdlUse:SetValue('TFF_TOTMC', nTotAtual )
				EndIf
				oMdlG:GoLine(nLineTFH)
			Else
				lOk :=  isInCallStack("At870GerOrc")
			EndIf

			If lOk .And. !Empty(oMdlG:GetValue('TFH_CHVTWO')) .And. !IsInCallStack('A740LoadFa');
				   .And. !Empty(oMdlG:GetValue('TFH_PRODUT')) .And. !IsInCallStack('At740VlGMat')
				If !lCodTWO
					lOk := .F.
					Help(,,'A740TFHTWOH',, STR0101,1,0)	//"Item não pode ser habilitado, pois o mesmo foi adicionado pelo facilitador"
				EndIf
			EndIf
			If lOk .AND. TecVlPrPar()
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")+oMdlG:GetValue("TFH_VLPRPA"))
			EndIf
		ElseIf cAcao == "SETVALUE"

			If !IsInCallStack("ATCPYDATA") .And.;
				!IsInCallStack("A600GrvOrc") .And. !IsInCallStack("At870GerOrc") .And.;
				!IsInCallStack("LoadXmlData")
				If !(cCampo $ "TFH_VLRMESMC")
					lOk := oMdlG:GetValue("TFH_COBCTR") != "2"
				EndIf
			EndIf

			If !isInCallStack("FillModel") .and. !isInCallStack("at870eftrv") .AND. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") ) .AND.;
					 !IsInCallStack('At870GerOrc')
				If cModelId == 'TECA740'
					If oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						If UPPER(cCampo) $ cLiberados
							If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFH" .AND.;
																s[2] == oMdlG:GetValue('TFH_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD') .AND.;
																s[4] == cCampo }) ) > 0
								If aEnceCpos[nAux][5] < xValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFH',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								EndIf
							ElseIf UPPER(cCampo) $ cControle
								If xValue > xOldValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFH',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								Else
									AADD(aEnceCpos , {"TFH",oMdlG:GetValue('TFH_COD'),oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD'),cCampo,xOldValue} )
								EndIf
							ElseIf lDesagrp .And. (cCampo == 'TFH_PRCVEN')  .And. xValue == 0
								lOk		 := .F.
								lHelp 	 := .F.
								Help( ,, 'PreLinTFH',, STR0290, 1, 0 ) //"Não é possível zerar este item, pois o parâmetro MV_GSDSGCN está desagrupado"
							EndIf
						Else
							lOk := .F.
							lHelp := .F.
							Help( ,, 'PreLinTFH',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
						EndIf
					EndIf
				ElseIf cModelId == 'TECA740F'
					If  oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						If UPPER(cCampo) $ cLiberados
							If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFH" .AND.;
																s[2] == oMdlG:GetValue('TFH_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO') .AND.;
																s[4] == cCampo }) ) > 0
								If aEnceCpos[nAux][5] < xValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFH',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								EndIf
							ElseIf UPPER(cCampo) $ cControle
								If xValue > xOldValue
									lOk		 := .F.
									lHelp 	 := .F.
									Help( ,, 'PreLinTFH',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								Else
									AADD(aEnceCpos , {"TFH",oMdlG:GetValue('TFH_COD'),oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO'),cCampo,xOldValue} )
								EndIf
							EndIf
						Else
							lOk		:=  .F.
							lHelp	:=	.F.
							Help( ,, 'PreLinTFH',, STR0148, 1, 0 ) //"Não é possível editar esse registro, pois o local de atendimento está finalizado"
						EndIf
					EndIf
				EndIf
			EndIf
			If lOk .AND. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .AND. !(cCampo $ "TFH_PERINI|TFH_PERFIM")
				aStruct  := oMdlG:GetStruct():GetFields()
				nPos := Ascan( aStruct, {|x| x[3] == cCampo })
				If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
					If !oMdlG:IsInserted() .AND. VldLineRvP( cCampo, xValue, IIF(Empty(oMdlG:getValue("TFH_CODREL")), oMdlG:getValue("TFH_COD"), oMdlG:getValue("TFH_CODREL")), "TFH", aStruct[nPos][4] == 'D' )
						oMdlG:LoadValue('TFH_MODPLA', "2")
					Else
						oMdlG:LoadValue('TFH_MODPLA', "1")
					EndIf
				EndIf
			EndIf
			If lOk .AND. TecVlPrPar()
				If cCampo == "TFH_VLPRPA" .AND. xValue != 0
					If oMdlG:GetValue('TFH_COBCTR') == '2'
						Help( ' ' , 1 , 'AT740PRPA' , ,  STR0265, 1 , 0 ) //"Não é possível informar este valor para itens extras."
						lOk 	:= .F.
						lHelp 	:= .F.
					ElseIf oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") != '1'
						Help( ' ' , 1 , 'AT740PRPA' , ,  STR0266, 1 , 0 ) //"Campo disponível apenas para contratos recorrentes."
						lOk 	:= .F.
						lHelp 	:= .F.
					EndIf
				EndIf
			EndIF
			If cCampo == 'TFH_PRCVEN' .AND. SuperGetMv("MV_ORCVLB1",,.F.)
				nValorPrd := POSICIONE("SB1",1,xFilial("SB1")+oMdlG:GetValue("TFH_PRODUT"),"B1_PRV1")
				If nValorPrd > 0 .AND. xValue < nValorPrd
					lOk		 := .F.
					lHelp 	 := .F.
					Help( ,, 'PreLinTFH',, "Não é Possivel diminuir o valor do produto uma vez que o mesmo tem valor de venda no cadastro de produto.", 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
				EndIf
			EndIf
		EndIf

		If "DELETE"$cAcao .AND. !Empty(oMdlG:getValue("TFH_PRODUT"))
			If (cModelId == 'TECA740' .AND. (oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1')) .OR. ;
				   (cModelId == 'TECA740F' .AND. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1' )

			   lOK := .F.
			   lHelp := .F.
			   Help( ,, 'PreLinTFH',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"

			Else
				If oMdlG:GetValue("TFH_COBCTR") <> "2" .AND. lOk .AND. oMdlFull:GetId() == 'TECA740F'
					If cAcao == 'DELETE'
						/*Ao deletar a linha do Grid, atualiza o valor do campo TFH_VLRMESMC para 0, corrigindo os totalizadores*/
						lUpdGrid	:= oMdlG:CanUpdateLine() //Indica se o grid pode ser atualizado - CanUpdateLine()
						If !lUpdGrid
							oMdlG:SetNoUpdateLine(.F.)
						EndIf
						oMdlG:SetValue('TFH_VLRMESMC',0)
						If !lUpdGrid
							oMdlG:SetNoUpdateLine(.T.)
						EndIf

					ElseIf cAcao == 'UNDELETE' .And. oMdlG:isDeleted()
						/*Ao recuperar a linha do Grid, atualiza o valor do campo TFH_VLRMESMC para o seu valor original, corrigindo os totalizadores*/
						lTEC740FUn := .T.
						oMdlG:UnDeleteLine() //Necessário fazer UNDELETE para o SetValue ocorrer. A variavel lTEC740FUn garante que esse UNDELETE não passe pelo PréValid
						oMdlG:SetValue('TFH_VLRMESMC',At740FTGMes( "TFH_MC", "TFH_PERINI", "TFH_PERFIM", "TFH_TOTGER" ))
						oMdlG:DeleteLine() //Volta a linha para o seu estado original, para que a cAcao de UNDELETE ocorra normalmente
						lTEC740FUn := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !lOk .AND. lHelp
	Help(,,"AT740OK",,STR0046,1,0) // "Operação não permitida para os itens adicionais!"
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFF
	Função de Prevalidacao da grade de Recursos Humanos
@sample 	PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValue, xOldValueo)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValue],Indefinido,Novo valor inserido no campo.
@param		[xOldValue],Indefinido,Antigo valor do campo.

@since		17/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea       := GetArea()
Local aSaveLines  := FWSaveRows()
Local aStruct     := {}
Local cCodTFF     := ""
Local cCodTFJ     := ""
Local cControle   := "TFF_SUBTOT|TFF_TOTAL|TFF_TOTMI|TFF_TOTMC"
Local cLiberados  := "TFF_QTDVEN|TFF_TOTAL|TFF_PRCVEN|TFF_LUCRO|TFF_TXLUCR|TFF_ADM|TFF_TXADM|TFF_SUBTOT|TFF_VALDES|TFF_DESCON|TFF_TOTMI|TFF_TOTMC|TFF_TOTMES|TFF_VLPRPA|TFF_PERFIM"
Local cTabTemp    := ""
Local dDatFim     := Stod("")
Local dDatIni     := Stod("")
Local lAgrupado   := SuperGetMv("MV_GSDSGCN",,"2") == '2'
Local lCodTWO     := TFF->( ColumnPos( 'TFF_CODTWO' ) ) > 0
Local lHelp       := .T.
Local lOk         := .T.
Local lOkSly      := AliasInDic( 'SLY' )
Local lOrcPrc     := SuperGetMv("MV_ORCPRC",,.F.) //Verifica se usa a tabela de precificação
Local lPrHora     := TecABBPRHR()
Local lTecItExtOp := IsInCallStack("At190dGrOrc")
Local lVldVlFixo  := .T.
Local nAux        := 0
Local nMatPrPa    := 0
Local nMesVlr     := 0
Local nTotAtual   := 0
Local nValDel     := 0
Local nValMes     := 0
Local nVlFixoMin  := ""
Local nX          := 0
Local oMdlFull    := oMdlG:GetModel()
Local oMdlMC      := Nil
Local oMdlMI      := Nil
Local oMdlTXP     := Nil
Local oMdlTXQ     := Nil
Local oMdlUse     := Nil
Local lInclui     := oMdlFull:GetOperation() == MODEL_OPERATION_INSERT


If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If cCampo == "TFF_PERINI" .Or. cCampo == "TFF_PERFIM"
		dPerCron := xOldValue
	EndIf
	If IsInCallStack("AT870PlaRe") .AND. oMdlFull:GetOperation() == MODEL_OPERATION_UPDATE .AND.;
			cAcao == "SETVALUE" .AND. !EMPTY(oMdlG:GetValue("TFF_CODREL"))
		cCodTFF := oMdlG:GetValue("TFF_CODREL")
	Else
		If oMdlFull:GetOperation() == MODEL_OPERATION_UPDATE .AND. isInCallStack("At870Revis")
			cCodTFF := oMdlG:GetValue("TFF_COD")
			cCodTFJ := TFJ->TFJ_CODIGO

			cTabTemp := GetNextAlias()
			BeginSql Alias cTabTemp
				SELECT TFF_COD, TFF_CODPAI
				FROM %Table:TFF% TFF
				WHERE TFF.TFF_FILIAL = %xFilial:TFF% AND
				TFF.TFF_CODSUB = %Exp:cCodTFF% AND
				TFF.%notDel%
			EndSql
			If !(cTabTemp)->(EOF())
				cCodTFF := (cTabTemp)->TFF_COD
				cCodTFJ := POSICIONE("TFL",1,xFilial("TFL") + (cTabTemp)->TFF_CODPAI,"TFL_CODPAI")
			EndIf
			(cTabTemp)->(DbCloseArea())
		Else
			cCodTFF := oMdlG:GetValue("TFF_COD")
			cCodTFJ := TFJ->TFJ_CODIGO
		EndIf
	EndIf
	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND. !(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl( IIF( isInCallStack("At870Revis") ,cCodTFJ , TFJ->TFJ_CODIGO ) ) .AND.;
				AT870ItPla( IIF( isInCallStack("At870Revis") , cCodTFF , oMdlG:GetValue("TFF_COD")), "TFF" ) .AND. !(cCampo $ cControle+"TFF_CONTRT|TFF_CONREV")
		lOk := .F.
		lHelp	:= .F.
		Help(,,'PreLinTFF',, STR0298,1,0) // "Não é possivel alterar itens de uma Manutenção Planejada em uma revisão!."
	EndIf
	If !IsInCallStack('At870GerOrc')
		If cAcao == 'SETVALUE'

			If oMdlFull:GetId()=='TECA740F'
				If (cCampo == 'TFF_PRCVEN') .And. !IsInCallStack('At740EEPC') .And. oMdlG:HasField('TFF_PROCES')
					oMdlG:LoadValue('TFF_PROCES',.F.)
				EndIf
			EndIf

			If  lOk .AND. !IsInCallStack("ATCPYDATA")  .And. !IsInCallStack("A600GrvOrc") .And. !IsInCallStack("LoadXmlData") .And. !IsInCallStack("InitDados")
				lOk := oMdlG:GetValue("TFF_COBCTR") != "2"
			EndIf

			If !isInCallStack("FillModel") .AND. !isInCallStack("at870eftrv") .AND. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )
				If oMdlG:GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
					If UPPER(cCampo) $ cLiberados
						If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFF" .AND.;
																s[2] == oMdlG:GetValue('TFF_COD') .AND.;
																s[3] == oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO') .AND.;
																s[4] == cCampo }) ) > 0
							If aEnceCpos[nAux][5] < xValue
								lOk		 := .F.
								lHelp 	 := .F.
								Help( ,, 'PreLinTFF',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
							EndIf
						ElseIf UPPER(cCampo) $ cControle
							If xValue > xOldValue
								lOk		 := .F.
								lHelp 	 := .F.
								Help( ,, 'PreLinTFF',, STR0180, 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
							Else
								AADD(aEnceCpos , {"TFF",oMdlG:GetValue('TFF_COD'),oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_CODIGO'),cCampo,xOldValue} )
							EndIf
						ElseIf !lAgrupado .And. (cCampo == 'TFF_PRCVEN')  .And. xValue == 0
							lOk		 := .F.
							lHelp 	 := .F.
							Help( ,, 'PreLinTFF',, STR0290, 1, 0 ) //"Não é possível zerar este item, pois o parâmetro MV_GSDSGCN está desagrupado"
						EndIf
					Else
						lOk	  := .F.
						lHelp := .F.
						Help( ,, 'PreLinTFF',, STR0147, 1, 0 ) //Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
					EndIf
				EndIf
			EndIf

			If (oMdlFull:GetId()=='TECA740F')
				If (cCampo == 'TFF_PRCVEN') .And. !IsInCallStack('At740EEPC') .And. oMdlG:HasField('TFF_PROCES')
					oMdlG:LoadValue('TFF_PROCES',.F.)
				EndIf

			ElseIf (IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .And. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )

				IF oMdlG:GetValue('TFF_COBCTR') == '2' .AND. oMdlG:IsUpdated()
					Help( ' ' , 1 , 'AT740EXTRA' , ,  STR0064, 1 , 0 ) // "Não é permitida alteração de itens extras"
					lOk 	:= .F.
					lHelp 	:= .F.
				EndIf
			EndIf
			If cAcao == 'SETVALUE'
				If cCampo == 'TFF_PLUCRO'
					If !Empty(oMdlG:GetValue("TFF_CALCMD"))
						FwMsgRun(Nil,{||lOk:=At740ApliLuc(xValue,xOldValue,.F.,cCampo)},Nil, STR0355 )//"Atualizando valores..."
						If !lOk
							Help(,,"PreLinTFF",,STR0314,1,0,,,,,,) //"Operação cancelada pelo usuario"
							lHelp := .F.
						EndIf
					Else
						Help(,,"PreLinTFF",,STR0358,1,0,,,,,,) //"Não foi informada planilha de preços."
						lHelp := .F.
						lOk := .F.
					EndIf
				ElseIf cCampo == 'TFF_VLFIXO'
					If xValue > 0
						If !Empty(oMdlG:GetValue("TFF_CALCMD"))
							oMdlMI := oMdlFull:GetModel("TFG_MI")
							oMdlMC := oMdlFull:GetModel("TFH_MC")
							oMdlTXP := oMdlFull:GetModel('TXPDETAIL')
							oMdlTXQ := oMdlFull:GetModel('TXQDETAIL')
							nVlFixoMin := SumMat740(oMdlMI,oMdlMC,oMdlTXP,oMdlTXQ) // Quantidade de Materiais vezes 1 centavo:
							If xValue < nVlFixoMin
								If ExistBlock('a740MarC')
									oMdlG:LoadValue("TFF_VLFIXO", xValue)
								Else
									If !isBlind()
										lVldVlFixo := FwAlertYesNo(STR0405 + cValToChar( nVlFixoMin ), STR0406) //"É necessário ter ao menos 1 centavo para cada unidade de material, valor mínimo:  "VALOR MÍNIMO"
									EndIf
									If lVldVlFixo
										xValue := nVlFixoMin	
										oMdlG:LoadValue("TFF_VLFIXO", xValue)
										At740MatRd(oMdlMI,oMdlMC,oMdlTXP,oMdlTXQ) // Atualiza pra 1 centavo cada material
									EndIf
								EndIf
							EndIf
							If lVldVlFixo
								IIF(isBlind(), lOk:=At740ApliVlr(xValue,xOldValue), FwMsgRun(Nil,{||lOk:=At740ApliVlr(xValue,xOldValue)},Nil, STR0355 ))//"Atualizando valores..."
								If !lOk
									If isInCallStack("At998MdPla") .Or. isInCallStack("At998ExPla")
										oMdlG:LoadValue( "TFF_VLFIXO", 0 )
									EndIf
									lHelp := .F.
								EndIf
							Else
								lOk := .F.
							EndIf
						Else
							Help(,,"PreLinTFF",,STR0358,1,0,,,,,,) //"Não foi informada planilha de preços."
							lHelp := .F.
							lOk := .F.
						EndIf
					EndIf
				ElseIf cCampo == 'TFF_PLACOD'
					If IsInCallStack( "At740ClCal" )
						oMdlG:LoadValue( "TFF_LEGEND", "BR_VERDE" )
					Else
						If !Empty(xValue)
							// Altera Legenda para Vermelho ao informar/alterar o codigo da Planilha
							oMdlG:LoadValue( "TFF_LEGEND", "BR_VERMELHO" )
						ElseIf Empty(xValue) .And. AllTrim( oMdlG:GetValue("TFF_LEGEND") ) <> "BR_BRANCO"
							// Altera Legenda para Branco ao apagar Codigo da Planilha
							oMdlG:LoadValue( "TFF_LEGEND", "BR_BRANCO" )
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cAcao == 'DELETE'
			If (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .OR. (FindFunction("AT870CtRev") .AND.AT870CtRev( oMdlFull:GetValue("TFJ_REFER", "TFJ_CODIGO")) )
				If lInclui .AND. (oMdlG:getValue("TFF_MODPLA") <> "1" .OR. ValidPlane( oMdlG:getValue("TFF_COD") , "TFF"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFF',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				ElseIf oMdlG:getValue("TFF_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFF_CODREL"))
					lOk := .F.
					lHelp	:= .F.
					Help(,,'PreLinTFF',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				EndIf
			EndIf
			If !isInCallStack("at870eftrv") .and. !Empty(oMdlG:getValue("TFF_PRODUT")) .AND. lOk
				If oMdlG:GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
					lOk 	:= .F.
					lHelp	:= .F.
					Help( ,, 'PreLinTFF',, STR0289, 1, 0 ) //"Não é possível excluir esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
				EndIf

				//Valida se a linha pode ser deletada na Revisao
				If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. lOk
					lOk := lOk .And. At740ExTFF(oMdlFull)
					//lExiste := At870Find('TFF_RH','TFF_CODSUB',oMdlG:GetValue('TFF_COD'),'TFL_CODSUB',oMdlUse:GetValue('TFL_CODIGO'),'', '',.F.,lOrcPrc)

					If !lOk
						Help(,,"PreLinTFF",, STR0151,1,0) //Não é possível excluir esse item.
						lOk 	:= .F.
						lHelp 	:= .F.
					EndIf
				EndIf

				If lOk .And. !Empty(oMdlG:GetValue('TFF_CHVTWO')) .And. !IsInCallStack('A740LoadFa')  .And. !Empty(oMdlG:GetValue('TFF_PRODUT'))
					If !lCodTWO
						lOk := .F.
						Help(,,'A740TFFTWOD',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
					EndIf
				EndIf
				If lOk
					//-----------------------------------------------
					//  Atualiza o item da locação vinculado
					oMdlUse := oMdlFull:GetModel('TFL_LOC')

					// valor do RH
					nValDel := oMdlG:GetValue('TFF_SUBTOT')
					nTotAtual := oMdlUse:GetValue('TFL_TOTRH')
					nTotAtual -= nValDel

					lOk := oMdlUse:SetValue('TFL_TOTRH', nTotAtual )

					//valor mensal do RH
					If lOrcPrc
						If oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") != '1'  // somente não recorrente
							dDatIni	:= oMdlG:GetValue('TFF_PERINI')
							dDatFim	:= oMdlG:GetValue('TFF_PERFIM')
							nMesVlr := At740FDDiff( dDatIni, dDatFim )

							If nMesVlr > 0
								nValMes := ( nValDel / nMesVlr )
							EndIf
						Else
							nValMes := nValDel
						EndIf

						nTotAtual := oMdlUse:GetValue('TFL_MESRH')
						nTotAtual -= nValMes

						lOk := oMdlUse:SetValue('TFL_MESRH', nTotAtual )
					EndIf

					// valor do Material de Implantação
					nValDel := oMdlG:GetValue('TFF_TOTMI')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMI')
					nTotAtual -= nValDel

					lOk := oMdlUse:SetValue('TFL_TOTMI', nTotAtual )

					// valor do Material de Consumo
					nValDel := oMdlG:GetValue('TFF_TOTMC')
					nTotAtual := oMdlUse:GetValue('TFL_TOTMC')
					nTotAtual -= nValDel

					lOk := oMdlUse:SetValue('TFL_TOTMC', nTotAtual )
					If lOk .And. TFF->( ColumnPos("TFF_GERPLA")) > 0 .And. TFL->( ColumnPos("TFL_GERPLA")) > 0
						At984aGtTt("TFF_RH","TFF_GERPLA","TFL_LOC","TFL_GERPLA",oMdlG:GetValue("TFF_GERPLA"),cAcao)

						If oMdlFull:GetModel( "TFJ_TOT" ) <> Nil .And. oMdlFull:GetModel( "TFJ_TOT" ):HasField( "TFJ_TOTGER" ) .And. oMdlFull:GetModel( "TFJ_TOT" ):HasField( "TFJ_TOTCUS" )
							aTot := A740TFJCus(oMdlFull)
							If Empty( oMdlG:GetValue('TFF_PLACOD') )
								nValDel := oMdlG:GetValue('TFF_TOTAL')
							Else
								nValDel := oMdlG:GetValue('TFF_VLRCOB')
							EndIf
							oMdlFull:GetModel( "TFJ_TOT" ):LoadValue( "TFJ_TOTGER", aTot[1]-nValDel )
							oMdlFull:GetModel( "TFJ_TOT" ):LoadValue( "TFJ_TOTCUS", aTot[2]-(oMdlG:GetValue('TFF_SUBTOT')+oMdlG:GetValue('TFF_TOTMI')+oMdlG:GetValue('TFF_TOTMC')+oMdlFull:GetModel( "TXPDETAIL" ):GetValue('TXP_TOTGER')+oMdlFull:GetModel( "TXQDETAIL" ):GetValue('TXQ_TOTGER')) )
						EndIf
					Endif
				EndIf
			EndIf

		ElseIf cAcao == 'UNDELETE'
			If lOk .And. !Empty(oMdlG:GetValue('TFF_CHVTWO')) .And. !IsInCallStack('A740LoadFa') .And. !Empty(oMdlG:GetValue('TFF_PRODUT'))
				If !lCodTWO
					lOk := .F.
					Help(,,'A740TFFTWOH',, STR0100,1,0)	//"Item não pode ser desabilitado, pois o mesmo foi adicionado pelo facilitador"
				Endif
			EndIf

			If lOk
				//-----------------------------------------------
				//  Atualiza o item da locação vinculado
				oMdlUse := oMdlFull:GetModel('TFL_LOC')

				// valor do RH
				nValDel := oMdlG:GetValue('TFF_SUBTOT')
				nTotAtual := oMdlUse:GetValue('TFL_TOTRH')
				nTotAtual += nValDel

				lOk := oMdlUse:SetValue('TFL_TOTRH', nTotAtual )

				//valor mensal do RH
				If oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") != '1'  // somente não recorrente
					dDatIni	:= oMdlG:GetValue('TFF_PERINI')
					dDatFim	:=  oMdlG:GetValue('TFF_PERFIM')
					nMesVlr := At740FDDiff( dDatIni, dDatFim )

					If nMesVlr > 0
						nValMes := ( nValDel / nMesVlr )
					EndIf
				Else
					nValMes := nValDel
				EndIf

				nTotAtual := oMdlUse:GetValue('TFL_MESRH')
				nTotAtual += nValMes

				lOk := oMdlUse:SetValue('TFL_MESRH', nTotAtual ) .And. Empty(oMdlG:GetValue('TFF_CHVTWO'))

				// valor do Material de Implantação
				nValDel := oMdlG:GetValue('TFF_TOTMI')
				nTotAtual := oMdlUse:GetValue('TFL_TOTMI')
				nTotAtual += nValDel

				lOk := oMdlUse:SetValue('TFL_TOTMI', nTotAtual )

				// valor do Material de Consumo
				nValDel := oMdlG:GetValue('TFF_TOTMC')
				nTotAtual := oMdlUse:GetValue('TFL_TOTMC')
				nTotAtual += nValDel

				lOk := oMdlUse:SetValue('TFL_TOTMC', nTotAtual )
				If lOk .And. TFF->( ColumnPos("TFF_GERPLA")) > 0 .And. TFL->( ColumnPos("TFL_GERPLA")) > 0
					At984aGtTt("TFF_RH","TFF_GERPLA","TFL_LOC","TFL_GERPLA",oMdlG:GetValue("TFF_GERPLA"),cAcao)

					If oMdlFull:GetModel( "TFJ_TOT" ) <> Nil .And. oMdlFull:GetModel( "TFJ_TOT" ):HasField( "TFJ_TOTGER" ) .And. oMdlFull:GetModel( "TFJ_TOT" ):HasField( "TFJ_TOTCUS" )
						aTot := A740TFJCus(oMdlFull)
						If Empty( oMdlG:GetValue('TFF_PLACOD') )
							nValDel := oMdlG:GetValue('TFF_TOTAL')
						Else
							nValDel := oMdlG:GetValue('TFF_VLRCOB')
						EndIf
						oMdlFull:GetModel( "TFJ_TOT" ):LoadValue( "TFJ_TOTGER", aTot[1]+nValDel )
						oMdlFull:GetModel( "TFJ_TOT" ):LoadValue( "TFJ_TOTCUS", aTot[2]+oMdlG:GetValue('TFF_SUBTOT')+oMdlG:GetValue('TFF_TOTMI')+oMdlG:GetValue('TFF_TOTMC')+oMdlFull:GetModel( "TXPDETAIL" ):GetValue('TXP_TOTGER')+oMdlFull:GetModel( "TXQDETAIL" ):GetValue('TXQ_TOTGER') )
					EndIf
				Endif
			EndIf
		EndIf

		If lOk .And. lOkSly
			// Durante a revisão do contrato não deverá ser possível realizar alteração do turno ou da escala
			// de um item de recursos humanos caso exista um benefício vinculado sem uma data final definida
			If cAcao == 'SETVALUE' .AND. (IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .And. !( IsInCallStack("Initdados") .Or. IsInCallStack("AtCpyData") )
				If cCampo $ "TFF_TURNO|TFF_ESCALA"
					If IsInCallStack("AT870PlaRe") .AND. POSICIONE("ABQ",3,xFilial("ABQ")+cCodTFF+xFilial("TFF"),"ABQ_ORIGEM") == 'CN9'
						lOk := .F.
						lHelp	:= .F.
						Help(,,'PreLinTFF',, STR0299,1,0) //"Não é permitido alterar a Escala de itens efetivos no processo de Revisão Planejada."
					EndIf
					If oMdlG:IsUpdated() .AND. lOk
						lOk := At740VerVB(cCodTFF)

						If !lOk
							lHelp := .F.
							Help(,,"PreLinTFF",, STR0081,1,0) // "Existem Vínculos de Benefícios ativos, não é possível realizar a alteração do turno ou da escala"
						EndIf
						If lOk .And. cCampo $ "TFF_ESCALA" .And. !At740VlEsc(cCodTFF,xOldValue)
							lOk   := .F.
							lHelp := .F.
						Endif
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If cAcao $ "DELETE|SETVALUE"
			If lTecItExtOp .And. oMdlG:GetValue('TFF_ITEXOP') <> "1"
				If cCampo <> "TFF_QTDVAG"
					lOk := .F.
					lHelp := .F.
					If IsInCallStack("AT855Brow")
						Help(,, "TFFAPROVOPE",, STR0345,1,0,,,,,,{STR0193})//"Não é possível deletar registros na aprovação operacional" ## "Para alterar este item, realize uma Revisão do Contrato"
					Else
						Help(,, "TFFNAOEXTRA",, STR0268,1,0,,,,,,{STR0193})//"Não é possível modificar itens que não foram gerados pela rotina de Item Extra Operacional." ## "Para alterar este item, realize uma Revisão do Contrato"
					EndIf
				EndIf
			Elseif oMdlG:GetValue('TFF_COBCTR') != "2"
				lOk := .F.
				lHelp := .F.
				Help(,, "TFFNAOEXTRA",,STR0192,1,0,,,,,,{STR0193})//"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
			EndIf
		Endif

		If cAcao == "DELETE"
			If oMdlG:GetValue('TFF_COBCTR') == "2" .Or. (lTecItExtOp .And. oMdlG:GetValue('TFF_ITEXOP') <> "1" )
				If !(At740VerABB( oMdlG:GetValue("TFF_COD") ))
					lOk := .F.
					lHelp := .F.
					Help(,,STR0035,, STR0062, 1, 0) //'Atenção'#"Não é possivel remover o item extra, pois existe agendamento para o atendente!"
				EndIf
			Endif
		EndIf
		
		If cAcao == 'SETVALUE'
			If cCampo == 'TFF_PLUCRO'
				If !Empty(oMdlG:GetValue("TFF_CALCMD"))
					FwMsgRun(Nil,{||lOk:=At740ApliLuc(xValue,xOldValue,.F.,cCampo)},Nil, STR0355 )//"Atualizando valores..."
					If !lOk
						Help(,,"PreLinTFF",,STR0314,1,0,,,,,,) //"Operação cancelada pelo usuario"
						lHelp := .F.
					EndIf
				Else
					Help(,,"PreLinTFF",,STR0358,1,0,,,,,,) //"Não foi informada planilha de preços."
					lHelp := .F.
					lOk := .F.
				EndIf
			ElseIf cCampo == 'TFF_VLFIXO'
				If xValue > 0
					If !Empty(oMdlG:GetValue("TFF_CALCMD"))
						FwMsgRun(Nil,{||lOk:=At740ApliVlr(xValue,xOldValue)},Nil, STR0355 )//"Atualizando valores..."
						If !lOk
							lHelp := .F.
						EndIf
					Else
						Help(,,"PreLinTFF",,STR0358,1,0,,,,,,) //"Não foi informada planilha de preços."
						lHelp := .F.
						lOk := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	If cAcao == 'SETVALUE'
		If lPrHora
			If (cCampo == "TFF_QTDHRS")
				If LEN(ALLTRIM(xValue)) == 5 .AND. AT(":",xValue) == 0
					lOk := .F.
					lHelp 	 := .F.
					Help( " ", 1, "PreLinTFF", Nil, STR0256, 1 )	//"Horário inválido. Por favor, insira um horário no formato HH:MM"
				EndIf
				If AT(":",xValue) == 0 .AND. AtJustNum(Alltrim(xValue)) == Alltrim(xValue) .AND. lOk
					If LEN(Alltrim(xValue)) == 4
						xValue := LEFT(Alltrim(xValue),2) + ":" + RIGHT(Alltrim(xValue),2)
					ElseIf LEN(Alltrim(xValue)) == 2
						xValue := Alltrim(xValue) + ":00"
					ElseIf LEN(Alltrim(xValue)) == 1
						xValue := "0" + Alltrim(xValue) + ":00"
					EndIf
				EndIf
				If lOk
					If !AtVldHora(Alltrim(xValue), .T.)
						lOK := .F.
						lHelp	:= .F.
						Help( " ", 1, "PreLinTFF", Nil, STR0255, 1 ) // "O valor digitado não corresponde a um horario valido!"
					EndIf
				EndIf
				If TecConvHr(xOldValue) > TecConvHr(xValue)
					If At740APHR(cCodTFF)
						lOk := .F.
						lHelp := .F.
						Help( ,, 'PreLinTFF',, STR0254, 1, 0 ) //"Já existe agenda gerada não é possivel diminuir o tempo de horas."
					EndIf
				EndIf
			EndIf
			If (cCampo == "TFF_QTDVEN") .AND. !Empty(oMdlG:GetValue('TFF_QTDHRS'))
				If !(IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") )
					At740QTDHr( .F., xValue, xOldValue )
				EndIf
			EndIf
		EndIf
		If lOk .AND. cCampo == "TFF_VLPRPA" .AND. xValue != 0
			If oMdlG:GetValue('TFF_COBCTR') == '2'
				Help( ' ' , 1 , 'AT740PRPA' , ,  STR0265, 1 , 0 ) //"Não é possível informar este valor para itens extras."
				lOk 	:= .F.
				lHelp 	:= .F.
			ElseIf oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") != '1'
				Help( ' ' , 1 , 'AT740PRPA' , , STR0266, 1 , 0 ) //"Campo disponível apenas para contratos recorrentes."
				lOk 	:= .F.
				lHelp 	:= .F.
			EndIf
		EndIf
	ElseIf cAcao $ "DELETE|UNDELETE"
		If lOk .AND. TecVlPrPar() .AND. oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") == '1' .And. !lTecItExtOp .AND. !IsInCallStack("At870GerOrc")
			oMdlMC := oMdlFull:GetModel("TFH_MC")
			oMdlMI := oMdlFull:GetModel("TFG_MI")
			If cAcao == "DELETE"
				If !lOrcPrc
					For nX := 1 To oMdlMC:Length()
						If !EMPTY(oMdlMC:GetValue("TFH_PRODUT", nX)) .AND.;
								oMdlMC:GetValue("TFH_COBCTR", nX) != '2' .AND.;
								!oMdlMC:isDeleted(nX)
							nMatPrPa += oMdlMC:GetValue("TFH_VLPRPA", nX)
						EndIf
					Next nX
					For nX := 1 To oMdlMI:Length()
						If !EMPTY(oMdlMI:GetValue("TFG_PRODUT", nX)) .AND.;
								oMdlMI:GetValue("TFG_COBCTR", nX) != '2' .AND.;
								!oMdlMI:isDeleted(nX)
							nMatPrPa += oMdlMI:GetValue("TFG_VLPRPA", nX)
						EndIf
					Next nX
				EndIf
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")-(oMdlG:GetValue("TFF_VLPRPA")+nMatPrPa))
			ElseIf cAcao == "UNDELETE"
				If !lOrcPrc
					For nX := 1 To oMdlMC:Length()
						If !EMPTY(oMdlMC:GetValue("TFH_PRODUT", nX)) .AND.;
								oMdlMC:GetValue("TFH_COBCTR", nX) != '2' .AND.;
								!oMdlMC:isDeleted(nX)
							nMatPrPa += oMdlMC:GetValue("TFH_VLPRPA", nX)
						EndIf
					Next nX
					For nX := 1 To oMdlMI:Length()
						If !EMPTY(oMdlMI:GetValue("TFG_PRODUT", nX)) .AND.;
								oMdlMI:GetValue("TFG_COBCTR", nX) != '2' .AND.;
								!oMdlMI:isDeleted(nX)
							nMatPrPa += oMdlMI:GetValue("TFG_VLPRPA", nX)
						EndIf
					Next nX
				EndIf
				oMdlFull:LoadValue("TFL_LOC","TFL_VLPRPA",;
					oMdlFull:GetValue("TFL_LOC","TFL_VLPRPA")+(oMdlG:GetValue("TFF_VLPRPA")+nMatPrPa))
			EndIf
		EndIf
	EndIf
EndIf

If !lOk .AND. lHelp
	Help(,,"AT740OK",,STR0046,1,0) // "Operação não permitida para os itens adicionais!"
EndIf

If !IsInCallStack('At870GerOrc') .AND. lOk .AND.;
		(isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .AND. !(cCampo $ "TFF_PERINI|TFF_PERFIM")
	aStruct  := oMdlG:GetStruct():GetFields()
	nPos := Ascan( aStruct, {|x| x[3] == cCampo })
	If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
		If !oMdlG:IsInserted() .AND. VldLineRvP( cCampo, xValue, IIF(EMPTY(oMdlG:getValue("TFF_CODREL")), oMdlG:getValue("TFF_COD"), oMdlG:getValue("TFF_CODREL")), "TFF", aStruct[nPos][4] == 'D' )
			oMdlG:LoadValue('TFF_MODPLA', "2")
		Else
			oMdlG:LoadValue('TFF_MODPLA', "1")
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk


//------------------------------------------------------------------------------
/*/{Protheus.doc} PosTFF
	Função de Prevalidacao do modelo de Recursos Humanos TFF
@sample 	PosTFF( oMdlG )
@param		[oMdlG],objeto,Representando o modelo de dados.
@since		18/03/2024
@version	P12
/*/
//------------------------------------------------------------------------------
Function PosTFF( oMdlG )
	Local lOk As Logical
	Local nLine As Numeric
	Local nX As Numeric
	Local cCorLeg As Character

	lOk := .T.
	nLine := oMdlG:GetLine()
	For nX := 1 To oMdlG:Length()
		oMdlG:GoLine( nX )

		If !(oMdlG:isDeleted())
			cCorLeg := AllTrim( oMdlG:GetValue("TFF_LEGEND") )
			If cCorLeg == "BR_VERMELHO"
				If MsgYesNo( STR0381 + CRLF + STR0382 + CRLF + STR0383 ) // STR0381#"Existem Itens que precisam processar a planilha de preços." - STR0382#"Verifique os itens com legenda vermelha." - STR0383#"Deseja executar a planilha para os itens faltantes?"
					At740PlLot()//"Reprocessando Planilha de Preços..."
				Else
					Help(,,'PosTFF',, STR0381 + CRLF + STR0382,1,0) // STR0381#"Existem Itens que precisam processar a planilha de preços." - STR0382#"Verifique os itens com legenda vermelha."
					lOk := .F.
				EndIf
				Exit
			EndIf
		EndIf
	Next nX
	oMdlG:GoLine( nLine )

Return lOk
//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFL
	Função de Prevalidacao da grade de locais de atendimento
@sample 	PreLinTFL(oMdlG, nLine, cAcao, cCampo)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.

@since		17/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function PreLinTFL1(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet := .T.
Local oMdlFull := If(oMdlG <> nil, oMdlG:GetModel(), nil)
Local lInclui	:= oMdlFull:GetOperation() == MODEL_OPERATION_INSERT
Local nAux := 0
Local cControle := "TFL_TOTAL"
Local cLiberados := "TFL_TOTRH|TFL_TOTAL|TFL_MESRH|TFL_TOTMI|TFL_TOTMC|TFL_MESMI|TFL_MESMC|TFL_TOTLE|TFL_VLPRPA"
Local lOk := .T.

If lRet .And. oMdlFull <> Nil .And.;
	!IsInCallStack('At870GerOrc')

	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND.!(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl(TFJ->TFJ_CODIGO) .AND. AT870ItPla( oMdlG:GetValue("TFL_CODIGO"), "TFL" )
		If !(UPPER(cCampo) $ cLiberados)
			lRet := .F.
			Help(,,'PreLinTFL',, STR0298,1,0) // "Não é possivel excluir itens não planejados."
		EndIf
	EndIf

	If lRet
		If cAcao == 'SETVALUE'
			If cCampo == 'TFL_DESLOC'
				//  Atualiza o item da locação vinculado
				At740fATFL( oMdlFull:GetModel('TFL_LOC') )
			ElseIf cCampo == 'TFL_PLUCRO'
				FwMsgRun(Nil,{||lRet:=At740ApliLuc(xValue,xOldValue,.T.)},Nil, STR0355 )//"Atualizando valores..."
				If !lRet
					Help(,,"PreLinTFL1",,STR0314,1,0,,,,,,) //"Operação cancelada pelo usuario"
				EndIf
			EndIf

			If  !isInCallStack("FillModel") .and. !isInCallStack("at870eftrv") .and. !isInCallStack("InitDados")

				If oMdlG:GetValue('TFL_ENCE') == '1'
					If UPPER(cCampo) $ cLiberados
						If ( nAux := ASCAN(aEnceCpos, {|s|	s[1] == "TFL" .AND.;
																s[2] == oMdlG:GetValue('TFL_CODIGO') .AND.;
																s[3] == oMdlFull:GetModel("TFJ_REFER"):GetValue("TFJ_CODIGO") .AND.;
																s[4] == cCampo }) ) > 0
							If aEnceCpos[nAux][5] < xValue
								Help(,,"PreLinTFL1",, STR0180, 1, 0) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								lRet := .F.
							EndIf
						ElseIf UPPER(cCampo) $ cControle
							If xValue > xOldValue
								Help(,,"PreLinTFL1",, STR0180, 1, 0) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
								lRet := .F.
							Else
								AADD(aEnceCpos , {"TFL",oMdlG:GetValue('TFL_CODIGO'),oMdlFull:GetModel("TFJ_REFER"):GetValue("TFJ_CODIGO"),cCampo,xOldValue} )
							EndIf
						EndIf
					Else
						Help(,,"PreLinTFL1",, STR0150, 1, 0)
						lRet := .F.
					EndIf
				EndIf

			EndIf
			If lRet .AND.( (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .OR. isInCallStack("AplicaRevi") ) .AND. !(cCampo $ "TFH_DTINI|TFH_DTFIM")
				aStruct  := oMdlG:GetStruct():GetFields()
				nPos := Ascan( aStruct, {|x| x[3] == cCampo })
				If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
					If !oMdlG:IsInserted() .AND. VldLineRvP( cCampo, xValue, IIF(Empty(oMdlG:getValue("TFL_CODREL")), oMdlG:getValue("TFL_CODIGO"), oMdlG:getValue("TFL_CODREL")), "TFL", aStruct[nPos][4] == 'D' )
						oMdlG:LoadValue('TFL_MODPLA', "2")
					Else
						oMdlG:LoadValue('TFL_MODPLA', "1")
					EndIf
				EndIf
			EndIf
		ElseIf cAcao == 'DELETE' .And. ((IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .OR. (isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi") ) .OR. (FindFunction("AT870CtRev") .AND. AT870CtRev( oMdlFull:GetValue("TFJ_REFER", "TFJ_CODIGO") )))
			If isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi")
				If lInclui .AND. (oMdlG:getValue("TFL_MODPLA") <> "1" .OR. ValidPlane( oMdlG:getValue("TFL_CODIGO") , "TFL"))
					lRet := .F.
					Help(,,'PreLinTFL1',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				ElseIf oMdlG:getValue("TFL_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFL_CODREL"))
					lRet := .F.
					Help(,,'PreLinTFL1',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
				EndIf
			EndIf
			If (IsInCallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. !Empty(oMdlFull:GetModel('TFL_LOC'):GetValue("TFL_PLAN"))

				lRet := lRet .And. At740VlExl(oMdlFull)

			EndIf
			// Verifica no contrato agrupado se tem medição e o saldo sera menor.

			//Verifica quais itens podem ser deletados na Revisão de Contrato
			lOk := At740ExtIt('TFL',oMdlFull:GetModel('TFL_LOC'):GetValue("TFL_CODIGO"), 'TFL_CONTRT', oMdlFull:GetModel('TFL_LOC'):IsInserted())

			If !lOk
				Help(,,"PreLinTFL1",, STR0151, 1, 0) //Não é possível excluir esse item.
			EndIf
		EndIf
	EndIf
EndIf

If lOk .And. (cAcao == 'UNDELETE' .Or. cAcao == 'DELETE')
 	If TFJ->( ColumnPos("TFJ_GERPLA")) > 0 .And. TFL->( ColumnPos("TFL_GERPLA")) > 0
		At984aGtTt("TFL_LOC","TFL_GERPLA","TFJ_REFER","TFJ_GERPLA",oMdlG:GetValue("TFL_GERPLA"),cAcao)
	Endif
Endif

If lRet .And. lOk .And. oMdlFull <> Nil .AND. oMdlFull:GetId()=='TECA740'
	If cAcao == 'SETVALUE' 
		If cCampo == 'TFL_LOCAL'
			If xValue <> fwfldget("TFL_LOCAL")
				If isBlind()
					at740RhPla(oMdlFull)
				Else
					FwMsgRun(Nil,{|| at740RhPla(oMdlFull)}, Nil, STR0401) //"Validando informações"
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------l
/*/{Protheus.doc} PosLinTFF
	 Permite a inclusão de valores zerados para a cortesia

@sample		PosLinTFF()

@since		15/04/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function PosLinTFF(oMdlG, nLine, cAcao, cCampo)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cJobThr		:= ""
Local nX			:= 0
Local oMdlFull 		:= oMdlG:GetModel()
Local oMdlMI		:= oMdlFull:GetModel("TFG_MI")
Local oMdlMC		:= oMdlFull:GetModel("TFH_MC")
Local lPrHora 		:= TecABBPRHR()
Local lOrcPrc 	    := SuperGetMv("MV_ORCPRC",,.F.)
Local lRet      	:= .T.

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If !cAcao == "DELETE" .And. !IsInCallStack("ATCPYDATA")
		If oMdlG:GetValue("TFF_COBCTR") == "1" .And. cAcao <> Nil
			lRet := At740VlVlr("TFF_RH","TFF_PRCVEN")
		EndIf
	EndIf
EndIf

If lRet
	If oMdlG:GetValue("TFF_INSALU") == "1" .And. oMdlG:GetValue("TFF_GRAUIN") <> "1"
		Help(,,"TFFINSALU1",, STR0066, 1, 0) //'Atenção'#"Itens que não possuem Insalubridade não devem ter Grau preenchido"
		lRet := .F.
	ElseIf oMdlG:GetValue("TFF_INSALU") <> "1" .And. oMdlG:GetValue("TFF_GRAUIN") == "1"
		Help(,,"TFFINSALU2",, STR0067, 1, 0) //'Atenção'#"Existem Itens que possuem Insalubridade sem o Grau preenchido"
		lRet := .F.
	ElseIf  !Empty( oMdlG:GetValue("TFF_PRODUT") ) .And. Empty( oMdlG:GetValue("TFF_FUNCAO") ) .And. !IsInCallStack("A740LoadFa")
		If (TFF->(ColumnPos('TFF_GERVAG')) > 0)
			If oMdlG:GetValue("TFF_GERVAG") == "1"
				Help(,, "PosLinTFF",,STR0364,1,0,,,,,,{STR0365})  // "O campo de Função (TFF_FUNCAO) é obrigatório" ###  "Preencha o campo para prosseguir."
				lRet := .F.
			EndIf
		Endif
	ElseIf !Empty( oMdlG:GetValue( "TFF_HORAIN" ) ) .AND. !Empty( oMdlG:GetValue( "TFF_HORAFI" ) ) .AND. Empty( oMdlG:GetValue( "TFF_TURNO" ) )
		Help(,, "HORAALOC",,STR0399,1,0,,,,,,{STR0400}) //"Campo de Turno não preenchido." ###  "Preencha o campo de Turno."
		lRet := .F.
	ElseIf !Empty( oMdlG:GetValue("TFF_PRODUT") ) .And. Empty( oMdlG:GetValue("TFF_TURNO") ) .And. Empty( oMdlG:GetValue("TFF_ESCALA") ) .And. !IsInCallStack("A740LoadFa")
		If (TFF->(ColumnPos('TFF_GERVAG')) > 0)
			If oMdlG:GetValue("TFF_GERVAG") == "1"
				Help(,, "RHTURNO",,STR0133,1,0,,,,,,{STR0134})  // "Campos de Turno e Escala não estão preenchidos." ###  "Preencha algum destes campos para prosseguir."
				lRet := .F.
			EndIf
		Else
			Help(,, "RHTURNO",,STR0133,1,0,,,,,,{STR0134})  // "Campos de Turno e Escala não estão preenchidos." ###  "Preencha algum destes campos para prosseguir."
			lRet := .F.
		Endif
	ElseIf !Empty(oMdlG:GetValue("TFF_PERFIM")) .AND. oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC")  == "1" .AND. oMdlG:GetValue('TFF_PERFIM') > oMdlFull:GetModel("TFL_LOC"):GetValue('TFL_DTFIM')
		Help( ,, 'PosLinTFF',, STR0288, 1, 0 ) //"Data de vigência final não está dentro da data do Local de atendimento."
		lRet := .F.
	EndIf
	If lPrHora .AND. !Empty(oMdlG:GetValue("TFF_ESCALA")) .AND. TecConvHr(oMdlG:GetValue("TFF_QTDHRS")) > 0
		Help( ,, 'PreLinTFF',, STR0257, 1, 0 ) // "O campo TFF_QTDHRS foi preenchido, por favor exclua a a escala."
		lRet := .F.
	EndIf
	If lRet .AND. !lOrcPrc
		If (( oMdlMI:Length() > 1 .OR. !Empty(oMdlMI:GetValue("TFG_PRODUT")) ) .OR. ( oMdlMC:Length() > 1 .OR. !Empty(oMdlMC:GetValue("TFH_PRODUT")) ))
			lRet := VldDatas(oMdlFull)
		EndIf
	EndIf
	If TecBHasGvg() .And. oMdlG:GetValue("TFF_GERVAG") == "2"
		If At740GerVag(oMdlG)
			Help( ,, 'TFF_GERVAG',, STR0309, 1, 0 ) //"Para itens que não vão gerar vaga operacional, os campos de Risco(TFF_RISCO), Qtd de Horas(TFF_QTDHRS),Insalubridade(TFF_INSALU) e Periculosidade(TFF_PERICU) não podem ser preenchidos"
			lRet := .F.
		EndIf
	EndIf
EndIf

// Calculo Automatico da Planilha:
If lRet .And. SuperGetMv("MV_TESGSNE",.F.,.F.) .And. !isBlind()
	If oMdlG:GetOperation() <> MODEL_OPERATION_VIEW
		//Starta um Job para Processar planilha em Background:
		If !oMdlG:IsDeleted()
			If AllTrim(oMdlG:GetValue("TFF_LEGEND")) == "BR_VERMELHO"
				cJobThr := oMdlG:GetValue("TFF_COD")
				If Empty(GetGlbValue(cJobThr))
					FwMsgRun(Nil,{|| At740PlaJob(cJobThr, oMdlG:GetValue("TFF_CALCMD"), oMdlG:GetValue("TFF_PLACOD")+oMdlG:GetValue("TFF_PLAREV"), oMdlFull) }, Nil, "Iniciando cálculo de planilha para posto "+cJobThr)
				EndIf
			EndIf
		EndIf
		//Encerra Jobs abertos que já tenham sido encerrados:
		If Len(aControle) > 0
			If !IsInCallStack("At740EncPla")
				For nX := Len(aControle) To 1 Step -1
					If GetGlbValue(aControle[nX]) == "EXIT"
						FwMsgRun(Nil,{|| At740EncPla(oMdlFull, aControle[nX], nX) }, Nil, "Atualizando planilha para posto "+aControle[nX])
					EndIf
				Next nX
			EndIf
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return(lRet)


//------------------------------------------------------------------------------l
/*/{Protheus.doc} PosLinTFI
	 Permite a inclusão de valores zerados para a cortesia

@sample		PosLinTFI()

@since		07/12/2020
@version	P12

/*/
//------------------------------------------------------------------------------
Function PosLinTFI(oMdlG, nLine, cAcao, cCampo)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      	:= .T.
Local oMdlFull 		:= oMdlG:GetModel()

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If !Empty(oMdlG:GetValue("TFI_PERFIM")) .AND. oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC") == "1" .AND. oMdlG:GetValue('TFI_PERFIM') > oMdlFull:GetModel("TFL_LOC"):GetValue('TFL_DTFIM')
		Help( ,, 'PosLinTFI',, STR0288, 1, 0 ) //"Data de vigência final não está dentro da data do Local de atendimento."
		lRet := .F.
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return(lRet)
//-----------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTFG
	 Permite a inclusão de valores zerados para a cortesia

@sample		PosLinTFG()

@since		16/04/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function PosLinTFG(oMdlG, nLine, cAcao, cCampo)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      := .T.
Local oMdlFull := oMdlG:GetModel()
Local nSld		:= 0
Local cMsgSolu	:= ""

If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .And. oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	DbSelectArea("TFG")
	DbSetOrder(1)
	If DbSeek( xFilial('TFG')+ oMdlG:GetValue("TFG_COD"))
		nSld := oMdlG:GetValue("TFG_QTDVEN") - TFG->TFG_QTDVEN
		If nSld <> 0
			If (TFG->TFG_SLD + nSld) < 0
				cMsgSolu := STR0242 + cValTOChar(oMdlG:GetValue("TFG_QTDVEN")+((TFG->TFG_SLD + nSld)* -1))+STR0243+oMdlG:GetValue("TFG_COD") //"Não é possível reduzir a quantidade desse item, pois isso irá gerar inconsistência entre o apontado x orçado"//"Inclua quantidade igual ou maior que "##" ou estorne apontamentos do material de código: "
				Help( " ", 1, "AT740TFGTQTD", Nil, STR0244, 1,,,,,,,;
						{cMsgSolu} )
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If !cAcao == "DELETE" .And. !IsInCallStack("ATCPYDATA")
		If oMdlG:GetValue("TFG_COBCTR") != "2" .And. cAcao <> Nil
			lRet := At740VlVlr("TFG_MI","TFG_PRCVEN")
		EndIf
	EndIf
EndIf

If lRet
	lRet := VldDatas(oMdlG,nLine)
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTFH
	 Permite a inclusão de valores zerados para a cortesia

@sample		PosLinTFH()

@since		16/04/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function PosLinTFH(oMdlG, nLine, cAcao, cCampo)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      := .T.
Local oMdlFull := oMdlG:GetModel()
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)
Local nSld		:= 0
Local cMsgSolu	:= ""

If (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .And. oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	DbSelectArea("TFH")
	DbSetOrder(1)
	If DbSeek( xFilial('TFH')+ oMdlG:GetValue("TFH_COD"))
		nSld := oMdlG:GetValue("TFH_QTDVEN") - TFH->TFH_QTDVEN
		If nSld <> 0
			If (TFH->TFH_SLD + nSld) < 0
				cMsgSolu := STR0242 + cValTOChar(oMdlG:GetValue("TFH_QTDVEN")+((TFH->TFH_SLD + nSld)* -1))+STR0243+oMdlG:GetValue("TFH_COD") //"Não é possível reduzir a quantidade desse item, pois isso irá gerar inconsistência entre o apontado x orçado"//"Inclua quantidade igual ou maior que "##" ou estorne apontamentos do material de código: "
				Help( " ", 1, "AT740TFHTQTD", Nil, STR0244, 1,,,,,,,;
						{cMsgSolu} )
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If oMdlFull <> Nil .And. (oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F')
	If !cAcao == "DELETE" .And. !IsInCallStack("ATCPYDATA")
		If oMdlG:GetValue("TFH_COBCTR") != "2" .And. cAcao <> Nil
			lRet := At740VlVlr("TFH_MC","TFH_PRCVEN")
		EndIf
	EndIf
EndIf

If lRet
	lRet := VldDatas(oMdlG,nLine)
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTFU
	Não permite a inserção de TFU_CODABN duplicado no contrato

@sample		PosLinTFU()

@since		09/08/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Function PosLinTFU(oMdlHE, nLine, cAcao, cCampo)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local aCodHe		:= {}
Local lRet 			:= .T.
Local nX

For nX := 1 To oMdlHE:Length()
    oMdlHE:GoLine(nX)
	If !oMdlHE:IsDeleted()
		If EMPTY(aCodHe) .OR. ASCAN(aCodHe, oMdlHE:GetValue("TFU_CODABN")) == 0
			AADD(aCodHe, oMdlHE:GetValue("TFU_CODABN"))
		Else
			Help(,, "PosLinTFU",, "A hora extra de codigo " + oMdlHE:GetValue("TFU_CODABN") + " esta duplicada.", 1, 0) //"A competência " ## " está duplicada."
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nX

FWRestRows( aSaveLines )
RestArea(aArea)

Return (lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldUM
	 Valida a unidade de medida digitada

@sample		At740VldUM()

@since		19/12/2013
@version	P11.90

@return 	lValido, Logico, define se a unidade de medida é valida (.T.) ou não (.F.)
/*/
//------------------------------------------------------------------------------
Function At740VldUM()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lValido := .F.

lValido := Empty( M->TEV_UM )

If !lValido
	DbSelectArea('SAH')
	SAH->( DbSetOrder( 1 ) )  // AH_FILIAL+AH_UNIMED

	lValido := SAH->( DbSeek( xFilial('SAH')+M->TEV_UM ) )

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lValido

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Reserv
	 Valida a alteração de qtde e as datas nos itens com reserva

@sample		At740Reserv()

@since		24/02/2014
@version	P12

@return 	lRet, Logico, define se prossegue com a alteração ou não
/*/
//------------------------------------------------------------------------------
Function At740Reserv( oMdl, cCampo, xValueNew, nLine, xValueOld )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet        := .T.

If !IsInCallStack('At740CpyMdl') .And. !Empty( oMdl:GetValue('TFI_RESERV') )

	lRet := MsgNoYes( STR0039 + CRLF + ;  // 'Esta alteração fará com que a reserva seja cancelada'
				STR0040, STR0041 )  // 'Deseja prosseguir?' #### 'Aviso'

	If lRet
		aAdd( aCancReserv, { oMdl:GetValue('TFI_COD'), oMdl:GetValue('TFI_RESERV') } )
		oMdl:SetValue('TFI_RESERV', ' ' ) // remove a relação com a reserva
	EndIf

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FinRes
	 Executa a finalização quando realiza a gravação do orçamento de serviços

@sample		At740FinRes()

@since		24/02/2014
@version	P12

@param 	oMdlOrcamento, objeto, objeto principal do orçamento de serviços
@param 	lGravação, logico, define se está na gravação ou no cancelamento (fechar sem salvar)
/*/
//------------------------------------------------------------------------------
Function At740FinRes( oOrcamento, lCommit )

Local aSave         := GetArea()
Local aSaveTFI       := TFI->( GetArea() )
Local aSaveTEW       := TEW->( GetArea() )
Local aSaveLines	:= FWSaveRows()
Local nLocais       := 0
Local nItensLE      := 0
Local oReserva      := FwLoadModel('TECA825C')
Local aRows         := FwSaveRows(oOrcamento)
Local oLocais       := oOrcamento:GetModel('TFL_LOC')
Local oItensLE      := oOrcamento:GetModel('TFI_LE')
Local nPosReserv     := 0
Local nTamDados      := 0
Local xAux          := Nil
Local lOk           := .T.

DbSelectArea('TFI')
TFI->( DbSetOrder( 6 ) ) // TFI_FILIAL+TFI_RESERV

For nLocais := 1 To oLocais:Length()

	oLocais:GoLine( nLocais )
	For nItensLE := 1 To oItensLE:Length()

		oItensLE:GoLine( nItensLE )
		nPosReserv := aScan( aCancReserv, {|x| x[1] == oItensLE:GetValue('TFI_COD') } )
		If nPosReserv > 0
			If lCommit .And. TFI->(DbSeek(xFilial('TFI')+aCancReserv[nPosReserv,2]))
				//---------------------------------------
				//   Executa o cancelamento das reservas
				oReserva:SetOperation(MODEL_OPERATION_UPDATE)

				At825CText( STR0042 )  // 'Item da venda de locação alterado'
				At825CTipo( DEF_RES_CANCELADA )

				lOk := oReserva:Activate()  // Ativa o objeto
				lOk := oReserva:VldData()  // Valida os dados
				lOk := oReserva:CommitData()   // realiza o cancelamento

				If !lOk
					oReserva:CancelData()
				EndIf

				oReserva:DeActivate()
			EndIf
			//---------------------------------------
			//   remove do array as informações da reserva
			nTamDados := Len(aCancReserv)
			aDel( aCancReserv, nPosReserv )
			aSize( aCancReserv, nTamDados-1 )
		EndIf

	Next nItensLE

Next nLocais

oReserva:Destroy()

FwRestRows( aRows, oOrcamento )
FWRestRows( aSaveLines )
RestArea( aSaveTEW )
RestArea( aSaveTFI )
RestArea( aSave )

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740LdLuc
	 Atualiza a Taxa de Lucro e administrativa para os demais itens

@sample		At740LdLuc()

@since		21/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740LdLuc(cTp)

Local oMdl   		:= FwModelActive()
Local oMdlLocal		:= oMdl:GetModel("TFL_LOC")
Local oMdlRH		:= oMdl:GetModel("TFF_RH")
Local oMdlMI		:= oMdl:GetModel("TFG_MI")
Local oMdlMC		:= oMdl:GetModel("TFH_MC")
Local oMdlLE 		:= oMdl:GetModel("TFI_LE")
Local oMdlUni 		:= Nil
Local oMdlArm		:= Nil
Local oMdlCobLe		:= oMdl:GetModel("TEV_ADICIO")
Local nLinLocal		:= 0
Local nLinRh		:= 0
Local nLinMi		:= 0
Local nLinMc		:= 0
Local nLinLe		:= 0
Local nLinCob 		:= 0
Local nPerc			:= 0
Local aSaveRows 	:= {}
Local lValid		:= .F.
Local aValid		:= {}
Local lGsOrcUnif 	:= FindFunction("TecGsUnif") .And. TecGsUnif()
Local nX			:= 0
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()

aSaveRows := FwSaveRows()

If cTp == "1"
	nPerc := oMdl:GetModel( "TFJ_REFER" ):GetValue( "TFJ_LUCRO" )
Else
	nPerc := oMdl:GetModel( "TFJ_REFER" ):GetValue( "TFJ_ADM" )
EndIf

aValid := At740Valid(cTp,nPerc)

If Len(aValid) > 0
	If MsgYesNo(STR0043) //"Deseja substituir as taxas de valores já definidas para os itens?"
		lValid := .F.
	Else
		lValid := .T.
	EndIf
EndIf

For nLinLocal := 1 To oMdlLocal:Length()
	oMdlLocal:GoLine( nLinLocal )
	If !oMdlLocal:IsDeleted()
		For nLinRh := 1 to oMdlRH:Length() //Recursos humanos
			oMdlRH:GoLine( nLinRh ) //Posiciona na linha
			If !oMdlRH:IsDeleted() //Se a linha não estiver deletada
				If !Empty(oMdlRH:GetValue("TFF_PRODUT"))
					If cTp == "1" //1 = Taxa de Lucro
						If !lValid
							oMdlRH:SetValue("TFF_LUCRO",nPerc)
						Else
							//Nao substituir
							nPos := Ascan(aValid,{|x| x[2] == "TFF"+Alltrim(STR(nLinRh))+"1"})
							If nPos > 0
								oMdlRH:SetValue("TFF_LUCRO",aValid[nPos,1])
							Else
								oMdlRH:SetValue("TFF_LUCRO",nPerc)
							EndIf
						EndIf
					Else //2 = Taxa Administrativa
						If !lValid
							oMdlRH:SetValue("TFF_ADM",nPerc)
						Else
							//Nao substituir
							nPos := Ascan(aValid,{|x| x[2] == "TFF"+Alltrim(STR(nLinRh))+"2"})
							If nPos > 0
								oMdlRH:SetValue("TFF_ADM",aValid[nPos,1])
							Else
								oMdlRH:SetValue("TFF_ADM",nPerc)
							EndIf
						EndIf
					EndIf
				EndIf
				For nLinMi := 1 to oMdlMI:Length() //Materiais de Implantação
					oMdlMI:GoLine( nLinMi )
					If !oMdlMI:IsDeleted()
						If !Empty(oMdlMI:GetValue("TFG_PRODUT"))
							If cTp == "1" //1 = Taxa de Lucro
								If !lValid
									oMdlMI:SetValue("TFG_LUCRO",nPerc)
								Else
									//Nao substituir
									nPos := Ascan(aValid,{|x| x[2] == "TFG"+Alltrim(STR(nLinMi))+"1"})
									If nPos > 0
										oMdlMI:SetValue("TFG_LUCRO",aValid[nPos,1])
									Else
										oMdlMI:SetValue("TFG_LUCRO",nPerc)
									EndIf
								EndIf
							Else //2 = Taxa Administrativa
								If !lValid
									oMdlMI:SetValue("TFG_ADM",nPerc)
								Else
									//Nao substituir
									nPos := Ascan(aValid,{|x| x[2] == "TFG"+Alltrim(STR(nLinMi))+"2"})
									If nPos > 0
										oMdlMI:SetValue("TFG_ADM",aValid[nPos,1])
									Else
										oMdlMI:SetValue("TFG_ADM",nPerc)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Next nLinMi

				For nLinMc := 1 to oMdlMC:Length() //Materiais de Consumo
					oMdlMC:GoLine( nLinMc )
					If !oMdlMC:IsDeleted()
						If !Empty(oMdlMC:GetValue("TFH_PRODUT"))
							If cTp == "1" //1 = Taxa de Lucro
								If !lValid
									oMdlMC:SetValue("TFH_LUCRO",nPerc)
								Else
									//Nao substituir
									nPos := Ascan(aValid,{|x| x[2] == "TFH"+Alltrim(STR(nLinMc))+"1"})
									If nPos > 0
										oMdlMC:SetValue("TFH_LUCRO",aValid[nPos,1])
									Else
										oMdlMC:SetValue("TFH_LUCRO",nPerc)
									EndIf
								EndIf
							Else //2 = Taxa Administrativa
								If !lValid
									oMdlMC:SetValue("TFH_ADM",nPerc)
								Else
									//Nao substituir
									nPos := Ascan(aValid,{|x| x[2] == "TFH"+Alltrim(STR(nLinMc))+"2"})
									If nPos > 0
										oMdlMC:SetValue("TFH_ADM",aValid[nPos,1])
									Else
										oMdlMC:SetValue("TFH_ADM",nPerc)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Next nLinMc
				If lGsOrcUnif
					oMdlUni := oMdl:GetModel("TXPDETAIL")
					For nX := 1 to oMdlUni:Length() //Uniformes
						oMdlUni:GoLine( nX )
						If !oMdlUni:IsDeleted()
							If !Empty(oMdlUni:GetValue("TXP_CODUNI"))
								If cTp == "1" //1 = Taxa de Lucro
									If !lValid
										oMdlUni:SetValue("TXP_LUCRO",nPerc)
									Else
										//Nao substituir
										nPos := Ascan(aValid,{|x| x[2] == "TXP"+Alltrim(STR(nX))+"1"})
										If nPos > 0
											oMdlUni:SetValue("TXP_LUCRO",aValid[nPos,1])
										Else
											oMdlUni:SetValue("TXP_LUCRO",nPerc)
										EndIf
									EndIf
								Else //2 = Taxa Administrativa
									If !lValid
										oMdlUni:SetValue("TXP_ADM",nPerc)
									Else
										//Nao substituir
										nPos := Ascan(aValid,{|x| x[2] == "TXP"+Alltrim(STR(nX))+"2"})
										If nPos > 0
											oMdlUni:SetValue("TXP_ADM",aValid[nPos,1])
										Else
											oMdlUni:SetValue("TXP_ADM",nPerc)
										EndIf
									EndIf
								EndIf
							Endif
						Endif
					Next nX
				Endif
				If lGsOrcArma
					oMdlArm := oMdl:GetModel("TXQDETAIL")
					For nX := 1 to oMdlArm:Length() //Uniformes
						oMdlArm:GoLine( nX )
						If !oMdlArm:IsDeleted()
							If !Empty(oMdlArm:GetValue("TXQ_CODPRD"))
								If cTp == "1" //1 = Taxa de Lucro
									If !lValid
										oMdlArm:SetValue("TXQ_LUCRO",nPerc)
									Else
										//Nao substituir
										nPos := Ascan(aValid,{|x| x[2] == "TXQ"+Alltrim(STR(nX))+"1"})
										If nPos > 0
											oMdlArm:SetValue("TXQ_LUCRO",aValid[nPos,1])
										Else
											oMdlArm:SetValue("TXQ_LUCRO",nPerc)
										EndIf
									EndIf
								Else //2 = Taxa Administrativa
									If !lValid
										oMdlArm:SetValue("TXQ_ADM",nPerc)
									Else
										//Nao substituir
										nPos := Ascan(aValid,{|x| x[2] == "TXQ"+Alltrim(STR(nX))+"2"})
										If nPos > 0
											oMdlArm:SetValue("TXQ_ADM",aValid[nPos,1])
										Else
											oMdlArm:SetValue("TXQ_ADM",nPerc)
										EndIf
									EndIf
								EndIf
							Endif
						Endif
					Next nX
				Endif
			EndIf
		Next nLinRh

		For nLinLe := 1 To oMdlLE:Length()
			oMdlLE:GoLine( nLinLe )
			For nLinCob := 1 to oMdlCobLe:Length() //Cobrança de Locação
				oMdlCobLe:GoLine( nLinCob )
				If !oMdlCobLe:IsDeleted()
					If !Empty(oMdlCobLe:GetValue("TEV_MODCOB"))
						If cTp == "1" //1 = Taxa de Lucro
							If !lValid
								oMdlCobLe:SetValue("TEV_LUCRO",nPerc)
							Else
								//Nao substituir
								nPos := Ascan(aValid,{|x| x[2] == "TEV"+Alltrim(STR(nLinCob))+"1"})
								If nPos > 0
									oMdlCobLe:SetValue("TEV_LUCRO",aValid[nPos,1])
								Else
									oMdlCobLe:SetValue("TEV_LUCRO",nPerc)
								EndIf
							EndIf
						Else //2 = Taxa Administrativa
							If !lValid
								oMdlCobLe:SetValue("TEV_ADM",nPerc)
							Else
								//Nao substituir
								nPos := Ascan(aValid,{|x| x[2] == "TEV"+Alltrim(STR(nLinCob))+"2"})
								If nPos > 0
									oMdlCobLe:SetValue("TEV_ADM",aValid[nPos,1])
								Else
									oMdlCobLe:SetValue("TEV_ADM",nPerc)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nLinCob
		Next nLinLe
	EndIf
Next nLinLocal

FwRestRows( aSaveRows )
If !lGsPrecific
	nTLuc := oMdl:GetModel("TFJ_REFER"):GetValue("TFJ_LUCRO")
	nTAdm := oMdl:GetModel("TFJ_REFER"):GetValue("TFJ_ADM")
Endif
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlAcr
	 Atualiza os valores de Lucro e da taxa administrativa para os demais itens

@sample		At740VlAcr()

@since		24/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740VlAcr(cTp)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   	:= FwModelActive()
Local oMdlItm	:= oMdl:GetModel("TEV_ADICIO")
Local nVlAcr	:= 0

If cTp == "1"
	nVlAcr := (oMdlItm:GetValue("TEV_LUCRO")/100)*oMdlItm:GetValue("TEV_SUBTOT")
	If nVlAcr == 0
		oMdlItm:SetValue("TEV_TXLUCR", nVlAcr)
	EndIf
Else
	nVlAcr := (oMdlItm:GetValue("TEV_ADM")/100)*oMdlItm:GetValue("TEV_SUBTOT")
	If nVlAcr == 0
		oMdlItm:SetValue("TEV_TXADM", nVlAcr)
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nVlAcr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740LdLuc
	 Atualiza a Taxa de Lucro e administrativa para os demais itens

@sample		At740LdLuc()

@since		21/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740VlTEV(cModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   		:= FwModelActive()
Local oMdlTEV		:= oMdl:GetModel(cModel)
Local nVlr			:= 0
Local nVlAcrLuc	:= 0
Local nVlAcrAdm	:= 0

nVlAcrLuc := (1+(oMdlTEV:GetValue("TEV_LUCRO")/100))*oMdlTEV:GetValue("TEV_SUBTOT")
nVlAcrAdm := (1+(oMdlTEV:GetValue("TEV_ADM")/100))*oMdlTEV:GetValue("TEV_SUBTOT")

nVlr := (nVlAcrLuc + nVlAcrAdm)-(oMdlTEV:GetValue("TEV_SUBTOT"))

FWRestRows( aSaveLines )
RestArea(aArea)
Return nVlr


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740MatAc
	Gatilho dos valores de Lucro e da taxa administrativa para os itens de materiais

@sample		At740MatAc()

@since		24/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740MatAc(cTp,cModel,cTab)

Local aArea		:= GetArea()
Local aSaveLines	:= {}
Local oMdl   	:= FwModelActive()
Local oMdlItm	:= oMdl:GetModel(cModel)
Local nPerc	:= 0
Local nVlAcr	:= 0
Local nQtd	:= oMdlItm:GetValue(cTab+"_QTDVEN")
Local nPrcVen := oMdlItm:GetValue(cTab+"_PRCVEN")

aSaveLines := FWSaveRows()

If cTp == "1"
	nPerc := oMdlItm:GetValue(cTab+"_LUCRO") / 100
Else
	nPerc := oMdlItm:GetValue(cTab+"_ADM") / 100
EndIf

nVlAcr := ROUND((nPerc * nPrcVen), TamSX3("CNB_VLUNIT")[2]) * nQtd

FWRestRows( aSaveLines )
RestArea(aArea)
Return nVlAcr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlTot
	 Gatilho para preencher o campo total geral dos itens de materiais

@sample		At740VlTot()

@since		21/02/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At740VlTot(cModel,cTab)

Local aArea			:= GetArea()
Local aSaveLines	:= {}
Local oMdl			:= FwModelActive()
Local oView			:= FwViewActive()
Local oMdlItm		:= oMdl:GetModel(cModel)
Local nVlr			:= 0
Local nVlrLuc		:= 0
Local nVlrAdm		:= 0
Local nPrcVen		:= oMdlItm:GetValue(cTab+"_PRCVEN")
Local nQtdVen		:= oMdlItm:GetValue(cTab+"_QTDVEN")
Local nVidMes		:= oMdlItm:GetValue(cTab+"_VIDMES")
Local nPercLucro	:= 0
Local nPercAdm		:= 0
Local lQtdUni		:= TXP->( ColumnPos('TXP_QTDUNI') ) > 0
Local cIDView       := ""
Local nPosIDView    := 0
Local nPerDesc      := 0

aSaveLines := FWSaveRows()

If lQtdUni .And. cTab == "TXP"
	nQtdVen := oMdlItm:GetValue(cTab+"_QTDUNI")
EndIf
If !lGsPrecific
	nPercLucro := (1+(oMdlItm:GetValue(cTab+"_LUCRO")/100))
	nPercAdm := (1+(oMdlItm:GetValue(cTab+"_ADM")/100))

	nVlrLuc := nQtdVen * ROUND(nPrcVen * nPercLucro, TamSX3("CNB_VLUNIT")[2])
	nVlrAdm := nQtdVen * ROUND(nPrcVen * nPercAdm, TamSX3("CNB_VLUNIT")[2])

	nVlr := (nVlrLuc + nVlrAdm)-(nQtdVen)*nPrcVen
Else
	nVlr := nQtdVen*nPrcVen
Endif

If cTab $ "TFG|TFH"
	nPerDesc := oMdlItm:GetValue(cTab+"_DESCON")
	nVlr := nVlr - ((nVlr * nPerDesc) / 100)
EndIf

If nVidMes > 0
	nVlr := nVlr / nVidMes
EndIf

// Não retirar esse refresh pois quando existe mais de um Posto com mais de um MI/MC/Uniforme/Arma ele se perde na atualização da tela
If !IsBlind() .And. ValType( oView ) == "O"
	nPosIDView := aScan(oView:aViews, { |x| x[6] == cModel})
	If nPosIDView > 0
		cIDView := oView:aViews[nPosIDView][1]
		oView:Refresh(cIDView)
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return nVlr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740RhVlr
	 Gatilho para os itens de recursos humanos

@sample		At740RhVlr()

@since		21/02/2013
@version	P11.90


/*/
//------------------------------------------------------------------------------
Function At740RhVlr(cTp)

Local aArea		:= GetArea()
Local aSaveLines	:= {}
Local oMdl   	:= FwModelActive()
Local oMdlItm	:= oMdl:GetModel("TFF_RH")
Local nQtde	:= oMdlItm:GetValue("TFF_QTDVEN")
Local nPrc		:= oMdlItm:GetValue("TFF_PRCVEN")
Local nVlAcr	:= 0
Local nVlrLucro	:= 0

aSaveLines := FWSaveRows()

If cTp == "1"
	nVlrLucro	:= oMdlItm:GetValue("TFF_LUCRO")/100
	nVlAcr 		:= ROUND(nVlrLucro * nPrc, TamSX3("CNB_VLUNIT")[2]) * nQtde
	If nVlAcr == 0
		oMdlItm:SetValue("TFF_TXLUCR", nVlAcr)
	EndIf
Else
	nVlAcr := ROUND(((oMdlItm:GetValue("TFF_ADM")/100) * nPrc), TamSX3("CNB_VLUNIT")[2] ) * nQtde
	If nVlAcr == 0
		oMdlItm:SetValue("TFF_TXADM", nVlAcr)
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nVlAcr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Valid
	 Validação dos campos das Taxas de Lucro e administrativa nos itens

@sample		At740Valid()

@since		21/02/2013
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At740Valid(cTp,nPerct)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   		:= FwModelActive()
Local oMdlLocal	:= oMdl:GetModel("TFL_LOC")
Local oMdlRH		:= oMdl:GetModel("TFF_RH")
Local oMdlMI		:= oMdl:GetModel("TFG_MI")
Local oMdlMC		:= oMdl:GetModel("TFH_MC")
Local oMdlLE		:= oMdl:GetModel("TEV_ADICIO")
Local oMdlUni		:= Nil
Local oMdlArm		:= Nil
Local nLinLocal	:= 0
Local nLRh			:= 0
Local nLMi			:= 0
Local nLMc			:= 0
Local nLLe			:= 0
Local aDados		:= {}
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local nX			:= 0
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()

For nLinLocal := 1 To oMdlLocal:Length()

	oMdlLocal:GoLine( nLinLocal )

	If !oMdlLocal:IsDeleted()

		For nLRh := 1 to oMdlRH:Length() //Recursos humanos

			oMdlRH:GoLine( nLRh )

			If !oMdlRH:IsDeleted()

				If cTp == "1"
					If !Empty(oMdlRH:GetValue("TFF_LUCRO")) .AND. oMdlRH:GetValue("TFF_LUCRO") <> nPerct .AND. oMdlRH:GetValue("TFF_LUCRO") <> nTLuc
						aAdd(aDados,{oMdlRH:GetValue("TFF_LUCRO"),"TFF"+Alltrim(STR(nLRh))+cTp})
					EndIf
				Else
					If !Empty(oMdlRH:GetValue("TFF_ADM")) .AND. oMdlRH:GetValue("TFF_ADM") <> nPerct .AND. oMdlRH:GetValue("TFF_ADM") <> nTAdm
						aAdd(aDados,{oMdlRH:GetValue("TFF_ADM"),"TFF"+Alltrim(STR(nLRh))+cTp})
					EndIf
				EndIf

				For nLMi := 1 to oMdlMI:Length() //Materiais de Implantação

					oMdlMI:GoLine( nLMi )

						If !oMdlMI:IsDeleted()

							If cTp == "1"
								If !Empty(oMdlMI:GetValue("TFG_LUCRO")) .AND. oMdlMI:GetValue("TFG_LUCRO") <> nPerct .AND. oMdlMI:GetValue("TFG_LUCRO") <> nTLuc
									aAdd(aDados,{oMdlMI:GetValue("TFG_LUCRO"),"TFG"+Alltrim(STR(nLMi))+cTp})
								EndIf
							Else
								If !Empty(oMdlMI:GetValue("TFG_ADM")) .AND. oMdlMI:GetValue("TFG_ADM") <> nPerct .AND. oMdlMI:GetValue("TFG_ADM") <> nTAdm
									aAdd(aDados,{oMdlMI:GetValue("TFG_ADM"),"TFG"+Alltrim(STR(nLMi))+cTp})
								EndIf
							EndIf

						EndIf

				Next nLMi

				For nLMc := 1 to oMdlMC:Length() //Materiais de Consumo

					oMdlMC:GoLine( nLMc )

						If !oMdlMC:IsDeleted()

							If cTp == "1"
								If !Empty(oMdlMC:GetValue("TFH_LUCRO")) .AND. oMdlMC:GetValue("TFH_LUCRO") <> nPerct .AND. oMdlMC:GetValue("TFH_LUCRO") <> nTLuc
									aAdd(aDados,{oMdlMC:GetValue("TFH_LUCRO"),"TFH"+Alltrim(STR(nLMc))+cTp})
								EndIf
							Else
								If !Empty(oMdlMC:GetValue("TFH_ADM")) .AND. oMdlMC:GetValue("TFH_ADM") <> nPerct .AND. oMdlMC:GetValue("TFH_ADM") <> nTAdm
									aAdd(aDados,{oMdlMC:GetValue("TFH_ADM"),"TFH"+Alltrim(STR(nLMc))+cTp})
								EndIf
							EndIf

						EndIf

				Next nLMc

				If lGsOrcUnif
					oMdlUni	:= oMdl:GetModel("TXPDETAIL")
					For nX := 1 to oMdlUni:Length() //Uniformes
						oMdlUni:GoLine( nX )
						If !oMdlUni:IsDeleted()
							If cTp == "1"
								If !Empty(oMdlUni:GetValue("TXP_LUCRO")) .AND. oMdlUni:GetValue("TXP_LUCRO") <> nPerct .AND. oMdlUni:GetValue("TXP_LUCRO") <> nTLuc
									aAdd(aDados,{oMdlUni:GetValue("TXP_LUCRO"),"TXP"+Alltrim(STR(nX))+cTp})
								EndIf
							Else
								If !Empty(oMdlUni:GetValue("TXP_ADM")) .AND. oMdlUni:GetValue("TXP_ADM") <> nPerct .AND. oMdlUni:GetValue("TXP_ADM") <> nTAdm
									aAdd(aDados,{oMdlUni:GetValue("TXP_ADM"),"TXP"+Alltrim(STR(nX))+cTp})
								EndIf
							EndIf
						EndIf
					Next nX
				Endif
				If lGsOrcArma
					oMdlArm	:= oMdl:GetModel("TXQDETAIL")
					For nX := 1 to oMdlArm:Length() //Armamento
						oMdlArm:GoLine( nX )
						If !oMdlArm:IsDeleted()
							If cTp == "1"
								If !Empty(oMdlArm:GetValue("TXQ_LUCRO")) .AND. oMdlArm:GetValue("TXQ_LUCRO") <> nPerct .AND. oMdlArm:GetValue("TXQ_LUCRO") <> nTLuc
									aAdd(aDados,{oMdlArm:GetValue("TXQ_LUCRO"),"TXQ"+Alltrim(STR(nX))+cTp})
								EndIf
							Else
								If !Empty(oMdlArm:GetValue("TXQ_ADM")) .AND. oMdlArm:GetValue("TXQ_ADM") <> nPerct .AND. oMdlArm:GetValue("TXQ_ADM") <> nTAdm
									aAdd(aDados,{oMdlArm:GetValue("TXQ_ADM"),"TXQ"+Alltrim(STR(nX))+cTp})
								EndIf
							EndIf
						EndIf
					Next nX
				Endif

			EndIf

		Next nLRh


		For nLLe := 1 to oMdlLE:Length() //Cobrança de Locação

			oMdlLE:GoLine( nLLe )

			If !oMdlLE:IsDeleted()

				If cTp == "1"
					If !EMpty(oMdlLE:GetValue("TEV_LUCRO")) .AND. oMdlLE:GetValue("TEV_LUCRO") <> nPerct .AND. oMdlLE:GetValue("TEV_LUCRO") <> nTLuc
						aAdd(aDados,{oMdlLE:GetValue("TEV_LUCRO"),"TEV"+Alltrim(STR(nLLe))+cTp})
					EndIf
				Else
					If !Empty(oMdlLE:GetValue("TEV_ADM")) .AND. oMdlLE:GetValue("TEV_ADM") <> nPerct .AND. oMdlLE:GetValue("TEV_ADM") <> nTAdm
						aAdd(aDados,{oMdlLE:GetValue("TEV_ADM"),"TEV"+Alltrim(STR(nLLe))+cTp})
					EndIf
				EndIf

			EndIf

		Next nLLe

	EndIf

Next nLinLocal

FWRestRows( aSaveLines )
RestArea(aArea)
Return aDados
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlVlr
Função para validação dos valores para os recursos humanos
@sample 	At740VlVlr(oModel,cCpoSelec)
@since		15/04/2014
@version	P12
@return 	lRet, Lógico, retorna .T. se data for válida.
@param  	cModelo, Caracter, nome do modelo de dados principal.
@param  	cCpoSelec, Caracter, nome do campo da data selecionada para validação.
/*/
//------------------------------------------------------------------------------
Function At740VlVlr(cModel,cCpoSelec,oModel)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl			:= Nil
Local nPrcVenda		:= 0
Local lCobrContr	:= .F.
Local lRet			:= .T.
Local lPermLocZero 	:= At680Perm( , __cUserId, '032' )

Default oModel		:= FwModelActive()

If oModel != Nil
	If (oModel:GetId() == "TECA740" .Or. oModel:GetId() == "TECA740F")
		oMdl := oModel:GetModel(cModel)
	Else
		oMdl := oModel
	EndIf
	If oMdl != Nil

		nPrcVenda	:= oMdl:GetValue(cCpoSelec)

		If nPrcVenda < 0
			Help(,,"At740VlVlr",,STR0114,1,0) //"O valor do preço de venda não pode ser negativo."
			lRet := .F.
		Else
			If Left(cCpoSelec,3) == "TFF"
				lCobrContr := (oMdl:GetValue("TFF_COBCTR") <> "2")
			ElseIf Left(cCpoSelec,3) == "TFG"
				lCobrContr := (oMdl:GetValue("TFG_COBCTR") <> "2")
			ElseIf Left(cCpoSelec,3) == "TFH"
				lCobrContr := (oMdl:GetValue("TFH_COBCTR") <> "2")
			EndIf

			If nPrcVenda == 0 .And. lCobrContr .And. !IsInCallStack("LoadXmlData") .And.;
				!IsInCallStack("ATCPYDATA") .And.;
				!IsInCallStack("A600GrvOrc") .And. !IsInCallStack("At870GerOrc") .And.;
				!IsInCallStack("At740FTrgG") .And. !lPermLocZero

				Help(,,"At740VlVlr",,STR0054,1,0) // "O valor do preço de venda deve ser maior do que zeros."
				lRet	:= .F.
			EndIf
		EndIf

	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldTFF

Valida se existe o recurso ja criado na configuração de alocação do atendente

@sample 	At740VldTFF(cContrato,cCodTFF,cFilTFF)

@since		24/04/2014
@version	P12

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	cContrato, Caracter, Numero do contrato para a consistencia.
@param  	cCodTFF, Caracter, codigo do recurso para a consistencia.
@param  	cFilTFF, Caracter, filial do recurso para a consistencia.

/*/
//------------------------------------------------------------------------------
Function At740VldTFF( cContrato, cCodTFF, cFilTFF )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet  := .T.

Default cFilTFF := xFilial("TFF", cFilAnt)

dbSelectArea("ABQ")
ABQ->(DbSetOrder(3)) //ABQ_FILIAL + ABQ_CODTFF+ ABQ_FILTFF


lRet := !ABQ->(DbSeek(xFilial("ABQ")+ cCodTFF + cFilTFF))

FWRestRows( aSaveLines )
RestArea(aArea)
Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} AT740F4()
Rotina consulta estoque através do último produto SB1 que está posicionado


@author arthur.colado
@since 07/04/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Function AT740F4()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cFilBkp := cFilAnt
Local cReadVar := ReadVar()
Local cConsulta := ""
Local oMdl := FwModelActive()

Set Key VK_F4 TO

If FWModeAccess("SB1")=="E"
	cFilAnt := SB1->B1_FILIAL
EndIf

If cReadVar == "M->TFG_QTDVEN"
	cConsulta := oMdl:getModel("TFG_MI"):GetValue("TFG_PRODUT")
EndIf

If cReadVar == "M->TFH_QTDVEN"
	cConsulta := oMdl:getModel("TFH_MC"):GetValue("TFH_PRODUT")
EndIf

If !Empty(cConsulta)
	MaViewSB2(cConsulta)
EndIf

cFilAnt := cFilBkp
Set Key VK_F4 TO AT740F4()

FWRestRows( aSaveLines )
RestArea(aArea)
Return Nil

/*/{Protheus.doc} At740Refre
Reposiciona grid do local de atendimento
@since 20/08/2014
@version 11.9
@param oView, objeto, View Orçamento de Serviços

/*/
Function At740Refre(oView)
Local aIdsModels 	:= oView:GetModelsIds()
Local aFolder		:= {}
Local lTecItExtOp 	:= IsInCallStack("At190dGrOrc")
Local cCodLoc 		:= ""
Local aArea			:= GetArea()

If oView:GetOperation() <> MODEL_OPERATION_VIEW
	If lTecItExtOp .And. !Empty(cCodLoc :=  At190dGetLc())
		oView:GetModel("TFL_LOC"):SeekLine({{"TFL_LOCAL",cCodLoc}})
		oView:Refresh("TFL_LOC")
	Else
		oView:GoLine('TFL_LOC',1) 	//VIEW_LOC
	Endif
	If aScan( aIdsModels, {|x| x=='TFF_RH' } ) > 0
		oView:GoLine('TFF_RH',1) 	//VIEW_RH
	EndIf
	If aScan( aIdsModels, {|x| x=='TFI_LE' } ) > 0
		oView:GoLine('TFI_LE',1) 	//VIEW_LE
	EndIf
EndIf

//Controle dos totais do recorrente
If oView:GetModel():GetId() == "TECA740F"
	aFolder := oView:GetFolderActive("ABAS", 2)

	If oView:GetOperation() == MODEL_OPERATION_INSERT
		oView:HideFolder("ABAS", STR0138,2) // "Resumo Geral Recorrente"
	Else
		If TFJ->TFJ_CNTREC == '1'
			oView:HideFolder("ABAS", STR0139,2) // "Resumo Geral
		Else
			oView:HideFolder("ABAS", STR0138,2) // "Resumo Geral Recorrente"
		EndIf
	EndIf

	oView:SelectFolder("ABAS", aFolder[2],2) // "Locais de Atendimento"

Endif

RestArea(aArea)
Return

/*/{Protheus.doc} At740VlSeq
Valida a Sequencia do Turno
@since 20/08/2014
@version 11.9
@param oModel, objeto, MOdel do Orçamento de Serviços
@return lRet, Sequencia do turno existente

/*/
Function At740VlSeq(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet			:= .T.
Local cFil			:= ""
Local cSeq			:= ""
Local cTno			:= ""
Local oTFF			:= Nil
Local aAreaSPJ	:= SPJ->(GetArea())

Default oModel := FwModelActive()

oTFF := oModel:GetModel("TFF_RH")

If oTFF <> Nil

	cTno := oTFF:GetValue("TFF_TURNO")
	cSeq := oTFF:GetValue("TFF_SEQTRN")

	If !Empty(cSeq)
		cFil	:= xFilial( "SPJ" , xFilial("SRA") )
		lRet := SPJ->( MsSeek( cFil + cTno + cSeq , .F. ) )

		If !( lRet )
			Help( ' ' , 1 , 'SEQTURNINV' , , OemToAnsi( STR0055 ) , 1 , 0 ) //Sequencia Nao Cadastrada Para o Turno
		EndIf
	EndIf
EndIf

RestArea(aAreaSPJ)
FWRestRows( aSaveLines )
RestArea(aArea)
Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VerVB

Função para validar se existe um vinculo de beneficio que ainda esta ativo, isto é,
com a data final não preenchida - LY_DTFIM para o item do RH.

@sample 	At740VerVB(cCodTFF)

@since		24/06/2015
@version	P12

@return 	lRet, Lógico

@param  	cCodTFF, Caracter, codigo do item do RH

/*/
//------------------------------------------------------------------------------
Function At740VerVB(cCodTFF)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet			:= .T.
Local cAliasSLY	:= GetNextAlias()

IF !Empty(cCodTFF)
	// Filtra os Beneficios
	BeginSql Alias cAliasSLY
		COLUMN LY_DTFIM AS DATE
		SELECT	LY_DTFIM
		FROM %table:SLY% SLY
		WHERE
			SLY.LY_FILIAL = %xFilial:SLY% AND
			SUBSTRING(SLY.LY_CHVENT,1,6) = %Exp:cCodTFF% AND
			SLY.LY_DTFIM = ' ' AND
			SLY.%NotDel%
 	EndSql

	lRet := (cAliasSLY)->(Eof())

	DbSelectArea(cAliasSLY)
	(cAliasSLY)->(DbCloseArea())
ENDIF

FWRestRows( aSaveLines )
RestArea(aArea)
RETURN lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F740LockGrd

Verifica se as Grids filhas poderão ser alteradas ou não de acordo com a escolha do campo
TFJ_GESMAT no cabeçalho

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function F740LockGrd(oMdlGer)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cGesMat := M->TFJ_GESMAT
Local lRet := .T.
Local lMINoIns := .F.
Local lMCNoIns := .F.
Default oMdlGer	:= FWModelActive() //Recuperando o model ativo da interface


//Quando o campo gestão de materiais for Material por valor ou percentual do recurso
//eu não permito manutenções nas Grids de Material de Implantação e Material de Consumo
If !IsInCallStack("At870GerOrc")

	If cGesMat == '2' .Or. cGesMat == '3'

		lMINoIns := .T.
		lMCNoIns := .T.
	ElseIf cGesMat == "4" //MI/Por Item/MC por valor
		lMCNoIns := .T.

	ElseIf cGesMat == "5" //MI por valor / MC por Item

		lMINoIns := .T.

	EndIf

	oMdlGer:GetModel('TFG_MI'):SetNoInsertLine(lMINoIns)
	oMdlGer:GetModel('TFG_MI'):SetNoUpdateLine(lMINoIns)
	oMdlGer:GetModel('TFG_MI'):SetNoDeleteLine(lMINoIns)

	oMdlGer:GetModel('TFH_MC'):SetNoInsertLine(lMCNoIns)
	oMdlGer:GetModel('TFH_MC'):SetNoUpdateLine(lMCNoIns)
	oMdlGer:GetModel('TFH_MC'):SetNoDeleteLine(lMCNoIns)
EndIf

If oMdlGer:GetValue('TFF_RH','TFF_ENCE') == '1'
	oMdlGer:GetModel('TFH_MC'):SetNoInsertLine(.T.)
	oMdlGer:GetModel('TFG_MI'):SetNoInsertLine(.T.)
EndIf



FWRestRows( aSaveLines )
RestArea(aArea)
Return ( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F740VldCmp

Verifica se o campo pode ser alterado de acordo com o tipo de gestão de material selecionado

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740VlMat()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet    := .T.
Local cCmp    := Readvar()
Local oModel  := FWModelActive() //Recuperando o model ativo da interface
Local oMdlVld := oModel:GetModel("TFF_RH")
Local cGesMat := oModel:GetModel('TFJ_REFER'):GetValue('TFJ_GESMAT')

Local nVlrAnt := 0
Local nVlrAtu := 0
Local lOk     := .F.

//Tratamento pois o gatilho executa a validação quando outros campos são alimentados
If 'TFF_VLRMAT' $ cCmp
	nVlrAtu := oMdlVld:GetValue("TFF_VLRMAT")
	lOk := .T.
EndIf

If 'TFF_VLRCON' $ cCmp
	nVlrAtu := oMdlVld:GetValue("TFF_VLRCON")
	lOk := .T.
EndIf

If lOk
	nVlrAnt := ( ( oMdlVld:GetValue('TFF_QTDVEN') * oMdlVld:GetValue('TFF_PRCVEN') ) * (oMdlVld:GetValue('TFF_PERMAT')/100 ) )
	If ( Empty( cGesMat ) .Or. cGesMat == '1' .Or. cGesMat == '3' )
		If  nVlrAnt <> nVlrAtu
			Help(,,'At740VlMat',,STR0069,1, 0 ) //"Este campo somente pode ser editado quando a Gestão de Materiais for igual a 'Material Por Valor'"
			lRet := .F.
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return ( lRet )

/*/
At740TDS


@sample 	At740TDS()

@since		20/07/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740TDS()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cCodTCZ  := ""
Local cDescTCZ := ""
Local oMdl   	 := FwModelActive()

If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

	cCodTCZ := oMdl:GetModel( "TDS_RH" ):GetValue( "TDS_CODTCZ" )
	cDescTCZ:= Posicione("TCZ",1,xFilial("TCZ") + cCodTCZ ,"TCZ->TCZ_DESC")

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return(cDescTCZ)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlGMat
Validação do campo de Gestão de Materiais (TFJ_GESMAT)
@sample 	At740VlGMat()
@since		20/07/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740VlGMat()
Local oModel  := FwModelActive()
Local oMdlTFJ := oModel:GetModel("TFJ_REFER")
Local cGESMat := oMdlTFJ:GetValue('TFJ_GESMAT')
Local lRet    := .T.

//1=Material;2=Material por valor;3=Percentual (obsoleto);4=MI Item/MC Valor;5=MI Valor/MC Item;6=Material por Item e valor
If cGESMat = "3"
	Help(,,"At740VlGMat", , STR0208,1, 0) //"Gestão de Material por percentual desabilitada, selecione a gestão por Valor e informe o campo percentual no item de RH"
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TrGMat
Gatilho do campo de Gestão de Materiais (TFJ_GESMAT)
@author 	flavio.vicco
@sample 	At740TrGMat()
@since		07/08/2023
/*/
//------------------------------------------------------------------------------
Function At740TrGMat()
Local aArea		:= {}
Local aSaveLines	:= {}
Local oModel  := FwModelActive()
Local oMdlTFJ := oModel:GetModel("TFJ_REFER")
Local cGESMat := oMdlTFJ:GetValue('TFJ_GESMAT')
Local lMaterial := (cGESMat  == "1" .Or. Empty(oMdlTFJ:GetValue('TFJ_GESMAT')))
Local nI := 0
Local nJ := 0
Local nX := 0
Local nVlrCon := 0
Local oMdlTFL := NIL
Local oMdlTFF := NIL
Local oMdlTFG := NIL
Local oMdlTFH := NIL
Local oView   := NIL
Local nOldTFL := NIL
Local nOldTFF := NIL
Local lRet    := .T.
Local lZera   := .F.
Local lCanDel := .F.
Local lVlrCon := TFF->( ColumnPos('TFF_VLRCON') ) > 0

If Empty(cGESMat)
	cGESMat := "1"
EndIf

If ExistFunc("At890NGMat") .AND. At890NGMat()
	//Verifica se a nova gestão de materiais está habilitada
	lRet := cGESMat $ "12456"
Else
	lRet := cGESMat $ "12"
EndIf

If lRet
	aArea		:= GetArea()
	aSaveLines	:= FWSaveRows()
	//Verifica se há valores de materiais
	oMdlTFL :=	oModel:GetModel("TFL_LOC")
	oMdlTFF :=	oModel:GetModel("TFF_RH")
	oMdlTFG :=	oModel:GetModel("TFG_MI")
	oMdlTFH :=	oModel:GetModel("TFH_MC")
	oView := FwViewActive()
	nOldTFL := oMdlTFL:GetLine()
	nOldTFF := oMdlTFF:GetLine()

	For nI:=1 To oMdlTFL:Length()
		oMdlTFL:GoLine(nI)
		For nJ:=1 To oMdlTFF:Length()
			oMdlTFF:GoLine(nJ)
			//Verifica se há valor preenchido ou se possui material informado
			If lVlrCon
				nVlrCon := oMdlTFF:GetValue("TFF_VLRCON")
			EndIf
			If ( ( lMaterial .AND.  (oMdlTFF:GetValue("TFF_VLRMAT") != 0  .OR. nVlrCon != 0 .OR.oMdlTFF:GetValue("TFF_PERMAT") != 0))  .Or. ;
				( (cGESMat $ "24" .AND. !oMdlTFH:IsEmpty()) .OR. (cGESMat $ "25" .AND. !oMdlTFG:IsEmpty()) ) )
				lZera := .T.
				Exit
			EndIf
		Next nJ
		If lZera
			Exit
		EndIf
	Next nI

	//Interação com usuário para zerar valores
	If lZera
		lRet := isBlind() .OR. MsgYesNo(STR0142)//"Os valores e os itens referentes aos materiais serão zerados. Deseja Continuar?"
	EndIf

	//Zera Valores de materiais
	If lRet .AND. lZera
		For nI:=1 To oMdlTFL:Length()
			oMdlTFL:GoLine(nI)
			//Limpa RH
			If lMaterial //Somente gestão por item
				For nJ:=1 To oMdlTFF:Length()
					oMdlTFF:GoLine(nJ)
					oMdlTFF:SetValue("TFF_VLRMAT", 0)
					oMdlTFF:SetValue("TFF_PERMAT", 0)
					If lVlrCon
						oMdlTFF:SetValue("TFF_VLRCON", 0)
					EndIf
				Next nJ
			EndIf
			If !lMaterial
				If oModel:GetId() == "TECA740"
					For nX:=1 To oMdlTFF:Length()
						oMdlTFF:GoLine(nX)
						//Limpa MI
						If cGESMat $ "2|5|"
							lCanDel := oMdlTFG:CanDeleteLine()
							oMdlTFG:SetNoDeleteLine(.F.)
							For nJ:=1 To oMdlTFG:Length()
								oMdlTFG:GoLine(nJ)
								If !oMdlTFG:IsDeleted() .And. !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
									oMdlTFG:DeleteLine()
								EndIf
							Next nJ
							oMdlTFG:SetNoDeleteLine(!lCanDel)
						EndIf
						//Limpa MC
						If cGESMat $ "2|4|"
							lCanDel := oMdlTFH:CanDeleteLine()
							oMdlTFH:SetNoDeleteLine(.F.)
							For nJ:=1 To oMdlTFH:Length()
								oMdlTFH:GoLine(nJ)
								If !oMdlTFH:IsDeleted() .And. !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
									oMdlTFH:DeleteLine()
								EndIf
							Next nJ
							oMdlTFH:SetNoDeleteLine(!lCanDel)
						EndIf
					Next nX
				Else
					//Limpa MI
					If cGESMat $ "2|5|"
						lCanDel := oMdlTFG:CanDeleteLine()
						oMdlTFG:SetNoDeleteLine(.F.)
						For nJ:=1 To oMdlTFG:Length()
							oMdlTFG:GoLine(nJ)
							If !oMdlTFG:IsDeleted() .And. !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
								oMdlTFG:DeleteLine()
							EndIf
						Next nJ
						oMdlTFG:SetNoDeleteLine(!lCanDel)
					EndIf
					//Limpa MC
					If cGESMat $ "2|4|"
						lCanDel := oMdlTFH:CanDeleteLine()
						oMdlTFH:SetNoDeleteLine(.F.)
						For nJ:=1 To oMdlTFH:Length()
							oMdlTFH:GoLine(nJ)
							If !oMdlTFH:IsDeleted() .And. !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
								oMdlTFH:DeleteLine()
							EndIf
						Next nJ
						oMdlTFH:SetNoDeleteLine(!lCanDel)
					EndIf
				EndIf
			EndIf
			At740AtTpr()
		Next nI

		oMdlTFL:GoLine(nOldTFL)
		oMdlTFF:GoLine(nOldTFF)

		If ValType(oView) == 'O'
			oView:Refresh("VIEW_RH")//Atualiza grid para que seja apresentado os valores alterados
		EndIf
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)

EndIf
Return lRet

//------------------------------------------------------------------------------
/*/
At740TDT
@sample 	At740TDT()
@since		20/07/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740TDT(cSeq)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cCodRBG  := ""
Local cCodEsc  := ""
Local cItEsc   := ""
Local cDesc    := ""
Local oMdl   	 := FwModelActive()

If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

	Do Case

	Case cSeq == '1'
		//codigo da habilidade
		cCodRBG := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_CODHAB" )
		cDesc   := Posicione("RBG",1,xFilial("RBG") + cCodRBG ,"RBG->RBG_DESC")
	Case cSeq == '2'
		//codigo escala
		cCodEsc := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_ESCALA" )
		cDesc   := Posicione("RBK",1,xFilial("RBK") + cCodEsc ,"RBK->RBK_DESCRI")
	Case cSeq == '3'
		//codigo item escala
		cCodEsc := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_ESCALA" )
		cItEsc  := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_ITESCA" )
		cDesc   := Posicione("RBL",1,xFilial("RBL") + cCodEsc + cItEsc ,"RBL->RBL_DESCRI")
	Case cSeq == '4'
		//codigo da habilidade X5
		cCodX5  := oMdl:GetModel( "TDT_RH" ):GetValue( "TDT_HABX5" )
		cDesc   := Posicione("SX5",1,xFilial("SX5")+"A4"+cCodX5,"X5_DESCRI")
	ENDCASE

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return(cDesc)

//------------------------------------------------------------------------------
/*/
At740TGV


@sample 	At740TGV()

@since		20/07/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740TGV()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cCodTGV  := ""
Local cDesc    := ""
Local oMdl   	 := FwModelActive()

If oMdl:GetId()=="TECA740" .Or. oMdl:GetId()=="TECA740F"

		//codigo da curso
		cCodTGV := oMdl:GetModel( "TGV_RH" ):GetValue( "TGV_CURSO" )
		cDesc   := Posicione("RA1",1,xFilial("RA1") + cCodTGV ,"RA1->RA1_DESC")

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return(cDesc)

/*/{Protheus.doc} At740LuTxA
	Copia o conteúdo preenchido nos campos de percentual de lucro e taxa administrativa
@return 	nValor, Numérico, percentual da tx adm ou do lucro
@param  	cCpoValor, Caracter, campo para ter o conteúdo copiado
/*/
Function At740LuTxA( cCpoValor )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local nValor := 0
Local oMdlFull := FwModelActive()

If oMdlFull <> Nil .And. ( oMdlFull:GetId()=='TECA740' .Or. oMdlFull:GetId()=='TECA740F' )
	nValor := oMdlFull:GetValue('TFJ_REFER', cCpoValor)
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} At740ConEq
Rotina para consulta de equipamentos

@author filipe.goncalves
@since 27/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Function At740ConEq()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel	:= FwModelActive()
Local oModConsu := FWLoadModel('TECA742')
Local dDtIni	:= oModel:GetValue('TFI_LE','TFI_PERINI')
Local dDtFim	:= oModel:GetValue('TFI_LE','TFI_PERFIM')
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

If !(Empty(dDtIni)) .And. !(Empty(dDtFim))
	oModConsu:SetOperation(3)
	oModConsu:Activate()
	FWExecView (STR0087, "TECA742"	,MODEL_OPERATION_INSERT,, {||.T.},,,aButtons,{||.T.},,, AT742LOAD(oModel, oModConsu))
Else
	Help(,,"AT740CON",,STR0088,1,0) //"Digite as datas de periodo do produto para utilizar a consulta de equipamentos"
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At740ValAM
Função para validar o tipo escolhido da apuração de medição

@author filipe.goncalves
@since 27/01/2016
@version P12.1.11
/*/
//-------------------------------------------------------------------
Function At740ValAM()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel	:= FwModelActive()
Local lRet		:= .T.
Local lIniFim 	:= Empty(oModel:GetValue('TFI_LE','TFI_PERINI')) .And. Empty(oModel:GetValue('TFI_LE','TFI_PERFIM'))
Local lEntCo	:= Empty(oModel:GetValue('TFI_LE','TFI_ENTEQP')) .And. Empty(oModel:GetValue('TFI_LE','TFI_COLEQP'))

If !lIniFim .And. lEntCo
	If oModel:GetValue('TFI_LE','TFI_APUMED') <> "1"
		lRet := .F.
		Help(,,"AT740OPC1",,STR0102,1,0)	//"Quando somente os períodos inicial e final estão preenchidos, é possivel selecionar apenas a opção '1' deste campo."
	Endif
Endif

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740VldAg
Validação para as dadtas de agendamento de entrega e coleta do equipamento.

@author Kaique Schiller
@since 13/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function At740VldAg(cCampo,dDtIni,dDtFim,dDtEnt,dDtCol)

Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local lRet 		:= .F.
Local cVldAgd 	:= SuperGetMv("MV_VLDAGD",,"1")
Local lCont		:= .T.

Default cCampo	:= ""
Default dDtIni	:= sTod("")
Default dDtFim	:= sTod("")
Default dDtEnt	:= sTod("")
Default dDtCol	:= sTod("")

If !Empty(dDtCol) .and. !Empty(dDtEnt)
	lCont := dDtCol >= dDtEnt
	If !lCont
		Help(,, "At740VldAg",,STR0108,1,0,,,,,,{STR0109})//#"Data Entrega/Coleta." #"Data Coleta deve ser maior que a data de entrega"
	EndIf
EndIf

If lCont .and. !Empty(dDtIni) .and. !Empty(dDtFim)
	lCont := dDtFim >= dDtIni
	If !lCont
		Help(,, "At740VldAg",,STR0110,1,0,,,,,,{STR0111})//#"Data Inicio/Fim."#"Data Fim deve ser maior que a Data Inicial"
	EndIf
EndIf

If lCont
	//Quando a data de entrega e coleta estiver igual ou fora do período.
	If cVldAgd == "1"
		If cCampo == "TFI_ENTEQP"
			If dDtEnt <= dDtIni
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0089,1,0,,,,,,{STR0090}) //"Data de entrega do equipamento." ## "A data de entrega tem que estar menor ou igual a data de inicio da alocação."
			Endif
		Endif
		If cCampo == "TFI_COLEQP"
			If dDtCol >= dDtFim
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0091,1,0,,,,,,{STR0092}) //"Data de coleta do equipamento." ## "A data de coleta tem que estar maior ou igual a data de fim da alocação."
			Endif
		Endif
	//Quando a data de entrega e coleta estiver igual ou dentro do período.
	Elseif cVldAgd == "2"
		If cCampo == "TFI_ENTEQP"
			If dDtEnt >= dDtIni
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0089,1,0,,,,,,{STR0093}) //"Data de entrega do equipamento." ## "A data de entrega tem que estar maior ou igual a data de inicio da alocação."
			Endif
		Endif
		If cCampo == "TFI_COLEQP"
			If dDtCol <= dDtFim .And. dDtCol >= dDtEnt
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0091,1,0,,,,,,{STR0094}) //"Data de coleta do equipamento." ## "A data de coleta tem que estar menor ou igual a data de fim da alocação."
			Endif
		Endif
	//Quando a data de entrega estiver igual ou maior que a data de inicio / quando a data de coleta estiver igual ou maior que a data final.
	Elseif cVldAgd == "3"
		If cCampo == "TFI_ENTEQP"
			If dDtEnt >= dDtIni
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0089,1,0,,,,,,{STR0093}) //"Data de entrega do equipamento." ## "A data de entrega tem que estar maior ou igual a data de inicio da alocação."
			Endif
		Endif
		If cCampo == "TFI_COLEQP"
			If dDtCol >= dDtFim
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0091,1,0,,,,,,{STR0092}) //"Data de coleta do equipamento." ## "A data de coleta tem que estar maior ou igual a data de fim da alocação."
			Endif
		Endif
	//Quando a data de entrega estiver igual ou menor que a data de inicio / quando a data de coleta estiver igual ou menor que a data final.
	Elseif cVldAgd == "4"
		If cCampo == "TFI_ENTEQP"
			If dDtEnt <= dDtIni
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0089,1,0,,,,,,{STR0090}) //"Data de entrega do equipamento." ## "A data de entrega tem que estar menor ou igual a data de inicio da alocação."
			Endif
		Endif
		If cCampo == "TFI_COLEQP"
			If dDtCol <= dDtFim
				lRet := .T.
			Else
				Help(,, "At740VldAg",,STR0091,1,0,,,,,,{STR0094}) //"Data de coleta do equipamento." ## "A data de coleta tem que estar estar menor ou igual a data de fim da alocação."
			Endif
		Endif
	Endif
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740CpoOb
Função para pegar os campos obrigatórios de determinados modelos da rotina e retirar o obrigatório deles por conta do facilitador de orçamento.

@author Filipe Gonçalves
@since 07/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Function At740CpoOb(oModel)

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local cRet	:= ""
Local aCpos	:= {{"TFF_RH",{}},{"TFG_MI",{}},{"TFH_MC",{}},{"TFI_LE",{}}}
Local nX	:= 0
Local nY	:= 0
Local nPos  := 0

For nX := 1 to len(oModel:GetAllSubModels())
	If  oModel:GetAllSubModels()[nX]:CID $ "TFF_RH|TFG_MI|TFH_MC|TFI_LE"
		cRet   := AllTrim(oModel:GetAllSubModels()[nX]:CID)
		nPos   := aScan(aCpos,{|x| AllTrim(x[1]) == cRet})
		oModNx := oModel:GetModel(cRet)
		aHead  := oModNx:GetStruct():GetFields()
		For nY := 1 To Len(aHead)
			If aHead[nY][MODEL_FIELD_OBRIGAT]
				Aadd(aCpos[nPos,2],aHead[nY][3])
			EndIf
		Next nY
		oModNx:GetStruct():SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	EndIf
Next nX

FWRestRows( aSaveLines )
RestArea(aArea)
Return aCpos


//-------------------------------------------------------------------
/*/{Protheus.doc} At740Obriga
Função para tornar os campos obrigatórios novamente, após a função At740CpoOb() retirar a obrigatoriedade.

@author Totvs
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Function At740Obriga()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel    := FwModelActive()
Local oModNx    := Nil
Local nX        := 0
Local nY        := 0
Local aCposObrg := {}

aCposObrg := aObriga
aObriga   := {}
For nX := 1 To Len(aCposObrg)
	oModNx := oModel:GetModel(aCposObrg[nX,1])
	For nY := 1 To Len(aCposObrg[nX,2])
		oModNx:GetStruct():SetProperty(aCposObrg[nX,2,nY],MODEL_FIELD_OBRIGAT,.T.)
	Next nY
Next nX

FWRestRows( aSaveLines )
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A740LoadFa
Função de validação para realizar a caraga dos dados nas abas

@author Filipe Gonçalves
@since 01/06/2016
@version P12
@Param
/*
	aDadosTWN[1] = TWN_FILIAL
	aDadosTWN[2] = TWN_ITEM
	aDadosTWN[3] = TWN_CODPRO
	aDadosTWN[4] = TWN_QUANTS
	aDadosTWN[5] = TWN_VLUNIT
	aDadosTWN[6] = TWN_TPITEM
	aDadosTWN[7] = TWN_CODTWM
	aDadosTWN[8] = TWN_ITEMRH
	aDadosTWN[9] = TWN_FUNCAO
	aDadosTWN[10] = TWN_TURNO
	aDadosTWN[11] = TWN_CARGO
	aDadosTWN[12] = TWN_TES
	DadosTWN[13] = TWN_TESPED
*/
//-------------------------------------------------------------------
Function A740LoadFa(oModelGrid, nLine, cAction, cField, xValue, xOldValue,lOkButton)
Local lRet			:= .T.
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local aValTWNRH 	:= {}
Local aValTWNMC 	:= {}
Local aValTWNMI		:= {}
Local aValTWNLE 	:= {}
Local oModel		:= FwModelActive()
Local oModLC		:= oModel:GetModel('TFL_LOC')
Local oModRH		:= oModel:GetModel('TFF_RH')
Local oModMI		:= oModel:GetModel('TFG_MI')
Local oModMC		:= oModel:GetModel('TFH_MC')
Local oModLE		:= oModel:GetModel('TFI_LE')
Local oModTWO		:= oModel:GetModel('TWODETAIL')
Local cChvItem 		:= ""
Local cCodFac		:= ""
Local cItemFc		:= ""
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",.F., .F.)
Local cGsDsGcn		:= oModel:GetValue('TFJ_REFER','TFJ_DSGCN')
Local cItem 		:= Replicate("0", TamSx3("TFF_ITEM")[1]  )
Local nTotal 		:= IF(lTotLoc,oModLC:Length(.T.),1)
Local nValItem 		:= 0
Local nDifItem 		:= 0
Local nMulItem 		:= 0
Local nNumItem 		:= 0
Local nQtdFc		:= 0
Local nX			:= 0
Local nY			:= 0
Local cGesMat		:= ""
Local lSetValue		:= .T.
Local cBaseTFL		:= ""
Local cBaseFac		:= ""

Default lOkButton	:= .F.

If !lOkButton .or. !lAlterTWO

	//Validação ao atribuir valores na tela do facilitador
	If !IsInCallStack("LoadXmlData")
		If cAction == 'SETVALUE'
			//Tratativa na mudanção do facilitador zerar o campo de quantidade
			If cField == "TWO_CODFAC"
				//Validação da Base operacional do local de atendimento x Facilitador:
				cBaseTFL := Posicione("ABS",1,xFilial("ABS")+oModLC:GetValue('TFL_LOCAL'),"ABS_BASEOP") //ABS_FILIAL+ABS_LOCAL
				cBaseFac := Posicione("TXR",1,xFilial("TXR")+xValue,"TXR_CODAA0") //TXR_FILIAL+TXR_CODIGO
				If !Empty(cBaseTFL) .And. !Empty(cBaseFac)
					If cBaseFac!=cBaseTFL
						lRet := .F.
						Help(,,"A740LOADFA",,STR0385,1,0,,,,,,{STR0386}) //"Não é possível inserir facilitador com Base Operacional diferente da Base Operacional do Local de Atendimento"#"Selecione um facilitador disponível na consulta padrão."
					EndIf
				EndIf

				TWM->(dbSetOrder(1))//TWN_FILIAL+TWN_CODTWM
				If TWM->(dbSeek(xFilial("TWM") + xValue))
					If TWM->TWM_DTVALI <= dDataBase
						lRet := .F.
						Help(,,"AT740VLDLOC",,STR0127,1,0) // "Validade do facilitador foi expirada, selecione outro facilitador"
					EndIf
				EndIf

				If (!Empty(xOldValue) .And. xValue <> xOldValue) .And. lRet
					//Posiciona no primeiro Local
					If lTotLoc
						oModLC:GoLine(1)
					EndIf
					For nX := 1 To nTotal
						If lTotLoc
							oModLC:GoLine(nX)
						EndIf
					oModTWO:LoadValue("TWO_QUANT", 0)
					//Fazer a deleção dos itens quando zerar a quantidade do facilitador
					TWN->(dbSetOrder(2))//TWN_FILIAL+TWN_CODTWM
					TWN->(dbSeek(xFilial("TWN") + xOldValue))
					For nY := 1 To oModRH:Length()
						oModRH:GoLine(nY)
						If !Empty(oModRH:GetValue('TFF_CHVTWO')) .And. TWN->TWN_CODTWM == SubStr(oModRH:GetValue('TFF_CHVTWO'), 1, 15)
							oModRH:DeleteLine()
							If !lOrcPrc
								// chama função para excluir as linhas de materiais
								At740FaExMt(oModMC, oModMI, .T.)
							EndIf
						EndIf
					Next nY
					If lOrcPrc
						// chama função para excluir as linhas de materiais
						At740FaExMt(oModMC, oModMI, .T.)
					EndIf
					//Itens Do LE
					For nY := 1 To oModLE:Length()
						oModLE:GoLine(nY)
						If !Empty(oModLE:GetValue('TFI_CHVTWO')) .And. TWN->TWN_CODTWM == SubStr(oModLE:GetValue('TFI_CHVTWO'), 1, 15)
							oModLE:DeleteLine()
						EndIf
					Next nY
					Next nX
				EndIf
			EndIf

			//Verifica se o código e a quantidade estão preenchidos para fazer a carga do SETVALUE
			If !Empty(oModTWO:GetValue('TWO_CODFAC')) .And. (cField == "TWO_QUANT" .And. xValue > 0 ) .And. lRet
				If !Empty(oModTWO:GetValue('TWO_CODFAC'))
					cCodFac := oModTWO:GetValue('TWO_CODFAC')
				EndIf
				//Posiciona no primeiro Local
				If lTotLoc
					oModLC:GoLine(1)
				EndIf
				For nX := 1 To nTotal
					If lTotLoc
						oModLC:GoLine(nX)

						If !Empty(oModTWO:GetValue('TWO_CODFAC'))
							cItemFc	:= oModTWO:GetValue('TWO_ITEM')
							nQtdFc	:= xValue
						EndIf
					EndIf
					TWN->(dbSetOrder(2))//TWN_FILIAL+TWN_CODTWM
					If TWN->(dbSeek(xFilial("TWN") + cCodFac))
						lAlterTWO := .T.

						aValTWNRH := Tec984Val(cCodFac, 'RH')
						aValTWNMC := Tec984Val(cCodFac, 'MC')
						aValTWNMI := Tec984Val(cCodFac, 'MI')
						aValTWNLE := Tec984Val(cCodFac, 'LE')

						cGesMat := oModel:GetValue('TFJ_REFER','TFJ_GESMAT')
						If Empty(cGesMat)
							cGesMat := "1"
						EndIf
						//-- Atribui itens de RH
						If !EMPTY(aValTWNRH)

							//Caso o Grid ja possua itens de RH, ajusta o campo ITEM para adicionar os produtos do facilitador
							If !oModRH:IsEmpty()
								oModRH:GoLine(oModRH:Length())
								cItem := oModRH:GetValue('TFF_ITEM')
							EndIf

							For nY := 1 To LEN(aValTWNRH)
								cItem := Soma1(cItem)
								If !Empty( aValTWNRH[nY][3] )
									//Percorrer o modelo para ver se já adicionou aquele facilitador
									If !oModRH:SeekLine( { { 'TFF_CHVTWO', cCodFac + aValTWNRH[nY][2] + oModTWO:GetValue('TWO_ITEM')}})
										If oModRH:Length() > 1 .Or. !Empty( oModRH:GetValue("TFF_PRODUT") )
											If nY <= LEN(aValTWNRH)
												oModRH:AddLine()
											EndIf
										EndIf
									EndIf
								EndIf
								// atribui os conteúdos relacionados ao controle de associação do facilitador
								nValItem	:= xOldValue
								nDifItem	:= xValue - nValItem
								nMulItem	:= nDifItem * aValTWNRH[nY][4]
								nNumItem	:= oModRH:GetValue('TFF_QTDVEN') + nMulItem
								cChvItem	:= cCodFac + aValTWNRH[nY][2] + oModTWO:GetValue('TWO_ITEM')

								lSetValue := oModRH:SetValue('TFF_ITEM', cItem)
								lSetValue := lSetValue .And. oModRH:SetValue('TFF_CHVTWO', cChvItem)
								lSetValue := lSetValue .And. oModRH:SetValue('TFF_QTDVEN', nNumItem)

								// Só atribui quando tem conteúdo
								If !( EMPTY(aValTWNRH[nY][3]) )
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_PRODUT', aValTWNRH[nY][3])
								EndIf
								If aValTWNRH[nY][5] > 0
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_PRCVEN', aValTWNRH[nY][5])
								EndIf
								If !Empty(aValTWNRH[nY][9])
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_FUNCAO', aValTWNRH[nY][9])
								EndIf
								If !Empty(aValTWNRH[nY][10])
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_TURNO'	, aValTWNRH[nY][10])
								EndIf
								If !Empty(aValTWNRH[nY][11])
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_CARGO'	, aValTWNRH[nY][11])
								EndIf
								If cGsDsGcn == "1" .AND. !( EMPTY(aValTWNRH[nY][13]) )
									lSetValue := lSetValue .And. oModRH:SetValue('TFF_TESPED', aValTWNRH[nY][13])
								EndIf

								//-- Atribui os itens de MI e MC - Filhos de RH
								If !lOrcPrc .And. lSetValue
									If cGesMat $ "1|4|6" .AND. !EMPTY(aValTWNMI)		// atualiza materia de implantação
										At740FaMat( oModTWO, aValTWNMI, oModMI, xValue, xOldValue, "TFG", cCodFac )
									EndIf

									If cGesMat $ "1|5|6" .AND. !EMPTY(aValTWNMC)	// atualiza materia de consumo
										At740FaMat( oModTWO, aValTWNMC, oModMC, xValue, xOldValue, "TFH", cCodFac )
									EndIf
								EndIf
							Next nY
							oModRH:GoLine(1)

							If !lSetValue .And. !IsBlind()
								AtErroMvc(oModel)
								MostraErro()
								lRet := .F.
							EndIf

						ElseIf !lOrcPrc
							If cGesMat $ "1|4|6" .AND. !EMPTY(aValTWNMI)	// atualiza materia de implantação
								At740FaMat( oModTWO, aValTWNMI, oModMI, xValue, xOldValue, "TFG", cCodFac )
							EndIf

							If cGesMat $ "1|5|6" .AND. !EMPTY(aValTWNMC)	// atualiza materia de consumo
								At740FaMat( oModTWO, aValTWNMC, oModMC, xValue, xOldValue, "TFH", cCodFac )
							EndIf
						EndIf

						//-- Atribui os itens de MI e MC - Não tem relacionamento com itens de RH
						If lOrcPrc .And. !(cGesMat $ '2|3')
							// atualiza materia de implantação
							If cGesMat $ "1|4|6" .AND. !EMPTY(aValTWNMI)
								At740FaMat( oModTWO, aValTWNMI, oModMI, xValue, xOldValue, "TFG", cCodFac )
							EndIf
							// atualiza materia de consumo
							If cGesMat $ "1|5|6" .AND. !EMPTY(aValTWNMC)
								At740FaMat( oModTWO, aValTWNMC, oModMC, xValue, xOldValue, "TFH", cCodFac )
							EndIf
						EndIf

						//Zera a variável para utilizar na grid de LE
						cItem := Replicate("0", TamSx3("TFI_ITEM")[1]  )

						//-- Atribui os itens de LE
						If !EMPTY(aValTWNLE)
							//Caso o Grid ja possua itens de LE, ajusta o campo ITEM para adicionar os produtos do facilitador
							If !oModLE:IsEmpty()
								oModLE:GoLine(oModLE:Length())
					 			cItem := oModLE:GetValue('TFI_ITEM')
							EndIf

							For nY := 1 To LEN(aValTWNLE)
								cItem := Soma1(cItem)
								If !Empty(aValTWNLE[nY][3])
									If !oModLE:SeekLine( { { 'TFI_CHVTWO',cCodFac + aValTWNLE[nY][2] + oModTWO:GetValue('TWO_ITEM') } } )
										//Verificar se não encontrou o facilitardor adicionar uma linha nova com as informações
										If oModLE:Length() > 1 .Or. !Empty( oModLE:GetValue("TFI_PRODUT") )
											If nY <= LEN(aValTWNLE)
												oModLE:AddLine()
											EndIf
										EndIf
									EndIf
									nValItem	:= xOldValue
									nDifItem	:= xValue - nValItem
									nMulItem	:= nDifItem * aValTWNLE[nY][4]
									nNumItem	:= oModLE:GetValue('TFI_QTDVEN') + nMulItem
									cChvItem :=  cCodFac + aValTWNLE[nY][2] + oModTWO:GetValue('TWO_ITEM')
									oModLE:SetValue('TFI_ITEM', cItem)
									oModLE:SetValue('TFI_CHVTWO', cChvItem)
									oModLE:SetValue('TFI_PRODUT', aValTWNLE[nY][3])
									oModLE:SetValue('TFI_QTDVEN', nNumItem)
									If !Empty(!Empty(aValTWNLE[nY][12]))
										oModLE:SetValue('TFI_TES', aValTWNLE[nY][12])
									EndIf
									If cGsDsGcn == "1"
										oModLE:SetValue('TFI_TESPED', aValTWNLE[nY][13])
									EndIf
								EndIf
							Next nY
							cItem := Replicate("0", TamSx3("TFF_ITEM")[1]  )
						EndIf

						oModLE:GoLine(1)
						FwModelActive( oModTWO:GetModel() )
					EndIf
				Next nX

				//Tratativa para duplicar o registro na TWO para os demais locais
				If lTotLoc
					For nY := 1 To oModLC:Length()
						oModLC:GoLine(nY)
						If Empty(oModTWO:GetValue('TWO_CODFAC'))
							If !(Empty(oModTWO:GetValue('TWO_ITEM')))
								oModLC:AddLine()
							EndIF
							oModTWO:LoadValue('TWO_ITEM'	,cItemFc)
							oModTWO:LoadValue('TWO_CODFAC'	,cCodFac)
							oModTWO:LoadValue('TWO_DESCRI'	,Posicione("TWM",1,xFilial("TWM") + cCodFac ,"TWM_DESCRI"))
							oModTWO:LoadValue('TWO_QUANT'	,nQtdFc)
						EndIf
					Next nY
				EndIf
			EndIf

		//Validação ao deletar a linha do facilitador
		ElseIf cAction == 'DELETE'
				If lTotLoc
					lDelTWO := .T.
				EndIf
				//Itens Do RH
				TWN->(dbSetOrder(2))//TWN_FILIAL+TWN_CODTWM
				TWN->(dbSeek(xFilial("TWN") + oModTWO:GetValue('TWO_CODFAC')))
				For nY := 1 To oModRH:Length()
					oModRH:GoLine(nY)
					cChavTWO := SubStr(oModRH:GetValue('TFF_CHVTWO'), 1, 15) + SubStr(oModRH:GetValue('TFF_CHVTWO'), 19, 3)
					If !Empty(oModRH:GetValue('TFF_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
						oModRH:DeleteLine()
						If !lOrcPrc
							// chama função para excluir as linhas de materiais
							At740FaExMt(oModMC, oModMI, .T., oModTWO)
						EndIf
					EndIf
				Next nY

				If lOrcPrc
					// chama função para excluir as linhas de materiais
					At740FaExMt(oModMC, oModMI, .T., oModTWO)
				EndIf

				//Itens Do LE
				For nY := 1 To oModLE:Length()
					oModLE:GoLine(nY)
					cChavTWO := SubStr(oModLE:GetValue('TFI_CHVTWO'), 1, 15) + SubStr(oModLE:GetValue('TFI_CHVTWO'), 19, 3)
					If !Empty(oModLE:GetValue('TFI_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
						oModLE:DeleteLine()
					EndIf
				Next nY

		//Validação para habilitar a linha deletada
		ElseIf cAction == 'UNDELETE'
			If lTotLoc
				lUnDel := .T.
			EndIf
			//Verifica se existe um registro duplicado ao habilitar a linha
			If lRet
				TWN->(dbSetOrder(2))//TWN_FILIAL+TWN_CODTWM
				TWN->(dbSeek(xFilial("TWN") + oModTWO:GetValue('TWO_CODFAC')))
				For nY := 1 To oModRH:Length()
					oModRH:GoLine(nY)
					cChavTWO := SubStr(oModRH:GetValue('TFF_CHVTWO'), 1, 15) + SubStr(oModRH:GetValue('TFF_CHVTWO'), 19, 3)
					If !Empty(oModRH:GetValue('TFF_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
						oModRH:UnDeleteLine()
						If !lOrcPrc
							// chama função para excluir as linhas de materiais
							At740FaExMt(oModMC, oModMI, .F., oModTWO)
						EndIf
					EndIf
				Next nY
				If lOrcPrc
					// chama função para excluir as linhas de materiais
					At740FaExMt(oModMC, oModMI, .F., oModTWO)
				EndIf
				//Itens Do LE
				For nY := 1 To oModLE:Length()
					oModLE:GoLine(nY)
					cChavTWO := SubStr(oModLE:GetValue('TFI_CHVTWO'), 1, 15) + SubStr(oModLE:GetValue('TFI_CHVTWO'), 19, 3)
					If !Empty(oModLE:GetValue('TFI_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
						oModLE:UnDeleteLine()
					EndIf
				Next nY
			EndIf

		//Validação para habilitar edição na linha quando o Local e as datas de inicio e fim estiverem informadas
		ElseIf cAction == 'CANSETVALUE'
			If !Empty(oModTWO:GetValue('TWO_CODFAC'))
				cCodFac := oModTWO:GetValue('TWO_CODFAC')
			EndIf

			If cField = 'TWO_CODFAC'
				If Empty(oModLC:GetValue('TFL_LOCAL')) .Or.  Empty(oModLC:GetValue('TFL_DTINI')) .Or. Empty(oModLC:GetValue('TFL_DTFIM'))
					lRet := .F.
				EndIf
			ElseIf cField = 'TWO_QUANT'
				If Empty(cCodFac)
					lRet := .F.
				Else
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TEC740FACI
Função de validação para realizar a caraga dos dados nas abas

@author Filipe Gonçalves
@since 01/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Function TEC740FACI(oModLoc)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local oStruTWO		:= FwFormStruct(2, 'TWO', {|cCpo| At740SelFields( 'TWO', Alltrim(cCpo) )})
Local oSubView		:= FwFormView():New(oModel)
Local oModelTFL	:= 	oModel:GetModel('TFL_LOC')
Local oModelTWO	:= oModel:GetModel('TWODETAIL')
Local lRet		:= .T.
Local nX		:= 0
Local nY		:= 0

If !lNovoFacil .And. oModelTFL:Length(.T.) > 1
	lTotLoc := MsgYesNo(STR0128) // "Deseja replicar o facilitador para todos os Locais de atendimento deste orçamento? "
EndIf

If lRet := 	!Empty(oModelTFL:GetValue('TFL_LOCAL'))

	lAlterTWO := .F.
	//Função para pegar os campos obrigatórios de determinados modelos da rotina
	If Len(aObriga) == 0
		aObriga := At740CpoOb(oModel)
	EndIf

	//Cria uma subView para chamar na tela flutuante
	oSubView:SetModel(oModel)
	oSubView:CreateHorizontalBox('POPBOX',100)
	oSubView:AddGrid('VIEW_TWO',oStruTWO,'TWODETAIL')
	oSubView:AddIncrementField('VIEW_TWO', 'TWO_ITEM')
	oSubView:SetOwnerView('VIEW_TWO','POPBOX')

	TECXFPOPUP(oModel,oSubView, STR0096, MODEL_OPERATION_UPDATE, 70,,, IIF(lAlterTWO, {||.T.},{|| A740LoadFa(Nil, 0, "SETVALUE", "TWO_QUANT", oModelTWO:GetValue("TWO_QUANT"), 0,.T.)}))

	If lTotLoc .And. lDelTWO
		For nY := 1 To oModelTFL:Length()
			oModelTFL:Goline(nY)
			For nX := 1 to oModelTWO:Length()
				oModelTWO:GoLine(nX)
				If !Empty(oModelTWO:GetValue('TWO_CODFAC')) .And. !oModelTWO:IsDeleted()
					oModelTWO:Deleteline()
				EndIf
			next nX
		Next nY
		lDelTWO := .F.
	ElseIf lTotLoc .And. lUnDel
		For nY := 1 To oModelTFL:Length()
			oModelTFL:Goline(nY)
			For nX := 1 to oModelTWO:Length()
				oModelTWO:GoLine(nX)
				If !Empty(oModelTWO:GetValue('TWO_CODFAC')) .And. oModelTWO:IsDeleted()
					oModelTWO:UnDeleteLine()
				EndIf
			next nX
		Next nY
		lUnDel := .F.
	EndIf
		// Função que torna todos os campos obrigatórios novamente, após ter a obrigatoriedade retirada pela função At740CpoOb().
	At740Obriga()
Else
	Help(,,"AT740VLDLOC",,STR0097,1,0) //- "Para utilizar o facilitador por favor informe um Local de Atendimento e suas datas de vigência."
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

lAlterTWO := .F.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TEC740NFac
Função de validação para realizar a carga dos dados nas abas
para o novo facilitador

@author Luiz Gabriel
@since 26/07/2022
@version P12.1.2210
/*/
//-------------------------------------------------------------------
Function TEC740NFac(oModLoc)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local oMdlBkp		:= oModel
Local oVieBkp		:= FwViewActive()
Local oModelTFL		:= oModel:GetModel('TFL_LOC')
Local oModelTFF		:= oModel:GetModel('TFF_RH')
Local oStruTWO		:= FwFormStruct(2, 'TWO', {|cCpo| At740SelFields( 'TWO', Alltrim(cCpo) )})
Local oSubView		:= FwFormView():New(oModel)
Local lRet			:= .T.
Local bSetOk 		:= {|oModel| Tec740FacOK(oModel,lTotLoc,oModLoc)}

If oModelTFF:IsDeleted()
	Help( Nil, Nil, "LINEDELFACILIT", Nil, STR0402, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0403 } ) // "Item excluído!" ## "Não é permitido alteração em Item excluído."
	Return .T.
EndIf

If !lNovoFacil .And. oModelTFL:Length(.T.) > 1
	lTotLoc := MsgYesNo(STR0128) // "Deseja replicar o facilitador para todos os Locais de atendimento deste orçamento? "
EndIf

If !Empty(oModelTFL:GetValue('TFL_LOCAL'))
	lAlterTWO := .F.
	//Função para pegar os campos obrigatórios de determinados modelos da rotina
	If Len(aObriga) == 0
		aObriga := At740CpoOb(oMdlBkp)
	EndIf

	//Cria uma subView para chamar na tela flutuante
	oSubView:SetModel(oModel)
	oStruTWO:SetProperty( "TWO_CODFAC", MVC_VIEW_LOOKUP, 'TXRFAC')
	oSubView:CreateHorizontalBox('POPBOX',100)
	oSubView:AddGrid('VIEW_TWO',oStruTWO,'TWODETAIL')
	oSubView:AddIncrementField('VIEW_TWO', 'TWO_ITEM')
	oSubView:SetOwnerView('VIEW_TWO','POPBOX')

	TECXFPOPUP(oModel,oSubView, STR0096, MODEL_OPERATION_UPDATE, 70,,STR0096,,bSetOk) //"Facilitador"

	// Função que torna todos os campos obrigatórios novamente, após ter a obrigatoriedade retirada pela função At740CpoOb().
	FwModelActive( oMdlBkp )
	FwViewActive( oVieBkp )
	At740Obriga()
Else
	Help(,,"AT740VLDLOC",,STR0097,1,0) //- "Para utilizar o facilitador por favor informe um Local de Atendimento e suas datas de vigência."
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

lAlterTWO := .F.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tec740FacOK
 chamada para o OK da tela do facilitador

@author Luiz Gabriel
@since 26/07/2022
@version P12.1.2210
/*/
//-------------------------------------------------------------------
Function Tec740FacOK( oModel, lTotLoc, oView740 )
Local lRet	:= .F.

	FwMsgRun(Nil,{|| lRet := Tec740CmtFac( oModel, lTotLoc, oView740 ) }, Nil, STR0337)	//"Carregando dados do facilitador......"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tec740CmtFac
função de carregamento do facilitador nos grids do orçamento

@author Luiz Gabriel
@since 26/07/2022
@version P12.1.2210
/*/
//-------------------------------------------------------------------
Static Function Tec740CmtFac( oModel, lTotLoc, oView740 )
Local nX			:= 0
Local nY			:= 0
Local oModelTFL		:= oModel:GetModel('TFL_LOC')
Local oModelTFF		:= oModel:GetModel('TFF_RH')
Local oModelTWO		:= oModel:GetModel('TWODETAIL')
Local oMdlFac 		:= Nil
Local oMdlTXS 		:= Nil
Local cItem 		:= Replicate("0", TamSx3("TFF_ITEM")[1]  )
Local cCodTWO 		:= ""
Local lCodigo 		:= .F.
Local cCodFacAnt	:= ""
Local oView := FwViewActive()

If oModel:GetOperation() ==  MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() ==  MODEL_OPERATION_INSERT
	If lNovoFacil
		If oModelTFF:Length() > 0
			nLinhaTFF := oModelTFF:GetLine()
			For nX := 1 To oModelTWO:Length()
				oModelTFF:GoLine( nLinhaTFF )
				oModelTWO:GoLine( nX )
				If !Empty(oModelTWO:GetValue('TWO_CODFAC')) .And. (oModelTWO:GetValue('TWO_QUANT') > 0 )
					cCodFac := Alltrim(oModelTWO:GetValue('TWO_CODFAC'))
					nQuant  := oModelTWO:GetValue('TWO_QUANT')
					cCodTWO := oModelTWO:GetValue('TWO_CODIGO')
					cIteTWO := oModelTWO:GetValue('TWO_ITEM')
					TXR->(dbSetOrder(1))//TXR_FILIAL+TXR_CODIGO
					If TXR->(dbSeek(xFilial("TXR") + cCodFac)) //Necessario posicionar para realizar load da TXR
						TXS->(dbSetOrder(2)) //TXS_FILIAL+TXS_CODTXR
						If TXS->(dbSeek(xFilial("TXS") + cCodFac))
							oMdlFac := FwLoadModel("TECA984A")
							oMdlFac:SetOperation(MODEL_OPERATION_VIEW)
							oMdlFac:Activate()
							oMdlTXS := oMdlFac:GetModel("TXSDETAIL")
							FwModelActive( oModelTWO:GetModel() )
							If !oMdlTXS:IsEmpty()
								If !oModelTFF:IsEmpty()
									//Verifica se há TFF´s carregadas com o mesmo codigo
									lCodigo := oModelTFF:SeekLine( { {'TFF_CODTWO',cCodTWO }})
									If lCodigo
										cCodFacAnt := SUBSTRING( oModelTFF:GetValue('TFF_CHVTWO'),1, TamSx3("TXR_CODIGO")[1])
										//verifica se houve mudança no codigo do facilitador
										lAlterTWO := !Empty(oModelTFF:GetValue('TFF_CHVTWO')) .And. cCodFacAnt <> cCodFac
									EndIf
									oModelTFF:GoLine(oModelTFF:Length())
								EndIf
								If !oModelTWO:IsDeleted()
									//caso houve alteração, deleta as linhas do facilitador anterior
									If lAlterTWO
										Tec984ADel(oModel,oModelTWO,oModelTFF,oMdlFac,cCodFacAnt,cCodTWO,lAlterTWO)
									EndIf
									//função para importar os dados do facilitador
									Tec984AImp( oModel, oModelTWO, oModelTFF, oMdlFac, cCodTWO, cCodFac, cItem, nQuant, oView740, cIteTWO )
								Else
									//Faz tratamento para deletar os itens do facilitador
									Tec984ADel(oModel,oModelTWO,oModelTFF,oMdlFac,cCodFac,cCodTWO,lAlterTWO)
								EndIf
								lAlterTWO := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf
	Else
		For nY := 1 To oModelTFL:Length()
			If lTotLoc
				oModelTFL:GoLine(nY)
			EndIf
			For nX := 1 To oModelTWO:Length()
				oModelTWO:GoLine( nX )
				If !Empty(oModelTWO:GetValue('TWO_CODFAC')) .And. (oModelTWO:GetValue('TWO_QUANT') > 0 )
					cCodFac := Alltrim(oModelTWO:GetValue('TWO_CODFAC'))
					nQuant := oModelTWO:GetValue('TWO_QUANT')
					cCodTWO := oModelTWO:GetValue('TWO_CODIGO')
					TXR->(dbSetOrder(1))//TXR_FILIAL+TXR_CODIGO
					If TXR->(dbSeek(xFilial("TXR") + cCodFac)) //Necessario posicionar para realizar load da TXR
						TXS->(dbSetOrder(2)) //TXS_FILIAL+TXS_CODTXR
						If TXS->(dbSeek(xFilial("TXS") + cCodFac))
							oMdlFac := FwLoadModel("TECA984A")
							oMdlFac:SetOperation(MODEL_OPERATION_VIEW)
							oMdlFac:Activate()
							oMdlTXS := oMdlFac:GetModel("TXSDETAIL")
							FwModelActive( oModelTWO:GetModel() )
							If !oMdlTXS:IsEmpty()
								If !oModelTFF:IsEmpty()
									//Verifica se há TFF´s carregadas com o mesmo codigo
									lCodigo := oModelTFF:SeekLine( { {'TFF_CODTWO',cCodTWO }})
									If lCodigo
										cCodFacAnt := SUBSTRING( oModelTFF:GetValue('TFF_CHVTWO'),1, TamSx3("TXR_CODIGO")[1])
										//verifica se houve mudança no codigo do facilitador
										lAlterTWO := !Empty(oModelTFF:GetValue('TFF_CHVTWO')) .And. cCodFacAnt <> cCodFac
									EndIf
									nLine := oModelTFF:GetLine()
									oModelTFF:GoLine(oModelTFF:Length())
									cItem := oModelTFF:GetValue('TFF_ITEM')
									oModelTFF:GoLine(nLine)
								EndIf
								If !oModelTWO:IsDeleted()
									//caso houve alteração, deleta as linhas do facilitador anterior
									If lAlterTWO
										Tec984ADel(oModel,oModelTWO,oModelTFF,oMdlFac,cCodFacAnt,cCodTWO,lAlterTWO)
									EndIf
									//função para importar os dados do facilitador
									Tec984AImp(oModel,oModelTWO,oModelTFF,oMdlFac,cCodTWO,cCodFac,cItem,nQuant)
								Else
									//Faz tratamento para deletar os itens do facilitador
									Tec984ADel(oModel,oModelTWO,oModelTFF,oMdlFac,cCodFac,cCodTWO,lAlterTWO)
								EndIf
								lAlterTWO := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			Next nX
			If !lTotLoc
				Exit
			EndIf
		Next nY
	EndIf
EndIf

oView:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} At740TEVQt
	Calcula a qtde de dias do item qdo preenchido o campo de modo de cobrança
@return 	nValor, Numérico, qtde de dias a ser utilizado como "diária" para o período e quantidade de itens indicado pelo usuário
@param 		lAtribui, Lógico, indica se deve acontecer a atribuição do conteúdo ao campo (por vir do gatilho de um modelo diferente)
								ou simplesmente retornar o conteúdo
/*/
//-------------------------------------------------------------------
Function At740TEVQt( lAtribui )

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local nQtde := 0
Local nDias := 0
Local oModel := FwModelActive()
Local oMdlTFI := Nil
Local cCodProd := ""
Local lIdUnico := .T.
Local oMdlTEV := Nil
Local oMdlTFJ := Nil
Default lAtribui := .F.

If oModel:GetId() == "TECA740" .Or. oModel:GetId() == "TECA740F"
	oMdlTFJ := oModel:GetModel("TFJ_REFER")
	oMdlTFI := oModel:GetModel("TFI_LE")
	oMdlTEV := oModel:GetModel("TEV_ADICIO")

	If oMdlTFJ:GetValue("TFJ_CNTREC") != "1" //Quando não for contrato reccorente.

		If Alltrim(oMdlTFI:GetValue("TFI_APUMED")) == '2' //Entrega e coleta
			nDias := oMdlTFI:GetValue("TFI_COLEQP") - oMdlTFI:GetValue("TFI_ENTEQP") + 1
		ElseIf Alltrim(oMdlTFI:GetValue("TFI_APUMED")) == '3' //Inicio e Coleta
			nDias := oMdlTFI:GetValue("TFI_COLEQP") - oMdlTFI:GetValue("TFI_PERINI") + 1
		ElseIf Alltrim(oMdlTFI:GetValue("TFI_APUMED")) == '4' //Entrega e Fim
			nDias := oMdlTFI:GetValue("TFI_PERFIM") - oMdlTFI:GetValue("TFI_ENTEQP") + 1
		Else
			// ' ' OR '1' = Início e Fim
			// '5' = Nota remessa(sera usado o Inicio como não temos a Nota nesse momento) e Fim
			nDias := oMdlTFI:GetValue("TFI_PERFIM") - oMdlTFI:GetValue("TFI_PERINI") + 1
		EndIf
	Else
		nDias := 30
	Endif

	cCodProd := oMdlTFI:GetValue("TFI_PRODUT")
	// verifica se o produto é Id Único
	If !Empty( cCodProd )
		lIdUnico :=	Posicione("SB5",1,xFilial("SB5")+cCodProd,"B5_ISIDUNI") $ " |1"
	EndIf

	// quando é Id Único a qtde é só a diferença de dias
	If lIdUnico
		nQtde := nDias * oMdlTFI:GetValue("TFI_QTDVEN")
	Else
		nQtde := nDias
	EndIf

	If lAtribui .And. nQtde > 0 .And. oMdlTEV:SeekLine({{"TEV_MODCOB","2"}})
		oMdlTEV:SetValue("TEV_QTDE", nQtde)
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} At740TEVMC
	Consiste o tipo de cobrança x modo de cobrança para a locação de um equipamento
@param 		NIL
@return 	.T.=Tipo de cobrança x Modo de cobrança válido // .F.=Tipo de cobrança x Modo de cobrança inválido
@since		15/07/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function At740TEVMC()

Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl   	:= FwModelActive()
Local cTpCobr	:= FwFldGet("TFI_TPCOBR")	//1=Dias;2=Horas
Local cMdCobr	:= FwFldGet("TEV_MODCOB")	//1=Uso;2=Disponibilidade;3=Mobilização;4=Horas;5=Franquia/Excedente
Local lRet		:= .T.
Local cMdOposto := ""
Local nI 		:= 0
Local oMdlModCob := Nil

If cTpCobr == "1" .AND. ( cMdCobr == "4" .Or. cMdCobr == "5" )
	lRet	:= .F.
	Help(,,"AT740TEVMC",,STR0129,; // "Não é permitido utilizar o modo de cobrança por horas com o tipo de cobrança na locação igual a 1-Dias."
							1,0,,,,,,{STR0130}) // "Selecione outro modo de cobrança ou altere o tipo da locação para horímetro."

ElseIf cTpCobr == "2" .AND. ( cMdCobr == "4" .Or. cMdCobr == "5" )
	cMdOposto := If( cMdCobr == "4", "5", "4" )

	oMdlModCob := oMdl:GetModel("TEV_ADICIO")

	For nI := 1 To oMdlModCob:Length()
		If oMdlModCob:GetValue("TEV_MODCOB",nI) == cMdOposto
			lRet	:= .F.
			Help(,,"AT740TEVMC",,STR0131,; // "Não é permitido utilizar os dois modos de cobrança por horas."
									1,0,,,,,,{STR0132}) // "Escolha somente uma das opções entre 4-Horas ou 5-Franquia/Excedente."
			Exit
		EndIf
	Next

EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740GesMa
	Condição do gatilho TFF_SUBTOT	sequencia 002
@param 		NIL
@return 	.T.
@since		15/08/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function At740GesMa()

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local lRet			:= .T.

lRet := .F.
If oModel:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT") == "3"
	lRet := .T.
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740VLRMA
	Condição do When do campo TFF_VLRMAT
@param 		NIL
@return 	.T.
@since		15/08/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function At740VLRMA()

Local oModel		:= FwModelActive()
Local lRet			:= .F.
Local cGesMat		:= oModel:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT")

lRet := !(Empty(cGesMat) .or. cGesMat == "1")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740WhCob
	Verifica se a linha deve ter seu valor atualizado para o total do orçamento/contrato
	Utilizado no bloco bCond do totalizador do MVC do grid de modo de cobrança de locação
@author 	Inovação Gestão de Serviços
@since		14/09/2016
@version	P12
@param 		oModel, Objeto FwFormModel/MpFormModel, objeto principal do cadastro MVC
@return 	Lógico, .T. soma, .F. não soma
/*/
//-------------------------------------------------------------------
Function At740WhCob( oModel )
// não soma os itens do tipo 5-Franquia/Excedente
Local lSoma := ( oModel:GetModel("TEV_ADICIO"):GetValue("TEV_MODCOB") <> '5' )

Return lSoma

//-------------------------------------------------------------------
/*/{Protheus.doc} At740SmTEV
	Zera os valores da linha quando identificar
	Executado a partir de gatilho do campo de modo de cobrança
@author 	Inovação Gestão de Serviços
@since		14/09/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function At740SmTEV()
Local oMdl := FwModelActive()
Local oMdlTEV := Nil
Local cModSelec := ""

If ((cModSelec := FwFldGet("TEV_MODCOB")) == '5') .And. FwFldGet("TEV_VLRUNI") > 0
	oMdlTEV := oMdl:GetModel("TEV_ADICIO")
	oMdlTEV:LoadValue("TEV_VLRUNI",0) // faz por load por causa da validação no campo
	oMdlTEV:SetValue("TEV_SUBTOT",0)  // faz via set para disparar as demais atualizações
	oMdlTEV:SetValue("TEV_VLTOT",0)   // faz via set para disparar as demais atualizações
EndIf

Return cModSelec

//-------------------------------------------------------------------
/*/{Protheus.doc} At740FaMat
	Função para adicionar valores nas Grids de Materiais
@param 		NIL
@return 	.T.
@since		15/08/2016
@version	P12
/*/
//-------------------------------------------------------------------
Static Function At740FaMat( oModTWO, aValTWNnX, oModGridOrc, xValue, xOldValue, cTab, cCodFac)

Local nX := 0
Local nY := 0
Local nValItem := 0
Local nDifItem := 0
Local nMulItem := 0
Local nNumItem := 0
Local cChvItem := ""
Local cItem		:= Replicate("0", TamSx3(cTab +"_ITEM")[1]  )
Local cGsDsGcn	:= oModGridOrc:GetModel():GetValue('TFJ_REFER','TFJ_DSGCN')

//Caso o Grid ja possua itens MI / MC, ajusta o campo ITEM para adicionar os produtos do facilitador
If !oModGridOrc:IsEmpty()
	oModGridOrc:GoLine(oModGridOrc:Length())
	cItem := oModGridOrc:GetValue(cTab+'_ITEM')
EndIf

For nY := 1 To LEN(aValTWNnX)

	cItem := Soma1(cItem)
	If !Empty(aValTWNnX[nY][3])

		If !oModGridOrc:SeekLine( { { cTab+'_CHVTWO' , ;
				oModTWO:GetValue('TWO_CODFAC') + aValTWNnX[nY][2] + oModTWO:GetValue('TWO_ITEM') } } )
			//Verificar se não encontrou o facilitardor adicionar uma linha nova com as informações
			If oModGridOrc:Length() > 1 .Or. !Empty( oModGridOrc:GetValue(cTab+"_PRODUT") )
				If nY <= LEN(aValTWNnX)
					oModGridOrc:AddLine()
				EndIf
			EndIf
		EndIf
		nMulItem	:= xValue * aValTWNnX[nY][4]
		nNumItem	:= oModGridOrc:GetValue(cTab+'_QTDVEN') + nMulItem
		cChvItem	:= cCodFac + aValTWNnX[nY][2] + oModTWO:GetValue('TWO_ITEM')
		oModGridOrc:SetValue(cTab+'_ITEM', cItem)
		oModGridOrc:SetValue(cTab+'_CHVTWO', cChvItem)
		oModGridOrc:SetValue(cTab+'_PRODUT', aValTWNnX[nY][3])
		oModGridOrc:SetValue(cTab+'_QTDVEN', nNumItem)
		If aValTWNnX[nY][5] > 0
			oModGridOrc:SetValue(cTab+'_PRCVEN', aValTWNnX[nY][5])
		EndIf
		If !Empty(aValTWNnX[nY][12])
			oModGridOrc:SetValue(cTab+'_TES', aValTWNnX[nY][12])
		EndIf
		If cGsDsGcn == "1"
			oModGridOrc:SetValue(cTab+'_TESPED', aValTWNnX[nY][12])
		EndIf
	EndIf
Next nY

oModGridOrc:GoLine(1)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At740FaExMt
	Função para deletar as informações nas Grids MC e MI
@param 		NIL
@return 	.T.
@since		15/08/2016
@version	P12
/*/
//-------------------------------------------------------------------
Static Function At740FaExMt(oModMC, oModMI, lDelete, oModTWO)

Local nX := 0
Local cChavTWO	:= ""

Default lDelete := .T.

If lDelete
	//Itens Do MC
	For nX := 1 To oModMC:Length()
		oModMC:GoLine(nX)
		cChavTWO := SubStr(oModMC:GetValue('TFH_CHVTWO'), 1, 15) + SubStr(oModMC:GetValue('TFH_CHVTWO'), 19, 3)
		If !Empty(oModMC:GetValue('TFH_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
			oModMC:DeleteLine()
		EndIf
	Next nX
	//Itens Do MI
	For nX := 1 To oModMI:Length()
		oModMI:GoLine(nX)
		cChavTWO := SubStr(oModMI:GetValue('TFG_CHVTWO'), 1, 15) + SubStr(oModMI:GetValue('TFG_CHVTWO'), 19, 3)
		If !Empty(oModMI:GetValue('TFG_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
			oModMI:DeleteLine()
		EndIf
	Next nX

Else
	//Itens Do MC
	For nX := 1 To oModMC:Length()
		oModMC:GoLine(nX)
		cChavTWO := SubStr(oModMC:GetValue('TFH_CHVTWO'), 1, 15) + SubStr(oModMC:GetValue('TFH_CHVTWO'), 19, 3)
		If !Empty(oModMC:GetValue('TFH_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
			oModMC:UnDeleteLine()
		EndIf
	Next nX
	//Itens Do MI
	For nX := 1 To oModMI:Length()
		oModMI:GoLine(nX)
		cChavTWO := SubStr(oModMC:GetValue('TFG_CHVTWO'), 1, 15) + SubStr(oModMC:GetValue('TFG_CHVTWO'), 19, 3)
		If !Empty(oModMI:GetValue('TFG_CHVTWO')) .And. TWN->TWN_CODTWM + oModTWO:GetValue('TWO_ITEM') == cChavTWO
			oModMI:UnDeleteLine()
		EndIf
	Next nX

EndIf

Return

/*/{Protheus.doc} At740Del
	Função para excluir um orçamento de serviços
@param 		nDelTFJ, numérico, indica o recno do cabeçalho do orçamento de serviços
@return 	Lógico, determina se a exclusão aconteceu com sucesso ou não
@since		29/12/16
@version	P12
/*/
Function At740Del( nDelTFJ )
Local lRet := .T.
Local lOrcPrc := SuperGetMV("MV_ORCPRC",,.F.)
Local oModel := If( lOrcPrc, FwLoadModel("TECA740F"), FwLoadModel("TECA740") )

TFJ->( DbGoTo( nDelTFJ ) )
oModel:SetOperation(MODEL_OPERATION_DELETE)

lRet := lRet .And. oModel:Activate()
At740SCmt( .T. )
lRet := lRet .And. oModel:VldData()
lRet := lRet .And. oModel:CommitData()

At740SCmt( .F. )

If !lRet
	AtErroMvc( oModel )
	MostraErro()
EndIf

If lRet .AND. FindFunction("At600ARROS")
	At600ARROS( .F. )
EndIF

Return lRet

/*/{Protheus.doc} At740IsOrc
@description 	Verifica se o registro posicionado é do orçamento de serviços
@param 			cModItem, caracter, modelo de origem do item a ser avaliado
@param 			cCodItemEval, caracter, código do item que precisa ser avaliado
@param 			cCodTFJ, caracter, código do orçamento de serviços a ser avaliado
@return 		Lógico, indica se o item pertence ao orçamento de serviços ou não
@since			19/01/17
@version		P12
/*/
Function At740IsOrc( cModItem, cCodTFJ, cCodTFL, oMdlAtivo )
Local lFound 		:= .F.
Local cTabTemp 		:= ""
Local nOrcPrc 		:= 0
Local cCodItemEval 	:= ""
Local cExpCodTFL 	:= ""

Default cCodTFL 	:= ""

// executa as avaliações conforme o modelo que entrou e a tabela relacionada a entidade | geralmente orçamento de serviços
If cModItem == "TFF_RH" .Or. cModItem == "TGV_RH" .Or. cModItem == "ABP_BENEF"
	If cModItem == "TGV_RH"
		cCodItemEval := TGV->TGV_CODTFF
	ElseIf cModItem == "ABP_BENEF"
		cCodItemEval := ABP->ABP_ITRH
	Else
		cCodItemEval := TFF->TFF_COD
	EndIf

	If Empty(cCodTFL)
		cExpCodTFL := "% TFF_FILIAL = '"+xFilial("TFF")+"' "
		cExpCodTFL += "AND TFF_COD = '"+cCodItemEval+"' "
		cExpCodTFL += "AND TFF.D_E_L_E_T_=' '%"
	Else
		cExpCodTFL := "% TFF_FILIAL = '"+xFilial("TFF")+"' "
		cExpCodTFL += "AND TFF_COD = '"+cCodItemEval+"' "
		cExpCodTFL += "AND TFL_CODIGO = '"+cCodTFL+"' "
		cExpCodTFL += "AND TFF.D_E_L_E_T_=' ' %"
	EndIf

	cTabTemp := GetNextAlias()

	BeginSql Alias cTabTemp
		SELECT TFJ_CODIGO
		FROM %Table:TFF% TFF
			INNER JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
									AND TFL_CODIGO = TFF_CODPAI
									AND TFL.%NotDel%
			INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
									AND TFJ_CODIGO = TFL_CODPAI
									AND TFJ.%NotDel%
		WHERE
			%Exp:cExpCodTFL%

	EndSql

	If (cTabTemp)->(!EOF()) .And. (cTabTemp)->TFJ_CODIGO == cCodTFJ
		lFound := .T.
	EndIf

	(cTabTemp)->(DbCloseArea())

ElseIf cModItem == "TFG_MI"
	nOrcPrc := If( SuperGetMV("MV_ORCPRC",,.F.), 1, 0)
	// executa a avaliação quando é orçamento com precificação
	// ou quando o item não é filho de um novo item de Rh
	If nOrcPrc == 1 .Or. ;
		!oMdlAtivo:GetModel("TFF_RH"):IsInserted()

		cCodItemEval := TFG->TFG_COD

		If Empty(cCodTFL)
			cExpCodTFL := "% TFG_FILIAL = '"+xFilial("TFG")+"' "
			cExpCodTFL += "AND TFG_COD = '"+cCodItemEval+"' "
			cExpCodTFL += "AND TFG.D_E_L_E_T_=' '%"
		Else
			cExpCodTFL := "% TFG_FILIAL = '"+xFilial("TFG")+"' "
			cExpCodTFL += "AND TFG_COD = '"+cCodItemEval+"' "
			cExpCodTFL += "AND TFL_CODIGO = '"+cCodTFL+"' "
			cExpCodTFL += "AND TFG.D_E_L_E_T_=' ' %"
		EndIf

		cTabTemp := GetNextAlias()

		BeginSql Alias cTabTemp
			SELECT TFJ_CODIGO
			FROM %Table:TFG% TFG
				LEFT JOIN %Table:TFF% TFF ON 0 = %Exp:nOrcPrc%
										AND TFF_FILIAL = %xFilial:TFF%
										AND TFF_COD = TFG_CODPAI
										AND TFF.%NotDel%
				INNER JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
										AND (
												(0 = %Exp:nOrcPrc% AND TFL_CODIGO = TFF_CODPAI)
												OR (1 = %Exp:nOrcPrc% AND TFL_CODIGO = TFG_CODPAI)
											)
										AND TFL.%NotDel%
				INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
										AND TFJ_CODIGO = TFL_CODPAI
										AND TFJ.%NotDel%
			WHERE
				%Exp:cExpCodTFL%
		EndSql

		If (cTabTemp)->(!EOF()) .And. (cTabTemp)->TFJ_CODIGO == cCodTFJ
			lFound := .T.
		EndIf

		(cTabTemp)->(DbCloseArea())
	EndIf
ElseIf cModItem == "TFH_MC"
	nOrcPrc := If( SuperGetMV("MV_ORCPRC",,.F.), 1, 0)
	// executa a avaliação quando é orçamento com precificação
	// ou quando o item não é filho de um novo item de Rh
	If nOrcPrc == 1 .Or. ;
		!oMdlAtivo:GetModel("TFF_RH"):IsInserted()

		cCodItemEval := TFH->TFH_COD

		If Empty(cCodTFL)
			cExpCodTFL := "% TFH_FILIAL = '"+xFilial("TFH")+"' "
			cExpCodTFL += "AND TFH_COD = '"+cCodItemEval+"' "
			cExpCodTFL += "AND TFH.D_E_L_E_T_=' ' %"
		Else
			cExpCodTFL := "% TFH_FILIAL = '"+xFilial("TFH")+"' "
			cExpCodTFL += "AND TFH_COD = '"+cCodItemEval+"' "
			cExpCodTFL += "AND TFL_CODIGO = '"+cCodTFL+"' "
			cExpCodTFL += "AND TFH.D_E_L_E_T_=' ' %"
		EndIf

		cTabTemp := GetNextAlias()

		BeginSql Alias cTabTemp
			SELECT TFJ_CODIGO
			FROM %Table:TFH% TFH
				LEFT JOIN %Table:TFF% TFF ON 0 = %Exp:nOrcPrc%
										AND TFF_FILIAL = %xFilial:TFF%
										AND TFF_COD = TFH_CODPAI
										AND TFF.%NotDel%
				INNER JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
										AND (
												(0 = %Exp:nOrcPrc% AND TFL_CODIGO = TFF_CODPAI)
												OR (1 = %Exp:nOrcPrc% AND TFL_CODIGO = TFH_CODPAI)
											)
										AND TFL.%NotDel%
				INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
										AND TFJ_CODIGO = TFL_CODPAI
										AND TFJ.%NotDel%
			WHERE
				%Exp:cExpCodTFL%
		EndSql

		If (cTabTemp)->(!EOF()) .And. (cTabTemp)->TFJ_CODIGO == cCodTFJ
			lFound := .T.
		EndIf

		(cTabTemp)->(DbCloseArea())
	EndIf
ElseIf cModItem == "TFI_LE"
	cCodItemEval := TFI->TFI_COD
	If Empty(cCodTFL)
		cExpCodTFL := "% TFI_FILIAL = '"+xFilial("TFI")+"' "
		cExpCodTFL += "AND TFI_COD = '"+cCodItemEval+"' "
		cExpCodTFL += "AND TFI.D_E_L_E_T_=' ' %"
	Else
		cExpCodTFL := "% TFI_FILIAL = '"+xFilial("TFI")+"' "
		cExpCodTFL += "AND TFI_COD = '"+cCodItemEval+"' "
		cExpCodTFL += "AND TFL_CODIGO = '"+cCodTFL+"' "
		cExpCodTFL += "AND TFI.D_E_L_E_T_=' ' %"
	EndIf
	cTabTemp := GetNextAlias()

	BeginSql Alias cTabTemp
		SELECT TFJ_CODIGO
		FROM %Table:TFI% TFI
			INNER JOIN %Table:TFL% TFL ON TFL_FILIAL = %xFilial:TFL%
									AND TFL_CODIGO = TFI_CODPAI
									AND TFL.%NotDel%
			INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
									AND TFJ_CODIGO = TFL_CODPAI
									AND TFJ.%NotDel%
		WHERE
			%Exp:cExpCodTFL%
	EndSql

	If (cTabTemp)->(!EOF()) .And. (cTabTemp)->TFJ_CODIGO == cCodTFJ
		lFound := .T.
	EndIf

	(cTabTemp)->(DbCloseArea())

Else
	// qlq caso diferente da lista não é avaliado
	lFound := .T.
EndIf

Return lFound

/*/{Protheus.doc} At740VldCC
	Função para validar o centro de custo do local de atendimento

@return 	Lógico, Determina se o centro de custo do local é o mesmo do sitema
@since		13/02/2017
@version	P12
/*/
Function At740VldCC(oMdlTFL)
Local lRet		:= .T.
Local oModel	:= FwModelActive()
Local oMdlTFL 	:= Nil
Local cLocal 	:= ""
Local lIsOrcServ 	:= oModel:GetId() $ "TECA740/TECA740F"
Local aArea		:= GetArea()

//Verifica se o centro de custo do local é o mesmo que está logado
DbSelectArea("ABS")
ABS->(DbSetOrder(1))
If lIsOrcServ
	oMdlTFL	:= oModel:GetModel('TFL_LOC')
	cLocal	:= oMdlTFL:GetValue("TFL_LOCAL")
	If ABS->(MsSeek(xFilial("ABS")+ cLocal)) .And. !Empty(ABS->ABS_FILCC) .And. (cFilAnt <> ABS->ABS_FILCC)
		lRet	:= .F.
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"TFL_LOCAL",oModel:GetModel():GetId(),	"TFL_LOCAL",'TFL_LOCAL',;
			STR0135, STR0136 )//"A filial do centro de custo do local de atendimento selecionado é diferente da filial do sistema"##"Selecione um local de atendimento onde a filial do centro de custo configurado seja o mesmo do sistema"
	EndIf
EndIf

RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At740GatRc
	Gatilho para inserir a data no campo de data fim.
@author 	Kaique Schiller
@param 		NIL
@return 	cCod
@since		04/04/2017
@version	P12.1.16
/*/
//-------------------------------------------------------------------
Function At740GatRc(cCod,cCamp,cDetail,oMdl)
Local dDtFim 		:= SuperGetMv("MV_CNVIGCP",,cTod("31/12/2049"))
Local oModel		:= Nil
Local oDetail		:= Nil
Local oStruct 		:= Nil
Local bWhen			:= {|| .T. }
Local bValid		:= {|| .T. }
Local aDtl			:= {}

Default cCod 		:= ""
Default cCamp 		:= ""
Default cDetail		:= ""
Default oMdl		:= Nil

If !Empty(cCamp) .And. !Empty(cDetail)
	If ValType(oMdl) == "O"
		oModel		:= oMdl
	Else
		oModel		:= FwModelActive()
	Endif

	If oModel:GetId() $ "TECA740|TECA740F|TECA740A|TECA740B"
		aDtl	 	:= Separa(cDetail,"|")

		If oModel:GetId() $ "TECA740|TECA740F"
			cDetail := aDtl[1]
		Elseif oModel:GetId() $ "TECA740A|TECA740B|TECA740C"
			cDetail := aDtl[2]
		Endif

		oDetail		:= oModel:GetModel(cDetail)
		oStruct 	:= oDetail:GetStruct()

		bWhen := oStruct:GetProperty(cCamp,MODEL_FIELD_WHEN)
		oStruct:SetProperty(cCamp,MODEL_FIELD_WHEN,{|| .T. })
		If cCamp $ "TFF_PERFIM|TFH_PERFIM|TFG_PERFIM|TFI_PERFIM"
			bValid := oStruct:GetProperty(cCamp,MODEL_FIELD_VALID)
			oStruct:SetProperty(cCamp,MODEL_FIELD_VALID,{|| .T. })
		Endif
		oDetail:SetValue(cCamp,dDtFim)
		oStruct:SetProperty(cCamp,MODEL_FIELD_WHEN,bWhen)
		If cCamp $ "TFF_PERFIM|TFH_PERFIM|TFG_PERFIM|TFI_PERFIM"
			oStruct:SetProperty(cCamp,MODEL_FIELD_VALID,bValid)
		Endif
	Endif
Endif

Return cCod

//-------------------------------------------------------------------
/*/{Protheus.doc} At740GRec
	Gatilho para inserir as datas nos campos de data fim quando houver registros nas grid's.
@author 	Kaique Schiller
@param 		NIL
@return 	cCod
@since		04/04/2017
@version	P12.1.16
/*/
//------------------------------------------------------------------
Function At740GRec(cCodRec)
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nW			:= 0
Local nDias			:= 30
Local aSaveLines	:= {}
Local oModel		:= Nil
Local oView			:= Nil
Local oDtlTFL		:= Nil
Local oDtlTFF		:= Nil
Local oDtlTFG		:= Nil
Local oDtlTFH		:= Nil
Local oDtlTFI		:= Nil

Default cCodRec := "2"

If cCodRec == "1"
	oModel := FwModelActive()
	oView  := FwViewActive()
	If oModel:GetId() $ "TECA740|TECA740F"
		aSaveLines	:= FWSaveRows()
		oDtlTFL		:= oModel:GetModel("TFL_LOC")
		oDtlTFF		:= oModel:GetModel("TFF_RH")
		oDtlTFG		:= oModel:GetModel("TFG_MI")
		oDtlTFH		:= oModel:GetModel("TFH_MC")
		oDtlTFI		:= oModel:GetModel("TFI_LE")
		oDtlTEV		:= oModel:GetModel("TEV_ADICIO")

		For nX := 1 To oDtlTFL:Length()
			If !oDtlTFL:IsEmpty()
				oDtlTFL:GoLine(nX)
				If !(oDtlTFL:IsDeleted())
					At740GatRc(,"TFL_DTFIM","TFL_LOC",oModel)
					For nZ := 1 To oDtlTFF:Length()
						If !oDtlTFF:IsEmpty()
							oDtlTFF:GoLine(nZ)
							At740GatRc(,"TFF_PERFIM","TFF_RH",oModel)

							If TecVlPrPar() .AND. !oDtlTFF:IsDeleted() .AND.;
									!Empty( oDtlTFF:GetValue("TFF_PRODUT") ) .AND. oDtlTFF:GetValue("TFF_VLPRPA") == 0 .AND.;
										!isInCallStack("At870GerOrc")
								oDtlTFF:LoadValue("TFF_VLPRPA", At740PrxPa("TFF") )
							EndIf

							For nY := 1 To oDtlTFG:Length()
								If !oDtlTFG:IsEmpty()
									oDtlTFG:GoLine(nY)
									If !(oDtlTFG:IsDeleted())
										At740GatRc(,"TFG_PERFIM","TFG_MI",oModel)
									Endif
									If TecVlPrPar() .AND. !oDtlTFG:IsDeleted() .AND.;
											!Empty( oDtlTFG:GetValue("TFG_PRODUT") ) .AND. oDtlTFG:GetValue("TFG_VLPRPA") == 0 .AND.;
												!isInCallStack("At870GerOrc")
										oDtlTFG:LoadValue("TFG_VLPRPA", At740PrxPa("TFG") )
									EndIf
								Endif
							Next nY

							For nY := 1 To oDtlTFH:Length()
								If !oDtlTFH:IsEmpty()
									oDtlTFH:GoLine(nY)
									If !(oDtlTFH:IsDeleted())
										At740GatRc(,"TFH_PERFIM","TFH_MC",oModel)
									Endif
									If TecVlPrPar() .AND. !oDtlTFH:IsDeleted() .AND.;
											!Empty( oDtlTFH:GetValue("TFH_PRODUT") ) .AND. oDtlTFH:GetValue("TFH_VLPRPA") == 0 .AND.;
												!isInCallStack("At870GerOrc")
										oDtlTFH:LoadValue("TFH_VLPRPA", At740PrxPa("TFH") )
									EndIf
								Endif
							Next nY
						Endif
					Next nZ
					For nY := 1 To oDtlTFI:Length()
						If !oDtlTFI:IsEmpty()
							oDtlTFI:GoLine(nY)
							nQuant	:= oDtlTFI:GetValue("TFI_QTDVEN")
							At740GatRc(,"TFI_PERFIM","TFI_LE",oModel)
							For nW := 1 To oDtlTEV:Length()
								If !oDtlTEV:IsEmpty()
									oDtlTEV:GoLine(nW)
									If oDtlTEV:GetValue("TEV_MODCOB") == "2" .And. !(oDtlTEV:IsDeleted())
										oDtlTEV:SetValue("TEV_QTDE",(nQuant*nDias))
									Endif
								Endif
							Next nW
						Endif
					Next nY
					If TecVlPrPar() .AND. !oDtlTFL:IsDeleted() .AND.;
							!Empty( oDtlTFL:GetValue("TFL_LOCAL") ) .AND. !isInCallStack("At870GerOrc")
						At740AtTpr()
					EndIf
				Endif
			Endif
		Next nX
		FWRestRows(aSaveLines)
		If ValType(oView) == "O" .And. oView:GetModel():GetId() $ "TECA740|TECA740F"
			oView:Refresh()
		Endif
	Endif
ElseIf cCodRec == "2"
	oModel := FwModelActive()
	oView  := FwViewActive()
	If oModel:GetId() $ "TECA740|TECA740F"
		aSaveLines	:= FWSaveRows()
		oDtlTFL		:= oModel:GetModel("TFL_LOC")
		oDtlTFF		:= oModel:GetModel("TFF_RH")
		oDtlTFG		:= oModel:GetModel("TFG_MI")
		oDtlTFH		:= oModel:GetModel("TFH_MC")

		For nX := 1 To oDtlTFL:Length()
			If !oDtlTFL:IsEmpty()
				oDtlTFL:GoLine(nX)
				If !(oDtlTFL:IsDeleted())
					For nZ := 1 To oDtlTFF:Length()
						If !oDtlTFF:IsEmpty()
							oDtlTFF:GoLine(nZ)

							If TecVlPrPar() .AND. !oDtlTFF:IsDeleted() .AND.;
									!Empty( oDtlTFF:GetValue("TFF_PRODUT") ) .AND. oDtlTFF:GetValue("TFF_VLPRPA") != 0 .AND.;
										!isInCallStack("At870GerOrc")
								oDtlTFF:LoadValue("TFF_VLPRPA", 0 )
							EndIf

							For nY := 1 To oDtlTFG:Length()
								If !oDtlTFG:IsEmpty()
									oDtlTFG:GoLine(nY)
									If TecVlPrPar() .AND. !oDtlTFG:IsDeleted() .AND.;
											!Empty( oDtlTFG:GetValue("TFG_PRODUT") ) .AND. oDtlTFG:GetValue("TFG_VLPRPA") != 0 .AND.;
												!isInCallStack("At870GerOrc")
										oDtlTFG:LoadValue("TFG_VLPRPA", 0 )
									EndIf
								Endif
							Next nY

							For nY := 1 To oDtlTFH:Length()
								If !oDtlTFH:IsEmpty()
									oDtlTFH:GoLine(nY)
									If TecVlPrPar() .AND. !oDtlTFH:IsDeleted() .AND.;
											!Empty( oDtlTFH:GetValue("TFH_PRODUT") ) .AND. oDtlTFH:GetValue("TFH_VLPRPA") != 0 .AND.;
												!isInCallStack("At870GerOrc")
										oDtlTFH:LoadValue("TFH_VLPRPA", 0 )
									EndIf
								Endif
							Next nY
						Endif
					Next nZ
					If TecVlPrPar() .AND. !oDtlTFL:IsDeleted() .AND. oDtlTFL:GetValue("TFL_VLPRPA") != 0 .AND.;
							!Empty( oDtlTFL:GetValue("TFL_LOCAL") ) .AND. !isInCallStack("At870GerOrc")
						oDtlTFL:LoadValue("TFL_VLPRPA", 0 )
					EndIf
				Endif
			Endif
		Next nX
		FWRestRows(aSaveLines)
		If ValType(oView) == "O" .And. oView:GetModel():GetId() $ "TECA740|TECA740F"
			oView:Refresh()
		Endif
	Endif
Endif

Return cCodRec

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Recor
	Se o contrato não for recorrente retorna .T.

@sample 	At740Recor(cNumCtr)
@param		ExpC1	Codigo do contrato

@author		Kaique Schiller
@since		10/04/2017
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740Recor(cNumCtr)
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cRevis	:= ""
Default cNumCtr := ""

If !Empty(cNumCtr)
	cRevis := Posicione("CN9",7,xFilial("CN9")+cNumCtr+"05","CN9_REVISA")
	DbSelectArea("TFJ")
	TFJ->(DbSetOrder(5)) //TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
	If TFJ->(DbSeek(xFilial("TFJ")+cNumCtr+cRevis))
		If TFJ->TFJ_CNTREC == "1"
			lRet := .F.
		Endif
	Endif
Endif

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Recor
	Se o contrato for recorrente bloqueia os campos de data fim.

@sample 	At740WhenR()

@author		Kaique Schiller
@since		17/04/2017
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740WhenR()

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740TpVerb
@description 	Função para o gatilho do tipo de verba convertendo entre H, V e D para 1, 2 e 3 respectivamente.
@sample 		At740TpVerb()
@author		josimar.assuncao
@since			30/05/2017
@version		P12
@return 		Caracter, devolve o tipo da verba convertida de H, V e D para 1, 2 e 3.
/*/
//------------------------------------------------------------------------------
Function At740TpVerb()
Local cTpVerba := Posicione("SRV", 1, xFilial("SRV")+M->ABP_VERBA, "RV_TIPO" )
Return At740ConvTp( cTpVerba )
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ConvTp
@description 	Função para conversão do conteúdo de H, V e D dos tipos de verba para 1, 2 e 3.
@sample 		At740ConvTp( "H" ) ==> "1"
@author		josimar.assuncao
@since			02.06.2017
@version		P12
@param 			cTipoLetra, caracter, tipo da verba como H, V ou D.
@return 		Caracter, devolve o tipo da verba convertida de H, V e D para 1, 2 e 3.
/*/
//------------------------------------------------------------------------------
Function At740ConvTp( cTipoLetra )
Local cRetorno := ""

If cTipoLetra == "H"
	cRetorno := "1"
ElseIf cTipoLetra == "V"
	cRetorno := "2"
ElseIf cTipoLetra == "D"
	cRetorno := "3"
EndIf

Return cRetorno
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ToADZ
@description 	Função para indicar que é necessário levar os dados do orçamento para a proposta comercial
@sample 		At740ToADZ( .F. ) // At740ToADZ()
@author		josimar.assuncao
@since			25.07.2017
@version		P12
@param 			lValor, lógico, conteúdo a ser atribuído
@return 		Lógico, devolve o conteúdo inserido
/*/
//------------------------------------------------------------------------------
Function At740ToADZ( lValor )
If ValType(lValor) == "L"
	lImpToADZ := lValor
EndIf
Return lImpToADZ
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740RplFac
@description 	Função para indicar que é necessário replicar o facilitador nos locais
@sample 		At740RplFac( .F. ) // At740RplFac()
@author		josimar.assuncao
@since			25.07.2017
@version		P12
@param 			lValor, lógico, conteúdo a ser atribuído
@return 		Lógico, devolve o conteúdo inserido
/*/
//------------------------------------------------------------------------------
Function At740RplFac( lValor )
If ValType(lValor) == "L"
	lTotLoc := lValor
EndIf
Return lTotLoc
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740HrEtr
@description 	Função que preenche o TFU_ABNDES de acordo com o TFU_CODABN, na grid de Horas Extras
@author		mateus.boiani
@since			28.11.2017
@version		P12
@param 			oModel, objeto, Modelo de dados do grid das Horas Extras
/*/
//------------------------------------------------------------------------------
Function At740HrEtr(oModel)
Local nI
Local cCODABN

For nI := 1 To oModel:Length()
	oModel:GoLine( nI )
	cCODABN := oModel:GetValue("TFU_CODABN")
	If !EMPTY(cCODABN)
		oModel:LoadValue("TFU_ABNDES", At740TrgABN(cCODABN))
	EndIf
Next
oModel:GoLine( 1 )

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Habil
@description 	Função que desabilita campos na Revisão do Contrato

@param 		aCampos, array, contém o nome dos campos que devem ser bloqueados para edição
@param 		oModel, model, modelo de dados que será editado
@since		30/11/2017
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740Habil(aCampos, oModel)
Local nI
Local cX3_Propri
Local cNotBlock := "TFJ_CONDPG|TFJ_OBSPRC|TFJ_GRPCOM"

If TFJ->( ColumnPos("TFJ_PRDRET")) > 0
	cNotBlock += "|TFJ_PRDRET"
EndIf

For nI := 1 To LEN(aCampos)
	cX3_Propri := GetSx3Cache(aCampos[nI][1],'X3_PROPRI')
	If oModel:HasField(aCampos[nI][1]) .AND. VALTYPE(cX3_Propri) == 'C' .AND. cX3_Propri != 'U' .AND. !(aCampos[nI][1]$cNotBlock)
		oModel:SetProperty(aCampos[nI][1], MVC_VIEW_CANCHANGE, .F.)
	EndIf
Next

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFU
@description 	Prevalid validação para a grid de Horas Extras do orçamento

@param 		oMdlG, nLine,cAcao, cCampo Modelo, linha, código da ação e nome do campo
@since		14/05/2018
@version	P12
@author	Diego A. Bezerra
/*/
//------------------------------------------------------------------------------
Function PreLinTFU(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdlFull		:= If(oMdlG <> nil, oMdlG:GetModel(), nil)
Local lFillModel	:= isInCallStack("FillModel")
Local lOk	:=	.T.
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)		//Verifica se usa a tabela de precificação
Local lExiste 		:= .F.
Local lInclui		:= oMdlFull:GetOperation() == MODEL_OPERATION_INSERT

If oMdlFull <> Nil .And.;
	!IsInCallStack('At870GerOrc')
	If !('CAN' $ cAcao) .AND. (IsInCallStack('At870Revis') .AND.!(IsInCallStack('AT870PlaRe') .OR. IsInCallStack('AplicaRevi'))) .AND. ;
		!AT870RevPl(TFJ->TFJ_CODIGO) .AND. AT870ItPla( oMdlG:GetValue("TFU_CODIGO"), "TFU" )
		lOk := .F.
		Help(,,'PreLinTFU',, STR0298,1,0) // "Não é possivel alterar itens de uma Manutenção Planejada em uma revisão!."
	EndIf

	If lOk .AND. cAcao == 'SETVALUE'
		If !lFillModel
			If oMdlFull:GetId() == 'TECA740'
				If oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
					lOk := .F.
					Help( ,, 'PreLinTFU',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
				EndIf
			ElseIf oMdlFull:GetId() == 'TECA740F'
				If  oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
					lOk	:= .F.
					Help( ,, 'PreLinABP',, STR0148, 1, 0 ) //"Não é possível editar esse registro, pois o local de atendimento está finalizado"
				EndIf
			EndIf
		EndIf
		If lOk .AND. isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi")
			aStruct  := oMdlG:GetStruct():GetFields()
			nPos := Ascan( aStruct, {|x| x[3] == cCampo })
			If nPos > 0 .AND. !aStruct[nPos][MODEL_FIELD_VIRTUAL]
				If VldTFULinR( cCampo, xValue, IIF(Empty(oMdlG:getValue("TFU_CODREL")), oMdlG:getValue("TFU_CODIGO"), oMdlG:getValue("TFU_CODREL")), IIF(Empty(oMdlFull:GetModel('TFF_RH'):GetValue('TFF_CODREL')), oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD'), oMdlFull:GetModel('TFF_RH'):GetValue('TFF_CODREL')), aStruct[nPos][4] == 'D' )
					oMdlG:LoadValue('TFU_MODPLA', "2")
				Else
					oMdlG:LoadValue('TFU_MODPLA', "1")
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If cAcao == 'DELETE'
	If lOk .AND. isInCallStack("AT870PlaRe") .OR. isInCallStack("AplicaRevi")
		If lInclui .AND. (oMdlG:getValue("TFU_MODPLA") <> "1" .OR. VldHeContr( oMdlG:getValue("TFU_CODIGO"), oMdlFull:GetModel('TFF_RH'):GetValue('TFF_COD')))
			Help(,,'PreLinTFU',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
			lOk := .F.
		ElseIf oMdlG:getValue("TFU_MODPLA") <> "1" .OR. !Empty(oMdlG:getValue("TFU_CODREL"))
			Help(,,'PreLinTFU',, STR0297,1,0) // "Não é possivel excluir itens não planejados."
			lOk := .F.
		EndIf
	EndIf
EndIf

//Valida se a linha pode ser deletada na Revisao de Contrato
If lOk .AND. (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe") ) .AND. cAcao == 'DELETE'
	lExiste := !oMdlG:IsInserted()
	If lExiste
		Help( ,, 'PreLinTFU',, STR0151, 1, 0 ) //Não é possível excluir esse item.
		lOk := .F.
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinABP
@description 	Prevalid validação para a grid de Benefícios

@param 		oMdlG, nLine,cAcao, cCampo Modelo, linha, código da ação e nome do campo
@since		14/05/2018
@version	P12
@author	Diego A. Bezerra
/*/
//------------------------------------------------------------------------------
Function PreLinABP(oMdlG, nLine, cAcao, cCampo, xValue, xCurrentValue)

Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oMdlFull	:= If(oMdlG <> nil, oMdlG:GetModel(), nil)
Local lFillModel:= isInCallStack("FillModel")
Local lOk		:= .T.
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.)		//Verifica se usa a tabela de precificação
Local lVerbaAd	:= FindFunction("TECA740K") .And. TableInDic("TXO") .And. TXO->( ColumnPos('TXO_COD') ) > 0

If oMdlFull <> Nil .And. (oMdlFull:GetId() == 'TECA740' .Or. oMdlFull:GetId() == 'TECA740F') .AND. !lTEC740FUn

	If oMdlFull <> Nil .And.;
		!IsInCallStack('At870GerOrc')

		If cAcao == 'SETVALUE'
			If !lFillModel
				If oMdlFull:GetId() == 'TECA740'
					If oMdlFull:GetModel('TFF_RH'):GetValue('TFF_ENCE') == '1' .OR. oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						lOk := .F.
						Help( ,, 'PreLinABP',, STR0147, 1, 0 ) //"Não é possível editar esse registro, pois o Local de Atendimento ou Item de RH estão finalizados"
					EndIf
				ElseIf oMdlFull:GetId() == 'TECA740F'
					If  oMdlFull:GetModel('TFL_LOC'):GetValue('TFL_ENCE') == '1'
						lOk	:= .F.
						Help( ,, 'PreLinABP',, STR0148, 1, 0 ) //"Não é possível editar esse registro, pois o local de atendimento está finalizado"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lOk .And. oMdlFull <> Nil .And. lVerbaAd
	If !IsInCallStack("TECA740K")
		If ABP->(ColumnPos('ABP_NICKPO')) > 0 .And. ABP->(ColumnPos('ABP_CONFCA')) > 0
			If oMdlG:GetValue("ABP_CONFCA") == "1"
				If cAcao == "DELETE" .Or. cAcao == "UNDELETE"
					FwMsgRun(Nil,{||at740UpdPl(cAcao, oMdlG, oMdlFull)},Nil, STR0355 )//"Atualizando valores..."
				EndIf
				If cCampo == "ABP_VALOR"
					If cAcao == "SETVALUE"
						FwMsgRun(Nil,{||at740UpdPl(cAcao, oMdlG, oMdlFull, xValue)},Nil, STR0355 )//"Atualizando valores..."
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lOk


//------------------------------------------------------------------------------
/*/{Protheus.doc} a740ChgLine
@description 	Função para evento de mudança de linha na view

@param 		oView, cViewId
@since		21/05/2018
@version	P12
@author	Diego A. Bezerra
/*/
//------------------------------------------------------------------------------
Function a740ChgLine(oView, cViewId)
Local oModel
Local lEnce
Local lTFFEnce
Local lTFIEnce
Local oTFLDetail := Nil
Local oTFFDetail := Nil
Local oTFIDetail := Nil
Local oTFGDetail := Nil
Local oTFHDetail := Nil
Local oTEVDetail := Nil
Local oTFUDetail := Nil
Local oABPDetail := Nil
Local cGesMat	 := ""
Local lBlqMI	 := .F.
Local lBlqMC 	 := .F.

Local cId := ""
Local lRefresh := .F.

Default oView	:= Nil

If (IsInCallStack("At870Revis") .OR. IsInCallStack("AT870PlaRe") )
	If oView == Nil
		oModel :=  FWModelActive()
		cId := oModel:getId()
		If cId $ 'TECA740|TECA740F'
			oModel:GetModel('TFL_LOC'):GoLine(1)
		EndIf
	Else
		oModel 		:= oView:GetModel()
		cId := oModel:getId()

		oTFLDetail := oModel:GetModel('TFL_LOC')
		oTFFDetail := oModel:GetModel('TFF_RH')
		oTFIDetail := oModel:GetModel('TFI_LE')
		oTFGDetail := oModel:GetModel('TFG_MI')
		oTFHDetail := oModel:GetModel('TFH_MC')
		oTEVDetail := oModel:GetModel('TEV_ADICIO')
		oTFUDetail := oModel:GetModel('TFU_HE')
		oABPDetail := oModel:GetModel('ABP_BENEF')

		cGesMat		:= oModel:GetModel("TFJ_REFER"):GetValue("TFJ_GESMAT")
		lEnce 		:= oTFLDetail:GetValue('TFL_ENCE') == '1'
		lTFFEnce 	:= oTFFDetail:GetValue('TFF_ENCE')  == '1'
		lTFIEnce 	:= oTFIDetail:GetValue('TFI_ENCE')  == '1'

		If cGesMat == '2' .Or. cGesMat == '3'
			lBlqMI := .T.
			lBlqMC := .T.
		ElseIf  cGesMat == '4'
			lBlqMC := .T.
		ElseIf  cGesMat == '5'
			lBlqMI := .T.
		EndIf

		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_INSERT
			If cId == 'TECA740'
				If cViewId == 'TFL_LOC'
					oTFFDetail:SetNoInsertLine(lEnce)
					oTFIDetail:SetNoInsertLine(lEnce)
					oTFGDetail:SetNoInsertLine(lEnce)
					oTFHDetail:SetNoInsertLine(lEnce)
					oTEVDetail:SetNoInsertLine(lEnce)
					oTFUDetail:SetNoInsertLine(lEnce)
					oABPDetail:SetNoInsertLine(lEnce)
				ElseIf cViewId == 'TFF_RH'
					oTFFDetail:SetNoInsertLine(lEnce)
					oTFGDetail:SetNoInsertLine(lTFFEnce)
					oTFHDetail:SetNoInsertLine(lTFFEnce)
					oTFUDetail:SetNoInsertLine(lTFFEnce)
					oABPDetail:SetNoInsertLine(lTFFEnce)
				ElseIf cViewId == 'TFI_LE'
					oTFIDetail:SetNoInsertLine(lEnce)
					oTEVDetail:SetNoInsertLine(lTFIEnce)
				EndIf
			ElseIf cId == 'TECA740F'
				If cViewId == 'TFL_LOC'
					oTFFDetail:SetNoInsertLine(lEnce)
					oTFIDetail:SetNoInsertLine(lEnce)
					oTFGDetail:SetNoInsertLine(lEnce)
					oTFHDetail:SetNoInsertLine(lEnce)
					oTEVDetail:SetNoInsertLine(lEnce)
					oTFUDetail:SetNoInsertLine(lEnce)
					oABPDetail:SetNoInsertLine(lEnce)
				ElseIf cViewId == 'TFF_RH'
					oTFFDetail:SetNoInsertLine(lEnce)
					oTFUDetail:SetNoInsertLine(lTFFEnce)
					oABPDetail:SetNoInsertLine(lTFFEnce)
				ElseIf cViewId == 'TFI_LE'
					oTFIDetail:SetNoInsertLine(lEnce)
					oTEVDetail:SetNoInsertLine(lTFIEnce)
				ElseIf cViewId == 'TFH_MC'
					oTFHDetail:SetNoInsertLine(lEnce)
				ElseIf cViewId == 'TFG_MI'
					oTFGDetail:SetNoInsertLine(lEnce)
				EndIf
			EndIf
		EndIf
		If cViewId == 'TFL_LOC'
			If Empty(oTFLDetail:GetValue('TFL_LOCAL'))

				lRefresh := at740IniLin(oTFFDetail,'TFF_COD','TFF_LEGEN') .Or. lRefresh
				lRefresh := at740IniLin(oTFIDetail,'TFI_COD','TFI_LEGEN',{'TFI_NOMATD'}) .Or. lRefresh
				If !lBlqMI
					lRefresh := at740IniLin(oTFGDetail,'TFG_COD') .Or. lRefresh
				EndIf
				If !lBlqMC
					lRefresh := at740IniLin(oTFHDetail,'TFH_COD') .Or. lRefresh
				EndIf
			EndIf
		EndIf
		If cViewId == 'TFF_RH' .And. cId == 'TECA740'
			If Empty(oTFFDetail:GetValue('TFF_PRODUT'))
				lRefresh := at740IniLin(oTFGDetail,'TFG_COD') .Or. lRefresh
				lRefresh := at740IniLin(oTFHDetail,'TFH_COD') .Or. lRefresh
			EndIf

		EndIf
		If lRefresh
			oView:Refresh()
		EndIf
	EndIf
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldLe
@description 	Validação dos valores de locação de equipamento, considerando itens zerados

@param 		oModel
@since		01/10/2018
@version	P12
@author	Matheus Lando Raimundo
/*/
//------------------------------------------------------------------------------
Static Function At740VldLe(oModel)
Local lRet := .T.
Local oTFIDetail := oModel:GetModel('TFI_LE')
Local nI := 1
Local nTotLE := 0
Local lLE := .F.


For nI := 1 To oTFIDetail:Length()
	oTFIDetail:GoLine(nI)
    If !oTFIDetail:IsDeleted() .And. !Empty( oTFIDetail:GetValue('TFI_PRODUT') )
    	nTotLE += oTFIDetail:GetValue('TFI_TOTAL')
		lLE := .T.
    	If nTotLE > 0
    		Exit
    	EndIf
  	EndIf
Next nI

If lLE .And. nTotLE == 0
	lRet := .F.
	Help(,,'AT740LEZERO',STR0181,,1,0) //'O valor total de itens de locação de equipamentos não pode ser igual a 0, informe o valor de cobrança em ao menos 1 (um) item.'
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ApP
Função de Aplicação de Planilha
@sample 	At740ApP(oModel)
@param		oModel, objeto, modelo MVC
@return	Nenhum
@since		08/10/2018
@author	Serviços
@version	12.1.17
/*/
//------------------------------------------------------------------------------

Static Function At740ApP(oModel)

Default oModel := NIL

If oModel <> NIL
	MsgRun( STR0183, STR0082, { || At740ApG(oModel)} )  //"Aplicando automaticamente a planilha#"Aguarde... #
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ApG
Função de Aplicação Automática da Planilha
@sample 	At740ApG(oModel)
@param		oModel, objeto, modelo MVC
@return	Nenhu,
@since		08/10/2018
@author	Serviços
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function At740ApG(oModel)
Local oMdlRh		:= oModel:GetModel("TFF_RH") //Modelo de Recursos Humanos
Local nY 			:= 0 //Contador de Linhas do Model
Local aPlanilha 	:= {} //Planilha Retornada


For nY := 1 To oMdlRh:Length()
	oMdlRh:GoLine(nY)
	If  Empty(oMdlRh:GetValue('TFF_PLACOD') ) .And. Empty(oMdlRh:GetValue('TFF_PLAREV') )

		aPlanilha := At740AR(oMdlRh:GetValue('TFF_PRODUT'), oMdlRh:GetValue('TFF_FUNCAO'),oMdlRh:GetValue('TFF_TURNO'),oMdlRh:GetValue('TFF_SEQTRN'), oMdlRh:GetValue('TFF_CARGO'), oMdlRh:GetValue('TFF_ESCALA') )
		If Len(aPlanilha) > 1
			At998ExPla(aPlanilha[2],oModel,.F., aPlanilha[1], .T.)
		EndIf
	EndIf
Next nY

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740AR
Função de Seleção de Planilha
@sample 	At740AR(cProduto, cFuncao, cTurno, cSeqTrn, cCargo, cEscala)
@param		cProduto, Caractere, Código do Produto
@param		cFuncao, Caractere, Código da Função
@param		cTurno, Caractere, Código do Turno
@param		cSeqTrn, Caractere, Código da Seq do Turno
@param		cCargo, Caractere, Código do Cargo
@param		cEscala, Caractere, Código da Escala
@return	aRetorno, Array, dados da planilha retornada onde
					[1] - XML da Planilha
					[2] - Código da Planilha + Revisão
@since		08/10/2018
@author	Serviços
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function At740AR(cProduto, 	cFuncao, cTurno, cSeqTrn, ;
						 cCargo, 	cEscala)

Local cPrdVazio 	:= Space(TamSX3("TX8_PRODUT")[1]) //Código do Produto Vazio
Local cFuncVazio 	:= Space(TamSX3("TX8_FUNCAO")[1]) //Código da Função
Local cTurnVazio 	:= Space(TamSX3("TX8_TURNO")[1]) //Turno Vazio
Local cSeqVazio 	:= Space(TamSX3("TX8_SEQTRN")[1]) //Sequencia Vazia
Local cCargVazio 	:= Space(TamSX3("TX8_CARGO")[1]) //Cargo Vazio
Local cEscVazio 	:= Space(TamSX3("TX8_ESCALA")[1]) //Escala Vazia
Local cWhere 		:= "" //Filtros da Query
Local cWhere2 		:= "" //Expressão temporária
Local cAliasQry 	:= GetNextAlias() //Alias da Query
Local aRetorno 		:= {} //Retorno da rotina
Local aAreaABW		:= {}

cWhere2 := "TX8.TX8_PRODUT = '" +cPrdVazio  + "'"
If !Empty(cProduto)
	cWhere := " AND (TX8.TX8_PRODUT = '" +cProduto  + "' OR "  + cWhere2 + " )"
Else
	cWhere := " AND "  + cWhere2
EndIf

cWhere2 := "TX8.TX8_FUNCAO = '" +cFuncVazio  + "'"
If !Empty(cFuncao)
	cWhere += " AND (TX8.TX8_FUNCAO = '" +cFuncao  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere2 := "TX8.TX8_TURNO = '" +cTurnVazio  + "'"
If !Empty(cTurno)
	cWhere += " AND (TX8.TX8_TURNO = '" +cTurno  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere2 := "TX8.TX8_SEQTRN = '" +cSeqVazio  + "'"
If !Empty(cSeqTrn)
	cWhere += " AND (TX8.TX8_SEQTRN = '" +cSeqTrn  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere2 := "TX8.TX8_CARGO = '" +cCargVazio  + "'"
If !Empty(cCargo)
	cWhere += " AND (TX8.TX8_CARGO = '" +cCargo  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere2 := "TX8.TX8_ESCALA = '" +cEscVazio  + "'"
If !Empty(cEscala)
	cWhere += " AND (TX8.TX8_ESCALA = '" +cEscala  + "' OR "  + cWhere2 + " )"
Else
	cWhere += " AND " + cWhere2
EndIf

cWhere := "%" + cWhere + "%"

BeginSql Alias cAliasQry

	SELECT TX8.TX8_PRODUT, TX8.TX8_FUNCAO, TX8.TX8_TURNO, TX8.TX8_SEQTRN, TX8.TX8_CARGO, TX8.TX8_ESCALA, TX8.TX8_PLANIL, ABW.ABW_REVISA, TX8.TX8_PRIORI
	  FROM %table:TX8% TX8
	       INNER JOIN %table:ABW% ABW ON ABW.ABW_FILIAL  = %xFilial:ABW%
	                                 AND ABW.%NotDel%
	                                 AND ABW.ABW_ULTIMA = '1'
	                                 AND ABW.ABW_CODIGO = TX8.TX8_PLANIL
	 WHERE TX8.TX8_FILIAL = %xFilial:TX8%
	   AND TX8.%NotDel%
	   %exp:cWhere%
	 ORDER BY TX8.TX8_PRIORI ASC
EndSql

If !(cAliasQry)->(Eof())
		aAreaABW := ABW->(GetArea())
		ABW->(DbSetOrder(1)) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
		If ABW->(DbSeek(xFilial("ABW")+(cAliasQry)->(TX8_PLANIL+ABW_REVISA)))
			aRetorno := {  (cAliasQry)->(TX8_PLANIL+ABW_REVISA), ;
							ABW->ABW_INSTRU }
		EndIf
		RestArea(aAreaABW)
EndIf

(cAliasQry)->(DbCloseArea())

Return aRetorno

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740IniLin
Inicializa linha com os inicilizadores padrão dos campos
@since		07/11/2018
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function at740IniLin(oMdlGrid,cKeyField,cFieldLeg,aFldExp)
Local oFields := Nil
Local cField := ""
Local nI := 1
Local lRet := .F.
Default cFieldLeg := ""
Default aFldExp := {}


If Empty(oMdlGrid:GetValue(cKeyField)) //Linha nova
	oFields := oMdlGrid:GetStruct():GetFields()
	For nI := 1 To Len(oFields)
		cField := oFields[nI,MODEL_FIELD_IDFIELD]
		If !Empty(oFields[nI,MODEL_FIELD_INIT]) .And. cField <> cFieldLeg .And. Ascan(aFldExp,cField) == 0
			If oMdlGrid:CanSetValue(cField)
				If cField <> "TFF_LOADPRC"
					oMdlGrid:SetValue(cField,CriaVar(cField,.T.))
				Else
					oMdlGrid:SetValue(cField,.F.)
				EndIf
			Else
				oMdlGrid:LoadValue(cField,CriaVar(cField,.T.))
			EndIf
		EndIf
	Next nI

	If !Empty(cFieldLeg) .And. oMdlGrid:GetStruct():HasField(cFieldLeg)
		oMdlGrid:LoadValue(cFieldLeg, "BR_VERDE")
	EndIf
	oMdlGrid:aDataModel[1,MODEL_GRID_MODIFY] := .F.
	lRet := .T.
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740RHNoCalc
verifica se o item possui calculo no item de RH ou linha zerada
@since		10/01/2019
@author	fabianas.silva
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740RHNoCalc(oFWSheet)
Local lRet := .T.

If !Empty(oFWSheet)

	lRet :=  oFWSheet:GetCellValue("TOTAL_RH") = 0
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740AtCod
Carrega valor inicial no campo codigo da TFF
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740AtCod(oModel)

oModel:LoadValue('TFF_COD', CriaVar('TFF_COD',.T.))

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740UCdSb
Atualiza o CODSUB dos itens do Orçamento
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740UCdSb(aRec, cTFJNew)
Local nI 		:= 1
Local lRevPla	:= (isInCallStatck("AT870PlaRe") .OR. isInCallStatck("AplicaRevi")) .AND. !(isInCallStack("AT870RvPlC"))
Default cTFJNew := ""
For nI := 1 To Len(aRec)
	If aRec[nI, 1] == 'TFL' //LOCAL DE ATENDIMENTO

		TFL->(DbSetOrder(1))
		If lRevPla
			TFL->(DbSeek(xFilial('TFL')+ aRec[nI, 3]))
		Else
			TFL->(DbSeek(xFilial('TFL')+ aRec[nI, 2]))
		EndIf
		RecLock('TFL',.F.)
		If lRevPla
			TFL->TFL_CODREL := aRec[nI, 2]
		Else
			TFL->TFL_CODSUB := aRec[nI, 3]
		EndIf
		TFL->(MsUnlock())

	ElseIf 	aRec[nI, 1] == 'TFF' //ITEM DE RH - POSTO
		TFF->(DbSetOrder(1))
		If lRevPla
			TFF->(DbSeek(xFilial('TFF')+ aRec[nI, 3]))
		Else
			TFF->(DbSeek(xFilial('TFF')+ aRec[nI, 2]))
		EndIf
		If !lRevPla .AND. FindFunction("TecBHasCrn") .AND. TecBHasCrn()
			At740IAtCd("TFF",TFF->TFF_COD, aRec[nI, 3], cTFJNew)
		EndIf
		RecLock('TFF',.F.)
		If lRevPla
			TFF->TFF_CODREL := aRec[nI, 2]
		Else
			TFF->TFF_CODSUB := aRec[nI, 3]
		EndIf
		TFF->(MsUnlock())

	ElseIf 	aRec[nI, 1] == 'TFG' //MATERIAL DE IMPLANTAÇÃO
		TFG->(DbSetOrder(1))
		If lRevPla
			TFG->(DbSeek(xFilial('TFG')+ aRec[nI, 3]))
		Else
			TFG->(DbSeek(xFilial('TFG')+ aRec[nI, 2]))
		EndIf
		If !lRevPla .AND. FindFunction("TecBHasCrn") .AND. TecBHasCrn()
			At740IAtCd("TFG",TFG->TFG_COD, aRec[nI, 3], cTFJNew)
		EndIf
		RecLock('TFG',.F.)
		If lRevPla
			TFG->TFG_CODREL := aRec[nI, 2]
		Else
			TFG->TFG_CODSUB := aRec[nI, 3]
		EndIf
		TFG->(MsUnlock())


	ElseIf 	aRec[nI, 1] == 'TFH' //MATERIAL DE CONSUMO
		TFH->(DbSetOrder(1))
		If lRevPla
			TFH->(DbSeek(xFilial('TFH')+ aRec[nI, 3]))
		Else
			TFH->(DbSeek(xFilial('TFH')+ aRec[nI, 2]))
		EndIf
		If !lRevPla .AND. FindFunction("TecBHasCrn") .AND. TecBHasCrn()
			At740IAtCd("TFH",TFH->TFH_COD, aRec[nI, 3], cTFJNew)
		EndIf
		RecLock('TFH',.F.)
		If lRevPla
			TFH->TFH_CODREL := aRec[nI, 2]
		Else
			TFH->TFH_CODSUB := aRec[nI, 3]
		EndIf
		TFH->(MsUnlock())

	ElseIf 	aRec[nI, 1] == 'TFI' //LOCAÇÃO DE EQUIPAMENTOS
		TFI->(DbSetOrder(1))
		TFI->(DbSeek(xFilial('TFI')+ aRec[nI, 2]))
		RecLock('TFI',.F.)
		TFI->TFI_CODSUB := aRec[nI, 3]
		TFI->(MsUnlock())

	ElseIf aRec[nI, 1] == 'TFU'
		TFU->(DbSetOrder(1))
		If TFU->(DbSeek(xFilial('TFU')+ aRec[nI, 3]))
			RecLock('TFU',.F.)
				TFU->TFU_CODREL := aRec[nI, 2]
			TFU->(MsUnlock())
		EndIf

	ElseIf aRec[nI, 1] == 'TXQ' //ARMAMENTOS - ARMA, COLETE E MUNIÇÕES
		TXQ->(DbSetOrder(1))
		If lRevPla
			//TXQ->(DbSeek(xFilial('TXQ')+ aRec[nI, 3]))
		Else
			TXQ->(DbSeek(xFilial('TXQ')+ aRec[nI, 2]))
		EndIf
		If TXQ->(Found())
			RecLock('TXQ',.F.)
			If lRevPla
				//TXQ->TXQ_CODREL := aRec[nI, 2]
			Else
				TXQ->TXQ_CODSUB := aRec[nI, 3]
			EndIf
			TXQ->(MsUnlock())
		EndIf

	ElseIf aRec[nI, 1] == 'TXP' //UNIFORMES
		TXP->(DbSetOrder(1))
		If lRevPla
			//TXP->(DbSeek(xFilial('TXP')+ aRec[nI, 3]))
		Else
			TXP->(DbSeek(xFilial('TXP')+ aRec[nI, 2]))
		EndIf
		If TXP->(Found())
			RecLock('TXP',.F.)
			If lRevPla
				//TXP->TXP_CODREL := aRec[nI, 2]
			Else
				TXP->TXP_CODSUB := aRec[nI, 3]
			EndIf
			TXP->(MsUnlock())
		EndIf
	EndIf

Next nI
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740UpSLY
Manipulação dos dados de Vinculo com Beneficios
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740UpSLY(cCodOld,cCodNew)
Local aBenefEx	:= {}
Local cAliasSLY := ""
Local cQuerySLY := ""
Local nPosSLY	:= 0
Local nX		:= 0
Local oQuery 	:= Nil

DbSelectArea("SLY")
SLY->(DbSetOrder(1)) //LY_FILIAL, LY_TIPO, LY_AGRUP, LY_ALIAS, LY_FILENT, LY_CHVENT, LY_CODIGO, LY_DTINI

// Verifica se existe beneficio vinculado
cQuerySLY := " SELECT SLY.* "
cQuerySLY += " FROM ? SLY"
cQuerySLY += " WHERE SLY.LY_FILIAL = ? "
cQuerySLY += "   AND SUBSTRING(LY_CHVENT,1,?) = ? "
cQuerySLY += "   AND SLY.LY_FILENT = ? "
cQuerySLY += "   AND SLY.LY_ALIAS = 'TDX' "
cQuerySLY += "   AND SLY.D_E_L_E_T_ = ' ' "
cQuerySLY += " ORDER BY SLY.LY_FILIAL, SLY.LY_TIPO, SLY.LY_AGRUP, SLY.LY_ALIAS, SLY.LY_FILENT, SLY.LY_CHVENT, SLY.LY_CODIGO, SLY.LY_DTINI "

cQuerySLY := ChangeQuery(cQuerySLY)
oQuery := FwExecStatement():New( cQuerySLY )

oQuery:SetUnsafe( 1, RetSqlName("SLY") )
oQuery:SetString( 2, xFilial("SLY") )
oQuery:SetUnsafe( 3, STR(TAMSX3("TFF_COD")[1]))
oQuery:SetString( 4, cCodOld)
oQuery:SetString( 5, xFilial("TFF") )

cAliasSLY := oQuery:OpenAlias()

While (cAliasSLY)->(!Eof())

	If SLY->(DbSeek((cAliasSLY)->(LY_FILIAL+LY_TIPO+LY_AGRUP+LY_ALIAS+LY_FILENT+LY_CHVENT+LY_CODIGO+LY_DTINI)))

		If Len(aBenefTFF) > 0
			//Procura no array se o SLY já estava adicionado antes da Revisão: CodTFF+RECNO
			nPosSLY := Ascan(aBenefTFF, {|x| x[1] == cCodOld .And. x[2] == (cAliasSLY)->R_E_C_N_O_ })
		EndIf

		If nPosSLY > 0
			// Se benefício já existia no orçamento cria um pra nova revisão e mantém o anterior do orçamento (caso cancelar revisão)
			// Inclusao do Beneficio de acordo com o codigo gerado
			RecLock("SLY", .T.)
				SLY->LY_FILIAL	:= (cAliasSLY)->LY_FILIAL
				SLY->LY_TIPO	:= (cAliasSLY)->LY_TIPO
				SLY->LY_AGRUP	:= (cAliasSLY)->LY_AGRUP
				SLY->LY_ALIAS	:= (cAliasSLY)->LY_ALIAS
				SLY->LY_FILENT	:= (cAliasSLY)->LY_FILENT
				SLY->LY_CHVENT	:= cCodNew + Substr((cAliasSLY)->LY_CHVENT, TAMSX3("TFF_COD")[1]+1, TAMSX3("R6_TURNO")[1])
				SLY->LY_CODIGO	:= (cAliasSLY)->LY_CODIGO
				SLY->LY_PGDUT	:= (cAliasSLY)->LY_PGDUT
				SLY->LY_PGSAB	:= (cAliasSLY)->LY_PGSAB
				SLY->LY_PGDOM	:= (cAliasSLY)->LY_PGDOM
				SLY->LY_PGFER	:= (cAliasSLY)->LY_PGFER
				SLY->LY_PGSUBS	:= (cAliasSLY)->LY_PGSUBS
				SLY->LY_PGFALT	:= (cAliasSLY)->LY_PGFALT
				SLY->LY_PGVAC	:= (cAliasSLY)->LY_PGVAC
				SLY->LY_DIAS	:= (cAliasSLY)->LY_DIAS
				SLY->LY_DTINI	:= STOD((cAliasSLY)->LY_DTINI)
				SLY->LY_DTFIM	:= STOD((cAliasSLY)->LY_DTFIM)
				SLY->LY_PGAFAS	:= (cAliasSLY)->LY_PGAFAS
				SLY->LY_PAGFAL	:= (cAliasSLY)->LY_PAGFAL
			SLY->(MsUnLock())
		Else
			// Se benefício não tinha no orçamento ele é só da revisão.
			// Alteração do código do Beneficio para a nova TFF gerada
			RecLock("SLY", .F.)
				SLY->LY_CHVENT := cCodNew + Substr((cAliasSLY)->LY_CHVENT, TAMSX3("TFF_COD")[1]+1, TAMSX3("R6_TURNO")[1])
			SLY->(MsUnLock())
		EndIf
	EndIf

	nPosSLY := 0

	dbSelectArea(cAliasSLY)
	(cAliasSLY)->(dbSkip())
EndDo

aBenefEx := GetABene()

//Desdeleta os beneficios do orçamento original deletados na revisão:
If Len(aBenefEx) > 0
	For nX := 1 To Len(aBenefEx)
		If cCodOld == aBenefEx[nX,1]
			SLY->(DbGoTo(aBenefEx[nX,2]))
			SLY->(RecLock("SLY",.F.))
				SLY->(DbRecall()) 
			SLY->(MsUnlock())
		EndIf
	Next nX
EndIf

DbSelectArea(cAliasSLY)
(cAliasSLY)->(DbCloseArea())

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ExtIt
Verifica se o item existe no orçamento base
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740ExtIt(cTabela, cCod, cCmpCont, lInserted)
Local lRet := .T.
Local lFind := .T.
Local aArea := &(cTabela)->(GetArea())
Local cTabApont := ""

If !lInserted
	&(cTabela)->(DbSetOrder(1))

	lFind := &(cTabela)->(DbSeek( xFilial(cTabela) + cCod )) .And. !Empty(  &(cTabela)->(FieldGet(FieldPos(cCmpCont))))

	If lFind .And. cTabela $ 'TFH|TFG'

		If cTabela == "TFH"
			cTabApont := "TFT"
		Else
			cTabApont := "TFS"
		EndIf

		//-- Verifica se existe apontamento de material
		lRet := Len(TecGetApnt(cCod,cTabApont)) > 0
	Else
		lRet := lFind
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ExTEV
Verifica se o item (TEV) existe no orçamento base
@since		15/03/2019
@author	Matheus Lando Raimundo
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function At740ExTEV(cCodTFI,cItem,lInserted)
Local lRet := .F.
Local cAliasTemp := GetNextAlias()
Local lRevis := isInCallStatck("At870Revis") .And. TFJ->TFJ_STATUS == '1'

If !lInserted
	//-- Primeira revisão
	If lRevis
		lRet := .T.
	Else
		BeginSql Alias cAliasTemp
			SELECT TEV_ITEM
			FROM %Table:TEV% TEV
				INNER JOIN %Table:TFI% TFI ON TFI_FILIAL = %xFilial:TFI%
										AND TFI.TFI_COD = TEV.TEV_CODLOC
										AND TFI_CODSUB = %Exp:cCodTFI%
										AND TFI.%NotDel%
			WHERE
				TEV.TEV_FILIAL = %xFilial:TEV%
				AND TEV.%NotDel%
				AND TEV.TEV_ITEM = %Exp:cItem%
		EndSql

		lRet := (cAliasTemp)->(!Eof())
		(cAliasTemp)->(DbCloseArea())
	EndIf
EndIf


Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740getQt
Retorna o valor do campo QTDVEN salvo no banco de dados
@since		27/03/2019
@author		Mateus Boiani
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function At740getQt(cCod,cTable)
Local aArea := GetArea()
Local nRet := 0
(cTable)->(DbSetOrder(1))

If (cTable)->(MsSeek(xFilial(cTable) + cCod))
	nRet := cTable + "->" + cTable +"_QTDVEN"
	nRet := &(nRet)
EndIf

RestArea(aArea)
Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740PosRg
Posicionamento nos resgistros do orçamento de serviços.

@since	26/06/2019
@author	Kaique Schiller
/*/
//------------------------------------------------------------------------------
Function At740PosRg(oVw)
Local aModelsId := {}
Local aEscolha	:= {}
Local nEscAba   := 0
Local nI		:= 0
Local lConExt 	:= IsInCallStack("At870GerOrc")
Local lTecItExtOp:= IsInCallStack("At190dGrOrc")

//View, SubModel, Descrição, Descrição da Aba
If !lConExt

	aModelsId := { {"VIEW_LOC"	,"TFL_LOC"	, STR0213, STR0022 },; //"Locais de Atendimento"
	 			   {"VIEW_RH"	,"TFF_RH"	, STR0214, STR0006 },; //"Recursos Humanos"
	 			   {"VIEW_LE"	,"TFI_LE"	, STR0215, STR0009 },; //"Locação de Equipamentos"
	 			   {"VIEW_MI"	,"TFG_MI"	, STR0216, STR0007 },; //"Materiais de Implantação"
	 			   {"VIEW_MC"	,"TFH_MC"	, STR0217, STR0008 },; //"Material de Consumo"
	 			   {"VIEW_BENEF","ABP_BENEF", STR0218, STR0023 },; //"Verbas Adicionais"
	 			   {"VIEW_HE"	,"TFU_HE"	, STR0219, STR0031 }}  //"Hora Extra"
Else
	If lTecItExtOp
		aModelsId := {  {"VIEW_LOC"	,"TFL_LOC"	, STR0213, STR0022 },; //"Locais de Atendimento"
						{"VIEW_RH"	,"TFF_RH"	, STR0214, STR0006 }} //"Recursos Humanos"
	Else
		aModelsId := {  {"VIEW_LOC"	,"TFL_LOC"	, STR0213, STR0022 },; //"Locais de Atendimento"
						{"VIEW_RH"	,"TFF_RH"	, STR0214, STR0006 },; //"Recursos Humanos"
						{"VIEW_MI"	,"TFG_MI"	, STR0216, STR0007 },; //"Materiais de Implantação"
						{"VIEW_MC"	,"TFH_MC"	, STR0217, STR0008 }}  //"Material de Consumo"

	Endif
Endif

For nI := 1 To Len(aModelsId)
	Aadd(aEscolha , aModelsId[nI,3] )
Next nI

//Escolhe qual aba deseja posicionar
nEscAba := GSEscolha( 	STR0220,;  // "Posicione"
						STR0221,;  // "Selecione em qual grid deseja posicionar."
						aEscolha,;
						1)

//Se confirmou alguma aba
If nEscAba >  0
	MsgRun( STR0222, STR0082, { || At740Posic(nEscAba,oVw,aModelsId,aEscolha)} ) //"Montando a pesquisa do posicione."#"Aguade..."
Endif

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Posic
Monta a tela de posicionamento via parambox.

@since	26/06/2019
@author	Kaique Schiller
/*/
//------------------------------------------------------------------------------
Static Function At740Posic(nEscAba,oVw,aModelsId,aEscolha)
Local oMdl	  		:= Nil
Local oMdlDtl 		:= Nil
Local oStruct		:= Nil
Local aPrBox  		:= {}
Local aRet	  		:= {}
Local aSeekLine 	:= {}
Local aCmpsSeek		:= {}
Local aRows    		:= {}
Local aStrVw		:= {}
Local aStrMdl 		:= {}
Local cPicture		:= ""
Local cIniPad 		:= ""
Local xConteud		:= ""
Local cConsult		:= ""
Local nTamCmp 		:= 0
Local nPos			:= 0
Local nX	  		:= 0

If oVw <> Nil

	//Struct da view selecionada
	oStruVw := oVw:GetViewStruct(aModelsId[nEscAba,1])

	//Modelo da view
	oMdl := oVw:GetModel()

	//Struct da model selecionada
	oMdlDtl := oMdl:GetModel(aModelsId[nEscAba,2])

	If oMdlDtl <> Nil

		//Struct do modelo
		oStruMdl := oMdlDtl:GetStruct()

		//Campos do modelo e da view
		aStrMdl  := oStruMdl:GetFields()
		aStrVw	 := oStruVw:GetFields()

		//Percorre a estrutura para pegar os campos a serem exibidos no parambox
		For nX := 1 To Len(aStrVw)

			//Realiza o tratamento de alguns campos, e seleciona apenas os campos que aparecem na view.
			If !(aStrVw[nX,1] $ "TFL_LEGEN|TFF_LEGEN|TFI_LEGEN")

				nPos     := 0
				cIniPad  := ""
				cPicture := aStrVw[nX,7]
				cConsult := aStrVw[nX,9]

				nPos := Ascan(aStrMdl, {|x| x[3] == aStrVw[nX,1] })

				If nPos > 0 .And. !(aStrMdl[nPos,4] $ "M|L")
					If aStrMdl[nPos,4] == "D"
						cIniPad := cTod("")
					Else
						cIniPad := Space(aStrMdl[nPos,5])
					Endif

					If aStrMdl[nPos,4] $ "N|D|C"
						nTamCmp := 70
					Else
						nTamCmp := aStrMdl[nPos,5]
					Endif

					//Monta os campos do parambox
					aAdd(aPrBox, { 1,aStrMdl[nPos,1],cIniPad,cPicture,,cConsult,,nTamCmp,.F.})

					//Armazena os campos do parambox para realizar o seekline
					aAdd(aCmpsSeek, { aStrMdl[nPos,3], aStrMdl[nPos,4] } )
				Endif
			Endif
		Next nX
	Endif

	//Se confirmar executa o seekline no modelo corrente.
	If !Empty(aPrBox) .And. ParamBox(aPrBox,STR0212+" - "+aModelsId[nEscAba,3],@aRet,,,,,,,,.F.) //Posicione

		For nX := 1 To Len(aRet)

			If !Empty(aRet[nX])

				If aCmpsSeek[nX,2] == "N"
					xConteud := Val(aRet[nX])
				Else
					xConteud := aRet[nX]
				Endif

				Aadd(aSeekLine, {aCmpsSeek[nX,1],xConteud} )

			Endif

		Next nX

		If !Empty(aSeekLine)

			If nEscAba == 1 .Or. nEscAba == 2 .Or. nEscAba == 3
				oVw:SelectFolder("ABAS", aModelsId[nEscAba,4],2) // "Aba superior"
			Endif

			If nEscAba == 4 .Or. nEscAba == 5 .Or. nEscAba == 6 .Or. nEscAba ==  7

				//Se aba de recursos humanos não estiver posicionado, realiza o posicionamento.
				If oVw:GetFolderActive("ABAS", 2)[2] <> STR0006
					oVw:SelectFolder("ABAS", STR0006, 2) // "Aba de Recursos Humanos"
				Endif

				oVw:SelectFolder("RH_ABAS", aModelsId[nEscAba,4],2) // "Aba inferior"

			Endif

			If !oMdlDtl:SeekLine( aSeekLine )
				If !IsBlind()
					MsgAlert(STR0210) //"Não foi possível posicionar na linha, verifique as informações inseridas."
				Endif
			Endif
		Else
			If !IsBlind()
				MsgAlert(STR0211) //"Não foi possível posicionar na linha, preencha os campos do posicionamento."
			Endif
		Endif
	Endif
Endif

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlExl
Valida a exclusão do local de atendimento na revisão de contratos.

@since	23/07/2019
@author	Serviços
/*/
//------------------------------------------------------------------------------
Static Function At740VlExl(oMdl)
Local aArea			:= GetArea()
Local oMdlTFL		:= oMdl:GetModel("TFL_LOC")
Local oMdlTFF		:= oMdl:GetModel("TFF_RH")
Local oMdlTFI		:= oMdl:GetModel("TFI_LE")
Local oMdlTFG		:= oMdl:GetModel("TFG_MI")
Local oMdlTFH		:= oMdl:GetModel("TFH_MC")
Local oMdlTXQ		:= Nil
Local aSaveLines	:= FWSaveRows()
Local lRet			:= .T.
Local lOkTFF		:= .T.
Local lOkTFS		:= .T.
Local lOkTEW		:= .T.
Local lOkCNA		:= .T.
Local lOkTXQ		:= .T.
Local aCmpTFS		:= {}
Local aCmpTXQ		:= {}
Local cMens			:= ""
Local cMens02		:= ""
Local cMens03		:= ""
Local cTmpCNA		:= ""
Local cTmpTFF		:= ""
Local cTmpTFS		:= ""
Local cTmpTEW		:= ""
Local cTmpTXQ		:= ""
Local cTmpCNB		:= ""
Local cTmpTFH		:= ""
Local cTmpTFG		:= ""
Local cProduto		:= ""
Local cTpMov		:= ""
Local cPicTFSQtde	:= PesqPict("TFS","TFS_QUANT")
Local nInd			:= 0
Local nQuant		:= 0
Local nSld			:= 0
Local nLinTFF		:= 0
Local nLinTFI		:= 0
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()

If !oMdlTFL:IsEmpty()

	cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
	cMens	+=	STR0224 	+ AllTrim(oMdlTFL:GetValue("TFL_CODIGO")) 	+ " "+; // "Código: "
				STR0225		+ AllTrim(oMdlTFL:GetValue("TFL_LOCAL")) 	+ "-"+; // "Local: "
							  AllTrim(oMdlTFL:GetValue("TFL_DESLOC"))


	//Verificar se o algum item do local já foi faturado.
		If !Empty(oMdlTFL:GetValue("TFL_PLAN"))

			cTmpCNA	:= GetNextAlias()

			BeginSql Alias cTmpCNA
				SELECT CNA.CNA_VLTOT, CNA.CNA_SALDO
				FROM %table:CNA% CNA
				WHERE CNA.CNA_FILIAL = %xFilial:CNA%
					AND CNA.CNA_CONTRA = %exp:oMdlTFL:GetValue("TFL_CONTRT")%
					AND CNA.CNA_REVISA = %exp:oMdlTFL:GetValue("TFL_CONREV")%
					AND CNA.CNA_NUMERO = %exp:oMdlTFL:GetValue("TFL_PLAN")%
					AND CNA.%NotDel%
			EndSql

			DbSelectArea(cTmpCNA)
			(cTmpCNA)->(DbGoTop())

			If	((cTmpCNA)->(!EOF()) .And. (cTmpCNA)->CNA_VLTOT <> (cTmpCNA)->CNA_SALDO)
				lOkCNA	:= .F.
				cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
				cMens	+= STR0226  //"Não é possível continuar com a exclusão desse Local de Atendimento, a medição dos itens do Local de Atendimento já foram realizadas."
			EndIf
			(cTmpCNA)->(DbCloseArea())
		EndIf
	If	!(oMdlTFF:IsEmpty())

		//Verificar os itens do RH
		For nLinTFF := 1 to oMdlTFF:Length()
			oMdlTFF:GoLine(nLinTFF)

			//Verificar se existe agenda gerada
			cTmpTFF	:= GetNextAlias()

			BeginSql Alias cTmpTFF
			   SELECT DISTINCT TFF.TFF_CONTRT, ABQ.ABQ_ITEM, TFF.TFF_COD, TFF.TFF_ITEM,
			                   TFF.TFF_PRODUT, (TFF.TFF_CONTRT || ABQ.ABQ_ITEM || 'CN9') AS TFF_IDCFAL,
			                   ABB.ABB_CODTEC, AA1.AA1_NOMTEC, SRJ.RJ_DESC
			     FROM %table:TFF% TFF
			          INNER JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
			                                    AND ABQ.%NotDel%
			                                    AND ABQ.ABQ_FILTFF = TFF.TFF_FILIAL
			                                    AND ABQ.ABQ_CODTFF = TFF.TFF_COD
			          INNER JOIN %table:ABB% ABB ON ABB.ABB_FILIAL = %xFilial:ABB%
			                                    AND ABB.%NotDel%
			                                    AND ABB.ABB_IDCFAL = (TFF.TFF_CONTRT || ABQ.ABQ_ITEM || 'CN9')
			          INNER JOIN %table:AA1% AA1 ON AA1.AA1_FILIAL = %xFilial:AA1%
			                                    AND AA1.%NotDel%
			                                    AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
			          INNER JOIN %table:SRJ% SRJ ON SRJ.RJ_FILIAL = %xFilial:SRJ%
			                                    AND SRJ.%NotDel%
			                                    AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO
			    WHERE TFF.TFF_FILIAL = %xFilial:TFF%
			      AND TFF.%NotDel%
			      AND TFF.TFF_COD 	 = %exp:oMdlTFF:GetValue("TFF_COD")%
			      AND 'S' IN (SELECT DISTINCT 'S' AGENDAATIVA
			                    FROM %table:ABB% ABB
			                   WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			                     AND ABB.%NotDel%
			                     AND ABB.ABB_ATIVO = '1'
			                     AND ABB.ABB_IDCFAL = (TFF.TFF_CONTRT || ABQ.ABQ_ITEM || 'CN9'))
			    ORDER BY TFF.TFF_CONTRT, ABQ.ABQ_ITEM, TFF.TFF_COD, TFF.TFF_ITEM, TFF.TFF_PRODUT
			EndSql

			DbSelectArea(cTmpTFF)
			(cTmpTFF)->(DbGoTop())

			If	(cTmpTFF)->(!EOF())
				lOkTFF	:= .F.
				cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
				cMens	+= STR0227 + CRLF	//"Os atendentes abaixo possuem agenda ativa:"
			EndIf

			While (cTmpTFF)->(!EOF())

				cMens	+= If( !Empty(cMens), CRLF, "" )

				cMens	+=	STR0228  + " [" + AllTrim((cTmpTFF)->TFF_ITEM) 	 + "] " +;	//"RH-Item:"
							STR0229	 + " [" + AllTrim((cTmpTFF)->TFF_PRODUT) + "] " +;	//"Cod. Prod:"
							STR0230	 + " [" + AllTrim((cTmpTFF)->ABB_CODTEC) + "-"  +;  //"Atendente:"
											  AllTrim((cTmpTFF)->AA1_NOMTEC) + "] " +;
							STR0231	 + " [" + AllTrim((cTmpTFF)->RJ_DESC) 	 + "] " 	//"Função:"

				(cTmpTFF)->(dBSkip())

			Enddo

			(cTmpTFF)->(DbCloseArea())

			If !lOrcPrc .And. !(oMdlTFG:IsEmpty())
				//Verificar os materiais de implantação não retornados
				cTmpTFS	:=	GetNextAlias()
				BeginSql Alias cTmpTFS
				   SELECT TFF.TFF_ITEM, TFF.TFF_COD, TFS.TFS_PRODUT, SB1.B1_DESC, SUM(TFS.TFS_QUANT) AS QtTotal, TFS.TFS_MOV, TFG.TFG_RESRET
				     FROM %table:TFS% TFS
				          INNER JOIN %table:TFG% TFG on TFG.TFG_FILIAL = %xFilial:TFG%
				                                    AND TFG.%NotDel%
				                                    AND TFG.TFG_COD = TFS.TFS_CODTFG
				          INNER JOIN %table:TFF% TFF on TFF.TFF_FILIAL = %xFilial:TFF%
				                                    AND TFF.%NotDel%
				                                    AND TFF.TFF_COD = TFG.TFG_CODPAI
				          INNER JOIN %table:SB1% SB1 on SB1.B1_FILIAL = %xFilial:SB1%
				                                    AND SB1.%NotDel%
				                                    AND SB1.B1_COD = TFS.TFS_PRODUT
				    WHERE TFF.TFF_FILIAL = %xFilial:TFF%
				      AND TFF.%NotDel%
				      AND TFF.TFF_COD 	 = %exp:oMdlTFF:GetValue("TFF_COD")%
				    GROUP BY TFF_COD, TFF_ITEM, TFS_PRODUT, SB1.B1_DESC, TFS_QUANT, TFS_MOV, TFG_RESRET
				    ORDER BY TFF_COD, TFF_ITEM, TFS_PRODUT, TFS_MOV
				EndSql

				aCmpTFS	:=	{}
				cMens02	:= ""
				nSld	:= 0

				DbSelectArea(cTmpTFS)
				(cTmpTFS)->(DbGoTop())

				While (cTmpTFS)->(!EOF())
					aAdd(aCmpTFS,{(cTmpTFS)->TFS_PRODUT,;
									(cTmpTFS)->QtTotal,;
									(cTmpTFS)->TFS_MOV,;
									(cTmpTFS)->TFG_RESRET,;
									(cTmpTFS)->TFF_ITEM,;
									(cTmpTFS)->B1_DESC})
					(cTmpTFS)->(dBSkip())
				Enddo

				(cTmpTFS)->(DbCloseArea())

				//Verificar se existe quantidade (saldo) a retornar
				For nInd := 1 to len(aCmpTFS)

					If cProduto == aCmpTFS[nInd][1] .OR. nInd == 1
						nRes	:= aCmpTFS[nInd][4]
						nQuant	:= aCmpTFS[nInd][2]
						cTpMov	:= aCmpTFS[nInd][3]

						If cTpMov == "1"
							nSld	+= nQuant
						Elseif cTpMov == "2"
							nSld	-= nQuant
						Endif

						//Se for o último registro
						If nInd == len(acmpTFS)
							If nSld - nRes > 0
								cMens02	+= If( !Empty(cMens02), CRLF, "" )
								//Se existir saldo a retornar, avisar o usuário...
								cMens02	+=	STR0232		+ " [" + AllTrim(aCmpTFS[nInd][5]) + "] " +;		//"MI-Item:"
											STR0229 	+ " [" + AllTrim(aCmpTFS[nInd][1]) + "-"  +; 		//"Cod. Prod:"
																 AllTrim(aCmpTFS[nInd][6]) + "] " +;
											STR0233		+ " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"	//"Quantidade:"
								lOkTFS	:= .F.
							Endif
						Endif

					Elseif cProduto <> aCmpTFS[nInd][1]
						If nSld - nRes > 0
							cMens02	+= If( !Empty(cMens02), CRLF, "" )
							//Se existir saldo a retornar, avisar o usuário...
							cMens02	+=	STR0232		+ " [" + AllTrim(aCmpTFS[nInd][5]) + "] " +;		//"MI-Item:"
										STR0229		+ " [" + AllTrim(aCmpTFS[nInd][1]) + "-"  +;		//"Cod. Prod:"
										 					 AllTrim(aCmpTFS[nInd][6]) + "] " +;
										STR0233 	+ " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"	//"Quantidade:"

							lOkTFS	:= .F.
							//zera as quantidades
							nSld	:= 0
							nRes	:= 0
							nQuant	:= 0
						Endif
					Endif
					cProduto	:= aCmpTFS[nInd][1]
				Next nInd

				If	!Empty(cMens02)
					cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
					cMens	+= STR0234 + CRLF + CRLF	//"Os materiais de implantação abaixo estão pendentes de retorno:"
					cMens	+= cMens02 + CRLF
				EndIf
			Endif

			If !lOrcPrc
				//Verificar os Armamentos (armas e coletes) não retornados
				If lGsOrcArma
					oMdlTXQ	:= oMdl:GetModel("TXQDETAIL")
					If !(oMdlTXQ:IsEmpty())
						cTmpTXQ	:=	GetNextAlias()
						BeginSql Alias cTmpTXQ
						SELECT TXQ.TXQ_CODIGO, TXQ.TXQ_CODPRD, TXQ.TXQ_QTDAPO
							FROM %table:TXQ% TXQ
							WHERE TXQ.TXQ_FILIAL = %xFilial:TXQ%
							AND TXQ.%NotDel%
							AND TXQ.TXQ_CODTFF = %exp:oMdlTFF:GetValue("TFF_COD")%
							AND TXQ.TXQ_QTDAPO > 0
							AND TXQ.TXQ_ITEARM <> '3'
						EndSql

						DbSelectArea(cTmpTXQ)
						(cTmpTXQ)->(DbGoTop())

						While (cTmpTXQ)->(!EOF())
							aAdd(aCmpTXQ,{(cTmpTXQ)->TXQ_CODIGO,;
											(cTmpTXQ)->TXQ_CODPRD,;
											(cTmpTXQ)->TXQ_QTDAPO})
							(cTmpTXQ)->(dBSkip())
						Enddo

						(cTmpTXQ)->(DbCloseArea())

						If Len(aCmpTXQ) > 0
							cMens03 := ""
							For nInd := 1 To Len(aCmpTXQ)
								If !Empty(cMens03)
									cMens03 += CRLF
								EndIf
								//Se existir saldo a retornar, avisar o usuário...
								cMens03	+=	STR0331	+ " [" + AllTrim(aCmpTXQ[nInd][2]) + "] " +;		//"Armamento"
											STR0229 + " [" + AllTrim(aCmpTXQ[nInd][1]) + "] "  +;		//"Cod. Prod:"
											STR0233	+ " [" + AllTrim(cValToChar(aCmpTXQ[nInd][3])) + "]"//"Quantidade:"
								lOkTXQ	:= .F.
							Next nInd
						EndIf
						If !Empty(cMens03)
							If !Empty(cMens)
								cMens += CRLF + CRLF
							EndIf
							cMens	+= STR0346 + CRLF + CRLF	//"Os Armamentos abaixo estão pendentes de retorno:"
							cMens	+= cMens03 + CRLF
						EndIf
					EndIf
				EndIf
			EndIf
		Next nLinTFF
	EndIf

	If lOrcPrc .And. !(oMdlTFG:IsEmpty())

		//Verificar os materiais de implantação não retornados
		cTmpTFS	:=	GetNextAlias()
		BeginSql Alias cTmpTFS
		   SELECT TFL.TFL_CODIGO, TFL.TFL_LOCAL, TFS.TFS_PRODUT, SB1.B1_DESC, SUM(TFS.TFS_QUANT) AS QtTotal, TFS.TFS_MOV, TFG.TFG_RESRET
		     FROM %table:TFS% TFS
		          INNER JOIN %table:TFG% TFG on TFG.TFG_FILIAL = %xFilial:TFG%
		                                    AND TFG.%NotDel%
		                                    AND TFG.TFG_COD = TFS.TFS_CODTFG
		          INNER JOIN %table:TFL% TFL on TFL.TFL_FILIAL = %xFilial:TFL%
		                                    AND TFL.%NotDel%
		                                    AND TFL.TFL_CODIGO = TFG.TFG_CODPAI
		                                    AND TFL.TFL_LOCAL  = TFG.TFG_LOCAL
		          INNER JOIN %table:SB1% SB1 on SB1.B1_FILIAL = %xFilial:SB1%
		                                    AND SB1.%NotDel%
		                                    AND SB1.B1_COD = TFS.TFS_PRODUT
		    WHERE TFG.TFG_FILIAL = %xFilial:TFG%
		      AND TFG.%NotDel%
		      AND TFG.TFG_CODPAI 	 = %exp:oMdlTFL:GetValue("TFL_CODIGO")%
		      AND TFG.TFG_LOCAL		 = %exp:oMdlTFL:GetValue("TFL_LOCAL")%
			    GROUP BY TFL_CODIGO, TFL_LOCAL , TFS_PRODUT, SB1.B1_DESC, TFS_QUANT, TFS_MOV, TFG_RESRET
			    ORDER BY TFL_CODIGO, TFL_LOCAL , TFS_PRODUT, TFS_MOV
			EndSql

			aCmpTFS	:=	{}
			cMens02	:= ""
		nSld	:= 0

		DbSelectArea(cTmpTFS)
		(cTmpTFS)->(DbGoTop())

		While (cTmpTFS)->(!EOF())
			aAdd(aCmpTFS,{(cTmpTFS)->TFS_PRODUT,;
							(cTmpTFS)->QtTotal,;
							(cTmpTFS)->TFS_MOV,;
							(cTmpTFS)->TFG_RESRET,;
							(cTmpTFS)->TFL_LOCAL,;
							(cTmpTFS)->B1_DESC})
			(cTmpTFS)->(dBSkip())
		Enddo

		(cTmpTFS)->(DbCloseArea())

		//Verificar se existe quantidade (saldo) a retornar
		For nInd := 1 to len(aCmpTFS)

			If cProduto == aCmpTFS[nInd][1] .OR. nInd == 1
				nRes	:= aCmpTFS[nInd][4]
				nQuant	:= aCmpTFS[nInd][2]
				cTpMov	:= aCmpTFS[nInd][3]

				If cTpMov == "1"
					nSld	+= nQuant
				Elseif cTpMov == "2"
					nSld	-= nQuant
				Endif

				//Se for o último registro
				If nInd == len(acmpTFS)
					If nSld - nRes > 0
						cMens02	+= If( !Empty(cMens02), CRLF, "" )
						//Se existir saldo a retornar, avisar o usuário...
						cMens02	+=	STR0229		+ " [" + AllTrim(aCmpTFS[nInd][1]) + "-"  +; 		//"Cod. Prod:"
														 AllTrim(aCmpTFS[nInd][6]) + "] " +;
									STR0233 	+ " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"	//"Quantidade:"
						lOkTFS	:= .F.
					Endif
				Endif

			Elseif cProduto <> aCmpTFS[nInd][1]
				If nSld - nRes > 0
					cMens02	+= If( !Empty(cMens02), CRLF, "" )
					//Se existir saldo a retornar, avisar o usuário...
					cMens02	+=	STR0229 	+ " [" + AllTrim(aCmpTFS[nInd][1]) + "-"  +;		//"Cod. Prod:"
								 					 AllTrim(aCmpTFS[nInd][6]) + "] " +;
								STR0233		+ " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"	//"Quantidade:"

					lOkTFS	:= .F.
					//zera as quantidades
					nSld	:= 0
					nRes	:= 0
					nQuant	:= 0
				Endif
			Endif
			cProduto	:= aCmpTFS[nInd][1]
		Next nInd

		If	!Empty(cMens02)
			cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
			cMens	+= STR0234 + CRLF + CRLF	//"Os materiais de implantação abaixo estão pendentes de retorno:"
			cMens	+= cMens02 + CRLF
		EndIf

	Endif

	If	!(oMdlTFI:IsEmpty())

		//Verificar os itens de locação
		For nLinTFI := 1 to oMdlTFI:Length()
			oMdlTFI:GoLine(nLinTFI)
			//Verificar equipamentos não retornados
			cTmpTEW	:= GetNextAlias()
			BeginSql Alias cTmpTEW
				SELECT TEW.TEW_CODEQU, TEW.TEW_PRODUT, TEW.TEW_BAATD, SB1.B1_DESC, TEW.TEW_DTRFIM, TFI.TFI_COD, TFI.TFI_ITEM
				  FROM %table:TEW% TEW
				       INNER JOIN %table:TFI% TFI on TFI.TFI_FILIAL = %xFilial:TFI%
				                                 AND TFI.%NotDel%
				                                 AND TFI.TFI_COD = TEW.TEW_CODEQU
				       INNER JOIN %table:SB1% SB1 on SB1.B1_FILIAL = %xFilial:SB1%
				                                 AND SB1.%NotDel%
				                                 AND SB1.B1_COD = TEW.TEW_PRODUT
				 WHERE TEW.TEW_FILIAL = %xFilial:TEW%
				   AND TEW.%NotDel%
				   AND TEW.TEW_CODEQU = %exp:oMdlTFI:GetValue("TFI_COD")%
				   AND TEW.TEW_DTSEPA <> ''
			EndSql

			DbSelectArea(cTmpTEW)
			(cTmpTEW)->( DbGoTop() )

			If	(cTmpTEW)->(!EOF())
				lOkTEW	:= .F.
				cMens	+= If( !Empty(cMens), CRLF + CRLF, "" )
				cMens	+= CRLF + STR0235 + CRLF	//"Os equipamentos abaixo estão pendentes de retorno ou encontram-se separados:"
			EndIf

			While (cTmpTEW)->(!EOF())
				cMens	+= If( !Empty(cMens), CRLF, "" )

				cMens	+=	STR0236		+ " [" + AllTrim((cTmpTEW)->TFI_ITEM) 	+ "] " +;	//"LE-Item:"
							STR0237		+ " [" + AllTrim((cTmpTEW)->TFI_COD) 	+ "] " +;	//"Cód. Locação:"
							STR0229	 	+ " [" + AllTrim((cTmpTEW)->TEW_PRODUT) + "-"  +;
							 					 AllTrim((cTmpTEW)->B1_DESC) 	+ "] " +;	//"Cod. Prod:"
							STR0238 	+ " [" + AllTrim((cTmpTEW)->TEW_BAATD) 	+ "] "		//"Núm. Série:"

				(cTmpTEW)->(dBSkip())
			Enddo
			(cTmpTEW)->(DbCloseArea())
		Next nLinTFI
	EndIf
Endif

lRet := ( lOkCNA .And. lOkTFF .And. lOkTFS .And. lOkTEW .And. lOkTXQ )

If !lRet
	AtShowLog(cMens,STR0239, .T., .T., .F.)  // "Inconsistências."
	Help( , , "At740VlExl", , STR0240, 1, 0,,,,,, {STR0241}) //"Não será possivel realizar a exclusão do Local de Atendimento, pois existem inconsistências que impedem tal procedimento."##"Realize as manutenções necessárias para que sejam atendidas as premissas para a exclusão do Local de Atendimento."
Endif

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ExTFF

@description Valida se é possivel excluir o item de RH.
@author	Augusto Albuquerque
@since	28/10/2019
/*/
//------------------------------------------------------------------------------
Function At740ExTFF(oMdl)
Local cTmpCNB		:= GetNextAlias()
Local cTmpTFH		:= GetNextAlias()
Local cTmpTFG		:= GetNextAlias()
Local cTmpTFF		:= GetNextAlias()
Local cTmpTFS		:= GetNextAlias()
Local cTmpTXQ		:= ""
Local cGsDsGcn		:= SuperGetMv("MV_GSDSGCN",,"2")
Local cMsg			:= ""
Local lOrcPrc 		:= SuperGetMv("MV_ORCPRC",,.F.)
Local lRet			:= .T.
Local lMed			:= .T.
Local nX
Local nLinPosi		:= 1
Local oMdlTFL		:= oMdl:GetModel("TFL_LOC")
Local oMdlTFF		:= oMdl:GetModel("TFF_RH")
Local oMdlTFG		:= oMdl:GetModel("TFG_MI")
Local oMdlTFH		:= oMdl:GetModel("TFH_MC")
Local oMdlTXQ		:= Nil
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()

If cGsDsGcn == "1"
	BeginSql Alias cTmpCNB
		SELECT CNB.CNB_QTDMED, CNB.CNB_VLUNIT
		FROM %table:CNB% CNB
		WHERE CNB.CNB_FILIAL = %xFilial:CNB%
			AND CNB.CNB_CONTRA = %exp:oMdlTFF:GetValue("TFF_CONTRT")%
			AND CNB.CNB_REVISA = %exp:oMdlTFF:GetValue("TFF_CONREV")%
			AND CNB.CNB_NUMERO = %exp:oMdlTFL:GetValue("TFL_PLAN")%
			AND CNB.CNB_PRODUT = %exp:oMdlTFF:GetValue("TFF_PRODUT")%
			AND CNB.CNB_ITEM = %exp:oMdlTFF:GetValue("TFF_ITCNB")%
			AND CNB.%NotDel%
	EndSql
	If	lOrcPrc
		If (cTmpCNB)->CNB_QTDMED > 0
			If (cTmpCNB)->CNB_QTDMED * (cTmpCNB)->CNB_VLUNIT >= oMdlTFF:GetValue("TFF_PRCVEN")
				lRet := .F.
				cMsg	+= STR0245 + CRLF // "Não é possivel excluir o item, pois o item ja foi medido."
				cMsg	+= STR0246 + CValToChar((cTmpCNB)->CNB_QTDMED * (cTmpCNB)->CNB_VLUNIT) + CRLF + CRLF // "Se desejar, reduza o item para valor superior a medição de: "
			EndIf
		EndIf
	Else
		If (cTmpCNB)->CNB_QTDMED > 0
			lRet := .F.
			cMsg	+= STR0245 + CRLF // "Não é possivel excluir o item, pois o item ja foi medido."
			cMsg	+= STR0246 + CValToChar((cTmpCNB)->CNB_QTDMED * (cTmpCNB)->CNB_VLUNIT) + CRLF + CRLF // "Se desejar, reduza o item para valor superior a medição de: "
		Else
			BeginSql Alias cTmpTFH
				SELECT CNB.CNB_QTDMED
				FROM %table:CNB% CNB
				INNER JOIN %table:TFH% TFH
					ON TFH.TFH_FILIAL = %xFilial:TFH%
					AND TFH.TFH_CODPAI = %exp:oMdlTFF:GetValue("TFF_COD")%
				WHERE CNB.CNB_FILIAL = %xFilial:CNB%
					AND CNB.CNB_CONTRA = TFH.TFH_CONTRT
					AND CNB.CNB_REVISA = TFH.TFH_CONREV
					AND CNB.CNB_NUMERO = %exp:oMdlTFL:GetValue("TFL_PLAN")%
					AND CNB.CNB_PRODUT = TFH.TFH_PRODUT
					AND CNB.CNB_ITEM =	TFH.TFH_ITCNB
					AND CNB.%NotDel%
			EndSql
			While (cTmpTFH)->(!Eof())
				If (cTmpTFH)->CNB_QTDMED > 0
					lMed := .F.
				EndIf
				(cTmpTFH)->(DbSkip())
			EndDo
			(cTmpTFH)->(DbCloseArea())
			If lMed
				BeginSql Alias cTmpTFG
					SELECT CNB.CNB_QTDMED
					FROM %table:CNB% CNB
					INNER JOIN %table:TFG% TFG
						ON TFG.TFG_FILIAL = %xFilial:TFG%
						AND TFG.TFG_CODPAI = %exp:oMdlTFF:GetValue("TFF_COD")%
					WHERE CNB.CNB_FILIAL = %xFilial:CNB%
						AND CNB.CNB_CONTRA = TFG.TFG_CONTRT
						AND CNB.CNB_REVISA = TFG.TFG_CONREV
						AND CNB.CNB_NUMERO = %exp:oMdlTFL:GetValue("TFL_PLAN")%
						AND CNB.CNB_PRODUT = TFG.TFG_PRODUT
						AND CNB.CNB_ITEM =	TFG.TFG_ITCNB
						AND CNB.%NotDel%
				EndSql
				While (cTmpTFG)->(!Eof())
					If (cTmpTFG)->CNB_QTDMED > 0
						lMed := .F.
					EndIf
					(cTmpTFG)->(DbSkip())
				EndDo
				(cTmpTFG)->(DbCloseArea())
			EndIf
			If !lMed
				lRet := .F.
				cMsg	+= STR0247 + CRLF + CRLF // "Item de MI/MC com medição, não é possivel excluir o item de RH."
			EndIf
		EndIf
		(cTmpCNB)->(DbCloseArea())
	EndIf
EndIf

//Verifica se existe agenda
If lRet
	BeginSql Alias cTmpTFF
		SELECT 1
		FROM %table:ABB% ABB
		INNER JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
			AND ABQ.ABQ_CODTFF = %exp:oMdlTFF:GetValue("TFF_COD")%
			AND ABQ.%NotDel%
		WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
			AND ABB.%NotDel%
	EndSql

	If	(cTmpTFF)->(!EOF())
		lRet	:= .F.
		cMsg	+= STR0251 + CRLF	// "O item possui alocação. Para maiores informações acesse o gestão de escala ou a mesa operacional."
	EndIf

	(cTmpTFF)->(DbCloseArea())

	If !lOrcPrc .AND. !(oMdlTFG:IsEmpty())
		nLinPosi	:= oMdlTFG:GetLine()
		For nX := 1 To oMdlTFG:Length()
			oMdlTFG:GoLine(nX)
			BeginSql Alias cTmpTFS
				SELECT 1
				FROM %table:TFS% TFS
				WHERE
					TFS.TFS_FILIAL = %xFilial:TFS%
					AND TFS.TFS_CODTFG = %exp:oMdlTFG:GetValue("TFG_COD")%
					AND TFS.%NotDel%
			EndSql
			If (cTmpTFS)->(!EOF())
				lRet	:= .F.
				cMsg	+= STR0248 + CRLF // "O item seguinte possui apontamento. "
				cMsg	+= STR0249 + oMdlTFG:GetValue("TFG_PRODUT") + CRLF // "Produto: "
				cMsg	+= STR0250 + oMdlTFG:GetValue("TFG_COD") + CRLF + CRLF // "Codigo: "
			EndIf
			(cTmpTFS)->(DbCloseArea())
		Next nX
		oMdlTFG:GoLine(nLinPosi)
	EndIf

	If	!lOrcPrc .AND. !(oMdlTFH:IsEmpty())
		nLinPosi	:= oMdlTFH:GetLine()
		For nX := 1 To oMdlTFH:Length()
			oMdlTFH:GoLine(nX)
			BeginSql Alias cTmpTFH
				SELECT 1
				FROM %table:TFT% TFT
				WHERE
					TFT.TFT_FILIAL = %xFilial:TFT%
					AND TFT.TFT_CODTFH = %exp:oMdlTFH:GetValue("TFH_COD")%
					AND TFT.%NotDel%
			EndSql
			If (cTmpTFH)->(!EOF())
				lRet	:= .F.
				cMsg	+= STR0248 + CRLF // "O item seguinte possui apontamento. "
				cMsg	+= STR0249 + oMdlTFH:GetValue("TFH_PRODUT") + CRLF // "Produto: "
				cMsg	+= STR0250 + oMdlTFH:GetValue("TFH_COD") + CRLF + CRLF // "Codigo: "
			EndIf
			(cTmpTFH)->(DbCloseArea())
		Next nX
		oMdlTFH:GoLine(nLinPosi)
	EndIf

	//Validação armamento - Deleção do Posto
	If lGsOrcArma
		oMdlTXQ	:= oMdl:GetModel("TXQDETAIL")
		If !lOrcPrc .AND. !(oMdlTXQ:IsEmpty())
			nLinPosi := oMdlTXQ:GetLine()
			cTmpTXQ := GetNextAlias()
			For nX := 1 To oMdlTXQ:Length()
				oMdlTXQ:GoLine(nX)
				BeginSql Alias cTmpTXQ
					SELECT 1
					FROM %table:TXQ% TXQ
					WHERE
						TXQ.TXQ_FILIAL = %xFilial:TXQ%
						AND TXQ.TXQ_CODTFF = %exp:oMdlTXQ:GetValue("TXQ_CODTFF")%
						AND TXQ.TXQ_CODIGO = %exp:oMdlTXQ:GetValue("TXQ_CODIGO")%
						AND TXQ.TXQ_QTDAPO > 0
						AND TXQ.TXQ_ITEARM <> '3'
						AND TXQ.%NotDel%
				EndSql
				If (cTmpTXQ)->(!EOF())
					lRet	:= .F.
					cMsg	+= STR0248 + CRLF // "O item seguinte possui apontamento. "
					cMsg	+= STR0249 + oMdlTXQ:GetValue("TXQ_CODPRD") + CRLF // "Produto: "
					cMsg	+= STR0250 + oMdlTXQ:GetValue("TXQ_CODIGO") + CRLF + CRLF // "Codigo: "
				EndIf
				(cTmpTXQ)->(DbCloseArea())
			Next nX
			oMdlTXQ:GoLine(nLinPosi)
		EndIf
	EndIf
EndIf

If !(isBlind())
	If !lRet
		AtShowLog(cMsg,STR0239, .T., .T., .F.)  // "Inconsistências."
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740AVerABB

Verifica se existe agendamento para o recurso do contrato

@sample 	At740AVerABB( cCodTFF )

@param 		cCodTFF - Codigo do recurso humano do contrato

@since		02/10/2013
@version	P11.90

@return 	nRet, retorna o resultado do cálculo

/*/
//------------------------------------------------------------------------------
Static Function At740VerABB( cCodTFF )
Local lRet := .F.
Local cAliasABB := GetNextAlias()

BeginSql Alias cAliasABB

	SELECT
		ABB.ABB_CODIGO
	FROM
		%Table:ABQ% ABQ
	JOIN %Table:ABB% ABB ON
		ABB.ABB_FILIAL = %xFilial:ABB% AND
		ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND
		ABB.%NotDel%
	WHERE
		ABQ.ABQ_FILIAL = %xFilial:ABQ% AND
		ABQ.ABQ_CODTFF = %Exp:cCodTFF% AND
		ABQ.%NotDel%

EndSql

If ((cAliasABB)->(Eof()) .And. (cAliasABB)->(Bof()))
	lRet := .T.
EndIf

(cAliasABB)->(dbCloseArea())

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740TarEx
Analisa recurso humano informado na TFF para serviço extra, caso o mesmo possua risco (1-SIM) cria automaticamente uma tarefa de funcionário (TN5).
A tarefa será criada com um sequencia automática e será considerado o campo LOCAL e FUNÇÃO informada no contrato.

@param  cLocal, Caracter, Codigo do Local
@param  aTFF, Array, Array contendo a TFF de cada local

@return Nenhum
@author Luiz Gabriel
@since 14/03/2019
/*/
//------------------------------------------------------------------------------------------
Static Function At740TarEx(cLocal,aItemRH)
Local aArea		:= {}
Local nCont		:= 0
Local cQueryNum	:= ""
Local cQueryTN5	:= ""
Local cProxTN5	:= ""
Local cFilTN5	:= ""

DbSelectArea("TN5")
TN5->(DbSetOrder(1))
If TN5->( ColumnPos("TN5_LOCAL")) > 0 .And. TN5->( ColumnPos("TN5_POSTO")) > 0

	aArea		:= GetArea()
	cQueryNum	:= GetNextAlias()

	BeginSql Alias cQueryNum
		SELECT MAX(TN5_CODTAR) ULTTAREFA
		FROM %Table:TN5% TN5
		WHERE TN5.TN5_FILIAL = %xFilial:TN5%
			AND TN5.%NotDel%
	EndSql

	cProxTN5 := Soma1( (cQueryNum)->ULTTAREFA )

	cFilTN5 := xFilial("TN5")

	For nCont := 1 To Len(aItemRH)

		If	aItemRH[nCont][14] == "1"

			cQueryTN5 := GetNextAlias()

			BeginSql Alias cQueryTN5

				SELECT TN5.R_E_C_N_O_ TN5RECNO
				FROM %Table:TN5% TN5
				WHERE TN5.TN5_FILIAL	= %exp:xFilial('TN5')%
					AND TN5.TN5_LOCAL	= %exp:cLocal%
					AND TN5.TN5_POSTO	= %exp:aItemRH[nCont][3]%
					AND TN5.%NotDel%
			EndSql

			If (cQueryTN5)->(EOF())
				RecLock("TN5",.T.)
					TN5->TN5_FILIAL 	:= cFilTN5
					TN5->TN5_CODTAR 	:= cProxTN5
					TN5->TN5_NOMTAR 	:= cLocal + " - " + aItemRH[nCont][3]
					TN5->TN5_LOCAL		:= cLocal
					TN5->TN5_POSTO		:= aItemRH[nCont][3]
				TN5->(MsUnlock())
			Endif

			cProxTN5 := Soma1( cProxTN5 )

			(cQueryTN5)->(dbCloseArea())

		Endif

	Next nCont

	(cQueryNum)->(dbCloseArea())

	RestArea(aArea)

Endif

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740Horas
@description Valor do saldod de horas
@return nQtd
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740Horas()
Local oModel	:= FwModelActive()
Local oMdlTFF	:= oModel:GetModel("TFF_RH")
Local cCodTFF	:= oMdlTFF:GetValue("TFF_COD")
Local cAliasTFF	:= GetNextAlias()
Local cRet		:= oMdlTFF:GetValue("TFF_QTDHRS")
Local cOldValue	:= ""

BeginSQL Alias cAliasTFF
	SELECT TFF.TFF_QTDHRS
		FROM %Table:TFF% TFF
		WHERE TFF.TFF_FILIAL = %xFilial:TFF%
			AND TFF.TFF_COD = %Exp:cCodTFF%
			AND TFF.%NotDel%
EndSQL

If !(cAliasTFF)->(EOF())
	cOldValue := (cAliasTFF)->TFF_QTDHRS
	If IsInCallStack("At870Revis")
		cRet := TecConvHr(SomaHoras(SubHoras(cRet, cOldValue ), oMdlTFF:GetValue("TFF_HRSSAL")))
	EndIf
EndIf
(cAliasTFF)->(DbCloseArea())

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740APHR
@description Verifica se esxiste agenda gerada para o codigo de TFF
@return lRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740APHR( cCodTFF )
Local lRet	:= .T.
Local cAliasABB := GetNextAlias()

BeginSQL Alias cAliasABB
	SELECT 1 REC
		FROM %Table:ABB% ABB
		INNER JOIN %Table:ABQ% ABQ
			ON ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL
		WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABQ.ABQ_FILTFF = %xFilial:TFF%
			AND ABQ.ABQ_CODTFF = %Exp:cCodTFF%
			AND ABQ.%NotDel%
			AND ABB.%NotDel%
EndSQL

lRet := !(cAliasABB)->(EOF())
(cAliasABB)->(DbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecVldHrTF
@description Valid do Campo TFF_QTDHRS
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecVldHrTF( cCampo, xValue )
Local oModel	:= FwModelActive()
Local oMdlTFF	:= oModel:GetModel("TFF_RH")

If AT(":",xValue) == 0
	If LEN(Alltrim(xValue)) == 4
		xValue := LEFT(Alltrim(xValue),2) + ":" + RIGHT(Alltrim(xValue),2)
		oMdlTFF:LoadValue(cCampo, xValue)
	ElseIf LEN(Alltrim(xValue)) == 2
		xValue := Alltrim(xValue) + ":00"
		oMdlTFF:LoadValue(cCampo, xValue)
	ElseIf LEN(Alltrim(xValue)) == 1
		xValue := "0" + Alltrim(xValue) + ":00"
		oMdlTFF:LoadValue(cCampo, xValue)
	EndIf
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecVldHrTF
@description Valid do Campo TFF_QTDHRS
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740QTDHr( lRevis, nNewValue, nOldValue )
Local oModel	:= FwModelActive()
Local oMdlTFF	:= oModel:GetModel("TFF_RH")
Local cRet		:= ""
Local cQtdHrs	:= oMdlTFF:GetValue("TFF_QTDHRS")
Local nQuant	:= oMdlTFF:GetValue("TFF_QTDVEN")
Local cCodTFF	:= oMdlTFF:GetValue("TFF_COD")
Local cConta	:= ""
Local cAliasTFF	:= GetNextAlias()
Local nQtd		:= 0
Local nX

Default lRevis := .F.

If lRevis
	BeginSQL Alias cAliasTFF
		SELECT TFF.TFF_QTDHRS, TFF.TFF_QTDVEN
			FROM %Table:TFF% TFF
			WHERE TFF.TFF_FILIAL = %xFilial:TFF%
				AND TFF.TFF_COD = %Exp:cCodTFF%
				AND TFF.%NotDel%
	EndSQL

	If !(cAliasTFF)->(EOF())
		nQtd := nQuant - (cAliasTFF)->TFF_QTDVEN
		cConta := TecConvHr(TecConvHr((cAliasTFF)->TFF_QTDHRS) / (cAliasTFF)->TFF_QTDVEN)
		If nQtd > 0
			cRet := cQtdHrs
			For nX := 1 To nQtd
				cRet := TecConvHr(SomaHoras(cRet, cConta))
			Next nX
		ElseIf nQtd < 0
			For nX := 1 To nQuant
				cRet := TecConvHr(SomaHoras(cRet, cConta))
			Next nX
		Else
			For nX := 1 To nQuant
				cRet := TecConvHr(SomaHoras(cRet, cConta))
			Next nX
		EndIf
	EndIf
	(cAliasTFF)->(DbCloseArea())
Else
	If !Empty(cQtdHrs)
		cQtdHrs := TecConvHr(TecConvHr(cQtdHrs) / nOldValue)
		For nX := 1 To nNewValue
			cRet := TecConvHr(SomaHoras(cRet, cQtdHrs))
		Next nX
	EndIf
	oMdlTFF:LoadValue("TFF_QTDHRS", cRet)
	oMdlTFF:LoadValue("TFF_HRSSAL", cRet)
EndIf

Return cRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TC740VLCL
@description Utilizada na validação dos campos do addCalc para desconsiderar postos encerrados ou fora da vigência
@author Diego Bezerra
@since  14/05/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TC740VLCL(oModel, cFld, nDeduc, cIdModel)
Local lRet 	:= .T.
Local aArea := {}
Local lPrec	:= .F.
Default cIdModel = ""

lPrec := cIdModel == 'TECA740F'
If lCalcEnc
	IF EMPTY(oModel:GetValue("TFL_LOC","TFL_ENCE")) .OR. oModel:GetValue("TFL_LOC","TFL_ENCE") == "2"
		If cFld == 'TOT_RH' .OR. cFld == 'TOT_MI' .OR. cFld == 'TOT_MC'
			If cFld == 'TOT_RH'
				aArea := GetArea()
				DbSelectArea("TFF")
				TFF->(DbSetOrder(3))
				If TFF->( dbSeek( xFilial("TFF") + oModel:GetValue("TFL_LOC","TFL_CODIGO")  ) )
					While TFF->(!Eof()) .AND. TFF->TFF_CODPAI == oModel:GetValue("TFL_LOC","TFL_CODIGO") .AND. TFF->TFF_FILIAL == xFilial('TFF')
						If ( TFF->TFF_ENCE == "1" .AND. TFF->TFF_COBCTR == '1' ) .Or. ( !Empty( TFF->TFF_PERFIM ) .And. dDataBase > TFF->TFF_PERFIM )
							nDeduc += TFF->(TFF_QTDVEN*TFF_PRCVEN)+(TFF->(TFF_QTDVEN*TFF_PRCVEN)*(TFF->TFF_LUCRO/100))+(TFF->(TFF_QTDVEN*TFF_PRCVEN)*(TFF->TFF_ADM/100));
										+(TFF->(TFF_QTDVEN*TFF_PRCVEN)*(TFF->TFF_DESCON/100))
							If !lPrec
								DbSelectArea("TFG")
								TFG->(DbSetOrder(3))
								IF TFG->( dbSeek( xFilial("TFG") + TFF->TFF_COD))
									While TFG->(!Eof()) .AND. TFG_CODPAI == TFF->TFF_COD .AND. TFG_FILIAL == xFilial('TFG')
										nDeduc += TFG->(TFG_QTDVEN*TFG_PRCVEN)+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_LUCRO/100))+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_ADM/100));
													+(TFG->(TFG_QTDVEN*TFG_PRCVEN)*(TFG->TFG_DESCON/100))
										TFG->(dbSkip())
									EndDo
								EndIf

								DbSelectArea("TFH")
								TFH->(DbSetOrder(3))
								IF TFH->( dbSeek( xFilial("TFH") + TFF->TFF_COD))
									While TFH->(!Eof()) .AND. TFH_CODPAI == TFF->TFF_COD .AND. TFH_FILIAL == xFilial('TFH')
										nDeduc += TFH->(TFH_QTDVEN*TFH_PRCVEN)+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_LUCRO/100))+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_ADM/100));
													+(TFH->(TFH_QTDVEN*TFH_PRCVEN)*(TFH->TFH_DESCON/100))
										TFH->(dbSkip())
									EndDo
								EndIf
							EndIf

						EndIf
						TFF->(dbSkip())
					EndDo
				EndIf
				RestArea(aArea)
			EndIf
		EndIf

		If cFld == 'TOT_LE'
			aArea := GetArea()
			DbSelectArea("TFI")
			TFI->(DbSetOrder(3))
			If TFI->( dbSeek( xFilial("TFI") + oModel:GetValue("TFL_LOC","TFL_CODIGO")  ) )
				While TFI->(!Eof()) .AND. TFI->TFI_CODPAI == oModel:GetValue("TFL_LOC","TFL_CODIGO")
					If TFI->TFI_ENCE == "1"
						nDeduc += IIF(!EMPTY(TFI->TFI_TOTAL) .AND. valtype(TFI->TFI_TOTAL)=="N",TFI->TFI_TOTAL,0)
					EndIf
					TFI->(dbskip())
				EndDo
			EndIf
			RestArea(aArea)
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf
Return lRet


/*/{Protheus.doc} TC740RCCL
	Utilizada no recalculo dos campos do addCalc para desconsiderar postos encerrados ou fora da vigência
	@type Function
	@author Anderson F. Gomes
	@since 02/04/2025
	@version 12.1.2310
	@param nDeduc, Numeric, Varável com o valor a ser deduzido
	@return Nil, Nil, Nulo
/*/
Function TC740RCCL( nDeduc )
	Local oModel As Object
	Local oView As Object
	Local oMdlTFL As Object
	Local oMdlTFF As Object
	Local oMdlTFG As Object
	Local oMdlTFH As Object
	Local oMdlCalc As Object
	Local nLinTFL As Numeric
	Local nLinTFF As Numeric
	Local nLinTFG As Numeric
	Local nLinTFH As Numeric
	Local nX As Numeric
	Local nY As Numeric
	Local nZ As Numeric

	oModel := FwModelActive()
	oMdlTFL := oModel:GetModel("TFL_LOC")
	nLinTFL := oMdlTFL:GetLine()
	oMdlTFF := oModel:GetModel( "TFF_RH" )
	nLinTFF := oMdlTFF:GetLine()
	oMdlTFG := oModel:GetModel( "TFG_MI" )
	nLinTFG := oMdlTFG:GetLine()
	oMdlTFH := oModel:GetModel( "TFH_MC" )
	nLinTFH := oMdlTFH:GetLine()

	nDeduc := 0

	For nX := 1 To oMdlTFL:Length()
		oMdlTFL:GoLine( nX )
		If Empty( oMdlTFL:GetValue( "TFL_ENCE" ) ) .Or. oMdlTFL:GetValue( "TFL_ENCE" ) == "2"
			oMdlTFF := oModel:GetModel( "TFF_RH" )
			For nY := 1 To oMdlTFF:Length()
				oMdlTFF:GoLine( nY )
				If ( oMdlTFF:GetValue( "TFF_ENCE" ) == "1" .And. oMdlTFF:GetValue( "TFF_COBCTR" ) == '1' ) .Or. ( !Empty( oMdlTFF:GetValue( "TFF_PERFIM" ) ) .And. dDataBase > oMdlTFF:GetValue( "TFF_PERFIM" ) )
					nDeduc += ( oMdlTFF:GetValue( "TFF_QTDVEN" ) * oMdlTFF:GetValue( "TFF_PRCVEN" ) ) +;
								( oMdlTFF:GetValue( "TFF_QTDVEN" ) * oMdlTFF:GetValue( "TFF_PRCVEN" ) * ( oMdlTFF:GetValue( "TFF_LUCRO" ) / 100 ) ) +;
								( oMdlTFF:GetValue( "TFF_QTDVEN" ) * oMdlTFF:GetValue( "TFF_PRCVEN" ) * ( oMdlTFF:GetValue( "TFF_ADM" ) / 100 ) ) +;
								( oMdlTFF:GetValue( "TFF_QTDVEN" ) * oMdlTFF:GetValue( "TFF_PRCVEN" ) * ( oMdlTFF:GetValue( "TFF_DESCON" ) / 100 ) )
				EndIf
				oMdlTFG := oModel:GetModel( "TFG_MI" )
				For nZ := 1 To oMdlTFG:Length()
					oMdlTFG:GoLine( nZ )
					If ( oMdlTFF:GetValue( "TFF_ENCE" ) == "1" .And. oMdlTFF:GetValue( "TFF_COBCTR" ) == '1' ) .Or. !Empty( oMdlTFG:GetValue( "TFG_PERFIM" ) ) .And. dDataBase > oMdlTFG:GetValue( "TFG_PERFIM" ) 
						nDeduc += ( oMdlTFG:GetValue( "TFG_QTDVEN" ) * oMdlTFG:GetValue( "TFG_PRCVEN" ) ) +;
									( oMdlTFG:GetValue( "TFG_QTDVEN" ) * oMdlTFG:GetValue( "TFG_PRCVEN" ) * ( oMdlTFG:GetValue( "TFG_LUCRO" ) / 100 ) ) +;
									( oMdlTFG:GetValue( "TFG_QTDVEN" ) * oMdlTFG:GetValue( "TFG_PRCVEN" ) * ( oMdlTFG:GetValue( "TFG_ADM" ) / 100 ) ) +;
									( oMdlTFG:GetValue( "TFG_QTDVEN" ) * oMdlTFG:GetValue( "TFG_PRCVEN" ) * ( oMdlTFG:GetValue( "TFG_DESCON" ) / 100 ) )
					EndIf
				Next nZ
				oMdlTFH := oModel:GetModel( "TFH_MC" )
				For nZ := 1 To oMdlTFH:Length()
					oMdlTFH:GoLine( nZ )
					If ( oMdlTFF:GetValue( "TFF_ENCE" ) == "1" .And. oMdlTFF:GetValue( "TFF_COBCTR" ) == '1' ) .Or. !Empty( oMdlTFH:GetValue( "TFH_PERFIM" ) ) .And. dDataBase > oMdlTFH:GetValue( "TFH_PERFIM" ) 
						nDeduc += ( oMdlTFH:GetValue( "TFH_QTDVEN" ) * oMdlTFH:GetValue( "TFH_PRCVEN" ) ) +;
									( oMdlTFH:GetValue( "TFH_QTDVEN" ) * oMdlTFH:GetValue( "TFH_PRCVEN" ) * ( oMdlTFH:GetValue( "TFH_LUCRO" ) / 100 ) ) +;
									( oMdlTFH:GetValue( "TFH_QTDVEN" ) * oMdlTFH:GetValue( "TFH_PRCVEN" ) * ( oMdlTFH:GetValue( "TFH_ADM" ) / 100 ) ) +;
									( oMdlTFH:GetValue( "TFH_QTDVEN" ) * oMdlTFH:GetValue( "TFH_PRCVEN" ) * ( oMdlTFH:GetValue( "TFH_DESCON" ) / 100 ) )
					EndIf
				Next nZ
			Next nY
		EndIf
	Next nX

	oMdlTFL:GoLine( nLinTFL )
	oMdlTFF:GoLine( nLinTFF )
	oMdlTFG:GoLine( nLinTFG )
	oMdlTFH:GoLine( nLinTFH )

	If !IsBlind()
		oMdlCalc := oModel:GetModel( "TOTAIS" )
		oMdlCalc:LoadValue( "TOT_GERAL_EN", oModel:GetValue( "CALC_TFL_NE", "TOT_RH_EN" ) +;
											oModel:GetValue( "CALC_TFL_NE", "TOT_MI_EN" ) +;
											oModel:GetValue( "CALC_TFL_NE", "TOT_MC_EN" ) +;
											oModel:GetValue( "CALC_TFL_NE", "TOT_LE_EN" ) +;
											oModel:GetValue( "CALC_TFL_NE", "TOT_TXP_EN" ) +;
											oModel:GetValue( "CALC_TFL_NE", "TOT_TXQ_EN" ) -;
											nDeduc, .T. )

		oView := FwViewActive()
		oView:Refresh( "VIEW_TOT" )
	Endif
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740PrxPa
@description Calcula automaticamente o valor do campo XXX_VLPRPA de acordo
com o model / params

@author Mateus Boiani
@since  17/06/2020
/*/
//------------------------------------------------------------------------------
Function At740PrxPa(cTipo, nQuantidade, nValor, nPercDesc, nValLucro, nValAdm, nVidMes)
	Local aSaveLines := {}
	Local nRet       := 0
	Local oMdlGrd
	Local oModel     := FwModelActive()

	Default cTipo       := ""
	Default nPercDesc   := 0
	Default nQuantidade := 0
	Default nValAdm     := 0
	Default nValLucro   := 0
	Default nValor      := 0
	Default nVidMes     := 1

	If !( ValType(nVidMes) == "N" .And. nVidMes > 0 )
		nVidMes := 1
	EndIf

	If !EMPTY(cTipo) .AND. VALTYPE(oModel) == "O" .AND. oModel:Getid() $ "TECA740|TECA740F"
		aSaveLines := FWSaveRows()
		If oModel:GetValue("TFJ_REFER","TFJ_CNTREC") == '1'
			If cTipo = "TFF"
				oMdlGrd := oModel:GetModel("TFF_RH")
				If oMdlGrd:GetValue("TFF_COBCTR") != '2'
					nQuantidade := oMdlGrd:GetValue("TFF_QTDVEN")
					nValor := oMdlGrd:GetValue("TFF_PRCVEN")
					nPercDesc := oMdlGrd:GetValue("TFF_DESCON")
					If !lGsPrecific
						nValAdm := oMdlGrd:GetValue("TFF_TXADM")
						nValLucro := oMdlGrd:GetValue("TFF_TXLUCR")
					Endif
				EndIf
			ElseIf cTipo == "TFH"
				oMdlGrd := oModel:GetModel("TFH_MC")
				If oMdlGrd:GetValue("TFH_COBCTR") != '2'
					nQuantidade := oMdlGrd:GetValue("TFH_QTDVEN")
					nValor := oMdlGrd:GetValue("TFH_PRCVEN")
					nPercDesc := oMdlGrd:GetValue("TFH_DESCON")
					If !lGsPrecific
						nValAdm := oMdlGrd:GetValue("TFH_TXADM")
						nValLucro := oMdlGrd:GetValue("TFH_TXLUCR")
					Endif
					If !Empty( oMdlGrd:GetValue( "TFH_VIDMES" ) )
						nVidMes := oMdlGrd:GetValue( "TFH_VIDMES" )
					EndIf
				EndIf
			ElseIf cTipo == "TFG"
				oMdlGrd := oModel:GetModel("TFG_MI")
				If oMdlGrd:GetValue("TFG_COBCTR") != '2'
					nQuantidade := oMdlGrd:GetValue("TFG_QTDVEN")
					nValor := oMdlGrd:GetValue("TFG_PRCVEN")
					nPercDesc := oMdlGrd:GetValue("TFG_DESCON")
					If !lGsPrecific
						nValAdm := oMdlGrd:GetValue("TFG_TXADM")
						nValLucro := oMdlGrd:GetValue("TFG_TXLUCR")
					Endif
					If !Empty( oMdlGrd:GetValue( "TFG_VIDMES" ) )
						nVidMes := oMdlGrd:GetValue( "TFG_VIDMES" )
					EndIf
				EndIf
			EndIf
		EndIf
		FWRestRows( aSaveLines )
	EndIf

	nRet := ( (nQuantidade * nValor) + nValLucro + nValAdm ) / nVidMes
	nRet -= ((nQuantidade * nValor) * nPercDesc/100)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740AtTpr
@description Atualiza o valor de TFL_VLPRPA de acordo com os dados do modelo

@author Mateus Boiani
@since  17/06/2020
/*/
//------------------------------------------------------------------------------
Function At740AtTpr()
Local oModel := FwModelActive()
Local oView := Nil
Local nX
Local nY
Local oMdlTFF
Local oMdlTFL
Local oMdlTFH
Local oMdlTFG
Local oMdlTFJ
Local nRet := 0
Local aSaveLines
Local aSelect := {}

If VALTYPE(oModel) == "O" .AND. oModel:Getid() $ "TECA740|TECA740F" .AND. TecVlPrPar()
	oMdlTFF := oModel:GetModel("TFF_RH")
	oMdlTFL := oModel:GetModel("TFL_LOC")
	oMdlTFH := oModel:GetModel("TFH_MC")
	oMdlTFG := oModel:GetModel("TFG_MI")
	oMdlTFJ := oModel:GetModel("TFJ_REFER")

	If oMdlTFJ:GetValue("TFJ_CNTREC") == '1'
		aSaveLines := FWSaveRows()
		For nX := 1 To oMdlTFF:Length()
			If oModel:Getid() == "TECA740"
				oMdlTFF:GoLine(nX)
				If !(oMdlTFF:isDeleted(nX)) .AND. !EMPTY( oMdlTFF:GetValue("TFF_PRODUT", nX) ) .AND. oMdlTFF:GetValue("TFF_COBCTR", nX) != "2"
					nRet += oMdlTFF:GetValue("TFF_VLPRPA", nX)
				EndIf
				For nY := 1 To oMdlTFH:Length()
					If !(oMdlTFH:isDeleted(nY)) .AND. !EMPTY( oMdlTFH:GetValue("TFH_PRODUT", nY) ) .AND. oMdlTFH:GetValue("TFH_COBCTR", nY) != "2"
						nRet += oMdlTFH:GetValue("TFH_VLPRPA",nY)
					EndIf
				Next nY
				For nY := 1 To oMdlTFG:Length()
					If !(oMdlTFG:isDeleted(nY)) .AND. !EMPTY( oMdlTFG:GetValue("TFG_PRODUT", nY) ) .AND. oMdlTFG:GetValue("TFG_COBCTR", nY) != "2"
						nRet += oMdlTFG:GetValue("TFG_VLPRPA",nY)
					EndIf
				Next nY
			Else
				If !(oMdlTFF:isDeleted(nX)) .AND. !EMPTY( oMdlTFF:GetValue("TFF_PRODUT", nX) ) .AND. oMdlTFF:GetValue("TFF_COBCTR", nX) != "2"
					nRet += oMdlTFF:GetValue("TFF_VLPRPA", nX)
				EndIf
			EndIf
		Next nX

		If oModel:Getid() == "TECA740F"
			For nY := 1 To oMdlTFH:Length()
				If !(oMdlTFH:isDeleted(nY)) .AND. !EMPTY( oMdlTFH:GetValue("TFH_PRODUT", nY) ) .AND. oMdlTFH:GetValue("TFH_COBCTR", nY) != "2"
					nRet += oMdlTFH:GetValue("TFH_VLPRPA",nY)
				EndIf
			Next nY
			For nY := 1 To oMdlTFG:Length()
				If !(oMdlTFG:isDeleted(nY)) .AND. !EMPTY( oMdlTFG:GetValue("TFG_PRODUT", nY) ) .AND. oMdlTFG:GetValue("TFG_COBCTR", nY) != "2"
					nRet += oMdlTFG:GetValue("TFG_VLPRPA",nY)
				EndIf
			Next nY
		EndIf
		FWRestRows( aSaveLines )
	EndIf
	oMdlTFL:LoadValue("TFL_VLPRPA",nRet)

	oView := FwViewActive()
	If !IsBlind() .And. ValType( oView ) == "O"
		aSelect := oView:GetCurrentSelect()
		If aSelect[1] $ "VIEW_MI|VIEW_MC" .And. aSelect[2] $ "TFG_VIDMES|TFH_VIDMES"
			oView:Refresh( aSelect[1] )
		EndIf
	EndIf
EndIf

Return nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740TFUVa
@description Valid do campo TFU_VALOR
@return Boolean - se o valor é maior ou igual a 0
@author Augusto Albuquerque
@since  04/09/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740TFUVa(nValor)
Return nValor >= 0
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlEsc
@description Validação de alteração da escala quando existe agenda gerada
@return Boolean - Não existe agenda = .T.
@author Kaique Schiller
@since  03/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740VlEsc(cCodTFF,cEscala,lAuto)
Local cTmpTFF 	:= GetNextAlias()
Local lRet		:= .T.
Local cExp     	:= "%%"
Local lMponto 	:= (ABB->(ColumnPos('ABB_MPONTO')) > 0 )
Local lTrocaEsc	:= At680Perm( Nil, __cUserID, "066" )
Default lAuto   := .F.

If lMponto
    cExp    := "%  AND ABB.ABB_MPONTO = 'F' AND ABB.ABB_ATIVO = '1' %"
Endif

//Verifica se há agendas iguais e posteriores a database do sistema
If lTrocaEsc .And. hasABBRig(dDataBase, cCodTFF, ,cEscala, .T.)
	lRet := .F.
	Help(,,"At740VlEsc",,STR0315 + dToc(dDataBase),; //"Este posto e escala possuem alocações com datas maiores ou iguais a "
					1,0,,,,,,{STR0316 + dToc(dDataBase) }) // ""Exclua as agendas com datas maiores ou iguais a "
EndIf

If lRet
	BeginSql Alias cTmpTFF
		SELECT 1
		FROM %table:ABB% ABB
		INNER JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
			AND ABQ.ABQ_CODTFF = %exp:cCodTFF%
			AND ABQ.%NotDel%
		INNER JOIN %table:TDV% TDV ON TDV.TDV_FILIAL = %xFilial:TDV%
			AND TDV.TDV_CODABB = ABB.ABB_CODIGO
			AND TDV.%NotDel%
		WHERE ABB.ABB_FILIAL = %xFilial:ABB%
			AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
			AND ABB.%NotDel%
			%exp:cExp%
	EndSql

	If	(cTmpTFF)->(!EOF())
		If !lTrocaEsc
			lRet	:= .F.
			Help(,,"At740VlEsc",,STR0291,; //"Não é possível alterar a escala."
						1,0,,,,,,{STR0292}) // "Esse posto possui alocação para maiores informações acesse a mesa operacional."
		Else
			If !lAuto
				lRet := MsgYesNo(STR0312, STR0313)//"Já existem alocações relacionadas para esta escala. Alterar a escala não permitirá novas alocações na escala antiga, deseja continuar?"##"Troca de Escala"
			Endif
			If !lRet
				Help(,,"At740VlEsc",,STR0314,1,0,,,,,,) //"Operação cancelada pelo usuario"
			EndIf
		EndIf
	EndIf
	(cTmpTFF)->(DbCloseArea())
EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} VldDatas
@description Validação das datas de MI e MC
@return Boolean
@author Junior Geraldo
@since  29/04/2021
/*/
//------------------------------------------------------------------------------
Static Function VldDatas(oMdlG,nLinhAtu)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lRet      	:= .T.
Local oMdlFull 		:= oMdlG:GetModel()
Local oMdlMI		:= oMdlFull:GetModel("TFG_MI")
Local oMdlMC		:= oMdlFull:GetModel("TFH_MC")
Local lOrcPrc 	    := SuperGetMv("MV_ORCPRC",,.F.)
Local nX            := 1
Local lRecorre      := oMdlFull:GetValue("TFJ_REFER","TFJ_CNTREC")  == "1"
Local nTamMdl		:= 0
Local nAuxNx		:= 1
Local lVld 			:= .T.

Default nLinhAtu	:= 0
//Não verificar quando está carregando pelo facilitador de orçamento
If !IsInCallStack("At740FaMat")
	If lRecorre
		nTamMdl:= oMdlMI:Length()
		If nLinhAtu > 0
			If oMdlG:CID == "TFG_MI" //Quando informado a linha maior que 0, estou validando somente a grid posicionada (Material de Implantação)
				nTamMdl:= nLinhAtu
				nAuxNx := nLinhAtu
			Else
				lVld := .F.
			EndIf
		EndIf
		If lVld
			For nX := nAuxNx to nTamMdl
				oMdlMI:GoLine(nX)
				If !Empty(oMdlMI:GetValue("TFG_PRODUT")) .AND. !Empty(oMdlMI:GetValue("TFG_PERFIM")) .AND. oMdlMI:GetValue('TFG_PERFIM') > IIF(lOrcPrc,oMdlFull:GetValue("TFL_LOC","TFL_DTFIM"), oMdlFull:GetValue("TFF_RH","TFF_PERFIM"))
					Help( ,, 'PosLinTFG',, STR0288, 1, 0,,,,,,{STR0293} ) //"Data de vigência final não está dentro da data do Local de atendimento." "Verifique as datas dos itens de Materiais de Implantação e Materiais de Consumo."
					lRet := .F.
					Exit
				EndIf
			Next nX
		EndIf

		If lRet
			nTamMdl:= oMdlMC:Length()
			nAuxNx := 1
			lVld	:= .T.
			If nLinhAtu > 0
				If oMdlG:CID == "TFH_MC"//Quando informado a linha maior que 0, estou validando somente a grid posicionada(Material de Consumo)
					nTamMdl:= nLinhAtu
					nAuxNx := nLinhAtu
				Else
					lVld := .F.
				EndIf
			EndIf
			If lVld
				For nX:= nAuxNx  to nTamMdl
					oMdlMC:GoLine(nX)
					If !Empty(oMdlMC:GetValue("TFH_PRODUT")) .AND. !Empty(oMdlMC:GetValue("TFH_PERFIM")) .AND. oMdlMC:GetValue('TFH_PERFIM') > IIF(lOrcPrc,oMdlFull:GetValue("TFL_LOC","TFL_DTFIM"), oMdlFull:GetValue("TFF_RH","TFF_PERFIM"))
						Help( ,, 'PosLinTFH',, STR0288, 1, 0,,,,,,{STR0293} ) //"Data de vigência final não está dentro da data do Local de atendimento." "Verifique as datas dos itens de Materiais de Implantação e Materiais de Consumo."
						lRet := .F.
						Exit
					EndIf
				Next nX
			EndIf
		Endif
	EndIf
EndIf


FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSeqABB
Verifica se existe alocão para todas sequencias da escala
@author Matheus.Goncalves
@since  28/05/2021
/*/
//-------------------------------------------------------------------
Static Function VldSeqABB(cCodTFF,nQtdven,cCodEsc, dDataRef)
Local cAliasSEQ	:= GetNextAlias()
Local nQtdEfet := 0
Local nQtdVaga := 0
Local lRet	:= .F.

Default cCodTFF :=""
Default	nQtdven	:= 0
Default cCodEsc :=""
Default dDataRef := dDataBase
//Quantidade de sequencias da escala
BeginSQL Alias cAliasSEQ
	SELECT COUNT(TDX.TDX_CODTDW) QTSEQUEN
	FROM %table:TDX% TDX
	WHERE TDX.TDX_FILIAL=%xFilial:TDX%
		AND TDX_CODTDW = %Exp:cCodEsc%
		AND TDX.%NotDel%
EndSql

If !(cAliasSEQ)->(EOF())
	nQtdVaga := nQtdven*(cAliasSEQ)->(QTSEQUEN)
Endif
(cAliasSEQ)->(DbCloseArea())
cAliasSEQ := GetNextAlias()

//Quantidade de alocação no posto
BeginSQL Alias cAliasSEQ
	SELECT COUNT(TGY.TGY_CODTFF) QTATEND
	FROM %table:TGY% TGY
	WHERE TGY.TGY_FILIAL=%xFilial:TGY%
		AND TGY.TGY_CODTFF = %Exp:cCodTFF%
		AND TGY.TGY_ULTALO <> ''
		AND TGY.%NotDel%
        AND TGY.TGY_ULTALO >= %Exp:DTOS(dDataRef)%
EndSql

If !(cAliasSEQ)->(EOF())
	nQtdEfet := (cAliasSEQ)->(QTATEND)
Endif
(cAliasSEQ)->(DbCloseArea())

nQtdVaga := nQtdVaga-nQtdEfet

If nQtdVaga < 0
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VLDTP
@description Valid do Campo TFJ_DTPLRV, para selecionar uma data maior que a data base
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Function At740VLDTP()
Local oModel  	:= FwModelActive()
Local oMdlTFJ	:= oModel:GetModel('TFJ_REFER')
Local dDataTFJ	:= oMdlTFJ:GetValue("TFJ_DTPLRV")
Local lRet		:= .T.

If dDataBase >= dDataTFJ
	lRet := .F.
	Help( ,, 'At740VLDTP',, STR0295, 1, 0,,,,,,{STR0296} ) //"Data não permitida." ## "Por favor Selecione uma data maior que a data base do sistema."
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidPlane
@description Verifica se a linha pertence ao contrato original para ser deletado nas Tabelas TFL/TFF/TFG/TFH
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Static Function ValidPlane( cCodAnt, cTabela )
Local cAliasVLD	:= GetNextAlias()
Local cQuery	:= ""
Local cEspcBr 	:= Space(TamSx3(cTabela+"_CODREL")[1])
Local lRet		:= .T.

Default cCodAnt := ""
Default cTabela	:= ""

If !Empty(cCodAnt) .AND. !Empty(cTabela)
	cQuery := ""
	cQuery += " SELECT 1 FROM " + RetSQLName(cTabela) + " " + cTabela
	cQuery += " WHERE "
	If cTabela == "TFL"
		cQuery += cTabela + "_CODIGO = '" + cCodAnt + "' AND "
	Else
		cQuery += cTabela + "_COD = '" + cCodAnt + "' AND "
	EndIf
	cQuery += cTabela + "_FILIAL = '" + xFilial(cTabela) + "' AND "
	cQuery += cTabela + ".D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVLD,.T.,.T.)

	lRet := (cAliasVLD)->(!Eof())

	(cAliasVLD)->(dbCloseArea())
Else
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldHeContr
@description Verifica se a linha pertence ao contrato original para ser deletado
@author	augusto.albuquerque
@since	25/06/2021
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function VldHeContr( cCodTFU, cCodTFF )
Local cAliasTFU	:= GetNextAlias()
Local cQuery	:= ""
Local cEspcBr 	:= Space(TamSx3("TFU_CODREL")[1])
Local lRet		:= .T.
Local nX

Default cCodTFU := ""
Default cCodTFF	:= ""

If !Empty(cCodTFU) .AND. !Empty(cCodTFF)
	cQuery := ""
	cQuery += " SELECT 1 "
	cQuery += " FROM " + RetSQLName("TFU") + " TFU "
	cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
	cQuery += " ON TFF.TFF_COD = TFU.TFU_CODTFF "
	cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "
	cQuery += " TFU.TFU_FILIAL = '" + xFilial("TFU") + "' "
	cQuery += " AND TFU.TFU_CODTFF = '" + cCodTFF + "' "
	cQuery += " AND TFU.TFU_CODIGO = '" + cCodTFU + "' "
	cQuery += " AND TFU.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFU,.T.,.T.)

	lRet := (cAliasTFU)->(!Eof())

	(cAliasTFU)->(dbCloseArea())
Else
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldLineRvP
@description Verifica se os campos voltaram para seu valor original do contrato nas tabelas TFL/TFF/TFG/TFH
@author	augusto.albuquerque
@since	25/06/2021
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function VldLineRvP( cCampo, xValor, cCodAnt, cTabela, lData)
Local aItem		:= {}
Local cAliasVLD	:= GetNextAlias()
Local cQuery	:= ""
Local lRet		:= .T.
Local nX

Default lData := .F.

cQuery := ""
cQuery += " SELECT  "
For nX := 1 To Len(aRevPlaIten)
	If aRevPlaIten[nX][1] == cTabela
		AADD( aItem, {aRevPlaIten[nX][2], aRevPlaIten[nX][3]})
		cQuery += aRevPlaIten[nX][2] + ","
	EndIf
Next nX
If (nPos := Ascan(aRevPlaIten, {|x| x[2] == cCampo})) > 0
	aRevPlaIten[nPos][3] := IIF(lData, DtoS(xValor), xValor)
	If (nPos := Ascan(aItem, {|x| x[1] == aRevPlaIten[nPos][2]})) > 0
		aItem[nPos][2] := IIF(lData, DtoS(xValor), xValor)//AADD( aItem, {cCampo, xValor})
	EndIf
Else
	AADD( aItem, {cCampo, IIF(lData, DtoS(xValor), xValor)})
	AADD( aRevPlaIten, {cTabela, cCampo, IIF(lData, DtoS(xValor), xValor)})
EndIf
cQuery += cCampo
cQuery += " FROM " + RetSQLName(cTabela) + " " + cTabela
cQuery += " WHERE "
If cTabela == "TFL"
	cQuery += cTabela + "_CODIGO = '" + cCodAnt + "' AND "
Else
	cQuery += cTabela + "_COD = '" + cCodAnt + "' AND "
EndIf
cQuery += cTabela + "_FILIAL = '" + xFilial(cTabela) + "' AND "
cQuery += cTabela + ".D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVLD,.T.,.T.)

If (cAliasVLD)->(!Eof())
	For nX := 1 To Len(aItem)
		If (cAliasVLD)->(&(aItem[nX][1])) <> aItem[nX][2]//(cAliasVLD)->aItem[nX][1] == aItem[nX][2]
			lRet := .F.
			Exit
		EndIf
	Next nX
EndIf

(cAliasVLD)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldTFULinR
@description Verifica se os campos voltaram para seu valor original do contrato
@author	augusto.albuquerque
@since	25/06/2021
/*/
//------------------------------------------------------------------------------
Static Function VldTFULinR( cCampo, xValor, cCodTFU, cCodTFF, lData )
Local aItem		:= {}
Local cAliasTFU	:= GetNextAlias()
Local cQuery	:= ""
Local lRet		:= .T.
Local nX

Default lData := .F.

If (nPos := Ascan(aRevPlaIten, {|x| x[2] == cCampo})) > 0
	aRevPlaIten[nPos][3] := IIF(lData, DtoS(xValor), xValor)
Else
	AADD( aRevPlaIten, {"TFU", cCampo, IIF(lData, DtoS(xValor), xValor)})
EndIf

cQuery := ""
cQuery += " SELECT  "
For nX := 1 To Len(aRevPlaIten)
	If aRevPlaIten[nX][1] == "TFU"
		AADD( aItem, {aRevPlaIten[nX][2], aRevPlaIten[nX][3]})
		cQuery += aRevPlaIten[nX][2] + ","
	EndIf
Next nX
cQuery += cCampo
cQuery += " FROM " + RetSQLName("TFU") + " TFU "
cQuery += " INNER JOIN " + RetSQLName("TFF") + " TFF "
cQuery += " ON TFF.TFF_COD = TFU.TFU_CODTFF "
cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFU.TFU_FILIAL = '" + xFilial("TFU") + "' "
cQuery += " AND TFU.TFU_CODTFF = '" + cCodTFF + "' "
cQuery += " AND TFU.TFU_CODIGO = '" + cCodTFU + "' "
cQuery += " AND TFU.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTFU,.T.,.T.)

If (cAliasTFU)->(!Eof())
	For nX := 1 To Len(aRevPlaIten)
		If aRevPlaIten[nX][1] == "TFU"
			If (cAliasTFU)->(&(aRevPlaIten[nX][2])) <> aRevPlaIten[nX][3]//(cAliasTFU)->aItem[nX][1] == aItem[nX][2]
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nX
EndIf

(cAliasTFU)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ATTOrcPla
@description Atualiza os campos de contrato e revisão antes do commit
@author	augusto.albuquerque
@since	25/06/2021
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function ATTOrcPla(oModel, cContrato, cRev)
Local nX
Local nZ
Local nY
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local oMdlTFL := oModel:GetModel("TFL_LOC")
Local oMdlTFF := oModel:GetModel("TFF_RH")
Local oMdlTFG := oModel:GetModel("TFG_MI")
Local oMdlTFH := oModel:GetModel("TFH_MC")
Local oMdlTXQ := Nil
Local oMdlTXP := Nil

oModel:LoadValue("TFJ_REFER","TFJ_CONTRT",cContrato)

For nX := 1 To oMdlTFL:Length() //LOCAL DE ATENDIMENTO
	oMdlTFL:Goline(nX)
	If !oMdlTFL:IsDeleted()
		oMdlTFL:LoadValue("TFL_CONTRT", cContrato)
		oMdlTFL:LoadValue("TFL_CONREV",cRev)
		For nY := 1 To oMdlTFF:Length() //ITEM DE RH - POSTO - SERVIÇO
			oMdlTFF:Goline(nY)
			If !oMdlTFF:IsDeleted() .AND. !Empty(oMdlTFF:GetValue('TFF_PRODUT'))
				oMdlTFF:LoadValue("TFF_CONTRT", cContrato)
				oMdlTFF:LoadValue("TFF_CONREV",cRev)
				For nZ := 1 To oMdlTFG:Length() //MATERIAL DE IMPLANTAÇÃO
					oMdlTFG:Goline(nZ)
					If !oMdlTFG:IsDeleted() .AND. !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
						oMdlTFG:LoadValue("TFG_CONTRT", cContrato)
						oMdlTFG:LoadValue("TFG_CONREV",cRev)
					EndIf
				Next nZ
				For nZ := 1 To oMdlTFH:Length() //MATERIAL DE CONSUMO
					oMdlTFH:Goline(nZ)
					If !oMdlTFH:IsDeleted() .AND. !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
						oMdlTFH:LoadValue("TFH_CONTRT", cContrato)
						oMdlTFH:LoadValue("TFH_CONREV",cRev)
					EndIf
				Next nZ
				If lGsOrcArma
					oMdlTXQ := oModel:GetModel("TXQDETAIL")
					For nZ := 1 To oMdlTXQ:Length() //ARMAMENTO - ARMAS, COLETES, MUNIÇÕES
						oMdlTXQ:Goline(nZ)
						If !oMdlTXQ:IsDeleted() .AND. !Empty(oMdlTXQ:GetValue('TXQ_CODPRD'))
							oMdlTXQ:LoadValue("TXQ_CONTRT", cContrato)
							oMdlTXQ:LoadValue("TXQ_CONREV",cRev)
						EndIf
					Next nZ
				EndIf
				If lGsOrcUnif
					oMdlTXP := oModel:GetModel("TXPDETAIL")
					For nZ := 1 To oMdlTXP:Length() //UNIFORME
						oMdlTXP:Goline(nZ)
						If !oMdlTXP:IsDeleted() .AND. !Empty(oMdlTXP:GetValue('TXP_CODUNI'))
							oMdlTXP:LoadValue("TXP_CONTRT", cContrato)
							oMdlTXP:LoadValue("TXP_CONREV",cRev)
						EndIf
					Next nZ
				EndIf
			EndIf
		Next nY
	EndIf
Next nX

Return .T.

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidTFFs
@description Criada para permitir que uma das validações na função ValidTFFs do fonte TECA870 faça um desvio para entrar na função VldSeqABB deste fonte.
@since 		06/08/2021
@author		Natacha Romeiro
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function At740VldQt(cCodTFF,nQtdven,cCodEsc, dDataRef)
Return  VldSeqABB(cCodTFF,nQtdven,cCodEsc, dDataRef)

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740GtPer
@description Retorna o valor do campo TFF_PERINI ou TFF_PERFIM antes da modificação

@since 		27/08/2021
@author		Luiz Gabriel
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function At740GtPer()
Return dPerCron

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740GtPer
@description Verifica se os campos de Risco, qtd de horas e Insalubridade estão preenchidos, quando o
campo Gera Vaga estiver como Sim

@since 		22/10/2021
@author		Luiz Gabriel
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function At740GerVag(oMdlTFF)
Local lRet:= .F.

If TFF->( ColumnPos("TFF_RISCO")) > 0 .And. oMdlTFF:GetValue("TFF_RISCO") == "1"
	lRet := .T.
EndIf

If TecABBPRHR() .And. (!lRet .And. !Empty(oMdlTFF:GetValue("TFF_QTDHRS")) .And. oMdlTFF:GetValue("TFF_QTDHRS") > "00:00")
	lRet := .T.
EndIf

If !lRet .And. oMdlTFF:GetValue("TFF_INSALU") <> "1"
	lRet := .T.
EndIf

If !lRet .And. oMdlTFF:GetValue("TFF_PERICU") <> "1"
	lRet := .T.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VldVg
@description Verifica se há alocação em um posto que vai ser alterado de Sim para Não no campo TFF_GERVAG, validação somente executada
na revisão.

@since 		22/10/2021
@author		Luiz Gabriel
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function At740VldVg(oMdlTFF)
Local lRet			:= .T.
Local cQueryTFF		:= GetNextAlias()
Local cGeraVaga		:= oMdlTFF:GetValue("TFF_GERVAG")
Local cFilBusc		:= oMdlTFF:GetValue("TFF_FILIAL")
Local cPosto		:= oMdlTFF:GetValue("TFF_COD")
Local cDataIni		:= dToS(oMdlTFF:GetValue("TFF_PERINI"))
Local cDataFim		:= dToS(oMdlTFF:GetValue("TFF_PERFIM"))

If cGeraVaga == "2"
	BeginSql Alias cQueryTFF

		SELECT ABQ_CONTRT,
			ABQ_ITEM,
			ABQ_ORIGEM,
			ABQ_CODTFF,
			ABQ_FILTFF,
			ABB_CODIGO
			FROM %Table:ABQ% ABQ
			INNER JOIN %Table:ABB% ABB ON ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL AND
																		ABB.ABB_FILIAL = %xFilial:ABB% AND
																		ABB_DTINI BETWEEN %exp:cDataIni% AND %exp:cDataFim%
																		AND ABB.%NotDel%
			WHERE
				ABQ.ABQ_FILIAL = %xFilial:ABQ% AND
				ABQ.ABQ_CODTFF = %exp:cPosto% AND
				ABQ.ABQ_FILTFF = %exp:cFilBusc% AND
				ABQ.%NotDel%
	EndSql

	If (cQueryTFF)->(!EOF())
		lRet := .F.
		Help( ,, 'At740VLDVg',, STR0310, 1, 0,,,,,,{STR0311} )//"Não é permitido a mudança para um posto que não gera vaga operacional se há agenda ativa"##"Exclua todas as agendas do posto para realizar a mudança"

	Endif

	(cQueryTFF)->(DbCloseArea())
EndIf

Return lRet
//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VGtPd
@description Validação do gatilho TFF_PRODUT seq 003

@since 		16/11/2021
@author		Kaique Schiller
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function At740VGtPd()
Return !Empty(M->TFF_PRODUT) .And. Posicione("SB1", 1, xFilial("SB1")+M->TFF_PRODUT, "B1_PRV1") <> 0
//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740iniOp
@description Localiza alguma alteração na parte operacional.

@since 		11/02/2022
@author		Kaique Schiller
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function At740AltOp(oMdl)
Local oMdlTFL 	 := oMdl:GetModel("TFL_LOC")
Local oMdlTFF 	 := oMdl:GetModel("TFF_RH")
Local oMdlTFH 	 := oMdl:GetModel("TFH_MC")
Local oMdlTFG 	 := oMdl:GetModel("TFG_MI")
Local lEditOp	 := .F.
Local cQueryTFL  := GetNextAlias()
Local cQueryTFF  := ""
Local cQueryTFH  := ""
Local cQueryTFG  := ""
Local aBenRev  	 := {}
Local nX		 := 0
Local nY		 := 0
Local nZ		 := 0
Local cCodAntTFF := ""

//Percorre os locais da revisão
For nX := 1 To oMdlTFL:Length()
	oMdlTFL:Goline(nX)
	If !lEditOp
		//Query para verifcar o local do orçamento antigo
		BeginSql Alias cQueryTFL
			COLUMN TFL_DTINI AS DATE
			COLUMN TFL_DTFIM AS DATE
			SELECT TFL.TFL_DTINI,
				   TFL.TFL_DTFIM
			FROM %Table:TFL% TFL
			WHERE
				TFL.TFL_FILIAL = %xFilial:TFL% AND
				TFL.TFL_CODSUB = %exp:oMdlTFL:GetValue("TFL_CODIGO")% AND
				TFL.%NotDel%
		EndSql
		If (cQueryTFL)->(!EOF())
			//Alteração opercional
			If oMdlTFL:GetValue("TFL_DTINI") != (cQueryTFL)->TFL_DTINI .Or.;
				oMdlTFL:GetValue("TFL_DTFIM") != (cQueryTFL)->TFL_DTFIM
				lEditOp := .T.
				Exit
			Endif
		Else
			lEditOp := .T.
			Exit
		Endif
		(cQueryTFL)->(DbCloseArea())
		If !lEditOp
			For nY := 1 To oMdlTFF:Length()
				oMdlTFF:Goline(nY)
				If !lEditOp
					cCodAntTFF:= ""
					cQueryTFF := GetNextAlias()
					BeginSql Alias cQueryTFF
						COLUMN TFF_PERINI AS DATE
						COLUMN TFF_PERFIM AS DATE
						SELECT TFF_COD,
							TFF_CODSUB,
							TFF_PERINI,
							TFF_PERFIM,
							TFF_QTDVEN,
							TFF_ESCALA
						FROM %Table:TFF% TFF
						WHERE
							TFF.TFF_FILIAL = %xFilial:TFF% AND
							TFF.TFF_CODSUB = %exp:oMdlTFF:GetValue("TFF_COD")% AND
							TFF.%NotDel%
					EndSql
					If (cQueryTFF)->(!EOF())
						//Alteração opercional
						If oMdlTFF:GetValue("TFF_PERINI") != (cQueryTFF)->TFF_PERINI .Or.;
							oMdlTFF:GetValue("TFF_PERFIM") != (cQueryTFF)->TFF_PERFIM .Or.;
							oMdlTFF:GetValue("TFF_QTDVEN") != (cQueryTFF)->TFF_QTDVEN .Or.;
							oMdlTFF:GetValue("TFF_ESCALA") != (cQueryTFF)->TFF_ESCALA
							lEditOp	:= .T.
							Exit
						Endif
						cCodAntTFF := (cQueryTFF)->TFF_COD
					Else
						lEditOp := .T.
						Exit
					Endif
					(cQueryTFF)->(DbCloseArea())
					If !lEditOp
						For nZ := 1 To oMdlTFH:Length()
							oMdlTFH:Goline(nZ)
							cQueryTFH  := GetNextAlias()
							BeginSql Alias cQueryTFH
								COLUMN TFH_PERINI AS DATE
								COLUMN TFH_PERFIM AS DATE
								SELECT TFH_COD,
									TFH_CODSUB,
									TFH_PERINI,
									TFH_PERFIM,
									TFH_QTDVEN
								FROM %Table:TFH% TFH
								WHERE
									TFH.TFH_FILIAL = %xFilial:TFH% AND
									TFH.TFH_CODSUB = %exp:oMdlTFH:GetValue("TFH_COD")% AND
									TFH.%NotDel%
							EndSql
							If (cQueryTFH)->(!EOF())
								If oMdlTFH:GetValue("TFH_PERINI") != (cQueryTFH)->TFH_PERINI .Or.;
									oMdlTFH:GetValue("TFH_PERFIM") != (cQueryTFH)->TFH_PERFIM .Or.;
									oMdlTFH:GetValue("TFH_QTDVEN") != (cQueryTFH)->TFH_QTDVEN
									lEditOp	:= .T.
									Exit
								Endif
							Else
								If !Empty(oMdlTFH:GetValue("TFH_PRODUT"))
									lEditOp := .T.
									Exit
								Endif
							Endif
							(cQueryTFH)->(DbCloseArea())
						Next nZ
					Endif
					If !lEditOp
						For nZ := 1 To oMdlTFG:Length()
							oMdlTFG:GoLine(nZ)
							cQueryTFG  := GetNextAlias()
							BeginSql Alias cQueryTFG
								COLUMN TFG_PERINI AS DATE
								COLUMN TFG_PERFIM AS DATE
								SELECT TFG_COD,
									TFG_CODSUB,
									TFG_PERINI,
									TFG_PERFIM,
									TFG_QTDVEN
								FROM %Table:TFG% TFG
								WHERE
									TFG.TFG_FILIAL = %xFilial:TFG% AND
									TFG.TFG_CODSUB = %exp:oMdlTFG:GetValue("TFG_COD")% AND
									TFG.%NotDel%
							EndSql
							If (cQueryTFG)->(!EOF())
								//Alteração opercional
								If oMdlTFG:GetValue("TFG_PERINI") != (cQueryTFG)->TFG_PERINI .Or.;
									oMdlTFG:GetValue("TFG_PERFIM") != (cQueryTFG)->TFG_PERFIM .Or.;
									oMdlTFG:GetValue("TFG_QTDVEN") != (cQueryTFG)->TFG_QTDVEN
									lEditOp	:= .T.
									Exit
								Endif
							Else
								If !Empty(oMdlTFG:GetValue("TFG_PRODUT"))
									lEditOp	:= .T.
									Exit
								Endif
							Endif
							(cQueryTFG)->(DbCloseArea())
						Next nZ
						If !lEditOp
							aBenRev := GetABenfs()
							For nZ := 1 to Len(aBenRev)
								If aBenRev[nZ][1]
									lEditOp := .T.
									Exit
								Else
									If SubsTring(aBenRev[nZ][7][1],1,6) == cCodAntTFF
										If aBenRev[nZ][2][1] != aBenRev[nZ][2][2] .Or.;
											aBenRev[nZ][3][1] != aBenRev[nZ][3][2] .Or.;
											aBenRev[nZ][4][1] != aBenRev[nZ][4][2] .Or.;
											aBenRev[nZ][5][1] != aBenRev[nZ][5][2] .Or.;
												aBenRev[nZ][6][1] != aBenRev[nZ][6][2] .Or.;
												aBenRev[nZ][8][1] != aBenRev[nZ][8][2] .Or.;
												aBenRev[nZ][9][1] != aBenRev[nZ][9][2] .Or.;
												aBenRev[nZ][10][1] != aBenRev[nZ][10][2] .Or.;
													aBenRev[nZ][11][1] != aBenRev[nZ][11][2] .Or.;
													aBenRev[nZ][12][1] != aBenRev[nZ][12][2] .Or.;
													aBenRev[nZ][13][1] != aBenRev[nZ][13][2] .Or.;
													aBenRev[nZ][14][1] != aBenRev[nZ][14][2] .Or.;
														aBenRev[nZ][15][1] != aBenRev[nZ][15][2] .Or.;
														aBenRev[nZ][16][1] != aBenRev[nZ][16][2] .Or.;
														aBenRev[nZ][17][1] != aBenRev[nZ][17][2] .Or.;
														aBenRev[nZ][18][1] != aBenRev[nZ][18][2] .Or.;
														aBenRev[nZ][19][1] != aBenRev[nZ][19][2]
											lEditOp	:= .T.
											Exit
										Endif
									Endif
								Endif
							Next nZ
						Endif
					Endif
				Endif
			Next nY
		Endif
	Endif
Next nX

Return lEditOp

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} a740AjDtEnc
@description Realiza o ajuste na data fim da TFF para itens encerrados que possuem agendas
após a data fim.

@since 		17/05/2022
@author		Luiz Gabriel
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function a740AjDtEnc(oMdlLoc,oMdlRh)
Local nY		:= 0
Local nZ 		:= 0
Local dDtAgd	:= CToD('')
Local dDtLoc	:= CToD('')
Local lDTEncTFF := FindFunction("TecEncDtFt") .AND. TecEncDtFt() .AND. !GSGetIns("LE")

If lDTEncTFF
	For nZ := 1 To oMdlLoc:Length()
		oMdlLoc:GoLine(nZ)
		dDtLoc := oMdlLoc:GetValue("TFL_DTFIM")
		For nY := 1 To oMdlRh:Length()
			oMdlRh:GoLine(nY)
			If oMdlRh:GetValue('TFF_ENCE') == '1' .And. Empty(oMdlRh:GetValue("TFF_DTENCE"))
				dDtAgd := A871DtEncF( oMdlRh )
				If dDtAgd > dDtLoc
					oMdlLoc:LoadValue('TFL_DTFIM',dDtAgd)
				EndIf
				If oMdlRh:GetValue('TFF_PERFIM') < dDtAgd
					oMdlRh:LoadValue('TFF_DTENCE',dDtAgd)
					oMdlRh:LoadValue('TFF_PERFIM',dDtAgd)
				EndIf
			EndIf
		Next nY
		oMdlRh:GoLine(1)
	Next nZ
	oMdlLoc:GoLine(1)
EndIf

Return

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} At740VlUni
Validação do código do produto de uniforme
@author Kaique Schiller
@since 07/06/2022
@return lRet, Logico, .T. Existe / .F. Não existe
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Function At740VlUni(cCodPrd)
Local lRet     := .T.
Local aAreaSB1 := {}

If !Empty(cCodPrd)
	aAreaSB1  := SB1->(GetArea())
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xFilial('SB1')+cCodPrd))
		lRet := .F.
		Help(' ', 1, 'REGNOIS')
	Else
		dbSelectArea('SB5')
		SB5->(dbSetOrder(1))//B5_FILIAL+B5_COD
		If !SB5->(dbSeek(xFilial('SB5')+cCodPrd)) .Or. SB5->B5_TPISERV<>'6'
			lRet := .F.
			Help(' ', 1, 'REGNOIS')
		EndIf
	EndIf
	RestArea(aAreaSB1)
Endif

Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} PreLinTXP
Validação de pré linha do grid de uniformes.
@author Kaique Schiller
@since 07/06/2022
@return lRet, Logico, .T./.F.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Function PreLinTXP(oMdlG,nLine,cAction, cCampo, xValue, xOldValue)
Local lRet      := .T.
Local oMdlFull := oMdlG:GetModel()
Local nValDel  := 0
local nValorPrd	:= 0
Local nTotAtual := 0
Local oMdlUse  := Nil
Local aSaveLines := FwSaveRows()
Local oView := FwViewActive()

If oMdlFull <> Nil .And. cAction != "CANSETVALUE"
	If lRet .And. !Empty(oMdlG:GetValue("TXP_CODUNI"))
		oMdlUse	:= oMdlFull:GetModel('TFF_RH')
		nValDel	:= oMdlG:GetValue('TXP_TOTGER')
		nTotAtual := oMdlUse:GetValue('TFF_TOTUNI')
		If cAction == 'DELETE'
			nTotAtual -= nValDel
		ElseIf cAction == 'UNDELETE'
			nTotAtual += nValDel
		Endif
		lRet := oMdlUse:SetValue('TFF_TOTUNI', nTotAtual) .Or. IsInCallStack('TEC740NFAC')
		FwRestRows(aSaveLines)
		If cAction == 'SETVALUE'
			If cCampo == 'TXP_PRCVEN' .AND. SuperGetMv("MV_ORCVLB1",,.F.)
				nValorPrd := POSICIONE("SB1",1,xFilial("SB1")+oMdlG:GetValue("TXP_CODUNI"),"B1_PRV1")
				If nValorPrd > 0 .AND. xValue < nValorPrd
					lRet	:= .F.
					Help( ,, 'PreLinTXP',, "Não é Possivel diminuir o valor do produto uma vez que o mesmo tem valor de venda no cadastro de produto.", 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If ValType(oView) == 'O' .And. oView:GetCurrentSelect()[1] == "VIEW_UNIF"
	oView:Refresh("VIEW_UNIF")
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTXP
	Load Data da grid de Uniforme (TXP)
@author		Kaique Schiller Olivero
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function AtLoadTXP(oMdl)
Local aRet := {}
Local cAliasTXP := ""
Local nLenFlds := 0
Local aAux := {}
Local oModel  := oMdl:GetModel()
Local oMdlRH  := oModel:GetModel('TFF_RH')
Local cCodPai := oMdlRH:GetValue('TFF_COD')
Local oStru   := oMdl:GetStruct()
Local nI      := 0
Local nVidMes := 1
Local aFields := {}
Local lVidMes := TXP->( ColumnPos('TXP_VIDMES') ) > 0
Local lQtdUni := TXP->( ColumnPos('TXP_QTDUNI') ) > 0
Local cQry    := ""
Local oQuery  := Nil

cQry := " SELECT TXP.R_E_C_N_O_ "
cQry += " FROM ? TXP "
cQry += " WHERE TXP.TXP_FILIAL = ? "
cQry += " AND TXP.TXP_CODTFF = ? "
cQry += " AND TXP.D_E_L_E_T_=' ' "
cQry := ChangeQuery( cQry )

oQuery := FwExecStatement():New(cQry)
oQuery:SetUnsafe( 1, RetSQLName("TXP") )
oQuery:SetString( 2, xFilial("TXP") )
oQuery:SetString( 3, cCodPai )

cAliasTXP := oQuery:OpenAlias()

If (cAliasTXP)->(!Eof())
	aStrFld := FWSX3Util():GetAllFields("TXP")
	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	While (cAliasTXP)->(!Eof())
		aAux := Array(nLenFlds)
		TXP->(DbGoTo((cAliasTXP)->R_E_C_N_O_))
		nVidMes := 1

		For nI := 1 To nLenFlds
			cField := aFields[nI, MODEL_FIELD_IDFIELD]

			If !aFields[nI, MODEL_FIELD_VIRTUAL]
				aAux[nI] := TXP->&(cField)
			Else
				If aScan(aStrFld, {|x|x==cField})
					aAux[nI] := CriaVar(cField, .T. )
					If cField == 'TXP_TOTAL'
						aAux[nI] := (TXP->TXP_QTDVEN * TXP->TXP_PRCVEN)
					ElseIf cField == 'TXP_DSCUNI'
						aAux[nI] := Posicione('SB1',1,xFilial('SB1')+TXP->TXP_CODUNI,'B1_DESC')
					ElseIf cField == 'TXP_TOTGER'
						If lVidMes .And. TXP->TXP_VIDMES > 0
							nVidMes := TXP->TXP_VIDMES
						EndIf
						If lQtdUni
							aAux[nI] := ((TXP->TXP_QTDUNI * TXP->TXP_PRCVEN) +  TXP->TXP_TXLUCR + TXP->TXP_TXADM)/nVidMes
						EndIf
					Else
						aAux[nI] := CriaVar(cField, .T. )
					EndIf
				EndIf
			EndIf
		Next nI

		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			Aadd(aRet,{0,aAux})
		Else
			Aadd(aRet,{(cAliasTXP)->R_E_C_N_O_,aAux})
		EndIf

		(cAliasTXP)->(DbSkip())
	EndDo
EndIf
(cAliasTXP)->(DbCloseArea())
oQuery:Destroy()
FwFreeObj(oQuery)

Return aRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} PreLinTXQ
Validação de pré linha do grid de armamento.
@author Kaique Schiller
@since 07/06/2022
@return lRet, Logico, .T./.F.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Function PreLinTXQ(oMdlG,nLine,cAction,cField,xValue,xOldValue)
Local lRet      := .T.
Local oMdlFull  := oMdlG:GetModel()
Local nValDel   := 0
Local nValorPrd	:= 0
Local nTotAtual := 0
Local oMdlUse   := Nil
Local lGsOrcArma:= FindFunction("TecGsArma") .And. TecGsArma()

If oMdlFull <> Nil
	If lRet .And. !Empty(oMdlG:GetValue("TXQ_CODPRD"))
		oMdlUse	:= oMdlFull:GetModel('TFF_RH')
		nValDel	:= oMdlG:GetValue('TXQ_TOTGER')
		nTotAtual := oMdlUse:GetValue('TFF_TOTARM')
		If cAction == 'DELETE'
			nTotAtual -= nValDel
		ElseIf cAction == 'UNDELETE'
			nTotAtual += nValDel
		Endif
		lRet := lRet .AND. oMdlUse:SetValue('TFF_TOTARM', nTotAtual ) .Or. IsInCallStack('TEC740NFAC')
		If cAction == 'SETVALUE'
			If cField == 'TXQ_PRCVEN' .AND. SuperGetMv("MV_ORCVLB1",,.F.)
				nValorPrd := POSICIONE("SB1",1,xFilial("SB1")+oMdlG:GetValue("TXQ_CODPRD"),"B1_PRV1")
				If nValorPrd > 0 .AND. xValue < nValorPrd
					lRet	:= .F.
					Help( ,, 'PreLinTXQ',, "Não é Possivel diminuir o valor do produto uma vez que o mesmo tem valor de venda no cadastro de produto.", 1, 0 ) //"Operação não permitida para itens encerrados. Por favor, inserir um valor menor do que o valor original do item"
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. (IsIncallStack('At870Revis') .OR. IsInCallStack("AT870PlaRe"))
	If cAction == 'DELETE'
		If lGsOrcArma
			If oMdlG:GetValue("TXQ_ITEARM") <> "3"
				If oMdlG:GetValue("TXQ_QTDAPO") > 0
					Help( " ", 1, "PreLinTXQ", Nil, STR0347, 1,,,,,,,{STR0348}) //"Essa linha não poderá ser excluída pois existe armamento movimentado" "Retorne o armamento movimentado"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	ElseIf cAction == "SETVALUE"
		If lGsOrcArma .And. cField == "TXQ_QTDVEN"
			If oMdlG:GetValue("TXQ_ITEARM") <> "3"
				If oMdlG:GetValue("TXQ_QTDAPO") > xValue
					Help( " ", 1, "PreLinTXQ", Nil, STR0349+cValTochar(oMdlG:GetValue("TXQ_QTDAPO"))+STR0350, 1,,,,,,,{STR0351}) //"Existem"+oMdlG:GetValue("TXQ_QTDAPO")+"armamentos desse item já movimentados, o novo valor atribuído não poderá ser menor.""Essa linha não poderá ser excluída pois existe armamento movimentado" "Retorne o armamento movimentado"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Endif
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlArm
	Valid do campo TXQ_CODARM
@author		Kaique Schiller Olivero
@since		23/06/2022
/*/
//-------------------------------------------------------------------------------
Function At740VlArm(cTip, cCod)
Local lRet 	 := .T.
Local aArea	 := {}
Default cTip := ""
Default cCod := ""

If !Empty(cTip)
	If !Empty(cCod)
		aArea := GetArea()
		DbSelectArea('SB5')
		SB5->( DbSetOrder( 1 ) ) //B5_FILIAL+B5_COD
		If !(SB5->( DbSeek( xFilial('SB5')+cCod ) ) .And. SB5->B5_TPISERV == cTip )
			lRet := .F.
			Help(,, "At740VlArm",,STR0332,1,0,,,,,,{STR0333}) //"Esse produto não está configurado conforme o tipo escolhido."#"Preencha o campo com o produto configurado corretamente."
		EndIf
		RestArea(aArea)
	Endif
Else
	lRet := .F.
	Help(,, "At740VlArm",,STR0334,1,0,,,,,,{STR0335}) //"Não é permitido preencher o campo código de armamento com o campo item armamento em branco."#"Preencha o campo de item do armamento."
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTXQ
	Load Data da grid de Armamento (TXQ)
@author		Kaique Schiller Olivero
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function AtLoadTXQ(oMdl)
Local aRet := {}
Local cAliasTXQ := ""
Local nLenFlds := 0
Local aAux := {}
Local oModel  := oMdl:GetModel()
Local oMdlRH  := oModel:GetModel('TFF_RH')
Local cCodPai := oMdlRH:GetValue('TFF_COD')
Local oStru   := oMdl:GetStruct()
Local nI      := 0
Local nVidMes := 1
Local aFields := {}
Local aStrFld := {}
Local lVidMes := TXQ->( ColumnPos('TXQ_VIDMES') ) > 0
Local cQry    := ""
Local oQuery  := Nil

cQry := " SELECT TXQ.R_E_C_N_O_ "
cQry += " FROM ? TXQ "
cQry += " WHERE TXQ.TXQ_FILIAL = ? "
cQry += " AND TXQ.TXQ_CODTFF = ? "
cQry += " AND TXQ.D_E_L_E_T_=' ' "
cQry := ChangeQuery( cQry )

oQuery := FwExecStatement():New(cQry)
oQuery:SetUnsafe( 1, RetSQLName("TXQ") )
oQuery:SetString( 2, xFilial("TXQ") )
oQuery:SetString( 3, cCodPai )

cAliasTXQ := oQuery:OpenAlias()

If (cAliasTXQ)->(!Eof())
	aStrFld := FWSX3Util():GetAllFields("TXQ")
	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	While (cAliasTXQ)->(!Eof())
		aAux := Array(nLenFlds)
		TXQ->(DbGoTo((cAliasTXQ)->R_E_C_N_O_))
		nVidMes := 1

		For nI := 1 To nLenFlds
			cField := aFields[nI, MODEL_FIELD_IDFIELD]

			If !aFields[nI, MODEL_FIELD_VIRTUAL]
				aAux[nI] := TXQ->&(cField)
			Else
				If aScan(aStrFld, {|x|x==cField})
					aAux[nI] := CriaVar(cField, .T. )
					If cField == 'TXQ_TOTAL'
						aAux[nI] := (TXQ->TXQ_QTDVEN * TXQ->TXQ_PRCVEN)
					ElseIf cField == 'TXQ_DSCPRD'
						aAux[nI] := Posicione('SB1',1,xFilial('SB1')+TXQ->TXQ_CODPRD,'B1_DESC')
					ElseIf cField == 'TXQ_TOTGER'
						If lVidMes .And. TXQ->TXQ_VIDMES > 0
							nVidMes := TXQ->TXQ_VIDMES
						EndIf
						aAux[nI] := ((TXQ->TXQ_QTDVEN * TXQ->TXQ_PRCVEN) +  TXQ->TXQ_TXLUCR + TXQ->TXQ_TXADM)/nVidMes
					Else
						aAux[nI] := CriaVar(cField, .T. )
					EndIf
				EndIf
			EndIf
		Next nI

		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			Aadd(aRet,{0,aAux})
		Else
			Aadd(aRet,{(cAliasTXQ)->R_E_C_N_O_,aAux})
		EndIf

		(cAliasTXQ)->(DbSkip())
	EndDo
EndIf
(cAliasTXQ)->(DbCloseArea())
oQuery:Destroy()
FwFreeObj(oQuery)

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740FilArm
	Filtro da consulta padrão TXQ_CODARM, TXW_CODPRD
@author		Kaique Schiller Olivero
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function At740FilArm()
Local cFiltro := "@#"
Local cTip := ""

If IsInCallStack("TECA984A")
	cTip := FwFldGet("TXW_ITEARM")
Else
	cTip := FwFldGet("TXQ_ITEARM")
Endif

cFiltro += '(SB5->B5_FILIAL == "' + xFilial("SB5")  +'" .And. SB5->B5_TPISERV == "' + cTip+ '" )'

Return cFiltro+"@#"

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc}
    @description Retorna o numero da sequencia da escala, de acordo com o codigo da escala
    @author Natacha Romeiro
    @since 28/07/22
    @return
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Function At740SeqEsc(cEscala)
Local cAlias 		:= GetNextAlias()
Local nSeqEsc 		:= 0

BeginSql Alias cAlias
	SELECT COUNT(*) SEQUENCIA
	FROM  %table:TDX% TDX
	WHERE TDX.TDX_FILIAL = %xFilial:TDX%
	  AND TDX.TDX_CODTDW = %exp:cEscala%
	  AND TDX.%NotDel%
EndSql

If (cAlias)->(!EOF())
	nSeqEsc := (cAlias)->SEQUENCIA
EndIf
(cAlias)->(DbCloseArea())

Return nSeqEsc

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc}
    @description @description Retorna o numero da sequencia do turno, de acordo com o codigo do turno.
    @author Natacha Romeiro
    @since 28/07/22
    @return
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Function At740SeqTurn(cTurno)
Local cAlias 		:= GetNextAlias()
Local nSeqTurn 		:= 0

BeginSql Alias cAlias
	SELECT MAX(SPJ.PJ_SEMANA) SEQUENCIA
		FROM %table:SPJ% SPJ
		INNER JOIN %table:SR6% SR6 ON SR6.R6_TURNO = SPJ.PJ_TURNO
			AND SR6.R6_FILIAL = %xFilial:SR6%
			AND SR6.%NotDel%
		WHERE SPJ.%NotDel%
			AND  SPJ.PJ_TURNO = %exp:cTurno%
			AND  SPJ.PJ_FILIAL = %xFilial:SPJ%
		EndSql

	If (cAlias)->(!EOF())
		nSeqTurn := Val((cAlias)->SEQUENCIA)
	EndIf
	(cAlias)->(DbCloseArea())

Return nSeqTurn

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740QtdAloc
@description  Retorna a Quantidade de Alocaçoes previstas na Escala
@param nRet, Numeric, Quantidade de Alocaçoes previstas na Escala
@author flavio.vicco
@since 31/03/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740QtdAloc(cEscala)
Local lQtdAloc := TDW->( ColumnPos("TDW_QTDALO")) > 0
Local cAlias   := ""
Local nRet     := 0

If lQtdAloc
	cAlias := GetNextAlias()

	BeginSql Alias cAlias
		SELECT TDW_QTDALO
		FROM  %table:TDW% TDW
		WHERE TDW.TDW_FILIAL = %xFilial:TDW%
		AND TDW.TDW_COD = %exp:cEscala%
		AND TDW.%NotDel%
	EndSql

	If (cAlias)->(!EOF())
		nRet := (cAlias)->TDW_QTDALO
	EndIf
	(cAlias)->(DbCloseArea())
EndIf

Return nRet

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Função resposavel por calcular e retornar a quantidade prevista de pessoas no posto.
@author Natacha Romeiro
@since	27/06/22
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function AtCalcPrev()
//Local lGerVag		:= (TFF->(ColumnPos('TFF_GERVAG')) > 0)
Local lQtdAloc		:= TDW->( ColumnPos("TDW_QTDALO")) > 0
Local lGerVag		:= .T.
Local nQtVend 		:= FwFldGet("TFF_QTDVEN")
Local cTurno  		:= FwFldGet("TFF_TURNO")
Local cEscala 		:= FwFldGet("TFF_ESCALA")
Local nSeqEscala	:= 0
Local nQtdAloc		:= 0
Local nRet			:= 0

If (TFF->(ColumnPos('TFF_GERVAG')) > 0)
    If FwFldGet("TFF_GERVAG") == '2'
        lGerVag := .F.
    EndIf
EndIf

If lGerVag .AND. nQtVend > 0
    If !Empty(cEscala)
        If lQtdAloc
            nQtdAloc := At740QtdAloc(cEscala)
            nRet := nQtdAloc * nQtVend
        EndIf
        If nQtdAloc == 0
            nSeqEscala = At740SeqEsc(cEscala)
            nRet := nSeqEscala * nQtVend
        EndIf
    ElseIf !Empty(cTurno)
        nSeqEscala = At740SeqTurn(cTurno)
        nRet := nSeqEscala * nQtVend
    Else
        nRet := nQtVend
    EndIf
EndIf

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At174TXR
	Função executada no gatilho do código do facilitador para captura da descrição

@sample 	At174TXR()

@since		27/07/2022
@version	P12.1.2210
/*/
//------------------------------------------------------------------------------
Function At174TXR()
Local cRet 		:= ' '
Local oMdl 		:= FwModelActive()
Local oMdlTWO 	:= oMdl:GetModel("TWODETAIL")
Local aArea		:= GetArea()

DbSelectArea('TXR')
TXR->( DbSetOrder( 1 ) )

If TXR->( DbSeek( xFilial("TXR") +Alltrim(oMdlTWO:GetValue("TWO_CODFAC"))) )
	cRet := TXR->TXR_DESC
EndIf

RestArea(aArea)

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740WhCb
	Edição do campo TFF_QTDTIP, TFF_VLRCOB, TFF_VLRPRP
@author Kaique Schiller
@sample 	At740WhCb()
@since		20/09/2022
/*/
//------------------------------------------------------------------------------
Function At740WhCb(cCampo)
Local lRet := .T.
Default cCampo := ""

If cCampo == "TFF_QTDTIP"
	If Val(FwFldGet("TFF_TPCOBR")) <= Val("02")
		lRet := .F.
	Endif
Elseif cCampo == "TFF_VLRCOB"
	If Val(FwFldGet("TFF_TPCOBR")) < Val("02") .OR. Val(FwFldGet("TFF_TPCOBR")) == Val("03")
		lRet := .F.
	Endif
Elseif cCampo == "TFF_VLRPRP"
	If Val(FwFldGet("TFF_TPCOBR")) <= Val("02")
		lRet := .F.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ClPrp
	Gatilho do campo do calculo do valor proposto e do calculo de valor cobrado
@author Kaique Schiller
@sample 	At740ClPrp()
@since		20/09/2022
/*/
//------------------------------------------------------------------------------
Function At740ClPrp(cTipo,nTotal,cCampo,cEscala,cTurno,nPrcVen)
Local nRet := 0
Local nQtdHrs := 0
Local oView := Nil
Default nTotal := 0
Default cEscala := ""
Default cTurno := ""
Default nPrcVen	:= 0

If cTipo == "01" .Or. cTipo == "03" //Contrato ou Outros Tipos
	If cCampo == "TFF_VLRCOB"
		nRet := nTotal
		If ((TFF->(ColumnPos('TFF_GERPLA')) > 0) .And. FwFldGet("TFF_GERPLA") > 0);
			.OR. isInCallStack('At998ExPla') .OR. isInCallStack('At998MdPla')
			nRet := FwFldGet("TFF_GERPLA")
		Endif
	Endif
Elseif cTipo == "02" //Valor
	If cCampo == "TFF_VLRPRP" .Or. cCampo == "TFF_VLRCOB"
		nQtdHrs := At740HrDia(cEscala,cTurno)
		If nQtdHrs > 0
			nRet := (nPrcVen/221)/nQtdHrs
		Endif
	Endif
Endif

oView := FwViewActive()

If ValType( oView ) == "O" .And. oView:GetModel():GetId() == "TECA740" .And. !IsInCallStack( "InitDados" ) .And. !IsInCallStack( "TECXFPOPUP" )
	If oView:GetCurrentSelect()[1] == 'TFF_RH'
		oView:Refresh( 'TFF_RH' )
	EndIf
EndIf

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740HrDia
	Quantidade de horas do dia da escala ou turno
@author Kaique Schiller
@sample 	At740HrDia()
@since		28/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At740HrDia(cEscala,cTurno)
Local cAliasQuery := ""
Local nHrIni	:= 0
Local nHrFim 	:= 0
Local dDataFim	:= sTod("")
Local cDiaSem	:= ""
Local nHrTotDia := 0
Default cEscala := ""
Default cTurno := ""

If !Empty(cEscala)
	cAliasQuery := GetNextAlias()
	BeginSql Alias cAliasQuery
		SELECT 	TGW.TGW_DIASEM,
				TGW.TGW_HORINI,
				TGW.TGW_HORFIM
		FROM %table:TDX% TDX
		INNER JOIN %table:TGW% TGW ON TGW.TGW_FILIAL = %xFilial:TGW%
			AND TGW.TGW_EFETDX = TDX.TDX_COD
			AND TGW.TGW_STATUS = '1'
			AND TGW.%NotDel%
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
		AND TDX.TDX_CODTDW = %exp:cEscala%
		AND TDX.%NotDel%
		ORDER BY TGW.TGW_EFETDX, TGW.TGW_DIASEM
	EndSql
	While (cAliasQuery)->(!EOF())
		If Empty(cDiaSem)
			cDiaSem := (cAliasQuery)->TGW_DIASEM
		Endif

		If cDiaSem <> (cAliasQuery)->TGW_DIASEM
			Exit
		Else
			If dDataFim == sTod("")
				nHrIni := (cAliasQuery)->TGW_HORINI
			Endif
			nHrFim :=  (cAliasQuery)->TGW_HORFIM
			If nHrIni >= nHrFim
				dDataFim := dDataBase+1
			Else
				dDataFim := dDataBase
			Endif
		Endif
		(cAliasQuery)->(dbSkip())
	EndDo
	If dDataFim <> sTod("")
		nHrTotDia := SubtHoras(dDataBase,TecConvhr(nHrIni),dDataFim,TecConvhr(nHrFim))
	Endif
	(cAliasQuery)->(DbCloseArea())
Elseif !Empty(cTurno)
	cAliasQuery := GetNextAlias()
	BeginSql Alias cAliasQuery
		SELECT 	SPJ.PJ_HRTOTAL
		FROM  %table:SPJ% SPJ
		WHERE SPJ.PJ_FILIAL = %xFilial:SPJ%
			AND SPJ.PJ_TURNO = %exp:cTurno%
			AND SPJ.PJ_TPDIA = 'S'
			AND SPJ.%NotDel%
	EndSql
	If (cAliasQuery)->(!EOF())
		nHrTotDia := (cAliasQuery)->PJ_HRTOTAL
	Endif
	(cAliasQuery)->(DbCloseArea())
Endif

Return nHrTotDia
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740Prcif
	Precificação com planilha
@author Kaique Schiller
@sample 	At740Prcif()
@since		04/11/2022
/*/
//------------------------------------------------------------------------------
Static Function At740Prcif()
Return SuperGetMv("MV_GSITORC",,"2") == "1" .And. FindFunction("TecGsPrecf") .And. TecGsPrecf()

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExecAutoRS
	Inicia ExecAuto(RSPA100.PRW - RSP100Inc) para o Recrutamento e Seleção (Módulo 20)
	@param	oModel = TECA740
	@return	Lógico
	@since	03/04/2023
	@Jack Junior
/*/
//------------------------------------------------------------------------------
Static Function ExecAutoRS(oModel)
Local aRotAuto := {}
Local cUserName:= UsrFullName(RetCodUsr())
Local lRet	   := .T.
Local nX 	   := 0
Local nY	   := 0
Local oMdlTFF  := oModel:GetModel("TFF_RH")
Local oMdlTFL  := oModel:GetModel("TFL_LOC")

Private lMsErroAuto := .F.
Private INCLUI 		:= .T.

Begin Transaction

For nX := 1 to oMdlTFL:Length() //Locais de atendimento
	oMdlTFL:GoLine(nX)

	For nY := 1 To oMdlTFF:Length() //Postos - Itens de RH
		oMdlTFF:GoLine(nY)
		aRotAuto := {}

		cDescFun := AllTrim(Posicione("SRJ",1,xFilial("SRJ")+oMdlTFF:GetValue("TFF_FUNCAO"),"RJ_DESC"))

		If oMdlTFF:GetValue("TFF_GERVAG") == "1" .And. oMdlTFF:GetValue("TFF_QTDVAG") > 0
			Aadd( aRotAuto, { "QS_FILIAL" , xFilial("SQS"), Nil })
			Aadd( aRotAuto, { "QS_DESCRIC", cDescFun, Nil })
			Aadd( aRotAuto, { "QS_CC"     , Posicione("ABS",1,xFilial("ABS")+oMdlTFL:GetValue("TFL_LOCAL"),"ABS_CCUSTO"), Nil })
			Aadd( aRotAuto, { "QS_FUNCAO" , oMdlTFF:GetValue("TFF_FUNCAO"), Nil })
			Aadd( aRotAuto, { "QS_NRVAGA" , oMdlTFF:GetValue("TFF_QTDVAG"), Nil })
			Aadd( aRotAuto, { "QS_SOLICIT", cUserName, Nil })
			Aadd( aRotAuto, { "QS_DTABERT", dDataBase, Nil })
			Aadd( aRotAuto, { "QS_TIPO"   , "1", Nil }) //1 - Interna/Externa ; 2 - Interna ; 3 - Externa
			Aadd( aRotAuto, { "QS_CODTFF" , oMdlTFF:GetValue("TFF_COD"), Nil })
			Aadd( aRotAuto, { "QS_FILTFF" , oMdlTFF:GetValue("TFF_FILIAL"), Nil })
			Aadd( aRotAuto, { "QS_PERFIL", " ", Nil })
			Aadd( aRotAuto, { "QS_CLIENTE", Posicione("TFJ",1,xFilial("TFJ")+oMdlTFL:GetValue("TFL_CODPAI"),"TFJ_CODENT"), Nil })

			//chamada ExecAuto
			MSExecAuto({|v,x,y,z| RSP100Inc(v,x,y,z)},"SQS",0,3,aRotAuto)

			If lMsErroAuto
				lRet := .F.
				MostraErro()
				DisarmTransaction()
				Exit
			EndIf
		EndIf
	Next nY
Next nX

End Transaction

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT740VldRS
	Verificação da existencia dos campos no dicionário
	Recrutamento e Seleção
	@return	Lógico
	@since	04/04/2023
	@Jack Junior
/*/
//------------------------------------------------------------------------------
Function AT740VldRS()
Local lRet := .T.

DbSelectArea("TFF")
DbSelectArea("SQS")

If !(TFF->(ColumnPos("TFF_QTDVAG")) > 0 .And. (SQS->(ColumnPos("QS_FILTFF")) > 0);
   .And. (SQS->(ColumnPos("QS_CODTFF")) > 0))
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT740VlVag
	1- Validação se gera vagas;
	2- Validação de quantidade do TFF_QTDVAG
	@Param nPrevVaga - Número de vagas previstas
		   nSolicVaga -Número de vagas solicitadas
		   nGeraVaga - 1- Gera vaga; 2-Não gera
	@return	Lógico
	@since	04/04/2023
	@Jack Junior
/*/
//------------------------------------------------------------------------------
Function AT740VlVag(nPrevVaga,nSolicVaga,nGeraVaga)
Local lRet := .T.

If lRet
	If nGeraVaga == "2" .And. nSolicVaga <> 0
		lRet := .F.
		Help(,,"AT740VlVag",,STR0343,1,0) //"Esse Posto está configurado para não gerar vagas."
	EndIf
EndIf

If lRet
	If nPrevVaga < nSolicVaga
		lRet := .F.
		Help(,,"AT740VlVag",,STR0344,1,0) //"A solicitação de vagas não pode ser maior que a alocação prevista para o posto."
	EndIf
EndIf

Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlPla
@description Validacao da Config. Planilha de Precos
@param  oModel, Objeto, modelo de dados da tabela TFF
@return Lógico
@author flavio.vicco
@since 17/04/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At740VlPla(oModel, cCampo, xValueNew, nLine, xValueOld)
Local lRet    := .T.
Local aArea   := GetArea()
Local cFuncao := oModel:GetValue("TFF_FUNCAO")
Local cPlaCod := oModel:GetValue("TFF_PLACOD")
Local cFiltro := "(ABW->ABW_ULTIMA=='1' .And. (Empty(ABW->ABW_FUNCAO) .Or. ABW->ABW_FUNCAO=='"+cFuncao+"'))"

If !Empty(cPlaCod)
	DbSelectArea("ABW")
	ABW->(DbSetFilter({||&cFiltro},cFiltro))
	ABW->(DbGoTop())
	ABW->(DbSetOrder(1)) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
	If !ABW->(DbSeek(xFilial("ABW")+cPlaCod))
		HELP(" ", 1,"REGNOIS")
		lRet := .F.
	EndIf
	ABW->(DbClearFilter())
EndIf

RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740FilPla
@description Filtro da consulta padrao de Config. Planilha Precos
@param  Nenhum
@return Lógico
@author flavio.vicco
@since 17/04/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740FilPla()
Local cFiltro := "@#"
Local lPrecif := At740Prcif()

If lPrecif
	cFiltro += 'ABW->ABW_ULTIMA=="1" .And. (Empty(ABW->ABW_FUNCAO) .Or. ABW->ABW_FUNCAO==FwFldGet("TFF_FUNCAO"))'
EndIf

Return cFiltro+"@#"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740TrgPla
@description Filtro do gatilho de Config. Planilha Precos
@param  Nenhum
@return Lógico
@author flavio.vicco
@since 17/04/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740TrgPla(cPlaCod,cFuncao)
Local cRet    := ""
Local aArea   := GetArea()
Local cFiltro := "(ABW->ABW_ULTIMA=='1' .And. !Empty(ABW->ABW_CODTCW) .And. (Empty(ABW->ABW_FUNCAO) .Or. ABW->ABW_FUNCAO=='"+cFuncao+"'))"

If !Empty(cPlaCod)
	DbSelectArea("ABW")
	ABW->(DbSetFilter({||&cFiltro},cFiltro))
	ABW->(DbGoTop())
	ABW->(DbSetOrder(1)) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
	If ABW->(DbSeek(xFilial("ABW")+cPlaCod))
		cRet := ABW->ABW_REVISA
	EndIf
	ABW->(DbClearFilter())
EndIf

RestArea(aArea)
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740PlLot
	Executa a planilha em lote
@author Kaique Schiller
@sample 	At740PlLot()
@since		14/04/2023
/*/
//------------------------------------------------------------------------------
Function At740PlLot(oMdl)

Processa({|| ExecAtuLot(oMdl)}, STR0387)//"Reprocessando Planilha de Preços..."

Return

/*/{Protheus.doc} At740RegPc
	Regra do gatilho do campo TFF_PRCVEN
@type  Function
@author Kaique Schiller
@since 08/05/2023
/*/
Function At740RegPc()

Return (((FwFldGet('TFF_QTDVEN')*FwFldGet('TFF_PRCVEN'))+FwFldGet("TFF_VLRMAT"))*(1-(FwFldGet('TFF_DESCON')/100)))

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740UpdPl
	Atualiza planilha de preço no delete ou undelete da linha ABP
	Atualiza Valores do posto no delete ou undelete da linha ABP
@author 	jack junior
@sample 	at740UpdPl()
@param		cAcao --> "DELETE" ou "UNDELETE"
@since		07/06/2023
/*/
//------------------------------------------------------------------------------
Function at740UpdPl(cAcao, oMdlABP, oMdlFull, xValue)
Local cPlanXML 	:= ""
Local cXMLNew	:= ""
Local nTotRh	:= 0
Local nTotPlan	:= 0
Local nValor	:= 0
Local oPlaTFF	:= Nil
Local oMdlRH 	:= oMdlFull:GetModel("TFF_RH")
Local oView 	:= FwViewActive()

Default xValue := 0

cPlanXML := oMdlRH:GetValue("TFF_CALCMD")
cNickABP := oMdlABP:GetValue("ABP_NICKPO")

If cAcao == "DELETE"
	nValor := 0
ElseIf cAcao == "UNDELETE"
	nValor := oMdlABP:GetValue("ABP_VALOR")
ElseIf cAcao == "SETVALUE"
	nValor := xValue
EndIf

oPlaTFF := FWUIWorkSheet():New(,.F.,,20,"PLAN_ATT")
oPlaTFF:LoadXmlModel(cPlanXML)

If oPlaTFF:CellExists(AllTrim(cNickABP))
	oPlaTFF:SetCellValue(AllTrim(cNickABP),cvaltochar(nValor))
EndIf

If oPlaTFF:CellExists("TOTAL_CUSTOS")
	nTotRh := oPlaTFF:GetCellValue("TOTAL_CUSTOS")
Elseif oPlaTFF:CellExists("TOTAL_CUSTO")
	nTotRh := oPlaTFF:GetCellValue("TOTAL_CUSTO")
Endif
If oPlaTFF:CellExists("TOTAL_BRUTO")
	nTotPlan := oPlaTFF:GetCellValue("TOTAL_BRUTO")
Endif

cXMLNew := oPlaTFF:GetXmlModel(,,,,.F.,.T.,.F.)

oMdlRh:SetValue("TFF_CALCMD",cXMLNew)
oMdlRh:SetValue("TFF_PRCVEN",Round(nTotRh, TamSX3("TFF_PRCVEN")[2]))
oMdlRh:SetValue("TFF_TOTPLA",Round(nTotPlan, TamSX3("TXS_TOTPLA")[2]))

oView:Refresh("VIEW_RH")

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ApliLuc
Atualiza planilha de preço no setvalue da linha TFF/TFL
@author 	flavio.vicco
@sample 	At740ApliLuc()
@param		[xValue],Indefinido,Novo valor inserido no campo.
@param		[xOldValue],Indefinido,Antigo valor do campo.
@param		[lAllRH],Logico,processa todos Postos?
@since		16/06/2023
/*/
//------------------------------------------------------------------------------
Static Function At740ApliLuc(xValue,xOldValue,lAllRH,cCampo)
Local aArea := GetArea()
Local aSaveLines := FWSaveRows()
Local oMdl    := FwModelActive()
Local oMdlRh  := oMdl:GetModel("TFF_RH")
Local oView   := FwViewActive()
Local nX      := 0
Local nLine   := 0
Local lRet    := .F.
Local cMsg    := STR0356 //"Aplicar Margem de Lucro nos postos que possuem planilha de preços?"
Local cMark   := ""

Default xValue := 0
Default lAllRH := .F.
Default cCampo := "TFL_PLUCRO"

cMark := PesqPict(SUBSTR(cCampo, 1, 3),cCampo)

If !lAllRH
	cMsg := STR0359+LTrim(Transform(xOldValue,cMark))+STR0360+LTrim(Transform(xValue,cMark))+STR0361 //"Alterar Margem de Lucro de "###" % para "###" % para este posto?"
EndIf

If (lRet := IIF(IsBlind() .OR. IsInCallStack("TECA870F"), .T.,  MsgYesNo(cMsg, STR0357))) //"Margem de Lucro"
	If lAllRH
		nLine := oMdlRh:GetLine()
		For nX := 1 to oMdlRh:Length()
			oMdlRh:GoLine(nX)
			If oMdlRh:GetValue("TFF_VLFIXO") == 0 .And. At740ProcLuc(oMdlRh,xValue)
				// Atualiza Percentual na linha do Posto TFF
				oMdlRh:LoadValue("TFF_PLUCRO",xValue)
			EndIf
		Next nX
		oMdlRh:GoLine(nLine)
		If ValType( oView ) == "O" .AND. ( oView:GetModel():GetId() == "TECA740" )
			oView:Refresh("VIEW_RH")
		EndIf
	Else
		If At740ProcLuc(oMdlRh,xValue)
			If ValType( oView ) == "O" .AND. ( oView:GetModel():GetId() == "TECA740" )
				oView:Refresh("VIEW_RH")
			EndIf
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ProcLuc
Atualiza planilha de preço no setvalue da linha TFF/TFL
@author 	flavio.vicco
@sample 	At740ProcLuc()
@param		[oMdlRh],Objeto,modelo de dados da tabela TFF
@param		[nPLucro],Numero,Margem de Lucro
@since		16/06/2023
/*/
//------------------------------------------------------------------------------
Static Function At740ProcLuc(oMdlRh,nPLucro)
Local oPlaTFF := Nil
Local cPlanXML:= ""
Local cXMLNew := ""
Local nTotPlan:= 0
Local lRet    := .F.

If !Empty(oMdlRh:GetValue("TFF_CALCMD"))
	cPlanXML := oMdlRH:GetValue("TFF_CALCMD")
	oPlaTFF  := FWUIWorkSheet():New(,.F.,,20,"PLAN_ATT")
	oPlaTFF:LoadXmlModel(cPlanXML)
	If oPlaTFF:CellExists(AllTrim("TX_LR"))
		oPlaTFF:SetCellValue(AllTrim("TX_LR"),cvaltochar(nPLucro))
	EndIf
	If oPlaTFF:CellExists("TOTAL_BRUTO")
		nTotPlan := oPlaTFF:GetCellValue("TOTAL_BRUTO")
	EndIf
	cXMLNew := oPlaTFF:GetXmlModel(,,,,.F.,.T.,.F.)
	oMdlRh:SetValue("TFF_CALCMD",cXMLNew)
	oMdlRh:SetValue("TFF_TOTPLA",Round(nTotPlan, FwTamSX3("TXS_TOTPLA")[2]))
	oMdlRh:LoadValue("TFF_VLFIXO",Round(0, FwTamSX3("TXS_TOTPLA")[2]))
	lRet := .T.
EndIf

If lRet .AND. ExistBlock('a740MarC')
	lRet := ExecBlock('a740MarC', .F., .F., {cPlanXML, cXMLNew, oMdlRh } )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740VbRun
MsgRun da atualização de aba de Verbas de Folha
@author 	jack.junior
@param
@since		22/06/2023
/*/
//------------------------------------------------------------------------------
Function at740VbRun(lPlan, cLocal, cFuncao, cPlan, cRev, oFWSheet)
Local lTecItExtOp := IsInCallStack("At190dGrOrc")
Default oFWSheet := Nil

If !lTecItExtOp
	If IsInCallStack("ExecAtuLot") .OR. IsInCallStack("At998Expla") .OR. IsInCallStack("At998MdPla")
		at740VbCCT(lPlan, cLocal, cFuncao, cPlan, cRev, oFWSheet)
	Else
		FwMsgRun(Nil,{||at740VbCCT(lPlan, cLocal, cFuncao, cPlan, cRev, oFWSheet)},Nil, "Carregando Verbas de Folha...")//"Carregando dados..."
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740VbCCT

Carrega grid de Verbas de Folha (ABZDETAIL) ao preencher os
campos TFF_FUNCAO ou executar planilha de preços

@author 	jack.junior
@param		lPlan - .T. - Planilha de preço / .F. - Gatilho campo TFF_FUNCAO
			cLocal - Código do local de atendimento do Posto
			cFuncao - Código da Função
			cXml - Xml da planilha
@since		22/06/2023
/*/
//------------------------------------------------------------------------------
Static Function at740VbCCT(lPlan, cLocal, cFuncao, cPlan, cRev, oFWSheet)
Local aVerbas := {}
Local nX      := 0
Local oMdl740 := Nil
Local oMdlABZ := Nil
Local oView   := FwViewActive()

oMdl740 := FwModelActive()
oMdlRH	:= oMdl740:GetModel("TFF_RH")
oMdlABZ := oMdl740:GetModel("ABZDETAIL")

at740ABZ(oMdlABZ,.F.) //Permissão alteração Grid ABZ - Verbas de Folha

oMdlABZ:GoLine(1)

atCleanABZ(oMdl740,oMdlABZ) //Limpeza do Grid ABZ - Verbas de Folha

If !lPlan .And. Empty(oMdlRH:GetValue("TFF_PLACOD"))
	If !Empty(cLocal) .And. !Empty(cFuncao)
		aVerbas := at740DadoF(cLocal, cFuncao) //Carrega Verbas de Folha - Sem Configuração de Cálculo:
	EndIf
ElseIf !Empty(oMdlRH:GetValue("TFF_PLACOD"))
	aVerbas := at740DadoP(cPlan,cRev,oMdl740,lPlan,oFWSheet) //Carrega Verbas de Folha - Com Planilha e Configuração de Cálculo:
EndIf

//Preenche GRID ABZ - Verbas de Folha
If Len(aVerbas) > 0
	For nX := 1 To Len(aVerbas)
		If oMdlABZ:SeekLine({{"ABZ_FILSRV",xFilial("SRV")},{"ABZ_CODSRV",AllTrim(aVerbas[nX][1])}},.T.)
			If oMdlABZ:IsDeleted()
				oMdlABZ:UnDeleteLine()
			EndIf
		Else
			If !Empty(oMdlABZ:GetValue("ABZ_CODSRV"))
				oMdlABZ:AddLine()
			EndIf
			oMdlABZ:SetValue("ABZ_FILSRV",xFilial("SRV")) //FILIAL SRV
			oMdlABZ:SetValue("ABZ_CODSRV",aVerbas[nX][1]) //CODIGO DA VERBA (SRV)
			oMdlABZ:SetValue("ABZ_DESCRI",aVerbas[nX][2]) //DESCRICAO DA VERBA
			oMdlABZ:SetValue("ABZ_FILCCT",xFilial("SWY")) //FILIAL CCT
			oMdlABZ:SetValue("ABZ_CCTCOD",aVerbas[nX][3]) //CODIGO CCT
			oMdlABZ:SetValue("ABZ_PERC"  ,aVerbas[nX][4]) //PERCENTUAL DA VERBA (SRV)
		EndIf
	Next nX
EndIf

oMdlABZ:GoLine(1)

If !IsInCallStack("TECXFPOPUP") .And. !IsInCallStack("TECA870F") .AND. !isBlind()
	oView:Refresh('ABZDETAIL')
EndIf

at740ABZ(oMdlABZ,.T.) //Retira Permissão de alteração Grid ABZ - Verbas de Folha

If lPlan
	oMdlRh:LoadValue( "TFF_LEGEND", "BR_VERDE" )
	nLine := oMdlRh:GetLine()
	For nX := 1 To oMdlRh:Length()
		oMdlRh:GoLine(nX)
		If !Empty(oMdlRh:GetValue( "TFF_PLACOD" ) ) .And. AllTrim( oMdlRh:GetValue( "TFF_LEGEND" ) ) == "BR_BRANCO"
			oMdlRh:LoadValue( "TFF_LEGEND", "BR_VERMELHO" )
		EndIf
	Next nX
	oMdlRh:GoLine(nLine)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740DadoF

Retorna array com verbas na CCT de acordo com a função e base operacinal

@author 	jack.junior
@param		cLocal - Código do local de atendimento do Posto
			cFuncao- Código da Função
@Return		aVerbas
@since		23/06/2023
/*/
//------------------------------------------------------------------------------
Static Function at740DadoF(cLocal, cFuncao)
Local cBaseOP  := ""
Local cCodCCT  := ""
Local cTabTemp := ""
Local aVerbas  := {}

cBaseOP := Posicione("ABS", 1, xFilial("ABS")+cLocal, "ABS_BASEOP" ) //ABS_FILIAL+ABS_LOCAL

If !Empty(cBaseOP)
	cTabTemp := GetNextAlias()
	//QUERY RETORNA CCT SE TIVER FUNÇÃO E BASE OPERACIONAL ASSOCIADAS
	BeginSql Alias cTabTemp

		SELECT SWY.WY_CODIGO
		FROM %Table:SWY% SWY
			INNER JOIN %Table:REI% REI ON
									//REI_FILIAL+REI_FILCCT+REI_CODCCT - INDEX 1
									REI.REI_FILIAL = %xFilial:REI%
									AND REI.REI_FILCCT = %xFilial:AA0%
									AND REI.REI_CODCCT = SWY.WY_CODIGO
									AND REI.%NotDel%
			INNER JOIN %Table:RI4% RI4 ON
									//RI4_FILCCT+RI4_CODCCT - INDEX 1
									RI4.RI4_FILIAL = %xFilial:RI4%
									AND RI4.RI4_CODCCT = SWY.WY_CODIGO
									AND RI4.%NotDel%
		WHERE
				SWY.WY_FILIAL = %xFilial:SWY%
				AND REI.REI_CODAA0 = %Exp:cBaseOP%
				AND RI4.RI4_CODSRJ = %Exp:cFuncao%
				AND SWY.%notDel%

	EndSql

	If (cTabTemp)->(!EOF())
		cCodCCT := (cTabTemp)->WY_CODIGO
	EndIf

	(cTabTemp)->(DbCloseArea())

	If !Empty(cCodCCT)
		cTabTemp := GetNextAlias()
		//SE TIVER CCT - RETORNA DADOS DAS VERBAS DE FOLHA
		BeginSql Alias cTabTemp

			SELECT SRV.RV_COD, SRV.RV_DESC, SRV.RV_TIPO, SRV.RV_PERC
			FROM %Table:SRV% SRV
				INNER JOIN %Table:REB% REB ON
										//RI4_FILCCT+RI4_CODCCT - INDEX 1
										REB.REB_FILIAL = %xFilial:REB%
										AND REB.REB_CODSRV = SRV.RV_COD
										AND REB.%NotDel%
			WHERE
					SRV.RV_FILIAL = %xFilial:SRV%
					AND REB.REB_CODCCT = %Exp:cCodCCT%
					AND SRV.%notDel%

		EndSql

		While (cTabTemp)->(!EOF())
			Aadd(aVerbas, {(cTabTemp)->RV_COD,;
							(cTabTemp)->RV_DESC,;
							cCodCCT,;
							(cTabTemp)->RV_PERC})

			(cTabTemp)->(dbSkip())
		EndDo

		(cTabTemp)->(DbCloseArea())
	EndIf
EndIf

Return aVerbas

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740DadoP

Retorna array com verbas obrigatórias da Configuração de Cálculo e
Verbas adicionadas em Verbas Adicionais - Folha (F8)

@author 	jack.junior
@param		cPlan - Código da Planilha de preço
			cRev - Código da Revisão da Planilha
@Return		aVerbas
@since		23/06/2023
/*/
//------------------------------------------------------------------------------
Static Function at740DadoP(cPlan, cRev, oMdl740, lPlan, oFWSheet)
Local aVerbas  := {}
Local cConfCal := ""
Local cTabTemp := ""
Local cXmlPlan := ""
Local nX	   := 0
Local oPlanXml := Nil

If !Empty(cPlan)
	cConfCal := Posicione("ABW", 1, xFilial("ABW")+cPlan+cRev, "ABW_CODTCW")
	cCodCCT := Posicione("TCW", 1, xFilial("TCW")+cConfCal, "TCW_CODCCT")
	cXmlPlan := oMdl740:GetModel("TFF_RH"):GetValue("TFF_CALCMD")

	If !Empty(cConfCal)
		cTabTemp := GetNextAlias()
		BeginSql Alias cTabTemp

			SELECT TCX.TCX_CODTBL, SRV.RV_DESC, SRV.RV_TIPO, SRV.RV_PERC, TCX.TCX_NICKPO, TCX.TCX_NICK
			FROM %Table:TCX% TCX
				INNER JOIN %Table:SRV% SRV ON
										//RV_FILIAL+RV_COD - INDEX 1
										SRV.RV_FILIAL = %xFilial:SRV%
										AND SRV.RV_COD = TCX.TCX_CODTBL
										AND SRV.%NotDel%
			WHERE
					TCX.TCX_FILIAL = %xFilial:TCX%
					AND TCX.TCX_CODTBL != ' '
					AND TCX.TCX_CODTCW = %Exp:cConfCal%
					AND TCX.TCX_TIPOPE = '1' //ABA MÃO DE OBRA
					AND TCX.TCX_OBRGT != '2'
					AND TCX.%notDel%
		EndSql

		If ValType(oFWSheet) == 'O' .And. MethIsMemberOf(oFWSheet,"LoadXmlModel")
			oPlanXml := oFWSheet
		Else
			oPlanXml := FWUIWorkSheet():New(,.F.,,11,"PLAN_LOAD")
			oPlanXml:LoadXmlModel(cXmlPlan)
		EndIf

		While (cTabTemp)->(!EOF())
			If !Empty((cTabTemp)->TCX_NICK) .And.;
			oPlanXml:CellExists(AllTrim((cTabTemp)->TCX_NICK)) .And.;
			!Empty(oPlanXml:GetCellValue(AllTrim((cTabTemp)->TCX_NICK))) .And.;
			IIF(Alltrim(oPlanXml:GetCellValue(AllTrim((cTabTemp)->TCX_NICK))) == "0", .F., oPlanXml:GetCellValue(AllTrim((cTabTemp)->TCX_NICK)) > 0 )//oPlanXml:GetCellValue(AllTrim((cTabTemp)->TCX_NICK)) > 0
				Aadd(aVerbas, {AllTrim((cTabTemp)->TCX_CODTBL),;
								AllTrim((cTabTemp)->RV_DESC),;
								cCodCCT,;
								(cTabTemp)->RV_PERC,;
								AllTrim((cTabTemp)->TCX_NICKPO)})
			EndIf
			(cTabTemp)->(dbSkip())
		EndDo

		(cTabTemp)->(DbCloseArea())
	EndIf


	If !lPlan //Se for Troca de Função (TFF_FUNCAO) - Manter Verbas já adicionadas na Planilha (TFF_CALCMD)
		//Verificar na planilha se tem a verba não obrigatória já adicionada:
		If !Empty(cXmlPlan) .And. !Empty(cConfCal)
			aVerbConf := at740QryCC(cConfCal) //Verbas Não obrigatórias

			If Len(aVerbConf) > 0
				aAux := at740VPlan(aVerbConf, oPlanXml)

				If Len(aAux) > 0
					For nX := 1 To Len(aAux)
						Aadd(aVerbas, {aAux[nX][1],;
							aAux[nX][2],;
							aAux[nX][3],;
							aAux[nX][4],;
							aAux[nX][5]})
					Next nX
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return aVerbas

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740ABZ

Liga/Desliga propriedades de alteração das linhas do grid ABZ

@author 	jack.junior
@param		oMdlABZ - Grid ABZ
			lTurn   - Booleano liga(.F.)/desliga(.T.) alterações das linhas
@Return		aVerbas
@since		23/06/2023
/*/
//------------------------------------------------------------------------------
Function at740ABZ(oMdlABZ,lTurn)

oMdlABZ:SetNoInsertLine(lTurn)
oMdlABZ:SetNoUpdateLine(lTurn)
oMdlABZ:SetNoDeleteLine(lTurn)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} atCleanABZ

Deleta linhas do grid ABZ ou Limpa modelo todo (Inclusão)

@author 	jack.junior
@param		oMdlABZ - Grid ABZ
			oMdl740 - Orçamento
@Return
@since		26/06/2023
/*/
//------------------------------------------------------------------------------
Static Function atCleanABZ(oMdl740, oMdlABZ)
Local nX := 0

If oMdl740:GetOperation() == MODEL_OPERATION_INSERT
	oMdlABZ:ClearData(.F.,.T.)
Else
	For nX := 1 To oMdlABZ:Length()
		If !Empty(oMdlABZ:GetValue("ABZ_CODSRV"))
			oMdlABZ:GoLine(nX)
			oMdlABZ:DeleteLine()
		EndIf
	Next nX
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740QryCC

Retorna Array de todas as verbas não obrigatórias da Configuração de Cálculo

@author 	jack.junior
@param		cConfCal - Código da Configuração de Cálculo
@Return		aVerbConf - Verbas não obrigatórias
@since		28/06/2023
/*/
//------------------------------------------------------------------------------
Static Function at740QryCC(cConfCal)
Local cTabTemp  := ""
Local aVerbConf := {}

cTabTemp := GetNextAlias()
BeginSql Alias cTabTemp

	SELECT TCX.TCX_CODTBL, TCX.TCX_DESCRI, TCX.TCX_PORCEN, TCX.TCX_NICKPO
	FROM %Table:TCX% TCX
	WHERE
			TCX.TCX_FILIAL = %xFilial:TCX%
			AND TCX.TCX_TIPTBL = '1'
			AND TCX.TCX_CODTCW = %Exp:cConfCal%
			AND TCX.TCX_TIPOPE = '1' //ABA MÃO DE OBRA
			AND TCX.TCX_OBRGT = '2'
			AND TCX_NICKPO != ' '
			AND TCX.%notDel%
EndSql

While (cTabTemp)->(!EOF())
	Aadd(aVerbConf, {AllTrim((cTabTemp)->TCX_CODTBL),;
					AllTrim((cTabTemp)->TCX_DESCRI),;
					"",;
					(cTabTemp)->TCX_PORCEN,;
					AllTrim((cTabTemp)->TCX_NICKPO)})

	(cTabTemp)->(dbSkip())
EndDo

(cTabTemp)->(DbCloseArea())

Return aVerbConf

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740VPlan

Verifica se existe a verba na planilha com valor maior que 0

@author 	jack.junior
@param		aVerbConf - Array de Verbas Não obrigatórias Config Calc.
			oPlanXml - Planilha de Preços do Posto
@Return		aAux - Verbas não obrigatórias adicionadas na planilha (Valor > 0)
@since		26/06/2023
/*/
//------------------------------------------------------------------------------
Static Function at740VPlan(aVerbConf, oPlanXml)
Local nX		:= 0
Local nValPlan 	:= 0
Local aAux		:= {}

For nX := 1 To Len(aVerbConf)
	If oPlanXml:CellExists(AllTrim(aVerbConf[nX][5]))
		nValPlan := oPlanXml:GetCellValue(aVerbConf[nX][5])
		If ValType(nValPlan) != "N" //Tratamento para typemismatch:
			nValPlan := Val(nValPlan)
		EndIf
		If nValPlan != 0
			Aadd(aAux, {aVerbConf[nX][1],;
						aVerbConf[nX][2],;
						aVerbConf[nX][3],;
						aVerbConf[nX][4],;
						aVerbConf[nX][5]})
		EndIf
	EndIf
Next nX

Return aAux

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ApliVlr
Atualiza planilha de preço no setvalue da linha TFF/TFL
@author 	flavio.vicco
@sample 	At740ApliVlr()
@param		[xValue],Indefinido,Novo valor inserido no campo.
@param		[xOldValue],Indefinido,Antigo valor do campo.
@since		26/06/2023
/*/
//------------------------------------------------------------------------------
Static Function At740ApliVlr(xValue,xOldValue)
Local oPlaTFF   := Nil
Local cPlanXML  := ""
Local cFormula  := ""
Local cPLucro	:= ""
Local cPicLucro	:= ""
Local nAliqImp  := 0
Local nValemSImp:= 0
Local nTxLcr    := 0
Local nTotMargem:= 0
Local nPLucro   := 0
Local nTotPerc	:= 0
Local lRet      := .F.
Local oMdl      := FwModelActive()
Local oMdlRh    := oMdl:GetModel("TFF_RH")
Local oError    := ErrorBlock( {||At740ErrForm()} )

If !Empty(oMdlRh:GetValue("TFF_CALCMD"))
	cPlanXML := oMdlRH:GetValue("TFF_CALCMD")
	oPlaTFF  := FWUIWorkSheet():New(,.F.,,20,"PLAN_ATT")
	oPlaTFF:LoadXmlModel(cPlanXML)
	If oPlaTFF:CellExists("ALIQ_IMPOSTOS")
		nAliqImp := oPlaTFF:GetCellValue("ALIQ_IMPOSTOS")
	EndIf
	If oPlaTFF:CellExists("TOTAL_CUSTO")
		nTotCustos := oPlaTFF:GetCellValue("TOTAL_CUSTO")
	EndIf
	If oPlaTFF:CellExists("ALIQ_TAXAS")
		nTotPerc := oPlaTFF:GetCellValue("ALIQ_TAXAS")
	EndIf
	If oPlaTFF:CellExists("TX_LR")
		nTxLcr := oPlaTFF:GetCellValue("TX_LR")
		If ValType(nTxLcr)=="C"
			nTxLcr := val(nTxLcr)
		EndIf
	EndIf

	nTotPerc -= nTxLcr
	// Formula de calculo do Total Bruto
	cFormula := Alltrim(oPlaTFF:oFWFormula:GetCell("TOTAL_BRUTO"):Formula)
	If !Empty(cFormula)
		cFormula := StrTran(cFormula,"TOTAL_LIQUIDO",cValToChar(xValue))
		cFormula := StrTran(cFormula,"ALIQ_IMPOSTOS",cValToChar(nAliqImp))
		cFormula := StrTran(cFormula,"/","*",1,1)
		cFormula := StrTran(cFormula,"=","")
		BEGIN SEQUENCE
			nValemSImp := &(cFormula)
		END SEQUENCE
		ErrorBlock(oError)
		If ValType(nValemSImp)=="N"
			// Margem Contribuicao
			nTotMargem := (1 - (nTotCustos / nValemSImp)) * 100
			// Margem de Lucro
			nPLucro    := nTotMargem - IIF(nTotPerc < 0, 0, nTotPerc)
			nPLucro := Round(nPLucro, TamSX3('TFF_PLUCRO')[2])
			cPicLucro := PesqPict( "TFF", "TFF_PLUCRO")
			cPLucro	:= Transform(nPLucro, cPicLucro) 
			//Verifica se o valor difere da picture do campo TFF_PLUCRO:
			If "*" $ cPLucro
				lRet := .F.
				cPLucro := AllTrim(Transform(nPLucro, "@E 9999999999999999999999999.99"))
				If isInCallStack("At998MdPla") .Or. isInCallStack("At998ExPla")
					FwAlertHelp(oMdlRh:GetId(), STR0388+" ("+cPLucro+")" + CRLF + STR0389+AllTrim(Str(Len(cPLucro)))+".")
				Else
					oMdl:SetErrorMessage(oMdlRh:GetId(),,oMdlRh:GetId(),,"At740ApliVlr",STR0388+" ("+cPLucro+")",STR0389+AllTrim(Str(Len(cPLucro)))+".")//"O resultado não pode ser inserido porque excede o limite de tamanho do campo disponível."#"Contate o administrador do sistema para alterar o tamanho do campo TFF_PLUCRO para pelo menos "
				EndIf
			Else
				lRet := oMdlRh:SetValue("TFF_PLUCRO",nPLucro)
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ErrForm
Tratamento de erro na formula de calculo
@author 	flavio.vicco
@sample 	At740ErrForm()
@since		26/06/2023
/*/
//------------------------------------------------------------------------------
Static Function At740ErrForm()
Local cMsgUsr := ""

cMsgUsr += STR0362 //"Para a funcionalidade do campo seja executada corretamente, "
cMsgUsr += STR0363 //"corrija as informações na configuração da tabela de precificação!"
Help(,, "AT740ERRFORM",, cMsgUsr, 1, 0)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740Func
@description Filtro da consulta padrao de Funções
@param  Nenhum
@return Character
@author Anderson F. Gomes
@since 01/09/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740Func()
Local cFiltro := ""
Local cFuncContr := ""
Local oModel := FwModelActive()
Local oMdlTFF := oModel:GetModel("TFF_RH")
Local lTecItExtOp := IsInCallStack("At190dGrOrc")
Local nLine := 0
Local nX := 0

If lTecItExtOp .And. oMdlTFF:Length() > 0
	nLine := oMdlTFF:GetLine()
	cFuncContr += "("
	For nX := 1 To oMdlTFF:Length()
		oMdlTFF:GoLine( nX )
		If !(oMdlTFF:GetValue( 'TFF_FUNCAO' ) $ cFuncContr) .And. nX <> nLine
			cFuncContr += IIf( nX > 1, " .Or. ", "" ) + "SRJ->RJ_FUNCAO == '" + oMdlTFF:GetValue( 'TFF_FUNCAO' ) +"'"
		EndIf
	Next nX
	cFuncContr += ")"
	oMdlTFF:GoLine( nLine )

	cFiltro := "@#" + cFuncContr + "@#"
EndIf

Return cFiltro

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740NvFac
@description Verifica se os novos campos para o Facilitador de Orçamento existem na base.
@param  Nenhum
@return Logical
@author Anderson F. Gomes
@since 15/09/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At740NvFac()
Local lRet := .F.

If TWO->( ColumnPos('TWO_CODRH') ) > 0 .And. TWO->( ColumnPos('TWO_ITEMRH') ) > 0
	lRet := .T.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CalendGatilho(oSubTFL,cCampo,xConteudo)
	Gatilho que realiza a atualização do identificador (código) do calendário de feriados do local de atendimento 
	(Grid Local de Atendimento) para o posto (Grid RH)
@param	oSubTFL: 	Objeto, instância da classe FwFormGridModel com o submodelo que pode ser tanto da tabela TFL   
		quanto da tabela TFF.
		cCampo:		Caractere, identificador do campo que disparou o gatilho.
		xConteudo:	Caractre, conteúdo que está em memória para o campo da variável cCampo

@return	cRet: 	 Caractere, ou código do calendário, ou descrição do calendário
@author Fernando Radu Muscalu 
@since 10/11/2023
@objeto do uso: Criado para atender a demanda da issue DSERSGS-17319
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CalendGatilho(oSubTFL,cCampo,xConteudo)

	Local cRet		:= ""
	Local cCalend	:= ""
	
	Local nI		:= 0
	Local nLinTFF	:= 0

	Local oSubTFF	:= Nil
	Local oView		:= Nil

	Local bWhen		:= {||}
	
	If ( cCampo == "TFL_LOCAL" )

		cRet := xConteudo

		cCalend	:= ABS->(GetAdvFVal("ABS","ABS_CALEND",XFilial("ABS") + xConteudo,1,""))		
		
		//Se entrou na recursão, então retorna o código do calendário
		//ao invés do próprio código do local de atendimento (TFL_LOCAL)
		If ( FwIsInCallStack("CalendGatilho") )
			cRet := cCalend
		EndIf

		oSubTFF	:= oSubTFL:GetModel():GetModel("TFF_RH")
		
		bWhen := oSubTFF:GetStruct():GetProperty("TFF_CALEND",MODEL_FIELD_WHEN)
		
		oSubTFF:GetStruct():setProperty("TFF_CALEND",MODEL_FIELD_WHEN,{||.T.})
		
		nLinTFF	:= oSubTFF:GetLine()

		For nI := 1 to oSubTFF:Length()
			
			oSubTFF:GoLine(nI)

			If ( oSubTFF:GetValue("TFF_GERVAG") == "1" )
				oSubTFF:SetValue("TFF_CALEND",cCalend)
			EndIf	

		Next nI

		oSubTFF:GoLine(nLinTFF)	
		
		oSubTFF:GetStruct():setProperty("TFF_CALEND",MODEL_FIELD_WHEN,bWhen)

		oView := FwViewActive()

		If !isBlind() .AND. ( oView:GetModel():GetId() == "TECA740" )
			oView:Refresh("VIEW_RH")
		EndIf

	ElseIf ( cCampo == "TFF_GERVAG" )
		
		If ( xConteudo == "2" )
			cRet := " "
			oSubTFL:GetModel():GetModel('TFF_RH'):LoadValue("TFF_DSCALE","")
		Else			
			cRet := CalendGatilho(oSubTFL:GetModel():GetModel('TFL_LOC'),"TFL_LOCAL",oSubTFL:GetModel():GetModel('TFL_LOC'):GetValue("TFL_LOCAL"))
		EndIf

	EndIf

Return(cRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CalendInicia(oSubTFF,cCampo)
	Inicializador padrão para os campos:
	TFF_CALEND (Código de Calendário de feriados)
	TFF_DSCALE (Descrição do calendário de feriados)

@param  	oSubTFF: 	Objeto, instância da classe FwFormGridModel com o submodelo que pode ser tanto da tabela TFF.
			cCampo:		Caractere, identificador do campo que será inicializado.

@return		cCalend: 	Caractere, ou código do calendário, ou descrição do calendário
@author	Fernando Radu Muscalu 
@since 10/11/2023
@objeto do uso: Criado para atender a demanda da issue DSERSGS-17319
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CalendInicia(oSubTFF,cCampo)

	Local cCalend	:= ""

	Local oSubTFL	:= oSubTFF:GetModel():GetModel("TFL_LOC")

	If ( cCampo == "TFF_CALEND" )

		If ( !Empty(oSubTFL:GetValue("TFL_LOCAL")) )
			cCalend	:= ABS->(GetAdvFVal("ABS","ABS_CALEND",XFilial("ABS") + oSubTFL:GetValue("TFL_LOCAL"),1,""))
		EndIf
	
	ElseIf ( cCampo == "TFF_DSCALE" .And. oSubTFF:GetLine() > 0 )
		
		If ( !Empty(oSubTFF:GetValue("TFF_CALEND")) )
			cCalend	:= AC0->(GetAdvFVal("AC0","AC0_DESC",XFilial("AC0") + oSubTFF:GetValue("TFF_CALEND"),1,""))
		EndIf
		
	EndIf

Return(cCalend)
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TemCalend(oSubTFF)
	Avalia se o local de atendimento (cadastro ABS) possui um calendário de feriado vinculado a ele.
	Esta função é utilizada para quando o usuário deseja editar o campo (WHEN). Se houver vínculo com calendário, o
	campo TFF_CALEND não poderá ser editado.
@param	 oSubTFF: 	Objeto, instância da classe FwFormGridModel com o submodelo que pode ser tanto da tabela TFF.

@return	lRet: Lógico, .T. o campo TFF_CALEND está livre para editar, .F. bloqueado para edição
@author Fernando Radu Muscalu
@since 10/11/2023
@objeto do uso: Criado para atender a demanda da issue DSERSGS-17319
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TemCalend(oSubTFF)

	Local lRet	:= .T.

	Local oSubTFL	:= oSubTFF:GetModel():GetModel("TFL_LOC")

	If ( !Empty(oSubTFL:GetValue("TFL_LOCAL")) )
		lRet	:= Empty(ABS->(GetAdvFVal("ABS","ABS_CALEND",XFilial("ABS") + oSubTFL:GetValue("TFL_LOCAL"),1,"")))
	EndIf
	
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740F3Fnc
@description F3 para o campo 
@param  Nenhum
@return Logical
@author Anderson F. Gomes
@since 16/11/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740F3Fnc()
Local oModel := FwModelActive()
Local oMdlTFL := oModel:GetModel('TFL_LOC')
Local oBrowse := Nil
Local oDlgTela := Nil
Local lRet := .F.
Local lQryCCT := .F.
Local cLocAtend := oMdlTFL:GetValue( 'TFL_LOCAL' )
Local cAls := GetNextAlias()
Local cQry := ""
Local cChgQry := ""
Local cAliasQry := ""
Local aIndex := {}
Local aSeek := { { STR0367, { { STR0368, "C", GetSx3Cache( "RJ_FUNCAO", "X3_TAMANHO" ), 0, "", , } } } }	// STR0367 - "Funções" \ STR0368 - "Função"
Local nSuperior	:= 0
Local nEsquerda	:= 0
Local nInferior	:= 0
Local nDireita := 0

cQry := " SELECT AA0.AA0_DESCRI, SWY.WY_CODIGO, SWY.WY_DESC, SRJ.RJ_FUNCAO, SRJ.RJ_DESC " + CRLF
cQry += " FROM " + RetSqlName( "ABS" ) + " ABS " + CRLF
cQry += " INNER JOIN " + RetSqlName( "AA0" ) + " AA0 ON " + FWJoinFilial("ABS", "AA0") + " AND AA0.AA0_CODIGO = ABS.ABS_BASEOP AND AA0.D_E_L_E_T_ = ' ' " + CRLF
cQry += " INNER JOIN " + RetSqlName( "REI" ) + " REI ON REI.REI_FILCCT = AA0.AA0_FILIAL AND REI.REI_CODAA0 = AA0.AA0_CODIGO AND REI.D_E_L_E_T_ = ' ' " + CRLF
cQry += " INNER JOIN " + RetSqlName( "SWY" ) + " SWY ON SWY.WY_FILIAL = REI.REI_FILCCT AND SWY.WY_CODIGO = REI.REI_CODCCT AND SWY.D_E_L_E_T_ = ' ' " + CRLF
cQry += " INNER JOIN " + RetSqlName( "RI4" ) + " RI4 ON RI4.RI4_FILCCT = REI.REI_FILCCT AND RI4.RI4_CODCCT = SWY.WY_CODIGO AND RI4.D_E_L_E_T_ = ' ' " + CRLF
cQry += " INNER JOIN " + RetSqlName( "SRJ" ) + " SRJ ON SRJ.RJ_FILIAL = RI4.RI4_FILSRJ AND SRJ.RJ_FUNCAO = RI4.RI4_CODSRJ AND SRJ.D_E_L_E_T_ = ' ' " + CRLF
If lTemRUK
	cQryRuk := cQry
	cQryRuk += " INNER JOIN " + RetSqlName( "RUK" ) + " RUK ON " + FWJoinFilial("SWY", "RUK") + " AND RUK.RUK_CODCCT = SWY.WY_CODIGO AND RUK.RUK_ESTADO = SWY.WY_ESTADO AND RUK.RUK_CODMUN = ABS.ABS_CODMUN AND RUK.D_E_L_E_T_ = ' ' " + CRLF
	cQryRuk += " WHERE AA0.AA0_FILIAL = '" + FwxFilial( "AA0" ) + "' AND ABS.ABS_LOCAL = '" + cLocAtend + "' AND ABS.D_E_L_E_T_ = ' ' " + CRLF
	cQryRuk += " ORDER BY SRJ.RJ_FUNCAO, SWY.WY_CODIGO " + CRLF
EndIf
cQry += " WHERE AA0.AA0_FILIAL = '" + FwxFilial( "AA0" ) + "' AND ABS.ABS_LOCAL = '" + cLocAtend + "' AND ABS.D_E_L_E_T_ = ' ' " + CRLF
cQry += " AND RI4.RI4_FILSRJ = '" + FwxFilial( "SRJ" ) + "' "
cQry += " ORDER BY SRJ.RJ_FUNCAO, SWY.WY_CODIGO " + CRLF

If lTemRUK
	oStatement := FWPreparedStatement():New( ChangeQuery( cQryRuk ) )
	cChgQry := oStatement:GetFixQuery()
	cAliasQry := GetNextAlias()
	MPSysOpenQuery( cChgQry, cAliasQry )
	If (cAliasQry)->( !Eof() )
		cQry := cQryRuk
		lQryCCT := .T.
	EndIf
EndIf

If !lQryCCT
	If lTemRUK
		(cAliasQry)->(DbCloseArea())
		oStatement:Destroy()
		FwFreeObj( oStatement )
	EndIf
	oStatement := FWPreparedStatement():New( ChangeQuery( cQry ) )
	cChgQry := oStatement:GetFixQuery()
	cAliasQry := GetNextAlias()
	MPSysOpenQuery( cChgQry, cAliasQry )
	If (cAliasQry)->( !Eof() )
		lQryCCT := .T.
	EndIf
EndIf
(cAliasQry)->(DbCloseArea())
oStatement:Destroy()
FwFreeObj( oStatement )

AAdd( aIndex, "RJ_FUNCAO" )

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800
If !isBlind()
	If lQryCCT
		DEFINE MSDIALOG oDlgTela TITLE OemTOAnsi( STR0367 ) FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL	// STR0367 - "Funções"

		oBrowse := FWFormBrowse():New()
		oBrowse:SetOwner( oDlgTela )
		oBrowse:SetDataQuery()
		oBrowse:SetAlias( cAls )
		oBrowse:SetQueryIndex( aIndex )
		oBrowse:SetQuery( cQry )
		oBrowse:SetSeek( , aSeek )
		oBrowse:SetDescription( OemTOAnsi( STR0367 ) ) // STR0367 - "Funções"
		oBrowse:SetMenuDef("")
		oBrowse:DisableDetails()
		oBrowse:SetDoubleClick({ || cRetFunc := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T. ,oDlgTela:End()})
		oBrowse:AddButton( OemTOAnsi( STR0369 ), {|| cRetFunc := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T., oDlgTela:End() } ,, 2 ) // STR0369 - "Confirmar"
		oBrowse:AddButton( OemTOAnsi( STR0370 ), {|| cRetFunc := "", oDlgTela:End() } ,, 2 ) // STR0370 - "Cancelar"
		oBrowse:SetUseFilter( .T. )
		oBrowse:SetProfileID("SRJCCT1")

		ADD COLUMN oColumn DATA {|| RJ_FUNCAO}  TITLE OemTOAnsi( STR0371 ) SIZE GetSx3Cache( "RJ_FUNCAO", "X3_TAMANHO" ) OF oBrowse // STR0371 - "Cód. Função"
		ADD COLUMN oColumn DATA {|| RJ_DESC}  TITLE OemTOAnsi( STR0368 ) SIZE GetSx3Cache( "RJ_DESC", "X3_TAMANHO" ) OF oBrowse // STR0368 - "Função"
		ADD COLUMN oColumn DATA {|| WY_CODIGO}  TITLE OemTOAnsi( STR0372 ) SIZE GetSx3Cache( "WY_CODIGO", "X3_TAMANHO" ) OF oBrowse // STR0372 - "Cód. CCT"
		ADD COLUMN oColumn DATA {|| WY_DESC}  TITLE OemTOAnsi( STR0373 ) SIZE GetSx3Cache( "WY_DESC", "X3_TAMANHO" ) OF oBrowse // STR0373 - "CCT"
		ADD COLUMN oColumn DATA {|| AA0_DESCRI} TITLE OemTOAnsi( STR0374 ) SIZE GetSx3Cache( "AA0_DESCRI", "X3_TAMANHO" ) OF oBrowse // STR0374 - "Local"
		oBrowse:Activate()
		ACTIVATE MSDIALOG oDlgTela CENTERED
	Else
		cQry := " SELECT SRJ.RJ_FUNCAO, SRJ.RJ_DESC FROM " + RetSqlName( "SRJ" ) + " SRJ WHERE SRJ.RJ_FILIAL = '" + FwxFilial( "SRJ" ) + "' AND SRJ.D_E_L_E_T_ = ' ' ORDER BY SRJ.RJ_FUNCAO " + CRLF

		DEFINE MSDIALOG oDlgTela TITLE OemTOAnsi( STR0367 ) FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL	// STR0367 - "Funções"

		oBrowse := FWFormBrowse():New()
		oBrowse:SetOwner( oDlgTela )
		oBrowse:SetDataQuery()
		oBrowse:SetAlias( cAls )
		oBrowse:SetQueryIndex( aIndex )
		oBrowse:SetQuery( cQry )
		oBrowse:SetSeek( , aSeek )
		oBrowse:SetDescription( OemTOAnsi( STR0367 ) ) // STR0367 - "Funções"
		oBrowse:SetMenuDef("")
		oBrowse:DisableDetails()
		oBrowse:SetDoubleClick({ || cRetFunc := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T. ,oDlgTela:End()})
		oBrowse:AddButton( OemTOAnsi( STR0369 ), {|| cRetFunc := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T., oDlgTela:End() } ,, 2 ) // STR0369 - "Confirmar"
		oBrowse:AddButton( OemTOAnsi( STR0370 ), {|| cRetFunc := "", oDlgTela:End() } ,, 2 ) // STR0370 - "Cancelar"
		oBrowse:SetUseFilter( .T. )
		oBrowse:SetProfileID("SRJCCT2")

		ADD COLUMN oColumn DATA {|| RJ_FUNCAO}  TITLE OemTOAnsi( STR0371 ) SIZE GetSx3Cache( "RJ_FUNCAO", "X3_TAMANHO" ) OF oBrowse // STR0371 - "Cód. Função"
		ADD COLUMN oColumn DATA {|| RJ_DESC}  TITLE OemTOAnsi( STR0368 ) SIZE GetSx3Cache( "RJ_DESC", "X3_TAMANHO" ) OF oBrowse // STR0368 - "Função"
		oBrowse:Activate()
		ACTIVATE MSDIALOG oDlgTela CENTERED
	EndIf
EndIf

Return( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740FunRt
@description Retorno da Consulta Específica At740F3Fnc
@param  Nenhum
@return Character
@author Anderson F. Gomes
@since 16/11/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740FunRt()
Return cRetFunc

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VGtPd
@description Validação do gatilho TFF_PRODUT seq 003

@since 		16/11/2021
@author		Kaique Schiller
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function At740VLPR(cCampo)
Return !Empty(M->&(cCampo)) .And. Posicione("SB1", 1, xFilial("SB1")+M->&(cCampo), "B1_PRV1") <> 0

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT740VLDP
@description Gatilho generico para retornar campo dos Produtos

@since 		29/02/2024
@author		Augusto Albuquerque
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
Function AT740VLDP(cCampo, cRegra)
Return !Empty(M->&(cCampo)) .And. Posicione("SB1", 1, xFilial("SB1")+M->&(cCampo), cRegra) <> 0

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740VlLoc
@description Valida as Funções de acordo com o município vinculado a Local / CCT
@param  Nenhum
@return Character
@author Anderson F. Gomes
@since 01/03/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740VlLoc()
Local cLocAtend As Character
Local cQry As Character
Local cVlPadFun As Character
Local cVlPadDFun As Character
Local oModel As Object
Local oMdlTFL As Object
Local oMdlTFF As Object
Local nX As Numeric
Local nLine As Numeric

lRet := .T.
oModel := FwModelActive()
oMdlTFL := oModel:GetModel('TFL_LOC')
oMdlTFF := oModel:GetModel('TFF_RH')
cLocAtend := oMdlTFL:GetValue( 'TFL_LOCAL' )

If oMdlTFF:Length() > 0
	cVlPadFun := Space( FWSX3Util():GetFieldStruct( "TFF_FUNCAO" )[3] )
	cVlPadDFun := Space( FWSX3Util():GetFieldStruct( "TFF_DFUNC" )[3] )
	nLine := oMdlTFF:GetLine()
	If _oQryVlLoc == Nil
		cQry := " SELECT AA0.AA0_DESCRI, SWY.WY_CODIGO, SWY.WY_DESC, SRJ.RJ_FUNCAO, SRJ.RJ_DESC " + CRLF
		cQry += " FROM " + RetSqlName( "ABS" ) + " ABS " + CRLF
		cQry += " INNER JOIN " + RetSqlName( "AA0" ) + " AA0 ON " + FWJoinFilial("ABS", "AA0") + " AND AA0.AA0_CODIGO = ABS.ABS_BASEOP AND AA0.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " INNER JOIN " + RetSqlName( "REI" ) + " REI ON REI.REI_FILCCT = AA0.AA0_FILIAL AND REI.REI_CODAA0 = AA0.AA0_CODIGO AND REI.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " INNER JOIN " + RetSqlName( "SWY" ) + " SWY ON SWY.WY_FILIAL = REI.REI_FILCCT AND SWY.WY_CODIGO = REI.REI_CODCCT AND SWY.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " INNER JOIN " + RetSqlName( "RI4" ) + " RI4 ON RI4.RI4_FILCCT = REI.REI_FILCCT AND RI4.RI4_CODCCT = SWY.WY_CODIGO AND RI4.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " INNER JOIN " + RetSqlName( "SRJ" ) + " SRJ ON SRJ.RJ_FILIAL = RI4.RI4_FILSRJ AND SRJ.RJ_FUNCAO = RI4.RI4_CODSRJ AND SRJ.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " INNER JOIN " + RetSqlName( "RUK" ) + " RUK ON " + FWJoinFilial("SWY", "RUK") + " AND RUK.RUK_CODCCT = SWY.WY_CODIGO AND RUK.RUK_ESTADO = SWY.WY_ESTADO AND RUK.RUK_CODMUN = ABS.ABS_CODMUN AND RUK.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " WHERE AA0.AA0_FILIAL = '" + FwxFilial( "AA0" ) + "' AND ABS.ABS_LOCAL = ? AND SRJ.RJ_FUNCAO = ? AND ABS.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " ORDER BY SRJ.RJ_FUNCAO, SWY.WY_CODIGO " + CRLF

		_oQryVlLoc := FWPreparedStatement():New( cQry )
	EndIf

	For nX := 1 To oMdlTFF:Length()
		oMdlTFF:GoLine( nX )

		_oQryVlLoc:SetString( 1, cLocAtend )
		_oQryVlLoc:SetString( 2, oMdlTFF:GetValue( 'TFF_FUNCAO' ) )
		cQry := _oQryVlLoc:GetFixQuery()
		MPSysOpenQuery( cQry, "_QryVlLoc" )

		If _QryVlLoc->( Eof() )
			oMdlTFF:LoadValue( 'TFF_FUNCAO', cVlPadFun )
			oMdlTFF:LoadValue( 'TFF_DFUNC', cVlPadDFun )
		EndIf

		_QryVlLoc->(DbCloseArea())
	Next nX

	oMdlTFF:GoLine( nLine )
	_oQryVlLoc:Destroy()
	FwFreeObj( _oQryVlLoc )
EndIf

Return Nil

/*/{Protheus.doc} TEC740Legen
	Verifica a regra para preenchimento da Legenda
	@type Function
	@author Anderson F. Gomes
	@since 18/03/2024
	@param  cPlaCod, Character, Código da Planilha
	@param  cCorLeg, Character, Cor Atual da Legenda
	@version 1.0.0
	@return cCor|Nil, Character|Nil, Cor da Legenda|Nulo
/*/
Function TEC740Legen( cPlaCod, cCorLeg )
	Local oModel As Object
	Local oMdlRh As Object
	Local oView As Object
	Local nX As Numeric
	Local nLine As Numeric
	Local lTemPLa As Logical

	oModel := FwModelActive()
	oMdlRh := oModel:GetModel('TFF_RH')

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE .AND. !IsInCallStack( "At740ClCal" )
		If ValType( cPlaCod ) == "U" .And. ValType( cCorLeg ) == "U" // Novo Item TFF
			lTemPLa := .F.
			nLine := oMdlRh:GetLine()
			For nX := 1 To oMdlRh:Length()
				oMdlRh:GoLine( nX )

				cCorLeg := AllTrim( oMdlRh:GetValue("TFF_LEGEND") )
				If cCorLeg == "BR_VERDE"
					lTemPLa := .T.
					Exit
				EndIf
			Next nX
			oMdlRh:GoLine( nLine )
			If lTemPLa
				Return "BR_VERMELHO"
			Else
				Return "BR_BRANCO"
			EndIf
		EndIf

		If ValType( cCorLeg ) == "U" // Carregando Oraçamento
			If Empty( cPlaCod )
				If (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE) .AND. !Isincallstack("At870GerOrc")
					oMdlRh:SetValue( "TFF_LEGEND", "BR_BRANCO" )
				Else
					oMdlRh:LoadValue( "TFF_LEGEND", "BR_BRANCO" )
				EndIf
			Else
				oMdlRh:LoadValue( "TFF_LEGEND", "BR_VERDE" )
			EndIf
		EndIf

		// Gatilhos
		If !Empty( cPlaCod ) .And. AllTrim( cCorLeg ) == "BR_BRANCO" 
			oMdlRh:LoadValue( "TFF_LEGEND", "BR_VERDE" )
		EndIf
		If !Empty( cPlaCod ) .And. AllTrim( cCorLeg ) == "BR_VERDE"
			oMdlRh:LoadValue( "TFF_LEGEND", "BR_VERMELHO" )
		EndIf

		oView := FwViewActive()

		If ValType( oView ) == "O" .And. oView:GetModel():GetId() == "TECA740" .And. !IsInCallStack( "InitDados" ) .And. !IsInCallStack( "TECXFPOPUP" )
			If oView:GetCurrentSelect()[1] == 'TFF_RH'
				oView:Refresh( 'TFF_RH' )
			EndIf
		EndIf
	Else
		oModel:nOperation := MODEL_OPERATION_UPDATE
		nLine := oMdlRh:GetLine()
		For nX := 1 To oMdlRh:Length()
			oMdlRh:GoLine( nX )

			cPlaCod := AllTrim( oMdlRh:GetValue("TFF_PLACOD") )
			If !Empty( cPlaCod )
				lTemPLa := .T.
				Exit
			EndIf
		Next nX
		oMdlRh:GoLine( nLine )
		If lTemPLa
			cPlaCod := AllTrim( oMdlRh:GetValue("TFF_PLACOD") )
			If Empty( cPlaCod )
				oMdlRh:LoadValue( "TFF_LEGEND", "BR_VERMELHO" )
			Else
				oMdlRh:LoadValue( "TFF_LEGEND", "BR_VERDE" )
			EndIf
		Else
			oMdlRh:LoadValue( "TFF_LEGEND", "BR_BRANCO" )
		EndIf
		oModel:nOperation := MODEL_OPERATION_DELETE
	EndIf
Return Nil

/*/{Protheus.doc} at740LDClk
	Exibe a tela de Legenda no duplo clique do campo TFF_LEGEND
	@type Function
	@author Anderson F. Gomes
	@since 18/03/2024
	@param  oFormulario, Object, Objeto do Grid
	@param  cFieldName, Character, Nome do campo atual
	@version 1.0.0
	@return .T., Logical, Verdadeiro
/*/
Function at740LDClk( oFormulario, cFieldName )
	Local aLeg As Array

	aLeg := {}
	If cFieldName == "TFF_LEGEND"
		AAdd( aLeg, { "BR_BRANCO", STR0377 } ) //STR0377 //"Sem planilha"
		AAdd( aLeg, { "BR_VERDE", STR0378 } ) //STR0378 //"Planilha Atualizada"
		AAdd( aLeg, { "BR_VERMELHO", STR0379 } ) //STR0379 //"Planilha Desatualizada"
		BrwLegenda( STR0376, STR0380, aLeg ) // "Legenda"###"Status"
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740FilFac
@description Filtro da consulta padrao de Facilitador de orçamento, para trazer facilitadores
que condizem com a BASE OPERACIONAL do local de atendimento selecionado no orçamento
@param  Nenhum
@return String filtro
@author jack.junior
@since 18/09/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740FilFac()
Local oModel 	:= Nil
Local cFiltro 	:= "@#"
Local cLocalTFL	:= ""
Local cBaseTFL	:= ""
Local lOrcamento:= IsInCallStack("TEC740NFac")

If lOrcamento
	oModel := FWModelActive() 
	cLocalTFL := oModel:GetModel('TFL_LOC'):getvalue('TFL_LOCAL')
	cBaseTFL  := Posicione("ABS", 1, xFilial("ABS")+cLocalTFL, "ABS_BASEOP" ) //ABS_FILIAL+ABS_LOCAL
	If !Empty(cBaseTFL)
		cFiltro += 'TXR->TXR_CODAA0=="'+cBaseTFL+'" .Or. Empty(TXR->TXR_CODAA0)'
	EndIf
EndIf

Return cFiltro+"@#"

Function AT740GetTe()
Local cRet			:= "501"
Local cQry			:= ""
Local cAliasQry		:= ""
Local oStatement	:= Nil

cQry := " SELECT SF4.F4_CODIGO "
cQry += " FROM " + RetSqlName( "SF4" ) + " SF4 "
cQry += " WHERE SF4.F4_FILIAL = ? "
cQry += " AND F4_CODIGO >= '501' "
cQry += " AND SF4.D_E_L_E_T_ = ' ' "

oStatement := FWPreparedStatement():New( cQry )
oStatement:SetString( 1, FwXFilial( "SF4" ) )

cQry := oStatement:GetFixQuery()
cAliasQry := GetNextAlias()

MPSysOpenQuery( cQry, cAliasQry )
If (cAliasQry)->( !Eof() )
	cRet := (cAliasQry)->F4_CODIGO
EndIf

(cAliasQry)->(DbCloseArea())
oStatement:Destroy()
FwFreeObj( oStatement )

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740QtdUni
@description Atualiza Qtd. Total de uniformes do grid ao alterar a alocação prevista do posto.
@param  nQtPrev - quantidade de alocação prevista TFF_QTPREV
@author jack.junior
@since 11/11/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At740QtdUni(nQtPrev)
Local oMdl    	:= FwModelActive()
Local oMdlTXP 	:= Nil
Local oView		:= Nil
Local aSaveRows := FWSaveRows( oMdl )
Local nQtdUni 	:= 0
Local nRestLine := 0
Local nX		:= 0

If oMdl:GetId()=='TECA740'
	oMdlTXP := oMdl:GetModel('TXPDETAIL')
	nRestLine := oMdlTXP:GetLine()

	For nX := 1 To oMdlTXP:Length()
		oMdlTXP:GoLine(nX)
		nQtdUni := oMdlTXP:GetValue('TXP_QTDVEN')
		If nQtdUni > 0
			oMdlTXP:SetValue('TXP_QTDUNI',nQtdUni*nQtPrev)
		EndIf
	Next nX

	oMdlTXP:GoLine(nRestLine)

	oView := FwViewActive()
	If ValType( oView ) == "O" .And. oView:GetModel():GetId() == "TECA740" .And. !IsInCallStack( "InitDados" ) .And. !IsInCallStack( "TECXFPOPUP" )
		oView:Refresh( 'VIEW_UNIF' )
	EndIf
EndIf

FWRestRows(aSaveRows)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreGridTFG
@description BPre - Bloco de Código de pré-validação do submodelo TFG.
@author jack.junior
@since 11/12/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function PreGridTFG(oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue)
Local lRet := .T.

lRet := isExtraTFF(oMdlG, cAction)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreGridTFH
@description BPre - Bloco de Código de pré-validação do submodelo TFH.
@author jack.junior
@since 11/12/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function PreGridTFH(oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue)
Local lRet := .T.

lRet := isExtraTFF(oMdlG, cAction)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreGridTXQ
@description BPre - Bloco de Código de pré-validação do submodelo TXQ.
@author jack.junior
@since 11/12/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function PreGridTXQ(oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue)
Local lRet := .T.

lRet := isExtraTFF(oMdlG, cAction)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreGridTXP
@description BPre - Bloco de Código de pré-validação do submodelo TXP.
@author jack.junior
@since 11/12/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function PreGridTXP(oMdlG, nLine, cAction, cIDField, xValue, xCurrentValue)
Local lRet := .T.

lRet := isExtraTFF(oMdlG, cAction)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isExtraTFF
@description Verifica se o Posto pai do grid analisado é um Posto de ITEM EXTRA na
				Rotina de Inclusão de Itens extras.
				Caso não seja, não permite edição do Grid.
@author jack.junior
@since 11/12/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function isExtraTFF(oMdlG, cAction)
Local lRet 		:= .T.
Local cGrid 	:= ""
Local cNomeGrid := ""

If IsInCallStack("At870GerOrc")
	If cAction $ "CANSETVALUE|SETVALUE|DELETE|UNDELETE|ADDLINE"
		If oMdlG:GetId() $ "TFG_MI|TFH_MC|TXPDETAIL|TXQDETAIL"
			If oMdlG:GetModel():GetModel("TFF_RH"):GetValue("TFF_COBCTR") == "1"
				lRet := .F.				
				cGrid := SubStr(oMdlG:GetId(),1,3)
				If cGrid == "TFG"
					cNomeGrid := STR0390 //"Material de Implantação"
				ElseIf cGrid == "TFH"
					cNomeGrid := STR0391 //"Material de Consumo"
				ElseIf cGrid == "TXP"
					cNomeGrid := STR0392 //"Uniformes"
				ElseIf cGrid == "TXQ"
					cNomeGrid := STR0393 //"Armamento"
				EndIf
				Help( , , "PreGrid"+cGrid, Nil, STR0394+" "+cNomeGrid+" "+STR0395, 1, 0,,,,,,{STR0396}) //"Não é possível realizar essa ação na grid de "+cNomeGrid+" pois esse Posto (TFF) não é um Item Extra (TFF_COBCTR = Não)"#"Para inclusão de materiais extras é necessário incluir um Posto (TFF) de Item Extra."
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExecAtuLot
Percorre o Modelo da TFF e executa/atualiza planilha 
	se TFF_LEGEND estiver vermelha
Se tem XML (TFF_CALCMD) ATUALIZA a planilha para manter F8, F9, F10, F11
Se não tem XML (TFF_CALCMD) EXECUTA da ABW (cadastro de planilha)

@author 	jack.junior
@param		oMdl - Caso Nil pega o ativo
@since		16/12/2024
/*/
//------------------------------------------------------------------------------
Static Function ExecAtuLot(oMdl)
Local aArea		 := GetArea()
Local aSaveLines := FWSaveRows()
Local oMdlRh 	 := Nil
Local nX 		 := 0
Local nY 		 := 0
Local cMdlLength := 0
Local cJobThr    := ""

If ValType(oMdl) == "U"
	oMdl := FwModelActive()
EndIf

oMdlRh := oMdl:GetModel("TFF_RH")
cMdlLength := oMdlRh:Length()

ProcRegua(cMdlLength)
IncProc(STR0397+ " 1 " + STR0398 + " " + cValToChar(cMdlLength) + "...") //"Aplicando Planilha no Posto" x "de" y...

// Verifcar se as Threads encerraram e atualizar postos.
If SuperGetMv("MV_TESGSNE",.F.,.F.) .And. !isBlind()
	aSort(aControle,,,{|x,y|x>y})
	While Len(aControle) > 0
		For nX := Len(aControle) To 1 Step -1
			cJobThr := aControle[nX]
			If GetGlbValue(cJobThr) == "EXIT"
				At740EncPla(oMdl, cJobThr, nX)
			EndIf
		Next nX
	EndDo
EndIf

// Processamento das planilhas desatualizadas
DbSelectArea("ABW")
ABW->(DbSetOrder(1)) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
For nY := 1 to cMdlLength
	oMdlRh:GoLine(nY)
	IncProc(STR0397+ " " + cValToChar(nY) + " " + STR0398 + " " + cValToChar(cMdlLength) + "...") //"Aplicando Planilha no Posto" x "de" y...
	If !(oMdlRh:IsDeleted())
		If AllTrim(oMdlRh:GetValue("TFF_LEGEND")) == "BR_VERMELHO" 
			If ABW->(DbSeek(xFilial("ABW")+oMdlRh:GetValue("TFF_PLACOD")+oMdlRh:GetValue("TFF_PLAREV")))
				If Empty(oMdlRh:GetValue("TFF_CALCMD")) //EXECUTA PLANILHA "NOVA":
					At998ExPla(ABW->ABW_INSTRU,oMdl,.F.,oMdlRh:GetValue("TFF_PLACOD")+oMdlRh:GetValue("TFF_PLAREV"))
					oMdlRh:LoadValue("TFF_VLFIXO", 0)
				Else //ATUALIZA PLANILHA:
					At998ExPla(oMdlRh:GetValue("TFF_CALCMD"), oMdl, .F./*lLocEq*/, oMdlRh:GetValue("TFF_PLACOD") + oMdlRh:GetValue("TFF_PLAREV"))
				EndIf
			Endif
		EndIf
	EndIf
Next nY
FWRestRows( aSaveLines )
RestArea(aArea)

Return

/*/{Protheus.doc} revisaoRegra
	Regra de Apontamento na TFF
	@author 	jack.junior 
	@param		oSubTFF - Modelo TFF ativo
	@since		10/01/2025
/*/
Static Function revisaoRegra(oSubTFF)
Local lRet	:= .T.

If !Empty(Posicione("TFF", 1, xFilial("TFF")+oSubTFF:GetValue("TFF_COD"), "TFF_REGRA" ))
	lRet := .F.
EndIf
	
Return(lRet)

/*/{Protheus.doc} TC740Mnt
	Seta valor no campo TFF_VLFIXO para execução dos gatilhos para recalcular os campos corretamente.
	@author 	roberto.santiago
	@param		oModel - Modelo ativo
	@since		17/02/2025
/*/
Function TC740Mnt(oModel, lRet) as variant

Local oMdlTFF    := Nil
Local oView      := Nil
Local nCurrValue := 0
Default lRet 	 := .T.

If lRet
	If ValType(oModel:GetModel("TFF_RH")) == "O"
		oMdlTFF    := oModel:GetModel("TFF_RH")
		nCurrValue := oMdlTFF:GetValue("TFF_VLFIXO")
		oMdlTFF:SetValue("TFF_VLFIXO", nCurrValue)

		oView := FwViewActive()
		If ValType( oView ) == "O" .And. oView:GetModel():GetId() == "TECA740"
			oView:Refresh()
		EndIf
	EndIf
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740RhPla
Percorre o modelo da TFF e altera a legenda pra VERMELHO caso tenha 
planilha de preços aplicada

@author 	jack.junior
@param		oMdlFull - Modelo Orçamento
@since		06/03/2025
/*/
//------------------------------------------------------------------------------
Function at740RhPla(oMdlFull)
Local oMdlRH := oMdlFull:GetModel("TFF_RH")
Local nX 	 := 1

For nX := 1 To oMdlRH:Length()
	oMdlRH:GoLine(nX)
	If AllTrim( oMdlRH:GetValue("TFF_LEGEND") ) == "BR_VERDE"
		oMdlRH:LoadValue( "TFF_LEGEND", "BR_VERMELHO" )
	EndIf
Next nX

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740PlaJob
	Carregar os dados do Posto e executar o Job
@author flavio.vicco
@since 19/03/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At740PlaJob(cJobThr, cXml, cCodRev, oModel)
Local oMdlRh		:= Nil
Local oMdlBen		:= Nil
Local oMdlLA		:= Nil
Local cCodCCT       := ""
Local cDescPeriod   := ""
Local cDscGrau      := ""
Local cDscInsa      := ""
Local cDscPeric     := ""
Local cFuncao       := ""
Local cGrauInsalub  := "1"
Local cInsalub      := "1"
Local cPericulo     := "1"
Local cQuantHrs     := ""
Local lFeriad       := .F.
Local lOrcSrv       := GetMv("MV_GSITORC",,"2") == "1"
Local nArea         := 0
Local nHoraSem      := 0
Local nHrDia        := 0
Local nHrsNot       := 0
Local nHrsTot       := 0
Local nMetrag       := 0
Local nMetro        := 0
Local nPercISS      := 0
Local nPlrCCT       := 0
Local nQtdAlo       := 0
Local nQtdIntra     := 0
Local nQtdVen       := 0
Local nQuantDias    := 0
Local nSalario      := 0
Local nTotAR		:= 0
Local nTotFer       := 0
Local nTotMC        := 0
Local nTotMI        := 0 
Local nTotUN		:= 0
Local nTotVer       := 0
Local nQtdPrev		:= 0
Local aData			:= {}

If !Empty(cCodRev)
	aAdd(aControle,cJobThr)
	//-- Inicio do processamento da THREAD
	PutGlbValue(cJobThr, "INIT")
	GlbUnLock()

	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlBen := oModel:GetModel("ABP_BENEF")
	oMdlLA := oModel:GetModel("TFL_LOC")
	cGrauInsalub := oMdlRh:GetValue("TFF_GRAUIN")
    cDscGrau :=  x3Combo("TFF_GRAUIN",cGrauInsalub)
	cInsalub := oMdlRh:GetValue("TFF_INSALU")
    cDscInsa := x3Combo("TFF_INSALU",cInsalub)
	cPericulo := oMdlRh:GetValue("TFF_PERICU")
    cDscPeric := x3Combo("TFF_PERICU",cPericulo)
    cQuantHrs := oMdlRh:GetValue("TFF_QTDHRS") 
    nDiasTrb := At998DTrb(oMdlRh:GetValue("TFF_ESCALA"),oMdlRh:GetValue("TFF_TURNO"),@nHrsTot,@nHrDia,@nHoraSem)
    nHrsInt := At998TotInt(oMdlRh:GetValue("TFF_ESCALA"),oMdlRh:GetValue("TFF_TURNO"))
    nHrsNot := At998HrNt(oMdlRh:GetValue("TFF_ESCALA"),oMdlRh:GetValue("TFF_TURNO"), @cDescPeriod,@lFeriad)
    nPercISS := At998GtISS(oModel:GetValue("TFL_LOC","TFL_LOCAL"),oModel:GetValue("TFF_RH","TFF_PRODUT"))
    nPlrCCT := At998PsqCCT(cCodRev)
    nQtdAlo := At740QtdAloc(oMdlRh:GetValue("TFF_ESCALA"))
    nQtdIntra := At998QtdIntra(oMdlRh:GetValue("TFF_ESCALA"))
    nQtdVen := oMdlRh:GetValue("TFF_QTDVEN")
    nQuantDias := (oMdlRh:GetValue("TFF_PERFIM") - oMdlRh:GetValue("TFF_PERINI")) + 1
    nTotAR := oMdlRh:GetValue("TFF_TOTARM")
    nTotFer := At998TotFer(oMdlRh:GetValue("TFF_CALEND"))
    nTotMC := oMdlRh:GetValue("TFF_TOTMC")
    nTotMI := oMdlRh:GetValue("TFF_TOTMI")
    nTotUN := oMdlRh:GetValue("TFF_TOTUNI")
    nTotVer := At998Verb(oMdlBen) 
	nMetro := oMdlLA:GetValue("TFL_METRO")
	nArea := oMdlRh:GetValue("TFF_AREAPR")
	nMetrag := oMdlRh:GetValue("TFF_METRAT")
	nQtdPrev := oMdlRh:GetValue("TFF_QTPREV")

	DbSelectArea("ABW")
	DbSetOrder(1) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
	If ABW->(DbSeek(xFilial("ABW")+cCodRev))
		//Se a TFF não tem XML pega do cadastro de planilha ABW:
		If Empty(cXml)
			cXml := ABW->ABW_INSTRU
		EndIf
		If Empty(Alltrim(ABW->ABW_FUNCAO))
			If RI4->( ColumnPos('RI4_SALARI') ) > 0 .And. !Empty(cFuncao)
				//Verifica se tem Função e Salario na CCT cadastrado:
				cConfCal := ABW->ABW_CODTCW
				cCodCCT := Posicione("TCW",1,xFilial("TCW")+cConfCal,"TCW_CODCCT") //Indice 1 = TCW_FILIAL+TCW_CODIGO
				If !Empty(cCodCCT)
					nSalario := at998SalCCT(cCodCCT, cFuncao)
				EndIf
			EndIf
			If nSalario == 0
				//Senão pega do cadastro de Funções SRJ:
				DbSelectArea("SRJ")
				SRJ->(DbSetOrder(1))
				If SRJ->(DbSeek(xFilial("SRJ")+cFuncao))
					nSalario := SRJ->RJ_SALARIO
				EndIf
			EndIf
		EndIf
	EndIf

	If !Empty(cXml)
		aData := {cGrauInsalub,; //01 - Grau de Insalubridade
					cDscGrau,;	 //02 - Descrição Grau Insalubridade
					cInsalub,;	 //03 - Tipo de Insalubridade
					cDscInsa,;	 //04 - Descrição Insalubridade
					cPericulo,;	 //05 - Grau de Periculosidade
					cDscPeric,;	 //06 - Descrição Periculosidade
					cQuantHrs,;	 //07 - Quantidade de horas
					nDiasTrb,;	 //08 - Dias trabalhados
					nHrsTot,;	 //09 - Horas totais
					nHrDia,;	 //10 - Hora dia
					nHoraSem,;	 //11 - Hora semana
					nHrsInt,;	 //12 - Horas
					nHrsNot,;	 //13 - Horas noturnas
					cDescPeriod,;//14 - Descrição do Período
					lFeriad,;	 //15 - Se é feriado
					nPercISS,;	 //16 - ISS
					nPlrCCT,;	 //17 - PLR
					nQtdAlo,;	 //18 - Quantidade de alocação
					nQtdIntra,;	 //19 - Quantidade de intrajornada
					nQtdVen,;	 //20 - Quantidade vendida TFF
					nQuantDias,; //21 - Quantidade de dias
					nTotAR,;	 //22 - Valor total de armamento
					nTotFer,;	 //23 - Total de feriado
					nTotMC,;	 //24 - Valor total de Material de consumo
					nTotMI,;	 //25 - Valor total de Material de implantação
					nTotUN,;	 //26 - Valor total de Uniforme
					nTotVer,;	 //27 - Verbas
					nMetro,;	 //28 - Metros
					nArea,;	 	 //29 - Area
					nMetrag,;	 //30 - Metragem
					nQtdPrev,;	 //31 - TFF_QTPREV
					nSalario,}	 //32 - Salário

		StartJob("At998ExJob", GetEnvServer(), .F., ;
					cEmpAnt, cFilAnt, cXml, cCodRev, cJobThr, aData, lOrcSrv)
	EndIf
EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At740EncPla
	Encerramento dos Jobs e Atualizaco dos dados dos Postos
@author flavio.vicco
@since 19/03/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At740EncPla(oMdl, cJobThr, nPos)
Local aResult    := {}
Local cXml       := ""
Local lAbtInss   := .F.
Local nPLucro    := 0
Local nTamCpoCod := 0
Local nTamCpoRev := 0
Local nTotAbINS  := 0
Local nTotal     := 0
Local nTotPlan   := 0
Local nLine		 := 0
Local lRet 		 := .T.
Local oMdlRh	 := Nil
Local oView		 := Nil

oMdlRh := oMdl:GetModel("TFF_RH")

nLine := oMdlRh:GetLine()

If oMdlRh:SeekLine({{'TFF_COD',cJobThr}},.T.,.T.)
	// Carregar resultados
	GetGlbVars(cJobThr+"_ARRAY", aResult)
	cXml     := aResult[1]
	nTotal   := aResult[2]
	nTotPlan := aResult[3]
	nPLucro  := aResult[4]
	nTotAbINS:= aResult[5]

	lAbtInss := TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"
	nTamCpoCod := TamSX3("TFF_PLACOD")[1]
	nTamCpoRev := TamSX3("TFF_PLAREV")[1]

	cCodRev := oMdlRh:GetValue("TFF_PLACOD")+oMdlRh:GetValue("TFF_PLAREV")
	lRet := lRet .And. oMdlRh:SetValue("TFF_PRCVEN", ROUND(nTotal, TamSX3("TFF_PRCVEN")[2]))
	lRet := lRet .And. oMdlRh:SetValue("TFF_CALCMD", cXml)
	/* Necessário pois no gatilho do campo existe a Função FwFldGet  - INÍCIO */
	lRet := lRet .And. oMdlRh:LoadValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
	lRet := lRet .And. oMdlRh:LoadValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
	/* Necessário pois no gatilho do campo existe a Função FwFldGet  - FIM */
	lRet := lRet .And. oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
	lRet := lRet .And. oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
	lRet := lRet .And. oMdlRh:SetValue("TFF_TOTPLA", ROUND(nTotPlan, TamSX3("TFF_TOTPLA")[2]))
	If lAbtInss .And. nTotAbINS > 0
		lRet := lRet .And. oMdlRh:SetValue("TFF_ABTINS",nTotAbINS)
	EndIf
	lRet := lRet .And. oMdlRh:LoadValue("TFF_PLUCRO",Round(at998Val(nPLucro), TamSX3("TFF_PLUCRO")[2]))
	// Atualizar Status da Planilha do Posto
	lRet := lRet .And. oMdlRh:LoadValue( "TFF_LEGEND", "BR_VERDE" )
	TC740Mnt(oMdl)

	// Liberar Status da Thread
	CleanThread(cJobThr, nPos)

	oMdlRh:GoLine(nLine)

	If !isBlind()
		oView := FwViewActive()
		oView:Refresh("VIEW_RH")
	EndIf
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CleanThread
	Limpa variáveis globais e array statico da thread
@author jack.junior
@since 10/07/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CleanThread(cJobThr, nPos)
Default cJobThr := ""

PutGlbValue(cJobThr, "")
GlbUnLock()
ClearGlbValue(cJobThr)
ClearGlbValue(cJobThr+"_ARRAY")

If Len(aControle) > 0 .And. nPos > 0
	aDel(aControle,nPos)
	aSize(aControle,(Len(aControle)-1))
EndIf

Return

/*/{Protheus.doc} SumMat740
Soma a quantidade de materiais de implantação + materiais de consumo + uniformes + armamentos
@author felipe.mcamargo
@since 13/07/2025
@param oMdlMI, object, Model TFG_MI
@param oMdlMC, object, Model TFH_MC
@param oMdlTXP, object, Model TXPDETAIL
@param oMdlTXQ, object, Model TXQDETAIL
@return variant, Valor mínimo aceitável na edição do campo TFF_VLFIXO que é a soma dos materiais MI + MC
/*/
Static Function SumMat740(oMdlMI,oMdlMC,oMdlTXP,oMdlTXQ)
	Local nI   := 0
	Local nRet := 0

	//Contagem de Materiais de Implantação:
	For nI := 1 To oMdlMI:Length()
		If !oMdlMI:IsDeleted(nI) .And. !Empty(oMdlMI:GetValue("TFG_PRODUT",nI))
			nRet += oMdlMI:GetValue("TFG_QTDVEN",nI)
		EndIf
	Next nI

	//Contagem de Materiais de Consumo:
	For nI := 1 To oMdlMC:Length()
		If !oMdlMC:IsDeleted(nI) .And. !Empty(oMdlMC:GetValue("TFH_PRODUT",nI))
			nRet += oMdlMC:GetValue("TFH_QTDVEN",nI)
		EndIf
	Next nI

	//Contagem de Uniformes:
	For nI := 1 To oMdlTXP:Length()
		If !oMdlTXP:IsDeleted(nI) .And. !Empty(oMdlTXP:GetValue("TXP_CODUNI",nI))
			nRet += oMdlTXP:GetValue("TXP_QTDVEN",nI)
		EndIf
	Next nI

	//Contagem de Armamento:
	For nI := 1 To oMdlTXQ:Length()
		If !oMdlTXQ:IsDeleted(nI) .And. !Empty(oMdlTXQ:GetValue("TXQ_CODPRD",nI))
			nRet += oMdlTXQ:GetValue("TXQ_QTDVEN",nI)
		EndIf
	Next nI

Return Round( nRet/100, TamSX3("TFF_VLFIXO")[2] )

/*/{Protheus.doc} At740MatRd
Altera os materiais para 1 centavo caso for utilizado o valor fixo mínimo no posto
Altera a vida útil dos materiais para 1
@author felipe.mcamargo
@since 13/07/2025
@param oMdlMI, object, Model TFG_MI
@param oMdlMC, object, Model TFH_MC
@param oMdlTXP, object, Model TXPDETAIL
@param oMdlTXQ, object, Model TXQDETAIL
@return Sem retorno mas atualiza os submodels de materiais com o valor mínimo de 1 centávo no valor unitário
/*/
Static Function At740MatRd(oMdlMI,oMdlMC,oMdlTXP,oMdlTXQ)
	Local nI := 0

	For nI := 1 To oMdlMI:Length()
		oMdlMI:goLine(nI)
		If !Empty(oMdlMI:GetValue("TFG_PRODUT"))
			oMdlMI:SetValue("TFG_VIDMES", 1)
			oMdlMI:SetValue("TFG_PRCVEN", 0.01)
		EndIf
	Next nI

	For nI := 1 To oMdlMC:Length()
		oMdlMC:goLine(nI)
		If !Empty(oMdlMC:GetValue("TFH_PRODUT"))
			oMdlMC:SetValue("TFH_VIDMES", 1)
			oMdlMC:SetValue("TFH_PRCVEN", 0.01)
		EndIf
	Next nI

	For nI := 1 To oMdlTXP:Length()
		oMdlTXP:goLine(nI)
		If !Empty(oMdlTXP:GetValue("TXP_CODUNI"))
			oMdlTXP:SetValue("TXP_VIDMES", 1)
			oMdlTXP:SetValue("TXP_PRCVEN", 0.01)
		EndIf
	Next nI

	For nI := 1 To oMdlTXQ:Length()
		oMdlTXQ:goLine(nI)
		If !Empty(oMdlTXQ:GetValue("TXQ_CODPRD"))
			oMdlTXQ:SetValue("TXQ_VIDMES", 1)
			oMdlTXQ:SetValue("TXQ_PRCVEN", 0.01)
		EndIf
	Next nI

Return

/*/{Protheus.doc} g740VlFixo
Gatilho para ajustar o posto para o valor mínimo caso for desejado
@author felipe.mcamargo
@since 7/13/2025
@return variant, Sem retorno mas durante o gatilho do TFF_VLFIXO ele força o valor mínimo
/*/
Function g740VlFixo()
	Local nVal    := 0
	Local nValMin := 0
	Local oMdl    := FwModelActive()
	Local oMdlMC  := oMdl:GetModel("TFH_MC")
	Local oMdlMI  := oMdl:GetModel("TFG_MI")
	Local oMdlRH  := oMdl:GetModel("TFF_RH")
	Local oMdlTXP := oMdl:GetModel('TXPDETAIL')
	Local oMdlTXQ := oMdl:GetModel('TXQDETAIL')

	nValMin := SumMat740(oMdlMI,oMdlMC,oMdlTXP,oMdlTXQ)
	nVal := oMdlRh:GetValue("TFF_VLFIXO")

	If nVal > 0 .And. nVal < nValMin .AND. !ExistBlock('a740MarC')
		oMdlRH:LoadValue("TFF_VLFIXO", nValMin)
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} saveTFFSLY
Popula o array statico aBenefTFF com os benefícios SLY ao abrir um orçamento.
@since		25/07/2025
@author		jack.junior
/*/
//------------------------------------------------------------------------------
Static Function saveTFFSLY(cCodTFF)
Local cQry		:= ""
Local cAliasSLY := ""
Local oQuery	:= Nil

cQry := "SELECT SLY.*, SLY.R_E_C_N_O_ SLY_RECNO "
cQry += "  FROM ? SLY "
cQry += " WHERE SLY.LY_FILIAL = ? "
cQry += "   AND SUBSTRING(LY_CHVENT,1,?) = ? "
cQry += "   AND SLY.LY_FILENT = ? "
cQry += "   AND SLY.LY_ALIAS = 'TDX' "
cQry += "   AND SLY.D_E_L_E_T_ = ' ' "
cQry := ChangeQuery( cQry )

oQuery := FwExecStatement():New(cQry)
oQuery:SetUnsafe( 1, RetSqlName("SLY") )
oQuery:SetString( 2, xFilial("SLY") )
oQuery:SetUnsafe( 3, STR(TAMSX3("TFF_COD")[1]))
oQuery:SetString( 4, cCodTFF)
oQuery:SetString( 5, xFilial("TFF") )

cAliasSLY := oQuery:OpenAlias()

If (cAliasSLY)->(!Eof())
	While (cAliasSLY)->(!Eof())
		AADD(aBenefTFF, {cCodTFF,;
						 (cAliasSLY)->SLY_RECNO,;
						 (cAliasSLY)->LY_FILIAL+(cAliasSLY)->LY_TIPO+(cAliasSLY)->LY_AGRUP+(cAliasSLY)->LY_ALIAS+(cAliasSLY)->LY_FILENT+(cAliasSLY)->LY_CHVENT+(cAliasSLY)->LY_CODIGO+(cAliasSLY)->LY_DTINI})
		(cAliasSLY)->(DbSkip())
	EndDo
EndIf

(cAliasSLY)->(DbCloseArea())
oQuery:Destroy()
FwFreeObj(oQuery)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtDelBenef
Deleta os benefícios incluídos em uma revisão ao Excluir a revisão
@since		25/07/2025
@author		jack.junior
/*/
//------------------------------------------------------------------------------
Static Function AtDelBenef()
Local nX := 0

DbSelectArea("SLY")
SLY->(DbSetOrder(1)) //LY_FILIAL+LY_TIPO+LY_AGRUP+LY_ALIAS+LY_FILENT+LY_CHVENT+LY_CODIGO+DTOS(LY_DTINI)

For nX := 1 To Len(aBenefTFF)

	If SLY->(DbSeek(aBenefTFF[nX,3]))
		Reclock('SLY',.F.)
		SLY->(DbDelete()) //Deleta o Registro
		SLY->(MsUnlock())
	EndIf

Next nX

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetABenTFF
Retorna o array statico de benefícios ao abrir um orçamento
@since		25/07/2025
@author		jack.junior
/*/
//------------------------------------------------------------------------------
Function GetABenTFF()
Return aBenefTFF
