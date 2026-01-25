#Include "loca229a.ch"
#Include "TOTVS.CH"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} LOCA229A
Função para inclusão de romaneio via menu da demanda
@type function
@version 25.10
@author Alexandre Circenis
@since 4/14/2025
/*/
FUNCTION LOCA229A()

Local oRomaneio := FWLoadModel("LOCA229A")
LOcal oMaster  := oRomaneio:GetModel("FQUMASTER")
Local aEnableButtons := {}
Local cTitle
Local nOperation
Local cRomaneio := ""

cTitle := STR0001 //"Incluir novo Romaneio"
nOperation := MODEL_OPERATION_INSERT
// Habilitar somente os botões Confirmar e Cancelar
aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0003},{.T.,STR0002},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //STR0002 //STR0003 //"Cancelar" //"Confirmar"

// Incluir uma nova demanda 
oRomaneio:SetOperation( nOperation ) //Inclusao
oRomaneio:Activate(.F.)

oMaster:SetValue( "FQU_PROJET", FQT->FQT_PROJET)
oMaster:SetValue( "FQU_OBRA"  , FQT->FQT_OBRA)


if FWExecView( cTitle  , 'LOCA229A', nOperation, /*oDlg*/, {|| .T. } ,;
    {|| cRomaneio := oRomaneio:GetModel("FQUMASTER"):GetValue("FQU_NUM"), .T. }/*bOk*/ , 10, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oRomaneio ) == 0

else
	Return .F.
endif

oRomaneio:DeActivate()
oRomaneio:Destroy()

Aviso(STR0006, STR0004+cRomaneio+STR0005, {"&Ok"}) //"Nova demanda incluida " //"&Ok" //" itens." //"Nova Demanda" //" com " //"O romaneio " //" fio incluido com sucesso." //"Novo romaneio"

Return

/*/{Protheus.doc} MODELDEF
Definicão do modelo de 
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo de Cabeçalho de Demanda
/*/
STATIC FUNCTION MODELDEF()
Local oStruFQU := FWFormStruct( 1, 'FQU', /*bAvalCampo*/,/*lViewUsado*/ )
Local cVld := ""
Local oModel
Local oEventMain	As Object

oEventMain	:= LOCA229AEVDEF():New() // Define novos eventos 

oModel := MPFormModel():New( 'LOCA229A', /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New( 'COMP012MODEL', /*bPreValidacao*/, { | oMdl | COMP012POS( oMdl ) } , /*bCommit*/, /*bCancel*/ )

oStruFQU:AddTrigger( "FQU_PROJET"   , "FQU_PROJET"	, {|| .T. }  , {|| LOCA229TGA() } )
oStruFQU:AddTrigger( "FQU_ASF"      , "FQU_ASF"	    , {|| .T. }  , {|| LOCA229TGB() } )
oStruFQU:AddTrigger( "FQU_MOTCOD"   , "FQU_MOTCOD"  , {|| .T. }  , {|| LOCA229TGC() } )
oStruFQU:AddTrigger( "FQU_TIPOVE"   , "FQU_DTIPVE"	, {|| .T. }  , {|| Posicione("DUT",1,XFilial("DUT")+FWFldGet('FQU_TIPOVE'),"DUT_DESCRI") } )
oStruFQU:AddTrigger( "FQU_VEICUL"   , "FQU_PLACA"	, {|| .T. }  , {|| Posicione("DA3",1,XFilial("DA3")+FWFldGet('FQU_VEICUL'),"DA3_PLACA") } )
oStruFQU:AddTrigger( "FQU_VEICU2"   , "FQU_PLACA2"	, {|| .T. }  , {|| Posicione("DA3",1,XFilial("DA3")+FWFldGet('FQU_VEICU2'),"DA3_PLACA") } )
oStruFQU:AddTrigger( "FQU_VEICU3"   , "FQU_PLACA3"	, {|| .T. }  , {|| Posicione("DA3",1,XFilial("DA3")+FWFldGet('FQU_VEICU3'),"DA3_PLACA") } )
oStruFQU:AddTrigger( "FQU_CODTRA"   , "FQU_TRANS"	, {|| .T. }  , {|| Posicione("SA4",1,XFilial("SA4")+FWFldGet('FQU_CODTRA'),"A4_NOME") } )

oSTruFQU:SetProperty("FQU_OBRA",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229AVO()'))
oSTruFQU:SetProperty("FQU_ASF",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229AVA()'))

oSTruFQU:SetProperty("FQU_DINEMB",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229XVD("1")'))
oSTruFQU:SetProperty("FQU_DFIEMB",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229XVD("2")'))
oSTruFQU:SetProperty("FQU_DINDES",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229XVD("3")'))
oSTruFQU:SetProperty("FQU_DFIDES",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229XVD("4")'))

oSTruFQU:SetProperty("FQU_HINEMB",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229XVH()'))
oSTruFQU:SetProperty("FQU_HFIEMB",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229XVH() .and. LOCA229XVP("2")'))
oSTruFQU:SetProperty("FQU_HINDES",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229XVH() .and. LOCA229XVP("3")'))
oSTruFQU:SetProperty("FQU_HFIDES",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229XVH() .and. LOCA229XVP("4")'))
oSTruFQU:SetProperty("FQU_PROJET",MODEL_FIELD_WHEN, {|| Empty(FwFldGet("FQU_PROJET")) .or. !FwIsInCallStack("LOCA229A") } )
oSTruFQU:SetProperty("FQU_OBRA",MODEL_FIELD_WHEN, {|| Empty(FwFldGet("FQU_OBRA")) .or. !FwIsInCallStack("LOCA229A") } )

// Atualizando o Valid dos campos de veiculos para evistar repetição
cVld := AllTrim(oSTruFQU:GetProperty("FQU_VEICUL", MODEL_FIELD_CVALID ) )
cVld += IIf(!Empty(cVld),'.AND.','')+'Loca229AVV("1")'
oSTruFQU:SetProperty("FQU_VEICUL",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,cVld) )

cVld := AllTrim(oSTruFQU:GetProperty("FQU_VEICU2", MODEL_FIELD_CVALID ) )
cVld += IIf(!Empty(cVld),'.AND.','')+'Loca229AVV("2")'
oSTruFQU:SetProperty("FQU_VEICU2",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,cVld) )

cVld := AllTrim(oSTruFQU:GetProperty("FQU_VEICU3", MODEL_FIELD_CVALID ) )
cVld += IIf(!Empty(cVld),'.AND.','')+'Loca229AVV("3")'
oSTruFQU:SetProperty("FQU_VEICU3",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,cVld) )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FQUMASTER', /*cOwner*/, oStruFQU, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0007 ) //'Gestão de Demandas' //"Romaneio de Expedição"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FQUMASTER' ):SetDescription(STR0007) //'Demanda' //"Romaneio de Expedição"
oModel:SetPrimaryKey({"FQU_FILIAL","FQU_DEMAND"})
// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActive( { | oModel | COMP012ACT( oModel ) }
//Regras de preenchimento
oModel:AddRules('FQUMASTER', "FQU_OBRA", 'FQUMASTER', "FQU_PROJET", 3)
oModel:AddRules('FQUMASTER', "FQU_ASF" , 'FQUMASTER', "FQU_PROJET", 3)

oModel:AddRules('FQUMASTER', "FQU_DFIEMB", 'FQUMASTER', "FQU_DINEMB", 3)
oModel:AddRules('FQUMASTER', "FQU_HINEMB", 'FQUMASTER', "FQU_DINEMB", 3)
oModel:AddRules('FQUMASTER', "FQU_DFIEMB", 'FQUMASTER', "FQU_DINEMB", 3)
oModel:AddRules('FQUMASTER', "FQU_HFIEMB", 'FQUMASTER', "FQU_DFIEMB", 3)
oModel:AddRules('FQUMASTER', "FQU_DINDES", 'FQUMASTER', "FQU_DFIEMB", 3)
oModel:AddRules('FQUMASTER', "FQU_HINDES", 'FQUMASTER', "FQU_DINDES", 3)
oModel:AddRules('FQUMASTER', "FQU_DFIDES", 'FQUMASTER', "FQU_DINDES", 3)
oModel:AddRules('FQUMASTER', "FQU_HFIDES", 'FQUMASTER', "FQU_DFIDES", 3)

oModel:AddRules('FQUMASTER', "FQU_PLACA" , 'FQUMASTER', "FQU_VEICUL", 3)
oModel:AddRules('FQUMASTER', "FQU_VEICU2", 'FQUMASTER', "FQU_VEICUL", 3)
oModel:AddRules('FQUMASTER', "FQU_PLACA2", 'FQUMASTER', "FQU_VEICU2", 3)
oModel:AddRules('FQUMASTER', "FQU_VEICU3", 'FQUMASTER', "FQU_VEICU2", 3)
oModel:AddRules('FQUMASTER', "FQU_PLACA3", 'FQUMASTER', "FQU_VEICU3", 3)

oModel:InstallEvent( 'LOCA229AEVDEF', /*cOwner*/, oEventMain )

Return oModel


/*/{Protheus.doc} ViewDef
Define a View da Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA229A' )
Local oStruFQU := FWFormStruct( 2, 'FQU', /*bAvalCampo*/,/*lViewUsado*/ )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQU', oStruFQU, 'FQUMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQU', 'TELA' )

Return oView

/*/{Protheus.doc} LOCA229TGA
Gatilho do campo FQU_ASF
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna .t.
/*/
Static function LOCA229TGA()
Local aArea := GetArea()
Local oModel   := FWModelActive()
Local oModelFQU:= oModel:GetModel("FQUMASTER")
Local cRet := oModelFQU:GetValue("FQU_PROJET")

dbSelectArea("FP0")
dbSetOrder(1)
dbSeek(xFilial("FP0")+oModelFQU:GetValue("FQU_PROJET"))
oModelFQU:LoadValue("FQU_CLIENT", FP0->FP0_CLI)
oModelFQU:LoadValue("FQU_LOJA", FP0->FP0_LOJA)
oModelFQU:LoadValue("FQU_NOMCLI", FP0->FP0_CLINOM)

RestArea(aArea)
return  cRet

/*/{Protheus.doc} LOCA229TGB
Gatilho do campo FQU_ASF
@type function
@version 24.10
@author Alexandre Circenis
@since 2/12/2025
@return variant, return_true
/*/
Static function LOCA229TGB()
Local aArea := GetArea()
Local oModel   := FWModelActive()
Local oModelFQU:= oModel:GetModel("FQUMASTER")
Local lMvLocx304 := GetMv("MV_LOCX304")
Local cRet := oModelFQU:GetValue("FQU_ASF")

oModelFQU:LoadValue("FQU_VIAGEM", Posicione("FQ5", 9, xFilial("FQ5")+oModelFQU:GetValue("FQU_ASF"), "FQ5_VIAGEM"))

If Empty(oModelFQU:GetValue("FQU_OBRA"))
	oModelFQU:SetValue("FQU_OBRA", Posicione("FQ5", 9, xFilial("FQ5")+oModelFQU:GetValue("FQU_ASF"), "FQ5_OBRA") )
EndIf

if lMvLocx304
	dbSelectArea("FQ7")
	dbSetOrder(3)
	dbSeek(xFilial("FQ7")+oModelFQU:GetValue("FQU_VIAGEM"))
	oModelFQU:LoadValue("FQU_CLIDES", FQ7->FQ7_LCCDES)
	oModelFQU:LoadValue("FQU_LOJDES", FQ7->FQ7_LCLDES)
	oModelFQU:LoadValue("FQU_NOMDES", FQ7->FQ7_LOCDES)
	oModelFQU:LoadValue("FQU_ENDDES", FQ7->FQ7_ENDEST)
	oModelFQU:LoadValue("FQU_BAIDES", FQ7->FQ7_BRRDES)
	oModelFQU:LoadValue("FQU_MUNDES", FQ7->FQ7_MUNDES)
	oModelFQU:LoadValue("FQU_ESTDES", FQ7->FQ7_UFDEST)
	oModelFQU:LoadValue("FQU_CEPDES", FQ7->FQ7_CEPDES)
	oModelFQU:SetValue("FQU_TIPOVE", FQ7->FQ7_X5COD)
else
	dbSelectArea("FP1")
	dbSetOrder(1)
	dbSeek(xFilial("FP1")+oModelFQU:GetValue("FQU_PROJET")+oModelFQU:GetValue("FQU_OBRA"))
	oModelFQU:LoadValue("FQU_CLIDES", FP1->FP1_CLIORI)
	oModelFQU:LoadValue("FQU_LOJDES", FP1->FP1_LOJORI)
	oModelFQU:LoadValue("FQU_NOMDES", FP1->FP1_NOMORI)
	oModelFQU:LoadValue("FQU_ENDDES", FP1->FP1_ENDORI)
	oModelFQU:LoadValue("FQU_BAIDES", FP1->FP1_BAIORI)
	oModelFQU:LoadValue("FQU_MUNDES", FP1->FP1_MUNORI)
	oModelFQU:LoadValue("FQU_ESTDES", FP1->FP1_ESTORI)
	oModelFQU:LoadValue("FQU_CEPDES", FP1->FP1_CEPORI)
	oModelFQU:SetValue("FQU_TIPOVE",  Posicione("FQ7", 3, xFilial("FQ7")+oModelFQU:GetValue("FQU_VIAGEM"), "FQ7_X5COD"))
endif

RestArea(aArea)

return cRet

/*/{Protheus.doc} LOCA229TGC
Gatilho do campo FQU_MOTCOD (Codigo do Motorista)
@type function
@version 24.10
@author Alexandre Circenis
@since 2/12/2025
@return variant, return_true
/*/
Static function LOCA229TGC()
Local aArea := GetArea()
Local oModel   := FWModelActive()
Local oModelFQU:= oModel:GetModel("FQUMASTER")
Local cRet := oModelFQU:GetValue("FQU_MOTCOD")

dbSelectArea("DA4")
dbSetOrder(1)
dbSeek(xFilial("DA4")+oModelFQU:GetValue("FQU_MOTCOD"))

oModelFQU:LoadValue("FQU_MOTORI", DA4->DA4_NOME)
oModelFQU:LoadValue("FQU_CPFMOT", DA4->DA4_CGC)


RestArea(aArea)
return cRet

/*/{Protheus.doc} LOCA229AVP
Valida o projeto informado na demanda
@type function
@version 24.10
@author Alexandre Circenis
@since 3/6/2025
@return variant, .T. se o projeto for valido 
/*/
Function LOCA229AVP()
Local lRet := .T.
Local oModel   := FWModelActive()

if !(Posicione("FP0",1,xFilial("FP0")+M->FQU_PROJET,"FP0_STATUS") $ "15" )
   	oModel:SetErrorMessage("","","","","LOCA229A_02",STR0008,) //"Contrato tem que estar ativo para gerar demanda." //"Contrato tem que estar ativo para gerar romaneio!"
	lRet := .F.
elseif EMPTY(ALLTRIM(GETADVFVAL("FQ5", "FQ5_SOT",XFILIAL("FQ5") + M->FQU_PROJET,08,"")))
	oModel:SetErrorMessage("","","","","LOCA229A_01",STR0018,) //"Contrato não possui A.S. geradas." //"Contrato não possui A.S. geradas!"
	lRet := .F.
endif

Return lRet
/*/{Protheus.doc} LOCA229XVD
Valida Data
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/29/2025
@param cTipo, character, Tipo da data ser Validada (1) Data Inicio Embarque (2) Data Final de Embarque (3) Data Inicio Desembarque (4) Data Final Desembarque
@return variant, .T. se data valida
/*/
Function LOCA229XVD( cTipo )
Local lRet := .T.
Local oModel   := FWModelActive()
Local dData := &(ReadVar())

If !Vazio()

	if dData < dDatabase
	   	oModel:SetErrorMessage("","","","","LOCA229A_04",STR0009,) //"Contrato tem que estar ativo para gerar demanda." //"Data deve ser maior ou igual a data do sistema!"
		lRet := .F.
	elseif cTipo = '2'
		if dData < FwFldGet("FQU_DINEMB")
	   		oModel:SetErrorMessage("","","","","LOCA229A_05",STR0010,) //"Contrato tem que estar ativo para gerar demanda." //"Data deve ser maior ou igual a data de Inicio de Embarque!"
			lRet := .F.
		endif
	elseif cTipo = '3'
		if dData < FwFldGet("FQU_DFIEMB")
	   		oModel:SetErrorMessage("","","","","LOCA229A_06",STR0011,) //"Contrato tem que estar ativo para gerar demanda." //"Data deve ser maior ou igual a data de Final de Embarque!"
			lRet := .F.
		endif
	elseif cTipo = '4'
		if dData < FwFldGet("FQU_DINDES")
	   		oModel:SetErrorMessage("","","","","LOCA229A_07",STR0012,) //"Contrato tem que estar ativo para gerar demanda." //"Data deve ser maior ou igual a data de Inicio de Desembarque!"
			lRet := .F.
		endif
	endif
endif

Return lRet
/*/{Protheus.doc} LOCA229XVP
Valida o periodo de embarque e desembarque
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/29/2025
@param cTipo, character, Tipo do periodo (1) Inicio Embarque (2) Final do Embarque (3) Inicio Desembarque (4) Final Desembarque
@return variant, .T. se periodo valido
/*/
Function LOCA229XVP( cTipo )
Local lRet := .T.
Local oModel   := FWModelActive()
Local cHora := &(ReadVar())

	if cTipo = '2'
		if  Dtos(FwFldGet("FQU_DFIEMB"))+cHora< Dtos(FwFldGet("FQU_DINEMB"))+FwFldGet("FQU_HINEMB")
	   		oModel:SetErrorMessage("","","","","LOCA229A_08",STR0013,) //"Contrato tem que estar ativo para gerar demanda." //"O final do embarque deve ocorrer junto ou após o inicio do embarque!"
			lRet := .F.
		endif
	elseif cTipo = '3'
		if Dtos(FwFldGet("FQU_DINDES"))+cHora< Dtos(FwFldGet("FQU_DFIEMB"))+FwFldGet("FQU_HFIEMB")
	   		oModel:SetErrorMessage("","","","","LOCA229A_09",STR0014,) //"Contrato tem que estar ativo para gerar demanda." //"O incio do desembarque deve ocorrer junto ou após o final do embarque!"
			lRet := .F.
		endif
	elseif cTipo = '4'
		if Dtos(FwFldGet("FQU_DFIDES"))+cHora< Dtos(FwFldGet("FQU_DINDES"))+FwFldGet("FQU_HINDES")
	   		oModel:SetErrorMessage("","","","","LOCA229A_10",STR0015,) //"Contrato tem que estar ativo para gerar demanda." //"O final do desembarque deve ocorrer junto ou após o inicio do desembarque!"
			lRet := .F.
		endif
	endif

Return lRet

/*/{Protheus.doc} Loca229AVO
Valida a Obra informada
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/23/2025
@return variant, return se a obra é valida
/*/
Function Loca229AVO()
Local lRet := .T.
Local oModel   := FWModelActive()
Local aArea := GetArea()
Local aAreaFQ5 := FQ5->(GetArea())

if !Empty(M->FQU_OBRA)
	if !Existcpo("FP1",FWFldGet("FQU_PROJET")+FWFldGet("FQU_OBRA"))
		lRet := .F.

	elseif !Empty(FwFldGet("FQU_ASF"))
		dbSelectArea("FQ5")
		dbSetOrder(9)
		dbSeek(xFilial("FQ5")+M->FQU_ASF)
	   	if FQ5->FQ5_OBRA <> FwFldGet("FQU_OBRA")
	   		oModel:SetErrorMessage("","","","","LOCA229A_11",STR0019,STR0020)  //"A Obra informada é a mesma da A.S.F. informada." //"Deixa a obra em branco e selecione uma A.S.F. da obra desejada ou deixe a A.S.f em branco para informar outra obra."
			lRet := .F.
		endif

	endif
endif
RestArea(aAreaFQ5)
RestArea(aArea)

Return lRet


/*/{Protheus.doc} Loca229AVA
Validações A.S.F.
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/23/2025
@return variant, .T. se a A.S.F. for valida
/*/
Function Loca229AVA()
Local lRet := .T.
Local oModel   := FWModelActive()
Local aArea    := GetArea()
Local aAreaFQ5  := FQ5->(GetArea())
Local aAreaFQ7  := FQ7->(GetArea())

if !Empty(M->FQU_ASF)
	dbSelectArea("FQ5")
	dbSetOrder(9)
	if !dbSeek(xFilial("FQ5")+M->FQU_ASF)
		oModel:SetErrorMessage("","","","","LOCA229A_12",STR0021,)  //"A.S.F. informada não cadastrada"
		lRet := .F.
	elseif FQ5->FQ5_TPAS <> 'F'
		oModel:SetErrorMessage("","","","","LOCA229A_13",STR0022,) //"A A.S.F. informada não é do tipo Frete."
		lRet := .F.
	elseif !Empty( FwFldGet("FQU_OBRA")) .and. FQ5->FQ5_OBRA <> FwFldGet("FQU_OBRA")
		oModel:SetErrorMessage("","","","","LOCA229A_14",STR0023,)  //"A A.S.F. informada não pertence a obra informada."
		lRet := .F.
	else
		dbSelectArea("FQ7")
		dbSetOrder(3)
		dbSeek(xFilial("FQ7")+FQ5->FQ5_VIAGEM)

		if FQ7->FQ7_TPROMA <> '0'
			oModel:SetErrorMessage("","","","","LOCA229A_15",STR0024,)  //"A A.S.F informada não é de um conjunto transportador do tipo 'Saida'"
			lRet := .F.
		endif
	endif
endif

RestArea(aAreaFQ7)
RestArea(aAreaFQ5)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} LOCA229ACF
Valida a alocação dos itens de transporte do romaneio
@type function
@version  25.10
@author Alexandre Circenis
@since 5/27/2025
@param cTipo, character, Tipo da Validação
0 => Motorista
1 => Veiculo 1
2 => Veiculo 2
3 => Veiculo 3
4 => Picking (Doca)
@return variant, Retorna .t. de o Item Ok ou .F. se item apresentou sobreposição 
/*/
Function LOCA229ACF(cTipo)
Local aArea := GetArea()
Local cQuery := ""
Local aParam   := {}
Local cAliasT    := GetNextAlias()
Local aHelp     
Local cHelp := ""
Local cNecPick := STR0026+FQU->FQU_HINEMB+STR0025+Dtoc(FQU->FQU_DINEMB)+ ; //" do dia " //" das "
			STR0027+FQU->FQU_HFIEMB+STR0025+Dtoc(FQU->FQU_DFIEMB) //" até as " //" do dia "
Local cNecTran := STR0026+FQU->FQU_HINEMB+STR0025+Dtoc(FQU->FQU_DINEMB)+ ; //" das " //" do dia "
			STR0027+FQU->FQU_HFIDES+STR0025+Dtoc(FQU->FQU_DFIDES) //" do dia " //" até as "

cQuery += "SELECT FQU_NUM, FQU_DINEMB, FQU_HINEMB, FQU_DFIEMB, FQU_HFIEMB, FQU_DFIDES, FQU_HFIDES"
cQuery += " FROM "+RetSqlName("FQU")
cQuery += " WHERE FQU_NUM <> ? "
Aadd(aParam, FQU->FQU_NUM)
if cTipo = '0' // Motorista
	cQuery += " and FQU_MOTCOD = ? "
	Aadd(aParam, FQU->FQU_MOTCOD)
elseif cTipo = '1' // Veiculo 1
	cQuery += " and FQU_VEICUL = ? "
	Aadd(aParam, FQU->FQU_VEICUL)
elseif cTipo = '2' // Veiculo 2
	cQuery += " and FQU_VEICU2 = ? "
	Aadd(aParam, FQU->FQU_VEICU2)
elseif cTipo = '3' // Veiculo 3
	cQuery += " and FQU_VEICU3 = ? "
	Aadd(aParam, FQU->FQU_VEICU3)
elseif cTipo = '4' // PICKING
	cQuery += " and FQU_PICKIN = ? "
	Aadd(aParam, FQU->FQU_PICKIN)
endif

// Veiculos e Motoristas estão alocados do inicio do embarque até o final do desembarque
// Picking (Doca) esta alocada do inicio do embarque até o final do embarque

if cTipo = '4'
	cQuery += " and FQU_DINEMB > ' ' and ( FQU_DINEMB < ? or ( FQU_DINEMB = ? and FQU_HINEMB < ? ))"
	Aadd(aParam, Dtos(FQU->FQU_DFIEMB))
	Aadd(aParam, Dtos(FQU->FQU_DFIEMB))
	Aadd(aParam, FQU->FQU_HFIEMB)
	cQuery += " and FQU_DFIEMB > ' ' and ( FQU_DFIEMB > ? or ( FQU_DFIEMB = ? and FQU_HFIEMB > ? ))"
	Aadd(aParam, Dtos(FQU->FQU_DINEMB))
	Aadd(aParam, Dtos(FQU->FQU_DINEMB))
	Aadd(aParam, FQU->FQU_HINEMB)
else
	cQuery += " and FQU_DINEMB > ' ' and ( FQU_DINEMB < ? or ( FQU_DINEMB = ? and FQU_HINEMB < ? ))"
	Aadd(aParam, Dtos(FQU->FQU_DFIDES))
	Aadd(aParam, Dtos(FQU->FQU_DFIDES))
	Aadd(aParam, FQU->FQU_HFIDES)	
	cQuery += " and FQU_DFIEMB > ' ' and ( FQU_DFIDES > ? or ( FQU_DFIDES = ? and FQU_HFIDES > ? ))"
	Aadd(aParam, Dtos(FQU->FQU_DINEMB))
	Aadd(aParam, Dtos(FQU->FQU_DINEMB))
	Aadd(aParam, FQU->FQU_HINEMB)
endif

cQuery += " and  D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
//-- Executa QUERY
MPSysOpenQuery(cQuery,cAliasT,,,aParam)


if cTipo = '0' // Motorista
	aHelp := { (cAliasT)->(Eof()), STR0029+FQU->FQU_MOTCOD+" - "+Alltrim(FQU->FQU_MOTORI)+ STR0028+ cNecTran,{}} //" | Alocado " //"O Motorista "
elseif cTipo = '1' // Veiculo 1
	aHelp := { (cAliasT)->(Eof()), STR0030+FQU->FQU_VEICUL+ " - "+ Posicione("DA3",1, xFilial("DA3")+FQU->FQU_VEICUL,"DA3_DESC+' "+STR0031+ " '+DA3_PLACA")+ STR0028+cNecTran,{}} //"O Veiculo " //" | Alocado " //"placa"
elseif cTipo = '2' // Veiculo 2
	aHelp := { (cAliasT)->(Eof()), STR0030+FQU->FQU_VEICU2+ " - "+ Posicione("DA3",1, xFilial("DA3")+FQU->FQU_VEICU2,"DA3_DESC+' "+STR0031+ " '+DA3_PLACA")+ STR0028+ cNecTran,{}} //"O Veiculo " //" | Alocado " //"placa"
elseif cTipo = '3' // Veiculo 3
	aHelp := { (cAliasT)->(Eof()), STR0030+FQU->FQU_VEICU3+ " - "+ Posicione("DA3",1, xFilial("DA3")+FQU->FQU_VEICU3,"DA3_DESC+' "+STR0031+ " '+DA3_PLACA")+ STR0028+ cNecTran,{}} //"O Veiculo " //" | Alocado " //"placa"
elseif cTipo = '4' // PICKING
	aHelp := { (cAliasT)->(Eof()), STR0032+FQU->FQU_PICKIN+ " - "+ Posicione("DC8",1, xFilial("DC8")+FQU->FQU_PICKIN,"DC8_DESEST") + STR0028+ cNecPick,{}} //"O Picking " //" | Alocado "
endif


if !(cAliasT)->(Eof())
	cHelp := ""
	While !(cAliasT)->(Eof())
		cHelp += STR0033+(cAliasT)->FQU_NUM //" Já possui alocação no romaneio "
		if cTipo = '4'
			cHelp += STR0026+(cAliasT)->FQU_HINEMB+STR0025+Dtoc(Stod((cAliasT)->FQU_DINEMB))+ ; //" do dia " //" das "
			STR0027+(cAliasT)->FQU_HFIEMB+STR0025+Dtoc(Stod((cAliasT)->FQU_DFIEMB)) //" até as " //" do dia "
		else
			cHelp += STR0026+(cAliasT)->FQU_HINEMB+STR0025+Dtoc(Stod((cAliasT)->FQU_DINEMB))+ ; //" do dia " //" das "
			STR0027+(cAliasT)->FQU_HFIDES+STR0025+Dtoc(Stod((cAliasT)->FQU_DFIDES)) //" até as " //" do dia "
		endif	

		Aadd( aHelp[3], { .F., cHelp})
		cHelp := ""
		(cAliasT)->(dbSkip())
	enddo
else
	Aadd( aHelp[3], {.T., STR0034}) //"Não foram encontrados conflitos"
endif

RestArea(aArea)

Return aHelp

/*/{Protheus.doc} Loca229AFI
Rotorna a necessidade de capacidade para montagem de carga
@type function
@version  25.10
@author Alexandre Circenis
@since 5/28/2025
@param cRomaneio, character, Codigo do Romaneio 
@param cTipo, character, Tipo da necessidade:
 1 = Peso Bruto
 2 = Cubagem (m3)
@return variant, Total de Necessidade 
/*/
Function Loca229AFI(cRomaneio, cTipo)
Local nValor := 0
Local aArea := GetArea()
Local cQuery := ""
Local aBind  := {}
Local cAliasT := GetNextAlias()

if cTipo = '1' // Peso Bruto
	cQuery += "SELECT Sum(FQ5_PESBRU) VALOR "
elseif cTipo = '2' // Cubagem (m3)
	cQuery  += "SELECT Sum(FQ5_M3) VALOR"
endif
cQuery += " FROM "+RetSqlName("FQ5")
cQuery += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"'"
cQuery += " AND FQ5_XROMAN = ? "
Aadd( aBind, cRomaneio)
cQuery += " AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
//-- Executa QUERY
MPSysOpenQuery(cQuery,cAliasT,,,aBind)

if !(cAliasT)->(Eof())
	nValor := (cAliasT)->VALOR
endif
RestArea(aArea)

Return nValor

/*/{Protheus.doc} Loca229AOK
Processa a verificação de alocação de recursos ou da capacidade de transporte
@type function
@version 25.10  
@author Alexandre Circenis
@since 6/6/2025
@param oModel, object, Modelo de origem 
@return variant, .T.  sempre .t.
/*/
Function Loca229AOK()
Local aEventos := {}

if !Empty(FQU->FQU_MOTCOD) // Validar se há sobreposição do motorista
	Aadd( aEventos , LOCA229ACF("0"))
endif
if !Empty(FQU->FQU_VEICUL) // Validar se há sobreposição de veiculos e capacidade
	Aadd( aEventos ,LOCA229ACF("1"))
	if !Empty(FQU->FQU_VEICU2)
		Aadd( aEventos ,LOCA229ACF("2"))
		if !Empty(FQU->FQU_VEICU3)
			Aadd( aEventos ,LOCA229ACF("3"))
		endif
	endif
endif

if !Empty( FQU->FQU_PICKIN) // Validar se há sobreposiçã do Pickin (doca)
	Aadd( aEventos ,LOCA229ACF("4"))
endif

Aadd( aEventos , LOCA229ACP( FQU->FQU_NUM))

Return aEventos

/*/{Protheus.doc} Loca229AVV
Valida se não há repetição de veiculos no romaneio
@type function
@version  25.10
@author Alexandre Circenis
@since 6/9/2025
@param cCampo, character , 1=Veiculo 1;2=Veiculo 2;3=Veiculo 3
@return variant, .T. se não houver repetição e .F. de houver repeticao
/*/
FUNCTION Loca229AVV( cCampo )
Local lRet := .T.
Local cVar := &(ReadVar())
Local oModel := FWModelActive()
Local oModelFQU := oModel:GetModel("FQUMASTER") 

if !Empty(cVar) // Se veiculo não vazio verificar se não há repetição

	if cCampo = '1' // Primeiro veiculo comparar com os veiculos 2 e 3
		if cVar = oModelFQU:GetValue("FQU_VEICU2") .or. cVar = oModelFQU:GetValue("FQU_VEICU3")
			oModel:SetErrorMessage("","","","","LOCA229A_21",STR0035+cVar+ STR0036,) //"O veiculo informado " //" já foi usado com veiculo 2 ou veiculo 3."
			lRet := .F.
		endif
	elseif cCampo = '2' // Segundo veiculo comparar com os veiculos 1 e 3
		if cVar = oModelFQU:GetValue("FQU_VEICUL") .or. cVar = oModelFQU:GetValue("FQU_VEICU3")
			oModel:SetErrorMessage("","","","","LOCA229A_22",STR0035+cVar+ STR0037,) //"O veiculo informado " //" já foi usado com veiculo 1 ou veiculo 3."
			lRet := .F.
		endif
	elseif cCampo = '3' // Terceiro veiculo comparar com os veiculos 1 e 2
		if cVar = oModelFQU:GetValue("FQU_VEICUL") .or. cVar = oModelFQU:GetValue("FQU_VEICU2")
			oModel:SetErrorMessage("","","","","LOCA229A_23",STR0035+cVar+ STR0038,) //"O veiculo informado " //" já foi usado com veiculo 1 ou veiculo 2"
			lRet := .F.
		endif
	endif
endif

return lRet

/*/{Protheus.doc} Loca229AEV
Função chamda ao final da gravação do Cabeçalho do romaneio, permite a inclusção dos itens 
e apresenta a analise do carregamento.
@type function
@version 25.10 
@author Alexandre Circenis
@since 6/10/2025
@param oModel, object, Model do cabeçalho do romaneio
@return variant, Nenhum retorno esperado
/*/
Function Loca229AEV(oModel)

If FQU->FQU_FCHEMB = '2' .and. MsgYesNo(STR0016,STR0017) //"Deseja incluir os itens agora?" //"Itens do Romaneio"
	Loca229C(oModel) 
endif

LOCA229AC() // Processar analise de carregamento

RETURN 


/*/{Protheus.doc} LOCA229ACP
Analisa a Capcidade de Carga dos veiculos alocados contra o total dos itens do romaneio
@type function
@version 25.10
@author Alexandre Circenis
@since 6/6/2025
@param cRomaneio, character, Codigo do Romaneio
@return variant, Array com as mensagens de analise do capacidade de carga dos veiculos
/*/
Function LOCA229ACP( cRomaneio)
Local aArea := GetArea()
Local nCapPeso := 0
Local nCapVol  := 0 
Local nNewPeso := 0
Local nNewVol  := 0
Local nTaraTot := 0

//DEFAULT lItens := .T.

// Quanto já está
nNewPeso += Loca229AFI(cRomaneio,'1')
nNewVol  += Loca229AFI(cRomaneio,'2')

// Capacidade de Carga
dbSelectArea("DA3")
dbSetOrder(1)
if !Empty(FQU->FQU_VEICUL)
	DA3->(dbSeek(xFilial("DA3")+FQU->FQU_VEICUL))
	nCapPeso += DA3->DA3_CAPACM
	nCapVol  += DA3->(DA3_ALTINT * DA3_LARINT * DA3_COMINT)
	nTaraTot += DA3->DA3_TARA
	if !Empty(FQU->FQU_VEICU2)
		DA3->(dbSeek(xFilial("DA3")+FQU->FQU_VEICU2))
		nCapPeso += DA3->DA3_CAPACM
		nCapVol  += DA3->(DA3_ALTINT * DA3_LARINT * DA3_COMINT)
		nTaraTot += DA3->DA3_TARA
		if !Empty(FQU->FQU_VEICU3)
			DA3->(dbSeek(xFilial("DA3")+FQU->FQU_VEICU3))
			nCapPeso += DA3->DA3_CAPACM
			nCapVol  += DA3->(DA3_ALTINT * DA3_LARINT * DA3_COMINT)
			nTaraTot += DA3->DA3_TARA
		endif
	endif
endif


aHelp := {nCapPeso >= nNewPeso .and. nCapvol >= nNewVol, STR0039, {}} //"Avaliação na Capacidade de Carga do Veiculos"
Aadd(aHelp[3], { nCapPeso >=nNewPeso, STR0042+Alltrim(Transform(nCapPeso, "@e 999,999,999.99"))+ " kg | Peso total do romaneio "+Alltrim(Transform(nNewPeso,"@e 999,999,999.99"))+STR0040+ Alltrim(Transform(nCapPeso-nNewPeso,"@e 999,999,999.99"))+STR0041}) //" kg | Disponivel " //" kg" //"Capacidade de transporte de peso "
Aadd(aHelp[3], {nCapvol >= nNewVol, STR0045+Alltrim(Transform(nCapVol,"@e 999,999.9999"))+ STR0046+Alltrim(Transform(nNewVol,"@e 999,999.9999"))+STR0043+ Alltrim(Transform(nCapVol-nNewVol,"@e 999,999.9999"))+STR0044}) //" m³ | Disponivel " //"m³" //"Cubagem total dos veiculos " //" m³ | Cubagem total do romaneio "
Aadd(aHelp[3], { .T. , STR0048+Alltrim(Transform((nTaraTot+nNewPeso)/1000,"@e 999,999.9999"+STR0047))}) //" Ton" //"Peso Bruto Total (PBT) "

RestArea(aArea)

RETURN aHelp
