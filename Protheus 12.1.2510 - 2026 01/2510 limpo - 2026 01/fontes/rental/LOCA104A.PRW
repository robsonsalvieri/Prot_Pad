#Include "loca104a.ch"
#Include "TOTVS.CH"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} LOCA104A
Função para inclusão de romaneio de devolução
@version 25.10
@author Alexandre Circenis
@since 4/14/2025
/*/

/*/{Protheus.doc} MODELDEF
Definicão do modelo de 
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo de Cabeçalho de Demanda
/*/
STATIC FUNCTION MODELDEF()
Local oStruFQW := FWFormStruct( 1, 'FQW', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
Local oEventMain	As Object

oEventMain	:= LOCA104AEVDEF():New() // Define novos eventos 

oModel := MPFormModel():New( 'LOCA104A', /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/, /*bCancel*/ )
oSTruFQW:SetProperty("FQW_PROJET",MODEL_FIELD_WHEN, {|| (Empty(FwFldGet("FQW_PROJET")) .or. M->FQW_STATUS = '1') } )
oSTruFQW:SetProperty("FQW_OBRA",MODEL_FIELD_WHEN, {|| Empty(FwFldGet("FQW_OBRA")) .or. M->FQW_STATUS = '1' } )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FQWMASTER', /*cOwner*/, oStruFQW, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0007 ) //'Gestão de Demandas' //"Romaneio de Expedição" //"Romaneio de Devolução"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FQWMASTER' ):SetDescription(STR0007) //'Demanda' //"Romaneio de Expedição" //"Romaneio de Devolução"
oModel:SetPrimaryKey({"FQW_FILIAL","FQW_DEMAND"})
// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActive( { | oModel | COMP012ACT( oModel ) }
//Regras de preenchimento
oModel:AddRules('FQWMASTER', "FQW_OBRA", 'FQWMASTER', "FQW_PROJET", 3)
oModel:AddRules('FQWMASTER', "FQW_ASF" , 'FQWMASTER', "FQW_PROJET", 3)

oModel:AddRules('FQWMASTER', "FQW_DFIEMB", 'FQWMASTER', "FQW_DINEMB", 3)
oModel:AddRules('FQWMASTER', "FQW_HINEMB", 'FQWMASTER', "FQW_DINEMB", 3)
oModel:AddRules('FQWMASTER', "FQW_DFIEMB", 'FQWMASTER', "FQW_DINEMB", 3)
oModel:AddRules('FQWMASTER', "FQW_HFIEMB", 'FQWMASTER', "FQW_DFIEMB", 3)
oModel:AddRules('FQWMASTER', "FQW_DINDES", 'FQWMASTER', "FQW_DFIEMB", 3)
oModel:AddRules('FQWMASTER', "FQW_HINDES", 'FQWMASTER', "FQW_DINDES", 3)
oModel:AddRules('FQWMASTER', "FQW_DFIDES", 'FQWMASTER', "FQW_DINDES", 3)
oModel:AddRules('FQWMASTER', "FQW_HFIDES", 'FQWMASTER', "FQW_DFIDES", 3)

oModel:AddRules('FQWMASTER', "FQW_PLACA" , 'FQWMASTER', "FQW_VEICUL", 3)
oModel:AddRules('FQWMASTER', "FQW_VEICU2", 'FQWMASTER', "FQW_VEICUL", 3)
oModel:AddRules('FQWMASTER', "FQW_PLACA2", 'FQWMASTER', "FQW_VEICU2", 3)
oModel:AddRules('FQWMASTER', "FQW_VEICU3", 'FQWMASTER', "FQW_VEICU2", 3)
oModel:AddRules('FQWMASTER', "FQW_PLACA3", 'FQWMASTER', "FQW_VEICU3", 3)

oModel:InstallEvent( 'LOCA104AEVDEF', /*cOwner*/, oEventMain )
// Liga a validação da ativacao do Modelo de Dados
oModel:SetVldActive( { | oModel | LOCA104AAC( oModel ) })

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
Local oModel   := FWLoadModel( 'LOCA104A' )
Local oStruFQW := FWFormStruct( 2, 'FQW', /*bAvalCampo*/,/*lViewUsado*/ )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQW', oStruFQW, 'FQWMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQW', 'TELA' )

Return oView

/*/{Protheus.doc} LOCA104TGA
Gatilho do campo FQW_ASF
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna .t.
/*/
function LOCA104TGA()
Local aArea := GetArea()
Local oModel   := FWModelActive()
Local oModelFQW:= oModel:GetModel("FQWMASTER")
Local cRet := oModelFQW:GetValue("FQW_PROJET")

dbSelectArea("FP0")
dbSetOrder(1)
dbSeek(xFilial("FP0")+oModelFQW:GetValue("FQW_PROJET"))
oModelFQW:LoadValue("FQW_CLIENT", FP0->FP0_CLI)
oModelFQW:LoadValue("FQW_LOJA", FP0->FP0_LOJA)
oModelFQW:LoadValue("FQW_NOMCLI", FP0->FP0_CLINOM)

RestArea(aArea)
return  cRet

/*/{Protheus.doc} LOCA104TGB
Gatilho do campo FQW_ASF
@type function
@version 24.10
@author Alexandre Circenis
@since 2/12/2025
@return variant, return_true
/*/
function LOCA104TGB()
Local aArea := GetArea()
Local oModel   := FWModelActive()
Local oModelFQW:= oModel:GetModel("FQWMASTER")
Local lMvLocx304 := GetMv("MV_LOCX304") // Usar o Cliente fo Conjunto Transportador (FQ7)
Local cRet := oModelFQW:GetValue("FQW_ASF")
Local lCliObra	:= SUPERGETMV("MV_LOCX204",.F.,.T.) // Usar o Cliente da Obra (FP1)
Local lNaoAchou := .T.

oModelFQW:LoadValue("FQW_VIAGEM", Posicione("FQ5", 9, xFilial("FQ5")+oModelFQW:GetValue("FQW_ASF"), "FQ5_VIAGEM"))

If Empty(oModelFQW:GetValue("FQW_OBRA"))
	oModelFQW:SetValue("FQW_OBRA", Posicione("FQ5", 9, xFilial("FQ5")+oModelFQW:GetValue("FQW_ASF"), "FQ5_OBRA") )
EndIf

if lMvLocx304 
	dbSelectArea("FQ7")
	dbSetOrder(3)
	dbSeek(xFilial("FQ7")+oModelFQW:GetValue("FQW_VIAGEM"))
	if !Empty(FQ7->FQ7_LCCDES)
		lNaoAchou := .F.
		oModelFQW:LoadValue("FQW_CLIDEV", FQ7->FQ7_LCCDES)
		oModelFQW:LoadValue("FQW_LOJDEV", FQ7->FQ7_LCLDES)
		oModelFQW:LoadValue("FQW_NOMDEV", FQ7->FQ7_LOCDES)
		oModelFQW:LoadValue("FQW_ENDDEV", FQ7->FQ7_ENDEST)
		oModelFQW:LoadValue("FQW_BAIDEV", FQ7->FQ7_BRRDES)
		oModelFQW:LoadValue("FQW_MUNDEV", FQ7->FQ7_MUNDES)
		oModelFQW:LoadValue("FQW_ESTDEV", FQ7->FQ7_UFDEST)
		oModelFQW:LoadValue("FQW_CEPDEV", FQ7->FQ7_CEPDES)
		oModelFQW:SetValue("FQW_TIPOVE", FQ7->FQ7_X5COD)
	endif
endif

if lNaoAchou .and. lCliObra // Não Achou na FQ7 usar a FP1
	dbSelectArea("FP1")
	dbSetOrder(1)
	dbSeek(xFilial("FP1")+oModelFQW:GetValue("FQW_PROJET")+oModelFQW:GetValue("FQW_OBRA"))
	if !Empty(FP1->FP1_CLIORI)
		lNaoAchou := .F.
		oModelFQW:LoadValue("FQW_CLIDEV", FP1->FP1_CLIORI)
		oModelFQW:LoadValue("FQW_LOJDEV", FP1->FP1_LOJORI)
		oModelFQW:LoadValue("FQW_NOMDEV", FP1->FP1_NOMORI)
		oModelFQW:LoadValue("FQW_ENDDEV", FP1->FP1_ENDORI)
		oModelFQW:LoadValue("FQW_BAIDEV", FP1->FP1_BAIORI)
		oModelFQW:LoadValue("FQW_MUNDEV", FP1->FP1_MUNORI)
		oModelFQW:LoadValue("FQW_ESTDEV", FP1->FP1_ESTORI)
		oModelFQW:LoadValue("FQW_CEPDEV", FP1->FP1_CEPORI)
		oModelFQW:SetValue("FQW_TIPOVE",  Posicione("FQ7", 3, xFilial("FQ7")+oModelFQW:GetValue("FQW_VIAGEM"), "FQ7_X5COD"))
	endif
endif

if lNaoAchou // Se não achou o cliente usar o cliente da capa do contrato
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+oModelFQW:GetValue("FQW_CLIENT")+oModelFQW:GetValue("FQW_LOJA"))
	oModelFQW:LoadValue("FQW_CLIDEV", SA1->A1_COD)
	oModelFQW:LoadValue("FQW_LOJDEV", SA1->A1_LOJA)
	oModelFQW:LoadValue("FQW_NOMDEV", SA1->A1_NOME)
	oModelFQW:LoadValue("FQW_ENDDEV", SA1->A1_END)
	oModelFQW:LoadValue("FQW_BAIDEV", SA1->A1_BAIRRO)
	oModelFQW:LoadValue("FQW_MUNDEV", Left(SA1->A1_MUN, 25)) 
	oModelFQW:LoadValue("FQW_ESTDEV", SA1->A1_EST)
	oModelFQW:LoadValue("FQW_CEPDEV", SA1->A1_CEP)
	oModelFQW:SetValue("FQW_TIPOVE",  Posicione("FQ7", 3, xFilial("FQ7")+oModelFQW:GetValue("FQW_VIAGEM"), "FQ7_X5COD"))
endif

RestArea(aArea)

return cRet

/*/{Protheus.doc} LOCA104TGC
Gatilho do campo FQW_MOTCOD (Codigo do Motorista)
@type function
@version 24.10
@author Alexandre Circenis
@since 2/12/2025
@return variant, return_true
/*/
function LOCA104TGC()
Local aArea := GetArea()
Local oModel   := FWModelActive()
Local oModelFQW:= oModel:GetModel("FQWMASTER")
Local cRet := oModelFQW:GetValue("FQW_MOTCOD")

dbSelectArea("DA4")
dbSetOrder(1)
dbSeek(xFilial("DA4")+oModelFQW:GetValue("FQW_MOTCOD"))

oModelFQW:LoadValue("FQW_MOTORI", DA4->DA4_NOME)
oModelFQW:LoadValue("FQW_CPFMOT", DA4->DA4_CGC)


RestArea(aArea)
return cRet

/*/{Protheus.doc} LOCA104AVP
Valida o projeto informado na demanda
@type function
@version 24.10
@author Alexandre Circenis
@since 3/6/2025
@return variant, .T. se o projeto for valido 
/*/
Function LOCA104AVP()
Local lRet := .T.
Local oModel   := FWModelActive()

if !(Posicione("FP0",1,xFilial("FP0")+M->FQW_PROJET,"FP0_STATUS") $ "15" )
   	oModel:SetErrorMessage("","","","","LOCA104A_02",STR0008,)   //"Contrato tem que estar ativo para gerar romaneio!"
	lRet := .F.
elseif EMPTY(ALLTRIM(GETADVFVAL("FQ5", "FQ5_SOT",XFILIAL("FQ5") + M->FQW_PROJET,08,"")))
	oModel:SetErrorMessage("","","","","LOCA104A_01",STR0009,)   //"Contrato não possui A.S. geradas!"
	lRet := .F.
elseif LOC104AItD(M->FQW_PROJET) <= 0
	oModel:SetErrorMessage("","","","","LOCA104A_03", STR0051,)    //"O Contrato informado não possui itens a serem devolvidos!"
	lRet := .F.
endif

Return lRet
/*/{Protheus.doc} LOCA104XVD
Valida Data
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/29/2025
@param cTipo, character, Tipo da data ser Validada (1) Data Inicio Embarque (2) Data Final de Embarque (3) Data Inicio Desembarque (4) Data Final Desembarque
@return variant, .T. se data valida
/*/
Function LOCA104XVD( cTipo )
Local lRet := .T.
Local oModel   := FWModelActive()
Local dData := &(ReadVar())

If !Vazio()

	if dData < dDatabase
	   	oModel:SetErrorMessage("","","","","LOCA104A_04",STR0010,)   //"Data deve ser maior ou igual a data do sistema!"
		lRet := .F.
	elseif cTipo = '2'
		if dData < FwFldGet("FQW_DINEMB")
	   		oModel:SetErrorMessage("","","","","LOCA104A_05",STR0011,)   //"Data deve ser maior ou igual a data de Inicio de Embarque!"
			lRet := .F.
		endif
	elseif cTipo = '3'
		if dData < FwFldGet("FQW_DFIEMB")
	   		oModel:SetErrorMessage("","","","","LOCA104A_06",STR0012,)   //"Data deve ser maior ou igual a data de Final de Embarque!"
			lRet := .F.
		endif
	elseif cTipo = '4'
		if dData < FwFldGet("FQW_DINDES")
	   		oModel:SetErrorMessage("","","","","LOCA104A_07",STR0013,)   //"Data deve ser maior ou igual a data de Inicio de Desembarque!"
			lRet := .F.
		endif
	endif
endif

Return lRet
/*/{Protheus.doc} LOCA104XVP
Valida o periodo de embarque e desembarque
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/29/2025
@param cTipo, character, Tipo do periodo (1) Inicio Embarque (2) Final do Embarque (3) Inicio Desembarque (4) Final Desembarque
@return variant, .T. se periodo valido
/*/
Function LOCA104XVP( cTipo )
Local lRet := .T.
Local oModel   := FWModelActive()
Local cHora := &(ReadVar())

	if cTipo = '2'
		if  Dtos(FwFldGet("FQW_DFIEMB"))+cHora< Dtos(FwFldGet("FQW_DINEMB"))+FwFldGet("FQW_HINEMB")
	   		oModel:SetErrorMessage("","","","","LOCA104A_08",STR0014,)   //"O final do embarque deve ocorrer junto ou após o inicio do embarque!"
			lRet := .F.
		endif
	elseif cTipo = '3'
		if Dtos(FwFldGet("FQW_DINDES"))+cHora< Dtos(FwFldGet("FQW_DFIEMB"))+FwFldGet("FQW_HFIEMB")
	   		oModel:SetErrorMessage("","","","","LOCA104A_09",STR0015,)   //"O incio do desembarque deve ocorrer junto ou após o final do embarque!"
			lRet := .F.
		endif
	elseif cTipo = '4'
		if Dtos(FwFldGet("FQW_DFIDES"))+cHora< Dtos(FwFldGet("FQW_DINDES"))+FwFldGet("FQW_HINDES")
	   		oModel:SetErrorMessage("","","","","LOCA104A_10",STR0016,)   //"O final do desembarque deve ocorrer junto ou após o inicio do desembarque!"
			lRet := .F.
		endif
	endif

Return lRet

/*/{Protheus.doc} Loca104AVO
Valida a Obra informada
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/23/2025
@return variant, return se a obra é valida
/*/
Function Loca104AVO()
Local lRet := .T.
Local oModel   := FWModelActive()
Local aArea := GetArea()
Local aAreaFQ5 := FQ5->(GetArea())

if !Empty(M->FQW_OBRA)
	if !Existcpo("FP1",FWFldGet("FQW_PROJET")+FWFldGet("FQW_OBRA"))
		lRet := .F.

	elseif !Empty(FwFldGet("FQW_ASF"))
		dbSelectArea("FQ5")
		dbSetOrder(9)
		dbSeek(xFilial("FQ5")+M->FQW_ASF)
	   	if FQ5->FQ5_OBRA <> FwFldGet("FQW_OBRA")
	   		oModel:SetErrorMessage("","","","","LOCA104A_11",STR0018,STR0017)  // // //"Deixa a obra em branco e selecione uma A.S.F. da obra desejada ou deixe a A.S.f em branco para informar outra obra." //"A Obra informada não é a mesma da A.S.F. informada."
			lRet := .F.
		endif

	elseif LOC104AItD(M->FQW_PROJET, M->FQW_OBRA) <= 0
		oModel:SetErrorMessage("","","","","LOCA104A_16",STR0052,)   //"Não há itens a serem devolvidos nesse projeto e obra"
		lRet := .F.
	endif
endif
RestArea(aAreaFQ5)
RestArea(aArea)

Return lRet


/*/{Protheus.doc} Loca104AVA
Validações A.S.F.
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/23/2025
@return variant, .T. se a A.S.F. for valida
/*/
Function Loca104AVA()
Local lRet := .T.
Local oModel   := FWModelActive()
Local aArea    := GetArea()
Local aAreaFQ5  := FQ5->(GetArea())
Local aAreaFQ7  := FQ7->(GetArea())

if !Empty(M->FQW_ASF)
	dbSelectArea("FQ5")
	dbSetOrder(9)
	if !dbSeek(xFilial("FQ5")+M->FQW_ASF)
		oModel:SetErrorMessage("","","","","LOCA104A_12",STR0019,)  //" //"A.S.F. informada não cadastrada"
		lRet := .F.
	elseif FQ5->FQ5_TPAS <> 'F'
		oModel:SetErrorMessage("","","","","LOCA104A_13",STR0020,) // //"A A.S.F. informada não é do tipo Frete."
		lRet := .F.
	elseif !Empty( FwFldGet("FQW_OBRA")) .and. FQ5->FQ5_OBRA <> FwFldGet("FQW_OBRA")
		oModel:SetErrorMessage("","","","","LOCA104A_14",STR0021,)  // //"A A.S.F. informada não pertence a obra informada."
		lRet := .F.
	else
		dbSelectArea("FQ7")
		dbSetOrder(3)
		dbSeek(xFilial("FQ7")+FQ5->FQ5_VIAGEM)

		if FQ7->FQ7_TPROMA <> '1'
			oModel:SetErrorMessage("","","","","LOCA104A_15",STR0022,)  //
			lRet := .F.
		endif
	endif
endif

RestArea(aAreaFQ7)
RestArea(aAreaFQ5)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} LOCA104ACF
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
Function LOCA104ACF(cTipo, cRemDev, cBusca, cRomaneio, dDInEmb, cHInEmb, dDFiEmb, cHFiEmb, dDInDes, cHiniDes, dDFiDes, cHFiDes)
Local aArea := GetArea()
Local cQuery := ""
Local aParam   := {}
Local cAliasT    := GetNextAlias()
Local aHelp     
Local cHelp := ""
Local cNecPick   
Local cNecTran := STR0024 + cHInEmb + STR0025 + Dtoc(dDInEmb) + ;   //" das "
			STR0026 + cHFiDes + STR0025 + Dtoc(dDFiDes)   //" do dia "
Local cRomaReme := ' '
Local cRomaDeve := ' '

if cRemDev = 'R' // Se é remessa Picking ocupado no embarque
	cNecPick := STR0024 + cHInEmb + STR0025 + Dtoc(dDInEmb) + ;   //" das "
				STR0026 + cHFiEmb + STR0025 + Dtoc(dDFiEmb) //" do dia "
	cRomaReme := cRomaneio
else // Caso contrario ocupado no Desembarque
	cNecPick := STR0024 + cHIniDes + STR0025 + Dtoc(dDInDes) + ;   //" das "
				STR0026 + cHFiDes + STR0025 + Dtoc(dDFiDes) //" do dia "
	cRomaDeve  := cRomaneio 	
endif

// Query para processar os romaneios de Devolução
cQuery += "SELECT FQW_NUM, FQW_DINEMB, FQW_HINEMB, FQW_DFIEMB, FQW_HFIEMB, FQW_DFIDES, FQW_HFIDES"
cQuery += " FROM "+RetSqlName("FQW")
cQuery += " WHERE FQW_NUM <> ? "
Aadd(aParam, cRomaDeve)
if cTipo = '0' // Motorista
	cQuery += " and FQW_MOTCOD = ? "
	Aadd(aParam, cBusca)
elseif cTipo = '4' // PICKING
	cQuery += " and FQW_PICKIN = ? "
	Aadd(aParam, cBusca)
else  // Comparar os Veiculos
	cQuery += " and ( FQW_VEICUL = ? "
	cQuery += "    or FQW_VEICU2 = ? "
	cQuery += "    or FQW_VEICU3 = ? ) "
	Aadd(aParam, cBusca)
	Aadd(aParam, cBusca)
	Aadd(aParam, cBusca)
endif

// Veiculos e Motoristas estão alocados do inicio do embarque até o final do desembarque
// Picking (Doca) esta alocada do inicio do Desembarque até o final do Desembarque

if cTipo = '4'
	cQuery += " and FQW_DINDES > ' ' and ( FQW_DINDES < ? or ( FQW_DINDES = ? and FQW_HINDES < ? ))"
	Aadd(aParam, Dtos(dDFiDes))
	Aadd(aParam, Dtos(dDFiDes))
	Aadd(aParam, cHFiDes)
	cQuery += " and FQW_DFIDES > ' ' and ( FQW_DFIDES > ? or ( FQW_DFIDES = ? and FQW_HFIDES > ? ))"
	Aadd(aParam, Dtos(dDInDes))
	Aadd(aParam, Dtos(dDInDes))
	Aadd(aParam, cHIniDes)
else
	cQuery += " and FQW_DINEMB > ' ' and ( FQW_DINEMB < ? or ( FQW_DINEMB = ? and FQW_HINEMB < ? ))"
	Aadd(aParam, Dtos(dDFiDes))
	Aadd(aParam, Dtos(dDFiDes))
	Aadd(aParam, cHFiDes)	
	cQuery += " and FQW_DFIEMB > ' ' and ( FQW_DFIDES > ? or ( FQW_DFIDES = ? and FQW_HFIDES > ? ))"
	Aadd(aParam, Dtos(dDInEmb))
	Aadd(aParam, Dtos(dDInEmb))
	Aadd(aParam, cHInEmb)
endif

cQuery += " and  D_E_L_E_T_ = ' '"

cQuery += " UNION "
// Query para processar os Romaneios de Remessa
cQuery += "SELECT FQU_NUM, FQU_DINEMB, FQU_HINEMB, FQU_DFIEMB, FQU_HFIEMB, FQU_DFIDES, FQU_HFIDES"
cQuery += " FROM "+RetSqlName("FQU")
cQuery += " WHERE FQU_NUM <> ? "
Aadd(aParam, cRomaReme)
if cTipo = '0' // Motorista
	cQuery += " and FQU_MOTCOD = ? "
	Aadd(aParam, cBusca)
elseif cTipo = '4' // PICKING
	cQuery += " and FQU_PICKIN = ? "
	Aadd(aParam, cBusca)
else // Veiculos
	cQuery += " and ( FQU_VEICUL = ? "
	cQuery += "    or FQU_VEICU2 = ? "
	cQuery += "    or FQU_VEICU3 = ? )"
	Aadd(aParam, cBusca)
	Aadd(aParam, cBusca)
	Aadd(aParam, cBusca)
endif

// Veiculos e Motoristas estão alocados do inicio do embarque até o final do desembarque
// Picking (Doca) esta alocada do inicio do embarque até o final do embarque

if cTipo = '4'
	cQuery += " and FQU_DINEMB > ' ' and ( FQU_DINEMB < ? or ( FQU_DINEMB = ? and FQU_HINEMB < ? ))"
	Aadd(aParam, Dtos(dDFiEmb))
	Aadd(aParam, Dtos(dDFiEmb))
	Aadd(aParam, cHFiEmb)
	cQuery += " and FQU_DFIEMB > ' ' and ( FQU_DFIEMB > ? or ( FQU_DFIEMB = ? and FQU_HFIEMB > ? ))"
	Aadd(aParam, Dtos(dDInEmb))
	Aadd(aParam, Dtos(dDInEmb))
	Aadd(aParam, cHInEmb)
else
	cQuery += " and FQU_DINEMB > ' ' and ( FQU_DINEMB < ? or ( FQU_DINEMB = ? and FQU_HINEMB < ? ))"
	Aadd(aParam, Dtos(dDFiDes))
	Aadd(aParam, Dtos(dDFiDes))
	Aadd(aParam, cHFiDes)	
	cQuery += " and FQU_DFIEMB > ' ' and ( FQU_DFIDES > ? or ( FQU_DFIDES = ? and FQU_HFIDES > ? ))"
	Aadd(aParam, Dtos(dDInEmb))
	Aadd(aParam, Dtos(dDInEmb))
	Aadd(aParam, cHInEmb)
endif

cQuery += " and  D_E_L_E_T_ = ' '"



cQuery := ChangeQuery(cQuery)
//-- Executa QUERY
MPSysOpenQuery(cQuery,cAliasT,,,aParam)


if cTipo = '0' // Motorista
	aHelp := { (cAliasT)->(Eof()), STR0027+cBusca+" - "+Posicione("DA4",1, xFilial("DA4")+cBusca,"DA4_NOME")+ STR0028+ cNecTran,{}} // //
elseif cTipo $ '1#2#3' // Veiculos
	aHelp := { (cAliasT)->(Eof()), STR0029 +cBusca+ " - "+ Posicione("DA3",1, xFilial("DA3")+cBusca,"DA3_DESC+' "+STR0030+ " '+DA3_PLACA")+ STR0028+cNecTran,{}} // // //
elseif cTipo = '4' // PICKING
	aHelp := { (cAliasT)->(Eof()), STR0031 +cBusca+ " - "+ Posicione("DC8",1, xFilial("DC8")+cBusca,"DC8_DESEST") + STR0028+ cNecPick,{}} // //STR0028
endif


if !(cAliasT)->(Eof())
	cHelp := ""
	While !(cAliasT)->(Eof())
		cHelp += STR0032+(cAliasT)->FQW_NUM  //" Já possui alocação no romaneio "
		if cTipo = '4'
			cHelp += STR0024+(cAliasT)->FQW_HINEMB+STR0025+Dtoc(Stod((cAliasT)->FQW_DINEMB))+ ; // //
			STR0026+(cAliasT)->FQW_HFIEMB+STR0025+Dtoc(Stod((cAliasT)->FQW_DFIEMB)) // //
		else
			cHelp += STR0024+(cAliasT)->FQW_HINEMB+STR0025+Dtoc(Stod((cAliasT)->FQW_DINEMB))+ ; // //
			STR0026+(cAliasT)->FQW_HFIDES+STR0025+Dtoc(Stod((cAliasT)->FQW_DFIDES)) // //
		endif	

		Aadd( aHelp[3], { .F., cHelp})
		cHelp := ""
		(cAliasT)->(dbSkip())
	enddo
else
	Aadd( aHelp[3], {.T., STR0033}) //
endif

RestArea(aArea)

Return aHelp

/*/{Protheus.doc} Loca104AFI
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
Function Loca104AFI(cRomaneio, cTipo)
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

/*/{Protheus.doc} Loca104AOK
Processa a verificação de alocação de recursos ou da capacidade de transporte
@type function
@version 25.10  
@author Alexandre Circenis
@since 6/6/2025
@param oModel, object, Modelo de origem 
@return variant, .T.  sempre .t.
/*/
Function Loca104AOK()
Local aEventos := {}

if !Empty(FQW->FQW_MOTCOD) // Validar se há sobreposição do motorista
	Aadd( aEventos , LOCA104ACF("0", "D", FQW->FQW_MOTCOD, FQW->FQW_NUM  , FQW->FQW_DINEMB, FQW->FQW_HINEMB, ;
	    FQW->FQW_DFIEMB, FQW->FQW_HFIEMB, FQW->FQW_DINDES, FQW->FQW_HINDES, FQW->FQW_DFIDES, FQW->FQW_HFIDES))

endif
if !Empty(FQW->FQW_VEICUL) // Validar se há sobreposição de veiculos e capacidade
	Aadd( aEventos , LOCA104ACF("1", "D", FQW->FQW_VEICUL, FQW->FQW_NUM  , FQW->FQW_DINEMB, FQW->FQW_HINEMB, ;
	    FQW->FQW_DFIEMB, FQW->FQW_HFIEMB, FQW->FQW_DINDES, FQW->FQW_HINDES, FQW->FQW_DFIDES, FQW->FQW_HFIDES))

	if !Empty(FQW->FQW_VEICU2)
		Aadd( aEventos , LOCA104ACF("2", "D", FQW->FQW_VEICU2, FQW->FQW_NUM   , FQW->FQW_DINEMB, FQW->FQW_HINEMB, ;
	  	  FQW->FQW_DFIEMB, FQW->FQW_HFIEMB, FQW->FQW_DINDES, FQW->FQW_HINDES, FQW->FQW_DFIDES, FQW->FQW_HFIDES))

		if !Empty(FQW->FQW_VEICU3)
			Aadd( aEventos , LOCA104ACF("3", "D", FQW->FQW_VEICU3, FQW->FQW_NUM, FQW->FQW_DINEMB, FQW->FQW_HINEMB, ;
			    FQW->FQW_DFIEMB, FQW->FQW_HFIEMB, FQW->FQW_DINDES, FQW->FQW_HINDES, FQW->FQW_DFIDES, FQW->FQW_HFIDES))

		endif
	endif
endif

if !Empty( FQW->FQW_PICKIN) // Validar se há sobreposiçã do Pickin (doca)
	Aadd( aEventos , LOCA104ACF("4", "D", FQW->FQW_PICKIN, FQW->FQW_NUM, FQW->FQW_DINEMB, FQW->FQW_HINEMB, ;
	    FQW->FQW_DFIEMB, FQW->FQW_HFIEMB, FQW->FQW_DINDES, FQW->FQW_HINDES, FQW->FQW_DFIDES, FQW->FQW_HFIDES))

endif

Aadd( aEventos , LOCA104ACP( FQW->FQW_NUM))

Return aEventos

/*/{Protheus.doc} Loca104AVV
Valida se não há repetição de veiculos no romaneio
@type function
@version  25.10
@author Alexandre Circenis
@since 6/9/2025
@param cCampo, character , 1=Veiculo 1;2=Veiculo 2;3=Veiculo 3
@return variant, .T. se não houver repetição e .F. de houver repeticao
/*/
FUNCTION Loca104AVV( cCampo )
Local lRet := .T.
Local cVar := &(ReadVar())
Local oModel := FWModelActive()
Local oModelFQW := oModel:GetModel("FQWMASTER") 

if !Empty(cVar) // Se veiculo não vazio verificar se não há repetição

	if cCampo = '1' // Primeiro veiculo comparar com os veiculos 2 e 3
		if cVar = oModelFQW:GetValue("FQW_VEICU2") .or. cVar = oModelFQW:GetValue("FQW_VEICU3")
			oModel:SetErrorMessage("","","","","LOCA104A_21",STR0035+cVar+ STR0034,)   //" já foi usado com veiculo 2 ou veiculo 3."
			lRet := .F.
		endif
	elseif cCampo = '2' // Segundo veiculo comparar com os veiculos 1 e 3
		if cVar = oModelFQW:GetValue("FQW_VEICUL") .or. cVar = oModelFQW:GetValue("FQW_VEICU3")
			oModel:SetErrorMessage("","","","","LOCA104A_22",STR0035+cVar+ STR0036,)   //"O veiculo informado "
			lRet := .F.
		endif
	elseif cCampo = '3' // Terceiro veiculo comparar com os veiculos 1 e 2
		if cVar = oModelFQW:GetValue("FQW_VEICUL") .or. cVar = oModelFQW:GetValue("FQW_VEICU2")
			oModel:SetErrorMessage("","","","","LOCA104A_23",STR0035+cVar+STR0037,)   //"O veiculo informado "
			lRet := .F.
		endif
	endif
endif

return lRet

/*/{Protheus.doc} Loca104AEV
Função chamda ao final da gravação do Cabeçalho do romaneio, permite a inclusção dos itens 
e apresenta a analise do carregamento.
@type function
@version 25.10 
@author Alexandre Circenis
@since 6/10/2025
@param oModel, object, Model do cabeçalho do romaneio
@return variant, Nenhum retorno esperado
/*/
Function Loca104AEV(oModel)

Local nOpc:=oModel:GetOperation()

if nOpc <> MODEL_OPERATION_VIEW

    if nOpc <> MODEL_OPERATION_DELETE

		If MsgYesNo(STR0038, STR0039)   //"Deseja incluir os itens agora?"
			Loca104B(oModel) 
		endif

		LOCA104AC() // Processar analise de carregamento

	endif

endif

RETURN 


/*/{Protheus.doc} LOCA104ACP
Analisa a Capcidade de Carga dos veiculos alocados contra o total dos itens do romaneio
@type function
@version 25.10
@author Alexandre Circenis
@since 6/6/2025
@param cRomaneio, character, Codigo do Romaneio
@return variant, Array com as mensagens de analise do capacidade de carga dos veiculos
/*/
Function LOCA104ACP( cRomaneio)
Local aArea := GetArea()
Local nCapPeso := 0
Local nCapVol  := 0 
Local nNewPeso := 0
Local nNewVol  := 0
Local nTaraTot := 0

//DEFAULT lItens := .T.

// Quanto já está
nNewPeso += Loca104AFI(cRomaneio,'1')
nNewVol  += Loca104AFI(cRomaneio,'2')

// Capacidade de Carga
dbSelectArea("DA3")
dbSetOrder(1)
if !Empty(FQW->FQW_VEICUL)
	DA3->(dbSeek(xFilial("DA3")+FQW->FQW_VEICUL))
	nCapPeso += DA3->DA3_CAPACM
	nCapVol  += DA3->(DA3_ALTINT * DA3_LARINT * DA3_COMINT)
	nTaraTot += DA3->DA3_TARA
	if !Empty(FQW->FQW_VEICU2)
		DA3->(dbSeek(xFilial("DA3")+FQW->FQW_VEICU2))
		nCapPeso += DA3->DA3_CAPACM
		nCapVol  += DA3->(DA3_ALTINT * DA3_LARINT * DA3_COMINT)
		nTaraTot += DA3->DA3_TARA
		if !Empty(FQW->FQW_VEICU3)
			DA3->(dbSeek(xFilial("DA3")+FQW->FQW_VEICU3))
			nCapPeso += DA3->DA3_CAPACM
			nCapVol  += DA3->(DA3_ALTINT * DA3_LARINT * DA3_COMINT)
			nTaraTot += DA3->DA3_TARA
		endif
	endif
endif


aHelp := {nCapPeso >= nNewPeso .and. nCapvol >= nNewVol, STR0040, {}}  //"Avaliação na Capacidade de Carga do Veiculos"
Aadd(aHelp[3], { nCapPeso >=nNewPeso, STR0043+Alltrim(Transform(nCapPeso, "@e 999,999,999.99"))+ STR0044+Alltrim(Transform(nNewPeso,"@e 999,999,999.99"))+STR0041+ Alltrim(Transform(nCapPeso-nNewPeso,"@e 999,999,999.99"))+STR0042 })   //" kg | Disponivel "
Aadd(aHelp[3], {nCapvol >= nNewVol, STR0047+Alltrim(Transform(nCapVol,"@e 999,999.9999"))+STR0048+Alltrim(Transform(nNewVol,"@e 999,999.9999"))+STR0045+ Alltrim(Transform(nCapVol-nNewVol,"@e 999,999.9999"))+STR0046})   //" m³ | Disponivel "
Aadd(aHelp[3], { .T. , STR0050+Alltrim(Transform((nTaraTot+nNewPeso)/1000,"@e 999,999.9999"+STR0049))})   //" Ton"

RestArea(aArea)

RETURN aHelp

/*/{Protheus.doc} LOC104AItD
Retorna o numero de itens que podem ser devolvidos por projeto ou obra conforme paramteros
@type function
@version 25.10
@author Alexandre Circenis
@since 21/11/2025
@param cContrato, character, Codigo do contrato do qual queremos obter o numero de itens que podem ser devolvidos
@param cObra, character, Ao informar a Obra junto com o Projeto irar retornso u mnumero de itens que podem ser devolvidos
@return variant, Numero de itens (linhas) que tem nota de remessa mas não tem nota de retorno
/*/
Function LOC104AItD(cContrato, cObra)
Local nValor := 0
Local aArea := GetArea()
Local cQuery := ""
Local aBind  := {}
Local cAliasT := GetNextAlias()

DEFAULT cObra := ''

cQuery += "SELECT Count(FPA_AS) VALOR"
cQuery += " FROM "+RetSqlName("FPA")
cQuery += " WHERE FPA_FILIAL = '"+xFilial("FPA")+"'"
cQuery += " AND FPA_PROJET = ? "
Aadd( aBind, cContrato) 
if !Empty(cObra) // se estiver na obra verificar se tem itens para devolver
	cQuery += " AND FPA_OBRA = ? "
	Aadd( aBind, cObra)
endif
cQuery += " AND FPA_NFRET = ' ' "
cQuery += " AND FPA_NFREM <> ' ' "

cQuery += " AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
//-- Executa QUERY
MPSysOpenQuery(cQuery,cAliasT,,,aBind)

nValor := (cAliasT)->VALOR

RestArea(aArea)

Return nValor


/*/{Protheus.doc} LOCA104AAC
Validação para varifica se podemos realizar as operações sobre o model
@type function
@version 25.10 
@author Alexandre Circenis
@since 5/6/2025
@param oModel, object, Model do ITem do Romaneio
@return variant, .T. se a operação puder ser realizada
/*/
Function LOCA104AAC( oModel )
Local lRet := .T.
Local nOpc:=oModel:GetOperation()

if nOpc <> MODEL_OPERATION_VIEW .and. nOpc <> MODEL_OPERATION_INSERT
    if FQW->FQW_STATUS = '5'
        Help(" ",1,"LOCA104F_02",, STR0053,1,0)  //"Operação invalida! O Romaneio já tem documento de devolução gerado. O Romaneio só poderá ser visualizado!"
  	    lRet := .F.
    endif
endif

return lRet
